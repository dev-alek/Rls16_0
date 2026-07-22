block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cli-fill.p $
$Archive: gbl/cli-fill.p $

Фильтр в списке клиентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/24/05
Author: Bakhtadze Natalya
Creation date: 12/24/05

*/

define input parameter  par-run-name as character no-undo .
define input parameter  RS-list-method  as character no-undo .
define input parameter  RS-status as character no-undo .
define input parameter  line-mode as character no-undo .
define input parameter  p-filter-var as character no-undo .
define output parameter lns-cnt as integer no-undo .
define output parameter line-rec as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cli-fill.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/cli-fill.p $":U .
define variable vss-description as character no-undo init "Фильтр в списке клиентов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

{ cmp/cli-list.i cli-list def shared }
define variable dsp-rs     as character format "x(50)" no-undo.
define variable lns-ignore as integer no-undo .
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
define query cli-fill for ub.clients.
define frame abc
dsp-rs no-label
with view-as dialog-box SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
TITLE par-run-name.
view frame abc.
display dsp-rs
with frame abc.
v-prepare-string = "for each clients where true " + p-filter-var .
glog = query cli-fill:handle:query-prepare(v-prepare-string) no-error.
if not glog
or error-status:error then do:
  message
  substitute("Ошибка при заполнении по фильтру&1:&2&1Выражение для Фильтра:&1&3"
             , {&new-line}
             , error-status:get-message(1)
             , p-filter-var)
  view-as alert-box error .
  undo, return error .
end.

glog = query cli-fill:handle:query-open() no-error.
if not glog
or error-status:error then do:
  message
  substitute("Ошибка при заполнении по фильтру&1:&2&1Выражение для Фильтра:&1&3"
             , {&new-line}
             , error-status:get-message(1)
             , p-filter-var)
  view-as alert-box error .
  undo, return error .
end.

REPEAT WITH FRAME abc:
  query cli-fill:handle:GET-NEXT().
  IF query cli-fill:handle:QUERY-OFF-END THEN LEAVE.
  process events.
  run ex-cli in this-procedure (input rs-list-method, input rs-status, input line-mode).
end.
glog = query cli-fill:handle:query-close() no-error.
hide frame abc.
{ cmp/ex-cli.i cli-list abc }