block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-skm.p $
$Archive: cus/g-skm.p $

Выгрузка в файл данных по продажам по СКМ-запуск

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/24/04
Author: Bakhtadze Natalya
Creation date: 06/24/04

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-skm.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/g-skm.p $":U .
define variable vss-description as character no-undo init "Выгрузка в файл данных по продажам по СКМ-запуск".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page0.i new }
{ gbl/getcntxt.i def }

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

run rep/d-report.w ( input parparentproc
               , input 'cus/e-skm.w'
               , input 'Выгрузка в файл данных по продажам по СКМ'
               , input 2
               , input ""
               , input "*"
               , input ""
               , input ""
               , input "shop,{&send-check},{&Excel-yes}"
               , input no).