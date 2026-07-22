block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории смены

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/09/05
Author: Bakhtadze Natalya
Creation date: 08/09/05

*/


TRIGGER PROCEDURE FOR DELETE OF ub.c-shift-obj.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории смены".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                            , ub.shift-staff.obj-type
                            , ub.shift-staff.obj-code
                            , ub.shift-staff.shift-date
                            , ub.shift-staff.shift-num
                            ) " }
{ cmp/trg-def.i }

main-block :
do transaction
on error undo main-block, return error return-value
:


 if not (g#news
      and g#db-num = 0
      and ub.c-shift-obj.corr-user-db-num = g#news-source-db
      ) then do:
  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись истории смены"
  view-as alert-box error .
  undo main-block, return error .
  end.
end.