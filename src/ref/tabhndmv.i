/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

переход по TAB с использованием списка имен виджетов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/27/03
Author: Bakhtadze Natalya
Creation date: 11/27/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

ON TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if {1} <> '' then do:
  if self:type = "TOGGLE-BOX" then
  self:BGCOLOR = ?.
  assign
  ii = lookup(self:name, {1}).
  assign
  ii = ii + 1
  v-next-widget-name = entry(ii, {1})
  no-error .
  if error-status:error then do:
    assign
    ii = 1
    v-next-widget-name = entry( ii, {1})
    .
  end.
  assign
  fh = frame {&frame-name}:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        &if "{2}" = "UNDERLINE-TB" &then
        if hh:type = "TOGGLE-BOX":U then do:
          assign
          hh:BGcolor = 1
          .
        end.
        &endif
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
        APPLY "TAB" to hh.
        return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end. /*do while*/
end.
END.


ON BACK-TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if {1} <> '' then do:
  assign
  ii = lookup(self:name, {1}).
  .
  assign
  ii = (if ii = 1
        then  num-entries({1})
        else ii - 1
        )
  v-next-widget-name = entry(ii, {1})
  .
  assign
  fh = frame {&frame-name}:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
      &if "{2}" = "UNDERLINE-TB" &then
        if hh:type = "TOGGLE-BOX":U then do:
          assign
          hh:BGcolor = 1
          .
        end.
        &endif
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
      APPLY "BACK-TAB" to hh.
      return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end. /*do while*/
  end.
END.


/* $Workfile$ e n d */