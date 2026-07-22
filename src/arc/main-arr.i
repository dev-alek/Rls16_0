/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Заполняет таблицу acc-stk-line

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

for each tt-stk-line:
    delete tt-stk-line.
end.
run stk-lnrv(
    input  tt-clients.obj-type,
    input  tt-clients.obj-code,
    input  tt-goods.artic,
    input  tt-goods.prod-type,
    input  tt-goods.prod-code,
    input  fact-order-start,
    input  fact-order-end,
    input  {1},
    input  {&root-cat-id},
    input  varis-shift-num,
    output table tt-stk-line).
/*Пробежимся по оборотам товара на объекте, в разрезе типов документа,*/
/*и уложим их в browser-имую таблицу общих оборотов.*/
/*Поля товар и объект в данной таблице не важны поэтому не заполняются */

for each tt-stk-line:
    assign varorder = lookup(substring(tt-stk-line.sum-type, length({1}) + 1), {&tdedt_list}).
    find first acc-stk-line where acc-stk-line.order = varorder no-error.
    if not available acc-stk-line then do:
       create acc-stk-line.
       assign
       acc-stk-line.obj-type          = ?
       acc-stk-line.obj-code          = ?
       acc-stk-line.artic             = ?
       acc-stk-line.prod-type         = ?
       acc-stk-line.prod-code         = ?
       acc-stk-line.sum-type          = ?
       acc-stk-line.cat-id            = {&root-cat-id}
       acc-stk-line.order             = varorder
       acc-stk-line.ext-doc-type      = substring(tt-stk-line.sum-type, length({1}) + 1)
       acc-stk-line.ext-doc-type-full = entry(acc-stk-line.order, {&tdedt_list-full}).
    end.
    CASE {1}:
       WHEN {&arh-csdt} or
       WHEN {&arh-csdt-service} then do:
          assign acc-stk-line.fact-qnty = acc-stk-line.fact-qnty + tt-stk-line.fact-qnty.
          if {2} then
          assign
          acc-stk-line.sum-base       = acc-stk-line.sum-base       + tt-stk-line.sum-base
          acc-stk-line.sum-rubl       = acc-stk-line.sum-rubl       + tt-stk-line.sum-rubl
          acc-stk-line.vat-base       = acc-stk-line.vat-base       + tt-stk-line.vat-base
          acc-stk-line.vat-rubl       = acc-stk-line.vat-rubl       + tt-stk-line.vat-rubl
          acc-stk-line.slt-base       = acc-stk-line.slt-base       + tt-stk-line.slt-base
          acc-stk-line.slt-rubl       = acc-stk-line.slt-rubl       + tt-stk-line.slt-rubl
          acc-stk-line.road-tax-base  = acc-stk-line.road-tax-base  + tt-stk-line.road-tax-base
          acc-stk-line.road-tax-rubl  = acc-stk-line.road-tax-rubl  + tt-stk-line.road-tax-rubl
          acc-stk-line.excise-base    = acc-stk-line.excise-base    + tt-stk-line.excise-base
          acc-stk-line.excise-rubl    = acc-stk-line.excise-rubl    + tt-stk-line.excise-rubl
          acc-stk-line.transport-base = acc-stk-line.transport-base + tt-stk-line.transport-base
          acc-stk-line.transport-rubl = acc-stk-line.transport-rubl + tt-stk-line.transport-rubl
          acc-stk-line.other-base     = acc-stk-line.other-base     + tt-stk-line.other-base
          acc-stk-line.other-rubl     = acc-stk-line.other-rubl     + tt-stk-line.other-rubl.
          else
          assign
          acc-stk-line.sum-base       = ?
          acc-stk-line.sum-rubl       = ?
          acc-stk-line.vat-base       = ?
          acc-stk-line.vat-rubl       = ?
          acc-stk-line.slt-base       = ?
          acc-stk-line.slt-rubl       = ?
          acc-stk-line.road-tax-base  = ?
          acc-stk-line.road-tax-rubl  = ?
          acc-stk-line.excise-base    = ?
          acc-stk-line.excise-rubl    = ?
          acc-stk-line.transport-base = ?
          acc-stk-line.transport-rubl = ?
          acc-stk-line.other-base     = ?
          acc-stk-line.other-rubl     = ?.
       end.
       WHEN {&arh-cgdt} or
       WHEN {&arh-cgdt-service} THEN
       assign
       acc-stk-line.sum-base-sale       = acc-stk-line.sum-base-sale       + tt-stk-line.sum-base
       acc-stk-line.sum-rubl-sale       = acc-stk-line.sum-rubl-sale       + tt-stk-line.sum-rubl
       acc-stk-line.vat-base-sale       = acc-stk-line.vat-base-sale       + tt-stk-line.vat-base
       acc-stk-line.vat-rubl-sale       = acc-stk-line.vat-rubl-sale       + tt-stk-line.vat-rubl
       acc-stk-line.slt-base-sale       = acc-stk-line.slt-base-sale       + tt-stk-line.slt-base
       acc-stk-line.slt-rubl-sale       = acc-stk-line.slt-rubl-sale       + tt-stk-line.slt-rubl
       acc-stk-line.road-tax-base-sale  = acc-stk-line.road-tax-base-sale  + tt-stk-line.road-tax-base
       acc-stk-line.road-tax-rubl-sale  = acc-stk-line.road-tax-rubl-sale  + tt-stk-line.road-tax-rubl
       acc-stk-line.excise-base-sale    = acc-stk-line.excise-base-sale    + tt-stk-line.excise-base
       acc-stk-line.excise-rubl-sale    = acc-stk-line.excise-rubl-sale    + tt-stk-line.excise-rubl
       acc-stk-line.transport-base-sale = acc-stk-line.transport-base-sale + tt-stk-line.transport-base
       acc-stk-line.transport-rubl-sale = acc-stk-line.transport-rubl-sale + tt-stk-line.transport-rubl
       acc-stk-line.other-base-sale     = acc-stk-line.other-base-sale     + tt-stk-line.other-base
       acc-stk-line.other-rubl-sale     = acc-stk-line.other-rubl-sale     + tt-stk-line.other-rubl.
       WHEN {&arh-sadt} or
       WHEN {&arh-sadt-service} THEN
       assign
       acc-stk-line.sum-base-doc       = acc-stk-line.sum-base-doc       + tt-stk-line.sum-base
       acc-stk-line.sum-rubl-doc       = acc-stk-line.sum-rubl-doc       + tt-stk-line.sum-rubl
       acc-stk-line.vat-base-doc       = acc-stk-line.vat-base-doc       + tt-stk-line.vat-base
       acc-stk-line.vat-rubl-doc       = acc-stk-line.vat-rubl-doc       + tt-stk-line.vat-rubl
       acc-stk-line.slt-base-doc       = acc-stk-line.slt-base-doc       + tt-stk-line.slt-base
       acc-stk-line.slt-rubl-doc       = acc-stk-line.slt-rubl-doc       + tt-stk-line.slt-rubl
       acc-stk-line.road-tax-base-doc  = acc-stk-line.road-tax-base-doc  + tt-stk-line.road-tax-base
       acc-stk-line.road-tax-rubl-doc  = acc-stk-line.road-tax-rubl-doc  + tt-stk-line.road-tax-rubl
       acc-stk-line.excise-base-doc    = acc-stk-line.excise-base-doc    + tt-stk-line.excise-base
       acc-stk-line.excise-rubl-doc    = acc-stk-line.excise-rubl-doc    + tt-stk-line.excise-rubl
       acc-stk-line.transport-base-doc = acc-stk-line.transport-base-doc + tt-stk-line.transport-base
       acc-stk-line.transport-rubl-doc = acc-stk-line.transport-rubl-doc + tt-stk-line.transport-rubl
       acc-stk-line.other-base-doc     = acc-stk-line.other-base-doc     + tt-stk-line.other-base
       acc-stk-line.other-rubl-doc     = acc-stk-line.other-rubl-doc     + tt-stk-line.other-rubl.
       otherwise do:
          message "Некорректный sum-type " {1} " при просмотре архива(main-arr.i)." skip
                  "Ошибка в расчетах."
          view-as alert-box error.
       end.
    END CASE.
end.
/* $Workfile$ e n d */