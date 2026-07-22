block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 9 марта 2020 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 9 марта 2020 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
/*
session:system-alert-boxes = yes.
session:appl-alert-boxes = yes.
session:debug-alert = yes.
*/
{ cmp/str-glbl.i }
{ utl/proc-async.i proc_def}
{ adm/auto-def.i}
{ cmp/trg-def.i}
{ nws/nws-def.i  new }
{ gbl/getcntxa.i }
/*writelogvalue = "AsyncProc".*/
run nws/nws-init.p no-error.
if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Error Ошибка инициализации переменных для системы передачи новостей" skip
      return-value
      view-as alert-box error.
    
end.
else do:
   define variable mDB as character no-undo.
   mDB = GetParamAsunc( 1).
   if mDB eq ? then do:
      
      run PutstatAsunc( "error   Получение данных было преврвано пользователем." ).
      return.
   end.
   else
      run PutstatAsunc(substitute ("Отправка и получение новостей по БД &1", mdb)).
   run nws/exch-nws.p (this-procedure,?,?,mDB).
end.
