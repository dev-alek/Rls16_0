block-level on error undo, throw.
/*

$Revision: e5665df1db10, 792, rls $
$Author: EShklyar $
$Date: Fri Sep 16 16:22:48 2016 +0300 $
$Workfile: g-p-pp.p $
$Archive: rep/g-p-pp.p $

Контроль приходных цен

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 09/05/03 4:44

*/
define input  parameter parParentProc  as widget-handle no-undo.
{ cmp/str-glbl.i }
{ cmp/r-page1.i NEW }
run rep/d-report.w (
input parParentProc ,
input  "rep/e-p-pp.w","Контроль приходных цен",
input  2,
input  "{&g-all},{&g-grp},{&g-choice}":U,
input  "{&o-firm},{&o-currency},{&o-choice}":U,
input  "",
input  "",
input  "all,{&Excel-yes},{&customer-yes}",
input  no).