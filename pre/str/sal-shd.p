block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-cre-db-num  as character    no-undo.
define input parameter p-task-type   as character    no-undo.
define input parameter p-task-num    as integer      no-undo.
define input parameter p-db-num      as integer      no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Обработка документов продаж по расписанию".
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
define  shared variable g#auto-pid           as integer   no-undo .
define  shared variable conn-par             as character no-undo .
define  shared variable g#auto-user-id       as character no-undo .
define  shared variable g#auto-user-login    as character no-undo .
define  shared variable g#auto-user-password as character no-undo .
define  shared variable v-socket             as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable auto-window-h     as handle    no-undo .
define  shared variable auto-log-msg-h    as handle    no-undo .
define  shared variable hand-log-msg-h    as handle    no-undo .
define  shared variable log-file-name     as character no-undo initial ? .
define  shared variable add-log-file-name as character no-undo initial ? .
define  shared variable writelogvalue     as character no-undo initial ? .
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
define stream LogStream .
define variable mNoTime as logical no-undo.
procedure write-to-log-notime :
  define input param i-str as character no-undo .
  mNoTime = yes.
  run write-to-log (i-str).
  mNoTime = no.
end.
procedure write-to-log :
  define input param p-str as character no-undo .
  do
  on error  undo, return error substitute( "&1 (write-to-log). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (write-to-log). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (write-to-log). endkey", vss-workfile )
  :
    define variable log-res        as logical   no-undo .
    define variable v-jj           as integer   no-undo .
    if    mNoTime
       or writelogvalue eq "AsyncProc"
    then
       p-str = substitute( "&1 (pid: &2) &3&4"   , g#auto-user-id, g#auto-pid,                        p-str, chr(10) ).
    else
       p-str = substitute( "&1 (pid: &2) &3 &4&5", g#auto-user-id, g#auto-pid, cur-time-string-sec(), p-str, chr(10) ).
    if auto-log-msg-h <> ? then do:
      log-res = auto-log-msg-h:move-to-eof( ) .
      log-res = auto-log-msg-h:insert-string( p-str ).
    end.
    if hand-log-msg-h <> ? then do:
      log-res = hand-log-msg-h:move-to-eof( ) .
      log-res = hand-log-msg-h:insert-string( p-str ).
    end.
    assign
      p-str = replace(p-str, (chr(10) + chr(13)), chr(10) )
      p-str = replace(p-str, (chr(13) + chr(10)), chr(10) )
      p-str = replace(p-str, chr(10), (chr(13) + chr(10)) )
    .
    if add-log-file-name <> ? then do:
      do v-jj = 1 to num-entries(add-log-file-name, chr(1)):
        run gbl/fileapnd.p
          ( input entry(v-jj, add-log-file-name, chr(1) )
          ,input p-str
          ,input 20
          ) no-error .
        if error-status:error then do:
          return error return-value .
        end.
      end.
    end.
    if writelogvalue eq "AsyncProc"
    then do:
       p-str = trim(p-str, (chr(13) + chr(10)) )
    .
       Publish "WriteLogAsunc" (p-str,yes).
    end.
    else if writelogvalue <> "yes" then do:
      run gbl/fileapnd.p
        ( input log-file-name
        ,input p-str
        ,input 20
        ) no-error .
      if error-status:error then do:
        return error return-value .
      end.
    end.
  end.
end procedure.
procedure write-to-screen :
  define input param p-str as character no-undo .
  do
  on error  undo, return error substitute( "&1 (write-to-screen). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (write-to-screen). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (write-to-screen). endkey", vss-workfile )
  :
    define variable log-res as logical no-undo.
    assign
      p-str = substitute( "&1 (pid: &2) &3 &4&5", g#auto-user-id, g#auto-pid, cur-time-string-sec(), p-str, chr(10) )
    .
    if auto-log-msg-h <> ?
    then do:
      log-res = auto-log-msg-h:move-to-eof( ) .
      log-res = auto-log-msg-h:insert-string( p-str ).
    end.
    if hand-log-msg-h <> ?
    then do:
      log-res = hand-log-msg-h:move-to-eof( ) .
      log-res = hand-log-msg-h:insert-string( p-str ).
    end.
  end.
end procedure.
procedure send-msg-to-email :
  define input  parameter p-subject      as character no-undo .
  define input  parameter p-text-err     as character no-undo .
  define input  parameter p-attach-files as character no-undo .
  do
  on error  undo, return error substitute( "&1 (send-msg-to-email). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (send-msg-to-email). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (send-msg-to-email). endkey", vss-workfile )
  :
    define variable v-tth             as handle    no-undo .
    define variable v-value-character as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as integer   no-undo .
    define variable v-value-logical   as logical   no-undo .
    define variable v-param-type      as character no-undo .
    define variable v-email       as character no-undo .
    define variable v-tmp-str     as character no-undo .
    define variable v-tmp1-str    as character no-undo .
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    delete object v-tth no-error.
    run adm/shattri.p
      ( input "get":U
       ,input  "":U
       ,input  0
       ,input  'auto-task':U
       ,input  'send-msg-to-email':U
       ,output v-value-character
       ,output v-value-date
       ,output v-value-decimal
       ,output v-value-integer
       ,output v-value-logical
       ,output v-param-type
       ,input-output table-handle v-tth
      ) no-error .
    if not error-status :error  then do:
      assign
        v-tmp-str = v-value-character
      .
    end.
    delete object v-tth no-error.
    assign
      v-tmp-str     = replace(v-tmp-str, (chr(10) + chr(13)), chr(44) )
      v-tmp-str     = replace(v-tmp-str, (chr(13) + chr(10)), chr(44) )
      v-tmp-str     = replace(v-tmp-str, chr(10), chr(44) )
      v-num-entries = num-entries( v-tmp-str, chr(44) )
      v-email       = "":U
    .
    do v-ind = 1 to v-num-entries
    :
      assign
        v-tmp1-str = entry( v-ind, v-tmp-str, chr(44) )
      .
      if trim( v-tmp1-str ) <> "":U then do:
        if v-email = "":U then do:
          assign
            v-email = v-tmp1-str
          .
        end.
        else do:
          assign
            v-email = v-email + chr(44) + v-tmp1-str
          .
        end.
      end.
    end.
    if v-email <> "":U then do:
      run gbl/sendmail.p
        ( input v-email
        , input p-subject
        , input p-text-err
        , input p-attach-files
        ) no-error .
      if error-status :error
        or return-value <> "":U
      then do:
        return error substitute( "&1 (send-msg-to-email). &2", vss-workfile, return-value ) .
      end.
    end.
  end.
end procedure.
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
define  temp-table temp-host no-undo
  field host-code like ub.store.host-code
  index xpk host-code
.
define  temp-table temp-obj no-undo
  field obj-type  like ub.clients.obj-type
  field obj-code  like ub.clients.obj-code
  field host-code like ub.store.host-code
  field db-num    like ub.clients.db-num
  index xpk  obj-type obj-code
  index xie1 host-code
  index xie2 db-num host-code
.
procedure init-temphost:
  define buffer buf_store   for ub.store .
  define buffer buf_shop    for ub.shop .
  define buffer buf_clients for ub.clients .
  define buffer buf_db for ub.db .
  define buffer buf_temp-host for temp-host .
  define buffer buf_temp-obj for temp-obj .
  do
  on error undo, return error return-value
  :
    for each buf_store
    on error undo, return error
    :
      find first buf_temp-host
        where buf_temp-host.host-code = buf_store.host-code
        no-error .
      if not available buf_temp-host
      then do:
        create buf_temp-host .
        assign
          buf_temp-host.host-code = buf_store.host-code
        .
      end.
      find first buf_clients no-lock
        where buf_clients.obj-type = 'скл':U
          and buf_clients.obj-code = buf_store.obj-code
        no-error .
      if not available buf_clients
      then do:
        message
          "Ошибка при поиске клиента" skip
          "Клиент" 'скл':U buf_store.obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      create buf_temp-obj .
      assign
        buf_temp-obj.obj-type  = 'скл':U
        buf_temp-obj.obj-code  = buf_store.obj-code
        buf_temp-obj.host-code = buf_store.host-code
        buf_temp-obj.db-num    = buf_clients.db-num
      .
    end.
    for each buf_shop
    on error undo, return error
    :
      find first buf_temp-host
        where buf_temp-host.host-code = buf_shop.host-code
        no-error .
      if not available buf_temp-host
      then do:
        create buf_temp-host .
        assign
          buf_temp-host.host-code = buf_shop.host-code
        .
      end.
      find first buf_clients no-lock
        where buf_clients.obj-type = 'маг':U
          and buf_clients.obj-code = buf_shop.obj-code
        no-error .
      if not available buf_clients then do:
        message
          "Ошибка при поиске клиента" skip
          "Клиент" 'маг':U buf_shop.obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      create buf_temp-obj .
      assign
        buf_temp-obj.obj-type  = 'маг':U
        buf_temp-obj.obj-code  = buf_shop.obj-code
        buf_temp-obj.host-code = buf_shop.host-code
        buf_temp-obj.db-num    = buf_clients.db-num
      .
    end.
  end.
end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-loc-counter as integer no-undo .
define variable v-counter-visible as logical no-undo .
define variable v-view-log as logical no-undo .
define stream auto2dia.
PROCEDURE write-log-and-file :
do
on error undo, return error
:
  define input parameter p-tab-position   as integer   no-undo.
  define input parameter p-file-name      as character no-undo .
  define input parameter p-log-level      as integer   no-undo .
  define input parameter p-log-string     AS CHARacter NO-UNDO.
  define variable v-jj as integer   no-undo .
  run write-to-screen in this-procedure( input ( fill( chr(32), p-tab-position) + p-log-string)) .
  if p-file-name <> '':U then do:
    do v-jj = 1 to num-entries(p-file-name, chr(1)):
      run  auto2dia-writefile in this-procedure (
                                      input entry(v-jj, p-file-name, chr(1))
                                      ,input p-log-level
                                      ,input (p-log-string + chr(10))
                                    ) no-error .
    end.
  end.
  if writelogvalue eq "AsyncProc"
  then
     run write-to-log in this-procedure( p-log-string) .
end.
END PROCEDURE.
PROCEDURE get-title :
do
on error undo, return error
:
define output parameter p-title     as character    no-undo.
end.
END PROCEDURE.
PROCEDURE set-title :
do
on error undo, return error
:
define input parameter p-title     as character    no-undo.
run write-to-log in this-procedure( input ( fill( chr(32), 15) + p-title)) .
end.
END PROCEDURE.
PROCEDURE get-counter-value :
do
on error undo, return error
:
define output parameter p-counter     as integer    no-undo.
    assign
    p-counter  = v-loc-counter
    .
end.
END PROCEDURE.
PROCEDURE set-counter-value :
do
on error undo, return error
:
define input parameter p-counter     as integer    no-undo.
    assign
    v-loc-counter = p-counter
    .
end.
END PROCEDURE.
PROCEDURE show-counter :
do
on error undo, return error
:
    assign
    v-counter-visible = true
    .
    process events.
end.
END PROCEDURE.
PROCEDURE hide-counter :
do
on error undo, return error
:
    assign
    v-counter-visible = false
    .
    run hide-message in parparentproc .
    process events.
end.
END PROCEDURE.
PROCEDURE write-counter :
do
on error undo, return error
:
define input parameter p-counter-string     as character    no-undo.
if v-counter-visible then
run write-message in parparentproc ( input p-counter-string) .
process events.
end.
END PROCEDURE.
PROCEDURE get-stop-state :
do
on error undo, return error
:
define output parameter p-stop-state    as logical      no-undo.
end.
END PROCEDURE.
PROCEDURE set-view-log :
do
on error undo, return error
:
define input parameter p-view-log     as logical    no-undo.
    assign
    v-view-log = p-view-log
    .
end.
END PROCEDURE.
PROCEDURE get-view-log :
do
on error undo, return error
:
define output parameter p-view-log     as logical    no-undo.
    assign
    p-view-log = v-view-log
    .
end.
END PROCEDURE.
PROCEDURE write-log :
do
on error undo, return error
:
define input parameter p-tab-position   as integer      no-undo.
define input parameter p-log-string     as character    no-undo.
run write-to-log in this-procedure( input ( fill( chr(32), 1  * p-tab-position)  +
                                    (IF p-log-string = "&Line" THEN FILL("-", 80)
                                    ELSE IF p-log-string = "&DLine" THEN FILL("=", 80)
                                    ELSE p-log-string))).
end.
END PROCEDURE.
procedure writelog :
do
on error undo, return error
:
define input parameter p-file-name AS CHAR     NO-UNDO.
define input parameter p-log-level AS INTEGER  NO-UNDO.
define input parameter p-log-string  AS CHAR     NO-UNDO.
  if p-file-name <> "" then
  run  auto2dia-Writefile in this-procedure (
                                    input p-file-name
                                  ,input p-log-level
                                  ,input p-log-string
                                ) no-error .
   process events.
end.
end procedure.
PROCEDURE auto2dia-writefile:
  define input parameter sFileName AS CHAR     NO-UNDO.
  define input parameter iLogLevel AS INTEGER  NO-UNDO.
  define input parameter sToWrite  AS CHAR     NO-UNDO.
  define variable v-SlashPos  as integer no-undo .
  define variable v-lDirName  as character no-undo .
  define variable v-lDirName2 as character no-undo .
  v-SlashPos  = maximum (  r-index(sFileName, "\"),  r-index(sFileName, "/")  ) .
  v-lDirName  = if v-SlashPos > 0 then substring (sFileName, 1, v-SlashPos - 1) else "".
  FILE-INFO:FILE-NAME = v-lDirName .
  v-lDirName2 = FILE-INFO:FULL-PATHNAME .
  if v-lDirName2 <> ? then do :
OUTPUT STREAM auto2dia TO VALUE(sFileName) APPEND.
    PUT STREAM auto2dia UNFORMATTED chr(10).
    PUT STREAM auto2dia UNFORMATTED (IF (iLogLevel = 0 OR sToWrite = "&DLine"
                                      OR sToWrite = "&Line") THEN "" ELSE
                                      cur-time-string-sec() + " ").
    PUT STREAM auto2dia UNFORMATTED
            (IF sToWrite = "&Line" THEN FILL("-", 80)
             ELSE IF sToWrite = "&DLine" THEN FILL("=", 80)
             ELSE sToWrite).
OUTPUT STREAM auto2dia CLOSE.
  end .
END PROCEDURE.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table tt0-info no-undo
field doc-code   like ub.trn-doc.doc-code
field artic      like ub.doc-line.artic
field prod-type  like ub.doc-line.prod-type
field prod-code  like ub.doc-line.prod-code
field prt-code  like ub.gds-dtl.prt-code
field obj-type   like ub.doc-line.obj-type
field obj-code   like ub.doc-line.obj-code
field error-message as character
field a-to-res as decimal
field was-res as decimal
field to-res as decimal
field is-res as decimal
field o-was-res as decimal
field o-to-res as decimal
field o-is-res as decimal
index pi is unique primary
obj-type
obj-code
artic
prod-type
prod-code
index iartic
artic
prod-type
prod-code
.
define NEW SHARED temp-table tt0-doc-line no-undo like lib-trn_ret-line.
define NEW SHARED temp-table tt0-gds-dtl  no-undo like ub.gds-dtl.
define NEW SHARED temp-table tt0-parts    no-undo like ub.parts.
define NEW SHARED temp-table temp-tpsi-clients  no-undo like ub.clients.
FUNCTION set-tpsi-doc-PS returns character( buffer buf_sale-doc for ub.sale-doc):
define variable v-ps as character no-undo .
assign
v-PS = substitute('@&1 для закрытия продажи &2 на &3&4&5товаров &6&5признаков &7'
                  , entry (lookup (buf_sale-doc.ext-doc-type, 'ee,ev,ie,es,iv':U), 'Межфирм.расход по ТПСИ,Внутр.расход по ТПСИ,Межфирм.приход по ТПСИ,Внутр.приход по ТПСИ':U)
                  , buf_sale-doc.out-code
                  , buf_sale-doc.obj-type
                  , buf_sale-doc.obj-code
                  , chr(4)
                  , buf_sale-doc.tot-lines
                  , buf_sale-doc.tot-dtl
                  ).
return v-Ps.
END FUNCTION.
procedure create-tt0-doc-line-gds-dtl :
define input parameter p-proprietor-obj-type like ub.trn-doc.obj-type no-undo .
define input parameter p-proprietor-obj-code like ub.trn-doc.obj-code no-undo .
define input parameter p-ext-doc-type        as character no-undo .
define input parameter p-doc-code            like ub.trn-doc.doc-code no-undo .
define input parameter p-artic               like ub.gds-dtl.artic no-undo .
define input parameter p-prod-type           like ub.gds-dtl.prod-type no-undo .
define input parameter p-prod-code           like ub.gds-dtl.prod-code no-undo .
define input parameter p-prt-code            like ub.gds-dtl.prt-code  no-undo .
define input parameter p-fact-qnty           like ub.gds-dtl.fact-qnty no-undo .
define output parameter p-was-gds-dtl-doc-qnty  like ub.gds-dtl.fact-qnty no-undo .
define output parameter p-gds-dtl-fact-qnty  like ub.gds-dtl.fact-qnty no-undo .
define parameter buffer b-doc-line           for ub.doc-line.
define parameter buffer b-gds-dtl            for ub.gds-dtl.
define parameter buffer buf_sale-doc for ub.sale-doc.
define variable old-qnty like ub.doc-line.fact-qnty no-undo .
define buffer other_doc-line for ub.doc-line.
define buffer other_gds-dtl for ub.gds-dtl.
  do
  on error undo, return error return-value
  :
    find first tt0-doc-line where
              tt0-doc-line.obj-type = p-proprietor-obj-type
          AND tt0-doc-line.obj-code = p-proprietor-obj-code
          AND tt0-doc-line.prod-type = p-prod-type
          AND tt0-doc-line.prod-code = p-prod-code
          AND tt0-doc-line.artic     = p-artic
          AND tt0-doc-line.ext-doc-type = p-ext-doc-type
          AND tt0-doc-line.status_      = 'нередакт':U no-error .
    if not available tt0-doc-line then do:
      create tt0-doc-line.
      buffer-copy b-doc-line
      except
      obj-type obj-code doc-code status_ ext-doc-type doc-qnty fact-qnty
      to tt0-doc-line
      assign
      tt0-doc-line.status_ = 'нередакт':U
      tt0-doc-line.ext-doc-type = p-ext-doc-type
      tt0-doc-line.obj-type = p-proprietor-obj-type
      tt0-doc-line.obj-code = p-proprietor-obj-code
      tt0-doc-line.doc-code = p-doc-code
      .
    end.
    if p-doc-code <> "":U then do:
      find first other_doc-line no-lock where
              other_doc-line.doc-code = p-doc-code
          AND  other_doc-line.artic    = p-artic
          AND  other_doc-line.prod-type = p-prod-type
          AND  other_doc-line.prod-code = p-prod-code no-error .
      if available other_doc-line then do:
        find first buf_sale-doc where buf_sale-doc.doc-code = other_doc-line.doc-code.
        assign
        tt0-doc-line.doc-qnty = other_doc-line.doc-qnty
        .
      end.
      else do:
        assign
        tt0-doc-line.doc-code = '':U
        .
      end.
    end.
    find first tt0-gds-dtl where
            tt0-gds-dtl.obj-type = p-proprietor-obj-type
        AND tt0-gds-dtl.obj-code = p-proprietor-obj-code
        AND tt0-gds-dtl.prod-type = p-prod-type
        AND tt0-gds-dtl.prod-code = p-prod-code
        AND tt0-gds-dtl.artic     = p-artic
        AND tt0-gds-dtl.prt-code  = p-prt-code  no-error .
    if not available tt0-gds-dtl then do:
      create tt0-gds-dtl.
      buffer-copy b-gds-dtl
      except
      obj-type obj-code doc-code doc-qnty fact-qnty
      to tt0-gds-dtl
      assign
      tt0-gds-dtl.obj-type = p-proprietor-obj-type
      tt0-gds-dtl.obj-code = p-proprietor-obj-code
      tt0-gds-dtl.doc-code = p-doc-code
      .
    end.
    if p-doc-code <> "":U then do:
        find first other_gds-dtl no-lock where
                other_gds-dtl.doc-code = p-doc-code
            AND  other_gds-dtl.artic    = p-artic
            AND  other_gds-dtl.prod-type    = p-prod-type
            AND  other_gds-dtl.prod-code    = p-prod-code
            AND  other_gds-dtl.prt-code    = p-prt-code no-error .
        if available other_gds-dtl then do:
          assign
          tt0-gds-dtl.doc-qnty = other_gds-dtl.doc-qnty
          .
        end.
        else do:
          assign
          tt0-gds-dtl.doc-code = '':U
          .
        end.
    end.
    assign
    old-qnty = tt0-gds-dtl.doc-qnty
    tt0-gds-dtl.fact-qnty = (if p-fact-qnty = ? then (- old-qnty) else (p-fact-qnty - tt0-gds-dtl.doc-qnty))
    tt0-doc-line.fact-qnty = tt0-doc-line.fact-qnty + (if p-fact-qnty = ? then (- old-qnty) else p-fact-qnty)
    p-gds-dtl-fact-qnty = tt0-gds-dtl.fact-qnty
    p-was-gds-dtl-doc-qnty = tt0-gds-dtl.doc-qnty
    .
  end.
end procedure.
procedure fill-tt-tpsi-table :
define input parameter p-doc-code  like ub.trn-doc.doc-code  no-undo .
define input parameter p-host-code like ub.trn-doc.host-code no-undo .
define input parameter p-obj-type  like ub.trn-doc.obj-type  no-undo .
define input parameter p-obj-code  like ub.trn-doc.obj-code  no-undo .
define variable v-proprietor-host-code      like ub.clients.host-code no-undo .
define variable v-proprietor-obj-type       like ub.clients.obj-type no-undo .
define variable v-proprietor-obj-code       like ub.clients.obj-code no-undo .
define variable v-ext-doc-type              like ub.trn-doc.ext-doc-type no-undo .
define variable v-gds-dtl-fact-qnty         like ub.gds-dtl.fact-qnty no-undo .
define variable v-was-gds-dtl-fact-qnty     like ub.gds-dtl.fact-qnty no-undo .
define buffer buf_goods for ub.goods.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_sale-doc for ub.sale-doc.
  do
  on error undo, return error
  :
    _doc-line:
    for each buf_Doc-line no-lock where
          buf_doc-line.doc-code = p-doc-code,
      first buf_goods no-lock where
          buf_goods.artic = buf_doc-line.artic
     AND  buf_goods.prod-type  = buf_doc-line.prod-type
     AND  buf_goods.prod-code  = buf_doc-line.prod-code,
        each buf_gds-dtl no-lock where
          buf_gds-dtl.doc-code = buf_doc-line.doc-code
      AND  buf_gds-dtl.artic    = buf_doc-line.artic
      AND  buf_gds-dtl.prod-type = buf_doc-line.prod-type
      AND  buf_gds-dtl.prod-code = buf_doc-line.prod-code:
      assign
      v-ext-doc-type = "":U.
      run tpsi-preselect-gds-proprietor in this-procedure (
                                                  input buf_goods.gds-code
                                                ,input g#db-num
                                                ,output v-proprietor-host-code
                                                ,output v-proprietor-obj-type
                                                ,output v-proprietor-obj-code ) no-error .
      if v-proprietor-host-code = p-host-code then do:
        assign
        v-ext-doc-type = 'ev':U .
      end.
      else do:
        assign
        v-ext-doc-type =  'ee':U .
      end.
      if  (v-proprietor-obj-type = p-obj-type
      AND v-proprietor-obj-code = p-obj-code)
      OR (v-proprietor-obj-type = "":U
      AND v-proprietor-obj-code = 0)
      OR v-proprietor-obj-code = ?
      then next _doc-line.
      find first buf_sale-doc no-lock where
                buf_sale-doc.inkas-code = p-doc-code
           AND buf_sale-doc.obj-type = v-proprietor-obj-type
           AND buf_sale-doc.obj-code = v-proprietor-obj-code
           AND buf_sale-doc.ext-doc-type = v-ext-doc-type
           no-error .
      run create-tt0-doc-line-gds-dtl  in this-procedure (
                                                           input v-proprietor-obj-type
                                                          ,input v-proprietor-obj-code
                                                          ,input v-ext-doc-type
                                                          ,input (if available buf_sale-doc then buf_sale-doc.doc-code else "":U)
                                                          ,input buf_doc-line.artic
                                                          ,input buf_Doc-line.prod-type
                                                          ,input buf_doc-line.prod-code
                                                          ,input buf_gds-dtl.prt-code
                                                          ,input 0
                                                          ,output v-was-gds-dtl-fact-qnty
                                                          ,output v-gds-dtl-fact-qnty
                                                          ,buffer buf_doc-line
                                                          ,buffer buf_gds-dtl
                                                          ,buffer buf_sale-doc
                                                        ).
    end.
  end.
end procedure.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure get-alias-type-price-obj :
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-prop-host-code like ub.sysconf.host-code no-undo .
define input parameter p-prop-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-prop-obj-code  like ub.clients.obj-code no-undo .
define output parameter p-ext-doc-type like ub.trn-doc.ext-doc-type no-undo .
define output parameter p-alias-type-price as character no-undo .
define output parameter p-price-obj-type like ub.clients.obj-type no-undo .
define output parameter p-price-obj-code like ub.clients.obj-code no-undo .
define variable v-mediat-obj-type           like ub.trn-doc.obj-type no-undo .
define variable v-mediat-obj-code           like ub.trn-doc.obj-code no-undo .
define variable v-mediat-objf               as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define buffer buf_trn-doc for ub.trn-doc.
  _main:
  do
  on error undo, return error return-value
  :
    run adm/shattri.p (
      input "get":U
      ,input  p-prop-obj-type
      ,input  p-prop-obj-code
      ,input  'alias-tpsi':U
      ,input  '':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
    if error-status:error
    then do:
      undo _main, return error substitute("Не удалось определить настройки МЕЖФИРМЕННОГО ИЛИ ВНУТРЕННЕГО ПЕРЕМЕЩЕНИЯ ЧУЖИХ ТОВАРОВ для &1&2"
                              , p-prop-obj-type
                              , p-prop-obj-code).
    end.
    find first thbjattr_thbj-attr where
              thbjattr_thbj-attr.obj-type = p-prop-obj-type
          and thbjattr_thbj-attr.obj-code = p-prop-obj-code
          and thbjattr_thbj-attr.upper-prop-code = 'alias-tpsi':U
          and thbjattr_thbj-attr.prop-code = 'alias-type-price':U no-error.
    if not available thbjattr_thbj-attr
    or thbjattr_thbj-attr.property-value-integer = 0 then do:
      undo _main, return error substitute("Не задано значение атрибута ТИП ЦЕНЫ МЕЖФИРМЕННОГО ИЛИ ВНУТРЕННЕГО ПЕРЕМЕЩЕНИЯ ЧУЖИХ ТОВАРОВ для &1&2"
                              , p-prop-obj-type
                              , p-prop-obj-code).
    end.
    assign
    p-alias-type-price = string(thbjattr_thbj-attr.property-value-integer).
    if p-prop-host-code = p-host-code
    and (p-alias-type-price = '':U
    or   p-alias-type-price <> '5':U)
    then  do:
      assign
      p-ext-doc-type = 'ev':U
      p-price-obj-type = p-obj-type
      p-price-obj-code = p-obj-code
      p-alias-type-price = '3':U
      .
    end.
    else do:
      if p-prop-host-code = p-host-code  then do:
        assign
        p-ext-doc-type = 'ev':U
        p-price-obj-type = p-obj-type
        p-price-obj-code = p-obj-code
        .
      end.
      else do:
        assign
        p-ext-doc-type = 'ee':U.
        assign
        v-mediat-obj-type = "":U
        v-mediat-obj-code = 0
        v-mediat-objf = "":U
        .
        if p-alias-type-price = '4':U then do:
          find first thbjattr_thbj-attr where
                    thbjattr_thbj-attr.obj-type = p-prop-obj-type
                and thbjattr_thbj-attr.obj-code = p-prop-obj-code
                and thbjattr_thbj-attr.upper-prop-code = 'alias-tpsi':U
                and thbjattr_thbj-attr.prop-code = 'alias-object-price':U no-error.
          if not available thbjattr_thbj-attr
          or thbjattr_thbj-attr.property-value-character = "":U then do:
            undo _main, return error substitute("Не найден объект-посредник для межфирменного перемещения ЧУЖИХ товаров с &1&2"
                                    , p-prop-obj-type
                                    , p-prop-obj-code).
          end.
          assign
          v-mediat-objf     = thbjattr_thbj-attr.property-value-character
          v-mediat-obj-type = entry(1, v-mediat-objf)
          v-mediat-obj-code = integer(entry(2, v-mediat-objf))
          no-error
          .
          if error-status:error then do:
            undo _main, return error substitute("Неверный формат атрибута ОБЪЕКТ-ПОСРЕДНИК для межфирменного перемещения ЧУЖИХ товаров для &1&2"
                                    , p-prop-obj-type
                                    , p-prop-obj-code).
          end.
        end.
        CASE p-alias-type-price:
          when '1':U then do:
            assign
            p-price-obj-type = p-prop-obj-type
            p-price-obj-code = p-prop-obj-code
            .
          end.
          when '2':U then do:
            assign
            p-price-obj-type = p-prop-obj-type
            p-price-obj-code = p-prop-obj-code
            .
          end.
          when '3':U
          or
          when '5':U
          then do:
            assign
            p-price-obj-type = p-obj-type
            p-price-obj-code = p-obj-code
            .
          end.
          when '4':U then do:
            assign
            p-price-obj-type = v-mediat-obj-type
            p-price-obj-code = v-mediat-obj-code
            .
          end.
        END CASE.
      end.
    end.
  end.
end procedure.
procedure write-tt0-info:
define input parameter p-artic as character no-undo .
define input parameter p-prod-type as character no-undo .
define input parameter p-prod-code as integer no-undo .
define input parameter p-prt-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-from-tpsi as logical no-undo .
define input parameter p-all-qnty as decimal no-undo .
define input parameter p-was-res as decimal no-undo .
define input parameter p-to-res as decimal no-undo .
define input parameter p-is-res as decimal no-undo .
define input parameter p-o-was-res as decimal no-undo .
define input parameter p-o-to-res as decimal no-undo .
define input parameter p-o-is-res as decimal no-undo .
define input parameter p-mess   as character no-undo .
define buffer buf_tt0-info for tt0-info.
  do
  on error undo, return error return-value
  :
    find first buf_tt0-info where
             buf_tt0-info.artic = p-artic
         and buf_tt0-info.prod-type = p-prod-type
         and buf_tt0-info.prod-code = p-prod-code
         and buf_tt0-info.prt-code = p-prt-code
         no-error .
    if not available buf_tt0-info then do:
      create buf_tt0-info.
      assign
      buf_tt0-info.artic = p-artic
      buf_tt0-info.prod-type = p-prod-type
      buf_tt0-info.prod-code = p-prod-code
      buf_tt0-info.prt-code  = p-prt-code
      buf_tt0-info.obj-type  = p-obj-type
      buf_tt0-info.obj-code  = p-obj-code
      buf_tt0-info.a-to-res  = ?
      buf_tt0-info.to-res    = ?
      buf_tt0-info.was-res   = ?
      buf_tt0-info.o-was-res = ?
      buf_tt0-info.o-to-res  = ?
      buf_tt0-info.o-is-res  = ?
      buf_tt0-info.is-res    = ?
      .
    end.
    assign
    buf_tt0-info.a-to-res  =
                              (if buf_tt0-info.a-to-res <> ?
                              and p-all-qnty = ?
                              then buf_tt0-info.a-to-res
                              else p-all-qnty)
    buf_tt0-info.was-res   = (if buf_tt0-info.was-res <> ?
                              and p-was-res = ?
                              then buf_tt0-info.was-res
                              else p-was-res)
    buf_tt0-info.to-res    = (if buf_tt0-info.to-res <> ?
                              and p-to-res = ?
                              then buf_tt0-info.to-res
                              else p-to-res)
    buf_tt0-info.is-res    = (if buf_tt0-info.is-res <> ?
                              and p-is-res = ?
                              then buf_tt0-info.is-res
                              else p-is-res)
    buf_tt0-info.o-was-res   = (if buf_tt0-info.o-was-res <> ?
                              and p-o-was-res = ?
                              then buf_tt0-info.o-was-res
                              else p-o-was-res)
    buf_tt0-info.o-to-res    = (if buf_tt0-info.o-to-res <> ?
                              and p-o-to-res = ?
                              then buf_tt0-info.o-to-res
                              else p-o-to-res)
    buf_tt0-info.o-is-res    = (if buf_tt0-info.o-is-res <> ?
                              and p-o-is-res = ?
                              then buf_tt0-info.o-is-res
                              else p-o-is-res)
    .
    assign
    buf_tt0-info.doc-code  = p-doc-code
    buf_tt0-info.error-message   = p-mess
    .
  end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table dtl-rests-mark no-undo
field artic like ub.gds-dtl.artic
field prod-type like ub.gds-dtl.prod-type
field prod-code like ub.gds-dtl.prod-code
index   pi  is primary
artic
prod-type
prod-code
.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define new shared temp-table temp-inkas no-undo like ub.inkas.
define variable v-curr-r-b as character no-undo init 'rubl':U.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure proc-step-100 :
define input parameter p-curr-obj-type    like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code    like ub.clients.obj-code no-undo .
define input parameter p-process-only-new as logical no-undo .
define input parameter p-finalize         as logical no-undo .
DEFINE VARIABLE compensed AS LOGICAL NO-UNDO.
DEFINE VARIABLE auto-comp AS LOGICAL NO-UNDO.
DEFINE VARIABLE autofbr AS LOGICAL NO-UNDO.
DEFINE VARIABLE one-curs AS LOGICAL NO-UNDO.
DEFINE VARIABLE restdish AS LOGICAL NO-UNDO.
DEFINE VARIABLE restingr AS LOGICAL NO-UNDO.
DEFINE VARIABLE resttpsi AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-is-tpsi-obj AS LOGICAL NO-UNDO.
DEFINE VARIABLE conf-attr AS character NO-UNDO.
DEFINE VARIABLE conf-par AS character NO-UNDO.
DEFINE VARIABLE par-type AS character NO-UNDO.
define variable v-parameter as character no-undo .
define variable v-is-wth as character no-undo .
define variable is-wth as logical   no-undo .
define variable sale-filter as logical no-undo .
define variable cas-shft    as logical no-undo init no.
define variable cas-curs    as logical no-undo init no.
define variable prcl-spl    as logical no-undo init no.
define variable pay-gds-algo as character no-undo.
define variable rdtaxcd     as INTEGER                  no-undo.
define variable exctaxcd    as INTEGER                  no-undo.
define variable factorrt    as decimal no-undo.
define variable btltaxcd    as INTEGER                  no-undo.
define variable p-day-only  as logical no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define buffer buf_inkas for ub.inkas.
DEFINE BUFFER buf_shop FOR ub.shop.
define buffer buf_trn-doc for ub.trn-doc.
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-wth':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-is-wth
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    or v-is-wth <> 'yes':u
    then do:
      assign
      is-wth = no
      .
    end.
    else do:
      is-wth = yes.
    end.
    FIND FIRST buf_shop NO-LOCK WHERE
              buf_shop.obj-code = p-curr-obj-code .
    run gbl/tpsi-obj.p ( input p-curr-obj-type
                        ,input p-curr-obj-code
                        ,output v-is-tpsi-obj) no-error .
    for each thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
    end.
    run adm/shattri.p (
        input "get":U
        ,input  p-curr-obj-type
        ,input  p-curr-obj-code
        ,input  'autosale':U
        ,input  "":U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    IF error-status:error then do:
      run write-to-log in this-procedure (
            input substitute("Ошибка при получении опций продажи НА ОБЪЕКТЕ &1&2:&3&4 &5"
              , p-curr-obj-type
              , p-curr-obj-code
              , chr(10)
              , error-status:get-message(1)
              , return-value )).
       undo, return.
    end.
    for each  thbjattr_thbj-attr where
              thbjattr_thbj-attr.obj-type = p-curr-obj-type
          and thbjattr_thbj-attr.obj-code = p-curr-obj-code
          and thbjattr_thbj-attr.upper-prop-code = 'autosale':U
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
      case thbjattr_thbj-attr.prop-code:
        when 'autocomp':U then do:
          auto-comp = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'autofbr':U then do:
          autofbr = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'one-curs':U then do:
          one-curs = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'restdish':U then do:
          restdish = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'restingr':U then do:
          restingr = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'resttpsi':U then do:
          resttpsi = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'prcl-spl':U then do:
          prcl-spl = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'pay-gds-algo':U then do:
          pay-gds-algo = thbjattr_thbj-attr.property-value-character.
        end.
        when 'sale-filter':U then do:
          sale-filter = thbjattr_thbj-attr.property-value-logical.
        end.
      end case.
      assign
      restdish = restdish and autofbr
      restingr = restingr and autofbr
      resttpsi = resttpsi and v-is-tpsi-obj
      .
    end.
    run adm/shattri.p (
        input "get":U
        ,input  p-curr-obj-type
        ,input  p-curr-obj-code
        ,input  'get-chk':U
        ,input  "":U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    IF error-status:error then do:
      run write-to-log in this-procedure (
            input substitute("Ошибка при получении опций закачик чеков НА ОБЪЕКТЕ &1&2:&3&4 &5"
              , p-curr-obj-type
              , p-curr-obj-code
              , chr(10)
              , error-status:get-message(1)
              , return-value )).
       undo, return.
    end.
    for each  thbjattr_thbj-attr where
              thbjattr_thbj-attr.obj-type = p-curr-obj-type
          and thbjattr_thbj-attr.obj-code = p-curr-obj-code
          and thbjattr_thbj-attr.upper-prop-code = 'get-chk':U
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
      case thbjattr_thbj-attr.prop-code:
        when 'cas-shft':U then do:
          assign
          cas-shft = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'cas-curs':U then do:
          assign
          cas-curs = thbjattr_thbj-attr.property-value-logical.
        end.
      end case.
    end.
    assign
    rdtaxcd  = integer('3':U)
    exctaxcd = integer('4':U)
    btltaxcd = integer('3':U).
    _inkas:
    for each buf_inkas where
            buf_Inkas.obj-type = p-curr-obj-type
        AND buf_Inkas.obj-code = p-curr-obj-code
        AND buf_Inkas.status_ = 'новый':U,
      first buf_trn-doc where
           buf_trn-doc.doc-code = buf_inkas.inkas-code:
      if p-process-only-new then do:
        find first temp-inkas where temp-inkas.inkas-code = buf_inkas.inkas-code no-error.
        if not available temp-inkas then next _inkas.
      end.
      if buf_trn-doc.flag_ <> no then NEXT _inkas.
      assign
      v-parameter =     string(if p-finalize then 3 else 2)
                                                        + chr(4) +
                        buf_inkas.inkas-code            + chr(4) +
                        string(sale-filter)             + chr(4) +
                        v-curr-r-b                      + chr(4) +
                        string(is-wth)                  + chr(4) +
                        string(cas-shft)                + chr(4) +
                        string(one-curs)                + chr(4) +
                        string(cas-curs)                + chr(4) +
                        string(prcl-spl)                + chr(4) +
                        pay-gds-algo                    + chr(4) +
                        string(rdtaxcd)                 + chr(4) +
                        string(exctaxcd)                + chr(4) +
                        string(factorrt)                + chr(4) +
                        string(btltaxcd)                + chr(4) +
                        string(buf_shop.day-only)
      .
      run str/saleincl.p (
                      input this-procedure
                     ,input this-procedure
                     ,input this-procedure
                     ,input v-parameter
                     )  no-error.
      if error-status:error
      and return-value <> "error"
      then do:
        run write-to-log in this-procedure (
              input substitute( "!!!Ошибка при закачке чеков в документ продажи &1 в &2&3&4" +
                                "&5 &6"
                              , buf_inkas.inkas-code
                              , p-curr-obj-type
                              , p-curr-obj-code
                              , chr(10)
                              , error-status:get-message(1)
                              , return-value
                              )            ).
         next _inkas.
      end.
    end.
  end.
end procedure.
procedure proc-step-200 :
define input parameter p-curr-obj-type    like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code    like ub.clients.obj-code no-undo .
define input parameter p-process-only-new as logical no-undo .
define input parameter p-finalize         as logical no-undo .
DEFINE VARIABLE compensed AS LOGICAL NO-UNDO.
DEFINE VARIABLE auto-comp AS LOGICAL NO-UNDO.
DEFINE VARIABLE autofbr AS LOGICAL NO-UNDO.
DEFINE VARIABLE one-curs AS LOGICAL NO-UNDO.
DEFINE VARIABLE restdish AS LOGICAL NO-UNDO.
DEFINE VARIABLE restingr AS LOGICAL NO-UNDO.
DEFINE VARIABLE resttpsi AS LOGICAL NO-UNDO.
define variable neg-tpsi-weight as logical no-undo .
define variable neg-tpsi-oper as logical no-undo .
define variable neg-tpsi-qnty as decimal no-undo .
DEFINE VARIABLE v-is-tpsi-obj AS LOGICAL NO-UNDO.
define variable v-parameter as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
DEFINE BUFFER buf_shop FOR ub.shop.
define buffer buf_inkas for ub.inkas.
define buffer buf_trn-doc for ub.trn-doc.
  do
  on error undo, return error
  :
   FIND FIRST buf_shop NO-LOCK WHERE
             buf_shop.obj-code = p-curr-obj-code.
   run gbl/tpsi-obj.p (
                  input p-curr-obj-type
                , input p-curr-obj-code
                , output v-is-tpsi-obj) no-error .
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
  run adm/shattri.p (
      input "get":U
      ,input  p-curr-obj-type
      ,input  p-curr-obj-code
      ,input  'autosale':U
      ,input  "":U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  IF error-status:error then do:
    run write-to-log in this-procedure (
          input substitute("Ошибка при получении опций продажи НА ОБЪЕКТЕ &1&2:&3&4 &5"
            , p-curr-obj-type
            , p-curr-obj-code
            , chr(10)
            , error-status:get-message(1)
            , return-value )).
      undo, return.
  end.
  for each  thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-curr-obj-type
        and thbjattr_thbj-attr.obj-code = p-curr-obj-code
        and thbjattr_thbj-attr.upper-prop-code = 'autosale':U
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
    case thbjattr_thbj-attr.prop-code:
      when 'autofbr':U then do:
        autofbr = thbjattr_thbj-attr.property-value-logical.
      end.
      when 'one-curs':U then do:
        one-curs = thbjattr_thbj-attr.property-value-logical.
      end.
      when 'restdish':U then do:
        restdish = thbjattr_thbj-attr.property-value-logical.
      end.
      when 'restingr':U then do:
        restingr = thbjattr_thbj-attr.property-value-logical.
      end.
      when 'resttpsi':U then do:
        resttpsi = thbjattr_thbj-attr.property-value-logical.
      end.
      when 'neg-tpsi-weight':U then do:
        neg-tpsi-weight = thbjattr_thbj-attr.property-value-logical.
      end.
      when 'neg-tpsi-qnty':U then do:
        neg-tpsi-qnty = thbjattr_thbj-attr.property-value-decimal.
      end.
      when 'neg-tpsi-oper':U then do:
        neg-tpsi-oper = thbjattr_thbj-attr.property-value-logical.
      end.
    end case.
    assign
    restdish = restdish and autofbr
    restingr = restingr and autofbr
    resttpsi = resttpsi and v-is-tpsi-obj
    .
  end.
    _inkas:
    for each buf_inkas where
            buf_Inkas.obj-type = p-curr-obj-type
        AND buf_Inkas.obj-code = p-curr-obj-code
        AND buf_Inkas.status_ = 'новый':U,
        first buf_trn-doc where
              buf_trn-doc.doc-code = buf_inkas.inkas-code:
      if p-process-only-new then do:
        find first temp-inkas where temp-inkas.inkas-code = buf_inkas.inkas-code no-error.
        if not available temp-inkas then next _inkas.
      end.
      assign
      v-parameter =   v-curr-r-b                       + chr(4) +
                      buf_inkas.inkas-code             + chr(4) +
                      string(if p-finalize then 3 else 2)
                                                       + chr(4) +
                      string(autofbr)                  + chr(4) +
                      string(buf_shop.is-catering)     + chr(4) +
                      string(v-is-tpsi-obj)            + chr(4) +
                      string(restdish)                 + chr(4) +
                      string(restingr)                 + chr(4) +
                      string(resttpsi)                 + chr(4) +
                      string(neg-tpsi-weight)          + chr(4) +
                      string(neg-tpsi-qnty)            + chr(4) +
                      string(neg-tpsi-oper)
      .
.
      run str/salersrv.p (
                      input this-procedure
                     ,input this-procedure
                     ,input this-procedure
                     ,input v-parameter
                     )  no-error.
      if error-status:error
      and return-value <> "error"
      then do:
        run write-to-log in this-procedure (
              input substitute( "!!!Ошибка при резервировании в документе продажи &1 в &2&3&4" +
                                "&5 &6"
                              , buf_inkas.inkas-code
                              , p-curr-obj-type
                              , p-curr-obj-code
                              , chr(10)
                              , error-status:get-message(1)
                              , return-value
                              )            ).
         next _inkas.
      end.
    end.
  end.
end procedure.
procedure proc-step-300 :
define input parameter p-curr-obj-type    like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code    like ub.clients.obj-code no-undo .
define input parameter p-process-only-new as logical no-undo .
DEFINE VARIABLE compensed AS LOGICAL NO-UNDO.
DEFINE VARIABLE auto-comp AS LOGICAL NO-UNDO.
DEFINE VARIABLE autofbr AS LOGICAL NO-UNDO.
DEFINE VARIABLE one-curs AS LOGICAL NO-UNDO.
DEFINE VARIABLE restdish AS LOGICAL NO-UNDO.
DEFINE VARIABLE restingr AS LOGICAL NO-UNDO.
DEFINE VARIABLE resttpsi AS LOGICAL NO-UNDO.
define variable neg-tpsi-weight as logical no-undo .
define variable neg-tpsi-oper as logical no-undo .
define variable neg-tpsi-qnty as decimal no-undo .
define variable close-in-rfsl as integer no-undo .
define variable pay-gds-algo as character no-undo .
DEFINE VARIABLE v-is-tpsi-obj AS LOGICAL NO-UNDO.
define variable v-parameter as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
DEFINE BUFFER buf_shop FOR ub.shop.
define buffer buf_inkas for ub.inkas.
  do
  on error undo, return error
  :
    find first buf_shop no-lock where buf_shop.obj-code = p-curr-obj-code.
    run gbl/tpsi-obj.p (
                   input p-curr-obj-type
                 , input p-curr-obj-code
                 , output v-is-tpsi-obj) no-error .
    for each thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
    end.
    run adm/shattri.p (
        input "get":U
        ,input  p-curr-obj-type
        ,input  p-curr-obj-code
        ,input  'autosale':U
        ,input  "":U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    IF error-status:error then do:
      run write-to-log in this-procedure (
            input substitute("Ошибка при получении опций продажи НА ОБЪЕКТЕ &1&2:&3&4 &5"
              , p-curr-obj-type
              , p-curr-obj-code
              , chr(10)
              , error-status:get-message(1)
              , return-value )).
       undo, return.
    end.
    for each  thbjattr_thbj-attr where
              thbjattr_thbj-attr.obj-type = p-curr-obj-type
          and thbjattr_thbj-attr.obj-code = p-curr-obj-code
          and thbjattr_thbj-attr.upper-prop-code = 'autosale':U
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
      case thbjattr_thbj-attr.prop-code:
        when 'autocomp':U then do:
          auto-comp = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'autofbr':U then do:
          autofbr = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'one-curs':U then do:
          one-curs = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'restdish':U then do:
          restdish = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'restingr':U then do:
          restingr = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'resttpsi':U then do:
          resttpsi = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'neg-tpsi-weight':U then do:
          neg-tpsi-weight = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'neg-tpsi-oper':U then do:
          neg-tpsi-oper = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'neg-tpsi-qnty':U then do:
          neg-tpsi-qnty = thbjattr_thbj-attr.property-value-decimal.
        end.
        when 'close-in-rfsl':U then do:
          close-in-rfsl = thbjattr_thbj-attr.property-value-integer.
        end.
        when 'pay-gds-algo':U then do:
          pay-gds-algo = thbjattr_thbj-attr.property-value-character.
        end.
      end case.
    end.
    assign
    restdish = restdish and autofbr
    restingr = restingr and autofbr
    resttpsi = resttpsi and v-is-tpsi-obj
    neg-tpsi-weight = neg-tpsi-weight and v-is-tpsi-obj
    neg-tpsi-oper = neg-tpsi-oper and v-is-tpsi-obj
    .
    _inkas:
    for each buf_inkas where
            buf_Inkas.obj-type = p-curr-obj-type
        AND buf_Inkas.obj-code = p-curr-obj-code
        AND buf_Inkas.status_ = 'нередакт':U:
      if p-process-only-new then do:
        find first temp-inkas where temp-inkas.inkas-code = buf_inkas.inkas-code no-error.
        if not available temp-inkas then next _inkas.
      end.
      assign
      v-parameter =   v-curr-r-b                       + chr(4) +
                      buf_inkas.inkas-code             + chr(4) +
                      string(2)              + chr(4) +
                      string(YES)        + chr(4) +
                      string(no)     + chr(4) +
                      string(auto-comp)                + chr(4) +
                      string(autofbr)                  + chr(4) +
                      string(one-curs)                 + chr(4) +
                      string(buf_shop.is-catering)     + chr(4) +
                      string(v-is-tpsi-obj)            + chr(4) +
                      string(restdish)                 + chr(4) +
                      string(restingr)                 + chr(4) +
                      string(resttpsi)                 + chr(4) +
                      string(neg-tpsi-weight)          + chr(4) +
                      string(neg-tpsi-qnty)            + chr(4) +
                      string(neg-tpsi-oper)            + chr(4) +
                      string(close-in-rfsl)            + chr(4) +
                      pay-gds-algo
      .
.
      run str/saleclos.p (
                      input this-procedure
                     ,input this-procedure
                     ,input this-procedure
                     ,input v-parameter
                     )  no-error.
      if error-status:error
      and return-value <> "error"
      then do:
        run write-to-log in this-procedure (
              input substitute( "!!!Ошибка при закрытии на факт документа продажи &1 в &2&3&4" +
                                "&5 &6"
                              , buf_inkas.inkas-code
                              , p-curr-obj-type
                              , p-curr-obj-code
                              , chr(10)
                              , error-status:get-message(1)
                              , return-value
                              )            ).
         next _inkas.
      end.
    end.
  end.
end procedure.
procedure proc-step-400 :
define input parameter p-curr-obj-type    like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code    like ub.clients.obj-code no-undo .
define input parameter p-process-only-new as logical no-undo .
define variable v-parameter as character no-undo .
define buffer buf_inkas for ub.inkas.
define buffer buf_chk-doc for ub.chk-doc.
  do
  on error undo, return error
  :
    _inkas:
    for each buf_inkas where
            buf_Inkas.obj-type = p-curr-obj-type
        AND buf_Inkas.obj-code = p-curr-obj-code
        AND buf_Inkas.status_ = 'новый':U:
      if p-process-only-new then do:
        find first temp-inkas where temp-inkas.inkas-code = buf_inkas.inkas-code no-error.
        if not available temp-inkas then next _inkas.
      end.
      find first buf_chk-doc no-lock where
                buf_chk-doc.obj-type = p-curr-obj-type
            AND buf_chk-doc.obj-code = p-curr-obj-code
            AND buf_chk-doc.out-code = buf_inkas.inkas-code no-error.
      if not available buf_chk-doc then do:
        assign
        v-parameter = string(2)                 + chr(4) +
                      p-curr-obj-type           + chr(4) +
                      string(p-curr-obj-code)   + chr(4) +
                      string(no)                + chr(4) +
                      buf_inkas.inkas-code
        .
        run str/del-sale.p (
                        input this-procedure
                      ,input this-procedure
                      ,input this-procedure
                      ,input v-parameter
                      )  no-error.
        if error-status:error
        and return-value <> "error"
        then do:
          run write-to-log in this-procedure (
                input substitute( "!!!Ошибка при удалении пустой (без чеков) продажи &1 в &2&3&4" +
                                  "&5 &6"
                                , buf_inkas.inkas-code
                                , p-curr-obj-type
                                , p-curr-obj-code
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value
                                )            ).
          next _inkas.
        end.
      end.
    end.
  end.
end procedure.
procedure get-db-num:
  define output parameter pDbNum as integer no-undo.
  pDbNum = g#db-num.
end.
procedure get-userid:
  define output parameter pUserId as character no-undo.
  assign
    pUserId  = g#userid
    .
end.
do
on error undo, return error
:
    define variable v-ind                       as integer      no-undo.
    define variable v-param-list                as character    no-undo.
    define variable v-temp-obj-list             as character    no-undo.
    define variable v-obj-list                  as character    no-undo.
    define variable v-param-type                as character    no-undo.
    define variable v-obj-counter               as integer      no-undo.
    define variable v-range                     as integer      no-undo.
    define variable v-host-code                 as integer      no-undo.
    define variable v-start-state               as integer      no-undo .
    define variable v-end-state                 as integer      no-undo .
    define variable v-finalize-100              as logical      no-undo .
    define variable v-finalize-200              as logical      no-undo .
    define variable v-process-only-new          as logical      no-undo .
    define variable v-parameter                 as character    no-undo .
    define buffer buf_clients   for ub.clients .
    define buffer buf_temp-obj  for temp-obj.
    assign
    log-file-name = "ext-sale.log".
    run gbl/set-gbl.p
      (input  true
      ,input  g#auto-user-id
      ,input  g#auto-user-password
      ) no-error.
    if error-status :error
    then do:
        run write-to-log( vss-workfile + chr(32)
                        + "!!!Ошибка при инициализации переменных g#..." + chr(10)
                        + error-status:get-message(error-status:num-messages)
                        + return-value
                        ) .
        return error.
    end.
    run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input 'schedule-param-list':U
        , output v-param-list
        , output v-param-type
    ).
    if v-param-list = "":U then do:
        run write-to-log( substitute("!!!Не заданы параметры обработки продаж в задаче &1&2"
                                     , p-task-num
                                     , chr(10)
                                     )
                        ) .
    end.
    assign
        v-range = integer( entry( 1,  v-param-list ) )
        v-start-state = (if num-entries(v-param-list) > 2 then integer(entry(3, v-param-list)) else 0)
        v-end-state = (if num-entries(v-param-list) > 3 then integer(entry(4, v-param-list)) else 0)
        v-finalize-100  = (if num-entries(v-param-list) > 4 then logical(entry(5, v-param-list)) else no)
        v-finalize-200  = (if num-entries(v-param-list) > 4 then logical(entry(6, v-param-list)) else no)
    .
    if v-range = 2
    then do:
        if num-entries( v-param-list ) > 2
        then do:
            assign
                v-host-code = integer( entry( 2,  v-param-list ) )
            .
        end.
        else do:
            assign
                v-host-code = -1
            .
            run write-to-log in this-procedure (
                input vss-workfile + chr(32) + " Не удалось определить код фирмы для обработки документов продаж объектов фирмы."
            ).
        end.
    end.
    if v-range = 2
    and v-host-code = -1
    then do:
        assign
            v-range = 1
        .
    end.
    if v-range <> 3 then run init-temphost.
    case v-range
    :
        when 1
        then do:
            for each temp-obj
            :
                if temp-obj.db-num = p-db-num
                then do:
                    assign
                        v-obj-list = v-obj-list
                                        + ( if v-obj-list = "" then "" else "," )
                                        + temp-obj.obj-type
                                        + "," + string( temp-obj.obj-code )
                    .
                end.
            end.
            assign
                v-range     = 3
            .
        end.
        when 2
        then do:
            for each temp-obj
            :
                if temp-obj.db-num = p-db-num
                and temp-obj.host-code = v-host-code
                then do:
                    assign
                        v-obj-list = v-obj-list
                                        + ( if v-obj-list = "" then "" else "," )
                                        + temp-obj.obj-type
                                        + "," + string( temp-obj.obj-code )
                    .
                end.
            end.
            assign
                v-range     = 3
            .
        end.
        when 3
        then do:
            run schedule-attr-value in this-procedure (
                  input p-cre-db-num
                , input p-task-type
                , input p-task-num
                , input 'schedule-obj-list':U
                , output v-temp-obj-list
                , output v-param-type
            ).
            do v-obj-counter = 1 to num-entries ( v-temp-obj-list ) / 2
            :
                find first buf_clients no-lock
                      where buf_clients.obj-type  = entry( v-obj-counter * 2 - 1, v-temp-obj-list )
                        and buf_clients.obj-code = integer( entry( v-obj-counter * 2, v-temp-obj-list ) )
                no-error.
                if not available buf_clients
                then do:
                    run write-to-log( vss-workfile + chr(32)
                                    + substitute( " Ошибка обработки документов продаж по расписанию: Не найден заданный объект &1 &2" + chr(10)
                                                    , buf_clients.obj-type
                                                    , buf_clients.obj-code
                                                )
                                    ) .
                    undo, return error .
                end.
                else do:
                    if buf_clients.db-num = p-db-num
                    then do:
                        assign
                            v-obj-list = v-obj-list
                                            + ( if v-obj-list = "" then "" else "," )
                                            + buf_clients.obj-type
                                            + "," + string( buf_clients.obj-code )
                        .
                        create buf_temp-obj .
                        assign
                          buf_temp-obj.obj-type  = buf_clients.obj-type
                          buf_temp-obj.obj-code  = buf_clients.obj-code
                          buf_temp-obj.host-code = buf_clients.host-code
                          buf_temp-obj.db-num    = buf_clients.db-num
                        .
                    end.
                end.
            end.
        end.
    end case.
    if v-obj-list = ""
    then do:
        run write-to-log( vss-workfile + chr(32)
                        + substitute( " Нет объектов для обработки документов продаж."
                                        + chr(10) + "    Номер базы данных:                   &1"
                                        + chr(10) + "    Задан список объектов:               &2"
                                        + chr(10) + "    Тип обработки        :               &3"
                                        , p-db-num
                                        , v-obj-list
                                        , v-range
                                    )
                        ) .
        undo, return error .
    end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    _temp-obj:
    for each temp-obj no-lock where
             temp-obj.obj-type = 'маг':U:
      if temp-obj.db-num <> g#db-num
      or index(v-obj-list,  temp-obj.obj-type + chr(44) + string( temp-obj.obj-code )) = 0 then do:
        next _temp-obj.
      end.
      assign
        v-cntxt-obj-type      = temp-obj.obj-type
        v-cntxt-obj-code      = temp-obj.obj-code
        v-cntxt-host-code-obj = temp-obj.host-code
        v-cntxt-db-num-obj    = temp-obj.db-num
      .
      run write-to-log in this-procedure (
            input substitute( "            &1&2 Обработка документов продаж............."
                             , temp-obj.obj-type
                             , temp-obj.obj-code
                             )
                                        ).
      if v-start-state = 0 then do:
        assign
        v-process-only-new = yes.
        assign
        v-parameter =
                      temp-obj.obj-type         + chr(4) +
                      string(temp-obj.obj-code) + chr(4) +
                      string(p-cre-db-num) + chr(4) +
                      string(p-task-type) + chr(4) +
                      string(p-task-num).
        run write-to-log in this-procedure (
              input substitute( "Создание документов продаж по шаблонам в &1&2..........."
                              , temp-obj.obj-type
                              , temp-obj.obj-code
                              )            ).
        run str/salemake.p (
                       input this-procedure
                      ,input this-procedure
                      ,input this-procedure
                      ,input v-parameter  ) no-error .
        if error-status:error then do:
          run write-to-log in this-procedure (
                input substitute( "!!!Ошибка при создании документов продаж по шаблонам в &1&2&3" +
                                  "&4 &5"
                                , temp-obj.obj-type
                                , temp-obj.obj-code
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value
                                )            ).
        end.
      end.
      if v-start-state <= 100
      and v-end-state >= 100
      then do:
        run write-to-log in this-procedure (
              input substitute( "Закачка чеков в документы продажи в &1&2..........."
                              , temp-obj.obj-type
                              , temp-obj.obj-code
                              )            ).
        run proc-step-100 in this-procedure(
                                            input temp-obj.obj-type
                                           ,input temp-obj.obj-code
                                           ,input v-process-only-new
                                           ,input v-finalize-100
                                           )  no-error .
        if error-status:error then do:
          run write-to-log in this-procedure (
                input substitute( "!!!Ошибка при закачке чеков в документы продаж в &1&2&3" +
                                  "&4 &5"
                                , temp-obj.obj-type
                                , temp-obj.obj-code
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value
                                )            ).
        end.
      end.
      process events.
      if v-start-state <= 200
      and v-end-state >= 200
      then do:
        run write-to-log in this-procedure (
              input substitute( "Резервирование в документах продаж в &1&2..........."
                              , temp-obj.obj-type
                              , temp-obj.obj-code
                              )            ).
        run proc-step-200 in this-procedure(
                                            input temp-obj.obj-type
                                           ,input temp-obj.obj-code
                                           ,input v-process-only-new
                                           ,input v-finalize-200)  no-error .
        if error-status:error then do:
          run write-to-log in this-procedure (
                input substitute( "!!!Ошибка при резервировании документов продаж в &1&2&3" +
                                  "&4 &5"
                                , temp-obj.obj-type
                                , temp-obj.obj-code
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value
                                )            ).
        end.
      end.
      process events.
      if v-start-state <= 300
      and v-end-state >= 300
      then do:
        run write-to-log in this-procedure (
              input substitute( "Закрытие на факт документов продаж в &1&2..........."
                              , temp-obj.obj-type
                              , temp-obj.obj-code
                              )            ).
        run proc-step-300 in this-procedure(
                                            input temp-obj.obj-type
                                           ,input temp-obj.obj-code
                                           ,input v-process-only-new)  no-error .
        if error-status:error then do:
          run write-to-log in this-procedure (
                input substitute( "!!!Ошибка при закрытии на факт документов продаж в &1&2&3" +
                                  "&4 &5"
                                , temp-obj.obj-type
                                , temp-obj.obj-code
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value
                                )            ).
        end.
      end.
      if v-start-state <= 400
      and v-end-state >= 400
      then do:
        run write-to-log in this-procedure (
              input substitute( "Удаление пустых(без чеков) документов продаж в &1&2..........."
                              , temp-obj.obj-type
                              , temp-obj.obj-code
                              )            ).
        run proc-step-400 in this-procedure(
                                            input temp-obj.obj-type
                                           ,input temp-obj.obj-code
                                           ,input v-process-only-new)  no-error .
        if error-status:error then do:
          run write-to-log in this-procedure (
                input substitute( "!!!Ошибка при удалении пустых (без чеков) документов продаж в &1&2&3" +
                                  "&4 &5"
                                , temp-obj.obj-type
                                , temp-obj.obj-code
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value
                                )            ).
        end.
      end.
      process events.
      run write-to-log in this-procedure (
            input substitute( "Обработка документов продаж &1&2 завершена"
                             , temp-obj.obj-type
                             , temp-obj.obj-code
                             )
                                        ).
    end.
end.
procedure mainmenu_getcntxt :
define output parameter p-cntxt-db-num                as integer   no-undo .
define output parameter p-cntxt-userid                as character no-undo .
define output parameter p-cntxt-level                 as character no-undo .
define output parameter p-cntxt-host-code-obj         as integer   no-undo .
define output parameter p-cntxt-obj-type              as character no-undo .
define output parameter p-cntxt-obj-code              as integer   no-undo .
define output parameter p-cntxt-db-num-obj            as integer   no-undo .
define output parameter p-cntxt-is-admin              as logical   no-undo .
  do
  on error undo, return error return-value
  :
  assign
    p-cntxt-db-num          =  g#db-num
    p-cntxt-userid          =  g#userid
    p-cntxt-level           =  v-cntxt-level
    p-cntxt-host-code-obj   =  v-cntxt-host-code-obj
    p-cntxt-obj-type        =  v-cntxt-obj-type
    p-cntxt-obj-code        =  v-cntxt-obj-code
    p-cntxt-is-admin        =  v-cntxt-is-admin
    p-cntxt-db-num-obj      =  v-cntxt-db-num-obj
  .
  end.
 end procedure.
