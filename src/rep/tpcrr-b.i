/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура делает Радио-сет по типу приобретениЯ

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 11/27/02 2:00

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure cr-ob :
 do
 on error undo, return error return-value
 :
define input parameter p-x as integer no-undo . /* coordinats in frame */
define input parameter p-y as integer no-undo .
define input parameter type-pr-name as character no-undo .
define input parameter type-pr-val  as character no-undo .


define variable l-str as character no-undo .
define variable i as integer no-undo .

if type-pr-name = ? then type-pr-name = 'Все,Выкуп,Консигнаци,Консигнация закупка,Консигнация выгода,Ответственное хранение,Старая консигнация':L .
if type-pr-val  = ?then type-pr-val  = 'all,r,cb,c,b,s,1':U .


repeat i = 1 to num-entries(type-pr-name) :
 l-str =  l-str  + entry(i ,type-pr-name) + ","  +
                   entry(i ,type-pr-val)  + "," .
end.

l-str = substring(l-str,1 , LENGTH (l-str) - 1) .

if num-entries(l-str) < 2 then do:
    message "Нет архивов по типу приобретения !!!" skip
    vss-include-info{&vssseq} skip
    view-as alert-box information .
    return 'First-page':U.
   end.

   create radio-set type-pr
   assign
    row    = p-y
    column = p-x
    frame  = frame {&frame-name}:handle
    horizontal    = false
    radio-buttons = l-str
 .


if valid-handle(type-pr) = false then do:
    message "Нет архивов по типу приобретения !!!" skip
    vss-include-info{&vssseq} skip
    view-as alert-box information .
    return 'First-page':U.
 end.

  type-pr:sensitive = yes  .
  type-pr:visible   = yes  .

 end. /* do */
end procedure. /* cr-ob */
/* $Workfile$ e n d */