block-level on error undo, throw.
define input parameter parparentproc     as widget-handle no-undo.
define input parameter p-rec_id          as recid         no-undo.
define input parameter p-doc-type        as character     no-undo.
define input parameter p-price-celection as integer       no-undo.
define input parameter p-print-null-qnty as logical       no-undo.
define input parameter p-sort-by-group   as logical       no-undo.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      as character no-undo initial "$Author: expertek $":U.
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: r-act-kg.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: rep/r-act-kg.p $":U.
define variable vss-description as character no-undo initial "Печать акта и протокола переоценки топлива в кг (весовой учет топлива)":U.
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
function cross-list returns logical (
  input parfirst-stream  as character,
  input parsecond-stream as character,
  input pardelim         as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  define variable vari            as integer no-undo .
  define variable varresult-cross as logical no-undo .
  assign
    varresult-cross = no
  .
  def var v-num-parfirst-stream as integer no-undo .
  assign
    v-num-parfirst-stream = num-entries(parfirst-stream, pardelim)
  .
  do vari = 1 to v-num-parfirst-stream
  :
    if lookup(entry(vari, parfirst-stream, pardelim)
             ,parsecond-stream
             ,pardelim
             ) > 0 then do:
      assign
        varresult-cross = yes
      .
      leave.
    end.
  end.
  return varresult-cross .
end function.
function hvrdtax return logical (input parrecid as recid):
define variable varresult as logical no-undo.
run hvrdtax-proc (input parrecid, output varresult).
return varresult.
end function.
procedure hvrdtax-proc:
define input  parameter parrecid  as recid   no-undo.
define output parameter parresult as logical no-undo.
define buffer bf_goods for ub.goods.
define buffer bf_units for ub.units.
define buffer rt_tax   for ub.tax.
find first rt_tax   where rt_tax.tax-code    = integer('3':U) no-lock no-error.
find first bf_goods where recid(bf_goods)    = parrecid              no-lock.
find first bf_units where bf_units.unit-name = bf_goods.unit-base    no-lock.
if available rt_tax and
    can-find(first ub.tax-units No-LOCK WHERE
                   ub.tax-units.tax-code = rt_tax.tax-code AND
                   LOOKUP(ub.tax-units.type, bf_units.type) > 0) then assign parresult = yes.
                                                    else assign parresult = no.
end procedure.
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tax-name:
define input  parameter pardef-tax  as character           no-undo.
define output parameter parname-tax as character initial ? no-undo.
define buffer bf_tax for ub.tax.
do on error undo, return error :
   case pardef-tax:
      when 'vat':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('1':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '1':U(не задействован)".
      end.
      when 'slt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('2':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '2':U(не задействован)".
      end.
      when 'rdt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('3':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '3':U(не задействован)".
      end.
      when 'exc':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('4':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '4':U(не задействован)".
      end.
      otherwise do:
         return error "Задан неверный параметр " + pardef-tax + " .".
      end.
   end case.
end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION determined RETURNS DECIMAL (INPUT parundefine-var AS DECIMAL):
   IF parundefine-var = ? THEN RETURN 0.00.
                          ELSE RETURN parundefine-var.
END FUNCTION.
FUNCTION dtm-char RETURNS CHARACTER (INPUT p-undef-char AS CHARACTER):
   IF p-undef-char = ? THEN do:
     RETURN "?".
   end.
   ELSE do:
     RETURN p-undef-char .
   end.
END FUNCTION.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    def var log-file-name as char no-undo.
    assign
        log-file-name = 'r-act-kg.log'
    .
    if log-file-name <> "":U
    then do:
        if search( 'r-act-kg.log' ) = ?
        then do:
            output to value( 'r-act-kg.log' ).
            output close.
        end.
    end.
    DEF STREAM stm-log.
    PROCEDURE writelog:
    DEF INPUT PARAMETER p-file-name AS CHAR     NO-UNDO.
    DEF INPUT PARAMETER p-log-level AS INTEGER  NO-UNDO.
    DEF INPUT PARAMETER p-log-string  AS CHAR     NO-UNDO.
    if p-file-name <> ""
    then do:
    OUTPUT STREAM stm-log TO VALUE(p-file-name) APPEND.
        PUT STREAM stm-log UNFORMATTED chr(10).
        PUT STREAM stm-log UNFORMATTED (IF (p-log-level = 0 OR p-log-string = "&DLine"
                                        OR p-log-string = "&Line") THEN "" ELSE
                                        cur-time-string-sec() + " ").
        PUT STREAM stm-log UNFORMATTED
                (IF p-log-string = "&Line" THEN FILL("-", 80)
                ELSE IF p-log-string = "&DLine" THEN FILL("=", 80)
                ELSE fill(" ", p-log-level * 2) + p-log-string).
    OUTPUT STREAM stm-log CLOSE.
    end.
    END PROCEDURE.
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
FUNCTION RedLine RETURNS CHARACTER ( INPUT i-str AS CHARACTER ) :
  DEFINE VARIABLE v-str AS CHARACTER NO-UNDO.
  RUN get-red-line IN THIS-PROCEDURE ( INPUT i-str, OUTPUT v-str ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN i-str ELSE v-str ).
END FUNCTION.
PROCEDURE get-red-line :
  DEFINE  INPUT PARAMETER p-str AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS CHARACTER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-res = CAPS( SUBSTRING( p-str, 1, 1 ) ) + LC( SUBSTRING( p-str, 2 ) ).
  END.
END PROCEDURE.
FUNCTION Roubles RETURNS CHARACTER ( INPUT i-sum AS DECIMAL ) :
  DEFINE VARIABLE Rouble AS CHARACTER NO-UNDO.
  RUN get-roubles IN THIS-PROCEDURE ( INPUT i-sum, OUTPUT Rouble ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE Rouble ).
END FUNCTION.
PROCEDURE get-roubles :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-rub AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Word   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE jj     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_last AS INTEGER   NO-UNDO.
  DEFINE VARIABLE l_prev AS LOGICAL   NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN Word   = STRING( ABS( p-sum ), "999999999999999999999999999999.99":U )
           jj     = LENGTH( Word )
           j_last = INTEGER( SUBSTRING( Word, jj - 3, 1 ) )
           l_prev =        ( SUBSTRING( Word, jj - 4, 1 ) = "1" ).
    IF      j_last = 1                THEN DO: ASSIGN p-rub = ( IF l_prev = YES THEN "рублей" ELSE "рубль" ).  END.
    ELSE IF j_last > 1 AND j_last < 5 THEN DO: ASSIGN p-rub = ( IF l_prev = YES THEN "рублей" ELSE "рубля" ). END.
                                      ELSE DO: ASSIGN p-rub = "рублей". END.
  END.
END PROCEDURE.
FUNCTION Copecks RETURNS CHARACTER ( INPUT i-sum AS DECIMAL ) :
  DEFINE VARIABLE Copeck AS CHARACTER NO-UNDO.
  RUN get-copecks IN THIS-PROCEDURE ( INPUT i-sum, OUTPUT Copeck ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE Copeck ).
END FUNCTION.
PROCEDURE get-copecks :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-kop AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Word   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE jj     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_last AS INTEGER   NO-UNDO.
  DEFINE VARIABLE l_prev AS LOGICAL   NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN  Word   = STRING( ABS( p-sum ), "999999999999999999999999999999.99":U )
            jj     = LENGTH( Word )
            j_last = INTEGER( SUBSTRING( Word, jj,     1 ) )
            l_prev =        ( SUBSTRING( Word, jj - 1, 1 ) = "1" ).
    IF           j_last = 1                THEN DO:
      ASSIGN p-kop = ( IF l_prev = YES THEN "копеек" ELSE "копейка" ).
    END. ELSE IF j_last > 1 AND j_last < 5 THEN DO:
      ASSIGN p-kop = ( IF l_prev = YES THEN "копеек" ELSE "копейки" ).
    END.                                   ELSE DO:
      ASSIGN p-kop = "копеек".
    END.
  END.
END PROCEDURE.
FUNCTION get-decade-word RETURNS CHARACTER ( INPUT i-dec AS INTEGER, INPUT i-num AS INTEGER ) :
  DEFINE VARIABLE v-grade AS CHARACTER NO-UNDO.
  RUN get-number-grade IN THIS-PROCEDURE ( INPUT i-dec, INPUT i-num, OUTPUT v-grade ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE v-grade ).
END FUNCTION.
FUNCTION Word-Sum RETURNS CHARACTER ( INPUT i-sum AS DECIMAL ) :
  DEFINE VARIABLE OutSum AS CHARACTER NO-UNDO.
  RUN conv-sum-to-word IN THIS-PROCEDURE ( INPUT i-sum, OUTPUT OutSum ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE OutSum ).
END FUNCTION.
PROCEDURE get-number-grade :
  DEFINE  INPUT PARAMETER p-dec AS INTEGER   NO-UNDO.
  DEFINE  INPUT PARAMETER p-num AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-list AS CHARACTER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    IF      p-dec = 1 THEN DO: ASSIGN v-list = ",один,два,три,четыре,пять,шесть,семь,восемь,девять".    END.
    ELSE IF p-dec = 2 THEN DO: ASSIGN v-list = "десять,одиннадцать,двенадцать,тринадцать,четырнадцать,пятнадцать,шестнадцать,семнадцать,восемнадцать,девятнадцать".    END.
    ELSE IF p-dec = 3 THEN DO: ASSIGN v-list = ",,двадцать,тридцать,сорок,пятьдесят,шестьдесят,семьдесят,восемьдесят,девяносто".   END.
    ELSE IF p-dec = 4 THEN DO: ASSIGN v-list = ",сто,двести,триста,четыреста,пятьсот,шестьсот,семьсот,восемьсот,девятьсот".  END.
                      ELSE DO: ASSIGN v-list = ",,,,,,,,,". END.
    ASSIGN p-res = ENTRY( p-num + 1, v-list ).
  END.
END PROCEDURE.
PROCEDURE conv-sum-to-word :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Formatted  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Word       AS CHARACTER NO-UNDO.
  DEFINE VARIABLE OutSum     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE jj         AS INTEGER   NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN Formatted = STRING( ABS( p-sum ), "999999999999999.99":U ) NO-ERROR.
    IF ERROR-STATUS :ERROR THEN DO:
      ASSIGN p-res = ?.
      UNDO, RETURN ERROR.
    END.
    DO jj = ( LENGTH( Formatted ) - 3 ) TO 3 BY -3 :
      IF SUBSTRING( Formatted, jj - 2, 3 ) = "000" THEN DO: NEXT. END.
      IF jj < 15 THEN DO:
        ASSIGN Word = ENTRY( jj, ",,триллион,,,миллиард,,,миллион,,,тысяч" ).
        IF SUBSTRING( Formatted, jj,     1 )  = "1" AND
           SUBSTRING( Formatted, jj - 1, 1 ) <> "1" AND jj = 12 THEN DO: ASSIGN Word = TRIM( Word ) + "а". END.
        IF SUBSTRING( Formatted, jj, 1 ) = "2" OR
           SUBSTRING( Formatted, jj, 1 ) = "3" OR
           SUBSTRING( Formatted, jj, 1 ) = "4" THEN DO:
          IF jj = 12 THEN DO:
            IF SUBSTRING( Formatted, jj - 1, 1 ) <> "1" THEN DO: ASSIGN Word = TRIM( Word ) + "и". END.
          END.       ELSE DO:
            IF SUBSTRING( Formatted, jj - 1, 1 ) <> "1" THEN DO: ASSIGN Word = TRIM( Word ) + "а". END.
          END.
        END.
        IF ( SUBSTRING( Formatted, jj,     1 ) <> "1" AND
             SUBSTRING( Formatted, jj,     1 ) <> "2" AND
             SUBSTRING( Formatted, jj,     1 ) <> "3" AND
             SUBSTRING( Formatted, jj,     1 ) <> "4" AND jj <> 12 ) OR
           ( SUBSTRING( Formatted, jj - 1, 1 )  = "1" AND jj <  12 ) THEN DO: ASSIGN Word = TRIM( Word ) + "ов". END.
        IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
      END.
      IF SUBSTRING( Formatted, jj - 1, 1 ) <> "1" THEN DO:
        IF      jj = 12 AND SUBSTRING( Formatted, jj, 1 ) = "1" THEN DO: ASSIGN Word = "одна". END.
        ELSE IF jj = 12 AND SUBSTRING( Formatted, jj, 1 ) = "2" THEN DO: ASSIGN Word = "две".  END.
        ELSE DO: ASSIGN Word = get-decade-word( 1, INTEGER( SUBSTRING( Formatted, jj, 1 ) ) ). END.
        IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
        ASSIGN Word = get-decade-word( 3, INTEGER( SUBSTRING( Formatted, jj - 1, 1 ) ) ).
      END.                                        ELSE DO:
        ASSIGN Word = get-decade-word( 2, INTEGER( SUBSTRING( Formatted, jj,     1 ) ) ).
      END.
      IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
      ASSIGN Word = get-decade-word( 4, INTEGER( SUBSTRING( Formatted, jj - 2, 1 ) ) ).
      IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
    END.
    ASSIGN OutSum = CAPS( SUBSTRING( OutSum, 1, 1 ) ) + SUBSTRING( OutSum, 2 ).
    IF OutSum = "":U AND TRUNCATE( p-sum, 0 ) = 0 THEN DO: ASSIGN OutSum = "Ноль". END.
    ASSIGN p-res = TRIM( OutSum ).
  END.
END PROCEDURE.
FUNCTION Total-Word RETURNS CHARACTER ( INPUT i-sum AS DECIMAL, INPUT i-curr AS CHARACTER, INPUT i-part AS CHARACTER ) :
  DEFINE VARIABLE word_sum AS CHARACTER NO-UNDO.
  RUN get-total-word IN THIS-PROCEDURE ( INPUT i-sum, INPUT i-curr, INPUT i-part, OUTPUT word_sum ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE word_sum ).
END FUNCTION.
PROCEDURE get-total-word :
  DEFINE  INPUT PARAMETER p-sum  AS DECIMAL   NO-UNDO.
  DEFINE  INPUT PARAMETER p-curr AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-part AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-word AS CHARACTER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-word = Word-Sum( p-sum ).
               ASSIGN p-word = ( IF p-sum < 0 THEN "- " ELSE "":U ) + TRIM(
                      RedLine( p-word )
               ) +
                      " ":U + p-curr + " ":U +
                      SUBSTRING( STRING( ABS( p-sum ), "999999999999999999999999999999.99" ), 32, 2 ) +
                      " ":U + p-part + ".".
                        END.
END PROCEDURE.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxp-doc-prt         like ub.store.doc-prt         no-undo.
  define variable v-cntxp-price-calc      like ub.store.price-calc      no-undo.
  define variable v-cntxp-inout-price     like ub.store.inout-price     no-undo.
  define variable v-cntxp-unit-cli-perm   like ub.store.unit-cli-perm   no-undo.
  define variable v-cntxp-out-rate        like ub.store.out-rate        no-undo.
  define variable v-cntxp-out-line-discnt like ub.store.out-line-discnt no-undo.
  define variable v-cntxp-in-ov           like ub.store.in-ov           no-undo.
  define variable v-cntxp-in-perm         like ub.store.in-perm         no-undo.
  define variable v-cntxp-no-eq           like ub.store.no-eq           no-undo.
  define variable v-cntxp-rsrv-time       like ub.store.rsrv-time       no-undo.
  define variable v-cntxp-load-time       like ub.store.load-time       no-undo.
  define variable v-cntxp-holidays        like ub.store.holidays        no-undo.
  define variable v-cntxp-in-pay          like ub.store.in-pay          no-undo.
  define variable v-cntxp-out-pay         like ub.store.out-pay         no-undo.
  define variable v-cntxp-ret-pay         like ub.store.ret-pay         no-undo.
  define variable v-cntxp-ret-sup-pay     like ub.store.ret-sup-pay     no-undo.
  define variable v-cntxp-down-pay        like ub.store.down-pay        no-undo.
  define variable v-cntxp-inv-pay         like ub.store.inv-pay         no-undo.
  define variable v-cntxp-chk-pay         like ub.store.chk-pay         no-undo.
  define variable v-cntxp-retail          like ub.sysconf.ord-prt       no-undo.
  define variable v-cntxp-osn-base        like ub.sysconf.osn-base      no-undo.
  define variable v-cntxp-conf-par        as   character                no-undo.
  define variable v-cntxp-par-type        as   character                no-undo.
  define variable v-cntxp-curr-host-code  like ub.store.host-code       no-undo.
  define variable v-cntxp-obj-type        like ub.clients.obj-type      no-undo.
  define variable v-cntxp-obj-code        like ub.clients.obj-code      no-undo.
  define variable v-cntxp-db-num          as integer   no-undo .
  define variable v-cntxp-userid          as character no-undo .
  define variable v-cntxp-level           as character no-undo .
  define variable v-cntxp-db-num-obj      as integer   no-undo .
  define variable v-cntxp-is-admin        as logical   no-undo .
  define buffer bf-cntxp_store for ub.store.
  define buffer bf-cntxp_shop  for ub.shop.
  define buffer bf-cntxp_sysconf for ub.sysconf.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxp-db-num
    ,output v-cntxp-userid
    ,output v-cntxp-level
    ,output v-cntxp-curr-host-code
    ,output v-cntxp-obj-type
    ,output v-cntxp-obj-code
    ,output v-cntxp-db-num-obj
    ,output v-cntxp-is-admin
    ) .
  if (v-cntxp-obj-type = 'маг':U or v-cntxp-obj-type = 'скл':U) and
     v-cntxp-obj-code <> 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output v-cntxp-conf-par
  ,output v-cntxp-par-type
  ) no-error .
    case v-cntxp-obj-type :
      when 'скл':U then do:
        find first bf-cntxp_store where bf-cntxp_store.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_store.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_store.doc-prt
          v-cntxp-price-calc      = bf-cntxp_store.price-calc
          v-cntxp-inout-price     = bf-cntxp_store.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_store.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_store.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_store.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_store.in-ov
          v-cntxp-in-perm         = bf-cntxp_store.in-perm
          v-cntxp-no-eq           = bf-cntxp_store.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_store.rsrv-time
          v-cntxp-load-time       = bf-cntxp_store.load-time
          v-cntxp-holidays        = bf-cntxp_store.holidays
          v-cntxp-in-pay          = bf-cntxp_store.in-pay
          v-cntxp-out-pay         = bf-cntxp_store.out-pay
          v-cntxp-ret-pay         = bf-cntxp_store.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_store.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_store.down-pay
          v-cntxp-inv-pay         = bf-cntxp_store.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_store.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
      when 'маг':U then do:
        find first bf-cntxp_shop where bf-cntxp_shop.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_shop.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_shop.doc-prt
          v-cntxp-price-calc      = bf-cntxp_shop.price-calc
          v-cntxp-inout-price     = bf-cntxp_shop.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_shop.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_shop.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_shop.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_shop.in-ov
          v-cntxp-in-perm         = bf-cntxp_shop.in-perm
          v-cntxp-no-eq           = bf-cntxp_shop.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_shop.rsrv-time
          v-cntxp-load-time       = bf-cntxp_shop.load-time
          v-cntxp-holidays        = bf-cntxp_shop.holidays
          v-cntxp-in-pay          = bf-cntxp_shop.in-pay
          v-cntxp-out-pay         = bf-cntxp_shop.out-pay
          v-cntxp-ret-pay         = bf-cntxp_shop.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_shop.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_shop.down-pay
          v-cntxp-inv-pay         = bf-cntxp_shop.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_shop.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
    end case.
  end.
define variable g#report-num  as integer   no-undo.
define variable g#quest-print as logical   no-undo.
define variable g#log         as logical   no-undo.
define variable base-code     as integer   no-undo.
define variable base-type     as character no-undo.
define variable base-part     as character no-undo.
define variable v-cntxt-host-name-obj as character no-undo .
define buffer buf_clients    for ub.clients.
define buffer buf_price-list for ub.price-list.
define variable v-old-sum                    as   decimal                   no-undo.
define variable v-new-sum                    as   decimal                   no-undo.
define variable v-del-sum                    as   decimal                   no-undo.
define variable v-up-fact                    as   decimal                   no-undo.
define variable propis                       as   character                 no-undo.
define variable abbr                         as   character                 no-undo.
define variable v-single-line                as   character                 no-undo.
define variable v-b-code                     as   character                 no-undo.
define variable v-line-counter               as   integer                   no-undo.
define variable v-good-line-counter          as   integer                   no-undo.
define variable Log-Res1                     as   logical                   no-undo.
define variable v-print-cost-price           as   logical                   no-undo.
define variable v-shift-down                 as   logical                   no-undo initial yes.
define variable v-print-group                as   logical                   no-undo initial yes.
define variable v-price-doc_doc-num          like ub.price-doc.doc-num      no-undo.
define variable v-price-doc_doc-date         like ub.price-doc.doc-date     no-undo.
define variable v-trn-doc_doc-code           like ub.trn-doc.doc-code       no-undo.
define variable v-main-price-sale            like ub.price-list.price-sale  no-undo.
define variable v-rb-is-base                 as   logical                   no-undo.
define variable sym1                         as   character format "x(1)":U no-undo initial ":" column-label ":!:".
define variable sym2                         as   character format "x(1)":U no-undo initial ":" column-label ":!:".
define variable sym3                         as   character format "x(1)":U no-undo initial ":" column-label ":!:".
define variable sym4                         as   character format "x(1)":U no-undo initial ":" column-label ":!:".
define variable sym5                         as   character format "x(1)":U no-undo initial ":" column-label ":!:".
define variable sym6                         as   character format "x(1)":U no-undo initial ":" column-label ":!:".
define variable is-petrol                    as   logical                   no-undo.
define variable is-pieces                    as   logical                   no-undo.
define variable v-have-petrolium             as   logical                   no-undo.
define variable v-price-list_doc-qnty        like ub.price-list.doc-qnty    no-undo.
define variable v-price-list_doc-num         like ub.price-list.doc-num     no-undo.
define variable v-price-list_road-tax        like ub.price-list.road-tax    no-undo.
define variable v-price-list_excise          like ub.price-list.excise      no-undo.
define variable v-price-list_price-sale_old  like ub.price-list.price-sale  no-undo.
define variable v-price-list_price-sale_new  like ub.price-list.price-sale  no-undo.
define variable v-price-list_b-code          like ub.bar-code.b-code        no-undo.
define variable v-gds-obj_last-price         like ub.gds-obj.last-rubl      no-undo.
define variable v-gds-prt-node_code          like ub.gds-prt.node-code      no-undo.
define variable v-gds-prt-node_name          like ub.gds-prt.node-name      no-undo.
define variable v-code-is-main               as   logical                   no-undo.
define variable v-not-main-unit-cli          like ub.bar-code.unit-cli      no-undo.
define variable v-not-main-cli-base-rate     like ub.bar-code.cli-base-rate no-undo.
define variable v-not-main-b-code            like ub.bar-code.cli-base-rate no-undo.
define variable v-taxname                    as   character                 no-undo.
define variable v-tax                        as   decimal                   no-undo initial 0.
define variable v-tax-sum                    as   decimal                   no-undo initial 0.
define variable v-tax-parts-qnty             as   decimal                   no-undo initial 0.
define variable v-cli-base-rate              as   decimal                   no-undo initial 0.
define variable j-counter                    as   integer                   no-undo initial 0.
define variable v-print-rubl                 as   logical                   no-undo.
define variable v-price-list-recid           as   recid                     no-undo.
define variable v-total_doc-qnty             like ub.price-list.doc-qnty    no-undo initial 0.
define variable v-total_price-sale_old       like ub.price-list.price-sale  no-undo initial 0.
define variable v-total_price-sale_new       like ub.price-list.price-sale  no-undo initial 0.
define variable v-total_last-price-sale      like ub.gds-obj.last-rubl      no-undo initial 0.
define variable v-total_price-sale_diff      like ub.price-list.price-sale  no-undo initial 0.
define variable v-price-list_price-sale_diff like ub.price-list.price-sale  no-undo.
define variable v-parts_road-tax-rubl        like ub.price-list.price-sale  no-undo.
define stream AktStr.
define frame Prik
  sym1 v-good-line-counter         column-label "N!п/п"             format ">>>9":U
  sym2 v-b-code                    column-label "Код! "             format "x(10)":U
  sym3 ub.price-list.artic         column-label "Артикул! "         format "x(16)":U
  sym4 ub.goods.gds-name           column-label "Название товара! " format "x(33)":U
  sym5 ub.price-list.doc-qnty      column-label "Количество  ! "    format "->>>>>>>9.<<":U
       v-price-list_price-sale_old column-label "Старая прод.!цена" format "->>>,>>>,>>9.99":U
       ub.price-list.price-sale    column-label "Новая прод.!цена"  format "->>>,>>>,>>9.99":U
       v-up-fact                   column-label "Процент!разницы"   format "->>>>>>>9.9%":U         sym6
header cur-time-print( ) at 5 format "x(35)":U string( "Приказ на переоценку " ) at 47 format "x(25)":U
       v-price-doc_doc-num format "x(10)":U " от " v-price-doc_doc-date format "99/99/9999":U
       string( "Страница " + string( PAGE-NUMBER( AktStr ), ">>9":U ) ) at 120 format "x(13)":U skip
       v-single-line at 1 format "x(136)":U
with width 160 down stream-io use-text.
define frame Prik-Cost
  sym1 v-b-code                 column-label "Код! "                format "x(10)":U
       ub.price-list.artic      column-label "Артикул! "            format "x(16)":U
  sym4 ub.goods.gds-name        column-label "Название товара! "    format "x(42)":U
  sym5 ub.price-list.doc-qnty   column-label "Количество  ! "       format "->>>>>>>9.<<":U
       v-gds-obj_last-price     column-label "Последняя учет.!цена" format "->>>,>>>,>>9.99":U
       ub.price-list.price-sale column-label "Новая прод.!цена"     format "->>>,>>>,>>9.99":U
       v-up-fact                column-label "Процент!разницы"      format "->>>>>>>9.9%":U         sym6
header cur-time-print( ) at 5 format "x(35)":U
       string( "Приказ на переоценку " ) at 47 format "x(25)":U v-price-doc_doc-num format "x(10)":U " от " v-price-doc_doc-date format "99/99/9999":U
       string( "Страница " + string( PAGE-NUMBER( AktStr ), ">>9":U ) ) at 120 format "x(13)":U skip
       v-single-line format "x(136)":U at 1
with width 160 down stream-io use-text.
define frame Akt
  sym1 v-b-code                    column-label "Код! "                  format "x(10)":U
       ub.price-list.artic         column-label "Артикул! "              format "x(16)":U
       ub.goods.gds-name           column-label "Название товара! "      format "x(21)":U
       ub.price-list.doc-qnty      column-label "Количество! "           format "->>>>>9.<<":U
       v-price-list_price-sale_old column-label "Старая прод.!цена"      format "->>>>>>>9.99":U
       v-old-sum                   column-label "Старая сумма!прод. цен" format "->>>>>>>>>>>9.99":U
       ub.price-list.price-sale    column-label "Новая прод.!цена"       format "->>>>>>>9.99":U
       v-new-sum                   column-label "Новая сумма!прод. цен"  format "->>>>>>>>>>9.99":U
       v-up-fact                   column-label "Процент!разницы"        format "->>>>>>>9.9%":U         sym6
header cur-time-print( ) at 5 format "x(35)":U
       string( "Акт переоценки " ) at 50 format "x(20)":U v-price-doc_doc-num format "x(10)":U " от " v-price-doc_doc-date format "99/99/9999":U
       string( "Страница " + string( PAGE-NUMBER( AktStr ), ">>9":U ) ) at 120 format "x(13)":U skip
       v-single-line format "x(136)":U at 1
with width 160 down stream-io use-text.
define frame Akt-Cost
  sym1 v-b-code                 column-label "Код! "               format "x(10)":U
       ub.price-list.artic      column-label "Артикул! "           format "x(16)":U
       ub.goods.gds-name        column-label "Название товара! "   format "x(22)":U
       ub.price-list.doc-qnty   column-label "Количество! "        format "->>>>>9.<<":U
       v-gds-obj_last-price     column-label "Последняя уч.!цена"  format "->>>>>>>>9.99":U
       v-old-sum                column-label "Сумма учет.!цен"     format "->>>>>>>>>9.99":U
       ub.price-list.price-sale column-label "Новая прод.!цена"    format "->>>>>>>>9.99":U
       v-new-sum                column-label "Новая сумма!пр. цен" format "->>>>>>>>>9.99":U
       v-up-fact                column-label "Процент!разницы"     format "->>>>>>>9.9%":U         sym6
header cur-time-print( ) at 5 format "x(35)":U
       string( "Акт переоценки " ) at 50 format "x(20)":U v-price-doc_doc-num format "x(10)":U " от " v-price-doc_doc-date format "99/99/9999":U
       string( "Страница " + string( PAGE-NUMBER( AktStr ), ">>9":U ) ) at 120 format "x(13)":U skip
       v-single-line format "x(136)":U at 1
with width 160 down stream-io use-text.
do on error undo, return error :
if session :set-wait-state( "compiler" ) then.
define buffer buf_rep_currency for ub.currency.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-cntxt-host-code-obj
  ,output v-cntxt-host-name-obj
  )  .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
find first buf_rep_currency no-lock where
           buf_rep_currency.curr-code = base-code
           no-error .
  if available buf_rep_currency
    then do:
      assign
        base-type = buf_rep_currency.curr-abbr
        base-part = buf_rep_currency.part-abbr
      .
    end.
    else do:
      assign
        base-type = "б.в."
        base-part = ""
      .
    end.
run get-report-num  in parparentproc ( output g#report-num ).
run get-quest-print in parparentproc ( output g#quest-print ) .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-rb-is-base
  )  .
  assign v-print-rubl = ( v-rb-is-base = no ).
  find first ub.price-doc no-lock where recid( ub.price-doc ) = p-rec_id no-error.
  if not available ub.price-doc then do:
    message 'Порушена табличка "price-doc" (r-act-kg.p).' view-as alert-box error.
    return error.
  end.
  assign v-have-petrolium = no.
  for each ub.price-list no-lock where ub.price-list.doc-num = ub.price-doc.doc-num :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input ub.price-list.artic
  ,  input ub.price-list.prod-type
  ,  input ub.price-list.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
    if error-status :error or is-petrol <> yes or is-pieces <> no then do: next. end.
    assign v-have-petrolium = yes.
    leave.
  end.
  if v-have-petrolium <> yes then do:
    message "Нет топливных товаров (r-act-kg.p)." view-as alert-box error.
    return.
  end.
  assign v-price-doc_doc-num  = ub.price-doc.doc-num
         v-price-doc_doc-date = ub.price-doc.doc-date.
  find ub.clients no-lock where
       ub.clients.obj-code = ub.price-doc.obj-code and
       ub.clients.obj-type = ub.price-doc.obj-type.
  if not available ub.clients then do:
    message 'Порушена табличка "ub.clients" (r-act-kg.p).' view-as alert-box error.
    return error.
  end.
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue-cast_print':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output Log-Res1
    )  .
end.
  if ( price-doc.status_ = 'акт':U ) or Log-Res1 = yes then do:
    assign v-print-cost-price = ( if p-price-celection = 2 then yes else no ).
  end.
  find ub.trn-doc no-lock where ub.trn-doc.doc-code = ub.price-doc.doc-num no-error.
  assign v-single-line = fill( "-", 136 ).
output stream AktStr to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size 62 .
  find buf_clients no-lock where
       buf_clients.obj-type = 'орг':U and
       buf_clients.obj-code = ub.price-doc.host-code.
  put stream AktStr space( 50 ) buf_clients.obj-name format "x(70)":U skip( 2 ).
  os-delete log-file-name.
  run writelog in this-procedure ( input log-file-name, input 0, input "&Line" ).
  if ub.price-doc.status_ = 'акт':U then do:
    put stream AktStr space( 25 ) string( "А К Т  переоценки  по  остаткам  " +
      ( if available ub.trn-doc then string( "документу N " + ub.trn-doc.doc-code + "  по  " )
                                else " " ) + ub.clients.obj-name ) format "x(90)":U skip( 1 ).
    run writelog in this-procedure ( input log-file-name, input 1, input "Печать акта № " + string( ub.price-doc.doc-num )
                                   + " по док-ту № " + "  от  " + string( ub.price-doc.doc-date, "99.99.9999":U )
                                   + "  по  " + ub.clients.obj-name ).
  end.
  else do:
    put stream AktStr space( 20 ) string( "П Р И К А З   о  переоценке  товаров  " +
      ( if available ub.trn-doc then string( "по документу N " + ub.trn-doc.doc-code )
                                else " " ) + "  в  " + ub.clients.obj-name ) format "x(110)":U skip( 1 ).
    run writelog in this-procedure ( input log-file-name, input 1, input "Печать приказа № " + string( ub.price-doc.doc-num )
                                   + " по док-ту № " + "  от  " + string( ub.price-doc.doc-date, "99.99.9999":U )
                                   + "  в  " + ub.clients.obj-name ).
  end.
  put stream AktStr "Номер " ub.price-doc.doc-num "  от  " ub.price-doc.doc-date format "99.99.9999":U skip( 1 ).
  form header v-single-line format "x(136)":U at  1 skip
              "Продолжение - на следующей странице" at 30 skip
  with frame Bottomframe width 160 page-bottom no-labels no-box.
  view stream AktStr frame bottomframe.
  if ub.price-doc.status_ = 'акт':U then do:
    run writelog in this-procedure ( input log-file-name, input 1, input "Документ закрыт до факта" ).
    if v-print-cost-price = yes then do: form with frame Akt-Cost. end.
                                else do: form with frame Akt.      end.
    if p-sort-by-group = yes then do:
      run writelog in this-procedure ( input log-file-name, input 1, input "Включена сортировка по группам" ).
      for each ub.price-list no-lock where ub.price-list.doc-num = ub.price-doc.doc-num
        , each ub.goods      no-lock where ub.goods.artic        = ub.price-list.artic             and
                                           ub.goods.prod-type    = ub.price-list.prod-type         and
                                           ub.goods.prod-code    = ub.price-list.prod-code
      break by ub.goods.grp-name
            by ub.goods.artic    descending
      :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input ub.goods.artic
  ,  input ub.goods.prod-type
  ,  input ub.goods.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
        if error-status :error or is-petrol <> yes or is-pieces <> no then do: next. end.
        assign v-print-group = ( if first-of( ub.goods.grp-name ) then yes else no ).
  find first ub.bar-code no-lock where ub.bar-code.b-code = ub.price-list.b-code.
  assign v-code-is-main = ( ub.bar-code.unit-cli = ub.goods.unit-base ).
  if v-code-is-main <> yes then do:
    assign v-not-main-unit-cli      = ub.bar-code.unit-cli
           v-not-main-cli-base-rate = ub.bar-code.cli-base-rate
           v-not-main-b-code        = ub.bar-code.b-code.
  end.
  find first ub.gds-prt no-lock where ub.gds-prt.node-code = ub.bar-code.node-code.
  assign v-gds-prt-node_name = ( if ub.gds-prt.upper-code = ub.goods.prt-root then
                               ( if ub.bar-code.in-code = "":U then ub.goods.gds-name       else
                               ( ub.bar-code.in-code + "    ":U + ub.bar-code.part-code ) ) else
   "    ":U + ub.gds-prt.f-name ).
  run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Определили имя товара со шкалой ( "
                                 + dtm-char( v-gds-prt-node_name ) + " )" ).
  find first ub.gds-obj no-lock where
             ub.gds-obj.obj-type  = ub.price-list.obj-type  and
             ub.gds-obj.obj-code  = ub.price-list.obj-code  and
             ub.gds-obj.prod-type = ub.price-list.prod-type and
             ub.gds-obj.prod-code = ub.price-list.prod-code and
             ub.gds-obj.artic     = ub.price-list.artic     no-error.
  if available ub.gds-obj then do:
    assign v-gds-obj_last-price = ( if v-rb-is-base = yes then ub.gds-obj.last-base else ub.gds-obj.last-rubl ).
    if v-gds-obj_last-price = ? then do: assign v-gds-obj_last-price = 0. end.
    run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Нашли товар ( "
                                   + string( ub.price-list.artic ) + " )" + " на объекте ( "
                                   + ub.price-list.obj-type + string( ub.price-list.obj-code )
                                   + " ). Определили цену закупки ( " + dtm-char( string( v-gds-obj_last-price ) ) + " )" ).
  end.
  else do:
    assign v-gds-obj_last-price = 0.
    run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Не нашли товара ( "
                                   + string( ub.price-list.artic ) + " )" + " на объекте ( "
                                   + ub.price-list.obj-type + string( ub.price-list.obj-code )
                                   + " ). Назначили цену закупки ( 0 )" ).
  end.
  find first ub.gds-prt no-lock where ub.gds-prt.upper-code = ub.goods.prt-root.
  assign v-gds-prt-node_code = ub.gds-prt.node-code.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  ub.price-list.obj-type
  ,input  ub.price-list.obj-code
  ,input  ub.price-list.b-code
  ,input  0
  ,input  ub.price-list.fact-order
  ,output v-price-list_doc-num
  ,output v-price-list_price-sale_old
  ,output v-price-list_road-tax
  ,output v-price-list_excise
  )  .
  if v-price-list_price-sale_old = ? then do: assign v-price-list_price-sale_old = 0. end.
  find last ub.inv-line no-lock where
            ub.inv-line.obj-type   = ub.price-list.obj-type   and
            ub.inv-line.obj-code   = ub.price-list.obj-code   and
            ub.inv-line.prod-type  = ub.price-list.prod-type  and
            ub.inv-line.prod-code  = ub.price-list.prod-code  and
            ub.inv-line.artic      = ub.price-list.artic      and
            ub.inv-line.status_    = 'факт':U                  and
            ub.inv-line.fact-order < ub.price-list.fact-order no-error.
  if available ub.inv-line then do:
    assign v-price-list_doc-qnty = ub.inv-line.after-qnty.
  end.
  else do:
    assign v-price-list_doc-qnty = 0.
  end.
  if v-price-list_doc-qnty = ? then do: assign v-price-list_doc-qnty = 0. end.
  assign v-cli-base-rate = ub.price-list.doc-qnty / v-price-list_doc-qnty.
  if v-cli-base-rate = ? then do: assign v-cli-base-rate = 0. end.
  assign v-gds-obj_last-price = v-gds-obj_last-price * v-cli-base-rate.
  if v-gds-obj_last-price = ? then do: assign v-gds-obj_last-price = 0. end.
  assign v-price-list_price-sale_new = ub.price-list.price-sale * v-cli-base-rate.
  if v-price-list_price-sale_new = ? then do: assign v-price-list_price-sale_new = 0. end.
  run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Определили продажную цену из прайс-листа ( "
                                 + dtm-char( string( v-price-list_price-sale_old ) ) + " )" ).
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  ub.goods.gds-code
  ,input  ub.bar-code.node-code
  ,output v-price-list_b-code
  )  .
  find first ub.bar-code no-lock where ub.bar-code.b-code = v-price-list_b-code.
  assign j-counter = j-counter + 1.
  if ( j-counter modulo 10 ) = 0 and j-counter >= 10 then do:
    run waitfram-show in this-procedure ( input substitute( "Обработано строк : &1...", j-counter ) ).
  end.
        if v-code-is-main = yes then do:
          run writelog in this-procedure ( input log-file-name, input 2, input "Основной код. Собираем количества и суммы" ).
          assign v-price-list_price-sale_diff = v-price-list_price-sale_new - v-price-list_price-sale_old.
          assign v-total_doc-qnty        = v-total_doc-qnty        + v-price-list_doc-qnty
                 v-total_price-sale_old  = v-total_price-sale_old  + v-price-list_doc-qnty * v-price-list_price-sale_old
                 v-total_price-sale_new  = v-total_price-sale_new  + v-price-list_doc-qnty * v-price-list_price-sale_new
                 v-total_last-price-sale = v-total_last-price-sale + v-price-list_doc-qnty * v-gds-obj_last-price
                 v-total_price-sale_diff = v-total_price-sale_diff + v-price-list_doc-qnty * v-price-list_price-sale_diff.
          run print-line-fact in this-procedure.
          if last-of( ub.goods.grp-name ) and not last( ub.goods.grp-name ) then do:
            put stream AktStr v-single-line format "x(136)":U at 1.
          end.
        end.
      end.
    end.
    else do:
      run writelog in this-procedure ( input log-file-name, input 1, input "Сортировка по группам выключена" ).
      for each ub.price-list no-lock where ub.price-list.doc-num = ub.price-doc.doc-num
        , each ub.goods      no-lock where ub.goods.artic        = ub.price-list.artic     and
                                           ub.goods.prod-type    = ub.price-list.prod-type and
                                           ub.goods.prod-code    = ub.price-list.prod-code
      break by ub.goods.artic descending
      :
  find first ub.bar-code no-lock where ub.bar-code.b-code = ub.price-list.b-code.
  assign v-code-is-main = ( ub.bar-code.unit-cli = ub.goods.unit-base ).
  if v-code-is-main <> yes then do:
    assign v-not-main-unit-cli      = ub.bar-code.unit-cli
           v-not-main-cli-base-rate = ub.bar-code.cli-base-rate
           v-not-main-b-code        = ub.bar-code.b-code.
  end.
  find first ub.gds-prt no-lock where ub.gds-prt.node-code = ub.bar-code.node-code.
  assign v-gds-prt-node_name = ( if ub.gds-prt.upper-code = ub.goods.prt-root then
                               ( if ub.bar-code.in-code = "":U then ub.goods.gds-name       else
                               ( ub.bar-code.in-code + "    ":U + ub.bar-code.part-code ) ) else
   "    ":U + ub.gds-prt.f-name ).
  run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Определили имя товара со шкалой ( "
                                 + dtm-char( v-gds-prt-node_name ) + " )" ).
  find first ub.gds-obj no-lock where
             ub.gds-obj.obj-type  = ub.price-list.obj-type  and
             ub.gds-obj.obj-code  = ub.price-list.obj-code  and
             ub.gds-obj.prod-type = ub.price-list.prod-type and
             ub.gds-obj.prod-code = ub.price-list.prod-code and
             ub.gds-obj.artic     = ub.price-list.artic     no-error.
  if available ub.gds-obj then do:
    assign v-gds-obj_last-price = ( if v-rb-is-base = yes then ub.gds-obj.last-base else ub.gds-obj.last-rubl ).
    if v-gds-obj_last-price = ? then do: assign v-gds-obj_last-price = 0. end.
    run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Нашли товар ( "
                                   + string( ub.price-list.artic ) + " )" + " на объекте ( "
                                   + ub.price-list.obj-type + string( ub.price-list.obj-code )
                                   + " ). Определили цену закупки ( " + dtm-char( string( v-gds-obj_last-price ) ) + " )" ).
  end.
  else do:
    assign v-gds-obj_last-price = 0.
    run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Не нашли товара ( "
                                   + string( ub.price-list.artic ) + " )" + " на объекте ( "
                                   + ub.price-list.obj-type + string( ub.price-list.obj-code )
                                   + " ). Назначили цену закупки ( 0 )" ).
  end.
  find first ub.gds-prt no-lock where ub.gds-prt.upper-code = ub.goods.prt-root.
  assign v-gds-prt-node_code = ub.gds-prt.node-code.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  ub.price-list.obj-type
  ,input  ub.price-list.obj-code
  ,input  ub.price-list.b-code
  ,input  0
  ,input  ub.price-list.fact-order
  ,output v-price-list_doc-num
  ,output v-price-list_price-sale_old
  ,output v-price-list_road-tax
  ,output v-price-list_excise
  )  .
  if v-price-list_price-sale_old = ? then do: assign v-price-list_price-sale_old = 0. end.
  find last ub.inv-line no-lock where
            ub.inv-line.obj-type   = ub.price-list.obj-type   and
            ub.inv-line.obj-code   = ub.price-list.obj-code   and
            ub.inv-line.prod-type  = ub.price-list.prod-type  and
            ub.inv-line.prod-code  = ub.price-list.prod-code  and
            ub.inv-line.artic      = ub.price-list.artic      and
            ub.inv-line.status_    = 'факт':U                  and
            ub.inv-line.fact-order < ub.price-list.fact-order no-error.
  if available ub.inv-line then do:
    assign v-price-list_doc-qnty = ub.inv-line.after-qnty.
  end.
  else do:
    assign v-price-list_doc-qnty = 0.
  end.
  if v-price-list_doc-qnty = ? then do: assign v-price-list_doc-qnty = 0. end.
  assign v-cli-base-rate = ub.price-list.doc-qnty / v-price-list_doc-qnty.
  if v-cli-base-rate = ? then do: assign v-cli-base-rate = 0. end.
  assign v-gds-obj_last-price = v-gds-obj_last-price * v-cli-base-rate.
  if v-gds-obj_last-price = ? then do: assign v-gds-obj_last-price = 0. end.
  assign v-price-list_price-sale_new = ub.price-list.price-sale * v-cli-base-rate.
  if v-price-list_price-sale_new = ? then do: assign v-price-list_price-sale_new = 0. end.
  run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Определили продажную цену из прайс-листа ( "
                                 + dtm-char( string( v-price-list_price-sale_old ) ) + " )" ).
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  ub.goods.gds-code
  ,input  ub.bar-code.node-code
  ,output v-price-list_b-code
  )  .
  find first ub.bar-code no-lock where ub.bar-code.b-code = v-price-list_b-code.
  assign j-counter = j-counter + 1.
  if ( j-counter modulo 10 ) = 0 and j-counter >= 10 then do:
    run waitfram-show in this-procedure ( input substitute( "Обработано строк : &1...", j-counter ) ).
  end.
        if v-code-is-main = yes then do:
          run writelog in this-procedure ( input log-file-name, input 2, input "Основной код. Собираем количества и суммы" ).
          assign v-price-list_price-sale_diff = v-price-list_price-sale_new - v-price-list_price-sale_old.
          assign v-total_doc-qnty        = v-total_doc-qnty        + v-price-list_doc-qnty
                 v-total_price-sale_old  = v-total_price-sale_old  + v-price-list_doc-qnty * v-price-list_price-sale_old
                 v-total_price-sale_new  = v-total_price-sale_new  + v-price-list_doc-qnty * v-price-list_price-sale_new
                 v-total_last-price-sale = v-total_last-price-sale + v-price-list_doc-qnty * v-gds-obj_last-price
                 v-total_price-sale_diff = v-total_price-sale_diff + v-price-list_doc-qnty * v-price-list_price-sale_diff.
          run print-line-fact in this-procedure.
        end.
      end.
    end.
    put stream AktStr v-single-line format "x(136)":U skip.
    if v-print-cost-price = yes then do:
      display stream AktStr "Итого" format "x(8)":U @ ub.goods.gds-name
                            v-total_doc-qnty        @ ub.price-list.doc-qnty
                            v-total_last-price-sale @ v-old-sum
                            v-total_price-sale_new  @ v-new-sum
                  ( 100 * ( v-total_price-sale_new  / v-total_last-price-sale - 1 ) ) when round( v-total_last-price-sale, 2 ) <> 0
                                                    @ v-up-fact
      with frame Akt-Cost.
      underline stream AktStr ub.price-list.doc-qnty
                              v-old-sum
                              v-new-sum
                              v-up-fact
      with frame Akt-Cost.
    end.
    else do:
      display stream AktStr "Итого" format "x(8)":U @ ub.goods.gds-name
                            v-total_doc-qnty        @ ub.price-list.doc-qnty
                            v-total_price-sale_old  @ v-old-sum
                            v-total_price-sale_new  @ v-new-sum
                  ( 100 * ( v-total_price-sale_new  / v-total_price-sale_old - 1 ) ) when round( v-total_price-sale_old, 2 ) <> 0
                                                    @ v-up-fact
      with frame Akt.
      underline stream AktStr ub.price-list.doc-qnty
                              v-old-sum
                              v-new-sum
                              v-up-fact
      with frame Akt.
    end.
    hide stream AktStr frame Bottomframe.
    if v-print-cost-price <> yes then do:
      if v-rb-is-base = yes then do:
        assign propis = Total-Word(          absolute( v-total_price-sale_diff ), base-type, base-part )
               abbr   = base-type.
      end.                  else do:
        assign propis = Total-Word(          absolute( v-total_price-sale_diff ),
                                    Roubles( absolute( v-total_price-sale_diff ) ),
                                    Copecks( absolute( v-total_price-sale_diff ) ) )
               abbr   = " руб.".
      end.
      if line-counter( AktStr ) + 9 > page-size( AktStr ) then do: page stream AktStr. end.
      put stream AktStr skip space( 10 ) "Cумма переоценки: " format "x(18)":U
        v-total_price-sale_diff format "->>>>>>>>9.99":U
        space( 1 ) ( if v-rb-is-base = yes then "баз.вал" else "руб" ) format "x(3)":U " (" format "x(2)":U.
      if v-total_price-sale_diff < 0 then do: put stream AktStr "Минус " format "x(6)":U. end.
      put stream AktStr
        ( if trim( propis ) begins abbr then string( "0 " + propis + ")" ) else string( propis + ")" ) ) format "x(95)":U.
    end.
    put stream AktStr skip( 2 ) space( 10 ) "Зав. складом : " format "x(25)":U skip.
  end.
  else do:
    run writelog in this-procedure ( input log-file-name, input 1, input "Документ не закрыт до акта" ).
    if v-print-cost-price = yes then do: form with frame Prik-Cost. end.
                                else do: form with frame Prik.      end.
    if p-sort-by-group = yes then do:
      for each ub.price-list no-lock where ub.price-list.doc-num = ub.price-doc.doc-num
        , each ub.goods      no-lock where ub.goods.artic        = ub.price-list.artic     and
                                           ub.goods.prod-type    = ub.price-list.prod-type and
                                           ub.goods.prod-code    = ub.price-list.prod-code
      break by ub.goods.grp-name
            by ub.goods.artic    descending
            by ub.goods.gds-code descending
      :
  find first ub.bar-code no-lock where ub.bar-code.b-code = ub.price-list.b-code.
  assign v-code-is-main = ( ub.bar-code.unit-cli = ub.goods.unit-base ).
  if v-code-is-main <> yes then do:
    assign v-not-main-unit-cli      = ub.bar-code.unit-cli
           v-not-main-cli-base-rate = ub.bar-code.cli-base-rate
           v-not-main-b-code        = ub.bar-code.b-code.
  end.
  find first ub.gds-prt no-lock where ub.gds-prt.node-code = ub.bar-code.node-code.
  assign v-gds-prt-node_name = ( if ub.gds-prt.upper-code = ub.goods.prt-root then
                               ( if ub.bar-code.in-code = "":U then ub.goods.gds-name       else
                               ( ub.bar-code.in-code + "    ":U + ub.bar-code.part-code ) ) else
   "    ":U + ub.gds-prt.f-name ).
  run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Определили имя товара со шкалой ( "
                                 + dtm-char( v-gds-prt-node_name ) + " )" ).
  find first ub.gds-obj no-lock where
             ub.gds-obj.obj-type  = ub.price-list.obj-type  and
             ub.gds-obj.obj-code  = ub.price-list.obj-code  and
             ub.gds-obj.prod-type = ub.price-list.prod-type and
             ub.gds-obj.prod-code = ub.price-list.prod-code and
             ub.gds-obj.artic     = ub.price-list.artic     no-error.
  if available ub.gds-obj then do:
    assign v-gds-obj_last-price = ( if v-rb-is-base = yes then ub.gds-obj.last-base else ub.gds-obj.last-rubl ).
    if v-gds-obj_last-price = ? then do: assign v-gds-obj_last-price = 0. end.
    run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Нашли товар ( "
                                   + string( ub.price-list.artic ) + " )" + " на объекте ( "
                                   + ub.price-list.obj-type + string( ub.price-list.obj-code )
                                   + " ). Определили цену закупки ( " + dtm-char( string( v-gds-obj_last-price ) ) + " )" ).
  end.
  else do:
    assign v-gds-obj_last-price = 0.
    run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Не нашли товара ( "
                                   + string( ub.price-list.artic ) + " )" + " на объекте ( "
                                   + ub.price-list.obj-type + string( ub.price-list.obj-code )
                                   + " ). Назначили цену закупки ( 0 )" ).
  end.
  find first ub.gds-prt no-lock where ub.gds-prt.upper-code = ub.goods.prt-root.
  assign v-gds-prt-node_code = ub.gds-prt.node-code.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  ub.price-list.obj-type
  ,input  ub.price-list.obj-code
  ,input  ub.price-list.b-code
  ,input  0
  ,input  ub.price-list.fact-order
  ,output v-price-list_doc-num
  ,output v-price-list_price-sale_old
  ,output v-price-list_road-tax
  ,output v-price-list_excise
  )  .
  if v-price-list_price-sale_old = ? then do: assign v-price-list_price-sale_old = 0. end.
  find last ub.inv-line no-lock where
            ub.inv-line.obj-type   = ub.price-list.obj-type   and
            ub.inv-line.obj-code   = ub.price-list.obj-code   and
            ub.inv-line.prod-type  = ub.price-list.prod-type  and
            ub.inv-line.prod-code  = ub.price-list.prod-code  and
            ub.inv-line.artic      = ub.price-list.artic      and
            ub.inv-line.status_    = 'факт':U                  and
            ub.inv-line.fact-order < ub.price-list.fact-order no-error.
  if available ub.inv-line then do:
    assign v-price-list_doc-qnty = ub.inv-line.after-qnty.
  end.
  else do:
    assign v-price-list_doc-qnty = 0.
  end.
  if v-price-list_doc-qnty = ? then do: assign v-price-list_doc-qnty = 0. end.
  assign v-cli-base-rate = ub.price-list.doc-qnty / v-price-list_doc-qnty.
  if v-cli-base-rate = ? then do: assign v-cli-base-rate = 0. end.
  assign v-gds-obj_last-price = v-gds-obj_last-price * v-cli-base-rate.
  if v-gds-obj_last-price = ? then do: assign v-gds-obj_last-price = 0. end.
  assign v-price-list_price-sale_new = ub.price-list.price-sale * v-cli-base-rate.
  if v-price-list_price-sale_new = ? then do: assign v-price-list_price-sale_new = 0. end.
  run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Определили продажную цену из прайс-листа ( "
                                 + dtm-char( string( v-price-list_price-sale_old ) ) + " )" ).
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  ub.goods.gds-code
  ,input  ub.bar-code.node-code
  ,output v-price-list_b-code
  )  .
  find first ub.bar-code no-lock where ub.bar-code.b-code = v-price-list_b-code.
  assign j-counter = j-counter + 1.
  if ( j-counter modulo 10 ) = 0 and j-counter >= 10 then do:
    run waitfram-show in this-procedure ( input substitute( "Обработано строк : &1...", j-counter ) ).
  end.
        if v-code-is-main = yes then do: run print-line-no-fact in this-procedure. end.
      end.
    end.
    else do:
      for each ub.price-list no-lock where ub.price-list.doc-num = ub.price-doc.doc-num
        , each ub.goods      no-lock where ub.goods.artic        = ub.price-list.artic     and
                                           ub.goods.prod-type    = ub.price-list.prod-type and
                                           ub.goods.prod-code    = ub.price-list.prod-code
      break by ub.goods.artic    descending
            by ub.goods.gds-code descending
      :
  find first ub.bar-code no-lock where ub.bar-code.b-code = ub.price-list.b-code.
  assign v-code-is-main = ( ub.bar-code.unit-cli = ub.goods.unit-base ).
  if v-code-is-main <> yes then do:
    assign v-not-main-unit-cli      = ub.bar-code.unit-cli
           v-not-main-cli-base-rate = ub.bar-code.cli-base-rate
           v-not-main-b-code        = ub.bar-code.b-code.
  end.
  find first ub.gds-prt no-lock where ub.gds-prt.node-code = ub.bar-code.node-code.
  assign v-gds-prt-node_name = ( if ub.gds-prt.upper-code = ub.goods.prt-root then
                               ( if ub.bar-code.in-code = "":U then ub.goods.gds-name       else
                               ( ub.bar-code.in-code + "    ":U + ub.bar-code.part-code ) ) else
   "    ":U + ub.gds-prt.f-name ).
  run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Определили имя товара со шкалой ( "
                                 + dtm-char( v-gds-prt-node_name ) + " )" ).
  find first ub.gds-obj no-lock where
             ub.gds-obj.obj-type  = ub.price-list.obj-type  and
             ub.gds-obj.obj-code  = ub.price-list.obj-code  and
             ub.gds-obj.prod-type = ub.price-list.prod-type and
             ub.gds-obj.prod-code = ub.price-list.prod-code and
             ub.gds-obj.artic     = ub.price-list.artic     no-error.
  if available ub.gds-obj then do:
    assign v-gds-obj_last-price = ( if v-rb-is-base = yes then ub.gds-obj.last-base else ub.gds-obj.last-rubl ).
    if v-gds-obj_last-price = ? then do: assign v-gds-obj_last-price = 0. end.
    run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Нашли товар ( "
                                   + string( ub.price-list.artic ) + " )" + " на объекте ( "
                                   + ub.price-list.obj-type + string( ub.price-list.obj-code )
                                   + " ). Определили цену закупки ( " + dtm-char( string( v-gds-obj_last-price ) ) + " )" ).
  end.
  else do:
    assign v-gds-obj_last-price = 0.
    run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Не нашли товара ( "
                                   + string( ub.price-list.artic ) + " )" + " на объекте ( "
                                   + ub.price-list.obj-type + string( ub.price-list.obj-code )
                                   + " ). Назначили цену закупки ( 0 )" ).
  end.
  find first ub.gds-prt no-lock where ub.gds-prt.upper-code = ub.goods.prt-root.
  assign v-gds-prt-node_code = ub.gds-prt.node-code.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  ub.price-list.obj-type
  ,input  ub.price-list.obj-code
  ,input  ub.price-list.b-code
  ,input  0
  ,input  ub.price-list.fact-order
  ,output v-price-list_doc-num
  ,output v-price-list_price-sale_old
  ,output v-price-list_road-tax
  ,output v-price-list_excise
  )  .
  if v-price-list_price-sale_old = ? then do: assign v-price-list_price-sale_old = 0. end.
  find last ub.inv-line no-lock where
            ub.inv-line.obj-type   = ub.price-list.obj-type   and
            ub.inv-line.obj-code   = ub.price-list.obj-code   and
            ub.inv-line.prod-type  = ub.price-list.prod-type  and
            ub.inv-line.prod-code  = ub.price-list.prod-code  and
            ub.inv-line.artic      = ub.price-list.artic      and
            ub.inv-line.status_    = 'факт':U                  and
            ub.inv-line.fact-order < ub.price-list.fact-order no-error.
  if available ub.inv-line then do:
    assign v-price-list_doc-qnty = ub.inv-line.after-qnty.
  end.
  else do:
    assign v-price-list_doc-qnty = 0.
  end.
  if v-price-list_doc-qnty = ? then do: assign v-price-list_doc-qnty = 0. end.
  assign v-cli-base-rate = ub.price-list.doc-qnty / v-price-list_doc-qnty.
  if v-cli-base-rate = ? then do: assign v-cli-base-rate = 0. end.
  assign v-gds-obj_last-price = v-gds-obj_last-price * v-cli-base-rate.
  if v-gds-obj_last-price = ? then do: assign v-gds-obj_last-price = 0. end.
  assign v-price-list_price-sale_new = ub.price-list.price-sale * v-cli-base-rate.
  if v-price-list_price-sale_new = ? then do: assign v-price-list_price-sale_new = 0. end.
  run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Определили продажную цену из прайс-листа ( "
                                 + dtm-char( string( v-price-list_price-sale_old ) ) + " )" ).
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  ub.goods.gds-code
  ,input  ub.bar-code.node-code
  ,output v-price-list_b-code
  )  .
  find first ub.bar-code no-lock where ub.bar-code.b-code = v-price-list_b-code.
  assign j-counter = j-counter + 1.
  if ( j-counter modulo 10 ) = 0 and j-counter >= 10 then do:
    run waitfram-show in this-procedure ( input substitute( "Обработано строк : &1...", j-counter ) ).
  end.
        if v-code-is-main = yes then do: run print-line-no-fact in this-procedure. end.
      end.
    end.
    hide stream AktStr frame Bottomframe.
    if line-counter( AktStr ) + 6 > page-size( AktStr ) then do: page stream AktStr. end.
    put stream AktStr v-single-line format "x(136)":U skip( 2 )
      space( 10 ) "Всего  " v-good-line-counter format ">>>>9":U " наименований." format "x(15)":U skip( 2 )
      space( 10 ) "Директор :  " format "x(60)":U "Главный бухгалтер :  " format "x(70)":U skip.
  end.
  output stream AktStr close.
if session :set-wait-state( "" ) then.
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 4 >= 8 then 2 else 0), 0, 0,
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
end.
procedure print-line-fact :
  define variable v-out-log-string as character no-undo.
  do on error undo, return error :
    run writelog in this-procedure ( input log-file-name, input 1, input "Вызов программы печати строки АКТА" ).
    if not can-find( first ub.gds-prt where ub.gds-prt.upper-code = v-gds-prt-node_code ) then do:
      run writelog in this-procedure ( input log-file-name, input 2, "Пустая шкала" ).
      if ( ub.price-list.doc-qnty <> 0 ) or ( p-print-null-qnty = yes ) then do:
        assign v-out-log-string = "Количество по документу > 0 ( = " + string( ub.price-list.doc-qnty ) + " ) " +
                                  "или включена печать нулевого количества ( " + string( p-print-null-qnty ) + " )".
        run writelog in this-procedure ( input log-file-name, input 3, input v-out-log-string ).
        if v-print-cost-price = yes then do:
          run writelog in this-procedure ( input log-file-name, input 4, input "Включена печать по учетным ценам" ).
          if p-sort-by-group = yes then do:
  if v-shift-down = yes then do:
    down stream AktStr 1 with frame Akt-Cost .
    assign v-shift-down = no.
  end.
  if v-print-group = yes then do:
    run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Печать имени группы ( " + ub.goods.grp-name + " )" ).
    put stream AktStr ub.goods.grp-name format "x(136)":U at 1.
  end.
          end.
          display stream AktStr
                  sym1  trim( string( ub.bar-code.b-code ) )                                 @ v-b-code
                          ub.price-list.artic
                          v-gds-prt-node_name                                                @ ub.goods.gds-name
                          v-price-list_doc-qnty       when v-price-list_doc-qnty <> ?        @ ub.price-list.doc-qnty
                          v-price-list_price-sale_new                                        @ ub.price-list.price-sale
                        ( v-price-list_doc-qnty       * v-price-list_price-sale_new )        @ v-new-sum
                          v-gds-obj_last-price
                        ( v-price-list_doc-qnty       * v-gds-obj_last-price        )        @ v-old-sum
                  100 * ( v-price-list_price-sale_new / v-gds-obj_last-price - 1    )
                                                      when v-gds-obj_last-price <> 0         @ v-up-fact sym6
          with frame Akt-Cost.
          down stream AktStr 1 with frame Akt-Cost.
  if hvrdtax( recid( ub.goods ) ) = yes then do:
    run tax-name in this-procedure ( input 'rdt':U, output v-taxname ).
    assign v-tax     = ub.price-list.road-tax * ub.price-list.doc-qnty
           v-tax-sum = v-tax-sum + v-tax.
    run writelog in this-procedure ( input log-file-name, input 5, input "r-act-kg.i Товар с третьим налогом ( "
                                   + dtm-char( v-taxname ) + " ), определили значение ( " + dtm-char( string( v-tax ) )
                                   + " ) и сумму всего ( " + dtm-char( string( v-tax-sum ) ) + " )" ).
    for each ub.parts where
             ub.parts.obj-type  = ub.price-list.obj-type  and
             ub.parts.obj-code  = ub.price-list.obj-code  and
             ub.parts.artic     = ub.price-list.artic     and
             ub.parts.prod-type = ub.price-list.prod-type and
             ub.parts.prod-code = ub.price-list.prod-code and
             ub.parts.out-code  = ub.price-list.doc-num
    break by ub.parts.road-tax-rubl
    :
      assign v-tax-parts-qnty = v-tax-parts-qnty + ub.parts.fact-qnty / ub.parts.cli-base-rate.
      if last-of( ub.parts.road-tax-rubl ) then do:
        assign v-parts_road-tax-rubl = ub.parts.road-tax-rubl * ub.parts.cli-base-rate.
        display stream AktStr "     В том числе"                            @ ub.price-list.artic
                              v-taxname                                     @ ub.goods.gds-name
                              v-tax-parts-qnty   when v-tax-parts-qnty <> ? @ ub.price-list.doc-qnty
                              v-parts_road-tax-rubl                         @ ub.price-list.price-sale
                              ub.parts.fact-qnty * ub.parts.road-tax-rubl   @ v-new-sum                sym1 sym6
        with frame Akt-Cost .
        down stream AktStr 1 with frame Akt-Cost .
        assign v-line-counter   = v-line-counter + 1
               v-tax-parts-qnty = 0.
      end.
    end.
  end.
        end.
        else do:
          run writelog in this-procedure ( input log-file-name, input 4, input "Печать по учетным ценам выключена" ).
          if p-sort-by-group = yes then do:
  if v-shift-down = yes then do:
    down stream AktStr 1 with frame  Akt .
    assign v-shift-down = no.
  end.
  if v-print-group = yes then do:
    run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Печать имени группы ( " + ub.goods.grp-name + " )" ).
    put stream AktStr ub.goods.grp-name format "x(136)":U at 1.
  end.
          end.
          display stream AktStr
                  sym1  trim( string( ub.bar-code.b-code ) )                                 @ v-b-code
                          ub.price-list.artic
                          v-gds-prt-node_name                                                @ ub.goods.gds-name
                          v-price-list_doc-qnty       when v-price-list_doc-qnty <> ?        @ ub.price-list.doc-qnty
                          v-price-list_price-sale_old
                        ( v-price-list_doc-qnty   * v-price-list_price-sale_old      )       @ v-old-sum
                          v-price-list_price-sale_new                                        @ ub.price-list.price-sale
                        ( v-price-list_doc-qnty   * v-price-list_price-sale_new      )       @ v-new-sum
                  100 * ( v-price-list_price-sale_diff / v-price-list_price-sale_old )
                                                      when v-price-list_price-sale_old <> 0  @ v-up-fact sym6
          with frame Akt.
          down stream AktStr 1 with frame Akt.
  if hvrdtax( recid( ub.goods ) ) = yes then do:
    run tax-name in this-procedure ( input 'rdt':U, output v-taxname ).
    assign v-tax     = ub.price-list.road-tax * ub.price-list.doc-qnty
           v-tax-sum = v-tax-sum + v-tax.
    run writelog in this-procedure ( input log-file-name, input 5, input "r-act-kg.i Товар с третьим налогом ( "
                                   + dtm-char( v-taxname ) + " ), определили значение ( " + dtm-char( string( v-tax ) )
                                   + " ) и сумму всего ( " + dtm-char( string( v-tax-sum ) ) + " )" ).
    for each ub.parts where
             ub.parts.obj-type  = ub.price-list.obj-type  and
             ub.parts.obj-code  = ub.price-list.obj-code  and
             ub.parts.artic     = ub.price-list.artic     and
             ub.parts.prod-type = ub.price-list.prod-type and
             ub.parts.prod-code = ub.price-list.prod-code and
             ub.parts.out-code  = ub.price-list.doc-num
    break by ub.parts.road-tax-rubl
    :
      assign v-tax-parts-qnty = v-tax-parts-qnty + ub.parts.fact-qnty / ub.parts.cli-base-rate.
      if last-of( ub.parts.road-tax-rubl ) then do:
        assign v-parts_road-tax-rubl = ub.parts.road-tax-rubl * ub.parts.cli-base-rate.
        display stream AktStr "     В том числе"                            @ ub.price-list.artic
                              v-taxname                                     @ ub.goods.gds-name
                              v-tax-parts-qnty   when v-tax-parts-qnty <> ? @ ub.price-list.doc-qnty
                              v-parts_road-tax-rubl                         @ ub.price-list.price-sale
                              ub.parts.fact-qnty * ub.parts.road-tax-rubl   @ v-new-sum                sym1 sym6
        with frame  Akt .
        down stream AktStr 1 with frame  Akt .
        assign v-line-counter   = v-line-counter + 1
               v-tax-parts-qnty = 0.
      end.
    end.
  end.
        end.
      end.
    end.
    else do:
      run writelog in this-procedure ( input log-file-name, input 2, input "Не пустая шкала" ).
      if ( price-list.doc-qnty <> 0 ) or ( p-print-null-qnty ) then do:
        assign v-out-log-string = "Количество по документу > 0 ( = " + string( ub.price-list.doc-qnty ) + " ) " +
                                  "или включена печать нулевого количества ( " + string( p-print-null-qnty ) + " )".
        run writelog in this-procedure ( input log-file-name, input 3, input v-out-log-string ).
        if v-print-cost-price = yes then do:
          run writelog in this-procedure ( input log-file-name, input 4, input "Включена печать по учетным ценам" ).
          display stream AktStr
                  sym1  trim( string( ub.bar-code.b-code ) )                                 @ v-b-code
                          ub.price-list.artic
                          v-gds-prt-node_name                                                @ ub.goods.gds-name
                          v-price-list_doc-qnty       when v-price-list_doc-qnty <> ?        @ ub.price-list.doc-qnty
                          v-gds-obj_last-price
                        ( v-price-list_doc-qnty       * v-gds-obj_last-price        )        @ v-old-sum
                          v-price-list_price-sale_new                                        @ ub.price-list.price-sale
                        ( v-price-list_doc-qnty       * v-price-list_price-sale_new )        @ v-new-sum
                  100 * ( v-price-list_price-sale_new / v-gds-obj_last-price - 1    )
                                                      when v-gds-obj_last-price <> 0         @ v-up-fact sym6
          with frame Akt-Cost.
          down stream AktStr 1 with frame Akt-Cost.
  if hvrdtax( recid( ub.goods ) ) = yes then do:
    run tax-name in this-procedure ( input 'rdt':U, output v-taxname ).
    assign v-tax     = ub.price-list.road-tax * ub.price-list.doc-qnty
           v-tax-sum = v-tax-sum + v-tax.
    run writelog in this-procedure ( input log-file-name, input 5, input "r-act-kg.i Товар с третьим налогом ( "
                                   + dtm-char( v-taxname ) + " ), определили значение ( " + dtm-char( string( v-tax ) )
                                   + " ) и сумму всего ( " + dtm-char( string( v-tax-sum ) ) + " )" ).
    for each ub.parts where
             ub.parts.obj-type  = ub.price-list.obj-type  and
             ub.parts.obj-code  = ub.price-list.obj-code  and
             ub.parts.artic     = ub.price-list.artic     and
             ub.parts.prod-type = ub.price-list.prod-type and
             ub.parts.prod-code = ub.price-list.prod-code and
             ub.parts.out-code  = ub.price-list.doc-num
    break by ub.parts.road-tax-rubl
    :
      assign v-tax-parts-qnty = v-tax-parts-qnty + ub.parts.fact-qnty / ub.parts.cli-base-rate.
      if last-of( ub.parts.road-tax-rubl ) then do:
        assign v-parts_road-tax-rubl = ub.parts.road-tax-rubl * ub.parts.cli-base-rate.
        display stream AktStr "     В том числе"                            @ ub.price-list.artic
                              v-taxname                                     @ ub.goods.gds-name
                              v-tax-parts-qnty   when v-tax-parts-qnty <> ? @ ub.price-list.doc-qnty
                              v-parts_road-tax-rubl                         @ ub.price-list.price-sale
                              ub.parts.fact-qnty * ub.parts.road-tax-rubl   @ v-new-sum                sym1 sym6
        with frame Akt-Cost .
        down stream AktStr 1 with frame Akt-Cost .
        assign v-line-counter   = v-line-counter + 1
               v-tax-parts-qnty = 0.
      end.
    end.
  end.
        end.
        else do:
          run writelog in this-procedure ( input log-file-name, input 4, input "Печать по учетным ценам выключена" ).
          display stream AktStr
                  sym1  trim( string( ub.bar-code.b-code ) )                                 @ v-b-code
                          ub.price-list.artic
                          v-gds-prt-node_name                                                @ ub.goods.gds-name
                          v-price-list_doc-qnty       when v-price-list_doc-qnty <> ?        @ ub.price-list.doc-qnty
                          v-price-list_price-sale_old
                        ( v-price-list_doc-qnty        * v-price-list_price-sale_old )       @ v-old-sum
                          v-price-list_price-sale_new                                        @ ub.price-list.price-sale
                        ( v-price-list_doc-qnty        * v-price-list_price-sale_new )       @ v-new-sum
                  100 * ( v-price-list_price-sale_diff / v-price-list_price-sale_old )
                                                      when v-price-list_price-sale_old <> 0  @ v-up-fact sym6
          with frame Akt.
          down stream AktStr 1 with frame Akt.
  if hvrdtax( recid( ub.goods ) ) = yes then do:
    run tax-name in this-procedure ( input 'rdt':U, output v-taxname ).
    assign v-tax     = ub.price-list.road-tax * ub.price-list.doc-qnty
           v-tax-sum = v-tax-sum + v-tax.
    run writelog in this-procedure ( input log-file-name, input 5, input "r-act-kg.i Товар с третьим налогом ( "
                                   + dtm-char( v-taxname ) + " ), определили значение ( " + dtm-char( string( v-tax ) )
                                   + " ) и сумму всего ( " + dtm-char( string( v-tax-sum ) ) + " )" ).
    for each ub.parts where
             ub.parts.obj-type  = ub.price-list.obj-type  and
             ub.parts.obj-code  = ub.price-list.obj-code  and
             ub.parts.artic     = ub.price-list.artic     and
             ub.parts.prod-type = ub.price-list.prod-type and
             ub.parts.prod-code = ub.price-list.prod-code and
             ub.parts.out-code  = ub.price-list.doc-num
    break by ub.parts.road-tax-rubl
    :
      assign v-tax-parts-qnty = v-tax-parts-qnty + ub.parts.fact-qnty / ub.parts.cli-base-rate.
      if last-of( ub.parts.road-tax-rubl ) then do:
        assign v-parts_road-tax-rubl = ub.parts.road-tax-rubl * ub.parts.cli-base-rate.
        display stream AktStr "     В том числе"                            @ ub.price-list.artic
                              v-taxname                                     @ ub.goods.gds-name
                              v-tax-parts-qnty   when v-tax-parts-qnty <> ? @ ub.price-list.doc-qnty
                              v-parts_road-tax-rubl                         @ ub.price-list.price-sale
                              ub.parts.fact-qnty * ub.parts.road-tax-rubl   @ v-new-sum                sym1 sym6
        with frame  Akt .
        down stream AktStr 1 with frame  Akt .
        assign v-line-counter   = v-line-counter + 1
               v-tax-parts-qnty = 0.
      end.
    end.
  end.
        end.
      end.
    end.
  end.
end procedure.
procedure print-line-no-fact :
  do on error undo, return error :
    run writelog in this-procedure ( input log-file-name, input 1, input "Вызов программы печати строки НЕ АКТА" ).
    if not can-find( first ub.gds-prt where ub.gds-prt.upper-code = v-gds-prt-node_code ) then do:
      if v-print-cost-price = yes then do:
        if p-sort-by-group = yes then do:
  if v-shift-down = yes then do:
    down stream AktStr 1 with frame Akt-Cost .
    assign v-shift-down = no.
  end.
  if v-print-group = yes then do:
    run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Печать имени группы ( " + ub.goods.grp-name + " )" ).
    put stream AktStr ub.goods.grp-name format "x(136)":U at 1.
  end.
        end.
        assign v-line-counter      = v-line-counter      + 1
               v-good-line-counter = v-good-line-counter + 1.
        display stream AktStr
                sym1 trim( string( ub.bar-code.b-code ) )                                 @ v-b-code
                     ub.price-list.artic
                sym4 v-gds-prt-node_name                                                  @ ub.goods.gds-name
                sym5 v-price-list_doc-qnty       when v-price-list_doc-qnty <> ?          @ ub.price-list.doc-qnty
                     v-gds-obj_last-price
                     v-price-list_price-sale_new                                          @ ub.price-list.price-sale
                     ( 100 * ( v-price-list_price-sale_new / v-gds-obj_last-price - 1 ) )
                                                 when v-gds-obj_last-price <> 0           @ v-up-fact sym6
        with frame Prik-Cost.
        down stream AktStr 1 with frame Prik-Cost.
  if hvrdtax( recid( ub.goods ) ) = yes then do:
    run tax-name in this-procedure ( input 'rdt':U, output v-taxname ).
    assign v-tax     = ub.price-list.road-tax * ub.price-list.doc-qnty
           v-tax-sum = v-tax-sum + v-tax.
    run writelog in this-procedure ( input log-file-name, input 5, input "r-act-kg.i Товар с третьим налогом ( "
                                   + dtm-char( v-taxname ) + " ), определили значение ( " + dtm-char( string( v-tax ) )
                                   + " ) и сумму всего ( " + dtm-char( string( v-tax-sum ) ) + " )" ).
    display stream AktStr "     В том числе"                                      @ ub.price-list.artic
                          v-taxname                                               @ ub.goods.gds-name
                          v-price-list_doc-qnty  when v-price-list_doc-qnty <> ?  @ ub.price-list.doc-qnty
                          ub.price-list.road-tax                                  @ ub.price-list.price-sale sym1 sym6
    with frame Prik-Cost .
    down stream AktStr 1 with frame Prik-Cost .
    assign v-line-counter = v-line-counter + 1.
  end.
      end.
      else do:
        if p-sort-by-group = yes then do:
  if v-shift-down = yes then do:
    down stream AktStr 1 with frame  Akt .
    assign v-shift-down = no.
  end.
  if v-print-group = yes then do:
    run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Печать имени группы ( " + ub.goods.grp-name + " )" ).
    put stream AktStr ub.goods.grp-name format "x(136)":U at 1.
  end.
        end.
        assign v-line-counter      = v-line-counter      + 1
               v-good-line-counter = v-good-line-counter + 1.
        display stream AktStr
                sym1    v-good-line-counter
                sym2    trim( string( ub.bar-code.b-code ) )                                 @ v-b-code
                sym3    ub.price-list.artic
                sym4    v-gds-prt-node_name                                                  @ ub.goods.gds-name
                sym5    v-price-list_doc-qnty       when v-price-list_doc-qnty <> ?          @ ub.price-list.doc-qnty
                        v-price-list_price-sale_old
                        v-price-list_price-sale_new                                          @ ub.price-list.price-sale
                100 * ( v-price-list_price-sale_new / v-price-list_price-sale_old - 1 )
                                                    when v-price-list_price-sale_old <> 0    @ v-up-fact sym6
        with frame Prik.
        down stream AktStr 1 with frame Prik.
  if hvrdtax( recid( ub.goods ) ) = yes then do:
    run tax-name in this-procedure ( input 'rdt':U, output v-taxname ).
    assign v-tax     = ub.price-list.road-tax * ub.price-list.doc-qnty
           v-tax-sum = v-tax-sum + v-tax.
    run writelog in this-procedure ( input log-file-name, input 5, input "r-act-kg.i Товар с третьим налогом ( "
                                   + dtm-char( v-taxname ) + " ), определили значение ( " + dtm-char( string( v-tax ) )
                                   + " ) и сумму всего ( " + dtm-char( string( v-tax-sum ) ) + " )" ).
    display stream AktStr "     В том числе"                                      @ ub.price-list.artic
                          v-taxname                                               @ ub.goods.gds-name
                          v-price-list_doc-qnty  when v-price-list_doc-qnty <> ?  @ ub.price-list.doc-qnty
                          ub.price-list.road-tax                                  @ ub.price-list.price-sale sym1 sym6
    with frame  Prik .
    down stream AktStr 1 with frame  Prik .
    assign v-line-counter = v-line-counter + 1.
  end.
      end.
    end.
    else do:
      if v-print-cost-price = yes then do:
        if p-sort-by-group = yes then do:
  if v-shift-down = yes then do:
    down stream AktStr 1 with frame Akt-Cost .
    assign v-shift-down = no.
  end.
  if v-print-group = yes then do:
    run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Печать имени группы ( " + ub.goods.grp-name + " )" ).
    put stream AktStr ub.goods.grp-name format "x(136)":U at 1.
  end.
        end.
        assign v-line-counter      = v-line-counter      + 1
               v-good-line-counter = v-good-line-counter + 1.
        display stream AktStr
                sym1    trim( string( ub.bar-code.b-code ) )                                 @ v-b-code
                        ub.price-list.artic
                sym4    v-gds-prt-node_name                                                  @ ub.goods.gds-name
                sym5    v-price-list_doc-qnty       when v-price-list_doc-qnty <> ?          @ ub.price-list.doc-qnty
                        v-gds-obj_last-price
                        v-price-list_price-sale_new                                          @ ub.price-list.price-sale
                100 * ( v-price-list_price-sale_new / v-gds-obj_last-price - 1 )
                                                    when v-gds-obj_last-price <> 0           @ v-up-fact sym6
        with frame Prik-Cost.
        down stream AktStr 1 with frame Prik-Cost.
  if hvrdtax( recid( ub.goods ) ) = yes then do:
    run tax-name in this-procedure ( input 'rdt':U, output v-taxname ).
    assign v-tax     = ub.price-list.road-tax * ub.price-list.doc-qnty
           v-tax-sum = v-tax-sum + v-tax.
    run writelog in this-procedure ( input log-file-name, input 5, input "r-act-kg.i Товар с третьим налогом ( "
                                   + dtm-char( v-taxname ) + " ), определили значение ( " + dtm-char( string( v-tax ) )
                                   + " ) и сумму всего ( " + dtm-char( string( v-tax-sum ) ) + " )" ).
    display stream AktStr "     В том числе"                                      @ ub.price-list.artic
                          v-taxname                                               @ ub.goods.gds-name
                          v-price-list_doc-qnty  when v-price-list_doc-qnty <> ?  @ ub.price-list.doc-qnty
                          ub.price-list.road-tax                                  @ ub.price-list.price-sale sym1 sym6
    with frame Prik-Cost .
    down stream AktStr 1 with frame Prik-Cost .
    assign v-line-counter = v-line-counter + 1.
  end.
      end.
      else do:
        if p-sort-by-group = yes then do:
  if v-shift-down = yes then do:
    down stream AktStr 1 with frame  Akt .
    assign v-shift-down = no.
  end.
  if v-print-group = yes then do:
    run writelog in this-procedure ( input log-file-name, input 4, input "r-act-kg.i Печать имени группы ( " + ub.goods.grp-name + " )" ).
    put stream AktStr ub.goods.grp-name format "x(136)":U at 1.
  end.
        end.
        assign v-line-counter      = v-line-counter      + 1
               v-good-line-counter = v-good-line-counter + 1.
        display stream AktStr
                sym1    v-good-line-counter
                sym2    trim( string( ub.bar-code.b-code ) )                                 @ v-b-code
                sym3    ub.price-list.artic
                sym4    v-gds-prt-node_name                                                  @ ub.goods.gds-name
                sym5    v-price-list_doc-qnty       when v-price-list_doc-qnty <> ?          @ ub.price-list.doc-qnty
                        v-price-list_price-sale_old
                        v-price-list_price-sale_new                                          @ ub.price-list.price-sale
                100 * ( v-price-list_price-sale_new / v-price-list_price-sale_old - 1 )
                                                    when v-price-list_price-sale_old <> 0    @ v-up-fact sym6
        with frame Prik.
        down stream AktStr 1 with frame Prik.
  if hvrdtax( recid( ub.goods ) ) = yes then do:
    run tax-name in this-procedure ( input 'rdt':U, output v-taxname ).
    assign v-tax     = ub.price-list.road-tax * ub.price-list.doc-qnty
           v-tax-sum = v-tax-sum + v-tax.
    run writelog in this-procedure ( input log-file-name, input 5, input "r-act-kg.i Товар с третьим налогом ( "
                                   + dtm-char( v-taxname ) + " ), определили значение ( " + dtm-char( string( v-tax ) )
                                   + " ) и сумму всего ( " + dtm-char( string( v-tax-sum ) ) + " )" ).
    display stream AktStr "     В том числе"                                      @ ub.price-list.artic
                          v-taxname                                               @ ub.goods.gds-name
                          v-price-list_doc-qnty  when v-price-list_doc-qnty <> ?  @ ub.price-list.doc-qnty
                          ub.price-list.road-tax                                  @ ub.price-list.price-sale sym1 sym6
    with frame  Prik .
    down stream AktStr 1 with frame  Prik .
    assign v-line-counter = v-line-counter + 1.
  end.
      end.
    end.
  end.
end procedure.
