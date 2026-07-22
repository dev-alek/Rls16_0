block-level on error undo, throw.
/*

$Revision: 632296b21e49, 1811, rls $
$Author: EShklyar $
$Date: Fri Mar 15 14:46:15 2019 +0300 $
$Workfile: g-new-shift.p $
$Archive: rep/g-new-shift.p $

Сменный отчет (Псковнефтепродукт)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/09/07
Author: Dmitry Ukhanov
Creation date: 08/09/07

Автор1: Булгаков Андрей Николаевич
Дата создания: 04/13/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter custom-par    as character     no-undo . 

define variable vss-revision    as character no-undo initial "$Revision: 632296b21e49, 1811, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Fri Mar 15 14:46:15 2019 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: g-new-shift.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/g-new-shift.p $":U .
define variable vss-description as character no-undo initial "Сменный отчет (Псковнефтепродукт)":U .

{ cmp/str-glbl.i     }
{ cmp/r-page0.i  new }
{ cmp/vssrevis.i     }

&scop ttl " СМЕННЫЙ ОТЧЕТ "
custom-par = "all,{&Arc-OT-yes},{&Arc-Supp-yes},{&Arc-stk-yes},{&Excel-yes}" + {&comma-char} + "TOG-Shift-2 = yes" + {&comma-char} + custom-par + {&comma-char} + "CALL='new-rep'" .
run rep/d-report.w (
                input parparentproc ,
                input 'rep/e-shift.w',
                {&ttl},
                input 8,
                input "{&g-all},{&g-grp}",
                input "{&o-currency}",
                input "",
                input "",
                input custom-par,
                input no).


/* $Workfile: g-new-shift.p $   E n d */