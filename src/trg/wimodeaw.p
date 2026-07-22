block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись атрибута режимов работы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/13/08
Author: Bakhtadze Natalya
Creation date: 10/13/08

*/

TRIGGER PROCEDURE FOR WRITE OF ub.wi-mode-attr.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись атрибута режимов работы".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.wi-mode-attr.mode-type
                         , ub.wi-mode-attr.mode-id
                         , ub.wi-mode-attr.attr-code
                                                  ) " }
{ cmp/trg-def.i }