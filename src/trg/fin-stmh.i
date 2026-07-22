/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура записи истории банковской выписки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/18/03
Author: Bakhtadze Natalya
Creation date: 11/18/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table tt-fin-statement no-undo like ub.fin-statement.

procedure fin-statementh_write-fin-statement-history :
define parameter buffer buf_fin-statement for tt-fin-statement.
define input parameter p-host-code like ub.fin-statement.host-code no-undo .
define input parameter p-sttm-code  like ub.fin-statement.sttm-code no-undo .

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-message as character no-undo .
define variable v-create-hist as logical no-undo .
define variable v-result as character no-undo .

define buffer buf_c-fin-statement for ub.c-fin-statement.
define buffer buf_c-fin-statement-line for ub.c-fin-statement-line.
define buffer buf_c-fin-statement-attr for ub.c-fin-statement-attr.
define buffer prev_c-fin-statement-line for ub.c-fin-statement-line.
define buffer prev_c-fin-statement-attr for ub.c-fin-statement-attr.


do
on error undo, return error return-value
:

  run cur-time in this-procedure ( output v-date, output v-time).

  create buf_c-fin-statement.
  buffer-copy buf_fin-statement to buf_c-fin-statement
  assign
  buf_c-fin-statement.sttm-code          = p-sttm-code
  buf_c-fin-statement.host-code          = p-host-code
  buf_c-fin-statement.chip-num           = next-value (s-fin-corr-chip, {&db-name_schema})
  buf_c-fin-statement.corr-time          = v-time
  buf_c-fin-statement.corr-user-db-num   = g#db-num
  buf_c-fin-statement.corr-user-name     = g#userid
  buf_c-fin-statement.corr-date          = v-date  /*здесь дата объекта*/
  .

  for each ub.fin-statement-line where
          ub.fin-statement-line.sttm-code = buf_fin-statement.sttm-code:
    create buf_c-fin-statement-line.
    buffer-copy ub.fin-statement-line to buf_c-fin-statement-line
    assign
    buf_c-fin-statement-line.chip-num           = buf_c-fin-statement.chip-num
    buf_c-fin-statement-line.corr-user-db-num   = buf_c-fin-statement.corr-user-db-num
    .
  end.
  for each ub.fin-statement-attr where
          ub.fin-statement-attr.sttm-code = buf_fin-statement.sttm-code:
    create buf_c-fin-statement-attr.
    buffer-copy ub.fin-statement-attr to buf_c-fin-statement-attr
    assign
    buf_c-fin-statement-attr.chip-num           = buf_c-fin-statement.chip-num
    buf_c-fin-statement-attr.corr-user-db-num   = buf_c-fin-statement.corr-user-db-num
    .
  end.
    release buf_c-fin-statement.
end. /*doe*/

end procedure. /* fin-statementh_write-fin-statement-history */