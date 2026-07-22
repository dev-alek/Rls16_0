/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение временной таблицы для отчета по документам -ЦУМ-5

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/03/04
Author: Bakhtadze Natalya
Creation date: 02/03/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table sj-goods no-undo
field gds-code  like ub.goods.gds-code
field b-code    like ub.bar-code.b-code
field prt-code  like ub.gds-dtl.prt-code
field artic     like ub.goods.artic
field prod-type like ub.goods.prod-type
field prod-code like ub.goods.prod-code
field name      like ub.goods.gds-name format "x(30)"
field grp-name  like ub.goods.grp-name
field struct    like ub.goods.struct   column-label "Состав сырья"
field unit      like ub.goods.unit-base
field f-name     like ub.gds-prt.f-name

field qnty      as   decimal

field obj-type   like ub.clients.obj-type
field obj-code   like ub.clients.obj-code
field doc-code   like ub.trn-doc.doc-code

field ext-doc-type like ub.trn-doc.ext-doc-type
field doc-date   like ub.trn-doc.doc-date
field fact-date  like ub.trn-doc.fact-date



field cli-type   like ub.trn-doc.cli-type
field cli-code   like ub.trn-doc.cli-code
field pay-code   like ub.trn-doc.pay-code

/*учетная часть*/
field supp-type like ub.goods.prod-type
field supp-code like ub.goods.prod-code
field supp-purch-code like ub.trn-doc.purch-code
field supp-pay-code like ub.trn-doc.pay-code
field in-code    like ub.parts.in-code
field part-code  like ub.parts.part-code
field uchet-with-vat-price as decimal /*учетные цены*/
field uchet-with-vat-sum   as decimal /*сумма учетные цены*/
field supp-vat-pc          like ub.doc-line.vat-pc
field supp-vat-sum         as decimal
field supp-vat-price       as decimal

/*продажная часть*/
field VAT-pc               like ub.doc-line.VAT-pc
field VAT-sum              as decimal /*сумма НДС*/
field VAT-price            as decimal /*удельный НДС*/
field sale-price           as decimal /*продажная цена из прайс на факт документа*/
field sale-price-pr        as decimal /*продажная цена из прайс на факт документа приведенная*/
field sale-sum             as decimal /*продажная сумма из прайс на факт документа*/
field doc-price            as decimal /*цена документа*/
field doc-sum              as decimal /*цена документа*/
field doc-discnt-sum       as decimal /*сумма скидки из документа*/
field doc-discnt           as decimal /*удельная сикдка*/

INDEX p1 IS PRIMARY   b-code doc-code in-code part-code
.

define {1} temp-table sj-parts no-undo
field gds-code  like ub.goods.gds-code
field qnty      as   decimal
field doc-code   like ub.trn-doc.doc-code

field supp-type like ub.goods.prod-type
field supp-code like ub.goods.prod-code
field supp-purch-code like ub.trn-doc.purch-code
field supp-pay-code like ub.trn-doc.pay-code
field in-code    like ub.parts.in-code
field part-code  like ub.parts.part-code

field uchet-with-vat-price as decimal /*учетные цены*/
field uchet-with-vat-sum   as decimal /*сумма учетные цены*/
field supp-vat-pc          like ub.doc-line.vat-pc
field supp-vat-sum         as decimal
field supp-vat-price       as decimal

INDEX p1 IS PRIMARY   gds-code doc-code in-code part-code
.


define {1} temp-table sj-gds-dtl no-undo
field gds-code  like ub.goods.gds-code
field b-code    like ub.bar-code.b-code
field prt-code  like ub.gds-dtl.prt-code
field qnty      as   decimal
field doc-code   like ub.trn-doc.doc-code

field VAT-pc               like ub.doc-line.VAT-pc
field VAT-sum              as decimal /*сумма НДС*/
field VAT-price            as decimal /*удельный НДС*/
field sale-price           as decimal /*продажная цена из прайс на факт документа*/
field sale-price-pr        as decimal /*продажная цена из прайс на факт документа приведенная*/
field sale-sum             as decimal /*продажная сумма из прайс на факт документа*/
field doc-price            as decimal /*цена документа*/
field doc-sum              as decimal /*цена документа*/
field doc-discnt-sum       as decimal /*сумма скидки из документа*/
field doc-discnt           as decimal /*удельная сикдка*/

INDEX p1 IS PRIMARY   b-code doc-code
.