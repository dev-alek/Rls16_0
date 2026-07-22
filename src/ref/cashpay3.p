block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cashpay3.p $
$Archive: ref/cashpay3.p $

Изменение статуса платежа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/27/04
Author: Bakhtadze Natalya
Creation date: 02/27/04

*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input parameter par-recid as recid no-undo.
define input-output parameter par-status_ as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cashpay3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cashpay3.p $":U .
define variable vss-description as character no-undo init "Изменение статуса кассового платежа".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }

DEFINE VARIABLE loc#log as logical no-undo .
DEFINE BUFFER bf-cash-pay for ub.cash-pay.
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE varold-status_ like ub.cash-pay.status_ no-undo .


_main:
do
on error undo, return error return-value
:

FIND FIRST bf-cash-pay WHERE
           recid(bf-cash-pay) = par-recid.
varold-status_ = bf-cash-pay.status_.
if par-status_ = "":U then do:
  CASE varold-status_:
    when {&current-status} then do:
      assign
      par-status_ = {&deleted-status}.
    end.
    when {&deleted-status} then do:
      assign
      par-status_ = {&current-status}.
    end.
  END CASE.
end.

CASE par-status_:
  WHEN {&current-status} then do:
    if {&current-status} = bf-cash-pay.status_  then do:
      message "Платеж уже имеет статус ТЕКУЩИЙ!"
      view-as alert-box ERROR.
      par-status_ = "".
      return error.
    end.
    else do:
      message
      "Платеж уже удален - восстановить его?"
      view-as alert-box QUestion buttons YEs-no update choice.
    end.
  end.
  WHEN {&deleted-status} then do:
    if {&deleted-status} = bf-cash-pay.status_  then do:
      message "Платеж уже имеет статус УДАЛЕН!"
      view-as alert-box ERROR.
      par-status_ = "".
      return error.
    end.
    else do:
      message
      "Удалить платеж?"
      view-as alert-box QUestion buttons yes-no update choice.
    end.
  end.
END CASE.
if choice then
assign
bf-cash-pay.status_ = par-status_.
par-status_ = "".
end.