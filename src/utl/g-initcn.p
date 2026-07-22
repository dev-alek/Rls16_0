block-level on error undo, throw.
/*

$Revision: 4ad5914afa0c, 372, rls $
$Author: EShklyar $
$Date: Mon Dec 28 19:14:08 2015 +0300 $
$Workfile: g-initcn.p $
$Archive: utl/g-initcn.p $

Инициализация фин. архива arh-trn-doc-contract

Автор: Кочетков Михаил Юрьевич
Дата создания: 07/05/07
Author: Michael Kochetkov
Creation date: 07/05/07

*/
define input  parameter parParentProc as handle    no-undo .

{ cmp/str-glbl.i }
{ cmp/r-page1.i new}

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

run rep/d-report.w
    ( input parParentProc ,
      input 'utl/initcont.p',
      "Инициализация фин. архива arh-trn-doc-contract",
      1,
      "":U,
      "*",
      "",
      "",
      "",
      yes).