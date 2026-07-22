/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры записи истории  для спула шкал

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/31/05
Author: Bakhtadze Natalya
Creation date: 08/31/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "gds-prt-trig" &then

procedure gds-prth_write-gds-prt-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-action as integer no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-prt for ub.c-gds-prt.


  do
  on error undo, return error
  :

    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-gds-prt.
    buffer-copy {2} to buf_c-gds-prt
    assign
    buf_c-gds-prt.node-code          = (if p-new-record then {3}.node-code else {2}.node-code)
    buf_c-gds-prt.prt-root           = (if p-new-record then {3}.prt-root else {2}.prt-root)
    buf_c-gds-prt.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
    buf_c-gds-prt.corr-time          = v-time
    buf_c-gds-prt.corr-user-db-num   = g#db-num
    buf_c-gds-prt.corr-user-name     = (if g#news then {&nts-user} else g#userid)
    buf_c-gds-prt.corr-date          = v-date
    buf_c-gds-prt.action = p-action
    .
  end.

end procedure.

&endif

/* $Workfile$ e n d */