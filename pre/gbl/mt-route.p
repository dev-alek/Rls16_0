using Ibs.Th.Gbl.XmlFilder.
block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mt-route.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/mt-route.p $":U .
define variable vss-description as character no-undo init "Маршрутизатор сообщений радиотерминала ".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure integerm :
  define input  parameter p-string      as character no-undo .
  define input  parameter p-allow-sign  as logical   no-undo .
  define input  parameter p-allow-comma as logical   no-undo .
  define output parameter p-value       as integer   no-undo .
  define output parameter p-data-valid  as logical   no-undo .
  define output parameter p-message     as character no-undo .
  define variable v-replace-string as character no-undo .
  do
  on error undo, return error return-value
  :
    if p-string = ?
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = "Ошибка задания входных параметров. Не задана строка для преобразования"
      .
      return .
    end.
    if p-string = ""
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = "Ошибка задания входных параметров. Задана пустая строка для преобразования"
      .
      return .
    end.
    assign
      p-value = integer(p-string) no-error
    .
    if error-status :error = true
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'"
                                 ,p-string
                                 )
      .
      return .
    end.
    if index(p-string, ' ':u) > 0
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                 + "Строка содержит символы пробела"
                                 ,p-string
                                 )
      .
      return .
    end.
    assign
      v-replace-string = p-string
      v-replace-string = replace(v-replace-string, '0':u, '9':u)
      v-replace-string = replace(v-replace-string, '1':u, '9':u)
      v-replace-string = replace(v-replace-string, '2':u, '9':u)
      v-replace-string = replace(v-replace-string, '3':u, '9':u)
      v-replace-string = replace(v-replace-string, '4':u, '9':u)
      v-replace-string = replace(v-replace-string, '5':u, '9':u)
      v-replace-string = replace(v-replace-string, '6':u, '9':u)
      v-replace-string = replace(v-replace-string, '7':u, '9':u)
      v-replace-string = replace(v-replace-string, '8':u, '9':u)
    .
    if p-allow-sign = true
    then do:
      if index('+-':u, substring(v-replace-string, 1, 1)) > 0
      then do:
        assign
          v-replace-string = substring(v-replace-string, 2)
        .
      end.
    end.
    else do:
      if substring(v-replace-string, 1, 1) = '+':u
      then do:
        assign
          p-value      = ?
          p-data-valid = false
          p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                  + "Задан параметр недопустимости знака челого числа. "
                                  + "Строка содержит символ плюс. "
                                  ,p-string
                                  )
        .
        return .
      end.
      if substring(v-replace-string, 1, 1) = '-':u
      then do:
        assign
          p-value      = ?
          p-data-valid = false
          p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                  + "Задан параметр недопустимости знака челого числа. "
                                  + "Строка содержит символ минус. "
                                  ,p-string
                                  )
        .
        return .
      end.
    end.
    if p-allow-comma = true
    then do:
      assign
        v-replace-string = replace(v-replace-string, ',', '')
      .
    end.
    else do:
      if index(v-replace-string, ',') > 0
      then do:
        assign
          p-value      = ?
          p-data-valid = false
          p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                  + "Задан параметр недопустимости знака разделителя тысяч."
                                  + "Строка содержит знак разделителя тысяч. "
                                  ,p-string
                                  )
        .
        return .
      end.
    end.
    if index(p-string, '.') > 0
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                 + "Строка содержит знак десятичной точки"
                                 ,p-string
                                 )
      .
      return .
    end.
    if v-replace-string <> fill('9', length(v-replace-string))
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                 + "Встречены символы, недопустимые для целого числа '&2'"
                                 ,p-string
                                 ,replace(v-replace-string, '9', '')
                                 )
      .
      return .
    end.
    assign
      p-data-valid = true
      p-message    = ""
    .
  end.
end procedure.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define temp-table tt-session no-undo
  field session-id        as character
  field last-update-date  as date
  field last-update-time  as integer
index pi is primary unique
  session-id
.
define buffer buf_tt-session for tt-session.
define variable v-xml-filder  as class XmlFilder  no-undo .
define variable v-data-valid        as logical   no-undo .
define variable v-err-message       as character no-undo .
define variable v-device-id         as character no-undo .
define variable v-mt-route_session-timeout  as integer   no-undo .
define variable v-mt-route_user-num         as integer   no-undo .
define variable v-mt-route_pos-code         as integer   no-undo .
define variable v-mt-route_parenthandle     as handle    no-undo .
procedure mt-route_init :
  define input  parameter parparentproc     as handle    no-undo .
  define input  parameter p-pos-code        as integer   no-undo .
  define input  parameter p-user-num        as integer   no-undo .
  define input  parameter p-session-timeout as integer   no-undo .
do
on error undo, return error return-value
:
  assign
    v-mt-route_pos-code         = p-pos-code
    v-mt-route_user-num         = p-user-num
    v-mt-route_session-timeout  = p-session-timeout
    v-mt-route_parenthandle     = parparentproc
  .
end.
end procedure.
procedure mt-route_init-session :
  define input  parameter p-session-id  as character no-undo .
  define output parameter p-registred   as logical   no-undo .
  define output parameter p-message     as character no-undo .
do
on error undo, return error return-value
:
  define variable v-session-num     as integer   no-undo .
  define variable v-session-valid   as logical   no-undo .
  define variable v-message         as character no-undo .
  run mt-route_check-session in this-procedure ( input p-session-id
                                               , input no
                                               , output v-session-valid
                                               , output v-message
                                               ) .
  if v-session-valid = yes
  then do:
    assign
      p-registred = yes
    .
    return .
  end.
  for each buf_tt-session:
    assign
      v-session-num = v-session-num + 1
    .
  end.
  if v-session-num < v-mt-route_user-num
  then do:
    find first buf_tt-session
      where buf_tt-session.session-id = p-session-id
    no-error .
    if not available buf_tt-session
    then do:
      define variable v-date as date      no-undo .
      define variable v-time as integer   no-undo .
      run cur-time in this-procedure ( output v-date
                                     , output v-time
                                     ) .
      create buf_tt-session.
      assign
        buf_tt-session.session-id       = p-session-id
        buf_tt-session.last-update-date = v-date
        buf_tt-session.last-update-time = v-time
        v-session-num                   = v-session-num + 1
        p-registred                     = yes
      .
      run mt-serv_write-user-num  in v-mt-route_parenthandle ( input v-session-num ) .
    end.
  end.
  else do:
    assign
      p-message = substitute( "Превышено максимальное число пользователей. Сейчас в системе: &1 ."
                            , v-session-num
                            )
    .
  end.
end.
end procedure.
procedure mt-route_delete-session :
  define input  parameter p-session-id as character no-undo .
do
on error undo, return error return-value
:
  define variable v-session-num as integer   no-undo .
  find first buf_tt-session
    where buf_tt-session.session-id = p-session-id
  no-error .
  if available buf_tt-session
  then do:
    delete buf_tt-session .
    for each buf_tt-session:
      assign
        v-session-num = v-session-num + 1
      .
    end.
    run mt-serv_write-user-num in v-mt-route_parenthandle ( input v-session-num ) .
  end.
end.
end procedure.
procedure mt-route_check-session :
  define input  parameter p-session-id      as character no-undo .
  define input  parameter p-update-session  as logical   no-undo .
  define output parameter p-session-valid   as logical   no-undo .
  define output parameter p-message         as character no-undo .
do
on error undo, return error return-value
:
  define variable v-date    as date      no-undo .
  define variable v-time    as integer   no-undo .
  define variable v-timeout as integer   no-undo .
  find first buf_tt-session
    where buf_tt-session.session-id = p-session-id
  no-error .
  if not available buf_tt-session
  then do:
    assign
      p-session-valid = false
      p-message      = substitute(" Не найдена сессия &1" , p-session-id)
    .
    return .
  end.
  run cur-time in this-procedure ( output v-date
                                 , output v-time
                                 ) .
  if buf_tt-session.last-update-date > v-date
  then do:
    assign
      p-session-valid = false
      p-message      = substitute("Календарная дата открытия сесии &1 отличается." , p-session-id)
    .
    return .
  end.
  assign
    v-timeout = v-time - buf_tt-session.last-update-time
  .
  if v-timeout > v-mt-route_session-timeout
  then do:
    assign
      p-session-valid = false
      p-message      = substitute( "Превышен таймаут сессии &1.&2Таймаут: &3"
                                  , p-session-id
                                  , chr(10)
                                  , string(v-timeout, "hh:mm:ss")
                                  )
    .
    run mt-route_delete-session in this-procedure (input p-session-id) .
    return .
  end.
  if p-update-session = yes
  then do:
    assign
      buf_tt-session.last-update-date = v-date
      buf_tt-session.last-update-time = v-time
    .
  end.
  assign
    p-session-valid = true
  .
end.
end procedure.
procedure mt-route_update-session :
  define input  parameter p-session-id    as character no-undo .
do
on error undo, return error return-value
:
  find first buf_tt-session
    where buf_tt-session.session-id = p-session-id
  no-error .
  if available buf_tt-session
  then do:
    define variable v-date as date      no-undo .
    define variable v-time as integer   no-undo .
    run cur-time in this-procedure ( output v-date
                                    , output v-time
                                    ) .
    assign
      buf_tt-session.last-update-date = v-date
      buf_tt-session.last-update-time = v-time
    .
  end.
end.
end procedure.
procedure mt-route_process-request :
  define input  parameter parparentproc   as handle    no-undo .
  define input  parameter p-req-num       as integer   no-undo .
  define input  parameter p-message-str   as character no-undo .
  define output parameter p-send-message  as character no-undo .
do
on error undo, return error return-value
:
  v-xml-filder = new XmlFilder() .
  run mt-route_init-route in this-procedure ( input   parparentproc
                                            , input   p-req-num
                                            , input   p-message-str
                                            , output  p-send-message
                                            ).
  delete object v-xml-filder.
  assign
    v-xml-filder = ?
    p-send-message = codepage-convert( p-send-message , "UTF-8" )
  .
end.
end procedure.
procedure mt-route_init-route :
  define input  parameter parparentproc   as handle    no-undo .
  define input  parameter p-req-num       as integer   no-undo .
  define input  parameter p-message-str   as character no-undo .
  define output parameter p-send-message  as character no-undo .
do
on error undo, return error return-value
:
  define variable v-msg-str as character no-undo .
  assign
    v-msg-str =  p-message-str
  .
  case p-req-num:
    when 1
    then do:
      define variable v-user-login-1        as character no-undo .
      define variable v-user-password-1     as character no-undo .
      define variable v-obj-type-1          as character no-undo .
      define variable v-obj-code-1          as integer   no-undo .
      run parse-req-1 in this-procedure ( input  v-msg-str
                                        , output v-data-valid
                                        , output v-err-message
                                        , output v-device-id
                                        , output v-user-login-1
                                        , output v-obj-type-1
                                        , output v-obj-code-1
                                        ).
      if v-data-valid <> yes then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input substitute( 'Ошибка при разборе сообщения &1 : &2'                                                                      , p-req-num                                                                      , v-err-message                                                                      )                                                    , output p-send-message                                                    ) .   return.  end.
            define variable v-session-valid2   as logical   no-undo . define variable v-session-message2 as character no-undo . run mt-route_check-session in this-procedure ( input  v-device-id                                              , input yes                                              , output v-session-valid2                                              , output v-session-message2                                              ) no-error . if error-status :error then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input "Ошибка при  вызове процедуры mt-route_check-session."                                                              , output p-send-message                                                              ) .   return .  end. if v-session-valid2 <> true then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input  v-session-message2                                                              , output p-send-message                                                              ) .   return .  end.
      run gbl/mtreq001.p ( input  parparentproc
                         , input  v-device-id
                         , input  v-user-login-1
                         , input  v-obj-type-1
                         , input  v-obj-code-1
                         , output p-send-message
                         ).
    end.
    when 2
    then do:
      define variable v-user-login-2        as character no-undo .
      define variable v-user-password-2     as character no-undo .
      define variable v-obj-type-2          as character no-undo .
      define variable v-obj-code-2          as integer   no-undo .
      run parse-req-2 in this-procedure ( input  v-msg-str
                                        , output v-data-valid
                                        , output v-err-message
                                        , output v-device-id
                                        , output v-user-login-2
                                        , output v-obj-type-2
                                        , output v-obj-code-2
                                        ).
      if v-data-valid <> yes then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input substitute( 'Ошибка при разборе сообщения &1 : &2'                                                                      , p-req-num                                                                      , v-err-message                                                                      )                                                    , output p-send-message                                                    ) .   return.  end.
            define variable v-session-valid3   as logical   no-undo . define variable v-session-message3 as character no-undo . run mt-route_check-session in this-procedure ( input  v-device-id                                              , input yes                                              , output v-session-valid3                                              , output v-session-message3                                              ) no-error . if error-status :error then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input "Ошибка при  вызове процедуры mt-route_check-session."                                                              , output p-send-message                                                              ) .   return .  end. if v-session-valid3 <> true then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input  v-session-message3                                                              , output p-send-message                                                              ) .   return .  end.
      run gbl/mtreq002.p ( input  parparentproc
                         , input  v-device-id
                         , input  v-user-login-2
                         , input  v-obj-type-2
                         , input  v-obj-code-2
                         , input  v-mt-route_pos-code
                         , output p-send-message
                         ).
    end.
    when 3
    then do:
      define variable v-3-doc-code       as character no-undo .
      define variable v-3-line-num       as integer   no-undo .
      define variable v-3-mode           as character no-undo .
      define variable v-3-src-code       as character no-undo .
      define variable v-3-src-qnty       as decimal   no-undo .
      define variable v-3-pump           as integer   no-undo .
      define variable v-3-nozzle-code    as integer   no-undo .
      define variable v-3-pl-code        as integer   no-undo .
      define variable v-3-write-off-code as integer   no-undo .
      define variable v-3-pass-gds       as integer   no-undo .
      define variable v-3-fbr-depart     as integer   no-undo .
      define variable v-3-user-login     as character no-undo .
      define variable v-3-user-password  as character no-undo .
      define variable v-3-obj-type       as character no-undo .
      define variable v-3-obj-code       as integer   no-undo .
      run parse-req-3 in this-procedure ( input  v-msg-str
                                        , output v-data-valid
                                        , output v-err-message
                                        , output v-device-id
                                        , output v-3-user-login
                                        , output v-3-obj-type
                                        , output v-3-obj-code
                                        , output v-3-doc-code
                                        , output v-3-line-num
                                        , output v-3-mode
                                        , output v-3-src-code
                                        , output v-3-src-qnty
                                        , output v-3-pump
                                        , output v-3-nozzle-code
                                        , output v-3-pl-code
                                        , output v-3-write-off-code
                                        , output v-3-pass-gds
                                        , output v-3-fbr-depart
                                        ) .
      if v-data-valid <> yes then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input substitute( 'Ошибка при разборе сообщения &1 : &2'                                                                      , p-req-num                                                                      , v-err-message                                                                      )                                                    , output p-send-message                                                    ) .   return.  end.
            define variable v-session-valid4   as logical   no-undo . define variable v-session-message4 as character no-undo . run mt-route_check-session in this-procedure ( input  v-device-id                                              , input yes                                              , output v-session-valid4                                              , output v-session-message4                                              ) no-error . if error-status :error then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input "Ошибка при  вызове процедуры mt-route_check-session."                                                              , output p-send-message                                                              ) .   return .  end. if v-session-valid4 <> true then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input  v-session-message4                                                              , output p-send-message                                                              ) .   return .  end.
      run gbl/mtreq003.p ( input  parparentproc
                         , input  v-device-id
                         , input  v-3-user-login
                         , input  v-3-obj-type
                         , input  v-3-obj-code
                         , input  v-3-doc-code
                         , input  v-3-line-num
                         , input  v-3-mode
                         , input  v-3-src-code
                         , input  v-3-src-qnty
                         , input  v-3-pump
                         , input  v-3-nozzle-code
                         , input  v-3-pl-code
                         , input  v-3-write-off-code
                         , input  v-3-pass-gds
                         , input  v-3-fbr-depart
                         , output p-send-message
                         ) .
    end.
    when 4
    then do :
      define variable v-doc-code-4       as character no-undo .
      run parse-req-4 in this-procedure ( input  v-msg-str
                                        , output v-data-valid
                                        , output v-err-message
                                        , output v-device-id
                                        , output v-doc-code-4
                                        ) .
      if v-data-valid <> yes then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input substitute( 'Ошибка при разборе сообщения &1 : &2'                                                                      , p-req-num                                                                      , v-err-message                                                                      )                                                    , output p-send-message                                                    ) .   return.  end.
            define variable v-session-valid5   as logical   no-undo . define variable v-session-message5 as character no-undo . run mt-route_check-session in this-procedure ( input  v-device-id                                              , input yes                                              , output v-session-valid5                                              , output v-session-message5                                              ) no-error . if error-status :error then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input "Ошибка при  вызове процедуры mt-route_check-session."                                                              , output p-send-message                                                              ) .   return .  end. if v-session-valid5 <> true then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input  v-session-message5                                                              , output p-send-message                                                              ) .   return .  end.
      run gbl/mtreq004.p ( input  parparentproc
                         , input  v-device-id
                         , input  v-doc-code-4
                         , output p-send-message
                         ) .
    end.
    when 5
    then do :
      define variable v-5-doc-code       as character no-undo .
      run parse-req-5 in this-procedure ( input  v-msg-str
                                        , output v-data-valid
                                        , output v-err-message
                                        , output v-device-id
                                        , output v-5-doc-code
                                        ) .
      if v-data-valid <> yes then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input substitute( 'Ошибка при разборе сообщения &1 : &2'                                                                      , p-req-num                                                                      , v-err-message                                                                      )                                                    , output p-send-message                                                    ) .   return.  end.
            define variable v-session-valid6   as logical   no-undo . define variable v-session-message6 as character no-undo . run mt-route_check-session in this-procedure ( input  v-device-id                                              , input yes                                              , output v-session-valid6                                              , output v-session-message6                                              ) no-error . if error-status :error then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input "Ошибка при  вызове процедуры mt-route_check-session."                                                              , output p-send-message                                                              ) .   return .  end. if v-session-valid6 <> true then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input  v-session-message6                                                              , output p-send-message                                                              ) .   return .  end.
      run gbl/mtreq005.p ( input  parparentproc
                         , input  v-device-id
                         , input  v-5-doc-code
                         , output p-send-message
                         ) .
    end.
    when 6
    then do :
      define variable v-doc-code-6       as character no-undo .
      define variable v-line-num-6       as integer   no-undo .
      define variable v-mode-6           as character no-undo .
      define variable v-src-code-6       as character no-undo .
      define variable v-src-qnty-6       as decimal   no-undo .
      define variable v-pump-6           as integer   no-undo .
      define variable v-nozzle-code-6    as integer   no-undo .
      define variable v-pl-code-6        as integer   no-undo .
      define variable v-write-off-code-6 as integer   no-undo .
      define variable v-pass-gds-6       as integer   no-undo .
      define variable v-fbr-depart-6     as integer   no-undo .
      define variable v-user-login-6     as character no-undo .
      define variable v-user-password-6  as character no-undo .
      define variable v-obj-type-6       as character no-undo .
      define variable v-obj-code-6       as integer   no-undo .
      run parse-req-6 in this-procedure ( input  v-msg-str
                                        , output v-data-valid
                                        , output v-err-message
                                        , output v-device-id
                                        , output v-user-login-6
                                        , output v-obj-type-6
                                        , output v-obj-code-6
                                        , output v-doc-code-6
                                        , output v-line-num-6
                                        , output v-mode-6
                                        , output v-src-code-6
                                        , output v-src-qnty-6
                                        , output v-pump-6
                                        , output v-nozzle-code-6
                                        , output v-pl-code-6
                                        , output v-write-off-code-6
                                        , output v-pass-gds-6
                                        , output v-fbr-depart-6
                                        ) .
      if v-data-valid <> yes then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input substitute( 'Ошибка при разборе сообщения &1 : &2'                                                                      , p-req-num                                                                      , v-err-message                                                                      )                                                    , output p-send-message                                                    ) .   return.  end.
            define variable v-session-valid7   as logical   no-undo . define variable v-session-message7 as character no-undo . run mt-route_check-session in this-procedure ( input  v-device-id                                              , input yes                                              , output v-session-valid7                                              , output v-session-message7                                              ) no-error . if error-status :error then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input "Ошибка при  вызове процедуры mt-route_check-session."                                                              , output p-send-message                                                              ) .   return .  end. if v-session-valid7 <> true then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input  v-session-message7                                                              , output p-send-message                                                              ) .   return .  end.
      run gbl/mtreq006.p ( input  parparentproc
                         , input  v-device-id
                         , input  v-user-login-6
                         , input  v-obj-type-6
                         , input  v-obj-code-6
                         , input  v-doc-code-6
                         , input  v-line-num-6
                         , input  v-mode-6
                         , input  v-src-code-6
                         , input  v-src-qnty-6
                         , input  v-pump-6
                         , input  v-nozzle-code-6
                         , input  v-pl-code-6
                         , input  v-write-off-code-6
                         , input  v-pass-gds-6
                         , input  v-fbr-depart-6
                         , output p-send-message
                         ) .
    end.
    when 7
    then do :
      define variable v-doc-code-7       as character no-undo .
      define variable v-line-num-7       as integer   no-undo .
      define variable v-mode-7           as character no-undo .
      define variable v-src-code-7       as character no-undo .
      define variable v-src-qnty-7       as decimal   no-undo .
      define variable v-pump-7           as integer   no-undo .
      define variable v-nozzle-code-7    as integer   no-undo .
      define variable v-pl-code-7        as integer   no-undo .
      define variable v-write-off-code-7 as integer   no-undo .
      define variable v-pass-gds-7       as integer   no-undo .
      define variable v-fbr-depart-7     as integer   no-undo .
      define variable v-user-login-7     as character no-undo .
      define variable v-user-password-7  as character no-undo .
      define variable v-obj-type-7       as character no-undo .
      define variable v-obj-code-7       as integer   no-undo .
      run parse-req-7 in this-procedure ( input  v-msg-str
                                        , output v-data-valid
                                        , output v-err-message
                                        , output v-device-id
                                        , output v-user-login-7
                                        , output v-obj-type-7
                                        , output v-obj-code-7
                                        , output v-doc-code-7
                                        , output v-line-num-7
                                        , output v-mode-7
                                        , output v-src-code-7
                                        , output v-src-qnty-7
                                        , output v-pump-7
                                        , output v-nozzle-code-7
                                        , output v-pl-code-7
                                        , output v-write-off-code-7
                                        , output v-pass-gds-7
                                        , output v-fbr-depart-7
                                        ) .
      if v-data-valid <> yes then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input substitute( 'Ошибка при разборе сообщения &1 : &2'                                                                      , p-req-num                                                                      , v-err-message                                                                      )                                                    , output p-send-message                                                    ) .   return.  end.
            define variable v-session-valid8   as logical   no-undo . define variable v-session-message8 as character no-undo . run mt-route_check-session in this-procedure ( input  v-device-id                                              , input yes                                              , output v-session-valid8                                              , output v-session-message8                                              ) no-error . if error-status :error then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input "Ошибка при  вызове процедуры mt-route_check-session."                                                              , output p-send-message                                                              ) .   return .  end. if v-session-valid8 <> true then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input  v-session-message8                                                              , output p-send-message                                                              ) .   return .  end.
      run gbl/mtreq007.p ( input  parparentproc
                         , input  v-device-id
                         , input  v-user-login-7
                         , input  v-obj-type-7
                         , input  v-obj-code-7
                         , input  v-doc-code-7
                         , input  v-line-num-7
                         , input  v-mode-7
                         , input  v-src-code-7
                         , input  v-src-qnty-7
                         , input  v-pump-7
                         , input  v-nozzle-code-7
                         , input  v-pl-code-7
                         , input  v-write-off-code-7
                         , input  v-pass-gds-7
                         , input  v-fbr-depart-7
                         , output p-send-message
                         ) .
    end.
    when 12
    then do:
      define variable v-user-login-12        as character no-undo .
      define variable v-user-password-12     as character no-undo .
      define variable v-obj-type-12          as character no-undo .
      define variable v-obj-code-12          as integer   no-undo .
      define variable v-logged-in            as logical   no-undo .
      run parse-req-12 in this-procedure ( input v-msg-str
                                         , output v-data-valid
                                         , output v-err-message
                                         , output v-device-id
                                         , output v-user-login-12
                                         , output v-user-password-12
                                         ).
      if v-data-valid <> yes then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input substitute( 'Ошибка при разборе сообщения &1 : &2'                                                                      , p-req-num                                                                      , v-err-message                                                                      )                                                    , output p-send-message                                                    ) .   return.  end.
      run gbl/mtreq012.p ( input  parparentproc
                         , input  v-device-id
                         , input  v-user-login-12
                         , input  v-user-password-12
                         , output v-logged-in
                         , output p-send-message
                         ).
      if v-logged-in
      then do:
        define variable v-registred   as logical   no-undo .
        define variable v-reg-message as character no-undo .
        run mt-route_init-session in this-procedure ( input  v-device-id
                                                    , output v-registred
                                                    , output v-reg-message
                                                    ).
        if v-registred <> true
        then do:
          run mt-serv_write-error-message in v-mt-route_parenthandle ( input  v-reg-message
                                                                     , output p-send-message
                                                                     ) .
        end.
      end.
    end.
    when 13
    then do:
      run parse-req-13 in this-procedure ( input v-msg-str
                                         , output v-data-valid
                                         , output v-err-message
                                         , output v-device-id
                                         ).
      if v-data-valid <> yes then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input substitute( 'Ошибка при разборе сообщения &1 : &2'                                                                      , p-req-num                                                                      , v-err-message                                                                      )                                                    , output p-send-message                                                    ) .   return.  end.
            define variable v-session-valid9   as logical   no-undo . define variable v-session-message9 as character no-undo . run mt-route_check-session in this-procedure ( input  v-device-id                                              , input yes                                              , output v-session-valid9                                              , output v-session-message9                                              ) no-error . if error-status :error then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input "Ошибка при  вызове процедуры mt-route_check-session."                                                              , output p-send-message                                                              ) .   return .  end. if v-session-valid9 <> true then do:   run mt-serv_write-error-message in v-mt-route_parenthandle ( input  v-session-message9                                                              , output p-send-message                                                              ) .   return .  end.
      run mt-route_delete-session in this-procedure ( input v-device-id ) .
      return.
    end.
    otherwise do:
      run mt-serv_write-error-message in parparentproc ( input substitute( 'Неизвестный номер запроса &1', p-req-num )
                                                       , output p-send-message
                                                       ) .
    end.
  end case.
end.
end procedure.
procedure parse-req-1 :
  define input  parameter p-mesasge-str       as character no-undo .
  define output parameter p-message-valid     as logical   no-undo .
  define output parameter p-message-error-str as character no-undo .
  define output parameter p-device-id         as character no-undo .
  define output parameter p-user-login        as character no-undo .
  define output parameter p-obj-type          as character no-undo .
  define output parameter p-obj-code          as integer   no-undo .
  define variable v-log         as logical          no-undo .
  define variable v-user-login  as character        no-undo .
  define variable v-object-type as character        no-undo .
  define variable v-object-code as character        no-undo .
do
on error undo, return error return-value
:
  v-xml-filder :set-tag-list( "deviceid,user,objt,objc") .
  v-log = v-xml-filder :parse(p-mesasge-str) .
  if v-log <> yes then do:
    assign
      p-message-error-str = v-xml-filder :error-message
    .
  end.
  else do:
    assign
      p-message-valid = yes
    .
    P-user-login  = v-xml-filder :get-tag( "user" , v-log ) .
    P-obj-type    = v-xml-filder :get-tag( "objt" , v-log ) .
    v-object-code = v-xml-filder :get-tag( "objc" , v-log ) .
    p-device-id   = v-xml-filder :get-tag( "deviceid" , v-log ) .
    define variable v-obj-code      as integer   no-undo .
    define variable v-data-valid    as logical   no-undo .
    define variable v-error-message as character no-undo .
    if v-object-code = ""
    then do:
      assign
        p-message-valid     = false
        p-message-error-str = "Не задан код объекта"
      .
      return .
    end.
    run integerm in this-procedure
      (input  v-object-code
      ,input  false
      ,input  false
      ,output P-obj-code
      ,output v-data-valid
      ,output v-error-message
      ) .
    if v-data-valid <> true
    then do:
      assign
        p-message-valid     = false
        p-message-error-str = substitute( "Ошибка преобразования кода объекта &1. &2"
                                        , v-object-code
                                        , v-error-message
                                        )
      .
      return .
    end.
  end.
end.
end procedure.
procedure parse-req-2 :
  define input  parameter p-mesasge-str       as character no-undo .
  define output parameter p-message-valid     as logical   no-undo .
  define output parameter p-message-error-str as character no-undo .
  define output parameter p-device-id         as character no-undo .
  define output parameter p-user-login        as character no-undo .
  define output parameter p-obj-type          as character no-undo .
  define output parameter p-obj-code          as integer   no-undo .
  define variable v-log         as logical          no-undo .
  define variable v-user-login  as character        no-undo .
  define variable v-object-type as character        no-undo .
  define variable v-object-code as character        no-undo .
do
on error undo, return error return-value
:
  v-xml-filder :set-tag-list( "deviceid,user,objt,objc") .
  v-log = v-xml-filder :parse(p-mesasge-str) .
  if v-log <> yes then do:
    assign
      p-message-error-str = v-xml-filder :error-message
    .
  end.
  else do:
    assign
      p-message-valid = yes
    .
    p-device-id   = v-xml-filder :get-tag( "deviceid" , v-log ) .
    P-user-login  = v-xml-filder :get-tag( "user" , v-log ) .
    P-obj-type    = v-xml-filder :get-tag( "objt" , v-log ) .
    v-object-code = v-xml-filder :get-tag( "objc" , v-log ) .
    define variable v-obj-code      as integer   no-undo .
    define variable v-data-valid    as logical   no-undo .
    define variable v-error-message as character no-undo .
    if v-object-code = ""
    then do:
      assign
        p-message-valid     = false
        p-message-error-str = "Не задан код объекта"
      .
      return .
    end.
    run integerm in this-procedure
      (input  v-object-code
      ,input  false
      ,input  false
      ,output p-obj-code
      ,output v-data-valid
      ,output v-error-message
      ) .
    if v-data-valid <> true
    then do:
      assign
        p-message-valid     = false
        p-message-error-str = substitute( "Ошибка преобразования кода объекта &1. &2"
                                        , v-object-code
                                        , v-error-message
                                        )
      .
      return .
    end.
  end.
end.
end procedure.
procedure parse-req-3 :
  define input  parameter p-msg-str         as character no-undo .
  define output parameter p-data-valid      as logical   no-undo .
  define output parameter p-err-message     as character no-undo .
  define output parameter p-device-id       as character no-undo .
  define output parameter p-user-login      as character no-undo .
  define output parameter p-obj-type        as character no-undo .
  define output parameter p-obj-code        as integer   no-undo .
  define output parameter p-doc-code        as character no-undo .
  define output parameter p-line-num        as integer   no-undo .
  define output parameter p-mode            as character no-undo .
  define output parameter p-src-code        as character no-undo .
  define output parameter p-src-qnty        as decimal   no-undo .
  define output parameter p-pump            as integer   no-undo .
  define output parameter p-nozzle-code     as integer   no-undo .
  define output parameter p-pl-code         as integer   no-undo .
  define output parameter p-write-off-code  as integer   no-undo .
  define output parameter p-pass-gds        as integer   no-undo .
  define output parameter p-fbr-depart      as integer   no-undo .
  define variable v-device-id       as character no-undo .
  define variable v-user-login      as character no-undo .
  define variable v-obj-type        as character no-undo .
  define variable v-obj-code        as character no-undo .
  define variable v-doc-code        as character no-undo .
  define variable v-line-num        as character no-undo .
  define variable v-mode            as character no-undo .
  define variable v-src-code        as character no-undo .
  define variable v-src-qnty        as character no-undo .
  define variable v-pump            as character no-undo .
  define variable v-nozzle-code     as character no-undo .
  define variable v-pl-code         as character no-undo .
  define variable v-write-off-code  as character no-undo .
  define variable v-pass-gds        as character no-undo .
  define variable v-fbr-depart      as character no-undo .
  define variable v-log             as logical   no-undo .
  define variable v-data-valid      as logical   no-undo .
  define variable v-error-message   as character no-undo .
do
on error undo, return error return-value
:
  v-xml-filder :set-tag-list( "deviceid,user,objt,objc,doccode,mode,barcode,gdslinenum,srcqnty,pump,nozzlecode,plcode,passgds,fbrdepart,writeoffcode") .
  v-log = v-xml-filder :parse(p-msg-str) .
  if v-log <> yes then do:
    assign
      p-err-message = v-xml-filder :error-message
    .
    return .
  end.
  p-device-id      = v-xml-filder :get-tag( "deviceid" , v-log ) .
  p-user-login     = v-xml-filder :get-tag( "user" , v-log ) .
  p-obj-type       = v-xml-filder :get-tag( "objt" , v-log ) .
  v-obj-code       = v-xml-filder :get-tag( "objc" , v-log ) .
  p-doc-code       = v-xml-filder :get-tag( "doccode" , v-log ) .
  v-line-num       = v-xml-filder :get-tag( "gdslinenum" , v-log ) .
  v-mode           = v-xml-filder :get-tag( "mode" , v-log ) .
  p-src-code       = v-xml-filder :get-tag( "barcode" , v-log ) .
  v-src-qnty       = v-xml-filder :get-tag( "srcqnty" , v-log ) .
  v-pump           = v-xml-filder :get-tag( "pump" , v-log ) .
  v-nozzle-code    = v-xml-filder :get-tag( "nozzlecode" , v-log ) .
  v-pl-code        = v-xml-filder :get-tag( "plcode" , v-log ) .
  v-write-off-code = v-xml-filder :get-tag( "writeoffcode" , v-log ) .
  v-pass-gds       = v-xml-filder :get-tag( "passgds" , v-log ) .
  v-fbr-depart     = v-xml-filder :get-tag( "fbrdepart" , v-log ) .
  if v-obj-code = ""
  then do:
    assign
      p-data-valid        = no
      p-err-message = "Не задан код объекта"
    .
    return .
  end.
  run integerm in this-procedure
    (input  v-obj-code
    ,input  false
    ,input  false
    ,output p-obj-code
    ,output v-data-valid
    ,output v-error-message
    ) .
  if v-data-valid <> true
  then do:
    assign
      p-data-valid        = no
      p-err-message = substitute( "Ошибка преобразования кода объекта &1. &2"
                                      , v-obj-code
                                      , v-error-message
                                      )
    .
    return .
  end.
  if v-line-num = ""
  then do:
    assign
      p-data-valid  = no
      p-err-message = "Не задана строка чека"
    .
    return .
  end.
  run integerm in this-procedure
    (input  v-line-num
    ,input  false
    ,input  false
    ,output p-line-num
    ,output v-data-valid
    ,output v-error-message
    ) .
  if v-data-valid <> true
  then do:
    assign
      p-data-valid        = no
      p-err-message = substitute( "Ошибка преобразования номера строки чека &1. &2"
                                      , v-line-num
                                      , v-error-message
                                      )
    .
    return .
  end.
  case caps(v-mode) :
    when 'A'
    then do:
      assign
        p-mode = 'ДОБАВЛЕНИЕ':U
      .
    end.
    when 'D'
    then do:
      assign
        p-mode = 'удаление':U
      .
    end.
    when 'U'
    then do:
      assign
        p-mode = 'ИЗМЕНЕНИЕ':U
      .
    end.
    otherwise do:
      assign
        p-data-valid  = no
        p-err-message = substitute( "Неверный режим работы с чеком : &1"
                                  , v-mode
                                  )
      .
      return .
    end.
  end case.
  if v-src-qnty = ""
  then do:
    assign
      p-data-valid  = no
      p-err-message = "Не задано количество товара"
    .
    return .
  end.
  assign
    p-src-qnty = decimal(v-src-qnty)
  no-error .
  if error-status :error
  then do:
    assign
      p-data-valid  = no
      p-err-message = substitute( "Ошибка преобразования количества &1"
                                , v-src-qnty
                                )
    .
    return .
  end.
  if v-pump = ""
  then do:
    assign
      p-data-valid  = no
      p-err-message = "Не задана перменная v-pump"
    .
    return .
  end.
  run integerm in this-procedure
    (input  v-pump
    ,input  false
    ,input  false
    ,output p-pump
    ,output v-data-valid
    ,output v-error-message
    ) .
  if v-data-valid <> true
  then do:
    assign
      p-data-valid        = no
      p-err-message = substitute( "Ошибка преобразования переменной v-pump &1. &2"
                                      , v-pump
                                      , v-error-message
                                      )
    .
    return .
  end.
  if v-pump = ""
  then do:
    assign
      p-data-valid  = no
      p-err-message = "Не задана перменная v-pump"
    .
    return .
  end.
  run integerm in this-procedure
    (input  v-pump
    ,input  false
    ,input  false
    ,output p-pump
    ,output v-data-valid
    ,output v-error-message
    ) .
  if v-data-valid <> true
  then do:
    assign
      p-data-valid        = no
      p-err-message = substitute( "Ошибка преобразования переменной v-pump &1. &2"
                                      , v-pump
                                      , v-error-message
                                      )
    .
    return .
  end.
  if v-nozzle-code = ""
  then do:
    assign
      p-data-valid  = no
      p-err-message = "Не задана перменная v-nozzle-code"
    .
    return .
  end.
  run integerm in this-procedure
    (input  v-nozzle-code
    ,input  false
    ,input  false
    ,output p-nozzle-code
    ,output v-data-valid
    ,output v-error-message
    ) .
  if v-data-valid <> true
  then do:
    assign
      p-data-valid        = no
      p-err-message = substitute( "Ошибка преобразования переменной v-nozzle-code &1. &2"
                                      , v-nozzle-code
                                      , v-error-message
                                      )
    .
    return .
  end.
  if v-pl-code = ""
  then do:
    assign
      p-data-valid  = no
      p-err-message = "Не задана перменная v-pl-code"
    .
    return .
  end.
  run integerm in this-procedure
    (input  v-pl-code
    ,input  false
    ,input  false
    ,output p-pl-code
    ,output v-data-valid
    ,output v-error-message
    ) .
  if v-data-valid <> true
  then do:
    assign
      p-data-valid        = no
      p-err-message = substitute( "Ошибка преобразования переменной v-pl-code &1. &2"
                                      , v-pl-code
                                      , v-error-message
                                      )
    .
    return .
  end.
  if v-write-off-code = ""
  then do:
    assign
      p-data-valid  = no
      p-err-message = "Не задана перменная v-write-off-code"
    .
    return .
  end.
  run integerm in this-procedure
    (input  v-write-off-code
    ,input  false
    ,input  false
    ,output p-write-off-code
    ,output v-data-valid
    ,output v-error-message
    ) .
  if v-data-valid <> true
  then do:
    assign
      p-data-valid        = no
      p-err-message = substitute( "Ошибка преобразования переменной v-write-off-code &1. &2"
                                      , v-write-off-code
                                      , v-error-message
                                      )
    .
    return .
  end.
  if v-pass-gds = ""
  then do:
    assign
      p-data-valid  = no
      p-err-message = "Не задана перменная v-pass-gds"
    .
    return .
  end.
  run integerm in this-procedure
    (input  v-pass-gds
    ,input  false
    ,input  false
    ,output p-pass-gds
    ,output v-data-valid
    ,output v-error-message
    ) .
  if v-data-valid <> true
  then do:
    assign
      p-data-valid        = no
      p-err-message = substitute( "Ошибка преобразования переменной v-pass-gds &1. &2"
                                      , v-pass-gds
                                      , v-error-message
                                      )
    .
    return .
  end.
  if v-fbr-depart = ""
  then do:
    assign
      p-data-valid  = no
      p-err-message = "Не задана перменная v-fbr-depart"
    .
    return .
  end.
  run integerm in this-procedure
    (input  v-fbr-depart
    ,input  false
    ,input  false
    ,output p-fbr-depart
    ,output v-data-valid
    ,output v-error-message
    ) .
  if v-data-valid <> true
  then do:
    assign
      p-data-valid        = no
      p-err-message = substitute( "Ошибка преобразования переменной v-fbr-depart &1. &2"
                                      , v-fbr-depart
                                      , v-error-message
                                      )
    .
    return .
  end.
  assign
    p-data-valid = yes
  .
end.
end procedure.
procedure parse-req-4 :
  define input  parameter p-msg-str         as character no-undo .
  define output parameter p-data-valid      as logical   no-undo .
  define output parameter p-err-message     as character no-undo .
  define output parameter p-device-id       as character no-undo .
  define output parameter p-doc-code        as character no-undo .
do
on error undo, return error return-value
:
  run parse-req-5 in this-procedure ( input  p-msg-str
                                    , output p-data-valid
                                    , output p-err-message
                                    , output p-device-id
                                    , output p-doc-code
                                    ) .
end.
end procedure.
procedure parse-req-5 :
  define input  parameter p-msg-str         as character no-undo .
  define output parameter p-data-valid      as logical   no-undo .
  define output parameter p-err-message     as character no-undo .
  define output parameter p-device-id       as character no-undo .
  define output parameter p-doc-code        as character no-undo .
  define variable v-device-id       as character no-undo .
  define variable v-doc-code        as character no-undo .
  define variable v-log             as logical   no-undo .
  define variable v-data-valid      as logical   no-undo .
  define variable v-error-message   as character no-undo .
do
on error undo, return error return-value
:
  v-xml-filder :set-tag-list( "deviceid,doccode") .
  v-log = v-xml-filder :parse(p-msg-str) .
  if v-log <> yes then do:
    assign
      p-err-message = v-xml-filder :error-message
    .
    return .
  end.
  p-device-id      = v-xml-filder :get-tag( "deviceid" , v-log ) .
  p-doc-code       = v-xml-filder :get-tag( "doccode" , v-log ) .
  assign
    p-data-valid = yes
  .
end.
end procedure.
procedure parse-req-6 :
  define input  parameter p-msg-str         as character no-undo .
  define output parameter p-data-valid      as logical   no-undo .
  define output parameter p-err-message     as character no-undo .
  define output parameter p-device-id       as character no-undo .
  define output parameter p-user-login      as character no-undo .
  define output parameter p-obj-type        as character no-undo .
  define output parameter p-obj-code        as integer   no-undo .
  define output parameter p-doc-code        as character no-undo .
  define output parameter p-line-num        as integer   no-undo .
  define output parameter p-mode            as character no-undo .
  define output parameter p-src-code        as character no-undo .
  define output parameter p-src-qnty        as decimal   no-undo .
  define output parameter p-pump            as integer   no-undo .
  define output parameter p-nozzle-code     as integer   no-undo .
  define output parameter p-pl-code         as integer   no-undo .
  define output parameter p-write-off-code  as integer   no-undo .
  define output parameter p-pass-gds        as integer   no-undo .
  define output parameter p-fbr-depart      as integer   no-undo .
do
on error undo, return error return-value
:
  run parse-req-3 in this-procedure ( input  p-msg-str
                                    , output p-data-valid
                                    , output p-err-message
                                    , output p-device-id
                                    , output p-user-login
                                    , output p-obj-type
                                    , output p-obj-code
                                    , output p-doc-code
                                    , output p-line-num
                                    , output p-mode
                                    , output p-src-code
                                    , output p-src-qnty
                                    , output p-pump
                                    , output p-nozzle-code
                                    , output p-pl-code
                                    , output p-write-off-code
                                    , output p-pass-gds
                                    , output p-fbr-depart
                                    ) .
end.
end procedure.
procedure parse-req-7 :
  define input  parameter p-msg-str         as character no-undo .
  define output parameter p-data-valid      as logical   no-undo .
  define output parameter p-err-message     as character no-undo .
  define output parameter p-device-id       as character no-undo .
  define output parameter p-user-login      as character no-undo .
  define output parameter p-obj-type        as character no-undo .
  define output parameter p-obj-code        as integer   no-undo .
  define output parameter p-doc-code        as character no-undo .
  define output parameter p-line-num        as integer   no-undo .
  define output parameter p-mode            as character no-undo .
  define output parameter p-src-code        as character no-undo .
  define output parameter p-src-qnty        as decimal   no-undo .
  define output parameter p-pump            as integer   no-undo .
  define output parameter p-nozzle-code     as integer   no-undo .
  define output parameter p-pl-code         as integer   no-undo .
  define output parameter p-write-off-code  as integer   no-undo .
  define output parameter p-pass-gds        as integer   no-undo .
  define output parameter p-fbr-depart      as integer   no-undo .
do
on error undo, return error return-value
:
  run parse-req-3 in this-procedure ( input  p-msg-str
                                    , output p-data-valid
                                    , output p-err-message
                                    , output p-device-id
                                    , output p-user-login
                                    , output p-obj-type
                                    , output p-obj-code
                                    , output p-doc-code
                                    , output p-line-num
                                    , output p-mode
                                    , output p-src-code
                                    , output p-src-qnty
                                    , output p-pump
                                    , output p-nozzle-code
                                    , output p-pl-code
                                    , output p-write-off-code
                                    , output p-pass-gds
                                    , output p-fbr-depart
                                    ) .
end.
end procedure.
procedure parse-req-12 :
  define input  parameter p-mesasge-str       as character no-undo .
  define output parameter p-message-valid     as logical   no-undo .
  define output parameter p-message-error-str as character no-undo .
  define output parameter p-device-id         as character no-undo .
  define output parameter p-user-login        as character no-undo .
  define output parameter p-user-password     as character no-undo .
  define variable v-log         as logical          no-undo .
do
on error undo, return error return-value
:
  v-xml-filder :set-tag-list( "deviceid,user,password") .
  v-log = v-xml-filder :parse(p-mesasge-str) .
  if v-log <> yes then do:
    assign
      p-message-error-str = v-xml-filder :error-message
    .
  end.
  else do:
    assign
      p-message-valid = yes
    .
    p-device-id     = v-xml-filder :get-tag( "deviceid" , v-log ) .
    P-user-login    = v-xml-filder :get-tag( "user" , v-log ) .
    P-user-password = v-xml-filder :get-tag( "password", v-log ) .
  end.
end.
end procedure.
procedure parse-req-13 :
  define input  parameter p-mesasge-str       as character no-undo .
  define output parameter p-message-valid     as logical   no-undo .
  define output parameter p-message-error-str as character no-undo .
  define output parameter p-device-id         as character no-undo .
  define variable v-log         as logical          no-undo .
do
on error undo, return error return-value
:
  v-xml-filder :set-tag-list( "deviceid") .
  v-log = v-xml-filder :parse(p-mesasge-str) .
  if v-log <> yes then do:
    assign
      p-message-error-str = v-xml-filder :error-message
    .
  end.
  else do:
    assign
      p-message-valid = yes
    .
    p-device-id = v-xml-filder :get-tag( "deviceid" , v-log ) .
  end.
end.
end procedure.
