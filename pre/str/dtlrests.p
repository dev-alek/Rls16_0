block-level on error undo, throw.
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter from-close as logical.
define input parameter p-method as character no-undo .
define input parameter p-all-goods as logical no-undo .
define input parameter p-is-catering like ub.shop.is-catering no-undo .
define input parameter p-is-tpsi-obj as logical no-undo .
define input parameter p-neg-tpsi-weight as logical no-undo .
define input parameter p-neg-tpsi-qnty as decimal no-undo .
define input parameter p-neg-tpsi-oper as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dtlrests.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/dtlrests.p $":U .
define variable vss-description as character no-undo init "Процедура сбора информации по отрицательным остаткам по продаже".
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
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table tt0-info no-undo
field doc-code   like ub.trn-doc.doc-code
field artic      like ub.doc-line.artic
field prod-type  like ub.doc-line.prod-type
field prod-code  like ub.doc-line.prod-code
field prt-code  like ub.gds-dtl.prt-code
field obj-type   like ub.doc-line.obj-type
field obj-code   like ub.doc-line.obj-code
field error-message as character
field a-to-res as decimal
field was-res as decimal
field to-res as decimal
field is-res as decimal
field o-was-res as decimal
field o-to-res as decimal
field o-is-res as decimal
index pi is unique primary
obj-type
obj-code
artic
prod-type
prod-code
index iartic
artic
prod-type
prod-code
.
define shared temp-table tt0-doc-line no-undo like lib-trn_ret-line.
define shared temp-table tt0-gds-dtl  no-undo like ub.gds-dtl.
define shared temp-table tt0-parts    no-undo like ub.parts.
define shared temp-table temp-tpsi-clients  no-undo like ub.clients.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE   SHARED temp-table dtl-rests no-undo
field b-code like ub.bar-code.b-code
field artic like ub.gds-dtl.artic
field prod-type like ub.gds-dtl.prod-type
field prod-code like ub.gds-dtl.prod-code
field gds-code like ub.goods.gds-code
field prt-code like ub.gds-dtl.prt-code
field unit-base like ub.goods.unit-base
field rest-fact-qnty as decimal
field maybe-qnty as decimal
field prt-qnty as decimal
field free-qnty as decimal
field need-qnty as decimal
field gds-name like ub.goods.gds-name
field OK as logical column-label "ОК"
FIELD fbr as integer
field prop as integer
field is-neg-tpsi-oper as logical
field weight as logical
field is-neg-tpsi-qnty as logical
field is-neg-tpsi-weight as logical
field ok-prop as logical
field is-neg-rest as logical
field to-view as logical
index   pi  is primary
gds-code
prt-code ASCENDING
index   bc
b-code ASCENDING
index ifbr fbr
index iprop prop
index iok ok
index iokprop ok-prop
index iview to-view
.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table dtl-rests-mark no-undo
field artic like ub.gds-dtl.artic
field prod-type like ub.gds-dtl.prod-type
field prod-code like ub.gds-dtl.prod-code
index   pi  is primary
artic
prod-type
prod-code
.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define buffer buf_inkas  for ub.inkas .
define buffer b-goods for ub.goods.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
define buffer buf_shop for ub.shop .
define variable out-dir-doc-code as character no-undo .
define variable in-dir-doc-code as character no-undo .
define variable free-qnty as dec no-undo.
define variable res-ras-qnty as dec no-undo.
define variable res-voz-qnty as dec no-undo.
define variable out-qnty as dec no-undo.
define variable res-ras-born-qnty as dec no-undo.
define variable res-voz-born-qnty as dec no-undo.
define variable first-gds-dtl as logical init yes.
define variable v-root-code like ub.gds-prt.upper-code no-undo .
define variable is-prt as logical no-undo init no.
define variable conf-par as char no-undo.
define variable par-type as char no-undo.
define variable v-is-dish as character no-undo .
define variable v-proprietor-host-code      like ub.clients.host-code no-undo .
define variable v-proprietor-obj-type       like ub.clients.obj-type no-undo .
define variable v-proprietor-obj-code       like ub.clients.obj-code no-undo .
define variable v-other-doc-qnty            like ub.gds-dtl.doc-qnty no-undo .
define variable v-prop as integer no-undo .
define variable v-weight as logical no-undo .
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_prt-obj for ub.prt-obj.
define buffer buf_parts for ub.parts.
define buffer buf_tt0-gds-dtl for tt0-gds-dtl.
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf_gds-obj for ub.gds-obj.
define buffer buf_units for ub.units.
do
on error undo, return error return-value
:
  find first buf_inkas exclusive-lock where
             buf_inkas.inkas-code = p-inkas-code no-error .
  if not available buf_inkas then do:
    if locked (buf_inkas) then return error ("Продажа" + chr(32) + p-inkas-code + chr(32) + "занята").
    else do:
       return error ("Не найдена продажа" + chr(32) + p-inkas-code).
    end.
  end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
  IF not error-status:error then
  is-prt = (conf-par = "yes").
  find first buf_shop no-lock where
           buf_shop.obj-code = buf_inkas.obj-code.
  assign
  is-prt = is-prt and buf_shop.doc-prt
  .
  if not buf_inkas.status_ = 'факт':U then do:
    for each dtl-rests:
      delete dtl-rests.
    end.
    if not from-close then do:
      for each dtl-rests-mark:
        delete dtl-rests-mark.
      end.
    end.
    find first buf_gds-prt no-lock where
                  buf_gds-prt.root = true
              and buf_gds-prt.node-name = '_Пустая шкала':U no-error .
    if available buf_gds-prt then do:
      assign
        v-root-code = buf_gds-prt.upper-code
      .
    end.
    for each buf_sale-doc where
            buf_sale-doc.inkas-code = p-inkas-code
        and buf_sale-doc.order > 0 :
      if buf_sale-doc.doc-kind = 'rwo':U then NEXT.
      if buf_sale-doc.chr-office = 'у':U then next.
      _cycle:
      FOR EACH buf_gds-dtl NO-LOCK WHERE
                buf_gds-dtl.doc-code = buf_sale-doc.doc-code,
          FIRST b-goods NO-LOCK WHERE
                b-goods.artic = buf_gds-dtl.artic AND
                b-goods.prod-type = buf_gds-dtl.prod-type AND
                b-goods.prod-code = buf_gds-dtl.prod-code,
          FIRST ub.bar-code WHERE
                ub.bar-code.gds-code = b-goods.gds-code AND
                ub.bar-code.node-code = buf_gds-dtl.prt-code AND
                ub.bar-code.in-code = "" AND
                ub.bar-code.part-code = "" AND
                ub.bar-code.unit-cli = b-goods.unit-base NO-LOCK
        on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        :
        find first buf_gds-obj exclusive-lock where
                  buf_gds-obj.obj-type = buf_inkas.obj-type
              and buf_gds-obj.obj-code = buf_inkas.obj-code no-error .
        find first buf_prt-obj WHERE
                  buf_prt-obj.obj-type = buf_inkas.obj-type
              AND buf_prt-obj.obj-code = buf_inkas.obj-code
              AND buf_prt-obj.artic = buf_gds-dtl.artic
              AND buf_prt-obj.prod-type = buf_gds-dtl.prod-type
              AND buf_prt-obj.prod-code = buf_gds-dtl.prod-code
              AND buf_prt-obj.prt-code = buf_gds-dtl.prt-code  NO-LOCK no-error .
        assign
        v-other-doc-qnty = 0
        v-prop = 0
        v-weight = no
        .
        if false  then do:
        end.
        else do:
          if p-is-tpsi-obj then do:
            find first buf_tt0-gds-dtl where
                    buf_tt0-gds-dtl.artic     = buf_gds-dtl.artic
                AND  buf_tt0-gds-dtl.prod-type = buf_gds-dtl.prod-type
                AND  buf_tt0-gds-dtl.prod-code = buf_gds-dtl.prod-code
                AND  buf_tt0-gds-dtl.prt-code = buf_gds-dtl.prt-code no-error .
            if available buf_tt0-gds-dtl then do:
              assign
              v-other-doc-qnty = buf_tt0-gds-dtl.doc-qnty.
              .
              if not (buf_tt0-gds-dtl.obj-type = buf_gds-dtl.obj-type
                    and buf_tt0-gds-dtl.obj-code = buf_gds-dtl.obj-code) then do:
                assign
                v-prop = 1
                .
                find first buf_units no-lock where
                          buf_units.unit-name = b-goods.unit-base .
                v-weight = lookup('вес':U, buf_units.type) > 0.
              end.
            end.
          end.
          if p-all-goods = no
          and b-goods.negative-rest = yes
          and (not p-is-tpsi-obj
              or not available buf_tt0-gds-dtl
              or v-prop = 0)
          then do:
            v-is-dish = string(0).
            if p-is-catering
            and b-goods.negative-rest = yes
            then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run fgdsobjt in g#library
  (input  buf_gds-dtl.obj-type
  ,input  buf_gds-dtl.obj-code
  ,input  b-goods.gds-code
  ,input  'is-dish=request'
  ,output v-is-dish
  )  .
            end.
            if integer(v-is-dish) = 0 then do:
              next _cycle.
            end.
          end.
        end.
        IF p-method = "parts" and not
            b-goods.prt-root = v-root-code then next _cycle.
        FIND FIRST dtl-rests WHERE
                  dtl-rests.gds-code = b-goods.gds-code AND
                  dtl-rests.prt-code = buf_gds-dtl.prt-code AND
                  dtl-rests.b-code = bar-code.b-code NO-ERROR .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run fgdsobjt in g#library
  (input  buf_gds-dtl.obj-type
  ,input  buf_gds-dtl.obj-code
  ,input  b-goods.gds-code
  ,input  'is-dish=request'
  ,output v-is-dish
  )  .
        if NOT available dtl-rests then do:
          CREATE dtl-rests .
          assign
          dtl-rests.prop =  v-prop
          dtl-rests.weight = v-weight
          dtl-rests.is-neg-tpsi-weight = (p-neg-tpsi-weight and dtl-rests.weight)
          dtl-rests.fbr = integer(v-is-dish)
          dtl-rests.rest-fact-qnty = 0
          dtl-rests.artic = buf_gds-dtl.artic
          dtl-rests.prod-code = buf_gds-dtl.prod-code
          dtl-rests.prod-type = buf_gds-dtl.prod-type
          dtl-rests.prt-code = buf_gds-dtl.prt-code
          dtl-rests.unit-base = b-goods.unit-base
          dtl-rests.b-code = bar-code.b-code
          dtl-rests.gds-code = b-goods.gds-code
          .
        end.
        assign
        dtl-rests.rest-fact-qnty = rest-fact-qnty  + buf_sale-doc.msign * (buf_gds-dtl.fact-qnty - v-other-doc-qnty)
        dtl-rests.maybe-qnty = dtl-rests.maybe-qnty + buf_sale-doc.msign * (buf_gds-dtl.fact-qnty - buf_gds-dtl.doc-qnty - v-other-doc-qnty )
        dtl-rests.prt-qnty = (if available buf_prt-obj then buf_prt-obj.fact-qnty else 0)
        dtl-rests.free-qnty = (if available buf_prt-obj then buf_prt-obj.free-qnty else 0)
        dtl-rests.need-qnty = dtl-rests.maybe-qnty
        dtl-rests.is-neg-tpsi-qnty = (dtl-rests.prop > 0 and dtl-rests.need-qnty <= p-neg-tpsi-qnty)
        dtl-rests.ok-prop = (dtl-rests.is-neg-tpsi-qnty or dtl-rests.is-neg-tpsi-weight)
        dtl-rests.ok = ((dtl-rests.prt-qnty - dtl-rests.rest-fact-qnty ) >= 0 AND
                         (dtl-rests.free-qnty - dtl-rests.maybe-qnty ) >= 0
                        )
        dtl-rests.to-view =  (not p-is-tpsi-obj
                              or not available buf_tt0-gds-dtl
                              or dtl-rests.prop = 0
                              or (v-other-doc-qnty > 0 and not dtl-rests.ok)
                              )
        .
        release dtl-rests.
        if p-method = "all":U or p-method = "parts":U then do:
          if false  then do:
          end.
          else do:
            if p-all-goods = no
            and b-goods.negative-rest = yes
            and (not p-is-tpsi-obj
                or not available buf_tt0-gds-dtl
                or v-prop = 0)
            then do:
              if not (p-is-catering
                      and
                      integer(v-is-dish) > 0
                      ) then do:
                next _cycle.
              end.
            end.
          end.
          assign
          free-qnty = 0
          out-qnty = 0
          res-ras-qnty = 0
          res-voz-qnty = 0
          res-ras-born-qnty = 0
          res-voz-born-qnty = 0.
          FOR EACH Buf_parts WHERE
                  Buf_parts.prod-type = buf_gds-dtl.prod-type AND
                  Buf_parts.prod-code = buf_gds-dtl.prod-code AND
                  Buf_parts.artic     = buf_gds-dtl.artic AND
                  Buf_parts.obj-type  = buf_inkas.obj-type AND
                  Buf_parts.obj-code  = buf_inkas.obj-code AND
                  Buf_parts.status_   = no USE-INDEX artic:
            CASE Buf_parts.out-code:
              when 'free-zone':U then do:
                free-qnty = free-qnty + Buf_parts.fact-qnty.
              end.
              when 'out-zone':U then do:
                out-qnty = out-qnty + Buf_parts.fact-qnty.
              end.
              otherwise do:
                if buf_sale-doc.dir = 1 then do:
                  if Buf_parts.out-code = Buf_parts.in-code then
                  res-ras-born-qnty = res-ras-born-qnty + Buf_parts.fact-qnty.
                  else
                  res-ras-qnty = res-ras-qnty + Buf_parts.fact-qnty.
                end.
                if buf_sale-doc.dir = - 1  then do:
                  if Buf_parts.out-code = Buf_parts.in-code and Buf_parts.is-supp = no then
                  res-voz-born-qnty = res-voz-born-qnty + Buf_parts.fact-qnty.
                  else
                  res-voz-qnty = res-voz-qnty + Buf_parts.fact-qnty.
                end.
              end.
            END CASE.
          END.
          IF not (p-is-catering and integer(v-is-dish) > 0)
          AND (free-qnty - res-ras-born-qnty + res-voz-qnty + res-voz-born-qnty >= 0 AND
              out-qnty - res-voz-born-qnty + res-ras-qnty + res-ras-born-qnty >= 0)
          then NEXT _cycle.
          ELSE  DO:
            FIND FIRST dtl-rests NO-LOCK WHERE
                        dtl-rests.gds-code = b-goods.gds-code NO-ERROR .
            IF not avail dtl-rests or
            (is-prt AND v-root-code <> b-goods.prt-root) then do:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run fgdsobjt in g#library
  (input  buf_gds-dtl.obj-type
  ,input  buf_gds-dtl.obj-code
  ,input  b-goods.gds-code
  ,input  'is-dish=request'
  ,output v-is-dish
  )  .
              if integer(v-is-dish) = 0
              and  (free-qnty - res-ras-born-qnty + res-voz-qnty + res-voz-born-qnty >= 0 AND
              out-qnty - res-voz-born-qnty + res-ras-qnty + res-ras-born-qnty >= 0) then NEXT _cycle.
              CREATE dtl-rests .
              assign
              dtl-rests.prop =  v-prop
              dtl-rests.weight = v-weight
              dtl-rests.is-neg-tpsi-weight = (p-neg-tpsi-weight and dtl-rests.weight)
              dtl-rests.rest-fact-qnty = 0
              dtl-rests.artic = buf_gds-dtl.artic
              dtl-rests.fbr = integer(v-is-dish)
              dtl-rests.unit-base = b-goods.unit-base
              dtl-rests.prod-code = buf_gds-dtl.prod-code
              dtl-rests.prod-type = buf_gds-dtl.prod-type
              dtl-rests.prt-code = -1
              dtl-rests.rest-fact-qnty = res-ras-qnty
              dtl-rests.maybe-qnty = res-voz-qnty
              dtl-rests.ok = no
              dtl-rests.prt-qnty = buf_sale-doc.msign * (buf_gds-dtl.fact-qnty - buf_gds-dtl.doc-qnty - v-other-doc-qnty)
              dtl-rests.gds-code = b-goods.gds-code
              dtl-rests.need-qnty = dtl-rests.prt-qnty
              .
            END.
            else do:
              if dtl-rests.fbr = 0
              and  (free-qnty - res-ras-born-qnty + res-voz-qnty + res-voz-born-qnty >= 0 AND
              out-qnty - res-voz-born-qnty + res-ras-qnty + res-ras-born-qnty >= 0) then NEXT _cycle.
              assign
              dtl-rests.prt-qnty = dtl-rests.prt-qnty +  buf_sale-doc.msign * (buf_gds-dtl.fact-qnty - buf_gds-dtl.doc-qnty - v-other-doc-qnty)
              dtl-rests.need-qnty = (if dtl-rests.prt-code = -1
                                    then prt-qnty
                                    else dtl-rests.maybe-qnty)
              .
            end.
            assign
            dtl-rests.is-neg-tpsi-qnty = (dtl-rests.prop > 0 and dtl-rests.need-qnty <= p-neg-tpsi-qnty)
            dtl-rests.ok-prop = (dtl-rests.is-neg-tpsi-qnty or dtl-rests.is-neg-tpsi-weight)
            dtl-rests.to-view =  (not p-is-tpsi-obj
                                  or dtl-rests.prop = 0
                                  or (v-other-doc-qnty > 0
                                      and
                                      not  (free-qnty - res-ras-born-qnty + res-voz-qnty + res-voz-born-qnty >= 0 AND
                                      out-qnty - res-voz-born-qnty + res-ras-qnty + res-ras-born-qnty >= 0)
                                  ))
            .
          END.
        end.
      END.
    end.
  end.
end.
