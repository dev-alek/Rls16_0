/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Набор функций для работы с акцизными и специальными марками.

Автор: Хныкин Павел Андреевич
Дата создания: 12/24/07
Author: Pavel Khnykin
Creation date: 12/24/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

function exmrklib_get-type-name returns character
  ( input p-mark-type as integer ) :
  define variable ret    as character no-undo .

  case p-mark-type:
      when 0 then ret = "Специальная".
      when 1 then ret = "Акцизная".
      otherwise   ret = "<неизвестен>".
  end case.

  return ret .

end function.


function exmrklib_get-status-name returns character
  ( input p-stts as integer ) :

&scop status-code string(p-stts)

  return {&status-int-name} .

end function.


/* $Workfile$ e n d */