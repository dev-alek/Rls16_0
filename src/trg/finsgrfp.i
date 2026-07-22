/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка в соответствии с типом и расширенным типом выписки при переходе по статусам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/18/03
Author: Bakhtadze Natalya
Creation date: 11/18/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

do on error undo, return error return-value :
  CASE p-fins-doc-type:
    when {&standard-sttm} then do:
      CASE P-status-current:
        when {&fin-new} then do:
          {&standard-sttm-new}
        end.
        when {&fin-bank} then do:
          {&standard-sttm-bank}
        end.
        otherwise do:
           return error substitute ("Недопустимый тип-статус &1-&2.", p-fins-doc-type, p-status-current).
        end.
      END CASE.
    end. /*when standard-sttm*/
    otherwise do:
        return error substitute ("Недопустимый тип-статус &1-&2.", p-fins-doc-type, p-status-current).
    end.
  END CASE.
end.




/* $Workfile$ e n d */