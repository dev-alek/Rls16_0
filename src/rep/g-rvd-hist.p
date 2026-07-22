block-level on error undo, throw.
/*

$Revision: 7182fdaa4b72, 2879, rls $
$Author: SSlivenko $
$Date: Пн ноя 22 19:49:11 2021 +0300 $
$Workfile: g-RVD-hist.p $
$Archive: rep/g-RVD-hist.p $

Главная программа запуска отчета r-RVD-hist.p из меню

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/08/10
Author: Dmitry Ukhanov
Creation date: 11/08/10

*/

define input  parameter parParentProc  as widget-handle no-undo.

def var vss-revision    as character no-undo init "$Revision: 7182fdaa4b72, 2879, rls $":U .
def var vss-author      as character no-undo init "$Author: SSlivenko $":U .
def var vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:11 2021 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: g-RVD-hist.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/g-RVD-hist.p $":U .
def var vss-description as character no-undo init "Главная программа запуска отчета r-RVD-hist.p из меню".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }
{ gbl/getcntxt.i def  }
{ gbl/getcntxt.i get  }
&scop tt-l " История изменения режима ввода данных по резервуарам"
define variable v-value    as character no-undo .
define variable v-type     as character no-undo .

run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-type) no-error.
    
if v-value = "yes"
and v-cntxt-db-num = 0
then do:
  message "В ТБД нет справочника товаров. Запуск отчёта невозможен!" view-as alert-box .
  return .
end .

run rep/d-report.w (
                input parParentProc ,
                input 'rep/e-RVD-hist.w',
                {&tt-l},
                input 4,
                input "{&g-one},{&g-choice}",
                input "*",
                input "",
                input "",
                input "all,{&Excel-yes}",
                input no).