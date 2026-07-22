block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: finbank2.p $
$Archive: ref/finbank2.p $

Изменение статуса банка

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/16/03
Author: Bakhtadze Natalya
Creation date: 10/16/03

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input parameter p-recid as recid no-undo.
define input-output parameter p-status_ as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: finbank2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/finbank2.p $":U .
define variable vss-description as character no-undo init "Изменение статуса БАНКА".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }

DEFINE VARIABLE loc#log as logical no-undo .
DEFINE BUFFER bf_fin-bank for ub.fin-bank.
define buffer buf_fin-schet for ub.fin-schet.
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE varold-status_ like ub.fin-bank.status_ no-undo .

do
on error undo, return error
:

FIND FIRST bf_fin-bank WHERE
           recid(bf_fin-bank) = p-recid No-ERROR.

if not avail bf_fin-bank then return error.
varold-status_ = bf_fin-bank.status_.
if p-status_ = ?
or p-status_ = "":U
then do:
  CASE varold-status_:
    when {&current-status} then do:
      assign
      p-status_ = {&deleted-status}.
    end.
    when {&deleted-status} then do:
      assign
      p-status_ = {&current-status}.
    end.
  END CASE.
end.

for each buf_fin-schet exclusive-lock where
         buf_fin-schet.host-code = bf_fin-bank.host-code
     AND buf_fin-schet.code-bank = bf_fin-bank.code-bank
on error undo, return error
on stop undo, return error:
  if buf_fin-schet.status_ <> {&deleted-status}
  and bf_fin-bank.status_ = {&current-status}
  then do:
    message
    "У банка имеются счета в статусе" buf_fin-schet.status_ skip
    "Удаление невозможно"
    view-as alert-box error.
    undo, return error .
  end.
end.
_main:
do
on error undo, return error
:

CASE p-status_:
  WHEN {&current-status} then do:
    if {&current-status} = bf_fin-bank.status_  then do:
      message "БАНК уже имеет статус ТЕКУЩИЙ!"
      view-as alert-box ERROR.
      p-status_ = "".
      return error.
    end.
    else do:
      message
      "Восстановить удаленный банк?"
      view-as alert-box question buttons yES-NO  update choice.
      if choice then
      assign
      bf_fin-bank.status_ = {&current-status} .
      end.
  end.
  WHEN {&deleted-status} then do:
    choice = FALSE .
    message "Удалить банк Вы уверены?" skip
    view-as alert-box WARNING
    buttons OK-Cancel update choice .
    /*здесь надо вставлять проверки!!!!!!!*/
    if choice then  do:
      bf_fin-bank.status_ = {&deleted-status} .
    end.
  end.
END CASE.
release bf_fin-bank no-error .
if error-status:error then do:
  message
  "Ошибка при сохранении записи БАНК" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo _main, return error .
end.

p-status_ = "".
end.

end. /*doe*/