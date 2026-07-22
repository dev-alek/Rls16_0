block-level on error undo, throw.
define input parameter p-filename       as character        no-undo.
define input parameter p-parameter      as character        no-undo.
define input parameter p-vb-filename    as character        no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: xlimport.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/xlimport.p $":U .
define variable vss-description as character no-undo init "Процедура импорта из формата xls".
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
define variable v-xlimport-macro-line-counter    as integer      no-undo.
define variable v-ok            as logical      no-undo.
define variable v-vb-filename   as character    no-undo.
define variable v-filename      as character    no-undo.
define variable v-version       as character no-undo .
define variable v-version-dec   as decimal   no-undo .
define variable v-found-reg-entry as logical no-undo .
define variable v-trusted as character no-undo .
define variable chExcelApp                  as com-handle       no-undo.
define variable chWorkBook                  as com-handle       no-undo.
define variable chCodeModule                as com-handle       no-undo.
do
on error undo, return error
:
    assign
        v-filename      = search( p-filename    )
        v-vb-filename   = search( p-vb-filename )
    .
    if v-filename = ?
    then do:
        message
            "Не найден файл Excel"
            skip p-filename
        view-as alert-box error.
        undo, return error .
    end.
    if v-vb-filename = ?
    then do:
        message
            "Не найден файл обработки"
            skip p-vb-filename
        view-as alert-box error.
        undo, return error .
    end.
    create "Excel.Application" chExcelApp no-error .
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
    assign
    chExcelApp :WindowState =
    chExcelApp :Visible     = False
    chExcelApp :Interactive = False
    chExcelApp :Visible     = yes
    chExcelApp :Interactive = yes
    v-version = chExcelApp:version
    no-error
    .
    assign
    v-version-dec = decimal(v-version)
    no-error .
    if error-status:error then do:
      run  clearexcel in this-procedure .
      message "Не удалось определить версию Excel"
      view-as alert-box error .
      return error '':U.
    end.
    if v-version-dec > 9 then do:
      run gbl/getregvl.p (
                       input "HKEY_CURRENT_USER":U
                      ,input  "SOFTWARE":U
                      ,input ("Microsoft\Office\" + string(v-version-dec, ">9.9":U) + "\Excel\Security":U)
                      ,input  "AccessVBOM":U
                      ,output v-found-reg-entry
                      ,OUTPUT v-trusted) no-error .
      if error-status:error then do:
        message
        "Не удалось определить политику безопасности для данной версии Excel"
        view-as alert-box error .
        run  clearexcel in this-procedure .
        return error '':U.
      end.
      if not v-found-reg-entry
      or trim(v-trusted) = "0":U then do:
        message
        "На Вашей машине запрещен программный доступ к VisualBasicProject" skip
        "В связи с этим вывод в EXCEL невозможен" skip
        "возможное решение проблемы:" skip
        "открыть в EXCEL диалог <Сервис\Макрос\Безопасность> (<Tools\Macro\Security>)" skip
        "выбрать закладку <Надежные источники> (<Trusted Sources>)  и включить галочку" skip
        "<Доверять доступ Visual Basic Project> (<Trust access to Visual Basic Project>)" skip
        "Затем закрыть Excel"
        view-as alert-box ERROR.
        run  clearexcel in this-procedure .
        return error '':U.
      end.
    end.
    assign
    chWorkBook = chExcelApp :Workbooks :Add( v-filename )
    .
    assign
    chCodeModule = chWorkbook :VBProject :VBComponents :Item(1) :CodeModule
    .
    run load-basic in this-procedure (
          input v-filename
        , input v-vb-filename
    ).
    assign
        v-ok = chWorkbook:LoadBasic
    .
    assign
        v-ok = chWorkbook:StartApp
    .
    assign
        chExcelApp :DisplayAlerts = False
    .
    run clearexcel in this-procedure .
end.
procedure load-basic :
define input parameter p-filename       as character        no-undo.
define input parameter p-vb-filename    as character        no-undo.
define variable chCodeModule as com-handle no-undo .
define variable num-of-lines as integer no-undo .
    define variable v-command-string    as character    no-undo.
  do
  on error undo, return error return-value
  :
  assign
    chCodeModule = chWorkbook :VBProject :VBComponents :Item(1) :CodeModule
  .
  assign
  num-of-lines = chCodeModule :CountOfLines.
  chCodeModule:DeleteLines(1, num-of-lines).
    run append-macro-line ( input 'Sub LoadBasic').
    assign
        v-command-string = substitute( '  ThisWorkbook.VBProject.VBComponents.Import "&1"'
                                , p-vb-filename
                           )
    .
    run append-macro-line ( input v-command-string ).
    run append-macro-line ( input '  Application.Interactive = True').
    run append-macro-line ( input '  Application.ScreenUpdating = True').
    run append-macro-line ( input 'End Sub').
    run append-macro-line ( input 'Sub StartApp').
    run append-macro-line ( input 'Dim mModule As Object').
    run append-macro-line ( input 'Dim liCount As Long').
    run append-macro-line ( input '  Application.ScreenUpdating = False').
    run append-macro-line ( input '  Application.Interactive = False').
    assign
        v-command-string = substitute( '  call VBAProject.mainMacro ("&1")'
                                , p-parameter
                           )
    .
    run append-macro-line ( input v-command-string ).
    run append-macro-line ( input 'For Each mModule In ThisWorkbook.VBProject.VBComponents').
    run append-macro-line ( input 'If mModule.Type = 1 Then').
    run append-macro-line ( input '    ThisWorkbook.VBProject.VBComponents.Remove ThisWorkbook.VBProject.VBComponents(mModule.Name)').
    run append-macro-line ( input 'End If').
    run append-macro-line ( input 'Next mModule').
    run append-macro-line ( input '  Application.Interactive = True').
    run append-macro-line ( input '  Application.ScreenUpdating = True').
    run append-macro-line ( input 'For Each mModule In ThisWorkbook.VBProject.VBComponents').
    run append-macro-line ( input '    liCount = mModule.CodeModule.CountOfLines').
    run append-macro-line ( input '    mModule.CodeModule.DeleteLines 1, liCount').
    run append-macro-line ( input 'Next mModule').
    run append-macro-line ( input 'End Sub').
  end.
end procedure.
procedure append-macro-line :
define input  parameter p-macro-str as character no-undo .
do
on error undo, return error return-value
:
    assign
        v-xlimport-macro-line-counter = v-xlimport-macro-line-counter + 1
    .
    assign
        v-ok = chCodeModule :InsertLines( v-xlimport-macro-line-counter, p-macro-str )
    .
end.
end procedure.
procedure ClearExcel :
define variable v-ok as logical no-undo .
  do
  on error undo, return error
  :
    release object chCodeModule no-error .
    release object chWorkBook   no-error .
    assign
        v-ok = chExcelApp:Quit()
    no-error.
    release object chExcelApp   no-error .
    PROCESS EVENTS.
  end.
end procedure.
