block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: inc-wth1.p $
$Archive: str/inc-wth1.p $

Добавление/удаление чека МЦ в документ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

define parameter buffer loc-chk-doc for ub.chk-doc.
/*add or delete*/
define input parameter par-koeff as integer no-undo .
define input parameter pardoc-code like ub.wth-doc.doc-code no-undo .
define input parameter parcurrent-w-p-code like ub.wth-line.w-p-code no-undo .
define input parameter parout-w-p-code like ub.wth-line.out-code no-undo .
define input parameter parext-doc-type like ub.wth-doc.ext-doc-type no-undo .
define input parameter parchk-type like ub.chk-doc.chk-type no-undo .
define input parameter p-silent as logical no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: inc-wth1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/inc-wth1.p $":U .
define variable vss-description as character no-undo init "Добавление/удаление чека МЦ в документ".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }

define temp-table tt-par-dtl  no-undo like ub.wth-par
{ str/ttpardt0.i }
.

define temp-table tt-par-dtl-inv  no-undo like ub.wth-par
{ str/ttpardt0.i inv }
.

DEFINE VARIABLE varline-rec as recid no-undo .
define buffer buf_chk-pay for ub.chk-pay .
define buffer buf2_chk-pay for ub.chk-pay .
define buffer buf_c-chk-doc for ub.c-chk-doc .
define buffer buf_c-chk-pay for ub.c-chk-pay .
define buffer buf_wth-place for ub.wth-place.
define buffer buf_wealth for ub.wealth.
define buffer buf_cash-pay for ub.cash-pay .
define buffer bufdoc_wth-place for ub.wth-place.
define buffer buf_wth-par for ub.wth-par.
define buffer buf_inkas-pay-wth for ub.inkas-pay-wth.
DEFINE VARIABLE varkoef as integer no-undo .
DEFINE VARIABLE var-sum like ub.chk-pay.tot-sum no-undo .
def var cur-wth like    ub.wealth.wth-code no-undo.

if NOT ABS(par-koeff) = 1 then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр вызова par-koeff" par-koeff
  view-as alert-box error .
  return error.
end.

FIND FIRST buf_wth-place No-LOCK WHERE
          buf_wth-place.obj-type = loc-chk-doc.obj-type AND
          buf_wth-place.obj-code = loc-chk-doc.obj-code AND
          buf_wth-place.cash-desk = loc-chk-doc.pay-desk NO-ERROR.
if not available buf_wth-place then do:
  message
  "Не определено МХ МЦ для кассы N" loc-chk-doc.pay-desk SKIP
  "объект" loc-chk-doc.obj-type loc-chk-doc.obj-code
  view-as alert-box error .
  return error .
end.

if parcurrent-w-p-code <> 0 and par-koeff = 1 then do:
  FIND FIRST bufdoc_wth-place No-LOCK WHERE
            bufdoc_wth-place.obj-type = loc-chk-doc.obj-type AND
            bufdoc_wth-place.obj-code = loc-chk-doc.obj-code AND
            bufdoc_wth-place.w-p-code = parcurrent-w-p-code No-ERROR.
  if not available bufdoc_wth-place or bufdoc_wth-place.cash-desk = 0 then dO:
    message
    "Не определено МХ МЦ в документе" pardoc-code " определено неверно" SKIP
    "объект" loc-chk-doc.obj-type loc-chk-doc.obj-code
    view-as alert-box error .
    return error .
  end.

  if buf_wth-place.w-p-code <> parcurrent-w-p-code then do:
    message
    "Документ МЦ" pardoc-code "сформирован для чеков кассы N" bufdoc_wth-place.cash-desk
    "а чек " loc-chk-doc.doc-code "пробит на кассе" loc-chk-doc.pay-desk SKIP
    "объект" loc-chk-doc.obj-type loc-chk-doc.obj-code
    view-as alert-box error .
    return error .

  end.
end.

main-block:
do
on error undo, return error
:
_chk-pay:
FOR EACH buf_chk-pay where
          buf_chk-pay.doc-code = loc-chk-doc.doc-code
BREAK
By buf_chk-pay.pay-code
BY buf_chk-pay.curr-code
ON ERROR UNDO _chk-pay, return error
          :
  if first-of(buf_chk-pay.curr-code)or first-of(buf_chk-pay.pay-code) then do:
    FIND FIRST buf_cash-pay No-LOCK where
                buf_cash-pay.cdpay-code = buf_chk-pay.pay-code AND
                buf_cash-pay.curr-code = buf_chk-pay.curr-code No-ERROR.
    IF NOT AVAILABLE buf_cash-pay then do:
      message
      "Не найден тип кассового платежа" skip
      "код платежа" buf_chk-pay.pay-code
      "код валюты" buf_chk-pay.curr-code
      view-as alert-box error .
      undo main-block, return error.
    end.


    FIND FIRST buf_wealth No-LOCK WHERE
                buf_wealth.wth-code = buf_cash-pay.wth-code No-ERROR.
    if NOT AVAILABLE buf_wealth then do:
      if buf_cash-pay.wth-code = 0 and
        buf_cash-pay.is-cash = no AND
        string(loc-chk-doc.chk-type) = {&pay-transfer} then do:
      error-status:error = no.
      end.
      else do:
        undo _chk-pay, return error substitute("Не найдена МЦ с кодом &1&2Чек МЦ &3"
                                                , buf_cash-pay.wth-code
                                                ,{&new-line}
                                                , loc-chk-doc.doc-code).
      end.
    end.
    assign
    var-sum = 0
    cur-wth = buf_wealth.wth-code.
    for each buf2_chk-pay no-lock where
            buf2_chk-pay.doc-code = loc-chk-doc.doc-code
         and buf2_chk-pay.pay-code = buf_chk-pay.pay-code
         and buf2_chk-pay.curr-code = buf_chk-pay.curr-code
         and buf2_chk-pay.par-code > 0
     ON ERROR UNDO _chk-pay, return error:
      find first buf_wth-par no-lock where
                buf_wth-par.wth-code = buf2_chk-pay.wth-code
            and buf_wth-par.par-code = buf2_chk-pay.par-code no-error.
      if not available buf_wth-par then do:
        undo _chk-pay, return error substitute("Не найден номинал МЦ &1 для МЦ &2&2Чек МЦ &4"
                                                , buf2_chk-pay.wth-code
                                                , buf2_chk-pay.par-code
                                                ,{&new-line}
                                                , loc-chk-doc.doc-code).
      end.
      find first tt-par-dtl where tt-par-dtl.par-code = buf2_chk-pay.par-code no-error.
      if not available tt-par-dtl then do:
        create tt-par-dtl.
        assign
        tt-par-dtl.wth-code = buf2_chk-pay.wth-code
        tt-par-dtl.doc-sum  = buf2_chk-pay.tot-sum
        tt-par-dtl.fact-sum  = 0.0
        tt-par-dtl.q-ty-doc  = buf2_chk-pay.doc-qnty
        tt-par-dtl.q-ty-fact  = 0.0
        tt-par-dtl.par-code = buf2_chk-pay.par-code
        tt-par-dtl.par-rate = buf_wth-par.par-rate
        tt-par-dtl.par-feat = buf_wth-par.par-feat
        tt-par-dtl.par-unit = buf_wth-par.par-unit
        tt-par-dtl.par-val = buf2_chk-pay.par-val
        .
      end.
      else do:
        assign
        tt-par-dtl.doc-sum  = tt-par-dtl.doc-sum  + buf2_chk-pay.tot-sum
        tt-par-dtl.q-ty-doc  = tt-par-dtl.q-ty-doc + buf2_chk-pay.doc-qnty
        .
      end.
      release tt-par-dtl.
    end. /* for each buf2_chk-pay no-lock where*/
      if loc-chk-doc.chk-type <> integer({&cd-drawer}) then do:
        find first buf_inkas-pay-wth where
                  buf_inkas-pay-wth.inkas-code = pardoc-code
              and buf_inkas-pay-wth.pay-code = buf_chk-pay.pay-code
              and buf_inkas-pay-wth.curr-code = buf_chk-pay.curr-code
              and buf_inkas-pay-wth.wth-code = buf_chk-pay.wth-code
              and buf_inkas-pay-wth.par-code = buf_chk-pay.par-code
              and buf_inkas-pay-wth.pay-desk = loc-chk-doc.pay-desk
              and buf_inkas-pay-wth.cashier = loc-chk-doc.cashier
              and buf_inkas-pay-wth.chk-type = loc-chk-doc.chk-type no-error.
        if not available  buf_inkas-pay-wth then do:
          create buf_inkas-pay-wth.
          assign
          buf_inkas-pay-wth.inkas-code = pardoc-code
          buf_inkas-pay-wth.pay-code = buf_chk-pay.pay-code
          buf_inkas-pay-wth.curr-code = buf_chk-pay.curr-code
          buf_inkas-pay-wth.wth-code = buf_chk-pay.wth-code
          buf_inkas-pay-wth.par-code = buf_chk-pay.par-code
          buf_inkas-pay-wth.pay-desk = loc-chk-doc.pay-desk
          buf_inkas-pay-wth.cashier = loc-chk-doc.cashier
          buf_inkas-pay-wth.chk-type = loc-chk-doc.chk-type
          buf_inkas-pay-wth.par-val = buf_chk-pay.par-val
          .
        end.
        assign
        buf_inkas-pay-wth.tot-sum = buf_inkas-pay-wth.tot-sum + buf_chk-pay.tot-sum
        buf_inkas-pay-wth.tot-base = buf_inkas-pay-wth.tot-base + buf_chk-pay.tot-base
        buf_inkas-pay-wth.tot-rubl = buf_inkas-pay-wth.tot-rubl + buf_chk-pay.tot-rubl
        buf_inkas-pay-wth.doc-qnty = buf_inkas-pay-wth.doc-qnty + buf_chk-pay.doc-qnty
        buf_inkas-pay-wth.tot-lines = buf_inkas-pay-wth.tot-lines + 1
        .
      end.


  end.
  assign
  var-sum = var-sum + buf_chk-pay.tot-sum
  .


  if last-of(buf_chk-pay.curr-code) and var-sum <> 0 then do:
    if parext-doc-type = {&WDEDT_Inv} then do:    /*инвентаризация*/
      if string(parchk-type) = {&pay-transfer} then dO:
        if buf_cash-pay.wth-code = 0 and
          buf_cash-pay.is-cash = no AND
          string(loc-chk-doc.chk-type) = {&pay-transfer} then do:
        end.
        else do:
          run str/wth-lni1.p (
                        input-output varline-rec
                        ,input  {&add-def}
                        ,input  pardoc-code
                        ,input  cur-wth
                        ,input  buf_wth-place.w-p-code
                        ,input  par-koeff * buf_chk-pay.tot-sum
                        ,input  yes /*par-log*/
                        ) no-error .
        end.
      END.
      else do:
        run str/wth-lnv1.p (
                       input-output varline-rec
                      ,input  {&add-def}
                      ,input  pardoc-code
                      ,input  cur-wth
                      ,input  buf_wth-place.w-p-code
                      ,input  ? /*bef-sum*/
                      ,input  par-koeff * buf_chk-pay.tot-sum
                      ,input  table tt-par-dtl-inv
                      ,input  yes /*par-log*/
                      ) no-error .
      end.
    end.
    else do:

      run str/wth-lnc1.p (
                     input-output varline-rec
                    ,input  {&add-def}
                    ,input p-silent
                    ,input pardoc-code
                    ,input cur-wth
                    ,input buf_wth-place.w-p-code
                    ,input parout-w-p-code
                    ,input par-koeff * abs(var-sum)
                    ,input (if loc-chk-doc.chk-type = integer({&cd-drawer})
                            then 0.0
                            else par-koeff * abs(var-sum))
                    ,input table tt-par-dtl
                    ,input yes /*par-log*/
                    ,input parext-doc-type
                    ,input 0
                    ,input 0
                    ) no-error .

    end.
    if error-status:error then do:
      define variable v-mess as character no-undo .
      v-mess = substitute("Не удалось создать (изменить, удалить) строку автоматического документа МЦ&1"  +
                          "код МЦ &2&1"  +
                          "МХ &3&1" +
                          "МХ назначения &4&1&5&1&6"
                          , {&new-line}
                          , cur-wth
                          , buf_wth-place.w-p-code
                          , parout-w-p-code
                          , error-status:get-message(1)
                          , return-value).
      if not p-silent then do:
        message
        v-mess
        view-as alert-box error .
      end.
      undo _chk-pay, return error (if p-silent then v-mess else '').
    end.
  end. /*if last-of(buf_chk-pay.curr-code) and var-sum <> 0 then do:*/
  assign
  buf_chk-pay.out-code = (if par-koeff = 1 then pardoc-code else '':U)
  .


END. /*FOR EACH buf_chk-pay*/
for each buf_c-chk-doc where
        buf_c-chk-doc.doc-code = loc-chk-doc.doc-code  :
    assign
    buf_c-chk-doc.out-code = (if par-koeff = 1 then pardoc-code else '':U)
    .
end.
for each buf_c-chk-pay where
        buf_c-chk-pay.doc-code = loc-chk-doc.doc-code     :
    assign
    buf_c-chk-pay.out-code = (if par-koeff = 1 then pardoc-code else '':U)
    .
end.
assign
loc-chk-doc.out-code = (if par-koeff = 1 then pardoc-code else '':U).

end. /*doe*/