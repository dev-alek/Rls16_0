block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-benet2.p $
$Archive: cus/g-benet2.p $

Движение товара - сводный отчет

Автор: Чернова Светлана Александровна
Дата создания: 09/08/05
Author: Svetlana Chernova
Creation date: 09/08/05

*/
define input  parameter parParentProc  as widget-handle no-undo.
{ cmp/str-glbl.i }
{ cmp/r-page1.i NEW}
{ gbl/getcntxt.i def }


{ gbl/getcntxt.i get }
define variable g#log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reports_report-benet2':U
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
input "cus/e-benet2.w","Движение товара - сводный отчет",
input  2,
input  "*":U,
input  "{&o-firm},{&o-all}",
input  "",
input  "",
input  "all,{&Arc-stk-yes},{&Excel-yes}",
input  no) .