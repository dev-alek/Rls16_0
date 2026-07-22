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
function total-doc-qnty return decimal
( input p-rec as recid  ) :
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return ? .
  return ( t-d.doc-qnty ).
end function.

function total-fact-qnty return decimal
( input p-rec as recid  ) :
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return ? .
return ( t-d.fact-qnty ).
end function.

function total-sum return decimal
( input p-rec as recid  ) :
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return ? .
  return ( if t-d.print-rubl = yes then t-d.tot-rubl else t-d.tot-doc ).
end function.

function total-dsc return decimal
( input p-rec as recid  ) :
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return ? .
  return ( if t-d.print-rubl = yes then t-d.discnt-rubl  else t-d.tot-doc - t-d.tot-cli ).
end function.

function total-dsc-fact return decimal
( input p-rec as recid  ) :
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return ? .
  return ( if t-d.print-rubl = yes then t-d.discnt-rubl else t-d.tot-calc ).
end function.
/* $Workfile$ e n d */