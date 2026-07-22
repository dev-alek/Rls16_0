block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.cash-desk OLD oldb.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись cash-desk".
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
      p-vss-parameters = substitute('&1|&2|&3|&4',  ub.cash-desk.db-num
                                        , ub.cash-desk.obj-code
                                        , ub.cash-desk.pos-type
                                        , ub.cash-desk.cash-num
                                          )
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
define variable v-date as date    no-undo .
define variable v-time as integer no-undo .
define buffer buf_cash-desk      for ub.cash-desk.
define buffer buf_cash-desk-attr for ub.cash-desk-attr.
define buffer buf_c-cash-desk    for ub.c-cash-desk.
define buffer buf_shop           for ub.shop.
main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
    if not g#news and ub.cash-desk.db-num <> g#db-num then
    do:
        message
            "Нельзя изменять запись о кассе," skip
            "принадлежащей другой БД"
            view-as alert-box .
        undo main-block, return error.
    end.
    find first buf_shop no-lock where
        buf_shop.obj-code = ub.cash-desk.obj-code no-error .
    if not avail buf_shop then
    do:
        message
            "Не найден магазин" ub.cash-desk.obj-code  "для кассы" skip
            "БД" ub.cash-desk.db-num
            "маг" ub.cash-desk.obj-code
            "тип" ub.cash-desk.pos-type
            "N кассы" ub.cash-desk.cash-num
            view-as alert-box .
        undo main-block, return error.
    end.
    if (buf_shop.is-kitchen
        or buf_shop.is-kitchen-store)
        and not buf_shop.is-catering
        then
    do:
        message
            "Нельзя создавать/изменять запись кассы для магазина, который имеет признаки КУХНЯ и/или СКЛАД КУХНИ" skip
            "и не является РЕСТОРАНОМ"
            "БД" ub.cash-desk.db-num
            "маг" ub.cash-desk.obj-code
            "тип" ub.cash-desk.pos-type
            "N кассы" ub.cash-desk.cash-num
            view-as alert-box .
        undo main-block, return error.
    end.
    FIND FIRST ub.wth-place NO-LOCK where
        ub.wth-place.obj-code = oldb.obj-code AND
        ub.wth-place.obj-type = 'маг':U AND
        ub.wth-place.cash-desk = oldb.cash-num NO-ERROR.
    IF AVAIL ub.wth-place and
        NOT (oldb.obj-code = ub.cash-desk.obj-code) then
    do:
        message "Данная касса привязана к МХ МЦ!" skip
            "изменение невозможно!" view-as alert-box ERROR.
        undo main-block, return error.
    end.
    find first buf_cash-desk No-LOCK WHERE
        buf_cash-desk.obj-code = ub.cash-desk.obj-code AND
        buf_cash-desk.pos-type = ub.cash-desk.pos-type AND
        buf_cash-desk.cash-num = ub.cash-desk.cash-num no-error .
    if available buf_cash-desk and
        recid(ub.cash-desk) <> recid(Buf_cash-desk) then
    do:
        message
            "В магазине" ub.cash-desk.obj-code "уже есть касса типа" ub.cash-desk.pos-type skip
            "с номером" ub.cash-desk.cash-num
            view-as alert-box error .
        undo main-block, return error .
    end.
    if not g#news then
    do:
        run cur-time in this-procedure(output v-date, output v-time).
        create buf_c-cash-desk.
        buffer-copy oldb to buf_c-cash-desk
            assign
            buf_c-cash-desk.db-num             =  ub.cash-desk.db-num
            buf_c-cash-desk.obj-code           =  ub.cash-desk.obj-code
            buf_c-cash-desk.pos-type           =  ub.cash-desk.pos-type
            buf_c-cash-desk.cash-num           =  ub.cash-desk.cash-num
            buf_c-cash-desk.chip-num           = next-value (s-cash-desk-chip, ub)
            buf_c-cash-desk.corr-time          = v-time
            buf_c-cash-desk.corr-user-db-num   = g#db-num
            buf_c-cash-desk.corr-user-name     = g#userid
            buf_c-cash-desk.corr-date          = v-date
            buf_c-cash-desk.subject            = 'cash-desk':U
            buf_c-cash-desk.action             = integer(if new(ub.cash-desk) then '1':U else '2':U)
            .
    end.
    define variable v-new-cash-desk as logical no-undo .
    assign
        v-new-cash-desk = new(ub.cash-desk)
        .
    if v-new-cash-desk = true then
    do:
        run trg/userlog.p (
            input 'create':U
            , input 'cash-desk':U
            , input ( buffer ub.cash-desk :handle )
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
            , input 'cash-desk':U
            , input ( buffer ub.cash-desk :handle )
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
    run str/callnews.p
        ( input 'cash-desk':U
        ,input (buffer ub.cash-desk:handle)
        ) .
    if g#oxml = yes
        then
    do:
        run str/calloxml.p (
            input 'update':U
            , input 'cash-desk':U
            , input ( buffer ub.cash-desk:handle )
            ) no-error.
        if error-status :error
            then
        do:
            undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                , chr(10)
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.
    end.
end.
