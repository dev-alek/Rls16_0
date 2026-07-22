block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории атрибута раскладки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/30/08
Author: Bakhtadze Natalya
Creation date: 09/30/08

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-layout-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории атрибута раскладки".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                         , ub.c-layout-attr.layout-id
                         , ub.c-layout-attr.attr-code
                         , ub.c-layout-attr.corr-user-db-num
                         , ub.c-layout-attr.chip-num
                                                  ) " }

