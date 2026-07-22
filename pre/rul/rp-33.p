block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer   no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-pos-type-for-discnt as character no-undo .
define input parameter log-file-name as character no-undo .
define input parameter p-dr-flddf as handle no-undo .
define input parameter p-bh as handle no-undo extent 6.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Вспомогательный файл к кодексам правил 15-16-17".
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
define  variable garbcoll_ii as integer no-undo .
define  temp-table temp-gc no-undo
field ii as integer
field obj-r as handle
field cn as character
index pi is unique primary
ii
index icn
cn.
procedure garbcoll_create-gc-entry :
define input parameter p-cn as character no-undo .
define input parameter p-obj-r as handle no-undo .
  do
  on error undo, return error
  :
    create temp-gc.
    assign
    temp-gc.ii = garbcoll_ii
    garbcoll_ii = garbcoll_ii + 1
    temp-gc.cn = p-cn
    temp-gc.obj-r = p-obj-r
    .
  end.
end procedure.
procedure garbcoll_clear :
  do
  on error undo, return error
  :
    for each temp-gc:
      delete object temp-gc.obj-r.
      delete temp-gc.
    end.
  end.
end procedure.
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
procedure library-cls_get-handle :
define input parameter p-library-name as character no-undo .
define output parameter p-library-handle as handle no-undo .
  do
  on error undo, return error
  :
    CASE p-library-name:
      when "library" then do:
        if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end.
        p-library-handle = g#library.
      end.
      when "library2" then do:
        if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end.
        p-library-handle = g#library2.
      end.
    end case.
  end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function loc-weekday returns integer ( input p-date as date):
Case weekday(p-date):
  when 1 then return 7.
  otherwise return  weekday(p-date) - 1.
end case.
end function.
FUNCTION DIS-TIME-RULE_-1 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
return yes.
end function.
FUNCTION DIS-TIME-RULE_-50001 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
return yes.
end function.
FUNCTION DIS-TIME-RULE_00000 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
return yes.
end function.
FUNCTION DIS-TIME-RULE_00001 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
return yes.
end function.
FUNCTION DIS-TIME-RULE_00002 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
          buf_dis-time-rule.time-rule-num = p-time-rule-num no-error.
if available buf_dis-time-rule
and buf_dis-time-rule.sts = integer ('0':U) then do:
  if buf_dis-time-rule.time-from <= p-time
  and buf_dis-time-rule.time-to >= p-time then do:
    return yes.
  end.
end.
return no.
end function.
FUNCTION DIS-TIME-RULE_00003 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
          buf_dis-time-rule.time-rule-num = p-time-rule-num no-error.
if available buf_dis-time-rule
and buf_dis-time-rule.sts = integer ('0':U) then do:
  if buf_dis-time-rule.date-from <= p-date
  and buf_dis-time-rule.date-to >= p-date then do:
    return yes.
  end.
end.
return no.
end function.
FUNCTION DIS-TIME-RULE_00004 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
          buf_dis-time-rule.time-rule-num = p-time-rule-num no-error.
if available buf_dis-time-rule
and buf_dis-time-rule.sts = integer ('0':U) then do:
  if buffer buf_dis-time-rule:buffer-field("week-day-" + string(loc-weekday(p-date) )):buffer-value = yes
  then do:
    return yes.
  end.
end.
return no.
end function.
FUNCTION DIS-TIME-RULE_00005 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
          buf_dis-time-rule.time-rule-num = p-time-rule-num no-error.
if available buf_dis-time-rule
and buf_dis-time-rule.sts = integer ('0':U) then do:
  if buffer buf_dis-time-rule:buffer-field("week-day-" + string(loc-weekday(p-date) )):buffer-value = yes
  then do:
    return yes.
  end.
end.
return no.
end function.
FUNCTION DIS-TIME-RULE_00006 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
          buf_dis-time-rule.time-rule-num = p-time-rule-num no-error.
if available buf_dis-time-rule
and buf_dis-time-rule.sts = integer ('0':U) then do:
  if buf_dis-time-rule.month-day = day(p-date) then do:
    return yes.
  end.
  return no.
end.
else do:
  return no.
end.
end function.
FUNCTION DIS-TIME-RULE_00007 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
          buf_dis-time-rule.time-rule-num = p-time-rule-num no-error.
if available buf_dis-time-rule
and buf_dis-time-rule.sts = integer ('0':U) then do:
  if buf_dis-time-rule.date-from <= p-date
  and buf_dis-time-rule.date-to >= p-date
  and buf_dis-time-rule.time-from <= p-time
  and buf_dis-time-rule.time-to >= p-time then do:
    return yes.
  end.
end.
return no.
end function.
FUNCTION DIS-TIME-RULE_00008 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
          buf_dis-time-rule.time-rule-num = p-time-rule-num no-error.
if available buf_dis-time-rule
and buf_dis-time-rule.sts = integer ('0':U) then do:
  if buf_dis-time-rule.date-from <= p-date
  and buf_dis-time-rule.date-to >= p-date
  and (buffer buf_dis-time-rule:buffer-field("week-day-" + string(loc-weekday(p-date) )):buffer-value = yes
       or buf_dis-time-rule.week-day-0 = yes)
  and buf_dis-time-rule.time-from <= p-time
  and buf_dis-time-rule.time-to >= p-time
  then do:
    return yes.
  end.
end.
return no.
end function.
FUNCTION DIS-TIME-RULE_00009 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
define buffer buf_dis-time-rule for ub.dis-time-rule.
define buffer buf_term-dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
          buf_dis-time-rule.time-rule-num = p-time-rule-num no-error.
if available buf_dis-time-rule
and buf_dis-time-rule.sts = integer ('0':U) then do:
  for each buf_term-dis-time-rule no-lock where
          buf_term-dis-time-rule.upper-time-rule-num = buf_dis-time-rule.time-rule-num:
    if buf_term-dis-time-rule.time-from <= p-time
    and buf_term-dis-time-rule.time-to >= p-time
    and buffer buf_term-dis-time-rule:buffer-field("week-day-" + string(loc-weekday(p-date) )):buffer-value = yes
    then do:
      return yes.
    end.
  end.
end.
return no.
end function.
FUNCTION DIS-TIME-RULE_00010 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
          buf_dis-time-rule.time-rule-num = p-time-rule-num no-error.
if available buf_dis-time-rule
and buf_dis-time-rule.sts = integer ('0':U) then do:
  if buffer buf_dis-time-rule:buffer-field("week-day-" + string(loc-weekday(p-date) )):buffer-value = yes
  then do:
    return yes.
  end.
end.
return no.
end function.
FUNCTION DIS-TIME-RULE_00011 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
          buf_dis-time-rule.time-rule-num = p-time-rule-num no-error.
if available buf_dis-time-rule
and buf_dis-time-rule.sts = integer ('0':U) then do:
  if (buf_dis-time-rule.week-day-0 = yes
  or (buffer buf_dis-time-rule:buffer-field("week-day-" + string(loc-weekday(p-date) )):buffer-value = yes))
  and (buf_dis-time-rule.time-from <= p-time
  and buf_dis-time-rule.time-to >= p-time)
  then do:
    return yes.
  end.
end.
return no.
end function.
FUNCTION DIS-TIME-RULE_00012 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
          buf_dis-time-rule.time-rule-num = p-time-rule-num no-error.
if available buf_dis-time-rule
and buf_dis-time-rule.sts = integer ('0':U) then do:
  if buf_dis-time-rule.time-from <= p-time
  then do:
    return yes.
  end.
end.
return no.
end function.
FUNCTION dis-rule_rf_00001 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-price-netto as decimal
                                        , output p-discnt-pcnt as decimal
                                        , output p-value-type as integer
                                        , output p-not-found as logical
                                        ):
define buffer buf_dis-rule for ub.dis-rule.
p-value-type = integer('1':U).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer('0':U)
and (buf_Dis-rule.time-templ-rl-root <= 50000 or dynamic-function( "dis-time-rule_" + string(buf_dis-rule.time-templ-rl-root - 50000, "99999")                                        , input buf_dis-rule.time-rule-num                                         , input p-date                                        , input p-time )) then do:
  p-discnt-pcnt = buf_dis-rule.discnt-value.
  return p-price-netto * buf_dis-rule.discnt-value / 100.
end.
p-not-found = yes.
return 0.
end function.
FUNCTION dis-rule_rf_00002 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-price-base-netto as decimal
                                        , input p-qnty as decimal
                                        , input p-cli-base-rate as decimal
                                        , output p-discnt-sum as decimal
                                        , output p-value-type as integer
                                        , output p-not-found as logical
                                        ):
define buffer buf_dis-rule for ub.dis-rule.
p-value-type = integer('2':U).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer('0':U)
and (buf_Dis-rule.time-templ-rl-root <= 50000 or dynamic-function( "dis-time-rule_" + string(buf_dis-rule.time-templ-rl-root - 50000, "99999")                                        , input buf_dis-rule.time-rule-num                                         , input p-date                                        , input p-time )) then do:
  if p-price-base-netto - buf_dis-rule.discnt-value <= 0 then do:
    p-discnt-sum  = 0.
    p-not-found = yes.
    return 0.
  end.
  p-discnt-sum = buf_dis-rule.discnt-value * p-qnty * p-cli-base-rate.
  return buf_dis-rule.discnt-value * p-cli-base-rate.
end.
p-not-found = yes.
return 0.
end function.
FUNCTION dis-rule_rf_00003 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-qnty as decimal
                                        , input p-cli-base-rate as decimal
                                        , input-output p-price as decimal
                                        , output p-discnt-sum as decimal
                                        , output p-value-type as integer
                                        , output p-not-found as logical
                                        ):
define variable v-price as decimal no-undo .
define buffer buf_dis-rule for ub.dis-rule.
p-value-type = integer('2':U).
v-price = p-price.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer('0':U)
and (buf_Dis-rule.time-templ-rl-root <= 50000 or dynamic-function( "dis-time-rule_" + string(buf_dis-rule.time-templ-rl-root - 50000, "99999")                                        , input buf_dis-rule.time-rule-num                                         , input p-date                                        , input p-time )) then do:
  if buf_dis-rule.discnt-value <= 0 then do:
    p-discnt-sum  = 0.
    p-not-found = yes.
    return 0.
  end.
  p-price = buf_dis-rule.discnt-value * p-cli-base-rate.
  p-discnt-sum = (v-price - p-price) * p-qnty.
  return (v-price - p-price).
end.
p-not-found = yes.
return 0.
end function.
FUNCTION dis-rule_rf_00005 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-price as decimal
                                        , input p-doc-qnty as decimal
                                        , input p-discnt-role as character
                                        , input p-gds-code as integer
                                        , input p-line-num as integer
                                        , input p-chk-gds-table as handle
                                        , output p-discnt-pcnt as decimal
                                        , output p-value-type as integer
                                        , output p-intended as logical
                                        , input-output p-doc-recalc-gline-num as integer
                                        , input-output p-gline-recalc-line-num as integer
                                        , output p-not-found as logical
                                        ):
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
define variable v-delta as decimal no-undo .
define variable v-start as logical no-undo init yes.
define variable v-discnt as decimal no-undo .
define variable v-qnty as decimal no-undo .
define variable glog as logical no-undo .
define variable v-chk-gds-bh as handle no-undo .
define variable v-line-num as integer no-undo init -1.
define variable v-current-line as integer no-undo .
p-value-type = integer('1':U).
v-qnty = p-doc-qnty.
p-intended = yes.
create buffer v-chk-gds-bh for table p-chk-gds-table:default-buffer-handle.
do while true:
 assign
 glog = v-chk-gds-bh:find-first( substitute("where gds-code = &1 and line-num > &2"
                                     , p-gds-code
                                     , v-current-line
                                     )) no-error.
 if not glog
 or error-status:error
 or v-chk-gds-bh:available = no
 then leave.
 assign
  v-current-line = v-chk-gds-bh:buffer-field("line-num"):buffer-value
  v-line-num = (if v-line-num > v-current-line
                or v-line-num = -1
                then v-current-line
                else v-line-num)
 .
 if v-chk-gds-bh:buffer-field("line-num"):buffer-value = p-line-num then do:
 end.
 else do:
  assign
  v-qnty = v-qnty + v-chk-gds-bh:buffer-field("will-doc-qnty"):buffer-value
  .
 end.
end.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer('0':U)
and (buf_Dis-rule.time-templ-rl-root <= 50000 or dynamic-function( "dis-time-rule_" + string(buf_dis-rule.time-templ-rl-root - 50000, "99999")                                        , input buf_dis-rule.time-rule-num                                         , input p-date                                        , input p-time ))
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if buf_term-dis-rule.doc-qnty <= v-qnty then do:
      if v-start
      or v-delta  > (v-qnty - buf_term-dis-rule.doc-qnty)
      then do:
        assign
        p-discnt-pcnt = buf_term-dis-rule.discnt-value
        v-start = no
        v-delta = v-qnty - buf_term-dis-rule.doc-qnty
        v-discnt  = p-price * buf_term-dis-rule.discnt-value / 100
        p-intended = no
        .
      end.
    end.
  end.
  if (v-line-num < p-line-num
  or p-doc-recalc-gline-num = 0
  or p-doc-recalc-gline-num > v-line-num)
  and not (p-gline-recalc-line-num = v-line-num
          and
          v-line-num = p-line-num)
  then do:
    p-doc-recalc-gline-num = v-line-num.
  end.
  if p-gline-recalc-line-num = 0
  or p-gline-recalc-line-num > v-line-num then do:
    p-gline-recalc-line-num = v-line-num.
  end.
  delete object v-chk-gds-bh.
  p-not-found = not p-intended.
  return v-discnt.
end.
p-not-found = yes.
return 0.
end function.
FUNCTION dis-rule_rf_00006 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-price-base as decimal
                                        , input p-doc-qnty as decimal
                                        , input p-cli-base-rate as decimal
                                        , input p-discnt-role as character
                                        , input p-gds-code as integer
                                        , input p-line-num as integer
                                        , input p-chk-gds-table as handle
                                        , output p-discnt-sum as decimal
                                        , output p-value-type as integer
                                        , output p-intended as logical
                                        , input-output p-doc-recalc-gline-num as integer
                                        , input-output p-gline-recalc-line-num as integer
                                        , output p-not-found as logical
                                        ):
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
define variable v-delta as decimal no-undo .
define variable v-start as logical no-undo init yes.
define variable v-discnt as decimal no-undo .
define variable v-qnty as decimal no-undo .
define variable glog as logical no-undo .
define variable v-chk-gds-bh as handle no-undo .
define variable v-line-num as integer no-undo init -1.
define variable v-current-line as integer no-undo .
p-value-type = integer('2':U).
v-qnty = p-doc-qnty.
p-intended = yes.
create buffer v-chk-gds-bh for table p-chk-gds-table:default-buffer-handle.
do while true:
 assign
 glog = v-chk-gds-bh:find-first( substitute("where gds-code = &1 and line-num > &2"
                                     , p-gds-code
                                     , v-current-line
                                     )) no-error.
 if not glog
 or error-status:error
 or v-chk-gds-bh:available = no
 then leave.
 assign
  v-current-line = v-chk-gds-bh:buffer-field("line-num"):buffer-value
  v-line-num = (if v-line-num > v-current-line
                or v-line-num = -1
                then v-current-line
                else v-line-num)
 .
 if v-chk-gds-bh:buffer-field("line-num"):buffer-value = p-line-num then do:
 end.
 else do:
  assign
  v-qnty = v-qnty + v-chk-gds-bh:buffer-field("will-doc-qnty"):buffer-value
  .
 end.
end.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer('0':U)
and (buf_Dis-rule.time-templ-rl-root <= 50000 or dynamic-function( "dis-time-rule_" + string(buf_dis-rule.time-templ-rl-root - 50000, "99999")                                        , input buf_dis-rule.time-rule-num                                         , input p-date                                        , input p-time ))
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if buf_term-dis-rule.doc-qnty <= v-qnty then do:
      if v-start
      or v-delta  > (v-qnty - buf_term-dis-rule.doc-qnty)
      then do:
        assign
        p-discnt-sum = buf_term-dis-rule.discnt-value * p-doc-qnty
        v-start = no
        v-delta = v-qnty - buf_term-dis-rule.doc-qnty
        v-discnt  = buf_term-dis-rule.discnt-value
        p-intended = no
        .
      end.
    end.
  end.
  if p-price-base - v-discnt <= 0 then do:
    p-discnt-sum  = 0.
    p-not-found = yes.
    return 0.
  end.
  if (v-line-num < p-line-num
  or p-doc-recalc-gline-num = 0
  or p-doc-recalc-gline-num > v-line-num)
  and not (p-gline-recalc-line-num = v-line-num
          and
          v-line-num = p-line-num)
  then do:
    p-doc-recalc-gline-num = v-line-num.
  end.
  if p-gline-recalc-line-num = 0
  or p-gline-recalc-line-num > v-line-num then do:
    p-gline-recalc-line-num = v-line-num.
  end.
  delete object v-chk-gds-bh.
  p-not-found = not p-intended.
  return v-discnt * p-cli-base-rate.
end.
p-not-found = yes.
return 0.
end function.
FUNCTION dis-rule_rf_00008 returns decimal ( input p-rule-num as integer
                                          , input p-date as date
                                          , input p-time as integer
                                          , input p-price-netto as decimal
                                          , input p-dis-kat as integer
                                          , output p-discnt-pcnt as decimal
                                          , output p-value-type as integer
                                          , output p-not-found as logical
                                          ):
define variable v-price as decimal no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
p-value-type = integer('1':U).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer('0':U)
and (buf_Dis-rule.time-templ-rl-root <= 50000 or dynamic-function( "dis-time-rule_" + string(buf_dis-rule.time-templ-rl-root - 50000, "99999")                                        , input buf_dis-rule.time-rule-num                                         , input p-date                                        , input p-time ))
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num
  and buf_term-dis-rule.dis-kat = p-dis-kat :
    p-discnt-pcnt = buf_term-dis-rule.discnt-value.
    return p-price-netto * buf_term-dis-rule.discnt-value / 100.
  end.
end.
p-not-found = yes.
return 0.0.
end function.
FUNCTION dis-rule_rf_00009 returns decimal ( input p-rule-num as integer
                                          , input p-date as date
                                          , input p-time as integer
                                          , input p-price-netto as decimal
                                          , input p-qnty as decimal
                                          , input p-cli-base-rate as decimal
                                          , input p-dis-kat as integer
                                          , output p-discnt-sum as decimal
                                          , output p-value-type as integer
                                          , output p-not-found as logical
                                          ):
define variable v-price as decimal no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
p-value-type = integer('2':U).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer('0':U)
and (buf_Dis-rule.time-templ-rl-root <= 50000 or dynamic-function( "dis-time-rule_" + string(buf_dis-rule.time-templ-rl-root - 50000, "99999")                                        , input buf_dis-rule.time-rule-num                                         , input p-date                                        , input p-time ))
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num
       and buf_term-dis-rule.dis-kat = p-dis-kat:
    if p-price-netto - buf_term-dis-rule.discnt-value * p-cli-base-rate <= 0 then do:
      p-discnt-sum = 0.
      p-not-found = yes.
      return 0.
    end.
    p-discnt-sum = buf_term-dis-rule.discnt-value * p-qnty * p-cli-base-rate.
    return buf_term-dis-rule.discnt-value * p-cli-base-rate .
  end.
end.
p-not-found = yes.
return 0.0.
end function.
FUNCTION dis-rule_rf_00020 returns decimal ( input p-rule-num as integer
                                          , input p-date as date
                                          , input p-time as integer
                                          , input p-sum-for-discnt as decimal
                                          , output p-discnt-pcnt as decimal
                                          , output p-value-type as integer
                                          , output p-not-found as logical
                                          ):
define variable v-discnt as decimal no-undo .
define variable v-start as logical no-undo init yes.
define variable v-delta as decimal no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
p-value-type = integer('1':U).
p-not-found = yes.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer('0':U)
and (buf_Dis-rule.time-templ-rl-root <= 50000 or dynamic-function( "dis-time-rule_" + string(buf_dis-rule.time-templ-rl-root - 50000, "99999")                                        , input buf_dis-rule.time-rule-num                                         , input p-date                                        , input p-time ))
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if buf_term-dis-rule.tot-sum <= p-sum-for-discnt then do:
      if v-start
      or v-delta  > (p-sum-for-discnt - buf_term-dis-rule.tot-sum)
      then do:
        assign
        p-discnt-pcnt = buf_term-dis-rule.discnt-value
        v-start = no
        v-delta = p-sum-for-discnt - buf_term-dis-rule.tot-sum
        v-discnt = p-sum-for-discnt * buf_term-dis-rule.discnt-value / 100
        p-not-found = no
        .
      end.
    end.
  end.
  return v-discnt.
end.
return 0.0.
end function.
FUNCTION dis-rule_rf_00028 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-price-netto as decimal
                                        , output p-discnt-pcnt as decimal
                                        , output p-value-type as integer
                                        , output p-not-found as logical
                                        ):
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
p-value-type = integer('1':U).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer('0':U)
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if (buf_term-Dis-rule.time-templ-rl-root <= 50000 or dynamic-function( "dis-time-rule_" + string(buf_term-dis-rule.time-templ-rl-root - 50000, "99999" )                                        , input buf_term-dis-rule.time-rule-num                                         , input p-date                                        , input p-time )) then do:
      p-discnt-pcnt = buf_term-dis-rule.discnt-value.
      return p-price-netto * buf_term-dis-rule.discnt-value / 100.
    end.
  end.
end.
p-not-found = yes.
return 0.
end function.
FUNCTION dis-rule_rf_00036 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-price-netto as decimal
                                        , output p-discnt-pcnt as decimal
                                        , output p-value-type as integer
                                        , output p-not-found as logical
                                        ) map to dis-rule_rf_00001 in this-procedure.
FUNCTION dis-rule_rf_00042 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-payment-sum as decimal
                                        , input p-exch-rate as decimal
                                        , input p-exch-scale as integer
                                        , input p-to-pay-r-b as decimal
                                        , input p-base-rate as decimal
                                        , output p-discnt-pcnt as decimal
                                        , output p-value-type as integer
                                        , input-output p-object-sum as decimal
                                        , output p-not-found as logical
                                        ):
define buffer buf_dis-rule for ub.dis-rule.
p-value-type = integer('1':U).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer('0':U)
and (buf_Dis-rule.time-templ-rl-root <= 50000 or dynamic-function( "dis-time-rule_" + string(buf_dis-rule.time-templ-rl-root - 50000, "99999")                                        , input buf_dis-rule.time-rule-num                                         , input p-date                                        , input p-time )) then do:
  p-discnt-pcnt = buf_dis-rule.discnt-value.
  if p-to-pay-r-b < (p-payment-sum / p-exch-rate * p-exch-scale) / p-base-rate then do:
    p-object-sum = p-to-pay-r-b.
  end.
  return minimum (p-to-pay-r-b, p-payment-sum / p-exch-rate * p-exch-scale / p-base-rate ) * buf_dis-rule.discnt-value / 100 .
end.
p-not-found = yes.
return 0.
end function.
FUNCTION dis-rule_rf_00042i returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-payment-sum as decimal
                                        , input p-exch-rate as decimal
                                        , input p-exch-scale as integer
                                        , input p-to-pay-r-b as decimal
                                        , input p-base-rate as decimal
                                        , output p-discnt-pcnt as decimal
                                        , output p-value-type as integer
                                        , input-output p-object-sum as decimal
                                        , output p-not-found  as logical
                                        ) :
define buffer buf_dis-rule for ub.dis-rule.
p-value-type = integer('1':U).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer('0':U)
and (buf_Dis-rule.time-templ-rl-root <= 50000 or dynamic-function( "dis-time-rule_" + string(buf_dis-rule.time-templ-rl-root - 50000, "99999")                                        , input buf_dis-rule.time-rule-num                                         , input p-date                                        , input p-time )) then do:
  p-discnt-pcnt = buf_dis-rule.discnt-value.
  if p-to-pay-r-b < (p-payment-sum / p-exch-rate * p-exch-scale) / p-base-rate then do:
    p-object-sum = p-to-pay-r-b.
  end.
  return minimum (p-to-pay-r-b, (p-payment-sum  * 100 / (100 - buf_dis-rule.discnt-value))/ p-exch-rate * p-exch-scale / p-base-rate) * buf_dis-rule.discnt-value / 100 .
end.
p-not-found = yes.
return 0.
end function.
FUNCTION dis-rule_rf_00048 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-price as decimal
                                        , input p-doc-qnty as decimal
                                        , input p-discnt-role as character
                                        , input p-sum-grp-code as integer
                                        , input p-line-num as integer
                                        , input p-chk-gds-table as handle
                                        , output p-discnt-pcnt as decimal
                                        , output p-value-type as integer
                                        , output p-intended as logical
                                        , input-output p-doc-recalc-gline-num as integer
                                        , input-output p-gline-recalc-line-num as integer
                                        , output p-not-found as logical
                                        ):
define variable v-delta as decimal no-undo .
define variable v-start as logical no-undo init yes.
define variable v-discnt as decimal no-undo .
define variable v-qnty as decimal no-undo .
define variable glog as logical no-undo .
define variable v-chk-gds-bh as handle no-undo .
define variable v-line-num as integer no-undo init -1.
define variable v-current-line as integer no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
p-value-type = integer('1':U).
v-qnty = p-doc-qnty .
p-intended = yes.
create buffer v-chk-gds-bh for table p-chk-gds-table:default-buffer-handle.
do while true:
 assign
 glog = v-chk-gds-bh:find-first( substitute("where sum-grp-code = &1 and line-num > &2"
                                     , p-sum-grp-code
                                     , v-current-line
                                     )) no-error.
 if not glog
 or error-status:error
 or v-chk-gds-bh:available = no
 then leave.
 assign
  v-current-line = v-chk-gds-bh:buffer-field("line-num"):buffer-value
  v-line-num = (if v-line-num > v-current-line
                or v-line-num = -1
                then v-current-line
                else v-line-num)
 .
 if v-chk-gds-bh:buffer-field("line-num"):buffer-value = p-line-num then do:
 end.
 else do:
  assign
  v-qnty = v-qnty + v-chk-gds-bh:buffer-field("will-doc-qnty"):buffer-value
  .
 end.
end.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer('0':U)
and (buf_Dis-rule.time-templ-rl-root <= 50000 or dynamic-function( "dis-time-rule_" + string(buf_dis-rule.time-templ-rl-root - 50000, "99999")                                        , input buf_dis-rule.time-rule-num                                         , input p-date                                        , input p-time ))
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if buf_term-dis-rule.doc-qnty <= v-qnty then do:
      if v-start
      or v-delta  > (v-qnty - buf_term-dis-rule.doc-qnty)
      then do:
        assign
        p-discnt-pcnt= buf_term-dis-rule.discnt-value
        v-start = no
        v-delta = v-qnty - buf_term-dis-rule.doc-qnty
        v-discnt = p-price * buf_term-dis-rule.discnt-value / 100
        p-intended = no
        .
      end.
    end.
  end.
  if (v-line-num < p-line-num
  or p-doc-recalc-gline-num = 0
  or p-doc-recalc-gline-num > v-line-num)
  and not (p-gline-recalc-line-num = v-line-num
          and
          v-line-num = p-line-num)
  then do:
    p-doc-recalc-gline-num = v-line-num.
  end.
  if p-gline-recalc-line-num = 0
  or p-gline-recalc-line-num > v-line-num then do:
    p-gline-recalc-line-num = v-line-num.
  end.
  delete object v-chk-gds-bh.
  p-not-found = not p-intended.
  return v-discnt.
end.
p-not-found = yes.
return 0.0.
end function.
FUNCTION dis-rule_rf_00049 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-price as decimal
                                        , input p-qnty as decimal
                                        , input p-discnt-role as character
                                        , input p-sum-grp-code as integer
                                        , input p-line-num as integer
                                        , input p-chk-gds-table as handle
                                        , output p-discnt-pcnt as decimal
                                        , output p-value-type as integer
                                        , output p-intended as logical
                                        , input-output p-doc-recalc-gline-num as integer
                                        , input-output p-gline-recalc-line-num as integer
                                        , output p-not-found as logical
                                        ):
define variable v-delta as decimal no-undo .
define variable v-start as logical no-undo init yes.
define variable v-discnt as decimal no-undo .
define variable v-sum as decimal no-undo .
define variable glog as logical no-undo .
define variable v-chk-gds-bh as handle no-undo .
define variable v-line-num as integer no-undo init -1.
define variable v-current-line as integer no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
p-value-type = integer('1':U).
v-sum = p-qnty * p-price.
p-intended = yes.
create buffer v-chk-gds-bh for table p-chk-gds-table:default-buffer-handle.
do while true:
 assign
 glog = v-chk-gds-bh:find-first( substitute("where sum-grp-code = &1 and line-num > &2"
                                     , p-sum-grp-code
                                     , v-current-line
                                     )) no-error.
 if not glog
 or error-status:error
 or v-chk-gds-bh:available = no
 then leave.
 assign
  v-current-line = v-chk-gds-bh:buffer-field("line-num"):buffer-value
  v-line-num = (if v-line-num > v-current-line
                or v-line-num = -1
                then v-current-line
                else v-line-num)
 .
 if v-chk-gds-bh:buffer-field("line-num"):buffer-value = p-line-num then do:
 end.
 else do:
  assign
  v-sum = v-sum + v-chk-gds-bh:buffer-field("src-qnty"):buffer-value * v-chk-gds-bh:buffer-field("start-src-price"):buffer-value
  .
 end.
end.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer('0':U)
and (buf_Dis-rule.time-templ-rl-root <= 50000 or dynamic-function( "dis-time-rule_" + string(buf_dis-rule.time-templ-rl-root - 50000, "99999")                                        , input buf_dis-rule.time-rule-num                                         , input p-date                                        , input p-time ))
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if buf_term-dis-rule.tot-sum <= v-sum then do:
      if v-start
      or v-delta  > (v-sum - buf_term-dis-rule.tot-sum)
      then do:
        assign
        p-discnt-pcnt= buf_term-dis-rule.discnt-value
        v-start = no
        v-delta = v-sum - buf_term-dis-rule.tot-sum
        v-discnt = p-price * buf_term-dis-rule.discnt-value / 100
        p-intended = no
        .
      end.
    end.
  end.
  if (v-line-num < p-line-num
  or p-doc-recalc-gline-num = 0
  or p-doc-recalc-gline-num > v-line-num)
  and not (p-gline-recalc-line-num = v-line-num
          and
          v-line-num = p-line-num)
  then do:
    p-doc-recalc-gline-num = v-line-num.
  end.
  if p-gline-recalc-line-num = 0
  or p-gline-recalc-line-num > v-line-num then do:
    p-gline-recalc-line-num = v-line-num.
  end.
  delete object v-chk-gds-bh.
  p-not-found = not p-intended.
  return v-discnt.
end.
p-not-found = yes.
return 0.0.
end function.
FUNCTION dis-rule_rf_00054 returns decimal ( input p-rule-num as integer
                                          , input p-date as date
                                          , input p-time as integer
                                          , input p-sum-for-discnt as decimal
                                          , input p-dis-kat as integer
                                          , output p-discnt-pcnt as decimal
                                          , output p-value-type as integer
                                          , output p-not-found as logical
                                          ):
define variable v-price as decimal no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
p-value-type = integer('1':U).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer('0':U)
and buf_dis-rule.dis-kat = p-dis-kat
and (buf_Dis-rule.time-templ-rl-root <= 50000 or dynamic-function( "dis-time-rule_" + string(buf_dis-rule.time-templ-rl-root - 50000, "99999")                                        , input buf_dis-rule.time-rule-num                                         , input p-date                                        , input p-time ))
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num  :
    p-discnt-pcnt = buf_term-dis-rule.discnt-value.
    return p-sum-for-discnt * buf_term-dis-rule.discnt-value / 100.
  end.
end.
p-not-found = yes.
return 0.0.
end function.
FUNCTION dis-rule_rf_00055 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-qnty as decimal
                                        , input p-price-netto as decimal
                                        , input-output p-without-subtotal-discnt as integer
                                        , input-output p-sum-for-discnt as decimal
                                        , output p-value-type as integer
                                        , output p-not-found as logical
                                        ):
define buffer buf_dis-rule for ub.dis-rule.
p-value-type = integer('2':U).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer('0':U)
and (buf_Dis-rule.time-templ-rl-root <= 50000 or dynamic-function( "dis-time-rule_" + string(buf_dis-rule.time-templ-rl-root - 50000, "99999")                                        , input buf_dis-rule.time-rule-num                                         , input p-date                                        , input p-time )) then do:
  p-without-subtotal-discnt = 1.
  p-sum-for-discnt = p-sum-for-discnt - (p-qnty  * p-price-netto).
  return - (p-qnty  * p-price-netto).
end.
p-not-found = yes.
p-without-subtotal-discnt = 0.
return 0.0.
end function.
FUNCTION dis-rule_rf_00056 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input-output p-without-gds-discnt as integer
                                        , output p-value-type as integer
                                        , output p-not-found as logical
                                        ):
define buffer buf_dis-rule for ub.dis-rule.
p-value-type = integer('2':U).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer('0':U)
and (buf_Dis-rule.time-templ-rl-root <= 50000 or dynamic-function( "dis-time-rule_" + string(buf_dis-rule.time-templ-rl-root - 50000, "99999")                                        , input buf_dis-rule.time-rule-num                                         , input p-date                                        , input p-time )) then do:
  p-without-gds-discnt = 1.
  return 0.0.
end.
p-not-found = yes.
p-without-gds-discnt = 0.
return 0.0.
end function.
FUNCTION dis-rule_rf_00076 returns decimal ( input p-rule-num as integer
                                          , input p-date as date
                                          , input p-time as integer
                                          , input p-price-netto as decimal
                                          , input p-qnty as decimal
                                          , input p-cli-base-rate as decimal
                                          , input p-dis-kat as integer
                                          , input-output p-price as decimal
                                          , output p-discnt-pcnt as decimal
                                          , output p-discnt-sum as decimal
                                          , output p-value-type as integer
                                          , output p-not-found as logical
                                          ):
define variable v-price as decimal no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
p-value-type = integer('2':U).
v-price = p-price.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer('0':U)
and (buf_Dis-rule.time-templ-rl-root <= 50000 or dynamic-function( "dis-time-rule_" + string(buf_dis-rule.time-templ-rl-root - 50000, "99999")                                        , input buf_dis-rule.time-rule-num                                         , input p-date                                        , input p-time ))
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num
  and buf_term-dis-rule.dis-kat = p-dis-kat :
    case buf_term-dis-rule.value-type:
      when integer('1':U) then do:
        p-value-type = integer('1':U).
        p-discnt-pcnt = buf_term-dis-rule.discnt-value.
        return p-price-netto * buf_term-dis-rule.discnt-value / 100.
      end.
      when integer('2':U) then do:
        p-value-type = integer('2':U).
        if p-price-netto - buf_term-dis-rule.discnt-value * p-cli-base-rate <= 0 then do:
          p-discnt-sum = 0.
          return 0.
        end.
        p-discnt-sum = buf_term-dis-rule.discnt-value * p-qnty * p-cli-base-rate.
        return buf_term-dis-rule.discnt-value * p-cli-base-rate.
      end.
      when integer('3':U) then do:
        p-value-type = integer('3':U).
        if buf_term-dis-rule.discnt-value <= 0 then do:
          p-discnt-sum  = 0.
          return 0.
        end.
        p-price = buf_term-dis-rule.discnt-value * p-cli-base-rate.
        p-discnt-sum = (p-price-netto - v-price) * p-qnty.
        return (p-price-netto - v-price).
      end.
    end case.
  end.
end.
p-not-found = yes.
return 0.0.
end function.
FUNCTION dis-rule_rf_00077 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-price-netto as decimal
                                        , input p-d-pcnt as decimal
                                        , output p-discnt-pcnt as decimal
                                        , output p-value-type as integer
                                        ):
p-value-type = integer('1':U).
assign
p-discnt-pcnt = p-d-pcnt.
return p-price-netto * p-d-pcnt / 100.
end function.
FUNCTION dis-rule_rf_00078 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-sum-for-discnt as decimal
                                        , input p-cash-d-pcnt as decimal
                                        , output p-discnt-pcnt as decimal
                                        , output p-value-type as integer
                                        ):
p-value-type = integer('1':U).
assign
p-discnt-pcnt = p-cash-d-pcnt.
return p-sum-for-discnt * p-cash-d-pcnt / 100.
end function.
FUNCTION dis-rule_rf_00084 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-obj-code as integer
                                        , input p-price-netto as decimal
                                        , input p-qnty as decimal
                                        , input p-b-code as integer
                                        , input-output p-price as decimal
                                        , output p-discnt-sum as decimal
                                        , output p-value-type as integer
                                        , output p-not-found as logical
                                        ):
define variable v-price as decimal no-undo .
define variable v-pdf-id as integer no-undo .
define variable v-pdf-db-num as integer   no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
v-price = p-price.
p-value-type = integer('2':U).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer('0':U)
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if (buf_term-Dis-rule.time-templ-rl-root <= 50000 or dynamic-function( "dis-time-rule_" + string(buf_term-dis-rule.time-templ-rl-root - 50000, "99999" )                                        , input buf_term-dis-rule.time-rule-num                                         , input p-date                                        , input p-time )) then do:
      run mpl-tpl-auto in this-procedure ( input p-b-code
                                          ,input 'маг':U
                                          ,input p-obj-code
                                          ,input integer(entry(1, buf_term-dis-rule.charkey_one,"-"))
                                          ,input integer(entry(2, buf_term-dis-rule.charkey_one,"-"))
                                          ,input ?
                                          ,output v-price
                                          ,output v-pdf-id
                                          ,output v-pdf-db-num
                                          ) no-error.
      if error-status :error then do:
         v-price = p-price-netto.
         p-not-found = yes.
         return 0.
      end.
      if v-pdf-id = 0
      or v-pdf-id = ? then do:
        p-not-found = yes.
      end.
      p-value-type = integer('12':U).
      p-discnt-sum = (p-price-netto - v-price) * p-qnty.
      return (p-price-netto - v-price).
    end.
  end.
end.
p-not-found = yes.
return 0.
end function.
FUNCTION dis-rule_rf_00085 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-price-netto as decimal
                                        , input p-nonunique as character
                                        , input p-b-code as integer
                                        , output p-not-found as logical
                                        , output p-discnt-pcnt as decimal
                                        , output p-value-type as integer
                                        ):
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
p-value-type = integer('1':U).
if p-nonunique <> string(p-b-code) then do:
  p-not-found = yes.
  return 0.
end.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer('0':U)
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if (buf_term-Dis-rule.time-templ-rl-root <= 50000 or dynamic-function( "dis-time-rule_" + string(buf_term-dis-rule.time-templ-rl-root - 50000, "99999" )                                        , input buf_term-dis-rule.time-rule-num                                         , input p-date                                        , input p-time )) then do:
      p-discnt-pcnt = buf_term-dis-rule.discnt-value.
      return p-price-netto * buf_term-dis-rule.discnt-value / 100.
    end.
  end.
end.
p-not-found = yes.
return 0.
end function.
FUNCTION dis-rule_rf_00088 returns decimal ( input p-rule-num as integer
                                          , input p-date as date
                                          , input p-time as integer
                                          , input p-obj-code as integer
                                          , input p-price-netto as decimal
                                          , input p-dis-kat as integer
                                          , input p-qnty as decimal
                                          , input p-b-code as integer
                                          , input-output p-price as decimal
                                          , output p-discnt-sum as decimal
                                          , output p-value-type as integer
                                          , output p-not-found as logical
                                          ):
define variable v-price as decimal no-undo .
define variable v-pdf-id as integer no-undo .
define variable v-pdf-db-num as integer   no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
v-price = p-price.
p-value-type = integer('2':U).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer('0':U)
and (buf_Dis-rule.time-templ-rl-root <= 50000 or dynamic-function( "dis-time-rule_" + string(buf_dis-rule.time-templ-rl-root - 50000, "99999")                                        , input buf_dis-rule.time-rule-num                                         , input p-date                                        , input p-time ))
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num
  and buf_term-dis-rule.dis-kat = p-dis-kat :
    run mpl-tpl-auto in this-procedure ( input p-b-code
                                        ,input 'маг':U
                                        ,input p-obj-code
                                        ,input integer(entry(1, buf_term-dis-rule.charkey_one,"-"))
                                        ,input integer(entry(2, buf_term-dis-rule.charkey_one,"-"))
                                        ,input ?
                                        ,output v-price
                                        ,output v-pdf-id
                                        ,output v-pdf-db-num
                                        ) no-error.
    if error-status :error then do:
        v-price = p-price-netto.
        p-not-found = yes.
        return 0.
    end.
    if v-pdf-id = 0
    or v-pdf-id = ? then do:
      p-not-found = yes.
    end.
    p-value-type = integer('12':U).
    p-discnt-sum = (p-price-netto - v-price) * p-qnty.
    return (p-price-netto - v-price).
  end.
end.
p-not-found = yes.
return 0.0.
end function.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-call-param no-undo
field call-number as integer
field call-name_ as character
field param-name_ as character
field param-label_ as character
field num-params_ as integer
field call-handle_ as handle
field param-number_ as integer
field param-datatype_ as character
field io-mode_ as character
field character_ as character
field date_ as date
field decimal_ as decimal
field integer_ as integer
field logical_ as logical
field fld-df as character
field field-name_ as CHARACTER
field table-no as integer
field field-handle as handle
index pi is unique primary call-name_ param-number_.
define variable v-last-call-name as character no-undo .
define variable v-last-call-number as int64 no-undo .
define variable v-inversed-chr as character no-undo init ''.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure printbuffer private:
define input parameter p-bh as handle no-undo .
define variable v-ii as integer no-undo .
if search("printbuffer.fld") <> ? then do:
  output to value( substitute("&1.txt", p-bh:name)) append.
  put unformatted today chr(32) string(time, "HH:MM:SS")
  this-procedure :name skip
  skip.
  do v-ii = 1 to p-bh:num-fields:
    if p-bh:buffer-field(v-ii):data-type = 'rowid':U then do:
      put unformatted fill( chr(32), 10) p-bh:buffer-field(v-ii):name string(p-bh:buffer-field(v-ii):buffer-value) at 35 skip.
    end.
    else do:
      put unformatted fill( chr(32), 10) p-bh:buffer-field(v-ii):name p-bh:buffer-field(v-ii):buffer-value at 35 skip.
    end.
  end.
end.
output close.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
procedure fact-order-mpl :
  do
  on error undo, return error return-value
  :
define input  parameter p-doc-date as date     no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-fact-order as decimal   no-undo .
define variable v-fact-date            as date    no-undo .
define variable v-fact-time            as integer no-undo .
define variable v-fact-order           as decimal no-undo .
define variable v-shift-end-fact-order as decimal no-undo .
define variable v-day-end-fact-order   as decimal no-undo .
define variable l-shift-on as logical no-undo .
define variable l-date as date      no-undo .
define variable l-time as integer   no-undo .
define variable shift-date as date      no-undo .
define variable shift-num  as integer   no-undo .
define variable shift-name as character no-undo .
define variable max-fact-order as decimal   no-undo .
define buffer buf_global-state for ub.global-state  .
find first buf_global-state no-lock no-error .
if not available buf_global-state then do:
   message
     "Не заданы параметры ценообразования!"
     view-as alert-box error
   .
   return error return-value .
end.
  run cur-time in this-procedure
  ( output v-fact-date ,
    output v-fact-time  ).
if p-doc-date = ? then do:
if buf_global-state.pl-use-sys-date-time  = true then do:
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  ?
        ,input  ?
        ,input  false
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
else do:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) no-error .
      if error-status :error then return error "Неопределена дата на объекте " + return-value .
      if p-doc-date <> ? then do:
      end.
       run gbl/factdate.p
       ( input        p-obj-type  ,
         input        p-obj-code  ,
         input-output v-fact-date ,
         input-output v-fact-time ,
         input-output shift-date      ,
         input-output shift-num       ,
         input-output shift-name      ,
         input        yes
         ) no-error .
      if error-status :error then return error substitute(" Ошибка из factdate.p: &1 &2"  , return-value , error-status :get-message(1)   ) .
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  shift-date
        ,input  shift-num
        ,input  l-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
end.
else do:
       run gbl/factdate.p
       ( input        p-obj-type  ,
         input        p-obj-code  ,
         input-output v-fact-date ,
         input-output v-fact-time ,
         input-output shift-date      ,
         input-output shift-num       ,
         input-output shift-name      ,
         input        yes
         ) no-error .
      if error-status :error then return error "Ошибка factdate.p " + return-value .
      v-fact-date = p-doc-date .
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  shift-date
        ,input  shift-num
        ,input  l-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
  end.
end procedure.
DEFINE TEMP-TABLE tt_price-all NO-UNDO LIKE ub.price-all
field sale-qnty as decimal
field sale-sum  as decimal
field sale-tnv  as decimal
field price-sale-base as decimal
field price-sale-rubl as decimal
field road-tax-base   as decimal
field road-tax-rubl   as decimal
field excise-base as decimal
field excise-rubl as decimal
field date-1 as date
field date-2 as date
field shift-1 as int
field shift-2 as int
field time-1 as int
field time-2 as int
field grp-name as char
field interv-name as char
field pay-name as char
field unit-cli as char
index pi
plt-priority DESCENDING
fact-order DESCENDING
qnty-from asc
sum-from asc
turnover-from asc
date-1 DESCENDING
time-1 DESCENDING
date-2 DESCENDING
time-2 DESCENDING
type-price DESCENDING
.
procedure mpl-autoprice :
define input  parameter p-only-b-code as logical   no-undo .
define input  parameter p-cli-type    as character no-undo .
define input  parameter p-cli-code    as integer   no-undo .
define input  parameter p-main-b-code as integer   no-undo .
define input  parameter p-b-code      as integer   no-undo .
define input  parameter p-obj-type    as character no-undo .
define input  parameter p-obj-code    as integer   no-undo .
define input  parameter p-qnty-doc    as decimal   no-undo .
define input  parameter p-sum-doc     as decimal   no-undo .
define input  parameter p-vid-pay        as character no-undo .
define input  parameter p-cash-pay-type  as character no-undo .
define input  parameter p-fact-order  as decimal   no-undo .
define output parameter p-plt-id          as integer   no-undo .
define output parameter p-plt-db-num      as integer   no-undo .
define output parameter p-pdf-id          as integer   no-undo .
define output parameter p-pdf-db-num      as integer   no-undo .
define output parameter p-sale-price-base as decimal   no-undo .
define output parameter p-sale-price-rubl as decimal   no-undo .
define output parameter p-road-tax-base as decimal   no-undo .
define output parameter p-road-tax-rubl as decimal   no-undo .
define output parameter p-excise-base   as decimal   no-undo .
define output parameter p-excise-rubl   as decimal   no-undo .
define variable v-cli-oborot-ALL as decimal   no-undo .
define buffer buf_buyer-in-buyer-group   for ub.buyer-in-buyer-group  .
define buffer buf_turnover-buyer-main    for ub.turnover-buyer-main  .
define buffer buf1_tnv-in-turnover-group for ub.tnv-in-turnover-group  .
define buffer buf2_tnv-in-turnover-group for ub.tnv-in-turnover-group  .
define buffer buf_price-all              for ub.price-all  .
define buffer buf_goods                  for ub.goods      .
define buffer buf_global-state           for ub.global-state  .
define buffer buf_buyer-group            for ub.buyer-group  .
define buffer buf_turnover-group         for ub.turnover-group  .
define buffer buf_main-code              for ub.bar-code  .
define buffer buf_bar-code               for ub.bar-code  .
define buffer buf_pay-type               for ub.pay-type  .
define buffer buf_cash-pay               for ub.cash-pay  .
define variable to-day          as date      no-undo .
define variable v-base-rate0    as decimal   no-undo .
define variable v-base-scale0   as decimal   no-undo .
define variable v-exch-rate0    as decimal   no-undo .
define variable v-exch-scale0   as decimal   no-undo .
define variable v-base-rate     as decimal   no-undo .
define variable v-base-scale    as decimal   no-undo .
define variable v-exch-rate     as decimal   no-undo .
define variable v-exch-scale    as decimal   no-undo .
define variable v-host-code     as integer   no-undo .
define variable v-curr-abbr     as character no-undo .
define variable v-grp-name      as character no-undo .
define variable v-date-1        as date      no-undo .
define variable v-date-2        as date      no-undo .
define variable v-interv        as character no-undo .
define variable v-pay-name      as character no-undo .
define variable v-cli-oborot    as decimal   no-undo .
define variable v-trn-pay-code  as integer   no-undo .
define variable v-cash-pay-curr as integer   no-undo .
define variable v-cash-pay-code as integer   no-undo .
do
on error undo, return error return-value
:
find first buf_main-code no-lock where buf_main-code.b-code = p-main-b-code .
find first buf_goods no-lock where buf_goods.gds-code = buf_main-code.gds-code.
if p-fact-order = ? then do:
  run fact-order-mpl (
      input   today       ,
      input   p-obj-type  ,
      input   p-obj-code  ,
      output  p-fact-order ).
end.
if p-vid-pay <> "" then do:
   find first buf_pay-type no-lock where  buf_pay-type.obj-code = integer(p-vid-pay) no-error .
   if available buf_pay-type
      then v-trn-pay-code = buf_pay-type.obj-code.
      else v-trn-pay-code =  0.
end.
else v-trn-pay-code = 0 .
if p-cash-pay-type <> "" then do:
   find first buf_cash-pay no-lock where  recid(buf_cash-pay) = integer(p-cash-pay-type) no-error .
   if available buf_pay-type
      then
        assign
          v-cash-pay-curr = buf_cash-pay.curr-code
          v-cash-pay-code = buf_cash-pay.cdpay-code
        .
      else
        assign
          v-cash-pay-curr = 0
          v-cash-pay-code = 0
          .
end.
else
  assign
    v-cash-pay-curr = 0
    v-cash-pay-code = 0
    .
for each tt_price-all  : delete tt_price-all . end.
assign
  p-plt-id             = ?
  p-plt-db-num         = ?
  p-pdf-id             = ?
  p-pdf-db-num         = ?
  p-sale-price-base    = ?
  p-sale-price-rubl    = ?
  v-cli-oborot         = 0
.
find first buf_global-state no-lock no-error .
if not available buf_global-state then do:
   message
     "Не заданы параметры ценообразования!"
     view-as alert-box error
   .
   return error return-value .
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output to-day
  )  .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  to-day
  ,output v-base-rate0
  ,output v-base-scale0
  )  .
  v-cli-oborot-ALL  = 0 .
  for each buf_turnover-buyer-main no-lock  where
           buf_turnover-buyer-main.cli-type = p-cli-type  and
           buf_turnover-buyer-main.cli-code = p-cli-code
           :
           v-cli-oborot-ALL = v-cli-oborot-ALL + buf_turnover-buyer-main.sum-doc-rubl-itog .
  end.
for each buf_price-all no-lock where
         buf_price-all.obj-type = p-obj-type and
         buf_price-all.obj-code = p-obj-code and
         buf_price-all.gds-code = buf_goods.gds-code and
         buf_price-all.status_  = 'акт':U  and
       ( p-only-b-code = false   or
       ( buf_price-all.b-code = p-main-b-code or
         buf_price-all.b-code = p-b-code))    and
        ( p-only-b-code = true  or
          buf_price-all.b-code = p-b-code)
          and
          buf_price-all.fact-order-sys-from  <= p-fact-order  and
        ( buf_price-all.fact-order-sys-to = ? or
          buf_price-all.fact-order-sys-to    >= p-fact-order)
        :
         v-interv   = "" .
         v-grp-name = "" .
         v-pay-name = "" .
         if buf_price-all.fact-order = 0  and buf_price-all.plt-priority = 0  then next.
         if buf_price-all.bgr-id > 0 then do:
            find first buf_buyer-group no-lock where
                       buf_buyer-group.bgr-id     = buf_price-all.bgr-id  and
                       buf_buyer-group.bgr-db-num = buf_price-all.bgr-db-num  no-error .
            if available buf_buyer-group then do:
               if p-cli-type <> "" and p-cli-type <> ? then do:
               find first buf_buyer-in-buyer-group no-lock where
                          buf_buyer-in-buyer-group.stts         = 0 and
                          buf_buyer-in-buyer-group.bgr-id       = buf_buyer-group.bgr-id     and
                          buf_buyer-in-buyer-group.bgr-db-num   = buf_buyer-group.bgr-db-num  and
                          buf_buyer-in-buyer-group.bbg-obj-type = p-cli-type and
                          buf_buyer-in-buyer-group.bbg-obj-code = p-cli-code
                          no-error .
                          if not available buf_buyer-in-buyer-group then do:
                             v-grp-name = "".
                             next.
                          end.
                          v-grp-name = buf_buyer-group.name .
               end.
            end.
            else do:
                 v-grp-name = "".
                 next.
            end.
         end.
         if buf_price-all.tog-id > 0 then do:
            find first buf_turnover-group no-lock where
                       buf_turnover-group.tog-id     = buf_price-all.tog-id      and
                       buf_turnover-group.tog-db-num = buf_price-all.tog-db-num  no-error .
            if available buf_turnover-group then do:
               if p-cli-type <> "" and p-cli-type <> ? then do:
                  v-cli-oborot = v-cli-oborot-all  .
                  find first buf1_tnv-in-turnover-group no-lock where
                             buf1_tnv-in-turnover-group.stts       =  0     and
                             buf1_tnv-in-turnover-group.tog-id     =  buf_turnover-group.tog-id     and
                             buf1_tnv-in-turnover-group.tog-db-num =  buf_turnover-group.tog-db-num and
                             buf1_tnv-in-turnover-group.ttg-summa  <=  v-cli-oborot no-error .
                  find first buf2_tnv-in-turnover-group no-lock where
                             buf2_tnv-in-turnover-group.stts       =  0     and
                             buf2_tnv-in-turnover-group.tog-id     =  buf_turnover-group.tog-id     and
                             buf2_tnv-in-turnover-group.tog-db-num =  buf_turnover-group.tog-db-num and
                             buf2_tnv-in-turnover-group.ttg-summa  >=  v-cli-oborot no-error .
                  if not (available buf1_tnv-in-turnover-group and
                          available buf2_tnv-in-turnover-group ) then do:
                          v-grp-name = "".
                          next .
                  end.
                  v-grp-name = buf_turnover-group.name.
               end.
            end.
            else do:
                 v-grp-name = "".
                 next.
            end.
         end.
         if buf_price-all.plt-fix-cource-crc-base = true then
            assign
              v-base-rate  = buf_price-all.pdf-base-rate
              v-base-scale = buf_price-all.pdf-base-scale
            .
            else
            assign
              v-base-rate  = v-base-rate0
              v-base-scale = v-base-scale0
            .
         if buf_price-all.plt-fix-cource-crc-doc = true then
            assign
              v-exch-rate  = buf_price-all.pdf-exch-rate
              v-exch-scale = buf_price-all.pdf-exch-scale
            .
            else do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  buf_price-all.curr-code
  ,input  to-day
  ,output v-exch-rate0
  ,output v-exch-scale0
  ,output v-curr-abbr
  )  .
            assign
              v-exch-rate  = v-exch-rate0
              v-exch-scale = v-exch-scale0
              .
           end.
           v-date-1 = date ( "" )  .
           if buf_price-all.fact-order-sys-from > 0 then do:
              if buf_price-all.start-sys-date <> ?   then  v-date-1 = buf_price-all.start-sys-date.
              if buf_price-all.start-shift-date <> ? then  v-date-1 = buf_price-all.start-shift-date.
              if buf_price-all.start-date <> ?       then  v-date-1 = buf_price-all.start-date.
           end.
           v-date-2 =  date ( "" )  .
           if buf_price-all.fact-order-sys-to > 0 then do:
              if buf_price-all.end-sys-date <> ?     then  v-date-2 = buf_price-all.end-sys-date.
              if buf_price-all.end-shift-date <> ?   then  v-date-2 = buf_price-all.end-shift-date.
              if buf_price-all.end-date <> ?         then  v-date-2 = buf_price-all.end-date.
           end.
           if buf_price-all.qnty-from <> ? then do :
              if not (
              ( p-qnty-doc  >= buf_price-all.qnty-from and buf_price-all.qnty-to = ? ) or
              ( p-qnty-doc  >= buf_price-all.qnty-from and p-qnty-doc <= buf_price-all.qnty-to and buf_price-all.qnty-to <> ?)
              ) then do:
                     v-interv = "".
                     next.
              end.
              v-interv = "К: " + string(buf_price-all.qnty-from) + " - " + ( if buf_price-all.qnty-to = ? then "и более" else string(buf_price-all.qnty-to)) .
           end.
           if buf_price-all.sum-from <> ? then do :
              if not (
              ( p-sum-doc  >= buf_price-all.sum-from and buf_price-all.sum-to = ? ) or
              ( p-sum-doc  >= buf_price-all.sum-from and p-sum-doc <= buf_price-all.sum-to and buf_price-all.sum-to <> ?)
              ) then do:
                 v-interv = "".
                 next.
              end.
              v-interv = "C: " +  string(buf_price-all.sum-from) + " - " + ( if buf_price-all.sum-to = ? then "и более" else string(buf_price-all.sum-to)) .
           end.
           if buf_price-all.turnover-from <> ? then do :
              if not (
              ( v-cli-oborot-ALL  >= buf_price-all.turnover-from and buf_price-all.turnover-to = ? ) or
              ( v-cli-oborot-ALL  >= buf_price-all.turnover-from and v-cli-oborot-ALL <= buf_price-all.turnover-to and buf_price-all.turnover-to <> ?)
              ) then do:
                 v-interv = "".
                 next.
              end.
              v-interv = "O: " +  string(buf_price-all.turnover-from) + " - " + ( if buf_price-all.turnover-to = ? then "и более" else string(buf_price-all.turnover-to)) .
           end.
           if buf_price-all.use-pay-type = 1 then do :
              if buf_price-all.pay-code <> v-trn-pay-code then do:
                 v-pay-name = "" .
                 next.
               end.
               v-pay-name = 'Оплата':U +  ":" + string(buf_price-all.pay-code) .
           end.
           if buf_price-all.use-cash-pay = 1 then do :
              if v-cash-pay-code <> 0 and  not ( buf_price-all.curr-pay-code = v-cash-pay-curr and
                                                 buf_price-all.cdpay-code    = v-cash-pay-code ) then do:
                v-pay-name = "" .
                next.
              end.
              v-pay-name = 'Касс.платеж':U + ":" + string(buf_price-all.cdpay-code) + "_" + string(buf_price-all.curr-pay-code).
           end.
          find first buf_bar-code no-lock where buf_bar-code.b-code = buf_price-all.b-code no-error .
          create tt_price-all .
          buffer-copy buf_price-all to tt_price-all
          assign
            tt_price-all.price-sale-rubl = buf_price-all.price-sale  * v-exch-rate / v-exch-scale
            tt_price-all.road-tax-rubl   = buf_price-all.road-tax    * v-exch-rate / v-exch-scale
            tt_price-all.excise-rubl     = buf_price-all.excise      * v-exch-rate / v-exch-scale
            tt_price-all.price-sale-base = tt_price-all.price-sale-rubl  / v-base-rate * v-base-scale
            tt_price-all.road-tax-base   = tt_price-all.road-tax-rubl    / v-base-rate * v-base-scale
            tt_price-all.excise-base     = tt_price-all.excise-rubl      / v-base-rate * v-base-scale
            tt_price-all.price-sale     = buf_price-all.price-sale
            tt_price-all.road-tax       = buf_price-all.road-tax
            tt_price-all.excise         = buf_price-all.excise
            tt_price-all.pdf-exch-rate   = v-exch-rate
            tt_price-all.pdf-exch-scale  = v-exch-scale
            tt_price-all.pdf-base-rate   = v-base-rate
            tt_price-all.pdf-base-scale  = v-base-scale
            tt_price-all.grp-name        = v-grp-name
            tt_price-all.date-1          = v-date-1
            tt_price-all.shift-1         = buf_price-all.start-shift-num
            tt_price-all.time-1          = buf_price-all.start-sys-time
            tt_price-all.date-2          = v-date-2
            tt_price-all.shift-2         = buf_price-all.end-shift-num
            tt_price-all.time-2          = buf_price-all.end-sys-time
            tt_price-all.interv-name     = v-interv
            tt_price-all.pay-name        = v-pay-name
            tt_price-all.unit-cli        = buf_bar-code.unit-cli
          .
end.
define variable vt-plt-id as integer   no-undo .
define variable vt-plt-db as integer   no-undo .
define variable vt-pdf-id as integer   no-undo .
define variable vt-pdf-db as integer   no-undo .
define buffer neos_price-all for tt_price-all  .
find first tt_price-all where tt_price-all.b-code = p-main-b-code use-index pi no-error .
    if available tt_price-all then do:
     assign
       vt-plt-id = tt_price-all.plt-id
       vt-plt-db = tt_price-all.plt-db-num
       vt-pdf-id = tt_price-all.pdf-id
       vt-pdf-db = tt_price-all.pdf-db
     .
     if tt_price-all.b-code = p-b-code then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = tt_price-all.price-sale-base
            p-sale-price-rubl  = tt_price-all.price-sale-rubl
            p-road-tax-base    = tt_price-all.road-tax-base
            p-road-tax-rubl    = tt_price-all.road-tax-rubl
            p-excise-base      = tt_price-all.excise-base
            p-excise-rubl      = tt_price-all.excise-rubl
            .
     end.
     else do:
       find first neos_price-all where
                  neos_price-all.b-code     = p-b-code  and
                  neos_price-all.plt-id     = vt-plt-id and
                  neos_price-all.plt-db-num = vt-plt-db and
                  neos_price-all.pdf-id     = vt-pdf-id and
                  neos_price-all.pdf-db     = vt-pdf-db
                  use-index pi no-error .
         if available neos_price-all then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = neos_price-all.price-sale-base
            p-sale-price-rubl  = neos_price-all.price-sale-rubl
            p-road-tax-base    = neos_price-all.road-tax-base
            p-road-tax-rubl    = neos_price-all.road-tax-rubl
            p-excise-base      = neos_price-all.excise-base
            p-excise-rubl      = neos_price-all.excise-rubl
            .
         end.
         else do:
              find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code no-error .
              if error-status :error    then do:
                message "Не найден бар-код" p-b-code view-as alert-box error .
                return error return-value .
              end.
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = tt_price-all.price-sale-base
            p-sale-price-rubl  = tt_price-all.price-sale-rubl
            p-road-tax-base    = tt_price-all.road-tax-base
            p-road-tax-rubl    = tt_price-all.road-tax-rubl
            p-excise-base      = tt_price-all.excise-base
            p-excise-rubl      = tt_price-all.excise-rubl * buf_bar-code.cli-base-rate
            .
         end.
     end.
  end.
end.
end procedure.
procedure mpl-tpl-auto :
define input  parameter p-b-code     as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-fact-order as decimal   no-undo .
define output parameter p-sale-price as decimal   no-undo .
define output parameter p-pdf-id     as integer   no-undo .
define output parameter p-pdf-db-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
if p-fact-order = ? then do:
  run fact-order-mpl (
      input   today       ,
      input   p-obj-type  ,
      input   p-obj-code  ,
      output  p-fact-order ) .
end.
assign
  p-pdf-id      = ?
  p-pdf-db-num  = ?
  p-sale-price  = ?
.
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_goods for ub.goods  .
find first buf_bar-code no-lock where
           buf_bar-code.b-code = p-b-code
           no-error .
if error-status :error then return error return-value .
find first buf_goods no-lock where
           buf_goods.gds-code = buf_bar-code.gds-code
           no-error .
if error-status :error then return error return-value .
define variable v-main-b-code as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-main-b-code
  )  .
define buffer buf_price-all for ub.price-all  .
for each tt_price-all : delete tt_price-all. end.
    for each buf_price-all no-lock where
            buf_price-all.plt-id     = p-plt-id                 and
            buf_price-all.plt-db-num = p-plt-db-num             and
            buf_price-all.obj-type   = p-obj-type               and
            buf_price-all.obj-code   = p-obj-code               and
            buf_price-all.gds-code   = buf_goods.gds-code       and
          ( buf_price-all.b-code = v-main-b-code or
            buf_price-all.b-code = p-b-code)    and
            buf_price-all.status_    = 'акт':U         and
            buf_price-all.fact-order-sys-from  <= p-fact-order  and
          ( buf_price-all.fact-order-sys-to = ? or
            buf_price-all.fact-order-sys-to >=  p-fact-order)
            :
              create tt_price-all .
              buffer-copy buf_price-all to tt_price-all
              assign
                tt_price-all.price-sale  = buf_price-all.price-sale
              .
    end.
define variable vt-plt-id as integer   no-undo .
define variable vt-plt-db as integer   no-undo .
define variable vt-pdf-id as integer   no-undo .
define variable vt-pdf-db as integer   no-undo .
define buffer neos_price-all for tt_price-all  .
find first tt_price-all where tt_price-all.b-code = v-main-b-code use-index pi no-error .
    if available tt_price-all then do:
     assign
       vt-plt-id = tt_price-all.plt-id
       vt-plt-db = tt_price-all.plt-db-num
       vt-pdf-id = tt_price-all.pdf-id
       vt-pdf-db = tt_price-all.pdf-db
     .
     if tt_price-all.b-code = p-b-code then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = tt_price-all.price-sale
            .
     end.
     else do:
       find first neos_price-all where
                  neos_price-all.b-code     = p-b-code  and
                  neos_price-all.plt-id     = vt-plt-id and
                  neos_price-all.plt-db-num = vt-plt-db and
                  neos_price-all.pdf-id     = vt-pdf-id and
                  neos_price-all.pdf-db     = vt-pdf-db
                  use-index pi no-error .
         if available neos_price-all then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = neos_price-all.price-sale
            .
         end.
         else do:
        find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code no-error .
        if error-status :error    then do:
           message "Не найден бар-код" p-b-code view-as alert-box error .
           return error return-value .
        end.
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = tt_price-all.price-sale * buf_bar-code.cli-base-rate
            .
         end.
     end.
  end.
  end.
end procedure.
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-pos-type as character no-undo .
define variable v-current-pos-type-for-discnt as character no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-last-error-message as character no-undo .
define variable v-codex-id as integer   no-undo .
define variable v-ruleset-id as integer   no-undo .
define variable v-caller as character no-undo .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-error :
define input parameter p-mess as character no-undo .
  do
  on error undo, return error
  :
     assign
     v-last-error-message = p-mess.
  end.
end procedure.
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define temp-table temp-rule-by-call no-undo like ub.rule-by-call.
define temp-table temp-discnt-role no-undo like ub.dis-cfg-rule
field codex_id as integer
field ruleset_id as integer
field order_id as integer
field rule_id as integer
field once-more as integer
index pi is unique
primary
codex_id
ruleset_id
order_id
rule_id
pos-type
discnt-role
subject-type
.
on delete of this-procedure do:
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_temp-rule-by-call for temp-rule-by-call.
define buffer buf_temp-discnt-role for temp-discnt-role.
  for each buf_temp-rule-call-param:
    delete buf_temp-rule-call-param.
  end.
  for each buf_temp-rule-by-call:
    delete buf_temp-rule-by-call.
  end.
  for each buf_temp-discnt-role:
    delete buf_temp-discnt-role.
  end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_temp-call-param for temp-call-param.
for each buf_temp-call-param where
        buf_temp-call-param.param-num = 0:
  delete object buf_temp-call-param.call-handle_.
  delete buf_temp-call-param.
end.
  run garbcoll_clear in this-procedure .
end.
run load-ruleset-context in this-procedure no-error.
if error-status:error then do:
  undo, return error return-value .
end.
procedure rs_15_1 :
define input parameter p-caller as character no-undo .
define input parameter v-gline-num as integer   no-undo .
define input parameter v-b-code as integer   no-undo .
define input parameter v-gds-code as integer   no-undo .
define input parameter v-sum-grp-code as integer no-undo .
define input parameter v-node-code as integer no-undo .
define input parameter v-src-qnty as decimal no-undo .
define input parameter v-doc-qnty as decimal no-undo .
define input parameter v-start-src-price as decimal no-undo .
define input parameter v-src-price as decimal no-undo .
define input parameter v-start-src-discnt as decimal no-undo .
define input parameter v-src-discnt as decimal no-undo .
define input parameter v-unit-base as character no-undo .
define input parameter v-unit-base-type as character no-undo .
define input parameter v-unit-cli as character no-undo .
define input parameter v-unit-cli-type as character no-undo .
define input parameter v-bh as handle no-undo extent 6.
define output parameter v-new-src-price as decimal no-undo .
define output parameter v-new-src-discnt as decimal no-undo .
define buffer buf_temp-rule-by-call for temp-rule-by-call.
define buffer buf_temp-discnt-role for temp-discnt-role.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  assign
  v-codex-id = 15
  v-ruleset-id = 1
  v-caller = p-caller
  v-new-src-price = v-src-price
  v-new-src-discnt = v-src-discnt
  .
  for each buf_temp-rule-by-call where
            buf_temp-rule-by-call.call_id = p-call-id
        and buf_temp-rule-by-call.codex_id = v-codex-id
        and buf_temp-rule-by-call.ruleset_id = v-ruleset-id
        and buf_temp-rule-by-call.profile_id = p-profile-id
        and buf_temp-rule-by-call.once-more = p-once-more
  by buf_temp-rule-by-call.order
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if not (buf_temp-rule-by-call.can-calc and buf_temp-rule-by-call.can-run) then next.
    run value( substitute("r_15_1_&1", buf_temp-rule-by-call.rule_id)) in this-procedure (
              input buf_temp-rule-by-call.order_id
             ,input buf_temp-rule-by-call.rule_id
             ,input v-gline-num
             ,input v-b-code
             ,input v-gds-code
             ,input v-sum-grp-code
             ,input v-node-code
             ,input v-src-qnty
             ,input v-doc-qnty
             ,input v-start-src-price
             ,input v-src-price
             ,input v-start-src-discnt
             ,input v-src-discnt
             ,input v-unit-base
             ,input v-unit-base-type
             ,input v-unit-cli
             ,input v-unit-cli-type
             ,input v-bh
             ,output v-new-src-price
             ,output v-new-src-discnt
             ) no-error.
    if not error-status :error then do:
      assign
      v-src-price = v-new-src-price
      v-src-discnt = v-new-src-discnt
      .
    end.
  end.
end.
end procedure.
procedure r_15_1_1971:
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter v-gline-num as integer   no-undo .
define input parameter v-b-code as integer   no-undo .
define input parameter v-gds-code as integer   no-undo .
define input parameter v-sum-grp-code as integer no-undo .
define input parameter v-node-code as integer no-undo .
define input parameter v-src-qnty as decimal no-undo .
define input parameter v-doc-qnty as decimal no-undo .
define input parameter v-start-src-price as decimal no-undo .
define input parameter v-src-price as decimal no-undo .
define input parameter v-start-src-discnt as decimal no-undo .
define input parameter v-src-discnt as decimal no-undo .
define input parameter v-unit-base as character no-undo .
define input parameter v-unit-base-type as character no-undo .
define input parameter v-unit-cli as character no-undo .
define input parameter v-unit-cli-type as character no-undo .
define input parameter v-bh as handle no-undo extent 6.
define output parameter v-new-src-price as decimal no-undo .
define output parameter v-new-src-discnt as decimal no-undo .
define buffer buf_temp-rule-call-param for temp-rule-call-param.
 define variable p-discnt-roles as character no-undo.
 define variable p-add-discnts as logical no-undo.
 find first buf_temp-rule-call-param no-lock where
buf_temp-rule-call-param.codex_id = v-codex-id
and buf_temp-rule-call-param.ruleset_id = v-ruleset-id
and buf_temp-rule-call-param.call_id = p-call-id
and buf_temp-rule-call-param.order_id = p-order-id
and buf_temp-rule-call-param.rule_id = p-rule-id
and buf_temp-rule-call-param.param-name = "p-add-discnts"
 no-error.
if available buf_temp-rule-call-param then do:
assign p-add-discnts = buf_temp-rule-call-param.param-value-logical.
end.
_main:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-found as logical no-undo .
define variable v-discnt as decimal no-undo .
define variable v-rule-num as integer no-undo .
define variable v-nonunique as character no-undo .
define variable v-templ-rl-root as integer no-undo .
define variable v-cycle as integer   no-undo .
define variable v-for-gds-obj-type as character no-undo .
define variable v-for-gds-obj-code as integer   no-undo .
define variable v-for-host-code as integer   no-undo .
define variable v-for-obj-type as character no-undo .
define variable v-for-obj-code as integer   no-undo .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii as integer no-undo .
define buffer buf_temp-call-param for temp-call-param.
define buffer buf2_temp-call-param for temp-call-param.
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_chk-discnt  for ub.chk-discnt.
define buffer buf_temp-discnt-role for temp-discnt-role.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-grp-rule for ub.dis-grp-rule.
define buffer buf_dis-thbj-rule for ub.dis-thbj-rule.
assign
v-new-src-price = v-src-price
v-new-src-discnt = v-src-discnt
.
_roles:
for each buf_temp-rule-call-param where
      buf_temp-rule-call-param.call_id = p-call-id
  and buf_temp-rule-call-param.codex_id = v-codex-id
  and buf_temp-rule-call-param.ruleset_id = v-ruleset-id
  and buf_temp-rule-call-param.order_id = p-order-id
  and buf_temp-rule-call-param.rule_id = p-rule-id
  and buf_temp-rule-call-param.param-name = "p-discnt-roles"
  and buf_temp-rule-call-param.p-index > 0
  by buf_temp-rule-call-param.call_id
  by buf_temp-rule-call-param.codex_id
  by buf_temp-rule-call-param.ruleset_id
  by buf_temp-rule-call-param.order_id
  by buf_temp-rule-call-param.param-name
  by buf_temp-rule-call-param.p-index:
  if v-bh[4]:buffer-field("without-gds-discnt"):buffer-value > 0 then return.
  find first buf_temp-discnt-role where
            buf_temp-discnt-role.codex_id = v-codex-id
        and buf_temp-discnt-role.ruleset_id = v-ruleset-id
        and buf_temp-discnt-role.order_id = p-order-id
        and buf_temp-discnt-role.rule_id = p-rule-id
        and buf_temp-discnt-role.discnt-role = buf_temp-rule-call-param.param-value-character
        and buf_temp-discnt-role.subject-type = integer('1':U)
        no-error.
  if available buf_temp-discnt-role then do:
    _cycle:
    do v-cycle = 1 to 3 :
      if v-cycle = 1 then do:
        if buf_temp-discnt-role.has-obj = 1 then do:
          assign
          v-for-host-code = v-current-host-code
          v-for-obj-type = v-current-obj-type
          v-for-obj-code = v-current-obj-code
          v-for-gds-obj-type = v-current-obj-type
          v-for-gds-obj-code = v-current-obj-code
          .
        end.
        else do:
          next _cycle.
        end.
      end.
      if v-cycle = 2 then do:
        if buf_temp-discnt-role.has-host = 1 then do:
          assign
          v-for-host-code = v-current-host-code
          v-for-obj-type = ''
          v-for-obj-code = 0
          v-for-gds-obj-type = 'орг':U
          v-for-gds-obj-code = v-current-host-code
          .
        end.
        else do:
          next _cycle.
        end.
      end.
      if v-cycle = 3 then do:
        if buf_temp-discnt-role.has-glob = 1 then do:
          assign
          v-for-host-code = v-current-host-code
          v-for-obj-type = ''
          v-for-obj-code = 0
          v-for-gds-obj-type = ''
          v-for-gds-obj-code = 0
          .
        end.
        else do:
          next _cycle.
        end.
      end.
      case buf_temp-discnt-role.table-name:
        when 'dis-gds-rule':U then do:
          _dis-gds-rule:
          for each buf_dis-gds-rule no-lock where
                    buf_dis-gds-rule.obj-type = v-for-gds-obj-type
                and buf_dis-gds-rule.obj-code = v-for-gds-obj-code
                and buf_dis-gds-rule.gds-code = v-gds-code
                and buf_dis-gds-rule.discnt-role = buf_temp-discnt-role.discnt-role
                and buf_dis-gds-rule.pos-type = p-pos-type-for-discnt:
            assign
            v-rule-num = buf_dis-gds-rule.rule-num
            v-templ-rl-root = buf_dis-gds-rule.templ-rl-root
            v-nonunique = buf_Dis-gds-rule.nonunique
            .
            if lookup(buf_dis-gds-rule.discnt-role, 'pcnt-kat':U) > 0
            and (v-bh[2]:buffer-field("src-d-card"):buffer-value = ""
                 or
                 v-bh[2]:buffer-field("src-d-card"):buffer-value = ?)
            then next _dis-gds-rule.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(string(v-templ-rl-root), "1,2,3,5,6,8,9,28,36,48,49,56,76,77,84,85,88") > 0
then  do:
  v-bh[6]:buffer-create.
  v-bh[6]:buffer-copy(v-bh[3]).
  v-inversed-chr = "".
  assign
  v-bh[6]:buffer-field("record-type"):buffer-value = 0
  v-bh[6]:buffer-field("line-type"):buffer-value = integer('1':U)
  v-bh[6]:buffer-field("discnt-id"):buffer-value = v-bh[2]:buffer-field("discnt-id"):buffer-value + 1
  v-bh[2]:buffer-field("discnt-id"):buffer-value = v-bh[2]:buffer-field("discnt-id"):buffer-value + 1
  v-bh[6]:buffer-field("line-num"):buffer-value = v-bh[4]:buffer-field("line-num"):buffer-value
  v-bh[2]:buffer-field("lnd"):buffer-value  = v-bh[2]:buffer-field("lnd"):buffer-value + 1
  v-bh[6]:buffer-field("doc-code"):buffer-value = v-bh[3]:buffer-field("doc-code"):buffer-value
  v-bh[6]:buffer-field("pay-desk"):buffer-value = v-bh[3]:buffer-field("pay-desk"):buffer-value
  v-bh[6]:buffer-field("obj-type"):buffer-value = v-bh[3]:buffer-field("obj-type"):buffer-value
  v-bh[6]:buffer-field("obj-code"):buffer-value = v-bh[3]:buffer-field("obj-code"):buffer-value
  v-bh[6]:buffer-field("chk-date"):buffer-value = v-bh[3]:buffer-field("chk-date"):buffer-value
  v-bh[6]:buffer-field("chk-time"):buffer-value = v-bh[3]:buffer-field("chk-time"):buffer-value
  v-bh[6]:buffer-field("time-oper"):buffer-value = v-bh[4]:buffer-field("time-oper"):buffer-value
  v-bh[6]:buffer-field("src-d-card"):buffer-value = v-bh[3]:buffer-field("src-d-card"):buffer-value
  v-bh[6]:buffer-field("kateg"):buffer-value = v-bh[2]:buffer-field("category"):buffer-value
  v-bh[6]:buffer-field("rank"):buffer-value = buf_temp-rule-call-param.p-index
  v-bh[6]:buffer-field("pass-discnt"):buffer-value = integer('0':U)
  v-bh[6]:buffer-field("rule-num"):buffer-value = v-rule-num
  v-bh[6]:buffer-field("nonunique"):buffer-value = v-nonunique
  v-bh[6]:buffer-field("templ-rl-root"):buffer-value = v-templ-rl-root
  v-bh[6]:buffer-field("discnt-type"):buffer-value = buf_temp-discnt-role.discnt-type
  v-bh[6]:buffer-field("discnt-role"):buffer-value = buf_temp-discnt-role.discnt-role
  v-bh[6]:buffer-field("object-line-num"):buffer-value = v-bh[4]:buffer-field("line-num"):buffer-value
  v-bh[6]:buffer-field("object-qnty"):buffer-value = v-bh[4]:buffer-field("src-qnty"):buffer-value
  v-bh[6]:buffer-field("object-sum"):buffer-value = (v-src-price - v-src-discnt) * v-src-qnty
  .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable glog24 as logical no-undo .
find first buf_temp-call-param where
        buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
    and buf_temp-call-param.param-num = 0 no-error .
if not available buf_temp-call-param then do:
  if this-procedure:handle:get-signature(substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr )) = '':u then do:
    undo, return error substitute("Определение &1 отсутствует в &2"
                                   ,substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
                                   , this-procedure:handle:file-name).
  end.
  create buf_temp-call-param.
  assign
  buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
  buf_temp-call-param.param-number_ = 0
  v-ii = 0
  .
  for each buf_drt-prop no-lock where
          buf_drt-prop.templ-rl-root = v-templ-rl-root
      and buf_drt-prop.upper-prop-code = "Run-params" + v-inversed-chr
    on error  undo , return error substitute( "&1. &2&3&4", vss-include-info24,  return-value, chr(10), error-status :get-message (1))
    on stop   undo , return error substitute( "&1. stop", vss-include-info24 )
    on endkey undo , return error substitute( "&1. endkey", vss-include-info24 ):
    if integer(buf_drt-prop.prop-code) = 0 then do:
      assign
      buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
      buf_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      buf_temp-call-param.fld-df = entry(5, buf_drt-prop.property-value)
      .
      glog24 = p-dr-flddf:find-first( substitute(' where fld-df = &1&2&1', chr(34), buf_temp-call-param.fld-df, chr(34))) no-error.
      if p-dr-flddf:available = no then do:
        message
        substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf_temp-call-param.fld-df
                                      ,buf_temp-call-param.param-name_
                                      ,v-templ-rl-root)
        view-as alert-box error .
        undo, return error substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf_temp-call-param.fld-df
                                      ,buf_temp-call-param.param-name_
                                      ,v-templ-rl-root).
      end.
      assign
      buf_temp-call-param.field-name_ = p-dr-flddf::field-name_
      buf_temp-call-param.table-no = p-dr-flddf::table-no
      buf_temp-call-param.num-params = v-ii
      .
    end.
    else do:
      create buf2_temp-call-param.
      assign
      v-ii = v-ii + 1
      buf2_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
      buf2_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf2_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf2_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf2_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf2_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      buf2_temp-call-param.fld-df = entry(5, buf_drt-prop.property-value)
      .
      glog24 = p-dr-flddf:find-first( substitute(' where fld-df = &1&2&1', chr(34), buf2_temp-call-param.fld-df, chr(34))) no-error.
      if p-dr-flddf:available = no then do:
        message
        substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf2_temp-call-param.fld-df
                                      ,buf2_temp-call-param.param-name_
                                      ,v-templ-rl-root)
        view-as alert-box error .
        undo, return error substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf2_temp-call-param.fld-df
                                      ,buf2_temp-call-param.param-name_
                                      ,v-templ-rl-root).
      end.
      assign
      buf2_temp-call-param.field-name_ = p-dr-flddf::field-name_
      buf2_temp-call-param.table-no = p-dr-flddf::table-no
      .
    end.
  end.
  assign
  buf_temp-call-param.num-params = v-ii
  .
end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  find first buf_temp-call-param where
            buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
        and buf_temp-call-param.param-number = 0.
  if not valid-handle(buf_temp-call-param.call-handle_) then do:
    create call buf_temp-call-param.call-handle_.
    assign
    buf_temp-call-param.call-handle_:call-name = buf_temp-call-param.call-name_
    buf_temp-call-param.call-handle_:call-type = FUNCTION-CALL-TYPE
    buf_temp-call-param.call-handle_:in-handle = this-procedure:handle
    buf_temp-call-param.call-handle_:num-parameters = buf_temp-call-param.num-params
    .
  end.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable glog26 as logical   no-undo .
  define variable v-dt-tp26  as character no-undo .
  for each buf2_temp-call-param where
          buf2_temp-call-param.param-num > 0
      and buf2_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
  on error  undo , return error substitute( "&1. &2&3&4", vss-include-info26,  return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-include-info26 )
  on endkey undo , return error substitute( "&1. endkey", vss-include-info26 ):
      if v-bh[buf2_temp-call-param.table-no]:buffer-field(buf2_temp-call-param.field-name_):buffer-value = ? then
      do:
         case buf2_temp-call-param.param-datatype_:
            when "decimal"  or when "integer" then
            do:
    glog26 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,0
                                                    ).
            end.
            when "character" then
            do:
    glog26 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,""
                                                    ).
            end.
         end case .
      end.
      else
    glog26 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,v-bh[buf2_temp-call-param.table-no]:buffer-field(buf2_temp-call-param.field-name_):buffer-value
                                                    ).
  end.
  assign
  buf_temp-call-param.call-number = buf_temp-call-param.call-number + 1
  v-last-call-number = buf_temp-call-param.call-number
  v-last-call-name = buf_temp-call-param.call-name_
  .
  buf_temp-call-param.call-handle_:invoke.
    if buf_temp-call-param.call-handle_:return-value = ? then
    do:
       v-dt-tp26 = v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):data-type .
       if v-dt-tp26 = "decimal" or v-dt-tp26 = "integer" then
       do:
v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):buffer-value = 0 .
       end.
    end.
    else
    do:
  v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):buffer-value = buf_temp-call-param.call-handle_:return-value.
    end.
  if v-bh[6]:buffer-field("value-type"):buffer-value =  integer('1':U) then do:
    v-bh[6]:buffer-field("discnt-value-abs"):buffer-value =
              v-bh[6]:buffer-field("discnt-value-pcnt"):buffer-value *
              v-bh[6]:buffer-field("object-sum"):buffer-value / 100
              .
  end.
  else do:
    v-bh[6]:buffer-field("discnt-value-pcnt"):buffer-value =
              v-bh[6]:buffer-field("discnt-value-abs"):buffer-value /
              v-bh[6]:buffer-field("object-sum"):buffer-value * 100
              .
  end.
  assign
  v-src-price = v-bh[4]:buffer-field("src-price"):buffer-value
  v-discnt = v-bh[6]:buffer-field("delta-discnt"):buffer-value
  v-bh[4]:buffer-field("src-price-netto"):buffer-value = v-src-price - v-src-discnt
  v-src-discnt = v-src-discnt + v-discnt
  v-new-src-price = v-src-price
  v-new-src-discnt = v-src-discnt
  .
  if v-bh[6]:buffer-field("intended"):buffer-value = no
  and v-bh[6]:buffer-field("not-found"):buffer-value = no
  then do:
    create buf_chk-discnt.
    buffer buf_chk-discnt:handle:buffer-copy(v-bh[6]).
    run printbuffer in this-procedure ( input v-bh[6]).
    v-bh[6]:buffer-release().
    release buf_chk-discnt.
    v-found = yes.
  end.
  else do:
    v-bh[6]:buffer-delete().
    v-found = no.
  end.
end.
          end.
          if v-found then leave _cycle.
        end.
        when 'dis-grp-rule':U then do:
          _dis-grp-rule:
          for each buf_dis-grp-rule no-lock where
                   buf_dis-grp-rule.classif-type = 'sum-grp':U
                and buf_dis-grp-rule.host-code = v-for-host-code
                and buf_dis-grp-rule.obj-type = v-for-obj-type
                and buf_dis-grp-rule.obj-code = v-for-obj-code
                and buf_dis-grp-rule.node-code = v-sum-grp-code
                and buf_dis-grp-rule.discnt-role = buf_temp-discnt-role.discnt-role
                and buf_dis-grp-rule.pos-type = p-pos-type-for-discnt:
            assign
            v-rule-num = buf_dis-grp-rule.rule-num
            v-templ-rl-root = buf_dis-grp-rule.templ-rl-root
            v-nonunique = buf_Dis-grp-rule.nonunique
            .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(string(v-templ-rl-root), "1,2,3,5,6,8,9,28,36,48,49,56,76,77,84,85,88") > 0
then  do:
  v-bh[6]:buffer-create.
  v-bh[6]:buffer-copy(v-bh[3]).
  v-inversed-chr = "".
  assign
  v-bh[6]:buffer-field("record-type"):buffer-value = 0
  v-bh[6]:buffer-field("line-type"):buffer-value = integer('1':U)
  v-bh[6]:buffer-field("discnt-id"):buffer-value = v-bh[2]:buffer-field("discnt-id"):buffer-value + 1
  v-bh[2]:buffer-field("discnt-id"):buffer-value = v-bh[2]:buffer-field("discnt-id"):buffer-value + 1
  v-bh[6]:buffer-field("line-num"):buffer-value = v-bh[4]:buffer-field("line-num"):buffer-value
  v-bh[2]:buffer-field("lnd"):buffer-value  = v-bh[2]:buffer-field("lnd"):buffer-value + 1
  v-bh[6]:buffer-field("doc-code"):buffer-value = v-bh[3]:buffer-field("doc-code"):buffer-value
  v-bh[6]:buffer-field("pay-desk"):buffer-value = v-bh[3]:buffer-field("pay-desk"):buffer-value
  v-bh[6]:buffer-field("obj-type"):buffer-value = v-bh[3]:buffer-field("obj-type"):buffer-value
  v-bh[6]:buffer-field("obj-code"):buffer-value = v-bh[3]:buffer-field("obj-code"):buffer-value
  v-bh[6]:buffer-field("chk-date"):buffer-value = v-bh[3]:buffer-field("chk-date"):buffer-value
  v-bh[6]:buffer-field("chk-time"):buffer-value = v-bh[3]:buffer-field("chk-time"):buffer-value
  v-bh[6]:buffer-field("time-oper"):buffer-value = v-bh[4]:buffer-field("time-oper"):buffer-value
  v-bh[6]:buffer-field("src-d-card"):buffer-value = v-bh[3]:buffer-field("src-d-card"):buffer-value
  v-bh[6]:buffer-field("kateg"):buffer-value = v-bh[2]:buffer-field("category"):buffer-value
  v-bh[6]:buffer-field("rank"):buffer-value = buf_temp-rule-call-param.p-index
  v-bh[6]:buffer-field("pass-discnt"):buffer-value = integer('0':U)
  v-bh[6]:buffer-field("rule-num"):buffer-value = v-rule-num
  v-bh[6]:buffer-field("nonunique"):buffer-value = v-nonunique
  v-bh[6]:buffer-field("templ-rl-root"):buffer-value = v-templ-rl-root
  v-bh[6]:buffer-field("discnt-type"):buffer-value = buf_temp-discnt-role.discnt-type
  v-bh[6]:buffer-field("discnt-role"):buffer-value = buf_temp-discnt-role.discnt-role
  v-bh[6]:buffer-field("object-line-num"):buffer-value = v-bh[4]:buffer-field("line-num"):buffer-value
  v-bh[6]:buffer-field("object-qnty"):buffer-value = v-bh[4]:buffer-field("src-qnty"):buffer-value
  v-bh[6]:buffer-field("object-sum"):buffer-value = (v-src-price - v-src-discnt) * v-src-qnty
  .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable glog28 as logical no-undo .
find first buf_temp-call-param where
        buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
    and buf_temp-call-param.param-num = 0 no-error .
if not available buf_temp-call-param then do:
  if this-procedure:handle:get-signature(substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr )) = '':u then do:
    undo, return error substitute("Определение &1 отсутствует в &2"
                                   ,substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
                                   , this-procedure:handle:file-name).
  end.
  create buf_temp-call-param.
  assign
  buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
  buf_temp-call-param.param-number_ = 0
  v-ii = 0
  .
  for each buf_drt-prop no-lock where
          buf_drt-prop.templ-rl-root = v-templ-rl-root
      and buf_drt-prop.upper-prop-code = "Run-params" + v-inversed-chr
    on error  undo , return error substitute( "&1. &2&3&4", vss-include-info28,  return-value, chr(10), error-status :get-message (1))
    on stop   undo , return error substitute( "&1. stop", vss-include-info28 )
    on endkey undo , return error substitute( "&1. endkey", vss-include-info28 ):
    if integer(buf_drt-prop.prop-code) = 0 then do:
      assign
      buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
      buf_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      buf_temp-call-param.fld-df = entry(5, buf_drt-prop.property-value)
      .
      glog28 = p-dr-flddf:find-first( substitute(' where fld-df = &1&2&1', chr(34), buf_temp-call-param.fld-df, chr(34))) no-error.
      if p-dr-flddf:available = no then do:
        message
        substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf_temp-call-param.fld-df
                                      ,buf_temp-call-param.param-name_
                                      ,v-templ-rl-root)
        view-as alert-box error .
        undo, return error substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf_temp-call-param.fld-df
                                      ,buf_temp-call-param.param-name_
                                      ,v-templ-rl-root).
      end.
      assign
      buf_temp-call-param.field-name_ = p-dr-flddf::field-name_
      buf_temp-call-param.table-no = p-dr-flddf::table-no
      buf_temp-call-param.num-params = v-ii
      .
    end.
    else do:
      create buf2_temp-call-param.
      assign
      v-ii = v-ii + 1
      buf2_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
      buf2_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf2_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf2_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf2_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf2_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      buf2_temp-call-param.fld-df = entry(5, buf_drt-prop.property-value)
      .
      glog28 = p-dr-flddf:find-first( substitute(' where fld-df = &1&2&1', chr(34), buf2_temp-call-param.fld-df, chr(34))) no-error.
      if p-dr-flddf:available = no then do:
        message
        substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf2_temp-call-param.fld-df
                                      ,buf2_temp-call-param.param-name_
                                      ,v-templ-rl-root)
        view-as alert-box error .
        undo, return error substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf2_temp-call-param.fld-df
                                      ,buf2_temp-call-param.param-name_
                                      ,v-templ-rl-root).
      end.
      assign
      buf2_temp-call-param.field-name_ = p-dr-flddf::field-name_
      buf2_temp-call-param.table-no = p-dr-flddf::table-no
      .
    end.
  end.
  assign
  buf_temp-call-param.num-params = v-ii
  .
end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  find first buf_temp-call-param where
            buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
        and buf_temp-call-param.param-number = 0.
  if not valid-handle(buf_temp-call-param.call-handle_) then do:
    create call buf_temp-call-param.call-handle_.
    assign
    buf_temp-call-param.call-handle_:call-name = buf_temp-call-param.call-name_
    buf_temp-call-param.call-handle_:call-type = FUNCTION-CALL-TYPE
    buf_temp-call-param.call-handle_:in-handle = this-procedure:handle
    buf_temp-call-param.call-handle_:num-parameters = buf_temp-call-param.num-params
    .
  end.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable glog30 as logical   no-undo .
  define variable v-dt-tp30  as character no-undo .
  for each buf2_temp-call-param where
          buf2_temp-call-param.param-num > 0
      and buf2_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
  on error  undo , return error substitute( "&1. &2&3&4", vss-include-info30,  return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-include-info30 )
  on endkey undo , return error substitute( "&1. endkey", vss-include-info30 ):
      if v-bh[buf2_temp-call-param.table-no]:buffer-field(buf2_temp-call-param.field-name_):buffer-value = ? then
      do:
         case buf2_temp-call-param.param-datatype_:
            when "decimal"  or when "integer" then
            do:
    glog30 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,0
                                                    ).
            end.
            when "character" then
            do:
    glog30 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,""
                                                    ).
            end.
         end case .
      end.
      else
    glog30 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,v-bh[buf2_temp-call-param.table-no]:buffer-field(buf2_temp-call-param.field-name_):buffer-value
                                                    ).
  end.
  assign
  buf_temp-call-param.call-number = buf_temp-call-param.call-number + 1
  v-last-call-number = buf_temp-call-param.call-number
  v-last-call-name = buf_temp-call-param.call-name_
  .
  buf_temp-call-param.call-handle_:invoke.
    if buf_temp-call-param.call-handle_:return-value = ? then
    do:
       v-dt-tp30 = v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):data-type .
       if v-dt-tp30 = "decimal" or v-dt-tp30 = "integer" then
       do:
v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):buffer-value = 0 .
       end.
    end.
    else
    do:
  v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):buffer-value = buf_temp-call-param.call-handle_:return-value.
    end.
  if v-bh[6]:buffer-field("value-type"):buffer-value =  integer('1':U) then do:
    v-bh[6]:buffer-field("discnt-value-abs"):buffer-value =
              v-bh[6]:buffer-field("discnt-value-pcnt"):buffer-value *
              v-bh[6]:buffer-field("object-sum"):buffer-value / 100
              .
  end.
  else do:
    v-bh[6]:buffer-field("discnt-value-pcnt"):buffer-value =
              v-bh[6]:buffer-field("discnt-value-abs"):buffer-value /
              v-bh[6]:buffer-field("object-sum"):buffer-value * 100
              .
  end.
  assign
  v-src-price = v-bh[4]:buffer-field("src-price"):buffer-value
  v-discnt = v-bh[6]:buffer-field("delta-discnt"):buffer-value
  v-bh[4]:buffer-field("src-price-netto"):buffer-value = v-src-price - v-src-discnt
  v-src-discnt = v-src-discnt + v-discnt
  v-new-src-price = v-src-price
  v-new-src-discnt = v-src-discnt
  .
  if v-bh[6]:buffer-field("intended"):buffer-value = no
  and v-bh[6]:buffer-field("not-found"):buffer-value = no
  then do:
    create buf_chk-discnt.
    buffer buf_chk-discnt:handle:buffer-copy(v-bh[6]).
    run printbuffer in this-procedure ( input v-bh[6]).
    v-bh[6]:buffer-release().
    release buf_chk-discnt.
    v-found = yes.
  end.
  else do:
    v-bh[6]:buffer-delete().
    v-found = no.
  end.
end.
            if v-found then leave _cycle.
          end.
        end.
        when 'dis-dc-rule':U then do:
          case buf_temp-discnt-role.link-prop:
            when integer('-1':U) then do:
              assign
              v-rule-num = buf_temp-discnt-role.templ-rl-root
              v-found = (v-bh[2]:buffer-field("src-d-card"):buffer-value > ""
                         and
                         v-bh[2]:buffer-field("d-pcnt"):buffer-value <> 0
                         )
              v-templ-rl-root = buf_temp-discnt-role.templ-rl-root
              v-nonunique = ''
              .
              if v-found then do:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(string(v-templ-rl-root), "1,2,3,5,6,8,9,28,36,48,49,56,76,77,84,85,88") > 0
then  do:
  v-bh[6]:buffer-create.
  v-bh[6]:buffer-copy(v-bh[3]).
  v-inversed-chr = "".
  assign
  v-bh[6]:buffer-field("record-type"):buffer-value = 0
  v-bh[6]:buffer-field("line-type"):buffer-value = integer('1':U)
  v-bh[6]:buffer-field("discnt-id"):buffer-value = v-bh[2]:buffer-field("discnt-id"):buffer-value + 1
  v-bh[2]:buffer-field("discnt-id"):buffer-value = v-bh[2]:buffer-field("discnt-id"):buffer-value + 1
  v-bh[6]:buffer-field("line-num"):buffer-value = v-bh[4]:buffer-field("line-num"):buffer-value
  v-bh[2]:buffer-field("lnd"):buffer-value  = v-bh[2]:buffer-field("lnd"):buffer-value + 1
  v-bh[6]:buffer-field("doc-code"):buffer-value = v-bh[3]:buffer-field("doc-code"):buffer-value
  v-bh[6]:buffer-field("pay-desk"):buffer-value = v-bh[3]:buffer-field("pay-desk"):buffer-value
  v-bh[6]:buffer-field("obj-type"):buffer-value = v-bh[3]:buffer-field("obj-type"):buffer-value
  v-bh[6]:buffer-field("obj-code"):buffer-value = v-bh[3]:buffer-field("obj-code"):buffer-value
  v-bh[6]:buffer-field("chk-date"):buffer-value = v-bh[3]:buffer-field("chk-date"):buffer-value
  v-bh[6]:buffer-field("chk-time"):buffer-value = v-bh[3]:buffer-field("chk-time"):buffer-value
  v-bh[6]:buffer-field("time-oper"):buffer-value = v-bh[4]:buffer-field("time-oper"):buffer-value
  v-bh[6]:buffer-field("src-d-card"):buffer-value = v-bh[3]:buffer-field("src-d-card"):buffer-value
  v-bh[6]:buffer-field("kateg"):buffer-value = v-bh[2]:buffer-field("category"):buffer-value
  v-bh[6]:buffer-field("rank"):buffer-value = buf_temp-rule-call-param.p-index
  v-bh[6]:buffer-field("pass-discnt"):buffer-value = integer('0':U)
  v-bh[6]:buffer-field("rule-num"):buffer-value = v-rule-num
  v-bh[6]:buffer-field("nonunique"):buffer-value = v-nonunique
  v-bh[6]:buffer-field("templ-rl-root"):buffer-value = v-templ-rl-root
  v-bh[6]:buffer-field("discnt-type"):buffer-value = buf_temp-discnt-role.discnt-type
  v-bh[6]:buffer-field("discnt-role"):buffer-value = buf_temp-discnt-role.discnt-role
  v-bh[6]:buffer-field("object-line-num"):buffer-value = v-bh[4]:buffer-field("line-num"):buffer-value
  v-bh[6]:buffer-field("object-qnty"):buffer-value = v-bh[4]:buffer-field("src-qnty"):buffer-value
  v-bh[6]:buffer-field("object-sum"):buffer-value = (v-src-price - v-src-discnt) * v-src-qnty
  .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable glog32 as logical no-undo .
find first buf_temp-call-param where
        buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
    and buf_temp-call-param.param-num = 0 no-error .
if not available buf_temp-call-param then do:
  if this-procedure:handle:get-signature(substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr )) = '':u then do:
    undo, return error substitute("Определение &1 отсутствует в &2"
                                   ,substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
                                   , this-procedure:handle:file-name).
  end.
  create buf_temp-call-param.
  assign
  buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
  buf_temp-call-param.param-number_ = 0
  v-ii = 0
  .
  for each buf_drt-prop no-lock where
          buf_drt-prop.templ-rl-root = v-templ-rl-root
      and buf_drt-prop.upper-prop-code = "Run-params" + v-inversed-chr
    on error  undo , return error substitute( "&1. &2&3&4", vss-include-info32,  return-value, chr(10), error-status :get-message (1))
    on stop   undo , return error substitute( "&1. stop", vss-include-info32 )
    on endkey undo , return error substitute( "&1. endkey", vss-include-info32 ):
    if integer(buf_drt-prop.prop-code) = 0 then do:
      assign
      buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
      buf_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      buf_temp-call-param.fld-df = entry(5, buf_drt-prop.property-value)
      .
      glog32 = p-dr-flddf:find-first( substitute(' where fld-df = &1&2&1', chr(34), buf_temp-call-param.fld-df, chr(34))) no-error.
      if p-dr-flddf:available = no then do:
        message
        substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf_temp-call-param.fld-df
                                      ,buf_temp-call-param.param-name_
                                      ,v-templ-rl-root)
        view-as alert-box error .
        undo, return error substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf_temp-call-param.fld-df
                                      ,buf_temp-call-param.param-name_
                                      ,v-templ-rl-root).
      end.
      assign
      buf_temp-call-param.field-name_ = p-dr-flddf::field-name_
      buf_temp-call-param.table-no = p-dr-flddf::table-no
      buf_temp-call-param.num-params = v-ii
      .
    end.
    else do:
      create buf2_temp-call-param.
      assign
      v-ii = v-ii + 1
      buf2_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
      buf2_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf2_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf2_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf2_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf2_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      buf2_temp-call-param.fld-df = entry(5, buf_drt-prop.property-value)
      .
      glog32 = p-dr-flddf:find-first( substitute(' where fld-df = &1&2&1', chr(34), buf2_temp-call-param.fld-df, chr(34))) no-error.
      if p-dr-flddf:available = no then do:
        message
        substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf2_temp-call-param.fld-df
                                      ,buf2_temp-call-param.param-name_
                                      ,v-templ-rl-root)
        view-as alert-box error .
        undo, return error substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf2_temp-call-param.fld-df
                                      ,buf2_temp-call-param.param-name_
                                      ,v-templ-rl-root).
      end.
      assign
      buf2_temp-call-param.field-name_ = p-dr-flddf::field-name_
      buf2_temp-call-param.table-no = p-dr-flddf::table-no
      .
    end.
  end.
  assign
  buf_temp-call-param.num-params = v-ii
  .
end.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  find first buf_temp-call-param where
            buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
        and buf_temp-call-param.param-number = 0.
  if not valid-handle(buf_temp-call-param.call-handle_) then do:
    create call buf_temp-call-param.call-handle_.
    assign
    buf_temp-call-param.call-handle_:call-name = buf_temp-call-param.call-name_
    buf_temp-call-param.call-handle_:call-type = FUNCTION-CALL-TYPE
    buf_temp-call-param.call-handle_:in-handle = this-procedure:handle
    buf_temp-call-param.call-handle_:num-parameters = buf_temp-call-param.num-params
    .
  end.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable glog34 as logical   no-undo .
  define variable v-dt-tp34  as character no-undo .
  for each buf2_temp-call-param where
          buf2_temp-call-param.param-num > 0
      and buf2_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
  on error  undo , return error substitute( "&1. &2&3&4", vss-include-info34,  return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-include-info34 )
  on endkey undo , return error substitute( "&1. endkey", vss-include-info34 ):
      if v-bh[buf2_temp-call-param.table-no]:buffer-field(buf2_temp-call-param.field-name_):buffer-value = ? then
      do:
         case buf2_temp-call-param.param-datatype_:
            when "decimal"  or when "integer" then
            do:
    glog34 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,0
                                                    ).
            end.
            when "character" then
            do:
    glog34 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,""
                                                    ).
            end.
         end case .
      end.
      else
    glog34 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,v-bh[buf2_temp-call-param.table-no]:buffer-field(buf2_temp-call-param.field-name_):buffer-value
                                                    ).
  end.
  assign
  buf_temp-call-param.call-number = buf_temp-call-param.call-number + 1
  v-last-call-number = buf_temp-call-param.call-number
  v-last-call-name = buf_temp-call-param.call-name_
  .
  buf_temp-call-param.call-handle_:invoke.
    if buf_temp-call-param.call-handle_:return-value = ? then
    do:
       v-dt-tp34 = v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):data-type .
       if v-dt-tp34 = "decimal" or v-dt-tp34 = "integer" then
       do:
v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):buffer-value = 0 .
       end.
    end.
    else
    do:
  v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):buffer-value = buf_temp-call-param.call-handle_:return-value.
    end.
  if v-bh[6]:buffer-field("value-type"):buffer-value =  integer('1':U) then do:
    v-bh[6]:buffer-field("discnt-value-abs"):buffer-value =
              v-bh[6]:buffer-field("discnt-value-pcnt"):buffer-value *
              v-bh[6]:buffer-field("object-sum"):buffer-value / 100
              .
  end.
  else do:
    v-bh[6]:buffer-field("discnt-value-pcnt"):buffer-value =
              v-bh[6]:buffer-field("discnt-value-abs"):buffer-value /
              v-bh[6]:buffer-field("object-sum"):buffer-value * 100
              .
  end.
  assign
  v-src-price = v-bh[4]:buffer-field("src-price"):buffer-value
  v-discnt = v-bh[6]:buffer-field("delta-discnt"):buffer-value
  v-bh[4]:buffer-field("src-price-netto"):buffer-value = v-src-price - v-src-discnt
  v-src-discnt = v-src-discnt + v-discnt
  v-new-src-price = v-src-price
  v-new-src-discnt = v-src-discnt
  .
  if v-bh[6]:buffer-field("intended"):buffer-value = no
  and v-bh[6]:buffer-field("not-found"):buffer-value = no
  then do:
    create buf_chk-discnt.
    buffer buf_chk-discnt:handle:buffer-copy(v-bh[6]).
    run printbuffer in this-procedure ( input v-bh[6]).
    v-bh[6]:buffer-release().
    release buf_chk-discnt.
    v-found = yes.
  end.
  else do:
    v-bh[6]:buffer-delete().
    v-found = no.
  end.
end.
              end.
              if v-found then leave _cycle.
            end.
          end case.
        end.
        when 'dis-thbj-rule':U then do:
          _dis-thbj-rule:
          for each buf_dis-thbj-rule no-lock where
                    buf_dis-thbj-rule.obj-type = v-for-gds-obj-type
                and buf_dis-thbj-rule.obj-code = v-for-gds-obj-code
                and buf_dis-thbj-rule.discnt-role = buf_temp-discnt-role.discnt-role
                and buf_dis-thbj-rule.pos-type = p-pos-type-for-discnt:
            case buf_temp-discnt-role.link-prop:
              when integer('0':U) then do:
                assign
                v-rule-num = buf_dis-thbj-rule.rule-num
                v-templ-rl-root = buf_dis-thbj-rule.templ-rl-root
                v-nonunique = buf_Dis-thbj-rule.nonunique
                .
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(string(v-templ-rl-root), "1,2,3,5,6,8,9,28,36,48,49,56,76,77,84,85,88") > 0
then  do:
  v-bh[6]:buffer-create.
  v-bh[6]:buffer-copy(v-bh[3]).
  v-inversed-chr = "".
  assign
  v-bh[6]:buffer-field("record-type"):buffer-value = 0
  v-bh[6]:buffer-field("line-type"):buffer-value = integer('1':U)
  v-bh[6]:buffer-field("discnt-id"):buffer-value = v-bh[2]:buffer-field("discnt-id"):buffer-value + 1
  v-bh[2]:buffer-field("discnt-id"):buffer-value = v-bh[2]:buffer-field("discnt-id"):buffer-value + 1
  v-bh[6]:buffer-field("line-num"):buffer-value = v-bh[4]:buffer-field("line-num"):buffer-value
  v-bh[2]:buffer-field("lnd"):buffer-value  = v-bh[2]:buffer-field("lnd"):buffer-value + 1
  v-bh[6]:buffer-field("doc-code"):buffer-value = v-bh[3]:buffer-field("doc-code"):buffer-value
  v-bh[6]:buffer-field("pay-desk"):buffer-value = v-bh[3]:buffer-field("pay-desk"):buffer-value
  v-bh[6]:buffer-field("obj-type"):buffer-value = v-bh[3]:buffer-field("obj-type"):buffer-value
  v-bh[6]:buffer-field("obj-code"):buffer-value = v-bh[3]:buffer-field("obj-code"):buffer-value
  v-bh[6]:buffer-field("chk-date"):buffer-value = v-bh[3]:buffer-field("chk-date"):buffer-value
  v-bh[6]:buffer-field("chk-time"):buffer-value = v-bh[3]:buffer-field("chk-time"):buffer-value
  v-bh[6]:buffer-field("time-oper"):buffer-value = v-bh[4]:buffer-field("time-oper"):buffer-value
  v-bh[6]:buffer-field("src-d-card"):buffer-value = v-bh[3]:buffer-field("src-d-card"):buffer-value
  v-bh[6]:buffer-field("kateg"):buffer-value = v-bh[2]:buffer-field("category"):buffer-value
  v-bh[6]:buffer-field("rank"):buffer-value = buf_temp-rule-call-param.p-index
  v-bh[6]:buffer-field("pass-discnt"):buffer-value = integer('0':U)
  v-bh[6]:buffer-field("rule-num"):buffer-value = v-rule-num
  v-bh[6]:buffer-field("nonunique"):buffer-value = v-nonunique
  v-bh[6]:buffer-field("templ-rl-root"):buffer-value = v-templ-rl-root
  v-bh[6]:buffer-field("discnt-type"):buffer-value = buf_temp-discnt-role.discnt-type
  v-bh[6]:buffer-field("discnt-role"):buffer-value = buf_temp-discnt-role.discnt-role
  v-bh[6]:buffer-field("object-line-num"):buffer-value = v-bh[4]:buffer-field("line-num"):buffer-value
  v-bh[6]:buffer-field("object-qnty"):buffer-value = v-bh[4]:buffer-field("src-qnty"):buffer-value
  v-bh[6]:buffer-field("object-sum"):buffer-value = (v-src-price - v-src-discnt) * v-src-qnty
  .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable glog36 as logical no-undo .
find first buf_temp-call-param where
        buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
    and buf_temp-call-param.param-num = 0 no-error .
if not available buf_temp-call-param then do:
  if this-procedure:handle:get-signature(substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr )) = '':u then do:
    undo, return error substitute("Определение &1 отсутствует в &2"
                                   ,substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
                                   , this-procedure:handle:file-name).
  end.
  create buf_temp-call-param.
  assign
  buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
  buf_temp-call-param.param-number_ = 0
  v-ii = 0
  .
  for each buf_drt-prop no-lock where
          buf_drt-prop.templ-rl-root = v-templ-rl-root
      and buf_drt-prop.upper-prop-code = "Run-params" + v-inversed-chr
    on error  undo , return error substitute( "&1. &2&3&4", vss-include-info36,  return-value, chr(10), error-status :get-message (1))
    on stop   undo , return error substitute( "&1. stop", vss-include-info36 )
    on endkey undo , return error substitute( "&1. endkey", vss-include-info36 ):
    if integer(buf_drt-prop.prop-code) = 0 then do:
      assign
      buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
      buf_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      buf_temp-call-param.fld-df = entry(5, buf_drt-prop.property-value)
      .
      glog36 = p-dr-flddf:find-first( substitute(' where fld-df = &1&2&1', chr(34), buf_temp-call-param.fld-df, chr(34))) no-error.
      if p-dr-flddf:available = no then do:
        message
        substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf_temp-call-param.fld-df
                                      ,buf_temp-call-param.param-name_
                                      ,v-templ-rl-root)
        view-as alert-box error .
        undo, return error substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf_temp-call-param.fld-df
                                      ,buf_temp-call-param.param-name_
                                      ,v-templ-rl-root).
      end.
      assign
      buf_temp-call-param.field-name_ = p-dr-flddf::field-name_
      buf_temp-call-param.table-no = p-dr-flddf::table-no
      buf_temp-call-param.num-params = v-ii
      .
    end.
    else do:
      create buf2_temp-call-param.
      assign
      v-ii = v-ii + 1
      buf2_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
      buf2_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf2_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf2_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf2_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf2_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      buf2_temp-call-param.fld-df = entry(5, buf_drt-prop.property-value)
      .
      glog36 = p-dr-flddf:find-first( substitute(' where fld-df = &1&2&1', chr(34), buf2_temp-call-param.fld-df, chr(34))) no-error.
      if p-dr-flddf:available = no then do:
        message
        substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf2_temp-call-param.fld-df
                                      ,buf2_temp-call-param.param-name_
                                      ,v-templ-rl-root)
        view-as alert-box error .
        undo, return error substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf2_temp-call-param.fld-df
                                      ,buf2_temp-call-param.param-name_
                                      ,v-templ-rl-root).
      end.
      assign
      buf2_temp-call-param.field-name_ = p-dr-flddf::field-name_
      buf2_temp-call-param.table-no = p-dr-flddf::table-no
      .
    end.
  end.
  assign
  buf_temp-call-param.num-params = v-ii
  .
end.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  find first buf_temp-call-param where
            buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
        and buf_temp-call-param.param-number = 0.
  if not valid-handle(buf_temp-call-param.call-handle_) then do:
    create call buf_temp-call-param.call-handle_.
    assign
    buf_temp-call-param.call-handle_:call-name = buf_temp-call-param.call-name_
    buf_temp-call-param.call-handle_:call-type = FUNCTION-CALL-TYPE
    buf_temp-call-param.call-handle_:in-handle = this-procedure:handle
    buf_temp-call-param.call-handle_:num-parameters = buf_temp-call-param.num-params
    .
  end.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable glog38 as logical   no-undo .
  define variable v-dt-tp38  as character no-undo .
  for each buf2_temp-call-param where
          buf2_temp-call-param.param-num > 0
      and buf2_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
  on error  undo , return error substitute( "&1. &2&3&4", vss-include-info38,  return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-include-info38 )
  on endkey undo , return error substitute( "&1. endkey", vss-include-info38 ):
      if v-bh[buf2_temp-call-param.table-no]:buffer-field(buf2_temp-call-param.field-name_):buffer-value = ? then
      do:
         case buf2_temp-call-param.param-datatype_:
            when "decimal"  or when "integer" then
            do:
    glog38 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,0
                                                    ).
            end.
            when "character" then
            do:
    glog38 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,""
                                                    ).
            end.
         end case .
      end.
      else
    glog38 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,v-bh[buf2_temp-call-param.table-no]:buffer-field(buf2_temp-call-param.field-name_):buffer-value
                                                    ).
  end.
  assign
  buf_temp-call-param.call-number = buf_temp-call-param.call-number + 1
  v-last-call-number = buf_temp-call-param.call-number
  v-last-call-name = buf_temp-call-param.call-name_
  .
  buf_temp-call-param.call-handle_:invoke.
    if buf_temp-call-param.call-handle_:return-value = ? then
    do:
       v-dt-tp38 = v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):data-type .
       if v-dt-tp38 = "decimal" or v-dt-tp38 = "integer" then
       do:
v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):buffer-value = 0 .
       end.
    end.
    else
    do:
  v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):buffer-value = buf_temp-call-param.call-handle_:return-value.
    end.
  if v-bh[6]:buffer-field("value-type"):buffer-value =  integer('1':U) then do:
    v-bh[6]:buffer-field("discnt-value-abs"):buffer-value =
              v-bh[6]:buffer-field("discnt-value-pcnt"):buffer-value *
              v-bh[6]:buffer-field("object-sum"):buffer-value / 100
              .
  end.
  else do:
    v-bh[6]:buffer-field("discnt-value-pcnt"):buffer-value =
              v-bh[6]:buffer-field("discnt-value-abs"):buffer-value /
              v-bh[6]:buffer-field("object-sum"):buffer-value * 100
              .
  end.
  assign
  v-src-price = v-bh[4]:buffer-field("src-price"):buffer-value
  v-discnt = v-bh[6]:buffer-field("delta-discnt"):buffer-value
  v-bh[4]:buffer-field("src-price-netto"):buffer-value = v-src-price - v-src-discnt
  v-src-discnt = v-src-discnt + v-discnt
  v-new-src-price = v-src-price
  v-new-src-discnt = v-src-discnt
  .
  if v-bh[6]:buffer-field("intended"):buffer-value = no
  and v-bh[6]:buffer-field("not-found"):buffer-value = no
  then do:
    create buf_chk-discnt.
    buffer buf_chk-discnt:handle:buffer-copy(v-bh[6]).
    run printbuffer in this-procedure ( input v-bh[6]).
    v-bh[6]:buffer-release().
    release buf_chk-discnt.
    v-found = yes.
  end.
  else do:
    v-bh[6]:buffer-delete().
    v-found = no.
  end.
end.
              end.
            end case.
            if v-found then leave _cycle.
          end.
          if v-found then leave _cycle.
        end.
      end case.
    end.
    if v-found and not p-add-discnts then do:
      leave _roles.
    end.
  end.
end.
end.
end procedure.
procedure rs_16_1 :
define input parameter p-caller as character no-undo .
define input parameter v-line-nums as integer   no-undo .
define input parameter v-start-sum-brutto-r-b as decimal no-undo .
define input parameter v-sum-brutto-r-b as decimal no-undo .
define input parameter v-sum-for-discnt-r-b as decimal no-undo .
define input parameter v-st-discnt-r-b as decimal no-undo .
define input parameter v-bh as handle no-undo extent 6.
define output parameter v-st-r-b as decimal no-undo .
define output parameter v-new-st-discnt-r-b as decimal no-undo .
define output parameter v-new-sum-for-discnt-r-b as decimal no-undo .
define buffer buf_temp-rule-by-call for temp-rule-by-call.
define buffer buf_temp-discnt-role for temp-discnt-role.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  assign
  v-codex-id = 16
  v-ruleset-id = 1
  v-caller = p-caller
  .
  assign
  v-st-r-b  = v-sum-brutto-r-b
  v-new-st-discnt-r-b  = v-st-discnt-r-b
  .
  for each buf_temp-rule-by-call where
            buf_temp-rule-by-call.call_id = p-call-id
        and buf_temp-rule-by-call.codex_id = v-codex-id
        and buf_temp-rule-by-call.ruleset_id = v-ruleset-id
        and buf_temp-rule-by-call.profile_id = p-profile-id
        and buf_temp-rule-by-call.once-more = p-once-more
  by buf_temp-rule-by-call.order
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if not (buf_temp-rule-by-call.can-calc and buf_temp-rule-by-call.can-run) then next.
    run value( substitute("r_16_1_&1", buf_temp-rule-by-call.rule_id)) in this-procedure (
              input buf_temp-rule-by-call.order_id
             ,input buf_temp-rule-by-call.rule_id
             ,input v-line-nums
             ,input v-start-sum-brutto-r-b
             ,input v-sum-brutto-r-b
             ,input v-sum-for-discnt-r-b
             ,input v-st-discnt-r-b
             ,input v-bh
             ,output v-st-r-b
             ,output v-new-st-discnt-r-b
             ,output v-new-sum-for-discnt-r-b
             ) no-error.
    if not error-status :error then do:
      assign
      v-sum-brutto-r-b  = v-st-r-b
      v-st-discnt-r-b  = v-new-st-discnt-r-b
      .
    end.
  end.
end.
end procedure.
procedure r_16_1_1972:
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter v-line-nums as integer   no-undo .
define input parameter v-start-sum-brutto-r-b as decimal no-undo .
define input parameter v-sum-brutto-r-b as decimal no-undo .
define input parameter v-sum-for-discnt-r-b as decimal no-undo .
define input parameter v-st-discnt-r-b as decimal no-undo .
define input parameter v-bh as handle no-undo extent 6.
define output parameter v-st-r-b as decimal no-undo .
define output parameter v-new-st-discnt-r-b as decimal no-undo .
define output parameter v-new-sum-for-discnt-r-b as decimal no-undo .
define buffer buf_temp-rule-call-param for temp-rule-call-param.
 define variable p-discnt-roles as character no-undo.
 define variable p-add-discnts as logical no-undo.
 find first buf_temp-rule-call-param no-lock where
buf_temp-rule-call-param.codex_id = v-codex-id
and buf_temp-rule-call-param.ruleset_id = v-ruleset-id
and buf_temp-rule-call-param.call_id = p-call-id
and buf_temp-rule-call-param.order_id = p-order-id
and buf_temp-rule-call-param.rule_id = p-rule-id
and buf_temp-rule-call-param.param-name = "p-add-discnts"
 no-error.
if available buf_temp-rule-call-param then do:
assign p-add-discnts = buf_temp-rule-call-param.param-value-logical.
end.
_main:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-found as logical no-undo .
define variable v-discnt as decimal no-undo .
define variable v-rule-num as integer no-undo .
define variable v-templ-rl-root as integer no-undo .
define variable v-cycle as integer   no-undo .
define variable v-for-gds-obj-type as character no-undo .
define variable v-for-gds-obj-code as integer   no-undo .
define variable v-for-host-code as integer   no-undo .
define variable v-for-obj-type as character no-undo .
define variable v-for-obj-code as integer   no-undo .
define variable v-qh as handle no-undo .
define variable v-line-type as integer   no-undo .
define variable v-ok as logical   no-undo .
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii as integer no-undo .
define buffer buf_temp-call-param for temp-call-param.
define buffer buf2_temp-call-param for temp-call-param.
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_chk-discnt  for ub.chk-discnt.
define buffer buf_temp-discnt-role for temp-discnt-role.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-thbj-rule for ub.dis-thbj-rule.
assign
v-st-r-b = v-sum-brutto-r-b
v-new-st-discnt-r-b = v-st-discnt-r-b
v-new-st-discnt-r-b = v-st-discnt-r-b
v-new-sum-for-discnt-r-b = v-sum-for-discnt-r-b
.
_roles:
for each buf_temp-rule-call-param where
      buf_temp-rule-call-param.call_id = p-call-id
  and buf_temp-rule-call-param.codex_id = v-codex-id
  and buf_temp-rule-call-param.ruleset_id = v-ruleset-id
  and buf_temp-rule-call-param.order_id = p-order-id
  and buf_temp-rule-call-param.rule_id = p-rule-id
  and buf_temp-rule-call-param.param-name = "p-discnt-roles"
  and buf_temp-rule-call-param.p-index > 0
  by buf_temp-rule-call-param.call_id
  by buf_temp-rule-call-param.codex_id
  by buf_temp-rule-call-param.ruleset_id
  by buf_temp-rule-call-param.order_id
  by buf_temp-rule-call-param.param-name
  by buf_temp-rule-call-param.p-index:
  find first buf_temp-discnt-role where
            buf_temp-discnt-role.codex_id = v-codex-id
        and buf_temp-discnt-role.ruleset_id = v-ruleset-id
        and buf_temp-discnt-role.order_id = p-order-id
        and buf_temp-discnt-role.rule_id = p-rule-id
        and buf_temp-discnt-role.discnt-role = buf_temp-rule-call-param.param-value-character
        and buf_temp-discnt-role.subject-type = integer('2':U)
        no-error.
  if available buf_temp-discnt-role then do:
    _cycle:
    do v-cycle = 1 to 3 :
      if v-cycle = 1 then do:
        if buf_temp-discnt-role.has-obj = 1 then do:
          assign
          v-for-host-code = v-current-host-code
          v-for-obj-type = v-current-obj-type
          v-for-obj-code = v-current-obj-code
          v-for-gds-obj-type = v-current-obj-type
          v-for-gds-obj-code = v-current-obj-code
          .
        end.
        else do:
          next _cycle.
        end.
      end.
      if v-cycle = 2 then do:
        if buf_temp-discnt-role.has-host = 1 then do:
          assign
          v-for-host-code = v-current-host-code
          v-for-obj-type = ''
          v-for-obj-code = 0
          v-for-gds-obj-type = 'орг':U
          v-for-gds-obj-code = v-current-host-code
          .
        end.
        else do:
          next _cycle.
        end.
      end.
      if v-cycle = 3 then do:
        if buf_temp-discnt-role.has-glob = 1 then do:
          assign
          v-for-obj-type = ''
          v-for-obj-code = 0
          v-for-host-code = 0
          v-for-gds-obj-type = ''
          v-for-gds-obj-code = 0
          .
        end.
        else do:
          next _cycle.
        end.
      end.
      case buf_temp-discnt-role.table-name:
        when 'dis-gds-rule':U then do:
          case buf_temp-discnt-role.discnt-role:
            when 'without-disc':U then do:
              v-line-type = integer('7':U).
            end.
            otherwise do:
              v-line-type = integer('2':U).
            end.
          end.
          create query v-qh.
          v-ok = v-qh:set-buffers(v-bh[4], (buffer buf_dis-gds-rule:handle)).
          v-ok = v-qh:QUERY-PREPARE(
                                    substitute('FOR EACH libthpos_chk-gds WHERE libthpos_chk-gds.doc-code = "&1", ' +
                                              'first buf_dis-gds-rule no-lock where buf_dis-gds-rule.gds-code = libthpos_chk-gds.gds-code ' +
                                              ' and  buf_dis-gds-rule.obj-type = "&2" ' +
                                              ' and buf_dis-gds-rule.obj-code = &3 ' +
                                              ' and buf_dis-gds-rule.discnt-role = "&4" ' +
                                              ' and buf_dis-gds-rule.pos-type = "&5" '
                                                                                      ,v-bh[2]:buffer-field("doc-code"):buffer-value
                                                                                      ,v-for-gds-obj-type
                                                                                      ,v-for-gds-obj-code
                                                                                      ,buf_temp-discnt-role.discnt-role
                                                                                      ,p-pos-type-for-discnt)).
          v-qh:QUERY-OPEN.
          _repeat:
          REPEAT :
            v-qh:GET-NEXT().
            IF v-qh:QUERY-OFF-END THEN LEAVE.
            assign
            v-rule-num = buf_dis-gds-rule.rule-num
            v-templ-rl-root = buf_dis-gds-rule.templ-rl-root
            .
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(string(v-templ-rl-root), "20,54,55,78") > 0
then  do:
  v-bh[6]:buffer-create.
  v-bh[6]:buffer-copy(v-bh[3]).
  v-inversed-chr =  "".
  assign
  v-bh[6]:buffer-field("record-type"):buffer-value = 0
  v-bh[6]:buffer-field("line-type"):buffer-value = v-line-type
  v-bh[6]:buffer-field("discnt-id"):buffer-value = v-bh[2]:buffer-field("discnt-id"):buffer-value + 1
  v-bh[2]:buffer-field("discnt-id"):buffer-value = v-bh[2]:buffer-field("discnt-id"):buffer-value + 1
  v-bh[6]:buffer-field("line-num"):buffer-value = (if buf_temp-discnt-role.table-name = 'dis-gds-rule':U
                                                              then v-bh[4]:buffer-field("line-num"):buffer-value
                                                              else v-bh[2]:buffer-field("lng"):buffer-value)
  v-bh[2]:buffer-field("lnd"):buffer-value  = v-bh[2]:buffer-field("lnd"):buffer-value + 1
  v-bh[6]:buffer-field("doc-code"):buffer-value = v-bh[3]:buffer-field("doc-code"):buffer-value
  v-bh[6]:buffer-field("pay-desk"):buffer-value = v-bh[3]:buffer-field("pay-desk"):buffer-value
  v-bh[6]:buffer-field("obj-type"):buffer-value = v-bh[3]:buffer-field("obj-type"):buffer-value
  v-bh[6]:buffer-field("obj-code"):buffer-value = v-bh[3]:buffer-field("obj-code"):buffer-value
  v-bh[6]:buffer-field("chk-date"):buffer-value = v-bh[3]:buffer-field("chk-date"):buffer-value
  v-bh[6]:buffer-field("chk-time"):buffer-value = v-bh[3]:buffer-field("chk-time"):buffer-value
  v-bh[6]:buffer-field("time-oper"):buffer-value = v-bh[2]:buffer-field("current-time"):buffer-value
  v-bh[6]:buffer-field("src-d-card"):buffer-value = v-bh[3]:buffer-field("src-d-card"):buffer-value
  v-bh[6]:buffer-field("kateg"):buffer-value = v-bh[2]:buffer-field("category"):buffer-value
  v-bh[6]:buffer-field("rank"):buffer-value = buf_temp-rule-call-param.p-index
  v-bh[6]:buffer-field("pass-discnt"):buffer-value = integer('0':U)
  v-bh[6]:buffer-field("rule-num"):buffer-value = v-rule-num
  v-bh[6]:buffer-field("templ-rl-root"):buffer-value = v-templ-rl-root
  v-bh[6]:buffer-field("discnt-type"):buffer-value = buf_temp-discnt-role.discnt-type
  v-bh[6]:buffer-field("discnt-role"):buffer-value = buf_temp-discnt-role.discnt-role
  v-bh[6]:buffer-field("object-line-num"):buffer-value = (if buf_temp-discnt-role.table-name = 'dis-gds-rule':U
                                                                      then v-bh[4]:buffer-field("line-num"):buffer-value
                                                                      else v-bh[2]:buffer-field("lnd"):buffer-value
                                                                      )
  v-bh[6]:buffer-field("object-qnty"):buffer-value = (if buf_temp-discnt-role.table-name = 'dis-gds-rule':U
                                                                  then v-bh[4]:buffer-field("src-qnty"):buffer-value
                                                                  else v-bh[2]:buffer-field("src-qnty"):buffer-value)
  v-bh[6]:buffer-field("object-sum"):buffer-value = (if buf_temp-discnt-role.table-name = 'dis-gds-rule':U
                                                                 then (v-bh[4]:buffer-field("src-price-netto"):buffer-value +
                                                                       v-bh[4]:buffer-field("src-qnty"):buffer-value
                                                                       )
                                                                 else v-bh[2]:buffer-field("st-for-discnt-r-b"):buffer-value)
  .
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable glog42 as logical no-undo .
find first buf_temp-call-param where
        buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
    and buf_temp-call-param.param-num = 0 no-error .
if not available buf_temp-call-param then do:
  if this-procedure:handle:get-signature(substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr )) = '':u then do:
    undo, return error substitute("Определение &1 отсутствует в &2"
                                   ,substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
                                   , this-procedure:handle:file-name).
  end.
  create buf_temp-call-param.
  assign
  buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
  buf_temp-call-param.param-number_ = 0
  v-ii = 0
  .
  for each buf_drt-prop no-lock where
          buf_drt-prop.templ-rl-root = v-templ-rl-root
      and buf_drt-prop.upper-prop-code = "Run-params" + v-inversed-chr
    on error  undo , return error substitute( "&1. &2&3&4", vss-include-info42,  return-value, chr(10), error-status :get-message (1))
    on stop   undo , return error substitute( "&1. stop", vss-include-info42 )
    on endkey undo , return error substitute( "&1. endkey", vss-include-info42 ):
    if integer(buf_drt-prop.prop-code) = 0 then do:
      assign
      buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
      buf_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      buf_temp-call-param.fld-df = entry(5, buf_drt-prop.property-value)
      .
      glog42 = p-dr-flddf:find-first( substitute(' where fld-df = &1&2&1', chr(34), buf_temp-call-param.fld-df, chr(34))) no-error.
      if p-dr-flddf:available = no then do:
        message
        substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf_temp-call-param.fld-df
                                      ,buf_temp-call-param.param-name_
                                      ,v-templ-rl-root)
        view-as alert-box error .
        undo, return error substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf_temp-call-param.fld-df
                                      ,buf_temp-call-param.param-name_
                                      ,v-templ-rl-root).
      end.
      assign
      buf_temp-call-param.field-name_ = p-dr-flddf::field-name_
      buf_temp-call-param.table-no = p-dr-flddf::table-no
      buf_temp-call-param.num-params = v-ii
      .
    end.
    else do:
      create buf2_temp-call-param.
      assign
      v-ii = v-ii + 1
      buf2_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
      buf2_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf2_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf2_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf2_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf2_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      buf2_temp-call-param.fld-df = entry(5, buf_drt-prop.property-value)
      .
      glog42 = p-dr-flddf:find-first( substitute(' where fld-df = &1&2&1', chr(34), buf2_temp-call-param.fld-df, chr(34))) no-error.
      if p-dr-flddf:available = no then do:
        message
        substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf2_temp-call-param.fld-df
                                      ,buf2_temp-call-param.param-name_
                                      ,v-templ-rl-root)
        view-as alert-box error .
        undo, return error substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf2_temp-call-param.fld-df
                                      ,buf2_temp-call-param.param-name_
                                      ,v-templ-rl-root).
      end.
      assign
      buf2_temp-call-param.field-name_ = p-dr-flddf::field-name_
      buf2_temp-call-param.table-no = p-dr-flddf::table-no
      .
    end.
  end.
  assign
  buf_temp-call-param.num-params = v-ii
  .
end.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  find first buf_temp-call-param where
            buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
        and buf_temp-call-param.param-number = 0.
  if not valid-handle(buf_temp-call-param.call-handle_) then do:
    create call buf_temp-call-param.call-handle_.
    assign
    buf_temp-call-param.call-handle_:call-name = buf_temp-call-param.call-name_
    buf_temp-call-param.call-handle_:call-type = FUNCTION-CALL-TYPE
    buf_temp-call-param.call-handle_:in-handle = this-procedure:handle
    buf_temp-call-param.call-handle_:num-parameters = buf_temp-call-param.num-params
    .
  end.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable glog44 as logical   no-undo .
  define variable v-dt-tp44  as character no-undo .
  for each buf2_temp-call-param where
          buf2_temp-call-param.param-num > 0
      and buf2_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
  on error  undo , return error substitute( "&1. &2&3&4", vss-include-info44,  return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-include-info44 )
  on endkey undo , return error substitute( "&1. endkey", vss-include-info44 ):
      if v-bh[buf2_temp-call-param.table-no]:buffer-field(buf2_temp-call-param.field-name_):buffer-value = ? then
      do:
         case buf2_temp-call-param.param-datatype_:
            when "decimal"  or when "integer" then
            do:
    glog44 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,0
                                                    ).
            end.
            when "character" then
            do:
    glog44 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,""
                                                    ).
            end.
         end case .
      end.
      else
    glog44 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,v-bh[buf2_temp-call-param.table-no]:buffer-field(buf2_temp-call-param.field-name_):buffer-value
                                                    ).
  end.
  assign
  buf_temp-call-param.call-number = buf_temp-call-param.call-number + 1
  v-last-call-number = buf_temp-call-param.call-number
  v-last-call-name = buf_temp-call-param.call-name_
  .
  buf_temp-call-param.call-handle_:invoke.
    if buf_temp-call-param.call-handle_:return-value = ? then
    do:
       v-dt-tp44 = v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):data-type .
       if v-dt-tp44 = "decimal" or v-dt-tp44 = "integer" then
       do:
v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):buffer-value = 0 .
       end.
    end.
    else
    do:
  v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):buffer-value = buf_temp-call-param.call-handle_:return-value.
    end.
  if v-bh[6]:buffer-field("value-type"):buffer-value =  integer('1':U) then do:
  end.
  else do:
    v-bh[6]:buffer-field("discnt-value-pcnt"):buffer-value =
              v-bh[6]:buffer-field("discnt-value-abs"):buffer-value /
              v-bh[6]:buffer-field("object-sum"):buffer-value * 100
              .
  end.
  if v-bh[6]:buffer-field("line-type"):buffer-value = integer('2':U) then do:
    assign
    v-discnt = v-bh[6]:buffer-field("discnt-value-abs"):buffer-value
    v-new-st-discnt-r-b = v-new-st-discnt-r-b + v-discnt
    v-st-r-b = v-st-r-b - v-discnt
    v-new-sum-for-discnt-r-b = v-new-sum-for-discnt-r-b - v-discnt
    .
  end.
  if v-bh[6]:buffer-field("intended"):buffer-value = no
  and v-bh[6]:buffer-field("not-found"):buffer-value = no
  then do:
    create buf_chk-discnt.
    buffer buf_chk-discnt:handle:buffer-copy(v-bh[6]).
    run printbuffer in this-procedure ( input v-bh[6]).
    v-bh[6]:buffer-release().
    release buf_chk-discnt.
    v-found = yes.
  end.
  else do:
    v-bh[6]:buffer-delete().
    v-found = no.
  end.
end.
          END.
          v-qh:QUERY-CLOSE().
          DELETE OBJECT v-qh.
          if v-found then do:
            if buf_temp-discnt-role.discnt-role = 'without-disc':U then do:
              v-found = no.
            end.
            leave _cycle.
          end.
        end.
        when 'dis-thbj-rule':U then do:
          v-line-type = integer('2':U).
          _dis-thbj-rule:
          for each buf_dis-thbj-rule no-lock where
                   buf_dis-thbj-rule.host-code = v-for-host-code
                and buf_dis-thbj-rule.obj-type = v-for-obj-type
                and buf_dis-thbj-rule.obj-code = v-for-obj-code
                and buf_dis-thbj-rule.discnt-role = buf_temp-discnt-role.discnt-role
                and buf_dis-thbj-rule.pos-type = p-pos-type-for-discnt:
            assign
            v-rule-num = buf_dis-thbj-rule.rule-num
            v-templ-rl-root = buf_dis-thbj-rule.templ-rl-root
            .
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(string(v-templ-rl-root), "20,54,55,78") > 0
then  do:
  v-bh[6]:buffer-create.
  v-bh[6]:buffer-copy(v-bh[3]).
  v-inversed-chr =  "".
  assign
  v-bh[6]:buffer-field("record-type"):buffer-value = 0
  v-bh[6]:buffer-field("line-type"):buffer-value = v-line-type
  v-bh[6]:buffer-field("discnt-id"):buffer-value = v-bh[2]:buffer-field("discnt-id"):buffer-value + 1
  v-bh[2]:buffer-field("discnt-id"):buffer-value = v-bh[2]:buffer-field("discnt-id"):buffer-value + 1
  v-bh[6]:buffer-field("line-num"):buffer-value = (if buf_temp-discnt-role.table-name = 'dis-gds-rule':U
                                                              then v-bh[4]:buffer-field("line-num"):buffer-value
                                                              else v-bh[2]:buffer-field("lng"):buffer-value)
  v-bh[2]:buffer-field("lnd"):buffer-value  = v-bh[2]:buffer-field("lnd"):buffer-value + 1
  v-bh[6]:buffer-field("doc-code"):buffer-value = v-bh[3]:buffer-field("doc-code"):buffer-value
  v-bh[6]:buffer-field("pay-desk"):buffer-value = v-bh[3]:buffer-field("pay-desk"):buffer-value
  v-bh[6]:buffer-field("obj-type"):buffer-value = v-bh[3]:buffer-field("obj-type"):buffer-value
  v-bh[6]:buffer-field("obj-code"):buffer-value = v-bh[3]:buffer-field("obj-code"):buffer-value
  v-bh[6]:buffer-field("chk-date"):buffer-value = v-bh[3]:buffer-field("chk-date"):buffer-value
  v-bh[6]:buffer-field("chk-time"):buffer-value = v-bh[3]:buffer-field("chk-time"):buffer-value
  v-bh[6]:buffer-field("time-oper"):buffer-value = v-bh[2]:buffer-field("current-time"):buffer-value
  v-bh[6]:buffer-field("src-d-card"):buffer-value = v-bh[3]:buffer-field("src-d-card"):buffer-value
  v-bh[6]:buffer-field("kateg"):buffer-value = v-bh[2]:buffer-field("category"):buffer-value
  v-bh[6]:buffer-field("rank"):buffer-value = buf_temp-rule-call-param.p-index
  v-bh[6]:buffer-field("pass-discnt"):buffer-value = integer('0':U)
  v-bh[6]:buffer-field("rule-num"):buffer-value = v-rule-num
  v-bh[6]:buffer-field("templ-rl-root"):buffer-value = v-templ-rl-root
  v-bh[6]:buffer-field("discnt-type"):buffer-value = buf_temp-discnt-role.discnt-type
  v-bh[6]:buffer-field("discnt-role"):buffer-value = buf_temp-discnt-role.discnt-role
  v-bh[6]:buffer-field("object-line-num"):buffer-value = (if buf_temp-discnt-role.table-name = 'dis-gds-rule':U
                                                                      then v-bh[4]:buffer-field("line-num"):buffer-value
                                                                      else v-bh[2]:buffer-field("lnd"):buffer-value
                                                                      )
  v-bh[6]:buffer-field("object-qnty"):buffer-value = (if buf_temp-discnt-role.table-name = 'dis-gds-rule':U
                                                                  then v-bh[4]:buffer-field("src-qnty"):buffer-value
                                                                  else v-bh[2]:buffer-field("src-qnty"):buffer-value)
  v-bh[6]:buffer-field("object-sum"):buffer-value = (if buf_temp-discnt-role.table-name = 'dis-gds-rule':U
                                                                 then (v-bh[4]:buffer-field("src-price-netto"):buffer-value +
                                                                       v-bh[4]:buffer-field("src-qnty"):buffer-value
                                                                       )
                                                                 else v-bh[2]:buffer-field("st-for-discnt-r-b"):buffer-value)
  .
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable glog46 as logical no-undo .
find first buf_temp-call-param where
        buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
    and buf_temp-call-param.param-num = 0 no-error .
if not available buf_temp-call-param then do:
  if this-procedure:handle:get-signature(substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr )) = '':u then do:
    undo, return error substitute("Определение &1 отсутствует в &2"
                                   ,substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
                                   , this-procedure:handle:file-name).
  end.
  create buf_temp-call-param.
  assign
  buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
  buf_temp-call-param.param-number_ = 0
  v-ii = 0
  .
  for each buf_drt-prop no-lock where
          buf_drt-prop.templ-rl-root = v-templ-rl-root
      and buf_drt-prop.upper-prop-code = "Run-params" + v-inversed-chr
    on error  undo , return error substitute( "&1. &2&3&4", vss-include-info46,  return-value, chr(10), error-status :get-message (1))
    on stop   undo , return error substitute( "&1. stop", vss-include-info46 )
    on endkey undo , return error substitute( "&1. endkey", vss-include-info46 ):
    if integer(buf_drt-prop.prop-code) = 0 then do:
      assign
      buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
      buf_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      buf_temp-call-param.fld-df = entry(5, buf_drt-prop.property-value)
      .
      glog46 = p-dr-flddf:find-first( substitute(' where fld-df = &1&2&1', chr(34), buf_temp-call-param.fld-df, chr(34))) no-error.
      if p-dr-flddf:available = no then do:
        message
        substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf_temp-call-param.fld-df
                                      ,buf_temp-call-param.param-name_
                                      ,v-templ-rl-root)
        view-as alert-box error .
        undo, return error substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf_temp-call-param.fld-df
                                      ,buf_temp-call-param.param-name_
                                      ,v-templ-rl-root).
      end.
      assign
      buf_temp-call-param.field-name_ = p-dr-flddf::field-name_
      buf_temp-call-param.table-no = p-dr-flddf::table-no
      buf_temp-call-param.num-params = v-ii
      .
    end.
    else do:
      create buf2_temp-call-param.
      assign
      v-ii = v-ii + 1
      buf2_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
      buf2_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf2_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf2_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf2_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf2_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      buf2_temp-call-param.fld-df = entry(5, buf_drt-prop.property-value)
      .
      glog46 = p-dr-flddf:find-first( substitute(' where fld-df = &1&2&1', chr(34), buf2_temp-call-param.fld-df, chr(34))) no-error.
      if p-dr-flddf:available = no then do:
        message
        substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf2_temp-call-param.fld-df
                                      ,buf2_temp-call-param.param-name_
                                      ,v-templ-rl-root)
        view-as alert-box error .
        undo, return error substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf2_temp-call-param.fld-df
                                      ,buf2_temp-call-param.param-name_
                                      ,v-templ-rl-root).
      end.
      assign
      buf2_temp-call-param.field-name_ = p-dr-flddf::field-name_
      buf2_temp-call-param.table-no = p-dr-flddf::table-no
      .
    end.
  end.
  assign
  buf_temp-call-param.num-params = v-ii
  .
end.
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  find first buf_temp-call-param where
            buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
        and buf_temp-call-param.param-number = 0.
  if not valid-handle(buf_temp-call-param.call-handle_) then do:
    create call buf_temp-call-param.call-handle_.
    assign
    buf_temp-call-param.call-handle_:call-name = buf_temp-call-param.call-name_
    buf_temp-call-param.call-handle_:call-type = FUNCTION-CALL-TYPE
    buf_temp-call-param.call-handle_:in-handle = this-procedure:handle
    buf_temp-call-param.call-handle_:num-parameters = buf_temp-call-param.num-params
    .
  end.
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable glog48 as logical   no-undo .
  define variable v-dt-tp48  as character no-undo .
  for each buf2_temp-call-param where
          buf2_temp-call-param.param-num > 0
      and buf2_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
  on error  undo , return error substitute( "&1. &2&3&4", vss-include-info48,  return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-include-info48 )
  on endkey undo , return error substitute( "&1. endkey", vss-include-info48 ):
      if v-bh[buf2_temp-call-param.table-no]:buffer-field(buf2_temp-call-param.field-name_):buffer-value = ? then
      do:
         case buf2_temp-call-param.param-datatype_:
            when "decimal"  or when "integer" then
            do:
    glog48 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,0
                                                    ).
            end.
            when "character" then
            do:
    glog48 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,""
                                                    ).
            end.
         end case .
      end.
      else
    glog48 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,v-bh[buf2_temp-call-param.table-no]:buffer-field(buf2_temp-call-param.field-name_):buffer-value
                                                    ).
  end.
  assign
  buf_temp-call-param.call-number = buf_temp-call-param.call-number + 1
  v-last-call-number = buf_temp-call-param.call-number
  v-last-call-name = buf_temp-call-param.call-name_
  .
  buf_temp-call-param.call-handle_:invoke.
    if buf_temp-call-param.call-handle_:return-value = ? then
    do:
       v-dt-tp48 = v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):data-type .
       if v-dt-tp48 = "decimal" or v-dt-tp48 = "integer" then
       do:
v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):buffer-value = 0 .
       end.
    end.
    else
    do:
  v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):buffer-value = buf_temp-call-param.call-handle_:return-value.
    end.
  if v-bh[6]:buffer-field("value-type"):buffer-value =  integer('1':U) then do:
  end.
  else do:
    v-bh[6]:buffer-field("discnt-value-pcnt"):buffer-value =
              v-bh[6]:buffer-field("discnt-value-abs"):buffer-value /
              v-bh[6]:buffer-field("object-sum"):buffer-value * 100
              .
  end.
  if v-bh[6]:buffer-field("line-type"):buffer-value = integer('2':U) then do:
    assign
    v-discnt = v-bh[6]:buffer-field("discnt-value-abs"):buffer-value
    v-new-st-discnt-r-b = v-new-st-discnt-r-b + v-discnt
    v-st-r-b = v-st-r-b - v-discnt
    v-new-sum-for-discnt-r-b = v-new-sum-for-discnt-r-b - v-discnt
    .
  end.
  if v-bh[6]:buffer-field("intended"):buffer-value = no
  and v-bh[6]:buffer-field("not-found"):buffer-value = no
  then do:
    create buf_chk-discnt.
    buffer buf_chk-discnt:handle:buffer-copy(v-bh[6]).
    run printbuffer in this-procedure ( input v-bh[6]).
    v-bh[6]:buffer-release().
    release buf_chk-discnt.
    v-found = yes.
  end.
  else do:
    v-bh[6]:buffer-delete().
    v-found = no.
  end.
end.
            if v-found then leave _cycle.
          end.
        end.
        when 'dis-dc-rule':U then do:
          v-line-type = integer('2':U).
          case buf_temp-discnt-role.link-prop:
            when integer('-1':U) then do:
              assign
              v-rule-num = buf_temp-discnt-role.templ-rl-root
              v-found = (v-bh[2]:buffer-field("src-d-card"):buffer-value > ""
                        and
                        v-bh[2]:buffer-field("cash-d-pcnt"):buffer-value <> 0
                          )
              v-templ-rl-root = buf_temp-discnt-role.templ-rl-root
              .
              if v-found then do:
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(string(v-templ-rl-root), "20,54,55,78") > 0
then  do:
  v-bh[6]:buffer-create.
  v-bh[6]:buffer-copy(v-bh[3]).
  v-inversed-chr =  "".
  assign
  v-bh[6]:buffer-field("record-type"):buffer-value = 0
  v-bh[6]:buffer-field("line-type"):buffer-value = v-line-type
  v-bh[6]:buffer-field("discnt-id"):buffer-value = v-bh[2]:buffer-field("discnt-id"):buffer-value + 1
  v-bh[2]:buffer-field("discnt-id"):buffer-value = v-bh[2]:buffer-field("discnt-id"):buffer-value + 1
  v-bh[6]:buffer-field("line-num"):buffer-value = (if buf_temp-discnt-role.table-name = 'dis-gds-rule':U
                                                              then v-bh[4]:buffer-field("line-num"):buffer-value
                                                              else v-bh[2]:buffer-field("lng"):buffer-value)
  v-bh[2]:buffer-field("lnd"):buffer-value  = v-bh[2]:buffer-field("lnd"):buffer-value + 1
  v-bh[6]:buffer-field("doc-code"):buffer-value = v-bh[3]:buffer-field("doc-code"):buffer-value
  v-bh[6]:buffer-field("pay-desk"):buffer-value = v-bh[3]:buffer-field("pay-desk"):buffer-value
  v-bh[6]:buffer-field("obj-type"):buffer-value = v-bh[3]:buffer-field("obj-type"):buffer-value
  v-bh[6]:buffer-field("obj-code"):buffer-value = v-bh[3]:buffer-field("obj-code"):buffer-value
  v-bh[6]:buffer-field("chk-date"):buffer-value = v-bh[3]:buffer-field("chk-date"):buffer-value
  v-bh[6]:buffer-field("chk-time"):buffer-value = v-bh[3]:buffer-field("chk-time"):buffer-value
  v-bh[6]:buffer-field("time-oper"):buffer-value = v-bh[2]:buffer-field("current-time"):buffer-value
  v-bh[6]:buffer-field("src-d-card"):buffer-value = v-bh[3]:buffer-field("src-d-card"):buffer-value
  v-bh[6]:buffer-field("kateg"):buffer-value = v-bh[2]:buffer-field("category"):buffer-value
  v-bh[6]:buffer-field("rank"):buffer-value = buf_temp-rule-call-param.p-index
  v-bh[6]:buffer-field("pass-discnt"):buffer-value = integer('0':U)
  v-bh[6]:buffer-field("rule-num"):buffer-value = v-rule-num
  v-bh[6]:buffer-field("templ-rl-root"):buffer-value = v-templ-rl-root
  v-bh[6]:buffer-field("discnt-type"):buffer-value = buf_temp-discnt-role.discnt-type
  v-bh[6]:buffer-field("discnt-role"):buffer-value = buf_temp-discnt-role.discnt-role
  v-bh[6]:buffer-field("object-line-num"):buffer-value = (if buf_temp-discnt-role.table-name = 'dis-gds-rule':U
                                                                      then v-bh[4]:buffer-field("line-num"):buffer-value
                                                                      else v-bh[2]:buffer-field("lnd"):buffer-value
                                                                      )
  v-bh[6]:buffer-field("object-qnty"):buffer-value = (if buf_temp-discnt-role.table-name = 'dis-gds-rule':U
                                                                  then v-bh[4]:buffer-field("src-qnty"):buffer-value
                                                                  else v-bh[2]:buffer-field("src-qnty"):buffer-value)
  v-bh[6]:buffer-field("object-sum"):buffer-value = (if buf_temp-discnt-role.table-name = 'dis-gds-rule':U
                                                                 then (v-bh[4]:buffer-field("src-price-netto"):buffer-value +
                                                                       v-bh[4]:buffer-field("src-qnty"):buffer-value
                                                                       )
                                                                 else v-bh[2]:buffer-field("st-for-discnt-r-b"):buffer-value)
  .
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable glog50 as logical no-undo .
find first buf_temp-call-param where
        buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
    and buf_temp-call-param.param-num = 0 no-error .
if not available buf_temp-call-param then do:
  if this-procedure:handle:get-signature(substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr )) = '':u then do:
    undo, return error substitute("Определение &1 отсутствует в &2"
                                   ,substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
                                   , this-procedure:handle:file-name).
  end.
  create buf_temp-call-param.
  assign
  buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
  buf_temp-call-param.param-number_ = 0
  v-ii = 0
  .
  for each buf_drt-prop no-lock where
          buf_drt-prop.templ-rl-root = v-templ-rl-root
      and buf_drt-prop.upper-prop-code = "Run-params" + v-inversed-chr
    on error  undo , return error substitute( "&1. &2&3&4", vss-include-info50,  return-value, chr(10), error-status :get-message (1))
    on stop   undo , return error substitute( "&1. stop", vss-include-info50 )
    on endkey undo , return error substitute( "&1. endkey", vss-include-info50 ):
    if integer(buf_drt-prop.prop-code) = 0 then do:
      assign
      buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
      buf_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      buf_temp-call-param.fld-df = entry(5, buf_drt-prop.property-value)
      .
      glog50 = p-dr-flddf:find-first( substitute(' where fld-df = &1&2&1', chr(34), buf_temp-call-param.fld-df, chr(34))) no-error.
      if p-dr-flddf:available = no then do:
        message
        substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf_temp-call-param.fld-df
                                      ,buf_temp-call-param.param-name_
                                      ,v-templ-rl-root)
        view-as alert-box error .
        undo, return error substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf_temp-call-param.fld-df
                                      ,buf_temp-call-param.param-name_
                                      ,v-templ-rl-root).
      end.
      assign
      buf_temp-call-param.field-name_ = p-dr-flddf::field-name_
      buf_temp-call-param.table-no = p-dr-flddf::table-no
      buf_temp-call-param.num-params = v-ii
      .
    end.
    else do:
      create buf2_temp-call-param.
      assign
      v-ii = v-ii + 1
      buf2_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
      buf2_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf2_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf2_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf2_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf2_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      buf2_temp-call-param.fld-df = entry(5, buf_drt-prop.property-value)
      .
      glog50 = p-dr-flddf:find-first( substitute(' where fld-df = &1&2&1', chr(34), buf2_temp-call-param.fld-df, chr(34))) no-error.
      if p-dr-flddf:available = no then do:
        message
        substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf2_temp-call-param.fld-df
                                      ,buf2_temp-call-param.param-name_
                                      ,v-templ-rl-root)
        view-as alert-box error .
        undo, return error substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf2_temp-call-param.fld-df
                                      ,buf2_temp-call-param.param-name_
                                      ,v-templ-rl-root).
      end.
      assign
      buf2_temp-call-param.field-name_ = p-dr-flddf::field-name_
      buf2_temp-call-param.table-no = p-dr-flddf::table-no
      .
    end.
  end.
  assign
  buf_temp-call-param.num-params = v-ii
  .
end.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  find first buf_temp-call-param where
            buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
        and buf_temp-call-param.param-number = 0.
  if not valid-handle(buf_temp-call-param.call-handle_) then do:
    create call buf_temp-call-param.call-handle_.
    assign
    buf_temp-call-param.call-handle_:call-name = buf_temp-call-param.call-name_
    buf_temp-call-param.call-handle_:call-type = FUNCTION-CALL-TYPE
    buf_temp-call-param.call-handle_:in-handle = this-procedure:handle
    buf_temp-call-param.call-handle_:num-parameters = buf_temp-call-param.num-params
    .
  end.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable glog52 as logical   no-undo .
  define variable v-dt-tp52  as character no-undo .
  for each buf2_temp-call-param where
          buf2_temp-call-param.param-num > 0
      and buf2_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
  on error  undo , return error substitute( "&1. &2&3&4", vss-include-info52,  return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-include-info52 )
  on endkey undo , return error substitute( "&1. endkey", vss-include-info52 ):
      if v-bh[buf2_temp-call-param.table-no]:buffer-field(buf2_temp-call-param.field-name_):buffer-value = ? then
      do:
         case buf2_temp-call-param.param-datatype_:
            when "decimal"  or when "integer" then
            do:
    glog52 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,0
                                                    ).
            end.
            when "character" then
            do:
    glog52 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,""
                                                    ).
            end.
         end case .
      end.
      else
    glog52 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,v-bh[buf2_temp-call-param.table-no]:buffer-field(buf2_temp-call-param.field-name_):buffer-value
                                                    ).
  end.
  assign
  buf_temp-call-param.call-number = buf_temp-call-param.call-number + 1
  v-last-call-number = buf_temp-call-param.call-number
  v-last-call-name = buf_temp-call-param.call-name_
  .
  buf_temp-call-param.call-handle_:invoke.
    if buf_temp-call-param.call-handle_:return-value = ? then
    do:
       v-dt-tp52 = v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):data-type .
       if v-dt-tp52 = "decimal" or v-dt-tp52 = "integer" then
       do:
v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):buffer-value = 0 .
       end.
    end.
    else
    do:
  v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):buffer-value = buf_temp-call-param.call-handle_:return-value.
    end.
  if v-bh[6]:buffer-field("value-type"):buffer-value =  integer('1':U) then do:
  end.
  else do:
    v-bh[6]:buffer-field("discnt-value-pcnt"):buffer-value =
              v-bh[6]:buffer-field("discnt-value-abs"):buffer-value /
              v-bh[6]:buffer-field("object-sum"):buffer-value * 100
              .
  end.
  if v-bh[6]:buffer-field("line-type"):buffer-value = integer('2':U) then do:
    assign
    v-discnt = v-bh[6]:buffer-field("discnt-value-abs"):buffer-value
    v-new-st-discnt-r-b = v-new-st-discnt-r-b + v-discnt
    v-st-r-b = v-st-r-b - v-discnt
    v-new-sum-for-discnt-r-b = v-new-sum-for-discnt-r-b - v-discnt
    .
  end.
  if v-bh[6]:buffer-field("intended"):buffer-value = no
  and v-bh[6]:buffer-field("not-found"):buffer-value = no
  then do:
    create buf_chk-discnt.
    buffer buf_chk-discnt:handle:buffer-copy(v-bh[6]).
    run printbuffer in this-procedure ( input v-bh[6]).
    v-bh[6]:buffer-release().
    release buf_chk-discnt.
    v-found = yes.
  end.
  else do:
    v-bh[6]:buffer-delete().
    v-found = no.
  end.
end.
              end.
              if v-found then leave _cycle.
            end.
          end case.
        end.
      end case.
    end.
    if v-found and not p-add-discnts then do:
      leave _roles.
    end.
  end.
end.
end.
end procedure.
procedure rs_17_1 :
define input parameter p-caller as character no-undo .
define input parameter v-pline-num as integer   no-undo .
define input parameter v-cdpay-code as integer   no-undo .
define input parameter v-curr-code as integer   no-undo .
define input parameter v-pay-card as character no-undo .
define input parameter v-inversed as logical no-undo .
define input parameter v-start-curr-sum as decimal no-undo .
define input parameter v-curr-sum as decimal no-undo .
define input parameter v-start-rubl-sum as decimal no-undo .
define input parameter v-rubl-sum as decimal no-undo .
define input parameter v-start-base-sum as decimal no-undo .
define input parameter v-base-sum as decimal no-undo .
define input parameter v-discnt-curr as decimal no-undo .
define input parameter v-discnt-rubl as decimal no-undo .
define input parameter v-discnt-base as decimal no-undo .
define input parameter v-bh as handle no-undo extent 6.
define output parameter v-new-curr-sum as decimal no-undo .
define output parameter v-new-rubl-sum as decimal no-undo .
define output parameter v-new-base-sum as decimal no-undo .
define output parameter v-new-discnt-curr as decimal no-undo .
define output parameter v-new-discnt-rubl as decimal no-undo .
define output parameter v-new-discnt-base as decimal no-undo .
define buffer buf_temp-rule-by-call for temp-rule-by-call.
define buffer buf_temp-discnt-role for temp-discnt-role.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  assign
  v-codex-id = 17
  v-ruleset-id = 1
  v-caller = p-caller
  .
  assign
  v-new-curr-sum      = v-curr-sum
  v-new-rubl-sum      = v-rubl-sum
  v-new-base-sum      = v-base-sum
  v-new-discnt-curr   = v-discnt-curr
  v-new-discnt-rubl   = v-discnt-rubl
  v-new-discnt-base   = v-discnt-base
  .
  for each buf_temp-rule-by-call where
            buf_temp-rule-by-call.call_id = p-call-id
        and buf_temp-rule-by-call.codex_id = v-codex-id
        and buf_temp-rule-by-call.ruleset_id = v-ruleset-id
        and buf_temp-rule-by-call.profile_id = p-profile-id
        and buf_temp-rule-by-call.once-more = p-once-more
  by buf_temp-rule-by-call.order
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if not (buf_temp-rule-by-call.can-calc and buf_temp-rule-by-call.can-run) then next.
    run value( substitute("r_17_1_&1", buf_temp-rule-by-call.rule_id)) in this-procedure (
              input buf_temp-rule-by-call.order_id
             ,input buf_temp-rule-by-call.rule_id
             ,input v-pline-num
             ,input v-cdpay-code
             ,input v-curr-code
             ,input v-pay-card
             ,input v-inversed
             ,input v-start-curr-sum
             ,input v-curr-sum
             ,input v-start-rubl-sum
             ,input v-rubl-sum
             ,input v-start-base-sum
             ,input v-base-sum
             ,input v-discnt-curr
             ,input v-discnt-rubl
             ,input v-discnt-base
             ,input v-bh
             ,output v-new-curr-sum
             ,output v-new-rubl-sum
             ,output v-new-base-sum
             ,output v-new-discnt-curr
             ,output v-new-discnt-rubl
             ,output v-new-discnt-base
             ) no-error.
    if not error-status :error then do:
      assign
      v-curr-sum      = v-new-curr-sum
      v-rubl-sum      = v-new-rubl-sum
      v-base-sum      = v-new-base-sum
      v-discnt-curr   = v-new-discnt-curr
      v-discnt-rubl   = v-new-discnt-rubl
      v-discnt-base   = v-new-discnt-base
      .
    end.
  end.
end.
end procedure.
procedure r_17_1_1973:
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter v-pline-num as integer   no-undo .
define input parameter v-cdpay-code as integer   no-undo .
define input parameter v-curr-code as integer   no-undo .
define input parameter v-pay-card as character no-undo .
define input parameter v-inversed as logical no-undo .
define input parameter v-start-curr-sum as decimal no-undo .
define input parameter v-curr-sum as decimal no-undo .
define input parameter v-start-rubl-sum as decimal no-undo .
define input parameter v-rubl-sum as decimal no-undo .
define input parameter v-start-base-sum as decimal no-undo .
define input parameter v-base-sum as decimal no-undo .
define input parameter v-discnt-curr as decimal no-undo .
define input parameter v-discnt-rubl as decimal no-undo .
define input parameter v-discnt-base as decimal no-undo .
define input parameter v-bh as handle no-undo extent 6.
define output parameter v-new-curr-sum as decimal no-undo .
define output parameter v-new-rubl-sum as decimal no-undo .
define output parameter v-new-base-sum as decimal no-undo .
define output parameter v-new-discnt-curr as decimal no-undo .
define output parameter v-new-discnt-rubl as decimal no-undo .
define output parameter v-new-discnt-base as decimal no-undo .
define buffer buf_temp-rule-call-param for temp-rule-call-param.
 define variable p-discnt-roles as character no-undo.
 define variable p-add-discnts as logical no-undo.
 find first buf_temp-rule-call-param no-lock where
buf_temp-rule-call-param.codex_id = v-codex-id
and buf_temp-rule-call-param.ruleset_id = v-ruleset-id
and buf_temp-rule-call-param.call_id = p-call-id
and buf_temp-rule-call-param.order_id = p-order-id
and buf_temp-rule-call-param.rule_id = p-rule-id
and buf_temp-rule-call-param.param-name = "p-add-discnts"
 no-error.
if available buf_temp-rule-call-param then do:
assign p-add-discnts = buf_temp-rule-call-param.param-value-logical.
end.
_main:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-found as logical no-undo .
define variable v-delta-discnt-r-b as decimal no-undo .
define variable v-delta-discnt-rubl as decimal no-undo .
define variable v-delta-discnt-base as decimal no-undo .
define variable v-delta-discnt-curr as decimal no-undo .
define variable v-rule-num as integer no-undo .
define variable v-templ-rl-root as integer no-undo .
define variable v-cycle as integer   no-undo .
define variable v-for-gds-obj-type as character no-undo .
define variable v-for-gds-obj-code as integer   no-undo .
define variable v-for-host-code as integer   no-undo .
define variable v-for-obj-type as character no-undo .
define variable v-for-obj-code as integer   no-undo .
define variable v-qh as handle no-undo .
define variable v-line-type as integer   no-undo .
define variable v-ok as logical   no-undo .
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii as integer no-undo .
define buffer buf_temp-call-param for temp-call-param.
define buffer buf2_temp-call-param for temp-call-param.
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_chk-discnt  for ub.chk-discnt.
define buffer buf_temp-discnt-role for temp-discnt-role.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
assign
v-new-curr-sum      = v-curr-sum
v-new-rubl-sum      = v-rubl-sum
v-new-base-sum      = v-base-sum
v-new-discnt-curr   = v-discnt-curr
v-new-discnt-rubl   = v-discnt-rubl
v-new-discnt-base   = v-discnt-base
.
_roles:
for each buf_temp-rule-call-param where
      buf_temp-rule-call-param.call_id = p-call-id
  and buf_temp-rule-call-param.codex_id = v-codex-id
  and buf_temp-rule-call-param.ruleset_id = v-ruleset-id
  and buf_temp-rule-call-param.order_id = p-order-id
  and buf_temp-rule-call-param.rule_id = p-rule-id
  and buf_temp-rule-call-param.param-name = "p-discnt-roles"
  and buf_temp-rule-call-param.p-index > 0
  by buf_temp-rule-call-param.call_id
  by buf_temp-rule-call-param.codex_id
  by buf_temp-rule-call-param.ruleset_id
  by buf_temp-rule-call-param.order_id
  by buf_temp-rule-call-param.param-name
  by buf_temp-rule-call-param.p-index:
  find first buf_temp-discnt-role where
            buf_temp-discnt-role.codex_id = v-codex-id
        and buf_temp-discnt-role.ruleset_id = v-ruleset-id
        and buf_temp-discnt-role.order_id = p-order-id
        and buf_temp-discnt-role.rule_id = p-rule-id
        and buf_temp-discnt-role.discnt-role = buf_temp-rule-call-param.param-value-character
        and buf_temp-discnt-role.subject-type = integer('5':U)
        no-error.
  if available buf_temp-discnt-role then do:
    _cycle:
    do v-cycle = 1 to 3 :
      if v-cycle = 1 then do:
        if buf_temp-discnt-role.has-obj = 1 then do:
          assign
          v-for-host-code = v-current-host-code
          v-for-obj-type = v-current-obj-type
          v-for-obj-code = v-current-obj-code
          v-for-gds-obj-type = v-current-obj-type
          v-for-gds-obj-code = v-current-obj-code
          .
        end.
        else do:
          next _cycle.
        end.
      end.
      if v-cycle = 2 then do:
        if buf_temp-discnt-role.has-host = 1 then do:
          assign
          v-for-host-code = v-current-host-code
          v-for-obj-type = ''
          v-for-obj-code = 0
          v-for-gds-obj-type = 'орг':U
          v-for-gds-obj-code = v-current-host-code
          .
        end.
        else do:
          next _cycle.
        end.
      end.
      if v-cycle = 3 then do:
        if buf_temp-discnt-role.has-glob = 1 then do:
          assign
          v-for-obj-type = ''
          v-for-obj-code = 0
          v-for-host-code = 0
          v-for-gds-obj-type = ''
          v-for-gds-obj-code = 0
          .
        end.
        else do:
          next _cycle.
        end.
      end.
      case buf_temp-discnt-role.table-name:
        when 'dis-gds-rule':U then do:
          v-line-type = integer('5':U).
          create query v-qh.
          v-ok = v-qh:set-buffers(v-bh[4], (buffer buf_dis-gds-rule:handle)).
          v-ok = v-qh:QUERY-PREPARE(
                                    substitute('FOR EACH libthpos_chk-gds WHERE libthpos_chk-gds.doc-code = "&1", ' +
                                              'first buf_dis-gds-rule no-lock where buf_dis-gds-rule.gds-code = libthpos_chk-gds.gds-code ' +
                                              ' and  buf_dis-gds-rule.obj-type = "&2" ' +
                                              ' and buf_dis-gds-rule.obj-code = &3 ' +
                                              ' and buf_dis-gds-rule.discnt-role = "&4" ' +
                                              ' and buf_dis-gds-rule.pos-type = "&5" '
                                                                                      ,v-bh[2]:buffer-field("doc-code"):buffer-value
                                                                                      ,v-for-gds-obj-type
                                                                                      ,v-for-gds-obj-code
                                                                                      ,buf_temp-discnt-role.discnt-role
                                                                                      ,p-pos-type-for-discnt)).
          v-qh:QUERY-OPEN.
          _repeat:
          REPEAT :
            v-qh:GET-NEXT().
            IF v-qh:QUERY-OFF-END THEN LEAVE.
            assign
            v-rule-num = buf_dis-gds-rule.rule-num
            v-templ-rl-root = buf_dis-gds-rule.templ-rl-root
            .
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(string(v-templ-rl-root), "42") > 0
then  do:
  v-bh[6]:buffer-create.
  v-bh[6]:buffer-copy(v-bh[3]).
  v-inversed-chr = (if v-inversed then "i":U else "").
  assign
  v-bh[6]:buffer-field("record-type"):buffer-value = 0
  v-bh[6]:buffer-field("line-type"):buffer-value = v-line-type
  v-bh[6]:buffer-field("discnt-id"):buffer-value = v-bh[2]:buffer-field("discnt-id"):buffer-value + 1
  v-bh[2]:buffer-field("discnt-id"):buffer-value = v-bh[2]:buffer-field("discnt-id"):buffer-value + 1
  v-bh[6]:buffer-field("line-num"):buffer-value = (if buf_temp-discnt-role.table-name = 'dis-gds-rule':U
                                                              then v-bh[4]:buffer-field("line-num"):buffer-value
                                                              else v-bh[5]:buffer-field("line-num"):buffer-value)
  v-bh[2]:buffer-field("lnd"):buffer-value  = v-bh[2]:buffer-field("lnd"):buffer-value + 1
  v-bh[6]:buffer-field("doc-code"):buffer-value = v-bh[3]:buffer-field("doc-code"):buffer-value
  v-bh[6]:buffer-field("pay-desk"):buffer-value = v-bh[3]:buffer-field("pay-desk"):buffer-value
  v-bh[6]:buffer-field("obj-type"):buffer-value = v-bh[3]:buffer-field("obj-type"):buffer-value
  v-bh[6]:buffer-field("obj-code"):buffer-value = v-bh[3]:buffer-field("obj-code"):buffer-value
  v-bh[6]:buffer-field("chk-date"):buffer-value = v-bh[3]:buffer-field("chk-date"):buffer-value
  v-bh[6]:buffer-field("chk-time"):buffer-value = v-bh[3]:buffer-field("chk-time"):buffer-value
  v-bh[6]:buffer-field("time-oper"):buffer-value = v-bh[2]:buffer-field("current-time"):buffer-value
  v-bh[6]:buffer-field("src-d-card"):buffer-value = v-bh[3]:buffer-field("src-d-card"):buffer-value
  v-bh[6]:buffer-field("kateg"):buffer-value = v-bh[2]:buffer-field("category"):buffer-value
  v-bh[6]:buffer-field("rank"):buffer-value = buf_temp-rule-call-param.p-index
  v-bh[6]:buffer-field("pass-discnt"):buffer-value = integer('0':U)
  v-bh[6]:buffer-field("rule-num"):buffer-value = v-rule-num
  v-bh[6]:buffer-field("templ-rl-root"):buffer-value = v-templ-rl-root
  v-bh[6]:buffer-field("discnt-type"):buffer-value = buf_temp-discnt-role.discnt-type
  v-bh[6]:buffer-field("discnt-role"):buffer-value = buf_temp-discnt-role.discnt-role
  v-bh[6]:buffer-field("object-line-num"):buffer-value = (if buf_temp-discnt-role.table-name = 'dis-gds-rule':U
                                                                      then v-bh[4]:buffer-field("line-num"):buffer-value
                                                                      else v-bh[5]:buffer-field("line-num"):buffer-value
                                                                      )
  v-bh[6]:buffer-field("object-qnty"):buffer-value = (if buf_temp-discnt-role.table-name = 'dis-gds-rule':U
                                                                  then v-bh[4]:buffer-field("src-qnty"):buffer-value
                                                                  else v-bh[2]:buffer-field("src-qnty"):buffer-value)
  v-bh[6]:buffer-field("object-sum"):buffer-value = (if buf_temp-discnt-role.table-name = 'dis-gds-rule':U
                                                                 then (v-bh[4]:buffer-field("src-price-netto"):buffer-value +
                                                                       v-bh[4]:buffer-field("src-qnty"):buffer-value
                                                                       )
                                                                 else v-bh[5]:buffer-field("brutto-r-b"):buffer-value)
  .
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable glog56 as logical no-undo .
find first buf_temp-call-param where
        buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
    and buf_temp-call-param.param-num = 0 no-error .
if not available buf_temp-call-param then do:
  if this-procedure:handle:get-signature(substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr )) = '':u then do:
    undo, return error substitute("Определение &1 отсутствует в &2"
                                   ,substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
                                   , this-procedure:handle:file-name).
  end.
  create buf_temp-call-param.
  assign
  buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
  buf_temp-call-param.param-number_ = 0
  v-ii = 0
  .
  for each buf_drt-prop no-lock where
          buf_drt-prop.templ-rl-root = v-templ-rl-root
      and buf_drt-prop.upper-prop-code = "Run-params" + v-inversed-chr
    on error  undo , return error substitute( "&1. &2&3&4", vss-include-info56,  return-value, chr(10), error-status :get-message (1))
    on stop   undo , return error substitute( "&1. stop", vss-include-info56 )
    on endkey undo , return error substitute( "&1. endkey", vss-include-info56 ):
    if integer(buf_drt-prop.prop-code) = 0 then do:
      assign
      buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
      buf_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      buf_temp-call-param.fld-df = entry(5, buf_drt-prop.property-value)
      .
      glog56 = p-dr-flddf:find-first( substitute(' where fld-df = &1&2&1', chr(34), buf_temp-call-param.fld-df, chr(34))) no-error.
      if p-dr-flddf:available = no then do:
        message
        substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf_temp-call-param.fld-df
                                      ,buf_temp-call-param.param-name_
                                      ,v-templ-rl-root)
        view-as alert-box error .
        undo, return error substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf_temp-call-param.fld-df
                                      ,buf_temp-call-param.param-name_
                                      ,v-templ-rl-root).
      end.
      assign
      buf_temp-call-param.field-name_ = p-dr-flddf::field-name_
      buf_temp-call-param.table-no = p-dr-flddf::table-no
      buf_temp-call-param.num-params = v-ii
      .
    end.
    else do:
      create buf2_temp-call-param.
      assign
      v-ii = v-ii + 1
      buf2_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
      buf2_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf2_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf2_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf2_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf2_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      buf2_temp-call-param.fld-df = entry(5, buf_drt-prop.property-value)
      .
      glog56 = p-dr-flddf:find-first( substitute(' where fld-df = &1&2&1', chr(34), buf2_temp-call-param.fld-df, chr(34))) no-error.
      if p-dr-flddf:available = no then do:
        message
        substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf2_temp-call-param.fld-df
                                      ,buf2_temp-call-param.param-name_
                                      ,v-templ-rl-root)
        view-as alert-box error .
        undo, return error substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf2_temp-call-param.fld-df
                                      ,buf2_temp-call-param.param-name_
                                      ,v-templ-rl-root).
      end.
      assign
      buf2_temp-call-param.field-name_ = p-dr-flddf::field-name_
      buf2_temp-call-param.table-no = p-dr-flddf::table-no
      .
    end.
  end.
  assign
  buf_temp-call-param.num-params = v-ii
  .
end.
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  find first buf_temp-call-param where
            buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
        and buf_temp-call-param.param-number = 0.
  if not valid-handle(buf_temp-call-param.call-handle_) then do:
    create call buf_temp-call-param.call-handle_.
    assign
    buf_temp-call-param.call-handle_:call-name = buf_temp-call-param.call-name_
    buf_temp-call-param.call-handle_:call-type = FUNCTION-CALL-TYPE
    buf_temp-call-param.call-handle_:in-handle = this-procedure:handle
    buf_temp-call-param.call-handle_:num-parameters = buf_temp-call-param.num-params
    .
  end.
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable glog58 as logical   no-undo .
  define variable v-dt-tp58  as character no-undo .
  for each buf2_temp-call-param where
          buf2_temp-call-param.param-num > 0
      and buf2_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
  on error  undo , return error substitute( "&1. &2&3&4", vss-include-info58,  return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-include-info58 )
  on endkey undo , return error substitute( "&1. endkey", vss-include-info58 ):
      if v-bh[buf2_temp-call-param.table-no]:buffer-field(buf2_temp-call-param.field-name_):buffer-value = ? then
      do:
         case buf2_temp-call-param.param-datatype_:
            when "decimal"  or when "integer" then
            do:
    glog58 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,0
                                                    ).
            end.
            when "character" then
            do:
    glog58 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,""
                                                    ).
            end.
         end case .
      end.
      else
    glog58 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,v-bh[buf2_temp-call-param.table-no]:buffer-field(buf2_temp-call-param.field-name_):buffer-value
                                                    ).
  end.
  assign
  buf_temp-call-param.call-number = buf_temp-call-param.call-number + 1
  v-last-call-number = buf_temp-call-param.call-number
  v-last-call-name = buf_temp-call-param.call-name_
  .
  buf_temp-call-param.call-handle_:invoke.
    if buf_temp-call-param.call-handle_:return-value = ? then
    do:
       v-dt-tp58 = v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):data-type .
       if v-dt-tp58 = "decimal" or v-dt-tp58 = "integer" then
       do:
v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):buffer-value = 0 .
       end.
    end.
    else
    do:
  v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):buffer-value = buf_temp-call-param.call-handle_:return-value.
    end.
  if v-inversed then do:
    v-bh[6]:buffer-field("object-sum"):buffer-value =
    v-bh[6]:buffer-field("object-sum"):buffer-value   .
  end.
  if v-bh[6]:buffer-field("value-type"):buffer-value =  integer('1':U) then do:
  end.
  else do:
    v-bh[6]:buffer-field("discnt-value-pcnt"):buffer-value =
              v-bh[6]:buffer-field("discnt-value-abs"):buffer-value /
              v-bh[6]:buffer-field("object-sum"):buffer-value * 100
              .
  end.
  assign
  v-delta-discnt-r-b = v-bh[6]:buffer-field("discnt-value-abs"):buffer-value
  .
  if v-bh[1]:buffer-field("r-b"):buffer-value = 'rubl':U then do:
    assign
    v-delta-discnt-rubl = v-delta-discnt-r-b
    v-new-rubl-sum = v-rubl-sum - v-delta-discnt-rubl * integer(not v-inversed)
    v-new-discnt-rubl = v-discnt-rubl + v-delta-discnt-rubl
    .
    if v-bh[1]:buffer-field("base-code"):buffer-value = 0 then do:
      assign
      v-delta-discnt-base = v-delta-discnt-r-b
      v-new-base-sum = v-base-sum - v-delta-discnt-base * integer(not v-inversed)
      v-new-discnt-base = v-discnt-base + v-delta-discnt-base
      .
    end.
    else do:
      assign
      v-delta-discnt-base = v-delta-discnt-r-b * v-bh[2]:buffer-field("base-rate"):buffer-value
      v-new-base-sum = v-base-sum - v-delta-discnt-base * integer(not v-inversed)
      v-new-discnt-base = v-discnt-base + v-delta-discnt-base
      .
    end.
  end.
  else do:
    assign
    v-delta-discnt-base = v-delta-discnt-r-b
    v-new-base-sum = v-base-sum - v-delta-discnt-base  * integer(not v-inversed)
    v-new-discnt-base = v-discnt-base + v-delta-discnt-base
    .
    if  v-bh[1]:buffer-field("base-code"):buffer-value = 0 then do:
      assign
      v-delta-discnt-rubl = v-delta-discnt-r-b
      v-new-rubl-sum = v-rubl-sum - v-delta-discnt-base * integer(not v-inversed)
      v-new-discnt-rubl = v-discnt-rubl + v-delta-discnt-base
      .
    end.
    else do:
      assign
      v-delta-discnt-base = v-delta-discnt-r-b / v-bh[2]:buffer-field("base-rate"):buffer-value
      v-new-base-sum = v-base-sum - v-delta-discnt-base * integer(not v-inversed)
      v-new-discnt-base = v-discnt-base + v-delta-discnt-base
      .
    end.
  end.
  if v-curr-code = 0 then do:
    assign
    v-delta-discnt-curr = v-delta-discnt-rubl
    v-new-curr-sum = v-curr-sum - v-delta-discnt-curr * integer(not v-inversed)
    v-new-discnt-curr = v-discnt-curr + v-delta-discnt-curr
    .
  end.
  else do:
    if v-curr-code = v-bh[1]:buffer-field("base-code"):buffer-value then do:
      assign
      v-delta-discnt-curr = v-delta-discnt-base
      v-new-curr-sum = v-curr-sum - v-delta-discnt-curr  * integer(not v-inversed)
      v-new-discnt-curr = v-discnt-curr + v-delta-discnt-curr
      .
    end.
    else do:
      assign
      v-delta-discnt-curr = v-delta-discnt-rubl / v-bh[5]:buffer-field("exch-rate"):buffer-value * v-bh[5]:buffer-field("exch-scale"):buffer-value
      v-new-curr-sum = v-curr-sum - v-delta-discnt-curr * integer(not v-inversed)
      v-new-discnt-curr = v-discnt-curr + v-delta-discnt-curr
      .
    end.
  end.
  if v-bh[6]:buffer-field("intended"):buffer-value = no
  and v-bh[6]:buffer-field("not-found"):buffer-value = no
  then do:
    if v-inversed then do:
      create buf_chk-discnt.
      buffer buf_chk-discnt:handle:buffer-copy(v-bh[6]).
      if buf_temp-discnt-role.table-name = 'dis-cp-rule':U then do:
        assign
        buffer buf_chk-discnt:handle:buffer-field("object-sum"):buffer-value = v-bh[2]:buffer-field("netto"):buffer-value
        .
      end.
      run printbuffer in this-procedure ( input v-bh[6]).
      release buf_chk-discnt.
    end.
    v-bh[6]:buffer-release().
    v-found = yes.
  end.
  else do:
    v-bh[6]:buffer-delete().
    v-found = no.
  end.
end.
            if v-found then leave _repeat.
          END.
          v-qh:QUERY-CLOSE().
          DELETE OBJECT v-qh.
          if v-found then do:
            if buf_temp-discnt-role.discnt-role = 'without-disc':U then do:
              v-found = no.
            end.
            leave _cycle.
          end.
        end.
        when 'dis-cp-rule':U then do:
          v-line-type = integer('5':U).
          _dis-thbj-rule:
          for each buf_dis-cp-rule no-lock where
                   buf_dis-cp-rule.host-code = v-for-host-code
                and buf_dis-cp-rule.obj-type = v-for-obj-type
                and buf_dis-cp-rule.obj-code = v-for-obj-code
                and buf_dis-cp-rule.discnt-role = buf_temp-discnt-role.discnt-role
                and buf_dis-cp-rule.pos-type = p-pos-type-for-discnt
                and buf_dis-cp-rule.cdpay-code = v-cdpay-code
                and buf_dis-cp-rule.curr-code = v-curr-code
                :
            assign
            v-rule-num = buf_dis-cp-rule.rule-num
            v-templ-rl-root = buf_dis-cp-rule.templ-rl-root
            .
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(string(v-templ-rl-root), "42") > 0
then  do:
  v-bh[6]:buffer-create.
  v-bh[6]:buffer-copy(v-bh[3]).
  v-inversed-chr = (if v-inversed then "i":U else "").
  assign
  v-bh[6]:buffer-field("record-type"):buffer-value = 0
  v-bh[6]:buffer-field("line-type"):buffer-value = v-line-type
  v-bh[6]:buffer-field("discnt-id"):buffer-value = v-bh[2]:buffer-field("discnt-id"):buffer-value + 1
  v-bh[2]:buffer-field("discnt-id"):buffer-value = v-bh[2]:buffer-field("discnt-id"):buffer-value + 1
  v-bh[6]:buffer-field("line-num"):buffer-value = (if buf_temp-discnt-role.table-name = 'dis-gds-rule':U
                                                              then v-bh[4]:buffer-field("line-num"):buffer-value
                                                              else v-bh[5]:buffer-field("line-num"):buffer-value)
  v-bh[2]:buffer-field("lnd"):buffer-value  = v-bh[2]:buffer-field("lnd"):buffer-value + 1
  v-bh[6]:buffer-field("doc-code"):buffer-value = v-bh[3]:buffer-field("doc-code"):buffer-value
  v-bh[6]:buffer-field("pay-desk"):buffer-value = v-bh[3]:buffer-field("pay-desk"):buffer-value
  v-bh[6]:buffer-field("obj-type"):buffer-value = v-bh[3]:buffer-field("obj-type"):buffer-value
  v-bh[6]:buffer-field("obj-code"):buffer-value = v-bh[3]:buffer-field("obj-code"):buffer-value
  v-bh[6]:buffer-field("chk-date"):buffer-value = v-bh[3]:buffer-field("chk-date"):buffer-value
  v-bh[6]:buffer-field("chk-time"):buffer-value = v-bh[3]:buffer-field("chk-time"):buffer-value
  v-bh[6]:buffer-field("time-oper"):buffer-value = v-bh[2]:buffer-field("current-time"):buffer-value
  v-bh[6]:buffer-field("src-d-card"):buffer-value = v-bh[3]:buffer-field("src-d-card"):buffer-value
  v-bh[6]:buffer-field("kateg"):buffer-value = v-bh[2]:buffer-field("category"):buffer-value
  v-bh[6]:buffer-field("rank"):buffer-value = buf_temp-rule-call-param.p-index
  v-bh[6]:buffer-field("pass-discnt"):buffer-value = integer('0':U)
  v-bh[6]:buffer-field("rule-num"):buffer-value = v-rule-num
  v-bh[6]:buffer-field("templ-rl-root"):buffer-value = v-templ-rl-root
  v-bh[6]:buffer-field("discnt-type"):buffer-value = buf_temp-discnt-role.discnt-type
  v-bh[6]:buffer-field("discnt-role"):buffer-value = buf_temp-discnt-role.discnt-role
  v-bh[6]:buffer-field("object-line-num"):buffer-value = (if buf_temp-discnt-role.table-name = 'dis-gds-rule':U
                                                                      then v-bh[4]:buffer-field("line-num"):buffer-value
                                                                      else v-bh[5]:buffer-field("line-num"):buffer-value
                                                                      )
  v-bh[6]:buffer-field("object-qnty"):buffer-value = (if buf_temp-discnt-role.table-name = 'dis-gds-rule':U
                                                                  then v-bh[4]:buffer-field("src-qnty"):buffer-value
                                                                  else v-bh[2]:buffer-field("src-qnty"):buffer-value)
  v-bh[6]:buffer-field("object-sum"):buffer-value = (if buf_temp-discnt-role.table-name = 'dis-gds-rule':U
                                                                 then (v-bh[4]:buffer-field("src-price-netto"):buffer-value +
                                                                       v-bh[4]:buffer-field("src-qnty"):buffer-value
                                                                       )
                                                                 else v-bh[5]:buffer-field("brutto-r-b"):buffer-value)
  .
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable glog60 as logical no-undo .
find first buf_temp-call-param where
        buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
    and buf_temp-call-param.param-num = 0 no-error .
if not available buf_temp-call-param then do:
  if this-procedure:handle:get-signature(substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr )) = '':u then do:
    undo, return error substitute("Определение &1 отсутствует в &2"
                                   ,substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
                                   , this-procedure:handle:file-name).
  end.
  create buf_temp-call-param.
  assign
  buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
  buf_temp-call-param.param-number_ = 0
  v-ii = 0
  .
  for each buf_drt-prop no-lock where
          buf_drt-prop.templ-rl-root = v-templ-rl-root
      and buf_drt-prop.upper-prop-code = "Run-params" + v-inversed-chr
    on error  undo , return error substitute( "&1. &2&3&4", vss-include-info60,  return-value, chr(10), error-status :get-message (1))
    on stop   undo , return error substitute( "&1. stop", vss-include-info60 )
    on endkey undo , return error substitute( "&1. endkey", vss-include-info60 ):
    if integer(buf_drt-prop.prop-code) = 0 then do:
      assign
      buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
      buf_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      buf_temp-call-param.fld-df = entry(5, buf_drt-prop.property-value)
      .
      glog60 = p-dr-flddf:find-first( substitute(' where fld-df = &1&2&1', chr(34), buf_temp-call-param.fld-df, chr(34))) no-error.
      if p-dr-flddf:available = no then do:
        message
        substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf_temp-call-param.fld-df
                                      ,buf_temp-call-param.param-name_
                                      ,v-templ-rl-root)
        view-as alert-box error .
        undo, return error substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf_temp-call-param.fld-df
                                      ,buf_temp-call-param.param-name_
                                      ,v-templ-rl-root).
      end.
      assign
      buf_temp-call-param.field-name_ = p-dr-flddf::field-name_
      buf_temp-call-param.table-no = p-dr-flddf::table-no
      buf_temp-call-param.num-params = v-ii
      .
    end.
    else do:
      create buf2_temp-call-param.
      assign
      v-ii = v-ii + 1
      buf2_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
      buf2_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf2_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf2_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf2_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf2_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      buf2_temp-call-param.fld-df = entry(5, buf_drt-prop.property-value)
      .
      glog60 = p-dr-flddf:find-first( substitute(' where fld-df = &1&2&1', chr(34), buf2_temp-call-param.fld-df, chr(34))) no-error.
      if p-dr-flddf:available = no then do:
        message
        substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf2_temp-call-param.fld-df
                                      ,buf2_temp-call-param.param-name_
                                      ,v-templ-rl-root)
        view-as alert-box error .
        undo, return error substitute("Не определен регистр &1 параметра &2 для расчета скидок/бонусов по правилу с шаблоном &3"
                                      ,buf2_temp-call-param.fld-df
                                      ,buf2_temp-call-param.param-name_
                                      ,v-templ-rl-root).
      end.
      assign
      buf2_temp-call-param.field-name_ = p-dr-flddf::field-name_
      buf2_temp-call-param.table-no = p-dr-flddf::table-no
      .
    end.
  end.
  assign
  buf_temp-call-param.num-params = v-ii
  .
end.
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  find first buf_temp-call-param where
            buf_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
        and buf_temp-call-param.param-number = 0.
  if not valid-handle(buf_temp-call-param.call-handle_) then do:
    create call buf_temp-call-param.call-handle_.
    assign
    buf_temp-call-param.call-handle_:call-name = buf_temp-call-param.call-name_
    buf_temp-call-param.call-handle_:call-type = FUNCTION-CALL-TYPE
    buf_temp-call-param.call-handle_:in-handle = this-procedure:handle
    buf_temp-call-param.call-handle_:num-parameters = buf_temp-call-param.num-params
    .
  end.
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable glog62 as logical   no-undo .
  define variable v-dt-tp62  as character no-undo .
  for each buf2_temp-call-param where
          buf2_temp-call-param.param-num > 0
      and buf2_temp-call-param.call-name_ = substitute("dis-rule_rf_&1&2", string(v-templ-rl-root, "99999"), v-inversed-chr)
  on error  undo , return error substitute( "&1. &2&3&4", vss-include-info62,  return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-include-info62 )
  on endkey undo , return error substitute( "&1. endkey", vss-include-info62 ):
      if v-bh[buf2_temp-call-param.table-no]:buffer-field(buf2_temp-call-param.field-name_):buffer-value = ? then
      do:
         case buf2_temp-call-param.param-datatype_:
            when "decimal"  or when "integer" then
            do:
    glog62 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,0
                                                    ).
            end.
            when "character" then
            do:
    glog62 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,""
                                                    ).
            end.
         end case .
      end.
      else
    glog62 = buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,v-bh[buf2_temp-call-param.table-no]:buffer-field(buf2_temp-call-param.field-name_):buffer-value
                                                    ).
  end.
  assign
  buf_temp-call-param.call-number = buf_temp-call-param.call-number + 1
  v-last-call-number = buf_temp-call-param.call-number
  v-last-call-name = buf_temp-call-param.call-name_
  .
  buf_temp-call-param.call-handle_:invoke.
    if buf_temp-call-param.call-handle_:return-value = ? then
    do:
       v-dt-tp62 = v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):data-type .
       if v-dt-tp62 = "decimal" or v-dt-tp62 = "integer" then
       do:
v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):buffer-value = 0 .
       end.
    end.
    else
    do:
  v-bh[buf_temp-call-param.table-no]:buffer-field(buf_temp-call-param.field-name_):buffer-value = buf_temp-call-param.call-handle_:return-value.
    end.
  if v-inversed then do:
    v-bh[6]:buffer-field("object-sum"):buffer-value =
    v-bh[6]:buffer-field("object-sum"):buffer-value   .
  end.
  if v-bh[6]:buffer-field("value-type"):buffer-value =  integer('1':U) then do:
  end.
  else do:
    v-bh[6]:buffer-field("discnt-value-pcnt"):buffer-value =
              v-bh[6]:buffer-field("discnt-value-abs"):buffer-value /
              v-bh[6]:buffer-field("object-sum"):buffer-value * 100
              .
  end.
  assign
  v-delta-discnt-r-b = v-bh[6]:buffer-field("discnt-value-abs"):buffer-value
  .
  if v-bh[1]:buffer-field("r-b"):buffer-value = 'rubl':U then do:
    assign
    v-delta-discnt-rubl = v-delta-discnt-r-b
    v-new-rubl-sum = v-rubl-sum - v-delta-discnt-rubl * integer(not v-inversed)
    v-new-discnt-rubl = v-discnt-rubl + v-delta-discnt-rubl
    .
    if v-bh[1]:buffer-field("base-code"):buffer-value = 0 then do:
      assign
      v-delta-discnt-base = v-delta-discnt-r-b
      v-new-base-sum = v-base-sum - v-delta-discnt-base * integer(not v-inversed)
      v-new-discnt-base = v-discnt-base + v-delta-discnt-base
      .
    end.
    else do:
      assign
      v-delta-discnt-base = v-delta-discnt-r-b * v-bh[2]:buffer-field("base-rate"):buffer-value
      v-new-base-sum = v-base-sum - v-delta-discnt-base * integer(not v-inversed)
      v-new-discnt-base = v-discnt-base + v-delta-discnt-base
      .
    end.
  end.
  else do:
    assign
    v-delta-discnt-base = v-delta-discnt-r-b
    v-new-base-sum = v-base-sum - v-delta-discnt-base  * integer(not v-inversed)
    v-new-discnt-base = v-discnt-base + v-delta-discnt-base
    .
    if  v-bh[1]:buffer-field("base-code"):buffer-value = 0 then do:
      assign
      v-delta-discnt-rubl = v-delta-discnt-r-b
      v-new-rubl-sum = v-rubl-sum - v-delta-discnt-base * integer(not v-inversed)
      v-new-discnt-rubl = v-discnt-rubl + v-delta-discnt-base
      .
    end.
    else do:
      assign
      v-delta-discnt-base = v-delta-discnt-r-b / v-bh[2]:buffer-field("base-rate"):buffer-value
      v-new-base-sum = v-base-sum - v-delta-discnt-base * integer(not v-inversed)
      v-new-discnt-base = v-discnt-base + v-delta-discnt-base
      .
    end.
  end.
  if v-curr-code = 0 then do:
    assign
    v-delta-discnt-curr = v-delta-discnt-rubl
    v-new-curr-sum = v-curr-sum - v-delta-discnt-curr * integer(not v-inversed)
    v-new-discnt-curr = v-discnt-curr + v-delta-discnt-curr
    .
  end.
  else do:
    if v-curr-code = v-bh[1]:buffer-field("base-code"):buffer-value then do:
      assign
      v-delta-discnt-curr = v-delta-discnt-base
      v-new-curr-sum = v-curr-sum - v-delta-discnt-curr  * integer(not v-inversed)
      v-new-discnt-curr = v-discnt-curr + v-delta-discnt-curr
      .
    end.
    else do:
      assign
      v-delta-discnt-curr = v-delta-discnt-rubl / v-bh[5]:buffer-field("exch-rate"):buffer-value * v-bh[5]:buffer-field("exch-scale"):buffer-value
      v-new-curr-sum = v-curr-sum - v-delta-discnt-curr * integer(not v-inversed)
      v-new-discnt-curr = v-discnt-curr + v-delta-discnt-curr
      .
    end.
  end.
  if v-bh[6]:buffer-field("intended"):buffer-value = no
  and v-bh[6]:buffer-field("not-found"):buffer-value = no
  then do:
    if v-inversed then do:
      create buf_chk-discnt.
      buffer buf_chk-discnt:handle:buffer-copy(v-bh[6]).
      if buf_temp-discnt-role.table-name = 'dis-cp-rule':U then do:
        assign
        buffer buf_chk-discnt:handle:buffer-field("object-sum"):buffer-value = v-bh[2]:buffer-field("netto"):buffer-value
        .
      end.
      run printbuffer in this-procedure ( input v-bh[6]).
      release buf_chk-discnt.
    end.
    v-bh[6]:buffer-release().
    v-found = yes.
  end.
  else do:
    v-bh[6]:buffer-delete().
    v-found = no.
  end.
end.
            if v-found then leave _cycle.
          end.
        end.
      end case.
    end.
    if v-found and not p-add-discnts then do:
      leave _roles.
    end.
  end.
end.
end.
end procedure.
procedure load-ruleset-context :
define variable v-subject-type as integer no-undo .
define variable v-found as logical no-undo .
define variable v-vh as handle no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_temp-rule-by-call for temp-rule-by-call.
define buffer buf_temp-discnt-role for temp-discnt-role.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf2_dis-cfg-rule for ub.dis-cfg-rule.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  for each buf_temp-rule-call-param:
    delete buf_temp-rule-call-param.
  end.
  for each buf_temp-rule-by-call:
    delete buf_temp-rule-by-call.
  end.
  for each buf_rule-call-param no-lock where
          buf_rule-call-param.profile_id = p-profile-id
      and buf_rule-call-param.once-more = p-once-more
      and buf_rule-call-param.call_id = p-call-id
  break
  by buf_rule-call-param.call_id
  by buf_rule-call-param.codex_id
  by buf_rule-call-param.ruleset_id
  by buf_rule-call-param.order_id
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if first-of(buf_rule-call-param.order_id)  then do:
      v-found = no.
    end.
    create buf_temp-rule-call-param.
    buffer-copy buf_rule-call-param to buf_temp-rule-call-param.
    if (lookup(buf_temp-rule-call-param.param-3-data-type, "LIST") = 0
    and lookup(buf_temp-rule-call-param.param-3-data-type, "SORTED-LIST") = 0
    )
    or buf_temp-rule-call-param.p-index > 0 then do:
      if lookup(buf_temp-rule-call-param.param-2-data-type, 'gds-discnt-role,subtotal-discnt-role,pay-discnt-role':U) > 0
      then do:
        case buf_temp-rule-call-param.param-2-data-type:
          when 'gds-discnt-role':U then do:
            assign
            v-subject-type = integer('1':U).
          end.
          when 'subtotal-discnt-role':U then do:
            assign
            v-subject-type = integer('2':U).
          end.
          when 'pay-discnt-role':U then do:
            assign
            v-subject-type = integer('5':U).
          end.
        end case.
        for each buf_dis-cfg-rule no-lock where
                    buf_dis-cfg-rule.discnt-role = buf_temp-rule-call-param.param-value-character
                and buf_dis-cfg-rule.pos-type = p-pos-type-for-discnt
             and buf_dis-cfg-rule.subject-type = v-subject-type :
          if buf_dis-cfg-rule.link-prop <> integer('0':U)
          and buf_dis-cfg-rule.link-prop <> integer('-1':U) then next.
          assign
          v-vh = p-bh[1]:buffer-field("how-" + buf_temp-rule-call-param.param-value-character) no-error.
          if valid-handle(v-vh)
          and buf_dis-cfg-rule.discnt-role <> p-bh[1]:buffer-field("how-" + buf_temp-rule-call-param.param-value-character):buffer-value
          then next.
          find first buf_temp-discnt-role where
                  buf_temp-discnt-role.codex_id = buf_temp-rule-call-param.codex_id
              and buf_temp-discnt-role.ruleset_id = buf_temp-rule-call-param.ruleset_id
              and buf_temp-discnt-role.order_id = buf_temp-rule-call-param.order_id
              and buf_temp-discnt-role.rule_id = buf_temp-rule-call-param.rule_id
              and buf_temp-discnt-role.pos-type = p-pos-type-for-discnt
              and buf_temp-discnt-role.discnt-role = buf_temp-rule-call-param.param-value-character
              and buf_temp-discnt-role.table-name = buf_dis-cfg-rule.table-name
              no-error.
          if not available buf_temp-discnt-role then do:
            create buf_temp-discnt-role.
            assign
            buf_temp-discnt-role.codex_id = buf_temp-rule-call-param.codex_id
            buf_temp-discnt-role.ruleset_id = buf_temp-rule-call-param.ruleset_id
            buf_temp-discnt-role.order_id = buf_temp-rule-call-param.order_id
            buf_temp-discnt-role.rule_id = buf_temp-rule-call-param.rule_id
            buf_temp-discnt-role.once-more = buf_temp-rule-call-param.once-more
            buf_temp-discnt-role.pos-type = p-pos-type-for-discnt
            buf_temp-discnt-role.subject-type = v-subject-type
            buf_temp-discnt-role.discnt-role = buf_temp-rule-call-param.param-value-character
            buf_temp-discnt-role.discnt-type = buf_Dis-cfg-rule.discnt-type
            buf_temp-discnt-role.table-name = buf_Dis-cfg-rule.table-name
            buf_temp-discnt-role.has-glob = buf_Dis-cfg-rule.has-glob
            buf_temp-discnt-role.has-host = buf_Dis-cfg-rule.has-host
            buf_temp-discnt-role.has-obj = buf_Dis-cfg-rule.has-obj
            buf_temp-discnt-role.link-prop = buf_Dis-cfg-rule.link-prop
            buf_temp-discnt-role.templ-rl-root = (if buf_Dis-cfg-rule.link-prop = integer('-1':U)
                                                  then buf_dis-cfg-rule.templ-rl-root
                                                  else buf_temp-discnt-role.templ-rl-root)
            buf_temp-discnt-role.time-templ-rl-root = (if buf_Dis-cfg-rule.link-prop = integer('-1':U)
                                                  then buf_dis-cfg-rule.time-templ-rl-root
                                                  else buf_temp-discnt-role.time-templ-rl-root)
            .
            v-found = yes.
            if buf_temp-discnt-role.table-name = 'dis-grp-rule':U then do:
              assign
              p-bh[1]:buffer-field("is-grp-totals"):buffer-value = yes.
            end.
          end.
        end.
      end.
    end.
    if last-of(buf_rule-call-param.order_id) then do:
      if v-found = no then do:
        create buf_temp-discnt-role.
        assign
        buf_temp-discnt-role.codex_id = buf_temp-rule-call-param.codex_id
        buf_temp-discnt-role.ruleset_id = buf_temp-rule-call-param.ruleset_id
        buf_temp-discnt-role.order_id = buf_temp-rule-call-param.order_id
        buf_temp-discnt-role.rule_id = buf_temp-rule-call-param.rule_id
        buf_temp-discnt-role.once-more = buf_temp-rule-call-param.once-more
        buf_temp-discnt-role.discnt-type = 0
        buf_temp-discnt-role.subject-type = 0
        buf_temp-discnt-role.discnt-role = ''
        .
      end.
    end.
  end.
  for each buf_rule-by-call no-lock where
          buf_rule-by-call.profile_id = p-profile-id
      and buf_rule-by-call.once-more = p-once-more
      and buf_rule-by-call.call_id = p-call-id
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    create buf_temp-rule-by-call.
    buffer-copy buf_rule-by-call to buf_temp-rule-by-call.
  end.
  assign
  v-current-host-code = p-host-code
  v-current-obj-type = p-obj-type
  v-current-obj-code = p-obj-code
  v-current-db-num = g#db-num
  v-current-pos-type = p-pos-type
  v-current-pos-type-for-discnt = p-pos-type-for-discnt
  .
end.
end procedure.
procedure rp-chk-doc_set-log :
define input parameter p-lock-log-handle as handle no-undo .
main-block:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  p-log-handle = p-lock-log-handle.
end.
end.
