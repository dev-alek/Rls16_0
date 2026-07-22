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
define buffer buf_ord-gds-cons      for ub.ord-gds-cons.
define buffer buf_ord-dtl-cons      for ub.ord-dtl-cons.

def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-ord-gds-cons
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-gds-cons.
end.

for each locb-ord-dtl-cons
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-dtl-cons.
end.