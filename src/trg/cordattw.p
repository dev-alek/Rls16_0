block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 08/02/07
Author: Svetlana Chernova
Creation date: 08/02/07

*/
TRIGGER PROCEDURE FOR WRITE OF ub.c-ord-doc-attr.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
main-block:
do on error   undo main-block , return error return-value
   on endkey  undo main-block , return error return-value
   on stop    undo main-block , return error return-value
   :
end.