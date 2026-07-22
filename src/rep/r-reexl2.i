/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 01/12/07
Author: Svetlana Chernova
Creation date: 01/12/07

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
num#str# = num#str# + 1.
num#col# = 2.
run macr_excel_char(
string( "Cумма ПРОДАЖНЫХ цен: " +
              trim( string( Coast{1}, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
              curr-rep )  , num#str# , num#col#   ) .
num#str# = num#str# + 1.
&if "{1}" = "vat" or "{2}" = "vat"  &then
run macr_excel_char(
string( "НДС в ПРОДАЖНЫХ ценах: " +
              trim( string( Coast-vat{1}, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
              curr-rep ) , num#str# , num#col#   ) .
  num#str# = num#str# + 1.
&endif
/* $Workfile$ e n d */