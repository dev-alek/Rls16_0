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

define buffer buf_doc-xyz-def-obj  for ub.doc-xyz-def-obj.
define buffer buf_doc-xyz-def-doc  for ub.doc-xyz-def-doc.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.

for each locb-doc-xyz-def-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-doc-xyz-def-obj.
end.
for each locb-doc-xyz-def-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-doc-xyz-def-doc.
end.