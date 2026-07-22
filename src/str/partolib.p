block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: partolib.p $
$Archive: str/partolib.p $

Библиотека процедур для работы с атрибутами партии на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/10/10
Author: Bakhtadze Natalya
Creation date: 02/10/10


*/

/* ********************************************************************************************************************* *\
 *                                                                                                                       *
 * procedure partolib_partoval - partsoatr-value                                                                          *
 * procedure partolib_partowrt - partsoatr-write                                                                          *
 * procedure partolib_partoxst - partsoatr-exist                                                                          *
 * procedure partolib_partodel - partsoatr-delete                                                                         *
 * procedure partolib_partocod - partsoatr-code                                                                           *
 * procedure partolib_partooth - proc-other                                                                              *
 *                                                                                                                       *
\* ********************************************************************************************************************* */

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      as character no-undo initial "$Author: expertek $":U.
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: partolib.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: str/partolib.p $":U.
define variable vss-description as character no-undo initial "Библиотека процедур для работы с атрибутами партии на объекте":U.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/partolib.i }

/*----------------------------ВНИМАНИЕ!!!--------------------------------------------------- */
/* значения атрибутов имеющих логический тип должны записываться в базу чисто как yes или no */
/* все форматирование осуществлять на верхнем уровне                                         */

/* Номер партии для документа межфирменного перемещения */


if valid-handle( g#partolib ) and g#partolib <> this-procedure :handle then do:
  message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 0 ) vss-description skip( 1 )
          "partolib.p: попытка повторной загрузки библиотеки" skip( 1 )
          g#partolib                     skip( 0 )
          g#partolib     :type           skip( 0 )
          g#partolib     :file-name      skip( 0 )
          valid-handle( g#partolib     ) skip( 0 )
          this-procedure :handle         skip( 0 )
          this-procedure :type           skip( 0 )
          this-procedure :file-name      skip( 0 )
          valid-handle( this-procedure ) skip( 0 )
  view-as alert-box error title " О Ш И Б К А  ! ! ! ".
  undo, return error "partolib.p: попытка повторной загрузки библиотеки".
end.
else do:
  assign
    g#partolib = this-procedure :handle
  .
end.

on delete of this-procedure do:
  assign
    g#partolib = ?
  .
end.

procedure partolib_partoval :
  define  input parameter p-obj-type as character no-undo .
  define  input parameter p-obj-code as integer no-undo .
  define  input parameter p-gds-code as integer no-undo .
  define  input parameter p-prt-code as integer no-undo .
  define  input parameter p-in-code as character no-undo .
  define  input parameter p-out-code as character no-undo .
  define  input parameter p-part-code as character no-undo .
  define  input parameter p-code     like ub.parts-obj-attr.attr-code  no-undo.
  define output parameter p-value    like ub.parts-obj-attr.attr-value no-undo.
  define output parameter p-type     as   character              no-undo.

  define buffer buf_parts-obj-attr for ub.parts-obj-attr.

  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .
  define variable v-sort as integer   no-undo .
  do on error undo, return error return-value :
    { str/partocod.i p-code
                 p-type
                 v-format
                 v-fillin_width
                 v-fillin_height
                 v-label
                 v-user-can-edit
                 v-output-display
                 v-other
                 v-proc-attr
                 v-full-screen-val
                 v-sort
                 no-error }
    if error-status :error then do: undo, return error return-value. end.

    find first buf_parts-obj-attr no-lock where
               buf_parts-obj-attr.obj-type  = p-obj-type
           and buf_parts-obj-attr.obj-code  = p-obj-code
           and buf_parts-obj-attr.gds-code  = p-gds-code
           and buf_parts-obj-attr.prt-code  = p-prt-code
           and buf_parts-obj-attr.in-code  = p-in-code
           and buf_parts-obj-attr.out-code  = p-out-code
           and buf_parts-obj-attr.part-code  = p-part-code
           and buf_parts-obj-attr.attr-code = p-code     no-error.
    assign p-value = ( if available buf_parts-obj-attr then buf_parts-obj-attr.attr-value else
                     ( if p-type = {&type-log} then "no":U else "":U ) ).
  end. /* on error */
end procedure. /* partolib_partoval */

procedure partolib_partowrt :
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer no-undo .
  define input parameter p-gds-code as integer no-undo .
  define input parameter p-prt-code as integer no-undo .
  define input parameter p-in-code as character no-undo .
  define input parameter p-out-code as character no-undo .
  define input parameter p-part-code as character no-undo .
  define input parameter p-code     like ub.parts-obj-attr.attr-code  no-undo.
  define input parameter p-value    like ub.parts-obj-attr.attr-value no-undo.

  define buffer buf_parts-obj-attr for ub.parts-obj-attr.
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .

  define variable v-type           as character no-undo.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  define variable v-sort           as integer   no-undo .

  do on error undo, return error return-value :
    { str/partocod.i p-code
                 v-type
                 v-format
                 v-fillin_width
                 v-fillin_height
                 v-label
                 v-user-can-edit
                 v-output-display
                 v-other
                 v-proc-attr
                 v-full-screen-val
                 v-sort
                 no-error }

    if error-status :error then do: undo, return error return-value. end.

    find first buf_parts-obj-attr exclusive-lock where
               buf_parts-obj-attr.obj-type  = p-obj-type
           and buf_parts-obj-attr.obj-code  = p-obj-code
           and buf_parts-obj-attr.gds-code  = p-gds-code
           and buf_parts-obj-attr.prt-code  = p-prt-code
           and buf_parts-obj-attr.in-code  = p-in-code
           and buf_parts-obj-attr.out-code  = p-out-code
           and buf_parts-obj-attr.part-code  = p-part-code
           and buf_parts-obj-attr.attr-code = p-code     no-error.

    if not available buf_parts-obj-attr then do:
      create buf_parts-obj-attr.
      assign
      buf_parts-obj-attr.obj-type  = p-obj-type
      buf_parts-obj-attr.obj-code  = p-obj-code
      buf_parts-obj-attr.gds-code  = p-gds-code
      buf_parts-obj-attr.prt-code  = p-prt-code
      buf_parts-obj-attr.in-code  = p-in-code
      buf_parts-obj-attr.out-code  = p-out-code
      buf_parts-obj-attr.part-code  = p-part-code
      buf_parts-obj-attr.attr-code = p-code.
    end.
    assign buf_parts-obj-attr.attr-value = p-value.
  end. /* on error */
end procedure. /* partolib_partowrt */

procedure partolib_partoxst :
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer no-undo .
  define input parameter p-gds-code as integer no-undo .
  define input parameter p-prt-code as integer no-undo .
  define input parameter p-in-code as character no-undo .
  define input parameter p-out-code as character no-undo .
  define input parameter p-part-code as character no-undo .
  define input parameter p-code     like ub.parts-obj-attr.attr-code no-undo.
  define output parameter p-exist    as   logical               no-undo.

  define buffer buf_parts-obj-attr for ub.parts-obj-attr.

  define variable v-type           as character no-undo.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .
  define variable v-sort as integer   no-undo .

  do on error undo, return error return-value :
    { str/partocod.i p-code
                 v-type
                 v-format
                 v-fillin_width
                 v-fillin_height
                 v-label
                 v-user-can-edit
                 v-output-display
                 v-other
                 v-proc-attr
                 v-full-screen-val
                 v-sort
                 no-error }

    if error-status :error then do: undo, return error return-value. end.

    find first buf_parts-obj-attr no-lock where
               buf_parts-obj-attr.obj-type  = p-obj-type
           and buf_parts-obj-attr.obj-code  = p-obj-code
           and buf_parts-obj-attr.gds-code  = p-gds-code
           and buf_parts-obj-attr.prt-code  = p-prt-code
           and buf_parts-obj-attr.in-code  = p-in-code
           and buf_parts-obj-attr.out-code  = p-out-code
           and buf_parts-obj-attr.part-code  = p-part-code
           and buf_parts-obj-attr.attr-code = p-code     no-error.

    if available buf_parts-obj-attr then do: p-exist = yes. end.
  end. /* on error */
end procedure. /* partolib_partoxst */

procedure partolib_partodel :
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer no-undo .
  define input parameter p-gds-code as integer no-undo .
  define input parameter p-prt-code as integer no-undo .
  define input parameter p-in-code as character no-undo .
  define input parameter p-out-code as character no-undo .
  define input parameter p-part-code as character no-undo .
  define  input parameter p-code     like ub.parts-obj-attr.attr-code no-undo.
  define output parameter p-deleted  as   logical               no-undo.

  define buffer buf_parts-obj-attr for ub.parts-obj-attr.

  define variable v-type           as character no-undo.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .
  define variable v-sort as integer   no-undo .
  do on error undo, return error return-value :
    { str/partocod.i p-code
                 v-type
                 v-format
                 v-fillin_width
                 v-fillin_height
                 v-label
                 v-user-can-edit
                 v-output-display
                 v-other
                 v-proc-attr
                 v-full-screen-val
                 v-sort
                 no-error }

    if error-status :error then do: undo, return error return-value. end.

    find first buf_parts-obj-attr exclusive-lock where
               buf_parts-obj-attr.obj-type  = p-obj-type
           and buf_parts-obj-attr.obj-code  = p-obj-code
           and buf_parts-obj-attr.gds-code  = p-gds-code
           and buf_parts-obj-attr.prt-code  = p-prt-code
           and buf_parts-obj-attr.in-code  = p-in-code
           and buf_parts-obj-attr.out-code  = p-out-code
           and buf_parts-obj-attr.part-code  = p-part-code
           and buf_parts-obj-attr.attr-code = p-code     no-error no-wait.

    if not available buf_parts-obj-attr then do:
      assign p-deleted = no.
    end.
    else do:
      delete buf_parts-obj-attr.
      assign p-deleted = yes.
    end.
  end. /* on error */
end procedure. /* partolib_partodel */

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign p-label          = ~{&label-~{&attr-code~}~} ~
           p-type           = ~{&type-~{&attr-code~}~}  ~
           p-format         = ~{&format-~{&attr-code~}~} ~
           p-fillin_width   = ~{&fillin_width-~{&attr-code~}~} ~
           p-fillin_height  = ~{&fillin_height-~{&attr-code~}~} ~
           p-label          = ~{&label-~{&attr-code~}~} ~
           p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
           p-output-display = ~{&output-display-~{&attr-code~}~} ~
           p-sort           = ~{&sort-~{&attr-code~}~} ~
           p-proc-attr      = '' ~
           p-other          = ~{&other-~{&attr-code~}~} . ~
&if '~{&proc-~{&attr-code~}~} ' <> '' &then  p-proc-attr = ~{&proc-~{&attr-code~}~}  .  &endif ~
  end.

procedure partolib_partocod :
  define  input parameter p-code           as character no-undo. /* код атрибута    */
  define output parameter p-type           as character no-undo. /* тип атрибута    */
  define output parameter p-format         as character no-undo. /* формат атрибута */
  define output parameter p-fillin_width   as integer   no-undo. /* ширина          */
  define output parameter p-fillin_height  as integer   no-undo. /* высота          */
  define output parameter p-label          as character no-undo. /* лабел атрибута */
  define output parameter p-user-can-edit  as logical   no-undo. /* пользователь может изменять в броусе */
  define output parameter p-output-display as logical   no-undo. /* виден в броусе */
  define output parameter p-other          as character no-undo. /* еще чего - нибудь */
  define output parameter p-proc-attr       as character no-undo. /* процедура корректировки */
  define output parameter p-full-screen-val as character no-undo. /* screen-value */
  define output parameter p-sort as integer   no-undo .

  do on error undo, return error return-value :
    case p-code :
      &scop attr-code partoatr-parts-end
      {&attr-temp-full-code}


      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute( 'неизвестный атрибут документа "&1"', p-code ).
      end.
    end case. /* p-code */
  end. /* on error */
end procedure. /* partolib_partocod */

/* Обработка v-other */
procedure partolib_tdat-oth :
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer no-undo .
  define input parameter p-gds-code as integer no-undo .
  define input parameter p-prt-code as integer no-undo .
  define input parameter p-in-code as character no-undo .
  define input parameter p-out-code as character no-undo .
  define input parameter p-part-code as character no-undo .
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
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .
  define variable v-sort as integer   no-undo .

  define buffer buf_parts-obj-attr for ub.parts-obj-attr.

  do on error undo, return error return-value :
     { str/partocod.i p-code
                  v-type
                  v-format
                  v-fillin_width
                  v-fillin_height
                  v-label
                  v-user-can-edit
                  v-output-display
                  v-other
                  v-proc-attr
                  v-full-screen-val
                  v-sort
                  no-error }


    /* отправить по новостям самостоятельно без документа. */
    if lookup( "nws":U, v-other ) > 0 then do:

    end. /* if lookup( "nws":U, v-other ) > 0 */
  end. /* on error */
end procedure. /* partolib_partooth */

procedure partolib_tdatothn :
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer no-undo .
  define input parameter p-gds-code as integer no-undo .
  define input parameter p-prt-code as integer no-undo .
  define input parameter p-in-code as character no-undo .
  define input parameter p-out-code as character no-undo .
  define input parameter p-part-code as character no-undo .
  define input parameter p-code     as character no-undo. /* код атрибута */

  define variable v-type           as character no-undo. /* тип атрибута    */
  define variable v-format         as character no-undo. /* формат атрибута */
  define variable v-fillin_width   as integer   no-undo. /* ширина          */
  define variable v-fillin_height  as integer   no-undo. /* высота          */
  define variable v-label          as character no-undo. /* лабел атрибута  */
  define variable v-user-can-edit  as logical   no-undo. /* пользователь может изменять в броусе */
  define variable v-output-display as logical   no-undo. /* виден в броусе  */
  define variable v-other          as character no-undo. /* еще чего-нибудь */
  define variable v-proc-attr       as character no-undo .
  define variable v-full-screen-val as character no-undo .
  define variable v-sort as integer   no-undo .

  define buffer buf_parts-obj-attr for ub.parts-obj-attr.

  do on error undo, return error return-value :
    find first buf_parts-obj-attr no-lock where
               buf_parts-obj-attr.obj-type  = p-obj-type
           and buf_parts-obj-attr.obj-code  = p-obj-code
           and buf_parts-obj-attr.gds-code  = p-gds-code
           and buf_parts-obj-attr.prt-code  = p-prt-code
           and buf_parts-obj-attr.in-code  = p-in-code
           and buf_parts-obj-attr.out-code  = p-out-code
           and buf_parts-obj-attr.part-code  = p-part-code
           and buf_parts-obj-attr.attr-code = p-code     no-error no-wait.


    run str/callnews.p ( input {&table_parts-obj-attr}
                       , input ( buffer buf_parts-obj-attr :handle ) ) no-error.
    if error-status :error then do:
      message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
              "Невозможно маршрутизировать part-obj-attr для отправки в новости" skip( 0 )
              "Атрибут:"  '"' + buf_parts-obj-attr.attr-code + '"' skip( 0 )
              error-status :get-message( 1 ) skip( 0 )
              error-status :get-message( 2 ) skip( 0 )
              error-status :get-message( 3 ) skip( 0 )
              "return-value = " return-value skip( 0 )
      view-as alert-box error.
      undo, return error return-value.
    end. /* error */

  end. /* on error */
end procedure. /* partolib_partothn */

/* $Workfile: partolib.p $   E n d */