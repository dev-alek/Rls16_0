block-level on error undo, throw.
TRIGGER PROCEDURE FOR DELETE OF ub.pl-gds.
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на удаление pl-gds":U.
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
      p-vss-parameters = substitute('&1|&2|&3|&4'
                         , ub.pl-gds.obj-type
                         , ub.pl-gds.obj-code
                         , ub.pl-gds.pl-code
                         , ub.pl-gds.gds-code
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
define variable v-log      as   logical      no-undo.
define variable v-db-num   like ub.db.db-num no-undo.
define variable str1       as   character    no-undo.
define variable jj         as   integer      no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define buffer buf_goods   for ub.goods.
define buffer buf_units   for ub.units.
define buffer buf_place   for ub.place.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_c-pl-gds  for ub.c-pl-gds.
define buffer buf_c-plc-hist  for ub.c-plc-hist.
define buffer buf_c-table-bind for ub.c-table-bind.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  ub.pl-gds.obj-type
  ,input  ub.pl-gds.obj-code
  ,output v-db-num
  )  .
  if g#db-num <> v-db-num
  and g#news <> yes
  then do:
      message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
              "Нельзя удалять запись ТОВАРА НА СКЛАДСКОМ МЕСТЕ в БД, отличной от БД объекта." skip
              "Номер текущей БД:" g#db-num skip "Номер БД объекта:" v-db-num
      view-as alert-box error.
      undo main-block, return error.
  end.
  if ub.pl-gds.fact-qnty <> 0 or
     ub.pl-gds.free-qnty <> 0 or
     ub.pl-gds.cli-free-qnty <> 0 or
     ub.pl-gds.cli-fact-qnty <> 0
      then do:
      message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
              "Количество по товару не равно 0!" skip
              "Код товара" pl-gds.gds-code skip
              "Код резервуара" pl-gds.pl-code skip
              "Факт кол-во (е.п.)" pl-gds.cli-fact-qnty skip
              "Свободно кол-во (е.п.)" pl-gds.cli-free-qnty skip
              "Факт (кол-во)" pl-gds.fact-qnty skip
              "Свободно (кол-во)" pl-gds.free-qnty skip
              "Удаление невозможно!"
      view-as alert-box error.
      undo main-block, return error.
  end.
  find first buf_goods no-lock where
             buf_goods.gds-code = ub.pl-gds.gds-code no-error.
  if not available buf_goods then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Не найден товар с кодом " ub.pl-gds.gds-code
    view-as alert-box error.
    undo main-block, return error.
  end.
  find first buf_units no-lock where
             buf_units.unit-name = buf_goods.unit-base no-error.
  if not available buf_goods then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Не найдена единица измерения " buf_goods.unit-base
    view-as alert-box error.
    undo main-block, return error.
  end.
  if lookup( 'топ':U,  buf_units.type ) > 0 or
     lookup( 'дро':U, buf_units.type ) > 0 then do:
    assign
      v-log = no
    .
    run trg/pl-gdsdv.p (  input ub.pl-gds.obj-type,
                      input ub.pl-gds.obj-code,
                      input ub.pl-gds.pl-code,
                      input ub.pl-gds.gds-code,
                     output v-log               ) no-error.
    if error-status :error then do:
        message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
                "Ошибка при вызове процедуры (триггера)" skip
                "объект" ub.pl-gds.obj-type ub.pl-gds.obj-code skip
                "скл.место" ub.pl-gds.pl-code skip
                "товар" ub.pl-gds.gds-code skip
                error-status :get-message( 1 ) skip
                return-value
        view-as alert-box error.
        undo main-block, return error.
    end.
    if v-log <> yes then do:
        message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
                "Не удалось удалить запись." skip
                return-value
        view-as alert-box information.
        undo main-block, return error.
    end.
  end.
  if not g#news then do:
    run nws/cmd-del.p ( input 'pl-gds':U
                    ,input ( buffer ub.pl-gds :handle )
                    ,input "":U                          ) no-error.
    if error-status :error then do:
      assign str1 = chr(10).
      do jj = 1 to error-status :num-messages :
        assign str1 = str1 + chr(10) + error-status :get-message ( jj ).
      end.
      undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&4",
                                    vss-workfile, chr(10), return-value, str1 ).
    end.
  end.
  if g#news <> yes then do:
    run cur-time in this-procedure(output v-today, output v-time).
    create buf_c-pl-gds.
    buffer-copy ub.pl-gds to buf_c-pl-gds
    assign
    buf_c-pl-gds.chip-num           = next-value (s-plc-chip, ub)
    buf_c-pl-gds.corr-time          = v-time
    buf_c-pl-gds.corr-user-db-num   = g#db-num
    buf_c-pl-gds.corr-user-name     = g#userid
    buf_c-pl-gds.corr-date          = v-today
    .
    create buf_c-plc-hist.
    buffer-copy buf_c-pl-gds to buf_c-plc-hist
    assign
    buf_c-plc-hist.action = integer('99':U)
    buf_c-plc-hist.subject = 'pl-gds':U
    buf_c-plc-hist.is-news = g#news
    .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  ub.pl-gds.obj-type
  ,input  ub.pl-gds.obj-code
  ,output v-host-code
  )  .
    create buf_c-gds-hist.
    buffer-copy buf_c-pl-gds
    except chip-num
    to buf_c-gds-hist
    assign
    buf_c-gds-hist.action = integer('99':U)
    buf_c-gds-hist.subject = 'pl-gds':U
    buf_c-gds-hist.host-code = v-host-code
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.chip-num = next-value (s-gds-chip, ub)
    buf_c-gds-hist.source-type = (if g#news then 'db':U else "":U)
    buf_c-gds-hist.source-ref = (if g#news then string(g#news-source-db) else "":U)
    .
    create buf_c-table-bind.
    assign
    buf_c-table-bind.chip-num-rec   = buf_c-gds-hist.chip-num
    buf_c-table-bind.chip-num-src   = buf_c-pl-gds.chip-num
    buf_c-table-bind.corr-user-db-num     = buf_c-pl-gds.corr-user-db-num
    buf_c-table-bind.tbl-name-rec   = 'c-gds-hist':U
    buf_c-table-bind.tbl-name-src   = 'c-plc-hist':U
    buf_c-table-bind.is-news         = g#news
    buf_c-table-bind.corr-user-name  = g#userid
    buf_c-table-bind.subject        = 'pl-gds':U
    .
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input 'delete':U
        , input 'pl-gds':U
        , input ( buffer ub.pl-gds:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , chr(10)
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
    run trg/userlog.p (
        input 'delete':U
        , input 'pl-gds':U
        , input ( buffer ub.pl-gds :handle )
        , input ?
        , input ""
        ) no-error.
    if error-status :error
        then
    do:
        undo, return substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
            , chr(10)
            , vss-workfile
            , return-value
            , error-status :get-message ( 1 ) ).
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'ref-event':U
  ,input  buffer ub.pl-gds:handle
  ,input ''
  ,input ''
  ,input ''
  ) no-error .
  if error-status :error
  then
  do:
      return error substitute( "&2&1Ошибка маршрутизации записи в машину правил&1&3&1&4"
          , chr(10)
          , vss-workfile
          , return-value
          , error-status :get-message ( 1 ) ).
end.
end.
