block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wth-inc1.p $
$Archive: str/wth-inc1.p $

Сохранение изменений в документе МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/14/05
Author: Bakhtadze Natalya
Creation date: 09/14/05

*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input parameter p-silent                       as logical no-undo .
define input-output parameter par-rid as recid no-undo .
define input parameter par-mode     as character no-undo .
define input parameter pardoc-code  like ub.wth-doc.doc-code no-undo .
define input parameter parhost-code like ub.wth-doc.host-code no-undo .
define input parameter parobj-type  like ub.wth-doc.obj-type no-undo .
define input parameter parobj-code  like ub.wth-doc.obj-code no-undo .
define input parameter parcli-type  like ub.wth-doc.cli-type no-undo .
define input parameter parcli-code  like ub.wth-doc.cli-code no-undo .
define input parameter pardoc-date  like ub.wth-doc.doc-date no-undo .
define input parameter parfact-date like ub.wth-doc.fact-date no-undo .
define input parameter parshift-date like ub.wth-doc.shift-date no-undo .
define input parameter parshift-num like ub.wth-doc.shift-num no-undo .
define input parameter parshift-name like ub.wth-doc.shift-name no-undo .
define input parameter par-operator like ub.wth-doc.operator no-undo .
define input parameter par-deliver  like ub.wth-doc.deliver no-undo .
define input parameter par-receiver like ub.wth-doc.receiver no-undo .
define input parameter pardoc-type  like ub.wth-doc.doc-type no-undo .
define input parameter parauto-fill like ub.wth-doc.auto-fill no-undo .
define input parameter par-exter_   like ub.wth-doc.exter_ no-undo .
define input parameter par-inter_   like ub.wth-doc.inter_ no-undo .
define input parameter parsource-ref like ub.wth-doc.source-ref no-undo .
define input parameter parsource-type like ub.wth-doc.source-type no-undo .
define input parameter par-borned   like ub.wth-doc.borned no-undo .
define input parameter pardoc-sum   like ub.wth-doc.doc-sum no-undo .
define input parameter parfact-sum  like ub.wth-doc.fact-sum no-undo .
define input parameter par-PS       like ub.wth-doc.PS no-undo .
define input parameter par-status_  like ub.wth-doc.status_ no-undo .
define input parameter parlines-exist as logical no-undo .
define input parameter parext-type like ub.wth-doc.ext-doc-type no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wth-inc1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/wth-inc1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в документе МЦ".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ trg/wth-doch.i }

DEFINE VARIABLE loc#log as logical no-undo .
define variable v-mes     as character no-undo .
define variable v-file    as logical no-undo .
DEFINE VARIABLE var-entry as character no-undo .
DEFINE VARIABLE l-shift-on as logical no-undo .
DEFINE VARIABLE f-date     AS DATE NO-UNDO.
DEFINE VARIABLE f-time     AS INT  NO-UNDO.
DEFINE VARIABLE s-date     AS DATE NO-UNDO.
DEFINE VARIABLE s-num      AS INT  NO-UNDO.
DEFINE VARIABLE s-name     AS CHAR NO-UNDO.
DEFINE VARIABLE varcli-name like ub.clients.obj-name no-undo .
define buffer buf_c-wth-doc for ub.c-wth-doc.

_main:
do
on error undo, return error
:


if NOT (par-mode = {&add-def} OR par-mode = {&update}) then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр вызова par-mode" par-mode
  view-as alert-box ERROR.
  return error '':U.
end.

if par-status_ = {&fact} then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр вызова par-status_" par-status_
  view-as alert-box ERROR.
  return error '':U.
end.

if can-find(FIRST ub.wth-doc where
                  ub.wth-doc.doc-code = pardoc-code and
                 recid(wth-doc) <> par-rid) then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр вызова par-rid" par-rid skip
  " и/или pardoc-code " pardoc-code
  view-as alert-box ERROR.
  return error '':U.
end.

if LOOKUP( parext-type,{&WDEDT_List}) = 0 then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр вызова parext-type" parext-type
  view-as alert-box ERROR.
  return error '':U.
end.

if par-mode = {&add-def} then do:
  if parsource-type <> {&wthd-cash-desk} then do:
    run gbl/factdate.p (
                     INPUT        parobj-type
                    ,INPUT        parobj-code
                    ,INPUT-OUTPUT f-date
                    ,INPUT-OUTPUT f-time
                    ,INPUT-OUTPUT s-date
                    ,INPUT-OUTPUT s-num
                    ,INPUT-OUTPUT s-name
                    ,INPUT        (not p-silent)
                      ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      undo _main, return error return-value .
    END.
  end.
end.

/*проверка корректности всех таблиц*/
run trg/wth-inc2.p (
                 input p-silent
                ,input pardoc-code
                ,input parhost-code
                ,input parobj-type
                ,input parobj-code
                ,input parcli-type
                ,input parcli-code
                ,input par-operator
                ,input par-deliver
                ,input par-receiver
                ,input pardoc-type
                ,input parauto-fill
                ,input par-exter_
                ,input par-inter_
                ,input parsource-ref
                ,input parsource-type
                ,input par-borned
                ,input parlines-exist
                ,input parext-type
                ,output varcli-name) no-error.
if error-status:error then do:
  undo _main, return error return-value.
end.

if par-mode = {&add-def} then do:          /*заполняются поля уник. индекса*/
  if pardoc-code = "":U then do:
  { trg/wth-docr.i ub.wth-doc pardoc-type par-inter_ par-exter_ " " g#userid parext-type}
  end.
  else do:
  { trg/wth-docr.i ub.wth-doc pardoc-type par-inter_ par-exter_ pardoc-code g#userid parext-type}
  end.
  assign par-rid = recid(ub.wth-doc).
end.
else do:
  FIND FIRST ub.wth-doc EXCLUSIVE-LOCK WHERE
            recid(ub.wth-doc) = par-rid NO-WAIT No-ERROR.
  if locked ub.wth-doc then do:
    v-mes = substitute( "Документ занят"
                        ).
    run err-mess(input-output v-mes).
    var-entry = "":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  end.
  if not avail ub.wth-doc then do:
    v-mes = substitute( "Не найден документ МЦ"
                        ).
    run err-mess(input-output v-mes).
    var-entry = "":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  end.
  if ub.wth-doc.status_ <> par-status_ then do:
    v-mes = substitute( "Неверный вызов - с изменением статуса документа МЦ с &1 на &2"
                        ,ub.wth-doc.status_
                        , par-status_
                        ).
    run err-mess(input-output v-mes).
    var-entry = "":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  end.
  if ub.wth-doc.auto-fill <> parauto-fill then do:
    v-mes = substitute( "Неверный вызов - с изменением типа заполнения документа МЦ"
                        ).
    run err-mess(input-output v-mes).
    var-entry = "":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  end.
  if ub.wth-doc.ext-doc-type <> parext-type then do:
    v-mes = substitute( "Неверный вызов - с изменением расширенного типа документа МЦ"
                        ).
    run err-mess(input-output v-mes).
    var-entry = "":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  end.

  if ub.wth-doc.status_ <> {&wayb} then dO:
    if ub.wth-doc.doc-code <> pardoc-code OR
       ub.wth-doc.host-code <> parhost-code OR
       ub.wth-doc.obj-type <> parobj-type OR
       ub.wth-doc.obj-code <> parobj-code OR
       ub.wth-doc.cli-type <> parcli-type OR
       ub.wth-doc.cli-code <> parcli-code OR
       ub.wth-doc.doc-date <> pardoc-date OR
       ub.wth-doc.shift-date <> parshift-date OR
       ub.wth-doc.shift-num <> parshift-num OR
       ub.wth-doc.shift-name <> parshift-name OR
       ub.wth-doc.operator <> par-operator OR
       ub.wth-doc.deliver <> par-deliver OR
       ub.wth-doc.receiver <> par-receiver OR
       ub.wth-doc.doc-type <> pardoc-type OR
       ub.wth-doc.exter_ <> par-exter_ OR
       ub.wth-doc.inter_ <> par-inter_ OR
       ub.wth-doc.ext-doc-type <> parext-type  OR
       ub.wth-doc.doc-sum <> pardoc-sum then do:
      v-mes = substitute( "Документ МЦ имеет статус &1 возможно изменить только сумму факт и примечание"
                        , ub.wth-doc.status_
                          ).
      run err-mess(input-output v-mes).
      var-entry = "":U.
      undo _main, return error (if p-silent then v-mes else var-entry).
    end.
  end.
  create tt-wth-doc.
  buffer-copy ub.wth-doc to tt-wth-doc.
end.
assign
ub.wth-doc.cli-name =  varcli-name
ub.wth-doc.doc-code = (if par-mode = {&add-def} then ub.wth-doc.doc-code else pardoc-code)
ub.wth-doc.host-code = parhost-code
ub.wth-doc.obj-type = parobj-type
ub.wth-doc.obj-code = parobj-code
ub.wth-doc.cli-type = parcli-type
ub.wth-doc.cli-code = parcli-code
ub.wth-doc.doc-date = pardoc-date
ub.wth-doc.fact-date = parfact-date
ub.wth-doc.shift-date = parshift-date
ub.wth-doc.shift-num = parshift-num
ub.wth-doc.shift-name = parshift-name
ub.wth-doc.operator = par-operator
ub.wth-doc.deliver = par-deliver
ub.wth-doc.receiver = par-receiver
ub.wth-doc.doc-type = pardoc-type
ub.wth-doc.auto-fill = parauto-fill
ub.wth-doc.exter_ = par-exter_
ub.wth-doc.inter_ = par-inter_
ub.wth-doc.doc-sum = pardoc-sum
ub.wth-doc.fact-sum = parfact-sum
ub.wth-doc.PS = par-PS
ub.wth-doc.status_ = par-status_
ub.wth-doc.source-ref = parsource-ref
ub.wth-doc.source-type = parsource-type
ub.wth-doc.borned = par-borned
ub.wth-doc.ext-doc-type = parext-type
.

release ub.wth-doc no-error .
if error-status:error then do:
    v-mes = substitute("Ошибка при сохранении документа&1&2 &3", {&new-line}, error-status:get-message(1), return-value ).
    run err-mess(input-output v-mes).
    var-entry = "":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
end.

/*проверим нужно ли писать историю.*/
find last buf_c-wth-doc no-lock where
          buf_c-wth-doc.doc-code = pardoc-code
      AND  buf_c-wth-doc.corr-user-db-num = g#db-num no-error.
if (not par-mode = {&add-def} and tt-wth-doc.creid <> g#userid
and not available buf_c-wth-doc)
/*кто-то исправил созданный другим документ и это исправление - первая запись в истории*/
or (available buf_c-wth-doc
and buf_c-wth-doc.corr-user-name <> g#userid)
/*предыдущее исправление было другим пользователем*/
then do:

  run wth-doch_write-wth-doc-history in this-procedure (
                                                          buffer tt-wth-doc
                                                          ,input pardoc-code
                                                          ,input parhost-code
                                                          ,input parobj-type
                                                          ,input parobj-code) no-error .
  if error-status:error then do:
      v-mes = error-status:get-message(1) .
      run err-mess(input-output v-mes).
      undo _main, return error v-mes.

  end.
end.

return '':U.
end. /*doe*/

PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mes as character No-UNDO.
  p-mes = substitute("Документ МЦ №&1: &2&3&4&5", pardoc-code, parobj-type, parobj-code, {&new-line}, p-mes).
  if not p-silent then
  message
  p-mes
  view-as alert-box error .
END PROCEDURE.