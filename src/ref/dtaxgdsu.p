block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dtaxgdsu.p $
$Archive: ref/dtaxgdsu.p $

Заполнение таблицы tax-rate-gds по полям временной таблицы tt-tax

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

DEFINE INPUT PARAMETER to-del as logical no-undo.
define input parameter parhost-code like ub.sysconf.host-code no-undo .
define input parameter parobj-type like ub.clients.obj-type no-undo .
define input parameter parobj-code like ub.clients.obj-code no-undo .
define input parameter par-rec as recid no-undo.
define input parameter par-copy-gds-code like ub.goods.gds-code no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dtaxgdsu.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dtaxgdsu.p $":U .
define variable vss-description as character no-undo init "Заполнение таблицы tax-rate-gds по полям временной таблицы tt-tax".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ str/tt-tax.i SHARED tt-tax full }
{ trg/factord.i }

DEFINE VARIABLE v-fact-order like ub.tax-rate-gds.fact-order no-undo .
define variable v-fact-date as date no-undo .
define buffer b_tax-rate-gds for ub.tax-rate-gds.
define buffer copy_tax-rate-gds for ub.tax-rate-gds.
define buffer copy_goods for ub.goods.
define buffer buf_tax-rate for ub.tax-rate.
define buffer buf_tax for ub.tax.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

find first ub.goods share-lock where
           recid(ub.goods) = par-rec no-error.

if not avail ub.goods then do:
  message
  vss-workfile vss-revision vss-description skip
  "Не найден товар - recid" par-rec
  view-as alert-box error .
  return error .
end.


_tt-tax:
FOR EACH tt-tax:
  find first buf_tax-rate no-lock where
            buf_tax-rate.tax-code = tt-tax.tax-code
        and buf_tax-rate.rate-code = tt-tax.rate-code  no-error.
  if not available buf_tax-rate then do:
    find first buf_tax no-lock where
              buf_tax.tax-code = tt-tax.tax-code no-error.
    if not available buf_tax then do:
      undo main-block, return error substitute("Неизвестный налог с кодом &1", tt-tax.tax-code).
    end.
    else do:
      if buf_tax.individual = yes then next.
    end.
    undo main-block, return error substitute("Отсутствует ставка налога &1 с кодом &2", tt-tax.tax-code, tt-tax.rate-code).
  end.
  assign
  v-fact-date = tt-tax.fact-date
  .
  run factord-end-day in this-procedure (input v-fact-date , output v-fact-order).
  if NOT tt-tax.tax-rate-gds-rc = ? then do:
    FIND  FIRST ub.tax-rate-gds where
                recid(ub.tax-rate-gds) = tt-tax.tax-rate-gds-rc NO-ERROR.
    find LAST b_tax-rate-gds where
              b_tax-rate-gds.gds-code = tax-rate-gds.gds-code AND
              b_tax-rate-gds.tax-code = tax-rate-gds.tax-code AND
              b_tax-rate-gds.host-code = tax-rate-gds.host-code AND
              b_tax-rate-gds.obj-type = tax-rate-gds.obj-type AND
              b_tax-rate-gds.obj-code = tax-rate-gds.obj-code AND
              b_tax-rate-gds.fact-order <= v-fact-order no-error.
    if avail b_tax-rate-gds and b_tax-rate-gds.rate-code = tt-tax.rate-code then NEXT _tt-tax.
    if not avail b_tax-rate-gds or b_tax-rate-gds.fact-order < v-fact-order then do:
      create b_tax-rate-gds.
      buffer-copy tax-rate-gds except rate-code to b_tax-rate-gds
      assign
      b_tax-rate-gds.rate-code = tt-tax.rate-code
      b_tax-rate-gds.fact-order = v-fact-order
      b_tax-rate-gds.fact-date = v-fact-date
      /*
      freeze
      tax-rate-gds.host-code = parhost-code
      tax-rate-gds.obj-type = parobj-type
      tax-rate-gds.obj-code = parobj-code
      */
      .
    end. /*not avail bb_tax-rate-gds*/
    else do:
      if b_tax-rate-gds.rate-code <> tt-tax.rate-code then
      assign
      b_tax-rate-gds.rate-code = tt-tax.rate-code
      .
    end.
  end.
  /*новый товар*/
  if (not avail ub.tax-rate-gds or tt-tax.tax-rate-gds-rc = ?) and
      not tt-tax.individual then do:
      find First b_tax-rate-gds where
                b_tax-rate-gds.gds-code = goods.gds-code AND
                b_tax-rate-gds.tax-code = tt-tax.tax-code AND
                b_tax-rate-gds.host-code = 0 AND
                b_tax-rate-gds.obj-type = "":U AND
                b_tax-rate-gds.obj-code = 0 AND
                b_tax-rate-gds.fact-order <= v-fact-order no-error.
    if not avail b_tax-rate-gds then do:
      assign
      v-fact-date = 01/01/1990
      .
      run factord-end-day in this-procedure (input v-fact-date , output v-fact-order).
    end.
    if not avail b_tax-rate-gds
    or v-fact-order <> b_tax-rate-gds.fact-order  then do:
      create tax-rate-gds.
      assign
      tax-rate-gds.tax-code = tt-tax.tax-code
      tax-rate-gds.rate-code = tt-tax.rate-code
      tax-rate-gds.gds-code = goods.gds-code
      tax-rate-gds.fact-order = v-fact-order
      tax-rate-gds.fact-date = v-fact-date
      /*
      freeze
      tax-rate-gds.host-code = parhost-code
      tax-rate-gds.obj-type = parobj-type
      tax-rate-gds.obj-code = parobj-code
      */
      .
    end.
  end.
  if to-del then
  delete tt-tax.
END.
/*допишем историю а то все без нее страдают несчастные*/
if par-copy-gds-code <> 0 then do:
  find first copy_goods no-lock where
            copy_goods.gds-code = par-copy-gds-code no-error .
  if not avail copy_goods then do:
    message
    "Не найден товар с кодом " par-copy-gds-code
    "-оригинал для копирования" skip
    view-as alert-box error .
    undo, return error.
  end.
  for each copy_tax-rate-gds no-lock where
           copy_tax-rate-gds.gds-code = copy_goods.gds-code and
           copy_tax-rate-gds.fact-order < v-fact-order:
     find first ub.tax-rate-gds No-LOCK where
                ub.tax-rate-gds.gds-code = ub.goods.gds-code
            ANd ub.tax-rate-gds.tax-code = copy_tax-rate-gds.tax-code
            ANd ub.tax-rate-gds.host-code = copy_tax-rate-gds.host-code
            ANd ub.tax-rate-gds.obj-type = copy_tax-rate-gds.obj-type
            ANd ub.tax-rate-gds.obj-code = copy_tax-rate-gds.obj-code
            ANd ub.tax-rate-gds.fact-order = copy_tax-rate-gds.fact-order no-error .
    if not avail ub.tax-rate-gds then do:
      create ub.tax-rate-gds.
      buffer-copy copy_tax-rate-gds except gds-code to ub.tax-rate-gds
      assign
      ub.tax-rate-gds.gds-code = ub.goods.gds-code
      .
      release ub.tax-rate-gds no-error.
      if error-status:error then do:
        message
        "Не удалось создать копию истории по ставкам налогов для товара с кодом" goods.gds-code
        view-as alert-box error .
        undo, return error.
      end.
    end. /*if not avail tax-rate-gds then do:*/
  end. /*for each copy_tax-rate-gds no-lock where*/
end. /*if par-copy-gds-code <> 0 then do:*/

end. /*doe*/