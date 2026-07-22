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
define variable mError as logical no-undo.
{ cmp/vssrevis.i }
{ gbl/getcntxt.i def }
{ cmp/trg-def.i  new}

{ utl/proc-async.i proc_def}

define variable mParam as character no-undo.
mParam = GetPARAMAsunc( 1).
if mParam eq ? then do:
   run PutstatAsunc( "error   Получение данных было преврвано пользователем." ).
   
end.
else do:
   if mParam eq "*"
   then do:
      for each db no-lock:
         mParam = (if mParam eq "*" then "" else ( mParam + ",")) + string(db.db-num). 
      end.
   end.
   run bge\auto-merc.p(this-procedure, mParam) no-error.
   if error-status:error
   then
      run PutstatAsunc( "error  Произошли ошибки при выполнение."  ).
   if    StopCheck()
   then do:
      run PutstatAsunc( "error   Получение данных было преврвано пользователем." ).
   end.
end.
{ utl/proc-async.i proc_end}