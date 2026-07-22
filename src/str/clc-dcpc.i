/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

значения процентов скидок в зависимости от общей суммы покупок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/16/05
Author: Bakhtadze Natalya
Creation date: 12/16/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION calc-dcpc-1 RETURNS DECIMAL(input  for-sum as decimal,
                                   input  n-d-pcnt as decimal,
                                   input  sumdiscs as char,
                                   output new-d-pcnt     as decimal):
define variable ii as integer no-undo.
ii = 1.
new-d-pcnt = n-d-pcnt.

REPEAT while (ii <= num-entries(sumdiscs, ";")):
    IF for-sum >= DECIMAL(ENTRY(1,ENTRY(ii, sumdiscs, ";"), "=")) AND
        (ii = NUM-ENTRIES(sumdiscs,";") OR
        for-sum < DECIMAL(ENTRY(1,ENTRY(ii + 1, sumdiscs, ";"), "="))
          ) THEN do:
      assign
      new-d-pcnt = decimal(ENTRY(2,ENTRY(ii, sumdiscs, ";"), "=")) NO-ERROR.
        LEAVE.
    END.
    ii = ii + 1.
END.

RETURN new-d-pcnt.
END FUNCTION.

FUNCTION calc-dckat-1 RETURNS INTEGER(input  for-sum as decimal,
                                   input  n-kat as integer,
                                   input  sumdiscs as char,
                                   output new-kat  as integer):
define variable ii as integer no-undo.
ii = 1.
new-kat = n-kat.

REPEAT while (ii <= num-entries(sumdiscs, ";")):
    IF for-sum >= DECIMAL(ENTRY(1,ENTRY(ii, sumdiscs, ";"), "=")) AND
        (ii = NUM-ENTRIES(sumdiscs,";") OR
        for-sum < DECIMAL(ENTRY(1,ENTRY(ii + 1, sumdiscs, ";"), "="))
          ) THEN do:
      assign
      new-kat = integer(ENTRY(2,ENTRY(ii, sumdiscs, ";"), "=")) NO-ERROR.
        LEAVE.
    END.
    ii = ii + 1.
END.

RETURN new-kat.
END FUNCTION.


FUNCTION calc-dcpc-2 RETURNS DECIMAL(input  for-sum as decimal,
                                    input  n-d-pcnt as decimal,
                                   input  sumdiscs as char,
                                   output new-d-pcnt     as decimal):
define variable ii as integer no-undo.
define variable v-new-ii as integer no-undo init -1.
define variable v-old-ii as integer no-undo init -1.
define variable no-support as logical no-undo .
new-d-pcnt = 0.
if n-d-pcnt = ? then do:
  no-support = yes.
  n-d-pcnt = 0.
end.
ii = 1.
REPEAT while (ii <= num-entries(sumdiscs, ";")):
    if ii = 1 and
    for-sum < DECIMAL(ENTRY(1, ENTRY(ii, sumdiscs, ";"), "=")) then do:
       assign
       v-new-ii = 0.
    end.
    if ii = 1
    and  n-d-pcnt < DECIMAL(ENTRY(2, ENTRY(ii, sumdiscs, ";"), "=")) then do:
       assign
       v-old-ii = 0.
    end.
    IF for-sum >= DECIMAL(ENTRY(1, ENTRY(ii, sumdiscs, ";"), "=")) AND
        (ii = NUM-ENTRIES(sumdiscs, ";") OR
        for-sum < DECIMAL(ENTRY(1, ENTRY(ii + 1, sumdiscs, ";"), "="))
          ) THEN do:
      assign
      new-d-pcnt = decimal(ENTRY(2, ENTRY(ii, sumdiscs, ";"), "=")) NO-ERROR.
      v-new-ii = ii.
    END.
    IF n-d-pcnt >= DECIMAL(ENTRY(2, ENTRY(ii, sumdiscs, ";"), "=")) AND
        (ii = NUM-ENTRIES(sumdiscs, ";") OR
        n-d-pcnt < DECIMAL(ENTRY(2, ENTRY(ii + 1, sumdiscs, ";"), "="))
          ) THEN do:
      assign
      v-old-ii = ii.
    end.
    if (v-new-ii <> - 1
    AND V-OLD-II <>  -1)
    and ((v-old-ii - v-new-ii) >= 1
          or
          new-d-pcnt > n-d-pcnt
          or no-support
          )
    then leave.
    ii = ii + 1.
END.
/*
если вверх тоже оп одной ступени - то как
if new-d-pcnt > n-d-pcnt then
new-d-pcnt = decimal(ENTRY(2, ENTRY(v-old-ii + 1, sumdiscs, ";"), "=")) no-error .
*/
if new-d-pcnt < n-d-pcnt then
new-d-pcnt = decimal(ENTRY(2, ENTRY(v-old-ii - 1, sumdiscs, ";"), "=")) no-error .
RETURN new-d-pcnt.
END FUNCTION.

FUNCTION calc-dckat-2 RETURNS INTEGER(input  for-sum as decimal,
                                   input  n-kat as integer,
                                   input  sumdiscs as char,
                                   output new-kat  as integer):
define variable ii as integer no-undo.
define variable v-new-ii as integer no-undo init -1.
define variable v-old-ii as integer no-undo init -1.
define variable no-support as logical no-undo .
if n-kat = ? then do:
  no-support = yes.
  n-kat = 0.
end.
ii = 1.
new-kat = 0.

REPEAT while (ii <= num-entries(sumdiscs, ";")):
    if ii = 1
    and for-sum < DECIMAL(ENTRY(1, ENTRY(ii, sumdiscs, ";"), "=")) then do:
       assign
       v-new-ii = 0.
    end.
    if ii = 1
    and n-kat < integer(ENTRY(2, ENTRY(ii, sumdiscs, ";"), "=")) then do:
       assign
       v-old-ii = 0.
    end.
    IF for-sum >= DECIMAL(ENTRY(1,ENTRY(ii, sumdiscs, ";"), "=")) AND
        (ii = NUM-ENTRIES(sumdiscs,";") OR
        for-sum < DECIMAL(ENTRY(1,ENTRY(ii + 1, sumdiscs, ";"), "="))
          ) THEN do:
      assign
      new-kat = integer(ENTRY(2,ENTRY(ii, sumdiscs, ";"), "=")) NO-ERROR.
      v-new-ii = ii.
    END.
    IF n-kat >= integer(ENTRY(2, ENTRY(ii, sumdiscs, ";"), "=")) AND
        (ii = NUM-ENTRIES(sumdiscs, ";") OR
        n-kat < integer(ENTRY(2, ENTRY(ii + 1, sumdiscs, ";"), "="))
          ) THEN do:
      assign
      v-old-ii = ii.
    END.
    if (v-new-ii <> - 1
    AND V-OLD-II <>  -1)
    and (abs(v-old-ii - v-new-ii) >= 1
         or
         no-support)
    then leave.
    ii = ii + 1.
END.
/*если вверх тоже оп одной ступени - то как
if v-new-ii > v-old-ii then
new-kat = integer(ENTRY(2, ENTRY(v-old-ii + 1, sumdiscs, ";"), "=")) no-error .
*/
if v-new-ii < v-old-ii then
new-kat = integer(ENTRY(2, ENTRY(v-old-ii - 1, sumdiscs, ";"), "=")) no-error .
RETURN new-kat.
END FUNCTION.


/* $Workfile$ e n d */