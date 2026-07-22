block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ck-uncli.p $
$Archive: str/ck-uncli.p $

Проверка возможности оформления товара в строке с единицами измерения отличной от указанной в справочнике

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич


*/

{ cmp/trg-def.i }
{ str/fix-unit.i }
define input parameter parunit-cli             like doc-line.unit-cli            no-undo.
define input parameter pargds-code             like goods.gds-code               no-undo.
define input parameter parobj-type             like clients.obj-type             no-undo.
define input parameter parobj-code             like clients.obj-code             no-undo.
define input parameter parhold-doc-code-parent like trn-doc.hold-doc-code-parent no-undo.
define input parameter parhold-doc-code-child  like trn-doc.hold-doc-code-child  no-undo.
define output parameter paris-error      as   logical             no-undo.
define variable         varis-petrol     as   logical             no-undo.
define variable         varis-pieces     as   logical             no-undo.
define variable         varunit-cli-perm like store.unit-cli-perm no-undo.
assign paris-error = no.

find first goods   where goods.gds-code = pargds-code  no-lock.
if parobj-type =  {&stock} then do:
  find first store where store.obj-code = parobj-code no-lock.
  assign
    varunit-cli-perm = store.unit-cli-perm.
end.
else do:
  find first shop where shop.obj-code = parobj-code no-lock.
  assign
    varunit-cli-perm = shop.unit-cli-perm.
end.
if parunit-cli <> goods.unit-cli then do:
  if ( varunit-cli-perm <> yes and
       (parhold-doc-code-parent = "" or
        parhold-doc-code-parent = "no-hold" or
        parhold-doc-code-parent = ?)
        and
       (parhold-doc-code-child = "" or
        parhold-doc-code-child = "no-hold" or
        parhold-doc-code-child = ?)

     )
     or fix-unit(ub.goods.unit-base) then do:
     paris-error = yes.
  end.
end.