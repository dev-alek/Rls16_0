/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Приемав новостях правил расписаний

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :

  { nws/imps-nws.i rec-full }

  assign
    rec-name = entry( 1, rec-full, {&delim-nws} )
    .

  {&test-count}

  CASE rec-name :
    when "dis-time-rule" then do:
      create locb1-dis-time-rule.
      { nws/impl-nws.i "dis-time-rule" "locb1-" }
    end.

    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе истории чека"
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.


if not available tb-dis-time-rule then do:
  create tb-dis-time-rule.
end.
/* обновляем документ */
buffer-copy wt-dis-time-rule to tb-dis-time-rule.


/* ------------------------------- dis-time-rule --------------------------------------------- */
if wt-dis-time-rule.time-rule-num > {&max-num-dr-template} then do:

for each buf1_dis-time-rule where
        buf1_dis-time-rule.upper-time-rule-num = wt-dis-time-rule.time-rule-num
on error  undo, return error
:
    if wt-dis-time-rule.upper-time-rule-num <> {&dtr-templates-shift} then do:
  delete buf1_dis-time-rule.
end.
  end.
for each locb1-dis-time-rule where
        locb1-dis-time-rule.upper-time-rule-num = wt-dis-time-rule.time-rule-num
     no-lock
on error  undo, return error
:
    find first buf1_dis-time-rule exclusive-lock where
              buf1_dis-time-rule.time-rule-num = locb1-dis-time-rule.time-rule-num no-error.
    if not available buf1_dis-time-rule then do:
  create buf1_dis-time-rule.
    end.
  buffer-copy locb1-dis-time-rule to buf1_dis-time-rule.
end.
end.

/* ------------------------ почистим за собой ---------------------------------------------- */

for each locb1-dis-time-rule
on error  undo, return error
:
  delete locb1-dis-time-rule.
end.

/* $Workfile$ e n d */