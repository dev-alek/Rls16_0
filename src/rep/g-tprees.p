block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-tprees.p $
$Archive: rep/g-tprees.p $

Реестр документов по типу приобретени

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 11/25/02 2:15

*/
define input  parameter parParentProc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-tprees.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-tprees.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }

run rep/d-report.w (
input parParentProc ,
input 'rep/e-tprees.w',
"Реестр документов по типу приобретения",
2,
"",
"{&o-currency}",
"",
"{&v-RUBL},{&v-base}",
"all,{&Arc-aht-yes},{&format-folder}":U,
no).