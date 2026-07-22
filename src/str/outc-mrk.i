/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Открытие потока - касса IBM

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer locked_cash-desk for ub.cash-desk.

  do transaction
  on error undo, return
  :
    FIND FIRST LOCKED_cash-desk EXCLUSIVE-LOCK WHERE
              LOCKED_cash-desk.obj-code = abs(i-obj-code)
          AND LOCKED_cash-desk.db-num = g#db-num
          AND LOCKED_cash-desk.pos-type = {&cd-type-marketer}
          AND LOCKED_cash-desk.cash-num = 0 NO-WAIT NO-ERROR.
    IF LOCKED locked_cash-desk THEN DO:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("На &1&2 в настоящее время занята запись кассы типа &3&4" +
                              "с номером 0 - кассовый менеджер&4" +
                              "Нельзя работать с товарами на кассе"
                            , {&shop}
                            , abs(i-obj-code)
                            , {&cd-type-marketer}
                            , {&NEW-LINE})
                                         ).
      UNDO, return.
    END.
  END.

/* $Workfile$ e n d */