block-level on error undo, throw.
.session:debug-alert = yes.
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
if    StopCheck()
then do:
   run PutstatAsunc(substitute("error   Получение счетчика было преврвано пользователем или по TimeOut.") ).
   return.
end.
define variable  mfilename as character no-undo.
mfilename = GetPARAMAsunc(1).
define variable mKey as character   no-undo.
mkey = GetPARAMAsunc(2).
define variable  mCode as character no-undo.
mCode  = GetPARAMAsunc(3).
define variable  mParam as character no-undo.
mParam  = GetPARAMAsunc(4).
if     mfilename ne ?
   and mkey      ne ?
   and mCode     ne ?
then do:
   define variable mCounterValue as int64 no-undo.
   define variable mCounterStor as class ibs.th.ref.counter.counterstorage.
   mCounterStor = new ibs.th.ref.counter.counterstorage().
   mCounterValue = mCounterStor:GetNextcount(mFileName, mKey, mcode,mParam).
   delete object mCounterStor.
   run PutMesAsuncNoTime(string(mCounterValue)).
end.
