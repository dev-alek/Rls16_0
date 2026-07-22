/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Модернизированная функция округлени

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION round-m RETURNS DECIMAL(input  mysum as decimal,
                                                                  input  orders as integer):
define variable  round-m-sum as decimal no-undo.
if orders >= 0 then
round-m-sum = round(mysum,orders).
else
round-m-sum = round(mysum / exp(10, abs(orders)), 0) * EXP(10, abs(orders)).
/*
message mysum / exp(10, abs(orders)) view-as alert-box.
message round(mysum / exp(10, abs(orders)), 0) view-as alert-box.
message round-m-sum view-as alert-box.
*/
return round-m-sum.
END FUNCTION.

/* $Workfile$ e n d */