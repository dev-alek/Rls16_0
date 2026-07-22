block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории СЕЗОННОГО КОЭФФИЦИЕНТА ТОВАРА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 21/01/04
Author: Bakhtadze Natalya
Creation date: 21/01/04

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-s-coeff.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории СЕЗОННОГО КОЭФФИЦИЕНТА ТОВАРА".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7'
                         , ub.c-s-coeff.gds-code
                         , ub.c-s-coeff.host-code
                         , ub.c-s-coeff.obj-type
                         , ub.c-s-coeff.obj-code
                         , ub.c-s-coeff.s-date
                         , ub.c-s-coeff.corr-user-db-num
                         , ub.c-s-coeff.chip-num
                         ) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ СЕЗОННОГО КОЭФФИЦИЕНТА ТОВАРА"
  view-as alert-box error .
  undo main-block, return error .

end.