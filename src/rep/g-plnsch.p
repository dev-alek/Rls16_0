block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-plnsch.p $
$Archive: rep/g-plnsch.p $

"Планируемые платежи"

Автор: Демин Алексей Сергеевич
Дата создания: 03/24/06
Author: Alexey Demin
Creation date: 03/24/06

*/
define input  parameter parParentProc as handle    no-undo .

{ cmp/str-glbl.i }
{ cmp/r-page1.i new}

run rep/d-report.w
    ( input parParentProc ,
      input 'rep/e-plnsch.w',
      "Планируемые платежи на дату",
      1,
      "":U,
      "",
      "",
      "{&v-rubl},{&v-base}",
      "{&customer-yes}",
      no).