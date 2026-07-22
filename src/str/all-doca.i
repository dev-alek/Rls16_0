/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 08/28/07
Author: Svetlana Chernova
Creation date: 08/28/07

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function f-{1} returns char
( input p-rec as recid  ) .
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return '' .
define buffer d-a for ub.doc-attr.
find first d-a no-lock where d-a.doc-code = t-d.doc-code and d-a.attr-code = '{1}' no-error .
if avail d-a then do:
  if num-entries (d-a.attr-value,'/') = 3 then return ( entry(3,d-a.attr-value,'/') + entry(2,d-a.attr-value,'/') + entry(1,d-a.attr-value,'/') ).
  else return d-a.attr-value.
end.
else return '' .
end function.