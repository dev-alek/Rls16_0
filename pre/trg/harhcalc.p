block-level on error undo, throw.
define input  parameter p-cat-code       like ub.hold-time.cat-code no-undo .
define input  parameter p-lock-code      as character no-undo .
define input  parameter p-btpr-type-code as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Первоначальный расчет межфирменных архивов".
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
procedure holdattr-code :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'begin-date':U then do:     assign     p-label = "Дата начала межфирменного архива"     p-type = 'T':U      p-format = "99/99/9999"     p-label = "Дата начала межфирменного архива"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'is-calc':U then do:     assign     p-label = "Произв.расчет арх."     p-type = 'L':U      p-format = "+/-"     p-label = "Произв.расчет арх."     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут межфирменного архива" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure holdattr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'begin-date':U then do:     assign     p-tooltip = "Дата начала межфирменного архива"     p-label = "Дата начала межфирменного архива" .   end.
            when 'is-calc':U then do:     assign     p-tooltip = "Производится расчет межфирменного архива"     p-label = "Произв.расчет арх." .   end.
      otherwise do:
        undo, return error "неизвестный атрибут межфирменного архива" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure holdattr-value :
  do
  on error undo, return error
  :
    define input  parameter p-cat-code  like ub.hold-attr.cat-code     no-undo .
    define input  parameter p-code      like ub.hold-attr.attr-code  no-undo .
    define output parameter p-value     like ub.hold-attr.attr-value no-undo .
    define output parameter p-type      as character no-undo .
    define buffer buf_hold-attr for ub.hold-attr .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run holdattr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_hold-attr no-lock
      where buf_hold-attr.cat-code    = p-cat-code
        and buf_hold-attr.attr-code = p-code
      no-error .
    if avail buf_hold-attr then do:
      assign
        p-value =  buf_hold-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure holdattr-write :
  do
  on error undo, return error
  :
    define input parameter p-cat-code    like ub.hold-attr.cat-code     no-undo .
    define input parameter p-code      like ub.hold-attr.attr-code  no-undo .
    define input parameter p-value     like ub.hold-attr.attr-value no-undo .
    define buffer buf_hold-attr for ub.hold-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run holdattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_hold-attr exclusive-lock
      where buf_hold-attr.cat-code    = p-cat-code
        and buf_hold-attr.attr-code = p-code
      no-error .
    if not available buf_hold-attr then do:
      create buf_hold-attr .
      assign
        buf_hold-attr.cat-code    = p-cat-code
        buf_hold-attr.attr-code = p-code
      .
    end.
    assign
      buf_hold-attr.attr-value = p-value
    .
  end.
end procedure.
procedure holdattr-exist :
  do
  on error undo, return error
  :
    define input parameter p-cat-code    like ub.hold-attr.cat-code     no-undo .
    define input parameter p-code      like ub.hold-attr.attr-code  no-undo .
    define output parameter p-exist    as logical  no-undo .
    define buffer buf_hold-attr for ub.hold-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run holdattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_hold-attr no-lock
      where buf_hold-attr.cat-code    = p-cat-code
        and buf_hold-attr.attr-code = p-code
      no-error .
    if  available buf_hold-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure holdattr-delete :
  do
  on error undo, return error
  :
    define input parameter p-cat-code   like ub.hold-attr.cat-code     no-undo .
    define input parameter p-code     like ub.hold-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_hold-attr for ub.hold-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run holdattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_hold-attr exclusive-lock
      where buf_hold-attr.cat-code    = p-cat-code
        and buf_hold-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_hold-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_hold-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure holdattr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'begin-date':U then do:     assign     p-news = no.   end.
            when 'is-calc':U then do:     assign     p-news = no.   end.
      otherwise do:
        undo, return error "неизвестный атрибут межфирменного архива" + " " + p-code .
      end.
    end.
  end.
end procedure.
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure create-hold-time :
define input parameter p-cat-code like ub.hold-time.cat-code no-undo .
define input parameter p-start-date like ub.hold-time.start-date no-undo .
DEFINE VARIABLE v-end-date like ub.hold-time.end-date no-undo .
define buffer buf_hold-time for ub.hold-time .
define buffer last_hold-time for ub.hold-time .
  do
  on error undo, return error
  :
    find last last_hold-time no-lock
      where last_hold-time.cat-code = p-cat-code
      use-index pi
      no-error .
    run gbl/lastdate.p
      (input p-start-date
      ,output v-end-date)
      no-error .
    if error-status :error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка поиска последней даты периода" skip
      "Дата начала периода" p-start-date
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
      undo, return error.
    end.
    create buf_hold-time.
    assign
      buf_hold-time.cat-code       = p-cat-code
      buf_hold-time.time-code      = (if available last_hold-time
                                      then (last_hold-time.time-code + 1)
                                      else 1)
      buf_hold-time.time-type      = 'мес':U
      buf_hold-time.start-date     = p-start-date
      buf_hold-time.end-date       = v-end-date
      buf_hold-time.create-date    = today
      buf_hold-time.update-date    = today
      buf_hold-time.grpupdate-date = today
    .
  end.
end procedure.
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
define variable conf-par     as character no-undo .
define variable par-type     as character no-undo .
define variable v-month      as integer   no-undo .
define variable v-year       as integer   no-undo .
define variable lok          as logical   no-undo .
define variable v-begin-date as date      no-undo .
define buffer del_hold-time for ub.hold-time .
define buffer del_hold-trn for ub.hold-trn .
define buffer del_hold-goods for ub.hold-goods .
define buffer del_hold-gds-grp for ub.hold-gds-grp .
define buffer del_hold-purch for ub.hold-purch .
define buffer del_hold-purch-grp for ub.hold-purch-grp .
define buffer del_hold-purch-supp for ub.hold-purch-supp .
define buffer del_hold-purch-supp-gds for ub.hold-purch-supp-gds .
define buffer del_hold-sale for ub.hold-sale .
define buffer del_hold-sale-grp for ub.hold-sale-grp .
define buffer buf_trn-doc for ub.trn-doc .
define buffer buf_db for ub.db .
define buffer buf_clients for ub.clients .
do
on error undo, return error
:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'holding'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output conf-par
  ,output par-type
  ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при чтении параметра разрешены межфирменные архивы" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  if lookup(conf-par, 'true,yes') = 0
  then do:
    message
      "Межфирменные архивы запрещены параметром конфигурации" skip
      view-as alert-box information .
    return.
  end.
  run gbl/d-inpmnt.w
    (input ""
    ,input ?
    ,input-output v-month
    ,input-output v-year
    ,output lok
    ).
  if lok <> true
  then do:
    message
      "Не задана дата начала расчета межфирменных архивов" skip
      view-as alert-box information .
    return .
  end.
  assign
    v-begin-date = date(v-month, 1, v-year)
  .
  if v-begin-date = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при задании даты начала расчета межфирменных архивов" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  define variable v-ok as logical   no-undo .
  message
    "ВНИМАНИЕ" skip
    "У вас должна быть работоспособная резервная копия базы данных" skip
    "Это последний вопрос перед инициализацией межфирменного архива" skip
    "" skip
    "Будет произведено УДАЛЕНИЕ архива и расчет с даты" string(v-begin-date, '99/99/9999':u) skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true
  then do:
    undo, return error return-value .
  end.
  run holdattr-write in this-procedure
    (input p-cat-code
    ,input 'is-calc':U
    ,input 'true':u
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при записи атрибута - первоначальный расчет межфирменных архивов" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  run holdattr-write in this-procedure
    (input p-cat-code
    ,input 'begin-date':U
    ,input string(v-begin-date, '99/99/9999':u)
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при записи даты начала межфирменных архивов" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  for each del_hold-time
    where del_hold-time.cat-code = p-cat-code
  on error undo, return error
  :
    delete del_hold-time .
  end.
  for each del_hold-trn
    where del_hold-trn.cat-code = p-cat-code
  on error undo, return error
  :
    delete del_hold-trn .
  end.
  for each del_hold-goods
    where del_hold-goods.cat-code = p-cat-code
  on error undo, return error
  :
    delete del_hold-goods .
  end.
  for each del_hold-gds-grp
    where del_hold-gds-grp.cat-code = p-cat-code
  on error undo, return error
  :
    delete del_hold-gds-grp .
  end.
  for each del_hold-purch
    where del_hold-purch.cat-code = p-cat-code
  on error undo, return error
  :
    delete del_hold-purch .
  end.
  for each del_hold-purch-grp
    where del_hold-purch-grp.cat-code = p-cat-code
  on error undo, return error
  :
    delete del_hold-purch-grp .
  end.
  for each del_hold-purch-supp
    where del_hold-purch-supp.cat-code = p-cat-code
  on error undo, return error
  :
    delete del_hold-purch-supp .
  end.
  for each del_hold-purch-supp-gds
    where del_hold-purch-supp-gds.cat-code = p-cat-code
  on error undo, return error
  :
    delete del_hold-purch-supp-gds .
  end.
  for each del_hold-sale
    where del_hold-sale.cat-code = p-cat-code
  on error undo, return error
  :
    delete del_hold-sale .
  end.
  for each del_hold-sale-grp
    where del_hold-sale-grp.cat-code = p-cat-code
  on error undo, return error
  :
    delete del_hold-sale-grp .
  end.
  for each buf_db no-lock
  ,each buf_clients no-lock
    where buf_clients.db-num = buf_db.db-num
  ,each buf_trn-doc no-lock
    where buf_trn-doc.obj-type = buf_clients.obj-type
      and buf_trn-doc.obj-code = buf_clients.obj-code
      and buf_trn-doc.status_ = 'факт':U
      and buf_trn-doc.fact-date >= v-begin-date
  on error undo, return error
  :
    run waitfram-show in this-procedure
      (input substitute("Расчет архивов по категории &1. Документ &2"
             ,p-cat-code
             ,buf_trn-doc.doc-code
             )
      ) .
    do transaction
    on error undo, return error
    :
      define buffer buf_batchprocess for ub.batchprocess .
      define buffer update_batchprocess for ub.batchprocess .
      find first buf_BatchProcess exclusive-lock
        where buf_BatchProcess.bp_type     = p-btpr-type-code
          and buf_BatchProcess.bp_status   = 'N':U
          and buf_batchprocess.charkey_one = buf_trn-doc.doc-code
        no-error .
      if available buf_BatchProcess
      then do:
  find first update_batchprocess exclusive-lock
    where rowid(update_batchprocess) = rowid(buf_batchprocess)
    no-error .
  if not available update_batchprocess then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись пересчета архива" skip
      view-as alert-box error .
    undo, return error .
  end.
  if update_batchprocess.bp_status <> 'N':U then do:
    message
      vss-workfile vss-revision vss-description skip
      "Запись пересчета архива имеет статус, отличный от" 'N':U skip
      "BP_Type"       update_batchprocess.BP_Type       skip
      "BP_Status"     update_batchprocess.BP_Status     skip
      "Key#_One"      update_batchprocess.Key#_One      skip
      "Key#_Two"      update_batchprocess.Key#_Two      skip
      "Key#_Three"    update_batchprocess.Key#_Three    skip
      "CharKey_One"   update_batchprocess.CharKey_One   skip
      "CharKey_Two"   update_batchprocess.CharKey_Two   skip
      "CharKey_Three" update_batchprocess.CharKey_Three skip
      view-as alert-box error .
    undo, return error .
  end.
    define variable v-btpr_upd-today-4 as date      no-undo.
  define variable v-btpr_upd-time-4  as integer   no-undo.
  run cur-time in this-procedure ( output v-btpr_upd-today-4
                                 , output v-btpr_upd-time-4
                                 ).
  assign
    update_batchprocess.bp_status         = 'D':U
    update_batchprocess.bp_execcounttries = update_batchprocess.bp_execcounttries + 1
    update_batchprocess.bp_execuser_id    = g#userid
    update_batchprocess.bp_execsysdate    = v-btpr_upd-today-4
    update_batchprocess.bp_execsystime    = string(v-btpr_upd-time-4, 'hh:mm')
    update_batchprocess.bp_execsystimeint = v-btpr_upd-time-4
  .
      end.
      run trg/harhtclc.p
        (input p-cat-code
        ,input p-lock-code
        ,input p-btpr-type-code
        ,input buf_trn-doc.doc-code
        ) no-error.
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          string       ("Ошибка при первоначальном расчете межфирменных архивов:" + chr(10) +
                        "cat-code:" + chr(32) + string(p-cat-code) + chr(10) +
                        "документ:" + chr(32) + buf_trn-doc.doc-code + chr(10)
                        )
        view-as alert-box error .
        undo, return error
          ("Ошибка при первоначальном расчете межфирменных архивов:" + chr(10) +
                        "cat-code:" + chr(32) + string(p-cat-code) + chr(10) +
                        "документ:" + chr(32) + buf_trn-doc.doc-code + chr(10)
                        ).
      end.
    end.
  end.
  run holdattr-write in this-procedure
    (input p-cat-code
    ,input 'is-calc':U
    ,input 'false':u
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при записи атрибута - первоначальный расчет межфирменных архивов" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
end.
