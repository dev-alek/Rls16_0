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

define buffer buf_buyer-in-buyer-group   for ub.buyer-in-buyer-group.
define buffer buf_c-buyer-in-buyer-group for ub.c-buyer-in-buyer-group.

define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.

for each locb-buyer-in-buyer-group
on error  undo, return error
:
  delete locb-buyer-in-buyer-group.
end.

for each locb-c-buyer-in-buyer-group
on error  undo, return error
:
  delete locb-c-buyer-in-buyer-group.
end.