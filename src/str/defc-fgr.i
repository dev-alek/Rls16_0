/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение временной таблицы по группам блюд на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

чтобы можно было больше не обращаясь к базе выводить на любую кассу

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


DEFINE {1} TEMP-TABLE cash-fgrp no-undo
FIELD node-code like ub.fbr-gds-grp.node-code
FIELD upper-code like ub.fbr-gds-grp.upper-code
FIELD out-code like ub.fbr-gds-grp.out-code
FIELD node-name like ub.fbr-gds-grp.node-name
FIELD upper-out-code like ub.fbr-gds-grp.out-code
FIELD lvl-num        like ub.fbr-gds-grp.lvl-num
FIELD stts  as integer
FIELD action-code as integer
index iout-code IS PRIMARY out-code
index istts stts
index ilvl action-code lvl-num
.

/* $Workfile$ e n d */