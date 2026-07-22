block-level on error undo, throw.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable g#auto-pid           as integer   no-undo .
define new shared variable conn-par             as character no-undo .
define new shared variable g#auto-user-id       as character no-undo .
define new shared variable g#auto-user-login    as character no-undo .
define new shared variable g#auto-user-password as character no-undo .
define new shared variable v-socket             as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable auto-window-h     as handle    no-undo .
define new shared variable auto-log-msg-h    as handle    no-undo .
define new shared variable hand-log-msg-h    as handle    no-undo .
define new shared variable log-file-name     as character no-undo initial ? .
define new shared variable add-log-file-name as character no-undo initial ? .
define new shared variable writelogvalue     as character no-undo initial ? .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new  shared variable g#auto as logical no-undo.
define new  shared variable g#news as logical no-undo.
define new  shared variable g#oxml as logical no-undo.
define new  shared variable g#esys as logical no-undo.
define new  shared variable g#news-source-db as integer no-undo.
define new  shared variable g#esys-source-esys as integer no-undo.
define new  shared variable g#db-num as integer   no-undo .
define new  shared variable g#userid as character no-undo .
define new  shared variable g#passwd as character no-undo .
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
define variable mAsuncStopUser as logical no-undo.
procedure WriteLogAsunc:
    define input  parameter Itext as character no-undo.
    define input  parameter IFlag as logical   no-undo.
    define variable vflag as logical no-undo.
    mAsyncProc:PutMes(input Itext, input IFlag).
    run StopCheckAsync(output vflag).
    if vflag
    then do:
       mAsuncStopUser = yes.
       stop.
    end.
end.
procedure SetGblError:
   define input  parameter Itext as character no-undo.
   define variable vtext as character no-undo.
   if mAsuncStopUser
   then do:
      vtext = "Error Операция прервана пользователем.".
      mAsyncProc:PutMes(vtext).
   end.
   else do:
      if Itext eq ?
      then
         vtext = "Error Ошибка при выполнениее асинхроного процесса".
      else
         vtext = "Error " + vtext.
      mAsyncProc:SetGblError(input Itext).
   end.
end.
function objExists return character
(input  ifolder as character,
 input  iType   as character  ):
    define variable vFileType as character no-undo init "D,F".
    define variable vi        as integer no-undo.
    define variable vtype as character no-undo.
    if iType ne ?
    then
       vFileType = iType.
    do vi = 1 to num-entries(vFileType):
       file-information:file-name = ".\" + right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index(vtype , entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
       file-information:file-name = right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if file-information:file-name <> "" and
          entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index( vtype, entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
    end.
    return ? .
end.
function SearchFile return character
(input  ifile as character):
   return objExists(ifile,?).
end.
function SearchPFile return character
(input inFile as char):
     define variable oFile       as character no-undo.
     define variable vFileSearch as character no-undo.
     define variable vNumEntry   as integer no-undo.
     if inFile = "" then return ?.
     vNumEntry = num-entries(inFile,".").
     vFileSearch = inFile.
     if    vNumEntry > 0
        and (   entry(vNumEntry,inFile,".") eq "p"
             or entry(vNumEntry,inFile,".") eq "w")
     then do:
        entry(vNumEntry,vFileSearch, ".") = "r".
        oFile = search(vFileSearch ).
        if oFile eq ?
        then
           oFile = search(inFile).
     end.
     else
        oFile = search(vFileSearch).
     return oFile.
  end.
procedure writeFileLogAsunc:
    define input  parameter IFile as character no-undo.
    ifile = searchfile(ifile).
    if ifile ne ?
    then
       mAsyncProc:Nextlog(ifile).
end.
procedure WriteStatAsunc:
    define input  parameter IText    as character no-undo.
    define input  parameter IFlagAdd as logical no-undo.
   mAsyncProc:putStatus (Itext,IFlagAdd).
end.
procedure IsAsyncProc:
   define output parameter oIsAsync as logical no-undo.
   oIsAsync = yes.
end.
define variable mnum   as integer no-undo.
define variable mCount as integer no-undo.
subscribe "StopProc"           anywhere run-procedure "StopCheckAsync".
subscribe "WriteLogAsunc"      anywhere.
subscribe "PutStatAsunc"       anywhere run-procedure "WriteStatAsunc".
subscribe "PutFileLogAsunc"    anywhere run-procedure "writeFileLogAsunc" .
subscribe "IsAsyncProc"        anywhere .
output to "errorasync.log".
mAsyncProc:BegRec () .
mNum   = int(mAsyncProc:GetPARAM("numSession"):valueparam).
mCount = int(mAsyncProc:GetPARAM("countSession"):valueparam).
mAsyncProc:creatProcInfo(1,mNum,mCount).
mAsyncProc:WritelogInter = decimal (mAsyncProc:GetPARAM("WritelogInter"):valueparam).
define variable mDbConnect as logical no-undo.
define variable mName as character  no-undo.
define variable mpassword as character  no-undo.
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, retry MAIN-BLOCK
   on end-key undo MAIN-BLOCK, retry MAIN-BLOCK
   on stop    undo MAIN-BLOCK, retry MAIN-BLOCK:
   if retry
   then do:
      run SetGblError(?).
      leave MAIN-BLOCK.
   end.
writelogvalue = "AsyncProc".
define variable mProc       as char no-undo.
define variable mParam      as character no-undo.
define variable mParamName  as character no-undo.
define variable mParamValue as character no-undo.
define variable mNumEntries as integer no-undo.
define variable mI          as integer no-undo.
define variable mSetGblPar  as logical no-undo.
mname = GetParamAsuncStr("User"):valueparam.
mpassword = GetParamAsuncStr("password"):valueparam.
mProc = GetParamAsuncStr("procedure"):valueparam.
mDbConnect = logical(GetParamAsuncStr("DbConnect"):valueparam).
mSetGblPar = logical(GetParamAsuncStr("SetGblPar"):valueparam).
if mSetGblPar eq ?
then
   mSetGblPar = true.
if     mProc ne ?
   and mProc ne ""
then do:
      run adm/autoinit.p ( input mname
                             ,input mpassword
                     ) no-error.
      if error-status :error then do:
         run PutMesAsunc ("Error " + error-status:get-message (1)).
      end.
      else do:
         if mDbConnect
         then do:
            run adm/autoconn.p no-error.
            if error-status :error
            then do:
               run PutMesAsunc ("Error Не удалось подключиться к БД: " + return-value) .
            end.
            else do:
               if     mname ne ""
                  and mSetGblPar
               then
               run gbl/set-gbl-async.p
                  (input  true
                  ,input  mName
                  ,input  mpassword
                  ).
               if search(mProc) ne ?
               then do:
                  run value(mProc) no-error.
                  if error-status :error
                  then do:
                     run PutMesAsunc (substitute ("Error Ошибка запуска процедуры &1 : &2 ",mProc, return-value)) .
                  end.
               end.
            end.
         end.
         else do:
            if search(mProc) ne ?
            then do:
               run value(mProc) no-error.
               if error-status :error
               then do:
                  run PutMesAsunc (substitute ("Error Ошибка запуска процедуры &1 : &2 ",mProc, return-value)) .
               end.
            end.
         end.
      end.
   end.
else
   run PutMesAsunc ("Error Не переданы параметры.") .
end.
finally:
   mAsyncProc:EndRec ()  .
   unsubscribe "StopProc".
   unsubscribe "WriteLogAsunc".
   unsubscribe "PutStatAsunc".
   unsubscribe "PutFileLogAsunc".
   unsubscribe "IsAsyncProc".
   delete object mAsyncProc.
   output close.
   output to "endproc.txt".
   output close.
   quit.
end.
