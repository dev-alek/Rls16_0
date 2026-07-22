/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

РАСЧЕТ ean-13

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/19/07
Author: Bakhtadze Natalya
Creation date: 07/19/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

function ean-13 returns character ( input p-code as character
                                   ,input DC-PFX as character):

define variable Dc-frmt as character no-undo INIT "ean13".
define variable FULL-B-CODE as character no-undo .

{ str/bc-gnrti.i "Dc" "p-code" "full-b-code" }

return full-b-code .

end function.