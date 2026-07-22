block-level on error undo, throw.
TRIGGER PROCEDURE FOR DELETE OF ub.dis-card .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление записи Дисконтная карта".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure discardh_write-dis-card-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-source-type like ub.c-dc-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-dc-hist.source-ref no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-card for ub.c-dis-card.
  do
  on error undo, return error
  :
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-dis-card.
    buffer-copy ub.dis-card to buf_c-dis-card
    assign
    buf_c-dis-card.d-card            = ub.dis-card.d-card
    buf_c-dis-card.card-num          = ub.dis-card.card-num
    buf_c-dis-card.chip-num           = next-value (s-dc-chip, ub)
    buf_c-dis-card.corr-time          = v-time
    buf_c-dis-card.corr-user-db-num   = g#db-num
    buf_c-dis-card.corr-user-name     = (if g#news
                                         then (chr(4) +  'СПН':U)
                                         else (if g#esys
                                               then (chr(4) +  'ВС':U)
                                               else g#userid
                                              )
                                         )
    buf_c-dis-card.corr-date          = v-date
    .
    create buf_c-dc-hist.
    buffer-copy buf_c-dis-card to buf_c-dc-hist
    assign
    buf_c-dc-hist.action = integer('99':U)
    buf_c-dc-hist.subject = 'dis-card':U
    buf_c-dc-hist.host-code = ub.dis-card.emitent-host-code
    buf_c-dc-hist.is-news = g#news
    buf_c-dc-hist.source-type = p-source-type
    buf_c-dc-hist.source-ref = p-source-ref
    .
    if not ( g#db-num > 0 )
    or (g#news
        and ( g#db-num > 0 )
        and buf_c-dis-card.corr-user-name = (chr(4) +  'СПН':U)
        )
    then do:
      run str/callnews.p
        (input 'c-dis-card':U
        ,input (buffer buf_c-dis-card:handle)
        ).
    end.
  end.
end procedure.
define buffer buf_dis-obj             for ub.dis-obj.
define buffer buf_dis-host            for ub.dis-host.
define buffer buf_c-dc-hist           for ub.c-dc-hist .
define buffer buf_c-dis-obj           for ub.c-dis-obj .
define buffer buf_c-dis-host          for ub.c-dis-host .
define buffer buf_dis-card-property   for ub.dis-card-property.
define buffer buf_c-dis-card-property for ub.c-dis-card-property.
define buffer buf_dis-dc-rule         for ub.dis-dc-rule.
define buffer buf_c-dis-dc-rule       for ub.c-dis-dc-rule.
main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
    if ub.dis-card.status_ <> 'неисп':U then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Физическое удаление дисконтной карты возможно только для НЕИСПОЛЬЗОВАВШИХСЯ карт" skip
            view-as alert-box error .
        undo main-block, return error.
    end.
    for each buf_dis-card-property where
        buf_dis-card-property.d-card = ub.dis-card.d-card
        on error undo main-block, return error
        on stop undo main-block, return error:
        find first ub.dis-card-property where
            recid(ub.dis-card-property) = recid(buf_dis-card-property) .
        assign
            ub.dis-card-property.card-num = - abs(ub.dis-card-property.card-num).
        delete ub.dis-card-property.
    end.
    for each buf_dis-obj where
        buf_dis-obj.d-card = ub.dis-card.d-card
        on error undo main-block, return error
        on stop undo main-block, return error:
        find first ub.dis-obj where
            recid(ub.dis-obj) = recid(buf_dis-obj) .
        assign
            ub.dis-obj.card-num = - abs(ub.dis-obj.card-num).
        delete ub.dis-obj.
    end.
    for each buf_dis-host where
        buf_dis-host.d-card = ub.dis-card.d-card
        on error undo main-block, return error
        on stop undo main-block, return error:
        find first ub.dis-host where
            recid(ub.dis-host) = recid(buf_dis-host) .
        assign
            ub.dis-host.card-num = - abs(ub.dis-host.card-num).
        delete ub.dis-host.
    end.
    for each buf_c-dis-card-property where
        buf_c-dis-card-property.d-card = ub.dis-card.d-card
        on error undo main-block, return error
        on stop undo main-block, return error:
        find first ub.c-dis-card-property where
            recid(ub.c-dis-card-property) = recid(buf_c-dis-card-property) .
        assign
            ub.c-dis-card-property.card-num = - abs(ub.c-dis-card-property.card-num).
        delete ub.c-dis-card-property.
    end.
    for each buf_c-dis-obj where
        buf_c-dis-obj.d-card = ub.dis-card.d-card
        on error undo main-block, return error
        on stop undo main-block, return error:
        find first ub.c-dis-obj where
            recid(ub.c-dis-obj) = recid(buf_c-dis-obj) .
        assign
            ub.c-dis-obj.card-num = - abs(ub.c-dis-obj.card-num).
        delete ub.c-dis-obj.
    end.
    for each buf_c-dis-host where
        buf_c-dis-host.d-card = ub.dis-card.d-card
        on error undo main-block, return error
        on stop undo main-block, return error:
        find first ub.c-dis-host where
            recid(ub.c-dis-host) = recid(buf_c-dis-host) .
        assign
            ub.c-dis-host.card-num = - abs(ub.c-dis-host.card-num).
        delete ub.c-dis-host.
    end.
    for each buf_c-dc-hist where
        buf_c-dc-hist.d-card = ub.dis-card.d-card
        on error undo main-block, return error
        on stop undo main-block, return error:
        if buf_c-dc-hist.subject <> 'dis-card':U then
        do:
            find first ub.c-dc-hist where
                recid(ub.c-dc-hist) = recid(buf_c-dc-hist) .
            assign
                ub.c-dc-hist.card-num = - abs(ub.c-dc-hist.card-num).
            delete ub.c-dc-hist.
        end.
    end.
    for each buf_dis-card-property where
        buf_Dis-card-property.d-card = ub.dis-card.d-card
        on error undo main-block, return error
        on stop undo main-block, return error:
        assign
            buf_Dis-card-property.card-num = - abs(buf_dis-card-property.card-num).
        delete buf_dis-card-property.
    end.
    for each buf_c-dis-card-property where
        buf_c-Dis-card-property.d-card = ub.dis-card.d-card
        on error undo main-block, return error
        on stop undo main-block, return error:
        assign
            buf_c-Dis-card-property.card-num = - abs(buf_c-dis-card-property.card-num).
        delete buf_c-dis-card-property.
    end.
    for each buf_dis-dc-rule where
        buf_dis-dc-rule.d-card = ub.dis-card.d-card
        on error undo main-block, return error
        on stop undo main-block, return error:
        assign
            buf_Dis-dc-rule.card-num = - abs(buf_dis-dc-rule.card-num).
        delete buf_dis-dc-rule.
    end.
    for each buf_c-dis-dc-rule where
        buf_c-dis-dc-rule.d-card = ub.dis-card.d-card
        on error undo main-block, return error
        on stop undo main-block, return error:
        assign
            buf_c-Dis-dc-rule.card-num = - abs(buf_c-dis-dc-rule.card-num).
        delete buf_c-dis-dc-rule.
    end.
    run discardh_write-dis-card-trigger in this-procedure  (
        input no
        ,input (if g#news
        then 'db':U
        else (if g#esys
        then 'esys':U
        else "":U)
        )
        ,input  (if g#news
        then string(g#news-source-db)
        else (if g#esys
        then string(g#esys-source-esys)
        else "":U)
        )
        ) .
    if g#oxml = yes
        then
    do:
        run str/calloxml.p (
            input 'delete':U
            , input 'dis-card':U
            , input ( buffer ub.dis-card:handle )
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
    run trg/userlog.p (
        input 'delete':U
        , input 'dis-card':U
        , input ( buffer ub.dis-card :handle )
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
