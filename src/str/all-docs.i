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
function total-fact return decimal  ~
( input p-rec as recid  ) . ~
def buffer t-d for ub.trn-doc . ~
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return ? . ~
return (if t-d.print-rubl then t-d.tot-sale else t-d.tot-fact). ~
end function. ~

function first-symb-type return char  ~
( input p-rec as recid  ) . ~
def buffer t-d for ub.trn-doc . ~
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return chr(1) . ~
return (substring (t-d.doc-type, 1, 1)).                    ~
end function. ~

function day-month return char ~
( input p-rec as recid  ) . ~
def buffer t-d for ub.trn-doc . ~
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return chr(1) . ~
return (substring ((string (t-d.doc-date)), 1, 5)).        ~
end function.  ~

function shift-day-month return char ~
( input p-rec as recid  ) . ~
def buffer t-d for ub.trn-doc . ~
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return chr(1) . ~
return (substring ((string (t-d.shift-date)), 1, 5)).      ~
end function.  ~

function object-label return char  ~
( input p-rec as recid  ) . ~
def buffer t-d for ub.trn-doc . ~
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return chr(1) . ~
return (trim (t-d.obj-type)  + string (t-d.obj-code)). ~
end function.  ~

function fcli-name return character   ~
( input p-rec as recid  ) . ~
def buffer t-d for ub.trn-doc . ~
find first t-d no-lock where recid(t-d) = p-rec no-error . if error-status :error then return chr(1) . ~
return t-d.cli-name .  ~
end function.

function total-pay-fact return character
( input p-rec as recid  ) .
def buffer loc-t-doc for ub.trn-doc .
find first loc-t-doc no-lock where recid(loc-t-doc) = p-rec no-error . if error-status :error then return chr(1) .
if loc-t-doc.doc-type = {&inventory} then return "" .
if (loc-t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} or loc-t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}) and v-sale <> yes then return "?" .
if loc-t-doc.doc-type = {&income} and
   loc-t-doc.internal = no        then do:
  return string ( loc-t-doc.tot-calc , "->,>>>,>>>,>>>,>>9.99" ).
end.
else do:
  return string( ( if loc-t-doc.print-rubl then (loc-t-doc.tot-sale - loc-t-doc.discnt-rubl) else (loc-t-doc.tot-fact - loc-t-doc.tot-calc) ) , "->,>>>,>>>,>>>,>>9.99" ).
end.
end function.

function total-acc return decimal
( input p-rec as recid  ) .
def buffer loc-t-doc for ub.trn-doc .
find first loc-t-doc no-lock where recid(loc-t-doc) = p-rec no-error . if error-status :error then return ? .
  if (loc-t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} or loc-t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}) and v-sale <> yes then return ?.
  return (if loc-t-doc.print-rubl then loc-t-doc.fact-rubl else loc-t-doc.fact-base).
end function.

function shift-name return character
( input p-rec as recid  ) .
def buffer loc-t-doc for ub.trn-doc .
find first loc-t-doc no-lock where recid(loc-t-doc) = p-rec no-error . if error-status :error then return ? .
  if loc-t-doc.shift-date = ? then do:
    return "":u.
  end.
  else do:
    if loc-t-doc.shift-num = integer(loc-t-doc.shift-name) then do:
      return loc-t-doc.shift-name.
    end.
    else do:
      return loc-t-doc.shift-name + "(" + string(loc-t-doc.shift-num) + ")".
    end.
  end.
end function.

/* Документ закрыт задним числом; простое форматирование */
function closed-backdated return character
( input p-rec as recid ) .
def buffer loc-t-doc for ub.trn-doc .
find first loc-t-doc no-lock where recid(loc-t-doc) = p-rec no-error . if error-status :error then return ?.
  return ( if loc-t-doc.is-back-date then "+" else "" ).
end function.
