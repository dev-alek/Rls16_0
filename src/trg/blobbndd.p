block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление blob-bind

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/28/07
Author: Bakhtadze Natalya
Creation date: 12/28/07

*/


TRIGGER PROCEDURE FOR DELETE OF ub.blob-bind.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление blob-bind".
{ cmp/vssrevis.i }
