/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры записи истории по fin-statement

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/02/05
Author: Bakhtadze Natalya
Creation date: 08/02/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure write-fin-statement-history :
define parameter buffer buf_fin-statement for ub.fin-statement.
define variable v-date as date no-undo .
define variable v-time as integer no-undo .

define buffer buf_c-fin-statement for ub.c-fin-statement.
define buffer buf_c-fin-statement-line for ub.c-fin-statement-line.
define buffer buf_c-fin-statement-attr for ub.c-fin-statement-attr.


  do
  on error undo, return error
  :

    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-fin-statement.
    buffer-copy buf_fin-statement to buf_c-fin-statement
    assign
    buf_c-fin-statement.chip-num           = next-value (s-fin-corr-chip, {&db-name_schema})
    buf_c-fin-statement.corr-time          = v-time
    buf_c-fin-statement.corr-user-db-num   = g#db-num
    buf_c-fin-statement.corr-user-name     = g#userid
    buf_c-fin-statement.corr-date          = v-date
    buf_c-fin-statement.corr-doc-code      = "":U /*todo*/
    .
    for each ub.fin-statement-line where
             ub.fin-statement-line.host-code = buf_fin-statement.host-code
         AND ub.fin-statement-line.sttm-code = buf_fin-statement.sttm-code:
      create buf_c-fin-statement-line.
      buffer-copy ub.fin-statement-line to buf_c-fin-statement-line
      assign
      buf_c-fin-statement-line.chip-num           = buf_c-fin-statement.chip-num
      buf_c-fin-statement-line.corr-user-db-num   = buf_c-fin-statement.corr-user-db-num
      .
    end.
    for each ub.fin-statement-attr where
             ub.fin-statement-attr.host-code = buf_fin-statement.host-code
         AND ub.fin-statement-attr.sttm-code = buf_fin-statement.sttm-code:
      create buf_c-fin-statement-attr.
      buffer-copy ub.fin-statement-attr to buf_c-fin-statement-attr
      assign
      buf_c-fin-statement-attr.chip-num           = buf_c-fin-statement.chip-num
      buf_c-fin-statement-attr.corr-user-db-num   = buf_c-fin-statement.corr-user-db-num
      buf_c-fin-statement-attr.attr-value         = buf_c-fin-statement-attr.attr-value
      .
    end.
    release buf_c-fin-statement.
    /*чтобы отработал триггер на запись buf_c-fin-statement раньше чем отработает триггер на удаление fin-statement*/
  end. /*doe*/

end procedure. /* write-fin-statement-history */


/* $Workfile$ e n d */