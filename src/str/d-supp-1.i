/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение переменных, таблиц, процедур для расчета временных таблиц и титульных переменных в разрезе

Автор: Чернова Светлана Александровна
Дата создания: 02/13/08
Author: Svetlana Chernova
Creation date: 02/13/08

Автор1: Булгаков Андрей Николаевич
Дата создания: 03/14/05

*/

/* ************************* *\
 * Общий список таблиц(8шт.) *
 * tt-title-fin              *
 * d-supp-fin                *
 * d-supp-grp-fin            *
 * d-slt-vat-cons-fin        *
 * d-slt-vat-cons-grp-fin    *
 * d-supp-slts-vats-cons-fin *
 * d-slts-vats-cons-fin      *
 * d-slts-vats-cons-grp-fin  *
\* ************************* */

/* Тип приобретения - заказ */
define {1} shared temp-table tt-title-fin no-undo
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field contract-code like ub.fin-doc.contract-code
  {&calculated-field}
  index purch-findoc  is   primary unique contract-code purch-code
.

/* Поставщик - Тип приобретения - заказ */
define {1} shared temp-table d-supp-fin no-undo
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field supp-name     like ub.clients.obj-name
  field supp-type     like ub.parts.supp-type
  field supp-code     like ub.parts.supp-code
  field contract-code like ub.fin-doc.contract-code
  {&calculated-field}
  index supp          is   primary unique contract-code supp-type supp-code purch-code
  index i2                                purch-code
.

/* Поставщик - Тип приобретения - Группа товаров - заказ */
define {1} shared temp-table d-supp-grp-fin no-undo
  field supp-type     like ub.parts.supp-type
  field supp-code     like ub.parts.supp-code
  field purch-code    like ub.parts.purch-code
  field grp-code      like ub.goods.grp-code
  field purch-name    as   character
  field supp-name     like ub.clients.obj-name
  field grp-name      like ub.gds-grp.node-name
  field contract-code like ub.fin-doc.contract-code
  {&calculated-field}
  index supp          is   primary unique contract-code supp-type supp-code purch-code grp-code
  index i2                                purch-code
.

/* НДС продажи - НП продажи - Тип приобретения - заказ */
define {1} shared temp-table d-slt-vat-cons-fin no-undo
  field vat-pc        like ub.doc-line.vat-pc
  field slt-pc        like ub.doc-line.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field contract-code like ub.fin-doc.contract-code
  {&calculated-field}
  index vat-slt-purch is   primary unique contract-code vat-pc slt-pc purch-code
.

/* НДС продажи - НП продажи - Тип приобретения - Группа товаров - заказ */
define {1} shared temp-table d-slt-vat-cons-grp-fin no-undo
  field vat-pc        like ub.doc-line.vat-pc
  field slt-pc        like ub.doc-line.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field grp-code      like ub.goods.grp-code
  field grp-name      like ub.gds-grp.node-name
  field contract-code like ub.fin-doc.contract-code
  {&calculated-field}
  index vat-slt-purch is   primary unique contract-code vat-pc slt-pc purch-code grp-code
.

/* Поставщик - НДС поставщика - НП поставщика - Тип приобретения - заказ */
define {1} shared temp-table d-supp-slts-vats-cons-fin no-undo
  field supp-type     like ub.parts.supp-type
  field supp-code     like ub.parts.supp-code
  field supp-name     like ub.clients.obj-name
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field contract-code like ub.fin-doc.contract-code
  {&calculated-field}
  index pi            is   primary unique contract-code supp-type supp-code vat-pc slt-pc purch-code
.

/* НДС поставщика - НП поставщика - Тип приобретения - заказ */
define {1} shared temp-table d-slts-vats-cons-fin no-undo
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field contract-code like ub.fin-doc.contract-code
  {&calculated-field}
  index vat-slt-purch is   primary unique contract-code vat-pc slt-pc purch-code
.

/* НДС поставщика - НП поставщика - Тип приобретения - Группа товаров - заказ */
define {1} shared temp-table d-slts-vats-cons-grp-fin no-undo
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field grp-code      like ub.goods.grp-code
  field purch-name    as   character
  field grp-name      like ub.gds-grp.node-name
  field contract-code like ub.fin-doc.contract-code
  {&calculated-field}
  index vat-slt-purch is   primary unique contract-code vat-pc slt-pc purch-code grp-code
.

/* $Workfile$   E n d */
