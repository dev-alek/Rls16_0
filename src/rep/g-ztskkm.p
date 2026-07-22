block-level on error undo, throw.
/*

$Revision: 2adf6a12c8b0, 3165, rls $
$Author: VSpiridonov $
$Date: 2022/12/27 12:54:22 $
$Workfile: g-ztskkm.p $
$Archive: rep/g-ztskkm.p $

Отчет по анализу длительности пересменка (Закрытие технологической смены на ККМ)

Автор: 
Дата создания: 08/09/07
Author: 
Creation date: 08/09/07
Автор1: 
Дата создания: 04/13/06

*/

define input parameter parparentproc as widget-handle no-undo .
/*define input parameter custom-par    as character     no-undo .*/
define variable custom-par as character no-undo .
define variable vss-revision    as character no-undo initial "$Revision: 2adf6a12c8b0, 3165, rls $":U .
define variable vss-author      as character no-undo initial "$Author: VSpiridonov $":U .
define variable vss-date        as character no-undo initial "$Date: 2022/12/27 12:54:22 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: g-ztskkm.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/g-ztskkm.p $":U .
define variable vss-description as character no-undo initial "Отчет по анализу длительности пересменка (Закрытие технологической смены на ККМ)":U .

{ cmp/str-glbl.i     }
{ cmp/r-page0.i  new }
{ cmp/vssrevis.i     }

&scop ttl " Отчет по анализу длительности пересменка (Закрытие технологической смены на ККМ) "
custom-par = "all,{&Arc-OT-yes},{&Arc-Supp-yes},{&Arc-stk-yes},{&Excel-yes}" + {&comma-char} + "TOG-Shift-2 = yes" + {&comma-char} + custom-par.
run rep/d-report.w (
                input parparentproc ,
                input 'rep/e-ztskkm.w',
                {&ttl},
                input 4,
                "", /* выбор товара */
                input "{&o-firm},{&o-currency},{&o-choice}",  /* выбор объекта */
                input "",
                input "",
                input custom-par,
                input no).

/* $Workfile: g-ztskkm.p $   E n d */