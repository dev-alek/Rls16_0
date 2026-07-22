block-level on error undo, throw.
define input parameter p-sys-key  as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: f0ae80db3135, 3548, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/11/27 08:31:17 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: kick-db.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/kick-db.p $":U .
define variable vss-description as character no-undo init "Закачка валют, едизм, стран, налогов".
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
procedure cli-grplib-get-full-name :
   define input parameter  p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    define buffer buf_upper_cli-grp for ub.cli-grp.
    find first buf_cli-grp no-lock
         where buf_cli-grp.node-code = p-node-code
    no-error.
    if not available buf_cli-grp
    then do:
        undo, return error "cli-grplib-get-full-name: Не найдена группа клиентов с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_cli-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_cli-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_cli-grp.upper-code
        .
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = v-upper-code
        no-error.
        if not available buf_cli-grp
        then do:
            undo, return error "cli-grplib-get-full-name: Не найдена группа клиентов с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure cgrplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_cli-grp       for ub.cli-grp.
do
on error undo, return error
:
  find first buf_cli-grp no-lock
      where buf_cli-grp.upper-code = 0
  no-error .
  if not available buf_cli-grp
  then do:
      undo, return error substitute("Не найдена корневая группа клиентов (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_cli-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_cli-grp no-lock where
              buf_cli-grp.node-name = v-entry
          and buf_cli-grp.upper-code = v-upper-code
          no-error.
    if not available buf_cli-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_cli-grp.node-code.
      v-upper-code = buf_cli-grp.node-code.
    end.
  end.
end.
end .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-b-code :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter p-b-code  like ub.bar-code.b-code       no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-b-code). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-b-code). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-b-code). endkey", vss-workfile )
  :
    define buffer buf_thbj-attr     for ub.thbj-attr .
    define buffer buf_sys-ctrl   for ub.sys-ctrl .
    define buffer buf_code-range for ub.code-range .
    define variable l-code         as   integer              no-undo .
    define variable v-db-num       like ub.db.db-num         no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .
    if type-code = 'sslc':U
    or type-code = 'ssgb':U
    then do:
      message
        "Нельзя генерировать локальный или глобальный взвешиваемый код." skip
        "Обратитесь к администратору системы."
        view-as alert-box error .
      undo, return error (if type-code = 'sslc':U then "loc-ss-code":U else "gbl-ss-code" ) .
    end.
    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    run get-next-seq( input  type-code,
                      output l-code
                    ).
    find first buf_sys-ctrl no-lock.
    if type-code = 'sclc':U
    or type-code = 'pglc':U
    then do:
      assign
        v-db-num = 0
      .
    end.
    else do:
      assign
        v-db-num = buf_sys-ctrl.db-num
      .
    end.
    find first buf_code-range no-lock
      where buf_code-range.db-num     = v-db-num
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "a"
      use-index stts
      no-error .
    if available buf_code-range
       and l-code <= buf_code-range.last-code
       and l-code >= buf_code-range.first-code then do:
      assign
        p-b-code = l-code
      .
    end.
    else do:
      if available buf_code-range
         and l-code < buf_code-range.last-code then do:
        message
          substitute( "Последовательность для создания кодов с типом &1 имеет неверное значение.", type-code ) skip
          "Обратитесь к администратору системы."
          view-as alert-box error .
        undo, return error "sequence":U .
      end.
      do transaction
      on error undo, return error
      :
        find first buf_thbj-attr exclusive-lock
          where buf_thbj-attr.upper-prop-code = 'code-range':U
            and buf_thbj-attr.prop-code = cfg-param-code
            and buf_thbj-attr.obj-type   = 'БД':U
            and buf_thbj-attr.obj-code   = v-db-num
          no-error .
        if not available buf_thbj-attr then do:
          find first buf_thbj-attr exclusive-lock
            where buf_thbj-attr.upper-prop-code = 'code-range':U
              and buf_thbj-attr.prop-code = cfg-param-code
              and buf_thbj-attr.obj-type   = ''
              and buf_thbj-attr.obj-code   = 0
            no-error .
          if not available buf_thbj-attr then do:
            if not locked buf_thbj-attr then do:
              message
                substitute( "Отсутствует параметр 'длина диапазона кодов' (&1) для БД &2.", cfg-param-code, buf_sys-ctrl.db-num ) skip
                "Обратитесь к администратору системы."
                view-as alert-box error .
            end.
            undo, return error "config":U .
          end.
        end.
        run get-next-seq( input type-code,
                          output l-code
                        ).
        find first buf_code-range
          where buf_code-range.db-num     = v-db-num
            and buf_code-range.range-type = type-code
            and buf_code-range.stts       = "a"
          use-index stts
          no-error .
        if available buf_code-range
        and l-code <= buf_code-range.last-code
        and l-code >= buf_code-range.first-code
        then do:
          assign
            p-b-code = l-code
          .
        end.
        else do:
          if available buf_code-range then do:
            assign
              buf_code-range.stts = "u"
            .
          end.
          find first buf_code-range
            where buf_code-range.db-num     = v-db-num
              and buf_code-range.range-type = type-code
              and buf_code-range.stts       = "f"
            use-index stts
            no-error .
          if not available buf_code-range then do:
            message
              substitute( "Отсутствует свободный диапазон для кодов с типом &1.", type-code ) skip
              "Обратитесь к администратору системы"
              view-as alert-box error .
            undo, return error "code-range":U .
          end.
          assign
            buf_code-range.stts           = "a"
          .
          if buf_code-range.first-code = 1 then do:
            run set-seq-cr( input type-code,
                            input buf_code-range.first-code
                          ).
            assign
              p-b-code = 1
            .
          end.
          else do:
            run set-seq-cr( input type-code,
                            input ( buf_code-range.first-code - 1 )
                          ).
            run get-next-seq( input type-code,
                              output p-b-code
                            ).
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure get-next-seq :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter next-seq  as   integer                  no-undo .
  do
  on error  undo, return error substitute( "&1 (get-next-seq). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-next-seq). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-next-seq). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          next-seq = next-value(s-bcgb-code, ub)
        .
      end.
      when 'scgb':U then do:
        assign
          next-seq = next-value(s-scgb-code, ub)
        .
      end.
      when 'sclc':U then do:
        assign
          next-seq = next-value(s-sclc-code, ub)
        .
      end.
      when 'pglc':U then do:
        assign
          next-seq = next-value(s-pglc-code, ub)
        .
      end.
      when 'dcgb':U then do:
        assign
          next-seq = next-value(s-dcgb-code, ub)
        .
      end.
      when 'ctgb':U then do:
        assign
          next-seq = next-value(s-ctgb-code, ub)
        .
      end.
      when 'drgb':U then do:
        assign
          next-seq = next-value(s-drgb-code, ub)
        .
      end.
      when 'fmgb':U then do:
        assign
          next-seq = next-value(s-fmgb-code, ub)
        .
      end.
      when 'pngb':U then do:
        assign
          next-seq = next-value(s-pngb-code, ub)
        .
      end.
      when 'cagb':U then do:
        assign
          next-seq = next-value(s-cagb-code, ub)
        .
      end.
      when 'fdgb':U then do:
        assign
          next-seq = next-value(s-fin-doc, ub)
        .
      end.
    end case.
  end.
end procedure.
procedure set-seq-cr :
  define input parameter type-code like ub.code-range.range-type no-undo .
  define input parameter set-val   like ub.code-range.first-code no-undo .
  do
  on error  undo, return error substitute( "&1 (set-seq-cr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (set-seq-cr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (set-seq-cr). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          current-value(s-bcgb-code, ub) = set-val
        .
      end.
      when 'scgb':U then do:
        assign
          current-value(s-scgb-code, ub) = set-val
        .
      end.
      when 'sclc':U then do:
        assign
          current-value(s-sclc-code, ub) = set-val
        .
      end.
      when 'pglc':U then do:
        assign
          current-value(s-pglc-code, ub) = set-val
        .
      end.
      when 'dcgb':U then do:
        assign
          current-value(s-dcgb-code, ub) = set-val
        .
      end.
      when 'ctgb':U then do:
        assign
          current-value(s-ctgb-code, ub) = set-val
        .
      end.
      when 'drgb':U then do:
        assign
          current-value(s-drgb-code, ub) = set-val
        .
      end.
      when 'fmgb':U then do:
        assign
          current-value(s-fmgb-code, ub) = set-val
        .
      end.
      when 'pngb':U then do:
        assign
          current-value(s-pngb-code, ub) = set-val
        .
      end.
      when 'cagb':U then do:
        assign
          current-value(s-cagb-code, ub) = set-val
        .
      end.
      when 'fdgb':U then do:
        assign
          current-value(s-fin-doc, ub) = set-val
        .
      end.
    end case.
  end.
end procedure.
procedure new-bcod-gen-code-range :
  do
  on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
  :
    define input parameter p-db-num  like ub.db.db-num             no-undo .
    define input parameter type-code like ub.code-range.range-type no-undo .
    define buffer buf_code-range      for ub.code-range .
    define buffer last_code-range     for ub.code-range .
    define buffer last-1_code-range   for ub.code-range .
    define buffer last-2_code-range   for ub.code-range .
    define buffer last-3_code-range   for ub.code-range .
    define buffer buf_sys-ctrl        for ub.sys-ctrl .
    define variable conf-par       as character no-undo .
    define variable par-type       as character no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .
    define variable v-cre-cdrg as logical   no-undo .
    define variable v-cre-str  as character no-undo .
    define variable v-cr1      as integer no-undo .
    define variable v-cr2      as integer no-undo .
    define variable v-cr3      as integer no-undo .
    define variable v-cmax     as integer no-undo .
    find first buf_sys-ctrl no-lock .
    if buf_sys-ctrl.db-num <> 0 and type-code <> 'cagb':U then do:
      undo, return error substitute("&1 &2 &3&4Диапазоны кодов можно создавать только в ГБД&4База данных &5"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    , p-db-num
                                   ).
    end.
    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    for each buf_code-range
      where buf_code-range.db-num     = -1
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "f"
    by buf_code-range.first-code
    on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
    :
      assign
        buf_code-range.db-num = p-db-num
      .
      return .
    end.
    assign
      v-cre-cdrg = TRUE
    .
    case type-code:
      when 'sclc':U
      or when 'scgb':U
      or when 'pglc':U
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = 'sclc':U
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = 'scgb':U
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = 'pglc':U
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
        if last_code-range.last-code + 1 > 99999 then do:
          assign
            v-cre-cdrg = FALSE
          .
        end.
      end.
      when 'bcgb':U
      or when 'sslc':U
      or when 'ssgb':U
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = 'sslc':U
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = 'bcgb':U
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = 'ssgb':U
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
      end.
      otherwise do:
        find last last_code-range no-lock
          where last_code-range.range-type = type-code
          no-error .
      end.
    end case.
    if not available last_code-range then do:
      undo, return error substitute("&1 &2 &3&4В БД нет ни одного диапазона с типом &5&4Не была проведена инициализация диапазонов!"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    , chr(10)
                                    , type-code
                                   ) .
    end.
    define variable v-mes6 as character no-undo .
    define variable v-param-type6 as character no-undo .
    define variable v-value-character6 as INTEGER no-undo .
    define variable v-value-date6 as date no-undo .
    define variable v-value-decimal6 as decimal no-undo .
    define variable v-value-integer6 AS integer no-undo .
    define variable v-value-logical6 AS LOGICAL no-undo .
    define variable v-tth6 as handle no-undo .
    run adm/shattri.p (
        input "get":U
        ,input  'БД':U
        ,input  p-db-num
        ,input  'code-range':U
        ,input  cfg-param-code
        ,output v-value-character6
        ,output v-value-date6
        ,output v-value-decimal6
        ,output v-value-integer6
        ,output v-value-logical6
        ,output v-param-type6
        ,INPUT-OUTPUT table-handle v-tth6
        ) no-error .
    if error-status :error then do:
      delete object v-tth6.
      v-mes6 = substitute("Ошибка при получении размера диапазона собственных глобальных кодов&2&1&2&3"
                         , error-status:get-message(1)
                         , chr(10)
                         , return-value ).
      undo, return error v-mes6.
    end.
    delete object v-tth6.
    if v-cre-cdrg = TRUE then do:
      create buf_code-range .
      assign
        buf_code-range.db-num     = p-db-num
        buf_code-range.range-type = type-code
        buf_code-range.stts       = "f"
        buf_code-range.first-code = last_code-range.last-code + 1
        buf_code-range.last-code  = last_code-range.last-code + integer(v-value-integer6)
        v-cre-str = "Свободный диапазон успешно создан"
      .
    end.
    else do:
      assign
        v-cre-str = "Нет возможности создать свободный диапазон." + chr(10)
                    + substitute( "Превышен предел диапазонов c типом &1", type-code )
      .
    end.
  end.
  return v-cre-str .
end procedure.
procedure gen-new-code-range-if-neces :
  define input parameter v-db-num           like ub.db.db-num             no-undo .
  define input parameter v-range-type       like ub.code-range.range-type no-undo .
  define input parameter v-cur-code         as   integer                  no-undo .
  define input parameter v-g#news           as   logical                  no-undo .
  define input parameter v-g#db-num         like ub.db.db-num             no-undo .
  define input parameter v-g#news-source-db like ub.db.db-num             no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-new-code-range-if-neces). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-new-code-range-if-neces). endkey", vss-workfile )
  :
    define variable l-code-range-exist as logical   no-undo init false .
    define variable v-db-for-send      as character no-undo .
    define buffer buf_code-range  for ub.code-range .
    define buffer buf1_code-range for ub.code-range .
    define buffer buf_db          for ub.db .
    find first buf_code-range
      where buf_code-range.range-type = v-range-type
        and buf_code-range.last-code >= v-cur-code
      use-index last-codei
      no-error .
    if
    (
       available buf_code-range
       and
      (buf_code-range.db-num = v-db-num
        and
      buf_code-range.first-code <= v-cur-code
      )
    or
      (
        v-range-type = 'drgb':U
        AND
        v-cur-code = 0
      )
   )
   then do:
      assign
        l-code-range-exist = true
      .
      if v-g#news
      and buf_code-range.stts = "f" then do:
        assign
          buf_code-range.stts = "u"
        .
      end.
    end.
    if not l-code-range-exist
       and v-g#news-source-db <> 0
    then do:
      undo, return error substitute("&1 &2 &3&4Отсутствует диапазон кодов для БД &5 Тип диапазона кодов &6 Код &7"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    ,v-db-num
                                    ,v-range-type
                                    ,v-cur-code
                                   ).
    end.
    if (not l-code-range-exist
        or ( v-cur-code >= int( (buf_code-range.first-code + buf_code-range.last-code) / 2 ) )
       )
    and ( not can-find (first buf1_code-range no-lock
                        where buf1_code-range.db-num = v-db-num
                          and buf1_code-range.range-type = v-range-type
                          and buf1_code-range.stts = "f"
                       )
        )
    then do:
      if v-g#db-num = 0 then do:
        run new-bcod-gen-code-range in this-procedure
          (input v-db-num,
           input v-range-type
          ) no-error .
        if error-status :error then do:
          undo, return error substitute("Ошибка при создании нового свободного диапазона &1 Тип диапазона кодов &2 Код &3:&4&5 &6"
                                        , substitute("&1 &2 &3", vss-workfile, vss-revision, vss-description)
                                        ,v-db-num
                                        ,v-range-type
                                        ,v-cur-code
                                        ,chr(10)
                                        ,error-status:get-message(1)
                                        ,return-value
                                       ).
        end.
      end.
      else do:
        if v-range-type = 'sclc':U
        or v-range-type = 'pglc':U
        then do:
          assign
            v-db-for-send = "":U
          .
          if v-g#db-num = 0 then do:
            for each buf_db no-lock
              where buf_db.db-num > 0
                and buf_db.db-num <> v-g#news-source-db
            on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
            :
              assign
                v-db-for-send = v-db-for-send + chr(1) + string( buf_db.db-num )
              .
            end.
            assign
              v-db-for-send = right-trim( v-db-for-send, chr(1) )
            .
          end.
          else do:
            if not v-g#news then do:
              assign
                v-db-for-send = "0":U
              .
            end.
          end.
          run nws/cr-route.p ( input 'send-cmd':U
                        ,input ("command":U + chr(1) + "create":U + chr(1) +
                               "code-range":U + chr(1) +
                               (if v-range-type = 'sclc':U
                                then string( current-value(s-sclc-code, ub))
                                else string( current-value(s-pglc-code, ub))
                                ) + chr(1) +
                                v-range-type)
                        ,input ?
                        ,input v-db-for-send
                        ) no-error .
          if error-status :error then do:
            undo, return error return-value.
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure cre-loc-sc-code-range :
  define input parameter v-cur-code as integer no-undo .
define input parameter p-cdrg-type as character no-undo .
  do
  on error  undo, return error substitute( "&1 (cre-loc-sc-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (cre-loc-sc-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (cre-loc-sc-code-range). endkey", vss-workfile )
  :
    define buffer buf_code-range for ub.code-range .
    find first buf_code-range
         where buf_code-range.range-type = p-cdrg-type
           and buf_code-range.first-code >= v-cur-code
         no-error .
    if not available buf_code-range then do:
      run new-bcod-gen-code-range in this-procedure
        ( input 0,
          input p-cdrg-type
        ) no-error .
      if error-status :error then do:
        undo, return error substitute( "Ошибка при создании нового свободного диапазона локальных весовых или штучных кодов&1"
                                       + "Код &2&1&3 &4"
                                      , chr(10)
                                      , v-cur-code
                                      , error-status:get-message(1)
                                      , return-value
                                     ) .
      end.
    end.
  end.
end procedure.
procedure mark-used-if-need :
define input parameter p-cur-code as integer no-undo .
define input parameter p-range-type like ub.code-range.range-type no-undo .
define input parameter p-db-num like ub.code-range.db-num no-undo .
  do
  on error  undo, return error substitute( "&1 (mark-used-if-need). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (mark-used-if-need). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (mark-used-if-need). endkey", vss-workfile )
  :
    DEFINE VARIABLE v-db-num like ub.code-range.db-num no-undo .
    define buffer buf_code-range for ub.code-range .
    assign
    v-db-num = if p-range-type = 'sclc':U
               then 0
               else p-db-num
    .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer locK-batchprocess7 for ub.batchprocess.
run gbl/lock-prc.p
    (input 'lscc':U
    ,input 0
    ,input 0
    ,input 0
    ,input ""
    ,input ""
    ,input ""
    ,input (
            ",,,Вкл/выкл лок. вес. кодов"
           )
    ,input true
    ,buffer lock-batchprocess7
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент идет процесс вкл/выкл лок. вес. кодов" skip
      view-as alert-box error .
    undo, return error .
  end.
    find first buf_code-range
         where buf_code-range.range-type = p-range-type
           and buf_code-range.first-code >= p-cur-code
           and buf_code-range.last-code <= p-cur-code
           and buf_code-range.db-num = v-db-num
         no-error .
    if not available buf_code-range then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании поиске диапазона" skip
        "База данных" p-db-num skip
        "Код" p-cur-code skip
        "Тип" p-range-type
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_code-range.stts = "f":U then do:
      assign
      buf_code-range.stts = "u":U
      .
    end.
  end.
end procedure.
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define  variable p-extra-to as integer no-undo .
define variable v-call-proc as handle no-undo.
define variable v-func-list as character no-undo.
v-call-proc = this-procedure:instantiating-procedure.
if valid-handle(v-call-proc) then do:
  v-func-list = v-call-proc:INTERNAL-ENTRIES.
  if can-do(v-func-list, "get-param") then do:
    run value("get-param") in v-call-proc (output p-extra-to).
  end.
end.
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable glog as logical no-undo .
define variable v-cntxt-db-num         like ub.sys-ctrl.db-num   no-undo.
define variable v-cntxt-userid         as   character            no-undo.
define buffer buf_sys-ctrl for DICTDB.sys-ctrl.
define variable v-is-1c-erp  as logical no-undo.
define variable country-path as char no-undo.
define variable menu-grp-path as character no-undo .
define temp-table for-country      no-undo like ub.country .
define temp-table temp_fbr-gds-grp no-undo like ub.fbr-gds-grp.
define buffer buf_currency          for DICTDB.currency .
define buffer buf_curr-accnt        for DICTDB.curr-accnt .
define buffer buf_curr-bank         for DICTDB.curr-bank .
define buffer buf_units             for DICTDB.units .
define buffer buf_cli-grp           for DICTDB.cli-grp .
define buffer buf_clients           for DICTDB.clients .
define buffer buf_clients-attr      for DICTDB.clients-attr .
define buffer buf_firm              for DICTDB.firm .
define buffer buf_cash-pay          for DICTDB.cash-pay .
define buffer buf_wealth            for DICTDB.wealth .
define buffer buf_pay-type          for DICTDB.pay-type .
define buffer buf_global-state      for DICTDB.global-state .
define buffer buf_trn-reason        for DICTDB.trn-reason .
disable triggers for load of DICTDB.country .
disable triggers for load of DICTDB.currency .
disable triggers for load of DICTDB.curr-accnt .
disable triggers for load of DICTDB.curr-bank .
disable triggers for load of DICTDB.units .
disable triggers for load of DICTDB.tax .
disable triggers for load of DICTDB.tax-rate .
disable triggers for load of DICTDB.tax-rate-attr .
disable triggers for load of DICTDB.tax-rate-value .
disable triggers for load of DICTDB.tax-units .
disable triggers for load of DICTDB.tax-rate-gds-grp .
disable triggers for load of DICTDB.fbr-gds-grp .
disable triggers for load of DICTDB.hist-nws-option .
disable triggers for load of DICTDB.cli-grp .
disable triggers for load of DICTDB.clients .
disable triggers for load of DICTDB.clients-attr .
disable triggers for load of DICTDB.firm .
disable triggers for load of DICTDB.cash-pay .
disable triggers for load of DICTDB.wealth .
disable triggers for load of DICTDB.pay-type .
disable triggers for load of DICTDB.criterion-analysis .
disable triggers for load of DICTDB.global-state .
disable triggers for load of DICTDB.trn-reason .
disable triggers for load of DICTDB.CashBook .
define stream errstream.
find first buf_sys-ctrl.
if buf_sys-ctrl.db-num <> 0 then do:
  message "Данная утилита может работать только в ГБД.".
  return.
end.
assign
v-cntxt-db-num = buf_sys-ctrl.db-num
v-cntxt-userid = userid("ub")
.
glog = no.
message
"Инициализация рублей в справочнике и курсов для них," skip
"единиц измерения, ставок налогов и др. информации ?   Вы уверены ?"
view-as alert-box question buttons OK-Cancel update glog.
if glog <> true then return.
v-is-1c-erp = (p-extra-to = 1).
run waitfram-show in this-procedure ("Инициализация валют").
find buf_currency where buf_currency.curr-code = 0 no-error.
if not available buf_currency then do:
  create buf_currency.
  assign
    buf_currency.curr-code = 0
  .
end.
assign
  buf_currency.curr-name = "Рубль России"
  buf_currency.curr-abbr = "руб"
  buf_currency.part-name = "копейка"
  buf_currency.part-abbr = "коп"
  buf_currency.okv-code  = 643
  buf_currency.curr-name-one =  "рубль":U
  buf_currency.curr-name-three = "рубля":U
  buf_currency.curr-name-five = "рублей":U
  buf_currency.part-name-one  = "копейка":U
  buf_currency.part-name-three = "копейки":U
  buf_currency.part-name-five = "копеек":U
.
run waitfram-show in this-procedure ("Инициализация курсов валют").
  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).
find buf_curr-accnt where buf_curr-accnt.curr-code = 0 no-error.
if not available buf_curr-accnt then do:
  create buf_curr-accnt.
  assign
    buf_curr-accnt.curr-code = 0
    buf_curr-accnt.exch-date = v-today
  .
end.
assign
  buf_curr-accnt.exch-rate = 1
  buf_curr-accnt.exch-scale = 1
.
find buf_curr-bank where buf_curr-bank.curr-code = 0 no-error.
if not available buf_curr-bank then do:
  create buf_curr-bank.
   assign
     buf_curr-bank.curr-code = 0
     buf_curr-bank.exch-date = v-today
   .
end.
assign
  buf_curr-bank.exch-rate = 1
  buf_curr-bank.exch-scale = 1
no-error.
if not v-is-1c-erp then do:
  run waitfram-show in this-procedure ("Инициализация справочника стран").
  country-path = search("cmp/countris.txt").
  if country-path = ? then do:
    message "Нет найден файл импорта для справочника стран countris.txt"
                    "Справочник стран не будет заполнен!"
                    view-as alert-box.
  end.
  else do:
    run import-countries in this-procedure (input country-path) .
  end.
end.
menu-grp-PATH = search("cmp/menu-grp.txt").
if menu-grp-path = ? then do:
    message
    "Отсутствует файл для импорта справочника глобальных групп меню menu-grp.txt" skip
    "Справочник глобальных групп меню не будет заполнен."
    view-as alert-box.
end.
else do:
  run waitfram-show in this-procedure ("Инициализация справочника глобальных групп меню").
  run import-menu-grps in this-procedure .
end.
if not v-is-1c-erp then do:
  if p-sys-key <> "raimbek":U then do:
  run waitfram-show in this-procedure ("Инициализация единиц измерения").
  run cre-unit in this-procedure ("шт", "штука", 'шту':U).
  run cre-unit in this-procedure ("пар", "пара", 'шту':U).
  run cre-unit in this-procedure ("кг", "килограмм", 'вес':U).
  run cre-unit in this-procedure ("м", "метр", 'дро':U).
  run cre-unit in this-procedure ("уп", "упаковка", 'шту':U).
  end.
end.
run waitfram-show in this-procedure ("Инициализация категорий налогов").
run cre-tax in this-procedure (1, "НДС", '%':U, yes, ('шту':U + chr(44) + 'вес':U + chr(44) + 'сер':U + chr(44) + 'дро':U + chr(44) + 'топ':U), no).
run cre-tax in this-procedure (2, "НП", '%':U, no, ('шту':U + chr(44) + 'вес':U + chr(44) + 'сер':U + chr(44) + 'дро':U + chr(44) + 'топ':U), no).
run cre-tax in this-procedure (3, "Доп.компонента", 'abs':U, no, 'сте':U, yes).
run cre-tax in this-procedure (4, "Акциз", 'abs':U, no, 'топ':U, yes).
run waitfram-show in this-procedure ("Инициализация ставок налогов").
if p-sys-key <> "raimbek":U then do:
  run cre-tax-rate in this-procedure (1, 1, "НДС 1").
  run cre-tax-rate in this-procedure (1, 2, "НДС 2").
  run cre-tax-rate in this-procedure (1, 3, "НДС 3").
  run cre-tax-rate in this-procedure (1, 4, "НДС 4").
  run cre-tax-rate-value in this-procedure (1, 1, 20, v-today, v-time).
  run cre-tax-rate-value in this-procedure (1, 2, 10, v-today, v-time).
  run cre-tax-rate-value in this-procedure (1, 3, 0,  v-today, v-time).
  run cre-tax-rate-value in this-procedure (1, 4, 0,  v-today, v-time).
end.
run cre-tax-rate in this-procedure (2, 22, "НП 22").
run cre-tax-rate-value in this-procedure (2, 22, 0, v-today, v-time).
run cre-tax-rate-attr in this-procedure (1, 4).
run waitfram-show in this-procedure ("Заполнение налогов на группу товаров").
run add-tax-gds-grp in this-procedure  no-error .
if p-sys-key <> "raimbek":U then do:
  if not v-is-1c-erp then do:
  run waitfram-show in this-procedure ("Инициализация групп клиентов" ) .
  run cre-cli-grp in this-procedure ( "Свои объекты, фирмы" ) .
  run cre-cli-grp in this-procedure ( "Производители и поставщики" ) .
  run cre-cli-grp in this-procedure ( "Покупатели" ) .
  run cre-cli-grp in this-procedure ( "Персонал" ) .
  end.
  run waitfram-show in this-procedure ("Инициализация клиентов").
  if v-is-1c-erp then do:
    run cre-cli2 in this-procedure .
  end.
  else do:
    run cre-cli in this-procedure ( "Реализация в магазине", "Покупатели" ) .
  end.
end.
else do:
  if not v-is-1c-erp then do:
  run waitfram-show in this-procedure ("Инициализация групп клиентов" ) .
  run cre-cli-grp in this-procedure ( "Группа по умолчанию" ) .
  end.
end.
if v-is-1c-erp then do:
  run waitfram-show in this-procedure ("Инициализация видов оплаты").
  run cre-pay-type in this-procedure ( 1, "Наличные" ) .
  run cre-pay-type in this-procedure ( 2, "Безналичные" ) .
  run cre-pay-type in this-procedure ( 3, "Возврат поставщику" ) .
  run cre-pay-type in this-procedure ( 4, "Оплата по консигнации" ) .
end .
else do :
  if p-sys-key <> "raimbek":U then do:
  run waitfram-show in this-procedure ("Инициализация видов оплаты").
  run cre-pay-type in this-procedure ( 1, "Наличные" ) .
  run cre-pay-type in this-procedure ( 2, "Безналичные" ) .
  run cre-pay-type in this-procedure ( 3, "Возврат поставщику" ) .
  run cre-pay-type in this-procedure ( 4, "Кредит" ) .
  run waitfram-show in this-procedure ("Инициализация МЦ").
  run cre-wth in this-procedure ( 1, 0, YES, "Наличные", '=sum':U ) .
  run waitfram-show in this-procedure ("Инициализация типов кассовых платежей").
  run cre-cash-pay in this-procedure (  1, 0, 1, 1, "Наличные",          TRUE, FALSE ) .
  run cre-cash-pay in this-procedure ( 20, 0, 1, 0, "Оплата по кредиту", FALSE, TRUE ).
  end.
  else do:
  run waitfram-show in this-procedure ("Инициализация видов оплаты").
  run cre-pay-type in this-procedure ( 4, "Наличные" ) .
  run cre-pay-type in this-procedure ( 5, "Безналичные" ) .
  end.
end .
if v-is-1c-erp then do:
  run waitfram-show in this-procedure ("Причины создания документов").
  run cre-trn-reason in this-procedure (19, "Истечение срока годности (кафе)") .
  run cre-trn-reason in this-procedure (20, "Потеря товарного вида актуальности (товары)") .
  run cre-trn-reason in this-procedure (22, "Зачистка резервуара (топлива)") .
  run cre-trn-reason in this-procedure (23, "Возврат товара поставщику") .
  run cre-trn-reason in this-procedure (24, "Ввод первоначальных остатков") .
  dynamic-current-value( "s-trn-reason":U, LDBNAME("DICTDB":U) ) = 24 .
end .
run waitfram-show in this-procedure ("Инициализация критериев анализа ABC и XYZ").
  run utl/abc-utl.p  .
run waitfram-show in this-procedure ("Инициализация глобальных настроек ценообразования").
for each buf_global-state exclusive-lock :
    delete buf_global-state.
end.
    create buf_global-state.
    assign
      buf_global-state.db-num-chg = 1
    .
run waitfram-show in this-procedure ("Инициализация настроек опций истории и маршрутизации").
do:
define variable v-codes1 as character no-undo .
define variable v-labels1 as character no-undo .
define variable v-groups1 as character no-undo .
assign
v-codes1 = 'goods':U + chr(4) + 'gds-obj-attr':U + chr(4) +
          'gds-host-attr':U + chr(4) + 'goods-attr':U + chr(4) +
          'fbr-gds-obj':U + chr(4) + 's-coeff':U + chr(4) +
          'prod-bc':U + chr(4) + 'bar-code':U + chr(4) +
          'varianty-delivery-gds-obj':U + chr(4) + 'gds-season':U + chr(4) +
          'dis-gds-rule':U + chr(4) + 'assortment-matrix-goods':U + chr(4) +
          'gds-obj-prop':U + chr(4) + 'ext-artic':U
v-labels1 = 'Товар':U + chr(4) + 'Атр-т тов. на объекте':U + chr(4) +
        'Атр-т тов. на фирме':U + chr(4) + 'Атр-т товара':U + chr(4) +
        'Атрибут РЕСТОРАНа':U + chr(4) + 'Сезонный коэфф':U + chr(4) +
        'ДопБК':U + chr(4) + 'Бар-код':U + chr(4) +
        'Варианты доставки':U + chr(4) + 'Сезон товара':U + chr(4) +
        'Скидка Товара на объ.':U + chr(4) + 'Содержимое ассортиментных матр':U + chr(4) +
        'Индикаторы':U + chr(4) + 'Внешний артикул товара':U
v-groups1 = fill(('goods':U + chr(4)), num-entries(v-codes1, chr(4) ) )
.
run create-hist-nws-option in this-procedure ( input v-codes1
                                              ,input v-labels1
                                              ,input v-groups1) .
assign
v-codes1 = 'cash-pay':U + chr(4) + 'cash-pay-attr':U + chr(4) + 'dis-cp-rule':U
v-labels1 = 'Касс.платеж':U + chr(4) + 'Аттр.касс.пл-жа':U + chr(4) + 'Скидки на платеж':U
v-groups1 = fill(('cash-pay':U + chr(4)), num-entries(v-codes1, chr(4) ) )
v-groups1 = right-trim(v-groups1, chr(4) )
.
run create-hist-nws-option in this-procedure ( input v-codes1
                                              ,input v-labels1
                                              ,input v-groups1) .
assign
v-codes1 = 'cash-desk':U + chr(4) + 'cash-desk-attr':U
v-labels1 = 'Касса':U + chr(4) + 'Аттр.кассы':U
v-groups1 = fill(('cash-desk':U + chr(4)), num-entries(v-codes1, chr(4) ) )
v-groups1 = right-trim(v-groups1, chr(4) )
.
run create-hist-nws-option in this-procedure ( input v-codes1
                                              ,input v-labels1
                                              ,input v-groups1) .
assign
v-codes1 = 'ext-classif':U
v-labels1 = 'Внешний классификатор':U
v-groups1 = fill(('ext-classif':U + chr(4)), num-entries(v-codes1, chr(4) ) )
v-groups1 = right-trim(v-groups1, chr(4) )
.
run create-hist-nws-option in this-procedure ( input v-codes1
                                              ,input v-labels1
                                              ,input v-groups1) .
assign
v-codes1 = 'contract-specif':U
v-labels1 = 'Спецификация к дог-ру':U
v-groups1 = fill(('contract-specif':U + chr(4)), num-entries(v-codes1, chr(4) ) )
v-groups1 = right-trim(v-groups1, chr(4) )
.
run create-hist-nws-option in this-procedure ( input v-codes1
                                              ,input v-labels1
                                              ,input v-groups1) .
end.
if not v-is-1c-erp then do:
run waitfram-show in this-procedure ("Заполнение справочника регионов РФ").
run utl/reg-cre.p.
run waitfram-show in this-procedure ("Создание кассовой книги по основному виду деятельности.").
run cre-CashBook in this-procedure .
end.
run waitfram-hide in this-procedure .
message "Инициализация закончена.".
procedure cre-unit:
def input param u-n as char no-undo.
def input param l-n as char no-undo.
def input param tp as char no-undo.
  find buf_units where buf_units.unit-name = u-n no-error.
  if not avail buf_units then do:
      find buf_units where buf_units.unit-name = (u-n + ".") no-error.
  end.
  if available buf_units then do:
    if buf_units.type = "" then do:
      message
      "Для единицы измерения:" buf_units.unit-name "тип не задан." "Подставляем:" tp skip (2)
      "Внимание!!! Проверьте все остальные единицы измерения. Возможно, Вы забыли запустить утилиту:"
      "Администратор / Утилиты / Смена версии / Типы единиц измерения. Это может привести к серьезным ошибкам в работе системы!".
      buf_units.type = tp.
    end.
    if buf_units.type <> tp then do:
      message
      "Для единицы измерения:" buf_units.unit-name "тип:" buf_units.type "не совпадает с рекомендуемым:" tp skip (2)
      "Это может привести к серьезным ошибкам в работе системы! Тип заменяется на рекомендуемый"
      view-as alert-box WARNING.
      buf_units.type = tp.
    end.
  end.
  else do:
    create buf_units.
    assign
      buf_units.unit-name = u-n
      buf_units.long-name = l-n
      buf_units.type = tp
      buf_units.stts = 0.
  end.
end procedure.
procedure import-countries private:
define input parameter p-country-path as character no-undo .
define buffer buf_country for DICTDB.country .
  input from value(p-country-path).
  empty temp-table for-country.
  _repeat:
  REPEAT:
      CREATE for-country.
      IMPORT for-country NO-ERROR.
      if error-status:error then next _repeat.
      if for-country.alpha1 = '':U then do:
        delete for-country.
        next _repeat.
      end.
      IF NOT (CAN-FIND(FIRST DICTDB.country where DICTDB.country.num-code = for-country.num-code) OR
              CAN-FIND(FIRST DICTDB.country where DICTDB.country.alpha1   = for-country.alpha1))
                  and for-country.num-code > 0
      then do:
          create buf_country.
          ASSIGN
            buf_country.alpha1     = for-country.alpha1
            buf_country.alpha2     = for-country.alpha2
            buf_country.long-name  = for-country.long-name
            buf_country.num-code   = for-country.num-code
            buf_country.short-name = for-country.short-name
          .
      end.
      delete for-country.
  END.
  empty temp-table for-country.
  INPUT CLOSE.
end procedure.
procedure cre-tax:
def input param taxcode like DICTDB.tax.tax-code no-undo.
def input param l-n as char no-undo.
def input param tp as char no-undo.
def input param tocashdesk as logical no-undo.
def input param unittypes as char no-undo.
def input param individ like DICTDB.tax.individual no-undo.
DEFINE VARIABLE jj         as integer no-undo .
DEFINE VARIABLE vunit-type like DICTDB.units.type no-undo .
DEFINE VARIABLE p1         as logical no-undo .
DEFINE VARIABLE p2         as logical no-undo .
define buffer buf_tax               for DICTDB.tax .
define buffer b_tax-unit for DICTDB.tax-units.
  find buf_tax where buf_tax.tax-code = taxcode no-error.
  if available buf_tax then do:
    if buf_tax.tax-type = "" then do:
      message "Для налога:" buf_tax.tax-name "тип не задан." "Подставляем:" tp
                      .
      buf_tax.tax-type = tp.
    end.
    if buf_tax.tax-type <> tp then do:
      message
      "Для налога:" buf_tax.tax-name "тип:" buf_tax.tax-type "не совпадает с рекомендуемым:" tp skip (2)
      "Это может привести к серьезным ошибкам в работе системы! Тип заменяется на рекомендуемый"
      view-as alert-box WARNING.
      buf_tax.tax-type = tp.
    end.
    if buf_tax.to-cashdesk <> tocashdesk then do:
      message
      "Для налога:" buf_tax.tax-name "флаг ~"отправлять на кассу~":" buf_tax.to-cashdesk "не совпадает с рекомендуемым:" tocashdesk skip (2)
      "Значение флага ~"отправлять на кассу~" заменено на:" tocashdesk
      view-as alert-box WARNING.
      buf_tax.to-cashdesk = tocashdesk .
    end.
    do jj = 1 to num-entries(unittypes):
      assign
      vunit-type =entry(jj, unittypes)
      p1 = no
      p2 = no
      .
      find first b_tax-unit No-LOCK WHERE
                          b_tax-unit.tax-code = taxcode AND
                          b_tax-unit.type = vunit-type AND
                          unittypes <> 'сте':U no-error.
      if not avail b_tax-unit then p1 = yes.
      IF can-find(first b_tax-unit No-LOCK WHERE
                        b_tax-unit.tax-code = taxcode AND
                        LOOKUP(b_tax-unit.type, unittypes) = 0 )
                  AND
      unittypes <> 'сте':U then do:
        p2 = yes.
      end.
     glog = yes.
     if p1 or p2 then do:
        message
        "Для налога:" buf_tax.tax-name "типы единиц измерения: не совпадают с рекомендуемыми:" unittypes skip (2)
        "Это может привести к серьезным ошибкам в работе системы! Тип заменяется на рекомендуемый"
        view-as alert-box WARNING.
        if p1 then do:
            run add-tax-units in this-procedure (taxcode, vunit-type).
        end.
        if p2 then do:
          FOr each b_tax-unit where
                  b_tax-unit.tax-code = taxcode AND
                  LOOKUP(b_tax-unit.type, unittypes) = 0:
            delete b_tax-unit.
          end.
        end.
      end.
    end.
  end.
  else do:
    create buf_tax.
    assign
      buf_tax.tax-code = taxcode
      buf_tax.tax-name = l-n
      buf_tax.tax-type = tp
      buf_tax.to-cashdesk = tocashdesk
      buf_tax.individual = individ
      buf_tax.status_ = 'тек':U
      .
    _jj:
    do jj = 1 to num-entries(unittypes):
      vunit-type =entry(jj, unittypes).
      if not (vunit-type = 'шту':U  OR
              vunit-type = 'дро':U OR
              vunit-type = 'сер':U OR
              vunit-type = 'вес':U OR
              vunit-type = 'топ':U
                  )  then do:
          NEXT _JJ.
        end.
      run add-tax-units in this-procedure (taxcode, vunit-type).
    END.
  end.
end procedure.
procedure cre-tax-rate:
def input param taxcode  like DICTDB.tax.tax-code       no-undo.
def input param ratecode like DICTDB.tax-rate.rate-code no-undo.
def input param ratename like DICTDB.tax-rate.rate-name no-undo.
define buffer buf_tax-rate          for DICTDB.tax-rate .
  find buf_tax-rate where buf_tax-rate.rate-code = ratecode no-error.
  if available buf_tax-rate then do:
    if NOT buf_tax-rate.tax-code = taxcode then do:
      message "Для ставки налога с кодом " buf_tax-rate.rate-code "код категории налога не совпадает с рекомендуемым." skip
      "Подставляем:" taxcode
      view-as alert-box.
                      .
      buf_tax-rate.tax-code = taxcode.
    end.
  end.
  else do:
    create buf_tax-rate.
    assign
      buf_tax-rate.tax-code = taxcode
      buf_tax-rate.rate-code = ratecode
      buf_tax-rate.rate-name = ratename
      buf_tax-rate.status_ = 'тек':U
      .
  end.
end procedure.
procedure cre-tax-rate-value:
def input param taxcode   like DICTDB.tax.tax-code              no-undo.
def input param ratecode  like DICTDB.tax-rate.rate-code        no-undo.
def input param ratevalue like DICTDB.tax-rate-value.rate-value no-undo.
def input param p-today   as date no-undo .
def input param p-time    as integer no-undo .
DEFINE VARIABLE var-day-end-fact-order as decimal no-undo .
define buffer buf_tax-rate-value    for DICTDB.tax-rate-value .
  run factord-end-day in this-procedure (input p-today, output var-day-end-fact-order).
  find LAST  buf_tax-rate-value where
             buf_tax-rate-value.rate-code   = ratecode  AND
             buf_tax-rate-value.tax-code    = taxcode AND
             buf_tax-rate-value.host-code   = 0 AND
             buf_tax-rate-value.obj-type    = "" AND
             buf_tax-rate-value.obj-code    = 0 AND
             buf_tax-rate-value.fact-order <= var-day-end-fact-order
             no-error.
  if not avail buf_tax-rate-value then do:
    create buf_tax-rate-value.
    assign
      buf_tax-rate-value.tax-code = taxcode
      buf_tax-rate-value.rate-code = ratecode
      buf_tax-rate-value.rate-value = ratevalue
      buf_tax-rate-value.fact-date  = p-today
      buf_tax-rate-value.fact-order = var-day-end-fact-order
      buf_tax-rate-value.status_ = 'тек':U
      buf_tax-rate-value.host-code = 0
      buf_tax-rate-value.obj-type = "":U
      buf_tax-rate-value.obj-code = 0
      buf_tax-rate-value.corr-date = p-today
      buf_tax-rate-value.corr-time = p-time
      buf_tax-rate-value.corr-user-db-num = v-cntxt-db-num
      buf_tax-rate-value.corr-user-name = v-cntxt-userid
      .
  end.
end procedure.
procedure cre-tax-rate-attr:
def input param taxcode  like DICTDB.tax.tax-code       no-undo.
def input param ratecode like DICTDB.tax-rate.rate-code no-undo.
define buffer buf_tax-rate-attr          for DICTDB.tax-rate-attr .
  find buf_tax-rate-attr where buf_tax-rate-attr.rate-code = ratecode no-error.
  if available buf_tax-rate-attr then do:
    if NOT buf_tax-rate-attr.tax-code = taxcode then do:
      message "Для ставки налога с кодом " buf_tax-rate-attr.rate-code "уже есть атрибут ЕНВД." skip
      "Подставляем:" taxcode
      view-as alert-box.
                      .
      buf_tax-rate-attr.tax-code = taxcode.
    end.
  end.
  else do:
    create buf_tax-rate-attr.
    assign
      buf_tax-rate-attr.tax-code = taxcode
      buf_tax-rate-attr.rate-code = ratecode
      buf_tax-rate-attr.attr-code = "envd"
      .
  end.
end procedure.
PROCEDURE add-tax-units:
define input parameter partax-code  like DICTDB.tax.tax-code no-undo .
define input parameter parunit-type like DICTDB.units.type   no-undo .
define buffer buf_tax-units         for DICTDB.tax-units .
  if not can-find(first buf_tax-units No-LOCK WHERE
                        buf_tax-units.tax-code = partax-code AND
                        buf_tax-units.type = parunit-type) then do:
    create buf_tax-units.
    assign
      buf_tax-units.tax-code = partax-code
      buf_tax-units.type = parunit-type
    .
  END.
END PROCEDURE.
procedure add-tax-gds-grp :
DEFINE VARIABLE var-vat-code as character no-undo .
DEFINE VARIABLE var-SLT-code as character no-undo .
DEFINE VARIABLE vattr-labels as character no-undo .
DEFINE VARIABLE vattr-codes as character no-undo .
DEFINE VARIABLE vartax-value like DICTDB.tax-rate-value.rate-value no-undo .
define variable VATtaxcd as integer no-undo.
define variable SLTtaxcd as integer no-undo.
define buffer buf_tax-rate-gds-grp  for DICTDB.tax-rate-gds-grp .
vattaxcd = integer('1':U).
slttaxcd = integer('2':U).
if p-sys-key <> "raimbek":U then do:
  assign
  vattr-codes = "":U
  vattr-labels = "":U
  .
  for each DICTDB.tax-rate no-lock where
           DICTDB.tax-rate.tax-code = vattaxcd:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  recid(DICTDB.tax-rate)
  ,input  DICTDB.tax-rate.tax-code
  ,input  DICTDB.tax-rate.rate-code
  ,input  ?
  ,input  0
  ,input  '':U
  ,input  0
  ,output vartax-value
  ) no-error .
    if error-status:error then do:
      message return-value view-as alert-box error .
      return error return-value.
    end.
    if vartax-value = ? then NEXT.
    if v-is-1c-erp then do:
      var-vat-code = string(tax-rate.rate-code) .
      leave .
    end.
    else assign
    vattr-labels = vattr-labels +
                  (if vattr-labels = "":U then "" else chr(44)) +
                  string(string(tax-rate.rate-code) + " - " + replace(tax-rate.rate-name, chr(44), "":U), "X(25)") +
                  fill(chr(32), 5) + string(vartax-value, "99.99%":U)
    vattr-codes = vattr-codes +
                  (if vattr-codes = "":U then "" else chr(44)) +
                  string(tax-rate.rate-code)
    .
  end.
  if not v-is-1c-erp then do:
    run gbl/d-list.w (
                INPUT "b-sel":U
                ,INPUT "Выберите ставку НДС для групп (по умолчанию)"
                ,INPUT vattr-codes
                ,INPUT vattr-labels
                ,INPUT chr(44)
                ,INPUT "":U
                ,output var-vat-code).
    IF var-vat-code = "":u THEN do:
    message
    "Вы не выбрали ставку НДС для групп!" skip
    "Это может привести к непредсказуемым результатам"
    view-as alert-box error .
    RETURN ERROR.
    end.
  end.
end.
assign
vattr-codes = "":U
vattr-labels = "":U
.
for each tax-rate no-lock where
         tax-rate.tax-code = slttaxcd:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  recid(tax-rate)
  ,input  tax-rate.tax-code
  ,input  tax-rate.rate-code
  ,input  ?
  ,input  0
  ,input  '':U
  ,input  0
  ,output vartax-value
  ) no-error .
  if error-status:error then do:
    message
    return-value view-as alert-box error .
    return error.
  end.
  if vartax-value = ? then NEXT.
  if v-is-1c-erp then do:
    var-slt-code = string(tax-rate.rate-code) .
    leave .
  end.
  else assign
  vattr-labels = vattr-labels +
                (if vattr-labels = "":U then "" else chr(44)) +
                string(string(tax-rate.rate-code) + " - " + replace(tax-rate.rate-name, chr(44), "":U), "X(25)") +
                fill(chr(32), 5) + string(vartax-value, "99.99%":U)
  vattr-codes = vattr-codes +
                (if vattr-codes = "":U then "" else chr(44)) +
                string(tax-rate.rate-code)
  .
end.
if not v-is-1c-erp then do:
  run gbl/d-list.w (
              INPUT "b-sel":U
              ,INPUT "Выберите ставку НП для групп (по умолчанию)(если НП не действует, выберите знач=0)"
              ,INPUT vattr-codes
              ,INPUT vattr-labels
              ,INPUT chr(44)
              ,INPUT "":U
              ,output var-slt-code).
  IF var-slt-code = "":u THEN do:
  message
  "Вы не выбрали ставку НП для групп!" skip
  "Это может привести к непредсказуемым результатам"
  view-as alert-box error .
  RETURN ERROR.
  end.
end .
do on error undo, return error :
  FOR EACH DICTDB.gds-grp No-LOCK:
    if p-sys-key <> "raimbek":U then do:
      if not can-find(first buf_tax-rate-gds-grp where
                            buf_tax-rate-gds-grp.tax-code = vattaxcd AND
                            buf_tax-rate-gds-grp.node-code = DICTDB.gds-grp.node-code AND
                            buf_tax-rate-gds-grp.host-code = 0 AND
                            buf_tax-rate-gds-grp.obj-type = "":U AND
                            buf_tax-rate-gds-grp.obj-code = 0
                            ) then do:
        create buf_tax-rate-gds-grp.
        assign
          buf_tax-rate-gds-grp.node-code = DICTDB.gds-grp.node-code
          buf_tax-rate-gds-grp.tax-code = vattaxcd
          buf_tax-rate-gds-grp.rate-code = integer(var-vat-code)
       .
      end.
    end.
    if not can-find(first buf_tax-rate-gds-grp where
                          buf_tax-rate-gds-grp.tax-code = slttaxcd AND
                          buf_tax-rate-gds-grp.node-code = DICTDB.gds-grp.node-code AND
                          buf_tax-rate-gds-grp.host-code = 0 AND
                          buf_tax-rate-gds-grp.obj-type = "":U AND
                          buf_tax-rate-gds-grp.obj-code = 0
                          ) then do:
      create buf_tax-rate-gds-grp.
      assign
         buf_tax-rate-gds-grp.node-code = DICTDB.gds-grp.node-code
         buf_tax-rate-gds-grp.tax-code = slttaxcd
         buf_tax-rate-gds-grp.rate-code = integer(var-slt-code)
      .
    end.
  end.
end.
END PROCEDURE.
PROCEDURE get-rate-value:
define input parameter partax-code like DICTDB.tax.tax-code no-undo .
define input parameter parrate-code like DICTDB.tax-rate.rate-code no-undo .
define output parameter parrate-value like DICTDB.tax-rate-value.rate-value no-undo .
DEFINE VARIABLE var-fact-order as decimal no-undo .
define buffer buf_tax-rate-value    for DICTDB.tax-rate-value .
   var-fact-order = integer(today) + 0.99.
   FIND LAST buf_tax-rate-value No-LOCK WHERE
            buf_tax-rate-value.tax-code = partax-code AND
            buf_tax-rate-value.rate-code = parrate-code AND
            buf_tax-rate-value.host-code = 0 AND
            buf_tax-rate-value.obj-type = "" AND
            buf_tax-rate-value.host-code = 0 AND
            buf_tax-rate-value.fact-order <= var-fact-order No-ERROR.
   if available buf_tax-rate-value then do:
      assign
         parrate-value = buf_tax-rate-value.rate-value
      .
   end.
END PROCEDURE.
procedure import-menu-grps :
define variable v-shift-node-code like DICTDB.fbr-gds-grp.node-code no-undo .
define buffer buf_fbr-gds-grp for DICTDB.fbr-gds-grp.
  do
  on error undo, return error
  :
    for each buf_fbr-gds-grp  where buf_fbr-gds-grp.node-code <> 1 no-lock:
      assign
      v-shift-node-code =  buf_fbr-gds-grp.node-code
      .
    end.
    input from value(menu-grp-path).
    for each temp_fbr-gds-grp:
      delete temp_fbr-gds-grp.
    end.
    _repeat2:
    REPEAT:
        CREATE temp_fbr-gds-grp.
        IMPORT temp_fbr-gds-grp.node-name temp_fbr-gds-grp.node-code temp_fbr-gds-grp.upper-code temp_fbr-gds-grp.lvl-num NO-ERROR.
        if error-status:error then do:
          delete temP_fbr-gds-grp.
          next  _repeat2.
        end.
        if not error-status:error then do:
          IF NOT CAN-FIND(FIRST buf_fbr-gds-grp where buf_fbr-gds-grp.node-code = (temp_fbr-gds-grp.node-code + v-shift-node-code)
                              and buF_fbr-gds-grp.obj-type      = "":U
                              AND buF_fbr-gds-grp.obj-code      = 0        )
            AND ( temp_fbr-gds-grp.upper-code  = 1
                or
                CAN-FIND(FIRST buf_fbr-gds-grp where buf_fbr-gds-grp.NODE-code = temp_fbr-gds-grp.upper-code +  v-shift-node-code
                              and buF_fbr-gds-grp.obj-type      = "":U
                              AND buF_fbr-gds-grp.obj-code      = 0           )
                  )
          and not can-find(first buf_fbr-gds-grp where
                                 buF_fbr-gds-grp.obj-type = "":U
                             AND buF_fbr-gds-grp.obj-code      = 0
                             and buF_fbr-gds-grp.upper-code = (if temp_fbr-gds-grp.upper-code  = 1
                                                              then 1
                                                              else  (temp_fbr-gds-grp.upper-code +  v-shift-node-code))
                           and buf_fbr-gds-grp.node-name = temp_fbr-gds-grp.node-name)
          then do:
              create buf_Fbr-gds-grp.
              ASSIGN
              buF_fbr-gds-grp.node-code     = temp_fbr-gds-grp.node-code  +  v-shift-node-code
              buf_fbr-gds-grp.upper-code    = (if temp_fbr-gds-grp.upper-code  = 1 then 1 else  (temp_fbr-gds-grp.upper-code +  v-shift-node-code))
              buF_fbr-gds-grp.node-name     = temp_fbr-gds-grp.node-name
              buF_fbr-gds-grp.obj-type      = "":U
              buF_fbr-gds-grp.obj-code      = 0
              buF_fbr-gds-grp.out-code      = temp_fbr-gds-grp.node-code
              buF_fbr-gds-grp.global-code   = temp_fbr-gds-grp.node-code
              buF_fbr-gds-grp.lvl-num       = temp_fbr-gds-grp.lvl-num
              .
          end.
        end.
        delete temp_fbr-gds-grp.
    END.
    for each temp_fbr-gds-grp:
      delete temp_fbr-gds-grp.
    end.
    INPUT CLOSE.
  end.
end procedure.
define temp-table tt-db-hn like DICTDB.db
field hn-id as integer
index pi is unique primary
db-num
hn-id
.
procedure create-hist-nws-option :
define input parameter p-codes as character no-undo .
define input parameter p-labels as character no-undo .
define input parameter p-groups as character no-undo .
define variable v-ii as integer no-undo .
define buffer buf_hist-nws-option for DICTDB.hist-nws-option.
do
on error undo, return error
:
  do v-ii = 1 to num-entries(p-codes, chr(4) ):
    find first buf_hist-nws-option where
          buf_hist-nws-option.db-num = buf_sys-ctrl.db-num
      and buf_hist-nws-option.table-name = entry(v-ii, p-codes, chr(4) )  no-error.
    if not available buf_hist-nws-option
    then do:
      find last tt-db-hn  where
              tt-db-hn.db-num = buf_sys-ctrl.db-num no-error.
      create buf_hist-nws-option.
      assign
      buf_hist-nws-option.db-num =  buf_sys-ctrl.db-num
      buf_hist-nws-option.hn-id  =  (if available tt-db-hn then tt-db-hn.hn-id + 1 else 1)
      buf_hist-nws-option.table-name =  entry(v-ii, p-codes, chr(4) )
      buf_hist-nws-option.option-descr = entry(v-ii, p-labels, chr(4) )
      buf_hist-nws-option.subject-group = entry( v-ii, p-groups, chr(4))
      buf_hist-nws-option.host-code = 0
      buf_hist-nws-option.obj-type = '':U
      buf_hist-nws-option.obj-code = 0
      buf_hist-nws-option.hist-to-nws = 0
      buf_hist-nws-option.nws-to-hist = 0
      buf_hist-nws-option.hist-from-prim = 0
      buf_hist-nws-option.get-hist-from-nws = 0
      .
      if current-value(s-hn-id, ub) < buf_hist-nws-option.hn-id
      then do:
        current-value(s-hn-id, ub) = buf_hist-nws-option.hn-id.
      end.
      create tt-db-hn.
      assign
      tt-db-hn.db-num = buf_hist-nws-option.db-num
      tt-db-hn.hn-id = buf_hist-nws-option.hn-id
      .
      release tt-db-hn.
    end.
  end.
end.
end procedure.
procedure cre-cli-grp :
define input parameter p-grp-name as character        no-undo.
do
on error undo, return error
:
  if not can-find(first buf_cli-grp No-LOCK
                  WHERE buf_cli-grp.node-name = p-grp-name
                  )
  then do:
      create buf_cli-grp.
      ASSIGN
         buf_cli-grp.node-code  = dynamic-next-value( "s-cli-grp":U, LDBNAME("DICTDB":U) )
         buf_cli-grp.lvl-num    = 1
         buf_cli-grp.node-name  = p-grp-name
         buf_cli-grp.upper-code = 1
         buf_cli-grp.is-term    = TRUE
      .
  end.
end.
end procedure.
procedure cre-cli :
define input parameter p-obj-name as character        no-undo.
define input parameter p-grp-name as character        no-undo.
define variable v-name    as character    no-undo.
define variable v-obj-code    as integer      no-undo.
do
on error undo, return error
:
  find first buf_cli-grp
       WHERE buf_cli-grp.node-name = p-grp-name
       NO-LOCK
       NO-ERROR
       .
   if NOT AVAILABLE buf_cli-grp
   then do:
      undo, return error SUBSTITUTE("cre-cli: Ошибка клиента. Не найдена группа клиентов &1", p-grp-name).
   end.
   if not can-find(first buf_clients
                     WHERE buf_clients.obj-name = p-obj-name
                     NO-LOCK
                     )
   then do:
      assign
         v-name = ""
      .
      run cli-grplib-get-full-name in this-procedure
         (input  buf_cli-grp.node-code
         ,output v-name
         ).
      run gen-b-code in this-procedure ( input 'fmgb':U, output v-obj-code) no-error .
      if error-status :error
      then do:
         undo, return error "cre-cli: Ошибка генерации уникального кода для фирмы поставщика." + chr(10) + return-value.
      end.
      create buf_firm.
      assign
         buf_firm.firm-code      = v-obj-code
      .
      create buf_clients.
      ASSIGN
         buf_clients.obj-type    = 'орг':U
         buf_clients.obj-code    = v-obj-code
         buf_clients.obj-name    = p-obj-name
         buf_clients.grp-code    = buf_cli-grp.node-code
         buf_clients.grp-name    = v-name
      .
  end.
end.
end procedure.
procedure cre-cli2 private:
define variable v-name as character no-undo .
    run cli-grplib-get-full-name in this-procedure (input 5 , output v-name) .
    create buf_clients.
    assign
      buf_clients.obj-type = 'орг':U
      buf_clients.obj-code = 800000001
      buf_clients.obj-name = "Реализация розничная"
      buf_clients.stts     = 0
      buf_clients.grp-code = 5
      buf_clients.grp-name = v-name
    .
    create buf_firm.
    assign
      buf_firm.firm-code = 800000001
      buf_firm.ind       = 0
    .
    create buf_clients.
    assign
      buf_clients.obj-type = 'орг':U
      buf_clients.obj-code = 800000002
      buf_clients.obj-name = "Технологический пролив"
      buf_clients.stts     = 0
      buf_clients.grp-code = 5
      buf_clients.grp-name = v-name
    .
    create buf_firm.
    assign
      buf_firm.firm-code = 800000002
      buf_firm.ind       = 0
    .
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  'орг':U
      ,input  800000002
      ,input  'shftrep2':U
      ,input  "yes":U
      ) no-error .
    if error-status:error then do:
      message return-value view-as alert-box error .
      return error return-value.
    end.
    create buf_clients.
    assign
      buf_clients.obj-type = 'орг':U
      buf_clients.obj-code = 800000003
      buf_clients.obj-name = "Отбор проб"
      buf_clients.stts     = 0
      buf_clients.grp-code = 5
      buf_clients.grp-name = v-name
    .
    create buf_firm.
    assign
      buf_firm.firm-code = 800000003
      buf_firm.ind       = 0
    .
    create buf_clients.
    assign
      buf_clients.obj-type = 'орг':U
      buf_clients.obj-code = 800000004
      buf_clients.obj-name = "Программа лояльности"
      buf_clients.stts     = 0
      buf_clients.grp-code = 5
      buf_clients.grp-name = v-name
    .
    create buf_firm.
    assign
      buf_firm.firm-code = 800000004
      buf_firm.ind       = 0
    .
    create buf_clients.
    assign
      buf_clients.obj-type = 'орг':U
      buf_clients.obj-code = 800000005
      buf_clients.obj-name = "Ввод первоначальных остатков"
      buf_clients.stts     = 0
      buf_clients.grp-code = 5
      buf_clients.grp-name = v-name
    .
    create buf_firm.
    assign
      buf_firm.firm-code = 800000005
      buf_firm.ind       = 0
    .
    create buf_clients.
    assign
      buf_clients.obj-type = 'орг':U
      buf_clients.obj-code = 800000006
      buf_clients.obj-name = 'Банк "ВБРР" АО'
      buf_clients.stts     = 0
      buf_clients.grp-code = 5
      buf_clients.grp-name = v-name
    .
    create buf_firm.
    assign
      buf_firm.firm-code = 800000006
      buf_firm.ind       = 0
    .
    create buf_clients.
    assign
      buf_clients.obj-type = 'орг':U
      buf_clients.obj-code = 800000007
      buf_clients.obj-name = "Банк ВБРР (агентская выручка)"
      buf_clients.stts     = 0
      buf_clients.grp-code = 5
      buf_clients.grp-name = v-name
    .
    create buf_firm.
    assign
      buf_firm.firm-code = 800000007
      buf_firm.ind       = 0
    .
    create buf_clients.
    assign
      buf_clients.obj-type = 'орг':U
      buf_clients.obj-code = 800000008
      buf_clients.obj-name = "Перемещение денежных средств"
      buf_clients.stts     = 0
      buf_clients.grp-code = 5
      buf_clients.grp-name = v-name
    .
    create buf_firm.
    assign
      buf_firm.firm-code = 800000008
      buf_firm.ind       = 0
    .
     create buf_clients.
    assign
      buf_clients.obj-type = 'орг':U
      buf_clients.obj-code = 800000009
      buf_clients.obj-name = "Выдача наличных денежных средств"
      buf_clients.stts     = 0
      buf_clients.grp-code = 5
      buf_clients.grp-name = v-name
    .
    create buf_firm.
    assign
      buf_firm.firm-code = 800000009
      buf_firm.ind       = 0
    .
end procedure .
procedure cre-pay-type :
define input parameter p-code as integer        no-undo.
define input parameter p-name as character        no-undo.
do
on error undo, return error
:
   if not can-find(first buf_pay-type
                   WHERE buf_pay-type.obj-code = p-code
                   NO-LOCK
                  )
   then do:
      create buf_pay-type.
      ASSIGN
         buf_pay-type.obj-code = p-code
         buf_pay-type.obj-name = p-name
      .
   END.
end.
end procedure.
procedure cre-wth :
define input parameter p-code as integer          no-undo.
define input parameter p-curr-code as integer          no-undo.
define input parameter p-is-money as logical          no-undo.
define input parameter p-name as character        no-undo.
define input parameter p-get-qnty-method as character        no-undo.
do
on error undo, return error
:
   FIND FIRST buf_currency
        WHERE buf_currency.curr-code = p-curr-code
        NO-LOCK
        NO-ERROR
        .
   if NOT AVAILABLE buf_currency
   then do:
      undo, return error SUBSTITUTE("cre-wth: Ошибка создания МЦ. Не найдена валюта &1", p-curr-code).
   end.
   if not can-find(first buf_wealth
                   WHERE buf_wealth.wth-code = p-code
                   NO-LOCK
                  )
   then do:
      CREATE buf_wealth.
      ASSIGN
         buf_wealth.wth-code  = p-code
         buf_wealth.wth-name  = p-name
         buf_wealth.is-money  = p-is-money
         buf_wealth.curr-code = p-curr-code
         buf_wealth.get-qnty-method = p-get-qnty-method
      .
   END.
end.
end procedure.
procedure cre-cash-pay :
define input parameter p-code       as integer          no-undo.
define input parameter p-curr-code  as integer          no-undo.
define input parameter p-type       as integer          no-undo.
define input parameter p-wth        as integer          no-undo.
define input parameter p-name       as character        no-undo.
define input parameter p-is-cash    as logical          no-undo.
define input parameter p-is-credit  as logical          no-undo.
do
on error undo, return error
:
   FIND FIRST buf_currency
        WHERE buf_currency.curr-code = p-curr-code
        NO-LOCK
        NO-ERROR
        .
   if NOT AVAILABLE buf_currency
   then do:
      undo, return error SUBSTITUTE("cre-cash-pay: Ошибка создания типа кассового платежа. Не найдена валюта &1", p-curr-code).
   end.
   FIND FIRST buf_pay-type
        WHERE buf_pay-type.obj-code = p-type
        NO-LOCK
        NO-ERROR
        .
   if NOT AVAILABLE buf_pay-type
   then do:
      undo, return error SUBSTITUTE("cre-cash-pay: Ошибка создания типа кассового платежа. Не найден тип платежа &1", p-type).
   end.
   IF p-wth <> 0
   THEN DO:
      FIND FIRST buf_wealth
         WHERE buf_wealth.wth-code   = p-wth
         NO-LOCK
         NO-ERROR
         .
      if NOT AVAILABLE buf_wealth
      then do:
         undo, return error SUBSTITUTE("cre-cash-pay: Ошибка создания типа кассового платежа. Не найдена МЦ &1", p-wth).
      end.
   end.
   if not can-find(first buf_cash-pay
                   WHERE buf_cash-pay.cdpay-code = p-code
                     AND buf_cash-pay.curr-code  = p-curr-code
                   NO-LOCK
                  )
   then do:
      CREATE buf_cash-pay.
      ASSIGN
         buf_cash-pay.cdpay-code  = p-code
         buf_cash-pay.curr-code   = p-curr-code
         buf_cash-pay.pay-code    = p-type
         buf_cash-pay.wth-code    = p-wth
         buf_cash-pay.is-credit   = p-is-credit
         buf_cash-pay.is-cash     = p-is-cash
         buf_cash-pay.atr1        = TRUE
         buf_cash-pay.atr2        = TRUE
         buf_cash-pay.status_     = 'тек':U
         buf_cash-pay.is-all-pay  = p-is-cash
         buf_cash-pay.can-mix     = INTEGER(p-is-cash)
         buf_cash-pay.has-overpay = INTEGER(p-is-credit)
      .
   END.
end.
end procedure.
procedure cre-trn-reason private :
define input parameter p-reason-code as integer no-undo .
define input parameter p-reason-name as character no-undo .
define variable v-rid as recid initial ? no-undo .
  run ref/trn-rsn1.p
    ( input-output v-rid
    , input 'ДОБАВЛЕНИЕ':U
    , input true
    , input p-reason-code
    , input p-reason-name
    , input ""
  ) .
  return .
end procedure .
procedure cre-CashBook private :
define buffer buf_CashBook     for DICTDB.CashBook .
define buffer buf_CashBookRule for DICTDB.CashBookRule .
  create buf_CashBook .
  assign
    buf_CashBook.id           = 0
    buf_CashBook.ext-code     = "0"
    buf_CashBook.CashBookName = "Основная деятельность"
    buf_CashBook.RuleOsnPko   = "0"
    buf_CashBook.RulePril     = "0"
    buf_CashBook.FlagSepCash  = true
    buf_CashBook.FlagSepFull  = true
    buf_CashBook.CorrPko      = "90.01"
    buf_CashBook.OsnAcct      = "50.02"
  .
end procedure .
