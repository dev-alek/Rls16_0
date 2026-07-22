block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-inptl.p $
$Archive: rep/g-inptl.p $

Главная программа запуска отчета r-inptl.p из меню

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/30/09
Author: Dmitry Ukhanov
Creation date: 01/30/09

Автор1: Суслов Алексей Юрьевич
Дата создания1: 03/27/06

*/

define input  parameter parParentProc  as widget-handle no-undo.

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: g-inptl.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/g-inptl.p $":U .
def var vss-description as character no-undo init "Главная программа запуска отчета r-inptl.p из меню".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }

run rep/d-report.w (
                input parParentProc ,
                input 'rep/r-inptl.p',
                input "Ж У Р Н А Л  П О С Т У П И В Ш И Х  Н Е Ф Т Е П Р О Д У К Т О В  З А  П Е Р И О Д",
                input 5,
                input "{&g-one}",
                input "{&o-currency},{&o-choice}",
                input "",
                input "",
                input "all",
                input yes).