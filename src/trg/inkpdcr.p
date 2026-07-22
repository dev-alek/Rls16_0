block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание inkas-pay-desk для старых продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/20/05
Author: Bakhtadze Natalya
Creation date: 10/20/05

*/

define input parameter parinkas-code like ub.inkas.inkas-code no-undo .
define input parameter parobj-type like ub.inkas.obj-type no-undo .
define input parameter parobj-code like ub.inkas.obj-code no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создание inkas-pay-desk для старых продаж".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }

DEFINE VARIABLE var-doc-type as character no-undo .
DEFINE VARIABLE v-exist-all-chk as integer no-undo .
define temp-table tt-inkas-pay-desk no-undo like ub.inkas-pay-desk.



for each tt-inkas-pay-desk:
  delete tt-inkas-pay-desk.
end.

_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ):

  find first ub.inkas no-lock where
             ub.inkas.inkas-code = parinkas-code.
  _chk-doc:
  for each ub.chk-doc No-LOCK WHERE
            ub.chk-doc.obj-type = parobj-type and
            ub.chk-doc.obj-code = parobj-code AND
            ub.chk-doc.out-code = parinkas-code:
      v-exist-all-chk = v-exist-all-chk + 1 .
      FOR  each ub.chk-pay no-lock where
            ub.chk-pay.doc-code = ub.chk-doc.doc-code
      break by
      ub.chk-pay.doc-code:
      if lookup(string(ub.chk-doc.chk-type), {&no-docum-receipt-codes}) > 0
      or lookup(string(ub.chk-doc.chk-type), {&petrol-receipt-codes}) > 0
      then DO:

        next _chk-doc.
      END.
      assign
      var-doc-type =  (if ub.chk-doc.netto >= 0
                      then  {&income}
                      else {&expense})
      .
      FIND FIRST tt-inkas-pay-desk WHERE
                  tt-inkas-pay-desk.pay-code = ub.chk-pay.pay-code AND
                  tt-inkas-pay-desk.curr-code = ub.chk-pay.curr-code AND
                  tt-inkas-pay-desk.pay-desk = ub.chk-doc.pay-desk AND
                  tt-inkas-pay-desk.doc-type = var-doc-type AND
                  tt-inkas-pay-desk.cashier = ub.chk-doc.cashier NO-ERROR.
      if NOT available tt-inkas-pay-desk then do:
        CREATE tt-inkas-pay-desk.
        assign
        tt-inkas-pay-desk.pay-code = ub.chk-pay.pay-code
        tt-inkas-pay-desk.curr-code = ub.chk-pay.curr-code
        tt-inkas-pay-desk.pay-desk = ub.chk-doc.pay-desk
        tt-inkas-pay-desk.tot-sum = 0
        tt-inkas-pay-desk.tot-base = 0
        tt-inkas-pay-desk.tot-rubl = 0
        tt-inkas-pay-desk.doc-type = var-doc-type
        tt-inkas-pay-desk.cashier = ub.chk-doc.cashier
        .
      end.
      assign
      tt-inkas-pay-desk.tot-sum = tt-inkas-pay-desk.tot-sum + ub.chk-pay.tot-sum
      tt-inkas-pay-desk.tot-base = tt-inkas-pay-desk.tot-base + ub.chk-pay.tot-base
      tt-inkas-pay-desk.tot-rubl = tt-inkas-pay-desk.tot-rubl + ub.chk-pay.tot-rubl
      .
    end.
  END.
  if v-exist-all-chk < ub.inkas.num-chk then do:
    message
    vss-workfile vss-revision vss-description skip
    "Недостаточно информации для расчета выручки по кассам" skip
    "Возможно не передаются по новостям чеки" skip
    "или чеки были заархивированы" skip
    "Отчет о продаже" parinkas-code
    view-as alert-box error .
    return error.
  end.
  for each tt-inkas-pay-desK:
    create ub.inkas-pay-desk.
    buffer-copy tt-inkas-pay-desk to ub.inkas-pay-desk
    assign
    ub.inkas-pay-desk.inkas-code = parinkas-code
    .
    delete tt-inkas-pay-desk.
  END.
end.