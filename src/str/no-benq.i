/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение наличия выручки по объектам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/20/05
Author: Bakhtadze Natalya
Creation date: 10/20/05

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE no-benq.
/*определение наличия выручки на объекте за заданный периодл времени*/
DEFINE OUTPUT PARAMETER found as logical init no.

FOR EACH obj-list WHERE obj-list.obj-type = {&shop} NO-LOCK :
  CASE (Period-Type > 0 and cas-shft):
    WHEN YES THEN DO:
      FIND FIRST chk-doc WHERE
                chk-doc.obj-type = obj-list.obj-type
            AND chk-doc.obj-code = obj-list.obj-code
            AND (
                chk-doc.shift-date >= startdate
            AND chk-doc.shift-date <= enddate)
            AND (IF cas-num > 0 then chk-doc.pay-desk = cas-num ELSE TRUE)
              NO-LOCK NO-ERROR.
      if available chk-doc then do:
        found = yes.
        return.
      end.
    END. /*WHEN YES*/
    WHEN NO THEN DO:
      FIND FIRST chk-doc WHERE
                chk-doc.obj-type = obj-list.obj-type
            AND chk-doc.obj-code = obj-list.obj-code
            AND chk-doc.chk-date >= startdate
            AND chk-doc.chk-date <= enddate
            AND (IF cas-num > 0 then chk-doc.pay-desk = cas-num ELSE TRUE)
      NO-LOCK NO-ERROR.
      if available chk-doc then do:
        found = yes.
        return.
      end.
    END. /*WHEN NO*/
  END CASE.
END. /*for each obj-list*/
END PROCEDURE.

/* $Workfile$ e n d */