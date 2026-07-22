block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-o-chkv.p $
$Archive: cus/g-o-chkv.p $

Обща

Автор: Чернова Светлана Александровна
Дата создания: 07/03/07
Author: Svetlana Chernova
Creation date: 07/03/07


*/
define input  parameter parParentProc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-o-chkv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/g-o-chkv.p $":U .
define variable vss-description as character no-undo init "Общая".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i NEW }

run rep/d-report.w (
    input parParentProc ,
    input "cus/r-o-chkv.p",
    input "Общая",
    input 2,
    input "":U,
    input "{&o-currency},{&o-choice}":U,
    input "",
    input "{&v-rubl}",
    input "shop,{&Excel-yes}",
    input yes
    ) .