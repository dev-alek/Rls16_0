/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение временной таблицы  с нужной информацей по МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

ЮКОС лист 5

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE {1} TEMP-TABLE t-5 no-undo
FIELD wth-code like ub.wealth.wth-code
FIELD wth-name like ub.wealth.wth-name
FIELD stock-before like ub.wth-line.income
FIELD stock-after like ub.wth-line.income
FIELD income-cassa  like ub.wth-line.income-cassa
FIELD income-other like ub.wth-line.income-other
FIELD incass-bank  like ub.wth-line.incass-bank
FIELD incass-other like ub.wth-line.incass-other
FIELD incass-cassa like ub.wth-line.incass-cassa
INDEX pi IS UNIQUE primary
wth-code
INDEX namei
wth-name
.


/* $Workfile$ e n d */