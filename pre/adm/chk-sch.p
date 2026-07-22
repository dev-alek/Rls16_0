block-level on error undo, throw.
define temp-table tt-BatchProcess
 field BP_Type as char
 field CharKey_One as char
 field CharKey_Two as char
 field CharKey_Three as char
 field BP_ExecSysDate as date
 field BP_ExecSysTimeInt as int
 index dt BP_ExecSysDate BP_ExecSysTimeInt.
define input  parameter p-task-type   as character no-undo .
define input  parameter p-for-db      as longchar no-undo .
define output parameter p-list-db     as character no-undo .
define output parameter p-list-db-All as character no-undo .
define output parameter p-list-key     as character no-undo .
define output parameter p-list-key-all  as character no-undo .
define input  parameter p-for-extsys  as character no-undo .
define input  parameter p-for-proc    as character no-undo .
define output parameter table for tt-BatchProcess .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "проверка необходимости выполнения действия по расписанию".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE verify-ini-entry:
DEFINE INPUT  PARAMETER ini-key-name     as character no-undo.
DEFINE INPUT  PARAMETER ini-section-name as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text   as character no-undo.
DEFINE INPUT  PARAMETER silence          as logical no-undo.
DEFINE OUTPUT PARAMETER ini-entry-value  as character no-undo INIt ?.
define variable v-mess as character no-undo .
get-key-value section ini-section-name key ini-key-name value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "spl"
then
get-key-value section ini-section-name key "splall" value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "sav"
then
get-key-value section ini-section-name key "savall" value ini-entry-value.
if ini-entry-value = ? then do:
  assign
  v-mess = substitute("Ошибка ini - файла:&1Секция &2&1Ключ &3&1&4"
                    , chr(10)
                    , ini-section-name
                    , ini-key-name
                    , error-msg-text).
    if not silence then do:
      message
      v-mess
      view-as alert-box ERROR  .
      return error.
    end.
    else do:
      return error v-mess.
    end.
end.
END PROCEDURE.
PROCEDURE verify-file:
DEFINE INPUT  PARAMETER filename       as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text as character no-undo.
DEFINE INPUT  PARAMETER silence        as logical no-undo.
DEFINE OUTPUT PARAMETER found          as logical no-undo.
file-info:file-name = filename.
found = NOT (file-info:full-pathname = ?).
if NOT found  then do:
  if not silence then do:
    message error-msg-text
    view-as alert-box ERROR.
    return error.
  end.
  else return error error-msg-text.
end.
END PROCEDURE.
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1. Ошибка при определении текущей даты!", vss-include-info5 ).
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
      return error substitute( "&1. НЕТ ОБРАБОТКИ АТРИБУТА &2!", vss-include-info5, p-task-type ).
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
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define temp-table tt-db no-undo
    field db-num as integer
    index pi is unique primary
      db-num ascending
  .
  define buffer buf_sys-ctrl         for ub.sys-ctrl .
  define buffer buf_db               for ub.db .
  define buffer buf_schedule         for ub.schedule .
  define buffer buf_BatchProcess     for ub.BatchProcess .
  define buffer buf-all_BatchProcess for ub.BatchProcess .
  define variable v-str           as character no-undo .
  define variable v-db-attr-value as character no-undo .
  define variable v-db-attr-type  as character no-undo .
  define variable v-db-attr-code  as character no-undo .
  define variable v-db-attr-exist as logical   no-undo .
  define variable v-db-attr-del   as logical   no-undo .
  define variable v-time          as integer   no-undo .
  define variable v-today         as date      no-undo .
  define variable v-new-time      as character no-undo .
  define variable v-new-date      as date      no-undo .
  define variable v-user-id       as character no-undo .
  define variable v-process       as character no-undo .
  define variable v-chg-manual    as logical   no-undo .
  define variable v-out           as character no-undo.
  define variable vWaitNextRunTime as logical no-undo.
  run cur-time( output v-today
               ,output v-time
              ) no-error.
  if error-status :error then do:
    run write-to-log( vss-workfile + chr(32)
                      + "Ошибка при определении текущего времени"
                    ) .
  end.
  run verify-ini-entry in this-procedure (
                                         input  'WaitNextRunTime'
                                        ,input    'schedule-free'
                                        ,input substitute("отсутствует параметр &1 секция &2 в ini-файле"
                                                          , 'WaitNextRunTime'
                                                          , 'schedule-free')
                                        ,input yes
                                        ,output v-out) no-error.
  if    not error-status:error
     and v-out ne ?
     and v-out ne ""
  then
     vWaitNextRunTime =  logical( v-out) no-error.
  assign
    v-str          = get-str-type( p-task-type )
    v-db-attr-code = get-attr-code( p-task-type )
  .
  if v-str = ? then do:
    return error string( vss-workfile + chr(32) + "НЕТ ОБРАБОТКИ АТРИБУТА" + chr(32) + p-task-type ) .
  end.
  assign
    p-list-db = "":U
  .
  find first buf_sys-ctrl no-lock.
  if trim( buf_sys-ctrl.status_ ) <> "":U then do:
    return error substitute( "&1. При статусе БД равном &2 работа сеанса &3 не допускается!"
                             ,vss-workfile
                             ,buf_sys-ctrl.status_
                             ,v-str
                            ) .
  end.
  for each tt-db
  on error undo, return error return-value
  :
    delete tt-db.
  end.
  for each buf_schedule no-lock
    where buf_schedule.task-type = p-task-type
      and buf_schedule.db-num-char <> "*":U
  on error undo, return error return-value
  :
    if buf_schedule.active = true then do:
      run gbl/prcs-lst.p
        ( input buf_schedule.db-num-char
        , input 0
        , input 99999
        , input false
        , input (buffer tt-db:handle)
        , input "db-num":U
        ) no-error .
    end.
  end.
  block1_db:
  for each buf_db no-lock
  on error undo, return error return-value
  :
    find first buf_schedule no-lock
      where buf_schedule.task-type   = p-task-type
        and buf_schedule.db-num-char = "*":U
        and buf_schedule.active      = true
      no-error
    .
    if not available buf_schedule then do:
      find first tt-db no-lock
        where tt-db.db-num = buf_db.db-num
        no-error
      .
      if not available tt-db then do:
        run db-attr-exist ( input buf_db.db-num
                           ,input v-db-attr-code
                           ,output v-db-attr-exist
                          ) no-error.
        if error-status :error then do:
          run write-to-log( substitute( "&1. Ошибка при определении наличия атрибута расписания для БД &2"
                                        ,vss-workfile
                                        ,buf_db.db-num
                                      )
                          ) .
        end.
        if v-db-attr-exist = true then do:
          run db-attr-value ( input buf_db.db-num
                             ,input v-db-attr-code
                             ,output v-db-attr-value
                             ,output v-db-attr-type
                            ) no-error.
          if error-status :error then do:
            run write-to-log( substitute( "&1. Ошибка при чтении атрибута наличия расписания для БД &2"
                                          ,vss-workfile
                                          ,buf_db.db-num
                                        )
                            ) .
          end.
          if v-db-attr-value = "yes":U then do:
            run db-attr-delete ( input buf_db.db-num
                                ,input v-db-attr-code
                                ,output v-db-attr-del
                              ) no-error.
            if error-status :error
              or v-db-attr-del = false
            then do:
              run write-to-log( substitute( "&1. Ошибка при удалении атрибута отсутствия расписания для БД &2&3"
                                            ,vss-workfile
                                            ,buf_db.db-num
                                            ,chr(10)
                                            ,return-value
                                          )
                              ) .
            end.
          end.
          next block1_db.
        end.
      end.
    end.
    find first buf_BatchProcess no-lock
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
    if not available buf_BatchProcess then do:
      run db-attr-exist ( input buf_db.db-num
                          ,input v-db-attr-code
                          ,output v-db-attr-exist
                        ) no-error.
      if error-status :error then do:
        run write-to-log( substitute( "&1. Ошибка при определении наличия атрибута расписания для БД &2"
                                      ,vss-workfile
                                      ,buf_db.db-num
                                    )
                        ) .
      end.
      if v-db-attr-exist then do:
        run db-attr-write ( input buf_db.db-num
                            ,input v-db-attr-code
                            ,input "no":U
                          ) no-error.
        if error-status :error then do:
          run write-to-log( substitute( "&1. Ошибка при записи атрибута отсутствия расписания для БД &2"
                                        ,vss-workfile
                                        ,buf_db.db-num
                                      )
                          ) .
        end.
      end.
    end.
  end.
  for each tt-db
  on error undo, return error return-value
  :
    delete tt-db.
  end.
  for each buf_db no-lock
  on error undo, return error
  :
    if p-task-type = 'autonws':U
       and ( ( buf_sys-ctrl.db-num = 0
               and buf_db.db-num = 0
             )
             or ( buf_sys-ctrl.db-num <> 0
                  and buf_db.db-num <> 0
                )
           )
    then do:
      next.
    end.
    if p-task-type = 'autooxml':U
       and ( ( buf_sys-ctrl.db-num = 0
               and buf_db.db-num <> 0
             )
             or ( buf_sys-ctrl.db-num <> 0
                  and buf_db.db-num <> buf_sys-ctrl.db-num
                )
           )
    then do:
      next.
    end.
    if p-for-db <> "":U
      and lookup( string( buf_db.db-num), p-for-db ) = 0
    then do:
      next.
    end.
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
    if available buf_BatchProcess then do:
      for each buf-all_BatchProcess exclusive-lock
        where buf-all_BatchProcess.BP_Status   = 'N':U
          and buf-all_BatchProcess.BP_Type     = p-task-type
          and buf-all_BatchProcess.CharKey_One = string( buf_db.db-num )
          and buf-all_BatchProcess.CharKey_Two = "auto":U
          and (p-task-type <> 'autooxml':U or
                (p-task-type = 'autooxml':U and
                  (  (num-entries (buf-all_BatchProcess.CharKey_Three, chr(3)) <= 3 and p-for-extsys = ""
                      )
                  or (p-for-extsys <> ""
                      and num-entries (buf-all_BatchProcess.CharKey_Three, chr(3)) > 3
                      and entry (4, buf-all_BatchProcess.CharKey_Three, chr(3)) = p-for-extsys
                      )
                   )
                 )
               )
          and (p-task-type <> 'autofree':U or
                (p-task-type = 'autofree':U and
                  (  (num-entries (buf-all_BatchProcess.CharKey_Three, chr(3)) <= 3 and p-for-proc = ""
                      )
                  or (p-for-proc <> ""
                      and num-entries (buf-all_BatchProcess.CharKey_Three, chr(3)) > 3
                      and entry (4, buf-all_BatchProcess.CharKey_Three, chr(3)) = p-for-proc
                      )
                   )
                 )
               )
      on error undo, return error
      :
        if buf-all_BatchProcess.BatchProcess# <> buf_BatchProcess.BatchProcess# then do:
          delete buf-all_BatchProcess.
        end.
      end.
    end.
    assign
      v-process    = "":U
      v-chg-manual = false
    .
    for each buf-all_BatchProcess exclusive-lock
       where buf-all_BatchProcess.BP_Status   = 'N':U
         and buf-all_BatchProcess.BP_Type     = p-task-type
         and buf-all_BatchProcess.CharKey_One = string( buf_db.db-num )
    on error undo, return error
    :
      if buf-all_BatchProcess.CharKey_Two <> "auto":U then do:
        if v-chg-manual = false then do:
          if not available buf_BatchProcess then do:
            create buf_BatchProcess .
            buffer-copy buf-all_BatchProcess to buf_BatchProcess
              assign
                buf_BatchProcess.BatchProcess# = next-value (s-btpr, ub)
                buf_BatchProcess.CharKey_Two   = "auto":U
              .
          end.
          if buf-all_BatchProcess.CharKey_Two = "manual":U
            or
            ( buf-all_BatchProcess.BP_ExecSysDate < buf_BatchProcess.BP_ExecSysDate
              or ( buf-all_BatchProcess.BP_ExecSysDate = buf_BatchProcess.BP_ExecSysDate
                  and buf-all_BatchProcess.BP_ExecSysTimeInt < buf_BatchProcess.BP_ExecSysTimeInt
                )
            )
          then do:
            buffer-copy buf-all_BatchProcess except BatchProcess# CharKey_Two to buf_BatchProcess .
            assign
              v-process  = buf-all_BatchProcess.CharKey_Two
              v-new-date = buf-all_BatchProcess.BP_ExecSysDate
              v-new-time = buf-all_BatchProcess.BP_ExecSysTime
              v-user-id  = buf-all_BatchProcess.User_ID
            .
            if buf-all_BatchProcess.CharKey_Two = "manual":U then do:
              assign
                v-chg-manual = true
              .
            end.
          end.
        end.
        delete buf-all_BatchProcess.
      end.
    end.
    if v-process <> "":U then do:
      run write-to-log( substitute( "Следующий сеанс &1 &2 после &3 &4 (изменил &5) (&6)"
                                    ,v-str
                                    ,buf_db.db-num
                                    ,v-new-time
                                    ,string( v-new-date , "99.99.9999" )
                                    ,v-user-id
                                    ,v-process
                                  )
                      ) .
    end.
    find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Status         = 'N':U
        and buf_BatchProcess.BP_Type           = p-task-type
        and buf_BatchProcess.CharKey_One       = string( buf_db.db-num )
        and buf_BatchProcess.CharKey_Two       = "auto":U
        and ( buf_BatchProcess.BP_ExecSysDate < v-today
              or (buf_BatchProcess.BP_ExecSysDate = v-today
                  and buf_BatchProcess.BP_ExecSysTimeInt < v-time
                )
            )
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
       if p-list-db = "":U then do:
        assign
          p-list-db  = string( buf_db.db-num )
          p-list-key = buf_BatchProcess.CharKey_Three
        .
      end.
      else do:
        assign
          p-list-db  = p-list-db + chr(44) + string( buf_db.db-num )
          p-list-key = p-list-key + chr(1) + buf_BatchProcess.CharKey_Three
        .
      end.
    end.
     for each buf_BatchProcess no-lock
         where buf_BatchProcess.BP_Status         = 'N':U
           and buf_BatchProcess.BP_Type           = p-task-type
           and buf_BatchProcess.CharKey_One       = string( buf_db.db-num )
           and buf_BatchProcess.CharKey_Two       = "auto":U
           and ( buf_BatchProcess.BP_ExecSysDate > v-today
                 or (buf_BatchProcess.BP_ExecSysDate = v-today
                     and buf_BatchProcess.BP_ExecSysTimeInt > v-time
                   )
               )
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
     :
        if vWaitNextRunTime
        then do:
           create tt-BatchProcess.
           buffer-copy buf_BatchProcess to tt-BatchProcess .
        end.
        if p-list-db = "":U then do:
        assign
          p-list-db-all  = string( buf_db.db-num )
          p-list-key-all = buf_BatchProcess.CharKey_Three
        .
      end.
      else do:
        assign
          p-list-db-all  = p-list-db-all  + chr(44) + string( buf_db.db-num )
          p-list-key-all = p-list-key-all + chr(1) + buf_BatchProcess.CharKey_Three
        .
      end.
     end.
  end.
  run gbl/delatrlb.p .
end.
