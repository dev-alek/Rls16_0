/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Корректировка Длинного сообщения из библиотеки АССМАТРИЦ

Автор: Чернова Светлана Александровна
Дата создания: 07/09/09
Author: Svetlana Chernova
Creation date: 07/09/09


*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure correct-message :
define input  parameter p-longchar as longchar no-undo .

define variable v-longchar as longchar no-undo .
define variable v-err-ext  as logical  no-undo .

  do
  on error undo, return error return-value
  :
   run get-long-message in this-procedure  (output v-longchar ).
/*
   message 'correct-message' skip
   'было     : ' string(v-longchar) skip
   'добавили + '    string(p-longchar) skip
   view-as alert-box information .
*/
    v-longchar = v-longchar + p-longchar.
    v-err-ext  = true .
    run set-long-message  in this-procedure  (input v-longchar,  input v-err-ext ).

  end.

end procedure. /* correct-message */

define variable v-longchar as longchar no-undo .
define variable v-err-ext as logical   no-undo .

procedure get-long-message  :
define output parameter p-longchar  as longchar no-undo .
  do
  on error undo, return error return-value
  :
     p-longchar = v-longchar .
  end.
end procedure. /* get-long-message  */
procedure set-long-message :
define input  parameter  p-longchar as longchar   no-undo .
define input  parameter  p-err-ext as logical   no-undo .
  do
  on error undo, return error return-value
  :
    v-longchar  =  p-longchar .
    v-err-ext   =  p-err-ext  .
  end.
end procedure. /* set-long-message */