block-level on error undo, throw.
define input  parameter p-host-code    as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: paypvavt.p $":u .
define variable vss-archive     as character no-undo init "$Archive: str/paypvavt.p $":u .
define variable vss-description as character no-undo init "Автомат. оплата фин. обязательств" .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-b-code :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter p-b-code  like ub.bar-code.b-code       no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-b-code). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-b-code). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-b-code). endkey", vss-workfile )
  :
    define buffer buf_thbj-attr     for ub.thbj-attr .
    define buffer buf_sys-ctrl   for ub.sys-ctrl .
    define buffer buf_code-range for ub.code-range .
    define variable l-code         as   integer              no-undo .
    define variable v-db-num       like ub.db.db-num         no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .
    if type-code = 'sslc':U
    or type-code = 'ssgb':U
    then do:
      message
        "Нельзя генерировать локальный или глобальный взвешиваемый код." skip
        "Обратитесь к администратору системы."
        view-as alert-box error .
      undo, return error (if type-code = 'sslc':U then "loc-ss-code":U else "gbl-ss-code" ) .
    end.
    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    run get-next-seq( input  type-code,
                      output l-code
                    ).
    find first buf_sys-ctrl no-lock.
    if type-code = 'sclc':U
    or type-code = 'pglc':U
    then do:
      assign
        v-db-num = 0
      .
    end.
    else do:
      assign
        v-db-num = buf_sys-ctrl.db-num
      .
    end.
    find first buf_code-range no-lock
      where buf_code-range.db-num     = v-db-num
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "a"
      use-index stts
      no-error .
    if available buf_code-range
       and l-code <= buf_code-range.last-code
       and l-code >= buf_code-range.first-code then do:
      assign
        p-b-code = l-code
      .
    end.
    else do:
      if available buf_code-range
         and l-code < buf_code-range.last-code then do:
        message
          substitute( "Последовательность для создания кодов с типом &1 имеет неверное значение.", type-code ) skip
          "Обратитесь к администратору системы."
          view-as alert-box error .
        undo, return error "sequence":U .
      end.
      do transaction
      on error undo, return error
      :
        find first buf_thbj-attr exclusive-lock
          where buf_thbj-attr.upper-prop-code = 'code-range':U
            and buf_thbj-attr.prop-code = cfg-param-code
            and buf_thbj-attr.obj-type   = 'БД':U
            and buf_thbj-attr.obj-code   = v-db-num
          no-error .
        if not available buf_thbj-attr then do:
          find first buf_thbj-attr exclusive-lock
            where buf_thbj-attr.upper-prop-code = 'code-range':U
              and buf_thbj-attr.prop-code = cfg-param-code
              and buf_thbj-attr.obj-type   = ''
              and buf_thbj-attr.obj-code   = 0
            no-error .
          if not available buf_thbj-attr then do:
            if not locked buf_thbj-attr then do:
              message
                substitute( "Отсутствует параметр 'длина диапазона кодов' (&1) для БД &2.", cfg-param-code, buf_sys-ctrl.db-num ) skip
                "Обратитесь к администратору системы."
                view-as alert-box error .
            end.
            undo, return error "config":U .
          end.
        end.
        run get-next-seq( input type-code,
                          output l-code
                        ).
        find first buf_code-range
          where buf_code-range.db-num     = v-db-num
            and buf_code-range.range-type = type-code
            and buf_code-range.stts       = "a"
          use-index stts
          no-error .
        if available buf_code-range
        and l-code <= buf_code-range.last-code
        and l-code >= buf_code-range.first-code
        then do:
          assign
            p-b-code = l-code
          .
        end.
        else do:
          if available buf_code-range then do:
            assign
              buf_code-range.stts = "u"
            .
          end.
          find first buf_code-range
            where buf_code-range.db-num     = v-db-num
              and buf_code-range.range-type = type-code
              and buf_code-range.stts       = "f"
            use-index stts
            no-error .
          if not available buf_code-range then do:
            message
              substitute( "Отсутствует свободный диапазон для кодов с типом &1.", type-code ) skip
              "Обратитесь к администратору системы"
              view-as alert-box error .
            undo, return error "code-range":U .
          end.
          assign
            buf_code-range.stts           = "a"
          .
          if buf_code-range.first-code = 1 then do:
            run set-seq-cr( input type-code,
                            input buf_code-range.first-code
                          ).
            assign
              p-b-code = 1
            .
          end.
          else do:
            run set-seq-cr( input type-code,
                            input ( buf_code-range.first-code - 1 )
                          ).
            run get-next-seq( input type-code,
                              output p-b-code
                            ).
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure get-next-seq :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter next-seq  as   integer                  no-undo .
  do
  on error  undo, return error substitute( "&1 (get-next-seq). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-next-seq). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-next-seq). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          next-seq = next-value(s-bcgb-code, ub)
        .
      end.
      when 'scgb':U then do:
        assign
          next-seq = next-value(s-scgb-code, ub)
        .
      end.
      when 'sclc':U then do:
        assign
          next-seq = next-value(s-sclc-code, ub)
        .
      end.
      when 'pglc':U then do:
        assign
          next-seq = next-value(s-pglc-code, ub)
        .
      end.
      when 'dcgb':U then do:
        assign
          next-seq = next-value(s-dcgb-code, ub)
        .
      end.
      when 'ctgb':U then do:
        assign
          next-seq = next-value(s-ctgb-code, ub)
        .
      end.
      when 'drgb':U then do:
        assign
          next-seq = next-value(s-drgb-code, ub)
        .
      end.
      when 'fmgb':U then do:
        assign
          next-seq = next-value(s-fmgb-code, ub)
        .
      end.
      when 'pngb':U then do:
        assign
          next-seq = next-value(s-pngb-code, ub)
        .
      end.
      when 'cagb':U then do:
        assign
          next-seq = next-value(s-cagb-code, ub)
        .
      end.
      when 'fdgb':U then do:
        assign
          next-seq = next-value(s-fin-doc, ub)
        .
      end.
    end case.
  end.
end procedure.
procedure set-seq-cr :
  define input parameter type-code like ub.code-range.range-type no-undo .
  define input parameter set-val   like ub.code-range.first-code no-undo .
  do
  on error  undo, return error substitute( "&1 (set-seq-cr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (set-seq-cr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (set-seq-cr). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          current-value(s-bcgb-code, ub) = set-val
        .
      end.
      when 'scgb':U then do:
        assign
          current-value(s-scgb-code, ub) = set-val
        .
      end.
      when 'sclc':U then do:
        assign
          current-value(s-sclc-code, ub) = set-val
        .
      end.
      when 'pglc':U then do:
        assign
          current-value(s-pglc-code, ub) = set-val
        .
      end.
      when 'dcgb':U then do:
        assign
          current-value(s-dcgb-code, ub) = set-val
        .
      end.
      when 'ctgb':U then do:
        assign
          current-value(s-ctgb-code, ub) = set-val
        .
      end.
      when 'drgb':U then do:
        assign
          current-value(s-drgb-code, ub) = set-val
        .
      end.
      when 'fmgb':U then do:
        assign
          current-value(s-fmgb-code, ub) = set-val
        .
      end.
      when 'pngb':U then do:
        assign
          current-value(s-pngb-code, ub) = set-val
        .
      end.
      when 'cagb':U then do:
        assign
          current-value(s-cagb-code, ub) = set-val
        .
      end.
      when 'fdgb':U then do:
        assign
          current-value(s-fin-doc, ub) = set-val
        .
      end.
    end case.
  end.
end procedure.
procedure new-bcod-gen-code-range :
  do
  on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
  :
    define input parameter p-db-num  like ub.db.db-num             no-undo .
    define input parameter type-code like ub.code-range.range-type no-undo .
    define buffer buf_code-range      for ub.code-range .
    define buffer last_code-range     for ub.code-range .
    define buffer last-1_code-range   for ub.code-range .
    define buffer last-2_code-range   for ub.code-range .
    define buffer last-3_code-range   for ub.code-range .
    define buffer buf_sys-ctrl        for ub.sys-ctrl .
    define variable conf-par       as character no-undo .
    define variable par-type       as character no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .
    define variable v-cre-cdrg as logical   no-undo .
    define variable v-cre-str  as character no-undo .
    define variable v-cr1      as integer no-undo .
    define variable v-cr2      as integer no-undo .
    define variable v-cr3      as integer no-undo .
    define variable v-cmax     as integer no-undo .
    find first buf_sys-ctrl no-lock .
    if buf_sys-ctrl.db-num <> 0 and type-code <> 'cagb':U then do:
      undo, return error substitute("&1 &2 &3&4Диапазоны кодов можно создавать только в ГБД&4База данных &5"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    , p-db-num
                                   ).
    end.
    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    for each buf_code-range
      where buf_code-range.db-num     = -1
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "f"
    by buf_code-range.first-code
    on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
    :
      assign
        buf_code-range.db-num = p-db-num
      .
      return .
    end.
    assign
      v-cre-cdrg = TRUE
    .
    case type-code:
      when 'sclc':U
      or when 'scgb':U
      or when 'pglc':U
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = 'sclc':U
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = 'scgb':U
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = 'pglc':U
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
        if last_code-range.last-code + 1 > 99999 then do:
          assign
            v-cre-cdrg = FALSE
          .
        end.
      end.
      when 'bcgb':U
      or when 'sslc':U
      or when 'ssgb':U
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = 'sslc':U
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = 'bcgb':U
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = 'ssgb':U
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
      end.
      otherwise do:
        find last last_code-range no-lock
          where last_code-range.range-type = type-code
          no-error .
      end.
    end case.
    if not available last_code-range then do:
      undo, return error substitute("&1 &2 &3&4В БД нет ни одного диапазона с типом &5&4Не была проведена инициализация диапазонов!"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    , chr(10)
                                    , type-code
                                   ) .
    end.
    define variable v-mes3 as character no-undo .
    define variable v-param-type3 as character no-undo .
    define variable v-value-character3 as INTEGER no-undo .
    define variable v-value-date3 as date no-undo .
    define variable v-value-decimal3 as decimal no-undo .
    define variable v-value-integer3 AS integer no-undo .
    define variable v-value-logical3 AS LOGICAL no-undo .
    define variable v-tth3 as handle no-undo .
    run adm/shattri.p (
        input "get":U
        ,input  'БД':U
        ,input  p-db-num
        ,input  'code-range':U
        ,input  cfg-param-code
        ,output v-value-character3
        ,output v-value-date3
        ,output v-value-decimal3
        ,output v-value-integer3
        ,output v-value-logical3
        ,output v-param-type3
        ,INPUT-OUTPUT table-handle v-tth3
        ) no-error .
    if error-status :error then do:
      delete object v-tth3.
      v-mes3 = substitute("Ошибка при получении размера диапазона собственных глобальных кодов&2&1&2&3"
                         , error-status:get-message(1)
                         , chr(10)
                         , return-value ).
      undo, return error v-mes3.
    end.
    delete object v-tth3.
    if v-cre-cdrg = TRUE then do:
      create buf_code-range .
      assign
        buf_code-range.db-num     = p-db-num
        buf_code-range.range-type = type-code
        buf_code-range.stts       = "f"
        buf_code-range.first-code = last_code-range.last-code + 1
        buf_code-range.last-code  = last_code-range.last-code + integer(v-value-integer3)
        v-cre-str = "Свободный диапазон успешно создан"
      .
    end.
    else do:
      assign
        v-cre-str = "Нет возможности создать свободный диапазон." + chr(10)
                    + substitute( "Превышен предел диапазонов c типом &1", type-code )
      .
    end.
  end.
  return v-cre-str .
end procedure.
procedure gen-new-code-range-if-neces :
  define input parameter v-db-num           like ub.db.db-num             no-undo .
  define input parameter v-range-type       like ub.code-range.range-type no-undo .
  define input parameter v-cur-code         as   integer                  no-undo .
  define input parameter v-g#news           as   logical                  no-undo .
  define input parameter v-g#db-num         like ub.db.db-num             no-undo .
  define input parameter v-g#news-source-db like ub.db.db-num             no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-new-code-range-if-neces). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-new-code-range-if-neces). endkey", vss-workfile )
  :
    define variable l-code-range-exist as logical   no-undo init false .
    define variable v-db-for-send      as character no-undo .
    define buffer buf_code-range  for ub.code-range .
    define buffer buf1_code-range for ub.code-range .
    define buffer buf_db          for ub.db .
    find first buf_code-range
      where buf_code-range.range-type = v-range-type
        and buf_code-range.last-code >= v-cur-code
      use-index last-codei
      no-error .
    if
    (
       available buf_code-range
       and
      (buf_code-range.db-num = v-db-num
        and
      buf_code-range.first-code <= v-cur-code
      )
    or
      (
        v-range-type = 'drgb':U
        AND
        v-cur-code = 0
      )
   )
   then do:
      assign
        l-code-range-exist = true
      .
      if v-g#news
      and buf_code-range.stts = "f" then do:
        assign
          buf_code-range.stts = "u"
        .
      end.
    end.
    if not l-code-range-exist
       and v-g#news-source-db <> 0
    then do:
      undo, return error substitute("&1 &2 &3&4Отсутствует диапазон кодов для БД &5 Тип диапазона кодов &6 Код &7"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    ,v-db-num
                                    ,v-range-type
                                    ,v-cur-code
                                   ).
    end.
    if (not l-code-range-exist
        or ( v-cur-code >= int( (buf_code-range.first-code + buf_code-range.last-code) / 2 ) )
       )
    and ( not can-find (first buf1_code-range no-lock
                        where buf1_code-range.db-num = v-db-num
                          and buf1_code-range.range-type = v-range-type
                          and buf1_code-range.stts = "f"
                       )
        )
    then do:
      if v-g#db-num = 0 then do:
        run new-bcod-gen-code-range in this-procedure
          (input v-db-num,
           input v-range-type
          ) no-error .
        if error-status :error then do:
          undo, return error substitute("Ошибка при создании нового свободного диапазона &1 Тип диапазона кодов &2 Код &3:&4&5 &6"
                                        , substitute("&1 &2 &3", vss-workfile, vss-revision, vss-description)
                                        ,v-db-num
                                        ,v-range-type
                                        ,v-cur-code
                                        ,chr(10)
                                        ,error-status:get-message(1)
                                        ,return-value
                                       ).
        end.
      end.
      else do:
        if v-range-type = 'sclc':U
        or v-range-type = 'pglc':U
        then do:
          assign
            v-db-for-send = "":U
          .
          if v-g#db-num = 0 then do:
            for each buf_db no-lock
              where buf_db.db-num > 0
                and buf_db.db-num <> v-g#news-source-db
            on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
            :
              assign
                v-db-for-send = v-db-for-send + chr(1) + string( buf_db.db-num )
              .
            end.
            assign
              v-db-for-send = right-trim( v-db-for-send, chr(1) )
            .
          end.
          else do:
            if not v-g#news then do:
              assign
                v-db-for-send = "0":U
              .
            end.
          end.
          run nws/cr-route.p ( input 'send-cmd':U
                        ,input ("command":U + chr(1) + "create":U + chr(1) +
                               "code-range":U + chr(1) +
                               (if v-range-type = 'sclc':U
                                then string( current-value(s-sclc-code, ub))
                                else string( current-value(s-pglc-code, ub))
                                ) + chr(1) +
                                v-range-type)
                        ,input ?
                        ,input v-db-for-send
                        ) no-error .
          if error-status :error then do:
            undo, return error return-value.
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure cre-loc-sc-code-range :
  define input parameter v-cur-code as integer no-undo .
define input parameter p-cdrg-type as character no-undo .
  do
  on error  undo, return error substitute( "&1 (cre-loc-sc-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (cre-loc-sc-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (cre-loc-sc-code-range). endkey", vss-workfile )
  :
    define buffer buf_code-range for ub.code-range .
    find first buf_code-range
         where buf_code-range.range-type = p-cdrg-type
           and buf_code-range.first-code >= v-cur-code
         no-error .
    if not available buf_code-range then do:
      run new-bcod-gen-code-range in this-procedure
        ( input 0,
          input p-cdrg-type
        ) no-error .
      if error-status :error then do:
        undo, return error substitute( "Ошибка при создании нового свободного диапазона локальных весовых или штучных кодов&1"
                                       + "Код &2&1&3 &4"
                                      , chr(10)
                                      , v-cur-code
                                      , error-status:get-message(1)
                                      , return-value
                                     ) .
      end.
    end.
  end.
end procedure.
procedure mark-used-if-need :
define input parameter p-cur-code as integer no-undo .
define input parameter p-range-type like ub.code-range.range-type no-undo .
define input parameter p-db-num like ub.code-range.db-num no-undo .
  do
  on error  undo, return error substitute( "&1 (mark-used-if-need). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (mark-used-if-need). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (mark-used-if-need). endkey", vss-workfile )
  :
    DEFINE VARIABLE v-db-num like ub.code-range.db-num no-undo .
    define buffer buf_code-range for ub.code-range .
    assign
    v-db-num = if p-range-type = 'sclc':U
               then 0
               else p-db-num
    .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer locK-batchprocess4 for ub.batchprocess.
run gbl/lock-prc.p
    (input 'lscc':U
    ,input 0
    ,input 0
    ,input 0
    ,input ""
    ,input ""
    ,input ""
    ,input (
            ",,,Вкл/выкл лок. вес. кодов"
           )
    ,input true
    ,buffer lock-batchprocess4
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент идет процесс вкл/выкл лок. вес. кодов" skip
      view-as alert-box error .
    undo, return error .
  end.
    find first buf_code-range
         where buf_code-range.range-type = p-range-type
           and buf_code-range.first-code >= p-cur-code
           and buf_code-range.last-code <= p-cur-code
           and buf_code-range.db-num = v-db-num
         no-error .
    if not available buf_code-range then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании поиске диапазона" skip
        "База данных" p-db-num skip
        "Код" p-cur-code skip
        "Тип" p-range-type
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_code-range.stts = "f":U then do:
      assign
      buf_code-range.stts = "u":U
      .
    end.
  end.
end procedure.
do
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  DEFINE temp-table temp-cli no-undo
    field   obj-type            as character
    field   obj-code            as integer
    field   obj-name            as character
    INDEX pi  IS PRIMARY obj-type  obj-code
  .
  DEFINE TEMP-TABLE tt-fin-doc NO-UNDO LIKE ub.fin-doc
    field   str-fo            as character
  .
  DEFINE TEMP-TABLE tt0-fin-doc-tax NO-UNDO LIKE ub.fin-doc-tax
    INDEX pi1 vat-pc slt-pc with-vat with-slt
  .
  define temp-table tt0-payment no-undo like ub.payment.
  DEFINE TEMP-TABLE tt_fin-doc NO-UNDO LIKE ub.fin-doc.
  DEFINE TEMP-TABLE tt0_fin-doc-tax NO-UNDO LIKE ub.fin-doc-tax.
  DEFINE TEMP-TABLE tt_fin-doc-attr NO-UNDO LIKE ub.fin-doc-attr.
  DEFINE TEMP-TABLE tt_fin-connect NO-UNDO LIKE ub.fin-connect.
  define stream LogStream.
  define buffer buf_contract for ub.contract .
  define buffer buf_fin-ob for ub.fin-ob .
  define buffer b1_fin-schet for ub.fin-schet .
  define buffer b2_fin-schet for ub.fin-schet .
  define variable f-name as character no-undo .
  define variable g#log  as logical   no-undo .
  define variable s-list as character no-undo .
  define variable v-message-text as character no-undo .
  define variable line as integer initial 1 no-undo .
  define variable v-curr-r-b as integer   no-undo .
  define variable curr-rc    as character no-undo .
  define variable sss    as character no-undo .
  define variable p-sys-time  as character no-undo .
  define variable p-koef-rubl as decimal   no-undo .
  define variable p-koef-base as decimal   no-undo .
  define variable p-koef-cont as decimal   no-undo .
  define variable p-koef-doc  as decimal   no-undo .
  define variable v-err as logical   no-undo .
  assign
    v-message-text = "paypvavt.log"
    f-name = "default.cli"
    g#log = yes
  .
  system-dialog get-file f-name
          filters "Списки клиентов *.cli" "*.cli"
          use-filename
          update g#log
          default-extension "cli".
  if not g#log then return  error .
  input from value (f-name).
  REPEAT :
     CREATE temp-cli.
     IMPORT temp-cli.obj-type temp-cli.obj-code NO-ERROR.
     IF ERROR-STATUS :ERROR THEN DO:
       DELETE temp-cli.
       UNDO, NEXT.
     END.
     find first ub.clients no-lock where ub.clients.obj-type = temp-cli.obj-type and ub.clients.obj-code = temp-cli.obj-code no-error .
     assign
       temp-cli.obj-name = ub.clients.obj-name
       s-list = s-list + chr(10) + temp-cli.obj-type + ' ' + string(temp-cli.obj-code) + '  ' + ub.clients.obj-name
     .
  END.
  input close.
  define variable choice as integer   no-undo .
  run gbl/d-askw.w (input "Автоматическая оплата по списку клиентов",
                input ("Выбраны клиенты :" + s-list ),
                input "|",
                input "Совокупный платеж по договору|Раздельные платежи по ФО|Отказ",
                input "||",
                input 1,
                input 3,
                output choice).
  if choice <> 3 then do:
    run waitfram-show("Ждите...").
    os-delete VALUE(v-message-text).
    output to value (v-message-text).
    OUTPUT CLOSE.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  p-host-code
  ,output v-curr-r-b
  )  .
    find first ub.sysconf no-lock      where ub.sysconf.host-code = p-host-code .
    find first ub.firm no-lock         where ub.firm.firm-code    = p-host-code .
    case choice :
      when 2 then run pay-fin-fo .
      when 1 then run pay-contract .
    end.
    OUTPUT CLOSE.
    run waitfram-hide.
    run gbl/prnfilen.w (
      input  "Результат создания платежей",
      input  0,
      input  v-message-text,
      input  7,
      output sss,
      output g#log
      ).
  end.
  else return  error .
end.
procedure pay-fin-fo :
define variable v-fd-code as integer no-undo .
  do  on error undo, return error return-value  :
    for each temp-cli, each buf_contract no-lock where buf_contract.host-code = p-host-code and buf_contract.cli-type = temp-cli.obj-type and buf_contract.cli-code = temp-cli.obj-code :
      for each buf_fin-ob no-lock
        where buf_fin-ob.host-code     = p-host-code
          and buf_fin-ob.contract-code = buf_contract.contract-code
          and buf_fin-ob.doc-type      = 'рас':U
          and buf_fin-ob.status_       =  'факт':U
          and buf_fin-ob.con-stat      < 2
        :
        assign v-err = no .
        run gen-b-code in this-procedure ( input 'fdgb':U
                                        , output v-fd-code) no-error .
        if error-status:error then do:
          define variable v-mess as character no-undo .
          v-mess = substitute("Ошибка при генерации внутреннего номера фин. док-та&1" +
                                "Вн.№ договора &1  ФО №  &2  от &3:&1&4&1&5"
                                , buf_contract.contract-code
                                , buf_fin-ob.prn-doc-code
                                , buf_fin-ob.doc-date
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value ).
          if error-status:error then do:
            output stream LogStream to Value(v-message-text) append.
            put stream Logstream unformatted
            v-mess skip.
            output stream LogStream close.
          end.
          undo, return error.
        end.
        create tt-fin-doc .
        assign
          tt-fin-doc.host-code       = p-host-code
          tt-fin-doc.fin-doc-code    = v-fd-code
          tt-fin-doc.base-rate       = buf_fin-ob.base-rate
          tt-fin-doc.base-scale      = buf_fin-ob.base-scale
          tt-fin-doc.contract-code   = buf_fin-ob.contract-code
          tt-fin-doc.contract-curr   = buf_fin-ob.contract-curr
          tt-fin-doc.contract-rate   = buf_fin-ob.contract-rate
          tt-fin-doc.contract-scale  = buf_fin-ob.contract-scale
          tt-fin-doc.curr-code       = buf_fin-ob.curr-code
          tt-fin-doc.obj-code        = buf_fin-ob.obj-code
          tt-fin-doc.obj-type        = buf_fin-ob.obj-type
          tt-fin-doc.doc-date        = today
          tt-fin-doc.exch-rate       = buf_fin-ob.exch-rate
          tt-fin-doc.exch-scale      = buf_fin-ob.exch-scale
          tt-fin-doc.PS              = ""
          tt-fin-doc.ocher-pl        = "6"
          tt-fin-doc.stat-pl         = ""
          tt-fin-doc.naznach-plat    = "Оплата по договору № " + buf_contract.contract-prn-code + " от " + string( buf_contract.contract-date,"99/99/9999")
          tt-fin-doc.payer-name      = buf_fin-ob.payer-name
          tt-fin-doc.payer-code      = buf_fin-ob.payer-code
          tt-fin-doc.payer-type      = buf_fin-ob.payer-type
          tt-fin-doc.receiver-code   = buf_fin-ob.receiver-code
          tt-fin-doc.receiver-name   = buf_fin-ob.receiver-name
          tt-fin-doc.receiver-type   = buf_fin-ob.receiver-type
          tt-fin-doc.prn-doc-code    = string(tt-fin-doc.fin-doc-code)
          tt-fin-doc.sum-doc         = buf_fin-ob.sum-doc      - buf_fin-ob.con-sum-doc
          tt-fin-doc.sum-base        = buf_fin-ob.sum-base     - buf_fin-ob.con-sum-base
          tt-fin-doc.sum-rubl        = buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-rubl
          tt-fin-doc.sum-contr       = buf_fin-ob.sum-contract - buf_fin-ob.con-sum-contr
          p-koef-rubl                = ( buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-rubl ) / buf_fin-ob.sum-rubl
          p-koef-base                = ( buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-base ) / buf_fin-ob.sum-rubl
          p-koef-cont                = ( buf_fin-ob.sum-contract - buf_fin-ob.con-sum-contr) / buf_fin-ob.sum-contract
          p-koef-doc                 = ( buf_fin-ob.sum-doc      - buf_fin-ob.con-sum-doc  ) / buf_fin-ob.sum-doc
        .
        for each ub.fin-ob-tax no-lock where ub.fin-ob-tax.host-code = p-host-code and ub.fin-ob-tax.doc-code = buf_fin-ob.doc-code :
          create tt0-fin-doc-tax .
          BUFFER-COPY ub.fin-ob-tax TO tt0-fin-doc-tax .
          assign
            tt0-fin-doc-tax.fin-doc-code       = tt-fin-doc.fin-doc-code
            tt0-fin-doc-tax.sum-line-doc       = ROUND(tt0-fin-doc-tax.sum-line-doc       , 2)  * p-koef-doc
            tt0-fin-doc-tax.sum-vat-line-doc   = ROUND(tt0-fin-doc-tax.sum-vat-line-doc   , 2)  * p-koef-doc
            tt0-fin-doc-tax.sum-slt-line-doc   = ROUND(tt0-fin-doc-tax.sum-slt-line-doc   , 2)  * p-koef-doc
            tt0-fin-doc-tax.sum-line-rubl      = ROUND(tt0-fin-doc-tax.sum-line-rubl      , 2)  * p-koef-rubl
            tt0-fin-doc-tax.sum-vat-line-rubl  = ROUND(tt0-fin-doc-tax.sum-vat-line-rubl  , 2)  * p-koef-rubl
            tt0-fin-doc-tax.sum-slt-line-rubl  = ROUND(tt0-fin-doc-tax.sum-slt-line-rubl  , 2)  * p-koef-rubl
            tt0-fin-doc-tax.sum-line-base      = ROUND(tt0-fin-doc-tax.sum-line-base      , 2)  * p-koef-base
            tt0-fin-doc-tax.sum-vat-line-base  = ROUND(tt0-fin-doc-tax.sum-vat-line-base  , 2)  * p-koef-base
            tt0-fin-doc-tax.sum-slt-line-base  = ROUND(tt0-fin-doc-tax.sum-slt-line-base  , 2)  * p-koef-base
            tt0-fin-doc-tax.sum-line-contr     = tt0-fin-doc-tax.sum-line-contr      * p-koef-cont
            tt0-fin-doc-tax.sum-vat-line-contr = tt0-fin-doc-tax.sum-vat-line-contr  * p-koef-cont
            tt0-fin-doc-tax.sum-slt-line-contr = tt0-fin-doc-tax.sum-slt-line-contr  * p-koef-cont
          .
        end.
        run CheckCli no-error .
        if error-status:error then do:
          assign v-err = yes .
          output stream LogStream to Value(v-message-text) append.
          put stream Logstream unformatted
          substitute("Несоответствие плательщика или получателя договору! Вн.№ договора &1  ФО №  &2  от &3", buf_contract.contract-code, buf_fin-ob.prn-doc-code, buf_fin-ob.doc-date) skip.
          output stream LogStream close.
        end.
        run FindBank .
        if buf_contract.pay-nal = no  then do:
          if buf_fin-ob.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = 'рпп':U .
          else                             assign tt-fin-doc.fin-doc-type = 'ппп':U .
          find first ub.currency no-lock where ub.currency.curr-code = b2_fin-schet.curr-code .
          assign tt-fin-doc.curr-code = b2_fin-schet.curr-code .
          case b2_fin-schet.curr-code :
              when 0 then do:
                assign tt-fin-doc.sum-doc = tt-fin-doc.sum-rubl .
                for each tt0-fin-doc-tax no-lock :
                  assign
                    tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-rubl
                    tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-rubl
                    tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-rubl
                  .
                end.
              end.
              when v-curr-r-b then do:
                assign tt-fin-doc.sum-doc = tt-fin-doc.sum-base .
                for each tt0-fin-doc-tax no-lock :
                  assign
                    tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-base
                    tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-base
                    tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-base
                  .
                end.
              end.
              when buf_contract.curr-code then do:
                assign tt-fin-doc.sum-doc = tt-fin-doc.sum-contr .
                for each tt0-fin-doc-tax no-lock :
                  assign
                    tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-contr
                    tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-contr
                    tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-contr
                  .
                end.
              end.
            otherwise do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  b2_fin-schet.curr-code
  ,input  today
  ,output tt-fin-doc.exch-rate
  ,output tt-fin-doc.exch-scale
  ,output curr-rc
  )  .
              assign tt-fin-doc.sum-doc = tt-fin-doc.sum-rubl * tt-fin-doc.exch-scale / tt-fin-doc.exch-rate .
            end.
          end.
        end.
        else do:
          if buf_contract.pay-nal = yes then do:
            if buf_fin-ob.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = 'рко':U .
            else                             assign tt-fin-doc.fin-doc-type = 'пко':U .
          end.
          else do:
            if buf_fin-ob.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = 'апр':U .
            else                             assign tt-fin-doc.fin-doc-type = 'апп':U .
          end.
          assign
            tt-fin-doc.receiver-code-schet = 0
            tt-fin-doc.receiver-bank-name  = ""
            tt-fin-doc.receiver-c-schet    = ""
            tt-fin-doc.receiver-r-schet    = ""
            tt-fin-doc.payer-code-schet = 0
            tt-fin-doc.payer-bank-name  = ""
            tt-fin-doc.payer-c-schet    = ""
            tt-fin-doc.payer-r-schet    = ""
          .
        end.
        assign tt-fin-doc.fin-ext-doc-type = tt-fin-doc.fin-doc-type .
        if tt-fin-doc.sum-contr < 0 then do:
          assign
            tt-fin-doc.payer-sign1        = ub.firm.director
            tt-fin-doc.payer-sign2        = ub.sysconf.snr-accnt
            tt-fin-doc.payer-sign3        = ub.sysconf.cashier
          .
          run InvertCli .
        end.
        else
          assign
            tt-fin-doc.receiver-sign1        = ub.firm.director
            tt-fin-doc.receiver-sign2        = ub.sysconf.snr-accnt
            tt-fin-doc.receiver-sign3        = ub.sysconf.cashier
          .
        if buf_contract.pay-nal = no then do:
          run StrTax (input-output sss) .
          assign tt-fin-doc.naznach-plat = tt-fin-doc.naznach-plat + "@" + sss .
        end.
        else if buf_contract.pay-nal = yes then do:
          run StrTax (input-output tt-fin-doc.including) .
        end.
        define variable p-doc-rec as recid no-undo.
        run UchetCode .
        if v-err = no then do:
          tt-fin-doc.doc-author = "fin-ob".
          run ref/findoc0.p (
            input-output p-doc-rec
           ,input 'ДОБАВЛЕНИЕ':U
           ,input yes
           ,input tt-fin-doc.host-code            ,input tt-fin-doc.fin-doc-code         ,input tt-fin-doc.an-uchet-code        ,input tt-fin-doc.an-uchet-value       ,input tt-fin-doc.base-rate            ,input tt-fin-doc.base-scale           ,input tt-fin-doc.cel-nazn-code        ,input tt-fin-doc.cel-nazn-value       ,input tt-fin-doc.contract-code        ,input tt-fin-doc.contract-curr        ,input tt-fin-doc.contract-rate        ,input tt-fin-doc.contract-scale       ,input tt-fin-doc.cor-acc              ,input tt-fin-doc.cor-acc-value        ,input tt-fin-doc.cor-acc1             ,input tt-fin-doc.cor-acc1-value       ,input tt-fin-doc.curr-code            ,input tt-fin-doc.doc-date             ,input tt-fin-doc.shift-date           ,input tt-fin-doc.shift-num            ,input tt-fin-doc.shift-name           ,input tt-fin-doc.enclosure            ,input tt-fin-doc.exch-rate            ,input tt-fin-doc.exch-scale           ,input tt-fin-doc.f104                 ,input tt-fin-doc.f105                 ,input tt-fin-doc.f106                 ,input tt-fin-doc.f107                 ,input tt-fin-doc.f108                 ,input tt-fin-doc.f109                 ,input tt-fin-doc.f110                 ,input tt-fin-doc.f22                  ,input tt-fin-doc.f23                  ,input tt-fin-doc.fact-date            ,input tt-fin-doc.fin-doc-type         ,input tt-fin-doc.fin-ext-doc-type     ,input tt-fin-doc.in-doc-code          ,input tt-fin-doc.in-host-code         ,input tt-fin-doc.including            ,input tt-fin-doc.nazn-pl              ,input tt-fin-doc.naznach-plat         ,input tt-fin-doc.ocher-pl             ,input tt-fin-doc.out-doc-code         ,input tt-fin-doc.out-host-code        ,input tt-fin-doc.pay-date             ,input tt-fin-doc.payer-bank-name      ,input tt-fin-doc.payer-bank-city      ,input tt-fin-doc.payer-bik            ,input tt-fin-doc.payer-c-schet        ,input tt-fin-doc.payer-code           ,input tt-fin-doc.payer-code-schet     ,input tt-fin-doc.payer-dop1           ,input tt-fin-doc.payer-dop2           ,input tt-fin-doc.payer-inn            ,input tt-fin-doc.payer-kpp            ,input tt-fin-doc.payer-name           ,input tt-fin-doc.payer-okpo           ,input tt-fin-doc.payer-passport      ,input tt-fin-doc.payer-r-schet        ,input tt-fin-doc.payer-type           ,input tt-fin-doc.perm-date            ,input tt-fin-doc.prn-doc-code         ,input tt-fin-doc.PS                   ,input tt-fin-doc.receiver-bank-name   ,input tt-fin-doc.receiver-bank-city   ,input tt-fin-doc.receiver-bik         ,input tt-fin-doc.receiver-c-schet     ,input tt-fin-doc.receiver-code        ,input tt-fin-doc.receiver-code-schet  ,input tt-fin-doc.receiver-dop1        ,input tt-fin-doc.receiver-dop2        ,input tt-fin-doc.receiver-inn         ,input tt-fin-doc.receiver-kpp         ,input tt-fin-doc.receiver-name        ,input tt-fin-doc.receiver-okpo        ,input tt-fin-doc.receiver-passport    ,input tt-fin-doc.receiver-r-schet     ,input tt-fin-doc.receiver-type        ,input tt-fin-doc.srok-pl              ,input tt-fin-doc.stat-pl              ,input tt-fin-doc.str-podr-code        ,input tt-fin-doc.str-podr-type        ,input tt-fin-doc.str-podr-name        ,input tt-fin-doc.sum-base             ,input tt-fin-doc.sum-doc              ,input tt-fin-doc.sum-rubl             ,input tt-fin-doc.sum-contr            ,input tt-fin-doc.trn-doc-code         ,input tt-fin-doc.vid-opl              ,input tt-fin-doc.vid-plat
           ,input tt-fin-doc.con-sum-rubl         ,input tt-fin-doc.con-sum-base         ,input tt-fin-doc.con-sum-doc          ,input tt-fin-doc.con-sum-contr        ,input tt-fin-doc.con-stat             ,input tt-fin-doc.payer-sign1                ,input tt-fin-doc.payer-sign2                ,input tt-fin-doc.payer-sign3                ,input tt-fin-doc.payer-sign4                ,input tt-fin-doc.receiver-sign1                ,input tt-fin-doc.receiver-sign2                ,input tt-fin-doc.receiver-sign3                ,input tt-fin-doc.receiver-sign4                ,input tt-fin-doc.obj-type                   ,input tt-fin-doc.obj-code                   ,input tt-fin-doc.doc-author                 ,input tt-fin-doc.fact-author                ,input tt-fin-doc.CashBookId
           ,input table tt0-fin-doc-tax
           ,input table tt_fin-doc-attr
           ,input no
           ,input table tt0-payment
           ) no-error .
          if error-status:error then do:
            assign v-err = yes .
            output stream LogStream to Value(v-message-text) append.
            put stream Logstream unformatted
            substitute("Ошибка создания платежа! Вн.№ договора &1  ФО №  &2  от &3&4&5"
                       , buf_contract.contract-code
                       , buf_fin-ob.prn-doc-code
                       , buf_fin-ob.doc-date
                       ,chr(10)
                       ,substitute( "&1&2&3", return-value, chr(10), error-status :get-message (1))
                       ) skip.
            output stream LogStream close.
          end.
        end.
        if v-err = no then do:
          create ub.fin-connect .
          assign
            ub.fin-connect.connect-code   = next-value( s-fin-connect, ub )
            ub.fin-connect.host-code      = p-host-code
            ub.fin-connect.fin-doc-code   = tt-fin-doc.fin-doc-code
            ub.fin-connect.fin-ob-code    = buf_fin-ob.doc-code
            ub.fin-connect.contract-code  = buf_fin-ob.contract-code
            ub.fin-connect.curr-code      = buf_fin-ob.curr-code
            ub.fin-connect.base-rate      = buf_fin-ob.base-rate
            ub.fin-connect.base-scale     = buf_fin-ob.base-scale
            ub.fin-connect.contract-curr  = buf_fin-ob.contract-curr
            ub.fin-connect.contract-rate  = buf_fin-ob.contract-rate
            ub.fin-connect.contract-scale = buf_fin-ob.contract-scale
            ub.fin-connect.exch-rate      = buf_fin-ob.exch-rate
            ub.fin-connect.exch-scale     = buf_fin-ob.exch-scale
            ub.fin-connect.status_        = 'тек':U
            ub.fin-connect.sum-rubl-ob    = buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-rubl
            ub.fin-connect.sum-base-ob    = buf_fin-ob.sum-base     - buf_fin-ob.con-sum-base
            ub.fin-connect.sum-contr-ob   = buf_fin-ob.sum-contract - buf_fin-ob.con-sum-contr
            ub.fin-connect.sum-rubl       = buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-rubl
            ub.fin-connect.sum-base       = buf_fin-ob.sum-base     - buf_fin-ob.con-sum-base
            ub.fin-connect.sum-doc        = buf_fin-ob.sum-doc      - buf_fin-ob.con-sum-doc
            ub.fin-connect.sum-contr      = buf_fin-ob.sum-contr    - buf_fin-ob.con-sum-contr
          .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdburt in g#library
  (output ub.fin-connect.user-db-num
  ,output ub.fin-connect.user-name
  ,output ub.fin-connect.fact-date
  ,output p-sys-time
  ,output ub.fin-connect.fact-time
  )  .
          find first ub.fin-ob exclusive-lock where ub.fin-ob.host-code = p-host-code and ub.fin-ob.doc-code = buf_fin-ob.doc-code .
          assign
            ub.fin-ob.con-sum-doc   = ub.fin-ob.sum-doc
            ub.fin-ob.con-sum-rubl  = ub.fin-ob.sum-rubl
            ub.fin-ob.con-sum-base  = ub.fin-ob.sum-base
            ub.fin-ob.con-sum-contr = ub.fin-ob.sum-contr
            ub.fin-ob.con-stat      = 2
          .
          find first ub.fin-doc exclusive-lock where recid(ub.fin-doc) = p-doc-rec .
          assign
            ub.fin-doc.con-sum-rubl  = ub.fin-doc.sum-rubl
            ub.fin-doc.con-sum-base  = ub.fin-doc.sum-base
            ub.fin-doc.con-sum-doc   = ub.fin-doc.sum-doc
            ub.fin-doc.con-sum-contr = ub.fin-doc.sum-contr
            ub.fin-doc.con-stat      = 2
          .
          output stream LogStream to Value(v-message-text) append.
          put stream Logstream unformatted
          substitute("Успешно создан &1 № &2 ! Вн.№ договора &3  ФО №  &4  от &5", tt-fin-doc.fin-doc-type, tt-fin-doc.prn-doc-code, buf_contract.contract-code, buf_fin-ob.prn-doc-code, buf_fin-ob.doc-date) skip.
          output stream LogStream close.
        end.
      end.
    end.
  end.
end procedure.
procedure pay-contract :
define variable v-fd-code as integer no-undo .
  do on error undo, return error return-value :
    for each temp-cli, each buf_contract no-lock where buf_contract.host-code = p-host-code and buf_contract.cli-type = temp-cli.obj-type and buf_contract.cli-code = temp-cli.obj-code :
      for each buf_fin-ob no-lock
        where buf_fin-ob.host-code     = p-host-code
          and buf_fin-ob.contract-code = buf_contract.contract-code
          and buf_fin-ob.doc-type      = 'рас':U
          and buf_fin-ob.status_       =  'факт':U
          and buf_fin-ob.con-stat      < 2
        :
        assign v-err = no .
        if ub.sysconf.fin-calc = 1 then do:
          find first tt-fin-doc
            where tt-fin-doc.contract-code = buf_fin-ob.contract-code
              and tt-fin-doc.obj-type      = buf_fin-ob.obj-type
              and tt-fin-doc.obj-code      = buf_fin-ob.obj-code
          no-error .
        end.
        else do:
          find first tt-fin-doc where tt-fin-doc.contract-code = buf_contract.contract-code no-error .
        end.
        if not available tt-fin-doc then do:
          run gen-b-code in this-procedure ( input 'fdgb':U
                                          , output v-fd-code) no-error .
          if error-status:error then do:
            define variable v-mess as character no-undo .
            v-mess = substitute("Ошибка при генерации внутреннего номера фин. док-та&1" +
                                 "Вн.№ договора &1  ФО №  &2  от &3:&1&4&1&5"
                                 , buf_contract.contract-code
                                 , buf_fin-ob.prn-doc-code
                                 , buf_fin-ob.doc-date
                                  , chr(10)
                                  , error-status:get-message(1)
                                  , return-value ).
            if error-status:error then do:
              output stream LogStream to Value(v-message-text) append.
              put stream Logstream unformatted
              v-mess skip.
              output stream LogStream close.
            end.
            undo, return error.
          end.
          create tt-fin-doc .
          assign
            tt-fin-doc.host-code       = p-host-code
            tt-fin-doc.fin-doc-code    = v-fd-code
            tt-fin-doc.prn-doc-code    = string(tt-fin-doc.fin-doc-code)
            tt-fin-doc.contract-code   = buf_fin-ob.contract-code
            tt-fin-doc.contract-curr   = buf_fin-ob.contract-curr
            tt-fin-doc.curr-code       = buf_fin-ob.curr-code
            tt-fin-doc.obj-code        = buf_fin-ob.obj-code
            tt-fin-doc.obj-type        = buf_fin-ob.obj-type
            tt-fin-doc.doc-date        = today
            tt-fin-doc.PS              = ""
            tt-fin-doc.ocher-pl        = "6"
            tt-fin-doc.stat-pl         = ""
            tt-fin-doc.naznach-plat    = "Оплата по договору № " + buf_contract.contract-prn-code + " от " + string( buf_contract.contract-date,"99/99/9999")
            tt-fin-doc.payer-name      = buf_fin-ob.payer-name
            tt-fin-doc.payer-code      = buf_fin-ob.payer-code
            tt-fin-doc.payer-type      = buf_fin-ob.payer-type
            tt-fin-doc.receiver-code   = buf_fin-ob.receiver-code
            tt-fin-doc.receiver-name   = buf_fin-ob.receiver-name
            tt-fin-doc.receiver-type   = buf_fin-ob.receiver-type
            tt-fin-doc.sum-base        = buf_fin-ob.sum-base     - buf_fin-ob.con-sum-base
            tt-fin-doc.sum-rubl        = buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-rubl
            tt-fin-doc.sum-contr       = buf_fin-ob.sum-contract - buf_fin-ob.con-sum-contr
            tt-fin-doc.sum-doc         = buf_fin-ob.sum-doc      - buf_fin-ob.con-sum-doc
            tt-fin-doc.base-scale      = buf_fin-ob.base-scale
            tt-fin-doc.contract-scale  = buf_fin-ob.contract-scale
            tt-fin-doc.exch-scale      = buf_fin-ob.exch-scale
            p-koef-rubl                = ( buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-rubl ) / buf_fin-ob.sum-rubl
            p-koef-base                = ( buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-base ) / buf_fin-ob.sum-rubl
            p-koef-cont                = ( buf_fin-ob.sum-contract - buf_fin-ob.con-sum-contr) / buf_fin-ob.sum-contract
            p-koef-doc                 = ( buf_fin-ob.sum-doc      - buf_fin-ob.con-sum-doc  ) / buf_fin-ob.sum-doc
          .
          run CheckCli no-error .
          if error-status:error then do:
            output stream LogStream to Value(v-message-text) append.
            put stream Logstream unformatted
            substitute("Несоответствие плательщика или получателя договору! Вн.№ договора &1  ФО №  &2  от &3", buf_contract.contract-code, buf_fin-ob.prn-doc-code, buf_fin-ob.doc-date) skip.
            output stream LogStream close.
          end.
        end.
        else do:
          assign
            tt-fin-doc.sum-base  = tt-fin-doc.sum-base  + buf_fin-ob.sum-base     - buf_fin-ob.con-sum-base
            tt-fin-doc.sum-rubl  = tt-fin-doc.sum-rubl  + buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-rubl
            tt-fin-doc.sum-contr = tt-fin-doc.sum-contr + buf_fin-ob.sum-contract - buf_fin-ob.con-sum-contr
            tt-fin-doc.sum-doc   = tt-fin-doc.sum-doc   + buf_fin-ob.sum-doc      - buf_fin-ob.con-sum-doc
            p-koef-rubl          = ( buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-rubl ) / buf_fin-ob.sum-rubl
            p-koef-base          = ( buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-base ) / buf_fin-ob.sum-rubl
            p-koef-cont          = ( buf_fin-ob.sum-contract - buf_fin-ob.con-sum-contr) / buf_fin-ob.sum-contract
            p-koef-doc           = ( buf_fin-ob.sum-doc      - buf_fin-ob.con-sum-doc  ) / buf_fin-ob.sum-doc
          .
          if tt-fin-doc.obj-code <> buf_fin-ob.obj-code or tt-fin-doc.obj-type <> buf_fin-ob.obj-type then assign tt-fin-doc.obj-type = "" tt-fin-doc.obj-code = 0 .
        end.
        if tt-fin-doc.str-fo <> "" then assign tt-fin-doc.str-fo = tt-fin-doc.str-fo + ", "  .
        assign tt-fin-doc.str-fo = tt-fin-doc.str-fo + string(buf_fin-ob.doc-code) .
        for each ub.fin-ob-tax no-lock where ub.fin-ob-tax.host-code = p-host-code and ub.fin-ob-tax.doc-code = buf_fin-ob.doc-code :
          find first tt0-fin-doc-tax
            where tt0-fin-doc-tax.vat-pc       = ub.fin-ob-tax.vat-pc
              and tt0-fin-doc-tax.slt-pc       = ub.fin-ob-tax.slt-pc
              and tt0-fin-doc-tax.with-vat     = ub.fin-ob-tax.with-vat
              and tt0-fin-doc-tax.with-slt     = ub.fin-ob-tax.with-slt
              and tt0-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code
          no-error .
          if not available tt0-fin-doc-tax then do:
            create tt0-fin-doc-tax .
            BUFFER-COPY ub.fin-ob-tax TO tt0-fin-doc-tax .
            assign
              tt0-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code
              tt0-fin-doc-tax.host-code    = p-host-code
              tt0-fin-doc-tax.line-num     = line
              line = line + 1
              tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-doc       * p-koef-doc
              tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-doc   * p-koef-doc
              tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-doc   * p-koef-doc
              tt0-fin-doc-tax.sum-line-rubl      = tt0-fin-doc-tax.sum-line-rubl      * p-koef-rubl
              tt0-fin-doc-tax.sum-vat-line-rubl  = tt0-fin-doc-tax.sum-vat-line-rubl  * p-koef-rubl
              tt0-fin-doc-tax.sum-slt-line-rubl  = tt0-fin-doc-tax.sum-slt-line-rubl  * p-koef-rubl
              tt0-fin-doc-tax.sum-line-base      = tt0-fin-doc-tax.sum-line-base      * p-koef-base
              tt0-fin-doc-tax.sum-vat-line-base  = tt0-fin-doc-tax.sum-vat-line-base  * p-koef-base
              tt0-fin-doc-tax.sum-slt-line-base  = tt0-fin-doc-tax.sum-slt-line-base  * p-koef-base
              tt0-fin-doc-tax.sum-line-contr     = tt0-fin-doc-tax.sum-line-contr     * p-koef-cont
              tt0-fin-doc-tax.sum-vat-line-contr = tt0-fin-doc-tax.sum-vat-line-contr * p-koef-cont
              tt0-fin-doc-tax.sum-slt-line-contr = tt0-fin-doc-tax.sum-slt-line-contr * p-koef-cont
            .
          end.
          else do:
            assign
              tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-doc       + ub.fin-ob-tax.sum-line-doc       * p-koef-doc
              tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-doc   + ub.fin-ob-tax.sum-vat-line-doc   * p-koef-doc
              tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-doc   + ub.fin-ob-tax.sum-slt-line-doc   * p-koef-doc
              tt0-fin-doc-tax.sum-line-rubl      = tt0-fin-doc-tax.sum-line-rubl      + ub.fin-ob-tax.sum-line-rubl      * p-koef-rubl
              tt0-fin-doc-tax.sum-vat-line-rubl  = tt0-fin-doc-tax.sum-vat-line-rubl  + ub.fin-ob-tax.sum-vat-line-rubl  * p-koef-rubl
              tt0-fin-doc-tax.sum-slt-line-rubl  = tt0-fin-doc-tax.sum-slt-line-rubl  + ub.fin-ob-tax.sum-slt-line-rubl  * p-koef-rubl
              tt0-fin-doc-tax.sum-line-base      = tt0-fin-doc-tax.sum-line-base      + ub.fin-ob-tax.sum-line-base      * p-koef-base
              tt0-fin-doc-tax.sum-vat-line-base  = tt0-fin-doc-tax.sum-vat-line-base  + ub.fin-ob-tax.sum-vat-line-base  * p-koef-base
              tt0-fin-doc-tax.sum-slt-line-base  = tt0-fin-doc-tax.sum-slt-line-base  + ub.fin-ob-tax.sum-slt-line-base  * p-koef-base
              tt0-fin-doc-tax.sum-line-contr     = tt0-fin-doc-tax.sum-line-contr     + ub.fin-ob-tax.sum-line-contr     * p-koef-cont
              tt0-fin-doc-tax.sum-vat-line-contr = tt0-fin-doc-tax.sum-vat-line-contr + ub.fin-ob-tax.sum-vat-line-contr * p-koef-cont
              tt0-fin-doc-tax.sum-slt-line-contr = tt0-fin-doc-tax.sum-slt-line-contr + ub.fin-ob-tax.sum-slt-line-contr * p-koef-cont
            .
          end.
        end.
        create tt_fin-connect .
        assign
         tt_fin-connect.connect-code   = next-value( s-fin-connect, ub )
         tt_fin-connect.host-code      = p-host-code
         tt_fin-connect.fin-doc-code   = tt-fin-doc.fin-doc-code
         tt_fin-connect.fin-ob-code    = buf_fin-ob.doc-code
         tt_fin-connect.contract-code  = buf_fin-ob.contract-code
         tt_fin-connect.curr-code      = buf_fin-ob.curr-code
         tt_fin-connect.base-rate      = buf_fin-ob.base-rate
         tt_fin-connect.base-scale     = buf_fin-ob.base-scale
         tt_fin-connect.contract-curr  = buf_fin-ob.contract-curr
         tt_fin-connect.contract-rate  = buf_fin-ob.contract-rate
         tt_fin-connect.contract-scale = buf_fin-ob.contract-scale
         tt_fin-connect.exch-rate      = buf_fin-ob.exch-rate
         tt_fin-connect.exch-scale     = buf_fin-ob.exch-scale
         tt_fin-connect.status_        = 'тек':U
         tt_fin-connect.sum-rubl-ob    = buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-rubl
         tt_fin-connect.sum-base-ob    = buf_fin-ob.sum-base     - buf_fin-ob.con-sum-base
         tt_fin-connect.sum-contr-ob   = buf_fin-ob.sum-contract - buf_fin-ob.con-sum-contr
         tt_fin-connect.sum-rubl       = buf_fin-ob.sum-rubl     - buf_fin-ob.con-sum-rubl
         tt_fin-connect.sum-base       = buf_fin-ob.sum-base     - buf_fin-ob.con-sum-base
         tt_fin-connect.sum-doc        = buf_fin-ob.sum-doc      - buf_fin-ob.con-sum-doc
         tt_fin-connect.sum-contr      = buf_fin-ob.sum-contr    - buf_fin-ob.con-sum-contr
         tt_fin-connect.user-db-num = 0
       .
      end.
    end.
    for each tt-fin-doc :
      find first buf_contract no-lock where buf_contract.host-code = p-host-code and buf_contract.contract-code = tt-fin-doc.contract-code .
      run FindBank .
      assign
        tt-fin-doc.base-rate       = if tt-fin-doc.sum-base  <> 0 then tt-fin-doc.sum-rubl * tt-fin-doc.base-scale / tt-fin-doc.sum-base      else 0
        tt-fin-doc.contract-rate   = if tt-fin-doc.sum-contr <> 0 then tt-fin-doc.sum-rubl * tt-fin-doc.contract-scale / tt-fin-doc.sum-contr else 0
        tt-fin-doc.exch-rate       = if tt-fin-doc.sum-doc   <> 0 then tt-fin-doc.sum-rubl * tt-fin-doc.exch-scale / tt-fin-doc.sum-doc       else 0
      .
      find first ub.currency no-lock where ub.currency.curr-code = b2_fin-schet.curr-code .
      assign  curr-rc = ub.currency.curr-abbr  .
      if buf_contract.pay-nal = no then do:
        if buf_contract.doc-type = 'при':U then do:
          if buf_fin-ob.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = 'рпп':U .
          else                           assign tt-fin-doc.fin-doc-type = 'ппп':U .
        end.
        else do:
          if buf_fin-ob.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = 'ппп':U .
          else                           assign tt-fin-doc.fin-doc-type = 'рпп':U .
        end.
        assign tt-fin-doc.curr-code = b2_fin-schet.curr-code  .
        case b2_fin-schet.curr-code :
              when 0 then do:
                assign tt-fin-doc.sum-doc = tt-fin-doc.sum-rubl .
                for each tt0-fin-doc-tax no-lock :
                  assign
                    tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-rubl
                    tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-rubl
                    tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-rubl
                  .
                end.
              end.
              when v-curr-r-b then do:
                assign tt-fin-doc.sum-doc = tt-fin-doc.sum-base .
                for each tt0-fin-doc-tax no-lock :
                  assign
                    tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-base
                    tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-base
                    tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-base
                  .
                end.
              end.
              when buf_contract.curr-code then do:
                assign tt-fin-doc.sum-doc = tt-fin-doc.sum-contr .
                for each tt0-fin-doc-tax no-lock :
                  assign
                    tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-contr
                    tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-contr
                    tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-contr
                  .
                end.
              end.
          otherwise do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  b2_fin-schet.curr-code
  ,input  today
  ,output tt-fin-doc.exch-rate
  ,output tt-fin-doc.exch-scale
  ,output curr-rc
  )  .
            assign tt-fin-doc.sum-doc = tt-fin-doc.sum-rubl * tt-fin-doc.exch-scale / tt-fin-doc.exch-rate .
          end.
        end.
      end.
      else do:
        if buf_contract.pay-nal = yes then do:
          if buf_contract.doc-type = 'при':U then do:
            if buf_fin-ob.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = 'рко':U .
            else                           assign tt-fin-doc.fin-doc-type = 'пко':U .
          end.
          else do:
            if buf_fin-ob.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = 'пко':U .
            else                           assign tt-fin-doc.fin-doc-type = 'рко':U .
          end.
        end.
        else do:
          if buf_contract.doc-type = 'при':U then do:
            if buf_fin-ob.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = 'апр':U .
            else                           assign tt-fin-doc.fin-doc-type = 'апп':U .
          end.
          else do:
            if buf_fin-ob.sum-contr > 0 then assign tt-fin-doc.fin-doc-type = 'апп':U .
            else                           assign tt-fin-doc.fin-doc-type = 'апр':U .
          end.
        end.
        assign
          tt-fin-doc.receiver-code-schet = 0
          tt-fin-doc.receiver-bank-name  = ""
          tt-fin-doc.receiver-c-schet    = ""
          tt-fin-doc.receiver-r-schet    = ""
          tt-fin-doc.payer-code-schet = 0
          tt-fin-doc.payer-bank-name  = ""
          tt-fin-doc.payer-c-schet    = ""
          tt-fin-doc.payer-r-schet    = ""
        .
      end.
      assign tt-fin-doc.fin-ext-doc-type = tt-fin-doc.fin-doc-type .
      if tt-fin-doc.sum-contr < 0 then do:
        assign
          tt-fin-doc.payer-sign1        = ub.firm.director
          tt-fin-doc.payer-sign2        = ub.sysconf.snr-accnt
          tt-fin-doc.payer-sign3        = ub.sysconf.cashier
        .
        run InvertCli .
      end.
      else
        assign
          tt-fin-doc.receiver-sign1        = ub.firm.director
          tt-fin-doc.receiver-sign2        = ub.sysconf.snr-accnt
          tt-fin-doc.receiver-sign3        = ub.sysconf.cashier
        .
      assign sss = " В т.ч.: "  .
      if buf_contract.pay-nal = no then do:
        for each tt0-fin-doc-tax where tt0-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code :
          if tt0-fin-doc-tax.with-vat = no then next.
          if sss <> " В т.ч.: " then sss = sss + "," .
          if tt-fin-doc.curr-code = 0 then assign sss = sss + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " руб. (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
          else                             assign sss = sss + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
        end.
        if sss = " В т.ч.: " then assign sss = "" .
        assign tt-fin-doc.naznach-plat = tt-fin-doc.naznach-plat + "@" + sss .
      end.
      else if buf_contract.pay-nal = yes then do:
        for each tt0-fin-doc-tax where tt0-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code :
          if tt0-fin-doc-tax.with-vat = no then next.
          if sss <> " В т.ч.: " then sss = sss + "," .
          if tt-fin-doc.curr-code = 0 then assign sss = sss + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " руб. (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
          else                             assign sss = sss + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
        end.
        if sss = " В т.ч.: " then assign sss = "" .
        assign tt-fin-doc.including = sss .
      end.
      run UchetCode .
      define variable p-doc-rec as recid no-undo.
      BUFFER-COPY tt-fin-doc TO tt_fin-doc .
      for each tt0_fin-doc-tax :
        delete tt0_fin-doc-tax.
      end.
      assign line = 1 .
      for each tt0-fin-doc-tax where tt0-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code :
        create tt0_fin-doc-tax .
        BUFFER-COPY tt0-fin-doc-tax TO tt0_fin-doc-tax .
        assign
          tt0_fin-doc-tax.line-num     = line
          line = line + 1
        .
      end.
      run ref/findoc0.p (
        input-output p-doc-rec
       ,input 'ДОБАВЛЕНИЕ':U
       ,input yes
       ,input tt_fin-doc.host-code            ,input tt_fin-doc.fin-doc-code         ,input tt_fin-doc.an-uchet-code        ,input tt_fin-doc.an-uchet-value       ,input tt_fin-doc.base-rate            ,input tt_fin-doc.base-scale           ,input tt_fin-doc.cel-nazn-code        ,input tt_fin-doc.cel-nazn-value       ,input tt_fin-doc.contract-code        ,input tt_fin-doc.contract-curr        ,input tt_fin-doc.contract-rate        ,input tt_fin-doc.contract-scale       ,input tt_fin-doc.cor-acc              ,input tt_fin-doc.cor-acc-value        ,input tt_fin-doc.cor-acc1             ,input tt_fin-doc.cor-acc1-value       ,input tt_fin-doc.curr-code            ,input tt_fin-doc.doc-date             ,input tt_fin-doc.shift-date           ,input tt_fin-doc.shift-num            ,input tt_fin-doc.shift-name           ,input tt_fin-doc.enclosure            ,input tt_fin-doc.exch-rate            ,input tt_fin-doc.exch-scale           ,input tt_fin-doc.f104                 ,input tt_fin-doc.f105                 ,input tt_fin-doc.f106                 ,input tt_fin-doc.f107                 ,input tt_fin-doc.f108                 ,input tt_fin-doc.f109                 ,input tt_fin-doc.f110                 ,input tt_fin-doc.f22                  ,input tt_fin-doc.f23                  ,input tt_fin-doc.fact-date            ,input tt_fin-doc.fin-doc-type         ,input tt_fin-doc.fin-ext-doc-type     ,input tt_fin-doc.in-doc-code          ,input tt_fin-doc.in-host-code         ,input tt_fin-doc.including            ,input tt_fin-doc.nazn-pl              ,input tt_fin-doc.naznach-plat         ,input tt_fin-doc.ocher-pl             ,input tt_fin-doc.out-doc-code         ,input tt_fin-doc.out-host-code        ,input tt_fin-doc.pay-date             ,input tt_fin-doc.payer-bank-name      ,input tt_fin-doc.payer-bank-city      ,input tt_fin-doc.payer-bik            ,input tt_fin-doc.payer-c-schet        ,input tt_fin-doc.payer-code           ,input tt_fin-doc.payer-code-schet     ,input tt_fin-doc.payer-dop1           ,input tt_fin-doc.payer-dop2           ,input tt_fin-doc.payer-inn            ,input tt_fin-doc.payer-kpp            ,input tt_fin-doc.payer-name           ,input tt_fin-doc.payer-okpo           ,input tt_fin-doc.payer-passport      ,input tt_fin-doc.payer-r-schet        ,input tt_fin-doc.payer-type           ,input tt_fin-doc.perm-date            ,input tt_fin-doc.prn-doc-code         ,input tt_fin-doc.PS                   ,input tt_fin-doc.receiver-bank-name   ,input tt_fin-doc.receiver-bank-city   ,input tt_fin-doc.receiver-bik         ,input tt_fin-doc.receiver-c-schet     ,input tt_fin-doc.receiver-code        ,input tt_fin-doc.receiver-code-schet  ,input tt_fin-doc.receiver-dop1        ,input tt_fin-doc.receiver-dop2        ,input tt_fin-doc.receiver-inn         ,input tt_fin-doc.receiver-kpp         ,input tt_fin-doc.receiver-name        ,input tt_fin-doc.receiver-okpo        ,input tt_fin-doc.receiver-passport    ,input tt_fin-doc.receiver-r-schet     ,input tt_fin-doc.receiver-type        ,input tt_fin-doc.srok-pl              ,input tt_fin-doc.stat-pl              ,input tt_fin-doc.str-podr-code        ,input tt_fin-doc.str-podr-type        ,input tt_fin-doc.str-podr-name        ,input tt_fin-doc.sum-base             ,input tt_fin-doc.sum-doc              ,input tt_fin-doc.sum-rubl             ,input tt_fin-doc.sum-contr            ,input tt_fin-doc.trn-doc-code         ,input tt_fin-doc.vid-opl              ,input tt_fin-doc.vid-plat
       ,input tt_fin-doc.con-sum-rubl         ,input tt_fin-doc.con-sum-base         ,input tt_fin-doc.con-sum-doc          ,input tt_fin-doc.con-sum-contr        ,input tt_fin-doc.con-stat             ,input tt_fin-doc.payer-sign1                ,input tt_fin-doc.payer-sign2                ,input tt_fin-doc.payer-sign3                ,input tt_fin-doc.payer-sign4                ,input tt_fin-doc.receiver-sign1                ,input tt_fin-doc.receiver-sign2                ,input tt_fin-doc.receiver-sign3                ,input tt_fin-doc.receiver-sign4                ,input tt_fin-doc.obj-type                   ,input tt_fin-doc.obj-code                   ,input tt_fin-doc.doc-author                 ,input tt_fin-doc.fact-author                ,input tt_fin-doc.CashBookId
       ,input table tt0_fin-doc-tax
       ,input table tt_fin-doc-attr
       ,input no
       ,input table tt0-payment
       ) no-error .
     if error-status:error then do:
       assign v-err = yes .
       output stream LogStream to Value(v-message-text) append.
       put stream Logstream unformatted
         substitute("Ошибка создания платежа! Вн.№ договора &1  ФО &2&3&4"
                    , tt-fin-doc.contract-code
                    , tt-fin-doc.str-fo
                    , chr(10)
                    ,substitute( "&1&2&3", vss-workfile, return-value, chr(10), error-status :get-message (1))
                    ) skip.
       output stream LogStream close.
     end.
     if v-err = no then do:
       for each tt_fin-connect where tt_fin-connect.fin-doc-code = tt-fin-doc.fin-doc-code :
         create ub.fin-connect .
         BUFFER-COPY tt_fin-connect TO ub.fin-connect .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdburt in g#library
  (output ub.fin-connect.user-db-num
  ,output ub.fin-connect.user-name
  ,output ub.fin-connect.fact-date
  ,output p-sys-time
  ,output ub.fin-connect.fact-time
  )  .
         find first ub.fin-ob exclusive-lock where ub.fin-ob.host-code = p-host-code and ub.fin-ob.doc-code = ub.fin-connect.fin-ob-code .
         assign
           ub.fin-ob.con-sum-doc   = ub.fin-ob.sum-doc
           ub.fin-ob.con-sum-rubl  = ub.fin-ob.sum-rubl
           ub.fin-ob.con-sum-base  = ub.fin-ob.sum-base
           ub.fin-ob.con-sum-contr = ub.fin-ob.sum-contr
           ub.fin-ob.con-stat      = 2
         .
       end.
       find first ub.fin-doc exclusive-lock where recid(ub.fin-doc) = p-doc-rec .
       assign
         ub.fin-doc.con-sum-rubl  = ub.fin-doc.sum-rubl
         ub.fin-doc.con-sum-base  = ub.fin-doc.sum-base
         ub.fin-doc.con-sum-doc   = ub.fin-doc.sum-doc
         ub.fin-doc.con-sum-contr = ub.fin-doc.sum-contr
         ub.fin-doc.con-stat      = 2
       .
       output stream LogStream to Value(v-message-text) append.
       put stream Logstream unformatted
       substitute("Успешно создан &1 № &2 по фин.об &3 ! Вн.№ договора &4", tt-fin-doc.fin-doc-type, tt-fin-doc.prn-doc-code, tt-fin-doc.str-fo, buf_contract.contract-code) skip.
       output stream LogStream close.
     end.
   end.
  end.
end procedure.
define variable vss-include-info10 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
PROCEDURE StrTax :
  do
  on error undo, return error return-value
  :
    define input-output parameter str as character no-undo .
    assign str = " В т.ч.: "  .
    for each tt0-fin-doc-tax :
      if tt0-fin-doc-tax.with-vat = no then next.
      if str <> " В т.ч.: " then str = str + "," .
      if tt-fin-doc.curr-code = 0 then
        assign str = str + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " руб. (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
      else
        assign str = str + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
    end.
    if str = " В т.ч.: " then assign str = "" .
  end.
END PROCEDURE.
PROCEDURE InvertCli :
  do
  on error undo, return error return-value
  :
      define variable payer-bank-name    like ub.fin-doc.payer-bank-name  .
      define variable payer-bank-city    like ub.fin-doc.payer-bank-city  .
      define variable payer-bik          like ub.fin-doc.payer-bik        .
      define variable payer-c-schet      like ub.fin-doc.payer-c-schet    .
      define variable payer-code         like ub.fin-doc.payer-code       .
      define variable payer-code-schet   like ub.fin-doc.payer-code-schet .
      define variable payer-inn          like ub.fin-doc.payer-inn        .
      define variable payer-kpp          like ub.fin-doc.payer-kpp        .
      define variable payer-name         like ub.fin-doc.payer-name       .
      define variable payer-okpo         like ub.fin-doc.payer-okpo       .
      define variable payer-passport     like ub.fin-doc.payer-passport   .
      define variable payer-r-schet      like ub.fin-doc.payer-r-schet    .
      define variable payer-type         like ub.fin-doc.payer-type       .
      assign
        tt-fin-doc.sum-rubl  = - tt-fin-doc.sum-rubl
        tt-fin-doc.sum-base  = - tt-fin-doc.sum-base
        tt-fin-doc.sum-doc   = - tt-fin-doc.sum-doc
        tt-fin-doc.sum-contr = - tt-fin-doc.sum-contr
        payer-bank-name      = tt-fin-doc.payer-bank-name
        payer-bank-city      = tt-fin-doc.payer-bank-city
        payer-bik            = tt-fin-doc.payer-bik
        payer-c-schet        = tt-fin-doc.payer-c-schet
        payer-code           = tt-fin-doc.payer-code
        payer-code-schet     = tt-fin-doc.payer-code-schet
        payer-inn            = tt-fin-doc.payer-inn
        payer-kpp            = tt-fin-doc.payer-kpp
        payer-name           = tt-fin-doc.payer-name
        payer-okpo           = tt-fin-doc.payer-okpo
        payer-passport       = tt-fin-doc.payer-passport
        payer-r-schet        = tt-fin-doc.payer-r-schet
        payer-type           = tt-fin-doc.payer-type
        tt-fin-doc.payer-bank-name    = tt-fin-doc.receiver-bank-name
        tt-fin-doc.payer-bank-city    = tt-fin-doc.receiver-bank-city
        tt-fin-doc.payer-bik          = tt-fin-doc.receiver-bik
        tt-fin-doc.payer-c-schet      = tt-fin-doc.receiver-c-schet
        tt-fin-doc.payer-code         = tt-fin-doc.receiver-code
        tt-fin-doc.payer-code-schet   = tt-fin-doc.receiver-code-schet
        tt-fin-doc.payer-inn          = tt-fin-doc.receiver-inn
        tt-fin-doc.payer-kpp          = tt-fin-doc.receiver-kpp
        tt-fin-doc.payer-name         = tt-fin-doc.receiver-name
        tt-fin-doc.payer-okpo         = tt-fin-doc.receiver-okpo
        tt-fin-doc.payer-passport     = tt-fin-doc.receiver-passport
        tt-fin-doc.payer-r-schet      = tt-fin-doc.receiver-r-schet
        tt-fin-doc.payer-type         = tt-fin-doc.receiver-type
        tt-fin-doc.receiver-bank-name =  payer-bank-name
        tt-fin-doc.receiver-bank-city =  payer-bank-city
        tt-fin-doc.receiver-bik       =  payer-bik
        tt-fin-doc.receiver-c-schet   =  payer-c-schet
        tt-fin-doc.receiver-code      =  payer-code
        tt-fin-doc.receiver-code-schet = payer-code-schet
        tt-fin-doc.receiver-inn       =  payer-inn
        tt-fin-doc.receiver-kpp       =  payer-kpp
        tt-fin-doc.receiver-name      =  payer-name
        tt-fin-doc.receiver-okpo      =  payer-okpo
        tt-fin-doc.receiver-passport  =  payer-passport
        tt-fin-doc.receiver-r-schet   =  payer-r-schet
        tt-fin-doc.receiver-type      =  payer-type
      .
      for each  tt0-fin-doc-tax no-lock :
        assign
          tt0-fin-doc-tax.sum-line-doc       = - tt0-fin-doc-tax.sum-line-doc
          tt0-fin-doc-tax.sum-vat-line-doc   = - tt0-fin-doc-tax.sum-vat-line-doc
          tt0-fin-doc-tax.sum-slt-line-doc   = - tt0-fin-doc-tax.sum-slt-line-doc
          tt0-fin-doc-tax.sum-line-rubl      = - tt0-fin-doc-tax.sum-line-rubl
          tt0-fin-doc-tax.sum-vat-line-rubl  = - tt0-fin-doc-tax.sum-vat-line-rubl
          tt0-fin-doc-tax.sum-slt-line-rubl  = - tt0-fin-doc-tax.sum-slt-line-rubl
          tt0-fin-doc-tax.sum-line-base      = - tt0-fin-doc-tax.sum-line-base
          tt0-fin-doc-tax.sum-vat-line-base  = - tt0-fin-doc-tax.sum-vat-line-base
          tt0-fin-doc-tax.sum-slt-line-base  = - tt0-fin-doc-tax.sum-slt-line-base
          tt0-fin-doc-tax.sum-line-contr     = - tt0-fin-doc-tax.sum-line-contr
          tt0-fin-doc-tax.sum-vat-line-contr = - tt0-fin-doc-tax.sum-vat-line-contr
          tt0-fin-doc-tax.sum-slt-line-contr = - tt0-fin-doc-tax.sum-slt-line-contr
        .
      end.
  end.
END PROCEDURE.
PROCEDURE CheckCli :
  do
  on error undo, return error return-value
  :
    if tt-fin-doc.payer-code = p-host-code and tt-fin-doc.payer-type = 'орг':U then do:
      assign
        tt-fin-doc.payer-bik        = buf_contract.own-bik
        tt-fin-doc.payer-code-schet = buf_contract.own-code-schet
        tt-fin-doc.payer-inn        = buf_contract.own-inn
        tt-fin-doc.payer-kpp        = buf_contract.own-kpp
      .
      if tt-fin-doc.receiver-code = buf_contract.cli-code and tt-fin-doc.receiver-type = buf_contract.cli-type then do:
        assign
          tt-fin-doc.receiver-bik        = buf_contract.cli-bik
          tt-fin-doc.receiver-code-schet = buf_contract.cli-code-schet
          tt-fin-doc.receiver-inn        = buf_contract.cli-inn
          tt-fin-doc.receiver-kpp        = buf_contract.cli-kpp
        .
      end.
      else do:
        if tt-fin-doc.receiver-code = buf_contract.posr-code and tt-fin-doc.receiver-type = buf_contract.posr-type then do:
          assign
            tt-fin-doc.receiver-bik        = buf_contract.posr-bik
            tt-fin-doc.receiver-code-schet = buf_contract.posr-code-schet
            tt-fin-doc.receiver-inn        = buf_contract.posr-inn
            tt-fin-doc.receiver-kpp        = buf_contract.posr-kpp
          .
        end.
        else do:
          assign
            tt-fin-doc.receiver-bik        = buf_contract.agnt-bik
            tt-fin-doc.receiver-code-schet = buf_contract.agnt-code-schet
            tt-fin-doc.receiver-inn        = buf_contract.agnt-inn
            tt-fin-doc.receiver-kpp        = buf_contract.agnt-kpp
          .
        end.
      end.
    end.
    else do:
      if tt-fin-doc.receiver-code = p-host-code and tt-fin-doc.receiver-type = 'орг':U then do:
        assign
          tt-fin-doc.receiver-bik        = buf_contract.own-bik
          tt-fin-doc.receiver-code-schet = buf_contract.own-code-schet
          tt-fin-doc.receiver-inn        = buf_contract.own-inn
          tt-fin-doc.receiver-kpp        = buf_contract.own-kpp
        .
        if tt-fin-doc.payer-code = buf_contract.cli-code and tt-fin-doc.payer-type = buf_contract.cli-type then do:
          assign
            tt-fin-doc.payer-bik        = buf_contract.cli-bik
            tt-fin-doc.payer-code-schet = buf_contract.cli-code-schet
            tt-fin-doc.payer-inn        = buf_contract.cli-inn
            tt-fin-doc.payer-kpp        = buf_contract.cli-kpp
          .
        end.
        else do:
          if tt-fin-doc.payer-code = buf_contract.posr-code and tt-fin-doc.payer-type = buf_contract.posr-type then do:
            assign
              tt-fin-doc.payer-bik        = buf_contract.posr-bik
              tt-fin-doc.payer-code-schet = buf_contract.posr-code-schet
              tt-fin-doc.payer-inn        = buf_contract.posr-inn
              tt-fin-doc.payer-kpp        = buf_contract.posr-kpp
            .
          end.
          else do:
            assign
              tt-fin-doc.payer-bik        = buf_contract.agnt-bik
              tt-fin-doc.payer-code-schet = buf_contract.agnt-code-schet
              tt-fin-doc.payer-inn        = buf_contract.agnt-inn
              tt-fin-doc.payer-kpp        = buf_contract.agnt-kpp
            .
          end.
        end.
      end.
      else return error .
    end.
  end.
END PROCEDURE.
PROCEDURE UchetCode :
  do
  on error undo, return error return-value
  :
    case tt-fin-doc.fin-doc-type :
      when 'пко':U then do:
        assign
          tt-fin-doc.cor-acc       = buf_contract.cor-acc-in-cash
          tt-fin-doc.cor-acc1      = buf_contract.cor-acc1-in-cash
          tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-in-cash
          tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-in-cash
        .
      end.
      when 'рко':U then do:
        assign
          tt-fin-doc.cor-acc       = buf_contract.cor-acc-out-cash
          tt-fin-doc.cor-acc1      = buf_contract.cor-acc1-out-cash
          tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-out-cash
          tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-out-cash
        .
      end.
      when 'ппп':U then do:
        assign
          tt-fin-doc.cor-acc       = buf_contract.cor-acc-in
          tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-in
          tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-in
        .
      end.
      when 'рпп':U then do:
        assign
          tt-fin-doc.cor-acc       = buf_contract.cor-acc-out
          tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-out
          tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-out
        .
      end.
      when 'апп':U then do:
        assign
          tt-fin-doc.cor-acc       = buf_contract.cor-acc-in-payoff
          tt-fin-doc.cor-acc1      = buf_contract.cor-acc1-in-payoff
          tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-in-payoff
          tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-in-payoff
        .
      end.
      when 'апр':U then do:
        assign
          tt-fin-doc.cor-acc       = buf_contract.cor-acc-out-payoff
          tt-fin-doc.cor-acc1      = buf_contract.cor-acc1-out-payoff
          tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-out-payoff
          tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-out-payoff
        .
      end.
    end.
    find first ub.fin-code-cel-nazn no-lock where ub.fin-code-cel-nazn.host-code = p-host-code and ub.fin-code-cel-nazn.fin-code = tt-fin-doc.cel-nazn-code no-error .
    if available ub.fin-code-cel-nazn then assign tt-fin-doc.cel-nazn-value = ub.fin-code-cel-nazn.code-value .
    find first ub.fin-code-an-uchet no-lock where ub.fin-code-an-uchet.host-code = p-host-code and ub.fin-code-an-uchet.fin-code = tt-fin-doc.an-uchet-code no-error .
    if available ub.fin-code-an-uchet then assign tt-fin-doc.an-uchet-value = ub.fin-code-an-uchet.code-value .
    find first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.host-code = p-host-code and ub.fin-code-cor-acc.fin-code = tt-fin-doc.cor-acc no-error .
    if available ub.fin-code-cor-acc then assign tt-fin-doc.cor-acc-value = ub.fin-code-cor-acc.code-value .
    find first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.host-code = p-host-code and ub.fin-code-cor-acc.fin-code = tt-fin-doc.cor-acc1 no-error .
    if available ub.fin-code-cor-acc then assign tt-fin-doc.cor-acc1-value = ub.fin-code-cor-acc.code-value .
  end.
END PROCEDURE.
PROCEDURE FindBank :
  do
  on error undo, return error return-value
  :
  find first b1_fin-schet no-lock where b1_fin-schet.host-code = p-host-code and b1_fin-schet.code-schet = tt-fin-doc.receiver-code-schet no-error .
  find first ub.fin-bank no-lock where ub.fin-bank.host-code = p-host-code and ub.fin-bank.code-bank = b1_fin-schet.code-bank no-error .
  if available b1_fin-schet then
  assign
    tt-fin-doc.receiver-bank-name  = ub.fin-bank.bank-name
    tt-fin-doc.receiver-bank-city  = ub.fin-bank.bank-city
    tt-fin-doc.receiver-c-schet    = b1_fin-schet.c-schet
    tt-fin-doc.receiver-r-schet    = b1_fin-schet.r-schet
  .
  find first b2_fin-schet no-lock where b2_fin-schet.host-code = p-host-code and b2_fin-schet.code-schet = tt-fin-doc.payer-code-schet no-error .
  find first ub.fin-bank no-lock where ub.fin-bank.host-code = p-host-code and ub.fin-bank.code-bank = b2_fin-schet.code-bank no-error .
  if available b2_fin-schet then
  assign
    tt-fin-doc.payer-bank-name  = ub.fin-bank.bank-name
    tt-fin-doc.payer-bank-city  = ub.fin-bank.bank-city
    tt-fin-doc.payer-c-schet    = b2_fin-schet.c-schet
    tt-fin-doc.payer-r-schet    = b2_fin-schet.r-schet
  .
  end.
END PROCEDURE.
