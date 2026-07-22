block-level on error undo, throw.
define temp-table  tt-dateZakaz     no-undo
field id as integer
field dateStart as date
field dateEnd as date
index pi id
    .
DEFINE TEMP-TABLE tt-typeDocChoose NO-UNDO
  field type-code as character
  field typeName  as character.
define temp-table gds-list like ub.goods
  field minZapas as decimal
  field contract as character
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi contract gds-code.
 define temp-table choose-gds-list like ub.goods
  field minZapas as decimal
  field contract as character
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi contract gds-code.
  define temp-table tt-gds-list like ub.goods
  field contract-code as integer
  field price as decimal
  field doc-qnty as decimal
  index pi gds-code.
define input parameter parparentproc    as handle no-undo .
define input parameter p-ok as logical no-undo .
define input parameter pRecidClients as character no-undo .
define input parameter pDateOrder as date no-undo .
define input parameter rPeriodZakaz as integer no-undo .
define input parameter pDateStart as date no-undo .
define input parameter pDateEnd as date no-undo .
define input parameter rDaySale as integer no-undo .
define input parameter pDaySale as integer no-undo .
define input parameter pGarantDay as integer no-undo .
define input parameter pDelDayGoods as logical no-undo .
define input parameter table for tt-typeDocChoose .
define input parameter table for tt-dateZakaz .
define input parameter table for gds-list .
define variable vss-revision    as character no-undo init "$Revision: 8f5f559ebdb3, 2359, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:34 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-rsrv-plan.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-rsrv-plan.p $":U .
define variable vss-description as character no-undo init "Отчет по планированию заказов".
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
function fnc-convert-dot-to-colon returns character
    (input p-data as decimal, input p-accur as character, input p-num as integer) forward.
function fnc-convert-dot-to-colon returns character
(input p-data as decimal, input p-accur as character, input p-num as integer):
    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
    if p-data = ? then p-data = 0 .
    p-data = round(p-data, p-num).
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).
    return v-str-result.
END FUNCTION.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-pl-gds no-undo   like ub.pl-gds .
define temp-table temp-prt-obj no-undo   field prt-code         like ub.prt-obj.prt-code     field price-sale       like ub.prt-obj.price-sale   field fact-qnty        like ub.prt-obj.fact-qnty    field price-list-qnty  like ub.prt-obj.fact-qnty    field is-term          as logical   field prt-obj-recid    as recid     field price-list-recid as recid     index xpk is primary unique prt-code   index xie1 is-term .
procedure prdoclib-process-goods :
  define input  parameter p-obj-type          as character no-undo .
  define input  parameter p-obj-code          as integer   no-undo .
  define input  parameter p-artic             as character no-undo .
  define input  parameter p-prod-type         as character no-undo .
  define input  parameter p-prod-code         as integer   no-undo .
  define input  parameter p-check-price-list  as logical   no-undo .
  define input  parameter p-check-price-parts as logical   no-undo .
  define input  parameter p-doc-num           as character no-undo .
  define input  parameter p-fact-date         as date      no-undo .
  define input  parameter p-corr-user-db-num  as integer   no-undo .
  define input  parameter p-corr-user-name    as character no-undo .
  define input  parameter p-corr-date         as date      no-undo .
  define input  parameter p-corr-time         as integer   no-undo .
  define input  parameter p-corr-time-str     as character no-undo .
  define output parameter p-gds-obj-fact-qnty as decimal   no-undo .
  define variable vss-description as character no-undo initial "prdoclib-process-goods-01: обработка продажных цен товара".
  define buffer buf_gds-obj      for ub.gds-obj .
  define buffer buf_prt-obj      for ub.prt-obj .
  define buffer buf_price-list   for ub.price-list .
  define buffer buf_bar-code     for ub.bar-code .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  define variable v-gds-code             like ub.goods.gds-code    no-undo .
  define variable v-root-node            like ub.prt-obj.prt-code  no-undo .
  define variable v-root-b-code          like ub.bar-code.b-code   no-undo .
  define variable v-total-term-fact-qnty like ub.prt-obj.fact-qnty no-undo .
  define variable v-total-fact-sale      like ub.gds-obj.fact-sale no-undo .
  define variable v-doc-num     like ub.price-list.doc-num    no-undo .
  define variable v-price-sale  like ub.price-list.price-sale no-undo .
  define variable v-road-tax    like ub.price-list.road-tax   no-undo .
  define variable v-excise      like ub.price-list.excise     no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-root-node
  )  .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  v-root-node
  ,buffer buf_gds-obj
  ,buffer buf_prt-obj
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка при начале товародвижения товара на объекте" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    find current buf_gds-obj  exclusive-lock .
    find current buf_prt-obj  exclusive-lock .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  v-gds-code
  ,input  v-root-node
  ,output v-root-b-code
  )  .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  v-root-b-code
  ,input  v-root-b-code
  ,input  0
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка при определении цены признака на объекте" skip
        "Объект"     p-obj-type p-obj-code  skip
        "Бар-код"    v-root-b-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    run prdoclib-init-temp-prt-obj in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-price-sale
      ) .
    find first buf_price-list no-lock
      where buf_price-list.doc-num    = v-doc-num
        and buf_price-list.price-type = ""
        and buf_price-list.b-code     = v-root-b-code
      .
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = v-root-node
      .
    assign
      buf_temp-prt-obj.price-sale       = v-price-sale
      buf_temp-prt-obj.price-list-qnty  = buf_price-list.doc-qnty
      buf_temp-prt-obj.price-list-recid = recid(buf_price-list)
    .
    define variable l-empty-scale as logical no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  v-root-node
  ,input  'empty-scale=request'
  ,output l-empty-scale
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка при определении атрибута шкалы" skip
        "Код признака" v-root-node skip
        "Запрашивался атрибут" "empty-scale=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      v-total-term-fact-qnty = 0
      v-total-fact-sale      = 0
    .
    if l-empty-scale = true
    then do:
      for each buf_price-list
        where buf_price-list.doc-num    = v-doc-num
          and buf_price-list.main-price = false
          and buf_price-list.artic      = p-artic
          and buf_price-list.prod-type  = p-prod-type
          and buf_price-list.prod-code  = p-prod-code
          and buf_price-list.price-type = ""
      on error undo, return error return-value
      :
        if buf_price-list.doc-qnty <> ? and p-check-price-parts
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info9 skip
            "Ошибка при закрытии переоценки" skip
            "Для неосновного бар-кода товара с пустой шкалой" skip
            "указано количество отличное от ?" skip
            "Переоценка" v-doc-num skip
            "Бар-код" buf_price-list.b-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Количество" buf_price-list.doc-qnty skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
    if l-empty-scale = false
    then do:
      define variable v-unit-base like ub.goods.unit-base no-undo .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitbase in g#library
  (input  v-gds-code
  ,output v-unit-base
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info9 skip
          "Ошибка при определении базовой единицы измерения товара" skip
          "Код товара" v-gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      for each buf_price-list
        where buf_price-list.doc-num    = v-doc-num
          and buf_price-list.main-price = false
          and buf_price-list.artic      = p-artic
          and buf_price-list.prod-type  = p-prod-type
          and buf_price-list.prod-code  = p-prod-code
          and buf_price-list.price-type = ""
      on error undo, return error
      :
        if buf_price-list.doc-qnty = ?
        then do:
          find first buf_bar-code no-lock
            where buf_bar-code.b-code = buf_price-list.b-code
            no-error .
          if  available buf_bar-code
          and buf_bar-code.unit-cli = v-unit-base
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info9 skip
              "Ошибка при закрытии переоценки" skip
              "Не задано количество для бар-кода с основной единицей измерения" skip
              "Переоценка" v-doc-num skip
              "Бар-код" buf_price-list.b-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              "Количество" buf_price-list.doc-qnty skip
              "Основная единица измерения" v-unit-base skip
              "Единица измерения бар-кода" buf_bar-code.unit-cli skip
              view-as alert-box error .
            undo, return error .
          end.
          next .
        end.
        find first buf_bar-code no-lock
          where buf_bar-code.b-code = buf_price-list.b-code
          no-error .
        if not available buf_bar-code
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info9 skip
            "В переоценке задан несуществующий бар-код" skip
            "Переоценка" v-doc-num skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Бар-код" buf_price-list.b-code skip
            view-as alert-box error .
          undo, return error .
        end.
        if buf_bar-code.in-code <> ""
        or buf_bar-code.part-code <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info9 skip
            "В переоценке задан бар-код партии" skip
            "Данная версия системы не рассчитана на работу со специальными ценами по партиям" skip
            "Переоценка" v-doc-num skip
            "Бар-код" buf_price-list.b-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Код ПН" buf_bar-code.in-code buf_bar-code.part-code skip
            view-as alert-box error .
          undo, return error .
        end.
        if buf_bar-code.node-code <> v-root-node
        then do:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  buf_bar-code.node-code
  ,buffer buf_prt-obj
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info9 skip
              "Невозможно найти prt-obj" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
          run prdoclib-create-temp-prt-obj in this-procedure
            (input  v-price-sale
            ,buffer buf_prt-obj
            ,buffer buf_temp-prt-obj
            ).
          assign
            buf_temp-prt-obj.price-sale       = buf_price-list.price-sale
            buf_temp-prt-obj.price-list-qnty  = buf_price-list.doc-qnty
            buf_temp-prt-obj.price-list-recid = recid(buf_price-list)
          .
        end.
      end.
      for each buf_temp-prt-obj
        where buf_temp-prt-obj.is-term = true
      :
        if buf_temp-prt-obj.price-list-recid <> ?
        then do:
          assign
            v-total-term-fact-qnty = v-total-term-fact-qnty
                                  + buf_temp-prt-obj.fact-qnty
            v-total-fact-sale = v-total-fact-sale
                              + buf_temp-prt-obj.fact-qnty * buf_temp-prt-obj.price-sale
          .
        end.
        if p-check-price-list = true
        then do:
          if buf_temp-prt-obj.price-list-recid = ?
          or buf_temp-prt-obj.fact-qnty = buf_temp-prt-obj.price-list-qnty
          then do:
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info9 skip
              "Ошибка при закрытии переоценки" skip
              "Несовпадают текущие количества по признаку" skip
              "и количество признака в переоценке" skip
              "Переоценка" v-doc-num skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              "Код признака" buf_temp-prt-obj.prt-code skip
              "Количество по признаку" buf_temp-prt-obj.fact-qnty skip
              "Количество по переоценке" buf_temp-prt-obj.price-list-qnty skip
              "Корень шкалы товара" v-root-node skip
              view-as alert-box error .
            undo, return error .
          end.
        end.
      end.
    end.
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = v-root-node
      .
    assign
      buf_temp-prt-obj.fact-qnty = buf_temp-prt-obj.fact-qnty
                                  - v-total-term-fact-qnty
    .
    if p-check-price-list = true
    then do:
      if buf_temp-prt-obj.fact-qnty <> buf_temp-prt-obj.price-list-qnty and p-check-price-parts
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info9 skip
          "Ошибка при закрытии переоценки" skip
          "Несовпадают текущие количества по корневому признаку" skip
          "и количество признака в переоценке" skip
          "Переоценка" v-doc-num skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Код признака" buf_temp-prt-obj.prt-code skip
          "Количество по признаку" buf_temp-prt-obj.fact-qnty skip
          "Количество по переоценке" buf_temp-prt-obj.price-list-qnty skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    assign
      v-total-fact-sale = v-total-fact-sale
                        + buf_temp-prt-obj.fact-qnty * buf_temp-prt-obj.price-sale
    .
    if v-total-fact-sale = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка при вычислении суммы в продажных ценах" skip
        "Получено неопределенное значение" skip
        "Переоценка" v-doc-num skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Код признака" buf_temp-prt-obj.prt-code skip
        "Сумма в продажных ценах" v-total-fact-sale skip
        view-as alert-box error .
      undo, return error .
    end.
    define variable v-old-fact-qnty     as decimal   no-undo .
    define variable v-old-fact-cli-qnty as decimal   no-undo .
    define variable v-old-fact-base     as decimal   no-undo .
    define variable v-old-fact-rubl     as decimal   no-undo .
    define variable v-old-fact-sale     as decimal   no-undo .
    assign
      v-old-fact-qnty     = buf_gds-obj.fact-qnty
      v-old-fact-cli-qnty = buf_gds-obj.fact-cli-qnty
      v-old-fact-base     = buf_gds-obj.fact-base
      v-old-fact-rubl     = buf_gds-obj.fact-rubl
      v-old-fact-sale     = buf_gds-obj.fact-sale
    .
    assign
      buf_gds-obj.price-sale = v-price-sale
      buf_gds-obj.fact-sale  = v-total-fact-sale
    .
    define variable v-corr-date as date      no-undo .
    define variable v-corr-time as integer   no-undo .
    run cur-time in this-procedure
      (output v-corr-date
      ,output v-corr-time
      ) .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gohist in g#library
  (input  buf_gds-obj.obj-type
  ,input  buf_gds-obj.obj-code
  ,input  buf_gds-obj.gds-code
  ,input  'close':U
  ,input  buf_gds-obj.fact-qnty
  ,input  buf_gds-obj.fact-cli-qnty
  ,input  buf_gds-obj.fact-base
  ,input  buf_gds-obj.fact-rubl
  ,input  buf_gds-obj.fact-sale
  ,input  v-old-fact-qnty
  ,input  v-old-fact-cli-qnty
  ,input  v-old-fact-base
  ,input  v-old-fact-rubl
  ,input  v-old-fact-sale
  ,input  'price-doc':U
  ,input  p-doc-num
  ,input  p-fact-date
  ,input  p-corr-user-db-num
  ,input  p-corr-user-name
  ,input  p-corr-date
  ,input  p-corr-time
  ,input  p-corr-time-str
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании истории по товару на объекте" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-gds-obj-fact-qnty = buf_gds-obj.fact-qnty
    .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if  buf_gds-obj.first-doc <> ?
and buf_gds-obj.first-doc > p-fact-date then do:
  assign
    buf_gds-obj.first-doc  = p-fact-date
  .
end.
if  buf_gds-obj.last-doc <> ?
and buf_gds-obj.last-doc < p-fact-date then do:
  assign
    buf_gds-obj.last-doc   = p-fact-date
  .
end.
    for each buf_temp-prt-obj
    ,first buf_prt-obj exclusive-lock
      where recid(buf_prt-obj) = buf_temp-prt-obj.prt-obj-recid
    on error undo, return error return-value
    :
      assign
        buf_prt-obj.price-sale = buf_temp-prt-obj.price-sale
      .
    end.
  end.
end procedure.
procedure prdoclib-clear-temp-prt-obj :
  define buffer buf_temp-prt-obj for temp-prt-obj .
  do
  on error undo, return error return-value
  :
    for each buf_temp-prt-obj
    on error undo, return error return-value
    :
      delete buf_temp-prt-obj .
    end.
  end.
end procedure.
procedure prdoclib-create-temp-prt-obj :
  define input parameter  p-root-price-sale like ub.price-list.price-sale no-undo .
  define parameter buffer buf_prt-obj       for ub.prt-obj .
  define parameter buffer buf_temp-prt-obj  for temp-prt-obj .
  define buffer buf_gds-prt for ub.gds-prt .
  do
  on error undo, return error return-value
  :
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = buf_prt-obj.prt-code
      no-error .
    if not available buf_temp-prt-obj
    then do:
      create buf_temp-prt-obj .
      assign
        buf_temp-prt-obj.prt-code         = buf_prt-obj.prt-code
        buf_temp-prt-obj.price-sale       = ?
        buf_temp-prt-obj.fact-qnty        = buf_prt-obj.fact-qnty
        buf_temp-prt-obj.price-list-qnty  = ?
        buf_temp-prt-obj.prt-obj-recid    = recid(buf_prt-obj)
        buf_temp-prt-obj.price-list-recid = ?
      .
      find first buf_gds-prt no-lock
        where buf_gds-prt.node-code = buf_temp-prt-obj.prt-code
        .
      assign
        buf_temp-prt-obj.is-term = buf_gds-prt.is-term
      .
      if buf_temp-prt-obj.is-term
      then do:
        assign
          buf_temp-prt-obj.price-sale = p-root-price-sale
        .
      end.
    end.
  end.
end procedure.
procedure prdoclib-temp-prt-obj-by-prt-root :
  define input parameter  p-prt-code like ub.prt-obj.prt-code no-undo .
  define parameter buffer buf_temp-prt-obj  for temp-prt-obj .
  define buffer buf_gds-prt for ub.gds-prt .
  do
  on error undo, return error return-value
  :
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = p-prt-code
      no-error .
    if not available buf_temp-prt-obj
    then do:
      create buf_temp-prt-obj .
      assign
        buf_temp-prt-obj.prt-code         = p-prt-code
        buf_temp-prt-obj.price-sale       = ?
        buf_temp-prt-obj.fact-qnty        = 0
        buf_temp-prt-obj.price-list-qnty  = ?
        buf_temp-prt-obj.prt-obj-recid    = ?
        buf_temp-prt-obj.price-list-recid = ?
      .
      find first buf_gds-prt no-lock
        where buf_gds-prt.node-code = buf_temp-prt-obj.prt-code
        .
      assign
        buf_temp-prt-obj.is-term = buf_gds-prt.is-term
      .
      if buf_temp-prt-obj.is-term
      then do:
        assign
          buf_temp-prt-obj.price-sale = 0
        .
      end.
    end.
  end.
end procedure.
procedure prdoclib-init-temp-prt-obj :
  define input parameter p-obj-type        like ub.prt-obj.obj-type  no-undo .
  define input parameter p-obj-code        like ub.prt-obj.obj-code  no-undo .
  define input parameter p-artic           like ub.prt-obj.artic     no-undo .
  define input parameter p-prod-type       like ub.prt-obj.prod-type no-undo .
  define input parameter p-prod-code       like ub.prt-obj.prod-code no-undo .
  define input parameter p-root-price-sale like ub.prt-obj.price-sale no-undo .
  define buffer buf_prt-obj      for ub.prt-obj .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  do
  on error undo, return error return-value
  :
    run prdoclib-clear-temp-prt-obj in this-procedure .
    for each buf_prt-obj
      where buf_prt-obj.obj-type  = p-obj-type
        and buf_prt-obj.obj-code  = p-obj-code
        and buf_prt-obj.artic     = p-artic
        and buf_prt-obj.prod-type = p-prod-type
        and buf_prt-obj.prod-code = p-prod-code
    on error undo, return error return-value
    :
      run prdoclib-create-temp-prt-obj in this-procedure
        (input  p-root-price-sale
        ,buffer buf_prt-obj
        ,buffer buf_temp-prt-obj
        ).
    end.
  end.
end procedure.
procedure prdoclib-calc-fact-sale :
  define input  parameter p-price-list-recid   as recid     no-undo .
  define output parameter p-fact-qnty          as decimal   no-undo .
  define output parameter p-cur-base           as decimal   no-undo .
  define output parameter p-cur-VAT-base       as decimal   no-undo .
  define output parameter p-cur-SLT-base       as decimal   no-undo .
  define output parameter p-cur-road-tax-base  as decimal   no-undo .
  define output parameter p-cur-excise-base    as decimal   no-undo .
  define buffer buf_main_price-list for ub.price-list .
  define buffer buf_price-list      for ub.price-list .
  define buffer buf_goods           for ub.goods .
  define buffer buf_gds-obj         for ub.gds-obj .
  define buffer buf_bar-code        for ub.bar-code .
  define variable l-empty-scale   as logical   no-undo .
  do
  on error undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  )
  on stop undo, return error substitute(" stop &1 &2" , return-value , error-status :get-message(1)  )
  on end-key undo, return error substitute(" end-key &1 &2" , return-value , error-status :get-message(1)  )
  :
    find first buf_main_price-list no-lock
      where recid(buf_main_price-list) = p-price-list-recid
      no-error .
    if not available buf_main_price-list
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка переоценки" skip
        "Код записи (recid)" p-price-list-recid skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  )   .
    end.
    if buf_main_price-list.main-price <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка задания входных параметров" skip
        "Строка переоценки не является основной" skip
        "Код записи (recid)" p-price-list-recid skip
        "Переоценка" buf_main_price-list.doc-num skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        "Бар-код" buf_main_price-list.b-code skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  )  .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = buf_main_price-list.artic
        and buf_goods.prod-type = buf_main_price-list.prod-type
        and buf_goods.prod-code = buf_main_price-list.prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Не найден товар" skip
        "Переоценка" buf_main_price-list.doc-num skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
    end.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_main_price-list.artic
  ,input  buf_main_price-list.prod-type
  ,input  buf_main_price-list.prod-code
  ,input  'empty-scale=request':u
  ,output l-empty-scale
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        'empty-scale=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
    end.
    find first buf_gds-obj no-lock
      where buf_gds-obj.gds-code = buf_goods.gds-code
        and buf_gds-obj.obj-type = buf_main_price-list.obj-type
        and buf_gds-obj.obj-code = buf_main_price-list.obj-code
      no-error .
      if not available buf_gds-obj then do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  buf_main_price-list.obj-type
  ,input  buf_main_price-list.obj-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,buffer buf_gds-obj
  ) no-error .
        if error-status :error then do:
           undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
        end.
      end.
    define variable price-rubl-with-tax-sale-prl    as decimal   no-undo .
    define variable price-base-with-tax-sale-prl    as decimal   no-undo .
    define variable price-rubl-without-tax-sale-prl as decimal   no-undo .
    define variable price-base-without-tax-sale-prl as decimal   no-undo .
    define variable vat-base-sale-prl               as decimal   no-undo .
    define variable vat-rubl-sale-prl               as decimal   no-undo .
    define variable vat-base-buyer-prl              as decimal   no-undo .
    define variable vat-rubl-buyer-prl              as decimal   no-undo .
    define variable slt-base-sale-prl               as decimal   no-undo .
    define variable slt-rubl-sale-prl               as decimal   no-undo .
    define variable road-tax-base-sale-prl          as decimal   no-undo .
    define variable road-tax-rubl-sale-prl          as decimal   no-undo .
    define variable excise-base-sale-prl            as decimal   no-undo .
    define variable excise-rubl-sale-prl            as decimal   no-undo .
    define variable discnt-base-sale-prl            as decimal   no-undo .
    define variable discnt-rubl-sale-prl            as decimal   no-undo .
    if buf_main_price-list.doc-qnty <> 0
    then do:
      run prl-vat in this-procedure
        (input  recid(buf_main_price-list)
        ,output price-rubl-with-tax-sale-prl
        ,output price-base-with-tax-sale-prl
        ,output price-rubl-without-tax-sale-prl
        ,output price-base-without-tax-sale-prl
        ,output vat-base-sale-prl
        ,output vat-rubl-sale-prl
        ,output vat-base-buyer-prl
        ,output vat-rubl-buyer-prl
        ,output slt-base-sale-prl
        ,output slt-rubl-sale-prl
        ,output road-tax-base-sale-prl
        ,output road-tax-rubl-sale-prl
        ,output excise-base-sale-prl
        ,output excise-rubl-sale-prl
        ,output discnt-base-sale-prl
        ,output discnt-rubl-sale-prl
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info9 skip
          "Ошибка при вызове процеды prl-vat" skip
          "Документ" buf_main_price-list.doc-num skip
          "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
      end.
    end.
    else do:
      assign
        price-rubl-with-tax-sale-prl    = 0
        price-base-with-tax-sale-prl    = 0
        price-rubl-without-tax-sale-prl = 0
        price-base-without-tax-sale-prl = 0
        vat-base-sale-prl               = 0
        vat-rubl-sale-prl               = 0
        vat-base-buyer-prl              = 0
        vat-rubl-buyer-prl              = 0
        slt-base-sale-prl               = 0
        slt-rubl-sale-prl               = 0
        road-tax-base-sale-prl          = 0
        road-tax-rubl-sale-prl          = 0
        excise-base-sale-prl            = 0
        excise-rubl-sale-prl            = 0
        discnt-base-sale-prl            = 0
        discnt-rubl-sale-prl            = 0
      .
    end.
    define variable v-curr-r-b as character no-undo .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    if v-curr-r-b = 'base':U
    then do:
      assign
        p-fact-qnty         = buf_main_price-list.doc-qnty
        p-cur-base          = price-base-with-tax-sale-prl * buf_main_price-list.doc-qnty
        p-cur-VAT-base      = vat-base-sale-prl * buf_main_price-list.doc-qnty
        p-cur-SLT-base      = slt-base-sale-prl * buf_main_price-list.doc-qnty
        p-cur-road-tax-base = road-tax-base-sale-prl * buf_main_price-list.doc-qnty
        p-cur-excise-base   = excise-base-sale-prl * buf_main_price-list.doc-qnty
      .
    end.
    else do:
      assign
        p-fact-qnty         = buf_main_price-list.doc-qnty
        p-cur-base          = price-rubl-with-tax-sale-prl * buf_main_price-list.doc-qnty
        p-cur-VAT-base      = vat-rubl-sale-prl * buf_main_price-list.doc-qnty
        p-cur-SLT-base      = slt-rubl-sale-prl * buf_main_price-list.doc-qnty
        p-cur-road-tax-base = road-tax-rubl-sale-prl * buf_main_price-list.doc-qnty
        p-cur-excise-base   = excise-rubl-sale-prl * buf_main_price-list.doc-qnty
      .
    end.
      define variable v-unit-base like ub.goods.unit-base no-undo .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitbase in g#library
  (input  buf_goods.gds-code
  ,output v-unit-base
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info9 skip
          "Ошибка при определении базовой единицы измерения товара" skip
          "Код товара" buf_goods.gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
      end.
      for each buf_price-list no-lock
        where buf_price-list.doc-num    = buf_main_price-list.doc-num
          and buf_price-list.main-price = false
          and buf_price-list.artic      = buf_main_price-list.artic
          and buf_price-list.prod-type  = buf_main_price-list.prod-type
          and buf_price-list.prod-code  = buf_main_price-list.prod-code
      :
        if buf_price-list.doc-qnty = ?
        then do:
          find first buf_bar-code no-lock
            where buf_bar-code.b-code = buf_price-list.b-code
            no-error .
          if available buf_bar-code
          and buf_bar-code.unit-cli = v-unit-base
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info9 skip
              "Ошибка при закрытии переоценки" skip
              "Не задано количество для бар-кода с основной единицей измерения" skip
              "Переоценка" buf_main_price-list.doc-num skip
              "Бар-код" buf_price-list.b-code skip
              "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
              "Количество" buf_price-list.doc-qnty skip
              "Основная единица измерения" v-unit-base skip
              "Единица измерения бар-кода" buf_bar-code.unit-cli skip
              view-as alert-box error .
            undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
          end.
          next .
        end.
        if not can-find
          (first buf_bar-code
          where buf_bar-code.b-code = buf_price-list.b-code
          )
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info9 skip
            "В переоценке задан несуществующий бар-код" skip
            "Переоценка" buf_price-list.doc-num skip
            "Артикул" buf_price-list.artic buf_price-list.prod-type buf_price-list.prod-code skip
            "Бар-код" buf_price-list.b-code skip
            view-as alert-box error .
          undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
        end.
        if buf_price-list.doc-qnty <> 0
        then do:
          run prl-vat in this-procedure
            (input  recid(buf_price-list)
            ,output price-rubl-with-tax-sale-prl
            ,output price-base-with-tax-sale-prl
            ,output price-rubl-without-tax-sale-prl
            ,output price-base-without-tax-sale-prl
            ,output vat-base-sale-prl
            ,output vat-rubl-sale-prl
            ,output vat-base-buyer-prl
            ,output vat-rubl-buyer-prl
            ,output slt-base-sale-prl
            ,output slt-rubl-sale-prl
            ,output road-tax-base-sale-prl
            ,output road-tax-rubl-sale-prl
            ,output excise-base-sale-prl
            ,output excise-rubl-sale-prl
            ,output discnt-base-sale-prl
            ,output discnt-rubl-sale-prl
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info9 skip
              "Ошибка при вызове процеды prl-vat" skip
              "Документ" buf_price-list.doc-num skip
              "Артикул" buf_price-list.artic buf_price-list.prod-type buf_price-list.prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
          end.
        end.
        else do:
          assign
            price-rubl-with-tax-sale-prl    = 0
            price-base-with-tax-sale-prl    = 0
            price-rubl-without-tax-sale-prl = 0
            price-base-without-tax-sale-prl = 0
            vat-base-sale-prl               = 0
            vat-rubl-sale-prl               = 0
            vat-base-buyer-prl              = 0
            vat-rubl-buyer-prl              = 0
            slt-base-sale-prl               = 0
            slt-rubl-sale-prl               = 0
            road-tax-base-sale-prl          = 0
            road-tax-rubl-sale-prl          = 0
            excise-base-sale-prl            = 0
            excise-rubl-sale-prl            = 0
            discnt-base-sale-prl            = 0
            discnt-rubl-sale-prl            = 0
          .
        end.
        if v-curr-r-b = 'base':U
        then do:
          assign
            p-fact-qnty         = p-fact-qnty
                                + buf_price-list.doc-qnty
            p-cur-base          = p-cur-base
                                + price-base-with-tax-sale-prl * buf_price-list.doc-qnty
            p-cur-VAT-base      = p-cur-VAT-base
                                + vat-base-sale-prl * buf_price-list.doc-qnty
            p-cur-SLT-base      = p-cur-SLT-base
                                + slt-base-sale-prl * buf_price-list.doc-qnty
            p-cur-road-tax-base = p-cur-road-tax-base
                                + road-tax-base-sale-prl * buf_price-list.doc-qnty
            p-cur-excise-base   = p-cur-excise-base
                                + excise-base-sale-prl * buf_price-list.doc-qnty
          .
        end.
        else do:
          assign
            p-fact-qnty         = p-fact-qnty
                                + buf_price-list.doc-qnty
            p-cur-base          = p-cur-base
                                + price-rubl-with-tax-sale-prl * buf_price-list.doc-qnty
            p-cur-VAT-base      = p-cur-VAT-base
                                + vat-rubl-sale-prl * buf_price-list.doc-qnty
            p-cur-SLT-base      = p-cur-SLT-base
                                + slt-rubl-sale-prl * buf_price-list.doc-qnty
            p-cur-road-tax-base = p-cur-road-tax-base
                                + road-tax-rubl-sale-prl * buf_price-list.doc-qnty
            p-cur-excise-base   = p-cur-excise-base
                                + excise-rubl-sale-prl * buf_price-list.doc-qnty
          .
        end.
      end.
  end.
end procedure.
procedure prdoclib-calc-prc :
  define input  parameter p-price-doc-recid as   recid                  no-undo.
  define input  parameter p-cons-pay        as   integer                no-undo.
  define output parameter p-ov-cons         like ub.doc-line.price-base no-undo.
  define output parameter p-ov-VAT-cons     like ub.doc-line.price-base no-undo.
  define output parameter p-ov-SLT-cons     like ub.doc-line.price-base no-undo.
  define output parameter p-ov-prch         like ub.doc-line.price-base no-undo.
  define output parameter p-ov-VAT-prch     like ub.doc-line.price-base no-undo.
  define output parameter p-ov-SLT-prch     like ub.doc-line.price-base no-undo.
  do
  on error undo, return error return-value
  :
    define buffer buf_price-doc       for ub.price-doc .
    define buffer buf_price-list      for ub.price-list .
    define buffer buf_parts           for ub.parts .
    define variable v-ov-qnty     as decimal   no-undo .
    define variable v-ov-base     as decimal   no-undo .
    define variable v-ov-VAT-base as decimal   no-undo .
    define variable v-ov-SLT-base as decimal   no-undo .
    define variable v-cons-qnty   as decimal   no-undo .
    define variable v-prch-qnty   as decimal   no-undo .
    define variable v-cons-mult   as decimal   no-undo .
    define variable v-prch-mult   as decimal   no-undo .
    find first buf_price-doc no-lock
      where recid(buf_price-doc) = p-price-doc-recid
      no-error .
    if not available buf_price-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ переоценки" skip
        "Код записи (recid)" p-price-doc-recid skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_price-list no-lock
      where buf_price-list.doc-num    = buf_price-doc.doc-num
        and buf_price-list.main-price = true
    on error undo, return error return-value
    :
      run prdoclib-calc-ov
        (input recid(buf_price-list)
        ,output v-ov-qnty
        ,output v-ov-base
        ,output v-ov-VAT-base
        ,output v-ov-SLT-base
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info9 skip
            "Ошибка при вызове процедуры prdoclib-calc-ov" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        undo, return error return-value .
      end.
      assign
        v-cons-qnty = 0
        v-prch-qnty = 0
      .
      for each buf_parts no-lock
        where buf_parts.out-code  = buf_price-list.doc-num
          and buf_parts.obj-type  = buf_price-list.obj-type
          and buf_parts.obj-code  = buf_price-list.obj-code
          and buf_parts.artic     = buf_price-list.artic
          and buf_parts.prod-type = buf_price-list.prod-type
          and buf_parts.prod-code = buf_price-list.prod-code
      on error undo, return error return-value
      :
        if buf_parts.pay-code = p-cons-pay
        then do:
          assign
            v-cons-qnty = v-cons-qnty + buf_parts.fact-qnty
          .
        end.
        else do:
          assign
            v-prch-qnty = v-prch-qnty + buf_parts.fact-qnty
          .
        end.
      end.
      if (v-cons-qnty + v-prch-qnty) = 0
      then do:
        assign
          v-cons-mult = 0
          v-prch-mult = 1
        .
      end.
      else do:
        assign
          v-cons-mult = v-cons-qnty / (v-cons-qnty + v-prch-qnty)
          v-prch-mult = v-prch-qnty / (v-cons-qnty + v-prch-qnty)
        .
      end.
      assign
        p-ov-cons     = p-ov-cons     + v-ov-base     * v-cons-mult
        p-ov-VAT-cons = p-ov-VAT-cons + v-ov-VAT-base * v-cons-mult
        p-ov-SLT-cons = p-ov-SLT-cons + v-ov-SLT-base * v-cons-mult
        p-ov-prch     = p-ov-prch     + v-ov-base     * v-prch-mult
        p-ov-VAT-prch = p-ov-VAT-prch + v-ov-VAT-base * v-prch-mult
        p-ov-SLT-prch = p-ov-SLT-prch + v-ov-SLT-base * v-prch-mult
      .
    end.
  end.
end procedure.
procedure prdoclib-calc-ov :
  define input  parameter p-price-list-recid as recid     no-undo .
  define output parameter p-fact-qnty        as decimal   no-undo .
  define output parameter p-ov-base          as decimal   no-undo .
  define output parameter p-ov-VAT-base      as decimal   no-undo .
  define output parameter p-ov-SLT-base      as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    define buffer buf_main_price-list    for ub.price-list .
    define buffer buf_prev_price-list    for ub.price-list .
    define buffer buf_special_price-list for ub.price-list .
    define buffer buf_goods              for ub.goods .
    define variable v-fact-qnty             like ub.doc-line.price-base no-undo.
    define variable v-cur-base              like ub.doc-line.price-base no-undo.
    define variable v-cur-VAT-base          like ub.doc-line.price-base no-undo.
    define variable v-cur-SLT-base          like ub.doc-line.price-base no-undo.
    define variable v-cur-road-tax-base     like ub.doc-line.price-base no-undo.
    define variable v-cur-excise-base       like ub.doc-line.price-base no-undo.
    define variable v-prev-price-list-recid as   recid                  no-undo.
    define variable v-prev-cli-base-rate    like ub.goods.cli-base-rate no-undo.
    define variable v-prev-fact-qnty        like ub.doc-line.price-base no-undo.
    define variable v-prev-cur-base         like ub.doc-line.price-base no-undo.
    define variable v-prev-cur-VAT-base     like ub.doc-line.price-base no-undo.
    define variable v-prev-cur-SLT-base     like ub.doc-line.price-base no-undo.
    find first buf_main_price-list no-lock
      where recid(buf_main_price-list) = p-price-list-recid
      no-error .
    if not available buf_main_price-list
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка переоценки" skip
        "Код записи (recid)" p-price-list-recid skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_main_price-list.main-price <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка задания входных параметров" skip
        "Строка переоценки не является основной" skip
        "Код записи (recid)" p-price-list-recid skip
        "Переоценка" buf_main_price-list.doc-num skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        "Бар-код" buf_main_price-list.b-code skip
        view-as alert-box error .
      undo, return error .
    end.
    run prdoclib-calc-fact-sale in this-procedure
      (input  recid(buf_main_price-list)
      ,output v-fact-qnty
      ,output v-cur-base
      ,output v-cur-VAT-base
      ,output v-cur-SLT-base
      ,output v-cur-road-tax-base
      ,output v-cur-excise-base
      ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка при расчете сумм переоценки." skip
        "Документ переоценки" buf_main_price-list.doc-num skip
        "Товар" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  buf_main_price-list.obj-type
  ,input  buf_main_price-list.obj-code
  ,input  buf_main_price-list.b-code
  ,input  buf_main_price-list.b-code
  ,input  buf_main_price-list.fact-order
  ,output v-prev-price-list-recid
  ,output v-prev-cli-base-rate
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка при поиске предыдущей переоценки." skip
        "Документ переоценки " buf_main_price-list.doc-num skip
        "Товар " buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-prev-price-list-recid <> ?
    then do:
      find first buf_prev_price-list no-lock
        where recid(buf_prev_price-list) = v-prev-price-list-recid
        .
      find first buf_special_price-list no-lock
        where buf_special_price-list.doc-num    = buf_prev_price-list.doc-num
          and buf_special_price-list.main-price = false
          and buf_special_price-list.artic      = buf_prev_price-list.artic
          and buf_special_price-list.prod-type  = buf_prev_price-list.prod-type
          and buf_special_price-list.prod-code  = buf_prev_price-list.prod-code
          and buf_special_price-list.doc-qnty   <> ?
        no-error .
      if available buf_special_price-list
      then do:
        message
          "Товар имеет специальные цены на признаки" skip
          "Разбиение суммы переоценки по консигнации, выкупу невозможно" skip
          "Переоценка" buf_prev_price-list.doc-num skip
          "Товар" buf_prev_price-list.artic buf_prev_price-list.prod-type buf_prev_price-list.prod-code skip
          view-as alert-box error .
        undo, return error .
      end.
      find first buf_goods no-lock
        where buf_goods.artic     = buf_main_price-list.artic
          and buf_goods.prod-type = buf_main_price-list.prod-type
          and buf_goods.prod-code = buf_main_price-list.prod-code
        no-error .
      if not available buf_goods
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info9 skip
          "Не найден товар" skip
          "Переоценка" buf_main_price-list.doc-num skip
          "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
          view-as alert-box error .
        undo, return error .
      end.
      if buf_prev_price-list.vat-pc = ?
      or buf_prev_price-list.slt-pc = ?
      then do:
        message
          "В переоценке не заданы налоги товара" skip
          "Разбиение суммы переоценки по консигнации, выкупу невозможно" skip
          "Переоценка" buf_prev_price-list.doc-num skip
          "Товар" buf_prev_price-list.artic buf_prev_price-list.prod-type buf_prev_price-list.prod-code skip
          "НДС" buf_prev_price-list.vat-pc skip
          "НП" buf_prev_price-list.slt-pc skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      define variable v-prev-cur-SLT-pc as decimal no-undo .
      assign
        v-prev-cur-SLT-pc   = buf_prev_price-list.price-sale * buf_prev_price-list.slt-pc / (100 + buf_prev_price-list.slt-pc)
      .
      assign
        v-prev-cur-base     = v-fact-qnty * buf_prev_price-list.price-sale
        v-prev-cur-VAT-base = v-fact-qnty
                            * (buf_prev_price-list.price-sale - v-prev-cur-SLT-pc)
                            * buf_prev_price-list.vat-pc / (100 + buf_prev_price-list.vat-pc)
        v-prev-cur-SLT-base = v-fact-qnty * v-prev-cur-SLT-pc
      .
      assign
        p-fact-qnty   = v-fact-qnty
        p-ov-base     = v-cur-base     - v-prev-cur-base
        p-ov-VAT-base = v-cur-VAT-base - v-prev-cur-VAT-base
        p-ov-SLT-base = v-cur-SLT-base - v-prev-cur-SLT-base
      .
    end.
    else do:
      assign
        v-prev-cur-base     = 0
        v-prev-cur-VAT-base = 0
        v-prev-cur-SLT-base = 0
        .
      assign
        p-fact-qnty   = v-fact-qnty
        p-ov-base     = v-cur-base     - v-prev-cur-base
        p-ov-VAT-base = v-cur-VAT-base - v-prev-cur-VAT-base
        p-ov-SLT-base = v-cur-SLT-base - v-prev-cur-SLT-base
      .
    end.
  end.
end procedure.
procedure prdoclib-init-prt-obj-by-factord :
  define input parameter p-obj-type           like ub.gds-obj.obj-type  no-undo .
  define input parameter p-obj-code           like ub.gds-obj.obj-code  no-undo .
  define input parameter p-artic              like ub.gds-obj.artic     no-undo .
  define input parameter p-prod-type          like ub.gds-obj.prod-type no-undo .
  define input parameter p-prod-code          like ub.gds-obj.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "prdoclib-init-prt-obj-by-factord: определение остатков по признакам на любой момент времени".
  define buffer buf_gds-obj      for ub.gds-obj .
  define buffer buf_doc-line     for ub.doc-line .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  define variable v-total-gds-dtl-qnty as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    do transaction
    on error undo, return error return-value
    :
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info9 skip
          "Невозможно найти gds-obj" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    run prdoclib-init-temp-prt-obj in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input 0
      ) .
    for each buf_temp-prt-obj
      where buf_temp-prt-obj.is-term <> true
    on error undo, return error return-value
    :
      delete buf_temp-prt-obj .
    end.
    if p-include-fact-order = true
    then do:
      assign
       p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order >= p-fact-order
    on error undo, return error return-value
    :
      run prdoclib-process-document in this-procedure
        (input  buf_doc-line.doc-code
        ,input  p-obj-type
        ,input  p-obj-code
        ,input  p-artic
        ,input  p-prod-type
        ,input  p-prod-code
        ,output v-total-gds-dtl-qnty
        ) .
    end.
  end.
end procedure.
procedure prdoclib-process-document :
  define input  parameter p-doc-code           as character no-undo .
  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-artic              as character no-undo .
  define input  parameter p-prod-type          as character no-undo .
  define input  parameter p-prod-code          as integer   no-undo .
  define output parameter p-total-gds-dtl-qnty as decimal   no-undo .
  define buffer buf_trn-doc      for ub.trn-doc .
  define buffer buf_gds-dtl      for ub.gds-dtl .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка при поиске документа" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-total-gds-dtl-qnty = 0
    .
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = p-doc-code
        and buf_gds-dtl.artic     = p-artic
        and buf_gds-dtl.prod-type = p-prod-type
        and buf_gds-dtl.prod-code = p-prod-code
    on error undo, return error
    :
      define variable v-term-node as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  buf_gds-dtl.prt-code
  ,output v-term-node
  )  .
      run prdoclib-temp-prt-obj-by-prt-root in this-procedure
        (input  v-term-node
        ,buffer buf_temp-prt-obj
        ) .
      if buf_temp-prt-obj.is-term <> true then do:
        undo, return error substitute("Документ ссылается на нетерминальный признак. Код признака &1"
                                     ,buf_gds-dtl.prt-code
                                     ) .
      end.
      case buf_trn-doc.doc-type :
        when 'при':U or
        when 'возврат':U
        then do:
          assign
            p-total-gds-dtl-qnty        = p-total-gds-dtl-qnty
                                        - buf_gds-dtl.fact-qnty
            buf_temp-prt-obj.fact-qnty  = buf_temp-prt-obj.fact-qnty
                                        - buf_gds-dtl.fact-qnty
          .
        end.
        when 'рас':U or
        when 'спи':U
        then do:
          assign
            p-total-gds-dtl-qnty        = p-total-gds-dtl-qnty
                                        + buf_gds-dtl.fact-qnty
            buf_temp-prt-obj.fact-qnty  = buf_temp-prt-obj.fact-qnty
                                        + buf_gds-dtl.fact-qnty
          .
        end.
        when 'инв':U
        then do:
          assign
            p-total-gds-dtl-qnty        = p-total-gds-dtl-qnty
                                        - buf_gds-dtl.doc-qnty
            buf_temp-prt-obj.fact-qnty  = buf_temp-prt-obj.fact-qnty
                                        - buf_gds-dtl.doc-qnty
          .
        end.
        otherwise do:
          undo, return error substitute("Неизвестный тип документа &1"
                                       ,buf_trn-doc.doc-type
                                       ) .
        end.
      end.
    end.
  end.
end procedure.
procedure prdoclib-prc-pl-document :
  define input  parameter p-doc-code              as character no-undo .
  define input  parameter p-obj-type              as character no-undo .
  define input  parameter p-obj-code              as integer   no-undo .
  define input  parameter p-gds-code              as integer   no-undo .
  define output parameter p-total-pl-gds-qnty     as decimal   no-undo .
  define output parameter p-total-pl-gds-cli-qnty as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    define buffer buf_trn-doc      for ub.trn-doc .
    define buffer buf_doc-pl       for ub.doc-pl .
    define buffer buf_temp-pl-gds for temp-pl-gds .
    define variable v-sign as decimal   no-undo .
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка при поиске документа" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Товар" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-total-pl-gds-qnty     = 0
      p-total-pl-gds-cli-qnty = 0
    .
    for each buf_doc-pl no-lock
      where buf_doc-pl.out-code  = p-doc-code
        and buf_doc-pl.gds-code  = p-gds-code
    on error undo, return error return-value
    :
      find first buf_temp-pl-gds
        where buf_temp-pl-gds.obj-type = buf_trn-doc.obj-type
          and buf_temp-pl-gds.obj-code = buf_trn-doc.obj-code
          and buf_temp-pl-gds.pl-code  = buf_doc-pl.pl-code
        .
      case buf_trn-doc.doc-type :
        when 'при':U
        or when 'возврат':U
        or when 'инв':U
        then do:
          assign
            v-sign = -1.0
          .
        end.
        when 'рас':U or
        when 'спи':U
        then do:
          assign
            v-sign = 1.0
          .
        end.
        otherwise do:
          undo, return error substitute("(prdoclib-prc-pl-document) Неизвестный тип документа &1", buf_trn-doc.doc-type ) .
        end.
      end case.
      assign
        p-total-pl-gds-qnty           = p-total-pl-gds-qnty           + buf_doc-pl.fact-qnty     * v-sign
        p-total-pl-gds-cli-qnty       = p-total-pl-gds-cli-qnty       + buf_doc-pl.cli-fact-qnty * v-sign
        buf_temp-pl-gds.fact-qnty     = buf_temp-pl-gds.fact-qnty     + buf_doc-pl.fact-qnty     * v-sign
        buf_temp-pl-gds.cli-fact-qnty = buf_temp-pl-gds.cli-fact-qnty + buf_doc-pl.cli-fact-qnty * v-sign
      .
    end.
  end.
end procedure.
procedure prdoclib-init-prt-obj-by-date :
  define input parameter p-obj-type   like ub.gds-obj.obj-type  no-undo .
  define input parameter p-obj-code   like ub.gds-obj.obj-code  no-undo .
  define input parameter p-artic      like ub.gds-obj.artic     no-undo .
  define input parameter p-prod-type  like ub.gds-obj.prod-type no-undo .
  define input parameter p-prod-code  like ub.gds-obj.prod-code no-undo .
  define input parameter p-fact-date  as date      no-undo .
  define variable vss-description as character no-undo init "prdoclib-init-prt-obj-by-date: определение остатков по признакам на конец дня".
  do
  on error undo, return error return-value
  :
    define variable v-fact-order                as decimal   no-undo .
    define variable v-shift-end-fact-order      as decimal   no-undo .
    define variable v-day-end-fact-order        as decimal   no-undo .
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  ?
      ,input  0
      ,input  false
      ,output v-fact-order
      ,output v-shift-end-fact-order
      ,output v-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка при определении момента времени, на который требуется остаток" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
    run prdoclib-init-prt-obj-by-date-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-day-end-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка при вызове метода prdoclib-init-prt-obj-by-date-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure prdoclib-calc-temp-fact-sale :
  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-gds-code           as integer   no-undo .
  define input  parameter p-day-end-fact-order as decimal   no-undo .
  define input  parameter p-curr-r-b           as character no-undo .
  define output parameter p-fact-qnty          as decimal   no-undo .
  define output parameter p-cur-base           as decimal   no-undo .
  define output parameter p-cur-VAT-base       as decimal   no-undo .
  define output parameter p-cur-SLT-base       as decimal   no-undo .
  define output parameter p-cur-road-tax-base  as decimal   no-undo .
  define output parameter p-cur-excise-base    as decimal   no-undo .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  define variable v-prt-b-code        like ub.bar-code.b-code no-undo .
  define variable v-cli-base-rate     like ub.bar-code.cli-base-rate no-undo .
  define variable parrecid-prl        as recid     no-undo .
  define variable v-fact-qnty         as decimal   no-undo .
  define variable v-cur-base          as decimal   no-undo .
  define variable v-cur-VAT-base      as decimal   no-undo .
  define variable v-cur-SLT-base      as decimal   no-undo .
  define variable v-cur-road-tax-base as decimal   no-undo .
  define variable v-cur-excise-base   as decimal   no-undo .
  define variable price-rubl-with-tax-sale-prl    as decimal   no-undo .
  define variable price-base-with-tax-sale-prl    as decimal   no-undo .
  define variable price-rubl-without-tax-sale-prl as decimal   no-undo .
  define variable price-base-without-tax-sale-prl as decimal   no-undo .
  define variable vat-base-sale-prl               as decimal   no-undo .
  define variable vat-rubl-sale-prl               as decimal   no-undo .
  define variable vat-base-buyer-prl              as decimal   no-undo .
  define variable vat-rubl-buyer-prl              as decimal   no-undo .
  define variable slt-base-sale-prl               as decimal   no-undo .
  define variable slt-rubl-sale-prl               as decimal   no-undo .
  define variable road-tax-base-sale-prl          as decimal   no-undo .
  define variable road-tax-rubl-sale-prl          as decimal   no-undo .
  define variable excise-base-sale-prl            as decimal   no-undo .
  define variable excise-rubl-sale-prl            as decimal   no-undo .
  define variable discnt-base-sale-prl            as decimal   no-undo .
  define variable discnt-rubl-sale-prl            as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    for each buf_temp-prt-obj no-lock
    on error undo, return error return-value
    :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  p-gds-code
  ,input  buf_temp-prt-obj.prt-code
  ,output v-prt-b-code
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении бар-кода признака" skip
          "Код товара"   p-gds-code skip
          "Код признака" buf_temp-prt-obj.prt-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  v-prt-b-code
  ,input  0
  ,input  p-day-end-fact-order
  ,output parrecid-prl
  ,output v-cli-base-rate
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении цены бар-кода" skip
          "Объект" p-obj-type p-obj-code skip
          "Бар-код" v-prt-b-code skip
          "fact-order" p-day-end-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      if parrecid-prl <> ?
      then do:
        run prl-vat in this-procedure
          (input  parrecid-prl
          ,output price-rubl-with-tax-sale-prl
          ,output price-base-with-tax-sale-prl
          ,output price-rubl-without-tax-sale-prl
          ,output price-base-without-tax-sale-prl
          ,output vat-base-sale-prl
          ,output vat-rubl-sale-prl
          ,output vat-base-buyer-prl
          ,output vat-rubl-buyer-prl
          ,output slt-base-sale-prl
          ,output slt-rubl-sale-prl
          ,output road-tax-base-sale-prl
          ,output road-tax-rubl-sale-prl
          ,output excise-base-sale-prl
          ,output excise-rubl-sale-prl
          ,output discnt-base-sale-prl
          ,output discnt-rubl-sale-prl
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процеды prl-vat" skip
            "Объект" p-obj-type p-obj-code skip
            "Код товара" p-gds-code skip
            "Указатель на запись переоценки" parrecid-prl skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
      else do:
        assign
          price-rubl-with-tax-sale-prl    = 0
          price-base-with-tax-sale-prl    = 0
          price-rubl-without-tax-sale-prl = 0
          price-base-without-tax-sale-prl = 0
          vat-base-sale-prl               = 0
          vat-rubl-sale-prl               = 0
          slt-base-sale-prl               = 0
          slt-rubl-sale-prl               = 0
          road-tax-base-sale-prl          = 0
          road-tax-rubl-sale-prl          = 0
          excise-base-sale-prl            = 0
          excise-rubl-sale-prl            = 0
          discnt-base-sale-prl            = 0
          discnt-rubl-sale-prl            = 0
        .
      end.
      assign
        v-fact-qnty         = v-fact-qnty
                            + buf_temp-prt-obj.fact-qnty
        v-cur-base          = v-cur-base
                            + (if p-curr-r-b = 'base':U
                                then price-base-with-tax-sale-prl
                                else price-rubl-with-tax-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-VAT-base      = v-cur-VAT-base
                            + (if p-curr-r-b = 'base':U
                                then vat-base-sale-prl
                                else vat-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-SLT-base      = v-cur-SLT-base
                            + (if p-curr-r-b = 'base':U
                                then slt-base-sale-prl
                                else slt-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-road-tax-base = v-cur-road-tax-base
                            + (if p-curr-r-b = 'base':U
                                then road-tax-base-sale-prl
                                else road-tax-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-excise-base   = v-cur-excise-base
                            + (if p-curr-r-b = 'base':U
                                then excise-base-sale-prl
                                else excise-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
      .
    end.
    assign
      p-fact-qnty         = v-fact-qnty
      p-cur-base          = v-cur-base
      p-cur-VAT-base      = v-cur-VAT-base
      p-cur-SLT-base      = v-cur-SLT-base
      p-cur-road-tax-base = v-cur-road-tax-base
      p-cur-excise-base   = v-cur-excise-base
    .
  end.
end procedure.
procedure prdoclib-clear-temp-pl-gds :
  define buffer buf_temp-pl-gds for temp-pl-gds .
  do
  on error undo, return error return-value
  :
    for each buf_temp-pl-gds
    on error undo, return error return-value
    :
      delete buf_temp-pl-gds .
    end.
  end.
end procedure.
procedure prdoclib-init-temp-pl-gds :
  define input parameter p-obj-type        like ub.pl-gds.obj-type  no-undo .
  define input parameter p-obj-code        like ub.pl-gds.obj-code  no-undo .
  define input parameter p-gds-code        like ub.pl-gds.gds-code  no-undo .
  define buffer buf_pl-gds      for ub.pl-gds .
  define buffer buf_temp-pl-gds for temp-pl-gds .
  do
  on error undo, return error return-value
  :
    run prdoclib-clear-temp-pl-gds in this-procedure .
    for each buf_pl-gds
      where buf_pl-gds.obj-type = p-obj-type
        and buf_pl-gds.obj-code = p-obj-code
        and buf_pl-gds.gds-code = p-gds-code
    on error undo, return error return-value
    :
      create buf_temp-pl-gds .
      buffer-copy buf_pl-gds to buf_temp-pl-gds .
    end.
  end.
end procedure.
procedure prdoclib-init-pl-gds-by-factord :
  define input parameter p-obj-type           like ub.gds-obj.obj-type  no-undo .
  define input parameter p-obj-code           like ub.gds-obj.obj-code  no-undo .
  define input parameter p-artic              like ub.gds-obj.artic     no-undo .
  define input parameter p-prod-type          like ub.gds-obj.prod-type no-undo .
  define input parameter p-prod-code          like ub.gds-obj.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "prdoclib-init-pl-gds-by-factord: определение остатков по признакам на любой момент времени".
  define buffer buf_goods       for ub.goods .
  define buffer buf_gds-obj     for ub.gds-obj .
  define buffer buf_doc-line    for ub.doc-line .
  define buffer buf_temp-pl-gds for temp-pl-gds .
  define variable v-total-pl-gds-qnty     as decimal   no-undo .
  define variable v-total-pl-gds-cli-qnty as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    do transaction
    on error undo, return error return-value
    :
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info9 skip
          "Невозможно найти gds-obj" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      .
    run prdoclib-init-temp-pl-gds in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input buf_goods.gds-code
      ) .
    if p-include-fact-order = true
    then do:
      assign
       p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order >= p-fact-order
    on error undo, return error return-value
    :
      run prdoclib-prc-pl-document in this-procedure
        ( input  buf_doc-line.doc-code
         ,input  p-obj-type
         ,input  p-obj-code
         ,input  buf_goods.gds-code
         ,output v-total-pl-gds-qnty
         ,output v-total-pl-gds-cli-qnty
        ) .
    end.
  end.
end procedure.
define new shared temp-table tt-zakaz like ub.order-line
    field gds-name          as character
    field minZapas          as decimal
    field volMinZapas       as integer
    field ostatokDay        as decimal
    field qntyDaySale       as integer
    field qntyDayGoods      as integer
    field ostatokGoods      as decimal
    field qntyDay           as integer
    field contract-prn-code as character
    field contract-code     as integer
    index pi    gds-code          contract-code
    index artic artic             prod-type         prod-code
    index contr contract-prn-code.
define new shared temp-table temp-gds-qnty no-undo
    field day      as date
    field ost      as decimal
    field gds-code as integer
    index pi is unique primary day gds-code
    index by-ost               ost .
define variable ii                  as integer   no-undo .
define variable kk                  as integer   no-undo .
define variable zakazDate           as date      no-undo .
define variable v-fact-order-start  as decimal   no-undo .
define variable v-fact-order-end    as decimal   no-undo .
define variable ostatok             as decimal   no-undo .
define variable v-full-path-RepView as character no-undo.
define variable v-file-name-rep-htm as character no-undo.
define variable g#report-num        as integer   no-undo.
define variable v-report-name       as character no-undo.
define variable v-period            as character no-undo.
define variable vDocType            as character no-undo .
define variable vDaySale            as integer   no-undo .
define variable vDateStart          as date      no-undo .
define variable vDateEnd            as date      no-undo .
define variable v-fact-orderStart   as decimal   no-undo .
define variable v-fact-orderEnd     as decimal   no-undo .
define variable periodDate          as date      no-undo .
define variable qntyPeriod          as integer   no-undo .
define variable periodDay           as integer   no-undo .
define stream OutStr-html.
define variable parameter-report as character no-undo .
define variable typeDocChoose    as character no-undo .
define variable dateZakaz        as character no-undo .
define buffer buf_goods           for ub.goods .
define buffer buf_clients         for ub.clients .
define buffer bf_clients          for ub.clients .
define buffer buf_contract-specif for ub.contract-specif .
define buffer buf_cli-gds         for ub.cli-gds .
define buffer buf_doc-line        for ub.doc-line .
define buffer buf_PromoGoogs      for ub.PromoGoods .
define buffer buf_PromoAction     for ub.PromoAction .
define buffer buf_stk-line        for ub.stk-line .
define buffer buf_trn-doc         for ub.trn-doc .
find first buf_clients no-lock where recid (buf_clients) = integer(pRecidClients) no-error .
function round-maxInt returns decimal
    (input p-dec as decimal) forward.
function round-maxDec returns decimal
    (input p-dec as decimal) forward.
function round-minInt returns decimal
    (input p-dec as decimal) forward.
function round-minDec returns decimal
    (input p-dec as decimal) forward.
function fnc-DD-MM-YYYY returns character
    (input p-dat-date as date) forward.
define variable qnty-lib-v-fact-order-2 as decimal no-undo .
define buffer buf_temp-gds-qnty for temp-gds-qnty .
find first tt-dateZakaz no-error .
if not available (tt-dateZakaz) then
do:
    create tt-dateZakaz .
    assign
        tt-dateZakaz.id        = 1
        tt-dateZakaz.dateStart = pDateStart
        tt-dateZakaz.dateEnd   = pDateEnd
        .
end.
case rDaySale:
    when 1 then
        vDaySale = 7 .
    when 2 then
        vDaySale = 14 .
    when 3 then
        vDaySale = 21 .
    when 4 then
        vDaySale = 28 .
    when 5 then
        vDaySale = pDaySale .
end.
for each tt-dateZakaz:
    qntyPeriod = qntyPeriod + 1 .
    if tt-dateZakaz.dateStart < vDateStart or vDateStart = ? then vDateStart = tt-dateZakaz.dateStart .
    if tt-dateZakaz.dateEnd > vDateEnd or vDateEnd = ? then vDateEnd = tt-dateZakaz.dateEnd .
end.
run day-begin-fact-order in this-procedure ( input vdateStart
    , output v-fact-orderStart
    ).
run factord-end-day in this-procedure ( input vdateEnd
    , output v-fact-orderEnd
    ).
for each gds-list:
    find first tt-zakaz no-lock where tt-zakaz.gds-code = gds-list.gds-code and tt-zakaz.contract-code = gds-list.contract-code no-error .
    if available (tt-zakaz) then next .
    create tt-zakaz .
    assign
        tt-zakaz.gds-code          = gds-list.gds-code
        tt-zakaz.artic             = gds-list.artic
        tt-zakaz.gds-name          = gds-list.gds-name
        tt-zakaz.prod-code         = gds-list.prod-code
        tt-zakaz.prod-type         = gds-list.prod-type
        tt-zakaz.garant-stock      = 0
        tt-zakaz.min-stock         = gds-list.minZapas
        tt-zakaz.ostatokDay        = 0
        tt-zakaz.ostatokGoods      = 0
        tt-zakaz.rest              = 0
        tt-zakaz.qntyDay           = qntyPeriod
        tt-zakaz.qntyDaySale       = 0
        tt-zakaz.average-sales     = 0
        tt-zakaz.order-qnty        = 0
        tt-zakaz.volMinZapas       = 0
        tt-zakaz.sales             = 0
        tt-zakaz.volume-goods      = 0
        tt-zakaz.contract-prn-code = gds-list.contract
        tt-zakaz.contract-code     = gds-list.contract-code
        .
    for each buf_cli-gds no-lock where buf_cli-gds.artic = gds-list.artic and
        buf_cli-gds.prod-code = gds-list.prod-code and
        buf_cli-gds.prod-type = gds-list.prod-type:
        tt-zakaz.rest = tt-zakaz.rest + buf_cli-gds.supp-qnty .
    end.
    empty temp-table temp-gds-qnty .
    if pDelDayGoods then run ost-gds-day(vDateStart, vDateEnd, gds-list.gds-code, v-cntxt-obj-type, v-cntxt-obj-code, tt-zakaz.rest) .
    for each tt-dateZakaz:
        run day-begin-fact-order in this-procedure ( input tt-dateZakaz.dateStart
            , output v-fact-order-start
            ).
        run factord-end-day in this-procedure ( input tt-dateZakaz.dateEnd
            , output v-fact-order-end
            ).
        if pDelDayGoods then
        do:
            for each buf_temp-gds-qnty where buf_temp-gds-qnty.gds-code = gds-list.gds-code and
                buf_temp-gds-qnty.ost > 0 and
                buf_temp-gds-qnty.day >= tt-dateZakaz.dateStart and
                buf_temp-gds-qnty.day <= tt-dateZakaz.dateEnd:
                tt-zakaz.qntyDayGoods = tt-zakaz.qntyDayGoods + 1 .
            end.
        end.
        else tt-zakaz.qntyDayGoods = tt-dateZakaz.dateEnd - tt-dateZakaz.dateStart + 1.
        for each tt-typeDocChoose:
            for each buf_doc-line no-lock
                where
                buf_doc-line.ext-doc-type = tt-typeDocChoose.type-code and
                buf_doc-line.obj-code = v-cntxt-obj-code and
                buf_doc-line.obj-type = v-cntxt-obj-type and
                buf_doc-line.artic = gds-list.artic and
                buf_doc-line.prod-code = gds-list.prod-code and
                buf_doc-line.prod-type = gds-list.prod-type and
                buf_doc-line.fact-order >= v-fact-order-start and
                buf_doc-line.fact-order <= v-fact-order-end :
                tt-zakaz.qntyDaySale = tt-zakaz.qntyDaySale + 1 .
                case tt-typeDocChoose.type-code:
                    when   'ie':U  or
                    when   'im':U     then
                        do:
                            tt-zakaz.sales = tt-zakaz.sales + buf_doc-line.fact-qnty .
                        end.
                    when  'we':U      then
                        tt-zakaz.sales = tt-zakaz.sales + buf_doc-line.fact-qnty .
                    when  'wm':U       then
                        tt-zakaz.sales = tt-zakaz.sales + buf_doc-line.fact-qnty .
                    when  'em':U       then
                        tt-zakaz.sales = tt-zakaz.sales + buf_doc-line.fact-qnty .
                    when  'ev':U      then
                        tt-zakaz.sales = tt-zakaz.sales + buf_doc-line.fact-qnty .
                    when  'rv':U  then
                        tt-zakaz.sales = tt-zakaz.sales - buf_doc-line.fact-qnty .
                    when  'ee':U      then
                        tt-zakaz.sales = tt-zakaz.sales + buf_doc-line.fact-qnty .
                    when  're':U  then
                        tt-zakaz.sales = tt-zakaz.sales - buf_doc-line.fact-qnty .
                    when  'es':U     then
                        tt-zakaz.sales = tt-zakaz.sales + buf_doc-line.fact-qnty .
                    when  'rs':U then
                        tt-zakaz.sales = tt-zakaz.sales - buf_doc-line.fact-qnty .
                    when  'we':U then
                        tt-zakaz.sales = tt-zakaz.sales - buf_doc-line.fact-qnty .
                end case.
            end.
        end.
    end.
    if tt-zakaz.qntyDayGoods <> 0 then tt-zakaz.average-sales = round-maxDec(tt-zakaz.sales / tt-zakaz.qntyDayGoods) .
    if tt-zakaz.qntyDayGoods <> 0 then
    do:
        if tt-zakaz.rest > -1 then
        do:
            tt-zakaz.ostatokDay = tt-zakaz.rest - ((integer(pDateOrder - date(today)) * tt-zakaz.average-sales)) .
            if tt-zakaz.ostatokDay < 0 then tt-zakaz.volume-goods = round-maxInt(tt-zakaz.average-sales * vDaySale).
            else tt-zakaz.volume-goods = round-maxInt(tt-zakaz.average-sales * vDaySale - tt-zakaz.ostatokDay) .
        end.
        else tt-zakaz.volume-goods = round-maxInt(tt-zakaz.average-sales * vDaySale - tt-zakaz.rest).
        if tt-zakaz.qntyDaySale <> 0 then
        do:
            tt-zakaz.volMinZapas = round-maxInt(tt-zakaz.volume-goods + tt-zakaz.min-stock) .
            tt-zakaz.garant-stock = round-maxInt(pGarantDay * tt-zakaz.average-sales) .
            tt-zakaz.order-qnty = round-maxInt(tt-zakaz.volume-goods + tt-zakaz.min-stock + tt-zakaz.garant-stock) .
            if tt-zakaz.average-sales <> 0 then tt-zakaz.ostatokGoods = round-minInt(tt-zakaz.rest / tt-zakaz.average-sales) .
        end.
        else tt-zakaz.volume-goods = 0 .
    end.
    for each buf_PromoGoogs no-lock where buf_PromoGoogs.gds-code = gds-list.gds-code,
        first buf_PromoAction no-lock where buf_PromoAction.id = buf_PromoGoogs.idAction and
        buf_PromoAction.end-date >= today and buf_PromoAction.beg-date <= today and buf_PromoAction.Status_ = 1:
        tt-zakaz.promo = true .
    end.
end.
for each tt-dateZakaz:
    periodDay = periodDay + (tt-dateZakaz.dateEnd - tt-dateZakaz.dateStart + 1) .
    v-period = v-period + ", " + "c " + string(tt-dateZakaz.dateStart,"99/99/9999") + " по " + string (tt-dateZakaz.dateEnd,"99/99/9999") .
end.
v-period = trim (v-period,", ") .
if not p-ok then do:
run get-full-path-RepViewer(output v-full-path-RepView).
run get-report-num in parParentProc(output g#report-num).
run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).
run create-file(v-file-name-rep-htm).
run waitfram-show in this-procedure ("Подождите ...").
output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' .
put stream OutStr-html unformatted
    "<!DOCTYPE HTML>" skip
    ' <html>' skip
    '  <head>' skip
    '   <meta charset="utf-8">' skip
    '    <style type="text/css">' skip
    '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
    '   </style>' skip
    '  </head>' skip
    .
put stream OutStr-html unformatted
    '<body>' skip
    '<TABLE name="zakaz"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
    .
put stream OutStr-html unformatted
    '<tr class="set_columns">' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 200px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '</tr>' skip
    .
find first bf_clients no-lock where bf_clients.obj-code = v-cntxt-obj-code and
    bf_clients.obj-type = v-cntxt-obj-type no-error .
put stream OutStr-html unformatted
    '<tr style="font-size:11px;">' skip
    '<td colspan="13" style="text-align: left; font-weight:bold;">Отчет по планированию заказа товаров Магазина и готовой продукции Кафе</td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;">на ' + string(pDateOrder,"99/99/9999") + '</td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Остаток товара, шт (О)</b> Количество товара на остатке в штуках на текущий момент (4).</td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;">объект: ' + bf_clients.obj-name + '</td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Продажи за период, шт (Vпр)</b> Количество продаж товара (с учетом возвратов) за выбранный период (5).</td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;">контрагент: ' + buf_clients.obj-name + '</td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Среднесуточные продажи за период, шт (Тпр)</b> Среднесуточное количество проданного товара за выбранный период времени Тпр = Vпр / P, где Р – период продаж в днях (6).</td>' skip
    '</tr>' skip
    .
for each tt-typeDocChoose:
    vDocType = vDocType + ", " + tt-typeDocChoose.typeName .
end.
vDocType = trim (vDocType,", ") .
put stream OutStr-html unformatted
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;">заказ формируется на : ' + string(vDaySale) + ' дней(дня), с учетом гарантийного запаса на ' + string(pGarantDay) + ' дней(дня)</td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Рекомендованный объем заказа с учетом минимального и гарантийного запасов, шт (Vзг)</b> Vзг = Vз + М + G  (7).</td>' skip
    '</tr>' skip .
put stream OutStr-html unformatted
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;">период анализа : ' + string(periodDay) + ' дней(дня) ' + v-period + '</td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Запас товара, в днях (Од)</b> Количество дней, на которое должно хватить остатков товара на текущий момент с учетом среднесуточных продаж за период Од = О / Тпр (8).</td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    .
if pDelDayGoods then
do:
    put stream OutStr-html unformatted
        '<td colspan="5" text_wrap="true" style="text-align: left;">исключены дни, когда товара не было на остатках</td>' skip
        .
end.
else
do:
    put stream OutStr-html unformatted
        '<td colspan="5" style="text-align: left;"></td>' skip
        .
end.
put stream OutStr-html unformatted
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Расчетный объем заказа с учетом темпа продаж, шт (Vз)</b> Vз = Тпр * Q - Ост, где Q – период, на который формируется заказ в днях,</td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;">если Ост < 0, то при расчете Ост не учитывается. Ост – Остаток товара на день заказа: Ост = О - (Dз-D) * Тпр, где Dз – дата заказа, D – текущая дата (9).</td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><strong>Расчетный объем заказа с учетом минимального запаса,шт (Vзм)</strong> Vзм = Vз + М  (10).</td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Минимальный запас, шт (М)</b> Количество товара, необходимое для выкладки (11). </td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Гарантийный запас, шт (G)</b> G = S * Тпр, где   S – гарантийный запас в днях (12).</td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Товар участвует в промоакции</b> Участие товара в промоакции в статусе «Активная» в ТН на момент формирования отчета. </td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;">Информация справочная, необходимо учитывать при подтверждении заказа (13).</td>' skip
    '</tr>' skip
    '<tr height:15px;  style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left;"></td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>* При расчете не учитываются сроки годности и движение рецептурных товаров</b></td>' skip
    '</tr>' skip
    .
put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" text_wrap="true" style="text-align: left; font-weight:bold;"><br></td>' skip
    '</tr>' skip
    '<tr>' skip
    '<td colspan="10" text_wrap="true" style="text-align: left; font-weight:bold;"><br></td>' skip
    '</tr>' skip
    '</thead>' skip
    .
put stream OutStr-html unformatted
    '     <tbody>' skip
    '       <tr style="font-size:11px;">' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver; height: 30px">Код ТН</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Артикул ТН</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Наименование товара</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Остаток товара, шт.<br>(О)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Продажи за период, шт.<br>(Vпр)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Среднесуточные продажи за период, шт.<br>(Тпр)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; font-size:12px; background-color: silver;">Рекомендованный объем заказа с учетом минимального и гарантийного запасов, шт.<br>(Vзг)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Запас товара, в днях<br>(Од)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Расчетный объем заказа с учетом темпа продаж, шт.<br>(Vз)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Расчетный объем заказа с учетом минимального запаса, шт.<br>(Vзм)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Минимальный запас, шт.<br>(М)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Гарантийный запас, шт.<br>(G)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Товар участвует в промоакции</th>' skip
    '       </tr>' skip
    '       <tr style="font-size:11px;">' skip
    '         <th style="text-align: center;  font-weight:bold; background-color: silver;"></th>' skip
    '         <th style="text-align: center;  font-weight:bold; background-color: silver;"></th>' skip
    '         <th style="text-align: center;  font-weight:bold; background-color: silver;"></th>' skip
    '         <th colspan="3" style="text-align: center;  font-weight:bold; background-color: silver;">ФАКТИЧЕСКИЕ ДАННЫЕ</th>' skip
    '         <th style="text-align: center;  font-weight:bold; background-color: silver;">ЗАКАЗ</th>' skip
    '         <th colspan="6" style="text-align: center;  font-weight:bold; background-color: silver;">СПРАВОЧНАЯ ИНФОРМАЦИЯ</th>' skip
    '       </tr>' skip
    '       <tr style="font-size:11px;">' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">2</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">3</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">4</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">5</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">6</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">7</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">8</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">9</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">10</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">11</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">12</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">13</th>' skip
    '       </tr>' skip
    .
for each tt-zakaz no-lock break by tt-zakaz.contract-code by tt-zakaz.gds-code:
    put stream OutStr-html unformatted
        '     <tbody>' skip
        .
    if first-of (tt-zakaz.contract-code) then
    do:
        put stream OutStr-html unformatted
            '<tr style="font-size:11px;">' skip
            '<td colspan="13" style="text-align: left; font-weight:bold;"><br>' + if tt-zakaz.contract-prn-code = "" then '   БЕЗ ДОГОВОРА</td>' else '   ' + tt-zakaz.contract-prn-code + '<br></td>' skip
            '</tr>' skip
            .
    end.
    if tt-zakaz.qntyDayGoods = 0 or tt-zakaz.qntyDaySale = 0 then
    do:
        put stream OutStr-html unformatted
            '       <tr style="font-size:11px;">' skip
            '         <td text_wrap="true" style="text-align: center;">' + string(tt-zakaz.gds-code) + '</td>' skip
            '         <td text_wrap="true" style="text-align: center;">' + string(tt-zakaz.artic) + '</td>' skip
            '         <td text_wrap="true" style="text-align: center;">' + string(tt-zakaz.gds-name) + '</td>' skip
            '         <td text_wrap="true" num="0" val="' + fnc-convert-dot-to-colon(tt-zakaz.rest,"->>>>>>>>>>>>>9",0) + '"  style="text-align: center;">' + fnc-convert-dot-to-colon(tt-zakaz.rest,"->>>>>>>>>>>9",0) + '</td>' skip
            '         <td text_wrap="true" num="0" val="' + fnc-convert-dot-to-colon(tt-zakaz.sales,"->>>>>>>>>>>>>9",0) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-zakaz.sales,"->>>>>>>>>>>>>9",0) + '</td>' skip
            '         <td text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(tt-zakaz.average-sales,"->>>>>>>>>>>>>9.9",1) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-zakaz.average-sales,"->>>>>>>>>>>>>9.9",1) + '</TD>' skip
            '         <td text_wrap="true" style="text-align: center; font-weight:bold; font-size:12px;">' + string(tt-zakaz.order-qnty) + '</td>' skip
            '         <td text_wrap="true" style="text-align: center;">' + if tt-zakaz.average-sales = 0 and tt-zakaz.ostatokDay <> 0 then "-" + '</td>' else string(tt-zakaz.ostatokGoods) + '</td>' skip
            '         <td text_wrap="true" style="text-align: center;">' + string(tt-zakaz.volume-goods) + '</td>' skip
            '         <td text_wrap="true" style="text-align: center;">' + if tt-zakaz.min-stock > tt-zakaz.rest then string(tt-zakaz.min-stock) + '</td>' else string(tt-zakaz.volMinZapas) + '</td>' skip
            '         <td text_wrap="true" style="text-align: center;">' + string(tt-zakaz.min-stock) + '</td>' skip
            '         <td text_wrap="true" style="text-align: center;">' + string(tt-zakaz.garant-stock) + '</td>' skip
            '         <td text_wrap="true" style="text-align: center;">' + (if tt-zakaz.promo then "да" else "нет") + '</td>' skip
            '       </tr>' skip
            .
    end.
    else
    do:
        put stream OutStr-html unformatted
            '       <tr style="font-size:11px;">' skip
            '         <td text_wrap="true" style="text-align: center;">' + string(tt-zakaz.gds-code) + '</td>' skip
            '         <td text_wrap="true" style="text-align: center;">' + string(tt-zakaz.artic) + '</td>' skip
            '         <td text_wrap="true" style="text-align: center;">' + string(tt-zakaz.gds-name) + '</td>' skip
            '         <td text_wrap="true" num="0" val="' + fnc-convert-dot-to-colon(tt-zakaz.rest,"->>>>>>>>>>>>>9",0) + '"  style="text-align: center;">' + fnc-convert-dot-to-colon(tt-zakaz.rest,"->>>>>>>>>>>9",0) + '</td>' skip
            '         <td text_wrap="true" num="0" val="' + fnc-convert-dot-to-colon(tt-zakaz.sales,"->>>>>>>>>>>>>9.",0) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-zakaz.sales,"->>>>>>>>>>>>>9",0) + '</td>' skip
            '         <td text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(tt-zakaz.average-sales,"->>>>>>>>>>>>>9.9",1) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-zakaz.average-sales,"->>>>>>>>>>>>>9.9",1) + '</TD>' skip
            '         <td text_wrap="true" style="text-align: center; font-weight:bold; font-size:12px;">' + string(tt-zakaz.order-qnty) + '</td>' skip
            '         <td text_wrap="true" style="text-align: center;">' + string(tt-zakaz.ostatokGoods) + '</td>' skip
            '         <td text_wrap="true" style="text-align: center;">' + string(tt-zakaz.volume-goods) + '</td>' skip
            '         <td text_wrap="true" style="text-align: center;">' + string(tt-zakaz.volMinZapas) + '</td>' skip
            '         <td text_wrap="true" style="text-align: center;">' + string(tt-zakaz.min-stock) + '</td>' skip
            '         <td text_wrap="true" style="text-align: center;">' + string(tt-zakaz.garant-stock) + '</td>' skip
            '         <td text_wrap="true" style="text-align: center;">' + (if tt-zakaz.promo then "да" else "нет") + '</td>' skip
            '       </tr>' skip
            .
    end.
end.
end.
for each tt-typeDocChoose:
    if typeDocChoose = "" then typeDocChoose = string(tt-typeDocChoose.type-code) .
    else typeDocChoose = typeDocChoose + chr(7) + string(tt-typeDocChoose.type-code) .
end.
for each tt-dateZakaz:
    if dateZakaz = "" then dateZakaz = string(tt-dateZakaz.dateStart) + chr(8) + string(tt-dateZakaz.dateEnd) .
    else dateZakaz = dateZakaz + chr(7) + string(tt-dateZakaz.dateStart) + chr(8) + string(tt-dateZakaz.dateEnd) .
end.
parameter-report = string(pDateOrder) + chr(4) +
    string(rPeriodZakaz) + chr(4) +
    string(vDaySale) + chr(4) +
    string(pGarantDay) + chr(4) +
    string(pDelDayGoods) + chr(4) +
    typeDocChoose + chr(4) +
    dateZakaz + chr(4) +
    string(periodDay) + chr(4) +
    string(v-period) .
.
if p-ok then run rep/crt-order.p (parparentproc, pDateOrder, buf_clients.obj-type, buf_clients.obj-code, parameter-report) .
if not p-ok then
do:
    run prn-lib-reportviewer-report-name in this-procedure (
        input THIS-PROCEDURE
        ,input v-file-name-rep-htm
        ).
end.
procedure get-full-path-RepViewer:
    define output parameter p-fill-path-RepView as character no-undo.
    if search("exe\ReportViewer\reportviewer.exe") <> ? then
    do:
        p-fill-path-RepView = search("exe\ReportViewer\reportviewer.exe").
    end.
    else
    do:
        message "Не найдена программа просмотра отчёта!" view-as alert-box error.
    end.
end procedure.
procedure define-full-path-Report:
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.
    p-file-name-rep-htm = session:temp-directory + "rpt" + string(p-rep-num) + ".html".
end procedure.
procedure search-full-path-Report:
    define input parameter p-file-name as character no-undo.
    if search(p-file-name) = ? then
    do:
        message "Не найден файл отчёта: " p-file-name view-as alert-box error.
    end.
    else
    do:
        p-file-name = search(p-file-name).
    end.
end procedure.
procedure Report-Viewer:
    define input parameter p-full-path-RepView as character no-undo.
    define input parameter p-file-name-rep-htm as character no-undo.
    os-command no-wait value(p-full-path-RepView + " " + search(p-file-name-rep-htm)).
end procedure.
procedure create-file:
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.
end procedure.
function round-maxInt returns decimal
    (input p-dec as decimal):
    define variable p-int as decimal no-undo .
    if absolute(p-dec - TRUNCATE (p-dec, 0)) < 0.5
        then
    do:
        if p-dec > 0 then p-int = integer (p-dec + 0.4) .
        else p-int = integer(p-dec) .
    end .
    else
    do:
        if p-dec < 0 then p-int = integer (p-dec + 0.4) .
        else p-int = integer(p-dec) .
    end.
    return p-int .
end function.
function round-minInt returns decimal
    (input p-dec as decimal):
    define variable p-int as decimal no-undo .
    if absolute(p-dec - TRUNCATE (p-dec, 0)) > 0.5
        then
    do:
        if p-dec > 0 then p-int = integer (p-dec - 0.4) .
        else p-int = integer(p-dec) .
    end .
    else
    do:
        if p-dec < 0 then p-int = integer (p-dec - 0.4) .
        else p-int = integer(p-dec) .
    end.
    return p-int .
end function.
function round-maxDec returns decimal
    (input p-dec as decimal):
    define variable p-int as decimal no-undo .
    if p-dec - TRUNCATE (p-dec, 1) > 0
        then
    do:
        if TRUNCATE (p-dec, 1) = 0 then p-int = TRUNCATE (p-dec, 1) .
        else p-int = TRUNCATE (p-dec, 1) + 0.1 .
    end.
    else
    do:
        if p-dec - TRUNCATE (p-dec, 1) > 0
            then
        do:
            p-int = TRUNCATE (p-dec, 1) - 0.1.
        end.
        else
        do:
            assign
                p-int = TRUNCATE (p-dec, 1) .
            .
        end.
    end.
    return p-int .
end function.
function round-minDec returns decimal
    (input p-dec as decimal):
    define variable p-int as decimal no-undo .
    if p-dec - TRUNCATE (p-dec, 1) < 0
        then
    do:
        if TRUNCATE (p-dec, 1) = 0 then p-int = TRUNCATE (p-dec, 1) .
        else p-int = TRUNCATE (p-dec, 1) - 0.1 .
    end.
    else
    do:
        if p-dec - TRUNCATE (p-dec, 1) > 0
            then
        do:
            p-int = TRUNCATE (p-dec, 1) - 0.1.
        end.
        else
        do:
            assign
                p-int = p-dec
                .
        end.
    end.
    return p-int .
end function.
function fnc-DD-MM-YYYY returns character
    (input p-dat-date as date):
    define variable result     as character no-undo.
    define variable p-str-date as character no-undo.
    p-str-date = replace(string(p-dat-date,'99.99.9999'), "/", ".").
    return p-str-date.
end function.
procedure ost-gds-day :
    do
        on error undo, return error return-value
        :
        define input parameter p-dateStart as date no-undo .
        define input parameter p-dateEnd as date no-undo .
        define input parameter p-gds-code like ub.goods.gds-code no-undo .
        define input parameter p-obj-type as character no-undo .
        define input parameter p-obj-code as integer no-undo .
        define input parameter p-ost-today as decimal no-undo .
        define variable vOst as decimal no-undo .
        define buffer p_goods     for ub.goods .
        define buffer p-doc-line  for ub.doc-line .
        define buffer pc-gds-obj  for ub.c-gds-obj .
        define buffer pc-gds-obj2 for ub.c-gds-obj .
        find first p_goods no-lock where p_goods.gds-code = p-gds-code no-error .
        if error-status :error then return error .
        do periodDate = vDateStart to vDateEnd:
            create temp-gds-qnty .
            assign
                temp-gds-qnty.day      = periodDate
                temp-gds-qnty.gds-code = p_goods.gds-code
                .
            find first pc-gds-obj no-lock where pc-gds-obj.gds-code = p_goods.gds-code and
                pc-gds-obj.obj-code = p-obj-code and
                pc-gds-obj.obj-type = p-obj-type and
                pc-gds-obj.corr-date = periodDate no-error .
            if not available (pc-gds-obj) then
            do:
                find last pc-gds-obj2 no-lock where pc-gds-obj2.gds-code = p_goods.gds-code and
                    pc-gds-obj2.obj-code = p-obj-code and
                    pc-gds-obj2.obj-type = p-obj-type and
                    pc-gds-obj2.corr-date < periodDate no-error .
                if available (pc-gds-obj2) then temp-gds-qnty.ost = pc-gds-obj2.fact-qnty .
            end.
            else temp-gds-qnty.ost = pc-gds-obj.fact-qnty .
        end.
    end.
end procedure.
