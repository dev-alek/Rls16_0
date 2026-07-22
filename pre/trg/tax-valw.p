block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.tax-rate-value OLD old-tax-rate-value.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись для таблицы значение ставки налога".
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
      p-vss-parameters = substitute('&1|&2|&3|&4|&5|&6|&7'
                         , ub.tax-rate-value.tax-code
                         , ub.tax-rate-value.rate-code
                         , ub.tax-rate-value.corr-user-db-num
                         , ub.tax-rate-value.chip-num
                         , ub.tax-rate-value.host-code
                         , ub.tax-rate-value.obj-type
                         , ub.tax-rate-value.obj-code
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
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
DEFINE buffer b_sysconf for ub.sysconf.
DEFINE buffer b_shop    for ub.shop.
DEFINE buffer b_store   for ub.store.
DEFINE buffer b_clients   for ub.clients.
define buffer b_tax-rate-value for ub.tax-rate-value .
define buffer buf_c-tax-hist for ub.c-tax-hist.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
    if not g#news and
    ( g#db-num > 0 ) and
    (ub.tax-rate-value.host-code = 0 OR
    (ub.tax-rate-value.obj-type = '':U AND
      ub.tax-rate-value.obj-code = 0)
    ) then do:
      message
      "Нельзя заводить значения налога по фирме и/или" skip
      "глобальное значение налога в УБД"
      view-as alert-box error .
      undo main-block, return error .
    end.
 if (ub.tax-rate-value.host-code = 0 and
     (ub.tax-rate-value.obj-type  <> "":U OR
      ub.tax-rate-value.obj-code  <> 0)
    ) OR
    (ub.tax-rate-value.obj-type = "":U  AND
     ub.tax-rate-value.obj-code  <> 0) OR
    (ub.tax-rate-value.obj-type <> "":U  AND
     ub.tax-rate-value.obj-code  = 0)  then do:
   message
      vss-workfile vss-revision vss-description skip
      "Ошибка при задании кода фирмы и/или объекта при записи значения ставки налога" skip
      "Код налога" ub.tax-rate-value.tax-code skip
      "Код ставки" ub.tax-rate-value.rate-code skip
      "Код фирмы" ub.tax-rate-value.host-code skip
      "Тип объекта" ub.tax-rate-value.obj-type skip
      "Код объекта" ub.tax-rate-value.obj-code skip
      "Факт. дата" ub.tax-rate-value.fact-date skip
      "Статус" ub.tax-rate-value.status_
      view-as alert-box error .
    undo main-block, return error .
 end.
 if ub.tax-rate-value.host-code <> 0 then do:
  find first b_sysconf No-LOCK WHERe
             b_sysconf.host-code = ub.tax-rate-value.host-code No-ERROR.
  if not avail b_sysconf then dO:
   message
      vss-workfile vss-revision vss-description skip
      "Не найдена фирма при записи значения ставки налога" skip
      "Код налога" ub.tax-rate-value.tax-code skip
      "Код ставки" ub.tax-rate-value.rate-code skip
      "Код фирмы" ub.tax-rate-value.host-code skip
      "Тип объекта" ub.tax-rate-value.obj-type skip
      "Код объекта" ub.tax-rate-value.obj-code skip
      "Факт. дата" ub.tax-rate-value.fact-date skip
      "Статус" ub.tax-rate-value.status_
      view-as alert-box error .
    undo main-block, return error .
  end.
 end.
 if ub.tax-rate-value.obj-code <> 0 then do:
  FIND FIRST b_clients No-LOCK WHERE
             b_clients.obj-type = ub.tax-rate-value.obj-type AND
             b_clients.obj-code = ub.tax-rate-value.obj-code No-ERROR.
  if not avail b_clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найден объект при записи значения ставки налога" skip
      "Код налога" ub.tax-rate-value.tax-code skip
      "Код ставки" ub.tax-rate-value.rate-code skip
      "Код фирмы" ub.tax-rate-value.host-code skip
      "Тип объекта" ub.tax-rate-value.obj-type skip
      "Код объекта" ub.tax-rate-value.obj-code skip
      "Факт. дата" ub.tax-rate-value.fact-date skip
      "Статус" ub.tax-rate-value.status_ skip
      "Номер БД для объекта" b_clients.db-num skip
      "Номер текущей БД" g#db-num
      view-as alert-box error .
    undo main-block, return error .
  end.
  CASE ub.tax-rate-value.obj-type:
    when 'маг':U then do:
      fiND FIRST B_SHOP NO-lock where
                  B_SHOP.OBJ-CODE = UB.TAX-RATE-value.obj-code No-ERROR.
      if not avail b_shop then do:
        message
            vss-workfile vss-revision vss-description skip
            "Не найден магазин при записи значения ставки налога" skip
            "Код налога" ub.tax-rate-value.tax-code skip
            "Код ставки" ub.tax-rate-value.rate-code skip
            "Код фирмы" ub.tax-rate-value.host-code skip
            "Тип объекта" ub.tax-rate-value.obj-type skip
            "Код объекта" ub.tax-rate-value.obj-code skip
            "Факт. дата" ub.tax-rate-value.fact-date skip
            "Статус" ub.tax-rate-value.status_
         view-as alert-box error .
         undo main-block, return error .
      end.
    end.
    when 'скл':U then do:
      fiND FIRST B_Store NO-lock where
                  B_Store.OBJ-CODE = UB.TAX-RATE-value.obj-code No-ERROR.
      if not avail b_store then do:
        message
            vss-workfile vss-revision vss-description skip
            "Не найден склад при записи значения ставки налога" skip
            "Код налога" ub.tax-rate-value.tax-code skip
            "Код ставки" ub.tax-rate-value.rate-code skip
            "Код фирмы" ub.tax-rate-value.host-code skip
            "Тип объекта" ub.tax-rate-value.obj-type skip
            "Код объекта" ub.tax-rate-value.obj-code skip
            "Факт. дата" ub.tax-rate-value.fact-date skip
            "Статус" ub.tax-rate-value.status_
         view-as alert-box error .
         undo main-block, return error .
      end.
    end.
  end CASE.
  if not g#news then do:
    if ( g#db-num > 0 ) = yes and g#db-num <> b_clients.db-num then do:
        message
            vss-workfile vss-revision vss-description skip
            "Попытка определеить значения ставки налога на объекте в чужой БД" skip
            "Код налога" ub.tax-rate-value.tax-code skip
            "Код ставки" ub.tax-rate-value.rate-code skip
            "Код фирмы" ub.tax-rate-value.host-code skip
            "Тип объекта" ub.tax-rate-value.obj-type skip
            "Код объекта" ub.tax-rate-value.obj-code skip
            "Факт. дата" ub.tax-rate-value.fact-date skip
            "Статус" ub.tax-rate-value.status_
         view-as alert-box error .
         undo main-block, return error .
    end.
  end.
 end.
 find first ub.tax No-LOCK WHERE
            ub.tax.tax-code = ub.tax-rate-value.tax-code No-ERROR.
 if not avail ub.tax then do:
    message
        vss-workfile vss-revision vss-description skip
        "Не найден налог при записи значения ставки налога" skip
        "Код налога" ub.tax-rate-value.tax-code skip
        "Код ставки" ub.tax-rate-value.rate-code skip
        "Код фирмы" ub.tax-rate-value.host-code skip
        "Тип объекта" ub.tax-rate-value.obj-type skip
        "Код объекта" ub.tax-rate-value.obj-code skip
        "Факт. дата" ub.tax-rate-value.fact-date skip
        "Статус" ub.tax-rate-value.status_
        view-as alert-box error .
      undo main-block, return error .
 end.
 find first ub.tax-rate Exclusive-LOCK WHERE
            ub.tax-rate.tax-code = ub.tax-rate-value.tax-code AND
            ub.tax-rate.rate-code = ub.tax-rate-value.rate-code No-WAIT No-ERROR.
 if locked ub.tax-rate then do:
    message
        vss-workfile vss-revision vss-description skip
        "Занята запись ставки при записи значения ставки налога" skip
        "Код налога" ub.tax-rate-value.tax-code skip
        "Код ставки" ub.tax-rate-value.rate-code skip
        "Код фирмы" ub.tax-rate-value.host-code skip
        "Тип объекта" ub.tax-rate-value.obj-type skip
        "Код объекта" ub.tax-rate-value.obj-code skip
        "Факт. дата" ub.tax-rate-value.fact-date skip
        "Статус" ub.tax-rate-value.status_
        view-as alert-box error .
      undo main-block, return error .
 end.
 if not avail ub.tax then do:
    message
        vss-workfile vss-revision vss-description skip
        "Не найдена ставка при записи значения ставки налога" skip
        "Код налога" ub.tax-rate-value.tax-code skip
        "Код ставки" ub.tax-rate-value.rate-code skip
        "Код фирмы" ub.tax-rate-value.host-code skip
        "Тип объекта" ub.tax-rate-value.obj-type skip
        "Код объекта" ub.tax-rate-value.obj-code skip
        "Факт. дата" ub.tax-rate-value.fact-date skip
        "Статус" ub.tax-rate-value.status_
        view-as alert-box error .
      undo main-block, return error .
 end.
if ub.tax-rate.status_ = 'удал':U and
   not g#news and
   ub.tax-rate-value.status_ <> 'удал':U then do:
   message
    vss-workfile vss-revision vss-description skip
    "Нельзя добавлять/или изменятьзначение ставки налога для удаленной ставки" skip
    "Код налога" ub.tax-rate-value.tax-code skip
    "Код ставки" ub.tax-rate-value.rate-code skip
    "Код фирмы" ub.tax-rate-value.host-code skip
    "Тип объекта" ub.tax-rate-value.obj-type skip
    "Код объекта" ub.tax-rate-value.obj-code skip
    "Факт. дата" ub.tax-rate-value.fact-date SKIP
    "Статус" ub.tax-rate-value.status_
    "Значение" ub.tax-rate-value.rate-value
    view-as alert-box error .
  undo main-block, return error .
end.
if not g#news then do:
  FIND LAST  b_tax-rate-value No-LOCK WHERE
              b_tax-rate-value.tax-code = ub.tax-rate-value.tax-code AND
              b_tax-rate-value.rate-code = ub.tax-rate-value.rate-code AND
              b_tax-rate-value.host-code = ub.tax-rate-value.host-code AND
              b_tax-rate-value.obj-type =  ub.tax-rate-value.obj-type AND
              b_tax-rate-value.obj-code =  ub.tax-rate-value.obj-code AND
              b_tax-rate-value.fact-order <=  ub.tax-rate-value.fact-order AND
              b_tax-rate-value.status_ =  ub.tax-rate-value.status_ AND
              ub.tax-rate-value.status_ = 'тек':U AND
              recid(b_tax-rate-value) <> recid(ub.tax-rate-value) NO-ERROR.
  if avail b_tax-rate-value and b_tax-rate-value.rate-value = ub.tax-rate-value.rate-value then do:
      message
          vss-workfile vss-revision vss-description skip
          "На выбранную дату уже есть такое же значение ставки налога" skip
          "Код налога" ub.tax-rate-value.tax-code skip
          "Код ставки" ub.tax-rate-value.rate-code skip
          "Код фирмы" ub.tax-rate-value.host-code skip
          "Тип объекта" ub.tax-rate-value.obj-type skip
          "Код объекта" ub.tax-rate-value.obj-code skip
          "Факт. дата" ub.tax-rate-value.fact-date SKIP
          "Статус" ub.tax-rate-value.status_
          "Значение" ub.tax-rate-value.rate-value
          view-as alert-box error .
        undo main-block, return error .
  end.
end.
  assign
  ub.tax-rate-value.status_ = (if ub.tax-rate.status_ = 'удал':U and g#news
                               then 'удал':U
                               else ub.tax-rate-value.status_
                              )
  .
  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    assign
    ub.tax-rate-value.chip-num           = next-value(s-corr-chip, ub)
    ub.tax-rate-value.corr-time          = v-time
    ub.tax-rate-value.corr-user-db-num   = g#db-num
    ub.tax-rate-value.corr-user-name     = g#userid
    ub.tax-rate-value.corr-date          = v-date
    .
    create buf_c-tax-hist.
    buffer-copy tax-rate-value to buf_c-tax-hist
    assign
    buf_c-tax-hist.action = (if new (ub.tax-rate-value )
                            then integer('1':U)
                            else integer('2':U))
    buf_c-tax-hist.subject = 'tax-rate-value':U
    buf_c-tax-hist.is-news = no
    .
  end.
  run str/callnews.p
    (input 'tax-rate-value':U
    ,input (buffer ub.tax-rate-value:handle)
    ).
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input 'update':U
        , input 'tax-rate-value':U
        , input ( buffer ub.tax-rate-value:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , chr(10)
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.
