/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функция описания итога среза

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/13/08
Author: Bakhtadze Natalya
Creation date: 06/13/08

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION proprefd_sum-id-des RETURNS CHARACTER
  ( INPUT p-sum-id AS CHARACTER, INPUT p-ref-type AS CHARACTER ) :

CASE p-ref-type:
    WHEN {&sum-id-type-one-ptrl} THEN DO:
       DEFINE BUFFER buf_goods FOR ub.goods.
       FIND FIRST buf_goods NO-LOCK WHERE
                 buf_goods.gds-code = integer(ENTRY(2, p-sum-id, "-")) NO-ERROR.
       IF NOT AVAILABLE buf_goods  THEN DO:
           RETURN "Неизвестное топливо".
       END.
       RETURN buf_goods.gds-name.
    END.
    OTHERWISE DO:
       RETURN "".
    END.
END CASE.
END FUNCTION.

FUNCTION proprefd_sum-id-des2 RETURNS CHARACTER
  ( INPUT p-sum-id AS CHARACTER, INPUT p-ref-type AS CHARACTER ) :

CASE p-ref-type:
    WHEN {&sum-id-type-one-ptrl} THEN DO:
       DEFINE BUFFER buf_goods FOR ub.goods.
       FIND FIRST buf_goods NO-LOCK WHERE
                 buf_goods.gds-code = integer(ENTRY(2, p-sum-id, "-")) NO-ERROR.
       IF NOT AVAILABLE buf_goods  THEN DO:
           RETURN "Неизвестное топливо".
       END.
       RETURN buf_goods.gds-name.
    END.
    OTHERWISE DO:
       RETURN p-sum-id.
    END.
END CASE.
END FUNCTION.



/* $Workfile$ e n d */