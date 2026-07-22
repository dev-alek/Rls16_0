block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.config old old-config.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись данных настройки и конфигурации системы".
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
Function reverse returns character (str as character).
   define variable rev_incl_s as character init "" no-undo .
   define variable rev_incl_i as integer no-undo .
   define variable rev_incl_l as integer no-undo .
   rev_incl_l = length(str).
   do rev_incl_i = 1 to rev_incl_l:
      rev_incl_s = rev_incl_s + substr(str,rev_incl_l - rev_incl_i + 1,1).
   end.
   return rev_incl_s.
end.
procedure check-enc.
  define input  parameter p-db-num    as integer   no-undo .
  define input  parameter p-db-key    as character no-undo .
  define input  parameter p-code      as character no-undo .
  define input  parameter p-value     as character no-undo .
  define input  parameter p-beg-date  as date      no-undo .
  define input  parameter p-end-date  as date      no-undo .
  define input  parameter p-enc-value as character no-undo .
  define output parameter p-answer    as logical   no-undo .
  define variable tmp         as character no-undo .
  define variable v-enc-value as character no-undo .
  if p-db-num <> 0
    and p-db-key = "":U
  then do:
    assign
      p-answer = true
    .
    return.
  end.
  if p-db-key = "unload-db":U then do:
    assign
      p-answer = true
    .
    return.
  end.
  if p-code = ""  then do:
    assign
      tmp = string( p-db-num ) + reverse (p-db-key).
    .
  end.
  else do:
    assign
      tmp = string( p-db-num )
            + trim( p-db-key )
            + reverse( trim( p-code ) )
            + reverse( trim( p-value ) )
            + reverse( string( p-beg-date, "99.99.9999" ) )
            + reverse( string( p-end-date, "99.99.9999" ) )
    .
  end.
  run pswd-enc in this-procedure
    ( input tmp
     ,output v-enc-value
    ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры pswd-enc" skip
      return-value skip
      error-status :get-message(1) skip
      view-as alert-box error .
    undo, return error .
  end.
  if v-enc-value = p-enc-value then do:
    assign
      p-answer = true
    .
  end.
  else do:
    assign
      p-answer = false
    .
  end.
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure pswd-enc :
  define input parameter  pswd     as character no-undo .
  define output parameter enc-pswd as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      enc-pswd = encode(pswd + string(index(pswd, "k")))
    .
  end.
end procedure.
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
main-block:
do
    on error  undo main-block, return error substitute("&1. error &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    on endkey undo main-block, return error substitute("&1. endkey")
    on stop   undo main-block, return error substitute("&1. stop")
    :
    define variable v-ok              as logical   no-undo .
    define variable v-host-code       as integer   no-undo .
    define variable v-assignment-type as character no-undo .
    define variable v-field-chg       as character no-undo .
    define variable v-date            as date      no-undo .
    define variable v-time            as integer   no-undo .
    define buffer buf_c-config for ub.c-config .
    define buffer buf_sys-ctrl for ub.sys-ctrl .
    if ub.config.param-code = ""
        or ub.config.param-code = ?
        then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Имя параметра должно быть задано" skip
            "param-code" ub.config.param-code skip
            view-as alert-box error .
        undo, return error .
    end.
    if not new ub.config
        and ub.config.param-code <> old-config.param-code
        then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Нельзя изменить имя параметра" skip
            "param-code" ub.config.param-code skip
            view-as alert-box error .
        return error .
    end.
    if length(ub.config.param-code) > 8
        then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Длина имени параметра не может превышать 8 символов" skip
            "param-code" ub.config.param-code skip
            view-as alert-box error .
        undo, return error .
    end.
    if lookup( ub.config.param-type, "C,L,D,I,T") = 0
        then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Неизвестный тип параметра" skip
            "param-code" ub.config.param-code skip
            "param-type" ub.config.param-type skip
            view-as alert-box error .
        undo, return error .
    end.
    if ub.config.host-code <> 0
        then
    do:
        find first ub.sysconf no-lock
            where ub.sysconf.host-code = ub.config.host-code
            no-error .
        if not available ub.sysconf
            then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Задан неправильный код фирмы"    skip
                "param-code" ub.config.param-code skip
                "host-code"  ub.config.host-code  skip
                view-as alert-box error .
            undo, return error .
        end.
    end.
    if ub.config.obj-type <> ""
        or ub.config.obj-code <> 0
        then
    do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  ub.config.obj-type
  ,input  ub.config.obj-code
  ,output v-host-code
  ) no-error .
        if error-status :error
            then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при определении кода фирмы для объекта" skip
                "param-code" ub.config.param-code skip
                "ub.config.obj-type" ub.config.obj-type skip
                "ub.config.obj-code" ub.config.obj-code skip
                view-as alert-box error .
            undo, return error .
        end.
        if ub.config.host-code = 0
            or ub.config.host-code = ?
            then
        do:
            assign
                ub.config.host-code = v-host-code
                .
        end.
        if ub.config.host-code <> v-host-code
            then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Фирма не соответствует объекту"  skip
                "param-code" ub.config.param-code skip
                "host-code"  ub.config.host-code  skip
                "obj-type"   ub.config.obj-type   skip
                "obj-code"   ub.config.obj-code   skip
                view-as alert-box error .
            undo, return error .
        end.
    end.
    assign
        v-assignment-type = ( if  ub.config.host-code = 0  then "0" else "1" )
                        + ( if  ub.config.obj-type  = ""
                            and ub.config.obj-code  = 0
                            then "0" else "1"
                          )
        .
    if lookup( v-assignment-type, '00,10,11':U ) = 0
        then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Неправильная привязка параметра конфигурации" skip
            "param-code" ub.config.param-code skip
            "host-code"  ub.config.host-code  skip
            "obj-type"   ub.config.obj-type   skip
            "obj-code"   ub.config.obj-code   skip
            "привязка"   v-assignment-type    skip
            view-as alert-box error .
        undo, return error .
    end.
    if not new ub.config
        and ub.config.conf-type <> old-config.conf-type
        then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Нельзя изменить тип параметра." skip
            "param-code" ub.config.param-code skip
            view-as alert-box error .
        return error .
    end.
    if not new ub.config
        and ub.config.conf-type = 'к,п':U
        then
    do:
        if ub.config.host-code  <> old-config.host-code
            or ub.config.obj-type   <> old-config.obj-type
            or ub.config.obj-code   <> old-config.obj-code
            then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Параметр кодированный" skip
                "Нельзя изменить привязку кодированного параметра" skip
                "param-code" ub.config.param-code skip
                view-as alert-box error .
            return error .
        end.
    end.
    if lookup( ub.config.conf-type, 'к,п':U ) > 0
        then
    do:
        find first ub.db no-lock
            where ub.db.db-num = ub.config.db-num
            .
        run check-enc in this-procedure
            ( input ub.config.db-num
            ,input ub.db.db-key
            ,input ub.config.param-code
            ,input ub.config.param-value
            ,input ub.config.beg-date
            ,input ub.config.end-date
            ,input ub.config.param-encoded
            ,output v-ok
            ) no-error .
        if error-status :error
            then
        do:
            undo main-block, return error substitute("&1. Ошибка при проверке кодировки параметра &2&3&4&3&5", vss-workfile, ub.config.param-code, chr(10), return-value, error-status :get-message ( 1 ) ).
        end.
        if v-ok <> true
            then
        do:
            undo main-block, return error substitute("&1. Неверное кодированное значение параметра &2", vss-workfile, ub.config.param-code ).
        end.
    end.
    if  ub.config.db-num = g#db-num
        and lookup(ub.config.conf-type, 'к,п':U) > 0
        then
    do:
        run gbl/menu-clr.p
            (input 0
            ) .
        run gbl/actn-clr.p
            (input 0
            ) .
    end.
    if ub.config.beg-date = ?
        or ub.config.end-date = ?
        then
    do:
        undo main-block, return error substitute("&1. Не задана дата начала и/или окончания действия параметра &2", vss-workfile, ub.config.param-code ).
    end.
    buffer-compare ub.config to old-config save result in v-field-chg.
    if v-field-chg <> "stts":U
        then
    do:
        find first buf_sys-ctrl no-lock .
        run cur-time in this-procedure
            ( output v-date
            ,output v-time
            ).
        create buf_c-config.
        if new(ub.config) then
        do:
            assign
                buf_c-config.param-code = ub.config.param-code
                buf_c-config.host-code  = ub.config.host-code
                buf_c-config.obj-type   = ub.config.obj-type
                buf_c-config.obj-code   = ub.config.obj-code
                buf_c-config.beg-date   = ub.config.beg-date
                buf_c-config.end-date   = ub.config.end-date
                buf_c-config.db-num     = ub.config.db-num
                .
        end.
        else
        do:
            buffer-copy old-config to buf_c-config .
        end.
        assign
            buf_c-config.chip-num         = next-value (s-cfg-chip, ub)
            buf_c-config.corr-time        = v-time
            buf_c-config.corr-date        = v-date
            buf_c-config.corr-user-db-num = buf_sys-ctrl.db-num
            buf_c-config.corr-user-name   = (if g#news = true then "СПН" else g#userid )
            buf_c-config.action           = integer(if new(ub.config) then '1':U else '2':U)
            .
        if trim( buf_c-config.corr-user-name ) = "":U then
        do:
            assign
                buf_c-config.corr-user-name = userid( "ub":U )
                .
        end.
    end.
    run str/callnews.p
        (input 'config':U
        ,input (buffer ub.config:handle)
        ) no-error .
    if error-status :error
        then
    do:
        undo main-block, return error substitute("&1. Невозможно маршрутизировать config для отправки в новости &2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message ( 1 ) ).
    end.
    if g#oxml = yes then
    do:
        run str/calloxml.p
            ( input 'update':U
            ,input 'config':U
            ,input ( buffer ub.config:handle )
            ) no-error.
        if error-status :error then
        do:
            undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                , chr(10)
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.
    end.
    if new(ub.config) then
    do:
        run trg/userlog.p (
            input 'create':U
            , input 'config':U
            , input ( buffer ub.config :handle )
            , input ?
            , input ""
            ) no-error.
        if error-status :error
            then
        do:
            undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                , chr(10)
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.
    end.
    else
    do:
        run trg/userlog.p (
            input 'update':U
            , input 'config':U
            , input ( buffer ub.config :handle )
            , input ?
            , input ""
            ) no-error.
        if error-status :error
            then
        do:
            undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                , chr(10)
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.
    end.
end.
