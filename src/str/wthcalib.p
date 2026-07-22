block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wthcalib.p $
$Archive: str/wthcalib.p $

Библиотека процедур для работы с атрибутами документа МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 04/10/08
Author: Polina Gridchina
Creation date: 04/10/08

Input:

Output:

*/


define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: wthcalib.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/wthcalib.p $":U .
define variable vss-description as character no-undo initial "Библиотека процедур для работы с атрибутами документа МЦ":U.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/wthcalib.i }

/*----------------------------ВНИМАНИЕ!!!--------------------------------------------------- */
/* значения атрибутов имеющих логический тип должны записываться в базу чисто как yes или no */
/* все форматирование осуществлять на верхнем уровне                                         */



if valid-handle( g#wthcalib ) and g#wthcalib <> this-procedure :handle then do:
  message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 0 ) vss-description skip( 1 )
          "wthcalib.p: попытка повторной загрузки библиотеки" skip( 1 )
          g#wthcalib                     skip( 0 )
          g#wthcalib     :type           skip( 0 )
          g#wthcalib     :file-name      skip( 0 )
          valid-handle( g#wthcalib     ) skip( 0 )
          this-procedure :handle         skip( 0 )
          this-procedure :type           skip( 0 )
          this-procedure :file-name      skip( 0 )
          valid-handle( this-procedure ) skip( 0 )
  view-as alert-box error title " О Ш И Б К А  ! ! ! ".
  undo, return error "wthcalib.p: попытка повторной загрузки библиотеки".
end.
else do:
  assign
    g#wthcalib = this-procedure :handle
  .
end.

on delete of this-procedure do:
  assign
    g#wthcalib = ?
  .
end.

procedure wthcalib_wthat-val :
  define  input parameter p-doc-code like ub.wth-doc-attr.doc-code   no-undo.
  define  input parameter p-code     like ub.wth-doc-attr.attr-code  no-undo.
  define output parameter p-value    like ub.wth-doc-attr.attr-value no-undo.
  define output parameter p-type     as   character              no-undo.

  define buffer buf_wth-doc-attr for ub.wth-doc-attr.

  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.

  do on error undo, return error return-value :
    { str/wthatcod.i p-code
                 p-type
                 v-format
                 v-fillin_width
                 v-fillin_height
                 v-label
                 v-user-can-edit
                 v-output-display
                 v-other          no-error }
    if error-status :error then do: undo, return error return-value. end.

    find first buf_wth-doc-attr no-lock where
               buf_wth-doc-attr.doc-code  = p-doc-code and
               buf_wth-doc-attr.attr-code = p-code     no-error.
    assign p-value = ( if available buf_wth-doc-attr then buf_wth-doc-attr.attr-value else
                     ( if p-type = {&type-log} then "no":U else "":U ) ).
  end. /* on error */
end procedure. /* wthcalib_wthat-val */

procedure wthcalib_wthat-wrt :
  define input parameter p-doc-code like ub.wth-doc-attr.doc-code   no-undo.
  define input parameter p-code     like ub.wth-doc-attr.attr-code  no-undo.
  define input parameter p-value    like ub.wth-doc-attr.attr-value no-undo.

  define buffer buf_wth-doc-attr for ub.wth-doc-attr.

  define variable v-type           as character no-undo.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.

  do on error undo, return error return-value :
    { str/wthatcod.i p-code
                 v-type
                 v-format
                 v-fillin_width
                 v-fillin_height
                 v-label
                 v-user-can-edit
                 v-output-display
                 v-other          no-error }
    if error-status :error then do: undo, return error return-value. end.

    find first buf_wth-doc-attr exclusive-lock where
               buf_wth-doc-attr.doc-code  = p-doc-code and
               buf_wth-doc-attr.attr-code = p-code     no-error.
    if not available buf_wth-doc-attr then do:
      create buf_wth-doc-attr.
      assign buf_wth-doc-attr.doc-code  = p-doc-code
             buf_wth-doc-attr.attr-code = p-code.
    end.
    assign buf_wth-doc-attr.attr-value = p-value.
  end. /* on error */
end procedure. /* wthcalib_wthat-wrt */

procedure wthcalib_wthat-xst :
  define  input parameter p-doc-code like ub.wth-doc-attr.doc-code  no-undo.
  define  input parameter p-code     like ub.wth-doc-attr.attr-code no-undo.
  define output parameter p-exist    as   logical               no-undo.

  define buffer buf_wth-doc-attr for ub.wth-doc-attr.

  define variable v-type           as character no-undo.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.

  do on error undo, return error return-value :
    { str/wthatcod.i p-code
                 v-type
                 v-format
                 v-fillin_width
                 v-fillin_height
                 v-label
                 v-user-can-edit
                 v-output-display
                 v-other          no-error }
    if error-status :error then do: undo, return error return-value. end.

    find first buf_wth-doc-attr no-lock where
               buf_wth-doc-attr.doc-code  = p-doc-code and
               buf_wth-doc-attr.attr-code = p-code     no-error.
    if available buf_wth-doc-attr then do: p-exist = yes. end.
  end. /* on error */
end procedure. /* wthcalib_wthat-xst */

procedure wthcalib_wthat-del:
  define  input parameter p-doc-code like ub.wth-doc-attr.doc-code  no-undo.
  define  input parameter p-code     like ub.wth-doc-attr.attr-code no-undo.
  define output parameter p-deleted  as   logical               no-undo.

  define buffer buf_wth-doc-attr for ub.wth-doc-attr.

  define variable v-type           as character no-undo.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  do on error undo, return error return-value :
    { str/wthatcod.i p-code
                 v-type
                 v-format
                 v-fillin_width
                 v-fillin_height
                 v-label
                 v-user-can-edit
                 v-output-display
                 v-other          no-error }
    if error-status :error then do: undo, return error return-value. end.

    find first buf_wth-doc-attr exclusive-lock where
               buf_wth-doc-attr.doc-code  = p-doc-code and
               buf_wth-doc-attr.attr-code = p-code     no-error no-wait.
    if not available buf_wth-doc-attr then do:
      assign p-deleted = no.
    end.
    else do:
    /*  delete buf_wth-doc-attr. */
      assign buf_wth-doc-attr.attr-value = '':U.
           assign p-deleted = yes.
    end.
  end. /* on error */
end procedure. /* wthcalib_wthat-del */

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign p-label          = ~{&label-~{&attr-code~}~} ~
           p-type           = ~{&type-~{&attr-code~}~} ~
           p-format         = ~{&format-~{&attr-code~}~} ~
           p-fillin_width   = ~{&fillin_width-~{&attr-code~}~} ~
           p-fillin_height  = ~{&fillin_height-~{&attr-code~}~} ~
           p-label          = ~{&label-~{&attr-code~}~} ~
           p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
           p-output-display = ~{&output-display-~{&attr-code~}~} ~
           p-other          = ~{&other-~{&attr-code~}~} . ~
  end.

procedure wthcalib_wthat-cod :
  define  input parameter p-code           as character no-undo. /* код атрибута    */
  define output parameter p-type           as character no-undo. /* тип атрибута    */
  define output parameter p-format         as character no-undo. /* формат атрибута */
  define output parameter p-fillin_width   as integer   no-undo. /* ширина          */
  define output parameter p-fillin_height  as integer   no-undo. /* высота          */
  define output parameter p-label          as character no-undo. /* лабел атрибута */
  define output parameter p-user-can-edit  as logical   no-undo. /* пользователь может изменять в броусе */
  define output parameter p-output-display as logical   no-undo. /* виден в броусе */
  define output parameter p-other          as character no-undo. /* еще чего - нибудь */

  do on error undo, return error return-value :
    case p-code :
      &scop attr-code wthcattr-dsf
      {&attr-temp-full-code}
      &scop attr-code wthcattr-nsf
      {&attr-temp-full-code}
      &scop attr-code wthcattr-proxy
      {&attr-temp-full-code}
      &scop attr-code wthcattr-paydoc
      {&attr-temp-full-code}
      &scop attr-code wthcattr-receiver
      {&attr-temp-full-code}
      &scop attr-code wthcattr-reason
      {&attr-temp-full-code}
      &scop attr-code wthcattr-consignee
      {&attr-temp-full-code}

            /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute( 'неизвестный атрибут документа "&1"', p-code ).
      end.
    end case. /* p-code */
  end. /* on error */
end procedure. /* wthcalib_wthat-cod */

/* Обработка v-other */
procedure wthcalib_wthat-oth :
  define input parameter p-doc-code as character no-undo.
  define input parameter p-code     as character no-undo. /* код атрибута */
  define input parameter p-value    as character no-undo. /* значение атрибута */

  define variable v-type           as character no-undo. /* тип атрибута    */
  define variable v-format         as character no-undo. /* формат атрибута */
  define variable v-fillin_width   as integer   no-undo. /* ширина          */
  define variable v-fillin_height  as integer   no-undo. /* высота          */
  define variable v-label          as character no-undo. /* лабел атрибута  */
  define variable v-user-can-edit  as logical   no-undo. /* пользователь может изменять в броусе */
  define variable v-output-display as logical   no-undo. /* виден в броусе  */
  define variable v-other          as character no-undo. /* еще чего-нибудь */

  define buffer buf_wth-doc-attr for ub.wth-doc-attr.

  define buffer bf_wth-doc   for ub.wth-doc.

  do on error undo, return error return-value :
     { str/wthatcod.i p-code
                  v-type
                  v-format
                  v-fillin_width
                  v-fillin_height
                  v-label
                  v-user-can-edit
                  v-output-display
                  v-other          }


    /* отправить по новостям самостоятельно без документа. */
    if lookup( "nws":U, v-other,{&slash-char} ) > 0 then do:
      find first bf_wth-doc no-lock where
                 bf_wth-doc.doc-code = p-doc-code /* and
                 bf_wth-doc.status_  = {&ready} */ no-error.
      if available bf_wth-doc and bf_wth-doc.status_ = {&fact} then do:
        find first buf_wth-doc-attr no-lock where
                   buf_wth-doc-attr.doc-code  = p-doc-code and
                   buf_wth-doc-attr.attr-code = p-code     no-error.
        run str/callnews.p ( input "wth-doc-attr", input ( buffer buf_wth-doc-attr :handle ) ) no-error.
        if error-status :error then do:
          message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
                  "Невозможно маршрутизировать wth-doc-attr для отправки в новости" skip( 0 )
                  "Документ:" '"' + bf_wth-doc.doc-code    + '"' skip( 0 )
                  "Атрибут:"  '"' + buf_wth-doc-attr.attr-code + '"' skip( 0 )
                  error-status :get-message( 1 ) skip( 0 )
                  error-status :get-message( 2 ) skip( 0 )
                  error-status :get-message( 3 ) skip( 0 )
                  "return-value = " return-value skip( 0 )
          view-as alert-box error.
          undo, return error return-value.
        end. /* error */
      end. /* if available bf_wth-doc */
    end. /* if lookup( "nws":U, v-other ) > 0 */
  end. /* on error */
end procedure. /* wthcalib_wthat-oth */
/*
procedure wthcattr-sprcli :
define input parameter parparentproc  as widget-handle no-undo.
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
 do
  on error undo, return error
  :
    &scop proc-name wthcattr-sprcli-proc
    {&run_proc_wthcalib}
      (input  parparentproc
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
 end.

end procedure.   */

/* $Workfile: wthcalib.p $   E n d */