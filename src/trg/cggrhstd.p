block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление главной записи истории групп товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 23/08/04
Author: Bakhtadze Natalya
Creation date: 23/08/04

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-gds-grp-hist.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление галвной записи истории групп товаров".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                        ,  ub.c-gds-grp-hist.node-code
                        , ub.c-gds-grp-hist.corr-user-db-num
                        , ub.c-gds-grp-hist.chip-num
                        , ub.c-gds-grp-hist.host-code
                        , ub.c-gds-grp-hist.obj-type
                        , ub.c-gds-grp-hist.obj-code
                        , ub.c-gds-grp-hist.subject

                        ) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять главную запись ИСТОРИИ ГРУПП ТОВАРОВ"
  view-as alert-box error .
  undo main-block, return error .

end.

