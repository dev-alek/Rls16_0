block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.gds-prt OLD oldb.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись шкалы товара".
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
procedure gds-prth_write-gds-prt-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-prt for ub.c-gds-prt.
  do
  on error undo, return error
  :
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-gds-prt.
    buffer-copy oldb to buf_c-gds-prt
    assign
    buf_c-gds-prt.node-code          = (if p-new-record then ub.gds-prt.node-code else oldb.node-code)
    buf_c-gds-prt.prt-root           = (if p-new-record then ub.gds-prt.prt-root else oldb.prt-root)
    buf_c-gds-prt.chip-num           = next-value (s-ref-corr-chip, ub)
    buf_c-gds-prt.corr-time          = v-time
    buf_c-gds-prt.corr-user-db-num   = g#db-num
    buf_c-gds-prt.corr-user-name     = (if g#news then (chr(4) +  'СПН':U) else g#userid)
    buf_c-gds-prt.corr-date          = v-date
    buf_c-gds-prt.action = p-action
    .
  end.
end procedure.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if ub.gds-prt.node-name = '_Пустая шкала':U then do:
    if ub.gds-prt.root    <> true
    or ub.gds-prt.is-term <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильные атрибуты пустой шкалы" '_Пустая шкала':U skip
        "ub.gds-prt.upper-code" ub.gds-prt.upper-code skip
        "ub.gds-prt.node-code"  ub.gds-prt.node-code  skip
        "ub.gds-prt.prt-root"   ub.gds-prt.prt-root   skip
        "ub.gds-prt.root"       ub.gds-prt.root       skip
        "ub.gds-prt.is-term"    ub.gds-prt.is-term    skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
  if ub.gds-prt.root = true then do:
    define buffer buf_gds-prt for ub.gds-prt .
    find first buf_gds-prt no-lock
      where buf_gds-prt.root = true
        and buf_gds-prt.node-name = ub.gds-prt.node-name
        and recid(buf_gds-prt) <> recid(ub.gds-prt)
      no-error .
    if available buf_gds-prt then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не уникальное имя шкалы" skip
        "ub.gds-prt.upper-code"  ub.gds-prt.upper-code skip
        "ub.gds-prt.node-code"   ub.gds-prt.node-code  skip
        "ub.gds-prt.prt-root"    ub.gds-prt.prt-root   skip
        "ub.gds-prt.node-name"   ub.gds-prt.node-name  skip
        "Уже существует шкала" skip
        "buf_gds-prt.upper-code" buf_gds-prt.upper-code skip
        "buf_gds-prt.node-code"  buf_gds-prt.node-code  skip
        "buf_gds-prt.prt-root"   buf_gds-prt.prt-root   skip
        "buf_gds-prt.node-name"  buf_gds-prt.node-name  skip
        view-as alert-box error .
      undo, return error .
    end.
    if  ub.gds-prt.is-term = true
    and ub.gds-prt.node-name <> '_Пустая шкала':U then do:
      message
        vss-workfile vss-revision vss-description skip
        "В системе уже должна присутствовать пустая шкала" '_Пустая шкала':U skip
        "Нельзя завести еще одну пустую шкалу" ub.gds-prt.node-name skip
        "ub.gds-prt.upper-code" ub.gds-prt.upper-code skip
        "ub.gds-prt.node-code"  ub.gds-prt.node-code  skip
        "ub.gds-prt.prt-root"   ub.gds-prt.prt-root   skip
        "ub.gds-prt.node-name"  ub.gds-prt.node-name  skip
        view-as alert-box error .
      undo, return error .
    end.
    if ub.gds-prt.prt-root <> ub.gds-prt.upper-code then do:
      message
        vss-workfile vss-revision vss-description skip
        "Противоречивая информация о корне шкалы" skip
        "ub.gds-prt.upper-code" ub.gds-prt.upper-code skip
        "ub.gds-prt.node-code"  ub.gds-prt.node-code  skip
        "ub.gds-prt.prt-root"   ub.gds-prt.prt-root   skip
        "ub.gds-prt.node-name"  ub.gds-prt.node-name  skip
        view-as alert-box error .
      undo, return error .
    end.
    if ub.gds-prt.lvl-num <> 0 then do:
      message
        vss-workfile vss-revision vss-description skip
        "Номер уровня корня шкалы не должен отличаться от 0" skip
        "ub.gds-prt.upper-code" ub.gds-prt.upper-code skip
        "ub.gds-prt.node-code"  ub.gds-prt.node-code  skip
        "ub.gds-prt.prt-root"   ub.gds-prt.prt-root   skip
        "ub.gds-prt.node-name"  ub.gds-prt.node-name  skip
        "ub.gds-prt.lvl-num"    ub.gds-prt.lvl-num    skip
        view-as alert-box error .
      undo, return error .
    end.
    if ub.gds-prt.f-name <> "" then do:
      message
        vss-workfile vss-revision vss-description skip
        "Полное имя корня шкалы не должно отличаться от пустой строки" skip
        "ub.gds-prt.upper-code" ub.gds-prt.upper-code skip
        "ub.gds-prt.node-code"  ub.gds-prt.node-code  skip
        "ub.gds-prt.prt-root"   ub.gds-prt.prt-root   skip
        "ub.gds-prt.node-name"  ub.gds-prt.node-name  skip
        "ub.gds-prt.f-name"     ub.gds-prt.f-name     skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
  if not g#news then do:
    define variable v-l as logical no-undo .
    buffer-compare oldb to ub.gds-prt
    case-sensitive
    save result in v-l.
    if not v-l then
    run gds-prth_write-gds-prt-trigger in this-procedure (
                                                            input new(ub.gds-prt)
                                                           ,input (if new(ub.gds-prt)
                                                                   then integer('1':U)
                                                                   else integer('2':U))
                                                           ).
  end.
  run str/callnews.p
    (input 'gds-prt':U
    ,input (buffer ub.gds-prt:handle)
    ).
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input 'update':U
        , input 'gds-prt':U
        , input ( buffer ub.gds-prt:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , chr(10)
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
  end.
end.
