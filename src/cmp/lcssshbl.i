/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функция получения шаблона для кодов по их начальному и конечному значению


Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION MakeShbl RETURNS CHARACTER(input par-int1 as integer, input par-int2 as integer):
DEFINE VARIABLE ii as integer no-undo init 1.
DEFINE VARIABLE var-char1 as character no-undo .
DEFINE VARIABLE var-char2 as character no-undo .
DEFINE VARIABLE par-shbl as character no-undo .

/*если их длина разная то ошибка*/
assign
var-char1 = string(par-int1)
var-char2 = string(par-int2)
.

if length(var-char1) <> length(var-char2) then return error.

do while ii <= length(var-char1):
  if substring(var-char1, ii, 1) = substring(var-char2, ii, 1) then do:
    par-shbl = par-shbl + substring(var-char1, ii, 1).
  end.
  else do:
    par-shbl = par-shbl + fill("?", length(var-char1) - length(par-shbl)).
    return par-shbl.
  end.
  ii = ii + 1.

end.
END FUNCTION.


/* $Workfile$ e n d */