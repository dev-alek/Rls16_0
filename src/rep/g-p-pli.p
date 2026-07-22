block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-p-pli.p $
$Archive: rep/g-p-pli.p $

История изменения цен поставшика

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
input  "rep/e-p-pli.w","История изменения цен поставшика",
input  2,
input  "{&g-choice}":U,
input  "":U,
input  "",
input  "",
input  "all,{&Excel-yes}",
input  no).