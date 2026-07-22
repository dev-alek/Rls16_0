block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление звена процесса

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/04/08
Author: Bakhtadze Natalya
Creation date: 07/04/08

*/

TRIGGER PROCEDURE FOR DELETE OF ub.rule-process.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление звена процесса".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                         , ub.rule-process.pchain-type
                         , ub.rule-process.pchain-id
                         , ub.rule-process.start-from
                         , ub.rule-process.link-id
                                                  ) " }

{ cmp/trg-def.i }

define variable v-start-level as integer no-undo .
define variable level as integer no-undo .
define variable v-p as character no-undo .
define variable v-confirmed as logical no-undo .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  assign
  v-start-level = 2
  .
  assign
    level = v-start-level
  .
  _repeat:
  repeat while program-name( level ) <> ? :
    v-p = program-name( level ).
    if substring(v-p, length(v-p) - length("fixrum.p") + 1) = "fixrum.p":U
    or substring(v-p, length(v-p) - length("fixrum.p") + 1) = "fixrum.r":U
    or substring(v-p, length(v-p) - length("rule-process3.p") + 1) = "rule-process3.p":U
    or substring(v-p, length(v-p) - length("rule-process3.p") + 1) = "rule-process3.r":U
    then do:
      v-confirmed = yes.
      leave _repeat.
    end.
    assign
      level = level + 1
    .
  end.
  if not v-confirmed then do:
    message
    vss-workfile vss-revision vss-description skip
    "Физическое удаление звена процесса в системе запрещено" skip
    view-as alert-box error .
    undo main-block, return error .
  end.
end.