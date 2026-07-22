block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: pr-ut10.p $
$Archive: utl/pr-ut10.p $

Пересчет закрытой переоценки (с заданием номера)

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 02/19/04 6:06

*/


{ cmp/trg-def.i  }
{ gbl/waitfram.i }

define buffer buf_price-doc  for price-doc  .
define buffer buf_price-list for price-list .
define variable col-part as integer no-undo .
define variable temp1 as integer init 10 no-undo .
define variable v-all as integer init 0 no-undo .
define variable v-nun as character no-undo .
  run gbl/d-prompt.w
    ( 'title=Введите Номер переоценки\'
    + 'format=x(15)\'
    + 'type=char\'
    ,input-output v-nun
    ).
  if return-value = 'false':u
  then do:
    return .
  end.
find first price-doc no-lock where price-doc.doc-num =  v-nun no-error .
if error-status :error then do:
   message "Не верно введен номер переоценки!!" view-as alert-box error .
   return error return-value .
end.
if price-doc.status_ <> {&act-overvalue} then do:
   message "Переоценка не закрыта на АКТ!!" view-as alert-box error .
   return error return-value .
end.

 run str/pr-oldd.p (price-doc.doc-num )  no-error .
 if error-status :error then do:
   message
   "Ошибка процедуры pr-oldd.p"
   error-status :get-message(1) view-as alert-box error .
   return error return-value .
end.