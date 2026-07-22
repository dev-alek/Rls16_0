/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функция для показа user-name по u s e r i d

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/13/06
Author: Bakhtadze Natalya
Creation date: 11/13/06

предполагает наличие library.p

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
{ gbl/usrfulnm.i
  p-user-id
  v-user-name
  no-error }
if error-status:error
or v-user-name = ""
then do:
  return p-user-id.
end.
else do:
  return v-user-name.
end.

end function.


/* $Workfile$ e n d */