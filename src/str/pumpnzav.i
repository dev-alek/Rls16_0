/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Верификация на создание и создание записи ТРК-пистолет

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/
{ str/ptrlv.i "def" }
procedure pumpnzav:
define input parameter parobj-type    like ub.clients.obj-type    no-undo.
define input parameter parobj-code    like ub.clients.obj-code    no-undo.
define input parameter parpump-code   like ub.pump.pump-code      no-undo.
define input parameter parnozzle-code like ub.nozzle.nozzle-code  no-undo.
define input parameter paris-meas     like ub.pump-nozzle.is-meas no-undo.
define input parameter paref-nid      like ub.pump-nozzle.ef-nid no-undo.
define buffer bf_clients     for ub.clients.
define buffer bf_pump        for ub.pump.
define buffer bf_nozzle      for ub.nozzle.
define buffer bf_pump-nozzle for ub.pump-nozzle.
define buffer bf_rvs-doc     for ub.rvs-doc.
define buffer bf_icnt-doc    for ub.icnt-doc.
{ str/ptrlv.i "ov+"       }
{ str/ptrlv.i "ppv+"      }
{ str/ptrlv.i "nv+"       }
{ str/ptrlv.i "rvs-doc-"  }
{ str/ptrlv.i "icnt-doc-" }
/*Проверяем то, что нет еще такой записи ТРК-пистолет*/
find first bf_pump-nozzle where bf_pump-nozzle.obj-type    = parobj-type    and
                                bf_pump-nozzle.obj-code    = parobj-code    and
                                bf_pump-nozzle.pump-code   = parpump-code   and
                                bf_pump-nozzle.nozzle-code = parnozzle-code no-lock no-error.
if available bf_pump-nozzle then
             return error SUBSTITUTE ("Уже есть запись ТРК-пистолет с номером ТРК &1 и номером пистолета &2", parpump-code, parnozzle-code) {&str-obj}.
create bf_pump-nozzle.
assign bf_pump-nozzle.obj-type    = parobj-type
       bf_pump-nozzle.obj-code    = parobj-code
       bf_pump-nozzle.pump-code   = parpump-code
       bf_pump-nozzle.nozzle-code = parnozzle-code
       bf_pump-nozzle.is-meas     = paris-meas
       bf_pump-nozzle.ef-nid      = paref-nid
       .
end procedure.
{ str/ptrlv.i "undef"}
/* $Workfile$ e n d */