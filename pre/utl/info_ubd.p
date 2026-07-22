block-level on error undo, throw.
DEF VAR num AS INT NO-UNDO.
DEF VAR v-ind-1 AS INT NO-UNDO.
define variable v-ind as integer   no-undo .
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
DEFINE VARIABLE chExcelApplication      AS COM-HANDLE.
DEFINE VARIABLE chWorkbook              AS COM-HANDLE.
DEFINE VARIABLE chWorksheet             AS COM-HANDLE.
def var cColumn       as character no-undo .
def var cRange        as character no-undo .
define TEMP-TABLE tt-db-info  no-undo
        field db-num                    as int
        field area-id                   as int
        field area-name                 as char
        field date-info                 as date
index pi IS PRIMARY db-num area-id area-name date-info.
.
CREATE "Excel.Application" chExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
assign
  chExcelApplication:Visible = false
  chWorkbook = chExcelApplication:Workbooks:Add ()
.
assign
  chWorkSheet = chExcelApplication:Sheets:Item (1)
  chExcelApplication:Interactive = false
  chExcelApplication:ScreenUpdating = false
  chWorkSheet:Name = "Партии"
  chWorkSheet:Range ("A1"):Value           = "№ БД"
  chWorkSheet:Columns ("A":U):ColumnWidth  = 5
  chWorkSheet:Columns ("A":U):NumberFormat = fill ("#", 5) + "0"
  chWorkSheet:Range ("B1"):Value           = "№ области"
  chWorkSheet:Columns ("B":U):ColumnWidth  = 5
  chWorkSheet:Columns ("B":U):NumberFormat = "@"
  chWorkSheet:Range ("C1"):Value           = "Имя области"
  chWorkSheet:Columns ("C":U):ColumnWidth  = 15
  chWorkSheet:Columns ("C":U):NumberFormat = fill ("0", 9)
  chWorkSheet:Range ("D1"):Value           = "Имя тома"
  chWorkSheet:Columns ("D":U):ColumnWidth  = 28
  chWorkSheet:Columns ("D":U):NumberFormat = fill ("0", 7)
  chWorkSheet:Range ("E1"):Value           = "Посл. том заполнен на %"
  chWorkSheet:Columns ("E":U):ColumnWidth  = 20
  chWorkSheet:Columns ("E":U):NumberFormat = "@"
  chWorkSheet:Range ("F1"):Value           = "На дату"
  chWorkSheet:Columns ("F":U):ColumnWidth  = 10
  chWorkSheet:Columns ("F":U):NumberFormat = "@"
  chWorkSheet:Range ("A1:F1"):Font:Bold = TRUE
  chWorkSheet:Range ("A1:F1"):Interior:ColorIndex = 35
  chWorkSheet:Range ("G1"):Value           = "Время "
  chWorkSheet:Columns ("G":U):ColumnWidth  = 10
  chWorkSheet:Columns ("G":U):NumberFormat = "@"
  chWorkSheet:Range ("A1:G1"):Font:Bold = TRUE
  chWorkSheet:Range ("A1:G1"):Interior:ColorIndex = 35
  .
run waitfram-show
  (input "Экспорт в EXCEL. Ждите ..."
  ).
v-ind = 1.
FOR EACH db WHERE db.db-num > 0 NO-LOCK:
    num = ?.
    srch_first:
    DO v-ind-1 = 1 TO 365:
      FIND FIRST  db-info  WHERE
               db-info.db-num = db.db-num
          AND db-info.date-info =  TODAY - v-ind-1
          AND  db-info.volume-hiwater <> 0
      NO-LOCK NO-ERROR.
      IF AVAIL db-info THEN DO:
          num = v-ind-1.
          LEAVE srch_first.
      END.
    END.
    IF num <> ?  THEN DO:
      FOR EACH    db-info   WHERE
             db-info.db-num = db.db-num
        AND  db-info.date-info =  TODAY - v-ind-1
        AND  db-info.volume-hiwater <> 0
      NO-LOCK:
        find first tt-db-info  WHERE
             tt-db-info.db-num    = db-info.db-num
        AND  tt-db-info.area-id   = db-info.area-id
        AND  tt-db-info.area-name = db-info.area-name
        AND  tt-db-info.date-info = db-info.date-info no-error.
        if not available (tt-db-info) then     do:
         create tt-db-info .
         assign
             tt-db-info.db-num    = db-info.db-num
             tt-db-info.area-id   = db-info.area-id
             tt-db-info.area-name = db-info.area-name
             tt-db-info.date-info = db-info.date-info .
         .
         end.
      END.
    END.
END.
FOR EACH tt-db-info  NO-LOCK:
find last    ub.db-info  WHERE
             tt-db-info.db-num    = db-info.db-num
        AND  tt-db-info.area-id   = db-info.area-id
        AND  tt-db-info.area-name = db-info.area-name
        AND  tt-db-info.date-info = db-info.date-info no-error.
         assign
            ccolumn = string (v-ind + 1)
            cRange = "A":U + cColumn
            chWorkSheet:Range (cRange):Value = db-info.db-num
            cRange = "B":U + cColumn
            chWorkSheet:Range (cRange):Value = db-info.area-id
            cRange = "C":U + cColumn
            chWorkSheet:Range (cRange):Value = db-info.area-name
            cRange = "D":U + cColumn
            chWorkSheet:Range (cRange):Value = db-info.volume-name
            cRange = "E":U + cColumn
            chWorkSheet:Range (cRange):Value = db-info.volume-percent-hiwater
            cRange = "F":U + cColumn
            chWorkSheet:Range (cRange):Value = ub.db-info.date-info
            cRange = "G":U + cColumn
            chWorkSheet:Range (cRange):Value =  string(ub.db-info.time-info, "HH:MM:SS")
            v-ind = v-ind + 1
            .
         IF db-info.volume-percent-hiwater > 50 AND db-info.volume-percent-hiwater < 80 THEN DO:
             ASSIGN
                cRange = "E":U + cColumn
                chWorkSheet:Range (cRange):Interior:ColorIndex = 6
             .
         END.
         ELSE IF db-info.volume-percent-hiwater > 80 THEN DO:
             ASSIGN
                cRange = "E":U + cColumn
                chWorkSheet:Range (cRange):Interior:ColorIndex = 3
             .
         END.
end.
empty temp-table tt-db-info .
run waitfram-hide in this-procedure .
assign
  chExcelApplication:Interactive = true
  chExcelApplication:ScreenUpdating = true
  chExcelApplication:Visible = true
.
RELEASE OBJECT chWorksheet.
RELEASE OBJECT chExcelApplication.
RELEASE OBJECT chWorkbook.
