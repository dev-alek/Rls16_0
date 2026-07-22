block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории атрибута товара на складском месте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/15/06
Author: Bakhtadze Natalya
Creation date: 02/15/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-pl-gds-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории атрибута товара на складском месте".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7'
                        , ub.c-pl-gds-attr.obj-type
                        , ub.c-pl-gds-attr.obj-code
                        , ub.c-pl-gds-attr.pl-code
                        , ub.c-pl-gds-attr.gds-code
                        , ub.c-pl-gds-attr.attr-code
                        , ub.c-pl-gds-attr.corr-user-db-num
                        , ub.c-pl-gds-attr.chip-num
                        ) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ АТРИБУТА ТОВАРА НА СКЛАДСКОМ МЕСТЕ"
  view-as alert-box error .
  undo main-block, return error .

end.