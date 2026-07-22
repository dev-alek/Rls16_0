block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-cashrs.p $
$Archive: rep/g-cashrs.p $

Статистика по кассирам - запуск

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-cashrs.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-cashrs.p $":U .
define variable vss-description as character no-undo init "Статистика по кассирам - запуск".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page0.i new }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define variable glog as logical no-undo .
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_cur-obj-proceeds_print':U
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
if not glog then return.

run rep/d-report.w (
                             input parparentproc
                            ,input 'rep/e-cashrs.w'
                            ,input ('Статистика по кассирам')
                            ,input 2
                            ,input ""
                            ,input "*"
                            ,input ""
                            ,input ""
                            ,input "shop,{&send-check}"
                            ,input no).