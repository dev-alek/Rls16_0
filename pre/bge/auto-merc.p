block-level on error undo, throw.
using Progress.Lang.*.
using ibs.th.str.gds.*.
using ibs.th.str.mercury.*.
using ibs.th.gbl.*.
using ibs.th.gbl.storage.*.
using ibs.th.str.clients.*.
using ibs.th.bge.mercury.*.
define input  parameter p-user-login    as character no-undo .
define input  parameter p-user-password as character no-undo .
define input  parameter p-list-db       as character no-undo .
def var vss-revision    as character no-undo init "$Revision: d6a01d2b837a, 2559, rls $":U .
def var vss-author      as character no-undo init "$Author: SSlivenko $":U .
def var vss-date        as character no-undo init "$Date: Вт авг 11 18:31:46 2020 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: auto-merc.p $":U .
def var vss-archive     as character no-undo init "$Archive: bge/auto-merc.p $":U .
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do
on error undo, return error
:
  define variable v-ind                    as integer   no-undo .
  define variable v-num-entries-db-list    as integer   no-undo .
  define variable v-db-num                 as integer   no-undo .
  define variable v-err-gen-pack           as integer   no-undo .
  define variable v-err-code               as integer   no-undo .
  define variable v-step-num               as integer   no-undo .
  define variable v-action                 as character no-undo .
  define variable v-message                as character no-undo .
  define variable v-proc-handle            as handle    no-undo .
  define variable v-main-proc-name         as character no-undo .
  define variable v-count-main-prc         as integer   no-undo .
  define variable v-pers-proc-name         as character no-undo .
  define variable v-apiKey              as character no-undo .
  define variable v-issuerId            as character no-undo .
  define variable v-login               as character no-undo .
  define variable v-login_is            as character no-undo .
  define variable v-password            as character no-undo .
  define variable v-initiator           as character no-undo .
  define variable v-type-connect        as integer   no-undo .
  define variable v-server              as integer   no-undo .
  define variable v-proxy-login         as character no-undo .
  define variable v-proxy-pswd          as character no-undo .
  define variable v-proxy-addres        as character no-undo .
  define variable v-proxy-ssl           as logical   no-undo .
  define variable v-appId           as character no-undo .
  define variable v-status_         as character no-undo .
  define variable v-Msg             as character no-undo .
  define buffer buf_ext-classif       for ub.ext-classif .
  define buffer buf2_ext-classif      for ub.ext-classif .
  define buffer buf_ext-system        for ub.ext-system .
  define buffer buf_parts             for ub.parts .
  define buffer buf_vsd               for ub.vsd .
  define buffer buf_clients           for ub.clients .
  define buffer buf_esys-all-attr     for ub.esys-all-attr .
  define buffer buf_db                for ub.db .
  define variable mercury       as class ibs.th.bge.mercury.mercury       no-undo.
  define variable vsdStorage    as class ibs.th.gbl.storage.vsdtostorage  no-undo.
  define variable vsdsTHObj     as class ibs.th.str.mercury.vsdsubs       no-undo.
  define variable vsdTHObj      as class ibs.th.str.mercury.vsdsub        no-undo.
  define variable vsdStsType    as class ibs.th.str.mercury.vsdstatustype no-undo.
  define variable objThObj      as class ibs.th.str.clients.clisub        no-undo.
  define variable objKeyRec     as class ibs.th.gbl.keyrec                no-undo.
  define variable v-part-rowid as rowid no-undo .
  define variable v-tbl-name as character no-undo .
  define variable ii as integer no-undo.
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
    v-num-entries-db-list = num-entries( p-list-db )
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
  find first buf_ext-system no-lock where buf_ext-system.esys-type = integer('10':U) no-error.
  if not available buf_ext-system
  then do :
    run write-to-log( "Нет внешней системы с типом Меркурий." ) .
    return .
  end.
  SECURITY-POLICY:SYMMETRIC-ENCRYPTION-KEY = GENERATE-PBE-KEY("sysadm").
  objThObj = new clisub ().
  vsdStsType = new vsdstatustype().
  run write-to-log( "Получение ответов на отправленные запросы " ) .
  ans_ :
  for each buf_esys-all-attr no-lock where buf_esys-all-attr.table-name = "esys-pck-sent"
                                      and buf_esys-all-attr.attr-code = "mercury"
                                      and buf_esys-all-attr.key3 = "Запрос отправлен" :
    find first buf_vsd no-lock where buf_vsd.UUID = buf_esys-all-attr.attr-value no-error.
    if not available buf_vsd then next ans_ .
    if not can-do(p-list-db, string(buf_vsd.db-num))
    then do :
      next ans_ .
    end .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input buf_vsd.obj-type
  ,input buf_vsd.obj-code
  ,input 'mercur':U
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
      case thbjattr_thbj-attr.prop-code :
        when "apikey" then v-apiKey = thbjattr_thbj-attr.property-value-character .
        when "login" then v-login = thbjattr_thbj-attr.property-value-character .
        when "login_is" then v-login_is = thbjattr_thbj-attr.property-value-character .
        when "password" then v-password = thbjattr_thbj-attr.property-value-character .
        when "type-connect" then v-type-connect = thbjattr_thbj-attr.property-value-integer .
        when "server" then v-server = thbjattr_thbj-attr.property-value-integer .
        when "proxy-addres" then v-proxy-addres = thbjattr_thbj-attr.property-value-character .
        when "proxy-login" then do:
          if thbjattr_thbj-attr.property-value-character <> ""
          then do :
define variable vss-include-info7 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pdecrypt in g#library2
  (input  thbjattr_thbj-attr.property-value-character
  ,output v-proxy-login
  ) no-error .
          end.
        end.
        when "proxy-pswd" then do:
          if thbjattr_thbj-attr.property-value-character <> ""
          then do :
define variable vss-include-info8 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pdecrypt in g#library2
  (input  thbjattr_thbj-attr.property-value-character
  ,output v-proxy-pswd
  ) no-error .
          end.
        end.
        when "proxy-ssl" then v-proxy-ssl = thbjattr_thbj-attr.property-value-logical .
      end case.
    end.
    if g#db-num <> 0 and v-type-connect = 2
    then do :
      next ans_ .
    end.
    find first buf_clients no-lock where buf_clients.obj-type = buf_vsd.obj-type and buf_clients.obj-code = buf_vsd.obj-code no-error.
    if not available buf_clients
    then do :
      run write-to-log( "В ВСД с UUID " + buf_vsd.UUID + " не верно задан объект!!!") .
      next ans_ .
    end.
    if v-type-connect = 1 and g#db-num <> 0 and g#db-num <> buf_clients.db-num
    then do :
      next ans_ .
    end.
    if g#db-num = 0 and v-type-connect = 1 and buf_clients.db-num <> 0
    then do :
      next ans_ .
    end.
    find first buf_db no-lock where buf_db.db-num = buf_clients.db-num .
    if buf_db.stts = 2
    then do :
      run write-to-log( "БД " + string(buf_db.db-num) + " выгружается. Пропускаем." ).
      next ans_ .
    end.
    find first buf_ext-classif no-lock
          where buf_ext-classif.classif-subject = 'clients':U
            and buf_ext-classif.classif-name = 'clients-esys':U
            and buf_ext-classif.db-num = 0
            and buf_ext-classif.key#_one = buf_ext-system.esys-id
            and buf_ext-classif.uniq-key-rec = 'clients':U + chr(3) + "орг" + chr(3) + string (buf_clients.host-code)
            no-error.
    if not available buf_ext-classif
    then do :
      run write-to-log( "Фирма орг" + string (buf_clients.host-code) + " не синхронизирована с ФГИС Меркурий (Нет GUID'а ХЗ)" ) .
      next ans_ .
    end.
    v-issuerId = entry(1, buf_ext-classif.charKey_Two, chr(6)) .
    mercury = new mercury(v-apiKey, v-issuerId, v-login, v-password, v-login_is, buf_ext-system.esys-id, v-server, v-proxy-addres, v-proxy-login, v-proxy-pswd, v-proxy-ssl, buf_db.db-num).
    mercury:vsdId = buf_esys-all-attr.key1.
    case buf_esys-all-attr.key2 :
      when 1
      then do :
        find first buf_vsd no-lock where buf_vsd.UUID = buf_esys-all-attr.attr-value and buf_vsd.ID =  buf_esys-all-attr.key1 no-error.
        if not available buf_vsd then next .
        objKeyRec = new keyrec () .
        objKeyRec:GenRowKeyr(buf_vsd.part-key, ?, "ub", ?, ?, v-part-rowid, v-tbl-name) .
        delete object objKeyRec no-error .
        find first buf_parts no-lock where rowid (buf_parts) = v-part-rowid no-error.
        if not available  buf_parts
        then do :
          run write-to-log( "ВСД с UUID " + buf_vsd.UUID + " не привязана к партии!!!") .
          next ans_.
        end.
        run write-to-log( "Получение ответа на запрос ВСД по UUID " + buf_vsd.UUID ) .
        do transaction :
          mercury:receiveVetDoc(input buf_esys-all-attr.key7, input LC(buf_esys-all-attr.attr-value), input buf_parts.qnty, input buf_parts.fact-qnty, input (buf_vsd.status_ = vsdStsType:IsUtilized), output v-Status_, output v-Msg) .
          delete object mercury no-error .
          find first ub.esys-all-attr exclusive-lock where rowid(ub.esys-all-attr) = rowid(buf_esys-all-attr) .
          if v-Status_ = "COMPLETED"
          then ub.esys-all-attr.key3 = "Ответ получен" .
          else do :
            v-Msg = trim(trim(v-Msg, chr(10))) .
            if v-Msg = ""
            then do :
              v-Msg = "Нет связи со шлюзом Ветис.Api..." .
              run write-to-log( v-Msg ) .
            end.
            else do :
              ub.esys-all-attr.key3 = "Запрос отклонён" .
              run write-to-log( "UUID ВСД:  " + buf_esys-all-attr.attr-value + chr(10) + v-Msg ) .
            end.
          end.
          release ub.esys-all-attr .
        end.
      end.
      when 2
      then do :
        run write-to-log( "Получение ответа на запрос на гашение ВСД с UUID " + buf_esys-all-attr.attr-value ) .
        do transaction :
          mercury:receiveIncomingConsignmentResponse(input buf_esys-all-attr.key7, input buf_esys-all-attr.attr-value, output v-Status_, output v-Msg) .
          delete object mercury no-error .
          find first ub.esys-all-attr exclusive-lock where rowid(ub.esys-all-attr) = rowid(buf_esys-all-attr) .
          if v-Status_ = "COMPLETED"
          then ub.esys-all-attr.key3 = "Ответ получен" .
          else do :
            v-Msg = trim(trim(v-Msg, chr(10))) .
            if v-Msg = ""
            then do :
              v-Msg = "Нет связи со шлюзом Ветис.Api..." .
              run write-to-log( v-Msg ) .
            end.
            else do :
              ub.esys-all-attr.key3 = "Запрос отклонён" .
              if v-Msg = "MERC14561"
              or v-Msg = "MERC14562"
              or v-Msg = "MERC14563"
              then
                run write-to-log( "UUID ВСД:  " + buf_esys-all-attr.attr-value + chr(10) + "Ошибка наименования продукции " + v-Msg + ". ВСД будет погашено с актом несоответсвия." ) .
              else
              if v-Msg = "MERC14258"
              or v-Msg = "MERC14537"
              then
                run write-to-log( "UUID ВСД:  " + buf_esys-all-attr.attr-value + chr(10) + "Ошибка номера партии/ТТН " + v-Msg + ". ВСД будет погашено с актом несоответсвия." ) .
              else
                run write-to-log( "UUID ВСД:  " + buf_esys-all-attr.attr-value + chr(10) + v-Msg ) .
            end.
          end.
        end.
      end.
    end case.
    delete object mercury no-error .
  end.
  pause 0.2 .
  do v-ind = 1 to v-num-entries-db-list
  on error undo, return error
  :
    assign
      v-db-num = integer( entry( v-ind, p-list-db ) )
    .
    find first buf_db no-lock where buf_db.db-num = v-db-num .
    if buf_db.stts = 2
    then do :
      run write-to-log( "БД " + string(v-db-num) + " выгружается. Пропускаем." ).
      next .
    end.
    run write-to-log( "Работа с БД " + string(v-db-num) ) .
    clients_ :
    for each clients no-lock where clients.obj-type = 'маг':U
                               and clients.db-num = v-db-num
                               and clients.stts = 0 :
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input clients.obj-type
  ,input clients.obj-code
  ,input 'mercur':U
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
        case thbjattr_thbj-attr.prop-code :
          when "apikey" then v-apiKey = thbjattr_thbj-attr.property-value-character .
          when "login" then v-login = thbjattr_thbj-attr.property-value-character .
          when "login_is" then v-login_is = thbjattr_thbj-attr.property-value-character .
          when "password" then v-password = thbjattr_thbj-attr.property-value-character .
          when "type-connect" then v-type-connect = thbjattr_thbj-attr.property-value-integer .
          when "server" then v-server = thbjattr_thbj-attr.property-value-integer .
          when "proxy-addres" then v-proxy-addres = thbjattr_thbj-attr.property-value-character .
          when "proxy-login" then do:
            if thbjattr_thbj-attr.property-value-character <> ""
            then do :
define variable vss-include-info10 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pdecrypt in g#library2
  (input  thbjattr_thbj-attr.property-value-character
  ,output v-proxy-login
  ) no-error .
            end.
          end.
          when "proxy-pswd" then do:
            if thbjattr_thbj-attr.property-value-character <> ""
            then do :
define variable vss-include-info11 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pdecrypt in g#library2
  (input  thbjattr_thbj-attr.property-value-character
  ,output v-proxy-pswd
  ) no-error .
            end.
          end.
          when "proxy-ssl" then v-proxy-ssl = thbjattr_thbj-attr.property-value-logical .
        end case.
      end.
      if v-type-connect = 1 and g#db-num <> 0 and g#db-num <> clients.db-num
      then do :
        next clients_.
      end.
      if g#db-num <> 0 and v-type-connect = 2
      then do :
        next clients_.
      end.
      if g#db-num = 0 and v-type-connect = 1 and clients.db-num <> 0
      then do :
        next clients_.
      end.
      find first buf_ext-classif no-lock
            where buf_ext-classif.classif-subject = 'clients':U
              and buf_ext-classif.classif-name = 'clients-esys':U
              and buf_ext-classif.db-num = 0
              and buf_ext-classif.key#_one = buf_ext-system.esys-id
              and buf_ext-classif.uniq-key-rec = 'clients':U + chr(3) + "орг" + chr(3) + string (clients.host-code)
              no-error.
      if not available buf_ext-classif
      then do :
        run write-to-log( "Фирма орг" + string (clients.host-code) + " не синхронизирована с ФГИС Меркурий (Нет GUID'а ХЗ)" ) .
        next clients_.
      end.
      v-issuerId = entry(1, buf_ext-classif.charKey_Two, chr(6)) .
      mercury = new mercury(v-apiKey, v-issuerId, v-login, v-password, v-login_is, buf_ext-system.esys-id, v-server, v-proxy-addres, v-proxy-login, v-proxy-pswd, v-proxy-ssl, buf_db.db-num).
      objThObj:ObjType = clients.obj-type.
      objThObj:ObjCode = clients.obj-code.
      vsdsTHObj = new vsdsubs ().
      vsdsTHObj:IsDelChildObj = yes .
      vsdStorage = new vsdtostorage ().
      vsdsTHObj = vsdStorage:getVSDsubs(input objThObj).
      find first buf_ext-classif no-lock
          where buf_ext-classif.classif-subject = 'clients':U
            and buf_ext-classif.classif-name = 'clients-esys':U
            and buf_ext-classif.db-num = 0
            and buf_ext-classif.key#_one = buf_ext-system.esys-id
            and buf_ext-classif.uniq-key-rec = 'clients':U + chr(3) + clients.obj-type + chr(3) + string (clients.obj-code)
            no-error.
      run write-to-log( "Отправка запросов по объекту " + clients.obj-type + string(clients.obj-code) ) .
      vsds_ :
      do ii = 1 to vsdsTHObj:GetItem (ii):
        if ii = 1 and not available buf_ext-classif
        then do :
          run write-to-log( "Объект маг" + string (clients.obj-code) + " не синхронизирован с ФГИС Меркурий (Нет GUID'а предприятия)" ) .
          delete object vsdsTHObj no-error .
          delete object vsdStorage no-error .
          next clients_.
        end.
        if date(vsdsTHObj:VsdObjCurr:FactDatetime) < (today - 14) then next vsds_ .
        if vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsNeedCheck
        or vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsErrCheck
        or vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsErrUtilized
        then do :
          if vsdsTHObj:VsdObjCurr:UUID = "" or vsdsTHObj:VsdObjCurr:UUID = ? or vsdsTHObj:VsdObjCurr:FactDatetime = ? then next .
          find first buf2_ext-classif no-lock
              where buf2_ext-classif.classif-subject = 'clients':U
                and buf2_ext-classif.classif-name = 'clients-esys':U
                and buf2_ext-classif.db-num = 0
                and buf2_ext-classif.key#_one = buf_ext-system.esys-id
                and buf2_ext-classif.uniq-key-rec = 'clients':U + chr(3) + vsdsTHObj:VsdObjCurr:CliType + chr(3) + string (vsdsTHObj:VsdObjCurr:CliCode)
                no-error.
          if not available buf2_ext-classif
          then do :
            vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsErrCheck .
            vsdsTHObj:VsdObjCurr:MsgErr = "Контрагент-поставщик не синхронизирован с ФГИС Меркурий." .
            do transaction :
              vsdStorage:updateDB(vsdsTHObj:VsdObjCurr) .
            end.
            run write-to-log( "UUID ВСД: " + vsdsTHObj:VsdObjCurr:UUID + " .   Контрагент-поставщик не синхронизирован с ФГИС Меркурий. Запрос не отправлен." ) .
            next vsds_.
          end.
          else do :
            if num-entries(buf2_ext-classif.charKey_Two, chr(6)) = 2
            then do :
              if entry(1, buf2_ext-classif.charKey_Two, chr(6)) = ""
              or entry(2, buf2_ext-classif.charKey_Two, chr(6)) = ""
              then do :
                if vsdsTHObj:VsdObjCurr:CliType = 'маг'
                then do :
                  if entry(2, buf2_ext-classif.charKey_Two, chr(6)) = ""
                  then do :
                    vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsErrCheck .
                    vsdsTHObj:VsdObjCurr:MsgErr = "Не заполнен GUID предприятия поставщика." .
                    do transaction :
                      vsdStorage:updateDB(vsdsTHObj:VsdObjCurr) .
                    end.
                    run write-to-log( "UUID ВСД: " + vsdsTHObj:VsdObjCurr:UUID + " .   Не заполнены GUID предприятия поставщика. Запрос не отправлен." ) .
                    next vsds_.
                  end.
                end.
                else do :
                  vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsErrCheck .
                  vsdsTHObj:VsdObjCurr:MsgErr = "Не заполнены GUID'ы хоз. субъекта поставщика и/или предприятия поставщика." .
                  do transaction :
                    vsdStorage:updateDB(vsdsTHObj:VsdObjCurr) .
                  end.
                  run write-to-log( "UUID ВСД: " + vsdsTHObj:VsdObjCurr:UUID + " .   Не заполнены GUID'ы хоз. субъекта поставщика и/или предприятия поставщика. Запрос не отправлен." ) .
                  next vsds_.
                end.
              end .
            end.
            else do :
              vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsErrCheck .
              vsdsTHObj:VsdObjCurr:MsgErr = "Не верный формат связки поставщика с ФГИС Меркурий" .
              vsdStorage:updateDB(vsdsTHObj:VsdObjCurr) .
              run write-to-log( "UUID ВСД: " + vsdsTHObj:VsdObjCurr:UUID + " .   Не верный формат связки поставщика с ФГИС Меркурий. Запрос не отправлен." ) .
              next vsds_.
            end.
          end.
          find first buf_esys-all-attr no-lock where buf_esys-all-attr.table-name = "esys-pck-sent"
                                                and buf_esys-all-attr.attr-code = "mercury"
                                                and buf_esys-all-attr.attr-value = vsdsTHObj:VsdObjCurr:UUID
                                                and buf_esys-all-attr.key1 = vsdsTHObj:VsdObjCurr:ID
                                                and buf_esys-all-attr.key2 = 1
                                                and buf_esys-all-attr.key3 = "Запрос отправлен"
                                                no-error .
          if available buf_esys-all-attr then next vsds_ .
          run write-to-log( "Отправка запроса на получение ВСД по UUID " + vsdsTHObj:VsdObjCurr:UUID ) .
          mercury:GetVetDocumentByUuid(LC(vsdsTHObj:VsdObjCurr:UUID), entry(2, buf_ext-classif.charKey_Two, chr(6)), v-appId, v-status_, v-Msg) .
          if v-status_ <> "ACCEPTED"
          then do :
            v-Msg = trim(trim(v-Msg, chr(10))) .
            if v-Msg = "" then v-Msg = "Нет связи со шлюзом Ветис.Api..." .
            run write-to-log( v-Msg ) .
            next  vsds_.
          end .
          do transaction :
            create buf_esys-all-attr .
            assign
              buf_esys-all-attr.table-name = "esys-pck-sent"
              buf_esys-all-attr.attr-code = "mercury"
              buf_esys-all-attr.key3 = "Запрос отправлен"
              buf_esys-all-attr.key4 = string(now)
              buf_esys-all-attr.key7 = v-appId
              buf_esys-all-attr.key2 = 1
              buf_esys-all-attr.key8 = g#auto-user-id
            .
            buf_esys-all-attr.key1 = vsdsTHObj:VsdObjCurr:ID .
            buf_esys-all-attr.attr-value = LC(vsdsTHObj:VsdObjCurr:UUID) .
          end.
        end.
        if vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsNeedUtilized
        then do :
          if vsdsTHObj:VsdObjCurr:UUID = "" or vsdsTHObj:VsdObjCurr:UUID = ? or vsdsTHObj:VsdObjCurr:FactDatetime = ? then next .
          find first buf_esys-all-attr no-lock where buf_esys-all-attr.table-name = "esys-pck-sent"
                                                and buf_esys-all-attr.attr-code = "mercury"
                                                and buf_esys-all-attr.attr-value = vsdsTHObj:VsdObjCurr:UUID
                                                and buf_esys-all-attr.key1 = vsdsTHObj:VsdObjCurr:ID
                                                and buf_esys-all-attr.key2 = 2
                                                and buf_esys-all-attr.key3 = "Запрос отправлен"
                                                no-error .
          if available buf_esys-all-attr then next  vsds_.
          objKeyRec = new keyrec () .
          objKeyRec:GenRowKeyr(vsdsTHObj:VsdObjCurr:PartKey, ?, "ub", ?, ?, v-part-rowid, v-tbl-name) .
          delete object objKeyRec no-error .
          find first buf_parts no-lock where rowid (buf_parts) = v-part-rowid no-error.
          if not available  buf_parts
          then do :
            run write-to-log( "ВСД с UUID " + vsdsTHObj:VsdObjCurr:UUID + " не привязана к партии!!!") .
            next vsds_.
          end.
          run write-to-log( "Отправка запроса на гашение ВСД с UUID " + vsdsTHObj:VsdObjCurr:UUID ) .
          mercury:processIncomingConsignment(vsdsTHObj, buf_parts.qnty, buf_parts.fact-qnty, v-appId, v-status_, v-Msg) .
          if v-status_ <> "ACCEPTED"
          then do :
            v-Msg = trim(trim(v-Msg, chr(10))) .
            if v-Msg = "" then v-Msg = "Нет связи со шлюзом Ветис.Api..." .
            run write-to-log( v-Msg ) .
            next vsds_ .
          end .
          do transaction :
            create buf_esys-all-attr .
            assign
              buf_esys-all-attr.table-name = "esys-pck-sent"
              buf_esys-all-attr.attr-code = "mercury"
              buf_esys-all-attr.key3 = "Запрос отправлен"
              buf_esys-all-attr.key4 = string(now)
              buf_esys-all-attr.key7 = v-appId
              buf_esys-all-attr.key2 = 2
              buf_esys-all-attr.key8 = g#auto-user-id
            .
            buf_esys-all-attr.key1 = vsdsTHObj:VsdObjCurr:ID .
            buf_esys-all-attr.attr-value = LC(vsdsTHObj:VsdObjCurr:UUID) .
          end.
        end.
      end.
      delete object vsdsTHObj .
      delete object vsdStorage .
      delete object mercury no-error .
    end.
    run write-to-log( "Закончена работа с БД " + string(v-db-num) ) .
    pause 0.2 .
  end.
  delete object objThObj no-error .
  delete object vsdStsType no-error .
end.
