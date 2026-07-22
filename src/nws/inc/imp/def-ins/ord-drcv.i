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
define buffer buf_ord-line-rcv      for ub.ord-line-rcv.
define buffer buf_ord-dtl-rcv       for ub.ord-dtl-rcv.
define buffer buf_ord-line      for ub.ord-line.
define buffer buf_ord-dtl       for ub.ord-dtl.
define buffer buf_ord-doc       for ub.ord-doc.
define buffer buf_ord-rcv-line-attr for ub.ord-rcv-line-attr.
define buffer buf_ord-rcv-attr  for ub.ord-rcv-attr.
define buffer buf_ord-line-attr for ub.ord-line-attr.
define buffer buf_ord-doc-attr  for ub.ord-doc-attr.

def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.

for each locb-ord-line-rcv
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-line-rcv.
end.
for each locb-ord-rcv-line-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-rcv-line-attr.
end.
for each locb-ord-rcv-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-rcv-attr.
end.

for each locb-ord-dtl-rcv
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-dtl-rcv.
end.

for each rcvlocb-ord-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete rcvlocb-ord-line.
end.
for each rcvlocb-ord-line-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete rcvlocb-ord-line-attr.
end.

for each rcvlocb-ord-dtl
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete rcvlocb-ord-dtl.
end.
for each rcvlocb-ord-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete rcvlocb-ord-doc.
end.

for each rcvlocb-ord-doc-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete rcvlocb-ord-doc-attr.
end.