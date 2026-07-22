/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать остатков и оборотов (тип остаткаили оборота 1 2 пусто)

Автор: Чернова Светлана Александровна
Дата создания: 01/28/01
Author: Svetlana Chernova
Creation date: 01/28/01

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CASE "{1}" :
WHEN  "1" then
TEMPSTR =  string( "Остаток на начало периода (" + string( startdate, "99/99/9999" ) + ")" )   .
WHEN "2" then
TEMPSTR = string( "Остаток на конец периода (" + string( enddate, "99/99/9999" ) + ")" )  .
OTHERWISE
TEMPSTR =string( "Оборот с " + string( startdate, "99/99/9999" ) + " по " + string( enddate, "99/99/9999" ) )  .
end CASE.

PUT STREAM OutStream
SKIP
SPACE(5)
TEMPSTR format "x(72)"
SKIP
SPACE(32) string( "Количество: " + trim( string( Quantity{1}, "->>>,>>>,>>9.<<<" ) ) ) format "x(72)"
SKIP.

IF PayType = 2 OR PayType = 0  then do:
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_reports_lookup-cost':U
  {&cntxt-object}
  v-cntxt-host-code-obj
  v-cntxt-obj-type
  v-cntxt-obj-code
  0
  0
  0
  false
  v-log
}
if  v-log = true  then

PUT STREAM OutStream
SPACE(23) string( "Cумма   УЧЕТНЫХ  цен: " +
            trim( string( Coast{1} , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
          SKIP.
PUT STREAM OutStream

SPACE(23) string( "Cумма УЧЕТНЫХ цен без НДС: " +
     trim( string( (Coast{1} - Coast-vat{1}  ) , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
     curr-rep
     ) format "x(72)"
     SKIP.
end.
Else   PUT STREAM OutStream
SPACE(23) string(  "Cумма ПРОДАЖНЫХ цен: " +
            trim( string( Coast{1}, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
          SKIP.


&if "{1}" = "vat" or "{2}" = "vat"  &then
IF PayType = 2 OR PayType = 0  then do :
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_reports_lookup-cost':U
  {&cntxt-object}
  v-cntxt-host-code-obj
  v-cntxt-obj-type
  v-cntxt-obj-code
  0
  0
  0
  false
  v-log
}
if  v-log = true  then
    PUT STREAM OutStream
    SPACE(23)
    string( "НДС в  УЧЕТНЫХ ценах: " +
                trim( string( Coast-vat{1}, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
                curr-rep
              ) format "x(72)"
    SKIP.
end.
ELSE PUT STREAM OutStream
SPACE(23)
string( "НДС в ПРОДАЖНЫХ ценах: " +
            trim( string( Coast-vat{1}, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
SKIP.
&endif
.
/* $Workfile$ e n d */