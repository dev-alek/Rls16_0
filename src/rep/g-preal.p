block-level on error undo, throw.
/*

$Revision: 6557e99634e7, 3192, rls $
$Author: EShklyar $
$Date: 2022/12/27 12:54:28 $
$Workfile: g-preal.p $
$Archive: rep/g-preal.p $

Отчет по пересменкам

Автор: 
Дата создания: 08/09/07
Author: Dmitry Ukhanov
Creation date: 08/09/07

Автор1: 
Дата создания: 04/13/06

*/

define input parameter parparentproc as widget-handle no-undo .
/*define input parameter custom-par    as character     no-undo .*/
define variable custom-par as character no-undo .
define variable vss-revision    as character no-undo initial "$Revision: 6557e99634e7, 3192, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: 2022/12/27 12:54:28 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: g-preal.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/g-preal.p $":U .
define variable vss-description as character no-undo initial "запуск Сводный отчет по поставкам топлива":U .

{ cmp/str-glbl.i     }
{ cmp/r-page0.i  new }
{ cmp/vssrevis.i     }

&scop ttl " Отчет по анализу длительности пересменки (Простой реализации до первого чека) "
custom-par = "all,{&Arc-OT-yes},{&Arc-Supp-yes},{&Arc-stk-yes},{&Excel-yes}" + {&comma-char} + "TOG-Shift-2 = yes" + {&comma-char} + custom-par.
run rep/d-report.w (
                input parparentproc ,
                input 'rep/e-preal.w',
                {&ttl},
                input 4,
                "", /* выбор товара */
/*                input "{&o-firm},{&o-currency},{&o-choice}",  /* выбор объекта */*/
                input "*",  /* выбор объекта */
                input "",
                input "",
                input custom-par,
                input no).

/* $Workfile: g-preal.p $   E n d */