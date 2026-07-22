/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функция для просмотра названий алгоритма

Автор: Чернова Светлана Александровна
Дата создания: 11/07/07
Author: Svetlana Chernova
Creation date: 11/07/07

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION alg-name RETURNS CHARACTER
  ( buffer loc-table for ub.gds-add-charges ) :
if not available  loc-table  then return "678" .
if loc-table.cost-include = no then return "".

case loc-table.algoritm :
  when "1" then do:
    return "сумме приходных цен".
  end.
  when "2" then do:
    return "количеству(в баз. ед.изм.)".
  end.
  when "3" then do:
    return "количеству(в пост. ед.изм.)" .
  end.
  when "4" then do:
    return "весу".
  end.
end case.

END FUNCTION.