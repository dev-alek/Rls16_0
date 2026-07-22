define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Автоматические задания".
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
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function get-str-type returns character (input p-task-type as character ).
  define variable v-str as character no-undo .
  case p-task-type :
    when 'autonws':U then do:
      assign
        v-str = "связи с БД"
      .
    end.
    when 'autoarh':U then do:
      assign
        v-str = "расчета архивов по БД"
      .
    end.
    when 'autoexp':U then do:
      assign
        v-str = "экспорта по БД"
      .
    end.
    when 'autooxml':U then do:
      assign
        v-str = "OpenXML по БД"
      .
    end.
    when 'autogcd':U then do:
      assign
        v-str = "приема информации с касс по БД"
      .
    end.
    when 'autosale':U then do:
      assign
        v-str = "работы с документами продажи по БД"
      .
    end.
    when 'autosuz':U then do:
      assign
        v-str = "запуска отчетов по БД"
      .
    end.
    when 'autocbnk':U then do:
      assign
        v-str = "эксп/имп в КЛИЕНТ-БАНК"
      .
    end.
    when 'autofree':U then do:
      assign
        v-str = "выполнение произ.заданий"
      .
    end.
    when 'mercury':U then do:
      assign
        v-str = "обмена с ФГИС Меркурий по БД"
      .
    end.
    when 'hddtest':U then do:
      assign
        v-str = "мониторинга HDD по БД"
      .
    end.
    when 'is_motp':U then do:
      assign
        v-str = "обмена с ИС МОТП по БД"
      .
    end.
    when 'is_diadoc':U then do:
      assign
        v-str = "обмена с ИС Диадок по БД"
      .
    end.
    when 'is_diadoc':U then do:
      assign
        v-str = "выгрузки в ИС Президентский мониторинг по БД"
      .
    end.
    otherwise do:
      assign
        v-str = "экспорта по БД"
      .
    end.
  end.
  return v-str.
end function.
procedure push-abtpr :
  define input parameter parparentproc as handle    no-undo .
  define input parameter p-db-num      as integer   no-undo .
  define input parameter p-task-type   as character no-undo .
  define input parameter p-start-type  as character no-undo .
  define input parameter p-date        as date      no-undo .
  define input parameter p-time        as integer   no-undo .
  do
  on error undo, return error
  :
    define buffer buf_BatchProcess for ub.BatchProcess .
    define buffer buf_sys-ctrl     for ub.sys-ctrl .
    define variable v-curr-date as date      no-undo .
    define variable v-curr-time as integer   no-undo .
    define variable v-str       as character no-undo .
    define variable v-user-id   as character no-undo .
    run cur-time in this-procedure
      ( output v-curr-date
       ,output v-curr-time
      ) no-error.
    if error-status :error then do:
      return error substitute( "&1. Ошибка при определении текущей даты!", vss-include-info1 ).
    end.
    if p-date = ? then do:
      assign
        p-date = v-curr-date
      .
    end.
    if p-time = ? then do:
      assign
        p-time = v-curr-time
      .
    end.
    assign
      v-str = get-str-type( p-task-type )
    .
    if v-str = ? then do:
      return error substitute( "&1. НЕТ ОБРАБОТКИ АТРИБУТА &2!", vss-include-info1, p-task-type ).
    end.
    run get-userid in parparentproc
      ( output v-user-id
      ).
    find first buf_sys-ctrl no-lock .
    find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Status   = 'N':U
        and buf_BatchProcess.BP_Type     = p-task-type
        and buf_BatchProcess.CharKey_One = string( p-db-num )
        and buf_BatchProcess.CharKey_Two = "auto":U
      no-error
    .
    if available buf_BatchProcess
      and ( buf_BatchProcess.BP_ExecSysDate < v-curr-date
            or (buf_BatchProcess.BP_ExecSysDate = v-curr-date
                and buf_BatchProcess.BP_ExecSysTimeInt < v-curr-time
                )
          )
    then do:
      return error substitute( "Автоматический режим &1 для БД &2 не запущен или в данный момент идет обработка!"
                              ,v-str ,p-db-num
                            ).
    end.
    find first buf_BatchProcess exclusive-lock
      where buf_BatchProcess.BP_Status   = 'N':U
        and buf_BatchProcess.BP_Type     = p-task-type
        and buf_BatchProcess.CharKey_One = string( p-db-num )
        and buf_BatchProcess.CharKey_Two = p-start-type
      no-error
    .
    if not available buf_BatchProcess then do:
      create buf_BatchProcess.
      assign
        buf_BatchProcess.BatchProcess# = next-value (s-btpr, ub)
        buf_BatchProcess.BP_Status     = 'N':U
        buf_BatchProcess.BP_Type       = p-task-type
        buf_BatchProcess.CharKey_One   = string( p-db-num )
        buf_BatchProcess.CharKey_Two   = p-start-type
      .
    end.
    assign
      buf_BatchProcess.CharKey_Three     = string( buf_sys-ctrl.db-num ) + chr(3) + p-task-type + chr(3) + "-1":U
      buf_BatchProcess.User_ID           = v-user-id
      buf_BatchProcess.Key#_One          = (if p-start-type = "manual":U then 1 else 0)
      buf_BatchProcess.BP_SysDate        = v-curr-date
      buf_BatchProcess.BP_SysTimeInt     = v-curr-time
      buf_BatchProcess.BP_SysTime        = string(v-curr-time, 'HH:MM:SS':U)
      buf_BatchProcess.BP_ExecSysDate    = p-date
      buf_BatchProcess.BP_ExecSysTimeInt = p-time
      buf_BatchProcess.BP_ExecSysTime    = string(p-time, 'HH:MM:SS':U)
    .
  end.
  return.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE TEMP-TABLE temp-autotask NO-UNDO
FIELD db-num like ub.db.db-num
FIELD task-type AS CHARACTER
FIELD task-name AS CHARACTER
FIELD task-date AS DATE
FIELD task-time AS INTEGER
FIELD date-time as character
FIELD overtime AS LOGICAL
FIELD corr as character
INDEX pi IS UNIQUE PRIMARY
db-num
task-type
.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define buffer buf_db for ub.db .
define variable log-exit   as logical   no-undo .
define variable v-par-val  as character no-undo .
define variable v-par-type as character no-undo .
define variable par-is-bge as logical   no-undo .
define variable par-is-edi as character no-undo .
define variable par-type   as character no-undo .
define variable is-edi as logical   no-undo .
define variable line-row   as rowid     no-undo .
define variable v-c-date as date      no-undo .
define variable v-c-time as integer   no-undo .
DEFINE VARIABLE v-start AS LOGICAL NO-UNDO INIT YES.
DEFINE BUFFER buf_temp-autotask FOR temp-autotask.
DEFINE BUTTON b-do-now DEFAULT
     LABEL "_ В&ыполнить"
     SIZE 12 BY 1 TOOLTIP "Выполнить задание без учета расписания".
DEFINE BUTTON b-exit AUTO-END-KEY DEFAULT
     LABEL "Вы&ход"
     SIZE 10 BY 1 TOOLTIP "Выход"
     BGCOLOR 8 .
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1 TOOLTIP "Помощь"
     BGCOLOR 8 .
DEFINE BUTTON b-not-send DEFAULT
     LABEL "Новости: Нет &подтверждений"
     SIZE 28 BY 1 TOOLTIP "Просмотр неотправленной и неподтвержденний информации".
DEFINE BUTTON i-exit
     IMAGE-UP FILE "cmp/i-run.bmp":U
     IMAGE-DOWN FILE "cmp/i-run.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/i-rund.bmp":U
     LABEL ""
     SIZE 2.5 BY .75.
DEFINE QUERY BR-autotask FOR
      temp-autotask SCROLLING.
DEFINE QUERY db-list FOR
      buf_db SCROLLING.
DEFINE BROWSE BR-autotask
  QUERY BR-autotask DISPLAY
      temp-autotask.task-name FORMAT "X(18)" COLUMN-LABEL "Тип задания"
temp-autotask.date-time FORMAT "X(16)" COLUMN-LABEL "Очередной сеанс"
temp-autotask.overtime FORMAT "#/" COLUMN-LABEL "Не вып"
temp-autotask.corr FORMAT "X(3)" NO-LABEL
    WITH NO-ROW-MARKERS SEPARATORS SIZE 52 BY 21.13 FIT-LAST-COLUMN.
DEFINE BROWSE db-list
  QUERY db-list DISPLAY
      buf_db.db-num
buf_db.db-name
    WITH NO-ROW-MARKERS SEPARATORS SIZE 46 BY 21.13.
DEFINE FRAME autopush
     b-exit AT ROW 1 COL 1
     b-not-send AT ROW 1 COL 15
     b-do-now AT ROW 1 COL 47
     b-help AT ROW 1 COL 89
     i-exit AT ROW 1.13 COL 47.13 WIDGET-ID 4
     db-list AT ROW 2 COL 1
     BR-autotask AT ROW 2 COL 47
     SPACE(0.09) SKIP(0.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Автоматические задания"
         CANCEL-BUTTON b-exit.
ASSIGN
       FRAME autopush:SCROLLABLE       = FALSE
       FRAME autopush:HIDDEN           = TRUE.
ASSIGN
       BR-autotask:HIDDEN  IN FRAME autopush                = TRUE.
ASSIGN
       db-list:HIDDEN  IN FRAME autopush                = TRUE.
ON WINDOW-CLOSE OF FRAME autopush
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-do-now IN FRAME autopush
DO:
  DEFINE BUFFER buf_sys-ctrl FOR ub.sys-ctrl.
  if not available buf_db then do:
    message "Не выбрана база данных"
      view-as alert-box error.
    return no-apply.
  end.
  if not available temp-autotask then do:
    message "Не выбрано автоматическое задание"
      view-as alert-box error.
    return no-apply.
  end.
  IF temp-autotask.task-type = 'autonws':U  THEN DO:
      find first buf_sys-ctrl no-lock.
      if buf_sys-ctrl.db-num <> 0
        and buf_db.db-num <> 0
      then do:
        message "Обмен новостями возможен только с БД 0 !"
          view-as alert-box error.
        return no-apply.
      end.
      if buf_sys-ctrl.db-num = buf_db.db-num then do:
        message "Обмен новостями с текущей БД невозможен!"
          view-as alert-box error.
        return no-apply.
      end.
  END.
  run write-new-bp in this-procedure
    ( input temp-autotask.task-type
     ,input buf_db.db-num
    ) no-error.
  if error-status :error then do:
    return no-apply.
  end.
END.
ON CHOOSE OF b-exit IN FRAME autopush
DO:
  assign
    log-exit = true
  .
END.
ON CHOOSE OF b-not-send IN FRAME autopush
DO:
  IF NOT AVAILABLE buf_db THEN DO:
    message "Не выбрана база данных"
    view-as alert-box error.
    return no-apply.
  END.
  run nws/v-route.w
    ( input parparentproc
    , input buf_db.db-num
    ) .
END.
ON ROW-DISPLAY OF BR-autotask IN FRAME autopush
DO:
  IF AVAIL temp-autotask THEN DO:
    RUN set-row-color.
  END.
END.
ON VALUE-CHANGED OF db-list IN FRAME autopush
DO:
  RUN fill-autotask IN THIS-PROCEDURE ( input buf_db.db-num).
  OPEN QUERY br-autotask FOR EACH temp-autotask NO-LOCK WHERE
                                  temp-autotask.db-num = buf_db.db-num.
  reposition BR-autotask to rowid line-row no-error .
END.
ON VALUE-CHANGED OF br-autotask IN FRAME autopush
DO:
  if available temp-autotask
  then
  line-row = rowid(temp-autotask) .
END.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame autopush
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
on choose of b-help in frame autopush
do:
  apply "help":u to frame autopush .
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame autopush:width - 0.3
                fh            = frame autopush:first-child
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame autopush :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame autopush :height-chars)
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
    if frame autopush :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame autopush :height-chars)
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
            frame autopush :height = v-frame-height
          .
          if frame autopush :scrollable = true
          then do:
            assign
              frame autopush :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame autopush :scrollable = true
          then do:
            assign
              frame autopush :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame autopush :height = v-frame-height
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
      v-frame-height = frame autopush :height
      v-frame-virtual-height = frame autopush :virtual-height
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
      v-field-group-handle = frame autopush :first-child
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
    do with frame autopush
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame autopush :scrollable = true
      then do:
        assign
          frame autopush :virtual-height = frame autopush :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame autopush :height = frame autopush :height + p-change-value
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
        frame autopush :height = frame autopush :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame autopush :scrollable = true
      then do:
        assign
          frame autopush :virtual-height = frame autopush :virtual-height + p-change-value
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
          ,input  string(frame autopush :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame autopush :height)
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
    if frame autopush :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame autopush :width
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
    if frame autopush :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame autopush :width
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
            frame autopush :width = v-frame-width
          .
          if frame autopush :scrollable = true
          then do:
            assign
              frame autopush :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame autopush :scrollable = true
          then do:
            assign
              frame autopush :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame autopush :width = v-frame-width
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
      v-frame-width = frame autopush :width
      v-frame-virtual-width = frame autopush :virtual-width
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
      v-field-group-handle = frame autopush :first-child
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
    do with frame autopush
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame autopush :scrollable = true
      then do:
        assign
          frame autopush :virtual-width = frame autopush :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame autopush :width = v-frame-width + p-change-value
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
        frame autopush :width = frame autopush :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame autopush :scrollable = true
      then do:
        assign
          frame autopush :virtual-width = frame autopush :virtual-width + p-change-value
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
          ,input  string(frame autopush :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame autopush :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame autopush
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame autopush :height - v-diasize-resize-button :height
                  - 1
                  - (frame autopush :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame autopush :width - v-diasize-resize-button :width
                  - 1
                  - (frame autopush :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame autopush
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
      v-row-delta = v-new-row - frame autopush :height
      v-col-delta = v-new-col - frame autopush :width
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
            - frame autopush :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame autopush :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame autopush :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame autopush :height-chars
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
      v-diasize-current-frame-width  = frame autopush :width
      v-diasize-current-frame-height = frame autopush :height
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
    do with frame autopush
    :
      assign
        v-diasize-orig-frame-height = frame autopush :height
        v-diasize-orig-frame-width  = frame autopush :width
        v-diasize-browse-handle     = browse BR-autotask :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame autopush :first-child
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME autopush:PARENT eq ?
THEN FRAME autopush:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define buffer buf_BatchProcess   for ub.BatchProcess .
  define buffer buf-c_BatchProcess for ub.BatchProcess .
  assign
    log-exit = false
  .
  RUN enable_UI.
  APPLY "value-changed" TO BROWSE db-list.
  assign
    par-is-bge = TRUE
  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-bge'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output v-par-val
  ,output v-par-type
  ) no-error .
  if error-status:error
     or v-par-type <> "L":U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка чтения конфигурационного параметра is-bge!"
      view-as alert-box error.
    return error .
  end.
  if v-par-val <> "yes" then do:
    assign
      par-is-bge = FALSE
    .
  end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-edi'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output par-is-edi
  ,output par-type
  )  .
  assign
      is-edi = lookup(par-is-edi, "true,yes":U) > 0
  .
  for each buf_temp-autotask:
    delete buf_temp-autotask.
  end.
  do while not log-exit
  on error undo, return error
  :
    wait-for
      go of frame autopush
      or close of this-procedure
      or value-changed of db-list in frame autopush
      or choose of b-do-now in frame autopush
      focus frame autopush
      pause 1
    .
    IF v-start THEN DO:
        v-start = NO.
        ENABLE
        db-list
        br-autotask
        WITH FRAME autopush.
        APPLY "value-changed" TO BROWSE db-list.
    END.
    else do:
      APPLY "value-changed" TO BROWSE db-list.
    end.
  end.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME autopush.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-exit b-not-send b-do-now b-help i-exit db-list BR-autotask
      WITH FRAME autopush.
  VIEW FRAME autopush.
  OPEN QUERY BR-autotask FOR EACH temp-autotask.    OPEN QUERY db-list FOR EACH buf_db NO-LOCK.
END PROCEDURE.
PROCEDURE fill-autotask :
define input parameter p-db-num as integer no-undo .
   run cur-time in this-procedure
      ( output v-c-date
       ,output v-c-time
      ) no-error.
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
        "Ошибка при определении текущей даты!"
        view-as alert-box error.
      return error.
    end.
for each buf_temp-autotask :
  delete buf_temp-autotask.
end.
if (p-db-num = 0
and v-cntxt-db-num > 0)
or (p-db-num > 0
and v-cntxt-db-num = 0)
then do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Status   = 'N':U
        and buf_BatchProcess.BP_Type     = 'autonws':U
        and buf_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf_BatchProcess.CharKey_Two = "auto":U
      no-error
    .
    FIND FIRST buf_temp-autotask WHERE
              buf_temp-autotask.db-num = buf_db.db-num
        AND buf_temp-autotask.task-type = 'autonws':U NO-ERROR.
    IF NOT AVAILABLE buf_temp-autotask THEN DO:
        CREATE buf_temp-autotask.
        ASSIGN
        buf_temp-autotask.db-num = buf_db.db-num
        buf_temp-autotask.task-type = 'autonws':U
        .
        case buf_temp-autotask.task-type:
          when 'autonws':U then do:
            assign
            buf_temp-autotask.task-name = "Новости"
            .
          end.
          when 'autoarh':U then do:
            assign
            buf_temp-autotask.task-name = "Архивы"
            .
          end.
          when 'autoexp':U then do:
            assign
            buf_temp-autotask.task-name = "Экспорт"
            .
          end.
          when 'autooxml':U then do:
            assign
            buf_temp-autotask.task-name = "OpenXML"
            .
          end.
          when 'autogcd':U then do:
            assign
            buf_temp-autotask.task-name = "Прием инф. с касс"
            .
          end.
          when 'autosale':U then do:
            assign
            buf_temp-autotask.task-name = "Обработка продаж"
            .
          end.
          when 'autosuz':U then do:
            assign
            buf_temp-autotask.task-name = "Отчеты"
            .
          end.
          when 'autocbnk':U then do:
            assign
            buf_temp-autotask.task-name = "Эксп/имп в КЛИЕНТ-БАНК"
            .
          end.
          when 'autofree':U then do:
            assign
            buf_temp-autotask.task-name = "Произвольные задания"
            .
          end.
          when 'sktsrv':U then do:
            assign
            buf_temp-autotask.task-name = "Сокет-Сервер"
            .
          end.
          when 'mercury':U then do:
            assign
            buf_temp-autotask.task-name = "Меркурий"
            .
          end.
          when 'hddtest':U then do:
            assign
            buf_temp-autotask.task-name = "Мониторинг HDD"
            .
          end.
          when 'is_motp':U then do:
            assign
            buf_temp-autotask.task-name = "ИС МОТП"
            .
          end.
          when 'is_diadoc':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Диадок"
            .
          end.
          when 'is_PM':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Президентский Мониторинг"
            .
          end.
        END CASE.
    END.
    if available buf_BatchProcess then do:
      assign
        buf_temp-autotask.task-date = buf_BatchProcess.BP_ExecSysDate
        buf_temp-autotask.task-time = buf_BatchProcess.BP_ExecSysTimeInt
      .
      if buf_temp-autotask.task-date < v-c-date
        or ( buf_temp-autotask.task-date = v-c-date
             and buf_BatchProcess.BP_ExecSysTimeInt < v-c-time
           )
      then do:
        assign
        buf_temp-autotask.overtime = YES
        .
      end.
      else do:
        if buf_temp-autotask.overtime = YES then do:
          assign
          buf_temp-autotask.overtime = NO
          .
        end.
      end.
    end.
    else do:
      assign
      buf_temp-autotask.overtime = YES
      buf_temp-autotask.task-date = ?
      buf_temp-autotask.task-time = ?
      .
    end.
    find first buf-c_BatchProcess no-lock
      where buf-c_BatchProcess.BP_Status   = 'N':U
        and buf-c_BatchProcess.BP_Type     = 'autonws':U
        and buf-c_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf-c_BatchProcess.CharKey_Two <> "auto":U
      no-error
    .
    if available buf-c_BatchProcess then do:
      assign
        buf_temp-autotask.corr = "!!!":U
      .
    end.
    else do:
      assign
      buf_temp-autotask.corr = "":U
      .
    end.
    assign
    buf_temp-autotask.date-time = string(buf_temp-autotask.task-date, "99/99/9999") + chr(32) +
                                  string(buf_temp-autotask.task-time, "HH:MM")
   .
end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Status   = 'N':U
        and buf_BatchProcess.BP_Type     = 'autoarh':U
        and buf_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf_BatchProcess.CharKey_Two = "auto":U
      no-error
    .
    FIND FIRST buf_temp-autotask WHERE
              buf_temp-autotask.db-num = buf_db.db-num
        AND buf_temp-autotask.task-type = 'autoarh':U NO-ERROR.
    IF NOT AVAILABLE buf_temp-autotask THEN DO:
        CREATE buf_temp-autotask.
        ASSIGN
        buf_temp-autotask.db-num = buf_db.db-num
        buf_temp-autotask.task-type = 'autoarh':U
        .
        case buf_temp-autotask.task-type:
          when 'autonws':U then do:
            assign
            buf_temp-autotask.task-name = "Новости"
            .
          end.
          when 'autoarh':U then do:
            assign
            buf_temp-autotask.task-name = "Архивы"
            .
          end.
          when 'autoexp':U then do:
            assign
            buf_temp-autotask.task-name = "Экспорт"
            .
          end.
          when 'autooxml':U then do:
            assign
            buf_temp-autotask.task-name = "OpenXML"
            .
          end.
          when 'autogcd':U then do:
            assign
            buf_temp-autotask.task-name = "Прием инф. с касс"
            .
          end.
          when 'autosale':U then do:
            assign
            buf_temp-autotask.task-name = "Обработка продаж"
            .
          end.
          when 'autosuz':U then do:
            assign
            buf_temp-autotask.task-name = "Отчеты"
            .
          end.
          when 'autocbnk':U then do:
            assign
            buf_temp-autotask.task-name = "Эксп/имп в КЛИЕНТ-БАНК"
            .
          end.
          when 'autofree':U then do:
            assign
            buf_temp-autotask.task-name = "Произвольные задания"
            .
          end.
          when 'sktsrv':U then do:
            assign
            buf_temp-autotask.task-name = "Сокет-Сервер"
            .
          end.
          when 'mercury':U then do:
            assign
            buf_temp-autotask.task-name = "Меркурий"
            .
          end.
          when 'hddtest':U then do:
            assign
            buf_temp-autotask.task-name = "Мониторинг HDD"
            .
          end.
          when 'is_motp':U then do:
            assign
            buf_temp-autotask.task-name = "ИС МОТП"
            .
          end.
          when 'is_diadoc':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Диадок"
            .
          end.
          when 'is_PM':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Президентский Мониторинг"
            .
          end.
        END CASE.
    END.
    if available buf_BatchProcess then do:
      assign
        buf_temp-autotask.task-date = buf_BatchProcess.BP_ExecSysDate
        buf_temp-autotask.task-time = buf_BatchProcess.BP_ExecSysTimeInt
      .
      if buf_temp-autotask.task-date < v-c-date
        or ( buf_temp-autotask.task-date = v-c-date
             and buf_BatchProcess.BP_ExecSysTimeInt < v-c-time
           )
      then do:
        assign
        buf_temp-autotask.overtime = YES
        .
      end.
      else do:
        if buf_temp-autotask.overtime = YES then do:
          assign
          buf_temp-autotask.overtime = NO
          .
        end.
      end.
    end.
    else do:
      assign
      buf_temp-autotask.overtime = YES
      buf_temp-autotask.task-date = ?
      buf_temp-autotask.task-time = ?
      .
    end.
    find first buf-c_BatchProcess no-lock
      where buf-c_BatchProcess.BP_Status   = 'N':U
        and buf-c_BatchProcess.BP_Type     = 'autoarh':U
        and buf-c_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf-c_BatchProcess.CharKey_Two <> "auto":U
      no-error
    .
    if available buf-c_BatchProcess then do:
      assign
        buf_temp-autotask.corr = "!!!":U
      .
    end.
    else do:
      assign
      buf_temp-autotask.corr = "":U
      .
    end.
    assign
    buf_temp-autotask.date-time = string(buf_temp-autotask.task-date, "99/99/9999") + chr(32) +
                                  string(buf_temp-autotask.task-time, "HH:MM")
   .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Status   = 'N':U
        and buf_BatchProcess.BP_Type     = 'mercury':U
        and buf_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf_BatchProcess.CharKey_Two = "auto":U
      no-error
    .
    FIND FIRST buf_temp-autotask WHERE
              buf_temp-autotask.db-num = buf_db.db-num
        AND buf_temp-autotask.task-type = 'mercury':U NO-ERROR.
    IF NOT AVAILABLE buf_temp-autotask THEN DO:
        CREATE buf_temp-autotask.
        ASSIGN
        buf_temp-autotask.db-num = buf_db.db-num
        buf_temp-autotask.task-type = 'mercury':U
        .
        case buf_temp-autotask.task-type:
          when 'autonws':U then do:
            assign
            buf_temp-autotask.task-name = "Новости"
            .
          end.
          when 'autoarh':U then do:
            assign
            buf_temp-autotask.task-name = "Архивы"
            .
          end.
          when 'autoexp':U then do:
            assign
            buf_temp-autotask.task-name = "Экспорт"
            .
          end.
          when 'autooxml':U then do:
            assign
            buf_temp-autotask.task-name = "OpenXML"
            .
          end.
          when 'autogcd':U then do:
            assign
            buf_temp-autotask.task-name = "Прием инф. с касс"
            .
          end.
          when 'autosale':U then do:
            assign
            buf_temp-autotask.task-name = "Обработка продаж"
            .
          end.
          when 'autosuz':U then do:
            assign
            buf_temp-autotask.task-name = "Отчеты"
            .
          end.
          when 'autocbnk':U then do:
            assign
            buf_temp-autotask.task-name = "Эксп/имп в КЛИЕНТ-БАНК"
            .
          end.
          when 'autofree':U then do:
            assign
            buf_temp-autotask.task-name = "Произвольные задания"
            .
          end.
          when 'sktsrv':U then do:
            assign
            buf_temp-autotask.task-name = "Сокет-Сервер"
            .
          end.
          when 'mercury':U then do:
            assign
            buf_temp-autotask.task-name = "Меркурий"
            .
          end.
          when 'hddtest':U then do:
            assign
            buf_temp-autotask.task-name = "Мониторинг HDD"
            .
          end.
          when 'is_motp':U then do:
            assign
            buf_temp-autotask.task-name = "ИС МОТП"
            .
          end.
          when 'is_diadoc':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Диадок"
            .
          end.
          when 'is_PM':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Президентский Мониторинг"
            .
          end.
        END CASE.
    END.
    if available buf_BatchProcess then do:
      assign
        buf_temp-autotask.task-date = buf_BatchProcess.BP_ExecSysDate
        buf_temp-autotask.task-time = buf_BatchProcess.BP_ExecSysTimeInt
      .
      if buf_temp-autotask.task-date < v-c-date
        or ( buf_temp-autotask.task-date = v-c-date
             and buf_BatchProcess.BP_ExecSysTimeInt < v-c-time
           )
      then do:
        assign
        buf_temp-autotask.overtime = YES
        .
      end.
      else do:
        if buf_temp-autotask.overtime = YES then do:
          assign
          buf_temp-autotask.overtime = NO
          .
        end.
      end.
    end.
    else do:
      assign
      buf_temp-autotask.overtime = YES
      buf_temp-autotask.task-date = ?
      buf_temp-autotask.task-time = ?
      .
    end.
    find first buf-c_BatchProcess no-lock
      where buf-c_BatchProcess.BP_Status   = 'N':U
        and buf-c_BatchProcess.BP_Type     = 'mercury':U
        and buf-c_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf-c_BatchProcess.CharKey_Two <> "auto":U
      no-error
    .
    if available buf-c_BatchProcess then do:
      assign
        buf_temp-autotask.corr = "!!!":U
      .
    end.
    else do:
      assign
      buf_temp-autotask.corr = "":U
      .
    end.
    assign
    buf_temp-autotask.date-time = string(buf_temp-autotask.task-date, "99/99/9999") + chr(32) +
                                  string(buf_temp-autotask.task-time, "HH:MM")
   .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Status   = 'N':U
        and buf_BatchProcess.BP_Type     = 'hddtest':U
        and buf_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf_BatchProcess.CharKey_Two = "auto":U
      no-error
    .
    FIND FIRST buf_temp-autotask WHERE
              buf_temp-autotask.db-num = buf_db.db-num
        AND buf_temp-autotask.task-type = 'hddtest':U NO-ERROR.
    IF NOT AVAILABLE buf_temp-autotask THEN DO:
        CREATE buf_temp-autotask.
        ASSIGN
        buf_temp-autotask.db-num = buf_db.db-num
        buf_temp-autotask.task-type = 'hddtest':U
        .
        case buf_temp-autotask.task-type:
          when 'autonws':U then do:
            assign
            buf_temp-autotask.task-name = "Новости"
            .
          end.
          when 'autoarh':U then do:
            assign
            buf_temp-autotask.task-name = "Архивы"
            .
          end.
          when 'autoexp':U then do:
            assign
            buf_temp-autotask.task-name = "Экспорт"
            .
          end.
          when 'autooxml':U then do:
            assign
            buf_temp-autotask.task-name = "OpenXML"
            .
          end.
          when 'autogcd':U then do:
            assign
            buf_temp-autotask.task-name = "Прием инф. с касс"
            .
          end.
          when 'autosale':U then do:
            assign
            buf_temp-autotask.task-name = "Обработка продаж"
            .
          end.
          when 'autosuz':U then do:
            assign
            buf_temp-autotask.task-name = "Отчеты"
            .
          end.
          when 'autocbnk':U then do:
            assign
            buf_temp-autotask.task-name = "Эксп/имп в КЛИЕНТ-БАНК"
            .
          end.
          when 'autofree':U then do:
            assign
            buf_temp-autotask.task-name = "Произвольные задания"
            .
          end.
          when 'sktsrv':U then do:
            assign
            buf_temp-autotask.task-name = "Сокет-Сервер"
            .
          end.
          when 'mercury':U then do:
            assign
            buf_temp-autotask.task-name = "Меркурий"
            .
          end.
          when 'hddtest':U then do:
            assign
            buf_temp-autotask.task-name = "Мониторинг HDD"
            .
          end.
          when 'is_motp':U then do:
            assign
            buf_temp-autotask.task-name = "ИС МОТП"
            .
          end.
          when 'is_diadoc':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Диадок"
            .
          end.
          when 'is_PM':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Президентский Мониторинг"
            .
          end.
        END CASE.
    END.
    if available buf_BatchProcess then do:
      assign
        buf_temp-autotask.task-date = buf_BatchProcess.BP_ExecSysDate
        buf_temp-autotask.task-time = buf_BatchProcess.BP_ExecSysTimeInt
      .
      if buf_temp-autotask.task-date < v-c-date
        or ( buf_temp-autotask.task-date = v-c-date
             and buf_BatchProcess.BP_ExecSysTimeInt < v-c-time
           )
      then do:
        assign
        buf_temp-autotask.overtime = YES
        .
      end.
      else do:
        if buf_temp-autotask.overtime = YES then do:
          assign
          buf_temp-autotask.overtime = NO
          .
        end.
      end.
    end.
    else do:
      assign
      buf_temp-autotask.overtime = YES
      buf_temp-autotask.task-date = ?
      buf_temp-autotask.task-time = ?
      .
    end.
    find first buf-c_BatchProcess no-lock
      where buf-c_BatchProcess.BP_Status   = 'N':U
        and buf-c_BatchProcess.BP_Type     = 'hddtest':U
        and buf-c_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf-c_BatchProcess.CharKey_Two <> "auto":U
      no-error
    .
    if available buf-c_BatchProcess then do:
      assign
        buf_temp-autotask.corr = "!!!":U
      .
    end.
    else do:
      assign
      buf_temp-autotask.corr = "":U
      .
    end.
    assign
    buf_temp-autotask.date-time = string(buf_temp-autotask.task-date, "99/99/9999") + chr(32) +
                                  string(buf_temp-autotask.task-time, "HH:MM")
   .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Status   = 'N':U
        and buf_BatchProcess.BP_Type     = 'is_motp':U
        and buf_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf_BatchProcess.CharKey_Two = "auto":U
      no-error
    .
    FIND FIRST buf_temp-autotask WHERE
              buf_temp-autotask.db-num = buf_db.db-num
        AND buf_temp-autotask.task-type = 'is_motp':U NO-ERROR.
    IF NOT AVAILABLE buf_temp-autotask THEN DO:
        CREATE buf_temp-autotask.
        ASSIGN
        buf_temp-autotask.db-num = buf_db.db-num
        buf_temp-autotask.task-type = 'is_motp':U
        .
        case buf_temp-autotask.task-type:
          when 'autonws':U then do:
            assign
            buf_temp-autotask.task-name = "Новости"
            .
          end.
          when 'autoarh':U then do:
            assign
            buf_temp-autotask.task-name = "Архивы"
            .
          end.
          when 'autoexp':U then do:
            assign
            buf_temp-autotask.task-name = "Экспорт"
            .
          end.
          when 'autooxml':U then do:
            assign
            buf_temp-autotask.task-name = "OpenXML"
            .
          end.
          when 'autogcd':U then do:
            assign
            buf_temp-autotask.task-name = "Прием инф. с касс"
            .
          end.
          when 'autosale':U then do:
            assign
            buf_temp-autotask.task-name = "Обработка продаж"
            .
          end.
          when 'autosuz':U then do:
            assign
            buf_temp-autotask.task-name = "Отчеты"
            .
          end.
          when 'autocbnk':U then do:
            assign
            buf_temp-autotask.task-name = "Эксп/имп в КЛИЕНТ-БАНК"
            .
          end.
          when 'autofree':U then do:
            assign
            buf_temp-autotask.task-name = "Произвольные задания"
            .
          end.
          when 'sktsrv':U then do:
            assign
            buf_temp-autotask.task-name = "Сокет-Сервер"
            .
          end.
          when 'mercury':U then do:
            assign
            buf_temp-autotask.task-name = "Меркурий"
            .
          end.
          when 'hddtest':U then do:
            assign
            buf_temp-autotask.task-name = "Мониторинг HDD"
            .
          end.
          when 'is_motp':U then do:
            assign
            buf_temp-autotask.task-name = "ИС МОТП"
            .
          end.
          when 'is_diadoc':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Диадок"
            .
          end.
          when 'is_PM':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Президентский Мониторинг"
            .
          end.
        END CASE.
    END.
    if available buf_BatchProcess then do:
      assign
        buf_temp-autotask.task-date = buf_BatchProcess.BP_ExecSysDate
        buf_temp-autotask.task-time = buf_BatchProcess.BP_ExecSysTimeInt
      .
      if buf_temp-autotask.task-date < v-c-date
        or ( buf_temp-autotask.task-date = v-c-date
             and buf_BatchProcess.BP_ExecSysTimeInt < v-c-time
           )
      then do:
        assign
        buf_temp-autotask.overtime = YES
        .
      end.
      else do:
        if buf_temp-autotask.overtime = YES then do:
          assign
          buf_temp-autotask.overtime = NO
          .
        end.
      end.
    end.
    else do:
      assign
      buf_temp-autotask.overtime = YES
      buf_temp-autotask.task-date = ?
      buf_temp-autotask.task-time = ?
      .
    end.
    find first buf-c_BatchProcess no-lock
      where buf-c_BatchProcess.BP_Status   = 'N':U
        and buf-c_BatchProcess.BP_Type     = 'is_motp':U
        and buf-c_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf-c_BatchProcess.CharKey_Two <> "auto":U
      no-error
    .
    if available buf-c_BatchProcess then do:
      assign
        buf_temp-autotask.corr = "!!!":U
      .
    end.
    else do:
      assign
      buf_temp-autotask.corr = "":U
      .
    end.
    assign
    buf_temp-autotask.date-time = string(buf_temp-autotask.task-date, "99/99/9999") + chr(32) +
                                  string(buf_temp-autotask.task-time, "HH:MM")
   .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Status   = 'N':U
        and buf_BatchProcess.BP_Type     = 'is_diadoc':U
        and buf_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf_BatchProcess.CharKey_Two = "auto":U
      no-error
    .
    FIND FIRST buf_temp-autotask WHERE
              buf_temp-autotask.db-num = buf_db.db-num
        AND buf_temp-autotask.task-type = 'is_diadoc':U NO-ERROR.
    IF NOT AVAILABLE buf_temp-autotask THEN DO:
        CREATE buf_temp-autotask.
        ASSIGN
        buf_temp-autotask.db-num = buf_db.db-num
        buf_temp-autotask.task-type = 'is_diadoc':U
        .
        case buf_temp-autotask.task-type:
          when 'autonws':U then do:
            assign
            buf_temp-autotask.task-name = "Новости"
            .
          end.
          when 'autoarh':U then do:
            assign
            buf_temp-autotask.task-name = "Архивы"
            .
          end.
          when 'autoexp':U then do:
            assign
            buf_temp-autotask.task-name = "Экспорт"
            .
          end.
          when 'autooxml':U then do:
            assign
            buf_temp-autotask.task-name = "OpenXML"
            .
          end.
          when 'autogcd':U then do:
            assign
            buf_temp-autotask.task-name = "Прием инф. с касс"
            .
          end.
          when 'autosale':U then do:
            assign
            buf_temp-autotask.task-name = "Обработка продаж"
            .
          end.
          when 'autosuz':U then do:
            assign
            buf_temp-autotask.task-name = "Отчеты"
            .
          end.
          when 'autocbnk':U then do:
            assign
            buf_temp-autotask.task-name = "Эксп/имп в КЛИЕНТ-БАНК"
            .
          end.
          when 'autofree':U then do:
            assign
            buf_temp-autotask.task-name = "Произвольные задания"
            .
          end.
          when 'sktsrv':U then do:
            assign
            buf_temp-autotask.task-name = "Сокет-Сервер"
            .
          end.
          when 'mercury':U then do:
            assign
            buf_temp-autotask.task-name = "Меркурий"
            .
          end.
          when 'hddtest':U then do:
            assign
            buf_temp-autotask.task-name = "Мониторинг HDD"
            .
          end.
          when 'is_motp':U then do:
            assign
            buf_temp-autotask.task-name = "ИС МОТП"
            .
          end.
          when 'is_diadoc':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Диадок"
            .
          end.
          when 'is_PM':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Президентский Мониторинг"
            .
          end.
        END CASE.
    END.
    if available buf_BatchProcess then do:
      assign
        buf_temp-autotask.task-date = buf_BatchProcess.BP_ExecSysDate
        buf_temp-autotask.task-time = buf_BatchProcess.BP_ExecSysTimeInt
      .
      if buf_temp-autotask.task-date < v-c-date
        or ( buf_temp-autotask.task-date = v-c-date
             and buf_BatchProcess.BP_ExecSysTimeInt < v-c-time
           )
      then do:
        assign
        buf_temp-autotask.overtime = YES
        .
      end.
      else do:
        if buf_temp-autotask.overtime = YES then do:
          assign
          buf_temp-autotask.overtime = NO
          .
        end.
      end.
    end.
    else do:
      assign
      buf_temp-autotask.overtime = YES
      buf_temp-autotask.task-date = ?
      buf_temp-autotask.task-time = ?
      .
    end.
    find first buf-c_BatchProcess no-lock
      where buf-c_BatchProcess.BP_Status   = 'N':U
        and buf-c_BatchProcess.BP_Type     = 'is_diadoc':U
        and buf-c_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf-c_BatchProcess.CharKey_Two <> "auto":U
      no-error
    .
    if available buf-c_BatchProcess then do:
      assign
        buf_temp-autotask.corr = "!!!":U
      .
    end.
    else do:
      assign
      buf_temp-autotask.corr = "":U
      .
    end.
    assign
    buf_temp-autotask.date-time = string(buf_temp-autotask.task-date, "99/99/9999") + chr(32) +
                                  string(buf_temp-autotask.task-time, "HH:MM")
   .
    if par-is-bge = true then do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Status   = 'N':U
        and buf_BatchProcess.BP_Type     = 'autoexp':U
        and buf_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf_BatchProcess.CharKey_Two = "auto":U
      no-error
    .
    FIND FIRST buf_temp-autotask WHERE
              buf_temp-autotask.db-num = buf_db.db-num
        AND buf_temp-autotask.task-type = 'autoexp':U NO-ERROR.
    IF NOT AVAILABLE buf_temp-autotask THEN DO:
        CREATE buf_temp-autotask.
        ASSIGN
        buf_temp-autotask.db-num = buf_db.db-num
        buf_temp-autotask.task-type = 'autoexp':U
        .
        case buf_temp-autotask.task-type:
          when 'autonws':U then do:
            assign
            buf_temp-autotask.task-name = "Новости"
            .
          end.
          when 'autoarh':U then do:
            assign
            buf_temp-autotask.task-name = "Архивы"
            .
          end.
          when 'autoexp':U then do:
            assign
            buf_temp-autotask.task-name = "Экспорт"
            .
          end.
          when 'autooxml':U then do:
            assign
            buf_temp-autotask.task-name = "OpenXML"
            .
          end.
          when 'autogcd':U then do:
            assign
            buf_temp-autotask.task-name = "Прием инф. с касс"
            .
          end.
          when 'autosale':U then do:
            assign
            buf_temp-autotask.task-name = "Обработка продаж"
            .
          end.
          when 'autosuz':U then do:
            assign
            buf_temp-autotask.task-name = "Отчеты"
            .
          end.
          when 'autocbnk':U then do:
            assign
            buf_temp-autotask.task-name = "Эксп/имп в КЛИЕНТ-БАНК"
            .
          end.
          when 'autofree':U then do:
            assign
            buf_temp-autotask.task-name = "Произвольные задания"
            .
          end.
          when 'sktsrv':U then do:
            assign
            buf_temp-autotask.task-name = "Сокет-Сервер"
            .
          end.
          when 'mercury':U then do:
            assign
            buf_temp-autotask.task-name = "Меркурий"
            .
          end.
          when 'hddtest':U then do:
            assign
            buf_temp-autotask.task-name = "Мониторинг HDD"
            .
          end.
          when 'is_motp':U then do:
            assign
            buf_temp-autotask.task-name = "ИС МОТП"
            .
          end.
          when 'is_diadoc':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Диадок"
            .
          end.
          when 'is_PM':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Президентский Мониторинг"
            .
          end.
        END CASE.
    END.
    if available buf_BatchProcess then do:
      assign
        buf_temp-autotask.task-date = buf_BatchProcess.BP_ExecSysDate
        buf_temp-autotask.task-time = buf_BatchProcess.BP_ExecSysTimeInt
      .
      if buf_temp-autotask.task-date < v-c-date
        or ( buf_temp-autotask.task-date = v-c-date
             and buf_BatchProcess.BP_ExecSysTimeInt < v-c-time
           )
      then do:
        assign
        buf_temp-autotask.overtime = YES
        .
      end.
      else do:
        if buf_temp-autotask.overtime = YES then do:
          assign
          buf_temp-autotask.overtime = NO
          .
        end.
      end.
    end.
    else do:
      assign
      buf_temp-autotask.overtime = YES
      buf_temp-autotask.task-date = ?
      buf_temp-autotask.task-time = ?
      .
    end.
    find first buf-c_BatchProcess no-lock
      where buf-c_BatchProcess.BP_Status   = 'N':U
        and buf-c_BatchProcess.BP_Type     = 'autoexp':U
        and buf-c_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf-c_BatchProcess.CharKey_Two <> "auto":U
      no-error
    .
    if available buf-c_BatchProcess then do:
      assign
        buf_temp-autotask.corr = "!!!":U
      .
    end.
    else do:
      assign
      buf_temp-autotask.corr = "":U
      .
    end.
    assign
    buf_temp-autotask.date-time = string(buf_temp-autotask.task-date, "99/99/9999") + chr(32) +
                                  string(buf_temp-autotask.task-time, "HH:MM")
   .
    END.
if p-db-num = v-cntxt-db-num then do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Status   = 'N':U
        and buf_BatchProcess.BP_Type     = 'autooxml':U
        and buf_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf_BatchProcess.CharKey_Two = "auto":U
      no-error
    .
    FIND FIRST buf_temp-autotask WHERE
              buf_temp-autotask.db-num = buf_db.db-num
        AND buf_temp-autotask.task-type = 'autooxml':U NO-ERROR.
    IF NOT AVAILABLE buf_temp-autotask THEN DO:
        CREATE buf_temp-autotask.
        ASSIGN
        buf_temp-autotask.db-num = buf_db.db-num
        buf_temp-autotask.task-type = 'autooxml':U
        .
        case buf_temp-autotask.task-type:
          when 'autonws':U then do:
            assign
            buf_temp-autotask.task-name = "Новости"
            .
          end.
          when 'autoarh':U then do:
            assign
            buf_temp-autotask.task-name = "Архивы"
            .
          end.
          when 'autoexp':U then do:
            assign
            buf_temp-autotask.task-name = "Экспорт"
            .
          end.
          when 'autooxml':U then do:
            assign
            buf_temp-autotask.task-name = "OpenXML"
            .
          end.
          when 'autogcd':U then do:
            assign
            buf_temp-autotask.task-name = "Прием инф. с касс"
            .
          end.
          when 'autosale':U then do:
            assign
            buf_temp-autotask.task-name = "Обработка продаж"
            .
          end.
          when 'autosuz':U then do:
            assign
            buf_temp-autotask.task-name = "Отчеты"
            .
          end.
          when 'autocbnk':U then do:
            assign
            buf_temp-autotask.task-name = "Эксп/имп в КЛИЕНТ-БАНК"
            .
          end.
          when 'autofree':U then do:
            assign
            buf_temp-autotask.task-name = "Произвольные задания"
            .
          end.
          when 'sktsrv':U then do:
            assign
            buf_temp-autotask.task-name = "Сокет-Сервер"
            .
          end.
          when 'mercury':U then do:
            assign
            buf_temp-autotask.task-name = "Меркурий"
            .
          end.
          when 'hddtest':U then do:
            assign
            buf_temp-autotask.task-name = "Мониторинг HDD"
            .
          end.
          when 'is_motp':U then do:
            assign
            buf_temp-autotask.task-name = "ИС МОТП"
            .
          end.
          when 'is_diadoc':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Диадок"
            .
          end.
          when 'is_PM':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Президентский Мониторинг"
            .
          end.
        END CASE.
    END.
    if available buf_BatchProcess then do:
      assign
        buf_temp-autotask.task-date = buf_BatchProcess.BP_ExecSysDate
        buf_temp-autotask.task-time = buf_BatchProcess.BP_ExecSysTimeInt
      .
      if buf_temp-autotask.task-date < v-c-date
        or ( buf_temp-autotask.task-date = v-c-date
             and buf_BatchProcess.BP_ExecSysTimeInt < v-c-time
           )
      then do:
        assign
        buf_temp-autotask.overtime = YES
        .
      end.
      else do:
        if buf_temp-autotask.overtime = YES then do:
          assign
          buf_temp-autotask.overtime = NO
          .
        end.
      end.
    end.
    else do:
      assign
      buf_temp-autotask.overtime = YES
      buf_temp-autotask.task-date = ?
      buf_temp-autotask.task-time = ?
      .
    end.
    find first buf-c_BatchProcess no-lock
      where buf-c_BatchProcess.BP_Status   = 'N':U
        and buf-c_BatchProcess.BP_Type     = 'autooxml':U
        and buf-c_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf-c_BatchProcess.CharKey_Two <> "auto":U
      no-error
    .
    if available buf-c_BatchProcess then do:
      assign
        buf_temp-autotask.corr = "!!!":U
      .
    end.
    else do:
      assign
      buf_temp-autotask.corr = "":U
      .
    end.
    assign
    buf_temp-autotask.date-time = string(buf_temp-autotask.task-date, "99/99/9999") + chr(32) +
                                  string(buf_temp-autotask.task-time, "HH:MM")
   .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Status   = 'N':U
        and buf_BatchProcess.BP_Type     = 'autogcd':U
        and buf_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf_BatchProcess.CharKey_Two = "auto":U
      no-error
    .
    FIND FIRST buf_temp-autotask WHERE
              buf_temp-autotask.db-num = buf_db.db-num
        AND buf_temp-autotask.task-type = 'autogcd':U NO-ERROR.
    IF NOT AVAILABLE buf_temp-autotask THEN DO:
        CREATE buf_temp-autotask.
        ASSIGN
        buf_temp-autotask.db-num = buf_db.db-num
        buf_temp-autotask.task-type = 'autogcd':U
        .
        case buf_temp-autotask.task-type:
          when 'autonws':U then do:
            assign
            buf_temp-autotask.task-name = "Новости"
            .
          end.
          when 'autoarh':U then do:
            assign
            buf_temp-autotask.task-name = "Архивы"
            .
          end.
          when 'autoexp':U then do:
            assign
            buf_temp-autotask.task-name = "Экспорт"
            .
          end.
          when 'autooxml':U then do:
            assign
            buf_temp-autotask.task-name = "OpenXML"
            .
          end.
          when 'autogcd':U then do:
            assign
            buf_temp-autotask.task-name = "Прием инф. с касс"
            .
          end.
          when 'autosale':U then do:
            assign
            buf_temp-autotask.task-name = "Обработка продаж"
            .
          end.
          when 'autosuz':U then do:
            assign
            buf_temp-autotask.task-name = "Отчеты"
            .
          end.
          when 'autocbnk':U then do:
            assign
            buf_temp-autotask.task-name = "Эксп/имп в КЛИЕНТ-БАНК"
            .
          end.
          when 'autofree':U then do:
            assign
            buf_temp-autotask.task-name = "Произвольные задания"
            .
          end.
          when 'sktsrv':U then do:
            assign
            buf_temp-autotask.task-name = "Сокет-Сервер"
            .
          end.
          when 'mercury':U then do:
            assign
            buf_temp-autotask.task-name = "Меркурий"
            .
          end.
          when 'hddtest':U then do:
            assign
            buf_temp-autotask.task-name = "Мониторинг HDD"
            .
          end.
          when 'is_motp':U then do:
            assign
            buf_temp-autotask.task-name = "ИС МОТП"
            .
          end.
          when 'is_diadoc':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Диадок"
            .
          end.
          when 'is_PM':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Президентский Мониторинг"
            .
          end.
        END CASE.
    END.
    if available buf_BatchProcess then do:
      assign
        buf_temp-autotask.task-date = buf_BatchProcess.BP_ExecSysDate
        buf_temp-autotask.task-time = buf_BatchProcess.BP_ExecSysTimeInt
      .
      if buf_temp-autotask.task-date < v-c-date
        or ( buf_temp-autotask.task-date = v-c-date
             and buf_BatchProcess.BP_ExecSysTimeInt < v-c-time
           )
      then do:
        assign
        buf_temp-autotask.overtime = YES
        .
      end.
      else do:
        if buf_temp-autotask.overtime = YES then do:
          assign
          buf_temp-autotask.overtime = NO
          .
        end.
      end.
    end.
    else do:
      assign
      buf_temp-autotask.overtime = YES
      buf_temp-autotask.task-date = ?
      buf_temp-autotask.task-time = ?
      .
    end.
    find first buf-c_BatchProcess no-lock
      where buf-c_BatchProcess.BP_Status   = 'N':U
        and buf-c_BatchProcess.BP_Type     = 'autogcd':U
        and buf-c_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf-c_BatchProcess.CharKey_Two <> "auto":U
      no-error
    .
    if available buf-c_BatchProcess then do:
      assign
        buf_temp-autotask.corr = "!!!":U
      .
    end.
    else do:
      assign
      buf_temp-autotask.corr = "":U
      .
    end.
    assign
    buf_temp-autotask.date-time = string(buf_temp-autotask.task-date, "99/99/9999") + chr(32) +
                                  string(buf_temp-autotask.task-time, "HH:MM")
   .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Status   = 'N':U
        and buf_BatchProcess.BP_Type     = 'autosale':U
        and buf_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf_BatchProcess.CharKey_Two = "auto":U
      no-error
    .
    FIND FIRST buf_temp-autotask WHERE
              buf_temp-autotask.db-num = buf_db.db-num
        AND buf_temp-autotask.task-type = 'autosale':U NO-ERROR.
    IF NOT AVAILABLE buf_temp-autotask THEN DO:
        CREATE buf_temp-autotask.
        ASSIGN
        buf_temp-autotask.db-num = buf_db.db-num
        buf_temp-autotask.task-type = 'autosale':U
        .
        case buf_temp-autotask.task-type:
          when 'autonws':U then do:
            assign
            buf_temp-autotask.task-name = "Новости"
            .
          end.
          when 'autoarh':U then do:
            assign
            buf_temp-autotask.task-name = "Архивы"
            .
          end.
          when 'autoexp':U then do:
            assign
            buf_temp-autotask.task-name = "Экспорт"
            .
          end.
          when 'autooxml':U then do:
            assign
            buf_temp-autotask.task-name = "OpenXML"
            .
          end.
          when 'autogcd':U then do:
            assign
            buf_temp-autotask.task-name = "Прием инф. с касс"
            .
          end.
          when 'autosale':U then do:
            assign
            buf_temp-autotask.task-name = "Обработка продаж"
            .
          end.
          when 'autosuz':U then do:
            assign
            buf_temp-autotask.task-name = "Отчеты"
            .
          end.
          when 'autocbnk':U then do:
            assign
            buf_temp-autotask.task-name = "Эксп/имп в КЛИЕНТ-БАНК"
            .
          end.
          when 'autofree':U then do:
            assign
            buf_temp-autotask.task-name = "Произвольные задания"
            .
          end.
          when 'sktsrv':U then do:
            assign
            buf_temp-autotask.task-name = "Сокет-Сервер"
            .
          end.
          when 'mercury':U then do:
            assign
            buf_temp-autotask.task-name = "Меркурий"
            .
          end.
          when 'hddtest':U then do:
            assign
            buf_temp-autotask.task-name = "Мониторинг HDD"
            .
          end.
          when 'is_motp':U then do:
            assign
            buf_temp-autotask.task-name = "ИС МОТП"
            .
          end.
          when 'is_diadoc':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Диадок"
            .
          end.
          when 'is_PM':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Президентский Мониторинг"
            .
          end.
        END CASE.
    END.
    if available buf_BatchProcess then do:
      assign
        buf_temp-autotask.task-date = buf_BatchProcess.BP_ExecSysDate
        buf_temp-autotask.task-time = buf_BatchProcess.BP_ExecSysTimeInt
      .
      if buf_temp-autotask.task-date < v-c-date
        or ( buf_temp-autotask.task-date = v-c-date
             and buf_BatchProcess.BP_ExecSysTimeInt < v-c-time
           )
      then do:
        assign
        buf_temp-autotask.overtime = YES
        .
      end.
      else do:
        if buf_temp-autotask.overtime = YES then do:
          assign
          buf_temp-autotask.overtime = NO
          .
        end.
      end.
    end.
    else do:
      assign
      buf_temp-autotask.overtime = YES
      buf_temp-autotask.task-date = ?
      buf_temp-autotask.task-time = ?
      .
    end.
    find first buf-c_BatchProcess no-lock
      where buf-c_BatchProcess.BP_Status   = 'N':U
        and buf-c_BatchProcess.BP_Type     = 'autosale':U
        and buf-c_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf-c_BatchProcess.CharKey_Two <> "auto":U
      no-error
    .
    if available buf-c_BatchProcess then do:
      assign
        buf_temp-autotask.corr = "!!!":U
      .
    end.
    else do:
      assign
      buf_temp-autotask.corr = "":U
      .
    end.
    assign
    buf_temp-autotask.date-time = string(buf_temp-autotask.task-date, "99/99/9999") + chr(32) +
                                  string(buf_temp-autotask.task-time, "HH:MM")
   .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Status   = 'N':U
        and buf_BatchProcess.BP_Type     = 'is_PM':U
        and buf_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf_BatchProcess.CharKey_Two = "auto":U
      no-error
    .
    FIND FIRST buf_temp-autotask WHERE
              buf_temp-autotask.db-num = buf_db.db-num
        AND buf_temp-autotask.task-type = 'is_PM':U NO-ERROR.
    IF NOT AVAILABLE buf_temp-autotask THEN DO:
        CREATE buf_temp-autotask.
        ASSIGN
        buf_temp-autotask.db-num = buf_db.db-num
        buf_temp-autotask.task-type = 'is_PM':U
        .
        case buf_temp-autotask.task-type:
          when 'autonws':U then do:
            assign
            buf_temp-autotask.task-name = "Новости"
            .
          end.
          when 'autoarh':U then do:
            assign
            buf_temp-autotask.task-name = "Архивы"
            .
          end.
          when 'autoexp':U then do:
            assign
            buf_temp-autotask.task-name = "Экспорт"
            .
          end.
          when 'autooxml':U then do:
            assign
            buf_temp-autotask.task-name = "OpenXML"
            .
          end.
          when 'autogcd':U then do:
            assign
            buf_temp-autotask.task-name = "Прием инф. с касс"
            .
          end.
          when 'autosale':U then do:
            assign
            buf_temp-autotask.task-name = "Обработка продаж"
            .
          end.
          when 'autosuz':U then do:
            assign
            buf_temp-autotask.task-name = "Отчеты"
            .
          end.
          when 'autocbnk':U then do:
            assign
            buf_temp-autotask.task-name = "Эксп/имп в КЛИЕНТ-БАНК"
            .
          end.
          when 'autofree':U then do:
            assign
            buf_temp-autotask.task-name = "Произвольные задания"
            .
          end.
          when 'sktsrv':U then do:
            assign
            buf_temp-autotask.task-name = "Сокет-Сервер"
            .
          end.
          when 'mercury':U then do:
            assign
            buf_temp-autotask.task-name = "Меркурий"
            .
          end.
          when 'hddtest':U then do:
            assign
            buf_temp-autotask.task-name = "Мониторинг HDD"
            .
          end.
          when 'is_motp':U then do:
            assign
            buf_temp-autotask.task-name = "ИС МОТП"
            .
          end.
          when 'is_diadoc':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Диадок"
            .
          end.
          when 'is_PM':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Президентский Мониторинг"
            .
          end.
        END CASE.
    END.
    if available buf_BatchProcess then do:
      assign
        buf_temp-autotask.task-date = buf_BatchProcess.BP_ExecSysDate
        buf_temp-autotask.task-time = buf_BatchProcess.BP_ExecSysTimeInt
      .
      if buf_temp-autotask.task-date < v-c-date
        or ( buf_temp-autotask.task-date = v-c-date
             and buf_BatchProcess.BP_ExecSysTimeInt < v-c-time
           )
      then do:
        assign
        buf_temp-autotask.overtime = YES
        .
      end.
      else do:
        if buf_temp-autotask.overtime = YES then do:
          assign
          buf_temp-autotask.overtime = NO
          .
        end.
      end.
    end.
    else do:
      assign
      buf_temp-autotask.overtime = YES
      buf_temp-autotask.task-date = ?
      buf_temp-autotask.task-time = ?
      .
    end.
    find first buf-c_BatchProcess no-lock
      where buf-c_BatchProcess.BP_Status   = 'N':U
        and buf-c_BatchProcess.BP_Type     = 'is_PM':U
        and buf-c_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf-c_BatchProcess.CharKey_Two <> "auto":U
      no-error
    .
    if available buf-c_BatchProcess then do:
      assign
        buf_temp-autotask.corr = "!!!":U
      .
    end.
    else do:
      assign
      buf_temp-autotask.corr = "":U
      .
    end.
    assign
    buf_temp-autotask.date-time = string(buf_temp-autotask.task-date, "99/99/9999") + chr(32) +
                                  string(buf_temp-autotask.task-time, "HH:MM")
   .
end.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Status   = 'N':U
        and buf_BatchProcess.BP_Type     = 'autosuz':U
        and buf_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf_BatchProcess.CharKey_Two = "auto":U
      no-error
    .
    FIND FIRST buf_temp-autotask WHERE
              buf_temp-autotask.db-num = buf_db.db-num
        AND buf_temp-autotask.task-type = 'autosuz':U NO-ERROR.
    IF NOT AVAILABLE buf_temp-autotask THEN DO:
        CREATE buf_temp-autotask.
        ASSIGN
        buf_temp-autotask.db-num = buf_db.db-num
        buf_temp-autotask.task-type = 'autosuz':U
        .
        case buf_temp-autotask.task-type:
          when 'autonws':U then do:
            assign
            buf_temp-autotask.task-name = "Новости"
            .
          end.
          when 'autoarh':U then do:
            assign
            buf_temp-autotask.task-name = "Архивы"
            .
          end.
          when 'autoexp':U then do:
            assign
            buf_temp-autotask.task-name = "Экспорт"
            .
          end.
          when 'autooxml':U then do:
            assign
            buf_temp-autotask.task-name = "OpenXML"
            .
          end.
          when 'autogcd':U then do:
            assign
            buf_temp-autotask.task-name = "Прием инф. с касс"
            .
          end.
          when 'autosale':U then do:
            assign
            buf_temp-autotask.task-name = "Обработка продаж"
            .
          end.
          when 'autosuz':U then do:
            assign
            buf_temp-autotask.task-name = "Отчеты"
            .
          end.
          when 'autocbnk':U then do:
            assign
            buf_temp-autotask.task-name = "Эксп/имп в КЛИЕНТ-БАНК"
            .
          end.
          when 'autofree':U then do:
            assign
            buf_temp-autotask.task-name = "Произвольные задания"
            .
          end.
          when 'sktsrv':U then do:
            assign
            buf_temp-autotask.task-name = "Сокет-Сервер"
            .
          end.
          when 'mercury':U then do:
            assign
            buf_temp-autotask.task-name = "Меркурий"
            .
          end.
          when 'hddtest':U then do:
            assign
            buf_temp-autotask.task-name = "Мониторинг HDD"
            .
          end.
          when 'is_motp':U then do:
            assign
            buf_temp-autotask.task-name = "ИС МОТП"
            .
          end.
          when 'is_diadoc':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Диадок"
            .
          end.
          when 'is_PM':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Президентский Мониторинг"
            .
          end.
        END CASE.
    END.
    if available buf_BatchProcess then do:
      assign
        buf_temp-autotask.task-date = buf_BatchProcess.BP_ExecSysDate
        buf_temp-autotask.task-time = buf_BatchProcess.BP_ExecSysTimeInt
      .
      if buf_temp-autotask.task-date < v-c-date
        or ( buf_temp-autotask.task-date = v-c-date
             and buf_BatchProcess.BP_ExecSysTimeInt < v-c-time
           )
      then do:
        assign
        buf_temp-autotask.overtime = YES
        .
      end.
      else do:
        if buf_temp-autotask.overtime = YES then do:
          assign
          buf_temp-autotask.overtime = NO
          .
        end.
      end.
    end.
    else do:
      assign
      buf_temp-autotask.overtime = YES
      buf_temp-autotask.task-date = ?
      buf_temp-autotask.task-time = ?
      .
    end.
    find first buf-c_BatchProcess no-lock
      where buf-c_BatchProcess.BP_Status   = 'N':U
        and buf-c_BatchProcess.BP_Type     = 'autosuz':U
        and buf-c_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf-c_BatchProcess.CharKey_Two <> "auto":U
      no-error
    .
    if available buf-c_BatchProcess then do:
      assign
        buf_temp-autotask.corr = "!!!":U
      .
    end.
    else do:
      assign
      buf_temp-autotask.corr = "":U
      .
    end.
    assign
    buf_temp-autotask.date-time = string(buf_temp-autotask.task-date, "99/99/9999") + chr(32) +
                                  string(buf_temp-autotask.task-time, "HH:MM")
   .
  if p-db-num = 0 then do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Status   = 'N':U
        and buf_BatchProcess.BP_Type     = 'autocbnk':U
        and buf_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf_BatchProcess.CharKey_Two = "auto":U
      no-error
    .
    FIND FIRST buf_temp-autotask WHERE
              buf_temp-autotask.db-num = buf_db.db-num
        AND buf_temp-autotask.task-type = 'autocbnk':U NO-ERROR.
    IF NOT AVAILABLE buf_temp-autotask THEN DO:
        CREATE buf_temp-autotask.
        ASSIGN
        buf_temp-autotask.db-num = buf_db.db-num
        buf_temp-autotask.task-type = 'autocbnk':U
        .
        case buf_temp-autotask.task-type:
          when 'autonws':U then do:
            assign
            buf_temp-autotask.task-name = "Новости"
            .
          end.
          when 'autoarh':U then do:
            assign
            buf_temp-autotask.task-name = "Архивы"
            .
          end.
          when 'autoexp':U then do:
            assign
            buf_temp-autotask.task-name = "Экспорт"
            .
          end.
          when 'autooxml':U then do:
            assign
            buf_temp-autotask.task-name = "OpenXML"
            .
          end.
          when 'autogcd':U then do:
            assign
            buf_temp-autotask.task-name = "Прием инф. с касс"
            .
          end.
          when 'autosale':U then do:
            assign
            buf_temp-autotask.task-name = "Обработка продаж"
            .
          end.
          when 'autosuz':U then do:
            assign
            buf_temp-autotask.task-name = "Отчеты"
            .
          end.
          when 'autocbnk':U then do:
            assign
            buf_temp-autotask.task-name = "Эксп/имп в КЛИЕНТ-БАНК"
            .
          end.
          when 'autofree':U then do:
            assign
            buf_temp-autotask.task-name = "Произвольные задания"
            .
          end.
          when 'sktsrv':U then do:
            assign
            buf_temp-autotask.task-name = "Сокет-Сервер"
            .
          end.
          when 'mercury':U then do:
            assign
            buf_temp-autotask.task-name = "Меркурий"
            .
          end.
          when 'hddtest':U then do:
            assign
            buf_temp-autotask.task-name = "Мониторинг HDD"
            .
          end.
          when 'is_motp':U then do:
            assign
            buf_temp-autotask.task-name = "ИС МОТП"
            .
          end.
          when 'is_diadoc':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Диадок"
            .
          end.
          when 'is_PM':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Президентский Мониторинг"
            .
          end.
        END CASE.
    END.
    if available buf_BatchProcess then do:
      assign
        buf_temp-autotask.task-date = buf_BatchProcess.BP_ExecSysDate
        buf_temp-autotask.task-time = buf_BatchProcess.BP_ExecSysTimeInt
      .
      if buf_temp-autotask.task-date < v-c-date
        or ( buf_temp-autotask.task-date = v-c-date
             and buf_BatchProcess.BP_ExecSysTimeInt < v-c-time
           )
      then do:
        assign
        buf_temp-autotask.overtime = YES
        .
      end.
      else do:
        if buf_temp-autotask.overtime = YES then do:
          assign
          buf_temp-autotask.overtime = NO
          .
        end.
      end.
    end.
    else do:
      assign
      buf_temp-autotask.overtime = YES
      buf_temp-autotask.task-date = ?
      buf_temp-autotask.task-time = ?
      .
    end.
    find first buf-c_BatchProcess no-lock
      where buf-c_BatchProcess.BP_Status   = 'N':U
        and buf-c_BatchProcess.BP_Type     = 'autocbnk':U
        and buf-c_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf-c_BatchProcess.CharKey_Two <> "auto":U
      no-error
    .
    if available buf-c_BatchProcess then do:
      assign
        buf_temp-autotask.corr = "!!!":U
      .
    end.
    else do:
      assign
      buf_temp-autotask.corr = "":U
      .
    end.
    assign
    buf_temp-autotask.date-time = string(buf_temp-autotask.task-date, "99/99/9999") + chr(32) +
                                  string(buf_temp-autotask.task-time, "HH:MM")
   .
  end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Status   = 'N':U
        and buf_BatchProcess.BP_Type     = 'autofree':U
        and buf_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf_BatchProcess.CharKey_Two = "auto":U
      no-error
    .
    FIND FIRST buf_temp-autotask WHERE
              buf_temp-autotask.db-num = buf_db.db-num
        AND buf_temp-autotask.task-type = 'autofree':U NO-ERROR.
    IF NOT AVAILABLE buf_temp-autotask THEN DO:
        CREATE buf_temp-autotask.
        ASSIGN
        buf_temp-autotask.db-num = buf_db.db-num
        buf_temp-autotask.task-type = 'autofree':U
        .
        case buf_temp-autotask.task-type:
          when 'autonws':U then do:
            assign
            buf_temp-autotask.task-name = "Новости"
            .
          end.
          when 'autoarh':U then do:
            assign
            buf_temp-autotask.task-name = "Архивы"
            .
          end.
          when 'autoexp':U then do:
            assign
            buf_temp-autotask.task-name = "Экспорт"
            .
          end.
          when 'autooxml':U then do:
            assign
            buf_temp-autotask.task-name = "OpenXML"
            .
          end.
          when 'autogcd':U then do:
            assign
            buf_temp-autotask.task-name = "Прием инф. с касс"
            .
          end.
          when 'autosale':U then do:
            assign
            buf_temp-autotask.task-name = "Обработка продаж"
            .
          end.
          when 'autosuz':U then do:
            assign
            buf_temp-autotask.task-name = "Отчеты"
            .
          end.
          when 'autocbnk':U then do:
            assign
            buf_temp-autotask.task-name = "Эксп/имп в КЛИЕНТ-БАНК"
            .
          end.
          when 'autofree':U then do:
            assign
            buf_temp-autotask.task-name = "Произвольные задания"
            .
          end.
          when 'sktsrv':U then do:
            assign
            buf_temp-autotask.task-name = "Сокет-Сервер"
            .
          end.
          when 'mercury':U then do:
            assign
            buf_temp-autotask.task-name = "Меркурий"
            .
          end.
          when 'hddtest':U then do:
            assign
            buf_temp-autotask.task-name = "Мониторинг HDD"
            .
          end.
          when 'is_motp':U then do:
            assign
            buf_temp-autotask.task-name = "ИС МОТП"
            .
          end.
          when 'is_diadoc':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Диадок"
            .
          end.
          when 'is_PM':U then do:
            assign
            buf_temp-autotask.task-name = "ИС Президентский Мониторинг"
            .
          end.
        END CASE.
    END.
    if available buf_BatchProcess then do:
      assign
        buf_temp-autotask.task-date = buf_BatchProcess.BP_ExecSysDate
        buf_temp-autotask.task-time = buf_BatchProcess.BP_ExecSysTimeInt
      .
      if buf_temp-autotask.task-date < v-c-date
        or ( buf_temp-autotask.task-date = v-c-date
             and buf_BatchProcess.BP_ExecSysTimeInt < v-c-time
           )
      then do:
        assign
        buf_temp-autotask.overtime = YES
        .
      end.
      else do:
        if buf_temp-autotask.overtime = YES then do:
          assign
          buf_temp-autotask.overtime = NO
          .
        end.
      end.
    end.
    else do:
      assign
      buf_temp-autotask.overtime = YES
      buf_temp-autotask.task-date = ?
      buf_temp-autotask.task-time = ?
      .
    end.
    find first buf-c_BatchProcess no-lock
      where buf-c_BatchProcess.BP_Status   = 'N':U
        and buf-c_BatchProcess.BP_Type     = 'autofree':U
        and buf-c_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf-c_BatchProcess.CharKey_Two <> "auto":U
      no-error
    .
    if available buf-c_BatchProcess then do:
      assign
        buf_temp-autotask.corr = "!!!":U
      .
    end.
    else do:
      assign
      buf_temp-autotask.corr = "":U
      .
    end.
    assign
    buf_temp-autotask.date-time = string(buf_temp-autotask.task-date, "99/99/9999") + chr(32) +
                                  string(buf_temp-autotask.task-time, "HH:MM")
   .
    IF NOT v-start THEN DO:
        br-autotask:REFRESH() IN FRAME autopush.
    END.
END PROCEDURE.
PROCEDURE set-row-color :
define variable iFGColor AS INTEGER NO-UNDO.
  define variable iBGColor AS INTEGER NO-UNDO.
  IF temp-autotask.overtime THEN DO:
      ASSIGN
        iFGColor = RED_COLOR
        iBGColor = WHITE_COLOR
      .
    end.
    ELSE do:
      ASSIGN
        iFGColor = Black_COLOR
        iBGColor = White_COLOR
      .
    end.
    ASSIGN
      temp-autotask.date-time:FGCOLOR IN BROWSE BR-autotask = iFGColor
      temp-autotask.date-time:BGCOLOR IN BROWSE BR-autotask = iBGColor
    .
END PROCEDURE.
PROCEDURE write-new-bp :
define input parameter p-task-type as   character    no-undo .
  define input parameter p-db-num    like ub.db.db-num no-undo .
  if transaction then do:
    message
      vss-workfile vss-revision vss-description skip
      "Недопустимо вызывать процедуру из транзакции!" skip
      view-as alert-box error .
  end.
  block_bp:
  do
  on error undo, return error
  :
    define buffer buf_BatchProcess for ub.BatchProcess .
    define buffer buf_sys-ctrl     for ub.sys-ctrl .
    define variable v-curr-date as date      no-undo .
    define variable v-curr-time as integer   no-undo .
    define variable v-date      as date      no-undo .
    define variable v-time      as integer   no-undo .
    define variable v-log       as logical   no-undo .
    define variable v-cancel    as logical   no-undo .
    define variable v-msg       as character no-undo .
    define variable v-str       as character no-undo .
    do for buf_BatchProcess
    on error undo, return error return-value
    :
      find first buf_sys-ctrl no-lock .
      find first buf_BatchProcess
        where buf_BatchProcess.BP_Status   = 'N':U
          and buf_BatchProcess.BP_Type     = p-task-type
          and buf_BatchProcess.CharKey_One = string( p-db-num )
          and buf_BatchProcess.CharKey_Two = "manual":U
        no-error
      .
      if available buf_BatchProcess then do:
        message "Изменение времени запуска уже производилось." skip
                "Установлено:" string( buf_BatchProcess.BP_ExecSysDate, "99.99.9999") buf_BatchProcess.BP_ExecSysTime skip
                "Вы действительно хотите его изменить?"
                view-as alert-box question buttons yes-no update v-log.
      end.
      else do:
        assign
          v-log = true
        .
      end.
    end.
    if v-log = false then do:
      assign
        v-msg = "Время очередного сеанса не изменено!"
      .
      undo, leave block_bp.
    end.
    assign
      v-str = get-str-type( p-task-type )
    .
    if v-str = ? then do:
      message vss-workfile vss-revision vss-description skip
        "НЕТ ОБРАБОТКИ АТРИБУТА" p-task-type
        view-as alert-box error.
      return error.
    end.
    case p-task-type :
      when 'autoarh':U
      then do:
        run adm/arc-shdp.w
          (input  buf_sys-ctrl.db-num
          ,input  p-task-type
          ,input  -1
          ,output v-cancel
          ) no-error .
        if error-status :error
        then do:
          message vss-workfile vss-revision vss-description skip
            "Ошибка при создании (редактировании) атрибута!"
            view-as alert-box error.
          return error.
        end.
        if v-cancel = true
        then do:
          assign
            v-msg = "Время очередного сеанса не изменено!"
          .
          undo, leave block_bp.
        end.
      end.
      when 'autoexp':U
      then do:
        run bge/bge-shdp.w
          (input  parparentproc
          ,input  buf_sys-ctrl.db-num
          ,input  p-task-type
          ,input  -1
          ,output v-cancel
          ) no-error.
        if error-status :error then do:
          message vss-workfile vss-revision vss-description skip
            "Ошибка при создании (редактировании) атрибута!"
            view-as alert-box error.
          return error.
        end.
        if v-cancel = TRUE then do:
          assign
            v-msg = "Время очередного сеанса не изменено!"
          .
          undo, leave block_bp.
        end.
      end.
      when 'autogcd':U
      then do:
        run str/gcd-shdp.w
          ( input  parparentproc
           ,input  buf_sys-ctrl.db-num
           ,input  p-task-type
           ,input  -1
           ,output v-cancel
          ) no-error.
        if error-status :error then do:
          message vss-workfile vss-revision vss-description skip
            "Ошибка при создании (редактировании) атрибута!"
            view-as alert-box error.
          return error.
        end.
        if v-cancel = TRUE then do:
          assign
            v-msg = "Время очередного сеанса не изменено!"
          .
          undo, leave block_bp.
        end.
      end.
      when 'autosale':U
      then do:
        run str/sal-shdp.w
          ( input parparentproc
           ,input  buf_sys-ctrl.db-num
           ,input  p-task-type
           ,input  -1
           ,output v-cancel
          ) no-error.
        if error-status :error then do:
          message vss-workfile vss-revision vss-description skip
            "Ошибка при создании (редактировании) атрибута!"
            view-as alert-box error.
          return error.
        end.
        if v-cancel = TRUE then do:
          assign
            v-msg = "Время очередного сеанса не изменено!"
          .
          undo, leave block_bp.
        end.
      end.
      when 'autosuz':U
      then do:
        run str/suz-shdp.w
          (input parparentproc
          ,input  buf_sys-ctrl.db-num
          ,input  p-task-type
          ,input  -1
          ,output v-cancel
          ) no-error .
        if error-status :error
        then do:
          message vss-workfile vss-revision vss-description skip
            "Ошибка при создании (редактировании) атрибута!"
            view-as alert-box error.
          return error.
        end.
        if v-cancel = true
        then do:
          assign
            v-msg = "Время очередного сеанса не изменено!"
          .
          undo, leave block_bp.
        end.
      end.
      when 'autocbnk':U
      then do:
          define variable v-params        as character    no-undo.
          define variable v-object-list        as character    no-undo.
          define variable v-doc-type-list      as character    no-undo.
          define variable v-hsch-list          as character    no-undo.
          define variable v-csch-list          as character    no-undo.
          define variable v-date-list          as character    no-undo.
        run bge/clb-shdp.w (
                         input parparentproc
                        ,input p-curr-host-code
                        ,input 'shd':U
                        ,input  buf_sys-ctrl.db-num
                        ,input  p-task-type
                        ,input  -1
                        ,input ?
                        ,output v-cancel
                        ,output v-params
                        ,output v-object-list
                        ,output v-doc-type-list
                        ,output v-date-list
                        ,output v-hsch-list
                        ,output v-csch-list
                      ) no-error.
        if error-status :error then do:
          message vss-workfile vss-revision vss-description skip
            "Ошибка при создании (редактировании) атрибута!"
            view-as alert-box error.
          return error.
        end.
        if v-cancel = TRUE then do:
          assign
            v-msg = "Время очередного сеанса не изменено!"
          .
          undo, leave block_bp.
        end.
      end.
      when 'is_PM':U
      then do:
        run adm/isPM-shdp.w
          (input  buf_sys-ctrl.db-num
          ,input  p-task-type
          ,input  -1
          ,output v-cancel
          ) no-error.
        if error-status :error
        then do:
          message vss-workfile vss-revision vss-description skip
            "Ошибка при создании (редактировании) атрибута!"
            view-as alert-box error.
          return error.
        end.
        if v-cancel = TRUE then do:
          assign
            v-msg = "Время очередного сеанса не изменено!"
          .
          undo, leave block_bp.
        end.
      end .
      when 'autofree':U
      then do:
        define variable v-free-id as character no-undo .
        define variable v-value as character no-undo .
        define buffer buf_schedule-attr for ub.schedule-attr.
        run adm/freeshdp.w (
                         input parparentproc
                        ,input p-curr-host-code
                        ,input p-curr-obj-type
                        ,input p-curr-obj-code
                        ,input 'shd':U
                        ,input  buf_sys-ctrl.db-num
                        ,input  p-task-type
                        ,input  -1
                        ,input ?
                        ,input-output v-free-id
                        ,output v-cancel
                        ,output v-params
                      ) no-error.
        if error-status :error then do:
          message vss-workfile vss-revision vss-description skip
            "Ошибка при создании (редактировании) атрибута!"
            view-as alert-box error.
          return error.
        end.
        if v-cancel = TRUE then do:
          assign
            v-msg = "Время очередного сеанса не изменено!"
          .
          undo, leave block_bp.
        end.
        else do:
          run schedule-attr-get-free-props in this-procedure (input v-free-id, output v-value).
          do transaction
          on error undo, return error return-value
          :
            for each buf_schedule-attr where
                    buf_schedule-attr.cre-db-num = buf_sys-ctrl.db-num
                AND buf_schedule-attr.task-type = p-task-type
                AND buf_schedule-attr.task-num = - 1
                and buf_schedule-attr.attr-code begins 'schd-free-id':U + chr(4)
            on error undo, return error error-status:get-message(1) :
              delete buf_schedule-attr.
            end.
          end.
          run schedule-attr-write in this-procedure (
                                                       input string(p-db-num)
                                                      ,input p-task-type
                                                      ,input - 1
                                                      ,input ('schd-free-id':U + chr(4) + v-free-id)
                                                      ,input v-value ).
        end.
      end.
    end.
    run cur-time in this-procedure
      ( output v-curr-date
       ,output v-curr-time
      ) no-error.
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
        "Ошибка при определении текущей даты!"
        view-as alert-box error.
      return error.
    end.
    assign
      v-date = v-curr-date
      v-time = v-curr-time
    .
    block_ed:
    do while true
    on error undo, return error
    :
      run adm/d-ed-d-t.w ( input-output v-date
                      ,input-output v-time
                    ) no-error .
      if error-status :error then do:
        message vss-workfile vss-revision vss-description skip
          "Ошибка при редактировании даты!"
          view-as alert-box error.
        return error.
      end.
      if v-date = ?
        or v-time = ?
      then do:
        assign
          v-msg = "Время очередного сеанса не изменено!"
        .
        undo, leave block_bp.
      end.
      if v-date > v-curr-date
        or ( v-date = v-curr-date
             and v-time >= v-curr-time
           )
      then do:
        leave block_ed.
      end.
      else do:
        message "Время очередного сеанса не может быть меньше текущего!"
          view-as alert-box error.
      end.
    end.
    run push-abtpr in this-procedure
      ( input parparentproc
       ,input p-db-num
       ,input p-task-type
       ,input "manual":U
       ,input v-date
       ,input v-time
      ) no-error .
    if error-status :error
    then do:
      message vss-workfile vss-revision vss-description skip
        "Ошибка при записи времени внеочередного запуска!" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error.
      return error.
    end.
    assign
      v-msg = substitute( "Команда на запуск &1 для БД &2 отправлена", v-str, p-db-num )
              + chr(10) + "и должна быть обработана в течении минуты."
    .
  end.
  if v-msg <> "":U then do:
    message v-msg
      view-as alert-box information.
  end.
  return.
END PROCEDURE.
