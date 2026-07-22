block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-kar3.p $
$Archive: cus/g-kar3.p $

Отчет по процентам скидки чеков - запуск

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/21/06
Author: Bakhtadze Natalya
Creation date: 03/21/06

*/

define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-kar3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/g-kar3.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/r-page0.i new }
{ gbl/getcntxt.i def }
{ cmp/library.i }


define NEW SHARED var shft as logical no-undo init no.
define NEW SHARED var cas-shft as logical no-undo init no.
define variable glog as logical no-undo .
{ gbl/getcntxt.i get }
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



/* использовать смены на объекте*/
if v-cntxt-obj-type = {&shop} then do:
    FIND FIRST ub.shop no-lock where ub.shop.obj-code = v-cntxt-obj-code No-ERROR.
    shft = ub.shop.shift-on.
end.
else do:
    FIND FIRST ub.store no-lock where ub.store.obj-code = v-cntxt-obj-code No-ERROR.
    shft = ub.store.shift-on.
end.

run rep/d-report.w (     input parparentproc
                    ,input 'cus/e-kar3.p'
                    ,input 'Отчет по процентам скидки чеков'
                    ,input 2
                    ,input ""
                    ,input "*"
                    ,input ""
                    ,input ""
                    ,input "shop,{&send-check}"
                    ,input yes).