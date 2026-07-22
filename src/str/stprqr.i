/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Простановка последней цены по фирме в запрос

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич
Дата создания: 09/19/05


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

for each ub.gds-obj where ub.gds-obj.prod-type = ub.goods.prod-type
                   and ub.gds-obj.prod-code = ub.goods.prod-code
                   and ub.gds-obj.artic     = ub.goods.artic
                   and ub.gds-obj.host-code = t-doc.host-code
                   and ub.gds-obj.obj-type  = t-doc.obj-type
                   and ub.gds-obj.obj-code  = t-doc.obj-code no-lock,
  first bf-trn-doc where bf-trn-doc.doc-code = ub.gds-obj.in-code no-lock,
  first d-l-b where d-l-b.doc-code  = ub.gds-obj.in-code
                and d-l-b.artic     = ub.goods.artic
                and d-l-b.prod-type = ub.goods.prod-type
                and d-l-b.prod-code = ub.goods.prod-code no-lock
  by bf-trn-doc.fact-order descending:
     ASSIGN {1}price-cli  = d-l-b.price-cli
            /*Для товаров с двумя единицами измерения*/
            {1}price-rubl = d-l-b.price-rubl
            {1}price-base = d-l-b.price-base.
            { str/in-vat.i
              t-doc.doc-code
              t-doc.base-rate
              t-doc.base-scale
              t-doc.exch-rate
              t-doc.exch-scale
              t-doc.vat-type
              t-doc.slt-type
              {1}artic
              {1}prod-type
              {1}prod-code
              {1}price-cli
              {1}cli-base-rate
              {1}price-rubl
              {1}vat-pc
              {1}slt-pc
              {1}road-tax
              {1}transport-rubl
              {1}other-rubl
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
              no-error }
       if error-status:error then do:
         return error "Ошибка при пересчете линии документа".
       end.
       ASSIGN {1}price-cli  = varprice-cli
              /*Для товаров с двумя единицами измерения*/
              {1}price-rubl = varprice-rubl
              {1}price-base = varprice-base.
     leave.
end.
/* $Workfile$ e n d */