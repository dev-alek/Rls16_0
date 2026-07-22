block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-is-dynamic as logical no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-process-file-name as character no-undo .
define input parameter p-save       as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Импорт/изменение клиентов по списку".
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
FUNCTION gbclcode-is-this-db-code returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'u'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code no-error .
if available buf_code-range then return yes.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and  buf_code-range.stts = 'a'
      and buf_code-range.first-code <= p-code
      no-error .
 if available buf_code-range then return yes.
end.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'f'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code
    no-error .
if available buf_code-range then return yes.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-code-short returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and buf_code-range.first-code <= p-code
      and buf_code-range.last-code >= p-code no-error .
  if available buf_code-range then return yes.
end.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-role returns integer ( input p-role as character
                                                    ,input p-db-num as integer
                                                    ,input p-staff-code as integer
                                                    ,input p-date as date
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
      and buf_staff.staff-code = p-staff-code
      and buf_staff.date-end >= p-date use-index pi  no-error .
if available buf_staff then do:
  return buf_staff.psn-code.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-this-db-first-role returns integer ( input p-role as character
                                                          ,input p-db-num as integer
                                                          ,input p-date as date
                                                              ):
define buffer buf_staff for ub.staff.
define buffer buf2_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each  buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.db-num = p-db-num,
first buf2_staff no-lock where
      buf2_staff.role = p-role
  and buf2_staff.role-level = 'db':U
  and buf2_staff.staff-code = buf_staff.staff-code
  and buf2_staff.date-start <= p-date
  and buf2_staff.date-end >= p-date
by buf_staff.staff-code
by date-start descending:
  return buf_staff.staff-code.
end.
end FUNCTION.
FUNCTION gbclcode-get-db-role returns integer ( input p-role as character
                                               ,input p-db-num as integer
                                               ,input p-psn-code as integer
                                               ,input p-date as date
                                               ,output p-c-password as character
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
     and buf_staff.date-end >= p-date
     and buf_staff.psn-code = p-psn-code use-index irole-psn no-error .
if available buf_staff
then do:
  assign
  p-c-password = buf_staff.password.
  return buf_staff.staff-code.
end.
p-c-password = ''.
return 0.
end FUNCTION.
FUNCTION gbclcode-is-psn-role returns integer (
                                              input p-role as character
                                              ,input p-psn-code as integer
                                              ,input p-date as date
                                                  ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each buf_staff no-lock where
          buf_staff.psn-code = p-psn-code
     and  buf_staff.role = p-role
by buf_staff.role-level
by buf_staff.date-start
     :
  if  buf_staff.date-start <= p-date and
  buf_staff.date-end >= p-date  then do:
    return buf_staff.staff-code.
  end.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-role-name returns character ( input p-role as character):
define variable v-role-name as character no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
no-error .
return v-role-name.
END.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-get-position returns character ( input p-role as character
                                                  ,input p-role-level as character
                                                  ,input p-work-place as character
                                                  ,input p-staff-code as integer
                                                             ):
define variable v-role-name as character no-undo .
define variable v-role-level as character no-undo .
define variable v-staff-code as integer no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
v-role-level = substitute("&1 &2", entry (lookup (p-role-level, 'global,db,firm,object':U) + 1, ',':U + 'Глобально,БД,Фирма,Объект':U) , p-work-place)
v-staff-code = p-staff-code
no-error .
return substitute("&1, &2, Код &3"
                ,v-role-name
                ,v-role-level
                ,(if p-staff-code = 0 then chr(63) else string(p-staff-code))).
END.
FUNCTION gbclcode-get-work-place returns character (
                                                input p-role as character
                                               ,input p-role-level as character
                                               ,input p-db-num as integer
                                               ,input p-host-code as integer
                                               ,input p-obj-type as character
                                               ,input p-obj-code as integer
                                               ) :
define variable v-work-place as character no-undo .
define variable v-obj-type as character no-undo .
  case p-role-level:
    when 'db':U then do:
      v-work-place = string(p-db-num, "99999").
    end.
    when 'firm':U then do:
      v-work-place = string(p-host-code, "99999").
    end.
    when 'object':U then do:
      assign
      v-work-place = p-obj-type + string(p-obj-code, "999999999")
      .
    end.
  END CASE.
  return v-work-place.
END FUNCTION.
FUNCTION gbclcode-get-level-last-code returns integer (
                                                        input p-role as character
                                                      , input p-role-level as character
                                                      , input p-work-place as character
                                                      , input p-date-start as date
                                                      ):
DEFINE VARIABLE v-today as date no-undo .
define buffer buf_staff for ub.staff.
if p-work-place = chr(63) then return ?.
if p-date-start = ? then do:
  v-today = today .
end.
else do:
  v-today = p-date-start.
end.
find last buf_staff no-lock where
          buf_staff.role = p-role
     and  buf_staff.role-level = p-role-level
     and  buf_staff.work-place = p-work-place
     and  buf_staff.date-start <= v-today + 1
     and  buf_staff.date-end >= v-today + 1
     use-index pi  no-error .
if available buf_staff
then return buf_staff.staff-code.
return 0.
end FUNCTION.
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
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
define stream getmc-stream .
procedure get-max-code :
  define input  parameter p-action         as   character                 no-undo .
  define input  parameter p-db-num         like ub.db.db-num             no-undo .
  define input  parameter p-curr-type-cdrg like ub.code-range.range-type no-undo .
  define input  parameter p-first-code     like ub.code-range.first-code no-undo .
  define input  parameter p-last-code      like ub.code-range.last-code  no-undo .
  define input  parameter p-view-mess      as   logical                   no-undo .
  define output parameter v-b-code         as   integer                   no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-main-bcode     like ub.bar-code.b-code no-undo .
    define variable l-prod-bc-global as   logical             no-undo .
    define variable l-prod-bc-weight as   logical             no-undo .
    define variable l-prod-bc-pgweight as   logical             no-undo .
    define variable rec-cnt          as   integer             no-undo .
    define variable str-u-f          as   character           no-undo .
    define variable str-u-f-rng      as   character           no-undo .
    define variable ind              as   integer             no-undo .
    define variable v-msg              as   character           no-undo initial "":U.
    define variable v-ret-msg          as   character           no-undo initial "":U.
    define frame get-max-code-inf
      rec-cnt label "Просмотрено"
      with view-as dialog-box side-labels row 11 centered
      title "..........................................." three-d
    .
    define buffer buf_code-range   for ub.code-range .
    define buffer buf-c_code-range for ub.code-range .
    define buffer buf_bar-code     for ub.bar-code .
    define buffer buf_place        for ub.place .
    define buffer buf_goods        for ub.goods .
    define buffer buf_units        for ub.units .
    define buffer buf_prod-bc      for ub.prod-bc .
    define buffer buf_dis-card     for ub.dis-card .
    define buffer buf_dis-rule     for ub.dis-rule .
    define buffer buf_dis-time-rule     for ub.dis-time-rule .
    define buffer buf_firm         for ub.firm .
    define buffer buf_person       for ub.person .
    define buffer buf_contract     for ub.contract .
    if p-curr-type-cdrg = 'sslc':U
    or p-curr-type-cdrg = 'ssgb':U
    then do:
      assign
        v-b-code = ?
      .
      return.
    end.
    if p-curr-type-cdrg = 'sclc':U
    or p-curr-type-cdrg = 'pglc':U
      or p-curr-type-cdrg = 'sslc':U
    then do:
      assign
        p-db-num = 0
      .
    end.
    case p-action :
      when "get-m-code":U then do:
        assign
          v-b-code = p-first-code
        .
      end.
      when "f-u":U then do:
        assign
          v-b-code = 0
        .
      end.
    end case.
    case p-curr-type-cdrg :
      when 'dcgb':U then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii3 as integer   no-undo .
define variable v-table-name3 as character no-undo .
define variable v-field-name3 as character no-undo .
define variable buf_h3 as handle no-undo .
define variable q_h3 as handle no-undo .
define variable v-avail3 as integer   no-undo .
define variable v-code-mess3 as character no-undo .
define variable glog3 as logical   no-undo .
define variable v-code_3 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii3 = 1 to num-entries('ub.dis-card'):
      assign
      v-table-name3 = entry(v-ii3, 'ub.dis-card')
      v-field-name3 = entry(v-ii3, 'card-num')
      .
      create buffer buf_h3 for table v-table-name3.
      create query q_h3.
      q_h3:SET-BUFFERS(buf_h3).
      q_h3:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name3
                        ,v-field-name3
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h3:QUERY-OPEN.
      REPEAT while  q_h3:get-next().
        assign
          v-code_3 = buf_h3:buffer-field(v-field-name3):buffer-value
        .
        leave .
      END.
      q_h3:QUERY-CLOSE().
      delete object q_h3.
      delete object buf_h3.
      v-b-code = max(v-code_3, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail3 = 0.
      do v-ii3 = 1 to num-entries('ub.dis-card'):
        assign
        v-table-name3 = entry(v-ii3, 'ub.dis-card')
        v-field-name3 = entry(v-ii3, 'card-num')
        .
        create buffer buf_h3 for table v-table-name3.
        glog3 = buf_h3:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name3
                                , v-field-name3
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h3:available then do:
          assign
          v-avail3 = v-avail3 + 1
          .
          if v-avail3 = 1 then do:
            v-code-mess3 = string(buf_h3:buffer-field(v-field-name3):buffer-value)
            .
          end.
        end.
        delete object buf_h3.
     end.
     if v-avail3 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess3
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail3 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'ctgb':U then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii4 as integer   no-undo .
define variable v-table-name4 as character no-undo .
define variable v-field-name4 as character no-undo .
define variable buf_h4 as handle no-undo .
define variable q_h4 as handle no-undo .
define variable v-avail4 as integer   no-undo .
define variable v-code-mess4 as character no-undo .
define variable glog4 as logical   no-undo .
define variable v-code_4 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii4 = 1 to num-entries('ub.contract'):
      assign
      v-table-name4 = entry(v-ii4, 'ub.contract')
      v-field-name4 = entry(v-ii4, 'contract-code')
      .
      create buffer buf_h4 for table v-table-name4.
      create query q_h4.
      q_h4:SET-BUFFERS(buf_h4).
      q_h4:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name4
                        ,v-field-name4
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h4:QUERY-OPEN.
      REPEAT while  q_h4:get-next().
        assign
          v-code_4 = buf_h4:buffer-field(v-field-name4):buffer-value
        .
        leave .
      END.
      q_h4:QUERY-CLOSE().
      delete object q_h4.
      delete object buf_h4.
      v-b-code = max(v-code_4, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail4 = 0.
      do v-ii4 = 1 to num-entries('ub.contract'):
        assign
        v-table-name4 = entry(v-ii4, 'ub.contract')
        v-field-name4 = entry(v-ii4, 'contract-code')
        .
        create buffer buf_h4 for table v-table-name4.
        glog4 = buf_h4:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name4
                                , v-field-name4
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h4:available then do:
          assign
          v-avail4 = v-avail4 + 1
          .
          if v-avail4 = 1 then do:
            v-code-mess4 = string(buf_h4:buffer-field(v-field-name4):buffer-value)
            .
          end.
        end.
        delete object buf_h4.
     end.
     if v-avail4 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess4
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail4 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'cagb':U then do:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii5 as integer   no-undo .
define variable v-table-name5 as character no-undo .
define variable v-field-name5 as character no-undo .
define variable buf_h5 as handle no-undo .
define variable q_h5 as handle no-undo .
define variable v-avail5 as integer   no-undo .
define variable v-code-mess5 as character no-undo .
define variable glog5 as logical   no-undo .
define variable v-code_5 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii5 = 1 to num-entries('ub.rule-by-call'):
      assign
      v-table-name5 = entry(v-ii5, 'ub.rule-by-call')
      v-field-name5 = entry(v-ii5, 'call#_id')
      .
      create buffer buf_h5 for table v-table-name5.
      create query q_h5.
      q_h5:SET-BUFFERS(buf_h5).
      q_h5:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name5
                        ,v-field-name5
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h5:QUERY-OPEN.
      REPEAT while  q_h5:get-next().
        assign
          v-code_5 = buf_h5:buffer-field(v-field-name5):buffer-value
        .
        leave .
      END.
      q_h5:QUERY-CLOSE().
      delete object q_h5.
      delete object buf_h5.
      v-b-code = max(v-code_5, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail5 = 0.
      do v-ii5 = 1 to num-entries('ub.rule-by-call'):
        assign
        v-table-name5 = entry(v-ii5, 'ub.rule-by-call')
        v-field-name5 = entry(v-ii5, 'call#_id')
        .
        create buffer buf_h5 for table v-table-name5.
        glog5 = buf_h5:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name5
                                , v-field-name5
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h5:available then do:
          assign
          v-avail5 = v-avail5 + 1
          .
          if v-avail5 = 1 then do:
            v-code-mess5 = string(buf_h5:buffer-field(v-field-name5):buffer-value)
            .
          end.
        end.
        delete object buf_h5.
     end.
     if v-avail5 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess5
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail5 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'fdgb':U then do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii6 as integer   no-undo .
define variable v-table-name6 as character no-undo .
define variable v-field-name6 as character no-undo .
define variable buf_h6 as handle no-undo .
define variable q_h6 as handle no-undo .
define variable v-avail6 as integer   no-undo .
define variable v-code-mess6 as character no-undo .
define variable glog6 as logical   no-undo .
define variable v-code_6 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii6 = 1 to num-entries('ub.fin-doc'):
      assign
      v-table-name6 = entry(v-ii6, 'ub.fin-doc')
      v-field-name6 = entry(v-ii6, 'fin-doc-code')
      .
      create buffer buf_h6 for table v-table-name6.
      create query q_h6.
      q_h6:SET-BUFFERS(buf_h6).
      q_h6:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name6
                        ,v-field-name6
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h6:QUERY-OPEN.
      REPEAT while  q_h6:get-next().
        assign
          v-code_6 = buf_h6:buffer-field(v-field-name6):buffer-value
        .
        leave .
      END.
      q_h6:QUERY-CLOSE().
      delete object q_h6.
      delete object buf_h6.
      v-b-code = max(v-code_6, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail6 = 0.
      do v-ii6 = 1 to num-entries('ub.fin-doc'):
        assign
        v-table-name6 = entry(v-ii6, 'ub.fin-doc')
        v-field-name6 = entry(v-ii6, 'fin-doc-code')
        .
        create buffer buf_h6 for table v-table-name6.
        glog6 = buf_h6:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name6
                                , v-field-name6
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h6:available then do:
          assign
          v-avail6 = v-avail6 + 1
          .
          if v-avail6 = 1 then do:
            v-code-mess6 = string(buf_h6:buffer-field(v-field-name6):buffer-value)
            .
          end.
        end.
        delete object buf_h6.
     end.
     if v-avail6 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess6
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail6 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'fmgb':U then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii7 as integer   no-undo .
define variable v-table-name7 as character no-undo .
define variable v-field-name7 as character no-undo .
define variable buf_h7 as handle no-undo .
define variable q_h7 as handle no-undo .
define variable v-avail7 as integer   no-undo .
define variable v-code-mess7 as character no-undo .
define variable glog7 as logical   no-undo .
define variable v-code_7 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii7 = 1 to num-entries('ub.firm'):
      assign
      v-table-name7 = entry(v-ii7, 'ub.firm')
      v-field-name7 = entry(v-ii7, 'firm-code')
      .
      create buffer buf_h7 for table v-table-name7.
      create query q_h7.
      q_h7:SET-BUFFERS(buf_h7).
      q_h7:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name7
                        ,v-field-name7
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h7:QUERY-OPEN.
      REPEAT while  q_h7:get-next().
        assign
          v-code_7 = buf_h7:buffer-field(v-field-name7):buffer-value
        .
        leave .
      END.
      q_h7:QUERY-CLOSE().
      delete object q_h7.
      delete object buf_h7.
      v-b-code = max(v-code_7, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail7 = 0.
      do v-ii7 = 1 to num-entries('ub.firm'):
        assign
        v-table-name7 = entry(v-ii7, 'ub.firm')
        v-field-name7 = entry(v-ii7, 'firm-code')
        .
        create buffer buf_h7 for table v-table-name7.
        glog7 = buf_h7:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name7
                                , v-field-name7
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h7:available then do:
          assign
          v-avail7 = v-avail7 + 1
          .
          if v-avail7 = 1 then do:
            v-code-mess7 = string(buf_h7:buffer-field(v-field-name7):buffer-value)
            .
          end.
        end.
        delete object buf_h7.
     end.
     if v-avail7 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess7
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail7 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'pngb':U then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii8 as integer   no-undo .
define variable v-table-name8 as character no-undo .
define variable v-field-name8 as character no-undo .
define variable buf_h8 as handle no-undo .
define variable q_h8 as handle no-undo .
define variable v-avail8 as integer   no-undo .
define variable v-code-mess8 as character no-undo .
define variable glog8 as logical   no-undo .
define variable v-code_8 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii8 = 1 to num-entries('ub.person'):
      assign
      v-table-name8 = entry(v-ii8, 'ub.person')
      v-field-name8 = entry(v-ii8, 'psn-code')
      .
      create buffer buf_h8 for table v-table-name8.
      create query q_h8.
      q_h8:SET-BUFFERS(buf_h8).
      q_h8:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name8
                        ,v-field-name8
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h8:QUERY-OPEN.
      REPEAT while  q_h8:get-next().
        assign
          v-code_8 = buf_h8:buffer-field(v-field-name8):buffer-value
        .
        leave .
      END.
      q_h8:QUERY-CLOSE().
      delete object q_h8.
      delete object buf_h8.
      v-b-code = max(v-code_8, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail8 = 0.
      do v-ii8 = 1 to num-entries('ub.person'):
        assign
        v-table-name8 = entry(v-ii8, 'ub.person')
        v-field-name8 = entry(v-ii8, 'psn-code')
        .
        create buffer buf_h8 for table v-table-name8.
        glog8 = buf_h8:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name8
                                , v-field-name8
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h8:available then do:
          assign
          v-avail8 = v-avail8 + 1
          .
          if v-avail8 = 1 then do:
            v-code-mess8 = string(buf_h8:buffer-field(v-field-name8):buffer-value)
            .
          end.
        end.
        delete object buf_h8.
     end.
     if v-avail8 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess8
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail8 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'drgb':U then do:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii9 as integer   no-undo .
define variable v-table-name9 as character no-undo .
define variable v-field-name9 as character no-undo .
define variable buf_h9 as handle no-undo .
define variable q_h9 as handle no-undo .
define variable v-avail9 as integer   no-undo .
define variable v-code-mess9 as character no-undo .
define variable glog9 as logical   no-undo .
define variable v-code_9 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii9 = 1 to num-entries('ub.dis-rule,ub.dis-time-rule'):
      assign
      v-table-name9 = entry(v-ii9, 'ub.dis-rule,ub.dis-time-rule')
      v-field-name9 = entry(v-ii9, 'rule-num,time-rule-num')
      .
      create buffer buf_h9 for table v-table-name9.
      create query q_h9.
      q_h9:SET-BUFFERS(buf_h9).
      q_h9:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name9
                        ,v-field-name9
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h9:QUERY-OPEN.
      REPEAT while  q_h9:get-next().
        assign
          v-code_9 = buf_h9:buffer-field(v-field-name9):buffer-value
        .
        leave .
      END.
      q_h9:QUERY-CLOSE().
      delete object q_h9.
      delete object buf_h9.
      v-b-code = max(v-code_9, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail9 = 0.
      do v-ii9 = 1 to num-entries('ub.dis-rule,ub.dis-time-rule'):
        assign
        v-table-name9 = entry(v-ii9, 'ub.dis-rule,ub.dis-time-rule')
        v-field-name9 = entry(v-ii9, 'rule-num,time-rule-num')
        .
        create buffer buf_h9 for table v-table-name9.
        glog9 = buf_h9:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name9
                                , v-field-name9
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h9:available then do:
          assign
          v-avail9 = v-avail9 + 1
          .
          if v-avail9 = 1 then do:
            v-code-mess9 = string(buf_h9:buffer-field(v-field-name9):buffer-value)
            .
          end.
        end.
        delete object buf_h9.
     end.
     if v-avail9 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess9
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail9 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'bcgb':U then do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii10 as integer   no-undo .
define variable v-table-name10 as character no-undo .
define variable v-field-name10 as character no-undo .
define variable buf_h10 as handle no-undo .
define variable q_h10 as handle no-undo .
define variable v-avail10 as integer   no-undo .
define variable v-code-mess10 as character no-undo .
define variable glog10 as logical   no-undo .
define variable v-code_10 as integer   no-undo .
case p-action :
  when "get-m-code":U then do:
    do v-ii10 = 1 to num-entries('ub.bar-code,ub.place'):
      assign
      v-table-name10 = entry(v-ii10, 'ub.bar-code,ub.place')
      v-field-name10 = entry(v-ii10, 'b-code,pl-code')
      .
      create buffer buf_h10 for table v-table-name10.
      create query q_h10.
      q_h10:SET-BUFFERS(buf_h10).
      q_h10:QUERY-PREPARE(substitute(" for each &1 WHERE &1.&2 >= &3 and &1.&2 <= &4 by &1.&2 descending"
                        ,v-table-name10
                        ,v-field-name10
                        ,p-first-code
                        ,p-last-code)
                        ).
      q_h10:QUERY-OPEN.
      REPEAT while  q_h10:get-next().
        assign
          v-code_10 = buf_h10:buffer-field(v-field-name10):buffer-value
        .
        leave .
      END.
      q_h10:QUERY-CLOSE().
      delete object q_h10.
      delete object buf_h10.
      v-b-code = max(v-code_10, v-b-code).
    end.
  end.
  when "f-u":U then do:
    for each buf_code-range share-lock
        where ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "f":U
              ) or
              ( buf_code-range.range-type = p-curr-type-cdrg
                and buf_code-range.db-num = p-db-num
                and buf_code-range.stts = "u":U
              )
    on error undo, return error
    :
      v-avail10 = 0.
      do v-ii10 = 1 to num-entries('ub.bar-code,ub.place'):
        assign
        v-table-name10 = entry(v-ii10, 'ub.bar-code,ub.place')
        v-field-name10 = entry(v-ii10, 'b-code,pl-code')
        .
        create buffer buf_h10 for table v-table-name10.
        glog10 = buf_h10:find-first ( substitute(" where &1.&2 >= &3 and &1.&2 <= &4 "
                                , v-table-name10
                                , v-field-name10
                                , buf_code-range.first-code
                                , buf_code-range.last-code)
                                ) no-error .
        if buf_h10:available then do:
          assign
          v-avail10 = v-avail10 + 1
          .
          if v-avail10 = 1 then do:
            v-code-mess10 = string(buf_h10:buffer-field(v-field-name10):buffer-value)
            .
          end.
        end.
        delete object buf_h10.
     end.
     if v-avail10 > 0
        and buf_code-range.stts = "f":U
      then do:
        assign
          buf_code-range.stts = "u":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                            , v-code-mess10
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
      if v-avail10 = 0
        and buf_code-range.stts = "u":U
      then do:
        find first buf-c_code-range exclusive-lock
          where rowid( buf-c_code-range ) = rowid( buf_code-range )
        .
        assign
          buf-c_code-range.stts = "c":U
        .
        release buf-c_code-range .
        assign
          buf_code-range.stts = "f":U
          v-b-code            = v-b-code + 1
          v-msg               = substitute( "Диапазон кодов с &2 по &3&1"
                                            + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                            , chr(10)
                                            , buf_code-range.first-code
                                            , buf_code-range.last-code
                                          )
        .
        if p-view-mess = true then do:
          message
            v-msg
            view-as alert-box information.
        end.
        else do:
          output stream getmc-stream to "getmc.log" append.
          put stream getmc-stream unformatted
            string( today, "99/99/9999" ) space(1)
            string( time, "HH:MM:SS" ) space(1)
            v-msg skip
          .
          output stream getmc-stream close.
        end.
      end.
    end.
  end.
end case.
      end.
      when 'scgb':U
      or when 'sclc':U
      then do:
        case p-action :
          when "get-m-code":U then do:
            assign
              frame get-max-code-inf :title = "Поиск максимального значения кода"
            .
          end.
          when "f-u":U then do:
            assign
              frame get-max-code-inf :title = "Корректировка статуса code-range"
            .
            run mark-all-used-as-free in this-procedure (
                                       input  p-db-num
                                      ,input  p-curr-type-cdrg
                                      ,output str-u-f
                                      ,output str-u-f-rng
                                    ).
          end.
        end case.
        view frame get-max-code-inf.
        assign
          rec-cnt = 0
        .
        display
          rec-cnt
          with frame get-max-code-inf
        .
        for each buf_units no-lock
            where lookup('вес':U, buf_units.type) > 0
        on error undo, return error
        :
          for each buf_goods no-lock
            where buf_goods.unit-base = buf_units.unit-name
          on error undo, return error
          :
            assign
              rec-cnt = rec-cnt + 1
            .
            if ( rec-cnt modulo 10 ) = 0 then do:
              display
                rec-cnt
                with frame get-max-code-inf
              .
            end.
            run mc_gdsbcode in this-procedure (
                             input  buf_goods.gds-code
                            ,input  ?
                            ,output v-main-bcode
                          ) no-error .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при поиске корневого бар-кода" skip
                "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            for each buf_prod-bc no-lock
                where buf_prod-bc.b-code = v-main-bcode
            on error undo, return error
            :
              if p-curr-type-cdrg = 'sclc':U
                and buf_prod-bc.bc-on = FALSE
              then do:
                next.
              end.
              run mc_prodbcat in this-procedure (
                               buffer buf_prod-bc
                              ,input  'global=request':u
                              ,output l-prod-bc-global
                            ) no-error .
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
                  "Основной бар-код" buf_prod-bc.b-code skip
                  "Дополнительный бар-код" buf_prod-bc.b-str skip
                  "Действие global=request" skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error .
              end.
              run mc_prodbcat in this-procedure (
                               buffer buf_prod-bc
                              ,input  'weight=request':u
                              ,output l-prod-bc-weight
                            ) no-error .
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
                  "Основной бар-код" buf_prod-bc.b-code skip
                  "Дополнительный бар-код" buf_prod-bc.b-str skip
                  "Действие weight=request" skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error .
              end.
              if l-prod-bc-weight
                and ( ( l-prod-bc-global
                        and p-curr-type-cdrg = 'scgb':U
                      )
                      or
                      ( not l-prod-bc-global
                        and p-curr-type-cdrg = 'sclc':U
                      )
                    )
              then do:
                case p-action :
                  when "get-m-code":U then do:
                    if integer( buf_prod-bc.b-str ) >= p-first-code
                      and integer( buf_prod-bc.b-str ) <= p-last-code
                      and integer( buf_prod-bc.b-str ) > v-b-code
                    then do:
                      assign
                        v-b-code = integer( buf_prod-bc.b-str )
                      .
                    end.
                  end.
                  when "f-u":U then do:
                    for each buf_code-range
                      where buf_code-range.db-num     = p-db-num
                        and buf_code-range.range-type = p-curr-type-cdrg
                        and buf_code-range.stts       = "f":U
                        and buf_code-range.first-code <= integer( buf_prod-bc.b-str )
                        and buf_code-range.last-code  >= integer( buf_prod-bc.b-str )
                    on error undo, return error
                    :
                      assign
                        buf_code-range.stts = "u":U
                      .
                      if lookup( string( buf_code-range.first-code ) + "-":U + string( buf_code-range.last-code ), str-u-f-rng ) <> 0 then do:
                        assign
                          str-u-f-rng = diff-list( str-u-f-rng
                                                  ,string( buf_code-range.first-code ) + "-":U + string( buf_code-range.last-code )
                                                  ,",":U
                                                  )
                        .
                      end.
                      if lookup( buf_code-range.range-type + chr(3) + string( buf_code-range.first-code ), str-u-f ) = 0 then do:
                        assign
                          v-b-code = v-b-code + 1
                          v-msg     = substitute( "Диапазон кодов с &2 по &3&1"
                                                  + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                                  , chr(10)
                                                  , buf_code-range.first-code
                                                  , buf_code-range.last-code
                                                  , buf_prod-bc.b-str
                                                )
                          v-ret-msg = v-ret-msg + v-msg
                        .
                        if p-view-mess = true then do:
                          message
                            v-msg
                            view-as alert-box information.
                        end.
                      end.
                    end.
                  end.
                end case.
              end.
            end.
          end.
        end.
        if p-action = "f-u":U then do:
          do ind = 1 to num-entries( str-u-f-rng ):
            assign
              v-b-code  = v-b-code + 1
              v-msg     = substitute( "Диапазон кодов &2&1"
                                      + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                      , chr(10)
                                      , entry( ind, str-u-f-rng )
                                    )
              v-ret-msg = v-ret-msg + chr(10) + v-msg
            .
            if p-view-mess = true then do:
              message
                v-msg
                view-as alert-box information.
            end.
          end.
        end.
        hide frame get-max-code-inf no-pause .
      end.
      when 'pglc':U
      then do:
        case p-action :
          when "get-m-code":U then do:
            assign
              frame get-max-code-inf :title = "Поиск максимального значения кода"
            .
          end.
          when "f-u":U then do:
            assign
              frame get-max-code-inf :title = "Корректировка статуса code-range"
            .
            run mark-all-used-as-free in this-procedure (
                                       input  p-db-num
                                      ,input  p-curr-type-cdrg
                                      ,output str-u-f
                                      ,output str-u-f-rng
                                    ).
          end.
        end case.
        view frame get-max-code-inf.
        assign
          rec-cnt = 0
        .
        display
          rec-cnt
          with frame get-max-code-inf
        .
        for each buf_prod-bc no-lock where
                buf_prod-bc.b-str >= "00100"
            and buf_prod-bc.b-str <= "99999"
            and buf_prod-bc.bc-on-type = 'pglc':U
            and length(buf_prod-bc.b-str) = 5
        on error undo, return error
        :
            assign
              rec-cnt = rec-cnt + 1
            .
            if ( rec-cnt modulo 10 ) = 0 then do:
              display
                rec-cnt
                with frame get-max-code-inf
              .
            end.
            if p-curr-type-cdrg = 'pglc':U
              and buf_prod-bc.bc-on = FALSE
            then do:
              next.
            end.
            run mc_prodbcat in this-procedure (
                              buffer buf_prod-bc
                            ,input  'pgweight=request':u
                            ,output l-prod-bc-pgweight
                          ) no-error .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
                "Основной бар-код" buf_prod-bc.b-code skip
                "Дополнительный бар-код" buf_prod-bc.b-str skip
                "Действие weight=request" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            if l-prod-bc-pgweight
            and p-curr-type-cdrg = 'pglc':U
            then do:
              case p-action :
                when "get-m-code":U then do:
                  if integer( buf_prod-bc.b-str ) >= p-first-code
                    and integer( buf_prod-bc.b-str ) <= p-last-code
                    and integer( buf_prod-bc.b-str ) > v-b-code
                  then do:
                    assign
                      v-b-code = integer( buf_prod-bc.b-str )
                    .
                  end.
                end.
                when "f-u":U then do:
                  for each buf_code-range
                    where buf_code-range.db-num     = p-db-num
                      and buf_code-range.range-type = p-curr-type-cdrg
                      and buf_code-range.stts       = "f":U
                      and buf_code-range.first-code <= integer( buf_prod-bc.b-str )
                      and buf_code-range.last-code  >= integer( buf_prod-bc.b-str )
                  on error undo, return error
                  :
                  assign
                  buf_code-range.stts = "u":U
                    .
                  if lookup( string( buf_code-range.first-code ) + "-":U + string( buf_code-range.last-code ), str-u-f-rng ) <> 0 then do:
                      assign
                        str-u-f-rng = diff-list( str-u-f-rng
                                                ,string( buf_code-range.first-code ) + "-":U + string( buf_code-range.last-code )
                                                ,",":U
                                                )
                      .
                  end.
                  if lookup( buf_code-range.range-type + chr(3) + string( buf_code-range.first-code ), str-u-f ) = 0 then do:
                      assign
                        v-b-code = v-b-code + 1
                        v-msg     = substitute( "Диапазон кодов с &2 по &3&1"
                                                + "Помечен как 'u' т.к. существующий код &4 попадает в данный диапазон.&1"
                                                , chr(10)
                                                , buf_code-range.first-code
                                                , buf_code-range.last-code
                                                , buf_prod-bc.b-str
                                              )
                        v-ret-msg = v-ret-msg + v-msg
                      .
                    if p-view-mess = true then do:
                      message
                        v-msg
                        view-as alert-box information.
                    end.
                  end.
                end.
              end.
            end case.
          end.
        end.
        if p-action = "f-u":U then do:
          do ind = 1 to num-entries( str-u-f-rng ):
            assign
              v-b-code = v-b-code + 1
              v-msg     = substitute( "Диапазон кодов &2&1"
                                      + "Помечен как 'f' т.к. нет ни одного кода который попадает в данный диапазон.&1"
                                      , chr(10)
                                      , entry( ind, str-u-f-rng )
                                    )
              v-ret-msg = v-ret-msg + chr(10) + v-msg
            .
            if p-view-mess = true then do:
              message
                v-msg
                view-as alert-box information.
            end.
          end.
        end.
        hide frame get-max-code-inf no-pause .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "get-max-code" skip
          "Непредусмотрена обработка диапазона кодов " p-curr-type-cdrg
          view-as alert-box error.
        return error.
      end.
    end case.
  end.
  return v-ret-msg.
end procedure.
procedure mark-all-used-as-free :
  define input  parameter p-db-num         like ub.db.db-num             no-undo .
  define input  parameter p-curr-type-cdrg like ub.code-range.range-type no-undo .
  define output parameter p-str-u-f        as   character                 no-undo .
  define output parameter p-str-u-f-rng    as   character                 no-undo .
  do
  on error undo, return error
  :
    define buffer buf_code-range   for ub.code-range.
    define buffer buf-c_code-range for ub.code-range .
    assign
      p-str-u-f     = "":U
      p-str-u-f-rng = "":U
    .
    for each buf_code-range share-lock
        where buf_code-range.db-num     = p-db-num
          and buf_code-range.range-type = p-curr-type-cdrg
          and buf_code-range.stts       = "u":U
    on error undo, return error
    :
      find first buf-c_code-range exclusive-lock
        where rowid( buf-c_code-range ) = rowid( buf_code-range )
      .
      assign
        buf-c_code-range.stts = "c":U
      .
      release buf-c_code-range .
      assign
        buf_code-range.stts = "f":U
        p-str-u-f     = p-str-u-f + ",":U + buf_code-range.range-type + chr(3) + string( buf_code-range.first-code )
        p-str-u-f-rng = p-str-u-f-rng + ",":U + string( buf_code-range.first-code ) + "-":U + string( buf_code-range.last-code )
      .
    end.
    assign
      p-str-u-f     = substring( p-str-u-f, 2, length( p-str-u-f ) - 1 )
      p-str-u-f-rng = substring( p-str-u-f-rng, 2, length( p-str-u-f-rng ) - 1 )
    .
  end.
end procedure.
procedure mc_prodbcat :
  do
  on error undo, return error
  :
    define parameter buffer buf_prod-bc  for ub.prod-bc .
    define input  parameter p-action           as character no-undo .
    define output parameter p-return-attribute as logical no-undo .
    def var vss-description as character no-undo init "prodbcat-01: определение параметров дополнительного бар-кода".
    define buffer buf_bar-code   for ub.bar-code   .
    define buffer buf_units      for ub.units      .
    define buffer buf_code-range for ub.code-range .
    define variable p-code-int as integer no-undo .
    define variable v-cdrg-type as character no-undo .
    if not available buf_prod-bc then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задан дополнительный бар-код" skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_bar-code no-lock
      where buf_bar-code.b-code = buf_prod-bc.b-code
      no-error .
    if not available buf_bar-code then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильная ссылка на основной бар-код" skip
        "Основной бар-код" buf_prod-bc.b-code skip
        "Дополнительный бар-код" buf_prod-bc.b-str skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_units no-lock
      where buf_units.unit-name = buf_bar-code.unit-cli
      no-error .
    if not available buf_units then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена единица измерения основного бар-кода" skip
        "Основной бар-код" buf_bar-code.b-code skip
        "Единица измерения" buf_bar-code.unit-cli skip
        view-as alert-box error .
      undo, return error .
    end.
    def var ind                    as integer   no-undo .
    def var v-num-entries-p-action as integer   no-undo .
    def var v-action               as character no-undo .
    assign
      v-num-entries-p-action = num-entries(p-action)
    .
    assign
      p-return-attribute = true
    .
    _ind:
    do ind = 1 to v-num-entries-p-action
    :
     if ind > 1 and p-return-attribute = false then return.
      assign
        v-action = entry(ind, p-action)
      .
      case v-action :
        when "global=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = ''
          or buf_prod-bc.bc-on-type = 'scgb':U
          or buf_prod-bc.bc-on-type = 'ssgb':U) then do:
            assign
              p-return-attribute = false
            .
          end.
        end.
        when "weight=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = 'sclc':U
          or buf_prod-bc.bc-on-type = 'scgb':U) then do:
            assign
              p-return-attribute = false.
          end.
        end.
        when "pgweight=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = 'pglc':U) then do:
            assign
              p-return-attribute = false.
          end.
        end.
        when "petrolium=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = 'ptlc':U) then do:
            assign
              p-return-attribute = false.
          end.
        end.
        when "scaleable=request":u
        then do:
          if not (buf_prod-bc.bc-on-type = 'sslc':U
          or buf_prod-bc.bc-on-type = 'ssgb':U) then do:
            assign
              p-return-attribute = false.
          end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестное значение параметра v-action " skip
            "v-action" v-action skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error .
        end.
      end case.
    end.
  end.
end procedure.
procedure mc_gdsbcode :
  define input  parameter p-gds-code  like ub.bar-code.gds-code  no-undo .
  define input  parameter p-node-code like ub.bar-code.node-code no-undo .
  define output parameter p-b-code    like ub.bar-code.b-code    no-undo .
  def var vss-description as character no-undo init "gdsbcode-01: определение первичного бар-кода признака".
  def var vss-proc-revision as character no-undo init "library.p gdsbcode-01" .
  define buffer buf_bar-code for ub.bar-code .
  def var v-unit-base like ub.goods.unit-base no-undo .
  do
  on error undo, return error
  :
    if p-node-code = ? then do:
      run mc_gdsrootnode in this-procedure (
         input  p-gds-code
        ,output p-node-code
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого признака товара" skip
          "Код товара" p-gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    run mc_unitbase in this-procedure (
       input  p-gds-code
      ,output v-unit-base
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка определения базовой единицы измерения товара" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_bar-code no-lock
      where buf_bar-code.gds-code  = p-gds-code
        and buf_bar-code.node-code = p-node-code
        and buf_bar-code.part-code = ""
        and buf_bar-code.in-code   = ""
        and buf_bar-code.unit-cli  = v-unit-base
      no-error .
    if not available buf_bar-code then do:
      undo, return error vss-proc-revision + ":" + chr(10)
        + "Не найден первичный бар-кода признака " + chr(10)
        + "Код товара " + string(p-gds-code) + chr(10)
        + "Код признака " + string(p-node-code) + chr(10)
        + "Базовая единица измерения " + string(v-unit-base) + chr(10)
        .
    end.
    assign
      p-b-code = buf_bar-code.b-code
    .
  end.
end procedure.
procedure mc_gdsrootnode :
  define input  parameter p-gds-code  like ub.goods.gds-code no-undo .
  define output parameter p-root-node like ub.goods.prt-root no-undo .
  def var vss-description as character no-undo init "gdsrootnode-01: определение корневого признака товара по коду товара".
  define buffer buf_goods   for ub.goods .
  do
  on error undo, return error
  :
    find first buf_goods no-lock
      where buf_goods.gds-code  = p-gds-code
      no-error .
    if not available buf_goods then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.
    run mc_prt-root-to-node-code in this-procedure (
       input  buf_goods.prt-root
      ,output p-root-node
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры prt-root-to-node-code" skip
        "Товар" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        "Указатель на корень шкалы" buf_goods.prt-root skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure mc_prt-root-to-node-code :
  define input  parameter p-prt-root  like ub.goods.prt-root no-undo .
  define output parameter p-root-node like ub.goods.prt-root no-undo .
  def var vss-description as character no-undo init "prt-root-to-node-code-01: определение корневого признака шкалы по коду шкалы".
  define buffer buf_gds-prt for ub.gds-prt .
  do
  on error undo, return error
  :
    find buf_gds-prt no-lock
      where buf_gds-prt.upper-code = p-prt-root
      no-error .
    if not available buf_gds-prt then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден корень шкалы" skip
        "Указатель на корень шкалы" p-prt-root skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-root-node = buf_gds-prt.node-code
    .
  end.
end procedure.
procedure mc_unitbase :
  define input  parameter p-gds-code  like ub.goods.gds-code  no-undo .
  define output parameter p-unit-base like ub.goods.unit-base no-undo .
  def var vss-description as character no-undo init "unitbase-01: определение базовой единицы измерения товара".
  define buffer buf_goods for ub.goods .
  do
  on error undo, return error
  :
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-unit-base = buf_goods.unit-base
    .
  end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info12 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info12, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info12, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info12, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info12, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info12 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info12, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info12 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info12, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info12, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info12, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info12, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info12, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info12, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info12 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info12 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info12, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info12, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info12, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info12 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info12 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info12, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info12, v-inform, v-tbl-name ).
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
define variable file-name as character no-undo .
define variable default-cli-grp like ub.cli-grp.node-code no-undo .
define variable mydelimiter as character no-undo.
define variable firm-pars as character no-undo.
define variable person-pars as character no-undo.
define variable log-file-name                as character      no-undo init "process-clients.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-rid                        as recid          no-undo .
define stream InStream.
define stream logstream .
define variable ss as char format "X(3000)".
define variable n-entry as char no-undo extent 40.
define variable my-obj-type like ub.clients.obj-type no-undo.
define variable my-obj-code like ub.clients.obj-code no-undo.
define variable my-obj-name like ub.clients.obj-name no-undo.
define variable my-reg-code like ub.clients.reg-code no-undo.
define variable my-data-type as character no-undo .
define variable my-parus-2-code as character no-undo .
define variable my-seek1 as integer.
define variable my-seek2 as integer.
define variable my-mess as char.
define variable choice as integer no-undo.
define variable create-client as logical no-undo.
define variable dd as decimal.
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".
define variable     f-code      like ub.firm.firm-code no-undo.
define variable     p-code      like ub.person.psn-code no-undo.
define variable my-value as integer no-undo.
define buffer buf-cli-grp for ub.cli-grp.
define variable num-rec as integer.
define variable num-rec-ok as integer.
define variable ii as integer.
define variable firm-fields as integer no-undo.
define variable person-fields as integer no-undo.
define variable uniq-method as character no-undo .
define variable dopdec as decimal no-undo.
define variable nen as integer no-undo .
define variable v-correct-inn as logical no-undo .
define variable v-check-dupl as logical no-undo .
define variable v-check-inn-kpp as logical no-undo .
define variable v-return-value as character no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define variable intelli-log-file-name as character no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_person for ub.person.
define buffer another_firm for ub.firm.
define buffer another_person for ub.person.
define buffer buf_ext-classif for ub.ext-classif.
define temp-table temp-firm no-undo like ub.firm.
define temp-table temp-person no-undo like ub.person.
define temp-table temp-clients no-undo like ub.clients.
define temp-table tt0-staff no-undo like ub.staff.
define shared temp-table tt0-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_rule-call-param for tt0-rule-call-param.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE request-proc-save-staff :
DEFINE INPUT PARAMETER p-child-handle AS HANDLE NO-UNDO.
define input parameter p-mode as character no-undo .
define input parameter p-callpoint as character no-undo .
define buffer buf_tt-staff for tt0-staff.
IF p-mode <> 'ДОБАВЛЕНИЕ':U
OR LOOKUP(p-callpoint , 'C,S':U) = 0 THEN RETURN.
for each buf_tt-staff :
    RUN proc-save-staff IN p-child-handle (
                                           INPUT buf_tt-staff.role
                                          ,INPUT buf_tt-staff.staff-code
                                          ,INPUT buf_tt-staff.role-level
                                          ,INPUT buf_tt-staff.db-num
                                          ,INPUT buf_tt-staff.host-code
                                          ,INPUT buf_tt-staff.obj-type
                                          ,INPUT buf_tt-staff.obj-code
                                          ,INPUT buf_tt-staff.password
                                          ,input buf_tt-staff.date-start
                                          ,input buf_tt-staff.date-end
                                          ,input buf_tt-staff.work-place
                                            ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      UNDO, RETURN ERROR RETURN-VALUE.
    END.
END.
END PROCEDURE.
  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-delimiter"
 no-error.
if available buf_rule-call-param then do:
assign mydelimiter = buf_rule-call-param.param-value-character.
end.
  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-uniq-method"
 no-error.
if available buf_rule-call-param then do:
assign uniq-method = buf_rule-call-param.param-value-character.
end.
  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-default-cli-grp"
 no-error.
if available buf_rule-call-param then do:
assign default-cli-grp = buf_rule-call-param.param-value-integer.
end.
assign
file-name            = p-process-file-name.
assign
intelli-log-file-name = substitute("&1.log"
                        ,substring( string( next-value( s-file-num, ub ), '99999999999999999999'), 13, 8 )).
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
FIND FIRST ub.db WHERE ub.db.db-num = v-db-num NO-LOCK .
if not ub.db.add-client
or NOT g#db-num = 0 then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Импорт клиентов возможен только в ГБД&1и БД, в которых разрешен ввод клиентов", chr(10))).
  assign
  v-view-log = yes.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При импорте информации произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action17   as character no-undo .
  define variable v-printed17       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При импорте информации произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'process-clients.txt')
    ,input  7
    ,output v-user-action17
    ,output v-printed17
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'process-clients.txt').
end.
                        return.
end.
  find last buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-firm-fields"
 no-error.
if available buf_rule-call-param then do:
assign firm-fields = buf_rule-call-param.p-index.
end.
  find last buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-person-fields"
 no-error.
if available buf_rule-call-param then do:
assign person-fields = buf_rule-call-param.p-index.
end.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
run gbl/filename.p (
                 input  file-name
                ,output v-full-path
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
if error-status:error
or v-full-path = ?
or v-full-path = '':U
then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Не найден файл для импорта клиентов&1", file-name)).
  assign
  v-view-log = yes.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При импорте информации произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action19   as character no-undo .
  define variable v-printed19       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При импорте информации произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'process-clients.txt')
    ,input  7
    ,output v-user-action19
    ,output v-printed19
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'process-clients.txt').
end.
                        return.
end.
define variable v-end-new-line as logical no-undo .
run gbl/filnline.p ( input file-name
                    ,output v-end-new-line) no-error.
if error-status:error
or not v-end-new-line then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка при проверке наличия пустой строки в конце файла импорта&1&2"
                         , chr(10)
                         , return-value
                         )).
  assign
  v-view-log = yes.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При импорте информации произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action21   as character no-undo .
  define variable v-printed21       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При импорте информации произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'process-clients.txt')
    ,input  7
    ,output v-user-action21
    ,output v-printed21
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'process-clients.txt').
end.
                        return.
end.
assign
file-name = v-full-path.
run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт клиентов из файла &1", file-name)).
input stream Instream from value(file-name).
_stroka:
REPEAT ON ERROR UNDO, leave:
    empty temp-table temp-clients.
    empty temp-table  temp-firm.
    empty temp-table  temp-person.
    my-seek1 = seek(Instream).
    import stream INstream
    UNFORMATTED
    ss
    .
    num-rec = num-rec + 1.
    my-seek2 = seek(Instream).
    if NUM-entries(ss, mydelimiter)  <> firm-fields AND
       NUM-entries(ss, mydelimiter)  <> person-fields then do:
        my-mess = substitute("Строчка не разобрана!&1" +
                             "количество полей &2 не соответствует выбранному Вами формату c кол-вом полей!"
                             ,chr(10)
                             ,num-entries(ss, mydelimiter) ).
        if num-rec = 1 then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input my-mess).
          v-view-log = yes.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При импорте информации произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action23   as character no-undo .
  define variable v-printed23       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При импорте информации произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'process-clients.txt')
    ,input  7
    ,output v-user-action23
    ,output v-printed23
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'process-clients.txt').
end.
                        return.
        end.
        else do:
          run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
          run err-write in this-procedure ( input-output my-mess).
        end.
        next _stroka.
    end.
    do nen = 1 to 40:
      assign
      n-entry[nen] = "":U
      .
    end.
    do nen = 1 to num-entries(ss, mydelimiter):
      assign
      n-entry[nen] = entry(nen, ss, Mydelimiter)
      n-entry[nen] = if index(n-entry[nen], chr(34), 1) = 1
                     AND r-index(n-entry[nen], chr(34), 1) = 1
                     then trim(n-entry[nen], chr(34))
                     else n-entry[nen]
      n-entry[nen] = if index(n-entry[nen], chr(39), 1) = 1
                     AND r-index(n-entry[nen], chr(39), 1) = 1
                     then trim(n-entry[nen], chr(39))
                     else n-entry[nen]
      .
    end.
    assign
    my-obj-type = n-entry[1]
    .
    if my-obj-type  <> 'орг':U AND my-obj-type <> 'чел':U then do:
        my-mess = substitute("Разрешенные значения поля <<ТИП-ОБЪЕКТА>> - &1 или &2"
                             ,'орг':U
                             ,'чел':U).
        run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
        run err-write in this-procedure ( input-output my-mess).
        next _stroka.
    end.
    assign
    my-obj-code = integer(n-entry[2])
    my-obj-name = n-entry[3]
    no-error
    .
    if error-status:error then do:
      my-mess = substitute("Поле <<КОД КЛИЕНТА>> должно быть неотрицательным целым числом").
      run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
      run err-write in this-procedure ( input-output my-mess).
      next _stroka.
    end.
    CASE my-obj-type:
      when 'орг':U then do:
        create temp-clients.
        assign
        temp-clients.obj-type = 'орг':U
        temp-clients.obj-name = my-obj-name
        temp-clients.obj-code = my-obj-code
        .
        create temp-firm.
        temp-firm.firm-code = my-obj-code.
          if NUM-entries(ss, mydelimiter) <> firm-fields then do:
            my-mess = substitute("Количество полей в строке импорта клиентов типа <<&1>>&2" +
                                 "согласно определенному Вами формату должно быть равно &3"
                                  ,'орг':U
                                  ,chr(10)
                                  ,firm-fields).
            run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
            run err-write in this-procedure ( input-output my-mess).
            next _stroka.
          end.
      end.
      when 'чел':U then do:
        create temp-clients.
        assign
        temp-clients.obj-type = 'чел':U
        temp-clients.obj-name = my-obj-name
        temp-clients.obj-code = my-obj-code
        .
        create temp-person.
        temp-person.psn-code = my-obj-code
        .
        if NUM-entries(ss, mydelimiter)  <> person-fields then do:
          my-mess = substitute("Количество полей в строке импорта клиентов типа <<&1>>&2" +
                                "согласно определенному Вами формату должно быть равно "
                              ,'чел':U
                              ,chr(10)
                              ,person-fields
                              ).
          run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
          run err-write in this-procedure ( input-output my-mess).
          next _stroka.
        end.
      end.
    END cASE.
    if my-obj-code = 0 then
    create-client = yes.
    else create-client = no.
    v-check-dupl = no.
    v-check-inn-kpp = no.
    if create-client then do:
      case uniq-method:
        when "obj-name" then do:
          FIND FIRST ub.clients no-lock where
                    ub.clients.obj-name = my-obj-name
                and ub.clients.obj-type = my-obj-type NO-ERROR.
          if avail ub.clients then do:
            if ub.clients.obj-type = 'орг':U then do:
              my-mess = substitute("Уже есть клиент с названием <<&1>>", my-obj-name).
              run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
              run err-write in this-procedure ( input-output my-mess).
              next _stroka.
            end.
            else do:
              v-check-dupl = yes.
            end.
          end.
        end.
        when "inn+kpp" then do:
          v-check-inn-kpp = yes.
        end.
      end case.
    end.
    CASE my-obj-type:
      WHEN 'орг':U then do:
        find first buf_rule-call-param where
                buf_rule-call-param.codex_id = p-codex-id
                and buf_rule-call-param.ruleset_id = p-ruleset-id
                and buf_rule-call-param.call_id = p-call-id
                and buf_rule-call-param.order_id = p-order-id
                and buf_rule-call-param.rule_id = p-rule-id
                and buf_rule-call-param.param-name = "p-firm-fields"
                and buf_rule-call-param.param-value-character = "firm.tobj-code" no-error.
         if available buf_rule-call-param then do:
          assign
          temp-firm.tobj-code = integer(n-entry[buf_rule-call-param.p-index])
          no-error
          .
          if error-status:error then do:
            my-mess = "Поле <<КОД ТОРГОВОГО ПРЕДСТАВИТЕЛЯ>> должно быть неотрицательным целым числом".
            run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
            run err-write in this-procedure ( input-output my-mess).
            next _stroka.
          end.
        end.
        find first buf_rule-call-param where
                buf_rule-call-param.codex_id = p-codex-id
                and buf_rule-call-param.ruleset_id = p-ruleset-id
                and buf_rule-call-param.call_id = p-call-id
                and buf_rule-call-param.order_id = p-order-id
                and buf_rule-call-param.rule_id = p-rule-id
                and buf_rule-call-param.param-name = "p-firm-fields"
                and buf_rule-call-param.param-value-character = "firm.ind" no-error.
        IF available buf_rule-call-param then do:
          assign
          temp-firm.ind = integer(n-entry[buf_rule-call-param.p-index])
          no-error
          .
          if error-status:error then do:
            my-mess = "Поле <<ПОЧТОВЫЙ ИНДЕКС>> должно быть неотрицательным целым числом".
            run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
            run err-write in this-procedure ( input-output my-mess).
            next _stroka.
          end.
        end.
        for each  buf_rule-call-param where
                buf_rule-call-param.codex_id = p-codex-id
                and buf_rule-call-param.ruleset_id = p-ruleset-id
                and buf_rule-call-param.call_id = p-call-id
                and buf_rule-call-param.order_id = p-order-id
                and buf_rule-call-param.rule_id = p-rule-id
                and buf_rule-call-param.param-name = "p-firm-fields"
                and buf_rule-call-param.param-value-character > '':
            case entry(1, buf_rule-call-param.param-value-character, "."):
              when 'firm':U then do:
                assign
                my-data-type = buffer temp-firm:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):data-type.
                case my-data-type:
                  when 'character':U then do:
                    assign
                    buffer temp-firm:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    n-entry[buf_rule-call-param.p-index].
                  end.
                  when 'integer':U then do:
                    assign
                    buffer temp-firm:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    integer(n-entry[buf_rule-call-param.p-index]).
                  end.
                  when 'decimal':U then do:
                    assign
                    buffer temp-firm:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    decimal(n-entry[buf_rule-call-param.p-index]).
                  end.
                  when 'logical':U then do:
                    assign
                    buffer temp-firm:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    logical(n-entry[buf_rule-call-param.p-index]).
                  end.
                end case.
              end.
              when 'clients':U then do:
                assign
                my-data-type = buffer temp-clients:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):data-type.
                case my-data-type:
                  when 'character':U then do:
                    assign
                    buffer temp-clients:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    n-entry[buf_rule-call-param.p-index].
                  end.
                  when 'integer':U then do:
                    assign
                    buffer temp-clients:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    integer(n-entry[buf_rule-call-param.p-index]).
                  end.
                  when 'decimal':U then do:
                    assign
                    buffer temp-clients:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    decimal(n-entry[buf_rule-call-param.p-index]).
                  end.
                  when 'logical':U then do:
                    assign
                    buffer temp-clients:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    logical(n-entry[buf_rule-call-param.p-index]).
                  end.
                end case.
              end.
              otherwise do:
                case entry(2, buf_rule-call-param.param-value-character, "."):
                  when "parus-2-code" then do:
                    my-parus-2-code =  n-entry[buf_rule-call-param.p-index].
                  end.
                end.
              end.
            end case.
        end.
        if v-check-dupl then do:
          for each buf_clients no-lock where
                  buf_clients.obj-type = 'чел':U
              and buf_clients.obj-name = my-obj-name,
              first buf_person no-lock where
                    buf_person.psn-code = buf_clients.obj-code :
            if (buf_person.name1 = temp-person.name1
            and buf_person.name2 = temp-person.name2)
            or
              (temp-person.name1 = ''
            and temp-person.name2 = '')
            or
              (buf_person.name1 = ''
            and buf_person.name2 = '')
            or (buf_person.name1 = temp-person.name1
                and
                (temp-person.name2 = ''
                or buf_person.name2 = ''))
            or (buf_person.name2 = temp-person.name2
                and
                (temp-person.name1 = ''
                or buf_person.name1 = '')) then do:
              my-mess = substitute("Уже есть такой &1  или не везде заданы ИМЕНА И ОТЧЕСТВА", temp-clients.obj-name).
              run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
              run err-write in this-procedure ( input-output my-mess).
              next _stroka.
            end.
          end.
        end.
        if v-check-inn-kpp then do:
          if temp-firm.inn + temp-firm.kpp <> '' then do:
            for each another_firm no-lock where
                    another_firm.inn = temp-firm.inn
                and another_firm.kpp = temp-firm.kpp :
                leave.
            end.
            for each another_person no-lock where
                    another_person.inn = temp-firm.inn
                and another_person.kpp = temp-firm.kpp :
                leave.
            end.
            if available another_firm
            or available another_person then do:
              my-mess = substitute("Уже есть клиент с сочетанием ИНН+КПП=&1+&2"
                                  , temp-firm.inn
                                  , temp-firm.kpp).
              if available another_firm then do:
                run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", "орг", another_firm.firm-code, my-parus-2-code, my-mess)).
              end.
              else do:
                run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", "чел", another_person.psn-code, my-parus-2-code, my-mess)).
              end.
              run err-write in this-procedure ( input-output my-mess).
              next _stroka.
            end.
          end.
        end.
        IF LENGTH(temp-clients.obj-name) > 130 OR
           LENGTH(temp-firm.city) > 23 OR
           temp-firm.ind > 999999 OR
           length(temp-firm.inn) > 21 OR
           length(temp-firm.okonh) > 120 OR
           length(temp-firm.okpo) > 10 OR
           length(temp-firm.kpp) > 9 OR
           length(temp-firm.addres1) > 30 OR
           length(temp-firm.addres2) > 30 OR
           length(temp-firm.post-addr1) > 50 OR
           length(temp-firm.post-addr2) > 50 OR
           length(temp-firm.phone) > 20 OR
           length(temp-firm.phone1-note) > 10 OR
           length(temp-firm.fax) >  20 OR
           length(temp-firm.telex) > 20 OR
           length(temp-firm.e-mail) > 100 OR
           length(temp-firm.director) >  25 OR
           length(temp-firm.contact-psn) > 50 OR
           length(temp-firm.engl-name) > 130 then do:
           assign
           my-mess =  (IF LENGTH(temp-clients.obj-name) > 130 then " поле <<НАЗВАНИЕ>> " else "") +
                      (IF LENGTH(temp-firm.city) > 23 then " поле <<Город>> " else "") +
                      (IF temp-firm.ind > 999999 then " поле <<ПОЧТОВЫЙ ИНДЕКС>> " else "") +
                      (IF length(temp-firm.inn) > 21 then " поле <<ИНН>> " else "") +
                      (IF length(temp-firm.okonh) > 120 then " поле <<ОКОНХ>> " else "") +
                      (IF length(temp-firm.okpo) > 10 then  " поле <<ОКПО>> " else "") +
                      (IF length(temp-firm.kpp) > 9 then  " поле <<КПП>> " else "") +
                      (IF length(temp-firm.addres1) > 30 then "поле <<ЮРИДИЧЕСКИЙ АДРЕС 1>> " else "") +
                      (IF length(temp-firm.addres2) > 30 then "поле <<ЮРИДИЧЕСКИЙ АДРЕС 2>> " else "") +
                      (IF length(temp-firm.post-addr1) > 50 then " <<ПОЧТОВЫЙ АДРЕС 1>> " else "") +
                      (IF length(temp-firm.post-addr2) > 50 then " <<ПОЧТОВЫЙ АДРЕС 2>> " else "") +
                      (IF length(temp-firm.phone) > 20 then " <<N ТЕЛЕФОНА>> " else "") +
                      (IF length(temp-firm.phone1-note) > 10 then  " <<Примечания к N ТЕЛЕФОНА>> " else "") +
                      (IF length(temp-firm.fax) > 20 then " <<N ФАКСА> " else "") +
                      (IF length(temp-firm.telex) > 20 then " <<N ТЕЛЕКСА>> " else "") +
                      (IF length(temp-firm.e-mail) > 100 then " <<E-mail>> " else "") +
                      (IF length(temp-firm.director) >  25 then  " <<Руководитель>> " else "") +
                      (IF length(temp-firm.contact-psn) > 50 then " <<Контактное лицо>> " else "") +
                      (IF length(temp-firm.engl-name) > 140 then  " <<Английское название>> " else "")
          my-mess = "Длина поля " + my-mess + " больше разрешенной"
          .
          run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
          run err-write in this-procedure ( input-output my-mess).
          next _stroka.
        END.
       if temp-firm.inn <> "":U then do:
         run gbl/keyinn.p ( input temp-firm.inn, input 'орг':U, input 0, input temp-firm.is-pboul, output v-correct-inn).
          if not v-correct-INN then do:
            assign
            v-return-value = return-value.
            run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
            run err-write in this-procedure  ( input-output v-return-value).
            next _stroka.
          end.
       end.
      END.
      WHEN 'чел':U then do:
        find first buf_rule-call-param where
                buf_rule-call-param.codex_id = p-codex-id
                and buf_rule-call-param.ruleset_id = p-ruleset-id
                and buf_rule-call-param.call_id = p-call-id
                and buf_rule-call-param.order_id = p-order-id
                and buf_rule-call-param.rule_id = p-rule-id
                and buf_rule-call-param.param-name = "p-person-fields"
                and buf_rule-call-param.param-value-character = "person.firm-code" no-error.
         if available buf_rule-call-param then do:
          assign
          temp-person.firm-code = integer(n-entry[buf_rule-call-param.p-index])
          no-error
          .
          if error-status:error then do:
            my-mess = "Поле <<КОД ФИРМЫ>> должно быть неотрицательным целым числом".
            run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
            run err-write in this-procedure ( input-output my-mess).
            next _stroka.
          end.
        end.
        find first buf_rule-call-param where
                buf_rule-call-param.codex_id = p-codex-id
                and buf_rule-call-param.ruleset_id = p-ruleset-id
                and buf_rule-call-param.call_id = p-call-id
                and buf_rule-call-param.order_id = p-order-id
                and buf_rule-call-param.rule_id = p-rule-id
                and buf_rule-call-param.param-name = "p-person-fields"
                and buf_rule-call-param.param-value-character = "person.ind" no-error.
         if available buf_rule-call-param then do:
          assign
          temp-person.ind = integer(n-entry[buf_rule-call-param.p-index])
          no-error
          .
          if error-status:error then do:
            my-mess = "Поле <<ПОЧТОВЫЙ ИНДЕКС>> должно быть неотрицательным целым числом".
            run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
            run err-write in this-procedure ( input-output my-mess).
            next _stroka.
          end.
        end.
        for each  buf_rule-call-param where
                buf_rule-call-param.codex_id = p-codex-id
                and buf_rule-call-param.ruleset_id = p-ruleset-id
                and buf_rule-call-param.call_id = p-call-id
                and buf_rule-call-param.order_id = p-order-id
                and buf_rule-call-param.rule_id = p-rule-id
                and buf_rule-call-param.param-name = "p-person-fields"
                and buf_rule-call-param.param-value-character > '':
            case entry(1, buf_rule-call-param.param-value-character, "."):
              when 'person':U then do:
                assign
                my-data-type = buffer temp-person:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):data-type.
                case my-data-type:
                  when 'character':U then do:
                    assign
                    buffer temp-person:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    n-entry[buf_rule-call-param.p-index].
                  end.
                  when 'integer':U then do:
                    assign
                    buffer temp-person:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    integer(n-entry[buf_rule-call-param.p-index]).
                  end.
                  when 'decimal':U then do:
                    assign
                    buffer temp-person:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    decimal(n-entry[buf_rule-call-param.p-index]).
                  end.
                  when 'logical':U then do:
                    assign
                    buffer temp-person:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    logical(n-entry[buf_rule-call-param.p-index]).
                  end.
                end case.
              end.
              when 'clients':U then do:
                assign
                my-data-type = buffer temp-clients:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):data-type.
                case my-data-type:
                  when 'character':U then do:
                    assign
                    buffer temp-clients:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    n-entry[buf_rule-call-param.p-index].
                  end.
                  when 'integer':U then do:
                    assign
                    buffer temp-clients:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    integer(n-entry[buf_rule-call-param.p-index]).
                  end.
                  when 'decimal':U then do:
                    assign
                    buffer temp-clients:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    decimal(n-entry[buf_rule-call-param.p-index]).
                  end.
                  when 'logical':U then do:
                    assign
                    buffer temp-clients:handle:buffer-field(entry(2, buf_rule-call-param.param-value-character, ".")):buffer-value =
                    logical(n-entry[buf_rule-call-param.p-index]).
                  end.
                end case.
              end.
              otherwise if num-entries(buf_rule-call-param.param-value-character, ".") > 1 then  do:
                case entry(2, buf_rule-call-param.param-value-character, "."):
                  when "parus-2-code" then do:
                    my-parus-2-code =  n-entry[buf_rule-call-param.p-index].
                  end.
                end.
              end.
            end case.
        end.
        if v-check-dupl then do:
          for each buf_clients no-lock where
                  buf_clients.obj-type = 'чел':U
              and buf_clients.obj-name = my-obj-name,
              first buf_person no-lock where
                    buf_person.psn-code = buf_clients.obj-code :
            if (buf_person.name1 = temp-person.name1
            and buf_person.name2 = temp-person.name2)
            or
              (temp-person.name1 = ''
            and temp-person.name2 = '')
            or
              (buf_person.name1 = ''
            and buf_person.name2 = '')
            or (buf_person.name1 = temp-person.name1
                and
                (temp-person.name2 = ''
                or buf_person.name2 = ''))
            or (buf_person.name2 = temp-person.name2
                and
                (temp-person.name1 = ''
                or buf_person.name1 = '')) then do:
              my-mess = substitute("Уже есть такой &1  или не везде заданы ИМЕНА И ОТЧЕСТВА", my-obj-name).
              run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
              run err-write in this-procedure ( input-output my-mess).
              next _stroka.
            end.
          end.
        end.
        if v-check-inn-kpp then do:
          if temp-person.inn + temp-person.kpp <> '' then do:
            for each another_firm no-lock where
                    another_firm.inn = temp-person.inn
                and another_firm.kpp = temp-person.kpp :
                leave.
            end.
            for each another_person no-lock where
                    another_person.inn = temp-person.inn
                and another_person.kpp = temp-person.kpp :
                leave.
            end.
            if available another_firm
            or available another_person then do:
              my-mess = substitute("Уже есть клиент с сочетанием ИНН+КПП=&1&2"
                                  , temp-person.inn
                                  , temp-person.kpp).
              run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
              run err-write in this-procedure ( input-output my-mess).
              next _stroka.
            end.
          end.
        end.
        IF LENGTH(my-obj-name) > 40 OR
           LENGTH(temp-person.city) > 23 OR
           temp-person.ind > 999999 OR
           length(temp-person.inn) > 15 OR
           length(temp-person.okonh) > 120 OR
           length(temp-person.okpo) > 10 OR
           length(temp-person.kpp) > 9 OR
           length(temp-person.address) > 30 OR
           length(temp-person.name1) > 20 OR
           length(temp-person.name2) > 20 OR
           length(temp-person.firm-name) > 40 OR
           length(temp-person.phone1) > 20 OR
           length(temp-person.phone1-note) > 10 OR
           length(temp-person.fax) >  20 OR
           length(temp-person.position) > 20 OR
           length(temp-person.e-mail) > 100 OR
           length(temp-person.passp-ser) >  8 OR
           length(temp-person.passp-num) > 18 OR
           length(temp-person.given-by) > 40 then do:
           assign
           my-mess =
                      (IF LENGTH(temp-clients.obj-name) > 40 then " поле <<ФАМИЛИЯ>> " else "") +
                      (IF LENGTH(temp-person.city) > 23 then " поле <<Город>> " else "") +
                      (IF temp-person.ind > 999999 then " поле <<ПОЧТОВЫЙ ИНДЕКС>> " else "") +
                      (IF length(temp-person.inn) > 15 then " поле <<ИНН>> " else "") +
                      (IF length(temp-person.okonh) > 120 then " поле <<ОКОНХ>> " else "") +
                      (IF length(temp-person.okpo) > 10 then  " поле <<ОКПО>> " else "") +
                      (IF length(temp-person.kpp) > 9 then  " поле <<КПП>> " else "") +
                      (IF length(temp-person.address) > 30 then "поле <<ЮРИДИЧЕСКИЙ АДРЕС 1>> " else "") +
                      (IF length(temp-person.name1) > 20 then "поле <<ИМЯ>> " else "") +
                      (IF length(temp-person.name2) > 20 then " <<ФАМИЛИЯ>> " else "") +
                      (IF length(temp-person.firm-name) > 40 then " <<ОРГАНИЗАЦИЯ>> " else "") +
                      (IF length(temp-person.phone1) > 20 then " <<N ТЕЛЕФОНА>> " else "") +
                      (IF length(temp-person.phone1-note) > 10 then  " <<Примечания к N ТЕЛЕФОНА>> " else "") +
                      (IF length(temp-person.fax) > 20 then " <<N ФАКСА> " else "") +
                      (IF length(temp-person.position) > 20 then " <<Должность>> " else "") +
                      (IF length(temp-person.e-mail) > 100 then " <<E-mail>> " else "") +
                      (IF length(temp-person.passp-ser) >  8 then  " <<СЕРИЯ ПАСПОРТА>> " else "") +
                      (IF length(temp-person.passp-num) > 18 then " <<N ПАСПОРТА>> " else "") +
                      (IF length(temp-person.given-by) > 40 then  " <<ПАСПОРТ ВЫДАН>> " else "")
          my-mess = "Длина поля " + my-mess + " больше разрешенной"
          .
          run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
          run err-write in this-procedure ( input-output my-mess).
          next _stroka.
        END.
       if temp-person.inn <> "":U then do:
         run gbl/keyinn.p ( input temp-person.inn, input 'чел':U, input 0, input temp-person.is-pboul, output v-correct-inn).
          if not v-correct-INN then do:
            assign
            v-return-value = return-value.
             run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
            run err-write in this-procedure ( input-output v-return-value).
            next _stroka.
          end.
       end.
      END.
    END CASE.
    if my-parus-2-code <> ''
    and create-client
    then do:
      find first buf_ext-classif no-lock where
                buf_Ext-classif.classif-subject = 'clients':U
          and buf_ext-classif.classif-name = 'exp-parus-2-code':U
          and buf_ext-classif.db-num = -1
          and buf_ext-classif.charkey_one = my-parus-2-code  no-error.
      if available buf_Ext-classif then do:
        my-mess = substitute("Уже есть клиент с кодом клиента &1 в классификаторе ПАРУС-2"
                            , my-parus-2-code
                            ).
        run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
        run err-write in this-procedure ( input-output my-mess).
        next _stroka.
      end.
    end.
    FIND FIRST ub.cli-grp No-LOCK where ub.cli-grp.node-code = default-cli-grp NO-ERROR.
    IF NOT avail ub.cli-grp then do:
      my-mess = substitute("Не найдена группа клиентов с вн.кодом &1", default-cli-grp).
      run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
      run err-write in this-procedure ( input-output my-mess).
      return.
    end.
    IF can-find(FIRST buf-cli-grp No-LOCK WHERE buf-cli-grp.upper-code = default-cli-grp) then do:
     run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
     my-mess = substitute("Выбрана нетерминальная группа клиентов (вн код &1)", cli-grp.node-name).
     run err-write in this-procedure ( input-output my-mess).
     return.
   end.
   DO TRANSACTION ON STOP UNDO, NEXT _stroka ON ERROR UNDO, NEXT _stroka:
    if my-obj-code > 0 then do:
      FIND FIRST clients NO-LOCK WHERE
                 clients.obj-type = my-obj-type AND
                 clients.obj-code = my-obj-code No-ERROR.
      IF not avail clients then do:
          create-client  = yes.
      end.
      else do:
        FIND FIRST CLIENTS EXCLUSIVE-LOCK WHERE
                   CLIENTS.obj-type = my-obj-type AND
                   CLIENTS.obj-code = my-obj-code NO-WAIT No-ERROR.
        IF AVAIL clients then do:
          CASE my-obj-type:
            WHEN 'орг':U then do:
              FIND FIRST ub.firm exclusive-lock WHERE
                         ub.firm.firm-code = my-obj-code No-WAIT NO-ERROR.
              IF NOT AVAIL ub.firm then do:
                my-mess = substitute("Запись о клиенте с типом &1 и кодом &2 занята!"
                                    ,my-obj-type
                                    ,my-obj-code).
                run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
                run err-write in this-procedure ( input-output my-mess).
                next _stroka.
              end.
            END.
            WHEN 'чел':U then do:
              FIND FIRST ub.person exclusive-lock WHERE
                         ub.person.psn-code = my-obj-code No-WAIT NO-ERROR.
              IF NOT AVAIL ub.person then do:
                my-mess = substitute("Запись о клиенте с типом &1 и кодом &2 занята!"
                                   ,my-obj-type
                                   ,my-obj-code).
                run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
                run err-write in this-procedure ( input-output my-mess).
                next _stroka.
              end.
            end.
          END CASE.
          assign
          v-rid = recid(clients).
        END.
        ELSE DO:
          my-mess = substitute("Запись о клиенте с типом &1 и кодом &2 занята"
                              ,my-obj-type
                              ,my-obj-code).
          run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
          run err-write in this-procedure ( input-output my-mess).
          next _stroka.
        END.
      end.
    end.
    if create-client then do:
          CASE my-obj-type:
        WHEN 'орг':U then do:
          run ref/firm1.p (
               input parparentproc
              ,input-output v-rid
              ,input 'ДОБАВЛЕНИЕ-ИМПОРТ':U
              ,input "cli-all":U
              ,input yes
              ,input - abs(my-obj-code)
              ,input 0
              ,input my-obj-name
              ,input 0
              ,input "":U
              ,input default-cli-grp
              ,input temp-firm.addres1
              ,input temp-firm.addres2
              ,input temp-firm.city
              ,input temp-firm.contact-psn
              ,input temp-firm.director
              ,input temp-firm.e-mail
              ,input temp-firm.engl-name
              ,input temp-firm.fax
              ,input temp-firm.given-by
              ,input temp-firm.ind
              ,input temp-firm.inn
              ,input no
              ,input temp-firm.is-pboul
              ,input temp-firm.kpp
              ,input temp-firm.okonh
              ,input temp-firm.okpo
              ,input temp-firm.passp-num
              ,input temp-firm.passp-ser
              ,input temp-firm.phone
              ,input temp-firm.phone1-note
              ,input temp-firm.post-addr1
              ,input temp-firm.post-addr2
              ,input temp-firm.post-city
              ,input temp-firm.post-ind
              ,input temp-clients.reg-code
              ,input temp-firm.telex
              ,input temp-firm.tobj-code
              ,input no
              ,input no
             ) no-error .
          if error-status:error then do:
            my-mess = substitute("Не удалось сохранить запись о клиенте с типом &1 и кодом &2&3&4&3&5"
                                 ,my-obj-type
                                 ,my-obj-code
                                 ,chr(10)
                                 , error-status:get-message(1)
                                 , return-value).
            run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
            run err-write in this-procedure ( input-output my-mess).
            next _stroka.
          end.
        END.
        WHEN 'чел':U then do:
          run ref/person1.p (
              input parparentproc
             ,input this-procedure:handle
             ,input-output v-rid
             ,input 'ДОБАВЛЕНИЕ-ИМПОРТ':U
             ,input "cli-all":U
             ,input yes
             ,input - abs(my-obj-code)
             ,input 0
             ,input my-obj-name
             ,input 0
             ,input "":U
             ,input default-cli-grp
             ,input temp-person.address
             ,input temp-person.city
             ,input ?
             ,input temp-person.e-mail
             ,input temp-person.fax
             ,input temp-person.firm-code
             ,input temp-person.firm-name
             ,input ?
             ,input temp-person.given-by
             ,input temp-person.ind
             ,input temp-person.inn
             ,input no
             ,input temp-person.is-pboul
             ,input temp-person.kpp
             ,input temp-person.name1
             ,input temp-person.name2
             ,input temp-person.okonh
             ,input temp-person.okpo
             ,input temp-person.passp-num
             ,input temp-person.passp-ser
             ,input temp-person.phone1
             ,input temp-person.phone1-note
             ,input temp-person.position
             ,input temp-person.post-box
             ,input temp-person.post-address
             ,input temp-person.post-city
             ,input temp-person.post-ind
             ,input temp-clients.reg-code
             ,input no
             ,input no
             ) no-error .
          if error-status:error then do:
            my-mess = substitute("Не удалось сохранить запись о клиенте с типом &1 и кодом &2&3&4&3&5"
                                 ,my-obj-type
                                 ,my-obj-code
                                 ,chr(10)
                                 , error-status:get-message(1)
                                 , return-value).
            run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
            run err-write in this-procedure ( input-output my-mess).
            next _stroka.
          end.
        END.
      END CASE.
      if my-parus-2-code <> '' then do:
        define variable v-uniq-key-rec as character no-undo .
        find first buf_clients no-lock where
                  recid(buf_clients) = V-RID.
        run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                      ,input (buffer buf_clients:handle)
                                      ,output v-uniq-key-rec).
        define variable v-rid-ext as integer no-undo.
        run ref/extclas1.p ( INPUT 'ДОБАВЛЕНИЕ':U
                            ,INPUT yes
                            ,INPUT-OUTPUT v-rid-ext
                            ,INPUT 'clients':U
                            ,INPUT 'exp-parus-2-code':U
                            ,input (-1)
                            ,input 0
                            ,input 0
                            ,input 0
                            ,input MY-parus-2-CODE
                            ,input '':U
                            ,input '':U
                            ,input 0
                            ,input v-uniq-key-rec ) no-error.
        if error-status:error then do:
          my-mess = substitute("Не удалось сохранить КОД клиента с типом &1 и кодом &2 ВО КЛАССИФИКАТОРЕ ПАРУС-2&3&4&3&5"
                              ,my-obj-type
                              ,my-obj-code
                              ,chr(10)
                              , error-status:get-message(1)
                              , return-value).
          run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
          run err-write in this-procedure ( input-output my-mess).
          undo _stroka, next _stroka.
        end.
      end.
      define variable v-int as integer no-undo .
      run get-max-code in this-procedure
        ( input "f-u":U
        ,input g#db-num
        ,input (if my-obj-type = 'орг':U then 'fmgb':U else 'pngb':U)
        ,input ?
        ,input ?
        ,input TRUE
        ,output v-int
        ).
    end.
    else do:
      CASE my-obj-type:
        WHEN 'орг':U then do:
          run ref/firm1.p (
               input parparentproc
              ,input-output v-rid
              ,input 'ИЗМЕНЕНИЕ':U
              ,input "cli-all":U
              ,input yes
              ,input clients.obj-code
              ,input clients.stts
              ,input my-obj-name
              ,input clients.lim-kr
              ,input clients.PS
              ,input clients.grp-code
              ,input temp-firm.addres1
              ,input temp-firm.addres2
              ,input temp-firm.city
              ,input temp-firm.contact-psn
              ,input temp-firm.director
              ,input temp-firm.e-mail
              ,input temp-firm.engl-name
              ,input temp-firm.fax
              ,input temp-firm.given-by
              ,input temp-firm.ind
              ,input temp-firm.inn
              ,input no
              ,input temp-firm.is-pboul
              ,input temp-firm.kpp
              ,input temp-firm.okonh
              ,input temp-firm.okpo
              ,input temp-firm.passp-num
              ,input temp-firm.passp-ser
              ,input temp-firm.phone1
              ,input temp-firm.phone1-note
              ,input temp-firm.post-addr1
              ,input temp-firm.post-addr2
              ,input temp-firm.post-city
              ,input temp-firm.post-ind
              ,input temp-clients.reg-code
              ,input temp-firm.telex
              ,input temp-firm.tobj-code
              ,input no
              ,input no
              ) no-error .
          if error-status:error then do:
            my-mess = substitute("Не удалось сохранить запись о клиенте с типом &1 и кодом &2&3&4&3&5"
                                 ,my-obj-type
                                 ,my-obj-code
                                 ,chr(10)
                                 , error-status:get-message(1)
                                 , return-value).
            run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
            run err-write in this-procedure ( input-output my-mess).
            next _stroka.
          end.
        END.
        when 'чел':U then do:
          run ref/person1.p (
               input parparentproc
              ,input this-procedure:handle
              ,input-output v-rid
              ,input 'ИЗМЕНЕНИЕ':U
              ,input "cli-all":U
              ,input yes
              ,input clients.obj-code
              ,input clients.stts
              ,input my-obj-name
              ,input clients.lim-kr
              ,input clients.PS
              ,input clients.grp-code
              ,input temp-person.address
              ,input temp-person.city
              ,input ?
              ,input temp-person.e-mail
              ,input temp-person.fax
              ,input temp-person.firm-code
              ,input temp-person.firm-name
              ,input ?
              ,input temp-person.given-by
              ,input temp-person.ind
              ,input temp-person.inn
              ,input no
              ,input temp-person.is-pboul
              ,input temp-person.kpp
              ,input temp-person.name1
              ,input temp-person.name2
              ,input temp-person.okonh
              ,input temp-person.okpo
              ,input temp-person.passp-num
              ,input temp-person.passp-ser
              ,input temp-person.phone1
              ,input temp-person.phone1-note
              ,input person.position
              ,input temp-person.post-box
              ,input temp-person.post-address
              ,input temp-person.post-city
              ,input temp-person.post-ind
              ,input temp-clients.reg-code
              ,input no
              ,input no
              ) no-error .
            if error-status:error then do:
              my-mess = substitute("Не удалось сохранить запись о клиенте с типом &1 и кодом &2&3&4&3&5"
                                  ,my-obj-type
                                  ,my-obj-code
                                  ,chr(10)
                                  , error-status:get-message(1)
                                  , return-value).
              run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).
              run err-write in this-procedure ( input-output my-mess).
              next _stroka.
            end.
        end.
      END CASE.
    end.
  END.
  num-rec-ok = num-rec-ok + 1.
  find first clients no-lock where
            recid(clients) = v-rid.
  run display-intelli-log in this-procedure ( input substitute("&1&2,&3,true,&4", clients.obj-type, clients.obj-code, my-parus-2-code, "OK")).
  run show-counter in p-log-handle .
  run write-counter in p-log-handle (substitute("Обработано &1 из них успешно &2"
                                              , num-rec
                                              , num-rec-ok
                                              )) no-error.
  run get-stop-state in p-log-handle (
      output v-stop
  ).
  if v-stop then do:
    leave _stroka.
  end.
END.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт клиентов из файла &1 завершен: из &2 записей успешно закачано &3&4&5"
                      , file-name
                      , num-rec
                      , num-rec-ok
                      , chr(10)
                      ,(if lookup("parus-2-code", firm-pars, chr(47)) > 0
                        or lookup("parus-2-code", person-pars, chr(47)) > 0 then
                        substitute("Дополнительный лог находится в файле &1", intelli-log-file-name)
                        else "")
                      )).
input stream InStream close.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При импорте информации произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action25   as character no-undo .
  define variable v-printed25       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При импорте информации произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'process-clients.txt')
    ,input  7
    ,output v-user-action25
    ,output v-printed25
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'process-clients.txt').
end.
                        return.
PROCEDURE err-write:
  DEFINE INPUT-OUTPUT PARAMETER mess as char No-UNDO.
  seek STREAM Instream to my-seek1.
  import stream InStream unformatted
  ss.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input mess + chr(10) + ss).
  assign
  v-view-log = yes.
  mess = "".
  seek STREAM Instream to my-seek2.
END PROCEDURE.
procedure display-intelli-log :
define input parameter p-mess as character no-undo .
do
on error undo, return error
:
  if lookup("parus-2-code", firm-pars, chr(47)) > 0
  or lookup("parus-2-code", person-pars, chr(47)) > 0 then do:
    output stream logstream to value(intelli-log-file-name) append.
    put stream logstream unformatted replace(p-mess, chr(10), chr(32))  skip.
    output stream logstream close.
  end.
end.
end procedure.
