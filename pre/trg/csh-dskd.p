block-level on error undo, throw.
TRIGGER PROCEDURE FOR DELETE OF ub.cash-desk.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление кассы ".
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
define variable v-date    as date      no-undo .
define variable v-time    as integer   no-undo .
define variable v-no-news as logical   no-undo .
define variable v-db-list as character no-undo .
define buffer buf_db             for ub.db.
define buffer buf_c-cash-desk    for ub.c-cash-desk.
define buffer buf_cash-desk-attr for ub.cash-desk-attr.
define buffer buf_inkas-pay-wth  for ub.inkas-pay-wth.
main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1) )
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
    if not g#news and ub.cash-desk.db-num <> g#db-num then
    do:
        find first buf_db no-lock where
            buf_db.db-num = ub.cash-desk.db-nu  no-error.
        if available buf_db then
        do:
            message
                "Нельзя удалять запись о кассе," skip
                "принадлежащей другой БД"
                view-as alert-box .
            undo main-block, return error.
        end.
        else
        do:
            assign
                v-no-news = yes.
        end.
    end.
    if g#db-num = 0
        and g#news
        and ub.cash-desk.db-num > 0
        then
    do:
        assign
            v-no-news = yes.
    end.
    if ub.cash-desk.autonomy <> integer('2':U) then
    do:
        FIND FIRST ub.wth-place NO-LOCK where
            ub.wth-place.obj-code = ub.cash-desk.obj-code AND
            ub.wth-place.obj-type = 'маг':U AND
            ub.wth-place.cash-desk = ub.cash-desk.cash-num NO-ERROR.
        IF AVAIL ub.wth-place then
        do:
            message "Данная касса привязана к МХ МЦ!" skip
                "Удаление невозможно!" view-as alert-box ERROR.
            undo main-block, return error.
        end.
        FIND FIRST ub.shift-cash No-LOCK WHERE
            ub.shift-cash.cash-num = ub.cash-desk.cash-num
            AND ub.shift-cash.obj-code = ub.cash-desk.obj-code
            AND ub.shift-cash.obj-type = 'маг':U
            AND ub.shift-cash.status_ <> 'зкр':U
            No-ERROR.
        if avail ub.shift-cash then
        do:
            message "Для данной кассы имеются незакрытые смены!" skip
                "Удаление невозможно!" view-as alert-box ERROR.
            undo main-block, return error.
        end.
    end.
    for each buf_cash-desk-attr where
        buf_cash-desk-attr.db-num = ub.cash-desk.db-num
        AND  buf_cash-desk-attr.obj-code = ub.cash-desk.obj-code
        AND  buf_cash-desk-attr.pos-type = ub.cash-desk.pos-type
        AND  buf_cash-desk-attr.cash-num = ub.cash-desk.cash-num
        on error undo main-block, return error return-value:
        delete buf_cash-desk-attr.
    end.
    for each buf_inkas-pay-wth where
        buf_inkas-pay-wth.obj-type = 'маг':U
        AND  buf_inkas-pay-wth.obj-code = ub.cash-desk.obj-code
        AND  buf_inkas-pay-wth.pay-desk = ub.cash-desk.cash-num
        AND  buf_inkas-pay-wth.cashier = 0
        AND  buf_inkas-pay-wth.inkas-code = ''
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
        delete buf_inkas-pay-wth.
    end.
    if not g#news then
    do:
        run cur-time in this-procedure(output v-date, output v-time).
        create buf_c-cash-desk.
        buffer-copy ub.cash-desk to buf_c-cash-desk
            assign
            buf_c-cash-desk.chip-num           = next-value (s-corr-chip, ub)
            buf_c-cash-desk.corr-time          = v-time
            buf_c-cash-desk.corr-user-db-num   = g#db-num
            buf_c-cash-desk.corr-user-name     = g#userid
            buf_c-cash-desk.corr-date          = v-date
            buf_c-cash-desk.is-del             = yes
            buf_c-cash-desk.attr-code          = "":U
            buf_c-cash-desk.subject            = 'cash-desk':U
            buf_c-cash-desk.action             = integer('99':U)
            .
    end.
    if not v-no-news then
    do:
        if g#db-num = 0
            and not g#news
            and ub.cash-desk.db-num <> 0 then
        do:
            assign
                v-db-list = string(ub.cash-desk.db-num)
                .
        end.
        if g#db-num <> 0 then
        do:
            assign
                v-db-list = string(0)
                .
        end.
        run nws/cmd-del.p
            ( input 'cash-desk':U
            ,input (buffer ub.cash-desk:handle)
            ,input v-db-list
            ) no-error .
        if error-status :error then
        do:
            return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message ( error-status :num-messages ) ).
        end.
        run trg/userlog.p (
            input 'delete':U
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
    if g#oxml = yes
        then
    do:
        run str/calloxml.p (
            input 'delete':U
            , input 'cash-desk':U
            , input ( buffer ub.cash-desk:handle )
            ) no-error.
        if error-status :error
            then
        do:
            undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                , chr(10)
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.
    end.
end.
