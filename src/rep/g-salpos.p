block-level on error undo, throw.

/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-salpos.p $
$Archive: rep/g-salpos.p $

"Сальдо по поставщикам"

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
      input 'rep/r-salpos.p',
      "Сальдо по поставщикам",
      0,
      "":U,
      "{&o-firm}",
      "",
      "{&v-rubl},{&v-base}",
      "{&customer-yes},x-customer-name=Выбор поставщика",
      yes).

     /* ,x-customer-type={&cmp}*/