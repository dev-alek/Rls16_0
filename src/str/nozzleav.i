/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Верификация на создание и создание пистолета ТРК

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/12/99
Author: Dmitry Ukhanov
Creation date: 08/12/99

Автор1: Суслов Алексей Юрьевич
Дата создания: 04/04/06

*/
{ str/ptrlv.i "def"}
&if "{1}" eq "class"
&then
method private void nozzleav(
parobj-type    like ub.clients.obj-type,
parobj-code    like ub.clients.obj-code,
parnozzle-code like ub.nozzle.nozzle-code 
):
&else
procedure nozzleav:
define input parameter parobj-type    like ub.clients.obj-type   no-undo.
define input parameter parobj-code    like ub.clients.obj-code   no-undo.
define input parameter parnozzle-code like ub.nozzle.nozzle-code no-undo.
&endif
define buffer bf_clients for ub.clients.
define buffer bf_nozzle  for ub.nozzle.
{ str/ptrlv.i "ov+"}
/*Проверяем то, что нет еще такого пистолета*/
find first bf_nozzle where bf_nozzle.obj-type    = parobj-type    and
                           bf_nozzle.obj-code    = parobj-code    and
                           bf_nozzle.nozzle-code = parnozzle-code no-lock no-error.
if available bf_nozzle then
             return error SUBSTITUTE("Уже есть пистолет с номером &1", parnozzle-code) {&str-obj}.
create bf_nozzle.
assign bf_nozzle.obj-type    = parobj-type
       bf_nozzle.obj-code    = parobj-code
       bf_nozzle.nozzle-code = parnozzle-code.
end. // procedure/method
{ str/ptrlv.i "undef"}
/* $Workfile$ e n d */