/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Описание временной таблицы для библиотеки lib-calc.p

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/
define temp-table tt-allsum no-undo
field sum-type           as   character                /*тип сумм {&sum-general[-sign]}   - основна
                                                                  {&sum-repayment[-sign]} - выкуп
                                                                  {&sum-cons_acc[-sign]}  - консигнация покрывающая оплате поставщику
                                                                  {&sum-cons_benf[-sign]} - консигнация по выгоде (с нее мы платим НДС государству)
                                                                  {&sum-resp_stor[-sign]} - ответственное хранение */
field sum-dsc-base-doc   like ub.doc-line.price-base   /*цены документа*/
field sum-dsc-rubl-doc   like ub.doc-line.price-base
field dsc-base-doc       like ub.doc-line.price-base
field dsc-rubl-doc       like ub.doc-line.price-base
field vat-base-doc       like ub.doc-line.price-base
field vat-rubl-doc       like ub.doc-line.price-base
field vat-base-buyer-doc like ub.doc-line.price-base
field vat-rubl-buyer-doc like ub.doc-line.price-base
field slt-base-doc       like ub.doc-line.price-base
field slt-rubl-doc       like ub.doc-line.price-base
field road-tax-base-doc  like ub.doc-line.price-base
field road-tax-rubl-doc  like ub.doc-line.price-base
field excise-base-doc    like ub.doc-line.price-base
field excise-rubl-doc    like ub.doc-line.price-base
field sum-dsc-base-acc   like ub.doc-line.price-base   /*учетные цена*/
field sum-dsc-rubl-acc   like ub.doc-line.price-base
field dsc-base-acc       like ub.doc-line.price-base
field dsc-rubl-acc       like ub.doc-line.price-base
field vat-base-acc       like ub.doc-line.price-base
field vat-rubl-acc       like ub.doc-line.price-base
field slt-base-acc       like ub.doc-line.price-base
field slt-rubl-acc       like ub.doc-line.price-base
field road-tax-base-acc  like ub.doc-line.price-base
field road-tax-rubl-acc  like ub.doc-line.price-base
field transport-base-acc like ub.doc-line.price-base
field transport-rubl-acc like ub.doc-line.price-base
field other-base-acc     like ub.doc-line.price-base
field other-rubl-acc     like ub.doc-line.price-base
index sum-type is primary unique sum-type.