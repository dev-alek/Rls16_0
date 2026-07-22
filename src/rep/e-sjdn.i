/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для процедур печати журнала продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/11/06
Author: Bakhtadze Natalya
Creation date: 01/11/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE  VAR    ObjsQnty            AS    INTEGER        no-undo.
DEFINE  VAR    AllObjsTotalsBy     AS    logical        no-undo.
DEFINE  VAR    Strbuf1             AS    character      no-undo.
DEFINE  VAR    intbuf1             AS    integer        no-undo.
DEFINE  var    chk-gds-lines       as    integer        no-undo.
define variable v-header-sale-curr as character no-undo .
define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}
if v-curr-r-b = {&r-b-base} then do:
  assign
  v-header-sale-curr = string( "(валюта продажи - баз.вал. )" )
  .
end.
else do:
  assign
  v-header-sale-curr = string( "(валюта продажи - {&abbr_rubli_allshift})"  )
  .
end.


def buffer cli-obj for ub.clients .

{ rep/e-sjdfr.i base normal normal SJ-base X(15) }

{ rep/e-sjdfr.i full normal normal SJ-full X(21) }


{ rep/e-sjdfr.i base normal twounit SJ-base-t X(15) }

{ rep/e-sjdfr.i full normal twounit SJ-full-t X(21) }

{ rep/e-sjdfr.i base discount normal SJ-base-d X(21) }

{ rep/e-sjdfr.i full discount normal SJ-FULL-d X(21) }

{ rep/e-sjdfr.i base discount twounit SJ-base-d-t X(21) }

{ rep/e-sjdfr.i full discount twounit SJ-FULL-d-t X(21) }





/* $Workfile$ e n d */