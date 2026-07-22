block-level on error undo, throw.
define input parameter parparentproc   as handle     no-undo .
define input parameter p-db-num        as integer    no-undo .
define input parameter p-last-sent-pck as integer    no-undo .
define input parameter p-last-rcv-pck  as integer    no-undo .
define output parameter pOk            as logical    no-undo init no .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Синхронизация новостей".
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
define  shared variable nws-exch-dir as character no-undo .
define  shared variable nws-heap-dir as character no-undo .
define variable err-mess as character no-undo .
define temp-table t-pck-conf no-undo
  field db-num-dst      as integer
  field db-num-src      as integer
  field pack-num        as integer
  field total-recs      as integer
  field sys-key         as character
  field src_db-key      as character
  field dst_db-key      as character
  field ver-num         as character
  field prev-crc        as character
  field actual-date     as date
  field actual-time-int as integer
.
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
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
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
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
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
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
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
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ext-system-attr-code :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-code in g#attr-lib
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
procedure ext-system-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-tooltip in g#attr-lib
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
procedure ext-system-attr-value :
  define input  parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-value     like ub.ext-system-attr.esya-attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-value in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
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
procedure ext-system-attr-write :
  define input parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define input parameter p-value     like ub.ext-system-attr.esya-attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-write in g#attr-lib
      (input p-esys-id
      ,input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-exist :
  define input  parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-exist in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-delete :
  define input  parameter p-esys-id  like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num   like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code     like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-delete in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable p-news as logical no-undo.
define variable v-real-last-sent-pck as integer no-undo .
define variable v-real-last-rcv-pck as integer no-undo .
define variable v-curr-obj-type as character no-undo .
define variable v-curr-obj-code as integer no-undo .
define variable v-cmd-proc-handle as handle no-undo .
define variable v-command as character no-undo .
define variable v-cmd-code as integer no-undo .
define variable v-db-list as character no-undo .
do
on error undo, return error
:
  for each pck-sent no-lock where pck-sent.db-num = p-db-num :
    v-real-last-sent-pck = max(v-real-last-sent-pck, pck-sent.pack-num) .
  end.
  for each pck-rcvd no-lock where pck-rcvd.db-num = p-db-num :
    v-real-last-rcv-pck = max(v-real-last-rcv-pck, pck-rcvd.pack-num) .
  end.
  if p-last-rcv-pck > v-real-last-sent-pck
  then do :
    return error "Номер последнего принятого пакета в УБД больше номера последнего отправленного пакета в ГБД!" .
  end.
  if p-last-sent-pck > v-real-last-rcv-pck
  then do :
    return error "Номер последнего отправленного пакета из УБД больше номера последнего принятого пакета в ГБД!" .
  end.
  if p-last-rcv-pck = v-real-last-sent-pck
  and p-last-sent-pck = v-real-last-rcv-pck
  then do :
    return error "Номера последних пакетов в ГБД и УБД совпадают. Синхронизация не требуется." .
  end.
  find first ub.clients no-lock where ub.clients.obj-type = 'маг':U
                                  and ub.clients.stts = 0
                                  and ub.clients.db-num = p-db-num
                                  no-error.
  if not available ub.clients
  then do :
    return error  ("Не найден магазин в УБД " + string(p-db-num)) .
  end.
  for each pck-sent exclusive-lock where pck-sent.db-num = p-db-num and pck-sent.pack-num > p-last-rcv-pck :
    for each route exclusive-lock where route.db-num = p-db-num and route.last-pack = pck-sent.pack-num :
      delete route .
    end.
    delete pck-sent .
  end.
  for each pck-rcvd exclusive-lock where pck-rcvd.db-num = p-db-num and pck-rcvd.pack-num > p-last-sent-pck :
    delete pck-rcvd .
  end.
  for each route exclusive-lock where route.db-num = p-db-num and route.last-pack = -1 :
    delete route .
  end.
  v-curr-obj-type = ub.clients.obj-type .
  v-curr-obj-code = ub.clients.obj-code .
  run create-routes no-error.
  if error-status :error then do:
    return error return-value .
  end.
  assign pOk = yes .
  run trg/userlog.p (
        input 'utl'
        , input ( ("Синхронизация новостей с УБД " +
                string(p-db-num) +
                substitute("; получ_до: &1; получ_после: &2; отпр_до: &3; отпр_после: 4", v-real-last-sent-pck, p-last-rcv-pck, v-real-last-rcv-pck, p-last-sent-pck) ) +
                chr(3) +
                "nws/nws-sync.p")
        , input ?
        , input ?
        , input ""
        ) no-error.
  if error-status :error
  then do:
    return error ("Ошибка записи истории действий пользователя" + chr(10) + return-value + error-status:get-message(1)) .
  end.
  run write-to-log in this-procedure
  ( input  substitute ("Произведена синхронизация новостей с УБД &1.&2Идентификатор пользователя: &3&2Номер последнего принятого пакета в УБД до синхронизации: &4&2Номер последнего принятого пакета в УБД после синхронизации: &5&2Номер последнего отправленного пакета из УБД до синхронизации: &6&2Номер последнего отправленного пакета из УБД после синхронизации: &7&2",
                        string(p-db-num),
                        chr(10),
                        g#auto-user-id,
                        v-real-last-sent-pck,
                        p-last-rcv-pck,
                        v-real-last-rcv-pck,
                        p-last-sent-pck
                         ) ) .
end .
procedure create-routes :
  find first ub.db no-lock where ub.db.db-num = p-db-num .
  run nws/cr-route.p ( input 'send-tbl':U, input 'db':U, input (buffer ub.db:handle), input string(p-db-num) ) no-error.
  if error-status :error then do:
    return error return-value.
  end.
  for each ub.db-attr no-lock where ub.db-attr.db-num = ub.db.db-num :
    run db-attr-news in this-procedure
      ( input ub.db-attr.attr-code
       ,output p-news
      ) no-error.
    if p-news = true then do:
      run nws/cr-route.p ( input 'send-tbl':U, input 'db-attr':U, input (buffer ub.db-attr:handle), input string(p-db-num) ) no-error.
      if error-status :error then do:
        return error return-value.
      end.
    end.
  end.
  find first ub.clients no-lock where ub.clients.obj-type = v-curr-obj-type
                                  and ub.clients.obj-code = v-curr-obj-code .
  run nws/cr-route.p ( input 'send-tbl':U, input 'clients':U, input (buffer ub.clients:handle), input string(p-db-num) ) no-error.
  if error-status :error then do:
    return error return-value.
  end.
  find first ub.shop no-lock where ub.shop.obj-code = ub.clients.obj-code .
  run nws/cr-route.p ( input 'send-tbl':U, input 'shop':U, input (buffer ub.shop:handle), input string(p-db-num) ) no-error.
  if error-status :error then do:
    return error return-value.
  end.
  for each ub.clients-attr no-lock where  ub.clients-attr.obj-type = ub.clients.obj-type
                                      and ub.clients-attr.obj-code = ub.clients.obj-code :
    run clntattr-news in this-procedure(input ub.clients-attr.attr-code,
                                        output p-news) no-error.
    if  p-news then do:
      run nws/cr-route.p ( input 'send-tbl':U, input 'clients-attr':U, input (buffer ub.clients-attr:handle), input string(p-db-num) ) no-error.
      if error-status :error then do:
        return error return-value.
      end.
    end.
  end.
  for each ub.ext-system no-lock where ub.ext-system.esys-db-num-exp = p-db-num or ub.ext-system.esys-db-num-imp = p-db-num :
    run nws/cr-route.p ( input 'send-tbl':U, input 'ext-system':U, input (buffer ub.ext-system:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
    for each ub.ext-system-attr no-lock where ub.ext-system-attr.esys-id  = ub.ext-system.esys-id
                                          and ub.ext-system-attr.db-num   = ub.ext-system.db-num :
      run ext-system-attr-news in this-procedure ( input ub.Ext-system-attr.esya-attr-code
                                                  ,output p-news).
      if  p-news then do:
        run nws/cr-route.p ( input 'send-tbl':U, input 'ext-system-attr':U, input (buffer ub.ext-system-attr:handle), input string(p-db-num) ) no-error.
        if error-status :error then do:
          return error return-value.
        end.
      end.
    end.
  end.
  for each ub.user-login-action-role no-lock where ub.user-login-action-role.db-num = p-db-num :
    run nws/cr-route.p ( input 'send-tbl':U, input 'user-login-action-role':U, input (buffer ub.user-login-action-role:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.action-role no-lock where ub.action-role.db-num = p-db-num :
    run nws/cr-route.p ( input 'send-tbl':U, input 'action-role':U, input (buffer ub.action-role:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.action-role-item no-lock where ub.action-role-item.db-num = p-db-num :
    run nws/cr-route.p ( input 'send-tbl':U, input 'action-role-item':U, input (buffer ub.action-role-item:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.schedule no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'schedule':U, input (buffer ub.schedule:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
    for each ub.schedule-attr no-lock where ub.schedule-attr.cre-db-num = ub.schedule.cre-db-num
                                        and ub.schedule-attr.task-type  = ub.schedule.task-type
                                        and ub.schedule-attr.task-num   = ub.schedule.task-num
                                        and ub.schedule-attr.task-num  <> -1 :
      run nws/cr-route.p ( input 'send-tbl':U, input 'schedule-attr':U, input (buffer ub.schedule-attr:handle), input string(p-db-num) ) no-error.
      if error-status :error then do:
        return error return-value.
      end.
    end.
  end.
  for each ub.config no-lock where ub.config.db-num = p-db-num :
    run nws/cr-route.p ( input 'send-tbl':U, input 'config':U, input (buffer ub.config:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.thbj-attr no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'thbj-attr':U, input (buffer ub.thbj-attr:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.clients no-lock :
    if ub.clients.obj-type = v-curr-obj-type and ub.clients.obj-code = v-curr-obj-code
    then next .
    run nws/cr-route.p ( input 'send-tbl':U, input 'clients':U, input (buffer ub.clients:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
    for each ub.clients-attr no-lock where  ub.clients-attr.obj-type = ub.clients.obj-type
                                        and ub.clients-attr.obj-code = ub.clients.obj-code :
      run clntattr-news in this-procedure(input ub.clients-attr.attr-code,
                                          output p-news) no-error.
      if  p-news then do:
        run nws/cr-route.p ( input 'send-tbl':U, input 'clients-attr':U, input (buffer ub.clients-attr:handle), input string(p-db-num) ) no-error.
        if error-status :error then do:
          return error return-value.
        end.
      end.
    end.
  end.
  for each ub.pay-type no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'pay-type':U, input (buffer ub.pay-type:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.cash-pay no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'cash-pay':U, input (buffer ub.cash-pay:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.cash-pay-attr no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'cash-pay-attr':U, input (buffer ub.cash-pay-attr:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.tax no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'tax':U, input (buffer ub.tax:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.tax-rate no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'tax-rate':U, input (buffer ub.tax-rate:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.tax-rate-value no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'tax-rate-value':U, input (buffer ub.tax-rate-value:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.tax-units no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'tax-units':U, input (buffer ub.tax-units:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.currency no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'currency':U, input (buffer ub.currency:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.curr-bank no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'curr-bank':U, input (buffer ub.curr-bank:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.curr-shop no-lock where ub.curr-shop.obj-type = v-curr-obj-type
                                  and ub.curr-shop.obj-code = v-curr-obj-code :
    if Year(ub.curr-shop.exch-date ) <> 9999 then do:
      run nws/cr-route.p ( input 'send-tbl':U, input 'curr-shop':U, input (buffer ub.curr-shop:handle), input string(p-db-num) ) no-error.
      if error-status :error then do:
        return error return-value.
      end.
    end.
  end.
  for each ub.country no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'country':U, input (buffer ub.country:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.regions no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'regions':U, input (buffer ub.regions:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.cash-desk no-lock where ub.cash-desk.db-num = p-db-num :
    run nws/cr-route.p ( input 'send-tbl':U, input 'cash-desk':U, input (buffer ub.cash-desk:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.cash-desk-attr no-lock where ub.cash-desk-attr.db-num = p-db-num :
    run nws/cr-route.p ( input 'send-tbl':U, input 'cash-desk-attr':U, input (buffer ub.cash-desk-attr:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.cashbookrule no-lock where ub.CashBookRule.Obj-type = v-curr-obj-type
                                     and ub.CashBookRule.Obj-code = v-curr-obj-code :
    run nws/cr-route.p ( input 'send-tbl':U, input 'CashBookRule':U, input (buffer ub.cashbookrule:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.OperServ no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'OperServ':U, input (buffer ub.OperServ:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
    for each ub.goods-attr exclusive-lock where ub.goods-attr.attr-code = 'oper-serv-idd':U
                                            and ub.goods-attr.attr-value = string(ub.OperServ.id):
      run nws/cr-route.p ( input 'send-tbl':U, input 'goods-attr':U, input (buffer ub.goods-attr:handle), input string(p-db-num) ) no-error.
      if error-status :error then do:
        return error return-value.
      end.
    end.
  end.
  for each ub.OperServAttr no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'OperServAttr':U, input (buffer ub.OperServAttr:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  run nws/cmd-bush.p persistent set v-cmd-proc-handle no-error .
  if error-status :error
  then do:
    delete procedure v-cmd-proc-handle .
    return error substitute("&1 &2 &3&4Ошибка при запуске процедуры cmd-bush.p&4" +
                                        "&5&4&6"
                                        ,vss-workfile
                                        ,vss-revision
                                        ,vss-description
                                        ,chr(10)
                                        ,error-status:get-message(1)
                                        ,return-value ).
  end.
  define buffer buf_rp-by-call for ub.rp-by-call.
  define buffer buf_rule-by-call for ub.rule-by-call.
  define buffer buf_rule-call-param for ub.rule-call-param.
  for each db no-lock
  where db.db-num > 0
  :
    assign
    v-db-list = v-db-list + chr(1) + string(db.db-num).
  end.
  v-db-list = trim(v-db-list, chr(1)).
  for each ub.dis-card-type no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'dis-card-type':U, input (buffer ub.dis-card-type:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
    assign
    v-command =  substitute("&2&1&3&1&4"
                           , chr(6)
                           , 'cmd-dct-send':U
                           , ub.dis-card-type.emitent-host-code
                           , ub.dis-card-type.type
                           ).
    run begin-create-command in v-cmd-proc-handle
      (input v-command
      ,input "":U
      ,output v-cmd-code
      ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при создании команды &1", 'cmd-dct-send':U ) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      delete procedure v-cmd-proc-handle .
      return error return-value .
    end.
    run send-command in v-cmd-proc-handle
      ( input v-cmd-code
        ,input v-db-list
        ) no-error .
    if error-status:error then do:
      delete procedure v-cmd-proc-handle .
      message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при отсылке команды &1", 'cmd-dct-send':U ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
      return error return-value .
    end.
    for each buf_rp-by-call where buf_rp-by-call.call_id = ub.dis-card-type.uniq-key-rec :
      run nws/cr-route.p ( input 'send-tbl':U, input 'rp-by-call':U, input (buffer buf_rp-by-call:handle), input string(p-db-num) ) no-error.
      if error-status :error then do:
        return error return-value.
      end.
    end.
    for each buf_rule-by-call where buf_rule-by-call.call_id = ub.dis-card-type.uniq-key-rec :
      run nws/cr-route.p ( input 'send-tbl':U, input 'rule-by-call':U, input (buffer buf_rule-by-call:handle), input string(p-db-num) ) no-error.
      if error-status :error then do:
        return error return-value.
      end.
    end.
    for each buf_rule-call-param where buf_rule-call-param.call_id = ub.dis-card-type.uniq-key-rec :
      run nws/cr-route.p ( input 'send-tbl':U, input 'rule-call-param':U, input (buffer buf_rule-call-param:handle), input string(p-db-num) ) no-error.
      if error-status :error then do:
        return error return-value.
      end.
    end.
  end.
  delete procedure v-cmd-proc-handle no-error .
  for each ub.dis-card-mask no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'dis-card-mask':U, input (buffer ub.dis-card-mask:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.dis-card no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'dis-card':U, input (buffer ub.dis-card:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
    run str/saledc.p
        (
          input parparentproc
        ,input this-procedure :handle
        ,input ?
        ,input 'one-card-add':U
        ,input ?
        ,input '':U
        ,input 0
        ,input 0
        ,input 0
        ,input g#db-num
        ,input ub.dis-card.d-card
        ,input ?
        ,input ?
        ,input ?
        ,input 1
        ,input 1
        ,input yes
        ) no-error .
    if error-status:error then do:
      return error return-value .
    end.
  end.
  for each ub.dis-host no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'dis-host':U, input (buffer ub.dis-host:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.dis-card-property no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'dis-card-property':U, input (buffer ub.dis-card-property:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.dis-rule no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'dis-rule':U, input (buffer ub.dis-rule:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.dis-gds-rule no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'dis-gds-rule':U, input (buffer ub.dis-gds-rule:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  for each ub.dis-time-rule no-lock :
    run nws/cr-route.p ( input 'send-tbl':U, input 'dis-time-rule':U, input (buffer ub.dis-time-rule:handle), input string(p-db-num) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
end procedure .
