/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: xmlfilder.cls $
$Archive: ibs/th/gbl/xmlfilder.cls $


Автор: Хныкин Павел Андреевич
Дата создания: 07/24/08
Author: Pavel Khnykin
Creation date: 07/24/08

*/

block-level on error undo, throw.
CLASS Ibs.Th.Gbl.XmlFilder:
  { cmp/str-glbl.i class }
  &scoped-define vssseq {&sequence}
  define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: xmlfilder.cls $ $Revision: aea5316774be, 0, rls $".


  define private temp-table tag-pair no-undo
    field tag-name  as character
    field tag-value as character
    field is-set    as logical
  index pi is primary unique
    tag-name
  index iset
    is-set
  .

  define private variable hdocument as handle    no-undo .
  define private variable hroot     as handle    no-undo .
  define private variable hchild    as handle    no-undo .
  define private variable htext     as handle    no-undo .

  define private variable v-is-correct-parse  as logical   no-undo .
  define private variable v-tag-list          as character no-undo .
  define private variable v-err-message       as character no-undo .


  constructor public XmlFilder () :

  end constructor.


  DESTRUCTOR XmlFilder () :
    empty temp-table tag-pair.

    if valid-handle (hdocument)
    then do:
      delete object hdocument no-error .
    end.

    if valid-handle (hroot)
    then do:
      delete object hroot no-error .
    end.

    if valid-handle (hchild)
    then do:
      delete object hchild no-error .
    end.

    if valid-handle (htext)
    then do:
      delete object htext no-error .
    end.

    assign
      hdocument = ?
      hroot     = ?
      hchild    = ?
      htext     = ?
    .

  END DESTRUCTOR.


  define public property well-parsed as logical   no-undo
    get:
      return v-is-correct-parse.
    end get.


  define public property error-message as character no-undo
    get:
      return v-err-message.
    end get.


  method public void set-tag-list ( input p-tag-list as character ) :

    define buffer buf_tag-pair for tag-pair.

    define variable v-num-entries as integer   no-undo .
    define variable v-i           as integer   no-undo .
    define variable v-tag-name    as character no-undo .

    do
    on error undo, return error return-value
    :
      empty temp-table buf_tag-pair.

      assign
        v-num-entries       = num-entries(p-tag-list)
        v-is-correct-parse  = false
        v-tag-list          = p-tag-list
        v-err-message       = ""
      .

      do v-i = 1 to v-num-entries
      :
        assign
          v-tag-name = entry(v-i, p-tag-list)
        .
        find first buf_tag-pair where buf_tag-pair.tag-name = v-tag-name no-error .
        if not available buf_tag-pair then do:
          create buf_tag-pair.
          assign
            buf_tag-pair.tag-name = v-tag-name
            buf_tag-pair.is-set   = false
          .
        end.
      end.
    end.

  end method.


  method public logical parse( input p-parse-str as character) :

    define buffer buf_tag-pair for tag-pair.

    define variable v-parse-str   as longchar  no-undo .
    define variable v-log         as logical   no-undo .
    define variable v-i           as integer   no-undo .
    define variable v-tag-name    as character no-undo .
    define variable v-tag-value   as character no-undo .

    do
    on error undo, return error return-value
    :
      create x-document hdocument.
      create x-noderef hroot.
      create x-noderef hchild.
      create x-noderef htext.

      assign
        v-parse-str = p-parse-str
      .

      /*hDocument :encoding = "win-1251".*/
      v-log = hDocument :load( "LONGCHAR", v-parse-str, no ) no-error.
      if error-status :error
      then do:
        assign
          v-err-message = substitute( "Ошибка загрузки XML-документа.&1&2&1&3"
                                    , {&new-line}
                                    , error-status :get-message(1)
                                    , error-status :get-message(2)
                                    )
        .
        return false. /* --->>>--- */
      end.
      if v-log <> yes
      then do:
        assign
          v-err-message = substitute( "Ошибка загрузки XML-документа.&1&2&1&3"
                                    , {&new-line}
                                    , error-status :get-message(1)
                                    , error-status :get-message(2)
                                    )
        .
        return false. /* --->>>--- */
      end.

      v-log = hDocument :get-document-element( hRoot ) no-error .
      if v-log <> yes
      then do:
        assign
          v-err-message = "Ошибка нахождения корневого элемнта документа."
        .
        return false. /* --->>>--- */
      end.

      el-tree:
      repeat v-i = 1 to hRoot :num-children
      :
        hRoot :get-child( hChild , v-i ) .
        if hChild :subtype <> 'ELEMENT' or hChild :num-children = 0 then next el-tree.
        assign
          v-tag-name = hChild :name
        .
        find first buf_tag-pair where buf_tag-pair.tag-name = v-tag-name no-error .
        if available buf_tag-pair then do:
          hChild :get-child( hText , 1 ).
          assign
            v-tag-value = hText :node-value
          .
          assign
            buf_tag-pair.tag-value  = v-tag-value
            buf_tag-pair.is-set     = true
          .
        end.
      end.

      delete object hdocument .
      delete object hroot     .
      delete object hchild    .
      delete object htext     .

      assign
        hdocument = ?
        hroot     = ?
        hchild    = ?
        htext     = ?
        v-i       = 0
      .


      for each buf_tag-pair
        where buf_tag-pair.is-set = false
      :
        assign
          v-i = v-i + 1
          v-err-message = buf_tag-pair.tag-name + ', '
        .
      end. /* for each buf_tag-pair  */

      if v-i > 0
      then do:
        assign
          v-err-message = "Не найдены поля: " + v-err-message
        .
        return false.
      end.
      return true.
    end.
  end method.


  method public character get-tag( input p-tag-name as character, output p-found as logical ) :

    define buffer buf_tag-pair  for tag-pair.

    define variable v-tag-value as character no-undo .

    do
    on error undo, return error return-value
    :
      find first buf_tag-pair where buf_tag-pair.tag-name = p-tag-name no-error .
      if available buf_tag-pair
      then do:
        assign
          v-tag-value = buf_tag-pair.tag-value
          p-found     = yes
        .
      end.
      else do:
        assign
          v-tag-value = ?
          p-found     = no
        .
      end.
      return v-tag-value.
    end.
  end method.

end class.
