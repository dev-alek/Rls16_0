block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории МХ МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 21/01/04
Author: Bakhtadze Natalya
Creation date: 21/01/04

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-wth-place.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории МХ МЦ".
{ cmp/trg-def.i }
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&7'
                           , ub.c-wth-place.host-code
                           , ub.c-wth-place.obj-type
                           , ub.c-wth-place.obj-code
                           , ub.c-wth-place.w-p-code
                           , ub.c-wth-place.corr-user-db-num
                           , ub.c-wth-place.chip-num
                           ) " }



main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись истории МХ МЦ"
  view-as alert-box error .
  undo main-block, return error .

end.