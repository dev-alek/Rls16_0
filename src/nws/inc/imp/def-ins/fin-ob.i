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

define buffer buf_fin-ob-tax      for ub.fin-ob-tax.
define buffer buf_fin-ob-trn      for ub.fin-ob-trn.
define buffer buf_fin-gds-part    for ub.fin-gds-part.

def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.

for each locb-fin-ob-tax
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-ob-tax.
end.
for each locb-fin-ob-trn
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-ob-trn.
end.
for each locb-fin-gds-part
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-gds-part.
end.
