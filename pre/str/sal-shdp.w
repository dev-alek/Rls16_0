DEFINE TEMP-TABLE temp-schedule-attr NO-UNDO LIKE ub.schedule-attr.
define input  parameter parparentproc as widget-handle   no-undo.
define input  parameter p-cre-db-num  as integer   no-undo .
define input  parameter p-task-type   as character no-undo .
define input  parameter p-task-num    as integer   no-undo .
define output parameter p-cancel      as logical      no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор параметров для автоматическиго обработки документов продаж по расписанию.".
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
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fltfield-clear :
  define output parameter loc-fld as character no-undo.
  define output parameter loc-lab as character no-undo .
  define output parameter loc-spr as character no-undo .
  define output parameter loc-dim as character no-undo .
  assign
    loc-fld = ""
    loc-lab = ""
    loc-spr = ""
    loc-dim = "0"
  .
end procedure .
procedure fltfield-add :
  define input        parameter par-fld as character no-undo.
  define input        parameter par-lab as character no-undo .
  define input        parameter par-spr as character no-undo .
  define input-output parameter loc-fld as character no-undo.
  define input-output parameter loc-lab as character no-undo .
  define input-output parameter loc-spr as character no-undo .
  define input-output parameter loc-dim as character no-undo .
  do
  on error undo, return error
  :
    assign
    loc-fld = if loc-dim = '0'
              then par-fld
              else (loc-fld + chr(44) + par-fld)
    loc-lab = if loc-dim = '0'
              then par-lab
              else (loc-lab + chr(44) + par-lab)
    loc-spr = if loc-dim = '0'
              then par-spr
              else (loc-spr + chr(44) + par-spr)
    loc-dim = (if num-entries(loc-dim) > 1 then (entry(1, loc-dim) + chr(44)) else "") +
              string(integer(if num-entries(loc-dim) > 1
                            then entry(2, loc-dim)
                            else entry(1, loc-dim)
                            ) + 1)
    no-error
    .
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-host-code             as integer      no-undo.
define variable v-host-name             as character    no-undo.
dEFINE variable v-param-type            as character    no-undo.
define variable filter-point0 as character no-undo init "Обработка продаж" .
define variable filter-point as character no-undo init "Обработка продаж" .
DEFINE VARIABLE kl AS INTEGER INITIAL 0.
define variable MethodReturn AS LOGICAL.
define variable id as recid no-undo .
define variable IDENT AS RECID no-undo .
define temp-table temp_obj-list no-undo
    field obj-type as character
    field obj-code as integer
    index pi is primary unique obj-type obj-code
.
DEFINE TEMP-TABLE temp-inkas NO-UNDO
    FIELD inkas-code LIKE ub.inkas.inkas-code
    FIELD shift-date LIKE ub.inkas.shift-date
    FIELD shift-num  LIKE ub.inkas.shift-num
    FIELD num-flt    AS INTEGER
    INDEX pi IS PRIMARY UNIQUE inkas-code
.
FUNCTION octal-to-char RETURNS CHARACTER
( p-string as character )  FORWARD.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.
DEFINE BUTTON bt-sel-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.
DEFINE BUTTON btn-add
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Добавить новый фильтр".
DEFINE BUTTON btn-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить ранее существующий фильтр".
DEFINE BUTTON btn-update
     LABEL "&Фильтр по чекам":L
     SIZE 20 BY 1 TOOLTIP "Изменить установки фильтра по чекам".
DEFINE BUTTON btn-update-main
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить установки шаблона".
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK DEFAULT
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE ED-FILTER AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 39 BY 3.83 NO-UNDO.
DEFINE VARIABLE ed-object AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 40.75 BY 3.38
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE F-shift-date AS CHARACTER FORMAT "X(20)":U
     LABEL "Дата смены(учета)"
     VIEW-AS FILL-IN
     SIZE 21 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE F-shift-name AS CHARACTER FORMAT "X(2)":U
     LABEL "№ смены (может игнор.)"
     VIEW-AS FILL-IN
     SIZE 3 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE F-shift-num AS CHARACTER FORMAT "X(2)":U
     LABEL "Порядок смен(может игнор.)"
     VIEW-AS FILL-IN
     SIZE 3 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE rs-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "все объекты БД", 1,
"все объекты БД по фирме", 2,
"объекты выборочно", 3
     SIZE 28 BY 3.25 NO-UNDO.
DEFINE VARIABLE rs-end AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "0", 0,
"100", 100,
"200", 200,
"300", 300,
"400", 400
     SIZE 38 BY 5.5 NO-UNDO.
DEFINE VARIABLE rs-start AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "0", 0,
"100", 100,
"200", 200,
"300", 300,
"400", 400
     SIZE 38 BY 5.5 NO-UNDO.
DEFINE RECTANGLE rct-obj
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 79 BY 4.25.
DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97 BY 7.
DEFINE VARIABLE T-finalize-100 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .75 NO-UNDO.
DEFINE VARIABLE T-finalize-200 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .75 NO-UNDO.
DEFINE QUERY br-template FOR
      temp-schedule-attr SCROLLING.
DEFINE BROWSE br-template
  QUERY br-template NO-LOCK DISPLAY
      entry(2, temp-schedule-attr.attr-code, chr(4)) COLUMN-LABEL "№" FORMAT "X(2)":U
      entry(3, temp-schedule-attr.attr-value, chr(4)) COLUMN-LABEL "Название шаблона" FORMAT "X(50)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 56 BY 6.25
         TITLE "Список шаблонов" ROW-HEIGHT-CHARS .67.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 71
     rs-1 AT ROW 3 COL 3.5 NO-LABEL
     ed-object AT ROW 3 COL 38 NO-LABEL
     bt-sel-obj AT ROW 5.25 COL 33
     rs-start AT ROW 7.75 COL 3 NO-LABEL
     rs-end AT ROW 7.75 COL 42 NO-LABEL
     T-finalize-100 AT ROW 9.25 COL 81.5
     T-finalize-200 AT ROW 10.25 COL 81.5
     F-shift-date AT ROW 13.25 COL 75.5 COLON-ALIGNED
     btn-add AT ROW 13.75 COL 2
     btn-del AT ROW 13.75 COL 12
     btn-update-main AT ROW 13.75 COL 22
     btn-update AT ROW 13.75 COL 32
     F-shift-name AT ROW 14.5 COL 89 COLON-ALIGNED
     br-template AT ROW 15 COL 1.5
     F-shift-num AT ROW 15.5 COL 89 COLON-ALIGNED
     ED-FILTER AT ROW 17.5 COL 59 NO-LABEL
     "Начальная стадия обработки" VIEW-AS TEXT
          SIZE 37 BY 1 AT ROW 6.75 COL 3
          FGCOLOR 4
     "Дополнительный фильтр по чекам" VIEW-AS TEXT
          SIZE 39 BY .67 AT ROW 16.75 COL 59
          BGCOLOR 1 FGCOLOR 15
     "Пометить как заверш." VIEW-AS TEXT
          SIZE 20.5 BY 1 AT ROW 6.75 COL 78.5
          FGCOLOR 4
     "Конечная стадия обработки" VIEW-AS TEXT
          SIZE 33 BY 1 AT ROW 6.75 COL 41.5
          FGCOLOR 4
     rct-obj AT ROW 2.25 COL 2
     RECT-6 AT ROW 6.5 COL 2
     SPACE(0.00) SKIP(7.83)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры обработки документов продаж по расписанию"
         CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       ED-FILTER:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON VALUE-CHANGED OF br-template IN FRAME Dialog-Frame
DO:
  assign
  f-shift-DATE:screen-value = ""
  f-shift-num:screen-value = ""
  f-shift-name:screen-value = ""
  ED-FILTER:screen-value = ""
  .
  IF AVAILABLE(temp-schedule-attr) THEN DO:
    RUN proc-value-changed IN THIS-PROCEDURE NO-ERROR.
  END.
END.
ON CHOOSE OF bt-sel-obj IN FRAME Dialog-Frame
DO:
    define variable v-exclude-obj-list     as character     no-undo.
    assign
        rs-1 :screen-value  = "3"
    .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_clear in this-procedure  .
    for each temp_obj-list:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_append in this-procedure
  (input  temp_obj-list.obj-type
  ,input  temp_obj-list.obj-code
  )  .
    end.
    define variable v-user-select as logical   no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return NO-APPLY .
    end.
    define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
    define variable v-skip-store as integer   no-undo .
    assign
      v-skip-store = 0
    .
    for each temp_obj-list :
      delete temp_obj-list.
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return no-apply
    :
      if buf_userobjs_temp-user-obj.obj-type = 'скл':U
      then do:
        assign
          v-skip-store = v-skip-store + 1
        .
      end.
      find first temp_obj-list no-lock where
                temp_obj-list.obj-type  = buf_userobjs_temp-user-obj.obj-type
            and temp_obj-list.obj-code  = buf_userobjs_temp-user-obj.obj-code no-error .
      if not available temp_obj-list then do:
        create temp_obj-list.
        assign
          temp_obj-list.obj-type = buf_userobjs_temp-user-obj.obj-type
          temp_obj-list.obj-code = buf_userobjs_temp-user-obj.obj-code
        .
        release temp_obj-list.
      end.
    end.
    if v-skip-store <> 0
    then do:
      message
        substitute("Среди выбранных были объекты типа &1", 'скл':U) skip
        "Они были исключены из списка" skip
        substitute("Всего было исключено &1 объектов", v-skip-store) skip
        view-as alert-box information .
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
ON CHOOSE OF btn-add IN FRAME Dialog-Frame
DO:
  define buffer buf_temp-schedule-attr for temp-schedule-attr.
  RUN proc-b-add IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  APPLY "VALUE-CHANGED" TO br-template.
  apply "entry" to br-template.
  APPLY "CHOOSE" TO btn-update-main.
END.
ON CHOOSE OF btn-del IN FRAME Dialog-Frame
do:
IF NOT available temp-schedule-attr THEN RETURN NO-APPLY.
RUN proc-b-del IN THIS-PROCEDURE NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF btn-update IN FRAME Dialog-Frame
DO:
 IF NOT AVAILABLE temp-schedule-attr THEN RETURN NO-APPLY.
 RUN proc-filter IN THIS-PROCEDURE NO-ERROR.
 IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF btn-update-main IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-name AS CHARACTER NO-UNDO.
define variable v-str as character no-undo .
define variable v-str-rus as character no-undo .
define variable v-str-int as character no-undo .
define variable v-str-rus-int as character no-undo .
define variable v-str-int-shift-name as character no-undo .
define variable v-str-rus-int-shift-name as character no-undo .
define variable v-flt-rec as recid no-undo .
IF NOT AVAILABLE temp-schedule-attr THEN RETURN NO-APPLY.
ASSIGN
v-flt-rec = recid(temp-schedule-attr)
v-name = ENTRY(3, temp-schedule-attr.attr-VALUE, chr(4))
v-str = entry(1, ENTRY(1, temp-schedule-attr.attr-VALUE, chr(4)))
v-str-rus = entry(1, ENTRY(2, temp-schedule-attr.attr-VALUE, chr(4)))
v-str-int = entry(2, ENTRY(1, temp-schedule-attr.attr-VALUE, chr(4)))
v-str-rus-int = entry(2, ENTRY(2, temp-schedule-attr.attr-VALUE, chr(4)))
.
if num-entries(ENTRY(1, temp-schedule-attr.attr-VALUE, chr(4))) > 2 then
assign
v-str-int-shift-name = entry(3, ENTRY(1, temp-schedule-attr.attr-VALUE, chr(4)))
v-str-rus-int-shift-name = entry(3, ENTRY(2, temp-schedule-attr.attr-VALUE, chr(4)))
.
  run str/asltmpl0.w ( parparentproc
                 ,INPUT-OUTPUT v-name
                 ,INPUT-OUTPUT v-str
                 ,INPUT-OUTPUT v-str-rus
                 ,INPUT-OUTPUT v-str-int
                 ,INPUT-OUTPUT v-str-rus-int
                 ,INPUT-OUTPUT v-str-rus-int-shift-name
                 ,INPUT-OUTPUT v-str-rus-int-shift-name
                 ) No-error.
  IF NOT ERROR-STATUS:error
  and v-name > ''
  THEN DO:
   RUN temp-schedule-attr-write  IN THIS-PROCEDURE(
                                             input p-cre-db-num
                                            ,input p-task-type
                                            ,input p-task-num
                                            ,input temp-schedule-attr.attr-code
                                            ,input (v-str + chr(44) +
                                                    v-str-int + chr(44) +
                                                    v-str-int-shift-name +
                                                    chr(4) +
                                                   v-str-rus + chr(44) +
                                                   v-str-rus-int + chr(44) +
                                                   v-str-rus-int-shift-name +
                                                    chr(4) + v-name)).
     OPEN QUERY br-template FOR EACH temp-schedule-attr       WHERE temp-schedule-attr.cre-db-num = p-cre-db-num  AND temp-schedule-attr.task-type = p-task-type  AND temp-schedule-attr.task-num = p-task-num  AND temp-schedule-attr.attr-code BEGINS ('schedule-date-list':U + chr(4)) NO-LOCK.
      reposition br-template to recid v-flt-rec no-error.
     APPLY "VALUE-CHANGED" TO br-template.
     apply "entry" to br-template.
 END.
 if v-name = '' then do:
   apply "CHOOSE" to btn-del.
 end.
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
    ASSIGN
        rs-1
        rs-start
        rs-end
        t-finalize-100
        t-finalize-200
    .
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
            "Не выбраны объекты для обработкаи документов продаж."
        view-as alert-box warning.
        undo, return no-apply.
    end.
    run attach-attr-to-schedule-line in this-procedure (
          input rs-1
        , input v-obj-list
        , INPUT rs-start
        , INPUT rs-end
        , INPUT t-finalize-100
        , INPUT t-finalize-200
    ).
     if rs-start = 0 then do:
      find first buf_temp-schedule-attr NO-LOCK WHERE
                buf_temp-schedule-attr.cre-db-num = p-cre-db-num
             AND buf_temp-schedule-attr.task-type = p-task-type
             AND buf_temp-schedule-attr.task-num = p-task-num
             AND buf_temp-schedule-attr.attr-code BEGINS ('schedule-date-list':U + chr(4))  no-error.
        if not available buf_temp-schedule-attr then do:
          message
          "Не определено ни одного шаблона для создания документов продаж" skip
          "Расписание не может быть сохранено"
          view-as alert-box .
          return no-apply.
        end.
        RUN save-table IN THIS-PROCEDURE.
      end.
      else DO:
       RUN save-table IN THIS-PROCEDURE.
    END.
    APPLY "GO" TO FRAME Dialog-Frame.
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
ON VALUE-CHANGED OF rs-end IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE ii AS INTEGER NO-UNDO.
  DEFINE VARIABLE v-label AS character NO-UNDO.
  DEFINE VARIABLE v-value AS integer NO-UNDO.
  ASSIGN
  rs-end.
  IF NOT (rs-start <= 100 AND rs-end >= 100) THEN DO:
   ASSIGN
   t-finalize-100 = NO
   .
   DISPLAY
   t-finalize-100
   WITH FRAME Dialog-Frame.
   DISPLAY
   t-finalize-100
   WITH FRAME Dialog-Frame.
  END.
  IF NOT (rs-start <= 200 AND rs-end >= 200) THEN DO:
   ASSIGN
   t-finalize-200 = NO
   .
   DISPLAY
   t-finalize-200
   WITH FRAME Dialog-Frame.
   DISPLAY
   t-finalize-200
   WITH FRAME Dialog-Frame.
  END.
_ii:
DO ii = 1 TO NUM-ENTRIES("0,100,200,300,400"):
   ASSIGN
   v-label = trim(ENTRY(ii, "Создавать продажи по шаблонам,                            Закачивать чеки в продажу,                            Резервировать товары продажи,                            Закрывать документ продажи на факт,                            Удалять пустые (без чеков) продажи"))
   v-value = integer(ENTRY(ii, "0,100,200,300,400"))
   .
   IF v-value < rs-start THEN DO:
      NEXT _ii.
   END.
   IF v-value > rs-end THEN DO:
       leave _ii.
   END.
   IF v-value >= rs-start
   AND v-value <= rs-end  THEN DO:
       CASE v-value:
           WHEN 100 THEN DO:
               ENABLE
               t-finalize-100
               WITH FRAME Dialog-Frame.
           END.
              WHEN 200 THEN DO:
               ENABLE
               t-finalize-200
               WITH FRAME Dialog-Frame.
           END.
       END CASE.
   END.
END.
END.
ON VALUE-CHANGED OF rs-start IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-start.
  RUN proc-start IN THIS-PROCEDURE (rs-start) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON VALUE-CHANGED OF T-finalize-100 IN FRAME Dialog-Frame
DO:
  ASSIGN
  t-finalize-100.
END.
ON VALUE-CHANGED OF T-finalize-200 IN FRAME Dialog-Frame
DO:
    ASSIGN
  t-finalize-200.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse br-template :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    frame Dialog-Frame :title = frame Dialog-Frame :title +
                        substitute(". &1: Задача номер &2"
                        , p-task-type
                        , p-task-num )
    .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при определении кода фирмы текущего объекта"
          skip "Тип объекта:" v-cntxt-obj-type
          skip "Код объекта:" v-cntxt-obj-code
          skip "Обработка документов продаж невозможна"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error.
    end.
    run get-host-name in this-procedure ( output v-host-name ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при определении имени фирмы"
          skip "Код фирмы:" v-host-code
          skip "Имя фирмы будет отображаться как '" + 'орг':U + string( v-host-code ) + "'"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box warning.
        assign
            v-host-name = 'орг':U + string( v-host-code )
        .
    end.
    run init-param-values in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , output v-obj-list
        , output rs-1
        , OUTPUT rs-start
        , OUTPUT rs-end
        , OUTPUT t-finalize-100
        , OUTPUT t-finalize-200
    ).
    RUN fill-table IN THIS-PROCEDURE.
    run MYenable.
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
    define input parameter p-rs-1               as integer      no-undo.
    define input parameter p-object-list        as character    no-undo.
    define input parameter p-rs-start           as integer      no-undo.
    define input parameter p-rs-end             as integer      no-undo.
    define input parameter p-finalize-100       as logical      no-undo.
    define input parameter p-finalize-200       as logical      no-undo.
    define variable v-attr-value as character     no-undo.
    define buffer buf_schedule      for ub.schedule.
    define buffer buf_schedule-attr for ub.schedule-attr.
    find first buf_schedule no-lock
         where buf_schedule.cre-db-num = p-cre-db-num
           and buf_schedule.task-type  = p-task-type
           and buf_schedule.task-num   = p-task-num
    no-error.
    if not available buf_schedule
    and (  p-task-type   <> 'autosale':U
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
                       + "," + string( v-cntxt-host-code-obj )
                       + "," + string( p-rs-start )
                       + "," + string( p-rs-end )
                       + "," + string( p-finalize-100 )
                       + "," + string( p-finalize-200 )
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
    for each buf_schedule-attr
    on error undo, return error
    :
        if buf_schedule-attr.task-type  <> 'autosale':U
        or buf_schedule-attr.cre-db-num <> p-cre-db-num
        or buf_schedule-attr.task-num   <> -1
        or (
                buf_schedule-attr.attr-code <> 'schedule-param-list':U
            and buf_schedule-attr.attr-code <> 'schedule-obj-list':U
            and buf_schedule-attr.attr-code <> 'schedule-date-list':U
            and buf_schedule-attr.attr-code <> 'schedule-filter':U
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
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY rs-1 ed-object rs-start rs-end T-finalize-100 T-finalize-200
          F-shift-date F-shift-name F-shift-num ED-FILTER
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel b-help rct-obj RECT-6 rs-1 bt-sel-obj rs-start
         rs-end T-finalize-100 T-finalize-200 btn-add btn-del btn-update-main
         btn-update br-template ED-FILTER
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-template FOR EACH temp-schedule-attr       WHERE temp-schedule-attr.cre-db-num = p-cre-db-num  AND temp-schedule-attr.task-type = p-task-type  AND temp-schedule-attr.task-num = p-task-num  AND temp-schedule-attr.attr-code BEGINS ('schedule-date-list':U + chr(4)) NO-LOCK.
END PROCEDURE.
PROCEDURE extract-parameter :
do
on error undo, return error
:
end.
END PROCEDURE.
PROCEDURE fill-table :
DEFINE BUFFER buf_schedule-attr FOR ub.schedule-attr.
DEFINE BUFFER buf_temp-schedule-attr FOR temp-schedule-attr.
FOR EACH buf_temp-schedule-attr:
    DELETE buf_temp-schedule-attr.
END.
FOR EACH buf_schedule-attr WHERE
        buf_schedule-attr.cre-db-num = p-cre-db-num
    AND buf_schedule-attr.task-type = p-task-type
    AND buf_schedule-attr.task-num = p-task-num:
  IF buf_schedule-attr.attr-code BEGINS ('schedule-date-list':U + chr(4))
  or buf_schedule-attr.attr-code BEGINS ('schedule-filter':U  + chr(4)) THEN DO:
    CREATE buf_temp-schedule-attr.
    BUFFER-COPY buf_schedule-attr
    TO
    buf_temp-schedule-attr.
  END.
END.
END PROCEDURE.
PROCEDURE filter-get :
DEFINE INPUT PARAMETER p-where-ysl AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-where-ysl-rus AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER p-where-phrase AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER p-where-phrase-rus AS CHARACTER NO-UNDO.
define variable  ind as integer no-undo.
define variable  v-new-where-phrase as character no-undo .
define variable  v-sub-phrase as character no-undo .
assign
p-where-phrase     = ""
p-where-phrase-rus = ""
.
if num-entries(p-where-ysl) > 0 then do:
  assign
  p-where-phrase = p-where-phrase
                  + ' and ('
  .
  do ind = 1 to num-entries(p-where-ysl):
    assign
    p-where-phrase = p-where-phrase
                  + " " + (if ind = 1 then left-trim(left-trim(entry(ind, p-where-ysl)), 'and':U)
                           else entry(ind, p-where-ysl))
    .
  end.
  assign
  p-where-phrase = p-where-phrase
                  + ')'
  .
end.
if num-entries(p-where-phrase, "^") > 1 then do:
  assign
  v-new-where-phrase = entry(1, p-where-phrase, "^")
  .
  do ind = 2 to num-entries(p-where-phrase, "^")
  :
    assign
    v-sub-phrase = entry(ind, p-where-phrase, "^")
    .
    if octal-to-char(substring(v-sub-phrase, 1, 3)) <> ? then do:
      assign
      v-new-where-phrase = v-new-where-phrase
                          + octal-to-char(substring(v-sub-phrase, 1, 3))
                          + substring(v-sub-phrase, 4)
      .
    end.
    else do:
      assign
      v-new-where-phrase = v-new-where-phrase
                          + "^"
                          + v-sub-phrase
      .
    end.
  end.
  assign
  p-where-phrase = v-new-where-phrase
  .
end.
assign
p-where-phrase-rus = p-where-ysl-rus
.
END PROCEDURE.
PROCEDURE get-host-name :
do
on error undo, return error
:
define output parameter p-host-name as character    no-undo.
define buffer buf_clients   for ub.clients.
    find first buf_clients no-lock
         where buf_clients.obj-type = 'орг':U
           and buf_clients.obj-code = v-host-code
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
    run manage-options          in this-procedure.
end.
END PROCEDURE.
PROCEDURE init-param-values :
do
on error undo, return error
:
define input parameter p-cre-db-num             as integer      no-undo .
define input parameter p-task-type              as character    no-undo.
define input parameter p-task-num               as integer      no-undo.
define output parameter p-obj-list              as character    no-undo.
define output parameter p-rs-1                  as integer      no-undo.
define output parameter p-rs-start              as integer      no-undo.
define output parameter p-rs-end                as integer      no-undo.
define output parameter p-finalize-100          as LOGICAL      no-undo.
define output parameter p-finalize-200          as LOGICAL      no-undo.
    define variable v-counter       as integer       no-undo.
    define variable v-param-list    as character     no-undo.
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
            p-rs-1                  = 1
            p-rs-start             = 0
            p-rs-end               = 300
            t-finalize-100         = NO
            t-finalize-200         = NO
        .
    end.
    else do:
        assign
            p-rs-1 = integer( entry( 1, v-param-list ) )
            p-rs-start = integer( entry( 3, v-param-list ) )
            p-rs-end = integer( entry( 4, v-param-list ) )
            p-finalize-100 = LOGICAL (entry( 5, v-param-list ) )
            p-finalize-200 = LOGICAL (entry( 6, v-param-list ) )
        .
    end.
end.
END PROCEDURE.
PROCEDURE manage-options :
do
on error undo, return error
:
assign
    rct-obj             :visible in frame Dialog-Frame = yes
    rs-1                :visible in frame Dialog-Frame = yes
    bt-sel-obj          :visible in frame Dialog-Frame = yes
    ed-object           :visible in frame Dialog-Frame = yes
.
run object-select in this-procedure (
    input rs-1
).
end.
END PROCEDURE.
PROCEDURE MyEnable :
dEFINE variable ii                      as INTEGER       no-undo.
DO ii =  1 TO NUM-ENTRIES("0,100,200,300,400"):
    ASSIGN
    rs-start:RADIO-BUTTONS IN FRAME Dialog-Frame =
    (IF ii = 1
    THEN (trim(ENTRY(ii, "Создавать продажи по шаблонам,                            Закачивать чеки в продажу,                            Резервировать товары продажи,                            Закрывать документ продажи на факт,                            Удалять пустые (без чеков) продажи")) + chr(44) + ENTRY(ii, "0,100,200,300,400"))
    ELSE (rs-start:RADIO-BUTTONS IN FRAME Dialog-Frame + chr(44) +
         (trim(ENTRY(ii, "Создавать продажи по шаблонам,                            Закачивать чеки в продажу,                            Резервировать товары продажи,                            Закрывать документ продажи на факт,                            Удалять пустые (без чеков) продажи")) + chr(44) + ENTRY(ii, "0,100,200,300,400"))
         )
    ).
END.
ASSIGN
rs-end:RADIO-BUTTONS IN FRAME Dialog-Frame = rs-start:RADIO-BUTTONS IN FRAME Dialog-Frame
.
ASSIGN
filter-point = filter-point + chr(32) + STRING(p-task-num)
.
DISPLAY
rs-1
ed-object
rs-start
rs-end
t-finalize-100
t-finalize-200
WITH FRAME Dialog-Frame.
ENABLE
rct-obj
RECT-6
Btn_OK
Btn_Cancel
b-help
rs-1
bt-sel-obj
rs-start
rs-end
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
APPLY "VALUE-CHANGED" TO rs-start IN FRAME Dialog-Frame.
OPEN QUERY br-template FOR EACH temp-schedule-attr       WHERE temp-schedule-attr.cre-db-num = p-cre-db-num  AND temp-schedule-attr.task-type = p-task-type  AND temp-schedule-attr.task-num = p-task-num  AND temp-schedule-attr.attr-code BEGINS ('schedule-date-list':U + chr(4)) NO-LOCK.
APPLY "VALUE-CHANGED" TO br-template IN FRAME Dialog-Frame.
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
            ed-object :screen-value in frame Dialog-frame = "Все объекты БД"
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
PROCEDURE proc-b-add :
define variable v-flt-rec as recid  no-undo .
DEFINE BUFFER buf_temp-schedule-attr FOR temp-schedule-attr.
FIND LAST buf_temp-schedule-attr NO-LOCK WHERE
        buf_temp-schedule-attr.cre-db-num = p-cre-db-num
    AND buf_temp-schedule-attr.task-type = p-task-type
    AND buf_temp-schedule-attr.task-num = p-task-num
    AND buf_temp-schedule-attr.attr-code BEGINS ('schedule-date-list':U + chr(4)) NO-ERROR.
  IF NOT AVAILABLE buf_temp-schedule-attr THEN Kl = 1.
  ELSE kl = integer(ENTRY(2, buf_temp-schedule-attr.attr-code, chr(4))) + 1.
  RUN temp-schedule-attr-write  IN THIS-PROCEDURE(
                                             input p-cre-db-num
                                            ,input p-task-type
                                            ,input p-task-num
                                            ,input ('schedule-date-list':U + chr(4) + STRING(kl))
                                            ,input ("(TODAY - 1),0" + chr(4) +
                                                   "(TODAY - 1),0" + chr(4))
                                            ).
  FIND first buf_temp-schedule-attr NO-LOCK WHERE
          buf_temp-schedule-attr.cre-db-num = p-cre-db-num
      AND buf_temp-schedule-attr.task-type = p-task-type
      AND buf_temp-schedule-attr.task-num = p-task-num
      AND buf_temp-schedule-attr.attr-code = ('schedule-date-list':U + chr(4) + STRING(kl)) .
  v-flt-rec = RECID(buf_temp-schedule-attr).
  OPEN QUERY br-template FOR EACH temp-schedule-attr       WHERE temp-schedule-attr.cre-db-num = p-cre-db-num  AND temp-schedule-attr.task-type = p-task-type  AND temp-schedule-attr.task-num = p-task-num  AND temp-schedule-attr.attr-code BEGINS ('schedule-date-list':U + chr(4)) NO-LOCK.
  REPOSITION br-template TO RECID v-flt-rec no-error.
END PROCEDURE.
PROCEDURE proc-b-del :
DEFINE VARIABLE v-deleted AS LOGICAL NO-UNDO.
define variable v-flt-rec as recid no-undo .
do on stop  undo, return:
 f-shift-DATE = "".
 f-shift-name = "".
 f-shift-num = "".
 ED-FILTER = "".
 v-flt-rec = recid(temp-schedule-attr).
 kl = INTEGER(ENTRY(2, temp-schedule-attr.attr-code, chr(4))).
 RUN temp-schedule-attr-delete IN THIS-PROCEDURE (
                                                 input p-cre-db-num
                                                ,input p-task-type
                                                ,input p-task-num
                                                ,input 'schedule-date-list':U + chr(4) + string(Kl)
                                                ,output v-deleted       ) NO-ERROR.
 IF ERROR-STATUS:ERROR or NOT v-deleted THEN UNDO, RETURN error.
 RUN temp-schedule-attr-delete IN THIS-PROCEDURE (
                                                 input p-cre-db-num
                                                ,input p-task-type
                                                ,input p-task-num
                                                ,input 'schedule-filter':U + chr(4) + string(Kl)
                                                ,output v-deleted       ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN UNDO, RETURN error.
 OPEN QUERY br-template FOR EACH temp-schedule-attr       WHERE temp-schedule-attr.cre-db-num = p-cre-db-num  AND temp-schedule-attr.task-type = p-task-type  AND temp-schedule-attr.task-num = p-task-num  AND temp-schedule-attr.attr-code BEGINS ('schedule-date-list':U + chr(4)) NO-LOCK.
 REPOSITION br-template TO RECID v-flt-rec no-error.
 APPLY "VALUE-CHANGED" TO br-template IN FRAME Dialog-Frame.
 apply "entry" to br-template.
end.
END PROCEDURE.
PROCEDURE proc-b-sch :
END PROCEDURE.
PROCEDURE proc-b-template :
assign
  tbl = 'chk-doc'
  join-tbl = 'X_chk-doc'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('doc-code', 'Номер в базе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-time', '', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-type', 'Тип чека', 'receipt-code',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('office', 'Т или у', 'gds-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-date', 'Дата смены(учета)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', 'Порядок смен', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-name', '№ смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-num', 'Номер по кассе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-desk', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cashier', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sales-man', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-doc', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sub-discnt', 'Списания', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('netto', 'Нетто сумма (выручка)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('d-card', 'N дис.карты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
END PROCEDURE.
PROCEDURE proc-filter :
define variable v-rid as recid no-undo .
define variable v-naim like ubflt.filter.naim no-undo .
define variable v-where-ysl as character no-undo .
define variable v-where-ysl-rus as character no-undo .
define variable where-phrase as character no-undo .
define variable where-phrase-rus as character no-undo .
define variable v-fields-sort as character no-undo .
define variable v-fields-sort-rus as character no-undo .
define variable p-lst-cend        as character no-undo .
define variable v-doc-rec        as  recid no-undo .
define buffer buf_temp-schedule-attr for temp-schedule-attr.
FIND FIRST buf_temp-schedule-attr NO-LOCK WHERE
          buf_temp-schedule-attr.cre-db-num = p-cre-db-num
    AND   buf_temp-schedule-attr.task-type  = p-task-type
    and   buf_temp-schedule-attr.task-num = p-task-num
    and buf_temp-schedule-attr.attr-code = 'schedule-filter':U + chr(4) +
                                      string(integer(entry(2, temp-schedule-attr.attr-code, chr(4))))   no-error.
if available buf_temp-schedule-attr then do:
  assign
  v-where-ysl = entry(1, buf_temp-schedule-attr.attr-value, chr(4))
  v-where-ysl-rus = entry(2, buf_temp-schedule-attr.attr-value, chr(4))
  v-naim          = entry(3, temp-schedule-attr.attr-value, chr(4))
  v-doc-rec       = recid(temp-schedule-attr)
  .
end.
else do:
end.
v-naim = entry(3, temp-schedule-attr.attr-value, chr(4)).
  Kl = 0.
  run gbl/updf.w  (
                input parparentproc
              , input "Обработка продаж"
              , input-output v-naim
              , input no
              , input no
              , input no
              , input no
              , input Tbl
              , input join-tbl
              , input Fld
              , input Lab
              , input Spr
              , input Dim
              , input-output v-where-ysl
              , input-output v-where-ysl-rus
              , input-output v-fields-sort
              , input-output v-fields-sort-rus
              , input-output p-lst-cend
              , input Kl
              , output v-rID).
  IF v-rid = ? THEN ID = IDENT.
  else do:
      run filter-get in this-procedure (
                                          input  v-where-ysl
                                         ,input  v-where-ysl-rus
                                         ,output where-phrase
                                         ,output where-phrase-rus
                                       ).
    if not available buf_temp-schedule-attr then do:
      create buf_temp-schedule-attr.
      buffer-copy temp-schedule-attr
      except attr-code attr-value
      to buf_temp-schedule-attr
      assign
      buf_temp-schedule-attr.attr-code = 'schedule-filter':U + chr(4) +
                                      string(integer(entry(2, temp-schedule-attr.attr-code, chr(4))))
      .
    end.
    assign
      buf_temp-schedule-attr.attr-value = where-phrase + chr(4) +
                                     where-phrase-rus
      .
  end.
  RUN MYenable.
  run object-select in this-procedure (
        input rs-1
    ).
  REPOSITION br-template TO RECID v-doc-rec no-error.
  APPLY "VALUE-CHANGED" TO br-template in frame Dialog-Frame.
  apply "entry" to br-template.
END PROCEDURE.
PROCEDURE proc-start :
DEFINE INPUT PARAMETER p-start AS INTEGER NO-UNDO.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-label AS character NO-UNDO.
DEFINE VARIABLE v-value AS INTEGER NO-UNDO.
DO ii = 1 TO NUM-ENTRIES("0,100,200,300,400"):
    ASSIGN
    v-label = trim(ENTRY(ii, "Создавать продажи по шаблонам,                            Закачивать чеки в продажу,                            Резервировать товары продажи,                            Закрывать документ продажи на факт,                            Удалять пустые (без чеков) продажи"))
    v-value = integer(ENTRY(ii, "0,100,200,300,400"))
    .
   rs-end:enable(v-label) IN FRAME Dialog-Frame.
END.
DO ii = 1 TO NUM-ENTRIES("0,100,200,300,400"):
    ASSIGN
    v-label = trim(ENTRY(ii, "Создавать продажи по шаблонам,                            Закачивать чеки в продажу,                            Резервировать товары продажи,                            Закрывать документ продажи на факт,                            Удалять пустые (без чеков) продажи"))
    v-value = integer(ENTRY(ii, "0,100,200,300,400"))
    .
    IF v-value < p-start  THEN DO:
       rs-end:disable(v-label) IN FRAME Dialog-Frame.
    END.
END.
IF p-start = 0 THEN dO:
    ENABLE
    br-template
    btn-add
    btn-del
    btn-update-main
    btn-update
    WITH FRAME Dialog-Frame.
    RUN proc-b-template IN THIS-PROCEDURE NO-ERROR.
END.
ELSE DO:
   if p-start > 100 then do:
    disable
    t-finalize-100
    with frame Dialog-Frame .
   end.
   else do:
    enable
    t-finalize-100
    with frame Dialog-Frame .
   end.
   if p-start > 200 then do:
    disable
    t-finalize-200
    with frame Dialog-Frame .
   end.
   else do:
    enable
    t-finalize-200
    with frame Dialog-Frame .
   end.
   disable
   br-template
   btn-add
   btn-del
   btn-update-main
   btn-update
WITH FRAME Dialog-Frame.
END.
APPLY "VALUE-CHANGED" to rs-end.
END PROCEDURE.
PROCEDURE proc-value-changed :
DEFINE VARIABLE ii as integer no-undo.
DEFINE VARIABLE v-str as character no-undo.
DEFINE BUFFER buf_temp-schedule-attr FOR temp-schedule-attr.
Kl = integer(entry(2, temp-schedule-attr.attr-code, chr(4))).
assign
  f-shift-date :screen-value IN FRAME Dialog-Frame = ""
  f-shift-num :screen-value IN FRAME Dialog-Frame = ""
  f-shift-name :screen-value IN FRAME Dialog-Frame = ""
  ED-FILTER:screen-value = "".
assign
ED-FILTER.
ASSIGN
f-shift-date = ENTRY(1, (entry(2, temp-schedule-attr.attr-value, chr(4))))
f-shift-num = ENTRY(2, (entry(2, temp-schedule-attr.attr-value, chr(4)))).
if num-entries(entry(2, temp-schedule-attr.attr-value, chr(4))) > 2 then do:
  f-shift-name = ENTRY(3, (entry(2, temp-schedule-attr.attr-value, chr(4)))).
end.
FIND FIRST buf_temp-schedule-attr NO-LOCK WHERE
        buf_temp-schedule-attr.cre-db-num = p-cre-db-num
  AND   buf_temp-schedule-attr.task-type = p-task-type
  AND   buf_temp-schedule-attr.task-num = p-task-num
  AND   buf_temp-schedule-attr.attr-code = ('schedule-filter':U + chr(4) + STRING(kl)) NO-ERROR.
IF AVAILABLE buf_temp-schedule-attr THEN DO:
  ASSIGN
  v-str = entry(2, buf_temp-schedule-attr.attr-value, chr(4)).
  DO ii = 1 TO NUM-ENTRIES(v-str):
      MethodReturn = ED-FILTER:insert-string(entry(ii, v-str) + chr(10)).
      assign ED-FILTER.
  END.
END.
IDENT = RECID(temp-schedule-attr).
DISPLAY
f-shift-date
f-shift-num
f-shift-name
ED-FILTER
WITH FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE save-table :
DEFINE VARIABLE v-deleted AS LOGICAL NO-UNDO.
DEFINE BUFFER buf_temp-schedule-attr FOR temp-schedule-attr.
DEFINE BUFFER buf_schedule-attr FOR ub.schedule-attr.
do ON ERROR UNDO, RETURN ERROR RETURN-VALUE:
FOR EACH buf_temp-schedule-attr :
    RUN  schedule-attr-write  IN THIS-PROCEDURE(
                                                     input buf_temp-schedule-attr.cre-db-num
                                                    ,input buf_temp-schedule-attr.task-type
                                                    ,input buf_temp-schedule-attr.task-num
                                                    ,input buf_temp-schedule-attr.attr-code
                                                    ,input buf_temp-schedule-attr.attr-value).
END.
FOR EACH buf_schedule-attr NO-LOCK where
        buf_schedule-attr.task-type = p-task-type
    and buf_schedule-attr.cre-db-num = p-cre-db-num
    and buf_schedule-attr.task-num = p-task-num:
  IF buf_schedule-attr.attr-code BEGINS ('schedule-date-list':U + chr(4))
  or buf_schedule-attr.attr-code BEGINS ('schedule-filter':U  + chr(4)) THEN DO:
    FIND FIRST buf_temp-schedule-attr NO-LOCK WHERE
              buf_temp-schedule-attr.cre-db-num = buf_schedule-attr.cre-db-num
        and   buf_temp-schedule-attr.task-type = buf_schedule-attr.task-type
        and   buf_temp-schedule-attr.task-num = buf_schedule-attr.task-num
         and   buf_temp-schedule-attr.attr-code = buf_schedule-attr.ATTR-code NO-ERROR.
    IF NOT AVAILABLE buf_temp-schedule-attr  THEN DO:
        RUN  schedule-attr-delete  IN THIS-PROCEDURE(
                                                         input buf_schedule-attr.cre-db-num
                                                        ,input buf_schedule-attr.task-type
                                                        ,input buf_schedule-attr.task-num
                                                        ,input buf_schedule-attr.attr-code
                                                        ,output v-deleted).
       IF NOT v-deleted THEN UNDO, RETURN ERROR.
    END.
  end.
END.
END.
END PROCEDURE.
PROCEDURE select-objects-only-this-db :
do
on error undo, return error
:
define output parameter p-only-this-db-obj-list as character    no-undo.
define output parameter p-exclude-obj-list      as character    no-undo.
  define variable v-db-num                as integer       no-undo.
  define variable v-obj-type              as character     no-undo.
  define variable v-obj-code              as integer       no-undo.
  define buffer buf_clients       for ub.clients.
  define buffer buf_temp_obj-list for temp_obj-list.
  define buffer buf_schedule for ub.schedule.
  assign
      p-only-this-db-obj-list = ""
      p-exclude-obj-list      = ""
  .
  if p-task-num > 0 then do:
    find first buf_schedule no-lock where
              buf_schedule.cre-db-num = p-cre-db-num
          and buf_schedule.task-type = p-task-type
          and buf_schedule.task-num = p-task-num no-error.
    if not available buf_schedule then do:
       undo, return error .
    end.
    assign
    v-db-num = ( if buf_schedule.db-num-char = "*" then -10 else integer( buf_schedule.db-num-char ) )
    .
  end.
  else do:
    v-db-num = v-cntxt-db-num.
  end.
    for each buf_temp_obj-list:
        find first buf_clients no-lock
                where buf_clients.obj-type = buf_temp_obj-list.obj-type
                and buf_clients.obj-code = buf_temp_obj-list.obj-code
        .
        if v-db-num = -10
        or buf_clients.db-num = v-db-num
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
END PROCEDURE.
PROCEDURE temp-schedule-attr-delete :
do
on error undo, return error
:
define input parameter p-cre-db-num    as integer    no-undo .
define input parameter p-task-type     as character  no-undo.
define input parameter p-task-num      as integer    no-undo.
define input parameter p-code          as character  no-undo.
define output parameter p-deleted      as logical    no-undo.
    define buffer buf_temp-schedule-attr for temp-schedule-attr .
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
    find first buf_temp-schedule-attr exclusive-lock
         where buf_temp-schedule-attr.cre-db-num = p-cre-db-num
           and buf_temp-schedule-attr.task-type  = p-task-type
           and buf_temp-schedule-attr.task-num   = p-task-num
           and buf_temp-schedule-attr.attr-code  = p-code
    no-error.
    if not available buf_temp-schedule-attr
    then do:
        assign
            p-deleted = no
        .
    end.
    else do:
        delete buf_temp-schedule-attr.
        assign
            p-deleted = yes
        .
    end.
end.
END PROCEDURE.
PROCEDURE temp-schedule-attr-write :
do
on error undo, return error
:
define input parameter p-cre-db-num as integer   no-undo .
define input parameter p-task-type  as character no-undo.
define input parameter p-task-num   as integer   no-undo.
define input parameter p-code       as character no-undo.
define input parameter p-value      as character no-undo.
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    define buffer buf_temp-schedule-attr for temp-schedule-attr .
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
    find first buf_temp-schedule-attr exclusive-lock
         where buf_temp-schedule-attr.cre-db-num = p-cre-db-num
           and buf_temp-schedule-attr.task-type  = p-task-type
           and buf_temp-schedule-attr.task-num   = p-task-num
           and buf_temp-schedule-attr.attr-code  = p-code
    no-error.
    if not available buf_temp-schedule-attr
    then do:
        create buf_temp-schedule-attr.
        assign
                buf_temp-schedule-attr.cre-db-num = p-cre-db-num
                buf_temp-schedule-attr.task-type  = p-task-type
                buf_temp-schedule-attr.task-num   = p-task-num
                buf_temp-schedule-attr.attr-code  = p-code
                buf_temp-schedule-attr.attr-value = p-value
        .
    end.
    else do:
        assign
            buf_temp-schedule-attr.attr-value = p-value
        .
    end.
end.
END PROCEDURE.
FUNCTION octal-to-char RETURNS CHARACTER
( p-string as character ) :
  def var v-asc     as integer no-undo .
  def var v-new-asc as integer no-undo .
  def var ind       as integer no-undo .
  if length(p-string) <> 3 then do:
    return ? .
  end.
  assign
    v-asc = 0
  .
  do ind = 1 to length(p-string)
  :
    assign
      v-new-asc = asc(substring(p-string, ind, 1)) - asc('0')
    .
    if v-new-asc < 0 or v-new-asc >= 8 then do:
      return ? .
    end.
    assign
      v-asc = v-asc * 8 + v-new-asc
    .
  end.
  return chr(v-asc) .
end function .
