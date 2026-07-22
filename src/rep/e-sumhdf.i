/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Почасовой отчет по суммам продаж  - определение temp-table

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
    field sum      as   decimal extent 24
    field sum_disc as   decimal extent 24
    field num-chk as integer extent 24 format ">>>>>9"
    INDEX pi IS PRIMARY obj-code grp-code other-code ASCENDING .
DEFINE {1} temp-table gds-h no-undo
   field obj-code like ub.clients.obj-code
    field grp-code like ub.goods.grp-code
    field b-code   like ub.bar-code.b-code
    field gds-name like ub.goods.gds-name
    field uniq     as   char
    field artic    like ub.goods.artic
    field sum      as   decimal extent 24
    field sum_disc as   decimal extent 24
    INDEX pi IS PRIMARY obj-code grp-code b-code ASCENDING
    INDEX uu obj-code grp-code uniq ASCENDING .
/*
define {1} temp-table pay-h no-undo
field pay-code like ub.chk-pay.pay-code
field curr-code like ub.chk-pay.curr-code
field sum-base      as   decimal extent 24
field sum-rubl      as   decimal extent 24
field num-pay as integer extent 24 format ">>>>>9"
INDEX pi IS PRIMARY pay-code curr-code ASCENDING .
*/
/* $Workfile$ e n d */