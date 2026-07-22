define input parameter iTableList as character no-undo.
define variable vi as integer no-undo.
define variable vTableList as character no-undo.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable mAsyncProc as class ibs.th.file.AsyncProc.
run ibs\th\file\getasyncproc.p (output mAsyncProc).
define variable mstopAsunc as logical no-undo.
function StopCheck returns logical:
   define variable oFlag as logical no-undo.
   run StopCheckAsync (output oFlag).
   return oFlag.
end.
procedure StopCheckAsync:
    define output  parameter oFlag as logical no-undo.
    if mstopAsunc
    then
       oFlag = mstopAsunc.
    else do:
       oFlag = mAsyncProc:CheckStop().
       mstopAsunc = oFlag.
    end.
end.
function GetParamAsunc returns character
(input iNumPar as integer  ):
   return mAsyncProc:GetPARAM(iNumPar).
end.
function GetParamAsuncStr returns ibs.th.file.asyncparam
(input iParamName as character ):
   return mAsyncProc:GetPARAM(iParamName).
end.
procedure PutMesAsunc:
    define input  parameter Itext as character no-undo.
    define variable vflag as logical no-undo.
    Publish "WriteLogAsunc" (Itext, yes)  .
end.
procedure PutMesAsuncNoTime:
    define input  parameter Itext as character no-undo.
    define variable vflag as logical no-undo.
    Publish "WriteLogAsunc" (Itext,no)  .
end.
procedure PutStatAsunc:
    define input  parameter Itext as character no-undo.
    Publish "PutStatAsunc" (Itext,no) .
     run
    PutMesAsunc (itext).
end.
procedure PutStatAsuncNoTime:
    define input  parameter Itext as character no-undo.
    Publish "PutStatAsunc" (Itext,no)  .
     run
    PutMesAsuncNoTime (itext).
end.
procedure PutStatAsuncAdd:
    define input  parameter Itext as character no-undo.
    Publish "PutStatAsunc" (Itext,yes)  .
end.
procedure PutFileLogAsunc:
    define input  parameter IFile as character no-undo.
    Publish "PutFileLogAsunc" (ifile)  .
end.
       mAsyncProc:mProcPublish = this-procedure.
vTableList = trim(iTableList,'"').
function copytable returns logical (itable_old as character, itable_new as character ) forward.
run putStatAsunc in this-procedure ("Копирование данных в новую структуру...").
def var mtablename as char no-undo.
do vi = 1 to num-entries (vTableList,"|"):
   mtablename  = entry(vi,vTableList,"|").
   run putStatAsunc in this-procedure ("Копирование данных в новую структуру. Обработка таблицы " + mtablename ).
   copytable(mtablename + "_old", mtablename).
end.
function copytable returns logical (itable_old as character, itable_new as character ):
   define variable vBufTargetTable as handle no-undo.
   define variable vBufSourseTable as handle no-undo.
   define variable vQuery          as handle no-undo.
   define variable vi as int64 no-undo.
   create buffer vBufTargetTable for table itable_new.
   vBufTargetTable:disable-load-triggers (false).
   create buffer vBufSourseTable for table itable_old.
   create query vQuery.
   vQuery:set-buffers(vBufSourseTable).
   vQuery:query-prepare("preselect EACH " + vBufSourseTable:name + " no-lock").
   vQuery:query-open().
   vQuery:get-first().
   do while vBufSourseTable:available:
      if vi mod 1000 = 0 then
        run putStatAsunc in this-procedure
          (substitute("Копирование данных в новую структуру. Oбработка таблицы &1. Обработано записей: &2 из &3.",
          itable_new, vi, vQuery:num-results)).
      do transaction:
         vBufTargetTable:buffer-create ().
         vBufTargetTable:buffer-copy (vBufSourseTable).
         vBufTargetTable:buffer-release ().
         vBufSourseTable:find-current (exclusive-lock).
         vBufSourseTable:buffer-delete ().
      end.
      vi = vi + 1.
      vQuery:get-next().
   end.
   vQuery:query-close().
   delete object vQuery.
   delete object vBufTargetTable.
   delete object vBufSourseTable.
end.
