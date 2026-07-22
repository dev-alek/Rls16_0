block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-venit.p $
$Archive: rep/g-venit.p $

Специальный заказной отчет для закрытия финансового периода 01.2001 в компании Lukoil Romania

Автор: Суслов Алексей Юрьевич
Дата создания: 04/12/06
Author: Alexey Suslov
Creation date: 04/12/06


*/

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: g-venit.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/g-venit.p $":U .
def var vss-description as character no-undo init "Специальный заказной отчет для закрытия финансового периода 01.2001 в компании Lukoil Romania".
{ cmp/vssrevis.i }
define input  parameter parParentProc  as widget-handle no-undo.
{ cmp/str-glbl.i }
{ cmp/r-page1.i new}
run rep/d-report.w (
                input parParentProc ,
                input 'rep/e-venit.w',
                input "ПРОДАЖИ ЧЕРЕЗ КАССУ",
                input 5,
                input "{&g-grp}",
                input "{&o-currency},{&o-choice}",
                input "",
                input "",
                input "all",
                input no).