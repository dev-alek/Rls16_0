block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории СКИДКИ ПО ДИСКОНТНОЙ КАРТЕ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/20/06
Author: Bakhtadze Natalya
Creation date: 12/20/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-dis-dc-rule.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории СКИДКИ ПО ДИСКОНТНОЙ КАРТЕ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8|&9'
                         , ub.c-dis-dc-rule.d-card
                        , ub.c-dis-dc-rule.host-code
                        , ub.c-dis-dc-rule.obj-type
                        , ub.c-dis-dc-rule.obj-code
                        , ub.c-dis-dc-rule.pos-type
                        , ub.c-dis-dc-rule.discnt-role
                        , ub.c-dis-dc-rule.nonunique
                        , ub.c-dis-dc-rule.corr-user-db-num
                        , ub.c-dis-dc-rule.chip-num
                         ) " }
{ cmp/trg-def.i  }
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if ub.c-dis-dc-rule.card-num >= 0 then do:
    message
      vss-workfile vss-revision vss-description skip
      "Физическое удаление ИСТОРИИ СКИДОК ПО ДИСКОНТНОЙ КАРТЕ возможно только для НЕИСПОЛЬЗОВАВШИХСЯ карт" skip
      view-as alert-box error .
    undo main-block, return error.
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_c-dis-dc-rule}
        , input ( buffer ub.c-dis-dc-rule:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
  end.
end.

