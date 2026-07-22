/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Формирование списка кодов по фильтру - общая часть для bb-list и scnblist

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/11/09
Author: Bakhtadze Natalya
Creation date: 12/11/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ cmp/bb-list.i {1} def shared }

define variable dsp-rs as char format "x(50)" no-undo.
define variable lns-ignore as integer no-undo .
define variable glog as logical no-undo .
define variable v-prepare-string as character no-undo .
define query bb-fill for ub.bar-code, ub.goods.
def frame abc
dsp-rs no-label
with view-as dialog-box SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
TITLE par-run-names.
view frame abc.
disp dsp-rs with frame abc.

v-prepare-string = "for each ub.bar-code no-lock where true " +
                   p-filter-var  + ", first ub.goods no-lock where ub.goods.gds-code = ub.bar-code.gds-code ".

glog = query bb-fill:handle:query-prepare(v-prepare-string) no-error.
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

glog = query bb-fill:handle:query-open() no-error.
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
  query bb-fill:handle:GET-NEXT().

  IF query bb-fill:handle:QUERY-OFF-END THEN LEAVE.
  process events.
  run ex-bbc in this-procedure (input rs-list-method
                               , input rs-status
                               , input line-mode
                               , input no
                               , input "":U
                               , input no
                               , buffer ub.bar-code
                               , buffer ub.prod-bc).
end.
glog = query bb-fill:handle:query-close() no-error.
hide frame abc.
{ cmp/ex-bbc.i {1} abc }


/* $Workfile$ e n d */