block-level on error undo, throw.
define input  parameter p-handle-callback as handle    no-undo .
define variable vss-revision    as character no-undo initial "$Revision: bbf1530230d5, 2753, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Сб фев 20 15:59:21 2021 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: partsxls.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/partsxls.p $":U .
define variable vss-description as character no-undo initial "Печать партий в формате EXCEL".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
DEFINE SHARED BUFFER parts FOR ub.parts .
DEFINE SHARED QUERY br-parts FOR
      parts SCROLLING.
DEFINE VARIABLE chExcelApplication      AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorkbook              AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorksheet             AS COM-HANDLE no-undo .
def var v-ind   as integer   no-undo .
def var cRow as character no-undo .
def var cRange  as character no-undo .
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
  chWorkSheet:Range ("A1"):Value           = "№ п/п"
  chWorkSheet:Columns ("A":U):ColumnWidth  = 7
  chWorkSheet:Columns ("A":U):NumberFormat = fill ("#", 5) + "0"
  chWorkSheet:Range ("B1"):Value           = "Тип объекта"
  chWorkSheet:Columns ("B":U):ColumnWidth  = 5
  chWorkSheet:Columns ("B":U):NumberFormat = "@"
  chWorkSheet:Range ("C1"):Value           = "Код объекта"
  chWorkSheet:Columns ("C":U):ColumnWidth  = 10
  chWorkSheet:Columns ("C":U):NumberFormat = fill ("0", 9)
  chWorkSheet:Range ("D1"):Value           = "Артикул"
  chWorkSheet:Columns ("D":U):ColumnWidth  = 20
  chWorkSheet:Columns ("D":U):NumberFormat = "@"
  chWorkSheet:Range ("E1"):Value           = "Тип производителя"
  chWorkSheet:Columns ("E":U):ColumnWidth  = 5
  chWorkSheet:Columns ("E":U):NumberFormat = "@"
  chWorkSheet:Range ("F1"):Value           = "Код производителя"
  chWorkSheet:Columns ("F":U):ColumnWidth  = 10
  chWorkSheet:Columns ("F":U):NumberFormat = fill ("0", 9)
  chWorkSheet:Range ("G1"):Value           = "Номер ПН"
  chWorkSheet:Columns ("G":U):ColumnWidth  = 10
  chWorkSheet:Columns ("G":U):NumberFormat = "@"
  chWorkSheet:Range ("H1"):Value           = "Документ"
  chWorkSheet:Columns ("H":U):ColumnWidth  = 10
  chWorkSheet:Columns ("H":U):NumberFormat = "@"
  chWorkSheet:Range ("I1"):Value           = "Код партии"
  chWorkSheet:Columns ("I":U):ColumnWidth  = 5
  chWorkSheet:Columns ("I":U):NumberFormat = "@"
  chWorkSheet:Range ("J1"):Value           = "По док."
  chWorkSheet:Columns ("J":U):ColumnWidth  = 10
  chWorkSheet:Range ("K1"):Value           = "Факт"
  chWorkSheet:Columns ("K":U):ColumnWidth  = 10
  chWorkSheet:Range ("L1"):Value           = "Цена (Б.В.)"
  chWorkSheet:Columns ("L":U):ColumnWidth  = 12
  chWorkSheet:Range ("M1"):Value           = "Цена (руб.)"
  chWorkSheet:Columns ("M":U):ColumnWidth  = 12
  chWorkSheet:Range ("N1"):Value           = "Поставка"
  chWorkSheet:Columns ("N":U):ColumnWidth  = 5
  chWorkSheet:Columns ("N":U):NumberFormat = "@"
  chWorkSheet:Range ("O1"):Value           = "Тип поставщика"
  chWorkSheet:Columns ("O":U):ColumnWidth  = 5
  chWorkSheet:Columns ("O":U):NumberFormat = "@"
  chWorkSheet:Range ("P1"):Value           = "Код поставщика"
  chWorkSheet:Columns ("P":U):ColumnWidth  = 10
  chWorkSheet:Columns ("P":U):NumberFormat = fill ("0", 9)
  chWorkSheet:Range ("Q1"):Value           = "ГТД"
  chWorkSheet:Columns ("Q":U):ColumnWidth  = 10
  chWorkSheet:Columns ("Q":U):NumberFormat = "@"
  chWorkSheet:Range ("R1"):Value           = "Тип приобретения"
  chWorkSheet:Columns ("R":U):ColumnWidth  = 20
  chWorkSheet:Columns ("R":U):NumberFormat = "@"
  chWorkSheet:Range ("S1"):Value           = "Договор"
  chWorkSheet:Columns ("S":U):ColumnWidth  = 20
  chWorkSheet:Columns ("S":U):NumberFormat = "@"
  chWorkSheet:Range ("T1"):Value           = "Годен до"
  chWorkSheet:Columns ("T":U):ColumnWidth  = 20
  chWorkSheet:Columns ("T":U):NumberFormat = "@"
  chWorkSheet:Range ("U1"):Value           = "Складское место"
  chWorkSheet:Columns ("U":U):ColumnWidth  = 20
  chWorkSheet:Columns ("U":U):NumberFormat = "@"
  chWorkSheet:Range ("V1"):Value           = "НДС"
  chWorkSheet:Columns ("V":U):ColumnWidth  = 10
  chWorkSheet:Columns ("V":U):NumberFormat = "@"
  chWorkSheet:Range ("A1:V1"):Font:Bold = TRUE
  chWorkSheet:Range ("A1:V1"):Interior:ColorIndex = 35
  .
run waitfram-show
  (input "Экспорт в EXCEL. Ждите ..."
  ).
def var v-rid as recid no-undo .
assign
  v-rid = recid(parts)
  v-ind = 0
.
reposition br-parts to row 1.
do while available parts
:
  assign
    v-ind = v-ind + 1
  .
  if (v-ind modulo 10) = 0 then do:
    run waitfram-show
      (input "Экспортировано в EXCEL строк : " + string (v-ind)
      ).
  end.
  assign
    cRow = string (v-ind + 1)
    cRange = "A":U + cRow
    chWorkSheet:Range (cRange):Value = v-ind
    cRange = "B":U + cRow
    chWorkSheet:Range (cRange):Value = parts.obj-type
    cRange = "C":U + cRow
    chWorkSheet:Range (cRange):Value = parts.obj-code
    cRange = "D":U + cRow
    chWorkSheet:Range (cRange):Value = parts.artic
    cRange = "E":U + cRow
    chWorkSheet:Range (cRange):Value = parts.prod-type
    cRange = "F":U + cRow
    chWorkSheet:Range (cRange):Value = parts.prod-code
    cRange = "G":U + cRow
    chWorkSheet:Range (cRange):Value = parts.in-code
    cRange = "H":U + cRow
    chWorkSheet:Range (cRange):Value = parts.out-code
    cRange = "I":U + cRow
    chWorkSheet:Range (cRange):Value = parts.part-code
    cRange = "J":U + cRow
    chWorkSheet:Range (cRange):Value = parts.qnty
    cRange = "K":U + cRow
    chWorkSheet:Range (cRange):Value = parts.fact-qnty
    cRange = "L":U + cRow
    chWorkSheet:Range (cRange):Value = parts.price-base
    cRange = "M":U + cRow
    chWorkSheet:Range (cRange):Value = parts.price-rubl
    cRange = "N":U + cRow
    chWorkSheet:Range (cRange):Value = string(parts.is-supp, "да/нет")
    cRange = "O":U + cRow
    chWorkSheet:Range (cRange):Value = parts.supp-type
    cRange = "P":U + cRow
    chWorkSheet:Range (cRange):Value = parts.supp-code
    cRange = "Q":U + cRow
    chWorkSheet:Range (cRange):Value = parts.cst-code
    cRange = "U":U + cRow
    chWorkSheet:Range (cRange):Value = parts.pl-code
    cRange = "V":U + cRow
    chWorkSheet:Range (cRange):Value = parts.vat-pc
  .
  define variable v-purch-str as character no-undo .
  if valid-handle(p-handle-callback)
  and p-handle-callback :get-signature("purch-code-to-str") <> ""
  then do:
    run purch-code-to-str in p-handle-callback
      (input  parts.purch-code
      ,output v-purch-str
      ) .
    assign
      cRange = "R":U + cRow
      chWorkSheet:Range (cRange):Value = v-purch-str
    .
  end.
  if valid-handle(p-handle-callback)
  and p-handle-callback :get-signature("contract-code-to-str") <> ""
  then do:
    define variable v-contract-prn-code-str as character no-undo .
    run contract-code-to-str in p-handle-callback
       (input  parts.contract-code
       ,input  parts.obj-type
       ,input  parts.obj-code
       ,output v-contract-prn-code-str
      ) .
    assign
      cRange = "S":U + cRow
      chWorkSheet:Range (cRange):Value = v-contract-prn-code-str
    .
  end.
  if parts.last-date <> ?
  then do:
    assign
      cRange = "T":U + cRow
      chWorkSheet:Range (cRange):Value = string(parts.last-date, '99/99/9999':U)
    .
  end.
  get next br-parts .
end.
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
if v-rid <> ? then do:
  reposition br-parts to recid v-rid .
end.
