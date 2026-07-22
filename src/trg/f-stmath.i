/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура записи истории атрибутов выписки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/18/03
Author: Bakhtadze Natalya
Creation date: 11/18/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "trig" &then

procedure write-fin-statement-attr-trigger :
define input parameter p-new-record as logical no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .

define buffer buf_c-fin-statement-attr for ub.c-fin-statement-attr.


  do
  on error undo, return error
  :

    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-fin-statement-attr.
    buffer-copy {2} to buf_c-fin-statement-attr
    assign
    buf_c-fin-statement-attr.host-code          = (if p-new-record then {3}.host-code else {2}.host-code)
    buf_c-fin-statement-attr.sttm-code          = (if p-new-record then {3}.sttm-code else {2}.sttm-code)
    buf_c-fin-statement-attr.attr-code          = (if p-new-record then {3}.attr-code else {2}.attr-code)
    buf_c-fin-statement-attr.chip-num           = next-value (s-fin-corr-chip, {&db-name_schema})
    buf_c-fin-statement-attr.corr-time          = v-time
    buf_c-fin-statement-attr.corr-user-db-num   = g#db-num
    buf_c-fin-statement-attr.corr-user-name     = g#userid
    buf_c-fin-statement-attr.corr-date          = v-date
    .
    release buf_c-fin-statement-attr.
    /*чтобы отработал триггер на запись buf_c-fin-statement раньше чем отработает триггер на удаление fin-statement*/
  end. /*doe*/

end procedure. /* write-fin-statement-trigger */

&endif

procedure write-fin-statement-attr-proc :
define parameter buffer buf_fin-statement-attr for ub.fin-statement-attr.
define variable v-date as date no-undo .
define variable v-time as integer no-undo .

define buffer buf_c-fin-statement-attr for ub.c-fin-statement-attr.


  do
  on error undo, return error
  :

    if not available buf_fin-statement-attr then do:
      undo, return error (vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description  + {&new-line} +
                    "Ошибка задания входных параметров:Не определен атрибут выписки" ).
    end.


    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-fin-statement-attr.
    buffer-copy buf_fin-statement-attr to buf_c-fin-statement-attr
    assign
    buf_c-fin-statement-attr.chip-num           = next-value (s-fin-corr-chip, {&db-name_schema})
    buf_c-fin-statement-attr.corr-time          = v-time
    buf_c-fin-statement-attr.corr-user-db-num   = g#db-num
    buf_c-fin-statement-attr.corr-user-name     = g#userid
    buf_c-fin-statement-attr.corr-date          = v-date
    .
    release buf_c-fin-statement-attr.
    /*чтобы отработал триггер на запись buf_c-trn-doc раньше чем отработает триггер на удаление fin-statement*/
  end. /*doe*/

end procedure. /* write-fin-statement-history */