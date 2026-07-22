block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
define variable mError as logical no-undo.
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
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
define stream Ostream.
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
   mCommand = substitute('&1 x &2 -o"&3" &4 rem del &2',m7z ,mubexe, mdirub, chr(38)).
   if session:system-alert-boxes
   then do:
      output stream Ostream to "1extr.bat".
      put stream Ostream unformatted replace (mCommand,chr(38),chr(13) + chr(10)).
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
      run utl\ubexeupddb.p (this-procedure,mDbConnet) no-error.
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
         mCommand = substitute('del /Q &2 &4 del /Q &3\ub.lg &4 &1 u -mx9 -r0 -sfx &2 &3\* &4 del /Q &3 &4 exit',m7z ,mubexe, mdirub, chr(38)).
         if session:system-alert-boxes
         then do:
            output stream Ostream to "2pack.bat".
            put stream Ostream unformatted replace (mCommand,chr(38),chr(13) + chr(10)).
            output stream Ostream close.
         end.
         run PutStatAsunc (substitute("Запаковываем болванку ")).
         os-command value (mCommand).
         run PutStatAsunc (substitute("Запаковка болванки завершена.")).
      end.
   end.
end.
