/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение товаров с фиксированной единицей измерени

Автор: Чернова Светлана Александровна
Дата создания: 05/16/08
Author: Svetlana Chernova
Creation date: 05/16/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 04/12/06

*/
function fix-unit returns logical (input parunit-base as character):
  find first ub.units where ub.units.unit-name = parunit-base no-lock no-error.
  if not available ub.units then return ?.
  else do:
    if lookup({&twounit},   ub.units.type) > 0 or
       lookup({&petrolium}, ub.units.type) > 0 then return yes.
                                               else return no.
  end.
end.
/*end of fix-unit.i*/