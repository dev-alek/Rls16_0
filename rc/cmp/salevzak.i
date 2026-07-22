/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение временной таблицы для ОТЧЕТ ПО ЗАРЕЗЕРВИРОВАННЫМ ПАРТИЯМ ПРОДАЖИ ПО ВАРИАНТАМ ЗАКУПКИ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/11/05
Author: Bakhtadze Natalya
Creation date: 03/11/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table sj-goods no-undo
field gds-code       like ub.goods.gds-code
field artic          like ub.goods.artic
field prod-type      like ub.goods.prod-type
field prod-code      like ub.goods.prod-code
field gds-name       like ub.goods.gds-name
field prod-name      like ub.goods.gds-name
field qnty           as   decimal
field rest-qnty      as   decimal
field sale-sum       like ub.trn-doc.tot-sale /*продажные цены*/
field price-sale     like ub.gds-dtl.price-rubl
field supp-type      like ub.parts.supp-type
field supp-code      like ub.parts.supp-code
field price-flag     as logical init no
field supp-flag      as logical init no
field var-purch      as integer
field is-out         as logical  /*расход возврат*/
INDEX p1 IS PRIMARY UNIQUE
is-out
gds-code
/*если 0 - то для всех товаров*/
var-purch
/*1 - выкуп консигнация временное хранение
2 - старая консигнаци
0 - все вместе
*/
supp-type
supp-code
INDEX p2
is-out
/*если 0 - то для всех товаров*/
var-purch
/*1 - выкуп консигнация временное хранение
2 - старая консигнаци
0 - все вместе
*/
sale-sum descending
.



define {1} temp-table sj-print no-undo                                   ~
field gds-code       like ub.goods.gds-code
field artic          like ub.goods.artic
field prod-type      like ub.goods.prod-type
field prod-code      like ub.goods.prod-code
field gds-name       like ub.goods.gds-name
field prod-name      like ub.goods.gds-name
field qnty           as   decimal
field sale-sum       like ub.trn-doc.tot-sale /*продажные цены*/
field price-sale     like ub.gds-dtl.price-rubl
field supp-type      like ub.parts.supp-type
field supp-code      like ub.parts.supp-code
field price-flag     as logical init no
field supp-flag      as logical init no
field var-purch      as integer
field is-cash        as logical
field is-out         as logical  /*расход возврат*/
INDEX p1 IS PRIMARY UNIQUE
is-out
gds-code
/*если 0 - то для всех товаров*/
var-purch
is-cash
/*1 - выкуп консигнация временное хранение
2 - старая консигнаци
0 - все вместе
*/
supp-type
supp-code
INDEX p2
is-out descending
gds-code
/*если 0 - то для всех товаров*/
var-purch
/*1 - выкуп консигнация временное хранение
2 - старая консигнаци
0 - все вместе
*/
sale-sum descending
.

/* $Workfile$ e n d */