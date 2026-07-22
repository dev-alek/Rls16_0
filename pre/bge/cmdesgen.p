block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-esys-id as integer   no-undo .
define input parameter p-db-num as integer   no-undo .
define input parameter p-db-num-exp as integer no-undo .
define input parameter p-cr-db-num as integer   no-undo .
define input parameter p-esr-dump-ord as int64 no-undo .
define input parameter p-gate-rec as character no-undo .
define input parameter p-xml-file-name as character no-undo .
define input parameter p-xml-file-number as integer no-undo .
define input parameter p-pack-num as integer no-undo .
define output parameter p-num-rec as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Укладка данных, маршрутизированных во ВС в файл".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info6 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info6, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info6, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info6, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info6, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info6 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info6, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info6 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info6, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info6, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info6, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info6, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info6, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info6, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info6 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info6 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info6, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info6, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info6, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info6 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info6 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info6, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info6, v-inform, v-tbl-name ).
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
                                                        ,vss-include-info4
                                                        ,p-gate-rec).
find first buf_clob-data no-lock where
          rowid(buf_clob-data) = v-tbl-row no-error.
if not available buf_clob-data then do:
  if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                          ,vss-include-info4
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info4 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info4 )
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info4 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info4 )
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info4 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info4 )
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info4 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info4 )
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table THpck-sent no-undo
field THfilename as character field THcrc-pack as character field THcredate as date field THcrenum as integer  field THcretimeint as integer field THcretime as character   field THrcvddate  as date field THpack-num  as integer  field THrcvdtimeint as integer field THrcvdtime  as character   field THrcvd  as logical      field THsendtxtdate as date field THsendtxttimeint as integer field THsendtxttime as character  field THtotal-recs  as integer  field THesys-id  as integer     index pi is unique primary THesys-id                  THpack-num                 index ircvd                THesys-id                  THrcvd
.
define temp-table THcurr-pack no-undo
field THfilename as character field THcrc-pack as character field THcredate as date field THcrenum as integer  field THcretimeint as integer field THcretime as character   field THrcvddate  as date field THpack-num  as integer  field THrcvdtimeint as integer field THrcvdtime  as character   field THrcvd  as logical      field THsendtxtdate as date field THsendtxttimeint as integer field THsendtxttime as character  field THtotal-recs  as integer  field THesys-id  as integer     index pi is unique primary THesys-id                  THpack-num                 index ircvd                THesys-id                  THrcvd
.
define temp-table THpck-rcvd no-undo
field THfilename as character
field THesys-id  as integer
field THcrc-pack as character
field THpack-num  as integer
field THrcvd-recs  as integer
field THrcvd as logical
field THtotal-recs  as integer
field THrcvddate  as date
field THrcvdtimeint as integer
field THrcvdtime  as character
index pi is unique primary
THesys-id
THpack-num
index rcvd
THesys-id
THrcvd
.
procedure get-header-by-rec :
define input  parameter p-gate-rec as character no-undo .
define output parameter p-tth as handle no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info7, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info7 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info7 )
:
  run gen-row-keyr in  this-procedure  (
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
    create temp-table p-tth .
    glog = p-tth:READ-XMLSCHEMA( "LONGCHAR"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    v-longchar = '':U.
    define variable v-esm as character no-undo .
    v-esm = error-status:get-message(1).
    if error-status :error
    or not glog
    then do:
      delete object p-tth no-error.
      undo, return error substitute("Не удалось прочитать XML-схему &1 (&2) из БД&3&4"
                                 , p-gate-rec
                                 , buf_clob-data.file-name_
                                 , chr(10)
                                 , v-esm
                                  ).
    end.
end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fillxpck :
define parameter buffer buf_esys-route for ub.esys-route.
define output parameter p-dataseth as handle no-undo .
define input-output parameter p-xmlh as handle no-undo .
define output parameter p-num-rec as integer no-undo .
define variable bh_route-dump as handle no-undo .
define variable tt-name as character no-undo .
define variable v-ok as logical no-undo .
define variable v-route-order-field as character no-undo .
define variable v-dump-order-field as character no-undo .
define variable v-esys-id as integer no-undo .
define variable v-db-num as integer no-undo .
define variable v-cr-db-num as integer no-undo .
define variable v-esr-dump-ord as int64 no-undo .
define variable v-esr-tbl-ord as int64 no-undo .
define variable v-pack-num as integer no-undo .
define buffer buf_esys-route-dump for ub.esys-route-dump.
define buffer buf_temp-xml-tables for temp-xml-tables.
  main-block:
  do
  on error undo, return error
  :
    define variable v-longchar as longchar no-undo .
    v-longchar = ?.
    run get-gate-by-rec in this-procedure ( input buf_esys-route.uniq-gate-rec
                                            ,output p-dataseth
                                            ,input-output p-xmlh
                                            ,input-output v-longchar
                                            ) no-error.
    if error-status:error then do:
        undo main-block, return error substitute("Ошибка при создании структуры маршрутизируемых данных согласно гейту:&1&2"
                            , buf_esys-route.uniq-gate-rec
                            , chr(10)
                            , error-status:get-message(1) ).
    end.
    run all-gates-empty in this-procedure no-error.
    assign
    v-esys-id = buf_esys-route.esys-id
    v-db-num = buf_esys-route.db-num
    v-cr-db-num = buf_esys-route.esr-cr-db-num
    v-esr-dump-ord = buf_esys-route.esr-dump-ord
    v-esr-tbl-ord = buf_esys-route.esr-tbl-ord
    v-pack-num = buf_esys-route.esr-last-pack
    .
    _fill:
    do while true:
      assign
      v-route-order-field = ''
      v-dump-order-field = ''
      .
    for each buf_esys-route-dump where
          buf_esys-route-dump.esrd-dump-ord   = v-esr-dump-ord
    by buf_esys-route-dump.esrd-rec-ord
    by buf_esys-route-dump.esrd-cr-db-num
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      bh_route-dump = (buffer buf_esys-route-dump:handle).
      if buf_esys-route-dump.uniq-gate-rec <> '':u then do:
        find first buf_temp-xml-tables where
                  buf_temp-xml-tables.tbl-name = buf_esys-route-dump.esrd-dump-name
              and buf_temp-xml-tables.uniq-gate-rec = buf_esys-route-dump.uniq-gate-rec no-error.
        if not available buf_temp-xml-tables then do:
          run gate-clear in this-procedure ( input p-dataseth, input p-xmlh).
          undo main-block, return error substitute( "&1. Не найдена таблица &2 в гейте &3 (1).&4&5"
                                    , vss-workfile
                                    , buf_esys-route-dump.esrd-dump-name
                                    , buf_esys-route-dump.uniq-gate-rec
                                    , chr(10)
                                    , error-status:get-message(1) ).
        end.
        if buf_temp-xml-tables.is-parent
        and not (buf_esys-route-dump.esrd-action begins "_hidden="
                  or buf_esys-route-dump.esrd-action begins "_route-order="
                  or buf_esys-route-dump.esrd-action begins "_dump-order="
                  )
        then do:
          p-num-rec = p-num-rec + 1.
        end.
      end.
      else do:
        find first buf_temp-xml-tables where
                  buf_temp-xml-tables.tbl-name = buf_esys-route-dump.esrd-dump-name
              and buf_temp-xml-tables.uniq-gate-rec = '':U no-error.
        if not available buf_temp-xml-tables then do:
          create buf_temp-xml-tables.
          assign
          buf_temp-xml-tables.tbl-name = buf_esys-route-dump.esrd-dump-name
          buf_temp-xml-tables.tbl-handle_ = ?
          buf_temp-xml-tables.table-handle_ = ?
          buf_temp-xml-tables.gate-handle_ = ?
          buf_temp-xml-tables.uniq-gate-rec = ''
          buf_temp-xml-tables.gate-name = ''
          .
          create temp-table buf_temp-xml-tables.table-handle_.
          assign
          buf_temp-xml-tables.table-handle_:undo      = false
          tt-name       = "tt_":U + buf_esys-route-dump.esrd-dump-name
          .
          assign
          v-ok = buf_temp-xml-tables.table-handle_:create-like( "ub.":U + buf_esys-route-dump.esrd-dump-name ) no-error
          .
          if v-ok <> true
            or error-status :error
          then do:
            run gate-clear in this-procedure ( input p-dataseth, input p-xmlh).
            undo main-block, return error substitute( "&1. Ошибка при создании временной таблицы &2 (1).&3&4", vss-workfile, tt-name, chr(10), error-status:get-message(1) ).
          end.
          assign
            v-ok = buf_temp-xml-tables.table-handle_:temp-table-prepare( tt-name ) no-error
          .
          if v-ok <> true
            or error-status :error
          then do:
            run gate-clear in this-procedure ( input p-dataseth, input p-xmlh).
            undo main-block, return error substitute( "&1. Ошибка при создании временной таблицы &2 (2).&3&4", vss-workfile, tt-name, chr(10), error-status:get-message(1) ).
          end.
        end.
        assign
        buf_temp-xml-tables.tbl-handle_ = buf_temp-xml-tables.table-handle_:default-buffer-handle
        p-num-rec = p-num-rec + 1
        .
      end.
      if buf_esys-route-dump.esrd-action begins "_hidden="
      or buf_esys-route-dump.esrd-action begins "_route-order="
      or buf_esys-route-dump.esrd-action begins "_dump-order="
      then do:
      if buf_esys-route-dump.esrd-action begins "_hidden=" then do:
        assign
        buf_temp-xml-tables.tbl-handle_:buffer-field(entry(2, buf_esys-route-dump.esrd-action, "=")):xml-node-type = "hidden" no-error.
        if error-status:error then do:
          run gate-clear in this-procedure ( input p-dataseth, input p-xmlh).
          undo main-block, return error substitute( "&1. Измение типа узла на HIdden не прошел для таблицы &2.&3&4"
                                                  ,vss-workfile
                                                  ,buf_esys-route-dump.esrd-dump-name
                                                  ,chr(10)
                                                  ,error-status:get-message(1) ).
        end.
      end.
        if buf_esys-route-dump.esrd-action begins "_route-order="  then do:
          v-route-order-field = entry(2, buf_esys-route-dump.esrd-action, "=").
        end.
        if buf_esys-route-dump.esrd-action begins "_dump-order="  then do:
          v-dump-order-field = entry(2, buf_esys-route-dump.esrd-action, "=").
        end.
      end.
      else do:
      assign
        v-ok = buf_temp-xml-tables.tbl-handle_:buffer-create no-error
      .
      if v-ok <> true
        or error-status :error
      then do:
        run gate-clear in this-procedure ( input p-dataseth, input p-xmlh).
        undo main-block, return error substitute( "&1. Ошибка при создании записи в буфере временной таблицы &2 .&3&4", vss-workfile, tt-name, chr(10), error-status:get-message(1) ).
      end.
      assign
        v-ok = buf_temp-xml-tables.tbl-handle_:raw-transfer ( false, bh_route-dump:buffer-field("esrd-value-rec") ) no-error
      .
      if v-ok <> true
        or error-status :error
      then do:
        run gate-clear in this-procedure ( input p-dataseth, input p-xmlh).
          undo main-block, return error substitute( "&1. RAW-TRANSFER не прошел для таблицы &2.&3&4", vss-workfile, buf_temp-xml-tables.tbl-name, chr(10), error-status:get-message(1) ).
      end.
        if v-route-order-field <> '' then do:
          assign
          buf_temp-xml-tables.tbl-handle_:buffer-field(v-route-order-field):buffer-value = string(buf_esys-route.esr-tbl-ord, "9999999999999999999") + "-" +
                                                                                           string(buf_esys-route-dump.esrd-rec-ord, "9999999999")
          .
        end.
        if v-dump-order-field <> '' then do:
          assign
          buf_temp-xml-tables.tbl-handle_:buffer-field(v-dump-order-field):buffer-value = string(buf_esys-route-dump.esrd-dump-ord, "9999999999999999999") + "-" +
                                                                                          string(buf_esys-route-dump.esrd-rec-ord, "9999999999")
          .
        end.
      end.
    end.
      if buf_esys-route.esr-action = 'command-pbush':U then do:
        find first  buf_esys-route exclusive-lock where
                  buf_esys-route.esys-id = v-esys-id
              and buf_esys-route.db-num = v-db-num
              and buf_esys-route.esr-cr-db-num = v-cr-db-num
              and buf_esys-route.esr-last-pack = v-pack-num
              and buf_esys-route.esr-tbl-ord > v-esr-tbl-ord no-error.
        if not available buf_esys-route then leave _fill.
        v-esr-tbl-ord = buf_esys-route.esr-tbl-ord.
        v-esr-dump-ord = buf_esys-route.esr-dump-ord.
      end.
      else do:
        leave _fill.
      end.
    end.
  end.
end procedure.
procedure fillxpck_empty :
define output parameter p-dataseth as handle no-undo .
define input-output parameter p-xmlh as handle no-undo .
define output parameter p-num-rec as integer no-undo .
do
on error undo, return error
:
  create dataset p-dataseth .
  assign
  p-dataseth:name = "empty"
  .
end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fillxcnf :
define input  parameter p-esys-id as integer   no-undo .
define input  parameter p-db-num as integer   no-undo .
define input  parameter p-crdb-num as integer   no-undo .
define input  parameter p-pack-num as integer   no-undo .
define parameter buffer buf_temp-esys-pck-sent for THpck-sent.
define parameter buffer buf_temp-esys-pck-rcvd for THpck-rcvd.
define parameter buffer curr_temp-esys-pck-sent for THcurr-pack.
define output parameter rec-cnt as integer   no-undo .
define output parameter v-prev-crc as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable glog as logical   no-undo .
define buffer prev_esys-pck-sent for ub.esys-pck-sent.
define buffer last_esys-route for ub.esys-route.
define buffer buf_esys-pck-sent for ub.esys-pck-sent.
define buffer buf_esys-pck-keys for ub.esys-pck-keys.
define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd.
define buffer buf_db for ub.db.
define buffer buf_sys-ctrl for ub.sys-ctrl.
do
on error undo, return error return-value
:
  find first buf_db where buf_db.db-num = g#db-num no-lock.
  find prev_esys-pck-sent no-lock
    where prev_esys-pck-sent.esys-id  = p-esys-id
      and prev_esys-pck-sent.db-num   = p-db-num
      and prev_esys-pck-sent.esps-cr-db-num = p-cr-db-num
      and prev_esys-pck-sent.esps-pack-num = p-pack-num - 1
    no-error
  .
  if available prev_esys-pck-sent then do:
    assign
      v-prev-crc = prev_esys-pck-sent.esps-crc-pack
    .
  end.
  else do:
    assign
      v-prev-crc = "":U
    .
  end.
  find first buf_sys-ctrl no-lock.
  create t-pck-conf.
  assign
  t-pck-conf.sys-key    = buf_sys-ctrl.sys-key
  t-pck-conf.esys-id    = p-esys-id
  t-pck-conf.db-num     = p-db-num
  t-pck-conf.current-db-num = g#db-num
  t-pck-conf.pack-num   = p-pack-num
  t-pck-conf.total-recs = ?
  t-pck-conf.rcvd-recs  = 0
  t-pck-conf.src_db-key = buf_db.db-key
  t-pck-conf.prev-crc   = v-prev-crc
  .
  find last last_esys-route no-lock
     where last_esys-route.esys-id   = p-esys-id
       and last_esys-route.db-num    = p-db-num
       and last_esys-route.esr-cr-db-num = p-cr-db-num
       and last_esys-route.esr-last-pack = p-pack-num
     use-index pi
     no-error .
  for each buf_esys-pck-sent no-lock
    where buf_esys-pck-sent.esys-id  = p-esys-id
      and buf_esys-pck-sent.db-num   = p-db-num
      and buf_esys-pck-sent.esps-rcvd     = no
      and buf_esys-pck-sent.esps-pack-num < p-pack-num
  on error  undo, return error substitute( "&1 (for each buf_esys-pck-sent). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (for each buf_esys-pck-sent). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (for each buf_esys-pck-sent). endkey", vss-workfile )
  :
    assign
    rec-cnt = rec-cnt + 1
    .
    create buf_temp-esys-pck-sent.
    glog = buffer buf_temp-esys-pck-sent:handle:buffer-copy(buffer buf_esys-pck-sent:handle
                                                ,""
                                                ,"THfilename,custom-pack-name,THcrc-pack,esps-crc-pack,THcredate,esps-credate,THcrenum,esps-crenum,THcretimeint,esps-cretimeint,THcretime,esps-cretime,THrcvddate,esps-rcvddate,THpack-num,esps-pack-num,THrcvdtimeint,esps-rcvdtimeint,THrcvdtime,esps-rcvdtime,THrcvd,esps-rcvd,THsendtxtdate,esps-sendtxtdate,THsendtxttimeint,esps-sendtxttimeint,THsendtxttime,esps-sendtxttime,THtotal-recs,esps-total-recs,THesys-id,esys-id"
                                                ).
  end.
  for each buf_esys-pck-rcvd no-lock
    where buf_esys-pck-rcvd.esys-id    = p-esys-id
      and buf_esys-pck-rcvd.db-num     = p-db-num
      and buf_esys-pck-rcvd.espr-rcvd       = no
      and buf_esys-pck-rcvd.espr-total-recs = buf_esys-pck-rcvd.espr-rcvd-recs
  on error  undo, return error substitute( "&1 (for each buf_esys-pck-rcvd). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (for each buf_esys-pck-rcvd). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (for each buf_esys-pck-rcvd). endkey", vss-workfile )
  :
    create buf_temp-esys-pck-rcvd.
    glog = buffer buf_temp-esys-pck-rcvd:handle:buffer-copy(buffer buf_esys-pck-rcvd:handle
                                                ,"":U
                                                ,"THfilename,custom-pack-name,THesys-id,esys-id,THcrc-pack,espr-crc-pack,THpack-num,espr-pack-num,THrcvd-recs,espr-rcvd-recs,THrcvd,espr-rcvd,THtotal-recs,total-recs"
                                                ).
    assign
    rec-cnt = rec-cnt + 1
    .
  end.
  do
  on error  undo, return error substitute( "&1 (do transaction). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (do transaction). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (do transaction). endkey", vss-workfile )
  :
    find first buf_esys-pck-sent exclusive-lock
      where buf_esys-pck-sent.esys-id   = p-esys-id
        and buf_esys-pck-sent.db-num   = p-db-num
        and buf_esys-pck-sent.esps-cr-db-num   = p-cr-db-num
        and buf_esys-pck-sent.esps-pack-num = p-pack-num
    .
    run cur-time in this-procedure ( output v-today, output v-time).
    assign
      rec-cnt = rec-cnt + 1 + 1
      buf_esys-pck-sent.esps-total-recs     = rec-cnt
      buf_esys-pck-sent.esps-CreNum         = buf_esys-pck-sent.esps-CreNum + 1
      buf_esys-pck-sent.esps-SendTxtDate    = v-today
      buf_esys-pck-sent.esps-SendTxtTimeInt = v-time
      buf_esys-pck-sent.esps-SendTxtTime    = string( v-time, "HH:MM:SS" )
      .
    create curr_temp-esys-pck-sent.
    glog = buffer curr_temp-esys-pck-sent:handle:buffer-copy(buffer buf_esys-pck-sent:handle
                                                ,""
                                                ,"THfilename,custom-pack-name,THcrc-pack,esps-crc-pack,THcredate,esps-credate,THcrenum,esps-crenum,THcretimeint,esps-cretimeint,THcretime,esps-cretime,THrcvddate,esps-rcvddate,THpack-num,esps-pack-num,THrcvdtimeint,esps-rcvdtimeint,THrcvdtime,esps-rcvdtime,THrcvd,esps-rcvd,THsendtxtdate,esps-sendtxtdate,THsendtxttimeint,esps-sendtxttimeint,THsendtxttime,esps-sendtxttime,THtotal-recs,esps-total-recs,THesys-id,esys-id"
                                                ).
  end.
end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-rel-handle no-undo
field dh as handle
field ii as integer
field active_ as logical
field child-buffer_ as character
field parent-buffer_ as character
field child-buffer-handle as handle
field parent-buffer-handle as handle
field name_ as character
field nested_ as logical
field relation-fields_ as character
field reposition_ as logical
field type_ as character
field query_ as handle
field where-string_ as character
field tbl-handle_ as handle
index pi is unique primary
ii
index iparentname parent-buffer_ child-buffer_
index iparenthandle parent-buffer-handle child-buffer-handle
.
procedure tmpreldf_get-relations :
define input parameter p-dataseth as handle no-undo .
define variable v-ii as integer no-undo .
define buffer buf_temp-rel-handle for temp-rel-handle.
do
on error undo, return error
:
  if not valid-handle(p-dataseth)
  or p-dataseth:type <> "DATASET"
  then do:
    return error substitute("Не определен dataset с handle &1", p-dataseth).
  end.
  for each buf_temp-rel-handle where
          buf_temp-rel-handle.dh = p-dataseth:
    delete buf_temp-rel-handle.
  end.
  do v-ii = 1 to p-dataseth:num-relations:
    create buf_temp-rel-handle.
    assign
    buf_temp-rel-handle.ii = v-ii
    buf_temp-rel-handle.dh = p-dataseth
    buf_temp-rel-handle.active_ = p-dataseth:get-relation(v-ii):active
    buf_temp-rel-handle.child-buffer_ = p-dataseth:get-relation(v-ii):child-buffer:name
    buf_temp-rel-handle.parent-buffer_ = p-dataseth:get-relation(v-ii):parent-buffer:name
    buf_temp-rel-handle.child-buffer-handle = p-dataseth:get-relation(v-ii):child-buffer
    buf_temp-rel-handle.tbl-handle_ = buf_temp-rel-handle.child-buffer-handle
    buf_temp-rel-handle.parent-buffer-handle = p-dataseth:get-relation(v-ii):parent-buffer
    buf_temp-rel-handle.name_ = p-dataseth:get-relation(v-ii):name
    buf_temp-rel-handle.nested_ = p-dataseth:get-relation(v-ii):nested
    buf_temp-rel-handle.relation-fields_ = p-dataseth:get-relation(v-ii):relation-fields
    buf_temp-rel-handle.reposition_ = p-dataseth:get-relation(v-ii):reposition
    buf_temp-rel-handle.type_ = p-dataseth:get-relation(v-ii):type
    buf_temp-rel-handle.query_ = p-dataseth:get-relation(v-ii):query
    buf_temp-rel-handle.where-string_ = p-dataseth:get-relation(v-ii):where-string
    .
  end.
end.
end procedure.
procedure tmpreldf_set-relations :
define input parameter p-srcdataseth as handle no-undo .
define input parameter p-trgdataseth as handle no-undo .
define variable gh as handle no-undo .
define buffer buf_temp-rel-handle for temp-rel-handle.
do
on error undo, return error
:
  if not valid-handle(p-srcdataseth)
  or p-srcdataseth:type <> "DATASET"
  then do:
    return error substitute("Не определен dataset-источник с handle &1", p-srcdataseth).
  end.
  if not valid-handle(p-trgdataseth)
  or p-trgdataseth:type <> "DATASET"
  then do:
    return error substitute("Не определен dataset-приемник с handle &1", p-trgdataseth).
  end.
  for each buf_temp-rel-handle no-lock where
          buf_temp-rel-handle.dh = p-srcdataseth
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    gh = p-trgdataseth:ADD-RELATION ( buf_temp-rel-handle.parent-buffer-handle
                                      , buf_temp-rel-handle.child-buffer-handle
                                      , buf_temp-rel-handle.relation-fields_
                                      , buf_temp-rel-handle.reposition_
                                      , buf_temp-rel-handle.nested_).
   if error-status:error
   or not valid-handle(gh) then do:
     undo, return error substitute("Ошибка при добавлении relation &1 в dataset &2", buf_temp-rel-handle.name, p-trgdataseth:name).
   end.
  end.
end.
end procedure.
define variable v_dataseth as handle no-undo .
define variable tth as handle  no-undo .
define variable bh_route-dump as handle no-undo .
define variable glog as logical no-undo .
define variable v-ok as logical no-undo .
define variable tt-name as character no-undo .
define variable v-xmlh as handle no-undo .
define variable v-headerh as handle no-undo .
define variable v-header-th as handle no-undo .
define variable v-pckrcvd as handle no-undo .
define variable v-pcksent as handle no-undo .
define variable v-currpcksent as handle no-undo .
define variable v-prev-crc as character no-undo .
define variable bh_tt as handle no-undo .
define variable rec-cnt as integer no-undo .
define variable v-num-rec as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-is-ack as logical no-undo .
define variable v-header-schema-name as character no-undo .
define variable v-header-name as character no-undo .
define variable v-header-rec as character no-undo .
define buffer buf_esys-route for ub.esys-route.
define buffer buf_esys-route-dump for ub.esys-route-dump.
define buffer buf_temp-xml-tables for temp-xml-tables.
define buffer buf_ext-system for ub.ext-system.
define buffer buf_esys-pck-sent for ub.esys-pck-sent.
define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd.
define buffer buf_esys-pck-keys for ub.esys-pck-keys.
define buffer buf_temp-esys-pck-rcvd for THpck-rcvd.
define buffer buf_temp-esys-pck-sent for THpck-sent.
define buffer curr_temp-esys-pck-sent for THcurr-pack.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  assign
  v-xmlh = buffer buf_temp-xml-tables:handle
  v-pckrcvd = buffer buf_temp-esys-pck-rcvd:handle
  v-pcksent = buffer buf_temp-esys-pck-sent:handle
  v-currpcksent = buffer curr_temp-esys-pck-sent:handle
  .
  for each buf_temp-esys-pck-rcvd:
    delete buf_temp-esys-pck-rcvd.
  end.
  for each buf_temp-esys-pck-sent:
    delete buf_temp-esys-pck-sent.
  end.
  for each curr_temp-esys-pck-sent:
    delete curr_temp-esys-pck-sent.
  end.
  for each t-pck-conf:
    delete t-pck-conf.
  end.
  find first buf_ext-system no-lock where
            buf_ext-system.esys-id = p-esys-id
        and buf_ext-system.db-num = p-db-num
            no-error.
  if not available buf_ext-system then do:
        run write-log in p-log-handle (           input 2         , input substitute("Неизвестная внешняя система &1", p-esys-id) ).
    undo, return error ''.
  end.
  find first buf_esys-pck-sent no-lock
    where buf_esys-pck-sent.esys-id  = p-esys-id
      and buf_esys-pck-sent.db-num   = p-db-num
      and buf_esys-pck-sent.esps-pack-num = p-pack-num
    no-error
  .
  if available buf_esys-pck-sent then do:
    if buf_esys-pck-sent.esps-SendTxtDate <> ? then do:
            run write-log in p-log-handle (           input 2         , input substitute("Переформирование файла пакета N &1 для ВС N &2", p-pack-num, p-esys-id ) ).
    end.
    else do:
            run write-log in p-log-handle (           input 2         , input substitute("Формирование файла пакета N &1 для ВС N &2", p-pack-num, p-esys-id ) ).
    end.
  end.
  else do:
        run write-log in p-log-handle (           input 2         , input substitute("&1. Пакет N &2 для ВС N &3 отсутствует.", vss-workfile, p-pack-num, p-esys-id ) ).
    undo, return error .
  end.
  if not buf_ext-system.delivery-method = integer('9':U) and not buf_ext-system.delivery-method = integer('11':U) then do:
    if p-esr-dump-ord >= 0 then do:
    find first buf_esys-route exclusive-lock where
              buf_esys-route.esr-dump-ord = p-esr-dump-ord
         and  buf_esys-route.esys-id = p-esys-id
         and  buf_esys-route.db-num = p-db-num
              .
    run  fillxpck in this-procedure (
                                       buffer buf_esys-route
                                      ,output v_dataseth
                                      ,input-output v-xmlh
                                      ,output v-num-rec
                                      ) no-error.
    if error-status:error then do:
            run write-log in p-log-handle (           input 2         , input substitute("&1 Ошибка при заполнении пакета &6 (&6) через gate &2&3&4&3&5"                                               , vss-workfile                                               ,buf_esys-route.uniq-gate-rec                                               ,chr(10)                                               ,error-status:get-message(1)                                               ,return-value                                               ,p-pack-num                                               ,buf_esys-route.esr-name-rec ) ).
      run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
      undo, return error ''.
    end.
    end.
    else do:
      run  fillxpck_empty in this-procedure (
                                         output v_dataseth
                                        ,input-output v-xmlh
                                        ,output v-num-rec
                                        ) no-error.
      if error-status:error then do:
                run write-log in p-log-handle (           input 2         , input substitute("&1 Ошибка при заполнении ПУСТОГО пакета &6 (&6) через &2&3&2&4"                                                 , vss-workfile                                                 ,chr(10)                                                 ,error-status:get-message(1)                                                 ,return-value                                                 ,p-pack-num                                                 ,buf_esys-route.esr-name-rec ) ).
        run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
        undo, return error ''.
      end.
    end.
    if buf_ext-system.exp-conf-wait = integer('1':U)  then do:
       run fillxcnf in this-procedure ( input p-esys-id
                                       ,input p-db-num
                                       ,input p-cr-db-num
                                       ,input p-pack-num
                                       ,buffer buf_temp-esys-pck-sent
                                       ,buffer buf_temp-esys-pck-rcvd
                                       ,buffer curr_temp-esys-pck-sent
                                       ,output rec-cnt
                                       ,output v-prev-crc
                                       ) no-error.
       if error-status :error then do:
                run write-log in p-log-handle (           input 2         , input substitute("&1 Ошибка при заполнении пакета &2 данными для подтверждений &3&4&3&5"                                       ,p-pack-num                                       , vss-workfile                                       ,chr(10)                                       ,error-status:get-message(1)                                       ,return-value                                         ) ).
        run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
        undo, return error ''.
       end.
    end.
    rec-cnt = rec-cnt + v-num-rec.
    case buf_ext-system.delivery-method:
      when integer('3':U) then do:
        if entry(num-entries(p-xml-file-name, "."), p-xml-file-name, ".") = "ack" then do:
          v-is-ack = yes.
        end.
        else do:
          v-header-schema-name = "exe/header_.xsd".
          v-header-name = "header_".
          define buffer buf_clients for ub.clients.
          find first buf_clients no-lock where
                    buf_clients.db-num = g#db-num
                and buf_clients.obj-type = 'маг':U no-error .
          run get-gate-rec in this-procedure ( input v-header-schema-name
                                              ,output v-header-rec) no-error.
          if error-status:error then do:
            undo, return error substitute("Не найдено описание xsd-схемы &1 в БД", v-header-schema-name).
          end.
          run get-header-by-rec in this-procedure ( input v-header-rec
                                                ,output v-header-th
                                                ) no-error.
          if error-status:error then do:
                        run write-log in p-log-handle (           input 2         , input substitute("Ошибка при создании структуры заголовка пакета согласно гейту:&1&2"                                       , v-header-rec                                       , chr(10), error-status:get-message(1) ) ).
            undo, return error '':U.
          end.
          run cur-time in this-procedure ( output v-today, output v-time).
          v-headerh = v-header-th:default-buffer-handle.
          v-headerh:buffer-create().
         assign
          v-headerh::to_ = "Oracle Retail"
          v-headerh::from_ = "IBS Trade House"
          v-headerh::obj-type = (if available buf_clients then buf_clients.obj-type else '')
          v-headerh::obj-code = (if available buf_clients then string (buf_clients.obj-code) else '')
          v-headerh::name = entry(2, entry(1, v_dataseth:private-data, chr(4)), chr(47))
          v-headerh::xsd = entry(2, entry(1, v_dataseth:private-data, chr(4)), chr(47))
          v-headerh::date-from =  string(datetime(v-today, mtime), "99/99/9999 HH:MM:SS")
          v-headerh::date-to =  string(datetime(v-today, mtime), "99/99/9999 HH:MM:SS")
          .
        end.
      end.
      when integer('5':U) then do:
        v-header-schema-name = "".
        v-header-name = "".
      end.
      otherwise do:
          v-header-schema-name = "exe/ThHeader.xsd".
          v-header-name = "ThHeader".
          run get-gate-rec in this-procedure ( input v-header-schema-name
                                              ,output v-header-rec) no-error.
          if error-status:error then do:
            undo, return error substitute("Не найдено описание xsd-схемы &1 в БД", v-header-schema-name).
          end.
          run get-header-by-rec in this-procedure ( input v-header-rec
                                                ,output v-header-th
                                                ) no-error.
          if error-status:error then do:
                        run write-log in p-log-handle (           input 2         , input substitute("Ошибка при создании структуры заголовка поакета согласно гейту:&1&2"                                       , v-header-rec                                       , chr(10), error-status:get-message(1) ) ).
            undo, return error '':U.
          end.
        v-headerh = v-header-th:default-buffer-handle.
        v-headerh:buffer-create( ).
        assign
        v-headerh::THfilename     = p-xml-file-name
        v-headerh::THfilenumber   = p-xml-file-number
        v-headerh::THformat_      = "Trade House OpenXML 1.0"
        v-headerh::THversion_     = trim( replace( substring( vss-archive, 15, 4 ), "$":U, "":U ) )
        v-headerh::THrevision     = trim( replace( substring( vss-revision, 12 ), "$":U, "":U ) )
        v-headerh::THesysname     = buf_ext-system.esys-name
        v-headerh::THcurrentDbNum = g#db-num
        v-headerh::THpack-num     = p-pack-num
        v-headerh::THschema-name  = substitute("exe/&1", entry(2, entry(1, v_dataseth:private-data, chr(4)), chr(47)))
        v-headerh::THprev-crc     = v-prev-crc
        v-headerh::THexport-esys-id  = p-esys-id
    .
      end.
    end case.
    if not v-is-ack
    and v-header-name <> ""
    then do:
    create buf_temp-xml-tables.
    assign
    buf_temp-xml-tables.tbl-name = v-headerh:table
    buf_temp-xml-tables.tbl-handle_ = v-headerh
    buf_temp-xml-tables.table-handle_ = v-headerh:table-handle
    buf_temp-xml-tables.uniq-gate-rec = (if available buf_esys-route then buf_esys-route.uniq-gate-rec else '')
    buf_temp-xml-tables.gate-name = v_dataseth:name
    buf_temp-xml-tables.gate-handle_ = v_dataseth
    buf_temp-xml-tables.order = -3
    rec-cnt = rec-cnt + 1
    .
  end.
    if buf_ext-system.exp-conf-wait = integer('1':U)  then do:
      create buf_temp-xml-tables.
      assign
      buf_temp-xml-tables.tbl-name = v-pcksent:table
      buf_temp-xml-tables.tbl-handle_ = v-pcksent
      buf_temp-xml-tables.table-handle_ = v-pcksent:table-handle
      buf_temp-xml-tables.uniq-gate-rec = (if available buf_esys-route then buf_esys-route.uniq-gate-rec else '')
      buf_temp-xml-tables.gate-name = v_dataseth:name
      buf_temp-xml-tables.gate-handle_ = v_dataseth
      buf_temp-xml-tables.order = -2
      .
      create buf_temp-xml-tables.
      assign
      buf_temp-xml-tables.tbl-name = v-pckrcvd:table
      buf_temp-xml-tables.tbl-handle_ = v-pckrcvd
      buf_temp-xml-tables.table-handle_ = v-pckrcvd:table-handle
      buf_temp-xml-tables.uniq-gate-rec = (if available buf_esys-route then buf_esys-route.uniq-gate-rec else '')
      buf_temp-xml-tables.gate-name = v_dataseth:name
      buf_temp-xml-tables.gate-handle_ = v_dataseth
      buf_temp-xml-tables.order = -1
      .
      create buf_temp-xml-tables.
      assign
      buf_temp-xml-tables.tbl-name = v-currpcksent:table
      buf_temp-xml-tables.tbl-handle_ = v-currpcksent
      buf_temp-xml-tables.table-handle_ = v-currpcksent:table-handle
      buf_temp-xml-tables.uniq-gate-rec = (if available buf_esys-route then buf_esys-route.uniq-gate-rec else '')
      buf_temp-xml-tables.gate-name = v_dataseth:name
      buf_temp-xml-tables.gate-handle_ = v_dataseth
      buf_temp-xml-tables.order = v_dataseth:num-buffers + 1
      .
    end.
    if not (v-is-ack
            or
            v-header-name = '')
    then do:
      if v-headerh:table = "THheader" then do:
        v-headerh::THtotal-recs = rec-cnt.
      end.
    run tmpreldf_get-relations in this-procedure ( input v_dataseth).
    for each buf_temp-xml-tables
    break
    by buf_temp-xml-tables.order:
     if first(buf_temp-xml-tables.order) then do:
       glog = v_dataseth:set-buffers ( buf_temp-xml-tables.tbl-handle_) no-error.
     end.
     else do:
       glog = v_dataseth:add-buffer ( buf_temp-xml-tables.tbl-handle_) no-error.
     end.
     if error-status:error
      or not glog                                     then do:
                run write-log in p-log-handle (           input 2         , input substitute("Ошибка при создании заголовка XML файла:&1&2", chr(10), error-status:get-message(1) ) ).
        run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
        undo, return error '':U.
      end.
    end.
    run tmpreldf_set-relations in this-procedure ( input v_dataseth, input v_dataseth).
    end.
    glog = v_dataseth:WRITE-XML("FILE"
                              ,p-xml-file-name
                              ,yes
                              ,(if buf_ext-system.delivery-method = integer('5':U)
                                then "utf-8"
                                else "windows-1251")
                              ,?
                              ,no
                              ,no
                              ) no-error.
    if error-status:error then do:
                run write-log in p-log-handle (           input 2         , input substitute("Ошибка при записи XML файла данными через гейт &1:&2&3"                                       , v_dataseth:name                                       , chr(10), error-status:get-message(1) ) ).
    end.
    p-num-rec = v-num-rec.
    run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
  end.
  else do:
    define stream exp-str .
    define variable mbuffer as memptr .
    output stream exp-str to value(p-xml-file-name).
    for each buf_esys-route-dump where buf_esys-route-dump.esrd-dump-ord = p-esr-dump-ord:
      mbuffer = buf_esys-route-dump.esrd-blob-value-rec.
      export stream exp-str mbuffer .
    end.
    output stream exp-str close.
  end.
end.
