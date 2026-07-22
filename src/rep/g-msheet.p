block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-msheet.p $
$Archive: rep/g-msheet.p $

Главная программа запуска отчета r-ptlrtr.p из меню

Автор: Суслов Алексей Юрьевич
Дата создания: 04/12/06
Author: Alexey Suslov
Creation date: 04/12/06


*/

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: g-msheet.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/g-msheet.p $":U .
def var vss-description as character no-undo init "Главная программа запуска отчета r-msheet.p из меню".
{ cmp/vssrevis.i }
define input  parameter parParentProc  as widget-handle no-undo.
{ cmp/str-glbl.i }
{ cmp/r-page1.i new}
run rep/d-report.w (
                input parParentProc ,
                input 'rep/e-msheet.p',
                input "Н А К О П И Т Е Л Ь Н А Я  В Е Д О М О С Т Ь",
                input 5,
                input "{&g-one}",
                input "{&o-currency},{&o-choice}",
                input "",
                input "",
                input "all",
                input yes).