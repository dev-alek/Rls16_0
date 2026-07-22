/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение временной таблицы по кодам составных товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

чтобы можно было больше не обращаясь к базе выводить на любую кассу

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE {1} TEMP-TABLE cash-rcp no-undo
FIELD rc as recid
FIELD rcp-string AS char
/*для связи с таблицей cash-gds*/
FIELD news-action as logical
/*при разборке новостей елси запись удаляется то ставится yes*/
index pi IS UNIQUE PRIMARY rc
.

/* $Workfile$ e n d */