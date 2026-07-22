block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории персонала смены

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/09/05
Author: Bakhtadze Natalya
Creation date: 08/09/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-shift-staff.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории персонала смены".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8'
                            , ub.c-shift-staff.obj-type
                            , ub.c-shift-staff.obj-code
                            , ub.c-shift-staff.shift-date
                            , ub.c-shift-staff.shift-num
                            , ub.c-shift-staff.next-shift
                            , ub.c-shift-staff.psn-num
                            , ub.c-shift-staff.corr-user-db-num
                            , ub.c-shift-staff.chip-num
                            ) " }
{ cmp/trg-def.i }

main-block :
do transaction
on error undo main-block, return error return-value
:
   if not (g#news
      and g#db-num = 0
      and ub.c-shift-staff.corr-user-db-num = g#news-source-db
      ) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя удалять запись истории персонала смены"
    view-as alert-box error .
    undo main-block, return error .
  end.

end.
