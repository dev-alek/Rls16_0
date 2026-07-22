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

define buffer buf_db-grp-obj-price    for ub.db-grp-obj-price  .
define buffer buf_host-grp-obj-price  for ub.host-grp-obj-price.
define buffer buf_obj-grp-obj-price   for ub.obj-grp-obj-price .
define buffer buf_grp-obj-price       for ub.grp-obj-price     .

define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.

for each locb-grp-obj-price
on error  undo, return error
:
  delete locb-grp-obj-price.
end.


for each locb-db-grp-obj-price
on error  undo, return error
:
  delete locb-db-grp-obj-price.
end.


for each locb-host-grp-obj-price
on error  undo, return error
:
  delete locb-host-grp-obj-price.
end.

for each locb-obj-grp-obj-price
on error  undo, return error
:
  delete locb-obj-grp-obj-price.
end.