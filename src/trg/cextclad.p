block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление c-ext-classif

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/04/04
Author: Bakhtadze Natalya
Creation date: 12/04/04

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-ext-classif.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление c-ext-classif".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8|&9'
                        , ub.c-ext-classif.classif-subject
                        , ub.c-ext-classif.classif-name
                        , ub.c-ext-classif.key#_one
                        , ub.c-ext-classif.key#_two
                        , ub.c-ext-classif.key#_three
                        , ub.c-ext-classif.charkey_one
                        , ub.c-ext-classif.charkey_two
                        , ub.c-ext-classif.charkey_three
                        , ub.c-ext-classif.nonunique
                        ) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error return-value
:
  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ ВНЕШНИХ КЛАССИФИКАТОРОВ"
  view-as alert-box error .
  undo main-block, return error .

end.