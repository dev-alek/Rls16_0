/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/07
Author: Bakhtadze Natalya
Creation date: 04/12/07

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


procedure set-error :
define input parameter p-mess as character no-undo .

  do
  on error undo, return error
  :
     assign
     v-last-error-message = p-mess.
  end.

end procedure. /* seterror */

/* $Workfile$ e n d */