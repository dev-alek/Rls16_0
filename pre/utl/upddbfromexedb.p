block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "обновление болванки".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define input  parameter iLogHandel as handle no-undo.
define input  parameter iConPar as character no-undo.
define input  parameter iDFfile as character no-undo.
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
run PutStatAsunc (substitute("Запущен процес обновления БД. " )).
define variable updschmObj as class ibs.th.adm.upd.updschm no-undo.
define variable mname     as character no-undo.
define variable mpassword as character no-undo.
updschmObj = new ibs.th.adm.upd.updschm (input iconpar,input "OneDf",this-procedure,iDFfile) no-error.
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
