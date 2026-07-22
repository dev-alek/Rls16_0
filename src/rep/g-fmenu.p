block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-fmenu.p $
$Archive: rep/g-fmenu.p $

"Меню"

Автор: Чернова Светлана Александровна
Дата создания: 11/04/03
Author: Svetlana Chernova
Creation date: 11/04/03

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-fmenu.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-fmenu.p $":U .
define variable vss-description as character no-undo init "Меню".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }

define input  parameter parParentProc  as widget-handle no-undo.
run rep/d-report.w
  (
    input parParentProc ,
    input "rep/r-fmenu.p",
    input "Меню",
    input 1  ,
    input "" ,
    input "*",
    input "" ,
    input "" ,
    input "all,{&Excel-yes}",
    input yes
    ).