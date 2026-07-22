block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории типов кассовых платежей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/06/04
Author: Bakhtadze Natalya
Creation date: 04/06/04

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-cash-pay.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории типов кассовых платежей" .
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8|&9',  ub.c-cash-pay.cdpay-code
                                          , ub.c-cash-pay.curr-code
                                          , ub.c-cash-pay.host-code
                                          , ub.c-cash-pay.obj-type
                                          , ub.c-cash-pay.obj-code
                                          , ub.c-cash-pay.attr-code
                                          , ub.c-cash-pay.corr-user-db-num
                                          , ub.c-cash-pay.chip-num
                                          , ub.c-cash-pay.subject
                                          ) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ типов кассовых платежей"
  view-as alert-box error .
  undo main-block, return error .

end.