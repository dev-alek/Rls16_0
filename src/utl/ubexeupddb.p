block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 17 авг. 2021 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 17 авг. 2021 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "обновление болванки".
{ cmp/vssrevis.i }

define input  parameter iLogHandel as handle no-undo.
define input  parameter iConPar as character no-undo.
{ utl/proc-async.i proc_def}
run PutStatAsunc (substitute("Запущен процес обновления БД. " )).
define variable updschmObj as class ibs.th.adm.upd.updschm no-undo.

updschmObj = new ibs.th.adm.upd.updschm (input iconpar,input "updblank",this-procedure) no-error.

if error-status:error
then do:
   run PutStatAsunc (substitute("error   Не удалось обновить структуру БД. &1 &2 &3 ", error-status:get-message(1),  error-status:get-message(2 ),  program-name( 1 ) )).
end.
else if updschmObj:IsErr
then do:
   run PutStatAsunc (substitute("error   Не удалось обновить структуру БД. &1 &2 ", updschmObj:Msg, program-name( 1 ) )).
   delete object updschmObj no-error.
end.
else if updschmObj:isNeedUpd
then do:
   updschmObj:upddbshm().
   if updschmObj:IsErr
   then do:
      run PutStatAsunc (substitute("error Не удалось обновить структуру БД. &1", updschmObj:Msg )).
      delete object updschmObj no-error.
   end.
   else if updschmObj:isUpdShm
   then do:
      run PutStatAsunc (substitute("БД обновлена. " )).
   end.
   else do:
      run PutStatAsunc (substitute("error Ошика при обновлении БД. &1",updschmObj:Msg )).
   end.
end.
else do:
   if updschmObj:CurrDBShm > updschmObj:TargetDBShm
   then do:
      run PutStatAsunc (substitute("error Версия базы &1 больше версии в сборке &2 ",updschmObj:CurrDBShm , updschmObj:TargetDBShm)).
   end.
   else
      run PutStatAsunc (substitute("error Обновление не требуется.")).
   
end.   
{ utl/proc-async.i proc_end}

