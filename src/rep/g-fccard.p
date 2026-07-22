block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-fccard.p $
$Archive: rep/g-fccard.p $

Реестр калькуляционных карточек

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 11/10/03 3:48

*/
define input  parameter parParentProc  as widget-handle no-undo.
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }
run rep/d-report.w
    (
    input parParentProc ,
    input 'rep/r-fccard.p',
    input "Реестр калькуляционных карточек",
    input 2 ,
    input "{&g-choice},{&g-one}",
    input "*",
    input "" ,
    input "",
    input "all,{&Excel-yes}",   /*,{&format-folder}*/
    input yes ).