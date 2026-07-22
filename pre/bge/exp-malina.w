DEFINE NEW GLOBAL SHARED VARIABLE appSrvUtils AS HANDLE                NO-UNDO.
IF NOT VALID-HANDLE(appSrvUtils) THEN
  RUN adecomm/as-utils.w PERSISTENT SET appSrvUtils.
THIS-PROCEDURE:ADD-SUPER-PROCEDURE(appSrvUtils).
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выгрузка информации в систему Малина".
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
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO .
DEFINE INPUT PARAMETER p-curr-host-code LIKE ub.sysconf.host-code NO-UNDO .
DEFINE INPUT PARAMETER p-curr-obj-type  LIKE ub.clients.obj-type NO-UNDO .
DEFINE INPUT PARAMETER p-curr-obj-code  LIKE ub.clients.obj-code NO-UNDO .
DEFINE INPUT PARAMETER p-mode           AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-db-num-char    AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER p-task-type      AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER p-task-num       AS INTEGER      NO-UNDO.
DEFINE INPUT PARAMETER p-action         AS CHARACTER    NO-UNDO.
DEFINE OUTPUT PARAMETER p-cancel        AS LOGICAL      NO-UNDO.
DEFINE OUTPUT PARAMETER p-params        AS CHARACTER    NO-UNDO.
define buffer buf_clients for ub.clients.
define variable c-dir as character no-undo.
define variable v-host-name as character no-undo.
define variable v-obj-list as character no-undo.
define variable v-param-list as character no-undo.
define variable v-param-type as character no-undo.
define variable ii as integer no-undo.
define variable v-entry as character no-undo.
define stream StreamLog.
DEFINE BUTTON b-close AUTO-END-KEY
     LABEL "Отменить"
     SIZE 15 BY 1.13.
DEFINE BUTTON b-dir
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON b-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON b-save
     LABEL "Сохранить"
     SIZE 15 BY 1.13.
DEFINE BUTTON b-start
     LABEL "Запустить"
     SIZE 15 BY 1.13.
DEFINE VARIABLE e-obj AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 42.5 BY 4.71 NO-UNDO.
DEFINE VARIABLE v-category AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Категория тов.класс-ра"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE v-category-2 AS CHARACTER FORMAT "X(256)":U
     LABEL "Категория для локаций"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE v-company AS INTEGER FORMAT "999":U INITIAL 9
     LABEL "Идентификатор компании"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE v-diapmax AS INTEGER FORMAT "999":U INITIAL 99
     VIEW-AS FILL-IN
     SIZE 5.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-diapmin AS INTEGER FORMAT "999":U INITIAL 0
     LABEL "Диапазон пакетов"
     VIEW-AS FILL-IN
     SIZE 5.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-directory AS CHARACTER FORMAT "X(256)":U
     LABEL "Директория"
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.
DEFINE VARIABLE v-prefix AS CHARACTER FORMAT "X(256)":U INITIAL "639300,275"
     LABEL "Префикс для карт Малина"
     VIEW-AS FILL-IN
     SIZE 42.5 BY 1 NO-UNDO.
DEFINE VARIABLE rs-obj AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "По фирме", 1,
"По объектам", 2
     SIZE 17 BY 2.13 NO-UNDO.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 26.5 BY 3.75.
DEFINE VARIABLE t-location AS LOGICAL INITIAL yes
     LABEL "Локации"
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.
DEFINE VARIABLE v-chk AS LOGICAL INITIAL no
     LABEL "Чеки"
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.
DEFINE VARIABLE v-goods AS LOGICAL INITIAL yes
     LABEL "Товарный классификатор"
     VIEW-AS TOGGLE-BOX
     SIZE 25 BY .83 NO-UNDO.
DEFINE FRAME gDialog
     b-start AT ROW 1.25 COL 2 WIDGET-ID 8
     b-save AT ROW 1.25 COL 38
     b-close AT ROW 1.25 COL 54.5
     v-company AT ROW 3.25 COL 25 COLON-ALIGNED WIDGET-ID 10
     v-goods AT ROW 3.25 COL 44 WIDGET-ID 28
     v-chk AT ROW 4.42 COL 44 WIDGET-ID 30
     v-category AT ROW 4.5 COL 25 COLON-ALIGNED WIDGET-ID 38
     t-location AT ROW 5.5 COL 44 WIDGET-ID 46
     v-category-2 AT ROW 5.75 COL 25 COLON-ALIGNED WIDGET-ID 48
     v-diapmin AT ROW 7.25 COL 25 COLON-ALIGNED WIDGET-ID 40
     v-diapmax AT ROW 7.25 COL 33.5 COLON-ALIGNED NO-LABEL WIDGET-ID 42
     v-directory AT ROW 8.5 COL 25 COLON-ALIGNED WIDGET-ID 12
     b-dir AT ROW 8.5 COL 67 WIDGET-ID 22
     v-prefix AT ROW 9.75 COL 25 COLON-ALIGNED WIDGET-ID 6
     rs-obj AT ROW 12.5 COL 2 NO-LABEL WIDGET-ID 34
     b-obj AT ROW 12.5 COL 19.5 WIDGET-ID 24
     e-obj AT ROW 12.5 COL 27 NO-LABEL WIDGET-ID 32
     "-" VIEW-AS TEXT
          SIZE 1.5 BY .67 AT ROW 7.5 COL 33.25 WIDGET-ID 44
     RECT-2 AT ROW 3 COL 43 WIDGET-ID 14
     SPACE(0.87) SKIP(11.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выгрузка информации в систему ~"Малина~""
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-close WIDGET-ID 100.
ASSIGN
       FRAME gDialog:SCROLLABLE       = FALSE
       FRAME gDialog:HIDDEN           = TRUE.
ASSIGN
       e-obj:READ-ONLY IN FRAME gDialog        = TRUE.
ON WINDOW-CLOSE OF FRAME gDialog
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-dir IN FRAME gDialog
DO:
  system-dialog get-dir c-dir.
  v-directory:screen-value in frame gDialog = c-dir.
END.
ON CHOOSE OF b-obj IN FRAME gDialog
DO:
    define variable v-exclude-obj-list as character no-undo.
    define variable v-user-select as logical no-undo.
    define variable v-object-available as logical no-undo.
    rs-obj:screen-value = "2".
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-object-available
  ) no-error .
    if error-status :error then do:
        message vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры gbl/usobjava.i" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error.
        undo, return no-apply.
    end.
    if v-object-available = true then do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_append in this-procedure
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  )  .
    end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
    if v-user-select <> true then do:
      message "Объект не выбран" view-as alert-box information.
      return no-apply.
    end.
    v-obj-list = "".
    e-obj:screen-value = "".
    for each userobjs_temp-user-obj:
        v-obj-list = v-obj-list + userobjs_temp-user-obj.obj-type + chr(44) +
            string(userobjs_temp-user-obj.obj-code) + chr(4).
            find first buf_clients where buf_clients.obj-code = userobjs_temp-user-obj.obj-code
                and buf_clients.obj-type = userobjs_temp-user-obj.obj-type no-lock no-error.
            e-obj:screen-value = e-obj:screen-value +
                (if buf_clients.obj-name <> '' then buf_clients.obj-name
                else userobjs_temp-user-obj.obj-type + string(userobjs_temp-user-obj.obj-code))
                + "," + chr(13).
    end.
END.
ON CHOOSE OF b-save IN FRAME gDialog
DO:
    DEFINE VARIABLE l-dircrt AS LOGICAL.
    ASSIGN
        v-company
        v-category
        v-category-2
        v-diapmin
        v-diapmax
        v-directory
        v-prefix
        v-goods
        v-chk
        rs-obj
        t-location.
    v-directory = right-trim(v-directory,'/\') + '\'.
    file-info:file-name = v-directory.
    if file-info:file-type = ? then do:
        message substitute("Директории &1 не существует.",v-directory) skip
        "Создать?" view-as alert-box warning buttons yes-no update l-dircrt.
        if l-dircrt then do:
            os-create-dir value(v-directory).
            if os-error <> 0 then do:
                message substitute("Невозможно создать директорию &1",v-directory) view-as alert-box error.
                leave.
            end.
        end.
        else leave.
    end.
    else do:
        if not (file-info:file-type begins "D":U) then do:
            message substitute("&1 не является директорией.",v-directory) view-as alert-box error.
            leave.
        end.
    end.
    if v-diapmin >= v-diapmax then do:
        message "Неверно указаны границы диапазона пакетов" view-as alert-box error.
        leave.
    end.
    v-param-list = string(v-company) + chr(4) +
                   v-directory + chr(4) +
                   v-prefix + chr(4) +
                   string(v-goods:CHECKED) + chr(4) +
                   string(v-chk)  + chr(4) +
                   string(v-category) + chr(4) +
                   string(v-diapmin) + chr(4) +
                   string(v-diapmax) + chr(4) +
                   string(t-location) + chr(4) + string(v-category-2) +
                   chr(4).
    run attach-attr-to-schedule-line in this-procedure ( INPUT v-param-list ).
    run schedule-attr-write in this-procedure (input p-db-num-char,
                                               input p-task-type,
                                               input p-task-num,
                                               input 'schedule-obj-list':U,
                                               input v-obj-list).
    message "Параметры сохранены!" view-as alert-box information.
    apply "go".
END.
ON CHOOSE OF b-start IN FRAME gDialog
DO:
  DEFINE VARIABLE l-dircrt AS LOGICAL NO-UNDO.
  define variable h-par as widget-handle  no-undo.
  DEFINE variable loghandle AS HANDLE no-undo.
  DEFINE VARIABLE v-objects AS CHARACTER NO-UNDO.
  ASSIGN
    v-company
    v-directory
    v-prefix
    v-category
    v-category-2
    v-diapmin
    v-diapmax
    .
  v-directory = RIGHT-TRIM(v-directory,'/\') + '\'.
  FILE-INFO:FILE-NAME = v-directory.
  IF FILE-INFO:FILE-TYPE = ? THEN DO:
    MESSAGE SUBSTITUTE("Директории &1 не существует.",v-directory) SKIP
        "Создать?" VIEW-AS ALERT-BOX WARNING BUTTONS YES-NO UPDATE l-dircrt.
        IF l-dircrt THEN DO:
            OS-CREATE-DIR VALUE(v-directory).
            IF OS-ERROR <> 0 THEN DO:
                MESSAGE SUBSTITUTE("Невозможно создать директорию &1",v-directory) VIEW-AS ALERT-BOX ERROR.
                LEAVE.
            END.
        END.
        ELSE LEAVE.
    END.
    ELSE DO:
        IF NOT (FILE-INFO:FILE-TYPE BEGINS "D":U) THEN DO:
            MESSAGE SUBSTITUTE("&1 не является директорией.",v-directory) VIEW-AS ALERT-BOX ERROR.
            LEAVE.
        END.
    END.
    if rs-obj = 1 then do:
        for each buf_clients no-lock where buf_clients.host-code = v-cntxt-host-code-obj:
            if buf_clients.stts <> 0 then next.
            create userobjs_temp-user-obj.
            assign
                userobjs_temp-user-obj.obj-code = buf_clients.obj-code
                userobjs_temp-user-obj.obj-type = buf_clients.obj-type.
        end.
    end.
    if v-diapmin >= v-diapmax then do:
        message "Неверно указаны границы диапазона пакетов" view-as alert-box error.
        leave.
    end.
    run bge\exp-malinap.p ( table userobjs_temp-user-obj,
                            v-company,
                            v-directory,
                            v-prefix,
                            v-goods:CHECKED,
                            v-chk:CHECKED,
                            v-category,
                            v-diapmin,
                            v-diapmax,
                            this-procedure:handle,
                            t-location:CHECKED,
                            v-category-2
                       ) .
    apply "go".
END.
ON VALUE-CHANGED OF rs-obj IN FRAME gDialog
DO:
    case rs-obj :screen-value in frame gDialog:
        when "1" then do:
            e-obj:screen-value = v-host-name.
            hide b-obj in frame gDialog.
            for each userobjs_temp-user-obj:
                delete userobjs_temp-user-obj.
            end.
            v-obj-list = 'орг':U + chr(44) + string(v-cntxt-host-code-obj).
        end.
        when "2" then do:
            display b-obj with frame gDialog.
            create userobjs_temp-user-obj.
            assign
            userobjs_temp-user-obj.obj-code = v-cntxt-obj-code
            userobjs_temp-user-obj.obj-type = v-cntxt-obj-type.
            v-obj-list = userobjs_temp-user-obj.obj-type + chr(44) + string(userobjs_temp-user-obj.obj-code) + chr(4).
            find first buf_clients where buf_clients.obj-type = userobjs_temp-user-obj.obj-type
                                     and buf_clients.obj-code = userobjs_temp-user-obj.obj-code no-lock no-error.
            e-obj:screen-value in frame gDialog = if buf_clients.obj-name <> '' then buf_clients.obj-name
                                                  else userobjs_temp-user-obj.obj-type + string(userobjs_temp-user-obj.obj-code).
        end.
    end case.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME gDialog:PARENT eq ?
THEN FRAME gDialog:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
             trim(error-status :get-message(4))
             trim(error-status :get-message(5))
      view-as alert-box warning.
      assign
          v-host-name = 'орг':U + string(v-cntxt-host-code-obj).
  end.
  RUN enable_UI.
  RUN my-enable.
  WAIT-FOR GO OF FRAME gDialog.
END.
RUN disable_UI.
PROCEDURE adm-create-objects :
END PROCEDURE.
PROCEDURE attach-attr-to-schedule-line :
DEFINE INPUT PARAMETER p-param-list AS CHARACTER NO-UNDO.
  define buffer buf_schedule      for schedule.
  define buffer buf_schedule-attr for schedule-attr.
  define buffer lock-batchprocess for ub.batchprocess.
  run gbl/lock-prc.p
    (input 'schd':U
    ,input 'exp-malina':U
    ,input 0
    ,input 0
    ,input '':U
    ,input ""
    ,input ""
    ,input (
    "Сохранение параметров Малина"
    )
    ,input yes
    ,buffer lock-batchprocess
    ) no-error .
  FIND FIRST buf_schedule-attr NO-LOCK WHERE
    buf_schedule-attr.task-type   = p-task-type
    and buf_schedule-attr.cre-db-num = INTEGER(p-db-num-char)
    and buf_schedule-attr.attr-code = ('schd-free-id':U + chr(4) + 'exp-malina') NO-ERROR.
  IF AVAILABLE  buf_schedule-attr
    AND buf_schedule-attr.task-num <> p-task-num
    AND buf_schedule-attr.task-num <> - 1
    and p-task-num <> - 1
    THEN
  DO:
    MESSAGE
      substitute("Уже есть расписание сохранения параметров Малина для БД &1&2" +
      "номер расписания &3"
      ,buf_schedule-attr.cre-db-num
      ,chr(10)
      ,buf_schedule-attr.task-num)
      VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
  find first buf_schedule no-lock
    where buf_schedule.task-type   = p-task-type
    and buf_schedule.cre-db-num  = INTEGER(p-db-num-char)
    and buf_schedule.task-num    = p-task-num
    no-error.
  if not available buf_schedule
    and (  p-task-type   <> 'autofree':U
    or p-db-num-char <> p-db-num-char
    or p-task-num    <> -1 )
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
    input INTEGER(p-db-num-char)
    , input p-task-type
    , input p-task-num
    , input 'schedule-param-list':U
    , input p-param-list
    ).
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME gDialog.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-company v-goods v-chk v-category t-location v-category-2 v-diapmin
          v-diapmax v-directory v-prefix rs-obj e-obj
      WITH FRAME gDialog.
  ENABLE RECT-2 b-start b-save b-close v-company v-goods v-chk v-category
         t-location v-category-2 v-diapmin v-diapmax v-directory b-dir v-prefix
         rs-obj b-obj e-obj
      WITH FRAME gDialog.
  VIEW FRAME gDialog.
END PROCEDURE.
PROCEDURE get-host-name :
do on error undo, return error:
define output parameter p-host-name as character no-undo.
    find first buf_clients no-lock where buf_clients.obj-type = 'орг':U
                                     and buf_clients.obj-code = v-cntxt-host-code-obj no-error.
    if not available buf_clients then do:
        message vss-workfile vss-revision vss-description skip
          "Не удалось найти текущую фирму" skip
          return-value skip
          trim(error-status :get-message(1))
          trim(error-status :get-message(2))
          trim(error-status :get-message(3))
          trim(error-status :get-message(4))
          trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error.
    end.
    else do:
        p-host-name = buf_clients.obj-name.
    end.
END.
END PROCEDURE.
PROCEDURE my-enable :
ASSIGN
    rs-obj:screen-value in frame gDialog = "2"
    v-directory:screen-value in frame gDialog = session:temp-directory.
case p-mode:
    when "run" then do:
        create userobjs_temp-user-obj.
    assign
        userobjs_temp-user-obj.obj-code = v-cntxt-obj-code
        userobjs_temp-user-obj.obj-type = v-cntxt-obj-type.
    v-obj-list = userobjs_temp-user-obj.obj-type + chr(44) + string(userobjs_temp-user-obj.obj-code) + chr(4).
    find first buf_clients where buf_clients.obj-type = userobjs_temp-user-obj.obj-type
                             and buf_clients.obj-code = userobjs_temp-user-obj.obj-code no-lock no-error.
    e-obj:screen-value in frame gDialog = if buf_clients.obj-name <> '' then buf_clients.obj-name
                                          else userobjs_temp-user-obj.obj-type + string(userobjs_temp-user-obj.obj-code).
        hide b-save in frame gDialog.
    end.
    when "shd" then do:
        hide b-start in frame gDialog.
        run schedule-attr-value in this-procedure (input p-db-num-char,
                                                   input p-task-type,
                                                   input p-task-num,
                                                   input 'schedule-param-list':U,
                                                   output v-param-list,
                                                   output v-param-type).
        if v-param-list <> "" then do:
            ASSIGN
                v-company = integer(entry(1,v-param-list,chr(4)))
                v-directory = entry(2,v-param-list,chr(4))
                v-prefix = entry(3,v-param-list,chr(4))
                v-goods = logical(entry(4,v-param-list,chr(4)))
                v-chk = logical(entry(5,v-param-list,chr(4)))
                v-category = integer(entry(6,v-param-list,chr(4)))
                v-diapmin = integer(entry(7,v-param-list,chr(4)))
                v-diapmax = integer(entry(8,v-param-list,chr(4)))
                t-location = logical(entry(9,v-param-list,chr(4)))
                v-category-2 = entry(10,v-param-list,chr(4))
                NO-ERROR.
            DISPLAY v-company WITH FRAME gDialog.
            DISPLAY v-directory WITH FRAME gDialog.
            DISPLAY v-prefix WITH FRAME gDialog.
            DISPLAY v-goods WITH FRAME gDialog.
            DISPLAY v-chk WITH FRAME gDialog.
            DISPLAY v-category WITH FRAME gDialog.
            DISPLAY v-category-2 WITH FRAME gDialog.
            DISPLAY v-diapmin WITH FRAME gDialog.
            DISPLAY v-diapmax
                    t-location
            WITH FRAME gDialog.
        end.
        run schedule-attr-value in this-procedure (input p-db-num-char,
                                                   input p-task-type,
                                                   input p-task-num,
                                                   input 'schedule-obj-list':U,
                                                   output v-obj-list,
                                                   output v-param-type).
        if v-obj-list <> "" then do:
            for each userobjs_temp-user-obj:
                delete userobjs_temp-user-obj.
            end.
            if v-obj-list begins 'орг':U then do:
                find first buf_clients where buf_clients.obj-type = entry(1, v-obj-list, chr(44))
                    and buf_clients.obj-code = integer(entry(2, v-obj-list, chr(44))) no-lock no-error.
                if available(buf_clients) then
                e-obj:screen-value = if buf_clients.obj-name <> '' then buf_clients.obj-name
                                     else buf_clients.obj-type + string(buf_clients.obj-code).
                rs-obj = 1.
                display rs-obj with frame gDialog.
            end.
            else do:
                e-obj:screen-value = "".
                do ii = 1 to num-entries(v-obj-list, chr(4)) on error undo, next:
                    v-entry = entry(ii, v-obj-list, chr(4)).
                    find first buf_clients where buf_clients.obj-type = entry(1, v-entry, chr(44))
                        and buf_clients.obj-code = integer(entry(2, v-entry, chr(44))) no-lock no-error.
                     if available buf_clients then do:
                         e-obj:screen-value = e-obj:screen-value +
                         (if buf_clients.obj-name <> '' then buf_clients.obj-name
                         else buf_clients.obj-type + string(buf_clients.obj-code))
                         + "," + chr(13).
                         create userobjs_temp-user-obj.
                         assign
                         userobjs_temp-user-obj.obj-type = buf_clients.obj-type
                         userobjs_temp-user-obj.obj-code = buf_clients.obj-code.
                     end.
                end.
                rs-obj = 2.
                display rs-obj with frame gDialog.
            end.
        end.
    end.
end case.
assign
    e-obj
    rs-obj
    v-directory.
END PROCEDURE.
PROCEDURE write-log-and-file :
define input parameter p-tab-position as integer no-undo.
define input parameter p-file-name as char no-undo.
define input parameter p-log-level as integer no-undo.
define input parameter p-log-string as char no-undo.
output stream StreamLog to value(p-file-name) append.
put stream StreamLog unformatted chr(10).
put stream StreamLog unformatted cur-time-string-sec() " " p-log-string.
output stream StreamLog close.
END PROCEDURE.
