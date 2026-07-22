/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение наличия выручки по объектам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/18/05
Author: Bakhtadze Natalya
Creation date: 10/18/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE no-benq.
/*определение наличия выручки на объекте за заданный периодл времени*/
DEFINE OUTPUT PARAMETER found as logical init no.
define buffer buf_chk-doc for ub.chk-doc.

FOR EACH obj-list WHERE
        obj-list.obj-type = {&shop} NO-LOCK :
  CASE X-Radio-Task > 1 :
    WHEN YES THEN DO:
      FOR EACH buf_chk-doc NO-LOCK WHERE
              buf_chk-doc.obj-type = obj-list.obj-type AND
              buf_chk-doc.obj-code = obj-list.obj-code AND
              (
                buf_chk-doc.shift-date >= X-date-start AND
                buf_chk-doc.shift-date <= X-date-end)
                AND
                (IF cas-num > 0 then buf_chk-doc.pay-desk = cas-num ELSE TRUE):
        IF X-Radio-Task = 3 AND
        ((buf_chk-doc.shift-date = X-date-start AND buf_chk-doc.shift-num < X-shift-Start) OR
          (buf_chk-doc.shift-date = X-date-end AND  buf_chk-doc.shift-num > X-shift-End) ) THEN NEXT.
        IF X-Radio-Task = 4 AND
        (buf_chk-doc.shift-num <> X-shift-Alone ) THEN NEXT.
        found = yes.
        return.
      END.
    END. /*WHEN YES*/
    WHEN NO THEN DO:
      FOR EACH buf_chk-doc NO-LOCK WHERE
            buf_chk-doc.obj-type = obj-list.obj-type AND
            buf_chk-doc.obj-code = obj-list.obj-code AND
            buf_chk-doc.chk-date >= X-date-start AND
            buf_chk-doc.chk-date <= X-date-end   AND
            (IF cas-num > 0 then buf_chk-doc.pay-desk = cas-num ELSE TRUE):
        found = yes.
        return.
      END.
     END. /*WHEN NO*/
   END CASE.
 END. /*for each obj-list*/
END PROCEDURE.

PROCEDURE no-benqi.
/*определение наличия непривязанных к продаже чеков или незакрытых продаж на объекте за заданный периодл времени*/
DEFINE OUTPUT PARAMETER found as logical init no.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_inkas for ub.inkas.

FOR EACH obj-list WHERE
      obj-list.obj-type = {&shop} NO-LOCK :
  CASE X-Radio-Task > 1 :
    WHEN YES THEN DO:
      FOR EACH buf_chk-doc No-LOCK WHERE
              buf_chk-doc.obj-type = obj-list.obj-type AND
              buf_chk-doc.obj-code = obj-list.obj-code AND
              (
                buf_chk-doc.shift-date >= X-date-start AND
                buf_chk-doc.shift-date <= X-date-end)
                AND
                buf_Chk-doc.out-code = ? AND
                (IF cas-num > 0 then buf_chk-doc.pay-desk = cas-num ELSE TRUE):
        IF X-Radio-Task = 3 AND
        ((buf_chk-doc.shift-date = X-date-start AND buf_chk-doc.shift-num < X-shift-Start) OR
          (buf_chk-doc.shift-date = X-date-end AND  buf_chk-doc.shift-num > X-shift-End) ) THEN NEXT.
        IF X-Radio-Task = 4 AND
        (buf_chk-doc.shift-num <> X-shift-Alone ) THEN NEXT.
        found = yes.
        return.
      END.
      FOR EACH buf_inkas No-LOCK WHERE
                buf_inkas.obj-type = obj-list.obj-type AND
                buf_inkas.obj-code = obj-list.obj-code AND
                (
                buf_inkas.shift-date >= X-date-start AND
                buf_inkas.shift-date <= X-date-end):
        if buf_inkas.status_ = {&fact}
        or buf_inkas.status_ = {&inquiry} then next.
        IF X-Radio-Task = 3 AND
        ((buf_inkas.shift-date = X-date-start AND buf_inkas.shift-num < X-shift-Start) OR
          (buf_inkas.shift-date = X-date-end AND  buf_inkas.shift-num > X-shift-End) ) THEN NEXT.
        IF X-Radio-Task = 4 AND
        (buf_inkas.shift-num <> X-shift-Alone ) THEN NEXT.
        found = yes.
        return.
      END.
    END. /*WHEN YES*/
    WHEN NO THEN DO:
      FOR EACH buf_chk-doc NO-LOCK WHERE
              buf_chk-doc.obj-type = obj-list.obj-type AND
              buf_chk-doc.obj-code = obj-list.obj-code AND
              buf_chk-doc.chk-date >= X-date-start AND
              buf_chk-doc.chk-date <= X-date-end   AND
              buf_Chk-doc.out-code = ? AND
              (IF cas-num > 0 then buf_chk-doc.pay-desk = cas-num ELSE TRUE):
        found = yes.
        return.
      END.
      FOR EACH buf_inkas NO-LOCK WHERE
              buf_inkas.obj-type = obj-list.obj-type AND
              buf_inkas.obj-code = obj-list.obj-code AND
              buf_inkas.doc-date >= X-date-start AND
              buf_inkas.doc-date <= X-date-end :
        if buf_inkas.status_ = {&fact}
        or buf_inkas.status_ = {&inquiry} then next.
        found = yes.
        return.
      END.
    END. /*WHEN NO*/
  END CASE.
END. /*for each obj-list*/
END PROCEDURE.


PROCEDURE no-benq-i.
/*процедура выяснения были ли закр продажи за этот период*/
DEFINE OUTPUT PARAMETER found as logical init no.
define buffer buf_inkas for ub.inkas.
CASE X-Radio-Task > 1:
  WHEN YES then do:
    FOR EACH obj-list WHERE
            obj-list.obj-type = {&shop} NO-LOCK :
      FOR EACH buf_inkas NO-LOCK WHERE
              buf_inkas.obj-type = obj-list.obj-type AND
              buf_inkas.obj-code = obj-list.obj-code AND
              buf_inkas.status_ = {&fact} AND
              (
              buf_inkas.shift-date >= X-date-start AND
              buf_inkas.shift-date <= X-date-end):

        IF X-Radio-Task = 3 AND
        ((buf_inkas.shift-date = X-date-start AND buf_inkas.shift-num < X-shift-Start) OR
          (buf_inkas.shift-date = X-date-end AND  buf_inkas.shift-num > X-shift-End) ) THEN NEXT.
        IF X-Radio-Task = 4 AND
        (buf_inkas.shift-num <> X-shift-Alone ) THEN NEXT.

        found = yes.
        return.
      END.
  END. /*for each obj-list*/
  END. /*when yes*/
  WHEN NO THEN DO:
    FOR EACH obj-list WHERE
            obj-list.obj-type = {&shop} NO-LOCK :
      FOR EACH buf_inkas NO-LOCK WHERE
              buf_inkas.obj-type = obj-list.obj-type AND
              buf_inkas.obj-code = obj-list.obj-code AND
              buf_inkas.status_ = {&fact} AND
              buf_inkas.doc-date >= X-date-start AND
              buf_inkas.doc-date <= X-date-end :
         found = yes.
         return.
      END.
    END. /*FOR EACH obj-list*/
  END. /*when no*/
END CASE.

END PROCEDURE.


PROCEDURE no-benq-i-office.
/*процедура выяснения были ли закр продажи за этот период*/
DEFINE OUTPUT PARAMETER found as logical init no.
define buffer buf_sale-doc for ub.sale-doc.

CASE X-Radio-Task > 1:
  WHEN YES then do:
    FOR EACH obj-list WHERE
            obj-list.obj-type = {&shop} NO-LOCK :
      FOR EACH buf_sale-doc NO-LOCK WHERE
               buf_Sale-doc.obj-type = obj-list.obj-type
           AND buf_sale-doc.obj-code = obj-list.obj-code
           AND buf_sale-doc.status_ = {&fact}
           AND buf_sale-doc.chr-office = {&gds-office}
           AND (
              buf_sale-doc.shift-date >= X-date-start
              AND
              buf_sale-doc.shift-date <= X-date-end):
        IF X-Radio-Task = 3 AND
        ((buf_sale-doc.shift-date = X-date-start AND buf_sale-doc.shift-num < X-shift-Start) OR
          (buf_sale-doc.shift-date = X-date-end AND  buf_sale-doc.shift-num > X-shift-End) ) THEN NEXT.
        IF X-Radio-Task = 4 AND
        (buf_sale-doc.shift-num <> X-shift-Alone ) THEN NEXT.
        found = yes.
        return.
      END.
    END. /*for each obj-list*/
  END. /*when yes*/
  WHEN NO THEN DO:
    FOR EACH obj-list WHERE
            obj-list.obj-type = {&shop} NO-LOCK :
      FOR EACH buf_sale-doc NO-LOCK WHERE
              buf_sale-doc.obj-type = obj-list.obj-type
         AND  buf_sale-doc.obj-code = obj-list.obj-code
         AND  buf_sale-doc.status_ = {&fact}
         AND  buf_sale-doc.chr-office = {&gds-office}
         AND  buf_sale-doc.doc-date >= X-date-start
         AND  buf_sale-doc.doc-date <= X-date-end :
        found = yes.
        return.
      END.
    END. /*FOR EACH obj-list*/
  END. /*when no*/
END CASE.

END PROCEDURE.


/* $Workfile$ e n d */