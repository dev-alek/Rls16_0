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

define buffer buf_qnty-group          for ub.qnty-group.
define buffer buf_qnty-in-qnty-group   for ub.qnty-in-qnty-group.
define buffer buf_c-qnty-group        for ub.c-qnty-group.
define buffer buf_c-qnty-in-qnty-group for ub.c-qnty-in-qnty-group.

define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.

for each locb-qnty-group
on error  undo, return error
:
  delete locb-qnty-group.
end.

for each locb-c-qnty-group
on error  undo, return error
:
  delete locb-c-qnty-group.
end.

for each locb-qnty-in-qnty-group
on error  undo, return error
:
  delete locb-qnty-in-qnty-group.
end.

for each locb-c-qnty-in-qnty-group
on error  undo, return error
:
  delete locb-c-qnty-in-qnty-group.
end.