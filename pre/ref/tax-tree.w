DEFINE TEMP-TABLE tt-tax-rate-value NO-UNDO LIKE ub.tax-rate-value
       field rc as recid
       field exp as logical
       index pi is unique primary
       tax-code
       rate-code
       host-code
       obj-type
       obj-code
       fact-order
       index irc is unique
       rc.
define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER BTTNS AS CHAR NO-UNDO.
DEFINE INPUT PARAMETER ref-mode AS CHAR No-UNDO.
DEFINE INPUT PARAMETER parhost-code like ub.sysconf.host-code No-UNDO.
DEFINE INPUT PARAMETER  parobj-type like ub.clients.obj-type No-UNDO.
DEFINE INPUT PARAMETER  parobj-code like ub.clients.obj-code No-UNDO.
DEFINE INPUT PARAMETER rid# As recid NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-tax-rate-rid As char NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник видов налогов" .
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
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable ri as recid no-undo.
define variable unittype like ub.units.type.
define variable var-rc as recid no-undo.
define variable add-tax-rate-value-option as character no-undo.
define variable var-tax-code like ub.tax.tax-code no-undo.
define variable var-ismarked as logical no-undo.
define variable v-tax-rate-rid as character no-undo .
define variable glog as logical no-undo .
FUNCTION get-marktax-rate RETURNS CHARACTER
  ( input par-ismarked as logical, input par-rid as recid, input par-tax-rate-rid as character)  FORWARD.
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer )  FORWARD.
FUNCTION get-types RETURNS CHARACTER
  ( input partax-code as integer )  FORWARD.
FUNCTION get-envd RETURNS CHARACTER
  ( input i-tax-code as integer, i-rate-code as integer)  FORWARD.
DEFINE MENU MENU-B-addtax-rate-value
       MENU-ITEM m_global       LABEL "Глобальная"
       MENU-ITEM m_host         LABEL "Фирма"
       MENU-ITEM m_object       LABEL "Объект"        .
DEFINE BUTTON B-addtax
     LABEL "Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-addtax-rate
     LABEL "Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-addtax-rate-value
     LABEL "Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-chgtax
     LABEL "Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-chgtax-rate
     LABEL "Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-deltax
     LABEL "Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-deltax-rate
     LABEL "Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-deltax-rate-value
     LABEL "Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-ext
     LABEL ">>"
     SIZE 4 BY 1.
DEFINE BUTTON B-gdstax-rate
     LABEL "Товары"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-histtax-rate
     IMAGE FILE "cmp/b-hist.bmp":U
     LABEL "История"
     SIZE 3 BY 1.
DEFINE BUTTON B-histtax-rate-value
     IMAGE FILE "cmp/b-hist.bmp":U
     LABEL "История"
     SIZE 3 BY 1.
DEFINE BUTTON B-marktax-rate
     LABEL "*"
     SIZE 3 BY 1.
DEFINE BUTTON B-overvalue-rate-value
     LABEL "ДНЦ"
     tooltip "Создать ДНЦ для объектов по товарам сменившим ставку"
     SIZE 10 BY 1.
DEFINE BUTTON B-seltax AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1.
DEFINE BUTTON B-seltax-rate AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1.
DEFINE BUTTON B-taxgds
     LABEL "Товары"
     SIZE 10 BY 1.
DEFINE BUTTON B-taxhist
     IMAGE FILE "cmp/b-hist.bmp":U
     LABEL "История"
     SIZE 3 BY 1.
DEFINE VARIABLE br-tax-rate-name AS CHARACTER FORMAT "X(256)":U INITIAL "Ставки по всем налогам"
      VIEW-AS TEXT
     SIZE 42.25 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE br-tax-rate-value-name AS CHARACTER FORMAT "X(256)":U INITIAL "Значения ставок"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE mark-numtax-rate AS INTEGER FORMAT ">>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 13.5 BY .67
     FGCOLOR 10  NO-UNDO.
DEFINE VARIABLE RS-date AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущие дата/статус", 1,
"Все", 0
     SIZE 29.25 BY .79 NO-UNDO.
DEFINE QUERY BR-tax-rate FOR
      ub.tax-rate SCROLLING.
DEFINE QUERY BR-tax-rate-value FOR
      tt-tax-rate-value SCROLLING.
DEFINE QUERY BR-taxes FOR
      ub.tax SCROLLING.
DEFINE BROWSE BR-tax-rate
  QUERY BR-tax-rate DISPLAY
      get-marktax-rate(var-ismarked, recid(tax-rate), v-tax-rate-rid ) FORMAT "X(1)"
      tax-rate.tax-code
      tax-rate.rate-code
      tax-rate.rate-name FORMAT "X(20)"
      tax-rate.status_
      get-envd(tax-rate.tax-code, tax-rate.rate-code) COLUMN-LABEL "без НДС" FORMAT "X(1)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 43 BY 10.67.
DEFINE BROWSE BR-tax-rate-value
  QUERY BR-tax-rate-value DISPLAY
      if tt-tax-rate-value.rc = var-rc then "*" else "" FORMAT "X(1)"
      tt-tax-rate-value.rate-value
      get-region(tt-tax-rate-value.host-code, tt-tax-rate-value.obj-type, tt-tax-rate-value.obj-code) COLUMN-LABEL "Область!действия" FORMAT "X(14)"
      tt-tax-rate-value.fact-date
      tt-tax-rate-value.status_
    WITH NO-ROW-MARKERS SEPARATORS SIZE 54.5 BY 10.63.
DEFINE BROWSE BR-taxes
  QUERY BR-taxes DISPLAY
      tax.tax-code
      tax.tax-name
      tax.to-cashdesk COLUMN-LABEL "На!кассу" FORMAT "+/"
      (IF (ub.tax.tax-type = "" ) THEN ("") ELSE (entry (lookup (tax.tax-type, '%,abs':U), 'процентный,абсолютный':U))) COLUMN-LABEL "Тип" FORMAT "x(10)"
      tax.individual COLUMN-LABEL "Инд." FORMAT "+/"
      tax.status_ FORMAT "X(12)"
      get-types(tax.tax-code) COLUMN-LABEL "Типы товаров" FORMAT "X(40)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6.25.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13
     B-seltax AT ROW 1 COL 20
     B-addtax AT ROW 1 COL 30
     B-chgtax AT ROW 1 COL 40
     B-deltax AT ROW 1 COL 50
     B-taxgds AT ROW 1 COL 60
     B-taxhist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     BR-taxes AT ROW 2.17 COL 1.25
     RS-date AT ROW 9.29 COL 45.75 NO-LABEL
     B-seltax-rate AT ROW 9.33 COL 1
     B-marktax-rate AT ROW 9.33 COL 11
     B-addtax-rate AT ROW 9.33 COL 14
     B-chgtax-rate AT ROW 9.33 COL 24
     B-deltax-rate AT ROW 9.33 COL 34
     B-addtax-rate-value AT ROW 9.33 COL 77
     B-deltax-rate-value AT ROW 9.33 COL 87
     B-gdstax-rate AT ROW 10.33 COL 24
     B-histtax-rate AT ROW 10.33 COL 34
     B-ext AT ROW 10.33 COL 45
     B-overvalue-rate-value AT ROW 10.33 COL 77
     B-histtax-rate-value AT ROW 10.33 COL 87
     BR-tax-rate AT ROW 11.58 COL 1
     BR-tax-rate-value AT ROW 11.58 COL 44.75
     br-tax-rate-name AT ROW 8.54 COL 1.5 NO-LABEL
     br-tax-rate-value-name AT ROW 8.58 COL 45.63 NO-LABEL
     mark-numtax-rate AT ROW 10.67 COL 4.5 NO-LABEL
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Налоги"
         DEFAULT-BUTTON B-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-addtax-rate-value:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-addtax-rate-value:HANDLE.
ASSIGN
       B-deltax:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-taxgds:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-taxhist:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-addtax IN FRAME Dialog-Frame
DO:
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_tax-kinds_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if NOT glog then return no-apply .
    ri = ?.
    run ref/taxesi.w ( 'ДОБАВЛЕНИЕ':U, input-output ri ).
    if ri <> ? then do:
        OPEN QUERY br-taxes FOR EACH ub.tax NO-LOCK.
        reposition br-taxes to recid ri.
        apply "ENTRY" to br-taxes.
    end.
END.
ON CHOOSE OF B-addtax-rate IN FRAME Dialog-Frame
DO:
   if ref-mode = "ALL-TAX-RATES":U then return no-apply.
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_tax-rates_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if NOT glog then return no-apply .
    if not avail ub.tax then return no-apply.
    if ub.tax.individual = yes then do:
      message "Нельзя добавить ставки к индивидуальному налогу"
      view-as alert-box ERROR.
      return no-apply.
    end.
    ri = recid(tax).
    run ref/taxratei.w ( 'ДОБАВЛЕНИЕ':U, input-output ri ).
    if ri <> ? then  do:
        run OpenBr-tax-rate.
        reposition br-tax-rate to recid ri no-error.
        apply "ENTRY" to br-tax-rate.
        apply "VALUE-CHANGED" to br-tax-rate.
    end.
END.
ON CHOOSE OF B-addtax-rate-value IN FRAME Dialog-Frame
DO:
  if add-tax-rate-value-option = "":U then do:
    run gbl/pop-up.p (self:handle, no) no-error.
    if error-status:error then return no-apply.
  end.
  if add-tax-rate-value-option = "":U then return no-apply.
  run proc-b-addtax-rate-value in this-procedure (add-tax-rate-value-option, RS-date) no-error   .
  if error-status:error then do:
    add-tax-rate-value-option = "":U.
     return no-apply.
  end.
END.
ON CHOOSE OF B-chgtax IN FRAME Dialog-Frame
DO:
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_tax-kinds_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if NOT glog then return no-apply .
    If available ub.tax then do:
        ri = recid( ub.TAX ) .
        run ref/taxesi.w ( 'ИЗМЕНЕНИЕ':U, input-output ri ).
        OPEN QUERY br-taxes FOR EACH ub.tax NO-LOCK.
        reposition br-taxes to recid ri no-error.
        apply "ENTRY" to br-taxes.
    end.
END.
ON CHOOSE OF B-chgtax-rate IN FRAME Dialog-Frame
DO:
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_tax-rates_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
   if NOT glog then return no-apply .
   If available ub.tax-rate then do:
    ri = recid( ub.TAX-rate ) .
    run ref/taxratei.w ( 'ИЗМЕНЕНИЕ':U, input-output ri ).
    RUn OpenBr.
    reposition br-tax-rate to recid ri NO-ERROR.
    apply "ENTRY" to br-tax-rate.
    apply "VALUE-CHANGED" to br-tax-rate.
   end.
END.
ON CHOOSE OF B-deltax IN FRAME Dialog-Frame
DO:
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_tax-kinds_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if NOT glog then return no-apply .
    run ref/tax-tr01.p (input recid(ub.tax)) no-error.
        if error-status:error then return no-apply.
     glog = browse br-taxes:refresh().
    apply "ENTRY" to br-taxes.
END.
ON CHOOSE OF B-deltax-rate IN FRAME Dialog-Frame
DO:
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_tax-rates_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
   if NOT glog then return no-apply .
   If available ub.tax-rate then do:
    ri = recid( ub.TAX-rate ) .
    run ref/taxrati2.p ( input ri ).
    RUn OpenBr-tax-rate.
    reposition br-tax-rate to recid ri NO-ERROR.
    apply "ENTRY" to br-tax-rate.
    APPLY "Value-changed" to br-tax-rate.
   end.
END.
ON CHOOSE OF B-deltax-rate-value IN FRAME Dialog-Frame
DO:
  define var tt-ri as recid no-undo.
    if not avail tt-tax-rate-value then return no-apply.
    if tt-tax-rate-value.obj-code <> 0
    then do:
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_tax-rate-values_object-update':U
    ,input  'object':U
    ,input  tt-tax-rate-value.host-code
    ,input  tt-tax-rate-value.obj-type
    ,input  tt-tax-rate-value.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    end.
    else do:
      if tt-tax-rate-value.host-code <> 0
      then do:
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_tax-rate-values_firm-update':U
    ,input  'firm':U
    ,input  tt-tax-rate-value.host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
      end.
      else do:
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_tax-rate-values_global-update':U
    ,input  'firm':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
      end.
    end.
  if NOT glog then return no-apply .
  if tt-tax-rate-value.host-code <> 0 and parhost-code <> tt-tax-rate-value.host-code then return no-apply.
  If available ub.tax-rate then do:
    assign
    tt-ri = recid(tt-tax-rate-value)
    ri = tt-TAX-rate-value.rc
       .
    run ref/taxvali2.p ( input ri
                        ,input no
                          ).
    RUn OpenBr-tax-rate-value(rs-date).
    reposition br-tax-rate-value to recid tt-ri NO-ERROR.
    apply "ENTRY" to br-tax-rate-value.
   end.
END.
ON CHOOSE OF B-ext IN FRAME Dialog-Frame
DO:
  if not avail tt-tax-rate-value then RETURN NO-APPLY.
  RUN proc-b-ext(var-rc, Rs-date) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-gdstax-rate IN FRAME Dialog-Frame
DO:
define variable v-list-mode as character no-undo .
define variable v-rid-list as character no-undo .
  if avail ub.tax-rate then do:
    v-list-mode = "TAX-RATE".
    run ref/taxgdss.w (  input parparentproc
                    ,input ''
                    ,input v-list-mode
                    ,input ub.tax-rate.tax-code
                    ,input ub.tax-rate.rate-code
                    ,input-output v-rid-list ).
 end.
END.
ON CHOOSE OF B-histtax-rate IN FRAME Dialog-Frame
DO:
define variable rid-list as character no-undo .
    if available ub.tax-rate THEN
    run ref/ctaxhist.w (
                     input parparentproc
                    ,INPUT "":U
                    ,INPUT "tax-rate":U
                    ,OUTPUT rid-list
                    ,INPUT ub.tax-rate.tax-code
                    ,INPUT ub.tax-rate.rate-code
                    ,input "":U
       ) .
    apply "entry" to br-tax-rate.
END.
ON CHOOSE OF B-histtax-rate-value IN FRAME Dialog-Frame
DO:
define variable rid-list as character no-undo .
    if available tt-tax-rate-value THEN
    run ref/ctaxhist.w (
                     input parparentproc
                    ,INPUT "":U
                    ,INPUT "tax-rate-value":U
                    ,OUTPUT rid-list
                    ,INPUT tt-tax-rate-value.tax-code
                    ,INPUT tt-tax-rate-value.rate-code
                    ,input "":U
       ) .
    apply "entry" to br-tax-rate-value.
END.
ON CHOOSE OF B-marktax-rate IN FRAME Dialog-Frame
DO:
  if available ub.tax-rate then do:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid15 as character no-undo .
define variable v-num-entry15 as integer   no-undo .
assign
  v-str-recid15 = trim( string( recid( ub.tax-rate ) , "->>>>>>>>>>>9":U ) )
  v-num-entry15 = lookup( v-str-recid15 , v-tax-rate-rid )
.
if v-num-entry15 > 0 then do:
  assign
    entry( v-num-entry15, v-tax-rate-rid ) = "":U
    v-tax-rate-rid = trim( replace( v-tax-rate-rid , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-tax-rate-rid = v-tax-rate-rid + ( if v-tax-rate-rid = "":U then "":U else chr(44) ) + v-str-recid15
  .
end.
    glog = br-tax-rate:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then  do:
      glog = br-tax-rate:select-next-row ().
      apply "Value-changed" to br-tax-rate in frame Dialog-Frame.
    end.
    if num-entries( v-tax-rate-rid ) = 0
    then
    hide mark-numtax-rate in frame Dialog-Frame.
    else
    disp num-entries( v-tax-rate-rid ) @ mark-numtax-rate with frame Dialog-Frame.
  end.
  apply "entry" to br-tax-rate in frame Dialog-Frame.
END.
ON CHOOSE OF B-overvalue-rate-value IN FRAME Dialog-Frame
DO:
    if available tt-tax-rate-value THEN
    run ref/tax-ovr.w ( input parparentproc, input tt-tax-rate-value.rc ) .
    apply "entry" to br-tax-rate-value.
END.
ON CHOOSE OF B-seltax IN FRAME Dialog-Frame
DO:
    if available ub.tax then do:
       rid# = recid( ub.tax).
       apply  "GO" to FRAME Dialog-Frame.
    end.
END.
ON CHOOSE OF B-seltax-rate IN FRAME Dialog-Frame
DO:
    if (( available ub.tax-rate ) AND ( v-tax-rate-rid = "" )) OR
               b-marktax-rate:sensitive = no then do:
        v-tax-rate-rid = string( recid( ub.tax-rate ) ) .
    end.
    br-tax-rate:refresh().
    RUn OpenBR-tax-rate-value in this-procedure (RS-date) no-error .
    p-tax-rate-rid = v-tax-rate-rid.
END.
ON CHOOSE OF B-taxgds IN FRAME Dialog-Frame
DO:
define variable v-list-mode as character no-undo .
define variable v-rid-list as character no-undo .
 if avail ub.tax then do:
    if ub.tax.individual then dO:
      run ref/taxigds.w ( input parparentproc
                         ,input ''
                         ,input "TAX"
                         ,input ub.tax.tax-code
                         ,input-output v-rid-list ) no-error.
    end.
    else do:
      run ref/taxgdss.w ( input parparentproc
                   , input ''
                   , input "TAX"
                   , input ub.tax.tax-code
                   , input 0
                   , input-output v-rid-list ).
    end.
 end.
END.
ON CHOOSE OF B-taxhist IN FRAME Dialog-Frame
DO:
define variable rid-list as character no-undo .
    if available ub.tax THEN do:
      run ref/ctaxhist.w (
                       input parparentproc
                      ,INPUT "":U
                      ,INPUT "tax":U
                      ,OUTPUT rid-list
                      ,INPUT ub.tax.tax-code
                      ,INPUT 0
                      ,input "":U
        ) .
     end.
    apply "entry" to br-taxes.
END.
ON INSERT-MODE OF BR-tax-rate IN FRAME Dialog-Frame
DO:
   IF b-marktax-rate:sensitive then do:
    APPLY "CHOOSE" to b-marktax-rate.
  end.
END.
ON RETURN OF BR-tax-rate IN FRAME Dialog-Frame
DO:
  if not ref-mode = "ALL-TAX-RATES":U then do:
  return no-apply.
  end.
END.
ON VALUE-CHANGED OF BR-tax-rate IN FRAME Dialog-Frame
DO:
  Run OpenBR-tax-rate-value(rs-date).
END.
ON MOUSE-SELECT-DBLCLICK OF BR-tax-rate-value IN FRAME Dialog-Frame
DO:
  APPLY "CHOOSE" to b-ext.
  return no-apply.
END.
ON VALUE-CHANGED OF BR-taxes IN FRAME Dialog-Frame
DO:
  if not avail ub.tax then return no-apply.
  if ref-mode <> "ALL-TAX-RATES":U then
  run OpenBr-tax-rate.
END.
ON CHOOSE OF MENU-ITEM m_global
DO:
  add-tax-rate-value-option = "GLOBAL":U.
  run proc-b-addtax-rate-value in this-procedure(add-tax-rate-value-option, RS-date) No-ERROR.
  if error-status:error then do:
    add-tax-rate-value-option = "":U.
    return no-apply.
  end.
END.
ON CHOOSE OF MENU-ITEM m_host
DO:
  add-tax-rate-value-option = "HOST":U.
  run proc-b-addtax-rate-value in this-procedure(add-tax-rate-value-option, rs-date) No-ERROR.
  if error-status:error then do:
    add-tax-rate-value-option = "":U.
    return no-apply.
  end.
END.
ON CHOOSE OF MENU-ITEM m_object
DO:
  add-tax-rate-value-option = "OBJECT":U.
  run proc-b-addtax-rate-value in this-procedure(add-tax-rate-value-option, rs-date) No-ERROR.
  if error-status:error then do:
    add-tax-rate-value-option = "":U.
    return no-apply.
  end.
END.
ON VALUE-CHANGED OF RS-date IN FRAME Dialog-Frame
DO:
  assign rs-date.
  run OpenBr-tax-rate-value (rs-date).
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-tax-rate :handle
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
run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse br-taxes :handle
  ) .
run diasize_add_browse in this-procedure
  (input  'height':u
  ,input  browse BR-tax-rate-value :handle
  ) .
run diasize_init in this-procedure .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if ref-mode = "ALL-TAX-RATES" then do:
      if rid# <> ? then do:
        find first tax no-lock where
                            recid(tax) = rid# No-ERROR.
        if not avail tax then return error.
        var-tax-code = tax.tax-code.
     end.
  end.
  assign
  v-tax-rate-rid = p-tax-rate-rid
  .
  RUN Myenable.
  if ref-mode = "ALL-TAX-RATES" then do:
     var-ismarked = if LOOKUP("b-seltax-rate", bttns) > 0 or LOOKUP("b-markltax-rate", bttns) > 0 then yes else no.
     run OpenBr-tax-rate.
  end.
  else do:
     RUn OpenBr.
  end.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY RS-date br-tax-rate-name br-tax-rate-value-name mark-numtax-rate
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-seltax B-addtax B-chgtax B-Help BR-taxes RS-date
         B-seltax-rate B-marktax-rate B-addtax-rate B-chgtax-rate B-deltax-rate
         B-addtax-rate-value B-deltax-rate-value B-gdstax-rate B-histtax-rate
         B-ext B-overvalue-rate-value B-histtax-rate-value BR-tax-rate
         BR-tax-rate-value mark-numtax-rate
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-taxes FOR EACH ub.tax NO-LOCK.
END PROCEDURE.
PROCEDURE MyEnable :
define variable nr as integer no-undo.
HIDE
mark-numtax-rate
in frame Dialog-Frame .
assign
RS-DATE = 1
B-addtax-rate-value:POPUP-MENU IN FRAME Dialog-Frame  = MENU MENU-B-addtax-rate-value:HANDLE
b-addtax-rate-value:MENU-MOUSE in frame Dialog-Frame = 1
nr = BR-taxes:height-chars
menu-item m_global:sensitive in menu menu-b-addtax-rate-value = (if v-cntxt-db-num > 0 then no  else yes)
menu-item m_host:sensitive in menu menu-b-addtax-rate-value = (if v-cntxt-db-num > 0 then no  else yes)
.
ENABLE
B-exit
B-seltax when lookup("b-seltax":U, bttns) > 0
B-chgtax when (v-cntxt-db-num = 0 AND not (parobj-type = "":U and parobj-code = 0))
b-taxgds
B-Help
b-taxhist
BR-taxes
B-seltax-rate when lookup("b-seltax-rate":U, bttns) > 0
B-addtax-rate when (v-cntxt-db-num = 0 AND NOT ref-mode = "ALL-TAX-RATES":U AND not (parobj-type = "":U and parobj-code = 0))
B-chgtax-rate when (v-cntxt-db-num = 0 AND NOT ref-mode = "ALL-TAX-RATES":U AND not (parobj-type = "":U and parobj-code = 0))
B-deltax-rate  when (v-cntxt-db-num = 0 AND NOT ref-mode = "ALL-TAX-RATES":U AND not (parobj-type = "":U and parobj-code = 0))
B-marktax-rate when lookup("b-marktax-rate":U, bttns) > 0
B-histtax-rate
b-gdstax-rate
BR-tax-rate
RS-DATE
b-addtax-rate-value when (NOT ref-mode = "ALL-TAX-RATES":U AND not (parobj-type = "":U and parobj-code = 0))
b-deltax-rate-value when (NOT ref-mode = "ALL-TAX-RATES":U AND not (parobj-type = "":U and parobj-code = 0))
b-histtax-rate-value when NOT ref-mode = "ALL-TAX-RATES":U
b-overvalue-rate-value when (NOT ref-mode = "ALL-TAX-RATES":U AND not (parobj-type = "":U and parobj-code = 0))
b-ext
BR-tax-rate-value
WITH FRAME Dialog-Frame.
if ref-mode = "ALL-TAX-RATES":U then dO:
    hide
    B-chgtax BR-taxes b-seltax B-taxgds B-taxhist
    in frame Dialog-Frame.
        assign
        B-addtax-rate:row in frame Dialog-Frame = B-addtax-rate:row in frame Dialog-Frame - nr
        B-addtax-rate-value:row in frame Dialog-Frame =  B-addtax-rate-value:row - nr
        B-chgtax-rate:row in frame Dialog-Frame =  B-chgtax-rate:row - nr
        B-deltax-rate:row in frame Dialog-Frame =  B-deltax-rate:row - nr
        B-deltax-rate-value:row in frame Dialog-Frame =  B-deltax-rate-value:row - nr
        B-ext:row in frame Dialog-Frame =  B-ext:row - nr
        B-gdstax-rate:row in frame Dialog-Frame =  B-gdstax-rate:row - nr
        B-histtax-rate:row in frame Dialog-Frame =  B-histtax-rate:row - nr
        B-histtax-rate-value:row in frame Dialog-Frame =  B-histtax-rate-value:row - nr
        B-overvalue-rate-value:row in frame Dialog-Frame =  B-overvalue-rate-value:row - nr
        B-marktax-rate:row in frame Dialog-Frame =  B-marktax-rate:row - nr
        BR-tax-rate:row in frame Dialog-Frame =  BR-tax-rate:row - nr
        br-tax-rate-name:row in frame Dialog-Frame =  br-tax-rate-name:row - nr
        BR-tax-rate-value:row in frame Dialog-Frame =  BR-tax-rate-value:row - nr
        br-tax-rate-value-name:row in frame Dialog-Frame =  br-tax-rate-value-name:row - nr
        B-seltax-rate:row in frame Dialog-Frame =  B-seltax-rate:row - nr
        mark-numtax-rate:row in frame Dialog-Frame =  mark-numtax-rate:row - nr
        RS-date:row in frame Dialog-Frame = RS-date:row - nr
        .
        DISPLAY br-tax-rate-name
                with frame Dialog-Frame.
end.
HIDE
b-addtax
b-deltax
in frame Dialog-Frame.
VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE OpenBr :
CASE ref-mode:
    when "ALL":U then do:
        OPEN QUERY BR-taxes FOR EACH ub.tax NO-LOCK.
    end.
    otherwise do:
           OPEN QUERY BR-taxes FOR EACH ub.tax NO-LOCK.
       end.
END CASE.
APPLY "VALUE-CHANGED" to br-taxes in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE Openbr-tax-rate :
CASE ref-mode:
    when "ALL":U then do:
        Open query br-tax-rate for each ub.tax-rate where
                                        ub.tax-rate.tax-code = ub.tax.tax-code NO-LOCK.
        br-tax-rate-name = "Ставки по налогу с кодом " + string(ub.tax.tax-code).
            display
            br-tax-rate-name
            with frame Dialog-Frame.
    end.
    when "ALL-TAX-RATES":U then do:
        if var-tax-code = 0 then
        Open query br-tax-rate for each ub.tax-rate NO-LOCK.
        else do:
          br-tax-rate-name = "Ставки по налогу с кодом " + string(ub.tax.tax-code).
          Open query br-tax-rate for each ub.tax-rate where
                                          ub.tax-rate.tax-code = var-tax-code NO-LOCK.
          display
          br-tax-rate-name
          with frame Dialog-Frame.
          REPOSITION BR-tax-rate to recid integer(v-tax-rate-rid) no-error.
          APPLY "ENTRY" to BR-tax-rate.
        end.
    end.
END CASE.
APPLY "VALUE-CHANGED" to br-tax-rate in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE OpenBr-tax-rate-value :
define input parameter par-date-option as integer no-undo.
define var var-tt-rc as recid.
define var var-fact-order like ub.tax-rate-value.fact-order no-undo.
define var var-ismarked-rate as logical no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer bf_tt-tax-rate-value for tt-tax-rate-value.
run cur-time in this-procedure(output v-today, output v-time).
run factord-end-day in this-procedure (input v-today, output var-fact-order).
for each tt-tax-rate-value:
    delete tt-tax-rate-value.
end.
if not available ub.tax-rate then do:
  open query br-tax-rate-value for each tt-tax-rate-value no-lock.
  return.
end.
var-ismarked-rate = var-ismarked and CAN-DO (v-tax-rate-rid, string( recid(ub.tax-rate))).
CASE par-date-option:
    when 0 then do:
    for each ub.tax-rate-value where
            ub.tax-rate-value.tax-code = ub.tax-rate.tax-code AND
            ub.tax-rate-value.rate-code = ub.tax-rate.rate-code AND
            ub.tax-rate-value.host-code = 0 AND
            ub.tax-rate-value.obj-type = "" AND
            ub.tax-rate-value.obj-code = 0
            :
      create
      tt-tax-rate-value.
      buffer-copy ub.tax-rate-value to tt-tax-rate-value
      assign
      tt-tax-rate-value.rc = recid(ub.tax-rate-value)
      .
      if tax-rate-value.fact-date <= v-today AND
        (not var-ismarked or var-ismarked-rate)  AND
        tax-rate-value.status_ = 'тек':U
      then
      var-rc = recid(ub.tax-rate-value).
    end.
  end.
  when 1 then do:
    FIND LAST ub.tax-rate-value where
            ub.tax-rate-value.tax-code = ub.tax-rate.tax-code AND
            ub.tax-rate-value.rate-code = ub.tax-rate.rate-code AND
            ub.tax-rate-value.host-code = 0 AND
            ub.tax-rate-value.obj-type = "" AND
            ub.tax-rate-value.obj-code = 0 AND
            ub.tax-rate-value.fact-order <= var-fact-order AND
            ub.tax-rate-value.status_ = 'тек':U No-ERROR.
    if avail ub.tax-rate-value then  do:
        create
        tt-tax-rate-value.
        buffer-copy ub.tax-rate-value to tt-tax-rate-value
        assign
        tt-tax-rate-value.rc = recid(ub.tax-rate-value)
        .
        if (not var-ismarked or var-ismarked-rate) then
        var-rc = recid(ub.tax-rate-value).
    end.
  end.
END CASE.
    for each ub.tax-rate-value where
            ub.tax-rate-value.tax-code = ub.tax-rate.tax-code AND
            ub.tax-rate-value.rate-code = ub.tax-rate.rate-code AND
            ub.tax-rate-value.host-code > 0 AND
            ub.tax-rate-value.obj-type = "" AND
            ub.tax-rate-value.obj-code = 0 AND
            (par-date-option = 0 or ub.tax-rate-value.fact-order <= var-fact-order) AND
            (par-date-option = 0 or ub.tax-rate-value.status_ = 'тек':U)
    break
    by ub.tax-rate-value.host-code
    by ub.tax-rate-value.obj-type
    by ub.tax-rate-value.obj-code
    by ub.tax-rate-value.fact-order
    by ub.tax-rate-value.status_
    :
      if par-date-option = 0 or last-of(ub.tax-rate-value.obj-code) then do:
          create
          tt-tax-rate-value.
          buffer-copy ub.tax-rate-value to tt-tax-rate-value
          assign
          tt-tax-rate-value.rc = recid(ub.tax-rate-value)
          .
            if tax-rate-value.fact-date <= v-today AND
               tax-rate-value.host-code = parhost-code AND
               (not var-ismarked or var-ismarked-rate) AND
               tax-rate-value.status_ = 'тек':U
            then
            var-rc = recid(ub.tax-rate-value).
      end.
    end.
   for each tt-tax-rate-value where
            tt-tax-rate-value.tax-code = ub.tax-rate.tax-code AND
            tt-tax-rate-value.rate-code = ub.tax-rate.rate-code AND
            tt-tax-rate-value.host-code = 0:
    tt-tax-rate-value.exp = yes.
   end.
    for each ub.tax-rate-value where
            ub.tax-rate-value.tax-code = ub.tax-rate.tax-code AND
            ub.tax-rate-value.rate-code = ub.tax-rate.rate-code AND
            ub.tax-rate-value.host-code = parhost-code AND
            ub.tax-rate-value.obj-type <> "" AND
            ub.tax-rate-value.obj-code <> 0 AND
            (par-date-option = 0 or ub.tax-rate-value.fact-order <= var-fact-order) AND
            (par-date-option = 0 or ub.tax-rate-value.status_ = 'тек':U)
    break
    by ub.tax-rate-value.host-code
    by ub.tax-rate-value.obj-type
    by ub.tax-rate-value.obj-code
    by ub.tax-rate-value.fact-order
    by ub.tax-rate-value.status_
    :
    if par-date-option = 0
    or last-of(ub.tax-rate-value.obj-code)
    then do:
        create
        tt-tax-rate-value.
        buffer-copy ub.tax-rate-value to tt-tax-rate-value
        assign
        tt-tax-rate-value.rc = recid(ub.tax-rate-value)
        .
               if tax-rate-value.fact-date <= v-today AND
                   tax-rate-value.host-code = parhost-code AND
                   tax-rate-value.obj-type = parobj-type AND
                   tax-rate-value.obj-code = parobj-code AND
                   (not var-ismarked or var-ismarked-rate) AND
                   tax-rate-value.status_ = 'тек':U
               then
               var-rc = recid(ub.tax-rate-value).
    end.
  end.
  for each tt-tax-rate-value where
        tt-tax-rate-value.tax-code = ub.tax-rate.tax-code AND
        tt-tax-rate-value.rate-code = ub.tax-rate.rate-code AND
        tt-tax-rate-value.host-code = parhost-code :
     tt-tax-rate-value.exp = yes.
  end.
find first tt-tax-rate-value where
    tt-tax-rate-value.rc = var-rc no-lock no-error.
    if avail tt-tax-rate-value then
    var-tt-rc = recid(tt-tax-rate-value).
open query br-tax-rate-value for each tt-tax-rate-value no-lock.
reposition br-tax-rate-value to recid var-tt-rc no-error.
br-tax-rate-value-name = "Значения ставки налога с кодом " +
                                                  string(tax-rate.tax-code) +
                         ": код ставки " + string(tax-rate.rate-code).
display
br-tax-rate-value-name
with frame Dialog-Frame.
if br-tax-rate-value:focused-row in frame Dialog-Frame = 1 then do:
    glog = br-tax-rate-value:SELECT-PREV-ROW( ) .
    if glog then do:
        APPLY "CURSOR-DOWN" to br-tax-rate-value.
    end.
end.
END PROCEDURE.
PROCEDURE proc-b-addtax-rate-value :
DEFINE INPUT PARAMETER par-option as character no-undo.
DEFINE INPUT PARAMETER par-date as integer no-undo.
define buffer b_tt-tax-rate-value for tt-tax-rate-value.
case par-option
:
  when "GLOBAL":U
  then do:
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_tax-rate-values_global-update':U
    ,input  'firm':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  end.
  when "HOST":U
  then do:
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_tax-rate-values_firm-update':U
    ,input  'firm':U
    ,input  parhost-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  end.
  when "OBJECT":U
  then do:
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_tax-rate-values_object-update':U
    ,input  'object':U
    ,input  parhost-code
    ,input  parobj-type
    ,input  parobj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестное значение режима" skip
      "par-option" par-option skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end case .
if not glog then return error.
if not avail ub.tax-rate then return no-apply.
if ub.tax-rate.status_ = 'удал':U then do:
  message "Нельзя добавить значениe к удаленной ставке"
  view-as alert-box error .
  return error.
end.
ri = recid(ub.tax-rate).
CASE par-option:
    when "GLOBAL":U then do:
        run ref/taxvali.w ( input 'ДОБАВЛЕНИЕ':U,
                            input 0,
                            input "":U,
                            input 0,
                            input-output ri ) no-error.
        if error-status:error then return error.
    end.
    when "HOST":U then do:
        run ref/taxvali.w ( input 'ДОБАВЛЕНИЕ':U,
                            input parhost-code,
                            input "":U,
                            input 0,
                            input-output ri ) no-error.
        if error-status:error then return error.
    end.
    when "OBJECT":U then do:
        run ref/taxvali.w ( input 'ДОБАВЛЕНИЕ':U,
                            input parhost-code,
                            input parobj-type,
                            input parobj-code,
                            input-output ri ) no-error.
        if error-status:error then return error.
    end.
END CASE.
if ri <> ? then  do:
    run OpenBr-tax-rate-value(par-date).
    if var-rc <> ri then do:
      FIND FIRST b_tt-tax-rate-value No-LOCK WHERE
                 b_tt-tax-rate-value.rc = ri No-ERROR.
      if avail b_tt-tax-rate-value then
      reposition br-tax-rate-value to recid recid(b_tt-tax-rate-value) no-error.
      apply "ENTRY" to br-tax-rate-value in frame Dialog-Frame.
    end.
end.
END PROCEDURE.
PROCEDURE proc-b-ext :
define input parameter par-rc as recid no-undo.
define input parameter par-date-option as integer no-undo.
define var var-tt-rc as recid no-undo.
define var var-fact-order like ub.tax-rate-value.fact-order no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer b_tt-tax-rate-value for tt-tax-rate-value.
define buffer bf_tt-tax-rate-value for tt-tax-rate-value.
if tt-tax-rate-value.host-code <> 0 and
   tt-tax-rate-value.obj-type <> "":U and
   tt-tax-rate-value.obj-code <> 0 THEN do:
   BELL.
   return error.
end.
run cur-time in this-procedure(output v-today, output v-time).
run factord-end-day in this-procedure (input v-today, output var-fact-order).
var-tt-rc = recid(tt-tax-rate-value).
IF tt-tax-rate-value.host-code = 0 then do:
    if tt-tax-rate-value.exp = yes then do:
      FIND FIRST b_tt-tax-rate-value where
                 b_tt-tax-rate-value.rc = par-rc No-ERROR.
      if avail b_tt-tax-rate-value and
              b_tt-tax-rate-value.tax-code = tt-tax-rate-value.tax-code AND
              b_tt-tax-rate-value.rate-code = tt-tax-rate-value.rate-code
      then.
      else dO:
        FOR EACH b_tt-tax-rate-value where
                              b_tt-tax-rate-value.tax-code = tt-tax-rate-value.tax-code AND
                              b_tt-tax-rate-value.rate-code = tt-tax-rate-value.rate-code AND
                              b_tt-tax-rate-value.host-code <> 0:
                    delete b_tt-tax-rate-value.
        END.
        find first b_tt-tax-rate-value where
                  recid(b_tt-tax-rate-value) = recid(tt-tax-rate-value) No-ERROR.
        if avail b_tt-tax-rate-value then do:
              b_tt-tax-rate-value.exp = no.
        end.
      end.
    end.
    else do:
      FOR EACH ub.tax-rate-value NO-LOCK where
              ub.tax-rate-value.tax-code = tt-tax-rate-value.tax-code AND
              ub.tax-rate-value.rate-code = tt-tax-rate-value.rate-code AND
              ub.tax-rate-value.host-code <> 0 AND
              ub.tax-rate-value.obj-type = "" AND
              ub.tax-rate-value.obj-code = 0 AND
              (par-date-option = 0 or ub.tax-rate-value.fact-order <= var-fact-order) AND
              (par-date-option = 0 or ub.tax-rate-value.status_ = 'тек':U)
      break
      by ub.tax-rate-value.host-code
      by ub.tax-rate-value.obj-type
      by ub.tax-rate-value.obj-code
      by ub.tax-rate-value.fact-order
      by ub.tax-rate-value.status_
      :
        if par-date-option = 0 or last-of(ub.tax-rate-value.obj-code) then do:
            create
            b_tt-tax-rate-value.
            buffer-copy ub.tax-rate-value to b_tt-tax-rate-value
            assign
            b_tt-tax-rate-value.rc = recid(ub.tax-rate-value)
            .
        end.
      end.
      find first b_tt-tax-rate-value where
                 recid(b_tt-tax-rate-value) = recid(tt-tax-rate-value) No-ERROR.
      if avail b_tt-tax-rate-value then do:
            b_tt-tax-rate-value.exp = yes.
       end.
    end.
end.
else do:
  if tt-tax-rate-value.exp = yes then do:
      FIND FIRST b_tt-tax-rate-value where
                 b_tt-tax-rate-value.rc = par-rc No-ERROR.
      if avail b_tt-tax-rate-value and
              b_tt-tax-rate-value.tax-code = tt-tax-rate-value.tax-code AND
              b_tt-tax-rate-value.rate-code = tt-tax-rate-value.rate-code AND
              b_tt-tax-rate-value.host-code = tt-tax-rate-value.host-code
      then.
      else do:
        FOR EACH b_tt-tax-rate-value where
                  b_tt-tax-rate-value.tax-code = tt-tax-rate-value.tax-code AND
                  b_tt-tax-rate-value.rate-code = tt-tax-rate-value.rate-code AND
                  b_tt-tax-rate-value.host-code = tt-tax-rate-value.host-code AND
                  b_tt-tax-rate-value.obj-type <> "" and
                  b_tt-tax-rate-value.obj-code <> 0:
            delete b_tt-tax-rate-value.
        END.
        find first b_tt-tax-rate-value where
                  recid(b_tt-tax-rate-value) = recid(tt-tax-rate-value) No-ERROR.
        if avail b_tt-tax-rate-value then do:
                  b_tt-tax-rate-value.exp = no.
        end.
     end.
   end.
   else do:
      FOR EACH ub.tax-rate-value NO-LOCK where
            ub.tax-rate-value.tax-code = tt-tax-rate-value.tax-code AND
            ub.tax-rate-value.rate-code = tt-tax-rate-value.rate-code AND
            ub.tax-rate-value.host-code = tt-tax-rate-value.host-code AND
            ub.tax-rate-value.obj-type <> "" AND
            ub.tax-rate-value.obj-code <> 0 AND
            (par-date-option = 0 or ub.tax-rate-value.fact-order <= var-fact-order) AND
            (par-date-option = 0 or ub.tax-rate-value.status_ = 'тек':U)
      break
      by ub.tax-rate-value.host-code
      by ub.tax-rate-value.obj-type
      by ub.tax-rate-value.obj-code
      by ub.tax-rate-value.fact-order
      by ub.tax-rate-value.status_
      :
        if par-date-option = 0 or last-of(ub.tax-rate-value.obj-code) then do:
          create
          b_tt-tax-rate-value.
          buffer-copy ub.tax-rate-value to b_tt-tax-rate-value
          assign
          b_tt-tax-rate-value.rc = recid(ub.tax-rate-value)
          .
      end.
    end.
    find first b_tt-tax-rate-value where
               recid(b_tt-tax-rate-value) = recid(tt-tax-rate-value) No-ERROR.
    if avail b_tt-tax-rate-value then do:
          b_tt-tax-rate-value.exp = yes.
    end.
  END.
end.
open query br-tax-rate-value for each tt-tax-rate-value no-lock.
reposition br-tax-rate-value to recid var-tt-rc no-error.
END PROCEDURE.
FUNCTION get-envd RETURNS CHARACTER
  ( input i-tax-code as integer, i-rate-code as integer) :
define buffer tax-rate-attr for tax-rate-attr.
define variable vIsENVD as logical no-undo.
find first tax-rate-attr where
           tax-rate-attr.tax-code  = i-tax-code
       and tax-rate-attr.rate-code = i-rate-code
       and tax-rate-attr.attr-code = "envd"
no-lock no-error.
vIsENVD =  AVAILABLE tax-rate-attr.
return string(vIsENVD, "+/").
END FUNCTION.
FUNCTION get-marktax-rate RETURNS CHARACTER
  ( input par-ismarked as logical, input par-rid as recid, input par-tax-rate-rid as character) :
define variable var-mark as character no-undo.
var-mark = IF par-ismarked and  CAN-DO (par-tax-rate-rid, string( par-rid )) THEN ("*") ELSE (" ").
return var-mark.
END FUNCTION.
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = "" and
       parobj-code = 0 then do:
       par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parhost-code).
       return par-region.
    end.
    par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
    return par-region.
END FUNCTION.
FUNCTION get-types RETURNS CHARACTER
  ( input partax-code as integer ) :
DEFINE BUFFER loc-tax-units for ub.tax-units.
DEFINE VARIABLE var-units-types as character no-undo .
define variable is-first as logical no-undo init yes.
    FOR EACH loc-tax-units No-LOCK WHERE
            loc-tax-units.tax-code = partax-code:
            var-units-types = var-units-types +
                              (if is-first then "":U else (chr(44) + chr(32))) +
                              loc-tax-units.type.
        is-first = no.
    END.
  RETURN var-units-types.
END FUNCTION.
