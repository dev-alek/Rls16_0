block-level on error undo, throw.
define input parameter parparentproc as handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-esys-id as integer   no-undo .
define input parameter p-db-num  as integer   no-undo .
define input parameter p-cr-db-num as integer no-undo .
define input parameter p-xml-file-name as character no-undo .
define input parameter p-file-name as character no-undo .
define input parameter p-pack-data as memptr no-undo . // с 23/VIII-2018 xml-файл читается из memptr, а не из файла
define input parameter p-pack-num as integer   no-undo .
define input parameter p-log-file-name as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: f4cdafb70594, 2001, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: Wed Sep 18 21:00:35 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cmdeigen.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/cmdeigen.p $":U .
define variable vss-description as character no-undo init "Импорт файла XML из внешней системы".
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
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info4 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info4, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info4, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info4, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info4 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info4, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info4 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info4, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info4, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info4, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info4, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info4, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info4 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info4 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info4, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info4, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info4 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info4 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info4, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, v-tbl-name ).
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable tempcxml_v-num_ as integer no-undo .
define NEW SHARED temp-table temp-xml-tables no-undo
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
define NEW SHARED temp-table temp-xml-records no-undo
field tbl-name as character
field uniq-key-rec as character
index pi is unique primary
tbl-name
uniq-key-rec
.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                                                        ,vss-include-info6
                                                        ,p-gate-rec).
find first buf_clob-data no-lock where
          rowid(buf_clob-data) = v-tbl-row no-error.
if not available buf_clob-data then do:
  if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                          ,vss-include-info6
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info6, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info6 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info6 )
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info6, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info6 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info6 )
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info6, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info6 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info6 )
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info6, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info6 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info6 )
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table temp-param-name no-undo
field profile_id as integer
field profile-type as character
field schema-name as character
field esys-id as integer
field call_id as character
field once-more as integer
field codex_id as integer
field ruleset_id as integer
field order_id as integer
field param-name as character
field param-type as character
field pack-process-uniq-key-rec as character
index pi is primary unique
esys-id
schema-name
profile_id
call_id
.
procedure xmlischn_fill :
define input  parameter p-codex-id  as integer   no-undo .
define input  parameter p-ruleset-id as integer   no-undo .
define buffer buf_rule-call-param  for ub.rule-call-param.
define buffer buf2_rule-call-param for ub.rule-call-param.
define buffer buf_temp-param-name for temp-param-name.
define variable v-esys-id-list as character no-undo .
define variable v-ii as integer no-undo .
  do
  on error undo, return error return-value
  :
    for each buf_rule-call-param where
            buf_rule-call-param.codex_id = p-codex-id
        and buf_rule-call-param.ruleset_id = p-ruleset-id
    break
    by buf_rule-call-param.call_id
    by buf_rule-call-param.profile_id
    by buf_rule-call-param.once-more
    :
      if first-of(buf_rule-call-param.once-more) then do:
        v-esys-id-list = ''.
        for each buf2_rule-call-param no-lock
           where buf2_rule-call-param.call_id    = buf_rule-call-param.call_id
             and buf2_rule-call-param.codex_id   = buf_rule-call-param.codex_id
             and buf2_rule-call-param.ruleset_id = buf_rule-call-param.ruleset_id
             and buf2_rule-call-param.profile_id = buf_rule-call-param.profile_id
             and buf2_rule-call-param.once-more  = buf_rule-call-param.once-more
             and buf2_rule-call-param.param-2-data-type = 'ext-system':U :
          if buf2_rule-call-param.param-name = "p-esys-id"
               or
               (buf2_rule-call-param.param-name = "p-esys-id-list"
               and
               buf2_rule-call-param.p-index > 0)
          then do:
            assign
            v-esys-id-list = v-esys-id-list + (if v-esys-id-list = '' then '' else chr(44)) +
                            string( buf2_rule-call-param.param-value-integer)
            .
          end.
        end.
      end.
      if v-esys-id-list = "" then v-esys-id-list = "-1".
      if buf_rule-call-param.param-2-data-type = "xsd" then do:
        find first buf_temp-param-name where
                buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
          and buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
          and buf_temp-param-name.call_id = buf_rule-call-param.call_id
          and buf_temp-param-name.once-more = buf_rule-call-param.once-more
          no-error.
        if not available buf_temp-param-name then do:
          do v-ii = 1 to num-entries(v-esys-id-list):
            find first buf_temp-param-name where
                    buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
              and buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
              and buf_temp-param-name.call_id = buf_rule-call-param.call_id
              and buf_temp-param-name.esys-id = integer(entry(v-ii, v-esys-id-list))
              no-error.
            if not available buf_temp-param-name then do:
          create buf_temp-param-name.
          assign
          buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
          buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
          buf_temp-param-name.call_id = buf_rule-call-param.call_id
          buf_temp-param-name.once-more = buf_rule-call-param.once-more
          buf_temp-param-name.esys-id = integer(entry(v-ii, v-esys-id-list))
          buf_temp-param-name.ruleset_id = buf_rule-call-param.ruleset_id
          buf_temp-param-name.codex_id = buf_rule-call-param.codex_id
          buf_temp-param-name.order_id = buf_rule-call-param.order_id
          buf_temp-param-name.param-name = buf_rule-call-param.param-name
            buf_temp-param-name.param-type = "xsd"
            buf_temp-param-name.profile-type = entry (buf_rule-call-param.codex_id, 'dis-card-type,dis-card-type,dis-card-type,dis-card-type,dis-card-type,dis-card-type,,,,,goods,clients,gds-grp,cli-grp,,,,edoc,chk-doc,thref,pdf,rep,ord,fdoc':U)
            buf_temp-param-name.pack-process-uniq-key-rec =
            substitute("&2&1&3&1&4&1&5"
                                                                      , chr(4)
                                                                      , buf_rule-call-param.call_id
                                                                      , buf_rule-call-param.codex_id
                                                                      , buf_rule-call-param.ruleset_id
                                                                      , buf_rule-call-param.order_id)
            .
            end.
          end.
        end.
      end.
      if buf_rule-call-param.param-2-data-type = "sub-type" then do:
        find first buf_temp-param-name where
                buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
          and buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
          and buf_temp-param-name.call_id = buf_rule-call-param.call_id
          and buf_temp-param-name.once-more = buf_rule-call-param.once-more
          no-error.
        if not available buf_temp-param-name then do:
          do v-ii = 1 to num-entries(v-esys-id-list):
            find first buf_temp-param-name where
                    buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
              and buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
              and buf_temp-param-name.call_id = buf_rule-call-param.call_id
              and buf_temp-param-name.esys-id = integer(entry(v-ii, v-esys-id-list))
              no-error.
            if not available buf_temp-param-name then do:
            create buf_temp-param-name.
            assign
            buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
            buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
            buf_temp-param-name.call_id = buf_rule-call-param.call_id
            buf_temp-param-name.once-more = buf_rule-call-param.once-more
            buf_temp-param-name.esys-id = integer(entry(v-ii, v-esys-id-list))
            buf_temp-param-name.ruleset_id = buf_rule-call-param.ruleset_id
            buf_temp-param-name.codex_id = buf_rule-call-param.codex_id
            buf_temp-param-name.order_id = buf_rule-call-param.order_id
            buf_temp-param-name.param-name = buf_rule-call-param.param-name
            buf_temp-param-name.param-type = "no-xsd"
          buf_temp-param-name.profile-type = entry (buf_rule-call-param.codex_id, 'dis-card-type,dis-card-type,dis-card-type,dis-card-type,dis-card-type,dis-card-type,,,,,goods,clients,gds-grp,cli-grp,,,,edoc,chk-doc,thref,pdf,rep,ord,fdoc':U)
          buf_temp-param-name.pack-process-uniq-key-rec =
          substitute("&2&1&3&1&4&1&5"
                                                                     , chr(4)
                                                                     , buf_rule-call-param.call_id
                                                                     , buf_rule-call-param.codex_id
                                                                     , buf_rule-call-param.ruleset_id
                                                                     , buf_rule-call-param.order_id)
          .
        end.
      end.
    end.
    end.
    end.
  end.
end procedure.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure impxcbsh :
define input  parameter p-esys-id as integer   no-undo .
define input  parameter p-pck-num as integer   no-undo .
define input  parameter p-uniq-gate-rec as character no-undo .
define input  parameter p-dataseth as handle no-undo .
define parameter buffer buf_temp-xml-tables for temp-xml-tables.
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer   no-undo .
define variable v-esys-rec-ord as integer   no-undo .
define variable glog as logical   no-undo .
define variable v_qh as handle no-undo .
define variable v-dmp-ord-int64 as int64 no-undo .
define buffer buf_esys-route for ub.esys-route.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  run nws/cmd-bush.p persistent set v-esys-cmd-proc-handle no-error .
  if error-status :error  then do:
    delete procedure v-esys-cmd-proc-handle no-error .
    undo main-block, return error  substitute("&1 &2 &3&4Ошибка при запуске процедуры cmd-bush.p&4" +
                                        "&5&4&6"
                                        ,vss-workfile
                                        ,vss-revision
                                        ,vss-description
                                        ,chr(10)
                                        ,error-status:get-message(1)
                                        ,return-value ).
  end.
  run begin-create-command in v-esys-cmd-proc-handle
    (input 'cmd-esys-general':U
    ,input string(- p-esys-id)
    ,output v-esys-cmd-code
    ) no-error.
  if error-status :error  then do:
    delete procedure v-esys-cmd-proc-handle no-error .
    undo main-block, return error  substitute("Ошибка при создании команды &1&2&3&1&4"
                                                     , 'cmd-esys-general':U
                                                     , error-status:get-message(1)
                                                     , return-value
                                                     ).
  end.
  for each buf_temp-xml-tables where
          buf_temp-xml-tables.gate-handle_ = p-dataseth
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if buf_temp-xml-tables.tbl-name = "ThHeader" then next.
    if buf_temp-xml-tables.tbl-name = "header_" then next.
    create query v_qh.
    glog = v_qh:set-buffers( buf_temp-xml-tables.tbl-handle_) no-error.
    if error-status:error
    or
    not glog then do:
      undo main-block, return error substitute("Ошибка при попытке получить записи &1&2&3&2&4"
                                                              , buf_temp-xml-tables.tbl-name
                                                              , chr(10)
                                                              , error-status:get-message(1)
                                                              , return-value).
    end.
    glog = v_qh:query-prepare( substitute( "for each &1 ", buf_temp-xml-tables.tbl-name)) no-error .
    if error-status:error
    or
    not glog then do:
      undo main-block, return error substitute("Ошибка при попытке получить записи &1&2&3&2&4"
                                                            , buf_temp-xml-tables.tbl-name
                                                            , chr(10)
                                                            , error-status:get-message(1)
                                                            , return-value).
    end.
    glog = v_qh:query-open no-error .
    if error-status:error
    or
    not glog then do:
      undo main-block, return error substitute("Ошибка при попытке получить записи &1&2&3&2&4"
                                                            , buf_temp-xml-tables.tbl-name
                                                            , chr(10)
                                                            , error-status:get-message(1)
                                                            , return-value).
    end.
    _record:
    do while true
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      v_qh:get-next().
      IF v_qh:query-off-end then leave _record.
      run add-dump in v-esys-cmd-proc-handle
        (input v-esys-cmd-code
        ,input buf_temp-xml-tables.tbl-name
        ,input '+update'
        ,input buf_temp-xml-tables.tbl-handle_
        ,input p-uniq-gate-rec
        ,output v-esys-rec-ord
        ) no-error .
      if error-status:error then do:
        if valid-handle(v-esys-cmd-proc-handle) then do:
          delete procedure v-esys-cmd-proc-handle .
        end.
        undo main-block, return error substitute("Ошибка при добавлении записи &2 в команду с кодом &3&1&4&1&5"
                                            ,chr(10)
                                            ,buf_temp-xml-tables.tbl-name
                                            ,v-esys-cmd-code
                                            ,error-status:get-message(1)
                                            ,return-value
                                            ) .
      end.
    end.
    v_qh:query-close().
    if valid-handle(v_qh) then do:
      delete object v_qh.
      v_qh = ?.
    end.
  end.
  run send-command-esys in v-esys-cmd-proc-handle
    (input v-esys-cmd-code
    ,input string(- p-esys-id)
    ,input g#userid
    ,output v-dmp-ord-int64
    ) no-error.
  if error-status :error then do:
    delete procedure v-esys-cmd-proc-handle no-error.
    undo main-block, return error substitute("Ошибка отсылке во внешнюю систему &1 команды с кодом &2&3&4&3&5"
                                                     , p-esys-id
                                                     , v-esys-cmd-code
                                                     , chr(10)
                                                     , error-status:get-message(1)
                                                     , return-value
                                                     ).
  end.
  delete procedure v-esys-cmd-proc-handle no-error.
  for each buf_esys-route exclusive-lock where
          buf_esys-route.esys-id = - p-esys-id
      and buf_esys-route.esr-dump-ord = v-dmp-ord-int64
      and buf_esys-route.db-num = g#db-num
       and buf_esys-route.esr-cr-db-num = g#db-num
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    assign
    buf_esys-route.esr-last-pack = p-pck-num
    .
  end.
end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info12 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define stream stmXMLOut.
define stream stmXMLLog.
define stream strXMLIn.
define temp-table temp_xmllib_rec-list no-undo
    field recName       as character
    field recLevel      as integer
    field recOpenLine   as integer
    field recCloseLine  as integer
    field closed        as logical
    index pi is primary unique
        recName
        recLevel
    index cl
        closed
.
define temp-table temp_xmllib_rec-fld-list no-undo
    field recName       as character
    field recLevel      as integer
    field fldName       as character
    field fldOpenLine   as integer
    field fldCloseLine  as integer
    field closed        as logical
    index pi is primary unique
        recName
        recLevel
        fldName
    index fn
        fldName
    index cl
        closed
.
define temp-table temp_xmllib_rec no-undo
    field rec-key       as integer
    field recLevel      as integer
    field recOpenLine   as integer
    field recCloseLine  as integer
    field recName       as character
    field closed        as logical
    index pi is primary unique
        rec-key
    index nm
        recName
        closed
        rec-key
    index cl
        closed
    index rlv
        recName
        recLevel
        closed
        rec-key
.
define temp-table temp_xmllib_rec-fld no-undo
    field fld-key       as integer
    field rec-key       as integer
    field fldOpenLine   as integer
    field fldCloseLine  as integer
    field fldName       as character
    field fldValue      as character
    field closed        as logical
    index pi is primary unique
        fld-key
    index nm
        rec-key
        fldName
        closed
        fld-key
    index cl
        closed
.
define variable v-xmllib-rec-key            as integer      no-undo .
define variable v-xmllib-rec-fld-key        as integer      no-undo .
define variable v-xmllib-dirname            as character    no-undo .
define variable v-xmllib-filename           as character    no-undo .
define variable v-xmllib-log-filename       as character    no-undo .
define variable v-xmllib-log-handle         as handle       no-undo .
define variable v-xmllib-log-proc-name      as character    no-undo .
define variable v-xmllib-error-status       as logical      no-undo .
define variable v-xmllib-sax-reader-handle  as handle       no-undo .
define variable v-xmllib-prg-bar-handle     as handle       no-undo .
define variable v-xmllib-codepage-convert   as logical      no-undo .
define variable v-xmllib-codepage-source    as character    no-undo .
define variable v-xmllib-codepage-target    as character    no-undo .
procedure xmllib-clear-parse-data :
do
on error undo, return error
:
    empty temp-table temp_xmllib_rec-list.
    empty temp-table temp_xmllib_rec-fld-list.
    empty temp-table temp_xmllib_rec.
    empty temp-table temp_xmllib_rec-fld.
end.
end procedure.
procedure xmllib-add-rec-fld :
define input parameter p-rec-name       as character        no-undo.
define input parameter p-rec-fld-name   as character        no-undo.
    define buffer buf_rec-list        for temp_xmllib_rec-list.
    define buffer buf_rec-fld-list    for temp_xmllib_rec-fld-list.
do
for buf_rec-list
  , buf_rec-fld-list
on error undo, return error
:
    find first buf_rec-list
         where buf_rec-list.recName = p-rec-name
    no-error.
    if not available buf_rec-list
    then do:
        create buf_rec-list.
        assign
            buf_rec-list.recName        = p-rec-name
            buf_rec-list.recOpenLine    = 0
            buf_rec-list.recCloseLine   = 0
            buf_rec-list.closed         = yes
        .
    end.
    find first buf_rec-fld-list
         where buf_rec-fld-list.recName = p-rec-name
           and buf_rec-fld-list.fldName = p-rec-fld-name
    no-error.
    if not available buf_rec-fld-list
    then do:
        create buf_rec-fld-list.
        assign
            buf_rec-fld-list.recName        = p-rec-name
            buf_rec-fld-list.fldName        = p-rec-fld-name
            buf_rec-fld-list.fldOpenLine    = 0
            buf_rec-fld-list.fldCloseLine   = 0
            buf_rec-fld-list.closed         = yes
        .
    end.
end.
end procedure.
procedure xmllib-tag-open:
define input parameter v-tag-level  as integer      no-undo.
define input parameter v-tag-name   as character    no-undo.
define input parameter v-tag-value  as character    no-undo.
do
on error undo, return error
:
    assign
        v-tag-name = trim( v-tag-name )
    .
    put stream stmXMLOut unformatted
        substitute( "&1&2<&3&4&5>"
            , chr(10)
            , fill(" ", 4 * v-tag-level)
            , v-tag-name
            , ( if v-tag-value = "":U or v-tag-value = ? then "":U else " ":U )
            , v-tag-value
        )
    .
end.
end procedure.
procedure xmllib-tag-put:
define input parameter v-tag-level      as integer      no-undo.
define input parameter v-tag-name       as character    no-undo.
define input parameter v-tag-value      as character    no-undo.
define input parameter v-empty-mode     as integer      no-undo.
do
on error undo, return error
:
    assign
        v-tag-name = trim( v-tag-name )
    .
    if  v-empty-mode = 1
    or (v-empty-mode = 0 and (v-tag-value <> "":U and v-tag-value <> ?) )
    or (v-empty-mode = 2 and (v-tag-value <> "":U and v-tag-value <> ? and v-tag-value <> "0":U))
    or (v-empty-mode = 3 and (v-tag-value <> "":U and v-tag-value <> ? and caps(v-tag-value) <> "no":U))
    then do:
        run xmlchar-encode in this-procedure (
              input v-tag-value
            , output v-tag-value
        ).
        put stream stmXMLOut unformatted
            substitute( "&1&2<&3>&4</&3>"
                , chr(10)
                , fill(" ":U, 4 * v-tag-level)
                , v-tag-name
                , v-tag-value
            )
        .
    end.
end.
end procedure.
procedure xmllib-tag-put-null :
define input parameter p-tag-level  as integer      no-undo.
define input parameter p-tag-name   as character    no-undo.
do
on error undo, return error
:
    assign
        p-tag-name = trim( p-tag-name )
    .
    put stream stmXMLOut unformatted
        substitute( '&1&2<&3 nil="true" /&3>'
            , chr(10)
            , fill(" ":U, 4 * p-tag-level)
            , p-tag-name
        )
    .
end.
end procedure.
procedure xmllib-tag-close:
define input parameter v-tag-level as integer      no-undo.
define input parameter v-tag-name  as character    no-undo.
do
on error undo, return error
:
    assign
        v-tag-name = trim( v-tag-name )
    .
    put stream stmXMLOut unformatted
        substitute( "&1&2</&3>"
            , chr(10)
            , fill( " ":U, 4 * v-tag-level)
            , v-tag-name
        )
    .
end.
end procedure.
procedure xmllib-write-log:
define input parameter v-filename   as character    no-undo.
define input parameter v-log-level  as integer      no-undo.
define input parameter v-out-string as character    no-undo.
do
on error undo, return error
:
    output stream stmXMLLog to value( v-filename ) append.
    put stream stmXMLLog unformatted
        chr(10)
    .
    put stream stmXMLLog unformatted
        ( if v-log-level = 0
          or v-out-string = "&DLine":U
          or v-out-string = "&Line":U
          then "":U
          else cur-time-string-sec() + " ":U )
    .
    put stream stmXMLLog unformatted
        ( if v-out-string = "&Line":U
          then fill( "-":U, 80 )
          else if v-out-string = "&DLine":U
               then fill( "=":U, 80 )
               else v-out-string )
    .
    output stream stmXMLLog close.
end.
end procedure.
procedure xmllib-write-edt:
define input parameter v-editor-handle    as handle       no-undo.
define input parameter v-log-level        as integer      no-undo.
define input parameter v-out-string       as character    no-undo.
do
on error undo, return error
:
    if valid-handle ( v-editor-handle )
    then do:
        v-editor-handle :move-to-eof().
        v-editor-handle :insert-string( ( if v-log-level = 0
                                          or v-out-string = "&DLine":U
                                          or v-out-string = "&Line":U
                                          then "":U
                                          else cur-time-string-sec() + " ":U
                                      ) ).
        v-editor-handle :insert-string( ( if v-out-string = "&Line":U
                                          then fill( "-":U, 80 )
                                          else if v-out-string = "&DLine":U then fill("=":U, 80)
                                          else fill( " ":U, v-log-level) + v-out-string
                                      ) ).
        v-editor-handle :insert-string( chr(10) ).
    end.
end.
end procedure.
procedure xmllib-show-cnt:
define input parameter v-fillin-handle     as handle   no-undo.
do
on error undo, return error
:
    if valid-handle( v-fillin-handle )
    then do:
        assign
            v-fillin-handle :visible = true
        .
    end.
end.
end procedure.
procedure xmllib-hide-cnt:
define input parameter v-fillin-handle     as handle   no-undo.
do
on error undo, return error
:
    if valid-handle( v-fillin-handle )
    then do:
        assign v-fillin-handle :visible = false.
    end.
end.
end procedure.
procedure xmllib-write-cnt:
define input parameter v-fillin-handle    as handle       no-undo.
define input parameter v-fillin-string    as character    no-undo.
do
on error undo, return error
:
    if valid-handle( v-fillin-handle )
    then do:
        assign
            v-fillin-handle :SCREEN-value = v-fillin-string
        .
    end.
end.
end procedure.
procedure xmllib-write-header:
define input parameter p-first-file     as logical      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-list-file-name as character    no-undo.
define input parameter p-file-number    as integer      no-undo.
define input parameter p-have-prev      as logical      no-undo.
define input parameter p-prev-filename  as character    no-undo.
define input parameter p-parameter-list as character    no-undo.
    define variable v-counter    as integer        no-undo.
do
on error undo, return error
:
    output stream stmXMLOut to value( p-xml-file-name + "tmp" ) convert target "1251" append.
    put stream stmXMLOut unformatted
        "<?xml version='1.0' encoding='windows-1251'?>"
    .
    run xmllib-tag-open( input 0, input "root"          , input "":U ).
    run xmllib-tag-open( input 0, input "THheader"        , input "":U ).
    run xmllib-tag-put( input 1 , input "THfileName"      , input p-xml-file-name + "xml":U  , input 0 ).
    run xmllib-tag-put( input 1 , input "THfileNumber"    , input string( p-file-number     ), input 0 ).
    run xmllib-tag-put( input 1 , input "THhavePrev"      , input string( p-have-prev       ), input 3 ).
    run xmllib-tag-put( input 1 , input "THprevFileName"  , input p-prev-filename            , input 0 ).
    do v-counter = 1 to integer( entry( 1, p-parameter-list ) )
    :
        run xmllib-tag-put(
              input 1
            , input entry( 2 * v-counter, p-parameter-list )
            , input entry( 2 * v-counter + 1, p-parameter-list )
            , input 0
        ).
    end.
    run xmllib-tag-close( input 0, input "THheader" ).
    output stream stmXMLOut close.
    if p-list-file-name <> "":U
    then do:
        output stream stmXMLOut to value( p-list-file-name + "tmp" ) convert target "1251" append.
        if p-first-file = yes
        then do:
            put stream stmXMLOut unformatted
                "<?xml version='1.0' encoding='windows-1251'?>"
            .
            run xmllib-tag-open( input 0, input "OpenXML", input "" ).
        end.
        run xmllib-tag-open( input 1, input "THfile", input "" ).
        run xmllib-tag-put( input 2, input "THfileName"       , input p-xml-file-name + "xml":U  , input 0 ).
        run xmllib-tag-put( input 2, input "THfileNumber"     , input string( p-file-number     ), input 0 ).
        run xmllib-tag-put( input 2, input "THhavePrev"       , input string( p-have-prev       ), input 3 ).
        run xmllib-tag-put( input 2, input "THprevFileName"   , input p-prev-filename            , input 0 ).
        do v-counter = 1 to integer( entry( 1, p-parameter-list ) )
        :
            run xmllib-tag-put(
                input 2
                , input entry( 2 * v-counter, p-parameter-list )
                , input entry( 2 * v-counter + 1, p-parameter-list )
                , input 0
            ).
        end.
        run xmllib-tag-close( input 1, input "THfile" ).
        output stream stmXMLOut close.
    end.
end.
end procedure.
procedure xmllib-write-footer:
define input parameter p-last-file      as logical      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-list-file-name as character    no-undo.
define input parameter p-have-next      as logical      no-undo.
define input parameter p-next-file-name as character    no-undo.
    define variable v-error-num     as integer           no-undo.
do
on error undo, return error
:
    output stream stmXMLOut to value( p-xml-file-name + "tmp" ) convert target "1251" append.
    if p-have-next = yes
    then do:
        run xmllib-tag-open( input 0, input "footer", "" ).
        run xmllib-tag-put( input 1, input "haveNext"       , string( p-have-next ) , 3 ).
        run xmllib-tag-put( input 1, input "nextFileName"   , p-next-file-name      , 0 ).
        run xmllib-tag-close( input 0, input "footer" ).
    end.
    run xmllib-tag-close( input 0, input "root" ).
    output stream stmXMLOut close.
    run bge/os_copy.p (
          input "M"
        , input p-xml-file-name + "tmp"
        , input p-xml-file-name + "xml"
        , output v-error-num
    ).
    if p-last-file = yes
    and p-list-file-name <> "":U
    then do:
        output stream stmXMLOut to value( p-list-file-name + "tmp" ) convert target "1251" append.
            run xmllib-tag-close( input 0, input "OpenXML" ).
        output stream stmXMLOut close.
        run bge/os_copy.p (
              input "M"
            , input p-list-file-name + "tmp"
            , input p-list-file-name + "xml":U
            , output v-error-num
        ).
    end.
end.
end procedure.
procedure xmllib-filename :
define input parameter p-subdir             as character        no-undo.
define input parameter p-prefix             as character    no-undo.
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-list-file-name    as character    no-undo.
    define variable v-home-dir  as character    no-undo.
    define variable v-error-num as integer      no-undo.
do
on error undo, return error
:
    get-key-value section "OXML" key "oxml-dir" value v-home-dir.
    if v-home-dir = ?
    then do:
        message
          skip "Не найден параметр ini-файла, определяющий каталог экспорта."
          skip "Нет параметра oxml-dir в секции [OXML]."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    if p-subdir <> "":U
    then do:
        assign
            v-home-dir = substitute( "&1/out/&2", v-home-dir, p-subdir )
        .
    end.
    run gbl/dir-cre.p (
        input v-home-dir
    ) no-error.
    if error-status :error
    then do:
        message
          skip "Неверно задан каталог экспорта в ini-файле."
          skip "Не удаётся создать каталог, указанный параметром"
          skip "oxml-dir в секции [OXML]."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    run bge/genfname.p (
          input v-home-dir
        , input p-prefix
        , input ""
        , input "xml"
        , input "tmp"
        , output p-xml-file-name
    ).
    assign
        p-xml-file-name     = substring( p-xml-file-name, 1, length( p-xml-file-name ) - 3 )
        p-log-file-name     = v-home-dir + chr(92) + "actions.log"
        p-list-file-name    = v-home-dir + chr(92) + "lst":U + substring( p-xml-file-name, length( p-xml-file-name ) - 5, 5 ) + ".":U
    .
end.
end procedure.
procedure xmllib-check-file-size :
define input parameter p-out-filename   as character    no-undo.
define output parameter p-is-big        as logical      no-undo.
    define variable v-current-position    as integer        no-undo.
do
on error undo, return error
:
    assign
        v-current-position = seek( stmXMLOut )
    .
    if v-current-position / 1024 / 1024  >= 100
    then do:
        assign
            p-is-big = yes
        .
    end.
end.
end procedure.
procedure xmllib-parse-file :
define input parameter p-full-filename      as character        no-undo.
    define variable v-num-dirs              as integer      no-undo .
    define variable v-str                   as character    no-undo .
    define variable v-str-count             as int64        no-undo .
do
on error undo, return error
:
    assign
        v-num-dirs              = num-entries( p-full-filename,"\/":U )
        v-xmllib-error-status   = no
    .
    if v-num-dirs > 1
    then do:
        assign
            v-xmllib-filename = entry( v-num-dirs, p-full-filename, "\/":U )
            v-xmllib-dirname  = substring( p-full-filename, 1, length( p-full-filename ) - length( v-xmllib-filename ) - 1 )
        .
    end.
    else do:
        assign
            v-xmllib-filename = p-full-filename
            v-xmllib-dirname  = "":U
        .
    end.
    if valid-handle(v-xmllib-prg-bar-handle)
    then do:
if session :set-wait-state( "compiler" ) then.
      input stream strXMLIn from value(p-full-filename) .
      repeat
      :
        import stream strXMLIn unformatted v-str no-error .
        assign
          v-str-count = v-str-count + 1
        .
      end.
      input stream strXMLIn close .
if session :set-wait-state( "" ) then.
      run prg-bar_init-cb-handle in this-procedure ( input v-xmllib-prg-bar-handle ) .
      run prg-bar_new in this-procedure ( input 1 , input v-str-count) .
      run prg-bar_show in this-procedure .
    end.
    create sax-reader v-xmllib-sax-reader-handle.
    v-xmllib-sax-reader-handle :set-input-source( "FILE":U, p-full-filename ).
    v-xmllib-sax-reader-handle :sax-parse( ) no-error.
    if error-status :error
    then do:
        run xmllib-parse-error in this-procedure ( input substitute("&1 &2 &3&4Ошибка обработки XML файла.&4&5&4&5&4&7&4&8"
                                                                    ,vss-workfile
                                                                    ,vss-revision
                                                                    ,vss-description
                                                                    ,chr(10)
                                                                    ,return-value
                                                                    ,trim(error-status :get-message(1))
                                                                    ,trim(error-status :get-message(2))
                                                                    ,trim(error-status :get-message(3)))
                                                  ).
        undo, return error .
    end.
    if v-xmllib-error-status <> no
    then do:
        run xmllib-parse-error in this-procedure (
            input "*** При обработке XML файла были ошибки."
        ).
        delete object v-xmllib-sax-reader-handle.
    end.
    delete object v-xmllib-sax-reader-handle.
    if valid-handle(v-xmllib-prg-bar-handle)
    then do:
      run prg-bar_delete in this-procedure .
    end.
end.
end procedure.
procedure xmllib-parse-progressive :
define input parameter p-full-filename      as character no-undo .
define input parameter p-pack-data          as memptr no-undo .
define input parameter p-parse-first        as logical no-undo .
define input parameter p-first-err          as logical no-undo .
define output parameter p-parse-status as integer no-undo .
define variable v-num-dirs              as integer no-undo .
define variable glog                    as logical no-undo .
define variable v-pack-size             as int64 no-undo .
do
on error undo, return error
:
  if p-parse-first then do:
    if valid-handle(v-xmllib-sax-reader-handle)
    then do:
    end.
    assign
        v-num-dirs              = num-entries( p-full-filename,"\/":U )
        v-xmllib-error-status   = no
    .
    if v-num-dirs > 1
    then do:
        assign
            v-xmllib-filename = entry( v-num-dirs, p-full-filename, "\/":U )
            v-xmllib-dirname  = substring( p-full-filename, 1, length( p-full-filename ) - length( v-xmllib-filename ) - 1 )
        .
    end.
    else do:
        assign
            v-xmllib-filename = p-full-filename
            v-xmllib-dirname  = "":U
        .
    end.
    create sax-reader v-xmllib-sax-reader-handle.
    v-pack-size = get-size (p-pack-data) .
    if v-pack-size > 0 then
      glog = v-xmllib-sax-reader-handle :set-input-source( "MEMPTR":U, p-pack-data ) no-error.
    else
      glog = v-xmllib-sax-reader-handle :set-input-source( "FILE":U, p-full-filename ) no-error.
    if error-status :error
    or not glog
    then do:
      delete object v-xmllib-sax-reader-handle.
      run xmllib-parse-error in this-procedure ( input substitute("&1 &2 &3&4Ошибка обработки XML файла.&4&5&4&5&4&7&4&8"
                                                                  ,vss-workfile
                                                                  ,vss-revision
                                                                  ,vss-description
                                                                  ,chr(10)
                                                                  ,return-value
                                                                  ,trim(error-status :get-message(1))
                                                                  ,trim(error-status :get-message(2))
                                                                  ,trim(error-status :get-message(3)) )
                                                ).
      undo, return error .
    end.
    v-xmllib-sax-reader-handle :sax-parse-first( ) no-error.
  end.
  else do:
    v-xmllib-sax-reader-handle :sax-parse-next( ) no-error.
  end.
  if error-status :error
  then do:
    delete object v-xmllib-sax-reader-handle.
    run xmllib-parse-error in this-procedure ( input substitute("&1 &2 &3&4Ошибка обработки XML файла.&4&5&4&5&4&7&4&8"
                                                                ,vss-workfile
                                                                ,vss-revision
                                                                ,vss-description
                                                                ,chr(10)
                                                                ,return-value
                                                                ,trim(error-status :get-message(1))
                                                                ,trim(error-status :get-message(2))
                                                                ,trim(error-status :get-message(3)) )
                                              ).
    undo, return error .
  end.
  if v-xmllib-error-status <> no
  then do:
    run xmllib-parse-error in this-procedure (
        input "*** При обработке XML файла были ошибки."
    ).
    if p-first-err then do:
      delete object v-xmllib-sax-reader-handle.
    end.
    else do:
      v-xmllib-error-status = no.
    end.
  end.
  if v-xmllib-sax-reader-handle:parse-status = SAX-COMPLETE  then do:
    p-parse-status = SAX-COMPLETE.
    delete object v-xmllib-sax-reader-handle.
    return '':U.
  end.
  else do:
    p-parse-status = v-xmllib-sax-reader-handle:parse-status.
    return '':U.
  end.
end.
end procedure.
procedure StartElement :
define input parameter p-name-space     as character        no-undo.
define input parameter p-local-name     as character        no-undo.
define input parameter p-q-name         as character        no-undo.
define input parameter p-attributes     as handle           no-undo.
    define buffer buf_rec             for temp_xmllib_rec.
    define buffer buf_rec-fld         for temp_xmllib_rec-fld.
    define buffer buf_rec-list        for temp_xmllib_rec-list.
    define buffer buf_rec-fld-list    for temp_xmllib_rec-fld-list.
do
for buf_rec
  , buf_rec-fld
  , buf_rec-list
  , buf_rec-fld-list
on error undo, return error
:
    if valid-handle(v-xmllib-prg-bar-handle)
    then do:
      run prg-bar_stepto in this-procedure ( input SELF:LOCATOR-LINE-NUMBER ) .
    end.
    find first buf_rec-list
         where buf_rec-list.recName = p-q-name
    no-error.
    if available buf_rec-list
    then do:
        if buf_rec-list.closed = no
        then do:
            find first buf_rec-fld-list
                 where buf_rec-fld-list.recName = buf_rec-list.recName
                   and buf_rec-fld-list.fldName = p-q-name
            no-error.
            if available buf_rec-fld-list
            and buf_rec-list.recName = buf_rec-fld-list.recName
            then do:
                if buf_rec-fld-list.closed = no
                then do:
                    run xmllib-parse-error in this-procedure (
                        input substitute( "Ошибка 1 открытия поля <&1> записи <&2>: Поле с этим именем уже открыто на строке &3."
                                        , p-q-name
                                        , p-q-name
                                        , buf_rec-fld-list.fldOpenLine
                                        )
                    ).
                end.
                else do:
                    run xmllib-parse-rec-fld-open in this-procedure (
                          input buf_rec-list.recName
                        , input buf_rec-list.recLevel
                        , input buf_rec-fld-list.fldName
                    ).
                    assign
                        buf_rec-fld-list.closed         = no
                        buf_rec-fld-list.fldOpenLine    = v-xmllib-sax-reader-handle :locator-line-number
                        buf_rec-fld-list.fldCloseLine   = 0
                    .
                end.
            end.
            else do:
                assign
                    buf_rec-list.recLevel = buf_rec-list.recLevel + 1
                .
                run xmllib-parse-rec-open in this-procedure (
                      input buf_rec-list.recName
                    , input buf_rec-list.recLevel
                ).
                assign
                    buf_rec-list.closed         = no
                    buf_rec-list.recOpenLine    = v-xmllib-sax-reader-handle :locator-line-number
                    buf_rec-list.recCloseLine   = 0
                .
            end.
        end.
        else do:
            run xmllib-parse-rec-open in this-procedure (
                  input buf_rec-list.recName
                , input buf_rec-list.recLevel
            ).
            assign
                buf_rec-list.closed         = no
                buf_rec-list.recOpenLine    = v-xmllib-sax-reader-handle :locator-line-number
                buf_rec-list.recCloseLine   = 0
            .
        end.
    end.
    else do:
        open-record:
        for each buf_rec-fld-list
           where buf_rec-fld-list.fldName = p-q-name
        :
            find first buf_rec-list
                 where buf_rec-list.recName = buf_rec-fld-list.recName
                   and buf_rec-list.closed  = no
            no-error.
            if available buf_rec-list
            then do:
                run xmllib-parse-rec-fld-open in this-procedure (
                      input buf_rec-list.recName
                    , input buf_rec-list.recLevel
                    , input buf_rec-fld-list.fldName
                ).
                assign
                    buf_rec-fld-list.recLevel       = buf_rec-list.recLevel
                    buf_rec-fld-list.closed         = no
                    buf_rec-fld-list.fldOpenLine    = v-xmllib-sax-reader-handle :locator-line-number
                    buf_rec-fld-list.fldCloseLine   = 0
                .
                leave open-record.
            end.
        end.
    end.
end.
end procedure.
procedure Characters :
define input parameter p-char-data  as memptr.
define input parameter p-numchars   as integer.
    define variable v-data-string    as character    no-undo.
    define variable v-cp-utf8           as integer no-undo init 65001 .
    define variable v-cp-windows1251    as integer no-undo init 1251 .
    define buffer buf_xmllib_rec             for temp_xmllib_rec.
    define buffer buf_xmllib_rec-fld         for temp_xmllib_rec-fld.
    define buffer buf_xmllib_rec-list        for temp_xmllib_rec-list.
    define buffer buf_xmllib_rec-fld-list    for temp_xmllib_rec-fld-list.
do
for buf_xmllib_rec
  , buf_xmllib_rec-fld
  , buf_xmllib_rec-list
  , buf_xmllib_rec-fld-list
on error undo, return error
:
    find first buf_xmllib_rec-list
         where buf_xmllib_rec-list.closed = no
    no-error.
    if available buf_xmllib_rec-list
    then do:
        find first buf_xmllib_rec-fld-list
             where buf_xmllib_rec-fld-list.closed = no
        no-error.
        if available buf_xmllib_rec-fld-list
        and buf_xmllib_rec-fld-list.recName  = buf_xmllib_rec-list.recName
        and buf_xmllib_rec-fld-list.recLevel = buf_xmllib_rec-list.recLevel
        then do:
            find last buf_xmllib_rec
                where buf_xmllib_rec.recName  = buf_xmllib_rec-list.recName
                  and buf_xmllib_rec.recLevel = buf_xmllib_rec-list.recLevel
                  and buf_xmllib_rec.closed   = no
            use-index nm
            no-error.
            if available buf_xmllib_rec
            then do:
                find last buf_xmllib_rec-fld
                    where buf_xmllib_rec-fld.rec-key = buf_xmllib_rec.rec-key
                      and buf_xmllib_rec-fld.fldName = buf_xmllib_rec-fld-list.fldName
                      and buf_xmllib_rec-fld.closed = no
                use-index nm
                no-error.
                if available buf_xmllib_rec-fld
                then do:
                    assign
                        v-data-string = get-string( p-char-data, 1, get-size( p-char-data ) )
                    .
                    if v-xmllib-codepage-convert = yes
                    then do:
                      assign
                          v-data-string = codepage-convert( v-data-string , v-xmllib-codepage-target , v-xmllib-codepage-source )
                      .
                    end.
                    run xmlchar-decode in this-procedure (
                        input v-data-string
                        , output v-data-string
                    ).
                    assign
                        buf_xmllib_rec-fld.fldValue = trim( substitute( "&1&2", buf_xmllib_rec-fld.fldValue, v-data-string ) )
                    .
                end.
            end.
        end.
    end.
end.
end procedure.
procedure EndElement :
define input parameter p-name-space     as character        no-undo.
define input parameter p-local-name     as character        no-undo.
define input parameter p-q-name         as character        no-undo.
    define buffer buf_rec             for temp_xmllib_rec.
    define buffer buf_rec-fld         for temp_xmllib_rec-fld.
    define buffer buf_rec-list        for temp_xmllib_rec-list.
    define buffer buf_rec-fld-list    for temp_xmllib_rec-fld-list.
do
for buf_rec
  , buf_rec-fld
  , buf_rec-list
  , buf_rec-fld-list
on error undo, return error
:
    find last buf_rec-list
        where buf_rec-list.recName = p-q-name
    use-index pi
    no-error.
    if available buf_rec-list
    then do:
        if buf_rec-list.closed = yes
        then do:
            run xmllib-parse-error in this-procedure (
                input substitute( "Ошибка закрытия записи или поля <&1>: Нет метки открытой записи."
                                , p-q-name
                                )
            ).
        end.
        else do:
            find last buf_rec
                where buf_rec.recName  = buf_rec-list.recName
                  and buf_rec.recLevel = buf_rec-list.recLevel
                  and buf_rec.closed   = no
            use-index nm
            no-error.
            if not available buf_rec
            then do:
                run xmllib-parse-error in this-procedure (
                    input substitute( "Ошибка закрытия записи или поля <&1> уровня &2: Нет открытой записи."
                                    , p-q-name
                                    , buf_rec-list.recLevel
                                    )
                ).
            end.
            else do:
                find first buf_rec-fld-list
                     where buf_rec-fld-list.recName  = buf_rec.recName
                       and buf_rec-fld-list.recLevel = buf_rec.recLevel
                       and buf_rec-fld-list.fldName  = p-q-name
                       and buf_rec-fld-list.closed   = no
                no-error.
                if not available buf_rec-fld-list
                then do:
                    if buf_rec.recName <> p-q-name
                    then do:
                        run xmllib-parse-error in this-procedure (
                            input substitute( "Ошибка закрытия записи <&1>: Имя открытой записи не совпадает с именем метки."
                                            , buf_rec.recName
                                            )
                        ).
                    end.
                    else do:
                        assign
                            buf_rec.closed              = yes
                            buf_rec.recCloseLine        = v-xmllib-sax-reader-handle :locator-line-number
                            buf_rec-list.recCloseLine   = v-xmllib-sax-reader-handle :locator-line-number
                        .
                        if buf_rec-list.recLevel > 0
                        then do:
                            assign
                                buf_rec-list.recLevel = buf_rec-list.recLevel - 1
                            .
                            for each buf_rec-fld-list
                               where buf_rec-fld-list.recName = buf_rec-list.recName
                            :
                                assign
                                    buf_rec-fld-list.recLevel = buf_rec-fld-list.recLevel - 1
                                .
                            end.
                        end.
                        else do:
                            assign
                                buf_rec-list.closed         = yes
                            .
                        end.
                    end.
                end.
                else do:
                    find last buf_rec-fld
                        where buf_rec-fld.rec-key = buf_rec.rec-key
                          and buf_rec-fld.fldName = buf_rec-fld-list.fldName
                          and buf_rec-fld.closed  = no
                    use-index nm
                    no-error.
                    if not available buf_rec-fld
                    then do:
                        run xmllib-parse-error in this-procedure (
                            input substitute( "Ошибка 2 закрытия поля <&1>: Не найдено открытое поле с этим именем в записи <&2> уровня &3."
                                            , buf_rec-fld-list.fldName
                                            , buf_rec.recName
                                            , buf_rec.recLevel
                                            )
                        ).
                    end.
                    else do:
                        assign
                            buf_rec-fld.closed              = yes
                            buf_rec-fld-list.closed         = yes
                            buf_rec-fld.fldCloseLine        = v-xmllib-sax-reader-handle :locator-line-number
                            buf_rec-fld-list.fldCloseLine   = v-xmllib-sax-reader-handle :locator-line-number
                        .
                    end.
                end.
            end.
        end.
    end.
    else do:
        close-field-rec:
        for each buf_rec-fld-list
           where buf_rec-fld-list.fldName = p-q-name
        :
            find first buf_rec-list
                 where buf_rec-list.recName  = buf_rec-fld-list.recName
                   and buf_rec-list.recLevel = buf_rec-fld-list.recLevel
                   and buf_rec-list.closed   = no
            no-error.
            if available buf_rec-list
            then do:
                find last buf_rec
                    where buf_rec.recName  = buf_rec-list.recName
                      and buf_rec.recLevel = buf_rec-list.recLevel
                      and buf_rec.closed   = no
                use-index nm
                no-error.
                if not available buf_rec
                then do:
                    run xmllib-parse-error in this-procedure (
                        input substitute( "Ошибка закрытия поля <&1>: Нет открытой записи."
                                        , p-q-name
                                        )
                    ).
                end.
                else do:
                    find last buf_rec-fld
                        where buf_rec-fld.rec-key = buf_rec.rec-key
                          and buf_rec-fld.fldName = buf_rec-fld-list.fldName
                          and buf_rec-fld.closed  = no
                    use-index nm
                    no-error.
                    if not available buf_rec-fld
                    then do:
                        run xmllib-parse-error in this-procedure (
                            input substitute( "Ошибка 1 закрытия поля <&1>: Не найдено открытое поле с этим именем в записи <&2> уровня &3."
                                            , buf_rec-fld-list.fldName
                                            , buf_rec.recName
                                            , buf_rec.recLevel
                                            )
                        ).
                    end.
                    else do:
                        assign
                            buf_rec-fld.closed              = yes
                            buf_rec-fld-list.closed         = yes
                            buf_rec-fld.fldCloseLine        = v-xmllib-sax-reader-handle :locator-line-number
                            buf_rec-fld-list.fldCloseLine   = v-xmllib-sax-reader-handle :locator-line-number
                        .
                    end.
                end.
                leave close-field-rec.
            end.
        end.
    end.
end.
end procedure.
procedure Error :
define input parameter p-error-message     as character        no-undo.
do
on error undo, return error
:
    run xmllib-parse-error in this-procedure (
        input p-error-message
    ).
    assign
        v-xmllib-error-status = yes
    .
end.
end procedure.
procedure xmllib-parse-error :
define input parameter p-err-message    as character        no-undo.
do
on error undo, return error
:
    if valid-handle(v-xmllib-log-handle) then do:
      run value(v-xmllib-log-proc-name) in  v-xmllib-log-handle
               (input substitute("&1Файл:    &2 &3&1Строка &4&1&5"
                                 ,chr(10)
                                 ,v-xmllib-dirname
                                 ,v-xmllib-filename
                                 ,(if valid-handle(v-xmllib-sax-reader-handle)
                                   then v-xmllib-sax-reader-handle :locator-line-number
                                   else ?)
                                 ,p-err-message)).
    end.
    else do:
      if v-xmllib-log-filename = "":U
      then do:
          message
                  vss-workfile vss-revision vss-description
              skip "Файл:   " v-xmllib-dirname v-xmllib-filename
              skip "Строка: " (if valid-handle(v-xmllib-sax-reader-handle)
                               then v-xmllib-sax-reader-handle :locator-line-number
                               else ?)
              skip(1)
              skip p-err-message
              skip return-value
              skip trim( error-status :get-message( 1 ) )
                  trim( error-status :get-message( 2 ) )
                  trim( error-status :get-message( 3 ) )
          view-as alert-box error.
          undo, return error.
      end.
      else do:
        output to value( v-xmllib-log-filename ).
        put unformatted
            substitute( "&1&2", chr(10), p-err-message )
        .
        output close.
      end.
    end.
end.
end procedure.
procedure xmllib-set-log-filename :
define input parameter p-log-filename   as character        no-undo.
do
on error undo, return error
:
    run gbl/fileapnd.p (
          input p-log-filename
        , input "":U
        , input 10
    ) no-error.
    if error-status :error
    then do:
        assign
            v-xmllib-log-filename = "":U
        .
    end.
    else do:
        assign
            v-xmllib-log-filename = p-log-filename
        .
    end.
end.
end procedure.
procedure xmllib-set-log-handle :
define input parameter p-log-handle    as handle        no-undo.
define input parameter p-log-proc-name as character no-undo .
do
on error undo, return error
:
    if valid-handle(p-log-handle)
    and lookup(p-log-proc-name, p-log-handle:internal-entries) > 0
    then do:
      assign
      v-xmllib-log-handle    = p-log-handle
      v-xmllib-log-proc-name = p-log-proc-name
      .
    end.
    else do:
      assign
      v-xmllib-log-handle    = ?
      v-xmllib-log-proc-name = '':U
      .
    end.
end.
end procedure.
procedure xmllib-set-prg-bar-handle :
define input parameter p-handle    as handle        no-undo.
do
on error undo, return error
:
    if valid-handle(p-handle)
    then do:
      assign
        v-xmllib-prg-bar-handle = p-handle
      .
    end.
    else do:
      assign
        v-xmllib-prg-bar-handle = ?
      .
    end.
end.
end procedure.
procedure xmllib-set-codepage-convert :
  define input  parameter p-codepage-source as character no-undo .
  define input  parameter p-codepage-target as character no-undo .
do
on error undo, return error return-value
:
  if ( p-codepage-source <> "" and p-codepage-target <> "" )
  then do:
    assign
      v-xmllib-codepage-convert = yes
      v-xmllib-codepage-source  = p-codepage-source
      v-xmllib-codepage-target  = p-codepage-target
    .
  end.
  else do:
    assign
      v-xmllib-codepage-convert = no
      v-xmllib-codepage-source  = ""
      v-xmllib-codepage-target  = ""
    .
  end.
end.
end procedure.
procedure xmllib-parse-rec-open :
define input parameter p-rec-name   as character        no-undo.
define input parameter p-rec-level  as integer          no-undo.
    define buffer buf_temp_xmllib_rec       for temp_xmllib_rec.
do
for buf_temp_xmllib_rec
on error undo, return error
:
     find first buf_temp_xmllib_rec
         where buf_temp_xmllib_rec.recName = p-rec-name
           and buf_temp_xmllib_rec.recLevel = p-rec-level
           and buf_temp_xmllib_rec.closed  = no
    use-index nm
    no-error.
    if available buf_temp_xmllib_rec
    then do:
        run xmllib-parse-error in this-procedure (
            input substitute( "Ошибка 2 открытия записи <&1>: Запись с этим именем и уровнем &2 уже открыта на строке &3."
                            , p-rec-name
                            , p-rec-level
                            , buf_temp_xmllib_rec.recOpenLine
                            )
        ).
    end.
    else do:
        assign
            v-xmllib-rec-key    = v-xmllib-rec-key + 1
        .
        create buf_temp_xmllib_rec.
        assign
            buf_temp_xmllib_rec.rec-key         = v-xmllib-rec-key
            buf_temp_xmllib_rec.recOpenLine     = v-xmllib-sax-reader-handle :locator-line-number
            buf_temp_xmllib_rec.recCloseLine    = 0
            buf_temp_xmllib_rec.recName         = p-rec-name
            buf_temp_xmllib_rec.recLevel        = p-rec-level
            buf_temp_xmllib_rec.closed          = no
        .
    end.
end.
end procedure.
procedure xmllib-parse-rec-fld-open :
define input parameter p-rec-name   as character        no-undo.
define input parameter p-rec-level  as integer          no-undo.
define input parameter p-fld-name   as character        no-undo.
    define buffer buf_temp_xmllib_rec       for temp_xmllib_rec.
    define buffer buf_temp_xmllib_rec-fld   for temp_xmllib_rec-fld.
do
for buf_temp_xmllib_rec
  , buf_temp_xmllib_rec-fld
on error undo, return error substitute( "Ошибка в xmllib-parse-rec-fld-open. &1. &2. &3"
                                        , return-value
                                        , trim( error-status :get-message( 1 ) )
                                        , trim( error-status :get-message( 2 ) ) )
:
    find last buf_temp_xmllib_rec
        where buf_temp_xmllib_rec.recName   = p-rec-name
          and buf_temp_xmllib_rec.recLevel  = p-rec-level
          and buf_temp_xmllib_rec.closed    = no
    use-index nm
    no-error.
    if not available buf_temp_xmllib_rec
    then do:
        run xmllib-parse-error in this-procedure (
            input substitute( "Ошибка 2 открытия поля <&2> в записи <&1> уровня &3: Нет открытой записи."
                            , p-rec-name
                            , p-fld-name
                            , p-rec-level
                            )
        ).
    end.
    else do:
        find last buf_temp_xmllib_rec-fld
            where buf_temp_xmllib_rec-fld.rec-key  = buf_temp_xmllib_rec.rec-key
              and buf_temp_xmllib_rec-fld.fldName  = p-fld-name
              and buf_temp_xmllib_rec-fld.closed   = no
        use-index nm
        no-error.
        if available buf_temp_xmllib_rec-fld
        then do:
            run xmllib-parse-error in this-procedure (
                input substitute( "Ошибка 3 открытия поля <&2> в записи <&1>: Поле с этим именем уже открыто на строке &3."
                                , p-rec-name
                                , p-fld-name
                                , buf_temp_xmllib_rec-fld.fldOpenLine
                                )
            ).
        end.
        else do:
            assign
                v-xmllib-rec-fld-key    = v-xmllib-rec-fld-key + 1
            .
            create buf_temp_xmllib_rec-fld.
            assign
                buf_temp_xmllib_rec-fld.fld-key         = v-xmllib-rec-fld-key
                buf_temp_xmllib_rec-fld.rec-key         = buf_temp_xmllib_rec.rec-key
                buf_temp_xmllib_rec-fld.fldOpenLine     = v-xmllib-sax-reader-handle :locator-line-number
                buf_temp_xmllib_rec-fld.fldCloseLine    = 0
                buf_temp_xmllib_rec-fld.fldName         = p-fld-name
                buf_temp_xmllib_rec-fld.closed          = no
            .
        end.
    end.
end.
end procedure.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info14, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info14 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info14 )
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
procedure getoxmlh :
define input parameter p-xml-file-name as character no-undo .
define input parameter p-pack-data     as memptr no-undo .
define input parameter p-headerh as handle no-undo .
define input parameter p-delivery-method as integer no-undo .
define variable v-parse-status as integer no-undo .
define buffer buf_rec for temp_xmllib_rec.
define buffer buf_rec-fld for temp_xmllib_rec-fld.
define variable v-end-of-header as logical   no-undo .
define variable v-ii as integer   no-undo .
define variable v-root-name as character no-undo .
define buffer buf_temp_xmllib_rec for temp_xmllib_rec.
do
on error undo, return error return-value
:
  run xmllib-clear-parse-data in this-procedure.
  if valid-handle(p-headerh) then do:
  do v-ii = 1 to p-headerh:num-fields:
    run xmllib-add-rec-fld  in this-procedure (
                                                 input p-headerh:table
                                                ,input (p-headerh:buffer-field(v-ii):name)
                                              )  .
  end.
  end.
  case p-delivery-method:
    when integer('3':U) then do:
      v-root-name = "Oracle_Retail".
      run xmllib-add-rec-fld  in this-procedure (
                                                    input v-root-name
                                                  ,input ""
                                                )  .
    end.
    when integer('5':U) then do:
      run xmllib-add-rec-fld  in this-procedure (
                                                    input "ORDER_"
                                                  ,input ""
                                                )  .
      run xmllib-add-rec-fld  in this-procedure (
                                                    input "STATUS__"
                                                  ,input ""
                                                )  .
      run xmllib-add-rec-fld  in this-procedure (
                                                    input "ORDRSP_"
                                                  ,input ""
                                                )  .
      run xmllib-add-rec-fld  in this-procedure (
                                                    input "DESADV_"
                                                  ,input ""
                                                )  .
      run xmllib-add-rec-fld  in this-procedure (
                                                    input "RECADV_"
                                                  ,input ""
                                                )  .
    end.
    when integer('9':U) then do:
            run xmllib-add-rec-fld  in this-procedure (
                                                    input "statusReport"
                                                  ,input ""
                                                )  .
    end.
    when integer('11':U) then do:
      v-root-name = "".
      run xmllib-add-rec-fld  in this-procedure (
                                                    input "ERPRN-GC"
                                                  ,input ""
                                                )  .
    end.
    otherwise do:
      v-root-name = "".
      run xmllib-add-rec-fld  in this-procedure (
                                                input v-root-name
                                               ,input ""
                                            )  .
    end.
  end case.
  run xmllib-parse-progressive ( input p-xml-file-name
                                ,input p-pack-data
                                ,input yes
                                ,input no
                                ,output v-parse-status) no-error .
  repeat while not (error-status:error
                    or
                    v-parse-status = sax-complete
                    or available buf_temp_xmllib_rec
                    ):
    if valid-handle(p-headerh)  then do:
    find first buf_temp_xmllib_rec where
              buf_temp_xmllib_rec.recname = p-headerh:table
          and buf_temp_xmllib_rec.closed = yes no-error.
    end.
    else do:
      find first buf_temp_xmllib_rec no-error.
    end.
    error-status:error = no .
    run xmllib-parse-progressive ( input p-xml-file-name
                                  ,input p-pack-data
                                  ,input no
                                  ,input no
                                  ,output v-parse-status) no-error .
  end.
end.
end procedure.
define variable vss-include-info15 as character format "X(65)" no-undo
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function get-short-pack-name returns character ( input p-action as character
                                                ,input p-pack-num as integer
                                                ,input p-delivery-method as integer
                                                ,input p-custom-pack-name as character
                                                ,output p-custom-flag as logical
                                                ):
define variable v-short-pack-name as character no-undo .
define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd.
define buffer buf_clients for ub.clients.
define variable v-int-point as character no-undo .
define variable v-type as character no-undo .
case p-delivery-method:
 when integer('3':U) then do:
   find first buf_clients no-lock where
            buf_clients.db-num = g#db-num
         and buf_clients.obj-type = 'маг':U no-error .
   if not available buf_clients then do:
    find first buf_clients no-lock where
              buf_clients.db-num = g#db-num
          and buf_clients.obj-type = 'скл':U no-error .
   end.
   case p-action:
     when "put"
     or when "fput" then do:
        v-short-pack-name = (if available buf_clients
                           then  string(buf_clients.obj-code, (if buf_clients.obj-code > 999 then "9999" else "999"))
                           else "___") + "-" + "000" + "_"
                           + string( p-pack-num, "999999999":U ) + ".DAT":U.
     end.
     when "get"
     or when "fget" then do:
       v-short-pack-name = "000" + "-" +
                           (if available buf_clients
                           then  string(buf_clients.obj-code, (if buf_clients.obj-code > 999 then "9999" else "999"))
                           else "___") + "_"
                           + string( p-pack-num, "999999999":U ) + ".DAT":U.
     end.
   end case.
   p-custom-flag = yes.
 end.
 when integer('5':U) then do:
   if p-action = "get" then do:
     find first buf_esys-pck-rcvd  where
                buf_esys-pck-rcvd.espr-pack-num = p-pack-num - 1
            and buf_esys-pck-rcvd.esys-id = p-esys-id
            and buf_esys-pck-rcvd.db-num = p-db-num
            and buf_esys-pck-rcvd.espr-cr-db-num = g#db-num no-error.
     if available buf_esys-pck-rcvd
     and (p-custom-pack-name = ""
          or
          num-entries(p-custom-pack-name, "_") < 2
          or  (num-entries(buf_esys-pck-rcvd.custom-pack-name, "_") >= 2
               and entry(2, buf_esys-pck-rcvd.custom-pack-name, "_") >= entry(2, p-custom-pack-name, "_")
               )
          ) then do:
       p-custom-flag = yes.
       return ''.
     end.
   end.
   p-custom-flag = yes.
   v-short-pack-name = p-custom-pack-name.
 end.
 when integer('9':U) then do:
   p-custom-flag = yes.
   v-short-pack-name = p-custom-pack-name.
 end.
 when integer('11':U) then do:
   case p-action:
     when "put"
     or when "fput" then do:
       run db-attr-value in this-procedure
           (input g#db-num
           ,input 'int-point':U
           ,output v-int-point
           ,output v-type
           ) no-error .
       p-custom-flag = yes.
       v-short-pack-name = v-int-point + "_00000_" + string(p-pack-num) + "_"
                         + string(day(now), "99") + string(month(now), "99") + string(year(now), "9999")
                         + substring(string(TIME, "HH:MM:SS"), 1, 2)
                         + substring(string(TIME, "HH:MM:SS"), 4, 2)
                         + substring(string(TIME, "HH:MM:SS"), 7, 2)
                         + ".xml" .
     end.
     when "get"
     or when "fget" then do:
       p-custom-flag = yes.
       v-short-pack-name = p-custom-pack-name.
     end.
   end case.
 end.
 otherwise do:
   v-short-pack-name = "o":U + string( p-pack-num, "999999999":U ) + ".":U.
 end.
end case.
return v-short-pack-name.
end function.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure get-xcnf_get-xcnf :
define input  parameter p-esys-id as integer no-undo .
define input  parameter p-db-num as integer   no-undo .
define input  parameter p-cr-db-num as integer   no-undo .
define input  parameter p-pack-num as integer   no-undo .
define input  parameter p-delivery-method as integer no-undo .
define parameter buffer buf_temp-esys-pck-sent for THpck-sent.
define parameter buffer buf_temp-esys-pck-rcvd for THpck-rcvd.
define parameter buffer curr_temp-esys-pck-sent for THcurr-pack.
define output parameter p-rec-cnt as integer   no-undo .
define buffer buf_esys-pck-keys for ub.esys-pck-keys.
define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd.
define buffer buf_esys-pck-sent for ub.esys-pck-sent.
define buffer buf_esys-route for ub.esys-route.
define buffer buf_esys-all-attr for ub.esys-all-attr.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-del-cnt as integer no-undo .
define variable v-del-pck-num as integer   no-undo.
define frame del-route
v-del-pck-num   label "Пакет N" format ">>>>>>>>>9" skip
v-del-cnt       label "Записей" format ">>>>>>>>>9"
with view-as dialog-box side-labels 1 columns three-d title "Удаление маршрутизации"
.
main-block:
do
on error undo, return error return-value
:
  if p-delivery-method <> integer('5':U) then do:
    find first curr_temp-esys-pck-sent where
              curr_temp-esys-pck-sent.THesys-id = p-esys-id
          and curr_temp-esys-pck-sent.THpack-num = p-pack-num no-error.
    if not available curr_temp-esys-pck-sent then do:
      undo, return error  substitute("Не найдена запись о текущем пакете &1 THcurr-pack в XML файлe &2:&3&4"
                                      , p-pack-num
                                      , p-xml-file-name
                                      , chr(10)
                                      , error-status:get-message(1)).
    end.
    p-rec-cnt = p-rec-cnt + 1.
    run cur-time in this-procedure ( output v-today, output v-time) no-error .
    if error-status :error then do:
    .
      undo, return error.
    end.
    if trim( curr_temp-esys-pck-sent.THcrc-pack ) = "" then do:
      undo, return error  substitute( "Ошибка обработки пакета: пакет N &1 в XML файлe &2 не имеет ключа!!!"
                                    , p-pack-num
                                    , p-xml-file-name ).
    end.
    if num-entries( curr_temp-esys-pck-sent.THcrc-pack, chr(32) ) < 4 then do:
      undo, return error  substitute( "Ошибка обработки пакета: некорректный ключ (&1) пакета N &2 !!!"
                                  , curr_temp-esys-pck-sent.THcrc-pack
                                  , p-pack-num ).
    end.
  end.
  if p-delivery-method <> integer('5':U) then do:
    for each buf_temp-esys-pck-sent
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      p-rec-cnt = p-rec-cnt + 1.
      find buf_esys-pck-rcvd exclusive-lock
        where buf_esys-pck-rcvd.esys-id   = p-esys-id
          and buf_esys-pck-rcvd.db-num   = p-db-num
          and buf_esys-pck-rcvd.espr-cr-db-num   = p-cr-db-num
          and buf_esys-pck-rcvd.espr-pack-num = buf_temp-esys-pck-sent.THpack-num
        no-error.
      if not available buf_esys-pck-rcvd then do:
        create buf_esys-pck-rcvd.
        assign
        buf_esys-pck-rcvd.esys-id    = p-esys-id
        buf_esys-pck-rcvd.db-num     = p-db-num
        buf_esys-pck-rcvd.espr-cr-db-num     = p-cr-db-num
        buf_esys-pck-rcvd.espr-pack-num   = buf_temp-esys-pck-sent.THpack-num
        buf_esys-pck-rcvd.espr-rcvd       = buf_temp-esys-pck-sent.THrcvd
        buf_esys-pck-rcvd.espr-rcvd-recs  = 0
        buf_esys-pck-rcvd.espr-total-recs = buf_temp-esys-pck-sent.THtotal-recs
        buf_esys-pck-rcvd.espr-crc-pack   = buf_temp-esys-pck-sent.THcrc-pack
        buf_esys-pck-rcvd.custom-pack-name = buf_temp-esys-pck-sent.THfilename
        .
        find first buf_esys-all-attr share-lock where
                buf_esys-all-attr.attr-code = 'custom-pack-name':U
            and buf_esys-all-attr.table-name = 'esys-pck-rcvd':U
            and buf_esys-all-attr.key1 = buf_esys-pck-rcvd.espr-pack-num
            and buf_esys-all-attr.key2 = p-esys-id
            and buf_esys-all-attr.key5 = p-db-num
            and buf_esys-all-attr.key6 = p-cr-db-num no-error.
        if available buf_esys-all-attr then do:
          buf_esys-pck-rcvd.custom-pack-name = buf_esys-all-attr.attr-value.
          delete buf_esys-all-attr.
        end.
      end.
    end.
  end.
  for each buf_temp-esys-pck-rcvd
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    p-rec-cnt = p-rec-cnt + 1.
    find buf_esys-pck-sent share-lock
      where buf_esys-pck-sent.esys-id  = p-esys-id
        and buf_esys-pck-sent.db-num   = p-db-num
        and buf_esys-pck-sent.esps-cr-db-num = p-cr-db-num
        and buf_esys-pck-sent.esps-pack-num = buf_temp-esys-pck-rcvd.THpack-num
      no-error.
    if available buf_esys-pck-sent then do:
      assign
        v-del-cnt = 0
      .
      view frame del-route .
      for each buf_esys-route
        where buf_esys-route.esys-id  = buf_esys-pck-sent.esys-id
          and buf_esys-route.db-num    = buf_esys-pck-sent.db-num
          and buf_esys-route.esr-cr-db-num    = buf_esys-pck-sent.esps-cr-db-num
          and buf_esys-route.esr-last-pack = buf_esys-pck-sent.esps-pack-num
      on error  undo, return error substitute("&1. error buf_esys-route &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      on endkey undo, return error substitute("&1. endkey buf_esys-route")
      on stop   undo, return error substitute("&1. stop buf_esys-route")
      :
        assign
          v-del-cnt = v-del-cnt + 1
        .
        do with frame del-route
        :
          assign
            v-del-pck-num :screen-value   = string( buf_esys-route.esr-last-pack, v-del-pck-num :format)
            v-del-cnt :screen-value       = string( v-del-cnt, v-del-cnt :format)
          .
        end.
        delete buf_esys-route.
      end.
      hide frame del-route .
      transaction_block_pck-rcvd:
      do
      on error  undo, return error substitute("&1. error transaction_block_pck-rcvd &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      on endkey undo, return error substitute("&1. endkey transaction_block_pck-rcvd")
      on stop   undo, return error substitute("&1. stop transaction_block_pck-rcvd")
      :
        assign
          buf_esys-pck-sent.esps-rcvd        = yes
          buf_esys-pck-sent.esps-rcvdDate    = buf_temp-esys-pck-rcvd.thrcvddate
          buf_esys-pck-sent.esps-RcvdTimeInt = buf_temp-esys-pck-rcvd.thrcvdtimeint
          buf_esys-pck-sent.esps-RcvdTime    = string( buf_temp-esys-pck-rcvd.thrcvdtimeint, "HH:MM:SS" )
        .
      end.
    end.
    delete buf_temp-esys-pck-rcvd.
  end.
end.
end procedure.
procedure get-xcnf_set-xcnf :
define input  parameter p-esys-id as integer no-undo .
define input  parameter p-db-num as integer   no-undo .
define input  parameter p-cr-db-num as integer   no-undo .
define input  parameter p-pack-num as integer   no-undo .
define input  parameter p-rec-cnt     as integer   no-undo.
define input  parameter p-headerh as handle.
define parameter buffer buf_temp-esys-pck-sent for THpck-sent.
define parameter buffer buf_temp-esys-pck-rcvd for THpck-rcvd.
define parameter buffer curr_temp-esys-pck-sent for THcurr-pack.
define variable v-present as logical no-undo .
define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd.
define buffer buf_esys-pck-sent for ub.esys-pck-sent.
define buffer buf_esys-all-attr for ub.esys-all-attr.
do
on error undo, return error return-value
:
  transaction_block_end:
  do
  on error  undo, return error substitute("&1. error transaction_block_end &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on endkey undo, return error substitute("&1. endkey transaction_block_end")
  on stop   undo, return error substitute("&1. stop transaction_block_end")
  :
    find first buf_temp-esys-pck-sent
      where buf_temp-esys-pck-sent.THesys-id = p-esys-id
        and buf_temp-esys-pck-sent.THpack-num = p-pack-num
      no-error.
    if not available buf_temp-esys-pck-sent
    then do:
      undo, return error substitute( "&1. Отсутствует полная информация о пакете &2 для ВС &3"
                                    ,vss-workfile
                                    ,p-pack-num
                                    ,p-esys-id
                                  )  .
    end.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find buf_esys-pck-rcvd exclusive-lock
  where buf_esys-pck-rcvd.esys-id  = p-esys-id
    and buf_esys-pck-rcvd.db-num   = p-db-num
    and buf_esys-pck-rcvd.espr-cr-db-num   = p-cr-db-num
    and buf_esys-pck-rcvd.espr-pack-num = p-pack-num
  no-error.
if not available buf_esys-pck-rcvd then do:
  create buf_esys-pck-rcvd.
  assign
  buf_esys-pck-rcvd.esys-id    = p-esys-id
  buf_esys-pck-rcvd.db-num     = p-db-num
  buf_esys-pck-rcvd.espr-cr-db-num     = p-cr-db-num
  buf_esys-pck-rcvd.espr-pack-num   = p-pack-num
  .
end.
    if new(buf_esys-pck-rcvd) then do:
      buf_esys-pck-rcvd.espr-rcvd       = buf_temp-esys-pck-sent.THrcvd.
    end.
    assign
    buf_esys-pck-rcvd.espr-rcvd-recs  = p-rec-cnt
    buf_esys-pck-rcvd.espr-total-recs = (if valid-handle(p-headerh)
                                         then (if p-headerh:table = "thheader"
                                               then p-headerh::THtotal-recs
                                               else 1)
                                         else 1)
    buf_esys-pck-rcvd.espr-CRC-pack   = buf_temp-esys-pck-sent.THCRC-pack
    buf_esys-pck-rcvd.custom-pack-name = buf_temp-esys-pck-sent.THfilename
    .
    find first buf_esys-all-attr share-lock where
            buf_esys-all-attr.attr-code = 'custom-pack-name':U
        and buf_esys-all-attr.table-name = 'esys-pck-rcvd':U
        and buf_esys-all-attr.key1 = buf_esys-pck-rcvd.espr-pack-num
        and buf_esys-all-attr.key2 = p-esys-id
        and buf_esys-all-attr.key5 = p-db-num
        and buf_esys-all-attr.key6 = p-cr-db-num no-error.
    if available buf_esys-all-attr then do:
        buf_esys-pck-rcvd.custom-pack-name = buf_esys-all-attr.attr-value.
        delete buf_esys-all-attr.
    end.
    for each buf_esys-pck-rcvd exclusive-lock
      where buf_esys-pck-rcvd.esys-id = p-esys-id
        and buf_esys-pck-rcvd.db-num = p-db-num
        and buf_esys-pck-rcvd.espr-cr-db-num = p-cr-db-num
        and buf_esys-pck-rcvd.espr-rcvd   = no
    on error  undo, return error substitute("&1. error buf_esys-pck-rcvd &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    on endkey undo, return error substitute("&1. endkey buf_esys-pck-rcvd")
    on stop   undo, return error substitute("&1. stop buf_esys-pck-rcvd")
    :
      find first buf_temp-esys-pck-sent no-lock
        where buf_temp-esys-pck-sent.thesys-id = p-esys-id
          and buf_temp-esys-pck-sent.THpack-num = buf_esys-pck-rcvd.espr-pack-num
        no-error .
      if not available buf_temp-esys-pck-sent then do:
        assign
          buf_esys-pck-rcvd.espr-rcvd = yes
        .
      end.
    end.
    run get-xcnf_check-imp-rec in this-procedure
      ( input  "delete":U
      ,input  p-esys-id
      ,input  p-db-num
      ,input  p-cr-db-num
      ,input  p-pack-num
      ,input  ?
      ,output v-present
      ) no-error .
    if error-status :error then do:
      undo, return  error  substitute( "&1. Ошибка при удалении уникальных ключей строк пакета. &2", vss-workfile, return-value ).
    end.
    run ext-system-attr-write in this-procedure
      ( input p-esys-id
      ,input p-db-num
      ,input 'need-gen-new-xpack':U
      ,input "yes":U
      ) no-error.
    if error-status :error then do:
      undo, return error   substitute( "&1. Ошибка записи атрибута формирования нового пакета для ВС &2"
                                    ,vss-workfile
                                    ,p-esys-id~
                                  ).
    end.
  end.
end.
end procedure.
procedure get-xcnf_set0xcnf :
define input  parameter p-esys-id as integer no-undo .
define input  parameter p-db-num as integer   no-undo .
define input  parameter p-cr-db-num as integer   no-undo .
define input  parameter p-pack-num as integer   no-undo .
define input  parameter p-delivery-method as integer no-undo .
define input  parameter p-rec-cnt as integer   no-undo .
define input  parameter p-headerh as handle no-undo .
define variable v-present as logical no-undo .
define variable v-rcvd as logical no-undo .
define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd.
define buffer buf_esys-all-attr for ub.esys-all-attr.
define buffer buf_temp-esys-pck-sent for THpck-sent.
  do
  on error undo, return error return-value
  :
    find buf_esys-pck-rcvd exclusive-lock
      where buf_esys-pck-rcvd.esys-id  = p-esys-id
        and buf_esys-pck-rcvd.db-num   = p-db-num
        and buf_esys-pck-rcvd.espr-cr-db-num   = p-cr-db-num
        and buf_esys-pck-rcvd.espr-pack-num = p-pack-num
      no-error.
    if not available buf_esys-pck-rcvd then do:
      create buf_esys-pck-rcvd.
      assign
      buf_esys-pck-rcvd.esys-id    = p-esys-id
      buf_esys-pck-rcvd.db-num     = p-db-num
      buf_esys-pck-rcvd.espr-cr-db-num     = p-cr-db-num
      buf_esys-pck-rcvd.espr-pack-num   = p-pack-num
      .
      find first buf_esys-all-attr share-lock where
              buf_esys-all-attr.attr-code = 'custom-pack-name':U
          and buf_esys-all-attr.table-name = 'esys-pck-rcvd':U
          and buf_esys-all-attr.key1 = buf_esys-pck-rcvd.espr-pack-num
          and buf_esys-all-attr.key2 = p-esys-id
          and buf_esys-all-attr.key5 = p-db-num
          and buf_esys-all-attr.key6 = p-cr-db-num no-error.
      if available buf_esys-all-attr then do:
         buf_esys-pck-rcvd.custom-pack-name = buf_esys-all-attr.attr-value.
         delete buf_esys-all-attr.
      end.
    end.
    define variable v-recs as integer no-undo .
    define variable v-filename as character no-undo .
    if valid-handle(p-headerh) then do:
      case p-headerh:table:
        when  "THheader" then do:
          assign
          v-recs = p-headerh::THtotal-recs
          v-filename = p-headerh::THfilename
          .
        end.
        when "header_" then do:
          define variable v1-flag as logical no-undo .
          assign
          v-recs = 1
          v-filename =  get-short-pack-name( input "get"
                                          , input buf_esys-pck-rcvd.espr-pack-num
                                          , input p-delivery-method
                                          , input buf_esys-pck-rcvd.custom-pack-name
                                          , output v1-flag).
        end.
      end case.
    end.
    else do:
      if p-delivery-method = integer('5':U)
      or p-delivery-method = integer('11':U)
      then do:
        assign
        v-recs = 1
        v-filename = buf_esys-pck-rcvd.custom-pack-name
        .
      end.
    end.
    if p-delivery-method = integer('5':U) then do:
      find first buf_temp-esys-pck-sent no-lock
        where buf_temp-esys-pck-sent.thesys-id = p-esys-id
          and buf_temp-esys-pck-sent.THpack-num = buf_esys-pck-rcvd.espr-pack-num
        no-error .
      if available buf_temp-esys-pck-sent then do:
        v-rcvd = yes.
      end.
    end.
    else do:
      v-rcvd = yes.
    end.
    assign
    buf_esys-pck-rcvd.espr-total-recs = v-recs
    buf_esys-pck-rcvd.espr-rcvd-recs = p-rec-cnt
    buf_esys-pck-rcvd.espr-CRC-pack   = ""
    buf_esys-pck-rcvd.espr-rcvd  = v-rcvd
    buf_esys-pck-rcvd.custom-pack-name = v-filename
    .
    ibs.th.bge.1crn.import.impmsgs:writeError2Db(
       p-esys-id
      ,p-db-num
      ,p-cr-db-num
      ,p-pack-num).
    run str/callnews.p
      (input 'esys-pck-rcvd':U
      ,input (buffer buf_esys-pck-rcvd:handle)
      )  .
    run get-xcnf_check-imp-rec in this-procedure
      ( input  "delete":U
      ,input  p-esys-id
      ,input  p-db-num
      ,input  p-cr-db-num
      ,input  p-pack-num
      ,input  ?
      ,output v-present
      ) no-error .
    if error-status :error then do:
      undo, return  error  substitute( "&1. Ошибка при удалении уникальных ключей строк пакета. &2", vss-workfile, return-value ).
    end.
  end.
end procedure.
procedure get-xcnf_check-imp-rec :
  define input  parameter p-action   as character no-undo .
  define input  parameter p-esys-id  as integer no-undo .
  define input  parameter p-db-num   as integer   no-undo .
  define input  parameter p-cr-db-num as integer no-undo .
  define input  parameter p-pack-num as integer   no-undo .
  define input  parameter p-uniq-key as character no-undo .
  define output parameter p-present  as logical   no-undo .
  do
  on error  undo, return error substitute( "&1 (check-imp-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (check-imp-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (check-imp-rec). endkey", vss-workfile )
  :
    define buffer buf_esys-pck-keys for ub.esys-pck-keys .
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
        find first buf_esys-pck-keys
          where buf_esys-pck-keys.esys-id  = p-esys-id
            and buf_esys-pck-keys.db-num   = p-db-num
            and buf_esys-pck-keys.espr-cr-db-num = p-cr-db-num
            and buf_esys-pck-keys.espr-pack-num = p-pack-num
            and buf_esys-pck-keys.espr-uniq-key = p-uniq-key
          no-error .
        if available buf_esys-pck-keys then do:
          assign
            p-present = true
          .
        end.
        else do:
          do transaction
          on error undo, return error
          :
            create buf_esys-pck-keys .
            assign
            buf_esys-pck-keys.esys-id  = p-esys-id
            buf_esys-pck-keys.db-num   = p-db-num
            buf_esys-pck-keys.espr-cr-db-num = p-cr-db-num
            buf_esys-pck-keys.espr-pack-num = p-pack-num
            buf_esys-pck-keys.espr-uniq-key = p-uniq-key
            p-present = false
            .
          end.
        end.
      end.
      when "delete":U then do:
        for each buf_esys-pck-keys exclusive-lock
          where buf_esys-pck-keys.esys-id  = p-esys-id
            and buf_esys-pck-keys.db-num   = p-db-num
            and buf_esys-pck-keys.espr-cr-db-num = p-cr-db-num
            and buf_esys-pck-keys.espr-pack-num = p-pack-num
        on error  undo, return error substitute( "&1 (check-imp-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        on stop   undo, return error substitute( "&1 (check-imp-rec). stop", vss-workfile )
        on endkey undo, return error substitute( "&1 (check-imp-rec). endkey", vss-workfile )
        :
          delete buf_esys-pck-keys.
        end.
      end.
    end case.
  end.
  return.
end procedure.
procedure get-xcnf_create-temp-esys-pck-rcvd :
define input parameter p-esys-id as integer no-undo .
define input parameter p-pack-num as integer no-undo .
define input parameter p-crc-pack as character no-undo .
define input parameter p-rcvd as logical no-undo .
define input parameter p-rcvd-recs as integer no-undo .
define input parameter p-total-recs as integer no-undo .
define input parameter p-rcvd-date as date no-undo .
define input parameter p-rcvd-time-int as integer no-undo .
define input parameter p-rcvd-time as character no-undo .
define buffer buf_temp-esys-pck-rcvd for THpck-rcvd.
do
on error undo, return error
:
  find first buf_temp-esys-pck-rcvd where
            buf_temp-esys-pck-rcvd.THesys-id = p-esys-id
        and buf_temp-esys-pck-rcvd.thpack-num = p-pack-num no-error.
  if not available buf_temp-esys-pck-rcvd then do:
    create buf_temp-esys-pck-rcvd.
    assign
    buf_temp-esys-pck-rcvd.thesys-id = p-esys-id
    buf_temp-esys-pck-rcvd.thpack-num = p-pack-num
    .
  end.
  assign
  buf_temp-esys-pck-rcvd.THcrc-pack  = p-crc-pack
  buf_temp-esys-pck-rcvd.THrcvd-recs   = p-rcvd-recs
  buf_temp-esys-pck-rcvd.THrcvd  = p-rcvd
  buf_temp-esys-pck-rcvd.THtotal-recs   = p-total-recs
  buf_temp-esys-pck-rcvd.THrcvddate  = p-rcvd-date
  buf_temp-esys-pck-rcvd.THrcvdtimeint = p-rcvd-time-int
  buf_temp-esys-pck-rcvd.THrcvdtime  = p-rcvd-time
  .
end.
end procedure.
procedure get-xcnf_create-temp-esys-pck-sent :
define input parameter p-esys-id as integer no-undo .
define input parameter p-pack-num as integer no-undo .
define input parameter p-crc-pack as character no-undo .
define input parameter p-rcvd as logical no-undo .
define input parameter p-rcvd-recs as integer no-undo .
define input parameter p-total-recs as integer no-undo .
define input parameter p-rcvd-date as date no-undo .
define input parameter p-rcvd-time-int as integer no-undo .
define input parameter p-rcvd-time as character no-undo .
define buffer buf_temp-esys-pck-sent for THpck-sent.
do
on error undo, return error
:
  find first buf_temp-esys-pck-sent where
            buf_temp-esys-pck-sent.THesys-id = p-esys-id
        and buf_temp-esys-pck-sent.thpack-num = p-pack-num no-error.
  if not available buf_temp-esys-pck-sent then do:
    create buf_temp-esys-pck-sent.
    assign
    buf_temp-esys-pck-sent.thesys-id = p-esys-id
    buf_temp-esys-pck-sent.thpack-num = p-pack-num
    .
  end.
  assign
  buf_temp-esys-pck-sent.THcrc-pack  = p-crc-pack
  buf_temp-esys-pck-sent.THtotal-recs   = p-total-recs
  buf_temp-esys-pck-sent.THrcvd  = p-rcvd
  buf_temp-esys-pck-sent.THtotal-recs   = p-total-recs
  buf_temp-esys-pck-sent.THrcvddate  = p-rcvd-date
  buf_temp-esys-pck-sent.THrcvdtimeint = p-rcvd-time-int
  buf_temp-esys-pck-sent.THrcvdtime  = p-rcvd-time
  buf_temp-esys-pck-sent.THtotal-recs = p-total-recs
  .
end.
end procedure.
procedure get-xcnf_find-pack-by-rd-uniq-key-rec :
define input parameter p-esys-id as integer no-undo .
define input parameter p-db-num as integer no-undo .
define input parameter p-uniq-key-rec as character no-undo .
define buffer buf_esys-route-dump for ub.esys-route-dump.
define buffer buf_esys-route for ub.esys-route.
do
on error undo, return error
:
  for each buf_esys-route-dump no-lock where
          buf_esys-route-dump.esrd-uniq-key-rec = p-uniq-key-rec,
      first buf_esys-route no-lock where
          buf_esys-route.esr-dump-ord   = buf_esys-route-dump.esrd-dump-ord
      and buf_esys-route.esys-id   = p-esys-id
      and buf_esys-route.db-num   = p-db-num:
    if buf_esys-route.esr-last-pack <> ?
    and buf_esys-route.esr-last-pack >= 0 then do:
      p-pack-num = buf_esys-route.esr-last-pack.
      return.
    end.
  end.
end.
end procedure.
procedure get-xcnf_find-pack-by-rd :
define input parameter p-esys-id as integer no-undo .
define input parameter p-db-num as integer no-undo .
define input parameter p-dump-ord as int64 no-undo .
define buffer buf_esys-route-dump for ub.esys-route-dump.
define buffer buf_esys-route for ub.esys-route.
do
on error undo, return error
:
  for each buf_esys-route-dump no-lock where
          buf_esys-route-dump.esrd-dump-ord = p-dump-ord,
      first buf_esys-route no-lock where
          buf_esys-route.esr-dump-ord   = buf_esys-route-dump.esrd-dump-ord
      and buf_esys-route.esys-id   = p-esys-id
      and buf_esys-route.db-num   = p-db-num:
    if buf_esys-route.esr-last-pack <> ?
    and buf_esys-route.esr-last-pack >= 0 then do:
      p-pack-num = buf_esys-route.esr-last-pack.
      return.
    end.
  end.
end.
end procedure.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable himp2Cd as handle no-undo.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def  new shared  temp-table dcp-list no-undo like ub.dis-card-property
                        field rc as recid
                        field to-del as  logical
                        field order-num as integer
                        index rci is unique rc to-del
                        index d-card-i is primary d-card host-code obj-type obj-code dt-code node-code to-del
                        index iobj obj-type obj-code
                        index io order-num
                        .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def  new shared  temp-table stpl-list no-undo like ub.stop-list
                        field rc as recid
                        field to-del as  logical
                        field order-num as integer
                        index rci is unique rc to-del
                        index pi is primary classif-type stop-list-code to-del
                        index iobj obj-type obj-code
                        index io order-num
                        .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def new shared temp-table pbc-list no-undo like ub.prod-bc
                        field rc as recid
                        field del as  logical
                        index rci is unique rc del
                        index gds-code-i b-code del
                        index ibc-on-type bc-on-type
                        .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def new shared temp-table bc-list no-undo like ub.bar-code
                        field del as  logical
                        index bc is unique b-code del
                        index gds-code-i gds-code del.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE new shared TEMP-TABLE cash-txn no-undo
FIELD tax-code like ub.tax.tax-code
FIELD tax-name like ub.tax.tax-name
FIELD news-action as logical
index pi IS UNIQUE PRIMARY tax-code.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table pdf-list no-undo like ub.price-doc-forming
field to-del     as logical
field order-num  as integer
index pi  is primary unique plt-id plt-db-num pdf-id pdf-db
index oi order-num
.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE new shared TEMP-TABLE cash-pay-list no-undo
FIELD cdpay-code as integer
FIELD curr-code as integer
index pi IS PRIMARY unique cdpay-code curr-code
.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE new shared TEMP-TABLE PromoAction-list no-undo
FIELD ID as int64
FIELD db-num as integer
FIELD del_ as logical
index pi IS PRIMARY unique ID db-num
.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE new shared TEMP-TABLE thbjattr-list no-undo like ub.thbj-attr .
define new shared var sendEMRC   as logical no-undo.
define new shared var settingUpd as logical no-undo.
define new shared var sendMarkType as logical no-undo.
define new shared var sendGisMt as logical no-undo.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                         input parparentproc
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
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v_dataseth as handle no-undo .
define variable glog as logical no-undo .
define variable v-ok as logical no-undo .
define variable v-xmlh as handle no-undo .
define variable v-headerh as handle no-undo .
define variable v-header-th as handle no-undo .
define variable v-pckrcvd as handle no-undo .
define variable v-pcksent as handle no-undo .
define variable v-currpcksent as handle no-undo .
define variable v-schema-name as character no-undo .
define variable v-esys-id as integer no-undo .
define variable v-schema-tmp-file as character no-undo .
define variable v-gate-rec as character no-undo .
define variable v-part-num as integer no-undo init 1.
define variable v-clob-db-num as integer no-undo .
define variable v-int64-id as int64 no-undo .
define variable v-prev-crc as character no-undo .
define variable v-import-prev-crc as character no-undo .
define variable v-pck-num                 as integer                  no-undo .
define variable v-header-obj-type as character no-undo .
define variable v-header-obj-code as integer no-undo .
define variable v-rec-cnt     as integer   no-undo.
define variable v-task as integer no-undo .
define variable v-task-ok as integer no-undo .
define variable v-header-schema-name as character no-undo .
define variable v-header-name as character no-undo .
define variable v-header-rec as character no-undo .
define variable v-process as character no-undo .
define variable v-insert-header as logical   no-undo .
define variable v-my-message as character no-undo .
define buffer buf_temp-xml-tables for temp-xml-tables.
define buffer buf_temp-esys-pck-rcvd for THpck-rcvd.
define buffer buf_temp-esys-pck-sent for THpck-sent.
define buffer curr_temp-esys-pck-sent for THcurr-pack.
define buffer buf_clob-data for ub.clob-data.
define buffer buf_ext-system for ub.ext-system.
define buffer buf_temp-param-name for temp-param-name.
define buffer buf_rule-profile for ub.rule-profile.
define buffer buf_esys-pck-keys for ub.esys-pck-keys.
define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd.
define buffer buf_esys-pck-sent for ub.esys-pck-sent.
define buffer buf_temp_xmllib_rec for temp_xmllib_rec.
define buffer buf_temp_xmllib_rec-fld for temp_xmllib_rec-fld.
define frame imp-pck
p-esys-id        label "ВС" skip
v-pck-num       label "Пакет" format ">>>>>>>>>9" skip
p-xml-file-name label "Файл пакета" format "x(50)" skip
v-rec-cnt       label "Основных записей" format ">>>>>>>>>9" skip
with view-as dialog-box side-labels 1 columns three-d title "** Разбор пакета"
.
main-block:
do
on error undo, return error return-value
:
  find first buf_ext-system no-lock where
            buf_ext-system.esys-id = p-esys-id
       and buf_ext-system.db-num = p-db-num
            no-error.
  if not available buf_ext-system then do:
  end.
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
  case buf_ext-system.delivery-method:
    when integer('3':U) then do:
      assign
      v-header-schema-name = "exe/header_.xsd"
      v-header-name = "header_".
    end.
    when integer('5':U) then do:
      assign
      v-header-schema-name = ""
      v-header-name = "".
    end.
    when integer('9':U) then do:
      assign
      v-header-schema-name = ""
      v-header-name = "".
    end.
    when integer('11':U) then do:
      assign
      v-header-schema-name = ""
      v-header-name = "".
    end.
    otherwise do:
      assign
      v-header-schema-name = "exe/THheader.xsd"
      v-header-name = "THheader".
    end.
  end case.
  if v-header-name <> '' then do:
  run get-gate-rec in this-procedure ( input v-header-schema-name
                                      ,output v-header-rec) no-error.
  if error-status:error then do:
    undo, return error substitute("Не найдено описание xsd-схемы &1 в БД", v-header-schema-name).
  end.
  run get-header-by-rec in this-procedure ( input v-header-rec
                                            ,output v-header-th
                                            ) no-error.
  if error-status:error then do:
    v-my-message = substitute("Ошибка при создании структуры заголовка пакета согласно гейту:&1&2&3&2&4"
                               , v-header-rec
                               , chr(10)
                               , error-status:get-message(1)
                               , return-value  ) .
    delete object v-header-th no-error.
    undo, return error v-my-message.
  end.
  v-headerh = v-header-th:default-buffer-handle.
  end.
  run  xmllib-set-log-handle in this-procedure (
                                                 input p-log-handle
                                                ,input "write-to-log"
                                                 ).
  run getoxmlh in this-procedure ( input p-xml-file-name
                                  ,input p-pack-data
                                  ,input v-headerh
                                  ,input buf_ext-system.delivery-method
                                  ) no-error.
define buffer buf_rec for temp_xmllib_rec.
define buffer buf_rec-fld for temp_xmllib_rec-fld.
  find first buf_esys-pck-rcvd no-lock
    where buf_esys-pck-rcvd.esys-id = p-esys-id
      and buf_esys-pck-rcvd.db-num   = p-db-num
      and buf_esys-pck-rcvd.espr-cr-db-num   = p-cr-db-num
      and buf_esys-pck-rcvd.espr-pack-num = p-pack-num - 1
    no-error
  .
  if available buf_esys-pck-rcvd then do:
    assign
      v-prev-crc = buf_esys-pck-rcvd.espr-crc-pack
    .
  end.
  else do:
    assign
      v-prev-crc = "":U
    .
  end.
  case buf_ext-system.delivery-method:
    when integer('5':U) then do:
      find first buf_temp_xmllib_rec no-error.
      if not available buf_temp_xmllib_rec
      or lookup(buf_temp_xmllib_rec.recname, "ORDRSP_,DESADV_,STATUS__") = 0
      then do:
        v-my-message = substitute("Неверный тип пакета &1"
                                    , p-pack-num
      , (if available buf_temp_xmllib_rec then buf_temp_xmllib_rec.recname else '')
                                  ) .
        delete object v-header-th no-error.
        return error v-my-message.
      end.
      v-schema-name = substitute("exe/&1.xsd",buf_temp_xmllib_rec.recname).
    end.
    when integer('9':U) then do:
      v-schema-name = entry (1, p-file-name, "_").
      if not can-find(first ub.clients
                      where ub.clients.obj-type = v-header-obj-type
                        and ub.clients.obj-code = v-header-obj-code
                        and ub.clients.db-num   = ibs.th.gbl.gbl-var:g#db-num)
      then do:
        v-my-message = substitute("Адресат пакета &1 (&2&3) НЕИЗВЕСТЕН", p-pack-num, v-header-obj-type, v-header-obj-code) .
        delete object v-header-th no-error.
        return error v-my-message .
      end.
      v-pck-num = p-pack-num.
    end.
    when integer('11':U) then do:
      v-pck-num = integer(entry(3, p-file-name, "_"))  no-error.
      find first buf_temp_xmllib_rec where
              buf_temp_xmllib_rec.recLevel = 0 no-error.
      if available (buf_temp_xmllib_rec)
        then v-schema-name =   buf_temp_xmllib_rec.recName.
    end.
    when integer('3':U) then do:
      v-esys-id = buf_ext-system.esys-id.
      find first buf_temp_xmllib_rec
           where buf_temp_xmllib_rec.recname = "Oracle_Retail" no-error.
      if not available buf_temp_xmllib_rec then do:
        v-my-message = substitute("Неверный тип пакета &1", p-pack-num, v-header-obj-code) .
        delete object v-header-th no-error.
        return error v-my-message.
      end.
      for first buf_temp_xmllib_rec
          where buf_temp_xmllib_rec.recname = "header_",
           each buf_temp_xmllib_rec-fld
          where buf_temp_xmllib_rec-fld.rec-key = buf_temp_xmllib_rec.rec-key:
        case buf_temp_xmllib_rec-fld.fldname:
          when "obj-type" then do:
            v-header-obj-type = buf_temp_xmllib_rec-fld.fldvalue.
          end.
          when "obj-code" then do:
            assign
            v-header-obj-code = 0
            v-header-obj-code = integer(buf_temp_xmllib_rec-fld.fldvalue) no-error.
          end.
          when "xsd" then do:
            v-schema-name = "exe/" + buf_temp_xmllib_rec-fld.fldvalue.
          end.
          when "date-from" then do:
            run set-exch-date-time in p-parent-handle ( input buf_temp_xmllib_rec-fld.fldvalue) no-error .
          end.
        end case.
      end.
      if not can-find (first ub.clients
                       where ub.clients.obj-type = v-header-obj-type
                         and ub.clients.obj-code = v-header-obj-code
                         and ub.clients.db-num   = ibs.th.gbl.gbl-var:g#db-num)
      then do:
        v-my-message = substitute("Адресат пакета &1 (&2&3) НЕИЗВЕСТЕН", p-pack-num, v-header-obj-type, v-header-obj-code) .
        delete object v-header-th no-error.
        return error v-my-message.
      end.
      v-pck-num = p-pack-num.
    end.
    otherwise do:
  for first buf_temp_xmllib_rec where
          buf_temp_xmllib_rec.recname = "THheader",
        each buf_temp_xmllib_rec-fld where
         buf_temp_xmllib_rec-fld.rec-key = buf_temp_xmllib_rec.rec-key:
    case buf_temp_xmllib_rec-fld.fldname:
       when "THfilename" then do:
       end.
       when "THschema-name" then do:
         v-schema-name = buf_temp_xmllib_rec-fld.fldvalue.
       end.
       when "THimport-esys-id" then do:
         v-esys-id = integer(buf_temp_xmllib_rec-fld.fldvalue) no-error .
       end.
       when "THpack-num" then do:
          v-pck-num = integer(buf_temp_xmllib_rec-fld.fldvalue) no-error.
       end.
       when "THprev-crc" then do:
          v-import-prev-crc = buf_temp_xmllib_rec-fld.fldvalue no-error.
       end.
    end case.
  end.
    end.
  end case.
  if buf_ext-system.delivery-method = integer('5':U)
     or buf_ext-system.delivery-method = integer('9':U)
  then do:
    v-pck-num = p-pack-num.
  end.
  if v-pck-num <> p-pack-num
  and not (buf_ext-system.delivery-method = integer('1':U))
  then do:
    v-my-message = substitute("Номер пакета &1 в заголовке файла &2&5 не совпадает с номером пакета &3 для вн.системы '&4'"
                                 , v-pck-num
                                 , p-xml-file-name
                                 , p-pack-num
                                 ,buf_ext-system.esys-name
                                 , chr(10)) .
    delete object v-header-th no-error.
    return error v-my-message.
  end.
  if buf_ext-system.imp-conf-send > 0  then do:
    if v-import-prev-crc <> v-prev-crc then do:
      v-my-message = substitute("&1. Ошибка приема! Пакет &2 сформирован в некорректной ВС&3" +
                                  "Ключ предыдущего пакета в файле (&4)&3не совпадает с ключом предыдущего пакета в БД (&5)"
                                  , vss-workfile
                                  , v-pck-num
                                  , chr(10)
                                  ,v-import-prev-crc
                                  , v-prev-crc
                                  ) .
      delete object v-header-th no-error.
      undo, return error v-my-message.
    end.
  end.
  if buf_ext-system.delivery-method <> integer('5':U)
    and buf_ext-system.delivery-method <> integer('9':U)
    and buf_ext-system.delivery-method <> integer('11':U)
  then do:
    assign
    v-pck-num = 0.
  end.
  find first buf_temp-param-name where
            buf_temp-param-name.schema-name = v-schema-name
       and  (buf_temp-param-name.esys-id = p-esys-id
            or
            buf_temp-param-name.esys-id = -1)
       no-error.
  if not available buf_temp-param-name then do:
    v-my-message = substitute("Не настроена обработка данных по схеме &1 для вн.системы &2"
                                 , v-schema-name
                                 ,buf_ext-system.esys-name ) .
    delete object v-header-th no-error.
    return error v-my-message.
  end.
    if buf_ext-system.delivery-method <> integer('9':U)
     and buf_ext-system.delivery-method <> integer('11':U) then do:
      run get-gate-rec in this-procedure ( v-schema-name
                                          ,output v-gate-rec) no-error.
      if error-status:error then do:
        undo, return error substitute("Не найдено описание xsd-схемы &1 в БД", v-schema-name).
      end.
      define variable v-longchar as longchar no-undo .
      v-longchar = ''.
      run get-gate-by-rec in this-procedure ( input v-gate-rec
                                            ,output v_dataseth
                                            ,input-output v-xmlh
                                            ,input-output v-longchar
                                            ) no-error.
      if error-status:error then do:
        v-my-message = substitute("Ошибка при создании структуры маршрутизируемых данных согласно гейту:&1&2&3&2&4"
                                  , v-gate-rec
                                  , chr(10)
                                  , error-status:get-message(1)
                                  , return-value ) .
        delete object v-header-th no-error.
        undo, return error v-my-message.
      end.
    end.
    if v-header-name <> '' then do:
  v-headerh = v-header-th:default-buffer-handle.
  find first buf_temp-xml-tables where
            buf_temp-xml-tables.tbl-name = v-headerh:table no-error.
  if not available buf_temp-xml-tables then do:
    v-insert-header = yes.
  create buf_temp-xml-tables.
  assign
  buf_temp-xml-tables.tbl-name = v-headerh:table
  buf_temp-xml-tables.tbl-handle_ = v-headerh
  buf_temp-xml-tables.table-handle_ = v-headerh:table-handle
  buf_temp-xml-tables.order = -3
  buf_temp-xml-tables.gate-handle = v_dataseth
  buf_temp-xml-tables.gate-name = v-schema-name
  buf_temp-xml-tables.uniq-gate-rec = v-gate-rec
  .
 end.
  else do:
    delete object v-header-th.
    v-headerh = buf_temp-xml-tables.table-handle_:default-buffer-handle.
  end.
  end.
  if buf_ext-system.imp-conf-send > 0  then do:
    create buf_temp-xml-tables.
    assign
    buf_temp-xml-tables.tbl-name = v-pckrcvd:table
    buf_temp-xml-tables.tbl-handle_ = v-pckrcvd
    buf_temp-xml-tables.table-handle_ = v-pckrcvd:table-handle
    buf_temp-xml-tables.uniq-gate-rec = v-gate-rec
    buf_temp-xml-tables.gate-name = v_dataseth:name
    buf_temp-xml-tables.gate-handle_ = v_dataseth
    buf_temp-xml-tables.order = -2
    .
    create buf_temp-xml-tables.
    assign
    buf_temp-xml-tables.tbl-name = v-pcksent:table
    buf_temp-xml-tables.tbl-handle_ = v-pcksent
    buf_temp-xml-tables.table-handle_ = v-pcksent:table-handle
    buf_temp-xml-tables.uniq-gate-rec = v-gate-rec
    buf_temp-xml-tables.gate-name = v_dataseth:name
    buf_temp-xml-tables.gate-handle_ = v_dataseth
    buf_temp-xml-tables.order = -1
    .
    create buf_temp-xml-tables.
    assign
    buf_temp-xml-tables.tbl-name = v-currpcksent:table
    buf_temp-xml-tables.tbl-handle_ = v-currpcksent
    buf_temp-xml-tables.table-handle_ = v-currpcksent:table-handle
    buf_temp-xml-tables.uniq-gate-rec = v-gate-rec
    buf_temp-xml-tables.gate-name = v_dataseth:name
    buf_temp-xml-tables.gate-handle_ = v_dataseth
    buf_temp-xml-tables.order = v_dataseth:num-buffers + 1
    .
  end.
  if v-insert-header = yes then do:
  run tmpreldf_get-relations in this-procedure ( input v_dataseth).
  for each buf_temp-xml-tables
  break
  by buf_temp-xml-tables.order
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
   if first(buf_temp-xml-tables.order) then do:
     glog = v_dataseth:set-buffers ( buf_temp-xml-tables.tbl-handle_) no-error.
   end.
   else do:
     glog = v_dataseth:add-buffer ( buf_temp-xml-tables.tbl-handle_) no-error.
   end.
   if error-status:error
   or not glog
   then do:
      v-my-message = substitute("Ошибка при создании заголовка XML файла:&1&2", chr(10), error-status:get-message(1) ) .
      run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
      undo, return error v-my-message.
    end.
  end.
  run tmpreldf_set-relations in this-procedure ( input v_dataseth, input v_dataseth).
    run gbl/_tmpfile.p (
                      input ""
                    , input "xml"
                    , output v-schema-tmp-file) .
  assign
  glog = v_dataseth:WRITE-XMLSCHEMA( "FILE"
                                   , v-schema-tmp-file
                                   , yes
                                   , ?
                                    , no
                                   ) no-error .
  if error-status :error then do:
        v-my-message = substitute("Ошибка при создании временного файла xsd со схемой &1:&2&3"
                                    , v_dataseth:name
                                    , chr(10)
                                    , error-status:get-message(1) ) .
    run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
    undo, return error v-my-message.
  end.
  end.
  else do:
    if buf_ext-system.delivery-method <> integer('9':U)
     and buf_ext-system.delivery-method <> integer('11':U)then do:
        run gbl/_tmpfile.p (
                            input ""
                          , input "xml"
                          , output v-schema-tmp-file) .
        COPY-LOB
        FROM  OBJECT v-longchar
        TO  FILE v-schema-tmp-file
        no-convert
        NO-ERROR .
        v-longchar = ''.
        if error-status :error then do:
            v-my-message = substitute("Ошибка при создании временного файла xsd со схемой &1:&2&3"
                                        , v_dataseth:name
                                        , chr(10)
                                        , error-status:get-message(1) ) .
          run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
          undo, return error v-my-message.
        end.
      end.
    end.
    if buf_ext-system.delivery-method <> integer('9':U)
     and buf_ext-system.delivery-method <> integer('11':U) then do:
      assign
      v-rec-cnt = 0
      .
      ASSIGN
      glog = v_dataseth:read-xml( "file"
                                ,p-xml-file-name
                                ,"merge"
                                ,v-schema-tmp-file
                                ,?
                                ,?
                                ,"strict"
                                ) no-error .
      if error-status:error
      then do:
        v-my-message = substitute("Ошибка при чтении XML файла &1 данными через гейт &2:&3&4"
                                        , p-xml-file-name
                                        , v_dataseth:name
                                        , chr(10)
                                        , error-status:get-message(1)) .
        run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
        if buf_ext-system.delivery-method = integer('3':U) then do:
          run set-err-type in p-parent-handle ( input 'STRUCTURE') no-error.
        end.
        undo, return error v-my-message.
      end.
       if not glog then do:
          v-my-message = substitute("Не прошел верификацию с помощью схемы &1 XML файл &2:&3&4&3&5"
                                        , v_dataseth:name
                                        , p-xml-file-name
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , error-status:get-message(2) ) .
        run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
        os-delete value(v-schema-tmp-file).
        if buf_ext-system.delivery-method = integer('3':U) then do:
          run set-err-type in p-parent-handle ( input 'STRUCTURE') no-error.
        end.
        undo, return error v-my-message.
      end.
    end.
  if buf_ext-system.delivery-method <>  integer('5':U)
    and buf_ext-system.delivery-method <>  integer('9':U)
    and buf_ext-system.delivery-method <>  integer('11':U)
  then do:
  case buf_ext-system.delivery-method:
    when integer('3':U) then do:
      find first buf_temp-xml-tables where
                buf_temp-xml-tables.tbl-name = v-header-name
            and buf_temp-xml-tables.gate-handle_ = v_dataseth
                no-error.
    end.
    otherwise do:
  find first buf_temp-xml-tables where
                buf_temp-xml-tables.tbl-name = v-header-name
        and buf_temp-xml-tables.gate-handle_ = v_dataseth
            no-error.
    end.
  end case.
  if not available buf_temp-xml-tables then do:
     v-my-message = substitute("Не найден THHEADER или Header_ в XML файлe &1:&2&3"
                                    , p-xml-file-name
                                    , chr(10)
                                    , error-status:get-message(1)) .
    run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
    os-delete value(v-schema-tmp-file).
    undo, return error v-my-message.
  end.
  glog = buf_temp-xml-tables.tbl-handle_:find-first( "where true") no-error.
  if error-status:error
  or not glog
  or buf_temp-xml-tables.tbl-handle_:available = no then do:
     v-my-message = substitute("Не найдена запись THHEADER или Header_ в XML файлe &1:&2&3"
                                    , p-xml-file-name
                                    , chr(10)
                                    , error-status:get-message(1)) .
    run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
    os-delete value(v-schema-tmp-file).
    undo, return error v-my-message.
  end.
  else do:
    case buf_ext-system.delivery-method:
      when integer('1':U) then do:
      v-pck-num = p-pack-num.
      buf_temp-xml-tables.tbl-handle_:buffer-field("THpack-num"):buffer-value = p-pack-num.
        buf_temp-xml-tables.tbl-handle_:buffer-field("THimport-esys-id"):buffer-value = p-esys-id.
      END.
      when integer('3':U) then do:
        v-pck-num = p-pack-num.
      end.
      otherwise do:
        v-pck-num = buf_temp-xml-tables.tbl-handle_:buffer-field("THpack-num"):buffer-value.
        buf_temp-xml-tables.tbl-handle_:buffer-field("THimport-esys-id"):buffer-value = p-esys-id.
      end.
    end.
  end.
  end.
  if buf_ext-system.imp-conf-send > 0
  or buf_ext-system.delivery-method = integer('5':U)
  then do:
    run get-xcnf_get-xcnf in this-procedure (
                                      input p-esys-id
                                     ,input p-db-num
                                     ,input g#db-num
                                     ,input p-pack-num
                                     ,input buf_ext-system.delivery-method
                                     ,buffer buf_temp-esys-pck-sent
                                     ,buffer buf_temp-esys-pck-rcvd
                                     ,buffer curr_temp-esys-pck-sent
                                     ,output v-rec-cnt
                                   ) no-error.
    if error-status :error then do:
     v-my-message = substitute("Ошибка при принятии подтверждений из ВС:&1&2&1&3"
                                 , chr(10)
                                 , error-status:get-message(1)
                                 , return-value ) .
     run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
     os-delete value(v-schema-tmp-file).
     undo, return error v-my-message.
    end.
  end.
  assign
  v-rec-cnt = v-rec-cnt + 1
  .
  if buf_ext-system.delivery-method <> integer('9':U)
   and buf_ext-system.delivery-method <> integer('11':U) then do:
    os-delete value(v-schema-tmp-file).
  end.
    _rule-profile:
  for each buf_temp-param-name WHERE
         (buf_temp-param-name.esys-id = p-esys-id
         or
         buf_temp-param-name.esys-id = -1)
      and buf_temp-param-name.schema-name = v-schema-name
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    v-task = v-task + 1.
    find first buf_esys-pck-keys no-lock where
            buf_esys-pck-keys.esys-id = p-esys-id
        and buf_esys-pck-keys.db-num = p-db-num
        and buf_esys-pck-keys.espr-cr-db-num = g#db-num
        and buf_esys-pck-keys.espr-pack-num = v-pck-num
        and buf_esys-pck-keys.espr-prev-uniq-key = ''
        and buf_esys-pck-keys.espr-uniq-key = substitute("&2&1&3&1&4&1&5"
                                                            , chr(4)
                                                            , buf_temp-param-name.call_id
                                                            , buf_temp-param-name.codex_id
                                                            , buf_temp-param-name.ruleset_id
                                                            , buf_temp-param-name.order_id)
        no-error.
    if available buf_esys-pck-keys then do:
      v-task-ok = v-task-ok + 1.
      next _rule-profile.
    end.
      case buf_temp-param-name.profile-type:
      when 'dis-card-type':U then do:
        define variable v-field-list as character no-undo .
        define variable v-value-list as character no-undo .
        run gen-key-fv in this-procedure ( input buf_temp-param-name.call_id
                                          ,output v-field-list
                                          ,output v-value-list).
        run str/saledc.p
          (
           input parparentproc
          ,input this-procedure :handle
          ,input p-log-handle
          ,input 'sale-xml-import':U
          ,input integer(entry(lookup("emitent-host-code", v-field-list, chr(3)), v-value-list, chr(3)))
          ,input  entry(lookup("type", v-field-list, chr(3)), v-value-list, chr(3))
          ,input buf_temp-param-name.profile_id
            ,input 0
          ,input buf_temp-param-name.ruleset_id
          ,input g#db-num
          ,input (
                 string(p-esys-id) + chr(4) +
                 p-xml-file-name + chr(4) +
                 string(v_dataseth) + chr(4) +
                 string(v-pck-num) + chr(4) +
                 p-log-file-name + chr(4) +
                 buf_temp-param-name.param-name + chr(4) +
                 buf_temp-param-name.schema-name + chr(4)
                  )
          ,input ?
          ,input ?
          ,input ?
          ,input 1
          ,input 1
          ,input yes
          ) no-error .
        if error-status:error then do:
          v-my-message = substitute("Ошибка при импорте данных по схеме &2:&3 профайл правил &1&3&4&3&5"
                                      ,buf_temp-param-name.profile_id
                                      ,v-schema-name
                                      ,chr(10)
                                      , error-status:get-message(1)
                                      , return-value
                                      ) .
          run write-log in p-log-handle ( input 2, input v-my-message ).
          if buf_temp-param-name.ruleset_id = 2 then do:
          end.
          undo _rule-profile, next _rule-profile.
        end.
      end.
     when 'cli-grp':U then do:
        run str/cgrprum.p
          (
           input parparentproc
          ,input this-procedure :handle
          ,input p-log-handle
          ,input 'xml-esys-import':U
          ,input buf_temp-param-name.profile_id
          ,input buf_temp-param-name.codex_id
          ,input buf_temp-param-name.ruleset_id
          ,input g#db-num
          ,input buf_temp-param-name.call_id
          ,input (
                 string(p-esys-id) + chr(4) +
                 p-xml-file-name + chr(4) +
                 string(v_dataseth) + chr(4) +
                 string(v-pck-num) + chr(4) +
                 p-log-file-name + chr(4) +
                 buf_temp-param-name.param-name + chr(4) +
                 buf_temp-param-name.schema-name + chr(4)
                  )
          ,input yes
          ) no-error .
        if error-status:error then do:
          v-my-message = substitute("Ошибка при импорте данных по схеме &2:&3 профайл правил &1&3&4&3&5"
                                      ,buf_temp-param-name.profile_id
                                      ,v-schema-name
                                      ,chr(10)
                                      , error-status:get-message(1)
                                      , return-value
                                      ) .
          run write-log in p-log-handle ( input 2, input v-my-message ).
          if buf_temp-param-name.ruleset_id = 5 then do:
          end.
          next _rule-profile.
        end.
      end.
      when 'clients':U then do:
        run str/clisrum.p
          (
           input parparentproc
          ,input this-procedure :handle
          ,input p-log-handle
          ,input 'xml-esys-import':U
          ,input buf_temp-param-name.profile_id
            ,input buf_temp-param-name.codex_id
          ,input buf_temp-param-name.ruleset_id
          ,input g#db-num
          ,input buf_temp-param-name.call_id
          ,input (
                 string(p-esys-id) + chr(4) +
                 p-xml-file-name + chr(4) +
                 string(v_dataseth) + chr(4) +
                 string(v-pck-num) + chr(4) +
                 p-log-file-name + chr(4) +
                 buf_temp-param-name.param-name + chr(4) +
                 buf_temp-param-name.schema-name + chr(4)
                  )
          ,input yes
          ) no-error .
        if error-status:error then do:
          v-my-message = substitute("Ошибка при импорте данных по схеме &2:&3 профайл правил &1&3&4&3&5"
                                      ,buf_temp-param-name.profile_id
                                      ,v-schema-name
                                      ,chr(10)
                                      , error-status:get-message(1)
                                      , return-value
                                      ) .
          run write-log in p-log-handle ( input 2, input v-my-message ).
          if buf_temp-param-name.ruleset_id = 5 then do:
          end.
          next _rule-profile.
        end.
      end.
      when 'edoc':U then do:
        case buf_temp-param-name.ruleset_id:
            when 4 then do:
            assign
            v-process = 'xml-esys-import_order':U
            .
          end.
           when 8 then do:
              assign
              v-process = 'xml-esys-import_rcv':U
              .
            end.
            when 12 then do:
            assign
            v-process = 'xml-esys-import_price-doc':U
            .
          end.
            when 16 then do:
            assign
            v-process = 'xml-esys-import_trn-doc':U
            .
          end.
            when 20 then do:
            assign
            v-process = 'xml-esys-import_inv-doc':U
            .
          end.
            when 24  then do:
            assign
            v-process = 'xml-esys-import_contract':U
            .
          end.
        end case.
        run str/edocrum.p
          (
           input parparentproc
          ,input this-procedure :handle
          ,input p-log-handle
          ,input v-process
          ,input buf_temp-param-name.profile_id
          ,input buf_temp-param-name.codex_id
          ,input buf_temp-param-name.ruleset_id
          ,input g#db-num
          ,input buf_temp-param-name.call_id
          ,input (
                 string(p-esys-id) + chr(4) +
                 p-xml-file-name + chr(4) +
                 string(v_dataseth) + chr(4) +
                 string(v-pck-num) + chr(4) +
                 p-log-file-name + chr(4) +
                 buf_temp-param-name.param-name + chr(4) +
                 buf_temp-param-name.schema-name + chr(4)
                  )
          ,input yes
          ) no-error .
        if error-status:error then do:
          v-my-message = substitute("Ошибка при импорте данных по схеме &2:&3 профайл правил &1&3&4&3&5"
                                      ,buf_temp-param-name.profile_id
                                      ,v-schema-name
                                      ,chr(10)
                                      , error-status:get-message(1)
                                      , return-value
                                      ) .
          run write-log in p-log-handle ( input 2, input v-my-message ).
          if buf_temp-param-name.ruleset_id = 5 then do:
          end.
          next _rule-profile.
        end.
      end.
      when 'thref':U then do:
        run ref/threfrum.p
          (
           input parparentproc
          ,input this-procedure :handle
          ,input p-log-handle
          ,input 'xml-esys-import':U
          ,input buf_temp-param-name.profile_id
          ,input buf_temp-param-name.codex_id
          ,input buf_temp-param-name.ruleset_id
          ,input g#db-num
          ,input buf_temp-param-name.call_id
          ,input (
                 string(p-esys-id) + chr(4) +
                 p-file-name + chr(4) +
                 (if string(v_dataseth) = ? then p-xml-file-name else string(v_dataseth)) + chr(4) +
                 string(v-pck-num) + chr(4) +
                 p-log-file-name + chr(4) +
                 buf_temp-param-name.param-name + chr(4) +
                 buf_temp-param-name.schema-name + chr(4)
                  )
          ,input yes
          ) no-error .
        if error-status:error then do:
          v-my-message = substitute("Ошибка при импорте данных по схеме &2: профайл правил &1&3&4&3&5"
                                      ,buf_temp-param-name.profile_id
                                      ,v-schema-name
                                      , chr(10)
                                      , error-status:get-message(1)
                                      , return-value
                                      ) .
          run write-log in p-log-handle ( input 2, input v-my-message ).
          if buf_temp-param-name.ruleset_id = 5 then do:
          end.
          next _rule-profile.
        end.
      end.
      when 'gds-grp':U then do:
        run str/ggrprum.p
          (
           input parparentproc
          ,input this-procedure :handle
          ,input p-log-handle
          ,input 'xml-esys-import':U
          ,input buf_temp-param-name.profile_id
          ,input buf_temp-param-name.codex_id
          ,input buf_temp-param-name.ruleset_id
          ,input g#db-num
          ,input buf_temp-param-name.call_id
          ,input (
                 string(p-esys-id) + chr(4) +
                 p-xml-file-name + chr(4) +
                 string(v_dataseth) + chr(4) +
                 string(v-pck-num) + chr(4) +
                 p-log-file-name + chr(4) +
                 buf_temp-param-name.param-name + chr(4) +
                 buf_temp-param-name.schema-name + chr(4)
                  )
          ,input yes
          ) no-error .
        if error-status:error then do:
          v-my-message = substitute("Ошибка при импорте данных по схеме &2:&3профайл правил &1&3&4&3&5"
                                      ,buf_temp-param-name.profile_id
                                      ,v-schema-name
                                      ,chr(10)
                                      , error-status:get-message(1)
                                      , return-value
                                      ) .
          run write-log in p-log-handle ( input 2, input v-my-message ).
          if buf_temp-param-name.ruleset_id = 5 then do:
          end.
          next _rule-profile.
        end.
      end.
      when 'goods':U then do:
        run str/goodsrum.p
          (
           input parparentproc
          ,input this-procedure :handle
          ,input p-log-handle
          ,input 'xml-esys-import':U
          ,input buf_temp-param-name.profile_id
          ,input buf_temp-param-name.codex_id
          ,input buf_temp-param-name.ruleset_id
          ,input g#db-num
          ,input buf_temp-param-name.call_id
          ,input (
                 string(p-esys-id) + chr(4) +
                 p-xml-file-name + chr(4) +
                 string(v_dataseth) + chr(4) +
                 string(v-pck-num) + chr(4) +
                 p-log-file-name + chr(4) +
                 buf_temp-param-name.param-name + chr(4) +
                 buf_temp-param-name.schema-name + chr(4)
                  )
          ,input yes
          ) no-error .
        if error-status:error then do:
          v-my-message = substitute("Ошибка при импорте данных по схеме &2:&3профайл правил &1&3&4&3&5"
                                      ,buf_temp-param-name.profile_id
                                      ,v-schema-name
                                      ,chr(10)
                                      , error-status:get-message(1)
                                      , return-value
                                      ) .
          run write-log in p-log-handle ( input 2, input v-my-message ).
          if buf_temp-param-name.ruleset_id = 5 then do:
          end.
          next _rule-profile.
        end.
      end.
      otherwise do:
        v-my-message = substitute("Неизвестный тип &1  профайла &2 для обработки данных по схеме &3"
                                      ,buf_temp-param-name.profile-type
                                    ,buf_temp-param-name.profile_id
                                    , v-schema-name) .
        run write-log in p-log-handle ( input 2, input v-my-message ).
        next _rule-profile.
      end.
    end case.
    v-task-ok = v-task-ok + 1.
    find first buf_esys-pck-keys no-lock where
            buf_esys-pck-keys.esys-id = p-esys-id
        and buf_esys-pck-keys.db-num = p-db-num
        and buf_esys-pck-keys.espr-cr-db-num = g#db-num
        and buf_esys-pck-keys.espr-pack-num = v-pck-num
        and buf_esys-pck-keys.espr-prev-uniq-key = ''
        and buf_esys-pck-keys.espr-uniq-key = substitute("&2&1&3&1&4&1&5"
                                                            , chr(4)
                                                            , buf_temp-param-name.call_id
                                                            , buf_temp-param-name.codex_id
                                                            , buf_temp-param-name.ruleset_id
                                                            , buf_temp-param-name.order_id)
        no-error.
    if not available buf_esys-pck-keys then do:
      do transaction
      on error undo, return error
      :
        create buf_esys-pck-keys.
        assign
        buf_esys-pck-keys.esys-id = p-esys-id
        buf_esys-pck-keys.db-num = p-db-num
        buf_esys-pck-keys.espr-cr-db-num = g#db-num
        buf_esys-pck-keys.espr-pack-num = v-pck-num
        buf_esys-pck-keys.espr-prev-uniq-key = ''
        buf_esys-pck-keys.espr-uniq-key = substitute("&2&1&3&1&4&1&5"
                                                              , chr(4)
                                                              , buf_temp-param-name.call_id
                                                              , buf_temp-param-name.codex_id
                                                              , buf_temp-param-name.ruleset_id
                                                              , buf_temp-param-name.order_id)
        .
      end.
    end.
  end.
  v-rec-cnt = v-rec-cnt + 1
  .
    if valid-handle(v-headerh) then do:
  if v-headerh:available
  and v-headerh:table = "THheader"
  and v-headerh::THtotal-recs <> v-rec-cnt then do:
    v-my-message = substitute("Не совпадает количество считанных записей и ожидаемое количество :&1" +
                                 "принято: &2&1"  +
                                 "должно быть: &3"
                                 ,chr(10)
                                 ,v-rec-cnt
                                ,v-headerh::THtotal-recs) .
    run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
    os-delete value(v-schema-tmp-file).
    undo, return error v-my-message.
  end.
end.
  if v-task = v-task-ok then do:
    if buf_ext-system.delivery-method = integer('5':U)  then do:
      run get-xcnf_get-xcnf in this-procedure (
                                        input p-esys-id
                                      ,input p-db-num
                                      ,input g#db-num
                                      ,input p-pack-num
                                      ,input buf_ext-system.delivery-method
                                      ,buffer buf_temp-esys-pck-sent
                                      ,buffer buf_temp-esys-pck-rcvd
                                      ,buffer curr_temp-esys-pck-sent
                                      ,output v-rec-cnt
                                    ) no-error.
      if error-status :error then do:
        v-my-message = substitute("Ошибка при принятии подтверждений из ВС:&1&2&1&3"
                                  , chr(10)
                                  , error-status:get-message(1)
                                  , return-value ) .
      run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
      os-delete value(v-schema-tmp-file).
      undo, return error v-my-message.
      end.
    end.
    if buf_ext-system.imp-conf-send  = integer('1':U)
    then do:
      run get-xcnf_set-xcnf in this-procedure (
                                       input p-esys-id
                                      ,input p-db-num
                                      ,input g#db-num
                                      ,input p-pack-num
                                      ,input v-rec-cnt
                                      ,input v-headerh
                                      ,buffer buf_temp-esys-pck-sent
                                      ,buffer buf_temp-esys-pck-rcvd
                                      ,buffer curr_temp-esys-pck-sent
                                    ) no-error.
    if error-status :error then do:
      v-my-message = substitute("Ошибка при выставлении подтверждений:&1&2&1&3"
                                  , chr(10)
                                  , error-status:get-message(1)
                                  , return-value ) .
      run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
      os-delete value(v-schema-tmp-file).
      undo, return error v-my-message.
    end.
    end.
    else do:
      run get-xcnf_set0xcnf in this-procedure (
                                       input p-esys-id
                                      ,input p-db-num
                                      ,input g#db-num
                                      ,input p-pack-num
                                      ,input buf_ext-system.delivery-method
                                      ,input v-rec-cnt
                                      ,input v-headerh
                                      )  no-error.
      if error-status :error then do:
        v-my-message = substitute("Ошибка при выставлении подтверждений:&1&2&1&3"
                                  , chr(10)
                                  , error-status:get-message(1)
                                  , return-value ) .
        run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
        os-delete value(v-schema-tmp-file).
        undo, return error v-my-message.
      end.
    end.
  end.
  for each buf_temp-esys-pck-sent  :
    delete buf_temp-esys-pck-sent .
  end.
  run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
  run send-to-cash in this-procedure no-error.
  return.
end.
procedure set-err-type :
define input parameter p-err-type as character no-undo .
do
on error undo, return error
:
  run set-err-type in p-parent-handle ( input p-err-type) no-error.
  if error-status:error then do:
    return error return-value .
  end.
end.
end procedure.
