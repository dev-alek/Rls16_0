block-level on error undo, throw.
define input parameter p-forced as logical no-undo .
define input parameter p-read-only as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Закачка правил скидок и расписаний".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-dr-version :
define output parameter p-check as logical no-undo .
define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-dopi3 as integer no-undo .
define variable v-dopi4 as integer no-undo .
define buffer buf_dis-rule for ub.dis-rule .
  do
  on error undo, return error
  :
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = 0 no-error .
    if (not available buf_dis-rule
    or buf_dis-rule.des <> "v16_0.1" )
    then do:
      assign
      v-dopi1 = integer(entry(2, buf_Dis-rule.des, "."))
      v-dopi2 = integer(entry(2, "v16_0.1", "."))
      v-dopi3 = integer(entry(2, entry(1, buf_Dis-rule.des, "."), "_"))
      v-dopi4 = integer(entry(2, entry(1, "v16_0.1", "."), "_"))
      no-error .
      if error-status:error
      or v-dopi2 > v-dopi1
      or v-dopi4 > v-dopi3
      or left-trim(entry(1, buf_Dis-rule.des, "."), "v":U) < "15"
      then do:
        assign
        p-check = yes.
      end.
    end.
  end.
end procedure.
procedure get-dr-version :
define output parameter p-dr-version as character no-undo init ?.
define buffer buf_dis-rule for ub.dis-rule .
do
on error undo, return error
:
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = 0 no-error .
  if available buf_dis-rule then do:
      p-dr-version = buf_dis-rule.des.
  end.
end.
end procedure.
define temp-table temp-drt-prop no-undo like ub.drt-prop.
procedure disrules-fill-properties:
define input  parameter p-templ-rl-root as integer   no-undo .
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_temp-drt-prop for temp-drt-prop.
do
on error undo, return error return-value
:
  for each buf_temp-drt-prop:
    delete buf_temp-drt-prop.
  end.
  for each buf_drt-prop where buf_drt-prop.templ-rl-root = p-templ-rl-root:
    create buf_temp-drt-prop.
    buffer-copy buf_drt-prop to buf_temp-drt-prop.
  end.
end.
end procedure.
~
def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-dtr-version :
define output parameter p-check as logical no-undo .
define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .
define buffer buf_dis-time-rule for ub.dis-time-rule .
  do
  on error undo, return error
  :
    find first buf_dis-time-rule no-lock where
              buf_dis-time-rule.time-rule-num = 50000  no-error .
    if not available buf_dis-time-rule
    or buf_dis-time-rule.des <> "v16_0.1" then do:
      assign
      v-dopi1 = integer(entry(2, buf_Dis-time-rule.des, "."))
      v-dopi2 = integer(entry(2, "v16_0.1", "."))
      no-error .
      if error-status:error
      or v-dopi2 > v-dopi1
      or left-trim(entry(1, buf_Dis-time-rule.des, "."), "v":U) < "15"
      then do:
        assign
        p-check = yes .
      end.
    end.
  end.
end procedure.
procedure get-dtr-version :
define output parameter p-dtr-version as character no-undo init ?.
define buffer buf_dis-time-rule for ub.dis-time-rule .
do
on error undo, return error
:
  find first buf_dis-time-rule no-lock where
            buf_dis-time-rule.time-rule-num = 50000 no-error .
  if available buf_dis-time-rule then do:
      p-dtr-version = buf_dis-time-rule.des.
  end.
end.
end procedure.
define stream imp-stream.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table temp-tables no-undo
field tbl-name as character
field buf-handle as handle
field tbl-handle as handle
index pi is unique primary
tbl-name.
define new shared temp-table temp-command no-undo
field command-name as character
field tbl-name as character
field uniq-key-rec as character
index pi is unique primary
tbl-name
command-name
uniq-key-rec
index icommand
command-name
tbl-name
uniq-key-rec
.
define buffer buf_temp-tables for temp-tables.
define variable v-check1 as logical no-undo .
define variable v-check2 as logical no-undo .
define variable v-force as logical no-undo .
define variable v-mes   as character no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-md5-signature as character no-undo .
define new shared temp-table tt-dis-rule no-undo like ub.dis-rule . find first buf_temp-tables where buf_temp-tables.tbl-name = "dis-rule" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "dis-rule"    buf_temp-tables.buf-handle = buffer tt-dis-rule:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-dis-cfg-rule no-undo like ub.dis-cfg-rule . find first buf_temp-tables where buf_temp-tables.tbl-name = "dis-cfg-rule" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "dis-cfg-rule"    buf_temp-tables.buf-handle = buffer tt-dis-cfg-rule:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-dis-time-rule no-undo like ub.dis-time-rule . find first buf_temp-tables where buf_temp-tables.tbl-name = "dis-time-rule" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "dis-time-rule"    buf_temp-tables.buf-handle = buffer tt-dis-time-rule:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-drt-prop no-undo like ub.drt-prop . find first buf_temp-tables where buf_temp-tables.tbl-name = "drt-prop" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "drt-prop"    buf_temp-tables.buf-handle = buffer tt-drt-prop:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define buffer buf_tt-dis-rule for tt-dis-rule.
define buffer buf_tt-dis-time-rule for tt-dis-time-rule.
run waitfram-show in this-procedure ("Реинициализация шаблонов для правил скидок и расписаний").
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if ( g#db-num > 0 ) then return.
  if not p-forced then do:
    run check-dr-version in this-procedure (output v-check1).
    run check-dtr-version in this-procedure (output v-check2).
  end.
  if v-check1
  or p-forced
  or v-check2
  then do:
    if (v-check1
    or v-check2 )
    and p-read-only then do:
      return error substitute("&1 &2 &3&4До начала работы с данной БД (режим RO) необходимо произвести вход в ОСНОВНУЮ БД!!!"
                              ,vss-workfile
                              ,vss-revision
                              ,vss-description
                              ,chr(10)).
    end.
     run gbl/md5.p (
       input  "cmp/fixdr.txt"
      ,output v-md5-signature
      ) .
    if v-md5-signature <> "28A7174A802DD8DA5830681AF2A890C5" then do:
      message
      substitute("Несовпадение файла эталонных записей по правилам скидок и расписаний (fixdr.txt) с контрольным числом")
      view-as alert-box error .
      undo, return error .
    end.
    run gbl/filename.p ( input "cmp/fixdr.txt"
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ) no-error .
    if error-status:error then do:
      message
      substitute("Не найден файл эталонных записей по правилам скидок и расписаний (fixdr.txt)")
      view-as alert-box error .
      undo, return error .
    end.
    run str/diallog.w (
          input ?
        ,input this-procedure
        ,input ('utl/upgimptt.p' + chr(4)  +
                '1' + chr(4) +
                '1' + chr(4) +
                '1' + chr(4) +
                '1')
        ,input v-full-path
        ,input yes
        ,input 'Прервать'
        ,input 'Чтение файла в память') no-error .
    if error-status:error then do:
      message
      substitute("Ошибка при чтении в память файла эталонных записей по правилам скидок и расписаний (fixdr.txt)&1&2&1&3"
                   , chr(10)
                   , error-status:get-message(1)
                   , return-value )
      view-as alert-box error .
      undo, return error .
    end.
    if v-check1 then do:
      find first buf_tt-dis-rule no-lock where
                buf_tt-dis-rule.rule-num = 0  no-error.
      if not available buf_tt-dis-rule
      or buf_tt-dis-rule.des <> "v16_0.1" then do:
        message
        substitute("Версии шаблонов скидок в r-кодах и файле эталонных записей по правилам скидок и расписаний (fixdr.txt) НЕ СОВПАДАЮТ&1" +
                   "в r-кодах - &2&1" +
                   "в файле - &3"
                   , chr(10)
                   , "v16_0.1"
                   , buf_tt-dis-rule.des
                   )
        view-as alert-box error .
        undo, return error .
      end.
    end.
    if v-check2 then do:
      find first buf_tt-dis-time-rule no-lock where
                buf_tt-dis-time-rule.time-rule-num = 50000 no-error.
      if not available buf_tt-dis-time-rule
      or buf_tt-dis-time-rule.des <> "v16_0.1" then do:
        message
        substitute("Версии шаблонов расписаний в r-кодах и файле эталонных записей по правилам скидок и расписаний (fixdr.txt) НЕ СОВПАДАЮТ&1" +
                   "в r-кодах - &2&1" +
                   "в файле - &3"
                   , chr(10)
                   , "v16_0.1"
                   , buf_tt-dis-time-rule.des
                   )
        view-as alert-box error .
        undo, return error .
      end.
    end.
    run add-dis-rules in this-procedure no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      assign
      v-mes = substitute("Ошибки при инициализации правил скидок:&1&2 &3"
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value ).
      if p-forced then do:
        message
        v-mes
        view-as alert-box error .
      end.
      undo, return error v-mes.
    end.
  end.
  if v-check2 or p-forced then do:
    run add-dis-time-rules in this-procedure no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      assign
      v-mes = substitute("Ошибки при инициализации расписаний:&1&2 &3"
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value ).
      if p-forced then do:
        message
        v-mes
        view-as alert-box error .
      end.
      undo, return error v-mes.
    end.
  end.
  for each buf_temp-tables
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if valid-handle(buf_temp-tables.tbl-handle) then do:
      delete object buf_temp-tables.tbl-handle.
     end.
  end.
end.
run waitfram-hide in this-procedure .
procedure delete-dis-time-rules :
define variable v-recid as recid no-undo .
define variable v-templ-rl-root as integer no-undo .
define buffer buf_dis-time-rule for ub.dis-time-rule.
define buffer del_dis-time-rule for ub.dis-time-rule.
define buffer down_dis-time-rule for ub.dis-time-rule.
define buffer buf_dis-rule for ub.dis-rule.
  do
  on error undo, return error
  :
     for each buf_dis-time-rule where
              buf_dis-time-rule.time-rule-num >= 50000 + 13
          AND buf_dis-time-rule.upper-time-rule-num = 50000 :
        assign
        buf_dis-time-rule.sts = integer('1':U)
        v-recid = recid(buf_dis-time-rule)
        v-templ-rl-root = buf_dis-time-rule.templ-rl-root
        .
        release buf_dis-time-rule.
        for each down_dis-time-rule where
                down_dis-time-rule.templ-rl-root = v-templ-rl-root
            AND down_dis-time-rule.upper-time-rule-num = v-templ-rl-root
            AND down_dis-time-rule.lvl-num <> 0
        on error undo, return error:
          for each buf_dis-rule exclusive-lock where
                            buf_dis-rule.time-rule-num = down_dis-time-rule.time-rule-num
          on error undo, return error :
            delete buf_dis-rule.
          end.
          delete down_dis-time-rule.
        end.
        find first del_dis-time-rule where recid(del_dis-time-rule) = v-recid.
        delete del_dis-time-rule.
     end.
  end.
end procedure.
procedure delete-dis-rules :
define input parameter p-templ-rl-root as integer no-undo .
define variable v-recid as recid no-undo .
define variable v-templ-rl-root as integer no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer del_dis-rule for ub.dis-rule.
define buffer down_dis-rule for ub.dis-rule.
  main-block:
  do
  on error undo, return error
  :
     for each buf_dis-rule where
              ((buf_dis-rule.rule-num >= 93
              and p-templ-rl-root = ?)
              or
              (buf_dis-rule.templ-rl-root = p-templ-rl-root))
          AND buf_dis-rule.upper-rule-num = 0
     on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
     on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
     on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
     :
        if p-templ-rl-root <> ?
        and buf_dis-rule.templ-rl-root <> p-templ-rl-root then next.
        assign
        buf_dis-rule.sts = integer('1':U)
        v-recid = recid(buf_dis-rule)
        v-templ-rl-root = buf_dis-rule.templ-rl-root
        .
        release buf_dis-rule.
        for each down_dis-rule where
                down_dis-rule.templ-rl-root = v-templ-rl-root
            AND down_dis-rule.upper-rule-num = v-templ-rl-root
        on error undo, return error:
          delete down_dis-rule.
        end.
        find first del_dis-rule where recid(del_dis-rule) = v-recid.
        delete del_dis-rule.
     end.
  end.
end procedure.
procedure add-dis-rules :
define variable v-num-rules as integer no-undo .
define buffer buf_tt-dis-rule for tt-dis-rule.
main-block:
do
on error undo, return error
:
  assign
  v-num-rules = 93
  .
  for each buf_tt-dis-rule where
          buf_tt-dis-rule.rule-num <= v-num-rules
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    run create-dis-rule in this-procedure (
                                             buffer buf_tt-dis-rule
                                            ,input buf_tt-dis-rule.des
                                            ,input buf_tt-dis-rule.dis-kat
                                            ,input buf_tt-dis-rule.discnt-type
                                            ,input buf_tt-dis-rule.doc-qnty
                                            ,input buf_tt-dis-rule.tot-sum
                                            ,input buf_tt-dis-rule.charkey_one
                                            ,input buf_tt-dis-rule.charkey_two
                                            ,input buf_tt-dis-rule.charkey_three
                                            ,input buf_tt-dis-rule.deckey_one
                                            ,input buf_tt-dis-rule.deckey_two
                                            ,input buf_tt-dis-rule.deckey_three
                                            ,input buf_tt-dis-rule.key#_one
                                            ,input buf_tt-dis-rule.key#_two
                                            ,input buf_tt-dis-rule.key#_three
                                            ,input buf_tt-dis-rule.subject-type
                                            ,input buf_tt-dis-rule.time-rule-num
                                            ,input buf_tt-dis-rule.upper-rule-num
                                            ,input buf_tt-dis-rule.value-type
                                            ,input buf_tt-dis-rule.sts
                                            ,input buf_tt-dis-rule.uniq-field
                                            ,input buf_tt-dis-rule.other
                                            ,input buf_tt-dis-rule.rule-num
                                          ) no-error .
    if error-status:error then do:
      undo, return error return-value .
    end.
  end.
end.
end procedure.
procedure add-dis-time-rules :
define variable v-num-rules as integer no-undo .
define buffer buf_tt-dis-time-rule for tt-dis-time-rule.
main-block:
do
on error undo, return error
:
  assign
  v-num-rules = 13
  .
  for each buf_tt-dis-time-rule where
          buf_tt-dis-time-rule.time-rule-num >= 50000
     and  buf_tt-dis-time-rule.time-rule-num <= (v-num-rules + 50000)
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    run create-dis-time-rule in this-procedure (
                                             buffer buf_tt-dis-time-rule
                                            ,input buf_tt-dis-time-rule.des
                                            ,input buf_tt-dis-time-rule.date-from
                                            ,input buf_tt-dis-time-rule.date-to
                                            ,input buf_tt-dis-time-rule.time-from
                                            ,input buf_tt-dis-time-rule.time-to
                                            ,input buf_tt-dis-time-rule.month-day
                                            ,input buf_tt-dis-time-rule.week-day-0
                                            ,input buf_tt-dis-time-rule.week-day-1
                                            ,input buf_tt-dis-time-rule.week-day-2
                                            ,input buf_tt-dis-time-rule.week-day-3
                                            ,input buf_tt-dis-time-rule.week-day-4
                                            ,input buf_tt-dis-time-rule.week-day-5
                                            ,input buf_tt-dis-time-rule.week-day-6
                                            ,input buf_tt-dis-time-rule.week-day-7
                                            ,input buf_tt-dis-time-rule.upper-time-rule-num
                                            ,input buf_tt-dis-time-rule.value-type
                                            ,input buf_tt-dis-time-rule.sts
                                            ,input buf_tt-dis-time-rule.uniq-field
                                            ,input buf_tt-dis-time-rule.other
                                            ,input buf_tt-dis-time-rule.time-rule-num
                                          ) no-error .
  end.
end.
end procedure.
procedure create-dis-rule :
define parameter buffer buf_tt-dis-rule for tt-dis-rule.
define input parameter  p-des               like ub.dis-rule.des               no-undo .
define input parameter  p-dis-kat           like ub.dis-rule.dis-kat           no-undo .
define input parameter  p-discnt-type       like ub.dis-rule.discnt-type       no-undo .
define input parameter  p-doc-qnty          like ub.dis-rule.doc-qnty          no-undo .
define input parameter  p-tot-sum           like ub.dis-rule.tot-sum           no-undo .
define input parameter  p-charkey_one       like ub.dis-rule.charkey_one       no-undo .
define input parameter  p-charkey_two       like ub.dis-rule.charkey_two       no-undo .
define input parameter  p-charkey_three     like ub.dis-rule.charkey_three     no-undo .
define input parameter  p-deckey_one        like ub.dis-rule.deckey_one       no-undo .
define input parameter  p-deckey_two        like ub.dis-rule.deckey_two       no-undo .
define input parameter  p-deckey_three      like ub.dis-rule.deckey_three     no-undo .
define input parameter  p-key#_one          like ub.dis-rule.key#_one          no-undo .
define input parameter  p-key#_two          like ub.dis-rule.key#_two          no-undo .
define input parameter  p-key#_three        like ub.dis-rule.key#_three        no-undo .
define input parameter  p-subject-type      like ub.dis-rule.subject-type      no-undo .
define input parameter  p-time-rule-num     like ub.dis-rule.time-rule-num     no-undo .
define input parameter  p-upper-rule-num    like ub.dis-rule.upper-rule-num    no-undo .
define input parameter  p-value-type        like ub.dis-rule.value-type        no-undo .
define input parameter  p-sts               like ub.dis-rule.sts               no-undo .
define input parameter  p-tree              like ub.dis-rule.uniq-field        no-undo .
define input parameter  p-other             like ub.dis-rule.other-inf         no-undo .
define input parameter  p-rule-num          like ub.dis-rule.rule-num          no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-exists as logical no-undo .
define variable v-level1 as character no-undo .
define variable v-level2 as character no-undo .
define variable v-curr-level as character no-undo .
define variable v-cmp-char as character no-undo .
define variable v-exists2 as logical   no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer down_dis-rule for ub.dis-rule.
define buffer buf_tt-dis-cfg-rule for tt-dis-cfg-rule.
on write of ub.dis-rule override do:
end.
main-block:
do
on error undo, return error
:
  find first buf_tt-dis-cfg-rule no-lock where
            buf_tt-dis-cfg-rule.templ-rl-root = p-rule-num
        and  buf_tt-dis-cfg-rule.table-name = '':U
        and  buf_tt-dis-cfg-rule.time-templ-rl-root = 0
        and  buf_tt-dis-cfg-rule.pos-type = '':U
        and  buf_tt-dis-cfg-rule.discnt-role = '':U no-error .
  if not available buf_tt-dis-cfg-rule then do:
  end.
  assign
  v-level1 = entry(1, buf_tt-dis-cfg-rule.other-inf, ";":U)
  v-level2 = (if num-entries(buf_tt-dis-cfg-rule.other-inf, ";":U) > 1
                then entry(2, buf_tt-dis-cfg-rule.other-inf, ";":U)
                else '')
  .
  find first buf_dis-rule where
            buf_dis-rule.rule-num = p-rule-num no-error.
  if not available buf_dis-rule then do:
    on write of ub.dis-rule revert.
    create buf_dis-rule.
    buffer-copy buf_tt-dis-rule to buf_Dis-rule.
  end.
  else do:
    if
    (buf_dis-rule.time-rule-num <> p-time-rule-num
    and
    lookup("time-rule-num", v-level1) = 0
    and
    lookup("time-rule-num", v-level2) = 0
    and
    (buf_dis-rule.sts = integer('1':U)
     or
     p-time-rule-num = -1)
    ) then do:
      assign
      buf_dis-rule.time-rule-num = p-time-rule-num
      .
      release buf_dis-rule.
      find first buf_dis-rule where
                buf_dis-rule.rule-num = p-rule-num no-error.
    end.
    on write of ub.dis-rule revert.
    buffer-compare buf_dis-rule
    using des discnt-type uniq-field other-inf dis-kat doc-qnty tot-sum
          charkey_one charkey_two charkey_three
          deckey_one deckey_two deckey_three
          key#_one key#_two key#_three
    to buf_tt-dis-rule
    save result in v-cmp-char.
    if v-cmp-char <> ''
    then do:
      buffer-copy buf_tt-dis-rule
      using des discnt-type uniq-field other-inf dis-kat doc-qnty tot-sum
            charkey_one charkey_two charkey_three
            deckey_one deckey_two deckey_three
            key#_one key#_two key#_three
      to buf_dis-rule
      assign
      v-doc-rec                      = recid(buf_dis-rule)
      v-exists                       = yes
      .
    end.
    if buf_dis-rule.sts               <> (if p-sts <> integer('1':U)
                                        then integer('0':U)
                                        else integer('1':U)) then do:
      assign
      buf_dis-rule.sts               = (if p-sts <> integer('1':U)
                                        then integer('0':U)
                                        else integer('1':U))
      v-doc-rec                      = recid(buf_dis-rule)
      v-exists2                       = yes
      .
    end.
    if buf_dis-rule.rule-num > 0 then do:
      if v-exists
      and v-cmp-char <> "des"
      then do:
        for each down_dis-rule where
                down_dis-rule.templ-rl-root = buf_dis-rule.templ-rl-root
            and down_dis-rule.lvl-num > 0
        on error undo main-block, return error:
          if down_dis-rule.upper-rule-num <= 99999 then do:
            assign
            v-curr-level = v-level1
            .
          end.
          else do:
            assign
            v-curr-level = v-level2
            .
          end.
          if
          down_dis-rule.uniq-field        <> p-tree
          or down_dis-rule.discnt-type <> p-discnt-type
          or
          down_dis-rule.other-inf         <> p-other
          or ((down_dis-rule.dis-kat        <> p-dis-kat )
              and
              lookup("dis-kat", v-curr-level) = 0
            )
          or ((down_dis-rule.doc-qnty       <> p-doc-qnty)
              and
              lookup("doc-qnty", v-curr-level) = 0
            )
          or ((down_dis-rule.tot-sum       <> p-tot-sum)
              and
              lookup("tot-sum", v-curr-level) = 0
            )
          or ((down_dis-rule.charkey_one       <> p-charkey_one)
              and
              lookup("charkey_one", v-curr-level) = 0
            )
          or ((down_dis-rule.charkey_two       <> p-charkey_two)
              and
              lookup("charkey_two", v-curr-level) = 0
            )
          or ((down_dis-rule.charkey_three       <> p-charkey_three)
              and
              lookup("charkey_three", v-curr-level) = 0
            )
          or ((down_dis-rule.deckey_one       <> p-deckey_one)
              and
              lookup("deckey_one", v-curr-level) = 0
            )
          or ((down_dis-rule.deckey_two       <> p-deckey_two)
              and
              lookup("deckey_two", v-curr-level) = 0
            )
          or ((down_dis-rule.deckey_three       <> p-deckey_three)
              and
              lookup("deckey_three", v-curr-level) = 0
            )
          or ((down_dis-rule.key#_one       <> p-key#_one)
              and
              lookup("key#_one", v-curr-level) = 0
            )
          or ((down_dis-rule.key#_two       <> p-key#_two)
              and
              lookup("key#_two", v-curr-level) = 0
            )
          or ((down_dis-rule.key#_three       <> p-key#_three)
              and
              lookup("key#_three", v-curr-level) = 0
            )
          then do:
            assign
            down_dis-rule.uniq-field        = p-tree
            down_dis-rule.discnt-type       = p-discnt-type
            down_dis-rule.other-inf         = p-other
            down_dis-rule.dis-kat           = (if p-dis-kat <> down_dis-rule.dis-kat
                                              and lookup("dis-kat", v-curr-level) = 0
                                              then p-dis-kat else down_dis-rule.dis-kat)
            down_dis-rule.doc-qnty          = (if p-doc-qnty <> down_dis-rule.doc-qnty
                                              and lookup("doc-qnty", v-curr-level) = 0
                                              then p-doc-qnty else down_dis-rule.doc-qnty)
            down_dis-rule.tot-sum           = (if p-tot-sum <> down_dis-rule.tot-sum
                                              and lookup("tot-sum", v-curr-level) = 0
                                              then p-tot-sum else down_dis-rule.tot-sum)
            down_dis-rule.charkey_one       = (if p-charkey_one <> down_dis-rule.charkey_one
                                              and lookup("charkey_one", v-curr-level) = 0
                                              then p-charkey_one else down_dis-rule.charkey_one)
            down_dis-rule.charkey_two       = (if p-charkey_two <> down_dis-rule.charkey_two
                                              and lookup("charkey_two", v-curr-level) = 0
                                              then p-charkey_two else down_dis-rule.charkey_two)
            down_dis-rule.charkey_three     = (if p-charkey_three <> down_dis-rule.charkey_three
                                              and lookup("charkey_three", v-curr-level) = 0
                                              then p-charkey_three else down_dis-rule.charkey_three)
            down_dis-rule.deckey_one       = (if p-deckey_one <> down_dis-rule.deckey_one
                                              and lookup("deckey_one", v-curr-level) = 0
                                              then p-deckey_one else down_dis-rule.deckey_one)
            down_dis-rule.deckey_two       = (if p-deckey_two <> down_dis-rule.deckey_two
                                              and lookup("deckey_two", v-curr-level) = 0
                                              then p-deckey_two else down_dis-rule.deckey_two)
            down_dis-rule.deckey_three     = (if p-deckey_three <> down_dis-rule.deckey_three
                                              and lookup("deckey_three", v-curr-level) = 0
                                              then p-deckey_three else down_dis-rule.deckey_three)
            down_dis-rule.key#_one       = (if p-key#_one <> down_dis-rule.key#_one
                                              and lookup("key#_one", v-curr-level) = 0
                                              then p-key#_one else down_dis-rule.key#_one)
            down_dis-rule.key#_two       = (if p-key#_two <> down_dis-rule.key#_two
                                            and lookup("key#_two", v-curr-level) = 0
                                            then p-key#_two else down_dis-rule.key#_two)
            down_dis-rule.key#_three     = (if p-key#_three <> down_dis-rule.key#_three
                                            and lookup("key#_three", v-curr-level) = 0
                                            then p-key#_three else down_dis-rule.key#_three)
          .
            if down_dis-rule.lvl-num <> 1 then do:
              assign
              down_dis-rule.sts               =  (if down_dis-rule.sts <> integer('2':U)
                                                  then integer('2':U)
                                                  else down_dis-rule.sts)
              .
            end.
            release down_dis-rule no-error .
            if error-status:error then undo, return error return-value .
          end.
        end.
      end.
      if v-exists2 then do:
        for each down_dis-rule where
                down_dis-rule.templ-rl-root = buf_dis-rule.templ-rl-root
            AND down_dis-rule.lvl-num       <> 0
        on error undo main-block, return error:
          if down_dis-rule.lvl-num <> 1 then do:
            assign
            down_dis-rule.sts               =  (if down_dis-rule.sts <> integer('2':U)
                                                then integer('2':U)
                                                else down_dis-rule.sts)
            .
            release down_dis-rule no-error .
            if error-status:error then undo, return error return-value.
          end.
        end.
      end.
    end.
    run create-dis-cfg-rule in this-procedure ( input p-rule-num).
    run create-drt-prop in this-procedure ( input p-rule-num).
    return .
  end.
  run create-dis-cfg-rule in this-procedure ( input p-rule-num).
  run create-drt-prop in this-procedure ( input p-rule-num).
end.
end procedure.
procedure create-dis-time-rule :
define parameter buffer buf_tt-dis-time-rule for tt-dis-time-rule.
define input parameter  p-des               like ub.dis-rule.des               no-undo .
define input parameter  p-date-from         like ub.dis-time-rule.date-from no-undo .
define input parameter  p-date-to           like ub.dis-time-rule.date-to  no-undo .
define input parameter  p-time-from         like ub.dis-time-rule.time-from  no-undo .
define input parameter  p-time-to           like ub.dis-time-rule.time-to  no-undo .
define input parameter  p-month-day         like ub.dis-time-rule.month-day no-undo .
define input parameter  p-week-day-0        like ub.dis-time-rule.week-day-0 no-undo .
define input parameter  p-week-day-1        like ub.dis-time-rule.week-day-1 no-undo .
define input parameter  p-week-day-2        like ub.dis-time-rule.week-day-2 no-undo .
define input parameter  p-week-day-3        like ub.dis-time-rule.week-day-3 no-undo .
define input parameter  p-week-day-4        like ub.dis-time-rule.week-day-4 no-undo .
define input parameter  p-week-day-5        like ub.dis-time-rule.week-day-5 no-undo .
define input parameter  p-week-day-6        like ub.dis-time-rule.week-day-6 no-undo .
define input parameter  p-week-day-7        like ub.dis-time-rule.week-day-7 no-undo .
define input parameter  p-upper-time-rule-num    like ub.dis-time-rule.upper-time-rule-num    no-undo .
define input parameter  p-value-type        like ub.dis-time-rule.value-type        no-undo .
define input parameter  p-sts               like ub.dis-time-rule.sts no-undo .
define input parameter  p-tree              like ub.dis-time-rule.uniq-field        no-undo .
define input parameter  p-other             like ub.dis-time-rule.other-inf         no-undo .
define input parameter  p-time-rule-num     like ub.dis-time-rule.time-rule-num          no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-exists as logical no-undo .
define variable v-exitst2 as logical   no-undo .
define variable v-level1 as character no-undo .
define variable v-level2 as character no-undo .
define variable v-curr-level as character no-undo .
define buffer buf_dis-time-rule for ub.dis-time-rule.
define buffer down_dis-time-rule for ub.dis-time-rule.
define buffer buf_tt-dis-cfg-rule for tt-dis-cfg-rule.
on write of ub.dis-time-rule override do: end.
main-block:
do
on error undo, return error
:
  find first buf_tt-dis-cfg-rule no-lock where
            buf_tt-dis-cfg-rule.time-templ-rl-root = p-time-rule-num
        and  buf_tt-dis-cfg-rule.table-name = '':U
        and  buf_tt-dis-cfg-rule.templ-rl-root = 0
        and  buf_tt-dis-cfg-rule.pos-type = '':U
        and  buf_tt-dis-cfg-rule.discnt-role = '':U no-error .
  if not available buf_tt-dis-cfg-rule then do:
  end.
  assign
  v-level1 = entry(1, buf_tt-dis-cfg-rule.other-inf, ";":U)
  v-level2 = (if num-entries(buf_tt-dis-cfg-rule.other-inf, ";":U) > 1
                then entry(2, buf_tt-dis-cfg-rule.other-inf, ";":U)
                else '')
  .
  find first buf_dis-time-rule where
            buf_dis-time-rule.time-rule-num  = p-time-rule-num  no-error.
  if not available buf_dis-time-rule then do:
    on write of ub.dis-time-rule revert.
    create buf_dis-time-rule.
    assign
    buf_dis-time-rule.time-rule-num          = p-time-rule-num
    v-exists = yes
    .
  end.
  else do:
    if buf_dis-time-rule.des <> p-des
    or
    buf_dis-time-rule.uniq-field        <> p-tree
    or
    buf_dis-time-rule.other-inf         <> p-other
    or
    buf_dis-time-rule.sts               <> (if p-sts <> integer('1':U)
                                            then integer('0':U)
                                            else integer('1':U))
    then do:
      assign
      buf_dis-time-rule.des               = p-des
      buf_dis-time-rule.uniq-field        = p-tree
      buf_dis-time-rule.other-inf         = p-other
      buf_dis-time-rule.sts               = (if p-sts <> integer('1':U)
                                              then integer('0':U)
                                              else integer('1':U))
      v-exists = yes
      .
    end.
    if buf_dis-time-rule.time-rule-num <> 50000 then do:
      for each down_dis-time-rule where
              down_dis-time-rule.templ-rl-root = buf_dis-time-rule.templ-rl-root
          AND  down_dis-time-rule.lvl-num       <> 0
      on error undo main-block, return error:
        if down_dis-time-rule.upper-time-rule-num <= 99999 then do:
          assign
          v-curr-level = v-level1
          .
        end.
        else do:
          assign
          v-curr-level = v-level2
          .
        end.
        if down_dis-time-rule.uniq-field        <> p-tree
        or
        down_dis-time-rule.other-inf         <> p-other
        or ((down_dis-time-rule.time-from       <> p-time-from)
            and
            lookup("time-from", v-curr-level) = 0
          )
        or ((down_dis-time-rule.time-to       <> p-time-to)
            and
            lookup("time-to", v-curr-level) = 0
          )
        or ((down_dis-time-rule.date-from       <> p-date-from)
            and
            lookup("date-from", v-curr-level) = 0
          )
        or ((down_dis-time-rule.date-to       <> p-date-to)
            and
            lookup("date-to", v-curr-level) = 0
          )
        or ((down_dis-time-rule.week-day-0       <> p-week-day-0)
            and
            lookup("week-day-0", v-curr-level) = 0
          )
        or ((down_dis-time-rule.week-day-1       <> p-week-day-1)
            and
            lookup("week-day-1", v-curr-level) = 0
          )
        or ((down_dis-time-rule.week-day-2       <> p-week-day-2)
            and
            lookup("week-day-2", v-curr-level) = 0
          )
        or ((down_dis-time-rule.week-day-3       <> p-week-day-3)
            and
            lookup("week-day-3", v-curr-level) = 0
          )
        or ((down_dis-time-rule.week-day-4       <> p-week-day-4)
            and
            lookup("week-day-4", v-curr-level) = 0
          )
        or ((down_dis-time-rule.week-day-5       <> p-week-day-5)
            and
            lookup("week-day-5", v-curr-level) = 0
          )
        or ((down_dis-time-rule.week-day-6       <> p-week-day-6)
            and
            lookup("week-day-6", v-curr-level) = 0
          )
        or ((down_dis-time-rule.week-day-7       <> p-week-day-7)
            and
            lookup("week-day-7", v-curr-level) = 0
          )
        or ((down_dis-time-rule.month-day       <> p-month-day)
            and
            lookup("month-day", v-curr-level) = 0
          )
        then do:
          assign
          down_dis-time-rule.uniq-field        = p-tree
          down_dis-time-rule.other-inf         = p-other
          down_dis-time-rule.date-from        = p-date-from
          down_dis-time-rule.date-to          = p-date-to
          down_dis-time-rule.time-from        = (if  ((down_dis-time-rule.time-from       <> p-time-from)
                                                  and
                                                  lookup("time-from", v-curr-level) = 0
                                                      )
                                                then p-time-from
                                                else down_dis-time-rule.time-from)
          down_dis-time-rule.time-to          = (if  ((down_dis-time-rule.time-to       <> p-time-to)
                                                  and
                                                  lookup("time-to", v-curr-level) = 0
                                                      )
                                                then p-time-to
                                                else down_dis-time-rule.time-to)
          down_dis-time-rule.week-day-0       = (if ((down_dis-time-rule.week-day-0       <> p-week-day-0)
                                                    and
                                                    lookup("week-day-0", v-curr-level) = 0
                                                  )
                                                then p-week-day-0
                                                else down_dis-time-rule.week-day-0)
          down_dis-time-rule.week-day-1       = (if ((down_dis-time-rule.week-day-1       <> p-week-day-1)
                                                    and
                                                    lookup("week-day-1", v-curr-level) = 0
                                                  )
                                                then p-week-day-1
                                                else down_dis-time-rule.week-day-1)
          down_dis-time-rule.week-day-2       = (if ((down_dis-time-rule.week-day-2       <> p-week-day-2)
                                                    and
                                                    lookup("week-day-2", v-curr-level) = 0
                                                  )
                                                then p-week-day-2
                                                else down_dis-time-rule.week-day-2)
          down_dis-time-rule.week-day-3       = (if ((down_dis-time-rule.week-day-3       <> p-week-day-3)
                                                    and
                                                    lookup("week-day-3", v-curr-level) = 0
                                                  )
                                                then p-week-day-3
                                                else down_dis-time-rule.week-day-3)
          down_dis-time-rule.week-day-4       = (if ((down_dis-time-rule.week-day-4       <> p-week-day-4)
                                                    and
                                                    lookup("week-day-4", v-curr-level) = 0
                                                  )
                                                then p-week-day-4
                                                else down_dis-time-rule.week-day-4)
          down_dis-time-rule.week-day-5       = (if ((down_dis-time-rule.week-day-5       <> p-week-day-5)
                                                    and
                                                    lookup("week-day-5", v-curr-level) = 0
                                                  )
                                                then p-week-day-5
                                                else down_dis-time-rule.week-day-5)
          down_dis-time-rule.week-day-6       = (if ((down_dis-time-rule.week-day-6       <> p-week-day-6)
                                                    and
                                                    lookup("week-day-6", v-curr-level) = 0
                                                  )
                                                then p-week-day-6
                                                else down_dis-time-rule.week-day-6)
          down_dis-time-rule.week-day-7       = (if ((down_dis-time-rule.week-day-7       <> p-week-day-7)
                                                    and
                                                    lookup("week-day-7", v-curr-level) = 0
                                                  )
                                                then p-week-day-7
                                                else down_dis-time-rule.week-day-7)
          down_dis-time-rule.month-day       = (if ((down_dis-time-rule.month-day       <> p-month-day)
                                                    and
                                                    lookup("month-day", v-curr-level) = 0
                                                  )
                                                then p-month-day
                                                else down_dis-time-rule.month-day)
          .
          release down_dis-time-rule no-error .
          if error-status:error then undo, return error return-value .
        end.
      end.
      for each down_dis-time-rule where
              down_dis-time-rule.templ-rl-root = buf_dis-time-rule.templ-rl-root
          AND down_dis-time-rule.lvl-num       > 0
      on error undo main-block, return error:
        if down_dis-time-rule.lvl-num <> 1 then do:
          assign
          down_dis-time-rule.sts               =  (if down_dis-time-rule.sts <> integer('2':U)
                                              then integer('2':U)
                                              else down_dis-time-rule.sts)
          .
          release down_dis-time-rule no-error .
          if error-status:error then undo, return error return-value.
        end.
      end.
    end.
    run create-drt-prop in this-procedure ( input p-time-rule-num).
    return .
  end.
  if buf_dis-time-rule.des <> p-des
  or
  buf_dis-time-rule.date-from         <> p-date-from
  or
  buf_dis-time-rule.date-to           <> p-date-to
  or
  buf_dis-time-rule.time-from         <> p-time-from
  or
  buf_dis-time-rule.time-to           <> p-time-to
  or
  buf_dis-time-rule.month-day         <> p-month-day
  or
  buf_dis-time-rule.week-day-0        <> p-week-day-0
  or
  buf_dis-time-rule.week-day-1        <> p-week-day-1
  or
  buf_dis-time-rule.week-day-2        <> p-week-day-2
  or
  buf_dis-time-rule.week-day-3        <> p-week-day-3
  or
  buf_dis-time-rule.week-day-4        <> p-week-day-4
  or
  buf_dis-time-rule.week-day-5        <> p-week-day-5
  or
  buf_dis-time-rule.week-day-6        <> p-week-day-6
  or
  buf_dis-time-rule.week-day-7        <> p-week-day-7
  or
  buf_dis-time-rule.sts               <> (if p-sts <> integer('1':U)
                                          then integer('0':U)
                                          else integer('1':U))
  or
  buf_dis-time-rule.upper-time-rule-num    <> p-upper-time-rule-num
  or
  buf_dis-time-rule.value-type        <> p-value-type
  or
  buf_dis-time-rule.root              <> yes
  or
  buf_dis-time-rule.lvl-num           <> 0
  or
  buf_dis-time-rule.is-term           <> yes
  or
  buf_dis-time-rule.uniq-field        <> p-tree
  or
  buf_dis-time-rule.other-inf         <> p-other
  or
  buf_dis-time-rule.rl-root           <> p-time-rule-num
  or
  buf_dis-time-rule.templ-rl-root     <> p-time-rule-num
  then do:
    assign
    buf_dis-time-rule.des                   = p-des
    buf_dis-time-rule.upper-time-rule-num    = p-upper-time-rule-num
    buf_dis-time-rule.date-from         = p-date-from
    buf_dis-time-rule.date-to           = p-date-to
    buf_dis-time-rule.time-from         = p-time-from
    buf_dis-time-rule.time-to           = p-time-to
    buf_dis-time-rule.month-day         = p-month-day
    buf_dis-time-rule.week-day-0        = p-week-day-0
    buf_dis-time-rule.week-day-1        = p-week-day-1
    buf_dis-time-rule.week-day-2        = p-week-day-2
    buf_dis-time-rule.week-day-3        = p-week-day-3
    buf_dis-time-rule.week-day-4        = p-week-day-4
    buf_dis-time-rule.week-day-5        = p-week-day-5
    buf_dis-time-rule.week-day-6        = p-week-day-6
    buf_dis-time-rule.week-day-7        = p-week-day-7
    buf_dis-time-rule.value-type        = p-value-type
    buf_dis-time-rule.root              = yes
    buf_dis-time-rule.lvl-num           = 0
    buf_dis-time-rule.is-term           = yes
    buf_dis-time-rule.uniq-field        = p-tree
    buf_dis-time-rule.other-inf         = p-other
    buf_dis-time-rule.rl-root           = p-time-rule-num
    buf_dis-time-rule.templ-rl-root     = p-time-rule-num
    buf_dis-time-rule.sts               = (if p-sts <> integer('1':U)
                                            then integer('0':U)
                                            else integer('1':U))
    .
    release buf_dis-time-rule no-error .
    if error-status:error then undo, return error return-value .
  end.
end.
end procedure.
procedure create-dis-cfg-rule :
define input parameter p-rule-num as integer no-undo .
define buffer buf_tt-dis-cfg-rule for tt-dis-cfg-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf2_dis-cfg-rule for ub.dis-cfg-rule.
main-block:
do
on error undo, return error
:
  for each buf_tt-dis-cfg-rule no-lock where
         buf_tt-dis-cfg-rule.templ-rl-root = p-rule-num
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_dis-cfg-rule share-lock where
              buf_dis-cfg-rule.templ-rl-root = buf_tt-dis-cfg-rule.templ-rl-root
          and buf_dis-cfg-rule.table-name = buf_tt-dis-cfg-rule.table-name
          and buf_dis-cfg-rule.pos-type = buf_tt-dis-cfg-rule.pos-type
          and buf_dis-cfg-rule.time-templ-rl-root = buf_tt-dis-cfg-rule.time-templ-rl-root
          and buf_dis-cfg-rule.self-nonunique = buf_tt-dis-cfg-rule.self-nonunique no-error.
    if not available buf_dis-cfg-rule then do:
      create buf_dis-cfg-rule.
    end.
    buffer-copy buf_tt-dis-cfg-rule
    to buf_dis-cfg-rule.
  end.
  for each buf_dis-cfg-rule no-lock where
          buf_dis-cfg-rule.templ-rl-root = p-rule-num
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_tt-dis-cfg-rule where
            buf_tt-dis-cfg-rule.templ-rl-root = buf_dis-cfg-rule.templ-rl-root
        and buf_tt-dis-cfg-rule.table-name = buf_dis-cfg-rule.table-name
        and buf_tt-dis-cfg-rule.pos-type = buf_dis-cfg-rule.pos-type
        and buf_tt-dis-cfg-rule.time-templ-rl-root = buf_dis-cfg-rule.time-templ-rl-root
        and buf_tt-dis-cfg-rule.self-nonunique = buf_dis-cfg-rule.self-nonunique
        no-error .
    if not available buf_tt-dis-cfg-rule then do:
      find first buf2_dis-cfg-rule exclusive-lock where
                recid(buf2_dis-cfg-rule) = recid(buf_dis-cfg-rule).
      delete buf2_dis-cfg-rule.
    end.
  end.
end.
end procedure.
procedure create-drt-prop :
define input parameter p-templ-rl-root as integer no-undo .
define buffer buf_tt-drt-prop for tt-drt-prop.
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf2_drt-prop for ub.drt-prop.
main-block:
do
on error undo, return error
:
  for each buf_tt-drt-prop no-lock where
          buf_tt-drt-prop.templ-rl-root = p-templ-rl-root
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_drt-prop share-lock where
              buf_drt-prop.templ-rl-root = buf_tt-drt-prop.templ-rl-root
          and buf_drt-prop.node-code = buf_tt-drt-prop.node-code no-error.
    if not available buf_drt-prop then do:
      create buf_drt-prop.
    end.
    buffer-copy buf_tt-drt-prop to buf_drt-prop.
  end.
  for each buf_drt-prop no-lock where
          buf_drt-prop.templ-rl-root = p-templ-rl-root
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_tt-drt-prop where
            buf_tt-drt-prop.templ-rl-root = buf_drt-prop.templ-rl-root
        and buf_tt-drt-prop.node-code = buf_drt-prop.node-code no-error .
    if not available buf_tt-drt-prop then do:
      find first buf2_drt-prop exclusive-lock where
                recid(buf2_drt-prop) = recid(buf_drt-prop).
      delete buf2_drt-prop.
    end.
  end.
end.
end procedure.
