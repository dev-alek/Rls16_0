/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отсылка на кассы остатков по БК - специфический код

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*отслыка БК на кассу*/
run term-prt in this-procedure no-error.
if error-status:error then do:
    error-status:error = no.
    NEXT _shop.
end.
IF return-value = "next" then do:
    NEXT _shop.
end.

/* $Workfile$ e n d */