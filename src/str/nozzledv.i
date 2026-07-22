/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Верификация на удаление и удаление пистолета ТРК

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/12/99
Author: Dmitry Ukhanov
Creation date: 08/12/99

*/
procedure nozzledv:
define input parameter parobj-type    like ub.clients.obj-type   no-undo.
define input parameter parobj-code    like ub.clients.obj-code   no-undo.
define input parameter parnozzle-code like ub.nozzle.nozzle-code no-undo.
define buffer bf_clients        for ub.clients.
define buffer bf_nozzle         for ub.nozzle.
define buffer bf_pl-pump-nozzle for ub.pl-pump-nozzle.
define buffer bf_pump-nozzle    for ub.pump-nozzle.
define variable varrec-id as recid no-undo.
{ str/ptrlv.i "def"}
{ str/ptrlv.i "ov+"}
/*Проверим то, что вообще-то есть чего удалить*/
find first bf_nozzle where bf_nozzle.obj-type    = parobj-type    and
                           bf_nozzle.obj-code    = parobj-code    and
                           bf_nozzle.nozzle-code = parnozzle-code no-lock no-error.
if not available bf_nozzle then do:
   return error SUBSTITUTE("Не найден пистолет с номером &1", parnozzle-code)
                {&str-obj}.
end.
assign varrec-id = RECID(bf_nozzle).
{ str/ptrlv.i "sch-cls"}
tr:
do transaction on error undo tr, return error
               on stop  undo tr, return error
               on quit  undo tr, return error :
  /*Удаляем все дочерние связанные таблицы*/
  for each bf_pl-pump-nozzle where bf_pl-pump-nozzle.obj-type    = parobj-type    and
                                   bf_pl-pump-nozzle.obj-code    = parobj-code    and
                                   bf_pl-pump-nozzle.nozzle-code = parnozzle-code exclusive-lock
                                   on error undo tr, return error
                                   on stop  undo tr, return error
                                   on quit  undo tr, return error :
      delete bf_pl-pump-nozzle.
  end.
  for each bf_pump-nozzle    where bf_pump-nozzle.obj-type       = parobj-type    and
                                   bf_pump-nozzle.obj-code       = parobj-code    and
                                   bf_pump-nozzle.nozzle-code    = parnozzle-code exclusive-lock
                                   on error undo tr, return error
                                   on stop  undo tr, return error
                                   on quit  undo tr, return error :
      delete bf_pump-nozzle.
  end.
  /*Ну а теперь себя*/
  find first bf_nozzle where RECID(bf_nozzle) = varrec-id exclusive-lock.
  delete bf_nozzle.
end. /*transaction*/
end procedure.
/* $Workfile$ e n d */