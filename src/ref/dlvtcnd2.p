block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dlvtcnd2.p $
$Archive: ref/dlvtcnd2.p $

Изменение статуса вохможности доставки по условиям хранени

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/22/04
Author: Bakhtadze Natalya
Creation date: 03/22/04

*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input parameter par-recid as recid no-undo.
define input-output parameter par-sts like ub.deliv-type-cond-keep.sts no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dlvtcnd2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dlvtcnd2.p $":U .
define variable vss-description as character no-undo init "Изменение статуса возможности доставки по условиям хранени ".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }

DEFINE VARIABLE loc#log as logical no-undo .
DEFINE BUFFER bf-deliv-type-cond-keep for ub.deliv-type-cond-keep.
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE varold-sts like ub.deliv-type-cond-keep.sts no-undo .


_main:
do
on error undo, return error
:

FIND FIRST bf-deliv-type-cond-keep WHERE
           recid(bf-deliv-type-cond-keep) = par-recid.
varold-sts = bf-deliv-type-cond-keep.sts.
if par-sts = ? then do:
  CASE varold-sts:
    when integer({&current-status-int}) then do:
      assign
      par-sts = integer({&deleted-status-int}).
    end.
    when integer({&deleted-status-int}) then do:
      assign
      par-sts = integer({&current-status-int}).
    end.
  END CASE.
end.

CASE par-sts:
  WHEN integer({&current-status-int}) then do:
    if integer({&current-status-int}) = bf-deliv-type-cond-keep.sts  then do:
      message "Запись уже имеет статус ТЕКУЩИЙ!"
      view-as alert-box ERROR.
      par-sts = ?.
      return error.
    end.
    else do:
      message
      "Запись уже удалена - восстановить?"
      view-as alert-box QUestion buttons YEs-no update choice.
    end.
  end.
  WHEN integer({&deleted-status-int}) then do:
    if integer({&deleted-status-int}) = bf-deliv-type-cond-keep.sts  then do:
      message "Запись уже имеет статус УДАЛЕН!"
      view-as alert-box ERROR.
      par-sts = ?.
      return error.
    end.
    else do:
      message
      "Удалить запись?"
      view-as alert-box QUestion buttons yes-no update choice.
    end.
  end.
END CASE.
if choice then
assign
bf-deliv-type-cond-keep.sts = par-sts.
release bf-deliv-type-cond-keep no-error .
if error-status:error then do:
  message
  "Ошибка при сохранении записи ВОЗМОЖНОСТИ ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo _main, return error .
end.

par-sts = ?.
end.