/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Таблица для хранения информации по отрицательным остаткам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/09/05
Author: Bakhtadze Natalya
Creation date: 10/09/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE {1} SHARED temp-table dtl-rests no-undo
field b-code like ub.bar-code.b-code
field artic like ub.gds-dtl.artic
field prod-type like ub.gds-dtl.prod-type
field prod-code like ub.gds-dtl.prod-code
field gds-code like ub.goods.gds-code
field prt-code like ub.gds-dtl.prt-code
field unit-base like ub.goods.unit-base
field rest-fact-qnty as decimal
field maybe-qnty as decimal
field prt-qnty as decimal
field free-qnty as decimal
field need-qnty as decimal
field gds-name like ub.goods.gds-name
field OK as logical column-label "ОК"
FIELD fbr as integer
field prop as integer /* 0 - наш объект 1 - наша фирма но чужой объект 2 чужая фирма*/
field is-neg-tpsi-oper as logical
field weight as logical
field is-neg-tpsi-qnty as logical
field is-neg-tpsi-weight as logical
field ok-prop as logical
field is-neg-rest as logical
field to-view as logical
index   pi  is primary
gds-code
prt-code ASCENDING
index   bc
b-code ASCENDING
index ifbr fbr
index iprop prop
index iok ok
index iokprop ok-prop
index iview to-view
.

/* $Workfile$ e n d */