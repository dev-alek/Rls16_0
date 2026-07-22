/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка в соответствии с типом и расширенным типом фин документа при переходе по статусам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/18/03
Author: Bakhtadze Natalya
Creation date: 11/18/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

do on error undo, return error return-value :
  CASE p-fin-doc-type:
    when {&income-cash} then do:
      CASE P-status-current:
        when {&fin-new} then do:
          {&income-cash-new}
        end.
        when {&fin-permitted} then do:
          {&income-cash-permitted}
        end.
        when {&fin-bank} then do:
           return error substitute ("Недопустимый тип-статус &1-&2.", p-fin-doc-type, p-status-current).
        end.
      END CASE.
    end.
    when {&income-cashless} then do:
      CASE P-status-current:
        when {&fin-new} then do:
          {&income-cashless-new}
        end.
        when {&fin-permitted} then do:
          {&income-cashless-permitted}
        end.
        when {&fin-bank} then do:
          {&income-cashless-bank}
        end.
      END CASE.
    end.
    when {&income-payoff} then do:
      CASE P-status-current:
        when {&fin-new} then do:
          {&income-payoff-new}
        end.
        when {&fin-permitted} then do:
          {&income-payoff-permitted}
        end.
        when {&fin-bank} then do:
           return error substitute ("Недопустимый тип-статус &1-&2.", p-fin-doc-type, p-status-current).
        end.
      END CASE.
    end.
    when {&expense-cash} then do:
      CASE P-status-current:
        when {&fin-new} then do:
          {&expense-cash-new}
        end.
        when {&fin-permitted} then do:
          {&expense-cash-permitted}
        end.
        when {&fin-bank} then do:
           return error substitute ("Недопустимый тип-статус &1-&2.", p-fin-doc-type, p-status-current).
        end.
      END CASE.
    end.
    when {&expense-cashless} then do:
      CASE P-status-current:
        when {&fin-new} then do:
          {&expense-cashless-new}
        end.
        when {&fin-permitted} then do:
          {&expense-cashless-permitted}
        end.
        when {&fin-bank} then do:
           {&expense-cashless-bank}
        end.
        when {&fin-rejected} then do:
           {&expense-cashless-rejected}
        end.
      END CASE.
    end.
    when {&expense-payoff} then do:
      CASE P-status-current:
        when {&fin-new} then do:
          {&expense-payoff-new}
        end.
        when {&fin-permitted} then do:
          {&expense-payoff-permitted}
        end.
        when {&fin-bank} then do:
           return error substitute ("Недопустимый тип-статус &1-&2.", p-fin-doc-type, p-status-current).
        end.
      END CASE.
    end.
  END CASE.
END.




/* $Workfile$ e n d */