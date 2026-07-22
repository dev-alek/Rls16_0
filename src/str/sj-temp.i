/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

временная таблица для печати одной продажи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/19/05
Author: Bakhtadze Natalya
Creation date: 10/19/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table sj-goods no-undo
field b-code       like ub.bar-code.b-code format "9999999999999"
field artic        like ub.goods.artic
field name         like ub.goods.gds-name format "x(30)"
field prod-name    like ub.clients.obj-name
field qnty         as   decimal
field qnty-2       as   decimal
field obj-price    like ub.price-list.price-sale
field discnt       as   decimal
field brutto-sum   as   decimal
field discnt-sum   as   decimal
field netto-sum    as   decimal
field uchet-sum    as   decimal
field pcnt         as   decimal
field is-out       as  logical
field VAT-pc       like ub.doc-line.VAT-pc
field SLT-pc       like ub.doc-line.SLT-pc
field write-off-sum as decimal
field dop-rowid    as rowid
INDEX p1 IS PRIMARY   b-code ASCENDING
                      obj-price ASCENDING
                      discnt ASCENDING
                      dop-rowid
INDEX p2              is-out DESCENDING
                      b-code ASCENDING
                      obj-price ASCENDING
                      discnt DESCENDING
.
DEFINE TEMP-TABLE d-slt-vat no-undo
FIELD SLT-pc like ub.doc-line.SLT-pc
FIELD SLT-r-b like ub.inkas.netto
FIELD SLT-r-b-brutto like ub.inkas.netto
INDEX p1 IS PRIMARY SLT-pc ASCENDING .


/* $Workfile$ e n d */