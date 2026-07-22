/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

переход по return с использованием списка имен виджетов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/27/03
Author: Bakhtadze Natalya
Creation date: 11/27/03

{1} список widget
{2} ключевое словое UNDERLINE-TAB
{3} действие которое надо предпринять на последнем widget

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

ON RETURN ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
  if {1} <> '' then do:
    assign
    ii = lookup(self:name, {1}).
    if ii = num-entries({1}) then do:
      /*это последний widget*/
      &if "{3}" <> "GO" &then
        {3}
        return no-apply.
      &endif
    end.
    if self:type <> "BUTTON" and
      self:type <> "EDITOR"  then do:
      run proc-move-forward in this-procedure .
      return no-apply.
    end.
    if self:type = "BUTTON" then do:
      APPLY "CHOOSE" to self.
    end.
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
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

procedure proc-move-forward :
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
do
on error undo, return error
:
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
          return.
        end.
        else do:
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
        end.
      end.
      hh = hh:next-sibling.
    end. /*do while*/
  end.
end.

end procedure. /* proc-move-forward */



/* $Workfile$ e n d */