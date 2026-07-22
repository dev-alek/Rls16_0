/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Показ номеров платежных карт

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/12/03
Author: Bakhtadze Natalya
Creation date: 08/12/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable paycardv as character no-undo .



FUNCTION f-paycardv RETURNS CHARACTER(input p-pay-card as character, p-cash-pay-obj-code as integer, p-cash-pay-curr-code as integer):
define variable kk as integer no-undo .
define variable pay-card-num as character no-undo .
define buffer buf_cash-pay for ub.cash-pay.

find first buf_cash-pay no-lock where
           buf_cash-pay.cdpay-code = p-cash-pay-obj-code
       AND buf_cash-pay.curr-code = p-cash-pay-curr-code no-error .
if not avail buf_cash-pay then return "":U.
if p-pay-card = "":u
or p-pay-card = ? then return "":U.
assign
pay-card-num = "":U
.
_kk:
do kk = 1 to num-entries(buf_cash-pay.pay-card-view):
  if p-pay-card begins entry(kk, buf_cash-pay.pay-card-view) then do:
    assign
    pay-card-num = p-pay-card
    .
    return pay-card-num.
  end.
end.
if pay-card-num = "":u then do:
  if length(p-pay-card) > 4 then
  assign
  pay-card-num = fill("*":U, length(p-pay-card) - 4) +
                  substr(p-pay-card, (length(p-pay-card) - 3), 4)
  .
  else
  return fill("*":U, length(p-pay-card)).
end.
return pay-card-num.

END FUNCTION.
/* $Workfile$ e n d */