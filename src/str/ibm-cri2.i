/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

часть послеобработки чека для оплат

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*проверим суммы из воздуха*/

FOR EACH t-pay No-LOCK WHERE
          t-pay.drc = recid({1}):
  if t-pay.tot-rubl <> 0
  or t-pay.tot-base <> 0
  then do:
    IF ((v-curr-r-b = {&r-b-rubl}
        and
        t-pay.tot-rubl < 0)
       AND ({1}.netto > 0)
      )
   OR
   ((v-curr-r-b = {&r-b-base}
      and
      t-pay.tot-base < 0)
      AND ({1}.netto > 0)
    )
    or
   ((v-curr-r-b = {&r-b-rubl}
      and
      t-pay.tot-rubl > 0)
      AND ({1}.netto < 0)
    )
    or
   ((v-curr-r-b = {&r-b-base}
      and
      t-pay.tot-base > 0)
      AND ({1}.netto < 0)
    )
    or
    ((t-pay.tot-rubl >= 0) <> (t-pay.tot-base >= 0))
   then do:
      assign
      for-chk-type = for-chk-type + {&pay-err} + {&comma-char}
      {1}.correct = no
      .
      run write-log-and-file in {2} (
            input 1
          , input log-file-name
          , input 1
          , input substitute(
                              "!!!Чек &1 - ошибочный&2" +
                              "По платежу с кодом &3, с &4 строками оплат чека, имеются несоответствия количества и суммы" +
                              "&5 либо имеются несоответствия типа чека (продажа/возврат) знаку суммы платежа"
                              , chk-doc.doc-code
                              , {&new-line}
                              , t-pay.pay-code
                              , t-pay.num-lines
                              , {&new-line}
                            )
                                            ).

    &if "{2}" = "LEAVE" &then
        LEAVE.
    &endif
    END.
  END. /*if t-pay.tot-rubl <> 0 */
END.

/* $Workfile$ e n d */