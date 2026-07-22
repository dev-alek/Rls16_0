/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Открытие потока - pricecheck-servis+

Автор: Чернова Светлана Александровна
Дата создания: 10/24/06
Author: Svetlana Chernova
Creation date: 10/24/06


*/
&if "{&subject}" = "good" &then
  output stream plucash to value(
  string( session:temp-directory + "plu" + string( var-report-num ) ) + '.plu')  convert target "1251".
  output stream bar to value(
  string( session:temp-directory + "bar" + string( var-report-num ) ) + '.bar' )  convert target "1251".
&endif
/* $Workfile$ e n d */