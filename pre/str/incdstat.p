block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define parameter buffer t-doc for ub.trn-doc.
define input parameter p-direction as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: incdstat.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/incdstat.p $":U .
define variable vss-description as character no-undo init "Действия с чеками инвентаризации при смене статуса документа".
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
define variable add-sens as logical no-undo init no.
FUNCTION calc-excise RETURNS DECIMAL(input  parprice-sale as decimal,
                                     input  parroad-tax   as decimal,
                                     input  parvat-pc     as decimal,
                                     input  parfactorrd   as decimal,
                                     output parexcise     as decimal):
ASSIGN parexcise = (parprice-sale - parroad-tax) * parvat-pc / (100 + parvat-pc) -
                   1 / parfactorrd * parroad-tax.
RETURN parexcise.
END FUNCTION.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
  define temp-table  tt-tax no-undo
field tax-code    like ub.tax.tax-code
FIELD individual  like ub.tax.individual
FIELD tax-name    like ub.tax.tax-name format "X(12)" column-label "Налог"
field rate-code   like ub.tax-rate.rate-code
FIELD rate-name   like ub.tax-rate.rate-name FORMAT "X(12)"
FIELD tax-type    like ub.tax.tax-type
field rate-value  like ub.tax-rate-value.rate-value
FIELD tax-rate-gds-rc  as recid
FIELD to-cashdesk like ub.tax.to-cashdesk
index tax-code is unique primary tax-code.
define new global shared variable g#libbcrcn as handle no-undo .
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable line-mode as character no-undo init ? .
define variable i            as integer   no-undo.
define variable j            as integer   no-undo.
define variable b-c           as integer   no-undo.
define variable scan-txt      as character no-undo.
define variable is-all        as logical   no-undo.
define variable rate          as decimal   no-undo.
define variable g-type        as character no-undo init ?.
define variable qnty-str      as character no-undo.
define variable bar-str       as character no-undo.
define variable part-list     as character no-undo initial "".
define variable varscales-pref      as character no-undo.
define variable varpgscales-pref      as character no-undo.
define variable varscales-pref-type as character no-undo.
def stream ggg.
define stream cur.
define stream log.
define stream ler.
define stream err.
define frame a
    i format ">>>>9" label "Просмотрено" space (20) skip
    j format ">>>>9" label "Обработано"
    with view-as dialog-box side-labels three-d title "".
def var mess as char no-undo.
procedure check-code:
define input parameter parbar-str AS char no-undo.
define input parameter parprice   like ub.gds-dtl.price-base no-undo.
define input parameter parqnty    as dec no-undo.
define input  parameter parg#doc-prt as logical no-undo.
define input  parameter parscales-pref as character no-undo.
define input  parameter parpgscales-pref as character no-undo.
define output parameter parplace   as log initial no no-undo.
define output parameter parb-c     as int no-undo.
define output parameter parrate    as dec no-undo.
define variable varresult   as character       no-undo.
define variable vartype-bc  as character       no-undo.
define variable varweight   as decimal         no-undo.
def buffer b-bar-code for ub.bar-code.
ASSIGN mess = " Код: " + parbar-str + " количество: " + string (parqnty) + " ".
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  parbar-str
,input  parprice
,input  v-cntxt-obj-type
,input  v-cntxt-obj-code
,input  yes
,input  no
,input  parscales-pref
,input  parpgscales-pref
,output varresult
,output vartype-bc
,output varweight
,buffer ub.bar-code
,buffer ub.prod-bc
,buffer ub.place
) no-error.
if error-status:error then do:
  return error "Ошибка при разборе бар-кода: " + parbar-str.
end.
if not available bar-code THEN DO:
   if add-sens = ? and available place
   then DO: parPlace = YES. RETURN. END.
   ELSE RETURN ERROR "Товар отсутствует в базе данных.".
END.
else do:
    assign  parb-c  = bar-code.b-code
            parrate = bar-code.cli-base-rate.
    find ub.goods where ub.goods.gds-code  = ub.bar-code.gds-code no-lock.
    find ub.gds-prt where ub.gds-prt.upper-code = ub.goods.prt-root no-lock.
    ASSIGN mess = mess + "Артикул: " + ub.goods.artic + " производитель: " + ub.goods.prod-type + " " + string (ub.goods.prod-code) + " " + ub.goods.gds-name + chr(10) .
    if parg#doc-prt and gds-prt.node-name <> '_Пустая шкала':U and
       can-find (first gds-prt where gds-prt.upper-code = bar-code.node-code) then
       RETURN ERROR "Ссылка не на подробный признак.".
    if not parg#doc-prt and gds-prt.node-name <> '_Пустая шкала':U and
         bar-code.node-code <> gds-prt.node-code then do:
      find b-bar-code where recid (b-bar-code) = recid (bar-code) no-lock.
      find bar-code where bar-code.gds-code  = b-bar-code.gds-code
                      and bar-code.node-code = gds-prt.node-code
                      and bar-code.in-code   = b-bar-code.in-code
                      and bar-code.part-code = b-bar-code.part-code
                      and bar-code.unit-cli  = ub.goods.unit-base
                        no-lock.
      parb-c = bar-code.b-code.
      RETURN "Ссылка на подробный или узловой признак. Заменяем на код: " + STRING(bar-code.b-code).
    end.
end.
RETURN.
END PROCEDURE.
procedure proc-code.
define input parameter pl-str as char no-undo.
DEFine INPUT PARAMeter mode-proc as CHAR NO-UNDO.
define input parameter parscales-pref as character no-undo.
define input parameter parpgscales-pref as character no-undo.
define buffer b-bar-code for ub.bar-code.
DEFINE VARIABLE mode-create      as LOGICAL NO-UNDO.
DEFINE VARIABLE rec-old          as RECID NO-UNDO.
define variable varres        as logical         no-undo.
define variable var-code-temp like ub.place.pl-code no-undo.
define buffer pc-goods for ub.goods.
define variable g-log-char as character no-undo.
define variable varprice-cli-old        like ub.doc-line.price-cli no-undo.
define variable varprice-rubl-old       like ub.doc-line.price-cli no-undo.
define variable varprice-base-old       like ub.doc-line.price-cli no-undo.
define variable varcli-qnty-old         like ub.doc-line.cli-qnty  no-undo.
define variable varcli-base-rate-old    like ub.doc-line.cli-qnty  no-undo.
define variable varfact-qnty-old        like ub.doc-line.cli-qnty  no-undo.
define variable vardoc-qnty-old         like ub.doc-line.cli-qnty  no-undo.
define variable varvat-pc-old           like ub.doc-line.vat-pc    no-undo.
define variable varslt-pc-old           like ub.doc-line.vat-pc    no-undo.
define variable varroad-tax-old         like ub.doc-line.price-cli no-undo.
define variable varexcise-old           like ub.doc-line.price-cli no-undo.
define variable vartransport-rubl-old   like ub.doc-line.price-cli no-undo.
define variable varother-rubl-old       like ub.doc-line.price-cli no-undo.
define variable lns-cnt                 as   integer               no-undo.
IF mode-proc = "PLACE" THEN DO:
    do lns-cnt = 1 to num-entries (part-list):
      find ub.bar-code where ub.bar-code.b-code  = integer (entry (lns-cnt, part-list)) no-lock.
      find first pc-goods where pc-goods.gds-code  = ub.bar-code.gds-code no-lock.
      RUN plgdsfnd (input  no,
                    input  v-cntxt-obj-type,
                    input  v-cntxt-obj-code,
                    input  pc-goods.gds-code,
                    output varres,
                    output var-code-temp) no-error.
     if varres = yes or error-status:error then do:
          put stream log unformatted "***" mess "Нельзя перемещать партии товара по складским местам "
          pc-goods.artic " " pc-goods.prod-type " " pc-goods.prod-code
          " по объкту " v-cntxt-obj-type " " v-cntxt-obj-code " "  skip.
          put stream ler unformatted "***" mess "Нельзя перемещать партии товара по складским местам "
          pc-goods.artic " " pc-goods.prod-type " " pc-goods.prod-code
          " по объкту " v-cntxt-obj-type " " v-cntxt-obj-code " "  skip.
          put stream err unformatted bar-str "," qnty-str "," pl-str skip.
      end.
      else
      for each ub.parts where ub.parts.obj-type  = v-cntxt-obj-type
                       and ub.parts.obj-code  = v-cntxt-obj-code
                       and ub.parts.artic     = pc-goods.artic
                       and ub.parts.prod-type = pc-goods.prod-type
                       and ub.parts.prod-code = pc-goods.prod-code
                       and ub.parts.in-code   = ub.bar-code.in-code
                       and ub.parts.part-code = ub.bar-code.part-code
                       and ub.parts.rsrv-free = yes:
        ub.parts.pl-code = ub.place.pl-code.
        put stream log unformatted mess "Партия: код: " bar-code.b-code " артикул: " ub.parts.artic " номер: " ub.parts.part-code " Место: " ub.parts.pl-code " - успешно" skip.
        j = j + 1.
        disp j with frame a.
      end.
    end.
    part-list = "".
END.
ELSE DO:
  if add-sens = ? then part-list = if part-list = "" then string (b-c) else part-list + "," + string (b-c).
  else do:
    if ub.goods.gds-type <> 'т':U and (t-doc.doc-type <> 'рас':U or t-doc.internal) then do:
      put stream log unformatted "***" mess "Услуга не соответствует типу данной накладной" skip.
      put stream ler unformatted "***" mess "Услуга не соответствует типу данной накладной" skip.
      put stream err unformatted bar-str "," qnty-str skip.
      return error.
    end.
    if g-type = ? then g-type = ub.goods.gds-type.
    if g-type <> ub.goods.gds-type then do:
      put stream log unformatted "***" mess "Тип товара не соответствует типу данной накладной" skip.
      put stream ler unformatted "***" mess "Тип товара не соответствует типу данной накладной" skip.
      put stream err unformatted bar-str ","  qnty-str skip.
      return error.
    end.
    assign g-log-char = "yes".
    do transaction on error undo , leave:
       define variable tempmess as character no-undo.
       define buffer bf_doc-line for ub.doc-line.
       find first ub.doc-line where ub.doc-line.doc-code  = t-doc.doc-code  and
                                 ub.doc-line.artic     = ub.goods.artic     and
                                 ub.doc-line.prod-type = ub.goods.prod-type and
                                 ub.doc-line.prod-code = ub.goods.prod-code no-error.
       if available ub.doc-line then do:
          assign
          mode-create = no
          varprice-cli-old       = ub.doc-line.price-cli
          varprice-rubl-old      = ub.doc-line.price-rubl
          varprice-base-old      = ub.doc-line.price-base
          varcli-qnty-old        = ub.doc-line.cli-qnty
          varcli-base-rate-old   = ub.doc-line.cli-base-rate
          varfact-qnty-old       = ub.doc-line.fact-qnty
          vardoc-qnty-old        = ub.doc-line.doc-qnty
          varvat-pc-old          = ub.doc-line.vat-pc
          varslt-pc-old          = ub.doc-line.slt-pc
          varroad-tax-old        = ub.doc-line.road-tax
          varexcise-old          = ub.doc-line.excise
          vartransport-rubl-old  = ub.doc-line.transport-rubl
          varother-rubl-old      = ub.doc-line.other-rubl.
       end.
       else mode-create = yes.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_copy-scn in g#lib-trn
  ( input  parparentproc
   ,input  recid(t-doc)
   ,input  bar-code.b-code
   ,input  decimal(qnty-str) * rate
   ,input  is-all
   ,input  add-sens
   ,input  line-mode
   ,output tempmess
   ,output g-log-char
  ) no-error .
       assign
       mess = mess + tempmess.
       if error-status:error then do:
         assign
         mess = mess + return-value.
         put stream err unformatted bar-str "," qnty-str skip.
         put stream log unformatted "***" mess " - ошибка" skip.
         put stream ler unformatted "***" mess " - ошибка" skip.
         return error.
       end.
       else do:
         put stream log unformatted mess " - успешно" skip.
         if pl-str <> "" then run store-place in this-procedure ( input pl-str
                                                                 ,input parscales-pref
                                                                 ,input parpgscales-pref
                                                                 ).
         j = j + 1.
         disp j with frame a.
       end.
       find first ub.doc-line where ub.doc-line.doc-code  = t-doc.doc-code  and
                                 ub.doc-line.artic     = ub.goods.artic     and
                                 ub.doc-line.prod-type = ub.goods.prod-type and
                                 ub.doc-line.prod-code = ub.goods.prod-code no-error.
       if t-doc.doc-type = 'при':U then do:
         if mode-create then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcintrn in g#lib-trn
  (
   input parparentproc
  ,input recid(doc-line)
  ,input t-doc.doc-code
  ,input ub.doc-line.artic
  ,input ub.doc-line.prod-type
  ,input ub.doc-line.prod-code
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 'create'
  ,input ''
  ) no-error.
            if error-status:error then return error return-value.
         end.
         else do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcintrn in g#lib-trn
  (
   input parparentproc
  ,input recid(doc-line)
  ,input ub.doc-line.doc-code
  ,input ub.doc-line.artic
  ,input ub.doc-line.prod-type
  ,input ub.doc-line.prod-code
  ,input varprice-cli-old
  ,input varprice-rubl-old
  ,input varprice-base-old
  ,input varcli-qnty-old
  ,input varcli-base-rate-old
  ,input varfact-qnty-old
  ,input vardoc-qnty-old
  ,input varvat-pc-old
  ,input varslt-pc-old
  ,input varroad-tax-old
  ,input varexcise-old
  ,input vartransport-rubl-old
  ,input varother-rubl-old
  ,input 'update'
  ,input ''
  ) no-error.
            if error-status:error then return error return-value.
         end.
       end.
    end.
    if substring(g-log-char, 1, 4) = "qnty" then do:
          put stream err unformatted bar-str "," ENTRY(2, g-log-char, "=") skip.
          put stream log unformatted "***" mess " - не все количество зарезервировано" skip.
          put stream ler unformatted "***" mess " - не все количество зарезервировано" skip.
    end.
  end.
end.
os-delete value (scan-txt).
end procedure.
procedure store-place:
DEFine INPUT PARAMETER pl-str as CHAR NO-UNDO.
define input parameter parscales-pref as character no-undo.
define input parameter parpgscales-pref as character no-undo.
define variable pl-c as int no-undo.
define variable varres        as logical         no-undo.
define variable var-code-temp like ub.place.pl-code no-undo.
define variable varresult   as character       no-undo.
define variable vartype-bc  as character       no-undo.
define variable varweight   as decimal         no-undo.
define buffer pc-goods for ub.goods.
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  pl-str
,input  ?
,input  v-cntxt-obj-type
,input  v-cntxt-obj-code
,input  yes
,input  no
,input  parscales-pref
,input  parpgscales-pref
,output varresult
,output vartype-bc
,output varweight
,buffer ub.bar-code
,buffer ub.prod-bc
,buffer ub.place
) no-error.
if error-status:error then do:
  return error "Ошибка при разборе бар-кода: " + pl-str.
end.
if available place then do:
  find ub.bar-code where ub.bar-code.b-code  = b-c no-lock.
  find first pc-goods where pc-goods.gds-code  = ub.bar-code.gds-code no-lock.
  RUN plgdsfnd (input  no,
                input  v-cntxt-obj-type,
                input  v-cntxt-obj-code,
                input  pc-goods.gds-code,
                output varres,
                output var-code-temp) no-error.
  if varres = yes or error-status:error then do:
      put stream log unformatted "***" mess "Нельзя перемещать партии товара по складским местам "
          pc-goods.artic " " pc-goods.prod-type " " pc-goods.prod-code
          " по объкту " v-cntxt-obj-type " " v-cntxt-obj-code " "  skip.
      put stream ler unformatted "***" mess "Нельзя перемещать партии товара по складским местам "
          pc-goods.artic " " pc-goods.prod-type " " pc-goods.prod-code
          " по объкту " v-cntxt-obj-type " " v-cntxt-obj-code " "  skip.
      put stream err unformatted bar-str "," qnty-str "," pl-str skip.
  end.
  else
  for each ub.parts where ub.parts.obj-type  = v-cntxt-obj-type
                   and ub.parts.obj-code  = v-cntxt-obj-code
                   and ub.parts.artic     = pc-goods.artic
                   and ub.parts.prod-type = pc-goods.prod-type
                   and ub.parts.prod-code = pc-goods.prod-code
                   and ub.parts.in-code   = ub.bar-code.in-code
                   and ub.parts.part-code = ub.bar-code.part-code:
    if ub.parts.rsrv-free or
       ub.parts.out-code = t-doc.doc-code then ub.parts.pl-code = ub.place.pl-code.
  end.
end.
end procedure.
procedure plgdsfnd :
  define input  parameter p-chk-and-chs    as logical               no-undo .
  define input  parameter p-obj-type       like ub.gds-obj.obj-type no-undo .
  define input  parameter p-obj-code       like ub.gds-obj.obj-code no-undo .
  define input  parameter p-gds-code       like ub.goods.gds-code   no-undo .
  define output parameter p-reserv-pl-code as   logical             no-undo .
  define output parameter p-pl-code        like ub.pl-gds.pl-code   no-undo .
  define buffer buf_goods         for ub.goods .
  define buffer buf_pl-gds        for ub.pl-gds .
  define buffer buf_second_pl-gds for ub.pl-gds .
  find first buf_goods no-lock where
             buf_goods.gds-code = p-gds-code no-error .
  if not available buf_goods
  then do:
    return error "Не найден товар. Первичный бар-код " + string( p-gds-code ) .
  end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'place-rsrv=request'
  ,output p-reserv-pl-code
  ) no-error .
  if error-status :error
  then do:
    return error substitute("Ошибка при запросе атрибута place-rsrv товара на объекте  &1 &2 " , error-status :get-message(1) , return-value  )  .
  end.
  if p-reserv-pl-code = no
  then do:
    return .
  end.
  if p-chk-and-chs <> yes
  then do:
    return .
  end.
  find first buf_pl-gds no-lock where
             buf_pl-gds.obj-type = p-obj-type and
             buf_pl-gds.obj-code = p-obj-code and
             buf_pl-gds.gds-code = p-gds-code no-error .
  if not available buf_pl-gds
  then do:
    return error "К товару не привязано ни одного места хранения" .
  end.
  find first buf_second_pl-gds no-lock where
             buf_second_pl-gds.obj-type  = p-obj-type          and
             buf_second_pl-gds.obj-code  = p-obj-code          and
             buf_second_pl-gds.gds-code  = p-gds-code          and
             recid( buf_second_pl-gds ) <> recid( buf_pl-gds ) no-error .
  if not available buf_second_pl-gds
  then do:
    assign
      p-pl-code = buf_pl-gds.pl-code
    .
  end.
  else do:
    run str/plgdssel.p
      (
         input parparentproc
      ,  input p-obj-type
      ,  input p-obj-code
      ,  input p-gds-code
      , output p-pl-code
      ) no-error .
    if error-status :error
    then do:
      return error substitute( 'Ошибка при вызове программы &1&2&3&2&4&2'
                             , 'plgdssel.p':U
                             , chr(10)
                             , error-status :get-message( 1 )
                             , return-value
                             ) .
    end.
    if p-pl-code = ? or
       p-pl-code = 0
    then do:
      return error "Не выбрано место хранения " + chr(10) .
    end.
  end.
end procedure.
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-bar-code-ne no-undo
field nm            as integer
field mark          as character
field b-c           as integer
field scn-qnty-doc  as decimal
field scn-qnty-file as decimal
field mem-qnty      as decimal
field bef-qnty      as decimal
field artic         like ub.goods.artic
field prod-type     like ub.goods.prod-type
field prod-code     like ub.goods.prod-code
field gds-name      like ub.goods.gds-name
field node-name     like ub.gds-prt.node-name
field part-code     like ub.bar-code.part-code
field in-code       like ub.bar-code.in-code
index pi is primary nm
index b-c is unique b-c.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE TEMP-TABLE in-bc NO-UNDO
     FIELD nm        as INTEGER
     FIELD bar-str   AS CHARACTER
     FIELD bar-code  as CHARACTER
     FIELD rez       as CHARACTER
     FIELD err-msg   as CHARACTER
     FIELD des       as CHARACTER
     INDEX pi IS PRIMARY nm.
DEFINE new SHARED TEMP-TABLE un-bc NO-UNDO
     FIELD nm             as INTEGER
     FIELD bar-code       as CHARACTER
     FIELD entity         as character
     FIELD b-c            as INTEGER
     FIELD rate           as DECIMAL
     FIELD TYPE-bc        as CHARACTER
     FIELD wt             as DECIMAL
     FIELD file-qnty      as decimal
     FIELD scn-qnty       as DECIMAL
     FIELD scn-pl         as CHARACTER
     FIELD artic          LIKE ub.goods.artic
     FIELD prod-type      LIKE ub.goods.prod-type
     FIELD prod-code      LIKE ub.goods.prod-code
     FIELD gds-name       LIKE ub.goods.gds-name
     FIELD prod-name      LIKE ub.clients.obj-name
     FIELD unit-base      LIKE ub.goods.unit-base
     FIELD units-type     LIKE ub.units.type
     FIELD f-name         LIKE ub.gds-prt.f-name
     FIELD in-code        LIKE ub.parts.in-code
     FIELD fact-date      LIKE ub.parts.fact-date
     FIELD part-code      LIKE ub.parts.part-code
     FIELD rez            as CHARACTER
     FIELD err-msg        as CHARACTER
     FIELD des            as CHARACTER
     FIELD pl-name        AS CHARACTER
     FIELD loc1           AS CHARACTER
     FIELD loc2           AS CHARACTER
     FIELD loc3           AS CHARACTER
     FIELD loc4           AS CHARACTER
     FIELD unit-name      LIKE ub.units.unit-name
     FIELD long-name      LIKE ub.units.long-name
     FIELD b-c-base       LIKE ub.bar-code.b-code
     FIELD unit-name-base LIKE ub.units.unit-name
     FIELD long-name-base LIKE ub.units.long-name
     INDEX pi IS PRIMARY  nm
     INDEX bar-code bar-code
     INDEX b-c b-c
     INDEX file-qnty file-qnty.
DEFINE new SHARED TEMP-TABLE anlz-bc NO-UNDO
     FIELD nm       as INTEGER
     FIELD b-c      as integer
     FIELD scn-qnty as DECIMAL
     FIELD scn-pl   as CHARACTER
     FIELD rez      as CHARACTER
     FIELD err-msg  as CHARACTER
     FIELD des      as CHARACTER
     FIELD upd-line as logical initial no
     INDEX pi IS PRIMARY nm
     INDEX b-c b-c.
DEFINE new SHARED TEMP-TABLE main-bc NO-UNDO
     FIELD nm       as INTEGER
     FIELD b-c      as integer
     FIELD scn-qnty as DECIMAL
     FIELD scn-pl   as CHARACTER
     FIELD rez      as CHARACTER
     FIELD des      as CHARACTER
     INDEX pi IS PRIMARY nm
     INDEX b-c b-c.
define temp-table tt-bar-code-doc no-undo
field b-c      as integer
field scn-qnty as decimal
index pi is primary b-c.
define temp-table old-doc-line no-undo like doc-line.
define temp-table tt-chk-gds no-undo like ub.chk-gds.
define variable p-chk-gds-rid-list as character no-undo .
define variable p-call-handle  as handle no-undo .
define variable p-ii as integer no-undo .
define variable p-ii-ok as integer no-undo .
define variable v-curr-r-b  as character no-undo .
define variable cas-shft    as logical no-undo init no.
define variable chk-amount as integer.
define variable p-day-only  as logical no-undo .
define variable p-rid-list as character no-undo .
define variable p-is-all as logical no-undo init no.
define buffer X_chk-doc for ub.chk-doc.
DEFINE QUERY QUERY-chk-doc FOR X_chk-doc SCROLLING.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure proc-main :
define input parameter p-status_ like ub.trn-doc.status_ no-undo .
define input parameter p-flag_ as logical no-undo .
define input parameter p-direction as integer no-undo .
define variable accum-chk-doc-tot-doc as decimal no-undo.
define variable v-add as logical no-undo .
define variable glog as logical no-undo .
define variable action as character no-undo .
define variable v-rc-ii as integer no-undo initial 1.
define variable v-rc-max as integer no-undo .
define variable v-first as logical no-undo init yes .
define variable recid-line as recid no-undo .
define variable pl-str        as character no-undo.
define variable conf-par      as character no-undo.
define variable par-type      as character no-undo.
define variable varplace      as logical   no-undo.
define variable is-err        as logical   no-undo initial no .
define variable v-num         as integer   no-undo.
define variable v-user-action as character no-undo.
define variable v-printed     as logical   no-undo.
define variable varerr        as logical   no-undo.
define variable varanlz       as logical   no-undo.
define variable varlog        as logical   no-undo.
define variable varvalue      as character no-undo.
define variable vartype       as character no-undo.
define variable varline-file  as character no-undo.
define variable scan-name     as character no-undo.
define variable varnoapnd     as logical   no-undo .
define variable ii            as integer   no-undo.
define variable jj            as integer   no-undo.
define variable v-chk-type    as character no-undo .
define variable v-to-inc      as logical   no-undo .
define variable v-direction   as integer   no-undo .
define variable v-query-prepare as character no-undo .
define variable v-mode        as character no-undo .
define variable v-is-petrolium as logical no-undo.
define variable v-is-pieces as logical no-undo.
define buffer bb_doc-line for ub.doc-line.
define buffer bb_gds-prt  for ub.gds-prt.
define buffer bb_goods    for ub.goods.
define buffer bb_gds-dtl  for ub.gds-dtl.
define buffer bb_bar-code for ub.bar-code.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_c-chk-doc for ub.c-chk-doc.
define buffer buf_c-chk-gds for ub.c-chk-gds.
define buffer buf_c-chk-pay for ub.c-chk-pay.
define buffer buf_c-chk-discnt for ub.c-chk-discnt.
define buffer buf_c-chk-doc-attr for ub.c-chk-doc-attr.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_tt-chk-gds for tt-chk-gds.
_main:
do
on error undo, return error return-value
:
  for each in-bc on error undo _main, return error return-value :
    delete in-bc.
  end.
  for each un-bc on error undo _main, return error return-value :
    delete un-bc.
  end.
  for each main-bc on error undo _main, return error return-value :
    delete main-bc.
  end.
  for each anlz-bc on error undo _main, return error return-value :
    delete anlz-bc.
  end.
  scan-name = substitute("&1-чеки", t-doc.doc-code).
  find first ub.sysconf no-lock where
            ub.sysconf.host-code = t-doc.host-code .
  g-type = if t-doc.office then 'у':U else 'т':U.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'nakl-glob':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'noapndsc' then varnoapnd = thbjattr_thbj-attr.property-value-logical  .
end.
  if varnoapnd  then do:
    output stream log to value (scan-name + ".log").
    output stream err to value (scan-name + ".err").
    output stream ler to value (scan-name + ".ler").
  end.
  else do:
    output stream log to value (scan-name + ".log") append.
    output stream err to value (scan-name + ".err") append.
    output stream ler to value (scan-name + ".ler") append.
  end.
  put stream log unformatted "  " skip.
  put stream log unformatted cur-time-string-sec() skip.
  put stream ler unformatted "  " skip.
  put stream ler unformatted cur-time-string-sec() skip.
  if add-sens = ? then
    put stream log unformatted " " skip skip "Привязка партий к складским местам.  Объект : " v-cntxt-obj-type " " string (v-cntxt-obj-code) skip skip.
  else do:
    put stream log unformatted " " skip skip "Накладная: " t-doc.doc-code
          " Тип: " t-doc.doc-type string (t-doc.internal, "внутр/внешн") " Статус: " p-status_ " ОК: " string (p-flag_, "+/-") skip skip.
    put stream ler unformatted " " skip skip "Накладная: " t-doc.doc-code
          " Тип: " t-doc.doc-type string (t-doc.internal, "внутр/внешн") " Статус: " p-status_ " ОК: " string (p-flag_, "+/-") skip skip.
    find first buf_doc-line where
              buf_doc-line.doc-code = t-doc.doc-code no-lock no-error.
    if available buf_doc-line then do:
      find first buf_goods where
               buf_goods.artic = buf_doc-line.artic
           and buf_goods.prod-type = buf_doc-line.prod-type
           and buf_goods.prod-code = buf_doc-line.prod-code no-lock.
      g-type =  buf_goods.gds-type.
    end.
  end.
  if p-status_  = 'разрешен':U and
    add-sens       = ?            then do:
    return.
  end.
  if p-status_  = 'разрешен':U
    or (p-status_ = 'разрешен':U
        and p-flag_ = yes
        and p-direction = 1
        )
    then do:
    put stream log unformatted " " skip skip "!!! Инвентаризация: " t-doc.doc-code
          " подсчет суммарных количеств для одинаковых кодов." skip skip.
  end.
  assign
  accum-chk-doc-tot-doc = 0
  v-rc-max = (if p-rid-list <> '':U then num-entries(p-rid-list) else 1)
  v-rc-ii = (if p-rid-list <> '':U
             then (if available X_chk-doc
                   then lookup(string(recid(X_chk-doc)), p-rid-list)
                   else v-rc-ii)
             else v-rc-ii)
  .
  if (p-status_ = 'разрешен':U
  and p-direction = -1)
  then do:
    ASSIGN
    v-query-prepare = substitute("for each X_chk-doc no-lock where X_chk-doc.out-code = '&1'":U, t-doc.doc-code).
    assign
    glog = QUERY query-chk-doc:QUERY-PREPARE(v-query-prepare) No-error.
    IF not glog
    THEN DO:
      undo, return error substitute("Ошибка при построении запроса по чекам инвентаризации:&1&2&1&3"
                                    , chr(10)
                                    , error-status:get-message(1)
                                    , return-value ).
    END.
    assign
    glog = QUERY query-chk-doc:query-OPEN() NO-ERROR.
    IF not glog
    THEN DO:
      undo, return error substitute("Ошибка при открытии запроса по чекам инвентаризации:&1&2&1&3"
                                    , chr(10)
                                    , error-status:get-message(1)
                                    , return-value ).
    END.
    ASSIGN
    glog = QUERY query-chk-doc:GET-FIRST(no-LOCK) NO-ERROR.
    IF not glog THEN DO:
      RETURN.
    END.
    ASSIGN
    glog = QUERY query-chk-doc:GET-FIRST(exclusive-LOCK, no-wait) NO-ERROR.
    do while locked (X_chk-doc ) and available X_chk-doc:
      glog = QUERY query-chk-doc:GET-NEXT(exclusive-LOCK, no-wait) NO-ERROR.
    end.
  end.
  c-d:
  DO WHILE available X_chk-doc or (p-rid-list <> '':U and  v-rc-ii <= v-rc-max) or action = "next"
  on error undo c-d, NEXT c-d
  on stop undo c-d, NEXT c-d:
    action = '':U.
    if not v-first then do:
      if p-rid-list = "":U then do:
        ASSIGN
        glog = QUERY query-chk-doc:GET-next(no-LOCK) NO-ERROR.
        if available X_chk-doc then do:
          ASSIGN
          glog = QUERY query-chk-doc:GET-current(exclusive-LOCK, no-wait) NO-ERROR.
          if locked(X_chk-doc) then do:
            error-status:error = no.
            action = "next".
            next c-d.
          end.
        end.
      end.
      else do:
        assign
        v-rc-ii = v-rc-ii + 1.
        _v-rc:
        do while v-rc-ii <= v-rc-max:
          find first X_chk-doc exclusive-lock where
                    recid(X_chk-doc) = integer(entry(v-rc-ii, p-rid-list))  no-error  NO-WAIT.
          if locked X_chk-doc or not available X_chk-doc then do:
            assign
            v-rc-ii = v-rc-ii + 1.
            next _v-rc.
          end.
          else LEAVE _v-rc.
        end.
        if v-rc-ii > v-rc-max then release X_chk-doc.
      end.
      if (not available X_chk-doc and action = '':U)
      or (p-rid-list <> "":U and v-rc-ii > v-rc-max) then LEAVE c-d.
    end.
    if v-first then v-first = no.
    if lookup(string(X_chk-doc.chk-type), '11':U) = 0 then next c-d.
    if X_chk-doc.out-code = ? then do:
      assign
      v-chk-type = replace(X_chk-doc.office, '0', '':U)
      v-chk-type = replace(v-chk-type, chr(44) + chr(44), chr(44))
      v-chk-type = trim(v-chk-type, chr(44))
      .
      if (v-chk-type <> g-type or v-chk-type = ?)
      then do:
        NEXT c-d .
      end.
      if  v-chk-type <> g-type
      and v-chk-type <> '':U then do:
        NEXT c-d .
      end.
      assign
      p-ii = p-ii + 1
      .
      if p-ii < 10
      or (p-ii < 1000 and chk-amount modulo 10 = 0)
      or (p-ii < 10000 and chk-amount modulo 100 = 0)
      then do:
        run display-chk in p-call-handle ( input chk-amount).
      end.
    end.
    if entry(1, X_chk-doc.doc-num, chr(4)) = t-doc.doc-code then do:
      run display-message in p-call-handle ( input substitute("Чек &1 уже был обсчитан&2" +
                                                                 "Если в нем остались необсчитанные товары,&2" +
                                                                 "Их может обсчитать потоварно"
                                                                 , X_chk-doc.doc-code
                                                                 , chr(10))).
    end.
    if X_chk-doc.out-code = ?
    then do:
      assign
      v-to-inc = yes.
    end.
    else do:
      assign
      v-to-inc = no.
    end.
    if X_chk-doc.out-code = t-doc.doc-code
    and p-status_ = 'разрешен':U
    and p-flag_ = yes
    and p-direction = 1
    and p-chk-gds-rid-list = '':U
    then do:
      assign
      v-direction = p-direction.
    end.
    else do:
      assign
      v-direction = 0.
    end.
    _one-check:
    do
    on error undo _one-check, leave _one-check
    on stop undo _one-check, leave _one-check
    :
      _buf_chk-gds:
      FOR EACH buf_chk-gds WHERE buf_chk-gds.doc-code = X_chk-doc.doc-code
      on error undo _one-check, LEAVE _one-check
      on stop undo _one-check, leave _one-check
      :
        if p-chk-gds-rid-list <> "":U
        and lookup(string(recid(buf_chk-gds)), p-chk-gds-rid-list) = 0 then next _buf_Chk-gds.
        if p-chk-gds-rid-list <> "":U then do:
          if p-status_ = 'разрешен':U
          and p-flag_ = yes
          and p-direction = 1
          then do:
            assign
            v-direction = p-direction.
          end.
          else do:
            assign
            v-direction = 0.
          end.
        end.
        assign
        buf_chk-gds.is-error = (if buf_chk-gds.out-code = ?
                                then yes
                                else (if p-status_ = 'разрешен':U
                                      and p-flag_ = yes
                                      and p-direction = -1
                                      then yes
                                      else buf_chk-gds.is-error)
                               )
        buf_chk-gds.out-code = (if buf_chk-gds.out-code = ?
                                then t-doc.doc-code
                                else buf_chk-gds.out-code)
        .
        if buf_chk-gds.doc-qnty = 0 then do:
          buf_chk-gds.is-err = no.
          NEXT _Buf_chk-gds.
        end.
        if buf_chk-gds.is-error = no then do:
          NEXT _Buf_chk-gds.
        end.
        if p-status_ = 'накл':U
        and p-flag_ <> yes
        then do:
          FIND FIRST buf_bar-code WHERE
                   buf_bar-code.b-code = buf_chk-gds.b-code NO-LOCK NO-ERROR.
          if not avail buf_bar-code then do:
            next _buf_chk-gds.
          end.
          FIND FIRST buf_goods WHERE
                    buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_adinvlin in g#lib-trn3
(input  parparentproc
,input  t-doc.doc-code
,input  buf_goods.artic
,input  buf_goods.prod-type
,input  buf_goods.prod-code
,output recid-line
) no-error.
          if error-status:error then do:
            buf_chk-gds.is-err = yes.
          end.
          find first buf_doc-line where recid(buf_doc-line) = recid-line exclusive-lock.
          buf_doc-line.prt-OK = ?.
          buf_chk-gds.is-err = yes.
        end.
        assign
        buf_chk-gds.line-type = entry(1, buf_chk-gds.line-type) + chr(4) + 'vt':U
        .
        if not v-to-inc
        and p-direction = 1
        then do:
          create buf_tt-chk-gds.
          buffer-copy buf_chk-gds to buf_tt-chk-gds.
          release buf_tt-chk-gds.
        end.
      END .
      if not v-to-inc
      and p-direction = 1
      and not can-find(first tt-chk-gds) then do:
        leave _one-check.
      end.
      if v-to-inc then do:
        for each buf_c-chk-doc where
                buf_c-chk-doc.doc-code = X_chk-doc.doc-code:
          assign
          buf_c-chk-doc.out-code = t-doc.doc-code
          .
        end.
        for each buf_c-chk-gds where
                buf_c-chk-gds.doc-code = X_chk-doc.doc-code:
          assign
          buf_c-chk-gds.out-code = t-doc.doc-code
          .
        end.
        for each buf_c-chk-discnt where
                buf_c-chk-discnt.doc-code = X_chk-doc.doc-code:
          assign
          buf_c-chk-discnt.out-code = t-doc.doc-code
          .
        end.
        for each buf_c-chk-pay where
                buf_c-chk-pay.doc-code = X_chk-doc.doc-code:
          assign
          buf_c-chk-pay.out-code = t-doc.doc-code
          .
        end.
        for each buf_c-chk-doc-attr where
                buf_c-chk-doc-attr.doc-code = X_chk-doc.doc-code:
          assign
          buf_c-chk-doc-attr.out-code = t-doc.doc-code
          .
        end.
        assign
        X_chk-doc.out-code = t-doc.doc-code
        chk-amount = chk-amount + 1
        accum-chk-doc-tot-doc = accum-chk-doc-tot-doc  + X_chk-doc.tot-doc
        .
      end.
      if p-status_ = 'накл':U
      and p-flag_   <> yes then do:
      end.
      if (p-status_ = 'разрешен':U
      and p-flag_ = yes
      and p-direction = 1)
      or p-status_ = 'разрешен':U
      then do:
        find first tt-chk-gds no-error.
        repeat while v-to-inc
        or v-direction = 1
        or can-find (first tt-chk-gds)
        :
          find first tt-chk-gds no-error.
          if p-chk-gds-rid-list <> '':U then do:
            for each un-bc on error undo _main, return error return-value :
              delete un-bc.
            end.
            for each anlz-bc on error undo _main, return error return-value :
              delete anlz-bc.
            end.
          end.
          run str/bc-anlz.p (
                         input parparentproc
                        ,input "chk-doc"
                        ,input  (if v-to-inc or (v-direction = 1 and not available tt-chk-gds)
                                then X_chk-doc.doc-code
                                else (X_chk-doc.doc-code + chr(44) + string(tt-chk-gds.line-num))
                                )
                        ,input yes
                        ,output varerr
                        ,output table in-bc ) no-error .
          if error-status:error then do:
          end.
          if varerr = yes then is-err = yes.
          if available tt-chk-gds then delete tt-chk-gds.
          find first tt-chk-gds no-error .
          if v-to-inc then v-to-inc = no.
          if v-direction = 1 then v-direction = 0.
          if p-chk-gds-rid-list <> '':U then do:
            define variable vari    as integer no-undo.
            define variable vartime as integer no-undo.
            for each un-bc on error undo, return error return-value :
                assign
                  vari = vari + 1.
                run display-message in p-call-handle ( INPUT substitute("Записываем ошибки разбора чека инвентаризации в файлы. Всего проверено на ошибки &1. Время &2.", vari, string (time - vartime, "hh:mm:ss"))).
                if un-bc.rez = "err" then do:
                  put stream log unformatted un-bc.err-msg skip.
                  put stream ler unformatted un-bc.err-msg skip.
                  put stream err unformatted un-bc.bar-code ", " un-bc.file-qnty skip.
                  assign is-err = yes.
                end.
            end.
            run waitfram-hide in this-procedure.
          end.
        end.
      end.
      assign
      p-ii-ok = p-ii-ok + 1
      .
    end.
    if p-status_ = 'разрешен':U
    and p-chk-gds-rid-list = '':U then do:
      entry(1, X_chk-doc.doc-num, chr(4)) = t-doc.doc-code.
    end.
    if p-status_ = 'разрешен':U
    and p-direction = - 1
    and p-chk-gds-rid-list = '':U then do:
      entry(1, X_chk-doc.doc-num, chr(4)) = '':U.
    end.
  END.
  run display-message in p-call-handle ( input "Записываем результат разбора чека инвентаризации файла в log-файл.").
  assign
    vari    = 0.
    vartime = time.
  if p-chk-gds-rid-list = '':U then do:
    for each un-bc on error undo, return error return-value :
        assign
          vari = vari + 1.
        run waitfram-show in this-procedure (substitute("Записываем ошибки разбора чека инвентаризации в файлы. Всего проверено на ошибки &1. Время &2.", vari, string (time - vartime, "hh:mm:ss"))).
        if un-bc.rez = "err" then do:
          put stream log unformatted un-bc.err-msg skip.
          put stream ler unformatted un-bc.err-msg skip.
          put stream err unformatted un-bc.bar-code ", " un-bc.file-qnty skip.
          assign is-err = yes.
        end.
    end.
  end.
  run waitfram-hide in this-procedure.
  _main-bc:
  for each main-bc on error undo, return error return-value :
    assign
    ii = i
    ii = ii + 1
    i = ii
    .
    run display-processed in p-call-handle ( input ii).
    find first ub.bar-code where ub.bar-code.b-code   = main-bc.b-c        no-lock.
    find first ub.goods    where ub.goods.gds-code    = ub.bar-code.gds-code  no-lock.
    find first ub.gds-prt  where ub.gds-prt.node-code = ub.bar-code.node-code no-lock.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input ub.goods.artic
  ,  input ub.goods.prod-type
  ,  input ub.goods.prod-code
  , output v-is-petrolium
  , output v-is-pieces
  ) .
    if v-is-petrolium = yes and
      v-is-pieces    = no  then do:
      message "Товар " goods.artic " " goods.prod-type " " goods.prod-code " является жидким топливом." skip
              "Товар нельзя добавить из чека."
      view-as alert-box error.
      put stream log unformatted "Бар-код " bar-code.b-code " принадлежит жидкому топливу - нельзя добавить из чека." skip.
      put stream ler unformatted "Бар-код " bar-code.b-code " принадлежит жидкому топливу - нельзя добавить из чека." skip.
      put stream err unformatted main-bc.b-c ", " main-bc.scn-qnty skip.
      assign is-err = yes.
      next.
    end.
    if gds-prt.is-term <> yes then do:
      put stream log unformatted "Бар-код " bar-code.b-code " не является кодом терминального признака." skip.
      put stream ler unformatted "Бар-код " bar-code.b-code " не является кодом терминального признака." skip.
      put stream err unformatted main-bc.b-c ", " main-bc.scn-qnty skip.
      assign is-err = yes.
      next.
    end.
    assign bar-str  = string(main-bc.b-c)
          qnty-str = string(main-bc.scn-qnty)
          rate     = 1
          pl-str   = main-bc.scn-pl
          mess     = main-bc.des.
    find first buf_doc-line no-lock where
              buf_doc-line.artic = goods.artic
          and buf_doc-line.prod-type = goods.prod-type
          and buf_doc-line.prod-code = goods.prod-code
          and buf_doc-line.doc-code = t-doc.doc-code
          no-error.
    run proc-code in this-procedure ( input main-bc.scn-pl
                                      ,input (if main-bc.rez = "place" then "place" else "")
                                      ,input varscales-pref
                                      ,input varpgscales-pref
                                      ) no-error.
    if error-status:error then do:
      assign is-err = yes.
    end.
    else do:
      assign
      jj = j
      jj = jj + 1
      j = jj
      .
      run display-processed-ok in p-call-handle ( input jj).
    end.
  end.
  output stream log close.
  output stream err close.
  output stream ler close.
  if is-err then do:
      message "Во время загрузки чеков:" scan-txt "обнаружены ошибки." skip
              "Смотрите ler файл."
      view-as alert-box error buttons ok.
      if search (scan-name + ".ler") <> ? then do:
        run gbl/prnfilen.w (
           input  substitute("Ошибки, обнаруженные во время загрузки чеков")
          ,input  0
          ,input  scan-name + ".ler"
          ,input  7
          ,output v-user-action
          ,output v-printed
          ).
      end.
  end.
  run display-chk in p-call-handle ( input chk-amount ).
end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref-type12 as character no-undo.
varscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref
  ,output varscales-pref-type12
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type12 as character no-undo.
varpgscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref
  ,output varpgscales-pref-type12
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
p-call-handle  = this-procedure:handle .
is-all = no.
run proc-main in this-procedure ( input t-doc.status_, input t-doc.flag, input p-direction ) no-error .
if error-status:error then undo, return error return-value .
procedure proc-next-c-d :
  do
  on error undo, return error
  :
  end.
end procedure.
procedure display-chk :
define input parameter p-chk-amount as integer no-undo .
  do
  on error undo, return error
  :
  end.
end procedure.
procedure  display-processed:
define input parameter p-ii as integer no-undo .
  do
  on error undo, return error
  :
  end.
end procedure.
procedure display-processed-ok :
define input parameter p-ii-ok as integer no-undo .
  do
  on error undo, return error
  :
  end.
end procedure.
procedure display-message :
define input parameter p-message as character no-undo .
  do
  on error undo, return error
  :
  end.
end procedure.
