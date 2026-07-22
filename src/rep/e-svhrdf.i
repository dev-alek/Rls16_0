/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Почасовой отчет по товарам - определение temp-table

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE {1} temp-table grp-h no-undo
    field obj-code like ub.clients.obj-code
    field grp-code like ub.goods.grp-code
    field other-code as integer
    field num-chk   like ub.inkas.num-chk extent 24
    field sum1 like ub.chk-doc.netto
    INDEX pi IS PRIMARY obj-code grp-code other-code sum1 ASCENDING
/*    INDEX uu grp-name sum1 ASCENDING */ .
DEFINE {1} temp-table sum-vals no-undo
    field sum1   like ub.chk-doc.netto
    field sum2   like ub.chk-doc.netto
    field num-chk   like ub.inkas.num-chk extent 24
    field tot like ub.inkas.num-chk
    INDEX pi IS PRIMARY sum1 ASCENDING .

/* $Workfile$ e n d */