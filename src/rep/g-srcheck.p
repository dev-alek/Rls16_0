block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: b010d5c8e6e4, 226, rls $":U .
define variable vss-author      as character no-undo init "$Author: SShalanin $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jul 24 17:41:37 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-srcheck.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-srcheck.p $":U .
define variable vss-description as character no-undo init "Средний чек".
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
                   ,input 'rep/e-srcheck.w'
                   ,input ('Средний чек')
                   ,input 4
                   ,input "{&g-all},{&g-grp},{&g-choice},{&g-one},{&g-spis}"
                   ,input "*"
                   ,input ""
                   ,input ""
                   , input "1,all,{&Excel-yes},x-SelectObject=obj-firm"
                   ,input no).
