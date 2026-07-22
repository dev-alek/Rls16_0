block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись строки стоплиста

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/07/07
Author: Bakhtadze Natalya
Creation date: 07/07/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.stop-list-line.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись строки стоплиста".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                           , ub.stop-list-line.classif-type
                           , ub.stop-list-line.stop-list-code
                           , ub.stop-list-line.line-num
                           ) " }

{ cmp/trg-def.i }
