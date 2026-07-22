define input  parameter parparentproc as handle           no-undo.
define input  parameter p-cre-db-num  as integer   no-undo .
define input  parameter p-task-type   as character no-undo .
define input  parameter p-task-num    as integer   no-undo .
define output parameter p-cancel      as logical      no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор параметров для экспорта по расписанию.".
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
define temp-table temp-schedule-free no-undo
field free-id as character
field free-task-name as character
field proc-run-name as character
field proc-param-edit-name as character
field conf-param as character
field is-gbd as logical
field is-ubd as logical
field enable-concurrent-0 as logical
field enable-concurrent-db as logical
field other-info as character
field enc-key as character
field is-rum as logical
index pi is unique primary
free-id.
procedure schedule-attr-name :
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
    if index(p-code, chr(4)) > 0 then do:
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-code :
            when 'schedule-param-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-obj-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-oss-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-gds-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-doc-type-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-date-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-filter':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-filter-2':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schd-free-id':U then do:     assign     p-label = "Идентификатор произвольной задачи"     p-type = 'C':U      p-format = "X(30)"     p-label = "Идентификатор произвольной задачи"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
      otherwise do:
        undo, return error "Неизвестный атрибут строки расписания" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure schedule-attr-tooltip :
do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-code :
            when 'schedule-param-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-obj-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-oss-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-gds-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-doc-type-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-date-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-filter':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-filter-2':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schd-free-id':U then do:     assign     p-tooltip = "Идентификатор произвольной задачи"     p-label = "Идентификатор произвольной задачи" .   end.
      otherwise do:
            undo, return error "Неизвестный атрибут строки расписания" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure schedule-attr-value :
do
on error undo, return error return-value
:
define input parameter  p-cre-db-num as integer    no-undo.
define input parameter  p-task-type  as character  no-undo.
define input parameter  p-task-num   as integer    no-undo.
define input parameter  p-code       as character  no-undo.
define output parameter p-value      as character  no-undo.
define output parameter p-type       as character  no-undo.
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define buffer buf_schedule-attr for ub.schedule-attr.
    run schedule-attr-name in this-procedure (
          input  p-code
        , output p-type
        , output v-format
        , output v-label
        , output v-user-can-edit
        , output v-output-display
        , output v-other
    ) no-error .
    if error-status :error
    then do:
        undo, return error return-value .
    end.
    if p-code begins ('schd-free-id':U + chr(4))
    and entry(2, p-code, chr(4)) = '':U then do:
      find first buf_schedule-attr no-lock
          where buf_schedule-attr.cre-db-num = p-cre-db-num
            and buf_schedule-attr.task-type  = p-task-type
            and buf_schedule-attr.task-num   = p-task-num
            and buf_schedule-attr.attr-code  begins p-code
      no-error .
    end.
    else do:
      find first buf_schedule-attr no-lock
          where buf_schedule-attr.cre-db-num = p-cre-db-num
            and buf_schedule-attr.task-type  = p-task-type
            and buf_schedule-attr.task-num   = p-task-num
            and buf_schedule-attr.attr-code  = p-code
      no-error .
    end.
    if available buf_schedule-attr
    then do:
        assign
            p-value = buf_schedule-attr.attr-value
        .
    end.
    else do:
      if p-code begins ('schd-free-id':U + chr(4) ) then do:
         run schedule-attr-get-free-props in this-procedure (input entry(2, p-code, chr(4)), output p-value).
      end.
      else do:
        assign
            p-value = if p-type = 'L':U then "no":U else ""
        .
      end.
    end.
end.
end procedure.
procedure schedule-attr-write :
do
on error undo, return error
:
define input parameter p-cre-db-num  as integer   no-undo.
define input parameter p-task-type   as character no-undo.
define input parameter p-task-num    as integer   no-undo.
define input parameter p-code        as character no-undo.
define input parameter p-value       as character no-undo.
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    define buffer buf_schedule-attr for ub.schedule-attr .
    run schedule-attr-name in this-procedure (
          input  p-code
        , output v-type
        , output v-format
        , output v-label
        , output v-user-can-edit
        , output v-output-display
        , output v-other
    ) no-error.
    if error-status :error
    then do:
        undo, return error return-value.
    end.
    find first buf_schedule-attr exclusive-lock
         where buf_schedule-attr.cre-db-num = p-cre-db-num
           and buf_schedule-attr.task-type  = p-task-type
           and buf_schedule-attr.task-num   = p-task-num
           and buf_schedule-attr.attr-code  = p-code
    no-error.
    if not available buf_schedule-attr
    then do:
        create buf_schedule-attr.
        assign
          buf_schedule-attr.cre-db-num = p-cre-db-num
          buf_schedule-attr.task-type  = p-task-type
          buf_schedule-attr.task-num   = p-task-num
          buf_schedule-attr.attr-code  = p-code
          buf_schedule-attr.attr-value = p-value
        .
    end.
    else do:
        assign
            buf_schedule-attr.attr-value = p-value
        .
    end.
end.
end procedure.
procedure schedule-attr-delete :
do
on error undo, return error
:
define input  parameter p-cre-db-num  as integer   no-undo.
define input  parameter p-task-type   as character no-undo.
define input  parameter p-task-num    as integer   no-undo.
define input  parameter p-code        as character no-undo.
define output parameter p-deleted     as logical   no-undo.
    define buffer buf_schedule-attr for ub.schedule-attr .
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    run schedule-attr-name in this-procedure (
          input p-code
        , output v-type
        , output v-format
        , output v-label
        , output v-user-can-edit
        , output v-output-display
        , output v-other
    ) no-error .
    if error-status :error
    then do:
        undo, return error return-value .
    end.
    find first buf_schedule-attr exclusive-lock
         where buf_schedule-attr.cre-db-num = p-cre-db-num
           and buf_schedule-attr.task-type  = p-task-type
           and buf_schedule-attr.task-num   = p-task-num
           and buf_schedule-attr.attr-code  = p-code
    no-error.
    if not available buf_schedule-attr
    then do:
        assign
            p-deleted = no
        .
    end.
    else do:
        delete buf_schedule-attr.
        assign
            p-deleted = yes
        .
    end.
end.
end procedure.
procedure schedule-attr-news :
do
on error undo, return error
:
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-code :
            when 'schedule-param-list':U then do:     assign     p-news = false.   end.
            when 'schedule-obj-list':U then do:     assign     p-news = false.   end.
            when 'schedule-oss-list':U then do:     assign     p-news = false.   end.
            when 'schedule-gds-list':U then do:     assign     p-news = false.   end.
            when 'schedule-doc-type-list':U then do:     assign     p-news = false.   end.
            when 'schedule-date-list':U then do:     assign     p-news = false.   end.
            when 'schedule-filter':U then do:     assign     p-news = false.   end.
            when 'schedule-filter-2':U then do:     assign     p-news = false.   end.
            when 'schd-free-id':U then do:     assign     p-news = false.   end.
      otherwise do:
        undo, return error "неизвестный атрибут строки расписания" + " " + p-code .
      end.
    end.
end.
end procedure.
procedure schedule-attr-extract-logical :
do
on error undo, return error
:
define input  parameter p-parameter-number   as integer      no-undo.
define input  parameter p-parameter-list     as character    no-undo.
define output parameter p-parameter-value   as logical      no-undo.
    if num-entries( p-parameter-list ) > p-parameter-number - 1
    then do:
        assign
            p-parameter-value   = ( entry( p-parameter-number, p-parameter-list ) = "yes" )
        .
    end.
    else do:
        assign
            p-parameter-value   = no
        .
    end.
end.
end procedure.
procedure schedule-attr-get-free-id :
do
on error undo, return error return-value
:
  define input  parameter p-cre-db-num  as integer   no-undo.
  define input  parameter p-task-type   as character no-undo.
  define input  parameter p-task-num    as integer   no-undo.
  define output parameter p-free-id     as character no-undo.
  define buffer buf_schedule-attr for ub.schedule-attr.
  find first buf_schedule-attr no-lock
      where buf_schedule-attr.cre-db-num = p-cre-db-num
        and buf_schedule-attr.task-type  = p-task-type
        and buf_schedule-attr.task-num   = p-task-num
        and buf_schedule-attr.attr-code  begins  ('schd-free-id':U + chr(4))
  no-error .
  if available buf_schedule-attr then
  assign
  p-free-id = entry(2, buf_schedule-attr.attr-code, chr(4))
  no-error
  .
end.
end procedure.
procedure schedule-attr-get-free-props :
  define input parameter p-free-id as character no-undo .
  define output parameter p-value as character no-undo .
  define buffer buf_temp-schedule-free for temp-schedule-free.
  do
  on error undo, return error return-value
  :
    find first buf_temp-schedule-free no-lock no-error .
    if not available buf_temp-schedule-free then do:
      run schedule-attr-fill-free-props in this-procedure .
    end.
    find first buf_temp-schedule-free where
            buf_temp-schedule-free.free-id = p-free-id no-error.
    if available buf_temp-schedule-free then do:
      assign
      p-value = buf_temp-schedule-free.free-task-name       + chr(4) +
                buf_temp-schedule-free.proc-run-name        + chr(4) +
                buf_temp-schedule-free.proc-param-edit-name + chr(4) +
                buf_temp-schedule-free.conf-param           + chr(4) +
                string(buf_temp-schedule-free.is-gbd)       + chr(4) +
                string(buf_temp-schedule-free.is-ubd)       + chr(4) +
                string(buf_temp-schedule-free.enable-concurrent-0) + chr(4) +
                string(buf_temp-schedule-free.enable-concurrent-db) + chr(4) +
                buf_temp-schedule-free.other-info
      .
    end.
    else do:
     if p-free-id <> '':U then return error substitute("&1 &2 &3&4Неопределены процедуры для работы с произвольной задачей по расписанию&4" +
                           "id произвольной задачи - &5"
                           ,vss-workfile
                           ,vss-revision
                           ,vss-description
                           ,chr(10)
                           ,p-free-id).
    end.
  end.
end procedure.
procedure schedule-attr-is-rum-free-id :
define input parameter p-free-id as character no-undo .
define output parameter p-is-rum as logical no-undo .
define buffer buf_temp-schedule-free for temp-schedule-free.
do
on error undo, return error
:
    find first buf_temp-schedule-free no-lock no-error .
    if not available buf_temp-schedule-free then do:
      run schedule-attr-fill-free-props in this-procedure .
    end.
    find first buf_temp-schedule-free where
            buf_temp-schedule-free.free-id = p-free-id no-error.
    if available buf_temp-schedule-free
    and buf_temp-schedule-free.is-rum
    then do:
      p-is-rum = yes.
    end.
end.
end procedure.
procedure schedule-attr-fill-free-props :
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define buffer buf_temp-schedule-free for temp-schedule-free.
define variable v-answer as logical no-undo .
  do
  on error undo, return error substitute("&1 &2 &3&4&5&4"
                                        ,vss-workfile
                                        ,vss-revision
                                        ,vss-description
                                        ,chr(10)
                                        ,error-status:get-message(1) )
  :
    run gbl/filename.p (
                    input 'cmp/shd-free.d'
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) .
    input from value(v-full-path).
    repeat :
      create buf_temp-schedule-free.
      import buf_temp-schedule-free.
    END.
    input close.
    _ff:
    for each buf_temp-schedule-free :
      if buf_temp-schedule-free.free-id = '':U then do:
         delete buf_temp-schedule-free.
         next _ff.
       end.
       run schedule-attr-check-enc in this-procedure (
                                                    input  buf_temp-schedule-free.free-id
                                                   ,input  (buf_temp-schedule-free.proc-run-name +
                                                            buf_temp-schedule-free.proc-param-edit-name +
                                                            buf_temp-schedule-free.conf-param +
                                                            string(buf_temp-schedule-free.is-gbd) +
                                                            string(buf_temp-schedule-free.is-ubd) +
                                                            string(buf_temp-schedule-free.enable-concurrent-0) +
                                                            string(buf_temp-schedule-free.enable-concurrent-db) +
                                                            string(buf_temp-schedule-free.other-info)
                                                            )
                                                    ,input  buf_temp-schedule-free.enc-key
                                                    ,output v-answer    ) no-error .
       if error-status:error
       or not v-answer then delete buf_temp-schedule-free.
     end.
  end.
end procedure.
Function schedule-attr-reverse returns character (str as character).
   define variable rev_incl_s as character init "" no-undo .
   define variable rev_incl_i as integer no-undo .
   define variable rev_incl_l as integer no-undo .
   rev_incl_l = length(str).
   do rev_incl_i = 1 to rev_incl_l:
      rev_incl_s = rev_incl_s + substr(str,rev_incl_l - rev_incl_i + 1,1).
   end.
   return rev_incl_s.
end.
procedure schedule-attr-check-enc.
  define input  parameter p-free-id   as character no-undo .
  define input  parameter p-value     as character no-undo .
  define input  parameter p-enc-value as character no-undo .
  define output parameter p-answer    as logical   no-undo .
  define variable tmp         as character no-undo .
  define variable v-enc-value as character no-undo .
  assign
  tmp = schedule-attr-reverse (trim (p-free-id)) + schedule-attr-reverse (trim (p-value)) .
  .
  run schedule-attr-pswd-enc in this-procedure
    ( input tmp
     ,output v-enc-value
    ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры pswd-enc" skip
      return-value skip
      error-status :get-message(1) skip
      view-as alert-box error .
    undo, return error .
  end.
  if v-enc-value = p-enc-value then do:
    assign
      p-answer = true
    .
  end.
  else do:
    assign
      p-answer = false
    .
  end.
end.
procedure schedule-attr-conf-enc.
  define input  parameter p-free-id   as character no-undo .
  define input  parameter p-value     as character no-undo .
  define output parameter p-enc-value as character no-undo .
  define variable tmp         as character no-undo .
  assign
    tmp = schedule-attr-reverse (trim (p-free-id)) + schedule-attr-reverse (trim (p-value))
  .
  run schedule-attr-pswd-enc in this-procedure
    ( input tmp
     ,output p-enc-value
    ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры pswd-enc" skip
      return-value skip
      error-status :get-message(1) skip
      view-as alert-box error .
    undo, return error .
  end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure schedule-attr-pswd-enc :
  define input parameter  pswd     as character no-undo .
  define output parameter enc-pswd as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      enc-pswd = encode(pswd + string(index(pswd, "k")))
    .
  end.
end procedure.
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
define variable v-obj-list              as character    no-undo.
define variable v-host-name             as character    no-undo.
define variable v-today                 as date         no-undo.
define variable v-time                  as integer      no-undo.
define variable v-init-doc-type-list    as character    no-undo.
define variable v-doc-type-list         as character    no-undo.
define variable v-param-type            as character     no-undo.
define temp-table temp_obj-list no-undo
    field obj-type as character
    field obj-code as integer
    index pi is primary unique obj-type obj-code
.
define temp-table temp_db-num no-undo
    field db-num-key    as integer
    index pi is primary unique
        db-num-key
.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.
DEFINE BUTTON bt-sel-doc-type
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.
DEFINE BUTTON bt-sel-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK DEFAULT
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE ed-doc-type AS CHARACTER INITIAL "Все"
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-VERTICAL NO-BOX
     SIZE 40.75 BY 1.83 NO-UNDO.
DEFINE VARIABLE ed-doc-type-title AS CHARACTER INITIAL "Типы документов"
     VIEW-AS EDITOR NO-BOX
     SIZE 13.13 BY 1.71 NO-UNDO.
DEFINE VARIABLE ed-object AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 40.75 BY 3.38
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE fi-date-from AS DATE FORMAT "99/99/9999":U
     LABEL "Дата с"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE fi-date-to AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE fi-dates-title AS CHARACTER FORMAT "X(256)":U INITIAL " Выбор диапазона дат"
      VIEW-AS TEXT
     SIZE 21.63 BY .67 NO-UNDO.
DEFINE VARIABLE fi-days-ago AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "Дней назад"
     VIEW-AS FILL-IN
     SIZE 5.38 BY 1 NO-UNDO.
DEFINE VARIABLE fi-days-amount AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "Количество дней"
     VIEW-AS FILL-IN
     SIZE 5.38 BY 1 NO-UNDO.
DEFINE VARIABLE fi-doc-options AS CHARACTER FORMAT "X(256)":U INITIAL " Выгружать документы:"
      VIEW-AS TEXT
     SIZE 22.63 BY .67 NO-UNDO.
DEFINE VARIABLE rs-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "глобально", 1,
"по фирме", 2,
"по объектам", 3
     SIZE 13.75 BY 3.25 NO-UNDO.
DEFINE VARIABLE rs-date AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "за прошлые дни", 0,
"по текущую", 1,
"интервал", 2
     SIZE 19.38 BY 3.25 NO-UNDO.
DEFINE RECTANGLE rct-dates
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 79 BY 4.46.
DEFINE RECTANGLE rct-doc-options
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 79 BY 4.
DEFINE RECTANGLE rct-doc-type
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 79 BY 2.17.
DEFINE RECTANGLE rct-obj
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 79 BY 4.25.
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 78.75 BY 4.
DEFINE VARIABLE tb-chk-pay-code AS LOGICAL INITIAL no
     LABEL "По типу кассового платежа"
     VIEW-AS TOGGLE-BOX
     SIZE 27.5 BY .83 NO-UNDO.
DEFINE VARIABLE tb-cst-code AS LOGICAL INITIAL no
     LABEL "ГТД по строкам документов"
     VIEW-AS TOGGLE-BOX
     SIZE 28.38 BY .83 NO-UNDO.
DEFINE VARIABLE tb-exp-checks AS LOGICAL INITIAL no
     LABEL "Чеки"
     VIEW-AS TOGGLE-BOX
     SIZE 22 BY .83 NO-UNDO.
DEFINE VARIABLE tb-exp-day AS LOGICAL INITIAL no
     LABEL "Товары по дням"
     VIEW-AS TOGGLE-BOX
     SIZE 18.88 BY .83 NO-UNDO.
DEFINE VARIABLE tb-exp-doc AS LOGICAL INITIAL no
     LABEL "Документы"
     VIEW-AS TOGGLE-BOX
     SIZE 16.25 BY .83 NO-UNDO.
DEFINE VARIABLE tb-exp-fo AS LOGICAL INITIAL no
     LABEL "Фин.обязательства"
     VIEW-AS TOGGLE-BOX
     SIZE 20.25 BY .83 NO-UNDO.
DEFINE VARIABLE tb-exp-fp AS LOGICAL INITIAL no
     LABEL "Фин.платежи"
     VIEW-AS TOGGLE-BOX
     SIZE 20.25 BY .83 NO-UNDO.
DEFINE VARIABLE tb-exp-ref AS LOGICAL INITIAL no
     LABEL "Справочники"
     VIEW-AS TOGGLE-BOX
     SIZE 16.25 BY .83 NO-UNDO.
DEFINE VARIABLE tb-exp-ref-ext AS LOGICAL INITIAL no
     LABEL "Расширенный экспорт"
     VIEW-AS TOGGLE-BOX
     SIZE 24.38 BY .83 NO-UNDO.
DEFINE VARIABLE tb-exp-stk AS LOGICAL INITIAL no
     LABEL "Товарные остатки"
     VIEW-AS TOGGLE-BOX
     SIZE 22.13 BY .83 NO-UNDO.
DEFINE VARIABLE tb-exp-stk-supp AS LOGICAL INITIAL no
     LABEL "По поставщикам"
     VIEW-AS TOGGLE-BOX
     SIZE 20.25 BY .83 NO-UNDO.
DEFINE VARIABLE tb-exp-way AS LOGICAL INITIAL no
     LABEL "Товары в пути"
     VIEW-AS TOGGLE-BOX
     SIZE 21.5 BY .83 NO-UNDO.
DEFINE VARIABLE tb-incr AS LOGICAL INITIAL no
     LABEL "Инкрементальная выгрузка"
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .83 NO-UNDO.
DEFINE VARIABLE tb-inkass-pay-code AS LOGICAL INITIAL no
     LABEL "По виду оплаты"
     VIEW-AS TOGGLE-BOX
     SIZE 24.38 BY .83 NO-UNDO.
DEFINE VARIABLE tb-not-fact-docs AS LOGICAL INITIAL no
     LABEL "Не закрытые документы"
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .83 NO-UNDO.
DEFINE VARIABLE tb-parts AS LOGICAL INITIAL no
     LABEL "По партиям"
     VIEW-AS TOGGLE-BOX
     SIZE 26.13 BY .83 NO-UNDO.
DEFINE VARIABLE tb-pay-desk AS LOGICAL INITIAL no
     LABEL "По кассе"
     VIEW-AS TOGGLE-BOX
     SIZE 13 BY .83 NO-UNDO.
DEFINE VARIABLE tb-pay-desk-cards AS LOGICAL INITIAL no
     LABEL "По префиксам карт"
     VIEW-AS TOGGLE-BOX
     SIZE 24.38 BY .83 NO-UNDO.
DEFINE VARIABLE tb-supp AS LOGICAL INITIAL no
     LABEL "Остатки по поставщикам"
     VIEW-AS TOGGLE-BOX
     SIZE 26.88 BY .83 NO-UNDO.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.25 COL 1.5
     Btn_Cancel AT ROW 1.25 COL 11.5
     tb-incr AT ROW 1.25 COL 23
     b-help AT ROW 1.25 COL 71
     tb-exp-doc AT ROW 3.5 COL 3.75
     tb-exp-ref AT ROW 3.5 COL 30.25
     tb-exp-fo AT ROW 3.5 COL 59.75
     tb-exp-day AT ROW 4.29 COL 3.75
     tb-exp-checks AT ROW 4.29 COL 6.75
     tb-exp-ref-ext AT ROW 4.29 COL 33.25
     tb-exp-fp AT ROW 4.5 COL 59.75
     tb-exp-way AT ROW 5.08 COL 3.75
     tb-exp-stk AT ROW 5.08 COL 30.25
     tb-exp-stk-supp AT ROW 5.92 COL 33.25
     fi-days-amount AT ROW 7.83 COL 41.75 COLON-ALIGNED
     rs-date AT ROW 8.17 COL 3.5 NO-LABEL
     fi-days-ago AT ROW 9.04 COL 41.75 COLON-ALIGNED
     fi-date-from AT ROW 10.29 COL 30.63 COLON-ALIGNED
     fi-date-to AT ROW 10.33 COL 47.38 COLON-ALIGNED
     tb-supp AT ROW 11.33 COL 27.88
     rs-1 AT ROW 12.5 COL 3.5 NO-LABEL
     ed-object AT ROW 12.5 COL 20.88 NO-LABEL
     bt-sel-obj AT ROW 14.79 COL 17.38
     ed-doc-type AT ROW 16.71 COL 16.88 NO-LABEL
     ed-doc-type-title AT ROW 16.79 COL 3 NO-LABEL
     bt-sel-doc-type AT ROW 17.38 COL 58.13
     tb-inkass-pay-code AT ROW 19.58 COL 3.13
     tb-cst-code AT ROW 19.58 COL 33.13
     tb-chk-pay-code AT ROW 20.42 COL 3.13
     tb-parts AT ROW 20.42 COL 33.13
     tb-pay-desk AT ROW 21.21 COL 6.13
     tb-not-fact-docs AT ROW 21.21 COL 33.13
     tb-pay-desk-cards AT ROW 22 COL 6.13
     fi-dates-title AT ROW 7.08 COL 1 COLON-ALIGNED NO-LABEL
     fi-doc-options AT ROW 18.79 COL 1 COLON-ALIGNED NO-LABEL
     " Список выгрузки:" VIEW-AS TEXT
          SIZE 18.88 BY .79 AT ROW 2.63 COL 4
     rct-dates AT ROW 7.29 COL 2
     rct-obj AT ROW 12 COL 2
     rct-doc-type AT ROW 16.5 COL 2
     rct-doc-options AT ROW 19 COL 2
     RECT-5 AT ROW 3 COL 2.25
     SPACE(0.37) SKIP(16.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры экспорта по расписанию"
         CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       ed-doc-type:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       tb-supp:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF bt-sel-doc-type IN FRAME Dialog-Frame
DO:
    define variable v-cancel     as logical           no-undo.
    define variable v-oper-num   as integer           no-undo.
    define variable v-doc-type-select as character no-undo .
    assign
    v-doc-type-select = (if input frame Dialog-Frame tb-exp-doc then "trn-doc":U else "":U)
    v-doc-type-select = (if input frame Dialog-Frame tb-exp-fp
                        then (v-doc-type-select + (if v-doc-type-select = "":U then "":U else chr(44)) + "fin-doc":U)
                        else v-doc-type-select)
    .
    run bge/bgeseltp.w (
          input v-doc-type-select
        , input v-init-doc-type-list
        , output v-doc-type-list
        , output v-cancel
    ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора типов операций."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-cancel = yes
    then do:
        assign
            v-doc-type-list = v-init-doc-type-list
        .
    end.
    else do:
        assign
            v-init-doc-type-list    = v-doc-type-list
        .
        if v-doc-type-list = ''
        then do:
            assign
                ed-doc-type :screen-value in frame Dialog-Frame = "Все"
            .
        end.
        else do:
            assign
                ed-doc-type :screen-value in frame Dialog-Frame = ''
            .
            do v-oper-num = 1 to num-entries( 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U )
            :
                if lookup( entry( v-oper-num, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ), v-init-doc-type-list ) <> 0
                then do:
                    assign
                        ed-doc-type :screen-value in frame Dialog-Frame = ed-doc-type :screen-value in frame Dialog-Frame
                                                    + entry( v-oper-num, 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ) + chr(10)
                    .
                end.
            end.
            do v-oper-num = 1 to num-entries( 'пко,рко,ппп,рпп,апп,апр,':U )
            :
                if lookup( entry( v-oper-num, 'пко,рко,ппп,рпп,апп,апр,':U ), v-init-doc-type-list ) <> 0
                then do:
                    assign
                        ed-doc-type :screen-value in frame Dialog-Frame = ed-doc-type :screen-value in frame Dialog-Frame
                                                    + entry( v-oper-num, 'приходный кассовый ордер,расходный кассовый ордер,приходное платежное поручение,расходное платежное поручение,апп,апр':U ) + chr(10)
                    .
                end.
            end.
        end.
    end.
END.
ON CHOOSE OF bt-sel-obj IN FRAME Dialog-Frame
DO:
    define variable v-obj-list           as character no-undo .
    define variable v-exclude-obj-list   as character no-undo .
    define variable v-object-available as logical   no-undo .
    assign
        rs-1 :screen-value  = "3"
    .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_clear in this-procedure  .
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-object-available
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры gbl/usobjava.i" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return no-apply .
    end.
    if v-object-available = true
    then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_append in this-procedure
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  )  .
    end.
    define variable v-user-select as logical   no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
    if v-user-select <> true
    then do:
      message
        "Объект не выбран"
        view-as alert-box information .
      return no-apply .
    end.
    define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
    for each buf_userobjs_temp-user-obj
    on error undo, return no-apply
    :
      create temp_obj-list .
      assign
        temp_obj-list.obj-type = buf_userobjs_temp-user-obj.obj-type
        temp_obj-list.obj-code = buf_userobjs_temp-user-obj.obj-code
      .
    end.
    run select-objects-only-this-db in this-procedure
      (output v-obj-list
      ,output v-exclude-obj-list
      ).
    if v-exclude-obj-list <> ""
    then do:
        message
            "Из списка выбранных объектов исключены"
            skip "объекты, не принадлежащие БД, указанной в расписании:"
            skip(1)
            skip v-exclude-obj-list
        view-as alert-box information.
    end.
    assign
        ed-object :screen-value = v-obj-list
    .
END.
ON CHOOSE OF Btn_Cancel IN FRAME Dialog-Frame
DO:
    assign
        p-cancel = yes
    .
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
    define variable v-obj-list as character     no-undo.
    ASSIGN
        rs-date
        fi-days-amount
        fi-days-ago
        fi-date-from
        fi-date-to
        rs-1
        tb-supp
        tb-inkass-pay-code
        tb-cst-code
        tb-parts
        tb-chk-pay-code
        tb-pay-desk
        tb-pay-desk-cards
        tb-not-fact-docs
        tb-exp-doc
        tb-exp-ref
        tb-exp-day
        tb-exp-way
        tb-exp-ref-ext
        tb-exp-stk
        tb-exp-stk-supp
        tb-incr
        tb-exp-checks
        tb-exp-fo
        tb-exp-fp
    .
    if tb-exp-doc  = no
    and tb-exp-ref = no
    and tb-exp-fo = no
    and tb-exp-fp = no
    and ( ( tb-exp-day = no
            and tb-exp-way = no
            and tb-exp-stk = no )
       or ( tb-incr = yes ) )
    then do:
        message
            skip "Выберите по крайней мере один тип выгрузки"
            skip "или отмените ввод параметров выгрузки."
        view-as alert-box warning
        buttons ok
        title "Не выбран тип выгрузки".
        undo, return no-apply.
    end.
    case rs-1
    :
    when 1
    then do:
        assign
            v-obj-list = ""
        .
    end.
    when 2
    then do:
        assign
            v-obj-list = ""
        .
    end.
    when 3
    then do:
        assign
            v-obj-list = ""
        .
        for each temp_obj-list
        :
            assign
                v-obj-list = v-obj-list
                        + ( if v-obj-list = "" then "" else "," ) + temp_obj-list.obj-type
                        + "," + string( temp_obj-list.obj-code )
            .
        end.
    end.
    end case.
    find first temp_obj-list no-error.
    if not available temp_obj-list
    and rs-1 = 3
    then do:
        message
            "Не выбраны объекты для выгрузки."
        view-as alert-box warning.
        undo, return no-apply.
    end.
    run attach-attr-to-schedule-line in this-procedure (
          input rs-date
        , input fi-days-amount
        , input fi-days-ago
        , input fi-date-from
        , input fi-date-to
        , input rs-1
        , input v-obj-list
        , input v-doc-type-list
        , input tb-supp
        , input tb-inkass-pay-code
        , input tb-cst-code
        , input tb-parts
        , input tb-chk-pay-code
        , input tb-pay-desk
        , input tb-pay-desk-cards
        , input tb-not-fact-docs
        , input tb-exp-doc
        , input tb-exp-ref
        , input tb-exp-day
        , input tb-exp-way
        , input tb-exp-ref-ext
        , input tb-exp-stk
        , input tb-exp-stk-supp
        , input tb-incr
        , input tb-exp-checks
        , input tb-exp-fo
        , input tb-exp-fp
    ).
    APPLY "GO" TO FRAME Dialog-Frame.
END.
ON RETURN OF fi-date-from IN FRAME Dialog-Frame
DO:
    APPLY "ENTRY" TO fi-date-to IN FRAME Dialog-Frame.
    RETURN NO-APPLY.
END.
ON RETURN OF fi-date-to IN FRAME Dialog-Frame
DO:
    APPLY "ENTRY" TO btn_OK IN FRAME Dialog-Frame.
    RETURN NO-APPLY.
END.
ON VALUE-CHANGED OF rs-1 IN FRAME Dialog-Frame
DO:
    assign
        rs-1
    .
    run object-select in this-procedure (
        input rs-1
    ) .
END.
ON VALUE-CHANGED OF rs-date IN FRAME Dialog-Frame
DO:
assign
    rs-date
.
run date-select in this-procedure (
    input rs-date
) .
END.
ON VALUE-CHANGED OF tb-chk-pay-code IN FRAME Dialog-Frame
DO:
    assign
        tb-chk-pay-code
    .
    run manage-tb-chk-pay-code in this-procedure.
END.
ON VALUE-CHANGED OF tb-exp-checks IN FRAME Dialog-Frame
DO:
    assign
        tb-exp-day
    .
    run manage-options in this-procedure.
END.
ON VALUE-CHANGED OF tb-exp-day IN FRAME Dialog-Frame
DO:
    assign
        tb-exp-day
    .
    run manage-options in this-procedure.
END.
ON VALUE-CHANGED OF tb-exp-doc IN FRAME Dialog-Frame
DO:
    assign
        tb-exp-doc
    .
    run manage-options in this-procedure.
END.
ON VALUE-CHANGED OF tb-exp-fo IN FRAME Dialog-Frame
DO:
    assign
        tb-exp-fo
    .
    run manage-options in this-procedure.
END.
ON VALUE-CHANGED OF tb-exp-fp IN FRAME Dialog-Frame
DO:
    assign
        tb-exp-fp
    .
    run manage-options in this-procedure.
END.
ON VALUE-CHANGED OF tb-exp-ref IN FRAME Dialog-Frame
DO:
    assign
        tb-exp-ref
    .
    run manage-tb-exp-ref in this-procedure.
    run manage-options in this-procedure.
END.
ON VALUE-CHANGED OF tb-exp-stk IN FRAME Dialog-Frame
DO:
    assign
        tb-exp-stk
    .
    run manage-tb-exp-stk in this-procedure.
    run manage-options in this-procedure.
END.
ON VALUE-CHANGED OF tb-exp-way IN FRAME Dialog-Frame
DO:
    assign
        tb-exp-way
    .
    run manage-options in this-procedure.
END.
ON VALUE-CHANGED OF tb-incr IN FRAME Dialog-Frame
DO:
    assign
        tb-incr
    .
    run manage-options in this-procedure.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of fi-date-from in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of fi-date-from in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of fi-date-from in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of fi-date-from in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of fi-date-from in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of fi-date-from in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date10
    MENU-ITEM m-ed-date10-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date10-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date10-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date10-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if fi-date-from :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      fi-date-from :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date10 :HANDLE
      fi-date-from :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle10 as handle no-undo .
  assign
    v-label-handle10 = fi-date-from :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle10)
  then do:
    if v-label-handle10 :tooltip = ""
    or v-label-handle10 :tooltip = ?
    then do:
      assign
        v-label-handle10 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date10-1 in menu m-ed-date10 DO:
    apply "ctrl-b":U to fi-date-from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-2 in menu m-ed-date10 DO:
    apply "ctrl-d":U to fi-date-from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-3 in menu m-ed-date10 DO:
    apply "ctrl-e":U to fi-date-from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-4 in menu m-ed-date10 DO:
    apply "ctrl-f":U to fi-date-from in frame Dialog-Frame .
  END.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of fi-date-to in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of fi-date-to in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of fi-date-to in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of fi-date-to in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of fi-date-to in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of fi-date-to in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date12
    MENU-ITEM m-ed-date12-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date12-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date12-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date12-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if fi-date-to :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      fi-date-to :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date12 :HANDLE
      fi-date-to :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle12 as handle no-undo .
  assign
    v-label-handle12 = fi-date-to :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle12)
  then do:
    if v-label-handle12 :tooltip = ""
    or v-label-handle12 :tooltip = ?
    then do:
      assign
        v-label-handle12 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date12-1 in menu m-ed-date12 DO:
    apply "ctrl-b":U to fi-date-to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date12-2 in menu m-ed-date12 DO:
    apply "ctrl-d":U to fi-date-to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date12-3 in menu m-ed-date12 DO:
    apply "ctrl-e":U to fi-date-to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date12-4 in menu m-ed-date12 DO:
    apply "ctrl-f":U to fi-date-to in frame Dialog-Frame .
  END.
run cur-time in this-procedure ( output v-today
                               , output v-time
                               ).
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    define buffer buf_schedule      for ub.schedule.
    assign
        frame Dialog-Frame :title = frame Dialog-Frame :title
                    + ". " + p-task-type + ": Задача номер " + string( p-task-num )
    .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    run get-host-name in this-procedure ( output v-host-name ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при определении имени фирмы"
          skip "Код фирмы:" v-cntxt-host-code-obj
          skip "Имя фирмы будет отображаться как '" + 'орг':U + string( v-cntxt-host-code-obj ) + "'"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box warning.
        assign
            v-host-name = 'орг':U + string( v-cntxt-host-code-obj )
        .
    end.
    run init-param-values in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , output fi-days-amount
        , output rs-date
        , output fi-days-ago
        , output fi-date-from
        , output fi-date-to
        , output tb-supp
        , output v-obj-list
        , output rs-1
        , output v-init-doc-type-list
        , output tb-inkass-pay-code
        , output tb-cst-code
        , output tb-parts
        , output tb-chk-pay-code
        , output tb-pay-desk
        , output tb-pay-desk-cards
        , output tb-not-fact-docs
        , output tb-exp-doc
        , output tb-exp-ref
        , output tb-exp-day
        , output tb-exp-way
        , output tb-exp-ref-ext
        , output tb-exp-stk
        , output tb-exp-stk-supp
        , output tb-incr
        , output tb-exp-checks
        , output tb-exp-fo
        , output tb-exp-fp
    ).
    find first buf_schedule no-lock
         where buf_schedule.cre-db-num = p-cre-db-num
           and buf_schedule.task-type  = p-task-type
           and buf_schedule.task-num   = p-task-num
    no-error.
    if not available buf_schedule
    and (  p-task-type   <> 'autoexp':U
        or p-task-num    <> -1 )
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не найдена строка расписания."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run enable_UI.
    if available buf_schedule
    and buf_schedule.db-num-char <> "*"
    then do:
        rs-1 :disable("глобально").
        rs-1 :disable("по фирме").
    end.
    run date-select in this-procedure (
        input rs-date
    ).
    run object-select in this-procedure (
        input rs-1
    ).
    run init-fields in this-procedure .
    WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE attach-attr-to-schedule-line :
do
on error undo, return error
:
    define input parameter p-rs-date            as integer      no-undo.
    define input parameter p-days-amount        as integer      no-undo.
    define input parameter p-days-ago           as integer      no-undo.
    define input parameter p-date-from          as date         no-undo.
    define input parameter p-date-to            as date         no-undo.
    define input parameter p-rs-1               as integer      no-undo.
    define input parameter p-object-list        as character    no-undo.
    define input parameter p-doc-type-list      as character    no-undo.
    define input parameter p-tb-supp            as logical      no-undo.
    define input parameter p-tb-inkass-pay-code as logical      no-undo.
    define input parameter p-tb-cst-code        as logical      no-undo.
    define input parameter p-tb-parts           as logical      no-undo.
    define input parameter p-tb-chk-pay-code    as logical      no-undo.
    define input parameter p-tb-pay-desk        as logical      no-undo.
    define input parameter p-tb-pay-desk-cards  as logical      no-undo.
    define input parameter p-tb-not-fact-docs   as logical      no-undo.
    define input parameter p-tb-exp-doc         as logical      no-undo.
    define input parameter p-tb-exp-ref         as logical      no-undo.
    define input parameter p-tb-exp-day         as logical      no-undo.
    define input parameter p-tb-exp-way         as logical      no-undo.
    define input parameter p-tb-exp-ref-ext     as logical      no-undo.
    define input parameter p-tb-exp-stk         as logical      no-undo.
    define input parameter p-tb-exp-stk-supp    as logical      no-undo.
    define input parameter p-tb-incr            as logical      no-undo.
    define input parameter p-tb-exp-checks      as logical      no-undo.
    define input parameter p-tb-exp-fo          as logical      no-undo.
    define input parameter p-tb-exp-fp          as logical      no-undo.
    define variable v-attr-value as character     no-undo.
    define buffer buf_schedule      for ub.schedule.
    define buffer buf_schedule-attr for ub.schedule-attr.
    find first buf_schedule no-lock
         where buf_schedule.cre-db-num = p-cre-db-num
           and buf_schedule.task-type  = p-task-type
           and buf_schedule.task-num   = p-task-num
    no-error.
    if not available buf_schedule
    and (  p-task-type   <> 'autoexp':U
        or p-task-num    <> -1 )
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не найдена строка расписания."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    assign
        v-attr-value = string( p-rs-1 )
                        + "," + ( if p-tb-inkass-pay-code = yes then "yes" else "no" )
                        + "," + ( if p-tb-cst-code        = yes then "yes" else "no" )
                        + "," + ( if p-tb-not-fact-docs   = yes then "yes" else "no" )
                        + "," + ( if p-tb-supp            = yes then "yes" else "no" )
                        + "," + ( if p-tb-parts           = yes then "yes" else "no" )
                        + "," + ( if p-tb-chk-pay-code    = yes then "yes" else "no" )
                        + "," + ( if p-tb-exp-doc         = yes then "yes" else "no" )
                        + "," + ( if p-tb-exp-ref         = yes then "yes" else "no" )
                        + "," + ( if p-tb-exp-day         = yes then "yes" else "no" )
                        + "," + ( if p-tb-exp-way         = yes then "yes" else "no" )
                        + "," + ( if p-tb-exp-ref-ext     = yes then "yes" else "no" )
                        + "," + ( if p-tb-exp-stk         = yes then "yes" else "no" )
                        + "," + ( if p-tb-exp-stk-supp    = yes then "yes" else "no" )
                        + "," + string( v-cntxt-host-code-obj )
                        + "," + ( if tb-pay-desk          = yes then "yes" else "no" )
                        + "," + ( if tb-incr              = yes then "yes" else "no" )
                        + "," + ( if tb-exp-checks        = yes then "yes" else "no" )
                        + "," + ( if tb-exp-fo            = yes then "yes" else "no" )
                        + "," + ( if tb-exp-fp            = yes then "yes" else "no" )
                        + "," + ( if tb-pay-desk-cards    = yes then "yes" else "no" )
    .
    run schedule-attr-write in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input 'schedule-param-list':U
        , input v-attr-value
    ).
    run schedule-attr-write in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input 'schedule-obj-list':U
        , input p-object-list
    ).
    run schedule-attr-write in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input 'schedule-doc-type-list':U
        , input p-doc-type-list
    ).
    assign
        v-attr-value = string( p-rs-date )
                        + "," + string( p-days-amount )
                        + "," + string( p-days-ago    )
                        + "," + string( p-date-from   )
                        + "," + string( p-date-to     )
    .
    run schedule-attr-write in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input 'schedule-date-list':U
        , input v-attr-value
    ).
    for each buf_schedule-attr
    on error undo, return error
    :
        if buf_schedule-attr.task-type  <> 'autoexp':U
        or buf_schedule-attr.cre-db-num <> p-cre-db-num
        or buf_schedule-attr.task-num   <> -1
        or (
                buf_schedule-attr.attr-code <> 'schedule-date-list':U
            and buf_schedule-attr.attr-code <> 'schedule-param-list':U
            and buf_schedule-attr.attr-code <> 'schedule-obj-list':U
            and buf_schedule-attr.attr-code <> 'schedule-doc-type-list':U
        )
        then do:
            find first buf_schedule
                 where buf_schedule.cre-db-num = buf_schedule-attr.cre-db-num
                   and buf_schedule.task-type  = buf_schedule-attr.task-type
                   and buf_schedule.task-num   = buf_schedule-attr.task-num
            no-error.
            if not available buf_schedule
            then do:
                delete buf_schedule-attr.
            end.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE date-select :
do
on error undo, return error
:
define input parameter p-date-select-value as integer      no-undo.
    case p-date-select-value
    :
        when 0
        then do:
            hide
                fi-date-from in frame Dialog-Frame
                fi-date-to
            .
            view
                fi-days-ago
                fi-days-amount
            .
        end.
        when 1
        then do:
            hide
                fi-date-to
                fi-days-ago
                fi-days-amount
            .
            view
                fi-date-from
            .
        end.
        when 2
        then do:
            hide
                fi-days-ago
                fi-days-amount
            .
            view
                fi-date-from
                fi-date-to
            .
        end.
    end case.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY tb-incr tb-exp-doc tb-exp-ref tb-exp-fo tb-exp-day tb-exp-checks
          tb-exp-ref-ext tb-exp-fp tb-exp-way tb-exp-stk tb-exp-stk-supp
          fi-days-amount rs-date fi-days-ago fi-date-from fi-date-to rs-1
          ed-object ed-doc-type ed-doc-type-title tb-inkass-pay-code tb-cst-code
          tb-chk-pay-code tb-parts tb-pay-desk tb-not-fact-docs
          tb-pay-desk-cards fi-dates-title fi-doc-options
      WITH FRAME Dialog-Frame.
  ENABLE rct-dates rct-obj rct-doc-type rct-doc-options RECT-5 Btn_OK
         Btn_Cancel tb-incr b-help tb-exp-doc tb-exp-ref tb-exp-fo tb-exp-day
         tb-exp-checks tb-exp-ref-ext tb-exp-fp tb-exp-way tb-exp-stk
         tb-exp-stk-supp fi-days-amount rs-date fi-days-ago fi-date-from
         fi-date-to rs-1 bt-sel-obj ed-doc-type bt-sel-doc-type
         tb-inkass-pay-code tb-cst-code tb-chk-pay-code tb-parts tb-pay-desk
         tb-not-fact-docs tb-pay-desk-cards
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE extract-parameter :
do
on error undo, return error
:
end.
END PROCEDURE.
PROCEDURE get-host-name :
do
on error undo, return error
:
define output parameter p-host-name as character    no-undo.
define buffer buf_clients   for ub.clients.
    find first buf_clients no-lock
         where buf_clients.obj-type = 'орг':U
           and buf_clients.obj-code = v-cntxt-host-code-obj
    no-error.
    if not available buf_clients
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не удалось найти текущую фирму"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    else do:
        assign
            p-host-name = buf_clients.obj-name
        .
    end.
end.
END PROCEDURE.
PROCEDURE init-fields :
do
on error undo, return error
:
    define variable v-oper-num     as integer           no-undo.
    run manage-tb-exp-stk       in this-procedure.
    run manage-tb-exp-ref       in this-procedure.
    run manage-options          in this-procedure.
    run manage-tb-chk-pay-code  in this-procedure.
    assign
        v-doc-type-list = v-init-doc-type-list
    .
    if v-init-doc-type-list <> ?
    and v-init-doc-type-list <> ''
    then do:
        assign
            ed-doc-type :screen-value in frame Dialog-Frame = ""
        .
        do v-oper-num = 1 to num-entries( 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U )
        :
            if lookup( entry( v-oper-num, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ), v-init-doc-type-list ) <> 0
            then do:
                assign
                    ed-doc-type :screen-value in frame Dialog-Frame = ed-doc-type :screen-value in frame Dialog-Frame
                                                + entry( v-oper-num, 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ) + chr(10)
                .
            end.
        end.
        do v-oper-num = 1 to num-entries( 'пко,рко,ппп,рпп,апп,апр,':U )
        :
            if lookup( entry( v-oper-num, 'пко,рко,ппп,рпп,апп,апр,':U ), v-init-doc-type-list ) <> 0
            then do:
                assign
                    ed-doc-type :screen-value in frame Dialog-Frame = ed-doc-type :screen-value in frame Dialog-Frame
                                                + entry( v-oper-num, 'приходный кассовый ордер,расходный кассовый ордер,приходное платежное поручение,расходное платежное поручение,апп,апр':U ) + chr(10)
                .
            end.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE init-param-values :
do
on error undo, return error
:
define input  parameter p-cre-db-num            as integer   no-undo .
define input  parameter p-task-type             as character no-undo .
define input  parameter p-task-num              as integer   no-undo .
define output parameter p-days-amount           as integer      no-undo.
define output parameter p-rs-date               as integer      no-undo.
define output parameter p-days-ago              as integer      no-undo.
define output parameter p-date-from             as date         no-undo.
define output parameter p-date-to               as date         no-undo.
define output parameter p-tb-supp               as logical      no-undo.
define output parameter p-obj-list              as character    no-undo.
define output parameter p-rs-1                  as integer      no-undo.
define output parameter p-doc-type-list         as character    no-undo.
define output parameter p-tb-inkass-pay-code    as logical      no-undo.
define output parameter p-tb-cst-code           as logical      no-undo.
define output parameter p-tb-parts              as logical      no-undo.
define output parameter p-tb-chk-pay-code       as logical      no-undo.
define output parameter p-tb-pay-desk           as logical      no-undo.
define output parameter p-tb-pay-desk-cards     as logical      no-undo.
define output parameter p-tb-not-fact-docs      as logical      no-undo.
define output parameter p-tb-exp-doc            as logical      no-undo.
define output parameter p-tb-exp-ref            as logical      no-undo.
define output parameter p-tb-exp-day            as logical      no-undo.
define output parameter p-tb-exp-way            as logical      no-undo.
define output parameter p-tb-exp-ref-ext        as logical      no-undo.
define output parameter p-tb-exp-stk            as logical      no-undo.
define output parameter p-tb-exp-stk-supp       as logical      no-undo.
define output parameter p-tb-incr               as logical      no-undo.
define output parameter p-tb-exp-checks         as logical      no-undo.
define output parameter p-tb-exp-fo             as logical      no-undo.
define output parameter p-tb-exp-fp             as logical      no-undo.
    define variable v-counter       as integer       no-undo.
    define variable v-param-list    as character     no-undo.
    run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input 'schedule-doc-type-list':U
        , output p-doc-type-list
        , output v-param-type
    ) .
    run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input 'schedule-obj-list':U
        , output p-obj-list
        , output v-param-type
    ) .
    for each temp_obj-list
    :
        delete temp_obj-list.
    end.
    do v-counter = 1 to num-entries( p-obj-list ) / 2
    :
        create temp_obj-list.
        assign
            temp_obj-list.obj-type = entry( 2 * v-counter - 1,  p-obj-list )
            temp_obj-list.obj-code = integer( entry( 2 * v-counter,      p-obj-list ) )
        .
    end.
    run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input 'schedule-param-list':U
        , output v-param-list
        , output v-param-type
    ) .
    if v-param-list = ""
    then do:
        assign
            p-rs-1                  = 0
            p-tb-inkass-pay-code    = no
            p-tb-cst-code           = no
            p-tb-not-fact-docs      = no
            p-tb-supp               = no
            p-tb-parts              = no
            p-tb-chk-pay-code       = no
            p-tb-pay-desk           = no
            p-tb-pay-desk-cards     = no
            p-tb-exp-doc            = no
            p-tb-exp-ref            = no
            p-tb-exp-day            = no
            p-tb-exp-way            = no
            p-tb-exp-ref-ext        = no
            p-tb-exp-stk            = no
            p-tb-exp-stk-supp       = no
            p-tb-incr               = no
            p-tb-exp-checks         = no
            p-tb-exp-fo             = no
            p-tb-exp-fp             = no
        .
    end.
    else do:
        assign
            p-rs-1 = integer( entry( 1, v-param-list ) )
        .
        run schedule-attr-extract-logical in this-procedure (
              input 2
            , input v-param-list
            , output p-tb-inkass-pay-code
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 3
            , input v-param-list
            , output p-tb-cst-code
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 4
            , input v-param-list
            , output p-tb-not-fact-docs
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 5
            , input v-param-list
            , output p-tb-supp
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 6
            , input v-param-list
            , output p-tb-parts
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 7
            , input v-param-list
            , output p-tb-chk-pay-code
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 8
            , input v-param-list
            , output p-tb-exp-doc
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 9
            , input v-param-list
            , output p-tb-exp-ref
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 10
            , input v-param-list
            , output p-tb-exp-day
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 11
            , input v-param-list
            , output p-tb-exp-way
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 12
            , input v-param-list
            , output p-tb-exp-ref-ext
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 13
            , input v-param-list
            , output p-tb-exp-stk
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 14
            , input v-param-list
            , output p-tb-exp-stk-supp
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 16
            , input v-param-list
            , output p-tb-pay-desk
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 17
            , input v-param-list
            , output p-tb-incr
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 18
            , input v-param-list
            , output p-tb-exp-checks
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 19
            , input v-param-list
            , output p-tb-exp-fo
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 20
            , input v-param-list
            , output p-tb-exp-fp
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 21
            , input v-param-list
            , output p-tb-pay-desk-cards
        ).
    end.
    run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input 'schedule-date-list':U
        , output v-param-list
        , output v-param-type
    ) .
    if v-param-list = ""
    then do:
        define variable v-today as date      no-undo.
        define variable v-time  as integer   no-undo.
        run cur-time in this-procedure ( output v-today
                                       , output v-time
                                       ).
        assign
            p-rs-date       = 0
            p-days-amount   = 1
            p-days-ago      = 0
            p-date-from     = v-today - 1
            p-date-to       = v-today - 1
        .
    end.
    else do:
        assign
            p-rs-date       = integer( entry( 1, v-param-list ) )
            p-days-amount   = integer( entry( 2, v-param-list ) )
            p-days-ago      = integer( entry( 3, v-param-list ) )
            p-date-from     = date( entry( 4, v-param-list ) )
            p-date-to       = date( entry( 5, v-param-list ) )
        .
    end.
end.
END PROCEDURE.
PROCEDURE manage-options :
do
on error undo, return error
:
    assign
        rct-doc-options     :visible in frame Dialog-Frame = no
        fi-doc-options      :visible in frame Dialog-Frame = no
        tb-inkass-pay-code  :visible in frame Dialog-Frame = no
        tb-chk-pay-code     :visible in frame Dialog-Frame = no
        tb-pay-desk         :visible in frame Dialog-Frame = no
        tb-pay-desk-cards   :visible in frame Dialog-Frame = no
        tb-cst-code         :visible in frame Dialog-Frame = no
        tb-parts            :visible in frame Dialog-Frame = no
        tb-not-fact-docs    :visible in frame Dialog-Frame = no
        rct-doc-type        :visible in frame Dialog-Frame = no
        ed-doc-type-title   :visible in frame Dialog-Frame = no
        ed-doc-type         :visible in frame Dialog-Frame = no
        bt-sel-doc-type     :visible in frame Dialog-Frame = no
        rct-dates           :visible in frame Dialog-Frame = no
        fi-dates-title      :visible in frame Dialog-Frame = no
        rs-date             :visible in frame Dialog-Frame = no
        fi-days-amount      :visible in frame Dialog-Frame = no
        fi-days-ago         :visible in frame Dialog-Frame = no
        fi-date-from        :visible in frame Dialog-Frame = no
        fi-date-to          :visible in frame Dialog-Frame = no
    .
    if tb-incr = yes
    then do:
        assign
            tb-exp-day          :visible in frame Dialog-Frame = no
            tb-exp-way          :visible in frame Dialog-Frame = no
            tb-exp-stk          :visible in frame Dialog-Frame = no
            tb-exp-stk-supp     :visible in frame Dialog-Frame = no
            tb-exp-ref-ext      :visible in frame Dialog-Frame = no
            tb-exp-checks       :visible in frame Dialog-Frame = yes
            rct-obj             :visible in frame Dialog-Frame = yes
            rs-1                :visible in frame Dialog-Frame = yes
            bt-sel-obj          :visible in frame Dialog-Frame = yes
            ed-object           :visible in frame Dialog-Frame = yes
        .
        run object-select in this-procedure (
            input rs-1
        ).
        if tb-exp-doc = yes
        then do:
            enable
                tb-exp-checks
            with frame Dialog-Frame .
        end.
        else do:
            disable
                tb-exp-checks
            with frame Dialog-Frame .
        end.
    end.
    else do:
        assign
            tb-exp-day          :visible in frame Dialog-Frame = yes
            tb-exp-way          :visible in frame Dialog-Frame = yes
            tb-exp-stk          :visible in frame Dialog-Frame = yes
            tb-exp-stk-supp     :visible in frame Dialog-Frame = yes
            tb-exp-ref-ext      :visible in frame Dialog-Frame = yes
            tb-exp-checks       :visible in frame Dialog-Frame = no
            rct-obj             :visible in frame Dialog-Frame = no
            rs-1                :visible in frame Dialog-Frame = no
            bt-sel-obj          :visible in frame Dialog-Frame = no
            ed-object           :visible in frame Dialog-Frame = no
        .
        run object-select in this-procedure (
            input rs-1
        ).
        if tb-exp-doc = yes
        then do:
            assign
                rct-doc-options     :visible in frame Dialog-Frame = yes
                fi-doc-options      :visible in frame Dialog-Frame = yes
                tb-inkass-pay-code  :visible in frame Dialog-Frame = yes
                tb-chk-pay-code     :visible in frame Dialog-Frame = yes
                tb-pay-desk         :visible in frame Dialog-Frame = yes
                tb-pay-desk-cards   :visible in frame Dialog-Frame = yes
                tb-cst-code         :visible in frame Dialog-Frame = yes
                tb-parts            :visible in frame Dialog-Frame = yes
                tb-not-fact-docs    :visible in frame Dialog-Frame = yes
            .
        end.
        if tb-exp-doc = yes
        or tb-exp-fp = yes
        or tb-exp-fo = yes
        then do:
            assign
                rct-doc-type        :visible in frame Dialog-Frame = yes
                ed-doc-type-title   :visible in frame Dialog-Frame = yes
                ed-doc-type         :visible in frame Dialog-Frame = yes
                bt-sel-doc-type     :visible in frame Dialog-Frame = yes
            .
        end.
        if tb-exp-doc = yes
        or tb-exp-ref = yes
        or tb-exp-day = yes
        or tb-exp-way = yes
        or tb-exp-stk = yes
        or tb-exp-fo = yes
        or tb-exp-fp = yes
        then do:
            assign
                rct-obj             :visible in frame Dialog-Frame = yes
                rs-1                :visible in frame Dialog-Frame = yes
                bt-sel-obj          :visible in frame Dialog-Frame = yes
                ed-object           :visible in frame Dialog-Frame = yes
            .
        end.
        if tb-exp-doc = yes
        or tb-exp-day = yes
        or tb-exp-stk = yes
        or tb-exp-ref = yes
        or tb-exp-fo = yes
        or tb-exp-fp = yes
        then do:
            assign
                rct-dates           :visible in frame Dialog-Frame = yes
                fi-dates-title      :visible in frame Dialog-Frame = yes
                rs-date             :visible in frame Dialog-Frame = yes
                fi-days-amount      :visible in frame Dialog-Frame = yes
                fi-days-ago         :visible in frame Dialog-Frame = yes
                fi-date-from        :visible in frame Dialog-Frame = yes
                fi-date-to          :visible in frame Dialog-Frame = yes
            .
            run date-select in this-procedure (
                input rs-date
            ).
        end.
    end.
end.
END PROCEDURE.
PROCEDURE manage-tb-chk-pay-code :
do
on error undo, return error
:
    if tb-chk-pay-code = yes
    then do:
        assign
            tb-pay-desk :sensitive in frame Dialog-Frame = yes
            tb-pay-desk-cards :sensitive in frame Dialog-Frame = yes
        .
    end.
    else do:
        assign
            tb-pay-desk :sensitive in frame Dialog-Frame = no
            tb-pay-desk-cards :sensitive in frame Dialog-Frame = no
        .
    end.
end.
END PROCEDURE.
PROCEDURE manage-tb-exp-ref :
do
on error undo, return error
:
    if tb-exp-ref = yes
    then do:
        assign
            tb-exp-ref-ext :sensitive in frame Dialog-Frame = yes
        .
    end.
    else do:
        assign
            tb-exp-ref-ext :sensitive in frame Dialog-Frame = no
        .
    end.
end.
END PROCEDURE.
PROCEDURE manage-tb-exp-stk :
do
on error undo, return error
:
    if tb-exp-stk = yes
    then do:
        assign
            tb-exp-stk-supp :sensitive in frame Dialog-Frame = yes
        .
    end.
    else do:
        assign
            tb-exp-stk-supp :sensitive in frame Dialog-Frame = no
        .
    end.
end.
END PROCEDURE.
PROCEDURE object-select :
do
on error undo, return error
:
define input parameter p-rs-1   as integer      no-undo.
case p-rs-1
:
    when 1
    then do:
        assign
            ed-object :screen-value in frame Dialog-frame = ""
        .
    end.
    when 2
    then do:
        assign
            ed-object :screen-value = v-host-name
        .
    end.
    when 3
    then do:
        assign
            ed-object :screen-value = ""
        .
        for each temp_obj-list
        :
            assign
                ed-object :screen-value = ed-object :screen-value
                    + ( if ed-object :screen-value = "" then "" else ", " )
                    + temp_obj-list.obj-type + string( temp_obj-list.obj-code )
            .
        end.
    end.
end case.
end.
END PROCEDURE.
PROCEDURE select-objects-only-this-db :
define output parameter p-only-this-db-obj-list as character    no-undo.
define output parameter p-exclude-obj-list      as character    no-undo.
    define variable v-db-num                as integer       no-undo.
    define variable v-obj-type              as character     no-undo.
    define variable v-obj-code              as integer       no-undo.
    define buffer buf_clients       for ub.clients.
    define buffer buf_temp_obj-list for temp_obj-list.
    define buffer buf_temp_db-num   for temp_db-num.
    define buffer buf_schedule      for ub.schedule.
do
for buf_clients
  , buf_temp_obj-list
  , buf_temp_db-num
  , buf_schedule
on error undo, return error
:
    find first buf_schedule no-lock
         where buf_schedule.cre-db-num  = p-cre-db-num
           and buf_schedule.task-type   = p-task-type
           and buf_schedule.task-num    = p-task-num
    no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Не найдена строка расписания для определения параметров."
            skip return-value
            skip trim( error-status :get-message( 1 ) )
                 trim( error-status :get-message( 2 ) )
                 trim( error-status :get-message( 3 ) )
        view-as alert-box error.
        undo, return error.
    end.
    assign
        p-only-this-db-obj-list = "":U
        p-exclude-obj-list      = "":U
    .
    if buf_schedule.db-num-char <> "*":U
    then do:
        run gbl/prcs-lst.p (
              input buf_schedule.db-num-char
            , input 0
            , input 99999
            , input no
            , input ( buffer buf_temp_db-num :handle )
            , input "db-num-key":U
        ) no-error .
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка разбора списка баз данных."
                skip return-value
                skip trim( error-status :get-message( 1 ) )
                    trim( error-status :get-message( 2 ) )
                    trim( error-status :get-message( 3 ) )
            view-as alert-box error.
            undo, return error.
        end.
    end.
    for each buf_temp_obj-list
    :
        find first buf_clients no-lock
             where buf_clients.obj-type = buf_temp_obj-list.obj-type
               and buf_clients.obj-code = buf_temp_obj-list.obj-code
        .
        if buf_schedule.db-num-char = "*":U
        then do:
            assign
                p-only-this-db-obj-list = p-only-this-db-obj-list
                                        + ( if p-only-this-db-obj-list <> "" then ", " else "" )
                                        + buf_temp_obj-list.obj-type + string( buf_temp_obj-list.obj-code )
            .
        end.
        else do:
            find first buf_temp_db-num
                 where buf_temp_db-num.db-num-key = buf_clients.db-num
            no-error.
            if available buf_temp_db-num
            then do:
                assign
                    p-only-this-db-obj-list = p-only-this-db-obj-list
                                            + ( if p-only-this-db-obj-list <> "" then ", " else "" )
                                            + buf_temp_obj-list.obj-type + string( buf_temp_obj-list.obj-code )
                .
            end.
            else do:
                assign
                    p-exclude-obj-list = p-exclude-obj-list
                                            + ( if p-exclude-obj-list <> "" then ", " else "" )
                                            + buf_temp_obj-list.obj-type + string( buf_temp_obj-list.obj-code )
                .
                delete buf_temp_obj-list.
            end.
        end.
    end.
end.
END PROCEDURE.
