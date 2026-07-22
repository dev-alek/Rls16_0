block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-pr-u8.p $
$Archive: utl/g-pr-u8.p $

Утилита  Проверка налога в переоценке

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 08/11/03 1:04

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-pr-u8.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/g-pr-u8.p $":U .
define variable vss-description as character no-undo init "Утилита проверки налога в переоценке".
{ cmp/vssrevis.i }
define input  parameter g#mainmenu-handle as handle no-undo .
{ cmp/str-glbl.i }
{ cmp/r-page1.i new}
run rep/d-report.w (
input g#mainmenu-handle ,
input                   'utl/pr-u8.p',"Утилита проверки налога в переоценке",
input                        2,
input                        "":U,
input                        "*":U,
input                        "",
input                        "",
input                        "all",
input                        yes).