block-level on error undo, throw.
define input  parameter parparentproc   as   widget-handle        no-undo .
define input  parameter p-action        as   character            no-undo .
define input  parameter p-db-num        like ub.db.db-num         no-undo .
define input  parameter p-pack-num      like ub.pck-sent.pack-num no-undo.
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: rcvd-nws.p $":U .
def var vss-archive     as character no-undo init "$Archive: nws/rcvd-nws.p $":U .
def var vss-description as character no-undo init "Прием новостей из указанной БД".
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
      return error substitute( "&1. Ошибка при определении текущей даты!", vss-include-info3 ).
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
      return error substitute( "&1. НЕТ ОБРАБОТКИ АТРИБУТА &2!", vss-include-info3, p-task-type ).
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define buffer buf_db       for ub.db .
  define buffer buf_sys-ctrl for ub.sys-ctrl .
  define buffer buf_db-attr  for ub.db-attr .
  define variable v-ver-num      as character no-undo .
  define variable v-pack-num     as integer   no-undo .
  define variable v-pack-name    as character no-undo .
  define variable v-source-dir   as character no-undo .
  define variable v-target-dir   as character no-undo .
  define variable v-temp-dir     as character no-undo .
  define variable v-rcvd-pack    as logical   no-undo .
  define variable v-err-msg      as character no-undo .
  define variable v-mem as memptr no-undo .
  define variable v-str as longchar no-undo .
  define variable v-last-rcv-pck as integer no-undo .
  define variable v-last-sent-pck as integer no-undo .
  define variable vOk as logical no-undo .
  define variable apusharh as logical   no-undo .
  find first buf_sys-ctrl no-lock .
  run get-version-num in parparentproc
    ( output v-ver-num
    ).
  find first buf_db no-lock
    where buf_db.db-num = p-db-num
    no-error
  .
  if not available buf_db then do:
    run write-to-log( substitute( "&1. БД &2 не найдена", vss-workfile, p-db-num ) ) .
    return error.
  end.
  if buf_db.db-key = "":U
    or buf_db.db-key = ?
  then do:
    run write-to-log( substitute("СПН для БД &1 отключена. Пакеты новостей не принимаются.", p-db-num ) ) .
    return.
  end.
  case p-action:
    when "take":U then do:
      run write-to-log( substitute("Прием пакетов новостей из БД &1", p-db-num ) ) .
    end.
    when "analys":U then do:
      run write-to-log( substitute("Разбор пакетов новостей из БД &1", p-db-num ) ) .
    end.
    when "take+analys":U then do:
      run write-to-log( substitute("Прием и разбор пакетов новостей из БД &1", p-db-num ) ) .
    end.
    otherwise do:
      message vss-workfile vss-revision vss-description skip
              substitute( "Не предусмотрена операция &1", p-action )
              view-as alert-box error.
      return error.
    end.
  end case.
  assign
    g#news-source-db = p-db-num
  .
  run nws/lock-nws.p
    ( input p-db-num
     ,buffer buf_db
    ) no-error.
  if error-status:error then do:
    run write-to-log( substitute( "&1. &2", vss-workfile, return-value ) ).
    return .
  end.
  assign
    v-pack-num = -1
    v-rcvd-pack = false
  .
  run nws/pck-num.p
    ( input "get":U
     ,input p-db-num
     ,input-output v-pack-num
     ,output v-pack-name
     ,output v-source-dir
     ,output v-target-dir
     ,output v-temp-dir
    ) no-error.
  if error-status:error then do:
    run write-to-log( substitute( "&1. Ошибка при генерации номера пакета. &2&3&2&4", vss-workfile, chr(10), error-status:get-message(1), return-value )
                    ) .
    return error.
  end.
  if lookup( p-action, "take,take+analys":U ) <> 0 then do:
    run nws/s-g-pack.p
      ( input "get":U
       ,input ?
       ,input ?
       ,input v-source-dir
       ,input v-target-dir
       ,input v-temp-dir
      ) no-error.
    if error-status:error then do:
      run write-to-log( substitute( "&1. &2", vss-workfile, return-value ) ).
      return error.
    end.
  end.
  if lookup( p-action, "analys,take+analys":U ) <> 0
  then do:
    if p-db-num > 0
    then do transaction :
      assign
        file-info:file-name = v-target-dir + chr(92) + "p9999999.txt"
      .
      if file-info:file-type <> ?
      and file-info:file-type begins "F":U
      then do :
        copy-lob from file (v-target-dir + chr(92) + "p9999999.txt") to v-str .
        v-mem = base64-decode (v-str) no-error .
        copy-lob from v-mem to v-str no-error .
        if v-str begins "needsync"
        and num-entries(v-str, chr(4)) = 5
        then do :
          os-delete value (v-target-dir + chr(92) + "p9999999.txt") no-error .
          os-delete value (v-source-dir + chr(92) + "p9999999.zip") no-error .
          find first buf_db-attr no-lock where buf_db-attr.db-num = p-db-num
                                           and buf_db-attr.attr-code = "last-nws-sync"
          no-error .
          if integer(entry(2, v-str, chr(4))) = p-db-num
          and (not available buf_db-attr
               or (available buf_db-attr and datetime-tz(buf_db-attr.attr-value) < datetime-tz(entry(5, v-str, chr(4))))
               )
          then do :
            run write-to-log( substitute( "Получен запрос на синхронизацию обмена СПН с БД &1", p-db-num ) ) .
            run nws/pck-num.p
              ( input "put":U
               ,input p-db-num
               ,input-output v-pack-num
               ,output v-pack-name
               ,output v-source-dir
               ,output v-target-dir
               ,output v-temp-dir
              ) no-error.
            if error-status:error then do:
              run write-to-log( substitute( "&1. Ошибка при генерации номера пакета. &2&3&2&4", vss-workfile, chr(10), error-status:get-message(1), return-value )
                              ) .
              return error.
            end.
            os-delete value (v-source-dir) recursive .
            os-delete value (v-target-dir) recursive .
            os-delete value (v-temp-dir)   recursive .
            assign
              file-info:file-name = v-source-dir
            .
            if file-info:file-type = ?
            or not ( file-info:file-type begins "D":U )
            then do:
              os-create-dir value( v-source-dir ).
              if os-error <> 0 then do:
                return error string( vss-workfile + chr(32)
                                     + "Каталог" + chr(32) + v-source-dir
                                     + chr(32) + "отсутствует, а создать его не удалось." ).
              end.
            end.
            assign
              file-info:file-name = v-target-dir
            .
            if file-info:file-type = ?
            or not ( file-info:file-type begins "D":U )
            then do:
              os-create-dir value( v-target-dir ).
              if os-error <> 0 then do:
                return error string( vss-workfile + chr(32)
                                     + "Каталог" + chr(32) + v-target-dir
                                     + chr(32) + "отсутствует, а создать его не удалось." ).
              end.
            end.
            assign
              v-last-rcv-pck  = integer(entry(3, v-str, chr(4)))
              v-last-sent-pck = integer(entry(4, v-str, chr(4)))
            .
            run nws/nws-sync.p (input parparentproc,
                                input p-db-num,
                                input v-last-rcv-pck,
                                input v-last-sent-pck,
                                output vOk)
                                no-error .
            if not vOk
            or error-status:error
            then do :
              run write-to-log( substitute( "Ошибка при синхронизация обмена СПН с БД &1&2&3", p-db-num, chr(10), return-value ) ) .
            end .
            if vOk
            then do :
              run db-attr-write in this-procedure
              ( input p-db-num
               ,input "last-nws-sync"
               ,input entry(5, v-str, chr(4))
              ) no-error.
              return .
            end .
          end .
        end .
      end .
    end .
    rcvd-pack:
    do while TRUE
    on error  undo, return error substitute( "&1 (rcvd-pack). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1 (rcvd-pack). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (rcvd-pack). endkey", vss-workfile )
    :
      run nws/pck-num.p
        ( input "get":U
         ,input p-db-num
         ,input-output v-pack-num
         ,output v-pack-name
         ,output v-source-dir
         ,output v-target-dir
         ,output v-temp-dir
        ) no-error.
      if error-status:error then do:
        run write-to-log( substitute( "&1. Ошибка при генерации номера пакета. &2&3&2&4", vss-workfile, chr(10), error-status:get-message(1), return-value )
                        ) .
        return error.
      end.
      assign
        file-info:file-name = v-target-dir + chr(92) + v-pack-name
      .
      if file-info:file-type = ?
        or not ( file-info:file-type begins "F":U ) then do:
        leave rcvd-pack.
      end.
      run nws/imp-pck.p
        ( input parparentproc
        , input p-db-num
        , input v-pack-num
        , input v-target-dir + chr(92) + v-pack-name
        ) no-error.
      if error-status:error then do:
        assign
          v-err-msg = substitute("&1. Ошибка импорта пакета &3\&4&2&5&2&6", vss-workfile, chr(10), v-target-dir, v-pack-name, error-status :get-message( 1 ), return-value )
        .
        run write-to-log( v-err-msg ) .
        run send-msg-to-email in parparentproc
          ( input substitute( "ТН (ver &1) БД &2. Ошибка СПН при импорте пакета из БД &2", v-ver-num, buf_sys-ctrl.db-num, p-db-num )
           ,input v-err-msg
           ,input "":U
          ) no-error .
        if error-status :error then do:
          run write-to-log( substitute( "&1. &3&2&4", vss-workfile, chr(10), error-status:get-message(1), return-value )
                          ) .
        end.
        return error.
      end.
      assign
        v-rcvd-pack = true
        v-pack-num = v-pack-num + 1
      .
      if ( p-pack-num <> -1
           and v-pack-num > p-pack-num
         )
      then do:
        leave rcvd-pack.
      end.
    end.
    if v-rcvd-pack = true then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'arh-global':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
      for each thbjattr_thbj-attr :
          if thbjattr_thbj-attr.prop-code = 'apusharh'  then apusharh = thbjattr_thbj-attr.property-value-logical.
      end.
      empty temp-table thbjattr_thbj-attr.
      if apusharh then do:
        run push-abtpr in this-procedure
          ( input auto-window-h
           ,input p-db-num
           ,input 'autoarh':U
           ,input "news-push":U
           ,input ?
           ,input ?
          ) no-error .
        if error-status :error then do:
          run write-to-log( substitute( "&1. Ошибка при изменении времени запуска автоматического расчета архивов. &2&3&2&4"
                                        , vss-workfile
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , return-value
                                      )
                          ) .
        end.
      end.
    end.
  end.
  run gbl/del-file.p
    ( input v-temp-dir
    ) no-error .
  if error-status:error then do:
    run write-to-log(  substitute( "&1. &2", vss-workfile, return-value ) ).
  end.
  case p-action:
    when "take":U then do:
      run write-to-log( substitute( "Завершен прием пакетов новостей из БД &1", p-db-num ) ) .
    end.
    when "analys":U then do:
      run write-to-log( substitute( "Завершен разбор пакетов новостей из БД &1", p-db-num ) ) .
    end.
    when "take+analys":U then do:
      run write-to-log( substitute( "Завершен прием и разбор пакетов новостей из БД &1", p-db-num ) ) .
    end.
  end case.
  return.
end.
