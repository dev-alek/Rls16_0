/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Формирование списка товаров по фильтру - общая часть для gds-list и scn-list

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/06/08
Author: Bakhtadze Natalya
Creation date: 03/06/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ cmp/gds-list.i {1} def shared }

define variable dsp-rs as char format "x(50)" no-undo.
define variable lns-ignore as integer no-undo .
define variable glog as logical no-undo .
define variable v-prepare-string as character no-undo .
define query gds-fill for ub.clients, ub.goods, ub.gds-prt.
def frame abc
dsp-rs no-label
with view-as dialog-box SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
TITLE par-run-names.
view frame abc.
disp dsp-rs with frame abc.

v-prepare-string = "for each clients, each goods where clients.obj-type = goods.prod-type and clients.obj-code = goods.prod-code " +
                   p-filter-var  +
                   ", first gds-prt where gds-prt.upper-code = goods.prt-root".
glog = query gds-fill:handle:query-prepare(v-prepare-string) no-error.
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

glog = query gds-fill:handle:query-open() no-error.
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
  query gds-fill:handle:GET-NEXT().

  IF query gds-fill:handle:QUERY-OFF-END THEN LEAVE.
  process events.
  run ex-gds in this-procedure ( buffer goods, input rs-list-method, input rs-status, input line-mode).
end.
glog = query gds-fill:handle:query-close() no-error.
hide frame abc.
{ cmp/ex-gds.i {1} abc }


/* $Workfile$ e n d */