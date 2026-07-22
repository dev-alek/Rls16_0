/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Работа с типами sum-id

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/25/07
Author: Bakhtadze Natalya
Creation date: 03/25/07

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION propreft-Date-to-String returns character(input  p-date as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + {&slash-char} +
             string(Month(p-date), "99":U) + {&slash-char} +
             string(DAY(p-date), "99":U).
return v-date-str.
END FUNCTION.

function propreft-string-to-date returns date ( input p-string  as character):

  define variable v-date as date no-undo .

  assign
  v-date = date(integer(substring(p-string, 6, 2))
                ,integer(substring(p-string, 9, 2))
                ,integer(substring(p-string, 1, 4))
               ) no-error .
  if error-status:error then return ?.
  return v-date.

END FUNCTION.


FUNCTION propreft-petrol-to-String returns character(input  p-gds-code as integer):
define variable v-date-str as character no-undo .
assign
v-date-str = substitute("petrol-&1", p-gds-code).
return v-date-str.
END FUNCTION.

FUNCTION propreft-string-to-petrol returns integer(input  p-string as character):
define variable v-gds-code as integer no-undo .
assign
v-gds-code = integer(entry(2, p-string, "-")) no-error.
return v-gds-code.
END FUNCTION.



/* $Workfile$ e n d */



