/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 06/08/06
Author: Svetlana Chernova
Creation date: 06/08/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_turnover-buyer-main       for ub.turnover-buyer-main      .
define buffer buf_turnover-buyer            for ub.turnover-buyer           .
define buffer buf_turnover-buyer-gds        for ub.turnover-buyer-gds       .
define buffer buf_turnover-buyer-attr       for ub.turnover-buyer-attr      .
define buffer buf_turnover-buyer-gds-attr   for ub.turnover-buyer-gds-attr  .

define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.

for each locb-turnover-buyer-main
on error  undo, return error
:
  delete locb-turnover-buyer-main.
end.


for each locb-turnover-buyer
on error  undo, return error
:
  delete locb-turnover-buyer.
end.


for each locb-turnover-buyer-gds
on error  undo, return error
:
  delete locb-turnover-buyer-gds.
end.

for each locb-turnover-buyer-gds-attr
on error  undo, return error
:
  delete locb-turnover-buyer-gds-attr.
end.

for each locb-turnover-buyer-attr
on error  undo, return error
:
  delete locb-turnover-buyer-attr.
end.