block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-grphr.p $
$Archive: rep/g-grphr.p $

Запуск отчета ПОЧАСОВАЯ СТАТИСТИКА ПО КОЛ-ВУ ТОВАРОВ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/07/09
Author: Bakhtadze Natalya
Creation date: 05/07/09

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-grphr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-grphr.p $":U .
define variable vss-description as character no-undo init "Запуск отчета ПОЧАСОВАЯ СТАТИСТИКА ПО КОЛ-ВУ ТОВАРОВ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/r-page0.i new }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }


define variable varis-ok      as   logical             no-undo initial no.
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
  varis-ok
}
if not varis-ok then return error.
run rep/d-report.w ( input parparentproc
                    ,input 'rep/e-grphr.w'
                    ,input 'Почасовая статистика розничных продаж по КОЛИЧЕСТВУ ТОВАРОВ'
                    ,input 2
                    ,input "{&g-all },{&g-grp},{&g-prod},{&g-choice}"
                    ,input '*'
                    ,input ''
                    ,input ''
                    ,input 'shop,{&send-check}'
                    ,input no).
