define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выгрузка в систему АТД".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO .
DEFINE INPUT PARAMETER p-curr-host-code LIKE ub.sysconf.host-code NO-UNDO .
DEFINE INPUT PARAMETER p-curr-obj-type  LIKE ub.clients.obj-type NO-UNDO .
DEFINE INPUT PARAMETER p-curr-obj-code  LIKE ub.clients.obj-code NO-UNDO .
define input parameter p_mode as character no-undo.
define input parameter p_cre-db-num as integer no-undo.
define input parameter p_task-type as character no-undo.
define input parameter p_task-num as integer no-undo.
DEFINE INPUT PARAMETER p-action         AS CHARACTER    NO-UNDO.
DEFINE OUTPUT PARAMETER p-cancel        AS LOGICAL      NO-UNDO.
DEFINE OUTPUT PARAMETER p-params        AS CHARACTER    NO-UNDO.
define buffer buf_clients   for ub.clients.
define buffer buf_shift-obj for ub.shift-obj.
define variable d_sht-start    as date      no-undo.
define variable i_sht-start    as integer   no-undo.
define variable d_sht-end      as date      no-undo.
define variable i_sht-end      as integer   no-undo.
define variable p-region       as character no-undo.
define variable c-dir          as character no-undo.
define variable dir_crt        as logical.
define variable v-host-name    as character no-undo.
define variable v-obj-list     as character no-undo.
define variable v-param-type   as character no-undo.
define variable v-param-list   as character no-undo.
define variable ii             as integer   no-undo.
define variable v-entry        as character no-undo.
define variable c_sel_esys     as character no-undo.
define variable l_ok           as logical   no-undo.
define variable c_shift-list   as character no-undo.
define variable par-type       as character no-undo.
define stream StreamLog.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON Btn_Obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .86.
DEFINE BUTTON Btn_Save
     LABEL "Сохранить"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON Btn_sht-from
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .86.
DEFINE BUTTON Btn_sht-to
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .86.
DEFINE BUTTON Btn_Start
     LABEL "Запустить"
     SIZE 15 BY 1.14.
DEFINE VARIABLE EDITOR-obj AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 36 BY 3.76 NO-UNDO.
DEFINE VARIABLE FILL-IN-Dir AS CHARACTER FORMAT "X(256)":U
     LABEL "Директория"
     VIEW-AS FILL-IN
     SIZE 40.4 BY 1 NO-UNDO.
DEFINE BUTTON b-dir
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .86.
DEFINE VARIABLE FILL-IN-sht-from-d AS DATE FORMAT "99/99/99":U
     LABEL "Смены с"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-sht-from-n AS INTEGER FORMAT "->9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-sht-to-d AS DATE FORMAT "99/99/99":U
     LABEL "По"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-sht-to-n AS INTEGER FORMAT "->9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE RADIO-SET-Objects AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "По фирме", 1,
"По объектам", 2
     SIZE 14.6 BY 2.62 NO-UNDO.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 59.4 BY 4.24.
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 59.4 BY 2.
DEFINE FRAME Dialog-Frame
     Btn_Save AT ROW 1.52 COL 2
     Btn_Start AT ROW 1.52 COL 2 WIDGET-ID 2
     Btn_Cancel AT ROW 1.52 COL 46.2
     FILL-IN-sht-from-d AT ROW 3 COL 10.4 COLON-ALIGNED WIDGET-ID 30
     FILL-IN-sht-from-n AT ROW 3 COL 21.8 COLON-ALIGNED NO-LABEL WIDGET-ID 38
     Btn_sht-from AT ROW 3 COL 28.4 WIDGET-ID 34
     FILL-IN-sht-to-d AT ROW 3 COL 38.8 COLON-ALIGNED WIDGET-ID 32
     FILL-IN-sht-to-n AT ROW 3 COL 50.4 COLON-ALIGNED NO-LABEL WIDGET-ID 42
     Btn_sht-to AT ROW 3 COL 56.8 WIDGET-ID 36
     EDITOR-obj AT ROW 5 COL 25 NO-LABEL WIDGET-ID 8
     RADIO-SET-Objects AT ROW 5.24 COL 4.6 NO-LABEL WIDGET-ID 4
     Btn_Obj AT ROW 6.76 COL 19 WIDGET-ID 24
     FILL-IN-Dir AT ROW 9.86 COL 14.6 COLON-ALIGNED WIDGET-ID 16
     b-dir AT ROW 9.86 COL 58 WIDGET-ID 22
     RECT-2 AT ROW 4.76 COL 2.6 WIDGET-ID 50
     RECT-5 AT ROW 9.38 COL 2.6 WIDGET-ID 56
     SPACE(0.59) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выгрузка в систему анализов треков данных"
         DEFAULT-BUTTON Btn_Save CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       EDITOR-obj:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
    APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-dir IN FRAME Dialog-Frame
DO:
  system-dialog get-dir c-dir.
  FILL-IN-Dir:screen-value in frame Dialog-Frame = c-dir.
END.
ON CHOOSE OF Btn_Obj IN FRAME Dialog-Frame
DO:
    define variable v-exclude-obj-list as character no-undo.
    define variable v-user-select      as logical   no-undo.
    define variable v-object-available as logical   no-undo.
    RADIO-SET-Objects:screen-value = "2".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_clear in this-procedure  .
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-object-available
  ) no-error .
    if error-status :error then
    do:
        message vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры gbl/usobjava.i" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error.
        undo, return no-apply.
    end.
    if v-object-available = true then
    do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_append in this-procedure
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  )  .
    end.
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
    if v-user-select <> true then
    do:
        message "Объект не выбран" view-as alert-box information.
        return no-apply.
    end.
    v-obj-list = "".
    EDITOR-obj:screen-value = "".
    for each userobjs_temp-user-obj:
        v-obj-list = v-obj-list + userobjs_temp-user-obj.obj-type + chr(44) +
            string(userobjs_temp-user-obj.obj-code) + chr(4).
        find first buf_clients where buf_clients.obj-code = userobjs_temp-user-obj.obj-code
            and buf_clients.obj-type = userobjs_temp-user-obj.obj-type no-lock no-error.
        EDITOR-obj:screen-value = EDITOR-obj:screen-value +
            (if buf_clients.obj-name <> '' then buf_clients.obj-name
            else userobjs_temp-user-obj.obj-type + string(userobjs_temp-user-obj.obj-code))
            + "," + chr(13).
    end.
END.
ON CHOOSE OF Btn_Save IN FRAME Dialog-Frame
DO:
    assign
        FILL-IN-Dir
        RADIO-SET-Objects
        FILL-IN-sht-from-d
        FILL-IN-sht-from-n
        FILL-IN-sht-to-d
        FILL-IN-sht-to-n
        .
    if FILL-IN-sht-from-d > FILL-IN-sht-to-d
    or (FILL-IN-sht-from-d = FILL-IN-sht-to-d and FILL-IN-sht-from-n > FILL-IN-sht-to-n)
    then do :
        message "Смены выбраны не верно!" view-as alert-box.
        return no-apply .
    end.
    FILL-IN-Dir = right-trim(FILL-IN-Dir,'/\') + '\'.
    file-info:file-name = FILL-IN-Dir.
    if file-info:file-type = ? then
    do:
        message substitute("Директории &1 не существует.",FILL-IN-Dir) skip
            "Создать?" view-as alert-box warning buttons yes-no update dir_crt.
        if dir_crt then
        do:
            os-create-dir value(FILL-IN-Dir).
            if os-error <> 0 then
            do:
                message substitute("Невозможно создать директорию &1",FILL-IN-Dir) view-as alert-box error.
                leave.
            end.
        end.
        else leave.
    end.
    else
    do:
        if not (file-info:file-type begins "D":U) then
        do:
            message substitute("&1 не является директорией.",FILL-IN-Dir) view-as alert-box error.
            leave.
        end.
    end.
    v-param-list = FILL-IN-Dir  + chr(4)  +
                   string(RADIO-SET-Objects)  + chr(4)  +
                   p-region .
    run attach-attr-to-schedule-line in this-procedure ( INPUT v-param-list ).
    run schedule-attr-write in this-procedure (input p_cre-db-num,
        input p_task-type,
        input p_task-num,
        input 'schedule-param-list':U,
        input v-param-list).
    run schedule-attr-write in this-procedure (input p_cre-db-num,
        input p_task-type,
        input p_task-num,
        input 'schedule-obj-list':U,
        input v-obj-list).
        message "Параметры сохранены!" view-as alert-box information.
    apply "go".
END.
ON CHOOSE OF Btn_sht-from IN FRAME Dialog-Frame
DO:
    run str/sht-all.w (parparentproc,
        v-cntxt-obj-type,
        v-cntxt-obj-code,
        "b-sel",
        "obj",
        v-cntxt-obj-type,
        v-cntxt-obj-code,
        "",
        input-output c_shift-list) no-error.
    if error-status:error then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при выборе смены"  skip
            error-status :get-message( 1 ) skip
            return-value skip
            view-as alert-box error .
        return no-apply.
    end.
    if c_shift-list =  "":U then
    do:
        return no-apply.
    end.
    find first buf_shift-obj where recid (buf_shift-obj) = integer (c_shift-list) no-lock.
    FILL-IN-sht-from-d:screen-value = string(buf_shift-obj.shift-date) no-error.
    FILL-IN-sht-from-n:screen-value = string(buf_shift-obj.shift-num) no-error.
END.
ON CHOOSE OF Btn_sht-to IN FRAME Dialog-Frame
DO:
    run str/sht-all.w (parparentproc,
        v-cntxt-obj-type,
        v-cntxt-obj-code,
        "b-sel",
        "obj",
        v-cntxt-obj-type,
        v-cntxt-obj-code,
        "",
        input-output c_shift-list) no-error.
    if error-status:error then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при выборе смены"  skip
            error-status :get-message( 1 ) skip
            return-value skip
            view-as alert-box error .
        return no-apply.
    end.
    if c_shift-list =  "":U then
    do:
        return no-apply.
    end.
    find first buf_shift-obj where recid (buf_shift-obj) = integer (c_shift-list) no-lock.
    FILL-IN-sht-to-d:screen-value = string(buf_shift-obj.shift-date) no-error.
    FILL-IN-sht-to-n:screen-value = string(buf_shift-obj.shift-num) no-error.
END.
ON CHOOSE OF Btn_Start IN FRAME Dialog-Frame
DO:
    assign
        FILL-IN-Dir
        RADIO-SET-Objects
        FILL-IN-sht-from-d
        FILL-IN-sht-from-n
        FILL-IN-sht-to-d
        FILL-IN-sht-to-n
    .
    if FILL-IN-sht-from-d > FILL-IN-sht-to-d
    or (FILL-IN-sht-from-d = FILL-IN-sht-to-d and FILL-IN-sht-from-n > FILL-IN-sht-to-n)
    then do :
        message "Смены выбраны не верно!" view-as alert-box.
        return no-apply .
    end.
    FILL-IN-Dir = right-trim(FILL-IN-Dir,'/\') + '\'.
    file-info:file-name = FILL-IN-Dir.
    if file-info:file-type = ? then
    do:
        message substitute("Директории &1 не существует.",FILL-IN-Dir) skip
            "Создать?" view-as alert-box warning buttons yes-no update dir_crt.
        if dir_crt then
        do:
            os-create-dir value(FILL-IN-Dir).
            if os-error <> 0 then
            do:
                message substitute("Невозможно создать директорию &1",FILL-IN-Dir) view-as alert-box error.
                leave.
            end.
        end.
        else leave.
    end.
    else
    do:
        if not (file-info:file-type begins "D":U) then
        do:
            message substitute("&1 не является директорией.",FILL-IN-Dir) view-as alert-box error.
            leave.
        end.
    end.
    if RADIO-SET-Objects = 1 then
    do:
        for each buf_clients no-lock where buf_clients.host-code = v-cntxt-host-code-obj:
            if buf_clients.stts <> 0 then next.
            find first userobjs_temp-user-obj where  userobjs_temp-user-obj.obj-code = buf_clients.obj-code and   userobjs_temp-user-obj.obj-type = buf_clients.obj-type no-lock no-error.
            if not available userobjs_temp-user-obj
            then do:
                create userobjs_temp-user-obj.
                assign
                    userobjs_temp-user-obj.obj-code = buf_clients.obj-code
                    userobjs_temp-user-obj.obj-type = buf_clients.obj-type.
            end.
        end.
    end.
    assign
        d_sht-start = date(FILL-IN-sht-from-d)
        i_sht-start = integer(FILL-IN-sht-from-n)
        d_sht-end   = date(FILL-IN-sht-to-d)
        i_sht-end   = integer(FILL-IN-sht-to-n)
    .
    run waitfram-show in this-procedure ( input "Идет выгрузка в систему анализа треков данных. Ждите..." ).
    run bge/bge-exp-ATD.p (input table userobjs_temp-user-obj,
        input FILL-IN-Dir,
        input this-procedure:handle,
        input d_sht-start,
        input i_sht-start,
        input d_sht-end,
        input i_sht-end,
        input p-region,
        input "run"
        ) no-error.
    if error-status:error then
    do:
        message return-value + error-status:get-message(1).
    end.
    run waitfram-hide in this-procedure .
    message "Выгрузка завершена" view-as alert-box .
    apply "go".
END.
ON VALUE-CHANGED OF RADIO-SET-Objects IN FRAME Dialog-Frame
DO:
        for each userobjs_temp-user-obj:
            delete userobjs_temp-user-obj.
        end.
        case RADIO-SET-Objects :screen-value in frame Dialog-frame:
            when "1" then
                do:
                    EDITOR-obj:screen-value = v-host-name.
                    hide Btn_Obj in frame Dialog-Frame.
                    for each userobjs_temp-user-obj:
                        delete userobjs_temp-user-obj.
                    end.
                    v-obj-list = 'орг':U + chr(44) + string(v-cntxt-host-code-obj).
                end.
            when "2" then
                do:
                    display Btn_Obj with frame Dialog-Frame.
                    create userobjs_temp-user-obj.
                    assign
                        userobjs_temp-user-obj.obj-code = v-cntxt-obj-code
                        userobjs_temp-user-obj.obj-type = v-cntxt-obj-type.
                    v-obj-list = userobjs_temp-user-obj.obj-type + chr(44) + string(userobjs_temp-user-obj.obj-code) + chr(4).
                    find first buf_clients where buf_clients.obj-type = userobjs_temp-user-obj.obj-type
                        and buf_clients.obj-code = userobjs_temp-user-obj.obj-code no-lock no-error.
                    EDITOR-obj:screen-value in frame Dialog-frame = if buf_clients.obj-name <> '' then buf_clients.obj-name
                    else userobjs_temp-user-obj.obj-type + string(userobjs_temp-user-obj.obj-code).
                end.
        end case.
    END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
    THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
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
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'atd-reg'
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  Yes
  ,output p-region
  ,output par-type
  ) NO-ERROR .
    if error-status:error or trim(p-region) = "" then  return error .
    RUN enable_UI.
    RUN my-enable.
    WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY FILL-IN-sht-from-d FILL-IN-sht-from-n FILL-IN-sht-to-d
          FILL-IN-sht-to-n EDITOR-obj RADIO-SET-Objects FILL-IN-Dir
      WITH FRAME Dialog-Frame.
  ENABLE RECT-2 RECT-5 Btn_Save Btn_Start Btn_Cancel FILL-IN-sht-from-d
         FILL-IN-sht-from-n Btn_sht-from FILL-IN-sht-to-d FILL-IN-sht-to-n
         Btn_sht-to EDITOR-obj RADIO-SET-Objects Btn_Obj FILL-IN-Dir  b-dir
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE my-enable :
define variable i as integer init 0 no-undo.
define variable ii as integer  init 0 no-undo.
    define variable v-name-nom as char      no-undo.
    define variable v-name-pit as char      no-undo.
    case p_mode:
        when "run" then
            do:
                hide Btn_Save in frame Dialog-Frame.
            end.
        when "shd" then
            do:
                hide Btn_Start FILL-IN-sht-from-d FILL-IN-sht-from-n FILL-IN-sht-to-d
                    FILL-IN-sht-to-n Btn_sht-from Btn_sht-to in frame Dialog-Frame.
                run schedule-attr-value in this-procedure (input p_cre-db-num,
                    input p_task-type,
                    input p_task-num,
                    input 'schedule-param-list':U,
                    output v-param-list,
                    output v-param-type).
                if v-param-list <> "" then
                do:
                    FILL-IN-Dir = entry(1,v-param-list,chr(4)) .
                    RADIO-SET-Objects = integer(entry(2,v-param-list,chr(4)) ).
                    p-region    = entry(3,v-param-list,chr(4)) .
                    display FILL-IN-Dir
                        RADIO-SET-Objects
                         with frame Dialog-Frame .
                end.
                run schedule-attr-value in this-procedure (input p_cre-db-num,
                    input p_task-type,
                    input p_task-num,
                    input 'schedule-obj-list':U,
                    output v-obj-list,
                    output v-param-type).
                if v-obj-list <> "" then
                do:
                    for each userobjs_temp-user-obj:
                        delete userobjs_temp-user-obj.
                    end.
                    if v-obj-list begins 'орг':U then
                    do:
                        find first buf_clients where buf_clients.obj-type = entry(1, v-obj-list, chr(44))
                            and buf_clients.obj-code = integer(entry(2, v-obj-list, chr(44))) no-lock no-error.
                        if available(buf_clients) then
                            EDITOR-obj:screen-value = if buf_clients.obj-name <> '' then buf_clients.obj-name
                            else buf_clients.obj-type + string(buf_clients.obj-code).
                        RADIO-SET-Objects = 1.
                        display RADIO-SET-Objects with frame Dialog-Frame.
                    end.
                    else
                    do:
                        EDITOR-obj:screen-value = "".
                        do ii = 1 to num-entries(v-obj-list, chr(4)) on error undo, next:
                            v-entry = entry(ii, v-obj-list, chr(4)).
                            find first buf_clients where buf_clients.obj-type = entry(1, v-entry, chr(44))
                                and buf_clients.obj-code = integer(entry(2, v-entry, chr(44))) no-lock no-error.
                            if available buf_clients then
                            do:
                                EDITOR-obj:screen-value = EDITOR-obj:screen-value +
                                    (if buf_clients.obj-name <> '' then buf_clients.obj-name
                                    else buf_clients.obj-type + string(buf_clients.obj-code))
                                    + "," + chr(13).
                            end.
                        end.
                        RADIO-SET-Objects = 2.
                        display RADIO-SET-Objects with frame Dialog-Frame.
                    end.
                end.
            end.
    end case.
end procedure.
PROCEDURE write-log-and-file :
    define input parameter p-tab-position as integer no-undo.
    define input parameter p-file-name as char no-undo.
    define input parameter p-log-level as integer no-undo.
    define input parameter p-log-string as char no-undo.
    output stream StreamLog to value(p-file-name) append.
    put stream StreamLog unformatted chr(10).
    put stream StreamLog unformatted cur-time-string-sec() " " p-log-string.
    output stream StreamLog close.
end procedure.
PROCEDURE attach-attr-to-schedule-line :
    DEFINE INPUT PARAMETER p-param-list AS CHARACTER NO-UNDO.
    define buffer buf_schedule      for schedule.
    define buffer buf_schedule-attr for schedule-attr.
    define buffer lock-batchprocess for ub.batchprocess.
    run gbl/lock-prc.p
        (input 'schd':U
        ,input 'exp-atd':U
        ,input 0
        ,input 0
        ,input '':U
        ,input ""
        ,input ""
        ,input (
        "Сохранение параметров выгрузки в систему АТД "
        )
        ,input yes
        ,buffer lock-batchprocess
        ) no-error .
    find first buf_schedule no-lock
        where buf_schedule.task-type   = p_task-type
        and buf_schedule.cre-db-num  = INTEGER(p_cre-db-num)
        and buf_schedule.task-num    = p_task-num
        no-error.
    if not available buf_schedule
        and (  p_task-type   <> 'autofree':U
        or p_cre-db-num <> p_cre-db-num
        or p_task-num    <> -1 )
        then
    do:
        message
            vss-workfile vss-revision vss-description
            skip
            "Не найдена строка расписания."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            view-as alert-box error.
        undo, return error .
    end.
    run schedule-attr-write in this-procedure (
        input INTEGER(p_cre-db-num)
        , input p_task-type
        , input p_task-num
        , input 'schedule-param-list':U
        , input p-param-list
        ).
END PROCEDURE.
