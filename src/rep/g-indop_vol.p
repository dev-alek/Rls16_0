block-level on error undo, throw.
/*

$Revision: 6fb4dee32451, 3338, rls $
$Author: EShklyar $
$Date: 2023/05/19 13:37:09 $
$Workfile: g-indop_vol.p $
$Archive: rep/g-indop_vol.p $

Прием топлива с превышением предельно допустимого объема резервуара

Автор: 
Дата создания: 08/09/07
Author: Dmitry Ukhanov
Creation date: 08/09/07

*/

define input parameter parparentproc as widget-handle no-undo .
/*define input parameter custom-par    as character     no-undo .*/
define variable custom-par as character no-undo .
define variable vss-revision    as character no-undo initial "$Revision: 6fb4dee32451, 3338, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: 2023/05/19 13:37:09 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: g-indop_vol.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/g-indop_vol.p $":U .
define variable vss-description as character no-undo initial "Прием топлива с превышением предельно допустимого объема резервуара":U .

{ cmp/str-glbl.i     }
{ cmp/r-page0.i  new }
{ cmp/vssrevis.i     }

&scop ttl " Прием топлива с превышением предельно допустимого объема резервуара "
custom-par = "all,{&Arc-OT-yes},{&Arc-Supp-yes},{&Arc-stk-yes},{&Excel-yes}" + {&comma-char} + "TOG-Shift-2 = yes" + {&comma-char} + custom-par.
run rep/d-report.w (
                input parparentproc ,
                input 'rep/e-indop_vol.w',
                {&ttl},
                input 4,
                "{&g-all},{&g-choice}:'petrol'", /* выбор товара */
/*                "{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one}",  выбор товара */
/*                input "{&o-firm},{&o-currency},{&o-choice}",   выбор объекта */
                input "*",                                       /* выбор объекта все*/
                input "",
                input "",
                input custom-par,
                input no).


/* $Workfile: g-indop_vol.p $   E n d */