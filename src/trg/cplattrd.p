block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории атрибута складского места

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/15/06
Author: Bakhtadze Natalya
Creation date: 02/15/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-place-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории атрибута складского места".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                        , ub.c-place-attr.obj-type
                        , ub.c-place-attr.obj-code
                        , ub.c-place-attr.pl-code
                        , ub.c-place-attr.attr-code
                        , ub.c-place-attr.corr-user-db-num
                        , ub.c-place-attr.chip-num
                        ) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ АТРИБУТА СКЛАДСКОГО МЕСТА"
  view-as alert-box error .
  undo main-block, return error .

end.