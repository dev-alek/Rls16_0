block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггуре на удаление истории товаров на принтерах кухни

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/11/05
Author: Bakhtadze Natalya
Creation date: 08/11/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-fbr-prn-gds.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории товаров на принтерах кухни".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7'
                           , ub.c-fbr-prn-gds.db-num
                           , ub.c-fbr-prn-gds.prn-num
                           , ub.c-fbr-prn-gds.obj-type
                           , ub.c-fbr-prn-gds.obj-code
                           , ub.c-fbr-prn-gds.gds-code
                           , ub.c-fbr-prn-gds.corr-user-db-num
                           , ub.c-fbr-prn-gds.chip-num
                           ) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись истории товаров на принтерах кухни"
  view-as alert-box error .
  undo main-block, return error .

end.