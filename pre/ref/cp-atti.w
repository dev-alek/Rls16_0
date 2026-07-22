DEFINE TEMP-TABLE Temp-hattr NO-UNDO LIKE ub.cash-pay-attr
       field user-can-edit as log
       field code as character
       field value_ as character.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as char no-undo.
define input parameter p-cdpay-code like ub.cash-pay-attr.cdpay-code no-undo.
define input parameter p-curr-code  like ub.cash-pay-attr.curr-code no-undo .
define input parameter p-host-code like ub.cash-pay-attr.host-code no-undo.
define input parameter p-obj-type like ub.cash-pay-attr.obj-type no-undo.
define input parameter p-obj-code like ub.cash-pay-attr.obj-code no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Атрибуты типа кассового платежа".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure cp-attr-code :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-range          as integer   no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-label = "Префиксы платежных карт (для выгрузки в XML)"     p-type = 'C':U      p-format = "X(19)"     p-label = "Префиксы платежных карт (для выгрузки в XML)"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=paycard-prefix':u      .   end.
            when 'grp-code':U then do:     assign     p-label = "Группа платежа"     p-type = 'C':U      p-format = "X(45)"     p-label = "Группа платежа"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=grp-code':u      .   end.
            when 'is-use':U then do:     assign     p-label = "Используется"     p-type = 'C':U      p-format = "X(255)"     p-label = "Используется"     p-range = 4     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=is-use':u      .   end.
            when 'dop-doc':U then do:     assign     p-label = "Дополнительный документ"     p-type = 'C':U      p-format = "X(255)"     p-label = "Дополнительный документ"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=dop-doc':u      .   end.
            when 'paycard-all-prefix':U then do:     assign     p-label = "Префиксы платежных карт (для разбора чеков и т.д.)"     p-type = 'C':U      p-format = "X(19)"     p-label = "Префиксы платежных карт (для разбора чеков и т.д.)"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=paycard-prefix':u      .   end.
            when 'paycard-edit-prefix':U then do:     assign     p-label = "Префиксы платежных карт, разрешенных для редактирования"     p-type = 'C':U      p-format = "X(19)"     p-label = "Префиксы платежных карт, разрешенных для редактирования"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=paycard-prefix':u      .   end.
            when 'form_km3':U then do:     assign     p-label = "Формировать КМ-3 по чекам возврата"     p-type = 'L':U      p-format = "+/-"     p-label = "Формировать КМ-3 по чекам возврата"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'bal_malina':U then do:     assign     p-label = "Оплата баллами Малина"     p-type = 'L':U      p-format = "+/-"     p-label = "Оплата баллами Малина"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'max_proc_sum':U then do:     assign     p-label = "Максимальный % порог от суммы"     p-type = 'D':U      p-format = ">>9.99"     p-label = "Максимальный % порог от суммы"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'mask_card_kup':U then do:     assign     p-label = "Маска карты\купона"     p-type = 'C':U      p-format = "x(129)"     p-label = "Маска карты\купона"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа кассового платежа &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure cp-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-tooltip = "Префиксы платежных карт (для выгрузки в XML)"     p-label = "Префиксы платежных карт (для выгрузки в XML)" .   end.
            when 'grp-code':U then do:     assign     p-tooltip = "Группа платежа"     p-label = "Группа платежа" .   end.
            when 'is-use':U then do:     assign     p-tooltip = "Используется"     p-label = "Используется" .   end.
            when 'dop-doc':U then do:     assign     p-tooltip = "Дополнительный документ"     p-label = "Дополнительный документ" .   end.
            when 'paycard-all-prefix':U then do:     assign     p-tooltip = "Префиксы платежных карт (для разбора чеков и т.д.)"     p-label = "Префиксы платежных карт (для разбора чеков и т.д.)" .   end.
            when 'paycard-edit-prefix':U then do:     assign     p-tooltip = "Префиксы платежных карт, разрешенных для редактировани"     p-label = "Префиксы платежных карт, разрешенных для редактирования" .   end.
            when 'form_km3':U then do:     assign     p-tooltip = "Формировать КМ-3 по чекам возврата"     p-label = "Формировать КМ-3 по чекам возврата" .   end.
            when 'bal_malina':U then do:     assign     p-tooltip = "Оплата баллами Малина"     p-label = "Оплата баллами Малина" .   end.
            when 'max_proc_sum':U then do:     assign     p-tooltip = "Максимальный % порог от суммы"     p-label = "Максимальный % порог от суммы" .   end.
            when 'mask_card_kup':U then do:     assign     p-tooltip = "Маска карты\купона"     p-label = "Маска карты\купона" .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа кассового платежа &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure cp-attr-value :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input  parameter p-code        like ub.cash-pay-attr.attr-code      no-undo .
    define output parameter p-value       like ub.cash-pay-attr.attr-value    no-undo .
    define output parameter p-type        as character no-undo .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr no-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code  = p-code
      no-error .
    if avail buf_cash-pay-attr then do:
      assign
        p-value =  buf_cash-pay-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure cp-attr-write :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define input parameter p-value    like ub.cash-pay-attr.attr-value no-undo .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define buffer last_cash-pay-attr for ub.cash-pay-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error .
    if not available buf_cash-pay-attr then do:
      create buf_cash-pay-attr .
      assign
      buf_cash-pay-attr.cdpay-code = p-cdpay-code
      buf_cash-pay-attr.curr-code  = p-curr-code
      buf_cash-pay-attr.host-code  = p-host-code
      buf_cash-pay-attr.obj-type   = p-obj-type
      buf_cash-pay-attr.obj-code   = p-obj-code
      buf_cash-pay-attr.attr-code = p-code
      .
    end.
    assign
      buf_cash-pay-attr.attr-value = p-value
    .
    release buf_cash-pay-attr no-error .
    if error-status:error then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cp-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error .
    if  available buf_cash-pay-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure cp-attr-delete :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_cash-pay-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_cash-pay-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure cp-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-news = true.   end.
            when 'grp-code':U then do:     assign     p-news = true.   end.
            when 'is-use':U then do:     assign     p-news = true.   end.
            when 'dop-doc':U then do:     assign     p-news = true.   end.
            when 'paycard-all-prefix':U then do:     assign     p-news = true.   end.
            when 'paycard-edit-prefix':U then do:     assign     p-news = true.   end.
            when 'form_km3':U then do:     assign     p-news = false.   end.
            when 'bal_malina':U then do:     assign     p-news = false.   end.
            when 'max_proc_sum':U then do:     assign     p-news = true.   end.
            when 'mask_card_kup':U then do:     assign     p-news = true.   end.
      otherwise do:
        p-news = no.
      end.
    end.
  end.
end procedure.
procedure cp-attr-hist :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-hist           as logical   no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-hist = true.   end.
            when 'paycard-all-prefix':U then do:     assign     p-hist = true.   end.
            when 'paycard-edit-prefix':U then do:     assign     p-hist = true.   end.
            when 'form_km3':U then do:     assign     p-hist = true.   end.
            when 'bal_malina':U then do:     assign     p-hist = true.   end.
            when 'max_proc_sum':U then do:     assign     p-hist = true.   end.
            when 'mask_card_kup':U then do:     assign     p-hist = true.   end.
      otherwise do:
        p-hist = no.
      end.
    end.
  end.
end procedure.
procedure paycard-prefix :
define input parameter p-cdpay-code like ub.cash-pay-attr.cdpay-code no-undo .
define input parameter p-curr-code like ub.cash-pay-attr.curr-code no-undo .
define input parameter p-host-code like ub.cash-pay-attr.host-code no-undo .
define input parameter p-obj-type like ub.cash-pay-attr.obj-type no-undo .
define input parameter p-obj-code like ub.cash-pay-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
define variable v-codes as character no-undo .
define variable v-labels as character no-undo .
define variable v-ok as logical no-undo .
  do
  on error undo, return error
  :
    assign
    v-value = p-value
    .
    run ref/cpa-pcep.w (
                   input parparentproc
                  ,input p-cdpay-code
                  ,input p-curr-code
                  ,input p-host-code
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input-output v-value
                  ,output v-ok
                   ) no-error .
    if
    v-ok and
    p-value <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.
end procedure.
procedure is-use :
define input parameter p-cdpay-code like ub.cash-pay-attr.cdpay-code no-undo .
define input parameter p-curr-code like ub.cash-pay-attr.curr-code no-undo .
define input parameter p-host-code like ub.cash-pay-attr.host-code no-undo .
define input parameter p-obj-type like ub.cash-pay-attr.obj-type no-undo .
define input parameter p-obj-code like ub.cash-pay-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
define variable v-codes as character no-undo .
define variable v-labels as character no-undo .
define variable v-ok as logical no-undo .
  do
  on error undo, return error
  :
    assign
    v-value = p-value
    .
    if p-obj-type = 'скл':U then do:
      message
      substitute("Нельзя задать атрибут для объекта типа &1", p-obj-type)
      view-as alert-box error .
      return error.
    end.
    run ref/cpa-isus.w (
                   input parparentproc
                  ,input p-cdpay-code
                  ,input p-curr-code
                  ,input p-host-code
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input-output v-value
                  ,output v-ok
                   ) no-error .
    if
    v-ok and
    p-value <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.
end procedure.
procedure grp-code :
define input parameter p-cdpay-code like ub.cash-pay-attr.cdpay-code no-undo .
define input parameter p-curr-code like ub.cash-pay-attr.curr-code no-undo .
define input parameter p-host-code like ub.cash-pay-attr.host-code no-undo .
define input parameter p-obj-type like ub.cash-pay-attr.obj-type no-undo .
define input parameter p-obj-code like ub.cash-pay-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
define variable v-codes as character no-undo .
define variable v-labels as character no-undo .
define variable v-ok as logical no-undo .
  do
  on error undo, return error
  :
    assign
    v-value = p-value
    .
    run ref/cpa-grp.w (
                   input parparentproc
                  ,input p-cdpay-code
                  ,input p-curr-code
                  ,input p-host-code
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input-output v-value
                  ,output v-ok
                   ) no-error .
    if
    v-ok and
    p-value <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.
end procedure.
procedure cp-attr-manual-edit :
do on error undo, return error return-value
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-section-num = 1.   end.
            when 'grp-code':U then do:     assign     p-section-num = 1.   end.
            when 'is-use':U then do:     assign     p-section-num = 1.   end.
            when 'dop-doc':U then do:     assign     p-section-num = 1.   end.
            when 'paycard-all-prefix':U then do:     assign     p-section-num = 1.   end.
            when 'form_km3':U then do:     assign     p-section-num = 1.   end.
            when 'bal_malina':U then do:     assign     p-section-num = 1.   end.
            when 'max_proc_sum':U then do:     assign     p-section-num = 1.   end.
            when 'mask_card_kup':U then do:     assign     p-section-num = 1.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа кассового платежа &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure cp-attr-batch-edit :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-section-num = 0.   end.
            when 'grp-code':U then do:     assign     p-section-num = 0.   end.
            when 'is-use':U then do:     assign     p-section-num = 0.   end.
            when 'dop-doc':U then do:     assign     p-section-num = 0.   end.
            when 'form_km3':U then do:     assign     p-section-num = 0.   end.
            when 'bal_malina':U then do:     assign     p-section-num = 0.   end.
            when 'max_proc_sum':U then do:     assign     p-section-num = 0.   end.
            when 'mask_card_kup':U then do:     assign     p-section-num = 0.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа кассового платежа &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure dop-doc :
define input parameter p-cdpay-code like ub.cash-pay-attr.cdpay-code no-undo .
define input parameter p-curr-code like ub.cash-pay-attr.curr-code no-undo .
define input parameter p-host-code like ub.cash-pay-attr.host-code no-undo .
define input parameter p-obj-type like ub.cash-pay-attr.obj-type no-undo .
define input parameter p-obj-code like ub.cash-pay-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
define variable v-codes as character no-undo .
define variable v-labels as character no-undo .
define variable v-ok as logical no-undo .
  do on error undo, return error:
    assign
    v-value = p-value.
    run ref/cpa-dop-doc.w (
                   input parparentproc
                  ,input p-cdpay-code
                  ,input p-curr-code
                  ,input p-host-code
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input-output v-value
                  ,output v-ok
                   ) no-error .
    if
    v-ok and
    p-value <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.
end procedure.
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = 'орг':U then do:
       par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parhost-code).
       return par-region.
    end.
    if parobj-type = 'регион':U
    then do:
       par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
       return par-region.
    end.
    par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
    return par-region.
END FUNCTION.
FUNCTION get-objregion RETURNS CHARACTER
  (  input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if  parobj-type = "":U and
      parobj-code = 0
  then do:
     par-region = "Глобально".
  end.
  else if parobj-type = 'орг':U
  then do:
     par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parobj-code).
  end.
  else if parobj-type = 'регион':U
  then do:
     par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
  end.
  else
     par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
  return par-region.
END FUNCTION.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-attr-property  no-undo
field upper-attr-code as character
field attr-code as character
field table-name as character
field edit-menu-section-num as integer
field attr-label as character
field menu-item-handle as widget-handle
field user-can-edit as logical
field menu-name as character
field parent-handle as handle
index pi is unique primary
table-name
menu-name
upper-attr-code
attr-code
index i-section
edit-menu-section-num
.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure attr-pop-create-items :
define input parameter p-table-name as character no-undo .
define input parameter p-get-section-num-proc-name as character no-undo .
define input parameter p-get-attr-label-proc-name as character no-undo .
define input parameter p-attr-choose-proc-name as character no-undo .
define input parameter p-menu-handle as widget-handle no-undo .
define input parameter p-attr-list as character no-undo .
define variable ii as integer no-undo .
define variable V-CREATED as logical no-undo .
define variable v-tool-tip as character no-undo .
define variable v-dop as character no-undo .
define variable v-attr-item as character no-undo .
define variable p-upper-attr-code as character no-undo .
define buffer buf_tt-attr-property for tt-attr-property.
  do
  on error undo, return error return-value
  :
     do ii = 1 to num-entries (p-attr-list):
       v-attr-item = entry(ii, p-attr-list) .
       find first tt-attr-property where
                 tt-attr-property.table-name = p-table-name
             and tt-attr-property.attr-code = v-attr-item
             and tt-attr-property.upper-attr-code = p-upper-attr-code
             and tt-attr-property.menu-name = p-menu-handle:name  no-error .
       if not available tt-attr-property then do:
         create tt-attr-property.
         assign
         tt-attr-property.table-name = p-table-name
         tt-attr-property.attr-code = v-attr-item
         tt-attr-property.upper-attr-code = p-upper-attr-code
         tt-attr-property.menu-name = p-menu-handle:name
         .
         run value ( p-get-section-num-proc-name) (
                                                   input tt-attr-property.attr-code
                                                  ,output tt-attr-property.edit-menu-section-num ) no-error .
         run value ( p-get-attr-label-proc-name ) (
                                        input tt-attr-property.attr-code
                                       ,output v-tool-tip
                                       ,output tt-attr-property.attr-label
                                      ) no-error .
         release tt-attr-property.
       end.
     end.
     for each tt-attr-property where tt-attr-property.menu-name = p-menu-handle:name
     break
     by  tt-attr-property.edit-menu-section-num
     by  tt-attr-property.attr-label
     :
       if tt-attr-property.edit-menu-section-num > 0
       then do:
          if not valid-handle(tt-attr-property.menu-item-handle) then do:
            if num-entries(tt-attr-property.attr-code, chr(4)) > 1
            and entry(2, tt-attr-property.attr-code, chr(4)) <> '':U
            then do:
              find first buf_tt-attr-property where
                        buf_tt-attr-property.table-name = p-table-name
                    and buf_tt-attr-property.menu-name = p-menu-handle:name
                    and buf_tt-attr-property.upper-attr-code = p-upper-attr-code
                    and buf_tt-attr-property.attr-code = entry(1, tt-attr-property.attr-code, chr(4)) no-error .
              if not available buf_tt-attr-property then do:
                create buf_tt-attr-property.
                assign
                buf_tt-attr-property.table-name = p-table-name
                buf_tt-attr-property.attr-code = entry(1, tt-attr-property.attr-code, chr(4))
                buf_tt-attr-property.upper-attr-code = p-upper-attr-code
                buf_tt-attr-property.menu-name = p-menu-handle:name
                .
                create sub-menu buf_tt-attr-property.menu-item-handle
                assign
                name = entry(1, tt-attr-property.attr-code, chr(4))  + chr(4)  + p-menu-handle:name
                parent = p-menu-handle.
              end.
              create menu-item tt-attr-property.menu-item-handle
              assign
              label = tt-attr-property.attr-label
              name = tt-attr-property.attr-code  + chr(4)  + p-menu-handle:name
              parent = buf_tt-attr-property.menu-item-handle
              triggers:
                on choose
                  persistent run value(p-attr-choose-proc-name + "-2") (
                                                                         input  entry(1, tt-attr-property.attr-code, chr(4) )
                                                                        ,input entry(2, tt-attr-property.attr-code, chr(4) )
                                                                          ) .
              end triggers.
              assign
              v-created = yes.
            end.
            else do:
              create menu-item tt-attr-property.menu-item-handle
              assign
              label = tt-attr-property.attr-label
              name = entry(1, tt-attr-property.attr-code, chr(4)) + chr(4)  + p-menu-handle:name
              parent = p-menu-handle
              triggers:
                on choose
                  persistent run value(p-attr-choose-proc-name) (
                                                                 input  entry(1, tt-attr-property.attr-code, chr(4) )) .
              end triggers.
              assign
              v-created = yes.
            end.
          end.
          if last-of(tt-attr-property.edit-menu-section-num)
            then do:
            find first buf_tt-attr-property where
                      buf_tt-attr-property.table-name = p-table-name
                 and  buf_tt-attr-property.attr-code = substitute("&1&2&3"
                                                         , p-table-name
                                                         , tt-attr-property.edit-menu-section-num
                                                         , p-menu-handle:name
                                                         )
                  and buf_tt-attr-property.menu-name = p-menu-handle:name  no-error .
            if not available buf_tt-attr-property then do:
              create buf_tt-attr-property.
              assign
              buf_tt-attr-property.table-name = p-table-name
              buf_tt-attr-property.edit-menu-section-num =  - 1
              buf_tt-attr-property.menu-name = p-menu-handle:name
              buf_tt-attr-property.upper-attr-code = ''
              buf_tt-attr-property.attr-code = substitute("&1&2&3"
                                                          , p-table-name
                                                          , tt-attr-property.edit-menu-section-num
                                                          , p-menu-handle:name
                                                          )
              .
              create menu-item buf_tt-attr-property.menu-item-handle
              assign
              subtype = "rule"
              parent = p-menu-handle
              .
            end.
          end.
       end.
     end.
     if not v-created then do:
        run attr-pop-clean-up in this-procedure ( input p-table-name).
     end.
  end.
end procedure.
procedure attr-pop-clean-up :
define input parameter p-table-name as character no-undo .
  for each tt-attr-property where
          tt-attr-property.table-name = p-table-name
    and tt-attr-property.edit-menu-section-num > 0:
    if valid-handle ( tt-attr-property.menu-item-handle) then do:
      delete widget tt-attr-property.menu-item-handle.
    end.
    delete tt-attr-property.
  end.
  for each tt-attr-property where
           tt-attr-property.table-name = p-table-name
       and tt-attr-property.edit-menu-section-num =  - 1:
    if valid-handle ( tt-attr-property.menu-item-handle) then do:
      delete widget tt-attr-property.menu-item-handle.
    end.
    delete tt-attr-property.
  end.
end procedure.
define variable updated as logical no-undo.
DEFINE VARIABLE added  as logical no-undo .
define variable add-option as char no-undo.
define variable temp-doc-rec as recid no-undo.
DEFINE MENU MENU-b-ins .
DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить атрибут типа кассового платежа".
DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить  атрибут типа кассового платежа".
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.
DEFINE BUTTON b-ins
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Добавить атрибут типа кассового платежа".
DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE 10 BY 1 TOOLTIP "Просмотр атрибута типа кассового платежа".
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1 TOOLTIP "Выход из режима".
DEFINE VARIABLE cd-cdpay-code AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "Код типа платежа"
      VIEW-AS TEXT
     SIZE 9.63 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE cd-curr-code AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Код валюты"
      VIEW-AS TEXT
     SIZE 6 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE v-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 55 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE QUERY BROWSE-2 FOR
      Temp-hattr SCROLLING.
DEFINE BROWSE BROWSE-2
  QUERY BROWSE-2 DISPLAY
      Temp-hattr.attr-code COLUMN-LABEL "Атрибут" FORMAT "X(50)":U
      get-region(temp-hattr.host-code, temp-hattr.obj-type, temp-hattr.obj-code) COLUMN-LABEL "Действует" FORMAT "X(12)":U
            WIDTH 13
      Temp-hattr.attr-value COLUMN-LABEL "Значение" FORMAT "X(45)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.33.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-ins AT ROW 1 COL 21
     b-lkp AT ROW 1 COL 31
     b-chg AT ROW 1 COL 41
     b-del AT ROW 1 COL 51
     b-help AT ROW 1 COL 71
     BROWSE-2 AT ROW 4.46 COL 1
     v-obj-name AT ROW 2 COL 2.5 NO-LABEL
     cd-cdpay-code AT ROW 3.25 COL 2.5
     cd-curr-code AT ROW 3.25 COL 33.5
     SPACE(48.24) SKIP(15.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Атрибуты типа кассового платежа".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
  if not avail temp-hattr then return no-apply.
  run proc-add-chg in this-procedure ( input no ) no-error.
  if error-status:error then return no-apply.
  RUN init-proc in this-procedure .
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo.
define variable attr-type as character no-undo .
define variable attr-format as character no-undo .
define variable attr-label as character no-undo .
define variable attr-range as integer no-undo .
define variable attr-user-can-edit as logical no-undo .
define variable attr-output-display as logical no-undo .
define variable attr-other as char no-undo .
define variable glog as logical no-undo .
DEFINE VARIABLE v-check AS CHARACTER NO-UNDO.
define variable v-correct as logical no-undo .
define variable v-error-code as character no-undo .
DEFINE VARIABLE jj AS INTEGER NO-UNDO.
  if not avail temp-hattr then return no-apply.
  run cp-attr-code (
    input  temp-hattr.code
    ,output attr-type
    ,output attr-format
    ,output attr-label
    ,output attr-range
    ,output attr-user-can-edit
    ,output attr-output-display
    ,output attr-other
    ) .
  if not attr-user-can-edit then do:
    message
    "Атрибут нельзя удалить вручную"
    view-as alert-box error .
    return no-apply.
  end.
     do jj = 1 to num-entries(attr-other, chr(47)):
    if entry(1, entry(jj, attr-other, chr(47)), "=":U) = "check":U then do:
      assign
      v-check = string(entry(2, entry(jj, attr-other, chr(47)), "=":U))
      .
    end.
  end.
  if v-check <> "":U then do:
    run value(v-check) (
                       input p-cdpay-code
                      ,input p-curr-code
                      ,input temp-hattr.code
                      ,input "0":U
                      ,input 'удаление':U
                      ,output v-correct
                      ,output v-error-code) no-error.
    if error-status:error then do:
      message
      "Ошибка при проверке корректности удаления атрибута" skip
      error-status:get-message(1) skip
      view-as alert-box error .
      undo, return no-apply .
    end.
    if not v-correct then do:
      message
      "Удаление атрибута некорректно" skip
      v-error-code
      view-as alert-box error .
      undo, return no-apply .
    end.
  end.
  glog = no.
  message
  "Вы уверены, что хотите удалить атрибут " temp-hattr.attr-code skip
  " для типа кассового платежа"
  view-as alert-box QUESTIOn buttons YES-NO update glog.
  if NOT glog then return no-apply.
    run cp-attr-delete in this-procedure(
                                    input p-cdpay-code
                                    ,input p-curr-code
                                    ,input temp-hattr.host-code
                                    ,input temp-hattr.obj-type
                                    ,input temp-hattr.obj-code
                                    ,input temp-hattr.code
                                    ,output loc#log) no-error .
    if error-status:error or not loc#log then do:
       message "Ошибка при удалении атрибута типа кассового платежа!"         "Обратитесь к администратору системы" skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
       return no-apply.
    end.
    delete temp-hattr.
    updated = yes.
    run init-proc in this-procedure .
END.
ON CHOOSE OF b-ins IN FRAME Dialog-Frame
DO:
define variable attr-type as character no-undo .
define variable attr-format as character no-undo .
define variable attr-label as character no-undo .
define variable attr-range as integer no-undo .
define variable attr-user-can-edit as logical no-undo .
define variable attr-output-display as logical no-undo .
define variable attr-other as char no-undo .
define variable loc#log as logical no-undo.
define buffer buf_temp-hattr for temp-hattr.
if add-option = "" then do:
  run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if add-option = "":U then return no-apply.
run proc-add-chg in this-procedure ( input yes) no-error .
if error-status:error then do:
  add-option = "":U.
  return no-apply.
end.
Run init-proc in this-procedure .
find first buf_temp-hattr no-lock where
                        buf_temp-hattr.code = add-option no-error.
add-option = "":U.
if avail buf_temp-hattr then
    temp-doc-rec = recid(buf_temp-hattr).
    else temp-doc-rec = ?.
reposition BROWSE-2 to recid temp-doc-rec no-error.
if error-status:error then return no-apply.
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
  IF not AVAILABLE temp-hattr then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
END.
ON MOUSE-SELECT-DBLCLICK OF BROWSE-2 IN FRAME Dialog-Frame
DO:
  IF not AVAILABLE temp-hattr then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON RETURN OF BROWSE-2 IN FRAME Dialog-Frame
DO:
  IF not AVAILABLE temp-hattr then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BROWSE-2 :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
 frame Dialog-Frame:TITLE = frame Dialog-Frame:TITLE.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  RUN MyEnable in this-procedure no-error.
  if error-status:error then return error.
  Run init-proc in this-procedure .
  view frame Dialog-Frame .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI in this-procedure .
run attr-pop-clean-up in this-procedure ( input 'cash-pay-attr':U ).
if updated then return 'ИЗМЕНЕНИЕ':U.
PROCEDURE choose-to-edit :
define input parameter p-attr-code as character no-undo .
assign
add-option = p-attr-code
.
APPLY "CHOOSE" to b-ins in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-obj-name cd-cdpay-code cd-curr-code
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-ins b-lkp b-chg b-del b-help v-obj-name cd-cdpay-code
         cd-curr-code
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-2 FOR EACH Temp-hattr NO-LOCK.
END PROCEDURE.
PROCEDURE init-proc :
define var  attr-type as character no-undo .
define var  attr-format as character no-undo .
define var  attr-label as character no-undo .
define var  attr-value as character no-undo .
define var  attr-range as integer no-undo .
define var  attr-user-can-edit as logical no-undo .
define var  attr-output-display as logical no-undo .
define var  attr-other as char no-undo .
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_cash-pay-attr for ub.cash-pay-attr.
for each  Temp-hattr share-lock: delete Temp-hattr. end.
add-option = "".
find first buf_cash-pay where buf_cash-pay.cdpay-code =  p-cdpay-code
                   AND buf_cash-pay.curr-code = p-curr-code
                        no-lock no-error .
Assign
    cd-cdpay-code = buf_cash-pay.cdpay-code
    cd-curr-code = buf_cash-pay.curr-code
    .
display cd-cdpay-code cd-curr-code
  with frame Dialog-Frame  .
   For each buf_cash-pay-attr where
            buf_cash-pay-attr.cdpay-code  = p-cdpay-code
       and  buf_cash-pay-attr.curr-code  = p-curr-code
            no-lock :
          run cp-attr-code in this-procedure (
                                              input buf_cash-pay-attr.attr-code
                                              ,output attr-type
                                              ,output attr-format
                                              ,output attr-label
                                              ,output attr-range
                                              ,output attr-user-can-edit
                                              ,output attr-output-display
                                              ,output attr-other ).
          if attr-output-display = true then DO:
              run cp-attr-value in this-procedure (
                                                  input buf_cash-pay-attr.cdpay-code
                                                  ,input buf_cash-pay-attr.curr-code
                                                  ,input buf_cash-pay-attr.host-code
                                                  ,input buf_cash-pay-attr.obj-type
                                                  ,input buf_cash-pay-attr.obj-code
                                                  ,input buf_cash-pay-attr.attr-code
                                                  ,output attr-value
                                                  ,output attr-type ).
              create Temp-hattr.
              assign
              Temp-hattr.attr-code = attr-label
              Temp-hattr.value_ = buf_cash-pay-attr.attr-value
              Temp-hattr.attr-value = (if attr-type = 'L':U
                                      then string(attr-value = "yes":U, attr-format)
                                      else attr-value)
              Temp-hattr.user-can-edit = attr-user-can-edit
              Temp-hattr.code = buf_cash-pay-attr.attr-code
              temp-hattr.host-code = buf_cash-pay-attr.host-code
              temp-hattr.obj-type = buf_cash-pay-attr.obj-type
              temp-hattr.obj-code = buf_cash-pay-attr.obj-code
              .
      End.
    End.
    OPEN QUERY BROWSE-2 FOR EACH Temp-hattr NO-LOCK.
END PROCEDURE.
PROCEDURE MyEnable :
define var  attr-type as character no-undo .
define var  attr-format as character no-undo .
define var  attr-label as character no-undo .
define var  attr-value as character no-undo .
define variable attr-range as integer no-undo .
define var  attr-user-can-edit as logical no-undo .
define var  attr-output-display as logical no-undo .
define var  attr-other as char no-undo .
define variable v-version as decimal no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-cd as character no-undo .
define variable v-cd-list as character no-undo .
DEFINE BUFFER buf_Cash-pay FOR ub.cash-pay.
ASSIGN
b-ins:POPUP-MENU IN FRAME Dialog-Frame  = MENU MENU-b-ins:HANDLE
b-ins:MENU-MOUSE = 1
Temp-hattr.attr-value:width in browse browse-2 = 45
Temp-hattr.attr-value:resizable in browse browse-2 = yes
.
if p-mode <> 'ПРОСМОТР':U then do:
  run attr-pop-create-items in this-procedure  (
                                                 input 'cash-pay-attr':U
                                                ,input 'cp-attr-manual-edit'
                                                ,input 'cp-attr-tooltip'
                                                ,input 'choose-to-edit'
                                                ,input menu menu-b-ins:handle
                                                ,input 'paycard-export-prefix,grp-code,is-use,dop-doc,paycard-all-prefix,paycard-edit-prefix,form_km3,bal_malina,max_proc_sum,mask_card_kup':u
                                              ).
end.
FIND FIRST buf_Cash-pay NO-LOCK WHERE
            buf_Cash-pay.cdpay-code = p-cdpay-code
      AND   buf_Cash-pay.curr-code = p-curr-code NO-ERROR.
IF AVAILABLE buf_cash-pay THEN DO:
    ASSIGN
    v-obj-name = buf_cash-pay.obj-name.
END.
ASSIGN b-ins:MENU-MOUSE in frame Dialog-Frame  = 1.
DISPLAY
v-obj-name
WITH FRAME Dialog-Frame .
ENABLE
b-quit
b-del when p-mode = 'ИЗМЕНЕНИЕ':U
b-ins when p-mode = 'ИЗМЕНЕНИЕ':U
b-chg when p-mode = 'ИЗМЕНЕНИЕ':U
b-lkp
b-help BROWSE-2
WITH FRAME Dialog-Frame .
VIEW FRAME Dialog-Frame .
OPEN QUERY BROWSE-2 FOR EACH Temp-hattr NO-LOCK.
END PROCEDURE.
PROCEDURE proc-add-chg :
define input parameter p-add as logical no-undo .
define variable attr-type as character no-undo .
define variable attr-format as character no-undo .
define variable attr-label as character no-undo .
define variable attr-range as integer no-undo .
define variable attr-user-can-edit as logical no-undo .
define variable attr-output-display as logical no-undo .
define variable attr-other as char no-undo .
define variable attr-value as character no-undo .
define variable v-attr-value as character no-undo .
define variable v-init as character no-undo .
define variable jj as integer no-undo.
DEFINE VARIABLE v-spr as character no-undo .
define variable v-spr-param as character no-undo .
DEFINE VARIABLE v-setted as logical no-undo .
DEFINE VARIABLE v-deleted as logical no-undo .
define variable v-check as character no-undo .
define variable v-error-code as character no-undo .
define variable v-correct as logical no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-obj-type like ub.clients.obj-type no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-ask-labels as character no-undo .
define variable choice as integer no-undo .
define var loc#log as logical no-undo.
case p-add:
  when yes then do:
    run cp-attr-code in this-procedure (
                                          input  add-option
                                          ,output attr-type
                                          ,output attr-format
                                          ,output attr-label
                                          ,output attr-range
                                          ,output attr-user-can-edit
                                          ,output attr-output-display
                                          ,output attr-other
                                          ) no-error .
    if error-status :error then do:
      return error .
    end.
    assign
    added = yes.
    CASE attr-range:
      when integer('0':U) then do:
        assign
        v-ask-labels = "Глобально"
        v-host-code = 0
        v-obj-type = '':U
        v-obj-code = 0
        .
      end.
      when integer('1':U) then do:
        assign
        v-ask-labels = substitute("Глобально|Фирма &1", p-host-code)
        v-host-code = 0
        v-obj-type = '':U
        v-obj-code = 0
        .
      end.
      when integer('2':U) then do:
        assign
        v-ask-labels = substitute("&1&2", p-obj-type, p-obj-code)
        v-host-code = p-host-code
        v-obj-type = p-obj-type
        v-obj-code = p-obj-code
        .
      end.
      when integer('4':U) then do:
        assign
        v-ask-labels = substitute("Глобально|Фирма &1|&2&3", p-host-code, p-obj-type, p-obj-code)
        v-host-code = 0
        v-obj-type = '':U
        v-obj-code = 0
        .
      end.
    END CASE.
    if num-entries(v-ask-labels, "|") > 1 then do:
      run gbl/d-askw.w (
                          input "Область действия атрибута"
                          ,input "Выберите область действия атрибута"
                          ,input "|"
                          ,input (v-ask-labels + "|Отменить")
                          ,input fill("|", num-entries(v-ask-labels, "|"))
                          ,input 1
                          ,input num-entries(v-ask-labels, "|") + 1
                          ,output choice).
      if choice = num-entries(v-ask-labels, "|") + 1 then do:
        undo, return error .
      end.
    end.
    CASE choice:
      when 1 then do:
      end.
      when 2 then do:
        if v-host-code <> 0
        then do:
          assign
          v-obj-type  = p-obj-type
          v-obj-code  = p-obj-code
          .
        end.
        if num-entries(v-ask-labels, "|") = 3    then do:
          assign
          v-host-code = p-host-code
          .
        end.
      end.
      when 3 then do:
        assign
        v-host-code = p-host-code
        v-obj-type  = p-obj-type
        v-obj-code  = p-obj-code
        .
      end.
    END CASE.
    if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
      run temp-cp-attr-exist in this-procedure (
                                                input p-cdpay-code
                                                ,input p-curr-code
                                                ,input v-host-code
                                                ,input v-obj-type
                                                ,input v-obj-code
                                                ,input add-option
                                                ,output loc#log)  no-error.
      if error-status:error then return error.
      if loc#log then do:
        message
        "Данный атрибут уже существует"
        view-as alert-box error .
        return error.
      end.
    end.
    do jj = 1 to num-entries(attr-other, chr(47)):
      if entry(1, entry(jj, attr-other, chr(47)), "=":U) = "init":U then do:
        assign
        v-init = string(entry(2, entry(jj, attr-other, chr(47)), "=":U))
        .
      end.
    end.
    if  v-init <> "":U then do:
        run  value(v-init)
                    in this-procedure (
                                          input p-cdpay-code
                                        , input p-curr-code
                                        , input v-host-code
                                        , input v-obj-type
                                        , input v-obj-code
                                        , output attr-value) no-error .
          if error-status:error then do:
              assign
              attr-value = "":U
              .
          end.
    end.
    CASE attr-type:
      when 'L':U then do:
        assign
        v-attr-value = "yes":U
        .
      end.
      when 'I':U or when 'D':U then do:
        assign
        v-attr-value = if v-init <> "":U
                      then attr-value
                      else string(0)
        .
      end.
      when 'T':U then do:
        assign
        v-attr-value = ?
        .
      end.
      when 'C':U then do:
        assign
        v-attr-value = if v-init <> "":U
                      then attr-value
                      else "":U
        .
      end.
    END CASE.
    assign
    attr-value = v-attr-value
    .
  end.
  when no then do:
    run cp-attr-code in this-procedure (
                                          input TEMP-hattr.code
                                          ,output attr-type
                                          ,output attr-format
                                          ,output attr-label
                                          ,output attr-range
                                          ,output attr-user-can-edit
                                          ,output attr-output-display
                                          ,output attr-other) no-error.
    IF ERROR-STATUS:ERROR THEN DO:
        message "Ошибка при определении названия и типа атрибута типа кассового платежа!"         "Обратитесь к администратору системы" skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
        return error.
    END.
    RUN cp-attr-VALUE IN THIS-PROCEDURE (
                                         INPUT p-cdpay-code
                                         ,INPUT p-curr-code
                                         ,input TEMP-hattr.host-code
                                         ,input TEMP-hattr.obj-type
                                         ,input TEMP-hattr.obj-code
                                         ,input TEMP-hattr.code
                                         ,OUTPUT ATTR-VALUE
                                         ,OUTPUT attr-type) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        message "Ошибка при определении значения атрибута типа кассового платежа!"         "Обратитесь к администратору системы" skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
        return error.
    END.
  end.
END CASE.
IF attr-user-can-edit Then DO:
  do jj = 1 to num-entries(attr-other, chr(47)):
    if entry(1, entry(jj, attr-other, chr(47)), "=":U) = "spr":U then do:
      assign
      v-spr = string(entry(2, entry(jj, attr-other, chr(47)), "=":U))
      .
    end.
    if entry(1, entry(jj, attr-other, chr(47)), "=":U) = "spr-param":U then do:
      assign
      v-spr-param = string(entry(2, entry(jj, attr-other, chr(47)), "=":U))
      .
    end.
    if entry(1, entry(jj, attr-other, chr(47)), "=":U) = "check":U then do:
      assign
      v-check = string(entry(2, entry(jj, attr-other, chr(47)), "=":U))
      .
    end.
  end.
  if v-spr = "":U then do:
    run gbl/d-prompt.w (
      'title=':u + "Изменение атрибута типа кассового платежа" + '\':u
    + 'text1=':u + attr-label + '\':u
    + 'format=' + (if attr-type = 'L':U then "yes/no" else attr-format) + '\':u
    + 'type=' + attr-type + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u
    + 'readonly=' + (if p-mode <> 'ИЗМЕНЕНИЕ':U then 'yes':u else 'no':u) + '\':u
    , input-output attr-value
        ).
    if return-value = 'false':u then return error.
  END.
  ELSE DO:
    if v-spr-param = "":U then do:
      run  value(v-spr)
                  in this-procedure (
                                       input p-cdpay-code
                                      ,input p-curr-code
                                      ,input (if p-add then v-host-code else temp-hattr.host-code)
                                      ,input (if p-add then v-obj-type else temp-hattr.obj-type)
                                      ,input (if p-add then v-obj-code else temp-hattr.obj-code)
                                      ,input-output attr-value
                                      ,output v-setted) no-error .
    end.
    else do:
      run  value( v-spr )  in this-procedure (
                                              input p-cdpay-code
                                              ,input p-curr-code
                                              ,input (if p-add then v-host-code else temp-hattr.host-code)
                                              ,input (if p-add then v-obj-type else temp-hattr.obj-type)
                                              ,input (if p-add then v-obj-code else temp-hattr.obj-code)
                                              ,input v-spr-param
                                              ,input-output attr-value
                                              ,output v-setted) no-error .
    end.
    if not v-setted then return error.
  end.
  if v-check <> "":U then do:
    run value(v-check) in this-procedure (
                                          input p-cdpay-code
                                          ,input p-curr-code
                                          ,input (if p-add = yes then add-option else temp-hattr.attr-code)
                                          ,input attr-value
                                          ,input (if p-add then 'ДОБАВЛЕНИЕ':U else 'ИЗМЕНЕНИЕ':U)
                                          ,output v-correct
                                          ,output v-error-code) no-error.
    if error-status:error then do:
      message
      "Ошибка при проверке корректности задаваемого значения атрибута" skip
      error-status:get-message(1) skip
      view-as alert-box error .
      undo, return error .
    end.
    if not v-correct then do:
      message
      "Задание атрибута некорректно" skip
      v-error-code
      view-as alert-box error .
      undo, return error .
    end.
  end.
  run cp-attr-write in this-procedure (
                                        input p-cdpay-code
                                        ,input p-curr-code
                                        ,input (if p-add then v-host-code else temp-hattr.host-code)
                                        ,input (if p-add then v-obj-type else temp-hattr.obj-type)
                                        ,input (if p-add then v-obj-code else temp-hattr.obj-code)
                                        ,input (if p-add then add-option else temp-hattr.code)
                                        ,input attr-value
                                      ) no-error .
  IF NOT error-status:error then do:
      assign
      updated = yes
      .
  END.
  else do:
      message "Ошибка при изменении значения атрибута типа кассового платежа!"         "Обратитесь к администратору системы" skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
  end.
End.
Else message "Изменение атрибута невозможно !" view-as alert-box error.
END PROCEDURE.
PROCEDURE proc-b-lkp :
define variable attr-type as character no-undo .
define variable attr-format as character no-undo .
define variable attr-label as character no-undo .
define variable attr-user-can-edit as logical no-undo .
define variable attr-output-display as logical no-undo .
define variable attr-other as char no-undo .
define variable attr-value as char no-undo .
define variable attr-range as integer no-undo .
define variable v-run-name as character no-undo .
define variable jj as integer no-undo .
  run cp-attr-code in this-procedure (
                       input temp-hattr.code
                      ,output attr-type
                      ,output attr-format
                      ,output attr-label
                      ,output attr-range
                      ,output attr-user-can-edit
                      ,output attr-output-display
                      ,output attr-other ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
    return error.
END.
do jj = 1 to num-entries(attr-other, chr(47)):
  if entry(1, entry(jj, attr-other, chr(47)), "=":U) = "display" then do:
    v-run-name = entry(2, entry(jj, attr-other, chr(47)), "=":U).
    run value(v-run-name) in this-procedure (
                                             input p-cdpay-code
                                            ,INPUT p-curr-code
                                            ,input temp-hattr.code
                                            ,input temp-hattr.attr-value
                                            ,input p-host-code
                                            ,input p-obj-type
                                            ,input p-obj-code
                                             )
                                             no-error .
    if error-status:error then undo, return error .
    return .
  end.
END.
message
"Расширенный просмотр ДАННОГО атрибута НЕ ПРЕДУСМОТРЕН!"
view-as alert-box Warning.
BELL.
END PROCEDURE.
PROCEDURE temp-cp-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_temp-hattr for temp-hattr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-version        as decimal   no-undo .
    run cp-attr-code in this-procedure (
                                        input  p-code
                                        ,output v-type
                                        ,output v-format
                                        ,output v-label
                                        ,output v-range
                                        ,output v-user-can-edit
                                        ,output v-output-display
                                        ,output v-other
                                        ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_temp-hattr exclusive-lock
      where buf_temp-hattr.cdpay-code = p-cdpay-code
        and buf_temp-hattr.curr-code  = p-curr-code
        and buf_temp-hattr.host-code  = p-host-code
        and buf_temp-hattr.obj-type   = (if v-version = 14.0 then '':U else p-obj-type)
        and (v-version = 14.0 or buf_temp-hattr.obj-code   = p-obj-code)
        and buf_temp-hattr.attr-code = p-code
      no-error .
    if  available buf_temp-hattr then do:
      p-exist = yes.
    end.
  end.
END PROCEDURE.
