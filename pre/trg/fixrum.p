block-level on error undo, throw.
define input parameter p-forced as logical no-undo .
define input parameter p-read-only as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Закачка конфигурации RUM".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-rum-version :
define output parameter p-check as logical no-undo .
define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-dopi3 as integer no-undo .
define variable v-dopi4 as integer no-undo .
define buffer buf_ruledict for ub.ruledict .
  do
  on error undo, return error
  :
    find first buf_ruledict no-lock where
              buf_ruledict.entry-id = 0  no-error.
    if (not available buf_ruledict
    or buf_ruledict.documentation <> "v16_0.13" )
    then do:
      assign
      v-dopi1 = integer(entry(2, buf_ruledict.documentation,  "."))
      v-dopi2 = integer(entry(2, "v16_0.13", "."))
      v-dopi3 = integer(entry(2, entry(1, buf_ruledict.documentation, "."), "_"))
      v-dopi4 = integer(entry(2, entry(1, "v16_0.13", "."), "_"))
      no-error .
      if error-status:error
      or v-dopi2 > v-dopi1
      or v-dopi4 > v-dopi3
      or left-trim(entry(1, buf_ruledict.documentation, "."), "v":U) < "16"
      then do:
        assign
        p-check = yes.
      end.
    end.
  end.
end procedure.
procedure get-rum-version :
define output parameter p-rum-version as character no-undo init ?.
define buffer buf_ruledict for ub.ruledict .
do
on error undo, return error
:
  find first buf_ruledict no-lock where
            buf_ruledict.entry-id = 0  no-error.
  if available buf_ruledict then do:
    p-rum-version = buf_ruledict.documentation.
  end.
end.
end procedure.
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info3 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info3, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info3, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info3 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info3, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info3 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info3, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info3, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info3, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info3, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info3, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info3 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info3 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info3, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info3 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info3 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
define stream imp-stream.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table temp-tables no-undo
field tbl-name as character
field buf-handle as handle
field tbl-handle as handle
index pi is unique primary
tbl-name.
define new shared temp-table temp-command no-undo
field command-name as character
field tbl-name as character
field uniq-key-rec as character
index pi is unique primary
tbl-name
command-name
uniq-key-rec
index icommand
command-name
tbl-name
uniq-key-rec
.
define buffer buf_temp-tables for temp-tables.
define variable v-check1 as logical no-undo .
define variable v-check2 as logical no-undo .
define variable v-force as logical no-undo .
define variable v-mes   as character no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-md5-signature as character no-undo .
define new shared temp-table tt-ruleset no-undo like ub.ruleset . find first buf_temp-tables where buf_temp-tables.tbl-name = "ruleset" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "ruleset"    buf_temp-tables.buf-handle = buffer tt-ruleset:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-prop-head no-undo like ub.prop-head . find first buf_temp-tables where buf_temp-tables.tbl-name = "prop-head" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "prop-head"    buf_temp-tables.buf-handle = buffer tt-prop-head:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-prop-ruleset no-undo like ub.prop-ruleset . find first buf_temp-tables where buf_temp-tables.tbl-name = "prop-ruleset" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "prop-ruleset"    buf_temp-tables.buf-handle = buffer tt-prop-ruleset:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-prop-map no-undo like ub.prop-map . find first buf_temp-tables where buf_temp-tables.tbl-name = "prop-map" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "prop-map"    buf_temp-tables.buf-handle = buffer tt-prop-map:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-prop-script no-undo like ub.prop-script . find first buf_temp-tables where buf_temp-tables.tbl-name = "prop-script" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "prop-script"    buf_temp-tables.buf-handle = buffer tt-prop-script:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-pscript-ruleset no-undo like ub.pscript-ruleset . find first buf_temp-tables where buf_temp-tables.tbl-name = "pscript-ruleset" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "pscript-ruleset"    buf_temp-tables.buf-handle = buffer tt-pscript-ruleset:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-rule-profile no-undo like ub.rule-profile . find first buf_temp-tables where buf_temp-tables.tbl-name = "rule-profile" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "rule-profile"    buf_temp-tables.buf-handle = buffer tt-rule-profile:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-rule-by-profile no-undo like ub.rule-by-profile . find first buf_temp-tables where buf_temp-tables.tbl-name = "rule-by-profile" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "rule-by-profile"    buf_temp-tables.buf-handle = buffer tt-rule-by-profile:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-ruledict no-undo like ub.ruledict . find first buf_temp-tables where buf_temp-tables.tbl-name = "ruledict" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "ruledict"    buf_temp-tables.buf-handle = buffer tt-ruledict:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-ruledict-param no-undo like ub.ruledict-param . find first buf_temp-tables where buf_temp-tables.tbl-name = "ruledict-param" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "ruledict-param"    buf_temp-tables.buf-handle = buffer tt-ruledict-param:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-rule no-undo like ub.rule . find first buf_temp-tables where buf_temp-tables.tbl-name = "rule" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "rule"    buf_temp-tables.buf-handle = buffer tt-rule:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-rule-script no-undo like ub.rule-script . find first buf_temp-tables where buf_temp-tables.tbl-name = "rule-script" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "rule-script"    buf_temp-tables.buf-handle = buffer tt-rule-script:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-rule-i-script no-undo like ub.rule-i-script . find first buf_temp-tables where buf_temp-tables.tbl-name = "rule-i-script" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "rule-i-script"    buf_temp-tables.buf-handle = buffer tt-rule-i-script:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-rule-by-set no-undo like ub.rule-by-set . find first buf_temp-tables where buf_temp-tables.tbl-name = "rule-by-set" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "rule-by-set"    buf_temp-tables.buf-handle = buffer tt-rule-by-set:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-prop-ref no-undo like ub.prop-ref . find first buf_temp-tables where buf_temp-tables.tbl-name = "prop-ref" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "prop-ref"    buf_temp-tables.buf-handle = buffer tt-prop-ref:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-rp-rule-param no-undo like ub.rp-rule-param . find first buf_temp-tables where buf_temp-tables.tbl-name = "rp-rule-param" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "rp-rule-param"    buf_temp-tables.buf-handle = buffer tt-rp-rule-param:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-rule-process no-undo like ub.rule-process . find first buf_temp-tables where buf_temp-tables.tbl-name = "rule-process" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "rule-process"    buf_temp-tables.buf-handle = buffer tt-rule-process:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define buffer buf_tt-ruledict for tt-ruledict.
run waitfram-show in this-procedure ("Реинициализация конфигурации RUM").
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if ( g#db-num > 0 ) then return.
  if not p-forced then do:
    run check-rum-version in this-procedure (output v-check1).
  end.
  if v-check1
  or p-forced
  then do:
     if v-check1
     and p-read-only then do:
        return error substitute("&1 &2 &3&4До начала работы с данной БД (режим RO) необходимо произвести вход в ОСНОВНУЮ БД!!!"
                                ,vss-workfile
                                ,vss-revision
                                ,vss-description
                                ,chr(10)).
     end.
    run gbl/md5.p (
       input  "cmp/fixrum.txt"
      ,output v-md5-signature
      ) .
    if v-md5-signature <> "102FB8E7686A0D9709EA4F3B552EA51C" then do:
      message
      substitute("Несовпадение файла эталонных записей по конфигурации RUM (fixrum.txt) с контрольным числом")
      view-as alert-box error .
      undo, return error .
    end.
    run gbl/filename.p ( input "cmp/fixrum.txt"
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ) no-error .
    if error-status:error then do:
      message
      substitute("Не найден файл эталонных записей по конфигурации RUM (fixrum.txt)")
      view-as alert-box error .
      undo, return error .
    end.
    run str/diallog.w (
          input ?
        ,input this-procedure
        ,input ('utl/upg-imp.p' + chr(4)  +
                '1' + chr(4) +
                '1' + chr(4) +
                '1' + chr(4) +
                '1')
        ,input v-full-path
        ,input yes
        ,input 'Прервать'
        ,input 'Чтение файла в память') no-error .
    if error-status:error then do:
      message
      substitute("Ошибка при чтении файла эталонных записей по конфигурации RUM (fixrum.txt)&1&2&1&3"
                   , chr(10)
                   , error-status:get-message(1)
                   , return-value )
      view-as alert-box error .
      undo, return error .
    end.
    for each buf_temp-tables
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      if valid-handle(buf_temp-tables.tbl-handle) then do:
        delete object buf_temp-tables.tbl-handle.
      end.
    end.
    define buffer buf_rule for ub.rule.
    find last buf_rule no-lock use-index pi.
    if current-value(s-rule-id, ub) < buf_rule.rule_Id then do:
      current-value(s-rule-id, ub) = buf_rule.rule_Id.
    end.
    define buffer buf_rule-script for ub.rule-script.
    find last buf_rule-script no-lock use-index pi.
    if current-value(s-rule-script-id, ub) < buf_rule-script.script_Id then do:
      current-value(s-rule-script-id, ub) = buf_rule-script.script_Id.
    end.
    define variable v-rule-profile-uniq-key-rec as character no-undo .
    define variable v-mess as character no-undo .
    define buffer buf_rule-profile for ub.rule-profile.
    define buffer buf_ruledict for ub.ruledict.
    define buffer buf_ruledict-param for ub.ruledict-param.
    for each buf_rule-profile no-lock
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      run gen-key-rec in this-procedure (
                                        input  'rule-profile':U
                                        ,input buffer buf_rule-profile:handle
                                        ,output v-rule-profile-uniq-key-rec).
      for first buf_ruledict no-lock where
              buf_ruledict.uniq-key-rec = v-rule-profile-uniq-key-rec,
          each buf_ruledict-param no-lock where
              buf_ruledict-param.entry-id = buf_ruledict.entry-id
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):
        if buf_ruledict-param.param-data-type = 'character':U
        and buf_ruledict-param.param-2-data-type = "xsd"
        then do:
          run rul/rdp-clob.p ( buffer buf_ruledict-param
                              ,input  'ИЗМЕНЕНИЕ':U) no-error.
          if error-status:error then  do:
                        message substitute("Не удалось сохранить CLOB &1:&2&3&2&4"                                 ,buf_ruledict-param.init-value-character                                 ,chr(10)                                 , error-status:get-message(1)                                 , return-value ) view-as alert-box.
            undo, return error .
          end.
        end.
      end.
    end.
  end.
end.
run waitfram-hide in this-procedure .
function get-order-id returns integer ( input p-profile-id as integer
                                       ,input p-codex-id as integer
                                       ,input p-ruleset-id as integer
                                       ,input p-rp-order-id as integer
                                       ,input p-call-id as character
                                       ,input p-once-more as integer
                                       ):
define variable v-ii as integer   no-undo .
define buffer buf_rule-by-call for ub.rule-by-call.
for each buf_rule-by-call no-lock where
        buf_rule-by-call.call_id = p-call-id
    and buf_rule-by-call.codex_id = p-codex-id
    and buf_rule-by-call.ruleset_id = p-ruleset-id
    and buf_rule-by-call.once-more = p-once-more
    and buf_rule-by-call.profile_id = p-profile-id
    :
    if v-ii = p-rp-order-id then do:
       return buf_rule-by-call.order_id.
    end.
    v-ii = v-ii + 1.
end.
return -1.
end.
procedure ruledict-param_add :
define input parameter p-bh as handle no-undo .
  run ruledict-param_add-update in this-procedure ( input p-bh, input p-bh:rowid) no-error.
  if error-status :error then undo, return error return-value .
end.
procedure ruledict-param_update :
define input parameter p-bh-old as handle no-undo .
define input parameter p-bh-new-temp as handle no-undo .
  run ruledict-param_add-update in this-procedure ( input p-bh-new-temp, input p-bh-old:rowid) no-error.
  if error-status :error then undo, return error return-value .
end.
procedure ruledict-param_add-update :
define input parameter p-bh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_ruledict for ub.ruledict.
  do
  on error undo, return error
  :
    find first buf_ruledict-param where
              rowid(buf_ruledict-param) = p-rowid.
    if p-bh::param-data-type = 'character':U
    and p-bh::param-2-data-type = "xsd"
    then do:
      find first buf_ruledict no-lock where
                buf_ruledict.entry-id = buf_ruledict-param.entry-id  no-error.
      if available buf_ruledict
      and buf_ruledict.entry-type = 'rule-profile':U then do:
        run rul/rdp-clob.p ( buffer buf_ruledict-param
                            ,input (if new(buf_ruledict-param) then 'ДОБАВЛЕНИЕ':U else 'ИЗМЕНЕНИЕ':U)) no-error.
        if error-status:error then  do:
                    message substitute("Не удалось сохранить CLOB &1:&2&3&2&4"                               ,p-bh::init-value-character                               ,chr(10)                               , error-status:get-message(1)                               , return-value ) view-as alert-box.
          undo, return error .
        end.
      end.
    end.
  end.
end procedure.
procedure ruledict-param_delete :
define input parameter p-bh as handle no-undo .
define buffer buf_ruledict-param for ub.ruledict-param.
  do
  on error undo, return error
  :
    find first buf_ruledict-param where
              rowid(buf_ruledict-param) = p-bh:rowid.
    if buf_ruledict-param.param-data-type = 'character':U
    and buf_ruledict-param.param-2-data-type = "xsd"
    then do:
      run rul/rdp-clob.p ( buffer buf_ruledict-param
                          ,input  'удаление':U)) no-error.
      if error-status:error then  do:
                message substitute("Не удалось сохранить CLOB &1:&2&3&2&4"                             ,buf_ruledict-param.init-value-character                             ,chr(10)                             , error-status:get-message(1)                             , return-value ) view-as alert-box.
        undo, return error .
      end.
    end.
  end.
end procedure.
procedure rp-rule-param_add :
define input parameter p-bh as handle no-undo .
define variable v-rule-profile-uniq-key-rec as character no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-order-id as integer   no-undo .
define variable v-order-id2 as integer   no-undo .
define buffer buf_rp-rule-param for ub.rp-rule-param.
define buffer buf2_rp-rule-param for ub.rp-rule-param.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf2_rule-call-param for ub.rule-call-param.
define buffer buf_rule-profile for ub.rule-profile.
define buffer buf_ruledict for ub.ruledict.
define buffer buf2_ruledict for ub.ruledict.
define buffer buf_ruledict2 for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf2_ruledict-param for ub.ruledict-param.
define buffer buf_ruledict-param2 for ub.ruledict-param.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf2_rule-by-call for ub.rule-by-call.
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_rule for ub.rule.
define buffer buf2_rule for ub.rule.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_rp-rule-param where
            rowid(buf_rp-rule-param) = p-bh:rowid.
  find first buf_rule-profile where buf_rule-profile.profile_id = buf_rp-rule-param.profile_id.
  run gen-key-rec in this-procedure (
                                    input  'rule-profile':U
                                    ,input buffer buf_rule-profile:handle
                                    ,output v-rule-profile-uniq-key-rec).
  find first buf_ruledict2 no-lock where
          buf_ruledict2.entry-type = 'rule-profile':U
      and  buf_ruledict2.uniq-key-rec = v-rule-profile-uniq-key-rec.
  find first buf_ruledict-param2 no-lock where
        buf_ruledict-param2.entry-id = buf_ruledict2.entry-id
    and buf_ruledict-param2.param-name = buf_rp-rule-param.rp-param-name.
  for each buf_rp-by-call exclusive-lock where
          buf_rp-by-call.profile_id = buf_rp-rule-param.profile_id
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    v-order-id = get-order-id ( input buf_rp-rule-param.profile_id
                              ,input buf_rp-rule-param.codex_id
                              ,input buf_rp-rule-param.ruleset_id
                              ,input buf_rp-rule-param.rp_order_id
                              ,input buf_rp-by-call.call_id
                              ,input buf_rp-by-call.once-more
                              ).
    if v-order-id <> -1 then do:
      find first buf_rule-by-call exclusive-lock where
            buf_rule-by-call.call_id = buf_rp-by-call.call_id
        and buf_rule-by-call.codex_id = buf_rp-rule-param.codex_id
        and buf_rule-by-call.ruleset_id = buf_rp-rule-param.ruleset_id
        and buf_rule-by-call.order_id = v-order-id.
      for each buf2_rp-rule-param no-lock where
                buf2_rp-rule-param.profile_id = buf_rp-rule-param.profile_id
            and buf2_rp-rule-param.rp-param-name = buf_rp-rule-param.rp-param-name:
        v-order-id2 = get-order-id ( input buf2_rp-rule-param.profile_id
                                  ,input buf2_rp-rule-param.codex_id
                                  ,input buf2_rp-rule-param.ruleset_id
                                  ,input buf2_rp-rule-param.rp_order_id
                                  ,input buf_rp-by-call.call_id
                                  ,input buf_rp-by-call.once-more
                                  ).
        find first buf2_rule-by-call exclusive-lock where
              buf2_rule-by-call.call_id = buf_rp-by-call.call_id
          and buf2_rule-by-call.codex_id = buf2_rp-rule-param.codex_id
          and buf2_rule-by-call.ruleset_id = buf2_rp-rule-param.ruleset_id
          and buf2_rule-by-call.order_id = v-order-id2.
        find first buf2_rule no-lock where
                  buf2_rule.rule_id = buf2_rp-rule-param.rule_id.
        find first buf2_ruledict no-lock where
                buf2_ruledict.entry-type = 'rule':U
            and  buf2_ruledict.uniq-key-rec = buf2_rule.uniq-key-rec.
          find first buf2_ruledict-param where
                    buf2_ruledict-param.entry-id = buf2_ruledict.entry-id
                and buf2_ruledict-param.param-name = buf2_rp-rule-param.rule-param-name
                    .
          find first buf2_rule-call-param where
                    buf2_rule-call-param.call_id = buf2_rule-by-call.call_id
                and buf2_rule-call-param.codex_id = buf2_rule-by-call.codex_id
                and buf2_rule-call-param.ruleset_id = buf2_rule-by-call.ruleset_id
                and buf2_rule-call-param.order_id = buf2_rule-by-call.order_id
                and buf2_rule-call-param.param-name = buf2_ruledict-param.param-name no-error.
         if available buf2_rule-call-param then leave.
      end.
      find first buf_rule no-lock where
                buf_rule.rule_id = buf_rule-by-call.rule_id.
      find first buf_ruledict no-lock where
              buf_ruledict.entry-type = 'rule':U
          and  buf_ruledict.uniq-key-rec = buf_rule.uniq-key-rec.
        find first buf_ruledict-param where
                  buf_ruledict-param.entry-id = buf_ruledict.entry-id
              and buf_ruledict-param.param-name = buf_rp-rule-param.rule-param-name
                  .
        find first buf_rule-call-param where
                  buf_rule-call-param.call_id = buf_rule-by-call.call_id
              and buf_rule-call-param.codex_id = buf_rule-by-call.codex_id
              and buf_rule-call-param.ruleset_id = buf_rule-by-call.ruleset_id
              and buf_rule-call-param.order_id = buf_rule-by-call.order_id
              and buf_rule-call-param.param-name = buf_ruledict-param.param-name no-error.
        if not available buf_rule-call-param then do:
          create buf_rule-call-param.
          assign
          buf_rule-call-param.call#_id = buf_rule-by-call.call#_id
          buf_rule-call-param.call_id = buf_rule-by-call.call_id
          buf_rule-call-param.codex_id = buf_rule-by-call.codex_id
          buf_rule-call-param.ruleset_id = buf_rule-by-call.ruleset_id
          buf_rule-call-param.order_id = buf_rule-by-call.order_id
          buf_rule-call-param.param-name = buf_ruledict-param.param-name
          .
        end.
        assign
        buf_rule-call-param.rule_id = buf_rule-by-call.rule_id
        buf_rule-call-param.p-index = 0
        buf_rule-call-param.param-des = buf_ruledict-param.documentation
        buf_rule-call-param.param-num = buf_ruledict-param.param-num
        buf_rule-call-param.param-label = buf_ruledict-param.param-label
        buf_rule-call-param.param-mode = buf_ruledict-param.param-mode
        buf_rule-call-param.param-data-type = buf_ruledict-param.param-data-type
        buf_rule-call-param.param-2-data-type = buf_ruledict-param.param-2-data-type
        buf_rule-call-param.param-3-data-type = buf_ruledict-param.param-3-data-type
        buf_rule-call-param.param-value-character = buf_ruledict-param2.init-value-character
        buf_rule-call-param.param-value-date = buf_ruledict-param2.init-value-date
        buf_rule-call-param.param-value-decimal = buf_ruledict-param2.init-value-decimal
        buf_rule-call-param.param-value-integer = buf_ruledict-param2.init-value-integer
        buf_rule-call-param.param-value-logical = buf_ruledict-param2.init-value-logical
        buf_rule-call-param.profile_id          = buf_rule-by-call.profile_id
        buf_rule-call-param.once-more           = buf_rule-by-call.once-more
        .
        if available buf2_rule-call-param then do:
          assign
          buf_rule-call-param.param-value-character = buf2_rule-call-param.param-value-character
          buf_rule-call-param.param-value-date      = buf2_rule-call-param.param-value-date
          buf_rule-call-param.param-value-decimal   = buf2_rule-call-param.param-value-decimal
          buf_rule-call-param.param-value-integer   = buf2_rule-call-param.param-value-integer
          buf_rule-call-param.param-value-logical   = buf2_rule-call-param.param-value-logical
          .
        end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
      if buf_ruledict-param.param-2-data-type = "r-b" then do:
        buf_rule-call-param.param-value-character = (if v-curr-r-b = 'rubl':U
                                                        then 'rubl':U
                                                        else 'base':U).
      end.
      if available buf_rule-call-param then do:
        run str/callnews.p
          (input 'rule-call-param':U
          ,input (buffer buf_rule-call-param:handle)
          ) no-error .
        if error-status:error then do:
                        message substitute("Не удалось сохранить rule-call-param&1:&2&1&3"                                 ,chr(10)                                 , error-status:get-message(1)                                 , return-value ) view-as alert-box.
          undo main-block, return error .
        end.
      end.
    end.
  end.
end.
end procedure.
procedure rp-rule-param_delete :
define input parameter p-bh as handle no-undo .
define variable v-order-id as integer   no-undo .
define buffer buf_rp-rule-param for ub.rp-rule-param.
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_rule-call-param for ub.rule-call-param.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_rp-rule-param where
            rowid(buf_rp-rule-param) = p-bh:rowid.
  for each buf_rp-by-call exclusive-lock where
          buf_rp-by-call.profile_id = buf_rp-rule-param.profile_id
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    v-order-id = get-order-id ( input buf_rp-rule-param.profile_id
                              ,input buf_rp-rule-param.codex_id
                              ,input buf_rp-rule-param.ruleset_id
                              ,input buf_rp-rule-param.rp_order_id
                              ,input buf_rp-by-call.call_id
                              ,input buf_rp-by-call.once-more
                              ).
   if v-order-id <> -1 then do:
     for each buf_rule-call-param exclusive-lock where
          buf_rule-call-param.call_id = buf_rp-by-call.call_id
      and buf_rule-call-param.codex_id = buf_rp-rule-param.codex_id
      and buf_rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
      and buf_rule-call-param.order_id = v-order-id
      and buf_rule-call-param.param-name = buf_rp-rule-param.rule-param-name
      and buf_rule-call-param.rule_id = buf_rp-rule-param.rule_id
      and buf_rule-call-param.profile_id  = buf_rp-rule-param.profile_id
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :
        run nws/cmd-del.p
          ( input 'rule-call-param':U
          ,input (buffer buf_rule-call-param:handle)
          ,input ''
          ) no-error .
        if error-status :error then do:
          if error-status:error then do:
                            message substitute("Не удалось удалить rule-call-param&1:&2&1&3"                                   ,chr(10)                                   , error-status:get-message(1)                                   , return-value ) view-as alert-box.
             undo main-block, return error .
          end.
        end.
        delete buf_rule-call-param.
     end.
   end.
  end.
end.
end procedure.
procedure rule-by-profile_update :
define input parameter p-bh-old as handle no-undo .
define input parameter p-bh-new-temp as handle no-undo .
define variable v-order-id as integer   no-undo .
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_rp-by-call for ub.rp-by-call.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if p-bh-old::is_dynamic <> p-bh-new-temp::is_dynamic
  and p-bh-old::codex_id = p-bh-new-temp::codex_id
  and p-bh-old::ruleset_id = p-bh-new-temp::ruleset_id
  and p-bh-old::profile_id = p-bh-new-temp::profile_id
  and p-bh-old::rule_id = p-bh-new-temp::rule_id
  and p-bh-old::rp_order_id = p-bh-new-temp::rp_order_id then do:
    for each buf_rp-by-call share-lock where
            buf_rp-by-call.profile_id = p-bh-old::profile_id
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      v-order-id = get-order-id ( input p-bh-old::profile_id
                                ,input p-bh-old::codex_id
                                ,input p-bh-old::ruleset_id
                                ,input p-bh-old::rp_order_id
                                ,input buf_rp-by-call.call_id
                                ,input buf_rp-by-call.once-more
                                ).
      if v-order-id <> -1 then do:
        find first buf_rule-by-call share-lock where
            buf_rule-by-call.call_id = buf_rp-by-call.call_id
        and buf_rule-by-call.profile_id = p-bh-old::profile_id
        and buf_rule-by-call.codex_id = p-bh-old::codex_id
        and buf_rule-by-call.ruleset_id = p-bh-old::ruleset_id
        and buf_rule-by-call.rule_id = p-bh-old::rule_id
        and buf_rule-by-call.order_id = v-order-id no-error.
        if available buf_rule-by-call then do:
          if p-bh-old::is_dynamic = yes then do:
            assign
            buf_rule-by-call.can-calc = yes
            buf_rule-by-call.can-run = yes
            .
          end.
          if p-bh-old::is_dynamic = no
          and p-bh-new-temp::is_dynamic = yes
          then do:
            assign
            buf_rule-by-call.is_dynamic = yes
            .
          end.
          run str/callnews.p
            (input 'rule-by-call':U
            ,input (buffer buf_rule-by-call:handle)
            ) no-error .
          if error-status:error then do:
                        message substitute("Не удалось сохранить rule-by-call-param&1:&2&1&3"                                 ,chr(10)                                 , error-status:get-message(1)                                 , return-value ) view-as alert-box.
            undo main-block, return error .
        end.
      end.
    end.
    end.
  end.
end.
end procedure.
procedure rule-by-profile_add :
define input parameter p-bh as handle no-undo .
define variable v-order-id as integer no-undo .
define variable v-exist as logical   no-undo .
define variable v-rule-by-call-uniq-key-rec as character no-undo .
define buffer buf_rule-by-profile for ub.rule-by-profile.
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_rule-profile for ub.rule-profile.
define buffer bufo_rule-by-profile  for ub.rule-by-profile .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_rule for ub.rule.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_rule-by-profile where
            rowid(buf_rule-by-profile) = p-bh:rowid.
  find first buf_rule-profile where
            buf_rule-profile.profile_id = buf_rule-by-profile.profile_id.
  for each buf_rp-by-call exclusive-lock where
          buf_rp-by-call.profile_id = buf_rule-by-profile.profile_id
  break
  by buf_rp-by-call.call_id
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    v-exist = no.
    find first bufo_rule-by-profile no-lock where
              bufo_rule-by-profile.profile_id = buf_rule-by-profile.profile_id
          and bufo_rule-by-profile.codex_id = buf_rule-by-profile.codex_id
          and bufo_rule-by-profile.ruleset_id = buf_rule-by-profile.ruleset_id
          and bufo_rule-by-profile.rp_order_id = buf_rule-by-profile.rp_order_id no-error.
    if available bufo_rule-by-profile  and
    bufo_rule-by-profile.rule_id <> buf_rule-by-profile.rule_id then do:
      v-order-id = get-order-id ( input buf_rp-by-call.profile_id
                                ,input buf_rule-by-profile.codex_id
                                ,input buf_rule-by-profile.ruleset_id
                                ,input buf_rule-by-profile.rp_order_id
                                ,input buf_rp-by-call.call_id
                                ,input buf_rp-by-call.once-more
                                ).
      if v-order-id <> -1 then do:
        find first buf_rule-by-call where
                  buf_rule-by-call.call_id = buf_rp-by-call.call_id
              and buf_rule-by-call.profile_id = buf_rule-by-profile.profile_id
              and buf_rule-by-call.once-more = buf_rp-by-call.once-more
              and buf_rule-by-call.codex_id = buf_rule-by-profile.codex_id
              and buf_rule-by-call.ruleset_id  = buf_rule-by-profile.ruleset_id
              and buf_rule-by-call.order_id = v-order-id
              and buf_rule-by-call.rule_id = bufo_rule-by-profile.rule_id
              no-error.
        if available buf_rule-by-call then do:
          v-exist = yes.
          for each buf_rule-call-param exclusive-lock where
                  buf_rule-call-param.call_id = buf_rule-by-call.call_id
              and buf_rule-call-param.codex_id = buf_rule-by-call.codex_id
              and buf_rule-call-param.ruleset_id = buf_rule-by-call.ruleset_id
              and buf_rule-call-param.order_id = buf_rule-by-call.order_id
          on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
          on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
          on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
          :
            assign
            buf_rule-call-param.rule_id = buf_rule-by-profile.rule_id.
            run str/callnews.p
              (input 'rule-call-param':U
              ,input (buffer buf_rule-call-param:handle)
              ) no-error .
            if error-status:error then do:
                            message substitute("Не удалось сохранить rule-call-param&1:&2&1&3"                                   ,chr(10)                                   , error-status:get-message(1)                                   , return-value ) view-as alert-box.
              undo main-block, return error .
            end.
        end.
      end.
    end.
  end.
    if not v-exist then do:
      FIND FIRST buf_rule NO-LOCK WHERE
                    buf_rule.RULE_id = buf_rule-by-profile.RULE_id .
      FIND LAST buf_rule-by-call WHERE
                buf_rule-by-call.codex_id =  buf_rule-by-profile.codex_id
            AND buf_rule-by-call.ruleset_id = buf_rule-by-profile.ruleset_id
      USE-INDEX imain NO-ERROR.
      IF AVAILABLE buf_rule-by-call THEN DO:
        v-order-id = buf_rule-by-call.order_id + 1.
      END.
      ELSE DO:
        v-order-id = 0.
      END.
      CREATE buf_rule-by-call.
      BUFFER-COPY buf_rule-by-profile TO buf_rule-by-call
      ASSIGN
      buf_rule-by-call.order_id = v-order-id
      buf_rule-by-call.algo-des = buf_rule-profile.NAME + chr(10) + buf_rule.NAME
      buf_rule-by-call.is_dynamic = buf_rule-by-profile.IS_dynamic
      buf_rule-by-call.can-calc = (IF buf_rule-by-call.is_dynamic
                                  THEN  no
                                  ELSE YES)
      buf_rule-by-call.call_id = buf_rp-by-call.call_id
    buf_rule-by-call.call#_id = buf_rp-by-call.call#_id
      buf_rule-by-call.once-more = buf_rp-by-call.once-more
      .
    run gen-key-rec in this-procedure (
                                      input  'rule-by-call':U
                                      ,input buffer buf_rule-by-call:handle
                                      ,output v-rule-by-call-uniq-key-rec).
    buf_rule-by-call.uniq-key-rec = v-rule-by-call-uniq-key-rec    .
    run str/callnews.p
      (input 'rule-by-call':U
      ,input (buffer buf_rule-by-call:handle)
      ) no-error .
    if error-status:error then do:
            message substitute("Не удалось сохранить rule-by-call&1:&2&1&3"                           ,chr(10)                           , error-status:get-message(1)                           , return-value ) view-as alert-box.
      undo main-block, return error .
    end.
    end.
end.
end.
end procedure.
procedure rule-by-profile_delete :
define input parameter p-bh as handle no-undo .
define variable v-order-id as integer no-undo .
define buffer buf_rule-by-profile for ub.rule-by-profile.
define buffer buf_rule-by-call for ub.rule-by-call.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_rule-by-profile where
            rowid(buf_rule-by-profile) = p-bh:rowid.
  for each buf_rule-by-call exclusive-lock where
          buf_rule-by-call.profile_id = buf_rule-by-profile.profile_id
      and buf_rule-by-call.codex_id = buf_rule-by-profile.codex_id
      and buf_rule-by-call.ruleset_id = buf_rule-by-profile.ruleset_id
      and buf_rule-by-call.rule_id = buf_rule-by-profile.rule_id
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    run nws/cmd-del.p
      ( input 'rule-by-call':U
      ,input (buffer ub.rule-by-call:handle)
      ,input ''
      ) no-error .
    if error-status :error then do:
            message substitute("Не удалось удалить rule-call-param&1:&2&1&3"                           ,chr(10)                           , error-status:get-message(1)                           , return-value ) view-as alert-box.
      undo main-block, return error .
    end.
    delete buf_rule-by-call.
    .
  end.
end.
end procedure.
