block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-fzlist.p $
$Archive: rep/g-fzlist.p $

"Опись дневных заборных листов"

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
    input 'rep/r-fzlist.p',"Опись дневных заборных листов",1,
            "":U,
            "*",
            "" ,
            "",
            "all,{&Excel-yes}", yes ).