block-level on error undo, throw.
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление атрибутов линий раскладок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/17/08
Author: Bakhtadze Natalya
Creation date: 10/17/08

*/

TRIGGER PROCEDURE FOR DELETE OF ub.layout-elem-rule-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление атрибутов линий раскладок".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.layout-elem-rule-attr.layout-id
                         , ub.layout-elem-rule-attr.mode-id
                         , ub.layout-elem-rule-attr.widget-id
                                                  ) " }
{ cmp/trg-def.i }