block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории атрибута элемента раскладки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/10/08
Author: Bakhtadze Natalya
Creation date: 10/10/08

*/

TRIGGER PROCEDURE FOR WRITE OF ub.layout-elem-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории атрибута элемента раскладки".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                         , ub.layout-elem-attr.layout-type
                         , ub.layout-elem-attr.device-type
                         , ub.layout-elem-attr.mode-id
                         , ub.layout-elem-attr.widget-id
                         , ub.layout-elem-attr.attr-code
                                                  ) " }
{ cmp/trg-def.i }