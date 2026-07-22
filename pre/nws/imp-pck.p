block-level on error undo, throw.
define input  parameter parparentproc   as   widget-handle        no-undo .
define input  parameter p-db-src        like ub.db.db-num         no-undo.
define input  parameter p-pck-num       like ub.pck-sent.pack-num no-undo.
define input  parameter p-file-pck-name as   character            no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "процедура импорта пакета".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3':u,p-db-src,p-pck-num,p-file-pck-name)
    .
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure pck-attr-code :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pck-attr-code in g#attr-lib
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
procedure pck-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pck-attr-tooltip in g#attr-lib
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
procedure pck-attr-value :
  define input  parameter p-tbl-pck   as   character                   no-undo .
  define input  parameter p-db-num    like ub.pck-rcvd-attr.db-num     no-undo .
  define input  parameter p-pack-num  like ub.pck-rcvd-attr.pack-num   no-undo .
  define input  parameter p-code      like ub.pck-rcvd-attr.attr-code  no-undo .
  define output parameter p-value     like ub.pck-rcvd-attr.attr-value no-undo .
  define output parameter p-type      as   character                   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pck-attr-value in g#attr-lib
      ( input  p-tbl-pck
      , input  p-db-num
      , input  p-pack-num
      , input  p-code
      , output p-value
      , output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure pck-attr-write :
  define input parameter p-tbl-pck   as   character                   no-undo .
  define input parameter p-db-num    like ub.pck-rcvd-attr.db-num     no-undo .
  define input parameter p-pack-num  like ub.pck-rcvd-attr.pack-num   no-undo .
  define input parameter p-code      like ub.pck-rcvd-attr.attr-code  no-undo .
  define input parameter p-value     like ub.pck-rcvd-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pck-attr-write in g#attr-lib
      ( input p-tbl-pck
      , input p-db-num
      , input p-pack-num
      , input p-code
      , input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure pck-attr-exist :
  define input  parameter p-tbl-pck  as   character                   no-undo .
  define input  parameter p-db-num   like ub.pck-rcvd-attr.db-num     no-undo .
  define input  parameter p-pack-num like ub.pck-rcvd-attr.pack-num   no-undo .
  define input  parameter p-code     like ub.pck-rcvd-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pck-attr-exist in g#attr-lib
      ( input  p-tbl-pck
      , input  p-db-num
      , input  p-pack-num
      , input  p-code
      , output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure pck-attr-delete :
  define input  parameter p-tbl-pck  as   character                   no-undo .
  define input  parameter p-db-num   like ub.pck-rcvd-attr.db-num     no-undo .
  define input  parameter p-pack-num like ub.pck-rcvd-attr.pack-num   no-undo .
  define input  parameter p-code     like ub.pck-rcvd-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pck-attr-delete in g#attr-lib
      ( input  p-tbl-pck
      , input  p-db-num
      , input  p-pack-num
      , input  p-code
      , output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure pck-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pck-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure pck-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pck-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure pck-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pck-attr-batch-edit in g#attr-lib
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
define new shared variable himp2Cd as handle no-undo.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table dc-list no-undo like ub.dis-card
  field to-del as logical
  field order-num as integer
  field fdec as decimal
  field fint as integer
  field flog as logical
  field fchar as character
  index pi  is primary unique d-card
  index cn      card-num
  index cli cli-type cli-code
  index host-dscnt  emitent-host-code status_ d-pcnt
  index host-type  emitent-host-code type d-pcnt
  index oi order-num
  .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   new shared   temp-table dc-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define new shared temp-table dc-dis-card-mask no-undo like ub.dis-card-mask.
define new shared temp-table dc-dis-card-mask-attr no-undo like ub.dis-card-mask-attr.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def  new shared  temp-table dcp-list no-undo like ub.dis-card-property
                        field rc as recid
                        field to-del as  logical
                        field order-num as integer
                        index rci is unique rc to-del
                        index d-card-i is primary d-card host-code obj-type obj-code dt-code node-code to-del
                        index iobj obj-type obj-code
                        index io order-num
                        .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def  new shared  temp-table stpl-list no-undo like ub.stop-list
                        field rc as recid
                        field to-del as  logical
                        field order-num as integer
                        index rci is unique rc to-del
                        index pi is primary classif-type stop-list-code to-del
                        index iobj obj-type obj-code
                        index io order-num
                        .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def new shared temp-table pbc-list no-undo like ub.prod-bc
                        field rc as recid
                        field del as  logical
                        index rci is unique rc del
                        index gds-code-i b-code del
                        index ibc-on-type bc-on-type
                        .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def new shared temp-table bc-list no-undo like ub.bar-code
                        field del as  logical
                        index bc is unique b-code del
                        index gds-code-i gds-code del.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gdsolist no-undo like ub.goods
field qnty   as decimal
field to-del as logical
field order-num as integer
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index art  is primary unique artic prod-type prod-code obj-type obj-code
index code is         unique gds-code obj-type obj-code
index oi order-num
index iobj obj-type obj-code gds-code
.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE new shared TEMP-TABLE cash-txn no-undo
FIELD tax-code like ub.tax.tax-code
FIELD tax-name like ub.tax.tax-name
FIELD news-action as logical
index pi IS UNIQUE PRIMARY tax-code.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table cash-txr no-undo
  field tax-code    like ub.tax.tax-code
  field rate-code   like ub.tax-rate.rate-code
  field host-code   like ub.sysconf.host-code
  field obj-type    like ub.clients.obj-type
  field obj-code    like ub.clients.obj-code
  field tax-type    like ub.tax.tax-type
  field status_     like ub.tax-rate-value.status_
  field rate-value  as decimal
  field rc          as recid
  field crf         as integer
  field news-action as logical
  index pi is unique primary tax-code host-code obj-type obj-code status_ rc
  index crf-i  crf host-code obj-type obj-code rc
.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table pdf-list no-undo like ub.price-doc-forming
field to-del     as logical
field order-num  as integer
index pi  is primary unique plt-id plt-db-num pdf-id pdf-db
index oi order-num
.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE new shared TEMP-TABLE cash-pay-list no-undo
FIELD cdpay-code as integer
FIELD curr-code as integer
index pi IS PRIMARY unique cdpay-code curr-code
.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE new shared TEMP-TABLE ext-classif-list no-undo
   FIELD db-num as integer
   field Key#One as integer
   field Key#Two as integer
   field CharKey_One as character
index pi IS PRIMARY unique db-num Key#Two Key#One CharKey_One
.
DEFINE new shared TEMP-TABLE c-ext-classif-list no-undo
   FIELD db-num as integer
   field Key#One as integer
   field Key#Two as integer
   field CharKey_One as character
   field chip-num as integer
index pi IS PRIMARY unique db-num Key#Two Key#One CharKey_One chip-num
.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE new shared TEMP-TABLE PromoAction-list no-undo
FIELD ID as int64
FIELD db-num as integer
FIELD del_ as logical
index pi IS PRIMARY unique ID db-num
.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE new shared TEMP-TABLE thbjattr-list no-undo like ub.thbj-attr .
define new shared var sendEMRC   as logical no-undo.
define new shared var settingUpd as logical no-undo.
define new shared var sendMarkType as logical no-undo.
define new shared var sendGisMt as logical no-undo.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure send-to-cash:
  if not can-find(first ub.cash-desk where
                  ub.cash-desk.db-num = ibs.th.gbl.gbl-var:g#db-num AND
                  ub.cash-desk.cash-on = yes) then return.
  do
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    if can-find(first gds-list no-lock)
    or can-find(first gdsolist no-lock)
    or can-find(first bc-list no-lock)
    or can-find(first pbc-list no-lock)
    or can-find(first cash-txn no-lock)
    or can-find(first cash-txr no-lock)
    or can-find(first dc-list no-lock)
    or can-find(first dc-dis-card-mask no-lock)
    or can-find(first stpl-list no-lock)
    or can-find(first pdf-list no-lock)
    or can-find(first cash-pay-list no-lock)
    or can-find(first ext-classif-list no-lock)
    or can-find(first c-ext-classif-list no-lock)
    or can-find(first PromoAction-list no-lock)
    or can-find(first thbjattr-list no-lock)
    or sendEMRC
    or settingUpd
    or sendMarkType
    then do:
      run str/diallog.w (
                         input ?
                        ,input ?
                        ,input 'str/sendnall.p':U
                        ,input string(ibs.th.gbl.gbl-var:g#db-num)
                        ,input yes
                        ,input '':U
                        ,input 'Отправка информации на кассу') no-error .
    end.
  end.
end procedure.
procedure fill-setting :
   define input parameter i-obj      as character no-undo .
   define input parameter i-obj-type as character no-undo .
   define input parameter i-obj-code as integer   no-undo .
   define input parameter i-parent   as character no-undo .
   define input parameter i-code     as character no-undo .
   define buffer buf_thbj-attr for ub.thbj-attr.
   define buffer buf_sys-ctrl for ub.sys-ctrl.
   define buffer buf_clients for ub.clients.
   define variable v-db-num    as integer no-undo.
   define variable v-shop-code as integer no-undo.
   define variable v-reg-code  as integer no-undo.
   settingUpd = yes.
   sendGisMt = no.
   if i-obj = "thbj-attr"
   then do:
      v-db-num  = ibs.th.gbl.gbl-var:g#db-num.
      if v-db-num <> 0 then do:
          find first buf_clients no-lock
               where buf_clients.obj-type = 'маг':U
                 and buf_clients.db-num   = v-db-num
             no-error.
          if available buf_clients then v-shop-code = buf_clients.obj-code.
      end.
   end.
   if i-obj = "thbj-attr" and
      (i-parent = 'gisMT':U or i-parent = 'marking':U)
   then do:
      if i-parent = 'gisMT':U and i-obj-type = "" and i-obj-code = 0 then do:
          if not can-find(first buf_thbj-attr no-lock where
                                buf_thbj-attr.obj-type = 'БД':U
                            and buf_thbj-attr.obj-code = v-db-num
                            and buf_thbj-attr.upper-prop-code = i-parent
                            and buf_thbj-attr.prop-code = i-code)
          then sendGisMt = yes.
      end.
      if i-parent = 'gisMT':U and i-obj-type = 'регион':U then do:
          sendGisMt = yes.
      end.
      else if (i-parent = 'gisMT':U and i-obj-type = 'БД':U and i-obj-code = v-db-num)
         then sendGisMt = yes.
      else if i-parent = 'marking':U and i-obj-type = 'маг':U and i-obj-code = v-shop-code
         then sendGisMt = yes.
      else if i-parent = 'marking':U and i-obj-type = "" then do:
          if not can-find(first buf_thbj-attr no-lock where
                                buf_thbj-attr.obj-type = 'маг':U
                            and buf_thbj-attr.obj-code = v-shop-code
                            and buf_thbj-attr.upper-prop-code = i-parent
                            and buf_thbj-attr.prop-code = i-code)
          then sendGisMt = yes.
      end.
      if sendGisMt = yes then do:
          if not can-find(first thbjattr-list where
                                thbjattr-list.obj-type = i-obj-type
                            and thbjattr-list.obj-code = i-obj-code
                            and thbjattr-list.upper-prop-code = i-parent
                            and thbjattr-list.prop-code = i-code)
          then do:
              create thbjattr-list.
              assign
                 thbjattr-list.obj-type = i-obj-type
                 thbjattr-list.obj-code = i-obj-code
                 thbjattr-list.upper-prop-code = i-parent
                 thbjattr-list.prop-code = i-code
                 .
          end.
      end.
   end.
end procedure.
procedure fill-code :
   define input parameter i-parent as character no-undo .
   define input parameter i-code   as character no-undo .
   if i-parent begins "EMC"
   then
      sendEMRC = yes.
   if i-parent begins "MarkType"
   then
      sendMarkType = yes.
end procedure.
procedure fill-gds-list :
define parameter buffer buf_goods for ub.goods.
do
on error undo, return error
:
  for first gds-list where gds-list.gds-code = buf_goods.gds-code:
    delete gds-list.
  end.
  create gds-list.
  buffer-copy buf_goods to gds-list no-error.
  if error-status:error then message error-status:get-message(1) view-as alert-box.
  release gds-list.
end.
end procedure.
procedure fill-dc-list :
define parameter buffer buf_dis-card for ub.dis-card .
do
on error undo, return error
:
  find first dc-list where
            dc-list.d-card = buf_dis-card.d-card no-lock no-error.
  if not available dc-list then do:
    create dc-list.
    buffer-copy buf_dis-card to dc-list.
    release dc-list.
  end.
end.
end procedure.
procedure fill-dc-list-mask :
define parameter buffer buf_dis-card-mask for ub.dis-card-mask .
do
on error undo, return error
:
   find first dc-list where
            dc-list.d-card = buf_dis-card-mask.mask no-lock no-error.
   if not available dc-list
   then do:
      find first ub.dis-card no-lock where
                 ub.dis-card.d-card = buf_dis-card-mask.mask no-error .
      if  available dis-card
      then
         run fill-dc-list(buffer dis-card) .
   end.
  find first dc-dis-card-mask where
             dc-dis-card-mask.mask-num = buf_dis-card-mask.mask-num no-lock no-error.
  buffer-copy buf_dis-card-mask to dc-dis-card-mask.
  release dc-dis-card-mask.
end.
end procedure.
procedure fill-dc-list-mask-attr :
define parameter buffer buf_dis-card-mask-attr for ub.dis-card-mask-attr .
define buffer dis-card-mask for ub.dis-card-mask .
do
on error undo, return error
:
  find first dc-dis-card-mask where
             dc-dis-card-mask.mask-num = buf_dis-card-mask-attr.mask-num no-lock no-error.
  if not available dc-dis-card-mask
  then do:
     find first dis-card-mask where dis-card-mask.mask-num eq buf_dis-card-mask-attr.mask-num no-lock no-error.
     if available dis-card-mask
     then
        run  fill-dc-list-mask (buffer dis-card-mask).
  end.
  find first dc-dis-card-mask-attr where
            dc-dis-card-mask-attr.mask-num  = buf_dis-card-mask-attr.mask-num
       and  dc-dis-card-mask-attr.attr-code = buf_dis-card-mask-attr.attr-code
            no-lock no-error.
  buffer-copy buf_dis-card-mask-attr to dc-dis-card-mask-attr.
  release dc-dis-card-mask-attr.
end.
end procedure.
procedure fill-dc-list-attr :
define input parameter p-d-card as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .
do
on error undo, return error
:
  find first dc-list where
            dc-list.d-card = p-d-card no-error .
  if not avail dc-list then do:
    create dc-list.
    assign
    dc-list.d-card = p-d-card
    dc-list.emitent-host-code = p-emitent-host-code
    .
    release dc-list.
  end.
end.
end procedure.
procedure fill-cash-pay :
define input parameter p-cdpay-code as integer no-undo .
define input parameter p-curr-code  as integer no-undo .
do
on error undo, return error
:
  if not can-find( cash-pay-list where cash-pay-list.cdpay-code = p-cdpay-code
                                   and cash-pay-list.curr-code  = p-curr-code )
  then do:
    create cash-pay-list.
    assign
       cash-pay-list.cdpay-code = p-cdpay-code
       cash-pay-list.curr-code  = p-curr-code
    .
    release cash-pay-list.
  end.
end.
end procedure.
procedure fill-PromoAction :
define input parameter p-id as int64 no-undo .
define input parameter p-db-num  as integer no-undo .
do
on error undo, return error
:
  if not can-find( PromoAction-list where PromoAction-list.id = p-id
                                      and PromoAction-list.db-num  = p-db-num )
  then do:
    create PromoAction-list.
    assign
       PromoAction-list.id = p-id
       PromoAction-list.db-num  = p-db-num
    .
    release PromoAction-list.
  end.
end.
end procedure.
procedure fill-ext-classif:
define input parameter p-db-num as integer no-undo .
define input parameter p-Key#One  as integer no-undo .
define input parameter p-Key#Two  as integer no-undo .
define input parameter p-CharKey_One  as character no-undo .
do
on error undo, return error
:
  if not can-find( ext-classif-list where ext-classif-list.db-num = p-db-num
                                   and ext-classif-list.Key#One  = p-Key#One
                                   and ext-classif-list.Key#Two = p-Key#Two
                                   and ext-classif-list.CharKey_One = p-CharKey_One )
  then do:
    create ext-classif-list.
    assign
    ext-classif-list.db-num = p-db-num
    ext-classif-list.Key#One  = p-Key#One
    ext-classif-list.Key#Two = p-Key#Two
    ext-classif-list.CharKey_One = p-CharKey_One
    .
    release ext-classif-list.
  end.
end.
end procedure.
procedure fill-c-ext-classif:
define input parameter p-db-num as integer no-undo .
define input parameter p-Key#One  as integer no-undo .
define input parameter p-Key#Two  as integer no-undo .
define input parameter p-CharKey_One  as character no-undo .
define input parameter p-chip-num as integer no-undo .
do
on error undo, return error
:
  if not can-find( c-ext-classif-list where c-ext-classif-list.db-num = p-db-num
                                   and c-ext-classif-list.Key#One  = p-Key#One
                                   and c-ext-classif-list.Key#Two = p-Key#Two
                                   and c-ext-classif-list.CharKey_One = p-CharKey_One
                                   and c-ext-classif-list.chip-num = p-chip-num )
  then do:
    create c-ext-classif-list.
    assign
        c-ext-classif-list.db-num = p-db-num
        c-ext-classif-list.Key#One  = p-Key#One
        c-ext-classif-list.Key#Two = p-Key#Two
        c-ext-classif-list.CharKey_One = p-CharKey_One
        c-ext-classif-list.chip-num = p-chip-num
    .
    release c-ext-classif-list.
  end.
end.
end procedure.
procedure fill-g-list :
define input parameter p-gds-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define buffer buf_goods for ub.goods.
do
on error undo, return error
:
  find first gds-list where
            gds-list.gds-code = p-gds-code no-error .
  if not avail gds-list then do:
    if p-obj-type = 'маг':U then do:
      find first gdsolist where
                gdsolist.gds-code = p-gds-code
          AND  gdsolist.obj-type = p-obj-type
          AND  gdsolist.obj-code = p-obj-code   no-error .
    end.
    else do:
      find first buf_goods no-lock where
                  buf_goods.gds-code = p-gds-code no-error .
      create gds-list.
      buffer-copy buf_goods to gds-list.
    end.
  end.
  if p-obj-type = 'маг':U and not avail gdsolist then do:
    find first gdsolist where
              gdsolist.gds-code = p-gds-code
        AND  gdsolist.obj-type = p-obj-type
        AND  gdsolist.obj-code = p-obj-code   no-error .
    if not available gdsolist then do:
      find first buf_goods no-lock where
                  buf_goods.gds-code = p-gds-code no-error .
      if avail buf_goods then do:
        create gdsolist.
        buffer-copy buf_goods to gdsolist
        assign
        gdsolist.obj-type = p-obj-type
        gdsolist.obj-code = p-obj-code
        .
      end.
    end.
  end.
  if avail gdsolist then do:
    assign
    gdsolist.to-del = no
    .
    release gdsolist.
  end.
  if avail gds-list then do:
    assign
    gds-list.to-del = no
    .
    release gds-list.
  end.
end.
end procedure.
procedure fill-cash-txn :
define parameter buffer buf_tax for ub.tax.
do
on error undo, return error
:
  if not can-find( cash-txn where
                  cash-txn.tax-code = buf_tax.tax-code
              and cash-txn.tax-name = buf_tax.tax-name
                 ) then do:
    create cash-txn.
    assign
    cash-txn.tax-code = buf_tax.tax-code
    cash-txn.tax-name = buf_tax.tax-name
    .
    release cash-txn.
  end.
end.
end procedure.
procedure fill-cash-txr :
define input parameter p-tax-code as integer no-undo .
define input parameter p-rate-code as integer no-undo .
define input parameter p-status_ as character no-undo .
define input parameter p-host-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-tax-type as character no-undo .
define input parameter p-value as decimal no-undo .
define input parameter p-crf as integer no-undo .
define input parameter p-rec as recid no-undo .
define buffer buf_tax for ub.tax.
do
on error undo, return error
:
  find first cash-txr where
          cash-txr.tax-code = p-tax-code
      AND cash-txr.host-code = p-host-code
      AND cash-txr.rate-code = p-rate-code
      AND cash-txr.obj-type = p-obj-type
      AND cash-txr.obj-code = p-obj-code
      AND cash-txr.rc = p-rec no-error .
  if not avail cash-txr then do:
    find first  cash-txn where
                    cash-txn.tax-code = p-tax-code no-error .
    if not available cash-txn then do:
      find first buf_tax no-lock where buf_tax.tax-code = p-tax-code.
      create cash-txn.
      assign
      cash-txn.tax-code = buf_tax.tax-code
      cash-txn.tax-name = buf_tax.tax-name
      .
      release cash-txn.
      define variable II as integer no-undo.
      find last  cash-txr where cash-txr.crf > 0 no-error.
      if available cash-txr
      then
         II = cash-txr.crf + 1.
      else
         II = 1.
         _tax-rate:
      FOR EACH ub.tax-rate NO-LOCK WHERE
                          ub.tax-rate.tax-code = buf_tax.tax-code
                      and ub.tax-rate.status_  <>   'удал':U:
                        create cash-txr.
                        assign
                        cash-txr.tax-code = tax-rate.tax-code
                        cash-txr.rate-code = tax-rate.rate-code
                        cash-txr.tax-type = buf_tax.tax-type
                        cash-txr.host-code = p-host-code
                        cash-txr.obj-type = p-obj-type
                        cash-txr.obj-code = p-obj-code
                        cash-txr.status_ = tax-rate.status_
                        cash-txr.rc = RECID(tax-rate)
                        cash-txr.crf = ii
                        ii = ii + 1
                        .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  recid(ub.tax-rate)
  ,input  0
  ,input  0
  ,input  ?
  ,input  p-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output cash-txr.rate-value
  ) no-error .
                        if error-status:error then next _tax-rate.
       END.
    end.
    else do:
       for each cash-txr where cash-txr.tax-code = tax-rate.tax-code:
          delete cash-txr.
       end.
       _tax-rate2:
        FOR EACH ub.tax-rate NO-LOCK WHERE
                          ub.tax-rate.tax-code = buf_tax.tax-code
                      and ub.tax-rate.status_  <>   'удал':U:
                        create cash-txr.
                        assign
                        cash-txr.tax-code = tax-rate.tax-code
                        cash-txr.rate-code = tax-rate.rate-code
                        cash-txr.tax-type = buf_tax.tax-type
                        cash-txr.host-code = p-host-code
                        cash-txr.obj-type = p-obj-type
                        cash-txr.obj-code = p-obj-code
                        cash-txr.status_ = tax-rate.status_
                        cash-txr.rc = RECID(tax-rate)
                        cash-txr.crf = ii
                        ii = ii + 1
                        .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  recid(ub.tax-rate)
  ,input  0
  ,input  0
  ,input  ?
  ,input  p-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output cash-txr.rate-value
  ) no-error .
                        if error-status:error then next _tax-rate2.
       END.
    end.
    find first cash-txr where
          cash-txr.tax-code = p-tax-code
      AND cash-txr.rate-code = p-rate-code
      no-error .
    if not avail cash-txr and  p-status_ <> 'удал':U
    then do:
       create cash-txr.
       assign
       cash-txr.tax-code  = p-tax-code
       cash-txr.rate-code = p-rate-code
       cash-txr.host-code = p-host-code
       cash-txr.obj-type  = p-obj-type
       cash-txr.obj-code  = p-obj-code
       cash-txr.tax-type  = p-tax-type
       cash-txr.crf       = p-crf
       cash-txr.rc        = p-rec
       cash-txr.status_   = (if p-status_ = ? then 'тек':U else p-status_)
       .
    end.
    if  avail cash-txr
    then do:
       if p-status_ eq 'удал':U
       then
          delete cash-txr.
       else assign
       cash-txr.tax-code  = p-tax-code
       cash-txr.rate-code = p-rate-code
       cash-txr.host-code = p-host-code
       cash-txr.obj-type  = p-obj-type
       cash-txr.obj-code  = p-obj-code
       cash-txr.tax-type  = p-tax-type
       cash-txr.crf       = p-crf
       cash-txr.rc        = p-rec
       cash-txr.status_   = (if p-status_ = ? then 'тек':U else p-status_)
       .
    end.
    release cash-txr.
  end.
end.
end procedure.
procedure fill-stpl-list :
define parameter buffer buf_stop-list for ub.stop-list.
do
on error undo, return error
:
  find first stpl-list where
            stpl-list.classif-type =  buf_stop-list.classif-type
        and stpl-list.stop-list-code = buf_stop-list.stop-list-code no-error .
  if not avail stpl-list then do:
    create stpl-list.
    buffer-copy buf_stop-list
    to stpl-list.
    release stpl-list.
  end.
end.
end procedure.
procedure fill-pbc-list :
define input parameter p-rc as recid no-undo .
define input parameter p-gds-code as integer no-undo .
define input parameter p-b-code as integer no-undo .
define input parameter p-b-str as character no-undo .
define input parameter p-bc-on as logical no-undo .
define input parameter p-del as logical no-undo .
do
on error undo, return error
:
  if p-bc-on = false
  or p-del = yes
  or not can-find(gds-list where gds-list.gds-code     = p-gds-code
                            no-lock ) then do:
    find first pbc-list where pbc-list.rc = p-rc no-error.
    if not available pbc-list then do:
      create pbc-list.
    end.
    assign
    pbc-list.b-code = p-b-code
    pbc-list.b-str = p-b-str
    pbc-list.rc = p-rc
    pbc-list.bc-on = p-bc-on
    pbc-list.del = p-del
    .
    release pbc-list .
  end.
end.
end procedure.
procedure fill-bar-code :
define input parameter p-b-code as integer no-undo .
define input parameter p-gds-code as integer no-undo .
define input parameter p-del as logical no-undo .
define input parameter p-node-code as integer no-undo .
define input parameter p-in-code as character no-undo .
define input parameter p-part-code as character no-undo .
define input parameter p-cli-base-rate as decimal no-undo .
define input parameter p-unit-cli as character no-undo .
do
on error undo, return error
:
  if p-del = yes
  or not can-find(gds-list where gds-list.gds-code     = p-gds-code
                            no-lock ) then do:
    find first bc-list where
            bc-list.b-code = p-b-code and bc-list.del = p-del no-error.
    if not avail bc-list then do:
      create bc-list.
      assign
      bc-list.gds-code = p-gds-code
      bc-list.b-code = p-b-code
      bc-list.node-code = p-node-code
      bc-list.in-code = p-in-code
      bc-list.part-code = p-part-code
      bc-list.cli-base-rate = p-cli-base-rate
      bc-list.unit-cli = p-unit-cli
      bc-list.del = p-del
      .
    end.
  end.
end.
end procedure.
procedure fill-pdf :
define input parameter p-plt-id as integer no-undo .
define input parameter p-plt-db-num as integer no-undo .
define input parameter p-pdf-id as integer no-undo .
define input parameter p-pdf-db-num as integer no-undo .
define input parameter p-del as logical no-undo .
define buffer buf_pdf-list for pdf-list.
do
on error undo, return error
:
  find first pdf-list where
           pdf-list.plt-id = p-plt-id
       and pdf-list.plt-db-num = p-plt-db-num
       and pdf-list.pdf-id = p-pdf-id
       and pdf-list.pdf-db = p-pdf-db-num no-error.
  if not available pdf-list then do:
    find last buf_pdf-list use-index oi no-error.
    create pdf-list.
    assign
    pdf-list.plt-id = p-plt-id
    pdf-list.plt-db-num = p-plt-db-num
    pdf-list.pdf-id = p-pdf-id
    pdf-list.pdf-db = p-pdf-db-num
    pdf-list.to-del = p-del
    pdf-list.order-num = (if available buf_pdf-list then buf_pdf-list.order-num + 1 else 1)
    .
    release pdf-list.
  end.
end.
end procedure.
def var vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-avail-artic:
  define input parameter chg-artic     like ub.goods.artic     no-undo.
  define input parameter chg-prod-type like ub.goods.prod-type no-undo.
  define input parameter chg-prod-code like ub.goods.prod-code no-undo.
  do
  on error  undo, return error
  on stop   undo, return error
  on endkey undo, return error :
    define buffer buf_goods for ub.goods .
    if not can-find( buf_goods where buf_goods.artic     = chg-artic
                                 and buf_goods.prod-type = chg-prod-type
                                 and buf_goods.prod-code = chg-prod-code
                               no-lock )
    then do:
        run write-to-log ( "Не найден товар: артикул" + chr(32) + chg-artic + chr(32)
                           + "производитель" + chr(32) + chg-prod-type + chr(32)
                           + string( chg-prod-code )
                           + chr(10) + "Возможно этот товар был переименован."
                           + chr(10) + "Обменяйтесь новостями и повторите прием пакета."
                         ).
      return error.
    end.
  end.
  return.
end procedure.
procedure check-avail-gds-code:
  define input-output parameter chg-gds-code like ub.goods.gds-code no-undo.
  do
  on error  undo, return error
  on stop   undo, return error
  on endkey undo, return error :
    define buffer buf_goods for ub.goods .
    define buffer buf_route for ub.route .
    find buf_goods where buf_goods.gds-code = chg-gds-code
                  no-lock no-error.
    if not available buf_goods then do:
      do-sch:
      for each buf_route no-lock
        where buf_route.name-rec begins ("command" + chr(1)
                                         + "goods" + chr(1)
                                         + "ren-gds-code" + chr(1)
                                         + string(chg-gds-code)
                                        )
      on error  undo, return error
      :
        assign
          chg-gds-code = int(entry(5,buf_route.name-rec,chr(1)))
          .
        leave do-sch.
      end.
    end.
  end.
  return.
end procedure.
PROCEDURE check-avail-b-code :
  define input-output parameter loc-b-code like ub.bar-code.b-code no-undo.
  do
  on error  undo, return error
  on endkey undo, return error
  on stop   undo, return error :
    define variable sought-b-code  like ub.bar-code.b-code no-undo.
    define variable bar_code      like ub.prod-bc.b-str   no-undo .
    define buffer buf_bar-code for ub.bar-code .
    define buffer buf_prod-bc  for ub.prod-bc .
    assign sought-b-code = loc-b-code .
    find buf_bar-code where buf_bar-code.b-code = sought-b-code no-lock no-error.
    if available buf_bar-code then do:
      assign loc-b-code = buf_bar-code.b-code.
    end.
    else do :
      run gen-bc( input sought-b-code, output bar_code ).
      find first buf_prod-bc where buf_prod-bc.b-str = bar_code no-lock no-error.
      if available buf_prod-bc then do:
        assign loc-b-code = buf_prod-bc.b-code .
        find next buf_prod-bc where buf_prod-bc.b-str = bar_code no-lock no-error.
        if available buf_prod-bc then do:
          assign loc-b-code = ? .
            run write-to-log ( "Системная ошибка!!! При перепривязке к собственному коду найдено несколько Доп.БК с одинаковыми кодами" ).
          return error.
        end.
      end.
      else do:
        assign loc-b-code = ?.
          run write-to-log ( substitute( "Системная ошибка!!! Нет собственного кода (&1), к которому можно перепривязать Доп.БК или строку переоценки", sought-b-code ) ).
        return error.
      end.
    end.
  end.
END PROCEDURE.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdsoattr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
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
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
def var vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def new shared var bc-frmt as character no-undo .
def new shared var bc-pfx  as character no-undo .
def var bc-par-type as character no-undo .
    run gbl/conf-rd.p ("bc-frmt", "", "", 0, "", "", "",  no , output bc-frmt, output bc-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR bc-par-type <> "C":U OR not can-do ("EAN8,EAN13", bc-frmt) ) then
        do:
            message "Не задан или не верно задан ТИП собственного бар-кода!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
    run gbl/conf-rd.p ("bc-pfx", "", "", 0, "", "", "",  no , output bc-pfx, output bc-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR bc-par-type <> "C":U ) then
        do:
            message "Не задан или не верно задан ПРЕФИКС бар-кода складского места!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
PROCEDURE gen-bc:
  def input  parameter internal-b-code like ub.bar-code.b-code no-undo .
  def output parameter full-b-code     as character init ""    no-undo .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str28  as character no-undo.
  define variable tmp-num28  as character no-undo.
  define variable i28        as integer   no-undo.
  define variable sum28      as integer   no-undo.
  define variable len-code28 as integer   no-undo.
  define variable varcont28  as logical   initial yes no-undo.
  CASE bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str28 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str28 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " bc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont28 = yes then do:
    if integer( substring( tmp-str28, 1, length( bc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = bc-pfx + substring( tmp-str28, length( bc-pfx ) + 1, length( tmp-str28 ) - length( bc-pfx ) )
        len-code28    = length( full-b-code )
      .
      define variable v-sum-char28 as character no-undo .
      assign
        sum28 = 0
      .
      do i28 = 1 to len-code28 by 2
      :
        assign
          v-sum-char28 = substr(full-b-code, len-code28 - i28 + 1, 1)
        .
        if v-sum-char28 < "0"
        or v-sum-char28 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum28 = sum28 + integer(v-sum-char28)
        .
      end.
      if varcont28 = yes then do:
        assign
          sum28 = sum28 * 3
        .
        do i28 = 2 to len-code28 by 2
        :
          assign
            v-sum-char28 = substr(full-b-code, len-code28 - i28 + 1, 1)
          .
          if v-sum-char28 < "0"
          or v-sum-char28 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum28 = sum28 + integer(v-sum-char28)
          .
        end.
        if varcont28 = yes then do:
           if sum28 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum28 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
END PROCEDURE.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure valid-ren-bcod-tbl-list :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-std-list        as character no-undo .
    define variable v-ignore-list     as character no-undo .
    define variable v-special-list    as character no-undo .
    assign
      v-std-list     = "bar-code-attr,c-bar-code-attr,bar-code-obj-attr,c-bar-code-obj-attr,chk-gds,c-chk-gds,chk-gds-pay,doc-prts,doc-prts-attr,cd-doc-line,c-cd-doc-line,cd-plu,c-cd-plu,c-doc-prts,c-price-list,prod-bc-attr,c-prod-bc-attr,prod-bc-db,prod-bc-db-attr,c-prod-bc-db-attr,price-all,price-doc-forming-gds,price-doc-forming-gdsattr,price-doc-forming-gds-tnv,price-doc-forming-gds-sum,price-doc-forming-gds-qnty,c-price-doc-forming-gds,c-price-doc-forming-gdsattr,c-price-doc-forming-gds-tnv,c-price-doc-forming-gds-sum,c-price-doc-forming-gds-qnty,scales-gds,c-scales-gds,sert-join,c-sert,sert-join-attr":U
      v-ignore-list  = "c-bar-code,c-prod-bc,c-gds-hist,rcs-retail1barcode":U
      v-special-list = "bar-code,prod-bc,price-list,price-list-attr,c-price-list-attr":U
    .
def var vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-inform      as character no-undo .
    define variable bh_tbl-name   as handle    no-undo .
    define variable v-tbl-not-idx as character no-undo .
    define variable v-idx-avail   as logical   no-undo .
    define variable new-tbl-list  as character no-undo .
    define variable old-tbl-list  as character no-undo .
    define variable old-tbl-avail as logical   no-undo .
    define variable v-double-tbl  as character no-undo .
    define variable v-tbl-name    as character no-undo .
    define variable v-msg         as character no-undo .
    assign
      v-msg         = "":U
      v-tbl-not-idx = "":U
      new-tbl-list  = "":U
    .
    for each ub._Field no-lock
      where ub._Field._Field-Name = 'b-code':U
    ,first ub._File of ub._Field
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      if  lookup( ub._File._File-Name, v-std-list     ) = 0
      and lookup( ub._File._File-Name, v-ignore-list  ) = 0
      and lookup( ub._File._File-Name, v-special-list ) = 0
      then do:
        assign
          new-tbl-list = new-tbl-list + chr(10) + ub._File._File-Name
        .
      end.
      if lookup( ub._File._File-Name, v-std-list ) <> 0
        or lookup( ub._File._File-Name, new-tbl-list, chr(10) ) <> 0
      then do:
        create buffer bh_tbl-name for table substitute( "ub.&1":U, ub._File._File-Name ) .
        assign
          v-idx-avail = false
          v-inform    = bh_tbl-name:index-information(1)
          v-ind       = 2
        .
        block_chk-idx:
        do while v-inform <> ?
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          if v-inform <> ?
              and lookup( entry( 5, v-inform, ",":U ), 'b-code':U ) > 0
          then do:
            assign
              v-idx-avail = true
            .
            leave block_chk-idx.
          end.
          assign
            v-inform = bh_tbl-name:index-information( v-ind )
            v-ind    = v-ind + 1
          .
        end.
        if v-idx-avail = false then do:
          if lookup( ub._File._File-Name, new-tbl-list, chr(10) ) <> 0 then do:
            assign
              new-tbl-list = new-tbl-list + " (индекса нет)"
            .
          end.
          else do:
            assign
              v-tbl-not-idx = v-tbl-not-idx + chr(10) + ub._File._File-Name
            .
          end.
        end.
        delete object bh_tbl-name.
      end.
    end.
    assign
      old-tbl-list  = "":U
      v-double-tbl  = "":U
      v-num-entries = num-entries( v-std-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name    = entry( v-ind, v-std-list )
        old-tbl-avail = false
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if not available ub._File then do:
        assign
          old-tbl-avail = true
        .
      end.
      else do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'b-code':U
          no-error .
        if not available ub._Field then do:
          assign
            old-tbl-avail = true
          .
        end.
      end.
      if old-tbl-avail = true then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > v-ind
           or lookup( v-tbl-name, v-ignore-list ) > 0
           or lookup( v-tbl-name, v-special-list ) > 0
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    assign
      v-num-entries = num-entries( v-ignore-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name = entry( v-ind, v-ignore-list )
        old-tbl-avail = false
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if not available ub._File then do:
        assign
          old-tbl-avail = true
        .
      end.
      else do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'b-code':U
          no-error .
        if not available ub._Field then do:
          assign
            old-tbl-avail = true
          .
        end.
      end.
      if old-tbl-avail = true then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > 0
           or lookup( v-tbl-name, v-ignore-list ) > v-ind
           or lookup( v-tbl-name, v-special-list ) > 0
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    assign
      v-num-entries = num-entries( v-special-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name = entry( v-ind, v-special-list )
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if available ub._File then do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'b-code':U
          no-error .
      end.
      if not available ub._File
        or ( available ub._File
             and not available ub._Field
           )
      then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > 0
           or lookup( v-tbl-name, v-ignore-list ) > 0
           or lookup( v-tbl-name, v-special-list ) > v-ind
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    if v-tbl-not-idx <> "" then do:
      assign
        v-msg = v-msg + substitute( "Таблицы не имеют индекса с полями &3 на первом месте и нет спецобработки: &2&1&1", chr(10), v-tbl-not-idx, 'b-code':U )
      .
    end.
    if new-tbl-list <> "":U then do:
      assign
        v-msg = v-msg + substitute( "Нет обработки таблиц: &2&1&1", chr(10), new-tbl-list )
      .
    end.
    if v-double-tbl <> "":U then do:
      assign
        v-msg = v-msg + substitute( "В списках есть задублированные таблицы: &2&1&1", chr(10), v-double-tbl )
      .
    end.
    if old-tbl-list <> "":U then do:
      assign
        v-msg = v-msg + substitute( "В списках есть несуществующие таблицы или таблицы в которых отсутствуют переименовываемые поля: &2&1&1", chr(10), old-tbl-list )
      .
    end.
    if v-msg <> "":U then do:
      return error substitute( "Утилита переименования &3 не корректна.&1&1&2", chr(10), v-msg, 'b-code':U ) .
    end.
  end.
end procedure.
PROCEDURE create-bar-code:
  define input parameter loc-b-code        like ub.bar-code.b-code        no-undo .
  define input parameter loc-cli-base-rate like ub.bar-code.cli-base-rate no-undo .
  define input parameter loc-gds-code      like ub.bar-code.gds-code      no-undo .
  define input parameter loc-in-code       like ub.bar-code.in-code       no-undo .
  define input parameter loc-node-code     like ub.bar-code.node-code     no-undo .
  define input parameter loc-part-code     like ub.bar-code.part-code     no-undo .
  define input parameter loc-unit-cli      like ub.bar-code.unit-cli      no-undo .
  define input parameter loc-cr-db-num     like ub.bar-code.cr-db-num     no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info25, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info25 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info25 )
  :
    define buffer buf_bar-code   for ub.bar-code .
    define buffer buf_goods      for ub.goods .
    define buffer buf_prod-bc    for ub.prod-bc .
    define buffer buf_price-list for ub.price-list.
    define buffer buf_db         for ub.db.
    define buffer buf_clients    for ub.clients.
    define variable src-b-code       like ub.bar-code.b-code no-undo .
    define variable attach-to-b-code like ub.bar-code.b-code no-undo .
    define variable bar_code         like ub.prod-bc.b-str   no-undo .
    define variable load-bc          as   logical            no-undo .
    define variable cre-prod-bc      as   logical            no-undo .
    DEFINE VARIABLE var-rate-value   like ub.tax-rate-value.rate-value no-undo .
    define variable prod_bc_cr-db-num like ub.prod-bc.cr-db-num no-undo .
    find buf_bar-code exclusive-lock
      where buf_bar-code.b-code = loc-b-code
      no-error.
    if available buf_bar-code
       and buf_bar-code.b-code        = loc-b-code
       and buf_bar-code.gds-code      = loc-gds-code
       and buf_bar-code.node-code     = loc-node-code
       and buf_bar-code.part-code     = loc-part-code
       and buf_bar-code.in-code       = loc-in-code
       and buf_bar-code.unit-cli      = loc-unit-cli
       and buf_bar-code.cli-base-rate = loc-cli-base-rate
    then do:
      return.
    end.
    if available buf_bar-code
      and ( buf_bar-code.gds-code     <> loc-gds-code
            or buf_bar-code.node-code <> loc-node-code
            or buf_bar-code.part-code <> loc-part-code
            or buf_bar-code.in-code   <> loc-in-code
            or buf_bar-code.unit-cli  <> loc-unit-cli
          )
    then do:
      run write-to-log( "ОШИБКА! Принимается ошибочный бар-код " + string( loc-b-code )
                        + " для товара " + string( loc-gds-code ) + "." ).
      return error.
    end.
    find buf_bar-code exclusive-lock
      where buf_bar-code.gds-code  = loc-gds-code
        and buf_bar-code.node-code = loc-node-code
        and buf_bar-code.part-code = loc-part-code
        and buf_bar-code.in-code   = loc-in-code
        and buf_bar-code.unit-cli  = loc-unit-cli
    no-error.
    find buf_goods no-lock
      where buf_goods.gds-code = buf_bar-code.gds-code
      no-error.
    assign
      load-bc      = TRUE
      cre-prod-bc  = FALSE
      .
    if available buf_bar-code and buf_bar-code.b-code <> loc-b-code then do:
      if g#db-num = 0 then do:
        assign
          src-b-code       = loc-b-code
          attach-to-b-code = buf_bar-code.b-code
          load-bc          = FALSE
          .
      end.
      else do:
        assign
          src-b-code       = buf_bar-code.b-code
          attach-to-b-code = loc-b-code
          load-bc          = TRUE
          .
        run ren-b-code in this-procedure
          ( input src-b-code
           ,input attach-to-b-code
          ) no-error .
        if error-status :error then do:
          run write-to-log ( substitute("Ошибка при переименовании бар-кода &1.&2&3&2&4", src-b-code, chr(10), return-value, error-status :get-message(1) ) ).
          return error.
        end.
        run write-to-log ( "Существовавший бар-код" + chr(32) + string( src-b-code ) + chr(32)
                           + "заменен на пришедший" + chr(32) + string( loc-b-code )
                         ).
      end.
      assign
        cre-prod-bc = TRUE
        prod_bc_cr-db-num = buf_bar-code.cr-db-num
        .
    end.
    if load-bc then do:
      if not available buf_bar-code then do:
        create buf_bar-code.
      end.
      else do:
        find first bc-list where bc-list.b-code = buf_bar-code.b-code no-error.
        if not available bc-list then do:
          create bc-list.
          buffer-copy buf_bar-code to bc-list
            assign
              bc-list.del = yes
          .
        end.
        else do:
          for each bc-list
            where bc-list.b-code = buf_bar-code.b-code
          on error undo, return error
          :
            assign
              bc-list.del = yes
            .
          end.
        end.
      end.
      assign
        buf_bar-code.b-code        = loc-b-code
        buf_bar-code.cli-base-rate = loc-cli-base-rate
        buf_bar-code.gds-code      = loc-gds-code
        buf_bar-code.in-code       = loc-in-code
        buf_bar-code.node-code     = loc-node-code
        buf_bar-code.part-code     = loc-part-code
        buf_bar-code.unit-cli      = loc-unit-cli
        buf_bar-code.cr-db-num     = loc-cr-db-num
        .
      if not can-find(gds-list where gds-list.gds-code = buf_bar-code.gds-code no-lock) then do:
          find first bc-list where bc-list.b-code = buf_bar-code.b-code no-error.
          if not available bc-list then do:
            create bc-list.
            buffer-copy buf_bar-code to bc-list
              assign
                bc-list.del = no
              .
          end.
      end.
    end.
    if cre-prod-bc = true then do:
      run gen-bc in this-procedure
        ( input src-b-code
         ,output bar_code
        ).
      if can-find( first buf_prod-bc where buf_prod-bc.b-str = bar_code no-lock ) then do:
        run write-to-log ( "Системная ошибка!!! При перемещении собственного кода в Доп.БК обнаружен повторный Доп.БК код" ).
        return error.
      end.
      run create-prod-bc in this-procedure
        ( input attach-to-b-code
         ,input bar_code
         ,input yes
         ,input prod_bc_cr-db-num
         ,input ''
        ).
      run write-to-log ( substitute( "Вместо бар-кода &1 создан Доп.БК &2", src-b-code, bar_code ) ).
    end.
  end.
END PROCEDURE.
PROCEDURE create-prod-bc:
  define input parameter loc-b-code like ub.prod-bc.b-code no-undo.
  define input parameter loc-b-str  like ub.prod-bc.b-str  no-undo.
  define input parameter loc-bc-on  like ub.prod-bc.bc-on  no-undo.
  define input parameter loc-cr-db-num like ub.prod-bc.cr-db-num no-undo .
  define input parameter loc-bc-on-type like ub.prod-bc.bc-on-type no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info25, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info25 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info25 )
  :
    define variable v-param-type                as character                no-undo.
    define variable v-value-character           as character                no-undo.
    define variable v-value-date                as date                     no-undo.
    define variable v-value-decimal             as decimal                  no-undo.
    define variable v-value-integer             as INTEGER                  no-undo.
    define variable v-value-logical             AS LOGICAL                  no-undo.
    define variable v-tth                       as handle                   no-undo.
    define variable dpl-off as logical no-undo .
    define buffer buf_bar-code for ub.bar-code .
    define buffer buf_prod-bc  for ub.prod-bc .
    define buffer buf_goods    for ub.goods .
    define buffer cre_prod-bc  for ub.prod-bc.
    find cre_prod-bc where cre_prod-bc.b-code = loc-b-code
                       and cre_prod-bc.b-str  = loc-b-str
                    exclusive-lock no-error.
    if available cre_prod-bc
       and cre_prod-bc.b-code = loc-b-code
       and cre_prod-bc.b-str  = loc-b-str
       and cre_prod-bc.bc-on  = loc-bc-on
    then do:
      return.
    end.
    find buf_bar-code where buf_bar-code.b-code = loc-b-code no-lock no-error.
    if not available buf_bar-code then do:
      return error.
    end.
    find buf_goods where buf_goods.gds-code = buf_bar-code.gds-code no-lock no-error.
    if not available buf_goods then do:
      return error.
    end.
    if loc-bc-on = yes
      and can-find(first buf_prod-bc where buf_prod-bc.b-str   = loc-b-str
                                       and buf_prod-bc.b-code <> loc-b-code
                                       and buf_prod-bc.bc-on   = yes no-lock ) then do:
      run adm/shattri.p (
          input "get":U
          ,input  '':U
          ,input  0
          ,input  'gds-ref':U
          ,input  'dpl-off':U
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output dpl-off
          ,output v-param-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error.
      delete object v-tth.
      if dpl-off = yes then do:
        for each buf_prod-bc exclusive-lock
          where buf_prod-bc.b-str   = loc-b-str
            and buf_prod-bc.b-code <> loc-b-code
            and buf_prod-bc.bc-on   = yes
        on error undo, return error return-value
        :
          assign buf_prod-bc.bc-on = no.
          if not can-find(gds-list where gds-list.artic     = buf_goods.artic
                                     and gds-list.prod-type = buf_goods.prod-type
                                     and gds-list.prod-code = buf_goods.prod-code
                                   no-lock ) then do:
            find first pbc-list where pbc-list.rc = recid(buf_prod-bc) no-error.
            if not available pbc-list then do:
              create pbc-list.
            end.
            buffer-copy buf_prod-bc to pbc-list
              assign
                pbc-list.rc = recid( buf_prod-bc )
              .
            release pbc-list .
          end.
          run write-to-log( "Исходя из настроек, выключен существующий доп. бар-код" + chr(32) + buf_prod-bc.b-str
                            + chr(32) + "для кода" + chr(32) + string( buf_prod-bc.b-code ) ).
        end.
      end.
      assign loc-bc-on = no.
      run write-to-log( "Выключен пришедший доп. бар-код" + chr(32) + loc-b-str
                        + chr(32) + "для кода" + chr(32) + string( loc-b-code ) ).
    end.
    if not available cre_prod-bc then do:
      create cre_prod-bc.
    end.
    assign
      cre_prod-bc.b-code = loc-b-code
      cre_prod-bc.b-str  = loc-b-str
      cre_prod-bc.bc-on  = loc-bc-on
      cre_prod-bc.cr-db-num = loc-cr-db-num
      cre_prod-bc.bc-on-type = loc-bc-on-type
      .
    if not can-find(gds-list where gds-list.artic     = buf_goods.artic
                               and gds-list.prod-type = buf_goods.prod-type
                               and gds-list.prod-code = buf_goods.prod-code
                             no-lock ) then do:
      find first pbc-list where pbc-list.rc = recid(cre_prod-bc) no-error.
      if not available pbc-list then do:
        create pbc-list.
      end.
      buffer-copy cre_prod-bc to pbc-list
        assign
          pbc-list.rc = recid( cre_prod-bc )
        .
      release pbc-list .
    end.
  end.
END PROCEDURE.
procedure ren-b-code :
  define input parameter p-old-b-code as integer no-undo .
  define input parameter p-new-b-code as integer no-undo .
  do
  on error  undo, return error substitute( "ren-b-code. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "ren-b-code. stop" )
  on endkey undo, return error substitute( "ren-b-code. endkey" )
  :
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-tbl-name    as character no-undo .
    define variable fh            as handle    no-undo .
    define variable bh            as handle    no-undo .
    define variable qh            as handle    no-undo .
    define variable v-query       as character no-undo .
    define buffer buf-ren_bar-code        for ub.bar-code .
    define buffer buf-ren_goods           for ub.goods .
    define buffer buf-ren_prod-bc         for ub.prod-bc .
    define buffer buf-ren_db              for ub.db .
    define buffer buf-ren_clients         for ub.clients .
    define buffer buf-ren_price-list      for ub.price-list .
    define buffer buf-ren_price-list-attr for ub.price-list-attr .
    run valid-ren-bcod-tbl-list in this-procedure
      no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при проверке списка таблиц для обработки." skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    do transaction
    on error  undo, return error substitute( "ren-b-code (1.err). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "ren-b-code (1.stop). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    on quit   undo, return error substitute( "ren-b-code (1.quit). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    on endkey undo, return error substitute( "ren-b-code (1.endkey). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      find first buf-ren_bar-code exclusive-lock
        where buf-ren_bar-code.b-code  = p-old-b-code
        .
      find first buf-ren_goods no-lock
        where buf-ren_goods.gds-code = buf-ren_bar-code.gds-code
        .
      assign
        buf-ren_bar-code.b-code  = p-new-b-code
      .
      for each buf-ren_prod-bc exclusive-lock
          where buf-ren_prod-bc.b-code = p-old-b-code
      on error undo, return error substitute( "ren-b-code. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        assign
          buf-ren_prod-bc.b-code = p-new-b-code
          .
        if not can-find(gds-list where gds-list.artic     = buf-ren_goods.artic
                                  and gds-list.prod-type = buf-ren_goods.prod-type
                                  and gds-list.prod-code = buf-ren_goods.prod-code
                                  no-lock ) then do:
          find first pbc-list where pbc-list.rc = recid( buf-ren_prod-bc ) no-error.
          if not available pbc-list then do:
            create pbc-list.
          end.
          buffer-copy buf-ren_prod-bc to pbc-list
            assign
              pbc-list.rc = recid( buf-ren_prod-bc )
              pbc-list.del = no
            .
          release pbc-list .
        end.
      end.
      for each buf-ren_db no-lock
      on error undo, return error substitute( "ren-b-code. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        for each buf-ren_clients no-lock
          where buf-ren_clients.db-num = buf-ren_db.db-num
        on error undo, return error substitute( "ren-b-code. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          for each buf-ren_price-list exclusive-lock
            where buf-ren_price-list.obj-type = buf-ren_clients.obj-type
              and buf-ren_price-list.obj-code = buf-ren_clients.obj-code
              and buf-ren_price-list.b-code   = p-old-b-code
          on error undo, return error substitute( "ren-b-code. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
          :
            assign
              buf-ren_price-list.b-code = p-new-b-code
              .
            for each buf-ren_price-list-attr exclusive-lock
              where buf-ren_price-list-attr.doc-num    = buf-ren_price-list.doc-num
                and buf-ren_price-list-attr.price-type = buf-ren_price-list.price-type
                and buf-ren_price-list-attr.b-code     = buf-ren_price-list.b-code
              on error undo, return error substitute( "ren-b-code. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
              :
                assign
                  buf-ren_price-list-attr.b-code = p-new-b-code
                  .
              end.
          end.
        end.
      end.
      assign
        v-num-entries = num-entries( "bar-code-attr,c-bar-code-attr,bar-code-obj-attr,c-bar-code-obj-attr,chk-gds,c-chk-gds,chk-gds-pay,doc-prts,doc-prts-attr,cd-doc-line,c-cd-doc-line,cd-plu,c-cd-plu,c-doc-prts,c-price-list,prod-bc-attr,c-prod-bc-attr,prod-bc-db,prod-bc-db-attr,c-prod-bc-db-attr,price-all,price-doc-forming-gds,price-doc-forming-gdsattr,price-doc-forming-gds-tnv,price-doc-forming-gds-sum,price-doc-forming-gds-qnty,c-price-doc-forming-gds,c-price-doc-forming-gdsattr,c-price-doc-forming-gds-tnv,c-price-doc-forming-gds-sum,c-price-doc-forming-gds-qnty,scales-gds,c-scales-gds,sert-join,c-sert,sert-join-attr":U )
      .
      do v-ind = 1 to v-num-entries
      on error undo, return error substitute( "ren-b-code. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      :
        assign
          v-tbl-name = substitute( "ub.&1":U, trim( entry( v-ind, "bar-code-attr,c-bar-code-attr,bar-code-obj-attr,c-bar-code-obj-attr,chk-gds,c-chk-gds,chk-gds-pay,doc-prts,doc-prts-attr,cd-doc-line,c-cd-doc-line,cd-plu,c-cd-plu,c-doc-prts,c-price-list,prod-bc-attr,c-prod-bc-attr,prod-bc-db,prod-bc-db-attr,c-prod-bc-db-attr,price-all,price-doc-forming-gds,price-doc-forming-gdsattr,price-doc-forming-gds-tnv,price-doc-forming-gds-sum,price-doc-forming-gds-qnty,c-price-doc-forming-gds,c-price-doc-forming-gdsattr,c-price-doc-forming-gds-tnv,c-price-doc-forming-gds-sum,c-price-doc-forming-gds-qnty,scales-gds,c-scales-gds,sert-join,c-sert,sert-join-attr":U ) ) )
          v-query    = substitute( "for each &1 where &1.b-code = &2":U, v-tbl-name, p-old-b-code )
        .
        create buffer bh for table v-tbl-name .
        create query qh .
        qh:set-buffers( bh ).
        qh:query-prepare( v-query ).
        qh:query-open() .
        qh:get-first( exclusive-lock ).
        do while qh:query-off-end <> true
        on error  undo, return error substitute( "ren-b-code (2.err). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        on stop   undo, return error substitute( "ren-b-code (2.stop). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        on quit   undo, return error substitute( "ren-b-code (2.quit). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        on endkey undo, return error substitute( "ren-b-code (2.endkey). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          assign
            fh = bh:buffer-field( "b-code":U )
            fh:buffer-value = p-new-b-code .
          .
          bh:buffer-release() no-error .
          qh:get-next( exclusive-lock ).
        END.
        qh:query-close() .
        delete object qh.
        delete object bh.
      end.
    END.
  end.
  return.
end procedure.
def var vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info31 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info31, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info31, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info31, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info31, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info31 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info31, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info31 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info31, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info31, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info31, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info31, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info31, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info31, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info31 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info31 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info31, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info31, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info31, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info31 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info31 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info31, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info31, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable tempcxml_v-num_ as integer no-undo .
define  temp-table temp-xml-tables no-undo
field order as integer
field tbl-name as character
field tbl-handle_ as handle
field table-handle_ as handle
field uniq-gate-rec as character
field gate-name as character
field gate-handle_ as handle
field is-parent as logical
index pi is unique primary
uniq-gate-rec
tbl-name
index iorder
order
index gr
uniq-gate-rec
index gh
gate-handle_
index iparent
is-parent
.
define  temp-table temp-xml-records no-undo
field tbl-name as character
field uniq-key-rec as character
index pi is unique primary
tbl-name
uniq-key-rec
.
def var vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure get-gate-file-name :
define input parameter p-gate-rec as character no-undo .
define output  parameter p-gate-file-name as character no-undo .
define buffer buf_clob-data for ub.clob-data.
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
run gen-row-keyr in this-procedure ( input p-gate-rec
                                    ,input ?
                                    ,input "ub"
                                    ,input ?
                                    ,input no-lock
                                    ,output v-tbl-row
                                    ,output v-tbl-name) no-error.
if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                        ,vss-include-info32
                                                        ,p-gate-rec).
find first buf_clob-data no-lock where
          rowid(buf_clob-data) = v-tbl-row no-error.
if not available buf_clob-data then do:
  if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                          ,vss-include-info32
                                                          ,p-gate-rec).
end.
p-gate-file-name = buf_clob-data.file-name.
end procedure.
procedure get-gate-rec :
define input  parameter p-gate-name as character no-undo .
define output parameter p-gate-rec as character no-undo .
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info32, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info32 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info32 )
:
    find first buf_clob-bind no-lock where
              buf_clob-bind.uniq-key-rec = p-gate-name
          and buf_clob-bind.field-name = '':U
          and buf_clob-bind.part-num = 1
          and buf_clob-bind.resource-type = 'gate':U
          no-error.
    if not available buf_clob-bind then do:
      undo, return error substitute("Неверная ссылка на XSD -файл &1 для gate"
                                      , p-gate-name
                                      ).
    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = buf_clob-bind.db-num
          and buf_clob-data.int64-i= buf_clob-bind.int64-id no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB c ДБ &1 id &2 - файл &3"
                                      , buf_clob-bind.db-num
                                      , buf_clob-bind.int64-id
                                      , p-gate-name
                                      ).
    end.
    run gen-key-rec in this-procedure ( input 'clob-data':U
                              ,input buffer buf_clob-data:handle
                              ,output p-gate-rec).
end.
end procedure.
procedure get-gate-by-name :
define input  parameter p-gate-name as character no-undo .
define output parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
define variable v-db-num as integer no-undo .
define variable v-int64-id as int64 no-undo .
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info32, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info32 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info32 )
:
    find first buf_clob-bind no-lock where
              buf_clob-bind.uniq-key-rec = p-gate-name
          and buf_clob-bind.field-name = '':U
          and buf_clob-bind.part-num = 1
          and buf_clob-bind.resource-type = 'gate':U
          no-error.
    if not available buf_clob-bind then do:
      undo, return error substitute("Неверная ссылка на XSD -файл &1 для gate"
                                      , p-gate-name
                                      ).
    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = buf_clob-bind.db-num
          and buf_clob-data.int64-i= buf_clob-bind.int64-id no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB c ДБ &1 id &2 - файл &3"
                                      , buf_clob-bind.db-num
                                      , buf_clob-bind.int64-id
                                      , p-gate-name
                                      ).
    end.
    assign
    v-longchar = buf_clob-data.cdata
    .
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, buf_clob-data.file-name_, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "LONGCHAR"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    v-longchar = '':U.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему &1 из БД:&2&3", p-gate-name, chr(10), error-status:get-message(1) ).
    end.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    run gen-key-rec in this-procedure ( input 'clob-data':U
                              ,input buffer buf_clob-data:handle
                              ,output p-gate-rec).
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
      end.
    end.
end.
end procedure.
procedure get-gate-by-rec :
define input  parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define input-output parameter p-longchar  as longchar no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info32, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info32 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info32 )
:
  run gen-row-keyr in this-procedure (
                                        input  p-gate-rec
                                        ,input  ?
                                        ,input  "ub"
                                        ,input  ?
                                        ,input  NO-LOCK
                                        ,output v-rowid
                                        ,output v-tbl-name   ) no-error.
    find first buf_clob-data no-lock where
              rowid(buf_clob-data) = v-rowid  no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB  &1"
                                      , p-gate-rec
                                      ).
    end.
    assign
    v-longchar = buf_clob-data.cdata
    .
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, buf_clob-data.file-name_, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "LONGCHAR"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    define variable v-esm as character no-undo .
    v-esm = error-status:get-message(1) .
    if p-longchar <> ? then do:
      p-longchar = v-longchar.
    end.
    v-longchar = '':U.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему &1 (&2) из БД&3&4"
                                   , p-gate-rec
                                   , p-gate-rec
                                   , v-esm
                                   ).
    end.
    p-dsh:private-data = buf_clob-data.file-name_ + chr(4) + p-gate-rec.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
end.
end procedure.
procedure get-gate-by-file :
define input  parameter p-schema-file-name as character no-undo .
define input  parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info32, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info32 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info32 )
:
    COPY-LOB
    FROM  FILE p-schema-file-name
    TO  OBJECT v-longchar
    no-convert
    NO-ERROR .
    if error-status :error then do:
        undo, return error substitute("Не удалось считать файл схемы &1 в память&2&3"
                                  , p-schema-file-name
                              , chr(10)
                              , error-status:get-message(1) ).
    end.
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, p-schema-file-name, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "longchar"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    v-longchar = ''.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему из файла &1&2&3"
                                   , p-schema-file-name
                                   ,chr(10)
                                   , error-status:get-message(1)
                                   ).
    end.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1" and  uniq-gate-rec = "&2" '
                                   ,p-dsh:get-buffer-handle(v-ii):name
                                   ,p-gate-rec
                                   )) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):table
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
end.
end procedure.
procedure gate-clear :
define input  parameter p-dsh as handle no-undo .
define input  parameter p-xmlh as handle no-undo .
define variable v-dsh as handle no-undo .
define variable v-th as handle no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-dsh) then do:
      delete object p-dsh.
      v-dsh = p-dsh.
      p-dsh = ?.
    end.
    repeat while true:
      p-xmlh:find-first( substitute( " where gate-handle_ = &1 ", v-dsh)
                         , share-lock) no-error.
      if p-xmlh:available then do:
        assign
        v-th = p-xmlh:buffer-field("table-handle_"):buffer-value.
        if valid-handle(p-xmlh:buffer-field("table-handle_"))
        and valid-handle(v-th)
        and v-th:dynamic = yes
        then do:
          delete object p-xmlh:buffer-field("table-handle_"):buffer-value.
          p-xmlh:buffer-field("table-handle_"):buffer-value = ?.
        end.
        p-xmlh:buffer-delete().
      end.
      else do:
        leave.
      end.
    end.
    if p-xmlh:dynamic = yes
    and valid-handle(p-xmlh)
    then do:
      delete object p-xmlh:table-handle.
      p-xmlh = ?.
    end.
    v-dsh = ?.
  end.
end procedure.
procedure all-gates-clear :
define parameter buffer buf_temp-xml-tables for temp-xml-tables.
do
on error undo, return error
:
  for each buf_temp-xml-tables
  break
  by buf_temp-xml-tables.uniq-gate-rec
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
      if first-of(buf_temp-xml-tables.uniq-gate-rec) then do:
        delete object buf_temp-xml-tables.gate-handle_.
        buf_temp-xml-tables.gate-handle_ = ?.
      end.
      if valid-handle(buf_temp-xml-tables.table-handle_)
      and buf_temp-xml-tables.table-handle_:dynamic = no
      then do:
        delete object buf_temp-xml-tables.table-handle_.
        buf_temp-xml-tables.table-handle_ = ?.
      end.
      delete buf_temp-xml-tables.
  end.
end.
end procedure.
procedure fix-schemalocation :
define input-output  parameter p-longchar as longchar no-undo .
DEFINE VARIABLE hdoc AS HANDLE.
DEFINE VARIABLE hroot AS HANDLE.
DEFINE VARIABLE hnode-child AS HANDLE.
DEFINE VARIABLE hnode-attr AS HANDLE.
define variable v-jj as integer   no-undo .
define variable ok as logical   no-undo .
define variable v-path1                    as character                no-undo .
DEFINE VARIABLE v-full-path1               as character                no-undo .
DEFINE VARIABLE v-file-name1               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext1        as character                no-undo .
DEFINE VARIABLE v-file-name-ext1           as character                no-undo .
define variable v-schema-location          as character                no-undo .
do
on error undo, return error return-value
:
  CREATE X-DOCUMENT hdoc.
  CREATE X-noderef hroot.
  CREATE X-noderef hnode-child.
  CREATE X-noderef hnode-attr.
  hdoc:load("longchar", p-longchar, no) no-error.
  iF ERROR-STATUS:GET-MESSAGE(1) <> '' THEN message ERROR-STATUS:GET-MESSAGE(1) view-as alert-box .
  hdoc:get-document-element(hroot).
  _repeat:
  REPEAT v-jj = 1 TO hroot:NUM-CHILDREN:
    ok = hroot:GET-CHILD(hNode-Child, v-jj).
    if not ok then next.
    if hNode-Child:local-name = "include"
    then do:
      ok = hNode-Child:GET-ATTRIBUTE-NODE( hnode-attr, "schemaLocation" ).
        v-schema-location = hnode-attr:node-value.
        run gbl/filename.p (
                        input "exe/" + hnode-attr:node-value
                      ,output v-full-path1
                      ,output v-path1
                      ,output v-file-name1
                      ,output v-file-name-no-ext1
                      ,output v-file-name-ext1
                      ) no-error .
        if error-status :error then do:
          delete object hnode-attr.
          delete object hnode-child.
          delete object hroot.
          delete object hdoc.
          undo, return error substitute("Не удалось определить расположение схемы &1", v-schema-location).
        end.
      ok = hNode-Child:sET-ATTRIBUTE(  "schemaLocation", v-full-path1 ).
      leave  _repeat.
    end.
  END.
  hdoc:save("longchar", p-longchar).
  delete object hnode-attr.
  delete object hnode-child.
  delete object hroot.
  delete object hdoc.
end.
end procedure.
procedure gate-clb_fill-xml-tables :
define input parameter p-dsh as handle no-undo .
define input-output parameter p-xmlh as handle no-undo .
define variable v-ii as integer no-undo .
  do
  on error undo, return error
  :
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = entry(2, p-dsh:private-data, chr(4))
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
  end.
end procedure.
procedure all-gates-empty :
define buffer buf_temp-xml-tables for temp-xml-tables.
do
on error undo, return error
:
  for each buf_temp-xml-tables
  break
  by buf_temp-xml-tables.uniq-gate-rec
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    if valid-handle(buf_temp-xml-tables.tbl-handle_) then do:
      buf_temp-xml-tables.tbl-handle_:empty-temp-table().
    end.
  end.
end.
end procedure.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-proc-name  as character no-undo .
define variable v-proc-avail as logical   no-undo .
define new global shared variable g#load-rec  as handle no-undo .
define stream imp-stream.
define temp-table tt_pck-rcvd      no-undo like ub.pck-rcvd .
define temp-table tt_pck-rcvd-attr no-undo like ub.pck-rcvd-attr .
define temp-table tt_pck-sent      no-undo like ub.pck-sent .
define variable v-sub-rec-cnt as integer   no-undo.
define variable v-rec-cnt     as integer   no-undo.
define variable v-file-hash   as character no-undo .
define frame imp-pck
  p-db-src        label "БД" skip
  p-pck-num       label "Пакет" format ">>>>>>>>>9" skip
  p-file-pck-name label "Файл пакета" format "x(50)" skip
  v-rec-cnt       label "Основных записей" format ">>>>>>>>>9" skip
  v-sub-rec-cnt   label "Привязанных" format ">>>>>>>>>9" skip
  with view-as dialog-box side-labels 1 columns three-d title "** Разбор пакета"
.
  define variable mFrameView      as logical   no-undo init yes.
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame imp-pck:handle.
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
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameNWSError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameNWSError").
  end.
  mFrameView = not mBatchMode.
if transaction then do:
  message
    vss-workfile vss-revision vss-description skip
    substitute( "Вызов данной процедуры невозможен при наличии транзакции" )
    view-as alert-box error
  .
  return error .
end.
run str/imp2cdseth.p(this-procedure).
main_block:
do
on error  undo, return error substitute("&1. error main_block. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on endkey undo, return error substitute("&1. endkey main_block")
on stop   undo, return error substitute("&1. stop main_block")
:
  define variable v-err-msg as character no-undo .
  for each gds-list:
    delete gds-list.
  end.
  for each gdsolist:
    delete gdsolist.
  end.
  for each bc-list:
    delete bc-list.
  end.
  for each pbc-list:
    delete pbc-list.
  end.
  for each dc-list:
    delete dc-list.
  end.
  for each cash-txn:
    delete cash-txn.
  end.
  for each cash-txr:
    delete cash-txr.
  end.
  for each stpl-list:
    delete stpl-list.
  end.
  for each cash-pay-list:
    delete cash-pay-list.
  end.
  for each PromoAction-list:
    delete PromoAction-list.
  end.
   for each ext-classif-list:
      delete ext-classif-list.
   end.
   for each c-ext-classif-list:
      delete c-ext-classif-list.
   end.
  assign
    v-err-msg = "":U .
  .
  run gbl/md5.p(p-file-pck-name, output v-file-hash).
  run write-to-log( substitute("Файл: &1; Контрольная сумма: &2.", p-file-pck-name,  v-file-hash) ) .
  input stream imp-stream from value( p-file-pck-name ).
  run local-imp-pck in this-procedure
     no-error .
  if error-status :error then do:
    assign
      v-err-msg = substitute( "Ошибка приема пакета &1&2&3", p-file-pck-name, chr(10), return-value ).
    .
  end.
  input stream imp-stream close .
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run send-to-cash no-error.
  if error-status:error then do:
    run write-to-log("Ошибка при отправке на кассу" + chr(10)
                     + return-value
                    ) no-error.
  end.
  assign
    g#news-source-db = -1
  .
  if v-err-msg <> "":U then do:
    undo, return error v-err-msg .
  end.
end.
return .
procedure local-imp-pck :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define buffer buf_sys-ctrl          for ub.sys-ctrl .
    define buffer buf_pck-sent          for ub.pck-sent .
    define buffer buf_pck-rcvd          for ub.pck-rcvd .
    define buffer buf-src_db            for ub.db .
    define buffer buf-dst_db            for ub.db .
    define buffer buf-for-sent_pck-rcvd for ub.pck-rcvd.
    define buffer buf-for-rcvd_pck-sent for ub.pck-sent .
    define buffer buf_route             for ub.route .
    define variable v-ver-num     as character no-undo .
    define variable v-rec-full       as character no-undo.
    define variable v-rec-name       as character no-undo.
    define variable v-sub-rec-num    as integer   no-undo.
    define variable v-curr-rowid     as rowid     no-undo .
    define variable v-uniq-gate-rec  as character no-undo .
    define variable v-uniq-key-rt    as character no-undo .
    define variable Ok               as logical   no-undo.
    define variable pck-name-bad     as character no-undo.
    define variable v-present        as logical   no-undo .
    define variable v-ind            as integer   no-undo.
    define variable v-qnty-skip      as integer   no-undo.
    define variable v-today          as date      no-undo .
    define variable v-time           as integer   no-undo .
    define variable v-prev-crc       as character no-undo .
    define variable v-pos            as integer   no-undo .
    define variable v-temp-str       as character no-undo .
    define variable v-temp-all       as character extent 1000 no-undo .
    define variable v-beg-date      as character no-undo .
    define variable v-beg-time      as character no-undo .
    define variable v-type          as character no-undo .
    define variable v-deleted       as logical   no-undo .
    define variable v-pck-attr-exist as logical   no-undo .
    define variable v-del-pck-num    as integer   no-undo.
    define variable v-del-cnt        as integer   no-undo.
    define frame del-route
      v-del-pck-num   label "Пакет N" format ">>>>>>>>>9" skip
      v-del-cnt       label "Записей" format ">>>>>>>>>9"
      with view-as dialog-box side-labels 1 columns three-d title "Удаление маршрутизации"
    .
    find buf-src_db no-lock
      where buf-src_db.db-num = p-db-src
    .
    if trim( buf-src_db.db-key ) = "":U
      or buf-src_db.db-key = ?
    then do:
      run write-to-log( substitute("СПН для БД &1 отключена. Пакеты не принимаются.", p-db-src ) ) .
      undo, return error.
    end.
    find first buf_sys-ctrl no-lock .
    find buf-dst_db no-lock
      where buf-dst_db.db-num = buf_sys-ctrl.db-num
    .
    run write-to-log( substitute("Разбор пакета N &1 из БД N &2", p-pck-num, p-db-src ) ) no-error.
    if mFrameView
    then do:
       view frame imp-pck.
       assign
         frame imp-pck:title = substitute( "&1 из БД &2", frame imp-pck:title, trim( string( p-db-src, ">>>>>>>>9" ) ) )
       .
       do with frame imp-pck
       :
          assign
             p-db-src :screen-value        = string( p-db-src, p-db-src :format)
             p-pck-num :screen-value       = string( p-pck-num, p-pck-num :format)
             p-file-pck-name :screen-value = string( p-file-pck-name, p-file-pck-name :format)
          .
       end.
    end.
    run cur-time in this-procedure
      ( output v-today
      , output v-time
      ) no-error .
    if error-status :error then do:
      run write-to-log( vss-workfile + chr(32)
                        + "Ошибка при определении текущей даты!"
                      ).
      undo, return error.
    end.
    run pck-attr-exist
      ( input "pck-rcvd":U
      , input p-db-src
      , input p-pck-num
      , input 'beg-imp-date':U
      , output v-pck-attr-exist
      ) no-error.
    if error-status :error then do:
      run write-to-log( substitute( "&1. Ошибка при определении наличия атрибута начала разбора пакета &2 из БД &3"
                                    ,vss-workfile
                                    ,p-pck-num
                                    ,p-db-src
                                  )
                      ) .
    end.
    if v-pck-attr-exist <> true then do:
      run pck-attr-write in this-procedure
        ( input "pck-rcvd":U
        , input p-db-src
        , input p-pck-num
        , input 'beg-imp-date':U
        , input string( v-today, "99/99/9999" )
        ) no-error.
      if error-status :error then do:
        run write-to-log( substitute( "&1. Ошибка записи атрибута даты начала разбора пакета &2 из БД &3"
                                      ,vss-workfile
                                      ,p-pck-num
                                      ,p-db-src
                                    )
                        ) .
        undo, return error.
      end.
      run pck-attr-write in this-procedure
        ( input "pck-rcvd":U
        , input p-db-src
        , input p-pck-num
        , input 'beg-imp-time':U
        , input string( v-time, ">>>>>>>>>9" )
        ) no-error.
      if error-status :error then do:
        run write-to-log( substitute( "&1. Ошибка записи атрибута времени начала разбора пакета &2 из БД &3"
                                      ,vss-workfile
                                      ,p-pck-num
                                      ,p-db-src
                                    )
                        ) .
        undo, return error.
      end.
      run db-attr-write in this-procedure
        ( input p-db-src
        ,input 'need-gen-new-pack':U
        ,input "yes":U
        ) no-error.
      if error-status :error then do:
        run write-to-log( substitute( "&1. Ошибка записи атрибута формирования нового пакета для БД &2"
                                      ,vss-workfile
                                      ,p-db-src
                                    )
                        ) .
        undo, return error.
      end.
    end.
    find first buf_pck-rcvd no-lock
      where buf_pck-rcvd.db-num   = p-db-src
        and buf_pck-rcvd.pack-num = p-pck-num - 1
      no-error
    .
    if available buf_pck-rcvd then do:
      assign
        v-prev-crc = buf_pck-rcvd.crc-pack
      .
    end.
    else do:
      assign
        v-prev-crc = "":U
      .
    end.
    assign
      Ok = FALSE
      .
    assign
      g#news-source-db = p-db-src
      v-rec-cnt = 0
      v-sub-rec-cnt = 0
    .
    run nws-imps in this-procedure
      ( input-output v-sub-rec-cnt
       ,output       v-rec-full
      ) no-error.
    if error-status :error
      or v-rec-full = ?
    then do:
      undo, return error substitute( "Ошибка приема записи N &1&2&3", v-rec-cnt, chr(10), return-value ).
    end.
    else do:
      assign
        v-rec-name = trim( entry( 1, v-rec-full, chr(1) ) )
      .
    end.
    if v-rec-name <> "pck-conf":U then do:
      run write-to-log( substitute( "&1. Ошибка пакета! Первая запись должна быть конфигурацией пакета ( pck-conf )"
                                    ,vss-workfile
                                  )
                      ).
      undo, return error.
    end.
    create t-pck-conf.
    run nws-impl-without-check in this-procedure
      ( input (buffer t-pck-conf:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    run get-version-num in parparentproc
      ( output v-ver-num
      ).
    if t-pck-conf.db-num-dst <> g#db-num then do:
      run write-to-log( substitute( "&1. Ошибка приема! Ожидается прием пакета для БД № &2, а данный пакет для БД № &3"
                                    ,vss-workfile
                                    ,g#db-num
                                    ,t-pck-conf.db-num-dst
                                  )
                      ).
      undo, return error.
    end.
    if t-pck-conf.db-num-src <> p-db-src then do:
      run write-to-log( substitute( "&1. Ошибка приема! Ожидается прием пакета из БД № &2, а данный пакет из БД № &3"
                                    ,vss-workfile
                                    ,p-db-src
                                    ,t-pck-conf.db-num-src
                                  )
                      ).
      undo, return error.
    end.
    if t-pck-conf.src_db-key <> buf-src_db.db-key then do:
      run write-to-log( substitute( "&1. Ошибка приема! Ожидается прием пакета из БД с ключем &2, а данный пакет из БД с ключем &3"
                                    ,vss-workfile
                                    ,buf-src_db.db-key
                                    ,t-pck-conf.src_db-key
                                  )
                      ).
      undo, return error.
    end.
    if t-pck-conf.dst_db-key <> buf-dst_db.db-key then do:
      run write-to-log( substitute( "&1. Ошибка приема! Ожидается прием пакета для БД с ключем &2, а данный пакет для БД с ключем &3"
                                    ,vss-workfile
                                    ,buf-dst_db.db-key
                                    ,t-pck-conf.dst_db-key
                                  )
                      ).
      undo, return error.
    end.
    if t-pck-conf.pack-num <> p-pck-num then do:
      run write-to-log( substitute( "&1. Ошибка приема! Ожидается пакет № &2, а данный пакет № &3"
                                  ,vss-workfile
                                  ,p-pck-num
                                  ,t-pck-conf.pack-num
                                  )
                      ).
      undo, return error.
    end.
    if t-pck-conf.prev-crc <> v-prev-crc then do:
      run write-to-log( substitute("&1. Ошибка приема! Пакет &2 сформирован в некорректной БД", vss-workfile, p-pck-num) ).
      undo, return error.
    end.
    run trg/db-stat.p
      (input p-db-src
      ,input t-pck-conf.actual-date
      ,input t-pck-conf.actual-time-int
      ) no-error .
    if error-status :error
    then do:
      undo, return error substitute( "Ошибка при вызове сохранении даты актуальности остатков &1 &2 запись N &3 ", chr(10), return-value, v-rec-cnt ) .
    end.
    beg-imp:
    repeat
    on error  undo, return error substitute("&1. error beg-imp. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on endkey undo, return error substitute("&1. endkey beg-imp")
    on stop   undo, return error substitute("&1. stop beg-imp")
    :
      assign
        v-sub-rec-cnt = 0
      .
      run nws-imps in this-procedure
        ( input-output v-sub-rec-cnt
         ,output       v-rec-full
        ) no-error.
      if error-status :error
        or v-rec-full = ?
      then do:
        undo, return error substitute( "Ошибка приема записи N &1&2&3", v-rec-cnt, chr(10), return-value ).
      end.
      assign
        v-rec-name    = trim( entry( 1, v-rec-full, chr(1) ) )
      .
      if v-rec-name <> '**END OF PACKET**':U then do:
        assign
          v-uniq-gate-rec = entry( num-entries( v-rec-full, chr(1) ) - 4, v-rec-full, chr(1) )
          v-uniq-key-rt   = entry( num-entries( v-rec-full, chr(1) ) - 3, v-rec-full, chr(1) )
          v-sub-rec-num   = integer( entry( num-entries( v-rec-full, chr(1) ) - 2, v-rec-full, chr(1) ) )
        .
      end.
      CASE v-rec-name:
        when "pck-conf":U then do :
          run nws-impl-without-check in this-procedure
            ( input (buffer t-pck-conf:handle)
            ) no-error.
          if error-status :error then do:
            return error return-value .
          end.
        end.
        when 'pck-sent':U then do :
          transaction_block_pck-sent:
          do transaction
          on error  undo, return error substitute("&1. error transaction_block_pck-sent. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
          on endkey undo, return error substitute("&1. endkey transaction_block_pck-sent")
          on stop   undo, return error substitute("&1. stop transaction_block_pck-sent")
          :
            create tt_pck-sent.
            assign
              v-pos = seek( imp-stream )
            .
            run nws-impl-without-check in this-procedure
              ( input (buffer tt_pck-sent:handle)
              ) no-error.
            if error-status :error then do:
              return error return-value .
            end.
            if tt_pck-sent.pack-num = p-pck-num then do:
              if trim( tt_pck-sent.crc-pack ) = "" then do:
                seek stream imp-stream to v-pos .
                import stream imp-stream UNFORMATTED v-temp-str .
                run write-to-log( vss-workfile + chr(32)
                                  + substitute( "Ошибка обработки пакета: пакет N &1 не имеет ключа!!!", p-pck-num ) + chr(10)
                                  + substitute(" Позиция в файле &1", seek(imp-stream) ) + chr(10)
                                  + substitute("&1", v-temp-str ) + chr(10)
                                  ).
                undo, return error.
              end.
              if num-entries( tt_pck-sent.crc-pack, chr(32) ) < 4 then do:
                seek stream imp-stream to v-pos .
                import stream imp-stream UNFORMATTED v-temp-str .
                run write-to-log( vss-workfile + chr(32)
                                  + substitute( "Ошибка обработки пакета: некорректный ключ (&1) пакета N &2 !!!", tt_pck-sent.crc-pack, p-pck-num ) + chr(10)
                                  + substitute(" Позиция в файле &1", seek(imp-stream) ) + chr(10)
                                  + substitute("&1", v-temp-str ) + chr(10)
                                  ).
                undo, return error.
              end.
            end.
            else do:
              find first buf-for-sent_pck-rcvd exclusive-lock
                where buf-for-sent_pck-rcvd.db-num   = p-db-src
                  and buf-for-sent_pck-rcvd.pack-num = tt_pck-sent.pack-num
                no-error.
              if not available buf-for-sent_pck-rcvd then do:
                create buf-for-sent_pck-rcvd.
                buffer-copy tt_pck-sent to buf-for-sent_pck-rcvd
                  assign
                    buf-for-sent_pck-rcvd.db-num     = p-db-src
                    buf-for-sent_pck-rcvd.rcvd-recs  = 0
                .
              end.
            end.
          end.
        end.
        when 'pck-rcvd':U then do :
          create tt_pck-rcvd.
          run nws-impl-without-check in this-procedure
            ( input (buffer tt_pck-rcvd:handle)
            ) no-error.
          if error-status :error then do:
            return error return-value .
          end.
          find first buf-for-rcvd_pck-sent no-lock
            where buf-for-rcvd_pck-sent.db-num   = p-db-src
              and buf-for-rcvd_pck-sent.pack-num = tt_pck-rcvd.pack-num
            no-error.
          if available buf-for-rcvd_pck-sent then do:
            assign
              v-del-cnt = 0
            .
            if mFrameView
            then
               view frame del-route .
            for each buf_route exclusive-lock
              where buf_route.db-num    = buf-for-rcvd_pck-sent.db-num
                and buf_route.last-pack = tt_pck-rcvd.pack-num
            on error  undo, return error substitute("&1. error buf_route &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
            on endkey undo, return error substitute("&1. endkey buf_route")
            on stop   undo, return error substitute("&1. stop buf_route")
            :
              assign
                v-del-cnt = v-del-cnt + 1
              .
              if mFrameView
              then do with frame del-route
              :
                assign
                  v-del-pck-num :screen-value   = string( buf_route.last-pack, v-del-pck-num :format)
                  v-del-cnt :screen-value       = string( v-del-cnt, v-del-cnt :format)
                .
              end.
              delete buf_route.
            end.
            if mFrameView
            then
               hide frame del-route .
            transaction_block_pck-rcvd:
            do transaction
            on error  undo, return error substitute("&1. error transaction_block_pck-rcvd &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
            on endkey undo, return error substitute("&1. endkey transaction_block_pck-rcvd")
            on stop   undo, return error substitute("&1. stop transaction_block_pck-rcvd")
            :
              run cur-time in this-procedure
                ( output v-today
                , output v-time
                ) no-error .
              if error-status :error then do:
                run write-to-log( vss-workfile + chr(32)
                                  + "Ошибка при определении текущей даты!"
                                ).
                undo, return error.
              end.
              find first buf-for-rcvd_pck-sent exclusive-lock
                where buf-for-rcvd_pck-sent.db-num   = p-db-src
                  and buf-for-rcvd_pck-sent.pack-num = tt_pck-rcvd.pack-num
                .
              if buf-for-rcvd_pck-sent.BegImpDate = ? then do:
                assign
                  buf-for-rcvd_pck-sent.BegImpDate    = tt_pck-rcvd.BegImpDate
                  buf-for-rcvd_pck-sent.BegImpTimeInt = tt_pck-rcvd.BegImpTimeInt
                  buf-for-rcvd_pck-sent.BegImpTime    = tt_pck-rcvd.BegImpTime
                .
              end.
              assign
                buf-for-rcvd_pck-sent.rcvd          = yes
                buf-for-rcvd_pck-sent.EndImpDate    = tt_pck-rcvd.EndImpDate
                buf-for-rcvd_pck-sent.EndImpTimeInt = tt_pck-rcvd.EndImpTimeInt
                buf-for-rcvd_pck-sent.EndImpTime    = tt_pck-rcvd.EndImpTime
                buf-for-rcvd_pck-sent.RcvdDate      = v-today
                buf-for-rcvd_pck-sent.RcvdTimeInt   = v-time
                buf-for-rcvd_pck-sent.RcvdTime      = string( v-time, "HH:MM:SS" )
              .
            end.
          end.
          delete tt_pck-rcvd.
        end.
        when 'pck-rcvd-attr':U then do :
          create tt_pck-rcvd-attr.
          run nws-impl-without-check in this-procedure
            ( input (buffer tt_pck-rcvd-attr:handle)
            ) no-error.
          if error-status :error then do:
            return error return-value .
          end.
          transaction_block_pck-rcvd-attr:
          do transaction
          on error  undo, return error substitute("&1. error transaction_block_pck-rcvd-attr &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
          on endkey undo, return error substitute("&1. endkey transaction_block_pck-rcvd-attr")
          on stop   undo, return error substitute("&1. stop transaction_block_pck-rcvd-attr")
          :
            find first buf-for-rcvd_pck-sent exclusive-lock
              where buf-for-rcvd_pck-sent.db-num   = p-db-src
                and buf-for-rcvd_pck-sent.pack-num = tt_pck-rcvd-attr.pack-num
              no-error.
            if available buf-for-rcvd_pck-sent then do:
              case tt_pck-rcvd-attr.attr-code :
                when 'beg-imp-date':U then do:
                  assign
                    buf-for-rcvd_pck-sent.BegImpDate    = date( tt_pck-rcvd-attr.attr-value )
                  .
                end.
                when 'beg-imp-time':U then do:
                  assign
                    buf-for-rcvd_pck-sent.BegImpTimeInt = integer( tt_pck-rcvd-attr.attr-value )
                    buf-for-rcvd_pck-sent.BegImpTime    = string( buf-for-rcvd_pck-sent.BegImpTimeInt, "HH:MM:SS" )
                  .
                end.
              end case.
            end.
          end.
          delete tt_pck-rcvd-attr.
        end.
        when '**END OF PACKET**':U then do:
          assign
            v-rec-cnt = v-rec-cnt - 1
            OK = yes
            .
          leave beg-imp.
        end.
        when      "delete"
          or when "create"
          or when "command"
          or when "get-seq"
          or when "put-seq"
          or when "dlcr"
        then do :
          transaction_block_command:
          do transaction
          on error  undo, return error substitute("&1. error transaction_block_command&3&2&3&4&3запись N &5&3привязанная запись &6", vss-workfile, return-value, chr(10), error-status :get-message(1), v-rec-cnt, v-sub-rec-cnt )
          on endkey undo, return error substitute("&1. endkey transaction_block_command&2запись N &3&2привязанная запись &4", vss-workfile, chr(10), v-rec-cnt, v-sub-rec-cnt )
          on stop   undo, return error substitute("&1. stop transaction_block_command&2запись N &3&2привязанная запись &4", vss-workfile, chr(10), v-rec-cnt, v-sub-rec-cnt )
          :
            run check-imp-rec in this-procedure
              ( input  "create":U
               ,input  p-db-src
               ,input  p-pck-num
               ,input  v-uniq-key-rt
               ,output v-present
              ) no-error .
            if error-status :error then do:
              undo, return error substitute( "&1 запись N &2&3Позиция в файле &4", return-value, v-rec-cnt, chr(10), seek(imp-stream) ) .
            end.
            if v-present = true then do:
              assign
                v-qnty-skip  = v-sub-rec-num * 2
              .
              do v-ind = 1 to v-qnty-skip :
                import stream imp-stream v-temp-all .
              end.
            end.
            else do:
              run nws/imp-cmd.p
                ( input this-procedure
                 ,input v-rec-full
                 ,input v-sub-rec-num
                 ,input p-db-src
                ).
            end.
          end.
        end.
        otherwise do :
          transaction_block_otherwise:
          do transaction
          on error  undo, return error substitute("&1. error transaction_block_otherwise&3&2&3&4&3запись N &5&3привязанная запись &6", vss-workfile, return-value, chr(10), error-status :get-message(1), v-rec-cnt, v-sub-rec-cnt )
          on endkey undo, return error substitute("&1. endkey transaction_block_otherwise&2запись N &3&2привязанная запись &4", vss-workfile, chr(10), v-rec-cnt, v-sub-rec-cnt )
          on stop   undo, return error substitute("&1. stop transaction_block_otherwise&2запись N &3&2привязанная запись &4", vss-workfile, chr(10), v-rec-cnt, v-sub-rec-cnt )
          :
            run check-imp-rec in this-procedure
              ( input  "create":U
               ,input  p-db-src
               ,input  p-pck-num
               ,input  v-uniq-key-rt
               ,output v-present
              ) no-error .
            if error-status :error then do:
              undo, return error substitute( "&1 запись N &2&3Позиция в файле &4", return-value, v-rec-cnt, chr(10), seek(imp-stream) ) .
            end.
            if v-present = true then do:
              assign
                v-qnty-skip  = v-sub-rec-num * 2 + 1
              .
              do v-ind = 1 to v-qnty-skip :
                import stream imp-stream v-temp-all .
              end.
            end.
            else do:
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
  v-proc-name = substitute( "proc-load-&1", v-rec-name )
  v-proc-avail = FALSE
.
if (valid-handle(g#load-rec) <> true) then do:
  run nws/load-rec.p persistent no-error .
  if error-status :error or (valid-handle(g#load-rec) <> true) then do:
    message
      "Error starting nws/load-rec.p" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    stop .
  end.
end.
if lookup( v-proc-name, g#load-rec:internal-entries ) > 0 then do:
  if v-proc-avail = TRUE then do:
    return error substitute( "&1. Рассогласованы библиотеки приема новостей для таблицы &2"
                             ,vss-workfile
                             ,v-rec-name
                           ).
  end.
  run value(v-proc-name) in g#load-rec
      ( input this-procedure
       ,input p-pck-num
       ,input v-sub-rec-num
      ).
  assign
    v-proc-avail = TRUE
  .
end.
if v-proc-avail = FALSE then do:
  run proc-load-standart in this-procedure
      ( input v-rec-name
       ,input v-uniq-gate-rec
       ,input ?
       ,input this-procedure
       ,input v-sub-rec-num
       ,output v-curr-rowid
      ) .
end.
            end.
          end.
        end.
      END CASE.
    end.
    if t-pck-conf.total-recs <> v-rec-cnt then do:
      run write-to-log( vss-workfile + chr(32)
                        + "Не совпадает количество считанных записей и ожидаемое количество :" + chr(10)
                        + "принято: " + string( v-rec-cnt ) + chr(10)
                        + "должно быть:" + string( t-pck-conf.total-recs )
                      ).
      undo, return error.
    end.
    transaction_block_end:
    do transaction
    on error  undo, return error substitute("&1. error transaction_block_end &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on endkey undo, return error substitute("&1. endkey transaction_block_end")
    on stop   undo, return error substitute("&1. stop transaction_block_end")
    :
      find first tt_pck-sent no-lock
        where tt_pck-sent.db-num   = g#db-num
          and tt_pck-sent.pack-num = p-pck-num
        no-error
      .
      if not available tt_pck-sent then do:
        run write-to-log( substitute( "&1. Отсутствует полная информация о пакете &2 для БД &3"
                                      ,vss-workfile
                                      ,p-pck-num
                                      ,p-db-src
                                    )
                        ) .
        undo, return error.
      end.
      run cur-time in this-procedure
        ( output v-today
        , output v-time
        ) no-error .
      if error-status :error then do:
        run write-to-log( vss-workfile + chr(32)
                          + "Ошибка при определении текущей даты!"
                        ).
        undo, return error.
      end.
      find first buf_pck-rcvd exclusive-lock
        where buf_pck-rcvd.db-num   = p-db-src
          and buf_pck-rcvd.pack-num = p-pck-num
        no-error.
      if not available buf_pck-rcvd then do:
        create buf_pck-rcvd.
        buffer-copy tt_pck-sent to buf_pck-rcvd
          assign
            buf_pck-rcvd.db-num     = p-db-src
        .
        run pck-attr-exist
          ( input "pck-rcvd":U
          , input p-db-src
          , input p-pck-num
          , input 'beg-imp-date':U
          , output v-pck-attr-exist
          ) no-error.
        if error-status :error then do:
          run write-to-log( substitute( "&1. Ошибка при определении наличия атрибута начала разбора пакета &2 из БД &3"
                                        ,vss-workfile
                                        ,p-pck-num
                                        ,p-db-src
                                      )
                          ) .
        end.
        if v-pck-attr-exist = true then do:
          run pck-attr-value in this-procedure
            ( input "pck-rcvd":U
            , input p-db-src
            , input p-pck-num
            , input 'beg-imp-date':U
            , output v-beg-date
            , output v-type
            ) no-error.
          if error-status :error then do:
            run write-to-log( substitute( "&1. Ошибка получения атрибута даты начала разбора пакета &2 из БД &3"
                                          ,vss-workfile
                                          ,p-pck-num
                                          ,p-db-src
                                        )
                            ) .
            undo, return error.
          end.
          run pck-attr-delete in this-procedure
            ( input "pck-rcvd":U
            , input p-db-src
            , input p-pck-num
            , input 'beg-imp-date':U
            , output v-deleted
            ) no-error.
          if error-status :error then do:
            run write-to-log( substitute( "&1. Ошибка при удалении атрибута даты начала разбора пакета &2 из БД &3"
                                          ,vss-workfile
                                          ,p-pck-num
                                          ,p-db-src
                                        )
                            ) .
            undo, return error.
          end.
          run pck-attr-value in this-procedure
            ( input "pck-rcvd":U
            , input p-db-src
            , input p-pck-num
            , input 'beg-imp-time':U
            , output v-beg-time
            , output v-type
            ) no-error.
          if error-status :error then do:
            run write-to-log( substitute( "&1. Ошибка получения атрибута времени начала разбора пакета &2 из БД &3"
                                          ,vss-workfile
                                          ,p-pck-num
                                          ,p-db-src
                                        )
                            ) .
            undo, return error.
          end.
          run pck-attr-delete in this-procedure
            ( input "pck-rcvd":U
            , input p-db-src
            , input p-pck-num
            , input 'beg-imp-time':U
            , output v-deleted
            ) no-error.
          if error-status :error then do:
            run write-to-log( substitute( "&1. Ошибка при удалении атрибута времени начала разбора пакета &2 из БД &3"
                                          ,vss-workfile
                                          ,p-pck-num
                                          ,p-db-src
                                        )
                            ) .
            undo, return error.
          end.
          assign
            buf_pck-rcvd.BegImpDate    = date( v-beg-date )
            buf_pck-rcvd.BegImpTimeInt = integer( v-beg-time )
            buf_pck-rcvd.BegImpTime    = string( buf_pck-rcvd.BegImpTimeInt, "HH:MM:SS" )
          .
        end.
      end.
      assign
        buf_pck-rcvd.rcvd-recs     = v-rec-cnt
        buf_pck-rcvd.EndImpDate    = v-today
        buf_pck-rcvd.EndImpTimeInt = v-time
        buf_pck-rcvd.EndImpTime    = string( v-time, "HH:MM:SS" )
      .
      for each buf_pck-rcvd exclusive-lock
        where buf_pck-rcvd.db-num = p-db-src
          and buf_pck-rcvd.rcvd   = no
      on error  undo, return error substitute("&1. error buf_pck-rcvd &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
      on endkey undo, return error substitute("&1. endkey buf_pck-rcvd")
      on stop   undo, return error substitute("&1. stop buf_pck-rcvd")
      :
        find first tt_pck-sent no-lock
          where tt_pck-sent.db-num   = g#db-num
            and tt_pck-sent.pack-num = buf_pck-rcvd.pack-num
          no-error .
        if not available tt_pck-sent then do:
          assign
            buf_pck-rcvd.rcvd = yes
          .
        end.
      end.
      run check-imp-rec in this-procedure
        ( input  "delete":U
        ,input  p-db-src
        ,input  p-pck-num
        ,input  ?
        ,output v-present
        ) no-error .
      if error-status :error then do:
        run write-to-log( substitute( "&1. Ошибка при удалении уникальных ключей строк пакета. &2", vss-workfile, return-value ) ).
        undo, return error.
      end.
      run db-attr-write in this-procedure
        ( input p-db-src
        ,input 'need-gen-new-pack':U
        ,input "yes":U
        ) no-error.
      if error-status :error then do:
        run write-to-log( substitute( "&1. Ошибка записи атрибута формирования нового пакета для БД &2"
                                      ,vss-workfile
                                      ,p-db-src
                                    )
                        ) .
        undo, return error.
      end.
    end.
    for each tt_pck-sent :
      delete tt_pck-sent.
    end.
    delete t-pck-conf.
    if not OK then do:
      run write-to-log ( "Пакет принят не полностью!.." + chr(10)
                        + "Вероятно была ошибка ( передачи по модему," + chr(10)
                        + "копирование с дискеты, ... )" + chr(10)
                        + "Повторите прием пакета по модему, " + chr(10)
                        + "замените дискету; либо обратитесь" + chr(10)
                        + "к администратору системы."
                      ).
      pck-name-bad = substr( p-file-pck-name, 1, r-index( p-file-pck-name, ".txt" )) + "bad".
      os-delete value( pck-name-bad ).
      if os-error <> 0 then do:
        run adm/os-err.p ( output err-mess ).
        run write-to-log( "Удаление файла: " + pck-name-bad + chr(10) + err-mess ).
      end.
      os-rename value( p-file-pck-name ) value( pck-name-bad ).
      if os-error <> 0 then do:
        run adm/os-err.p ( output err-mess ).
        run write-to-log( "Переименование файла: " + p-file-pck-name
                          + "в файл: " + pck-name-bad + chr(10)
                          + err-mess ).
      end.
      undo, return error.
    end.
    if mFrameView
    then
       hide frame imp-pck.
  end.
end procedure.
procedure nws-imps :
  define input-output parameter p-counter  as integer   no-undo .
  define output       parameter p-rec-full as character no-undo .
  do
  on error  undo, return error substitute( "&1 (nws-imps). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (nws-imps). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (nws-imps). endkey", vss-workfile )
  :
    define variable v-imps-rec-name   as character no-undo .
    define variable v-rec-num         as integer   no-undo.
    define variable v-skip-rec        as logical   no-undo .
    assign
      v-skip-rec = false
    .
    block_imp-head-rec:
    repeat
    on error  undo, return error substitute("&1. error block_imp-head-rec. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on endkey undo, return error substitute("&1. endkey block_imp-head-rec")
    on stop   undo, return error substitute("&1. stop block_imp-head-rec")
    :
      if v-skip-rec = false then do:
        if p-counter = 0 then do:
          assign
            v-rec-cnt = v-rec-cnt + 1
          .
        end.
      end.
      else do:
        assign
          v-skip-rec = false
        .
      end.
      import stream imp-stream p-rec-full .
      assign
        v-imps-rec-name = trim( entry( 1, p-rec-full, chr(1) ) )
      .
      if v-imps-rec-name begins "pck-null-rec":U then do:
        if p-counter > 0 then do:
          assign
            p-counter = p-counter + 1
          .
        end.
      end.
      else do:
        if v-imps-rec-name begins "pck-pause":U then do:
          assign
            v-skip-rec = true
          .
          message
            "Просили паузу? Получите..."  skip
            substitute( "&1", p-rec-full ) skip
            "После нажатия OK все продолжится." skip
            view-as alert-box.
        end.
        else do:
          if v-imps-rec-name begins "pck-log-write":U then do:
            assign
              v-skip-rec = true
            .
            run write-to-log( substitute( ">>> &1", p-rec-full ) ).
          end.
          else do:
            leave block_imp-head-rec .
          end.
        end.
      end.
    end.
    if v-imps-rec-name <> '**END OF PACKET**':U then do:
      if p-counter = 0 then do:
        assign
          v-rec-num  = integer( entry( num-entries( p-rec-full, chr(1) ), p-rec-full, chr(1) ) )
        .
        if v-rec-cnt <> v-rec-num then do:
          undo, return error substitute( "&1. Ошибка обработки пакета: читается запись N &2, а должна быть N &3. Позиция в файле &4"
                                         ,vss-workfile
                                         ,v-rec-num
                                         ,v-rec-cnt
                                         ,seek(imp-stream)
                                       ).
        end.
      end.
      assign
        v-sub-rec-cnt = integer( entry( num-entries( p-rec-full, chr(1) ) - 1, p-rec-full, chr(1) ) )
      .
      if p-counter <> v-sub-rec-cnt then do:
        undo, return error substitute( "Ошибка пакета. Запись &1&2Принимается привязанная запись N &3, а должна быть N &4. Позиция в файле &5"
                                        ,v-rec-cnt
                                        ,chr(10)
                                        ,v-sub-rec-cnt
                                        ,p-counter
                                        ,seek(imp-stream)
                                      ) .
      end.
      if mFrameView
      then
      do with frame imp-pck
      :
        assign
          p-db-src :screen-value        = string( p-db-src, p-db-src :format)
          p-pck-num :screen-value       = string( p-pck-num, p-pck-num :format)
          p-file-pck-name :screen-value = string( p-file-pck-name, p-file-pck-name :format)
          v-rec-cnt :screen-value       = string( v-rec-cnt, v-rec-cnt :format)
          v-sub-rec-cnt :screen-value   = string( v-sub-rec-cnt, v-sub-rec-cnt :format)
        .
      end.
    end.
  end.
  return .
end procedure.
procedure nws-impl :
  define input  parameter p-tbl-name   as character no-undo .
  define input  parameter p-buf-handle as handle    no-undo .
  do
  on error  undo, return error substitute( "&1 (nws-impl). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (nws-impl). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (nws-impl). endkey", vss-workfile )
  :
    define variable v-fh-artic     as handle    no-undo .
    define variable v-fh-prod-type as handle    no-undo .
    define variable v-fh-prod-code as handle    no-undo .
    define variable v-fh-gds-code  as handle    no-undo .
    define variable v-fh-b-code    as handle    no-undo .
    define variable v-gds-code     as integer   no-undo .
    define variable v-b-code       as integer   no-undo .
    define variable v-old-b-code   as integer no-undo .
    run nws-impl-without-check in this-procedure
      ( input p-buf-handle
      ) no-error .
    if error-status :error then do:
      return error return-value .
    end.
    assign
      v-fh-artic    = p-buf-handle:buffer-field( 'artic':U )
      v-fh-gds-code = p-buf-handle:buffer-field( 'gds-code':U )
      v-fh-b-code   = p-buf-handle:buffer-field( 'b-code':U )
      no-error
    .
    if v-fh-artic <> ?
      and lookup( p-tbl-name, 'goods,c-goods':U) = 0
    then do:
      assign
        v-fh-prod-type = p-buf-handle:buffer-field( 'prod-type':U )
        v-fh-prod-code = p-buf-handle:buffer-field( 'prod-code':U )
        no-error
      .
      if v-fh-prod-type = ? then do:
        return error substitute( "(nws-impl) &1&2Поле &3 не найдено в таблице &4, а поле artic есть!"
                                  ,vss-workfile
                                  ,chr(10)
                                  ,'prod-type':U
                                  ,p-buf-handle:name
                                ).
      end.
      if v-fh-prod-code = ? then do:
        return error substitute( "(nws-impl) &1&2Поле &3 не найдено в таблице &4, а поле artic есть!"
                                  ,vss-workfile
                                  ,chr(10)
                                  ,'prod-code':U
                                  ,p-buf-handle:name
                                ).
      end.
      run check-avail-artic in this-procedure
        ( input v-fh-artic:buffer-value
         ,input v-fh-prod-type:buffer-value
         ,input integer( v-fh-prod-code:buffer-value )
        ) no-error.
      if error-status :error then do:
        return error return-value .
      end.
    end.
    if v-fh-gds-code <> ?
    then do:
      assign
        v-gds-code = integer( v-fh-gds-code:buffer-value )
      .
      run check-avail-gds-code in this-procedure
        ( input-output v-gds-code
        ) no-error.
      if error-status :error then do:
        return error return-value .
      end.
      assign
        v-fh-gds-code:buffer-value = v-gds-code
      .
    end.
    if v-fh-b-code <> ?
      and lookup( p-tbl-name, 'bar-code,c-bar-code,c-gds-hist,c-prod-bc,c-chk-gds,chk-gds,c-sert':U) = 0
    then do:
      assign
        v-old-b-code = integer( v-fh-b-code:buffer-value )
        v-b-code = integer( v-fh-b-code:buffer-value )
      .
      define variable v-ok-b-code as logical no-undo .
      v-ok-b-code = no.
      run check-avail-b-code in this-procedure
        ( input-output v-b-code
        ) no-error.
      if error-status :error then do:
        case p-tbl-name:
          when 'chk-gds':U then do:
          if v-old-b-code = 0
          and p-buf-handle:buffer-field("out-code"):buffer-value <> ? then do:
              v-ok-b-code = yes.
          end.
          end.
          when 'doc-prts':U
          or when 'c-doc-prts':U
          then do:
            if v-fh-b-code:buffer-value  < 0
            then do:
              v-ok-b-code = yes.
            end.
          end.
        end case.
        if v-ok-b-code = no then do:
          return error return-value .
        end.
      end.
      assign
        v-fh-b-code:buffer-value = v-b-code
      .
    end.
  end.
  return .
end procedure.
procedure nws-impl-without-check :
  define input  parameter p-buf-handle as handle    no-undo .
  do
  on error  undo, return error substitute( "&1 (nws-impl-without-check). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (nws-impl-without-check). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (nws-impl-without-check). endkey", vss-workfile )
  :
    define variable v-imp-str    as character extent 1000 no-undo .
    define variable v-num-fields as integer   no-undo .
    define variable v-ind        as integer   no-undo .
    define variable v-fld-name   as character no-undo .
    define variable v-fld-value  as character no-undo .
    define variable v-fh         as handle    no-undo .
    if not p-buf-handle:available then do:
      return error substitute( "(nws-impl-without-check) &1&2Buffer таблицы &3 еще не создан!"
                                ,vss-workfile
                                ,chr(10)
                                ,p-buf-handle:name
                              ).
    end.
    import stream imp-stream v-imp-str.
    if v-imp-str[1] <> "<num-fields>" then do:
      return error substitute( "(nws-impl-without-check) &1&2Неверный формат строки для импорта записи&2Строка должна начинаться с <num-fields> а начинается с &3!"
                                ,vss-workfile
                                ,chr(10)
                                ,v-imp-str[1]
                              ).
    end.
    assign
      v-fld-name   = "":U
      v-fld-value  = "":U
      v-num-fields = integer( v-imp-str[2] )
    .
    block_read:
    do v-ind = 3 to v-num-fields * 2 + 2 by 2
    on error undo, return error
    :
      assign
        v-fld-name  = v-imp-str[v-ind]
      .
      if v-fld-name <> "":U then do:
        assign
          v-fld-name  = substring( v-fld-name, 2, length(v-fld-name) - 2)
          v-fld-value = v-imp-str[v-ind + 1]
        .
        assign
          v-fh = p-buf-handle:buffer-field( v-fld-name ) no-error
        .
        if (error-status :error
          or v-fh = ?)
          and p-buf-handle:name <> "locb-marking"
        then do:
          return error substitute( "(nws-impl-without-check) &1&2Поле &3 не найдено в таблице &4&2&5"
                                    ,vss-workfile
                                    ,chr(10)
                                    ,v-fld-name
                                    ,p-buf-handle:name
                                    ,error-status :get-message ( 1 )
                                  ).
        end.
        if v-fh <> ? then do:
          v-fh:buffer-value = v-fld-value.
        end.
      end.
      else do:
        leave block_read.
      end.
    end.
  end.
  return .
end procedure.
procedure check-imp-rec :
  define input  parameter p-action   as character no-undo .
  define input  parameter p-db-num   as integer   no-undo .
  define input  parameter p-pack-num as integer   no-undo .
  define input  parameter p-uniq-key as character no-undo .
  define output parameter p-present  as logical   no-undo .
  do
  on error  undo, return error substitute( "&1 (check-imp-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (check-imp-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (check-imp-rec). endkey", vss-workfile )
  :
    define buffer buf_pck-keys for ub.pck-keys .
    case p-action :
      when "create":U then do:
        if not transaction then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute( "Вызов процедуры check-imp-rec( create ) возможен только в одной транзакции с приемом записи!" )
            view-as alert-box error
          .
          return error .
        end.
        find first buf_pck-keys
          where buf_pck-keys.db-num   = p-db-num
            and buf_pck-keys.pack-num = p-pack-num
            and buf_pck-keys.uniq-key = p-uniq-key
          no-error .
        if available buf_pck-keys then do:
          assign
            p-present = true
          .
        end.
        else do:
          do transaction
          on error undo, return error
          :
            create buf_pck-keys .
            assign
              buf_pck-keys.db-num   = p-db-num
              buf_pck-keys.pack-num = p-pack-num
              buf_pck-keys.uniq-key = p-uniq-key
              p-present = false
            .
          end.
        end.
      end.
      when "delete":U then do:
        for each buf_pck-keys exclusive-lock
          where buf_pck-keys.db-num   = p-db-num
            and buf_pck-keys.pack-num = p-pack-num
        on error  undo, return error substitute( "&1 (check-imp-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
        on stop   undo, return error substitute( "&1 (check-imp-rec). stop", vss-workfile )
        on endkey undo, return error substitute( "&1 (check-imp-rec). endkey", vss-workfile )
        :
          delete buf_pck-keys.
        end.
      end.
    end case.
  end.
  return.
end procedure.
procedure proc-load-standart :
  define input parameter p-tbl-name   as character no-undo.
  define input parameter p-uniq-gate-rec as character no-undo .
  define input parameter p-bh-handle  as handle    no-undo.
  define input parameter p-imp-handle as handle    no-undo.
  define input parameter l-counter    as integer   no-undo.
  define output parameter p-curr-rowid as rowid    no-undo.
  do
  on error  undo, return error substitute( "&1 (proc-load-standart). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (proc-load-standart). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (proc-load-standart). endkey", vss-workfile )
  :
    define variable v-full-tbl-name as character no-undo .
    define variable bh_tbl-name     as handle    no-undo .
    define variable fh_tbl-name     as handle    no-undo .
    define variable tt-name         as character no-undo .
    define variable tth             as handle    no-undo .
    define variable bh_tt           as handle    no-undo .
    define variable fh_tt           as handle    no-undo .
    define variable v-ok            as logical   no-undo .
    define variable v-rowid         as rowid     no-undo .
    define variable v-tbl-name      as character no-undo .
    define variable compare-log     as logical   no-undo.
    define variable v_dataseth      as handle    no-undo.
    define variable v-xmlh          as handle    no-undo.
    define variable v-table-ready   as logical   no-undo.
    define buffer buf_temp-xml-tables for temp-xml-tables.
    v-xmlh = buffer buf_temp-xml-tables:handle.
    if l-counter <> 0 then do:
      return error substitute( "&1 (proc-load-standart). Ошибка обработки записи &2&3Есть привязанные записи, а обработка идет для одной", vss-workfile, p-tbl-name, chr(10) ).
    end.
    if p-bh-handle <> ?
    and (not valid-handle(p-bh-handle)
         or p-bh-handle:type <> "buffer") then do:
      return error substitute( "&1 (proc-load-standart). Ошибка обработки записи &2&3Передан невалидный handle или hanlde не типа BUFFER", vss-workfile, p-tbl-name, chr(10) ).
    end.
    assign
      v-full-tbl-name = substitute( "ub.&1":U, p-tbl-name )
    .
    create temp-table tth.
    assign
      tt-name = "wt-" + p-tbl-name
      tth:undo = no
      v-ok = false
    .
    if p-bh-handle = ? then do:
      if p-uniq-gate-rec = '':U then do:
        assign
          v-ok = tth:create-like( v-full-tbl-name ) no-error
        .
      end.
      else do:
        define variable v-longchar as longchar no-undo .
        v-longchar = ?.
        run get-gate-by-rec in this-procedure ( input p-uniq-gate-rec
                                                ,output v_dataseth
                                                ,input-output v-xmlh
                                                ,input-output v-longchar
                                                ) no-error.
        if error-status:error then do:
           return error substitute( "&1 (proc-load-standart). Ошибка при создании временной таблицы &2 (3)", vss-workfile, tt-name ) .
        end.
        find first buf_temp-xml-tables where
                  buf_temp-xml-tables.uniq-gate-rec = p-uniq-gate-rec
              and buf_temp-xml-tables.tbl-name = p-tbl-name no-error.
        if not available buf_temp-xml-tables then do:
           if valid-handle(v_dataseth) then do:                    run gate-clear in this-procedure ( input v_dataseth                                                     , input buffer buf_temp-xml-tables:handle).                   end.
           return error substitute( "&1 (proc-load-standart). Ошибка при создании временной таблицы &2 (4)", vss-workfile, tt-name ) .
        end.
        bh_tt = buf_temp-xml-tables.tbl-handle_.
        v-ok = yes.
        v-table-ready = yes.
      end.
    end.
    else do:
      assign
        v-ok = tth:create-like( p-bh-handle ) no-error
      .
    end.
    if v-ok <> true then do:
      return error substitute( "&1 (proc-load-standart). Ошибка при создании временной таблицы &2 (1)", vss-workfile, tt-name ) .
    end.
    if not v-table-ready then do:
      assign
        v-ok = false
      .
      assign
        v-ok = tth:temp-table-prepare( tt-name ) no-error
      .
      if v-ok <> true then do:
      if valid-handle(v_dataseth) then do:                    run gate-clear in this-procedure ( input v_dataseth                                                     , input buffer buf_temp-xml-tables:handle).                   end.
        return error substitute( "&1 (proc-load-standart). Ошибка при создании временной таблицы &2 (2)", vss-workfile, tt-name ) .
      end.
      assign
        bh_tt = tth:default-buffer-handle
      .
    end.
    assign
      v-ok = false
    .
    assign
      v-ok = bh_tt:buffer-create no-error
    .
    if v-ok <> true then do:
      if valid-handle(v_dataseth) then do:                    run gate-clear in this-procedure ( input v_dataseth                                                     , input buffer buf_temp-xml-tables:handle).                   end.
      return error substitute( "&1 (proc-load-standart). Ошибка при создании буфера временной таблицы.", vss-workfile ).
    end.
    run nws-impl in p-imp-handle
      ( input p-tbl-name
       ,input bh_tt
      ) no-error.
    if error-status :error then do:
      if valid-handle(v_dataseth) then do:                    run gate-clear in this-procedure ( input v_dataseth                                                     , input buffer buf_temp-xml-tables:handle).                   end.
      return error return-value .
    end.
    if p-bh-handle = ? then do:
      run gen-row-keyr in this-procedure
        ( input p-tbl-name
         ,input bh_tt
         ,input "ub":U
         ,input ?
         ,input exclusive-lock
         ,output v-rowid
         ,output v-tbl-name
        ) no-error .
      if error-status :error then do:
        if valid-handle(v_dataseth) then do:                    run gate-clear in this-procedure ( input v_dataseth                                                     , input buffer buf_temp-xml-tables:handle).                   end.
        return error substitute( "&1 (proc-load-standart). Ошибка при определении в БД rowid для записи &2.&3&4", vss-workfile, p-tbl-name, chr(10), return-value ).
      end.
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      run gen-row-keyr in this-procedure
        ( input p-tbl-name
         ,input bh_tt
         ,input ?
         ,input p-bh-handle
         ,input ?
         ,output v-rowid
         ,output v-tbl-name
        ) no-error .
      if error-status :error then do:
        if valid-handle(v_dataseth) then do:                    run gate-clear in this-procedure ( input v_dataseth                                                     , input buffer buf_temp-xml-tables:handle).                   end.
        return error substitute( "&1 (proc-load-standart). Ошибка при определении в Temp-table rowid записи для ключа &2.&3&4", vss-workfile, p-tbl-name, chr(10), return-value ).
      end.
      create buffer bh_tbl-name for table p-bh-handle:table-handle .
    end.
    bh_tbl-name:find-by-rowid( v-rowid, exclusive-lock ) no-error .
    if not bh_tbl-name:available then do:
      assign
        v-ok = false
      .
      assign
        v-ok = bh_tbl-name:buffer-create no-error
      .
      if v-ok <> true then do:
        if valid-handle(v_dataseth) then do:                    run gate-clear in this-procedure ( input v_dataseth                                                     , input buffer buf_temp-xml-tables:handle).                   end.
        return error substitute( "&1 (proc-load-standart). Ошибка при создании буфера временной таблицы.", vss-workfile, p-tbl-name ).
      end.
      assign
        compare-log = false
      .
    end.
    else do:
      assign
        compare-log = bh_tbl-name:buffer-compare( bh_tt, 'case-sensitive':U )
      .
    end.
    if compare-log = false then do:
      assign
        v-ok = false
      .
      assign
        v-ok = bh_tbl-name:buffer-copy( bh_tt ) no-error
      .
      if v-ok <> true then do:
        if valid-handle(v_dataseth) then do:                    run gate-clear in this-procedure ( input v_dataseth                                                     , input buffer buf_temp-xml-tables:handle).                   end.
        return error substitute( "&1 (proc-load-standart). BUFFER-COPY не прошел для таблицы &2", vss-workfile, p-tbl-name ).
      end.
    end.
    assign
      v-ok = false
      p-curr-rowid = bh_tbl-name:rowid
    .
    assign
      v-ok = bh_tbl-name:buffer-release() no-error
    .
    if v-ok <> true then do:
      if valid-handle(v_dataseth) then do:                    run gate-clear in this-procedure ( input v_dataseth                                                     , input buffer buf_temp-xml-tables:handle).                   end.
      return error substitute( "&1 (proc-load-standart). buffer-release не прошел для таблицы &2", vss-workfile, p-tbl-name ).
    end.
    assign
      v-ok = false
    .
    assign
      v-ok = tth:clear() no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (proc-load-standart). Ошибка при очистке временной таблицы &2", vss-workfile, tt-name ) .
    end.
    delete object bh_tbl-name .
    delete object tth .
    if valid-handle(v_dataseth) then do:                    run gate-clear in this-procedure ( input v_dataseth                                                     , input buffer buf_temp-xml-tables:handle).                   end.
    assign
      fh_tbl-name  = ?
      fh_tt        = ?
      bh_tt        = ?
      v_dataseth   = ?
      v-xmlh       = ?
    .
  end.
  return .
end procedure.
procedure skip-rec :
  do
  on error  undo, return error substitute( "&1 (skip-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (skip-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (skip-rec). endkey", vss-workfile )
  :
    define variable v-skip-str    as character extent 1000 no-undo .
    import stream imp-stream v-skip-str.
  end.
  return .
end procedure.
