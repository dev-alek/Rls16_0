/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/27/06
Author: Bakhtadze Natalya
Creation date: 04/27/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


procedure low-ascii :
define input parameter p-string as character no-undo .
define input parameter p-silence as logical no-undo .

define variable ii as integer no-undo .
define variable v-symbol as character no-undo .
define variable v-mess as character no-undo .
  do
  on error undo, return error return-value
  :
     do ii = 1 to length(p-string):
       v-symbol = substring(p-string, ii, 1).
       if asc(v-symbol) > 127 then do:
          v-mess =  substitute("Неверный символ &1 в строке &2", v-symbol, p-string).
          if not p-silence then do:
            message
            v-mess
            view-as alert-box error .
          end.
          undo, return error .
       end.
     end.

  end.

end procedure. /* low-ascii */

/* $Workfile$ e n d */