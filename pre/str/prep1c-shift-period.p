block-level on error undo, throw.
define temp-table tt-pl-gds no-undo
  field pl-code like ub.place.pl-code
  field loc1 like ub.place.loc1
  field gds-code like ub.goods.gds-code
  field num-pri-periods as integer
.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.shift-obj.obj-type no-undo .
define input parameter p-obj-code like ub.shift-obj.obj-code no-undo .
define input parameter p-shift-date like ub.shift-obj.shift-date no-undo .
define input parameter p-shift-num like ub.shift-obj.shift-num no-undo .
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
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
define buffer buf_place for ub.place .
define buffer buf_shift-obj for ub.shift-obj .
define buffer buf_shift-period for ub.shift-period .
define variable expData as memptr no-undo .
define variable log-file-name as character no-undo initial "shift-period.log" .
define variable v-pid as int64 no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
function string-mth returns character
  (inValue as decimal)
:
  def var v-str as character no-undo.
  def var v-stt as decimal   no-undo.
  if inValue = ?  then v-str = "0".
  if inValue < 0 then
  do:
    v-stt = inValue .
    inValue = abs(v-stt).
  end.
  if string (inValue) begins "."
    then v-str = "0" + string (inValue).
  else v-str = string (inValue).
  if v-stt <> 0 then v-str = "-" + v-str.
  return v-str.
end.
find first buf_shift-obj no-lock where buf_shift-obj.obj-type = p-obj-type
                                   and buf_shift-obj.obj-code = p-obj-code
                                   and buf_shift-obj.shift-date = p-shift-date
                                   and buf_shift-obj.shift-num = p-shift-num
                                   no-error .
if not available buf_shift-obj
then do :
  return .
end .
for each buf_shift-period no-lock where buf_shift-period.obj-type = buf_shift-obj.obj-type
                                    and buf_shift-period.obj-code = buf_shift-obj.obj-code
                                    and buf_shift-period.shift-date = buf_shift-obj.shift-date
                                    and buf_shift-period.shift-num = buf_shift-obj.shift-num,
  first buf_place no-lock where buf_place.pl-code = buf_shift-period.pl-code
:
  find first tt-pl-gds where tt-pl-gds.pl-code = buf_shift-period.pl-code
                         and tt-pl-gds.gds-code = buf_shift-period.gds-code
                         no-error .
  if not available tt-pl-gds
  then do :
    create tt-pl-gds .
    assign
      tt-pl-gds.pl-code = buf_shift-period.pl-code
      tt-pl-gds.loc1 = buf_place.loc1
      tt-pl-gds.gds-code = buf_shift-period.gds-code
      tt-pl-gds.num-pri-periods = 0
    .
  end .
  if buf_shift-period.period-type = 4
  then do :
    assign tt-pl-gds.num-pri-periods = tt-pl-gds.num-pri-periods + 1 .
  end .
end .
run create-esys-data .
run exp1C .
procedure create-esys-data :
  define variable sw as handle no-undo.
  define variable ii as integer no-undo .
  define variable v-num-pri-periods as integer no-undo .
  define variable v-period as character no-undo .
  define variable v-doc-code as character no-undo .
  create sax-writer sw.
  sw:set-output-destination ("memptr", expData).
  sw:encoding = "UTF-8".
  sw:fragment = true .
  sw:formatted = true .
  sw:start-document () .
    sw:start-element ("shift-period") .
      sw:write-data-element ("shift-date", iso-date(buf_shift-obj.shift-date)).
      sw:write-data-element ("shift-num", string(buf_shift-obj.shift-num)).
      sw:start-element ("tanks") .
        for each tt-pl-gds :
          assign v-num-pri-periods = 0 .
          sw:start-element ("tank") .
            sw:write-data-element ("tank-num", string(tt-pl-gds.loc1)) .
            sw:write-data-element ("gd-code", string(tt-pl-gds.gds-code)) .
            sw:start-element ("section-periods") .
              for each buf_shift-period no-lock where buf_shift-period.obj-type = buf_shift-obj.obj-type
                                                  and buf_shift-period.obj-code = buf_shift-obj.obj-code
                                                  and buf_shift-period.shift-date = buf_shift-obj.shift-date
                                                  and buf_shift-period.shift-num = buf_shift-obj.shift-num
                                                  and buf_shift-period.gds-code = tt-pl-gds.gds-code
                                                  and buf_shift-period.pl-code = tt-pl-gds.pl-code
                                                  by buf_shift-period.period-num
              :
                sw:start-element ("section-period") .
                  assign v-period = string(buf_shift-period.period-type) .
                  if buf_shift-period.period-type = 4
                  and tt-pl-gds.num-pri-periods > 1
                  then do :
                    assign
                      v-num-pri-periods = v-num-pri-periods + 1
                      v-period = string(buf_shift-period.period-type) + "." + string(v-num-pri-periods)
                    .
                  end .
                  sw:write-data-element ("period", v-period) .
                  if buf_shift-period.period-type = 0
                  or buf_shift-period.period-type = 1
                  then do :
                    sw:write-data-element ("initializ", string(1)) .
                  end .
                  if buf_shift-period.period-type = 1
                  or buf_shift-period.period-type = 3
                  then do :
                    assign
                      v-doc-code = entry(2, buf_shift-period.period-name, "№")
                      v-doc-code = entry(1, v-doc-code, ")")
                    .
                    sw:write-data-element ("before-invoice", v-doc-code) .
                  end .
                  if buf_shift-period.period-type = 4
                  then do :
                    assign
                      v-doc-code = entry(2, buf_shift-period.period-name, "№")
                      v-doc-code = entry(1, v-doc-code, ")")
                    .
                    sw:write-data-element ("from-invoice", v-doc-code) .
                    assign
                      v-doc-code = entry(3, buf_shift-period.period-name, "№")
                      v-doc-code = entry(1, v-doc-code, ")")
                    .
                    sw:write-data-element ("before-invoice", v-doc-code) .
                  end .
                  if buf_shift-period.period-type = 5
                  then do :
                    assign
                      v-doc-code = entry(2, buf_shift-period.period-name, "№")
                      v-doc-code = entry(1, v-doc-code, ")")
                    .
                    sw:write-data-element ("from-invoice", v-doc-code) .
                  end .
                  sw:write-data-element ("contrl-dnst", string-mth(round(buf_shift-period.control-density, 4))) .
                  sw:write-data-element ("implem15-dnst", string-mth(round(buf_shift-period.sales-density15, 4))) .
                  sw:write-data-element ("delta-dnst", string-mth(round(buf_shift-period.delta-density, 4))) .
                sw:end-element ("section-period") .
              end .
            sw:end-element ("section-periods") .
          sw:end-element ("tank") .
        end .
      sw:end-element ("tanks") .
    sw:end-element ("shift-period") .
  sw:end-document () .
end procedure .
procedure exp1C :
  run str/send1C-some-data.p (input parparentproc,
                              input this-procedure,
                              input this-procedure,
                              input expData,
                              input "shift-periods" + chr(4) + substitute("shift-obj&1&2",chr(3),string(rowid(buf_shift-obj))) )
                              no-error .
  if error-status:error
  then do :
    run write-to-log( "Ошибка при отправке в 1С. " + return-value ).
  end .
end procedure .
procedure write-to-log :
  define input param p-str as character no-undo .
  assign
    p-str = substitute( "&3&1&3&2&3", cur-time-string(), p-str, chr(10) )
  .
  output to value(log-file-name) append .
  put unformatted p-str .
  output close .
end procedure .
procedure write-log-and-file :
  define input parameter p-tab-position   as integer   no-undo.
  define input parameter p-file-name      as character no-undo .
  define input parameter p-log-level      as integer   no-undo .
  define input parameter p-log-string     AS CHARacter NO-UNDO.
  define variable v-jj as integer   no-undo .
  run write-to-log (input p-log-string) .
end procedure .
