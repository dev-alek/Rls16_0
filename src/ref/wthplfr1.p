block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wthplfr1.p $
$Archive: ref/wthplfr1.p $

Сохранение изменений в записи МХ МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/20/04
Author: Bakhtadze Natalya
Creation date: 01/20/04

*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input-output parameter par-rid as recid no-undo .
define input parameter par-mode as character no-undo .
define input parameter parw-p-code      like ub.wth-place.w-p-code no-undo .
define input parameter parhost-code     like ub.wth-place.host-code no-undo .
define input parameter parobj-type      like ub.wth-place.obj-type no-undo .
define input parameter parobj-code      like ub.wth-place.obj-code  no-undo .
define input parameter parw-p-name      like ub.wth-place.w-p-name no-undo .
define input parameter par-status_      like ub.wth-place.status_  no-undo .
define input parameter parcash-desk     like ub.wth-place.cash-desk  no-undo .
define input parameter parmain-cash-desk like ub.wth-place.main-cash-desk  no-undo .
define input parameter par-PS            like ub.wth-place.ps  no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wthplfr1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/wthplfr1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в записи МХ МЦ".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ str/wth-lib.i }

DEFINE VARIABLE var-entry as character no-undo .
DEFINE VARIABLE parstock like ub.wth-pobj.income-pl no-undo .

if NOT (par-mode = {&add-def} OR par-mode = {&update}) then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр вызова par-mode" par-mode
  view-as alert-box ERROR.
  return error '':U.
end.

if par-mode = {&add-def} AND
  can-find(FIRST ub.wth-place where
                 ub.wth-place.host-code = parhost-code AND
                 ub.wth-place.obj-code = parobj-code AND
                 ub.wth-place.obj-type = parobj-type AND
                 ub.wth-place.w-p-code = parw-p-code
                 ) then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр вызова parhost-code " parhost-code
  "и/или parobj-type " parobj-type SKIP
  "и/или parobj-code " parobj-code SKIP
  "и/или parw-p-code " parw-p-code SKIP
  "Уже есть МХ МЦ:"  skip
  "Код фирмы" parhost-code skip
  "Тип объекта" parobj-type skip
  "Код объекта" parobj-code skip
  "Код МХ" parw-p-code
  view-as alert-box ERROR.
  return error '':U.
end.

run trg/wthplfr3.p (
                 INPUT parw-p-code
                ,INPUT parhost-code
                ,INPUT parobj-type
                ,INPUT parobj-code
                ,INPUT parw-p-name
                ,INPUT par-status_
                ,INPUT parcash-desk
                ,INPUT parmain-cash-desk
                ,INPUT par-PS
                ) no-error.
if error-status:error then do:
  return error return-value.
end.


if par-mode = {&add-def} then do:
  create ub.wth-place.
  assign par-rid = recid(ub.wth-place).
end.
else do:
  FIND FIRST ub.wth-place EXCLUSIVE-LOCK WHERE
            recid(ub.wth-place) = par-rid NO-WAIT No-ERROR.
  if locked ub.wth-place then do:
    message "Запись МХ МЦ занята"
    view-as alert-box error .
    return error.
  end.
  if not avail ub.wth-place then do:
    message "Не найдена запись МХ МЦ"
    view-as alert-box error .
    return error.
  end.
  if ub.wth-place.w-p-code <> parw-p-code OR
      ub.wth-place.host-code <> parhost-code OR
      ub.wth-place.obj-type <> parobj-type OR
      ub.wth-place.obj-code <> parobj-code then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "код фирмы и/или объект и/или код МХ" skip
      view-as alert-box ERROR.
      return error '':U.
  end.
  if ub.wth-place.cash-desk <> parcash-desk and
     ub.wth-place.cash-desk <> 0 then do:
    for each ub.wth-pobj No-LOCK WHERE
             ub.wth-pobj.obj-type = parobj-type AND
             ub.wth-pobj.obj-code = parobj-code AND
             ub.wth-pobj.w-p-code = parw-p-code
             :
      run wth-lib_cur-stock-place in this-procedure (
                                                       input parobj-type
                                                      ,input parobj-code
                                                      ,input parw-p-code
                                                      ,input ub.wth-pobj.wth-code
                                                      ,output parstock) no-error .

      if parstock <> 0 then do:
        message
        vss-workfile vss-revision vss-description skip
        "Для уже имеющейся записи нельзя изменить"
        "номер кассы если было движение на это МХ МЦ или остаток МЦ на нем <> 0"
        view-as alert-box error .
        return error '':U.
      end.
    END.
  end.
end.


assign
ub.wth-place.w-p-code =  (if par-mode = {&add-def}
                          then next-value(s-wth-place, {&db-name_schema})
                          else parw-p-code)
ub.wth-place.host-code =  parhost-code
ub.wth-place.obj-type =  parobj-type
ub.wth-place.obj-code =  parobj-code
ub.wth-place.w-p-name =  parw-p-name
ub.wth-place.status_ =  par-status_
ub.wth-place.PS =  par-pS
ub.wth-place.cash-desk = parcash-desk
ub.wth-place.main-cash-desk = parmain-cash-desk
.
return '':U.