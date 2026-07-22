/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_global-state        for ub.global-state.
define buffer buf_global-state-attr   for ub.global-state-attr.
define buffer buf_c-global-state      for ub.c-global-state.
define buffer buf_c-global-state-attr for ub.c-global-state-attr.

define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.

for each locb-global-state
on error  undo, return error
:
  delete locb-global-state.
end.


for each locb-c-global-state
on error  undo, return error
:
  delete locb-c-global-state.
end.

for each locb-global-state-attr
on error  undo, return error
:
  delete locb-global-state-attr.
end.

for each locb-c-global-state-attr
on error  undo, return error
:
  delete locb-c-global-state-attr.
end.