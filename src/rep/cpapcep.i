/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица для хранения префиксов платежных карт для экспорта в XML

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/25/05
Author: Bakhtadze Natalya
Creation date: 05/25/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if not "{1}" = "proc" &then

define {1} temp-table temp-cpa-pcep no-undo
field cdpay-code like ub.cash-pay.cdpay-code
field curr-code like ub.cash-pay.cdpay-code
/*
field host-code like ub.sysconf.host-code
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
*/
field prefix as character
index pi is primary
cdpay-code
curr-code
/*
host-code
obj-type
obj-code
*/
.

&endif

&if "{1}" = "proc" &then
procedure cpapcep:

define variable ii as integer no-undo .
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_cash-pay-attr for ub.cash-pay-attr.
define buffer buf_temp-cpa-pcep for temp-cpa-pcep.

  do
  on error undo, return error
  :
     for each buf_cash-pay-attr no-lock where
            buf_Cash-pay-attr.attr-code = {&cp-attr-paycard-export-prefix}:
       do ii = 1 to num-entries(buf_Cash-pay-attr.attr-value):
        create buf_temp-cpa-pcep.
        assign
        buf_temp-cpa-pcep.cdpay-code = buf_cash-pay-attr.cdpay-code
        buf_temp-cpa-pcep.curr-code = buf_cash-pay-attr.curr-code
        /*
        buf_temp-cpa-pcep.host-code = p-host-code
        buf_temp-cpa-pcep.obj-type = p-obj-type
        buf_temp-cpa-pcep.obj-code = p-obj-code
        */
        buf_temp-cpa-pcep.prefix = entry(ii, buf_Cash-pay-attr.attr-value)
        .
      end.
    end.
  end.

end procedure. /* cpapcep */
&endif


/* $Workfile$ e n d */
