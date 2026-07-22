/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Таблица для хранения информации по объектам для КМ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/26/04
Author: Bakhtadze Natalya
Creation date: 05/26/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table cash-obj no-undo
field km-objcode  as integer /*номер магазина или номер весов или номер кассы - не отслыается*/
field km-objname as character
field km-objtype as integer /*1 - BO 2-КМ 3-касса 4-весы 5-сканер*/
field on-addr like ub.cash-desk.addr-path
field off-addr like ub.cash-desk.addr-path
field shop-nums as character /*список магазинов - только номер через запятую*/
field obj-lock as integer /*1 заблокирован*/
field firm-name as character
field jur-address as character
field post-address as character
field INN as character
field KPP as character
index pi is unique primary
km-objtype km-objcode km-objname
.

/* $Workfile$ e n d */