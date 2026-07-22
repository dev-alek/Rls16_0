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

define buffer buf_abcxyz-analysis-attr           for ub.abcxyz-analysis-attr    .
define buffer buf_abcxyz-analysis-goods          for ub.abcxyz-analysis-goods   .
define buffer buf_abcxyz-analysis-goods-attr     for ub.abcxyz-analysis-goods-attr.

def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.

for each locb-abcxyz-analysis-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abcxyz-analysis-attr.
end.

for each locb-abcxyz-analysis-goods-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abcxyz-analysis-goods-attr.
end.

for each locb-abcxyz-analysis-goods
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abcxyz-analysis-goods.
end.