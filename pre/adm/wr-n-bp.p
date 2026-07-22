block-level on error undo, throw.
define input parameter parparentproc   as handle    no-undo .
define input parameter p-session-begin as logical   no-undo .
define input parameter p-task-type     as character no-undo .
define input parameter p-db-num        as character no-undo .
define input parameter p-for-extsys    as character no-undo .
define input parameter p-for-proc      as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: 784232a2254b, 2720, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пн янв 18 10:14:30 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wr-n-bp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/wr-n-bp.p $":U .
define variable vss-description as character no-undo init "запись следующего по расписанию задания".
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
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
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE LastDate:
    def input parameter in-date as date no-undo.
    def output parameter LastDate as date no-undo.
    LastDate = ((DATE(MONTH(in-date),28,YEAR(in-date)) + 4) - DAY(DATE(MONTH(in-date),28,YEAR(in-date)) + 4)).
END PROCEDURE.
define temp-table curr-task no-undo
  field db-num      as character column-label "БД" format "X(5)"
  field db-num-char as character column-label "БД" format "X(5)"
  field task-num    as integer   column-label "N задачи" format ">>>>>>>9"
  field task-type   as character
  field cre-db-num    as integer
  field task-date   as date      column-label "Дата"  format "99.99.9999"
  field task-time   as integer   column-label "Время"
  field task-free-id  as character column-label "ID произвольного задания"
  index pi is unique primary
    task-type
    db-num
    task-num
  index pii
    task-type
    db-num
    task-date
    task-time
.
define temp-table tt-weekday no-undo
  field weekday as integer
  index pi is unique primary
    weekday ascending
.
define temp-table tt-hour no-undo
  field hour as integer
  index pi is unique primary
    hour ascending
.
define temp-table tt-minute no-undo
  field minute as integer
  index pi is unique primary
    minute ascending
.
define temp-table tt-db no-undo
  field db-num as integer
  index pi is unique primary
    db-num ascending
.
procedure trans-task :
  define input parameter p-task-type as character no-undo .
  do
  on error undo, return error
  :
    define variable v-curr-weekday  as integer   no-undo .
    define variable v-today         as date      no-undo .
    define variable v-curr-time     as integer   no-undo .
    define variable v-curr-time-str as character no-undo .
    define variable v-curr-hour     as integer   no-undo .
    define variable v-curr-minute   as integer   no-undo .
    define variable v-curr-sec      as integer   no-undo .
    define variable v-task-date     as date      no-undo .
    define variable v-task-time     as integer   no-undo .
    define variable v-last-date     as date      no-undo .
    define variable v-num-entries   as integer   no-undo .
    define variable v-ind           as integer   no-undo .
    define variable v-set-task      as logical   no-undo .
    define variable v-task-time-h   as integer   no-undo .
    define variable v-first-hour    as integer   no-undo .
    define variable v-task-time-m   as integer   no-undo .
    define variable v-first-minute  as integer   no-undo .
    define variable v-create-task   as logical   no-undo .
    define buffer buf_schedule for ub.schedule .
    define buffer buf_db       for ub.db .
    define buffer buf_sys-ctrl for ub.sys-ctrl .
    find first buf_sys-ctrl no-lock .
    block_sch:
    for each buf_schedule no-lock
      where buf_schedule.cre-db-num = buf_sys-ctrl.db-num
        and buf_schedule.task-type  = p-task-type
        and buf_schedule.active     = TRUE
    on error undo, return error
    :
      assign
        v-today         = today
        v-curr-time     = time
        v-curr-time-str = string( time, "HH:MM:SS":U )
        v-curr-hour     = integer( entry( 1, v-curr-time-str, ":":U ) )
        v-curr-minute   = integer( entry( 2, v-curr-time-str, ":":U ) )
        v-curr-sec      = integer( entry( 3, v-curr-time-str, ":":U ) )
        v-task-date     = v-today
        v-task-time     = v-curr-time
      .
      if trim( buf_schedule.task-weekday ) <> "*":U then do:
        for each tt-weekday
        on error undo, return error return-value
        :
          delete tt-weekday.
        end.
        run gbl/prcs-lst.p
          ( input  buf_schedule.task-weekday
           ,input  1
           ,input  7
           ,input  false
           ,input (buffer tt-weekday:handle)
           ,input "weekday":U
          ) no-error .
        find first tt-weekday no-lock
          where tt-weekday.weekday >= weekday( v-task-date ) - 1
          no-error .
        if available tt-weekday then do:
          assign
            v-task-date = v-task-date + tt-weekday.weekday - weekday( v-task-date ) + 1
          .
        end.
        else do:
          for first tt-weekday no-lock
            by tt-weekday.weekday
          on error undo, return error return-value
          :
            assign
              v-task-date = v-task-date + 7 + tt-weekday.weekday - weekday( v-task-date + 7 ) + 1
            .
          end.
        end.
        if v-task-date < v-today then do:
          next block_sch.
        end.
      end.
      else do:
        if trim( buf_schedule.task-year ) <> "*":U then do:
          assign
            v-task-date = date( month( v-task-date )
                                ,day( v-task-date )
                                ,integer( buf_schedule.task-year )
                              )
          .
          if v-task-date < v-today then do:
            next block_sch.
          end.
        end.
        if trim( buf_schedule.task-month ) <> "*":U then do:
          assign
            v-task-date = date( integer( buf_schedule.task-month )
                                ,day( v-task-date )
                                ,year( v-task-date )
                              )
          .
          if v-task-date < v-today then do:
            run next-task-year ( input recid( buf_schedule )
                                ,input-output v-task-date
                              ) no-error.
            if error-status :error then do:
              next block_sch.
            end.
          end.
        end.
        if trim( buf_schedule.task-day ) <> "*":U then do:
          run lastdate in this-procedure
            (input  v-task-date
            ,output v-last-date
            ) no-error .
          if error-status :error then do:
            next block_sch.
          end.
          if integer( buf_schedule.task-day ) > day( v-last-date ) then do:
            next block_sch.
          end.
          assign
            v-task-date = date( month( v-task-date )
                               ,integer( buf_schedule.task-day )
                               ,year( v-task-date )
                              )
          .
          if v-task-date < v-today then do:
            run next-task-month in this-procedure
              ( input recid( buf_schedule )
               ,input-output v-task-date
              ) no-error.
            if error-status :error then do:
              next block_sch.
            end.
          end.
        end.
      end.
      if trim( buf_schedule.task-hour ) <> "*":U then do:
        for each tt-hour
        on error undo, return error return-value
        :
          delete tt-hour.
        end.
        run gbl/prcs-lst.p
          ( input  buf_schedule.task-hour
           ,input  0
           ,input  24
           ,input  false
           ,input (buffer tt-hour:handle)
           ,input "hour":U
          ) no-error .
        for first tt-hour no-lock
          by tt-hour.hour
        on error undo, return error return-value
        :
          assign
            v-first-hour = tt-hour.hour
          .
        end.
        if v-task-date > v-today then do:
          assign
            v-task-time = v-task-time + ( v-first-hour - v-curr-hour ) * 3600
          .
        end.
        else do:
          if v-task-date = v-today then do:
            assign
              v-task-time-h = v-task-time
              v-set-task    = false
            .
            block_hour:
            for each tt-hour no-lock
              by tt-hour.hour
            on error undo, return error return-value
            :
              assign
                v-task-time-h = v-task-time + ( tt-hour.hour - v-curr-hour ) * 3600
              .
              if v-task-time-h >= v-curr-time then do:
                assign
                  v-task-time = v-task-time-h
                  v-set-task  = true
                .
                leave block_hour.
              end.
            end.
            if v-task-time < v-curr-time
              or v-set-task = false
            then do:
              assign
                v-task-time = v-task-time + ( v-first-hour - v-curr-hour ) * 3600
              .
              run next-task-day ( input recid( buf_schedule )
                                 ,input-output v-task-date
                                ) no-error.
              if error-status :error then do:
                next block_sch.
              end.
            end.
          end.
        end.
      end.
      else do:
        if v-task-date > v-today then do:
          assign
            v-task-time = v-task-time + ( 0 - v-curr-hour ) * 3600
          .
        end.
      end.
      if trim( buf_schedule.task-minute ) <> "*":U then do:
        for each tt-minute
        on error undo, return error return-value
        :
          delete tt-minute.
        end.
        run gbl/prcs-lst.p
          ( input buf_schedule.task-minute
           ,input 0
           ,input 60
           ,input false
           ,input (buffer tt-minute:handle)
           ,input "minute":U
          ) no-error .
        for first tt-minute no-lock
          by tt-minute.minute
        on error undo, return error return-value
        :
          assign
            v-first-minute = tt-minute.minute
          .
        end.
        if v-task-date > v-today then do:
          assign
            v-task-time = v-task-time + ( v-first-minute - v-curr-minute ) * 60
          .
        end.
        else do:
          if v-task-date = v-today then do:
            assign
              v-task-time-m = v-task-time
              v-set-task    = false
            .
            block_minute:
            for each tt-minute no-lock
              by tt-minute.minute
            on error undo, return error return-value
            :
              assign
                v-task-time-m = v-task-time + ( tt-minute.minute - v-curr-minute ) * 60
              .
              if v-task-time-m >= v-curr-time then do:
                assign
                  v-task-time = v-task-time-m
                  v-set-task  = true
                .
                leave block_minute.
              end.
            end.
            if v-task-time < v-curr-time
              or v-set-task = false
            then do:
              assign
                v-task-time = v-task-time + ( v-first-minute - v-curr-minute ) * 60
              .
              run next-task-hour ( input recid( buf_schedule )
                                  ,input-output v-task-date
                                  ,input-output v-task-time
                                ) no-error.
              if error-status :error then do:
                next block_sch.
              end.
            end.
          end.
        end.
      end.
      else do:
        assign
          v-task-time-h = integer( entry( 1, string( v-task-time, "HH:MM:SS":U ), ":":U ) )
        .
        if v-task-date > v-today
          or ( v-task-date = v-today
               and v-task-time-h > v-curr-hour
             )
        then do:
          assign
            v-task-time = v-task-time + ( 0 - v-curr-minute ) * 60
          .
        end.
      end.
      if trim( buf_schedule.task-second ) <> "*":U then do:
        assign
          v-task-time = v-task-time - v-curr-sec + integer( buf_schedule.task-second )
        .
        if v-task-date = v-today
          and v-task-time + 10 <= v-curr-time
        then do:
          run next-task-minute ( input recid( buf_schedule )
                                ,input-output v-task-date
                                ,input-output v-task-time
                               ) no-error.
          if error-status :error then do:
            next block_sch.
          end.
        end.
      end.
      if v-task-date = v-today
        and v-task-time <= v-curr-time
      then do:
        run next-task-minute ( input recid( buf_schedule )
                              ,input-output v-task-date
                              ,input-output v-task-time
                              ) no-error.
        if error-status :error then do:
          next block_sch.
        end.
      end.
      if buf_schedule.db-num-char <> "*":U then do:
        for each tt-db
        on error undo, return error return-value
        :
          delete tt-db.
        end.
        run gbl/prcs-lst.p
          ( input buf_schedule.db-num-char
          ,input 0
          ,input 99999
          ,input false
          ,input (buffer tt-db:handle)
          ,input "db-num":U
          ) no-error .
      end.
      for each buf_db no-lock
      on error undo, return error return-value
      :
        assign
          v-create-task = true
        .
        if buf_schedule.db-num-char <> "*":U then do:
          find first tt-db no-lock
            where tt-db.db-num = buf_db.db-num
            no-error .
          if not available tt-db then do:
            assign
              v-create-task = false
            .
          end.
        end.
        if v-create-task = true then do:
          create curr-task .
          assign
            curr-task.db-num      = string( buf_db.db-num )
            curr-task.db-num-char = buf_schedule.db-num-char
            curr-task.task-num    = buf_schedule.task-num
            curr-task.task-type   = buf_schedule.task-type
            curr-task.cre-db-num    = buf_schedule.cre-db-num
            curr-task.task-date   = v-task-date
            curr-task.task-time   = v-task-time
          .
        end.
      end.
    end.
    for each tt-weekday
    on error undo, return error return-value
    :
      delete tt-weekday.
    end.
    for each tt-hour
    on error undo, return error return-value
    :
      delete tt-hour.
    end.
    for each tt-minute
    on error undo, return error return-value
    :
      delete tt-minute.
    end.
    for each tt-db
    on error undo, return error return-value
    :
      delete tt-db.
    end.
  end.
end procedure.
procedure next-task-year :
  define input        parameter p-recid-sch as recid no-undo .
  define input-output parameter p-task-date as date no-undo.
  do
  on error undo, return error
  :
    define buffer buf_schedule for ub.schedule .
    find first buf_schedule no-lock
      where recid( buf_schedule ) = p-recid-sch
    .
    if trim( buf_schedule.task-year ) <> "*":U then do:
      assign
        p-task-date = ?
      .
      return error.
    end.
    else do:
      if month( p-task-date ) = 2
        and day( p-task-date ) = 29
      then do:
        if trim( buf_schedule.task-day ) <> "*":U then do:
          assign
            p-task-date = date( month( p-task-date )
                                ,day( p-task-date )
                                ,year( p-task-date ) + 4
                              )
          .
        end.
        else do:
          assign
            p-task-date = date( month( p-task-date )
                                ,28
                                ,year( p-task-date ) + 1
                              )
          .
        end.
      end.
      else do:
        assign
          p-task-date = date( month( p-task-date )
                              ,day( p-task-date )
                              ,year( p-task-date ) + 1
                            )
        .
      end.
    end.
  end.
end procedure.
procedure next-task-month :
  define input        parameter p-recid-sch as recid no-undo .
  define input-output parameter p-task-date as date no-undo.
  do
  on error undo, return error
  :
    define variable v-date      as date no-undo .
    define variable v-last-date as date no-undo .
    define buffer buf_schedule for ub.schedule .
    find first buf_schedule no-lock
      where recid( buf_schedule ) = p-recid-sch
    .
    if trim( buf_schedule.task-month ) <> "*":U then do:
      run next-task-year ( input p-recid-sch
                          ,input-output p-task-date
                         ) no-error.
      if error-status :error then do:
        assign
          p-task-date = ?
        .
        return error.
      end.
    end.
    else do:
      if month( p-task-date ) = 12 then do:
        assign
          p-task-date = date( 1
                             ,day( p-task-date )
                             ,year( p-task-date )
                             )
        .
        run next-task-year ( input p-recid-sch
                            ,input-output p-task-date
                          ) no-error.
        if error-status :error then do:
          assign
            p-task-date = ?
          .
          return error.
        end.
      end.
      else do:
        assign
          v-date = date( month( p-task-date ) + 1
                        ,1
                        ,year( p-task-date )
                       )
        .
        run lastdate in this-procedure
          ( input  v-date
           ,output v-last-date
          ) no-error .
        if error-status :error then do:
          assign
            p-task-date = ?
          .
          return error.
        end.
        if day( p-task-date ) > day( v-last-date ) then do:
          if trim( buf_schedule.task-day ) <> "*":U then do:
            do while true :
              assign
                v-date = date( month( v-date ) + 1
                              ,1
                              ,year( v-date )
                            )
              .
              run lastdate in this-procedure
                ( input  v-date
                 ,output v-date
                ) no-error .
              if error-status :error then do:
                assign
                  p-task-date = ?
                .
                return error.
              end.
              if day( p-task-date ) = day( v-date ) then do:
                assign
                  p-task-date = v-date
                .
                leave.
              end.
            end.
          end.
          else do:
            assign
              p-task-date = v-last-date
            .
          end.
        end.
        else do:
          assign
            p-task-date = date( month( p-task-date ) + 1
                               ,day( p-task-date )
                               ,year( p-task-date )
                              )
          .
        end.
      end.
    end.
  end.
end procedure.
procedure next-task-day :
  define input        parameter p-recid-sch as recid no-undo .
  define input-output parameter p-task-date as date no-undo.
  do
  on error undo, return error
  :
    define buffer buf_schedule for ub.schedule .
    find first buf_schedule no-lock
      where recid( buf_schedule ) = p-recid-sch
    .
    if trim( buf_schedule.task-weekday ) <> "*":U then do:
      find first tt-weekday no-lock
        where tt-weekday.weekday > weekday( p-task-date ) - 1
        no-error .
      if available tt-weekday then do:
        assign
          p-task-date = p-task-date + tt-weekday.weekday - weekday( p-task-date ) + 1
        .
      end.
      else do:
        for first tt-weekday no-lock
          by tt-weekday.weekday
        on error undo, return error return-value
        :
          assign
            p-task-date = p-task-date + 7 + tt-weekday.weekday - weekday( p-task-date + 7 ) + 1
          .
        end.
      end.
    end.
    else do:
      if trim( buf_schedule.task-day ) <> "*":U then do:
        run next-task-month ( input p-recid-sch
                            ,input-output p-task-date
                            ) no-error.
        if error-status :error then do:
          assign
            p-task-date = ?
          .
          return error.
        end.
      end.
      else do:
        if month( p-task-date ) <> month( p-task-date + 1 ) then do:
          assign
            p-task-date = date( month( p-task-date )
                                ,1
                                ,year( p-task-date )
                              )
          .
          run next-task-month ( input p-recid-sch
                              ,input-output p-task-date
                              ) no-error.
          if error-status :error then do:
            assign
              p-task-date = ?
            .
            return error.
          end.
        end.
        else do:
          assign
            p-task-date = p-task-date + 1
          .
        end.
      end.
    end.
  end.
end procedure.
procedure next-task-hour :
  define input        parameter p-recid-sch as recid   no-undo .
  define input-output parameter p-task-date as date    no-undo.
  define input-output parameter p-task-time as integer no-undo.
  do
  on error undo, return error
  :
    define buffer buf_schedule for ub.schedule .
    define variable v-task-hour as integer   no-undo .
    find first buf_schedule no-lock
      where recid( buf_schedule ) = p-recid-sch
    .
    if trim( buf_schedule.task-hour ) <> "*":U then do:
      assign
        v-task-hour = integer( entry( 1, string( p-task-time, "HH:MM:SS":U ), ":":U ) )
      .
      find first tt-hour no-lock
        where tt-hour.hour > v-task-hour
        no-error .
      if available tt-hour then do:
        assign
          p-task-time = p-task-time + ( tt-hour.hour - v-task-hour ) * 3600
        .
      end.
      else do:
        for first tt-hour no-lock
          by tt-hour.hour
        on error undo, return error return-value
        :
          assign
            p-task-time = p-task-time + ( tt-hour.hour - v-task-hour ) * 3600
          .
        end.
        run next-task-day ( input p-recid-sch
                          ,input-output p-task-date
                          ) no-error.
        if error-status :error then do:
          assign
            p-task-date = ?
            p-task-time = ?
          .
          return error.
        end.
      end.
    end.
    else do:
      if p-task-time + 3600 >= 86400 then do:
        run next-task-day ( input p-recid-sch
                           ,input-output p-task-date
                          ) no-error.
        if error-status :error then do:
          assign
            p-task-date = ?
            p-task-time = ?
          .
          return error.
        end.
        assign
          p-task-time = p-task-time + 3600 - 86400
        .
      end.
      else do:
        assign
          p-task-time = p-task-time + 3600
        .
      end.
    end.
  end.
end procedure.
procedure next-task-minute :
  define input        parameter p-recid-sch as recid   no-undo .
  define input-output parameter p-task-date as date    no-undo.
  define input-output parameter p-task-time as integer no-undo.
  do
  on error undo, return error
  :
    define buffer buf_schedule for ub.schedule .
    define variable v-task-minute as integer   no-undo .
    find first buf_schedule no-lock
      where recid( buf_schedule ) = p-recid-sch
    .
    if trim( buf_schedule.task-minute ) <> "*":U then do:
      assign
        v-task-minute = integer( entry( 2, string( p-task-time, "HH:MM:SS":U ), ":":U ) )
      .
      find first tt-minute no-lock
        where tt-minute.minute > v-task-minute
        no-error .
      if available tt-minute then do:
        assign
          p-task-time = p-task-time + ( tt-minute.minute - v-task-minute ) * 60
        .
      end.
      else do:
        for first tt-minute no-lock
          by tt-minute.minute
        on error undo, return error return-value
        :
          assign
            p-task-time = p-task-time + ( tt-minute.minute - v-task-minute ) * 60
          .
        end.
        run next-task-hour ( input p-recid-sch
                            ,input-output p-task-date
                            ,input-output p-task-time
                          ) no-error.
        if error-status :error then do:
          assign
            p-task-date = ?
            p-task-time = ?
          .
          return error.
        end.
      end.
    end.
    else do:
      if truncate( p-task-time / 3600, 0 ) <> truncate( ( p-task-time + 60 ) / 3600, 0 ) then do:
        run next-task-hour ( input p-recid-sch
                            ,input-output p-task-date
                            ,input-output p-task-time
                          ) no-error.
        if error-status :error then do:
          assign
            p-task-date = ?
            p-task-time = ?
          .
          return error.
        end.
        assign
          p-task-time = p-task-time + 60 - 3600
        .
      end.
      else do:
        assign
          p-task-time = p-task-time + 60
        .
      end.
    end.
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure db-attr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-value :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-value     like ub.db-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-value in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-write :
  define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input parameter p-code      like ub.db-attr.attr-code  no-undo .
  define input parameter p-value     like ub.db-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-write in g#attr-lib
      (input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-exist :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-delete :
  define input  parameter p-db-num   like ub.db-attr.db-num     no-undo .
  define input  parameter p-code     like ub.db-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  function get-attr-code returns character (input p-task-type as character ).
    define variable v-db-attr-code as character no-undo .
    case p-task-type :
      when 'autonws':U then do:
        assign
          v-db-attr-code = 'schedule-nws':U.
        .
      end.
      when 'autoarh':U then do:
        assign
          v-db-attr-code = 'schedule-arc':U
        .
      end.
      when 'autoexp':U then do:
        assign
          v-db-attr-code = 'schedule-exp':U
        .
      end.
      when 'autooxml':U then do:
        assign
          v-db-attr-code = 'schedule-oxml':U
        .
      end.
      when 'autogcd':U then do:
        assign
          v-db-attr-code = 'schedule-getcd':U
        .
      end.
      when 'autosale':U then do:
        assign
          v-db-attr-code = 'schedule-sale':U
        .
      end.
      when 'autosuz':U then do:
        assign
          v-db-attr-code = 'schedule-suz':U
        .
      end.
      when 'autocbnk':U then do:
        assign
          v-db-attr-code = 'schedule-cbnk':U
        .
      end.
      when 'autofree':U then do:
        assign
          v-db-attr-code = 'schedule-free':U
        .
      end.
      when 'mercury':U then do:
        assign
          v-db-attr-code = 'schedule-merc':U
        .
      end.
      when 'hddtest':U then do:
        assign
          v-db-attr-code = 'schedule-hdd':U
        .
      end.
      when 'is_motp':U then do:
        assign
          v-db-attr-code = 'schedule-motp':U
        .
      end.
      when 'is_diadoc':U then do:
        assign
          v-db-attr-code = 'schedule-diadoc':U
        .
      end.
      when 'is_PM':U then do:
        assign
          v-db-attr-code = 'schedule-isPM':U
        .
      end.
      otherwise do:
        assign
          v-db-attr-code = ?
        .
      end.
    end.
    return v-db-attr-code.
  end function.
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
      return error substitute( "&1. Ошибка при определении текущей даты!", vss-include-info6 ).
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
      return error substitute( "&1. НЕТ ОБРАБОТКИ АТРИБУТА &2!", vss-include-info6, p-task-type ).
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define buffer buf_BatchProcess for ub.BatchProcess .
  define buffer buf_db           for ub.db .
  define buffer buf_sys-ctrl     for ub.sys-ctrl .
  define variable v-str                 as character no-undo .
  define variable v-db-wait             as character no-undo .
  define variable num-entries-v-db-wait as integer   no-undo .
  define variable v-db-list             as character no-undo .
  define variable num-entries-v-db-list as integer   no-undo .
  define variable v-db-num              as character no-undo .
  define variable ind                   as integer   no-undo .
  define variable v-date                as date      no-undo .
  define variable v-time                as integer   no-undo .
  define variable v-user-id             as character no-undo .
  define variable v-recid               as recid     no-undo .
  define variable db-attr-code          as character no-undo .
  define variable db-attr-value         as character no-undo .
  define variable db-attr-type          as character no-undo .
  define variable db-attr-exist         as logical   no-undo .
  define variable v-free-id             as character no-undo .
  if transaction = true then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Вызов данной процедуры не возможен при наличии транзакции" )
      view-as alert-box error
    .
    return error substitute( "&1. Вызов данной процедуры не возможен при наличии активной транзакции.", vss-workfile ).
  end.
  assign
    v-str        = get-str-type( p-task-type )
    db-attr-code = get-attr-code( p-task-type )
  .
  if v-str = ? then do:
    return error string( vss-workfile + chr(32) + "НЕТ ОБРАБОТКИ АТРИБУТА" + chr(32) + p-task-type ) .
  end.
  run trans-task( input p-task-type ) no-error.
  if error-status:error then do:
    run write-to-log( vss-workfile + chr(32)
                      + "Ошибка при выполнении процедуры преобразования расписания." + chr(10)
                      + error-status:get-message(error-status:num-messages) + chr(10)
                      + return-value
                    ) .
    return error.
  end.
  assign
    v-db-wait = "":U
  .
  if p-db-num <> "*":U then do:
    assign
      v-db-list = p-db-num
    .
  end.
  else do:
    assign
      v-db-list = "":U
    .
  end.
  find first buf_sys-ctrl no-lock.
  if p-task-type = 'autonws':U
     and buf_sys-ctrl.db-num <> 0
  then do:
    run db-attr-value ( input 0
                       ,input db-attr-code
                       ,output db-attr-value
                       ,output db-attr-type
                      ) no-error.
    if error-status :error then do:
      run write-to-log( vss-workfile + chr(32)
                        + "Ошибка при чтении атрибута наличия расписания для БД" + chr(32) + v-db-num
                      ) .
    end.
    if v-db-list = "":U then do:
      if db-attr-value = "no":U then do:
        assign
          v-db-list = "0":U
        .
      end.
      else do:
        assign
          v-db-wait = "0":U
        .
      end.
    end.
  end.
  else do:
    _db:
    for each buf_db no-lock
    on error  undo, return error substitute( "&1 (for each db). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1 (for each db). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (for each db). endkey", vss-workfile )
    :
      if p-task-type = 'autonws':U
         and ( buf_db.db-num = 0
               or buf_db.db-key = "":U
               or buf_db.db-key = ?
             )
      then do:
        next.
      end.
      if (p-task-type = 'autosale':U
      or p-task-type = 'autogcd':U
      or p-task-type = 'autocbnk':U
      or p-task-type = 'autooxml':U
      or p-task-type = 'autosuz':U
      or p-task-type = 'autofree':U
      or p-task-type = 'hddtest':U
      )
         and buf_db.db-num <> buf_sys-ctrl.db-num
      then do:
        next _db.
      end.
      run db-attr-value ( input buf_db.db-num
                         ,input db-attr-code
                         ,output db-attr-value
                         ,output db-attr-type
                        ) no-error.
      if error-status :error then do:
        run write-to-log( vss-workfile + chr(32)
                          + "Ошибка при чтении атрибута наличия расписания для БД" + chr(32) + v-db-num
                        ) .
      end.
      if lookup( string( buf_db.db-num ), v-db-list, chr(44) ) = 0 then do:
        if p-db-num = "*":U
          or db-attr-value = "no":U
        then do:
          if v-db-list = "":U then do:
            assign
              v-db-list = string( buf_db.db-num )
            .
          end.
          else do:
            assign
              v-db-list = v-db-list + chr(44) + string( buf_db.db-num )
            .
          end.
        end.
        else do:
          if v-db-wait = "":U then do:
            assign
              v-db-wait = string( buf_db.db-num )
            .
          end.
          else do:
            assign
              v-db-wait = v-db-wait + chr(44) + string( buf_db.db-num )
            .
          end.
        end.
      end.
    end.
  end.
  assign
    num-entries-v-db-list = num-entries( v-db-list )
  .
  do ind = 1 to num-entries-v-db-list
  on error  undo, return error substitute( "&1 (v-db-list). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (v-db-list). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (v-db-list). endkey", vss-workfile )
  :
    assign
      v-db-num = entry( ind, v-db-list )
      v-recid  = ?
    .
    if v-db-num = "*":U
      or v-db-num = "":U
    then do:
      next.
    end.
    run cur-time ( output v-date
                  ,output v-time
                 ).
    if p-task-type = 'autofree':U and p-for-proc <> "" then do:
      for each curr-task where curr-task.task-type = 'autofree':U:
        run schedule-attr-get-free-id (input curr-task.cre-db-num
                                      ,input curr-task.task-type
                                      ,input curr-task.task-num
                                      ,output v-free-id) no-error.
        curr-task.task-free-id = v-free-id .
      end.
    end.
    find first curr-task no-lock
      where curr-task.task-type = p-task-type
        and curr-task.db-num    = v-db-num
        and curr-task.task-date = v-date
        and curr-task.task-time > v-time
        and (p-for-proc = "" or lookup (string(curr-task.task-free-id), p-for-proc) > 0)
      no-error
    .
    if not available curr-task then do:
      find first curr-task no-lock
        where curr-task.task-type = p-task-type
          and curr-task.db-num    = v-db-num
          and curr-task.task-date > v-date
          and (p-for-proc = "" or lookup (string(curr-task.task-free-id), p-for-proc) > 0)
        no-error
      .
    end.
    do transaction
    on error  undo, return error substitute( "&1 (do transaction). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1 (do transaction). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (do transaction). endkey", vss-workfile )
    :
      find first buf_BatchProcess exclusive-lock
        where buf_BatchProcess.BP_Status   = 'N':U
          and buf_BatchProcess.BP_Type     = p-task-type
          and buf_BatchProcess.CharKey_One = v-db-num
          and buf_BatchProcess.CharKey_Two = "auto":U
          and (p-task-type <> 'autooxml':U or
                (p-task-type = 'autooxml':U and
                  (  (num-entries (buf_BatchProcess.CharKey_Three, chr(3)) <= 3 and p-for-extsys = ""
                      )
                  or (p-for-extsys <> ""
                      and num-entries (buf_BatchProcess.CharKey_Three, chr(3)) > 3
                      and entry (4, buf_BatchProcess.CharKey_Three, chr(3)) = p-for-extsys
                      )
                   )
                 )
               )
          and (p-task-type <> 'autofree':U or
                (p-task-type = 'autofree':U and
                  (  (num-entries (buf_BatchProcess.CharKey_Three, chr(3)) <= 3 and p-for-proc = ""
                      )
                  or (p-for-proc <> ""
                      and num-entries (buf_BatchProcess.CharKey_Three, chr(3)) > 3
                      and entry (4, buf_BatchProcess.CharKey_Three, chr(3)) = p-for-proc
                      )
                   )
                 )
               )
        no-error
      .
      run db-attr-exist ( input v-db-num
                        ,input  db-attr-code
                        ,output db-attr-exist
                        ) no-error.
      if error-status :error then do:
        run write-to-log( vss-workfile + chr(32)
                          + "Ошибка при определении наличия атрибута расписания для БД" + chr(32) + v-db-num
                        ) .
      end.
      run db-attr-value ( input  v-db-num
                        ,input  db-attr-code
                        ,output db-attr-value
                        ,output db-attr-type
                        ) no-error.
      if error-status :error then do:
        run write-to-log( vss-workfile + chr(32)
                          + "Ошибка при чтении атрибута наличия расписания для БД" + chr(32) + v-db-num
                        ) .
      end.
      if not available curr-task then do:
        if db-attr-value = "yes":U
          or db-attr-exist = false
          or p-session-begin = true
        then do:
          if p-task-type <> 'mercury':U
          and p-task-type <> 'is_PM':U
          then
          run write-to-log( substitute( "Для БД &1 &2 не составлено расписание!", v-db-num, if p-for-proc <> "" then "и процесса произвольного задания " + p-for-proc else "") ).
          run db-attr-write ( input v-db-num
                            ,input db-attr-code
                            ,input no
                            ) no-error.
          if error-status :error then do:
            run write-to-log( substitute( "&1. Ошибка при записи атрибута отсутствия расписания для БД &2"
                                        ,vss-workfile
                                        ,v-db-num
                                        )
                            ) .
          end.
        end.
        if available buf_BatchProcess
          and ( buf_BatchProcess.BP_ExecSysDate < v-date
                or ( buf_BatchProcess.BP_ExecSysDate = v-date
                    and buf_BatchProcess.BP_ExecSysTimeInt < v-time
                  )
              )
        then do:
          delete buf_BatchProcess.
        end.
        next.
      end.
      run get-userid in parparentproc
        ( output v-user-id
        ).
      if not available buf_BatchProcess then do:
        create buf_BatchProcess.
        assign
          buf_BatchProcess.BatchProcess# = next-value (s-btpr, ub)
          buf_BatchProcess.BP_Type       = p-task-type
          buf_BatchProcess.BP_Status     = 'N':U
          buf_BatchProcess.CharKey_One   = v-db-num
          buf_BatchProcess.CharKey_Two   = "auto":U
        .
      end.
      assign
        buf_BatchProcess.CharKey_Three     = substitute( "&1&2&3&2&4&5", buf_sys-ctrl.db-num, chr(3), curr-task.task-type, curr-task.task-num,
            if (p-for-extsys <> "" and p-task-type = 'autooxml':U) then chr(3) + p-for-extsys else
                if (p-for-proc <> "" and p-task-type = 'autofree':U) then chr(3) + p-for-proc else "")
        buf_BatchProcess.User_ID           = v-user-id
        buf_BatchProcess.Key#_One          = 0
        buf_BatchProcess.BP_SysDate        = v-date
        buf_BatchProcess.BP_SysTimeInt     = v-time
        buf_BatchProcess.BP_SysTime        = string(v-time, 'HH:MM:SS':U)
        buf_BatchProcess.BP_ExecSysDate    = curr-task.task-date
        buf_BatchProcess.BP_ExecSysTimeInt = curr-task.task-time
        buf_BatchProcess.BP_ExecSysTime    = string(curr-task.task-time, 'HH:MM:SS':U)
      .
      run write-to-log( "Следующий сеанс" + chr(32) + v-str
                        + chr(32) + v-db-num
                        + chr(32) + "после" + chr(32) + buf_BatchProcess.BP_ExecSysTime
                        + chr(32) + string( buf_BatchProcess.BP_ExecSysDate , "99.99.9999" )
                      ) .
      run db-attr-write ( input v-db-num
                        ,input db-attr-code
                        ,input "yes":U
                        ) no-error.
      if error-status :error then do:
        run write-to-log( vss-workfile + chr(32)
                          + "Ошибка при записи атрибута наличия расписание для БД" + chr(32) + v-db-num
                        ) .
      end.
    end.
  end.
  if p-session-begin = true then do:
    assign
      num-entries-v-db-wait = num-entries( v-db-wait )
    .
    do ind = 1 to num-entries-v-db-wait
    on error  undo, return error substitute( "&1 (v-db-wait). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1 (v-db-wait). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (v-db-wait). endkey", vss-workfile )
    :
      find first buf_BatchProcess no-lock
        where buf_BatchProcess.BP_Status   = 'N':U
          and buf_BatchProcess.BP_Type     = p-task-type
          and buf_BatchProcess.CharKey_One = entry( ind, v-db-wait )
          and buf_BatchProcess.CharKey_Two = "auto":U
          and (p-task-type <> 'autooxml':U or
                (p-task-type = 'autooxml':U and
                  (  (num-entries (buf_BatchProcess.CharKey_Three, chr(3)) <= 3 and p-for-extsys = ""
                      )
                  or (p-for-extsys <> ""
                      and num-entries (buf_BatchProcess.CharKey_Three, chr(3)) > 3
                      and entry (4, buf_BatchProcess.CharKey_Three, chr(3)) = p-for-extsys
                      )
                   )
                 )
               )
          and (p-task-type <> 'autofree':U or
                (p-task-type = 'autofree':U and
                  (  (num-entries (buf_BatchProcess.CharKey_Three, chr(3)) <= 3 and p-for-proc = ""
                      )
                  or (p-for-proc <> ""
                      and num-entries (buf_BatchProcess.CharKey_Three, chr(3)) > 3
                      and entry (4, buf_BatchProcess.CharKey_Three, chr(3)) = p-for-proc
                      )
                   )
                 )
               )
        no-error
      .
      if available buf_BatchProcess then do:
        run write-to-log( "Очередной сеанс" + chr(32) + v-str
                          + chr(32) + entry( ind, v-db-wait )
                          + chr(32) + "после" + chr(32) + buf_BatchProcess.BP_ExecSysTime
                          + chr(32) + string( buf_BatchProcess.BP_ExecSysDate , "99.99.9999" )
                        ) .
      end.
    end.
  end.
  for each buf_db no-lock
  on error  undo, return error substitute( "&1 (for each db 2). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (for each db 2). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (for each db 2). endkey", vss-workfile )
  :
    find first buf_BatchProcess exclusive-lock
      where buf_BatchProcess.BP_Status   = 'N':U
        and buf_BatchProcess.BP_Type     = p-task-type
        and buf_BatchProcess.CharKey_One = string( buf_db.db-num )
        and buf_BatchProcess.CharKey_Two = "auto":U
        and (p-task-type <> 'autooxml':U or
              (p-task-type = 'autooxml':U and
                (  (num-entries (buf_BatchProcess.CharKey_Three, chr(3)) <= 3 and p-for-extsys = ""
                    )
                or (p-for-extsys <> ""
                    and num-entries (buf_BatchProcess.CharKey_Three, chr(3)) > 3
                    and entry (4, buf_BatchProcess.CharKey_Three, chr(3)) = p-for-extsys
                    )
                 )
               )
             )
          and (p-task-type <> 'autofree':U or
                (p-task-type = 'autofree':U and
                  (  (num-entries (buf_BatchProcess.CharKey_Three, chr(3)) <= 3 and p-for-proc = ""
                      )
                  or (p-for-proc <> ""
                      and num-entries (buf_BatchProcess.CharKey_Three, chr(3)) > 3
                      and entry (4, buf_BatchProcess.CharKey_Three, chr(3)) = p-for-proc
                      )
                   )
                 )
               )
      no-error
    .
    if available buf_BatchProcess
      and lookup( string(buf_db.db-num), v-db-list ) = 0
      and lookup( string(buf_db.db-num), v-db-wait ) = 0
    then do:
      delete buf_BatchProcess.
    end.
  end.
end.
return.
