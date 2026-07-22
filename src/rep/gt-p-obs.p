block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gt-p-obs.p $
$Archive: rep/gt-p-obs.p $

Оборотка по типу приобретениЯ

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 11/20/02 2:40

*/

define input  parameter parParentProc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gt-p-obs.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/gt-p-obs.p $":U .
define variable vss-description as character no-undo init "Оборотка по типу приобретения".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i NEW }


run rep/d-report.w (
    input parParentProc ,
    input "rep/t-p-ob-s.w",
    input  "Оборотная ведомость - по типу приобретения",
    input 2,
    input "{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one},{&g-grp-prod}":u,
    input "*":u,
    input "",
    input "{&v-rubl},{&v-base}",
    input "all,{&Arc-aht-yes},{&excel-yes},{&show-sale},{&show-crsa},{&show-cost},{&format-folder}",
    input no).