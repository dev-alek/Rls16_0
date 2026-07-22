block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-op10.p $
$Archive: rep/g-op10.p $

Акт о реализации и отпуске изделий кухни ОП-10

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 11/04/03 2:56

*/
define input  parameter parParentProc  as widget-handle no-undo.
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }
run rep/d-report.w
    (
    input parParentProc ,
    input "rep/r-op10.p"        ,
    input "Акт о реализации и отпуске изделий кухни"  ,
    input 1    ,
    input ""   ,
    input "*"  ,
    input ""   ,
    input ""   ,
    input "all,{&Excel-yes},{&format-folder}" ,
    input yes
    ).