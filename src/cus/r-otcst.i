/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Таможенная оборотка - определения временных таблиц

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&global-define nau-length 41
&global-define format-qnty "->>>>>>>9.<<<"
&global-define format-brutto ">>>>9.999"

/*длина формата format-qnty и format brutto должна равняться длине поля 6*/

define {1} shared temp-table tt-cst no-undo
field cst-code         like ub.parts.cst-code
field artic            like ub.goods.artic
field prod-type        like ub.goods.prod-type
field prod-code        like ub.goods.prod-code
field name_artic_unit  as   character
field unit             like ub.goods.unit-base
field nationality      like ub.goods.nationality
field tnved            like ub.goods.tnved
field num-place        as   decimal
field brutto           as   decimal
field qnty-income      like ub.parts.fact-qnty
field qnty-start       like ub.parts.fact-qnty
field qnty-sale        like ub.parts.fact-qnty
field qnty-ext_expence like ub.parts.fact-qnty
field qnty-other_expence like ub.parts.fact-qnty
field qnty-rest        like ub.parts.fact-qnty
field ps               as   character
index pi is primary unique
cst-code
artic
prod-type
prod-code
.

define  {1} shared temp-table tt-cst-ext  no-undo
field cst-code         like ub.parts.cst-code
field artic            like ub.goods.artic
field prod-type        like ub.goods.prod-type
field prod-code        like ub.goods.prod-code
field des              as   character
field qnty as decimal
index pi is primary
cst-code
artic
prod-type
prod-code
.

define  {1} shared temp-table tt-cst-year  no-undo
field in-year            as integer
field cst-code         like ub.parts.cst-code
field zero               as logical
/* 0 не ни движения ни остаток*/
/* 1 нет движения  есть остатки*/
/* 2 есть движение */
index pi is primary unique
cst-code
index i-year is unique
zero
in-year
cst-code
.



/* $Workfile$ e n d */