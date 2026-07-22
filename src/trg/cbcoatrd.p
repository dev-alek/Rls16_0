block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории атрибутов бар-кода по обьъектам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/02/09
Author: Bakhtadze Natalya
Creation date: 06/02/09

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-bar-code-obj-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории атрибутов бар-кода по обьъектам".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6':u~
                              ,ub.c-bar-code-obj-attr.obj-type~
                              ,ub.c-bar-code-obj-attr.obj-code~
                              ,ub.c-bar-code-obj-attr.b-code~
                              ,ub.c-bar-code-obj-attr.attr-code~
                              ,ub.c-bar-code-obj-attr.corr-user-db-num~
                              ,ub.c-bar-code-obj-attr.chip-num~
                              )" }
{ cmp/trg-def.i  }

do
on error undo, return error
:
  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ АТРИБУТА БАР-КОДА"
  view-as alert-box error .
  undo , return error .

end.