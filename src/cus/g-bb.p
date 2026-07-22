block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-bb.p $
$Archive: cus/g-bb.p $

Отчет для Бизнес-Букета - запуск - Отчет о движении товаров через кассу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/20/05
Author: Bakhtadze Natalya
Creation date: 04/20/05

*/

define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-bb.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/g-bb.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
define variable glog as logical no-undo .
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
                 , input 'cus/e-bb.w'
                 , input ('Отчет о движении товаров через кассу')
                 , input 2
                 , input "{&g-all},{&g-choice}"
                 , input "*"
                 , input ""
                 , input ""
                 , input "shop"
                 , input no).