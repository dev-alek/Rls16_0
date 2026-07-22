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
function mark-string return character
( input p-rec as recid  ) .
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return '' .
return ( if lookup(string(recid(t-d)),mark-list) > 0 then '*' else '' ).
end function.
function factur return char
( input p-rec as recid  ) .
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return '' .
 if t-d.cr-factur = yes then do:
   return string(t-d.factur-date).
 end.
 else do:
   if t-d.need-factur = 0 then  return '0'.
   if t-d.need-factur = 1 then  return '1'.
   if t-d.need-factur = 2 then  return '2'.
 end.
end function.
function fo-buyer return char
( input p-rec as recid  ) .
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return '' .
 if t-d.cr-fo-buyer = yes then do:
   return string (t-d.buyer-fo-date).
 end.
 else do:
   if t-d.need-buyer = 0 then return '0'.
   if t-d.need-buyer = 1 then return '1'.
   if t-d.need-buyer = 2 then return '2'.
 end.
end function.
function fo-realiz return integer
( input p-rec as recid  ) .
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return ? .
 if t-d.cr-expfo = yes then do:
   return int (t-d.expfo-date).
 end.
 else do:
   if t-d.need-expfo = 0 then return 0.
   if t-d.need-expfo = 1 then return 1.
   if t-d.need-expfo = 2 then return 2.
 end.
end function.
function fo-postavka return character
( input p-rec as recid  ) .
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return '' .
 if t-d.cr-incfo = yes then do:
   return string (t-d.incfo-date).
 end.
 else do:
   if t-d.need-incfo = 0 then return '0'.
   if t-d.need-incfo = 1 then return '1'.
   if t-d.need-incfo = 2 then return '2'.
 end.
end function.
function total-vat return decimal
( input p-rec as recid  ) .
def buffer t-d for ub.trn-doc .
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return ? .
return (if t-d.print-rubl then t-d.vat-rubl else t-d.vat-base).
end function.