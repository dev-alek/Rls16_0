block-level on error undo, throw.
define input parameter p-forced as logical no-undo .
define input parameter p-read-only as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Приведение дефолтных раскладок, имеющихся в БД к эталонному виду".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-layout-version :
define output parameter p-check as logical no-undo .
define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-dopi3 as integer no-undo .
define variable v-dopi4 as integer no-undo .
define buffer buf_layout for ub.layout .
  do
  on error undo, return error
  :
    find first buf_layout no-lock where
              buf_layout.layout-id = '_'  no-error.
    if (not available buf_layout
    or buf_layout.layout-name <> "v15_1.11" )
    then do:
      assign
      v-dopi1 = integer(entry(2, buf_layout.layout-name,  "."))
      v-dopi2 = integer(entry(2, "v15_1.11", "."))
      v-dopi3 = integer(entry(2, entry(1, buf_layout.layout-name, "."), "_"))
      v-dopi4 = integer(entry(2, entry(1, "v15_1.11", "."), "_"))
      no-error .
      if error-status:error
      or v-dopi2 > v-dopi1
      or v-dopi4 > v-dopi3
      or left-trim(entry(1, buf_layout.layout-name, "."), "v":U) < "15"
      then do:
        assign
        p-check = yes.
      end.
    end.
  end.
end procedure.
procedure get-layout-version :
define output parameter p-layout-version as character no-undo init ?.
define buffer buf_layout for ub.layout .
do
on error undo, return error
:
  find first buf_layout no-lock where
              buf_layout.layout-id = '_'  no-error.
  if available buf_layout then do:
    p-layout-version = buf_layout.layout-name.
  end.
end.
end procedure.
define stream imp-stream.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure layouth_create-layout_h :
define input parameter p-mode as character no-undo .
define input parameter p-layout-id as character no-undo .
define parameter buffer buf_layout for ub.layout.
define output parameter p-chip-num as integer no-undo .
define variable v-chip-num as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-layout for ub.c-layout.
do
on error undo, return error
:
  run cur-time in this-procedure ( output v-today, output v-time).
  find last buf_c-layout no-lock where
            buf_c-layout.layout-id = p-layout-id
       and  buf_c-layout.corr-user-db-num = g#db-num
       use-index pi no-error.
  assign
  v-chip-num = (if available buf_c-layout
                then buf_c-layout.chip-num + 1
                else 0).
  create buf_c-layout.
  if available buf_layout
  and p-mode <> 'ДОБАВЛЕНИЕ':U
  then do:
    buffer-copy buf_layout
    to buf_c-layout.
  end.
  if not available buf_layout then do:
    assign
    buf_c-layout.layout-id = p-layout-id
    .
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    assign
    buf_c-layout.layout-id = p-layout-id
    .
  end.
  assign
  buf_c-layout.subject = 'layout':U
  buf_c-layout.action = (if p-mode = 'ДОБАВЛЕНИЕ':U
                         then integer('1':U)
                         else (if p-mode = 'ИЗМЕНЕНИЕ':U
                               then integer('2':U)
                               else integer('99':U)
                               )
                        )
  buf_c-layout.chip-num = v-chip-num
  buf_c-layout.corr-user-db-num = g#db-num
  buf_c-layout.corr-user-name = g#userid
  buf_c-layout.corr-date = v-today
  buf_c-layout.corr-time = v-time
  p-chip-num = v-chip-num
  .
end.
end procedure.
procedure layouth_create-layout-elem-rule_h :
define input parameter p-mode as character no-undo .
define input parameter p-layout-id as character no-undo .
define input parameter p-mode-id as character no-undo .
define input parameter p-widget-id as character no-undo .
define parameter buffer buf_layout-elem-rule for ub.layout-elem-rule.
define input parameter p-chip-num as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-layout-elem-rule for ub.c-layout-elem-rule.
do
on error undo, return error
:
  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_c-layout-elem-rule.
  if available buf_layout-elem-rule
  and p-mode <> 'ДОБАВЛЕНИЕ':U
  then do:
    buffer-copy buf_layout-elem-rule
    to buf_c-layout-elem-rule.
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    assign
    buf_c-layout-elem-rule.layout-id = p-layout-id
    buf_c-layout-elem-rule.mode-id = p-mode-id
    buf_c-layout-elem-rule.widget-id = p-widget-id
    .
  end.
  assign
  buf_c-layout-elem-rule.subject = 'layout-elem-rule':U
  buf_c-layout-elem-rule.action = (if p-mode = 'ДОБАВЛЕНИЕ':U
                         then integer('1':U)
                         else (if p-mode = 'ИЗМЕНЕНИЕ':U
                               then integer('2':U)
                               else integer('99':U)
                               )
                        )
  buf_c-layout-elem-rule.chip-num = p-chip-num
  buf_c-layout-elem-rule.corr-user-db-num = g#db-num
  buf_c-layout-elem-rule.corr-user-name = g#userid
  buf_c-layout-elem-rule.corr-date = v-today
  buf_c-layout-elem-rule.corr-time = v-time
  .
end.
end procedure.
procedure layouth_create-rule-call-param_h :
define input parameter p-mode as character no-undo .
define input parameter p-call#-id as integer no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-param-name as character no-undo .
define input parameter p-index as integer no-undo .
define input parameter p-call-id as character no-undo .
define parameter buffer buf_rule-call-param for ub.rule-call-param.
define input parameter p-chip-num as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-rule-call-param for ub.c-rule-call-param.
do
on error undo, return error
:
  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_c-rule-call-param.
  if available buf_rule-call-param
  and p-mode <> 'ДОБАВЛЕНИЕ':U
  then do:
    buffer-copy buf_rule-call-param
    to buf_c-rule-call-param.
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    assign
    buf_c-rule-call-param.call#_id = p-call#-id
    buf_c-rule-call-param.codex_id = p-codex-id
    buf_c-rule-call-param.ruleset_id = p-ruleset-id
    buf_c-rule-call-param.order_id = p-order-id
    buf_c-rule-call-param.param-name = p-param-name
    buf_c-rule-call-param.p-index = p-index
    buf_c-rule-call-param.call_id = p-call-id
    .
  end.
  assign
  buf_c-rule-call-param.action = (if p-mode = 'ДОБАВЛЕНИЕ':U
                                  then integer('1':U)
                                  else (if p-mode = 'удаление':U
                                        then integer('99':U)
                                        else integer('2':U)
                                        )
                                  )
  buf_c-rule-call-param.chip-num = p-chip-num
  buf_c-rule-call-param.corr-user-db-num = g#db-num
  buf_c-rule-call-param.corr-user-name = g#userid
  buf_c-rule-call-param.corr-date = v-today
  buf_c-rule-call-param.corr-time = v-time
  .
end.
end procedure.
def var vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info9 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info9, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info9, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info9, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info9, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info9 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info9, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info9 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info9, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info9, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info9, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info9, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info9, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info9, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info9 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info9 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info9, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info9, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info9, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info9 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info9 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info9, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info9, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
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
define new shared temp-table tt-layout no-undo like ub.layout . find first buf_temp-tables where buf_temp-tables.tbl-name = "layout" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "layout"    buf_temp-tables.buf-handle = buffer tt-layout:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-layout-elem no-undo like ub.layout-elem . find first buf_temp-tables where buf_temp-tables.tbl-name = "layout-elem" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "layout-elem"    buf_temp-tables.buf-handle = buffer tt-layout-elem:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-layout-elem-rule no-undo like ub.layout-elem-rule . find first buf_temp-tables where buf_temp-tables.tbl-name = "layout-elem-rule" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "layout-elem-rule"    buf_temp-tables.buf-handle = buffer tt-layout-elem-rule:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-wi-mode no-undo like ub.wi-mode . find first buf_temp-tables where buf_temp-tables.tbl-name = "wi-mode" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "wi-mode"    buf_temp-tables.buf-handle = buffer tt-wi-mode:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-rule-call-param no-undo like ub.rule-call-param . find first buf_temp-tables where buf_temp-tables.tbl-name = "rule-call-param" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "rule-call-param"    buf_temp-tables.buf-handle = buffer tt-rule-call-param:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-rule-by-call no-undo like ub.rule-by-call . find first buf_temp-tables where buf_temp-tables.tbl-name = "rule-by-call" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "rule-by-call"    buf_temp-tables.buf-handle = buffer tt-rule-by-call:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define new shared temp-table tt-rule-by-set no-undo like ub.rule-by-set . find first buf_temp-tables where buf_temp-tables.tbl-name = "rule-by-set" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "rule-by-set"    buf_temp-tables.buf-handle = buffer tt-rule-by-set:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define buffer buf_tt-layout for tt-layout.
define buffer buf_tt-layout-elem for tt-layout-elem.
define buffer buf_tt-wi-mode for tt-wi-mode.
run waitfram-show in this-procedure ("Реинициализация раскладок").
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if ( g#db-num > 0 ) then return.
  if not p-forced then do:
    run check-layout-version in this-procedure (output v-check1).
  end.
  if v-check1
  or p-forced
  then do:
    if v-check1
     and p-read-only then do:
        return error substitute("&1 &2 &3&4До начала работы с данной БД (режим RO) необходимо произвести вход в ОСНОВНУЮ БД!!!"
                                ,vss-workfile
                                ,vss-revision
                                ,vss-description
                                ,chr(10)).
     end.
     run gbl/md5.p (
       input  "cmp/fix-lay.txt"
      ,output v-md5-signature
      ) .
    if v-md5-signature <> "0FE47550AC5DF79F387CB798B90641F8" then do:
      message
      substitute("Несовпадение файла эталонных записей по расладкам (fix-lay.txt) с контрольным числом")
      view-as alert-box error .
      undo, return error .
    end.
    run gbl/filename.p ( input "cmp/fix-lay.txt"
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ) no-error .
    if error-status:error then do:
      message
      substitute("Не найден файл эталонных записей по раскладкам (fix-lay.txt)")
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
      substitute("Ошибка при чтении в память файла эталонных записей по раскладкам (fix-lay.txt)&1&2&1&3"
                   , chr(10)
                   , error-status:get-message(1)
                   , return-value )
      view-as alert-box error .
      undo, return error .
    end.
    if v-check1 then do:
      find first buf_tt-layout no-lock where
                buf_tt-layout.layout-id = '_'  no-error.
      if not available buf_tt-layout
      or buf_tt-layout.layout-name <> "v15_1.11" then do:
        message
        substitute("Версии дефолтных раскладок в r-кодах и файле эталонных записей по раскладкам (fix-lay.txt) НЕ СОВПАДАЮТ&1" +
                   "в r-кодах - &2&1" +
                   "в файле - &3"
                   , chr(10)
                   , "v15_1.11"
                   , (if available buf_tt-layout then buf_tt-layout.layout-name else '')
                   )
        view-as alert-box error .
        undo, return error .
      end.
    end.
    run add-wi-mode in this-procedure no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      assign
      v-mes = substitute("Ошибки при инициализации режимов работы IBS TH POS:&1&2 &3"
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
    run add-layout-elem in this-procedure  no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      assign
      v-mes = substitute("Ошибки при инициализации элементов для раскладок IBS TH POS:&1&2 &3"
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
    run add-layout in this-procedure no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      assign
      v-mes = substitute("Ошибки при инициализации раскладок:&1&2 &3"
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
    run delete-layout-elem in this-procedure no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      assign
      v-mes = substitute("Ошибки при удалении ненужных элементов для раскладок:&1&2 &3"
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
    run delete-wi-mode in this-procedure no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      assign
      v-mes = substitute("Ошибки при удалении ненужных режимов:&1&2 &3"
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
    run delete-rule-by-set in this-procedure no-error.
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      assign
      v-mes = substitute("Ошибки при удалении ненужных привязок правил:&1&2 &3"
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
procedure add-layout-elem :
define variable v-cmp as logical   no-undo .
define variable v-chip-num as integer no-undo .
define buffer buf_tt-layout-elem for tt-layout-elem.
define buffer buf_layout-elem for ub.layout-elem.
define buffer buf_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_layout for ub.layout.
define buffer buf2_layout-elem-rule for ub.layout-elem-rule.
main-block:
do
on error undo, return error return-value
:
  for each buf_tt-layout-elem
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    v-cmp = no.
    find first buf_layout-elem where
             buf_layout-elem.layout-type = buf_tt-layout-elem.layout-type
         and buf_layout-elem.device-type = buf_tt-layout-elem.device-type
         and buf_layout-elem.mode-id = buf_tt-layout-elem.mode-id
         and buf_layout-elem.widget-id = buf_tt-layout-elem.widget-id no-error .
    if not available buf_layout-elem then do:
      create buf_layout-elem.
      v-cmp = no.
    end.
    else do:
      buffer-compare buf_tt-layout-elem to buf_layout-elem save result in v-cmp.
    end.
    if not v-cmp then do:
      buffer-copy buf_tt-layout-elem to buf_layout-elem.
    end.
    if buf_tt-layout-elem.elem-type = integer('-1':U) then do:
      for each buf_layout-elem-rule no-lock where
              buf_layout-elem-rule.mode-id = tt-layout-elem.mode-id
          and buf_layout-elem-rule.widget-id = tt-layout-elem.widget-id
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
        find first buf_layout share-lock where
                 buf_layout.layout-id = buf_layout-elem-rule.layout-id
             and buf_layout.layout-type = buf_layout-elem.layout-type
             and buf_layout.device-type = buf_layout-elem.device-type no-error.
        if available buf_layout
        and buf_layout.is-default = integer('0':U)
        then do:
          run  layouth_create-layout_h  in this-procedure (
                                                         input 'ИЗМЕНЕНИЕ':U
                                                        ,input buf_layout.layout-id
                                                        ,buffer buf_layout
                                                        ,output v-chip-num).
          if buf_layout.sts <> integer('99':U) then
          assign
          buf_layout.sts = integer('50':U)
          .
          find first buf2_layout-elem-rule exclusive-lock where
                    recid(buf2_layout-elem-rule) = recid(buf_layout-elem-rule).
          run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                          input 'ИЗМЕНЕНИЕ':U
                                                        ,input buf2_layout-elem-rule.layout-id
                                                        ,input buf2_layout-elem-rule.mode-id
                                                        ,input buf2_layout-elem-rule.widget-id
                                                        ,buffer buf2_layout-elem-rule
                                                        ,input v-chip-num).
          assign
          buf2_layout-elem-rule.sts = integer('1':U)
          .
        end.
      end.
    end.
  end.
end.
end procedure.
procedure delete-layout-elem :
define variable v-cmp as logical   no-undo .
define variable v-chip-num as integer no-undo .
define buffer buf_tt-layout-elem for tt-layout-elem.
define buffer buf_layout-elem for ub.layout-elem.
define buffer buf_layout-elem-rule for ub.layout-elem-rule.
define buffer buf2_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_layout for ub.layout.
main-block:
do
on error undo, return error return-value
:
  for each buf_layout-elem
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    v-cmp = no.
    find first buf_tt-layout-elem where
             buf_tt-layout-elem.layout-type = buf_layout-elem.layout-type
         and buf_tt-layout-elem.device-type = buf_layout-elem.device-type
         and buf_tt-layout-elem.mode-id = buf_layout-elem.mode-id
         and buf_tt-layout-elem.widget-id = buf_layout-elem.widget-id no-error .
    if not available buf_tt-layout-elem then do:
      for each buf_layout-elem-rule no-lock where
              buf_layout-elem-rule.mode-id = buf_layout-elem.mode-id
          and buf_layout-elem-rule.widget-id = buf_layout-elem.widget-id
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
        find first buf_layout share-lock where
                 buf_layout.layout-id = buf_layout-elem-rule.layout-id
             and buf_layout.layout-type = buf_layout-elem.layout-type
             and buf_layout.device-type = buf_layout-elem.device-type no-error.
        if available buf_layout then do:
          run  layouth_create-layout_h  in this-procedure (
                                                         input 'ИЗМЕНЕНИЕ':U
                                                        ,input buf_layout.layout-id
                                                        ,buffer buf_layout
                                                        ,output v-chip-num).
          if buf_layout.sts <> integer('99':U) then
          assign
          buf_layout.sts = integer('50':U)
          .
        end.
        find first buf2_layout-elem-rule exclusive-lock where
                  recid(buf2_layout-elem-rule) = recid(buf_layout-elem-rule).
        run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                        input 'ИЗМЕНЕНИЕ':U
                                                      ,input buf2_layout-elem-rule.layout-id
                                                      ,input buf2_layout-elem-rule.mode-id
                                                      ,input buf2_layout-elem-rule.widget-id
                                                      ,buffer buf2_layout-elem-rule
                                                      ,input v-chip-num).
        assign
        buf2_layout-elem-rule.sts = integer('1':U)
        .
      end.
    end.
  end.
end.
end procedure.
procedure add-layout :
define variable v-cmp as logical   no-undo .
define variable v-chip-num as integer no-undo .
define variable v-ler-uniq-key-rec as character no-undo .
define variable v-rbc-uniq-key-rec as character no-undo .
define variable v-call#-id as integer no-undo .
define buffer buf_tt-layout for tt-layout.
define buffer buf_tt-layout-elem for tt-layout-elem.
define buffer buf_layout for ub.layout.
define buffer buf2_layout for ub.layout.
define buffer buf3_layout for ub.layout.
define buffer buf_layout-elem for ub.layout-elem.
define buffer buf2_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_tt-layout-elem-rule for tt-layout-elem-rule.
define buffer buf_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_tt-rule-call-param for tt-rule-call-param.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_tt-rule-by-call for tt-rule-by-call.
define buffer buf_wi-mode for ub.wi-mode.
main-block:
do
on error undo, return error return-value
:
  for each buf_tt-layout where
         (buf_tt-layout.is-default = integer('1':U)
          or
          buf_tt-layout.is-default = integer('-1':U)
          )
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    v-chip-num = -1.
    v-cmp = yes.
    find first buf_layout exclusive-lock where
             buf_layout.layout-id = buf_tt-layout.layout-id no-error.
    if not available buf_layout then do:
      create buf_layout.
      v-cmp = no.
    end.
    else do:
      buffer-compare buf_tt-layout to buf_layout case-sensitive save result in v-cmp.
    end.
    if not v-cmp then do:
      run  layouth_create-layout_h  in this-procedure (
                                                      input (if new(buf_layout) then 'ДОБАВЛЕНИЕ':U else 'ИЗМЕНЕНИЕ':U)
                                                    ,input buf_tt-layout.layout-id
                                                    ,buffer buf_layout
                                                    ,output v-chip-num).
      buffer-copy buf_tt-layout to buf_layout.
    end.
    for each buf_tt-layout-elem-rule where
            buf_tt-layout-elem-rule.layout-id = buf_tt-layout.layout-id
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):
      v-cmp = yes.
      find first buf_layout-elem-rule where
                buf_layout-elem-rule.layout-id = buf_tt-layout.layout-id
            and buf_layout-elem-rule.mode-id = buf_tt-layout-elem-rule.mode-id
            and buf_layout-elem-rule.widget-id = buf_tt-layout-elem-rule.widget-id no-error.
      if not available buf_layout-elem-rule then do:
        create buf_layout-elem-rule.
        v-cmp = no.
      end.
      else do:
       buffer-compare buf_tt-layout-elem-rule to buf_layout-elem-rule case-sensitive save result in v-cmp.
      end.
      if not v-cmp then do:
        if v-chip-num < 0 then do:
          run  layouth_create-layout_h  in this-procedure (
                                                          input (if new(buf_layout) then 'ДОБАВЛЕНИЕ':U else 'ИЗМЕНЕНИЕ':U)
                                                        ,input buf_tt-layout.layout-id
                                                        ,buffer buf_layout
                                                        ,output v-chip-num).
        end.
        run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                        input (if new(buf_layout-elem-rule)
                                                               then 'ДОБАВЛЕНИЕ':U
                                                               else 'ИЗМЕНЕНИЕ':U)
                                                      ,input buf_tt-layout-elem-rule.layout-id
                                                      ,input buf_tt-layout-elem-rule.mode-id
                                                      ,input buf_tt-layout-elem-rule.widget-id
                                                      ,buffer buf_layout-elem-rule
                                                      ,input v-chip-num).
        buffer-copy buf_tt-layout-elem-rule to buf_layout-elem-rule.
      end.
      for each buf_tt-rule-by-call where
             buf_tt-rule-by-call.call_id = buf_tt-layout-elem-rule.uniq-key-rec
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):
        v-cmp = yes.
        find first buf_rule-by-call where
                 buf_rule-by-call.call_id = buf_tt-rule-by-call.call_id
            and  buf_rule-by-call.codex_id = buf_tt-rule-by-call.codex_id
            and  buf_rule-by-call.ruleset_id = buf_tt-rule-by-call.ruleset_id
            and  buf_rule-by-call.order_id = buf_tt-rule-by-call.order_id no-error.
       if not available buf_rule-by-call then do:
         create buf_rule-by-call.
         v-cmp = no.
       end.
       else do:
         buffer-compare buf_tt-rule-by-call to buf_rule-by-call case-sensitive save result in v-cmp.
       end.
       if not v-cmp then do:
          buffer-copy buf_tt-rule-by-call to buf_rule-by-call.
        end.
      end.
      for each buf_tt-rule-call-param where
             buf_tt-rule-call-param.call_id = buf_tt-layout-elem-rule.uniq-key-rec
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):
        v-cmp = yes.
        find first buf_rule-call-param where
                 buf_rule-call-param.call_id = buf_tt-rule-call-param.call_id
            and  buf_rule-call-param.codex_id = buf_tt-rule-call-param.codex_id
            and  buf_rule-call-param.ruleset_id = buf_tt-rule-call-param.ruleset_id
            and  buf_rule-call-param.order_id = buf_tt-rule-call-param.order_id
            and  buf_rule-call-param.param-name = buf_tt-rule-call-param.param-name
            and  buf_rule-call-param.p-index = buf_tt-rule-call-param.p-index no-error.
       if not available buf_rule-call-param then do:
         create buf_rule-call-param.
         v-cmp = no.
       end.
       else do:
         buffer-compare buf_tt-rule-call-param to buf_rule-call-param case-sensitive save result in v-cmp.
       end.
       if not v-cmp then do:
          if v-chip-num < 0 then do:
            run  layouth_create-layout_h  in this-procedure (
                                                            input (if new(buf_layout) then 'ДОБАВЛЕНИЕ':U else 'ИЗМЕНЕНИЕ':U)
                                                          ,input buf_tt-layout.layout-id
                                                          ,buffer buf_layout
                                                          ,output v-chip-num).
          end.
          run  layouth_create-rule-call-param_h  in this-procedure (
                                                          input (if new(buf_rule-call-param)
                                                                then 'ДОБАВЛЕНИЕ':U
                                                                else 'ИЗМЕНЕНИЕ':U)
                                                        ,input buf_tt-rule-call-param.call#_id
                                                        ,input buf_tt-rule-call-param.codex_id
                                                        ,input buf_tt-rule-call-param.ruleset_id
                                                        ,input buf_tt-rule-call-param.order_id
                                                        ,input buf_tt-rule-call-param.param-name
                                                        ,input buf_tt-rule-call-param.p-index
                                                        ,input buf_tt-rule-call-param.call_id
                                                        ,buffer buf_rule-call-param
                                                        ,input v-chip-num).
          buffer-copy buf_tt-rule-call-param to buf_rule-call-param.
        end.
      end.
      for each buf_rule-call-param where
             buf_rule-call-param.call_id = buf_tt-layout-elem-rule.uniq-key-rec
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):
        find first buf_tt-rule-call-param where
                 buf_tt-rule-call-param.call_id = buf_rule-call-param.call_id
            and  buf_tt-rule-call-param.codex_id = buf_rule-call-param.codex_id
            and  buf_tt-rule-call-param.ruleset_id = buf_rule-call-param.ruleset_id
            and  buf_tt-rule-call-param.order_id = buf_rule-call-param.order_id
            and  buf_tt-rule-call-param.param-name = buf_rule-call-param.param-name
            and  buf_tt-rule-call-param.p-index = buf_rule-call-param.p-index no-error.
        if not available buf_tt-rule-call-param then do:
          if v-chip-num < 0 then do:
            run  layouth_create-layout_h  in this-procedure (
                                                            input (if new(buf_layout) then 'ДОБАВЛЕНИЕ':U else 'ИЗМЕНЕНИЕ':U)
                                                          ,input buf_tt-layout.layout-id
                                                          ,buffer buf_layout
                                                          ,output v-chip-num).
          end.
          run  layouth_create-rule-call-param_h  in this-procedure (
                                                          input 'удаление':U
                                                        ,input buf_rule-call-param.call#_id
                                                        ,input buf_rule-call-param.codex_id
                                                        ,input buf_rule-call-param.ruleset_id
                                                        ,input buf_rule-call-param.order_id
                                                        ,input buf_rule-call-param.param-name
                                                        ,input buf_rule-call-param.p-index
                                                        ,input buf_rule-call-param.call_id
                                                        ,buffer buf_rule-call-param
                                                        ,input v-chip-num).
        end.
      end.
    end.
    for each buf_layout-elem-rule where
            buf_layout-elem-rule.layout-id = buf_tt-layout.layout-id
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):
      find first buf_tt-layout-elem-rule where
                buf_tt-layout-elem-rule.layout-id = buf_layout.layout-id
            and buf_tt-layout-elem-rule.mode-id = buf_layout-elem-rule.mode-id
            and buf_tt-layout-elem-rule.widget-id = buf_layout-elem-rule.widget-id no-error.
      if not available buf_tt-layout-elem-rule then do:
        if v-chip-num < 0 then do:
          run  layouth_create-layout_h  in this-procedure (
                                                          input (if new(buf_layout) then 'ДОБАВЛЕНИЕ':U else 'ИЗМЕНЕНИЕ':U)
                                                        ,input buf_tt-layout.layout-id
                                                        ,buffer buf_layout
                                                        ,output v-chip-num).
        end.
        run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                        input 'удаление':U
                                                      ,input buf_layout-elem-rule.layout-id
                                                      ,input buf_layout-elem-rule.mode-id
                                                      ,input buf_layout-elem-rule.widget-id
                                                      ,buffer buf_layout-elem-rule
                                                      ,input v-chip-num).
        for each buf_rule-by-call where
             buf_rule-by-call.call_id = buf_layout-elem-rule.uniq-key-rec
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):
           delete buf_rule-by-call.
        end.
        for each buf_rule-call-param where
              buf_rule-call-param.call_id = buf_layout-elem-rule.uniq-key-rec
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):
          if v-chip-num < 0 then do:
            run  layouth_create-layout_h  in this-procedure (
                                                            input (if new(buf_layout) then 'ДОБАВЛЕНИЕ':U else 'ИЗМЕНЕНИЕ':U)
                                                          ,input buf_tt-layout.layout-id
                                                          ,buffer buf_layout
                                                          ,output v-chip-num).
          end.
          run  layouth_create-rule-call-param_h  in this-procedure (
                                                          input 'удаление':U
                                                        ,input buf_rule-call-param.call#_id
                                                        ,input buf_rule-call-param.codex_id
                                                        ,input buf_rule-call-param.ruleset_id
                                                        ,input buf_rule-call-param.order_id
                                                        ,input buf_rule-call-param.param-name
                                                        ,input buf_rule-call-param.p-index
                                                        ,input buf_rule-call-param.call_id
                                                        ,buffer buf_rule-call-param
                                                        ,input v-chip-num).
           delete buf_rule-call-param.
        end.
        delete buf_layout-elem-rule.
      end.
    end.
    if buf_tt-layout.is-default = integer('-1':U) then do:
      for each buf2_layout no-lock where
              buf2_layout.layout-type = buf_tt-layout.layout-type
          and buf2_layout.device-type = buf_tt-layout.device-type:
        if buf2_layout.layout-id = buf_tt-layout.layout-id then next .
        for each buf_tt-layout-elem-rule where
                buf_tt-layout-elem-rule.layout-id = buf_tt-layout.layout-id
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
          find first buf2_layout-elem-rule no-lock where
                buf2_layout-elem-rule.layout-id = buf2_layout.layout-id
             and buf2_layout-elem-rule.mode-id = buf_tt-layout-elem-rule.mode-id
             and buf2_layout-elem-rule.widget-id = buf_tt-layout-elem-rule.widget-id no-error.
          if not available buf2_layout-elem-rule
          or (available (buf2_layout-elem-rule)
             and
             buf2_layout-elem-rule.rule_id <> buf_tt-layout-elem-rule.rule_id) then do:
             run  layouth_create-layout_h  in this-procedure (
                                                           input 'ИЗМЕНЕНИЕ':U
                                                          ,input buf2_layout.layout-id
                                                          ,buffer buf2_layout
                                                          ,output v-chip-num).
            if available buf2_layout-elem-rule then do:
              find current buf2_layout-elem-rule share-lock.
              run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                              input 'ИЗМЕНЕНИЕ':U
                                                            ,input buf2_layout-elem-rule.layout-id
                                                            ,input buf2_layout-elem-rule.mode-id
                                                            ,input buf2_layout-elem-rule.widget-id
                                                            ,buffer buf2_layout-elem-rule
                                                            ,input v-chip-num).
              assign
              buf2_layout-elem-rule.sts = integer('1':U).
              find first buf3_layout share-lock where recid(buf3_layout) = recid(buf2_layout) no-error.
              if available buf3_layout then do:
                if buf3_layout.sts <> integer('99':U) then
                buf3_layout.sts = integer('50':U)
                .
              end.
            end.
            else do:
              run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                              input 'ДОБАВЛЕНИЕ':U
                                                            ,input buf2_layout.layout-id
                                                            ,input buf_tt-layout-elem-rule.mode-id
                                                            ,input buf_tt-layout-elem-rule.widget-id
                                                            ,buffer buf2_layout-elem-rule
                                                            ,input v-chip-num).
              create buf2_layout-elem-rule.
              buffer-copy buf_tt-layout-elem-rule
              except layout-id
              to buf2_layout-elem-rule
              assign
              buf2_layout-elem-rule.layout-id = buf2_layout.layout-id
              buf2_layout-elem-rule.is-mandatory = integer('1':U)
              .
              run gen-key-rec in this-procedure ( input 'layout-elem-rule':U
                                                  ,input (buffer  buf2_layout-elem-rule:handle)
                                                  ,output v-ler-uniq-key-rec).
              buf2_layout-elem-rule.uniq-key-rec = v-ler-uniq-key-rec.
              find first buf_wi-mode no-lock where
                        buf_wi-mode.mode-type = 'cd-IBS-TH':U
                    and buf_wi-mode.mode-id  = buf2_layout-elem-rule.mode-id.
              find first buf_rule-by-call share-lock where
                        buf_rule-by-call.call_id = buf2_layout-elem-rule.uniq-key-rec
                    and buf_rule-by-call.codex_id = buf_wi-mode.codex_id
                    and buf_rule-by-call.ruleset_id = buf_wi-mode.ruleset_id
                    and buf_rule-by-call.order_id = 0 no-error.
              if not available buf_rule-by-call then do:
                run rul/g-callid.p (
                                    input (if buf2_layout.is-default = integer('0':U)
                                            then 'layout-elem-rule':U
                                            else 'layout-elem-rule':U + chr(44) + "minus")
                                    ,input buf2_layout-elem-rule.uniq-key-rec
                                    ,output v-call#-id).
                create buf_rule-by-call.
                assign
                buf_rule-by-call.call_id = buf2_layout-elem-rule.uniq-key-rec
                buf_rule-by-call.call#_id = v-call#-id
                buf_rule-by-call.codex_id = buf_wi-mode.codex_id
                buf_rule-by-call.ruleset_id = buf_wi-mode.ruleset_id
                buf_rule-by-call.order_id = 0
                .
                run gen-key-rec in this-procedure ( input 'rule-by-call':U
                                                    ,input (buffer  buf_rule-by-call:handle)
                                                    ,output v-rbc-uniq-key-rec).
                buf_rule-by-call.uniq-key-rec = v-rbc-uniq-key-rec.
                .
              end.
            end.
          end.
        end.
      end.
    end.
  end.
end.
end procedure.
procedure add-wi-mode:
define variable v-cmp as logical   no-undo .
define buffer buf_tt-wi-mode for tt-wi-mode.
define buffer buf_wi-mode for ub.wi-mode.
main-block:
do
on error undo, return error return-value
:
  for each buf_tt-wi-mode
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    v-cmp = no.
    find first buf_wi-mode where
             buf_wi-mode.mode-type = buf_tt-wi-mode.mode-type
         and buf_wi-mode.mode-id = buf_tt-wi-mode.mode-id  no-error .
    if not available buf_wi-mode then do:
      create buf_wi-mode.
      v-cmp = no.
    end.
    else do:
      buffer-compare buf_tt-wi-mode to buf_wi-mode save result in v-cmp.
    end.
    if not v-cmp then do:
      buffer-copy buf_tt-wi-mode to buf_wi-mode.
    end.
  end.
end.
end procedure.
procedure delete-wi-mode :
define variable v-chip-num as integer   no-undo .
define buffer buf_tt-wi-mode for tt-wi-mode.
define buffer buf_wi-mode for ub.wi-mode.
define buffer buf_layout-elem-rule for ub.layout-elem-rule.
define buffer buf2_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_layout for ub.layout.
main-block:
do
on error undo, return error
:
  for each buf_wi-mode share-lock
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_tt-wi-mode where
              buf_tt-wi-mode.mode-type = buf_wi-mode.mode-type
          and buf_tt-wi-mode.mode-id = buf_wi-mode.mode-id no-error.
    if not available buf_tt-wi-mode
    and buf_wi-mode.mode-type = 'cd-IBS-TH':U
    then do:
       for each buf_layout-elem-rule no-lock where
                buf_layout-elem-rule.mode-id = buf_wi-mode.mode-id
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
       :
           v-chip-num = -1.
          find first buf_layout share-lock where
                buf_layout.layout-id = buf_layout-elem-rule.layout-id no-error.
          if available buf_layout
          then do:
             run  layouth_create-layout_h  in this-procedure (
                                                           input 'ИЗМЕНЕНИЕ':U
                                                          ,input buf_layout.layout-id
                                                          ,buffer buf_layout
                                                          ,output v-chip-num).
            if buf_layout.sts <> integer('99':U) then
            assign
            buf_layout.sts = integer('50':U)
            .
          end.
          find first buf2_layout-elem-rule exclusive-lock where
                  recid(buf2_layout-elem-rule) = recid(buf_layout-elem-rule).
           if v-chip-num >= 0 then
           run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                            input 'ИЗМЕНЕНИЕ':U
                                                          ,input buf2_layout-elem-rule.layout-id
                                                          ,input buf2_layout-elem-rule.mode-id
                                                          ,input buf2_layout-elem-rule.widget-id
                                                          ,buffer buf2_layout-elem-rule
                                                          ,input v-chip-num).
          assign
          buf2_layout-elem-rule.sts = integer('1':U)
          .
       end.
       delete buf_wi-mode.
    end.
  end.
end.
end procedure.
procedure delete-rule-by-set :
define buffer buf_tt-rule-by-set for tt-rule-by-set.
define buffer buf_rule-by-set for ub.rule-by-set.
main-block:
do
on error undo, return error
:
  for each buf_rule-by-set share-lock
  where buf_rule-by-set.codex_id = 19
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_tt-rule-by-set where
              buf_tt-rule-by-set.codex_id = buf_rule-by-set.codex_id
          and buf_tt-rule-by-set.ruleset_id = buf_rule-by-set.ruleset_id
          and buf_tt-rule-by-set.rule_id = buf_rule-by-set.rule_id
          no-error.
    if not available buf_tt-rule-by-set
    and buf_rule-by-set.codex_id = 19
    then do:
      delete buf_rule-by-set.
    end.
  end.
end.
end procedure.
