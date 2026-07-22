/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение временной таблицы используемой при закачке чеков МЦ в БД или далее

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then

DEFINE VARIABLE crwth as integer no-undo.
DEFINE VARIABLE var-sum-r-b as decimal no-undo .

&if "{2}" = "chk" &then

/*закачка чеков в продажу*/

DEFINE {3} TEMP-TABLE t-wth No-UNDO
FIELD pay-code like ub.chk-pay.pay-code
FIELD curr-code like ub.chk-pay.curr-code
FIELD wth-code like ub.wealth.wth-code
FIELD tot-sum like ub.chk-pay.tot-sum
FIELD sum-r-b as decimal
FIELD num-lines as integer
field byval as character
FIELD crf as integer
FIELD drc as recid
index pi is PRIMARY pay-code curr-code
index crfi crf.

&endif

&endif

/* $Workfile$ e n d */