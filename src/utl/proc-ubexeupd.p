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

{cmp/str-glbl.i}
{utl/search.i}
define stream Ostream.

{ utl/proc-async.i proc_def}
run PutStatAsunc (substitute("Запущен процесс обновления болванки")).
define variable mCommand as character no-undo.
define variable m7z as character no-undo.
define variable mUbexe as character no-undo.
define variable mDirUb as character no-undo.
define variable mDbConnet as character no-undo.
define variable mVer      as character no-undo.

run gbl/getvers.p (OUTPUT mVer).
mVer = replace(mVer,".","_").
m7z    = search("exe\7z.exe").
mUbexe = search("exe\ub" + mVer + ".exe").
os-create-dir value("ub" + mVer) .
if os-error <> 0 then do:
   run PutStatAsunc (substitute("Невозможно создать директорию ub&1",mVer)).
   
end.
else do:
   mDirUb = objExists ("ub" + mVer,"d").
   mCommand = substitute('&1 x &2 -o"&3" &4 rem del &2',m7z ,mubexe, mdirub, {&ampersand}).
   if session:system-alert-boxes
   then do:
      output stream Ostream to "1extr.bat".
      put stream Ostream unformatted replace (mCommand,{&ampersand},{&carriage-return} + {&new-line}).
      output stream Ostream close.
   end. 
   run PutStatAsunc (substitute("Распаковываем болванку ")).
   os-command silent value (mCommand).
   mDbConnet = substitute("-db &1\ub.db -ld ub -1 -U sysadm -P sysadm ", mdirub).
   run PutStatAsunc (substitute("Распаковка болванки завершена.")).
   connect value(mDbConnet) no-error.
   if error-status:error
   then do:
     def var vtext as char no-undo.
     vtext =  substitute( "Не удалось подключиться к болванке с параметрами: &1  Ошибка &2"
                          ,mDbConnet
                          ,error-status :get-message(1)
                           ).
      run PutStatAsunc ("Error " + vtext).
   end.
   else do:
/*      subscribe "PutStat" anywhere run-procedure "SetErr".*/
      run utl\ubexeupddb.p (this-procedure,mDbConnet) no-error.
/*      unsubscribe "PutStat".*/
      if error-status:error
      then do:
         vtext =  substitute( "Ошибка при обновлении болванки &1"
                          ,error-status :get-message(1)
                           ).
         run PutStatAsunc ("Error " + vtext).
         mError = yes.
      end.
      disconnect ub no-error .
      if not mError 
      then do:
         mCommand = substitute('del /Q &2 &4 del /Q &3\ub.lg &4 &1 u -mx9 -r0 -sfx &2 &3\* &4 del /Q &3 &4 exit',m7z ,mubexe, mdirub, {&ampersand}).
         if session:system-alert-boxes
         then do:
            output stream Ostream to "2pack.bat".
            put stream Ostream unformatted replace (mCommand,{&ampersand},{&carriage-return} + {&new-line}).
            output stream Ostream close.
         end.
         run PutStatAsunc (substitute("Запаковываем болванку ")).
         os-command value (mCommand).
         run PutStatAsunc (substitute("Запаковка болванки завершена.")).
      end.
   end.
end.
{ utl/proc-async.i proc_end}
 