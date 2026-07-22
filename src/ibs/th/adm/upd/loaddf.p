/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обновление схемы БД через df 

Автор: Морозов Александр Сергеевич
Дата создания: 04/23/18
Author: Morozov Alexandr
Creation date: 04/23/18


*/
{ utl/proc-async.i proc_def}
{ utl/search.i }
current-window:hidden = yes. 
define input  parameter iparam as character no-undo.
run PutMesAsunc ("Загружаем df в базу" ).

run PutFileLogAsunc(iparam).
os-delete "ub.e".
run prodict/load_df.r (iparam + ",no") no-error.
define variable mfile as character no-undo.
mfile = searchFile("ub.e").
file-info:file-name = mfile.
if file-info:file-name ne ? and 
  file-info:file-size ne 0
then do:
   run PutMesAsunc ("Error Ошибка обновления БД" ).
   run PutFileLogAsunc(mfile).
end. 
        
{ utl/proc-async.i proc_end}



