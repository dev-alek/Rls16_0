/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Типы прайс-листов

Автор: Чернова Светлана Александровна
Дата создания: 06/08/06
Author: Svetlana Chernova
Creation date: 06/08/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_price-list-type                 for ub.price-list-type               .
define buffer buf_price-list-type-pay-type        for ub.price-list-type-pay-type      .
define buffer buf_price-list-type-cassa           for ub.price-list-type-cassa         .
define buffer buf_price-list-type-gds-grp         for ub.price-list-type-gds-grp       .
define buffer buf_price-list-type-attr            for ub.price-list-type-attr          .
define buffer buf_price-list-type-cash-pay        for ub.price-list-type-cash-pay      .


define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.

for each locb-price-list-type
on error  undo, return error
:
  delete locb-price-list-type.
end.


for each locb-price-list-type-pay-type
on error  undo, return error
:
  delete locb-price-list-type-pay-type.
end.


for each locb-price-list-type-cassa
on error  undo, return error
:
  delete locb-price-list-type-cassa.
end.


for each locb-price-list-type-gds-grp
on error  undo, return error
:
  delete locb-price-list-type-gds-grp.
end.

for each locb-price-list-type-attr
on error  undo, return error
:
  delete locb-price-list-type-attr.
end.

for each locb-price-list-type-cash-pay
on error  undo, return error
:
  delete locb-price-list-type-cash-pay.
end.