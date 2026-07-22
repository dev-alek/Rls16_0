block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-ospis.p $
$Archive: cus/g-ospis.p $

Отчет по контрагентам списани

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 06/08/04 10:57

*/
define input  parameter parParentProc  as widget-handle no-undo.
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }

run rep/d-report.w
   (
input parParentProc ,
input "cus/e-ospis.w",
input "Отчет по контрагентам списания ",
input 2,
input "{&g-all},{&g-choice}":U,
input "{&o-currency},{&o-choice}",
input "",
input "{&v-RUBL}",
input "all,{&Excel-yes}",
input no)
.