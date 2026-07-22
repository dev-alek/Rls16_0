/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_c-doc-line      for ub.c-doc-line.
define buffer buf_c-doc-line-attr for ub.c-doc-line-attr.
define buffer buf_c-gds-dtl       for ub.c-gds-dtl.
define buffer buf_c-parts         for ub.c-parts.
define buffer buf_c-doc-prts      for ub.c-doc-prts.
define buffer buf_c-doc-pl        for ub.c-doc-pl.
define buffer buf_c-doc-pl-pump   for ub.c-doc-pl-pump.
define buffer buf_c-parts-attr    for ub.c-parts-attr.
define buffer buf_c-parts-root    for ub.c-parts-root.
define buffer buf_c-doc-attr      for ub.c-doc-attr.
define buffer buf_c-doc-fbr-gds   for ub.doc-fbr-gds.

def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.

for each locb-c-doc-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-line.
end.
for each locb-c-doc-line-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-line-attr.
end.
for each locb-c-gds-dtl
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-gds-dtl.
end.
for each locb-c-parts
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-parts.
end.
for each locb-c-parts-root
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-parts-root.
end.

for each locb-c-parts-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-parts-attr.
end.
for each locb-c-doc-prts
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-prts.
end.
for each locb-c-doc-pl
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-pl.
end.
for each locb-c-doc-pl-pump
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-pl-pump.
end.
for each locbt-c-doc-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbt-c-doc-attr.
end.
for each locb-c-doc-fbr-gds
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-fbr-gds.
end.