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

define buffer buf_turnover-group          for ub.turnover-group.
define buffer buf_tnv-in-turnover-group   for ub.tnv-in-turnover-group.
define buffer buf_c-turnover-group        for ub.c-turnover-group.
define buffer buf_c-tnv-in-turnover-group for ub.c-tnv-in-turnover-group.

define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.

for each locb-turnover-group
on error  undo, return error
:
  delete locb-turnover-group.
end.

for each locb-c-turnover-group
on error  undo, return error
:
  delete locb-c-turnover-group.
end.

for each locb-tnv-in-turnover-group
on error  undo, return error
:
  delete locb-tnv-in-turnover-group.
end.

for each locb-c-tnv-in-turnover-group
on error  undo, return error
:
  delete locb-c-tnv-in-turnover-group.
end.