/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функция получающая № смены по буферу (для показа в справочниках)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/13/06
Author: Bakhtadze Natalya
Creation date: 01/13/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

function shift-name return character ( buffer loc-{1} for ub.{1} ) :
  if loc-{1}.shift-date = ? then do:
    return "":u.
  end.
  else do:
    if loc-{1}.shift-num = integer(loc-{1}.shift-name) then do:
      return loc-{1}.shift-name.
    end.
    else do:
      return loc-{1}.shift-name + "(" + string(loc-{1}.shift-num) + ")".
    end.
  end.
end function.

/* $Workfile$ e n d */