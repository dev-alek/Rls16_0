block-level on error undo, throw.
define input parameter p-esys-id      like ub.ext-system.esys-id         no-undo .
define input parameter p-db-num       like ub.ext-system.db-num          no-undo .
define variable vss-revision    as character no-undo init "$Revision: f0ffd58b8bac, 1562, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Tue Nov 06 04:41:34 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rem-xpck.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/rem-xpck.p $":U .
define variable vss-description as character no-undo init "Удаление пакетов OXML по указанной ВС".
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
do
on error undo, return error
:
  define stream dir-stream .
  define buffer buf_ext-system       for ub.ext-system .
  define buffer buf_esys-pck-sent for ub.esys-pck-sent.
  define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd .
  define buffer buf_esys-all-attr for ub.esys-all-attr.
  define variable v-pck-for-esys  as integer   no-undo .
  define variable v-add-to-list  as logical   no-undo .
  define variable v-list-action  as character no-undo .
  define variable v-action       as character no-undo .
  define variable v-dir-name     as character no-undo .
  define variable v-pack-num     as integer   no-undo .
  define variable v-pack-name    as character no-undo .
  define variable v-custom-pack-name as character no-undo .
  define variable v-source-dir   as character no-undo .
  define variable v-target-dir   as character no-undo .
  define variable v-temp-dir     as character no-undo .
  define variable v-ind          as integer   no-undo .
  define variable v-type         as character no-undo .
  define variable v-filename     as character no-undo .
  define variable v-fullfilename as character no-undo .
  define variable v-log-file-name as character no-undo .
  define variable v-list-file-name as character no-undo .
  define variable v-custom-pack-flag as logical no-undo .
  define variable v-file-cnt     as integer   no-undo .
  define variable v-count-del      as integer   no-undo .
  define variable v-count-need-del as integer   no-undo .
  define variable v-today        as date      no-undo .
  define variable v-time         as integer   no-undo .
  define variable v-success      as logical no-undo .
  find first buf_ext-system no-lock
    where buf_ext-system.esys-id = p-esys-id
      and buf_ext-system.db-num = p-db-num
    no-error
  .
  if not available buf_ext-system then do:
    run write-to-log( substitute( "&1. ВС &2 не найдена", vss-workfile, p-esys-id ) ) .
    return error.
  end.
  if buf_ext-system.delete-pck-on = 0 then do:
    return .
  end.
  assign
  v-pck-for-esys = buf_ext-system.esys-id
  .
  if buf_ext-system.save-days-pck-num < 20 then do:
    return.
  end.
  run write-to-log( substitute("Анализ необходимости удаления файлов OXML по ВС &1", v-pck-for-esys ) ) .
  v-success = no.
  run bge/lockesys.p (
    input buf_ext-system.esys-id
    ,input buf_ext-system.db-num
    ,buffer buf_ext-system
    ,output v-success
  ) no-error.
  if error-status:error
  or not v-success
  then do:
    run write-to-log( substitute( "&1. &2", vss-workfile, return-value ) ).
    return .
  end.
  run cur-time in this-procedure
    ( output v-today
     ,output v-time
    ) no-error .
  if error-status :error then do:
    run write-to-log( substitute( "&1. Ошибка при определении текущего времени. &2&3&2&4", vss-workfile, chr(10), error-status :get-message(1) , return-value )
                    ) .
    return error.
  end.
  assign
    v-list-action    = "put,get":U
    v-count-del      = 0
    v-count-need-del = 0
    v-file-cnt       = 0
  .
  do v-ind = 1 to 2
  :
    assign
      v-action   = entry( v-ind, v-list-action )
      v-pack-num = ?
    .
    run bge/espcknum.p
      ( input v-action
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
      run write-to-log( substitute( "&1. Ошибка при генерации номера пакета. &2&3&2&4", vss-workfile, chr(10), error-status:get-message(1), return-value ) ) .
    end.
    if v-action = "put":U  then do:
      assign
        v-dir-name = v-source-dir
      .
    end.
    else do:
      assign
        v-dir-name = v-target-dir
      .
    end.
    assign
      file-info :file-name = v-dir-name
    .
    if file-info :full-pathname = ""
    or file-info :full-pathname = ?  then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Каталог: &1 ('heap') не найден !!!", v-dir-name ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
      undo, return error .
    end.
    assign
      v-dir-name = file-info :full-pathname
    .
    input stream dir-stream from os-dir ( v-dir-name )  no-attr-list no-echo  .
    _repeat:
    repeat:
      import stream dir-stream v-filename v-fullfilename .
      assign
      file-info :file-name = v-fullfilename
      .
      if caps( file-info :file-type ) begins "F":U
        and num-entries( v-filename, "." ) > 1
      then do:
        assign
        v-file-cnt = v-file-cnt + 1
        .
        if file-info :file-mod-date + buf_ext-system.save-days-pck-num < v-today then do:
          if length(v-filename) = 14
          and substring(v-filename, 1, 1) = 'o'
          and substring(v-filename, 11, 4) = '.xml'
          and trim(substring(v-filename, 2, 9), '0123456789') = '' then do:
            assign
              v-pack-num    = integer( substring( v-filename, 2, r-index(v-filename, '.':U) - 1 ) )
              v-add-to-list = true
            .
          end.
          else do:
            find first buf_esys-all-attr no-lock where
                    buf_esys-all-attr.attr-code = 'custom-pack-name':U
                and buf_esys-all-attr.table-name = (if v-ind = 1 then 'esys-pck-sent':U else 'esys-pck-rcvd':U)
                and buf_esys-all-attr.key2 = p-esys-id
                and buf_esys-all-attr.attr-value  = v-filename
                and buf_esys-all-attr.key5 =  p-db-num no-error.
            if not available buf_esys-all-attr then next _repeat.
            assign
              v-pack-num    = buf_esys-all-attr.key1
              v-add-to-list = true
            .
          end.
          case v-action :
            when "put":U then do:
              find first buf_esys-pck-sent no-lock
                where buf_esys-pck-sent.esys-id  = v-pck-for-esys
                  and buf_esys-pck-sent.db-num   = p-db-num
                  and buf_esys-pck-sent.esps-pack-num = v-pack-num
                  and buf_esys-pck-sent.esps-cr-db-num = g#db-num
                no-error .
              if not available buf_esys-pck-sent
                or buf_esys-pck-sent.esps-rcvd <> true
              then do:
                assign
                  v-add-to-list = false
                .
              end.
            end.
            when "get":U then do:
              find first buf_esys-pck-rcvd no-lock
                where buf_esys-pck-rcvd.esys-id   = v-pck-for-esys
                  and buf_esys-pck-rcvd.db-num   = p-db-num
                  and buf_esys-pck-rcvd.espr-pack-num = v-pack-num
                  and buf_esys-pck-rcvd.espr-cr-db-num = g#db-num
                no-error .
              if not available buf_esys-pck-rcvd then do:
                assign
                  v-add-to-list = false
                .
              end.
            end.
          end case.
          if v-add-to-list = true then do:
            if v-count-need-del = 0 then do:
              run write-to-log( substitute("Удаление файлов OXML по ВС &1", v-pck-for-esys ) ) .
            end.
            assign
              v-count-need-del = v-count-need-del + 1
            .
            run gbl/del-file.p
              ( input file-info :full-pathname
              ) no-error .
            if error-status:error then do:
              run write-to-log( substitute( "&1. Ошибка при удалении пакета. &2&3&2&4", vss-workfile, chr(10), error-status:get-message(1), return-value )
                              ) .
            end.
            else do:
              assign
                v-count-del = v-count-del + 1
              .
            end.
          end.
        end.
      end.
    end.
    input stream dir-stream close.
  end.
  if v-count-need-del > 0 then do:
    run write-to-log( substitute("Анализ пакетов по ВС &1 завершен. Просмотрено &2 файлов. Удалено &3 из &4 старых пакетов."
                                 , v-pck-for-esys
                                 , v-file-cnt
                                 , v-count-del
                                 , v-count-need-del
                                   ) ) .
  end.
  else do:
    run write-to-log( substitute("Анализ пакетов по ВС &1 завершен. Просмотрено &2 файлов. Старых файлов не обнаружено."
                                 , v-pck-for-esys
                                 , v-file-cnt
                                   ) ) .
  end.
end.
