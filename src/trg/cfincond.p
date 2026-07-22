block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории связки

Автор: Чернова Светлана Александровна
Дата создания: 04/12/06
Author: Svetlana Chernova
Creation date: 04/12/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-fin-connect .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории связки".
{ cmp/vssrevis.i "substitute('&1|&2|&3', ub.c-fin-connect.fact-date, ub.c-fin-connect.fin-doc-code, ub.c-fin-connect.fin-ob-code) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error
:
  end.