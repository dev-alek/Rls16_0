block-level on error undo, throw.
TRIGGER PROCEDURE FOR DELETE OF ub.dis-card-type.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление типа дисконтной карты".
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
      p-vss-parameters = substitute('&1|&2|&3|&4|&5'
                         , ub.dis-card-type.emitent-host-code
                         , ub.dis-card-type.type
                         , ub.dis-card-type.host-code
                        , ub.dis-card-type.obj-type
                        , ub.dis-card-type.obj-code
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
define buffer buf_c-dis-card-type    for ub.c-dis-card-type.
define buffer buf_hist-nws-option    for ub.hist-nws-option.
define buffer buf_rule-call-param    for ub.rule-call-param.
define buffer buf_rp-by-call         for ub.rp-by-call.
define buffer buf_rule-by-call       for ub.rule-by-call.
define buffer buf_Dis-card-type      for ub.dis-card-type.
define buffer buf_dis-card-type-attr for ub.dis-card-type-attr.
define buffer buf_dis-dct-rule       for ub.dis-dct-rule.
define buffer buf_prop-ref-call      for ub.prop-ref-call.
main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
    if not g#news
        and g#db-num <> 0 then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Запрещено удаление типа ДК в УБД"
            view-as alert-box error .
        undo main-block, return error .
    end.
    if ub.dis-card-type.host-code = 0
        and ub.dis-card-type.obj-code = 0
        and ub.dis-card-type.obj-type = '':U
        then
    do:
        FIND FIRST ub.dis-card No-LOCK WHERE
            ub.dis-card.type = ub.dis-card-type.type AND
            ub.dis-card.emitent-host-code = ub.dis-card-type.emitent-host-code NO-ERROR.
        if avail ub.dis-card then
        do:
            message "Для типа дисконтной карты имеются карты!" skip
                "Удаление невозможно!" view-as alert-box ERROR.
            undo main-block, return error.
        end.
        find first buf_prop-ref-call no-lock where
            buf_prop-ref-call.call_id = ub.dis-card-type.uniq-key-rec no-error.
        if available buf_prop-ref-call then
        do:
            message "Для типа дисконтной карты имеются срезы/итоги!" skip
                "Удаление невозможно!" view-as alert-box ERROR.
            undo main-block, return error.
        end.
        find first buf_dis-card-type-attr no-lock where
            buf_dis-card-type-attr.emitent-host-code = ub.dis-card-type.emitent-host-code
            and buf_dis-card-type-attr.type = ub.dis-card-type.type no-error.
        if available buf_dis-card-type-attr then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Имеются записи атрибутов типа ДК" skip
                "Тип ДК" ub.dis-card-type.type "Эмитент" ub.dis-card-type.emitent-host-code
                view-as alert-box error .
            undo main-block, return error .
        end.
        find first buf_dis-card-type no-lock where
            buf_dis-card-type.emitent-host-code = ub.dis-card-type.emitent-host-code
            and buf_dis-card-type.type = ub.dis-card-type.type
            and buf_dis-card-type.host-code > 0 no-error.
        if available buf_dis-card-type then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Имеются записи локальных (фирма или объект) настроек для типа ДК" skip
                "Тип ДК" ub.dis-card-type.type "Эмитент" ub.dis-card-type.emitent-host-code
                view-as alert-box error .
            undo main-block, return error .
        end.
        find first buf_hist-nws-option no-lock where
            buf_hist-nws-option.table-name = 'dis-card-type':U
            and buf_hist-nws-option.host-code = ub.dis-card-type.emitent-host-code
            AND buf_hist-nws-option.charkey_one = ub.dis-card-type.type no-error .
        if available buf_hist-nws-option then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Имеются записи опций маршрутизации и записи истории для типа ДК" skip
                "Тип ДК" ub.dis-card-type.type "Эмитент" ub.dis-card-type.emitent-host-code
                view-as alert-box error .
            undo main-block, return error .
        end.
        find first buf_rule-by-call no-lock where
            buf_rule-by-call.call_id = ub.dis-card-type.uniq-key-rec no-error.
        if available buf_rule-by-call then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Имеются привязки правил к типу ДК" skip
                "Тип ДК" ub.dis-card-type.type "Эмитент" ub.dis-card-type.emitent-host-code
                view-as alert-box error .
            undo main-block, return error .
        end.
        find first buf_rp-by-call no-lock where
            buf_rp-by-call.call_id = ub.dis-card-type.uniq-key-rec no-error.
        if available buf_rp-by-call then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Имеются привязки правил к профайлам правил для типа ДК" skip
                "Тип ДК" ub.dis-card-type.type "Эмитент" ub.dis-card-type.emitent-host-code
                view-as alert-box error .
            undo main-block, return error .
        end.
        find first buf_rule-call-param no-lock where
            buf_rule-call-param.call_id = ub.dis-card-type.uniq-key-rec no-error.
        if available buf_rule-call-param then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Имеются параметры вызова правил для типа ДК" skip
                "Тип ДК" ub.dis-card-type.type "Эмитент" ub.dis-card-type.emitent-host-code
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.
    for each buf_dis-dct-rule  where
        buf_Dis-dct-rule.emitent-host-code = ub.dis-card-type.emitent-host-code
        and buf_Dis-dct-rule.type = ub.dis-card-type.type
        and buf_Dis-dct-rule.host-code = ub.dis-card-type.host-code
        and buf_Dis-dct-rule.obj-type = ub.dis-card-type.obj-type
        and buf_Dis-dct-rule.obj-code = ub.dis-card-type.obj-code
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
        if buf_Dis-dct-rule.discnt-role = 'def-categ':U
            or buf_Dis-dct-rule.discnt-role = 'def-pcnt':U
            or buf_Dis-dct-rule.discnt-role = 'def-cash-pcnt':U then
        do:
            delete buf_Dis-dct-rule.
        end.
        else
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Имеются скидки для ТИПА ДК" skip
                "Тип ДК" ub.dis-card-type.type "Эмитент" ub.dis-card-type.emitent-host-code
                "Фирма" ub.dis-card-type.host-code
                "Объект" ub.dis-card-type.obj-type ub.dis-card-type.obj-code
                "Объект"
                "Тип скидки"  entry (lookup (buf_dis-dct-rule.discnt-role, 'calc-d-pcnt,calc-cash-d-pcnt,calc-categ,dis-tot-flag,def-categ,def-pcnt,def-cash-pcnt':u) + 1, ',' + 'Расчет %скидки ДК на товар,Расчет %скидки ДК на итог,Расчет категории ДК,Участие в итогах по ДК,Категория ДК по умолчанию,% скидки ДК на товар по умолч.,% скидки ДК на итог по умолч.':u)
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-dis-card-type.
    buffer-copy ub.dis-card-type to buf_c-dis-card-type
        assign
        buf_c-dis-card-type.chip-num           = next-value (s-dc-chip, ub)
        buf_c-dis-card-type.corr-time          = v-time
        buf_c-dis-card-type.corr-user-db-num   = g#db-num
        buf_c-dis-card-type.corr-user-name     = g#userid
        buf_c-dis-card-type.corr-date          = v-date
        buf_c-dis-card-type.action = integer('99':U)
        buf_c-dis-card-type.subject = 'dis-card-type':U
        .
    if g#oxml = yes
        then
    do:
        run str/calloxml.p (
            input 'delete':U
            , input 'dis-card-type':U
            , input ( buffer ub.dis-card-type:handle )
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
        , input 'dis-card-type':U
        , input ( buffer ub.dis-card-type :handle )
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
