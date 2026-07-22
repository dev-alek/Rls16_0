block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории привязки правила скидки к ресурсу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/25/07
Author: Bakhtadze Natalya
Creation date: 05/25/07

*/


TRIGGER PROCEDURE FOR DELETE OF ub.c-dis-some-rule.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление привязки правила скидки к ресурсу".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8|&9'
                        ,  ub.c-dis-some-rule.classif-type
                        ,  ub.c-dis-some-rule.resource#_id
                        ,  ub.c-dis-some-rule.host-code
                        ,  ub.c-dis-some-rule.obj-type + string(ub.c-dis-some-rule.obj-code)
                        ,  ub.c-dis-some-rule.pos-type
                        ,  ub.c-dis-some-rule.discnt-role
                        ,  ub.c-dis-some-rule.nonunique
                        ,  ub.c-dis-some-rule.corr-user-db-num
                        ,  ub.c-dis-some-rule.chip-num
                        ) " }

{ cmp/str-glbl.i }


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  message
  vss-workfile vss-revision vss-description skip
  "Физическое удаление истории правизки правила скидки к ресурсу ЗАПРЕЩЕНО"
  view-as alert-box error .
  undo main-block, return error .

end.

