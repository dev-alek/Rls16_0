/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Перенумерование строк в документе

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 03/24/06


*/
procedure renum :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_trn-doc  for ub.trn-doc.
define buffer bf_doc-line for ub.doc-line.
define variable varline-num as integer no-undo.
define query q-doc-line for bf_doc-line.
do on error undo, return error return-value :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
if error-status:error then do:
  return error substitute("Не найден документ с номером &1", pardoc-code).
end.
open query q-doc-line preselect each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code use-index line-num exclusive-lock.
get first q-doc-line.
assign varline-num = 0.
do while available(bf_doc-line):
   assign varline-num = varline-num + 1.
   assign
     bf_doc-line.line-num = varline-num.
   get next q-doc-line.
end.
end.
end procedure.