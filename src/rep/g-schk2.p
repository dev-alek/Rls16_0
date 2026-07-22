block-level on error undo, throw.
/*

$Revision: 7534a354acf2, 3187, rls $
$Author: EShklyar $
$Date: 2022/12/27 12:54:25 $
$Workfile: g-schk2.p $
$Archive: rep/g-schk2.p $

Отчет по всем возвратным операциям

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
define variable vss-revision    as character no-undo initial "$Revision: 7534a354acf2, 3187, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: 2022/12/27 12:54:25 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: g-schk2.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/g-schk2.p $":U .
define variable vss-description as character no-undo initial "Отчет по всем возвратным операциям":U .

{ cmp/str-glbl.i     }
{ cmp/r-page0.i  new }
{ cmp/vssrevis.i     }

&scop ttl " Отчет по всем возвратным операциям "
custom-par = "all,{&Arc-OT-yes},{&Arc-Supp-yes},{&Arc-stk-yes},{&Excel-yes}" + {&comma-char} + "TOG-Shift-2 = yes" + {&comma-char} + custom-par.
run rep/d-report.w (
                input parparentproc ,
                input 'rep/e-schk2.w',
                {&ttl},
                input 4,
                "{&g-grp},{&g-choice}", /* выбор товара */
/*                "{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one}",  выбор товара */
/*                input "{&o-firm},{&o-currency},{&o-choice}",   выбор объекта */
                input "*",                                       /* выбор объекта все*/
                input "",
                input "",
                input custom-par,
                input no).


/* $Workfile: g-schk2.p $   E n d */