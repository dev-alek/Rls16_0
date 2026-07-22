/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура создания истории ТОВАРА НА ОБЪЕКТЕ - для тех полей, которые являются справочной информацией

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/22/09
Author: Bakhtadze Natalya
Creation date: 12/22/09

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ nws/lib-nws.i }
{ gbl/cur-time.i }

procedure gds-objh_write-gds-obj-proc  :
define parameter buffer buf_gds-obj for ub.gds-obj .
define input parameter p-action as integer no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-current-db-num as integer no-undo .
define variable v-news as logical no-undo .
define variable v-esys as logical no-undo .
define variable v-userid as character no-undo .
define variable v-h as handle no-undo .
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_c-gds-obj-ref for ub.c-gds-obj-ref.


  do
  on error undo, return error
  :
    if not available buf_gds-obj then do:
      undo, return error (vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description  + {&new-line} +
                    "Ошибка задания входных параметров:Не определен товар на объекте" ).
    end.
    /*найдем контекст*/
    { gbl/calltree.i 'mainhandle_parentproc_indicator' this-procedure:handle ? v-h }
    run get-news in v-h ( output v-news) no-error.
    if v-news or not valid-handle(v-h) then return ''.
    run get-db-num in v-h ( output v-current-db-num).
    run get-userid in v-h ( output v-userid).
    run get-esys in v-h ( output v-esys).
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-gds-obj-ref.
    buffer-copy buf_gds-obj to buf_c-gds-obj-ref
    assign
    buf_c-gds-obj-ref.gds-code           = buf_gds-obj.gds-code
    buf_c-gds-obj-ref.obj-type           = buf_gds-obj.obj-type
    buf_c-gds-obj-ref.obj-code           = buf_gds-obj.obj-code
    buf_c-gds-obj-ref.chip-num           = next-value (s-gds-chip, {&db-name_schema})
    buf_c-gds-obj-ref.corr-time          = v-time
    buf_c-gds-obj-ref.corr-user-db-num   = v-current-db-num
    buf_c-gds-obj-ref.corr-user-name     = (if v-news then {&nts-user}
                                      else (if v-esys
                                            then {&esys-user}
                                            else v-userid)
                                            )
    buf_c-gds-obj-ref.corr-date          = v-date
    .
    create buf_c-gds-hist.
    buffer-copy buf_c-gds-obj-ref to buf_c-gds-hist
    assign
    buf_c-gds-hist.action =  p-action
    buf_c-gds-hist.subject = {&table_gds-obj}
    buf_c-gds-hist.is-news = v-news
    buf_c-gds-hist.source-type = p-source-type
    buf_c-gds-hist.source-ref = p-source-ref
    .
    run nws/cr-route.p ( input {&send-tbl}
                       , input {&table_c-gds-obj-ref}
                       , input buffer buf_c-gds-obj-ref:handle
                       , input '' ) .
    run nws/cr-route.p ( input {&send-tbl}
                       , input {&table_c-gds-hist}
                       , input buffer buf_c-gds-hist:handle
                       , input '' ) .

  end.

end procedure. /* gds-objh_write-gds-obj-proc  */


/* $Workfile$ e n d */