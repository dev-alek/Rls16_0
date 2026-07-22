/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Верификация на удаление и удаление ТРК

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/
procedure pumpdv:
define input parameter parobj-type  like ub.clients.obj-type   no-undo.
define input parameter parobj-code  like ub.clients.obj-code   no-undo.
define input parameter parpump-code like ub.pump.pump-code no-undo.
define buffer bf_clients        for ub.clients.
define buffer bf_pump           for ub.pump.
define buffer bf_pl-pump        for ub.pl-pump.
define buffer bf_pump-nozzle    for ub.pump-nozzle.
define buffer bf_pl-pump-nozzle for ub.pl-pump-nozzle.
define buffer bf_pl-gds-pump    for ub.pl-gds-pump.
define variable varrec-id as recid no-undo.
{ str/ptrlv.i "def"}
{ str/ptrlv.i "ov+"}
/*Проверим то, что вообще-то есть чего удалить*/
find first bf_pump where bf_pump.obj-type  = parobj-type    and
                         bf_pump.obj-code  = parobj-code    and
                         bf_pump.pump-code = parpump-code no-lock no-error.
if not available bf_pump then
   return error SUBSTITUTE("Не найден пистолет с номером &1", parpump-code) {&str-obj}.
assign varrec-id = RECID(bf_pump).
{ str/ptrlv.i "sch-cls"}
tr:
do transaction on error undo tr, return error
               on stop  undo tr, return error
               on quit  undo tr, return error :
  /*Удаляем все дочерние связанные таблицы*/
  for each bf_pl-pump-nozzle where bf_pl-pump-nozzle.obj-type    = parobj-type    and
                                   bf_pl-pump-nozzle.obj-code    = parobj-code    and
                                   bf_pl-pump-nozzle.pump-code   = parpump-code   exclusive-lock
                                   on error undo tr, return error
                                   on stop  undo tr, return error
                                   on quit  undo tr, return error :
      delete bf_pl-pump-nozzle.
  end.
  for each bf_pl-gds-pump    where bf_pl-gds-pump.obj-type       = parobj-type    and
                                   bf_pl-gds-pump.obj-code       = parobj-code    and
                                   bf_pl-gds-pump.pump-code      = parpump-code   exclusive-lock
                                   on error undo tr, return error
                                   on stop  undo tr, return error
                                   on quit  undo tr, return error :
      delete bf_pl-gds-pump.
  end.
  for each bf_pl-pump        where bf_pl-pump.obj-type           = parobj-type    and
                                   bf_pl-pump.obj-code           = parobj-code    and
                                   bf_pl-pump.pump-code          = parpump-code   exclusive-lock
                                   on error undo tr, return error
                                   on stop  undo tr, return error
                                   on quit  undo tr, return error :
      delete bf_pl-pump.
  end.
  for each bf_pump-nozzle    where bf_pump-nozzle.obj-type       = parobj-type    and
                                   bf_pump-nozzle.obj-code       = parobj-code    and
                                   bf_pump-nozzle.pump-code      = parpump-code exclusive-lock
                                   on error undo tr, return error
                                   on stop  undo tr, return error
                                   on quit  undo tr, return error :
      delete bf_pump-nozzle.
  end.
  /*Ну а теперь себя*/
  find first bf_pump where RECID(bf_pump) = varrec-id exclusive-lock.
  delete bf_pump.
end. /*transaction*/

end procedure.
{ str/ptrlv.i undef}
/* $Workfile$ e n d */