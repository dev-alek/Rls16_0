block-level on error undo, throw.
/*

$Revision: 4c147e0df675, 235, rls $
$Author: PGridchina $
$Date: Tue Jul 28 13:40:01 2015 +0400 $
$Workfile: g-xldcrd.p $
$Archive: rep/g-xldcrd.p $

ОТЧЕТ ПО ПОКУПКАМ ПОСТОЯННЫХ КЛИЕНТОВ (С ДИС.КАРТАМИ) - запуск

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: 4c147e0df675, 235, rls $":U .
define variable vss-author      as character no-undo init "$Author: PGridchina $":U .
define variable vss-date        as character no-undo init "$Date: Tue Jul 28 13:40:01 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-xldcrd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-xldcrd.p $":U .
define variable vss-description as character no-undo init "ОТЧЕТ ПО ПОКУПКАМ ПОСТОЯННЫХ КЛИЕНТОВ (С ДИС.КАРТАМИ) - запуск".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ cmp/r-page0.i new}
define variable glog as logical no-undo .
{ gbl/getcntxt.i get }
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_permanent-client-sale_print':U
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
if NOT glog then  do:
  return .
end.

run rep/d-report.w (            input parparentproc
                            ,input 'rep/e-xldcrd.w'
                            ,input ('Продажи постоянным клиентам')
                            ,input 2 /*ТН-3320(было 2)*/
                            ,input "{&g-all},{&g-prod},{&g-grp},{&g-choice},{&g-one}"
                            ,input "*"
                            ,input ""
                            ,input ""
                            ,input "shop,{&Print-List-Hist-yes}"
                            ,input no).