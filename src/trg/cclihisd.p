block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории КЛИЕНТА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 21/01/04
Author: Bakhtadze Natalya
Creation date: 21/01/04

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-cli-hist.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление главной записи истории КЛИЕНТА".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                        ,  ub.c-cli-hist.obj-type
                        , ub.c-cli-hist.obj-code
                        , ub.c-cli-hist.corr-user-db-num
                        , ub.c-cli-hist.chip-num
                        , ub.c-cli-hist.host-code
                        , ub.c-cli-hist.subject
                        ) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять главную запись ИСТОРИИ КЛИЕНТА"
  view-as alert-box error .
  undo main-block, return error .

end.
