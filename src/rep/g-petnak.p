block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-petnak.p $
$Archive: rep/g-petnak.p $

Расход нефтепродуктов по документам - запуск

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-petnak.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-petnak.p $":U .
define variable vss-description as character no-undo init "Расход нефтепродуктов по документам - запуск".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page0.i new }
{ gbl/getcntxt.i def }

def NEW SHARED var shft as logical no-undo init no.
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



CASE shft:
    WHEN YES THEN DO:
        run rep/d-report.w (
                             input parparentproc
                            ,input 'rep/e-petnak.w'
                            ,input 'Расход нефтепродуктов по документам'
                            ,input 5
                            ,input ""
                            ,input "*"
                            ,input ""
                            ,input ""
                            ,input "all"
                            ,input no).
    END.
    WHEN NO THEN DO:
        run rep/d-report.w (
                             input parparentproc
                            ,input 'rep/e-petnak.w'
                            ,input 'Расход нефтепродуктов по документам'
                            ,input 2
                            ,input ""
                            ,input "*"
                            ,input ""
                            ,input  ""
                            ,input "all"
                            ,input no).
    END.
END CASE.