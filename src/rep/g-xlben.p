block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-xlben.p $
$Archive: rep/g-xlben.p $

Помесячный оборот по магазинам в ценах продаж - запуск

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-xlben.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-xlben.p $":U .
define variable vss-description as character no-undo init "Помесячный оборот по магазинам в ценах продаж - запуск".
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
'actn_proceeds-monthly_print':U
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
                            ,input 'rep/e-xlben.w'
                            ,input ('Помесячный оборот по магазинам в ценах продаж')
                            ,input 0
                            ,input ""
                            ,input "*"
                            ,input ""
                            ,input ""
                            ,input "shop,{&Excel-yes}"
                            ,input no)