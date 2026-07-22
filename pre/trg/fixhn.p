block-level on error undo, throw.
define input parameter p-forced as logical no-undo .
define input parameter p-read-only as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Приведение в соответствие с БД опций истории и маршрутизации".
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
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable attach-list as character no-undo initial '~
abc-analysis-attr~
,abc-analysis-doc~
,abc-analysis-gds-obj~
,abc-analysis-gds-obj-attr~
,abc-analysis-goods~
,abc-analysis-goods-attr~
,abc-analysis-grp~
,abc-analysis-obj~
,abc-analysis-period~
,abc-analysis-prod~
,abcxyz-analysis-attr~
,abcxyz-analysis-goods~
,abcxyz-analysis-goods-attr~
,add-line~
,add-trn~
,add-trn-attr~
,arh-trn-doc-contract~
,c-buyer-in-buyer-group~
,c-buyer-group~
,c-pl-gds-obj~
,c-sht-hist~
,cd-doc-line~
,c-cd-doc-line~
,chk-discnt~
,chk-discnt-attr~
,c-chk-discnt~
,chk-doc~
,chk-doc-attr~
,c-chk-doc-attr~
,chk-gds~
,chk-gds-attr~
,marking-chk~
,c-marking-chk~
,c-marking-attr~
,c-chk-gds~
,chk-pay~
,chk-gds-attr~
,chk-pay-attr~
,c-chk-pay~
,contract-line~
,contract-specif-attr~
,c-contract-line~
,db-grp-obj-price~
,c-db-grp-obj-price~
,doc-abc-def-doc~
,doc-abc-def-obj~
,c-doc-attr~
,doc-fbr-gds~
,c-doc-fbr-gds~
,doc-line~
,c-doc-line~
,doc-line-attr~
,c-doc-line-attr~
,doc-line-sum~
,c-doc-line-sum~
,doc-pl~
,c-doc-pl~
,doc-pl-pump~
,c-doc-pl-pump~
,doc-prts~
,c-doc-prts~
,doc-xyz-def-doc~
,doc-xyz-def-obj~
,esys-route-dump~
,factur-connect-line~
,fbr-line~
,c-fbr-line~
,fbr-pln-line~
,c-fbr-pln-line~
,c-fin-code-an-uchet~
,c-fin-code-cel-nazn~
,c-fin-code-cor-acc~
,fin-doc-attr~
,c-fin-doc-attr~
,fin-doc-tax~
,c-fin-doc-tax~
,fin-gds-part~
,c-fin-gds-part~
,fin-ob-attr~
,c-fin-ob-attr~
,fin-ob-tax~
,c-fin-ob-tax~
,fin-ob-tax-before~
,fin-ob-trn~
,fin-statement-attr~
,c-fin-statement-attr~
,fin-statement-line~
,c-fin-statement-line~
,gds-dtl~
,c-gds-dtl~
,c-global-state~
,global-state-attr~
,c-global-state-attr~
,host-grp-obj-price~
,c-host-grp-obj-price~
,icnt-line~
,inkas-pay~
,c-inkas-pay~
,inkas-pay-desk~
,c-inkas-pay-desk~
,inkas-pay-wth~
,c-inkas-pay-wth~
,inv-doc~
,inv-line~
,c-inv-line~
,layout-elem-rule~
,obj-grp-obj-price~
,c-obj-grp-obj-price~
,ord-cons-attr~
,ord-cons-line-attr~
,ord-doc-attr~
,c-ord-doc-attr~
,ord-dtl~
,c-ord-dtl~
,ord-dtl-cons~
,ord-dtl-rcv~
,ord-gds-cons~
,ord-line~
,c-ord-line~
,ord-line-attr~
,c-ord-line-attr~
,ord-line-rcv~
,ord-rcv-attr~
,ord-rcv-line-attr~
,c-parts~
,c-parts-attr~
,parts-root~
,c-parts-root~
,esys-pck-keys~
,c-price-doc-forming~
,price-doc-forming-attr~
,c-price-doc-forming-attr~
,price-doc-forming-gds~
,c-price-doc-forming-gds~
,price-doc-forming-gdsattr~
,c-price-doc-forming-gdsattr~
,price-doc-forming-gds-qnty~
,c-price-doc-forming-gds-qnty~
,price-doc-forming-gds-sum~
,c-price-doc-forming-gds-sum~
,price-doc-forming-gds-tnv~
,c-price-doc-forming-gds-tnv~
,price-list~
,c-price-list~
,price-list-attr~
,c-price-list-attr~
,price-list-type-attr~
,c-price-list-type-attr~
,price-list-type-cash-pay~
,c-price-list-type-cash-pay~
,price-list-type-cassa~
,c-price-list-type-cassa~
,price-list-type-gds-grp~
,c-price-list-type-gds-grp~
,price-list-type-pay-type~
,c-price-list-type-pay-type~
,c-qnty-group~
,qnty-in-qnty-group~
,c-qnty-in-qnty-group~
,rang-abc-def-obj~
,rang-xyz-def-obj~
,rule-i-script~
,rule-script~
,rule-trans-memo~
,rvs-line~
,rvs-line-attr~
,c-rvs-line~
,rvs-line-pump~
,c-rvs-line-pump~
,rvs-pump~
,sale-doc~
,c-sale-doc~
,schet-fact-line~
,c-schet-fact-line~
,shift-cash~
,c-shift-obj~
,shift-staff~
,c-shift-staff~
,shift-attr~
,c-shift-attr~
,stop-list-line~
,c-sum-group~
,sum-in-sum-group~
,c-sum-in-sum-group~
,c-turnover-group~
,tnv-in-turnover-group~
,c-tnv-in-turnover-group~
,trn-doc-sum~
,c-trn-doc-sum~
,c-trn-reason~
,trn-reason-host~
,c-trn-reason-host~
,trn-reason-obj~
,c-trn-reason-obj~
,trn-rsn-attr~
,c-trn-rsn-attr~
,turnover-buyer~
,turnover-buyer-attr~
,turnover-buyer-gds~
,turnover-buyer-gds-attr~
,wi-mode~
,wth-dtl~
,c-wth-dtl~
,wth-line~
,c-wth-line~
,wth-parts~
,c-wth-parts~
,xyz-analysis-attr~
,xyz-analysis-doc~
,xyz-analysis-gds-obj~
,xyz-analysis-gds-obj-attr~
,xyz-analysis-goods~
,xyz-analysis-goods-attr~
,xyz-analysis-obj~
,xyz-analysis-period~
,utd-lines~
,utd-marking-lines~
,utd-err~
,utd-attr~
,utd-lines-attr~
,utd-marking-lines-attr~
,utd-err-attr~
,marking~
,marking-lines~
,order-doc~
,order-line~
,reportShift~
,shift-param~
,susp-chk~
':U .
define variable news-list as character no-undo initial '~
abc-analysis~
,abcxyz-analysis~
,add-doc~
,action-post~
,action-post-host~
,action-post-menu-group~
,action-post-obj~
,action-post-role~
,action-post-user-login~
,action-role~
,c-action-role~
,action-role-item~
,c-action-role-item~
,action-role-item-gds~
,action-role-item-gds-grp~
,alc-sale-lic~
,c-alc-sale-lic~
,alc-sale-lic-attr~
,c-alc-sale-lic-attr~
,alc-sale-lic-type~
,c-alc-sale-lic-type~
,alc-supp-lic~
,c-alc-supp-lic~
,alc-supp-lic-attr~
,c-alc-supp-lic-attr~
,alc-supp-lic-type~
,c-alc-supp-lic-type~
,alc-type~
,c-alc-type~
,alc-type-attr~
,c-alc-type-attr~
,alc-type-gds~
,c-alc-type-gds~
,arh-fin-doc-an~
,arh-fin-doc-an-nal~
,arh-fin-doc-c-schet-tax-nal~
,arh-fin-doc-contr-schet~
,arh-fin-doc-contr-schet-nal~
,arh-fin-doc-contr-schet-tax~
,arh-fin-doc-schet~
,arh-fin-doc-schet-nal~
,arh-fin-doc-schet-tax~
,arh-fin-doc-schet-tax-nal~
,arh-fin-doc-contr-schet-obj~
,arh-fin-doc-contr-s-nal-obj~
,arh-fin-doc-contr-s-tax-obj~
,arh-fin-doc-c-s-tax-nal-obj~
,arh-fin-doc-schet-obj~
,arh-fin-doc-schet-nal-obj~
,arh-fin-ob-contr~
,attr-prop~
,auto-tank~
,c-auto-tank~
,auto-tank-meas~
,auto-tank-attr~
,auto-section~
,c-auto-section~
,auto-section-attr~
,c-auto-section-attr~
,auto-section-table~
,c-auto-section-table~
,bar-code~
,c-bar-code~
,bar-code-attr~
,c-bar-code-attr~
,bar-code-obj-attr~
,c-bar-code-obj-attr~
,blob-bind~
,buyer-group~
,buyer-in-buyer-group~
,c-cli-hist~
,c-dc-hist~
,c-fbr-gds-grp-hist~
,c-gds-grp-hist~
,c-gds-hist~
,c-nzl-hist~
,c-plc-hist~
,c-pmp-hist~
,c-recipe-hist~
,c-table-bind~
,c-tax-hist~
,c-usr-hist~
,c-wth-hist~
,cash-desk~
,c-cash-desk~
,cash-desk-attr~
,c-cash-desk-attr~
,cash-pay~
,c-cash-pay~
,cash-pay-attr~
,c-cash-pay-attr~
,cd-clu~
,c-cd-clu~
,cd-dlu~
,c-cd-dlu~
,cd-doc~
,c-cd-doc~
,cd-events~
,cd-events-attr~
,cd-event-log~
,cd-event-log-attr~
,cd-grp~
,c-cd-grp~
,cd-plu~
,c-cd-plu~
,c-chk-doc~
,cd-trans~
,cd-video-link~
,cd-video-link-attr~
,cli-art~
,cli-gds~
,cli-grp~
,c-cli-grp~
,clients~
,c-clients~
,clients-attr~
,c-clients-attr~
,clob-bind~
,code-range~
,condition-keeping~
,c-condition-keeping~
,config~
,c-config~
,contract~
,c-contract~
,contract-attr~
,contract-specif~
,c-contract-specif~
,country~
,c-country~
,criterion-analysis~
,cshr-month~
,curr-accnt~
,c-curr-accnt~
,curr-bank~
,c-curr-bank~
,curr-shop~
,currency~
,custom-labels~
,datatype-exp~
,datatype-exp-attr~
,datatype-imp~
,datatype-imp-attr~
,datatype-table~
,datatype-table-exp~
,datatype-table-field~
,datatype-table-field-exp~
,datatype-table-field-imp~
,datatype-table-imp~
,db~
,c-db~
,db-attr~
,db-info~
,db-status~
,deliv-type-cond-keep~
,c-deliv-type-cond-keep~
,delivery-subject~
,c-delivery-subject~
,delivery-type~
,c-delivery-type~
,delivery-type-subject~
,c-delivery-type-subject~
,dis-card~
,c-dis-card~
,dis-card-long~
,c-dis-card-long~
,dis-card-mask~
,c-dis-card-mask~
,dis-card-mask-attr~
,c-dis-card-mask-attr~
,dis-card-property~
,c-dis-card-property~
,dis-card-type~
,c-dis-card-type~
,dis-card-type-attr~
,c-dis-card-type-attr~
,dis-cfg-rule~
,c-dis-cfg-rule~
,dis-cp-rule~
,c-dis-cp-rule~
,dis-dc-rule~
,c-dis-dc-rule~
,dis-dct-rule~
,c-dis-dct-rule~
,dis-gds-rule~
,c-dis-gds-rule~
,dis-gds-rule-attr~
,dis-grp-rule~
,c-dis-grp-rule~
,dis-host~
,c-dis-host~
,dis-obj~
,c-dis-obj~
,dis-rule~
,c-dis-rule~
,dis-some-rule~
,c-dis-some-rule~
,dis-thbj-rule~
,c-dis-thbj-rule~
,dis-time-rule~
,c-dis-time-rule~
,doc-abc-def~
,doc-attr~
,doc-xyz-def~
,drt-prop~
,c-drt-prop~
,edi-status~
,esys-all-attr~
,esys-datatype-exp~
,c-esys-datatype-exp~
,esys-datatype-imp~
,c-esys-datatype-imp~
,esys-pck-rcvd~
,esys-pck-rcvd-err~
,esys-pck-sent~
,esys-route~
,ex-mark~
,c-ex-mark~
,ext-artic~
,c-ext-artic~
,ext-artic-attr~
,c-ext-artic-attr~
,ext-classif~
,c-ext-classif~
,ext-file~
,ext-file-line~
,ext-file-par~
,ext-system~
,c-ext-system~
,ext-system-attr~
,factur-connect~
,fbr-doc~
,c-fbr-doc~
,fbr-gds-grp~
,c-fbr-gds-grp~
,fbr-gds-grp-attr~
,c-fbr-gds-grp-attr~
,fbr-gds-obj~
,c-fbr-gds-obj~
,fbr-history~
,fbr-pln~
,c-fbr-pln~
,fbr-prn~
,c-fbr-prn~
,fbr-prn-gds~
,c-fbr-prn-gds~
,fbr-prn-grp~
,c-fbr-prn-grp~
,fbr-recipe~
,fbr-recipe-gds~
,fin-bank~
,c-fin-bank~
,fin-code-an-uchet~
,fin-code-cel-nazn~
,fin-code-cor-acc~
,fin-connect~
,fin-doc~
,c-fin-doc~
,fin-ob~
,c-fin-ob~
,fin-ob-before~
,fin-schet~
,c-fin-schet~
,fin-statement~
,c-fin-statement~
,firm~
,c-firm~
,gds-grp~
,c-gds-grp~
,gds-grp-attr~
,c-gds-grp-attr~
,gds-grp-obj~
,c-gds-grp-obj~
,gds-host-attr~
,c-gds-host-attr~
,gds-obj~
,gds-obj-attr~
,c-gds-obj-attr~
,gds-obj-prop~
,c-gds-obj-prop~
,gds-obj-prop-attr~
,assortment-matrix~
,assortment-matrix-attr~
,c-assortment-matrix~
,assortment-matrix-goods~
,c-assortment-matrix-goods~
,gds-prt~
,c-gds-prt~
,gds-season~
,c-gds-season~
,gds-add-charges~
,c-gds-add-charges~
,gds-grp-obj-attr~
,c-gds-obj-ref~
,global-state~
,goods~
,c-goods~
,goods-attr~
,c-goods-attr~
,group-period-validity~
,c-group-period-validity~
,grp-obj-price~
,c-grp-obj-price~
,hist-nws-option~
,c-hist-nws-option~
,icnt-doc~
,inkas~
,c-inkas~
,layout~
,c-layout~
,layout-elem~
,layout-elem-rule~
,c-layout-elem-rule~
,lvl-name~
,menu-user~
,menu-user-call~
,marking~
,marking-lines~
,nozzle~
,c-nozzle~
,nozzle-attr~
,c-nozzle-attr~
,nws-doc-hist~
,nws-outline~
,obj-date~
,ord-cons~
,ord-doc~
,c-ord-doc~
,ord-doc-rcv~
,ord-chain~
,parts~
,parts-attr~
,pay-type~
,c-pay-type~
,pck-rcvd~
,pck-sent~
,person~
,c-person~
,pl-gds~
,c-pl-gds~
,pl-gds-attr~
,c-pl-gds-attr~
,pl-gds-pump~
,c-pl-gds-pump~
,pl-level~
,pl-level-imp~
,c-pl-level~
,pl-level-mm~
,pl-level-mm-imp~
,pl-pump~
,c-pl-pump~
,pl-pump-nozzle~
,c-pl-pump-nozzle~
,place~
,c-place~
,place-attr~
,c-place-attr~
,place-imp~
,place-imp-attr~
,place-io~
,c-place-io~
,point-io~
,c-point-io~
,point-place-rel~
,c-point-place-rel~
,point-point-rel~
,c-point-point-rel~
,price-all~
,price-doc~
,c-price-doc~
,price-doc-forming~
,c-price-doc-forming~
,price-list-type~
,c-price-list-type~
,prod-bc~
,c-prod-bc~
,prod-bc-db~
,profile-by-profile~
,c-profile-by-profile~
,prop-head~
,c-prop-head~
,prop-map~
,prop-ref~
,c-prop-ref~
,prop-ref-call~
,prop-ruleset~
,prop-script~
,prt-obj~
,pscript-ruleset~
,pump~
,c-pump~
,pump-attr~
,c-pump-attr~
,pump-nozzle~
,c-pump-nozzle~
,qnty-group~
,rang-abc-def~
,rang-xyz-def~
,recipe~
,c-recipe~
,recipe-develop~
,c-recipe-develop~
,recipe-gds~
,c-recipe-gds~
,regions~
,c-regions~
,norm-loss~
,c-norm-loss~
,rp-by-call~
,c-rp-by-call~
,rp-rule-param~
,rpt-option~
,rule~
,rule-by-call~
,c-rule-by-call~
,rule-by-profile~
,rule-by-set~
,rule-call-param~
,c-rule-call-param~
,rule-profile~
,rule-process~
,ruledict~
,c-ruledict~
,ruledict-param~
,ruleset~
,rvs-doc~
,c-rvs-doc~
,s-coeff~
,c-s-coeff~
,scales~
,c-scales~
,scales-attr~
,c-scales-attr~
,scales-gds~
,c-scales-gds~
,scales-grp~
,c-scales-grp~
,schedule~
,schedule-attr~
,schet-fact-doc~
,c-schet-fact-doc~
,season~
,c-season~
,sert~
,c-sert~
,sert-join~
,shift-obj~
,c-shift-obj~
,shift-period~
,shop~
,c-shop~
,some-lk~
,sr-izmerenia~
,c-sr-izmerenia~
,sr-izmerenia-attr~
,c-sr-izmerenia-attr~
,staff~
,c-staff~
,stop-list~
,store~
,c-store~
,sum-group~
,sum-grp~
,c-sum-grp~
,sum-grp-obj~
,c-sum-grp-obj~
,sysconf~
,c-sysconf~
,tare~
,c-tare~
,tax~
,c-tax~
,tax-rate~
,c-tax-rate~
,tax-rate-gds~
,tax-rate-gds-grp~
,c-tax-rate-gds-grp~
,tax-rate-value~
,tax-units~
,c-tax-units~
,thbj-attr~
,c-thbj-attr~
,trn-doc~
,c-trn-doc~
,trn-reason~
,turnover-buyer-main~
,turnover-group~
,units~
,c-units~
,upgrade~
,user-account~
,c-user-account~
,user-context-history~
,user-host~
,user-login~
,c-user-login~
,user-login-action-item~
,user-login-action-role~
,user-login-attr~
,user-menu-group~
,user-obj~
,user-window-attr~
,var-deliv-gr-per-val~
,c-var-deliv-gr-per-val~
,variant-delivery~
,c-variant-delivery~
,varianty-delivery-gds-obj~
,c-varianty-delivery-gds-obj~
,wealth~
,c-wealth~
,who-lk~
,wth-doc~
,c-wth-doc~
,wth-doc-attr
,wth-gds~
,c-wth-gds~
,wth-ser~
,c-wth-ser~
,wth-par~
,c-wth-par~
,wth-place~
,c-wth-place~
,xyz-analysis~
,c-user-log~
,egais-clients~
,c-egais-clients~
,egais-gds~
,c-egais-gds~
,c-vsd~
,c-gds-mercury
,vsd~
,vsd-attr~
,c-gds-mercury~
,gds-mercury~
,gds-mercury-attr~
,units-attr~
,c-promo-schedule~
,c-promo-schedule-week~
,c-PromoAction~
,c-PromoAttr~
,c-PromoCriterion~
,c-PromoGift~
,c-PromoGoods~
,c-PromoObject~
,promo-schedule~
,promo-schedule-week~
,PromoAction~
,PromoAttr~
,PromoCriterion~
,PromoGift~
,PromoGoods~
,PromoObject~
,tech-prol-pwd~
,c-tech-prol-pwd~
,c-CashBook~
,c-CashBookAttr~
,c-CashBookRule~
,c-CashBookRuleAttr~
,c-OperServ~
,c-operServAttr~
,CashBook~
,CashBookAttr~
,CashBookRule~
,CashBookRuleAttr~
,OperServ~
,OperServAttr~
,c-counter~
,counter~
,c-cashbook-head~
,c-goods-attr-any~
,c-promo-head~
,code~
,c-code~
,devisPc~
,devisPc-attr~
,utd~
,c-utd-head~
,c-utd~
,c-utd-head~
,c-utd-lines~
,c-utd-marking-lines~
,c-utd-err~
,c-utd-attr~
,c-utd-lines-attr~
,c-utd-marking-lines-attr~
,c-utd-err-attr~
,marking-attr
,Xattr~
,xGroupObj~
,xstatus~
,c-contract-specif-attr~
,tran-fuel~
,chk-slip-head~
,chk-slip-string~
,c-marking
,order-doc~
,order-line~
,order-doc-attr~
,order-line-attr~
,c-order-head~
,c-order-doc~
,c-order-line~
,c-order-doc-attr~
,c-order-line-attr~
,reportShift~
,shift-param~
,susp-chk~
':U .
define variable oth-list1 as character no-undo .
define variable oth-list2 as character no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-updated as logical no-undo .
define variable v-ii as integer no-undo .
define variable v-mess as logical no-undo .
define buffer buf_hist-nws-option for ub.hist-nws-option.
define buffer buf2_hist-nws-option for ub.hist-nws-option.
define buffer locked_hist-nws-option for ub.hist-nws-option.
run waitfram-show in this-procedure ( "Реинициализация настроек опций истории и маршрутизации").
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  _v-ii:
  do v-ii = 1 to num-entries( news-list):
    find first buf_hist-nws-option no-lock where
              buf_hist-nws-option.db-num = g#db-num
          and buf_hist-nws-option.table-name = entry(v-ii, news-list) no-error.
    if entry(v-ii, news-list) begins "c-":U then next _v-ii.
    if not available buf_hist-nws-option  then do:
      if g#db-num > 0  then do:
        find first buf_hist-nws-option no-lock where
                  buf_hist-nws-option.db-num = 0
            and  buf_hist-nws-option.table-name = entry(v-ii, news-list)
            and  buf_hist-nws-option.charkey_one = '':U
            and  buf_hist-nws-option.charkey_two = '':U
            and  buf_hist-nws-option.charkey_three = '':U
            and  buf_hist-nws-option.key#_one = 0
            and  buf_hist-nws-option.key#_two = 0
            and  buf_hist-nws-option.key#_three = 0
            no-error.
        if available buf_hist-nws-option then do:
          if not available locked_hist-nws-option then do:
            if p-read-only then do:
              v-mess = yes.
              leave _v-ii.
            end.
            find first locked_hist-nws-option exclusive-lock where
                      locked_hist-nws-option.db-num = g#db-num
                  and locked_hist-nws-option.hn-id = 0.
          end.
          find first buf2_hist-nws-option share-lock where
                    buf2_hist-nws-option.db-num = g#db-num
                and buf2_hist-nws-option.hn-id = buf_hist-nws-option.hn-id no-error .
          if available buf2_hist-nws-option then do:
          end.
          else do:
            if p-read-only then do:
              v-mess = yes.
              leave _v-ii.
            end.
            create buf2_hist-nws-option.
            assign
            buf2_hist-nws-option.db-num = g#db-num
            buf2_hist-nws-option.hn-id = buf_hist-nws-option.hn-id.
          end.
          buffer-copy buf_hist-nws-option
          except
          db-num
          get-hist-from-nws
          hist-from-prim
          hist-to-nws
          nws-to-cd
          nws-to-hist
          smart-nws
          to buf2_hist-nws-option
          assign
          buf2_hist-nws-option.db-num = g#db-num
          buf2_hist-nws-option.get-hist-from-nws = ( if buf_hist-nws-option.get-hist-from-nws = integer('10':U)
                                                      or buf_hist-nws-option.get-hist-from-nws = integer('-10':U)
                                                      then buf_hist-nws-option.get-hist-from-nws
                                                      else integer('0':U))
          buf2_hist-nws-option.hist-from-prim = ( if buf_hist-nws-option.hist-from-prim = integer('10':U)
                                                      or buf_hist-nws-option.hist-from-prim = integer('-10':U)
                                                      then buf_hist-nws-option.hist-from-prim
                                                      else integer('0':U))
          buf2_hist-nws-option.hist-to-nws = ( if buf_hist-nws-option.hist-to-nws = integer('10':U)
                                                      or buf_hist-nws-option.hist-to-nws = integer('-10':U)
                                                      then buf_hist-nws-option.hist-to-nws
                                                      else integer('0':U))
          buf2_hist-nws-option.nws-to-cd = ( if buf_hist-nws-option.nws-to-cd = integer('10':U)
                                                      or buf_hist-nws-option.nws-to-cd = integer('-10':U)
                                                      then buf_hist-nws-option.nws-to-cd
                                                      else integer('-1':U))
          buf2_hist-nws-option.nws-to-hist = ( if buf_hist-nws-option.nws-to-hist = integer('10':U)
                                                      or buf_hist-nws-option.nws-to-hist = integer('-10':U)
                                                      then buf_hist-nws-option.nws-to-hist
                                                      else integer('0':U))
          buf2_hist-nws-option.smart-nws = ( if buf_hist-nws-option.smart-nws = integer('10':U)
                                                      or buf_hist-nws-option.smart-nws = integer('-10':U)
                                                      then buf_hist-nws-option.smart-nws
                                                      else integer('-1':U))
          v-updated                      = yes
          .
        end.
      end.
      else do:
        if p-read-only then do:
          v-mess = yes.
          leave _v-ii.
        end.
        if not available locked_hist-nws-option then do:
          find first locked_hist-nws-option exclusive-lock where
                    locked_hist-nws-option.db-num = g#db-num
                and locked_hist-nws-option.hn-id = 0 no-wait no-error.
          if locked locked_hist-nws-option then do:
             message
             substitute("В процессе входа в систему потребовалось реинициализировать настройки записи истории и маршрутизации&1"+
                        "однако ресурс занят&1" +
                        "ТАБЛИЦА &2" +
                        "Имя пользователя, использующего ресурс будет известно после нажатия клавиши ВВОД"
                        , chr(10)
                        ,entry(v-ii, news-list)
                        )
             view-as alert-box error .
              find first locked_hist-nws-option exclusive-lock where
                        locked_hist-nws-option.db-num = g#db-num
                    and locked_hist-nws-option.hn-id = 0
                    no-error.
             return.
          end.
        end.
        create buf2_hist-nws-option.
        assign
        buf2_hist-nws-option.db-num = g#db-num
        buf2_hist-nws-option.hn-id  = next-value(s-hn-id, ub)
        buf2_hist-nws-option.subject-group = '':U
        buf2_hist-nws-option.table-name = entry(v-ii, news-list)
        buf2_hist-nws-option.get-hist-from-nws = integer('0':U)
        buf2_hist-nws-option.hist-from-prim    = integer('0':U)
        buf2_hist-nws-option.hist-to-nws       = integer('0':U)
        buf2_hist-nws-option.nws-to-cd         = integer('-1':U)
        buf2_hist-nws-option.nws-to-hist       = integer('0':U)
        buf2_hist-nws-option.smart-nws         = integer('-1':U)
        v-updated                              = yes
        .
      end.
    end.
  end.
  if v-mess then do:
    return error substitute("&1 &2 &3&4До начала работы с данной БД (режим RO) необходимо произвести вход в ОСНОВНУЮ БД!!!"
                            ,vss-workfile
                            ,vss-revision
                            ,vss-description
                            ,chr(10)).
  end.
  if v-updated then do:
    run cur-time in this-procedure(output v-today, output v-time).
    assign
    locked_hist-nws-option.option-descr = substitute("&1 &2", string(v-today, "99/99/9999"), string(v-time, "HH:MM:SS")).
  end.
end.
run waitfram-hide in this-procedure .
