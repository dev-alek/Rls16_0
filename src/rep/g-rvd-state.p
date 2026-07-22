block-level on error undo, throw.
/*

$Revision: 7182fdaa4b72, 2879, rls $
$Author: SSlivenko $
$Date: Пн ноя 22 19:49:11 2021 +0300 $
$Workfile: g-RVD-state.p $
$Archive: rep/g-RVD-state.p $

Главная программа запуска отчета r-RVD-state.p из меню

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/08/10
Author: Dmitry Ukhanov
Creation date: 11/08/10

*/

define input  parameter parParentProc  as widget-handle no-undo.

def var vss-revision    as character no-undo init "$Revision: 7182fdaa4b72, 2879, rls $":U .
def var vss-author      as character no-undo init "$Author: SSlivenko $":U .
def var vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:11 2021 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: g-RVD-state.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/g-RVD-state.p $":U .
def var vss-description as character no-undo init "Главная программа запуска отчета r-RVD-state.p из меню".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }
&scop tt-l " Состояние изменения режима ввода данных по резервуарам"
run rep/d-report.w (
                input parParentProc ,
                input 'rep/e-RVD-state.w',
                {&tt-l},
                input 0,
                input "{&g-one},{&g-choice}",
                input "*",
                input "",
                input "",
                input "all,{&Excel-yes}",
                input no).