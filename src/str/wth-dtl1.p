block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wth-dtl1.p $
$Archive: str/wth-dtl1.p $

Сохранение изменений в строке детализации документа МЦ

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

define output parameter par-rid as recid no-undo .
define input parameter par-mode    as character no-undo .
define input parameter pardoc-code like ub.wth-dtl.doc-code no-undo .
define input parameter parwth-code like ub.wth-dtl.wth-code no-undo .
define input parameter parw-p-code like ub.wth-dtl.w-p-code no-undo .
define input parameter parpar-code like ub.wth-dtl.par-code no-undo .
define input parameter pardoc-sum  like ub.wth-dtl.doc-sum no-undo .
define input parameter parfact-sum  like ub.wth-dtl.fact-sum no-undo .
define input parameter parsum-gds-rubl like  ub.wth-dtl.sum-gds-rubl no-undo .
define input parameter parsum-gds-base like  ub.wth-dtl.sum-gds-base no-undo .
define input parameter parline-exist as logical no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wth-dtl1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/wth-dtl1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в строке детализации документа МЦ".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }

DEFINE VARIABLE var-entry as character no-undo .
DEFINE VARIABLE loc#log as logical no-undo .
define buffer buf_wth-line for ub.wth-line.
define buffer buf_wth-doc for ub.wth-doc.
define buffer buf_wth-parts for ub.wth-parts.

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
          "Не найден документа МЦ" pardoc-code
  view-as alert-box error .
end.
/*
if buf_wth-doc.status_ <> {&wayb} then do:
  message
  vss-workfile vss-revision vss-description skip
  "Документ МЦ имеет статус" buf_wth-doc.status_
 "добавление/изменение строки невозможно"
  view-as alert-box ERROR.
  return error '':U.
end.
*/

FIND FIRST buf_wth-line EXCLUSIVE-LOCK WHERE
           buf_wth-line.doc-code = buf_wth-doc.doc-code AND
           buf_wth-line.wth-code = parwth-code AND
           buf_wth-line.w-p-code = parw-p-code No-ERROR No-WAIT.
IF LOCKED buf_wth-line then do:
  message vss-workfile vss-revision vss-description skip
          "Запись строки документа МЦ" pardoc-code "занята"
          "добавление/изменение строки невозможно"
  view-as alert-box error .
end.
IF NOT available buf_wth-line then do:
  message vss-workfile vss-revision vss-description skip
          "Не найдена строка документа МЦ" pardoc-code parwth-code parw-p-code
  view-as alert-box error .
end.


IF NOT CAN-FIND( ub.wealth NO-LOCK WHERE ub.wealth.wth-code = parwth-code ) THEN DO:
  MESSAGE "Материальная ценность" parwth-code "не найдена в справочнике!"
  VIEW-AS ALERT-BOX ERROR.
  var-entry = "wth-code":U.
  RETURN ERROR var-entry.
END.

FIND FIRST ub.wth-dtl NO-LOCK WHERE
          ub.wth-dtl.doc-code = pardoc-code   AND
          ub.wth-dtl.wth-code = parwth-code   AND
          ub.wth-dtl.w-p-code = parw-p-code   AND
          ub.wth-dtl.par-code = parpar-code NO-ERROR.
if buf_wth-doc.status_ = {&permitted} then do:
  if (
      (not available ub.wth-dtl and pardoc-sum <> 0) OR
      (avail ub.wth-dtl AND
        (ub.wth-dtl.doc-code <> pardoc-code OR
        ub.wth-dtl.wth-code <> parwth-code OR
        ub.wth-dtl.w-p-code <> parw-p-code OR
        (buf_wth-doc.doc-type <> {&inventory} and ub.wth-dtl.doc-sum <> pardoc-sum )
      )
      )
    ) then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Документ МЦ имеет статус" buf_wth-doc.status_
    "возможно изменить только сумму факт"
    view-as alert-box ERROR.
    return error '':U.
  end.
end.

DO ON ERROR UNDO, return error '':U
   ON STOP UNDO, return error '':U:

IF AVAIL ub.wth-dtl THEN DO:
  ASSIGN
  par-rid = RECID( ub.wth-dtl ).
  FIND FIRST ub.wth-dtl EXCLUSIVE-LOCK WHERE
             RECID( ub.wth-dtl ) = par-rid.
END.
ELSE DO:
  { trg/wth-dtcr.i ub.wth-dtl buf_wth-line parpar-code }
  ASSIGN par-rid = RECID( ub.wth-dtl ).
END.
IF buf_wth-doc.doc-type = {&inventory} THEN DO:
  ASSIGN
  ub.wth-dtl.bef-sum  = (if parline-exist then (ub.wth-dtl.bef-sum + pardoc-sum) else pardoc-sum )
  ub.wth-dtl.aft-sum  = (if parline-exist then (ub.wth-dtl.aft-sum + parfact-sum) else parfact-sum )
  .
END.
ELSE DO:

  ASSIGN
  ub.wth-dtl.doc-sum  =  (if parline-exist then (ub.wth-dtl.doc-sum + pardoc-sum) else pardoc-sum )
  ub.wth-dtl.fact-sum = (if parline-exist then (ub.wth-dtl.fact-sum + parfact-sum) else parfact-sum )
  ub.wth-dtl.sum-gds-rubl = (if parline-exist then (ub.wth-dtl.sum-gds-rubl + parsum-gds-rubl) else parsum-gds-rubl )
  ub.wth-dtl.sum-gds-base = (if parline-exist then (ub.wth-dtl.sum-gds-base + parsum-gds-base) else parsum-gds-base )
  .

END.
if ub.wth-dtl.doc-sum = 0 AND
    ub.wth-dtl.fact-sum = 0 and
    ub.wth-dtl.bef-sum = 0 and
    ub.wth-dtl.aft-sum = 0
    and not can-find(first buf_wth-parts where
                           buf_wth-parts.w-p-code = ub.wth-dtl.w-p-code
                           and buf_wth-parts.wth-code = ub.wth-dtl.wth-code
                           and buf_wth-parts.par-code = ub.wth-dtl.par-code
                           and buf_wth-parts.out-code = ub.wth-dtl.doc-code ) then do:

  delete ub.wth-dtl.
end.
else do: /*Заполняем  gds-code по первой партии указанного номинала*/
     find first buf_wth-parts no-lock where
                           buf_wth-parts.w-p-code = ub.wth-dtl.w-p-code
                           and buf_wth-parts.wth-code = ub.wth-dtl.wth-code
                           and buf_wth-parts.par-code = ub.wth-dtl.par-code
                           and buf_wth-parts.out-code = ub.wth-dtl.doc-code no-error.
     if available buf_wth-parts then ub.wth-dtl.gds-code = buf_wth-parts.gds-code.
end.
END.