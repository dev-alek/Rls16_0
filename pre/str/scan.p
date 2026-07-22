block-level on error undo, throw.
define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter add-sens  as logical no-undo.
define input  parameter p-doc-rec as recid no-undo .
define input  parameter p-name-file as character no-undo .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: scan.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/scan.p $":U .
define variable vss-description as character no-undo initial "Единая процедура работы с мобильным сканером":U .
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define buffer t-doc for ub.trn-doc.
define variable bar-str       as character no-undo.
define variable pl-str        as character no-undo.
define variable qnty-str      as character no-undo.
define variable part-list     as character no-undo initial "".
define variable b-c           as integer   no-undo.
define variable rate          as decimal   no-undo.
define variable varplace      as logical   no-undo.
define variable is-err        as logical   no-undo initial no .
define variable v-num         as integer   no-undo.
define variable is-all        as logical   no-undo.
define variable i             as integer   no-undo.
define variable j             as integer   no-undo.
define variable v-user-action as character no-undo.
define variable v-printed     as logical   no-undo.
define variable varerr        as logical   no-undo.
define variable varanlz       as logical   no-undo.
define variable varlog        as logical   no-undo.
define variable varvalue      as character no-undo.
define variable vartype       as character no-undo.
define variable varline-file  as character no-undo.
define variable scan-txt      as character no-undo.
define variable scan-name     as character no-undo.
define variable g-type        as character no-undo init ?.
define variable varnoapnd     as logical   no-undo .
define variable line-mode as character no-undo init ? .
define variable varis-petrolium as logical no-undo.
define variable varis-pieces as logical no-undo.
define variable v-silent as logical   no-undo init false .
define variable v-upperhandl as handle no-undo .
define variable v1 as character no-undo .
define variable v2 as character no-undo .
define variable v-pri-nakl- as logical   no-undo .
define variable v-first-del as logical   no-undo .
if num-entries(p-name-file, chr(4)) >= 2 then do:
  assign
    v1 = entry(1,p-name-file, chr(4))
    v2 = entry(2,p-name-file, chr(4))
    no-error
    .
   if error-status :error then
   assign
     v1 = p-name-file
     v2 = ?
   .
   v-upperhandl = widget-handle(v2) .
   p-name-file  = v1.
end.
find first t-doc no-lock where recid(t-doc) = p-doc-rec no-error .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type8 as character no-undo.
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
  ,output varscales-pref-type8
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type8 as character no-undo.
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
  ,output varpgscales-pref-type8
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
define temp-table old-doc-line no-undo like ub.doc-line.
define stream cur.
define stream log.
define stream ler.
define stream err.
define buffer bb_doc-line for ub.doc-line.
define buffer bb_gds-prt  for ub.gds-prt.
define buffer bb_goods    for ub.goods.
define buffer bb_gds-dtl  for ub.gds-dtl.
define buffer bb_bar-code for ub.bar-code.
define temp-table tt-bar-code-doc no-undo
field b-c      as integer
field scn-qnty as decimal
index pi is primary b-c.
def var vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if p-name-file = ? then do:
system-dialog get-file scan-txt
  title "Выберите файл со сканера"
       filters "WorkAbout MS15"         "*.dbs",
               "WorkAbout"              "*.imp",
               "Инвентаризация с кассы" "*.inv",
               "Все файлы"               "*.*"
       update varlog.
if not varlog then return error.
end.
else do:
  scan-txt = p-name-file.
end.
if entry (2, scan-txt, ".") = "log" then do:
  message "Файл с расширением '.log' не может быть обработан. Переименуйте его.".
  return error.
end.
if entry (2, scan-txt, ".") = "err" then do:
  message "Файл с расширением '.err' не может быть обработан. Переименуйте его.".
  return error.
end.
if entry (2, scan-txt, ".") = "ler" then do:
  message "Файл с расширением '.ler' не может быть обработан. Переименуйте его.".
  return error.
end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'scanfile':U ,
                       output varvalue ,
                       output vartype ) no-error .
if lookup (scan-txt, varvalue) <> 0 then do:
  message "Файл с названием " scan-txt " уже загружался в документ " t-doc.doc-code " ." skip
          "Продолжить?" view-as alert-box question buttons yes-no update varlog.
  if varlog <> yes then do:
    return error.
  end.
end.
else do:
  assign
    varline-file = varvalue + min (",", varvalue) + scan-txt no-error.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'scanfile':U ,
                       input varline-file ) no-error .
end.
  assign
    v-pri-nakl- = false
    v-silent    = false
    v-first-del = false
  .
  run cb_is-silent in v-upperhandl (output v-silent )  no-error .
  if v-silent then do:
     v-num = 1.
  end.
  else do:
    if t-doc.ext-doc-type = 'ie':U
      and t-doc.status_  = 'накл':U
      and t-doc.flag_    = no
    then do:
      assign
        v-pri-nakl- = true
      .
    end.
    run gbl/d-askw.w
      ( input "Вопрос"
      , input "Выберите режим работы для обработки файла." + chr(10)
      , input "|^"
      , input "Переписать|Прибавить|Спрашивать|"
             + (if v-pri-nakl- = true then "Обнулить|" else "":U)
             + "Отмена"
      , input "Переписать количество со сканера для всех товаров|"
            + "Прибавить количество со сканера для всех товаров|"
            + "Cпрашивать для каждого товара|"
            + (if v-pri-nakl- = true then "Удалить все строки и загрузить со сканера|" else "":U)
            + "Отменить"
      , input 1
      , input (if v-pri-nakl- = true then 5 else 4 )
      , output v-num
      ).
  end.
  case v-num :
    when 1 then do:
      assign is-all = yes.
    end.
    when 2 then do:
      assign is-all = no.
    end.
    when 3 then do:
      assign is-all = ?.
    end.
    when 4 then do:
      if v-pri-nakl- = true then do:
        assign
          is-all = yes
          v-first-del = true
        .
      end.
      else do:
        return error.
      end.
    end.
    otherwise do:
      return error.
    end.
  end case.
scan-name = entry (1, scan-txt, ".").
frame a :title = "Разбор файла : " + scan-txt.
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
if varnoapnd then do:
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
        " Тип: " t-doc.doc-type string (t-doc.internal, "внутр/внешн") " Статус: " t-doc.status_ " ОК: " string (t-doc.flag_, "+/-") skip skip.
  put stream ler unformatted " " skip skip "Накладная: " t-doc.doc-code
        " Тип: " t-doc.doc-type string (t-doc.internal, "внутр/внешн") " Статус: " t-doc.status_ " ОК: " string (t-doc.flag_, "+/-") skip skip.
  find first doc-line where doc-line.doc-code = t-doc.doc-code no-lock no-error.
  if available doc-line then do:
    find goods where goods.artic = doc-line.artic
                 and goods.prod-type = doc-line.prod-type
                 and goods.prod-code = doc-line.prod-code no-lock.
    g-type =  goods.gds-type.
  end.
end.
view frame a.
input stream cur from value (scan-txt).
if t-doc.doc-type = 'инв':U and
   t-doc.status_  = 'разрешен':U and
   add-sens       = ?            then do:
  return.
end.
if t-doc.doc-type = 'инв':U and
   t-doc.status_  = 'разрешен':U then do:
  put stream log unformatted " " skip skip "!!! Инвентаризация: " t-doc.doc-code
        " подсчет суммарных количеств для одинаковых кодов." skip skip.
end.
else do:
  put stream log unformatted " " skip skip "!!! Складской документ: " t-doc.doc-code
        " подсчет суммарных количеств для одинаковых кодов." skip skip.
end.
for each un-bc on error undo, return error return-value :
    delete un-bc.
end.
run str/bc-anlz.p (parParentProc , "file", scan-txt, yes, output varerr, output table in-bc) no-error.
if error-status:error then do:
   message "Ошибка при обработке файла сканера." skip
           error-status:get-message(1)
      view-as alert-box error buttons ok.
   return error.
end.
if varerr = yes then is-err = yes.
define variable vari    as integer no-undo.
define variable vartime as integer no-undo.
run waitfram-show in this-procedure ("Записываем результат разбора сканерного файла в log-файл.").
assign
  vari    = 0.
  vartime = time.
for each in-bc on error undo, return error return-value :
    assign
      vari = vari + 1.
    run waitfram-show in this-procedure (substitute("Записываем ошибки разбора сканерного файла в файлы. Всего проверено на ошибки &1. Время &2.", vari, string (time - vartime, "hh:mm:ss"))).
    if in-bc.rez = "err" then do:
       put stream log unformatted in-bc.err-msg skip.
       put stream ler unformatted in-bc.err-msg skip.
       put stream err unformatted in-bc.bar-str skip.
       assign is-err = yes.
    end.
    if in-bc.des <> "" and in-bc.des <> ? then put stream log unformatted in-bc.des.
end.
for each un-bc on error undo, return error return-value :
    assign
      vari = vari + 1.
    run waitfram-show in this-procedure (substitute("Записываем ошибки разбора сканерного файла в файлы. Всего проверено на ошибки &1. Время &2.", vari, string (time - vartime, "hh:mm:ss"))).
    if un-bc.rez = "err" then do:
       put stream log unformatted un-bc.err-msg skip.
       put stream ler unformatted un-bc.err-msg skip.
       put stream err unformatted un-bc.bar-code ", " un-bc.file-qnty skip.
       assign is-err = yes.
    end.
end.
if v-first-del = true then do:
  for each bb_doc-line
    where bb_doc-line.doc-code = t-doc.doc-code
  on error undo, return error return-value
  :
    delete bb_doc-line .
  end.
end.
if t-doc.doc-type = 'при':U
  and t-doc.status_  = 'накл':U
  and t-doc.flag_    = yes
then do:
  run waitfram-show in this-procedure ("Строим таблицу сравнения по загруженой информации из файла.").
  for each bb_doc-line where bb_doc-line.doc-code = t-doc.doc-code no-lock on error undo, return error return-value :
    find first bb_goods where bb_goods.artic     = bb_doc-line.artic     and
                              bb_goods.prod-type = bb_doc-line.prod-type and
                              bb_goods.prod-code = bb_doc-line.prod-code no-lock.
    find first bb_gds-prt where bb_gds-prt.upper-code = bb_goods.prt-root no-lock.
    if bb_gds-prt.node-name = '_Пустая шкала':U then do:
      find first bb_bar-code where bb_bar-code.gds-code  = bb_goods.gds-code    and
                                   bb_bar-code.node-code = bb_gds-prt.node-code and
                                   bb_bar-code.part-code = ""                   and
                                   bb_bar-code.in-code   = ""                   and
                                   bb_bar-code.unit-cli  = bb_goods.unit-base   no-lock.
      create tt-bar-code-doc.
      assign
        tt-bar-code-doc.b-c      = bb_bar-code.b-code
        tt-bar-code-doc.scn-qnty = bb_doc-line.doc-qnty.
      create tt-bar-code-ne.
      assign
        tt-bar-code-ne.nm            = 0
        tt-bar-code-ne.mark          = "d"
        tt-bar-code-ne.b-c           = bb_bar-code.b-code
        tt-bar-code-ne.scn-qnty-doc  = bb_doc-line.doc-qnty
        tt-bar-code-ne.scn-qnty-file = 0
        tt-bar-code-ne.artic         = bb_goods.artic
        tt-bar-code-ne.prod-type     = bb_goods.prod-type
        tt-bar-code-ne.prod-code     = bb_goods.prod-code
        tt-bar-code-ne.gds-name      = bb_goods.gds-name
        tt-bar-code-ne.node-name     = "--------------------"
        tt-bar-code-ne.in-code       = ""
        tt-bar-code-ne.part-code     = "".
    end.
    else do:
      for each bb_gds-dtl where bb_gds-dtl.doc-code  = bb_doc-line.doc-code  and
                                bb_gds-dtl.artic     = bb_doc-line.artic     and
                                bb_gds-dtl.prod-type = bb_doc-line.prod-type and
                                bb_gds-dtl.prod-code = bb_doc-line.prod-code no-lock on error undo, return error return-value :
         find first bb_gds-prt where bb_gds-prt.node-code = bb_gds-dtl.prt-code no-lock.
         find first bb_bar-code where bb_bar-code.gds-code  = bb_goods.gds-code    and
                                      bb_bar-code.node-code = bb_gds-prt.node-code and
                                      bb_bar-code.part-code = ""                   and
                                      bb_bar-code.in-code   = ""                   and
                                      bb_bar-code.unit-cli  = bb_goods.unit-base   no-lock.
         create tt-bar-code-doc.
         assign
           tt-bar-code-doc.b-c      = bb_bar-code.b-code
           tt-bar-code-doc.scn-qnty = bb_doc-line.doc-qnty.
         create tt-bar-code-ne.
         assign
           tt-bar-code-ne.nm            = 0
           tt-bar-code-ne.mark          = "d"
           tt-bar-code-ne.b-c           = bb_bar-code.b-code
           tt-bar-code-ne.scn-qnty-doc  = bb_gds-dtl.doc-qnty
           tt-bar-code-ne.scn-qnty-file = 0
           tt-bar-code-ne.artic         = bb_goods.artic
           tt-bar-code-ne.prod-type     = bb_goods.prod-type
           tt-bar-code-ne.prod-code     = bb_goods.prod-code
           tt-bar-code-ne.gds-name      = bb_goods.gds-name
           tt-bar-code-ne.node-name     = bb_gds-prt.node-name
           tt-bar-code-ne.in-code       = ""
           tt-bar-code-ne.part-code     = "".
      end.
    end.
  end.
  assign
    varanlz = yes.
  for each main-bc on error undo, return error return-value :
    if main-bc.scn-pl <> "" then do:
      assign
        varanlz = no.
    end.
    find first bb_bar-code where bb_bar-code.b-code = main-bc.b-c no-lock.
    if bb_bar-code.in-code   <> "" or
       bb_bar-code.part-code <> "" then do:
       message "В файле экспорте есть бар-код, cоответствующий бар-коду партии " bb_bar-code.b-code " ." skip
               "По данному бар-коду невозможно произвести сравнительный анализ. Он будет выведен отдельной строкой в таблицу анализа."
       view-as alert-box.
    end.
    find first tt-bar-code-ne where tt-bar-code-ne.b-c = bb_bar-code.b-code no-error.
    if not available tt-bar-code-ne then do:
      find first bb_goods where bb_goods.gds-code = bb_bar-code.gds-code no-lock.
      find first bb_gds-prt where bb_gds-prt.upper-code = bb_goods.prt-root no-lock.
      create tt-bar-code-ne.
      if bb_gds-prt.node-name = '_Пустая шкала':U then do:
        assign
          tt-bar-code-ne.nm            = -1
          tt-bar-code-ne.mark          = (if bb_bar-code.in-code <> "" or bb_bar-code.part-code <> "" then "?" else "f")
          tt-bar-code-ne.b-c           = bb_bar-code.b-code
          tt-bar-code-ne.scn-qnty-doc  = 0
          tt-bar-code-ne.scn-qnty-file = main-bc.scn-qnty
          tt-bar-code-ne.artic         = bb_goods.artic
          tt-bar-code-ne.prod-type     = bb_goods.prod-type
          tt-bar-code-ne.prod-code     = bb_goods.prod-code
          tt-bar-code-ne.gds-name      = bb_goods.gds-name
          tt-bar-code-ne.node-name     = "------------------"
          tt-bar-code-ne.in-code       = bb_bar-code.in-code
          tt-bar-code-ne.part-code     = bb_bar-code.part-code.
      end.
      else do:
        find first bb_gds-prt where bb_gds-prt.node-code = bb_bar-code.node-code no-lock.
        assign
          tt-bar-code-ne.nm            = main-bc.nm
          tt-bar-code-ne.mark          = (if bb_bar-code.in-code <> "" or bb_bar-code.part-code <> "" then "?" else "f")
          tt-bar-code-ne.b-c           = bb_bar-code.b-code
          tt-bar-code-ne.scn-qnty-doc  = 0
          tt-bar-code-ne.scn-qnty-file = main-bc.scn-qnty
          tt-bar-code-ne.artic         = bb_goods.artic
          tt-bar-code-ne.prod-type     = bb_goods.prod-type
          tt-bar-code-ne.prod-code     = bb_goods.prod-code
          tt-bar-code-ne.gds-name      = bb_goods.gds-name
          tt-bar-code-ne.node-name     = bb_gds-prt.node-name
          tt-bar-code-ne.in-code       = bb_bar-code.in-code
          tt-bar-code-ne.part-code     = bb_bar-code.part-code.
      end.
    end.
    else do:
      assign
        tt-bar-code-ne.nm            = main-bc.nm
        tt-bar-code-ne.mark          = (if tt-bar-code-ne.scn-qnty-doc = main-bc.scn-qnty then "" else (if tt-bar-code-ne.scn-qnty-doc > main-bc.scn-qnty then "<" else ">"))
        tt-bar-code-ne.scn-qnty-file = main-bc.scn-qnty.
    end.
  end.
  if varanlz = yes then do:
    run str/scr-neb.w (input parparentproc, input-output table tt-bar-code-ne, input scan-name, input no, input v-cntxt-obj-type, input v-cntxt-obj-code).
  end.
end.
run waitfram-hide in this-procedure.
assign
  i    = 0
  j    = 0
  .
define buffer buf_gds-obj for ub.gds-obj  .
find first buf_gds-obj no-lock where
           buf_gds-obj.obj-type = t-doc.obj-type and
           buf_gds-obj.obj-code = t-doc.obj-code and
           buf_gds-obj.gds-code = goods.gds-code no-error .
if available buf_gds-obj and buf_gds-obj.cash-parts then do:
for each anlz-bc on error undo, return error return-value :
  i = i + 1.
  display i with frame a.
  find first bar-code where bar-code.b-code   = anlz-bc.b-c        no-lock.
  find first goods    where goods.gds-code    = bar-code.gds-code  no-lock.
  assign bar-str  = string( anlz-bc.b-c)
         qnty-str = string( anlz-bc.scn-qnty)
         rate     = 1
         pl-str   = anlz-bc.scn-pl
         mess     = anlz-bc.des.
  run proc-code in this-procedure (input anlz-bc.scn-pl
                                  ,input (if anlz-bc.rez = "place" then "place" else "")
                                  ,input varscales-pref
                                  ,input varpgscales-pref
                                  ) no-error.
  if error-status:error then do:
     assign is-err = yes.
  end.
  else do:
    assign
      j = j + 1.
    display j with frame a.
  end.
end.
end.
else do:
for each main-bc on error undo, return error return-value :
  i = i + 1.
  display i with frame a.
  find first bar-code where bar-code.b-code   = main-bc.b-c        no-lock.
  find first goods    where goods.gds-code    = bar-code.gds-code  no-lock.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input goods.artic
  ,  input goods.prod-type
  ,  input goods.prod-code
  , output varis-petrolium
  , output varis-pieces
  ) .
  find first gds-prt  where gds-prt.node-code = bar-code.node-code no-lock.
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
  run proc-code in this-procedure (input main-bc.scn-pl
                                  ,input (if main-bc.rez = "place" then "place" else "")
                                  ,input varscales-pref
                                  ,input varpgscales-pref
                                  ) no-error.
  if error-status:error then do:
     assign is-err = yes.
  end.
  else do:
    assign
      j = j + 1.
    display j with frame a.
  end.
end.
end.
output stream log close.
output stream err close.
output stream ler close.
output stream cur close.
if is-err then do:
    message "Во время загрузки файла:" scan-txt "обнаружены ошибки." skip
            "Смотрите ler файл."
    view-as alert-box error buttons ok.
    if search (scan-name + ".ler") <> ? then do:
      run gbl/prnfilen.w
        (input  substitute("Ошибки, обнаруженные во время загрузки файла &1", scan-txt)
        ,input  0
        ,input  scan-name + ".ler"
        ,input  7
        ,output v-user-action
        ,output v-printed
        ).
    end.
end.
