/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение временной таблицы по услуге

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/30/09
Author: Dmitry Ukhanov
Creation date: 01/30/09

Автор1: Бахтадзе Наталья Викторовна
Дата создания1: 04/10/06

ЮКОС лист 4

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*какие вообще топлива были за смену*/
DEFINE {1} TEMP-TABLE t-4 no-undo
FIELD gds-code like ub.goods.gds-code
FIELD main-code like ub.bar-code.b-code
FIELD artic like ub.goods.artic
FIELD prod-type like ub.goods.prod-type
FIELD prod-code like ub.goods.prod-code
FIELD last-price as decimal FORMAT ">>>>9.99"
FIELD gds-name like ub.goods.gds-name FORMAT "X(24)"
FIELD lines as integer
INDEX pi IS UNIQUE primary
gds-code
INDEX art IS UNIQUE
artic
prod-type
prod-code
INDEX pervakov IS UNIQUE
main-code
.


/* $Workfile$ e n d */