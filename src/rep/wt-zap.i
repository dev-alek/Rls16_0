/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE temp-table gds-zap no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    field unit-base  like ub.goods.unit-base
    field prt-root     like ub.goods.prt-root
    field gds-name like ub.goods.gds-name
    field prod-type  like ub.goods.prod-type
    field prod-code like ub.goods.prod-code
    field artic          like ub.goods.artic
    field b-code      like ub.bar-code.b-code
    field weight-bc like ub.prod-bc.b-str
    field grp-name  like ub.goods.grp-name
    field prod-name like ub.clients.obj-name
    field doc-code like ub.doc-line.doc-code
    field order-num  as integer
    field qnty  as decimal
&if "{1}" = "bb-list" or "{1}" = "scnblist" &then
    field b-str  like ub.prod-bc.b-str
&endif
/*
    gds-zap.grp-code  like goods.grp-code
    INDEX grp grp-name ASCENDING
*/
    INDEX obj IS PRIMARY obj-type obj-code    ASCENDING
    .

/* $Workfile$ e n d */