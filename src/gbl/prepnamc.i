/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Àâòîð: Áàõòàäçå Íàòàëüÿ Âèêòîðîâíà
Äàòà ñîçäàíèÿ: 09/10/08
Author: Bakhtadze Natalya
Creation date: 09/10/08

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION prep-nameorcode RETURNS CHARACTER
  ( input p-nameorcode as character ) :
define variable v-nameorcode as character no-undo .
define variable v-dopi as character no-undo .
if trim(p-nameorcode) = '' then  return ''.
v-nameorcode = trim( trim( p-NameOrCode) , "*" ) .
if index(v-NameOrCode, {&double-quote} ,1 ) = 1
and R-index(v-NameOrCode, {&double-quote} ,1 ) = 1 then do:
  assign
  v-NameOrCode = trim(v-NameOrCode, {&double-quote})
  .
end.
assign
v-dopi = substring(v-NameOrCode, length(v-NameOrCode), 1)
.
if index("abcdefghijklmnopqrstuvwxyzàáâãäå¸æçèéêëìíîïðñòóôõö÷øùúûüýþÿ", v-dopi) > 0
or index("1234567890", v-dopi) > 0
then do:
  v-NameOrCode = v-NameOrCOde + "*".
end.
v-NameOrCode = LC(v-NameOrCode).

RETURN v-nameorcode.   /* Function return value. */

END FUNCTION.

/* $Workfile$ e n d */