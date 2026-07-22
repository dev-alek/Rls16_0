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
run PutStatAsunc (substitute("Запущен процесс обновления")).
define variable mCommand as character no-undo.
define variable m7z as character no-undo.
define variable mUbexe as character no-undo.
define variable mDirUb as character no-undo.
define variable mDbConnet as character no-undo.
define variable mVer      as character no-undo.
session:system-alert-boxes = yes.
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
   mCommand = substitute('&1 x &2 -o"&3" -y &4 rem del &2',m7z ,mubexe, mdirub, {&ampersand}).
   if session:system-alert-boxes
   then do:
      output stream Ostream to "1extr.bat".
      put stream Ostream unformatted replace (mCommand,{&ampersand},{&carriage-return} + {&new-line}).
      output stream Ostream close.
   end. 
   run PutStatAsunc (substitute("Распаковываем болванку ")).
   os-command silent value (mCommand).
   mDbConnet = substitute("-db &1\ub.db -ld zub -1 -U sysadm -P sysadm ", mdirub).
   run PutStatAsunc (substitute("Распаковка болванки завершена.")).
   
   define variable mOrigdb as character no-undo.
   define variable mProwin as character no-undo.
   mProwin = search("bin/prowin32.exe").
   mOrigdb = GetParamAsunc(1).
   run PutStatAsunc (substitute("Сравниваем БД с болванкой ")).
   /*--------------------------------------------------------------------   
   https://docs.progress.com/ru-RU/bundle/openedge-database-tools-117/page/Batch-Incremental-utility.html
This command line utility creates a .df file from comparing two OpenEdge databases. A new file called prodict/dump_inc.p is parallel to prodict/dump_df.p and prodict/load_df.p. Procedure dump_inc.p will query the following environmental variables:

DUMP_INC_DFFILE — Name of file to dump to
DUMP_INC_CODEPAGE — Output code page
DUMP_INC_INDEXMODE — Index-mode for newly created indexes; allowed values are active or inactive
DUMP_INC_RENAMEFILE — Name of the file that contains rename information. The format of this file is:
T, <old-table-name>,<new-table-name>
F, <table-name>,<old-field-name>,<new-field-name>
S,<old-sequence-name>,<new-sequence-name>
Note: There is no need to rename indexes because the code compares index elements and changes them automatically.
DUMP_INC_DEBUG
0 = debug off, only errors and important warnings
1 = all the above plus warnings
2 = all the above plus configuration information
The first connected database is the source database and automatically receives the alias DICDB.

Use the following code to call the "dump_inc.p" procedure:

OpenEdge-install-dir/bin/_progres -b -db source-db -db target-db -p prodict/dump_inc.p
The resulting delta.df file can then be applied to the target database, giving it the same definitions as the source database.
--------------------------------------------------------------------*/ 
 /*создание не активных индексов не работает в 10 progress ативируем при загрузке */  
   mCommand = substitute ("set DUMP_INC_INDEXMODE=active &4 set DUMP_INC_DEBUG=0 &4 &1 -b &2 &3 -p prodict/dump_inc.p &4 exit",
   /**/
   mProwin, mDbConnet,mOrigdb ,{&ampersand}).
   if session:system-alert-boxes
   then do:
      output stream Ostream to "2Compare.bat".
      put stream Ostream unformatted replace (mCommand,{&ampersand},{&carriage-return} + {&new-line}).
      output stream Ostream close.
   end.
   os-command silent value (mCommand).
   run PutStatAsunc (substitute("Выгружен результат сравнения БД и Болванки ")).
   define variable mDFDelta as character no-undo.
/*   run gbl\inidebug.p.*/
   mDFDelta = searchFile("delta.df").
   if mDFDelta ne ?
   then do:
      run PutFileLogAsunc(mDFDelta).
      define stream  sReadfile.
      define variable mText as character no-undo.
      input  stream sReadfile FROM  VALUE(mDFDelta ).
      import stream sReadfile unformatted mText.
      input  stream sReadfile close.
      if mText begins "."
      then
         run PutStatAsunc (substitute("Error Базы равны ")).
      else do:
         if index(GetPARAMAsunc(2),"UpdateDB=yes") eq 0
         then
            run PutStatAsunc (substitute('Error В базах есть расхождения, для обновляния базы по полванке запустите сесию с параметром -param "UpdateDB=yes" ')).
         else do:
            connect value(mOrigdb) no-error.
            if error-status:error
            then do:
              def var vtext as char no-undo.
              vtext =  substitute( "Не удалось подключиться к основной БД с параметрами: &1  Ошибка &2"
                                   ,mDbConnet
                                   ,error-status :get-message(1)
                                    ).
               run PutStatAsunc ("Error " + vtext).
            end.
            else do:
               run utl\upddbfromexedb.p (this-procedure,mOrigdb,mDFDelta) no-error.
               if error-status:error
               then do:
                  vtext =  substitute( "Ошибка при обновлении БД &1"
                                   ,error-status :get-message(1)
                                    ).
                  run PutStatAsunc ("Error " + vtext).
               end.
               disconnect ub no-error .
            end.
         end.
      end.
   end.
   else
      run PutStatAsunc (substitute("Error Не удалось создать файл расхождений ")).
   
end.
{ utl/proc-async.i proc_end}
 