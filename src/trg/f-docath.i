/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура записи истории атрибутов платежа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/18/03
Author: Bakhtadze Natalya
Creation date: 11/18/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "trig" &then

procedure write-fin-doc-attr-trigger :
define input parameter p-new-record as logical no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .

define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.


  do
  on error undo, return error
  :

    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-fin-doc-attr.
    buffer-copy {2} to buf_c-fin-doc-attr
    assign
    buf_c-fin-doc-attr.host-code          = (if p-new-record then {3}.host-code else {2}.host-code)
    buf_c-fin-doc-attr.fin-doc-code       = (if p-new-record then {3}.fin-doc-code else {2}.fin-doc-code)
    buf_c-fin-doc-attr.attr-code          = (if p-new-record then {3}.attr-code else {2}.attr-code)
    buf_c-fin-doc-attr.chip-num           = next-value (s-corr-chip, {&db-name_schema})
    buf_c-fin-doc-attr.corr-time          = v-time
    buf_c-fin-doc-attr.corr-user-db-num   = g#db-num
    buf_c-fin-doc-attr.corr-user-name     = g#userid
    buf_c-fin-doc-attr.corr-date          = v-date
    .
    release buf_c-fin-doc-attr.
    /*чтобы отработал триггер на запись buf_c-trn-doc раньше чем отработает триггер на удаление fin-doc*/
  end. /*doe*/

end procedure. /* write-fin-doc-trigger */

&endif

procedure write-fin-doc-attr-proc :
define parameter buffer buf_fin-doc-attr for ub.fin-doc-attr.
define variable v-date as date no-undo .
define variable v-time as integer no-undo .

define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.


  do
  on error undo, return error
  :

    if not available buf_fin-doc-attr then do:
      undo, return error (vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description  + {&new-line} +
                    "Ошибка задания входных параметров:Не определен атрибут платежа" ).
    end.


    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-fin-doc-attr.
    buffer-copy buf_fin-doc-attr to buf_c-fin-doc-attr
    assign
    buf_c-fin-doc-attr.chip-num           = next-value (s-corr-chip, {&db-name_schema})
    buf_c-fin-doc-attr.corr-time          = v-time
    buf_c-fin-doc-attr.corr-user-db-num   = g#db-num
    buf_c-fin-doc-attr.corr-user-name     = g#userid
    buf_c-fin-doc-attr.corr-date          = v-date
    .
    release buf_c-fin-doc-attr.
    /*чтобы отработал триггер на запись buf_c-trn-doc раньше чем отработает триггер на удаление fin-doc*/
  end. /*doe*/

end procedure. /* write-fin-doc-history */