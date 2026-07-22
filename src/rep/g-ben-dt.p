block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-ben-dt.p $
$Archive: rep/g-ben-dt.p $

Отчет по движению товара - сводный-запуск

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/

define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-ben-dt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-ben-dt.p $":U .
define variable vss-description as character no-undo init "Отчет по движению товара - сводный-запуск".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new}
{ gbl/getcntxt.i def }


{ gbl/getcntxt.i get }

 define variable g#log as logical   no-undo .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_reports_report-benet6':U
  {&cntxt-object}
  v-cntxt-host-code-obj
  v-cntxt-obj-type
  v-cntxt-obj-code
  0
  0
  0
  true
  g#log
}
 if not g#log then return.

run rep/d-report.w ( input parParentProc ,
input                       'rep/e-ben-dt.w',
input                       'Отчет по движению товара - сводный',
input                        2,
input                        "{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one},{&g-grp-prod}",
input                        "{&o-firm},{&o-currency},{&o-choice}",
input                        "",
input                        "{&v-RUBL},{&v-base}",
input                        "shop,{&Arc-stk-yes},{&Excel-yes}",
input                        no).