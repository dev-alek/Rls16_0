block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-otpsy.p $
$Archive: rep/g-otpsy.p $

Оборотка по типу приобретениЯ (ТПСИ)

Автор: Чернова Светлана Александровна
Дата создания: 09/16/05
Author: Svetlana Chernova
Creation date: 09/16/05

Creation date: 11/20/02 2:40

*/
define input  parameter parParentProc  as widget-handle no-undo.

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: g-otpsy.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/g-otpsy.p $":U .
def var vss-description as character no-undo init "Оборотка по типу приобретения (ТПСИ)    ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i NEW }


run rep/d-report.w (
    input parParentProc ,
    input "rep/e-otpsy.w","Оборотная ведомость - ТПСИ",
    input 2,
    input "*":u,
    input "{&o-firm},{&o-currency},{&o-choice}":u,
    input "",
    input "{&v-rubl},{&v-base}",
    input "all,{&Arc-aht-yes},{&excel-yes},{&show-sale},{&show-crsa},{&show-cost},{&format-folder}",
    input no).