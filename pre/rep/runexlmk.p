block-level on error undo, throw.
define input parameter tempfile as char no-undo.
define input parameter p-list-name as char no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: runexlmk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/runexlmk.p $":U .
define variable vss-description as character no-undo init "Вывод в Excel с запуском дополнительной сессии".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable tempfile-frm as character no-undo .
define variable tempfile-t-t as character no-undo .
define variable res          as integer   no-undo .
define variable v-cmdln      as character no-undo .
define variable v-exefile    as character no-undo .
define variable v-inifile    as character no-undo .
define variable err-file     as character no-undo .
define stream forformat .
do
on error undo, return error return-value
:
  define variable v-full-path        as character no-undo .
  define variable v-path             as character no-undo .
  define variable v-file-name        as character no-undo .
  define variable v-file-name-no-ext as character no-undo .
  define variable v-file-name-ext    as character no-undo .
  run gbl/filename.p (input  tempfile, output v-full-path, output v-path, output v-file-name, output v-file-name-no-ext, output v-file-name-ext) .
  assign
    tempfile-frm = v-path + '/':u + v-file-name-no-ext + '.':U + 'frm':U
    tempfile-t-t = v-path + '\':u + v-file-name-no-ext + '.':U + 't-t':U
  .
  run mcr-rep-mk (input tempfile-t-t, input v-path + '\':u + v-file-name-no-ext, input p-list-name) .
  os-delete  value( tempfile-t-t ) .
  os-delete  value( tempfile  ) .
  define variable err-status as integer   no-undo .
  err-status = OS-ERROR.
  IF err-status <> 0 THEN  return "disable-button":U.
                     else  return.
end.
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-param no-undo   field param-code     as character   field param-sub-code as character   field param-value    as character   index xpk is primary unique param-code param-sub-code   .
procedure paramls-clear :
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    for each buf_temp-param
    on error undo, return error
    :
      delete buf_temp-param .
    end.
  end.
end procedure.
procedure paramls-write :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
      .
    end.
    assign
      buf_temp-param.param-value = p-value
    .
  end.
end procedure.
procedure paramls-read :
  define input  parameter p-code          as character no-undo .
  define input  parameter p-sub-code      as character no-undo .
  define input  parameter p-default-value as character no-undo .
  define output parameter p-value         as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if available buf_temp-param then do:
      assign
        p-value = buf_temp-param.param-value
      .
    end.
    else do:
      assign
        p-value = p-default-value
      .
    end.
  end.
end procedure.
procedure paramls-append :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
         where buf_temp-param.param-code     = p-code
           and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
        buf_temp-param.param-value    = p-value
      .
    end.
    else do:
        assign
            buf_temp-param.param-value = buf_temp-param.param-value + ",":U + p-value
        .
    end.
  end.
end procedure.
define stream  inStream  .
procedure mcr-rep-mk :
  define input parameter  v-file-name as character no-undo .
  define input parameter  v-file-name1 as character no-undo .
  define input parameter  v-list-name as character no-undo .
  do
  on error undo, return error return-value
  :
  define variable v-count  as integer no-undo .
  define variable v-param-code     as character no-undo .
  define variable v-param-sub-code as character no-undo .
  define variable v-param-value    as character no-undo .
  input stream instream from value (v-file-name) .
  repeat  :
    assign
      v-count = v-count + 1
      v-param-code     = ''
      v-param-sub-code = ''
      v-param-value    = ''
    .
    import stream instream  v-param-code  v-param-sub-code  v-param-value .
    create temp-param .
    assign
      temp-param.param-code     = v-param-code
      temp-param.param-sub-code = v-param-sub-code
      temp-param.param-value    = v-param-value
    .
  end.
  input stream instream close .
  define variable v-ok as logical   no-undo .
  run macroexl-mk (input v-file-name1, input v-list-name, input-output table temp-param  ) .
  os-delete value (v-file-name) .
  define buffer buf_temp-param for temp-param .
  for each buf_temp-param  where buf_temp-param.param-code = "file" on error undo, return error :
    os-delete value(buf_temp-param.param-value) .
  end.
  end.
end procedure.
define buffer buf_temp-param for temp-param .
define variable chExcelApp   as com-handle no-undo .
define variable chWorkBook   as com-handle no-undo .
define variable chCodeModule as com-handle no-undo .
define variable v-ind              as integer   no-undo .
define variable v-excel-macro-file as character no-undo .
define variable v-ok               as logical   no-undo .
procedure macroexl-mk :
  define input parameter v-file-name as character no-undo .
  define input parameter v-list-name as character no-undo .
  define input-output parameter table for temp-param .
  do
  on error undo, return error return-value
  :
  define variable v-excel-file-name as character no-undo .
  define variable v-read-password   as character no-undo .
  define variable v-write-password  as character no-undo .
  define variable v-excel-dir-name  as character no-undo .
  assign
    v-excel-file-name = v-file-name + ".xls"
  .
  if search(v-excel-file-name) <> ? then do:
    os-delete value(v-excel-file-name) .
  end.
  define variable v-column-list as character no-undo .
  run paramls-read in this-procedure  (input  "charcol" ,input  "" ,input  "" ,output v-column-list ) .
  create "Excel.Application" chExcelApp no-error .
  if error-status :error then do:
    message
      "Ошибка при запуске Excel" skip
      error-status :get-message(1) skip
      view-as alert-box error .
    undo, return error .
  end.
  define variable v-excel-visible-char as character no-undo .
  run paramls-read  (input "option",input "visible",input "true",output v-excel-visible-char ) .
  assign
    chExcelApp :Visible = lookup(v-excel-visible-char, "true,yes") > 0
  .
  assign
    chExcelApp :WindowState = -4143
    chExcelApp :Visible     = True
    chExcelApp :Interactive = False
  .
  assign
    chWorkBook = chExcelApp :Workbooks :Add()
  .
  assign
    chCodeModule = chWorkbook :VBProject :VBComponents :Item(1) :CodeModule
  .
  run export-macro in this-procedure .
  for each buf_temp-param
    where buf_temp-param.param-code = "file"
  by buf_temp-param.param-sub-code descending
  on error undo, return error
  :
    assign
      file-info :file-name = buf_temp-param.param-value
    .
    assign
      v-excel-macro-file = file-info :full-pathname
    .
    if v-excel-macro-file = ?
    or v-excel-macro-file = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден файл" buf_temp-param.param-value skip
        "param-code" buf_temp-param.param-code skip
        "param-sub-code" buf_temp-param.param-sub-code skip
        view-as alert-box error .
      undo, next .
    end.
    assign  v-ok = chWorkbook :DDEExec(v-excel-macro-file,v-list-name , v-column-list) .
  end.
  for each buf_temp-param
    where buf_temp-param.param-code = "command"
  by buf_temp-param.param-sub-code
  on error undo, leave
  :
    assign
      v-ok = chWorkbook :DDEExecCommand(buf_temp-param.param-value)
    .
  end.
  run clear-macro in this-procedure .
  assign
    chExcelApp :DisplayAlerts = False
  .
  define variable v-default-excel-file-name as character no-undo .
  assign
    v-default-excel-file-name = chWorkBook :FullName
  .
  if  v-read-password <> ""  and v-write-password <> "" then do:
    assign
      v-ok = chWorkBook :SaveAs(v-excel-file-name, -4143  ,v-read-password ,v-write-password , , , ) no-error
    .
  end.
  else do:
    if v-write-password <> "" then do:
      assign
        v-ok = chWorkBook :SaveAs(v-excel-file-name, -4143 , ,v-write-password , , , ) no-error
      .
    end.
    else do:
      assign
        v-ok = chWorkBook :SaveAs(v-excel-file-name, -4143 , , , , , ) no-error
      .
    end.
  end.
  assign
    chExcelApp :DisplayAlerts = True
  .
  assign
    v-excel-file-name = chWorkBook :FullName
  .
  if v-excel-file-name = v-default-excel-file-name
  or v-excel-file-name = ? then do:
    release object chCodeModule no-error .
    release object chWorkBook   no-error .
    release object chExcelApp   no-error .
    message
      "Ошибка при сохранении файла" skip
      "Сохраните Excel файл вручную" skip
      view-as alert-box information .
  end.
  else do:
    assign
      chWorkBook :Saved = true
    .
    assign
      v-ok = chWorkBook :Close
    .
    release object chCodeModule no-error .
    release object chWorkBook   no-error .
    assign
      v-ok = chExcelApp:Quit() no-error
    .
    release object chExcelApp   no-error .
  end.
  end.
end procedure.
procedure append-macro-line :
  define input  parameter p-macro-str as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-ind = v-ind + 1
    .
    assign
      v-ok = chCodeModule :InsertLines(v-ind, p-macro-str )
    .
  end.
end procedure.
procedure export-test-macro :
  assign
    v-ind = 0
  .
  do
  on error undo, return error return-value
  :
    run append-macro-line (input 'Sub HelloWorld()').
    run append-macro-line (input '  MsgBox "HelloWorld"').
    run append-macro-line (input 'End Sub').
  end.
end procedure.
procedure export-macro :
  assign
    v-ind = 0
  .
  do
  on error undo, return error return-value
  :
    run append-macro-line (input 'Sub DDEExec(FileName$, SheetName$, numColList$)').
    run append-macro-line (input '  Application.ScreenUpdating = False').
    run append-macro-line (input '  Application.Interactive = False').
    run append-macro-line (input '  Set NewSheet = Sheets.Add(Type:=xlWorksheet)').
    run append-macro-line (input '  NewSheet.Name = SheetName$').
    run append-macro-line (input '  dim ind as long').
    run append-macro-line (input '  dim vshowmess as boolean').
    run append-macro-line (input '  vshowmess = true').
    run append-macro-line (input '  callList(numColList$)').
    run append-macro-line (input '  Open FileName$ For Input As #1').
    run append-macro-line (input '  ind = 0').
    run append-macro-line (input '  Do Until EOF(1)').
    run append-macro-line (input '    Line Input #1, vCommand').
    run append-macro-line (input '    ind = ind + 1').
    run append-macro-line (input '    if ind mod 3000 = 0 then').
    run append-macro-line (input '      Application.StatusBar = "Импорт из " & FileName$ & " Строк " & CStr(ind)').
    run append-macro-line (input '      Application.ScreenUpdating = True').
    run append-macro-line (input '      Application.ScreenUpdating = False').
    run append-macro-line (input '    end if').
    run append-macro-line (input '    On Error Resume Next').
    run append-macro-line (input '    ExecuteExcel4Macro (vCommand)').
    run append-macro-line (input '    If (Err.Number <> 0) and (vshowmess = true) Then').
    run append-macro-line (input '      Dim vCancelMacro As Integer').
    run append-macro-line (input '      vCancelMacro = MsgBox("Ошибка " & Err.Number & Chr(13) & "Команда " & vCommand & Chr(13) & "Файл " & FileName$ & Chr(13) & "Строка файла " & ind & Chr(13) & "Yes - Продолжить выполнение программы" & Chr(13) & "No - Продолжить выполнение программы и не выводить сообщения об ошибках" & Chr(13) & "Cancel - Прервать выполнение программы" & Chr(13), vbYesNoCancel)').
    run append-macro-line (input '      Select Case vCancelMacro').
    run append-macro-line (input '        Case vbYes').
    run append-macro-line (input '        Case vbNo').
    run append-macro-line (input '          vshowmess = false').
    run append-macro-line (input '        Case vbCancel').
    run append-macro-line (input '          Close #1').
    run append-macro-line (input '          Exit Sub').
    run append-macro-line (input '      End Select').
    run append-macro-line (input '    End If').
    run append-macro-line (input '    On Error GoTo 0').
    run append-macro-line (input '  Loop').
    run append-macro-line (input '  Close #1').
    run append-macro-line (input '  Application.StatusBar = "Импорт из " & FileName$ & " завершен"').
    run append-macro-line (input '  Application.ScreenUpdating = True').
    run append-macro-line (input '  Application.Interactive = True').
    run append-macro-line (input 'End Sub').
    run append-macro-line (input 'Sub DDEExecCommand(vCommand$)').
    run append-macro-line (input '   ExecuteExcel4Macro (vCommand$)').
    run append-macro-line (input 'End Sub').
    run append-macro-line (input 'Sub FormatColumnNumber(numCol As Integer)').
    run append-macro-line (input '  Columns(numCol).NumberFormat = "@"').
    run append-macro-line (input 'End Sub').
    run append-macro-line (input 'Sub callList(sList As String)').
    run append-macro-line (input '  Dim iPos0 As Integer, iPos As Integer').
    run append-macro-line (input '  Dim sDelimiter As String').
    run append-macro-line (input '  sDelimiter = ","').
    run append-macro-line (input '  If sList = "" Then').
    run append-macro-line (input '      Exit Sub').
    run append-macro-line (input '  End If').
    run append-macro-line (input '  iPos0 = 0').
    run append-macro-line (input '  iPos = InStr(1, sList, sDelimiter, vbBinaryCompare)').
    run append-macro-line (input '  If iPos = 0 Then').
    run append-macro-line (input '      FormatColumnNumber(Cint(sList))').
    run append-macro-line (input '      Exit Sub').
    run append-macro-line (input '  End If').
    run append-macro-line (input '  While True').
    run append-macro-line (input '      FormatColumnNumber(Cint(Mid(sList, iPos0 + 1, IIf(iPos = 0, Len(sList), iPos - iPos0 - 1))))').
    run append-macro-line (input '      If iPos = 0 Then').
    run append-macro-line (input '          Exit Sub').
    run append-macro-line (input '      End If').
    run append-macro-line (input '      iPos0 = iPos').
    run append-macro-line (input '      iPos = InStr(iPos + 1, sList, sDelimiter)').
    run append-macro-line (input '  Wend').
    run append-macro-line (input 'End Sub').
  end.
end procedure.
procedure clear-macro :
  define variable v-num-lines as integer   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-num-lines = chCodeModule :CountOfLines
    .
    chCodeModule :DeleteLines(1, v-num-lines) .
  end.
end procedure.
