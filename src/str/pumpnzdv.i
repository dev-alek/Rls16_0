/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Верификация на удаление и удаление записи ТРК-пистолет

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/
procedure pumpnzdv:
define input parameter parobj-type    like ub.clients.obj-type   no-undo.
define input parameter parobj-code    like ub.clients.obj-code   no-undo.
define input parameter parpump-code   like ub.pump.pump-code     no-undo.
define input parameter parnozzle-code like ub.nozzle.nozzle-code no-undo.
define buffer bf_clients        for ub.clients.
define buffer bf_pump-nozzle    for ub.pump-nozzle.
define buffer bf_pl-pump-nozzle for ub.pl-pump-nozzle.
define variable varrec-id as recid no-undo.
{ str/ptrlv.i "def"}
{ str/ptrlv.i "ov+"}
/*Проверим то, что вообще-то есть чего удалить*/
find first bf_pump-nozzle where bf_pump-nozzle.obj-type    = parobj-type   and
                                bf_pump-nozzle.obj-code    = parobj-code   and
                                bf_pump-nozzle.pump-code   = parpump-code  and
                                bf_pump-nozzle.nozzle-code = parnozzle-code
                                no-lock no-error.
if not available bf_pump-nozzle then
   return error SUBSTITUTE("Не найден запись ТРК-пистлет с номером ТРК &1 и номером пистлета &2", parpump-code, parnozzle-code) {&str-obj}.
assign varrec-id = RECID(bf_pump-nozzle).
{ str/ptrlv.i "sch-cls"}
tr:
do transaction on error undo tr, return error
               on stop  undo tr, return error
               on quit  undo tr, return error :
  /*Удаляем все дочерние, связанные таблицы*/
  for each bf_pl-pump-nozzle where bf_pl-pump-nozzle.obj-type    = parobj-type    and
                                   bf_pl-pump-nozzle.obj-code    = parobj-code    and
                                   bf_pl-pump-nozzle.pump-code   = parpump-code   and
                                   bf_pl-pump-nozzle.nozzle-code = parnozzle-code exclusive-lock
                                   on error undo tr, return error
                                   on stop  undo tr, return error
                                   on quit  undo tr, return error :
      delete bf_pl-pump-nozzle.
  end.
  /*Ну а теперь себя*/
  find first bf_pump-nozzle where RECID(bf_pump-nozzle) = varrec-id exclusive-lock.
  delete bf_pump-nozzle.
end. /*transaction*/

end procedure.
/* $Workfile$ e n d */