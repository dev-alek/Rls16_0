using ibs.th.gbl.*.
define input parameter  p-message       as character no-undo .
define input parameter  DisabledOptions as integer   no-undo .
define input parameter  p-file-name     as character no-undo .
define input parameter  p-font-number   as integer   no-undo.
define output parameter p-user-action   as character no-undo .
define output parameter p-printed       as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Программа печати файла".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3|&4':u,DisabledOptions,p-file-name,p-user-action,p-printed)
    .
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable lok             as logical   no-undo .
define variable v-prnfilen-excel-file-exist     as logical      no-undo.
define variable RepFileFullName as character no-undo .
define variable v-report-output as logical   no-undo .
define variable v-excel-printed as logical no-undo .
define variable v-postpone-print as logical no-undo .
define variable p-excel-name as character no-undo .
define variable v-caller as handle no-undo .
define temp-table temp-destination no-undo
field destination-id as character
field destination as character
index pi is unique primary
destination-id.
define stream temp-stream .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure prnexldl_clear:
define input parameter p-txl-file-name as character no-undo .
define variable v-template-file-name as character no-undo .
define variable v-vb-file-name as character no-undo .
define variable v-data-header-filename as character no-undo .
define variable v-data-filename as character no-undo .
if search( p-txl-file-name ) <> ? then do:
  input stream temp-stream from value( p-txl-file-name ).
  repeat
  :
      import stream temp-stream v-template-file-name   .
      import stream temp-stream v-vb-file-name         .
      import stream temp-stream v-data-header-filename .
      os-delete value(v-data-header-filename).
      import stream temp-stream v-data-filename        .
      os-delete value(v-data-filename).
  end.
  input stream temp-stream close.
  os-delete value( p-txl-file-name ).
end.
end procedure .
def stream cfg-stream.
function check-xslt-files returns logical() forward.
DEFINE BUTTON b-excel
     IMAGE-UP FILE "cmp/prnts_excel.bmp":U
     IMAGE-DOWN FILE "cmp/prnts_excel.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/prnt_excel.bmp":U
     LABEL " E&xcel"
     SIZE 10 BY 3.33.
DEFINE BUTTON b-file
     IMAGE-UP FILE "cmp/prnts_file.bmp":U
     IMAGE-DOWN FILE "cmp/prnts_file.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/prnt_file.bmp":U
     LABEL " &Файл"
     SIZE 10 BY 3.33.
DEFINE BUTTON b-help DEFAULT
     IMAGE-UP FILE "cmp/prnt_help.bmp":U
     IMAGE-DOWN FILE "cmp/prnt_help.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/prnt_help.bmp":U
     LABEL "&Помощь":L
     SIZE 3 BY 1.08
     BGCOLOR 8 .
DEFINE BUTTON b-other
     IMAGE-UP FILE "cmp/prnts_zak.bmp":U
     IMAGE-DOWN FILE "cmp/prnts_zak.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/prnt_zak.bmp":U
     LABEL "&Заказная"
     SIZE 10 BY 3.33.
DEFINE BUTTON b-pdf
     IMAGE-UP FILE "cmp/prnts_pdf.bmp":U
     IMAGE-DOWN FILE "cmp/prnts_pdf.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/prnt_pdf.bmp":U
     LABEL "P&DF"
     SIZE 10 BY 3.33.
DEFINE BUTTON b-printer
     IMAGE-UP FILE "cmp/prnts_prnt.bmp":U
     IMAGE-DOWN FILE "cmp/prnts_prnt.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/prnt_prnt.bmp":U
     LABEL "_ &Принтер"
     SIZE 10 BY 3.33.
DEFINE BUTTON b-screen
     IMAGE-UP FILE "cmp/prnts_screen.bmp":U
     IMAGE-DOWN FILE "cmp/prnts_screen.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/prnt_screen.bmp":U
     LABEL "_ &Экран"
     SIZE 10 BY 3.33.
DEFINE BUTTON Exit AUTO-END-KEY
     IMAGE-UP FILE "cmp/prnts_exit.bmp":U
     IMAGE-DOWN FILE "cmp/prnts_exit.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/prnt_exit.bmp":U
     LABEL "&Выход ":L
     SIZE 10 BY 3.33.
DEFINE VARIABLE EDITOR-history AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 79.5 BY 4.63
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-description AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 80.5 BY .67
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Действия по выводу отчёта:"
      VIEW-AS TEXT
     SIZE 26 BY .67
     BGCOLOR 15  NO-UNDO.
DEFINE IMAGE IMAGE-1
     FILENAME "cmp/mainprint.bmp":U
     STRETCH-TO-FIT
     SIZE 80.5 BY 10.5.
DEFINE FRAME DIALOG-1
     Exit AT ROW 1.17 COL 1.25
     EDITOR-history AT ROW 5.79 COL 1.5 NO-LABEL
     b-printer AT ROW 1.17 COL 12.25
     b-pdf AT ROW 1.17 COL 23.25
     b-screen AT ROW 1.17 COL 34.25
     b-file AT ROW 1.17 COL 45.25
     b-other AT ROW 1.17 COL 56.25
     b-excel AT ROW 1.17 COL 67.25
     b-help AT ROW 1.17 COL 78
     FILL-IN-1 AT ROW 4.96 COL 1.5 NO-LABEL
     fi-description AT ROW 10.63 COL 1 NO-LABEL
     IMAGE-1 AT ROW 1 COL 1 WIDGET-ID 14
    WITH VIEW-AS DIALOG-BOX
         SIDE-LABELS THREE-D  SCROLLABLE
         TITLE "Вывод отчета".
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.
ASSIGN
       EDITOR-history:READ-ONLY IN FRAME DIALOG-1        = TRUE.
ASSIGN
       Exit:PRIVATE-DATA IN FRAME DIALOG-1     =
                "Exit".
ON CHOOSE OF b-excel IN FRAME DIALOG-1
DO:
  define variable v-disable-button as logical   no-undo .
  if session :set-wait-state("compiler") then .
  if check-xslt-files() then
    do:
       run xslt-transform.
       run disable-excel(true).
    end.
  else if v-postpone-print then do:
    run gbl/open_url.p ( input p-excel-name) no-error .
  end.
  else do:
  if search( p-file-name + ".txl" ) = ?
  then do:
    run rep/runexcel.p
        (input p-file-name + ".txt"
        ) no-error .
    if error-status :error
    then do:
        if session :set-wait-state("") then .
        apply 'ENTRY':u to Exit .
        return no-apply .
    end.
  end.
  else do:
    run rep/runxlt.p (
        input p-file-name + ".txl"
    ) no-error.
    if error-status :error
    then do:
        os-delete value( p-file-name + ".txl" ).
        run disable-excel in this-procedure (
            input yes
        ).
        if session :set-wait-state("") then .
        run update-history in this-procedure (
            input "Отказ от сохранения отчёта в формате Excel"
        ).
        apply 'ENTRY':u to Exit .
        return no-apply .
    end.
    assign
        v-disable-button = yes
    .
  end.
  if return-value = "disable-button":U
  then do:
    assign
      v-disable-button = true
    .
  end.
  run disable-excel in this-procedure (
    input v-disable-button
  ).
  end.
  assign
    v-report-output = true
    p-user-action   = p-user-action + "; " + "excel"
  .
  run update-history in this-procedure
    (input "Отчёт сохранён в формате Excel"
    ) .
  if session :set-wait-state("") then .
  apply 'ENTRY':u to Exit .
END.
ON CHOOSE OF b-file IN FRAME DIALOG-1
DO:
  if session :set-wait-state("compiler") then .
  assign
    RepFileFullName = "report.txt"
  .
  system-dialog get-file RepFileFullName
      ask-overwrite
      save-as
      create-test-file
      use-filename
      initial-dir '.'
      update lok
      default-extension "txt" .
  if lok = true
  then do:
    if RepFileFullName <> p-file-name
    then do:
      define variable v-err-status as integer   no-undo .
      os-copy
        value(p-file-name)
        value(RepFileFullName)
        .
      assign
        v-err-status = os-error
      .
      if v-err-status <> 0
      then do:
        message
          "Не удалось вывести отчет в файл" repfilefullname skip
          "Ошибка" v-err-status skip
          view-as alert-box error .
      end.
      else do:
        message
          "Отчёт выведен в файл"  repfilefullname skip
          view-as alert-box information .
        assign
          p-printed       = true
          v-report-output = true
          p-user-action   = p-user-action + "; " + "файл"
        .
        run update-history in this-procedure
          (input substitute("Отчёт сохранён в файл &1", repfilefullname)
          ) .
      end.
    end.
  end.
  if session :set-wait-state("") then .
  apply 'ENTRY':u to Exit .
END.
ON CHOOSE OF b-other IN FRAME DIALOG-1
DO:
  define variable v-ok as logical   no-undo .
  message
    "Передать отчет заказной программе обработки" skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true
  then do:
    return no-apply .
  end.
  if session :set-wait-state("compiler") then .
  define variable v-extprog-retval as character no-undo .
  run gbl/extprog.p
    (input  'exec':U
    ,input  'altprn':U
    ,input  p-file-name
    ,input  ""
    ,input  ""
    ,output v-extprog-retval
    ) .
  assign
    v-report-output = true
    p-user-action   = p-user-action + "; " + "заказная"
  .
  run update-history in this-procedure
    (input "Отчёт передан заказной программе обработки"
    ) .
  if session :set-wait-state("") then .
  apply 'ENTRY':u to Exit .
END.
ON CHOOSE OF b-pdf IN FRAME DIALOG-1
DO:
  if session :set-wait-state("compiler") then .
  define variable v-landscape as logical   no-undo .
  if DisabledOptions >= 8
  then do:
    assign
      v-landscape = true
    .
  end.
  else do:
    assign
      v-landscape = false
    .
  end.
  assign
    RepFileFullName = "report.pdf"
  .
  system-dialog get-file RepFileFullName
      ask-overwrite
      save-as
      create-test-file
      use-filename
      initial-dir '.'
      update lok
      default-extension "pdf" .
  if lok = true
  then do:
    if  search(RepFileFullName) <> ""
    and search(RepFileFullName) <> ?
    then do:
      os-delete value(RepFileFullName) .
    end.
    if  search(RepFileFullName) <> ""
    and search(RepFileFullName) <> ?
    then do:
      message
        "Файл существует и его невозможно удалить" skip
        "Невозможно вывести отчет в файл" RepFileFullName skip
        view-as alert-box error .
    end.
    else do:
      define variable v-extprog-retval as character no-undo .
      run gbl/extprog.p
        (input  'exec':U
        ,input  'txt2pdf':U
        ,input  p-file-name
        ,input  RepFileFullName
        ,input  (if v-landscape then "-l" else "")
        ,output v-extprog-retval
        ) .
      assign
        v-report-output = true
        p-user-action   = p-user-action + "; " + "pdf"
      .
      run update-history in this-procedure
        (input substitute("Отчёт сохранён в формате PDF в файл &1", repfilefullname)
        ) .
    end.
  end.
  if session :set-wait-state("") then .
  apply 'ENTRY':u to Exit .
END.
ON CHOOSE OF b-printer IN FRAME DIALOG-1
DO:
  if session :set-wait-state("compiler") then .
  run adecomm/_osprint.p
    (input  ?
    ,input  p-file-name
    ,input  p-font-number
    ,input  (if DisabledOptions >= 8 then 3 else 1)
    ,input  0
    ,input  0
    ,output lok
    ).
  if lok
  then do:
    assign
      p-printed       = true
      v-report-output = true
      p-user-action   = p-user-action + "; " + "принтер"
    .
    run update-history in this-procedure
      (input "Отчёт распечатан на принтер"
      ) .
  end.
  if session :set-wait-state("") then .
  apply 'ENTRY':u to Exit .
END.
ON CHOOSE OF b-screen IN FRAME DIALOG-1
DO:
  if session :set-wait-state("compiler") then .
  define variable v-extprog-retval as character no-undo .
  run gbl/extprog.p
    (input  'exec':U
    ,input  'rptview':U
    ,input  p-file-name
    ,input  ""
    ,input  ""
    ,output v-extprog-retval
    ) .
  assign
    v-report-output = true
    p-user-action   = p-user-action + "; " + "экран"
  .
  if session :set-wait-state("") then .
  apply 'ENTRY':u to Exit .
END.
ON CHOOSE OF Exit IN FRAME DIALOG-1
DO:
  if search( p-file-name + ".txl" ) <> ?
  and not v-excel-printed
  then do:
    run prnexldl_clear in this-procedure ( input  p-file-name + ".txl"
                                         ) no-error.
  end.
  if search( p-file-name + ".txt" ) <> ?
  and search( p-file-name + ".frm" ) <> ? then do:
    os-delete value( p-file-name + ".txt" ).
    os-delete value( p-file-name + ".frm" ).
  end.
  apply "end-error":u to frame DIALOG-1  .
  return no-apply .
END.
IF CURRENT-WINDOW:WINDOW-STATE = WINDOW-MINIMIZED
THEN CURRENT-WINDOW:WINDOW-STATE = WINDOW-NORMAL.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DIALOG-1
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame DIALOG-1
do:
  apply "help":u to frame DIALOG-1 .
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame DIALOG-1:width - 0.3
                fh            = frame DIALOG-1:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
ON WINDOW-CLOSE OF FRAME DIALOG-1 APPLY "END-ERROR":U TO SELF.
on end-error of frame DIALOG-1
do:
  define variable v-ok as logical   no-undo .
  run clear-temp-xslt-files.
  if v-report-output = false
  then do:
    message
      "Отчёт не был просмотрен, сохранён или распечатан" skip
      "Закрыть диалог вывода отчета?" skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true
    then do:
      return no-apply .
    end.
  end.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
 :
    assign
      p-printed       = false
      v-report-output = false
    .
    if DisabledOptions >= 30 then do:
      assign
      v-postpone-print = yes
      .
      disabledoptions = disabledoptions - 30.
      for each temp-destination:
        delete temp-destination.
      end.
      v-caller = this-procedure:instantiating-procedure.
      run cb_get-options in v-caller ( input this-procedure:handle).
    end.
    run init-fields in this-procedure .
    if return-value = 'exit' then return .
    apply 'entry':u to b-screen .
    RUN enable_UI.
    run disable-option in this-procedure .
    assign
      fi-description :screen-value = p-message
    .
    WAIT-FOR GO OF FRAME DIALOG-1.
END.
RUN disable_UI.
PROCEDURE cb_set-options :
DEFINE INPUT PARAMETER p-option AS character NO-UNDO.
define input parameter p-resource as character no-undo .
DEFINE BUFFER buf_temp-destination FOR temp-destination.
find first buf_temp-destination where
         buf_temp-destination.destination = p-option no-error.
if not available buf_temp-destination then do:
  create buf_temp-destination.
  assign
  buf_temp-destination.destination-id = p-option
  buf_temp-destination.destination = p-resource.
end.
END PROCEDURE.
PROCEDURE disable-excel :
  define input  parameter p-disable-button as logical   no-undo .
  do with frame DIALOG-1
  on error undo, return error
  :
    if p-disable-button = true
    then do:
      assign
        b-excel :sensitive = false
        v-excel-printed = yes
      .
    end.
    else do:
        if v-prnfilen-excel-file-exist = no
        then do:
            assign
                b-excel :sensitive = false
            .
        end.
    end.
  end.
END PROCEDURE.
PROCEDURE disable-option :
  do with frame DIALOG-1
  on error undo, return error
  :
    case disabledoptions :
      when 1 or
      when 9
      then do:
        assign
          b-printer :sensitive = false
        .
      end.
      when 2 or
      when 10
      then do:
        assign
          b-screen :sensitive = false
        .
        apply 'entry':u to b-file .
      end.
      when 3 or
      when 11
      then do:
        assign
          b-printer :sensitive = false
          b-screen  :sensitive = false
        .
        apply 'entry':u to b-file .
      end.
      when 4 or
      when 12
      then do:
        assign
          b-file :sensitive = false
        .
      end.
      when 5 or
      when 13
      then do:
        assign
          b-printer :sensitive = false
          b-file    :sensitive = false
        .
      end.
      when 6 or
      when 14
      then do:
        assign
          b-screen :sensitive = false
          b-file   :sensitive = false
        .
        apply 'entry':u to b-file .
      end.
      when 20
      then do:
        assign
          b-screen  :sensitive = false
          b-file    :sensitive = false
          b-printer :sensitive = false
          b-other   :sensitive = false
          b-pdf     :sensitive = false
        .
        apply 'entry':u to b-excel .
      end.
      when 21
      then do:
          assign
            b-screen  :sensitive = false
            b-excel   :sensitive = false
            b-printer :sensitive = false
          .
          apply 'entry':u to b-file .
      end.
    end case.
    if v-postpone-print
    and p-file-name = '' then do:
      assign
        b-screen  :sensitive = false
        b-file    :sensitive = false
        b-printer :sensitive = false
        b-other   :sensitive = false
        b-pdf     :sensitive = false
      .
    end.
    run disable-excel in this-procedure
      (input false
      ) .
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME DIALOG-1.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY EDITOR-history fi-description FILL-IN-1
      WITH FRAME DIALOG-1.
  ENABLE Exit IMAGE-1 EDITOR-history b-printer b-pdf b-screen b-file b-other
         b-excel b-help FILL-IN-1 fi-description
      WITH FRAME DIALOG-1.
END PROCEDURE.
PROCEDURE init-fields :
    define variable v-filename          as character    no-undo.
    define variable v-filesize          as integer      no-undo.
    define variable v-data-valid        as logical      no-undo.
    define variable v-err-message       as character    no-undo.
do
on error undo, return error
:
if v-postpone-print then do:
  find first temp-destination where
          temp-destination.destination-id =  'text':U no-error.
  if available temp-destination
  and search (temp-destination.destination) <> ?
  then do:
    assign
    p-file-name = temp-destination.destination
    .
  end.
end.
if p-file-name <> '' AND SEARCH(p-file-name) <> ?  then do:
INPUT stream temp-stream FROM value(p-file-name).
def var str1 as character no-undo .
def var kol-row as integer init 0 no-undo  .
REPEAT:
    IMPORT stream temp-stream UNFORMATTED str1 no-error .
    kol-row = kol-row + 1 .
    if kol-row >= 2  then DO:
     leave.
    End.
END.
INPUT stream temp-stream CLOSE.
if kol-row = 0 then DO:
    Message "Нет заданий на печать ! " view-as alert-box .
    Return  'exit'.
    End.
end.
    if p-font-number <= 0
    then do:
        assign
            p-font-number = 7
        .
    end.
    assign
        v-prnfilen-excel-file-exist = no
    .
    if v-postpone-print then do:
      find first temp-destination where
             temp-destination.destination-id =  'excel':U no-error.
      if available temp-destination
      and search (temp-destination.destination) <> ?
      then do:
        assign
            v-prnfilen-excel-file-exist = yes
            p-excel-name = temp-destination.destination
        .
      end.
    end.
    else do:
    if search( p-file-name + ".txt" ) = ?
    then do:
        assign
            v-filename = search( p-file-name + ".txl" )
        .
        if v-filename <> ?
        then do:
            run gbl/filesize.p (
                  input v-filename
                , output v-filesize
            ).
            if v-filesize <> 0
            and v-filesize <> ?
            then do:
                assign
                    v-prnfilen-excel-file-exist = yes
                .
            end.
            else do:
                if v-filesize = 0
                then do:
                    os-delete value( v-filename ).
                end.
            end.
        end.
    end.
    else do:
        assign
            v-prnfilen-excel-file-exist = yes
        .
    end.
    if check-xslt-files() then
        do:
            v-prnfilen-excel-file-exist = true.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE update-history :
  define input  parameter p-message as character no-undo .
  define variable lok as logical   no-undo .
  do with frame DIALOG-1
  on error undo, return error
  :
    assign
      lok = EDITOR-history :move-to-eof( )
      lok = EDITOR-history :insert-string( p-message + chr(10) )
      lok = EDITOR-history :move-to-eof( )
    .
  end.
END PROCEDURE.
procedure xslt-transform:
    def var rnd-file-name as char no-undo.
    run gbl/_tmpfile.p("", ".xls", output rnd-file-name).
    def var xslt-path as char no-undo.
    xslt-path = search("exe\xslt.exe").
    os-command silent value(xslt-path + " -config " + p-file-name + ".xslt-cfg").
    def var excel as com-handle no-undo.
    create "Excel.Application" excel no-error.
    if not ERROR-STATUS:ERROR then
        do:
            excel:Visible = false.
            excel:DisplayAlerts = false.
            excel:Workbooks:open(p-file-name + ".xslt-res").
            excel:Visible = true.
            excel:ActiveWorkBook:SaveAs(rnd-file-name,-4143, , , , , ).
            release object excel no-error.
            if error-status:ERROR then
                message "Не удалось освободить com-component->excel"
                    view-as alert-box.
        end.
    else
        message "Не удалось создать com-component->excel" view-as alert-box.
end.
function check-xslt-files returns logical:
    if search(p-file-name + ".xslt-cfg") = ? then return false.
    input stream cfg-stream from value(p-file-name + ".xslt-cfg").
    def var str as char no-undo.
    def var ret-val as logical no-undo initial false.
    repeat:
        import stream cfg-stream unformatted str.
        if str begins "merge_file=" then ret-val = true.
    end.
    output stream cfg-stream close.
    return ret-val.
end.
procedure clear-temp-xslt-files:
  os-delete value(p-file-name + ".xslt-cfg") no-error.
  os-delete value(p-file-name + ".xslt-res") no-error.
  os-delete value(p-file-name + ".xslt-data") no-error.
  os-delete value(p-file-name + ".xslt-merged") no-error.
end.
