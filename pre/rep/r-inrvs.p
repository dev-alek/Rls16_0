block-level on error undo, throw.
def var vss-revision    as character no-undo init "$Revision: 099a383cf864, 290, rls $":U .
def var vss-author      as character no-undo init "$Author: PGridchina $":U .
def var vss-date        as character no-undo init "$Date: Tue Dec 01 19:11:24 2015 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-inrvs.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-inrvs.p $":U .
def var vss-description as character no-undo init "Приходная накладная по топливу".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE LastDate:
    def input parameter in-date as date no-undo.
    def output parameter LastDate as date no-undo.
    LastDate = ((DATE(MONTH(in-date),28,YEAR(in-date)) + 4) - DAY(DATE(MONTH(in-date),28,YEAR(in-date)) + 4)).
END PROCEDURE.
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-recid              as recid            no-undo.
def stream repstr .
def var v-ind         as integer   no-undo .
def var v-line        as character no-undo format "X(195)" .
assign
  v-line = fill("-", 195 )
.
def var v-line1        as character no-undo format "X(195)" .
def var v-line2        as character no-undo format "X(195)" .
def var v-line3        as character no-undo format "X(195)" .
assign
  v-line1 = v-line
  v-line2 = v-line
  v-line3 = v-line
.
define variable varpl-qnty              like ub.doc-line.doc-qnty   no-undo.
define variable varpl-cli-qnty          like ub.doc-line.cli-qnty   no-undo.
define variable varpl-fact-qnty         like ub.doc-line.fact-qnty  no-undo.
define variable varpl-state-qnty        like ub.doc-line.fact-qnty  no-undo.
define variable varpl-acc-prc-cur-cli   like ub.doc-line.price-cli  no-undo.
define variable varpl-acc-sum-cur-cli   like ub.doc-line.price-cli  no-undo.
define variable varpl-sale-prc-cur-base like ub.doc-line.price-base no-undo.
define variable varpl-sale-sum-cur-base like ub.doc-line.price-base no-undo.
define variable varpl-acc-prc-cur-base  like ub.doc-line.price-base no-undo.
define variable varpl-acc-sum-cur-base  like ub.doc-line.price-base no-undo.
define variable varpl-num               like ub.place.pl-code       no-undo.
define variable varcar-num              as   character           no-undo.
define variable varcar-volume           as   character           no-undo.
define variable varpl-acc-sum-cur-cli-doc   like ub.doc-line.price-cli  no-undo.
define variable varpl-sale-sum-cur-base-doc like ub.doc-line.price-base no-undo.
define variable varpl-acc-sum-cur-base-doc  like ub.doc-line.price-base no-undo.
define buffer bef-rvs-doc for ub.rvs-doc.
define buffer aft-rvs-doc for ub.rvs-doc.
define buffer bef-rvs-line for ub.rvs-line.
define buffer aft-rvs-line for ub.rvs-line.
def var sym1          as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym2          as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym3          as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym4          as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym5          as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym6          as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym7          as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym8          as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym9          as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym10         as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym11         as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym12         as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym13         as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym14         as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym15         as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym16         as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym17         as character no-undo format "x(1)":u label '!':u init ":":u .
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
run waitfram-show in this-procedure
  (input 'Подождите ...'
  ) .
output stream repstr to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(45) .
find first ub.trn-doc no-lock
  where recid(ub.trn-doc) = p-recid no-error.
if not available ub.trn-doc then do:
  message
    vss-workfile vss-revision vss-description skip
    "Документ не найден" skip
    view-as alert-box.
  undo, return error .
end.
def var v-host-name   as character no-undo.
def var v-host-city   as character no-undo.
def var v-obj-name    as character no-undo.
def var v-cli-name    as character no-undo.
def var v-cli-city    as character no-undo.
def var v-header-name as character no-undo.
def var v-print-time  as character no-undo.
def var v-curr-abbr   as character no-undo.
def var v-bef-rvs     as character no-undo.
def var v-aft-rvs     as character no-undo.
assign
  v-header-name = "П Р И Х О Д Н А Я  Н А К Л А Д Н А Я  П О  Т О П Л И В У  № " + ub.trn-doc.doc-code
  v-print-time  = cur-time-string()
.
find first ub.clients no-lock
  where ub.clients.obj-type = ub.trn-doc.obj-type
    and ub.clients.obj-code = ub.trn-doc.obj-code
  .
assign
  v-obj-name = ub.clients.obj-name
.
find first ub.clients no-lock
  where ub.clients.obj-type = ub.trn-doc.cli-type
    and ub.clients.obj-code = ub.trn-doc.cli-code
  .
assign
  v-cli-name = ub.clients.obj-name
.
case ub.clients.obj-type :
  when 'орг':U then do:
    find first ub.firm no-lock
      where ub.firm.firm-code = ub.clients.obj-code
      .
    assign
      v-cli-city = ub.firm.city
    .
  end.
  when 'чел':U then do:
    find first ub.person no-lock
      where ub.person.psn-code = ub.clients.obj-code
      .
    assign
      v-cli-city = ub.person.city
    .
  end.
end.
find first ub.clients no-lock
  where ub.clients.obj-type = 'орг':U
    and ub.clients.obj-code = ub.trn-doc.host-code
  .
assign
  v-host-name = ub.clients.obj-name
.
find first ub.firm no-lock
  where ub.firm.firm-code = ub.clients.obj-code
  .
assign
  v-host-city = ub.firm.city
.
find first ub.currency where ub.currency.curr-code = ub.trn-doc.exch-code no-lock.
ASSIGN v-curr-abbr = ub.currency.curr-abbr.
find first bef-rvs-doc where bef-rvs-doc.out-code = ub.trn-doc.doc-code and
                             bef-rvs-doc.rvs-type = 'перед_док':U    no-lock no-error.
ASSIGN v-bef-rvs = if available bef-rvs-doc then string(bef-rvs-doc.rvs-code) else "сверка не производилась".
find first aft-rvs-doc where aft-rvs-doc.out-code = ub.trn-doc.doc-code and
                             aft-rvs-doc.rvs-type = 'после_док':U     no-lock no-error.
ASSIGN v-aft-rvs = if available aft-rvs-doc then string(aft-rvs-doc.rvs-code) else "сверка не производилась".
define frame doc-line-frm
  sym1  space(0) ub.goods.artic             format "x(7)" column-label "1" space(0)
  sym2  space(0) ub.goods.gds-name          format "x(35)" column-label "2" space(0)
  sym3  space(0) varpl-qnty              format ">>>,>>9.<<<" column-label "3" space(0)
  sym4  space(0) ub.doc-line.fact-density   format ">.9999" column-label "4" space(0)
  sym5  space(0) varpl-cli-qnty          format ">>>,>>9.<<<" column-label "5" space(0)
  sym6  space(0) varpl-fact-qnty         format ">>>,>>9.<<<" column-label "6" space(0)
  sym7  space(0) varpl-state-qnty        format ">>>,>>9.<<<" column-label "7" space(0)
  sym8  space(0) varpl-acc-prc-cur-cli   format "->>,>>9.99" column-label "8" space(0)
  sym9  space(0) varpl-acc-sum-cur-cli   format "->,>>>,>>9.99" column-label "9=6*8" space(0)
  sym10 space(0) varpl-sale-prc-cur-base format "->>,>>9.99" column-label "10" space(0)
  sym11 space(0) varpl-sale-sum-cur-base format "->,>>>,>>9.99" column-label "11=10*6" space(0)
  sym12 space(0) varpl-acc-prc-cur-base  format "->>,>>9.99" column-label "12" space(0)
  sym13 space(0) varpl-acc-sum-cur-base  format "->,>>>,>>9.99" column-label "13=12*6" space(0)
  sym14 space(0) varpl-num               format " 999999999" column-label "14" space(0)
  sym15 space(0) varcar-num              format "X(8)" column-label "15" space(0)
  sym16 space(0) varcar-volume           format "X(11)" column-label "16" space(0)
  sym17 space(0)
  with width 197  stream-io use-text .
form with frame doc-line-frm .
    define variable v-oper-name    as character    no-undo.
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrnick in g#library
  (input  ub.trn-doc.creid
  ,output v-oper-name
  )  .
put stream repstr unformatted
  string(v-host-name + fill(" ", 40), "x(40)")  v-host-city skip
  "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"  v-print-time skip
  "   Номер смены "  ub.trn-doc.shift-name  "    Дата начала смены "  ub.trn-doc.shift-date skip
  "                                 П Р И Х О Д Н А Я  Н А К Л А Д Н А Я  П О  Т О П Л И В У  № "  ub.trn-doc.doc-code skip
  "   АЗС: "  v-obj-name  "    Оператор: "  v-oper-name skip
  "   Поставщик: "  v-cli-name skip
  "    Адрес поставщика: "  v-cli-city skip
  "   По документу: "  ub.trn-doc.doc-code   " от "  string( if ub.trn-doc.fact-date <> ? then ub.trn-doc.fact-date else ub.trn-doc.doc-date )
  " г.          Валюта: "  v-curr-abbr " Курс: " ub.trn-doc.exch-rate " Шкала: " ub.trn-doc.exch-scale skip
  "   Номер протокол измерений до слива: " v-bef-rvs "      Номер протокола после слива и стабилизации: " v-aft-rvs skip
  .
put stream repstr unformatted
  v-line skip
  STRING("!       ", "X(8)") STRING("!                                   ", "X(36)") STRING("!        ", "X(9)") STRING("! Плот ", "X(7)") STRING("!        ", "X(9)") STRING("! Фактич.", "X(9)") STRING("!Фактич. ", "X(9)") STRING("!  Учетная ", "X(11)") STRING("!  Сумма по   ", "X(14)") STRING("! Розничная", "X(11)") STRING("!  Сумма по   ", "X(14)") STRING("!  Учетная ", "X(11)") STRING("!  Сумма по   ", "X(14)") STRING("!          ", "X(11)") STRING("! Гос    ", "X(9)") STRING("!           !", "X(13)") skip
  STRING("!       ", "X(8)") STRING("!                                   ", "X(36)") STRING("!Объем по", "X(9)") STRING("!ность ", "X(7)") STRING("!Кол-во  ", "X(9)") STRING("! кол-во ", "X(9)") STRING("!объем по", "X(9)") STRING("!    цена  ", "X(11)") STRING("!  учет. цене ", "X(14)") STRING("!   цена в ", "X(11)") STRING("!  розн. цене ", "X(14)") STRING("!   цена в ", "X(11)") STRING("!  учет. цене ", "X(14)") STRING("!  Номер   ", "X(11)") STRING("! номер  ", "X(9)") STRING("!   Объем   !", "X(13)") skip
  STRING("!Артикул", "X(8)") STRING("!            Наименование           ", "X(36)") STRING("!ТТН в л.", "X(9)") STRING("!поТТН ", "X(7)") STRING("! по ТТН ", "X(9)") STRING("! принят.", "X(9)") STRING("!счетчику", "X(9)") STRING("!  в валюте", "X(11)") STRING("!  в валюте   ", "X(14)") STRING("!  базовой ", "X(11)") STRING("!  в базовой  ", "X(14)") STRING("!  базовой ", "X(11)") STRING("!  в базовой  ", "X(14)") STRING("!резервуара", "X(11)") STRING("! авто   ", "X(9)") STRING("!  цистерны !", "X(13)") skip
  STRING("!       ", "X(8)") STRING("!                                   ", "X(36)") STRING("!        ", "X(9)") STRING("! куб  ", "X(7)") STRING("!  в кг  ", "X(9)") STRING("!топлива ", "X(9)") STRING("!в литрах", "X(9)") STRING("! накладной", "X(11)") STRING("!  накладной  ", "X(14)") STRING("!   валюте ", "X(11)") STRING("!   валюте    ", "X(14)") STRING("!   валюте ", "X(11)") STRING("!   валюте    ", "X(14)") STRING("!          ", "X(11)") STRING("!цистерны", "X(9)") STRING("!           !", "X(13)") skip
  STRING("!       ", "X(8)") STRING("!                                   ", "X(36)") STRING("!        ", "X(9)") STRING("! см   ", "X(7)") STRING("!        ", "X(9)") STRING("!в литрах", "X(9)") STRING("!        ", "X(9)") STRING("!          ", "X(11)") STRING("!             ", "X(14)") STRING("!          ", "X(11)") STRING("!             ", "X(14)") STRING("!          ", "X(11)") STRING("!             ", "X(14)") STRING("!          ", "X(11)") STRING("!        ", "X(9)") STRING("!           !", "X(13)") skip
  v-line
  .
form header
  v-line1 at 1 skip
  v-header-name format "x(50)" at 1
    "Дата:" at 60
    v-print-time format "x(20)"
    "Стр." at 169 string( page-number(repstr), ">>>9" )  skip
  v-line2 at 1 skip
  with frame topframe
  width 197 page-top no-labels no-box .
view stream repstr frame topframe .
form header
  v-line skip
  "Продолжение на следующей странице " at 30 skip
  with frame bottomframe
  width 197 page-bottom no-labels no-box .
view stream repstr frame bottomframe .
for each ub.doc-line
  where ub.doc-line.doc-code = ub.trn-doc.doc-code no-lock,
  first ub.goods where ub.goods.artic     = ub.doc-line.artic     and
                    ub.goods.prod-type = ub.doc-line.prod-type and
                    ub.goods.prod-code = ub.doc-line.prod-code no-lock,
  each ub.parts where ub.parts.out-code  = ub.doc-line.doc-code  and
                   ub.parts.obj-type  = ub.doc-line.obj-type  and
                   ub.parts.obj-code  = ub.doc-line.obj-code  and
                   ub.parts.artic     = ub.doc-line.artic     and
                   ub.parts.prod-type = ub.doc-line.prod-type and
                   ub.parts.prod-code = ub.doc-line.prod-code no-lock
 break by ub.parts.artic
       by ub.parts.prod-type
       by ub.parts.prod-code
       by ub.parts.pl-code
:
  if first-of(ub.parts.prod-code) then do:
     find first ub.doc-attr where ub.doc-attr.doc-code  = ub.doc-line.doc-code and
                                  ub.doc-attr.attr-code = 'car-num':U no-lock no-error.
     ASSIGN
     varcar-num    = if available ub.doc-attr then ub.doc-attr.attr-value else "".
     find first ub.doc-line-attr where ub.doc-line-attr.doc-code  = ub.doc-line.doc-code and
                                    ub.doc-line-attr.gds-code  = ub.goods.gds-code    and
                                    ub.doc-line-attr.attr-code = "car-vol" no-lock no-error.
     ASSIGN
     varcar-volume = if available ub.doc-line-attr then ub.doc-line-attr.attr-value else "".
     for each ub.gds-dtl where ub.gds-dtl.doc-code  = ub.doc-line.doc-code  and
                            ub.gds-dtl.artic     = ub.doc-line.artic     and
                            ub.gds-dtl.prod-type = ub.doc-line.prod-type and
                            ub.gds-dtl.prod-code = ub.doc-line.prod-code no-lock :
        accumulate ub.gds-dtl.cur-base * ub.gds-dtl.fact-qnty (total)
                   ub.gds-dtl.fact-qnty (total).
     end.
     ASSIGN varpl-sale-prc-cur-base = (accum total ub.gds-dtl.cur-base * ub.gds-dtl.fact-qnty) / (accum total ub.gds-dtl.fact-qnty).
  end.
  assign
    v-ind = v-ind + 1
  .
  process events .
  run waitfram-show in this-procedure
    (input "Печать приходной накладной. Обработано строк: " + string(v-ind)
    ) .
assign
  price-rubl-with-tax-loc = ub.parts.price-rubl
  price-base-with-tax-loc = ub.parts.price-base
.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if ub.parts.out-code = 'free-zone':U     or
     ub.parts.out-code = 'out-zone':U   or
     ub.parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = ub.parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = ub.parts.price-cli
   cli-base-rate          = ub.parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if ub.parts.road-tax-base  = ? then 0 else ub.parts.road-tax-base)
           road-tax-rubl-loc  = (if ub.parts.road-tax-rubl  = ? then 0 else ub.parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if ub.parts.transport-base = ? then 0 else ub.parts.transport-base)
          transport-rubl-loc = (if ub.parts.transport-rubl = ? then 0 else ub.parts.transport-rubl)
          other-base-loc     = (if ub.parts.other-base     = ? then 0 else ub.parts.other-base)
          other-rubl-loc     = (if ub.parts.other-rubl     = ? then 0 else ub.parts.other-rubl)
          vat-pc-loc         = (if ub.parts.vat-pc         = ? then 0 else ub.parts.vat-pc)
          slt-pc-loc         = (if ub.parts.slt-pc         = ? then 0 else ub.parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (ub.parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if ub.parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if ub.parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / ub.parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
  ACCUMULATE slt-base-loc * ub.parts.fact-qnty (TOTAL)
             vat-base-loc * ub.parts.fact-qnty (TOTAL).
  ACCUMULATE
  ub.parts.qnty                           (TOTAL BY ub.parts.pl-code)
  ub.parts.cli-qnty                       (TOTAL BY ub.parts.pl-code)
  ub.parts.fact-qnty                      (TOTAL BY ub.parts.pl-code)
  .
  if last-of(ub.parts.pl-code) then do:
     if available bef-rvs-doc and
        available aft-rvs-doc then do:
        find first bef-rvs-line where bef-rvs-line.rvs-code = bef-rvs-doc.rvs-code and
                                      bef-rvs-line.obj-type = bef-rvs-doc.obj-type and
                                      bef-rvs-line.obj-code = bef-rvs-doc.obj-code and
                                      bef-rvs-line.pl-code  = ub.parts.pl-code        and
                                      bef-rvs-line.gds-code = ub.goods.gds-code       no-lock.
        find first aft-rvs-line where aft-rvs-line.rvs-code = aft-rvs-doc.rvs-code and
                                      aft-rvs-line.obj-type = aft-rvs-doc.obj-type and
                                      aft-rvs-line.obj-code = aft-rvs-doc.obj-code and
                                      aft-rvs-line.pl-code  = ub.parts.pl-code        and
                                      aft-rvs-line.gds-code = ub.goods.gds-code       no-lock.
     end.
     ASSIGN
       varpl-qnty              = (ACCUM TOTAL BY ub.parts.pl-code ub.parts.qnty)
       varpl-cli-qnty          = (ACCUM TOTAL BY ub.parts.pl-code ub.parts.cli-qnty)
       varpl-fact-qnty         = (ACCUM TOTAL BY ub.parts.pl-code ub.parts.fact-qnty)
       varpl-state-qnty        = (if available bef-rvs-doc and available aft-rvs-doc then aft-rvs-line.state-measure-qnty - bef-rvs-line.state-measure-qnty else ?)
       varpl-acc-prc-cur-cli   = ub.doc-line.price-rubl / ub.trn-doc.exch-rate * ub.trn-doc.exch-scale
       varpl-acc-sum-cur-cli   = varpl-acc-prc-cur-cli   * varpl-fact-qnty
       varpl-sale-sum-cur-base = varpl-sale-prc-cur-base * varpl-fact-qnty
       varpl-acc-prc-cur-base  = ub.doc-line.price-base
       varpl-acc-sum-cur-base  = varpl-acc-prc-cur-base * varpl-fact-qnty
       varpl-num               = ub.parts.pl-code.
   ASSIGN
    varpl-acc-sum-cur-cli-doc   = varpl-acc-prc-cur-cli   * varpl-qnty
    varpl-sale-sum-cur-base-doc = varpl-sale-prc-cur-base * varpl-qnty
    varpl-acc-sum-cur-base-doc  = varpl-acc-prc-cur-base  * varpl-qnty.
   ACCUMULATE varpl-acc-sum-cur-cli        (TOTAL)
              varpl-sale-sum-cur-base      (TOTAL)
              varpl-acc-sum-cur-base       (TOTAL)
              varpl-acc-sum-cur-cli-doc    (TOTAL)
              varpl-sale-sum-cur-base-doc  (TOTAL)
              varpl-acc-sum-cur-base-doc   (TOTAL).
    display stream repstr
      sym1  ub.goods.artic
      sym2  ub.goods.gds-name
      sym3  varpl-qnty
      sym4  ub.doc-line.fact-density
      sym5  varpl-cli-qnty
      sym6  varpl-state-qnty
      sym7  varpl-fact-qnty
      sym8  varpl-acc-prc-cur-cli
      sym9  varpl-acc-sum-cur-cli
      sym10 varpl-sale-prc-cur-base
      sym11 varpl-sale-sum-cur-base
      sym12 varpl-acc-prc-cur-base
      sym13 varpl-acc-sum-cur-base
      sym14 varpl-num
      sym15 varcar-num
      sym16 varcar-volume
      sym17
      with frame doc-line-frm 0 down.
      down stream repstr 1 with frame doc-line-frm.
  end.
end.
put stream repstr
  v-line  skip
  .
hide frame input-frm .
put stream repstr
  skip
  "   П О  Ф А К Т У:                                                               П О  Т Т Н :" skip
  "   Итого в валюте накладной по учетной цене " (ACCUM TOTAL varpl-acc-sum-cur-cli)    format ">>,>>>,>>9.99" "                           Итого в валюте накладной по учетной цене" (ACCUM TOTAL varpl-acc-sum-cur-cli-doc)   format ">>,>>>,>>9.99" skip
  "   Итого в базовой валюте по учетной цене   " (ACCUM TOTAL varpl-acc-sum-cur-base)   format ">>,>>>,>>9.99" "                           Итого в базовой валюте по учетной цене  " (ACCUM TOTAL varpl-acc-sum-cur-base-doc)  format ">>,>>>,>>9.99" skip
  "   Итого в базовой валюте по розничной цене " (ACCUM TOTAL varpl-sale-sum-cur-base)  format ">>,>>>,>>9.99" "                           Итого в базовой валюте по розничной цене" (ACCUM TOTAL varpl-sale-sum-cur-base-doc) format ">>,>>>,>>9.99" skip
  "   В том числе в базовой валюте по учетной цене:" skip
  "          НДС                                " (ACCUM TOTAL vat-base-loc * ub.parts.fact-qnty) format ">>,>>>,>>9.99" skip
  "          Без НДС                            " (ACCUM TOTAL varpl-acc-sum-cur-base) - (ACCUM TOTAL vat-base-loc * ub.parts.fact-qnty) format ">>,>>>,>>9.99" skip
  "          НсП                                " (ACCUM TOTAL slt-base-loc * ub.parts.fact-qnty) format ">>,>>>,>>9.99" skip
  "          ГСМ                                "
  .
put stream repstr
  skip(2)
  .
put stream repstr unformatted
  "   Топливо сдал ___________________________                                          Топливо принял _________________________ "
  .
hide stream repstr frame bottomframe .
output stream repstr close.
run waitfram-hide in this-procedure .
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 8 >= 8 then 2 else 0), 0, 0,
                                      OUTPUT g#log ).
end.
else do:
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + " " +
      string( session:temp-directory) +  "$" + string( g#report-num )
              ) .
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl" + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txl" + " " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl"
              ) .
end.
