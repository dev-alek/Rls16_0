block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории СКИДОК ПО ТИПУ ДИСКОНТНОЙ КАРТЫ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/20/06
Author: Bakhtadze Natalya
Creation date: 12/20/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-dis-dct-rule.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории СКИДОК ПО ТИПУ ДИСКОНТНОЙ КАРТЫ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8|&9'
                         , ub.c-dis-dct-rule.emitent-host-code
                         , ub.c-dis-dct-rule.type
                         , ub.c-dis-dct-rule.host-code
                        , ub.c-dis-dct-rule.obj-type  + string(ub.c-dis-dct-rule.obj-code)
                        , ub.c-dis-dct-rule.pos-type
                        , ub.c-dis-dct-rule.discnt-role
                        , ub.c-dis-dct-rule.nonunique
                        , ub.c-dis-dct-rule.corr-user-db-num
                        , ub.c-dis-dct-rule.chip-num
                         ) " }
{ cmp/trg-def.i  }
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ СКИДОК ПО ТИПУ ДИСКОНТНОЙ КАРТЫ"
  view-as alert-box error .
  undo main-block, return error .

end.