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

define buffer buf_ord-line      for ub.ord-line.
define buffer buf_ord-dtl       for ub.ord-dtl.
define buffer buf_ord-line-attr      for ub.ord-line-attr.
define buffer buf_ord-doc-attr       for ub.ord-doc-attr.


def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.

for each locb-ord-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-line.
end.

for each locb-ord-line-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-line-attr.
end.

for each locb-ord-doc-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-doc-attr.
end.

for each locb-ord-dtl
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-dtl.
end.