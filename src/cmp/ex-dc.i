/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

обработка карты для списка

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/18/05
Author: Bakhtadze Natalya
Creation date: 12/18/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE ex-dc :
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .

if rs-list-method = "single":U or
  (ub.dis-card.status_ = {&current-status} and (rs-status = {&current-status} or rs-status = {&all})) or
  (ub.dis-card.status_ = {&deleted-status} and (rs-status = {&deleted-status} or rs-status = {&all})) or
  (ub.dis-card.status_ = {&blocked-status} and (rs-status = {&blocked-status} or rs-status = {&all}))
  then do:
  if line-mode = {&deletion} or line-mode = {&leave} then do:
    find first {1} where
               {1}.d-card = ub.dis-card.d-card no-error.
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
      { cmp/dc-list.i {1} assign }
    end.
  &if "{2}" <> "abc" &then
  if lns-cnt modulo 25 = 0 then
  &endif
  disp "Ждите..." + string (lns-cnt) @ dsp-rs with frame {2}.
end.
end.

/* $Workfile$ e n d */