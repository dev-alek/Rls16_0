block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wth-lni1.p $
$Archive: str/wth-lni1.p $

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

define input-output parameter par-rid as recid no-undo .
define input parameter par-mode    as character no-undo .
define input parameter pardoc-code like ub.wth-line.doc-code no-undo .
define input parameter parwth-code like ub.wth-line.wth-code no-undo .
define input parameter parw-p-code like ub.wth-line.w-p-code no-undo .
define input parameter parfact-sum  like ub.wth-line.BEF-sum no-undo .
define input parameter parline-exist as logical no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wth-lni1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/wth-lni1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в строке документа МЦ инвентаризации".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/showinf.i }
{ str/wth-lib.i }
{ gbl/cur-time.i }

DEFINE VARIABLE var-entry as character no-undo .
DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE calc-line-bef-sum as decimal no-undo .
DEFINE VARIABLE calc-line-aft-sum as decimal no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

define buffer buf_wth-doc for ub.wth-doc .
define buffer buf_wth-line for ub.wth-line .
define buffer inv_wth-doc for ub.wth-doc.
define buffer check_chk-doc for ub.chk-doc .

if NOT (par-mode = {&add-def} OR par-mode = {&update}) then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр вызова par-mode" par-mode
  view-as alert-box ERROR.
  return error '':U.
end.


FIND FIRST buf_wth-doc EXCLUSIVE-LOCK WHERE
           buf_wth-doc.doc-code = pardoc-code No-ERROR No-WAIT.
IF LOCKED buf_wth-doc then do:
  message vss-workfile vss-revision vss-description skip
          "Запись документа МЦ" pardoc-code "занята"
          "добавление/изменение строки невозможно"
  view-as alert-box error .
end.
IF NOT available buf_wth-doc then do:
  message vss-workfile vss-revision vss-description skip
          "Не найден документ МЦ" pardoc-code
  view-as alert-box error .
end.
if buf_wth-doc.status_ = {&fact} then do:
  message
  vss-workfile vss-revision vss-description skip
  "Документ МЦ имеет статус" buf_wth-doc.status_
 "добавление/изменение строки невозможно"
  view-as alert-box ERROR.
  return error '':U.
end.
if buf_wth-doc.status_ = {&permitted} and
par-mode = {&add-def} then dO:
  message
  vss-workfile vss-revision vss-description skip
  "Документ МЦ имеет статус" buf_wth-doc.status_
  "добавление строки невозможно"
  view-as alert-box ERROR.
  return error '':U.
end.

if par-mode = {&add-def} then do:
  par-rid = ?.
  if  parline-exist = yes then do:
    FIND FIRST ub.wth-line No-LOCK WHERE
              ub.wth-line.doc-code = pardoc-code AND
              ub.wth-line.wth-code = parwth-code AND
              ub.wth-line.w-p-code = parw-p-code No-ERROR.
    if available ub.wth-line then do:
      par-rid = recid(ub.wth-line).
      assign
      parfact-sum = parfact-sum + ub.wth-line.fact-sum
      .
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

FIND FIRST buf_wth-line NO-LOCK WHERE
          buf_wth-line.obj-type    = buf_wth-doc.obj-type   AND
          buf_wth-line.obj-code    = buf_wth-doc.obj-code   AND
          buf_wth-line.w-p-code    = parw-p-code   AND
          buf_wth-line.shift-date  = buf_wth-doc.shift-date AND
          buf_wth-line.shift-num   = buf_wth-doc.shift-num  AND
          buf_wth-line.wth-code    = parwth-code   AND
          buf_wth-line.status_    <> {&fact}           AND
          RECID( buf_wth-line )   <>  par-rid  NO-ERROR.
IF AVAIL buf_wth-line THEN DO:
  FIND FIRST inv_wth-doc NO-LOCK WHERE
              inv_wth-doc.doc-code = buf_wth-line.doc-code No-ERROR.
  IF inv_wth-doc.doc-type = {&inventory} THEN DO:
    FIND FIRST check_chk-doc No-LOCK WHERE
              check_chk-doc.out-code = inv_wth-doc.doc-code NO-ERROR.
    if avail check_chk-doc and string(check_chk-doc.chk-type) = {&pay-transfer} then.
    else do:
      MESSAGE
      "Материальная ценность" parwth-code "есть в незакрытой инвентаризации"
      buf_wth-line.doc-code "по м/х" parw-p-code "!" SKIP
      "Невозможно добавить в документ!"
      VIEW-AS ALERT-BOX ERROR.
      var-entry = "wth-code":U.
      RETURN ERROR var-entry.
    end.
  END.
END.

DO ON ERROR UNDO, return '':U
   On STOP UNDO, return '':U:

  if par-mode = {&add-def} and par-rid = ? then do:
    run cur-time in this-procedure(output v-today, output v-time).
    { trg/wth-licr.i wth-line buf_wth-doc doc parw-p-code " " v-today  }
    assign par-rid = recid(ub.wth-line).
  end.
  else do:
    FIND FIRST ub.wth-line EXCLUSIVE-LOCK WHERE
              recid(ub.wth-line) = par-rid No-WAIT No-ERROR.
    if locked ub.wth-line then do:
      message "Строка документа МЦ занят"
      view-as alert-box error .
      return error '':U.
    end.
    if not avail ub.wth-line then do:
      message "Не найдена строка документа МЦ"
      view-as alert-box error .
      return error '':U.
    end.
    if buf_wth-doc.status_ = {&permitted} and
      (ub.wth-line.doc-code <> pardoc-code OR
      ub.wth-line.wth-code <> parwth-code OR
      ub.wth-line.w-p-code <> parw-p-code OR
      ub.wth-line.fact-sum <> parfact-sum ) then dO:
      message
      vss-workfile vss-revision vss-description skip
      "Документ МЦ имеет статус" buf_wth-doc.status_
      "изменения невозможны"
      view-as alert-box ERROR.
      return error '':U.
    end.
  end.
  run wth-lib_cur-stock-place in this-procedure (
                                                  input  buf_wth-doc.obj-type
                                                 ,input  buf_wth-doc.obj-code
                                                 ,input  parw-p-code
                                                 ,input parwth-code
                                                 ,output calc-line-bef-sum
                                                 ) no-error.
  if error-status:error then
  return error return-value.
  assign
  ub.wth-line.doc-code = pardoc-code
  ub.wth-line.wth-code = parwth-code
  ub.wth-line.w-p-code = parw-p-code
  buf_wth-doc.bef-sum = buf_wth-doc.bef-sum - ub.wth-line.bef-sum + calc-line-bef-sum
  ub.wth-line.bef-sum = calc-line-bef-sum
  calc-line-aft-sum = calc-line-bef-sum + parfact-sum
  buf_wth-doc.aft-sum = buf_wth-doc.aft-sum - ub.wth-line.aft-sum + calc-line-aft-sum
  ub.wth-line.aft-sum = calc-line-aft-sum
  buf_wth-doc.fact-sum = buf_wth-doc.fact-sum - ub.wth-line.fact-sum + parfact-sum
  ub.wth-line.fact-sum = parfact-sum
  .
END.
return '':U.