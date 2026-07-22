/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Есть ли в товаре стеклопосуда(дорожный налог)?

Автор: Чернова Светлана Александровна
Дата создания: 02/14/07
Author: Svetlana Chernova
Creation date: 02/14/07

create: Суслов Алексей Юрьевич
Дата создания: 04/12/06


                        !!!ВНИМАНИЕ!!!
               Должен быть также включен файл croslist.i
                        !!!ВНИМАНИЕ!!!
*/
function hvrdtax return logical (input parrecid as recid):
define variable varresult as logical no-undo.
run hvrdtax-proc (input parrecid, output varresult).
return varresult.
end function.
procedure hvrdtax-proc:
define input  parameter parrecid  as recid   no-undo.
define output parameter parresult as logical no-undo.
define buffer bf_goods for ub.goods.
define buffer bf_units for ub.units.
define buffer rt_tax   for ub.tax.
find first rt_tax   where rt_tax.tax-code    = integer({&road-tax-code}) no-lock no-error.
find first bf_goods where recid(bf_goods)    = parrecid              no-lock.
find first bf_units where bf_units.unit-name = bf_goods.unit-base    no-lock.
if available rt_tax and
    can-find(first ub.tax-units No-LOCK WHERE
                   ub.tax-units.tax-code = rt_tax.tax-code AND
                   LOOKUP(ub.tax-units.type, bf_units.type) > 0) then assign parresult = yes.
                                                    else assign parresult = no.
end procedure.
/*e n d  h v r d t a x.i*/