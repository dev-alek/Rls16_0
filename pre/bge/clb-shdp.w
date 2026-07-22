DEFINE TEMP-TABLE temp-schedule-attr NO-UNDO LIKE ub.schedule-attr.
define input PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input PARAMETER p-curr-host-code LIKE ub.sysconf.host-code NO-UNDO.
define input PARAMETER p-mode           AS CHARACTER NO-UNDO.
define input  parameter p-cre-db-num as integer   no-undo .
define input  parameter p-task-type  as character no-undo .
define input  parameter p-task-num   as integer   no-undo .
define input parameter p-action         as character    no-undo.
define output parameter p-cancel        as logical      no-undo.
define output parameter p-params        as character    no-undo.
define output parameter p-object-list        as character    no-undo.
define output parameter p-doc-type-list      as character    no-undo.
define output parameter p-date-list          as character    no-undo.
define output parameter p-hsch-list          as character    no-undo.
define output parameter p-csch-list          as character    no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор параметров для автоматического эксп/имп фин документов в систему клиент-банк.".
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
define   temp-table temp_obj-list no-undo
    field obj-type as character
    field obj-code as integer
    index pi is primary unique obj-type obj-code
.
DEFINE   TEMP-TABLE temp_hfin-schet NO-UNDO LIKE ub.fin-schet
.
DEFINE   TEMP-TABLE temp_cfin-schet NO-UNDO LIKE ub.fin-schet
.
define temp-table temp-bik no-undo
field host-code like ub.sysconf.host-code
field code-bank like ub.fin-bank.code-bank
field bik       like ub.fin-bank.bik
field f_name    as character
field o_name    as character
field d-count    as integer
field adresat as character
index pi is unique primary
host-code
bik
.
procedure init-host-list :
define input parameter p-host-list as character no-undo .
define variable v-counter as integer no-undo .
define buffer buf_temp_obj-list for temp_obj-list.
  do
  on error undo, return error
  :
  for each buf_temp_obj-list
  :
      delete buf_temp_obj-list.
  end.
  do v-counter = 1 to num-entries( p-host-list ) / 2
  :
      create buf_temp_obj-list.
      assign
          buf_temp_obj-list.obj-type = entry( 2 * v-counter - 1,  p-host-list )
          buf_temp_obj-list.obj-code = integer( entry( 2 * v-counter,      p-host-list ) )
      .
  end.
  end.
end procedure.
procedure fill-hfin-schet :
define input parameter p-hfin-schet as character no-undo .
define variable v-counter as integer no-undo .
define buffer buf_temp_hfin-schet for temp_hfin-schet.
  do
  on error undo, return error return-value
  :
      for each buf_temp_hfin-schet
      :
          delete buf_temp_hfin-schet.
      end.
      do v-counter = 1 to num-entries( p-hfin-schet ) / 6
      :
          create buf_temp_hfin-schet.
          assign
          buf_temp_hfin-schet.host-code = integer( entry( 6 * v-counter - 5,      p-hfin-schet ) )
          buf_temp_hfin-schet.r-schet = entry( 6 * v-counter - 4,  p-hfin-schet )
          buf_temp_hfin-schet.cli-type =  entry( 6 * v-counter - 3,      p-hfin-schet )
          buf_temp_hfin-schet.cli-code = integer( entry( 6 * v-counter - 2,      p-hfin-schet ) )
          buf_temp_hfin-schet.code-bank = integer( entry( 6 * v-counter - 1,      p-hfin-schet ) )
          buf_temp_hfin-schet.code-schet = integer( entry( 6 * v-counter,      p-hfin-schet ) )
          .
      end.
  end.
end procedure.
procedure fill-cfin-schet :
define input parameter p-cfin-schet as character no-undo .
define variable v-counter as integer no-undo .
define buffer buf_temp_cfin-schet for temp_cfin-schet.
  do
  on error undo, return error return-value
  :
      for each buf_temp_cfin-schet
      :
          delete buf_temp_cfin-schet.
      end.
      do v-counter = 1 to num-entries( p-cfin-schet ) / 6
      :
          create buf_temp_cfin-schet.
          assign
          buf_temp_cfin-schet.host-code = integer( entry( 6 * v-counter - 5,      p-cfin-schet ) )
          buf_temp_cfin-schet.r-schet = entry( 6 * v-counter - 4,  p-cfin-schet )
          buf_temp_cfin-schet.cli-type =  entry( 6 * v-counter - 3,      p-cfin-schet )
          buf_temp_cfin-schet.cli-code = integer( entry( 6 * v-counter - 2,      p-cfin-schet ) )
          buf_temp_cfin-schet.code-bank = integer( entry( 6 * v-counter - 1,      p-cfin-schet ) )
          buf_temp_cfin-schet.code-schet = integer( entry( 6 * v-counter,      p-cfin-schet ) )
          .
      end.
  end.
end procedure.
define variable v-host-list              as character    no-undo.
define variable v-hsch-list              as character    no-undo.
define variable v-csch-list              as character    no-undo.
define variable v-host-name             as character    no-undo.
dEFINE variable v-param-type            as character    no-undo.
define variable v-today                 as date         no-undo.
define variable v-time                  as integer      no-undo.
define variable v-init-doc-type-list    as character    no-undo.
define variable v-doc-type-list         as character    no-undo.
define variable v-ext-fin-doc-type-list as character extent 2 init
[
    "расходное платежное поручение",             'рпп':U
]                                                           no-undo.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.
DEFINE BUTTON bt-sel-csch
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.6 BY 1.03.
DEFINE BUTTON bt-sel-doc-type
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.6 BY 1.03.
DEFINE BUTTON bt-sel-host
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.6 BY 1.03.
DEFINE BUTTON bt-sel-hsch
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.6 BY 1.03.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK DEFAULT
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE ed-csch AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 50 BY 2.77
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE ED-doc-type AS CHARACTER INITIAL "Все"
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 50 BY 2.77 NO-UNDO.
DEFINE VARIABLE ed-host AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 20.3 BY 2.77
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE ed-hsch AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 50 BY 2.77
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE f-doc-type-label AS CHARACTER FORMAT "X(256)":U INITIAL "Типы документов"
      VIEW-AS TEXT
     SIZE 15.5 BY .77 NO-UNDO.
DEFINE VARIABLE f-t-create-1 AS CHARACTER FORMAT "X(256)":U INITIAL "отсутствующие"
      VIEW-AS TEXT
     SIZE 15.5 BY .77 NO-UNDO.
DEFINE VARIABLE f-t-create-2 AS CHARACTER FORMAT "X(256)":U INITIAL "платежи"
      VIEW-AS TEXT
     SIZE 15.5 BY .77 NO-UNDO.
DEFINE VARIABLE f-t-create-3 AS CHARACTER FORMAT "X(256)":U INITIAL "платежей"
      VIEW-AS TEXT
     SIZE 15.5 BY .77 NO-UNDO.
DEFINE VARIABLE f-t-create-4 AS CHARACTER FORMAT "X(256)":U INITIAL "создавать"
      VIEW-AS TEXT
     SIZE 15.5 BY .77 NO-UNDO.
DEFINE VARIABLE f-t-create-5 AS CHARACTER FORMAT "X(256)":U INITIAL "строки выписки"
      VIEW-AS TEXT
     SIZE 15.5 BY .77 NO-UNDO.
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
     SIZE 21.6 BY .67 NO-UNDO.
DEFINE VARIABLE fi-days-ago AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "Дней назад"
     VIEW-AS FILL-IN
     SIZE 5.4 BY 1 NO-UNDO.
DEFINE VARIABLE fi-days-amount AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "Количество дней"
     VIEW-AS FILL-IN
     SIZE 5.4 BY 1 NO-UNDO.
DEFINE VARIABLE fi-encoding-select AS CHARACTER FORMAT "X(256)":U INITIAL "Выбор кодировки"
      VIEW-AS TEXT
     SIZE 19.5 BY .67 NO-UNDO.
DEFINE VARIABLE fi-format-select AS CHARACTER FORMAT "X(256)":U INITIAL " Выбор формата обмена"
      VIEW-AS TEXT
     SIZE 23.5 BY .67 NO-UNDO.
DEFINE VARIABLE rs-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "все фирмы", 1,
"выбранная фирма", 2
     SIZE 19 BY 2.27 NO-UNDO.
DEFINE VARIABLE RS-action AS CHARACTER INITIAL "exp"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Экспорт", "exp",
"Импорт", "imp"
     SIZE 39.5 BY 1 NO-UNDO.
DEFINE VARIABLE rs-csch AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "все счета контраг.", 1,
"счета выборочно", 2
     SIZE 21 BY 2.27 NO-UNDO.
DEFINE VARIABLE rs-date AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "за прошлые дни", 0,
"по текущую", 1,
"интервал", 2
     SIZE 19.4 BY 3.27 NO-UNDO.
DEFINE VARIABLE RS-encoding AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "DOS", "IBM866",
"Windows", "Windows-1251"
     SIZE 16.5 BY 3.5 NO-UNDO.
DEFINE VARIABLE RS-format AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Item 1", "1"
     SIZE 27.5 BY 3.27 NO-UNDO.
DEFINE VARIABLE rs-hsch AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "все счета фирмы", 1,
"счета выборочно", 2
     SIZE 18 BY 2.27 NO-UNDO.
DEFINE RECTANGLE rct-dates
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 76.5 BY 4.47.
DEFINE RECTANGLE rct-host
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 48.5 BY 3.5.
DEFINE RECTANGLE rct-host-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 76.5 BY 3.5.
DEFINE RECTANGLE rct-host-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 76.5 BY 3.5.
DEFINE VARIABLE T-create AS LOGICAL INITIAL no
     LABEL "Создавать"
     VIEW-AS TOGGLE-BOX
     SIZE 19.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-create-no-th AS LOGICAL INITIAL no
     LABEL "Для отсутствующих"
     VIEW-AS TOGGLE-BOX
     SIZE 19.5 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     RS-action AT ROW 1 COL 28.5 NO-LABEL
     b-help AT ROW 1 COL 71
     RS-encoding AT ROW 2.5 COL 31.5 NO-LABEL
     RS-format AT ROW 2.77 COL 2 NO-LABEL
     ed-host AT ROW 2.77 COL 78 NO-LABEL
     rs-1 AT ROW 3 COL 52 NO-LABEL
     bt-sel-host AT ROW 4.27 COL 72.5
     rs-hsch AT ROW 6.5 COL 2.5 NO-LABEL
     ed-hsch AT ROW 6.5 COL 27.5 NO-LABEL
     T-create AT ROW 7.27 COL 79.5
     bt-sel-hsch AT ROW 7.77 COL 23
     rs-csch AT ROW 10.27 COL 3 NO-LABEL
     ed-csch AT ROW 10.27 COL 28 NO-LABEL
     T-create-no-th AT ROW 10.33 COL 79.5
     bt-sel-csch AT ROW 11.5 COL 23.5
     fi-days-amount AT ROW 14.27 COL 41.8 COLON-ALIGNED
     rs-date AT ROW 14.57 COL 3.5 NO-LABEL
     fi-days-ago AT ROW 15.47 COL 41.8 COLON-ALIGNED
     fi-date-from AT ROW 16.7 COL 30.6 COLON-ALIGNED
     fi-date-to AT ROW 16.77 COL 47.4 COLON-ALIGNED
     ED-doc-type AT ROW 18.27 COL 22 NO-LABEL
     bt-sel-doc-type AT ROW 18.77 COL 18.5
     fi-format-select AT ROW 2 COL 2 NO-LABEL
     fi-encoding-select AT ROW 2 COL 30.5 NO-LABEL
     f-t-create-1 AT ROW 8.27 COL 79.5 NO-LABEL
     f-t-create-2 AT ROW 9 COL 79.5 NO-LABEL
     f-t-create-3 AT ROW 11.33 COL 79.5 NO-LABEL
     f-t-create-4 AT ROW 12.07 COL 79.5 NO-LABEL
     f-t-create-5 AT ROW 13 COL 79.5 NO-LABEL
     fi-dates-title AT ROW 13.5 COL 3 NO-LABEL
     f-doc-type-label AT ROW 18.77 COL 2.5 NO-LABEL
     rct-host AT ROW 2.5 COL 50.5
     rct-host-2 AT ROW 6.27 COL 2
     rct-host-3 AT ROW 10 COL 2
     rct-dates AT ROW 13.7 COL 2
     SPACE(20.50) SKIP(3.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры эксп.-имп. фин документов в систему КЛИЕНТ-БАНК"
         CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       ED-doc-type:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF bt-sel-csch IN FRAME Dialog-Frame
DO:
 define variable v-rid-list as character no-undo.
define variable v-status_ like ub.fin-schet.status_ no-undo init 'тек':U.
DEFINE VARIABLE v-sch-list AS CHARACTER NO-UNDO.
define buffer buf_temp_obj-list for temp_obj-list.
define variable v-host-code like ub.sysconf.host-code no-undo .
    assign
        rs-csch :screen-value  = "2"
    .
    if p-mode = 'shd':U then do:
      find first buf_temp_obj-list no-error .
      if not available buf_temp_obj-list then do:
        message
        "Не выбрана фирма"
        view-as alert-box error .
        return no-apply.
      end.
      assign
      v-host-code = buf_temp_obj-list.obj-code.
    end.
    else do:
      assign
      v-host-code = p-curr-host-code.
    end.
    run ref/finschts.w (
              INPUT parparentproc
              ,INPUT v-host-code
              ,input "b-sel,b-mark":U
              ,input 'фирма':U
              ,input '':U
              ,input 0
              ,input ?
              ,input v-host-code
              ,input 0
              ,input-output v-status_
              ,input-output v-rid-list
) no-error.
    run fill-sch-list in this-procedure ( input v-rid-list, INPUT 'фирма':U, OUTPUT v-sch-list ) no-error .
    if error-status :error
    then do:
        return no-apply.
    end.
    ASSIGN
        ed-csch :screen-value = v-sch-list
        ed-csch
    .
END.
ON CHOOSE OF bt-sel-doc-type IN FRAME Dialog-Frame
DO:
    define variable v-cancel     as logical           no-undo.
    define variable v-oper-num   as integer           no-undo.
    define variable v-doc-type-select as character no-undo .
    assign
    v-doc-type-select = "fin-doc-bank":U
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
                ed-doc-type
            .
        end.
        else do:
            assign
                ed-doc-type :screen-value in frame Dialog-Frame = ''
                ed-doc-type
            .
            do v-oper-num = 1 to 1
            :
                if lookup( v-ext-fin-doc-type-list [v-oper-num * 2], v-init-doc-type-list ) <> 0
                then do:
                    assign
                        ed-doc-type :screen-value in frame Dialog-Frame = ed-doc-type :screen-value in frame Dialog-Frame
                                                    + v-ext-fin-doc-type-list [v-oper-num * 2 - 1] + chr(10)
                        ed-doc-type
                    .
                end.
            end.
        end.
    end.
END.
ON CHOOSE OF bt-sel-host IN FRAME Dialog-Frame
DO:
   define variable v-firm-code like ub.sysconf.host-code no-undo .
   DEFINE VARIABLE v-rec-list AS CHARACTER NO-UNDO.
    assign
        rs-1 :screen-value  = "2"
    .
    define buffer buf_sysconf      for ub.sysconf.
    find first buf_sysconf no-lock
         where buf_sysconf.host-code = p-curr-host-code
    no-error .
    if available buf_sysconf
    then do:
          assign
            v-host-list = string( recid( buf_sysconf ) )
        .
    end.
    run adm/sconfs.w (
          input parparentproc
        , input "b-sel":U
        , input no
        , input p-curr-host-code
        , output v-firm-code
        , input-output v-rec-list
    ) no-error.
    run fill-host-list in this-procedure ( input v-rec-list, OUTPUT v-host-list ) no-error .
    if error-status :error
    then do:
        return no-apply.
    end.
    assign
        ed-host :screen-value = v-host-list
        ed-host
    .
END.
ON CHOOSE OF bt-sel-hsch IN FRAME Dialog-Frame
DO:
 define variable v-rid-list as character no-undo.
define variable v-status_ like ub.fin-schet.status_ no-undo init 'тек':U.
DEFINE VARIABLE v-sch-list AS CHARACTER NO-UNDO.
define variable v-host-code like ub.sysconf.host-code no-undo .
define buffer buf_temp_obj-list for temp_obj-list.
    assign
        rs-hsch :screen-value  = "2"
    .
    if p-mode = 'shd':U then do:
      find first buf_temp_obj-list no-error .
      if not available buf_temp_obj-list then do:
        message
        "Не выбрана фирма"
        view-as alert-box error .
        return no-apply.
      end.
      assign
      v-host-code = buf_temp_obj-list.obj-code.
    end.
    else do:
      assign
      v-host-code = p-curr-host-code.
    end.
        run ref/finschts.w (
                  INPUT parparentproc
                  ,INPUT v-host-code
                  ,input "b-sel,b-mark":U
                  ,input "company-host":U
                  ,input 'орг':U
                  ,input v-host-code
                  ,input ?
                  ,input v-host-code
                  ,input 0
                  ,input-output v-status_
                  ,input-output v-rid-list
    ) no-error.
    run fill-sch-list in this-procedure ( input v-rid-list, INPUT "company-host", OUTPUT v-sch-list ) no-error .
    if error-status :error
    then do:
        return no-apply.
    end.
    ASSIGN
        ed-hsch :screen-value = v-sch-list
        ed-hsch
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
    define variable v-deleted as logical     no-undo.
    DEFINE BUFFER buf_schedule-attr FOR ub.schedule-attr.
    DEFINE BUFFER buf_temp-schedule-attr FOR temp-schedule-attr.
    if p-mode = 'shd':U then
    assign
    rs-action
    rs-1
    .
    IF rs-format:SENSITIVE IN FRAME Dialog-Frame THEN
    ASSIGN
    rs-format
    .
    IF rs-action = 'exp' THEN DO:
        ASSIGN
        t-create
        rs-encoding
        rs-date
        fi-days-amount
        fi-days-ago
        fi-date-from
        fi-date-to
        rs-hsch
        rs-csch
        .
    END.
    IF rs-action = 'imp' THEN DO:
        ASSIGN
        t-create
        t-create-no-th
        rs-encoding
        rs-hsch
        .
    END.
    case rs-1
    :
    when 1
    then do:
        assign
            v-host-list = ""
        .
    end.
    when 2
    then do:
        assign
            v-host-list = ""
        .
        for each temp_obj-list
        :
            assign
                v-host-list = v-host-list
                        + ( if v-host-list = "" then "" else "," ) + temp_obj-list.obj-type
                        + "," + string( temp_obj-list.obj-code )
            .
        end.
    end.
    end case.
    find first temp_obj-list no-error.
    if not available temp_obj-list
    and rs-1 = 2
    then do:
        message
            "Не выбраны фирмы для эксп/имп финдокументов в КЛИЕНТ-БАНК."
        view-as alert-box warning.
        undo, return no-apply.
    end.
    CASE rs-hsch
    :
    when 1
    then do:
        assign
            v-hsch-list = ""
        .
    end.
    when 2
    then do:
        assign
            v-hsch-list = ""
        .
        for each temp_hfin-schet
        :
            assign
                v-hsch-list = v-hsch-list
                        + ( if v-hsch-list = "" then "" else "," )  +  string(temp_hfin-schet.host-code)
                        + "," + temp_hfin-schet.r-schet
                        + "," + string( temp_hfin-schet.cli-type )
                        + "," + string( temp_hfin-schet.cli-code )
                        + "," + string( temp_hfin-schet.code-bank )
                        + "," + string( temp_hfin-schet.code-schet )
            .
        end.
    end.
    end case.
    find first temp_hfin-schet no-error.
    if not available temp_hfin-schet
    and rs-hsch = 2
    then do:
        message
            "Не выбраны счета СВОЕЙ фирмы для эксп/имп финдокументов в КЛИЕНТ-БАНК."
        view-as alert-box warning.
        undo, return no-apply.
    end.
CASE rs-csch
    :
    when 1
    then do:
        assign
            v-csch-list = ""
        .
    end.
    when 2
    then do:
        assign
            v-csch-list = ""
        .
        for each temp_cfin-schet
        :
            assign
                v-csch-list = v-csch-list
                        + ( if v-csch-list = "" then "" else "," ) +  string(temp_cfin-schet.host-code)
                        + "," + temp_cfin-schet.r-schet
                        + "," + string( temp_cfin-schet.cli-type )
                        + "," + string( temp_cfin-schet.cli-code )
                        + "," + string( temp_cfin-schet.code-bank )
                        + "," + string( temp_cfin-schet.code-schet )
            .
        end.
    end.
    end case.
    find first temp_cfin-schet no-error.
    if not available temp_cfin-schet
    and rs-csch = 2
    then do:
        message
            "Не выбраны счета КОНТРАГЕНТОВ для эксп/имп финдокументов в КЛИЕНТ-БАНК."
        view-as alert-box warning.
        undo, return no-apply.
    end.
    CASE rs-date:
      when 0 then do:
      end.
      when 1
      then do:
         if fi-date-from = ? then do:
           message
           "Неверно задана дата начала"
           view-as alert-box error .
           return no-apply.
         end.
      end.
      when 2 then do:
         if fi-date-from > fi-date-to then do:
           message
           "Неверно задан диапазон дат"
           view-as alert-box error .
           return no-apply.
         end.
      end.
    END CASE.
    run attach-attr-to-schedule-line in this-procedure (
          INPUT rs-format
        , INPUT rs-encoding
        , input rs-date
        , input fi-days-amount
        , input fi-days-ago
        , input fi-date-from
        , input fi-date-to
        , input rs-1
        , input v-host-list
        , input v-doc-type-list
        , INPUT rs-action
        , INPUT rs-hsch
        , INPUT v-hsch-list
        , INPUT rs-csch
        , INPUT v-csch-list
        , INPUT t-create
        , input t-create-no-th
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
    run host-select in this-procedure (
        input rs-1
    ) .
    run manage-rs-1 in this-procedure.
END.
ON VALUE-CHANGED OF RS-action IN FRAME Dialog-Frame
DO:
  if rs-action:sensitive in frame Dialog-Frame = yes then
  ASSIGN
  rs-action.
  else do:
    display
    rs-action
    with frame Dialog-Frame .
  end.
  RUN manage-options IN THIS-PROCEDURE.
END.
ON VALUE-CHANGED OF rs-csch IN FRAME Dialog-Frame
DO:
    assign
        rs-csch
    .
    run cschet-select in this-procedure (
        input rs-csch
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
ON VALUE-CHANGED OF RS-encoding IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-encoding.
END.
ON VALUE-CHANGED OF RS-format IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-format.
END.
ON VALUE-CHANGED OF rs-hsch IN FRAME Dialog-Frame
DO:
    assign
        rs-hsch
    .
    run hschet-select in this-procedure (
        input rs-hsch
    ) .
END.
ON VALUE-CHANGED OF T-create IN FRAME Dialog-Frame
DO:
  ASSIGN
  t-create.
  CASE t-create:
  WHEN YES THEN DO:
    ASSIGN
    t-create-no-th = NO.
    DISPLAY
    t-create-no-th
    WITH FRAME Dialog-Frame.
  END.
  WHEN NO THEN DO:
    ASSIGN
    t-create-no-th = YES.
    DISPLAY
    t-create-no-th
    WITH FRAME Dialog-Frame.
  END.
 END CASE.
END.
ON VALUE-CHANGED OF T-create-no-th IN FRAME Dialog-Frame
DO:
  IF INPUT FRAME Dialog-Frame t-create-no-th = YES THEN DO:
     IF t-create = YES THEN DO:
        MESSAGE
        "Включена опция СОЗДАВАТЬ ОТСУТСТВУЮЩИЕ ПЛАТЕЖИ"
        VIEW-AS ALERT-BOX ERROR.
        t-create-no-th = NO.
        DISPLAY t-create-no-th
        WITH FRAME Dialog-Frame.
     END.
  END.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define MENU m-ed-date6
    MENU-ITEM m-ed-date6-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date6-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date6-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date6-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if fi-date-from :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      fi-date-from :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date6 :HANDLE
      fi-date-from :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle6 as handle no-undo .
  assign
    v-label-handle6 = fi-date-from :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle6)
  then do:
    if v-label-handle6 :tooltip = ""
    or v-label-handle6 :tooltip = ?
    then do:
      assign
        v-label-handle6 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date6-1 in menu m-ed-date6 DO:
    apply "ctrl-b":U to fi-date-from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date6-2 in menu m-ed-date6 DO:
    apply "ctrl-d":U to fi-date-from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date6-3 in menu m-ed-date6 DO:
    apply "ctrl-e":U to fi-date-from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date6-4 in menu m-ed-date6 DO:
    apply "ctrl-f":U to fi-date-from in frame Dialog-Frame .
  END.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define MENU m-ed-date8
    MENU-ITEM m-ed-date8-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date8-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date8-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date8-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if fi-date-to :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      fi-date-to :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date8 :HANDLE
      fi-date-to :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle8 as handle no-undo .
  assign
    v-label-handle8 = fi-date-to :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle8)
  then do:
    if v-label-handle8 :tooltip = ""
    or v-label-handle8 :tooltip = ?
    then do:
      assign
        v-label-handle8 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date8-1 in menu m-ed-date8 DO:
    apply "ctrl-b":U to fi-date-to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-2 in menu m-ed-date8 DO:
    apply "ctrl-d":U to fi-date-to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-3 in menu m-ed-date8 DO:
    apply "ctrl-e":U to fi-date-to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-4 in menu m-ed-date8 DO:
    apply "ctrl-f":U to fi-date-to in frame Dialog-Frame .
  END.
run cur-time in this-procedure ( output v-today
                               , output v-time
                               ).
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    if p-mode = 'shd':U then do:
      assign
      frame Dialog-Frame :title = frame Dialog-Frame :title +
                          substitute(". &1: Задача номер &2"
                          , p-task-type
                          , p-task-num )
      .
    end.
    if p-curr-host-code = 0 then do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      assign
      p-curr-host-code = v-cntxt-host-code-obj.
    end.
    run get-host-name in this-procedure ( output v-host-name ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при определении имени фирмы"
          skip "Код фирмы:" p-curr-host-code
          skip "Имя фирмы будет отображаться как '" + 'орг':U + string( p-curr-host-code ) + "'"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box warning.
        assign
            v-host-name = 'орг':U + string( p-curr-host-code )
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
        , output v-host-list
        , output v-init-doc-type-list
        , output rs-format
        , output rs-encoding
        , OUTPUT rs-1
        , output rs-action
        , OUTPUT rs-hsch
        , OUTPUT v-hsch-list
        , OUTPUT rs-csch
        , OUTPUT v-csch-list
        , OUTPUT t-create
        , output t-create-no-th
        ).
    run MYenable.
    run host-select in this-procedure (
        input rs-1
    ).
    run date-select in this-procedure (
        input rs-date
    ).
    RUN init-fields in this-procedure .
    apply "value-changed" to rs-action.
    WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE attach-attr-to-schedule-line :
    define input  parameter p-rs-format          as character no-undo .
    define input  parameter p-rs-encoding        as character no-undo .
    define input  parameter p-rs-date            as integer   no-undo .
    define input  parameter p-days-amount        as integer   no-undo .
    define input  parameter p-days-ago           as integer   no-undo .
    define input  parameter p-date-from          as date      no-undo .
    define input  parameter p-date-to            as date      no-undo .
    define input  parameter p-rs-1               as integer   no-undo .
    define input  parameter p-loc-object-list    as character no-undo .
    define input  parameter p-loc-doc-type-list  as character no-undo .
    define input  parameter p-rs-action          as character no-undo .
    define input  parameter p-rs-hsch            as integer   no-undo .
    define input  parameter p-loc-hsch-list      as character no-undo .
    define input  parameter p-rs-csch            as integer   no-undo .
    define input  parameter p-loc-csch-list      as character no-undo .
    define input  parameter p-create             as logical   no-undo .
    define input  parameter p-create-no-th       as logical   no-undo .
do
on error undo, return error
:
    define variable v-attr-value as character     no-undo.
    define variable v-date-value as character     no-undo.
    define buffer buf_schedule      for ub.schedule.
    define buffer buf_schedule-attr for ub.schedule-attr.
    assign
        v-attr-value =   p-rs-format
                       + chr(44) + p-rs-encoding
                       + chr(44) + string( p-rs-1 )
                       + chr(44) + string( p-curr-host-code )
                       + chr(44) + p-rs-action
                       + chr(44) + string(p-rs-hsch)
                       + chr(44) + string(p-rs-csch)
                       + chr(44) + string(p-create)
                       + chr(44) + string(p-create-no-th)
    .
    assign
        v-date-value = string( p-rs-date )
                        + "," + string( p-days-amount )
                        + "," + string( p-days-ago    )
                        + "," + (if p-date-from = ? then chr(63) else string(p-date-from))
                        + "," + (if p-date-to = ? then chr(63) else string(p-date-to))
    .
    CASE p-mode:
      when 'shd':U then do:
          find first buf_schedule no-lock
               where buf_schedule.cre-db-num = p-cre-db-num
                 and buf_schedule.task-type  = p-task-type
                 and buf_schedule.task-num   = p-task-num
          no-error.
          if not available buf_schedule
          and (  p-task-type   <> 'autocbnk':U
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
            , input p-loc-object-list
        ).
        run schedule-attr-write in this-procedure (
              input p-cre-db-num
            , input p-task-type
            , input p-task-num
            , input 'schedule-doc-type-list':U
            , input p-loc-doc-type-list
        ).
        run schedule-attr-write in this-procedure (
              input p-cre-db-num
            , input p-task-type
            , input p-task-num
            , input 'schedule-filter':U
            , input p-loc-hsch-list
        ).
        run schedule-attr-write in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input 'schedule-filter-2':U
        , input p-loc-csch-list
    ).
    run schedule-attr-write in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input 'schedule-date-list':U
        , input v-date-value
    ).
        for each buf_schedule-attr
        on error undo, return error
        :
            if buf_schedule-attr.cre-db-num <> p-cre-db-num
            or buf_schedule-attr.task-type  <> 'autocbnk':U
            or buf_schedule-attr.task-num   <> -1
            or (
                    buf_schedule-attr.attr-code <> 'schedule-param-list':U
                and buf_schedule-attr.attr-code <> 'schedule-obj-list':U
                and buf_schedule-attr.attr-code <> 'schedule-date-list':U
                and buf_schedule-attr.attr-code <> 'schedule-doc-type-list':U
                and buf_schedule-attr.attr-code <> 'schedule-filter':U
                and buf_schedule-attr.attr-code <> 'schedule-filter-2':U
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
      when 'run':U then do:
        assign
        p-params = v-attr-value
        p-object-list = p-loc-object-list
        p-doc-type-list = p-loc-doc-type-list
        p-hsch-list = p-loc-hsch-list
        p-csch-list = p-loc-csch-list
        p-date-list = v-date-value
        .
      end.
    END CASE.
end.
END PROCEDURE.
PROCEDURE cschet-select :
define input parameter p-rs-csch   as integer      no-undo.
case p-rs-csch
:
    when 1
    then do:
        assign
            ed-csch :screen-value in frame Dialog-frame = "Все счета контрагентов"
            ed-csch
        .
    end.
    when 2
    then do:
        assign
            ed-csch :screen-value = ""
            ed-csch
        .
        for each temp_cfin-schet
        :
            assign
                ed-csch:screen-value = ed-csch :screen-value
                    + ( if ed-csch :screen-value = "" then "" else ", " )
                    + SUBSTITUTE("&1 &2&3 &4/&5",
                           temp_cfin-schet.r-schet
                          ,temp_cfin-schet.cli-type
                          ,temp_cfin-schet.cli-code
                          ,temp_cfin-schet.code-bank
                          ,temp_cfin-schet.code-schet).
                ed-csch
            .
        end.
    end.
end case.
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
            display
            fi-days-ago
            fi-days-amount
            with frame Dialog-Frame .
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
            display
            fi-date-from
            with frame Dialog-Frame .
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
            display
            fi-date-from
            fi-date-to
            with frame Dialog-Frame .
         end.
    end case.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY RS-action RS-encoding RS-format ed-host rs-1 rs-hsch ed-hsch T-create
          rs-csch ed-csch T-create-no-th fi-days-amount rs-date fi-days-ago
          fi-date-from fi-date-to ED-doc-type fi-format-select
          fi-encoding-select f-t-create-1 f-t-create-2 f-t-create-3 f-t-create-4
          f-t-create-5 fi-dates-title f-doc-type-label
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK rct-host rct-host-2 rct-host-3 rct-dates Btn_Cancel RS-action
         b-help RS-encoding RS-format rs-1 bt-sel-host rs-hsch T-create
         bt-sel-hsch rs-csch T-create-no-th bt-sel-csch fi-days-amount rs-date
         fi-days-ago fi-date-from fi-date-to ED-doc-type bt-sel-doc-type
         fi-format-select fi-encoding-select
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE extract-parameter :
do
on error undo, return error
:
end.
END PROCEDURE.
PROCEDURE fill-host-list :
do
on error undo, return error
:
define input parameter p-recid-list as character no-undo.
define output parameter p-host-list as character no-undo.
define variable v-recid-index as integer no-undo.
define variable v-recid          as recid    no-undo.
define buffer buf_sysconf     for ub.sysconf.
for each temp_obj-list:
    delete temp_obj-list.
end.
cre-obj-list:
do v-recid-index = 1 to num-entries( p-recid-list )
:
    find first buf_sysconf
         where recid( buf_sysconf ) = integer( entry( v-recid-index, p-recid-list) )
    no-error.
    if error-status :error
    then do:
        message
        "Не найдена запись sysconf для " p-recid-list
        skip v-recid-index entry( v-recid-index, p-recid-list)
        view-as alert-box.
        next cre-obj-list.
    end.
    create temp_obj-list.
    assign
        temp_obj-list.obj-type = 'орг':U
        temp_obj-list.obj-code = buf_sysconf.host-code
    .
    ASSIGN
    p-host-list = p-host-list + (IF p-host-list = '':U THEN '':U ELSE chr(10)) +
                substitute("&1&2",
                           'орг':U
                           ,buf_sysconf.host-code).
end.
end.
END PROCEDURE.
PROCEDURE fill-sch-list :
do
on error undo, return error
:
define input parameter p-recid-list as character no-undo.
define input parameter p-mode as character no-undo.
define OUTPUT parameter p-schet-list as character no-undo.
define variable v-recid-index as integer no-undo.
define variable v-recid          as recid    no-undo.
define buffer buf_fin-schet     for ub.fin-schet.
CASE p-mode:
    WHEN 'фирма':U THEN DO:
        for each temp_cfin-schet:
            delete temp_cfin-schet.
        end.
    END.
    WHEN "company-host" THEN DO:
        for each temp_hfin-schet:
            delete temp_hfin-schet.
        end.
    END.
END CASE.
cre-schet-list:
do v-recid-index = 1 to num-entries( p-recid-list )
:
    find first buf_fin-schet
         where recid( buf_fin-schet ) = integer( entry( v-recid-index, p-recid-list) )
    no-error.
    if error-status :error
    then do:
        message
        "Не найдена запись fin-schet для " p-recid-list
        skip v-recid-index entry( v-recid-index, p-recid-list)
        view-as alert-box.
        next cre-schet-list.
    end.
    ASSIGN
    p-schet-list = p-schet-list + (IF p-schet-list = '':U THEN '':U ELSE chr(10)) +
                   substitute("&1 &2&3 &4/&5",
                              buf_fin-schet.r-schet
                              ,buf_fin-schet.cli-type
                              ,buf_fin-schet.cli-code
                              ,buf_fin-schet.code-bank
                              ,buf_fin-schet.code-schet).
     CASE p-mode:
         WHEN 'фирма':U THEN DO:
             create temp_cfin-schet.
             BUFFER-COPY buf_fin-schet TO temp_cfin-schet.
         END.
         WHEN "company-host":U THEN DO:
             create temp_hfin-schet.
             BUFFER-COPY buf_fin-schet TO temp_hfin-schet.
         END.
     END CASE.
end.
END.
END PROCEDURE.
PROCEDURE get-host-name :
do
on error undo, return error
:
define output parameter p-host-name as character    no-undo.
define buffer buf_clients   for ub.clients.
    find first buf_clients no-lock
         where buf_clients.obj-type = 'орг':U
           and buf_clients.obj-code = p-curr-host-code
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
PROCEDURE host-select :
do
on error undo, return error
:
define input parameter p-rs-1   as integer      no-undo.
case p-rs-1
:
    when 1
    then do:
        assign
            ed-host :screen-value in frame Dialog-frame = "Все фирмы"
            ed-host
        .
    end.
    when 2
    then do:
        assign
            ed-host :screen-value = ""
            ed-host
        .
        for each temp_obj-list
        :
            assign
                ed-host :screen-value = ed-host :screen-value
                    + ( if ed-host :screen-value = "" then "" else ", " )
                    + temp_obj-list.obj-type + string( temp_obj-list.obj-code )
                ed-host
            .
        end.
    end.
end case.
end.
END PROCEDURE.
PROCEDURE hschet-select :
do
on error undo, return error
:
define input parameter p-rs-hsch   as integer      no-undo.
case p-rs-hsch
:
    when 1
    then do:
        assign
            ed-hsch :screen-value in frame Dialog-frame = "Все счета фирмы"
            ed-hsch
        .
    end.
    when 2
    then do:
        assign
            ed-hsch :screen-value = ""
            ed-hsch
        .
        for each temp_hfin-schet
        :
            assign
                ed-hsch:screen-value = ed-hsch :screen-value
                    + ( if ed-hsch :screen-value = "" then "" else chr(10) )
                    + SUBSTITUTE("&1 &2&3 &4/&5",
                               temp_hfin-schet.r-schet
                              ,temp_hfin-schet.cli-type
                              ,temp_hfin-schet.cli-code
                              ,temp_hfin-schet.code-bank
                              ,temp_hfin-schet.code-schet)
               ed-hsch.
        end.
    end.
end case.
end.
END PROCEDURE.
PROCEDURE init-fields :
do
on error undo, return error
:
    define variable v-oper-num     as integer           no-undo.
    run manage-options          in this-procedure.
    run manage-rs-1  in this-procedure.
    assign
        v-doc-type-list = v-init-doc-type-list
    .
    v-oper-num = 1.
    assign
        ed-doc-type :screen-value in frame Dialog-Frame =    v-ext-fin-doc-type-list [v-oper-num * 2 - 1] + chr(10)
    v-doc-type-list = v-ext-fin-doc-type-list [v-oper-num * 2]
    ed-doc-type
    .
end.
END PROCEDURE.
PROCEDURE init-param-values :
  define input  parameter p-cre-db-num        as integer   no-undo .
  define input  parameter p-task-type         as character no-undo .
  define input  parameter p-task-num          as integer   no-undo .
  define output parameter p-days-amount       as integer   no-undo .
  define output parameter p-rs-date           as integer   no-undo .
  define output parameter p-days-ago          as integer   no-undo .
  define output parameter p-date-from         as date      no-undo .
  define output parameter p-date-to           as date      no-undo .
  define output parameter p-host-list         as character no-undo .
  define output parameter p-loc-doc-type-list as character no-undo .
  define output parameter p-rs-format         as character no-undo .
  define output parameter p-rs-encoding       as character no-undo .
  define output parameter p-rs-1              as integer   no-undo .
  define output parameter p-rs-action         as character no-undo .
  define output parameter p-rs-hsch           as integer   no-undo .
  define output parameter p-hfin-schet        as character no-undo .
  define output parameter p-rs-csch           as integer   no-undo .
  define output parameter p-cfin-schet        as character no-undo .
  define output parameter p-create            as logical   no-undo .
  define output parameter p-create-no-th      as logical   no-undo .
  do
  on error undo, return error
  :
  define variable v-counter       as integer       no-undo.
  define variable v-param-list    as character     no-undo.
  define variable v-date-list     as character no-undo .
  CASE p-mode:
    when 'shd':U then do:
      run schedule-attr-value in this-procedure (
            input p-cre-db-num
          , input p-task-type
          , input p-task-num
          , input 'schedule-obj-list':U
          , output p-host-list
          , output v-param-type
      ) .
      run init-host-list in this-procedure (input p-host-list).
      run schedule-attr-value in this-procedure (
            input p-cre-db-num
          , input p-task-type
          , input p-task-num
          , input 'schedule-param-list':U
          , output v-param-list
          , output v-param-type
      ) .
      run schedule-attr-value in this-procedure (
            input p-cre-db-num
          , input p-task-type
          , input p-task-num
          , input 'schedule-filter':U
          , output p-hfin-schet
          , output v-param-type
      ) .
      run fill-hfin-schet in this-procedure (input p-hfin-schet).
      run schedule-attr-value in this-procedure (
            input p-cre-db-num
          , input p-task-type
          , input p-task-num
          , input 'schedule-filter-2':U
          , output p-cfin-schet
          , output v-param-type
      ) .
      run fill-cfin-schet in this-procedure (input p-cfin-schet).
      run schedule-attr-value in this-procedure (
            input p-cre-db-num
          , input p-task-type
          , input p-task-num
          , input 'schedule-date-list':U
          , output v-date-list
          , output v-param-type
      ) .
      run schedule-attr-value in this-procedure (
            input p-cre-db-num
          , input p-task-type
          , input p-task-num
          , input 'schedule-doc-type-list':U
          , output p-loc-doc-type-list
          , output v-param-type
      ) .
    end.
    when 'run':U then do:
      assign
      v-param-list = STRING('1s':U) + chr(44) +
                     'ibm866':U + chr(44) +
                     string(2) + chr(44) +
                     string(p-curr-host-code) + chr(44) +
                     p-action + chr(44) +
                     string(1) + chr(44) +
                     string(1) + chr(44) +
                     string(no) + chr(44)
     .
    end.
  END CASE.
    if v-param-list = ""
    or p-mode = 'run':U
    then do:
        assign
        p-rs-format             = '1s':U
        p-rs-encoding           = 'ibm866'
        p-rs-1                  = (if p-mode = 'run' then 2 else 1)
        v-host-list             = (if p-mode = 'run'
                                   then  substitute("&1&2"
                                                  ,'орг':U
                                                  ,p-curr-host-code)
                                   else '':U)
        p-rs-action             = p-action
        p-rs-hsch               = 1
        p-rs-csch               = 1
        p-create               = NO
        p-create-no-th         = yes
        p-rs-action            = p-action
        .
       if p-mode = 'run':U then do:
          create temp_obj-list.
          assign
          temp_obj-list.obj-type = 'орг':U
          temp_obj-list.obj-code = p-curr-host-code
          .
          release temp_obj-list.
        end.
    end.
    else do:
        assign
        p-rs-encoding = entry( 2, v-param-list)
        p-rs-1 = integer( entry( 3, v-param-list) )
        p-rs-action =  entry( 5, v-param-list )
        p-rs-hsch = integer( entry( 6, v-param-list ) )
        p-rs-csch = integer( entry( 7, v-param-list ) )
        p-create = logical( entry( 8, v-param-list ) )
        p-create-no-th = (if num-entries(v-param-list) > 8
                          and not p-create
                          then logical( entry( 9, v-param-list ) )
                          else no)
        .
    end.
    if v-date-list = ""
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
            p-rs-date       = integer( entry( 1, v-date-list ) )
            p-days-amount   = integer( entry( 2, v-date-list ) )
            p-days-ago      = integer( entry( 3, v-date-list ) )
            p-date-from     = date( entry( 4, v-date-list ) )
            p-date-to       = date( entry( 5, v-date-list ) )
        .
    end.
end.
END PROCEDURE.
PROCEDURE manage-options :
do
on error undo, return error
:
    assign
    rct-host          :visible in frame Dialog-Frame = no
    rct-host-2        :visible in frame Dialog-Frame = no
    rct-host-3        :visible in frame Dialog-Frame = no
    rs-1              :visible in frame Dialog-Frame = no
    bt-sel-host       :visible in frame Dialog-Frame = no
    ed-host           :visible in frame Dialog-Frame = no
    ed-doc-type       :visible in frame Dialog-Frame = no
    bt-sel-doc-type   :visible in frame Dialog-Frame = no
    rs-hsch           :visible in frame Dialog-Frame = no
    bt-sel-hsch       :visible in frame Dialog-Frame = no
    ed-hsch           :visible in frame Dialog-Frame = no
    rs-csch           :visible in frame Dialog-Frame = no
    bt-sel-csch       :visible in frame Dialog-Frame = no
    ed-csch           :visible in frame Dialog-Frame = no
    rct-dates           :visible in frame Dialog-Frame = no
    fi-dates-title      :visible in frame Dialog-Frame = no
    rs-date             :visible in frame Dialog-Frame = no
    fi-days-amount      :visible in frame Dialog-Frame = no
    fi-days-ago         :visible in frame Dialog-Frame = no
    fi-date-from        :visible in frame Dialog-Frame = no
    fi-date-to          :visible in frame Dialog-Frame = no
    f-doc-type-label    :visible in frame Dialog-Frame = no
    t-create            :visible in frame Dialog-Frame = no
    f-t-create-1        :visible in frame Dialog-Frame = no
    f-t-create-2        :visible in frame Dialog-Frame = no
    t-create-no-th      :visible in frame Dialog-Frame = no
    f-t-create-3        :visible in frame Dialog-Frame = no
    f-t-create-4        :visible in frame Dialog-Frame = no
    f-t-create-5        :visible in frame Dialog-Frame = no
.
if rs-action = "exp" then do:
    assign
    rct-host          :visible in frame Dialog-Frame = yes
    rct-host-2        :visible in frame Dialog-Frame = yes
    rct-host-3        :visible in frame Dialog-Frame = yes
    rs-1              :visible in frame Dialog-Frame = yes
    bt-sel-host       :visible in frame Dialog-Frame = yes
    ed-host           :visible in frame Dialog-Frame = yes
    ed-doc-type       :visible in frame Dialog-Frame = yes
    bt-sel-doc-type   :visible in frame Dialog-Frame = yes
    rs-hsch           :visible in frame Dialog-Frame = YES
    ed-hsch           :visible in frame Dialog-Frame = YES
    rs-csch           :visible in frame Dialog-Frame = YES
    ed-csch           :visible in frame Dialog-Frame = YES
    f-doc-type-label  :visible in frame Dialog-Frame = YES
    rct-dates           :visible in frame Dialog-Frame = yes
    fi-dates-title      :visible in frame Dialog-Frame = yes
    rs-date             :visible in frame Dialog-Frame = yes
    fi-days-amount      :visible in frame Dialog-Frame = yes
    fi-days-ago         :visible in frame Dialog-Frame = yes
    fi-date-from        :visible in frame Dialog-Frame = yes
    fi-date-to          :visible in frame Dialog-Frame = yes
    bt-sel-hsch       :visible in frame Dialog-Frame = yes
    bt-sel-csch       :visible in frame Dialog-Frame = yes
    .
    run host-select in this-procedure (
    input rs-1
     ).
    run hschet-select in this-procedure (
    input rs-hsch
     ).
    run cschet-select in this-procedure (
    input rs-csch
     ).
    run date-select in this-procedure (
        input rs-date
    ).
    RUN manage-rs-1 IN THIS-PROCEDURE.
    enable
    rs-1 when p-mode = 'shd':U
    bt-sel-host when p-mode = 'shd':U
    ed-host     when p-mode = 'shd':U
    ed-doc-type
    ed-hsch
    ed-csch
    rs-date
    with frame Dialog-Frame .
    DISPLAY
    rs-encoding
    rs-1
    f-doc-type-label
    fi-dates-title
    ed-host     when p-mode = 'shd':U
    ed-doc-type
    ed-hsch
    ed-csch
    rs-date
    with frame Dialog-Frame .
end.
if rs-action = "imp" then do:
    ASSIGN
    rct-host          :visible in frame Dialog-Frame = yes
    rct-host-2        :visible in frame Dialog-Frame = yes
    bt-sel-host       :visible in frame Dialog-Frame = yes
    rs-hsch           :visible in frame Dialog-Frame = YES
    ed-hsch           :visible in frame Dialog-Frame = YES
    rs-1              :visible in frame Dialog-Frame = yes
    ed-host           :visible in frame Dialog-Frame = yes
    t-create            :visible in frame Dialog-Frame = YES
    f-t-create-1        :visible in frame Dialog-Frame = YES
    f-t-create-2        :visible in frame Dialog-Frame = YES
    t-create-no-th      :visible in frame Dialog-Frame = YES
    f-t-create-3        :visible in frame Dialog-Frame = YES
    f-t-create-4        :visible in frame Dialog-Frame = YES
    f-t-create-5        :visible in frame Dialog-Frame = YES
    bt-sel-hsch       :visible in frame Dialog-Frame = yes
    .
    run host-select in this-procedure (
    input rs-1
     ).
    run hschet-select in this-procedure (
    input rs-hsch
     ).
    RUN manage-rs-1 IN THIS-PROCEDURE.
    enable
    rs-1 when p-mode = 'shd':U
    bt-sel-host when p-mode = 'shd':U
    ed-host     when p-mode = 'shd':U
    ed-hsch
    t-create
    t-create-no-th
    with frame Dialog-Frame .
    if p-mode = 'run' then do:
      display
      rs-1
      with frame Dialog-Frame .
    end.
    DISPLAY
    f-t-create-1
    f-t-create-2
    f-t-create-3
    f-t-create-4
    f-t-create-5
    rs-1
    t-create
    t-create-no-th
    ed-host     when p-mode = 'shd':U
    ed-hsch
    rs-encoding
    with frame Dialog-Frame .
END.
end.
END PROCEDURE.
PROCEDURE manage-rs-1 :
do
on error undo, return error
:
 if rs-1 = 1
    then do:
        assign
        rs-hsch = 1
        rs-hsch :sensitive in frame Dialog-Frame = NO
        bt-sel-hsch:sensitive in frame Dialog-Frame = NO
        .
        display
        rs-hsch
        with frame Dialog-Frame .
        run hschet-select in this-procedure (
            input rs-hsch
        ) .
        if rs-action = 'exp' then do:
          assign
          rs-csch = 1
          rs-csch :sensitive in frame Dialog-Frame = NO
          bt-sel-csch:sensitive in frame Dialog-Frame = NO
          .
          display
          rs-csch
          with frame Dialog-Frame .
          run cschet-select in this-procedure (
              input rs-csch
          ) .
        end.
    end.
    else do:
        assign
        rs-hsch :sensitive in frame Dialog-Frame = YES
        bt-sel-hsch:sensitive in frame Dialog-Frame = YES
        .
        display
        rs-hsch
        with frame Dialog-Frame .
        run hschet-select in this-procedure (
            input rs-hsch
        ) .
        if rs-action = 'exp' then do:
          assign
          rs-csch :sensitive in frame Dialog-Frame = YES
          bt-sel-csch:sensitive in frame Dialog-Frame = YES
          .
          display
          rs-csch
          with frame Dialog-Frame .
          run cschet-select in this-procedure (
              input rs-csch
          ) .
        end.
    end.
    DISPLAY
    rs-hsch
    rs-csch when rs-action = 'exp'
    WITH FRAME Dialog-Frame.
  end.
END PROCEDURE.
PROCEDURE MyEnable :
dEFINE variable ii                      as INTEGER       no-undo.
dEFINE VARIABLE v-dop AS CHARACTER NO-UNDO.
DO ii = 1 TO NUM-ENTRIES('1s':U):
    ASSIGN
    v-dop = v-dop + (IF v-dop = '':U THEN '':U ELSE chr(44)) +
            entry (lookup (ENTRY(ii, '1s':U), '1s':U) + 1, ',' + '1С':U) + chr(44) + ENTRY(ii, '1s':U)  .
END.
rs-format:RADIO-BUTTONS IN FRAME Dialog-Frame = v-dop.
if p-mode = 'shd':U then do:
  if rs-action = '':U
  or rs-action = ?
  then rs-action = 'exp'.
  DISPLAY
  rs-action
  fi-format-select
  fi-encoding-select
  WITH FRAME Dialog-Frame.
end.
ENABLE
Btn_OK
Btn_Cancel
b-help
rs-action when p-mode = 'shd':U
fi-days-amount
rs-date
fi-days-ago
fi-date-from
fi-date-to
rs-encoding
rs-format
WITH FRAME Dialog-Frame.
ASSIGN
rs-format = '1s':U.
DISABLE
rs-format
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
END PROCEDURE.
