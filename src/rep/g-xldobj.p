block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-xldobj.p $
$Archive: rep/g-xldobj.p $

Итоги по дисконтным картам-запуск

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-xldobj.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-xldobj.p $":U .
define variable vss-description as character no-undo init "Итоги по дисконтным картам-запуск".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ cmp/r-page0.i new }

define variable glog as logical no-undo .
{ gbl/getcntxt.i get }
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_discount-cards-totals_print':U
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
if NOT glog then do:
  return .
end.
run rep/d-report.w (
                            input parparentproc
                            ,input 'rep/e-xldobj.w'
                            ,input ('Итоги по дисконтным картам')
                            ,input 0
                            ,input ""
                            ,input "*"
                            ,input ""
                            ,input ""
                            ,input "shop,{&Print-List-Hist-yes}"
                            ,input no).