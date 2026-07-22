/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$


Автор: Суслов Алексей Юрьевич
Дата создания: 03/27/06
Author: Alexey Suslov
Creation date: 03/27/06

Инклюд определения переменных, таблиц, процедур для расчета временных таблиц и титульных переменных в разрезе:
  tt-title             - титульные переменные тип приобретения (создаются всегда);
  d-supp-grp           - разбивка по поставщикам - тип приобретения - группа товаров/услуг;
  d-supp               - разбивка по поставщикам - тип приобретения;
  d-slt-vat            - разбивка НДС реализации - НП реализации;
  d-slt-vat-cons       - разбивка НДС реализации - НП реализации - тип приобретения;
  d-slt-vat-cons-grp   - разбивка НДС реализации - НП реализации - тип приобретения - группа товаров/услуг;
  d-supp-slts-vats     - разбивка по поставщикам - НДС поставщика - НП поставщика;
  d-slts-vats          - разбивка НДС поставщика - НП поставщика;
  d-slts-vats-cons     - разбивка НДС поставщика - НП поставщика - тип приобретения;
  d-slts-vats-cons-grp - разбивка НДС поставщика - НП поставщика - тип приобретения - группа товаров/услуг.
(Всего 10 таблиц.)

Author: Суслов А.Ю. (С)

*/

/* ******************************************** *\
 * acc                - учетная цена;           *
 * sale               - текущие продажные цены; *
 * pay и без префикса - цены документа.         *
\* ******************************************** */

&scop calculated-field field fact-qnty           like ub.doc-line.price-rubl ~
                       field acc-base            like ub.doc-line.price-rubl ~
                       field acc-rubl            like ub.doc-line.price-rubl ~
                       field acc-vat-base        like ub.doc-line.price-rubl ~
                       field acc-vat-rubl        like ub.doc-line.price-rubl ~
                       field acc-slt-base        like ub.doc-line.price-rubl ~
                       field acc-slt-rubl        like ub.doc-line.price-rubl ~
                       field acc-road-tax-base   like ub.doc-line.price-rubl ~
                       field acc-road-tax-rubl   like ub.doc-line.price-rubl ~
                       field acc-excise-base     like ub.doc-line.price-rubl ~
                       field acc-excise-rubl     like ub.doc-line.price-rubl ~
                       field acc-transport-base  like ub.doc-line.price-rubl ~
                       field acc-transport-rubl  like ub.doc-line.price-rubl ~
                       field acc-other-base      like ub.doc-line.price-rubl ~
                       field acc-other-rubl      like ub.doc-line.price-rubl ~
                       field pay-base            like ub.doc-line.price-rubl ~
                       field pay-rubl            like ub.doc-line.price-rubl ~
                       field no-vat-base         like ub.doc-line.price-rubl ~
                       field no-vat-rubl         like ub.doc-line.price-rubl ~
                       field vat-base            like ub.doc-line.price-rubl ~
                       field vat-rubl            like ub.doc-line.price-rubl ~
                       field vat-base-buyer      like ub.doc-line.price-rubl ~
                       field vat-rubl-buyer      like ub.doc-line.price-rubl ~
                       field slt-base            like ub.doc-line.price-rubl ~
                       field slt-rubl            like ub.doc-line.price-rubl ~
                       field road-tax            like ub.doc-line.price-rubl ~
                       field excise              like ub.doc-line.price-rubl ~
                       field sale-base           like ub.doc-line.price-rubl ~
                       field sale-rubl           like ub.doc-line.price-rubl ~
                       field sale-vat-base       like ub.doc-line.price-rubl ~
                       field sale-vat-rubl       like ub.doc-line.price-rubl ~
                       field sale-vat-buyer-base like ub.doc-line.price-rubl ~
                       field sale-vat-buyer-rubl like ub.doc-line.price-rubl ~
                       field sale-slt-base       like ub.doc-line.price-rubl ~
                       field sale-slt-rubl       like ub.doc-line.price-rubl ~
                       field sale-road-tax-base  like ub.doc-line.price-rubl ~
                       field sale-road-tax-rubl  like ub.doc-line.price-rubl ~
                       field sale-excise-base    like ub.doc-line.price-rubl ~
                       field sale-excise-rubl    like ub.doc-line.price-rubl ~
                       field ov-base             like ub.doc-line.price-rubl ~
                       field ov-vat              like ub.doc-line.price-rubl

/* Тип приобретения */
define {1} shared temp-table tt-title no-undo
  field purch-code like ub.parts.purch-code
  field purch-name as   character
  {&calculated-field}
  index purch-code is   primary unique purch-code
.

/* Поставщик - Тип приобретения */
define {1} shared temp-table d-supp no-undo
  field purch-code like ub.parts.purch-code
  field purch-name as   character
  field supp-name  like ub.clients.obj-name
  field supp-type  like ub.parts.supp-type
  field supp-code  like ub.parts.supp-code
  {&calculated-field}
  index supp       is   primary unique supp-type supp-code purch-code
  index i2                                                 purch-code
.

/* Поставщик - Тип приобретения - Группа товаров */
define {1} shared temp-table d-supp-grp no-undo
  field supp-type  like ub.parts.supp-type
  field supp-code  like ub.parts.supp-code
  field purch-code like ub.parts.purch-code
  field grp-code   like ub.goods.grp-code
  field purch-name as   character
  field supp-name  like ub.clients.obj-name
  field grp-name   like ub.gds-grp.node-name
  {&calculated-field}
  index supp       is   primary unique supp-type supp-code purch-code grp-code
  index i2                                                 purch-code
.

/* НДС продажи - НП продажи */
define {1} shared temp-table d-slt-vat no-undo
  field vat-pc  like ub.doc-line.vat-pc
  field slt-pc  like ub.doc-line.slt-pc
  {&calculated-field}
  index vat-slt is   primary unique vat-pc slt-pc
.

/* НДС продажи - НП продажи -Тип приобретения */
define {1} shared temp-table d-slt-vat-cons no-undo
  field vat-pc        like ub.doc-line.vat-pc
  field slt-pc        like ub.doc-line.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  {&calculated-field}
  index vat-slt-purch is   primary   unique vat-pc slt-pc purch-code
.

/* НДС продажи - НП продажи - Тип приобретения - Группа товаров */
define {1} shared temp-table d-slt-vat-cons-grp no-undo
  field vat-pc        like ub.doc-line.vat-pc
  field slt-pc        like ub.doc-line.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field grp-code      like ub.goods.grp-code
  field grp-name      like ub.gds-grp.node-name
  {&calculated-field}
  index vat-slt-purch is   primary   unique vat-pc slt-pc purch-code grp-code
.

/* Поставщик - НДС поставщика - НП поставщика - Тип приобретения */
define {1} shared temp-table d-supp-slts-vats-cons no-undo
  field supp-type  like ub.parts.supp-type
  field supp-code  like ub.parts.supp-code
  field supp-name  like ub.clients.obj-name
  field vat-pc     like ub.parts.vat-pc
  field slt-pc     like ub.parts.slt-pc
  field purch-code like ub.parts.purch-code
  field purch-name as   character
  {&calculated-field}
  index pi         is   primary   unique supp-type supp-code vat-pc slt-pc purch-code
.

/* НДС поставщика - НП поставщика */
define {1} shared temp-table d-slts-vats no-undo
  field vat-pc  like ub.parts.vat-pc
  field slt-pc  like ub.parts.slt-pc
  {&calculated-field}
  index vat-slt is   primary unique vat-pc slt-pc
.

/* НДС поставщика - НП поставщика - Тип приобретения */
define {1} shared temp-table d-slts-vats-cons no-undo
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  {&calculated-field}
  index vat-slt-purch is   primary   unique vat-pc slt-pc purch-code
.

/* НДС поставщика - НП поставщика - Тип приобретения - Группа товаров */
define {1} shared temp-table d-slts-vats-cons-grp no-undo
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field grp-code      like ub.goods.grp-code
  field purch-name    as   character
  field grp-name      like ub.gds-grp.node-name
  {&calculated-field}
  index vat-slt-purch is   primary   unique vat-pc slt-pc purch-code grp-code
.

{ str/d-supp-1.i {1} }

/* $Workfile$   E n d */
