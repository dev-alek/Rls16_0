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

define buffer buf_rang-xyz-def-obj for ub.rang-xyz-def-obj  .

def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.

for each locb-rang-xyz-def-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-rang-xyz-def-obj.
end.