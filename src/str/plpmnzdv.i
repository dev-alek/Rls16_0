/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Верификация на удаление и удаление записи резервуар-ТРК-пистолет

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08


*/
procedure plpmnzdv:
define input parameter parobj-type    like ub.clients.obj-type   no-undo.
define input parameter parobj-code    like ub.clients.obj-code   no-undo.
define input parameter parpl-code     like ub.place.pl-code      no-undo.
define input parameter parpump-code   like ub.pump.pump-code     no-undo.
define input parameter parnozzle-code like ub.nozzle.nozzle-code no-undo.
define buffer bf_clients        for ub.clients.
define buffer bf_pl-pump-nozzle for ub.pl-pump-nozzle.
define variable varrec-id as recid no-undo.
{ str/ptrlv.i "def"}
{ str/ptrlv.i "ov+"}
{ str/ptrlv.i "sch-cls"}
tr:
do transaction on error undo tr, return error
               on stop  undo tr, return error
               on quit  undo tr, return error :
   find first bf_pl-pump-nozzle where bf_pl-pump-nozzle.obj-type    = parobj-type    and
                                      bf_pl-pump-nozzle.obj-code    = parobj-code    and
                                      bf_pl-pump-nozzle.pl-code     = parpl-code     and
                                      bf_pl-pump-nozzle.pump-code   = parpump-code   and
                                      bf_pl-pump-nozzle.nozzle-code = parnozzle-code exclusive-lock no-error.
   if not available bf_pl-pump-nozzle then
      return error SUBSTITUTE("Не найдена запись для удаления резевуар &1 ТРК &2 пистолет &3",
                              parpl-code,
                              parpump-code,
                              parnozzle-code) {&str-obj}.
   delete bf_pl-pump-nozzle.
end. /*transaction*/

end procedure.
/* $Workfile$ e n d */