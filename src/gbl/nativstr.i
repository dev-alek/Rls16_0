/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/03/07
Author: Bakhtadze Natalya
Creation date: 09/03/07

*/

&if defined(nativstr_i) = 0 &then

&glob nativstr_i



&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


function native-string returns character ( input p-string as character
                                          ,input p-data-type as character
                                          ,input p-format as character):
define variable v-string as character no-undo .
case p-data-type:
  when {&abl-datatype-character} then do:
    assign
    v-string = string(p-string, p-format)
    no-error .
  end.
  when {&abl-datatype-date} then do:
    assign
    v-string = string(date(p-string), p-format)
    no-error .
  end.
  when {&abl-datatype-decimal} then do:
    assign
    v-string = string(decimal(p-string), p-format)
    no-error .
  end.
  when {&abl-datatype-integer} then do:
    assign
    v-string = string(integer(p-string), p-format)
    no-error .
  end.
  when {&abl-datatype-logical} then do:
    assign
    v-string = string(logical(p-string), p-format)
    no-error .
  end.
end case.
return v-string.
end function.

&endif