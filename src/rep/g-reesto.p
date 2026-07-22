block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-reesto.p $
$Archive: rep/g-reesto.p $

Реестр документов по объектам

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

*/
define input  parameter parParentProc  as widget-handle no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-reesto.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-reesto.p $":U .
define variable vss-description as character no-undo init "Реестр документов по объектам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }
run rep/d-report.w (
    input parParentProc ,
    input 'rep/e-reesto.w',
    "Реестр документов по объектам",
    4,
    "",
    "*",
    "",
    "{&v-RUBL},{&v-base}",
    "all,{&Arc-stk-yes},{&format-folder}":U,
    no).