block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории РЕЖИМОВ РАБОТЫ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/30/08
Author: Bakhtadze Natalya
Creation date: 09/30/08

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-wi-mode.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории РЕЖИМОВ РАБОТЫ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                         , ub.c-wi-mode.mode-type
                         , ub.c-wi-mode.mode-id
                         , ub.c-wi-mode.corr-user-db-num
                         , ub.c-wi-mode.chip-num
                                                  ) " }