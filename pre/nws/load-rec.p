block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: b39224d84de3, 3188, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:26 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gen-imp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/gen-imp.p $":U .
define variable vss-description as character no-undo init "загрузка в БД строки".
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
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info3 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info3, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info3, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info3 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info3, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info3 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info3, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info3, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info3, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info3, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info3, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info3 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info3 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info3, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info3 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info3 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, v-tbl-name ).
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
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-proc-name  as character no-undo .
define variable v-proc-avail as logical   no-undo .
define new global shared variable g#load-rec  as handle no-undo .
if valid-handle (g#load-rec)
and g#load-rec <> this-procedure :handle
and lookup( "proc-load-abc-analysis":U, g#load-rec:internal-entries ) > 0
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки" skip
    g#load-rec skip
    g#load-rec :type skip
    g#load-rec :file-name skip
    valid-handle(g#load-rec) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error return-value .
end.
else do:
  assign
    g#load-rec = this-procedure :handle
  .
end.
if this-procedure :persistent <> true
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка запуска библиотеки" program-name(1) skip
    "Попытка запустить ее как обычную процедуру" skip
    view-as alert-box error .
end.
on delete of this-procedure do:
  assign
    g#load-rec = ?
  .
end.
define temp-table locb-abc-analysis-obj          no-undo like  ub.abc-analysis-obj          .
define temp-table locb-abc-analysis-doc          no-undo like  ub.abc-analysis-doc          .
define temp-table locb-abc-analysis-attr         no-undo like  ub.abc-analysis-attr         .
define temp-table locb-abc-analysis-period       no-undo like  ub.abc-analysis-period       .
define temp-table locb-abc-analysis-goods        no-undo like  ub.abc-analysis-goods        .
define temp-table locb-abc-analysis-gds-obj      no-undo like  ub.abc-analysis-gds-obj      .
define temp-table locb-abc-analysis-goods-attr   no-undo like  ub.abc-analysis-goods-attr   .
define temp-table locb-abc-analysis-gds-obj-attr no-undo like  ub.abc-analysis-gds-obj-attr .
define temp-table wt-abc-analysis no-undo like ub.abc-analysis.
PROCEDURE proc-load-abc-analysis:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-abc-analysis. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-abc-analysis. stop" )
  on endkey undo, return error substitute( "$proc-load-abc-analysis. endkey" )
  :
    define buffer tb-abc-analysis for ub.abc-analysis.
    define variable compare-log as logical no-undo.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_abc-analysis-obj           for ub.abc-analysis-obj          .
define buffer buf_abc-analysis-doc           for ub.abc-analysis-doc          .
define buffer buf_abc-analysis-attr          for ub.abc-analysis-attr         .
define buffer buf_abc-analysis-period        for ub.abc-analysis-period       .
define buffer buf_abc-analysis-goods         for ub.abc-analysis-goods        .
define buffer buf_abc-analysis-gds-obj       for ub.abc-analysis-gds-obj      .
define buffer buf_abc-analysis-goods-attr    for ub.abc-analysis-goods-attr   .
define buffer buf_abc-analysis-gds-obj-attr  for ub.abc-analysis-gds-obj-attr .
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-abc-analysis-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-obj.
end.
for each locb-abc-analysis-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-doc.
end.
for each locb-abc-analysis-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-attr.
end.
for each locb-abc-analysis-period
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-period.
end.
for each locb-abc-analysis-goods
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-goods.
end.
for each locb-abc-analysis-gds-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-gds-obj.
end.
for each locb-abc-analysis-goods-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-goods-attr.
end.
for each locb-abc-analysis-gds-obj-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-gds-obj-attr.
end.
    for each wt-abc-analysis
    on error undo, return error substitute( "$proc-load-abc-analysis(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-abc-analysis .
    end.
    create wt-abc-analysis.
    run nws-impl in p-imp-handle
      ( input 'abc-analysis':U
       ,input (buffer wt-abc-analysis:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-abc-analysis
      where tb-abc-analysis.abc-id = wt-abc-analysis.abc-id
        and tb-abc-analysis.db-num = wt-abc-analysis.db-num
      exclusive-lock no-error.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "abc-analysis-obj" then do:
      create locb-abc-analysis-obj.
run nws-impl in p-imp-handle
  ( input "abc-analysis-obj":U
   ,input (buffer locb-abc-analysis-obj:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "abc-analysis-doc" then do:
      create locb-abc-analysis-doc.
run nws-impl in p-imp-handle
  ( input "abc-analysis-doc":U
   ,input (buffer locb-abc-analysis-doc:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "abc-analysis-attr" then do:
      create locb-abc-analysis-attr.
run nws-impl in p-imp-handle
  ( input "abc-analysis-attr":U
   ,input (buffer locb-abc-analysis-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "abc-analysis-period" then do:
      create locb-abc-analysis-period.
run nws-impl in p-imp-handle
  ( input "abc-analysis-period":U
   ,input (buffer locb-abc-analysis-period:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "abc-analysis-goods" then do:
      create locb-abc-analysis-goods.
run nws-impl in p-imp-handle
  ( input "abc-analysis-goods":U
   ,input (buffer locb-abc-analysis-goods:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "abc-analysis-gds-obj" then do:
      create locb-abc-analysis-gds-obj.
run nws-impl in p-imp-handle
  ( input "abc-analysis-gds-obj":U
   ,input (buffer locb-abc-analysis-gds-obj:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "abc-analysis-goods-attr" then do:
      create locb-abc-analysis-goods-attr.
run nws-impl in p-imp-handle
  ( input "abc-analysis-goods-attr":U
   ,input (buffer locb-abc-analysis-goods-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "abc-analysis-gds-obj-attr" then do:
      create locb-abc-analysis-gds-obj-attr.
run nws-impl in p-imp-handle
  ( input "abc-analysis-gds-obj-attr":U
   ,input (buffer locb-abc-analysis-gds-obj-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе abc-анализа."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_abc-analysis-obj where
         buf_abc-analysis-obj.abc-id   = wt-abc-analysis.abc-id  and
         buf_abc-analysis-obj.db-num    = wt-abc-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_abc-analysis-obj.
end.
for each locb-abc-analysis-obj where
         locb-abc-analysis-obj.abc-id = wt-abc-analysis.abc-id and
         locb-abc-analysis-obj.db-num  = wt-abc-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_abc-analysis-obj.
  buffer-copy locb-abc-analysis-obj to buf_abc-analysis-obj.
end.
for each buf_abc-analysis-doc where
         buf_abc-analysis-doc.abc-id   = wt-abc-analysis.abc-id  and
         buf_abc-analysis-doc.db-num    = wt-abc-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_abc-analysis-doc.
end.
for each locb-abc-analysis-doc where
         locb-abc-analysis-doc.abc-id = wt-abc-analysis.abc-id and
         locb-abc-analysis-doc.db-num  = wt-abc-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_abc-analysis-doc.
  buffer-copy locb-abc-analysis-doc to buf_abc-analysis-doc.
end.
for each buf_abc-analysis-attr where
         buf_abc-analysis-attr.abc-id   = wt-abc-analysis.abc-id  and
         buf_abc-analysis-attr.db-num   = wt-abc-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_abc-analysis-attr.
end.
for each locb-abc-analysis-attr where
         locb-abc-analysis-attr.abc-id = wt-abc-analysis.abc-id and
         locb-abc-analysis-attr.db-num  = wt-abc-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_abc-analysis-attr.
  buffer-copy locb-abc-analysis-attr to buf_abc-analysis-attr.
end.
for each buf_abc-analysis-period where
         buf_abc-analysis-period.abc-id   = wt-abc-analysis.abc-id  and
         buf_abc-analysis-period.db-num   = wt-abc-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_abc-analysis-period.
end.
for each locb-abc-analysis-period where
         locb-abc-analysis-period.abc-id = wt-abc-analysis.abc-id and
         locb-abc-analysis-period.db-num  = wt-abc-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_abc-analysis-period.
  buffer-copy locb-abc-analysis-period to buf_abc-analysis-period.
end.
for each buf_abc-analysis-goods-attr where
         buf_abc-analysis-goods-attr.abc-id   = wt-abc-analysis.abc-id  and
         buf_abc-analysis-goods-attr.db-num   = wt-abc-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_abc-analysis-goods-attr.
end.
for each locb-abc-analysis-goods-attr where
         locb-abc-analysis-goods-attr.abc-id = wt-abc-analysis.abc-id and
         locb-abc-analysis-goods-attr.db-num  = wt-abc-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_abc-analysis-goods-attr.
  buffer-copy locb-abc-analysis-goods-attr to buf_abc-analysis-goods-attr.
end.
for each buf_abc-analysis-goods where
         buf_abc-analysis-goods.abc-id   = wt-abc-analysis.abc-id  and
         buf_abc-analysis-goods.db-num   = wt-abc-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_abc-analysis-goods.
end.
for each locb-abc-analysis-goods where
         locb-abc-analysis-goods.abc-id = wt-abc-analysis.abc-id and
         locb-abc-analysis-goods.db-num  = wt-abc-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_abc-analysis-goods.
  buffer-copy locb-abc-analysis-goods to buf_abc-analysis-goods.
end.
for each buf_abc-analysis-gds-obj-attr where
         buf_abc-analysis-gds-obj-attr.abc-id   = wt-abc-analysis.abc-id  and
         buf_abc-analysis-gds-obj-attr.db-num   = wt-abc-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_abc-analysis-gds-obj-attr.
end.
for each locb-abc-analysis-gds-obj-attr where
         locb-abc-analysis-gds-obj-attr.abc-id = wt-abc-analysis.abc-id and
         locb-abc-analysis-gds-obj-attr.db-num  = wt-abc-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_abc-analysis-gds-obj-attr.
  buffer-copy locb-abc-analysis-gds-obj-attr to buf_abc-analysis-gds-obj-attr.
end.
for each buf_abc-analysis-gds-obj where
         buf_abc-analysis-gds-obj.abc-id   = wt-abc-analysis.abc-id  and
         buf_abc-analysis-gds-obj.db-num   = wt-abc-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_abc-analysis-gds-obj.
end.
for each locb-abc-analysis-gds-obj where
         locb-abc-analysis-gds-obj.abc-id = wt-abc-analysis.abc-id and
         locb-abc-analysis-gds-obj.db-num  = wt-abc-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_abc-analysis-gds-obj.
  buffer-copy locb-abc-analysis-gds-obj to buf_abc-analysis-gds-obj.
end.
if not available tb-abc-analysis then do:
  create tb-abc-analysis.
end.
buffer-copy wt-abc-analysis to tb-abc-analysis.
for each locb-abc-analysis-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-obj.
end.
for each locb-abc-analysis-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-doc.
end.
for each locb-abc-analysis-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-attr.
end.
for each locb-abc-analysis-period
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-period.
end.
for each locb-abc-analysis-goods
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-goods.
end.
for each locb-abc-analysis-gds-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-gds-obj.
end.
for each locb-abc-analysis-goods-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-goods-attr.
end.
for each locb-abc-analysis-gds-obj-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abc-analysis-gds-obj-attr.
end.
    delete wt-abc-analysis.
  end.
END PROCEDURE.
define temp-table locb-abcxyz-analysis-attr          no-undo like ub.abcxyz-analysis-attr    .
define temp-table locb-abcxyz-analysis-goods         no-undo like ub.abcxyz-analysis-goods   .
define temp-table locb-abcxyz-analysis-goods-attr    no-undo like ub.abcxyz-analysis-goods-attr.
define temp-table wt-abcxyz-analysis no-undo like ub.abcxyz-analysis.
PROCEDURE proc-load-abcxyz-analysis:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-abcxyz-analysis. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-abcxyz-analysis. stop" )
  on endkey undo, return error substitute( "$proc-load-abcxyz-analysis. endkey" )
  :
    define buffer tb-abcxyz-analysis for ub.abcxyz-analysis.
    define variable compare-log as logical no-undo.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_abcxyz-analysis-attr           for ub.abcxyz-analysis-attr    .
define buffer buf_abcxyz-analysis-goods          for ub.abcxyz-analysis-goods   .
define buffer buf_abcxyz-analysis-goods-attr     for ub.abcxyz-analysis-goods-attr.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-abcxyz-analysis-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abcxyz-analysis-attr.
end.
for each locb-abcxyz-analysis-goods-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abcxyz-analysis-goods-attr.
end.
for each locb-abcxyz-analysis-goods
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abcxyz-analysis-goods.
end.
    for each wt-abcxyz-analysis
    on error undo, return error substitute( "$proc-load-abcxyz-analysis(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-abcxyz-analysis .
    end.
    create wt-abcxyz-analysis.
    run nws-impl in p-imp-handle
      ( input 'abcxyz-analysis':U
       ,input (buffer wt-abcxyz-analysis:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-abcxyz-analysis
      where tb-abcxyz-analysis.abcx-id = wt-abcxyz-analysis.abcx-id
        and tb-abcxyz-analysis.db-num = wt-abcxyz-analysis.db-num
      exclusive-lock no-error.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "abcx-analysis-attr" then do:
      create locb-abcxyz-analysis-attr.
run nws-impl in p-imp-handle
  ( input "abcxyz-analysis-attr":U
   ,input (buffer locb-abcxyz-analysis-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "abcxyz-analysis-goods" then do:
      create locb-abcxyz-analysis-goods.
run nws-impl in p-imp-handle
  ( input "abcxyz-analysis-goods":U
   ,input (buffer locb-abcxyz-analysis-goods:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "abcxyz-analysis-goods-attr" then do:
      create locb-abcxyz-analysis-goods-attr.
run nws-impl in p-imp-handle
  ( input "abcxyz-analysis-goods-attr":U
   ,input (buffer locb-abcxyz-analysis-goods-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе abcx-анализа."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_abcxyz-analysis-attr where
         buf_abcxyz-analysis-attr.abcx-id   = wt-abcxyz-analysis.abcx-id  and
         buf_abcxyz-analysis-attr.db-num   = wt-abcxyz-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_abcxyz-analysis-attr.
end.
for each locb-abcxyz-analysis-attr where
         locb-abcxyz-analysis-attr.abcx-id = wt-abcxyz-analysis.abcx-id and
         locb-abcxyz-analysis-attr.db-num  = wt-abcxyz-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_abcxyz-analysis-attr.
  buffer-copy locb-abcxyz-analysis-attr to buf_abcxyz-analysis-attr.
end.
for each buf_abcxyz-analysis-goods-attr where
         buf_abcxyz-analysis-goods-attr.abcx-id   = wt-abcxyz-analysis.abcx-id  and
         buf_abcxyz-analysis-goods-attr.db-num   = wt-abcxyz-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_abcxyz-analysis-goods-attr.
end.
for each locb-abcxyz-analysis-goods-attr where
         locb-abcxyz-analysis-goods-attr.abcx-id = wt-abcxyz-analysis.abcx-id and
         locb-abcxyz-analysis-goods-attr.db-num  = wt-abcxyz-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_abcxyz-analysis-goods-attr.
  buffer-copy locb-abcxyz-analysis-goods-attr to buf_abcxyz-analysis-goods-attr.
end.
for each buf_abcxyz-analysis-goods where
         buf_abcxyz-analysis-goods.abcx-id   = wt-abcxyz-analysis.abcx-id  and
         buf_abcxyz-analysis-goods.db-num   = wt-abcxyz-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_abcxyz-analysis-goods.
end.
for each locb-abcxyz-analysis-goods where
         locb-abcxyz-analysis-goods.abcx-id = wt-abcxyz-analysis.abcx-id and
         locb-abcxyz-analysis-goods.db-num  = wt-abcxyz-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_abcxyz-analysis-goods.
  buffer-copy locb-abcxyz-analysis-goods to buf_abcxyz-analysis-goods.
end.
if not available tb-abcxyz-analysis then do:
  create tb-abcxyz-analysis.
end.
buffer-copy wt-abcxyz-analysis to tb-abcxyz-analysis.
for each locb-abcxyz-analysis-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abcxyz-analysis-attr.
end.
for each locb-abcxyz-analysis-goods
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abcxyz-analysis-goods.
end.
for each locb-abcxyz-analysis-goods-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-abcxyz-analysis-goods-attr.
end.
    delete wt-abcxyz-analysis.
  end.
END PROCEDURE.
define temp-table locb-add-line        no-undo like ub.add-line    .
define temp-table locb-add-trn         no-undo like ub.add-trn   .
define temp-table locb-add-trn-attr    no-undo like ub.add-trn-attr.
define temp-table locb-add-doc-line-attr   no-undo like ub.doc-line-attr.
define temp-table wt-add-doc no-undo like ub.add-doc.
PROCEDURE proc-load-add-doc:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-add-doc. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-add-doc. stop" )
  on endkey undo, return error substitute( "$proc-load-add-doc. endkey" )
  :
    define buffer tb-add-doc for ub.add-doc.
    define variable compare-log as logical no-undo.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_add-line         for ub.add-line    .
define buffer buf_add-trn          for ub.add-trn   .
define buffer buf_add-trn-attr     for ub.add-trn-attr.
define buffer buf_doc-line-attr    for ub.doc-line-attr.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-add-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-add-line.
end.
for each locb-add-trn-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-add-trn-attr.
end.
for each locb-add-doc-line-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-add-doc-line-attr.
end.
for each locb-add-trn
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-add-trn.
end.
    for each wt-add-doc
    on error undo, return error substitute( "$proc-load-add-doc(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-add-doc .
    end.
    create wt-add-doc.
    run nws-impl in p-imp-handle
      ( input 'add-doc':U
       ,input (buffer wt-add-doc:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-add-doc
      where tb-add-doc.doc-code = wt-add-doc.doc-code
      exclusive-lock no-error.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "add-line" then do:
      create locb-add-line.
run nws-impl in p-imp-handle
  ( input "add-line":U
   ,input (buffer locb-add-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "add-trn" then do:
      create locb-add-trn.
run nws-impl in p-imp-handle
  ( input "add-trn":U
   ,input (buffer locb-add-trn:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "add-trn-attr" then do:
      create locb-add-trn-attr.
run nws-impl in p-imp-handle
  ( input "add-trn-attr":U
   ,input (buffer locb-add-trn-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "doc-line-attr" then do:
      create locb-add-doc-line-attr.
run nws-impl in p-imp-handle
  ( input "add-doc-line-attr":U
   ,input (buffer locb-add-doc-line-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе ДопРасх."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_add-line where
         buf_add-line.doc-code   = wt-add-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_add-line.
end.
for each locb-add-line where
         locb-add-line.doc-code = wt-add-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_add-line.
  buffer-copy locb-add-line to buf_add-line.
end.
for each buf_add-trn-attr where
         buf_add-trn-attr.doc-code   = wt-add-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_add-trn-attr.
end.
for each locb-add-trn-attr where
         locb-add-trn-attr.doc-code = wt-add-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_add-trn-attr.
  buffer-copy locb-add-trn-attr to buf_add-trn-attr.
end.
for each buf_doc-line-attr where
         buf_doc-line-attr.doc-code   = wt-add-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_doc-line-attr.
end.
for each locb-add-doc-line-attr where
         locb-add-doc-line-attr.doc-code = wt-add-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_doc-line-attr.
  buffer-copy locb-add-doc-line-attr to buf_doc-line-attr.
end.
for each buf_add-trn where
         buf_add-trn.doc-code   = wt-add-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_add-trn.
end.
for each locb-add-trn where
         locb-add-trn.doc-code = wt-add-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_add-trn.
  buffer-copy locb-add-trn to buf_add-trn.
end.
if not available tb-add-doc then do:
  create tb-add-doc.
end.
buffer-copy wt-add-doc to tb-add-doc.
for each locb-add-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-add-line.
end.
for each locb-add-trn
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-add-trn.
end.
for each locb-add-trn-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-add-trn-attr.
end.
for each locb-add-doc-line-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-add-doc-line-attr.
end.
    delete wt-add-doc.
  end.
END PROCEDURE.
define temp-table wt-bar-code no-undo like ub.bar-code.
PROCEDURE proc-load-bar-code:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-bar-code. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-bar-code. stop" )
  on endkey undo, return error substitute( "$proc-load-bar-code. endkey" )
  :
    define buffer tb-bar-code for ub.bar-code.
    define variable compare-log as logical no-undo.
    for each wt-bar-code
    on error undo, return error substitute( "$proc-load-bar-code(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-bar-code .
    end.
    create wt-bar-code.
    run nws-impl in p-imp-handle
      ( input 'bar-code':U
       ,input (buffer wt-bar-code:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-bar-code
      where tb-bar-code.b-code = wt-bar-code.b-code
      exclusive-lock no-error.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create-bar-code in p-imp-handle
  ( input wt-bar-code.b-code
   ,input wt-bar-code.cli-base-rate
   ,input wt-bar-code.gds-code
   ,input wt-bar-code.in-code
   ,input wt-bar-code.node-code
   ,input wt-bar-code.part-code
   ,input wt-bar-code.unit-cli
   ,input wt-bar-code.cr-db-num
  ).
    delete wt-bar-code.
  end.
END PROCEDURE.
define temp-table locb-buyer-group             no-undo like  ub.buyer-group.
define temp-table locb-c-buyer-group           no-undo like  ub.c-buyer-group.
define temp-table wt-buyer-group no-undo like ub.buyer-group.
PROCEDURE proc-load-buyer-group:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-buyer-group. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-buyer-group. stop" )
  on endkey undo, return error substitute( "$proc-load-buyer-group. endkey" )
  :
    define buffer tb-buyer-group for ub.buyer-group.
    define variable compare-log as logical no-undo.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_buyer-group          for ub.buyer-group.
define buffer buf_c-buyer-group        for ub.c-buyer-group.
define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.
for each locb-buyer-group
on error  undo, return error
:
  delete locb-buyer-group.
end.
for each locb-c-buyer-group
on error  undo, return error
:
  delete locb-c-buyer-group.
end.
    for each wt-buyer-group
    on error undo, return error substitute( "$proc-load-buyer-group(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-buyer-group .
    end.
    create wt-buyer-group.
    run nws-impl in p-imp-handle
      ( input 'buyer-group':U
       ,input (buffer wt-buyer-group:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-buyer-group
      where tb-buyer-group.bgr-id = wt-buyer-group.bgr-id
        and tb-buyer-group.bgr-db-num = wt-buyer-group.bgr-db-num
      exclusive-lock no-error.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "c-buyer-group" then do:
      create locb-c-buyer-group.
run nws-impl in p-imp-handle
  ( input "c-buyer-group":U
   ,input (buffer locb-c-buyer-group:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_c-buyer-group where buf_c-buyer-group.bgr-id = wt-buyer-group.bgr-id
                             and buf_c-buyer-group.bgr-db-num = wt-buyer-group.bgr-db-num
on error  undo, return error
:
  delete buf_c-buyer-group.
end.
for each locb-c-buyer-group where locb-c-buyer-group.bgr-id     = wt-buyer-group.bgr-id
                              and locb-c-buyer-group.bgr-db-num = wt-buyer-group.bgr-db-num
  no-lock
on error  undo, return error
:
  create buf_c-buyer-group.
  buffer-copy  locb-c-buyer-group to buf_c-buyer-group.
end.
if not available tb-buyer-group then do:
  create tb-buyer-group.
end.
buffer-copy wt-buyer-group to tb-buyer-group.
for each locb-c-buyer-group
on error  undo, return error
:
  delete locb-c-buyer-group.
end.
    delete wt-buyer-group.
  end.
END PROCEDURE.
define temp-table locb-buyer-in-buyer-group    no-undo like  ub.buyer-in-buyer-group.
define temp-table locb-c-buyer-in-buyer-group  no-undo like  ub.c-buyer-in-buyer-group.
define temp-table wt-buyer-in-buyer-group no-undo like ub.buyer-in-buyer-group.
PROCEDURE proc-load-buyer-in-buyer-group:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-buyer-in-buyer-group. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-buyer-in-buyer-group. stop" )
  on endkey undo, return error substitute( "$proc-load-buyer-in-buyer-group. endkey" )
  :
    define buffer tb-buyer-in-buyer-group for ub.buyer-in-buyer-group.
    define variable compare-log as logical no-undo.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_buyer-in-buyer-group   for ub.buyer-in-buyer-group.
define buffer buf_c-buyer-in-buyer-group for ub.c-buyer-in-buyer-group.
define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.
for each locb-buyer-in-buyer-group
on error  undo, return error
:
  delete locb-buyer-in-buyer-group.
end.
for each locb-c-buyer-in-buyer-group
on error  undo, return error
:
  delete locb-c-buyer-in-buyer-group.
end.
    for each wt-buyer-in-buyer-group
    on error undo, return error substitute( "$proc-load-buyer-in-buyer-group(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-buyer-in-buyer-group .
    end.
    create wt-buyer-in-buyer-group.
    run nws-impl in p-imp-handle
      ( input 'buyer-in-buyer-group':U
       ,input (buffer wt-buyer-in-buyer-group:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-buyer-in-buyer-group
      where tb-buyer-in-buyer-group.bgr-id = wt-buyer-in-buyer-group.bgr-id
        and tb-buyer-in-buyer-group.bgr-db-num = wt-buyer-in-buyer-group.bgr-db-num
        and tb-buyer-in-buyer-group.bbg-obj-type = wt-buyer-in-buyer-group.bbg-obj-type
        and tb-buyer-in-buyer-group.bbg-obj-code = wt-buyer-in-buyer-group.bbg-obj-code
      exclusive-lock no-error.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "c-buyer-in-buyer-group" then do:
      create locb-c-buyer-in-buyer-group.
run nws-impl in p-imp-handle
  ( input "c-buyer-in-buyer-group":U
   ,input (buffer locb-c-buyer-in-buyer-group:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_c-buyer-in-buyer-group where buf_c-buyer-in-buyer-group.bgr-id     = wt-buyer-in-buyer-group.bgr-id
                                      and buf_c-buyer-in-buyer-group.bgr-db-num = wt-buyer-in-buyer-group.bgr-db-num
                                      and buf_c-buyer-in-buyer-group.bbg-obj-type = wt-buyer-in-buyer-group.bbg-obj-type
                                      and buf_c-buyer-in-buyer-group.bbg-obj-code = wt-buyer-in-buyer-group.bbg-obj-code
on error  undo, return error
:
  delete buf_c-buyer-in-buyer-group.
end.
for each locb-c-buyer-in-buyer-group where locb-c-buyer-in-buyer-group.bgr-id       = wt-buyer-in-buyer-group.bgr-id
                                       and locb-c-buyer-in-buyer-group.bgr-db-num   = wt-buyer-in-buyer-group.bgr-db-num
                                       and locb-c-buyer-in-buyer-group.bbg-obj-type = wt-buyer-in-buyer-group.bbg-obj-type
                                       and locb-c-buyer-in-buyer-group.bbg-obj-code = wt-buyer-in-buyer-group.bbg-obj-code
no-lock
on error  undo, return error
:
  create buf_c-buyer-in-buyer-group.
  buffer-copy locb-c-buyer-in-buyer-group to buf_c-buyer-in-buyer-group.
end.
if not available tb-buyer-in-buyer-group then do:
  create tb-buyer-in-buyer-group.
end.
buffer-copy wt-buyer-in-buyer-group to tb-buyer-in-buyer-group.
for each locb-c-buyer-in-buyer-group
on error  undo, return error
:
  delete locb-c-buyer-in-buyer-group.
end.
    delete wt-buyer-in-buyer-group.
  end.
END PROCEDURE.
define temp-table wt-cash-pay no-undo like ub.cash-pay.
PROCEDURE proc-load-cash-pay:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-cash-pay. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-cash-pay. stop" )
  on endkey undo, return error substitute( "$proc-load-cash-pay. endkey" )
  :
    define buffer tb-cash-pay for ub.cash-pay.
    define variable compare-log as logical no-undo.
    for each wt-cash-pay
    on error undo, return error substitute( "$proc-load-cash-pay(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-cash-pay .
    end.
    create wt-cash-pay.
    run nws-impl in p-imp-handle
      ( input 'cash-pay':U
       ,input (buffer wt-cash-pay:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-cash-pay
      where tb-cash-pay.cdpay-code = wt-cash-pay.cdpay-code
        and tb-cash-pay.curr-code = wt-cash-pay.curr-code
      exclusive-lock no-error.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if not available tb-cash-pay then do:
  create tb-cash-pay.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-cash-pay TO wt-cash-pay case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-cash-pay TO tb-cash-pay.
  run fill-cash-pay in p-imp-handle (input tb-cash-pay.cdpay-code
                                    ,input tb-cash-pay.curr-code
                                     ).
end.
    delete wt-cash-pay.
  end.
END PROCEDURE.
define temp-table wt-cash-pay-attr no-undo like ub.cash-pay-attr.
PROCEDURE proc-load-cash-pay-attr:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-cash-pay-attr. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-cash-pay-attr. stop" )
  on endkey undo, return error substitute( "$proc-load-cash-pay-attr. endkey" )
  :
    define buffer tb-cash-pay-attr for ub.cash-pay-attr.
    define variable compare-log as logical no-undo.
    for each wt-cash-pay-attr
    on error undo, return error substitute( "$proc-load-cash-pay-attr(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-cash-pay-attr .
    end.
    create wt-cash-pay-attr.
    run nws-impl in p-imp-handle
      ( input 'cash-pay-attr':U
       ,input (buffer wt-cash-pay-attr:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-cash-pay-attr
      where tb-cash-pay-attr.cdpay-code = wt-cash-pay-attr.cdpay-code
        and tb-cash-pay-attr.curr-code = wt-cash-pay-attr.curr-code
        and tb-cash-pay-attr.host-code = wt-cash-pay-attr.host-code
        and tb-cash-pay-attr.obj-type = wt-cash-pay-attr.obj-type
        and tb-cash-pay-attr.obj-code = wt-cash-pay-attr.obj-code
        and tb-cash-pay-attr.attr-code = wt-cash-pay-attr.attr-code
      exclusive-lock no-error.
    define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile: cshpattr.i $ $Revision: 1b25beb36074, 2902, rls $".
if not available tb-cash-pay-attr then do:
  create tb-cash-pay-attr.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-cash-pay-attr TO wt-cash-pay-attr case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-cash-pay-attr TO tb-cash-pay-attr.
  run fill-cash-pay in p-imp-handle (input tb-cash-pay-attr.cdpay-code
                                    ,input tb-cash-pay-attr.curr-code
                                     ).
end.
    delete wt-cash-pay-attr.
  end.
END PROCEDURE.
define temp-table locb2-c-chk-gds     no-undo like ub.c-chk-gds.
define temp-table locb2-c-chk-pay     no-undo like ub.c-chk-pay.
define temp-table locb2-c-chk-discnt  no-undo like ub.c-chk-discnt.
define temp-table locb2-c-chk-doc-attr  no-undo like ub.c-chk-doc-attr.
define temp-table wt-c-chk-doc no-undo like ub.c-chk-doc.
PROCEDURE proc-load-c-chk-doc:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-c-chk-doc. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-c-chk-doc. stop" )
  on endkey undo, return error substitute( "$proc-load-c-chk-doc. endkey" )
  :
    define buffer tb-c-chk-doc for ub.c-chk-doc.
    define variable compare-log as logical no-undo.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_c-chk-gds         for ub.c-chk-gds.
define buffer buf_c-chk-pay         for ub.c-chk-pay.
define buffer buf_c-chk-discnt      for ub.c-chk-discnt.
define buffer buf_c-chk-doc-attr    for ub.c-chk-doc-attr.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
for each locb2-c-chk-gds
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-chk-gds.
end.
for each locb2-c-chk-pay
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-chk-pay.
end.
for each locb2-c-chk-discnt
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-chk-discnt.
end.
for each locb2-c-chk-doc-attr
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-chk-doc-attr.
end.
    for each wt-c-chk-doc
    on error undo, return error substitute( "$proc-load-c-chk-doc(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-c-chk-doc .
    end.
    create wt-c-chk-doc.
    run nws-impl in p-imp-handle
      ( input 'c-chk-doc':U
       ,input (buffer wt-c-chk-doc:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-c-chk-doc
      where tb-c-chk-doc.doc-code = wt-c-chk-doc.doc-code
        and tb-c-chk-doc.corr-user-db-num = wt-c-chk-doc.corr-user-db-num
        and tb-c-chk-doc.chip-num = wt-c-chk-doc.chip-num
      exclusive-lock no-error.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "c-chk-gds" then do:
      create locb2-c-chk-gds.
run nws-impl in p-imp-handle
  ( input "c-chk-gds":U
   ,input (buffer locb2-c-chk-gds:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-chk-pay" then do:
      create locb2-c-chk-pay.
run nws-impl in p-imp-handle
  ( input "c-chk-pay":U
   ,input (buffer locb2-c-chk-pay:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-chk-discnt" then do:
      create locb2-c-chk-discnt.
run nws-impl in p-imp-handle
  ( input "c-chk-discnt":U
   ,input (buffer locb2-c-chk-discnt:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-chk-doc-attr" then do:
      create locb2-c-chk-doc-attr.
run nws-impl in p-imp-handle
  ( input "c-chk-doc-attr":U
   ,input (buffer locb2-c-chk-doc-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе истории чека"
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
if not available tb-c-chk-doc then do:
  create tb-c-chk-doc.
end.
buffer-copy wt-c-chk-doc to tb-c-chk-doc.
for each buf_c-chk-doc-attr where
        buf_c-chk-doc-attr.doc-code = wt-c-chk-doc.doc-code
   AND  buf_c-chk-doc-attr.chip-num = wt-c-chk-doc.chip-num
on error  undo, return error
:
  delete buf_c-chk-doc-attr.
end.
for each locb2-c-chk-doc-attr where
        locb2-c-chk-doc-attr.doc-code = wt-c-chk-doc.doc-code
   AND  locb2-c-chk-doc-attr.chip-num = wt-c-chk-doc.chip-num   no-lock
on error  undo, return error
:
  create buf_c-chk-doc-attr.
  buffer-copy locb2-c-chk-doc-attr to buf_c-chk-doc-attr.
end.
for each buf_c-chk-gds where
        buf_c-chk-gds.doc-code = wt-c-chk-doc.doc-code
   AND  buf_c-chk-gds.chip-num = wt-c-chk-doc.chip-num
on error  undo, return error
:
  delete buf_c-chk-gds.
end.
for each locb2-c-chk-gds where
        locb2-c-chk-gds.doc-code = wt-c-chk-doc.doc-code
   AND  locb2-c-chk-gds.chip-num = wt-c-chk-doc.chip-num    no-lock
on error  undo, return error
:
  create buf_c-chk-gds.
  buffer-copy locb2-c-chk-gds to buf_c-chk-gds.
end.
for each buf_c-chk-pay where
        buf_c-chk-pay.doc-code = wt-c-chk-doc.doc-code
    AND buf_c-chk-pay.chip-num = wt-c-chk-doc.chip-num
on error  undo, return error
:
  delete buf_c-chk-pay.
end.
for each locb2-c-chk-pay where
        locb2-c-chk-pay.doc-code = wt-c-chk-doc.doc-code
    AND locb2-c-chk-pay.chip-num = wt-c-chk-doc.chip-num   no-lock
on error  undo, return error
:
  create buf_c-chk-pay.
  buffer-copy locb2-c-chk-pay to buf_c-chk-pay.
end.
for each buf_c-chk-discnt where
       buf_c-chk-discnt.doc-code = wt-c-chk-doc.doc-code
   AND buf_c-chk-discnt.chip-num = wt-c-chk-doc.chip-num
on error  undo, return error
:
  delete buf_c-chk-discnt.
end.
for each locb2-c-chk-discnt where
        locb2-c-chk-discnt.doc-code = wt-c-chk-doc.doc-code
    AND locb2-c-chk-discnt.chip-num = wt-c-chk-doc.chip-num  no-lock
on error  undo, return error
:
  create buf_c-chk-discnt.
  buffer-copy locb2-c-chk-discnt to buf_c-chk-discnt.
end.
for each locb2-c-chk-gds
on error  undo, return error
:
  delete locb2-c-chk-gds.
end.
for each locb2-c-chk-pay
on error  undo, return error
:
  delete locb2-c-chk-pay.
end.
for each locb2-c-chk-discnt
on error  undo, return error
:
  delete locb2-c-chk-discnt.
end.
for each locb2-c-chk-doc-attr
on error  undo, return error
:
  delete locb2-c-chk-doc-attr.
end.
    delete wt-c-chk-doc.
  end.
END PROCEDURE.
define temp-table wt-clients no-undo like ub.clients.
PROCEDURE proc-load-clients:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-clients. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-clients. stop" )
  on endkey undo, return error substitute( "$proc-load-clients. endkey" )
  :
    define buffer tb-clients for ub.clients.
    define variable compare-log as logical no-undo.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_cli-grp  for ub.cli-grp .
define buffer buf_dis-card for ub.dis-card .
define variable v-l as logical no-undo .
    for each wt-clients
    on error undo, return error substitute( "$proc-load-clients(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-clients .
    end.
    create wt-clients.
    run nws-impl in p-imp-handle
      ( input 'clients':U
       ,input (buffer wt-clients:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-clients
      where tb-clients.obj-type = wt-clients.obj-type
        and tb-clients.obj-code = wt-clients.obj-code
      exclusive-lock no-error.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  if not can-find(buf_cli-grp where buf_cli-grp.node-code = wt-clients.grp-code)
      and g#db-num = 0 then do:
    run write-to-log in this-procedure (input " В БД нет группы для клиента " + wt-clients.obj-name + " ("
                      + wt-clients.obj-type + " " + string( wt-clients.obj-code ) + ") "
                    ).
    return error.
  end.
  if can-find(buf_cli-grp where buf_cli-grp.upper-code = wt-clients.grp-code)
      and g#db-num = 0 then do:
    run write-to-log in this-procedure (input " В ГБД есть подгруппа в группе клиента " + wt-clients.obj-name + " ("
                      + wt-clients.obj-type + " " + string( wt-clients.obj-code ) + ")."
                    ).
    return error.
  end.
if not available tb-clients then do:
  create tb-clients.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-clients TO wt-clients case-sensitive save result in compare-log no-error.
  buffer-compare tb-clients using obj-name TO wt-clients case-sensitive save result in v-l no-error.
end.
if not compare-log then do:
  buffer-copy wt-clients TO tb-clients .
  if
  not (tb-clients.obj-type = 'маг':U or tb-clients.obj-type = 'скл':U)
  and not v-l then do:
    for each buf_dis-card where
             buf_dis-card.cli-type = tb-clients.obj-type
         AND buf_dis-card.cli-code = tb-clients.obj-code:
      run fill-dc-list in p-imp-handle ( buffer buf_Dis-card) .
    end.
  end.
end.
    delete wt-clients.
  end.
END PROCEDURE.
define temp-table wt-clients-attr no-undo like ub.clients-attr.
PROCEDURE proc-load-clients-attr:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-clients-attr. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-clients-attr. stop" )
  on endkey undo, return error substitute( "$proc-load-clients-attr. endkey" )
  :
    define buffer tb-clients-attr for ub.clients-attr.
    define variable compare-log as logical no-undo.
    for each wt-clients-attr
    on error undo, return error substitute( "$proc-load-clients-attr(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-clients-attr .
    end.
    create wt-clients-attr.
    run nws-impl in p-imp-handle
      ( input 'clients-attr':U
       ,input (buffer wt-clients-attr:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-clients-attr
      where tb-clients-attr.obj-type = wt-clients-attr.obj-type
        and tb-clients-attr.obj-code = wt-clients-attr.obj-code
        and tb-clients-attr.attr-code = wt-clients-attr.attr-code
      exclusive-lock no-error.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if not available tb-clients-attr then do:
   create tb-clients-attr.
   assign compare-log = no.
end.
else do:
   buffer-compare tb-clients-attr TO wt-clients-attr case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
   buffer-copy wt-clients-attr TO tb-clients-attr.
   if wt-clients-attr.attr-code = "envd" then do:
      for each tax-rate-attr where
               tax-rate-attr.attr-code = wt-clients-attr.attr-code
      no-lock,
          each tax-rate-gds where
               tax-rate-gds.tax-code  = tax-rate-attr.tax-code
           and tax-rate-gds.rate-code = tax-rate-attr.rate-code
           and tax-rate-gds.fact-date <= today
      no-lock:
         run fill-g-list in p-imp-handle (tax-rate-gds.gds-code,
                                          wt-clients-attr.obj-type,
                                          wt-clients-attr.obj-code).
      end.
   end.
end.
    delete wt-clients-attr.
  end.
END PROCEDURE.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table locb-contract-line no-undo like ub.contract-line.
define temp-table wt-contract no-undo like ub.contract.
PROCEDURE proc-load-contract:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-contract. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-contract. stop" )
  on endkey undo, return error substitute( "$proc-load-contract. endkey" )
  :
    define buffer tb-contract for ub.contract.
    define variable compare-log as logical no-undo.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_contract-line for ub.contract-line.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-contract-line
on error undo, return error error-status :get-message (1)
:
  delete locb-contract-line.
end.
    for each wt-contract
    on error undo, return error substitute( "$proc-load-contract(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-contract .
    end.
    create wt-contract.
    run nws-impl in p-imp-handle
      ( input 'contract':U
       ,input (buffer wt-contract:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-contract
      where tb-contract.host-code = wt-contract.host-code
        and tb-contract.contract-code = wt-contract.contract-code
      exclusive-lock no-error.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "contract-line" then do:
      create locb-contract-line.
run nws-impl in p-imp-handle
  ( input "contract-line":U
   ,input (buffer locb-contract-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip "в составе договора." view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_contract-line where buf_contract-line.contract-num = wt-contract.contract-code and
                              buf_contract-line.host-code = wt-contract.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_contract-line.
end.
for each locb-contract-line where locb-contract-line.contract-num = wt-contract.contract-code and
                               locb-contract-line.host-code = wt-contract.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_contract-line.
  buffer-copy locb-contract-line to buf_contract-line.
end.
if not available tb-contract then do:
  create tb-contract.
end.
buffer-copy wt-contract to tb-contract.
for each locb-contract-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-contract-line.
end.
    delete wt-contract.
  end.
END PROCEDURE.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table locb-c-contract-line no-undo like ub.c-contract-line.
define temp-table wt-c-contract no-undo like ub.c-contract.
PROCEDURE proc-load-c-contract:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-c-contract. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-c-contract. stop" )
  on endkey undo, return error substitute( "$proc-load-c-contract. endkey" )
  :
    define buffer tb-c-contract for ub.c-contract.
    define variable compare-log as logical no-undo.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_c-contract-line for ub.c-contract-line.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-c-contract-line
on error undo, return error error-status :get-message (1)
:
  delete locb-c-contract-line.
end.
    for each wt-c-contract
    on error undo, return error substitute( "$proc-load-c-contract(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-c-contract .
    end.
    create wt-c-contract.
    run nws-impl in p-imp-handle
      ( input 'c-contract':U
       ,input (buffer wt-c-contract:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-c-contract
      where tb-c-contract.host-code = wt-c-contract.host-code
        and tb-c-contract.contract-code = wt-c-contract.contract-code
        and tb-c-contract.corr-user-db-num = wt-c-contract.corr-user-db-num
        and tb-c-contract.chip-num = wt-c-contract.chip-num
      exclusive-lock no-error.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "c-contract-line" then do:
      create locb-c-contract-line.
run nws-impl in p-imp-handle
  ( input "c-contract-line":U
   ,input (buffer locb-c-contract-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе истории договора."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_c-contract-line where buf_c-contract-line.contract-num = wt-c-contract.contract-code and
                              buf_c-contract-line.host-code = wt-c-contract.host-code  and
                              buf_c-contract-line.corr-user-db-num  = wt-c-contract.corr-user-db-num  and
                              buf_c-contract-line.chip-num  = wt-c-contract.chip-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-contract-line.
end.
for each locb-c-contract-line where locb-c-contract-line.contract-num = wt-c-contract.contract-code and
                               locb-c-contract-line.host-code = wt-c-contract.host-code  and
                               locb-c-contract-line.corr-user-db-num  = wt-c-contract.corr-user-db-num  and
                               locb-c-contract-line.chip-num = wt-c-contract.chip-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-contract-line.
  buffer-copy locb-c-contract-line to buf_c-contract-line.
end.
if not available tb-c-contract then do:
  create tb-c-contract.
end.
buffer-copy wt-c-contract to tb-c-contract.
for each locb-c-contract-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-contract-line.
end.
    delete wt-c-contract.
  end.
END PROCEDURE.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table locb-contract-specif-attr no-undo like ub.contract-specif-attr.
define temp-table wt-contract-specif no-undo like ub.contract-specif.
PROCEDURE proc-load-contract-specif:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-contract-specif. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-contract-specif. stop" )
  on endkey undo, return error substitute( "$proc-load-contract-specif. endkey" )
  :
    define buffer tb-contract-specif for ub.contract-specif.
    define variable compare-log as logical no-undo.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_contract-specif-attr for ub.contract-specif-attr.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-contract-specif-attr
on error undo, return error error-status :get-message (1)
:
  delete locb-contract-specif-attr.
end.
    for each wt-contract-specif
    on error undo, return error substitute( "$proc-load-contract-specif(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-contract-specif .
    end.
    create wt-contract-specif.
    run nws-impl in p-imp-handle
      ( input 'contract-specif':U
       ,input (buffer wt-contract-specif:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-contract-specif
      where tb-contract-specif.host-code = wt-contract-specif.host-code
        and tb-contract-specif.contract-num = wt-contract-specif.contract-num
        and tb-contract-specif.gds-code = wt-contract-specif.gds-code
      exclusive-lock no-error.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "contract-specif-attr" then do:
      create locb-contract-specif-attr.
run nws-impl in p-imp-handle
  ( input "contract-specif-attr":U
   ,input (buffer locb-contract-specif-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip "в составе договора." view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_contract-specif-attr
  where buf_contract-specif-attr.contract-num = wt-contract-specif.contract-num
    and buf_contract-specif-attr.host-code    = wt-contract-specif.host-code
    and buf_contract-specif-attr.gds-code     = wt-contract-specif.gds-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info31, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete buf_contract-specif-attr.
end.
for each locb-contract-specif-attr no-lock
  where locb-contract-specif-attr.contract-num = wt-contract-specif.contract-num
    and locb-contract-specif-attr.host-code    = wt-contract-specif.host-code
    and locb-contract-specif-attr.gds-code     = wt-contract-specif.gds-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info31, return-value, chr(10), error-status :get-message ( 1 ) )
:
  create buf_contract-specif-attr.
  buffer-copy locb-contract-specif-attr to buf_contract-specif-attr.
end.
if not available tb-contract-specif then do:
  create tb-contract-specif.
end.
buffer-copy wt-contract-specif to tb-contract-specif.
for each locb-contract-specif-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info31, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete locb-contract-specif-attr.
end.
    delete wt-contract-specif.
  end.
END PROCEDURE.
define temp-table wt-db no-undo like ub.db.
PROCEDURE proc-load-db:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-db. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-db. stop" )
  on endkey undo, return error substitute( "$proc-load-db. endkey" )
  :
    define buffer tb-db for ub.db.
    define variable compare-log as logical no-undo.
    for each wt-db
    on error undo, return error substitute( "$proc-load-db(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-db .
    end.
    create wt-db.
    run nws-impl in p-imp-handle
      ( input 'db':U
       ,input (buffer wt-db:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-db
      where tb-db.db-num = wt-db.db-num
      exclusive-lock no-error.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if wt-db.db-num = g#db-num and g#db-num <> 0 and available tb-db then do:
  assign
    wt-db.db-key     = tb-db.db-key
    wt-db.db-key-enc = tb-db.db-key-enc
    .
end.
if not available tb-db then do:
  create tb-db.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-db TO wt-db case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-db TO tb-db.
end.
    delete wt-db.
  end.
END PROCEDURE.
define temp-table wt-db-status no-undo like ub.db-status.
PROCEDURE proc-load-db-status:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-db-status. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-db-status. stop" )
  on endkey undo, return error substitute( "$proc-load-db-status. endkey" )
  :
    define buffer tb-db-status for ub.db-status.
    define variable compare-log as logical no-undo.
    for each wt-db-status
    on error undo, return error substitute( "$proc-load-db-status(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-db-status .
    end.
    create wt-db-status.
    run nws-impl in p-imp-handle
      ( input 'db-status':U
       ,input (buffer wt-db-status:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-db-status
      where tb-db-status.db-num = wt-db-status.db-num
      exclusive-lock no-error.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if wt-db-status.db-num = g#db-num and g#db-num <> 0 then do:
  assign
    wt-db-status.stock-date = TODAY
    wt-db-status.stock-time = TIME
    .
  if available tb-db-status then do:
    assign
      wt-db-status.fact-num = tb-db-status.fact-num
      .
  end.
end.
if not available tb-db-status then do:
  create tb-db-status.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-db-status TO wt-db-status case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-db-status TO tb-db-status.
end.
    delete wt-db-status.
  end.
END PROCEDURE.
define temp-table wt-dis-card no-undo like ub.dis-card.
PROCEDURE proc-load-dis-card:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-dis-card. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-dis-card. stop" )
  on endkey undo, return error substitute( "$proc-load-dis-card. endkey" )
  :
    define buffer tb-dis-card for ub.dis-card.
    define variable compare-log as logical no-undo.
    for each wt-dis-card
    on error undo, return error substitute( "$proc-load-dis-card(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-dis-card .
    end.
    create wt-dis-card.
    run nws-impl in p-imp-handle
      ( input 'dis-card':U
       ,input (buffer wt-dis-card:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-dis-card
      where tb-dis-card.d-card = wt-dis-card.d-card
      exclusive-lock no-error.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if not available tb-dis-card then do:
  create tb-dis-card.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-dis-card TO wt-dis-card case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  if g#db-num = 0 and lookup( tb-dis-card.status_ , ('смкли':U + chr(44) + 'неисп':U)) > 0  then do:   buffer-copy wt-dis-card     except wt-dis-card.status_     to tb-dis-card. end. else do:   buffer-copy wt-dis-card to tb-dis-card. end.
  run fill-dc-list in p-imp-handle ( buffer tb-Dis-card) .
end.
    delete wt-dis-card.
  end.
END PROCEDURE.
define temp-table wt-dis-card-mask no-undo like ub.dis-card-mask.
PROCEDURE proc-load-dis-card-mask:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-dis-card-mask. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-dis-card-mask. stop" )
  on endkey undo, return error substitute( "$proc-load-dis-card-mask. endkey" )
  :
    define buffer tb-dis-card-mask for ub.dis-card-mask.
    define variable compare-log as logical no-undo.
    for each wt-dis-card-mask
    on error undo, return error substitute( "$proc-load-dis-card-mask(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-dis-card-mask .
    end.
    create wt-dis-card-mask.
    run nws-impl in p-imp-handle
      ( input 'dis-card-mask':U
       ,input (buffer wt-dis-card-mask:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-dis-card-mask
      where tb-dis-card-mask.mask-num = wt-dis-card-mask.mask-num
      exclusive-lock no-error.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if not available tb-dis-card-mask then do:
  create tb-dis-card-mask.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-dis-card-mask TO wt-dis-card-mask case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  if g#db-num = 0 then do:   buffer-copy wt-dis-card-mask     to tb-dis-card-mask. end. else do:   buffer-copy wt-dis-card-mask to tb-dis-card-mask. end.
  run fill-dc-list-mask in p-imp-handle ( buffer tb-dis-card-mask) .
end.
    delete wt-dis-card-mask.
  end.
END PROCEDURE.
define temp-table wt-dis-card-mask-attr no-undo like ub.dis-card-mask-attr.
PROCEDURE proc-load-dis-card-mask-attr:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-dis-card-mask-attr. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-dis-card-mask-attr. stop" )
  on endkey undo, return error substitute( "$proc-load-dis-card-mask-attr. endkey" )
  :
    define buffer tb-dis-card-mask-attr for ub.dis-card-mask-attr.
    define variable compare-log as logical no-undo.
    for each wt-dis-card-mask-attr
    on error undo, return error substitute( "$proc-load-dis-card-mask-attr(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-dis-card-mask-attr .
    end.
    create wt-dis-card-mask-attr.
    run nws-impl in p-imp-handle
      ( input 'dis-card-mask-attr':U
       ,input (buffer wt-dis-card-mask-attr:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-dis-card-mask-attr
      where tb-dis-card-mask-attr.mask-num = wt-dis-card-mask-attr.mask-num
        and tb-dis-card-mask-attr.attr-code = wt-dis-card-mask-attr.attr-code
      exclusive-lock no-error.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if not available tb-dis-card-mask-attr then do:
  create tb-dis-card-mask-attr.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-dis-card-mask-attr TO wt-dis-card-mask-attr case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  if g#db-num = 0 then do:   buffer-copy wt-dis-card-mask-attr     to tb-dis-card-mask-attr. end. else do:   buffer-copy wt-dis-card-mask-attr to tb-dis-card-mask-attr. end.
  run fill-dc-list-mask-attr in p-imp-handle ( buffer tb-dis-card-mask-attr) .
end.
    delete wt-dis-card-mask-attr.
  end.
END PROCEDURE.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
define temp-table wt-dis-card-property no-undo like ub.dis-card-property.
PROCEDURE proc-load-dis-card-property:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-dis-card-property. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-dis-card-property. stop" )
  on endkey undo, return error substitute( "$proc-load-dis-card-property. endkey" )
  :
    define buffer tb-dis-card-property for ub.dis-card-property.
    define variable compare-log as logical no-undo.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-nws-to-cd as integer no-undo .
define buffer buf_dis-card for ub.dis-card.
    for each wt-dis-card-property
    on error undo, return error substitute( "$proc-load-dis-card-property(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-dis-card-property .
    end.
    create wt-dis-card-property.
    run nws-impl in p-imp-handle
      ( input 'dis-card-property':U
       ,input (buffer wt-dis-card-property:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-dis-card-property
      where tb-dis-card-property.d-card = wt-dis-card-property.d-card
        and tb-dis-card-property.dt-code = wt-dis-card-property.dt-code
        and tb-dis-card-property.node-code = wt-dis-card-property.node-code
        and tb-dis-card-property.host-code = wt-dis-card-property.host-code
        and tb-dis-card-property.obj-type = wt-dis-card-property.obj-type
        and tb-dis-card-property.obj-code = wt-dis-card-property.obj-code
      exclusive-lock no-error.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if not available tb-dis-card-property then do:
  create tb-dis-card-property.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-dis-card-property TO wt-dis-card-property case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-dis-card-property TO tb-dis-card-property.
  v-nws-to-cd = integer('0':U).
  find first buf_dis-card no-lock where
            buf_dis-card.d-card = tb-dis-card-property.d-card no-error.
  if available buf_dis-card then do:
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'dis-card-property':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  buf_Dis-card.type
  ,input  '':U
  ,input  '':U
  ,input  buf_Dis-card.emitent-host-code
  ,input  tb-dis-card-property.dtm-code
  ,input  0
  ,input  'nws-to-cd'
  ,output v-nws-to-cd
  ) no-error .
    if v-nws-to-cd >= 0 then do:
      run fill-dc-list in p-imp-handle ( buffer buf_Dis-card) .
    end.
  end.
end.
    delete wt-dis-card-property.
  end.
END PROCEDURE.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table locb-dis-gds-rule      no-undo like ub.dis-gds-rule.
define temp-table wt-dis-gds-rule no-undo like ub.dis-gds-rule.
PROCEDURE proc-load-dis-gds-rule:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-dis-gds-rule. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-dis-gds-rule. stop" )
  on endkey undo, return error substitute( "$proc-load-dis-gds-rule. endkey" )
  :
    define buffer tb-dis-gds-rule for ub.dis-gds-rule.
    define variable compare-log as logical no-undo.
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-to-del as logical no-undo .
define buffer buf_goods for ub.goods.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
for each locb-dis-gds-rule
on error undo, return error error-status :get-message (1)
:
  delete locb-dis-gds-rule.
end.
    for each wt-dis-gds-rule
    on error undo, return error substitute( "$proc-load-dis-gds-rule(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-dis-gds-rule .
    end.
    create wt-dis-gds-rule.
    run nws-impl in p-imp-handle
      ( input 'dis-gds-rule':U
       ,input (buffer wt-dis-gds-rule:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-dis-gds-rule
      where tb-dis-gds-rule.obj-type = wt-dis-gds-rule.obj-type
        and tb-dis-gds-rule.obj-code = wt-dis-gds-rule.obj-code
        and tb-dis-gds-rule.gds-code = wt-dis-gds-rule.gds-code
        and tb-dis-gds-rule.pos-type = wt-dis-gds-rule.pos-type
        and tb-dis-gds-rule.discnt-role = wt-dis-gds-rule.discnt-role
        and tb-dis-gds-rule.nonunique = wt-dis-gds-rule.nonunique
      exclusive-lock no-error.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if not available tb-dis-gds-rule then do:
  find first buf_dis-gds-rule where
            buf_dis-gds-rule.obj-type = wt-dis-gds-rule.obj-type
        and buf_dis-gds-rule.obj-code = wt-dis-gds-rule.obj-code
        and buf_dis-gds-rule.discnt-role = wt-dis-gds-rule.discnt-role
        and buf_dis-gds-rule.pos-type = wt-dis-gds-rule.pos-type
        and buf_dis-gds-rule.gds-code = wt-dis-gds-rule.gds-code no-error.
  if available buf_dis-gds-rule then do:
    if (wt-dis-gds-rule.nonunique = ''
    and buf_dis-gds-rule.nonunique <> '') then do:
      v-to-del = yes.
    end.
    if (wt-dis-gds-rule.nonunique <> ''
    and buf_dis-gds-rule.nonunique = '') then do:
      delete buf_dis-gds-rule.
    end.
  end.
  create tb-dis-gds-rule.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-dis-gds-rule TO wt-dis-gds-rule case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-dis-gds-rule TO tb-dis-gds-rule.
  if lookup(wt-dis-gds-rule.pos-type, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA':U) > 0 then do:
      run fill-g-list in p-imp-handle ( input wt-dis-gds-rule.gds-code
                                      ,input wt-dis-gds-rule.obj-type
                                      ,input wt-dis-gds-rule.obj-code
                                      ).
  end.
  if v-to-del then do:
    delete tb-dis-gds-rule.
  end.
end.
    delete wt-dis-gds-rule.
  end.
END PROCEDURE.
define temp-table locb1-dis-rule     no-undo like ub.dis-rule.
def var vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-drt-prop no-undo like ub.drt-prop.
procedure disrules-fill-properties:
define input  parameter p-templ-rl-root as integer   no-undo .
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_temp-drt-prop for temp-drt-prop.
do
on error undo, return error return-value
:
  for each buf_temp-drt-prop:
    delete buf_temp-drt-prop.
  end.
  for each buf_drt-prop where buf_drt-prop.templ-rl-root = p-templ-rl-root:
    create buf_temp-drt-prop.
    buffer-copy buf_drt-prop to buf_temp-drt-prop.
  end.
end.
end procedure.
~
define temp-table wt-dis-rule no-undo like ub.dis-rule.
PROCEDURE proc-load-dis-rule:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-dis-rule. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-dis-rule. stop" )
  on endkey undo, return error substitute( "$proc-load-dis-rule. endkey" )
  :
    define buffer tb-dis-rule for ub.dis-rule.
    define variable compare-log as logical no-undo.
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ok as logical no-undo .
define buffer buf_dis-rule  for ub.dis-rule .
define buffer template_dis-rule for ub.dis-rule.
define variable h_wt-dis-rule as handle no-undo .
define variable h_buf_dis-rule as handle no-undo .
define variable jj as integer no-undo .
define variable v-uniq-field as character no-undo .
define variable v-curr-field as character no-undo .
define buffer buf1_dis-rule         for ub.dis-rule.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define variable v-gds-send as logical no-undo .
define variable v-dc-send as logical no-undo .
define buffer buf_Dis-card for ub.dis-card.
define buffer buf_goods for ub.goods.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-dc-rule for ub.dis-dc-rule.
for each locb1-dis-rule
on error undo, return error error-status :get-message (1)
:
  delete locb1-dis-rule.
end.
    for each wt-dis-rule
    on error undo, return error substitute( "$proc-load-dis-rule(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-dis-rule .
    end.
    create wt-dis-rule.
    run nws-impl in p-imp-handle
      ( input 'dis-rule':U
       ,input (buffer wt-dis-rule:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-dis-rule
      where tb-dis-rule.rule-num = wt-dis-rule.rule-num
      exclusive-lock no-error.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when 'dis-rule':U then do:
      create locb1-dis-rule.
run nws-impl in p-imp-handle
  ( input "dis-rule":U
   ,input (buffer locb1-dis-rule:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе истории чека"
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
do
on error  undo, return error
on endkey undo, return error
on stop   undo, return error :
  if (available tb-dis-rule
      and tb-dis-rule.rule-num = wt-dis-rule.rule-num
      and (tb-dis-rule.sts  = wt-dis-rule.sts
          OR
          wt-dis-rule.sts <> integer('0':U)
          ))
  or wt-dis-rule.lvl-num = 0
  then do:
    v-ok = yes.
  end.
  if not v-ok then do:
    find first template_dis-rule no-lock where
              template_dis-rule.rule-num = wt-dis-rule.templ-rl-root no-error.
    if not available template_dis-rule then do:
      run write-to-log( substitute("Не найден шаблон №&1 для правила скидок №&2"
                                  , wt-dis-rule.templ-rl-root
                                  , wt-dis-rule.rule-num)).
      return error .
    end.
    if not can-find(first ub.drt-prop no-lock where
                         ub.drt-prop.templ-rl-root = template_dis-rule.templ-rl-root
                     and ub.drt-prop.upper-prop-code = '':U
                     and ub.drt-prop.prop-code = 'uniq':U) then do:
      v-ok = yes.
    end.
    else do:
      v-uniq-field = chr(32) .
    end.
  end.
  if not v-ok then do:
    do jj = 1 to num-entries("discnt-value"):
      assign
      v-curr-field = entry(jj, "discnt-value")
      .
      if can-find(first ub.drt-prop no-lock where
                        ub.drt-prop.templ-rl-root = template_dis-rule.templ-rl-root
                    and ub.drt-prop.upper-prop-code = '':U
                    and ub.drt-prop.prop-code = v-curr-field + 'uniq=':U
                    and ub.drt-prop.property-value  = "yes") then do:
        assign
        v-uniq-field = v-uniq-field + chr(44) + v-curr-field.
      end.
    end.
    v-uniq-field = trim(v-uniq-field, chr(44)).
    if wt-dis-rule.sts = integer('0':U) then do:
      assign
      h_wt-dis-rule = buffer wt-dis-rule:handle
      h_buf_dis-rule = buffer buf_dis-rule:handle
      .
      _dis-rule:
      for each buf_dis-rule where buf_dis-rule.upper-rule-num   = wt-dis-rule.upper-rule-num
                                      and buf_dis-rule.host-code = wt-dis-rule.host-code
                                      and buf_dis-rule.obj-type = wt-dis-rule.obj-type
                                      and buf_dis-rule.obj-code = wt-dis-rule.obj-code
                                      and buf_dis-rule.sts   = integer('0':U)
        on error undo, return error return-value:
        if buf_dis-rule.rule-num = wt-dis-rule.rule-num then next _dis-rule.
        if buf_dis-rule.sts = integer('1':U) then nEXT _dis-rule.
        if v-uniq-field = '':U then do:
          if g#db-num = 0 then do:
            assign
            wt-dis-rule.sts = integer('1':U)
            .
            run write-to-log( substitute("Выключено полученное правило скидки №&1, так как имеется активное правило №&2&3" +                                         "Тип правила: &4"                                                                                                       , wt-dis-rule.rule-num                                                                                                  , buf_dis-rule.rule-num                                                                                                 , chr(10)                                                                                                         , template_dis-rule.des)).
          end.
          else do:
            assign
            buf_dis-rule.sts = integer('1':U)
            .
            run write-to-log( substitute("Выключено правило скидки №&1, так как получено новое активное правило №&2&3" +                                         "Тип правила: &4"                                                                                                       , buf_dis-rule.rule-num                                                                                                 , wt-dis-rule.rule-num                                                                                                  , chr(10)                                                                                                         , template_dis-rule.des)).
          end.
          leave _dis-rule.
        end.
        do jj = 1 to num-entries(v-uniq-field):
          if h_wt-dis-rule:buffer-field(entry(jj, v-uniq-field)):buffer-value = h_buf_dis-rule:buffer-field(entry(jj, v-uniq-field)):buffer-value
          then do:
            if g#db-num = 0 then do:
              assign
              wt-dis-rule.sts = integer('1':U)
              .
              run write-to-log( substitute("Выключено полученное правило скидки №&1, так как имеется активное правило №&2&3" +                                         "Тип правила: &4"                                                                                                       , wt-dis-rule.rule-num                                                                                                  , buf_dis-rule.rule-num                                                                                                 , chr(10)                                                                                                         , template_dis-rule.des)).
            end.
            else do:
              assign
              buf_dis-rule.sts = integer('1':U)
              .
              run write-to-log( substitute("Выключено правило скидки №&1, так как получено новое активное правило №&2&3" +                                         "Тип правила: &4"                                                                                                       , buf_dis-rule.rule-num                                                                                                 , wt-dis-rule.rule-num                                                                                                  , chr(10)                                                                                                         , template_dis-rule.des)).
            end.
          end.
        end.
      end.
    end.
  end.
  if not available tb-dis-rule then do:
    create tb-dis-rule.
  end.
  buffer-copy wt-dis-rule to tb-dis-rule.
end.
if wt-dis-rule.rule-num > 99999 then do:
  for each locb1-dis-rule where
          locb1-dis-rule.upper-rule-num = wt-dis-rule.rule-num
      no-lock
  on error  undo, return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message (1))
  :
    find first buf1_dis-rule exclusive-lock where
              buf1_dis-rule.rule-num = locb1-dis-rule.rule-num no-error.
    if not available buf1_dis-rule then do:
      create buf1_dis-rule.
    end.
    buffer-copy locb1-dis-rule to buf1_dis-rule.
  end.
  for each buf1_dis-rule where
          buf1_dis-rule.upper-rule-num = wt-dis-rule.rule-num
  on error  undo, return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message (1))
  :
    find first locb1-dis-rule exclusive-lock where
              locb1-dis-rule.rule-num = buf1_dis-rule.rule-num no-error.
    if not available locb1-dis-rule then do:
      if wt-dis-rule.upper-rule-num <> 0 then do:
        delete buf1_dis-rule.
      end.
    end.
  end.
end.
for each locb1-dis-rule
on error  undo, return error
:
  delete locb1-dis-rule.
end.
for each buf_dis-cfg-rule no-lock where
        buf_dis-cfg-rule.templ-rl-root = tb-dis-rule.templ-rl-root
    and buf_dis-cfg-rule.time-templ-rl-root = tb-dis-rule.time-templ-rl-root:
  if buf_dis-cfg-rule.table-name = 'dis-gds-rule':U
  and lookup(buf_dis-cfg-rule.pos-type, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA':U) > 0 then do:
    v-gds-send = yes.
  end.
  if buf_dis-cfg-rule.table-name = 'dis-dc-rule':U
  and lookup(buf_dis-cfg-rule.pos-type, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA':U) > 0 then do:
    v-dc-send = yes.
  end.
  if v-gds-send
  or v-dc-send then leave.
end.
if v-gds-send then do:
  for each buf_dis-gds-rule no-lock where
          buf_Dis-gds-rule.rule-num = tb-dis-rule.rule-num:
    if lookup(buf_dis-gds-rule.pos-type, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA':U) > 0 then do:
      run fill-g-list in p-imp-handle ( input buf_dis-gds-rule.gds-code
                                      ,input buf_dis-gds-rule.obj-type
                                      ,input buf_dis-gds-rule.obj-code
                                      ).
    end.
  end.
end.
if v-dc-send then do:
  for each buf_dis-dc-rule no-lock where
          buf_dis-dc-rule.rule-num = tb-dis-rule.rule-num,
      first buf_Dis-card no-lock where
           buf_Dis-card.d-card = buf_dis-dc-rule.d-card:
    run fill-dc-list in p-imp-handle ( buffer buf_Dis-card) .
  end.
end.
    delete wt-dis-rule.
  end.
END PROCEDURE.
define temp-table locb1-dis-time-rule     no-undo like ub.dis-time-rule.
define temp-table wt-dis-time-rule no-undo like ub.dis-time-rule.
PROCEDURE proc-load-dis-time-rule:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-dis-time-rule. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-dis-time-rule. stop" )
  on endkey undo, return error substitute( "$proc-load-dis-time-rule. endkey" )
  :
    define buffer tb-dis-time-rule for ub.dis-time-rule.
    define variable compare-log as logical no-undo.
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf1_dis-time-rule         for ub.dis-time-rule.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
def var vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
for each locb1-dis-time-rule
on error undo, return error error-status :get-message (1)
:
  delete locb1-dis-time-rule.
end.
    for each wt-dis-time-rule
    on error undo, return error substitute( "$proc-load-dis-time-rule(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-dis-time-rule .
    end.
    create wt-dis-time-rule.
    run nws-impl in p-imp-handle
      ( input 'dis-time-rule':U
       ,input (buffer wt-dis-time-rule:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-dis-time-rule
      where tb-dis-time-rule.time-rule-num = wt-dis-time-rule.time-rule-num
      exclusive-lock no-error.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "dis-time-rule" then do:
      create locb1-dis-time-rule.
run nws-impl in p-imp-handle
  ( input "dis-time-rule":U
   ,input (buffer locb1-dis-time-rule:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе истории чека"
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
if not available tb-dis-time-rule then do:
  create tb-dis-time-rule.
end.
buffer-copy wt-dis-time-rule to tb-dis-time-rule.
if wt-dis-time-rule.time-rule-num > 99999 then do:
for each buf1_dis-time-rule where
        buf1_dis-time-rule.upper-time-rule-num = wt-dis-time-rule.time-rule-num
on error  undo, return error
:
    if wt-dis-time-rule.upper-time-rule-num <> 50000 then do:
  delete buf1_dis-time-rule.
end.
  end.
for each locb1-dis-time-rule where
        locb1-dis-time-rule.upper-time-rule-num = wt-dis-time-rule.time-rule-num
     no-lock
on error  undo, return error
:
    find first buf1_dis-time-rule exclusive-lock where
              buf1_dis-time-rule.time-rule-num = locb1-dis-time-rule.time-rule-num no-error.
    if not available buf1_dis-time-rule then do:
  create buf1_dis-time-rule.
    end.
  buffer-copy locb1-dis-time-rule to buf1_dis-time-rule.
end.
end.
for each locb1-dis-time-rule
on error  undo, return error
:
  delete locb1-dis-time-rule.
end.
    delete wt-dis-time-rule.
  end.
END PROCEDURE.
define temp-table locb-doc-abc-def-obj  no-undo like ub.doc-abc-def-obj.
define temp-table locb-doc-abc-def-doc  no-undo like ub.doc-abc-def-doc.
define temp-table wt-doc-abc-def no-undo like ub.doc-abc-def.
PROCEDURE proc-load-doc-abc-def:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-doc-abc-def. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-doc-abc-def. stop" )
  on endkey undo, return error substitute( "$proc-load-doc-abc-def. endkey" )
  :
    define buffer tb-doc-abc-def for ub.doc-abc-def.
    define variable compare-log as logical no-undo.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_doc-abc-def-obj  for ub.doc-abc-def-obj.
define buffer buf_doc-abc-def-doc  for ub.doc-abc-def-doc.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-doc-abc-def-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-doc-abc-def-doc.
end.
for each locb-doc-abc-def-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-doc-abc-def-obj.
end.
    for each wt-doc-abc-def
    on error undo, return error substitute( "$proc-load-doc-abc-def(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-doc-abc-def .
    end.
    create wt-doc-abc-def.
    run nws-impl in p-imp-handle
      ( input 'doc-abc-def':U
       ,input (buffer wt-doc-abc-def:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-doc-abc-def
      where tb-doc-abc-def.doad-id = wt-doc-abc-def.doad-id
        and tb-doc-abc-def.db-num = wt-doc-abc-def.db-num
      exclusive-lock no-error.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "doc-abc-def-obj" then do:
      create locb-doc-abc-def-obj.
run nws-impl in p-imp-handle
  ( input "doc-abc-def-obj":U
   ,input (buffer locb-doc-abc-def-obj:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "doc-abc-def-doc" then do:
      create locb-doc-abc-def-doc.
run nws-impl in p-imp-handle
  ( input "doc-abc-def-doc":U
   ,input (buffer locb-doc-abc-def-doc:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе abc-анализа."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_doc-abc-def-obj where
         buf_doc-abc-def-obj.doad-id   = wt-doc-abc-def.doad-id  and
         buf_doc-abc-def-obj.db-num    = wt-doc-abc-def.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_doc-abc-def-obj.
end.
for each locb-doc-abc-def-obj where
         locb-doc-abc-def-obj.doad-id = wt-doc-abc-def.doad-id and
         locb-doc-abc-def-obj.db-num  = wt-doc-abc-def.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_doc-abc-def-obj.
  buffer-copy locb-doc-abc-def-obj to buf_doc-abc-def-obj.
end.
for each buf_doc-abc-def-doc where
         buf_doc-abc-def-doc.doad-id   = wt-doc-abc-def.doad-id  and
         buf_doc-abc-def-doc.db-num    = wt-doc-abc-def.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_doc-abc-def-doc.
end.
for each locb-doc-abc-def-doc where
         locb-doc-abc-def-doc.doad-id = wt-doc-abc-def.doad-id and
         locb-doc-abc-def-doc.db-num  = wt-doc-abc-def.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_doc-abc-def-doc.
  buffer-copy locb-doc-abc-def-doc to buf_doc-abc-def-doc.
end.
if not available tb-doc-abc-def then do:
  create tb-doc-abc-def.
end.
buffer-copy wt-doc-abc-def to tb-doc-abc-def.
for each locb-doc-abc-def-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-doc-abc-def-obj.
end.
for each locb-doc-abc-def-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-doc-abc-def-doc.
end.
    delete wt-doc-abc-def.
  end.
END PROCEDURE.
 define temp-table locb-doc-xyz-def-obj   no-undo like ub.doc-xyz-def-obj.
 define temp-table locb-doc-xyz-def-doc   no-undo like ub.doc-xyz-def-doc.
define temp-table wt-doc-xyz-def no-undo like ub.doc-xyz-def.
PROCEDURE proc-load-doc-xyz-def:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-doc-xyz-def. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-doc-xyz-def. stop" )
  on endkey undo, return error substitute( "$proc-load-doc-xyz-def. endkey" )
  :
    define buffer tb-doc-xyz-def for ub.doc-xyz-def.
    define variable compare-log as logical no-undo.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_doc-xyz-def-obj  for ub.doc-xyz-def-obj.
define buffer buf_doc-xyz-def-doc  for ub.doc-xyz-def-doc.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-doc-xyz-def-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-doc-xyz-def-obj.
end.
for each locb-doc-xyz-def-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-doc-xyz-def-doc.
end.
    for each wt-doc-xyz-def
    on error undo, return error substitute( "$proc-load-doc-xyz-def(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-doc-xyz-def .
    end.
    create wt-doc-xyz-def.
    run nws-impl in p-imp-handle
      ( input 'doc-xyz-def':U
       ,input (buffer wt-doc-xyz-def:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-doc-xyz-def
      where tb-doc-xyz-def.doxd-id = wt-doc-xyz-def.doxd-id
        and tb-doc-xyz-def.db-num = wt-doc-xyz-def.db-num
      exclusive-lock no-error.
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "doc-xyz-def-obj" then do:
      create locb-doc-xyz-def-obj.
run nws-impl in p-imp-handle
  ( input "doc-xyz-def-obj":U
   ,input (buffer locb-doc-xyz-def-obj:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "doc-xyz-def-doc" then do:
      create locb-doc-xyz-def-doc.
run nws-impl in p-imp-handle
  ( input "doc-xyz-def-doc":U
   ,input (buffer locb-doc-xyz-def-doc:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе xyz-анализа."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_doc-xyz-def-obj where
         buf_doc-xyz-def-obj.doxd-id   = wt-doc-xyz-def.doxd-id  and
         buf_doc-xyz-def-obj.db-num    = wt-doc-xyz-def.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_doc-xyz-def-obj.
end.
for each locb-doc-xyz-def-obj where
         locb-doc-xyz-def-obj.doxd-id = wt-doc-xyz-def.doxd-id and
         locb-doc-xyz-def-obj.db-num  = wt-doc-xyz-def.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_doc-xyz-def-obj.
  buffer-copy locb-doc-xyz-def-obj to buf_doc-xyz-def-obj.
end.
for each buf_doc-xyz-def-doc where
         buf_doc-xyz-def-doc.doxd-id   = wt-doc-xyz-def.doxd-id  and
         buf_doc-xyz-def-doc.db-num    = wt-doc-xyz-def.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_doc-xyz-def-doc.
end.
for each locb-doc-xyz-def-doc where
         locb-doc-xyz-def-doc.doxd-id = wt-doc-xyz-def.doxd-id and
         locb-doc-xyz-def-doc.db-num  = wt-doc-xyz-def.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_doc-xyz-def-doc.
  buffer-copy locb-doc-xyz-def-doc to buf_doc-xyz-def-doc.
end.
if not available tb-doc-xyz-def then do:
  create tb-doc-xyz-def.
end.
buffer-copy wt-doc-xyz-def to tb-doc-xyz-def.
for each locb-doc-xyz-def-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-doc-xyz-def-obj.
end.
for each locb-doc-xyz-def-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-doc-xyz-def-doc.
end.
    delete wt-doc-xyz-def.
  end.
END PROCEDURE.
define temp-table locb-esys-route-dump     no-undo like ub.esys-route-dump.
define temp-table wt-esys-route no-undo like ub.esys-route.
PROCEDURE proc-load-esys-route:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-esys-route. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-esys-route. stop" )
  on endkey undo, return error substitute( "$proc-load-esys-route. endkey" )
  :
    define buffer tb-esys-route for ub.esys-route.
    define variable compare-log as logical no-undo.
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_esys-route-dump        for ub.esys-route-dump.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
for each locb-esys-route-dump
on error undo, return error error-status :get-message (1)
:
  delete locb-esys-route-dump.
end.
    for each wt-esys-route
    on error undo, return error substitute( "$proc-load-esys-route(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-esys-route .
    end.
    create wt-esys-route.
    run nws-impl in p-imp-handle
      ( input 'esys-route':U
       ,input (buffer wt-esys-route:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-esys-route
      where tb-esys-route.esys-id = wt-esys-route.esys-id
        and tb-esys-route.db-num = wt-esys-route.db-num
        and tb-esys-route.esr-cr-db-num = wt-esys-route.esr-cr-db-num
        and tb-esys-route.esr-last-pack = wt-esys-route.esr-last-pack
        and tb-esys-route.esr-tbl-ord = wt-esys-route.esr-tbl-ord
      exclusive-lock no-error.
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
  .
  CASE rec-name :
    when "esys-route-dump" then do:
      create locb-esys-route-dump.
run nws-impl in p-imp-handle
  ( input "esys-route-dump":U
   ,input (buffer locb-esys-route-dump:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе истории чека МЦ"
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
if not available tb-esys-route then do:
  create tb-esys-route.
end.
buffer-copy wt-esys-route to tb-esys-route.
for each buf_esys-route-dump where
        buf_esys-route-dump.esrd-dump-ord = wt-esys-route.esr-dump-ord
    AND buf_esys-route-dump.esrd-cr-db-num = wt-esys-route.esr-cr-db-num
on error  undo, return error
:
  delete buf_esys-route-dump.
end.
for each locb-esys-route-dump where
        locb-esys-route-dump.esrd-dump-ord = wt-esys-route.esr-dump-ord
    AND locb-esys-route-dump.esrd-cr-db-num = wt-esys-route.esr-cr-db-num
    no-lock
on error  undo, return error
:
  create buf_esys-route-dump.
  buffer-copy locb-esys-route-dump to buf_esys-route-dump.
end.
for each locb-esys-route-dump
on error  undo, return error
:
  delete locb-esys-route-dump.
end.
    delete wt-esys-route.
  end.
END PROCEDURE.
define temp-table wt-ext-classif no-undo like ub.ext-classif.
PROCEDURE proc-load-ext-classif:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-ext-classif. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-ext-classif. stop" )
  on endkey undo, return error substitute( "$proc-load-ext-classif. endkey" )
  :
    define buffer tb-ext-classif for ub.ext-classif.
    define variable compare-log as logical no-undo.
    for each wt-ext-classif
    on error undo, return error substitute( "$proc-load-ext-classif(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-ext-classif .
    end.
    create wt-ext-classif.
    run nws-impl in p-imp-handle
      ( input 'ext-classif':U
       ,input (buffer wt-ext-classif:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-ext-classif
      where tb-ext-classif.classif-subject = wt-ext-classif.classif-subject
        and tb-ext-classif.classif-name = wt-ext-classif.classif-name
        and tb-ext-classif.db-num = wt-ext-classif.db-num
        and tb-ext-classif.Key#_One = wt-ext-classif.Key#_One
        and tb-ext-classif.Key#_Two = wt-ext-classif.Key#_Two
        and tb-ext-classif.Key#_Three = wt-ext-classif.Key#_Three
        and tb-ext-classif.CharKey_One = wt-ext-classif.CharKey_One
        and tb-ext-classif.CharKey_Two = wt-ext-classif.CharKey_Two
        and tb-ext-classif.CharKey_Three = wt-ext-classif.CharKey_Three
        and tb-ext-classif.nonunique = wt-ext-classif.nonunique
      exclusive-lock no-error.
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if not available tb-ext-classif then do:
  create tb-ext-classif.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-ext-classif TO wt-ext-classif case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-ext-classif TO tb-ext-classif.
   if wt-ext-classif.classif-subject = "goods" and wt-ext-classif.classif-name = "exp-esys-gds-code" then do:
   run fill-ext-classif in p-imp-handle (input tb-ext-classif.db-num
      ,input tb-ext-classif.Key#_One
      ,input tb-ext-classif.Key#_Two
      ,input tb-ext-classif.CharKey_One
      ).
   end.
end.
    delete wt-ext-classif.
  end.
END PROCEDURE.
define temp-table wt-c-ext-classif no-undo like ub.c-ext-classif.
PROCEDURE proc-load-c-ext-classif:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-c-ext-classif. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-c-ext-classif. stop" )
  on endkey undo, return error substitute( "$proc-load-c-ext-classif. endkey" )
  :
    define buffer tb-c-ext-classif for ub.c-ext-classif.
    define variable compare-log as logical no-undo.
    for each wt-c-ext-classif
    on error undo, return error substitute( "$proc-load-c-ext-classif(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-c-ext-classif .
    end.
    create wt-c-ext-classif.
    run nws-impl in p-imp-handle
      ( input 'c-ext-classif':U
       ,input (buffer wt-c-ext-classif:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-c-ext-classif
      where tb-c-ext-classif.classif-subject = wt-c-ext-classif.classif-subject
        and tb-c-ext-classif.classif-name = wt-c-ext-classif.classif-name
        and tb-c-ext-classif.db-num = wt-c-ext-classif.db-num
        and tb-c-ext-classif.Key#_One = wt-c-ext-classif.Key#_One
        and tb-c-ext-classif.Key#_Two = wt-c-ext-classif.Key#_Two
        and tb-c-ext-classif.Key#_Three = wt-c-ext-classif.Key#_Three
        and tb-c-ext-classif.CharKey_One = wt-c-ext-classif.CharKey_One
        and tb-c-ext-classif.CharKey_Two = wt-c-ext-classif.CharKey_Two
        and tb-c-ext-classif.CharKey_Three = wt-c-ext-classif.CharKey_Three
        and tb-c-ext-classif.nonunique = wt-c-ext-classif.nonunique
        and tb-c-ext-classif.corr-user-db-num = wt-c-ext-classif.corr-user-db-num
        and tb-c-ext-classif.chip-num = wt-c-ext-classif.chip-num
      exclusive-lock no-error.
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if not available tb-c-ext-classif then do:
  create tb-c-ext-classif.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-c-ext-classif TO wt-c-ext-classif case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-c-ext-classif TO tb-c-ext-classif.
   if wt-c-ext-classif.classif-subject = "goods" and wt-c-ext-classif.classif-name = "exp-esys-gds-code" then do:
   run fill-c-ext-classif in p-imp-handle (input tb-c-ext-classif.db-num
      ,input tb-c-ext-classif.Key#_One
      ,input tb-c-ext-classif.Key#_Two
      ,input tb-c-ext-classif.CharKey_One
      ,input tb-c-ext-classif.chip-num
      ).
end.
end.
    delete wt-c-ext-classif.
  end.
END PROCEDURE.
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table locb-factur-connect-line no-undo like ub.factur-connect-line.
define temp-table wt-factur-connect no-undo like ub.factur-connect.
PROCEDURE proc-load-factur-connect:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-factur-connect. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-factur-connect. stop" )
  on endkey undo, return error substitute( "$proc-load-factur-connect. endkey" )
  :
    define buffer tb-factur-connect for ub.factur-connect.
    define variable compare-log as logical no-undo.
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_factur-connect-line for ub.factur-connect-line.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-factur-connect-line
on error undo, return error error-status :get-message (1)
:
  delete locb-factur-connect-line.
end.
    for each wt-factur-connect
    on error undo, return error substitute( "$proc-load-factur-connect(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-factur-connect .
    end.
    create wt-factur-connect.
    run nws-impl in p-imp-handle
      ( input 'factur-connect':U
       ,input (buffer wt-factur-connect:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-factur-connect
      where tb-factur-connect.db-num = wt-factur-connect.db-num
        and tb-factur-connect.connect-code = wt-factur-connect.connect-code
      exclusive-lock no-error.
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "factur-connect-line" then do:
      create locb-factur-connect-line.
run nws-impl in p-imp-handle
  ( input "factur-connect-line":U
   ,input (buffer locb-factur-connect-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе савокупных заявок."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_factur-connect-line where buf_factur-connect-line.connect-code = wt-factur-connect.connect-code and
                                       buf_factur-connect-line.db-num    = wt-factur-connect.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_factur-connect-line.
end.
for each locb-factur-connect-line where locb-factur-connect-line.connect-code = wt-factur-connect.connect-code and
                                        locb-factur-connect-line.db-num    = wt-factur-connect.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_factur-connect-line.
  buffer-copy locb-factur-connect-line to buf_factur-connect-line.
end.
if not available tb-factur-connect then do:
  create tb-factur-connect.
end.
buffer-copy wt-factur-connect to tb-factur-connect.
for each locb-factur-connect-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-factur-connect-line.
end.
    delete wt-factur-connect.
  end.
END PROCEDURE.
define temp-table locb-fbr-line no-undo like ub.fbr-line.
define temp-table locb-fbr-recipe no-undo like ub.fbr-recipe.
define temp-table locb-fbr-recipe-gds no-undo like ub.fbr-recipe-gds.
define temp-table wt-fbr-doc no-undo like ub.fbr-doc.
PROCEDURE proc-load-fbr-doc:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-fbr-doc. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-fbr-doc. stop" )
  on endkey undo, return error substitute( "$proc-load-fbr-doc. endkey" )
  :
    define buffer tb-fbr-doc for ub.fbr-doc.
    define variable compare-log as logical no-undo.
define buffer buf_fbr-line for ub.fbr-line.
define buffer buf_fbr-recipe     for ub.fbr-recipe.
define buffer buf_fbr-recipe-gds for ub.fbr-recipe-gds.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
    for each wt-fbr-doc
    on error undo, return error substitute( "$proc-load-fbr-doc(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-fbr-doc .
    end.
    create wt-fbr-doc.
    run nws-impl in p-imp-handle
      ( input 'fbr-doc':U
       ,input (buffer wt-fbr-doc:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-fbr-doc
      where tb-fbr-doc.doc-code = wt-fbr-doc.doc-code
      exclusive-lock no-error.
define variable vss-include-info61 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "fbr-line" then do:
      create locb-fbr-line.
run nws-impl in p-imp-handle
  ( input "fbr-line":U
   ,input (buffer locb-fbr-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "fbr-recipe" then do:
      create locb-fbr-recipe.
run nws-impl in p-imp-handle
  ( input "fbr-recipe":U
   ,input (buffer locb-fbr-recipe:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "fbr-recipe-gds" then do:
      create locb-fbr-recipe-gds.
run nws-impl in p-imp-handle
  ( input "fbr-recipe-gds":U
   ,input (buffer locb-fbr-recipe-gds:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе производства."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_fbr-line where buf_fbr-line.doc-code = wt-fbr-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info61, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete buf_fbr-line.
end.
for each locb-fbr-line where locb-fbr-line.doc-code = wt-fbr-doc.doc-code
                       no-lock
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info61, return-value, chr(10), error-status :get-message ( 1 ) )
:
  create buf_fbr-line.
  buffer-copy locb-fbr-line to buf_fbr-line.
end.
for each buf_fbr-recipe where buf_fbr-recipe.doc-code = wt-fbr-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info61, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete buf_fbr-recipe.
end.
for each locb-fbr-recipe where locb-fbr-recipe.doc-code = wt-fbr-doc.doc-code
                       no-lock
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info61, return-value, chr(10), error-status :get-message ( 1 ) )
:
  create buf_fbr-recipe.
  buffer-copy locb-fbr-recipe to buf_fbr-recipe.
end.
for each buf_fbr-recipe-gds where buf_fbr-recipe-gds.doc-code = wt-fbr-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info61, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete buf_fbr-recipe-gds.
end.
for each locb-fbr-recipe-gds where locb-fbr-recipe-gds.doc-code = wt-fbr-doc.doc-code
                       no-lock
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info61, return-value, chr(10), error-status :get-message ( 1 ) )
:
  create buf_fbr-recipe-gds.
  buffer-copy locb-fbr-recipe-gds to buf_fbr-recipe-gds.
end.
if not available tb-fbr-doc then do:
  create tb-fbr-doc.
end.
define variable v-old-fbr-doc-status as character no-undo .
define variable v-new-fbr-doc-status as character no-undo .
assign
  v-old-fbr-doc-status = tb-fbr-doc.status_
  v-new-fbr-doc-status = wt-fbr-doc.status_
.
run trg/nwsdochs.p
  (input g#db-num
  ,input 'update':U
  ,input wt-fbr-doc.doc-code
  ,input wt-fbr-doc.obj-type
  ,input wt-fbr-doc.obj-code
  ,input 'fbr-doc':U
  ,input '':u
  ,input wt-fbr-doc.fact-date
  ,input wt-fbr-doc.out-qnty
  ,input wt-fbr-doc.out-base
  ,input wt-fbr-doc.out-rubl
  ,input 0
  ,input v-old-fbr-doc-status
  ,input v-new-fbr-doc-status
  ,input g#news-source-db
  ,input p-pck-num
  ,input wt-fbr-doc.user-db-num
  ,input wt-fbr-doc.user-name
  ,input wt-fbr-doc.sys-date
  ,input wt-fbr-doc.sys-time
  ,input wt-fbr-doc.sys-time-int
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.
buffer-copy wt-fbr-doc to tb-fbr-doc.
for each locb-fbr-line
on error  undo, return error
:
  delete locb-fbr-line.
end.
    delete wt-fbr-doc.
  end.
END PROCEDURE.
define temp-table locb-c-fbr-line no-undo like ub.c-fbr-line.
define temp-table wt-c-fbr-doc no-undo like ub.c-fbr-doc.
PROCEDURE proc-load-c-fbr-doc:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-c-fbr-doc. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-c-fbr-doc. stop" )
  on endkey undo, return error substitute( "$proc-load-c-fbr-doc. endkey" )
  :
    define buffer tb-c-fbr-doc for ub.c-fbr-doc.
    define variable compare-log as logical no-undo.
define buffer buf_c-fbr-line for ub.c-fbr-line.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
    for each wt-c-fbr-doc
    on error undo, return error substitute( "$proc-load-c-fbr-doc(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-c-fbr-doc .
    end.
    create wt-c-fbr-doc.
    run nws-impl in p-imp-handle
      ( input 'c-fbr-doc':U
       ,input (buffer wt-c-fbr-doc:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-c-fbr-doc
      where tb-c-fbr-doc.doc-code = wt-c-fbr-doc.doc-code
        and tb-c-fbr-doc.corr-user-db-num = wt-c-fbr-doc.corr-user-db-num
        and tb-c-fbr-doc.chip-num = wt-c-fbr-doc.chip-num
      exclusive-lock no-error.
define variable vss-include-info62 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "c-fbr-line" then do:
      create locb-c-fbr-line.
run nws-impl in p-imp-handle
  ( input "c-fbr-line":U
   ,input (buffer locb-c-fbr-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе производства."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_c-fbr-line where buf_c-fbr-line.doc-code = wt-c-fbr-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-fbr-line.
end.
for each locb-c-fbr-line where locb-c-fbr-line.doc-code = wt-c-fbr-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-fbr-line.
  buffer-copy locb-c-fbr-line to buf_c-fbr-line.
end.
if not available tb-c-fbr-doc then do:
  create tb-c-fbr-doc.
end.
buffer-copy wt-c-fbr-doc to tb-c-fbr-doc.
for each locb-c-fbr-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-fbr-line.
end.
    delete wt-c-fbr-doc.
  end.
END PROCEDURE.
define temp-table locb-fbr-pln-line no-undo like ub.fbr-pln-line.
define temp-table wt-fbr-pln no-undo like ub.fbr-pln.
PROCEDURE proc-load-fbr-pln:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-fbr-pln. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-fbr-pln. stop" )
  on endkey undo, return error substitute( "$proc-load-fbr-pln. endkey" )
  :
    define buffer tb-fbr-pln for ub.fbr-pln.
    define variable compare-log as logical no-undo.
define buffer buf_fbr-pln-line for ub.fbr-pln-line.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
    for each wt-fbr-pln
    on error undo, return error substitute( "$proc-load-fbr-pln(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-fbr-pln .
    end.
    create wt-fbr-pln.
    run nws-impl in p-imp-handle
      ( input 'fbr-pln':U
       ,input (buffer wt-fbr-pln:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-fbr-pln
      where tb-fbr-pln.doc-code = wt-fbr-pln.doc-code
      exclusive-lock no-error.
define variable vss-include-info63 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "fbr-pln-line" then do:
      create locb-fbr-pln-line.
run nws-impl in p-imp-handle
  ( input "fbr-pln-line":U
   ,input (buffer locb-fbr-pln-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе производства."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_fbr-pln-line where buf_fbr-pln-line.doc-code = wt-fbr-pln.doc-code
on error  undo, return error
:
  delete buf_fbr-pln-line.
end.
for each locb-fbr-pln-line where locb-fbr-pln-line.doc-code = wt-fbr-pln.doc-code
                       no-lock
on error  undo, return error
:
  create buf_fbr-pln-line.
  buffer-copy locb-fbr-pln-line to buf_fbr-pln-line.
end.
if not available tb-fbr-pln then do:
  create tb-fbr-pln.
end.
define variable v-old-fbr-pln-status as character no-undo .
define variable v-new-fbr-pln-status as character no-undo .
assign
  v-old-fbr-pln-status = tb-fbr-pln.status_
  v-new-fbr-pln-status = wt-fbr-pln.status_
.
run trg/nwsdochs.p
  (input g#db-num
  ,input 'update':U
  ,input wt-fbr-pln.doc-code
  ,input wt-fbr-pln.obj-type
  ,input wt-fbr-pln.obj-code
  ,input 'fbr-pln':U
  ,input '':u
  ,input wt-fbr-pln.fact-date
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input v-old-fbr-pln-status
  ,input v-new-fbr-pln-status
  ,input g#news-source-db
  ,input p-pck-num
  ,input wt-fbr-pln.user-db-num
  ,input wt-fbr-pln.user-name
  ,input wt-fbr-pln.sys-date
  ,input wt-fbr-pln.sys-time
  ,input wt-fbr-pln.sys-time-int
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.
buffer-copy wt-fbr-pln to tb-fbr-pln.
for each locb-fbr-pln-line
on error  undo, return error
:
  delete locb-fbr-pln-line.
end.
    delete wt-fbr-pln.
  end.
END PROCEDURE.
define temp-table locb-c-fbr-pln-line no-undo like ub.c-fbr-pln-line.
define temp-table wt-c-fbr-pln no-undo like ub.c-fbr-pln.
PROCEDURE proc-load-c-fbr-pln:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-c-fbr-pln. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-c-fbr-pln. stop" )
  on endkey undo, return error substitute( "$proc-load-c-fbr-pln. endkey" )
  :
    define buffer tb-c-fbr-pln for ub.c-fbr-pln.
    define variable compare-log as logical no-undo.
define buffer buf_c-fbr-pln-line for ub.c-fbr-pln-line.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
    for each wt-c-fbr-pln
    on error undo, return error substitute( "$proc-load-c-fbr-pln(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-c-fbr-pln .
    end.
    create wt-c-fbr-pln.
    run nws-impl in p-imp-handle
      ( input 'c-fbr-pln':U
       ,input (buffer wt-c-fbr-pln:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-c-fbr-pln
      where tb-c-fbr-pln.doc-code = wt-c-fbr-pln.doc-code
        and tb-c-fbr-pln.corr-user-db-num = wt-c-fbr-pln.corr-user-db-num
        and tb-c-fbr-pln.chip-num = wt-c-fbr-pln.chip-num
      exclusive-lock no-error.
define variable vss-include-info64 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "c-fbr-pln-line" then do:
      create locb-c-fbr-pln-line.
run nws-impl in p-imp-handle
  ( input "c-fbr-pln-line":U
   ,input (buffer locb-c-fbr-pln-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе производства."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_c-fbr-pln-line where buf_c-fbr-pln-line.doc-code = wt-c-fbr-pln.doc-code
on error  undo, return error
:
  delete buf_c-fbr-pln-line.
end.
for each locb-c-fbr-pln-line where locb-c-fbr-pln-line.doc-code = wt-c-fbr-pln.doc-code
                       no-lock
on error  undo, return error
:
  create buf_c-fbr-pln-line.
  buffer-copy locb-c-fbr-pln-line to buf_c-fbr-pln-line.
end.
if not available tb-c-fbr-pln then do:
  create tb-c-fbr-pln.
end.
define variable v-old-c-fbr-pln-status as character no-undo .
define variable v-new-c-fbr-pln-status as character no-undo .
assign
  v-old-c-fbr-pln-status = tb-c-fbr-pln.status_
  v-new-c-fbr-pln-status = wt-c-fbr-pln.status_
.
run trg/nwsdochs.p
  (input g#db-num
  ,input 'update':U
  ,input wt-c-fbr-pln.doc-code
  ,input wt-c-fbr-pln.obj-type
  ,input wt-c-fbr-pln.obj-code
  ,input 'c-fbr-pln':U
  ,input '':u
  ,input wt-c-fbr-pln.fact-date
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input v-old-c-fbr-pln-status
  ,input v-new-c-fbr-pln-status
  ,input g#news-source-db
  ,input p-pck-num
  ,input wt-c-fbr-pln.user-db-num
  ,input wt-c-fbr-pln.user-name
  ,input wt-c-fbr-pln.sys-date
  ,input wt-c-fbr-pln.sys-time
  ,input wt-c-fbr-pln.sys-time-int
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.
buffer-copy wt-c-fbr-pln to tb-c-fbr-pln.
for each locb-c-fbr-pln-line
on error  undo, return error
:
  delete locb-c-fbr-pln-line.
end.
    delete wt-c-fbr-pln.
  end.
END PROCEDURE.
define temp-table locb-fin-doc-tax  no-undo like ub.fin-doc-tax.
define temp-table locb-fin-doc-attr  no-undo like ub.fin-doc-attr.
define new global shared variable g#lib-farh as handle no-undo .
define temp-table wt-fin-doc no-undo like ub.fin-doc.
PROCEDURE proc-load-fin-doc:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-fin-doc. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-fin-doc. stop" )
  on endkey undo, return error substitute( "$proc-load-fin-doc. endkey" )
  :
    define buffer tb-fin-doc for ub.fin-doc.
    define variable compare-log as logical no-undo.
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_fin-doc-tax      for ub.fin-doc-tax.
define buffer buf_fin-doc-attr     for ub.fin-doc-attr.
define buffer buf_sysconf for ub.sysconf .
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
define variable v-obj-db-num as integer no-undo .
for each locb-fin-doc-tax
on error undo, return error error-status :get-message (1)
:
  delete locb-fin-doc-tax.
end.
for each locb-fin-doc-attr
on error undo, return error error-status :get-message (1)
:
  delete locb-fin-doc-attr.
end.
    for each wt-fin-doc
    on error undo, return error substitute( "$proc-load-fin-doc(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-fin-doc .
    end.
    create wt-fin-doc.
    run nws-impl in p-imp-handle
      ( input 'fin-doc':U
       ,input (buffer wt-fin-doc:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-fin-doc
      where tb-fin-doc.host-code = wt-fin-doc.host-code
        and tb-fin-doc.fin-doc-code = wt-fin-doc.fin-doc-code
      exclusive-lock no-error.
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "fin-doc-tax" then do:
      create locb-fin-doc-tax.
run nws-impl in p-imp-handle
  ( input "fin-doc-tax":U
   ,input (buffer locb-fin-doc-tax:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "fin-doc-attr" then do:
      create locb-fin-doc-attr.
run nws-impl in p-imp-handle
  ( input "fin-doc-attr":U
   ,input (buffer locb-fin-doc-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе савокупных заявок."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_fin-doc-tax where buf_fin-doc-tax.fin-doc-code = wt-fin-doc.fin-doc-code and
                              buf_fin-doc-tax.host-code = wt-fin-doc.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_fin-doc-tax.
end.
for each locb-fin-doc-tax where locb-fin-doc-tax.fin-doc-code = wt-fin-doc.fin-doc-code and
                               locb-fin-doc-tax.host-code = wt-fin-doc.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_fin-doc-tax.
  buffer-copy locb-fin-doc-tax to buf_fin-doc-tax.
end.
for each buf_fin-doc-attr where buf_fin-doc-attr.fin-doc-code = wt-fin-doc.fin-doc-code and
                              buf_fin-doc-attr.host-code = wt-fin-doc.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_fin-doc-attr.
end.
for each locb-fin-doc-attr where locb-fin-doc-attr.fin-doc-code = wt-fin-doc.fin-doc-code and
                               locb-fin-doc-attr.host-code = wt-fin-doc.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_fin-doc-attr.
  buffer-copy locb-fin-doc-attr to buf_fin-doc-attr.
end.
if not available tb-fin-doc then do:
  create tb-fin-doc.
end.
buffer-copy wt-fin-doc to tb-fin-doc.
for each locb-fin-doc-tax
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-doc-tax.
end.
for each locb-fin-doc-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-doc-attr.
end.
if tb-fin-doc.status_ = 'факт':U then do:
  find first buf_sysconf no-lock where
            buf_sysconf.host-code = tb-fin-doc.host-code.
  if not (tb-fin-doc.obj-type = '' and tb-fin-doc.obj-code = 0) then do:
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  tb-fin-doc.obj-type
  ,input  tb-fin-doc.obj-code
  ,output v-obj-db-num
  )  .
  end.
  if g#db-num = v-obj-db-num
  or g#db-num = buf_sysconf.firm-db-num then do:
if (valid-handle(g#lib-farh) <> true) then do:   run str/lib-farh.p persistent no-error .   if error-status :error or (valid-handle(g#lib-farh) <> true) then do:     message       "Error starting lib-farh.p" skip       g#lib-farh skip       g#lib-farh :type skip       g#lib-farh :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-farh_taskclcd in g#lib-farh
(input tb-fin-doc.host-code
,input tb-fin-doc.fin-doc-code
,input 'all':U
,input g#userid
,input 'close':u
) no-error
.
    if error-status:error then do:
      undo, return error substitute("Ошибка при расчете архивов по платежу: &1 &2", return-value, error-status:get-message(1)).
    end.
  end.
end.
    delete wt-fin-doc.
  end.
END PROCEDURE.
define temp-table locb-c-fin-doc-tax  no-undo like ub.c-fin-doc-tax.
define temp-table locb-c-fin-doc-attr  no-undo like ub.c-fin-doc-attr.
define temp-table wt-c-fin-doc no-undo like ub.c-fin-doc.
PROCEDURE proc-load-c-fin-doc:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-c-fin-doc. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-c-fin-doc. stop" )
  on endkey undo, return error substitute( "$proc-load-c-fin-doc. endkey" )
  :
    define buffer tb-c-fin-doc for ub.c-fin-doc.
    define variable compare-log as logical no-undo.
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_c-fin-doc-tax      for ub.c-fin-doc-tax.
define buffer buf_c-fin-doc-attr     for ub.c-fin-doc-attr.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
for each locb-c-fin-doc-attr
on error undo, return error error-status :get-message (1)
:
  delete locb-c-fin-doc-attr.
end.
for each locb-c-fin-doc-tax
on error undo, return error error-status :get-message (1)
:
  delete locb-c-fin-doc-tax.
end.
    for each wt-c-fin-doc
    on error undo, return error substitute( "$proc-load-c-fin-doc(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-c-fin-doc .
    end.
    create wt-c-fin-doc.
    run nws-impl in p-imp-handle
      ( input 'c-fin-doc':U
       ,input (buffer wt-c-fin-doc:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-c-fin-doc
      where tb-c-fin-doc.host-code = wt-c-fin-doc.host-code
        and tb-c-fin-doc.fin-doc-code = wt-c-fin-doc.fin-doc-code
        and tb-c-fin-doc.corr-user-db-num = wt-c-fin-doc.corr-user-db-num
        and tb-c-fin-doc.chip-num = wt-c-fin-doc.chip-num
      exclusive-lock no-error.
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "c-fin-doc-tax" then do:
      create locb-c-fin-doc-tax.
run nws-impl in p-imp-handle
  ( input "c-fin-doc-tax":U
   ,input (buffer locb-c-fin-doc-tax:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-fin-doc-attr" then do:
      create locb-c-fin-doc-attr.
run nws-impl in p-imp-handle
  ( input "c-fin-doc-attr":U
   ,input (buffer locb-c-fin-doc-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе савокупных заявок."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_c-fin-doc-tax where buf_c-fin-doc-tax.fin-doc-code = wt-c-fin-doc.fin-doc-code and
                              buf_c-fin-doc-tax.host-code = wt-c-fin-doc.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-fin-doc-tax.
end.
for each locb-c-fin-doc-tax where locb-c-fin-doc-tax.fin-doc-code = wt-c-fin-doc.fin-doc-code and
                               locb-c-fin-doc-tax.host-code = wt-c-fin-doc.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-fin-doc-tax.
  buffer-copy locb-c-fin-doc-tax to buf_c-fin-doc-tax.
end.
for each buf_c-fin-doc-attr where buf_c-fin-doc-attr.fin-doc-code = wt-c-fin-doc.fin-doc-code and
                              buf_c-fin-doc-attr.host-code = wt-c-fin-doc.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-fin-doc-attr.
end.
for each locb-c-fin-doc-attr where locb-c-fin-doc-attr.fin-doc-code = wt-c-fin-doc.fin-doc-code and
                               locb-c-fin-doc-attr.host-code = wt-c-fin-doc.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-fin-doc-attr.
  buffer-copy locb-c-fin-doc-attr to buf_c-fin-doc-attr.
end.
if not available tb-c-fin-doc then do:
  create tb-c-fin-doc.
end.
buffer-copy wt-c-fin-doc to tb-c-fin-doc.
for each locb-c-fin-doc-tax
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-fin-doc-tax.
end.
for each locb-c-fin-doc-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-fin-doc-attr.
end.
    delete wt-c-fin-doc.
  end.
END PROCEDURE.
define temp-table locb-fin-ob-tax  no-undo like ub.fin-ob-tax.
define temp-table locb-fin-ob-trn  no-undo like ub.fin-ob-trn.
define temp-table locb-fin-gds-part no-undo like ub.fin-gds-part.
define temp-table wt-fin-ob no-undo like ub.fin-ob.
PROCEDURE proc-load-fin-ob:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-fin-ob. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-fin-ob. stop" )
  on endkey undo, return error substitute( "$proc-load-fin-ob. endkey" )
  :
    define buffer tb-fin-ob for ub.fin-ob.
    define variable compare-log as logical no-undo.
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_fin-ob-tax      for ub.fin-ob-tax.
define buffer buf_fin-ob-trn      for ub.fin-ob-trn.
define buffer buf_fin-gds-part    for ub.fin-gds-part.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-fin-ob-tax
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-ob-tax.
end.
for each locb-fin-ob-trn
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-ob-trn.
end.
for each locb-fin-gds-part
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-gds-part.
end.
    for each wt-fin-ob
    on error undo, return error substitute( "$proc-load-fin-ob(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-fin-ob .
    end.
    create wt-fin-ob.
    run nws-impl in p-imp-handle
      ( input 'fin-ob':U
       ,input (buffer wt-fin-ob:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-fin-ob
      where tb-fin-ob.host-code = wt-fin-ob.host-code
        and tb-fin-ob.doc-code = wt-fin-ob.doc-code
      exclusive-lock no-error.
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "fin-ob-tax" then do:
      create locb-fin-ob-tax.
run nws-impl in p-imp-handle
  ( input "fin-ob-tax":U
   ,input (buffer locb-fin-ob-tax:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "fin-ob-trn" then do:
      create locb-fin-ob-trn.
run nws-impl in p-imp-handle
  ( input "fin-ob-trn":U
   ,input (buffer locb-fin-ob-trn:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "fin-gds-part" then do:
      create locb-fin-gds-part.
run nws-impl in p-imp-handle
  ( input "fin-gds-part":U
   ,input (buffer locb-fin-gds-part:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе савокупных заявок."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_fin-ob-tax where buf_fin-ob-tax.doc-code = wt-fin-ob.doc-code and
                              buf_fin-ob-tax.host-code = wt-fin-ob.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_fin-ob-tax.
end.
for each locb-fin-ob-tax where locb-fin-ob-tax.doc-code = wt-fin-ob.doc-code and
                               locb-fin-ob-tax.host-code = wt-fin-ob.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_fin-ob-tax.
  buffer-copy locb-fin-ob-tax to buf_fin-ob-tax.
end.
for each buf_fin-ob-trn where buf_fin-ob-trn.doc-code = wt-fin-ob.doc-code and
                              buf_fin-ob-trn.host-code = wt-fin-ob.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_fin-ob-trn.
end.
for each locb-fin-ob-trn where locb-fin-ob-trn.doc-code = wt-fin-ob.doc-code and
                               locb-fin-ob-trn.host-code = wt-fin-ob.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_fin-ob-trn.
  buffer-copy locb-fin-ob-trn to buf_fin-ob-trn.
end.
for each buf_fin-gds-part where buf_fin-gds-part.fin-ob-code = wt-fin-ob.doc-code and
                                buf_fin-gds-part.host-code = wt-fin-ob.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_fin-gds-part.
end.
for each locb-fin-gds-part where locb-fin-gds-part.fin-ob-code = wt-fin-ob.doc-code and
                                 locb-fin-gds-part.host-code   = wt-fin-ob.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_fin-gds-part.
  buffer-copy locb-fin-gds-part to buf_fin-gds-part.
end.
if not available tb-fin-ob then do:
  create tb-fin-ob.
end.
buffer-copy wt-fin-ob to tb-fin-ob.
for each locb-fin-ob-tax
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-ob-tax.
end.
for each locb-fin-ob-trn
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-ob-trn.
end.
for each locb-fin-gds-part
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-gds-part.
end.
    delete wt-fin-ob.
  end.
END PROCEDURE.
define temp-table locb-c-fin-ob-tax  no-undo like ub.c-fin-ob-tax.
define temp-table wt-c-fin-ob no-undo like ub.c-fin-ob.
PROCEDURE proc-load-c-fin-ob:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-c-fin-ob. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-c-fin-ob. stop" )
  on endkey undo, return error substitute( "$proc-load-c-fin-ob. endkey" )
  :
    define buffer tb-c-fin-ob for ub.c-fin-ob.
    define variable compare-log as logical no-undo.
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_c-fin-ob-tax      for ub.c-fin-ob-tax.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-c-fin-ob-tax
on error  undo, return error
:
  delete locb-c-fin-ob-tax .
end.
    for each wt-c-fin-ob
    on error undo, return error substitute( "$proc-load-c-fin-ob(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-c-fin-ob .
    end.
    create wt-c-fin-ob.
    run nws-impl in p-imp-handle
      ( input 'c-fin-ob':U
       ,input (buffer wt-c-fin-ob:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-c-fin-ob
      where tb-c-fin-ob.host-code = wt-c-fin-ob.host-code
        and tb-c-fin-ob.doc-code = wt-c-fin-ob.doc-code
        and tb-c-fin-ob.corr-user-db-num = wt-c-fin-ob.corr-user-db-num
        and tb-c-fin-ob.chip-num = wt-c-fin-ob.chip-num
      exclusive-lock no-error.
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "c-fin-ob-tax" then do:
      create locb-c-fin-ob-tax.
run nws-impl in p-imp-handle
  ( input "c-fin-ob-tax":U
   ,input (buffer locb-c-fin-ob-tax:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе савокупных заявок."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_c-fin-ob-tax where buf_c-fin-ob-tax.doc-code  = wt-c-fin-ob.doc-code and
                                buf_c-fin-ob-tax.host-code = wt-c-fin-ob.host-code and
                                buf_c-fin-ob-tax.chip-num  = wt-c-fin-ob.chip-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-fin-ob-tax.
end.
for each locb-c-fin-ob-tax where locb-c-fin-ob-tax.doc-code = wt-c-fin-ob.doc-code   and
                                 locb-c-fin-ob-tax.host-code = wt-c-fin-ob.host-code and
                                 locb-c-fin-ob-tax.chip-num  = wt-c-fin-ob.chip-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-fin-ob-tax.
  buffer-copy locb-c-fin-ob-tax to buf_c-fin-ob-tax.
end.
if not available tb-c-fin-ob then do:
  create tb-c-fin-ob.
end.
buffer-copy wt-c-fin-ob to tb-c-fin-ob.
for each locb-c-fin-ob-tax
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-fin-ob-tax.
end.
    delete wt-c-fin-ob.
  end.
END PROCEDURE.
define temp-table locb-fin-ob-tax-before  no-undo like ub.fin-ob-tax-before.
define temp-table wt-fin-ob-before no-undo like ub.fin-ob-before.
PROCEDURE proc-load-fin-ob-before:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-fin-ob-before. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-fin-ob-before. stop" )
  on endkey undo, return error substitute( "$proc-load-fin-ob-before. endkey" )
  :
    define buffer tb-fin-ob-before for ub.fin-ob-before.
    define variable compare-log as logical no-undo.
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_fin-ob-tax-before      for ub.fin-ob-tax-before.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-fin-ob-tax-before
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-ob-tax-before.
end.
    for each wt-fin-ob-before
    on error undo, return error substitute( "$proc-load-fin-ob-before(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-fin-ob-before .
    end.
    create wt-fin-ob-before.
    run nws-impl in p-imp-handle
      ( input 'fin-ob-before':U
       ,input (buffer wt-fin-ob-before:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-fin-ob-before
      where tb-fin-ob-before.host-code = wt-fin-ob-before.host-code
        and tb-fin-ob-before.before-code = wt-fin-ob-before.before-code
      exclusive-lock no-error.
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "fin-ob-tax-before" then do:
      create locb-fin-ob-tax-before.
run nws-impl in p-imp-handle
  ( input "fin-ob-tax-before":U
   ,input (buffer locb-fin-ob-tax-before:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе савокупных заявок."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_fin-ob-tax-before where buf_fin-ob-tax-before.before-code = wt-fin-ob-before.before-code and
                              buf_fin-ob-tax-before.host-code = wt-fin-ob-before.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_fin-ob-tax-before.
end.
for each locb-fin-ob-tax-before where locb-fin-ob-tax-before.before-code = wt-fin-ob-before.before-code and
                               locb-fin-ob-tax-before.host-code = wt-fin-ob-before.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_fin-ob-tax-before.
  buffer-copy locb-fin-ob-tax-before to buf_fin-ob-tax-before.
end.
if not available tb-fin-ob-before then do:
  create tb-fin-ob-before.
end.
buffer-copy wt-fin-ob-before to tb-fin-ob-before.
for each locb-fin-ob-tax-before
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-ob-tax-before.
end.
    delete wt-fin-ob-before.
  end.
END PROCEDURE.
define temp-table locb-fin-statement-line  no-undo like ub.fin-statement-line.
define temp-table locb-fin-statement-attr  no-undo like ub.fin-statement-attr.
define temp-table wt-fin-statement no-undo like ub.fin-statement.
PROCEDURE proc-load-fin-statement:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-fin-statement. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-fin-statement. stop" )
  on endkey undo, return error substitute( "$proc-load-fin-statement. endkey" )
  :
    define buffer tb-fin-statement for ub.fin-statement.
    define variable compare-log as logical no-undo.
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_fin-statement-line     for ub.fin-statement-line.
define buffer buf_fin-statement-attr     for ub.fin-statement-attr.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
for each locb-fin-statement-line
on error undo, return error error-status :get-message (1)
:
  delete locb-fin-statement-line.
end.
for each locb-fin-statement-attr
on error undo, return error error-status :get-message (1)
:
  delete locb-fin-statement-attr.
end.
    for each wt-fin-statement
    on error undo, return error substitute( "$proc-load-fin-statement(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-fin-statement .
    end.
    create wt-fin-statement.
    run nws-impl in p-imp-handle
      ( input 'fin-statement':U
       ,input (buffer wt-fin-statement:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-fin-statement
      where tb-fin-statement.host-code = wt-fin-statement.host-code
        and tb-fin-statement.sttm-code = wt-fin-statement.sttm-code
      exclusive-lock no-error.
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "fin-statement-line" then do:
      create locb-fin-statement-line.
run nws-impl in p-imp-handle
  ( input "fin-statement-line":U
   ,input (buffer locb-fin-statement-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "fin-statement-attr" then do:
      create locb-fin-statement-attr.
run nws-impl in p-imp-handle
  ( input "fin-statement-attr":U
   ,input (buffer locb-fin-statement-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе совокупных выписок."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_fin-statement-line where buf_fin-statement-line.sttm-code = wt-fin-statement.sttm-code and
                              buf_fin-statement-line.host-code = wt-fin-statement.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_fin-statement-line.
end.
for each locb-fin-statement-line where locb-fin-statement-line.sttm-code = wt-fin-statement.sttm-code and
                               locb-fin-statement-line.host-code = wt-fin-statement.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_fin-statement-line.
  buffer-copy locb-fin-statement-line to buf_fin-statement-line.
end.
for each buf_fin-statement-attr where buf_fin-statement-attr.sttm-code = wt-fin-statement.sttm-code and
                              buf_fin-statement-attr.host-code = wt-fin-statement.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_fin-statement-attr.
end.
for each locb-fin-statement-attr where locb-fin-statement-attr.sttm-code = wt-fin-statement.sttm-code and
                               locb-fin-statement-attr.host-code = wt-fin-statement.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_fin-statement-attr.
  buffer-copy locb-fin-statement-attr to buf_fin-statement-attr.
end.
if not available tb-fin-statement then do:
  create tb-fin-statement.
end.
buffer-copy wt-fin-statement to tb-fin-statement.
for each locb-fin-statement-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-statement-line.
end.
for each locb-fin-statement-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-fin-statement-attr.
end.
    delete wt-fin-statement.
  end.
END PROCEDURE.
define temp-table locb-c-fin-statement-line  no-undo like ub.c-fin-statement-line.
define temp-table locb-c-fin-statement-attr  no-undo like ub.c-fin-statement-attr.
define temp-table wt-c-fin-statement no-undo like ub.c-fin-statement.
PROCEDURE proc-load-c-fin-statement:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-c-fin-statement. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-c-fin-statement. stop" )
  on endkey undo, return error substitute( "$proc-load-c-fin-statement. endkey" )
  :
    define buffer tb-c-fin-statement for ub.c-fin-statement.
    define variable compare-log as logical no-undo.
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_c-fin-statement-line      for ub.c-fin-statement-line.
define buffer buf_c-fin-statement-attr      for ub.c-fin-statement-attr.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
for each locb-c-fin-statement-line
on error undo, return error error-status :get-message (1)
:
  delete locb-c-fin-statement-line.
end.
for each locb-c-fin-statement-attr
on error undo, return error error-status :get-message (1)
:
  delete locb-c-fin-statement-attr.
end.
    for each wt-c-fin-statement
    on error undo, return error substitute( "$proc-load-c-fin-statement(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-c-fin-statement .
    end.
    create wt-c-fin-statement.
    run nws-impl in p-imp-handle
      ( input 'c-fin-statement':U
       ,input (buffer wt-c-fin-statement:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-c-fin-statement
      where tb-c-fin-statement.host-code = wt-c-fin-statement.host-code
        and tb-c-fin-statement.sttm-code = wt-c-fin-statement.sttm-code
        and tb-c-fin-statement.corr-user-db-num = wt-c-fin-statement.corr-user-db-num
        and tb-c-fin-statement.chip-num = wt-c-fin-statement.chip-num
      exclusive-lock no-error.
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "c-fin-statement-line" then do:
      create locb-c-fin-statement-line.
run nws-impl in p-imp-handle
  ( input "c-fin-statement-line":U
   ,input (buffer locb-c-fin-statement-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-fin-statement-attr" then do:
      create locb-c-fin-statement-attr.
run nws-impl in p-imp-handle
  ( input "c-fin-statement-attr":U
   ,input (buffer locb-c-fin-statement-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе совокупных выписок."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_c-fin-statement-line where buf_c-fin-statement-line.sttm-code = wt-c-fin-statement.sttm-code and
                              buf_c-fin-statement-line.host-code = wt-c-fin-statement.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-fin-statement-line.
end.
for each locb-c-fin-statement-line where locb-c-fin-statement-line.sttm-code = wt-c-fin-statement.sttm-code and
                               locb-c-fin-statement-line.host-code = wt-c-fin-statement.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-fin-statement-line.
  buffer-copy locb-c-fin-statement-line to buf_c-fin-statement-line.
end.
for each buf_c-fin-statement-attr where buf_c-fin-statement-attr.sttm-code = wt-c-fin-statement.sttm-code and
                              buf_c-fin-statement-attr.host-code = wt-c-fin-statement.host-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-fin-statement-attr.
end.
for each locb-c-fin-statement-attr where locb-c-fin-statement-attr.sttm-code = wt-c-fin-statement.sttm-code and
                               locb-c-fin-statement-attr.host-code = wt-c-fin-statement.host-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-fin-statement-attr.
  buffer-copy locb-c-fin-statement-attr to buf_c-fin-statement-attr.
end.
if not available tb-c-fin-statement then do:
  create tb-c-fin-statement.
end.
buffer-copy wt-c-fin-statement to tb-c-fin-statement.
for each locb-c-fin-statement-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-fin-statement-line.
end.
for each locb-c-fin-statement-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-fin-statement-attr.
end.
    delete wt-c-fin-statement.
  end.
END PROCEDURE.
define temp-table wt-firm no-undo like ub.firm.
PROCEDURE proc-load-firm:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-firm. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-firm. stop" )
  on endkey undo, return error substitute( "$proc-load-firm. endkey" )
  :
    define buffer tb-firm for ub.firm.
    define variable compare-log as logical no-undo.
define variable vss-include-info80 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-l as logical no-undo .
define buffer buf_dis-card for ub.dis-card .
    for each wt-firm
    on error undo, return error substitute( "$proc-load-firm(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-firm .
    end.
    create wt-firm.
    run nws-impl in p-imp-handle
      ( input 'firm':U
       ,input (buffer wt-firm:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-firm
      where tb-firm.firm-code = wt-firm.firm-code
      exclusive-lock no-error.
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if not available tb-firm then do:
  create tb-firm.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-firm TO wt-firm case-sensitive save result in compare-log no-error.
end.
 buffer-compare tb-firm using city ind addres1 TO wt-firm case-sensitive save result in v-l no-error.
if not compare-log then do:
  buffer-copy wt-firm TO tb-firm.
end.
if not v-l then do:
  for each buf_dis-card no-lock where
           buf_dis-card.cli-type = 'орг':U
       AND buf_dis-card.cli-code = tb-firm.firm-code:
    run fill-dc-list in p-imp-handle ( buffer buf_Dis-card).
  end.
end.
    delete wt-firm.
  end.
END PROCEDURE.
define variable vss-include-info82 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure update-service-price :
  define input  parameter p-obj-type   as character no-undo .
  define input  parameter p-obj-code   as integer   no-undo .
  define input  parameter p-artic      as character no-undo .
  define input  parameter p-prod-type  as character no-undo .
  define input  parameter p-prod-code  as integer   no-undo .
  define input  parameter p-price-base as decimal   no-undo .
  define input  parameter p-price-rubl as decimal   no-undo .
  define buffer buf_gds-obj for ub.gds-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
    find current buf_gds-obj exclusive-lock .
    assign
      buf_gds-obj.price-base = p-price-base
      buf_gds-obj.price-rubl = p-price-rubl
    .
    if g#db-num = 0
    then do:
      run str/callnews.p
        (input 'gds-obj':U
        ,input (buffer buf_gds-obj:handle)
        ).
    end.
  end.
end procedure.
define temp-table wt-gds-obj no-undo like ub.gds-obj.
PROCEDURE proc-load-gds-obj:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-gds-obj. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-gds-obj. stop" )
  on endkey undo, return error substitute( "$proc-load-gds-obj. endkey" )
  :
    define buffer tb-gds-obj for ub.gds-obj.
    define variable compare-log as logical no-undo.
    for each wt-gds-obj
    on error undo, return error substitute( "$proc-load-gds-obj(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-gds-obj .
    end.
    create wt-gds-obj.
    run nws-impl in p-imp-handle
      ( input 'gds-obj':U
       ,input (buffer wt-gds-obj:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-gds-obj
      where tb-gds-obj.obj-type = wt-gds-obj.obj-type
        and tb-gds-obj.obj-code = wt-gds-obj.obj-code
        and tb-gds-obj.artic = wt-gds-obj.artic
        and tb-gds-obj.prod-type = wt-gds-obj.prod-type
        and tb-gds-obj.prod-code = wt-gds-obj.prod-code
      exclusive-lock no-error.
define variable vss-include-info84 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run update-service-price in this-procedure
  (input wt-gds-obj.obj-type
  ,input wt-gds-obj.obj-code
  ,input wt-gds-obj.artic
  ,input wt-gds-obj.prod-type
  ,input wt-gds-obj.prod-code
  ,input wt-gds-obj.price-base
  ,input wt-gds-obj.price-rubl
  ) .
    delete wt-gds-obj.
  end.
END PROCEDURE.
define variable vss-include-info85 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table locb-gds-obj-attr      no-undo like ub.gds-obj-attr.
define temp-table wt-gds-obj-attr no-undo like ub.gds-obj-attr.
PROCEDURE proc-load-gds-obj-attr:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-gds-obj-attr. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-gds-obj-attr. stop" )
  on endkey undo, return error substitute( "$proc-load-gds-obj-attr. endkey" )
  :
    define buffer tb-gds-obj-attr for ub.gds-obj-attr.
    define variable compare-log as logical no-undo.
define variable vss-include-info86 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-type           as character no-undo .
define variable v-format         as character no-undo .
define variable v-label          as character no-undo .
define variable v-user-can-edit  as logical   no-undo .
define variable v-output-display as logical   no-undo .
define variable v-other          as character no-undo .
define variable jj as integer no-undo .
define variable v-dop1 as character no-undo .
define variable v-dop2 as character no-undo .
define buffer buf_goods for ub.goods.
for each locb-gds-obj-attr
on error undo, return error error-status :get-message (1)
:
  delete locb-gds-obj-attr.
end.
    for each wt-gds-obj-attr
    on error undo, return error substitute( "$proc-load-gds-obj-attr(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-gds-obj-attr .
    end.
    create wt-gds-obj-attr.
    run nws-impl in p-imp-handle
      ( input 'gds-obj-attr':U
       ,input (buffer wt-gds-obj-attr:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-gds-obj-attr
      where tb-gds-obj-attr.obj-type = wt-gds-obj-attr.obj-type
        and tb-gds-obj-attr.obj-code = wt-gds-obj-attr.obj-code
        and tb-gds-obj-attr.gds-code = wt-gds-obj-attr.gds-code
        and tb-gds-obj-attr.attr-code = wt-gds-obj-attr.attr-code
      exclusive-lock no-error.
define variable vss-include-info87 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if not available tb-gds-obj-attr then do:
  create tb-gds-obj-attr.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-gds-obj-attr TO wt-gds-obj-attr case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-gds-obj-attr TO tb-gds-obj-attr.
    run gdsoattr-name in p-imp-handle
      ( input  tb-gds-obj-attr.attr-code
        ,output v-type
        ,output v-format
        ,output v-label
        ,output v-user-can-edit
        ,output v-output-display
        ,output v-other
      ) .
  _do:
  do jj = 1 to num-entries(v-other, chr(47)):
    assign
    v-dop1 = entry(1, entry(jj, v-other, chr(47)), '=':U)
    .
    if v-dop1 = "cd":U then do:
      run fill-g-list in p-imp-handle ( input tb-gds-obj-attr.gds-code
                                      ,input tb-gds-obj-attr.obj-type
                                      ,input tb-gds-obj-attr.obj-code
                                      ).
      LEAVE _do.
    end.
  end.
end.
    delete wt-gds-obj-attr.
  end.
END PROCEDURE.
define temp-table wt-assortment-matrix no-undo like ub.assortment-matrix.
PROCEDURE proc-load-assortment-matrix:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-assortment-matrix. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-assortment-matrix. stop" )
  on endkey undo, return error substitute( "$proc-load-assortment-matrix. endkey" )
  :
    define buffer tb-assortment-matrix for ub.assortment-matrix.
    define variable compare-log as logical no-undo.
define variable vss-include-info88 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_old_assortment-matrix for ub.assortment-matrix  .
    for each wt-assortment-matrix
    on error undo, return error substitute( "$proc-load-assortment-matrix(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-assortment-matrix .
    end.
    create wt-assortment-matrix.
    run nws-impl in p-imp-handle
      ( input 'assortment-matrix':U
       ,input (buffer wt-assortment-matrix:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-assortment-matrix
      where tb-assortment-matrix.asmt-id = wt-assortment-matrix.asmt-id
        and tb-assortment-matrix.db-num = wt-assortment-matrix.db-num
      exclusive-lock no-error.
define variable vss-include-info89 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  if l-counter <> 0 then do:
  return error vss-workfile + chr(32)
              + vss-revision + chr(32)
              + vss-description + chr(10)
              + "Ошибка обработки записи" + chr(32)
              + 'assortment-matrix':U + chr(10)
              + "Есть привязанные записи, а обработка идет для одной".
  end.
  if g#news then do:
     if wt-assortment-matrix.asmt-type = 'Объект':U and wt-assortment-matrix.asmt-status = 0  then do:
        find first buf_old_assortment-matrix no-lock where
                   buf_old_assortment-matrix.asmt-status = 0 and
                   not
                  ( buf_old_assortment-matrix.asmt-id    = wt-assortment-matrix.asmt-id  and
                    buf_old_assortment-matrix.db-num     = wt-assortment-matrix.db-num )
                    and
                   buf_old_assortment-matrix.obj-type    = wt-assortment-matrix.obj-type and
                   buf_old_assortment-matrix.obj-code    = wt-assortment-matrix.obj-code and
                   buf_old_assortment-matrix.asmt-type    = wt-assortment-matrix.asmt-type no-error .
        if available buf_old_assortment-matrix then do:
        if g#db-num = 0  then
           run write-to-log in p-imp-handle (
           substitute(">> Пришедшая АМ: &1 по объекту &2&3 противоречит существующей АМ: &4 , АМ УБД будет принята в статусе УДАЛЕНа <<" ,
           wt-assortment-matrix.asmt-id,
           wt-assortment-matrix.obj-type,
           wt-assortment-matrix.obj-code,
           buf_old_assortment-matrix.asmt-id )) .
         else
           run write-to-log in p-imp-handle (
           substitute(">> Пришедшая АМ: &1 по объекту &2&3 противоречит существующей АМ: &4 , статус АМ УБД в следующем сеансе связи будет изменен на УДАЛЕН <<" ,
           wt-assortment-matrix.asmt-id,
           wt-assortment-matrix.obj-type,
           wt-assortment-matrix.obj-code,
           buf_old_assortment-matrix.asmt-id )) .
       end.
     end.
  end.
  if not available tb-assortment-matrix then do:
    create tb-assortment-matrix.
    assign compare-log = no.
  end.
  else do:
    buffer-compare tb-assortment-matrix TO wt-assortment-matrix case-sensitive save result in compare-log no-error.
  end.
  if not compare-log then do:
    buffer-copy wt-assortment-matrix TO tb-assortment-matrix.
  end.
    delete wt-assortment-matrix.
  end.
END PROCEDURE.
define temp-table wt-gds-grp-obj-attr no-undo like ub.gds-grp-obj-attr.
PROCEDURE proc-load-gds-grp-obj-attr:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-gds-grp-obj-attr. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-gds-grp-obj-attr. stop" )
  on endkey undo, return error substitute( "$proc-load-gds-grp-obj-attr. endkey" )
  :
    define buffer tb-gds-grp-obj-attr for ub.gds-grp-obj-attr.
    define variable compare-log as logical no-undo.
    for each wt-gds-grp-obj-attr
    on error undo, return error substitute( "$proc-load-gds-grp-obj-attr(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-gds-grp-obj-attr .
    end.
    create wt-gds-grp-obj-attr.
    run nws-impl in p-imp-handle
      ( input 'gds-grp-obj-attr':U
       ,input (buffer wt-gds-grp-obj-attr:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-gds-grp-obj-attr
      where tb-gds-grp-obj-attr.node-code = wt-gds-grp-obj-attr.node-code
        and tb-gds-grp-obj-attr.host-code = wt-gds-grp-obj-attr.host-code
        and tb-gds-grp-obj-attr.obj-type = wt-gds-grp-obj-attr.obj-type
        and tb-gds-grp-obj-attr.obj-code = wt-gds-grp-obj-attr.obj-code
        and tb-gds-grp-obj-attr.attr-code = wt-gds-grp-obj-attr.attr-code
      exclusive-lock no-error.
define variable vss-include-info90 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer bf_clients for ub.clients .
define variable v-obj-code as integer no-undo .
  if l-counter <> 0 then do:
  return error vss-workfile + chr(32)
              + vss-revision + chr(32)
              + vss-description + chr(10)
              + "Ошибка обработки записи" + chr(32)
              + 'gds-grp-obj-attr':U + chr(10)
              + "Есть привязанные записи, а обработка идет для одной".
  end.
    if wt-gds-grp-obj-attr.attr-code <> 'QntyAssMat':U  then do:
    if not available tb-gds-grp-obj-attr then do:
      create tb-gds-grp-obj-attr.
      assign compare-log = no.
    end.
    else do:
      buffer-compare tb-gds-grp-obj-attr TO wt-gds-grp-obj-attr case-sensitive save result in compare-log no-error.
    end.
    if not compare-log then do:
      buffer-copy wt-gds-grp-obj-attr TO tb-gds-grp-obj-attr.
      if   (    tb-gds-grp-obj-attr.attr-code  = 'ban-sales-via-cd':U
            and tb-gds-grp-obj-attr.attr-value = "yes")
         or tb-gds-grp-obj-attr.attr-code = 'emrc-type':U
      then do:
         for each ub.goods no-lock where ub.goods.grp-code = tb-gds-grp-obj-attr.node-code:
             run fill-g-list in  p-imp-handle  ( input ub.goods.gds-code, input tb-gds-grp-obj-attr.obj-type, input tb-gds-grp-obj-attr.obj-code).
         end.
      end.
    end.
  end.
    delete wt-gds-grp-obj-attr.
  end.
END PROCEDURE.
define temp-table locb-global-state no-undo like ub.global-state.
define temp-table locb-global-state-attr no-undo like ub.global-state-attr.
define temp-table locb-c-global-state-attr no-undo like ub.c-global-state-attr.
define temp-table locb-c-global-state no-undo like ub.c-global-state.
define temp-table wt-global-state no-undo like ub.global-state.
PROCEDURE proc-load-global-state:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-global-state. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-global-state. stop" )
  on endkey undo, return error substitute( "$proc-load-global-state. endkey" )
  :
    define buffer tb-global-state for ub.global-state.
    define variable compare-log as logical no-undo.
define variable vss-include-info91 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_global-state        for ub.global-state.
define buffer buf_global-state-attr   for ub.global-state-attr.
define buffer buf_c-global-state      for ub.c-global-state.
define buffer buf_c-global-state-attr for ub.c-global-state-attr.
define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.
for each locb-global-state
on error  undo, return error
:
  delete locb-global-state.
end.
for each locb-c-global-state
on error  undo, return error
:
  delete locb-c-global-state.
end.
for each locb-global-state-attr
on error  undo, return error
:
  delete locb-global-state-attr.
end.
for each locb-c-global-state-attr
on error  undo, return error
:
  delete locb-c-global-state-attr.
end.
    for each wt-global-state
    on error undo, return error substitute( "$proc-load-global-state(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-global-state .
    end.
    create wt-global-state.
    run nws-impl in p-imp-handle
      ( input 'global-state':U
       ,input (buffer wt-global-state:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-global-state
      where tb-global-state.gls-id = wt-global-state.gls-id
      exclusive-lock no-error.
define variable vss-include-info92 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "global-state-attr" then do:
      create locb-global-state-attr.
run nws-impl in p-imp-handle
  ( input "global-state-attr":U
   ,input (buffer locb-global-state-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-global-state" then do:
      create locb-c-global-state.
run nws-impl in p-imp-handle
  ( input "c-global-state":U
   ,input (buffer locb-c-global-state:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-global-state-attr" then do:
      create locb-c-global-state-attr.
run nws-impl in p-imp-handle
  ( input "c-global-state-attr":U
   ,input (buffer locb-c-global-state-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_c-global-state where buf_c-global-state.gls-id = wt-global-state.gls-id
on error  undo, return error
:
  delete buf_c-global-state.
end.
for each locb-c-global-state where locb-c-global-state.gls-id = wt-global-state.gls-id   no-lock
on error  undo, return error
:
  create buf_c-global-state.
  buffer-copy  locb-c-global-state to buf_c-global-state.
end.
for each buf_global-state-attr where buf_global-state-attr.gls-id = wt-global-state.gls-id
on error  undo, return error
:
  delete buf_global-state-attr.
end.
for each locb-global-state-attr where locb-global-state-attr.gls-id = wt-global-state.gls-id
no-lock
on error  undo, return error
:
  create buf_global-state-attr.
  buffer-copy locb-global-state-attr to buf_global-state-attr.
end.
for each buf_c-global-state-attr where buf_c-global-state-attr.gls-id = wt-global-state.gls-id
on error  undo, return error
:
  delete buf_c-global-state-attr.
end.
for each locb-c-global-state-attr where locb-c-global-state-attr.gls-id = wt-global-state.gls-id
no-lock
on error  undo, return error
:
  create buf_c-global-state-attr.
  buffer-copy locb-c-global-state-attr to buf_c-global-state-attr.
end.
if not available tb-global-state then do:
  create tb-global-state.
end.
buffer-copy wt-global-state to tb-global-state.
for each locb-c-global-state
on error  undo, return error
:
  delete locb-c-global-state.
end.
for each locb-global-state-attr
on error  undo, return error
:
  delete locb-global-state-attr.
end.
for each locb-c-global-state-attr
on error  undo, return error
:
  delete locb-c-global-state-attr.
end.
    delete wt-global-state.
  end.
END PROCEDURE.
def var vss-include-info93 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table locb-bar-code     no-undo like ub.bar-code.
define temp-table locb-prod-bc      no-undo like ub.prod-bc.
define temp-table locb-tax-rate-gds      no-undo like ub.tax-rate-gds.
define temp-table wt-goods no-undo like ub.goods.
PROCEDURE proc-load-goods:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-goods. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-goods. stop" )
  on endkey undo, return error substitute( "$proc-load-goods. endkey" )
  :
    define buffer tb-goods for ub.goods.
    define variable compare-log as logical no-undo.
define variable vss-include-info94 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_bar-code     for ub.bar-code .
define buffer buf_prod-bc      for ub.prod-bc .
define buffer buf_tax-rate-gds      for ub.tax-rate-gds .
define buffer dst-units        for ub.units .
define buffer src-units        for ub.units .
define variable counter        as   integer           no-undo .
define variable rec-full       as   character         no-undo .
define variable rec-name       as   character         no-undo .
define variable the-same-goods as   logical           no-undo .
define variable imp-goods      as   logical           no-undo .
define variable load-tax       as   logical           no-undo .
define variable error-message  as   character         no-undo .
define variable old-gds-code   like ub.goods.gds-code no-undo .
define variable v-cmd          as   character         no-undo .
for each locb-bar-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info94, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info94 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info94 )
:
  delete locb-bar-code.
end.
for each locb-prod-bc
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info94, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info94 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info94 )
:
  delete locb-prod-bc.
end.
for each locb-tax-rate-gds
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info94, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info94 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info94 )
:
  delete locb-tax-rate-gds.
end.
    for each wt-goods
    on error undo, return error substitute( "$proc-load-goods(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-goods .
    end.
    create wt-goods.
    run nws-impl in p-imp-handle
      ( input 'goods':U
       ,input (buffer wt-goods:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-goods
      where tb-goods.gds-code = wt-goods.gds-code
      exclusive-lock no-error.
define variable vss-include-info95 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "bar-code" then do:
      create locb-bar-code.
      run nws-impl-without-check in p-imp-handle
        ( input (buffer locb-bar-code:handle)
        ) no-error.
      if error-status :error then do:
        return error return-value .
      end.
    end.
    when "prod-bc" then do:
      create locb-prod-bc.
      run nws-impl-without-check in p-imp-handle
        ( input (buffer locb-prod-bc:handle)
        ) no-error.
      if error-status :error then do:
        return error return-value .
      end.
    end.
    when "tax-rate-gds" then do:
      create locb-tax-rate-gds.
      run nws-impl-without-check in p-imp-handle
        ( input (buffer locb-tax-rate-gds:handle)
        ) no-error.
      if error-status :error then do:
        return error return-value .
      end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе товара."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
assign
  imp-goods = FALSE
  load-tax  = TRUE
  .
do while imp-goods = FALSE
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  find tb-goods where tb-goods.gds-code = wt-goods.gds-code
                exclusive-lock no-error.
  if available tb-goods then do:
    if tb-goods.artic = wt-goods.artic
       and tb-goods.prod-type = wt-goods.prod-type
       and tb-goods.prod-code = wt-goods.prod-code
    then do:
      if g#db-num = 0 and lookup( string( tb-goods.stts ), '50,51' ) <> 0 then do:   buffer-copy wt-goods     except wt-goods.stts     to tb-goods. end. else do:   buffer-copy wt-goods to tb-goods. end.
      assign imp-goods = TRUE.
      run fill-g-list in  p-imp-handle  ( input tb-goods.gds-code, input '':U, input 0).
    end.
    else do:
      run write-to-log in this-procedure (input "Системная ошибка!!! Не совпадает артикул или(и) производитель при совпадении кода товара." ).
      return error.
    end.
  end.
  else do:
    find tb-goods where tb-goods.artic     = wt-goods.artic
                    and tb-goods.prod-type = wt-goods.prod-type
                    and tb-goods.prod-code = wt-goods.prod-code
                  no-error.
    if available tb-goods then do:
      find current tb-goods exclusive-lock.
assign the-same-goods = FALSE.
if tb-goods.prt-root = wt-goods.prt-root
then do:
  if tb-goods.unit-base = wt-goods.unit-base then do:
    assign the-same-goods = TRUE.
  end.
end.
      if the-same-goods then do:
        if g#db-num = 0 then do:
          assign
            v-cmd = string( "command" + chr(1) + "goods" + chr(1) + "ren-gds-code"
                            + chr(1) + string( wt-goods.gds-code )
                            + chr(1) + string( tb-goods.gds-code )
                           )
            .
          run nws/cr-route.p ( input 'send-cmd':U, input v-cmd, input ?, input string( g#news-source-db ) ).
          assign
            load-tax = FALSE
          .
          run write-to-log in this-procedure (input "Пришедший товар (gds-code) " + string( wt-goods.gds-code )
                            + " заменен на " + string( tb-goods.gds-code ) + "." ).
        end.
        else do:
          assign
            old-gds-code = tb-goods.gds-code
          .
          run utl/ren-gdsc.p
            ( input old-gds-code
             ,input wt-goods.gds-code
            ) no-error .
          if error-status :error then do:
            run write-to-log in this-procedure
              (input "Не удалось заменить gds-code существовавшего товара " + string( old-gds-code )
                     + " на " + string( wt-goods.gds-code ) + "." + chr(10)
                     + return-value + chr(10) + error-status:get-message(1)
              ).
            return error.
          end.
          run write-to-log in this-procedure (input "Существовавший товар (gds-code) " + string( old-gds-code )
                            + " заменен на " + string( wt-goods.gds-code ) + "." ).
          if g#db-num = 0 and lookup( string( tb-goods.stts ), '50,51' ) <> 0 then do:   buffer-copy wt-goods     except wt-goods.stts     to tb-goods. end. else do:   buffer-copy wt-goods to tb-goods. end.
        end.
        assign imp-goods = TRUE.
      end.
      else do:
        if g#db-num = 0 then do:
          if g#auto = true then do:
            run write-to-log in this-procedure (input "Коллизия! Дождитесь разбора коллизий в УБД." ).
            return error.
          end.
          else do:
            run write-to-log in this-procedure (input "Коллизия! Дождитесь разбора коллизий в УБД и повторите прием пакета." ).
            return error.
          end.
        end.
        else do:
          run write-to-log in this-procedure (input "Коллизия! Необходимо изменить артикул и(или) производителя у товара." + chr(10)
                            + tb-goods.gds-name + chr(10)
                            + tb-goods.artic + " " + tb-goods.prod-type + " " + string( tb-goods.prod-code ) + "." + chr(10)
                          ).
          if g#auto = true then do:
            run write-to-log in this-procedure (input "Для этого запустите ручной разбор пакета." ).
            return error.
          end.
          else do:
            message "Коллизия! Необходимо изменить артикул и(или) производителя у товара." skip
                    tb-goods.gds-name skip
                    tb-goods.artic + " " + tb-goods.prod-type + " " + string( tb-goods.prod-code ) + "." skip
                    view-as alert-box.
            run utl/new-art.w ( input ?
                           ,input tb-goods.artic
                           ,input tb-goods.prod-type
                           ,input tb-goods.prod-code
                          ) no-error.
            if return-value <> "" then do:
              run write-to-log in this-procedure (input "Артикул не изменен " + rec-full ).
              message "Артикул не изменен " + rec-full
                      view-as alert-box.
              return error.
            end.
          end.
        end.
      end.
    end.
    else do:
      create tb-goods.
      buffer-copy wt-goods to tb-goods.
      assign imp-goods = TRUE.
    end.
  end.
end.
for each locb-bar-code where locb-bar-code.gds-code = wt-goods.gds-code
on error  undo, return error
:
  run check-avail-gds-code in p-imp-handle
    ( input-output locb-bar-code.gds-code
    ).
  run create-bar-code in p-imp-handle
    ( input locb-bar-code.b-code
     ,input locb-bar-code.cli-base-rate
     ,input locb-bar-code.gds-code
     ,input locb-bar-code.in-code
     ,input locb-bar-code.node-code
     ,input locb-bar-code.part-code
     ,input locb-bar-code.unit-cli
     ,input locb-bar-code.cr-db-num
    ).
  for each locb-prod-bc where locb-prod-bc.b-code = locb-bar-code.b-code
  on error  undo, return error
  :
    run check-avail-b-code in p-imp-handle
      ( input-output locb-prod-bc.b-code
      ).
    run create-prod-bc in p-imp-handle
      ( input locb-prod-bc.b-code
       ,input locb-prod-bc.b-str
       ,input yes
       ,input locb-prod-bc.cr-db-num
       ,input locb-prod-bc.bc-on-type
      ).
  end.
end.
if load-tax then do:
  for each locb-tax-rate-gds no-lock
    where locb-tax-rate-gds.gds-code     = wt-goods.gds-code
  on error  undo, return error
  :
    find FIRST buf_tax-rate-gds where
              buf_tax-rate-gds.gds-code     = locb-tax-rate-gds.gds-code
          and buf_tax-rate-gds.tax-code  = locb-tax-rate-gds.tax-code
          AND buf_tax-rate-gds.host-code = locb-tax-rate-gds.host-code
          AND buf_tax-rate-gds.obj-type  = locb-tax-rate-gds.obj-type
          AND buf_tax-rate-gds.obj-code  = locb-tax-rate-gds.obj-code
          AND buf_tax-rate-gds.fact-order  = locb-tax-rate-gds.fact-order
                     exclusive-lock no-error.
    if not available buf_tax-rate-gds then do:
      create buf_tax-rate-gds.
    end.
    buffer-copy locb-tax-rate-gds to buf_tax-rate-gds.
  end.
end.
for each locb-bar-code
on error  undo, return error
:
  delete locb-bar-code.
end.
for each locb-prod-bc
on error  undo, return error
:
  delete locb-prod-bc.
end.
for each locb-tax-rate-gds
on error  undo, return error
:
  delete locb-tax-rate-gds.
end.
    delete wt-goods.
  end.
END PROCEDURE.
define temp-table wt-goods-attr no-undo like ub.goods-attr.
PROCEDURE proc-load-goods-attr:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-goods-attr. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-goods-attr. stop" )
  on endkey undo, return error substitute( "$proc-load-goods-attr. endkey" )
  :
    define buffer tb-goods-attr for ub.goods-attr.
    define variable compare-log as logical no-undo.
    for each wt-goods-attr
    on error undo, return error substitute( "$proc-load-goods-attr(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-goods-attr .
    end.
    create wt-goods-attr.
    run nws-impl in p-imp-handle
      ( input 'goods-attr':U
       ,input (buffer wt-goods-attr:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-goods-attr
      where tb-goods-attr.gds-code = wt-goods-attr.gds-code
        and tb-goods-attr.attr-code = wt-goods-attr.attr-code
      exclusive-lock no-error.
define variable vss-include-info96 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-type           as character no-undo .
define variable v-format         as character no-undo .
define variable v-label          as character no-undo .
define variable v-user-can-edit  as logical   no-undo .
define variable v-output-display as logical   no-undo .
define variable v-other          as character no-undo .
define variable jj as integer no-undo .
define variable v-dop1 as character no-undo .
if not available tb-goods-attr then do:
  create tb-goods-attr.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-goods-attr TO wt-goods-attr case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-goods-attr TO tb-goods-attr.
         if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
        ( input  tb-goods-attr.attr-code
        ,output v-type
        ,output v-format
        ,output v-label
        ,output v-user-can-edit
        ,output v-output-display
        ,output v-other
      ) .
  _do:
  do jj = 1 to num-entries(v-other, chr(47)):
    assign
    v-dop1 = entry(1, entry(jj, v-other, chr(47)), '=':U)
    .
    if v-dop1 = "cd":U then do:
      run fill-g-list in p-imp-handle ( input tb-goods-attr.gds-code
                                       ,input ""
                                       ,input 0
                                      ).
      LEAVE _do.
    end.
  end.
end.
    delete wt-goods-attr.
  end.
END PROCEDURE.
define  temp-table locb-db-grp-obj-price   no-undo like  ub.db-grp-obj-price  .
define  temp-table locb-host-grp-obj-price no-undo like  ub.host-grp-obj-price.
define  temp-table locb-obj-grp-obj-price  no-undo like  ub.obj-grp-obj-price .
define  temp-table locb-grp-obj-price      no-undo like  ub.grp-obj-price     .
define temp-table wt-grp-obj-price no-undo like ub.grp-obj-price.
PROCEDURE proc-load-grp-obj-price:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-grp-obj-price. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-grp-obj-price. stop" )
  on endkey undo, return error substitute( "$proc-load-grp-obj-price. endkey" )
  :
    define buffer tb-grp-obj-price for ub.grp-obj-price.
    define variable compare-log as logical no-undo.
define variable vss-include-info97 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_db-grp-obj-price    for ub.db-grp-obj-price  .
define buffer buf_host-grp-obj-price  for ub.host-grp-obj-price.
define buffer buf_obj-grp-obj-price   for ub.obj-grp-obj-price .
define buffer buf_grp-obj-price       for ub.grp-obj-price     .
define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.
for each locb-grp-obj-price
on error  undo, return error
:
  delete locb-grp-obj-price.
end.
for each locb-db-grp-obj-price
on error  undo, return error
:
  delete locb-db-grp-obj-price.
end.
for each locb-host-grp-obj-price
on error  undo, return error
:
  delete locb-host-grp-obj-price.
end.
for each locb-obj-grp-obj-price
on error  undo, return error
:
  delete locb-obj-grp-obj-price.
end.
    for each wt-grp-obj-price
    on error undo, return error substitute( "$proc-load-grp-obj-price(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-grp-obj-price .
    end.
    create wt-grp-obj-price.
    run nws-impl in p-imp-handle
      ( input 'grp-obj-price':U
       ,input (buffer wt-grp-obj-price:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-grp-obj-price
      where tb-grp-obj-price.gop-id = wt-grp-obj-price.gop-id
        and tb-grp-obj-price.gop-db-num = wt-grp-obj-price.gop-db-num
      exclusive-lock no-error.
define variable vss-include-info98 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "db-grp-obj-price" then do:
      create locb-db-grp-obj-price.
run nws-impl in p-imp-handle
  ( input "db-grp-obj-price":U
   ,input (buffer locb-db-grp-obj-price:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "host-grp-obj-price" then do:
      create locb-host-grp-obj-price.
run nws-impl in p-imp-handle
  ( input "host-grp-obj-price":U
   ,input (buffer locb-host-grp-obj-price:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "obj-grp-obj-price" then do:
      create locb-obj-grp-obj-price.
run nws-impl in p-imp-handle
  ( input "obj-grp-obj-price":U
   ,input (buffer locb-obj-grp-obj-price:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_host-grp-obj-price where buf_host-grp-obj-price.gop-id = wt-grp-obj-price.gop-id
                            and buf_host-grp-obj-price.gop-db-num = wt-grp-obj-price.gop-db-num
on error  undo, return error
:
  delete buf_host-grp-obj-price.
end.
for each locb-host-grp-obj-price where locb-host-grp-obj-price.gop-id     = wt-grp-obj-price.gop-id
                             and locb-host-grp-obj-price.gop-db-num = wt-grp-obj-price.gop-db-num
  no-lock
on error  undo, return error
:
  create buf_host-grp-obj-price.
  buffer-copy  locb-host-grp-obj-price to buf_host-grp-obj-price.
end.
for each buf_obj-grp-obj-price where buf_obj-grp-obj-price.gop-id     = wt-grp-obj-price.gop-id
                                  and buf_obj-grp-obj-price.gop-db-num = wt-grp-obj-price.gop-db-num
on error  undo, return error
:
  delete buf_obj-grp-obj-price.
end.
for each locb-obj-grp-obj-price where locb-obj-grp-obj-price.gop-id     = wt-grp-obj-price.gop-id
                                    and locb-obj-grp-obj-price.gop-db-num = wt-grp-obj-price.gop-db-num
no-lock
on error  undo, return error
:
  create buf_obj-grp-obj-price.
  buffer-copy locb-obj-grp-obj-price to buf_obj-grp-obj-price.
end.
for each buf_db-grp-obj-price where buf_db-grp-obj-price.gop-id     = wt-grp-obj-price.gop-id
                                and buf_db-grp-obj-price.gop-db-num = wt-grp-obj-price.gop-db-num
on error  undo, return error
:
  delete buf_db-grp-obj-price.
end.
for each locb-db-grp-obj-price where locb-db-grp-obj-price.gop-id = wt-grp-obj-price.gop-id
                                    and locb-db-grp-obj-price.gop-db-num = wt-grp-obj-price.gop-db-num
no-lock
on error  undo, return error
:
  create buf_db-grp-obj-price.
  buffer-copy locb-db-grp-obj-price to buf_db-grp-obj-price.
end.
if not available tb-grp-obj-price then do:
  create tb-grp-obj-price.
end.
buffer-copy wt-grp-obj-price to tb-grp-obj-price.
for each locb-db-grp-obj-price
on error  undo, return error
:
  delete locb-db-grp-obj-price.
end.
for each locb-host-grp-obj-price
on error  undo, return error
:
  delete locb-host-grp-obj-price.
end.
for each locb-obj-grp-obj-price
on error  undo, return error
:
  delete locb-obj-grp-obj-price.
end.
    delete wt-grp-obj-price.
  end.
END PROCEDURE.
define temp-table locb-icnt-line     no-undo like ub.icnt-line.
define temp-table locbi-doc-attr      no-undo like ub.doc-attr.
define temp-table wt-icnt-doc no-undo like ub.icnt-doc.
PROCEDURE proc-load-icnt-doc:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-icnt-doc. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-icnt-doc. stop" )
  on endkey undo, return error substitute( "$proc-load-icnt-doc. endkey" )
  :
    define buffer tb-icnt-doc for ub.icnt-doc.
    define variable compare-log as logical no-undo.
define variable vss-include-info99 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_icnt-line      for ub.icnt-line.
define buffer buf_doc-attr       for ub.doc-attr.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
for each locb-icnt-line
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info99, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info99 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info99 )
:
  delete locb-icnt-line.
end.
for each locbi-doc-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info99, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info99 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info99 )
:
  delete locbi-doc-attr.
end.
    for each wt-icnt-doc
    on error undo, return error substitute( "$proc-load-icnt-doc(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-icnt-doc .
    end.
    create wt-icnt-doc.
    run nws-impl in p-imp-handle
      ( input 'icnt-doc':U
       ,input (buffer wt-icnt-doc:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-icnt-doc
      where tb-icnt-doc.doc-code = wt-icnt-doc.doc-code
      exclusive-lock no-error.
define variable vss-include-info100 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "icnt-line" then do:
      create locb-icnt-line.
run nws-impl in p-imp-handle
  ( input "icnt-line":U
   ,input (buffer locb-icnt-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "doc-attr" then do:
      create locbi-doc-attr.
run nws-impl in p-imp-handle
  ( input "doc-attr":U
   ,input (buffer locbi-doc-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе документов инв. счетчиков ТРК."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_icnt-line where buf_icnt-line.doc-code = wt-icnt-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_icnt-line.
end.
for each locb-icnt-line where locb-icnt-line.doc-code = wt-icnt-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_icnt-line.
  buffer-copy locb-icnt-line to buf_icnt-line.
end.
for each buf_doc-attr where buf_doc-attr.doc-code = wt-icnt-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_doc-attr.
end.
for each locbi-doc-attr where locbi-doc-attr.doc-code = wt-icnt-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_doc-attr.
  buffer-copy locbi-doc-attr to buf_doc-attr.
end.
if not available tb-icnt-doc then do:
  create tb-icnt-doc.
end.
define variable v-old-icnt-doc-status as character no-undo .
define variable v-new-icnt-doc-status as character no-undo .
if tb-icnt-doc.status_ = ""
or tb-icnt-doc.status_ = ?
then do:
  assign
    v-old-icnt-doc-status = ""
  .
end.
else do:
  assign
    v-old-icnt-doc-status = tb-icnt-doc.status_ + string(tb-icnt-doc.flag_, '+/-':u)
  .
end.
assign
  v-new-icnt-doc-status = wt-icnt-doc.status_ + string(wt-icnt-doc.flag_, '+/-':u)
.
run trg/nwsdochs.p
  (input g#db-num
  ,input 'update':U
  ,input wt-icnt-doc.doc-code
  ,input wt-icnt-doc.obj-type
  ,input wt-icnt-doc.obj-code
  ,input 'icnt-doc':U
  ,input wt-icnt-doc.ext-doc-type
  ,input wt-icnt-doc.fact-date
  ,input wt-icnt-doc.state-mh-cnt
  ,input 0
  ,input 0
  ,input 0
  ,input v-old-icnt-doc-status
  ,input v-new-icnt-doc-status
  ,input g#news-source-db
  ,input p-pck-num
  ,input wt-icnt-doc.user-db-num
  ,input wt-icnt-doc.user-name
  ,input wt-icnt-doc.sys-date
  ,input wt-icnt-doc.sys-time
  ,input wt-icnt-doc.sys-time-int
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.
buffer-copy wt-icnt-doc to tb-icnt-doc.
for each locb-icnt-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-icnt-line.
end.
for each locbi-doc-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbi-doc-attr.
end.
    delete wt-icnt-doc.
  end.
END PROCEDURE.
define temp-table locb-inkas-pay      no-undo like ub.inkas-pay.
define temp-table locb-inkas-pay-desk no-undo like ub.inkas-pay-desk.
define temp-table locb-inkas-pay-wth  no-undo like ub.inkas-pay-wth.
define temp-table locb-sale-doc       no-undo like ub.sale-doc.
define temp-table locb-chk-doc        no-undo like ub.chk-doc.
define temp-table locb-chk-gds        no-undo like ub.chk-gds.
define temp-table locb-chk-gds-attr   no-undo like ub.chk-gds-attr.
define temp-table locb-chk-pay        no-undo like ub.chk-pay.
define temp-table locb-chk-pay-attr     no-undo like ub.chk-pay-attr .
define temp-table locb-chk-discnt     no-undo like ub.chk-discnt.
define temp-table locb-chk-doc-attr   no-undo like ub.chk-doc-attr.
define temp-table locb-chk-gds-pay    no-undo like ub.chk-gds-pay.
define temp-table locb-chk-discnt-attr  no-undo like ub.chk-discnt-attr.
define temp-table locb-c-chk-doc        no-undo like ub.c-chk-doc.
define temp-table locb-c-chk-gds        no-undo like ub.c-chk-gds.
define temp-table locb-c-chk-pay        no-undo like ub.c-chk-pay.
define temp-table locb-c-chk-discnt     no-undo like ub.c-chk-discnt.
define temp-table locb-c-chk-doc-attr   no-undo like ub.c-chk-doc-attr.
define temp-table locb-c-inkas          no-undo like ub.c-inkas.
define temp-table locb-c-inkas-pay      no-undo like ub.c-inkas-pay.
define temp-table locb-c-inkas-pay-desk no-undo like ub.c-inkas-pay-desk.
define temp-table locb-c-inkas-pay-wth  no-undo like ub.c-inkas-pay-wth.
define temp-table locb-c-sale-doc       no-undo like ub.c-sale-doc.
define variable vss-include-info101 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define temp-table wt-inkas no-undo like ub.inkas.
PROCEDURE proc-load-inkas:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-inkas. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-inkas. stop" )
  on endkey undo, return error substitute( "$proc-load-inkas. endkey" )
  :
    define buffer tb-inkas for ub.inkas.
    define variable compare-log as logical no-undo.
define variable vss-include-info102 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_inkas-pay      for ub.inkas-pay.
define buffer buf_inkas-pay-desk for ub.inkas-pay-desk.
define buffer buf_inkas-pay-wth  for ub.inkas-pay-wth.
define buffer buf_sale-doc       for ub.sale-doc.
define buffer buf_c-sale-doc       for ub.c-sale-doc.
define buffer buf_chk-doc        for ub.chk-doc.
define buffer buf_chk-gds        for ub.chk-gds.
define buffer buf_chk-gds-attr   for ub.chk-gds-attr.
define buffer buf_chk-pay        for ub.chk-pay.
define buffer buf_chk-pay-attr   for ub.chk-pay-attr.
define buffer buf_chk-discnt     for ub.chk-discnt.
define buffer buf_chk-discnt-attr     for ub.chk-discnt-attr.
define buffer buf_chk-doc-attr   for ub.chk-doc-attr.
define buffer buf_chk-gds-pay    for ub.chk-gds-pay.
define buffer buf_c-chk-doc        for ub.c-chk-doc.
define buffer buf_c-chk-gds        for ub.c-chk-gds.
define buffer buf_c-chk-pay        for ub.c-chk-pay.
define buffer buf_c-chk-discnt     for ub.c-chk-discnt.
define buffer buf_c-chk-doc-attr   for ub.c-chk-doc-attr.
define buffer buf_c-inkas          for ub.c-inkas.
define buffer buf_c-inkas-pay      for ub.c-inkas-pay.
define buffer buf_c-inkas-pay-desk for ub.c-inkas-pay-desk.
define buffer buf_c-inkas-pay-wth  for ub.c-inkas-pay-wth.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
define variable v-need-saledc as logical no-undo .
for each locb-inkas-pay
on error undo, return error error-status :get-message (1)
:
  delete locb-inkas-pay.
end.
for each locb-inkas-pay-desk
on error undo, return error error-status :get-message (1)
:
  delete locb-inkas-pay-desk.
end.
for each locb-inkas-pay-wth
on error undo, return error error-status :get-message (1)
:
  delete locb-inkas-pay-wth.
end.
for each locb-sale-doc
on error undo, return error error-status :get-message (1)
:
  delete locb-sale-doc.
end.
for each locb-chk-doc
on error undo, return error error-status :get-message (1)
:
  delete locb-chk-doc.
end.
for each locb-chk-gds
on error undo, return error error-status :get-message (1)
:
  delete locb-chk-gds.
end.
for each locb-chk-pay
on error undo, return error error-status :get-message (1)
:
  delete locb-chk-pay.
end.
for each locb-chk-pay-attr
on error undo, return error error-status :get-message (1)
:
  delete locb-chk-pay-attr.
end.
for each locb-chk-discnt
on error undo, return error error-status :get-message (1)
:
  delete locb-chk-discnt.
end.
for each locb-chk-discnt-attr
on error undo, return error error-status :get-message (1)
:
  delete locb-chk-discnt-attr.
end.
for each locb-chk-doc-attr
on error undo, return error error-status :get-message (1)
:
  delete locb-chk-doc-attr.
end.
for each locb-chk-gds-pay
on error undo, return error error-status :get-message (1)
:
  delete locb-chk-gds-pay.
end.
for each locb-c-chk-doc
on error undo, return error error-status :get-message (1)
:
  delete locb-c-chk-doc.
end.
for each locb-c-chk-gds
on error undo, return error error-status :get-message (1)
:
  delete locb-c-chk-gds.
end.
for each locb-c-chk-pay
on error undo, return error error-status :get-message (1)
:
  delete locb-c-chk-pay.
end.
for each locb-c-chk-discnt
on error undo, return error error-status :get-message (1)
:
  delete locb-c-chk-discnt.
end.
for each locb-c-chk-doc-attr
on error undo, return error error-status :get-message (1)
:
  delete locb-c-chk-doc-attr.
end.
for each locb-c-inkas
on error undo, return error error-status :get-message (1)
:
  delete locb-c-inkas.
end.
for each locb-c-inkas-pay
on error undo, return error error-status :get-message (1)
:
  delete locb-c-inkas-pay.
end.
for each locb-c-inkas-pay-desk
on error undo, return error error-status :get-message (1)
:
  delete locb-c-inkas-pay-desk.
end.
for each locb-c-inkas-pay-wth
on error undo, return error error-status :get-message (1)
:
  delete locb-c-inkas-pay-wth.
end.
for each locb-c-sale-doc
on error undo, return error error-status :get-message (1)
:
  delete locb-c-sale-doc.
end.
    for each wt-inkas
    on error undo, return error substitute( "$proc-load-inkas(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-inkas .
    end.
    create wt-inkas.
    run nws-impl in p-imp-handle
      ( input 'inkas':U
       ,input (buffer wt-inkas:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-inkas
      where tb-inkas.inkas-code = wt-inkas.inkas-code
      exclusive-lock no-error.
define variable vss-include-info103 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "inkas-pay" then do:
      create locb-inkas-pay.
run nws-impl in p-imp-handle
  ( input "inkas-pay":U
   ,input (buffer locb-inkas-pay:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "inkas-pay-desk" then do:
      create locb-inkas-pay-desk.
run nws-impl in p-imp-handle
  ( input "inkas-pay-desk":U
   ,input (buffer locb-inkas-pay-desk:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "inkas-pay-wth" then do:
      create locb-inkas-pay-wth.
run nws-impl in p-imp-handle
  ( input "inkas-pay-wth":U
   ,input (buffer locb-inkas-pay-wth:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "sale-doc" then do:
      create locb-sale-doc.
run nws-impl in p-imp-handle
  ( input "sale-doc":U
   ,input (buffer locb-sale-doc:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-sale-doc" then do:
      create locb-c-sale-doc.
run nws-impl in p-imp-handle
  ( input "c-sale-doc":U
   ,input (buffer locb-c-sale-doc:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "chk-doc" then do:
      create locb-chk-doc.
run nws-impl in p-imp-handle
  ( input "chk-doc":U
   ,input (buffer locb-chk-doc:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "chk-gds" then do:
      create locb-chk-gds.
run nws-impl in p-imp-handle
  ( input "chk-gds":U
   ,input (buffer locb-chk-gds:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "chk-gds-attr" then do:
      create locb-chk-gds-attr.
run nws-impl in p-imp-handle
  ( input "chk-gds-attr":U
   ,input (buffer locb-chk-gds-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "chk-pay" then do:
      create locb-chk-pay.
run nws-impl in p-imp-handle
  ( input "chk-pay":U
   ,input (buffer locb-chk-pay:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "chk-pay-attr" then do:
      create locb-chk-pay-attr.
run nws-impl in p-imp-handle
  ( input "chk-pay-attr":U
   ,input (buffer locb-chk-pay-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "chk-discnt" then do:
      create locb-chk-discnt.
run nws-impl in p-imp-handle
  ( input "chk-discnt":U
   ,input (buffer locb-chk-discnt:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
     when "chk-discnt-attr" then do:
      create locb-chk-discnt-attr.
run nws-impl in p-imp-handle
  ( input "chk-discnt-attr":U
   ,input (buffer locb-chk-discnt-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "chk-doc-attr" then do:
      create locb-chk-doc-attr.
run nws-impl in p-imp-handle
  ( input "chk-doc-attr":U
   ,input (buffer locb-chk-doc-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "chk-gds-pay" then do:
      create locb-chk-gds-pay.
run nws-impl in p-imp-handle
  ( input "chk-gds-pay":U
   ,input (buffer locb-chk-gds-pay:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-chk-doc" then do:
      create locb-c-chk-doc.
run nws-impl in p-imp-handle
  ( input "c-chk-doc":U
   ,input (buffer locb-c-chk-doc:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-chk-gds" then do:
      create locb-c-chk-gds.
run nws-impl in p-imp-handle
  ( input "c-chk-gds":U
   ,input (buffer locb-c-chk-gds:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-chk-pay" then do:
      create locb-c-chk-pay.
run nws-impl in p-imp-handle
  ( input "c-chk-pay":U
   ,input (buffer locb-c-chk-pay:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-chk-discnt" then do:
      create locb-c-chk-discnt.
run nws-impl in p-imp-handle
  ( input "c-chk-discnt":U
   ,input (buffer locb-c-chk-discnt:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-chk-doc-attr" then do:
      create locb-c-chk-doc-attr.
run nws-impl in p-imp-handle
  ( input "c-chk-doc-attr":U
   ,input (buffer locb-c-chk-doc-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-inkas" then do:
      create locb-c-inkas.
run nws-impl in p-imp-handle
  ( input "c-inkas":U
   ,input (buffer locb-c-inkas:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-inkas-pay" then do:
      create locb-c-inkas-pay.
run nws-impl in p-imp-handle
  ( input "c-inkas-pay":U
   ,input (buffer locb-c-inkas-pay:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-inkas-pay-desk" then do:
      create locb-c-inkas-pay-desk.
run nws-impl in p-imp-handle
  ( input "c-inkas-pay-desk":U
   ,input (buffer locb-c-inkas-pay-desk:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-inkas-pay-wth" then do:
      create locb-c-inkas-pay-wth.
run nws-impl in p-imp-handle
  ( input "c-inkas-pay-wth":U
   ,input (buffer locb-c-inkas-pay-wth:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "nws/inc/imp/inkas.i: Не предусмотрен прием таблицы " rec-name skip
              "в составе накладной"
              view-as alert-box error.
      return error "nws/inc/imp/inkas.i: Не предусмотрен прием таблицы " + rec-name + chr(10) + "в составе накладной".
    end.
  END CASE.
end.
if not available tb-inkas then do:
  create tb-inkas.
end.
define variable v-old-inkas-status as character no-undo .
define variable v-new-inkas-status as character no-undo .
assign
  v-old-inkas-status = tb-inkas.status_
  v-new-inkas-status = wt-inkas.status_
.
run trg/nwsdochs.p
  (input g#db-num
  ,input 'update':U
  ,input wt-inkas.inkas-code
  ,input wt-inkas.obj-type
  ,input wt-inkas.obj-code
  ,input 'inkas':U
  ,input '':u
  ,input wt-inkas.fact-date
  ,input wt-inkas.qnty
  ,input 0
  ,input 0
  ,input 0
  ,input v-old-inkas-status
  ,input v-new-inkas-status
  ,input g#news-source-db
  ,input p-pck-num
  ,input wt-inkas.user-db-num
  ,input wt-inkas.user-name
  ,input wt-inkas.sys-date
  ,input wt-inkas.sys-time
  ,input wt-inkas.sys-time-int
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.
buffer-copy wt-inkas to tb-inkas.
for each buf_inkas-pay where buf_inkas-pay.inkas-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_inkas-pay.
end.
for each locb-inkas-pay where locb-inkas-pay.inkas-code = wt-inkas.inkas-code
                        no-lock
on error  undo, return error
:
  create buf_inkas-pay.
  buffer-copy locb-inkas-pay to buf_inkas-pay.
end.
for each buf_inkas-pay-desk where buf_inkas-pay-desk.inkas-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_inkas-pay-desk.
end.
for each locb-inkas-pay-desk where locb-inkas-pay-desk.inkas-code = wt-inkas.inkas-code
                        no-lock
on error  undo, return error
:
  create buf_inkas-pay-desk.
  buffer-copy locb-inkas-pay-desk to buf_inkas-pay-desk.
end.
for each buf_inkas-pay-wth where buf_inkas-pay-wth.inkas-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_inkas-pay-wth.
end.
for each locb-inkas-pay-wth where locb-inkas-pay-wth.inkas-code = wt-inkas.inkas-code
                        no-lock
on error  undo, return error
:
  create buf_inkas-pay-wth.
  buffer-copy locb-inkas-pay-wth to buf_inkas-pay-wth.
end.
for each buf_c-inkas-pay where buf_c-inkas-pay.inkas-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_c-inkas-pay.
end.
for each locb-c-inkas-pay where locb-c-inkas-pay.inkas-code = wt-inkas.inkas-code
                        no-lock
on error  undo, return error
:
  create buf_c-inkas-pay.
  buffer-copy locb-c-inkas-pay to buf_c-inkas-pay.
end.
for each buf_c-inkas-pay-desk where buf_c-inkas-pay-desk.inkas-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_c-inkas-pay-desk.
end.
for each locb-c-inkas-pay-desk where locb-c-inkas-pay-desk.inkas-code = wt-inkas.inkas-code
                        no-lock
on error  undo, return error
:
  create buf_c-inkas-pay-desk.
  buffer-copy locb-c-inkas-pay-desk to buf_c-inkas-pay-desk.
end.
for each buf_c-inkas-pay-wth where buf_c-inkas-pay-wth.inkas-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_c-inkas-pay-wth.
end.
for each locb-c-inkas-pay-wth where locb-c-inkas-pay-wth.inkas-code = wt-inkas.inkas-code
                        no-lock
on error  undo, return error
:
  create buf_c-inkas-pay-wth.
  buffer-copy locb-c-inkas-pay-wth to buf_c-inkas-pay-wth.
end.
for each buf_sale-doc where buf_sale-doc.inkas-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_sale-doc.
end.
for each locb-sale-doc where locb-sale-doc.inkas-code = wt-inkas.inkas-code
                        no-lock
on error  undo, return error
:
  create buf_sale-doc.
  buffer-copy locb-sale-doc to buf_sale-doc.
end.
for each buf_c-sale-doc where buf_c-sale-doc.inkas-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_c-sale-doc.
end.
for each locb-c-sale-doc where locb-c-sale-doc.inkas-code = wt-inkas.inkas-code
                        no-lock
on error  undo, return error
:
  create buf_c-sale-doc.
  buffer-copy locb-c-sale-doc to buf_c-sale-doc.
end.
for each buf_chk-gds-pay where buf_chk-gds-pay.out-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_chk-gds-pay.
end.
for each locb-chk-gds-pay where locb-chk-gds-pay.out-code = wt-inkas.inkas-code
                      no-lock
on error  undo, return error
:
  create buf_chk-gds-pay.
  buffer-copy locb-chk-gds-pay to buf_chk-gds-pay.
end.
for each buf_chk-doc where buf_chk-doc.out-code = wt-inkas.inkas-code
on error  undo, return error
:
  for each buf_chk-doc-attr where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
  on error  undo, return error
  :
    delete buf_chk-doc-attr.
  end.
  delete buf_chk-doc.
end.
v-need-saledc = no.
for each locb-chk-doc where locb-chk-doc.out-code = wt-inkas.inkas-code
                      no-lock
on error  undo, return error
:
  create buf_chk-doc.
  buffer-copy locb-chk-doc to buf_chk-doc.
  for each locb-chk-doc-attr where locb-chk-doc-attr.doc-code = buf_chk-doc.doc-code
                      no-lock
  on error  undo, return error
  :
     create buf_chk-doc-attr.
     buffer-copy locb-chk-doc-attr to buf_chk-doc-attr.
  end.
  if buf_chk-doc.d-card <> ""
  and not v-need-saledc
  then do:
    v-need-saledc = yes.
  end.
end.
for each buf_chk-gds where buf_chk-gds.out-code = wt-inkas.inkas-code
on error  undo, return error
:
  for each buf_chk-gds-attr where buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
      and buf_chk-gds-attr.line-num = buf_chk-gds.line-num
  on error  undo, return error
  :
    delete buf_chk-gds-attr.
  end.
  delete buf_chk-gds.
end.
for each locb-chk-gds where locb-chk-gds.out-code = wt-inkas.inkas-code
                      no-lock
on error  undo, return error
:
  create buf_chk-gds.
  buffer-copy locb-chk-gds to buf_chk-gds.
  for each locb-chk-gds-attr where locb-chk-gds-attr.doc-code = locb-chk-gds.doc-code
      and locb-chk-gds-attr.line-num = locb-chk-gds.line-num
                        no-lock
  on error  undo, return error
  :
    create buf_chk-gds-attr.
    buffer-copy locb-chk-gds-attr to buf_chk-gds-attr.
  end.
end.
for each buf_chk-pay where buf_chk-pay.out-code = wt-inkas.inkas-code
on error  undo, return error
:
  for each buf_chk-pay-attr where buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code
      and buf_chk-pay-attr.line-num = buf_chk-pay.line-num
  on error  undo, return error
  :
    delete buf_chk-pay-attr.
  end.
  delete buf_chk-pay.
end.
for each locb-chk-pay where locb-chk-pay.out-code = wt-inkas.inkas-code
                      no-lock
on error  undo, return error
:
  create buf_chk-pay.
  buffer-copy locb-chk-pay to buf_chk-pay.
  for each locb-chk-pay-attr where locb-chk-pay-attr.doc-code = locb-chk-pay.doc-code
      and locb-chk-pay-attr.line-num = locb-chk-pay.line-num
                        no-lock
  on error  undo, return error
  :
    create buf_chk-pay-attr.
    buffer-copy locb-chk-pay-attr to buf_chk-pay-attr.
  end.
end.
for each buf_chk-discnt where buf_chk-discnt.out-code = wt-inkas.inkas-code
on error  undo, return error
:
  for each buf_chk-discnt-attr where buf_chk-discnt-attr.doc-code = buf_chk-discnt.doc-code and
    buf_chk-discnt-attr.line-num = buf_chk-discnt.line-num:
    delete buf_chk-discnt-attr.
  end.
  delete buf_chk-discnt.
end.
for each locb-chk-discnt where locb-chk-discnt.out-code = wt-inkas.inkas-code
                      no-lock
on error  undo, return error
:
  create buf_chk-discnt.
  buffer-copy locb-chk-discnt to buf_chk-discnt.
   for each locb-chk-discnt-attr where locb-chk-discnt-attr.doc-code = locb-chk-discnt.doc-code and
    locb-chk-discnt-attr.line-num = locb-chk-discnt.line-num:
    create buf_chk-discnt-attr.
    buffer-copy locb-chk-discnt-attr to buf_chk-discnt-attr.
  end.
end.
for each buf_c-chk-doc-attr where buf_c-chk-doc-attr.out-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_c-chk-doc-attr.
end.
for each locb-c-chk-doc-attr where locb-c-chk-doc-attr.out-code = wt-inkas.inkas-code
                      no-lock
on error  undo, return error
:
  create buf_c-chk-doc-attr.
  buffer-copy locb-c-chk-doc-attr to buf_c-chk-doc-attr.
end.
for each locb-c-chk-doc where locb-c-chk-doc.out-code = wt-inkas.inkas-code
                      no-lock:
   find  first buf_c-chk-doc where buf_c-chk-doc.doc-code = locb-c-chk-doc.doc-code
                 and buf_c-chk-doc.out-code = ? no-error.
   if available buf_c-chk-doc then do:
   for each buf_c-chk-gds where buf_c-chk-gds.doc-code = locb-c-chk-doc.doc-code:
     delete buf_c-chk-gds.
   end.
   for each buf_c-chk-pay where buf_c-chk-pay.doc-code = locb-c-chk-doc.doc-code:
     delete buf_c-chk-pay.
   end.
   for each buf_c-chk-discnt where buf_c-chk-discnt.doc-code = locb-c-chk-doc.doc-code:
     delete buf_c-chk-discnt.
   end.
   for each buf_c-chk-doc-attr where buf_c-chk-doc-attr.doc-code = locb-c-chk-doc.doc-code:
     delete buf_c-chk-doc-attr.
   end.
   delete buf_c-chk-doc.
end.
end.
for each buf_c-chk-doc where buf_c-chk-doc.out-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_c-chk-doc.
end.
for each locb-c-chk-doc where locb-c-chk-doc.out-code = wt-inkas.inkas-code
                      no-lock
on error  undo, return error
:
  create buf_c-chk-doc.
  buffer-copy locb-c-chk-doc to buf_c-chk-doc.
end.
for each buf_c-chk-gds where buf_c-chk-gds.out-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_c-chk-gds.
end.
for each locb-c-chk-gds where locb-c-chk-gds.out-code = wt-inkas.inkas-code
                      no-lock
on error  undo, return error
:
  create buf_c-chk-gds.
  buffer-copy locb-c-chk-gds to buf_c-chk-gds.
end.
for each buf_c-chk-pay where buf_c-chk-pay.out-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_c-chk-pay.
end.
for each locb-c-chk-pay where locb-c-chk-pay.out-code = wt-inkas.inkas-code
                      no-lock
on error  undo, return error
:
  create buf_c-chk-pay.
  buffer-copy locb-c-chk-pay to buf_c-chk-pay.
end.
for each buf_c-chk-discnt where buf_c-chk-discnt.out-code = wt-inkas.inkas-code
on error  undo, return error
:
  delete buf_c-chk-discnt.
end.
for each locb-c-chk-discnt where locb-c-chk-discnt.out-code = wt-inkas.inkas-code
                      no-lock
on error  undo, return error
:
  create buf_c-chk-discnt.
  buffer-copy locb-c-chk-discnt to buf_c-chk-discnt.
end.
if g#db-num = 0
and wt-inkas.status_ = 'факт':U
and v-need-saledc
then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input wt-inkas.inkas-code ,
                       input 'need-saledc':U ,
                       input string(1) )  .
end.
for each locb-inkas-pay
on error  undo, return error
:
  delete locb-inkas-pay.
end.
for each locb-c-inkas-pay
on error  undo, return error
:
  delete locb-c-inkas-pay.
end.
for each locb-inkas-pay-desk
on error  undo, return error
:
  delete locb-inkas-pay-desk.
end.
for each locb-c-inkas-pay-desk
on error  undo, return error
:
  delete locb-c-inkas-pay-desk.
end.
for each locb-inkas-pay-wth
on error  undo, return error
:
  delete locb-inkas-pay-wth.
end.
for each locb-c-inkas-pay-wth
on error  undo, return error
:
  delete locb-c-inkas-pay-wth.
end.
for each locb-sale-doc
on error  undo, return error
:
  delete locb-sale-doc.
end.
for each locb-c-sale-doc
on error  undo, return error
:
  delete locb-c-sale-doc.
end.
for each locb-chk-doc
on error  undo, return error
:
  delete locb-chk-doc.
end.
for each locb-chk-gds
on error  undo, return error
:
  delete locb-chk-gds.
end.
for each locb-chk-gds-attr
on error  undo, return error
:
  delete locb-chk-gds-attr.
end.
for each locb-chk-pay
on error  undo, return error
:
  delete locb-chk-pay.
end.
for each locb-chk-pay-attr
on error  undo, return error
:
  delete locb-chk-pay-attr.
end.
for each locb-chk-discnt
on error  undo, return error
:
  delete locb-chk-discnt.
end.
for each locb-chk-doc-attr
on error  undo, return error
:
  delete locb-chk-doc-attr.
end.
for each locb-chk-gds-pay
on error  undo, return error
:
  delete locb-chk-gds-pay.
end.
for each locb-c-chk-doc
on error  undo, return error
:
  delete locb-c-chk-doc.
end.
for each locb-c-chk-gds
on error  undo, return error
:
  delete locb-c-chk-gds.
end.
for each locb-c-chk-pay
on error  undo, return error
:
  delete locb-c-chk-pay.
end.
for each locb-c-chk-discnt
on error  undo, return error
:
  delete locb-c-chk-discnt.
end.
for each locb-c-chk-doc-attr
on error  undo, return error
:
  delete locb-c-chk-doc-attr.
end.
    delete wt-inkas.
  end.
END PROCEDURE.
define temp-table locb2-c-inkas      no-undo like ub.c-inkas.
define temp-table locb2-c-inkas-pay      no-undo like ub.c-inkas-pay.
define temp-table locb2-c-inkas-pay-desk no-undo like ub.c-inkas-pay-desk.
define temp-table locb2-c-inkas-pay-wth no-undo like ub.c-inkas-pay-wth.
define temp-table locb2-c-sale-doc      no-undo like ub.c-sale-doc.
define temp-table wt-c-inkas no-undo like ub.c-inkas.
PROCEDURE proc-load-c-inkas:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-c-inkas. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-c-inkas. stop" )
  on endkey undo, return error substitute( "$proc-load-c-inkas. endkey" )
  :
    define buffer tb-c-inkas for ub.c-inkas.
    define variable compare-log as logical no-undo.
define variable vss-include-info104 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_c-inkas-pay      for ub.c-inkas-pay.
define buffer buf_c-sale-doc       for ub.c-sale-doc.
define buffer buf_c-inkas-pay-desk for ub.c-inkas-pay-desk.
define buffer buf_c-inkas-pay-wth  for ub.c-inkas-pay-wth.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
for each locb2-c-inkas
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-inkas.
end.
for each locb2-c-inkas-pay
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-inkas-pay.
end.
for each locb2-c-inkas-pay-desk
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-inkas-pay-desk.
end.
for each locb2-c-inkas-pay-wth
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-inkas-pay-wth.
end.
for each locb2-c-sale-doc
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-sale-doc.
end.
    for each wt-c-inkas
    on error undo, return error substitute( "$proc-load-c-inkas(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-c-inkas .
    end.
    create wt-c-inkas.
    run nws-impl in p-imp-handle
      ( input 'c-inkas':U
       ,input (buffer wt-c-inkas:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-c-inkas
      where tb-c-inkas.inkas-code = wt-c-inkas.inkas-code
        and tb-c-inkas.corr-user-db-num = wt-c-inkas.corr-user-db-num
        and tb-c-inkas.chip-num = wt-c-inkas.chip-num
      exclusive-lock no-error.
define variable vss-include-info105 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "c-inkas-pay" then do:
      create locb2-c-inkas-pay.
run nws-impl in p-imp-handle
  ( input "c-inkas-pay":U
   ,input (buffer locb2-c-inkas-pay:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-inkas-pay-desk" then do:
      create locb2-c-inkas-pay-desk.
run nws-impl in p-imp-handle
  ( input "c-inkas-pay-desk":U
   ,input (buffer locb2-c-inkas-pay-desk:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-inkas-pay-wth" then do:
      create locb2-c-inkas-pay-wth.
run nws-impl in p-imp-handle
  ( input "c-inkas-pay-wth":U
   ,input (buffer locb2-c-inkas-pay-wth:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-sale-doc" then do:
      create locb2-c-sale-doc.
run nws-impl in p-imp-handle
  ( input "c-sale-doc":U
   ,input (buffer locb2-c-sale-doc:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message " nws/inc/imp/c-inkas.i: Не предусмотрен прием таблицы " rec-name skip
              "в составе накладной"
              view-as alert-box error.
      return error " nws/inc/imp/c-inkas.i: Не предусмотрен прием таблицы " + rec-name + chr(10) + "в составе накладной".
    end.
  END CASE.
end.
if not available tb-c-inkas then do:
  create tb-c-inkas.
end.
buffer-copy wt-c-inkas to tb-c-inkas.
for each buf_c-inkas-pay where buf_c-inkas-pay.inkas-code = wt-c-inkas.inkas-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-inkas-pay.
end.
for each locb2-c-inkas-pay where locb2-c-inkas-pay.inkas-code = wt-c-inkas.inkas-code
                        no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-inkas-pay.
  buffer-copy locb2-c-inkas-pay to buf_c-inkas-pay.
end.
for each buf_c-inkas-pay-desk where buf_c-inkas-pay-desk.inkas-code = wt-c-inkas.inkas-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-inkas-pay-desk.
end.
for each locb2-c-inkas-pay-desk where locb2-c-inkas-pay-desk.inkas-code = wt-c-inkas.inkas-code
                        no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-inkas-pay-desk.
  buffer-copy locb2-c-inkas-pay-desk to buf_c-inkas-pay-desk.
end.
for each buf_c-inkas-pay-wth where buf_c-inkas-pay-wth.inkas-code = wt-c-inkas.inkas-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-inkas-pay-wth.
end.
for each locb2-c-inkas-pay-wth where locb2-c-inkas-pay-wth.inkas-code = wt-c-inkas.inkas-code
                        no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-inkas-pay-wth.
  buffer-copy locb2-c-inkas-pay-wth to buf_c-inkas-pay-wth.
end.
for each buf_c-sale-doc where buf_c-sale-doc.inkas-code = wt-c-inkas.inkas-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-sale-doc.
end.
for each locb2-c-sale-doc where locb2-c-sale-doc.inkas-code = wt-c-inkas.inkas-code
                        no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-sale-doc.
  buffer-copy locb2-c-sale-doc to buf_c-sale-doc.
end.
for each locb2-c-inkas
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb2-c-inkas.
end.
for each locb2-c-inkas-pay
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb2-c-inkas-pay.
end.
for each locb2-c-inkas-pay-desk
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb2-c-inkas-pay-desk.
end.
for each locb2-c-inkas-pay-wth
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb2-c-inkas-pay-wth.
end.
for each locb2-c-sale-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb2-c-sale-doc.
end.
    delete wt-c-inkas.
  end.
END PROCEDURE.
define variable vss-include-info106 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info107 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure layouth_create-layout_h :
define input parameter p-mode as character no-undo .
define input parameter p-layout-id as character no-undo .
define parameter buffer buf_layout for ub.layout.
define output parameter p-chip-num as integer no-undo .
define variable v-chip-num as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-layout for ub.c-layout.
do
on error undo, return error
:
  run cur-time in this-procedure ( output v-today, output v-time).
  find last buf_c-layout no-lock where
            buf_c-layout.layout-id = p-layout-id
       and  buf_c-layout.corr-user-db-num = g#db-num
       use-index pi no-error.
  assign
  v-chip-num = (if available buf_c-layout
                then buf_c-layout.chip-num + 1
                else 0).
  create buf_c-layout.
  if available buf_layout
  and p-mode <> 'ДОБАВЛЕНИЕ':U
  then do:
    buffer-copy buf_layout
    to buf_c-layout.
  end.
  if not available buf_layout then do:
    assign
    buf_c-layout.layout-id = p-layout-id
    .
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    assign
    buf_c-layout.layout-id = p-layout-id
    .
  end.
  assign
  buf_c-layout.subject = 'layout':U
  buf_c-layout.action = (if p-mode = 'ДОБАВЛЕНИЕ':U
                         then integer('1':U)
                         else (if p-mode = 'ИЗМЕНЕНИЕ':U
                               then integer('2':U)
                               else integer('99':U)
                               )
                        )
  buf_c-layout.chip-num = v-chip-num
  buf_c-layout.corr-user-db-num = g#db-num
  buf_c-layout.corr-user-name = g#userid
  buf_c-layout.corr-date = v-today
  buf_c-layout.corr-time = v-time
  p-chip-num = v-chip-num
  .
end.
end procedure.
procedure layouth_create-layout-elem-rule_h :
define input parameter p-mode as character no-undo .
define input parameter p-layout-id as character no-undo .
define input parameter p-mode-id as character no-undo .
define input parameter p-widget-id as character no-undo .
define parameter buffer buf_layout-elem-rule for ub.layout-elem-rule.
define input parameter p-chip-num as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-layout-elem-rule for ub.c-layout-elem-rule.
do
on error undo, return error
:
  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_c-layout-elem-rule.
  if available buf_layout-elem-rule
  and p-mode <> 'ДОБАВЛЕНИЕ':U
  then do:
    buffer-copy buf_layout-elem-rule
    to buf_c-layout-elem-rule.
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    assign
    buf_c-layout-elem-rule.layout-id = p-layout-id
    buf_c-layout-elem-rule.mode-id = p-mode-id
    buf_c-layout-elem-rule.widget-id = p-widget-id
    .
  end.
  assign
  buf_c-layout-elem-rule.subject = 'layout-elem-rule':U
  buf_c-layout-elem-rule.action = (if p-mode = 'ДОБАВЛЕНИЕ':U
                         then integer('1':U)
                         else (if p-mode = 'ИЗМЕНЕНИЕ':U
                               then integer('2':U)
                               else integer('99':U)
                               )
                        )
  buf_c-layout-elem-rule.chip-num = p-chip-num
  buf_c-layout-elem-rule.corr-user-db-num = g#db-num
  buf_c-layout-elem-rule.corr-user-name = g#userid
  buf_c-layout-elem-rule.corr-date = v-today
  buf_c-layout-elem-rule.corr-time = v-time
  .
end.
end procedure.
procedure layouth_create-rule-call-param_h :
define input parameter p-mode as character no-undo .
define input parameter p-call#-id as integer no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-param-name as character no-undo .
define input parameter p-index as integer no-undo .
define input parameter p-call-id as character no-undo .
define parameter buffer buf_rule-call-param for ub.rule-call-param.
define input parameter p-chip-num as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-rule-call-param for ub.c-rule-call-param.
do
on error undo, return error
:
  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_c-rule-call-param.
  if available buf_rule-call-param
  and p-mode <> 'ДОБАВЛЕНИЕ':U
  then do:
    buffer-copy buf_rule-call-param
    to buf_c-rule-call-param.
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    assign
    buf_c-rule-call-param.call#_id = p-call#-id
    buf_c-rule-call-param.codex_id = p-codex-id
    buf_c-rule-call-param.ruleset_id = p-ruleset-id
    buf_c-rule-call-param.order_id = p-order-id
    buf_c-rule-call-param.param-name = p-param-name
    buf_c-rule-call-param.p-index = p-index
    buf_c-rule-call-param.call_id = p-call-id
    .
  end.
  assign
  buf_c-rule-call-param.action = (if p-mode = 'ДОБАВЛЕНИЕ':U
                                  then integer('1':U)
                                  else (if p-mode = 'удаление':U
                                        then integer('99':U)
                                        else integer('2':U)
                                        )
                                  )
  buf_c-rule-call-param.chip-num = p-chip-num
  buf_c-rule-call-param.corr-user-db-num = g#db-num
  buf_c-rule-call-param.corr-user-name = g#userid
  buf_c-rule-call-param.corr-date = v-today
  buf_c-rule-call-param.corr-time = v-time
  .
end.
end procedure.
define temp-table locb-layout-elem-rule no-undo like ub.layout-elem-rule.
define temp-table locb-rule-call-param no-undo like ub.rule-call-param.
define temp-table locb-rule-by-call no-undo like ub.rule-by-call.
define temp-table wt-layout no-undo like ub.layout.
PROCEDURE proc-load-layout:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-layout. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-layout. stop" )
  on endkey undo, return error substitute( "$proc-load-layout. endkey" )
  :
    define buffer tb-layout for ub.layout.
    define variable compare-log as logical no-undo.
define buffer buf_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_layout-elem for ub.layout-elem.
define buffer buf_wi-mode for ub.wi-mode.
define buffer buf2_layout for ub.layout.
define buffer buf2_layout-elem-rule for ub.layout-elem-rule.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
define variable v-chip-num as integer no-undo .
define variable v-cmp as logical   no-undo .
    for each wt-layout
    on error undo, return error substitute( "$proc-load-layout(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-layout .
    end.
    create wt-layout.
    run nws-impl in p-imp-handle
      ( input 'layout':U
       ,input (buffer wt-layout:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-layout
      where tb-layout.layout-id = wt-layout.layout-id
      exclusive-lock no-error.
define variable vss-include-info108 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when 'layout-elem-rule':U then do:
      create locb-layout-elem-rule.
run nws-impl in p-imp-handle
  ( input "layout-elem-rule":U
   ,input (buffer locb-layout-elem-rule:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when 'rule-by-call':U then do:
      create locb-rule-by-call.
run nws-impl in p-imp-handle
  ( input "rule-by-call":U
   ,input (buffer locb-rule-by-call:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when 'rule-call-param':U then do:
      create locb-rule-call-param.
run nws-impl in p-imp-handle
  ( input "rule-call-param":U
   ,input (buffer locb-rule-call-param:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе раскалдки."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
run  layouth_create-layout_h  in this-procedure (
                                                input 'ИЗМЕНЕНИЕ':U
                                              ,input wt-layout.layout-id
                                              ,buffer tb-layout
                                              ,output v-chip-num).
if wt-layout.is-default = integer('0':U)
or wt-layout.is-default = integer('1':U)
then do:
  find first buf2_layout share-lock where
            buf2_layout.layout-type = wt-layout.layout-type
        and buf2_layout.device-type = wt-layout.device-type
        and buf2_layout.is-default = integer('-1':U) no-error.
  if available buf2_layout then do:
    for each buf2_layout-elem-rule no-lock where
            buf2_layout-elem-rule.layout-id = buf2_layout.layout-id
    on error  undo, return error:
      find first locb-layout-elem-rule where
               locb-layout-elem-rule.layout-id = wt-layout.layout-id
          and locb-layout-elem-rule.mode-id = buf2_layout-elem-rule.mode-id
          and locb-layout-elem-rule.widget-id = buf2_layout-elem-rule.widget-id no-error.
      if not available locb-layout-elem-rule
      or locb-layout-elem-rule.rule_id <> buf2_layout-elem-rule.rule_id then do:
        if available locb-layout-elem-rule then do:
          assign
          locb-layout-elem-rule.sts = integer('1':U)
          .
        end.
        wt-layout.sts = (if wt-layout.sts <> integer('99':U)
                        then integer('50':U)
                        else wt-layout.sts).
      end.
    end.
  end.
end.
for each locb-layout-elem-rule where locb-layout-elem-rule.layout-id = wt-layout.layout-id
on error  undo, return error:
  find first buf_wi-mode no-lock where
          buf_wi-mode.mode-type = 'cd-IBS-TH':U
      and buf_wi-mode.mode-id = locb-layout-elem-rule.mode-id no-error.
  if not available buf_wi-mode then do:
    assign
    locb-layout-elem-rule.sts = integer('1':U)
    wt-layout.sts = (if wt-layout.sts <> integer('99':U)
                     then integer('50':U)
                     else wt-layout.sts)
    .
  end.
  find first buf_layout-elem no-lock where
          buf_layout-elem.layout-type = wt-layout.layout-type
      and buf_layout-elem.device-type = wt-layout.device-type
      and buf_layout-elem.mode-id = locb-layout-elem-rule.mode-id
      and buf_layout-elem.widget-id = locb-layout-elem-rule.widget-id
      no-error.
  if not available buf_layout-elem
  or (wt-layout.is-default = integer('0':U)
      and
      buf_layout-elem.elem-type = integer('0':U)
      )
  then do:
    assign
    locb-layout-elem-rule.sts = integer('1':U)
    wt-layout.sts = (if wt-layout.sts <> integer('99':U)
                     then integer('50':U)
                     else wt-layout.sts)
    .
  end.
  v-cmp = yes.
  find first buf_layout-elem-rule where
            buf_layout-elem-rule.layout-id = locb-layout-elem-rule.layout-id
        and buf_layout-elem-rule.mode-id = locb-layout-elem-rule.mode-id
        and buf_layout-elem-rule.widget-id = locb-layout-elem-rule.widget-id no-error.
  if not available buf_layout-elem-rule then do:
    v-cmp = no.
    create buf_layout-elem-rule.
  end.
  else do:
    buffer-compare buf_layout-elem-rule to locb-layout-elem-rule case-sensitive  save result in v-cmp.
  end.
  if not v-cmp then do:
    run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                    input (if new (buf_layout-elem-rule) then 'ДОБАВЛЕНИЕ':U else 'ИЗМЕНЕНИЕ':U)
                                                  ,input locb-layout-elem-rule.layout-id
                                                  ,input locb-layout-elem-rule.mode-id
                                                  ,input locb-layout-elem-rule.widget-id
                                                  ,buffer buf_layout-elem-rule
                                                  ,input v-chip-num).
    buffer-copy locb-layout-elem-rule to buf_layout-elem-rule.
  end.
    for each locb-rule-by-call where
         locb-rule-by-call.call_id = locb-layout-elem-rule.uniq-key-rec
  on error  undo, return error:
     v-cmp = yes.
     find first buf_rule-by-call where
              buf_rule-by-call.call_id = locb-rule-by-call.call_id
          and buf_rule-by-call.codex_id = locb-rule-by-call.codex_id
          and buf_rule-by-call.ruleset_id = locb-rule-by-call.ruleset_id
          and buf_rule-by-call.order_id = locb-rule-by-call.order_id no-error.
     if not available buf_rule-by-call then do:
       v-cmp = no.
       create buf_rule-by-call.
       buffer-copy locb-rule-by-call to buf_rule-by-call.
     end.
     else do:
       buffer-compare locb-rule-by-call to buf_rule-by-call case-sensitive  save result in v-cmp.
     end.
     if v-cmp = no then do:
        buffer-copy locb-rule-by-call to buf_rule-by-call.
     end.
  end.
  for each locb-rule-call-param where
         locb-rule-call-param.call_id = locb-layout-elem-rule.uniq-key-rec
  on error  undo, return error:
     v-cmp = yes.
     find first buf_rule-call-param where
              buf_rule-call-param.call_id = locb-rule-call-param.call_id
          and buf_rule-call-param.codex_id = locb-rule-call-param.codex_id
          and buf_rule-call-param.ruleset_id = locb-rule-call-param.ruleset_id
          and buf_rule-call-param.order_id = locb-rule-call-param.order_id
          and buf_rule-call-param.param-name = locb-rule-call-param.param-name
          and buf_rule-call-param.p-index = locb-rule-call-param.p-index
          no-error.
     if not available buf_rule-call-param then do:
       v-cmp = no.
       create buf_rule-call-param.
       buffer-copy locb-rule-call-param to buf_rule-call-param.
     end.
     else do:
       buffer-compare locb-rule-call-param to buf_rule-call-param case-sensitive  save result in v-cmp.
     end.
     if v-cmp = no then do:
        run  layouth_create-rule-call-param_h  in this-procedure (
                                                        input (if new(buf_rule-call-param)
                                                               then 'ДОБАВЛЕНИЕ':U
                                                               else 'ИЗМЕНЕНИЕ':U)
                                                      ,input locb-rule-call-param.call#_id
                                                      ,input locb-rule-call-param.codex_id
                                                      ,input locb-rule-call-param.ruleset_id
                                                      ,input locb-rule-call-param.order_id
                                                      ,input locb-rule-call-param.param-name
                                                      ,input locb-rule-call-param.p-index
                                                      ,input locb-rule-call-param.call_id
                                                      ,buffer buf_rule-call-param
                                                      ,input v-chip-num).
        buffer-copy locb-rule-call-param to buf_rule-call-param.
     end.
  end.
  for each buf_rule-call-param where
         buf_rule-call-param.call_id = locb-layout-elem-rule.uniq-key-rec
  on error  undo, return error:
     v-cmp = yes.
     find first locb-rule-call-param where
              locb-rule-call-param.call_id = buf_rule-call-param.call_id
          and locb-rule-call-param.codex_id = buf_rule-call-param.codex_id
          and locb-rule-call-param.ruleset_id = buf_rule-call-param.ruleset_id
          and locb-rule-call-param.order_id = buf_rule-call-param.order_id
          and locb-rule-call-param.param-name = buf_rule-call-param.param-name
          and locb-rule-call-param.p-index = buf_rule-call-param.p-index
          no-error.
     if not available locb-rule-call-param then do:
        run  layouth_create-rule-call-param_h  in this-procedure (
                                                        input 'удаление':U
                                                      ,input buf_rule-call-param.call#_id
                                                      ,input buf_rule-call-param.codex_id
                                                      ,input buf_rule-call-param.ruleset_id
                                                      ,input buf_rule-call-param.order_id
                                                      ,input buf_rule-call-param.param-name
                                                      ,input buf_rule-call-param.p-index
                                                      ,input buf_rule-call-param.call_id
                                                      ,buffer buf_rule-call-param
                                                      ,input v-chip-num).
     end.
  end.
end.
for each buf_layout-elem-rule where buf_layout-elem-rule.layout-id = wt-layout.layout-id
on error  undo, return error
:
  v-cmp = yes.
  find first locb-layout-elem-rule where
            locb-layout-elem-rule.layout-id = buf_layout-elem-rule.layout-id
        and locb-layout-elem-rule.mode-id = buf_layout-elem-rule.mode-id
        and locb-layout-elem-rule.widget-id = buf_layout-elem-rule.widget-id no-error.
  if not available buf_layout-elem-rule then do:
    run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                    input 'удаление':U
                                                  ,input buf_layout-elem-rule.layout-id
                                                  ,input buf_layout-elem-rule.mode-id
                                                  ,input buf_layout-elem-rule.widget-id
                                                  ,buffer buf_layout-elem-rule
                                                  ,input v-chip-num).
    for each buf_rule-by-call where
            buf_rule-by-call.call_id = buf_layout-elem-rule.uniq-key-rec
    on error  undo, return error:
      delete buf_rule-by-call.
    end.
    for each buf_rule-call-param where
            buf_rule-call-param.call_id = buf_layout-elem-rule.uniq-key-rec
    on error  undo, return error:
        run  layouth_create-rule-call-param_h  in this-procedure (
                                                        input 'удаление':U
                                                      ,input buf_rule-call-param.call#_id
                                                      ,input buf_rule-call-param.codex_id
                                                      ,input buf_rule-call-param.ruleset_id
                                                      ,input buf_rule-call-param.order_id
                                                      ,input buf_rule-call-param.param-name
                                                      ,input buf_rule-call-param.p-index
                                                      ,input buf_rule-call-param.call_id
                                                      ,buffer buf_rule-call-param
                                                      ,input v-chip-num).
      delete buf_rule-by-call.
    end.
    delete buf_layout-elem-rule.
  end.
end.
if not available tb-layout then do:
  create tb-layout.
end.
buffer-copy wt-layout to tb-layout.
for each locb-layout-elem-rule
on error  undo, return error
:
  delete locb-layout-elem-rule.
end.
for each locb-rule-call-param
on error  undo, return error
:
  delete locb-rule-call-param.
end.
for each locb-rule-by-call
on error  undo, return error
:
  delete locb-rule-by-call.
end.
    delete wt-layout.
  end.
END PROCEDURE.
def var vss-include-info109 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info110 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable mMRCCode  as logical    no-undo.
define variable mTypeMark as character  no-undo.
function IS-NeedMark returns logical
( input ib-code as integer  ,
  input ib-str as character ):
   define buffer buf_prod-bc-attr for ub.prod-bc-attr.
   find first buf_prod-bc-attr where buf_prod-bc-attr.b-code eq ib-code
                                 and buf_prod-bc-attr.b-str  eq ib-str
                                 and buf_prod-bc-attr.attr-code eq 'mark':U
     no-lock no-error.
   return if available buf_prod-bc-attr then logical(buf_prod-bc-attr.attr-value) else no .
end.
function repTegforDm return char
(iDM as char ):
    define variable vTeglist as character no-undo init "01,02,11,13,17,21,8005,37".
    define variable vteg as character no-undo.
    define variable oDM as character no-undo.
    define variable vi as integer no-undo.
    oDM = iDm.
    do vi = 1 to num-entries(vTeglist):
       vTeg = entry(vi,vTeglist).
       oDM = replace(oDM,"(" + vTeg + ")",vTeg).
    end.
    return oDM.
end.
function repSpecSimbforDm return char
(iDM as char ):
    define variable oDM as character no-undo.
  run
    xmlchar-decode(iDM, output oDM).
  return repTegforDm (oDM).
end.
function CheckGtin return logical
(iGtin as char):
   define variable bar_code as character no-undo.
   define variable vGtin as logical no-undo init "yes".
   if length(iGtin) eq 14
   then do:
      bar_code = substr (iGtin, 1, length (iGtin) - 1).
      run str/chk-sum.p
       (input-output bar_code ) no-error .
      if iGtin ne  bar_code
      then
         vGtin = no.
   end.
   else
      vGtin = no.
   return vgtin.
end.
function repSpecSimbforXlm return char
(iDM as char ):
    iDM = replace(iDM,chr(29),"").
    return iDM.
end.
function getGtinByDM return char
(IDM as char):
   define variable VTXT as char no-undo.
   define variable vGtin as char no-undo.
   vTXt = IdM.
   vGtin = IDM.
   if    length(vtxt) > 14
   then do:
      if   vtxt begins "(01)"
             or vtxt begins "(02)"
      then
         vGtin = substring(vtxt,5,14).
      else if   (vtxt begins "01"
             or vtxt begins "02" )
             and (   (    substring(iDm,17,2) eq "21"
                      and length(vtxt) >= 21)
                  or substring(iDm,17,2) eq "37"
                  or substring(iDm,17,4) eq "(37)" )
      then do:
         vGtin = substring(vtxt,3,14).
         if not checkGtin(vGtin)
         then
            vGtin = substring(vtxt,1,14).
      end.
      else if     length(vtxt) eq 14 + 7 + 4 + 4
          or length(vtxt) eq 14 + 7 + 4
          or length(vtxt) eq 14 + 7
      then
         vGtin = substring(vtxt,1,14).
   end.
   if not checkGtin(vGtin)
   then
      vGtin = "".
   return vgtin.
end.
function getGdsCodeByGtin return int
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin  and prod-bc.bc-on no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.gds-code else ?.
end.
function getQntyCodeByGtin return decimal
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.cli-base-rate else ?.
end.
function getGdsCodeByDM return int
(iDm as char):
   define variable vGtin as char no-undo.
   define buffer prod-bc for ub.prod-bc.
   vGtin  = getGtinByDM (IDM ).
   return getGdsCodeByGtin (vGtin).
end.
function ChekTypeMarkByGds return logical
(iGds-code as integer ):
   define buffer goods-attr for ub.goods-attr.
   find first goods-attr where goods-attr.gds-code   = iGds-code
                           and goods-attr.attr-code  = 'mark-type':U
   no-lock no-error.
   if available goods-attr
   then do:
      mTypeMark = goods-attr.attr-value.
      return goods-attr.attr-value = objsrv:Env:Marking:Types:tabak:NameProp
        .
   end.
   else
      return no.
end.
function ChekTypeMarkByDm return logical
(iDM as char ):
   return ChekTypeMarkByGds(getGdsCodeByDM(idm)).
end.
function ChekTypeMarkByGtin return logical
(iGtin as char ):
   return ChekTypeMarkByGds(getGdsCodeByGtin(iGtin)).
end.
function GetNextElement return character
  (input iAllTeg        as logical
  ,output oteg          as character
  ,output otegval       as character
  ,input-output pstr    as character
   ):
     define variable vlistElem   as character no-undo init "00,01,02,21,17,11,13,(01),(02),(21),(17),(11),(13)".
     define variable vlistleng   as character no-undo init "27,14,14,13,06,06,06,0014,0014,0013,0006,0006,0006".
     define variable vlistElemDop   as character no-undo init ",37,(37),(8005),8005,93,(93)".
     define variable vlistlengDop   as character no-undo init ",08,0008,000006,0006,04,0004".
     define variable vTeg as character no-undo.
     define variable vLength as integer no-undo.
     define variable vi as integer no-undo.
     define variable vj as integer no-undo.
     define buffer code for ub.code.
     find first code where Code.parent eq "MarkType"
                       and Code.CodeValue   eq mTypeMark
                       no-lock no-error.
     if     available code
        and Code.misc1 ne ""
        and Code.misc1 ne ?
     then do:
        integer (Code.misc1) no-error.
        if not error-status:error
        then
          entry (4,vlistleng) = Code.misc1.
     end.
     if iAllTeg
     then
        assign
           vlistElem     = vlistElem    + vlistElemDop
           vlistleng     = vlistleng    + vlistlengDop
        .
     else if mMRCCode
     then
        assign
           vlistElem     = vlistElem    + ",(8005),8005"
           vlistleng     = vlistleng    + ",000006,0006"
        .
    block-elem:
    do vi = 1 to num-entries(vlistElem):
       vTeg = entry(vi,vlistElem).
       if pstr begins vTeg
       then do:
          if    vTeg eq "21"
          then
             vLength = index(pstr,chr(29)) - 2 no-error.
          if vLength  <= 0
          then
             vLength = int(entry(vi,vlistleng)).
          otegval = substring (pstr,length(vteg) + 1, vLength).
          oteg = replace(replace(vteg,")",""),"(","").
          vTeg = vteg + otegval.
          otegval = replace(otegval,chr(29),"").
          oteg = replace(replace(oteg,")",""),"(","").
          pstr = substring (pstr,length(vTeg)+ 1).
          vTeg = replace(vTeg,chr(29),"").
          leave block-elem.
       end.
       else
          vTeg = "".
    end.
    return vteg.
end.
function GetCodeIdent return character
(iDm as char):
   define variable Velement   as character no-undo init "first".
   define variable oCodeIdent as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define variable vGtin as character no-undo.
   define buffer marking for ub.marking.
   for first marking no-lock where
             marking.mark eq iDm
         and marking.unit-ext = "LEVEL2"
   :
     return iDm.
   end.
   vGtin  = getGtinByDM (iDm ).
   ChekTypeMarkByDm(idm).
   if iDm begins 'tech_':U
   then
      oCodeIdent = iDm.
   else if length(iDm) < 21
   then do:
      find first marking where marking.mark eq idm
      no-lock no-error.
      oCodeIdent = if available marking then marking.mark else  ?.
   end.
   else if     length(iDm) eq 29
      and not iDm begins "01"
      and not iDm begins "02"
   then
      oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21 ).
   else  if     length(iDm) >= 24
            and (  iDm begins "01"
                or iDm begins "02")
            and  substring(iDm,17,2) ne "21"
   then do:
      if checkGtin(substring(iDm,1,14)) and ( (length(idm) eq 25 and substring(iDm,22,1) eq "A")
                                                or (length(idm) eq 29 and substring(iDm,22,1) eq "A"))
      then
         oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21).
      else
         oCodeIdent = iDM.
   end.
   else  if     (   length(iDm) eq 25
                 or length(iDm) eq 21)
            and (not iDm begins "01"
            and  not iDm begins "02")
   then
      oCodeIdent = substring(iDm,1,21).
   else if vGtin = substring(iDm,1,14) and checkGtin(substring(iDm,1,14)) and ( length(idm) eq 21 or (length(idm) eq 25 and substring(iDm,22,1) eq "A"))
   then
      oCodeIdent = substring(iDm,1,21).
   else do while Velement ne "" and idm ne "":
      Velement = GetNextElement(no,output vteg, output vtegval, input-output idm).
      oCodeIdent = oCodeIdent + Velement.
   end.
   return oCodeIdent.
end.
function GetTegCod return character
(icodeIdent as char, iTeg as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo init ?.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if     ((length(icodeIdent) eq 21
      and not icodeIdent begins "01"
      and not icodeIdent begins "02")
      or
          ( length(icodeIdent) eq 25
            and not icodeIdent begins "01"
            and not icodeIdent begins "02"))
   then do:
      if iTeg eq "01" or iTeg eq "02"
      then
         oTeg = substring(icodeIdent,1,21).
      else  if  iTeg eq "21"
      then
         oTeg = substring(icodeIdent,15,7).
   end.
   else do:
      ChekTypeMarkByDm(icodeIdent).
      block-teg:
         do while Velement ne "" and icodeIdent ne "":
         Velement = GetNextElement(yes,output vteg, output vtegval, input-output icodeIdent).
         if    Velement begins iTeg
            or Velement begins "(" + iTeg + ")"
         then do:
            oTeg = vtegval.
            leave block-teg.
         end.
      end.
   end.
   return oTeg.
end.
function isOAD return logical
(icodeIdent as character):
   return length(icodeIdent) > 18 and GetTegCod(icodeIdent,"37") ne ? and GetTegCod(icodeIdent,"02") ne ?.
end.
function isMark return logical
(icodeIdent as character):
   define buffer buf_marking for ub.marking.
   return can-find(first buf_marking where buf_marking.mark begins icodeIdent) or
          (length(icodeIdent) > 20 and not isOAD(icodeIdent)).
end.
function addBracketForCode return character
(icodeIdent as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define buffer marking for ub.marking.
   find first marking no-lock where
              marking.mark begins icodeIdent no-error.
   if    not ChekTypeMarkByDm(icodeIdent)
      or length(icodeIdent) le 24
      or (avail marking and marking.unit-ext = "LEVEL2")
   then
      oTeg = icodeIdent.
   else do:
      if (  icodeIdent begins "01"
         or icodeIdent begins "02"
         ) and CheckGtin(substring (icodeIdent,3,14))
         and substring (icodeIdent,17,2) eq "21"
      then do:
         mMRCCode = yes.
         ChekTypeMarkByDm(icodeIdent).
         block-teg:
         do while Velement ne "" and icodeIdent ne "":
            Velement = GetNextElement(no,output vteg, output vtegval, input-output icodeIdent).
            if vteg ne ""
            then
               oTeg = oTeg + "(" + vteg + ")" + vtegval .
         end.
         mMRCCode = no.
      end.
      else do:
         oTeg = icodeIdent.
      end.
   end.
   return oTeg.
end.
function getlevelByCodId return int
(iCode as char):
   define variable vLength as int no-undo.
   define variable vLevel  as int no-undo.
   if not ChekTypeMarkByDM (icode) then return ?.
   vLength = length(iCode).
   if    vLength eq 18
      or vLength eq 20
   then
      Vlevel = 4.
   else if vLength eq 21
   then
      Vlevel = 1.
   else if vLength eq 25
   then do:
      if  iCode begins "01"
      then
         Vlevel = 3.
      else
         Vlevel = 1.
   end.
   else if     vLength >= 26
           and vLength <= 46
   then do:
      if    substring(iCode,17,2) eq "11"
         or substring(iCode,17,2) eq "13"
         or (    substring(iCode,17,2) eq "21"
             and vLength >= 33
             and substring(iCode,26,4) ne "8005")
      then
         Vlevel = 4.
      else if    vLength eq 31
              or vLength eq 38
              or vLength eq 39
              or vLength eq 45
      then
         Vlevel = 1.
      else if    vLength eq 35
              or vLength eq 43
      then
         Vlevel = 3.
      else
         Vlevel = ?.
   end.
   else
      Vlevel = ?.
   return Vlevel.
end.
function getLevelMotpBycodid return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 6
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByLevelMotp return character
(iUnit as char):
   define variable vLevel as integer no-undo.
   define variable vListMOTP    as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   define variable vListutd as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = lookup(iUnit,vListMOTP).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vListutd).
end.
function getLevelMotpByDM return character
(iDm as char):
   return getLevelMotpByCodId(GetCodeIdent(iDm)).
end.
function getLevelUTDByCodId return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByDM return character
(iDm as char):
   return getLevelUTDByCodId(GetCodeIdent(iDm)).
end.
define variable mNotMarkQnty as logical no-undo.
function getQntyUTDByCodId return decimal
(iDM as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "1,5,10,500".
   define variable vGtin as character no-undo.
   define variable vqnty as decimal no-undo init ?.
   vqnty = dec(GetTegCod(iDM,"37")) no-error.
   if vqnty eq ?
   then do:
      if not mNotMarkQnty
      then do:
         define buffer marking for ub.marking.
         define variable vCodident as character no-undo.
         vCodident = GetCodeIdent(idm).
         find first marking where marking.mark begins vCodident no-lock no-error.
         if     available marking
            and marking.box-qnty ne ?
         then
            return marking.box-qnty.
      end.
      vGtin = getGtinByDm(iDM).
      if ChekTypeMarkByGtin (vGtin)
      then do:
         vLevel = getlevelByCodId(iDM).
         if     vLevel >= 1
            and vLevel <= 4
         then
            vqnty = int(entry(vlevel,vList)).
      end.
      else
         vqnty = getQntyCodeByGtin(vgtin).
   end.
   return vqnty.
end.
function getQntyUTDByDM return decimal
(iDm as char):
   define variable vDM as character no-undo.
   if     length (iDm) ne 25
      and length (iDm) ne 29
      and substring (iDm,length (iDm) - 6 + 1, 2 ) eq "93"
   then
      vDM = substring (iDm,1,length (iDm) - 6 ).
   else
      vDM = substring (iDm,1,length (iDm) - 4 ).
   return getQntyUTDByCodId(vDM).
end.
function getMRC4 return decimal
(iMRC as char):
   define variable oMrc     as decimal no-undo init ?.
   define variable vAlphabet as character no-undo init "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!~"%&'*+-./_,:;=<>?".
   define variable vi       as integer no-undo.
   define variable vfound   as integer no-undo.
   define variable vposStart   as integer no-undo.
   do:
   OMRc = 0.
   do vi = 1 to 4:
      define variable vsimb as character no-undo.
      vsimb = substring(iMRC,vi,1).
      vposStart = if keycode("Z") < keycode(vsimb) then 27 else 1.
      vfound = index(vAlphabet,vsimb,vposStart) - 1.
      if vfound > 0
      then
         OMRc = OMRc + exp (80,(4 - vi) ) * vfound  .
      end.
      OMRc = OMRc / 100.
   end.
   return OMRc.
end.
function getMRCByDM return decimal
(iDm as char):
   define variable vMRC     as character no-undo.
   define variable oMrc     as decimal no-undo init ?.
   define variable Velement as character no-undo init "empty".
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if    length(idm) eq 14 + 7 + 4 + 4
      or length(idm) eq 14 + 7 + 4
   then do:
      vMRC = substring(idm,22,4).
      omrc = getMRC4(vMRC).
   end.
   else do:
       ChekTypeMarkByDm(iDm).
       block-mrc:
       do while Velement ne "" and idm ne "":
          Velement = GetNextElement(yes,output vteg, output vtegval, input-output idm).
          if Velement begins "8005"
          then do:
             vMRC = substring(Velement,5,6).
             leave block-mrc.
          end.
          else if Velement begins "(8005)"
          then do:
             vMRC = substring(Velement,7,6).
             leave block-mrc.
          end.
       end.
       if vMRC ne ""
       then
          OMRc = dec(vmrc) / 100 no-error.
   end.
   return OMRc.
end.
function MoveDate return Date
(idate as date,
 iMonth as int64):
   define variable vMonth   as int64 no-undo.
   define variable vYear    as int64 no-undo.
   define variable vDateNew as date  no-undo.
    define variable vDay     as int64 no-undo.
    vMonth = month(iDate) + iMonth.
    vYear =  year(iDate).
    if vMonth <= 0
    then assign
       vMonth = vMonth + 12
        vYear  = vYear - 1
    .
    else if vMonth > 12
    then assign
       vMonth = vMonth - 12
        vYear  = vYear + 1
    .
    vDateNew = date(vMonth,day(iDate),vYear) no-error.
    do while error-status:error eq yes:
       VDay = vDay + 1.
       vDateNew = date(vMonth,day(iDate) - vDay,vYear) no-error.
    end.
    if VDay > 0
    then
       vDateNew + 1.
    return vDateNew.
end.
procedure checkEMRC:
define input  parameter iDm as character no-undo.
define output parameter vok as logical   no-undo init yes.
   define variable v-value-emrc as character no-undo.
   define variable v-type-emrc  as character no-undo.
   define variable vDateIso     as character no-undo.
   define variable vMRC         as decimal no-undo.
   define variable vqnty        as decimal no-undo.
   define variable vPrice       as decimal no-undo.
   define variable vparent      as character no-undo.
   define variable vgds-code    as integer no-undo.
   define buffer code for ub.code.
   vMRC = getMRCByDM(iDm).
   if vMRC > 0
   then do:
      vgds-code = getGdsCodeByDM(iDm).
      vqnty     = getQntyUTDByDM(iDm).
            if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
         (
          input   vgds-code
         ,input   'emrc-type':U
         ,output   v-value-emrc
         ,output   v-type-emrc
       ) no-error.
       if     v-value-emrc ne ""
          and v-value-emrc ne ?
       then do:
          vDateIso = iso-date(today).
          vPrice = vMRC / vqnty.
          vparent ="emc" + chr(4) + v-value-emrc.
          find last code where Code.parent      eq vparent
                           and Code.code        le vDateIso
                           and code.status_  eq 0
          no-lock no-error.
          if not available code or ( vPrice  >= dec(Code.CodeValue))
          then
             vOk = true .
          else do:
              define variable vText      as character no-undo.
              define variable vDate      as date no-undo.
              define variable vDateLast  as character no-undo.
              define variable vDateFirst as character no-undo.
              define variable vDate3     as date no-undo.
              vdate = date(code.misc1).
              vDateLast = code.misc1.
              vDate3 = MoveDate(today, - 3 ).
              vText =  substitute ("ТОВАР ИМЕЕТ ОГРАНИЧЕННЫЙ СРОК РЕАЛИЗАЦИИ. Если товар произведен после &2, то его приемка и продажа запрещена.",
                                   string(vDate3  , "99/99/9999"),
                                   string(vDate   , "99/99/9999")
                                   ).
              vdateIso = iso-date(vdate3).
              find last code  where Code.parent      eq vparent
                                and Code.code        le vDateIso
                                and code.status_  eq 0 no-lock no-error.
              if available code
              then
                 vDateIso = code.code.
              vDateFirst = vDateIso.
              vDateLast = iso-date(vdate).
              define variable vGood as logical no-undo.
              define variable vDateSale as date no-undo.
              define buffer bcode for code.
              for last code where Code.parent   eq vparent
                              and code.status_  eq 0
                              and code.code     < vDateLast
                              and code.code     >= vDateFirst
              no-lock:
                 find first bcode where bCode.parent   eq vparent
                                    and bcode.status_  eq 0
                                    and bcode.code     > code.code no-lock no-error.
                 if available bcode
                 then do:
                    if vPrice < dec(Code.CodeValue)
                    then
                       vText = vtext + substitute ("&1Если товар произведен с &2 до &3, ТО ЕГО ПРИЕМКА И ПРОДАЖА ЗАПРЕЩЕНА",
                                                  chr(10),
                                                  string(    date( code.misc1)       ,"99/99/9999"),
                                                  string(    date(bcode.misc1)       ,"99/99/9999")
                                                  ).
                    else do:
                       vGood = yes.
                       vDateSale = MoveDate(date(bcode.misc1), 3) - 1.
                       vText = vtext + substitute ("&1Если товар произведен до &3, то продажа разрешена до &4.~Осталось &5 дней.",
                                                  chr(10),
                                                  string(    date( code.misc1)         ,"99/99/9999"),
                                                  string(    date(bcode.misc1)         ,"99/99/9999"),
                                                  string(         vDateSale            ,"99/99/9999"),
                                                  string(vDateSale - today)
                                                  ).
                    end.
                 end.
              end.
              if vgood
              then do:
                 define variable choice as integer no-undo .
                 run gbl/d-askw.w (input "Уточнение"
                        ,input  vText
                        ,input "|"
                        ,input "Принять|Вернуть"
                        ,input "Принять данный товар|Вернуть товар постащику"
                        ,input 1
                        ,input 2
                        ,output choice) no-error.
                 vok = choice eq 1.
              end.
              else
                 vok =false.
          end.
       end.
   end.
end.
function addGs2Mark return character
(iMark as char):
   define variable vDM   as character no-undo.
   define variable vIdx  as integer   no-undo.
   if index(iMark,chr(29),1) > 0
   then return iMark.
   if substring(iMark,26,4) = "8005" then
   do:
     vIdx = index(iMark,"93",26 + 4 + 5).
     if vIdx > 1 then do:
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,25),
                        substring(iMark,26,vIdx - 25 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       vIdx = index(vDm,"240",vIdx + 4).
       if vIdx > 0 then
       do:
         vDM = substitute("&1&3&2",
                          substring(vDm,1,vIdx - 1),
                          substring(vDm,vIdx),
                          chr(29)) no-error.
       end.
     end.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,25),
                        substring(iMark,26),
                        chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "91" then
   do:
     vIdx = index(iMark,"92",32).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,31),
                        substring(iMark,32,vIdx - 31 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,31),
                        substring(iMark,32),
                        chr(29)) no-error.
   end.
   else if substring(iMark,39,2) = "91" then
   do:
     vIdx = index(iMark,"92",38).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,38),
                        substring(iMark,39,vIdx - 38 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,38),
                        substring(iMark,39),
                        chr(29)) no-error.
   end.
   else if substring(iMark,25,2) = "93" then
   do:
     vIdx = index(iMark,"92",25).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vIdx = index(iMark,"3103",25).
       if vIdx > 0 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       else
         vDM = substitute("&1&3&2",
                          substring(iMark,1,24),
                          substring(iMark,25),
                          chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "93" then
   do:
     vDM = substitute("&1&3&2",
           substring(iMark,1,31),
           substring(iMark,32),
           chr(29)) no-error.
   end.
   return if vDM <> "" then vDm else iMark.
end.
define temp-table wt-marking no-undo like ub.marking.
PROCEDURE proc-load-marking:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-marking. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-marking. stop" )
  on endkey undo, return error substitute( "$proc-load-marking. endkey" )
  :
    define buffer tb-marking for ub.marking.
    define variable compare-log as logical no-undo.
    define variable gtin as character no-undo.
    for each wt-marking
    on error undo, return error substitute( "$proc-load-marking(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-marking .
    end.
    create wt-marking.
    run nws-impl in p-imp-handle
      ( input 'marking':U
       ,input (buffer wt-marking:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-marking
      where tb-marking.mark = wt-marking.mark
      exclusive-lock no-error.
    if l-counter <> 0 then do:
      return error substitute( "&1 &2. Ошибка обработки записи &3", vss-workfile, vss-revision, 'marking':U )
                   + chr(10) + "Есть привязанные записи, а обработка идет для одной".
    end.
    if not available tb-marking then do:
      create tb-marking.
      assign compare-log = no.
    end.
    else do:
      buffer-compare tb-marking TO wt-marking case-sensitive save result in compare-log no-error.
    end.
    if not compare-log then do:
      buffer-copy wt-marking TO tb-marking.
    end.
    delete wt-marking.
  end.
END PROCEDURE.
define temp-table locb-ord-gds-cons      no-undo like ub.ord-gds-cons.
define temp-table locb-ord-dtl-cons      no-undo like ub.ord-dtl-cons.
define temp-table wt-ord-cons no-undo like ub.ord-cons.
PROCEDURE proc-load-ord-cons:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-ord-cons. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-ord-cons. stop" )
  on endkey undo, return error substitute( "$proc-load-ord-cons. endkey" )
  :
    define buffer tb-ord-cons for ub.ord-cons.
    define variable compare-log as logical no-undo.
define variable vss-include-info111 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_ord-gds-cons      for ub.ord-gds-cons.
define buffer buf_ord-dtl-cons      for ub.ord-dtl-cons.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-ord-gds-cons
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-gds-cons.
end.
for each locb-ord-dtl-cons
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-dtl-cons.
end.
    for each wt-ord-cons
    on error undo, return error substitute( "$proc-load-ord-cons(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-ord-cons .
    end.
    create wt-ord-cons.
    run nws-impl in p-imp-handle
      ( input 'ord-cons':U
       ,input (buffer wt-ord-cons:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-ord-cons
      where tb-ord-cons.cons-code = wt-ord-cons.cons-code
      exclusive-lock no-error.
define variable vss-include-info112 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "ord-gds-cons" then do:
      create locb-ord-gds-cons.
run nws-impl in p-imp-handle
  ( input "ord-gds-cons":U
   ,input (buffer locb-ord-gds-cons:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "ord-dtl-cons" then do:
      create locb-ord-dtl-cons.
run nws-impl in p-imp-handle
  ( input "ord-dtl-cons":U
   ,input (buffer locb-ord-dtl-cons:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе савокупных заявок."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_ord-gds-cons where buf_ord-gds-cons.cons-code = wt-ord-cons.cons-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-gds-cons.
end.
for each locb-ord-gds-cons where locb-ord-gds-cons.cons-code = wt-ord-cons.cons-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-gds-cons.
  buffer-copy locb-ord-gds-cons to buf_ord-gds-cons.
end.
for each buf_ord-dtl-cons where buf_ord-dtl-cons.cons-code = wt-ord-cons.cons-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-dtl-cons.
end.
for each locb-ord-dtl-cons where locb-ord-dtl-cons.cons-code = wt-ord-cons.cons-code
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-dtl-cons.
  buffer-copy locb-ord-dtl-cons to buf_ord-dtl-cons.
end.
if not available tb-ord-cons then do:
  create tb-ord-cons.
end.
define variable v-old-ord-cons-status as character no-undo .
define variable v-new-ord-cons-status as character no-undo .
if tb-ord-cons.status_ = ""
or tb-ord-cons.status_ = ?
then do:
  assign
    v-old-ord-cons-status = ""
  .
end.
else do:
  assign
    v-old-ord-cons-status = tb-ord-cons.status_ + string(tb-ord-cons.flag_, '+/-':u)
  .
end.
assign
  v-new-ord-cons-status = wt-ord-cons.status_ + string(wt-ord-cons.flag_, '+/-':u)
.
run trg/nwsdochs.p
  (input g#db-num
  ,input 'update':U
  ,input wt-ord-cons.cons-code
  ,input wt-ord-cons.input-obj-type
  ,input wt-ord-cons.input-obj-code
  ,input 'ord-cons':U
  ,input '':u
  ,input wt-ord-cons.fact-date
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input v-old-ord-cons-status
  ,input v-new-ord-cons-status
  ,input g#news-source-db
  ,input p-pck-num
  ,input wt-ord-cons.user-db-num
  ,input wt-ord-cons.user-name
  ,input wt-ord-cons.sys-date
  ,input wt-ord-cons.sys-time
  ,input wt-ord-cons.sys-time-int
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.
buffer-copy wt-ord-cons to tb-ord-cons.
for each locb-ord-gds-cons
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-gds-cons.
end.
for each locb-ord-dtl-cons
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-dtl-cons.
end.
    delete wt-ord-cons.
  end.
END PROCEDURE.
define temp-table locb-ord-line      no-undo like ub.ord-line.
define temp-table locb-ord-line-attr no-undo like ub.ord-line-attr.
define temp-table locb-ord-doc-attr  no-undo like ub.ord-doc-attr.
define temp-table locb-ord-dtl       no-undo like ub.ord-dtl.
define temp-table wt-ord-doc no-undo like ub.ord-doc.
PROCEDURE proc-load-ord-doc:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-ord-doc. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-ord-doc. stop" )
  on endkey undo, return error substitute( "$proc-load-ord-doc. endkey" )
  :
    define buffer tb-ord-doc for ub.ord-doc.
    define variable compare-log as logical no-undo.
define variable vss-include-info113 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_ord-line      for ub.ord-line.
define buffer buf_ord-dtl       for ub.ord-dtl.
define buffer buf_ord-line-attr      for ub.ord-line-attr.
define buffer buf_ord-doc-attr       for ub.ord-doc-attr.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-ord-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-line.
end.
for each locb-ord-line-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-line-attr.
end.
for each locb-ord-doc-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-doc-attr.
end.
for each locb-ord-dtl
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-dtl.
end.
    for each wt-ord-doc
    on error undo, return error substitute( "$proc-load-ord-doc(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-ord-doc .
    end.
    create wt-ord-doc.
    run nws-impl in p-imp-handle
      ( input 'ord-doc':U
       ,input (buffer wt-ord-doc:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-ord-doc
      where tb-ord-doc.doc-code = wt-ord-doc.doc-code
      exclusive-lock no-error.
define variable vss-include-info114 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "ord-line" then do:
      create locb-ord-line.
run nws-impl in p-imp-handle
  ( input "ord-line":U
   ,input (buffer locb-ord-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "ord-line-attr" then do:
      create locb-ord-line-attr.
run nws-impl in p-imp-handle
  ( input "ord-line-attr":U
   ,input (buffer locb-ord-line-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "ord-doc-attr" then do:
      create locb-ord-doc-attr.
run nws-impl in p-imp-handle
  ( input "ord-doc-attr":U
   ,input (buffer locb-ord-doc-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "ord-dtl" then do:
      create locb-ord-dtl.
run nws-impl in p-imp-handle
  ( input "ord-dtl":U
   ,input (buffer locb-ord-dtl:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе заказов."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_ord-line where buf_ord-line.doc-code = wt-ord-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-line.
end.
for each locb-ord-line where locb-ord-line.doc-code = wt-ord-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-line.
  buffer-copy locb-ord-line to buf_ord-line.
end.
for each buf_ord-line-attr where buf_ord-line-attr.doc-code = wt-ord-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-line-attr.
end.
for each locb-ord-line-attr where locb-ord-line-attr.doc-code = wt-ord-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-line-attr.
  buffer-copy locb-ord-line-attr to buf_ord-line-attr.
end.
for each buf_ord-doc-attr where buf_ord-doc-attr.doc-code = wt-ord-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-doc-attr.
end.
for each locb-ord-doc-attr where locb-ord-doc-attr.doc-code = wt-ord-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-doc-attr.
  buffer-copy locb-ord-doc-attr to buf_ord-doc-attr.
end.
for each buf_ord-dtl where buf_ord-dtl.doc-code = wt-ord-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-dtl.
end.
for each locb-ord-dtl where locb-ord-dtl.doc-code = wt-ord-doc.doc-code
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-dtl.
  buffer-copy locb-ord-dtl to buf_ord-dtl.
end.
if not available tb-ord-doc then do:
  create tb-ord-doc.
end.
define variable v-old-ord-doc-status as character no-undo .
define variable v-new-ord-doc-status as character no-undo .
if tb-ord-doc.status_ = ""
or tb-ord-doc.status_ = ?
then do:
  assign
    v-old-ord-doc-status = ""
  .
end.
else do:
  assign
    v-old-ord-doc-status = tb-ord-doc.status_ + string(tb-ord-doc.flag_, '+/-':u)
  .
end.
assign
  v-new-ord-doc-status = wt-ord-doc.status_ + string(wt-ord-doc.flag_, '+/-':u)
.
run trg/nwsdochs.p
  (input g#db-num
  ,input 'update':U
  ,input wt-ord-doc.doc-code
  ,input wt-ord-doc.obj-type
  ,input wt-ord-doc.obj-code
  ,input 'ord-doc':U
  ,input '':u
  ,input wt-ord-doc.fact-date
  ,input wt-ord-doc.cli-qnty
  ,input 0
  ,input 0
  ,input 0
  ,input v-old-ord-doc-status
  ,input v-new-ord-doc-status
  ,input g#news-source-db
  ,input p-pck-num
  ,input wt-ord-doc.user-db-num
  ,input wt-ord-doc.user-name
  ,input wt-ord-doc.sys-date
  ,input wt-ord-doc.sys-time
  ,input wt-ord-doc.sys-time-int
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.
buffer-copy wt-ord-doc to tb-ord-doc.
for each locb-ord-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-line.
end.
for each locb-ord-line-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-line-attr.
end.
for each locb-ord-doc-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-doc-attr.
end.
for each locb-ord-dtl
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-dtl.
end.
    delete wt-ord-doc.
  end.
END PROCEDURE.
define temp-table locb-c-ord-line      no-undo like ub.c-ord-line.
define temp-table wt-c-ord-doc no-undo like ub.c-ord-doc.
PROCEDURE proc-load-c-ord-doc:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-c-ord-doc. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-c-ord-doc. stop" )
  on endkey undo, return error substitute( "$proc-load-c-ord-doc. endkey" )
  :
    define buffer tb-c-ord-doc for ub.c-ord-doc.
    define variable compare-log as logical no-undo.
define variable vss-include-info115 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_c-ord-line     for ub.c-ord-line.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-c-ord-line
on error  undo, return error
:
  delete locb-c-ord-line.
end.
    for each wt-c-ord-doc
    on error undo, return error substitute( "$proc-load-c-ord-doc(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-c-ord-doc .
    end.
    create wt-c-ord-doc.
    run nws-impl in p-imp-handle
      ( input 'c-ord-doc':U
       ,input (buffer wt-c-ord-doc:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-c-ord-doc
      where tb-c-ord-doc.doc-code = wt-c-ord-doc.doc-code
        and tb-c-ord-doc.corr-user-db-num = wt-c-ord-doc.corr-user-db-num
        and tb-c-ord-doc.chip-num = wt-c-ord-doc.chip-num
      exclusive-lock no-error.
define variable vss-include-info116 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "c-ord-line" then do:
      create locb-c-ord-line.
run nws-impl in p-imp-handle
  ( input "c-ord-line":U
   ,input (buffer locb-c-ord-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе истории заказа."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_c-ord-line where buf_c-ord-line.doc-code = wt-c-ord-doc.doc-code and
                              buf_c-ord-line.chip-num = wt-c-ord-doc.chip-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-ord-line.
end.
for each locb-c-ord-line where locb-c-ord-line.doc-code = wt-c-ord-doc.doc-code and
                               locb-c-ord-line.chip-num = wt-c-ord-doc.chip-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-ord-line.
  buffer-copy locb-c-ord-line to buf_c-ord-line.
end.
if not available tb-c-ord-doc then do:
  create tb-c-ord-doc.
end.
buffer-copy wt-c-ord-doc to tb-c-ord-doc.
for each locb-c-ord-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-ord-line.
end.
    delete wt-c-ord-doc.
  end.
END PROCEDURE.
define temp-table locb-ord-line-rcv    no-undo like ub.ord-line-rcv.
define temp-table locb-ord-dtl-rcv     no-undo like ub.ord-dtl-rcv.
define temp-table rcvlocb-ord-line     no-undo like ub.ord-line.
define temp-table rcvlocb-ord-dtl      no-undo like ub.ord-dtl.
define temp-table rcvlocb-ord-doc      no-undo like ub.ord-doc.
define temp-table locb-ord-rcv-attr         no-undo like ub.ord-rcv-attr.
define temp-table locb-ord-rcv-line-attr    no-undo like ub.ord-rcv-line-attr.
define temp-table rcvlocb-ord-line-attr     no-undo like ub.ord-line-attr.
define temp-table rcvlocb-ord-doc-attr      no-undo like ub.ord-doc-attr.
define temp-table wt-ord-doc-rcv no-undo like ub.ord-doc-rcv.
PROCEDURE proc-load-ord-doc-rcv:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-ord-doc-rcv. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-ord-doc-rcv. stop" )
  on endkey undo, return error substitute( "$proc-load-ord-doc-rcv. endkey" )
  :
    define buffer tb-ord-doc-rcv for ub.ord-doc-rcv.
    define variable compare-log as logical no-undo.
define variable vss-include-info117 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_ord-line-rcv      for ub.ord-line-rcv.
define buffer buf_ord-dtl-rcv       for ub.ord-dtl-rcv.
define buffer buf_ord-line      for ub.ord-line.
define buffer buf_ord-dtl       for ub.ord-dtl.
define buffer buf_ord-doc       for ub.ord-doc.
define buffer buf_ord-rcv-line-attr for ub.ord-rcv-line-attr.
define buffer buf_ord-rcv-attr  for ub.ord-rcv-attr.
define buffer buf_ord-line-attr for ub.ord-line-attr.
define buffer buf_ord-doc-attr  for ub.ord-doc-attr.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-ord-line-rcv
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-line-rcv.
end.
for each locb-ord-rcv-line-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-rcv-line-attr.
end.
for each locb-ord-rcv-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-rcv-attr.
end.
for each locb-ord-dtl-rcv
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-dtl-rcv.
end.
for each rcvlocb-ord-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete rcvlocb-ord-line.
end.
for each rcvlocb-ord-line-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete rcvlocb-ord-line-attr.
end.
for each rcvlocb-ord-dtl
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete rcvlocb-ord-dtl.
end.
for each rcvlocb-ord-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete rcvlocb-ord-doc.
end.
for each rcvlocb-ord-doc-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete rcvlocb-ord-doc-attr.
end.
    for each wt-ord-doc-rcv
    on error undo, return error substitute( "$proc-load-ord-doc-rcv(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-ord-doc-rcv .
    end.
    create wt-ord-doc-rcv.
    run nws-impl in p-imp-handle
      ( input 'ord-doc-rcv':U
       ,input (buffer wt-ord-doc-rcv:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-ord-doc-rcv
      where tb-ord-doc-rcv.doc-code = wt-ord-doc-rcv.doc-code
        and tb-ord-doc-rcv.rcv-code = wt-ord-doc-rcv.rcv-code
      exclusive-lock no-error.
define variable vss-include-info118 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "ord-line-rcv" then do:
      create locb-ord-line-rcv.
run nws-impl in p-imp-handle
  ( input "ord-line-rcv":U
   ,input (buffer locb-ord-line-rcv:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "ord-dtl-rcv" then do:
      create locb-ord-dtl-rcv.
run nws-impl in p-imp-handle
  ( input "ord-dtl-rcv":U
   ,input (buffer locb-ord-dtl-rcv:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "ord-line" then do:
      create rcvlocb-ord-line.
run nws-impl in p-imp-handle
  ( input "ord-line":U
   ,input (buffer rcvlocb-ord-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "ord-dtl" then do:
      create rcvlocb-ord-dtl.
run nws-impl in p-imp-handle
  ( input "ord-dtl":U
   ,input (buffer rcvlocb-ord-dtl:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "ord-doc" then do:
      create rcvlocb-ord-doc.
run nws-impl in p-imp-handle
  ( input "ord-doc":U
   ,input (buffer rcvlocb-ord-doc:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "ord-rcv-line-attr" then do:
      create locb-ord-rcv-line-attr.
run nws-impl in p-imp-handle
  ( input "ord-rcv-line-attr":U
   ,input (buffer locb-ord-rcv-line-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "ord-line-attr" then do:
      create rcvlocb-ord-line-attr.
run nws-impl in p-imp-handle
  ( input "ord-line-attr":U
   ,input (buffer rcvlocb-ord-line-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "ord-doc-attr" then do:
      create rcvlocb-ord-doc-attr.
run nws-impl in p-imp-handle
  ( input "ord-doc-attr":U
   ,input (buffer rcvlocb-ord-doc-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "ord-rcv-attr" then do:
      create locb-ord-rcv-attr.
run nws-impl in p-imp-handle
  ( input "ord-rcv-attr":U
   ,input (buffer locb-ord-rcv-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе поставок под заказы."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each rcvlocb-ord-doc where rcvlocb-ord-doc.doc-code = wt-ord-doc-rcv.doc-code and
                               rcvlocb-ord-doc.doc-type <> 'ОР':U
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
if not can-find(first buf_ord-doc where buf_ord-doc.doc-code = wt-ord-doc-rcv.doc-code
      and buf_ord-doc.doc-type <> 'ОР':U no-lock )
   then create buf_ord-doc.
   else find buf_ord-doc where buf_ord-doc.doc-code = wt-ord-doc-rcv.doc-code
                           and buf_ord-doc.doc-type <> 'ОР':U
                               exclusive-lock no-error.
  buffer-copy rcvlocb-ord-doc to buf_ord-doc.
end.
for each rcvlocb-ord-doc-attr where rcvlocb-ord-doc-attr.doc-code = wt-ord-doc-rcv.doc-code
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
if not can-find(first buf_ord-doc-attr where buf_ord-doc-attr.doc-code = wt-ord-doc-rcv.doc-code no-lock )
   then create buf_ord-doc-attr.
   else find buf_ord-doc-attr where buf_ord-doc-attr.doc-code = wt-ord-doc-rcv.doc-code exclusive-lock no-error.
  buffer-copy rcvlocb-ord-doc-attr to buf_ord-doc-attr.
end.
for each buf_ord-line-rcv where buf_ord-line-rcv.rcv-code = wt-ord-doc-rcv.rcv-code and
                                buf_ord-line-rcv.doc-code = wt-ord-doc-rcv.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-line-rcv.
end.
for each locb-ord-line-rcv where locb-ord-line-rcv.rcv-code = wt-ord-doc-rcv.rcv-code and
                                 locb-ord-line-rcv.doc-code = wt-ord-doc-rcv.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-line-rcv.
  buffer-copy locb-ord-line-rcv to buf_ord-line-rcv.
end.
for each buf_ord-rcv-line-attr where buf_ord-rcv-line-attr.rcv-code = wt-ord-doc-rcv.rcv-code and
                                buf_ord-rcv-line-attr.doc-code = wt-ord-doc-rcv.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-rcv-line-attr.
end.
for each locb-ord-rcv-line-attr where locb-ord-rcv-line-attr.rcv-code = wt-ord-doc-rcv.rcv-code and
                                 locb-ord-rcv-line-attr.doc-code = wt-ord-doc-rcv.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-rcv-line-attr.
  buffer-copy locb-ord-rcv-line-attr to buf_ord-rcv-line-attr.
end.
for each buf_ord-rcv-attr where buf_ord-rcv-attr.rcv-code = wt-ord-doc-rcv.rcv-code and
                                buf_ord-rcv-attr.doc-code = wt-ord-doc-rcv.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-rcv-attr.
end.
for each locb-ord-rcv-attr where locb-ord-rcv-attr.rcv-code = wt-ord-doc-rcv.rcv-code and
                                 locb-ord-rcv-attr.doc-code = wt-ord-doc-rcv.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-rcv-attr.
  buffer-copy locb-ord-rcv-attr to buf_ord-rcv-attr.
end.
for each buf_ord-dtl-rcv where buf_ord-dtl-rcv.rcv-code = wt-ord-doc-rcv.rcv-code and
                               buf_ord-dtl-rcv.doc-code = wt-ord-doc-rcv.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-dtl-rcv.
end.
for each locb-ord-dtl-rcv where locb-ord-dtl-rcv.rcv-code = wt-ord-doc-rcv.rcv-code and
                                locb-ord-dtl-rcv.doc-code = wt-ord-doc-rcv.doc-code
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-dtl-rcv.
  buffer-copy locb-ord-dtl-rcv to buf_ord-dtl-rcv.
end.
for each buf_ord-line where buf_ord-line.doc-code = wt-ord-doc-rcv.doc-code,
    first buf_ord-doc no-lock where buf_ord-doc.doc-code = buf_ord-line.doc-code
                                and buf_ord-doc.doc-type <> 'ОР':U
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-line.
end.
for each rcvlocb-ord-line where rcvlocb-ord-line.doc-code = wt-ord-doc-rcv.doc-code no-lock,
    first buf_ord-doc no-lock where buf_ord-doc.doc-code = wt-ord-doc-rcv.doc-code
                                and buf_ord-doc.doc-type <> 'ОР':U
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-line.
  buffer-copy rcvlocb-ord-line to buf_ord-line.
end.
for each buf_ord-line-attr where buf_ord-line-attr.doc-code = wt-ord-doc-rcv.doc-code ,
    first buf_ord-doc no-lock where buf_ord-doc.doc-code = wt-ord-doc-rcv.doc-code
                                and buf_ord-doc.doc-type <> 'ОР':U
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-line-attr.
end.
for each rcvlocb-ord-line-attr where rcvlocb-ord-line-attr.doc-code = wt-ord-doc-rcv.doc-code no-lock ,
    first buf_ord-doc no-lock where buf_ord-doc.doc-code = wt-ord-doc-rcv.doc-code
                                and buf_ord-doc.doc-type <> 'ОР':U
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-line-attr.
  buffer-copy rcvlocb-ord-line-attr to buf_ord-line-attr.
end.
for each buf_ord-dtl where buf_ord-dtl.doc-code = wt-ord-doc-rcv.doc-code ,
    first buf_ord-doc no-lock where buf_ord-doc.doc-code = wt-ord-doc-rcv.doc-code
                                and buf_ord-doc.doc-type <> 'ОР':U
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_ord-dtl.
end.
for each rcvlocb-ord-dtl where rcvlocb-ord-dtl.doc-code = wt-ord-doc-rcv.doc-code
                      no-lock ,
    first buf_ord-doc no-lock where buf_ord-doc.doc-code = wt-ord-doc-rcv.doc-code
                                and buf_ord-doc.doc-type <> 'ОР':U
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_ord-dtl.
  buffer-copy rcvlocb-ord-dtl to buf_ord-dtl.
end.
if not available tb-ord-doc-rcv then do:
   create tb-ord-doc-rcv no-error.
end.
define variable v-old-ord-doc-rcv-status as character no-undo .
define variable v-new-ord-doc-rcv-status as character no-undo .
if tb-ord-doc-rcv.status_ = ""
or tb-ord-doc-rcv.status_ = ?
then do:
  assign
    v-old-ord-doc-rcv-status = ""
  .
end.
else do:
  assign
    v-old-ord-doc-rcv-status = tb-ord-doc-rcv.status_ + string(tb-ord-doc-rcv.flag_, '+/-':u)
  .
end.
assign
  v-new-ord-doc-rcv-status = wt-ord-doc-rcv.status_ + string(wt-ord-doc-rcv.flag_, '+/-':u)
.
run trg/nwsdochs.p
  (input g#db-num
  ,input 'update':U
  ,input wt-ord-doc-rcv.rcv-code
  ,input wt-ord-doc-rcv.obj-type
  ,input wt-ord-doc-rcv.obj-code
  ,input 'ord-doc-rcv':U
  ,input '':u
  ,input wt-ord-doc-rcv.fact-date
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input v-old-ord-doc-rcv-status
  ,input v-new-ord-doc-rcv-status
  ,input g#news-source-db
  ,input p-pck-num
  ,input wt-ord-doc-rcv.user-db-num
  ,input wt-ord-doc-rcv.user-name
  ,input wt-ord-doc-rcv.sys-date
  ,input wt-ord-doc-rcv.sys-time
  ,input wt-ord-doc-rcv.sys-time-int
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.
buffer-copy wt-ord-doc-rcv to tb-ord-doc-rcv no-error.
for each locb-ord-line-rcv
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-line-rcv.
end.
for each locb-ord-rcv-line-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-rcv-line-attr.
end.
for each locb-ord-rcv-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-rcv-attr.
end.
for each locb-ord-dtl-rcv
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-ord-dtl-rcv.
end.
for each rcvlocb-ord-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete rcvlocb-ord-line.
end.
for each rcvlocb-ord-line-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete rcvlocb-ord-line-attr.
end.
for each rcvlocb-ord-dtl
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete rcvlocb-ord-dtl.
end.
for each rcvlocb-ord-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete rcvlocb-ord-doc.
end.
for each rcvlocb-ord-doc-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete rcvlocb-ord-doc-attr.
end.
    delete wt-ord-doc-rcv.
  end.
END PROCEDURE.
define temp-table wt-person no-undo like ub.person.
PROCEDURE proc-load-person:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-person. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-person. stop" )
  on endkey undo, return error substitute( "$proc-load-person. endkey" )
  :
    define buffer tb-person for ub.person.
    define variable compare-log as logical no-undo.
define variable vss-include-info119 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-l as logical no-undo .
define buffer buf_dis-card for ub.dis-card .
    for each wt-person
    on error undo, return error substitute( "$proc-load-person(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-person .
    end.
    create wt-person.
    run nws-impl in p-imp-handle
      ( input 'person':U
       ,input (buffer wt-person:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-person
      where tb-person.psn-code = wt-person.psn-code
      exclusive-lock no-error.
define variable vss-include-info120 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if not available tb-person then do:
  create tb-person.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-person TO wt-person case-sensitive save result in compare-log no-error.
end.
 buffer-compare tb-person using city ind address name1 name2 TO wt-person case-sensitive save result in v-l no-error.
if not compare-log then do:
  buffer-copy wt-person TO tb-person.
end.
if not v-l then do:
  for each buf_dis-card no-lock where
           buf_dis-card.cli-type = 'чел':U
       AND buf_dis-card.cli-code = tb-person.psn-code:
    run fill-dc-list in p-imp-handle ( buffer buf_Dis-card) .
  end.
end.
    delete wt-person.
  end.
END PROCEDURE.
define temp-table locb-price-list no-undo like ub.price-list.
define temp-table locb-doc-attr      no-undo like ub.doc-attr.
define temp-table locb-price-list-attr no-undo like ub.price-list-attr.
define temp-table wt-price-doc no-undo like ub.price-doc.
PROCEDURE proc-load-price-doc:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-price-doc. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-price-doc. stop" )
  on endkey undo, return error substitute( "$proc-load-price-doc. endkey" )
  :
    define buffer tb-price-doc for ub.price-doc.
    define variable compare-log as logical no-undo.
define variable vss-include-info121 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_price-list      for ub.price-list.
define buffer buf_doc-attr        for ub.doc-attr.
define buffer buf_price-list-attr      for ub.price-list-attr.
def var counter  as   integer            no-undo.
def var rec-full as   character          no-undo.
def var rec-name as   character          no-undo.
def var bar_code like ub.bar-code.b-code no-undo .
define buffer buf_bar-code for ub.bar-code .
for each locb-price-list
on error  undo, return error
:
  delete locb-price-list.
end.
for each locb-doc-attr
on error  undo, return error
:
  delete locb-doc-attr.
end.
for each locb-price-list-attr
on error  undo, return error
:
  delete locb-price-list-attr.
end.
    for each wt-price-doc
    on error undo, return error substitute( "$proc-load-price-doc(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-price-doc .
    end.
    create wt-price-doc.
    run nws-impl in p-imp-handle
      ( input 'price-doc':U
       ,input (buffer wt-price-doc:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-price-doc
      where tb-price-doc.doc-num = wt-price-doc.doc-num
      exclusive-lock no-error.
define variable vss-include-info122 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "price-list" then do:
      create locb-price-list.
      run nws-impl-without-check in p-imp-handle
        ( input (buffer locb-price-list:handle)
        ) no-error.
      if error-status :error then do:
        return error return-value .
      end.
      run check-avail-artic in p-imp-handle
        ( input locb-price-list.artic
         ,input locb-price-list.prod-type
         ,input locb-price-list.prod-code
        ).
      run check-avail-b-code in p-imp-handle
        ( input-output locb-price-list.b-code
        ) no-error.
      if error-status :error then do:
        find first buf_bar-code no-lock
          where buf_bar-code.b-code = locb-price-list.b-code
          no-error
        .
        if not available buf_bar-code
          and locb-price-list.doc-qnty = ?
        then do:
          delete locb-price-list.
        end.
      end.
    end.
    when "doc-attr" then do:
      create locb-doc-attr.
run nws-impl in p-imp-handle
  ( input "doc-attr":U
   ,input (buffer locb-doc-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "price-list-attr" then do:
      create locb-price-list-attr.
run nws-impl in p-imp-handle
  ( input "price-list-attr":U
   ,input (buffer locb-price-list-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе переоценки."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_price-list where buf_price-list.doc-num = wt-price-doc.doc-num
on error  undo, return error
:
  delete buf_price-list.
end.
for each locb-price-list where locb-price-list.doc-num = wt-price-doc.doc-num
                         no-lock
on error  undo, return error
:
  create buf_price-list.
  buffer-copy  locb-price-list to buf_price-list.
end.
for each buf_doc-attr where buf_doc-attr.doc-code = wt-price-doc.doc-num
on error  undo, return error
:
  delete buf_doc-attr.
end.
for each locb-doc-attr where locb-doc-attr.doc-code = wt-price-doc.doc-num
                       no-lock
on error  undo, return error
:
  create buf_doc-attr.
  buffer-copy locb-doc-attr to buf_doc-attr.
end.
for each buf_price-list-attr where buf_price-list-attr.doc-num = wt-price-doc.doc-num
on error  undo, return error
:
  delete buf_price-list-attr.
end.
for each locb-price-list-attr where locb-price-list-attr.doc-num = wt-price-doc.doc-num
                       no-lock
on error  undo, return error
:
  create buf_price-list-attr.
  buffer-copy locb-price-list-attr to buf_price-list-attr.
end.
if not available tb-price-doc then do:
  create tb-price-doc.
end.
define variable v-old-price-doc-status as character no-undo .
define variable v-new-price-doc-status as character no-undo .
assign
  v-old-price-doc-status = tb-price-doc.status_
  v-new-price-doc-status = wt-price-doc.status_
.
run trg/nwsdochs.p
  (input g#db-num
  ,input 'update':U
  ,input wt-price-doc.doc-num
  ,input wt-price-doc.obj-type
  ,input wt-price-doc.obj-code
  ,input 'price-doc':U
  ,input 'ot':U
  ,input wt-price-doc.fact-date
  ,input wt-price-doc.rest-qnty
  ,input 0
  ,input 0
  ,input 0
  ,input v-old-price-doc-status
  ,input v-new-price-doc-status
  ,input g#news-source-db
  ,input p-pck-num
  ,input wt-price-doc.user-db-num
  ,input wt-price-doc.user-name
  ,input wt-price-doc.sys-date
  ,input wt-price-doc.sys-time
  ,input wt-price-doc.sys-time-int
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.
buffer-copy wt-price-doc to tb-price-doc.
for each locb-price-list
on error  undo, return error
:
  delete locb-price-list.
end.
for each locb-doc-attr
on error  undo, return error
:
  delete locb-doc-attr.
end.
for each locb-price-list-attr
on error  undo, return error
:
  delete locb-price-list-attr.
end.
    delete wt-price-doc.
  end.
END PROCEDURE.
define temp-table locb-c-price-doc       no-undo like ub.c-price-doc.
define temp-table locb-c-price-list      no-undo like ub.c-price-list.
define temp-table locb-c-price-list-attr no-undo like ub.c-price-list-attr.
define temp-table locb-c-doc-attr        no-undo like ub.c-doc-attr.
define temp-table wt-c-price-doc no-undo like ub.c-price-doc.
PROCEDURE proc-load-c-price-doc:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-c-price-doc. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-c-price-doc. stop" )
  on endkey undo, return error substitute( "$proc-load-c-price-doc. endkey" )
  :
    define buffer tb-c-price-doc for ub.c-price-doc.
    define variable compare-log as logical no-undo.
define variable vss-include-info123 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_c-price-doc       for ub.c-price-doc.
define buffer buf_c-price-list      for ub.c-price-list.
define buffer buf_c-price-list-attr for ub.c-price-list-attr.
define buffer buf_c-doc-attr        for ub.c-doc-attr.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-c-price-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-price-doc.
end.
for each locb-c-price-list
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-price-list.
end.
for each locb-c-doc-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-attr.
end.
for each locb-c-price-list-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-price-list-attr.
end.
    for each wt-c-price-doc
    on error undo, return error substitute( "$proc-load-c-price-doc(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-c-price-doc .
    end.
    create wt-c-price-doc.
    run nws-impl in p-imp-handle
      ( input 'c-price-doc':U
       ,input (buffer wt-c-price-doc:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-c-price-doc
      where tb-c-price-doc.doc-num = wt-c-price-doc.doc-num
        and tb-c-price-doc.corr-user-db-num = wt-c-price-doc.corr-user-db-num
        and tb-c-price-doc.chip-num = wt-c-price-doc.chip-num
      exclusive-lock no-error.
define variable vss-include-info124 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "c-price-list" then do:
      create locb-c-price-list.
run nws-impl in p-imp-handle
  ( input "c-price-list":U
   ,input (buffer locb-c-price-list:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе истории переоценки."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_c-price-list where buf_c-price-list.doc-num = wt-c-price-doc.doc-num and
                              buf_c-price-list.chip-num = wt-c-price-doc.chip-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-price-list.
end.
for each locb-c-price-list where locb-c-price-list.doc-num = wt-c-price-doc.doc-num and
                               locb-c-price-list.chip-num = wt-c-price-doc.chip-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-price-list.
  buffer-copy locb-c-price-list to buf_c-price-list.
end.
if not available tb-c-price-doc then do:
  create tb-c-price-doc.
end.
buffer-copy wt-c-price-doc to tb-c-price-doc.
for each locb-c-price-list
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-price-list.
end.
    delete wt-c-price-doc.
  end.
END PROCEDURE.
define temp-table locb-price-doc-forming              no-undo like  ub.price-doc-forming            .
define temp-table locb-price-doc-forming-attr         no-undo like  ub.price-doc-forming-attr       .
define temp-table locb-price-doc-forming-gds          no-undo like  ub.price-doc-forming-gds        .
define temp-table locb-price-doc-forming-gds-qnty     no-undo like  ub.price-doc-forming-gds-qnty   .
define temp-table locb-price-doc-forming-gds-sum      no-undo like  ub.price-doc-forming-gds-sum    .
define temp-table locb-price-doc-forming-gds-tnv      no-undo like  ub.price-doc-forming-gds-tnv    .
define temp-table wt-price-doc-forming no-undo like ub.price-doc-forming.
PROCEDURE proc-load-price-doc-forming:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-price-doc-forming. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-price-doc-forming. stop" )
  on endkey undo, return error substitute( "$proc-load-price-doc-forming. endkey" )
  :
    define buffer tb-price-doc-forming for ub.price-doc-forming.
    define variable compare-log as logical no-undo.
define variable vss-include-info125 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_price-doc-forming                     for ub.price-doc-forming            .
define buffer buf_price-doc-forming-attr                for ub.price-doc-forming-attr       .
define buffer buf_price-doc-forming-gds                 for ub.price-doc-forming-gds        .
define buffer buf_price-doc-forming-gds-qnty            for ub.price-doc-forming-gds-qnty   .
define buffer buf_price-doc-forming-gds-sum             for ub.price-doc-forming-gds-sum    .
define buffer buf_price-doc-forming-gds-tnv             for ub.price-doc-forming-gds-tnv    .
define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.
define variable v-send-to-cash as logical no-undo .
for each locb-price-doc-forming
on error  undo, return error
:
  delete locb-price-doc-forming.
end.
for each locb-price-doc-forming-gds
on error  undo, return error
:
  delete locb-price-doc-forming-gds.
end.
for each locb-price-doc-forming-gds-qnty
on error  undo, return error
:
  delete locb-price-doc-forming-gds-qnty.
end.
for each locb-price-doc-forming-gds-sum
on error  undo, return error
:
  delete locb-price-doc-forming-gds-sum.
end.
for each locb-price-doc-forming-attr
on error  undo, return error
:
  delete locb-price-doc-forming-attr.
end.
for each locb-price-doc-forming-gds-tnv
on error  undo, return error
:
  delete locb-price-doc-forming-gds-tnv.
end.
    for each wt-price-doc-forming
    on error undo, return error substitute( "$proc-load-price-doc-forming(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-price-doc-forming .
    end.
    create wt-price-doc-forming.
    run nws-impl in p-imp-handle
      ( input 'price-doc-forming':U
       ,input (buffer wt-price-doc-forming:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-price-doc-forming
      where tb-price-doc-forming.plt-id = wt-price-doc-forming.plt-id
        and tb-price-doc-forming.plt-db-num = wt-price-doc-forming.plt-db-num
        and tb-price-doc-forming.pdf-id = wt-price-doc-forming.pdf-id
        and tb-price-doc-forming.pdf-db = wt-price-doc-forming.pdf-db
      exclusive-lock no-error.
define variable vss-include-info126 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "price-doc-forming-gds" then do:
      create locb-price-doc-forming-gds.
run nws-impl in p-imp-handle
  ( input "price-doc-forming-gds":U
   ,input (buffer locb-price-doc-forming-gds:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "price-doc-forming-gds-qnty" then do:
      create locb-price-doc-forming-gds-qnty.
run nws-impl in p-imp-handle
  ( input "price-doc-forming-gds-qnty":U
   ,input (buffer locb-price-doc-forming-gds-qnty:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "price-doc-forming-gds-sum" then do:
      create locb-price-doc-forming-gds-sum.
run nws-impl in p-imp-handle
  ( input "price-doc-forming-gds-sum":U
   ,input (buffer locb-price-doc-forming-gds-sum:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "price-doc-forming-attr" then do:
      create locb-price-doc-forming-attr.
run nws-impl in p-imp-handle
  ( input "price-doc-forming-attr":U
   ,input (buffer locb-price-doc-forming-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "price-doc-forming-gds-tnv" then do:
      create locb-price-doc-forming-gds-tnv.
run nws-impl in p-imp-handle
  ( input "price-doc-forming-gds-tnv":U
   ,input (buffer locb-price-doc-forming-gds-tnv:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_price-doc-forming-gds where buf_price-doc-forming-gds.plt-id     = wt-price-doc-forming.plt-id
                                   and buf_price-doc-forming-gds.plt-db-num = wt-price-doc-forming.plt-db-num
                                   and buf_price-doc-forming-gds.pdf-id     = wt-price-doc-forming.pdf-id
                                   and buf_price-doc-forming-gds.pdf-db     = wt-price-doc-forming.pdf-db
on error  undo, return error
:
  delete buf_price-doc-forming-gds.
end.
for each locb-price-doc-forming-gds where locb-price-doc-forming-gds.plt-id     = wt-price-doc-forming.plt-id
                                   and locb-price-doc-forming-gds.plt-db-num = wt-price-doc-forming.plt-db-num
                                   and locb-price-doc-forming-gds.pdf-id     = wt-price-doc-forming.pdf-id
                                   and locb-price-doc-forming-gds.pdf-db     = wt-price-doc-forming.pdf-db
no-lock
on error  undo, return error
:
  create buf_price-doc-forming-gds.
  buffer-copy locb-price-doc-forming-gds to buf_price-doc-forming-gds.
end.
for each buf_price-doc-forming-gds-qnty where buf_price-doc-forming-gds-qnty.plt-id     = wt-price-doc-forming.plt-id
                                   and buf_price-doc-forming-gds-qnty.plt-db-num = wt-price-doc-forming.plt-db-num
                                   and buf_price-doc-forming-gds-qnty.pdf-id     = wt-price-doc-forming.pdf-id
                                   and buf_price-doc-forming-gds-qnty.pdf-db     = wt-price-doc-forming.pdf-db
on error  undo, return error
:
  delete buf_price-doc-forming-gds-qnty.
end.
for each locb-price-doc-forming-gds-qnty where locb-price-doc-forming-gds-qnty.plt-id     = wt-price-doc-forming.plt-id
                                    and locb-price-doc-forming-gds-qnty.plt-db-num = wt-price-doc-forming.plt-db-num
                                    and locb-price-doc-forming-gds-qnty.pdf-id     = wt-price-doc-forming.pdf-id
                                    and locb-price-doc-forming-gds-qnty.pdf-db     = wt-price-doc-forming.pdf-db
no-lock
on error  undo, return error
:
  create buf_price-doc-forming-gds-qnty.
  buffer-copy locb-price-doc-forming-gds-qnty to buf_price-doc-forming-gds-qnty.
end.
for each buf_price-doc-forming-gds-sum where buf_price-doc-forming-gds-sum.plt-id     = wt-price-doc-forming.plt-id
                                   and buf_price-doc-forming-gds-sum.plt-db-num = wt-price-doc-forming.plt-db-num
                                   and buf_price-doc-forming-gds-sum.pdf-id     = wt-price-doc-forming.pdf-id
                                   and buf_price-doc-forming-gds-sum.pdf-db     = wt-price-doc-forming.pdf-db
on error  undo, return error
:
  delete buf_price-doc-forming-gds-sum.
end.
for each locb-price-doc-forming-gds-sum where locb-price-doc-forming-gds-sum.plt-id     = wt-price-doc-forming.plt-id
                                    and locb-price-doc-forming-gds-sum.plt-db-num = wt-price-doc-forming.plt-db-num
                                    and locb-price-doc-forming-gds-sum.pdf-id     = wt-price-doc-forming.pdf-id
                                    and locb-price-doc-forming-gds-sum.pdf-db     = wt-price-doc-forming.pdf-db
no-lock
on error  undo, return error
:
  create buf_price-doc-forming-gds-sum.
  buffer-copy locb-price-doc-forming-gds-sum to buf_price-doc-forming-gds-sum.
end.
for each buf_price-doc-forming-attr where buf_price-doc-forming-attr.plt-id     = wt-price-doc-forming.plt-id
                                   and buf_price-doc-forming-attr.plt-db-num = wt-price-doc-forming.plt-db-num
                                   and buf_price-doc-forming-attr.pdf-id     = wt-price-doc-forming.pdf-id
                                   and buf_price-doc-forming-attr.pdf-db     = wt-price-doc-forming.pdf-db
on error  undo, return error
:
  delete buf_price-doc-forming-attr.
end.
for each locb-price-doc-forming-attr where locb-price-doc-forming-attr.plt-id     = wt-price-doc-forming.plt-id
                                    and locb-price-doc-forming-attr.plt-db-num = wt-price-doc-forming.plt-db-num
                                    and locb-price-doc-forming-attr.pdf-id     = wt-price-doc-forming.pdf-id
                                    and locb-price-doc-forming-attr.pdf-db     = wt-price-doc-forming.pdf-db
no-lock
on error  undo, return error
:
  create buf_price-doc-forming-attr.
  buffer-copy locb-price-doc-forming-attr to buf_price-doc-forming-attr.
end.
for each buf_price-doc-forming-gds-tnv where buf_price-doc-forming-gds-tnv.plt-id     = wt-price-doc-forming.plt-id
                                   and buf_price-doc-forming-gds-tnv.plt-db-num = wt-price-doc-forming.plt-db-num
                                   and buf_price-doc-forming-gds-tnv.pdf-id     = wt-price-doc-forming.pdf-id
                                   and buf_price-doc-forming-gds-tnv.pdf-db     = wt-price-doc-forming.pdf-db
on error  undo, return error
:
  delete buf_price-doc-forming-gds-tnv.
end.
for each locb-price-doc-forming-gds-tnv where locb-price-doc-forming-gds-tnv.plt-id     = wt-price-doc-forming.plt-id
                                    and locb-price-doc-forming-gds-tnv.plt-db-num = wt-price-doc-forming.plt-db-num
                                    and locb-price-doc-forming-gds-tnv.pdf-id     = wt-price-doc-forming.pdf-id
                                    and locb-price-doc-forming-gds-tnv.pdf-db     = wt-price-doc-forming.pdf-db
no-lock
on error  undo, return error
:
  create buf_price-doc-forming-gds-tnv.
  buffer-copy locb-price-doc-forming-gds-tnv to buf_price-doc-forming-gds-tnv.
end.
if not available tb-price-doc-forming then do:
  create tb-price-doc-forming.
end.
buffer-copy wt-price-doc-forming to tb-price-doc-forming.
for each locb-price-doc-forming-gds
on error  undo, return error
:
  delete locb-price-doc-forming-gds.
end.
for each locb-price-doc-forming-gds-qnty
on error  undo, return error
:
  delete locb-price-doc-forming-gds-qnty.
end.
for each locb-price-doc-forming-gds-sum
on error  undo, return error
:
  delete locb-price-doc-forming-gds-sum.
end.
for each locb-price-doc-forming-attr
on error  undo, return error
:
  delete locb-price-doc-forming-attr.
end.
for each locb-price-doc-forming-gds-tnv
on error  undo, return error
:
  delete locb-price-doc-forming-gds-tnv.
end.
release tb-price-doc-forming.
v-send-to-cash = no.
if g#db-num > 0 then do:
define variable vss-include-info127 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run a-nwspdf in g#library2
  (input  wt-price-doc-forming.plt-id
  ,input  wt-price-doc-forming.plt-db-num
  ,input  wt-price-doc-forming.pdf-id
  ,input  wt-price-doc-forming.pdf-db
  ,output v-send-to-cash
  ) no-error .
end.
if v-send-to-cash then do:
  run fill-pdf in p-imp-handle ( input wt-price-doc-forming.plt-id
                                  ,input wt-price-doc-forming.plt-db-num
                                  ,input wt-price-doc-forming.pdf-id
                                  ,input wt-price-doc-forming.pdf-db
                                  ,input (if wt-price-doc-forming.STTS = integer('1':U) then yes else no)
                                  ).
end.
    delete wt-price-doc-forming.
  end.
END PROCEDURE.
define temp-table locb-c-price-doc-forming            no-undo like  ub.c-price-doc-forming          .
define temp-table locb-c-price-doc-forming-attr       no-undo like  ub.c-price-doc-forming-attr     .
define temp-table locb-c-price-doc-forming-gds        no-undo like  ub.c-price-doc-forming-gds      .
define temp-table lb-c-price-doc-forming-gds-qnty     no-undo like  ub.c-price-doc-forming-gds-qnty .
define temp-table locb-c-price-doc-forming-gds-sum    no-undo like  ub.c-price-doc-forming-gds-sum  .
define temp-table locb-c-price-doc-forming-gds-tnv    no-undo like  ub.c-price-doc-forming-gds-tnv  .
define temp-table wt-c-price-doc-forming no-undo like ub.c-price-doc-forming.
PROCEDURE proc-load-c-price-doc-forming:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-c-price-doc-forming. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-c-price-doc-forming. stop" )
  on endkey undo, return error substitute( "$proc-load-c-price-doc-forming. endkey" )
  :
    define buffer tb-c-price-doc-forming for ub.c-price-doc-forming.
    define variable compare-log as logical no-undo.
define variable vss-include-info128 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_c-price-doc-forming                   for ub.c-price-doc-forming          .
define buffer buf_c-price-doc-forming-attr              for ub.c-price-doc-forming-attr     .
define buffer buf_c-price-doc-forming-gds               for ub.c-price-doc-forming-gds      .
define buffer buf_c-price-doc-forming-gds-qnty          for ub.c-price-doc-forming-gds-qnty .
define buffer buf_c-price-doc-forming-gds-sum           for ub.c-price-doc-forming-gds-sum  .
define buffer buf_c-price-doc-forming-gds-tnv           for ub.c-price-doc-forming-gds-tnv  .
define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.
for each locb-c-price-doc-forming
on error  undo, return error
:
  delete locb-c-price-doc-forming.
end.
for each locb-c-price-doc-forming-gds
on error  undo, return error
:
  delete locb-c-price-doc-forming-gds.
end.
for each lb-c-price-doc-forming-gds-qnty
on error  undo, return error
:
  delete lb-c-price-doc-forming-gds-qnty.
end.
for each locb-c-price-doc-forming-gds-sum
on error  undo, return error
:
  delete locb-c-price-doc-forming-gds-sum.
end.
for each locb-c-price-doc-forming-attr
on error  undo, return error
:
  delete locb-c-price-doc-forming-attr.
 end.
for each locb-c-price-doc-forming-gds-tnv
on error  undo, return error
:
  delete locb-c-price-doc-forming-gds-tnv.
end.
    for each wt-c-price-doc-forming
    on error undo, return error substitute( "$proc-load-c-price-doc-forming(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-c-price-doc-forming .
    end.
    create wt-c-price-doc-forming.
    run nws-impl in p-imp-handle
      ( input 'c-price-doc-forming':U
       ,input (buffer wt-c-price-doc-forming:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-c-price-doc-forming
      where tb-c-price-doc-forming.plt-id = wt-c-price-doc-forming.plt-id
        and tb-c-price-doc-forming.plt-db-num = wt-c-price-doc-forming.plt-db-num
        and tb-c-price-doc-forming.pdf-id = wt-c-price-doc-forming.pdf-id
        and tb-c-price-doc-forming.pdf-db = wt-c-price-doc-forming.pdf-db
        and tb-c-price-doc-forming.corr-user-db-num = wt-c-price-doc-forming.corr-user-db-num
        and tb-c-price-doc-forming.chip-num = wt-c-price-doc-forming.chip-num
      exclusive-lock no-error.
define variable vss-include-info129 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "c-price-doc-forming-gds" then do:
      create locb-c-price-doc-forming-gds.
run nws-impl in p-imp-handle
  ( input "c-price-doc-forming-gds":U
   ,input (buffer locb-c-price-doc-forming-gds:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-price-doc-forming-gds-qnty" then do:
      create lb-c-price-doc-forming-gds-qnty.
run nws-impl in p-imp-handle
  ( input "c-price-doc-forming-gds-qnty":U
   ,input (buffer lb-c-price-doc-forming-gds-qnty:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-price-doc-forming-gds-sum" then do:
      create locb-c-price-doc-forming-gds-sum.
run nws-impl in p-imp-handle
  ( input "c-price-doc-forming-gds-sum":U
   ,input (buffer locb-c-price-doc-forming-gds-sum:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-price-doc-forming-attr" then do:
      create locb-c-price-doc-forming-attr.
run nws-impl in p-imp-handle
  ( input "c-price-doc-forming-attr":U
   ,input (buffer locb-c-price-doc-forming-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-price-doc-forming-gds-tnv" then do:
      create locb-c-price-doc-forming-gds-tnv.
run nws-impl in p-imp-handle
  ( input "c-price-doc-forming-gds-tnv":U
   ,input (buffer locb-c-price-doc-forming-gds-tnv:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_c-price-doc-forming-gds where buf_c-price-doc-forming-gds.plt-id     = wt-c-price-doc-forming.plt-id
                                   and buf_c-price-doc-forming-gds.chip-num         = wt-c-price-doc-forming.chip-num
                                   and buf_c-price-doc-forming-gds.corr-user-db-num = wt-c-price-doc-forming.corr-user-db-num
                                   and buf_c-price-doc-forming-gds.plt-db-num = wt-c-price-doc-forming.plt-db-num
                                   and buf_c-price-doc-forming-gds.pdf-id     = wt-c-price-doc-forming.pdf-id
                                   and buf_c-price-doc-forming-gds.pdf-db     = wt-c-price-doc-forming.pdf-db
on error  undo, return error
:
  delete buf_c-price-doc-forming-gds.
end.
for each locb-c-price-doc-forming-gds where locb-c-price-doc-forming-gds.plt-id = wt-c-price-doc-forming.plt-id
                                    and locb-c-price-doc-forming-gds.plt-db-num = wt-c-price-doc-forming.plt-db-num
                                    and locb-c-price-doc-forming-gds.pdf-id     = wt-c-price-doc-forming.pdf-id
                                    and locb-c-price-doc-forming-gds.pdf-db     = wt-c-price-doc-forming.pdf-db
                                    and locb-c-price-doc-forming-gds.chip-num         = wt-c-price-doc-forming.chip-num
                                    and locb-c-price-doc-forming-gds.corr-user-db-num = wt-c-price-doc-forming.corr-user-db-num
no-lock
on error  undo, return error
:
  create buf_c-price-doc-forming-gds.
  buffer-copy locb-c-price-doc-forming-gds to buf_c-price-doc-forming-gds.
end.
for each buf_c-price-doc-forming-gds-qnty where buf_c-price-doc-forming-gds-qnty.plt-id     = wt-c-price-doc-forming.plt-id
                                   and buf_c-price-doc-forming-gds-qnty.plt-db-num = wt-c-price-doc-forming.plt-db-num
                                   and buf_c-price-doc-forming-gds-qnty.pdf-id     = wt-c-price-doc-forming.pdf-id
                                   and buf_c-price-doc-forming-gds-qnty.pdf-db     = wt-c-price-doc-forming.pdf-db
                                   and buf_c-price-doc-forming-gds-qnty.chip-num         = wt-c-price-doc-forming.chip-num
                                   and buf_c-price-doc-forming-gds-qnty.corr-user-db-num = wt-c-price-doc-forming.corr-user-db-num
on error  undo, return error
:
  delete buf_c-price-doc-forming-gds-qnty.
end.
for each lb-c-price-doc-forming-gds-qnty where lb-c-price-doc-forming-gds-qnty.plt-id = wt-c-price-doc-forming.plt-id
                                   and lb-c-price-doc-forming-gds-qnty.plt-db-num = wt-c-price-doc-forming.plt-db-num
                                   and lb-c-price-doc-forming-gds-qnty.pdf-id     = wt-c-price-doc-forming.pdf-id
                                   and lb-c-price-doc-forming-gds-qnty.pdf-db     = wt-c-price-doc-forming.pdf-db
                                   and lb-c-price-doc-forming-gds-qnty.chip-num         = wt-c-price-doc-forming.chip-num
                                   and lb-c-price-doc-forming-gds-qnty.corr-user-db-num = wt-c-price-doc-forming.corr-user-db-num
no-lock
on error  undo, return error
:
  create buf_c-price-doc-forming-gds-qnty.
  buffer-copy lb-c-price-doc-forming-gds-qnty to buf_c-price-doc-forming-gds-qnty.
end.
for each buf_c-price-doc-forming-gds-sum where
                                       buf_c-price-doc-forming-gds-sum.plt-id     = wt-c-price-doc-forming.plt-id
                                   and buf_c-price-doc-forming-gds-sum.plt-db-num = wt-c-price-doc-forming.plt-db-num
                                   and buf_c-price-doc-forming-gds-sum.pdf-id     = wt-c-price-doc-forming.pdf-id
                                   and buf_c-price-doc-forming-gds-sum.pdf-db     = wt-c-price-doc-forming.pdf-db
                                   and buf_c-price-doc-forming-gds-sum.chip-num         = wt-c-price-doc-forming.chip-num
                                   and buf_c-price-doc-forming-gds-sum.corr-user-db-num = wt-c-price-doc-forming.corr-user-db-num
on error  undo, return error
:
  delete buf_c-price-doc-forming-gds-sum.
end.
for each locb-c-price-doc-forming-gds-sum where locb-c-price-doc-forming-gds-sum.plt-id = wt-c-price-doc-forming.plt-id
                                    and locb-c-price-doc-forming-gds-sum.plt-db-num = wt-c-price-doc-forming.plt-db-num
                                    and locb-c-price-doc-forming-gds-sum.pdf-id     = wt-c-price-doc-forming.pdf-id
                                    and locb-c-price-doc-forming-gds-sum.pdf-db     = wt-c-price-doc-forming.pdf-db
                                    and locb-c-price-doc-forming-gds-sum.chip-num         = wt-c-price-doc-forming.chip-num
                                    and locb-c-price-doc-forming-gds-sum.corr-user-db-num = wt-c-price-doc-forming.corr-user-db-num
no-lock
on error  undo, return error
:
  create buf_c-price-doc-forming-gds-sum.
  buffer-copy locb-c-price-doc-forming-gds-sum to buf_c-price-doc-forming-gds-sum.
end.
for each buf_c-price-doc-forming-attr where buf_c-price-doc-forming-attr.plt-id     = wt-c-price-doc-forming.plt-id
                                  and buf_c-price-doc-forming-attr.plt-db-num = wt-c-price-doc-forming.plt-db-num
                                  and buf_c-price-doc-forming-attr.pdf-id     = wt-c-price-doc-forming.pdf-id
                                  and buf_c-price-doc-forming-attr.pdf-db     = wt-c-price-doc-forming.pdf-db
                                  and buf_c-price-doc-forming-attr.chip-num         = wt-c-price-doc-forming.chip-num
                                  and buf_c-price-doc-forming-attr.corr-user-db-num = wt-c-price-doc-forming.corr-user-db-num
on error  undo, return error
:
  delete buf_c-price-doc-forming-attr.
end.
for each locb-c-price-doc-forming-attr where locb-c-price-doc-forming-attr.plt-id = wt-c-price-doc-forming.plt-id
                                    and locb-c-price-doc-forming-attr.plt-db-num = wt-c-price-doc-forming.plt-db-num
                                    and locb-c-price-doc-forming-attr.pdf-id     = wt-c-price-doc-forming.pdf-id
                                    and locb-c-price-doc-forming-attr.pdf-db     = wt-c-price-doc-forming.pdf-db
                                    and locb-c-price-doc-forming-attr.chip-num         = wt-c-price-doc-forming.chip-num
                                    and locb-c-price-doc-forming-attr.corr-user-db-num = wt-c-price-doc-forming.corr-user-db-num
no-lock
on error  undo, return error
:
  create buf_c-price-doc-forming-attr.
  buffer-copy locb-c-price-doc-forming-attr to buf_c-price-doc-forming-attr.
end.
for each buf_c-price-doc-forming-gds-tnv where buf_c-price-doc-forming-gds-tnv.plt-id = wt-c-price-doc-forming.plt-id
                                      and buf_c-price-doc-forming-gds-tnv.plt-db-num = wt-c-price-doc-forming.plt-db-num
                                      and buf_c-price-doc-forming-gds-tnv.pdf-id     = wt-c-price-doc-forming.pdf-id
                                      and buf_c-price-doc-forming-gds-tnv.pdf-db     = wt-c-price-doc-forming.pdf-db
                                      and buf_c-price-doc-forming-gds-tnv.chip-num         = wt-c-price-doc-forming.chip-num
                                      and buf_c-price-doc-forming-gds-tnv.corr-user-db-num = wt-c-price-doc-forming.corr-user-db-num
on error  undo, return error
:
  delete buf_c-price-doc-forming-gds-tnv.
end.
for each locb-c-price-doc-forming-gds-tnv where locb-c-price-doc-forming-gds-tnv.plt-id = wt-c-price-doc-forming.plt-id
                                    and locb-c-price-doc-forming-gds-tnv.plt-db-num = wt-c-price-doc-forming.plt-db-num
                                    and locb-c-price-doc-forming-gds-tnv.pdf-id     = wt-c-price-doc-forming.pdf-id
                                    and locb-c-price-doc-forming-gds-tnv.pdf-db     = wt-c-price-doc-forming.pdf-db
                                    and locb-c-price-doc-forming-gds-tnv.chip-num         = wt-c-price-doc-forming.chip-num
                                    and locb-c-price-doc-forming-gds-tnv.corr-user-db-num = wt-c-price-doc-forming.corr-user-db-num
no-lock
on error  undo, return error
:
  create buf_c-price-doc-forming-gds-tnv.
  buffer-copy locb-c-price-doc-forming-gds-tnv to buf_c-price-doc-forming-gds-tnv.
end.
if not available tb-c-price-doc-forming then do:
  create tb-c-price-doc-forming.
end.
buffer-copy wt-c-price-doc-forming to tb-c-price-doc-forming.
for each locb-c-price-doc-forming-gds
on error  undo, return error
:
  delete locb-c-price-doc-forming-gds.
end.
for each lb-c-price-doc-forming-gds-qnty
on error  undo, return error
:
  delete lb-c-price-doc-forming-gds-qnty.
end.
for each locb-c-price-doc-forming-gds-sum
on error  undo, return error
:
  delete locb-c-price-doc-forming-gds-sum.
end.
for each locb-c-price-doc-forming-attr
on error  undo, return error
:
  delete locb-c-price-doc-forming-attr.
end.
for each locb-c-price-doc-forming-gds-tnv
on error  undo, return error
:
  delete locb-c-price-doc-forming-gds-tnv.
end.
    delete wt-c-price-doc-forming.
  end.
END PROCEDURE.
define temp-table locb-price-list-type                no-undo like   ub.price-list-type               .
define temp-table locb-price-list-type-pay-type       no-undo like   ub.price-list-type-pay-type      .
define temp-table locb-price-list-type-cassa          no-undo like   ub.price-list-type-cassa         .
define temp-table locb-price-list-type-gds-grp        no-undo like   ub.price-list-type-gds-grp       .
define temp-table locb-price-list-type-attr           no-undo like   ub.price-list-type-attr          .
define temp-table locb-price-list-type-cash-pay       no-undo like   ub.price-list-type-cash-pay      .
define temp-table wt-price-list-type no-undo like ub.price-list-type.
PROCEDURE proc-load-price-list-type:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-price-list-type. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-price-list-type. stop" )
  on endkey undo, return error substitute( "$proc-load-price-list-type. endkey" )
  :
    define buffer tb-price-list-type for ub.price-list-type.
    define variable compare-log as logical no-undo.
define variable vss-include-info130 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_price-list-type                 for ub.price-list-type               .
define buffer buf_price-list-type-pay-type        for ub.price-list-type-pay-type      .
define buffer buf_price-list-type-cassa           for ub.price-list-type-cassa         .
define buffer buf_price-list-type-gds-grp         for ub.price-list-type-gds-grp       .
define buffer buf_price-list-type-attr            for ub.price-list-type-attr          .
define buffer buf_price-list-type-cash-pay        for ub.price-list-type-cash-pay      .
define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.
for each locb-price-list-type
on error  undo, return error
:
  delete locb-price-list-type.
end.
for each locb-price-list-type-pay-type
on error  undo, return error
:
  delete locb-price-list-type-pay-type.
end.
for each locb-price-list-type-cassa
on error  undo, return error
:
  delete locb-price-list-type-cassa.
end.
for each locb-price-list-type-gds-grp
on error  undo, return error
:
  delete locb-price-list-type-gds-grp.
end.
for each locb-price-list-type-attr
on error  undo, return error
:
  delete locb-price-list-type-attr.
end.
for each locb-price-list-type-cash-pay
on error  undo, return error
:
  delete locb-price-list-type-cash-pay.
end.
    for each wt-price-list-type
    on error undo, return error substitute( "$proc-load-price-list-type(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-price-list-type .
    end.
    create wt-price-list-type.
    run nws-impl in p-imp-handle
      ( input 'price-list-type':U
       ,input (buffer wt-price-list-type:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-price-list-type
      where tb-price-list-type.plt-id = wt-price-list-type.plt-id
        and tb-price-list-type.plt-db-num = wt-price-list-type.plt-db-num
      exclusive-lock no-error.
define variable vss-include-info131 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "price-list-type-pay-type" then do:
      create locb-price-list-type-pay-type.
run nws-impl in p-imp-handle
  ( input "price-list-type-pay-type":U
   ,input (buffer locb-price-list-type-pay-type:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "price-list-type-cassa" then do:
      create locb-price-list-type-cassa.
run nws-impl in p-imp-handle
  ( input "price-list-type-cassa":U
   ,input (buffer locb-price-list-type-cassa:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "price-list-type-gds-grp" then do:
      create locb-price-list-type-gds-grp.
run nws-impl in p-imp-handle
  ( input "price-list-type-gds-grp":U
   ,input (buffer locb-price-list-type-gds-grp:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "price-list-type-attr" then do:
      create locb-price-list-type-attr.
run nws-impl in p-imp-handle
  ( input "price-list-type-attr":U
   ,input (buffer locb-price-list-type-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "price-list-type-cash-pay" then do:
      create locb-price-list-type-cash-pay.
run nws-impl in p-imp-handle
  ( input "price-list-type-cash-pay":U
   ,input (buffer locb-price-list-type-cash-pay:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_price-list-type-pay-type where buf_price-list-type-pay-type.plt-id     = wt-price-list-type.plt-id
                                  and buf_price-list-type-pay-type.plt-db-num = wt-price-list-type.plt-db-num
on error  undo, return error
:
  delete buf_price-list-type-pay-type.
end.
for each locb-price-list-type-pay-type where locb-price-list-type-pay-type.plt-id     = wt-price-list-type.plt-id
                                    and locb-price-list-type-pay-type.plt-db-num = wt-price-list-type.plt-db-num
no-lock
on error  undo, return error
:
  create buf_price-list-type-pay-type.
  buffer-copy locb-price-list-type-pay-type to buf_price-list-type-pay-type.
end.
for each buf_price-list-type-cassa where buf_price-list-type-cassa.plt-id     = wt-price-list-type.plt-id
                                  and buf_price-list-type-cassa.plt-db-num = wt-price-list-type.plt-db-num
on error  undo, return error
:
  delete buf_price-list-type-cassa.
end.
for each locb-price-list-type-cassa where locb-price-list-type-cassa.plt-id     = wt-price-list-type.plt-id
                                    and locb-price-list-type-cassa.plt-db-num = wt-price-list-type.plt-db-num
no-lock
on error  undo, return error
:
  create buf_price-list-type-cassa.
  buffer-copy locb-price-list-type-cassa to buf_price-list-type-cassa.
end.
for each buf_price-list-type-gds-grp where buf_price-list-type-gds-grp.plt-id     = wt-price-list-type.plt-id
                                  and buf_price-list-type-gds-grp.plt-db-num = wt-price-list-type.plt-db-num
on error  undo, return error
:
  delete buf_price-list-type-gds-grp.
end.
for each locb-price-list-type-gds-grp where locb-price-list-type-gds-grp.plt-id     = wt-price-list-type.plt-id
                                    and locb-price-list-type-gds-grp.plt-db-num = wt-price-list-type.plt-db-num
no-lock
on error  undo, return error
:
  create buf_price-list-type-gds-grp.
  buffer-copy locb-price-list-type-gds-grp to buf_price-list-type-gds-grp.
end.
for each buf_price-list-type-attr where buf_price-list-type-attr.plt-id     = wt-price-list-type.plt-id
                                  and buf_price-list-type-attr.plt-db-num = wt-price-list-type.plt-db-num
on error  undo, return error
:
  delete buf_price-list-type-attr.
end.
for each locb-price-list-type-attr where locb-price-list-type-attr.plt-id     = wt-price-list-type.plt-id
                                    and locb-price-list-type-attr.plt-db-num = wt-price-list-type.plt-db-num
no-lock
on error  undo, return error
:
  create buf_price-list-type-attr.
  buffer-copy locb-price-list-type-attr to buf_price-list-type-attr.
end.
for each buf_price-list-type-cash-pay where buf_price-list-type-cash-pay.plt-id     = wt-price-list-type.plt-id
                                  and buf_price-list-type-cash-pay.plt-db-num = wt-price-list-type.plt-db-num
on error  undo, return error
:
  delete buf_price-list-type-cash-pay.
end.
for each locb-price-list-type-cash-pay where locb-price-list-type-cash-pay.plt-id     = wt-price-list-type.plt-id
                                    and locb-price-list-type-cash-pay.plt-db-num = wt-price-list-type.plt-db-num
no-lock
on error  undo, return error
:
  create buf_price-list-type-cash-pay.
  buffer-copy locb-price-list-type-cash-pay to buf_price-list-type-cash-pay.
end.
if not available tb-price-list-type then do:
  create tb-price-list-type.
end.
buffer-copy wt-price-list-type to tb-price-list-type.
run trg/bp_tpl.p (tb-price-list-type.plt-id ,tb-price-list-type.plt-db-num ) no-error.
for each locb-price-list-type-pay-type
on error  undo, return error
:
  delete locb-price-list-type-pay-type.
end.
for each locb-price-list-type-cassa
on error  undo, return error
:
  delete locb-price-list-type-cassa.
end.
for each locb-price-list-type-gds-grp
on error  undo, return error
:
  delete locb-price-list-type-gds-grp.
end.
for each locb-price-list-type-attr
on error  undo, return error
:
  delete locb-price-list-type-attr.
end.
for each locb-price-list-type-cash-pay
on error  undo, return error
:
  delete locb-price-list-type-cash-pay.
end.
    delete wt-price-list-type.
  end.
END PROCEDURE.
define temp-table locb-c-price-list-type              no-undo like   ub.c-price-list-type             .
define temp-table locb-c-price-list-type-pay-type     no-undo like   ub.c-price-list-type-pay-type    .
define temp-table locb-c-price-list-type-cassa        no-undo like   ub.c-price-list-type-cassa       .
define temp-table locb-c-price-list-type-gds-grp      no-undo like   ub.c-price-list-type-gds-grp     .
define temp-table locb-c-price-list-type-attr         no-undo like   ub.c-price-list-type-attr        .
define temp-table locb-c-price-list-type-cash-pay     no-undo like   ub.c-price-list-type-cash-pay    .
define temp-table wt-c-price-list-type no-undo like ub.c-price-list-type.
PROCEDURE proc-load-c-price-list-type:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-c-price-list-type. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-c-price-list-type. stop" )
  on endkey undo, return error substitute( "$proc-load-c-price-list-type. endkey" )
  :
    define buffer tb-c-price-list-type for ub.c-price-list-type.
    define variable compare-log as logical no-undo.
define variable vss-include-info132 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_c-price-list-type               for ub.c-price-list-type             .
define buffer buf_c-price-list-type-pay-type      for ub.c-price-list-type-pay-type    .
define buffer buf_c-price-list-type-cassa         for ub.c-price-list-type-cassa       .
define buffer buf_c-price-list-type-gds-grp       for ub.c-price-list-type-gds-grp     .
define buffer buf_c-price-list-type-attr          for ub.c-price-list-type-attr        .
define buffer buf_c-price-list-type-cash-pay      for ub.c-price-list-type-cash-pay    .
define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.
for each locb-c-price-list
on error  undo, return error
:
  delete locb-c-price-list.
end.
for each locb-c-price-list-type-pay-type
on error  undo, return error
:
  delete locb-c-price-list-type-pay-type.
end.
for each locb-c-price-list-type-cassa
on error  undo, return error
:
  delete locb-c-price-list-type-cassa.
end.
for each locb-c-price-list-type-gds-grp
on error  undo, return error
:
  delete locb-c-price-list-type-gds-grp.
end.
for each locb-c-price-list-type-attr
on error  undo, return error
:
  delete locb-c-price-list-type-attr.
end.
for each locb-c-price-list-type-cash-pay
on error  undo, return error
:
  delete locb-c-price-list-type-cash-pay.
end.
    for each wt-c-price-list-type
    on error undo, return error substitute( "$proc-load-c-price-list-type(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-c-price-list-type .
    end.
    create wt-c-price-list-type.
    run nws-impl in p-imp-handle
      ( input 'c-price-list-type':U
       ,input (buffer wt-c-price-list-type:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-c-price-list-type
      where tb-c-price-list-type.plt-id = wt-c-price-list-type.plt-id
        and tb-c-price-list-type.plt-db-num = wt-c-price-list-type.plt-db-num
        and tb-c-price-list-type.corr-user-db-num = wt-c-price-list-type.corr-user-db-num
        and tb-c-price-list-type.chip-num = wt-c-price-list-type.chip-num
      exclusive-lock no-error.
define variable vss-include-info133 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "c-price-list-type-pay-type" then do:
      create locb-c-price-list-type-pay-type.
run nws-impl in p-imp-handle
  ( input "c-price-list-type-pay-type":U
   ,input (buffer locb-c-price-list-type-pay-type:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-price-list-type-cassa" then do:
      create locb-c-price-list-type-cassa.
run nws-impl in p-imp-handle
  ( input "c-price-list-type-cassa":U
   ,input (buffer locb-c-price-list-type-cassa:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-price-list-type-gds-grp" then do:
      create locb-c-price-list-type-gds-grp.
run nws-impl in p-imp-handle
  ( input "c-price-list-type-gds-grp":U
   ,input (buffer locb-c-price-list-type-gds-grp:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-price-list-type-attr" then do:
      create locb-c-price-list-type-attr.
run nws-impl in p-imp-handle
  ( input "c-price-list-type-attr":U
   ,input (buffer locb-c-price-list-type-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-price-list-type-cash-pay" then do:
      create locb-c-price-list-type-cash-pay.
run nws-impl in p-imp-handle
  ( input "c-price-list-type-cash-pay":U
   ,input (buffer locb-c-price-list-type-cash-pay:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_c-price-list-type-pay-type where buf_c-price-list-type-pay-type.plt-id     = wt-c-price-list-type.plt-id
                                  and buf_c-price-list-type-pay-type.plt-db-num = wt-c-price-list-type.plt-db-num
                                  and buf_c-price-list-type-pay-type.chip-num         = wt-c-price-list-type.chip-num
                                  and buf_c-price-list-type-pay-type.corr-user-db-num = wt-c-price-list-type.corr-user-db-num
on error  undo, return error
:
  delete buf_c-price-list-type-pay-type.
end.
for each locb-c-price-list-type-pay-type where locb-c-price-list-type-pay-type.plt-id = wt-c-price-list-type.plt-id
                                    and locb-c-price-list-type-pay-type.plt-db-num = wt-c-price-list-type.plt-db-num
                                    and locb-c-price-list-type-pay-type.chip-num         = wt-c-price-list-type.chip-num
                                    and locb-c-price-list-type-pay-type.corr-user-db-num = wt-c-price-list-type.corr-user-db-num
no-lock
on error  undo, return error
:
  create buf_c-price-list-type-pay-type.
  buffer-copy locb-c-price-list-type-pay-type to buf_c-price-list-type-pay-type.
end.
for each buf_c-price-list-type-cassa where buf_c-price-list-type-cassa.plt-id     = wt-c-price-list-type.plt-id
                                  and buf_c-price-list-type-cassa.plt-db-num = wt-c-price-list-type.plt-db-num
                                  and buf_c-price-list-type-cassa.chip-num         = wt-c-price-list-type.chip-num
                                  and buf_c-price-list-type-cassa.corr-user-db-num = wt-c-price-list-type.corr-user-db-num
on error  undo, return error
:
  delete buf_c-price-list-type-cassa.
end.
for each locb-c-price-list-type-cassa where locb-c-price-list-type-cassa.plt-id = wt-c-price-list-type.plt-id
                                    and locb-c-price-list-type-cassa.plt-db-num = wt-c-price-list-type.plt-db-num
                                    and locb-c-price-list-type-cassa.chip-num         = wt-c-price-list-type.chip-num
                                    and locb-c-price-list-type-cassa.corr-user-db-num = wt-c-price-list-type.corr-user-db-num
no-lock
on error  undo, return error
:
  create buf_c-price-list-type-cassa.
  buffer-copy locb-c-price-list-type-cassa to buf_c-price-list-type-cassa.
end.
for each buf_c-price-list-type-gds-grp where buf_c-price-list-type-gds-grp.plt-id     = wt-c-price-list-type.plt-id
                                  and buf_c-price-list-type-gds-grp.plt-db-num = wt-c-price-list-type.plt-db-num
                                  and buf_c-price-list-type-gds-grp.chip-num         = wt-c-price-list-type.chip-num
                                  and buf_c-price-list-type-gds-grp.corr-user-db-num = wt-c-price-list-type.corr-user-db-num
on error  undo, return error
:
  delete buf_c-price-list-type-gds-grp.
end.
for each locb-c-price-list-type-gds-grp where locb-c-price-list-type-gds-grp.plt-id = wt-c-price-list-type.plt-id
                                    and locb-c-price-list-type-gds-grp.plt-db-num = wt-c-price-list-type.plt-db-num
                                    and locb-c-price-list-type-gds-grp.chip-num         = wt-c-price-list-type.chip-num
                                    and locb-c-price-list-type-gds-grp.corr-user-db-num = wt-c-price-list-type.corr-user-db-num
no-lock
on error  undo, return error
:
  create buf_c-price-list-type-gds-grp.
  buffer-copy locb-c-price-list-type-gds-grp to buf_c-price-list-type-gds-grp.
end.
for each buf_c-price-list-type-attr where buf_c-price-list-type-attr.plt-id     = wt-c-price-list-type.plt-id
                                  and buf_c-price-list-type-attr.plt-db-num = wt-c-price-list-type.plt-db-num
                                  and buf_c-price-list-type-attr.chip-num         = wt-c-price-list-type.chip-num
                                  and buf_c-price-list-type-attr.corr-user-db-num = wt-c-price-list-type.corr-user-db-num
on error  undo, return error
:
  delete buf_c-price-list-type-attr.
end.
for each locb-c-price-list-type-attr where locb-c-price-list-type-attr.plt-id = wt-c-price-list-type.plt-id
                                    and locb-c-price-list-type-attr.plt-db-num = wt-c-price-list-type.plt-db-num
                                    and locb-c-price-list-type-attr.chip-num         = wt-c-price-list-type.chip-num
                                    and locb-c-price-list-type-attr.corr-user-db-num = wt-c-price-list-type.corr-user-db-num
no-lock
on error  undo, return error
:
  create buf_c-price-list-type-attr.
  buffer-copy locb-c-price-list-type-attr to buf_c-price-list-type-attr.
end.
for each buf_c-price-list-type-cash-pay where buf_c-price-list-type-cash-pay.plt-id     = wt-c-price-list-type.plt-id
                                  and buf_c-price-list-type-cash-pay.plt-db-num = wt-c-price-list-type.plt-db-num
                                  and buf_c-price-list-type-cash-pay.chip-num         = wt-c-price-list-type.chip-num
                                  and buf_c-price-list-type-cash-pay.corr-user-db-num = wt-c-price-list-type.corr-user-db-num
on error  undo, return error
:
  delete buf_c-price-list-type-cash-pay.
end.
for each locb-c-price-list-type-cash-pay where locb-c-price-list-type-cash-pay.plt-id = wt-c-price-list-type.plt-id
                                    and locb-c-price-list-type-cash-pay.plt-db-num = wt-c-price-list-type.plt-db-num
                                    and locb-c-price-list-type-cash-pay.chip-num         = wt-c-price-list-type.chip-num
                                    and locb-c-price-list-type-cash-pay.corr-user-db-num = wt-c-price-list-type.corr-user-db-num
no-lock
on error  undo, return error
:
  create buf_c-price-list-type-cash-pay.
  buffer-copy locb-c-price-list-type-cash-pay to buf_c-price-list-type-cash-pay.
end.
if not available tb-c-price-list-type then do:
  create tb-c-price-list-type.
end.
buffer-copy wt-c-price-list-type to tb-c-price-list-type.
for each locb-c-price-list-type-pay-type
on error  undo, return error
:
  delete locb-c-price-list-type-pay-type.
end.
for each locb-c-price-list-type-cassa
on error  undo, return error
:
  delete locb-c-price-list-type-cassa.
end.
for each locb-c-price-list-type-gds-grp
on error  undo, return error
:
  delete locb-c-price-list-type-gds-grp.
end.
for each locb-c-price-list-type-attr
on error  undo, return error
:
  delete locb-c-price-list-type-attr.
end.
for each locb-c-price-list-type-cash-pay
on error  undo, return error
:
  delete locb-c-price-list-type-cash-pay.
end.
    delete wt-c-price-list-type.
  end.
END PROCEDURE.
define temp-table wt-prod-bc no-undo like ub.prod-bc.
PROCEDURE proc-load-prod-bc:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-prod-bc. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-prod-bc. stop" )
  on endkey undo, return error substitute( "$proc-load-prod-bc. endkey" )
  :
    define buffer tb-prod-bc for ub.prod-bc.
    define variable compare-log as logical no-undo.
    for each wt-prod-bc
    on error undo, return error substitute( "$proc-load-prod-bc(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-prod-bc .
    end.
    create wt-prod-bc.
    run nws-impl in p-imp-handle
      ( input 'prod-bc':U
       ,input (buffer wt-prod-bc:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-prod-bc
      where tb-prod-bc.b-code = wt-prod-bc.b-code
        and tb-prod-bc.b-str = wt-prod-bc.b-str
      exclusive-lock no-error.
define variable vss-include-info134 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run check-avail-b-code in p-imp-handle
  ( input-output wt-prod-bc.b-code
  ).
run create-prod-bc in p-imp-handle
  ( input wt-prod-bc.b-code, input wt-prod-bc.b-str, input wt-prod-bc.bc-on, input wt-prod-bc.cr-db-num, input wt-prod-bc.bc-on-type
  ).
    delete wt-prod-bc.
  end.
END PROCEDURE.
define temp-table locb-qnty-group            no-undo like  ub.qnty-group.
define temp-table locb-qnty-in-qnty-group    no-undo like  ub.qnty-in-qnty-group.
define temp-table locb-c-qnty-group          no-undo like  ub.c-qnty-group.
define temp-table locb-c-qnty-in-qnty-group  no-undo like  ub.c-qnty-in-qnty-group.
define temp-table wt-qnty-group no-undo like ub.qnty-group.
PROCEDURE proc-load-qnty-group:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-qnty-group. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-qnty-group. stop" )
  on endkey undo, return error substitute( "$proc-load-qnty-group. endkey" )
  :
    define buffer tb-qnty-group for ub.qnty-group.
    define variable compare-log as logical no-undo.
define variable vss-include-info135 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_qnty-group          for ub.qnty-group.
define buffer buf_qnty-in-qnty-group   for ub.qnty-in-qnty-group.
define buffer buf_c-qnty-group        for ub.c-qnty-group.
define buffer buf_c-qnty-in-qnty-group for ub.c-qnty-in-qnty-group.
define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.
for each locb-qnty-group
on error  undo, return error
:
  delete locb-qnty-group.
end.
for each locb-c-qnty-group
on error  undo, return error
:
  delete locb-c-qnty-group.
end.
for each locb-qnty-in-qnty-group
on error  undo, return error
:
  delete locb-qnty-in-qnty-group.
end.
for each locb-c-qnty-in-qnty-group
on error  undo, return error
:
  delete locb-c-qnty-in-qnty-group.
end.
    for each wt-qnty-group
    on error undo, return error substitute( "$proc-load-qnty-group(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-qnty-group .
    end.
    create wt-qnty-group.
    run nws-impl in p-imp-handle
      ( input 'qnty-group':U
       ,input (buffer wt-qnty-group:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-qnty-group
      where tb-qnty-group.qgr-id = wt-qnty-group.qgr-id
        and tb-qnty-group.qgr-db-num = wt-qnty-group.qgr-db-num
      exclusive-lock no-error.
define variable vss-include-info136 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "qnty-in-qnty-group" then do:
      create locb-qnty-in-qnty-group.
run nws-impl in p-imp-handle
  ( input "qnty-in-qnty-group":U
   ,input (buffer locb-qnty-in-qnty-group:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-qnty-group" then do:
      create locb-c-qnty-group.
run nws-impl in p-imp-handle
  ( input "c-qnty-group":U
   ,input (buffer locb-c-qnty-group:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-qnty-in-qnty-group" then do:
      create locb-c-qnty-in-qnty-group.
run nws-impl in p-imp-handle
  ( input "c-qnty-in-qnty-group":U
   ,input (buffer locb-c-qnty-in-qnty-group:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_c-qnty-group where buf_c-qnty-group.qgr-id = wt-qnty-group.qgr-id
                            and buf_c-qnty-group.qgr-db-num = wt-qnty-group.qgr-db-num
on error  undo, return error
:
  delete buf_c-qnty-group.
end.
for each locb-c-qnty-group where locb-c-qnty-group.qgr-id     = wt-qnty-group.qgr-id
                             and locb-c-qnty-group.qgr-db-num = wt-qnty-group.qgr-db-num
  no-lock
on error  undo, return error
:
  create buf_c-qnty-group.
  buffer-copy  locb-c-qnty-group to buf_c-qnty-group.
end.
for each buf_qnty-in-qnty-group where buf_qnty-in-qnty-group.qgr-id     = wt-qnty-group.qgr-id
                                  and buf_qnty-in-qnty-group.qgr-db-num = wt-qnty-group.qgr-db-num
on error  undo, return error
:
  delete buf_qnty-in-qnty-group.
end.
for each locb-qnty-in-qnty-group where locb-qnty-in-qnty-group.qgr-id     = wt-qnty-group.qgr-id
                                    and locb-qnty-in-qnty-group.qgr-db-num = wt-qnty-group.qgr-db-num
no-lock
on error  undo, return error
:
  create buf_qnty-in-qnty-group.
  buffer-copy locb-qnty-in-qnty-group to buf_qnty-in-qnty-group.
end.
for each buf_c-qnty-in-qnty-group where buf_c-qnty-in-qnty-group.qgr-id     = wt-qnty-group.qgr-id
                                  and buf_c-qnty-in-qnty-group.qgr-db-num = wt-qnty-group.qgr-db-num
on error  undo, return error
:
  delete buf_c-qnty-in-qnty-group.
end.
for each locb-c-qnty-in-qnty-group where locb-c-qnty-in-qnty-group.qgr-id = wt-qnty-group.qgr-id
                                    and locb-c-qnty-in-qnty-group.qgr-db-num = wt-qnty-group.qgr-db-num
no-lock
on error  undo, return error
:
  create buf_c-qnty-in-qnty-group.
  buffer-copy locb-c-qnty-in-qnty-group to buf_c-qnty-in-qnty-group.
end.
if not available tb-qnty-group then do:
  create tb-qnty-group.
end.
buffer-copy wt-qnty-group to tb-qnty-group.
for each locb-c-qnty-group
on error  undo, return error
:
  delete locb-c-qnty-group.
end.
for each locb-qnty-in-qnty-group
on error  undo, return error
:
  delete locb-qnty-in-qnty-group.
end.
for each locb-c-qnty-in-qnty-group
on error  undo, return error
:
  delete locb-c-qnty-in-qnty-group.
end.
    delete wt-qnty-group.
  end.
END PROCEDURE.
define temp-table locb-rang-abc-def-obj   no-undo like  ub.rang-abc-def-obj  .
define temp-table wt-rang-abc-def no-undo like ub.rang-abc-def.
PROCEDURE proc-load-rang-abc-def:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-rang-abc-def. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-rang-abc-def. stop" )
  on endkey undo, return error substitute( "$proc-load-rang-abc-def. endkey" )
  :
    define buffer tb-rang-abc-def for ub.rang-abc-def.
    define variable compare-log as logical no-undo.
define variable vss-include-info137 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_rang-abc-def-obj for ub.rang-abc-def-obj  .
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-rang-abc-def-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-rang-abc-def-obj.
end.
    for each wt-rang-abc-def
    on error undo, return error substitute( "$proc-load-rang-abc-def(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-rang-abc-def .
    end.
    create wt-rang-abc-def.
    run nws-impl in p-imp-handle
      ( input 'rang-abc-def':U
       ,input (buffer wt-rang-abc-def:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-rang-abc-def
      where tb-rang-abc-def.raad-id = wt-rang-abc-def.raad-id
        and tb-rang-abc-def.db-num = wt-rang-abc-def.db-num
      exclusive-lock no-error.
define variable vss-include-info138 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "rang-abc-def-obj" then do:
      create locb-rang-abc-def-obj.
run nws-impl in p-imp-handle
  ( input "rang-abc-def-obj":U
   ,input (buffer locb-rang-abc-def-obj:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе abc-анализа."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_rang-abc-def-obj where
         buf_rang-abc-def-obj.raad-id   = wt-rang-abc-def.raad-id  and
         buf_rang-abc-def-obj.db-num    = wt-rang-abc-def.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_rang-abc-def-obj.
end.
for each locb-rang-abc-def-obj where
         locb-rang-abc-def-obj.raad-id = wt-rang-abc-def.raad-id and
         locb-rang-abc-def-obj.db-num  = wt-rang-abc-def.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_rang-abc-def-obj.
  buffer-copy locb-rang-abc-def-obj to buf_rang-abc-def-obj.
end.
if not available tb-rang-abc-def then do:
  create tb-rang-abc-def.
end.
buffer-copy wt-rang-abc-def to tb-rang-abc-def.
for each locb-rang-abc-def-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-rang-abc-def-obj.
end.
    delete wt-rang-abc-def.
  end.
END PROCEDURE.
define temp-table locb-rang-xyz-def-obj   no-undo like  ub.rang-xyz-def-obj  .
define temp-table wt-rang-xyz-def no-undo like ub.rang-xyz-def.
PROCEDURE proc-load-rang-xyz-def:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-rang-xyz-def. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-rang-xyz-def. stop" )
  on endkey undo, return error substitute( "$proc-load-rang-xyz-def. endkey" )
  :
    define buffer tb-rang-xyz-def for ub.rang-xyz-def.
    define variable compare-log as logical no-undo.
define variable vss-include-info139 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_rang-xyz-def-obj for ub.rang-xyz-def-obj  .
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-rang-xyz-def-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-rang-xyz-def-obj.
end.
    for each wt-rang-xyz-def
    on error undo, return error substitute( "$proc-load-rang-xyz-def(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-rang-xyz-def .
    end.
    create wt-rang-xyz-def.
    run nws-impl in p-imp-handle
      ( input 'rang-xyz-def':U
       ,input (buffer wt-rang-xyz-def:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-rang-xyz-def
      where tb-rang-xyz-def.raxd-id = wt-rang-xyz-def.raxd-id
        and tb-rang-xyz-def.db-num = wt-rang-xyz-def.db-num
      exclusive-lock no-error.
define variable vss-include-info140 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "rang-xyz-def-obj" then do:
      create locb-rang-xyz-def-obj.
run nws-impl in p-imp-handle
  ( input "rang-xyz-def-obj":U
   ,input (buffer locb-rang-xyz-def-obj:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе xyz-анализа."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_rang-xyz-def-obj where
         buf_rang-xyz-def-obj.raxd-id   = wt-rang-xyz-def.raxd-id  and
         buf_rang-xyz-def-obj.db-num    = wt-rang-xyz-def.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_rang-xyz-def-obj.
end.
for each locb-rang-xyz-def-obj where
         locb-rang-xyz-def-obj.raxd-id = wt-rang-xyz-def.raxd-id and
         locb-rang-xyz-def-obj.db-num  = wt-rang-xyz-def.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_rang-xyz-def-obj.
  buffer-copy locb-rang-xyz-def-obj to buf_rang-xyz-def-obj.
end.
if not available tb-rang-xyz-def then do:
  create tb-rang-xyz-def.
end.
buffer-copy wt-rang-xyz-def to tb-rang-xyz-def.
for each locb-rang-xyz-def-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-rang-xyz-def-obj.
end.
    delete wt-rang-xyz-def.
  end.
END PROCEDURE.
define temp-table locb-recipe-gds no-undo like ub.recipe-gds.
define temp-table wt-recipe no-undo like ub.recipe.
PROCEDURE proc-load-recipe:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-recipe. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-recipe. stop" )
  on endkey undo, return error substitute( "$proc-load-recipe. endkey" )
  :
    define buffer tb-recipe for ub.recipe.
    define variable compare-log as logical no-undo.
define buffer buf_recipe-gds for ub.recipe-gds.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
    for each wt-recipe
    on error undo, return error substitute( "$proc-load-recipe(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-recipe .
    end.
    create wt-recipe.
    run nws-impl in p-imp-handle
      ( input 'recipe':U
       ,input (buffer wt-recipe:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-recipe
      where tb-recipe.recipe-code = wt-recipe.recipe-code
      exclusive-lock no-error.
define variable vss-include-info141 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "recipe-gds" then do:
      create locb-recipe-gds.
run nws-impl in p-imp-handle
  ( input "recipe-gds":U
   ,input (buffer locb-recipe-gds:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе производства."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
if not available tb-recipe then do:
  create tb-recipe.
end.
buffer-copy wt-recipe to tb-recipe.
for each buf_recipe-gds where buf_recipe-gds.recipe-code = wt-recipe.recipe-code
on error  undo, return error
:
  delete buf_recipe-gds.
end.
for each locb-recipe-gds where locb-recipe-gds.recipe-code = wt-recipe.recipe-code
                       no-lock
on error  undo, return error
:
  create buf_recipe-gds.
  buffer-copy locb-recipe-gds to buf_recipe-gds.
end.
for each locb-recipe-gds
on error  undo, return error
:
  delete locb-recipe-gds.
end.
    delete wt-recipe.
  end.
END PROCEDURE.
define temp-table locb-c-recipe-gds no-undo like ub.c-recipe-gds.
define temp-table wt-c-recipe no-undo like ub.c-recipe.
PROCEDURE proc-load-c-recipe:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-c-recipe. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-c-recipe. stop" )
  on endkey undo, return error substitute( "$proc-load-c-recipe. endkey" )
  :
    define buffer tb-c-recipe for ub.c-recipe.
    define variable compare-log as logical no-undo.
define buffer buf_c-recipe-gds for ub.c-recipe-gds.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
    for each wt-c-recipe
    on error undo, return error substitute( "$proc-load-c-recipe(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-c-recipe .
    end.
    create wt-c-recipe.
    run nws-impl in p-imp-handle
      ( input 'c-recipe':U
       ,input (buffer wt-c-recipe:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-c-recipe
      where tb-c-recipe.recipe-code = wt-c-recipe.recipe-code
        and tb-c-recipe.corr-user-db-num = wt-c-recipe.corr-user-db-num
        and tb-c-recipe.chip-num = wt-c-recipe.chip-num
      exclusive-lock no-error.
define variable vss-include-info142 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "c-recipe-gds" then do:
      create locb-c-recipe-gds.
run nws-impl in p-imp-handle
  ( input "c-recipe-gds":U
   ,input (buffer locb-c-recipe-gds:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе производства."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
if not available tb-c-recipe then do:
  create tb-c-recipe.
end.
buffer-copy wt-c-recipe to tb-c-recipe.
for each buf_c-recipe-gds where buf_c-recipe-gds.recipe-code = wt-c-recipe.recipe-code
on error  undo, return error
:
  delete buf_c-recipe-gds.
end.
for each locb-c-recipe-gds where locb-c-recipe-gds.recipe-code = wt-c-recipe.recipe-code
                       no-lock
on error  undo, return error
:
  create buf_c-recipe-gds.
  buffer-copy locb-c-recipe-gds to buf_c-recipe-gds.
end.
for each locb-c-recipe-gds
on error  undo, return error
:
  delete locb-c-recipe-gds.
end.
    delete wt-c-recipe.
  end.
END PROCEDURE.
define variable vss-include-info143 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table locb-rvs-line      no-undo like ub.rvs-line.
define temp-table locbr-rvs-line-attr no-undo like ub.rvs-line-attr.
define temp-table locb-rvs-line-pump no-undo like ub.rvs-line-pump.
define temp-table locbr-doc-attr     no-undo like ub.doc-attr.
define temp-table locbr-doc-line-attr     no-undo like ub.doc-line-attr.
define temp-table locbr-rvs-pump     no-undo like ub.rvs-pump.
define temp-table wt-rvs-doc no-undo like ub.rvs-doc.
PROCEDURE proc-load-rvs-doc:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-rvs-doc. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-rvs-doc. stop" )
  on endkey undo, return error substitute( "$proc-load-rvs-doc. endkey" )
  :
    define buffer tb-rvs-doc for ub.rvs-doc.
    define variable compare-log as logical no-undo.
define variable vss-include-info144 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_rvs-line      for ub.rvs-line.
define buffer buf_rvs-line-pump for ub.rvs-line-pump.
define buffer buf_doc-attr      for ub.doc-attr.
define buffer buf_doc-line-attr for ub.doc-line-attr.
define buffer buf_rvs-line-attr for ub.rvs-line-attr.
define buffer buf_rvs-pump      for ub.rvs-pump.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
for each locb-rvs-line
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info144, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info144 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info144 )
:
  delete locb-rvs-line.
end.
for each locb-rvs-line-pump
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info144, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info144 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info144 )
:
  delete locb-rvs-line-pump.
end.
for each locbr-rvs-pump
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info144, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info144 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info144 )
:
  delete locbr-rvs-pump.
end.
for each locbr-doc-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info144, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info144 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info144 )
:
  delete locbr-doc-attr.
end.
for each locbr-doc-line-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info144, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info144 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info144 )
:
  delete locbr-doc-line-attr.
end.
for each locbr-rvs-line-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info144, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info144 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info144 )
:
  delete locbr-rvs-line-attr.
end.
    for each wt-rvs-doc
    on error undo, return error substitute( "$proc-load-rvs-doc(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-rvs-doc .
    end.
    create wt-rvs-doc.
    run nws-impl in p-imp-handle
      ( input 'rvs-doc':U
       ,input (buffer wt-rvs-doc:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-rvs-doc
      where tb-rvs-doc.rvs-code = wt-rvs-doc.rvs-code
      exclusive-lock no-error.
define variable vss-include-info145 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do counter = 1 to l-counter
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info145, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info145 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info145 )
:
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "rvs-line" then do:
      create locb-rvs-line.
run nws-impl in p-imp-handle
  ( input "rvs-line":U
   ,input (buffer locb-rvs-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "rvs-line-pump" then do:
      create locb-rvs-line-pump.
run nws-impl in p-imp-handle
  ( input "rvs-line-pump":U
   ,input (buffer locb-rvs-line-pump:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "rvs-pump" then do:
      create locbr-rvs-pump.
run nws-impl in p-imp-handle
  ( input "rvs-pump":U
   ,input (buffer locbr-rvs-pump:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "doc-attr" then do:
      create locbr-doc-attr.
run nws-impl in p-imp-handle
  ( input "doc-attr":U
   ,input (buffer locbr-doc-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "doc-line-attr" then do:
      create locbr-doc-line-attr.
run nws-impl in p-imp-handle
  ( input "doc-line-attr":U
   ,input (buffer locbr-doc-line-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "rvs-line-attr" then do:
      create locbr-rvs-line-attr.
run nws-impl in p-imp-handle
  ( input "rvs-line-attr":U
   ,input (buffer locbr-rvs-line-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message
        substitute( "Не предусмотрен прием таблицы &1", rec-name ) skip
        substitute( "в составе сверки." ) skip
        view-as alert-box error.
      return error .
    end.
  end case.
end.
for each buf_rvs-line
  where buf_rvs-line.rvs-code = wt-rvs-doc.rvs-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info145, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info145 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info145 )
:
  delete buf_rvs-line.
end.
for each locb-rvs-line
  where locb-rvs-line.rvs-code = wt-rvs-doc.rvs-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info145, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info145 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info145 )
:
  create buf_rvs-line.
  buffer-copy locb-rvs-line to buf_rvs-line.
end.
for each buf_rvs-line-pump
  where buf_rvs-line-pump.rvs-code = wt-rvs-doc.rvs-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info145, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info145 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info145 )
:
  delete buf_rvs-line-pump.
end.
for each locb-rvs-line-pump
  where locb-rvs-line-pump.rvs-code = wt-rvs-doc.rvs-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info145, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info145 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info145 )
:
  create buf_rvs-line-pump.
  buffer-copy locb-rvs-line-pump to buf_rvs-line-pump.
end.
for each buf_rvs-pump
  where buf_rvs-pump.rvs-code = wt-rvs-doc.rvs-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info145, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info145 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info145 )
:
  delete buf_rvs-pump.
end.
for each locbr-rvs-pump
  where locbr-rvs-pump.rvs-code = wt-rvs-doc.rvs-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info145, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info145 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info145 )
:
  create buf_rvs-pump.
  buffer-copy locbr-rvs-pump to buf_rvs-pump.
end.
for each buf_doc-attr
  where buf_doc-attr.doc-code = wt-rvs-doc.rvs-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info145, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info145 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info145 )
:
  delete buf_doc-attr.
end.
for each locbr-doc-attr
  where locbr-doc-attr.doc-code = wt-rvs-doc.rvs-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info145, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info145 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info145 )
:
  create buf_doc-attr.
  buffer-copy locbr-doc-attr to buf_doc-attr.
end.
for each buf_doc-line-attr where buf_doc-line-attr.doc-code = wt-rvs-doc.rvs-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info145, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info145 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info145 )
:
  delete buf_doc-line-attr.
end.
for each locbr-doc-line-attr where locbr-doc-line-attr.doc-code = wt-rvs-doc.rvs-code
                       no-lock
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info145, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info145 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info145 )
:
  create buf_doc-line-attr.
  buffer-copy locbr-doc-line-attr to buf_doc-line-attr.
end.
for each buf_rvs-line-attr where buf_rvs-line-attr.rvs-code = wt-rvs-doc.rvs-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info145, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info145 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info145 )
:
  delete buf_rvs-line-attr.
end.
for each locbr-rvs-line-attr where locbr-rvs-line-attr.rvs-code = wt-rvs-doc.rvs-code
                       no-lock
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info145, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info145 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info145 )
:
  create buf_rvs-line-attr.
  buffer-copy locbr-rvs-line-attr to buf_rvs-line-attr.
end.
if not available tb-rvs-doc then do:
  create tb-rvs-doc.
end.
define variable v-old-rvs-doc-status as character no-undo .
define variable v-new-rvs-doc-status as character no-undo .
assign
  v-old-rvs-doc-status = tb-rvs-doc.status_
  v-new-rvs-doc-status = wt-rvs-doc.status_
.
run trg/nwsdochs.p
  (input g#db-num
  ,input 'update':U
  ,input wt-rvs-doc.rvs-code
  ,input wt-rvs-doc.obj-type
  ,input wt-rvs-doc.obj-code
  ,input 'rvs-doc':U
  ,input '':u
  ,input wt-rvs-doc.fact-date
  ,input wt-rvs-doc.state-measure-qnty
  ,input 0
  ,input 0
  ,input 0
  ,input v-old-rvs-doc-status
  ,input v-new-rvs-doc-status
  ,input g#news-source-db
  ,input p-pck-num
  ,input wt-rvs-doc.user-db-num
  ,input wt-rvs-doc.user-name
  ,input wt-rvs-doc.sys-date
  ,input wt-rvs-doc.sys-time
  ,input wt-rvs-doc.sys-time-int
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.
buffer-copy wt-rvs-doc to tb-rvs-doc.
if wt-rvs-doc.rvs-type <> 'после_док':U
  and ( v-new-rvs-doc-status = 'разрешен':U
        or v-new-rvs-doc-status = 'нередакт':U
      )
then do:
  run trg/lock-rvs.p
    ( input wt-rvs-doc.rvs-code
     ,input "assign-rvs-on=true"
     ,input wt-rvs-doc.rvs-code
     ,input false
    ) no-error.
  if error-status :error then do:
    undo, return error return-value .
  end.
end.
for each locb-rvs-line
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info145, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info145 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info145 )
:
  delete locb-rvs-line.
end.
for each locb-rvs-line-pump
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info145, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info145 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info145 )
:
  delete locb-rvs-line-pump.
end.
for each locbr-rvs-pump
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info145, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info145 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info145 )
:
  delete locbr-rvs-pump.
end.
for each locbr-doc-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info145, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info145 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info145 )
:
  delete locbr-doc-attr.
end.
for each locbr-rvs-line-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info145, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info145 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info145 )
:
  delete locbr-rvs-line-attr.
end.
    delete wt-rvs-doc.
  end.
END PROCEDURE.
define variable vss-include-info146 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table locb-c-rvs-line      no-undo like ub.c-rvs-line.
define temp-table locb-c-rvs-line-pump no-undo like ub.c-rvs-line-pump.
define temp-table locbr-c-doc-attr     no-undo like ub.c-doc-attr.
define temp-table wt-c-rvs-doc no-undo like ub.c-rvs-doc.
PROCEDURE proc-load-c-rvs-doc:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-c-rvs-doc. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-c-rvs-doc. stop" )
  on endkey undo, return error substitute( "$proc-load-c-rvs-doc. endkey" )
  :
    define buffer tb-c-rvs-doc for ub.c-rvs-doc.
    define variable compare-log as logical no-undo.
define variable vss-include-info147 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_c-rvs-line      for ub.c-rvs-line.
define buffer buf_c-rvs-line-pump for ub.c-rvs-line-pump.
define buffer buf_c-doc-attr      for ub.c-doc-attr.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
for each locb-c-rvs-line
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info147, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info147 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info147 )
:
  delete locb-c-rvs-line.
end.
for each locb-c-rvs-line-pump
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info147, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info147 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info147 )
:
  delete locb-c-rvs-line-pump.
end.
for each locbr-c-doc-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info147, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info147 )
on endkey undo, return error substitute( "&1. endkey", vss-include-info147 )
:
  delete locbr-c-doc-attr.
end.
    for each wt-c-rvs-doc
    on error undo, return error substitute( "$proc-load-c-rvs-doc(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-c-rvs-doc .
    end.
    create wt-c-rvs-doc.
    run nws-impl in p-imp-handle
      ( input 'c-rvs-doc':U
       ,input (buffer wt-c-rvs-doc:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-c-rvs-doc
      where tb-c-rvs-doc.rvs-code = wt-c-rvs-doc.rvs-code
        and tb-c-rvs-doc.corr-user-db-num = wt-c-rvs-doc.corr-user-db-num
        and tb-c-rvs-doc.chip-num = wt-c-rvs-doc.chip-num
      exclusive-lock no-error.
define variable vss-include-info148 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "c-rvs-line" then do:
      create locb-c-rvs-line.
run nws-impl in p-imp-handle
  ( input "c-rvs-line":U
   ,input (buffer locb-c-rvs-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-rvs-line-pump" then do:
      create locb-c-rvs-line-pump.
run nws-impl in p-imp-handle
  ( input "c-rvs-line-pump":U
   ,input (buffer locb-c-rvs-line-pump:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-doc-attr" then do:
      create locbr-c-doc-attr.
run nws-impl in p-imp-handle
  ( input "c-doc-attr":U
   ,input (buffer locbr-c-doc-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе производства."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_c-rvs-line where buf_c-rvs-line.rvs-code = wt-c-rvs-doc.rvs-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-rvs-line.
end.
for each locb-c-rvs-line where locb-c-rvs-line.rvs-code = wt-c-rvs-doc.rvs-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-rvs-line.
  buffer-copy locb-c-rvs-line to buf_c-rvs-line.
end.
for each buf_c-rvs-line-pump where buf_c-rvs-line-pump.rvs-code = wt-c-rvs-doc.rvs-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-rvs-line-pump.
end.
for each locb-c-rvs-line-pump where locb-c-rvs-line-pump.rvs-code = wt-c-rvs-doc.rvs-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-rvs-line-pump.
  buffer-copy locb-c-rvs-line-pump to buf_c-rvs-line-pump.
end.
for each buf_c-doc-attr where buf_c-doc-attr.doc-code = wt-c-rvs-doc.rvs-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-doc-attr.
end.
for each locbr-c-doc-attr where locbr-c-doc-attr.doc-code = wt-c-rvs-doc.rvs-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-doc-attr.
  buffer-copy locbr-c-doc-attr to buf_c-doc-attr.
end.
if not available tb-c-rvs-doc then do:
  create tb-c-rvs-doc.
end.
buffer-copy wt-c-rvs-doc to tb-c-rvs-doc.
for each locb-c-rvs-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-rvs-line.
end.
for each locb-c-rvs-line-pump
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-rvs-line-pump.
end.
for each locbr-c-doc-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbr-c-doc-attr.
end.
    delete wt-c-rvs-doc.
  end.
END PROCEDURE.
define variable vss-include-info149 as character format "x(65)" no-undo initial "@(#)$Workfile$".
define temp-table locb-schet-fact-line no-undo like ub.schet-fact-line.
define temp-table wt-schet-fact-doc no-undo like ub.schet-fact-doc.
PROCEDURE proc-load-schet-fact-doc:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-schet-fact-doc. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-schet-fact-doc. stop" )
  on endkey undo, return error substitute( "$proc-load-schet-fact-doc. endkey" )
  :
    define buffer tb-schet-fact-doc for ub.schet-fact-doc.
    define variable compare-log as logical no-undo.
define variable vss-include-info150 as character format "x(65)" no-undo initial "@(#)$Workfile$".
define buffer buf_schet-fact-line for ub.schet-fact-line.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-schet-fact-line
on error undo, return error error-status :get-message (1)
:
  delete locb-schet-fact-line.
end.
    for each wt-schet-fact-doc
    on error undo, return error substitute( "$proc-load-schet-fact-doc(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-schet-fact-doc .
    end.
    create wt-schet-fact-doc.
    run nws-impl in p-imp-handle
      ( input 'schet-fact-doc':U
       ,input (buffer wt-schet-fact-doc:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-schet-fact-doc
      where tb-schet-fact-doc.db-num = wt-schet-fact-doc.db-num
        and tb-schet-fact-doc.doc-code = wt-schet-fact-doc.doc-code
      exclusive-lock no-error.
define variable vss-include-info151 as character format "x(65)" no-undo initial "@(#)$Workfile$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "schet-fact-line" then do:
      create locb-schet-fact-line.
run nws-impl in p-imp-handle
  ( input "schet-fact-line":U
   ,input (buffer locb-schet-fact-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе савокупных заявок."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_schet-fact-line where buf_schet-fact-line.doc-code = wt-schet-fact-doc.doc-code and
                                   buf_schet-fact-line.db-num = wt-schet-fact-doc.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_schet-fact-line.
end.
for each locb-schet-fact-line where locb-schet-fact-line.doc-code = wt-schet-fact-doc.doc-code and
                                    locb-schet-fact-line.db-num = wt-schet-fact-doc.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_schet-fact-line.
  buffer-copy locb-schet-fact-line to buf_schet-fact-line.
end.
if not available tb-schet-fact-doc then do:
  create tb-schet-fact-doc.
end.
buffer-copy wt-schet-fact-doc to tb-schet-fact-doc.
for each locb-schet-fact-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-schet-fact-line.
end.
    delete wt-schet-fact-doc.
  end.
END PROCEDURE.
define variable vss-include-info152 as character format "x(65)" no-undo initial "@(#)$Workfile$".
define temp-table locb-c-schet-fact-line no-undo like ub.c-schet-fact-line.
define temp-table wt-c-schet-fact-doc no-undo like ub.c-schet-fact-doc.
PROCEDURE proc-load-c-schet-fact-doc:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-c-schet-fact-doc. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-c-schet-fact-doc. stop" )
  on endkey undo, return error substitute( "$proc-load-c-schet-fact-doc. endkey" )
  :
    define buffer tb-c-schet-fact-doc for ub.c-schet-fact-doc.
    define variable compare-log as logical no-undo.
define variable vss-include-info153 as character format "x(65)" no-undo initial "@(#)$Workfile$".
define buffer buf_c-schet-fact-line for ub.c-schet-fact-line.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-c-schet-fact-line
on error undo, return error error-status :get-message (1)
:
  delete locb-c-schet-fact-line.
end.
    for each wt-c-schet-fact-doc
    on error undo, return error substitute( "$proc-load-c-schet-fact-doc(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-c-schet-fact-doc .
    end.
    create wt-c-schet-fact-doc.
    run nws-impl in p-imp-handle
      ( input 'c-schet-fact-doc':U
       ,input (buffer wt-c-schet-fact-doc:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-c-schet-fact-doc
      where tb-c-schet-fact-doc.db-num = wt-c-schet-fact-doc.db-num
        and tb-c-schet-fact-doc.doc-code = wt-c-schet-fact-doc.doc-code
        and tb-c-schet-fact-doc.corr-user-db-num = wt-c-schet-fact-doc.corr-user-db-num
        and tb-c-schet-fact-doc.chip-num = wt-c-schet-fact-doc.chip-num
      exclusive-lock no-error.
define variable vss-include-info154 as character format "x(65)" no-undo initial "@(#)$Workfile$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "c-schet-fact-line" then do:
      create locb-c-schet-fact-line.
run nws-impl in p-imp-handle
  ( input "c-schet-fact-line":U
   ,input (buffer locb-c-schet-fact-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе савокупных заявок."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_c-schet-fact-line where buf_c-schet-fact-line.doc-code = wt-c-schet-fact-doc.doc-code and
                                     buf_c-schet-fact-line.db-num = wt-c-schet-fact-doc.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-schet-fact-line.
end.
for each locb-c-schet-fact-line where locb-c-schet-fact-line.doc-code = wt-c-schet-fact-doc.doc-code and
                                    locb-c-schet-fact-line.db-num = wt-c-schet-fact-doc.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-schet-fact-line.
  buffer-copy locb-c-schet-fact-line to buf_c-schet-fact-line.
end.
if not available tb-c-schet-fact-doc then do:
  create tb-c-schet-fact-doc.
end.
buffer-copy wt-c-schet-fact-doc to tb-c-schet-fact-doc.
for each locb-c-schet-fact-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-schet-fact-line.
end.
    delete wt-c-schet-fact-doc.
  end.
END PROCEDURE.
define temp-table locb-shift-staff no-undo like ub.shift-staff.
define temp-table locb-shift-cash no-undo like ub.shift-cash.
define temp-table locb-c-shift-staff no-undo like ub.c-shift-staff.
define temp-table locb-c-sht-hist no-undo like ub.c-sht-hist.
define temp-table locb-c-shift-obj no-undo like ub.c-shift-obj.
 define  temp-table tmprecid
    field Frecid as recid init ?
    field fnum as character
    field fTable as character
 index num  fnum Frecid
 index itable is primary unique fTable Frecid
 .
define variable fSelect as logical no-undo format "*/" column-label "".
function isSelect return logical
    (iBuffer as handle  ):
    define buffer tmprecid for tmprecid.
    if iBuffer:available
    then
       find first tmprecid where tmprecid.fTable = iBuffer:TABLE
                             and tmprecid.Frecid = iBuffer:recid
       no-lock no-error.
    return available tmprecid.
 end.
function setSelect return logical
    (iBuffer as handle  ):
    define buffer tmprecid for tmprecid.
    if iBuffer:available
    then do:
       find first tmprecid where tmprecid.fTable = iBuffer:TABLE
                             and tmprecid.Frecid = iBuffer:recid
       no-lock no-error.
       if available tmprecid
       then
          delete tmprecid.
       else do:
          create tmprecid.
          assign
             tmprecid.fTable = iBuffer:TABLE
             tmprecid.Frecid = iBuffer:recid
          .
       end.
    end.
    return available tmprecid.
 end.
 procedure rid-keep :
     run gbl/rid-keep.p (input table tmprecid) no-error.
 end.
 procedure rid-rest :
      run gbl/rid-rest.p (output table tmprecid) no-error.
 end.
define temp-table wt-shift-obj no-undo like ub.shift-obj.
PROCEDURE proc-load-shift-obj:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-shift-obj. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-shift-obj. stop" )
  on endkey undo, return error substitute( "$proc-load-shift-obj. endkey" )
  :
    define buffer tb-shift-obj for ub.shift-obj.
    define variable compare-log as logical no-undo.
define variable vss-include-info155 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_shift-staff for ub.shift-staff.
define buffer buf_shift-cash for ub.shift-cash.
define buffer buf_c-shift-staff for ub.c-shift-staff.
define buffer buf_c-sht-hist for ub.c-sht-hist.
define buffer buf_c-shift-obj for ub.c-shift-obj.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
for each locb-shift-staff
on error undo, return error error-status :get-message (1)
:
  delete locb-shift-staff.
end.
for each locb-shift-cash
on error undo, return error error-status :get-message (1)
:
  delete locb-shift-cash.
end.
for each locb-c-shift-staff
on error undo, return error error-status :get-message (1)
:
  delete locb-c-shift-staff.
end.
for each locb-c-sht-hist
on error undo, return error error-status :get-message (1)
:
  delete locb-c-sht-hist.
end.
for each locb-c-shift-obj
on error undo, return error error-status :get-message (1)
:
  delete locb-c-shift-obj.
end.
    for each wt-shift-obj
    on error undo, return error substitute( "$proc-load-shift-obj(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-shift-obj .
    end.
    create wt-shift-obj.
    run nws-impl in p-imp-handle
      ( input 'shift-obj':U
       ,input (buffer wt-shift-obj:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-shift-obj
      where tb-shift-obj.obj-type = wt-shift-obj.obj-type
        and tb-shift-obj.obj-code = wt-shift-obj.obj-code
        and tb-shift-obj.shift-date = wt-shift-obj.shift-date
        and tb-shift-obj.shift-num = wt-shift-obj.shift-num
      exclusive-lock no-error.
define variable vss-include-info156 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "shift-staff" then do:
      create locb-shift-staff.
run nws-impl in p-imp-handle
  ( input "shift-staff":U
   ,input (buffer locb-shift-staff:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "shift-cash" then do:
      create locb-shift-cash.
run nws-impl in p-imp-handle
  ( input "shift-cash":U
   ,input (buffer locb-shift-cash:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-shift-staff" then do:
      create locb-c-shift-staff.
run nws-impl in p-imp-handle
  ( input "c-shift-staff":U
   ,input (buffer locb-c-shift-staff:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-sht-hist" then do:
      create locb-c-sht-hist.
run nws-impl in p-imp-handle
  ( input "c-sht-hist":U
   ,input (buffer locb-c-sht-hist:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-shift-obj" then do:
      create locb-c-shift-obj.
run nws-impl in p-imp-handle
  ( input "c-shift-obj":U
   ,input (buffer locb-c-shift-obj:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе смен на объекте."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each locb-shift-staff
where
locb-shift-staff.obj-type eq wt-shift-obj.obj-type
and locb-shift-staff.obj-code eq wt-shift-obj.obj-code
and locb-shift-staff.shift-date eq wt-shift-obj.shift-date
and locb-shift-staff.shift-num eq wt-shift-obj.shift-num
no-lock
on error  undo, return error
:
 for first buf_shift-staff where buf_shift-staff.obj-type eq locb-shift-staff.obj-type
and buf_shift-staff.obj-code eq locb-shift-staff.obj-code
and buf_shift-staff.shift-date eq locb-shift-staff.shift-date
and buf_shift-staff.shift-num eq locb-shift-staff.shift-num
and buf_shift-staff.next-shift eq locb-shift-staff.next-shift
and buf_shift-staff.psn-num eq locb-shift-staff.psn-num
   exclusive-lock: leave. end.
   if not available buf_shift-staff
   then do:
      create buf_shift-staff.
      buffer-copy locb-shift-staff to buf_shift-staff.
   end.
   else
     buffer-copy locb-shift-staff  to buf_shift-staff.
   validate buf_shift-staff no-error.
   if error-status:error
   then
      return error return-value.
   create tmprecid.
   assign
      tmprecid.fTable = "buf_shift-staff"
      tmprecid.Frecid = recid(buf_shift-staff)
   .
end.
for each buf_shift-staff where
buf_shift-staff.obj-type eq wt-shift-obj.obj-type
and buf_shift-staff.obj-code eq wt-shift-obj.obj-code
and buf_shift-staff.shift-date eq wt-shift-obj.shift-date
and buf_shift-staff.shift-num eq wt-shift-obj.shift-num
exclusive-lock
on error  undo, return error
:
   find first tmprecid where tmprecid.fTable = "buf_shift-staff"
                         and tmprecid.Frecid = recid(buf_shift-staff)
   no-lock no-error.
   if not available tmprecid
   then
      delete buf_shift-staff.
end.
empty temp-table tmprecid.
for each locb-shift-cash
where
locb-shift-cash.obj-type eq wt-shift-obj.obj-type
and locb-shift-cash.obj-code eq wt-shift-obj.obj-code
and locb-shift-cash.shift-date eq wt-shift-obj.shift-date
and locb-shift-cash.shift-num eq wt-shift-obj.shift-num
no-lock
on error  undo, return error
:
 for first buf_shift-cash where buf_shift-cash.obj-type eq locb-shift-cash.obj-type
and buf_shift-cash.obj-code eq locb-shift-cash.obj-code
and buf_shift-cash.cash-num eq locb-shift-cash.cash-num
and buf_shift-cash.shift-date eq locb-shift-cash.shift-date
and buf_shift-cash.shift-num eq locb-shift-cash.shift-num
and buf_shift-cash.src-shift-name eq locb-shift-cash.src-shift-name
   exclusive-lock: leave. end.
   if not available buf_shift-cash
   then do:
      create buf_shift-cash.
      buffer-copy locb-shift-cash to buf_shift-cash.
   end.
   else
     buffer-copy locb-shift-cash  to buf_shift-cash.
   validate buf_shift-cash no-error.
   if error-status:error
   then
      return error return-value.
   create tmprecid.
   assign
      tmprecid.fTable = "buf_shift-cash"
      tmprecid.Frecid = recid(buf_shift-cash)
   .
end.
for each buf_shift-cash where
buf_shift-cash.obj-type eq wt-shift-obj.obj-type
and buf_shift-cash.obj-code eq wt-shift-obj.obj-code
and buf_shift-cash.shift-date eq wt-shift-obj.shift-date
and buf_shift-cash.shift-num eq wt-shift-obj.shift-num
exclusive-lock
on error  undo, return error
:
   find first tmprecid where tmprecid.fTable = "buf_shift-cash"
                         and tmprecid.Frecid = recid(buf_shift-cash)
   no-lock no-error.
   if not available tmprecid
   then
      delete buf_shift-cash.
end.
empty temp-table tmprecid.
for each locb-c-shift-staff
where
locb-c-shift-staff.obj-type eq wt-shift-obj.obj-type
and locb-c-shift-staff.obj-code eq wt-shift-obj.obj-code
and locb-c-shift-staff.shift-date eq wt-shift-obj.shift-date
and locb-c-shift-staff.shift-num eq wt-shift-obj.shift-num
no-lock
on error  undo, return error
:
 for first buf_c-shift-staff where buf_c-shift-staff.obj-type eq locb-c-shift-staff.obj-type
and buf_c-shift-staff.obj-code eq locb-c-shift-staff.obj-code
and buf_c-shift-staff.shift-date eq locb-c-shift-staff.shift-date
and buf_c-shift-staff.shift-num eq locb-c-shift-staff.shift-num
and buf_c-shift-staff.next-shift eq locb-c-shift-staff.next-shift
and buf_c-shift-staff.psn-num eq locb-c-shift-staff.psn-num
and buf_c-shift-staff.corr-user-db-num eq locb-c-shift-staff.corr-user-db-num
and buf_c-shift-staff.chip-num eq locb-c-shift-staff.chip-num
   exclusive-lock: leave. end.
   if not available buf_c-shift-staff
   then do:
      create buf_c-shift-staff.
      buffer-copy locb-c-shift-staff to buf_c-shift-staff.
   end.
   else
     buffer-copy locb-c-shift-staff  to buf_c-shift-staff.
   validate buf_c-shift-staff no-error.
   if error-status:error
   then
      return error return-value.
   create tmprecid.
   assign
      tmprecid.fTable = "buf_c-shift-staff"
      tmprecid.Frecid = recid(buf_c-shift-staff)
   .
end.
for each buf_c-shift-staff where
buf_c-shift-staff.obj-type eq wt-shift-obj.obj-type
and buf_c-shift-staff.obj-code eq wt-shift-obj.obj-code
and buf_c-shift-staff.shift-date eq wt-shift-obj.shift-date
and buf_c-shift-staff.shift-num eq wt-shift-obj.shift-num
exclusive-lock
on error  undo, return error
:
   find first tmprecid where tmprecid.fTable = "buf_c-shift-staff"
                         and tmprecid.Frecid = recid(buf_c-shift-staff)
   no-lock no-error.
   if not available tmprecid
   then
      delete buf_c-shift-staff.
end.
empty temp-table tmprecid.
for each locb-c-sht-hist
where
locb-c-sht-hist.obj-type eq wt-shift-obj.obj-type
and locb-c-sht-hist.obj-code eq wt-shift-obj.obj-code
and locb-c-sht-hist.shift-date eq wt-shift-obj.shift-date
and locb-c-sht-hist.shift-num eq wt-shift-obj.shift-num
no-lock
on error  undo, return error
:
 for first buf_c-sht-hist where buf_c-sht-hist.obj-type eq locb-c-sht-hist.obj-type
and buf_c-sht-hist.obj-code eq locb-c-sht-hist.obj-code
and buf_c-sht-hist.shift-date eq locb-c-sht-hist.shift-date
and buf_c-sht-hist.shift-num eq locb-c-sht-hist.shift-num
and buf_c-sht-hist.corr-user-db-num eq locb-c-sht-hist.corr-user-db-num
and buf_c-sht-hist.chip-num eq locb-c-sht-hist.chip-num
and buf_c-sht-hist.subject eq locb-c-sht-hist.subject
   exclusive-lock: leave. end.
   if not available buf_c-sht-hist
   then do:
      create buf_c-sht-hist.
      buffer-copy locb-c-sht-hist to buf_c-sht-hist.
   end.
   else
     buffer-copy locb-c-sht-hist  to buf_c-sht-hist.
   validate buf_c-sht-hist no-error.
   if error-status:error
   then
      return error return-value.
   create tmprecid.
   assign
      tmprecid.fTable = "buf_c-sht-hist"
      tmprecid.Frecid = recid(buf_c-sht-hist)
   .
end.
for each buf_c-sht-hist where
buf_c-sht-hist.obj-type eq wt-shift-obj.obj-type
and buf_c-sht-hist.obj-code eq wt-shift-obj.obj-code
and buf_c-sht-hist.shift-date eq wt-shift-obj.shift-date
and buf_c-sht-hist.shift-num eq wt-shift-obj.shift-num
   and buf_c-sht-hist.corr-user-db-num = g#news-source-db
exclusive-lock
on error  undo, return error
:
   find first tmprecid where tmprecid.fTable = "buf_c-sht-hist"
                         and tmprecid.Frecid = recid(buf_c-sht-hist)
   no-lock no-error.
   if not available tmprecid
   then
      delete buf_c-sht-hist.
end.
empty temp-table tmprecid.
for each locb-c-shift-obj
where
locb-c-shift-obj.obj-type eq wt-shift-obj.obj-type
and locb-c-shift-obj.obj-code eq wt-shift-obj.obj-code
and locb-c-shift-obj.shift-date eq wt-shift-obj.shift-date
and locb-c-shift-obj.shift-num eq wt-shift-obj.shift-num
no-lock
on error  undo, return error
:
 for first buf_c-shift-obj where buf_c-shift-obj.obj-type eq locb-c-shift-obj.obj-type
and buf_c-shift-obj.obj-code eq locb-c-shift-obj.obj-code
and buf_c-shift-obj.shift-date eq locb-c-shift-obj.shift-date
and buf_c-shift-obj.shift-num eq locb-c-shift-obj.shift-num
and buf_c-shift-obj.corr-user-db-num eq locb-c-shift-obj.corr-user-db-num
and buf_c-shift-obj.chip-num eq locb-c-shift-obj.chip-num
   exclusive-lock: leave. end.
   if not available buf_c-shift-obj
   then do:
      create buf_c-shift-obj.
      buffer-copy locb-c-shift-obj to buf_c-shift-obj.
   end.
   else
     buffer-copy locb-c-shift-obj  to buf_c-shift-obj.
   validate buf_c-shift-obj no-error.
   if error-status:error
   then
      return error return-value.
   create tmprecid.
   assign
      tmprecid.fTable = "buf_c-shift-obj"
      tmprecid.Frecid = recid(buf_c-shift-obj)
   .
end.
for each buf_c-shift-obj where
buf_c-shift-obj.obj-type eq wt-shift-obj.obj-type
and buf_c-shift-obj.obj-code eq wt-shift-obj.obj-code
and buf_c-shift-obj.shift-date eq wt-shift-obj.shift-date
and buf_c-shift-obj.shift-num eq wt-shift-obj.shift-num
   and buf_c-shift-obj.corr-user-db-num = g#news-source-db
exclusive-lock
on error  undo, return error
:
   find first tmprecid where tmprecid.fTable = "buf_c-shift-obj"
                         and tmprecid.Frecid = recid(buf_c-shift-obj)
   no-lock no-error.
   if not available tmprecid
   then
      delete buf_c-shift-obj.
end.
empty temp-table tmprecid.
if not available tb-shift-obj then do:
  create tb-shift-obj.
end.
buffer-copy wt-shift-obj to tb-shift-obj.
for each locb-shift-staff
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-shift-staff.
end.
for each locb-shift-cash
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-shift-cash.
end.
for each locb-c-shift-staff
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-shift-staff.
end.
for each locb-c-sht-hist
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-sht-hist.
end.
for each locb-c-shift-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-shift-obj.
end.
    delete wt-shift-obj.
  end.
END PROCEDURE.
define temp-table locb2-shift-cash no-undo like ub.shift-cash.
define temp-table locb2-c-shift-staff no-undo like ub.c-shift-staff.
define temp-table locb2-c-sht-hist no-undo like ub.c-sht-hist.
define temp-table locb2-c-shift-obj no-undo like ub.c-shift-obj.
define temp-table wt-c-shift-obj no-undo like ub.c-shift-obj.
PROCEDURE proc-load-c-shift-obj:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-c-shift-obj. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-c-shift-obj. stop" )
  on endkey undo, return error substitute( "$proc-load-c-shift-obj. endkey" )
  :
    define buffer tb-c-shift-obj for ub.c-shift-obj.
    define variable compare-log as logical no-undo.
define variable vss-include-info157 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_shift-cash for ub.shift-cash.
define buffer buf_c-shift-staff for ub.c-shift-staff.
define buffer buf_c-sht-hist for ub.c-sht-hist.
define buffer buf_c-shift-obj for ub.c-shift-obj.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
for each locb2-shift-cash
on error undo, return error error-status :get-message (1)
:
  delete locb2-shift-cash.
end.
for each locb2-c-shift-staff
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-shift-staff.
end.
for each locb2-c-sht-hist
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-sht-hist.
end.
for each locb2-c-shift-obj
on error undo, return error error-status :get-message (1)
:
  delete locb2-c-shift-obj.
end.
    for each wt-c-shift-obj
    on error undo, return error substitute( "$proc-load-c-shift-obj(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-c-shift-obj .
    end.
    create wt-c-shift-obj.
    run nws-impl in p-imp-handle
      ( input 'c-shift-obj':U
       ,input (buffer wt-c-shift-obj:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-c-shift-obj
      where tb-c-shift-obj.obj-type = wt-c-shift-obj.obj-type
        and tb-c-shift-obj.obj-code = wt-c-shift-obj.obj-code
        and tb-c-shift-obj.shift-date = wt-c-shift-obj.shift-date
        and tb-c-shift-obj.shift-num = wt-c-shift-obj.shift-num
        and tb-c-shift-obj.corr-user-db-num = wt-c-shift-obj.corr-user-db-num
        and tb-c-shift-obj.chip-num = wt-c-shift-obj.chip-num
      exclusive-lock no-error.
define variable vss-include-info158 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "shift-cash" then do:
      create locb2-shift-cash.
run nws-impl in p-imp-handle
  ( input "shift-cash":U
   ,input (buffer locb2-shift-cash:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-shift-staff" then do:
      create locb2-c-shift-staff.
run nws-impl in p-imp-handle
  ( input "c-shift-staff":U
   ,input (buffer locb2-c-shift-staff:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-sht-hist" then do:
      create locb2-c-sht-hist.
run nws-impl in p-imp-handle
  ( input "c-sht-hist":U
   ,input (buffer locb2-c-sht-hist:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-shift-obj" then do:
      create locb2-c-shift-obj.
run nws-impl in p-imp-handle
  ( input "c-shift-obj":U
   ,input (buffer locb2-c-shift-obj:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе смен на объекте."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_shift-cash where buf_shift-cash.obj-type   = wt-c-shift-obj.obj-type
                           and buf_shift-cash.obj-code   = wt-c-shift-obj.obj-code
                           and buf_shift-cash.shift-date = wt-c-shift-obj.shift-date
                           and buf_shift-cash.shift-num  = wt-c-shift-obj.shift-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_shift-cash.
end.
for each locb2-shift-cash where locb2-shift-cash.obj-type   = wt-c-shift-obj.obj-type
                            and locb2-shift-cash.obj-code   = wt-c-shift-obj.obj-code
                            and locb2-shift-cash.shift-date = wt-c-shift-obj.shift-date
                            and locb2-shift-cash.shift-num  = wt-c-shift-obj.shift-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_shift-cash.
  buffer-copy locb2-shift-cash to buf_shift-cash.
end.
_buf_c-sht-hist:
for each buf_c-sht-hist where buf_c-sht-hist.obj-type   = wt-c-shift-obj.obj-type
                           and buf_c-sht-hist.obj-code   = wt-c-shift-obj.obj-code
                           and buf_c-sht-hist.shift-date = wt-c-shift-obj.shift-date
                           and buf_c-sht-hist.shift-num  = wt-c-shift-obj.shift-num
                           and buf_c-sht-hist.corr-user-db-num  = wt-c-shift-obj.corr-user-db-num
                           and buf_c-sht-hist.chip-num  <= wt-c-shift-obj.chip-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
   CASE buf_c-sht-hist.subject:
    when 'c-shift-staff':U then do:
      find first buf_c-shift-staff where buf_c-shift-staff.obj-type      = buf_c-sht-hist.obj-type
                              and buf_c-shift-staff.obj-code         = buf_c-sht-hist.obj-code
                              and buf_c-shift-staff.shift-date       = buf_c-sht-hist.shift-date
                              and buf_c-shift-staff.shift-num        = buf_c-sht-hist.shift-num
                              and buf_c-shift-staff.corr-user-db-num = buf_c-sht-hist.corr-user-db-num
                              and buf_c-shift-staff.chip-num         = buf_c-sht-hist.chip-num exclusive-lock no-wait no-error .
      if locked(buf_c-shift-staff) then do:
        undo, return error.
      end.
      delete buf_c-shift-staff.
    end.
    when 'c-shift-obj':U then do:
      if buf_c-sht-hist.chip-num  = wt-c-shift-obj.chip-num then NEXT _buf_c-sht-hist.
      find first buf_c-shift-obj where buf_c-shift-obj.obj-type      = buf_c-sht-hist.obj-type
                              and buf_c-shift-obj.obj-code         = buf_c-sht-hist.obj-code
                              and buf_c-shift-obj.shift-date       = buf_c-sht-hist.shift-date
                              and buf_c-shift-obj.shift-num        = buf_c-sht-hist.shift-num
                              and buf_c-shift-obj.corr-user-db-num = buf_c-sht-hist.corr-user-db-num
                              and buf_c-shift-obj.chip-num         = buf_c-sht-hist.chip-num exclusive-lock no-wait no-error .
      if locked(buf_c-shift-obj) then do:
        undo, return error.
      end.
      delete buf_c-shift-obj.
    end.
  END CASE.
  delete buf_c-sht-hist.
end.
_locb2-c-sht-hist:
for each locb2-c-sht-hist where locb2-c-sht-hist.obj-type   = wt-c-shift-obj.obj-type
                            and locb2-c-sht-hist.obj-code   = wt-c-shift-obj.obj-code
                            and locb2-c-sht-hist.shift-date = wt-c-shift-obj.shift-date
                            and locb2-c-sht-hist.shift-num  = wt-c-shift-obj.shift-num
                            and locb2-c-sht-hist.corr-user-db-num  = wt-c-shift-obj.corr-user-db-num
                            and locb2-c-sht-hist.chip-num  <= wt-c-shift-obj.chip-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  CASE locb2-c-sht-hist.subject:
    when 'shift-staff':U then dO:
      find first locb2-c-shift-staff where locb2-c-shift-staff.obj-type = locb2-c-sht-hist.obj-type
                              and locb2-c-shift-staff.obj-code         = locb2-c-sht-hist.obj-code
                              and locb2-c-shift-staff.shift-date       = locb2-c-sht-hist.shift-date
                              and locb2-c-shift-staff.shift-num        = locb2-c-sht-hist.shift-num
                              and locb2-c-shift-staff.corr-user-db-num = locb2-c-sht-hist.corr-user-db-num
                              and locb2-c-shift-staff.chip-num         = locb2-c-sht-hist.chip-num
                        no-lock no-error .
      if available locb2-c-shift-staff then do:
        create buf_c-shift-staff.
        buffer-copy locb2-c-shift-staff to buf_c-shift-staff.
      end.
    end.
    when 'shift-obj':U then dO:
      if locb2-c-sht-hist.chip-num = wt-c-shift-obj.chip-num then NEXT _locb2-c-sht-hist.
      find first locb2-c-shift-obj where locb2-c-shift-obj.obj-type = locb2-c-sht-hist.obj-type
                              and locb2-c-shift-obj.obj-code         = locb2-c-sht-hist.obj-code
                              and locb2-c-shift-obj.shift-date       = locb2-c-sht-hist.shift-date
                              and locb2-c-shift-obj.shift-num        = locb2-c-sht-hist.shift-num
                              and locb2-c-shift-obj.corr-user-db-num = locb2-c-sht-hist.corr-user-db-num
                              and locb2-c-shift-obj.chip-num         = locb2-c-sht-hist.chip-num
                        no-lock no-error .
      if available locb2-c-shift-obj then do:
        create buf_c-shift-obj.
        buffer-copy locb2-c-shift-obj to buf_c-shift-obj.
      end.
    end.
  END CASE.
  create buf_c-sht-hist.
  buffer-copy locb2-c-sht-hist to buf_c-sht-hist.
end.
if not available tb-c-shift-obj then do:
  create tb-c-shift-obj.
end.
buffer-copy wt-c-shift-obj to tb-c-shift-obj.
for each locb2-shift-cash
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb2-shift-cash.
end.
for each locb2-c-shift-staff
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb2-c-shift-staff.
end.
for each locb2-c-sht-hist
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb2-c-sht-hist.
end.
for each locb2-c-shift-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb2-c-shift-obj.
end.
    delete wt-c-shift-obj.
  end.
END PROCEDURE.
define variable vss-include-info159 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table wt-staff no-undo like ub.staff.
PROCEDURE proc-load-staff:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-staff. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-staff. stop" )
  on endkey undo, return error substitute( "$proc-load-staff. endkey" )
  :
    define buffer tb-staff for ub.staff.
    define variable compare-log as logical no-undo.
define variable vss-include-info160 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-import as logical no-undo init yes.
define buffer buf_staff for ub.staff .
    for each wt-staff
    on error undo, return error substitute( "$proc-load-staff(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-staff .
    end.
    create wt-staff.
    run nws-impl in p-imp-handle
      ( input 'staff':U
       ,input (buffer wt-staff:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-staff
      where tb-staff.role = wt-staff.role
        and tb-staff.role-level = wt-staff.role-level
        and tb-staff.work-place = wt-staff.work-place
        and tb-staff.staff-code = wt-staff.staff-code
        and tb-staff.date-start = wt-staff.date-start
      exclusive-lock no-error.
define variable vss-include-info161 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if available tb-staff
and tb-staff.psn-code <> wt-staff.psn-code
then do:
  if wt-staff.db-num = g#news-source-db
  or (wt-staff.obj-type <> '':U and wt-staff.obj-code <> 0
      and can-find(first ub.clients no-lock where
                        ub.clients.db-num = g#news-source-db
                    and ub.clients.obj-type = wt-staff.obj-type
                    and ub.clients.obj-code = wt-staff.obj-code)) then do:
    if g#db-num = 0 then do:
      delete tb-staff.
    end.
    else do:
      v-import = no.
    end.
  end.
  if wt-staff.db-num = g#db-num
  or (wt-staff.obj-type <> '':U and wt-staff.obj-code <> 0
      and can-find(first ub.clients no-lock where
                        ub.clients.db-num = g#db-num
                    and ub.clients.obj-type = wt-staff.obj-type
                    and ub.clients.obj-code = wt-staff.obj-code)) then do:
    v-import = no.
  end.
end.
for each buf_staff where
          buf_staff.role = wt-staff.role
     and  buf_staff.role-level = wt-staff.role-level
     and  buf_staff.work-place = wt-staff.work-place
     and  buf_staff.staff-code = wt-staff.staff-code
     and  buf_staff.date-end >= wt-staff.date-start
 by buf_staff.date-start
 on error undo, return error
 on stop undo, return error
 :
  IF buf_staff.psn-code = wt-staff.psn-code then do:
    if buf_staff.date-end = 12/31/9999
    then do:
      if buf_staff.date-start = wt-staff.date-start then do:
      buf_staff.date-end = wt-staff.date-end.
        v-import = no.
        leave.
    end.
    else do:
        v-import = no.
        leave.
      end.
    end.
    else do:
      if buf_staff.date-start = wt-staff.date-start
        and ( wt-staff.db-num = g#news-source-db
              or ( wt-staff.obj-type <> '':U
                   and wt-staff.obj-code <> 0
                   and can-find(first ub.clients no-lock where
                                      ub.clients.db-num = g#news-source-db
                                  and ub.clients.obj-type = wt-staff.obj-type
                                  and ub.clients.obj-code = wt-staff.obj-code
                                )
                 )
            )
      then do:
        buf_staff.date-end = wt-staff.date-end.
        v-import = no.
        leave.
      end.
      else do:
        v-import = no.
      end.
    end.
    if buf_staff.date-end < wt-staff.date-end then do:
      if buf_staff.date-start = wt-staff.date-start then do:
        buf_staff.date-end = wt-staff.date-end.
        v-import = yes.
        leave.
      end.
    end.
  end.
  else do:
    if buf_staff.date-start < wt-staff.date-start
    and wt-staff.date-start >= v-today + 1 then do:
      assign
      buf_staff.date-end = (if buf_staff.date-end - wt-staff.date-start >= 1
                            then wt-staff.date-start - 1
                            else buf_staff.date-end)
                            .
    end.
    else do:
      if wt-staff.db-num = g#news-source-db
      or (wt-staff.obj-type <> '':U and wt-staff.obj-code <> 0
          and can-find(first ub.clients no-lock where
                            ub.clients.db-num = g#news-source-db
                        and ub.clients.obj-type = wt-staff.obj-type
                        and ub.clients.obj-code = wt-staff.obj-code)) then do:
        if g#db-num = 0 then do:
          delete buf_staff.
        end.
        else do:
          v-import = no.
        end.
      end.
      if wt-staff.db-num = g#db-num
      or (wt-staff.obj-type <> '':U and wt-staff.obj-code <> 0
          and can-find(first ub.clients no-lock where
                            ub.clients.db-num = g#db-num
                        and ub.clients.obj-type = wt-staff.obj-type
                        and ub.clients.obj-code = wt-staff.obj-code)) then do:
        v-import = no.
      end.
    END.
  end.
END.
if v-import = yes then do:
  IF NOT AVAILABLE Tb-STAFF then DO:
    CREATE TB-STAFF.
  END.
  BUFFER-COPY wt-staff to tb-staff.
end.
if v-import = no then do:
  if available Tb-STAFF then do:
      Tb-STAFF.password = wt-staff.password.
  end.
end.
    delete wt-staff.
  end.
END PROCEDURE.
define temp-table locb-stop-list-line no-undo like ub.stop-list-line.
define temp-table locb-c-stop-list-line no-undo like ub.c-stop-list-line.
define temp-table locb-c-stop-list no-undo like ub.c-stop-list.
define temp-table wt-stop-list no-undo like ub.stop-list.
PROCEDURE proc-load-stop-list:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-stop-list. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-stop-list. stop" )
  on endkey undo, return error substitute( "$proc-load-stop-list. endkey" )
  :
    define buffer tb-stop-list for ub.stop-list.
    define variable compare-log as logical no-undo.
define variable vss-include-info162 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_stop-list-line for ub.stop-list-line.
define buffer buf_c-stop-list-line for ub.c-stop-list-line.
define buffer buf_c-stop-list for ub.c-stop-list.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
define variable v-to-send as logical no-undo .
for each locb-stop-list-line
on error undo, return error error-status :get-message (1)
:
  delete locb-stop-list-line.
end.
for each locb-c-stop-list-line
on error undo, return error error-status :get-message (1)
:
  delete locb-c-stop-list-line.
end.
for each locb-c-stop-list
on error undo, return error error-status :get-message (1)
:
  delete locb-c-stop-list.
end.
    for each wt-stop-list
    on error undo, return error substitute( "$proc-load-stop-list(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-stop-list .
    end.
    create wt-stop-list.
    run nws-impl in p-imp-handle
      ( input 'stop-list':U
       ,input (buffer wt-stop-list:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-stop-list
      where tb-stop-list.classif-type = wt-stop-list.classif-type
        and tb-stop-list.stop-list-code = wt-stop-list.stop-list-code
      exclusive-lock no-error.
define variable vss-include-info163 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "stop-list-line" then do:
      create locb-stop-list-line.
run nws-impl in p-imp-handle
  ( input "stop-list-line":U
   ,input (buffer locb-stop-list-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-stop-list-line" then do:
      create locb-c-stop-list-line.
run nws-impl in p-imp-handle
  ( input "c-stop-list-line":U
   ,input (buffer locb-c-stop-list-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-stop-list" then do:
      create locb-c-stop-list.
run nws-impl in p-imp-handle
  ( input "c-stop-list":U
   ,input (buffer locb-c-stop-list:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "nws/inc/imp/stop-l.i: Не предусмотрен прием таблицы " rec-name skip
              "в составе накладной"
              view-as alert-box error.
      return error "nws/inc/imp/stop-l.i: Не предусмотрен прием таблицы " + rec-name + chr(10) + "в составе накладной".
    end.
  END CASE.
end.
if not available tb-stop-list then do:
  if wt-stop-list.status_ = 'факт':U then do:
     v-to-send = yes.
   end.
  create tb-stop-list.
end.
else do:
  if wt-stop-list.status_ = 'факт':U
  and tb-stop-list.status_ <> 'факт':U then do:
    v-to-send = yes.
  end.
end.
define variable v-old-stop-list-status as character no-undo .
define variable v-new-stop-list-status as character no-undo .
assign
  v-old-stop-list-status = tb-stop-list.status_
  v-new-stop-list-status = wt-stop-list.status_
.
run trg/nwsdochs.p
  (input g#db-num
  ,input 'update':U
  ,input wt-stop-list.stop-list-code
  ,input wt-stop-list.obj-type
  ,input wt-stop-list.obj-code
  ,input 'stop-list':U
  ,input wt-stop-list.list-type
  ,input wt-stop-list.fact-date
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input v-old-stop-list-status
  ,input v-new-stop-list-status
  ,input g#news-source-db
  ,input p-pck-num
  ,input wt-stop-list.user-db-num
  ,input wt-stop-list.user-name
  ,input wt-stop-list.sys-date
  ,input wt-stop-list.sys-time
  ,input wt-stop-list.sys-time-int
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.
buffer-copy wt-stop-list to tb-stop-list.
for each buf_stop-list-line where
       buf_stop-list-line.classif-type = wt-stop-list.classif-type
   and buf_stop-list-line.stop-list-code = wt-stop-list.stop-list-code
on error  undo, return error
:
  delete buf_stop-list-line.
end.
for each buf_c-stop-list-line where
       buf_c-stop-list-line.classif-type = wt-stop-list.classif-type
   and buf_c-stop-list-line.stop-list-code = wt-stop-list.stop-list-code
on error  undo, return error
:
  delete buf_c-stop-list-line.
end.
for each buf_c-stop-list where
       buf_c-stop-list.classif-type = wt-stop-list.classif-type
   and buf_c-stop-list.stop-list-code = wt-stop-list.stop-list-code
on error  undo, return error
:
  delete buf_c-stop-list.
end.
for each locb-stop-list-line where
        locb-stop-list-line.classif-type = wt-stop-list.classif-type
    and locb-stop-list-line.stop-list-code = wt-stop-list.stop-list-code
                        no-lock
on error  undo, return error
:
  create buf_stop-list-line.
  buffer-copy locb-stop-list-line to buf_stop-list-line.
end.
for each locb-c-stop-list-line where
        locb-c-stop-list-line.classif-type = wt-stop-list.classif-type
    and locb-c-stop-list-line.stop-list-code = wt-stop-list.stop-list-code
                        no-lock
on error  undo, return error
:
  create buf_c-stop-list-line.
  buffer-copy locb-c-stop-list-line to buf_c-stop-list-line.
end.
for each locb-c-stop-list where
        locb-c-stop-list.classif-type = wt-stop-list.classif-type
    and locb-c-stop-list.stop-list-code = wt-stop-list.stop-list-code
                        no-lock
on error  undo, return error
:
  create buf_c-stop-list.
  buffer-copy locb-c-stop-list to buf_c-stop-list.
end.
for each locb-stop-list-line
on error  undo, return error
:
  delete locb-stop-list-line.
end.
for each locb-c-stop-list-line
on error  undo, return error
:
  delete locb-c-stop-list-line.
end.
for each locb-c-stop-list
on error  undo, return error
:
  delete locb-c-stop-list.
end.
if v-to-send then do:
  run fill-stpl-list in p-imp-handle ( buffer tb-stop-list).
end.
    delete wt-stop-list.
  end.
END PROCEDURE.
define temp-table locb-sum-group           no-undo like  ub.sum-group.
define temp-table locb-sum-in-sum-group    no-undo like  ub.sum-in-sum-group.
define temp-table locb-c-sum-group         no-undo like  ub.c-sum-group.
define temp-table locb-c-sum-in-sum-group  no-undo like  ub.c-sum-in-sum-group.
define temp-table wt-sum-group no-undo like ub.sum-group.
PROCEDURE proc-load-sum-group:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-sum-group. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-sum-group. stop" )
  on endkey undo, return error substitute( "$proc-load-sum-group. endkey" )
  :
    define buffer tb-sum-group for ub.sum-group.
    define variable compare-log as logical no-undo.
define variable vss-include-info164 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_sum-group          for ub.sum-group.
define buffer buf_sum-in-sum-group   for ub.sum-in-sum-group.
define buffer buf_c-sum-group        for ub.c-sum-group.
define buffer buf_c-sum-in-sum-group for ub.c-sum-in-sum-group.
define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.
for each locb-sum-group
on error  undo, return error
:
  delete locb-sum-group.
end.
for each locb-c-sum-group
on error  undo, return error
:
  delete locb-c-sum-group.
end.
for each locb-sum-in-sum-group
on error  undo, return error
:
  delete locb-sum-in-sum-group.
end.
for each locb-c-sum-in-sum-group
on error  undo, return error
:
  delete locb-c-sum-in-sum-group.
end.
    for each wt-sum-group
    on error undo, return error substitute( "$proc-load-sum-group(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-sum-group .
    end.
    create wt-sum-group.
    run nws-impl in p-imp-handle
      ( input 'sum-group':U
       ,input (buffer wt-sum-group:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-sum-group
      where tb-sum-group.sgr-id = wt-sum-group.sgr-id
        and tb-sum-group.sgr-db-num = wt-sum-group.sgr-db-num
      exclusive-lock no-error.
define variable vss-include-info165 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "sum-in-sum-group" then do:
      create locb-sum-in-sum-group.
run nws-impl in p-imp-handle
  ( input "sum-in-sum-group":U
   ,input (buffer locb-sum-in-sum-group:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-sum-group" then do:
      create locb-c-sum-group.
run nws-impl in p-imp-handle
  ( input "c-sum-group":U
   ,input (buffer locb-c-sum-group:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-sum-in-sum-group" then do:
      create locb-c-sum-in-sum-group.
run nws-impl in p-imp-handle
  ( input "c-sum-in-sum-group":U
   ,input (buffer locb-c-sum-in-sum-group:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_c-sum-group where buf_c-sum-group.sgr-id = wt-sum-group.sgr-id
                           and buf_c-sum-group.sgr-db-num = wt-sum-group.sgr-db-num
on error  undo, return error
:
  delete buf_c-sum-group.
end.
for each locb-c-sum-group where locb-c-sum-group.sgr-id     = wt-sum-group.sgr-id
                            and locb-c-sum-group.sgr-db-num = wt-sum-group.sgr-db-num
  no-lock
on error  undo, return error
:
  create buf_c-sum-group.
  buffer-copy  locb-c-sum-group to buf_c-sum-group.
end.
for each buf_sum-in-sum-group where buf_sum-in-sum-group.sgr-id     = wt-sum-group.sgr-id
                                and buf_sum-in-sum-group.sgr-db-num = wt-sum-group.sgr-db-num
on error  undo, return error
:
  delete buf_sum-in-sum-group.
end.
for each locb-sum-in-sum-group where locb-sum-in-sum-group.sgr-id     = wt-sum-group.sgr-id
                                  and locb-sum-in-sum-group.sgr-db-num = wt-sum-group.sgr-db-num
no-lock
on error  undo, return error
:
  create buf_sum-in-sum-group.
  buffer-copy locb-sum-in-sum-group to buf_sum-in-sum-group.
end.
for each buf_c-sum-in-sum-group where buf_c-sum-in-sum-group.sgr-id     = wt-sum-group.sgr-id
                                  and buf_c-sum-in-sum-group.sgr-db-num = wt-sum-group.sgr-db-num
on error  undo, return error
:
  delete buf_c-sum-in-sum-group.
end.
for each locb-c-sum-in-sum-group where locb-c-sum-in-sum-group.sgr-id = wt-sum-group.sgr-id
                                    and locb-c-sum-in-sum-group.sgr-db-num = wt-sum-group.sgr-db-num
no-lock
on error  undo, return error
:
  create buf_c-sum-in-sum-group.
  buffer-copy locb-c-sum-in-sum-group to buf_c-sum-in-sum-group.
end.
if not available tb-sum-group then do:
  create tb-sum-group.
end.
buffer-copy wt-sum-group to tb-sum-group.
for each locb-c-sum-group
on error  undo, return error
:
  delete locb-c-sum-group.
end.
for each locb-sum-in-sum-group
on error  undo, return error
:
  delete locb-sum-in-sum-group.
end.
for each locb-c-sum-in-sum-group
on error  undo, return error
:
  delete locb-c-sum-in-sum-group.
end.
    delete wt-sum-group.
  end.
END PROCEDURE.
define temp-table wt-tax no-undo like ub.tax.
PROCEDURE proc-load-tax:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-tax. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-tax. stop" )
  on endkey undo, return error substitute( "$proc-load-tax. endkey" )
  :
    define buffer tb-tax for ub.tax.
    define variable compare-log as logical no-undo.
    for each wt-tax
    on error undo, return error substitute( "$proc-load-tax(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-tax .
    end.
    create wt-tax.
    run nws-impl in p-imp-handle
      ( input 'tax':U
       ,input (buffer wt-tax:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-tax
      where tb-tax.tax-code = wt-tax.tax-code
      exclusive-lock no-error.
define variable vss-include-info166 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if not available tb-tax then do:
  create tb-tax.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-tax TO wt-tax case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-tax TO tb-tax.
  if tb-tax.to-cashdesk = yes then do:
    run fill-cash-txn in p-imp-handle ( buffer tb-tax).
  end.
end.
    delete wt-tax.
  end.
END PROCEDURE.
define temp-table wt-tax-rate no-undo like ub.tax-rate.
PROCEDURE proc-load-tax-rate:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-tax-rate. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-tax-rate. stop" )
  on endkey undo, return error substitute( "$proc-load-tax-rate. endkey" )
  :
    define buffer tb-tax-rate for ub.tax-rate.
    define variable compare-log as logical no-undo.
define variable vss-include-info167 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_tax for ub.tax.
define buffer buf_clients for ub.clients.
define buffer buf_shop    for ub.shop.
    for each wt-tax-rate
    on error undo, return error substitute( "$proc-load-tax-rate(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-tax-rate .
    end.
    create wt-tax-rate.
    run nws-impl in p-imp-handle
      ( input 'tax-rate':U
       ,input (buffer wt-tax-rate:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-tax-rate
      where tb-tax-rate.tax-code = wt-tax-rate.tax-code
        and tb-tax-rate.rate-code = wt-tax-rate.rate-code
      exclusive-lock no-error.
define variable vss-include-info168 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if not available tb-tax-rate then do:
  create tb-tax-rate.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-tax-rate TO wt-tax-rate case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-tax-rate TO tb-tax-rate.
  find buf_tax where buf_tax.tax-code = tb-tax-rate.tax-code no-lock no-error.
  define variable v-host-code as integer   no-undo .
  if available buf_tax
  and buf_tax.to-cashdesk = yes
  then do:
    for each buf_clients no-lock
      where buf_clients.obj-type = 'маг':U
        and buf_clients.db-num = g#db-num
    on error undo, return error return-value
    :
define variable vss-include-info169 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_clients.obj-type
  ,input  buf_clients.obj-code
  ,output v-host-code
  )  .
      run fill-cash-txr in p-imp-handle (
                                           input tb-tax-rate.tax-code
                                          ,input tb-tax-rate.rate-code
                                          ,input tb-tax-rate.status_
                                          ,input v-host-code
                                          ,input buf_clients.obj-type
                                          ,input buf_clients.obj-code
                                          ,input buf_tax.tax-type
                                          ,input ?
                                          ,input tb-tax-rate.rate-code
                                          ,input recid(tb-tax-rate)
                                          ).
    end.
  end.
end.
    delete wt-tax-rate.
  end.
END PROCEDURE.
define variable vss-include-info170 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table wt-tax-rate-gds no-undo like ub.tax-rate-gds.
PROCEDURE proc-load-tax-rate-gds:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-tax-rate-gds. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-tax-rate-gds. stop" )
  on endkey undo, return error substitute( "$proc-load-tax-rate-gds. endkey" )
  :
    define buffer tb-tax-rate-gds for ub.tax-rate-gds.
    define variable compare-log as logical no-undo.
define variable vss-include-info171 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_goods for ub.goods.
    for each wt-tax-rate-gds
    on error undo, return error substitute( "$proc-load-tax-rate-gds(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-tax-rate-gds .
    end.
    create wt-tax-rate-gds.
    run nws-impl in p-imp-handle
      ( input 'tax-rate-gds':U
       ,input (buffer wt-tax-rate-gds:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-tax-rate-gds
      where tb-tax-rate-gds.gds-code = wt-tax-rate-gds.gds-code
        and tb-tax-rate-gds.tax-code = wt-tax-rate-gds.tax-code
        and tb-tax-rate-gds.host-code = wt-tax-rate-gds.host-code
        and tb-tax-rate-gds.obj-type = wt-tax-rate-gds.obj-type
        and tb-tax-rate-gds.obj-code = wt-tax-rate-gds.obj-code
        and tb-tax-rate-gds.fact-order = wt-tax-rate-gds.fact-order
      exclusive-lock no-error.
define variable vss-include-info172 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if not available tb-tax-rate-gds then do:
  create tb-tax-rate-gds.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-tax-rate-gds TO wt-tax-rate-gds case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-tax-rate-gds TO tb-tax-rate-gds.
  if num-entries(tb-tax-rate-gds.corr-user-name, chr(4)) > 1
  and entry(2, tb-tax-rate-gds.corr-user-name, chr(4)) = 'upgrade':U then do:
  end.
  else do:
    find buf_goods where buf_goods.gds-code = tb-tax-rate-gds.gds-code
                  no-lock no-error.
    if available buf_goods then do:
      run fill-gds-list in p-imp-handle ( buffer buf_goods).
    end.
  end.
end.
    delete wt-tax-rate-gds.
  end.
END PROCEDURE.
define temp-table wt-tax-rate-value no-undo like ub.tax-rate-value.
PROCEDURE proc-load-tax-rate-value:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-tax-rate-value. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-tax-rate-value. stop" )
  on endkey undo, return error substitute( "$proc-load-tax-rate-value. endkey" )
  :
    define buffer tb-tax-rate-value for ub.tax-rate-value.
    define variable compare-log as logical no-undo.
define variable vss-include-info173 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_tax for ub.tax.
    for each wt-tax-rate-value
    on error undo, return error substitute( "$proc-load-tax-rate-value(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-tax-rate-value .
    end.
    create wt-tax-rate-value.
    run nws-impl in p-imp-handle
      ( input 'tax-rate-value':U
       ,input (buffer wt-tax-rate-value:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-tax-rate-value
      where tb-tax-rate-value.tax-code = wt-tax-rate-value.tax-code
        and tb-tax-rate-value.rate-code = wt-tax-rate-value.rate-code
        and tb-tax-rate-value.host-code = wt-tax-rate-value.host-code
        and tb-tax-rate-value.obj-type = wt-tax-rate-value.obj-type
        and tb-tax-rate-value.obj-code = wt-tax-rate-value.obj-code
        and tb-tax-rate-value.fact-order = wt-tax-rate-value.fact-order
      exclusive-lock no-error.
define variable vss-include-info174 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if not available tb-tax-rate-value then do:
  create tb-tax-rate-value.
  assign compare-log = no.
end.
else do:
  buffer-compare tb-tax-rate-value TO wt-tax-rate-value case-sensitive save result in compare-log no-error.
end.
if not compare-log then do:
  buffer-copy wt-tax-rate-value TO tb-tax-rate-value.
  find buf_tax where buf_tax.tax-code = tb-tax-rate-value.tax-code no-lock no-error.
  if available buf_tax and
     buf_tax.to-cashdesk = yes AND
     tb-tax-rate-value.fact-date <= today
    then do:
    run fill-cash-txr in p-imp-handle (
                                         input buf_tax.tax-code
                                        ,input tb-tax-rate-value.rate-code
                                        ,input ?
                                        ,input tb-tax-rate-value.host-code
                                        ,input tb-tax-rate-value.obj-type
                                        ,input tb-tax-rate-value.obj-code
                                        ,input buf_tax.tax-type
                                        ,input tb-tax-rate-value.rate-value
                                        ,input integer( tb-tax-rate-value.fact-date)
                                        ,input recid(tb-tax-rate-value)
                                        ).
  end.
end.
    delete wt-tax-rate-value.
  end.
END PROCEDURE.
define temp-table wt-thbj-attr no-undo like ub.thbj-attr.
PROCEDURE proc-load-thbj-attr:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-thbj-attr. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-thbj-attr. stop" )
  on endkey undo, return error substitute( "$proc-load-thbj-attr. endkey" )
  :
    define buffer tb-thbj-attr for ub.thbj-attr.
    define variable compare-log as logical no-undo.
    for each wt-thbj-attr
    on error undo, return error substitute( "$proc-load-thbj-attr(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-thbj-attr .
    end.
    create wt-thbj-attr.
    run nws-impl in p-imp-handle
      ( input 'thbj-attr':U
       ,input (buffer wt-thbj-attr:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-thbj-attr
      where tb-thbj-attr.obj-type = wt-thbj-attr.obj-type
        and tb-thbj-attr.obj-code = wt-thbj-attr.obj-code
        and tb-thbj-attr.upper-prop-code = wt-thbj-attr.upper-prop-code
        and tb-thbj-attr.prop-code = wt-thbj-attr.prop-code
      exclusive-lock no-error.
define variable vss-include-info175 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if not available tb-thbj-attr then
do:
   create tb-thbj-attr.
   assign
      compare-log = no.
end.
else
do:
   buffer-compare tb-thbj-attr TO wt-thbj-attr case-sensitive save result in compare-log no-error.
end.
if not compare-log then
do:
   buffer-copy wt-thbj-attr TO tb-thbj-attr.
   run fill-setting in p-imp-handle ("thbj-attr",
                                     tb-thbj-attr.obj-type,
                                     tb-thbj-attr.obj-code,
                                     tb-thbj-attr.upper-prop-code,
                                     tb-thbj-attr.prop-code).
end.
    delete wt-thbj-attr.
  end.
END PROCEDURE.
define temp-table locb-doc-line             no-undo like ub.doc-line.
define temp-table locb-doc-line-attr        no-undo like ub.doc-line-attr.
define temp-table locb-inv-line             no-undo like ub.inv-line.
define temp-table locb-doc-line-sum         no-undo like ub.doc-line-sum.
define temp-table locb-inv-doc              no-undo like ub.inv-doc.
define temp-table locb-trn-doc-sum          no-undo like ub.trn-doc-sum.
define temp-table locb-gds-dtl              no-undo like ub.gds-dtl.
define temp-table locb-parts                no-undo like ub.parts.
define temp-table locb-marking-lines        no-undo like ub.marking-lines.
define temp-table locb-doc-prts             no-undo like ub.doc-prts.
define temp-table locb-doc-pl               no-undo like ub.doc-pl.
define temp-table locb-doc-pl-attr          no-undo like ub.doc-pl-attr.
define temp-table locb-doc-pl-pump          no-undo like ub.doc-pl-pump.
define temp-table locb-parts-root           no-undo like ub.parts-root.
define temp-table locb-parts-attr           no-undo like ub.parts-attr.
define temp-table locb-parts-supp           no-undo like ub.parts-supp.
define temp-table locb-gen-attr             no-undo like ub.gen-attr.
define temp-table locbt-doc-attr            no-undo like ub.doc-attr.
define temp-table locb-doc-fbr-gds          no-undo like ub.doc-fbr-gds.
define temp-table locb-arh-trn-doc-contract no-undo like ub.arh-trn-doc-contract.
define temp-table tdlocb-chk-doc            no-undo like ub.chk-doc.
define temp-table tdlocb-c-chk-doc          no-undo like ub.c-chk-doc.
define temp-table tdlocb-chk-gds            no-undo like ub.chk-gds.
define temp-table tdlocb-chk-gds-attr       no-undo like ub.chk-gds-attr.
define temp-table tdlocb-c-chk-gds          no-undo like ub.c-chk-gds.
define temp-table tdlocb-chk-doc-attr       no-undo like ub.chk-doc-attr.
define temp-table tdlocb-c-chk-doc-attr     no-undo like ub.c-chk-doc-attr.
define temp-table locb-ord-chain            no-undo like ub.ord-chain.
define temp-table tdlocb-marking-chk        no-undo like ub.marking-chk.
define buffer locb-rc-arh-trn-doc-contract for locb-arh-trn-doc-contract.
define new global shared variable g#libtfarh as handle no-undo .
define variable vss-include-info176 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE proc-load-trn-doc-inv-chk:
  define input parameter p-doc-code as character no-undo.
define buffer buf_chk-doc                  for ub.chk-doc.
define buffer buf_c-chk-doc                for ub.c-chk-doc.
define buffer buf_chk-gds                  for ub.chk-gds.
define buffer buf_chk-gds-attr             for ub.chk-gds-attr.
define buffer buf_c-chk-gds                for ub.c-chk-gds.
define buffer buf_chk-doc-attr             for ub.chk-doc-attr.
define buffer buf_c-chk-doc-attr           for ub.c-chk-doc-attr.
define buffer buf_marking-chk              for ub.marking-chk.
  do
  on error  undo, return error substitute( "$proc-load-trn-doc-inv-chk-doc. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-trn-doc-inv-chk-doc. stop" )
  on endkey undo, return error substitute( "$proc-load-trn-doc-inv-chk-doc. endkey" )
  :
    for each buf_chk-doc-attr where buf_chk-doc-attr.out-code = p-doc-code
    on error  undo, return error
    :
      delete buf_chk-doc-attr.
    end.
    for each tdlocb-chk-doc-attr where tdlocb-chk-doc-attr.out-code = p-doc-code
                          no-lock
    on error  undo, return error
    :
      create buf_chk-doc-attr.
      buffer-copy tdlocb-chk-doc-attr to buf_chk-doc-attr.
    end.
    for each buf_chk-doc where buf_chk-doc.out-code = p-doc-code
    on error  undo, return error
    :
      delete buf_chk-doc.
    end.
    for each tdlocb-chk-doc where tdlocb-chk-doc.out-code = p-doc-code
                          no-lock
    on error  undo, return error
    :
      create buf_chk-doc.
      buffer-copy tdlocb-chk-doc to buf_chk-doc.
    end.
    for each buf_chk-gds where buf_chk-gds.out-code = p-doc-code
    on error  undo, return error
    :
      for each buf_chk-gds-attr where buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code and buf_chk-gds-attr.line-num = buf_chk-gds.line-num
      on error  undo, return error
      :
        delete buf_chk-gds-attr.
      end.
      for each buf_marking-chk where buf_marking-chk.doc-code = buf_chk-gds.doc-code and buf_marking-chk.line-num = buf_chk-gds.line-num
      on error  undo, return error
      :
        delete buf_marking-chk.
      end.
      delete buf_chk-gds.
    end.
    for each tdlocb-chk-gds where tdlocb-chk-gds.out-code = p-doc-code
                          no-lock
    on error  undo, return error
    :
      create buf_chk-gds.
      buffer-copy tdlocb-chk-gds to buf_chk-gds.
      for each tdlocb-chk-gds-attr where tdlocb-chk-gds-attr.doc-code = tdlocb-chk-gds.doc-code and tdlocb-chk-gds-attr.line-num = tdlocb-chk-gds.line-num
                            no-lock
      on error  undo, return error
      :
        create buf_chk-gds-attr.
        buffer-copy tdlocb-chk-gds-attr to buf_chk-gds-attr.
      end.
      for each tdlocb-marking-chk where tdlocb-marking-chk.doc-code = tdlocb-chk-gds.doc-code and tdlocb-marking-chk.line-num = tdlocb-chk-gds.line-num
                            no-lock
      on error  undo, return error
      :
        create buf_marking-chk.
        buffer-copy tdlocb-marking-chk to buf_marking-chk.
      end.
    end.
    for each buf_c-chk-doc-attr where buf_c-chk-doc-attr.out-code = p-doc-code
    on error  undo, return error
    :
      delete buf_c-chk-doc-attr.
    end.
    for each tdlocb-c-chk-doc-attr where tdlocb-c-chk-doc-attr.out-code = p-doc-code
                          no-lock
    on error  undo, return error
    :
      create buf_c-chk-doc-attr.
      buffer-copy tdlocb-c-chk-doc-attr to buf_c-chk-doc-attr.
    end.
    for each tdlocb-c-chk-doc where tdlocb-c-chk-doc.out-code = p-doc-code
                          no-lock,
        first buf_c-chk-doc where buf_c-chk-doc.doc-code = tdlocb-c-chk-doc.doc-code
                    and buf_c-chk-doc.out-code = ?
    on error  undo, return error
    :
      for each buf_c-chk-gds where buf_c-chk-gds.doc-code = tdlocb-c-chk-doc.doc-code:
        delete buf_c-chk-gds.
      end.
      for each buf_c-chk-doc-attr where buf_c-chk-doc-attr.doc-code = tdlocb-c-chk-doc.doc-code:
        delete buf_c-chk-doc-attr.
      end.
      delete buf_c-chk-doc.
    end.
    for each buf_c-chk-doc where buf_c-chk-doc.out-code = p-doc-code
    on error  undo, return error
    :
      delete buf_c-chk-doc.
    end.
    for each tdlocb-c-chk-doc where tdlocb-c-chk-doc.out-code = p-doc-code
                          no-lock
    on error  undo, return error
    :
      create buf_c-chk-doc.
      buffer-copy tdlocb-c-chk-doc to buf_c-chk-doc.
    end.
    for each buf_c-chk-gds where buf_c-chk-gds.out-code = p-doc-code
    on error  undo, return error
    :
      delete buf_c-chk-gds.
    end.
    for each tdlocb-c-chk-gds where tdlocb-c-chk-gds.out-code = p-doc-code
                          no-lock
    on error  undo, return error
    :
      create buf_c-chk-gds.
      buffer-copy tdlocb-c-chk-gds to buf_c-chk-gds.
    end.
    for each tdlocb-chk-doc
    on error  undo, return error
    :
      delete tdlocb-chk-doc.
    end.
    for each tdlocb-chk-doc-attr
    on error  undo, return error
    :
      delete tdlocb-chk-doc-attr.
    end.
    for each tdlocb-chk-gds
    on error  undo, return error
    :
      delete tdlocb-chk-gds.
    end.
    for each tdlocb-chk-gds-attr
    on error  undo, return error
    :
      delete tdlocb-chk-gds-attr.
    end.
    for each tdlocb-marking-chk
    on error  undo, return error
    :
      delete tdlocb-marking-chk.
    end.
    for each tdlocb-c-chk-doc
    on error  undo, return error
    :
      delete tdlocb-c-chk-doc.
    end.
    for each tdlocb-c-chk-doc-attr
    on error  undo, return error
    :
      delete tdlocb-c-chk-doc-attr.
    end.
    for each tdlocb-c-chk-gds
    on error  undo, return error
    :
      delete tdlocb-c-chk-gds.
    end.
  end.
END PROCEDURE.
define temp-table wt-trn-doc no-undo like ub.trn-doc.
PROCEDURE proc-load-trn-doc:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-trn-doc. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-trn-doc. stop" )
  on endkey undo, return error substitute( "$proc-load-trn-doc. endkey" )
  :
    define buffer tb-trn-doc for ub.trn-doc.
    define variable compare-log as logical no-undo.
define variable vss-include-info177 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_doc-line                for ub.doc-line.
define buffer buf_doc-line-attr           for ub.doc-line-attr.
define buffer buf_inv-line                for ub.inv-line.
define buffer buf_doc-line-sum            for ub.doc-line-sum.
define buffer buf_inv-doc                 for ub.inv-doc.
define buffer buf_goods                   for ub.goods .
define buffer buf_trn-doc-sum             for ub.trn-doc-sum.
define buffer buf_gds-dtl                 for ub.gds-dtl.
define buffer buf_parts                   for ub.parts.
define buffer buf_marking-lines           for ub.marking-lines.
define buffer buf_gen-attr                for ub.gen-attr.
define buffer buf_doc-prts                for ub.doc-prts.
define buffer buf_doc-pl                  for ub.doc-pl.
define buffer buf_doc-pl-attr             for ub.doc-pl-attr.
define buffer buf_doc-pl-pump             for ub.doc-pl-pump.
define buffer buf_parts-attr              for ub.parts-attr.
define buffer buf_parts-supp              for ub.parts-supp.
define buffer buf_parts-root              for ub.parts-root.
define buffer buf_doc-attr                for ub.doc-attr.
define buffer buf_ord-chain               for ub.ord-chain.
define buffer buf_doc-fbr-gds             for ub.doc-fbr-gds.
define buffer buf_arh-trn-doc-contract    for ub.arh-trn-doc-contract.
define buffer buf-rc_arh-trn-doc-contract for ub.arh-trn-doc-contract.
define variable varrecalc-arh-trn-doc as logical no-undo.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
for each locb-doc-line
on error  undo, return error
:
  delete locb-doc-line.
end.
for each locb-doc-line-attr
on error  undo, return error
:
  delete locb-doc-line-attr.
end.
for each locb-inv-doc
on error  undo, return error
:
  delete locb-inv-doc.
end.
for each locb-trn-doc-sum
on error  undo, return error
:
  delete locb-trn-doc-sum.
end.
for each locb-inv-line
on error  undo, return error
:
  delete locb-inv-line.
end.
for each locb-doc-line-sum
on error  undo, return error
:
  delete locb-doc-line-sum.
end.
for each locb-gds-dtl
on error  undo, return error
:
  delete locb-gds-dtl.
end.
for each locb-parts
on error  undo, return error
:
  delete locb-parts.
end.
for each locb-parts-attr
on error  undo, return error
:
  delete locb-parts-attr.
end.
for each locb-parts-root
on error  undo, return error
:
  delete locb-parts-root.
end.
for each locb-parts-supp
on error  undo, return error
:
  delete locb-parts-supp.
end.
for each locb-doc-prts
on error  undo, return error
:
  delete locb-doc-prts.
end.
for each locb-doc-pl
on error  undo, return error
:
  delete locb-doc-pl.
end.
for each locb-doc-pl-pump
on error  undo, return error
:
  delete locb-doc-pl-pump.
end.
for each locbt-doc-attr
on error  undo, return error
:
  delete locbt-doc-attr.
end.
for each locb-ord-chain
on error  undo, return error
:
  delete locb-ord-chain.
end.
for each locb-doc-fbr-gds
on error  undo, return error
:
  delete locb-doc-fbr-gds.
end.
for each locb-arh-trn-doc-contract
on error undo, return error
:
  delete locb-arh-trn-doc-contract.
end.
for each locb-gen-attr
on error  undo, return error
:
  delete locb-gen-attr.
end.
for each locb-marking-lines
on error  undo, return error
:
  delete locb-marking-lines.
end.
    for each wt-trn-doc
    on error undo, return error substitute( "$proc-load-trn-doc(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-trn-doc .
    end.
    create wt-trn-doc.
    run nws-impl in p-imp-handle
      ( input 'trn-doc':U
       ,input (buffer wt-trn-doc:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-trn-doc
      where tb-trn-doc.doc-code = wt-trn-doc.doc-code
      exclusive-lock no-error.
define variable vss-include-info178 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do counter = 1 to l-counter
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
on endkey undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  define variable part-key-rec as character no-undo.
  CASE rec-name :
    when 'doc-line':U
    then do:
      create locb-doc-line.
run nws-impl in p-imp-handle
  ( input "doc-line":U
   ,input (buffer locb-doc-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when 'doc-line-attr':U
    then do:
      create locb-doc-line-attr.
run nws-impl in p-imp-handle
  ( input "doc-line-attr":U
   ,input (buffer locb-doc-line-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when 'inv-doc':U
    then do:
      create locb-inv-doc.
run nws-impl in p-imp-handle
  ( input "inv-doc":U
   ,input (buffer locb-inv-doc:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when 'trn-doc-sum':U
    then do:
      create locb-trn-doc-sum.
run nws-impl in p-imp-handle
  ( input "trn-doc-sum":U
   ,input (buffer locb-trn-doc-sum:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when 'inv-line':U
    then do:
      create locb-inv-line.
run nws-impl in p-imp-handle
  ( input "inv-line":U
   ,input (buffer locb-inv-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when 'doc-line-sum':U
    then do:
      create locb-doc-line-sum.
run nws-impl in p-imp-handle
  ( input "doc-line-sum":U
   ,input (buffer locb-doc-line-sum:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when 'gds-dtl':U
    then do:
      create locb-gds-dtl.
run nws-impl in p-imp-handle
  ( input "gds-dtl":U
   ,input (buffer locb-gds-dtl:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when 'parts':U
    then do:
      create locb-parts.
run nws-impl in p-imp-handle
  ( input "parts":U
   ,input (buffer locb-parts:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when 'parts-root':U
    then do:
      create locb-parts-root.
run nws-impl in p-imp-handle
  ( input "parts-root":U
   ,input (buffer locb-parts-root:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when 'parts-attr':U
    then do:
      create locb-parts-attr.
run nws-impl in p-imp-handle
  ( input "parts-attr":U
   ,input (buffer locb-parts-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when 'parts-supp':U
    then do:
      create locb-parts-supp.
run nws-impl in p-imp-handle
  ( input "parts-supp":U
   ,input (buffer locb-parts-supp:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when 'doc-prts':U
    then do:
      create locb-doc-prts.
run nws-impl in p-imp-handle
  ( input "doc-prts":U
   ,input (buffer locb-doc-prts:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when 'doc-pl':U
    then do:
      create locb-doc-pl.
run nws-impl in p-imp-handle
  ( input "doc-pl":U
   ,input (buffer locb-doc-pl:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when 'doc-pl-attr':U
    then do:
      create locb-doc-pl-attr.
run nws-impl in p-imp-handle
  ( input "doc-pl-attr":U
   ,input (buffer locb-doc-pl-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when 'doc-pl-pump':U
    then do:
      create locb-doc-pl-pump.
run nws-impl in p-imp-handle
  ( input "doc-pl-pump":U
   ,input (buffer locb-doc-pl-pump:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when 'doc-attr':U
    then do:
      create locbt-doc-attr.
run nws-impl in p-imp-handle
  ( input "doc-attr":U
   ,input (buffer locbt-doc-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when 'doc-fbr-gds':U
    then do:
      create locb-doc-fbr-gds.
run nws-impl in p-imp-handle
  ( input "doc-fbr-gds":U
   ,input (buffer locb-doc-fbr-gds:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when 'arh-trn-doc-contract':U
    then do:
      create locb-arh-trn-doc-contract.
run nws-impl in p-imp-handle
  ( input "arh-trn-doc-contract":U
   ,input (buffer locb-arh-trn-doc-contract:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "chk-doc" then do:
      create tdlocb-chk-doc.
run nws-impl in p-imp-handle
  ( input "chk-doc":U
   ,input (buffer tdlocb-chk-doc:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "chk-gds" then do:
      create tdlocb-chk-gds.
run nws-impl in p-imp-handle
  ( input "chk-gds":U
   ,input (buffer tdlocb-chk-gds:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "chk-gds-attr" then do:
      create tdlocb-chk-gds-attr.
run nws-impl in p-imp-handle
  ( input "chk-gds-attr":U
   ,input (buffer tdlocb-chk-gds-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "marking-chk" then do:
      create tdlocb-marking-chk.
run nws-impl in p-imp-handle
  ( input "marking-chk":U
   ,input (buffer tdlocb-marking-chk:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "chk-doc-attr" then do:
      create tdlocb-chk-doc-attr.
run nws-impl in p-imp-handle
  ( input "chk-doc-attr":U
   ,input (buffer tdlocb-chk-doc-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-chk-doc" then do:
      create tdlocb-c-chk-doc.
run nws-impl in p-imp-handle
  ( input "c-chk-doc":U
   ,input (buffer tdlocb-c-chk-doc:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-chk-gds" then do:
      create tdlocb-c-chk-gds.
run nws-impl in p-imp-handle
  ( input "c-chk-gds":U
   ,input (buffer tdlocb-c-chk-gds:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-chk-doc-attr" then do:
      create tdlocb-c-chk-doc-attr.
run nws-impl in p-imp-handle
  ( input "c-chk-doc-attr":U
   ,input (buffer tdlocb-c-chk-doc-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when 'ord-chain':U
    then do:
      create locb-ord-chain.
run nws-impl in p-imp-handle
  ( input "ord-chain":U
   ,input (buffer locb-ord-chain:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when 'gen-attr':U
    then do:
      create locb-gen-attr.
run nws-impl in p-imp-handle
  ( input "gen-attr":U
   ,input (buffer locb-gen-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when 'marking-lines':U
    then do:
      create locb-marking-lines.
run nws-impl in p-imp-handle
  ( input "marking-lines":U
   ,input (buffer locb-marking-lines:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message
        "nws/inc/imp/trn-doc.i: Не предусмотрен прием таблицы " rec-name skip
        "в составе накладной"
        view-as alert-box error.
      return error "nws/inc/imp/trn-doc.i: Не предусмотрен прием таблицы " + rec-name + chr(10) + "в составе накладной".
    end.
  END CASE.
end.
if not available tb-trn-doc
then do:
  create tb-trn-doc.
end.
else do:
  run trg/nwstdrs.p
    (input tb-trn-doc.doc-code
    ,input false
    ) no-error .
  if error-status :error
  then do:
    run write-to-log in this-procedure
      (input substitute("&1 &2", error-status :get-message(1), return-value)
      ) .
    undo, return error substitute("Ошибка при снятии резервов по документу &1", tb-trn-doc.doc-code) .
  end.
end.
define variable v-old-trn-doc-status as character no-undo .
define variable v-new-trn-doc-status as character no-undo .
define variable v-str                as character no-undo .
define variable par-type             as character no-undo .
define variable v-gds-code           as integer   no-undo .
if tb-trn-doc.status_ = ""
or tb-trn-doc.status_ = ?
then do:
  assign
    v-old-trn-doc-status = ""
  .
end.
else do:
  assign
    v-old-trn-doc-status = tb-trn-doc.status_ + string(tb-trn-doc.flag_, '+/-':u)
  .
end.
assign
  v-new-trn-doc-status = wt-trn-doc.status_ + string(wt-trn-doc.flag_, '+/-':u)
.
run trg/nwsdochs.p
  (input g#db-num
  ,input 'update':U
  ,input wt-trn-doc.doc-code
  ,input wt-trn-doc.obj-type
  ,input wt-trn-doc.obj-code
  ,input 'trn-doc':U
  ,input wt-trn-doc.ext-doc-type
  ,input wt-trn-doc.fact-date
  ,input wt-trn-doc.fact-qnty
  ,input wt-trn-doc.fact-base
  ,input wt-trn-doc.fact-rubl
  ,input 0
  ,input v-old-trn-doc-status
  ,input v-new-trn-doc-status
  ,input g#news-source-db
  ,input p-pck-num
  ,input wt-trn-doc.user-db-num
  ,input wt-trn-doc.user-name
  ,input wt-trn-doc.sys-date
  ,input wt-trn-doc.sys-time
  ,input wt-trn-doc.sys-time-int
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.
buffer-copy wt-trn-doc to tb-trn-doc .
for each buf_inv-line exclusive-lock
  where buf_inv-line.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete buf_inv-line.
end.
for each locb-inv-line no-lock
  where locb-inv-line.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  create buf_inv-line.
  buffer-copy locb-inv-line to buf_inv-line.
end.
for each buf_doc-line-sum exclusive-lock
  where buf_doc-line-sum.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete buf_doc-line-sum.
end.
for each locb-doc-line-sum no-lock
  where locb-doc-line-sum.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  create buf_doc-line-sum.
  buffer-copy locb-doc-line-sum to buf_doc-line-sum.
end.
for each buf_inv-doc exclusive-lock
  where buf_inv-doc.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete buf_inv-doc.
end.
for each locb-inv-doc no-lock
  where locb-inv-doc.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  create buf_inv-doc.
  buffer-copy locb-inv-doc to buf_inv-doc.
end.
for each buf_trn-doc-sum exclusive-lock
  where buf_trn-doc-sum.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete buf_trn-doc-sum.
end.
for each locb-trn-doc-sum no-lock
  where locb-trn-doc-sum.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  create buf_trn-doc-sum.
  buffer-copy locb-trn-doc-sum to buf_trn-doc-sum.
end.
for each buf_gds-dtl exclusive-lock
  where buf_gds-dtl.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete buf_gds-dtl.
end.
for each locb-gds-dtl no-lock
  where locb-gds-dtl.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  create buf_gds-dtl.
  buffer-copy locb-gds-dtl to buf_gds-dtl.
end.
on delete of ub.doc-line override do: end.
for each buf_doc-line exclusive-lock
  where buf_doc-line.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete buf_doc-line.
end.
for each locb-doc-line no-lock
  where locb-doc-line.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  create buf_doc-line.
  buffer-copy locb-doc-line to buf_doc-line.
end.
on delete of ub.ord-chain override do: end.
for each buf_ord-chain exclusive-lock
  where buf_ord-chain.rel-doc-code = wt-trn-doc.doc-code
    and buf_ord-chain.rel-doc-type = 'trn'
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete buf_ord-chain.
end.
for each locb-ord-chain no-lock
  where locb-ord-chain.rel-doc-code = wt-trn-doc.doc-code
    and locb-ord-chain.rel-doc-type = 'trn'
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
    find first buf_ord-chain exclusive-lock
      where buf_ord-chain.rel-id = locb-ord-chain.rel-id
        and buf_ord-chain.db-num = locb-ord-chain.db-num
      no-error.
    if available buf_ord-chain then do:
       assign
         buf_ord-chain.rel-id = locb-ord-chain.rel-id * (-1)
       .
    end.
  create buf_ord-chain.
  buffer-copy locb-ord-chain to buf_ord-chain .
end.
for each locb-parts-attr no-lock
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  find buf_parts-attr no-lock
    where buf_parts-attr.in-code   = locb-parts-attr.in-code
      and buf_parts-attr.gds-code  = locb-parts-attr.gds-code
      and buf_parts-attr.part-code = locb-parts-attr.part-code
    no-error .
  if not available buf_parts-attr
  then do:
    find first buf_goods no-lock
      where buf_goods.gds-code = locb-parts-attr.gds-code
      .
    for each buf_parts exclusive-lock
      where buf_parts.in-code   = locb-parts-attr.in-code
        and buf_parts.artic     = buf_goods.artic
        and buf_parts.prod-type = buf_goods.prod-type
        and buf_parts.prod-code = buf_goods.prod-code
        and buf_parts.prt-code = locb-parts-attr.prt-code
        and buf_parts.part-code = locb-parts-attr.part-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
    :
      if buf_parts.contract-code <> locb-parts-attr.contract-code
      then do:
        assign
          buf_parts.contract-code = locb-parts-attr.contract-code
        .
      end.
    end.
    create buf_parts-attr .
    buffer-copy locb-parts-attr to buf_parts-attr .
  end.
end.
for each buf_parts exclusive-lock
  where buf_parts.out-code = wt-trn-doc.doc-code
    and buf_parts.obj-code = wt-trn-doc.obj-code
    and buf_parts.obj-type = wt-trn-doc.obj-type
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                    ,input (buffer buf_parts:handle)
                                    ,output part-key-rec).
  for each buf_gen-attr exclusive-lock
    where buf_gen-attr.p-key = part-key-rec
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    delete buf_gen-attr.
  end.
  delete buf_parts .
end.
for each buf_marking-lines where
      buf_marking-lines.obj-type = wt-trn-doc.obj-type
  and buf_marking-lines.obj-code = wt-trn-doc.obj-code
  and buf_marking-lines.out-code = wt-trn-doc.doc-code
on error undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
  delete buf_marking-lines.
end.
for each locb-parts no-lock
  where locb-parts.out-code = wt-trn-doc.doc-code
    and locb-parts.obj-code = wt-trn-doc.obj-code
    and locb-parts.obj-type = wt-trn-doc.obj-type
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
define variable vss-include-info179 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  locb-parts.artic
  ,input  locb-parts.prod-type
  ,input  locb-parts.prod-code
  ,output v-gds-code
  )  .
  find first buf_parts-attr no-lock
    where buf_parts-attr.in-code   = locb-parts.in-code
      and buf_parts-attr.gds-code  = v-gds-code
      and buf_parts-attr.part-code = locb-parts.part-code
    no-error .
  if available buf_parts-attr
    and locb-parts.contract-code <> buf_parts-attr.contract-code
  then do:
    assign
      varrecalc-arh-trn-doc    = yes
      locb-parts.contract-code = buf_parts-attr.contract-code
    .
  end.
  else do:
    assign
      varrecalc-arh-trn-doc = no
    .
  end.
  create buf_parts .
  buffer-copy locb-parts to buf_parts
  assign
    buf_parts.status_   = yes
    buf_parts.rsrv-free = ?
  .
  run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                    ,input (buffer buf_parts:handle)
                                    ,output part-key-rec).
  for each locb-gen-attr no-lock
    where locb-gen-attr.p-key = part-key-rec
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    create buf_gen-attr.
    buffer-copy locb-gen-attr to buf_gen-attr.
  end.
  for each locb-marking-lines where
        locb-marking-lines.obj-type = buf_parts.obj-type
    and locb-marking-lines.obj-code = buf_parts.obj-code
    and locb-marking-lines.in-code = buf_parts.in-code
    and locb-marking-lines.out-code = buf_parts.out-code
    and locb-marking-lines.part-code = buf_parts.part-code
    and locb-marking-lines.prt-code = buf_parts.prt-code
    and locb-marking-lines.gds-code = v-gds-code
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    create buf_marking-lines.
    buffer-copy locb-marking-lines to buf_marking-lines.
  end.
end.
for each buf_doc-prts exclusive-lock
  where buf_doc-prts.out-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete buf_doc-prts.
end.
for each locb-doc-prts no-lock
  where locb-doc-prts.out-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  create buf_doc-prts.
  buffer-copy locb-doc-prts to buf_doc-prts.
end.
for each buf_doc-pl exclusive-lock
  where buf_doc-pl.out-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete buf_doc-pl.
end.
for each locb-doc-pl no-lock
  where locb-doc-pl.out-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  create buf_doc-pl.
  buffer-copy locb-doc-pl to buf_doc-pl.
end.
for each buf_doc-pl-attr exclusive-lock
  where buf_doc-pl-attr.out-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete buf_doc-pl-attr.
end.
for each locb-doc-pl-attr no-lock
  where locb-doc-pl-attr.out-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  create buf_doc-pl-attr.
  buffer-copy locb-doc-pl-attr to buf_doc-pl-attr.
end.
for each buf_doc-pl-pump exclusive-lock
  where buf_doc-pl-pump.obj-type = wt-trn-doc.obj-type
    and buf_doc-pl-pump.obj-code = wt-trn-doc.obj-code
    and buf_doc-pl-pump.out-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete buf_doc-pl-pump.
end.
for each locb-doc-pl-pump no-lock
  where locb-doc-pl-pump.obj-type = wt-trn-doc.obj-type
    and locb-doc-pl-pump.obj-code = wt-trn-doc.obj-code
    and locb-doc-pl-pump.out-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  create buf_doc-pl-pump.
  buffer-copy locb-doc-pl-pump to buf_doc-pl-pump.
end.
for each buf_doc-line-attr exclusive-lock
  where buf_doc-line-attr.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete buf_doc-line-attr.
end.
for each locb-doc-line-attr no-lock
  where locb-doc-line-attr.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  create buf_doc-line-attr.
  buffer-copy locb-doc-line-attr to buf_doc-line-attr.
end.
for each buf_parts-root exclusive-lock
  where buf_parts-root.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete buf_parts-root.
end.
for each locb-parts-root no-lock
  where locb-parts-root.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  create buf_parts-root.
  buffer-copy locb-parts-root to buf_parts-root.
end.
for each locb-parts-supp no-lock
  where locb-parts-supp.in-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  find buf_parts-supp no-lock
    where buf_parts-supp.in-code   = locb-parts-supp.in-code
      and buf_parts-supp.artic     = locb-parts-supp.artic
      and buf_parts-supp.prod-type = locb-parts-supp.prod-type
      and buf_parts-supp.prod-code = locb-parts-supp.prod-code
      and buf_parts-supp.part-code = locb-parts-supp.part-code
    no-error.
  if not available buf_parts-supp then do:
    create buf_parts-supp.
    buffer-copy locb-parts-supp to buf_parts-supp.
  end.
end.
for each buf_doc-attr exclusive-lock
  where buf_doc-attr.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete buf_doc-attr.
end.
for each locbt-doc-attr no-lock
  where locbt-doc-attr.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  create buf_doc-attr.
  buffer-copy locbt-doc-attr to buf_doc-attr.
end.
for each buf_doc-fbr-gds exclusive-lock
  where buf_doc-fbr-gds.out-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete buf_doc-fbr-gds.
end.
for each locb-doc-fbr-gds no-lock
  where locb-doc-fbr-gds.out-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  create buf_doc-fbr-gds.
  buffer-copy locb-doc-fbr-gds to buf_doc-fbr-gds.
end.
for each buf_arh-trn-doc-contract exclusive-lock
  where buf_arh-trn-doc-contract.doc-code  = wt-trn-doc.doc-code
on error undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete buf_arh-trn-doc-contract.
end.
for each locb-arh-trn-doc-contract no-lock
  where locb-arh-trn-doc-contract.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  for each buf-rc_arh-trn-doc-contract exclusive-lock
    where buf-rc_arh-trn-doc-contract.host-code     = locb-arh-trn-doc-contract.host-code
      and buf-rc_arh-trn-doc-contract.contract-code = locb-arh-trn-doc-contract.contract-code
      and buf-rc_arh-trn-doc-contract.cli-type      = locb-arh-trn-doc-contract.cli-type
      and buf-rc_arh-trn-doc-contract.cli-code      = locb-arh-trn-doc-contract.cli-code
      and buf-rc_arh-trn-doc-contract.obj-type      = locb-arh-trn-doc-contract.obj-type
      and buf-rc_arh-trn-doc-contract.obj-code      = locb-arh-trn-doc-contract.obj-code
      and buf-rc_arh-trn-doc-contract.ext-doc-type  = locb-arh-trn-doc-contract.ext-doc-type
      and buf-rc_arh-trn-doc-contract.sum-type      = locb-arh-trn-doc-contract.sum-type
      and buf-rc_arh-trn-doc-contract.fact-order    > locb-arh-trn-doc-contract.fact-order
  on error undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    delete buf-rc_arh-trn-doc-contract.
  end.
end.
if varrecalc-arh-trn-doc = no then do:
  for each locb-arh-trn-doc-contract no-lock
    where locb-arh-trn-doc-contract.doc-code = wt-trn-doc.doc-code
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    for each locb-rc-arh-trn-doc-contract no-lock
      where locb-rc-arh-trn-doc-contract.host-code     = locb-arh-trn-doc-contract.host-code
        and locb-rc-arh-trn-doc-contract.contract-code = locb-arh-trn-doc-contract.contract-code
        and locb-rc-arh-trn-doc-contract.cli-type      = locb-arh-trn-doc-contract.cli-type
        and locb-rc-arh-trn-doc-contract.cli-code      = locb-arh-trn-doc-contract.cli-code
        and locb-rc-arh-trn-doc-contract.obj-type      = locb-arh-trn-doc-contract.obj-type
        and locb-rc-arh-trn-doc-contract.obj-code      = locb-arh-trn-doc-contract.obj-code
        and locb-rc-arh-trn-doc-contract.ext-doc-type  = locb-arh-trn-doc-contract.ext-doc-type
        and locb-rc-arh-trn-doc-contract.sum-type      = locb-arh-trn-doc-contract.sum-type
        and locb-rc-arh-trn-doc-contract.fact-order    > locb-arh-trn-doc-contract.fact-order
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
    :
      create buf-rc_arh-trn-doc-contract.
      buffer-copy locb-rc-arh-trn-doc-contract to buf-rc_arh-trn-doc-contract.
    end.
    create buf_arh-trn-doc-contract.
    buffer-copy locb-arh-trn-doc-contract to buf_arh-trn-doc-contract.
  end.
end.
else do:
  if wt-trn-doc.status_ = 'факт':U then do:
    run clntattr-value in p-imp-handle
      ( input wt-trn-doc.obj-type
       ,input wt-trn-doc.obj-code
       ,input  'arh-trn-doc-contract':U
       ,output v-str
       ,output par-type
      ) no-error .
    if error-status:error or v-str = "no" then do:
      run clntattr-write in p-imp-handle
        ( input wt-trn-doc.obj-type
         ,input wt-trn-doc.obj-code
         ,input 'arh-trn-doc-contract':U
         ,input "yes":u
        ).
    end.
  end.
end.
run proc-load-trn-doc-inv-chk in this-procedure
  ( input tb-trn-doc.doc-code
  ) no-error.
if error-status :error
then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error substitute("Ошибка при обработке чеков инвентаризации по документу &1", tb-trn-doc.doc-code) .
end.
run trg/nwstdrs.p
  (input tb-trn-doc.doc-code
  ,input true
  ) no-error .
if error-status :error
then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error substitute("Ошибка при резервировании по документу &1", tb-trn-doc.doc-code) .
end.
if g#db-num = 0
and (tb-trn-doc.ext-doc-type = 're':U OR
     tb-trn-doc.ext-doc-type = 'ee':U)
     and tb-trn-doc.d-card       <> ""
     and tb-trn-doc.d-card       <> ?
     and tb-trn-doc.status_ = 'факт':U
then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input tb-trn-doc.doc-code ,
                       input 'need-saledc':U ,
                       input string(1) )  .
end.
if tb-trn-doc.ext-doc-type = 'iv':U and
   tb-trn-doc.status_      = 'запрос':U and
   tb-trn-doc.flag_        = true
then do:
  run cus/ord-mrz.p ( ? , recid(tb-trn-doc)) no-error .
end.
for each locb-doc-line
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete locb-doc-line.
end.
for each locb-ord-chain
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete locb-ord-chain.
end.
for each locb-doc-line-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete locb-doc-line-attr.
end.
for each locb-inv-doc
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete locb-inv-doc.
end.
for each locb-trn-doc-sum
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete locb-trn-doc-sum.
end.
for each locb-inv-line
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete locb-inv-line.
end.
for each locb-doc-line-sum
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete locb-doc-line-sum.
end.
for each locb-gds-dtl
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete locb-gds-dtl.
end.
for each locb-parts
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete locb-parts.
end.
for each locb-parts-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete locb-parts-attr.
end.
for each locb-parts-root
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete locb-parts-root.
end.
for each locb-parts-supp
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete locb-parts-supp.
end.
for each locb-doc-prts
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete locb-doc-prts.
end.
for each locb-doc-pl
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete locb-doc-pl.
end.
for each locb-doc-pl-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete locb-doc-pl-attr.
end.
for each locb-doc-pl-pump
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete locb-doc-pl-pump.
end.
for each locbt-doc-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete locbt-doc-attr.
end.
for each locb-doc-fbr-gds
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete locb-doc-fbr-gds.
end.
for each locb-arh-trn-doc-contract
on error undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete locb-arh-trn-doc-contract.
end.
for each locb-gen-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete locb-gen-attr.
end.
for each locb-marking-lines
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info178, return-value, chr(10), error-status :get-message ( 1 ) )
:
  delete locb-marking-lines.
end.
    delete wt-trn-doc.
  end.
END PROCEDURE.
define temp-table locb-c-doc-line      no-undo like ub.c-doc-line.
define temp-table locb-c-doc-line-attr no-undo like ub.c-doc-line-attr.
define temp-table locb-c-gds-dtl       no-undo like ub.c-gds-dtl.
define temp-table locb-c-parts         no-undo like ub.c-parts.
define temp-table locb-c-doc-prts      no-undo like ub.c-doc-prts.
define temp-table locb-c-doc-pl        no-undo like ub.c-doc-pl.
define temp-table locb-c-doc-pl-pump   no-undo like ub.c-doc-pl-pump.
define temp-table locb-c-parts-attr    no-undo like ub.c-parts-attr.
define temp-table locb-c-parts-root    no-undo like ub.c-parts-root.
define temp-table locbt-c-doc-attr     no-undo like ub.c-doc-attr.
define temp-table locb-c-doc-fbr-gds   no-undo like ub.c-doc-fbr-gds.
define temp-table wt-c-trn-doc no-undo like ub.c-trn-doc.
PROCEDURE proc-load-c-trn-doc:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-c-trn-doc. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-c-trn-doc. stop" )
  on endkey undo, return error substitute( "$proc-load-c-trn-doc. endkey" )
  :
    define buffer tb-c-trn-doc for ub.c-trn-doc.
    define variable compare-log as logical no-undo.
define variable vss-include-info180 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_c-doc-line      for ub.c-doc-line.
define buffer buf_c-doc-line-attr for ub.c-doc-line-attr.
define buffer buf_c-gds-dtl       for ub.c-gds-dtl.
define buffer buf_c-parts         for ub.c-parts.
define buffer buf_c-doc-prts      for ub.c-doc-prts.
define buffer buf_c-doc-pl        for ub.c-doc-pl.
define buffer buf_c-doc-pl-pump   for ub.c-doc-pl-pump.
define buffer buf_c-parts-attr    for ub.c-parts-attr.
define buffer buf_c-parts-root    for ub.c-parts-root.
define buffer buf_c-doc-attr      for ub.c-doc-attr.
define buffer buf_c-doc-fbr-gds   for ub.doc-fbr-gds.
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-c-doc-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-line.
end.
for each locb-c-doc-line-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-line-attr.
end.
for each locb-c-gds-dtl
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-gds-dtl.
end.
for each locb-c-parts
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-parts.
end.
for each locb-c-parts-root
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-parts-root.
end.
for each locb-c-parts-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-parts-attr.
end.
for each locb-c-doc-prts
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-prts.
end.
for each locb-c-doc-pl
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-pl.
end.
for each locb-c-doc-pl-pump
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-pl-pump.
end.
for each locbt-c-doc-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbt-c-doc-attr.
end.
for each locb-c-doc-fbr-gds
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-fbr-gds.
end.
    for each wt-c-trn-doc
    on error undo, return error substitute( "$proc-load-c-trn-doc(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-c-trn-doc .
    end.
    create wt-c-trn-doc.
    run nws-impl in p-imp-handle
      ( input 'c-trn-doc':U
       ,input (buffer wt-c-trn-doc:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-c-trn-doc
      where tb-c-trn-doc.doc-code = wt-c-trn-doc.doc-code
        and tb-c-trn-doc.corr-user-db-num = wt-c-trn-doc.corr-user-db-num
        and tb-c-trn-doc.chip-num = wt-c-trn-doc.chip-num
      exclusive-lock no-error.
define variable vss-include-info181 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "c-doc-line" then do:
      create locb-c-doc-line.
run nws-impl in p-imp-handle
  ( input "c-doc-line":U
   ,input (buffer locb-c-doc-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-doc-line-attr" then do:
      create locb-c-doc-line-attr.
run nws-impl in p-imp-handle
  ( input "c-doc-line-attr":U
   ,input (buffer locb-c-doc-line-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-gds-dtl" then do:
      create locb-c-gds-dtl.
run nws-impl in p-imp-handle
  ( input "c-gds-dtl":U
   ,input (buffer locb-c-gds-dtl:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-parts" then do:
      create locb-c-parts.
run nws-impl in p-imp-handle
  ( input "c-parts":U
   ,input (buffer locb-c-parts:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-parts-attr" then do:
      create locb-c-parts-attr.
run nws-impl in p-imp-handle
  ( input "c-parts-attr":U
   ,input (buffer locb-c-parts-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-parts-root" then do:
      create locb-c-parts-root.
run nws-impl in p-imp-handle
  ( input "c-parts-root":U
   ,input (buffer locb-c-parts-root:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-doc-prts" then do:
      create locb-c-doc-prts.
run nws-impl in p-imp-handle
  ( input "c-doc-prts":U
   ,input (buffer locb-c-doc-prts:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-doc-pl" then do:
      create locb-c-doc-pl.
run nws-impl in p-imp-handle
  ( input "c-doc-pl":U
   ,input (buffer locb-c-doc-pl:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-doc-pl-pump" then do:
      create locb-c-doc-pl-pump.
run nws-impl in p-imp-handle
  ( input "c-doc-pl-pump":U
   ,input (buffer locb-c-doc-pl-pump:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-doc-attr" then do:
      create locbt-c-doc-attr.
run nws-impl in p-imp-handle
  ( input "c-doc-attr":U
   ,input (buffer locbt-c-doc-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-doc-fbr-gds" then do:
      create locb-c-doc-fbr-gds.
run nws-impl in p-imp-handle
  ( input "c-doc-fbr-gds":U
   ,input (buffer locb-c-doc-fbr-gds:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "nws/inc/imp/c-trn-do.i: Не предусмотрен прием таблицы " rec-name skip
              "в составе накладной"
              view-as alert-box error.
      return error "nws/inc/imp/c-trn-do.i: Не предусмотрен прием таблицы " + rec-name + chr(10) + "в составе накладной".
    end.
  END CASE.
end.
if not available tb-c-trn-doc then do:
  create tb-c-trn-doc.
end.
buffer-copy wt-c-trn-doc to tb-c-trn-doc.
for each buf_c-gds-dtl where buf_c-gds-dtl.doc-code = wt-c-trn-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-gds-dtl.
end.
for each locb-c-gds-dtl where locb-c-gds-dtl.doc-code = wt-c-trn-doc.doc-code
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-gds-dtl.
  buffer-copy locb-c-gds-dtl to buf_c-gds-dtl.
end.
on delete of ub.c-doc-line override do: end.
for each buf_c-doc-line where buf_c-doc-line.doc-code = wt-c-trn-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-doc-line.
end.
for each locb-c-doc-line where locb-c-doc-line.doc-code = wt-c-trn-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-doc-line.
  buffer-copy locb-c-doc-line to buf_c-doc-line.
end.
for each buf_c-parts where buf_c-parts.out-code = wt-c-trn-doc.doc-code
                       and buf_c-parts.obj-code = wt-c-trn-doc.obj-code
                       and buf_c-parts.obj-type = wt-c-trn-doc.obj-type
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-parts.
end.
for each locb-c-parts where locb-c-parts.out-code = wt-c-trn-doc.doc-code
                        and locb-c-parts.obj-code = wt-c-trn-doc.obj-code
                        and locb-c-parts.obj-type = wt-c-trn-doc.obj-type
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-parts.
  buffer-copy locb-c-parts to buf_c-parts
    assign
      buf_c-parts.status_   = no
      buf_c-parts.rsrv-free = ?
    .
end.
for each buf_c-doc-prts where buf_c-doc-prts.out-code = wt-c-trn-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-doc-prts.
end.
for each locb-c-doc-prts where locb-c-doc-prts.out-code = wt-c-trn-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-doc-prts.
  buffer-copy locb-c-doc-prts to buf_c-doc-prts.
end.
for each buf_c-doc-pl where buf_c-doc-pl.out-code = wt-c-trn-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-doc-pl.
end.
for each locb-c-doc-pl where locb-c-doc-pl.out-code = wt-c-trn-doc.doc-code
                     no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-doc-pl.
  buffer-copy locb-c-doc-pl to buf_c-doc-pl.
end.
for each buf_c-doc-pl-pump where buf_c-doc-pl-pump.obj-type = wt-c-trn-doc.obj-type
                             and buf_c-doc-pl-pump.obj-code = wt-c-trn-doc.obj-code
                             and buf_c-doc-pl-pump.out-code = wt-c-trn-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-doc-pl-pump.
end.
for each locb-c-doc-pl-pump  where locb-c-doc-pl-pump.obj-type = wt-c-trn-doc.obj-type
                               and locb-c-doc-pl-pump.obj-code = wt-c-trn-doc.obj-code
                               and locb-c-doc-pl-pump.out-code = wt-c-trn-doc.doc-code
                             no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-doc-pl-pump.
  buffer-copy locb-c-doc-pl-pump to buf_c-doc-pl-pump.
end.
for each buf_c-doc-line-attr where buf_c-doc-line-attr.doc-code = wt-c-trn-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-doc-line-attr.
end.
for each locb-c-doc-line-attr where locb-c-doc-line-attr.doc-code = wt-c-trn-doc.doc-code
                            no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-doc-line-attr.
  buffer-copy locb-c-doc-line-attr to buf_c-doc-line-attr.
end.
for each locb-c-parts-attr where locb-c-parts-attr.in-code = wt-c-trn-doc.doc-code
                         no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  find buf_c-parts-attr no-lock
    where buf_c-parts-attr.chip-num  = locb-c-parts-attr.chip-num
      and buf_c-parts-attr.in-code   = locb-c-parts-attr.in-code
      and buf_c-parts-attr.gds-code  = locb-c-parts-attr.gds-code
      and buf_c-parts-attr.part-code = locb-c-parts-attr.part-code
    no-error .
  if not available buf_c-parts-attr
  then do:
    create buf_c-parts-attr.
    buffer-copy locb-c-parts-attr to buf_c-parts-attr.
  end.
end.
for each buf_c-parts-root where buf_c-parts-root.doc-code = wt-c-trn-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-parts-root.
end.
for each locb-c-parts-root where locb-c-parts-root.doc-code = wt-c-trn-doc.doc-code
                            no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-parts-root.
  buffer-copy locb-c-parts-root to buf_c-parts-root.
end.
for each buf_c-doc-attr where buf_c-doc-attr.doc-code = wt-c-trn-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-doc-attr.
end.
for each locbt-c-doc-attr where locbt-c-doc-attr.doc-code = wt-c-trn-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-doc-attr.
  buffer-copy locbt-c-doc-attr to buf_c-doc-attr.
end.
for each buf_c-doc-fbr-gds where buf_c-doc-fbr-gds.out-code = wt-c-trn-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-doc-fbr-gds.
end.
for each locb-c-doc-fbr-gds where locb-c-doc-fbr-gds.out-code = wt-c-trn-doc.doc-code
                     no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-doc-fbr-gds.
  buffer-copy locb-c-doc-fbr-gds to buf_c-doc-fbr-gds.
end.
for each locb-c-doc-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-line.
end.
for each locb-c-doc-line-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-line-attr.
end.
for each locb-c-gds-dtl
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-gds-dtl.
end.
for each locb-c-parts
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-parts.
end.
for each locb-c-parts-root
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-parts-root.
end.
for each locb-c-parts-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-parts-attr.
end.
for each locb-c-doc-prts
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-prts.
end.
for each locb-c-doc-pl
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-pl.
end.
for each locb-c-doc-pl-pump
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-pl-pump.
end.
for each locbt-c-doc-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbt-c-doc-attr.
end.
for each locb-c-doc-fbr-gds
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-fbr-gds.
end.
    delete wt-c-trn-doc.
  end.
END PROCEDURE.
define temp-table locb-turnover-buyer-main      no-undo like  ub.turnover-buyer-main      .
define temp-table locb-turnover-buyer           no-undo like  ub.turnover-buyer           .
define temp-table locb-turnover-buyer-gds       no-undo like  ub.turnover-buyer-gds       .
define temp-table locb-turnover-buyer-attr      no-undo like  ub.turnover-buyer-attr      .
define temp-table locb-turnover-buyer-gds-attr  no-undo like  ub.turnover-buyer-gds-attr  .
define temp-table wt-turnover-buyer-main no-undo like ub.turnover-buyer-main.
PROCEDURE proc-load-turnover-buyer-main:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-turnover-buyer-main. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-turnover-buyer-main. stop" )
  on endkey undo, return error substitute( "$proc-load-turnover-buyer-main. endkey" )
  :
    define buffer tb-turnover-buyer-main for ub.turnover-buyer-main.
    define variable compare-log as logical no-undo.
define variable vss-include-info182 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_turnover-buyer-main       for ub.turnover-buyer-main      .
define buffer buf_turnover-buyer            for ub.turnover-buyer           .
define buffer buf_turnover-buyer-gds        for ub.turnover-buyer-gds       .
define buffer buf_turnover-buyer-attr       for ub.turnover-buyer-attr      .
define buffer buf_turnover-buyer-gds-attr   for ub.turnover-buyer-gds-attr  .
define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.
for each locb-turnover-buyer-main
on error  undo, return error
:
  delete locb-turnover-buyer-main.
end.
for each locb-turnover-buyer
on error  undo, return error
:
  delete locb-turnover-buyer.
end.
for each locb-turnover-buyer-gds
on error  undo, return error
:
  delete locb-turnover-buyer-gds.
end.
for each locb-turnover-buyer-gds-attr
on error  undo, return error
:
  delete locb-turnover-buyer-gds-attr.
end.
for each locb-turnover-buyer-attr
on error  undo, return error
:
  delete locb-turnover-buyer-attr.
end.
    for each wt-turnover-buyer-main
    on error undo, return error substitute( "$proc-load-turnover-buyer-main(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-turnover-buyer-main .
    end.
    create wt-turnover-buyer-main.
    run nws-impl in p-imp-handle
      ( input 'turnover-buyer-main':U
       ,input (buffer wt-turnover-buyer-main:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-turnover-buyer-main
      where tb-turnover-buyer-main.cli-type = wt-turnover-buyer-main.cli-type
        and tb-turnover-buyer-main.cli-code = wt-turnover-buyer-main.cli-code
        and tb-turnover-buyer-main.obj-type = wt-turnover-buyer-main.obj-type
        and tb-turnover-buyer-main.obj-code = wt-turnover-buyer-main.obj-code
      exclusive-lock no-error.
define variable vss-include-info183 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "turnover-buyer" then do:
      create locb-turnover-buyer.
run nws-impl in p-imp-handle
  ( input "turnover-buyer":U
   ,input (buffer locb-turnover-buyer:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "turnover-buyer-gds" then do:
      create locb-turnover-buyer-gds.
run nws-impl in p-imp-handle
  ( input "turnover-buyer-gds":U
   ,input (buffer locb-turnover-buyer-gds:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "turnover-buyer-gds-attr" then do:
      create locb-turnover-buyer-gds-attr.
run nws-impl in p-imp-handle
  ( input "turnover-buyer-gds-attr":U
   ,input (buffer locb-turnover-buyer-gds-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "turnover-buyer-attr" then do:
      create locb-turnover-buyer-attr.
run nws-impl in p-imp-handle
  ( input "turnover-buyer-attr":U
   ,input (buffer locb-turnover-buyer-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_turnover-buyer-gds where buf_turnover-buyer-gds.cli-code = wt-turnover-buyer-main.cli-code
                            and buf_turnover-buyer-gds.cli-type = wt-turnover-buyer-main.cli-type
                            and buf_turnover-buyer-gds.obj-type = wt-turnover-buyer-main.obj-type
                            and buf_turnover-buyer-gds.obj-code = wt-turnover-buyer-main.obj-code
on error  undo, return error
:
  delete buf_turnover-buyer-gds.
end.
for each locb-turnover-buyer-gds where locb-turnover-buyer-gds.cli-code     = wt-turnover-buyer-main.cli-code
                             and locb-turnover-buyer-gds.cli-type = wt-turnover-buyer-main.cli-type
                             and locb-turnover-buyer-gds.obj-type = wt-turnover-buyer-main.obj-type
                             and locb-turnover-buyer-gds.obj-code = wt-turnover-buyer-main.obj-code
  no-lock
on error  undo, return error
:
  create buf_turnover-buyer-gds.
  buffer-copy  locb-turnover-buyer-gds to buf_turnover-buyer-gds.
end.
for each buf_turnover-buyer-gds-attr where buf_turnover-buyer-gds-attr.cli-code = wt-turnover-buyer-main.cli-code
                            and buf_turnover-buyer-gds-attr.cli-type = wt-turnover-buyer-main.cli-type
                            and buf_turnover-buyer-gds-attr.obj-type = wt-turnover-buyer-main.obj-type
                            and buf_turnover-buyer-gds-attr.obj-code = wt-turnover-buyer-main.obj-code
on error  undo, return error
:
  delete buf_turnover-buyer-gds-attr.
end.
for each locb-turnover-buyer-gds-attr where locb-turnover-buyer-gds-attr.cli-code     = wt-turnover-buyer-main.cli-code
                             and locb-turnover-buyer-gds-attr.cli-type = wt-turnover-buyer-main.cli-type
                             and locb-turnover-buyer-gds-attr.obj-type = wt-turnover-buyer-main.obj-type
                             and locb-turnover-buyer-gds-attr.obj-code = wt-turnover-buyer-main.obj-code
  no-lock
on error  undo, return error
:
  create buf_turnover-buyer-gds-attr.
  buffer-copy  locb-turnover-buyer-gds-attr to buf_turnover-buyer-gds-attr.
end.
for each buf_turnover-buyer-attr where buf_turnover-buyer-attr.cli-code     = wt-turnover-buyer-main.cli-code
                                  and buf_turnover-buyer-attr.cli-type = wt-turnover-buyer-main.cli-type
                                  and buf_turnover-buyer-attr.obj-type = wt-turnover-buyer-main.obj-type
                                  and buf_turnover-buyer-attr.obj-code = wt-turnover-buyer-main.obj-code
on error  undo, return error
:
  delete buf_turnover-buyer-attr.
end.
for each locb-turnover-buyer-attr where locb-turnover-buyer-attr.cli-code     = wt-turnover-buyer-main.cli-code
                                    and locb-turnover-buyer-attr.cli-type = wt-turnover-buyer-main.cli-type
                                    and locb-turnover-buyer-attr.obj-type = wt-turnover-buyer-main.obj-type
                                    and locb-turnover-buyer-attr.obj-code = wt-turnover-buyer-main.obj-code
no-lock
on error  undo, return error
:
  create buf_turnover-buyer-attr.
  buffer-copy locb-turnover-buyer-attr to buf_turnover-buyer-attr.
end.
for each buf_turnover-buyer where buf_turnover-buyer.cli-code = wt-turnover-buyer-main.cli-code
                              and buf_turnover-buyer.cli-type = wt-turnover-buyer-main.cli-type
                              and buf_turnover-buyer.obj-type = wt-turnover-buyer-main.obj-type
                              and buf_turnover-buyer.obj-code = wt-turnover-buyer-main.obj-code
on error  undo, return error
:
  delete buf_turnover-buyer.
end.
for each locb-turnover-buyer where locb-turnover-buyer.cli-code = wt-turnover-buyer-main.cli-code
                                    and locb-turnover-buyer.cli-type = wt-turnover-buyer-main.cli-type
                                    and locb-turnover-buyer.obj-type = wt-turnover-buyer-main.obj-type
                                    and locb-turnover-buyer.obj-code = wt-turnover-buyer-main.obj-code
no-lock
on error  undo, return error
:
  create buf_turnover-buyer.
  buffer-copy locb-turnover-buyer to buf_turnover-buyer.
end.
if not available tb-turnover-buyer-main then do:
  create tb-turnover-buyer-main.
end.
buffer-copy wt-turnover-buyer-main to tb-turnover-buyer-main.
for each locb-turnover-buyer
on error  undo, return error
:
  delete locb-turnover-buyer.
end.
for each locb-turnover-buyer-gds
on error  undo, return error
:
  delete locb-turnover-buyer-gds.
end.
for each locb-turnover-buyer-gds-attr
on error  undo, return error
:
  delete locb-turnover-buyer-gds-attr.
end.
for each locb-turnover-buyer-attr
on error  undo, return error
:
  delete locb-turnover-buyer-attr.
end.
    delete wt-turnover-buyer-main.
  end.
END PROCEDURE.
define temp-table locb-turnover-group           no-undo like ub.turnover-group.
define temp-table locb-tnv-in-turnover-group    no-undo like ub.tnv-in-turnover-group.
define temp-table locb-c-turnover-group         no-undo like ub.c-turnover-group.
define temp-table locb-c-tnv-in-turnover-group  no-undo like ub.c-tnv-in-turnover-group.
define temp-table wt-turnover-group no-undo like ub.turnover-group.
PROCEDURE proc-load-turnover-group:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-turnover-group. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-turnover-group. stop" )
  on endkey undo, return error substitute( "$proc-load-turnover-group. endkey" )
  :
    define buffer tb-turnover-group for ub.turnover-group.
    define variable compare-log as logical no-undo.
define variable vss-include-info184 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_turnover-group          for ub.turnover-group.
define buffer buf_tnv-in-turnover-group   for ub.tnv-in-turnover-group.
define buffer buf_c-turnover-group        for ub.c-turnover-group.
define buffer buf_c-tnv-in-turnover-group for ub.c-tnv-in-turnover-group.
define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.
for each locb-turnover-group
on error  undo, return error
:
  delete locb-turnover-group.
end.
for each locb-c-turnover-group
on error  undo, return error
:
  delete locb-c-turnover-group.
end.
for each locb-tnv-in-turnover-group
on error  undo, return error
:
  delete locb-tnv-in-turnover-group.
end.
for each locb-c-tnv-in-turnover-group
on error  undo, return error
:
  delete locb-c-tnv-in-turnover-group.
end.
    for each wt-turnover-group
    on error undo, return error substitute( "$proc-load-turnover-group(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-turnover-group .
    end.
    create wt-turnover-group.
    run nws-impl in p-imp-handle
      ( input 'turnover-group':U
       ,input (buffer wt-turnover-group:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-turnover-group
      where tb-turnover-group.tog-id = wt-turnover-group.tog-id
        and tb-turnover-group.tog-db-num = wt-turnover-group.tog-db-num
      exclusive-lock no-error.
define variable vss-include-info185 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "tnv-in-turnover-group" then do:
      create locb-tnv-in-turnover-group.
run nws-impl in p-imp-handle
  ( input "tnv-in-turnover-group":U
   ,input (buffer locb-tnv-in-turnover-group:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-turnover-group" then do:
      create locb-c-turnover-group.
run nws-impl in p-imp-handle
  ( input "c-turnover-group":U
   ,input (buffer locb-c-turnover-group:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-tnv-in-turnover-group" then do:
      create locb-c-tnv-in-turnover-group.
run nws-impl in p-imp-handle
  ( input "c-tnv-in-turnover-group":U
   ,input (buffer locb-c-tnv-in-turnover-group:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_c-turnover-group where buf_c-turnover-group.tog-id = wt-turnover-group.tog-id
                            and buf_c-turnover-group.tog-db-num = wt-turnover-group.tog-db-num
on error  undo, return error
:
  delete buf_c-turnover-group.
end.
for each locb-c-turnover-group where locb-c-turnover-group.tog-id     = wt-turnover-group.tog-id
                             and locb-c-turnover-group.tog-db-num = wt-turnover-group.tog-db-num
  no-lock
on error  undo, return error
:
  create buf_c-turnover-group.
  buffer-copy  locb-c-turnover-group to buf_c-turnover-group.
end.
for each buf_tnv-in-turnover-group where buf_tnv-in-turnover-group.tog-id     = wt-turnover-group.tog-id
                                  and buf_tnv-in-turnover-group.tog-db-num = wt-turnover-group.tog-db-num
on error  undo, return error
:
  delete buf_tnv-in-turnover-group.
end.
for each locb-tnv-in-turnover-group where locb-tnv-in-turnover-group.tog-id     = wt-turnover-group.tog-id
                                    and locb-tnv-in-turnover-group.tog-db-num = wt-turnover-group.tog-db-num
no-lock
on error  undo, return error
:
  create buf_tnv-in-turnover-group.
  buffer-copy locb-tnv-in-turnover-group to buf_tnv-in-turnover-group.
end.
for each buf_c-tnv-in-turnover-group where buf_c-tnv-in-turnover-group.tog-id     = wt-turnover-group.tog-id
                                  and buf_c-tnv-in-turnover-group.tog-db-num = wt-turnover-group.tog-db-num
on error  undo, return error
:
  delete buf_c-tnv-in-turnover-group.
end.
for each locb-c-tnv-in-turnover-group where locb-c-tnv-in-turnover-group.tog-id = wt-turnover-group.tog-id
                                    and locb-c-tnv-in-turnover-group.tog-db-num = wt-turnover-group.tog-db-num
no-lock
on error  undo, return error
:
  create buf_c-tnv-in-turnover-group.
  buffer-copy locb-c-tnv-in-turnover-group to buf_c-tnv-in-turnover-group.
end.
if not available tb-turnover-group then do:
  create tb-turnover-group.
end.
buffer-copy wt-turnover-group to tb-turnover-group.
for each locb-c-turnover-group
on error  undo, return error
:
  delete locb-c-turnover-group.
end.
for each locb-tnv-in-turnover-group
on error  undo, return error
:
  delete locb-tnv-in-turnover-group.
end.
for each locb-c-tnv-in-turnover-group
on error  undo, return error
:
  delete locb-c-tnv-in-turnover-group.
end.
    delete wt-turnover-group.
  end.
END PROCEDURE.
define temp-table locb-wth-line      no-undo like ub.wth-line.
define temp-table locb-wth-dtl       no-undo like ub.wth-dtl.
define temp-table locb-wth-parts     no-undo like ub.wth-parts.
define temp-table locb-wth-doc-attr  no-undo like ub.wth-doc-attr.
define temp-table locbw-chk-doc       no-undo like ub.chk-doc.
define temp-table locbw-chk-pay       no-undo like ub.chk-pay.
define temp-table locbw-c-chk-doc     no-undo like ub.c-chk-doc.
define temp-table locbw-c-chk-pay     no-undo like ub.c-chk-pay.
define temp-table locbw-c-wth-doc    no-undo like ub.c-wth-doc.
define temp-table locbw-c-wth-line   no-undo like ub.c-wth-line.
define temp-table locbw-c-wth-dtl    no-undo like ub.c-wth-dtl.
define temp-table locbw-c-wth-parts  no-undo like ub.c-wth-parts.
define temp-table locbw-inkas-pay-wth  no-undo like ub.inkas-pay-wth.
define temp-table locbw-c-inkas-pay-wth  no-undo like ub.c-inkas-pay-wth.
define temp-table wt-wth-doc no-undo like ub.wth-doc.
PROCEDURE proc-load-wth-doc:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-wth-doc. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-wth-doc. stop" )
  on endkey undo, return error substitute( "$proc-load-wth-doc. endkey" )
  :
    define buffer tb-wth-doc for ub.wth-doc.
    define variable compare-log as logical no-undo.
define variable vss-include-info186 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_wth-line      for ub.wth-line.
define buffer buf_wth-dtl       for ub.wth-dtl.
define buffer buf_chk-doc     for ub.chk-doc.
define buffer buf_chk-pay      for ub.chk-pay.
define buffer buf_wth-parts     for ub.wth-parts.
define buffer buf_wth-doc-attr  for ub.wth-doc-attr.
define buffer buf_c-chk-doc   for ub.c-chk-doc.
define buffer buf_c-chk-pay    for ub.c-chk-pay.
define buffer buf_c-wth-doc     for ub.c-wth-doc.
define buffer buf_c-wth-line    for ub.c-wth-line.
define buffer buf_c-wth-dtl     for ub.c-wth-dtl.
define buffer buf_c-wth-parts   for ub.c-wth-parts.
define buffer buf_inkas-pay-wth   for ub.inkas-pay-wth.
define buffer buf_c-inkas-pay-wth   for ub.c-inkas-pay-wth.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
for each locb-wth-line
on error undo, return error error-status :get-message (1)
:
  delete locb-wth-line.
end.
for each locb-wth-dtl
on error undo, return error error-status :get-message (1)
:
  delete locb-wth-dtl.
end.
for each locb-wth-parts
on error undo, return error error-status :get-message (1)
:
  delete locb-wth-parts.
end.
for each locb-wth-doc-attr
on error undo, return error error-status :get-message (1)
:
  delete locb-wth-doc-attr.
end.
for each locb-chk-doc
on error undo, return error error-status :get-message (1)
:
  delete locb-chk-doc.
end.
for each locb-chk-pay
on error undo, return error error-status :get-message (1)
:
  delete locb-chk-pay.
end.
for each locb-c-chk-doc
on error undo, return error error-status :get-message (1)
:
  delete locb-c-chk-doc.
end.
for each locb-c-chk-pay
on error undo, return error error-status :get-message (1)
:
  delete locb-c-chk-pay.
end.
for each locbw-c-wth-doc
on error undo, return error error-status :get-message (1)
:
  delete locbw-c-wth-doc.
end.
for each locbw-c-wth-line
on error undo, return error error-status :get-message (1)
:
  delete locbw-c-wth-line.
end.
for each locbw-c-wth-dtl
on error undo, return error error-status :get-message (1)
:
  delete locbw-c-wth-dtl.
end.
for each locbw-c-wth-parts
on error undo, return error error-status :get-message (1)
:
  delete locbw-c-wth-parts.
end.
for each locbw-inkas-pay-wth
on error undo, return error error-status :get-message (1)
:
  delete locbw-inkas-pay-wth.
end.
for each locbw-c-inkas-pay-wth
on error undo, return error error-status :get-message (1)
:
  delete locbw-c-inkas-pay-wth.
end.
    for each wt-wth-doc
    on error undo, return error substitute( "$proc-load-wth-doc(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-wth-doc .
    end.
    create wt-wth-doc.
    run nws-impl in p-imp-handle
      ( input 'wth-doc':U
       ,input (buffer wt-wth-doc:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-wth-doc
      where tb-wth-doc.doc-code = wt-wth-doc.doc-code
      exclusive-lock no-error.
define variable vss-include-info187 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "wth-line" then do:
      create locb-wth-line.
run nws-impl in p-imp-handle
  ( input "wth-line":U
   ,input (buffer locb-wth-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "wth-dtl" then do:
      create locb-wth-dtl.
run nws-impl in p-imp-handle
  ( input "wth-dtl":U
   ,input (buffer locb-wth-dtl:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "wth-parts" then do:
      create locb-wth-parts.
run nws-impl in p-imp-handle
  ( input "wth-parts":U
   ,input (buffer locb-wth-parts:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "wth-doc-attr" then do:
      create locb-wth-doc-attr.
run nws-impl in p-imp-handle
  ( input "wth-doc-attr":U
   ,input (buffer locb-wth-doc-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "chk-doc" then do:
      create locbw-chk-doc.
run nws-impl in p-imp-handle
  ( input "chk-doc":U
   ,input (buffer locbw-chk-doc:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "chk-pay" then do:
      create locbw-chk-pay.
run nws-impl in p-imp-handle
  ( input "chk-pay":U
   ,input (buffer locbw-chk-pay:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-chk-doc" then do:
      create locbw-c-chk-doc.
run nws-impl in p-imp-handle
  ( input "c-chk-doc":U
   ,input (buffer locbw-c-chk-doc:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-chk-pay" then do:
      create locbw-c-chk-pay.
run nws-impl in p-imp-handle
  ( input "c-chk-pay":U
   ,input (buffer locbw-c-chk-pay:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-wth-doc" then do:
      create locbw-c-wth-doc.
run nws-impl in p-imp-handle
  ( input "c-wth-doc":U
   ,input (buffer locbw-c-wth-doc:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-wth-line" then do:
      create locbw-c-wth-line.
run nws-impl in p-imp-handle
  ( input "c-wth-line":U
   ,input (buffer locbw-c-wth-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-wth-dtl" then do:
      create locbw-c-wth-dtl.
run nws-impl in p-imp-handle
  ( input "c-wth-dtl":U
   ,input (buffer locbw-c-wth-dtl:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-wth-parts" then do:
      create locbw-c-wth-parts.
run nws-impl in p-imp-handle
  ( input "c-wth-parts":U
   ,input (buffer locbw-c-wth-parts:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "inkas-pay-wth" then do:
      create locbw-inkas-pay-wth.
run nws-impl in p-imp-handle
  ( input "inkas-pay-wth":U
   ,input (buffer locbw-inkas-pay-wth:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-inkas-pay-wth" then do:
      create locbw-c-inkas-pay-wth.
run nws-impl in p-imp-handle
  ( input "c-inkas-pay-wth":U
   ,input (buffer locbw-c-inkas-pay-wth:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе документа мат. ценностей"
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
if not available tb-wth-doc then do:
  create tb-wth-doc.
end.
else do:
  if tb-wth-doc.status_ = 'факт':U then  return error substitute("Документ &1 уже закрыт на факт." ,tb-wth-doc.doc-code).
end.
define variable v-old-wth-doc-status as character no-undo .
define variable v-new-wth-doc-status as character no-undo .
assign
  v-old-wth-doc-status = tb-wth-doc.status_
  v-new-wth-doc-status = wt-wth-doc.status_
.
run trg/nwsdochs.p
  (input g#db-num
  ,input 'update':U
  ,input wt-wth-doc.doc-code
  ,input wt-wth-doc.obj-type
  ,input wt-wth-doc.obj-code
  ,input 'wth-doc':U
  ,input ""
  ,input wt-wth-doc.fact-date
  ,input wt-wth-doc.fact-sum
  ,input 0
  ,input 0
  ,input 0
  ,input v-old-wth-doc-status
  ,input v-new-wth-doc-status
  ,input g#news-source-db
  ,input p-pck-num
  ,input wt-wth-doc.user-db-num
  ,input wt-wth-doc.user-name
  ,input wt-wth-doc.sys-date
  ,input wt-wth-doc.sys-time
  ,input wt-wth-doc.sys-time-int
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.
buffer-copy wt-wth-doc to tb-wth-doc.
on delete of ub.wth-dtl override do: end.
for each buf_wth-dtl where buf_wth-dtl.doc-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_wth-dtl.
end.
for each locb-wth-dtl where locb-wth-dtl.doc-code = wt-wth-doc.doc-code
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_wth-dtl.
  buffer-copy locb-wth-dtl to buf_wth-dtl.
end.
on delete of ub.wth-parts override do: end.
for each buf_wth-parts where buf_wth-parts.out-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_wth-parts no-error.
  if error-status:error then return error return-value.
end.
run trg/wthrspt.p (table locb-wth-parts
                  , yes ) no-error.
if error-status :error
then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status:get-message(1), return-value)
    ) .
  undo, return error
    substitute("Ошибка при установке резервов по документу &1. &3 &4 " ,
                wt-wth-doc.doc-code  ,
                return-value ,
                error-status:get-message(1))
    .
end.
for each locb-wth-parts where locb-wth-parts.out-code = wt-wth-doc.doc-code and locb-wth-parts.stts = 1
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_wth-parts.
  buffer-copy locb-wth-parts to buf_wth-parts.
end.
on delete of ub.wth-line override do: end.
on delete of ub.c-chk-doc override do: end.
on delete of ub.c-chk-pay override do: end.
for each buf_wth-line where buf_wth-line.doc-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_wth-line.
end.
for each locb-wth-line where locb-wth-line.doc-code = wt-wth-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_wth-line.
  buffer-copy locb-wth-line to buf_wth-line.
end.
on delete of ub.wth-doc-attr override do: end.
for each buf_wth-doc-attr where buf_wth-doc-attr.doc-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_wth-doc-attr.
end.
for each locb-wth-doc-attr where locb-wth-doc-attr.doc-code = wt-wth-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_wth-doc-attr.
  buffer-copy locb-wth-doc-attr to buf_wth-doc-attr.
end.
on delete of ub.chk-doc override do: end.
for each buf_chk-doc where buf_chk-doc.out-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
   for each buf_c-chk-doc where buf_c-chk-doc.doc-code = buf_chk-doc.doc-code:
     delete buf_c-chk-doc.
   end.
   for each buf_c-chk-pay where buf_c-chk-pay.doc-code = buf_chk-doc.doc-code:
     delete buf_c-chk-pay.
   end.
  delete buf_chk-doc.
end.
for each locb-chk-doc where locb-chk-doc.out-code = wt-wth-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  for each buf_c-chk-doc where buf_c-chk-doc.doc-code = locb-chk-doc.doc-code:
    delete buf_c-chk-doc.
  end.
  for each buf_c-chk-pay where buf_c-chk-pay.doc-code = locb-chk-doc.doc-code:
    delete buf_c-chk-pay.
  end.
  create buf_chk-doc.
  buffer-copy locb-chk-doc to buf_chk-doc.
end.
on delete of ub.chk-pay override do: end.
for each buf_chk-pay where buf_chk-pay.out-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_chk-pay.
end.
for each locb-chk-pay where locb-chk-pay.out-code = wt-wth-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_chk-pay.
  buffer-copy locb-chk-pay to buf_chk-pay.
end.
for each locb-c-chk-doc where locb-c-chk-doc.out-code = wt-wth-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
   for each buf_c-chk-doc where buf_c-chk-doc.doc-code = locb-c-chk-doc.doc-code:
     delete buf_c-chk-doc.
   end.
   for each buf_c-chk-pay where buf_c-chk-pay.doc-code = locb-c-chk-doc.doc-code:
     delete buf_c-chk-pay.
   end.
  create buf_c-chk-doc.
  buffer-copy locb-c-chk-doc to buf_c-chk-doc.
end.
for each buf_c-chk-pay where buf_c-chk-pay.out-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-chk-pay.
end.
for each locb-c-chk-pay where locb-c-chk-pay.out-code = wt-wth-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-chk-pay.
  buffer-copy locb-c-chk-pay to buf_c-chk-pay.
end.
on delete of ub.c-wth-doc override do: end.
for each buf_c-wth-doc where buf_c-wth-doc.doc-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-wth-doc.
end.
for each locbw-c-wth-doc where locbw-c-wth-doc.doc-code = wt-wth-doc.doc-code
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-wth-doc.
  buffer-copy locbw-c-wth-doc to buf_c-wth-doc.
end.
for each buf_c-wth-dtl where buf_c-wth-dtl.doc-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-wth-dtl.
end.
for each locbw-c-wth-dtl where locbw-c-wth-dtl.doc-code = wt-wth-doc.doc-code
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-wth-dtl.
  buffer-copy locbw-c-wth-dtl to buf_c-wth-dtl.
end.
for each buf_c-wth-parts where buf_c-wth-parts.out-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-wth-parts.
end.
for each locbw-c-wth-parts where locbw-c-wth-parts.out-code = wt-wth-doc.doc-code
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-wth-parts.
  buffer-copy locbw-c-wth-parts to buf_c-wth-parts.
end.
on delete of ub.c-wth-line override do: end.
for each buf_c-wth-line where buf_c-wth-line.doc-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-wth-line.
end.
for each locbw-c-wth-line where locbw-c-wth-line.doc-code = wt-wth-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-wth-line.
  buffer-copy locbw-c-wth-line to buf_c-wth-line.
end.
for each buf_inkas-pay-wth where buf_inkas-pay-wth.inkas-code = wt-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_inkas-pay-wth.
end.
for each locb-inkas-pay-wth where locb-inkas-pay-wth.inkas-code = wt-wth-doc.doc-code
                        no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_inkas-pay-wth.
  buffer-copy locb-inkas-pay-wth to buf_inkas-pay-wth.
end.
for each locb-wth-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-wth-line.
end.
for each locb-wth-dtl
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-wth-dtl.
end.
for each locb-wth-parts
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-wth-parts.
end.
for each locbw-chk-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbw-chk-doc.
end.
for each locbw-chk-pay
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbw-chk-pay.
end.
for each locbw-c-chk-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbw-c-chk-doc.
end.
for each locbw-c-chk-pay
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbw-c-chk-pay.
end.
for each locbw-c-wth-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbw-c-wth-doc.
end.
for each locbw-c-wth-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbw-c-wth-line.
end.
for each locbw-c-wth-dtl
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbw-c-wth-dtl.
end.
for each locbw-c-wth-parts
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbw-c-wth-parts.
end.
for each locbw-inkas-pay-wth
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbw-inkas-pay-wth.
end.
for each locbw-c-inkas-pay-wth
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbw-c-inkas-pay-wth.
end.
    delete wt-wth-doc.
  end.
END PROCEDURE.
define temp-table locb-c-wth-line       no-undo like ub.c-wth-line.
define temp-table locb-c-wth-dtl        no-undo like ub.c-wth-dtl.
define temp-table locb-c-wth-parts      no-undo like ub.c-wth-parts.
define temp-table locbw2-c-inkas-pay-wth no-undo like ub.c-inkas-pay-wth.
define temp-table wt-c-wth-doc no-undo like ub.c-wth-doc.
PROCEDURE proc-load-c-wth-doc:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-c-wth-doc. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-c-wth-doc. stop" )
  on endkey undo, return error substitute( "$proc-load-c-wth-doc. endkey" )
  :
    define buffer tb-c-wth-doc for ub.c-wth-doc.
    define variable compare-log as logical no-undo.
define variable vss-include-info188 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_c-wth-line      for ub.c-wth-line.
define buffer buf_c-wth-dtl       for ub.c-wth-dtl.
define buffer buf_c-wth-parts     for ub.c-wth-parts.
define buffer buf_c-inkas-pay-wth for ub.c-inkas-pay-wth.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
for each locb-c-wth-line
on error undo, return error error-status :get-message (1)
:
  delete locb-c-wth-line.
end.
for each locb-c-wth-dtl
on error undo, return error error-status :get-message (1)
:
  delete locb-c-wth-dtl.
end.
for each locb-c-wth-parts
on error undo, return error error-status :get-message (1)
:
  delete locb-c-wth-parts.
end.
for each locbw-c-inkas-pay-wth
on error undo, return error error-status :get-message (1)
:
  delete locbw-c-inkas-pay-wth.
end.
    for each wt-c-wth-doc
    on error undo, return error substitute( "$proc-load-c-wth-doc(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-c-wth-doc .
    end.
    create wt-c-wth-doc.
    run nws-impl in p-imp-handle
      ( input 'c-wth-doc':U
       ,input (buffer wt-c-wth-doc:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-c-wth-doc
      where tb-c-wth-doc.doc-code = wt-c-wth-doc.doc-code
        and tb-c-wth-doc.corr-user-db-num = wt-c-wth-doc.corr-user-db-num
        and tb-c-wth-doc.chip-num = wt-c-wth-doc.chip-num
      exclusive-lock no-error.
define variable vss-include-info189 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "c-wth-line" then do:
      create locb-c-wth-line.
run nws-impl in p-imp-handle
  ( input "c-wth-line":U
   ,input (buffer locb-c-wth-line:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-wth-dtl" then do:
      create locb-c-wth-dtl.
run nws-impl in p-imp-handle
  ( input "c-wth-dtl":U
   ,input (buffer locb-c-wth-dtl:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-wth-parts" then do:
      create locb-c-wth-parts.
run nws-impl in p-imp-handle
  ( input "c-wth-parts":U
   ,input (buffer locb-c-wth-parts:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "c-inkas-pay-wth" then do:
      create locb2-c-inkas-pay-wth.
run nws-impl in p-imp-handle
  ( input "c-inkas-pay-wth":U
   ,input (buffer locb2-c-inkas-pay-wth:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе истории документа мат. ценностей"
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
if not available tb-c-wth-doc then do:
  create tb-c-wth-doc.
end.
buffer-copy wt-c-wth-doc to tb-c-wth-doc.
for each buf_c-wth-dtl where buf_c-wth-dtl.doc-code = wt-c-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-wth-dtl.
end.
for each locb-c-wth-dtl where locb-c-wth-dtl.doc-code = wt-c-wth-doc.doc-code
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-wth-dtl.
  buffer-copy locb-c-wth-dtl to buf_c-wth-dtl.
end.
on delete of ub.c-wth-line override do: end.
for each buf_c-wth-line where buf_c-wth-line.doc-code = wt-c-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-wth-line.
end.
for each locb-c-wth-line where locb-c-wth-line.doc-code = wt-c-wth-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-wth-line.
  buffer-copy locb-c-wth-line to buf_c-wth-line.
end.
on delete of ub.c-wth-parts override do: end.
for each buf_c-wth-parts where buf_c-wth-parts.out-code = wt-c-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-wth-parts.
end.
for each locb-c-wth-parts where locb-c-wth-parts.out-code = wt-c-wth-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-wth-parts.
  buffer-copy locb-c-wth-parts to buf_c-wth-parts.
end.
for each buf_c-inkas-pay-wth where buf_c-inkas-pay-wth.inkas-code = wt-c-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-inkas-pay-wth.
end.
for each locbw2-c-inkas-pay-wth where locbw2-c-inkas-pay-wth.inkas-code = wt-c-wth-doc.doc-code
                        no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-inkas-pay-wth.
  buffer-copy locbw2-c-inkas-pay-wth to buf_c-inkas-pay-wth.
end.
for each locb-c-wth-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-wth-line.
end.
for each locb-c-wth-dtl
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-wth-dtl.
end.
for each locb-c-wth-parts
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-wth-parts.
end.
for each locbw2-c-inkas-pay-wth
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbw2-c-inkas-pay-wth.
end.
    delete wt-c-wth-doc.
  end.
END PROCEDURE.
define temp-table locb-xyz-analysis-obj            no-undo like ub.xyz-analysis-obj          .
define temp-table locb-xyz-analysis-doc            no-undo like ub.xyz-analysis-doc          .
define temp-table locb-xyz-analysis-attr           no-undo like ub.xyz-analysis-attr         .
define temp-table locb-xyz-analysis-period         no-undo like ub.xyz-analysis-period       .
define temp-table locb-xyz-analysis-goods          no-undo like ub.xyz-analysis-goods        .
define temp-table locb-xyz-analysis-gds-obj        no-undo like ub.xyz-analysis-gds-obj      .
define temp-table locb-xyz-analysis-goods-attr     no-undo like ub.xyz-analysis-goods-attr   .
define temp-table locb-xyz-analysis-gds-obj-attr   no-undo like ub.xyz-analysis-gds-obj-attr .
define temp-table wt-xyz-analysis no-undo like ub.xyz-analysis.
PROCEDURE proc-load-xyz-analysis:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-xyz-analysis. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-xyz-analysis. stop" )
  on endkey undo, return error substitute( "$proc-load-xyz-analysis. endkey" )
  :
    define buffer tb-xyz-analysis for ub.xyz-analysis.
    define variable compare-log as logical no-undo.
define variable vss-include-info190 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_xyz-analysis-obj           for ub.xyz-analysis-obj          .
define buffer buf_xyz-analysis-doc           for ub.xyz-analysis-doc          .
define buffer buf_xyz-analysis-attr          for ub.xyz-analysis-attr         .
define buffer buf_xyz-analysis-period        for ub.xyz-analysis-period       .
define buffer buf_xyz-analysis-goods         for ub.xyz-analysis-goods        .
define buffer buf_xyz-analysis-gds-obj       for ub.xyz-analysis-gds-obj      .
define buffer buf_xyz-analysis-goods-attr    for ub.xyz-analysis-goods-attr   .
define buffer buf_xyz-analysis-gds-obj-attr  for ub.xyz-analysis-gds-obj-attr .
def var counter  as integer   no-undo.
def var rec-full as character no-undo.
def var rec-name as character no-undo.
for each locb-xyz-analysis-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-obj.
end.
for each locb-xyz-analysis-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-doc.
end.
for each locb-xyz-analysis-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-attr.
end.
for each locb-xyz-analysis-period
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-period.
end.
for each locb-xyz-analysis-goods
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-goods.
end.
for each locb-xyz-analysis-gds-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-gds-obj.
end.
for each locb-xyz-analysis-goods-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-goods-attr.
end.
for each locb-xyz-analysis-gds-obj-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-gds-obj-attr.
end.
    for each wt-xyz-analysis
    on error undo, return error substitute( "$proc-load-xyz-analysis(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-xyz-analysis .
    end.
    create wt-xyz-analysis.
    run nws-impl in p-imp-handle
      ( input 'xyz-analysis':U
       ,input (buffer wt-xyz-analysis:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-xyz-analysis
      where tb-xyz-analysis.xyz-id = wt-xyz-analysis.xyz-id
        and tb-xyz-analysis.db-num = wt-xyz-analysis.db-num
      exclusive-lock no-error.
define variable vss-include-info191 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "xyz-analysis-obj" then do:
      create locb-xyz-analysis-obj.
run nws-impl in p-imp-handle
  ( input "xyz-analysis-obj":U
   ,input (buffer locb-xyz-analysis-obj:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "xyz-analysis-doc" then do:
      create locb-xyz-analysis-doc.
run nws-impl in p-imp-handle
  ( input "xyz-analysis-doc":U
   ,input (buffer locb-xyz-analysis-doc:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "xyz-analysis-attr" then do:
      create locb-xyz-analysis-attr.
run nws-impl in p-imp-handle
  ( input "xyz-analysis-attr":U
   ,input (buffer locb-xyz-analysis-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "xyz-analysis-period" then do:
      create locb-xyz-analysis-period.
run nws-impl in p-imp-handle
  ( input "xyz-analysis-period":U
   ,input (buffer locb-xyz-analysis-period:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "xyz-analysis-goods" then do:
      create locb-xyz-analysis-goods.
run nws-impl in p-imp-handle
  ( input "xyz-analysis-goods":U
   ,input (buffer locb-xyz-analysis-goods:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "xyz-analysis-gds-obj" then do:
      create locb-xyz-analysis-gds-obj.
run nws-impl in p-imp-handle
  ( input "xyz-analysis-gds-obj":U
   ,input (buffer locb-xyz-analysis-gds-obj:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "xyz-analysis-goods-attr" then do:
      create locb-xyz-analysis-goods-attr.
run nws-impl in p-imp-handle
  ( input "xyz-analysis-goods-attr":U
   ,input (buffer locb-xyz-analysis-goods-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "xyz-analysis-gds-obj-attr" then do:
      create locb-xyz-analysis-gds-obj-attr.
run nws-impl in p-imp-handle
  ( input "xyz-analysis-gds-obj-attr":U
   ,input (buffer locb-xyz-analysis-gds-obj-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе xyz-анализа."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
for each buf_xyz-analysis-obj where
         buf_xyz-analysis-obj.xyz-id   = wt-xyz-analysis.xyz-id  and
         buf_xyz-analysis-obj.db-num    = wt-xyz-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_xyz-analysis-obj.
end.
for each locb-xyz-analysis-obj where
         locb-xyz-analysis-obj.xyz-id = wt-xyz-analysis.xyz-id and
         locb-xyz-analysis-obj.db-num  = wt-xyz-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_xyz-analysis-obj.
  buffer-copy locb-xyz-analysis-obj to buf_xyz-analysis-obj.
end.
for each buf_xyz-analysis-doc where
         buf_xyz-analysis-doc.xyz-id   = wt-xyz-analysis.xyz-id  and
         buf_xyz-analysis-doc.db-num    = wt-xyz-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_xyz-analysis-doc.
end.
for each locb-xyz-analysis-doc where
         locb-xyz-analysis-doc.xyz-id = wt-xyz-analysis.xyz-id and
         locb-xyz-analysis-doc.db-num  = wt-xyz-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_xyz-analysis-doc.
  buffer-copy locb-xyz-analysis-doc to buf_xyz-analysis-doc.
end.
for each buf_xyz-analysis-attr where
         buf_xyz-analysis-attr.xyz-id   = wt-xyz-analysis.xyz-id  and
         buf_xyz-analysis-attr.db-num   = wt-xyz-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_xyz-analysis-attr.
end.
for each locb-xyz-analysis-attr where
         locb-xyz-analysis-attr.xyz-id = wt-xyz-analysis.xyz-id and
         locb-xyz-analysis-attr.db-num  = wt-xyz-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_xyz-analysis-attr.
  buffer-copy locb-xyz-analysis-attr to buf_xyz-analysis-attr.
end.
for each buf_xyz-analysis-period where
         buf_xyz-analysis-period.xyz-id   = wt-xyz-analysis.xyz-id  and
         buf_xyz-analysis-period.db-num   = wt-xyz-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_xyz-analysis-period.
end.
for each locb-xyz-analysis-period where
         locb-xyz-analysis-period.xyz-id = wt-xyz-analysis.xyz-id and
         locb-xyz-analysis-period.db-num  = wt-xyz-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_xyz-analysis-period.
  buffer-copy locb-xyz-analysis-period to buf_xyz-analysis-period.
end.
for each buf_xyz-analysis-goods-attr where
         buf_xyz-analysis-goods-attr.xyz-id   = wt-xyz-analysis.xyz-id  and
         buf_xyz-analysis-goods-attr.db-num   = wt-xyz-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_xyz-analysis-goods-attr.
end.
for each locb-xyz-analysis-goods-attr where
         locb-xyz-analysis-goods-attr.xyz-id = wt-xyz-analysis.xyz-id and
         locb-xyz-analysis-goods-attr.db-num  = wt-xyz-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_xyz-analysis-goods-attr.
  buffer-copy locb-xyz-analysis-goods-attr to buf_xyz-analysis-goods-attr.
end.
for each buf_xyz-analysis-goods where
         buf_xyz-analysis-goods.xyz-id   = wt-xyz-analysis.xyz-id  and
         buf_xyz-analysis-goods.db-num   = wt-xyz-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_xyz-analysis-goods.
end.
for each locb-xyz-analysis-goods where
         locb-xyz-analysis-goods.xyz-id = wt-xyz-analysis.xyz-id and
         locb-xyz-analysis-goods.db-num  = wt-xyz-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_xyz-analysis-goods.
  buffer-copy locb-xyz-analysis-goods to buf_xyz-analysis-goods.
end.
for each buf_xyz-analysis-gds-obj-attr where
         buf_xyz-analysis-gds-obj-attr.xyz-id   = wt-xyz-analysis.xyz-id  and
         buf_xyz-analysis-gds-obj-attr.db-num   = wt-xyz-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_xyz-analysis-gds-obj-attr.
end.
for each locb-xyz-analysis-gds-obj-attr where
         locb-xyz-analysis-gds-obj-attr.xyz-id = wt-xyz-analysis.xyz-id and
         locb-xyz-analysis-gds-obj-attr.db-num  = wt-xyz-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_xyz-analysis-gds-obj-attr.
  buffer-copy locb-xyz-analysis-gds-obj-attr to buf_xyz-analysis-gds-obj-attr.
end.
for each buf_xyz-analysis-gds-obj where
         buf_xyz-analysis-gds-obj.xyz-id   = wt-xyz-analysis.xyz-id  and
         buf_xyz-analysis-gds-obj.db-num   = wt-xyz-analysis.db-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_xyz-analysis-gds-obj.
end.
for each locb-xyz-analysis-gds-obj where
         locb-xyz-analysis-gds-obj.xyz-id = wt-xyz-analysis.xyz-id and
         locb-xyz-analysis-gds-obj.db-num  = wt-xyz-analysis.db-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_xyz-analysis-gds-obj.
  buffer-copy locb-xyz-analysis-gds-obj to buf_xyz-analysis-gds-obj.
end.
if not available tb-xyz-analysis then do:
  create tb-xyz-analysis.
end.
buffer-copy wt-xyz-analysis to tb-xyz-analysis.
for each locb-xyz-analysis-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-obj.
end.
for each locb-xyz-analysis-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-doc.
end.
for each locb-xyz-analysis-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-attr.
end.
for each locb-xyz-analysis-period
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-period.
end.
for each locb-xyz-analysis-goods
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-goods.
end.
for each locb-xyz-analysis-gds-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-gds-obj.
end.
for each locb-xyz-analysis-goods-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-goods-attr.
end.
for each locb-xyz-analysis-gds-obj-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-xyz-analysis-gds-obj-attr.
end.
    delete wt-xyz-analysis.
  end.
END PROCEDURE.
define temp-table wt-code no-undo like ub.code.
PROCEDURE proc-load-code:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-code. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-code. stop" )
  on endkey undo, return error substitute( "$proc-load-code. endkey" )
  :
    define buffer tb-code for ub.code.
    define variable compare-log as logical no-undo.
    for each wt-code
    on error undo, return error substitute( "$proc-load-code(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-code .
    end.
    create wt-code.
    run nws-impl in p-imp-handle
      ( input 'Code':U
       ,input (buffer wt-code:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-code
      where tb-code.parent = wt-code.parent
        and tb-code.code = wt-code.code
      exclusive-lock no-error.
define variable vss-include-info192 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if not available tb-code then
do:
   create tb-code.
   assign
      compare-log = no.
end.
else
do:
   buffer-compare tb-code TO wt-code case-sensitive save result in compare-log no-error.
end.
if not compare-log then
do:
   buffer-copy wt-code TO tb-code.
   run fill-code in p-imp-handle (input tb-code.parent
                                 ,input tb-code.code
      ).
end.
    delete wt-code.
  end.
END PROCEDURE.
define temp-table locb-utd no-undo like  ub.utd.
define temp-table locb-utd-attr no-undo like  ub.utd-attr.
define temp-table locb-utd-lines no-undo like  ub.utd-lines.
define temp-table locb-utd-lines-attr no-undo like  ub.utd-lines-attr.
define temp-table locb-utd-marking-lines no-undo like  ub.utd-marking-lines.
define temp-table locb-utd-marking-lines-attr no-undo like  ub.utd-marking-lines-attr.
define temp-table locb-utd-err no-undo like  ub.utd-err.
define temp-table locb-utd-err-attr no-undo like  ub.utd-err-attr.
define temp-table locb-marking no-undo like  ub.marking.
define temp-table locb-marking-attr no-undo like  ub.marking-attr.
define variable gtin as character no-undo.
define variable mySeqUtd as int64 no-undo init ?.
procedure MySeqForUtd:
   define input  parameter iTable       as character no-undo.
   define input  parameter iseqnamehist as character no-undo.
   define input  parameter idb-name     as character no-undo.
   define output parameter Oseq         as int64 no-undo.
   if iTable begins "utd"
   then do:
      if myseqUtd eq ?
      then
         myseqUtd = dynamic-next-value(iseqnamehist,idb-name).
      Oseq = myseqUtd.
   end.
   else
      Oseq = ?.
   return.
end.
define temp-table wt-utd no-undo like ub.utd.
PROCEDURE proc-load-utd:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-utd. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-utd. stop" )
  on endkey undo, return error substitute( "$proc-load-utd. endkey" )
  :
    define buffer tb-utd for ub.utd.
    define variable compare-log as logical no-undo.
define variable vss-include-info193 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_utd                    for ub.utd.
define buffer buf_utd-attr               for ub.utd-attr.
define buffer buf_utd-lines              for ub.utd-lines.
define buffer buf_utd-lines-attr         for ub.utd-lines-attr.
define buffer buf_utd-marking-lines      for ub.utd-marking-lines.
define buffer buf_utd-marking-lines-attr for ub.utd-marking-lines-attr.
define buffer buf_utd-err                for ub.utd-err.
define buffer buf_utd-err-attr           for ub.utd-err-attr.
define buffer buf_marking                for ub.marking.
define buffer buf_marking-attr           for ub.marking-attr.
define variable counter  as   integer   no-undo.
define variable rec-full as   character no-undo.
define variable rec-name as   character no-undo.
define variable v-send-to-cash as logical no-undo .
define variable gtin           as character no-undo.
for each locb-utd
on error  undo, return error
:
  delete locb-utd.
end.
for each locb-utd-lines
on error  undo, return error
:
  delete locb-utd-lines.
end.
for each locb-utd-marking-lines
on error  undo, return error
:
  delete locb-utd-marking-lines.
end.
for each locb-utd-err
on error  undo, return error
:
  delete locb-utd-err.
end.
for each locb-marking
on error  undo, return error
:
  delete locb-marking.
end.
for each locb-utd-attr
on error  undo, return error
:
  delete locb-utd-attr.
end.
for each locb-utd-lines-attr
on error  undo, return error
:
  delete locb-utd-lines-attr.
end.
for each locb-utd-marking-lines-attr
on error  undo, return error
:
  delete locb-utd-marking-lines-attr.
end.
for each locb-utd-err-attr
on error  undo, return error
:
  delete locb-utd-err-attr.
end.
for each locb-marking-attr
on error  undo, return error
:
  delete locb-marking-attr.
end.
    for each wt-utd
    on error undo, return error substitute( "$proc-load-utd(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-utd .
    end.
    create wt-utd.
    run nws-impl in p-imp-handle
      ( input 'utd':U
       ,input (buffer wt-utd:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-utd
      where tb-utd.db-num = wt-utd.db-num
        and tb-utd.doc-id = wt-utd.doc-id
      exclusive-lock no-error.
define variable vss-include-info194 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :
run nws-imps in p-imp-handle
  ( input-output counter
   ,output       rec-full
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
  assign
    rec-name = entry( 1, rec-full, chr(1) )
    .
  CASE rec-name :
    when "utd-attr" then do:
      create locb-utd-attr.
run nws-impl in p-imp-handle
  ( input "utd-attr":U
   ,input (buffer locb-utd-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "utd-lines" then do:
      create locb-utd-lines.
run nws-impl in p-imp-handle
  ( input "utd-lines":U
   ,input (buffer locb-utd-lines:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "utd-lines-attr" then do:
      create locb-utd-lines-attr.
run nws-impl in p-imp-handle
  ( input "utd-lines-attr":U
   ,input (buffer locb-utd-lines-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "utd-err" then do:
      create locb-utd-err.
run nws-impl in p-imp-handle
  ( input "utd-err":U
   ,input (buffer locb-utd-err:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "utd-err-attr" then do:
      create locb-utd-err-attr.
run nws-impl in p-imp-handle
  ( input "utd-err-attr":U
   ,input (buffer locb-utd-err-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "marking" then do:
      create locb-marking.
run nws-impl in p-imp-handle
  ( input "marking":U
   ,input (buffer locb-marking:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "marking-attr" then do:
      create locb-marking-attr.
run nws-impl in p-imp-handle
  ( input "marking-attr":U
   ,input (buffer locb-marking-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "utd-marking-lines" then do:
      create locb-utd-marking-lines.
run nws-impl in p-imp-handle
  ( input "utd-marking-lines":U
   ,input (buffer locb-utd-marking-lines:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "utd-marking-lines-attr" then do:
      create locb-utd-marking-lines-attr.
run nws-impl in p-imp-handle
  ( input "utd-marking-lines-attr":U
   ,input (buffer locb-utd-marking-lines-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "utd-lines" then do:
      create locb-utd-lines.
run nws-impl in p-imp-handle
  ( input "utd-lines":U
   ,input (buffer locb-utd-lines:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    when "utd-lines-attr" then do:
      create locb-utd-lines-attr.
run nws-impl in p-imp-handle
  ( input "utd-lines-attr":U
   ,input (buffer locb-utd-lines-attr:handle)
  ) no-error.
if error-status :error then do:
  return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message(1) ) .
end.
    end.
    otherwise do:
      message "Не предуcмотрен прием таблицы " rec-name skip
              "в cоcтаве куcта."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.
subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
MySeqUtd = ?.
for each locb-utd-attr
where
locb-utd-attr.doc-id eq wt-utd.doc-id
and locb-utd-attr.db-num eq wt-utd.db-num
no-lock
on error  undo, return error
:
 for first buf_utd-attr where buf_utd-attr.db-num eq locb-utd-attr.db-num
and buf_utd-attr.doc-id eq locb-utd-attr.doc-id
and buf_utd-attr.attr-code eq locb-utd-attr.attr-code
   exclusive-lock: leave. end.
   if not available buf_utd-attr
   then do:
      create buf_utd-attr.
      buffer-copy locb-utd-attr to buf_utd-attr.
   end.
   else
     buffer-copy locb-utd-attr  to buf_utd-attr.
   validate buf_utd-attr no-error.
   if error-status:error
   then
      return error return-value.
   create tmprecid.
   assign
      tmprecid.fTable = "buf_utd-attr"
      tmprecid.Frecid = recid(buf_utd-attr)
   .
end.
for each buf_utd-attr where
buf_utd-attr.doc-id eq wt-utd.doc-id
and buf_utd-attr.db-num eq wt-utd.db-num
exclusive-lock
on error  undo, return error
:
   find first tmprecid where tmprecid.fTable = "buf_utd-attr"
                         and tmprecid.Frecid = recid(buf_utd-attr)
   no-lock no-error.
   if not available tmprecid
   then
      delete buf_utd-attr.
end.
empty temp-table tmprecid.
for each locb-utd-lines
where
locb-utd-lines.doc-id eq wt-utd.doc-id
and locb-utd-lines.db-num eq wt-utd.db-num
no-lock
on error  undo, return error
:
 for first buf_utd-lines where buf_utd-lines.db-num eq locb-utd-lines.db-num
and buf_utd-lines.doc-id eq locb-utd-lines.doc-id
and buf_utd-lines.LineNum eq locb-utd-lines.LineNum
   exclusive-lock: leave. end.
   if not available buf_utd-lines
   then do:
      create buf_utd-lines.
      buffer-copy locb-utd-lines to buf_utd-lines.
   end.
   else
     buffer-copy locb-utd-lines  to buf_utd-lines.
   validate buf_utd-lines no-error.
   if error-status:error
   then
      return error return-value.
   create tmprecid.
   assign
      tmprecid.fTable = "buf_utd-lines"
      tmprecid.Frecid = recid(buf_utd-lines)
   .
end.
for each buf_utd-lines where
buf_utd-lines.doc-id eq wt-utd.doc-id
and buf_utd-lines.db-num eq wt-utd.db-num
exclusive-lock
on error  undo, return error
:
   find first tmprecid where tmprecid.fTable = "buf_utd-lines"
                         and tmprecid.Frecid = recid(buf_utd-lines)
   no-lock no-error.
   if not available tmprecid
   then
      delete buf_utd-lines.
end.
empty temp-table tmprecid.
for each locb-utd-lines-attr
where
locb-utd-lines-attr.doc-id eq wt-utd.doc-id
and locb-utd-lines-attr.db-num eq wt-utd.db-num
no-lock
on error  undo, return error
:
 for first buf_utd-lines-attr where buf_utd-lines-attr.db-num eq locb-utd-lines-attr.db-num
and buf_utd-lines-attr.doc-id eq locb-utd-lines-attr.doc-id
and buf_utd-lines-attr.LineNum eq locb-utd-lines-attr.LineNum
and buf_utd-lines-attr.attr-code eq locb-utd-lines-attr.attr-code
   exclusive-lock: leave. end.
   if not available buf_utd-lines-attr
   then do:
      create buf_utd-lines-attr.
      buffer-copy locb-utd-lines-attr to buf_utd-lines-attr.
   end.
   else
     buffer-copy locb-utd-lines-attr  to buf_utd-lines-attr.
   validate buf_utd-lines-attr no-error.
   if error-status:error
   then
      return error return-value.
   create tmprecid.
   assign
      tmprecid.fTable = "buf_utd-lines-attr"
      tmprecid.Frecid = recid(buf_utd-lines-attr)
   .
end.
for each buf_utd-lines-attr where
buf_utd-lines-attr.doc-id eq wt-utd.doc-id
and buf_utd-lines-attr.db-num eq wt-utd.db-num
exclusive-lock
on error  undo, return error
:
   find first tmprecid where tmprecid.fTable = "buf_utd-lines-attr"
                         and tmprecid.Frecid = recid(buf_utd-lines-attr)
   no-lock no-error.
   if not available tmprecid
   then
      delete buf_utd-lines-attr.
end.
empty temp-table tmprecid.
for each locb-utd-err
where
locb-utd-err.doc-id eq wt-utd.doc-id
and locb-utd-err.db-num eq wt-utd.db-num
no-lock
on error  undo, return error
:
 for first buf_utd-err where buf_utd-err.db-num eq locb-utd-err.db-num
and buf_utd-err.doc-id eq locb-utd-err.doc-id
and buf_utd-err.CheckType eq locb-utd-err.CheckType
and buf_utd-err.CodeErr eq locb-utd-err.CodeErr
and buf_utd-err.CheckObj eq locb-utd-err.CheckObj
and buf_utd-err.reckey eq locb-utd-err.reckey
   exclusive-lock: leave. end.
   if not available buf_utd-err
   then do:
      create buf_utd-err.
      buffer-copy locb-utd-err to buf_utd-err.
   end.
   else
     buffer-copy locb-utd-err  to buf_utd-err.
   validate buf_utd-err no-error.
   if error-status:error
   then
      return error return-value.
   create tmprecid.
   assign
      tmprecid.fTable = "buf_utd-err"
      tmprecid.Frecid = recid(buf_utd-err)
   .
end.
for each buf_utd-err where
buf_utd-err.doc-id eq wt-utd.doc-id
and buf_utd-err.db-num eq wt-utd.db-num
exclusive-lock
on error  undo, return error
:
   find first tmprecid where tmprecid.fTable = "buf_utd-err"
                         and tmprecid.Frecid = recid(buf_utd-err)
   no-lock no-error.
   if not available tmprecid
   then
      delete buf_utd-err.
end.
empty temp-table tmprecid.
for each locb-utd-err-attr
where
locb-utd-err-attr.doc-id eq wt-utd.doc-id
and locb-utd-err-attr.db-num eq wt-utd.db-num
no-lock
on error  undo, return error
:
 for first buf_utd-err-attr where buf_utd-err-attr.db-num eq locb-utd-err-attr.db-num
and buf_utd-err-attr.doc-id eq locb-utd-err-attr.doc-id
and buf_utd-err-attr.CheckType eq locb-utd-err-attr.CheckType
and buf_utd-err-attr.CodeErr eq locb-utd-err-attr.CodeErr
and buf_utd-err-attr.CheckObj eq locb-utd-err-attr.CheckObj
and buf_utd-err-attr.reckey eq locb-utd-err-attr.reckey
and buf_utd-err-attr.attr-code eq locb-utd-err-attr.attr-code
   exclusive-lock: leave. end.
   if not available buf_utd-err-attr
   then do:
      create buf_utd-err-attr.
      buffer-copy locb-utd-err-attr to buf_utd-err-attr.
   end.
   else
     buffer-copy locb-utd-err-attr  to buf_utd-err-attr.
   validate buf_utd-err-attr no-error.
   if error-status:error
   then
      return error return-value.
   create tmprecid.
   assign
      tmprecid.fTable = "buf_utd-err-attr"
      tmprecid.Frecid = recid(buf_utd-err-attr)
   .
end.
for each buf_utd-err-attr where
buf_utd-err-attr.doc-id eq wt-utd.doc-id
and buf_utd-err-attr.db-num eq wt-utd.db-num
exclusive-lock
on error  undo, return error
:
   find first tmprecid where tmprecid.fTable = "buf_utd-err-attr"
                         and tmprecid.Frecid = recid(buf_utd-err-attr)
   no-lock no-error.
   if not available tmprecid
   then
      delete buf_utd-err-attr.
end.
empty temp-table tmprecid.
for each locb-marking
no-lock
on error  undo, return error
:
     gtin = GetCodeIdent(locb-marking.mark).
 for first buf_marking where buf_marking.mark eq locb-marking.mark
  or buf_marking.mark begins gtin exclusive-lock: leave. end.
   if not available buf_marking
   then do:
      create buf_marking.
      buffer-copy locb-marking to buf_marking.
   end.
   else
     buffer-copy locb-marking  to buf_marking.
   validate buf_marking no-error.
   if error-status:error
   then
      return error return-value.
end.
for each locb-marking-attr
no-lock
on error  undo, return error
:
 for first buf_marking-attr where buf_marking-attr.mark eq locb-marking-attr.mark
and buf_marking-attr.attr-code eq locb-marking-attr.attr-code
   exclusive-lock: leave. end.
   if not available buf_marking-attr
   then do:
      create buf_marking-attr.
      buffer-copy locb-marking-attr to buf_marking-attr.
   end.
   else
     buffer-copy locb-marking-attr  to buf_marking-attr.
   validate buf_marking-attr no-error.
   if error-status:error
   then
      return error return-value.
end.
for each locb-utd-marking-lines
where
locb-utd-marking-lines.doc-id eq wt-utd.doc-id
and locb-utd-marking-lines.db-num eq wt-utd.db-num
no-lock
on error  undo, return error
:
 for first buf_utd-marking-lines where buf_utd-marking-lines.db-num eq locb-utd-marking-lines.db-num
and buf_utd-marking-lines.doc-id eq locb-utd-marking-lines.doc-id
and buf_utd-marking-lines.LineNum eq locb-utd-marking-lines.LineNum
and buf_utd-marking-lines.mark eq locb-utd-marking-lines.mark
   exclusive-lock: leave. end.
   if not available buf_utd-marking-lines
   then do:
      create buf_utd-marking-lines.
      buffer-copy locb-utd-marking-lines to buf_utd-marking-lines.
   end.
   else
     buffer-copy locb-utd-marking-lines  to buf_utd-marking-lines.
   validate buf_utd-marking-lines no-error.
   if error-status:error
   then
      return error return-value.
   create tmprecid.
   assign
      tmprecid.fTable = "buf_utd-marking-lines"
      tmprecid.Frecid = recid(buf_utd-marking-lines)
   .
end.
for each buf_utd-marking-lines where
buf_utd-marking-lines.doc-id eq wt-utd.doc-id
and buf_utd-marking-lines.db-num eq wt-utd.db-num
exclusive-lock
on error  undo, return error
:
   find first tmprecid where tmprecid.fTable = "buf_utd-marking-lines"
                         and tmprecid.Frecid = recid(buf_utd-marking-lines)
   no-lock no-error.
   if not available tmprecid
   then
      delete buf_utd-marking-lines.
end.
empty temp-table tmprecid.
for each locb-utd-marking-lines-attr
where
locb-utd-marking-lines-attr.doc-id eq wt-utd.doc-id
and locb-utd-marking-lines-attr.db-num eq wt-utd.db-num
no-lock
on error  undo, return error
:
 for first buf_utd-marking-lines-attr where buf_utd-marking-lines-attr.db-num eq locb-utd-marking-lines-attr.db-num
and buf_utd-marking-lines-attr.doc-id eq locb-utd-marking-lines-attr.doc-id
and buf_utd-marking-lines-attr.LineNum eq locb-utd-marking-lines-attr.LineNum
and buf_utd-marking-lines-attr.mark eq locb-utd-marking-lines-attr.mark
and buf_utd-marking-lines-attr.attr-code eq locb-utd-marking-lines-attr.attr-code
   exclusive-lock: leave. end.
   if not available buf_utd-marking-lines-attr
   then do:
      create buf_utd-marking-lines-attr.
      buffer-copy locb-utd-marking-lines-attr to buf_utd-marking-lines-attr.
   end.
   else
     buffer-copy locb-utd-marking-lines-attr  to buf_utd-marking-lines-attr.
   validate buf_utd-marking-lines-attr no-error.
   if error-status:error
   then
      return error return-value.
   create tmprecid.
   assign
      tmprecid.fTable = "buf_utd-marking-lines-attr"
      tmprecid.Frecid = recid(buf_utd-marking-lines-attr)
   .
end.
for each buf_utd-marking-lines-attr where
buf_utd-marking-lines-attr.doc-id eq wt-utd.doc-id
and buf_utd-marking-lines-attr.db-num eq wt-utd.db-num
exclusive-lock
on error  undo, return error
:
   find first tmprecid where tmprecid.fTable = "buf_utd-marking-lines-attr"
                         and tmprecid.Frecid = recid(buf_utd-marking-lines-attr)
   no-lock no-error.
   if not available tmprecid
   then
      delete buf_utd-marking-lines-attr.
end.
empty temp-table tmprecid.
if not available tb-utd then do:
  create tb-utd.
end.
buffer-copy wt-utd to tb-utd.
validate tb-utd no-error.
  if error-status:error
  then
     return error return-value.
unsubscribe "getNextseq".
for each locb-utd-lines
on error  undo, return error
:
  delete locb-utd-lines.
end.
for each locb-utd-err
on error  undo, return error
:
  delete locb-utd-err.
end.
for each locb-marking
on error  undo, return error
:
  delete locb-marking.
end.
for each locb-utd-marking-lines
on error  undo, return error
:
  delete locb-utd-marking-lines.
end.
release tb-utd.
for each locb-utd-lines-attr
on error  undo, return error
:
  delete locb-utd-lines-attr.
end.
for each locb-utd-err-attr
on error  undo, return error
:
  delete locb-utd-err-attr.
end.
for each locb-marking-attr
on error  undo, return error
:
  delete locb-marking-attr.
end.
for each locb-utd-marking-lines-attr
on error  undo, return error
:
  delete locb-utd-marking-lines-attr.
end.
for each locb-utd-attr
on error  undo, return error
:
  delete locb-utd-attr.
end.
    delete wt-utd.
  end.
END PROCEDURE.
define temp-table wt-chk-slip-head no-undo like ub.chk-slip-head.
PROCEDURE proc-load-chk-slip-head:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-chk-slip-head. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-chk-slip-head. stop" )
  on endkey undo, return error substitute( "$proc-load-chk-slip-head. endkey" )
  :
    define buffer tb-chk-slip-head for ub.chk-slip-head.
    define variable compare-log as logical no-undo.
define variable vss-include-info195 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if true
then do :
  run skip-rec in p-imp-handle no-error .
  return .
end .
else do :
end .
    for each wt-chk-slip-head
    on error undo, return error substitute( "$proc-load-chk-slip-head(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-chk-slip-head .
    end.
    create wt-chk-slip-head.
    run nws-impl in p-imp-handle
      ( input 'chk-slip-head':U
       ,input (buffer wt-chk-slip-head:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-chk-slip-head
      where tb-chk-slip-head.db-num = wt-chk-slip-head.db-num
        and tb-chk-slip-head.ID = wt-chk-slip-head.ID
        and tb-chk-slip-head.CheckID = wt-chk-slip-head.CheckID
        and tb-chk-slip-head.RRN = wt-chk-slip-head.RRN
      exclusive-lock no-error.
    if l-counter <> 0 then do:
      return error substitute( "&1 &2. Ошибка обработки записи &3", vss-workfile, vss-revision, 'chk-slip-head':U )
                   + chr(10) + "Есть привязанные записи, а обработка идет для одной".
    end.
    if not available tb-chk-slip-head then do:
      create tb-chk-slip-head.
      assign compare-log = no.
    end.
    else do:
      buffer-compare tb-chk-slip-head TO wt-chk-slip-head case-sensitive save result in compare-log no-error.
    end.
    if not compare-log then do:
      buffer-copy wt-chk-slip-head TO tb-chk-slip-head.
    end.
    delete wt-chk-slip-head.
  end.
END PROCEDURE.
define temp-table wt-chk-slip-string no-undo like ub.chk-slip-string.
PROCEDURE proc-load-chk-slip-string:
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do
  on error  undo, return error substitute( "$proc-load-chk-slip-string. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-chk-slip-string. stop" )
  on endkey undo, return error substitute( "$proc-load-chk-slip-string. endkey" )
  :
    define buffer tb-chk-slip-string for ub.chk-slip-string.
    define variable compare-log as logical no-undo.
define variable vss-include-info196 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if true
then do :
  run skip-rec in p-imp-handle no-error .
  return .
end .
else do :
end .
    for each wt-chk-slip-string
    on error undo, return error substitute( "$proc-load-chk-slip-string(del-wt-). &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      delete wt-chk-slip-string .
    end.
    create wt-chk-slip-string.
    run nws-impl in p-imp-handle
      ( input 'chk-slip-string':U
       ,input (buffer wt-chk-slip-string:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    find first tb-chk-slip-string
      where tb-chk-slip-string.db-num = wt-chk-slip-string.db-num
        and tb-chk-slip-string.ID = wt-chk-slip-string.ID
        and tb-chk-slip-string.CheckID = wt-chk-slip-string.CheckID
        and tb-chk-slip-string.RRN = wt-chk-slip-string.RRN
        and tb-chk-slip-string.str-num = wt-chk-slip-string.str-num
      exclusive-lock no-error.
    if l-counter <> 0 then do:
      return error substitute( "&1 &2. Ошибка обработки записи &3", vss-workfile, vss-revision, 'chk-slip-string':U )
                   + chr(10) + "Есть привязанные записи, а обработка идет для одной".
    end.
    if not available tb-chk-slip-string then do:
      create tb-chk-slip-string.
      assign compare-log = no.
    end.
    else do:
      buffer-compare tb-chk-slip-string TO wt-chk-slip-string case-sensitive save result in compare-log no-error.
    end.
    if not compare-log then do:
      buffer-copy wt-chk-slip-string TO tb-chk-slip-string.
    end.
    delete wt-chk-slip-string.
  end.
END PROCEDURE.
