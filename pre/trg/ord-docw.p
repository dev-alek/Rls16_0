block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.ORD-doc OLD BUFFER old_ord-doc.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись заказа".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure grp-attr-name :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
    case p-code :
            when 'gds-grp-nabor':U then do:     assign     p-label = "Набор"     p-type = 'L':U      p-format = "yes/no"     p-label = "Набор"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
      otherwise do:
        undo, return error "Неизвестный атрибут группы товаров на фирме" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure grp-attr-tooltip :
do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'gds-grp-nabor':U then do:     assign     p-tooltip = "Набор - не товарные позиции"     p-label = "Набор" .   end.
      otherwise do:
            undo, return error "Неизвестный атрибут группы товаров на фирме" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure grp-attr-value :
do
on error undo, return error
:
define input  parameter p-node-code   as integer    no-undo.
define input  parameter p-code        as character  no-undo.
define input  parameter p-host-code   as integer    no-undo.
define input  parameter p-obj-type    as character  no-undo.
define input  parameter p-obj-code    as integer    no-undo.
define output parameter p-value       as character  no-undo.
define output parameter p-type        as character  no-undo.
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define buffer buf_gds-grp-attr for ub.gds-grp-attr.
    run grp-attr-name in this-procedure (
          input  p-code
        , output p-type
        , output v-format
        , output v-label
        , output v-user-can-edit
        , output v-output-display
        , output v-other
    ) no-error .
    if error-status :error
    then do:
        undo, return error return-value .
    end.
    find first buf_gds-grp-attr no-lock
         where buf_gds-grp-attr.node-code = p-node-code
           and buf_gds-grp-attr.attr-code = p-code
           and buf_gds-grp-attr.host-code = p-host-code
           and buf_gds-grp-attr.obj-type  = p-obj-type
           and buf_gds-grp-attr.obj-code  = p-obj-code
    no-error .
    if available buf_gds-grp-attr
    then do:
        assign
            p-value = buf_gds-grp-attr.attr-value
        .
    end.
    else do:
        assign
            p-value = if p-type = 'L':U then "no":U else ""
        .
    end.
end.
end procedure.
procedure grp-attr-write :
do
on error undo, return error
:
define input parameter p-node-code  like ub.gds-grp-attr.node-code      no-undo.
define input parameter p-code       like ub.gds-grp-attr.attr-code      no-undo.
define input parameter p-host-code  as integer                          no-undo.
define input parameter p-obj-type   like ub.clients.obj-type            no-undo.
define input parameter p-obj-code   like ub.clients.obj-code            no-undo.
define input parameter p-value      like ub.gds-grp-attr.attr-value     no-undo.
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    define buffer buf_gds-grp-attr for ub.gds-grp-attr .
    run grp-attr-name in this-procedure (
                      input  p-code
                    , output v-type
                    , output v-format
                    , output v-label
                    , output v-user-can-edit
                    , output v-output-display
                    , output v-other
    ) no-error.
    if error-status :error
    then do:
        undo, return error return-value.
    end.
    find first buf_gds-grp-attr exclusive-lock
         where buf_gds-grp-attr.node-code  = p-node-code
           and buf_gds-grp-attr.attr-code  = p-code
           and buf_gds-grp-attr.host-code  = p-host-code
           and buf_gds-grp-attr.obj-type   = p-obj-type
           and buf_gds-grp-attr.obj-code   = p-obj-code
    no-error.
    if not available buf_gds-grp-attr
    then do:
        create buf_gds-grp-attr.
        assign
                buf_gds-grp-attr.node-code  = p-node-code
                buf_gds-grp-attr.attr-code  = p-code
                buf_gds-grp-attr.host-code  = p-host-code
                buf_gds-grp-attr.obj-type   = p-obj-type
                buf_gds-grp-attr.obj-code   = p-obj-code
                buf_gds-grp-attr.attr-value = p-value
        .
    end.
    else do:
        assign
            buf_gds-grp-attr.attr-value = p-value
        .
    end.
end.
end procedure.
procedure grp-attr-delete :
do
on error undo, return error
:
define input parameter p-node-code  like ub.gds-grp-attr.node-code  no-undo.
define input parameter p-code       like ub.gds-grp-attr.attr-code  no-undo.
define input parameter p-host-code  as integer                      no-undo.
define input parameter p-obj-type   like ub.clients.obj-type        no-undo.
define input parameter p-obj-code   like ub.clients.obj-code        no-undo.
define output parameter p-deleted   as logical                      no-undo.
    define buffer buf_gds-grp-attr for ub.gds-grp-attr .
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    run grp-attr-name in this-procedure
    ( input  p-code
    , output v-type
    , output v-format
    , output v-label
    , output v-user-can-edit
    , output v-output-display
    , output v-other
    ) no-error .
    if error-status :error then do:
        undo, return error return-value .
    end.
    find first buf_gds-grp-attr exclusive-lock
         where buf_gds-grp-attr.node-code  = p-node-code
           and buf_gds-grp-attr.attr-code  = p-code
           and buf_gds-grp-attr.host-code  = p-host-code
           and buf_gds-grp-attr.obj-type   = p-obj-type
           and buf_gds-grp-attr.obj-code   = p-obj-code
    no-error.
    if not available buf_gds-grp-attr
    then do:
        assign
            p-deleted = no
        .
    end.
    else do:
       delete buf_gds-grp-attr.
       assign
            p-deleted = yes
        .
    end.
end.
end procedure.
procedure grp-attr-news :
do
on error undo, return error
:
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'gds-grp-nabor':U then do:     assign     p-news = true.   end.
      otherwise do:
        undo, return error "неизвестный атрибут товара на фирме" + " " + p-code .
      end.
    end.
end.
end procedure.
procedure grp-attr-obj-value :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define input parameter p-attr-code as character    no-undo .
define output parameter p-attr-value     as character   no-undo.
define output parameter p-range     as integer      no-undo.
define output parameter p-exists    as logical      no-undo.
define variable v-host-code as integer      no-undo.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-attr      for ub.gds-grp-attr.
find first buf_gds-grp-attr no-lock
     where buf_gds-grp-attr.node-code = p-node-code
       and buf_gds-grp-attr.attr-code = p-attr-code
       and buf_gds-grp-attr.host-code = v-host-code
       and buf_gds-grp-attr.obj-type  = p-obj-type
       and buf_gds-grp-attr.obj-code  = p-obj-code
no-error .
if not available buf_gds-grp-attr
then do:
    find first buf_gds-grp-attr no-lock
         where buf_gds-grp-attr.node-code = p-node-code
           and buf_gds-grp-attr.attr-code = p-attr-code
           and buf_gds-grp-attr.host-code = v-host-code
           and buf_gds-grp-attr.obj-type  = ""
           and buf_gds-grp-attr.obj-code  = 0
    no-error .
    if not available buf_gds-grp-attr
    then do:
        find first buf_gds-grp-attr no-lock
            where buf_gds-grp-attr.node-code = p-node-code
            and buf_gds-grp-attr.attr-code = p-attr-code
            and buf_gds-grp-attr.host-code = 0
            and buf_gds-grp-attr.obj-type  = ""
            and buf_gds-grp-attr.obj-code  = 0
        no-error .
        if not available buf_gds-grp-attr
        then do:
            assign
                p-exists = no
            .
        end.
        else do:
            assign
                p-exists = yes
                p-range  = 1
            .
        end.
    end.
    else do:
        assign
            p-exists = yes
            p-range  = 2
        .
    end.
end.
else do:
    assign
        p-exists = yes
        p-range  = 3
    .
end.
if available buf_gds-grp-attr
then do:
  assign
  p-attr-value = buf_gds-grp-attr.attr-value
  .
end.
end.
end procedure.
procedure ver-gds-grp-nabor :
do
on error undo, return error return-value
:
define input  parameter p-gds-code as integer   no-undo .
define output parameter p-nabor as logical   no-undo .
define buffer buf_goods for ub.goods.
p-nabor = false .
find first  buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
if error-status :error then return error .
define variable v-value       as character  no-undo.
define variable v-type        as character  no-undo.
  run grp-attr-value (
     input   buf_goods.grp-code
    ,input   'gds-grp-nabor':U
    ,input   0
    ,input   ""
    ,input   0
    ,output  v-value
    ,output  v-type       ) no-error .
    if error-status :error then return error .
  if v-value = "yes" then p-nabor = true  .
end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION status-edoc-nn RETURN CHAR (buffer loc-o-doc for ub.ord-doc
                                   , input is-edoc-nn as logical
                                   , input is-edi as logical
                                   , output p-color as integer ).
define variable v-obj-db-num as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-obj-uniq-key-rec as character no-undo .
define buffer buf_clients for ub.clients  .
define buffer obj_clients for ub.clients  .
define buffer buf_ext-classif for ub.ext-classif  .
define buffer buf2_ext-classif for ub.ext-classif  .
define buffer buf_ext-system  for ub.ext-system  .
p-color = ?.
if not available loc-o-doc then do:
  return ''.
end.
if not ( is-edoc-nn or is-edi)
or loc-o-doc.doc-type <> 'ОП':U  then do:
  p-color = ?.
  return ''.
end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  loc-o-doc.obj-type
  ,input  loc-o-doc.obj-code
  ,output v-obj-db-num
  )  .
find first  buf_clients no-lock where
            buf_clients.obj-type = loc-o-doc.cli-type and
            buf_clients.obj-code = loc-o-doc.cli-code
              no-error .
if not available buf_clients then do:
  p-color = ?.
  return "" .
end.
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer buf_clients:handle)
                                  , output v-uniq-key-rec).
find first buf_ext-classif no-lock
      where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
        and buf_ext-classif.classif-subject = 'clients':U
        and buf_ext-classif.classif-name    = 'clients-edoc-nn':U no-error.
if available buf_ext-classif then do :
  assign
  p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , '14,12,?,10,10,?,?,?,?,?,4'))
  no-error .
  return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , ',отправлен,принят,подтвержден,подтвержденOk,согласованный ушел,принят согласованный,поставка пришла,поставка принята,ПН отправлена,Отказ') .
end.
else do :
  find first obj_clients no-lock where
            obj_clients.obj-type = loc-o-doc.obj-type
        and obj_clients.obj-code = loc-o-doc.obj-code no-error.
  if not available obj_clients then do:
    return ''.
  end.
  run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                    , input (buffer obj_clients:handle)
                                    , output v-obj-uniq-key-rec).
  for each buf_ext-classif no-lock
        where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
          and buf_ext-classif.classif-subject = 'clients':U
          and buf_ext-classif.classif-name    = 'exite-edi':U,
     first buf_ext-system no-lock
        where buf_ext-system.esys-id = buf_ext-classif.key#_one
          and buf_ext-system.db-num  = 0
          and buf_ext-system.esys-have-export = yes
          and buf_ext-system.esys-db-num-exp = v-obj-db-num,
     first buf2_ext-classif no-lock
              where buf2_ext-classif.uniq-key-rec = v-obj-uniq-key-rec
                and buf2_ext-classif.classif-subject = 'clients':U
                and buf2_ext-classif.classif-name    = 'exite-edi':U
                and buf2_ext-classif.key#_one  = buf_ext-classif.key#_one:
    assign
    p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , '14,12,?,14,?,?,10,?,?,?,?,4,10,4'))
    no-error .
    return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , ',отправлен,принят,подтвержден,подтвержден-,подтвержден+,подтвержденОк,поставка пришла,поставка принята,ПН отправлена,ПН получена,Отказ,Доставлен,Ошибка') .
  end.
  return ''.
end.
return ''.
END FUNCTION.
FUNCTION status-is-edoc-nn RETURN logical ( input p-is-edoc-nn   as logical
                                             , input p-cli-type     as character
                                             , input p-cli-code     as integer
                                             , input p-obj-type     as character
                                             , input p-obj-code     as integer
                                             ) .
define variable v-uniq-key-rec as character no-undo .
define buffer buf_clients     for ub.clients .
define buffer buf_ext-classif for ub.ext-classif .
define buffer buf_ext-system  for ub.ext-system  .
if not p-is-edoc-nn then do:
  return no.
end.
find first buf_clients no-lock
     where buf_clients.obj-type = p-cli-type
       and buf_clients.obj-code = p-cli-code
       no-error .
if not available buf_clients then do:
  return no .
end.
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer buf_clients:handle)
                                  , output v-uniq-key-rec).
find first buf_ext-classif no-lock
     where buf_ext-classif.uniq-key-rec    = v-uniq-key-rec
       and buf_ext-classif.classif-subject = 'clients':U
       and buf_ext-classif.classif-name    = 'clients-edoc-nn':U
       no-error.
if available buf_ext-classif then do :
  return yes .
end.
return no.
END FUNCTION.
FUNCTION status-is-edi RETURN logical ( input p-is-edi as logical
                                         , input p-cli-type as character
                                         , input p-cli-code as integer
                                         , input p-obj-type     as character
                                         , input p-obj-code     as integer
                                         , output p-dm-edi as integer
                                         ) .
define variable v-obj-db-num   as integer   no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-obj-uniq-key-rec as character no-undo .
define buffer buf_clients     for ub.clients .
define buffer obj_clients     for ub.clients .
define buffer buf_ext-classif for ub.ext-classif .
define buffer buf2_ext-classif for ub.ext-classif .
define buffer buf_ext-system  for ub.ext-system  .
if not p-is-edi then do:
  return no.
end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-obj-db-num
  )  .
find first buf_clients no-lock
     where buf_clients.obj-type = p-cli-type
       and buf_clients.obj-code = p-cli-code
       no-error .
if not available buf_clients then do:
  return no .
end.
find first obj_clients no-lock where
          obj_clients.obj-type = p-obj-type
      and obj_clients.obj-code = p-obj-code no-error.
if not available buf_clients then do:
  return no .
end.
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer buf_clients:handle)
                                  , output v-uniq-key-rec).
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer obj_clients:handle)
                                  , output v-obj-uniq-key-rec).
for each buf_ext-classif no-lock
      where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
        and buf_ext-classif.classif-subject = 'clients':U
        and buf_ext-classif.classif-name    = 'exite-edi':U,
    first buf_ext-system no-lock
      where buf_ext-system.esys-id = buf_ext-classif.key#_one
        and buf_ext-system.db-num  = 0
        and buf_ext-system.esys-have-export = yes
        and (buf_ext-system.esys-db-num-exp = v-obj-db-num
        or buf_ext-system.esys-db-num-exp = 0),
    first buf2_ext-classif no-lock
            where buf2_ext-classif.uniq-key-rec = v-obj-uniq-key-rec
              and buf2_ext-classif.classif-subject = 'clients':U
              and buf2_ext-classif.classif-name    = 'exite-edi':U
              and buf2_ext-classif.key#_one  = buf_ext-classif.key#_one:
  leave.
end.
if available buf_ext-classif then do :
  p-dm-edi = buf_ext-system.whole-send-news.
  return yes .
end.
return no .
END FUNCTION.
FUNCTION get-gln returns character ( input p-obj-type as character
                                    ,input p-obj-code as integer):
define variable v-uniq-key-rec as character no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.
find first buf_clients no-lock where
          buf_clients.obj-type = p-obj-type
      and buf_clients.obj-code = p-obj-code no-error.
if not available buf_clients then do:
  return chr(63).
end.
run gen-key-rec  in this-procedure ( input 'clients':U
                                    ,input (buffer buf_clients:handle)
                                    ,output v-uniq-key-rec) no-error.
if error-status:error then do:
   return chr(63).
end.
find first buf_ext-classif no-lock where
          buf_ext-classif.classif-subject = 'clients':U
      and buf_ext-classif.classif-name = 'GLN':U
      and buf_ext-classif.uniq-key-rec = v-uniq-key-rec no-error .
if available buf_ext-classif then do:
  return buf_ext-classif.charkey_one.
end.
else do:
 return ''.
end.
END FUNCTION.
FUNCTION get-type-code-from-gln returns logical ( input  p-gln      as character
                                                    ,output p-obj-type as character
                                                    ,output p-obj-code as integer) :
define variable v-uniq-key-rec as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.
find first buf_ext-classif no-lock where
          buf_ext-classif.classif-subject = 'clients':U
      and buf_ext-classif.classif-name = 'GLN':U
      and buf_ext-classif.charkey_one = p-gln no-error .
if available buf_ext-classif then do:
  assign v-uniq-key-rec = buf_ext-classif.uniq-key-rec.
end.
else do:
  assign
    p-obj-type = ''
    p-obj-code = 0
  .
  return no.
end.
if v-uniq-key-rec <> '' then do:
    run gen-key-fv in this-procedure ( input  v-uniq-key-rec
                                      ,output v-field-list
                                      ,output v-value-list).
end.
assign
  p-obj-type = entry(lookup("obj-type":U
                          , v-field-list
                          , chr(3))
                          , v-value-list, chr(3))
  p-obj-code = integer(entry(lookup("obj-code":U
                                  , v-field-list
                                  , chr(3))
                                  , v-value-list, chr(3)))
no-error .
if error-status:error then do:
  assign
    p-obj-type = ''
    p-obj-code = 0
  .
  return no.
end.
else do:
  return yes.
end.
END FUNCTION.
FUNCTION status-edoc-edi-light RETURN CHAR (buffer loc-o-doc for ub.ord-doc
                                   , input is-edoc-nn as logical
                                   , input is-edi as logical
                                   , output p-color as integer ).
p-color = ?.
if not available loc-o-doc then do:
  return ''.
end.
if not ( is-edoc-nn or is-edi)
or loc-o-doc.doc-type <> 'ОП':U  then do:
  p-color = ?.
  return ''.
end.
case loc-o-doc.whole-send-news:
  when integer('1':U) then do:
    assign
    p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , '14,12,?,10,10,?,?,?,?,?,4'))
    no-error .
    return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , ',отправлен,принят,подтвержден,подтвержденOk,согласованный ушел,принят согласованный,поставка пришла,поставка принята,ПН отправлена,Отказ') .
  end.
  when integer('2':U) then do:
    assign
    p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , '14,12,?,14,?,?,10,?,?,?,?,4,10,4'))
    no-error .
    return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , ',отправлен,принят,подтвержден,подтвержден-,подтвержден+,подтвержденОк,поставка пришла,поставка принята,ПН отправлена,ПН получена,Отказ,Доставлен,Ошибка') .
  end .
  otherwise do:
    p-color = ?.
    return ''.
  end.
end case.
end function.
procedure ord-savl_process-line :
define parameter buffer buf_ord-doc for ub.ord-doc.
define parameter buffer buf_ord-line for ub.ord-line.
define variable v-root-node like ub.gds-prt.node-code no-undo .
define variable l-goods-twounit as logical no-undo .
define variable rsrv-code       as character no-undo .
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable return-AssMin   as logical   no-undo .
define variable return-igt      as character no-undo .
define variable gdop-min-stock  as decimal   no-undo .
define variable grop-max-stock  as decimal   no-undo .
define variable grop-level-always-presence  as decimal   no-undo .
define variable grop-min-order as decimal   no-undo .
define variable num_rec as integer no-undo .
define variable var-ok-assort-pol as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable t-sum like ub.ord-line.qnty no-undo .
define variable v-str-ps as character no-undo .
define variable v-event-code as character no-undo .
define variable v-nabor       as logical   no-undo .
define variable is-edi-doc as logical no-undo .
define variable v-dm-edi  as integer no-undo .
define buffer buf_goods for ub.goods.
define buffer buf_ord-dtl for ub.ord-dtl.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  assign
  num_rec   = num_rec + 1
  .
  if num_rec mod 10 = 0 then do:
    run display-line-process in this-procedure ( input num_rec , buffer buf_ord-line).
  end.
  find first buf_goods no-lock
    where buf_goods.artic     = buf_ord-line.artic
      and buf_goods.prod-type = buf_ord-line.prod-type
      and buf_goods.prod-code = buf_ord-line.prod-code
    no-error .
  if not available buf_goods then do:
    undo main-block, return error substitute("&1 &2 &3&4Не найден товар&4"  +
                                             "Заказ &5&4 Артикул &6 &7&8&4 gds-code &9&4"
                                              ,vss-workfile
                                              ,vss-revision
                                              ,vss-description
                                              ,chr(10)
                                              ,buf_ord-line.doc-code
                                              ,buf_ord-line.artic
                                              ,buf_ord-line.prod-type
                                              ,buf_ord-line.prod-code
                                              ,buf_ord-line.gds-code ) +
                                  substitute("&1"
                                              ,(if g#db-num = 0
                                              then "Если товар был переименован, необходимо принять новости в УБД и переформировать пакеты"
                                              else "")).
   end.
  if buf_ord-doc.status_ = 'новый':U
  and buf_ord-doc.doc-type <> 'ПО':U
  and buf_ord-doc.doc-type <> 'ФП':U  then do:
     var-ok-assort-pol = true .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  buf_ord-doc.doc-type
  ,input  buf_ord-line.gds-code
  ,input  buf_ord-doc.obj-type
  ,input  buf_ord-doc.obj-code
  ,input  if g#news then false else true
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
    assign
    is-edi-doc = status-is-edi ( input yes
                        , input buf_ord-doc.cli-type
                        , input buf_ord-doc.cli-code
                        , input buf_ord-doc.obj-type
                        , input buf_ord-doc.obj-code
                        , output v-dm-edi
                        ) no-error.
    if var-ok-assort-pol = false and not g#news and not is-edi-doc then do:
      run ord-savl_del-str-info in this-procedure (  input buf_ord-doc.PS
                                                    , input var-mess-assort-pol
                                                    , output v-str-ps ) .
      buf_ord-doc.PS = v-str-ps .
      delete buf_ord-line .
      return .
    end.
    if buf_ord-doc.cli-type = 'маг':U or
      buf_ord-doc.cli-type = 'скл':U then do:
      var-ok-assort-pol = true .
      v-event-code = "cli_" + buf_ord-doc.doc-type .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  v-event-code
  ,input  buf_ord-line.gds-code
  ,input  buf_ord-doc.cli-type
  ,input  buf_ord-doc.cli-code
  ,input  if g#news then false else true
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
       if var-ok-assort-pol = false and not g#news then do:
          run ord-savl_del-str-info in this-procedure ( input buf_ord-doc.PS
                                             , input var-mess-assort-pol
                                             , output v-str-ps ) .
          buf_ord-doc.PS = v-str-ps .
          delete buf_ord-line .
          return .
       end.
     end.
   end.
   if buf_ord-doc.status_ = 'новый':U
   and buf_ord-doc.doc-type = 'ПО':U  then do:
     var-ok-assort-pol = true .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassmat in g#library2
  (input  buf_ord-line.gds-code
  ,input  buf_ord-doc.obj-type
  ,input  buf_ord-doc.obj-code
  ,input  if g#news then false else true
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  )  .
     if var-ok-assort-pol = false and not g#news then do:
       run ord-savl_del-str-info in this-procedure ( input buf_ord-doc.PS
                                          , input var-mess-assort-pol
                                          , output v-str-ps ) .
        buf_ord-doc.PS = v-str-ps .
        delete buf_ord-line .
        return .
      end.
    end.
    run ord-savl_ver-gds-flor in this-procedure ( input buf_goods.gds-code
                                        , output v-nabor ) no-error .
    if v-nabor = true then do:
      undo main-block, return error substitute("&1 &2 &3&4"  +
                                              "Заказ &5&4 Артикул &6 &7&8&4 &9&4"  +
                                              "является набором (букет) !!!&4" +
                                              "Удалите его из списка товаров !"
                                              ,vss-workfile
                                              ,vss-revision
                                              ,vss-description
                                              ,chr(10)
                                              ,buf_ord-line.doc-code
                                              ,buf_ord-line.artic
                                              ,buf_ord-line.prod-type
                                              ,buf_ord-line.prod-code
                                              ,buf_goods.gds-name ).
    end.
    if buf_goods.gds-type =  'у':U  then do:
      undo main-block, return error substitute("&1 &2 &3&4"  +
                                              "Заказ &5&4 Артикул &6 &7&8&4 &9&4"  +
                                              "является услугой !!!&4" +
                                              "Удалите его из списка товаров !"
                                              ,vss-workfile
                                              ,vss-revision
                                              ,vss-description
                                              ,chr(10)
                                              ,buf_ord-line.doc-code
                                              ,buf_ord-line.artic
                                              ,buf_ord-line.prod-type
                                              ,buf_ord-line.prod-code
                                              ,buf_goods.gds-name ).
    end.
    assign
    buf_ord-line.obj-type = buf_ord-doc.obj-type
    buf_ord-line.obj-code = buf_ord-doc.obj-code
    buf_ord-line.status_  = buf_ord-doc.status_
    .
    if buf_ord-line.cli-base-rate = ?
    or buf_ord-line.cli-base-rate = 0 then do:
      assign
      buf_ord-line.cli-base-rate = buf_goods.cli-base-rate
     .
    end.
    if buf_ord-line.unit-cli = ?
    or buf_ord-line.unit-cli = "" then do:
      assign
      buf_ord-line.unit-cli = buf_goods.unit-cli
      .
    end.
  t-sum = 0.
  for each buf_ord-dtl no-lock where
      buf_ord-dtl.doc-code  = buf_ord-line.doc-code and
      buf_ord-dtl.artic     = buf_ord-line.artic and
      buf_ord-dtl.prod-type = buf_ord-line.prod-type and
      buf_ord-dtl.prod-code = buf_ord-line.prod-code  :
    t-sum = t-sum + buf_ord-dtl.qnty.
  end.
  if t-sum > buf_ord-line.qnty then do:
    undo main-block, return error substitute("&1 &2 &3&4Количество по признакам больше чем по строке товара&4" +
                                            "Заказ &5&4 Артикул &6 &7&8&4 &9&4"  +
                                            "является услугой !!!&4" +
                                            "Удалите его из списка товаров !"
                                            ,vss-workfile
                                            ,vss-revision
                                            ,vss-description
                                            ,chr(10)
                                            ,buf_ord-line.doc-code
                                            ,buf_ord-line.artic
                                            ,buf_ord-line.prod-type
                                            ,buf_ord-line.prod-code
                                            ,buf_goods.gds-name ).
  end.
end.
end procedure .
procedure ord-savl_ver-gds-flor :
define input  parameter  p-gds-code as integer   no-undo .
define output parameter  p-nabor   as logical   no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  p-nabor = false .
  run ver-gds-grp-nabor in this-procedure ( input p-gds-code, output p-nabor) .
end.
end procedure.
procedure ord-savl_del-str-info :
define input   parameter p-str1    as character no-undo .
define input   parameter p-str-dop as character no-undo .
define output  parameter p-str2    as character no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  p-str1     = trim  (p-str1   ) .
  p-str-dop  = trim  (p-str-dop) .
  p-str1     = trim  (p-str1   ,chr(10) ) .
  p-str-dop  = trim  (p-str-dop,chr(10) ) .
  if length (p-str1) + length (p-str-dop )     >=  2000  then do:
    p-str2 = substitute ("&1 вся информация не умещается...." , p-str1 ) .
    return .
  end.
  p-str2  = substitute ("&1&3&2" , p-str1, p-str-dop ,chr(10) ) .
end.
end procedure.
define variable num_rec                as integer   no-undo .
define variable num_gds                as integer   no-undo .
define variable start-time             as integer   no-undo .
define variable current-time           as character no-undo .
define variable current-action         as character no-undo .
define variable v-description-ord-type as character no-undo .
define variable v-today                as date      no-undo.
define variable v-time                 as integer   no-undo.
define buffer bf_contract-specif for ub.contract-specif  .
define buffer buf_goods          for ub.goods  .
define variable v-curr-abbr as character no-undo .
FUNCTION is-edi-send-nws RETURN logical (  input p-cli-type as character
    , input p-cli-code as integer
    , input p-obj-type     as character
    , input p-obj-code     as integer
    ) .
    define variable v-obj-db-num       as integer   no-undo .
    define variable v-uniq-key-rec     as character no-undo .
    define variable v-obj-uniq-key-rec as character no-undo .
    define variable v-is-edi           as logical   no-undo .
    define variable par-is-edi         as character no-undo .
    define variable par-type           as character no-undo .
    define buffer buf_clients      for ub.clients .
    define buffer obj_clients      for ub.clients .
    define buffer buf_ext-classif  for ub.ext-classif .
    define buffer buf2_ext-classif for ub.ext-classif .
    define buffer buf_ext-system   for ub.ext-system  .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-obj-db-num
  )  .
    if v-obj-db-num = 0 then
    do:
        return no.
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-edi'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output par-is-edi
  ,output par-type
  ) no-error .
    v-is-edi = lookup(par-is-edi, "true,yes":U) > 0.
    if not v-is-edi then
    do:
        return no.
    end.
    find first buf_clients no-lock
        where buf_clients.obj-type = p-cli-type
        and buf_clients.obj-code = p-cli-code
        no-error .
    if not available buf_clients then
    do:
        return no .
    end.
    find first obj_clients no-lock where
        obj_clients.obj-type = p-obj-type
        and obj_clients.obj-code = p-obj-code no-error.
    if not available buf_clients then
    do:
        return no .
    end.
    run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
        , input (buffer buf_clients:handle)
        , output v-uniq-key-rec).
    run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
        , input (buffer obj_clients:handle)
        , output v-obj-uniq-key-rec).
    for each buf_ext-classif no-lock
        where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
        and buf_ext-classif.classif-subject = 'clients':U
        and buf_ext-classif.classif-name    = 'exite-edi':U,
        first buf_ext-system no-lock
        where buf_ext-system.esys-id = buf_ext-classif.key#_one
        and buf_ext-system.db-num  = 0
        and buf_ext-system.esys-have-export = yes
        and buf_ext-system.esys-db-num-exp = 0
        ,
        first buf2_ext-classif no-lock
        where buf2_ext-classif.uniq-key-rec = v-obj-uniq-key-rec
        and buf2_ext-classif.classif-subject = 'clients':U
        and buf2_ext-classif.classif-name    = 'exite-edi':U
        and buf2_ext-classif.key#_one  = buf_ext-classif.key#_one:
        leave.
    end.
    if available buf_ext-classif then
    do :
        return yes .
    end.
    return no .
END FUNCTION.
assign
    v-description-ord-type = ub.ord-doc.doc-type
    .
define frame a
    ub.ord-doc.doc-code                        label "Заказ" skip
    v-description-ord-type                     label "Тип документа" skip
    current-action         format "x(40)"      no-label skip
    num_rec                format ">>>>>>>9"   label "Обработано артикулов" skip
    ub.ord-line.artic                          label "Текущий артикул" skip
    num_gds                format ">>>>>>>9"   label "Обработано признаков" skip
    current-time           format "x(8)"       label "Время" skip
    with view-as dialog-box side-labels three-d
    title "Обработка заказа"
    .
main-block :
do transaction
    on error undo main-block, return error
    :
    define variable kol-str as integer no-undo .
    kol-str = 0.
    if not g#news
        then
    do:
        if ub.ord-doc.contract-code > 0  and
            not ( ub.ord-doc.status_ = 'факт':U or
            ub.ord-doc.status_ = 'отказ':U)
            then
        do:
            find first bf_contract-specif where bf_contract-specif.host-code    = ub.ord-doc.host-code     and
                bf_contract-specif.contract-num = ub.ord-doc.contract-code no-lock no-error.
            if available bf_contract-specif then
            do:
                for each ub.ord-line no-lock where
                    ub.ord-line.doc-code = ub.ord-doc.doc-code :
                    if not can-find (first bf_contract-specif no-lock where
                        bf_contract-specif.host-code    = ub.ord-doc.host-code and
                        bf_contract-specif.contract-num = ub.ord-doc.contract-code and
                        bf_contract-specif.gds-code     = ub.ord-line.gds-code   ) then
                    do:
                        message
                            "Выбран Договор со спецификацией !!!" skip
                            "Несоответствие списка товаров заказа и спецификации " skip
                            "Заказ      :" ub.ord-doc.doc-code        skip
                            "код товара :" ub.ord-line.gds-code skip
                            "артикл     :" ub.ord-line.artic skip
                            view-as alert-box error .
                    end.
                end.
            end.
        end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdburt in g#library
  (output ub.ord-doc.user-db-num
  ,output ub.ord-doc.user-name
  ,output ub.ord-doc.sys-date
  ,output ub.ord-doc.sys-time
  ,output ub.ord-doc.sys-time-int
  )  .
        if ub.ord-doc.status_ = 'новый':U then
        do:
            if ub.ord-doc.exch-rate = 0 or ub.ord-doc.exch-scale = 0  then
            do:
                if ub.ord-doc.exch-code = ? then  ub.ord-doc.exch-code = 0 .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  ub.ord-doc.exch-code
  ,input  ub.ord-doc.doc-date
  ,output ub.ord-doc.exch-rate
  ,output ub.ord-doc.exch-scale
  ,output v-curr-abbr
  )  .
            end.
            if ub.ord-doc.base-rate = 0 or ub.ord-doc.base-scale = 0  then
            do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  ub.ord-doc.host-code
  ,input  ub.ord-doc.doc-date
  ,output ub.ord-doc.base-rate
  ,output ub.ord-doc.base-scale
  ) no-error .
            end.
            for each ub.ord-line exclusive-lock
                where ub.ord-line.doc-code = ub.ord-doc.doc-code :
                find first buf_goods no-lock where
                    buf_goods.artic = ub.ord-line.artic and
                    buf_goods.prod-type = ub.ord-line.prod-type  and
                    buf_goods.prod-code = ub.ord-line.prod-code no-error .
                if available buf_goods then
                    assign
                        ub.ord-line.gds-code = buf_goods.gds-code
                        .
                kol-str = kol-str + 1.
            end.
            ub.ord-doc.tot-lines = kol-str .
            run sum-head .
        end.
        if new(ub.ord-doc)  then
            assign
                ub.ord-doc.real-date-create = today
                ub.ord-doc.real-time-create = time
                ub.ord-doc.creid            = g#userid
                ub.ord-doc.fact-num         = next-value (s-ORD-fact, ub)
                .
    end.
    if ub.ord-doc.status_ = 'согласование':U then
    do:
        assign
            ub.ord-doc.creid = g#userid
            .
    end.
    if ub.ord-doc.doc-type = 'ОР':U
        and ub.ord-doc.status_ <> 'новый':U
        and g#db-num = 0
        and g#news
        then
    do:
        run str/callnews.p
            (input 'ord-doc':U
            ,input (buffer ub.ord-doc:handle)
            ) no-error .
        if error-status :error then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Невозможно маршрутизировать ord-doc для отправки в новости" skip
                "Заказ О-РЦ " ub.ord-doc.doc-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            undo, return error .
        end.
    end.
    define variable l-date as date      no-undo .
    define variable l-time as integer   no-undo .
    define variable s-date as date      no-undo .
    define variable s-num  as integer   no-undo .
    define variable s-name as character no-undo .
    if ub.ord-doc.status_ = 'факт':U then
    do:
        if not g#news then
        do:
            run cur-time in this-procedure (output l-date , output l-time) no-error .
            ub.ord-doc.fact-time  = l-time .
            run gbl/factdate.p ( input        ub.ord-doc.obj-type  ,
                input        ub.ord-doc.obj-code   ,
                input-output ub.ord-doc.fact-date ,
                input-output ub.ord-doc.fact-time ,
                input-output s-date  ,
                input-output s-num ,
                input-output s-name,
                input        yes     ).
            assign
                ub.ord-doc.shift-date = s-date
                ub.ord-doc.shift-num  = s-num
                ub.ord-doc.shift-name = s-name.
            if ub.ord-doc.fact-num =  0 or ub.ord-doc.fact-num = ?  then
            do:
                assign
                    ub.ord-doc.fact-num = next-value (s-ORD-fact, ub)
                    .
            end.
            if ub.ord-doc.fact-order =  0 or ub.ord-doc.fact-order = ?  then
            do:
                define variable v-fact-order           as decimal no-undo .
                define variable v-shift-end-fact-order as decimal no-undo .
                define variable v-day-end-fact-order   as decimal no-undo .
                define variable l-shift-on             as logical no-undo .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  ub.ord-doc.obj-type
  ,input  ub.ord-doc.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) no-error .
                if error-status :error then
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Ошибка при определении атрибута объекта" skip
                        "Заказ" ub.ord-doc.doc-code skip
                        "Объект" ub.ord-doc.obj-type ub.ord-doc.obj-code skip
                        error-status :get-message(1) skip
                        return-value skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                run factord in this-procedure
                    (input  ub.ord-doc.fact-date
                    ,input  ub.ord-doc.fact-time
                    ,input  ub.ord-doc.fact-num
                    ,input  ub.ord-doc.shift-date
                    ,input  ub.ord-doc.shift-num
                    ,input  l-shift-on
                    ,output v-fact-order
                    ,output v-shift-end-fact-order
                    ,output v-day-end-fact-order
                    ) no-error .
                if error-status :error
                    or v-fact-order = ?
                    or v-fact-order = 0 then
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Ошибка при определении фактического номера складского документа" skip
                        "Заказ" ub.ord-doc.doc-code skip
                        "fact-date"               ub.ord-doc.fact-date   skip
                        "fact-time"               ub.ord-doc.fact-time   skip
                        "fact-num"                ub.ord-doc.fact-num    skip
                        "shift-date"              ub.ord-doc.shift-date  skip
                        "shift-num"               ub.ord-doc.shift-num   skip
                        "v-fact-order"            v-fact-order           skip
                        "v-shift-end-fact-order"  v-shift-end-fact-order skip
                        "v-day-end-fact-order"    v-day-end-fact-order   skip
                        error-status :get-message(1) skip
                        return-value skip
                        view-as alert-box error .
                    undo, return error .
                end.
                assign
                    ub.ord-doc.fact-order = v-fact-order
                    .
            end.
        end.
    end.
    run cur-time in this-procedure ( output v-today
        , output start-time
        ).
    assign
        current-action = "Проверка статуса."
        .
    view frame a.
    display
        ub.ord-doc.doc-code
        v-description-ord-type
        with frame a.
    if g#news  = false then
    do:
        if  not (ub.ord-doc.status_ = 'новый':U and ub.ord-doc.flag_ = false and old_ord-doc.obj-code <> 0 ) or
            ( old_ord-doc.user-name <> g#userid )
            then
        do:
            create ub.c-ord-doc.
            BUFFER-COPY old_ord-doc  TO ub.c-ord-doc
                assign
                ub.c-ord-doc.chip-num           = next-value (s-corr-chip, ub)
                ub.c-ord-doc.corr-time          = start-time
                ub.c-ord-doc.corr-user-db-num   = g#db-num
                ub.c-ord-doc.corr-user-name     = g#userid
                ub.c-ord-doc.corr-date          = v-today
                .
        end.
    end.
    if  (( ub.ord-doc.status_    = 'отказ':U
        or
        ( ub.ord-doc.status_    = 'запрос':U  and ub.ord-doc.flag_ = true and ub.ord-doc.doc-type   = 'ОО':U )
        or
        ( ub.ord-doc.status_    = 'запрос':U  and ub.ord-doc.doc-type   = 'ОР':U )
        or
        ( ub.ord-doc.status_    = 'разрешено':U  and ub.ord-doc.doc-type   = 'ОР':U )
        or
        ( ub.ord-doc.status_    = 'отгружено':U and ub.ord-doc.doc-type   = 'ОР':U )
        or
        ub.ord-doc.status_    = 'факт':U
        or
        ( ub.ord-doc.status_    = 'поставка':U and
        old_ord-doc.out-code  <> ub.ord-doc.out-code )
        or
        ( ub.ord-doc.order-type = 2 and
        g#db-num <> 0 and
        ub.ord-doc.status_    = 'новый':U and
        ub.ord-doc.flag_      = true  and
        ub.ord-doc.doc-type   = 'ОО':U )
        or
        ( ub.ord-doc.order-type = 3 and
        g#db-num = 0 and
        ub.ord-doc.status_    = 'новый':U and
        ub.ord-doc.flag_      = true  and
        ub.ord-doc.doc-type   = 'ОО':U )
        ) and
        g#news  = false)
        or is-edi-send-nws(ub.ord-doc.cli-type, ub.ord-doc.cli-code, ub.ord-doc.obj-type, ub.ord-doc.obj-code)
        then
    do:
        run str/callnews.p
            (input 'ord-doc':U
            ,input (buffer ub.ord-doc:handle)
            ) no-error .
        if error-status :error then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Невозможно маршрутизировать ord-doc для отправки в новости" skip
                "Заказ" ub.ord-doc.doc-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            undo, return error .
        end.
    end.
    define variable v-message as character no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input  (if ub.ord-doc.doc-type = 'ОР':U then 'event_intorder':U else 'event_order':U)
  ,input  buffer old_ord-doc:handle
  ,input  buffer ub.ord-doc:handle
  ,input ''
  ,input ''
  ) no-error .
    if error-status:error
        then
    do:
        v-message = substitute("&1 &2 &3&4Ошибка при вызове процедуры rum-runa.i&4&5&4&5&6"
            ,vss-workfile
            ,vss-revision
            ,vss-description
            ,chr(10)
            , error-status:get-message(1)
            , return-value ).
        if not g#news then
        do:
            message
                v-message
                view-as alert-box error .
        end.
        undo main-block,  return error v-message.
    end.
    assign
        current-action = "Проверка строк."
        .
    for each ub.ord-line exclusive-lock
        where ub.ord-line.doc-code = ub.ord-doc.doc-code
        on error undo main-block, return error
        on end-key undo main-block, return error
        :
        run ord-savl_process-line in this-procedure ( buffer ub.ord-doc, buffer ub.ord-line) no-error .
        if error-status :error then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при обработке товара" skip
                "Заказ" ub.ord-doc.doc-code skip
                "Артикул" ub.ord-line.artic ub.ord-line.prod-type ub.ord-line.prod-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
        end.
    end.
    if new ub.ord-doc then
    do:
        run trg/userlog.p (
            input 'create':U
            , input 'ord-doc':U
            , input ( buffer ub.ord-doc :handle )
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
            , input 'ord-doc':U
            , input ( buffer ub.ord-doc :handle )
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
            input 'update':U
            , input 'ord-doc':U
            , input ( buffer ub.ORD-doc:handle )
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
procedure show-action :
    do
        on error undo, return error
        :
        define input parameter p-action as character no-undo .
        define variable v-today as date    no-undo.
        define variable v-time  as integer no-undo.
        run cur-time in this-procedure ( output v-today
            , output v-time
            ).
        assign
            current-time   = string(v-time - start-time, "HH:MM:SS")
            current-action = p-action
            .
        display
            current-time current-action
            with frame a.
    end.
end procedure.
procedure sum-head :
    do
        on error undo, return error return-value
        :
        assign
            ub.ord-doc.qnty     = 0
            ub.ord-doc.cli-qnty = 0
            ub.ord-doc.sum-cli  = 0
            ub.ord-doc.sum-rubl = 0
            ub.ord-doc.sum-base = 0
            .
        for each ub.ord-line no-lock where
            ub.ord-line.doc-code = ub.ord-doc.doc-code :
            assign
                ub.ord-doc.qnty     = ub.ord-doc.qnty + ub.ord-line.qnty
                ub.ord-doc.cli-qnty = ub.ord-doc.cli-qnty + ub.ord-line.cli-qnty
                ub.ord-doc.sum-cli  = ub.ord-doc.sum-cli  + ( ub.ord-line.cli-qnty * ub.ord-line.price-cli)
                ub.ord-doc.sum-rubl = ub.ord-doc.sum-rubl + ( ub.ord-line.qnty * ub.ord-line.price-rubl )
                ub.ord-doc.sum-base = ub.ord-doc.sum-base + ( ub.ord-line.qnty * ub.ord-line.price-base )
                .
        end.
    end.
end procedure.
procedure display-line-process :
    define input parameter p-num-rec as integer no-undo .
    define parameter buffer buf_ord-line for ub.ord-line.
    DEFINE VARIABLE v-today as date    no-undo .
    DEFINE VARIABLE v-time  as integer no-undo .
    do
        on error undo, return error
        :
        run cur-time in this-procedure ( output v-today
            ,output v-time
            ).
        assign
            current-time = string(v-time - start-time, "HH:MM:SS")
            .
        display
            p-num-rec  @ num_rec
            buf_ord-line.artic
            num_gds
            current-time
            current-action
            with frame a.
    end.
end procedure.
