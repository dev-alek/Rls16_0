/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PUT STREAM OutStream
SPACE(23)
string( "Cумма ПРОДАЖНЫХ цен: " +
              trim( string( Coast{1}, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
              curr-rep
            ) format "x(72)"
  SKIP
&if "{1}" = "vat" or "{2}" = "vat"  &then
SPACE(23)
string( "НДС в ПРОДАЖНЫХ ценах: " +
              trim( string( Coast-vat{1}, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
              curr-rep
            ) format "x(72)"
  SKIP
&endif
  .
/* $Workfile$ e n d */