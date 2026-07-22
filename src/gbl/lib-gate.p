/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: lib-gate.p $
$Archive: gbl/lib-gate.p $

Библиотека процедур для работы GATE

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/07/09
Author: Bakhtadze Natalya
Creation date: 10/07/09

*/

using Ibs.Th.Rul.Route-data_.
block-level on error undo, throw.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: lib-gate.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/lib-gate.p $":U .
define variable vss-description as character no-undo initial "Библиотека процедур для работы GATE":U .

{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/lib-gate.i }
{ rul/tempcxml.i }
/*вдруг кто неправильно вызовет*/
{ rul/garbcoll.i }

if valid-handle (g#lib-gate)
and g#lib-gate <> this-procedure :handle
and g#lib-gate :get-signature('lib-gate_clear-fill-option':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки для работы с GATE" skip
    g#lib-gate skip
    g#lib-gate :type skip
    g#lib-gate :file-name skip
    valid-handle(g#lib-gate) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#lib-gate = this-procedure :handle
  .
end.

define temp-table temp-gate no-undo
field gate-handle_ as handle
field uniq-gate-rec as character
field schema-name as character
field gate-name as character
index pi is unique primary
uniq-gate-rec
index ischema-name
schema-name
.


define stream outstream .
define variable v-route-data_ as class Route-data_ no-undo .

on delete of this-procedure do:
  run lib-gate_clear-gates in this-procedure .
  assign
  g#lib-gate = ?
  .
end.


procedure lib-gate_gate-start :
define output parameter p-lb-handle as handle no-undo .
p-lb-handle = this-procedure:handle.
return ''.
end procedure. /* lib-date_init */

procedure lib-gate_clear-gates:
define buffer buf_temp-gate for temp-gate.
do
on error undo, return error return-value
:
  for each buf_temp-gate where
  on error undo, return error :
    run gate-clear in this-procedure ( input buf_temp-gate.gate-handle_
                                      ,input buffer temp-xml-tables:handle
                                       ) no-error.
    delete buf_temp-gate.
  end.
  if valid-object(v-route-data_) then do:
    delete object v-route-data_.
  end.
end.
end procedure. /* lib-nws_clear-fill-option */


procedure lib-gate_route-data_ :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-gc-handle  as handle no-undo .
define output parameter p-route-data_ as class Route-data_ no-undo .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

if not valid-object(v-route-data_) then do:
  &scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input p-gc-handle, input this-procedure:handle)
  v-route-data_ = new Route-data_{&constructor_1} .
  p-route-data_ = v-route-data_.

end.
else do:
  v-route-data_:route-data_init ( input parparentproc, input p-parent-handle, input p-log-handle, input p-gc-handle, input this-procedure:handle).
  v-route-data_:route-data_clear-data().
  p-route-data_ = v-route-data_.
end.
end.
end procedure. /* lib-gate_route-data_ */

procedure lib-gate_display-gates :
define input parameter p-file-name as character no-undo .

do
on error undo, return error
:
  if p-file-name <> '' then do:
    output stream outstream to value(p-file-name).
    for each temp-gate:
      put stream outstream unformatted
      temp-gate.uniq-gate-rec {&space-char}
      temp-gate.schema-name {&space-char}
      string(temp-gate.gate-handle)
      skip.

    end.
    put stream outstream skip(2).
    for each temp-xml-tables:
      put stream outstream unformatted
      temp-xml-tables.order {&space-char}
      temp-xml-tables.tbl-name {&space-char}
      temp-xml-tables.gate-name {&space-char}
      skip.

    end.
    if valid-object(v-route-data_) then do:
      put stream outstream unformatted
      "route-data_" {&space-char} v-route-data_:name_ skip.
    end.

    output stream outstream close.
  end.
end.

end procedure. /* lib-gate_display-gates */


{ gbl/gate-clb.i lib-gate }

