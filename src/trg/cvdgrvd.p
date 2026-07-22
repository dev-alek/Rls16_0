block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление в таблице ИСТОРИЯ ВАРИАНТОВ ДОСТАВКИ ПО ГРУППАМ СРОКОВ ГОДНОСТИ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/04
Author: Bakhtadze Natalya
Creation date: 03/24/04

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-var-deliv-gr-per-val.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление в таблице ИСТОРИЯ ВАРИАНТОВ ДОСТАВКИ ПО ГРУППАМ СРОКОВ ГОДНОСТИ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7', ub.c-var-deliv-gr-per-val.deliv-type-code,
                                                ub.c-var-deliv-gr-per-val.deliv-subj-code,
                                              ub.c-var-deliv-gr-per-val.obj-type,
                                              ub.c-var-deliv-gr-per-val.obj-code,
                                              ub.c-var-deliv-gr-per-val.gr-per-val-code,
                                              ub.c-var-deliv-gr-per-val.corr-user-db-num,
                                              ub.c-var-deliv-gr-per-val.chip-num
                                              ) " }


main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ ВАРИАНТОВ ДОСТАВКИ ПО ГРУППАМ СРОКОВ ГОДНОСТИ"
  view-as alert-box error .
  undo main-block, return error .


end.



