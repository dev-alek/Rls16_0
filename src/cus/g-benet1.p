block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-benet1.p $
$Archive: cus/g-benet1.p $

Движение товара по месту хранени

Автор: Чернова Светлана Александровна
Дата создания: 09/08/05
Author: Svetlana Chernova
Creation date: 09/08/05

*/
define input  parameter parparentproc  as widget-handle no-undo.
{ cmp/str-glbl.i }
{ cmp/r-page1.i NEW}
{ gbl/getcntxt.i def }


{ gbl/getcntxt.i get }
define variable g#log as logical   no-undo .

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reports_report-benet1':U
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

run rep/d-report.w (
input parParentProc ,
input                   "cus/e-benet1.w","Движение товара по месту хранения",
input                        2,
input                        "*":U,
input                        "*":U,
input                        "",
input                        "",
input                        "all,{&Arc-stk-yes},{&Excel-yes}",
input                        no).