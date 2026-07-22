/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История типов прайс-листов

Автор: Чернова Светлана Александровна
Дата создания: 06/08/06
Author: Svetlana Chernova
Creation date: 06/08/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_c-price-list-type               for ub.c-price-list-type             .
define buffer buf_c-price-list-type-pay-type      for ub.c-price-list-type-pay-type    .
define buffer buf_c-price-list-type-cassa         for ub.c-price-list-type-cassa       .
define buffer buf_c-price-list-type-gds-grp       for ub.c-price-list-type-gds-grp     .
define buffer buf_c-price-list-type-attr          for ub.c-price-list-type-attr        .
define buffer buf_c-price-list-type-cash-pay      for ub.c-price-list-type-cash-pay    .


define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.

for each locb-c-price-list
on error  undo, return error
:
  delete locb-c-price-list.
end.


for each locb-c-price-list-type-pay-type
on error  undo, return error
:
  delete locb-c-price-list-type-pay-type.
end.

for each locb-c-price-list-type-cassa
on error  undo, return error
:
  delete locb-c-price-list-type-cassa.
end.

for each locb-c-price-list-type-gds-grp
on error  undo, return error
:
  delete locb-c-price-list-type-gds-grp.
end.

for each locb-c-price-list-type-attr
on error  undo, return error
:
  delete locb-c-price-list-type-attr.
end.

for each locb-c-price-list-type-cash-pay
on error  undo, return error
:
  delete locb-c-price-list-type-cash-pay.
end.