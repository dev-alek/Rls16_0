/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функция получения псевдонима пользовател

Автор: Белоусов Илья Александрович
Дата создания: 11/12/07
Author: Ilia Belousov
Creation date: 11/12/07

предполагает наличие library.p

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

function usrnickf returns character ( input p-user-id as character):

   define variable v-nick      as character    no-undo.
   if p-user-id = ?
   OR p-user-id = "":U
   then do:
      return '':U .
   end.

   { gbl/usrnick.i
   p-user-id
   v-nick
   no-error }

   if error-status :error
   then do:
      return p-user-id.
   end.
   else do:
      return v-nick.
   end.

end function. /* usrnickf */


/* $Workfile$ e n d */