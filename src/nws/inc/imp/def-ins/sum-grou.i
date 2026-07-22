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

define buffer buf_sum-group          for ub.sum-group.
define buffer buf_sum-in-sum-group   for ub.sum-in-sum-group.
define buffer buf_c-sum-group        for ub.c-sum-group.
define buffer buf_c-sum-in-sum-group for ub.c-sum-in-sum-group.

define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.

for each locb-sum-group
on error  undo, return error
:
  delete locb-sum-group.
end.


for each locb-c-sum-group
on error  undo, return error
:
  delete locb-c-sum-group.
end.

for each locb-sum-in-sum-group
on error  undo, return error
:
  delete locb-sum-in-sum-group.
end.

for each locb-c-sum-in-sum-group
on error  undo, return error
:
  delete locb-c-sum-in-sum-group.
end.