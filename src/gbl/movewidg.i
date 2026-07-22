/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/06/10
Author: Bakhtadze Natalya
Creation date: 04/06/10

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


procedure movewidg_up-down :
define input parameter p-fh as widget-handle no-undo .
/*это ghandle щкна*/
define input parameter p-widget-name as character no-undo .
define input parameter p-move-rows as decimal no-undo .
define variable v-ii as integer no-undo .
define variable v-h as handle no-undo .
define variable v-gh as handle no-undo .
define variable v-lh as handle no-undo .
define variable v-widget-handles as character no-undo .
define variable v-widget-labels as character no-undo .

assign
v-gh = p-fh:first-child
v-widget-handles = fill( {&comma-char}, num-entries(p-widget-name) - 1)
v-widget-labels = fill( {&comma-char}, num-entries(p-widget-name) - 1)
.

do while valid-handle(v-gh):
  v-h = v-gh:first-child.
  do while valid-handle(v-h):
    if lookup(v-h:name, p-widget-name) > 0 then do:
      assign
      entry(lookup(v-h:name, p-widget-name), v-widget-handles) = string(v-h)
      .
      if lookup(v-h:type, "COMBO-BOX,EDITOR,FILL-IN,RADIO-SET,SELECTION-LIST,SLIDER,TEXT") > 0
      and  valid-handle(v-h:side-label-handle) then do:
        assign
        entry(lookup(v-h:name, p-widget-name), v-widget-labels) = string(v-h:side-label-handle)
        .
      end.
    end.
    v-h = v-h:next-sibling.
  end. /*do while valid-handle(v-h):*/
  v-gh = v-gh:next-sibling.
end. /*do while valid-handle(v-gh):*/
do v-ii = 1 to num-entries(p-widget-name):
  assign
  v-h = widget-handle(entry(v-ii, v-widget-handles))
  v-lh = (if entry(v-ii, v-widget-labels) <> ''
          then widget-handle(entry(v-ii, v-widget-labels))
          else ?)
  .
  if valid-handle(v-h) then do:
    assign
    v-h:row = v-h:row + p-move-rows
    .
  end.
  if valid-handle(v-lh) then do:
    assign
    v-lh:row = v-lh:row + p-move-rows
    .
  end.
end.

end procedure. /* movewidg_up-down */