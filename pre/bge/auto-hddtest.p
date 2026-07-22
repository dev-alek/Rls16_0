block-level on error undo, throw.
using Progress.Lang.*.
define input  parameter p-user-login    as character no-undo .
define input  parameter p-user-password as character no-undo .
define input  parameter p-db-num        as integer no-undo .
def var vss-revision    as character no-undo init "$Revision: 5c1b000f89f8, 2349, rls $":U .
def var vss-author      as character no-undo init "$Author: SSlivenko $":U .
def var vss-date        as character no-undo init "$Date: Ср июн 10 21:13:33 2020 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: auto-hddtest.p $":U .
def var vss-archive     as character no-undo init "$Archive: bge/auto-hddtest.p $":U .
def var vss-description as character no-undo init "Работа с ФГИС меркурий".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define temp-table HddTest no-undo
  field db-num      as integer
  field id          as int64
  field namepc      as character
  field hddModule   as character
  field testStatus  as character
  field hddFilling  as character
  field hddSysFilling  as character
  field hddName     as character
  field hddSerial   as character
  field sysInfo     as character
  field dt          as datetime-tz
  index i1 as unique
    hddSerial hddModule dt
.
define temp-table hddAttributes no-undo
  field name_       as character
  field value_      as integer
  field thresh      as integer
  field type_       as character
  field raw_value   as character
  field hddModule   as character
  field hddSerial   as character
  field dt          as datetime-tz
  index i1 as unique
    hddSerial hddModule name_ dt
.
function my-date returns datetime-tz (input v-str as character) forward .
define buffer buf_hddAttributes for hddAttributes .
define variable v-ind                    as integer   no-undo .
define variable v-err-gen-pack           as integer   no-undo .
define variable v-err-code               as integer   no-undo .
define variable v-step-num               as integer   no-undo .
define variable v-action                 as character no-undo .
define variable v-message                as character no-undo .
define variable v-proc-handle            as handle    no-undo .
define variable v-main-proc-name         as character no-undo .
define variable log-exit          as logical    no-undo .
define variable curl-path         as character  no-undo .
define variable v-post-file-name  as character  no-undo .
define variable v-response-file-name  as character  no-undo .
define variable v-cmd-file-name   as character  no-undo .
define variable v-command         as character  no-undo .
define variable v-out-str         as character  no-undo .
define variable v-pid-list        as character  no-undo .
define variable v-time-str        as character  no-undo .
define variable v-del-file        as character  no-undo .
define variable v-count-main-prc         as integer   no-undo .
define variable v-pers-proc-name         as character no-undo .
define variable v-part-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define buffer buf_code for ub.Code .
define buffer buf_devisPC for ub.devisPC .
define buffer buf_devisPC-attr for ub.devisPC-attr .
define variable v-start-DT as datetime no-undo initial 1/1/1970 .
define variable v-test-DT as datetime no-undo .
define variable v-epoch-time as integer no-undo .
define variable v-str-dt as character no-undo .
define variable v-tms as integer no-undo .
define variable hDoc              as handle     no-undo .
define variable hRoot             as handle     no-undo .
define variable good              as logical    no-undo .
define variable ii as integer no-undo.
do
on error undo, return error
:
  if transaction then do:
    message
      substitute( "&1. Вызов данной процедуры невозможен при наличии транзакции", vss-workfile )
      view-as alert-box error .
    return error .
  end.
  if valid-handle( session :first-procedure ) then do:
    assign
      v-main-proc-name = "gbl/mainproc.p":U
      v-proc-handle    = session :first-procedure
      v-count-main-prc = 0
      v-pers-proc-name = "":U
    .
    do while valid-handle( v-proc-handle )
    :
      if v-proc-handle :file-name = v-main-proc-name then do:
        assign
          v-count-main-prc = v-count-main-prc + 1
        .
      end.
      else do:
        assign
          v-pers-proc-name = v-pers-proc-name + chr(44) + v-proc-handle :file-name
        .
      end.
      assign
        v-proc-handle = v-proc-handle:next-sibling no-error
      .
    end.
    if v-count-main-prc > 1
      or v-pers-proc-name <> "":U
    then do:
      message
        substitute( "&1. Вызов данной процедуры невозможен при наличии определений persistent prosedures &2"
                    + "Список недопустимых процедур: &3&2"
                    + "Исключение - единственная процедура &4&2"
                    + "Определений данной процедуры &5&2"
                    , vss-workfile
                    , chr(10)
                    , v-pers-proc-name
                    , v-main-proc-name
                    , v-count-main-prc
                   )
        view-as alert-box error .
      return error .
    end.
  end.
  assign
    g#auto                = true
  .
  run gbl/set-gbl.p
    (input true
    ,input p-user-login
    ,input p-user-password
    ) no-error.
  if error-status :error
  then do:
    run write-to-log( substitute("&1. Ошибка при инициализации переменных g#... &2&3&4"
                                  ,vss-workfile
                                  ,error-status:get-message(error-status:num-messages)
                                  ,chr(10)
                                  ,return-value
                                )
                    ) .
    return error.
  end.
  assign
    g#auto = true
  .
  assign
  curl-path = search("exe/curl.exe")
  .
  v-response-file-name = "hdd-test-result.xml" .
  run write-to-log( "Работа с БД " + string(p-db-num) ) .
  for each buf_code no-lock where buf_code.parent = "SpravDevice"
                              and buf_code.status_ = 0 :
    if trim(buf_code.misc1) = ""
    then do :
      run write-to-log( "Для устройства " + string(buf_code.code) + " " + string(buf_code.CodeName) + " не указан IP" ) .
      next.
    end.
    v-tms = interval( now, v-start-DT , "seconds" ) .
    v-tms = v-tms - 604800 - (timezone * 60) .
    find last buf_devisPC no-lock where buf_devisPC.db-num = p-db-num
                                    and buf_devisPC.namepc = buf_code.CodeName
                                    no-error.
    if available buf_devisPC
    then do :
      find last buf_devisPC-attr exclusive-lock where buf_devisPC-attr.db-num = buf_devisPC.DB-num
                                                  and buf_devisPC-attr.id = buf_devisPC.id
                                                  no-error.
      if available buf_devisPC-attr
      then do :
        v-test-DT = dateTime(buf_devisPC-attr.date, (buf_devisPC-attr.time_ * 1000)) .
        v-tms = interval( v-test-DT, v-start-DT , "seconds" ) .
        v-tms = v-tms - 10000 - (timezone * 60) .
      end.
    end.
    v-post-file-name = "hdd-test-req.xml" .
    v-out-str = substitute ("<?xml version='1.0' encoding='windows-1251'?><data type='dsw'><HddTest ctrl='READ' tms = '&1'></HddTest><Count>500</Count></data>", string(v-tms)) .
    output to value (v-post-file-name) .
    put unformatted v-out-str skip .
    output close .
    v-command = substitute('&1 -0 --connect-timeout 5 -X POST -H "Content-Type: text/xml" -d @"&2" &3 >&4'
                            , curl-path
                            , v-post-file-name
                            , buf_code.misc1
                            , v-response-file-name) .
    os-command silent value (v-command) .
    file-info:file-name = v-response-file-name .
    if file-info:file-size = 0
    then do :
      run write-to-log( "Пустой ответ от устройства " + string(buf_code.CodeName) + ". IP: " +  trim(buf_code.misc1)) .
      next.
    end.
    empty temp-table HddTest .
    empty temp-table hddAttributes .
    run parse-xml (input v-response-file-name) no-error.
    if error-status:error
    then do :
      run write-to-log( "Не могу разобрать ответ от устройства " + string(buf_code.CodeName) + ". IP: " +  trim(buf_code.misc1)) .
      next.
    end.
    for each HddTest no-lock break by HddTest.dt :
      find first buf_devisPC no-lock where buf_devisPC.modeldevice = trim(HddTest.hddModule)
                                       and buf_devisPC.SerialNumber = trim(HddTest.hddSerial)
                                       and buf_devisPC.ModelPC = trim(HddTest.sysInfo)
                                       and buf_devisPC.DB-num = p-db-num
                                       no-error .
      if not available buf_devisPC
      then do :
        create buf_devisPC .
        assign
          buf_devisPC.id = next-value(s-devisPC-id)
          buf_devisPC.DB-num = p-db-num
          buf_devisPC.ModelPC = trim(HddTest.sysInfo)
          buf_devisPC.namepc = buf_code.CodeName
          buf_devisPC.modeldevice = trim(HddTest.hddModule)
          buf_devisPC.SerialNumber = trim(HddTest.hddSerial)
        .
      end.
      find last buf_devisPC-attr exclusive-lock where buf_devisPC-attr.db-num = buf_devisPC.DB-num
                                                  and buf_devisPC-attr.id = buf_devisPC.id
                                                  and buf_devisPC-attr.attr-code = "ProcDisk"
                                                  and buf_devisPC-attr.date = date(HddTest.dt)
                                                  and buf_devisPC-attr.time_ = integer( truncate( MTIME( HddTest.dt ) / 1000, 0 ) )
                                                  no-error.
      if not available buf_devisPC-attr
      then do :
        create buf_devisPC-attr .
        assign
          buf_devisPC-attr.db-num = buf_devisPC.DB-num
          buf_devisPC-attr.id = buf_devisPC.id
          buf_devisPC-attr.attr-code = "ProcDisk"
          buf_devisPC-attr.date = date(HddTest.dt)
          buf_devisPC-attr.time_ = integer( truncate( MTIME( HddTest.dt ) / 1000, 0 ) )
        .
      end.
      assign buf_devisPC-attr.attr-value = string(HddTest.hddFilling) .
      find last buf_devisPC-attr exclusive-lock where buf_devisPC-attr.db-num = buf_devisPC.DB-num
                                                  and buf_devisPC-attr.id = buf_devisPC.id
                                                  and buf_devisPC-attr.attr-code = "UserProc"
                                                  and buf_devisPC-attr.date = date(HddTest.dt)
                                                  and buf_devisPC-attr.time_ = integer( truncate( MTIME( HddTest.dt ) / 1000, 0 ) )
                                                  no-error.
      if not available buf_devisPC-attr
      then do :
        create buf_devisPC-attr .
        assign
          buf_devisPC-attr.db-num = buf_devisPC.DB-num
          buf_devisPC-attr.id = buf_devisPC.id
          buf_devisPC-attr.attr-code = "UserProc"
          buf_devisPC-attr.date = date(HddTest.dt)
          buf_devisPC-attr.time_ = integer( truncate( MTIME( HddTest.dt ) / 1000, 0 ) )
        .
      end.
      assign buf_devisPC-attr.attr-value = string(HddTest.hddSysFilling) .
      find last buf_devisPC-attr exclusive-lock where buf_devisPC-attr.db-num = buf_devisPC.DB-num
                                                  and buf_devisPC-attr.id = buf_devisPC.id
                                                  and buf_devisPC-attr.attr-code = "testStatus"
                                                  and buf_devisPC-attr.date = date(HddTest.dt)
                                                  and buf_devisPC-attr.time_ = integer( truncate( MTIME( HddTest.dt ) / 1000, 0 ) )
                                                  no-error.
      if not available buf_devisPC-attr
      then do :
        create buf_devisPC-attr .
        assign
          buf_devisPC-attr.db-num = buf_devisPC.DB-num
          buf_devisPC-attr.id = buf_devisPC.id
          buf_devisPC-attr.attr-code = "testStatus"
          buf_devisPC-attr.date = date(HddTest.dt)
          buf_devisPC-attr.time_ = integer( truncate( MTIME( HddTest.dt ) / 1000, 0 ) )
        .
      end.
      assign buf_devisPC-attr.attr-value = HddTest.testStatus .
      for each hddAttributes no-lock where hddAttributes.hddModule   = HddTest.hddModule
                                       and hddAttributes.hddSerial   = HddTest.hddSerial
                                       and hddAttributes.dt          = HddTest.dt :
        find last buf_devisPC-attr exclusive-lock where buf_devisPC-attr.db-num = buf_devisPC.DB-num
                                                    and buf_devisPC-attr.id = buf_devisPC.id
                                                    and buf_devisPC-attr.attr-code = hddAttributes.name_
                                                    and buf_devisPC-attr.date = date(hddAttributes.dt)
                                                    and buf_devisPC-attr.time_ = integer( truncate( MTIME( hddAttributes.dt ) / 1000, 0 ) )
                                                    no-error.
        if not available buf_devisPC-attr
        then do :
          create buf_devisPC-attr .
          assign
            buf_devisPC-attr.db-num = buf_devisPC.DB-num
            buf_devisPC-attr.id = buf_devisPC.id
            buf_devisPC-attr.attr-code = hddAttributes.name_
            buf_devisPC-attr.date = date(hddAttributes.dt)
            buf_devisPC-attr.time_ = integer( truncate( MTIME( hddAttributes.dt ) / 1000, 0 ) )
          .
        end.
        assign
          buf_devisPC-attr.attr-value = string(hddAttributes.value_)
          buf_devisPC-attr.attr-Raw-value = string(hddAttributes.raw_value)
          buf_devisPC-attr.tresh = string(hddAttributes.thresh)
          buf_devisPC-attr.type = hddAttributes.type_
        .
      end.
    end.
  end.
  run write-to-log( "Закончена работа с БД " + string(p-db-num) ) .
end.
procedure parse-xml :
  define input parameter p-file as character .
  CREATE X-DOCUMENT hDoc.
  CREATE X-NODEREF hRoot.
  hDoc:LOAD("file",p-file,FALSE) no-error.
  if error-status:error
  then do :
    DELETE OBJECT hDoc no-error.
    DELETE OBJECT hRoot no-error.
    return error .
  end .
  hDoc:GET-DOCUMENT-ELEMENT(hRoot) no-error.
  if error-status:error
  then do :
    DELETE OBJECT hDoc no-error.
    DELETE OBJECT hRoot no-error.
    return error .
  end .
  RUN GetChildren(hRoot, 1) no-error.
  if error-status:error
  then do :
    DELETE OBJECT hDoc no-error.
    DELETE OBJECT hRoot no-error.
    return error .
  end .
  DELETE OBJECT hDoc.
  DELETE OBJECT hRoot.
end procedure .
PROCEDURE GetChildren:
DEFINE INPUT PARAMETER hParent AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER level AS INTEGER NO-UNDO.
DEFINE VARIABLE i AS INTEGER NO-UNDO.
DEFINE VARIABLE hNoderef AS HANDLE NO-UNDO.
DEFINE VARIABLE hText AS HANDLE NO-UNDO.
define variable client as character no-undo.
CREATE X-NODEREF hNoderef.
CREATE X-NODEREF hText .
i = hParent:num-children no-error .
if error-status:error
or i = ?
then do :
  DELETE OBJECT hNoderef no-error .
  DELETE OBJECT hText no-error .
  return error .
end .
REPEAT i = 1 TO hParent:NUM-CHILDREN:
    good = hParent:GET-CHILD(hNoderef,i).
    IF NOT good THEN
        LEAVE.
    IF hNoderef:SUBTYPE <> "element" THEN
        NEXT.
    hNoderef:GET-CHILD(hText, 1) no-error .
    IF hNoderef:NAME = "HddTest"
    then do :
      create HddTest .
      assign v-str-dt = hNoderef:get-attribute("tstamp") .
      integer(v-str-dt) no-error .
      if error-status:error
      then do :
        assign HddTest.dt = my-date(v-str-dt).
      end.
      else do :
        assign v-epoch-time = integer(v-str-dt) .
        assign HddTest.dt = ADD-INTERVAL(v-start-DT, v-epoch-time, "SECONDS").
      end.
    end.
    IF hNoderef:NAME = "hddModule" then assign HddTest.hddModule = hText:node-value no-error .
    IF hNoderef:NAME = "testStatus"then assign HddTest.testStatus = hText:node-value no-error .
    IF hNoderef:NAME = "hddFilling" then assign HddTest.hddFilling = hText:node-value no-error .
    IF hNoderef:NAME = "hddSysFilling" then assign HddTest.hddSysFilling = hText:node-value no-error .
    IF hNoderef:NAME = "systemInfo" then assign HddTest.sysInfo = hText:node-value no-error .
    IF hNoderef:NAME = "hddName" then assign HddTest.hddName = hText:node-value no-error .
    IF hNoderef:NAME = "hddSerial"
    then do :
      assign HddTest.hddSerial = hText:node-value no-error .
    end.
    IF hNoderef:NAME = "hddAttributes"
    then do :
      create hddAttributes .
      assign
        hddAttributes.hddModule   = HddTest.hddModule
        hddAttributes.hddSerial   = HddTest.hddSerial
        hddAttributes.dt          = HddTest.dt
      .
    end.
    IF hNoderef:NAME = "name"
    then do :
      find first buf_hddAttributes where buf_hddAttributes.hddModule = hddAttributes.hddModule
                                     and buf_hddAttributes.hddSerial = hddAttributes.hddSerial
                                     and buf_hddAttributes.dt        = hddAttributes.dt
                                     and buf_hddAttributes.name_     = hText:node-value
                                     no-error .
      if available buf_hddAttributes
      then do :
        delete buf_hddAttributes .
      end.
      assign hddAttributes.name_ = hText:node-value no-error .
    end.
    IF hNoderef:NAME = "value" then assign hddAttributes.value_ = integer(hText:node-value) no-error .
    IF hNoderef:NAME = "thresh" then assign hddAttributes.thresh = integer(hText:node-value) no-error .
    IF hNoderef:NAME = "type" then assign hddAttributes.type_ = hText:node-value no-error .
    IF hNoderef:NAME = "raw_value" then assign hddAttributes.raw_value = hText:node-value no-error .
    RUN GetChildren(hNoderef, (level + 1)).
END.
DELETE OBJECT hNoderef.
DELETE OBJECT hText.
END PROCEDURE.
function my-date returns datetime-tz (input v-str as character) :
  define variable v-year    as integer no-undo .
  define variable v-month   as integer no-undo .
  define variable v-day     as integer no-undo .
  define variable v-hour    as integer no-undo .
  define variable v-min     as integer no-undo .
  define variable v-sec     as integer no-undo .
  define variable v-tz-hour as integer no-undo .
  define variable v-tz-min  as integer no-undo .
  define variable v-sign    as character no-undo .
  define variable v-time-delta as integer no-undo .
  define variable v-dttz    as datetime-tz no-undo .
  assign
    v-year    = integer(substring(v-str, 1, 4))
    v-month   = integer(substring(v-str, 6, 2))
    v-day     = integer(substring(v-str, 9, 2))
    v-hour    = integer(substring(v-str, 12, 2))
    v-min     = integer(substring(v-str, 15, 2))
    v-sec     = integer(substring(v-str, 18, 2))
    v-tz-hour = integer(substring(v-str, 21, 2))
    v-tz-min  = integer(substring(v-str, 23, 2))
    v-sign    = substring(v-str, 20, 1)
    v-time-delta = (v-tz-hour) * 60 + v-tz-min
  .
  if v-sign = "-" then v-time-delta = v-time-delta * -1 .
  v-dttz = datetime-tz(v-month, v-day, v-year, v-hour, v-min, v-sec, 0, v-time-delta) .
  return v-dttz .
end function.
