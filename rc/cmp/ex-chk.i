/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка чека для списка

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/20/05
Author: Bakhtadze Natalya
Creation date: 12/20/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE ex-chk :
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .

define variable v-process as logical no-undo .
define variable v-start-date as date no-undo .
define variable v-end-date as date no-undo .


&scop process-chk-doc  rs-list-method = "single":U or ~
          (rs-status = ~{&all~} ~
           or ~
           (chk-doc.out-code = ? and rs-status = "free":U) ~
           or ~
           (chk-doc.chk-date >= v-start-date and chk-doc.chk-date <= v-end-date and rs-status = "chk-date":U) ~
          )

  CASE entry(1, rs-status, {&delim-par}):
    when "chk-date":U then do:
      ASSIGN
      V-START-DATE = DATE(ENTRY(2, rs-status, {&delim-par}))
      V-END-DATE = DATE(ENTRY(3, rs-status, {&delim-par}))
      rs-status = entry(1, rs-status, {&delim-par})
      .
    end.
  END CASE.

  if line-mode = {&deletion} or line-mode = {&leave} then do:
    find first {1} where
              {1}.doc-code = ub.chk-doc.doc-code
              no-error.
    if available {1} then do:
      if {&process-chk-doc}
      then do:
        assign
        v-process = yes
        .
      end.
      if line-mode = {&deletion} and v-process then do:
        if {1}.doc-code <> v-doc-code then
        lns-cnt = lns-cnt + 1.
        delete {1}.
      end.
      if line-mode = {&leave} and  v-process then do:
        if {1}.to-del = ? then .
        else do:
          if {1}.doc-code <> v-doc-code then
          lns-cnt = lns-cnt + 1.
          assign {1}.to-del = ?.
        end.
      end.
      if not v-process
      and {1}.doc-code <> v-doc-code
      then
      assign
      lns-ignore = lns-ignore + 1
      .
    end.
  end.
  else
    if line-mode = {&add-def} then do:
      if {&process-chk-doc} then do:
        { cmp/chk-list.i {1} assign-chk chk-doc }
      end.
      else assign
      lns-ignore = lns-ignore + 1
      .
    end.
  &if "{2}" <> "abc" &then
  if lns-cnt modulo 25 = 0 then
  &endif
  disp "Ждите..." + string (lns-cnt) @ dsp-rs with frame {2}.

end PROCEDURE.


/* $Workfile$ e n d */