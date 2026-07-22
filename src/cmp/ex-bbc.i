/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

обработка бар-кода для списка

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/09/05
Author: Bakhtadze Natalya
Creation date: 02/09/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE ex-bbc :
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-empty-scale as logical no-undo .
define input parameter p-b-str as character no-undo .
define input parameter p-is-loc-ean as logical no-undo .

define parameter buffer buf_bar-code for ub.bar-code.
define parameter buffer buf_prod-bc for ub.prod-bc.

define variable v-f-name like ub.gds-prt.f-name no-undo .
define buffer buf_gds-prt for ub.gds-prt.
if available buf_prod-bc then
p-b-str = buf_prod-bc.b-str.
if rs-list-method begins "single":U or
  (ub.goods.stts = 0  and rs-status <> {&deleted}) or
  (ub.goods.stts <> 0 and rs-status <> {&current}) then do:
  if line-mode = {&deletion} or line-mode = {&leave} then do:
    find first {1} where {1}.gds-code  = ub.goods.gds-code
                     and {1}.b-code    = buf_bar-code.b-code
                     and {1}.b-str     = p-b-str  no-error.
    if available {1} then do:
      if line-mode = {&deletion} then do:
        lns-cnt = lns-cnt + 1.
        delete {1}.
      end.
      else do:
        if {1}.to-del = ? then.
        else do:
          lns-cnt = lns-cnt + 1.
          {1}.to-del = ?.
        end.
      end.
    end.
  end.
  else
    if line-mode = {&add-def} then do:
      if p-empty-scale then  do:

      end.
      else do:
        find first buf_gds-prt no-lock where
                  buf_gds-prt.node-code = buf_bar-code.node-code no-error.
        if not available buf_gds-prt then v-f-name = "!!!Неизвестный признак шкалы".
        else v-f-name = buf_gds-prt.f-name.
      end.
      { cmp/bb-list.i {1} assign ub.goods buf_bar-code buf_prod-bc p-b-str v-f-name p-is-loc-ean }
    end.
  &if "{2}" <> "abc" &then
  if lns-cnt modulo 25 = 0 then
  &endif
  disp "ЖДИТЕ...    Обработано кодов :" + string (lns-cnt) @ dsp-rs with frame {2}.
end.
else
assign
lns-ignore = lns-ignore + 1
.
end.

/* $Workfile$ e n d  */