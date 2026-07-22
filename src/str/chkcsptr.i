/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка того, что смена закрыта или есть закрытый документ типа "смена" за текущую смену

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/12/99
Author: Dmitry Ukhanov
Creation date: 08/12/99

Автор1: Суслов Алексей Юрьевич
Дата создания: 03/27/06

*/
{ cmp/library.i }
{ cmp/str-glbl.i }
procedure chkcsptr:
define input parameter parobj-type   like ub.clients.obj-type     no-undo.
define input parameter parobj-code   like ub.clients.obj-code     no-undo.
define variable        varretobjat   as   character            no-undo.
define variable        varshift-date like ub.shift-obj.shift-date no-undo.
define variable        varshift-num  like ub.shift-obj.shift-num  no-undo.
define buffer bf_clients   for ub.clients.
define buffer bf_shift-obj for ub.shift-obj.
define buffer bf_rvs-doc   for ub.rvs-doc.

/*Проверяем объект на правильность*/
find first bf_clients where bf_clients.obj-type = parobj-type and
                            bf_clients.obj-code = parobj-code no-lock no-error.
if not available bf_clients then return error "Нет такого объекта " + parobj-type +
                                              " "                   + string(parobj-code) + ".".
{ gbl/objat.i parobj-type
          parobj-code
          "'shift-on=request'"
          varretobjat
          no-error }
if error-status:error then  return error "Ошибка при вызове файла library.p: objat".
if varretobjat <> "yes" then do:
   return error "Фатальная ошибка. На объекте " + parobj-type + " " + string(parobj-code) + " не включены смены.".
end.
find first bf_shift-obj
     where bf_shift-obj.obj-type = parobj-type
       and bf_shift-obj.obj-code = parobj-code
       and bf_shift-obj.status_  = {&sht-current}
      use-index pi no-error .
if available bf_shift-obj then do:
   find first bf_rvs-doc where bf_rvs-doc.obj-type   = parobj-type             and
                               bf_rvs-doc.obj-code   = parobj-code             and
                               bf_rvs-doc.shift-date = bf_shift-obj.shift-date and
                               bf_rvs-doc.shift-num  = bf_shift-obj.shift-num  and
                               bf_rvs-doc.status_    = {&fact}                 and
                               bf_rvs-doc.rvs-type   = {&rvs-shift}            no-lock no-error.
   if not available bf_rvs-doc then
   return error "Смена открыта и не сделан документ сверки типа 'смена' за текущую смену.".
end.

end procedure.

/* $Workfile$ e n d */