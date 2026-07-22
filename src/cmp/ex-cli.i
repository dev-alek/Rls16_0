/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

обработка клиента для списка

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/24/05
Author: Bakhtadze Natalya
Creation date: 12/24/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE ex-cli :
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .

if rs-list-method = "single":U or
  (ub.clients.stts = 0  and rs-status <> {&deleted}) or
  (ub.clients.stts <> 0 and rs-status <> {&current}) then do:
  if line-mode = {&deletion} or line-mode = {&leave} then do:
    find first {1} where
               {1}.obj-type = ub.clients.obj-type AND
               {1}.obj-code = ub.clients.obj-code no-error.
    if available {1} then do:
      if line-mode = {&deletion} then do:
        lns-cnt = lns-cnt + 1.
        delete {1}.
      end.
      else do:
        if {1}.to-del = ? then .
        else do:
           lns-cnt = lns-cnt + 1.
           {1}.to-del = ?.
        end.
      end.
    end.
  end.
  else
    if line-mode = {&add-def} then do:
      { cmp/cli-list.i {1} assign }
    end.
  &if "{2}" <> "abc" &then
  if lns-cnt modulo 25 = 0 then
  &endif
  disp "Ждите..." + string (lns-cnt) @ dsp-rs with frame {2}.
end.
else
assign
lns-ignore = lns-ignore + 1
.
end.

/* $Workfile$ e n d */