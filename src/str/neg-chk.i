/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение времнной таблицыч для показа чеков по продаже в которых цена не сопадает с ценой документа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE {1} SHARED temp-table nc no-undo
field doc-code like ub.inkas.inkas-code
field b-code like ub.bar-code.b-code
field artic like ub.gds-dtl.artic
field prod-type like ub.gds-dtl.prod-type
field prod-code like ub.gds-dtl.prod-code
field prt-code like ub.gds-dtl.prt-code
field gds-name like ub.goods.gds-name
field chk-code like ub.chk-doc.doc-code
field cashier like ub.chk-doc.cashier
field price-r-b like ub.gds-dtl.price-rubl
field price-chk like ub.chk-gds.price-base
field chk-qnty like ub.chk-gds.doc-qnty
field fact-qnty like ub.gds-dtl.fact-qnty
field discnt like ub.chk-gds.discnt
field chk-num like ub.chk-doc.chk-num
field pay-desk like ub.chk-doc.pay-desk
index   pi  is primary   doc-code artic prod-type prod-code prt-code chk-code ASCENDING
index   bc                     doc-code b-code                                            chk-code ASCENDING .

/* $Workfile$ e n d */