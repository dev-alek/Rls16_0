/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Почасовой отчет по величинам сумм продаж - определение temp-table

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE {1} temp-table grp-h no-undo
    field grp-code like ub.goods.grp-code
    field hour  as decimal extent 24
    field qnty  as  decimal
    field obj-code like ub.clients.obj-code
    INDEX pi IS PRIMARY obj-code grp-code ASCENDING .
DEFINE {1} temp-table gds-h no-undo
    field grp-code like     ub.goods.grp-code
    field obj-code like ub.clients.obj-code
    field b-code      like      ub.bar-code.b-code
    field gds-name like     ub.goods.gds-name
    field f-name like     ub.gds-prt.f-name
    field is-empty as logical
    field uniq          as      char
    field artic          like     ub.goods.artic
    field hour          as      decimal extent 24
    field qnty          as      decimal
    INDEX pi IS PRIMARY obj-code grp-code b-code ASCENDING.

/* $Workfile$ e n d */