block-level on error undo, throw.
define input  parameter p-ah-infov-handle as handle    no-undo .
define variable vss-revision    as character no-undo initial "$Revision: bbf1530230d5, 2753, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Сб фев 20 15:59:21 2021 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: ahinfxls.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/ahinfxls.p $":U .
define variable vss-description as character no-undo initial "Печать информации по складским архивам по товарам, по поставщикам, по типам приобретени".
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
DEFINE VARIABLE chExcelApplication      AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorkbook              AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorksheet             AS COM-HANDLE no-undo .
define variable cColumn       as character no-undo .
define variable cRange        as character no-undo .
if not valid-handle(p-ah-infov-handle)
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка задания входных параметров" skip
    "Неизвестная ссылка на программу" p-ah-infov-handle skip
    view-as alert-box error .
  undo, return error return-value .
end.
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
  chWorkSheet:Name = "Признаки"
  chWorkSheet:PageSetup:PrintGridlines     = TRUE
  chWorkSheet:Range ("A1"):Value           = "Архивы на объектах"
  chWorkSheet:Range ("A1:A1"):Font:Bold    = TRUE
  chWorkSheet:Range ("A2"):Value           = "Номер БД"
  chWorkSheet:Columns ("A":U):ColumnWidth  = 7
  chWorkSheet:Columns ("A":U):NumberFormat = fill ("#", 5) + "0"
  chWorkSheet:Range ("B2"):Value           = "Объект"
  chWorkSheet:Columns ("B":U):ColumnWidth  = 7
  chWorkSheet:Columns ("B":U):NumberFormat = "@"
  chWorkSheet:Range ("C2"):Value           = "Тип"
  chWorkSheet:Columns ("C":U):ColumnWidth  = 10
  chWorkSheet:Columns ("C":U):NumberFormat = "@"
  chWorkSheet:Range ("D2"):Value           = "Не рассчитан оборот"
  chWorkSheet:Columns ("D":U):ColumnWidth  = 5
  chWorkSheet:Columns ("D":U):NumberFormat = "@"
  chWorkSheet:Range ("E2"):Value           = "Не рассчитан нач.остаток"
  chWorkSheet:Columns ("E":U):ColumnWidth  = 5
  chWorkSheet:Columns ("E":U):NumberFormat = "@"
  chWorkSheet:Range ("F2"):Value           = "Расчет архива выключен"
  chWorkSheet:Columns ("F":U):ColumnWidth  = 5
  chWorkSheet:Columns ("F":U):NumberFormat = "@"
  chWorkSheet:Range ("G2"):Value           = "Сбой удал./восст."
  chWorkSheet:Columns ("G":U):ColumnWidth  = 5
  chWorkSheet:Columns ("G":U):NumberFormat = "@"
  chWorkSheet:Range ("H2"):Value           = "Задания на расчет"
  chWorkSheet:Columns ("H":U):ColumnWidth  = 5
  chWorkSheet:Columns ("H":U):NumberFormat = "@"
  chWorkSheet:Range ("I2"):Value           = "Подробный"
  chWorkSheet:Columns ("I":U):ColumnWidth  = 10
  chWorkSheet:Columns ("I":U):NumberFormat = "@"
  chWorkSheet:Range ("J2"):Value           = "Сжатый"
  chWorkSheet:Columns ("J":U):ColumnWidth  = 10
  chWorkSheet:Columns ("J":U):NumberFormat = "@"
  chWorkSheet:Range ("K2"):Value           = "Перерасчет"
  chWorkSheet:Columns ("K":U):ColumnWidth  = 10
  chWorkSheet:Columns ("K":U):NumberFormat = "@"
  chWorkSheet:Range ("A2:K2"):Font:Bold = TRUE
  chWorkSheet:Range ("A2:K2"):Interior:ColorIndex = 35
  .
run waitfram-show in this-procedure
  (input "Экспорт в EXCEL. Ждите ..."
  ).
define variable v-rid as recid no-undo .
define variable v-ind as integer   no-undo .
run ah-infov_get-first in p-ah-infov-handle .
do while true
:
  define variable v-available                as logical   no-undo .
  define variable v-db-num                   as integer   no-undo .
  define variable v-obj-type                 as character no-undo .
  define variable v-obj-code                 as integer   no-undo .
  define variable v-archive-type             as character no-undo .
  define variable v-deleted                  as logical   no-undo .
  define variable v-archive-calc             as logical   no-undo .
  define variable v-archive-del              as logical   no-undo .
  define variable v-archive-disable          as logical   no-undo .
  define variable v-archive-rest             as logical   no-undo .
  define variable v-archive-bpexist          as logical   no-undo .
  define variable v-archive-detail-date      as date      no-undo .
  define variable v-archive-start-date       as date      no-undo .
  define variable v-archive-date-recalc      as date      no-undo .
  define variable v-archive-lock-prc         as logical   no-undo .
  define variable v-archive-execuser         as character no-undo .
  define variable v-archive-execsysdate      as date      no-undo .
  define variable v-archive-execsystime      as character no-undo .
  define variable v-archive-rest-lock-prc    as logical   no-undo .
  define variable v-archive-rest-execuser    as character no-undo .
  define variable v-archive-rest-execsysdate as date      no-undo .
  define variable v-archive-rest-execsystime as character no-undo .
  define variable v-archive-type-name     as character no-undo .
  run ah-infov_get-current in p-ah-infov-handle
    (output v-available
    ,output v-db-num
    ,output v-obj-type
    ,output v-obj-code
    ,output v-archive-type
    ,output v-deleted
    ,output v-archive-calc
    ,output v-archive-del
    ,output v-archive-disable
    ,output v-archive-rest
    ,output v-archive-bpexist
    ,output v-archive-detail-date
    ,output v-archive-start-date
    ,output v-archive-date-recalc
    ,output v-archive-lock-prc
    ,output v-archive-execuser
    ,output v-archive-execsysdate
    ,output v-archive-execsystime
    ,output v-archive-rest-lock-prc
    ,output v-archive-rest-execuser
    ,output v-archive-rest-execsysdate
    ,output v-archive-rest-execsystime
    ) .
  if v-available <> true
  then do:
    leave .
  end.
  run ah-infov_archive-type-name-proc in p-ah-infov-handle
    (input  v-archive-type
    ,output v-archive-type-name
    ) .
  assign
    v-ind = v-ind + 1
  .
  run waitfram-show in this-procedure
    (input substitute("Экспортировано в EXCEL строк: &1", v-ind)
    ).
  assign
    cColumn = STRING (v-ind + 2)
    cRange = "A":U + cColumn
    chWorkSheet:Range (cRange):Value = v-db-num
    cRange = "B":U + cColumn
    chWorkSheet:Range (cRange):Value = substitute("&1 &2", v-obj-type, v-obj-code)
    cRange = "C":U + cColumn
    chWorkSheet:Range (cRange):Value = v-archive-type-name
    cRange = "D":U + cColumn
    chWorkSheet:Range (cRange):Value = string(v-archive-calc, '+/-':u)
    cRange = "E":U + cColumn
    chWorkSheet:Range (cRange):Value = string(v-archive-del, '+/-':u)
    cRange = "F":U + cColumn
    chWorkSheet:Range (cRange):Value = string(v-archive-disable, '+/-':u)
    cRange = "G":U + cColumn
    chWorkSheet:Range (cRange):Value = string(v-archive-rest, '+/-':u)
    cRange = "H":U + cColumn
    chWorkSheet:Range (cRange):Value = string(v-archive-bpexist, '+/-':u)
    cRange = "I":U + cColumn
    chWorkSheet:Range (cRange):Value = string(v-archive-detail-date, '99/99/9999':u)
    cRange = "J":U + cColumn
    chWorkSheet:Range (cRange):Value = string(v-archive-start-date, '99/99/9999':u)
    cRange = "K":U + cColumn
    chWorkSheet:Range (cRange):Value = string(v-archive-date-recalc, '99/99/9999':u)
  .
  run ah-infov_get-next in p-ah-infov-handle .
END.
run waitfram-hide in this-procedure .
assign
  chExcelApplication:Interactive = true
  chExcelApplication:ScreenUpdating = true
  chExcelApplication:Visible = true
.
RELEASE OBJECT chWorksheet NO-ERROR.
RELEASE OBJECT chWorkbook NO-ERROR.
chExcelApplication :QUIT().
RELEASE OBJECT  chExcelApplication  NO-ERROR.
