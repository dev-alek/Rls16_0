/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

объявление таблиц

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_abc-analysis-obj           for ub.abc-analysis-obj          .
define buffer buf_abc-analysis-doc           for ub.abc-analysis-doc          .
define buffer buf_abc-analysis-attr          for ub.abc-analysis-attr         .
define buffer buf_abc-analysis-period        for ub.abc-analysis-period       .
define buffer buf_abc-analysis-goods         for ub.abc-analysis-goods        .
define buffer buf_abc-analysis-gds-obj       for ub.abc-analysis-gds-obj      .
define buffer buf_abc-analysis-goods-attr    for ub.abc-analysis-goods-attr   .
define buffer buf_abc-analysis-gds-obj-attr  for ub.abc-analysis-gds-obj-attr .

def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.

for each locb-abc-analysis-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-obj.
end.
for each locb-abc-analysis-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-doc.
end.
for each locb-abc-analysis-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-attr.
end.
for each locb-abc-analysis-period
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-period.
end.
for each locb-abc-analysis-goods
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-goods.
end.
for each locb-abc-analysis-gds-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-gds-obj.
end.
for each locb-abc-analysis-goods-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-goods-attr.
end.
for each locb-abc-analysis-gds-obj-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-gds-obj-attr.
end.