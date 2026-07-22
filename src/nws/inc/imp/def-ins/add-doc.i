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

define buffer buf_add-line         for ub.add-line    .
define buffer buf_add-trn          for ub.add-trn   .
define buffer buf_add-trn-attr     for ub.add-trn-attr.
define buffer buf_doc-line-attr    for ub.doc-line-attr.

def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.

for each locb-add-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-add-line.
end.

for each locb-add-trn-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-add-trn-attr.
end.

for each locb-add-doc-line-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-add-doc-line-attr.
end.

for each locb-add-trn
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-add-trn.
end.