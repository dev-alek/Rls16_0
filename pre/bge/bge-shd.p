block-level on error undo, throw.
define input parameter p-cre-db-num as integer   no-undo .
define input parameter p-task-type  as character no-undo .
define input parameter p-task-num   as integer   no-undo .
define input parameter p-db-num     as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: a61e6bb0c7e0, 2871, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:10 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-shd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-shd.p $":U .
define variable vss-description as character no-undo init "Экспорт по расписанию.".
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
DEFINE new SHARED TEMP-TABLE TT-tnved NO-UNDO
FIELD tnved  AS CHAR FORMAT "X(10)"  LABEL 'Код ТНВЭД':U
FIELD f-name AS CHAR FORMAT "X(255)" LABEL 'Полное наименование':U
INDEX tnved IS UNIQUE PRIMARY  tnved.
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
    define buffer lck_schedule-attr for ub.schedule-attr.
    define buffer buf_shift-obj for ub.shift-obj.
    define variable v-ind                       as integer      no-undo.
    define variable v-param-list                as character    no-undo.
    define variable v-temp-obj-list             as character    no-undo.
    define variable v-obj-counter               as integer      no-undo.
    define variable v-obj-list                  as character    no-undo.
    define variable v-obj-list-shift            as character    no-undo.
    define variable v-obj-list-noshift          as character    no-undo.
    define variable v-obj-list-type             as character    no-undo.
    define variable v-obj-list-code             as integer      no-undo.
    define variable v-doc-type-list             as character    no-undo.
    define variable v-spec-doc-type-list        as character    no-undo.
    define variable v-date-range                as character    no-undo.
    define variable v-param-type                as character    no-undo.
    define variable v-date-from                 as date         no-undo.
    define variable v-date-to                   as date         no-undo.
    define variable v-pay-code                  as logical      no-undo.
    define variable v-cst                       as logical      no-undo.
    define variable v-parts                     as logical      no-undo.
    define variable v-chk-pay-code              as logical      no-undo.
    define variable v-pay-desk                  as logical      no-undo.
    define variable v-opened-docs               as logical      no-undo.
    define variable v-exp-doc                   as logical      no-undo.
    define variable v-exp-ref                   as logical      no-undo.
    define variable v-exp-day                   as logical      no-undo.
    define variable v-exp-way                   as logical      no-undo.
    define variable v-exp-ref-ext               as logical      no-undo.
    define variable v-exp-stk                   as logical      no-undo.
    define variable v-exp-stk-supp              as logical      no-undo.
    define variable v-incr                      as logical      no-undo.
    define variable v-exp-checks                as logical      no-undo.
    define variable v-exp-doc-rvs               as logical      no-undo.
    define variable v-exp-fo                    as logical      no-undo.
    define variable v-exp-fp                    as logical      no-undo.
    define variable v-exp-s-f                   as logical      no-undo.
    define variable v-range                     as integer      no-undo.
    define variable v-initial-range             as integer      no-undo.
    define variable v-host-code                 as integer      no-undo.
    define variable v-par-value         as character    no-undo.
    define variable v-par-type          as character    no-undo.
    define variable v-shift-mode-on     as logical      no-undo.
    define variable v-bgeflold          as character    no-undo.
    define variable v-value-character as character  no-undo .
    define variable v-value-date      as date       no-undo .
    define variable v-value-decimal   as decimal    no-undo .
    define variable v-value-integer   as integer    no-undo .
    define variable v-value-logical   as logical    no-undo .
    define variable v-tth             as handle     no-undo .
do
on error undo, return error
:
    run adm/lockshda.p ( input p-cre-db-num
                       , input p-task-type
                       , input p-task-num
                       , input 'schedule-param-list':U
                       , buffer lck_schedule-attr
                       ) no-error .
    if error-status :error = yes
    then do:
      run write-to-log( vss-workfile + chr(32)
                      + "Другая сессия уже работает с этим расписанием..." + chr(10)
                      + error-status:get-message(error-status:num-messages)
                      + return-value
                      ) .
      return .
    end.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeshift':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
          v-shift-mode-on = no
      .
    end.
    else do:
      assign
          v-shift-mode-on = ( v-value-character = "distinct":U )
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeflold':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgeflold  = "old":U
      .
    end.
    else do:
      assign
        v-bgeflold  = v-value-character
      .
    end.
    delete object v-tth.
    run gbl/set-gbl.p (
          input true
        , input g#auto-user-id
        , input g#auto-user-password
    ) no-error .
    if error-status :error
    then do:
        run write-to-log( vss-workfile + chr(32)
                        + "Ошибка при инициализации переменных g#..." + chr(10)
                        + error-status:get-message(error-status:num-messages)
                        + return-value
                        ) .
        return error.
    end.
    do :
    run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input 'schedule-param-list':U
        , output v-param-list
        , output v-param-type
    ).
    assign
        v-range = integer( entry( 1,  v-param-list ) )
    .
    if v-range = 2
    then do:
        if num-entries( v-param-list ) > 14
        then do:
            assign
                v-host-code = integer( entry( 15,  v-param-list ) )
            .
        end.
        else do:
            assign
                v-host-code = -1
            .
            run write-to-log in this-procedure (
                input vss-workfile + chr(32) + " Не удалось определить код фирмы для выгрузки по объектам."
            ).
        end.
    end.
    run schedule-attr-extract-logical in this-procedure (
          input 2
        , input v-param-list
        , output v-pay-code
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 3
        , input v-param-list
        , output v-cst
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 4
        , input v-param-list
        , output v-opened-docs
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 6
        , input v-param-list
        , output v-parts
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 7
        , input v-param-list
        , output v-chk-pay-code
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 8
        , input v-param-list
        , output v-exp-doc
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 9
        , input v-param-list
        , output v-exp-ref
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 10
        , input v-param-list
        , output v-exp-day
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 11
        , input v-param-list
        , output v-exp-way
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 12
        , input v-param-list
        , output v-exp-ref-ext
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 13
        , input v-param-list
        , output v-exp-stk
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 14
        , input v-param-list
        , output v-exp-stk-supp
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 16
        , input v-param-list
        , output v-pay-desk
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 17
        , input v-param-list
        , output v-incr
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 18
        , input v-param-list
        , output v-exp-checks
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 19
        , input v-param-list
        , output v-exp-fo
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 20
        , input v-param-list
        , output v-exp-fp
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 22
        , input v-param-list
        , output v-exp-s-f
    ).
    run schedule-attr-extract-logical in this-procedure (
          input 23
        , input v-param-list
        , output v-exp-doc-rvs
    ).
    end .
    if v-incr = no
    then do:
        if v-exp-doc = yes
        or v-exp-fp = yes
        then do:
            run schedule-attr-value in this-procedure (
                input p-cre-db-num
                , input p-task-type
                , input p-task-num
                , input 'schedule-doc-type-list':U
                , output v-doc-type-list
                , output v-param-type
            ).
        end.
        if v-exp-doc = yes
        or v-exp-stk = yes
        or v-exp-day = yes
        or v-exp-fo  = yes
        or v-exp-fp  = yes
        or v-exp-s-f = yes
        then do:
            run schedule-attr-value in  this-procedure (
                input p-cre-db-num
                , input p-task-type
                , input p-task-num
                , input 'schedule-date-list':U
                , output v-date-range
                , output v-param-type
            ).
            run analyze-date-range in this-procedure (
                  input v-date-range
                , output v-date-from
                , output v-date-to
            ) no-error.
            if error-status :error
            or v-date-from  = ?
            or v-date-to    = ?
            then do:
                run write-to-log( vss-workfile + chr(32)
                                + substitute( " Ошибка выгрузки по расписанию. Не удалось определить интервал дат для выгрузки." + chr(10) + "&1" + chr(10) + "&2" + chr(10) + "&3"
                                                , return-value
                                                , error-status :get-message( 0 )
                                                , error-status :get-message( 1 )
                                            )
                                ) .
                undo, return error .
            end.
        end.
    end.
    if v-exp-doc = yes
    or v-exp-day = yes
    or v-exp-way = yes
    or v-exp-stk = yes
    or v-exp-fo  = yes
    or v-exp-fp  = yes
    or v-exp-s-f = yes
    then do:
        assign
            v-initial-range = v-range
        .
        run fill-obj-list in this-procedure (
              input v-initial-range
            , input v-host-code
            , output v-range
            , output v-obj-list
        ).
        if v-obj-list = ""
        or v-range <> 3
        then do:
            run write-to-log( vss-workfile + chr(32)
                            + substitute( " Нет объектов для выгрузки или неверно задан тип выгрузки."
                                            + chr(10) + "    Номер базы данных:                   &1"
                                            + chr(10) + "    Задан список объектов:               &2"
                                            + chr(10) + "    Тип выгрузки (допускается только 3): &3"
                                            , p-db-num
                                            , v-obj-list
                                            , v-range
                                        )
                            ) .
            undo, return error .
        end.
    end.
    if v-incr = no
    then do:
        run write-to-log ( vss-workfile + chr(32) + " Выгрузка по расписанию. Флаг инкрементальной выгрузки выключен." ) .
        if v-exp-doc = yes
        then do:
            if v-shift-mode-on = yes
            then do:
                run bge/shd-doch.p (
                      input p-db-num
                    , input v-date-from
                    , input v-date-to
                    , input v-range
                    , input v-obj-list
                    , input cross-list(v-doc-type-list, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U, chr(44))
                    , input v-pay-code
                    , input v-cst
                    , input v-parts
                    , input v-chk-pay-code
                    , input v-pay-desk
                    , input no
                    , input v-opened-docs
                    , input v-exp-doc-rvs
                    , input ?
                    , input ?
                ) no-error.
                if error-status :error
                then do:
                    run write-to-log( vss-workfile + chr(32)
                                    + substitute( " Ошибка выгрузки документов по расписанию. &1 "
                                                    , return-value
                                                )
                                    ) .
                end.
            end.
            else do:
                if v-bgeflold = "firm":U
                then do:
                    run bge/shd-docf.p (
                          input p-db-num
                        , input v-date-from
                        , input v-date-to
                        , input v-range
                        , input v-obj-list
                        , input cross-list(v-doc-type-list, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U, chr(44))
                        , input v-pay-code
                        , input v-cst
                        , input v-parts
                        , input v-chk-pay-code
                        , input v-pay-desk
                        , input no
                        , input v-opened-docs
                        , input v-exp-doc-rvs
                        , input ?
                        , input ?
                    ) no-error.
                    if error-status :error
                    then do:
                        run write-to-log( vss-workfile + chr(32)
                                        + substitute( " Ошибка выгрузки документов фирм по расписанию. &1 "
                                                        , return-value
                                                    )
                                        ) .
                    end.
                end.
                else do:
                    run bge/shd-docs.p (
                          input p-db-num
                        , input v-date-from
                        , input v-date-to
                        , input v-range
                        , input v-obj-list
                        , input cross-list(v-doc-type-list, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U, chr(44))
                        , input v-pay-code
                        , input v-cst
                        , input v-parts
                        , input v-chk-pay-code
                        , input v-pay-desk
                        , input no
                        , input v-opened-docs
                        , input v-exp-doc-rvs
                        , input ?
                        , input ?
                    ) no-error.
                    if error-status :error
                    then do:
                        run write-to-log( vss-workfile + chr(32)
                                        + substitute( " Ошибка выгрузки документов по расписанию. &1 "
                                                        , return-value
                                                    )
                                        ) .
                    end.
                end.
            end.
        end.
        if v-exp-ref = yes
        then do:
            if v-exp-ref-ext = yes
            then do:
                run bge/bge-ref.p (
                      input ?
                    , input "good-ext"
                    , input yes
                    , input v-host-code
                    , input ?
                    , input ?
                ) no-error.
            end.
            else do:
                run bge/bge-ref.p (
                      input ?
                    , input ""
                    , input yes
                    , input v-host-code
                    , input ?
                    , input ?
                ) no-error.
            end.
            if error-status :error
            then do:
                run write-to-log( vss-workfile + chr(32)
                                + substitute( " Ошибка выгрузки справочников по расписанию. &1 "
                                                , return-value
                                            )
                                ) .
            end.
        end.
        if v-exp-day = yes
        then do:
            run bge/bge-day.p (
                  input ?
                , input v-date-from
                , input v-date-to
                , input v-range
                , input v-obj-list
                , input 0
                , input yes
                , input ?
                , input ?
            ) no-error.
            if error-status :error
            then do:
                run write-to-log( vss-workfile + chr(32)
                                + substitute( " Ошибка выгрузки товаров по дням по расписанию. &1 "
                                                , return-value
                                            )
                                ) .
            end.
        end.
        if v-exp-way = yes
        then do:
            run bge/bge-way.p (
                input -1
                , input yes
                , input p-db-num
                , input v-obj-list
                , input ?
                , input ?
            ) no-error.
            if error-status :error
            then do:
                run write-to-log( vss-workfile + chr(32)
                                + substitute( " Ошибка выгрузки товаров в пути по расписанию. &1 "
                                                , return-value
                                            )
                                ) .
            end.
        end.
        if v-exp-stk = yes and entry(1,v-date-range) = '1' then do:
                    run bge/bgestd.p (
                          input ?
                        , input -1
                        , input 3
                        , input v-obj-list
                        , input v-date-to
                        , input v-cst
                        , input yes
                        , input yes
                        , input 0
                        , input ?
                        , input ?
                    ).
        end.
        else if v-exp-stk = yes  then  do:
           if v-exp-stk-supp = yes
            then do:
                run bge/bge-stk.p (
                      input ?
                    , input -1
                    , input v-date-from
                    , input v-date-to
                    , input yes
                    , input yes
                    , input p-db-num
                    , input v-obj-list
                    , input ?
                    , input ?
                ) no-error.
                if error-status :error
                then do:
                    run write-to-log( vss-workfile + chr(32)
                                    + substitute( " Ошибка выгрузки остатков товаров по поставщикам по расписанию. &1 "
                                                    , return-value
                                                )
                                    ) .
                end.
            end.
            else do:
                run bge/bge-stk.p (
                      input ?
                    , input -1
                    , input v-date-from
                    , input v-date-to
                    , input no
                    , input yes
                    , input p-db-num
                    , input v-obj-list
                    , input ?
                    , input ?
                ) no-error.
                if error-status :error
                then do:
                    run write-to-log( vss-workfile + chr(32)
                                    + substitute( " Ошибка выгрузки остатков товаров по расписанию. &1 "
                                                    , return-value
                                                )
                                    ) .
                end.
            end.
        end.
        if v-exp-fo = yes then do:
            run bge/bgefo.p (
                  input v-date-from
                , input v-date-to
                , input v-range
                , input v-obj-list
                , input ?
                , input ?
                ) no-error.
                if error-status :error
                then do:
                    run write-to-log( vss-workfile + chr(32)
                                    + substitute( " Ошибка выгрузки ФО по расписанию. &1 &2 "
                                                    , return-value, error-status :get-message(1)
                                                )
                                    ) .
                end.
        end.
        if v-exp-fp = yes then do:
            run bge/bgefdoc.p (
                  input v-date-from
                , input v-date-to
                , input v-initial-range
                , input "shd":U
                , input (if v-initial-range = 2 then v-host-code else 0)
                , input v-obj-list
                , input p-db-num
                , input cross-list(v-doc-type-list, 'пко,рко,ппп,рпп,апп,апр,':U, chr(44))
                , input ?
                , input ?
            ) no-error.
                if error-status :error
                then do:
                    run write-to-log( vss-workfile + chr(32)
                                    + substitute( " Ошибка выгрузки платежных документов по расписанию. &1 &2 "
                                                    , return-value, error-status :get-message(1)
                                                )
                                    ) .
                end.
        end.
        if v-exp-s-f = yes then do:
        end.
    end.
    else do:
        run write-to-log ( vss-workfile + chr(32) + " Выгрузка по расписанию. Флаг инкрементальной выгрузки включен. " ) .
        if v-exp-doc = yes
        then do:
            if v-shift-mode-on = yes
            then do:
                v-obj-list-shift = "".
                v-obj-list-noshift = "".
                do v-obj-counter = 1 to num-entries (v-obj-list) / 2:
                    assign
                    v-obj-list-type = entry(v-obj-counter * 2 - 1, v-obj-list)
                    v-obj-list-code = integer(entry(v-obj-counter * 2, v-obj-list)) no-error.
                    if not can-find(first buf_shift-obj
                        where buf_shift-obj.obj-type = v-obj-list-type
                          and buf_shift-obj.obj-code = v-obj-list-code)
                        then do:
                            assign
                            v-obj-list-noshift = v-obj-list-noshift + v-obj-list-type + ',' + string(v-obj-list-code) + ','.
                    end.
                    else do:
                        assign
                        v-obj-list-shift = v-obj-list-shift + v-obj-list-type + ',' + string(v-obj-list-code) + ','.
                    end.
                end.
                if v-obj-list-shift <> "" then do:
                run bge/shd-inch.p (
                      input p-db-num
                    , input v-range
                        , input v-obj-list-shift
                        , input v-exp-checks
                        , input v-exp-doc-rvs
                    ) no-error.
                    if error-status :error
                    then do:
                        run write-to-log ( vss-workfile + chr(32)
                                        + substitute( " Ошибка выгрузки по расписанию. &1 "
                                                        , return-value
                                                    )
                                        ) .
                        undo, return error .
                    end.
                end.
                if v-obj-list-noshift <> "" then do:
                    run bge/shd-incr.p (
                          input p-db-num
                        , input v-range
                        , input v-obj-list-noshift
                        , input v-exp-checks
                        , input v-exp-doc-rvs
                    ) no-error.
                    if error-status :error
                    then do:
                        run write-to-log ( vss-workfile + chr(32)
                                        + substitute( " Ошибка выгрузки по расписанию. &1 "
                                                        , return-value
                                                    )
                                        ) .
                        undo, return error .
                    end.
                end.
            end.
            else do:
                run bge/shd-incr.p (
                      input p-db-num
                    , input v-range
                    , input v-obj-list
                    , input v-exp-checks
                    , input v-exp-doc-rvs
                ) no-error.
                if error-status :error
                then do:
                    run write-to-log ( vss-workfile + chr(32)
                                    + substitute( " Ошибка выгрузки по расписанию. &1 "
                                                    , return-value
                                                )
                                    ) .
                    undo, return error .
                end.
            end.
        end.
        if v-exp-ref = yes
        then do:
            run bge/bge-ref.p (
                  input ?
                , input "good-ext"
                , input yes
                , input v-host-code
                , input ?
                , input ?
            ) no-error.
        end.
        if v-exp-fp = yes
        then do:
            run bge/shfdincr.p (
                  input p-db-num
                , input v-initial-range
                , input (if v-initial-range = 2 then v-host-code else 0)
                , input v-obj-list
            ) no-error.
            if error-status :error
            then do:
                run write-to-log ( vss-workfile + chr(32)
                                + substitute( " Ошибка выгрузки по расписанию. &1 "
                                                , return-value
                                            )
                                ) .
                undo, return error .
            end.
        end.
        if v-exp-fo = yes
        then do:
            run bge/shfoincr.p (
                  input p-db-num
                , input v-range
                , input v-obj-list
            ) no-error.
            if error-status :error
            then do:
                run write-to-log ( vss-workfile + chr(32)
                                + substitute( " Ошибка выгрузки по расписанию ФО. &1 "
                                                , return-value
                                            )
                                ) .
                undo, return error .
            end.
        end.
    end.
end.
procedure analyze-date-range :
do
on error undo, return error
:
define input parameter p-date-range         as character    no-undo.
define output parameter p-date-from         as date         no-undo.
define output parameter p-date-to           as date         no-undo.
    define variable v-today         as date      no-undo.
    define variable v-time          as integer   no-undo.
    define variable v-days-ago      as integer       no-undo.
    define variable v-days-amount   as integer       no-undo.
    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    case entry( 1, p-date-range )
    :
        when "0":U
        then do:
            assign
                v-days-ago    = integer( entry( 3, p-date-range ) )
                v-days-amount = integer( entry( 2, p-date-range ) )
            .
            assign
                p-date-from = v-today - v-days-ago
                p-date-to   = v-today - v-days-ago + v-days-amount
            .
            if p-date-to > v-today
            then do:
                assign
                  p-date-to = v-today
                .
            end.
        end.
        when "1":U
        then do:
            assign
                p-date-from = date( entry( 4, p-date-range ) )
                p-date-to   = v-today
            .
        end.
        when "2":U
        then do:
            assign
                p-date-from = date( entry( 4, p-date-range ) )
                p-date-to   = date( entry( 5, p-date-range ) )
            .
        end.
        otherwise do:
            assign
                p-date-from = ?
                p-date-to   = ?
            .
        end.
    end case.
end.
end procedure.
procedure fill-obj-list :
define input parameter p-range-in   as integer          no-undo.
define input parameter p-host-code  as integer          no-undo.
define output parameter p-range-out as integer          no-undo.
define output parameter p-obj-list  as character        no-undo.
    define variable v-obj-counter               as integer      no-undo.
    define buffer buf_clients   for ub.clients.
do
for buf_clients
on error undo, return error
:
    if p-range-in = 2
    and v-host-code = -1
    then do:
        assign
            p-range-in = 1
        .
    end.
    assign
        p-range-out = p-range-in
    .
    run init-temphost.
    case p-range-in
    :
        when 1
        then do:
            for each temp-obj
            :
                if temp-obj.db-num = p-db-num
                then do:
                    assign
                        p-obj-list = p-obj-list
                                        + ( if p-obj-list = "" then "" else "," )
                                        + temp-obj.obj-type
                                        + "," + string( temp-obj.obj-code )
                    .
                end.
            end.
            assign
                p-range-out  = 3
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
                        p-obj-list = p-obj-list
                                        + ( if p-obj-list = "" then "" else "," )
                                        + temp-obj.obj-type
                                        + "," + string( temp-obj.obj-code )
                    .
                end.
            end.
            assign
                p-range-out  = 3
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
                                    + substitute( " Ошибка выгрузки по расписанию: Не найден заданный объект &1 &2" + chr(10)
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
                            p-obj-list = p-obj-list
                                            + ( if p-obj-list = "" then "" else "," )
                                            + buf_clients.obj-type
                                            + "," + string( buf_clients.obj-code )
                        .
                    end.
                end.
            end.
        end.
    end case.
end.
end procedure.
