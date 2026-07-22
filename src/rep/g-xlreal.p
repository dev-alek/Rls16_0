block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-xlreal.p $
$Archive: rep/g-xlreal.p $

Помесячная реализация в магазине - запуск

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-xlreal.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-xlreal.p $":U .
define variable vss-description as character no-undo init "Помесячная реализация в магазине - запуск".
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
'actn_sale-report_print':U
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

if NOT gLog then do:
  return.
end.
run rep/d-report.w (            input parparentproc
                            ,input 'rep/e-xlreal.w'
                            ,input ('Помесячная реализация в магазине')
                            ,input 0
                            ,input ""
                            ,input "{&o-currency},{&o-choice}"
                            ,input ""
                            ,input ""
                            ,input "shop,{&send-check},{&Excel-Yes}"
                            ,input no).