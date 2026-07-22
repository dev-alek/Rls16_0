block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wth-lnv1.p $
$Archive: str/wth-lnv1.p $

Сохранение изменений в строке документа МЦ инвентаризаци

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

DEFINE TEMP-TABLE tt-par-dtl NO-UNDO LIKE ub.wth-par
{ str/ttpardt0.i inv }
.

define input-output parameter par-rid as recid no-undo .
define input parameter par-mode    as character no-undo .
define input parameter pardoc-code like ub.wth-line.doc-code no-undo .
define input parameter parwth-code like ub.wth-line.wth-code no-undo .
define input parameter parw-p-code like ub.wth-line.w-p-code no-undo .
define input parameter parbef-sum  like ub.wth-line.BEF-sum no-undo .
define input parameter paraft-sum  like ub.wth-line.AFT-sum no-undo .
define input parameter table for tt-par-dtl.
define input parameter parline-exist as logical no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wth-lnv1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/wth-lnv1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в строке документа МЦ инвентаризации".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ str/wth-lib.i  }

define variable var-entry         as character no-undo .
define variable loc#log           as logical   no-undo .
define variable vardtl-rec        as recid     no-undo .
define variable varis-dtl         as logical   no-undo .
define variable vardtl-bef-sum    as decimal   no-undo .
define variable vardtl-aft-sum    as decimal   no-undo .
define variable varline-bef-sum   as decimal   no-undo .
define variable varline-aft-sum   as decimal   no-undo .
define variable v-today           as date      no-undo .
define variable v-time            as integer   no-undo .
define variable varbef-sum        as decimal   no-undo .
define variable vdoc-bef-sum      as decimal   no-undo .
define variable v-added           as logical   no-undo .
define variable calc-line-bef-sum as decimal   no-undo .

define buffer buf_wth-doc  for ub.wth-doc .
define buffer buf_wth-line for ub.wth-line .
define buffer inv_wth-doc  for ub.wth-doc.

if not (par-mode = {&add-def}
        or par-mode = {&update}
        or par-mode = {&deletion}
       )
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова par-mode" par-mode
    view-as alert-box ERROR.
  return error '':U.
end.

find first buf_wth-doc exclusive-lock
  where buf_wth-doc.doc-code = pardoc-code
  no-error
  no-wait.
if locked buf_wth-doc
then do:
  message vss-workfile vss-revision vss-description skip
          "Запись документа МЦ" pardoc-code "занята"
          "добавление/изменение строки невозможно"
  view-as alert-box error .
  return error substitute("Запись документа МЦ &1 занята", pardoc-code ).
end.
if not available buf_wth-doc
then do:
  message vss-workfile vss-revision vss-description skip
          "Не найден документ МЦ" pardoc-code
  view-as alert-box error .
  return error substitute("Не найден документ МЦ &1", pardoc-code ).
end.

if buf_wth-doc.status_ = {&fact}
then do:
  message
  vss-workfile vss-revision vss-description skip
  "Документ МЦ имеет статус" buf_wth-doc.status_
  "добавление/изменение строки невозможно"
  view-as alert-box ERROR.
  return error '':U.
end.
if  buf_wth-doc.status_ = {&permitted}
and par-mode = {&add-def}
then do:
  message
  vss-workfile vss-revision vss-description skip
  "Документ МЦ имеет статус" buf_wth-doc.status_
  "добавление строки невозможно"
  view-as alert-box ERROR.
  return error '':U.
end.
assign
varbef-sum = parbef-sum.

if buf_wth-doc.auto-fill
or parbef-sum = ?
then do:
  run wth-lib_cur-stock-place in this-procedure (
                                                    input  buf_wth-doc.obj-type
                                                  ,input  buf_wth-doc.obj-code
                                                  ,input  parw-p-code
                                                  ,input parwth-code
                                                  ,output calc-line-bef-sum
                                                  ) no-error.
  if error-status:error
  then do:
    return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
end.

if par-mode = {&add-def}
then do:
  par-rid = ?.
  if  parline-exist = yes
  then do:
    FIND FIRST ub.wth-line No-LOCK WHERE
              ub.wth-line.doc-code = pardoc-code AND
              ub.wth-line.wth-code = parwth-code AND
              ub.wth-line.w-p-code = parw-p-code No-ERROR.
    if available ub.wth-line
    then do:
      par-rid = recid(ub.wth-line).
      assign
      v-added = yes
      varbef-sum = (if parbef-sum = ?
                    then calc-line-bef-sum
                    else (varbef-sum + ub.wth-line.bef-sum))
      paraft-sum = paraft-sum + ub.wth-line.aft-sum
      .
    end.
    else do:
      if parbef-sum = ?
      then do:
        assign
        varbef-sum = calc-line-bef-sum.
      end.
    end.
  end.
end.


run trg/wth-lnv2.p (
                input pardoc-code,
                input buf_wth-doc.host-code,
                input buf_wth-doc.obj-type,
                input buf_wth-doc.obj-code,
                input buf_wth-doc.cli-type,
                input buf_wth-doc.cli-code,
                input buf_wth-doc.auto-fill,
                input buf_wth-doc.borned,
                input par-rid,
                input parwth-code,
                input parw-p-code ) no-error.
if error-status:error then return error return-value.

find first buf_wth-line no-lock
  where buf_wth-line.obj-type    = buf_wth-doc.obj-type
    and buf_wth-line.obj-code    = buf_wth-doc.obj-code
    and buf_wth-line.w-p-code    = parw-p-code
    and buf_wth-line.shift-date  = buf_wth-doc.shift-date
    and buf_wth-line.shift-num   = buf_wth-doc.shift-num
    and buf_wth-line.wth-code    = parwth-code
    and buf_wth-line.status_    <> {&fact}
    and recid( buf_wth-line )   <>  par-rid
  no-error .
if available buf_wth-line
then do:
  find first inv_wth-doc no-lock
    where inv_wth-doc.doc-code = buf_wth-line.doc-code
    no-error .
  if inv_wth-doc.doc-type = {&inventory}
  then do:
    message
      "Материальная ценность" parwth-code "есть в незакрытой инвентаризации"
      buf_wth-line.doc-code "по м/х" parw-p-code "!" Skip
      "Невозможно добавить в документ!"
      view-as alert-box error.
      assign
        var-entry = "wth-code":u
      .
      return error var-entry.
  end.
  else do:
    message
      "Материальная ценность" parwth-code "есть в незакрытом документе"
      buf_wth-line.doc-code "по м/х" parw-p-code "!" Skip
      "Невозможно добавить в документ!"
      view-as alert-box error.
      assign
        var-entry = "wth-code":U
      .
      return error var-entry.
  End.
END.

do
on error undo, return '':u
on stop undo, return '':u
:

  if par-mode = {&add-def} and par-rid = ?
  then do:
    run cur-time in this-procedure(output v-today, output v-time).
    { trg/wth-licr.i wth-line buf_wth-doc doc parw-p-code " " v-today }
    assign par-rid = recid(ub.wth-line).
  end.
  else do:
    FIND FIRST ub.wth-line EXCLUSIVE-LOCK WHERE
              recid(ub.wth-line) = par-rid No-WAIT No-ERROR.
    if locked ub.wth-line
    then do:
      message "Строка документа МЦ занят"
      view-as alert-box error .
      return error '':U.
    end.
    if not avail ub.wth-line
    then do:
      message "Не найдена строка документа МЦ"
      view-as alert-box error .
      return error '':U.
    end.
    if  buf_wth-doc.status_ = {&permitted}
    and (ub.wth-line.doc-code <> pardoc-code
         or ub.wth-line.wth-code <> parwth-code
         or ub.wth-line.w-p-code <> parw-p-code
         or ub.wth-line.bef-sum <> parbef-sum
        )
    then dO:
      message
      vss-workfile vss-revision vss-description skip
      "Документ МЦ имеет статус" buf_wth-doc.status_
      "возможно изменить только сумму факт"
      view-as alert-box ERROR.
      return error '':U.
    end.
  end.

  if buf_wth-doc.auto-fill
  or parbef-sum = ?
  then do:
  end.
  else do:
    calc-line-bef-sum = if par-mode = {&deletion}
                        then 0
                        else varbef-sum.
  end.
  assign
    ub.wth-line.doc-code = pardoc-code
    ub.wth-line.wth-code = parwth-code
    ub.wth-line.w-p-code = parw-p-code
  .
  if parbef-sum = ?
  then do:
    for each buf_wth-line no-lock where
            buf_wth-line.doc-code = buf_wth-doc.doc-code:
      if recid(buf_wth-line) = recid(ub.wth-line) then next.
      assign
      vdoc-bef-sum = vdoc-bef-sum + buf_wth-line.bef-sum.
    end.
    assign
    vdoc-bef-sum = vdoc-bef-sum + varbef-sum
    buf_wth-doc.bef-sum = vdoc-bef-sum
    .
  end.
  else do:
    assign
    buf_wth-doc.bef-sum = buf_wth-doc.bef-sum - ub.wth-line.bef-sum + calc-line-bef-sum
    .
  end.
  assign
  ub.wth-line.bef-sum = parbef-sum
  buf_wth-doc.aft-sum = buf_wth-doc.aft-sum - ub.wth-line.aft-sum + paraft-sum
  ub.wth-line.aft-sum = paraft-sum
  .
  assign
  varline-bef-sum = ub.wth-line.bef-sum
  varline-aft-sum = ub.wth-line.aft-sum
  .
  if par-mode = {&add-def}
  then do:
    release ub.wth-line no-error.
    if error-status:error
    then do:
      return error '':U.
    end.
  end.
  for each tt-par-dtl:
    varis-dtl = yes.
    run str/wth-dtl1.p (output vardtl-rec,
                  input par-mode,
                  input pardoc-code,
                  input parwth-code,
                  input parw-p-code,
                  input tt-par-dtl.par-code,
                  input tt-par-dtl.sum-BEF,
                  input tt-par-dtl.sum-aft,
                  input 0,
                  input 0,
                  input parline-exist
                  ) no-error.

    if error-status:error or vardtl-rec = ?
    then do:
      assign
        var-entry = "b-par":U
      .
      return error var-entry.
    end.
    assign
    vardtl-bef-sum = vardtl-bef-sum + tt-par-dtl.sum-bef
    vardtl-aft-sum = vardtl-aft-sum + tt-par-dtl.sum-aft
    .
  END.
  if varis-dtl
  then do:
    /*заходили в форму номиналов*/
    case buf_wth-doc.status_ :
      when {&wayb}
      then do:
        if varline-bef-sum <> vardtl-bef-sum
        and NOT (vardtl-bef-sum  = 0 and
                 not can-find(first ub.wth-dtl No-LOCK WHERE
                                    ub.wth-dtl.doc-code = pardoc-code AND
                                    ub.wth-dtl.wth-code = parwth-code AND
                                    ub.wth-dtl.w-p-code = parw-p-code)
                )
        then do:
          message "Сумма по номиналам не совпадает с суммой движения материального средства!"
          view-as alert-box error .
          var-entry = "wth-dtl":U.
          return error var-entry.
        end.
      end.
      when {&permitted}
      then do:
        if varline-aft-sum <> vardtl-aft-sum and
          NOT (vardtl-aft-sum  = 0 and
                not can-find(first ub.wth-dtl No-LOCK WHERE
                                    ub.wth-dtl.doc-code = pardoc-code AND
                                    ub.wth-dtl.wth-code = parwth-code AND
                                    ub.wth-dtl.w-p-code = parw-p-code)
                )
        then dO:
          message "Сумма по номиналам не совпадает с суммой движения материального средства!"
          view-as alert-box error .
          var-entry = "wth-dtl":U.
          return error var-entry.
        end.
      end.
    END CASE.
  end.
  else do:
    if can-find(first ub.wth-dtl No-LOCK WHERE
                      ub.wth-dtl.doc-code = pardoc-code AND
                      ub.wth-dtl.wth-code = parwth-code AND
                      ub.wth-dtl.w-p-code = parw-p-code)
    then do:
      FOR EACH ub.wth-dtl No-LOCK WHERE
                ub.wth-dtl.doc-code = ub.wth-line.doc-code AND
                ub.wth-dtl.wth-code = ub.wth-line.wth-code AND
                ub.wth-dtl.w-p-code = ub.wth-line.w-p-code:
        assign
        vardtl-bef-sum = vardtl-bef-sum + ub.wth-dtl.bef-sum
        vardtl-aft-sum = vardtl-aft-sum + ub.wth-dtl.aft-sum
        .
      END.
      if varline-bef-sum <> vardtl-bef-sum or
         varline-aft-sum <> vardtl-aft-sum
      then dO:
        message "Сумма по номиналам не совпадает с суммой движения материального средства!"
        view-as alert-box error .
        var-entry = "wth-dtl":U.
        return error var-entry.
      end.
    end. /*номиналы есть*/
  end. /*в форму номиналов не заходили*/
END.
return '':U.