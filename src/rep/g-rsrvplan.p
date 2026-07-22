block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-rsrvPlan.p $
$Archive: rep/g-rsrvPlan.p $

Отчет по планированию заказов.

Input:

Output:

*/

define input parameter p-mainmenu-handle as handle           no-undo.
define input parameter p-ok as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-rsrvPlan.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-rsrvPlan.p $":U .
define variable vss-description as character no-undo init "Отчет по планированию заказов.".
{ cmp/vssrevis.i    }
{ cmp/trg-def.i     }
/*{ cmp/r-page1.i new }*/

do
on error undo, return error
:
run rep/e-rsrv-plan.w ( input p-mainmenu-handle, p-ok) .
end.