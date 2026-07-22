DEFINE BUFFER buf_assortment-matrix FOR ub.assortment-matrix.
DEFINE BUFFER buf_assortment-matrix-goods FOR ub.assortment-matrix-goods.
DEFINE BUFFER Buf_gds-obj-prop FOR ub.gds-obj-prop.
DEFINE NEW SHARED BUFFER buf_goods FOR ub.goods.
DEFINE BUFFER buf_XYZ-analysis FOR ub.XYZ-analysis.
define buffer buf_XYZ-analysis-attr FOR ub.xyz-analysis-attr.
DEFINE BUFFER buf_XYZ-analysis-gds-obj FOR ub.XYZ-analysis-gds-obj.
DEFINE NEW SHARED BUFFER Buf_XYZ-analysis-goods FOR ub.XYZ-analysis-goods.
DEFINE BUFFER Buf_XYZ-analysis-obj FOR ub.XYZ-analysis-obj.
define input  parameter parParentProc AS WIDGET-HANDLE NO-UNDO.
define input  parameter v-id as integer   no-undo .
define input  parameter v-db-num as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр результатов XYZ анализа".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
new shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table doc-list no-undo
field doc-date   like ub.trn-doc.doc-date
field doc-code   like ub.trn-doc.doc-code
field obj-type   like ub.trn-doc.obj-type
field obj-code   like ub.trn-doc.obj-code
field fact-num   like ub.trn-doc.fact-num
field fact-date  like ub.trn-doc.fact-date
field shift-date like ub.trn-doc.shift-date
field shift-num  like ub.trn-doc.shift-num
field shift-name like ub.trn-doc.shift-name
field fact-order as decimal
field is-trn-doc as logical
field is-del as logical
field doc-type   like ub.trn-doc.doc-type
field ext-doc-type   like ub.trn-doc.ext-doc-type
field sel-order  as integer
field znak       as integer
field to-del     as logical
field is-archive-exist as logical
index xpk is primary unique doc-code doc-type
index xfact fact-num
index xfact-date fact-date
index sel-order sel-order
index znak-order znak sel-order
index isdel is-del
.
define buffer inkas_trn-doc for ub.trn-doc .
define buffer c-inkas_trn-doc for ub.c-trn-doc .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table doc-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-index_name-value no-undo
field name-key  as character
field value-key as character
index pi name-key
.
define temp-table temp-sub-index_name no-undo
field name-key  as character
field nn as integer
index pi nn
.
procedure def-hash :
  do
  on error undo, return error return-value
  :
  define input  parameter p-full-string as character no-undo .
  define output parameter p-possb-keep-string as logical   no-undo .
  define output parameter p-string            as character no-undo .
  define output parameter p-hash-string       as character no-undo .
    p-full-string = trim( p-full-string ) .
    if length (p-full-string ) > 150 then do:
    assign
      p-possb-keep-string =  false
      p-string            =  substring(p-full-string,1,150)
      p-hash-string       =  encode(p-full-string)
    .
    end.
    else do:
    assign
      p-possb-keep-string =  true
      p-string            =  p-full-string
      p-hash-string       =  encode(p-full-string)
    .
    end.
  end.
end procedure.
procedure find-from-hash :
  do
  on error undo, return error return-value
  :
define input  parameter  p-full-string            as character no-undo .
define input  parameter  p-table-name             as character no-undo .
define input  parameter  p-field-possb-keep-name  as character no-undo .
define input  parameter  p-field-string-name      as character no-undo .
define input  parameter  p-field-hash-string-name as character no-undo .
define input  parameter  p-sub-table-name         as character no-undo .
define output parameter  p-recid                  as recid     no-undo .
define variable v-possb-keep-string as logical   no-undo .
define variable v-string            as character no-undo .
define variable v-hash-string       as character no-undo .
define variable v-query-prepare     as character no-undo .
define variable i  as integer no-undo .
define variable qh as widget-handle no-undo .
define variable bh as widget-handle no-undo .
define variable p-rez as logical   no-undo .
run def-hash in this-procedure (input  p-full-string ,
              output v-possb-keep-string ,
              output v-string            ,
              output v-hash-string
              ).
p-recid = ? .
create buffer bh for table p-table-name.
create query qh.
   v-query-prepare =
    "for each " + p-table-name + " no-lock where "
    + p-field-possb-keep-name   + " = "  + string(v-possb-keep-string) + " and "
    + p-field-string-name       + " = '" + v-string            + "' and "
    + p-field-hash-string-name  + " = '" + v-hash-string       + "'"
    .
if v-possb-keep-string = true then do:
    qh:set-buffers(bh).
    qh:query-prepare(v-query-prepare).
    qh:query-open.
    qh:get-first.
    p-recid = bh:recid.
end.
else do:
message false "анализ hash" .
  qh:set-buffers(bh).
  qh:query-prepare(v-query-prepare).
  qh:query-open.
  qh:get-first.
  p-recid = bh:recid.
  repeat :
    qh:get-next.
    if bh:available then do:
       qh:get-first.
       run ver-sub-table in this-procedure (
           input  p-full-string ,
           input  p-table-name ,
           input  p-sub-table-name ,
           input  bh:recid  ,
           output p-rez
           ).
       if p-rez = true  then do:
          p-recid = bh:recid .
          leave.
       end.
       else do:
         next.
       end.
    end.
    leave.
  end.
end.
delete widget bh.
delete widget qh.
  end.
end procedure.
procedure ver-sub-table :
  do
  on error undo, return error return-value
  :
define input  parameter p-full-string as character no-undo .
define input  parameter p-name-table as character no-undo .
define input  parameter p-sub-name-table as character no-undo .
define input  parameter p-recid as recid no-undo .
define output parameter p-ok as logical   no-undo .
define variable v-query-prepare     as character no-undo .
define variable i  as integer no-undo .
define variable qh as widget-handle no-undo .
define variable bh as widget-handle no-undo .
define variable p-rez as logical   no-undo .
for each temp-index_name-value : delete temp-index_name-value . end.
for each temp-sub-index_name : delete temp-sub-index_name . end.
    create buffer bh for table p-name-table.
    create query qh.
    v-query-prepare = "for each " + p-name-table + " no-lock where recid(" + p-name-table + ") = " + string ( p-recid ) .
    qh:set-buffers(bh).
    qh:query-prepare(v-query-prepare).
    qh:query-open.
    qh:get-first.
    p-recid = bh:recid.
define variable v-inf-ind AS CHAR NO-UNDO.
define variable v-name-pi as character no-undo .
define variable v-num-fl-inkey as integer   no-undo .
define variable v-num-fl       as integer   no-undo .
define variable j as integer   no-undo .
v-name-pi = bh:PRIMARY .
v-inf-ind = "1".
i = 0.
DO while ( v-inf-ind <> ? )
    on error undo, return error:
    i = i + 1 .
    v-inf-ind = bh:INDEX-INFORMATION(i) .
    if v-inf-ind = ? then leave.
    if entry( 1 , v-inf-ind ) = v-name-pi then do:
       v-num-fl-inkey = ( num-entries(v-inf-ind) - 4 ) / 2 .
       v-num-fl       = ( num-entries(v-inf-ind) - 4 )     .
      if v-num-fl-inkey >= 1 then do:
          do j = 5 to v-num-fl  by 2 :
              create temp-index_name-value .
              assign
                temp-index_name-value.name-key  = entry( j , v-inf-ind )
                temp-index_name-value.value-key = bh:BUFFER-FIELD(entry( j , v-inf-ind )):BUFFER-VALUE
              .
          end.
       end.
    end.
END.
define variable qh-sub as widget-handle no-undo .
define variable bh-sub as widget-handle no-undo .
    create buffer bh-sub for table p-sub-name-table.
    create query qh-sub.
define variable k as integer   no-undo init 0 .
    v-query-prepare = "for each " + p-sub-name-table + " no-lock where " .
    for each temp-index_name-value :
        v-query-prepare = v-query-prepare  + p-sub-name-table + "." + temp-index_name-value.name-key +
                      " = " + temp-index_name-value.value-key + " and " .
    end.
    v-query-prepare = v-query-prepare + " true = true " .
    qh-sub:set-buffers(bh-sub).
    qh-sub:query-prepare(v-query-prepare).
    qh-sub:query-open.
      v-name-pi = bh-sub:PRIMARY .
      v-inf-ind = "1".
      i = 0.
      DO while ( v-inf-ind <> ? )
          on error undo, return error:
          i = i + 1 .
          v-inf-ind = bh-sub:INDEX-INFORMATION(i) .
          if v-inf-ind = ? then leave.
          if entry( 1 , v-inf-ind ) = v-name-pi then do:
            v-num-fl-inkey = ( num-entries(v-inf-ind) - 4 ) / 2 .
            v-num-fl       = ( num-entries(v-inf-ind) - 4 )     .
            if v-num-fl-inkey >= 1 then do:
                do j = 5 to v-num-fl  by 2 :
                    if not can-find (first temp-index_name-value  where temp-index_name-value.name-key =  entry( j , v-inf-ind )) then do:
                        create temp-sub-index_name .
                        assign
                          temp-sub-index_name.name-key  = entry( j , v-inf-ind )
                          temp-sub-index_name.nn  = j
                        .
                    end.
                end.
            end.
          end.
      END.
      define variable v-qw as character no-undo .
      v-qw = "".
      qh-sub:GET-first.
      DO WHILE (bh-sub:AVAILABLE):
        for each temp-sub-index_name :
            v-qw = v-qw + string(bh-sub:BUFFER-FIELD(temp-sub-index_name.name-key):BUFFER-VALUE) .
        end.
        v-qw = v-qw + ",".
        qh-sub:GET-NEXT.
      END.
      p-ok = false .
      if trim(p-full-string, ",")  =  trim (v-qw, ",") then p-ok = true  .
    delete widget bh-sub.
    delete widget qh-sub.
    delete widget bh.
    delete widget qh.
  end.
end procedure.
PROCEDURE update-rang-def :
define input  parameter p-recid as recid     no-undo .
define input  parameter p-list-obj as character no-undo .
define input  parameter p-a as decimal   no-undo .
define input  parameter p-b as decimal   no-undo .
define input  parameter p-c as decimal   no-undo .
define input  parameter p-d as decimal   no-undo .
define input  parameter p-e as decimal   no-undo .
define input  parameter p-f as decimal   no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-exist as logical   no-undo .
define variable p-id as integer   no-undo .
define variable p-db as integer   no-undo .
define variable  p-possb-keep-string-obj as logical   no-undo .
define variable  p-string-obj            as character no-undo .
define variable  p-hash-string-obj       as character no-undo .
define buffer buf_rang-abc-def     for ub.rang-abc-def.
define buffer buf_rang-abc-def-obj for ub.rang-abc-def-obj.
find first buf_rang-abc-def exclusive-lock where recid(buf_rang-abc-def) = p-recid no-error .
if not available buf_rang-abc-def then do:
    v-exist = false  .
    assign
      p-id = next-value(s-asmt, ub)
      p-db = g#db-num
    .
    create buf_rang-abc-def.
    run def-hash in this-procedure (
         input   p-list-obj
        ,output  p-possb-keep-string-obj
        ,output  p-string-obj
        ,output  p-hash-string-obj
        ).
end.
else do:
  assign
      v-exist = true
      p-id = buf_rang-abc-def.raad-id
      p-db = buf_rang-abc-def.db-num
      p-hash-string-obj       = buf_rang-abc-def.raad-hash-string-obj
      p-possb-keep-string-obj = buf_rang-abc-def.raad-possb-keep-string-obj
      p-string-obj            = buf_rang-abc-def.raad-string-obj
  .
end.
run cur-time in this-procedure ( output v-date, output v-time ) .
    assign
          buf_rang-abc-def.raad-hash-string-obj       = p-hash-string-obj
          buf_rang-abc-def.raad-possb-keep-string-obj = p-possb-keep-string-obj
          buf_rang-abc-def.raad-string-obj            = p-string-obj
          buf_rang-abc-def.raad-a                     = p-a
          buf_rang-abc-def.raad-b                     = p-b
          buf_rang-abc-def.raad-c                     = p-c
          buf_rang-abc-def.raad-d                     = p-d
          buf_rang-abc-def.raad-e                     = p-e
          buf_rang-abc-def.raad-f                     = p-f
          buf_rang-abc-def.raad-id                    = p-id
          buf_rang-abc-def.raad-date                  = v-date
          buf_rang-abc-def.raad-db-num                = g#db-num
          buf_rang-abc-def.db-num                     = p-db
          buf_rang-abc-def.raad-time                  = v-time
          buf_rang-abc-def.raad-who                   = g#userid
      .
if v-exist = true then do:
   for each buf_rang-abc-def-obj exclusive-lock where
            buf_rang-abc-def-obj.raad-id = buf_rang-abc-def.raad-id and
            buf_rang-abc-def-obj.db-num  = buf_rang-abc-def.db-num :
            delete buf_rang-abc-def-obj.
   end.
end.
define variable i as integer   no-undo .
define variable k as integer   no-undo .
p-list-obj = trim(p-list-obj, "," ).
k = num-entries(p-list-obj, ",") .
repeat  i = 1 to k :
  create buf_rang-abc-def-obj.
  assign
    buf_rang-abc-def-obj.raad-id  = buf_rang-abc-def.raad-id
    buf_rang-abc-def-obj.db-num   = buf_rang-abc-def.db-num
    buf_rang-abc-def-obj.obj-type = substring(entry(i, p-list-obj) , 1 , 3 )
    buf_rang-abc-def-obj.obj-code = integer(substring(entry(i, p-list-obj) , 4 , 10 ))
  .
end.
RELEASE buf_rang-abc-def .
END PROCEDURE.
PROCEDURE update-rang-xyz-def :
define input  parameter p-recid as recid     no-undo .
define input  parameter p-list-obj as character no-undo .
define input  parameter p-x as decimal   no-undo .
define input  parameter p-y as decimal   no-undo .
define input  parameter p-z as decimal   no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-exist as logical   no-undo .
define variable p-id as integer   no-undo .
define variable p-db as integer   no-undo .
define variable  p-possb-keep-string-obj as logical   no-undo .
define variable  p-string-obj            as character no-undo .
define variable  p-hash-string-obj       as character no-undo .
define buffer buf_rang-xyz-def     for ub.rang-xyz-def.
define buffer buf_rang-xyz-def-obj for ub.rang-xyz-def-obj.
find first buf_rang-xyz-def exclusive-lock where recid(buf_rang-xyz-def) = p-recid no-error .
if not available buf_rang-xyz-def then do:
    v-exist = false  .
    assign
      p-id = next-value(s-asmt, ub)
      p-db = g#db-num
    .
    create buf_rang-xyz-def.
    run def-hash in this-procedure (
         input   p-list-obj
        ,output  p-possb-keep-string-obj
        ,output  p-string-obj
        ,output  p-hash-string-obj
        ).
end.
else do:
  assign
      v-exist = true
      p-id = buf_rang-xyz-def.raxd-id
      p-db = buf_rang-xyz-def.db-num
      p-hash-string-obj       = buf_rang-xyz-def.raxd-hash-string-obj
      p-possb-keep-string-obj = buf_rang-xyz-def.raxd-possb-keep-string-obj
      p-string-obj            = buf_rang-xyz-def.raxd-string-obj
  .
end.
run cur-time in this-procedure ( output v-date, output v-time ) .
    assign
          buf_rang-xyz-def.raxd-hash-string-obj       = p-hash-string-obj
          buf_rang-xyz-def.raxd-possb-keep-string-obj = p-possb-keep-string-obj
          buf_rang-xyz-def.raxd-string-obj            = p-string-obj
          buf_rang-xyz-def.raxd-x                     = p-x
          buf_rang-xyz-def.raxd-y                     = p-y
          buf_rang-xyz-def.raxd-z                     = p-z
          buf_rang-xyz-def.raxd-id                    = p-id
          buf_rang-xyz-def.raxd-date                  = v-date
          buf_rang-xyz-def.raxd-db-num                = g#db-num
          buf_rang-xyz-def.db-num                     = p-db
          buf_rang-xyz-def.raxd-time                  = v-time
          buf_rang-xyz-def.raxd-who                   = g#userid
      .
if v-exist = true then do:
   for each buf_rang-xyz-def-obj exclusive-lock where
            buf_rang-xyz-def-obj.raxd-id = buf_rang-xyz-def.raxd-id and
            buf_rang-xyz-def-obj.db-num  = buf_rang-xyz-def.db-num :
            delete buf_rang-xyz-def-obj.
   end.
end.
define variable i as integer   no-undo .
define variable k as integer   no-undo .
p-list-obj = trim(p-list-obj, "," ).
k = num-entries(p-list-obj, ",") .
repeat  i = 1 to k :
  create buf_rang-xyz-def-obj.
  assign
    buf_rang-xyz-def-obj.raxd-id  = buf_rang-xyz-def.raxd-id
    buf_rang-xyz-def-obj.db-num   = buf_rang-xyz-def.db-num
    buf_rang-xyz-def-obj.obj-type = substring(entry(i, p-list-obj) , 1 , 3 )
    buf_rang-xyz-def-obj.obj-code = integer(substring(entry(i, p-list-obj) , 4 , 10 ))
  .
end.
RELEASE buf_rang-xyz-def .
END PROCEDURE.
PROCEDURE update-doc-xyz-def :
define input  parameter p-recid as recid     no-undo .
define input  parameter p-list-obj as character no-undo .
define input  parameter p-list-doc as character no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-exist as logical   no-undo .
define variable p-id as integer   no-undo .
define variable p-db as integer   no-undo .
define variable  p-possb-keep-string-obj as logical   no-undo .
define variable  p-string-obj            as character no-undo .
define variable  p-hash-string-obj       as character no-undo .
define variable  p-possb-keep-string-doc as logical   no-undo .
define variable  p-string-doc            as character no-undo .
define variable  p-hash-string-doc       as character no-undo .
define buffer buf_doc-xyz-def     for ub.doc-xyz-def.
define buffer buf_doc-xyz-def-obj for ub.doc-xyz-def-obj.
define buffer buf_doc-xyz-def-doc for ub.doc-xyz-def-doc.
    run def-hash in this-procedure (
         input   p-list-obj
        ,output  p-possb-keep-string-obj
        ,output  p-string-obj
        ,output  p-hash-string-obj
        ).
    run def-hash in this-procedure  (
         input   p-list-doc
        ,output  p-possb-keep-string-doc
        ,output  p-string-doc
        ,output  p-hash-string-doc
        ).
find first buf_doc-xyz-def exclusive-lock where recid(buf_doc-xyz-def) = p-recid no-error .
if not available buf_doc-xyz-def then do:
    v-exist = false  .
    assign
      p-id = next-value(s-asmt, ub)
      p-db = g#db-num
    .
    create buf_doc-xyz-def.
end.
else do:
  assign
      v-exist = true
      p-id = buf_doc-xyz-def.doxd-id
      p-db = buf_doc-xyz-def.db-num
  .
end .
run cur-time in this-procedure ( output v-date, output v-time ) .
    assign
          buf_doc-xyz-def.doxd-hash-string-obj       = p-hash-string-obj
          buf_doc-xyz-def.doxd-possb-keep-string-obj = p-possb-keep-string-obj
          buf_doc-xyz-def.doxd-string-obj            = p-string-obj
          buf_doc-xyz-def.doxd-hash-string-doc       = p-hash-string-doc
          buf_doc-xyz-def.doxd-possb-keep-string-doc = p-possb-keep-string-doc
          buf_doc-xyz-def.doxd-string-doc            = p-string-doc
          buf_doc-xyz-def.doxd-id                    = p-id
          buf_doc-xyz-def.doxd-date                  = v-date
          buf_doc-xyz-def.doxd-db-num                = g#db-num
          buf_doc-xyz-def.doxd-time                  = v-time
          buf_doc-xyz-def.doxd-who                   = g#userid
          buf_doc-xyz-def.db-num                     = p-db
      .
if v-exist = true then do:
   for each buf_doc-xyz-def-doc exclusive-lock where
            buf_doc-xyz-def-doc.doxd-id = buf_doc-xyz-def.doxd-id and
            buf_doc-xyz-def-doc.db-num  = buf_doc-xyz-def.db-num :
            delete buf_doc-xyz-def-doc.
   end.
   for each buf_doc-xyz-def-obj exclusive-lock where
            buf_doc-xyz-def-obj.doxd-id = buf_doc-xyz-def.doxd-id and
            buf_doc-xyz-def-obj.db-num  = buf_doc-xyz-def.db-num :
            delete buf_doc-xyz-def-obj.
   end.
end.
define variable i as integer   no-undo .
define variable k as integer   no-undo .
p-list-obj = trim(p-list-obj, ",")  .
k = num-entries(p-list-obj, ",") .
repeat  i = 1 to k :
  create buf_doc-xyz-def-obj.
  assign
    buf_doc-xyz-def-obj.doxd-id  = buf_doc-xyz-def.doxd-id
    buf_doc-xyz-def-obj.db-num   = buf_doc-xyz-def.db-num
    buf_doc-xyz-def-obj.obj-type = substring(entry(i, p-list-obj) , 1 , 3 )
    buf_doc-xyz-def-obj.obj-code = integer(substring(entry(i, p-list-obj) , 4 , 10 ))
  .
end.
p-list-doc = trim(p-list-doc , ",") .
k = num-entries(p-list-doc, ",") .
repeat  i = 1 to k :
  create buf_doc-xyz-def-doc.
  assign
    buf_doc-xyz-def-doc.doxd-id  = buf_doc-xyz-def.doxd-id
    buf_doc-xyz-def-doc.db-num   = buf_doc-xyz-def.db-num
    buf_doc-xyz-def-doc.dxdd-ext-doc-type = entry(i, p-list-doc)
  .
end.
RELEASE buf_doc-xyz-def .
END PROCEDURE.
PROCEDURE update-doc-def :
define input  parameter p-recid as recid     no-undo .
define input  parameter p-list-obj as character no-undo .
define input  parameter p-list-doc as character no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-exist as logical   no-undo .
define variable p-id as integer   no-undo .
define variable p-db as integer   no-undo .
define variable  p-possb-keep-string-obj as logical   no-undo .
define variable  p-string-obj            as character no-undo .
define variable  p-hash-string-obj       as character no-undo .
define variable  p-possb-keep-string-doc as logical   no-undo .
define variable  p-string-doc            as character no-undo .
define variable  p-hash-string-doc       as character no-undo .
define buffer buf_doc-abc-def     for ub.doc-abc-def.
define buffer buf_doc-abc-def-obj for ub.doc-abc-def-obj.
define buffer buf_doc-abc-def-doc for ub.doc-abc-def-doc.
    run def-hash  in this-procedure (
         input   p-list-obj
        ,output  p-possb-keep-string-obj
        ,output  p-string-obj
        ,output  p-hash-string-obj
        ).
    run def-hash  in this-procedure (
         input   p-list-doc
        ,output  p-possb-keep-string-doc
        ,output  p-string-doc
        ,output  p-hash-string-doc
        ).
find first buf_doc-abc-def exclusive-lock where recid(buf_doc-abc-def) = p-recid no-error .
if not available buf_doc-abc-def then do:
    v-exist = false  .
    assign
      p-id = next-value(s-asmt, ub)
      p-db = g#db-num
    .
    create buf_doc-abc-def.
end.
else do:
  assign
      v-exist = true
      p-id = buf_doc-abc-def.doad-id
      p-db = buf_doc-abc-def.db-num
  .
end .
run cur-time in this-procedure ( output v-date, output v-time ) .
    assign
          buf_doc-abc-def.doad-hash-string-obj       = p-hash-string-obj
          buf_doc-abc-def.doad-possb-keep-string-obj = p-possb-keep-string-obj
          buf_doc-abc-def.doad-string-obj            = p-string-obj
          buf_doc-abc-def.doad-hash-string-doc       = p-hash-string-doc
          buf_doc-abc-def.doad-possb-keep-string-doc = p-possb-keep-string-doc
          buf_doc-abc-def.doad-string-doc            = p-string-doc
          buf_doc-abc-def.doad-id                    = p-id
          buf_doc-abc-def.doad-date                  = v-date
          buf_doc-abc-def.doad-db-num                = g#db-num
          buf_doc-abc-def.doad-time                  = v-time
          buf_doc-abc-def.doad-who                   = g#userid
          buf_doc-abc-def.db-num                     = p-db
      .
if v-exist = true then do:
   for each buf_doc-abc-def-doc exclusive-lock where
            buf_doc-abc-def-doc.doad-id = buf_doc-abc-def.doad-id and
            buf_doc-abc-def-doc.db-num  = buf_doc-abc-def.db-num :
            delete buf_doc-abc-def-doc.
   end.
   for each buf_doc-abc-def-obj exclusive-lock where
            buf_doc-abc-def-obj.doad-id = buf_doc-abc-def.doad-id and
            buf_doc-abc-def-obj.db-num  = buf_doc-abc-def.db-num :
            delete buf_doc-abc-def-obj.
   end.
end.
define variable i as integer   no-undo .
define variable k as integer   no-undo .
p-list-obj = trim(p-list-obj, ",")  .
k = num-entries(p-list-obj, ",") .
repeat  i = 1 to k :
  create buf_doc-abc-def-obj.
  assign
    buf_doc-abc-def-obj.doad-id  = buf_doc-abc-def.doad-id
    buf_doc-abc-def-obj.db-num   = buf_doc-abc-def.db-num
    buf_doc-abc-def-obj.obj-type = substring(entry(i, p-list-obj) , 1 , 3 )
    buf_doc-abc-def-obj.obj-code = integer(substring(entry(i, p-list-obj) , 4 , 10 ))
  .
end.
p-list-doc = trim(p-list-doc , ",") .
k = num-entries(p-list-doc, ",") .
repeat  i = 1 to k :
  create buf_doc-abc-def-doc.
  assign
    buf_doc-abc-def-doc.doad-id  = buf_doc-abc-def.doad-id
    buf_doc-abc-def-doc.db-num   = buf_doc-abc-def.db-num
    buf_doc-abc-def-doc.dadd-ext-doc-type = entry(i, p-list-doc)
  .
end.
RELEASE buf_doc-abc-def .
END PROCEDURE.
PROCEDURE find-def-analysis-obj :
define input  parameter p-type     as character no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-abc-id   as integer   no-undo .
define output parameter p-db-num   as integer   no-undo .
  do
  on error undo, return error return-value
  :
  if p-type = "abc"  then do:
      define buffer buf_abc-analysis-obj for ub.abc-analysis-obj  .
      define buffer buf_abc-analysis     for ub.abc-analysis      .
      find first buf_abc-analysis-obj no-lock where
                buf_abc-analysis-obj.obj-type = p-obj-type and
                buf_abc-analysis-obj.obj-code = p-obj-code and
                buf_abc-analysis-obj.is-def   = true use-index objdef no-error .
                if available buf_abc-analysis-obj then do:
                    p-abc-id = buf_abc-analysis-obj.abc-id .
                    p-db-num = buf_abc-analysis-obj.db-num .
                end.
                else do:
                    p-abc-id = 0 .
                    p-db-num = 0.
                    return "На объекте нет анализа по умолчанию" .
                end.
  end.
  if p-type = "xyz"  then do:
      define buffer buf_xyz-analysis-obj for ub.xyz-analysis-obj  .
      define buffer buf_xyz-analysis     for ub.xyz-analysis      .
      find first buf_xyz-analysis-obj no-lock where
                buf_xyz-analysis-obj.obj-type = p-obj-type and
                buf_xyz-analysis-obj.obj-code = p-obj-code and
                buf_xyz-analysis-obj.is-def   = true use-index objdef no-error .
                if available buf_xyz-analysis-obj then do:
                    p-abc-id = buf_xyz-analysis-obj.xyz-id .
                    p-db-num = buf_xyz-analysis-obj.db-num .
                end.
                else do:
                    p-abc-id = 0 .
                    p-db-num = 0 .
                    return "На объекте нет анализа по умолчанию" .
                end.
  end.
  return .
end.
END PROCEDURE.
procedure save-def-analysis-obj :
define input  parameter p-type     as character no-undo .
define input  parameter p-db-num   as integer   no-undo .
define input  parameter p-abc-id   as integer   no-undo .
define output parameter v-log      as logical   no-undo .
  do
  on error undo, return error return-value
  :
  v-log = true .
  if p-type = "abc"  then do:
      define buffer buf_abc-analysis-obj for ub.abc-analysis-obj  .
      define buffer buf_abc-obj          for ub.abc-analysis-obj  .
      define buffer buf_abc-analysis     for ub.abc-analysis      .
      for each buf_abc-obj no-lock where
               buf_abc-obj.abc-id = p-abc-id and
               buf_abc-obj.db-num = p-db-num :
            define variable v-exist    as logical   no-undo init false .
            define variable v-list-anal as character no-undo init ""    .
            for each  buf_abc-analysis-obj no-lock where
                      not (buf_abc-analysis-obj.abc-id = p-abc-id and
                           buf_abc-analysis-obj.db-num = p-db-num) and
                      buf_abc-analysis-obj.is-def   = true   and
                      buf_abc-analysis-obj.obj-type = buf_abc-obj.obj-type and
                      buf_abc-analysis-obj.obj-code = buf_abc-obj.obj-code
                      :
                v-exist    = true .
                v-list-anal = string( buf_abc-analysis-obj.abc-id ) + "," .
            end.
            if v-exist then do:
                message "На объекте "
                buf_abc-obj.obj-type
                buf_abc-obj.obj-code
                skip
                "уже есть анализы по умолчанию , их внутренние номера :" skip
                v-list-anal                                              skip
                "Сделать по умолчанию анализ текущий " p-abc-id " ?"
                view-as alert-box question
                buttons yes-no update v-log .
                if v-log then do:
                    for each  buf_abc-analysis-obj exclusive-lock where
                              buf_abc-analysis-obj.obj-type = buf_abc-obj.obj-type and
                              buf_abc-analysis-obj.obj-code = buf_abc-obj.obj-code :
                      if ( buf_abc-analysis-obj.abc-id = p-abc-id and
                           buf_abc-analysis-obj.db-num = p-db-num ) then
                              buf_abc-analysis-obj.is-def   = true .
                      else buf_abc-analysis-obj.is-def   = false  .
                    end.
                end.
            end.
            else do:
              for each  buf_abc-analysis-obj exclusive-lock where
                        buf_abc-analysis-obj.obj-type = buf_abc-obj.obj-type and
                        buf_abc-analysis-obj.obj-code = buf_abc-obj.obj-code and
                        buf_abc-analysis-obj.abc-id = p-abc-id and
                        buf_abc-analysis-obj.db-num = p-db-num
                        :
                  buf_abc-analysis-obj.is-def   = true .
              end.
            end.
      end.
  end.
  if p-type = "xyz"  then do:
      define buffer buf_xyz-analysis-obj for ub.xyz-analysis-obj  .
      define buffer buf_xyz-obj          for ub.xyz-analysis-obj  .
      define buffer buf_xyz-analysis     for ub.xyz-analysis      .
      for each buf_xyz-obj no-lock where
               buf_xyz-obj.xyz-id = p-abc-id and
               buf_xyz-obj.db-num = p-db-num :
            v-exist = false .
            v-list-anal = ""    .
            for each  buf_xyz-analysis-obj no-lock where
                      not (buf_xyz-analysis-obj.xyz-id = p-abc-id and
                           buf_xyz-analysis-obj.db-num = p-db-num) and
                      buf_xyz-analysis-obj.is-def   = true   and
                      buf_xyz-analysis-obj.obj-type = buf_xyz-obj.obj-type and
                      buf_xyz-analysis-obj.obj-code = buf_xyz-obj.obj-code
                      :
                v-exist    = true .
                v-list-anal = string( buf_xyz-analysis-obj.xyz-id ) + "," .
            end.
            if v-exist then do:
                message "На объекте "
                buf_xyz-obj.obj-type
                buf_xyz-obj.obj-code
                skip
                "уже есть анализы по умолчанию , их внутренние номера :" skip
                v-list-anal                                              skip
                "Сделать по умолчанию анализ текущий " p-abc-id " ?"
                view-as alert-box question
                buttons yes-no update v-log .
                if v-log then do:
                    for each  buf_xyz-analysis-obj exclusive-lock where
                              buf_xyz-analysis-obj.obj-type = buf_xyz-obj.obj-type and
                              buf_xyz-analysis-obj.obj-code = buf_xyz-obj.obj-code :
                      if ( buf_xyz-analysis-obj.xyz-id = p-abc-id and
                           buf_xyz-analysis-obj.db-num = p-db-num ) then
                              buf_xyz-analysis-obj.is-def   = true .
                      else buf_xyz-analysis-obj.is-def   = false  .
                    end.
                end.
            end.
            else do:
              for each  buf_xyz-analysis-obj exclusive-lock where
                        buf_xyz-analysis-obj.obj-type = buf_xyz-obj.obj-type and
                        buf_xyz-analysis-obj.obj-code = buf_xyz-obj.obj-code and
                        buf_xyz-analysis-obj.xyz-id = p-abc-id and
                        buf_xyz-analysis-obj.db-num = p-db-num
                        :
                  buf_xyz-analysis-obj.is-def   = true .
              end.
            end.
      end.
  end.
end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function func-get-name-from-ext-type   returns char
  ( p-ext-type as character   ,
    p-caps     as logical ).
define variable v-ext-name as character no-undo .
run get-name-from-ext-type in this-procedure (
    input p-ext-type  ,
    input p-caps  ,
    output v-ext-name )
    no-error .
    if error-status :error then do:
       assign
         v-ext-name = p-ext-type
       .
    end.
 return (v-ext-name) .
end.
procedure get-name-from-ext-type :
 do
 on error undo, return error return-value
 :
define input  parameter p-ext-type as character no-undo .
define input  parameter p-caps     as logical no-undo   .
define output parameter p-ext-name as character no-undo .
define variable v-num as integer no-undo .
  if lookup ( p-ext-type , 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ) = 0 then do :
    message
      vss-include-info11 skip
      "Неправильно задано значение входящего параметра! "
      "Нет такого типа документов " p-ext-type
      view-as alert-box error .
      undo, return error .
  end.
  v-num      = lookup ( p-ext-type , 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ) .
  p-ext-name = entry  ( v-num , 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ) .
  if p-caps  = true then do :
     p-ext-name = caps(substring(p-ext-name,1,1) ) + substring(p-ext-name, 2 , length (p-ext-name) - 1 ) .
  end .
  end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-fltopend-rowid as rowid extent 18 no-undo .
procedure fltopend_fltopend :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
  do
  on error undo, return error
  :
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
assign
v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                   p-where-cond + chr(32)  +
                   p-use-indFIRST-query-tail + chr(32) +
                   p-use-ind-sort-clmn-by + chr(32) +
                   p-indexed-reposition
.
assign
glog = p-qh:query-prepare(v-prepare-string) no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
assign
glog = p-qh:query-open no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
  end.
end procedure.
procedure fltopend_fltfindd :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-index-phrase as character no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-recid as recid no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  glog = p-bh:find-by-rowid( p-rowid, p-lock) no-error.
  create buffer v-bh for table p-bh buffer-name p-bh:name.
  create query v-qh.
  v-qh:set-buffers(v-bh).
  v-prepare-string = substitute("for each &1 &2 &3"
                                  ,v-bh:name
                                  ,p-where-cond
                                  ,p-use-index-phrase).
  glog = v-qh:query-prepare(v-prepare-string) no-error.
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  if p-next then do:
    v-qh:reposition-to-rowid(p-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  v-recid = v-bh:recid no-error .
  delete object v-qh.
  delete object v-bh.
  return string(v-recid) .
end.
end procedure.
procedure fltopend_fltfindq :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
define output parameter p-fltopend-rowid as rowid extent 18 no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo extent 18.
define variable v-rowid as rowid no-undo extent 18.
define variable v-ii as integer no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  create query v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    create buffer v-bh[v-ii] for table p-qh:get-buffer-handle(v-ii) buffer-name p-qh:get-buffer-handle(v-ii):name .
    assign
    v-rowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid
    no-error.
    v-qh:add-buffer(v-bh[v-ii]).
  end.
  assign
  v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                    p-where-cond + chr(32)  +
                    p-use-indFIRST-query-tail + chr(32) +
                    p-use-ind-sort-clmn-by + chr(32) +
                    p-indexed-reposition
  .
  glog = v-qh:query-prepare( v-prepare-string) no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  if p-next then do:
    glog = v-qh:reposition-to-rowid(v-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  do v-ii = 1 to p-qh:num-buffers:
    assign
    p-fltopend-rowid[v-ii] = v-bh[v-ii]:rowid
    no-error.
  end.
  delete object v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    delete object v-bh[v-ii].
  end.
end.
end procedure.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#lib-Matrix  as handle no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure correct-message :
define input  parameter p-longchar as longchar no-undo .
define variable v-longchar as longchar no-undo .
define variable v-err-ext  as logical  no-undo .
  do
  on error undo, return error return-value
  :
   run get-long-message in this-procedure  (output v-longchar ).
    v-longchar = v-longchar + p-longchar.
    v-err-ext  = true .
    run set-long-message  in this-procedure  (input v-longchar,  input v-err-ext ).
  end.
end procedure.
define variable v-longchar as longchar no-undo .
define variable v-err-ext as logical   no-undo .
procedure get-long-message  :
define output parameter p-longchar  as longchar no-undo .
  do
  on error undo, return error return-value
  :
     p-longchar = v-longchar .
  end.
end procedure.
procedure set-long-message :
define input  parameter  p-longchar as longchar   no-undo .
define input  parameter  p-err-ext as logical   no-undo .
  do
  on error undo, return error return-value
  :
    v-longchar  =  p-longchar .
    v-err-ext   =  p-err-ext  .
  end.
end procedure.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure assmatat-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-value :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input  parameter p-code      like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-value     like ub.assortment-matrix-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-value in g#attr-lib
      (input  p-asmt-id
      ,input  p-db-num
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-write :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input parameter p-code      like ub.assortment-matrix-attr.attr-code  no-undo .
  define input parameter p-value     like ub.assortment-matrix-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-write in g#attr-lib
      (input  p-asmt-id
      ,input  p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-exist :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input  parameter p-code      like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-exist in g#attr-lib
      (input  p-asmt-id
      ,input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-delete :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input  parameter p-code     like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-delete in g#attr-lib
      (input  p-asmt-id
      ,input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
DEFINE VARIABLE vss-include-info20 AS CHARACTER FORMAT "x(65)" NO-UNDO INITIAL "@(#)$Workfile$ $Revision$".
FUNCTION indicator-life-gds-n RETURNS CHARACTER ( input p-rec as recid ) FORWARD.
DEFINE VARIABLE v-gl-iProc-Otkl AS DECIMAL NO-UNDO INITIAL 0.
DEFINE VARIABLE v-gl-lAM-Is-Obj         AS LOGICAL NO-UNDO INITIAL FALSE.
DEFINE VARIABLE v-gl-iAM-Gds-All        AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE v-gl-iAM-Sbl-Gds-All    AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE v-gl-iAM-Gds-Vyv        AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE v-gl-lAM-Ref-Shablon    AS LOGICAL NO-UNDO INITIAL FALSE.
DEFINE VARIABLE v-gl-dAM-Proc-Otkl      AS DECIMAL NO-UNDO INITIAL 0.
DEFINE VARIABLE v-gl-dAM-Proc-Otkl-Ras  AS DECIMAL NO-UNDO INITIAL 0.
FUNCTION Is-Gds-In-AssMatr RETURN LOGICAL(
   p-Gds-code AS INTEGER,
   p-Asmt-id  AS INTEGER,
   p-Db-num   AS INTEGER):
   DEFINE BUFFER buf_Gds FOR Ub.Assortment-matrix-goods.
   RETURN CAN-FIND(FIRST buf_Gds WHERE
                         buf_Gds.Asmt-id     = p-Asmt-id
                     AND buf_Gds.Db-num      = p-Db-num
                     AND buf_Gds.Gds-code    = p-Gds-code
                     AND buf_Gds.Asmg-status = INTEGER('0':U)
                   NO-LOCK).
END FUNCTION.
PROCEDURE Get-Delta-Gds-2-Matrix:
   DEFINE PARAMETER BUFFER buf_AM-1 FOR ub.Assortment-matrix.
   DEFINE PARAMETER BUFFER buf_AM-2 FOR ub.Assortment-matrix.
   DEFINE OUTPUT PARAMETER iDelta AS INTEGER NO-UNDO INITIAL 0.
   DEFINE BUFFER buf_Gds-1 FOR ub.Assortment-matrix-goods.
   DEFINE BUFFER buf_Gds-2 FOR ub.Assortment-matrix-goods.
   FOR EACH buf_Gds-1 WHERE
            buf_Gds-1.Asmt-id = buf_AM-1.Asmt-id
        AND buf_Gds-1.Db-num  = buf_AM-1.Db-num
        AND buf_Gds-1.Asmg-status = INTEGER('0':U)
       NO-LOCK:
       IF NOT CAN-FIND(FIRST buf_Gds-2 WHERE
                             buf_Gds-2.Asmt-id     = buf_AM-2.Asmt-id
                         AND buf_Gds-2.Db-num      = buf_AM-2.Db-num
                         AND buf_Gds-2.Gds-code    = buf_Gds-1.Gds-code
                         AND buf_Gds-2.Asmg-status = INTEGER('0':U)
                         NO-LOCK) THEN DO:
          ASSIGN
             iDelta = iDelta + 1.
       END.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Cntrl-AM-Add-1:
   DEFINE INPUT PARAMETER iDelta  AS INTEGER   NO-UNDO.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   IF v-gl-iProc-Otkl = 0      THEN RETURN.
   IF NOT v-gl-lAM-Is-Obj      THEN RETURN.
   IF NOT v-gl-lAM-Ref-Shablon THEN RETURN.
   RUN Calc-Proc-Otkl IN THIS-PROCEDURE(iDelta).
   IF iDelta = 0 THEN DO:
      IF v-gl-dAM-Proc-Otkl >= v-gl-iProc-Otkl THEN DO:
         cError = "В данной матрице процент отклонения товаров от шаблона (=" + STRING(v-gl-dAM-Proc-Otkl) + ")" + chr(10) +
                  " больше допустимого (=" + STRING( v-gl-iProc-Otkl) +  ")." + chr(10) +
                  "Добавление товаров невозможно !".
      END.
   END. ELSE DO:
      IF v-gl-dAM-Proc-Otkl-Ras >= v-gl-iProc-Otkl THEN DO:
         cError = "В данной матрице будущий расчетный процент отклонения товаров от шаблона (=" + STRING(v-gl-dAM-Proc-Otkl-Ras) + ")" + chr(10) +
                  " больше допустимого (=" + STRING( v-gl-iProc-Otkl ) +  ")." + chr(10) +
                  " Добавление товаров невозможно !".
      END.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Get-Gl-Param-Proc-Otkl:
   DEFINE INPUT PARAMETER   p-Asmt-Id AS INTEGER    NO-UNDO.
   DEFINE INPUT PARAMETER   p-Db-num  AS INTEGER    NO-UNDO.
   DEFINE OUTPUT PARAMETER  cError    AS CHARACTER  NO-UNDO INITIAL "".
   DEFINE BUFFER buf_AM   FOR ub.Assortment-Matrix.
   FIND FIRST buf_AM WHERE
              buf_AM.asmt-id = p-Asmt-id
          AND buf_AM.db-num  = p-Db-num
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_AM THEN DO:
      cError = PROGRAM-NAME(1) +  ":Не найдена АМ id=" + STRING(p-Asmt-id) + " db-num=" + STRING(p-Db-num).
      RETURN.
   END.
   RUN Get-Gl-Set-Proc-Otkl IN THIS-PROCEDURE(
       buf_AM.obj-type,
       buf_AM.obj-code
       ).
   RUN Get-Gl-Param-AM-All in THIS-PROCEDURE(
       buf_AM.Asmt-id,
       buf_AM.db-num
       ).
   RETURN.
END PROCEDURE.
PROCEDURE Get-Gl-Param-AM-All:
   DEFINE INPUT PARAMETER   p-Asmt-Id AS INTEGER    NO-UNDO.
   DEFINE INPUT PARAMETER   p-Db-num  AS INTEGER    NO-UNDO.
   DEFINE VARIABLE lIsAmObj    AS LOGICAL    NO-UNDO INITIAL FALSE.
   DEFINE VARIABLE iSh-Asmt-id AS INTEGER    NO-UNDO INITIAL 0.
   DEFINE VARIABLE iSh-Db-num  AS INTEGER    NO-UNDO INITIAL 0.
   DEFINE VARIABLE cSh-Type    AS CHARACTER  NO-UNDO INITIAL "".
   DEFINE VARIABLE cError      AS CHARACTER  NO-UNDO INITIAL "".
   DEFINE VARIABLE dAmt        AS DECIMAL    EXTENT 2  NO-UNDO INITIAL 0.
   DEFINE VARIABLE cMode       AS CHARACTER  NO-UNDO INITIAL "".
   ASSIGN
      v-gl-iAM-Gds-All     = 0
      v-gl-iAM-Sbl-Gds-All = 0
      v-gl-iAM-Gds-Vyv     = 0
      v-gl-dAM-Proc-Otkl   = 0
      v-gl-lAM-Ref-Shablon = FALSE
      .
   RUN Get-Param-AM IN THIS-PROCEDURE (
       p-Asmt-id,
       p-Db-num,
       OUTPUT lIsAmObj,
       OUTPUT iSh-Asmt-id,
       OUTPUT iSh-Db-num,
       OUTPUT cSh-Type,
       OUTPUT cError
       ).
   IF cError <> "" THEN DO:
      MESSAGE
         PROGRAM-NAME(1) ":" SKIP
         "Такого быть не должно !!!" SKIP
         cError SKIP
         VIEW-AS ALERT-BOX INFO BUTTONS OK.
      RETURN.
   END.
   ASSIGN
      cMode                 = (IF lIsAmObj THEN "IL_GDS":U ELSE "")
      v-gl-lAM-Ref-Shablon  = (IF iSh-Asmt-id = 0 THEN FALSE ELSE TRUE)
      .
   RUN Get-Param-AM-Gds IN THIS-PROCEDURE(
       p-Asmt-Id,
       p-Db-num,
       '0':U,
       cMode,
       OUTPUT dAmt
       ).
   ASSIGN
      v-gl-iAM-Gds-All = dAmt[1]
      v-gl-iAM-Gds-Vyv = (IF lIsAmObj THEN dAmt[2] ELSE 0)
      .
    IF NOT v-gl-lAM-Ref-Shablon THEN DO:
       RETURN.
    END.
   RUN Get-Param-AM-Gds IN THIS-PROCEDURE(
       iSh-Asmt-id,
       iSh-Db-num,
       '0':U,
       "",
       OUTPUT dAmt
       ).
   ASSIGN
      v-gl-iAM-Sbl-Gds-All = dAmt[1].
   RUN Calc-Proc-Otkl IN THIS-PROCEDURE(0).
   RETURN.
END PROCEDURE.
PROCEDURE Get-Param-AM-Gds:
   DEFINE INPUT PARAMETER   p-Asmt-Id AS INTEGER    NO-UNDO.
   DEFINE INPUT PARAMETER   p-Db-num  AS INTEGER    NO-UNDO.
   DEFINE INPUT PARAMETER   p-Stat    AS INTEGER    NO-UNDO.
   DEFINE INPUT PARAMETER   p-Mode    AS CHARACTER  NO-UNDO.
   DEFINE OUTPUT PARAMETER  o-dAmt    AS DECIMAL    EXTENT 2 NO-UNDO INITIAL 0.
   DEFINE BUFFER buf_AM-goods FOR ub.Assortment-matrix-goods.
   FOR EACH buf_AM-goods WHERE
            buf_AM-goods.Asmt-id      = p-Asmt-Id
        AND buf_AM-goods.Db-num       = p-Db-num
        AND buf_AM-goods.asmg-status  = p-Stat
       NO-LOCK:
       ASSIGN
          o-dAmt[1] = o-dAmt[1] + 1.
       IF CAN-DO("IL_GDS":U, p-Mode) THEN DO:
          IF Indicator-life-gds-n(recid(buf_AM-goods)) = 'На вывод из ассортимента':U THEN DO:
             ASSIGN
                o-dAmt[2] = o-dAmt[2] + 1.
          END.
       END.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Get-Param-AM:
   DEFINE INPUT  PARAMETER  p-Asmt-id   AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER  p-Db-num    AS INTEGER   NO-UNDO.
   DEFINE OUTPUT PARAMETER  lIsObj      AS LOGICAL   NO-UNDO INITIAL FALSE.
   DEFINE OUTPUT PARAMETER  o-Asmt-id   AS INTEGER   NO-UNDO INITIAL 0.
   DEFINE OUTPUT PARAMETER  o-Db-Num    AS INTEGER   NO-UNDO INITIAL 0.
   DEFINE OUTPUT PARAMETER  v-Type      AS CHARACTER NO-UNDO INITIAL "".
   DEFINE OUTPUT PARAMETER  cError      AS CHARACTER NO-UNDO INITIAL "".
   DEFINE VARIABLE v-value AS  CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_AM   FOR ub.Assortment-Matrix.
   DEFINE BUFFER buf_AM-2 FOR ub.Assortment-Matrix.
   ASSIGN
      v-gl-lAM-Is-Obj = FALSE.
   FIND FIRST buf_AM WHERE
              buf_AM.asmt-id = p-Asmt-id
          AND buf_AM.db-num  = p-Db-num
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_AM THEN DO:
      cError = "Не найдена АМ id=" + STRING(p-Asmt-id) + " db-num=" + STRING(p-Db-num).
      RETURN.
   END.
   IF buf_AM.asmt-type <> 'Объект':U THEN DO:
      RETURN.
   END. ELSE DO:
      ASSIGN
         lIsObj           = TRUE
         v-gl-lAM-Is-Obj  = TRUE
         .
   END.
   run assmatat-value (
       input buf_AM.asmt-id
      ,input buf_AM.db-num
      ,input 'RootShablon':U
      ,output v-value
      ,output v-type
      ) .
   IF v-value = "" OR v-value = ? THEN DO:
      RETURN.
   END.
   ASSIGN
      o-Asmt-id = INTEGER(ENTRY(1, v-value, chr(4)))
      o-Db-num  = INTEGER(ENTRY(2, v-value, chr(4)))
      NO-ERROR.
   IF ERROR-STATUS:ERROR THEN DO:
      cError = PROGRAM-NAME(1) + ":" + ERROR-STATUS:GET-MESSAGE(1).
      RETURN.
   END.
   FIND FIRST buf_AM-2 WHERE
              buf_AM-2.asmt-id = o-Asmt-id
          AND buf_AM-2.db-num  = o-Db-num
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_AM-2 THEN DO:
      cError = "Не найден шаблон АМ id=" + STRING(o-Asmt-id) + " db-num=" + STRING(o-Db-num).
      RETURN.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Get-Gl-Set-Proc-Otkl:
   DEFINE INPUT PARAMETER  cObj-type AS CHARACTER NO-UNDO.
   DEFINE INPUT PARAMETER  iObj-code AS INTEGER   NO-UNDO.
   DEFINE VARIABLE v-Character   AS CHARACTER  NO-UNDO .
   DEFINE VARIABLE v-Date        AS DATE       NO-UNDO .
   DEFINE VARIABLE v-Decimal     AS DECIMAL    NO-UNDO .
   DEFINE VARIABLE v-Integer     AS INTEGER    NO-UNDO .
   DEFINE VARIABLE v-Logical     AS LOGICAL    NO-UNDO .
   DEFINE VARIABLE v-Param-Type  AS CHARACTER  NO-UNDO .
   ASSIGN
      v-gl-iProc-Otkl = 0
      .
   EMPTY TEMP-TABLE thbjattr_thbj-attr .
   RUN adm/shattri.p (
           INPUT  "get":U,
           INPUT  cObj-type,
           INPUT  iObj-code,
           INPUT  'Ass-obj':U,
           INPUT  'ass-proc-matr-shabl':U ,
           OUTPUT v-Character,
           OUTPUT v-Date,
           OUTPUT v-Decimal,
           OUTPUT v-Integer,
           OUTPUT v-Logical,
           OUTPUT v-Param-Type,
           INPUT-OUTPUT TABLE thbjattr_thbj-attr
       ) NO-ERROR.
   IF ERROR-STATUS:ERROR THEN DO:
      ASSIGN
         v-Integer  = 0
         v-Decimal  = 0.
   END. ELSE DO:
      ASSIGN
         v-gl-iProc-Otkl = v-Integer
         .
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Calc-Proc-Otkl:
   DEFINE INPUT PARAMETER iDeltaGds AS INTEGER NO-UNDO.
   DEFINE VARIABLE iTmp AS INTEGER NO-UNDO INITIAL 0.
   ASSIGN
      v-gl-dAM-Proc-Otkl     = 0
      v-gl-dAM-Proc-Otkl-Ras = 0
      .
   IF NOT v-gl-lAM-Ref-Shablon THEN DO:
      RETURN.
   END.
   IF v-gl-iAM-Sbl-Gds-All = 0 THEN DO:
      ASSIGN
         v-gl-dAM-Proc-Otkl     = 999999
         v-gl-dAM-Proc-Otkl-Ras = 999999
         .
      RETURN.
   END.
   ASSIGN
      iTmp = (v-gl-iAM-Gds-All - v-gl-iAM-Sbl-Gds-All)
      v-gl-dAM-Proc-Otkl     = ROUND(iTmp * 100 / v-gl-iAM-Sbl-Gds-All, 2)
      v-gl-dAM-Proc-Otkl-Ras = ROUND((iTmp + iDeltaGds)  * 100 / v-gl-iAM-Sbl-Gds-All, 2)
      .
   RETURN.
END PROCEDURE.
FUNCTION indicator-life-gds-n RETURNS CHARACTER
( input p-rec as recid ) :
define buffer buf_matrix-goods for ub.assortment-matrix-goods .
define variable v-gdop-min-stock              as decimal   no-undo .
define variable v-grop-max-stock              as decimal   no-undo .
define variable v-grop-level-always-presence  as decimal   no-undo .
define variable v-grop-min-order              as decimal   no-undo .
define variable v-assort-min                  as LOGICAL   NO-UNDO.
DEFINE variable v-indicator-life-gds          as CHARACTER NO-UNDO.
find first buf_matrix-goods no-lock where recid (buf_matrix-goods) = p-rec no-error .
if error-status :error then return '' .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjpr in g#library
  (input  buf_Matrix-goods.obj-type
  ,input  buf_Matrix-goods.obj-code
  ,input  ?
  ,input  ?
  ,input  ?
  ,input  buf_Matrix-goods.gds-code
  ,output v-assort-min
  ,output v-indicator-life-gds
  ,output v-gdop-min-stock
  ,output v-grop-max-stock
  ,output v-grop-level-always-presence
  ,output v-grop-min-order
  )  .
  return v-indicator-life-gds.
end function.
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
define variable filter-point as character no-undo init "Просмотр XYZ анализа" .
define variable filter-point0 as character no-undo init "Просмотр_XYZ_анализа" .
define variable sort-column-name as character no-undo .
define variable doc-rec as recid no-undo .
define variable v-izt      as character no-undo .
define variable v-Acc-mat  as character no-undo .
define variable v-Amin     as character no-undo .
define variable v-obj-AssMin  as logical   no-undo .
define variable v-obj-igt     as character no-undo .
 define variable v-gdop-min-stock              as decimal   no-undo .
 define variable v-grop-max-stock              as decimal   no-undo .
 define variable v-grop-level-always-presence  as decimal   no-undo .
 define variable v-grop-min-order              as decimal   no-undo .
define stream Out-Stream.
define stream OutStr-html.
define VARIABLE p-report-id              as character               no-undo .
define variable v-file-name-rep-htm as character no-undo .
v-err-ext = false  .
v-longchar = "".
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clear-longmess in g#lib-Matrix
   .
define variable rid-list   as character no-undo .
def var list-mode as char  no-undo.
def var doc-mode  as char  no-undo.
def var line-rec  as recid no-undo.
def var gds-rec   as recid no-undo.
def var prt-rec   as recid no-undo.
def var line-mode as char  no-undo.
define variable g#mainmenu-handle AS WIDGET-HANDLE NO-UNDO.
g#mainmenu-handle = parParentProc .
find first buf_XYZ-analysis no-lock where
           buf_XYZ-analysis.XYZ-id = v-id and
           buf_XYZ-analysis.db-num = v-db-num
            no-error .
if not available  buf_XYZ-analysis then do:
   message vss-workfile vss-revision vss-description skip
          "Не найдена запись buf_XYZ-analysis"  v-id v-db-num
          return-value
          error-status :get-message(1) .
   return.
end.
define buffer buf_criterion-analysis for ub.criterion-analysis.
find first buf_criterion-analysis no-lock where
           buf_criterion-analysis.cral-id = buf_XYZ-analysis.cral-id no-error .
if not available  buf_criterion-analysis then do:
   message vss-workfile vss-revision vss-description skip
          "Не найдена запись buf_criterion-analysis"  buf_XYZ-analysis.cral-id
          return-value
          error-status :get-message(1) .
   return.
end.
DEFINE VARIABLE v-ass-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Ассортиментная матрица"
      VIEW-AS TEXT
     SIZE 69.5 BY .67
     FGCOLOR 4  NO-UNDO.
define variable g-log as logical   no-undo .
DEFINE BUTTON B-add-AM
     LABEL "Добавить в АМ"
     SIZE 16.5 BY 1 TOOLTIP "Добавить в ассортиментную матрицу по объекту".
DEFINE BUTTON B-add-AMin
     LABEL "Добавить в АМin"
     SIZE 16.5 BY 1 TOOLTIP "Добавить в ассортиментный минимум по объектам".
DEFINE BUTTON B-cancel AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-chg-izt
     LABEL "Изменить ИЖТ"
     SIZE 12.5 BY 1 TOOLTIP "Изменить ИЖТ".
DEFINE BUTTON B-del-AM
     LABEL "Удалить из АМ"
     SIZE 16 BY 1 TOOLTIP "Удалить из  ассортиментных матриц по объектам".
DEFINE BUTTON B-del-AMin
     LABEL "Удалить из АМin"
     SIZE 16 BY 1 TOOLTIP "Удалить из  ассортиментных минимумов по объектам".
DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-mark
     LABEL "*"
     SIZE 3 BY 1.
DEFINE BUTTON B-ord
     LABEL "Новый заказ"
     SIZE 13.5 BY 1 TOOLTIP "Сформировать заказ".
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-save
     LABEL "Сохранить"
     SIZE 11.5 BY 1 TOOLTIP "Сохранить по умолчанию".
DEFINE BUTTON B-spis-ord
     LABEL "Заказы"
     SIZE 13.5 BY 1 TOOLTIP "Список открытых заказов по отмеченным товарам".
DEFINE new shared QUERY BROWSE-goods FOR
      Buf_XYZ-analysis-goods,
      buf_goods SCROLLING.
DEFINE QUERY BROWSE-obj FOR
      Buf_XYZ-analysis-obj,
      buf_XYZ-analysis-gds-obj,
      Buf_gds-obj-prop,
      buf_assortment-matrix,
      buf_assortment-matrix-goods SCROLLING.
DEFINE BROWSE BROWSE-goods
  QUERY BROWSE-goods NO-LOCK DISPLAY
      mark-string(recid( buf_XYZ-analysis-goods), rid-list) COLUMN-LABEL "*! ! " FORMAT "X(1)":U
      buf_goods.artic COLUMN-LABEL "Артикул! ! " FORMAT "X(16)":U            WIDTH 10
      buf_goods.gds-name COLUMN-LABEL "Название! ! " FORMAT "X(50)":U        WIDTH 20
      buf_xyz-analysis-goods.xyzg-xyz column-label "X!Y!Z" format "x(1)":u
      buf_xyz-analysis-goods.xyzg-prcnt-for-estimate column-label "Коэфф.!вариации!%" format ">>9.9999":u       width 8
      buf_xyz-analysis-goods.kol-period   column-label "Кол!пер! " format ">>9":u
      buf_xyz-analysis-goods.average-qnty column-label "Среднее!по!критерию" format "->>>>>>9.<<<":u             width 8
      buf_xyz-analysis-goods.sigma        column-label "Средне-!квадратическое!отклонение" format ">>>>>>>>>>9.99":u
      v-izt      column-label "ИЖТ! ! "           format "x(20)":u                                                width 10
      v-amin     column-label "Ассорт.!min! "     format "x(9)":u                                                 width 9
      v-acc-mat  column-label "Ассорт.!матрица! " format "x(9)":u                                                 width 9
      buf_xyz-analysis-goods.xyzg-qnty column-label "Количество!по!реализации" format "->>>>>>9.<<<":u           width 12
      buf_xyz-analysis-goods.xyzg-stock-qnty column-label "Остаток!количество! " format "->>>>>>9.<<<":u          width 12
      buf_xyz-analysis-goods.xyzg-stock-price-acc column-label "Остаток!товара в!учет.ценах" format "->>>>>>>9.99":u
      buf_xyz-analysis-goods.xyzg-stock-price-sale column-label "Остаток!товара в!продаж.ценах" format "->>>>>>>9.99":u
      buf_xyz-analysis-goods.xyzg-sum-acc column-label "Сумма!реализации в!учет.ценах" format "->>>>>>>9.99":u
      buf_xyz-analysis-goods.xyzg-sum-cur column-label "Сумма!реализации в!прод.ценах" format "->>>>>>>9.99":u
      buf_xyz-analysis-goods.xyzg-sum-doc column-label "Сумма!реализации в!ценах докум." format "->>>>>>>9.99":u
      buf_xyz-analysis-goods.xyzg-temp-sale-goods column-label "Темп!продаж!среднесут." format "->>>>>9.<<<":u
      buf_xyz-analysis-goods.xyzg-order-qnty COLUMN-LABEL "Заказанное!количество!товара" FORMAT ">>>>>>9.<<<":U   WIDTH 11
      enable buf_goods.artic
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 12.25 FIT-LAST-COLUMN.
DEFINE BROWSE BROWSE-obj
  QUERY BROWSE-obj NO-LOCK DISPLAY
      Buf_XYZ-analysis-obj.obj-type COLUMN-LABEL "Тип! ! "     FORMAT "X(3)":U
      Buf_XYZ-analysis-obj.obj-code COLUMN-LABEL "Объект! ! "  FORMAT ">>>>>9":U
      buf_XYZ-analysis-gds-obj.XYog-qnty            COLUMN-LABEL "Количество!по!реализации"          FORMAT "->>>>9.<<<":U  WIDTH 12
      buf_XYZ-analysis-gds-obj.XYog-temp-sale-goods COLUMN-LABEL "Темп!продаж! "                      FORMAT "->>>>9.<<<":U  WIDTH 12
      buf_XYZ-analysis-gds-obj.XYog-stock-qnty COLUMN-LABEL "Остаток!количество! "                    FORMAT "->>>>9.<<<":U  WIDTH 12
      buf_XYZ-analysis-gds-obj.XYog-price-crc COLUMN-LABEL "Продаж.цена!в валюте!критерия"           FORMAT "->>>>9.99":U   WIDTH 12
      buf_XYZ-analysis-gds-obj.XYog-sum-acc COLUMN-LABEL "Сумма!реализации в!учет.ценах"             FORMAT "->>>>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-sum-cur COLUMN-LABEL "Сумма!реализации в!продаж.ценах"           FORMAT "->>>>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-sum-doc COLUMN-LABEL "Сумма!реализации в!ценах докум."           FORMAT "->>>>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-vat-acc COLUMN-LABEL "НДС по сумме!реализации в!учет.ценах"      FORMAT "->>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-vat-cur COLUMN-LABEL "НДС по сумме!реализации в!продаж.ценах"    FORMAT "->>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-vat-doc COLUMN-LABEL "НДС по сумме!реализации в!ценах докум."    FORMAT "->>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-transport-acc COLUMN-LABEL "Транспорт.!расходы в!учет.ценах"     FORMAT "->>>>9.99":U   WIDTH 12
      buf_XYZ-analysis-gds-obj.XYog-transport-cur COLUMN-LABEL "Транспорт.!расходы в!продаж.ценах"   FORMAT "->>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-transport-doc COLUMN-LABEL "Транспорт.!расходы в!ценах докум."   FORMAT "->>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-road-tax-acc COLUMN-LABEL "Налог 3 по!реализации в!учет.ценах"   FORMAT "->>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-road-tax-cur COLUMN-LABEL "Налог 3 по!реализации в!продаж.ценах" FORMAT "->>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-road-tax-doc COLUMN-LABEL "Налог 3 по!реализации в!ценах докум." FORMAT "->>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-other-doc COLUMN-LABEL "Сумма прочих!расходов в!ценах докум."    FORMAT "->>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-other-cur COLUMN-LABEL "Сумма прочих!расходов в!продаж.ценах"    FORMAT "->>>>9.99":U
      buf_XYZ-analysis-gds-obj.XYog-other-acc COLUMN-LABEL "Сумма прочих!расходов в!учет.ценах"      FORMAT "->>>>9.99":U
      v-obj-igt                  COLUMN-LABEL "ИЖТ! ! "                                  FORMAT "x(20)":U        WIDTH 8
      v-obj-AssMin               COLUMN-LABEL "Aсс!min! "                                FORMAT "*/ ":U
      v-ass-name                              COLUMN-LABEL "Ассорт.!матрица! "                        FORMAT "x(20)":U   WIDTH 10
      buf_assortment-matrix-goods.asmt-id     COLUMN-LABEL "Код!Ассорт.!матрицы"                     FORMAT ">>>>>>>>9"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 7 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-cancel AT ROW 1 COL 1
     B-mark AT ROW 1 COL 15
     B-save AT ROW 1 COL 18
     B-chg-izt AT ROW 1 COL 29.5
     B-add-AM AT ROW 1 COL 42
     B-del-AM AT ROW 1 COL 58.5
     B-spis-ord AT ROW 1 COL 74.5
     B-Help AT ROW 1 COL 88
     B-add-AMin AT ROW 2 COL 42
     B-del-AMin AT ROW 2 COL 58.5
     B-ord AT ROW 2 COL 74.5
     B-print AT ROW 2 COL 88
     BROWSE-goods AT ROW 3 COL 1
     BROWSE-obj AT ROW 15.25 COL 1
     SPACE(0.12) SKIP(0.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Просмотр результатов XYZ анализа"
         CANCEL-BUTTON B-cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add-AM IN FRAME Dialog-Frame
DO:
define variable v-log as logical   no-undo .
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_assort-matr-gds_add-def':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
 if not v-log then return  .
  if num-entries( rid-list ) = 0 then do:
    message "Не выбраны товары !!!" view-as alert-box information .
    return no-apply.
  end.
  run proc-cgh-AM ( input true ) no-error .
  if error-status :error then
      message error-status :get-message(1)
          return-value
          "Ошибка вернулась из proc-cgh-Am"
          view-as alert-box error .
   reposition browse-goods to recid integer(entry(1,rid-list)) no-error.
END.
ON CHOOSE OF B-add-AMin IN FRAME Dialog-Frame
DO:
  if num-entries( rid-list ) = 0 then do:
    message "Не выбраны товары !!!" view-as alert-box information .
    return no-apply.
  end.
  run proc-cgh-Amin ( input true ) no-error .
  if error-status :error then
      message error-status :get-message(1)
          return-value
          "Ошибка вернулась из proc-cgh-Amin"
          view-as alert-box error .
   reposition browse-goods to recid integer(entry(1,rid-list)) no-error.
END.
ON CHOOSE OF B-chg-izt IN FRAME Dialog-Frame
DO:
  if num-entries( rid-list ) = 0 then do:
    message "Не выбраны товары !!!" view-as alert-box information .
    return no-apply.
  end.
  run proc-chg-igt no-error .
  if error-status :error then
      message error-status :get-message(1)
          return-value
          "Ошибка вернулась из proc-chg-igt"
          view-as alert-box error .
  reposition browse-goods to recid integer(entry(1,rid-list)) no-error.
END.
ON CHOOSE OF B-del-AM IN FRAME Dialog-Frame
DO:
define variable v-log as logical   no-undo .
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_assort-matr-gds_deletion':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
 if not v-log then return  .
  if num-entries( rid-list ) = 0 then do:
    message "Не выбраны товары !!!" view-as alert-box information .
    return no-apply.
  end.
  run proc-cgh-AM ( input false ) no-error .
  if error-status :error then
      message error-status :get-message(1)
          return-value
          "Ошибка вернулась из proc-cgh-Am"
          view-as alert-box error .
    reposition browse-goods to recid integer(entry(1,rid-list)) no-error.
END.
ON CHOOSE OF B-del-AMin IN FRAME Dialog-Frame
DO:
  if num-entries( rid-list ) = 0 then do:
    message "Не выбраны товары !!!" view-as alert-box information .
    return no-apply.
  end.
  run proc-cgh-Amin ( input false ) no-error .
  if error-status :error then
      message error-status :get-message(1)
          return-value
          "Ошибка вернулась из proc-cgh-Amin"
          view-as alert-box error .
  reposition browse-goods to recid integer(entry(1,rid-list)) no-error.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
    if available Buf_XYZ-analysis-goods then do:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid25 as character no-undo .
define variable v-num-entry25 as integer   no-undo .
assign
  v-str-recid25 = trim( string( recid( Buf_XYZ-analysis-goods ) , "->>>>>>>>>>>9":U ) )
  v-num-entry25 = lookup( v-str-recid25 , rid-list )
.
if v-num-entry25 > 0 then do:
  assign
    entry( v-num-entry25, rid-list ) = "":U
    rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    rid-list = rid-list + ( if rid-list = "":U then "":U else chr(44) ) + v-str-recid25
  .
end.
        g-log = browse-goods:refresh() .
        if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            g-log = browse-goods:select-next-row ().
            apply "VALUE-CHANGED" to browse-goods in frame Dialog-Frame.
        end.
    end.
    apply "entry" to browse-goods in frame Dialog-Frame.
END.
ON CHOOSE OF B-ord IN FRAME Dialog-Frame
DO:
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
  run print-proc ( true  ).
END.
ON CHOOSE OF B-save IN FRAME Dialog-Frame
DO:
  run proc-save.
END.
ON CHOOSE OF B-spis-ord IN FRAME Dialog-Frame
DO:
define variable v-recid as character no-undo .
for each doc-list : delete doc-list. end.
  run cus/mdoclist.p ( rid-list ) .
  run cus/dord-doc.w (
  parParentProc
  ,""
  ,?
  ,?
  ,?
  ,?
  , input-output v-recid
  ).
  reposition browse-goods to recid integer(entry(1,rid-list)) no-error.
END.
ON ROW-DISPLAY OF BROWSE-goods IN FRAME Dialog-Frame
DO:
  if available  buf_XYZ-analysis-goods then do:
    run proc-disp-goods in this-procedure .
    if v-Amin = "входит" then  v-Amin:fgcolor  in browse browse-goods  = 4.
    if buf_xyz-analysis-goods.xyzg-xyz = "X" then
       assign
         buf_goods.artic:fgcolor  in browse browse-goods  = 12
         buf_goods.gds-name:fgcolor  in browse browse-goods  = 12
         buf_XYZ-analysis-goods.XYZg-XYZ:fgcolor  in browse browse-goods  = 12
         buf_XYZ-analysis-goods.XYZg-prcnt-for-estimate:fgcolor  in browse browse-goods  = 12
       .
    if buf_xyz-analysis-goods.xyzg-xyz = "Y" then
       assign
         buf_goods.artic:fgcolor  in browse browse-goods  = 9
         buf_goods.gds-name:fgcolor  in browse browse-goods  = 9
         buf_XYZ-analysis-goods.XYZg-XYZ:fgcolor  in browse browse-goods  = 9
         buf_XYZ-analysis-goods.XYZg-prcnt-for-estimate:fgcolor  in browse browse-goods  = 9
       .
  END.
END.
ON VALUE-CHANGED OF BROWSE-goods IN FRAME Dialog-Frame
DO:
  if available  buf_XYZ-analysis-goods then do:
     OPEN QUERY BROWSE-obj       FOR EACH Buf_XYZ-analysis-obj WHERE                Buf_XYZ-analysis-obj.XYZ-id = v-id AND                Buf_XYZ-analysis-obj.db-num = v-db-num                NO-LOCK,                  EACH buf_XYZ-analysis-gds-obj WHERE                buf_XYZ-analysis-gds-obj.obj-type = Buf_XYZ-analysis-obj.obj-type AND                buf_XYZ-analysis-gds-obj.obj-code = Buf_XYZ-analysis-obj.obj-code AND                buf_XYZ-analysis-gds-obj.gds-code = Buf_XYZ-analysis-goods.gds-code AND                buf_XYZ-analysis-gds-obj.XYZ-id   =  v-id AND                buf_XYZ-analysis-gds-obj.db-num   = v-db-num                OUTER-JOIN NO-LOCK,                  EACH Buf_gds-obj-prop WHERE                Buf_gds-obj-prop.obj-type = ub.buf_XYZ-analysis-obj.obj-type AND                Buf_gds-obj-prop.obj-code = ub.buf_XYZ-analysis-obj.obj-code AND                Buf_gds-obj-prop.gds-code = ub.buf_XYZ-analysis-goods.gds-code                OUTER-JOIN NO-LOCK,                 first buf_assortment-matrix WHERE                buf_assortment-matrix.asmt-status        = 0  AND                buf_assortment-matrix.obj-type =  Buf_XYZ-analysis-obj.obj-type AND                buf_assortment-matrix.obj-code =  Buf_XYZ-analysis-obj.obj-code                OUTER-JOIN NO-LOCK,                 FIRST buf_assortment-matrix-goods WHERE                buf_assortment-matrix-goods.asmg-status        = 0  AND                buf_assortment-matrix-goods.asmt-id  =  buf_assortment-matrix.asmt-id AND                buf_assortment-matrix-goods.db-num   =  buf_assortment-matrix.db-num  AND                buf_assortment-matrix-goods.gds-code =  buf_XYZ-analysis-goods.gds-code                OUTER-JOIN NO-LOCK INDEXED-REPOSITION.
  end.
END.
ON ROW-DISPLAY OF BROWSE-obj IN FRAME Dialog-Frame
DO:
 run disp-obj in this-procedure .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
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
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
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
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse browse-goods :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame Dialog-Frame anywhere do:
  run init-gds-rec.
  if gds-rec = ? then
    return no-apply.
  run ref/gds-form.w ( input parparentproc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to browse-goods in frame Dialog-Frame.
  return no-apply.
end.
run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse BROWSE-obj :handle
  ) .
run diasize_init in this-procedure .
def var sort-labelbrowse-goods   as character no-undo .
def var sort-clmnbrowse-goods    as handle    no-undo .
def var cur-clmnbrowse-goods     as handle    no-undo .
def var cur-clmn-locbrowse-goods as integer   no-undo .
def var re-querybrowse-goods     as logical   initial no no-undo .
on start-search, ctrl-o of browse-goods in frame Dialog-Frame do:
   run sort-brbrowse-goods
     (input (if available XYZ-analysis-goods
             then recid(XYZ-analysis-goods)
             else ?
            )
     ).
end.
PROCEDURE sort-brbrowse-goods :
  define input parameter p-recid as recid no-undo .
  if re-querybrowse-goods = no then do:
    assign
       cur-clmnbrowse-goods = browse-goods:current-column in frame Dialog-Frame
    .
    if sort-clmnbrowse-goods <> ? then sort-clmnbrowse-goods:column-fgcolor = 0.
    if cur-clmnbrowse-goods = sort-clmnbrowse-goods then do:
      assign
         sort-labelbrowse-goods = ""
         sort-clmnbrowse-goods = ?
      .
     end.
     else do:
       assign
         sort-labelbrowse-goods = cur-clmnbrowse-goods:label
         sort-clmnbrowse-goods  = cur-clmnbrowse-goods
         sort-clmnbrowse-goods:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbrowse-goods = 1
  .
  def var column-handle as handle no-undo .
  column-handle = browse-goods:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbrowse-goods then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbrowse-goods = cur-clmn-locbrowse-goods + 1
    .
  end.
  case sort-labelbrowse-goods:
        when '*! !'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1mark-string&1, recid(buf_XYZ-analysis-goods), &1&2&1)', chr(34), rid-list)     .     run OpenBr (yes, no, '':U).   . END.
        when 'Артикул! !'  then DO:    assign       sort-column-name = "buf_goods.artic"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Название! !'  then DO:    assign       sort-column-name = "buf_goods.gds-name"     .     run OpenBr (yes, no, '':U).   . END.
        when 'X!Y!Z'  then DO:    assign       sort-column-name = "buf_XYZ-analysis-goods.XYZg-XYZ"     .     run OpenBr (yes, no, '':U).   . END.
        when '% по  !крите-!рию   '  then DO:    assign       sort-column-name = "buf_XYZ-analysis-goods.XYZg-prcnt-for-estimate"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Сумма!для оценки!по критерию'  then DO:    assign       sort-column-name = "buf_XYZ-analysis-goods.XYZg-sum-for-estimate"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Заказанное!количество!товара'  then DO:    assign       sort-column-name = "buf_XYZ-analysis-goods.XYZg-order-qnty"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Количество!по!реализации'  then DO:    assign       sort-column-name = "buf_XYZ-analysis-goods.XYZg-qnty"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Остаток!количество!'  then DO:    assign       sort-column-name = "buf_XYZ-analysis-goods.XYZg-stock-qnty"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Остаток!товара в!учет.ценах'  then DO:    assign       sort-column-name = "buf_XYZ-analysis-goods.XYZg-stock-price-acc"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Остаток!товара в!продаж.ценах'  then DO:    assign       sort-column-name = "buf_XYZ-analysis-goods.XYZg-stock-price-sale"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Сумма!реализации в!учет.ценах'  then DO:    assign       sort-column-name = "buf_XYZ-analysis-goods.XYZg-sum-acc"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Сумма!реализации в!прод.ценах'  then DO:    assign       sort-column-name = "buf_XYZ-analysis-goods.XYZg-sum-cur"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Сумма!реализации в!ценах докум.'  then DO:    assign       sort-column-name = "buf_XYZ-analysis-goods.XYZg-sum-doc"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Темп!продаж!'  then DO:    assign       sort-column-name = "buf_XYZ-analysis-goods.XYZg-temp-sale-goods"     .     run OpenBr (yes, no, '':U).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr (yes, no, '':U).
      if sort-labelbrowse-goods <> "" then do:
        assign
          cur-clmnbrowse-goods:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbrowse-goods = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition browse-goods to recid p-recid no-error.
    apply "value-changed" to browse-goods in frame Dialog-Frame.
  end.
  apply "entry" to browse-goods in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbrowse-goods:
if cur-clmnbrowse-goods = ? then do:
   run OpenBr (yes, no, '':U).
end.
else do:
   assign re-querybrowse-goods = yes.
   run sort-brbrowse-goods
     (input (if available XYZ-analysis-goods
             then recid(XYZ-analysis-goods)
             else ?
            )
     ).
   assign re-querybrowse-goods = no.
end.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   buf_goods.artic:resizable in browse BROWSE-goods = true .
   buf_goods.gds-name:resizable in browse BROWSE-goods = true .
   v-izt:resizable in browse BROWSE-goods = true .
   buf_goods.artic:read-only in browse BROWSE-goods = true .
   v-ass-name:resizable in browse BROWSE-obj = true .
   v-obj-igt:resizable in browse BROWSE-obj = true .
  run my_enable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_ui.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE DISP-OBJ :
 define buffer   buf2_assortment-matrix for ub.assortment-matrix .
      v-ass-name = "" .
      if available buf_assortment-matrix-goods  then do:
          find first buf2_assortment-matrix no-lock where
                     buf2_assortment-matrix.asmt-id  =  buf_assortment-matrix-goods.asmt-id and
                     buf2_assortment-matrix.db-num   =  buf_assortment-matrix-goods.db-num no-error .
                     if available buf2_assortment-matrix
                        then  v-ass-name = buf2_assortment-matrix.asmt-name .
      end.
      if available buf_XYZ-analysis-obj then do:
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjpr in g#library
  (input  buf_XYZ-analysis-obj.obj-type
  ,input  buf_XYZ-analysis-obj.obj-code
  ,input  ?
  ,input  ?
  ,input  ?
  ,input  buf_XYZ-analysis-goods.gds-code
  ,output v-obj-AssMin
  ,output v-obj-igt
  ,output v-gdop-min-stock
  ,output v-grop-max-stock
  ,output v-grop-level-always-presence
  ,output v-grop-min-order
  )  .
      end.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE B-cancel B-mark B-save B-chg-izt B-add-AM B-del-AM B-spis-ord B-Help
         B-add-AMin B-del-AMin B-ord B-print BROWSE-goods BROWSE-obj
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-goods FOR EACH Buf_XYZ-analysis-goods       WHERE Buf_XYZ-analysis-goods.XYZ-id = v-id and Buf_XYZ-analysis-goods.db-num = v-db-num NO-LOCK,              EACH buf_goods OF ub.Buf_XYZ-analysis-goods NO-LOCK INDEXED-REPOSITION.    OPEN QUERY BROWSE-obj       FOR EACH Buf_XYZ-analysis-obj WHERE                Buf_XYZ-analysis-obj.XYZ-id = v-id AND                Buf_XYZ-analysis-obj.db-num = v-db-num                NO-LOCK,                  EACH buf_XYZ-analysis-gds-obj WHERE                buf_XYZ-analysis-gds-obj.obj-type = Buf_XYZ-analysis-obj.obj-type AND                buf_XYZ-analysis-gds-obj.obj-code = Buf_XYZ-analysis-obj.obj-code AND                buf_XYZ-analysis-gds-obj.gds-code = Buf_XYZ-analysis-goods.gds-code AND                buf_XYZ-analysis-gds-obj.XYZ-id   =  v-id AND                buf_XYZ-analysis-gds-obj.db-num   = v-db-num                OUTER-JOIN NO-LOCK,                  EACH Buf_gds-obj-prop WHERE                Buf_gds-obj-prop.obj-type = ub.buf_XYZ-analysis-obj.obj-type AND                Buf_gds-obj-prop.obj-code = ub.buf_XYZ-analysis-obj.obj-code AND                Buf_gds-obj-prop.gds-code = ub.buf_XYZ-analysis-goods.gds-code                OUTER-JOIN NO-LOCK,                 first buf_assortment-matrix WHERE                buf_assortment-matrix.asmt-status        = 0  AND                buf_assortment-matrix.obj-type =  Buf_XYZ-analysis-obj.obj-type AND                buf_assortment-matrix.obj-code =  Buf_XYZ-analysis-obj.obj-code                OUTER-JOIN NO-LOCK,                 FIRST buf_assortment-matrix-goods WHERE                buf_assortment-matrix-goods.asmg-status        = 0  AND                buf_assortment-matrix-goods.asmt-id  =  buf_assortment-matrix.asmt-id AND                buf_assortment-matrix-goods.db-num   =  buf_assortment-matrix.db-num  AND                buf_assortment-matrix-goods.gds-code =  buf_XYZ-analysis-goods.gds-code                OUTER-JOIN NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE init-gds-rec :
if available buf_goods then
gds-rec = recid(buf_goods) .
END PROCEDURE.
PROCEDURE make-gds-list :
do
  on error undo, return error return-value
  :
define buffer buf2_goods for ub.goods.
define buffer buf2_XYZ-analysis-goods for ub.XYZ-analysis-goods.
define variable v-kol as integer   no-undo .
define variable i as integer   no-undo .
run waitfram-show ( "Подготовка временных таблиц.... ") .
    for each gds-list : delete gds-list. end.
    v-kol = num-entries( rid-list ) .
    repeat i = 1 to v-kol :
      find first buf2_XYZ-analysis-goods no-lock where recid(buf2_XYZ-analysis-goods) = integer(entry(i,rid-list)) no-error .
      if available buf2_XYZ-analysis-goods then do:
          find first buf2_goods no-lock where buf2_goods.gds-code = buf2_XYZ-analysis-goods.gds-code no-error .
          if available buf2_goods then do:
              create gds-list.
              BUFFER-COPY buf2_goods TO gds-list .
          end.
      end.
    end.
 run waitfram-hide.
  end.
END PROCEDURE.
PROCEDURE my_enable :
define buffer Buf2_XYZ-analysis-obj for ub.XYZ-analysis-obj.
hide b-ord in frame Dialog-Frame .
  ENABLE B-Cancel
         B-mark
         B-save
         B-chg-izt
         B-add-AM
         B-del-AM
         B-spis-ord
         B-Help
         B-add-AMin
         B-del-AMin
         B-print
         BROWSE-goods
         BROWSE-obj
      WITH FRAME Dialog-Frame.
  view frame dialog-frame.
  FOR EACH Buf2_XYZ-analysis-obj WHERE
           Buf2_XYZ-analysis-obj.XYZ-id = v-id AND
           Buf2_XYZ-analysis-obj.db-num = v-db-num     NO-LOCK :
    run create_obj-list (Buf2_XYZ-analysis-obj.obj-type , Buf2_XYZ-analysis-obj.obj-code ) .
  end.
  run openbr ( yes, no, '':u).
END PROCEDURE.
PROCEDURE OPenbr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
def var l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
define buffer buff_contract for contract.
define variable loc_contract-code as character no-undo .
def var sort-column-phrase as character no-undo .
case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.
define variable l-open-query as logical   no-undo .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-32  as logical   no-undo .
define variable  l-filter-open-32    as logical   .
define variable  flt-rec-32       as recid     no-undo .
define variable  filter-name-32      as character no-undo .
define variable  where-phrase-32     as character no-undo .
define variable  sort-phrase-32      as character no-undo .
define variable  where-phrase-rus-32 as character no-undo .
define variable  sort-phrase-rus-32  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-32
  ,output filter-name-32
  ,output where-phrase-32
  ,output sort-phrase-32
  ,output where-phrase-rus-32
  ,output sort-phrase-rus-32
  ).
if p-open-query then do:
  assign
    l-filter-open-32 = false
  .
  if flt-rec-32 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-32 as character no-undo .
    define variable  parameter-3-32 as character no-undo .
    define variable  parameter-4-32 as character no-undo .
    define variable  parameter-5-32 as character no-undo .
    define variable  parameter-6-32 as character no-undo .
    define variable  parameter-7-32 as character no-undo .
      assign
      parameter-3-32 =
                              "FOR EACH Buf_XYZ-analysis-goods"
      parameter-4-32 =
        (
          if (" Buf_XYZ-analysis-goods.XYZ-id = v-id  and Buf_XYZ-analysis-goods.db-num = v-db-num  " + " " + where-phrase-32) <> ""
          then  substitute ( ' Buf_XYZ-analysis-goods.XYZ-id = &1  and Buf_XYZ-analysis-goods.db-num = &2 ', v-id, v-db-num )  + " " + where-phrase-32
          else "true"
        )
      parameter-5-32 = (" " + "" + " " + ", EACH buf_goods OF ub.Buf_XYZ-analysis-goods NO-LOCK")
      parameter-6-32 = if sort-phrase-32 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-32
        )
      parameter-7-32 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-32 =
          (" Buf_XYZ-analysis-goods.XYZ-id = v-id  and Buf_XYZ-analysis-goods.db-num = v-db-num  " + " " + where-phrase-32 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query browse-goods:handle
                          ,input parameter-3-32
                          ,input parameter-4-32
                          ,input parameter-5-32
                          ,input parameter-6-32
                          ,input parameter-7-32
                          )
      .
      assign
        l-filter-open-32 = true
      .
    end.
    if l-filter-open-32 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-32 = false then do:
    OPEN QUERY browse-goods FOR EACH Buf_XYZ-analysis-goods use-index sort-pcnt
      where  Buf_XYZ-analysis-goods.XYZ-id = v-id  and Buf_XYZ-analysis-goods.db-num = v-db-num
    , EACH buf_goods OF ub.Buf_XYZ-analysis-goods NO-LOCK
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( Buf_XYZ-analysis-goods )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query browse-goods:handle:get-buffer-handle(1) = (buffer Buf_XYZ-analysis-goods:handle) then do:
      assign
      parameter-2-32 = (if p-find-next then "true":u else "false":u )
      parameter-4-32 =
        "where ":u +  substitute ( ' Buf_XYZ-analysis-goods.XYZ-id = &1  and Buf_XYZ-analysis-goods.db-num = &2 ', v-id, v-db-num )  + " ":u + where-phrase-32 + " ":u + p-find-condition + " " + ""
      parameter-5-32 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query browse-goods:handle
                          ,input rowid(Buf_XYZ-analysis-goods)
                          ,input logical(parameter-2-32)
                          ,input no-lock
                          ,input (buffer Buf_XYZ-analysis-goods:handle)
                          ,input parameter-4-32
                          ,input parameter-5-32
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-32 = (if p-find-next then "true":u else "false":u )
      parameter-3-32 =  "FOR EACH Buf_XYZ-analysis-goods"
      parameter-4-32 =
        (
          if (" Buf_XYZ-analysis-goods.XYZ-id = v-id  and Buf_XYZ-analysis-goods.db-num = v-db-num  " + " " + where-phrase-32) <> ""
          then  substitute ( ' Buf_XYZ-analysis-goods.XYZ-id = &1  and Buf_XYZ-analysis-goods.db-num = &2 ', v-id, v-db-num )  + " " + where-phrase-32
          else "true"
        )
      parameter-5-32 = (" " + "" + " " + ", EACH buf_goods OF ub.Buf_XYZ-analysis-goods NO-LOCK" + " " + p-find-condition)
      parameter-6-32 = if sort-phrase-32 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-32
        )
      parameter-7-32 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query browse-goods:handle
                          ,input logical(parameter-2-32)
                          ,input no-lock
                          ,input parameter-3-32
                          ,input parameter-4-32
                          ,input parameter-5-32
                          ,input parameter-6-32
                          ,input parameter-7-32
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
if not p-open-query then
REPOSITION browse-goods to recid doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query browse-goods:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
  if available  buf_XYZ-analysis-goods then do:
     OPEN QUERY BROWSE-obj       FOR EACH Buf_XYZ-analysis-obj WHERE                Buf_XYZ-analysis-obj.XYZ-id = v-id AND                Buf_XYZ-analysis-obj.db-num = v-db-num                NO-LOCK,                  EACH buf_XYZ-analysis-gds-obj WHERE                buf_XYZ-analysis-gds-obj.obj-type = Buf_XYZ-analysis-obj.obj-type AND                buf_XYZ-analysis-gds-obj.obj-code = Buf_XYZ-analysis-obj.obj-code AND                buf_XYZ-analysis-gds-obj.gds-code = Buf_XYZ-analysis-goods.gds-code AND                buf_XYZ-analysis-gds-obj.XYZ-id   =  v-id AND                buf_XYZ-analysis-gds-obj.db-num   = v-db-num                OUTER-JOIN NO-LOCK,                  EACH Buf_gds-obj-prop WHERE                Buf_gds-obj-prop.obj-type = ub.buf_XYZ-analysis-obj.obj-type AND                Buf_gds-obj-prop.obj-code = ub.buf_XYZ-analysis-obj.obj-code AND                Buf_gds-obj-prop.gds-code = ub.buf_XYZ-analysis-goods.gds-code                OUTER-JOIN NO-LOCK,                 first buf_assortment-matrix WHERE                buf_assortment-matrix.asmt-status        = 0  AND                buf_assortment-matrix.obj-type =  Buf_XYZ-analysis-obj.obj-type AND                buf_assortment-matrix.obj-code =  Buf_XYZ-analysis-obj.obj-code                OUTER-JOIN NO-LOCK,                 FIRST buf_assortment-matrix-goods WHERE                buf_assortment-matrix-goods.asmg-status        = 0  AND                buf_assortment-matrix-goods.asmt-id  =  buf_assortment-matrix.asmt-id AND                buf_assortment-matrix-goods.db-num   =  buf_assortment-matrix.db-num  AND                buf_assortment-matrix-goods.gds-code =  buf_XYZ-analysis-goods.gds-code                OUTER-JOIN NO-LOCK INDEXED-REPOSITION.
  end.
END PROCEDURE.
PROCEDURE print-proc :
define input  parameter p-obj as logical   no-undo .
def var date_string     as      char    no-undo.
def var Line                as      char    no-undo.
def var for-time as char.
           run get-report-num (
            output p-report-id
        ).
    v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".
    output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
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
        '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
        '<thead>' skip
        '<TR class="set_columns">'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 150px;"></TD>'skip
            '<TD style="width: 30px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 80px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
            '<TD style="width: 60px;"></TD>'skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="18" STYLE="font-size: 14px;">Вн.Код     :' + string(buf_XYZ-analysis.XYZ-id) + '</TD>' skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="18" STYLE="font-size: 14px;">Название   :' + string(buf_XYZ-analysis.XYZ-name) + '</TD>' skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="18" STYLE="font-size: 14px;">Критерий   :' + string(buf_criterion-analysis.cral-name) + '</TD>' skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="18" STYLE="font-size: 14px;">Коментарии :' + string(buf_XYZ-analysis.XYZ-des) + '</TD>' skip
        '</TR>'skip
        '<TR>'skip
            '<TD colspan="18" STYLE="font-size: 14px;">Создание анализа :' + string(buf_XYZ-analysis.XYZ-date-create,"99.99.9999") + '' + string(buf_XYZ-analysis.XYZ-time-create,"hh:mm") + '' + buf_XYZ-analysis.XYZ-who-create + '</TD>' skip
        '</TR>'skip
    .
    define buffer bufp_XYZ-analysis-obj for ub.XYZ-analysis-obj.
    define VARIABLE v-obj as character no-undo .
    for each bufp_XYZ-analysis-obj no-lock where bufp_XYZ-analysis-obj.db-num = buf_XYZ-analysis.db-num and
                                                 bufp_XYZ-analysis-obj.XYZ-id = buf_XYZ-analysis.XYZ-id :
       v-obj = v-obj + "," + trim(bufp_XYZ-analysis-obj.obj-type) + " " + trim(string(bufp_XYZ-analysis-obj.obj-code)) .
    end.
    v-obj = TRIM (v-obj,",") .
        put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="18" STYLE="font-size: 14px;">Объекты    :' + string(v-obj) + '</TD>' skip
        '</TR>'skip
        .
    define buffer bufp_XYZ-analysis-period for ub.XYZ-analysis-period.
    define VARIABLE v-period as character no-undo .
    for each bufp_XYZ-analysis-period no-lock where bufp_XYZ-analysis-period.db-num = buf_XYZ-analysis.db-num and
                                                    bufp_XYZ-analysis-period.XYZ-id = buf_XYZ-analysis.XYZ-id :
       v-period = v-period + "," + string(bufp_XYZ-analysis-period.XYZp-start,"99.99.9999") + "-" + string(bufp_XYZ-analysis-period.XYZp-end,"99.99.9999") .
    end.
        v-period = TRIM (v-period,",") .
        put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="18" STYLE="font-size: 14px;">Периоды    :' + string(v-period) + '</TD>' skip
        '</TR>'skip
        .
    define buffer bufp_XYZ-analysis-doc for ub.XYZ-analysis-doc.
    define VARIABLE v-doc-type as character no-undo .
    for each bufp_XYZ-analysis-doc no-lock where bufp_XYZ-analysis-doc.db-num = buf_XYZ-analysis.db-num and
                                                 bufp_XYZ-analysis-doc.XYZ-id = buf_XYZ-analysis.XYZ-id :
       v-doc-type = v-doc-type + "," + func-get-name-from-ext-type( bufp_XYZ-analysis-doc.XYZd-ext-doc-type , false ) .
    end.
        v-doc-type = TRIM (v-doc-type,",") .
        put stream OutStr-html unformatted
        '<TR>'skip
            '<TD colspan="18" STYLE="font-size: 14px;">Типы документов  :' + string(v-doc-type) + '</TD>' skip
        '</TR>'skip
        .
        put stream OutStr-html unformatted
        '</thead>'skip
    .
     put stream OutStr-html unformatted
        '<tbody>'
        '<TR>'skip
            '<TH style="text-align: center;">Артикул</TH>'skip
            '<TH style="text-align: center;">Название</TH>'skip
            '<TH style="text-align: center;">XYZ</TH>'skip
            '<TH style="text-align: center;">Коэфф-т вариац %</TH>'skip
            '<TH style="text-align: center;">Кол-во период продаж</TH>'skip
            '<TH style="text-align: center;">Сумма для оценки по критер</TH>'skip
            '<TH style="text-align: center;">ИЖТ</TH>'skip
            '<TH style="text-align: center;">Ассорт. min</TH>'skip
            '<TH style="text-align: center;">Ассорт. матрица</TH>'skip
            '<TH style="text-align: center;">Кол-во по реализац</TH>'skip
            '<TH style="text-align: center;">Остаток кол-во</TH>'skip
            '<TH style="text-align: center;">Остаток товара в учет.ценах</TH>'skip
            '<TH style="text-align: center;">Остаток товара в продаж.ценах</TH>'skip
            '<TH style="text-align: center;">Сумма реализ. в учет.ценах</TH>'skip
            '<TH style="text-align: center;">Сумма реализ. в прод.ценах</TH>'skip
            '<TH style="text-align: center;">Сумма реализ. в ценах докум.</TH>'skip
            '<TH style="text-align: center;">Темп продаж среднесут</TH>'skip
            '<TH style="text-align: center;">Заказ кол-во товара </TH>'skip
        '</TR>'skip
        .
    run OpenBR in this-procedure (yes, no, '':U).
    DO WHILE available Buf_XYZ-analysis-goods :
        run prt-goods in this-procedure .
                put stream OutStr-html unformatted
                    '<TR>'skip
                    '<TD> ' + string(buf_goods.artic) + '</TD>'skip
                    '<TD> ' + string(buf_goods.gds-name) + '</TD>'skip
                    '<TD> ' + string(Buf_XYZ-analysis-goods.XYZg-XYZ) + '</TD>'skip
                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-prcnt-for-estimate,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-prcnt-for-estimate <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-prcnt-for-estimate,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                    '<TD num="0" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.kol-period,"->>>>>>>>>>>9",0) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.kol-period <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.kol-period,"->>>>>>>>>>>9",0) + '</TD>' else "" + '</td>' skip
                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-for-estimate,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-sum-for-estimate <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-for-estimate,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                    '<TD> ' + string(v-izt) + '</TD>'skip
                    '<TD> ' + string(v-Amin) + '</TD>'skip
                    '<TD> ' + string(v-Acc-mat) + '</TD>'skip
                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-qnty <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-qnty,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-stock-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-stock-qnty <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-stock-qnty,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-stock-price-acc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-stock-price-acc <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-stock-price-acc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-stock-price-sale,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-stock-price-sale <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-stock-price-sale,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-acc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-sum-acc <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-acc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-cur,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-sum-cur <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-cur,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-doc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-sum-doc <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-sum-doc,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-temp-sale-goods,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-temp-sale-goods <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-temp-sale-goods,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                    '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-order-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-goods.XYZg-order-qnty <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-goods.XYZg-order-qnty,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
                    '</TR>'skip
                    .
        if p-obj = true then
        do:
            OPEN QUERY BROWSE-obj       FOR EACH Buf_XYZ-analysis-obj WHERE                Buf_XYZ-analysis-obj.XYZ-id = v-id AND                Buf_XYZ-analysis-obj.db-num = v-db-num                NO-LOCK,                  EACH buf_XYZ-analysis-gds-obj WHERE                buf_XYZ-analysis-gds-obj.obj-type = Buf_XYZ-analysis-obj.obj-type AND                buf_XYZ-analysis-gds-obj.obj-code = Buf_XYZ-analysis-obj.obj-code AND                buf_XYZ-analysis-gds-obj.gds-code = Buf_XYZ-analysis-goods.gds-code AND                buf_XYZ-analysis-gds-obj.XYZ-id   =  v-id AND                buf_XYZ-analysis-gds-obj.db-num   = v-db-num                OUTER-JOIN NO-LOCK,                  EACH Buf_gds-obj-prop WHERE                Buf_gds-obj-prop.obj-type = ub.buf_XYZ-analysis-obj.obj-type AND                Buf_gds-obj-prop.obj-code = ub.buf_XYZ-analysis-obj.obj-code AND                Buf_gds-obj-prop.gds-code = ub.buf_XYZ-analysis-goods.gds-code                OUTER-JOIN NO-LOCK,                 first buf_assortment-matrix WHERE                buf_assortment-matrix.asmt-status        = 0  AND                buf_assortment-matrix.obj-type =  Buf_XYZ-analysis-obj.obj-type AND                buf_assortment-matrix.obj-code =  Buf_XYZ-analysis-obj.obj-code                OUTER-JOIN NO-LOCK,                 FIRST buf_assortment-matrix-goods WHERE                buf_assortment-matrix-goods.asmg-status        = 0  AND                buf_assortment-matrix-goods.asmt-id  =  buf_assortment-matrix.asmt-id AND                buf_assortment-matrix-goods.db-num   =  buf_assortment-matrix.db-num  AND                buf_assortment-matrix-goods.gds-code =  buf_XYZ-analysis-goods.gds-code                OUTER-JOIN NO-LOCK INDEXED-REPOSITION.
            DO WHILE available Buf_XYZ-analysis-obj :
                run disp-obj in this-procedure .
                    if AVAILABLE Buf_XYZ-analysis-gds-obj then
                    do:
                        if Buf_XYZ-analysis-gds-obj.XYog-qnty <> ? or Buf_XYZ-analysis-gds-obj.XYog-qnty <> 0 then
                        do:
                            put stream OutStr-html unformatted
                                '<TR>'skip
                                '<TD></TD>'skip
                                '<TD> ' + string(Buf_XYZ-analysis-obj.obj-type + " " + string(Buf_XYZ-analysis-obj.obj-code)) + '</TD>'skip
                                '<TD></TD>'skip
                                '<TD></TD>'skip
                                '<TD></TD>'skip
                                '<TD></TD>'skip
                                '<TD> ' + string(v-obj-igt) + '</TD>'skip
                                '<TD> ' + string( v-obj-AssMin , "да/нет" ) + '</TD>'skip
                                '<TD> ' + string(v-ass-name) + '</TD>'skip
                                .
                            put stream OutStr-html unformatted
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-gds-obj.XYog-qnty <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-qnty,"->>>>>>>>>>>9.99",2) + '</TD>' else "-" + '</td>' skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-stock-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-gds-obj.XYog-stock-qnty <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-stock-qnty,"->>>>>>>>>>>9.99",2) + '</TD>' else "-" + '</td>' skip
                                '<TD></TD>'skip
                                '<TD num="0.00" val="' + fnc-convert-dot-to-colon((Buf_XYZ-analysis-gds-obj.XYog-stock-qnty * buf_XYZ-analysis-gds-obj.XYog-price-crc ),"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if (Buf_XYZ-analysis-gds-obj.XYog-stock-qnty * buf_XYZ-analysis-gds-obj.XYog-price-crc ) <> ? then fnc-convert-dot-to-colon((Buf_XYZ-analysis-gds-obj.XYog-stock-qnty * buf_XYZ-analysis-gds-obj.XYog-price-crc ),"->>>>>>>>>>>9.99",2) + '</TD>' else "-" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-sum-acc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-gds-obj.XYog-sum-acc <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-sum-acc,"->>>>>>>>>>>9.99",2) + '</TD>' else "-" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-sum-cur,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-gds-obj.XYog-sum-cur <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-sum-cur,"->>>>>>>>>>>9.99",2) + '</TD>' else "-" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-sum-doc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-gds-obj.XYog-sum-doc <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-sum-doc,"->>>>>>>>>>>9.99",2) + '</TD>' else "-" + '</td>' skip
                                  '<TD num="0.00" val="' + fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-temp-sale-goods,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if Buf_XYZ-analysis-gds-obj.XYog-temp-sale-goods <> ? then fnc-convert-dot-to-colon(Buf_XYZ-analysis-gds-obj.XYog-temp-sale-goods,"->>>>>>>>>>>9.99",2) + '</TD>' else "-" + '</td>' skip
                                  '<TD></TD>'skip
                              '</TR>'skip
                                .
                        end.
                    end.
                    get next browse-obj.
                END.
        end.
            GET next BROWSE-goods.
      END.
   put stream OutStr-html unformatted
                                '</tbody>' skip
                                '</table>' skip
                                '</body>' skip
                                '</html>' skip
                                .
output stream OutStr-html close.
  run prn-lib-reportviewer-report-name in this-procedure (
                                                          input parParentProc
                                                          ,input v-file-name-rep-htm
                                                          ).
END PROCEDURE.
PROCEDURE proc-cgh-Am :
    do
    on error undo, return error return-value
    :
define input  parameter v-new as logical   no-undo .
define buffer buf_matrix                  for  ub.assortment-matrix .
define buffer buf2_assortment-matrix-goods for ub.assortment-matrix-goods .
define buffer buf_gds-obj for ub.gds-obj.
define variable p-doc-rec as recid no-undo .
define variable v-sts as integer   no-undo .
DEFINE VARIABLE cError as CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE iDelta as INTEGER   NO-UNDO INITIAL 0.
v-err-ext = false  .
v-longchar = "".
 run make-gds-list .
 for each obj-list :
      Label-AM:
      for each  buf_matrix no-lock where
          buf_matrix.asmt-status = 0 and
          buf_matrix.obj-type = obj-list.obj-type and
          buf_matrix.obj-code = obj-list.obj-code :
           if v-new = true then do:
              run waitfram-show in this-procedure  ("Добавление товаров в ассортиментную матрицу  "  +
                                                  buf_matrix.asmt-name +
                                                  "  на объекте " +
                                                  string( obj-list.obj-code )) .
          end.
          else do:
              run waitfram-show in this-procedure  ("Удаление товаров из ассортиментную матрицу  "  +
                                                  buf_matrix.asmt-name +
                                                  "  на объекте " +
                                                  string( obj-list.obj-code )) .
          end.
          if v-new = true then do:
             RUN Get-Gl-Param-Proc-Otkl in THIS-PROCEDURE(
                 buf_matrix.asmt-id,
                 buf_matrix.db-num,
                 OUTPUT cError
                 ).
             if cError <> "" THEN DO:
                v-err-ext = true .
                v-longchar = v-longchar + cError + chr(10).
                NEXT Label-AM.
             END.
DEFINE VARIABLE vss-include-info33 AS CHARACTER FORMAT "x(65)" NO-UNDO INITIAL "@(#)$Workfile$ $Revision$".
FOR EACH gds-list NO-LOCK:
    IF NOT CAN-FIND(FIRST ub.Assortment-matrix-goods WHERE
                          ub.Assortment-matrix-goods.Asmt-id      = buf_matrix.Asmt-id
                      AND ub.Assortment-matrix-goods.Db-num       = buf_matrix.db-num
                      AND ub.Assortment-matrix-goods.gds-code     = gds-list.gds-code
                      AND ub.Assortment-matrix-goods.asmg-status  = INTEGER('0':U)
                      NO-LOCK) THEN DO:
       ASSIGN
          iDelta = iDelta + 1.
    END.
END.
             RUN Cntrl-AM-Add-1 IN THIS-PROCEDURE(
                 iDelta,
                 OUTPUT cError
                 ).
             if cError <> "" THEN DO:
                v-err-ext = true .
                v-longchar = v-longchar + cError + chr(10).
                NEXT Label-AM.
             END.
          END.
          for each gds-list :
                if v-new = true then do:
                   find first buf_gds-obj no-lock where
                        buf_gds-obj.obj-type = obj-list.obj-type and
                        buf_gds-obj.obj-code = obj-list.obj-code and
                        buf_gds-obj.gds-code = gds-list.gds-code no-error .
                        if available buf_gds-obj then do:
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run main_gds-mat1 in g#lib-Matrix
 (input this-procedure
 ,input-output p-doc-rec
 ,input 'ДОБАВЛЕНИЕ':U
 ,input buf_matrix.asmt-id
 ,input buf_matrix.db-num
 ,input gds-list.gds-code
 ,input ''
  ) no-error .
                            if error-status :error then do:
                                v-err-ext = true .
                                v-longchar = v-longchar + return-value + chr(10).
                            end.
                        end.
                end.
                else do:
                  find first buf2_assortment-matrix-goods no-lock where
                        buf2_assortment-matrix-goods.asmt-id  = buf_matrix.asmt-id and
                        buf2_assortment-matrix-goods.db-num   = buf_matrix.db-num  and
                        buf2_assortment-matrix-goods.gds-code = gds-list.gds-code  and
                        buf2_assortment-matrix-goods.asmg-status = 0
                        no-error .
                        if available buf2_assortment-matrix-goods then do:
                            v-sts = int('1':U) .
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run main_gds-mat2 in g#lib-Matrix
 (input this-procedure
 ,input recid(buf2_assortment-matrix-goods)
 ,input-output v-sts
 ,input no
  ) no-error .
                              if error-status :error then do:
                                v-err-ext = true .
                                v-longchar = v-longchar + return-value + chr(10).
                              end.
                        end.
                end.
          end.
      end.
end.
run waitfram-hide in this-procedure .
    if v-err-ext = true  then do:
    define variable v-ok as logical   no-undo .
      run gbl/d-longchar.w (
          ?,
          'Editor_row=2\':u
        + 'title=При добавлении в Ассортиментные матрицы\':u
        + 'Editor_col=1\':u
        + 'Editor_width=96\':u
        + 'Editor_height=21\':u
        + 'readonly=yes\':u
      ,input-output v-longchar
      ,output v-ok ) no-error .
        v-longchar = "" .
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clear-longmess in g#lib-Matrix
   .
    end.
run OpenBr (yes, no, '':U).
end.
END PROCEDURE.
PROCEDURE proc-cgh-Amin :
    do
    on error undo, return error return-value
    :
define input  parameter v-new as logical   no-undo .
  run make-gds-list .
  run ref/chg-amin.p ( input v-new ) no-error  .
      if error-status :error then
          message vss-workfile vss-revision vss-description skip
          error-status :get-message(1)
          return-value
          .
  run OpenBr (yes, no, '':U).
    end.
END PROCEDURE.
PROCEDURE proc-chg-igt :
    do
    on error undo, return error return-value
    :
define variable  v-old as character no-undo .
define variable  v-new as character no-undo .
  run make-gds-list in this-procedure .
  run ref/graf-igt.w ( output v-old, output v-new ).
  if not(v-old = "" and v-new = "")  then do:
      run ref/chg-igt.p ( input v-old, input v-new , input true ) no-error  .
          if error-status :error then
              message vss-workfile vss-revision vss-description skip
              error-status :get-message(1)
              return-value
              .
  end.
run OpenBr ( yes, no, '':U).
    end.
END PROCEDURE.
PROCEDURE proc-disp-goods :
define variable   v-old-izt  as character no-undo .
define variable   v-old-amin  as character no-undo .
define variable   v-old-acc-mat  as character no-undo .
define variable vt-Amin as character no-undo .
    assign
    v-old-izt  = ""
    v-izt      = ""
    v-Amin     = ""
    v-old-Amin = ""
    v-acc-mat     =  ""
    v-old-acc-mat = ""
    .
OPEN QUERY BROWSE-obj       FOR EACH Buf_XYZ-analysis-obj WHERE                Buf_XYZ-analysis-obj.XYZ-id = v-id AND                Buf_XYZ-analysis-obj.db-num = v-db-num                NO-LOCK,                  EACH buf_XYZ-analysis-gds-obj WHERE                buf_XYZ-analysis-gds-obj.obj-type = Buf_XYZ-analysis-obj.obj-type AND                buf_XYZ-analysis-gds-obj.obj-code = Buf_XYZ-analysis-obj.obj-code AND                buf_XYZ-analysis-gds-obj.gds-code = Buf_XYZ-analysis-goods.gds-code AND                buf_XYZ-analysis-gds-obj.XYZ-id   =  v-id AND                buf_XYZ-analysis-gds-obj.db-num   = v-db-num                OUTER-JOIN NO-LOCK,                  EACH Buf_gds-obj-prop WHERE                Buf_gds-obj-prop.obj-type = ub.buf_XYZ-analysis-obj.obj-type AND                Buf_gds-obj-prop.obj-code = ub.buf_XYZ-analysis-obj.obj-code AND                Buf_gds-obj-prop.gds-code = ub.buf_XYZ-analysis-goods.gds-code                OUTER-JOIN NO-LOCK,                 first buf_assortment-matrix WHERE                buf_assortment-matrix.asmt-status        = 0  AND                buf_assortment-matrix.obj-type =  Buf_XYZ-analysis-obj.obj-type AND                buf_assortment-matrix.obj-code =  Buf_XYZ-analysis-obj.obj-code                OUTER-JOIN NO-LOCK,                 FIRST buf_assortment-matrix-goods WHERE                buf_assortment-matrix-goods.asmg-status        = 0  AND                buf_assortment-matrix-goods.asmt-id  =  buf_assortment-matrix.asmt-id AND                buf_assortment-matrix-goods.db-num   =  buf_assortment-matrix.db-num  AND                buf_assortment-matrix-goods.gds-code =  buf_XYZ-analysis-goods.gds-code                OUTER-JOIN NO-LOCK INDEXED-REPOSITION.
    GET next BROWSE-obj.
    assign
    v-old-izt  =  Buf_gds-obj-prop.gdop-igt
    v-izt      =  Buf_gds-obj-prop.gdop-igt
    v-Amin     =  string(Buf_gds-obj-prop.gdop-assort-min)
    v-old-Amin =  string(Buf_gds-obj-prop.gdop-assort-min)
    v-acc-mat     =  string(buf_assortment-matrix-goods.asmt-id)
    v-old-acc-mat =  string(buf_assortment-matrix-goods.asmt-id)
    no-error
    .
        if v-old-Amin = ? or
          v-old-Amin = 'no' or
          v-old-Amin = "?" or
          v-old-Amin = "" then v-old-Amin = "" .
    if v-izt = ? or v-izt = "" then v-izt = 'Пусто':U .
    if v-old-izt = ? or v-old-izt = "" then v-old-izt = 'Пусто':U .
    if v-Amin = ? or v-Amin = 'no' or v-Amin = "?" or v-Amin = "" then v-Amin = "не входит" .
       else v-Amin = "входит" .
    if v-acc-mat = ? or v-acc-mat = ""  then v-acc-mat = "не входит" .
       else v-acc-mat = "входит" .
    DO WHILE AVAILABLE(Buf_XYZ-analysis-obj):
        if Buf_gds-obj-prop.gdop-igt <> ? then
        if v-old-izt     <> Buf_gds-obj-prop.gdop-igt                then  v-izt = "разное" .
           vt-amin = string(Buf_gds-obj-prop.gdop-assort-min) .
        if vt-Amin = ?    or
           vt-Amin = 'no' or
           vt-Amin = "?"  or
           vt-Amin = "" then vt-Amin = "" .
        if v-old-Amin    <> vt-Amin  then  v-Amin = "разное" .
        if v-old-acc-mat <> string(buf_assortment-matrix-goods.asmt-id)
          and (v-old-acc-mat = ? or string(buf_assortment-matrix-goods.asmt-id) = ?  )
          then  v-acc-mat = "разное" .
      assign
        v-old-izt     = Buf_gds-obj-prop.gdop-igt
        v-old-Amin    = string(Buf_gds-obj-prop.gdop-assort-min)
        v-old-acc-mat = string(buf_assortment-matrix-goods.asmt-id)
        no-error
      .
        if v-old-Amin = ? or
           v-old-Amin = 'no' or
           v-old-Amin = "?" or
           v-old-Amin = "" then v-old-Amin = "" .
        if v-old-izt = ? or v-old-izt = "" then v-old-izt = 'Пусто':U .
      GET NEXT BROWSE-obj.
    END.
END PROCEDURE.
PROCEDURE proc-save :
  define variable v-list-doc as character no-undo .
  define variable v-list-obj as character no-undo .
  define variable v-possb-keep-string-obj as logical   no-undo .
  define variable v-string-obj            as character no-undo .
  define variable v-hash-string-obj       as character no-undo .
  define variable v-recid as recid  no-undo .
  define buffer x-XYZ-analysis for ub.XYZ-analysis.
  define buffer x-XYZ-analysis-obj for ub.XYZ-analysis-obj .
  define buffer x-XYZ-analysis-doc for ub.XYZ-analysis-doc .
  run waitfram-show ( "Сохранение анализа по умолчанию ... ") .
  v-list-obj = "" .
  find first x-XYZ-analysis no-lock  where
             x-XYZ-analysis.XYZ-id  = v-id and
             x-XYZ-analysis.db-num  = v-db-num  no-error .
             if error-status :error then return .
  for each  x-XYZ-analysis-obj no-lock
      where x-XYZ-analysis-obj.XYZ-id = x-XYZ-analysis.XYZ-id and
            x-XYZ-analysis-obj.db-num = x-XYZ-analysis.db-num  :
            v-list-obj = v-list-obj + x-XYZ-analysis-obj.obj-type + string(x-XYZ-analysis-obj.obj-code) + "," .
  end.
  run find-from-hash  (
     input v-list-obj
    ,input "rang-XYZ-def"
    ,input "raxd-possb-keep-string-obj"
    ,input "raxd-string-obj"
    ,input "raxd-hash-string-obj"
    ,input "rang-XYZ-def-obj"
    ,output v-recid
    ).
  run update-rang-xyz-def (
     input v-recid
    ,input v-list-obj
    ,input x-XYZ-analysis.XYZ-x
    ,input x-XYZ-analysis.XYZ-y
    ,input x-XYZ-analysis.XYZ-z
    ).
  v-list-doc = "".
  for each x-XYZ-analysis-doc no-lock
      where x-XYZ-analysis-doc.XYZ-id = x-XYZ-analysis.XYZ-id and
            x-XYZ-analysis-doc.db-num = x-XYZ-analysis.db-num  :
            v-list-doc = v-list-doc + x-XYZ-analysis-doc.XYZd-ext-doc-type  + "," .
  end.
  run find-from-hash  (
     input v-list-obj
    ,input "doc-XYZ-def"
    ,input "doxd-possb-keep-string-obj"
    ,input "doxd-string-obj"
    ,input "doxd-hash-string-obj"
    ,input "doc-XYZ-def-obj"
    ,output v-recid
    ).
  run update-doc-def (
     input v-recid
    ,input v-list-obj
    ,input v-list-doc
    ).
  run waitfram-hide in this-procedure .
  define variable p-ok as logical   no-undo .
    run save-def-analysis-obj (
      input  "xyz"
    , input  x-xyz-analysis.db-num
    , input  x-xyz-analysis.xyz-id
    , output p-ok
    ) .
    if p-ok then
   message
   "Интервалы ранжирования и типы документов запомнены для данного списка объектов по умолчанию" skip
   "Этот анализ будет использоваться в отчетах как анализ по умолчанию" skip
   x-xyz-analysis.xyz-id skip
   x-xyz-analysis.xyz-name
  view-as alert-box information .
END PROCEDURE.
PROCEDURE prt-goods :
define variable v-old-izt  as character no-undo .
define variable v-old-amin  as character no-undo .
define variable v-old-acc-mat  as character no-undo .
define variable vt-Amin as character no-undo .
define variable t-izt   as character no-undo .
define variable t-Amin  as character no-undo .
define variable t-asm   as character no-undo .
define variable fl      as logical   no-undo .
fl = true .
    assign
    v-old-izt  = ""
    v-izt      = ""
    v-Amin     = ""
    v-old-Amin = ""
    v-acc-mat     =  ""
    v-old-acc-mat = ""
    .
define buffer buf2_XYZ-analysis-gds-obj for ub.XYZ-analysis-gds-obj   .
define buffer buf2_assortment-matrix for ub.assortment-matrix.
define buffer buf2_assortment-matrix-goods for ub.assortment-matrix-goods.
FOR EACH Buf_XYZ-analysis-obj WHERE
         Buf_XYZ-analysis-obj.XYZ-id = v-id AND
         Buf_XYZ-analysis-obj.db-num = v-db-num
         NO-LOCK
         :
        find first buf2_XYZ-analysis-gds-obj WHERE
                   buf2_XYZ-analysis-gds-obj.obj-type = Buf_XYZ-analysis-obj.obj-type AND
                   buf2_XYZ-analysis-gds-obj.obj-code = Buf_XYZ-analysis-obj.obj-code AND
                   buf2_XYZ-analysis-gds-obj.gds-code = Buf_XYZ-analysis-goods.gds-code AND
                   buf2_XYZ-analysis-gds-obj.XYZ-id   =  v-id AND
                   buf2_XYZ-analysis-gds-obj.db-num   = v-db-num
                   NO-LOCK  no-error .
                find first buf2_assortment-matrix WHERE
                      buf2_assortment-matrix.asmt-status        = 0  AND
                      buf2_assortment-matrix.obj-type =  Buf_XYZ-analysis-obj.obj-type AND
                      buf2_assortment-matrix.obj-code =  Buf_XYZ-analysis-obj.obj-code
                      NO-LOCK no-error .
                find first buf2_assortment-matrix-goods WHERE
                      buf2_assortment-matrix-goods.asmg-status        = 0  AND
                      buf2_assortment-matrix-goods.asmt-id  =  buf2_assortment-matrix.asmt-id AND
                      buf2_assortment-matrix-goods.db-num   =  buf2_assortment-matrix.db-num  AND
                      buf2_assortment-matrix-goods.gds-code =  buf_XYZ-analysis-goods.gds-code
                      NO-LOCK no-error .
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjpr in g#library
  (input  Buf_XYZ-analysis-obj.obj-type
  ,input  Buf_XYZ-analysis-obj.obj-code
  ,input  ?
  ,input  ?
  ,input  ?
  ,input  Buf_XYZ-analysis-goods.gds-code
  ,output t-amin
  ,output t-izt
  ,output v-gdop-min-stock
  ,output v-grop-max-stock
  ,output v-grop-level-always-presence
  ,output v-grop-min-order
  )  .
             if not available buf2_assortment-matrix-goods then t-asm = "0" .
                                                           else t-asm = "1".
             if fl = true then do:
                  assign
                  fl =  false
                  v-old-izt  =  t-izt
                  v-izt      =  t-izt
                  v-Amin     =  t-amin
                  v-old-Amin =  t-amin
                  v-acc-mat     =  t-asm
                  v-old-acc-mat =  t-asm
                  .
                  if  v-Amin = 'no'  then v-Amin = "не входит" .
                                     else v-Amin = "входит" .
                  if v-acc-mat = "0" then v-acc-mat = "не входит" .
                                     else v-acc-mat = "входит" .
              end.
        if v-old-izt     <> t-izt            then  v-izt = "разное" .
        if v-old-Amin    <> t-Amin           then  v-Amin = "разное" .
        if v-old-acc-mat <> t-asm            then  v-acc-mat = "разное" .
      assign
        v-old-izt     = t-izt
        v-old-Amin    = t-Amin
        v-old-acc-mat = t-asm
      .
end.
END PROCEDURE.
PROCEDURE get-report-num :
define output parameter p-report-num as integer no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/getrpnum.p (output p-report-num).
  end.
END PROCEDURE.
