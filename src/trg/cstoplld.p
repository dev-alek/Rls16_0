block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории строки стоплиста

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/07/07
Author: Bakhtadze Natalya
Creation date: 07/07/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-stop-list-line.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории строки стоплиста".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                           , ub.c-stop-list-line.classif-type
                           , ub.c-stop-list-line.stop-list-code
                           , ub.c-stop-list-line.line-num
                           , ub.c-stop-list-line.corr-user-db-num
                           , ub.c-stop-list-line.chip-num
                           ) " }
{ cmp/trg-def.i }