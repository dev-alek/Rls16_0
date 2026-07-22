block-level on error undo, throw.
define input  parameter p-esys-id      like ub.ext-system.esys-id no-undo .
define input  parameter p-db-num       like ub.ext-system.db-num no-undo .
define output parameter p-err-gen-pack as   integer      no-undo .
define output parameter p-cre-all-pck  as   logical      no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Подготовка пакета(ов) OpenXML".
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
      p-vss-parameters = substitute('&1':u,p-db-num)
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable g#auto-pid           as integer   no-undo .
define  shared variable conn-par             as character no-undo .
define  shared variable g#auto-user-id       as character no-undo .
define  shared variable g#auto-user-login    as character no-undo .
define  shared variable g#auto-user-password as character no-undo .
define  shared variable v-socket             as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable auto-window-h     as handle    no-undo .
define  shared variable auto-log-msg-h    as handle    no-undo .
define  shared variable hand-log-msg-h    as handle    no-undo .
define  shared variable log-file-name     as character no-undo initial ? .
define  shared variable add-log-file-name as character no-undo initial ? .
define  shared variable writelogvalue     as character no-undo initial ? .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define  shared variable oxml-exch-dir as character no-undo .
define  shared variable oxml-heap-dir as character no-undo .
define variable err-mess as character no-undo .
define temp-table t-pck-conf no-undo
  field esys-id         as integer
  field db-num          as integer
  field current-db-num  as integer
  field pack-num        as integer
  field rcvd-recs       as integer
  field total-recs      as integer
  field sys-key         as character
  field src_db-key      as character
  field ver-num         as character
  field prev-crc        as character
  field actual-date     as date
  field actual-time-int as integer
.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-lock no-undo
  field lock-conn-id   as integer   label "Номер Подключения"
  field user-name      as character label "Пользователь"
  field lock-flag      as character label "Флаг"
  field trans-id       as integer   label "Транзакция"
  field trans-txtime   as character
  field trans-state    as character
  field trans-dur      as integer
  field connect-type   as character label "Подключение"
  field connect-time   as character format "x(20)"
  field connect-device as character format "x(40)" label "Устройство"
  .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure esallatr-name :
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
    case p-code :
            when 'custom-pack-name':U then do:     assign     p-label = "Имя файла в ВС"     p-type = 'C':U      p-format = "X(255)"     p-label = "Имя файла в ВС"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
            when 'route-custom-pack-name':U then do:     assign     p-label = "Иям файла в ВС"     p-type = 'C':U      p-format = "X(255)"     p-label = "Иям файла в ВС"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут ВС &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure esallatr-tooltip :
do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'custom-pack-name':U then do:     assign     p-tooltip = "Имя файла в ВС"     p-label = "Имя файла в ВС" .   end.
            when 'route-custom-pack-name':U then do:     assign     p-tooltip = "Имя файла в ВС"     p-label = "Иям файла в ВС" .   end.
      otherwise do:
        undo, return error substitute("Неизвестный атрибут ВС &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure esallatr-value :
do
  on error undo, return error
  :
  define input  parameter p-table-name as character no-undo .
  define input  parameter p-key1     as int64 no-undo .
  define input  parameter p-key2     as int64 no-undo .
  define input  parameter p-key3     as character no-undo .
  define input  parameter p-key4     as character no-undo .
  define input  parameter p-key5     as int64 no-undo .
  define input  parameter p-key6     as int64 no-undo .
  define input  parameter p-key7     as character no-undo .
  define input  parameter p-key8     as character no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  define buffer buf_esys-all-attr for ub.esys-all-attr.
  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-user-can-edit  as logical   no-undo .
  define variable v-output-display as logical   no-undo .
  define variable v-other          as character no-undo .
    run esallatr-name in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    Find first  buf_esys-all-attr no-lock where
                buf_esys-all-attr.attr-code = p-code
           and  buf_esys-all-attr.table-name  = p-table-name
           and  buf_esys-all-attr.key1  = p-key1
           and  buf_esys-all-attr.key2  = p-key2
           and  buf_esys-all-attr.key3  = p-key3
           and  buf_esys-all-attr.key4  = p-key4
           and  buf_esys-all-attr.key5  = p-key5
           and  buf_esys-all-attr.key6  = p-key6
           and  buf_esys-all-attr.key7  = p-key7
           and  buf_esys-all-attr.key8  = p-key8  no-error .
   if avail buf_esys-all-attr then do:
    assign
    p-value = buf_esys-all-attr.attr-value.
   end.
   else do:
    assign
    p-value = if p-type = 'L':U then "no":U else "".
   end.
end.
end procedure.
procedure esallatr-write :
  do
  on error undo, return error
  :
    define input  parameter p-table-name as character no-undo .
    define input  parameter p-key1     as int64 no-undo .
    define input  parameter p-key2     as int64 no-undo .
    define input  parameter p-key3     as character no-undo .
    define input  parameter p-key4     as character no-undo .
    define input  parameter p-key5     as int64 no-undo .
    define input  parameter p-key6     as int64 no-undo .
    define input  parameter p-key7     as character no-undo .
    define input  parameter p-key8     as character no-undo .
    define input  parameter p-code     as character no-undo .
    define input  parameter p-value    like ub.esys-all-attr.attr-value no-undo .
    define buffer buf_esys-all-attr for ub.esys-all-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run esallatr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    Find first  buf_esys-all-attr exclusive-lock where
                buf_esys-all-attr.attr-code = p-code
           and  buf_esys-all-attr.table-name  = p-table-name
           and  buf_esys-all-attr.key1  = p-key1
           and  buf_esys-all-attr.key2  = p-key2
           and  buf_esys-all-attr.key3  = p-key3
           and  buf_esys-all-attr.key4  = p-key4
           and  buf_esys-all-attr.key5  = p-key5
           and  buf_esys-all-attr.key6  = p-key6
           and  buf_esys-all-attr.key7  = p-key7
           and  buf_esys-all-attr.key8  = p-key8  no-error .
    if not available buf_esys-all-attr then do:
      assign
      buf_esys-all-attr.attr-code = p-code
      buf_esys-all-attr.table-name  = p-table-name
      buf_esys-all-attr.key1  = p-key1
      buf_esys-all-attr.key2  = p-key2
      buf_esys-all-attr.key3  = p-key3
      buf_esys-all-attr.key4  = p-key4
      buf_esys-all-attr.key5  = p-key5
      buf_esys-all-attr.key6  = p-key6
      buf_esys-all-attr.key7  = p-key7
      buf_esys-all-attr.key8  = p-key8
      buf_esys-all-attr.attr-value = p-value
      no-error.
    end.
    ELSE
    assign
    buf_esys-all-attr.attr-value = p-value no-error
    .
  end.
end procedure.
procedure esallatr-exist :
  do
  on error undo, return error
  :
    define input  parameter p-table-name as character no-undo .
    define input  parameter p-key1     as int64 no-undo .
    define input  parameter p-key2     as int64 no-undo .
    define input  parameter p-key3     as character no-undo .
    define input  parameter p-key4     as character no-undo .
    define input  parameter p-key5     as int64 no-undo .
    define input  parameter p-key6     as int64 no-undo .
    define input  parameter p-key7     as character no-undo .
    define input  parameter p-key8     as character no-undo .
    define input  parameter p-code     like ub.esys-all-attr.attr-code  no-undo .
    define output parameter p-exist   AS LOGICAL no-undo .
    define buffer buf_esys-all-attr for ub.esys-all-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run esallatr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    Find first  buf_esys-all-attr no-lock where
                buf_esys-all-attr.attr-code = p-code
           and  buf_esys-all-attr.table-name  = p-table-name
           and  buf_esys-all-attr.key1  = p-key1
           and  buf_esys-all-attr.key2  = p-key2
           and  buf_esys-all-attr.key3  = p-key3
           and  buf_esys-all-attr.key4  = p-key4
           and  buf_esys-all-attr.key5  = p-key5
           and  buf_esys-all-attr.key6  = p-key6
           and  buf_esys-all-attr.key7  = p-key7
           and  buf_esys-all-attr.key8  = p-key8  no-error .
    if available buf_esys-all-attr then do:
      P-EXIST = YES.
    end.
  end.
end procedure.
procedure esallatr-delete :
  do
  on error undo, return error
  :
    define input  parameter p-table-name as character no-undo .
    define input  parameter p-key1     as int64 no-undo .
    define input  parameter p-key2     as int64 no-undo .
    define input  parameter p-key3     as character no-undo .
    define input  parameter p-key4     as character no-undo .
    define input  parameter p-key5     as int64 no-undo .
    define input  parameter p-key6     as int64 no-undo .
    define input  parameter p-key7     as character no-undo .
    define input  parameter p-key8     as character no-undo .
    define input parameter  p-code     like ub.esys-all-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo .
    define buffer buf_esys-all-attr for ub.esys-all-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run esallatr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    Find first  buf_esys-all-attr exclusive-lock where
                buf_esys-all-attr.attr-code = p-code
           and  buf_esys-all-attr.table-name  = p-table-name
           and  buf_esys-all-attr.key1  = p-key1
           and  buf_esys-all-attr.key2  = p-key2
           and  buf_esys-all-attr.key3  = p-key3
           and  buf_esys-all-attr.key4  = p-key4
           and  buf_esys-all-attr.key5  = p-key5
           and  buf_esys-all-attr.key6  = p-key6
           and  buf_esys-all-attr.key7  = p-key7
           and  buf_esys-all-attr.key8  = p-key8  no-error .
    if not available buf_esys-all-attr then do:
      p-DELETED = NO.
    end.
    ELSE DO:
      delete buf_esys-all-attr.
      p-DELETED = YES.
    END.
  end.
end procedure.
procedure esallatr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'custom-pack-name':U then do:     assign     p-news = true.   end.
            when 'route-custom-pack-name':U then do:     assign     p-news = true.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут ВС &1", p-code ).
      end.
    end.
  end.
end procedure.
  define variable v-pack-num   as integer   no-undo .
  define variable v-pack-name  as character no-undo .
  define variable v-source-dir as character no-undo .
  define variable v-target-dir as character no-undo .
  define variable v-temp-dir   as character no-undo .
  define variable v-log-file-name as character no-undo .
  define variable v-list-file-name as character no-undo .
  define variable route-cnt       as integer no-undo .
  define variable rec-cnt         as integer no-undo .
  define variable qnty-of-cur-rec as integer no-undo .
  define variable v-max-pack-size as integer no-undo .
  define variable v-today        as date    no-undo .
  define variable v-time         as integer no-undo .
  define variable v-last-tbl-ord like ub.route.tbl-ord no-undo .
  define variable v-custom-pack-name as character no-undo .
  define variable v-custom-pack-flag as logical   no-undo .
  define buffer buf_sys-ctrl for ub.sys-ctrl .
  define buffer buf_ext-system   for ub.ext-system.
  define buffer buf_esys-route    for ub.esys-route.
  define buffer buf_esys-pck-sent for ub.esys-pck-sent .
  define buffer buf_esys-all-attr for ub.esys-all-attr.
  define variable esys-attr-value  as character no-undo .
  define variable esys-attr-exist  as logical   no-undo .
  define variable db-esys-attr-exist as logical   no-undo .
  define variable db-esys-attr-value as character no-undo .
  define variable db-esys-attr-type  as character no-undo .
  define variable v-gen-new-xpack as logical   no-undo .
  define variable v-fst-pck      as integer   no-undo .
  define variable v-success      as logical   no-undo .
  define variable v-sys-key  as character no-undo .
  define frame inf
    p-esys-id   label "для ВС" format ">>>>>>>>9"
    v-pack-num  label "Пакет N" format ">>>>>>>>9"
    route-cnt   label "Основных записей"
    rec-cnt     label "Привязанных"
    with view-as dialog-box side-labels 1 columns three-d title "** Формирование пакета".
  define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.
  mFramHandle = frame inf:handle.
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameoxmError").
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameoxmError").
  end.
  mFrameView = not session:batch-mode and mFramHandle:visible.
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  if transaction then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Вызов данной процедуры невозможен при наличии транзакции" )
      view-as alert-box error
    .
    return error .
  end.
  assign
    v-fst-pck = ?
    p-err-gen-pack = 0
    v-gen-new-xpack = false
    p-cre-all-pck  = true
  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currsysk in g#library
  (output v-sys-key
  ) no-error .
  find first buf_ext-system no-lock where
          buf_Ext-system.esys-id = p-esys-id
      and buf_Ext-system.db-num = p-db-num.
  v-success = no.
  run bge/lockesys.p (
      input buf_ext-system.esys-id
    ,input buf_ext-system.db-num
    ,buffer buf_ext-system
    ,output v-success) no-error.
  if error-status:error
  or not v-success
  then do:
    run write-to-log in this-procedure ( substitute( "&1. &2", vss-workfile, return-value ) ).
    return .
  end.
  if buf_ext-system.esys-status = integer( '-1':U )
  then do:
      run write-to-log in this-procedure  (
           input substitute( "Подготовка таблиц выгрузки внешней системы '&1'...", buf_ext-system.esys-name )
      ).
      run initial-export in this-procedure ( input buf_ext-system.esys-id
                                            ,input buf_Ext-system.db-num
                                            ,input buf_ext-system.esys-name) no-error.
      if error-status :error then do:
        run write-to-log (
             input substitute( "Ошибка при первоначальной выгрузке внешней системы '&1'...", buf_ext-system.esys-name )
        ).
        undo, return ''.
      end.
  end.
  find last buf_esys-route no-lock
    where buf_esys-route.esys-id = p-esys-id
      and buf_esys-route.db-num = p-db-num
      and buf_esys-route.esr-last-pack = -1
    no-error
  .
  v-last-tbl-ord = if available buf_esys-route then buf_esys-route.esr-tbl-ord else 0 .
  if mFrameView
  then do:
     view frame inf.
     do with frame inf
     :
        assign
        p-esys-id :screen-value   = string( p-esys-id, p-esys-id :format)
     .
     end.
  end.
      run ext-system-attr-exist (
                          input p-esys-id
                          ,input p-db-num
                          ,input 'need-gen-new-xpack':U
                          ,output db-esys-attr-exist
                        ) no-error.
      if error-status :error then do:
        run write-to-log( substitute("&1. Ошибка при определении наличия атрибута формирования нового пакета для ВС &2"
                                    ,vss-workfile
                                    ,p-esys-id
                                    )
                        ) .
        undo, return error.
      end.
      run ext-system-attr-value (
                          input p-esys-id
                          ,input p-db-num
                          ,input 'need-gen-new-xpack':U
                          ,output db-esys-attr-value
                          ,output db-esys-attr-type
                        ) no-error.
      if error-status :error then do:
        run write-to-log( substitute("&1. Ошибка при чтении атрибута формирования нового пакета для ВС &2"
                                    ,vss-workfile
                                    ,p-esys-id
                                    )
                        ) .
        undo, return error.
      end.
  gen-pack:
  do while p-err-gen-pack = 0
  on error undo, return error
  :
    find first buf_esys-route share-lock
      where buf_esys-route.esys-id = p-esys-id
        and buf_esys-route.db-num = p-db-num
        and buf_esys-route.esr-last-pack = -1
      no-wait
      no-error
    .
    if available buf_esys-route
    and (buf_esys-route.esr-action = 'command-bush':U
    or  buf_esys-route.esr-action = 'command-pbush':U)
    then do:
      esys-attr-value = "yes":U.
    end.
    else do:
      esys-attr-exist = db-esys-attr-exist .
      esys-attr-value = db-esys-attr-value .
    end.
    v-custom-pack-name = ''.
    if ( available buf_esys-route
         and buf_esys-route.esr-tbl-ord <= v-last-tbl-ord
       )
      or (esys-attr-exist = false and available buf_esys-route)
      or esys-attr-value = "yes":U
    then do:
      assign
        v-pack-num     = -1
        v-gen-new-xpack = true
      .
      if buf_ext-system.delivery-method = integer('1':U)
      or buf_ext-system.delivery-method = integer('3':U)
      or buf_ext-system.delivery-method = integer('5':U)
          or buf_ext-system.whole-send-news = integer('9':U)
      then do:
        find first buf_esys-all-attr share-lock where
                buf_esys-all-attr.attr-code = 'route-custom-pack-name':U
            and buf_esys-all-attr.table-name = 'esys-route':U
            and buf_esys-all-attr.key1 = buf_esys-route.esr-dump-ord
            and buf_esys-all-attr.key2 = buf_esys-route.esys-id
            and buf_esys-all-attr.key5 = buf_esys-route.db-num
             no-error.
        if available buf_esys-all-attr then do:
          v-custom-pack-name = buf_esys-all-attr.attr-value.
        end.
      end.
      run ext-system-attr-write (
                         input p-esys-id
                        ,input p-db-num
                        ,input 'need-gen-new-xpack':U
                        ,input "no":U
                        ) no-error.
      if error-status :error then do:
        run write-to-log( vss-workfile + chr(32)
                          + "Ошибка записи атрибута формирования нового пакета для ВС" + chr(32)
                          + string( p-esys-id )
                        ) .
        assign
          p-err-gen-pack = 2
        .
        undo, return error.
      end.
    end.
    else do:
      if v-gen-new-xpack = false then do:
        run write-to-log( substitute( "Нет новой информации для отправки в ВС &1", p-esys-id ) ) .
      end.
      leave gen-pack .
    end.
    run bge/espcknum.p // 28/X-2018 - v-source-dir и v-target-dir не используются;
                       // 12/VIII-2019 - v-temp-dir, v-log-file-name, v-list-file-name не используются
      ( input "put":U
       ,input p-esys-id
       ,input p-db-num
       ,input buf_ext-system.delivery-method
       ,input oxml-exch-dir
       ,input oxml-heap-dir
       ,input ""
       ,input-output v-pack-num
       ,input-output v-custom-pack-name
       ,output v-pack-name
       ,output v-source-dir
       ,output v-target-dir
       ,output v-temp-dir
       ,output v-log-file-name
       ,output v-list-file-name
       ,output v-custom-pack-flag
      ) no-error.
    if error-status:error then do:
      run write-to-log( vss-workfile + chr(32)
                        + "Ошибка при генерации номера пакета." + chr(10)
                        + substitute( "&1", error-status:get-message(error-status:num-messages) ) + chr(10)
                        + substitute( "&1", return-value )
                      ) .
      undo, return error.
    end.
    if v-fst-pck = ? then do:
      assign
        v-fst-pck = v-pack-num
      .
    end.
    else do:
      if v-pack-num = v-fst-pck + 30
      or (buf_ext-system.delivery-method = integer('11':U) and v-pack-num = v-fst-pck + 1)
      then do:
        assign
          p-cre-all-pck = false
        .
        leave gen-pack .
      end.
    end.
    if mFrameView
    then do with frame inf
    :
      assign
        p-esys-id :screen-value   = string( p-esys-id, p-esys-id :format)
        v-pack-num :screen-value = string( v-pack-num, v-pack-num :format)
      .
    end.
    run write-to-log( substitute("Подготовка пакета N &1 для ВС N &2", v-pack-num, p-esys-id ) ).
    find first buf_ext-system
      where buf_ext-system.esys-id = p-esys-id
        and buf_ext-system.db-num = p-db-num
      no-error
    .
    if not available buf_ext-system then do:
      run write-to-log( substitute( "&1. Подготовка пакета прервана. ВС &2 не найдена.", vss-workfile, p-esys-id ) ).
      assign
        p-err-gen-pack = 2
      .
      undo, return error.
    end.
    assign
    v-max-pack-size = 10000
    .
    run cur-time( output v-today
                 ,output v-time
                ) no-error .
    if error-status :error then do:
      run write-to-log( vss-workfile + chr(32) + "Ошибка при определении текущей даты!" ) .
      assign
        p-err-gen-pack = 2
      .
      undo, return error.
    end.
    find first buf_esys-pck-sent no-lock
      where buf_esys-pck-sent.esys-id   = p-esys-id
         and buf_esys-pck-sent.db-num   = p-db-num
        and buf_esys-pck-sent.esps-pack-num = v-pack-num
      no-error
    .
    if available buf_esys-pck-sent then do:
      run write-to-log( substitute( "&1. Пакет с номером &2 уже существует.", vss-workfile, v-pack-num ) ) .
      assign
        p-err-gen-pack = 2
      .
      undo, return error.
    end.
    do transaction
    on error  undo, return error substitute( "&1 (pck-sent). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1 (pck-sent). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (pck-sent). endkey", vss-workfile )
    :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
create buf_esys-pck-sent.
assign
buf_esys-pck-sent.esps-CreDate        = v-today
buf_esys-pck-sent.esps-CreTimeInt     = v-time
buf_esys-pck-sent.esps-CreTime        = string( v-time, "HH:MM:SS" )
buf_esys-pck-sent.esys-id             = p-esys-id
buf_esys-pck-sent.db-num              = p-db-num
buf_esys-pck-sent.esps-cr-db-num      = g#db-num
buf_esys-pck-sent.esps-pack-num       = v-pack-num
buf_esys-pck-sent.esps-rcvd           = no
buf_esys-pck-sent.esps-total-recs     = ?
buf_esys-pck-sent.esps-CreNum         = 0
buf_esys-pck-sent.esps-SendTxtDate    = ?
buf_esys-pck-sent.esps-SendTxtTimeInt = 0
buf_esys-pck-sent.esps-SendTxtTime    = "":U
buf_esys-pck-sent.esps-rcvdDate       = ?
buf_esys-pck-sent.esps-RcvdTimeInt    = 0
buf_esys-pck-sent.esps-RcvdTime       = "":U
buf_esys-pck-sent.esps-CRC-pack       = substitute( "&1 &2 &3 &4", today, time, etime, DBTASKID( "ub":U ) )
.
      buf_esys-pck-sent.custom-pack-name = v-custom-pack-name.
      if index(v-custom-pack-name,  "&pack-num") > 0 then do:
        buf_esys-pck-sent.custom-pack-name = replace(v-custom-pack-name, "&pack-num", string(v-pack-num)).
      end.
      if v-custom-pack-flag = no then do:
        assign buf_esys-pck-sent.custom-pack-name = buf_esys-pck-sent.custom-pack-name + "xml".
      end.
      assign
        route-cnt = 0
        rec-cnt   = 0
      .
      define variable v-uniq-gate-rec as character no-undo init ?.
      define variable v-action as character no-undo .
      v-uniq-gate-rec = ?.
      route-label:
      for each buf_esys-route no-lock
        where buf_esys-route.esys-id   = p-esys-id
          and buf_esys-route.db-num    = p-db-num
          and buf_esys-route.esr-last-pack = -1
        by buf_esys-route.esr-tbl-ord
      on error   undo, return error
      on end-key undo, return error
      :
        if buf_esys-route.esr-tbl-ord > v-last-tbl-ord then do:
          leave route-label.
        end.
        if v-uniq-gate-rec = ? then do:
          assign
          v-uniq-gate-rec = buf_esys-route.uniq-gate-rec.
          v-action = buf_esys-route.esr-action.
        end.
        if buf_esys-route.uniq-gate-rec <> v-uniq-gate-rec then do:
          leave route-label.
        end.
        if v-action <> buf_esys-route.esr-action then do:
          leave route-label.
        end.
        find ub.esys-route exclusive-lock
          where rowid( ub.esys-route ) = rowid( buf_esys-route )
          no-wait no-error
        .
        if not available ub.esys-route then do:
          if locked ub.esys-route then do:
            run write-to-log( vss-workfile + chr(32)
                              + substitute( "Подготовка пакета прервана на захваченной записи &1", buf_esys-route.esr-name-rec )
                            ).
            if v-sys-key = 'ExpertekIBS':U
            then do:
              run gbl/findlock.p
                (input  recid( buf_esys-route )
                ,output table temp-lock
                ) .
              for each temp-lock
              :
                run write-to-log( substitute( "Запись захватил пользователь &1", temp-lock.user-name )
                                  + chr(10) + substitute( "Номер подключения - &1":U, temp-lock.lock-conn-id )
                                  + chr(10) + substitute( "Флаги             - &1":U, temp-lock.lock-flag )
                                  + chr(10) + substitute( "Номер транзакции  - &1":U, temp-lock.trans-id )
                                  + chr(10) + substitute( "Тип подключения   - &1":U, temp-lock.connect-type )
                                  + chr(10) + substitute( "Устройство        - &1":U, temp-lock.connect-device )
                                ).
              end.
            end.
          end.
          else do:
            run write-to-log( vss-workfile + chr(32)
                              + substitute( "Подготовка пакета прервана на отсутствующей записи &1", buf_esys-route.esr-name-rec )
                            ).
          end.
          assign
            p-err-gen-pack = 1
          .
          leave route-label.
        end.
        if ub.esys-route.esr-num-dump = 0 then do:
          assign
            qnty-of-cur-rec = 1
          .
        end.
        else do:
          assign
            qnty-of-cur-rec = ub.esys-route.esr-num-dump
          .
        end.
        assign
          route-cnt = route-cnt + 1
          rec-cnt = rec-cnt + qnty-of-cur-rec
        .
        if rec-cnt <> qnty-of-cur-rec
          and rec-cnt > v-max-pack-size
        then do:
          leave route-label.
        end.
        if mFrameView
        then do with frame inf
        :
          assign
            p-esys-id :screen-value   = string( p-esys-id, p-esys-id :format)
            v-pack-num :screen-value = string( v-pack-num, v-pack-num :format)
            route-cnt :screen-value  = string( route-cnt, route-cnt :format)
            rec-cnt :screen-value  = string( rec-cnt - route-cnt, rec-cnt :format)
          .
        end.
        assign
          ub.esys-route.esr-last-pack = v-pack-num
        .
        if buf_esys-route.esr-action = 'command-bush':U
        and buf_ext-system.delivery-method <> integer('11':U)
        then do:
          leave route-label.
        end.
      end.
      find first ub.esys-pck-sent exclusive-lock
        where ub.esys-pck-sent.esys-id  = p-esys-id
          and ub.esys-pck-sent.db-num   = p-db-num
          and ub.esys-pck-sent.esps-pack-num = v-pack-num
        no-error
      .
      if not available ub.esys-pck-sent then do:
        run write-to-log( substitute( "&1. Отсутствует шапка пакета с номером &2!", vss-workfile, v-pack-num ) ) .
        assign
          p-err-gen-pack = 2
        .
        undo, return error.
      end.
      assign
        ub.esys-pck-sent.esps-total-recs = route-cnt
      .
    end.
  end.
  if mFrameView
  then do:
    hide frame inf.
  end.
end.
procedure initial-export :
define input  parameter p-esys-id as integer   no-undo .
define input  parameter p-db-num as integer   no-undo .
define input  parameter p-esys-name as character no-undo .
define buffer buf_esys-route for ub.esys-route.
define buffer buf_esys-route-dump for ub.esys-route-dump.
define buffer buf_BatchProcess       for ub.BatchProcess.
do
on error undo, return error return-value
:
  for each buf_esys-route exclusive-lock
      where buf_esys-route.esys-id        = p-esys-id
        and buf_esys-route.db-num         = p-db-num
  :
      for each buf_esys-route-dump exclusive-lock
          where buf_esys-route-dump.esrd-dump-ord = buf_esys-route.esr-dump-ord
      on error undo, return error
      :
          delete buf_esys-route-dump.
      end.
      delete buf_esys-route.
  end.
  run write-to-log (
        input substitute( "Подготовка таблиц выгрузки внешней системы '&1' завершена.", p-esys-name )
                                   ).
  find first buf_BatchProcess no-lock
    where buf_BatchProcess.bp_type   = 'oxmlnew':U
      and buf_BatchProcess.bp_status = 'N':U
      and  buf_BatchProcess.key#_one  = p-esys-id
      and buf_BatchProcess.key#_two = p-db-num
  no-error .
  if available buf_BatchProcess
  then do:
      run bge/oxmlinit.p (
            input this-procedure
          , input p-esys-id
          , input p-db-num
      ).
      do transaction
      on error undo, return error
      :
  find first buf_BatchProcess exclusive-lock
    where buf_BatchProcess.bp_type   = 'oxmlnew':U
      and buf_BatchProcess.bp_status = 'N':U
      and  buf_BatchProcess.key#_one  = p-esys-id
      and buf_BatchProcess.key#_two = p-db-num
  no-error .
          delete buf_BatchProcess.
      end.
  end.
end.
end procedure.
