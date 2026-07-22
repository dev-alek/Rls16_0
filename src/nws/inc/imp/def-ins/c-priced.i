/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История переоценки

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_c-price-doc       for ub.c-price-doc.
define buffer buf_c-price-list      for ub.c-price-list.
define buffer buf_c-price-list-attr for ub.c-price-list-attr.
define buffer buf_c-doc-attr        for ub.c-doc-attr.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.

for each locb-c-price-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-price-doc.
end.


for each locb-c-price-list
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-price-list.
end.

for each locb-c-doc-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-attr.
end.

for each locb-c-price-list-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-price-list-attr.
end.
