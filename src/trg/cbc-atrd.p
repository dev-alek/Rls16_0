block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории атрибута бар-кода

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/14/07
Author: Bakhtadze Natalya
Creation date: 03/14/07

*/

TRIGGER PROCEDURE FOR delete OF ub.c-bar-code-attr .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории атрибута бар-кода".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4':u~
                              ,ub.c-bar-code-attr.b-code~
                              ,ub.c-bar-code-attr.attr-code~
                              ,ub.c-bar-code-attr.corr-user-db-num~
                              ,ub.c-bar-code-attr.chip-num~
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