block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-ptrpmp.p $
$Archive: rep/g-ptrpmp.p $

АКТ учета нефтепродуктов при выполнении работ по проверке погрешности ТРК

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/22/05
Author: Dmitry Ukhanov
Creation date: 11/22/05

*/

/* Parameter Definitions */
define input parameter p-parent-proc as widget-handle no-undo.

/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      as character no-undo initial "$Author: expertek $":U.
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: g-ptrpmp.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: rep/g-ptrpmp.p $":U.
define variable vss-description as character no-undo initial "АКТ учета нефтепродуктов при выполнении работ по проверке погрешности ТРК":U.

/* Common Definitions */
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/r-page1.i  new }

/* ***************************  Main Block  *************************** */
run rep/d-report.w ( input p-parent-proc,
                 input "rep/r-ptrpmp.p":U,
                 input "АКТ учета нефтепродуктов при выполнении работ по проверке погрешности ТРК":U,
                 input 1,
                 input "":U,
                 input "*":U,
                 input "":U,
                 input "":U,
                 input "all,{&Excel-yes}":U,
                 input yes                                 ).

/* $Workfile: g-ptrpmp.p $   E n d */
