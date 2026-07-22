block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории элемента раскладки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/26/08
Author: Bakhtadze Natalya
Creation date: 09/26/08

*/


TRIGGER PROCEDURE FOR DELETE OF ub.c-layout-elem.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории элемента раскладки".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                         , ub.c-layout-elem.layout-type
                         , ub.c-layout-elem.device-type
                         , ub.c-layout-elem.mode-id
                         , ub.c-layout-elem.widget-id
                         , ub.c-layout-elem.corr-user-db-num
                         , ub.c-layout-elem.chip-num
                         ) " }

{ cmp/trg-def.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  message
    vss-workfile vss-revision vss-description skip
    "Физическое удаление истории элемента раскладки в системе запрещено" skip
    view-as alert-box error .
  undo main-block, return error.
end.