/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Общие код для почасвого отчета по величинам сумм продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/02/05
Author: Bakhtadze Natalya
Creation date: 09/02/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer tot_full-grp for full-grp.

for each obj-list no-lock:
  assign
  accum-obj-list = accum-obj-list + 1.
  if accum-obj-list > 1 then LEAVE.
end.

CASE method:
  when "LINE":U then do:
    run waitfram-show in this-procedure ("Строю дерево групп ..."). /*пробелы не стирать!!!*/
    for each ub.gds-grp no-lock:
      find first for-grp where
                for-grp.upper-code = ub.gds-grp.node-code No-LOCK No-ERROR.
      if not avail for-grp then do:
        create full-grp.
        assign
        full-grp.grp-code = ub.gds-grp.node-code.
        if tree then
        run grplib-get-full-name in this-procedure(input ub.gds-grp.node-code, output full-grp.full-name).
        else
        full-grp.full-name = ub.gds-grp.node-name.
        full-grp.full-name = replace(full-grp.full-name, " ", "_").
      end.
    end. /*for each gds-grp no-lock:*/
    run waitfram-hide in this-procedure .
  end. /*line*/
  when "pay":U then do:
    for each ub.cash-pay No-LOCK:
      create full-grp.
      assign
      full-grp.grp-code = ub.cash-pay.cdpay-code
      full-grp.other-code = ub.cash-pay.curr-code
      .
      FIND FIRST ub.currency No-LOCK WHERE
                ub.currency.curr-code = ub.cash-pay.curr-code no-error.
      full-grp.full-name = substitute("&1_Валюта_&2"
                                      , ub.cash-pay.obj-name
                                      ,(if available ub.currency
                                        then ub.currency.curr-abbr
                                        else string(ub.cash-pay.curr-code))).
    end.
  end.
END CASE.