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

define buffer buf_xyz-analysis-obj           for ub.xyz-analysis-obj          .
define buffer buf_xyz-analysis-doc           for ub.xyz-analysis-doc          .
define buffer buf_xyz-analysis-attr          for ub.xyz-analysis-attr         .
define buffer buf_xyz-analysis-period        for ub.xyz-analysis-period       .
define buffer buf_xyz-analysis-goods         for ub.xyz-analysis-goods        .
define buffer buf_xyz-analysis-gds-obj       for ub.xyz-analysis-gds-obj      .
define buffer buf_xyz-analysis-goods-attr    for ub.xyz-analysis-goods-attr   .
define buffer buf_xyz-analysis-gds-obj-attr  for ub.xyz-analysis-gds-obj-attr .

def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.

for each locb-xyz-analysis-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-obj.
end.
for each locb-xyz-analysis-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-doc.
end.
for each locb-xyz-analysis-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-attr.
end.
for each locb-xyz-analysis-period
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-period.
end.
for each locb-xyz-analysis-goods
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-goods.
end.
for each locb-xyz-analysis-gds-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-gds-obj.
end.
for each locb-xyz-analysis-goods-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-goods-attr.
end.
for each locb-xyz-analysis-gds-obj-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-gds-obj-attr.
end.