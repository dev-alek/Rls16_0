block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rc-price.p $
$Archive: str/rc-price.p $

Пересчет цен в строке

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 09/20/05


*/
define input parameter parrecdoc-line as recid no-undo.
{ cmp/str-glbl.i  }
{ str/lib-trn.i   }
define variable varprice-cli                like ub.doc-line.price-rubl no-undo.
define variable varprice-cli-unit-base      like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax           like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp          like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp      like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs        like ub.doc-line.price-rubl no-undo.
define variable varprice-slt                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt             like ub.doc-line.price-rubl no-undo.
define variable varprice-vat                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt         like ub.doc-line.price-rubl no-undo.
define variable varprice-rubl               like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-rubl      like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-rubl     like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-rubl like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-rubl   like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-rubl           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-rubl        like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-rubl           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-rubl    like ub.doc-line.price-rubl no-undo.
define variable varprice-base               like ub.doc-line.price-base no-undo.
define variable varprice-road-tax-base      like ub.doc-line.price-base no-undo.
define variable varprice-other-exp-base     like ub.doc-line.price-base no-undo.
define variable varprice-transport-exp-base like ub.doc-line.price-base no-undo.
define variable varprice-without-abs-base   like ub.doc-line.price-base no-undo.
define variable varprice-slt-base           like ub.doc-line.price-base no-undo.
define variable varprice-no-slt-base        like ub.doc-line.price-base no-undo.
define variable varprice-vat-base           like ub.doc-line.price-base no-undo.
define variable varprice-no-vat-slt-base    like ub.doc-line.price-base no-undo.
define buffer t-doc for trn-doc.
find first doc-line where recid(doc-line) = parrecdoc-line.
find first t-doc where t-doc.doc-code = doc-line.doc-code.
{ str/in-vat.i
  t-doc.doc-code
  t-doc.base-rate
  t-doc.base-scale
  t-doc.exch-rate
  t-doc.exch-scale
  t-doc.vat-type
  t-doc.slt-type
  doc-line.artic
  doc-line.prod-type
  doc-line.prod-code
  doc-line.price-cli
  doc-line.cli-base-rate
  doc-line.price-rubl
  doc-line.vat-pc
  doc-line.slt-pc
  doc-line.road-tax
  doc-line.transport-rubl
  doc-line.other-rubl
  varprice-cli
  varprice-cli-unit-base
  varprice-road-tax
  varprice-other-exp
  varprice-transport-exp
  varprice-without-abs
  varprice-slt
  varprice-no-slt
  varprice-vat
  varprice-no-vat-slt
  varprice-rubl
  varprice-road-tax-rubl
  varprice-other-exp-rubl
  varprice-transport-exp-rubl
  varprice-without-abs-rubl
  varprice-slt-rubl
  varprice-no-slt-rubl
  varprice-vat-rubl
  varprice-no-vat-slt-rubl
  varprice-base
  varprice-road-tax-base
  varprice-other-exp-base
  varprice-transport-exp-base
  varprice-without-abs-base
  varprice-slt-base
  varprice-no-slt-base
  varprice-vat-base
  varprice-no-vat-slt-base
  no-error
}
if error-status:error then do:
  return error "Ошибка при пересчете линии документа".
end.
assign doc-line.price-cli  = varprice-cli
       doc-line.price-base = varprice-base
       doc-line.price-rubl = varprice-rubl.