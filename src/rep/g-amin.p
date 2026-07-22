block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-amin.p $
$Archive: rep/g-amin.p $

Ассортиментный минимум по текущему объекту

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 03/29/05
*/

define input  parameter parParentProc  as widget-handle no-undo.
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }

run rep/d-report.w
    (
    input parParentProc ,
    input "rep/e-amin.w" ,
    input "Ассортиментный минимум по текущему объекту",
    input 0,
    input "{&g-all},{&g-grp},{&g-prod},{&g-choice}":U,
    input "{&o-currency}",
    input "{&p-crsa}" ,
    input "",
    input "all,{&Excel-yes}",
    input no).