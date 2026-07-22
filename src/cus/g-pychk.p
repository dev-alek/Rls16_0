block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-pychk.p $
$Archive: cus/g-pychk.p $

Суммы продаж с разбивкой по типам кассовых платежей и НДС - запуск

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/05/04
Author: Bakhtadze Natalya
Creation date: 08/05/04

*/

define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-pychk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/g-pychk.p $":U .
define variable vss-description as character no-undo init "Суммы продаж с разбивкой по типам кассовых платежей и НДС - запуск".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page0.i new }
{ gbl/getcntxt.i def }
define NEW SHARED var cas-shft as logical no-undo init no.
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
if not glog then return.

run rep/d-report.w (
                  input parparentproc
                 ,input 'cus/e-pychk.w'
                 ,input 'Суммы продаж с разбивкой по типам кассовых платежей и НДС'
                 ,input 4
                 ,input "{&g-all},{&g-choice}"
                 ,input "*"
                 ,input ""
                 ,input ""
                 ,input "shop,{&send-check},{&Excel-yes}"
                 ,input no).