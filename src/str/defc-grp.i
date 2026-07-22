/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение временной таблицы по группам товаров для касс

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

чтобы можно было больше не обращаясь к базе выводить на любую кассу

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE {1} TEMP-TABLE cash-grp no-undo
FIELD stts like ub.clients.stts
FIELD grp-code like ub.sum-grp.grp-code
FIELD upper-code like ub.gds-grp.upper-code
FIELD grp-name like ub.sum-grp.grp-name
FIELD news-action as logical
/*при разборке новостей если запись удаляется то ставится yes*/
index pi IS UNIQUE PRIMARY
grp-code
.

DEFINE {1} TEMP-TABLE cash-units no-undo  like ub.units
.

DEFINE {1} TEMP-TABLE cash-gds-prt no-undo like ub.gds-prt
.

DEFINE {1} TEMP-TABLE cash-country no-undo like ub.country
.




/* $Workfile$ e n d */