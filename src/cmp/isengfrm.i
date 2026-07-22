/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Строка подобна числу в инж формате

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION IsEngFrm RETURNS Logical  ( INPUT p-str as char) :
DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE v-int as integer no-undo .
DEFINE VARIABLE v-char as character no-undo .
DEFINE VARIABLE v-dec as decimal no-undo .

if p-str begins '0':U then return yes.
if index(p-str, "E":U ) = 0 then return no.
if index(p-str, "+":U ) = 0
AND index(p-str, "-":U ) = 0 then return no.


assign
v-dec = decimal(entry(1, p-str, "E":U))
no-error .
if error-status:error then return no.
assign
v-int = integer(entry(2, p-str, "E":U))
no-error .
if error-status:error then return no.
assign
v-char = entry(2, p-str, "E":U)
.
if (substr(v-char, 1, 1) = "+":U and index(v-char, "-":U) = 0 )
OR
(substr(v-char, 1, 1) = "-":U and index(v-char, "+":U) = 0 )
then return yes.

END FUNCTION.



/* $Workfile$ e n d */