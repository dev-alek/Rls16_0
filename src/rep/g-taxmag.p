block-level on error undo, throw.
/*

$Revision: 7b257f2a487e, 484, rls $
$Author: SShalanin $
$Date: Sun Feb 28 19:23:08 2016 +0400 $
$Workfile: g-taxmag.p $
$Archive: rep/g-taxmag.p $

Отчет о налогах по релизации в магазине - запуск

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: 7b257f2a487e, 484, rls $":U .
define variable vss-author      as character no-undo init "$Author: SShalanin $":U .
define variable vss-date        as character no-undo init "$Date: Sun Feb 28 19:23:08 2016 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-taxmag.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-taxmag.p $":U .
define variable vss-description as character no-undo init "Отчет о налогах по релизации в магазине - запуск".
{ cmp/vssrevis.i }


{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ cmp/r-page0.i new}

define variable glog as logical no-undo .
{ gbl/getcntxt.i get }
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_tax-settlement_print':U
{&cntxt-firm}
v-cntxt-host-code-obj
'':U
0
0
0
0
true
glog
}

if not gLog then return "NO".
run rep/d-report.w (
                   input parparentproc
                   ,input 'rep/e-taxmag.w'
                   ,input ('РАСЧЕТ НАЛОГОВ (РЕАЛИЗАЦИЯ В МАГАЗИНЕ)')
                   ,input 4
                   ,input "{&g-all},{&g-grp},{&g-choice}"
                   ,input "*"
                   ,input ""
                   ,input ""
                   ,input "shop,{&Excel-yes}"
                   ,input no).

