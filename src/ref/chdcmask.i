/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функция проверки соответствия данного кода данной маске

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/14/04
Author: Bakhtadze Natalya
Creation date: 12/14/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

function check-by-mask returns logical (
  input p-mask  as character
  ,input p-str as character
   ,output p-descr as character
  ).

define variable ii as integer no-undo .
define variable v-max as integer no-undo .
define variable v-mask-char as character no-undo .
assign
v-max = length (p-mask).
_do:
do ii = 1 to v-max:
  assign
  v-mask-char = substring(p-mask, ii, 1).
  if v-mask-char = {&question-mark} then NEXT _do.
  if v-mask-char = "*":U then do:
    if ii < v-max then do:
      assign
      p-descr = substitute("неверная маска &1: звездочка может быть только последним символом маски").
      return no .
    end.
    return yes.
  end.
  else do:
    if v-mask-char <> substring(p-str, ii, 1) then do:
      assign
      p-descr = substitute("№ ДК &1 не соответствует МАСКЕ &2", p-str, p-mask).
      return no.
    end.
    next _do.
  end.
end.
if v-mask-char = {&question-mark} and v-max = length(p-str) then return yes.


end function.

/* $Workfile$ e n d */