block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-zapasr.p $
$Archive: rep/g-zapasr.p $


Отчет "Состояние запаса с учетом резервов"

Автор: Демин Алексей Сергеевич
Дата создания: 01/11/06
Author: Alexey Demin
Creation date: 01/11/06

*/

define input  parameter parParentProc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-zapasr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-zapasr.p $":U .
define variable vss-description as character no-undo init "Состояние запаса с учетом резервов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }

run rep/d-report.w
    (
    input parParentProc ,
    input 'rep/e-zapasr.w',"Состояние запаса с учетом резервов",
    1,
    "{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one},{&g-grp-prod}":U,
    "*",
    "" ,
    "{&v-RUBL},{&v-base}",
    "all,{&Excel-yes},{&format-folder}", no).