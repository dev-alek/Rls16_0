block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: rst-aht.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/rst-aht.p $":U .
define variable vss-description as character no-undo initial "Восстановление складского архива по типам приобретения".
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
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table doc-list no-undo
  field doc-code         like ub.trn-doc.doc-code
  field obj-type         like ub.trn-doc.obj-type
  field obj-code         like ub.trn-doc.obj-code
  field fact-date        like ub.trn-doc.fact-date
  field shift-date       like ub.trn-doc.shift-date
  field shift-num        like ub.trn-doc.shift-num
  field shift-name       like ub.trn-doc.shift-name
  field fact-order       as decimal
  field is-trn-doc       as logical
  field doc-type         like ub.trn-doc.doc-type
  field is-archive-exist as logical
  index xpk is primary unique doc-code doc-type
  index xfact-order fact-order
  index xfact-date  fact-date
  .
define temp-table doclslib-goods no-undo
  field gds-code  as integer
  field artic     as character
  field prod-type as character
  field prod-code as integer
  index xpk is primary unique gds-code
  index xie1 artic prod-type prod-code
  .
define buffer inkas_trn-doc for ub.trn-doc .
define stream doclsliblog .
procedure doclslib-clear-doc-list :
  define buffer buf_doc-list for doc-list .
  do
  on error undo, return error
  :
    for each buf_doc-list
    on error undo, return error
    :
      delete buf_doc-list .
    end.
  end.
end procedure.
procedure doclslib-init-trn-doc :
  define input parameter p-obj-type      as character no-undo .
  define input parameter p-obj-code      as integer   no-undo .
  define input parameter p-cut-date      as date      no-undo .
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_doc-list for doc-list .
  do
  on error undo, return error
  :
    if p-cut-date = ?
    then do:
      for each buf_trn-doc no-lock
        where buf_trn-doc.obj-type = p-obj-type
          and buf_trn-doc.obj-code = p-obj-code
          and buf_trn-doc.status_  = 'факт':U
      on error undo, return error
      :
        create buf_doc-list .
        assign
          buf_doc-list.doc-code   = buf_trn-doc.doc-code
          buf_doc-list.doc-type   = buf_trn-doc.doc-type
          buf_doc-list.fact-date  = buf_trn-doc.fact-date
          buf_doc-list.shift-date = buf_trn-doc.shift-date
          buf_doc-list.shift-num  = buf_trn-doc.shift-num
          buf_doc-list.shift-name = buf_trn-doc.shift-name
          buf_doc-list.fact-order = buf_trn-doc.fact-order
          buf_doc-list.is-trn-doc = true
        .
      end.
    end.
    else do:
      for each buf_trn-doc no-lock
        where buf_trn-doc.obj-type  = p-obj-type
          and buf_trn-doc.obj-code  = p-obj-code
          and buf_trn-doc.status_   = 'факт':U
          and buf_trn-doc.fact-date >= p-cut-date
      on error undo, return error
      :
        create buf_doc-list .
        assign
          buf_doc-list.doc-code   = buf_trn-doc.doc-code
          buf_doc-list.doc-type   = buf_trn-doc.doc-type
          buf_doc-list.fact-date  = buf_trn-doc.fact-date
          buf_doc-list.shift-date = buf_trn-doc.shift-date
          buf_doc-list.shift-num  = buf_trn-doc.shift-num
          buf_doc-list.shift-name = buf_trn-doc.shift-name
          buf_doc-list.fact-order = buf_trn-doc.fact-order
          buf_doc-list.is-trn-doc = true
        .
      end.
    end.
  end.
end procedure.
procedure doclslib-init-price-doc :
  define input parameter p-obj-type      as character no-undo .
  define input parameter p-obj-code      as integer   no-undo .
  define input parameter p-cut-date      as date      no-undo .
  define buffer buf_price-doc for ub.price-doc .
  define buffer buf_doc-list for doc-list .
  do
  on error undo, return error
  :
    if p-cut-date = ?
    then do:
      for each buf_price-doc no-lock
        where buf_price-doc.obj-type = p-obj-type
          and buf_price-doc.obj-code = p-obj-code
          and buf_price-doc.status_  = 'акт':U
      on error undo, return error
      :
        create buf_doc-list .
        assign
          buf_doc-list.doc-code   = buf_price-doc.doc-num
          buf_doc-list.doc-type   = ''
          buf_doc-list.fact-date  = buf_price-doc.fact-date
          buf_doc-list.shift-date = buf_price-doc.shift-date
          buf_doc-list.shift-num  = buf_price-doc.shift-num
          buf_doc-list.shift-name = buf_price-doc.shift-name
          buf_doc-list.fact-order = buf_price-doc.fact-order
          buf_doc-list.is-trn-doc = false
        .
      end.
    end.
    else do:
      for each buf_price-doc no-lock
        where buf_price-doc.obj-type = p-obj-type
          and buf_price-doc.obj-code = p-obj-code
          and buf_price-doc.status_  = 'акт':U
          and ub.buf_price-doc.fact-date >= p-cut-date
      on error undo, return error
      :
        create buf_doc-list .
        assign
          buf_doc-list.doc-code   = buf_price-doc.doc-num
          buf_doc-list.doc-type   = ''
          buf_doc-list.fact-date  = buf_price-doc.fact-date
          buf_doc-list.shift-date = buf_price-doc.shift-date
          buf_doc-list.shift-num  = buf_price-doc.shift-num
          buf_doc-list.shift-name = buf_price-doc.shift-name
          buf_doc-list.fact-order = buf_price-doc.fact-order
          buf_doc-list.is-trn-doc = false
        .
      end.
    end.
  end.
end procedure.
procedure doclslib-clear-bydate-doc-list :
  define input parameter p-fact-date as date no-undo .
  define buffer buf_doc-list for doc-list .
  do
  on error undo, return error
  :
    if p-fact-date <> ?
    then do:
      for each buf_doc-list
        where buf_doc-list.fact-date < p-fact-date
      on error undo, return error
      :
        delete buf_doc-list .
      end.
    end.
  end.
end procedure.
procedure doclslib-clear-rst :
  define input parameter p-fact-date as date no-undo .
  define buffer buf_doc-list for doc-list .
  do
  on error undo, return error
  :
    if p-fact-date <> ?
    then do:
      for each buf_doc-list
        where buf_doc-list.fact-date >= p-fact-date
      on error undo, return error
      :
        delete buf_doc-list .
      end.
    end.
  end.
end procedure.
procedure doclslib-export-doc-list :
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer no-undo .
  define input  parameter p-log-file-name as character no-undo .
  define input  parameter p-description   as character no-undo .
  define buffer buf_doc-list for doc-list .
  do
  on error undo, return error
  :
    output stream doclsliblog to value(p-log-file-name) .
    export stream doclsliblog "#############################################################" .
    export stream doclsliblog "Список документов" .
    export stream doclsliblog p-description .
    export stream doclsliblog "Объект" p-obj-type p-obj-code .
    export stream doclsliblog "Дата" string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U).
    for each buf_doc-list
    by buf_doc-list.fact-order
    on error undo, return error
    :
      export stream doclsliblog buf_doc-list .
    end.
    export stream doclsliblog "#############################################################" .
    output stream doclsliblog close .
  end.
end procedure.
procedure doclslib-clear-batch-process :
  define input parameter p-bp_type like ub.batchprocess.bp_type no-undo .
  define buffer buf_batchprocess        for ub.batchprocess .
  define buffer execdelete_batchprocess for ub.batchprocess .
  define buffer buf_doc-list            for doc-list .
  for each buf_doc-list
  on end-key undo, return error substitute( "doclslib-clear-batch-process. end-key   &1&2&3", return-value, chr(10), error-status :get-message ( 1 ) )
  on error   undo, return error substitute( "doclslib-clear-batch-process. error     &1&2&3", return-value, chr(10), error-status :get-message ( 1 ) )
  on stop    undo, return error substitute( "doclslib-clear-batch-process. STOP      &2"
                                 + "bp_type &3&2"
                                 + "Документ &4"
                                 , chr(10)
                                 , p-bp_type
                                 , buf_doc-list.doc-code
                                )
  :
    find first buf_batchprocess exclusive-lock
      where buf_BatchProcess.BP_Status   = 'N':U
        and buf_batchprocess.bp_type     = p-bp_type
        and buf_batchprocess.charkey_one = buf_doc-list.doc-code
      no-error .
    if available buf_batchprocess
    then do:
      delete buf_batchprocess .
    end.
  end.
end procedure.
procedure doclslib-calc-arh :
  define input  parameter p-log-handle     as handle    no-undo .
  define input  parameter p-obj-type       as character no-undo .
  define input  parameter p-obj-code       as integer   no-undo .
  define input  parameter p-cut-date       as date      no-undo .
  define input  parameter p-update-recalc  as logical   no-undo .
  define variable v-prev-fact-date as date      no-undo .
  define buffer buf_doc-list for doc-list .
  define buffer stop-arh-restore-lock_btpr for ub.batchprocess .
  define buffer stop-arh-news-lock_btpr    for ub.batchprocess .
  do
  on stop    undo, return error substitute( "doclslib-calc-arh. stop      &1&2&3", return-value, chr(10), error-status :get-message ( 1 ) )
  on end-key undo, return error substitute( "doclslib-calc-arh. end-key   &1&2&3", return-value, chr(10), error-status :get-message ( 1 ) )
  on error   undo, return error substitute( "doclslib-calc-arh. error     &1&2&3", return-value, chr(10), error-status :get-message ( 1 ) )
  :
    define buffer buf_lock_gdsrenart_batchprocess for ub.batchprocess .
    run gbl/lockrngd.p
      (input  'grar':U
      ,input  'disable':U
      ,buffer buf_lock_gdsrenart_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при блокировании функции переименования артикула товара" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error return-value .
    end.
    define buffer buf_lock_gdsrengc_batchprocess for ub.batchprocess .
    run gbl/lockrngd.p
      (input  'grgc':U
      ,input  'disable':U
      ,buffer buf_lock_gdsrengc_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при блокировании функции переименования кода товара" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error return-value .
    end.
    for each buf_doc-list
    by buf_doc-list.fact-order
    on stop    undo, return error substitute( "f e . stop      &1&2&3", return-value, chr(10), error-status :get-message ( 1 ) )
    on end-key undo, return error substitute( "f e . end-key   &1&2&3", return-value, chr(10), error-status :get-message ( 1 ) )
    on error   undo, return error substitute( "f e . error     &1&2&3", return-value, chr(10), error-status :get-message ( 1 ) )
    :
      find first stop-arh-restore-lock_btpr no-lock
        where stop-arh-restore-lock_btpr.bp_type       = 'lock':U + 'rsrs':U
          and stop-arh-restore-lock_btpr.bp_status     = 'N':U
          and stop-arh-restore-lock_btpr.Key#_One      = buf_doc-list.obj-code
          and stop-arh-restore-lock_btpr.Key#_Two      = 0
          and stop-arh-restore-lock_btpr.Key#_Three    = 0
          and stop-arh-restore-lock_btpr.CharKey_One   = buf_doc-list.obj-type
          and stop-arh-restore-lock_btpr.CharKey_Two   = ""
          and stop-arh-restore-lock_btpr.CharKey_Three = ""
        no-error .
      if available stop-arh-restore-lock_btpr
      then do:
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input "Процедура восстановления складского архива запросила остановку процедуры расчета складского архива"
          ) .
        undo, return error "Процедура восстановления складского архива запросила остановку процедуры расчета складского архива" .
      end.
      find first stop-arh-news-lock_btpr no-lock
        where stop-arh-news-lock_btpr.bp_type       = 'lock':U + 'rsrn':U
          and stop-arh-news-lock_btpr.bp_status     = 'N':U
          and stop-arh-news-lock_btpr.Key#_One      = buf_doc-list.obj-code
          and stop-arh-news-lock_btpr.Key#_Two      = 0
          and stop-arh-news-lock_btpr.Key#_Three    = 0
          and stop-arh-news-lock_btpr.CharKey_One   = buf_doc-list.obj-type
          and stop-arh-news-lock_btpr.CharKey_Three = ""
        no-error .
      if available stop-arh-news-lock_btpr
      then do:
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input "Система новостей запросила остановку процедуры расчета складского архива"
          ) .
        undo, return error "Система новостей запросила остановку процедуры расчета складского архива" .
      end.
      if buf_doc-list.is-trn-doc
      then do:
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Начало расчёта. Документ &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
        run trg/calc-arh.p
          (input buf_doc-list.doc-code
          ,input p-cut-date
          ).
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Расчёт завершен. Документ &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
      end.
      else do:
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Начало расчёта. Переоценка &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
        run trg/calc-apc.p
          (input buf_doc-list.doc-code
          ,input p-cut-date
          ).
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Расчёт завершен. Переоценка &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
      end.
      if  p-update-recalc  = true
      and v-prev-fact-date <> ?
      and buf_doc-list.fact-date > v-prev-fact-date
      then do:
        run gbl/clntat-w.p
          (input p-obj-type
          ,input p-obj-code
          ,input 'arh-recalc':U
          ,input string(buf_doc-list.fact-date, '99/99/9999':U)
          ) .
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Завершён расчет дня &1. Устанавливается дата перерасчёта &2"
                           ,string(v-prev-fact-date, '99/99/9999':u)
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           )
          ) .
      end.
      assign
        v-prev-fact-date = buf_doc-list.fact-date
      .
    end.
  end.
end procedure.
procedure doclslib-calc-aht :
  define input  parameter p-log-handle    as handle    no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define input  parameter p-cut-date      as date      no-undo .
  define input  parameter p-update-recalc as logical   no-undo .
  define variable v-prev-fact-date as date      no-undo .
  define buffer buf_doc-list for doc-list .
  define buffer stop-aht-restore-lock_btpr for ub.batchprocess .
  define buffer stop-aht-news-lock_btpr    for ub.batchprocess .
  do
  on error undo, return error return-value
  :
    define buffer buf_lock_gdsrenart_batchprocess for ub.batchprocess .
    run gbl/lockrngd.p
      (input  'grar':U
      ,input  'disable':U
      ,buffer buf_lock_gdsrenart_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при блокировании функции переименования артикула товара" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error return-value .
    end.
    define buffer buf_lock_gdsrengc_batchprocess for ub.batchprocess .
    run gbl/lockrngd.p
      (input  'grgc':U
      ,input  'disable':U
      ,buffer buf_lock_gdsrengc_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при блокировании функции переименования кода товара" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error return-value .
    end.
    for each buf_doc-list
    by buf_doc-list.fact-order
    on error undo, return error
    :
      find first stop-aht-restore-lock_btpr no-lock
        where stop-aht-restore-lock_btpr.bp_type       = 'lock':U + 'rsts':U
          and stop-aht-restore-lock_btpr.bp_status     = 'N':U
          and stop-aht-restore-lock_btpr.Key#_One      = buf_doc-list.obj-code
          and stop-aht-restore-lock_btpr.Key#_Two      = 0
          and stop-aht-restore-lock_btpr.Key#_Three    = 0
          and stop-aht-restore-lock_btpr.CharKey_One   = buf_doc-list.obj-type
          and stop-aht-restore-lock_btpr.CharKey_Two   = ""
          and stop-aht-restore-lock_btpr.CharKey_Three = ""
        no-error .
      if available stop-aht-restore-lock_btpr
      then do:
        undo, return error "Процедура восстановления складского архива запросила остановку процедуры автоматического расчета складского архива" .
      end.
      find first stop-aht-news-lock_btpr no-lock
        where stop-aht-news-lock_btpr.bp_type       = 'lock':U + 'rstn':U
          and stop-aht-news-lock_btpr.bp_status     = 'N':U
          and stop-aht-news-lock_btpr.Key#_One      = buf_doc-list.obj-code
          and stop-aht-news-lock_btpr.Key#_Two      = 0
          and stop-aht-news-lock_btpr.Key#_Three    = 0
          and stop-aht-news-lock_btpr.CharKey_One   = buf_doc-list.obj-type
          and stop-aht-news-lock_btpr.CharKey_Three = ""
        no-error .
      if available stop-aht-news-lock_btpr
      then do:
        undo, return error "Система новостей запросила остановку процедуры автоматического расчета складского архива" .
      end.
      if buf_doc-list.is-trn-doc
      then do:
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Начало расчёта. Документ &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
        run trg/aht-doc.p
          (input buf_doc-list.doc-code
          ,input p-cut-date
          ).
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Расчёт завершен. Документ &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
      end.
      else do:
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Начало расчёта. Переоценка &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
        run trg/aht-prc.p
          (input buf_doc-list.doc-code
          ,input p-cut-date
          ).
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Расчёт завершен. Переоценка &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
      end.
      if  p-update-recalc  = true
      and v-prev-fact-date <> ?
      and buf_doc-list.fact-date > v-prev-fact-date
      then do:
        run gbl/clntat-w.p
          (input p-obj-type
          ,input p-obj-code
          ,input 'aht-recalc':U
          ,input string(buf_doc-list.fact-date, '99/99/9999':U)
          ) .
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Завершён расчет дня &1. Устанавливается дата перерасчёта &2"
                           ,string(v-prev-fact-date, '99/99/9999':u)
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           )
          ) .
      end.
      assign
        v-prev-fact-date = buf_doc-list.fact-date
      .
    end.
  end.
end procedure.
procedure doclslib-calc-ahsp :
  define input  parameter p-log-handle    as handle    no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define input  parameter p-cut-date      as date      no-undo .
  define input  parameter p-update-recalc as logical   no-undo .
  define variable v-prev-fact-date as date      no-undo .
  define buffer buf_doc-list for doc-list .
  define buffer stop-ahsp-restore-lock_btpr for ub.batchprocess .
  define buffer stop-ahsp-news-lock_btpr    for ub.batchprocess .
  do
  on error undo, return error return-value
  :
    define buffer buf_lock_gdsrenart_batchprocess for ub.batchprocess .
    run gbl/lockrngd.p
      (input  'grar':U
      ,input  'disable':U
      ,buffer buf_lock_gdsrenart_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при блокировании функции переименования артикула товара" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error return-value .
    end.
    define buffer buf_lock_gdsrengc_batchprocess for ub.batchprocess .
    run gbl/lockrngd.p
      (input  'grgc':U
      ,input  'disable':U
      ,buffer buf_lock_gdsrengc_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при блокировании функции переименования кода товара" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error return-value .
    end.
    for each buf_doc-list
      where buf_doc-list.is-trn-doc = true
    by buf_doc-list.fact-order
    on error undo, return error
    :
      find first stop-ahsp-restore-lock_btpr no-lock
        where stop-ahsp-restore-lock_btpr.bp_type       = 'lock':U + 'rsss':U
          and stop-ahsp-restore-lock_btpr.bp_status     = 'N':U
          and stop-ahsp-restore-lock_btpr.Key#_One      = buf_doc-list.obj-code
          and stop-ahsp-restore-lock_btpr.Key#_Two      = 0
          and stop-ahsp-restore-lock_btpr.Key#_Three    = 0
          and stop-ahsp-restore-lock_btpr.CharKey_One   = buf_doc-list.obj-type
          and stop-ahsp-restore-lock_btpr.CharKey_Two   = ""
          and stop-ahsp-restore-lock_btpr.CharKey_Three = ""
        no-error .
      if available stop-ahsp-restore-lock_btpr
      then do:
        undo, return error "Процедура восстановления складского архива запросила остановку процедуры расчета складского архива" .
      end.
      find first stop-ahsp-news-lock_btpr no-lock
        where stop-ahsp-news-lock_btpr.bp_type       = 'lock':U + 'rssn':U
          and stop-ahsp-news-lock_btpr.bp_status     = 'N':U
          and stop-ahsp-news-lock_btpr.Key#_One      = buf_doc-list.obj-code
          and stop-ahsp-news-lock_btpr.Key#_Two      = 0
          and stop-ahsp-news-lock_btpr.Key#_Three    = 0
          and stop-ahsp-news-lock_btpr.CharKey_One   = buf_doc-list.obj-type
          and stop-ahsp-news-lock_btpr.CharKey_Three = ""
        no-error .
      if available stop-ahsp-news-lock_btpr
      then do:
        undo, return error "Система новостей запросила остановку процедуры расчета складского архива" .
      end.
      run doclslib-log-information in this-procedure
        (input p-log-handle
        ,input substitute("Начало расчёта. Документ &1. Факт &2. Номер &3"
                          ,buf_doc-list.doc-code
                          ,string(buf_doc-list.fact-date, '99/99/9999':u)
                          ,buf_doc-list.fact-order
                          )
        ) .
      define variable v-need-process as logical   no-undo .
      run trg/ah-csptr.p
        (input  buf_doc-list.doc-code
        ,input  p-cut-date
        ,input  false
        ,output v-need-process
        ).
      run doclslib-log-information in this-procedure
        (input p-log-handle
        ,input substitute("Расчёт завершен. Документ &1. Факт &2. Номер &3"
                          ,buf_doc-list.doc-code
                          ,string(buf_doc-list.fact-date, '99/99/9999':u)
                          ,buf_doc-list.fact-order
                          )
        ) .
      if  p-update-recalc  = true
      and v-prev-fact-date <> ?
      and buf_doc-list.fact-date > v-prev-fact-date
      then do:
        run gbl/clntat-w.p
          (input p-obj-type
          ,input p-obj-code
          ,input 'ahsp-recalc':U
          ,input string(buf_doc-list.fact-date, '99/99/9999':U)
          ) .
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Завершён расчет дня &1. Устанавливается дата перерасчёта &2"
                           ,string(v-prev-fact-date, '99/99/9999':u)
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           )
          ) .
      end.
      assign
        v-prev-fact-date = buf_doc-list.fact-date
      .
    end.
  end.
end procedure.
procedure doclslib-log-information :
  define input  parameter p-log-handle as handle    no-undo .
  define input  parameter p-message    as character no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-log-procedure-name as character no-undo .
    assign
      v-log-procedure-name = "cb-doclslib-log"
    .
    if valid-handle(p-log-handle)
    and p-log-handle :get-signature(v-log-procedure-name) <> ""
    then do:
      run value(v-log-procedure-name) in p-log-handle
        (input p-message
        ) no-error .
    end.
  end.
end procedure.
procedure doclslib-find-last-fact-date :
  define output parameter p-last-fact-date  as date      no-undo .
  define output parameter p-reason          as character no-undo .
  do
  on error undo, return error
  :
    define variable v-last-fact-date    as date      no-undo .
    define buffer buf_doc-list for doc-list .
    assign
      v-last-fact-date    = ?
    .
    for each buf_doc-list
    by buf_doc-list.fact-order
    on error undo, return error
    :
      if buf_doc-list.is-archive-exist = false
      or buf_doc-list.fact-date = ?
      then do:
        assign
          p-reason = p-reason + substitute("По документу &1 отсутствует рассчитанный складской архив"
                                          ,buf_doc-list.doc-code
                                          )
        .
        leave .
      end.
      if buf_doc-list.fact-date = ?
      then do:
        assign
          p-reason = p-reason + substitute("Документ &1 имеет не заданную фактическую дату "
                                          ,buf_doc-list.doc-code
                                          )
        .
        leave .
      end.
      if v-last-fact-date = ?
      or (v-last-fact-date <> ?
          and v-last-fact-date < buf_doc-list.fact-date
         )
      then do:
        assign
          v-last-fact-date = buf_doc-list.fact-date
          p-reason         = substitute("Последний рассчитанный документ &1" + chr(10)
                                       ,buf_doc-list.doc-code
                                       )
        .
      end.
    end.
    assign
      p-last-fact-date = v-last-fact-date
    .
  end.
end procedure.
procedure doclslib-check-arh-exist :
  define input parameter  p-obj-type       as character no-undo .
  define input parameter  p-obj-code       as integer   no-undo .
  define input parameter  p-cut-fact-order as decimal   no-undo .
  define output parameter p-archive-exist  as logical   no-undo .
  define buffer buf_stk-tot for ub.stk-tot .
  do
  on error undo, return error
  :
    find first buf_stk-tot no-lock
      where buf_stk-tot.obj-type   = p-obj-type
        and buf_stk-tot.obj-code   = p-obj-code
        and buf_stk-tot.fact-order > p-cut-fact-order
      no-error .
    assign
      p-archive-exist = (available buf_stk-tot)
    .
  end.
end procedure.
procedure doclslib-check-aht-exist :
  define input parameter  p-obj-type       as character no-undo .
  define input parameter  p-obj-code       as integer   no-undo .
  define input parameter  p-cut-fact-order as decimal   no-undo .
  define output parameter p-archive-exist  as logical   no-undo .
  define buffer buf_aht-stk-tot for ub.aht-stk-tot .
  do
  on error undo, return error
  :
    find first buf_aht-stk-tot no-lock
      where buf_aht-stk-tot.obj-type   = p-obj-type
        and buf_aht-stk-tot.obj-code   = p-obj-code
        and buf_aht-stk-tot.fact-order > p-cut-fact-order
      no-error .
    assign
      p-archive-exist = (available buf_aht-stk-tot)
    .
  end.
end procedure.
procedure doclslib-check-ahsp-exist :
  define input parameter  p-obj-type       as character no-undo .
  define input parameter  p-obj-code       as integer   no-undo .
  define input parameter  p-cut-fact-order as decimal   no-undo .
  define output parameter p-archive-exist  as logical   no-undo .
  define buffer buf_stk-supp-tot for ub.stk-supp-tot .
  do
  on error undo, return error
  :
    find first buf_stk-supp-tot no-lock
      where buf_stk-supp-tot.obj-type   = p-obj-type
        and buf_stk-supp-tot.obj-code   = p-obj-code
        and buf_stk-supp-tot.fact-order > p-cut-fact-order
      no-error .
    assign
      p-archive-exist = (available buf_stk-supp-tot)
    .
  end.
end procedure.
procedure doclslib-check-doc-arh-exist :
  define buffer buf_doc-list for doc-list .
  define buffer buf_ot-tot for ub.ot-tot .
  do
  on error undo, return error return-value
  :
    for each buf_doc-list
    on error undo, return error
    :
      find first buf_ot-tot no-lock
        where buf_ot-tot.doc-code = buf_doc-list.doc-code
        no-error .
      if available buf_ot-tot
      then do:
        assign
          buf_doc-list.is-archive-exist = true
        .
      end.
      else do:
        assign
          buf_doc-list.is-archive-exist = false
        .
      end.
    end.
  end.
end procedure.
procedure doclslib-check-doc-aht-exist :
  define buffer buf_doc-list for doc-list .
  define buffer buf_aht-doc for ub.aht-doc .
  do
  on error undo, return error return-value
  :
    for each buf_doc-list
    on error undo, return error
    :
      find first buf_aht-doc no-lock
        where buf_aht-doc.doc-code = buf_doc-list.doc-code
        no-error .
      if available buf_aht-doc
      then do:
        assign
          buf_doc-list.is-archive-exist = true
        .
      end.
      else do:
        assign
          buf_doc-list.is-archive-exist = false
        .
      end.
    end.
  end.
end procedure.
procedure doclslib-check-doc-ahsp-exist :
  define buffer buf_doc-list for doc-list .
  define buffer buf_ot-supp-line for ub.ot-supp-tot .
  do
  on error undo, return error return-value
  :
    for each buf_doc-list
    on error undo, return error
    :
      find first buf_ot-supp-line no-lock
        where buf_ot-supp-line.doc-code = buf_doc-list.doc-code
        no-error .
      if available buf_ot-supp-line
      then do:
        assign
          buf_doc-list.is-archive-exist = true
        .
      end.
      else do:
        if buf_doc-list.doc-type = 'инв':U
        then do:
          define variable v-need-process as logical   no-undo .
          run trg/ah-csptr.p
            (input  buf_doc-list.doc-code
            ,input  0
            ,input  true
            ,output v-need-process
            ).
          if v-need-process = true
          then do:
            assign
              buf_doc-list.is-archive-exist = false
            .
          end.
          else do:
            assign
              buf_doc-list.is-archive-exist = true
            .
          end.
        end.
        else do:
          assign
            buf_doc-list.is-archive-exist = false
          .
        end.
      end.
    end.
  end.
end procedure.
procedure doclslib-clear-ahsp-doc-list :
  define buffer buf_doc-list for doc-list .
  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_parts    for ub.parts .
  do
  on error undo, return error return-value
  :
    check-doc-list :
    for each buf_doc-list
    on error undo, return error return-value
    :
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = buf_doc-list.doc-code
        .
      if buf_trn-doc.office = true
      then do:
        delete buf_doc-list .
        next check-doc-list .
      end.
      find first buf_doc-line no-lock
        where buf_doc-line.doc-code = buf_trn-doc.doc-code
        no-error .
      if not available buf_doc-line
      then do:
        delete buf_doc-list .
        next check-doc-list .
      end.
      find first buf_parts no-lock
        where buf_parts.out-code = buf_trn-doc.doc-code
          and buf_parts.fact-qnty <> 0
        no-error .
      if not available buf_parts
      then do:
        delete buf_doc-list .
        next check-doc-list .
      end.
    end.
  end.
end procedure.
procedure doclslib-init-goods :
  define buffer buf_doclslib-goods for doclslib-goods .
  define buffer buf_doc-list       for doc-list .
  define buffer buf_trn-doc        for ub.trn-doc .
  define buffer buf_price-doc      for ub.price-doc .
  define buffer buf_doc-line       for ub.doc-line .
  define buffer buf_price-list     for ub.price-list .
  define variable v-gds-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    for each buf_doclslib-goods
    on error undo, return error return-value
    :
      delete buf_doclslib-goods .
    end.
    for each buf_doc-list
    on error undo, return error return-value
    :
      if buf_doc-list.is-trn-doc
      then do:
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_doc-list.doc-code
          .
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
        on error undo, return error return-value
        :
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output v-gds-code
  )  .
          find first buf_doclslib-goods
            where buf_doclslib-goods.gds-code = v-gds-code
            no-error .
          if not available buf_doclslib-goods
          then do:
            create buf_doclslib-goods .
            assign
              buf_doclslib-goods.gds-code  = v-gds-code
              buf_doclslib-goods.artic     = buf_doc-line.artic
              buf_doclslib-goods.prod-type = buf_doc-line.prod-type
              buf_doclslib-goods.prod-code = buf_doc-line.prod-code
            .
          end.
        end.
      end.
      else do:
        find first buf_price-doc no-lock
          where buf_price-doc.doc-num = buf_doc-list.doc-code
          .
        for each buf_price-list no-lock
          where buf_price-list.doc-num = buf_price-doc.doc-num
        on error undo, return error return-value
        :
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_price-list.artic
  ,input  buf_price-list.prod-type
  ,input  buf_price-list.prod-code
  ,output v-gds-code
  )  .
          find first buf_doclslib-goods
            where buf_doclslib-goods.gds-code = v-gds-code
            no-error .
          if not available buf_doclslib-goods
          then do:
            create buf_doclslib-goods .
            assign
              buf_doclslib-goods.gds-code  = v-gds-code
              buf_doclslib-goods.artic     = buf_price-list.artic
              buf_doclslib-goods.prod-type = buf_price-list.prod-type
              buf_doclslib-goods.prod-code = buf_price-list.prod-code
            .
          end.
        end.
      end.
    end.
  end.
end procedure.
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define stream ahtlog .
define temp-table temp-aht-ot-tot no-undo like ub.aht-ot-tot .
define temp-table temp-aht-ot-line no-undo like ub.aht-ot-line .
define temp-table temp-aht-stk-tot no-undo like ub.aht-stk-tot .
define temp-table temp-aht-stk-line no-undo like ub.aht-stk-line .
procedure aht_get-sum-type :
  define input  parameter p-aht-type        as character no-undo .
  define output parameter p-allsum-sum-type as character no-undo .
  do
  on error undo, return error return-value
  :
    case p-aht-type :
      when 'r':U then do:
        assign
          p-allsum-sum-type = 'сумма_по_выкупу_со_знаком':U
        .
      end.
      when 'c':U then do:
        assign
          p-allsum-sum-type = 'сумма_по_консигнации_закупка_со_знаком':U
        .
      end.
      when 'b':U then do:
        assign
          p-allsum-sum-type = 'сумма_по_консигнации_выгода_со_знаком':U
        .
      end.
      when 's':U then do:
        assign
          p-allsum-sum-type = 'сумма_по_ответственному_хранению_со_знаком':U
        .
      end.
      when 'o':U then do:
        assign
          p-allsum-sum-type = 'сумма_по_старой_консигнации_со_знаком':U
        .
      end.
      when 'v':U then do:
        assign
          p-allsum-sum-type = 'сумма_по_услуге_со_знаком':U
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info8 skip
          "Неизвестное значение типа приобретения" skip
          "Тип приобретения" p-aht-type skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
end procedure.
procedure aht_get-stk-sum-type :
  define input  parameter p-ot-sum-type      as character no-undo .
  define input  parameter p-ext-doc-type     as character no-undo .
  define output parameter p-stk-ext-sum-type as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-stk-ext-sum-type = p-ot-sum-type + p-ext-doc-type
    .
  end.
end procedure.
procedure aht_store-ot-line :
  define input  parameter p-doc-code       as character no-undo .
  define input  parameter p-gds-code       as integer   no-undo .
  define input  parameter p-sum-type       as character no-undo .
  define input  parameter p-ext-doc-type   as character no-undo .
  define input  parameter p-obj-type       as character no-undo .
  define input  parameter p-obj-code       as integer   no-undo .
  define input  parameter p-fact-order     as decimal   no-undo .
  define input  parameter p-fact-qnty      as decimal   no-undo .
          define input  parameter p-cost-sum-base       as decimal   no-undo .     define input  parameter p-cost-sum-rubl       as decimal   no-undo .     define input  parameter p-cost-vat-base       as decimal   no-undo .     define input  parameter p-cost-vat-rubl       as decimal   no-undo .     define input  parameter p-cost-slt-base       as decimal   no-undo .     define input  parameter p-cost-slt-rubl       as decimal   no-undo .     define input  parameter p-cost-road-tax-base  as decimal   no-undo .     define input  parameter p-cost-road-tax-rubl  as decimal   no-undo .     define input  parameter p-cost-excise-base    as decimal   no-undo .     define input  parameter p-cost-excise-rubl    as decimal   no-undo .     define input  parameter p-cost-transport-base as decimal   no-undo .     define input  parameter p-cost-transport-rubl as decimal   no-undo .     define input  parameter p-cost-other-base     as decimal   no-undo .     define input  parameter p-cost-other-rubl     as decimal   no-undo .     define input  parameter p-cost-discnt-base    as decimal   no-undo .     define input  parameter p-cost-discnt-rubl    as decimal   no-undo .
          define input  parameter p-crsa-sum-base       as decimal   no-undo .     define input  parameter p-crsa-sum-rubl       as decimal   no-undo .     define input  parameter p-crsa-vat-base       as decimal   no-undo .     define input  parameter p-crsa-vat-rubl       as decimal   no-undo .     define input  parameter p-crsa-slt-base       as decimal   no-undo .     define input  parameter p-crsa-slt-rubl       as decimal   no-undo .     define input  parameter p-crsa-road-tax-base  as decimal   no-undo .     define input  parameter p-crsa-road-tax-rubl  as decimal   no-undo .     define input  parameter p-crsa-excise-base    as decimal   no-undo .     define input  parameter p-crsa-excise-rubl    as decimal   no-undo .     define input  parameter p-crsa-transport-base as decimal   no-undo .     define input  parameter p-crsa-transport-rubl as decimal   no-undo .     define input  parameter p-crsa-other-base     as decimal   no-undo .     define input  parameter p-crsa-other-rubl     as decimal   no-undo .     define input  parameter p-crsa-discnt-base    as decimal   no-undo .     define input  parameter p-crsa-discnt-rubl    as decimal   no-undo .
          define input  parameter p-sale-sum-base       as decimal   no-undo .     define input  parameter p-sale-sum-rubl       as decimal   no-undo .     define input  parameter p-sale-vat-base       as decimal   no-undo .     define input  parameter p-sale-vat-rubl       as decimal   no-undo .     define input  parameter p-sale-slt-base       as decimal   no-undo .     define input  parameter p-sale-slt-rubl       as decimal   no-undo .     define input  parameter p-sale-road-tax-base  as decimal   no-undo .     define input  parameter p-sale-road-tax-rubl  as decimal   no-undo .     define input  parameter p-sale-excise-base    as decimal   no-undo .     define input  parameter p-sale-excise-rubl    as decimal   no-undo .     define input  parameter p-sale-transport-base as decimal   no-undo .     define input  parameter p-sale-transport-rubl as decimal   no-undo .     define input  parameter p-sale-other-base     as decimal   no-undo .     define input  parameter p-sale-other-rubl     as decimal   no-undo .     define input  parameter p-sale-discnt-base    as decimal   no-undo .     define input  parameter p-sale-discnt-rubl    as decimal   no-undo .
  define buffer buf_temp-aht-ot-line for temp-aht-ot-line .
  do
  on error undo, return error return-value
  :
    find first buf_temp-aht-ot-line
      where buf_temp-aht-ot-line.doc-code  = p-doc-code
        and buf_temp-aht-ot-line.gds-code  = p-gds-code
        and buf_temp-aht-ot-line.sum-type  = p-sum-type
      no-error .
    if not available buf_temp-aht-ot-line then do:
      create buf_temp-aht-ot-line .
      assign
        buf_temp-aht-ot-line.doc-code     = p-doc-code
        buf_temp-aht-ot-line.gds-code     = p-gds-code
        buf_temp-aht-ot-line.sum-type     = p-sum-type
        buf_temp-aht-ot-line.ext-doc-type = p-ext-doc-type
        buf_temp-aht-ot-line.obj-type     = p-obj-type
        buf_temp-aht-ot-line.obj-code     = p-obj-code
        buf_temp-aht-ot-line.fact-order   = p-fact-order
      .
    end.
    assign
      buf_temp-aht-ot-line.fact-qnty = buf_temp-aht-ot-line.fact-qnty + p-fact-qnty
                                                      buf_temp-aht-ot-line.cost-sum-base       = buf_temp-aht-ot-line.cost-sum-base       + p-cost-sum-base            buf_temp-aht-ot-line.cost-sum-rubl       = buf_temp-aht-ot-line.cost-sum-rubl       + p-cost-sum-rubl            buf_temp-aht-ot-line.cost-vat-base       = buf_temp-aht-ot-line.cost-vat-base       + p-cost-vat-base            buf_temp-aht-ot-line.cost-vat-rubl       = buf_temp-aht-ot-line.cost-vat-rubl       + p-cost-vat-rubl            buf_temp-aht-ot-line.cost-slt-base       = buf_temp-aht-ot-line.cost-slt-base       + p-cost-slt-base            buf_temp-aht-ot-line.cost-slt-rubl       = buf_temp-aht-ot-line.cost-slt-rubl       + p-cost-slt-rubl            buf_temp-aht-ot-line.cost-road-tax-base  = buf_temp-aht-ot-line.cost-road-tax-base  + p-cost-road-tax-base       buf_temp-aht-ot-line.cost-road-tax-rubl  = buf_temp-aht-ot-line.cost-road-tax-rubl  + p-cost-road-tax-rubl       buf_temp-aht-ot-line.cost-excise-base    = buf_temp-aht-ot-line.cost-excise-base    + p-cost-excise-base         buf_temp-aht-ot-line.cost-excise-rubl    = buf_temp-aht-ot-line.cost-excise-rubl    + p-cost-excise-rubl         buf_temp-aht-ot-line.cost-transport-base = buf_temp-aht-ot-line.cost-transport-base + p-cost-transport-base      buf_temp-aht-ot-line.cost-transport-rubl = buf_temp-aht-ot-line.cost-transport-rubl + p-cost-transport-rubl      buf_temp-aht-ot-line.cost-other-base     = buf_temp-aht-ot-line.cost-other-base     + p-cost-other-base          buf_temp-aht-ot-line.cost-other-rubl     = buf_temp-aht-ot-line.cost-other-rubl     + p-cost-other-rubl          buf_temp-aht-ot-line.cost-discnt-base    = buf_temp-aht-ot-line.cost-discnt-base    + p-cost-discnt-base          buf_temp-aht-ot-line.cost-discnt-rubl    = buf_temp-aht-ot-line.cost-discnt-rubl    + p-cost-discnt-rubl
                                                      buf_temp-aht-ot-line.crsa-sum-base       = buf_temp-aht-ot-line.crsa-sum-base       + p-crsa-sum-base            buf_temp-aht-ot-line.crsa-sum-rubl       = buf_temp-aht-ot-line.crsa-sum-rubl       + p-crsa-sum-rubl            buf_temp-aht-ot-line.crsa-vat-base       = buf_temp-aht-ot-line.crsa-vat-base       + p-crsa-vat-base            buf_temp-aht-ot-line.crsa-vat-rubl       = buf_temp-aht-ot-line.crsa-vat-rubl       + p-crsa-vat-rubl            buf_temp-aht-ot-line.crsa-slt-base       = buf_temp-aht-ot-line.crsa-slt-base       + p-crsa-slt-base            buf_temp-aht-ot-line.crsa-slt-rubl       = buf_temp-aht-ot-line.crsa-slt-rubl       + p-crsa-slt-rubl            buf_temp-aht-ot-line.crsa-road-tax-base  = buf_temp-aht-ot-line.crsa-road-tax-base  + p-crsa-road-tax-base       buf_temp-aht-ot-line.crsa-road-tax-rubl  = buf_temp-aht-ot-line.crsa-road-tax-rubl  + p-crsa-road-tax-rubl       buf_temp-aht-ot-line.crsa-excise-base    = buf_temp-aht-ot-line.crsa-excise-base    + p-crsa-excise-base         buf_temp-aht-ot-line.crsa-excise-rubl    = buf_temp-aht-ot-line.crsa-excise-rubl    + p-crsa-excise-rubl         buf_temp-aht-ot-line.crsa-transport-base = buf_temp-aht-ot-line.crsa-transport-base + p-crsa-transport-base      buf_temp-aht-ot-line.crsa-transport-rubl = buf_temp-aht-ot-line.crsa-transport-rubl + p-crsa-transport-rubl      buf_temp-aht-ot-line.crsa-other-base     = buf_temp-aht-ot-line.crsa-other-base     + p-crsa-other-base          buf_temp-aht-ot-line.crsa-other-rubl     = buf_temp-aht-ot-line.crsa-other-rubl     + p-crsa-other-rubl          buf_temp-aht-ot-line.crsa-discnt-base    = buf_temp-aht-ot-line.crsa-discnt-base    + p-crsa-discnt-base          buf_temp-aht-ot-line.crsa-discnt-rubl    = buf_temp-aht-ot-line.crsa-discnt-rubl    + p-crsa-discnt-rubl
                                                      buf_temp-aht-ot-line.sale-sum-base       = buf_temp-aht-ot-line.sale-sum-base       + p-sale-sum-base            buf_temp-aht-ot-line.sale-sum-rubl       = buf_temp-aht-ot-line.sale-sum-rubl       + p-sale-sum-rubl            buf_temp-aht-ot-line.sale-vat-base       = buf_temp-aht-ot-line.sale-vat-base       + p-sale-vat-base            buf_temp-aht-ot-line.sale-vat-rubl       = buf_temp-aht-ot-line.sale-vat-rubl       + p-sale-vat-rubl            buf_temp-aht-ot-line.sale-slt-base       = buf_temp-aht-ot-line.sale-slt-base       + p-sale-slt-base            buf_temp-aht-ot-line.sale-slt-rubl       = buf_temp-aht-ot-line.sale-slt-rubl       + p-sale-slt-rubl            buf_temp-aht-ot-line.sale-road-tax-base  = buf_temp-aht-ot-line.sale-road-tax-base  + p-sale-road-tax-base       buf_temp-aht-ot-line.sale-road-tax-rubl  = buf_temp-aht-ot-line.sale-road-tax-rubl  + p-sale-road-tax-rubl       buf_temp-aht-ot-line.sale-excise-base    = buf_temp-aht-ot-line.sale-excise-base    + p-sale-excise-base         buf_temp-aht-ot-line.sale-excise-rubl    = buf_temp-aht-ot-line.sale-excise-rubl    + p-sale-excise-rubl         buf_temp-aht-ot-line.sale-transport-base = buf_temp-aht-ot-line.sale-transport-base + p-sale-transport-base      buf_temp-aht-ot-line.sale-transport-rubl = buf_temp-aht-ot-line.sale-transport-rubl + p-sale-transport-rubl      buf_temp-aht-ot-line.sale-other-base     = buf_temp-aht-ot-line.sale-other-base     + p-sale-other-base          buf_temp-aht-ot-line.sale-other-rubl     = buf_temp-aht-ot-line.sale-other-rubl     + p-sale-other-rubl          buf_temp-aht-ot-line.sale-discnt-base    = buf_temp-aht-ot-line.sale-discnt-base    + p-sale-discnt-base          buf_temp-aht-ot-line.sale-discnt-rubl    = buf_temp-aht-ot-line.sale-discnt-rubl    + p-sale-discnt-rubl
    .
  end.
end procedure.
procedure aht_update-ot-tot :
  define input  parameter p-obj-type            like ub.trn-doc.obj-type     no-undo .
  define input  parameter p-obj-code            like ub.trn-doc.obj-code     no-undo .
  define input  parameter p-fact-order          like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-ext-doc-type        like ub.trn-doc.ext-doc-type no-undo .
  define buffer buf_temp-aht-ot-line for temp-aht-ot-line .
  define buffer buf_temp-aht-ot-tot for temp-aht-ot-tot .
  do
  on error undo, return error
  :
    for each buf_temp-aht-ot-line
    on error undo, return error
    :
      find first buf_temp-aht-ot-tot
        where buf_temp-aht-ot-tot.doc-code = buf_temp-aht-ot-line.doc-code
          and buf_temp-aht-ot-tot.sum-type = buf_temp-aht-ot-line.sum-type
        no-error .
      if not available buf_temp-aht-ot-tot then do:
        create buf_temp-aht-ot-tot .
        assign
          buf_temp-aht-ot-tot.doc-code     = buf_temp-aht-ot-line.doc-code
          buf_temp-aht-ot-tot.sum-type     = buf_temp-aht-ot-line.sum-type
          buf_temp-aht-ot-tot.ext-doc-type = p-ext-doc-type
          buf_temp-aht-ot-tot.obj-type     = p-obj-type
          buf_temp-aht-ot-tot.obj-code     = p-obj-code
          buf_temp-aht-ot-tot.fact-order   = p-fact-order
        .
      end.
      assign
        buf_temp-aht-ot-tot.fact-qnty = buf_temp-aht-ot-tot.fact-qnty + buf_temp-aht-ot-line.fact-qnty
                                                                        buf_temp-aht-ot-tot.cost-sum-base       = buf_temp-aht-ot-tot.cost-sum-base       + buf_temp-aht-ot-line.cost-sum-base            buf_temp-aht-ot-tot.cost-sum-rubl       = buf_temp-aht-ot-tot.cost-sum-rubl       + buf_temp-aht-ot-line.cost-sum-rubl            buf_temp-aht-ot-tot.cost-vat-base       = buf_temp-aht-ot-tot.cost-vat-base       + buf_temp-aht-ot-line.cost-vat-base            buf_temp-aht-ot-tot.cost-vat-rubl       = buf_temp-aht-ot-tot.cost-vat-rubl       + buf_temp-aht-ot-line.cost-vat-rubl            buf_temp-aht-ot-tot.cost-slt-base       = buf_temp-aht-ot-tot.cost-slt-base       + buf_temp-aht-ot-line.cost-slt-base            buf_temp-aht-ot-tot.cost-slt-rubl       = buf_temp-aht-ot-tot.cost-slt-rubl       + buf_temp-aht-ot-line.cost-slt-rubl            buf_temp-aht-ot-tot.cost-road-tax-base  = buf_temp-aht-ot-tot.cost-road-tax-base  + buf_temp-aht-ot-line.cost-road-tax-base       buf_temp-aht-ot-tot.cost-road-tax-rubl  = buf_temp-aht-ot-tot.cost-road-tax-rubl  + buf_temp-aht-ot-line.cost-road-tax-rubl       buf_temp-aht-ot-tot.cost-excise-base    = buf_temp-aht-ot-tot.cost-excise-base    + buf_temp-aht-ot-line.cost-excise-base         buf_temp-aht-ot-tot.cost-excise-rubl    = buf_temp-aht-ot-tot.cost-excise-rubl    + buf_temp-aht-ot-line.cost-excise-rubl         buf_temp-aht-ot-tot.cost-transport-base = buf_temp-aht-ot-tot.cost-transport-base + buf_temp-aht-ot-line.cost-transport-base      buf_temp-aht-ot-tot.cost-transport-rubl = buf_temp-aht-ot-tot.cost-transport-rubl + buf_temp-aht-ot-line.cost-transport-rubl      buf_temp-aht-ot-tot.cost-other-base     = buf_temp-aht-ot-tot.cost-other-base     + buf_temp-aht-ot-line.cost-other-base          buf_temp-aht-ot-tot.cost-other-rubl     = buf_temp-aht-ot-tot.cost-other-rubl     + buf_temp-aht-ot-line.cost-other-rubl          buf_temp-aht-ot-tot.cost-discnt-base    = buf_temp-aht-ot-tot.cost-discnt-base    + buf_temp-aht-ot-line.cost-discnt-base          buf_temp-aht-ot-tot.cost-discnt-rubl    = buf_temp-aht-ot-tot.cost-discnt-rubl    + buf_temp-aht-ot-line.cost-discnt-rubl
                                                                        buf_temp-aht-ot-tot.crsa-sum-base       = buf_temp-aht-ot-tot.crsa-sum-base       + buf_temp-aht-ot-line.crsa-sum-base            buf_temp-aht-ot-tot.crsa-sum-rubl       = buf_temp-aht-ot-tot.crsa-sum-rubl       + buf_temp-aht-ot-line.crsa-sum-rubl            buf_temp-aht-ot-tot.crsa-vat-base       = buf_temp-aht-ot-tot.crsa-vat-base       + buf_temp-aht-ot-line.crsa-vat-base            buf_temp-aht-ot-tot.crsa-vat-rubl       = buf_temp-aht-ot-tot.crsa-vat-rubl       + buf_temp-aht-ot-line.crsa-vat-rubl            buf_temp-aht-ot-tot.crsa-slt-base       = buf_temp-aht-ot-tot.crsa-slt-base       + buf_temp-aht-ot-line.crsa-slt-base            buf_temp-aht-ot-tot.crsa-slt-rubl       = buf_temp-aht-ot-tot.crsa-slt-rubl       + buf_temp-aht-ot-line.crsa-slt-rubl            buf_temp-aht-ot-tot.crsa-road-tax-base  = buf_temp-aht-ot-tot.crsa-road-tax-base  + buf_temp-aht-ot-line.crsa-road-tax-base       buf_temp-aht-ot-tot.crsa-road-tax-rubl  = buf_temp-aht-ot-tot.crsa-road-tax-rubl  + buf_temp-aht-ot-line.crsa-road-tax-rubl       buf_temp-aht-ot-tot.crsa-excise-base    = buf_temp-aht-ot-tot.crsa-excise-base    + buf_temp-aht-ot-line.crsa-excise-base         buf_temp-aht-ot-tot.crsa-excise-rubl    = buf_temp-aht-ot-tot.crsa-excise-rubl    + buf_temp-aht-ot-line.crsa-excise-rubl         buf_temp-aht-ot-tot.crsa-transport-base = buf_temp-aht-ot-tot.crsa-transport-base + buf_temp-aht-ot-line.crsa-transport-base      buf_temp-aht-ot-tot.crsa-transport-rubl = buf_temp-aht-ot-tot.crsa-transport-rubl + buf_temp-aht-ot-line.crsa-transport-rubl      buf_temp-aht-ot-tot.crsa-other-base     = buf_temp-aht-ot-tot.crsa-other-base     + buf_temp-aht-ot-line.crsa-other-base          buf_temp-aht-ot-tot.crsa-other-rubl     = buf_temp-aht-ot-tot.crsa-other-rubl     + buf_temp-aht-ot-line.crsa-other-rubl          buf_temp-aht-ot-tot.crsa-discnt-base    = buf_temp-aht-ot-tot.crsa-discnt-base    + buf_temp-aht-ot-line.crsa-discnt-base          buf_temp-aht-ot-tot.crsa-discnt-rubl    = buf_temp-aht-ot-tot.crsa-discnt-rubl    + buf_temp-aht-ot-line.crsa-discnt-rubl
                                                                        buf_temp-aht-ot-tot.sale-sum-base       = buf_temp-aht-ot-tot.sale-sum-base       + buf_temp-aht-ot-line.sale-sum-base            buf_temp-aht-ot-tot.sale-sum-rubl       = buf_temp-aht-ot-tot.sale-sum-rubl       + buf_temp-aht-ot-line.sale-sum-rubl            buf_temp-aht-ot-tot.sale-vat-base       = buf_temp-aht-ot-tot.sale-vat-base       + buf_temp-aht-ot-line.sale-vat-base            buf_temp-aht-ot-tot.sale-vat-rubl       = buf_temp-aht-ot-tot.sale-vat-rubl       + buf_temp-aht-ot-line.sale-vat-rubl            buf_temp-aht-ot-tot.sale-slt-base       = buf_temp-aht-ot-tot.sale-slt-base       + buf_temp-aht-ot-line.sale-slt-base            buf_temp-aht-ot-tot.sale-slt-rubl       = buf_temp-aht-ot-tot.sale-slt-rubl       + buf_temp-aht-ot-line.sale-slt-rubl            buf_temp-aht-ot-tot.sale-road-tax-base  = buf_temp-aht-ot-tot.sale-road-tax-base  + buf_temp-aht-ot-line.sale-road-tax-base       buf_temp-aht-ot-tot.sale-road-tax-rubl  = buf_temp-aht-ot-tot.sale-road-tax-rubl  + buf_temp-aht-ot-line.sale-road-tax-rubl       buf_temp-aht-ot-tot.sale-excise-base    = buf_temp-aht-ot-tot.sale-excise-base    + buf_temp-aht-ot-line.sale-excise-base         buf_temp-aht-ot-tot.sale-excise-rubl    = buf_temp-aht-ot-tot.sale-excise-rubl    + buf_temp-aht-ot-line.sale-excise-rubl         buf_temp-aht-ot-tot.sale-transport-base = buf_temp-aht-ot-tot.sale-transport-base + buf_temp-aht-ot-line.sale-transport-base      buf_temp-aht-ot-tot.sale-transport-rubl = buf_temp-aht-ot-tot.sale-transport-rubl + buf_temp-aht-ot-line.sale-transport-rubl      buf_temp-aht-ot-tot.sale-other-base     = buf_temp-aht-ot-tot.sale-other-base     + buf_temp-aht-ot-line.sale-other-base          buf_temp-aht-ot-tot.sale-other-rubl     = buf_temp-aht-ot-tot.sale-other-rubl     + buf_temp-aht-ot-line.sale-other-rubl          buf_temp-aht-ot-tot.sale-discnt-base    = buf_temp-aht-ot-tot.sale-discnt-base    + buf_temp-aht-ot-line.sale-discnt-base          buf_temp-aht-ot-tot.sale-discnt-rubl    = buf_temp-aht-ot-tot.sale-discnt-rubl    + buf_temp-aht-ot-line.sale-discnt-rubl
      .
    end.
  end.
end procedure.
procedure aht_update-stk-table :
  define input  parameter p-fact-order     like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-cut-fact-order like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-ext-doc-type   like ub.trn-doc.ext-doc-type no-undo .
  define input  parameter p-trn-doc        as logical   no-undo .
  define buffer buf_temp-aht-ot-tot for temp-aht-ot-tot .
  define buffer buf_temp-aht-ot-line for temp-aht-ot-line .
  define variable v-stk-ext-sum-type as character no-undo .
  do
  on error undo, return error
  :
    for each buf_temp-aht-ot-tot
    on error undo, return error
    :
      run aht_get-stk-sum-type in this-procedure
        (input  buf_temp-aht-ot-tot.sum-type
        ,input  p-ext-doc-type
        ,output v-stk-ext-sum-type
        ) .
      run aht_store-stk-tot in this-procedure
        (buffer buf_temp-aht-ot-tot
        ,input buf_temp-aht-ot-tot.sum-type
        ,input p-fact-order
        ,input p-cut-fact-order
        ,input p-ext-doc-type
        ,input false
        ) .
      run aht_store-stk-tot in this-procedure
        (buffer buf_temp-aht-ot-tot
        ,input v-stk-ext-sum-type
        ,input p-fact-order
        ,input p-cut-fact-order
        ,input p-ext-doc-type
        ,input p-trn-doc
        ) .
    end.
    for each buf_temp-aht-ot-line
    on error undo, return error
    :
      run aht_get-stk-sum-type in this-procedure
        (input  buf_temp-aht-ot-line.sum-type
        ,input  p-ext-doc-type
        ,output v-stk-ext-sum-type
        ) .
      run aht_store-stk-line in this-procedure
        (buffer buf_temp-aht-ot-line
        ,input buf_temp-aht-ot-line.sum-type
        ,input p-fact-order
        ,input p-cut-fact-order
        ,input p-ext-doc-type
        ,input false
        ) .
      run aht_store-stk-line in this-procedure
        (buffer buf_temp-aht-ot-line
        ,input v-stk-ext-sum-type
        ,input p-fact-order
        ,input p-cut-fact-order
        ,input p-ext-doc-type
        ,input p-trn-doc
        ) .
    end.
  end.
end procedure.
procedure aht_store-stk-tot :
  define parameter buffer buf_temp-aht-ot-tot for temp-aht-ot-tot .
  define input  parameter p-stk-sum-type      as character no-undo .
  define input  parameter p-fact-order        like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-cut-fact-order    like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-ext-doc-type      like ub.trn-doc.ext-doc-type no-undo .
  define input  parameter p-update-sale       as logical   no-undo .
  define buffer buf_aht-stk-tot for ub.aht-stk-tot .
  define buffer new-buf_aht-stk-tot for ub.aht-stk-tot .
  do
  on error undo, return error return-value
  :
    find last buf_aht-stk-tot exclusive-lock
      where buf_aht-stk-tot.obj-type   = buf_temp-aht-ot-tot.obj-type
        and buf_aht-stk-tot.obj-code   = buf_temp-aht-ot-tot.obj-code
        and buf_aht-stk-tot.sum-type   = p-stk-sum-type
        and buf_aht-stk-tot.fact-order <= p-fact-order
      use-index category
      no-error .
    if not available buf_aht-stk-tot
    or buf_aht-stk-tot.fact-order <> p-fact-order
    then do:
      create new-buf_aht-stk-tot .
      assign
        new-buf_aht-stk-tot.obj-type   = buf_temp-aht-ot-tot.obj-type
        new-buf_aht-stk-tot.obj-code   = buf_temp-aht-ot-tot.obj-code
        new-buf_aht-stk-tot.fact-order = p-fact-order
        new-buf_aht-stk-tot.sum-type   = p-stk-sum-type
      .
      if available buf_aht-stk-tot then do:
        assign
          new-buf_aht-stk-tot.fact-qnty = buf_aht-stk-tot.fact-qnty
                                                                      new-buf_aht-stk-tot.cost-sum-base       = buf_aht-stk-tot.cost-sum-base             new-buf_aht-stk-tot.cost-sum-rubl       = buf_aht-stk-tot.cost-sum-rubl             new-buf_aht-stk-tot.cost-vat-base       = buf_aht-stk-tot.cost-vat-base             new-buf_aht-stk-tot.cost-vat-rubl       = buf_aht-stk-tot.cost-vat-rubl             new-buf_aht-stk-tot.cost-slt-base       = buf_aht-stk-tot.cost-slt-base             new-buf_aht-stk-tot.cost-slt-rubl       = buf_aht-stk-tot.cost-slt-rubl             new-buf_aht-stk-tot.cost-road-tax-base  = buf_aht-stk-tot.cost-road-tax-base        new-buf_aht-stk-tot.cost-road-tax-rubl  = buf_aht-stk-tot.cost-road-tax-rubl        new-buf_aht-stk-tot.cost-excise-base    = buf_aht-stk-tot.cost-excise-base          new-buf_aht-stk-tot.cost-excise-rubl    = buf_aht-stk-tot.cost-excise-rubl          new-buf_aht-stk-tot.cost-transport-base = buf_aht-stk-tot.cost-transport-base       new-buf_aht-stk-tot.cost-transport-rubl = buf_aht-stk-tot.cost-transport-rubl       new-buf_aht-stk-tot.cost-other-base     = buf_aht-stk-tot.cost-other-base           new-buf_aht-stk-tot.cost-other-rubl     = buf_aht-stk-tot.cost-other-rubl           new-buf_aht-stk-tot.cost-discnt-base    = buf_aht-stk-tot.cost-discnt-base          new-buf_aht-stk-tot.cost-discnt-rubl    = buf_aht-stk-tot.cost-discnt-rubl
                                                                      new-buf_aht-stk-tot.crsa-sum-base       = buf_aht-stk-tot.crsa-sum-base             new-buf_aht-stk-tot.crsa-sum-rubl       = buf_aht-stk-tot.crsa-sum-rubl             new-buf_aht-stk-tot.crsa-vat-base       = buf_aht-stk-tot.crsa-vat-base             new-buf_aht-stk-tot.crsa-vat-rubl       = buf_aht-stk-tot.crsa-vat-rubl             new-buf_aht-stk-tot.crsa-slt-base       = buf_aht-stk-tot.crsa-slt-base             new-buf_aht-stk-tot.crsa-slt-rubl       = buf_aht-stk-tot.crsa-slt-rubl             new-buf_aht-stk-tot.crsa-road-tax-base  = buf_aht-stk-tot.crsa-road-tax-base        new-buf_aht-stk-tot.crsa-road-tax-rubl  = buf_aht-stk-tot.crsa-road-tax-rubl        new-buf_aht-stk-tot.crsa-excise-base    = buf_aht-stk-tot.crsa-excise-base          new-buf_aht-stk-tot.crsa-excise-rubl    = buf_aht-stk-tot.crsa-excise-rubl          new-buf_aht-stk-tot.crsa-transport-base = buf_aht-stk-tot.crsa-transport-base       new-buf_aht-stk-tot.crsa-transport-rubl = buf_aht-stk-tot.crsa-transport-rubl       new-buf_aht-stk-tot.crsa-other-base     = buf_aht-stk-tot.crsa-other-base           new-buf_aht-stk-tot.crsa-other-rubl     = buf_aht-stk-tot.crsa-other-rubl           new-buf_aht-stk-tot.crsa-discnt-base    = buf_aht-stk-tot.crsa-discnt-base          new-buf_aht-stk-tot.crsa-discnt-rubl    = buf_aht-stk-tot.crsa-discnt-rubl
        .
        if p-update-sale then do:
          assign
                                                                                    new-buf_aht-stk-tot.sale-sum-base       = buf_aht-stk-tot.sale-sum-base             new-buf_aht-stk-tot.sale-sum-rubl       = buf_aht-stk-tot.sale-sum-rubl             new-buf_aht-stk-tot.sale-vat-base       = buf_aht-stk-tot.sale-vat-base             new-buf_aht-stk-tot.sale-vat-rubl       = buf_aht-stk-tot.sale-vat-rubl             new-buf_aht-stk-tot.sale-slt-base       = buf_aht-stk-tot.sale-slt-base             new-buf_aht-stk-tot.sale-slt-rubl       = buf_aht-stk-tot.sale-slt-rubl             new-buf_aht-stk-tot.sale-road-tax-base  = buf_aht-stk-tot.sale-road-tax-base        new-buf_aht-stk-tot.sale-road-tax-rubl  = buf_aht-stk-tot.sale-road-tax-rubl        new-buf_aht-stk-tot.sale-excise-base    = buf_aht-stk-tot.sale-excise-base          new-buf_aht-stk-tot.sale-excise-rubl    = buf_aht-stk-tot.sale-excise-rubl          new-buf_aht-stk-tot.sale-transport-base = buf_aht-stk-tot.sale-transport-base       new-buf_aht-stk-tot.sale-transport-rubl = buf_aht-stk-tot.sale-transport-rubl       new-buf_aht-stk-tot.sale-other-base     = buf_aht-stk-tot.sale-other-base           new-buf_aht-stk-tot.sale-other-rubl     = buf_aht-stk-tot.sale-other-rubl           new-buf_aht-stk-tot.sale-discnt-base    = buf_aht-stk-tot.sale-discnt-base          new-buf_aht-stk-tot.sale-discnt-rubl    = buf_aht-stk-tot.sale-discnt-rubl
          .
        end.
      end.
    end.
    if p-stk-sum-type <> 'v':U
    then do:
      for each buf_aht-stk-tot exclusive-lock
        where buf_aht-stk-tot.obj-type   = buf_temp-aht-ot-tot.obj-type
          and buf_aht-stk-tot.obj-code   = buf_temp-aht-ot-tot.obj-code
          and buf_aht-stk-tot.sum-type   = p-stk-sum-type
          and buf_aht-stk-tot.fact-order >= p-fact-order
          and buf_aht-stk-tot.fact-order <= p-cut-fact-order
      :
        assign
          buf_aht-stk-tot.fact-qnty = buf_aht-stk-tot.fact-qnty + buf_temp-aht-ot-tot.fact-qnty
                                                                                          buf_aht-stk-tot.cost-sum-base       = buf_aht-stk-tot.cost-sum-base       + buf_temp-aht-ot-tot.cost-sum-base            buf_aht-stk-tot.cost-sum-rubl       = buf_aht-stk-tot.cost-sum-rubl       + buf_temp-aht-ot-tot.cost-sum-rubl            buf_aht-stk-tot.cost-vat-base       = buf_aht-stk-tot.cost-vat-base       + buf_temp-aht-ot-tot.cost-vat-base            buf_aht-stk-tot.cost-vat-rubl       = buf_aht-stk-tot.cost-vat-rubl       + buf_temp-aht-ot-tot.cost-vat-rubl            buf_aht-stk-tot.cost-slt-base       = buf_aht-stk-tot.cost-slt-base       + buf_temp-aht-ot-tot.cost-slt-base            buf_aht-stk-tot.cost-slt-rubl       = buf_aht-stk-tot.cost-slt-rubl       + buf_temp-aht-ot-tot.cost-slt-rubl            buf_aht-stk-tot.cost-road-tax-base  = buf_aht-stk-tot.cost-road-tax-base  + buf_temp-aht-ot-tot.cost-road-tax-base       buf_aht-stk-tot.cost-road-tax-rubl  = buf_aht-stk-tot.cost-road-tax-rubl  + buf_temp-aht-ot-tot.cost-road-tax-rubl       buf_aht-stk-tot.cost-excise-base    = buf_aht-stk-tot.cost-excise-base    + buf_temp-aht-ot-tot.cost-excise-base         buf_aht-stk-tot.cost-excise-rubl    = buf_aht-stk-tot.cost-excise-rubl    + buf_temp-aht-ot-tot.cost-excise-rubl         buf_aht-stk-tot.cost-transport-base = buf_aht-stk-tot.cost-transport-base + buf_temp-aht-ot-tot.cost-transport-base      buf_aht-stk-tot.cost-transport-rubl = buf_aht-stk-tot.cost-transport-rubl + buf_temp-aht-ot-tot.cost-transport-rubl      buf_aht-stk-tot.cost-other-base     = buf_aht-stk-tot.cost-other-base     + buf_temp-aht-ot-tot.cost-other-base          buf_aht-stk-tot.cost-other-rubl     = buf_aht-stk-tot.cost-other-rubl     + buf_temp-aht-ot-tot.cost-other-rubl          buf_aht-stk-tot.cost-discnt-base    = buf_aht-stk-tot.cost-discnt-base    + buf_temp-aht-ot-tot.cost-discnt-base          buf_aht-stk-tot.cost-discnt-rubl    = buf_aht-stk-tot.cost-discnt-rubl    + buf_temp-aht-ot-tot.cost-discnt-rubl
                                                                                          buf_aht-stk-tot.crsa-sum-base       = buf_aht-stk-tot.crsa-sum-base       + buf_temp-aht-ot-tot.crsa-sum-base            buf_aht-stk-tot.crsa-sum-rubl       = buf_aht-stk-tot.crsa-sum-rubl       + buf_temp-aht-ot-tot.crsa-sum-rubl            buf_aht-stk-tot.crsa-vat-base       = buf_aht-stk-tot.crsa-vat-base       + buf_temp-aht-ot-tot.crsa-vat-base            buf_aht-stk-tot.crsa-vat-rubl       = buf_aht-stk-tot.crsa-vat-rubl       + buf_temp-aht-ot-tot.crsa-vat-rubl            buf_aht-stk-tot.crsa-slt-base       = buf_aht-stk-tot.crsa-slt-base       + buf_temp-aht-ot-tot.crsa-slt-base            buf_aht-stk-tot.crsa-slt-rubl       = buf_aht-stk-tot.crsa-slt-rubl       + buf_temp-aht-ot-tot.crsa-slt-rubl            buf_aht-stk-tot.crsa-road-tax-base  = buf_aht-stk-tot.crsa-road-tax-base  + buf_temp-aht-ot-tot.crsa-road-tax-base       buf_aht-stk-tot.crsa-road-tax-rubl  = buf_aht-stk-tot.crsa-road-tax-rubl  + buf_temp-aht-ot-tot.crsa-road-tax-rubl       buf_aht-stk-tot.crsa-excise-base    = buf_aht-stk-tot.crsa-excise-base    + buf_temp-aht-ot-tot.crsa-excise-base         buf_aht-stk-tot.crsa-excise-rubl    = buf_aht-stk-tot.crsa-excise-rubl    + buf_temp-aht-ot-tot.crsa-excise-rubl         buf_aht-stk-tot.crsa-transport-base = buf_aht-stk-tot.crsa-transport-base + buf_temp-aht-ot-tot.crsa-transport-base      buf_aht-stk-tot.crsa-transport-rubl = buf_aht-stk-tot.crsa-transport-rubl + buf_temp-aht-ot-tot.crsa-transport-rubl      buf_aht-stk-tot.crsa-other-base     = buf_aht-stk-tot.crsa-other-base     + buf_temp-aht-ot-tot.crsa-other-base          buf_aht-stk-tot.crsa-other-rubl     = buf_aht-stk-tot.crsa-other-rubl     + buf_temp-aht-ot-tot.crsa-other-rubl          buf_aht-stk-tot.crsa-discnt-base    = buf_aht-stk-tot.crsa-discnt-base    + buf_temp-aht-ot-tot.crsa-discnt-base          buf_aht-stk-tot.crsa-discnt-rubl    = buf_aht-stk-tot.crsa-discnt-rubl    + buf_temp-aht-ot-tot.crsa-discnt-rubl
        .
        if p-update-sale then do:
          assign
                                                                                                            buf_aht-stk-tot.sale-sum-base       = buf_aht-stk-tot.sale-sum-base       + buf_temp-aht-ot-tot.sale-sum-base            buf_aht-stk-tot.sale-sum-rubl       = buf_aht-stk-tot.sale-sum-rubl       + buf_temp-aht-ot-tot.sale-sum-rubl            buf_aht-stk-tot.sale-vat-base       = buf_aht-stk-tot.sale-vat-base       + buf_temp-aht-ot-tot.sale-vat-base            buf_aht-stk-tot.sale-vat-rubl       = buf_aht-stk-tot.sale-vat-rubl       + buf_temp-aht-ot-tot.sale-vat-rubl            buf_aht-stk-tot.sale-slt-base       = buf_aht-stk-tot.sale-slt-base       + buf_temp-aht-ot-tot.sale-slt-base            buf_aht-stk-tot.sale-slt-rubl       = buf_aht-stk-tot.sale-slt-rubl       + buf_temp-aht-ot-tot.sale-slt-rubl            buf_aht-stk-tot.sale-road-tax-base  = buf_aht-stk-tot.sale-road-tax-base  + buf_temp-aht-ot-tot.sale-road-tax-base       buf_aht-stk-tot.sale-road-tax-rubl  = buf_aht-stk-tot.sale-road-tax-rubl  + buf_temp-aht-ot-tot.sale-road-tax-rubl       buf_aht-stk-tot.sale-excise-base    = buf_aht-stk-tot.sale-excise-base    + buf_temp-aht-ot-tot.sale-excise-base         buf_aht-stk-tot.sale-excise-rubl    = buf_aht-stk-tot.sale-excise-rubl    + buf_temp-aht-ot-tot.sale-excise-rubl         buf_aht-stk-tot.sale-transport-base = buf_aht-stk-tot.sale-transport-base + buf_temp-aht-ot-tot.sale-transport-base      buf_aht-stk-tot.sale-transport-rubl = buf_aht-stk-tot.sale-transport-rubl + buf_temp-aht-ot-tot.sale-transport-rubl      buf_aht-stk-tot.sale-other-base     = buf_aht-stk-tot.sale-other-base     + buf_temp-aht-ot-tot.sale-other-base          buf_aht-stk-tot.sale-other-rubl     = buf_aht-stk-tot.sale-other-rubl     + buf_temp-aht-ot-tot.sale-other-rubl          buf_aht-stk-tot.sale-discnt-base    = buf_aht-stk-tot.sale-discnt-base    + buf_temp-aht-ot-tot.sale-discnt-base          buf_aht-stk-tot.sale-discnt-rubl    = buf_aht-stk-tot.sale-discnt-rubl    + buf_temp-aht-ot-tot.sale-discnt-rubl
          .
        end.
      end.
    end.
  end.
end procedure.
procedure aht_store-stk-line :
  define parameter buffer buf_temp-aht-ot-line for temp-aht-ot-line .
  define input  parameter p-stk-sum-type   as character no-undo .
  define input  parameter p-fact-order     like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-cut-fact-order like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-ext-doc-type   like ub.trn-doc.ext-doc-type no-undo .
  define input  parameter p-update-sale    as logical   no-undo .
  define buffer buf_aht-stk-line for ub.aht-stk-line .
  define buffer new-buf_aht-stk-line for ub.aht-stk-line .
  do
  on error undo, return error return-value
  :
    find last buf_aht-stk-line exclusive-lock
      where buf_aht-stk-line.obj-type   = buf_temp-aht-ot-line.obj-type
        and buf_aht-stk-line.obj-code   = buf_temp-aht-ot-line.obj-code
        and buf_aht-stk-line.gds-code   = buf_temp-aht-ot-line.gds-code
        and buf_aht-stk-line.sum-type   = p-stk-sum-type
        and buf_aht-stk-line.fact-order <= p-fact-order
      use-index category
      no-error .
    if not available buf_aht-stk-line
    or buf_aht-stk-line.fact-order <> p-fact-order
    then do:
      create new-buf_aht-stk-line .
      assign
        new-buf_aht-stk-line.obj-type   = buf_temp-aht-ot-line.obj-type
        new-buf_aht-stk-line.obj-code   = buf_temp-aht-ot-line.obj-code
        new-buf_aht-stk-line.gds-code   = buf_temp-aht-ot-line.gds-code
        new-buf_aht-stk-line.fact-order = p-fact-order
        new-buf_aht-stk-line.sum-type   = p-stk-sum-type
      .
      if available buf_aht-stk-line then do:
        assign
          new-buf_aht-stk-line.fact-qnty = buf_aht-stk-line.fact-qnty
                                                                      new-buf_aht-stk-line.cost-sum-base       = buf_aht-stk-line.cost-sum-base             new-buf_aht-stk-line.cost-sum-rubl       = buf_aht-stk-line.cost-sum-rubl             new-buf_aht-stk-line.cost-vat-base       = buf_aht-stk-line.cost-vat-base             new-buf_aht-stk-line.cost-vat-rubl       = buf_aht-stk-line.cost-vat-rubl             new-buf_aht-stk-line.cost-slt-base       = buf_aht-stk-line.cost-slt-base             new-buf_aht-stk-line.cost-slt-rubl       = buf_aht-stk-line.cost-slt-rubl             new-buf_aht-stk-line.cost-road-tax-base  = buf_aht-stk-line.cost-road-tax-base        new-buf_aht-stk-line.cost-road-tax-rubl  = buf_aht-stk-line.cost-road-tax-rubl        new-buf_aht-stk-line.cost-excise-base    = buf_aht-stk-line.cost-excise-base          new-buf_aht-stk-line.cost-excise-rubl    = buf_aht-stk-line.cost-excise-rubl          new-buf_aht-stk-line.cost-transport-base = buf_aht-stk-line.cost-transport-base       new-buf_aht-stk-line.cost-transport-rubl = buf_aht-stk-line.cost-transport-rubl       new-buf_aht-stk-line.cost-other-base     = buf_aht-stk-line.cost-other-base           new-buf_aht-stk-line.cost-other-rubl     = buf_aht-stk-line.cost-other-rubl           new-buf_aht-stk-line.cost-discnt-base    = buf_aht-stk-line.cost-discnt-base          new-buf_aht-stk-line.cost-discnt-rubl    = buf_aht-stk-line.cost-discnt-rubl
                                                                      new-buf_aht-stk-line.crsa-sum-base       = buf_aht-stk-line.crsa-sum-base             new-buf_aht-stk-line.crsa-sum-rubl       = buf_aht-stk-line.crsa-sum-rubl             new-buf_aht-stk-line.crsa-vat-base       = buf_aht-stk-line.crsa-vat-base             new-buf_aht-stk-line.crsa-vat-rubl       = buf_aht-stk-line.crsa-vat-rubl             new-buf_aht-stk-line.crsa-slt-base       = buf_aht-stk-line.crsa-slt-base             new-buf_aht-stk-line.crsa-slt-rubl       = buf_aht-stk-line.crsa-slt-rubl             new-buf_aht-stk-line.crsa-road-tax-base  = buf_aht-stk-line.crsa-road-tax-base        new-buf_aht-stk-line.crsa-road-tax-rubl  = buf_aht-stk-line.crsa-road-tax-rubl        new-buf_aht-stk-line.crsa-excise-base    = buf_aht-stk-line.crsa-excise-base          new-buf_aht-stk-line.crsa-excise-rubl    = buf_aht-stk-line.crsa-excise-rubl          new-buf_aht-stk-line.crsa-transport-base = buf_aht-stk-line.crsa-transport-base       new-buf_aht-stk-line.crsa-transport-rubl = buf_aht-stk-line.crsa-transport-rubl       new-buf_aht-stk-line.crsa-other-base     = buf_aht-stk-line.crsa-other-base           new-buf_aht-stk-line.crsa-other-rubl     = buf_aht-stk-line.crsa-other-rubl           new-buf_aht-stk-line.crsa-discnt-base    = buf_aht-stk-line.crsa-discnt-base          new-buf_aht-stk-line.crsa-discnt-rubl    = buf_aht-stk-line.crsa-discnt-rubl
        .
        if p-update-sale then do:
          assign
                                                                                    new-buf_aht-stk-line.sale-sum-base       = buf_aht-stk-line.sale-sum-base             new-buf_aht-stk-line.sale-sum-rubl       = buf_aht-stk-line.sale-sum-rubl             new-buf_aht-stk-line.sale-vat-base       = buf_aht-stk-line.sale-vat-base             new-buf_aht-stk-line.sale-vat-rubl       = buf_aht-stk-line.sale-vat-rubl             new-buf_aht-stk-line.sale-slt-base       = buf_aht-stk-line.sale-slt-base             new-buf_aht-stk-line.sale-slt-rubl       = buf_aht-stk-line.sale-slt-rubl             new-buf_aht-stk-line.sale-road-tax-base  = buf_aht-stk-line.sale-road-tax-base        new-buf_aht-stk-line.sale-road-tax-rubl  = buf_aht-stk-line.sale-road-tax-rubl        new-buf_aht-stk-line.sale-excise-base    = buf_aht-stk-line.sale-excise-base          new-buf_aht-stk-line.sale-excise-rubl    = buf_aht-stk-line.sale-excise-rubl          new-buf_aht-stk-line.sale-transport-base = buf_aht-stk-line.sale-transport-base       new-buf_aht-stk-line.sale-transport-rubl = buf_aht-stk-line.sale-transport-rubl       new-buf_aht-stk-line.sale-other-base     = buf_aht-stk-line.sale-other-base           new-buf_aht-stk-line.sale-other-rubl     = buf_aht-stk-line.sale-other-rubl           new-buf_aht-stk-line.sale-discnt-base    = buf_aht-stk-line.sale-discnt-base          new-buf_aht-stk-line.sale-discnt-rubl    = buf_aht-stk-line.sale-discnt-rubl
          .
        end.
      end.
    end.
    if p-stk-sum-type <> 'v':U
    then do:
      for each buf_aht-stk-line exclusive-lock
        where buf_aht-stk-line.obj-type   = buf_temp-aht-ot-line.obj-type
          and buf_aht-stk-line.obj-code   = buf_temp-aht-ot-line.obj-code
          and buf_aht-stk-line.gds-code   = buf_temp-aht-ot-line.gds-code
          and buf_aht-stk-line.sum-type   = p-stk-sum-type
          and buf_aht-stk-line.fact-order >= p-fact-order
          and buf_aht-stk-line.fact-order <= p-cut-fact-order
      :
        assign
          buf_aht-stk-line.fact-qnty = buf_aht-stk-line.fact-qnty + buf_temp-aht-ot-line.fact-qnty
                                                                                          buf_aht-stk-line.cost-sum-base       = buf_aht-stk-line.cost-sum-base       + buf_temp-aht-ot-line.cost-sum-base            buf_aht-stk-line.cost-sum-rubl       = buf_aht-stk-line.cost-sum-rubl       + buf_temp-aht-ot-line.cost-sum-rubl            buf_aht-stk-line.cost-vat-base       = buf_aht-stk-line.cost-vat-base       + buf_temp-aht-ot-line.cost-vat-base            buf_aht-stk-line.cost-vat-rubl       = buf_aht-stk-line.cost-vat-rubl       + buf_temp-aht-ot-line.cost-vat-rubl            buf_aht-stk-line.cost-slt-base       = buf_aht-stk-line.cost-slt-base       + buf_temp-aht-ot-line.cost-slt-base            buf_aht-stk-line.cost-slt-rubl       = buf_aht-stk-line.cost-slt-rubl       + buf_temp-aht-ot-line.cost-slt-rubl            buf_aht-stk-line.cost-road-tax-base  = buf_aht-stk-line.cost-road-tax-base  + buf_temp-aht-ot-line.cost-road-tax-base       buf_aht-stk-line.cost-road-tax-rubl  = buf_aht-stk-line.cost-road-tax-rubl  + buf_temp-aht-ot-line.cost-road-tax-rubl       buf_aht-stk-line.cost-excise-base    = buf_aht-stk-line.cost-excise-base    + buf_temp-aht-ot-line.cost-excise-base         buf_aht-stk-line.cost-excise-rubl    = buf_aht-stk-line.cost-excise-rubl    + buf_temp-aht-ot-line.cost-excise-rubl         buf_aht-stk-line.cost-transport-base = buf_aht-stk-line.cost-transport-base + buf_temp-aht-ot-line.cost-transport-base      buf_aht-stk-line.cost-transport-rubl = buf_aht-stk-line.cost-transport-rubl + buf_temp-aht-ot-line.cost-transport-rubl      buf_aht-stk-line.cost-other-base     = buf_aht-stk-line.cost-other-base     + buf_temp-aht-ot-line.cost-other-base          buf_aht-stk-line.cost-other-rubl     = buf_aht-stk-line.cost-other-rubl     + buf_temp-aht-ot-line.cost-other-rubl          buf_aht-stk-line.cost-discnt-base    = buf_aht-stk-line.cost-discnt-base    + buf_temp-aht-ot-line.cost-discnt-base          buf_aht-stk-line.cost-discnt-rubl    = buf_aht-stk-line.cost-discnt-rubl    + buf_temp-aht-ot-line.cost-discnt-rubl
                                                                                          buf_aht-stk-line.crsa-sum-base       = buf_aht-stk-line.crsa-sum-base       + buf_temp-aht-ot-line.crsa-sum-base            buf_aht-stk-line.crsa-sum-rubl       = buf_aht-stk-line.crsa-sum-rubl       + buf_temp-aht-ot-line.crsa-sum-rubl            buf_aht-stk-line.crsa-vat-base       = buf_aht-stk-line.crsa-vat-base       + buf_temp-aht-ot-line.crsa-vat-base            buf_aht-stk-line.crsa-vat-rubl       = buf_aht-stk-line.crsa-vat-rubl       + buf_temp-aht-ot-line.crsa-vat-rubl            buf_aht-stk-line.crsa-slt-base       = buf_aht-stk-line.crsa-slt-base       + buf_temp-aht-ot-line.crsa-slt-base            buf_aht-stk-line.crsa-slt-rubl       = buf_aht-stk-line.crsa-slt-rubl       + buf_temp-aht-ot-line.crsa-slt-rubl            buf_aht-stk-line.crsa-road-tax-base  = buf_aht-stk-line.crsa-road-tax-base  + buf_temp-aht-ot-line.crsa-road-tax-base       buf_aht-stk-line.crsa-road-tax-rubl  = buf_aht-stk-line.crsa-road-tax-rubl  + buf_temp-aht-ot-line.crsa-road-tax-rubl       buf_aht-stk-line.crsa-excise-base    = buf_aht-stk-line.crsa-excise-base    + buf_temp-aht-ot-line.crsa-excise-base         buf_aht-stk-line.crsa-excise-rubl    = buf_aht-stk-line.crsa-excise-rubl    + buf_temp-aht-ot-line.crsa-excise-rubl         buf_aht-stk-line.crsa-transport-base = buf_aht-stk-line.crsa-transport-base + buf_temp-aht-ot-line.crsa-transport-base      buf_aht-stk-line.crsa-transport-rubl = buf_aht-stk-line.crsa-transport-rubl + buf_temp-aht-ot-line.crsa-transport-rubl      buf_aht-stk-line.crsa-other-base     = buf_aht-stk-line.crsa-other-base     + buf_temp-aht-ot-line.crsa-other-base          buf_aht-stk-line.crsa-other-rubl     = buf_aht-stk-line.crsa-other-rubl     + buf_temp-aht-ot-line.crsa-other-rubl          buf_aht-stk-line.crsa-discnt-base    = buf_aht-stk-line.crsa-discnt-base    + buf_temp-aht-ot-line.crsa-discnt-base          buf_aht-stk-line.crsa-discnt-rubl    = buf_aht-stk-line.crsa-discnt-rubl    + buf_temp-aht-ot-line.crsa-discnt-rubl
        .
        if p-update-sale then do:
          assign
                                                                                                            buf_aht-stk-line.sale-sum-base       = buf_aht-stk-line.sale-sum-base       + buf_temp-aht-ot-line.sale-sum-base            buf_aht-stk-line.sale-sum-rubl       = buf_aht-stk-line.sale-sum-rubl       + buf_temp-aht-ot-line.sale-sum-rubl            buf_aht-stk-line.sale-vat-base       = buf_aht-stk-line.sale-vat-base       + buf_temp-aht-ot-line.sale-vat-base            buf_aht-stk-line.sale-vat-rubl       = buf_aht-stk-line.sale-vat-rubl       + buf_temp-aht-ot-line.sale-vat-rubl            buf_aht-stk-line.sale-slt-base       = buf_aht-stk-line.sale-slt-base       + buf_temp-aht-ot-line.sale-slt-base            buf_aht-stk-line.sale-slt-rubl       = buf_aht-stk-line.sale-slt-rubl       + buf_temp-aht-ot-line.sale-slt-rubl            buf_aht-stk-line.sale-road-tax-base  = buf_aht-stk-line.sale-road-tax-base  + buf_temp-aht-ot-line.sale-road-tax-base       buf_aht-stk-line.sale-road-tax-rubl  = buf_aht-stk-line.sale-road-tax-rubl  + buf_temp-aht-ot-line.sale-road-tax-rubl       buf_aht-stk-line.sale-excise-base    = buf_aht-stk-line.sale-excise-base    + buf_temp-aht-ot-line.sale-excise-base         buf_aht-stk-line.sale-excise-rubl    = buf_aht-stk-line.sale-excise-rubl    + buf_temp-aht-ot-line.sale-excise-rubl         buf_aht-stk-line.sale-transport-base = buf_aht-stk-line.sale-transport-base + buf_temp-aht-ot-line.sale-transport-base      buf_aht-stk-line.sale-transport-rubl = buf_aht-stk-line.sale-transport-rubl + buf_temp-aht-ot-line.sale-transport-rubl      buf_aht-stk-line.sale-other-base     = buf_aht-stk-line.sale-other-base     + buf_temp-aht-ot-line.sale-other-base          buf_aht-stk-line.sale-other-rubl     = buf_aht-stk-line.sale-other-rubl     + buf_temp-aht-ot-line.sale-other-rubl          buf_aht-stk-line.sale-discnt-base    = buf_aht-stk-line.sale-discnt-base    + buf_temp-aht-ot-line.sale-discnt-base          buf_aht-stk-line.sale-discnt-rubl    = buf_aht-stk-line.sale-discnt-rubl    + buf_temp-aht-ot-line.sale-discnt-rubl
          .
        end.
      end.
    end.
  end.
end procedure.
procedure aht_store-ot-table :
  define buffer buf_temp-aht-ot-tot for temp-aht-ot-tot .
  define buffer buf_aht-ot-tot for ub.aht-ot-tot .
  define buffer buf_temp-aht-ot-line for temp-aht-ot-line .
  define buffer buf_aht-ot-line for ub.aht-ot-line .
  define buffer buf_temp-aht-stk-tot for temp-aht-stk-tot .
  define buffer buf_aht-stk-tot for ub.aht-stk-tot .
  define buffer buf_temp-aht-stk-line for temp-aht-stk-line .
  define buffer buf_aht-stk-line for ub.aht-stk-line .
  do
  on error undo, return error
  :
    for each buf_temp-aht-ot-tot
    on error undo, return error
    :
      if
                              buf_temp-aht-ot-tot.cost-sum-base       = ? or    buf_temp-aht-ot-tot.cost-sum-rubl       = ? or    buf_temp-aht-ot-tot.cost-vat-base       = ? or    buf_temp-aht-ot-tot.cost-vat-rubl       = ? or    buf_temp-aht-ot-tot.cost-slt-base       = ? or    buf_temp-aht-ot-tot.cost-slt-rubl       = ? or    buf_temp-aht-ot-tot.cost-road-tax-base  = ? or    buf_temp-aht-ot-tot.cost-road-tax-rubl  = ? or    buf_temp-aht-ot-tot.cost-excise-base    = ? or    buf_temp-aht-ot-tot.cost-excise-rubl    = ? or    buf_temp-aht-ot-tot.cost-transport-base = ? or    buf_temp-aht-ot-tot.cost-transport-rubl = ? or    buf_temp-aht-ot-tot.cost-other-base     = ? or    buf_temp-aht-ot-tot.cost-other-rubl     = ? or    buf_temp-aht-ot-tot.cost-discnt-base    = ? or    buf_temp-aht-ot-tot.cost-discnt-rubl    = ?
      or
                              buf_temp-aht-ot-tot.crsa-sum-base       = ? or    buf_temp-aht-ot-tot.crsa-sum-rubl       = ? or    buf_temp-aht-ot-tot.crsa-vat-base       = ? or    buf_temp-aht-ot-tot.crsa-vat-rubl       = ? or    buf_temp-aht-ot-tot.crsa-slt-base       = ? or    buf_temp-aht-ot-tot.crsa-slt-rubl       = ? or    buf_temp-aht-ot-tot.crsa-road-tax-base  = ? or    buf_temp-aht-ot-tot.crsa-road-tax-rubl  = ? or    buf_temp-aht-ot-tot.crsa-excise-base    = ? or    buf_temp-aht-ot-tot.crsa-excise-rubl    = ? or    buf_temp-aht-ot-tot.crsa-transport-base = ? or    buf_temp-aht-ot-tot.crsa-transport-rubl = ? or    buf_temp-aht-ot-tot.crsa-other-base     = ? or    buf_temp-aht-ot-tot.crsa-other-rubl     = ? or    buf_temp-aht-ot-tot.crsa-discnt-base    = ? or    buf_temp-aht-ot-tot.crsa-discnt-rubl    = ?
      or
                              buf_temp-aht-ot-tot.sale-sum-base       = ? or    buf_temp-aht-ot-tot.sale-sum-rubl       = ? or    buf_temp-aht-ot-tot.sale-vat-base       = ? or    buf_temp-aht-ot-tot.sale-vat-rubl       = ? or    buf_temp-aht-ot-tot.sale-slt-base       = ? or    buf_temp-aht-ot-tot.sale-slt-rubl       = ? or    buf_temp-aht-ot-tot.sale-road-tax-base  = ? or    buf_temp-aht-ot-tot.sale-road-tax-rubl  = ? or    buf_temp-aht-ot-tot.sale-excise-base    = ? or    buf_temp-aht-ot-tot.sale-excise-rubl    = ? or    buf_temp-aht-ot-tot.sale-transport-base = ? or    buf_temp-aht-ot-tot.sale-transport-rubl = ? or    buf_temp-aht-ot-tot.sale-other-base     = ? or    buf_temp-aht-ot-tot.sale-other-rubl     = ? or    buf_temp-aht-ot-tot.sale-discnt-base    = ? or    buf_temp-aht-ot-tot.sale-discnt-rubl    = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info8 skip
          "При расчета складского архива по типам приобретения получено неопределенное значение" skip
          "Документ" buf_temp-aht-ot-tot.doc-code skip
          "Тип суммы" buf_temp-aht-ot-tot.sum-type skip
          view-as alert-box error .
        output stream ahtlog to ahtlog.txt append .
        export stream ahtlog
          vss-include-info8 buf_temp-aht-ot-tot.doc-code .
                                                        export stream ahtlog "temp-aht-ot-tot.cost-sum-base"       buf_temp-aht-ot-tot.cost-sum-base        .     export stream ahtlog "temp-aht-ot-tot.cost-sum-rubl"       buf_temp-aht-ot-tot.cost-sum-rubl        .     export stream ahtlog "temp-aht-ot-tot.cost-vat-base"       buf_temp-aht-ot-tot.cost-vat-base        .     export stream ahtlog "temp-aht-ot-tot.cost-vat-rubl"       buf_temp-aht-ot-tot.cost-vat-rubl        .     export stream ahtlog "temp-aht-ot-tot.cost-slt-base"       buf_temp-aht-ot-tot.cost-slt-base        .     export stream ahtlog "temp-aht-ot-tot.cost-slt-rubl"       buf_temp-aht-ot-tot.cost-slt-rubl        .     export stream ahtlog "temp-aht-ot-tot.cost-road-tax-base"  buf_temp-aht-ot-tot.cost-road-tax-base   .     export stream ahtlog "temp-aht-ot-tot.cost-road-tax-rubl"  buf_temp-aht-ot-tot.cost-road-tax-rubl   .     export stream ahtlog "temp-aht-ot-tot.cost-excise-base"    buf_temp-aht-ot-tot.cost-excise-base     .     export stream ahtlog "temp-aht-ot-tot.cost-excise-rubl"    buf_temp-aht-ot-tot.cost-excise-rubl     .     export stream ahtlog "temp-aht-ot-tot.cost-transport-base" buf_temp-aht-ot-tot.cost-transport-base  .     export stream ahtlog "temp-aht-ot-tot.cost-transport-rubl" buf_temp-aht-ot-tot.cost-transport-rubl  .     export stream ahtlog "temp-aht-ot-tot.cost-other-base"     buf_temp-aht-ot-tot.cost-other-base      .     export stream ahtlog "temp-aht-ot-tot.cost-other-rubl"     buf_temp-aht-ot-tot.cost-other-rubl      .     export stream ahtlog "temp-aht-ot-tot.cost-discnt-base"    buf_temp-aht-ot-tot.cost-discnt-base     .     export stream ahtlog "temp-aht-ot-tot.cost-discnt-rubl"    buf_temp-aht-ot-tot.cost-discnt-rubl     .
                                                        export stream ahtlog "temp-aht-ot-tot.crsa-sum-base"       buf_temp-aht-ot-tot.crsa-sum-base        .     export stream ahtlog "temp-aht-ot-tot.crsa-sum-rubl"       buf_temp-aht-ot-tot.crsa-sum-rubl        .     export stream ahtlog "temp-aht-ot-tot.crsa-vat-base"       buf_temp-aht-ot-tot.crsa-vat-base        .     export stream ahtlog "temp-aht-ot-tot.crsa-vat-rubl"       buf_temp-aht-ot-tot.crsa-vat-rubl        .     export stream ahtlog "temp-aht-ot-tot.crsa-slt-base"       buf_temp-aht-ot-tot.crsa-slt-base        .     export stream ahtlog "temp-aht-ot-tot.crsa-slt-rubl"       buf_temp-aht-ot-tot.crsa-slt-rubl        .     export stream ahtlog "temp-aht-ot-tot.crsa-road-tax-base"  buf_temp-aht-ot-tot.crsa-road-tax-base   .     export stream ahtlog "temp-aht-ot-tot.crsa-road-tax-rubl"  buf_temp-aht-ot-tot.crsa-road-tax-rubl   .     export stream ahtlog "temp-aht-ot-tot.crsa-excise-base"    buf_temp-aht-ot-tot.crsa-excise-base     .     export stream ahtlog "temp-aht-ot-tot.crsa-excise-rubl"    buf_temp-aht-ot-tot.crsa-excise-rubl     .     export stream ahtlog "temp-aht-ot-tot.crsa-transport-base" buf_temp-aht-ot-tot.crsa-transport-base  .     export stream ahtlog "temp-aht-ot-tot.crsa-transport-rubl" buf_temp-aht-ot-tot.crsa-transport-rubl  .     export stream ahtlog "temp-aht-ot-tot.crsa-other-base"     buf_temp-aht-ot-tot.crsa-other-base      .     export stream ahtlog "temp-aht-ot-tot.crsa-other-rubl"     buf_temp-aht-ot-tot.crsa-other-rubl      .     export stream ahtlog "temp-aht-ot-tot.crsa-discnt-base"    buf_temp-aht-ot-tot.crsa-discnt-base     .     export stream ahtlog "temp-aht-ot-tot.crsa-discnt-rubl"    buf_temp-aht-ot-tot.crsa-discnt-rubl     .
                                                        export stream ahtlog "temp-aht-ot-tot.sale-sum-base"       buf_temp-aht-ot-tot.sale-sum-base        .     export stream ahtlog "temp-aht-ot-tot.sale-sum-rubl"       buf_temp-aht-ot-tot.sale-sum-rubl        .     export stream ahtlog "temp-aht-ot-tot.sale-vat-base"       buf_temp-aht-ot-tot.sale-vat-base        .     export stream ahtlog "temp-aht-ot-tot.sale-vat-rubl"       buf_temp-aht-ot-tot.sale-vat-rubl        .     export stream ahtlog "temp-aht-ot-tot.sale-slt-base"       buf_temp-aht-ot-tot.sale-slt-base        .     export stream ahtlog "temp-aht-ot-tot.sale-slt-rubl"       buf_temp-aht-ot-tot.sale-slt-rubl        .     export stream ahtlog "temp-aht-ot-tot.sale-road-tax-base"  buf_temp-aht-ot-tot.sale-road-tax-base   .     export stream ahtlog "temp-aht-ot-tot.sale-road-tax-rubl"  buf_temp-aht-ot-tot.sale-road-tax-rubl   .     export stream ahtlog "temp-aht-ot-tot.sale-excise-base"    buf_temp-aht-ot-tot.sale-excise-base     .     export stream ahtlog "temp-aht-ot-tot.sale-excise-rubl"    buf_temp-aht-ot-tot.sale-excise-rubl     .     export stream ahtlog "temp-aht-ot-tot.sale-transport-base" buf_temp-aht-ot-tot.sale-transport-base  .     export stream ahtlog "temp-aht-ot-tot.sale-transport-rubl" buf_temp-aht-ot-tot.sale-transport-rubl  .     export stream ahtlog "temp-aht-ot-tot.sale-other-base"     buf_temp-aht-ot-tot.sale-other-base      .     export stream ahtlog "temp-aht-ot-tot.sale-other-rubl"     buf_temp-aht-ot-tot.sale-other-rubl      .     export stream ahtlog "temp-aht-ot-tot.sale-discnt-base"    buf_temp-aht-ot-tot.sale-discnt-base     .     export stream ahtlog "temp-aht-ot-tot.sale-discnt-rubl"    buf_temp-aht-ot-tot.sale-discnt-rubl     .
        output stream ahtlog close .
        undo, return error .
      end.
      find first buf_aht-ot-tot exclusive-lock
        where buf_aht-ot-tot.doc-code = buf_temp-aht-ot-tot.doc-code
          and buf_aht-ot-tot.sum-type = buf_temp-aht-ot-tot.sum-type
        no-error .
      if not available buf_aht-ot-tot then do:
        create buf_aht-ot-tot .
      end.
                  assign
        buf_aht-ot-tot.doc-code     = buf_temp-aht-ot-tot.doc-code       buf_aht-ot-tot.sum-type     = buf_temp-aht-ot-tot.sum-type       buf_aht-ot-tot.ext-doc-type = buf_temp-aht-ot-tot.ext-doc-type   buf_aht-ot-tot.obj-type     = buf_temp-aht-ot-tot.obj-type       buf_aht-ot-tot.obj-code     = buf_temp-aht-ot-tot.obj-code       buf_aht-ot-tot.fact-order   = buf_temp-aht-ot-tot.fact-order
      .
      assign
        buf_aht-ot-tot.fact-qnty = buf_temp-aht-ot-tot.fact-qnty
                                                        buf_aht-ot-tot.cost-sum-base       = buf_temp-aht-ot-tot.cost-sum-base             buf_aht-ot-tot.cost-sum-rubl       = buf_temp-aht-ot-tot.cost-sum-rubl             buf_aht-ot-tot.cost-vat-base       = buf_temp-aht-ot-tot.cost-vat-base             buf_aht-ot-tot.cost-vat-rubl       = buf_temp-aht-ot-tot.cost-vat-rubl             buf_aht-ot-tot.cost-slt-base       = buf_temp-aht-ot-tot.cost-slt-base             buf_aht-ot-tot.cost-slt-rubl       = buf_temp-aht-ot-tot.cost-slt-rubl             buf_aht-ot-tot.cost-road-tax-base  = buf_temp-aht-ot-tot.cost-road-tax-base        buf_aht-ot-tot.cost-road-tax-rubl  = buf_temp-aht-ot-tot.cost-road-tax-rubl        buf_aht-ot-tot.cost-excise-base    = buf_temp-aht-ot-tot.cost-excise-base          buf_aht-ot-tot.cost-excise-rubl    = buf_temp-aht-ot-tot.cost-excise-rubl          buf_aht-ot-tot.cost-transport-base = buf_temp-aht-ot-tot.cost-transport-base       buf_aht-ot-tot.cost-transport-rubl = buf_temp-aht-ot-tot.cost-transport-rubl       buf_aht-ot-tot.cost-other-base     = buf_temp-aht-ot-tot.cost-other-base           buf_aht-ot-tot.cost-other-rubl     = buf_temp-aht-ot-tot.cost-other-rubl           buf_aht-ot-tot.cost-discnt-base    = buf_temp-aht-ot-tot.cost-discnt-base          buf_aht-ot-tot.cost-discnt-rubl    = buf_temp-aht-ot-tot.cost-discnt-rubl
                                                        buf_aht-ot-tot.crsa-sum-base       = buf_temp-aht-ot-tot.crsa-sum-base             buf_aht-ot-tot.crsa-sum-rubl       = buf_temp-aht-ot-tot.crsa-sum-rubl             buf_aht-ot-tot.crsa-vat-base       = buf_temp-aht-ot-tot.crsa-vat-base             buf_aht-ot-tot.crsa-vat-rubl       = buf_temp-aht-ot-tot.crsa-vat-rubl             buf_aht-ot-tot.crsa-slt-base       = buf_temp-aht-ot-tot.crsa-slt-base             buf_aht-ot-tot.crsa-slt-rubl       = buf_temp-aht-ot-tot.crsa-slt-rubl             buf_aht-ot-tot.crsa-road-tax-base  = buf_temp-aht-ot-tot.crsa-road-tax-base        buf_aht-ot-tot.crsa-road-tax-rubl  = buf_temp-aht-ot-tot.crsa-road-tax-rubl        buf_aht-ot-tot.crsa-excise-base    = buf_temp-aht-ot-tot.crsa-excise-base          buf_aht-ot-tot.crsa-excise-rubl    = buf_temp-aht-ot-tot.crsa-excise-rubl          buf_aht-ot-tot.crsa-transport-base = buf_temp-aht-ot-tot.crsa-transport-base       buf_aht-ot-tot.crsa-transport-rubl = buf_temp-aht-ot-tot.crsa-transport-rubl       buf_aht-ot-tot.crsa-other-base     = buf_temp-aht-ot-tot.crsa-other-base           buf_aht-ot-tot.crsa-other-rubl     = buf_temp-aht-ot-tot.crsa-other-rubl           buf_aht-ot-tot.crsa-discnt-base    = buf_temp-aht-ot-tot.crsa-discnt-base          buf_aht-ot-tot.crsa-discnt-rubl    = buf_temp-aht-ot-tot.crsa-discnt-rubl
                                                        buf_aht-ot-tot.sale-sum-base       = buf_temp-aht-ot-tot.sale-sum-base             buf_aht-ot-tot.sale-sum-rubl       = buf_temp-aht-ot-tot.sale-sum-rubl             buf_aht-ot-tot.sale-vat-base       = buf_temp-aht-ot-tot.sale-vat-base             buf_aht-ot-tot.sale-vat-rubl       = buf_temp-aht-ot-tot.sale-vat-rubl             buf_aht-ot-tot.sale-slt-base       = buf_temp-aht-ot-tot.sale-slt-base             buf_aht-ot-tot.sale-slt-rubl       = buf_temp-aht-ot-tot.sale-slt-rubl             buf_aht-ot-tot.sale-road-tax-base  = buf_temp-aht-ot-tot.sale-road-tax-base        buf_aht-ot-tot.sale-road-tax-rubl  = buf_temp-aht-ot-tot.sale-road-tax-rubl        buf_aht-ot-tot.sale-excise-base    = buf_temp-aht-ot-tot.sale-excise-base          buf_aht-ot-tot.sale-excise-rubl    = buf_temp-aht-ot-tot.sale-excise-rubl          buf_aht-ot-tot.sale-transport-base = buf_temp-aht-ot-tot.sale-transport-base       buf_aht-ot-tot.sale-transport-rubl = buf_temp-aht-ot-tot.sale-transport-rubl       buf_aht-ot-tot.sale-other-base     = buf_temp-aht-ot-tot.sale-other-base           buf_aht-ot-tot.sale-other-rubl     = buf_temp-aht-ot-tot.sale-other-rubl           buf_aht-ot-tot.sale-discnt-base    = buf_temp-aht-ot-tot.sale-discnt-base          buf_aht-ot-tot.sale-discnt-rubl    = buf_temp-aht-ot-tot.sale-discnt-rubl
      .
    end.
    for each buf_temp-aht-ot-line
    on error undo, return error
    :
      if
                              buf_temp-aht-ot-line.cost-sum-base       = ? or    buf_temp-aht-ot-line.cost-sum-rubl       = ? or    buf_temp-aht-ot-line.cost-vat-base       = ? or    buf_temp-aht-ot-line.cost-vat-rubl       = ? or    buf_temp-aht-ot-line.cost-slt-base       = ? or    buf_temp-aht-ot-line.cost-slt-rubl       = ? or    buf_temp-aht-ot-line.cost-road-tax-base  = ? or    buf_temp-aht-ot-line.cost-road-tax-rubl  = ? or    buf_temp-aht-ot-line.cost-excise-base    = ? or    buf_temp-aht-ot-line.cost-excise-rubl    = ? or    buf_temp-aht-ot-line.cost-transport-base = ? or    buf_temp-aht-ot-line.cost-transport-rubl = ? or    buf_temp-aht-ot-line.cost-other-base     = ? or    buf_temp-aht-ot-line.cost-other-rubl     = ? or    buf_temp-aht-ot-line.cost-discnt-base    = ? or    buf_temp-aht-ot-line.cost-discnt-rubl    = ?
      or
                              buf_temp-aht-ot-line.crsa-sum-base       = ? or    buf_temp-aht-ot-line.crsa-sum-rubl       = ? or    buf_temp-aht-ot-line.crsa-vat-base       = ? or    buf_temp-aht-ot-line.crsa-vat-rubl       = ? or    buf_temp-aht-ot-line.crsa-slt-base       = ? or    buf_temp-aht-ot-line.crsa-slt-rubl       = ? or    buf_temp-aht-ot-line.crsa-road-tax-base  = ? or    buf_temp-aht-ot-line.crsa-road-tax-rubl  = ? or    buf_temp-aht-ot-line.crsa-excise-base    = ? or    buf_temp-aht-ot-line.crsa-excise-rubl    = ? or    buf_temp-aht-ot-line.crsa-transport-base = ? or    buf_temp-aht-ot-line.crsa-transport-rubl = ? or    buf_temp-aht-ot-line.crsa-other-base     = ? or    buf_temp-aht-ot-line.crsa-other-rubl     = ? or    buf_temp-aht-ot-line.crsa-discnt-base    = ? or    buf_temp-aht-ot-line.crsa-discnt-rubl    = ?
      or
                              buf_temp-aht-ot-line.sale-sum-base       = ? or    buf_temp-aht-ot-line.sale-sum-rubl       = ? or    buf_temp-aht-ot-line.sale-vat-base       = ? or    buf_temp-aht-ot-line.sale-vat-rubl       = ? or    buf_temp-aht-ot-line.sale-slt-base       = ? or    buf_temp-aht-ot-line.sale-slt-rubl       = ? or    buf_temp-aht-ot-line.sale-road-tax-base  = ? or    buf_temp-aht-ot-line.sale-road-tax-rubl  = ? or    buf_temp-aht-ot-line.sale-excise-base    = ? or    buf_temp-aht-ot-line.sale-excise-rubl    = ? or    buf_temp-aht-ot-line.sale-transport-base = ? or    buf_temp-aht-ot-line.sale-transport-rubl = ? or    buf_temp-aht-ot-line.sale-other-base     = ? or    buf_temp-aht-ot-line.sale-other-rubl     = ? or    buf_temp-aht-ot-line.sale-discnt-base    = ? or    buf_temp-aht-ot-line.sale-discnt-rubl    = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info8 skip
          "При расчета складского архива по типам приобретения получено неопределенное значение" skip
          "Документ" buf_temp-aht-ot-line.doc-code skip
          "Код товара" buf_temp-aht-ot-line.gds-code skip
          "Тип суммы" buf_temp-aht-ot-line.sum-type skip
          view-as alert-box error .
        undo, return error .
      end.
      find first buf_aht-ot-line exclusive-lock
        where buf_aht-ot-line.doc-code  = buf_temp-aht-ot-line.doc-code
          and buf_aht-ot-line.gds-code  = buf_temp-aht-ot-line.gds-code
          and buf_aht-ot-line.sum-type  = buf_temp-aht-ot-line.sum-type
        no-error .
      if not available buf_aht-ot-line then do:
        create buf_aht-ot-line .
      end.
                  assign
        buf_aht-ot-line.doc-code     = buf_temp-aht-ot-line.doc-code       buf_aht-ot-line.gds-code     = buf_temp-aht-ot-line.gds-code       buf_aht-ot-line.sum-type     = buf_temp-aht-ot-line.sum-type       buf_aht-ot-line.ext-doc-type = buf_temp-aht-ot-line.ext-doc-type   buf_aht-ot-line.obj-type     = buf_temp-aht-ot-line.obj-type       buf_aht-ot-line.obj-code     = buf_temp-aht-ot-line.obj-code       buf_aht-ot-line.fact-order   = buf_temp-aht-ot-line.fact-order
      .
      assign
        buf_aht-ot-line.fact-qnty = buf_temp-aht-ot-line.fact-qnty
                                                        buf_aht-ot-line.cost-sum-base       = buf_temp-aht-ot-line.cost-sum-base             buf_aht-ot-line.cost-sum-rubl       = buf_temp-aht-ot-line.cost-sum-rubl             buf_aht-ot-line.cost-vat-base       = buf_temp-aht-ot-line.cost-vat-base             buf_aht-ot-line.cost-vat-rubl       = buf_temp-aht-ot-line.cost-vat-rubl             buf_aht-ot-line.cost-slt-base       = buf_temp-aht-ot-line.cost-slt-base             buf_aht-ot-line.cost-slt-rubl       = buf_temp-aht-ot-line.cost-slt-rubl             buf_aht-ot-line.cost-road-tax-base  = buf_temp-aht-ot-line.cost-road-tax-base        buf_aht-ot-line.cost-road-tax-rubl  = buf_temp-aht-ot-line.cost-road-tax-rubl        buf_aht-ot-line.cost-excise-base    = buf_temp-aht-ot-line.cost-excise-base          buf_aht-ot-line.cost-excise-rubl    = buf_temp-aht-ot-line.cost-excise-rubl          buf_aht-ot-line.cost-transport-base = buf_temp-aht-ot-line.cost-transport-base       buf_aht-ot-line.cost-transport-rubl = buf_temp-aht-ot-line.cost-transport-rubl       buf_aht-ot-line.cost-other-base     = buf_temp-aht-ot-line.cost-other-base           buf_aht-ot-line.cost-other-rubl     = buf_temp-aht-ot-line.cost-other-rubl           buf_aht-ot-line.cost-discnt-base    = buf_temp-aht-ot-line.cost-discnt-base          buf_aht-ot-line.cost-discnt-rubl    = buf_temp-aht-ot-line.cost-discnt-rubl
                                                        buf_aht-ot-line.crsa-sum-base       = buf_temp-aht-ot-line.crsa-sum-base             buf_aht-ot-line.crsa-sum-rubl       = buf_temp-aht-ot-line.crsa-sum-rubl             buf_aht-ot-line.crsa-vat-base       = buf_temp-aht-ot-line.crsa-vat-base             buf_aht-ot-line.crsa-vat-rubl       = buf_temp-aht-ot-line.crsa-vat-rubl             buf_aht-ot-line.crsa-slt-base       = buf_temp-aht-ot-line.crsa-slt-base             buf_aht-ot-line.crsa-slt-rubl       = buf_temp-aht-ot-line.crsa-slt-rubl             buf_aht-ot-line.crsa-road-tax-base  = buf_temp-aht-ot-line.crsa-road-tax-base        buf_aht-ot-line.crsa-road-tax-rubl  = buf_temp-aht-ot-line.crsa-road-tax-rubl        buf_aht-ot-line.crsa-excise-base    = buf_temp-aht-ot-line.crsa-excise-base          buf_aht-ot-line.crsa-excise-rubl    = buf_temp-aht-ot-line.crsa-excise-rubl          buf_aht-ot-line.crsa-transport-base = buf_temp-aht-ot-line.crsa-transport-base       buf_aht-ot-line.crsa-transport-rubl = buf_temp-aht-ot-line.crsa-transport-rubl       buf_aht-ot-line.crsa-other-base     = buf_temp-aht-ot-line.crsa-other-base           buf_aht-ot-line.crsa-other-rubl     = buf_temp-aht-ot-line.crsa-other-rubl           buf_aht-ot-line.crsa-discnt-base    = buf_temp-aht-ot-line.crsa-discnt-base          buf_aht-ot-line.crsa-discnt-rubl    = buf_temp-aht-ot-line.crsa-discnt-rubl
                                                        buf_aht-ot-line.sale-sum-base       = buf_temp-aht-ot-line.sale-sum-base             buf_aht-ot-line.sale-sum-rubl       = buf_temp-aht-ot-line.sale-sum-rubl             buf_aht-ot-line.sale-vat-base       = buf_temp-aht-ot-line.sale-vat-base             buf_aht-ot-line.sale-vat-rubl       = buf_temp-aht-ot-line.sale-vat-rubl             buf_aht-ot-line.sale-slt-base       = buf_temp-aht-ot-line.sale-slt-base             buf_aht-ot-line.sale-slt-rubl       = buf_temp-aht-ot-line.sale-slt-rubl             buf_aht-ot-line.sale-road-tax-base  = buf_temp-aht-ot-line.sale-road-tax-base        buf_aht-ot-line.sale-road-tax-rubl  = buf_temp-aht-ot-line.sale-road-tax-rubl        buf_aht-ot-line.sale-excise-base    = buf_temp-aht-ot-line.sale-excise-base          buf_aht-ot-line.sale-excise-rubl    = buf_temp-aht-ot-line.sale-excise-rubl          buf_aht-ot-line.sale-transport-base = buf_temp-aht-ot-line.sale-transport-base       buf_aht-ot-line.sale-transport-rubl = buf_temp-aht-ot-line.sale-transport-rubl       buf_aht-ot-line.sale-other-base     = buf_temp-aht-ot-line.sale-other-base           buf_aht-ot-line.sale-other-rubl     = buf_temp-aht-ot-line.sale-other-rubl           buf_aht-ot-line.sale-discnt-base    = buf_temp-aht-ot-line.sale-discnt-base          buf_aht-ot-line.sale-discnt-rubl    = buf_temp-aht-ot-line.sale-discnt-rubl
      .
    end.
  end.
end procedure.
procedure aht_add-document :
  define input  parameter p-doc-code     like ub.aht-doc.doc-code     no-undo .
  define input  parameter p-obj-type     like ub.aht-doc.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.aht-doc.obj-code     no-undo .
  define input  parameter p-ext-doc-type like ub.aht-doc.ext-doc-type no-undo .
  define input  parameter p-is-trn-doc   like ub.aht-doc.is-trn-doc   no-undo .
  define input  parameter p-fact-order   like ub.aht-doc.fact-order   no-undo .
  define input  parameter p-fact-date    like ub.aht-doc.fact-date    no-undo .
  define input  parameter p-shift-date   like ub.aht-doc.shift-date   no-undo .
  define input  parameter p-shift-num    like ub.aht-doc.shift-num    no-undo .
  define buffer buf_aht-doc for ub.aht-doc .
  do
  on error undo, return error return-value
  :
    find first buf_aht-doc exclusive-lock
      where buf_aht-doc.doc-code = p-doc-code
      no-error .
    if available buf_aht-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info8 skip
        "Попытка повторного создания записи" skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info8 skip
        "Ошибка задания входных параметров" skip
        "Не задан номер документа" skip
        "Документ" p-doc-code skip
        "Номер документа" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    create buf_aht-doc .
    assign
      buf_aht-doc.doc-code     = p-doc-code
      buf_aht-doc.obj-type     = p-obj-type
      buf_aht-doc.obj-code     = p-obj-code
      buf_aht-doc.ext-doc-type = p-ext-doc-type
      buf_aht-doc.is-trn-doc   = p-is-trn-doc
      buf_aht-doc.fact-order   = p-fact-order
      buf_aht-doc.fact-date    = p-fact-date
      buf_aht-doc.shift-date   = p-shift-date
      buf_aht-doc.shift-num    = p-shift-num
    .
  end.
end procedure.
procedure aht_add-date :
  define input  parameter p-obj-type     like ub.aht-stk.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.aht-stk.obj-code     no-undo .
  define input  parameter p-stk-type     like ub.aht-stk.stk-type     no-undo .
  define input  parameter p-fact-order   like ub.aht-stk.fact-order   no-undo .
  define input  parameter p-fact-date    like ub.aht-stk.fact-date    no-undo .
  define input  parameter p-shift-date   like ub.aht-stk.shift-date   no-undo .
  define input  parameter p-shift-num    like ub.aht-stk.shift-num    no-undo .
  define buffer buf_aht-stk for ub.aht-stk .
  do
  on error undo, return error return-value
  :
    find first buf_aht-stk no-lock
      where buf_aht-stk.obj-type   = p-obj-type
        and buf_aht-stk.obj-code   = p-obj-code
        and buf_aht-stk.stk-type   = p-stk-type
        and buf_aht-stk.fact-order = p-fact-order
      no-error .
    if not available buf_aht-stk then do:
      create buf_aht-stk .
      assign
        buf_aht-stk.obj-type   = p-obj-type
        buf_aht-stk.obj-code   = p-obj-code
        buf_aht-stk.stk-type   = p-stk-type
        buf_aht-stk.fact-order = p-fact-order
        buf_aht-stk.fact-date  = p-fact-date
        buf_aht-stk.shift-date = p-shift-date
        buf_aht-stk.shift-num  = p-shift-num
      .
    end.
  end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
define temp-table temp-create-aht-stk-tot no-undo
   field obj-type as character
   field obj-code as integer
   field sum-type as character
   field need-create as logical
   index xpk is primary unique obj-type obj-code sum-type
   index xie1 need-create
.
define temp-table temp-create-aht-stk-line no-undo
   field obj-type  as character
   field obj-code  as integer
   field gds-code  as integer
   field sum-type  as character
   field need-create as logical
   index xpk is primary unique obj-type obj-code gds-code sum-type
   index xie1 need-create
.
define stream slog .
define stream sinp .
define stream sout .
define buffer calc-aht-lock_batchprocess for ub.batchprocess .
define variable v-user-select         as logical   no-undo .
define variable v-obj-type            as character no-undo .
define variable v-obj-code            as integer   no-undo .
define variable v-file-name           as character no-undo .
define variable v-backup-file-name    as character no-undo .
define variable v-today               as date      no-undo .
define variable v-restore-start-date  as date      no-undo .
define variable v-restore-detail-date as date      no-undo .
define variable v-ok                  as logical   no-undo .
define variable v-line-num            as integer   no-undo .
do
on error undo, return error return-value
:
  define variable rid-list as character no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  ,output v-obj-type
  ,output v-obj-code
  )  .
  if v-user-select <> true
  then do:
    return .
  end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output v-today
  )  .
  define buffer restore-aht-lock_batchprocess for ub.batchprocess .
  run gbl/lock-prc.p
    (input 'rsat':U
    ,input v-obj-code
    ,input 0
    ,input 0
    ,input v-obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Восстановление складского архива по типам приобретения"
    ,input true
    ,buffer restore-aht-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по типам приобретения" skip
        "Объект" v-obj-type v-obj-code skip
        "В данный момент восстанавливается складской архив по типам приобретения" skip
        "Невозможно произвести восстановлением складского архива по типам приобретения" skip
        view-as alert-box error .
    end.
    undo, return error "В данный момент восстанавливается складской архив по типам приобретения" .
  end.
  run gbl/lock-prc.p
    (input 'ahtb':U
    ,input v-obj-code
    ,input 0
    ,input 0
    ,input v-obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Расчёт складского архива по типам приобретения"
    ,input true
    ,buffer calc-aht-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по типам приобретения" skip
        "Объект" v-obj-type v-obj-code skip
        "В данный момент рассчитывается складской архив по типам приобтерения" skip
        "Невозможно произвести восстановление складского архива по типам приобретения" skip
        view-as alert-box error .
    end.
    undo, return error "В данный момент рассчитывается складской архив по типам приобретения" .
  end.
  define buffer buf_lock_gdsrenart_batchprocess for ub.batchprocess .
  run gbl/lockrngd.p
    (input  'grar':U
    ,input  'disable':U
    ,buffer buf_lock_gdsrenart_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при блокировании функции переименования артикула товара" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    undo, return error return-value .
  end.
  define buffer buf_lock_gdsrengc_batchprocess for ub.batchprocess .
  run gbl/lockrngd.p
    (input  'grgc':U
    ,input  'disable':U
    ,buffer buf_lock_gdsrengc_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при блокировании функции переименования кода товара" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    undo, return error return-value .
  end.
  define variable v-attr-value as character no-undo .
  define variable v-attr-type  as character no-undo .
  define variable v-aht-calc          as logical   no-undo .
  define variable v-aht-del           as logical   no-undo .
  define variable v-aht-start-date    as date      no-undo .
  define variable v-aht-detail-date   as date      no-undo .
  define variable v-aht-recalc-date   as date      no-undo .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'aht-calc':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-aht-calc = (lookup(v-attr-value, 'yes,true') > 0)
  .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'aht-del':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-aht-del = (lookup(v-attr-value, 'yes,true') > 0)
  .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'aht-start':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-aht-start-date = date(v-attr-value)
  .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'aht-detail':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-aht-detail-date = date(v-attr-value)
  .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'aht-recalc':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-aht-recalc-date = date(v-attr-value)
  .
  if (v-aht-start-date <> ?
     and v-aht-detail-date = ?)
  or (v-aht-start-date = ?
     and v-aht-detail-date <> ?)
  then do:
    message
      "Складской архив по типам приобретения" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести восстановление складского архива по типам приобретения" skip
      "Противоречивая информация в датах инициализации складского архива" skip
      "Дата начала складского архива по типам приобретения" string(v-aht-start-date, '99/99/9999':u) skip
      "Дата начала подробного складского архива по типам приобретения" string(v-aht-detail-date, '99/99/9999':u) skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if v-aht-detail-date = ?
  then do:
    message
      "Складской архив по типам приобретения" skip
      "Объект" v-obj-type v-obj-code skip
      "На объекте рассчитан складской архив по типам приобретения за все даты" skip
      "Операция восстановления не может быть произведена" skip
      view-as alert-box information .
    return .
  end.
  define variable v-year  as integer   no-undo .
  define variable v-month as integer   no-undo .
  define variable v-day   as integer   no-undo .
  assign
    v-year  = year(v-aht-detail-date)
    v-month = month(v-aht-detail-date)
    v-day   = day(v-aht-detail-date)
  .
  assign
    v-file-name = 'ahtdel':u
                + '_':u
                + (if v-obj-type = 'скл':U then 'stock':u else 'shop':u)
                + '_':u
                + string(v-obj-code)
                + '_':u
                + string(v-year, '9999':u)
                + string(v-month, '99':u)
                + string(v-day, '99':u)
                + '.txt'
  .
  assign
    v-backup-file-name = entry(1, v-file-name, '.') + '.rst':u
  .
  define variable v-full-file-name    as character no-undo .
  define variable v-full-backup-name  as character no-undo .
  define variable v-restore-from-file as logical   no-undo .
  define variable v-restore-backup    as logical   no-undo .
  assign
    v-full-file-name = search(v-file-name)
  .
  if v-full-file-name = ?
  or v-full-file-name = ""
  then do:
    assign
      v-restore-from-file = false
    .
  end.
  else do:
    assign
      v-restore-from-file = true
    .
  end.
  assign
    v-full-backup-name = search(v-backup-file-name)
  .
  if v-full-backup-name = ?
  or v-full-backup-name = ""
  then do:
    assign
      v-restore-backup = false
    .
  end.
  else do:
    assign
      v-restore-backup = true
    .
  end.
  define variable v-num as integer   no-undo .
  run gbl/d-askw.w
    (input "Вопрос"
    ,input substitute("Объект &1 &2", v-obj-type, v-obj-code) + chr(10)
           + "Произвести восстановление подробного складского архива по типам приобретения" + chr(10)
           + "Дата начала подробного складского архива по типам приобретения " + string(v-aht-detail-date, '99/99/9999':U) + chr(10)
           + "Сегодня " + string(v-today, '99/99/9999':U) + chr(10)
    ,input '|^':u
    ,input "Из файла" + '^confirm':u + (if v-restore-from-file = true then '':u else '^disable':u)
    + '|':u + "Резервная копия" + '^confirm':u + (if v-restore-backup = true then '':u else '^disable':u)
    + '|':u + "Документы" + '^confirm':u + (if v-aht-del = true then '^disable':u else '':u)
    + '|':u + "Отказ"
    ,input (if v-restore-from-file then substitute("Восстановить из файла &1", v-full-file-name)
            else substitute("Файл с сохраненными данными &1 не найден", v-file-name ) )
        + "|":u +
           (if v-restore-from-file then substitute("Восстановить из резервной копии &1", v-backup-file-name)
            else substitute("Файл резервной копии &1 не найден", v-backup-file-name) )
        + "|":u + (if v-aht-del
                   then "Была ошибка при предыдущем Удалении/Восстановлении" + chr(10)
                        + "Архив по типам приобретения можно восстановить только из файла"
                   else "Рассчитать на основании документов"
                   )
        + "|":u + ""
    ,input 1
    ,input 4
    ,output v-num
    ).
  define variable v-clear-start as logical   no-undo .
  assign
    v-clear-start = true
  .
  case v-num :
    when 1
    then do:
      assign
        v-restore-from-file = true
        v-restore-backup    = false
      .
      run check-md5-signature in this-procedure
        (input  v-obj-type
        ,input  v-obj-code
        ,input  'aht':U
        ,input  v-file-name
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Складской архив по типам приобретения" skip
            "Объект" v-obj-type v-obj-code skip
            "Ошибка при проверке контрольной суммы файла" skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        undo, return error return-value .
      end.
      input stream sinp from value(v-file-name) .
      run validate-file-name in this-procedure
        (input  v-obj-type
        ,input  v-obj-code
        ,input  v-aht-detail-date
        ,input  v-file-name
        ,output v-restore-start-date
        ,output v-restore-detail-date
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Складской архив по типам приобретения" skip
          "Объект" v-obj-type v-obj-code skip
          "Ошибка при проверке данных файла архивации" skip
          "Имя файла архивации" v-file-name skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      input stream sinp close .
    end.
    when 2
    then do:
      assign
        v-restore-from-file = true
        v-restore-backup    = true
      .
      assign
        v-file-name = v-backup-file-name
      .
      run check-md5-signature in this-procedure
        (input  v-obj-type
        ,input  v-obj-code
        ,input  'aht':U
        ,input  v-file-name
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Складской архив по типам приобретения" skip
            "Объект" v-obj-type v-obj-code skip
            "Ошибка при проверке контрольной суммы файла" skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        undo, return error return-value .
      end.
      input stream sinp from value(v-file-name) .
      run validate-file-name in this-procedure
        (input  v-obj-type
        ,input  v-obj-code
        ,input  v-aht-detail-date
        ,input  v-file-name
        ,output v-restore-start-date
        ,output v-restore-detail-date
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Складской архив по типам приобретения" skip
          "Объект" v-obj-type v-obj-code skip
          "Ошибка при проверке данных файла архивации" skip
          "Имя файла архивации" v-file-name skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      input stream sinp close .
    end.
    when 3
    then do:
      if v-aht-del = true
      then do:
        message
          "Складской архив по типам приобретения" skip
          "Объект" v-obj-type v-obj-code skip
          "Невозможно произвести восстановление на основании документов" skip
          "Остатки складского архива по типам приобретения не рассчитаны" skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if  v-aht-recalc-date <> ?
      and v-aht-recalc-date <= v-aht-detail-date
      then do:
        message
          "Складской архив по типам приобретения" skip
          "Объект" v-obj-type v-obj-code skip
          "Невозможно произвести восстановление на основании документов" skip
          "Дата перерасчета складского архива по типам приобретения меньше даты начала подробного складского архива по типам приобретения" skip
          "Дата перерасчета складского архива по типам приобретения" string(v-aht-recalc-date, '99/99/9999':u) skip
          "Дата начала подробного складского архива по типам приобретени " string(v-aht-detail-date, '99/99/9999':u) skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      assign
        v-restore-from-file = false
        v-restore-backup    = false
      .
      assign
        v-month = month(v-aht-detail-date)
        v-year  = year(v-aht-start-date)
      .
      assign
        v-month = v-month - 1
      .
      if v-month < 1
      then do:
        assign
          v-month = 12
          v-year  = v-year - 1
        .
      end.
      run gbl/d-inpmnt.w
        (input "Введите месяц и год"
        ,input ?
        ,input-output v-month
        ,input-output v-year
        ,output v-ok
        ).
      if v-ok <> true
      then do:
        message
          "Складской архив по типам приобретения" skip
          "Объект" v-obj-type v-obj-code skip
          "Дата расчета складского архива по типам приобретения не задана" skip
          "Восстановление складского архива не было произведено" skip
          view-as alert-box information .
        undo, return error return-value .
      end.
      assign
        v-restore-detail-date = date(v-month, 1, v-year)
      .
      if v-restore-detail-date = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Складской архив по типам приобретения" skip
          "Объект" v-obj-type v-obj-code skip
          "Ошибка при выборе даты" skip
          "Месяц" v-month skip
          "Год" v-year skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if v-restore-detail-date >= v-aht-detail-date
      then do:
        message
          "Складской архив по типам приобретения" skip
          "Объект" v-obj-type v-obj-code skip
          "Неправильная дата расчета складского архива по типам приобретения" skip
          "Дата восстановления складского архива не может быть больше, чем дата на которую" skip
          "имеется рассчитанный складской архив" skip
          "Дата восстановление подробного складского архива по типам приобретения" string(v-restore-detail-date, '99/99/9999':u) skip
          "Дата начала подробного складского архива по типам приобретения" string(v-aht-detail-date, '99/99/9999':u) skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if v-restore-detail-date >= v-aht-start-date
      then do:
        assign
          v-clear-start = false
          v-restore-start-date = v-aht-start-date
        .
      end.
      else do:
        assign
          v-restore-start-date = v-restore-detail-date
        .
      end.
    end.
    when 4
    then do:
      return .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по типам приобретения" skip
        "Объект" v-obj-type v-obj-code skip
        "Внутрення ошибка" skip
        "Неизвестное значение v-num" v-num skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .
  assign
    v-ok = false
  .
  define variable v-aht-source as character no-undo .
  if v-restore-from-file = true
  then do:
    assign
      v-aht-source = "Восстановление складского архива по типам приобретения из файла " + v-file-name
    .
  end.
  else do:
    assign
      v-aht-source = "Рассчёт складского архива по типам приобретения на основании первичных документов"
    .
  end.
  if (v-restore-start-date = ?
      and v-restore-detail-date <> ?
     )
  or (v-restore-start-date <> ?
      and v-restore-detail-date = ?
     )
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Складской архив по типам приобретения" skip
      "Объект" v-obj-type v-obj-code skip
      "Внутренняя ошибка" skip
      "Противоречивая информация в датах начала складского архива и начала подробного складского архива" skip
      "Дата начала складского архива" string(v-restore-start-date, '99/99/9999':u) skip
      "Дата начала подробного складского архива" string(v-restore-detail-date, '99/99/9999':u) skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  message
    "Складской архив по типам приобретения" skip
    "Объект" v-obj-type v-obj-code skip
    "Последнее предупреждение перед восстановлением складского архива по типам приобретения" skip
    "Дата с которой существует складской архив по типам приобретения" string(v-aht-start-date, '99/99/9999':u) skip
    "Дата с которой имеются подробный складской архив по типам приобретения" string(v-aht-detail-date, '99/99/9999':u) skip
    "" skip
    "Дата с которой будет начинаться складской архив по типам приобретения после восстановления" string(v-restore-start-date, '99/99/9999':u) skip
    "Дата с которой будет начинаться подробный складской архив по типам приобретения после восстановления" string(v-restore-detail-date, '99/99/9999':u) skip
    ""
    "" skip
    "Сегодня" string(v-today, '99/99/9999':u) skip
    "" v-aht-source skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true
  then do:
    return .
  end.
  define variable v-start-time     as int64     no-undo .
  define variable v-current-time   as character no-undo .
  define variable v-current-action as character no-undo .
  define variable v-count          as integer   no-undo .
  define variable v-sub-action     as character no-undo .
  def frame a
    v-obj-type       label "Объект"
    v-obj-code       no-label skip
    v-current-action format "x(40)" no-label skip
    v-current-time   format "x(8)"  label "Время расчета складского архива" skip
    v-count          format ">>>,>>>,>>9" no-label skip
    v-sub-action     format "x(40)" no-label skip
    with view-as dialog-box side-labels three-d
    title "Расчет складского архива по типам приобретения"
    .
  assign
    v-start-time = etime
  .
  view frame a .
  display
    v-obj-type
    v-obj-code
    with frame a .
  define variable v-day-end-fact-order   as decimal   no-undo .
  run factord-end-day in this-procedure
    (input  v-aht-detail-date - 1
    ,output v-day-end-fact-order
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Складской архив по типам приобретения" skip
      "Объект" v-obj-type v-obj-code skip
      "Ошибка при вызове процедуры factord"
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if  v-aht-del        = false
  and v-restore-backup = false
  then do:
    run create-log-file in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input v-aht-start-date
      ,input v-aht-detail-date
      ,input v-aht-start-date
      ,input v-aht-detail-date
      ,input v-backup-file-name
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по типам приобретения" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при создании файла архивации" skip
        "Имя файла архивации" v-file-name skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run trg/ahtclr.p
      (input v-obj-type
      ,input v-obj-code
      ,input 0
      ,input v-day-end-fact-order
      ,input v-backup-file-name
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по типам приобретения" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при cохранении складского архива по типам приобретения"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run close-log-file in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input v-aht-start-date
      ,input v-aht-detail-date
      ,input v-aht-start-date
      ,input v-aht-detail-date
      ,input v-backup-file-name
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по типам приобретения" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при закрытии файла архивации" skip
        "Имя файла архивации" v-file-name skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    define variable v-md5-signature as character no-undo .
    run gbl/md5.p
      (input  v-backup-file-name
      ,output v-md5-signature
      ) .
    define variable v-create-chip-num as integer   no-undo .
    define variable v-action-type     as character no-undo .
    if v-restore-from-file = true
    then do:
      assign
        v-action-type = 'rstfil-start':U
      .
    end.
    else do:
      assign
        v-action-type = 'rstdoc-start':U
      .
    end.
    run utl/arhiscr.p
      (input  v-obj-type
      ,input  v-obj-code
      ,input  'aht':U
      ,input  v-action-type
      ,input  v-backup-file-name
      ,input  v-md5-signature
      ,input  0
      ,input  ""
      ,input  ""
      ,input  v-restore-detail-date
      ,output v-create-chip-num
      ) .
  end.
  else do:
    if v-restore-from-file = true
    then do:
      assign
        v-action-type = 'rstfil-start':U
      .
    end.
    else do:
      assign
        v-action-type = 'rstdoc-start':U
      .
    end.
    run utl/arhiscr.p
      (input  v-obj-type
      ,input  v-obj-code
      ,input  'aht':U
      ,input  v-action-type
      ,input  ""
      ,input  ""
      ,input  0
      ,input  ""
      ,input  ""
      ,input  v-restore-detail-date
      ,output v-create-chip-num
      ) .
  end.
  define variable v-start-fact-order           as decimal   no-undo .
  define variable v-start-shift-end-fact-order as decimal   no-undo .
  define variable v-start-day-end-fact-order   as decimal   no-undo .
  if v-clear-start = true
  then do:
    assign
      v-start-day-end-fact-order = 0
    .
  end.
  else do:
    run factord in this-procedure
      (input  v-restore-detail-date - 1
      ,input  1
      ,input  1
      ,input  ?
      ,input  0
      ,input  false
      ,output v-start-fact-order
      ,output v-start-shift-end-fact-order
      ,output v-start-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по типам приобретения" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
  if v-restore-from-file = true
  then do:
    run clntattr-write in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input 'aht-del':U
      ,input 'true':u
      ) .
    run trg/ahtclr.p
      (input v-obj-type
      ,input v-obj-code
      ,input v-start-day-end-fact-order
      ,input v-day-end-fact-order
      ,input ""
      )  no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по типам приобретения" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при удалении складского архива по типам приобретения" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    input stream slog from value(v-file-name) .
    run validate-file-name in this-procedure
      (input  v-obj-type
      ,input  v-obj-code
      ,input  v-aht-detail-date
      ,input  v-file-name
      ,output v-restore-start-date
      ,output v-restore-detail-date
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по типам приобретения" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при закрытии файла архивации" skip
        "Имя файла архивации" v-file-name skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run restore-from-file in this-procedure .
    define variable v-close-restore-start-date  as date      no-undo .
    define variable v-close-restore-detail-date as date      no-undo .
    run validate-file-name in this-procedure
      (input  v-obj-type
      ,input  v-obj-code
      ,input  v-aht-detail-date
      ,input  v-file-name
      ,output v-close-restore-start-date
      ,output v-close-restore-detail-date
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по типам приобретения" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при закрытии файла архивации" skip
        "Имя файла архивации" v-file-name skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-close-restore-start-date  <> v-restore-start-date
    or v-close-restore-detail-date <> v-restore-detail-date
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по типам приобретения" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при закрытии файла архивации" skip
        "Не соответствие дат начала архива и начала подробного архива в конце и в начала файла" skip
        "Дата начала архива в начале файла" v-restore-start-date skip
        "Дата начала подробного архива в началей файла" v-restore-detail-date skip
        "Дата начала архива в конце файла" v-close-restore-start-date skip
        "Дата начала подробного архива в конца файла" v-close-restore-detail-date skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    input stream sinp close .
    run clntattr-write in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input 'aht-start':U
      ,input string(v-restore-start-date, '99/99/9999':u)
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты начала складского архива по типам приобретения" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    run clntattr-write in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input 'aht-detail':U
      ,input string(v-restore-detail-date, '99/99/9999':u)
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты начала подробного складского архива по типам приобретения" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    define variable v-delete-aht-del as logical   no-undo .
    run clntattr-delete in this-procedure
      (input  v-obj-type
      ,input  v-obj-code
      ,input  'aht-del':U
      ,output v-delete-aht-del
      ) .
  end.
  else do:
    define buffer lock_shift-obj for ub.shift-obj .
    run factord-lock-shift in this-procedure
      (input  v-obj-type
      ,input  v-obj-code
      ,input  v-restore-start-date - 1
      ,buffer lock_shift-obj
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при блокировке смены на объекте" skip
        "Объект" v-obj-type v-obj-code skip
        "Дата" v-restore-detail-date skip
        return-value
        view-as alert-box error .
      undo, return error return-value .
    end.
    run doclslib-clear-doc-list in this-procedure .
    run doclslib-init-trn-doc in this-procedure
      (input  v-obj-type
      ,input  v-obj-code
      ,input  v-restore-detail-date
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при заполнении списка документов" skip
        "Объект" v-obj-type v-obj-code skip
        "Дата" v-restore-detail-date skip
        view-as alert-box error .
      undo, return error .
    end.
    run doclslib-init-price-doc in this-procedure
      (input  v-obj-type
      ,input  v-obj-code
      ,input  v-restore-detail-date
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при заполнении списка переоценок" skip
        "Объект" v-obj-type v-obj-code skip
        "Дата" v-restore-detail-date skip
        view-as alert-box error .
      undo, return error .
    end.
    run doclslib-clear-rst in this-procedure
      (input v-aht-detail-date
      ) .
    run doclslib-init-goods in this-procedure .
    run clntattr-write in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input 'aht-rest':U
      ,input 'true':u
      ) .
    run ahrstutl-init in this-procedure
      (input  v-obj-type
      ,input  v-obj-code
      ,input  v-aht-detail-date - 1
      ,input  1
      ) .
    run ahrstutl-create-stk in this-procedure
      (input  v-obj-type
      ,input  v-obj-code
      ,input  v-aht-detail-date - 1
      ) .
    run ahrstutl-clear-aht in this-procedure
      (input  v-obj-type
      ,input  v-obj-code
      ,input  v-start-day-end-fact-order
      ,input  v-aht-detail-date - 1
      ) .
    find current calc-aht-lock_batchprocess no-lock .
    if v-clear-start = true
    then do:
      run show-action in this-procedure
        (input "Инициализация остатка на дату нового начала складского архива по типам приобретения"
        ).
      run trg/inaht.p
        (input  this-procedure :handle
        ,input  v-obj-type
        ,input  v-obj-code
        ,input  v-restore-start-date - 1
        ,input  v-aht-detail-date - 1
        ) .
    end.
    run show-action in this-procedure
      (input "Расчёт складского архива по типам приобретения"
      ).
    run doclslib-calc-aht in this-procedure
      (input this-procedure
      ,input v-obj-type
      ,input v-obj-code
      ,input v-aht-detail-date - 1
      ,input false
      ) .
    if v-clear-start = true
    then do:
      run show-action in this-procedure
        (input "Обновление накопительных остатков"
        ).
      run ahrstutl-init in this-procedure
        (input v-obj-type
        ,input v-obj-code
        ,input v-aht-detail-date - 1
        ,input -1
        ) .
      run ahrstutl-update in this-procedure
        (input v-obj-type
        ,input v-obj-code
        ,input v-restore-detail-date - 1
        ,input v-aht-detail-date - 1
        ) .
    end.
    run show-action in this-procedure
      (input "Блокировка расчёта складского архива по типам приобретения"
      ).
    define variable v-need-stop-aht as logical   no-undo .
    assign
      v-need-stop-aht = false
    .
    run gbl/lock-prc.p
      (input 'ahtb':U
      ,input v-obj-code
      ,input 0
      ,input 0
      ,input v-obj-type
      ,input ""
      ,input ""
      ,input "Объект,,, ,,,Расчет складского архива по типам приобретения"
      ,input false
      ,buffer calc-aht-lock_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры блокировки расчета складского архива по типам приобретения" skip
          "Невозможно продолжить восстановление складского архива по типам приобретения" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error "Ошибка при вызове процедуры блокировки расчёта складского архива по типам приобретения" .
      end.
      assign
        v-need-stop-aht = true
      .
    end.
    define buffer stop-aht-restore-lock_btpr for batchprocess .
    if v-need-stop-aht = true
    then do:
      do transaction
      on error undo, return error return-value
      :
        create stop-aht-restore-lock_btpr .
        assign
          stop-aht-restore-lock_btpr.bp_type       = 'lock':U + 'rsrs':U
          stop-aht-restore-lock_btpr.bp_status     = 'N':U
          stop-aht-restore-lock_btpr.Key#_One      = v-obj-code
          stop-aht-restore-lock_btpr.Key#_Two      = 0
          stop-aht-restore-lock_btpr.Key#_Three    = 0
          stop-aht-restore-lock_btpr.CharKey_One   = v-obj-type
          stop-aht-restore-lock_btpr.CharKey_Two   = ""
          stop-aht-restore-lock_btpr.CharKey_Three = ""
        .
        define variable v-start-lock-time   as int64     no-undo .
        define variable v-start-lock-second as integer   no-undo .
        assign
          v-start-lock-time = etime
        .
        wait_block:
        do while true
        :
          assign
            v-start-lock-second = integer((etime - v-start-lock-time) / 1000)
          .
          run waitfram-show in this-procedure
            (input waitfram-join-function("Архив рассчитывается на другой машине"
                                         ,"Отправлено сообщение о необходимости остановки расчёта складского архива"
                                         ,substitute("Ожидание освобождения ресурса расчёта складского архива &1", string(v-start-lock-second, 'HH:MM:SS':U))
                                         )
            ) .
          run gbl/lock-prc.p
            (input 'ahtb':U
            ,input v-obj-code
            ,input 0
            ,input 0
            ,input v-obj-type
            ,input ""
            ,input ""
            ,input "Объект,,, ,,,Расчет складского архива по типам приобретения"
            ,input false
            ,buffer calc-aht-lock_batchprocess
            ) no-error .
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры блокировки расчета складского архива по типам приобретения" skip
                "Невозможно продолжить восстановление складского архива по типам приобретения" skip
                view-as alert-box error .
              undo, return error "В данный момент рассчитывается складской архив по типам приобретения" .
            end.
          end.
          else do:
            run waitfram-hide in this-procedure .
            leave wait_block .
          end.
          pause 1 no-message .
        end.
        delete stop-aht-restore-lock_btpr .
      end.
    end.
    run show-action in this-procedure
      (input "Удаление повторных записей остатков"
      ).
    run ahrstutl-delete-copy in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input v-aht-detail-date - 1
      ) .
    run show-action in this-procedure
      (input "Обновление атрибутов складского архива"
      ).
    run clntattr-write in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input 'aht-start':U
      ,input string(v-restore-start-date, '99/99/9999':u)
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты начала складского архива по типам приобретения" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    run clntattr-write in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input 'aht-detail':U
      ,input string(v-restore-detail-date, '99/99/9999':u)
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты начала подробного складского архива по типам приобретения" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    define variable v-delete-aht-rest as logical   no-undo .
    run clntattr-delete in this-procedure
      (input  v-obj-type
      ,input  v-obj-code
      ,input  'aht-rest':U
      ,output v-delete-aht-rest
      ) .
  end.
  if v-restore-from-file = true
  then do:
    assign
      v-action-type = 'rstfil-stop':U
    .
  end.
  else do:
    assign
      v-action-type = 'rstdoc-stop':U
    .
  end.
  run utl/arhiscr.p
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'aht':U
    ,input  v-action-type
    ,input  ""
    ,input  ""
    ,input  0
    ,input  ""
    ,input  ""
    ,input  v-restore-detail-date
    ,output v-create-chip-num
    ) .
  run invalidate-md5-signature in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'aht':U
    ,input  v-file-name
    ,input  v-create-chip-num
    ) .
  run invalidate-md5-signature in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'aht':U
    ,input  v-backup-file-name
    ,input  v-create-chip-num
    ) .
  message
    "Складской архив по типам приобретения" skip
    "Объект" v-obj-type v-obj-code skip
    "Восстановление складского архива по типам приобретения успешно закончилось" skip
    "Объект" v-obj-type v-obj-code skip
    "" + (if v-restore-detail-date <> ?
         then substitute("На объекте существует подробный складской архив с даты &1", string(v-restore-detail-date, '99/99/9999':u))
         else "На объекте существует складской архив с даты открытия объекта"
         ) skip
    view-as alert-box information .
end.
procedure restore-from-file :
  do
  on error undo, return error return-value
  :
    define variable v-key-value as character no-undo .
    run show-action in this-procedure
      (input "Импорт данных из файла " + v-file-name
      ) .
    define variable v-data-finished as logical   no-undo .
    assign
      v-data-finished = false
    .
    assign
      v-line-num = 0
    .
    define variable v-total-count as integer   no-undo .
    assign
      v-total-count = 0
    .
    repeat
    :
      import stream sinp v-key-value .
      assign
        v-line-num = v-line-num + 1
      .
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Чтение файла"
          ) .
      end.
      case v-key-value :
          when 'aht-doc':u then do:     define buffer buf_aht-doc for ub.aht-doc .     create buf_aht-doc .     import stream sinp buf_aht-doc no-error .     if error-status :error then do:       message         vss-workfile vss-revision vss-description skip         "Ошибка при импорте таблицы aht-doc" skip         "Строка" v-line-num skip         error-status :get-message(1) skip         view-as alert-box error .       undo, return error .     end.     assign       v-line-num = v-line-num + 1     .   end.
          when 'aht-gds':u then do:     define buffer buf_aht-gds for ub.aht-gds .     create buf_aht-gds .     import stream sinp buf_aht-gds no-error .     if error-status :error then do:       message         vss-workfile vss-revision vss-description skip         "Ошибка при импорте таблицы aht-gds" skip         "Строка" v-line-num skip         error-status :get-message(1) skip         view-as alert-box error .       undo, return error .     end.     assign       v-line-num = v-line-num + 1     .   end.
          when 'aht-stk':u then do:     define buffer buf_aht-stk for ub.aht-stk .     create buf_aht-stk .     import stream sinp buf_aht-stk no-error .     if error-status :error then do:       message         vss-workfile vss-revision vss-description skip         "Ошибка при импорте таблицы aht-stk" skip         "Строка" v-line-num skip         error-status :get-message(1) skip         view-as alert-box error .       undo, return error .     end.     assign       v-line-num = v-line-num + 1     .   end.
          when 'aht-time':u then do:     define buffer buf_aht-time for ub.aht-time .     create buf_aht-time .     import stream sinp buf_aht-time no-error .     if error-status :error then do:       message         vss-workfile vss-revision vss-description skip         "Ошибка при импорте таблицы aht-time" skip         "Строка" v-line-num skip         error-status :get-message(1) skip         view-as alert-box error .       undo, return error .     end.     assign       v-line-num = v-line-num + 1     .   end.
          when 'aht-ot-tot':u then do:     define buffer buf_aht-ot-tot for ub.aht-ot-tot .     create buf_aht-ot-tot .     import stream sinp buf_aht-ot-tot no-error .     if error-status :error then do:       message         vss-workfile vss-revision vss-description skip         "Ошибка при импорте таблицы aht-ot-tot" skip         "Строка" v-line-num skip         error-status :get-message(1) skip         view-as alert-box error .       undo, return error .     end.     assign       v-line-num = v-line-num + 1     .   end.
          when 'aht-ot-line':u then do:     define buffer buf_aht-ot-line for ub.aht-ot-line .     create buf_aht-ot-line .     import stream sinp buf_aht-ot-line no-error .     if error-status :error then do:       message         vss-workfile vss-revision vss-description skip         "Ошибка при импорте таблицы aht-ot-line" skip         "Строка" v-line-num skip         error-status :get-message(1) skip         view-as alert-box error .       undo, return error .     end.     assign       v-line-num = v-line-num + 1     .   end.
          when 'aht-stk-tot':u then do:     define buffer buf_aht-stk-tot for ub.aht-stk-tot .     create buf_aht-stk-tot .     import stream sinp buf_aht-stk-tot no-error .     if error-status :error then do:       message         vss-workfile vss-revision vss-description skip         "Ошибка при импорте таблицы aht-stk-tot" skip         "Строка" v-line-num skip         error-status :get-message(1) skip         view-as alert-box error .       undo, return error .     end.     assign       v-line-num = v-line-num + 1     .   end.
          when 'aht-stk-line':u then do:     define buffer buf_aht-stk-line for ub.aht-stk-line .     create buf_aht-stk-line .     import stream sinp buf_aht-stk-line no-error .     if error-status :error then do:       message         vss-workfile vss-revision vss-description skip         "Ошибка при импорте таблицы aht-stk-line" skip         "Строка" v-line-num skip         error-status :get-message(1) skip         view-as alert-box error .       undo, return error .     end.     assign       v-line-num = v-line-num + 1     .   end.
        when 'end-of-log':u
        then do:
          assign
            v-data-finished = true
          .
          leave .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Складской архив по типам приобретения" skip
            "Объект" v-obj-type v-obj-code skip
            "Неизвестный код таблицы" v-key-value skip
            "Строка" v-line-num skip
            view-as alert-box error .
          undo, return error .
        end.
      end case .
    end.
    if v-data-finished = false
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по типам приобретения" skip
        "Объект" v-obj-type v-obj-code skip
        "Не найден признак окончания данных" skip
        "Неправильный формат файла" v-file-name skip
        "Строка" v-line-num skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure validate-file-name :
  define input parameter  p-obj-type            as character no-undo .
  define input parameter  p-obj-code            as integer   no-undo .
  define input parameter  v-aht-detail-date     as date      no-undo .
  define input parameter  p-file-name           as character no-undo .
  define output parameter p-restore-start-date  as date      no-undo .
  define output parameter p-restore-detail-date as date      no-undo .
  do
  on error undo, return error
  :
    define variable v-param-code  as character no-undo .
    define variable v-param-value as character no-undo .
    import stream sinp v-param-code v-param-value .
    assign
      v-line-num = v-line-num + 1
    .
    if v-param-code <> 'archive-log-version':u
    or v-param-value <> '2.1':u
    then do:
      message
        "Складской архив по типам приобретения" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error .
    end.
    import stream sinp v-param-code v-param-value .
    assign
      v-line-num = v-line-num + 1
    .
    if v-param-code <> 'obj-type':u
    or v-param-value <> p-obj-type
    then do:
      message
        "Складской архив по типам приобретения" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error .
    end.
    import stream sinp v-param-code v-param-value .
    assign
      v-line-num = v-line-num + 1
    .
    if v-param-code <> 'obj-code':u
    or v-param-value <> string(p-obj-code)
    then do:
      message
        "Складской архив по типам приобретения" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error .
    end.
    import stream sinp v-param-code v-param-value .
    assign
      v-line-num = v-line-num + 1
    .
    if v-param-code <> 'old-start-date':u
    then do:
      message
        "Складской архив по типам приобретения" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-restore-start-date = date(v-param-value)
    .
    import stream sinp v-param-code v-param-value .
    assign
      v-line-num = v-line-num + 1
    .
    if v-param-code <> 'old-detail-date':u
    then do:
      message
        "Складской архив по типам приобретения" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-restore-detail-date = date(v-param-value)
    .
    import stream sinp v-param-code v-param-value .
    assign
      v-line-num = v-line-num + 1
    .
    if v-param-code <> 'new-start-date':u
    then do:
      message
        "Складской архив по типам приобретения" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error .
    end.
    import stream sinp v-param-code v-param-value .
    assign
      v-line-num = v-line-num + 1
    .
    if v-param-code <> 'new-detail-date':u
    then do:
      message
        "Складской архив по типам приобретения" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-aht-detail-date <> date(v-param-value)
    then do:
      message
        "Складской архив по типам приобретения" skip
        "Объект" p-obj-type p-obj-code skip
        "Несоответствие текущей даты начала подробного архива" skip
        "и даты начала подробного архива в файле" p-file-name skip
        "Строка" v-line-num skip
        "Текущая дата начала подробного архива" string(v-aht-detail-date) skip
        "Дата начала подробного архива в файле" v-param-value skip
        "Восстановление архива невозможно" skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure show-action :
  do
  on error undo, return error
  :
    define input parameter p-action as character no-undo .
    assign
      v-current-time = string(time - v-start-time, "HH:MM:SS")
      v-current-action = p-action
    .
    display
      v-current-time
      v-current-action
      with frame a.
  end.
end procedure.
procedure show-count :
  define input  parameter p-count      as integer   no-undo .
  define input  parameter p-sub-action as character no-undo .
  do
  on error undo, return error
  :
    assign
      v-current-time = string(time - v-start-time, "HH:MM:SS")
      v-count        = p-count
      v-sub-action   = p-sub-action
    .
    display
      v-current-time
      v-count
      v-sub-action
      with frame a.
  end.
end procedure.
procedure create-log-file :
  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-old-start-date  as date      no-undo .
  define input  parameter p-old-detail-date as date      no-undo .
  define input  parameter p-new-start-date  as date      no-undo .
  define input  parameter p-new-detail-date as date      no-undo .
  define input  parameter p-file-name       as character no-undo .
  do
  on error undo, return error
  :
    if search('.' + '/':u + p-file-name) <> ?
    then do:
      define variable v-ok as logical   no-undo .
      message
        "ВНИМАНИЕ!" skip
        "Файл" p-file-name "существует и будет перезаписан" skip
        "Продолжить?"
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok <> true
      then do:
        undo, return error return-value .
      end.
    end.
    output stream slog to value(p-file-name) .
    export stream slog 'archive-log-version':u '2.1':u .
    export stream slog 'obj-type':u            p-obj-type .
    export stream slog 'obj-code':u            string(p-obj-code) .
    export stream slog 'old-start-date':u      string(p-old-start-date, '99/99/9999':u ) .
    export stream slog 'old-detail-date':u     string(p-old-detail-date, '99/99/9999':u ) .
    export stream slog 'new-start-date':u      string(p-new-start-date, '99/99/9999':u ) .
    export stream slog 'new-detail-date':u     string(p-new-detail-date, '99/99/9999':u ) .
    output stream slog close .
  end.
end procedure.
procedure close-log-file :
  define input  parameter p-obj-type        as character no-undo .
  define input  parameter p-obj-code        as integer   no-undo .
  define input  parameter p-old-start-date  as date      no-undo .
  define input  parameter p-old-detail-date as date      no-undo .
  define input  parameter p-new-start-date  as date      no-undo .
  define input  parameter p-new-detail-date as date      no-undo .
  define input  parameter p-file-name       as character no-undo .
  do
  on error undo, return error
  :
    output stream slog to value(p-file-name) append .
    export stream slog 'end-of-log':u .
    export stream slog 'archive-log-version':u '2.1':u .
    export stream slog 'obj-type':u            p-obj-type .
    export stream slog 'obj-code':u            string(p-obj-code) .
    export stream slog 'old-start-date':u      string(p-old-start-date, '99/99/9999':u ) .
    export stream slog 'old-detail-date':u     string(p-old-detail-date, '99/99/9999':u ) .
    export stream slog 'new-start-date':u      string(p-new-start-date, '99/99/9999':u ) .
    export stream slog 'new-detail-date':u     string(p-new-detail-date, '99/99/9999':u ) .
    export stream slog '.':u                   .
    output stream slog close .
  end.
end procedure.
procedure store-temp :
  define buffer buf_temp-aht-stk-tot  for temp-aht-stk-tot .
  define buffer buf_temp-aht-stk-line for temp-aht-stk-line .
  define buffer buf_temp-create-aht-stk-tot  for temp-create-aht-stk-tot .
  define buffer buf_temp-create-aht-stk-line for temp-create-aht-stk-line .
  do
  on error undo, return error return-value
  :
    output stream sout to value ("rst-aht.txt") append .
    export stream sout 'export':u string(today, '99/99/9999':u) string(time, 'hh:mm:ss':u) .
    for each buf_temp-aht-stk-tot
    on error undo, return error return-value
    :
      export stream sout 'temp-aht-stk-tot':u .
      export stream sout buf_temp-aht-stk-tot .
    end.
    for each buf_temp-aht-stk-line
    on error undo, return error return-value
    :
      export stream sout 'temp-aht-stk-line':u .
      export stream sout buf_temp-aht-stk-line .
    end.
    for each buf_temp-create-aht-stk-tot
    on error undo, return error return-value
    :
      export stream sout 'temp-create-aht-stk-tot':u .
      export stream sout buf_temp-create-aht-stk-tot .
    end.
    for each buf_temp-create-aht-stk-line
    on error undo, return error return-value
    :
      export stream sout 'temp-create-aht-stk-line':u .
      export stream sout buf_temp-create-aht-stk-line .
    end.
    output stream sout close .
  end.
end procedure.
procedure ahrstutl-init :
  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-fact-date          as date      no-undo .
  define input  parameter p-sign               as integer   no-undo .
  define variable v-shift-on                as logical   no-undo .
  define variable v-shift-date              as date      no-undo .
  define variable v-shift-num               as integer   no-undo .
  define variable v-day-end-fact-order      as decimal   no-undo .
  define variable v-shift-end-fact-order    as decimal   no-undo .
  define variable v-search-end-fact-order   as decimal   no-undo .
  define variable v-create-fact-order       as decimal   no-undo .
  define variable v-shift-create-fact-order as decimal   no-undo .
  define variable v-gds-goods     as logical   no-undo .
  define variable v-sum-type-list as character no-undo .
  do
  on error undo, return error return-value
  :
    run factord-cut-archive in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-fact-date
      ,output v-shift-on
      ,output v-shift-date
      ,output v-shift-num
      ,output v-day-end-fact-order
      ,output v-shift-end-fact-order
      ) .
    assign
      v-create-fact-order       = v-day-end-fact-order
      v-shift-create-fact-order = v-shift-end-fact-order
    .
    if p-sign = -1
    then do:
      assign
        v-day-end-fact-order   = v-day-end-fact-order - 0.0000000001
        v-shift-end-fact-order = v-shift-end-fact-order - 0.0000000001
      .
    end.
    define variable v-ind as integer   no-undo .
    run show-action in this-procedure
      (input "Остаток по объекту"
      ).
    run ahrstutl-tot-sum-type-list in this-procedure
      (output v-sum-type-list
      ) .
    do v-ind = 1 to num-entries(v-sum-type-list)
    :
      run ahrstutl-init-tot in this-procedure
        (input p-obj-type
        ,input p-obj-code
        ,input entry(v-ind, v-sum-type-list)
        ,input v-day-end-fact-order
        ,input v-create-fact-order
        ,input p-sign
        ) .
    end.
    run show-action in this-procedure
      (input "Остаток по товарам"
      ).
    define variable v-total-count as integer   no-undo .
    define buffer buf_doclslib-goods for doclslib-goods.
    for each buf_doclslib-goods no-lock
    on error undo, return error return-value
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Артикул " + string(buf_doclslib-goods.artic)
          ).
      end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  buf_doclslib-goods.gds-code
  ,input  'gds-goods=request':u
  ,output v-gds-goods
  ) no-error .
      run ahrstutl-line-sum-type-list in this-procedure
        (input  v-gds-goods
        ,output v-sum-type-list
        ) .
      do v-ind = 1 to num-entries(v-sum-type-list)
      :
        run ahrstutl-init-line in this-procedure
          (input p-obj-type
          ,input p-obj-code
          ,input buf_doclslib-goods.gds-code
          ,input entry(v-ind, v-sum-type-list)
          ,input v-day-end-fact-order
          ,input v-create-fact-order
          ,input p-sign
          ) .
      end.
    end.
  end.
end procedure.
procedure ahrstutl-init-tot :
  define input  parameter p-obj-type               as character no-undo .
  define input  parameter p-obj-code               as integer   no-undo .
  define input  parameter p-sum-type               as character no-undo .
  define input  parameter p-aht-stk-tot-fact-order as decimal   no-undo .
  define input  parameter p-create-tot-fact-order  as decimal   no-undo .
  define input  parameter p-sign                   as integer   no-undo .
  define buffer buf_aht-stk-tot for ub.aht-stk-tot .
  define buffer buf_temp-aht-stk-tot for temp-aht-stk-tot .
  define buffer buf_temp-create-aht-stk-tot for temp-create-aht-stk-tot .
  define variable v-prev-stk-tot-fact-order        like ub.stk-tot.fact-order no-undo .
  define variable v-create-stk as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-create-stk = false
    .
    find last buf_aht-stk-tot no-lock
      where buf_aht-stk-tot.obj-type   = p-obj-type
        and buf_aht-stk-tot.obj-code   = p-obj-code
        and buf_aht-stk-tot.sum-type   = p-sum-type
        and buf_aht-stk-tot.fact-order <= p-aht-stk-tot-fact-order
      use-index category
      no-error .
    if available buf_aht-stk-tot
    then do:
      assign
        v-prev-stk-tot-fact-order = buf_aht-stk-tot.fact-order
      .
      if v-prev-stk-tot-fact-order <> p-aht-stk-tot-fact-order
      then do:
        assign
          v-create-stk = true
        .
      end.
      else do:
        assign
          v-create-stk = false
        .
      end.
      find first buf_temp-aht-stk-tot
        where buf_temp-aht-stk-tot.obj-type   = buf_aht-stk-tot.obj-type
          and buf_temp-aht-stk-tot.obj-code   = buf_aht-stk-tot.obj-code
          and buf_temp-aht-stk-tot.fact-order = p-create-tot-fact-order
          and buf_temp-aht-stk-tot.sum-type   = buf_aht-stk-tot.sum-type
        no-error .
      if not available buf_temp-aht-stk-tot
      then do:
        create buf_temp-aht-stk-tot .
        assign
                              buf_temp-aht-stk-tot.obj-type     = buf_aht-stk-tot.obj-type     buf_temp-aht-stk-tot.obj-code     = buf_aht-stk-tot.obj-code     buf_temp-aht-stk-tot.fact-order   = buf_aht-stk-tot.fact-order   buf_temp-aht-stk-tot.sum-type     = buf_aht-stk-tot.sum-type
          buf_temp-aht-stk-tot.fact-order = p-aht-stk-tot-fact-order
        .
      end.
      assign
        buf_temp-aht-stk-tot.fact-qnty = buf_temp-aht-stk-tot.fact-qnty
                                       + p-sign * buf_aht-stk-tot.fact-qnty
                                                                        buf_temp-aht-stk-tot.cost-sum-base       = buf_temp-aht-stk-tot.cost-sum-base       + p-sign * buf_aht-stk-tot.cost-sum-base            buf_temp-aht-stk-tot.cost-sum-rubl       = buf_temp-aht-stk-tot.cost-sum-rubl       + p-sign * buf_aht-stk-tot.cost-sum-rubl            buf_temp-aht-stk-tot.cost-vat-base       = buf_temp-aht-stk-tot.cost-vat-base       + p-sign * buf_aht-stk-tot.cost-vat-base            buf_temp-aht-stk-tot.cost-vat-rubl       = buf_temp-aht-stk-tot.cost-vat-rubl       + p-sign * buf_aht-stk-tot.cost-vat-rubl            buf_temp-aht-stk-tot.cost-slt-base       = buf_temp-aht-stk-tot.cost-slt-base       + p-sign * buf_aht-stk-tot.cost-slt-base            buf_temp-aht-stk-tot.cost-slt-rubl       = buf_temp-aht-stk-tot.cost-slt-rubl       + p-sign * buf_aht-stk-tot.cost-slt-rubl            buf_temp-aht-stk-tot.cost-road-tax-base  = buf_temp-aht-stk-tot.cost-road-tax-base  + p-sign * buf_aht-stk-tot.cost-road-tax-base       buf_temp-aht-stk-tot.cost-road-tax-rubl  = buf_temp-aht-stk-tot.cost-road-tax-rubl  + p-sign * buf_aht-stk-tot.cost-road-tax-rubl       buf_temp-aht-stk-tot.cost-excise-base    = buf_temp-aht-stk-tot.cost-excise-base    + p-sign * buf_aht-stk-tot.cost-excise-base         buf_temp-aht-stk-tot.cost-excise-rubl    = buf_temp-aht-stk-tot.cost-excise-rubl    + p-sign * buf_aht-stk-tot.cost-excise-rubl         buf_temp-aht-stk-tot.cost-transport-base = buf_temp-aht-stk-tot.cost-transport-base + p-sign * buf_aht-stk-tot.cost-transport-base      buf_temp-aht-stk-tot.cost-transport-rubl = buf_temp-aht-stk-tot.cost-transport-rubl + p-sign * buf_aht-stk-tot.cost-transport-rubl      buf_temp-aht-stk-tot.cost-other-base     = buf_temp-aht-stk-tot.cost-other-base     + p-sign * buf_aht-stk-tot.cost-other-base          buf_temp-aht-stk-tot.cost-other-rubl     = buf_temp-aht-stk-tot.cost-other-rubl     + p-sign * buf_aht-stk-tot.cost-other-rubl          buf_temp-aht-stk-tot.cost-discnt-base    = buf_temp-aht-stk-tot.cost-discnt-base    + p-sign * buf_aht-stk-tot.cost-discnt-base          buf_temp-aht-stk-tot.cost-discnt-rubl    = buf_temp-aht-stk-tot.cost-discnt-rubl    + p-sign * buf_aht-stk-tot.cost-discnt-rubl
                                                                        buf_temp-aht-stk-tot.crsa-sum-base       = buf_temp-aht-stk-tot.crsa-sum-base       + p-sign * buf_aht-stk-tot.crsa-sum-base            buf_temp-aht-stk-tot.crsa-sum-rubl       = buf_temp-aht-stk-tot.crsa-sum-rubl       + p-sign * buf_aht-stk-tot.crsa-sum-rubl            buf_temp-aht-stk-tot.crsa-vat-base       = buf_temp-aht-stk-tot.crsa-vat-base       + p-sign * buf_aht-stk-tot.crsa-vat-base            buf_temp-aht-stk-tot.crsa-vat-rubl       = buf_temp-aht-stk-tot.crsa-vat-rubl       + p-sign * buf_aht-stk-tot.crsa-vat-rubl            buf_temp-aht-stk-tot.crsa-slt-base       = buf_temp-aht-stk-tot.crsa-slt-base       + p-sign * buf_aht-stk-tot.crsa-slt-base            buf_temp-aht-stk-tot.crsa-slt-rubl       = buf_temp-aht-stk-tot.crsa-slt-rubl       + p-sign * buf_aht-stk-tot.crsa-slt-rubl            buf_temp-aht-stk-tot.crsa-road-tax-base  = buf_temp-aht-stk-tot.crsa-road-tax-base  + p-sign * buf_aht-stk-tot.crsa-road-tax-base       buf_temp-aht-stk-tot.crsa-road-tax-rubl  = buf_temp-aht-stk-tot.crsa-road-tax-rubl  + p-sign * buf_aht-stk-tot.crsa-road-tax-rubl       buf_temp-aht-stk-tot.crsa-excise-base    = buf_temp-aht-stk-tot.crsa-excise-base    + p-sign * buf_aht-stk-tot.crsa-excise-base         buf_temp-aht-stk-tot.crsa-excise-rubl    = buf_temp-aht-stk-tot.crsa-excise-rubl    + p-sign * buf_aht-stk-tot.crsa-excise-rubl         buf_temp-aht-stk-tot.crsa-transport-base = buf_temp-aht-stk-tot.crsa-transport-base + p-sign * buf_aht-stk-tot.crsa-transport-base      buf_temp-aht-stk-tot.crsa-transport-rubl = buf_temp-aht-stk-tot.crsa-transport-rubl + p-sign * buf_aht-stk-tot.crsa-transport-rubl      buf_temp-aht-stk-tot.crsa-other-base     = buf_temp-aht-stk-tot.crsa-other-base     + p-sign * buf_aht-stk-tot.crsa-other-base          buf_temp-aht-stk-tot.crsa-other-rubl     = buf_temp-aht-stk-tot.crsa-other-rubl     + p-sign * buf_aht-stk-tot.crsa-other-rubl          buf_temp-aht-stk-tot.crsa-discnt-base    = buf_temp-aht-stk-tot.crsa-discnt-base    + p-sign * buf_aht-stk-tot.crsa-discnt-base          buf_temp-aht-stk-tot.crsa-discnt-rubl    = buf_temp-aht-stk-tot.crsa-discnt-rubl    + p-sign * buf_aht-stk-tot.crsa-discnt-rubl
                                                                        buf_temp-aht-stk-tot.sale-sum-base       = buf_temp-aht-stk-tot.sale-sum-base       + p-sign * buf_aht-stk-tot.sale-sum-base            buf_temp-aht-stk-tot.sale-sum-rubl       = buf_temp-aht-stk-tot.sale-sum-rubl       + p-sign * buf_aht-stk-tot.sale-sum-rubl            buf_temp-aht-stk-tot.sale-vat-base       = buf_temp-aht-stk-tot.sale-vat-base       + p-sign * buf_aht-stk-tot.sale-vat-base            buf_temp-aht-stk-tot.sale-vat-rubl       = buf_temp-aht-stk-tot.sale-vat-rubl       + p-sign * buf_aht-stk-tot.sale-vat-rubl            buf_temp-aht-stk-tot.sale-slt-base       = buf_temp-aht-stk-tot.sale-slt-base       + p-sign * buf_aht-stk-tot.sale-slt-base            buf_temp-aht-stk-tot.sale-slt-rubl       = buf_temp-aht-stk-tot.sale-slt-rubl       + p-sign * buf_aht-stk-tot.sale-slt-rubl            buf_temp-aht-stk-tot.sale-road-tax-base  = buf_temp-aht-stk-tot.sale-road-tax-base  + p-sign * buf_aht-stk-tot.sale-road-tax-base       buf_temp-aht-stk-tot.sale-road-tax-rubl  = buf_temp-aht-stk-tot.sale-road-tax-rubl  + p-sign * buf_aht-stk-tot.sale-road-tax-rubl       buf_temp-aht-stk-tot.sale-excise-base    = buf_temp-aht-stk-tot.sale-excise-base    + p-sign * buf_aht-stk-tot.sale-excise-base         buf_temp-aht-stk-tot.sale-excise-rubl    = buf_temp-aht-stk-tot.sale-excise-rubl    + p-sign * buf_aht-stk-tot.sale-excise-rubl         buf_temp-aht-stk-tot.sale-transport-base = buf_temp-aht-stk-tot.sale-transport-base + p-sign * buf_aht-stk-tot.sale-transport-base      buf_temp-aht-stk-tot.sale-transport-rubl = buf_temp-aht-stk-tot.sale-transport-rubl + p-sign * buf_aht-stk-tot.sale-transport-rubl      buf_temp-aht-stk-tot.sale-other-base     = buf_temp-aht-stk-tot.sale-other-base     + p-sign * buf_aht-stk-tot.sale-other-base          buf_temp-aht-stk-tot.sale-other-rubl     = buf_temp-aht-stk-tot.sale-other-rubl     + p-sign * buf_aht-stk-tot.sale-other-rubl          buf_temp-aht-stk-tot.sale-discnt-base    = buf_temp-aht-stk-tot.sale-discnt-base    + p-sign * buf_aht-stk-tot.sale-discnt-base          buf_temp-aht-stk-tot.sale-discnt-rubl    = buf_temp-aht-stk-tot.sale-discnt-rubl    + p-sign * buf_aht-stk-tot.sale-discnt-rubl
      .
    end.
    else do:
      assign
        v-create-stk = true
      .
      find first buf_temp-aht-stk-tot
        where buf_temp-aht-stk-tot.obj-type   = p-obj-type
          and buf_temp-aht-stk-tot.obj-code   = p-obj-code
          and buf_temp-aht-stk-tot.fact-order = p-create-tot-fact-order
          and buf_temp-aht-stk-tot.sum-type   = p-sum-type
        no-error .
      if not available buf_temp-aht-stk-tot
      then do:
        create buf_temp-aht-stk-tot .
        assign
          buf_temp-aht-stk-tot.obj-type   = p-obj-type
          buf_temp-aht-stk-tot.obj-code   = p-obj-code
          buf_temp-aht-stk-tot.fact-order = p-create-tot-fact-order
          buf_temp-aht-stk-tot.sum-type   = p-sum-type
        .
      end.
    end.
    if p-sign = 1
    then do:
      create buf_temp-create-aht-stk-tot .
      assign
        buf_temp-create-aht-stk-tot.obj-type    = p-obj-type
        buf_temp-create-aht-stk-tot.obj-code    = p-obj-code
        buf_temp-create-aht-stk-tot.sum-type    = p-sum-type
        buf_temp-create-aht-stk-tot.need-create = v-create-stk
      .
    end.
  end.
end procedure.
procedure ahrstutl-init-line :
  define input  parameter p-obj-type                as character no-undo .
  define input  parameter p-obj-code                as integer   no-undo .
  define input  parameter p-gds-code                as integer   no-undo .
  define input  parameter p-sum-type                as character no-undo .
  define input  parameter p-aht-stk-line-fact-order as decimal   no-undo .
  define input  parameter p-create-line-fact-order  as decimal   no-undo .
  define input  parameter p-sign                    as integer   no-undo .
  define buffer buf_aht-stk-line for ub.aht-stk-line .
  define buffer buf_temp-aht-stk-line for temp-aht-stk-line .
  define buffer buf_temp-create-aht-stk-line for temp-create-aht-stk-line .
  define variable v-prev-stk-line-fact-order       like ub.stk-line.fact-order no-undo .
  define variable v-prev-shift-stk-line-fact-order like ub.stk-line.fact-order no-undo .
  define variable v-create-stk as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-create-stk = false
    .
    find last buf_aht-stk-line no-lock
      where buf_aht-stk-line.obj-type   = p-obj-type
        and buf_aht-stk-line.obj-code   = p-obj-code
        and buf_aht-stk-line.gds-code   = p-gds-code
        and buf_aht-stk-line.sum-type   = p-sum-type
        and buf_aht-stk-line.fact-order <= p-aht-stk-line-fact-order
      use-index category
      no-error .
    if available buf_aht-stk-line
    then do:
      assign
        v-prev-stk-line-fact-order = buf_aht-stk-line.fact-order
      .
      if v-prev-stk-line-fact-order <> p-aht-stk-line-fact-order
      then do:
        assign
          v-create-stk = true
        .
      end.
      else do:
        assign
          v-create-stk = false
        .
      end.
      find first buf_temp-aht-stk-line
        where buf_temp-aht-stk-line.obj-type   = buf_aht-stk-line.obj-type
          and buf_temp-aht-stk-line.obj-code   = buf_aht-stk-line.obj-code
          and buf_temp-aht-stk-line.gds-code   = buf_aht-stk-line.gds-code
          and buf_temp-aht-stk-line.fact-order = p-create-line-fact-order
          and buf_temp-aht-stk-line.sum-type   = buf_aht-stk-line.sum-type
        no-error .
      if not available buf_temp-aht-stk-line
      then do:
        create buf_temp-aht-stk-line .
        assign
          buf_temp-aht-stk-line.obj-type   = buf_aht-stk-line.obj-type
          buf_temp-aht-stk-line.obj-code   = buf_aht-stk-line.obj-code
          buf_temp-aht-stk-line.gds-code   = buf_aht-stk-line.gds-code
          buf_temp-aht-stk-line.fact-order = p-create-line-fact-order
          buf_temp-aht-stk-line.sum-type   = buf_aht-stk-line.sum-type
        .
      end.
      assign
        buf_temp-aht-stk-line.fact-qnty = buf_temp-aht-stk-line.fact-qnty
                                        + p-sign * buf_aht-stk-line.fact-qnty
                                                                        buf_temp-aht-stk-line.cost-sum-base       = buf_temp-aht-stk-line.cost-sum-base       + p-sign * buf_aht-stk-line.cost-sum-base            buf_temp-aht-stk-line.cost-sum-rubl       = buf_temp-aht-stk-line.cost-sum-rubl       + p-sign * buf_aht-stk-line.cost-sum-rubl            buf_temp-aht-stk-line.cost-vat-base       = buf_temp-aht-stk-line.cost-vat-base       + p-sign * buf_aht-stk-line.cost-vat-base            buf_temp-aht-stk-line.cost-vat-rubl       = buf_temp-aht-stk-line.cost-vat-rubl       + p-sign * buf_aht-stk-line.cost-vat-rubl            buf_temp-aht-stk-line.cost-slt-base       = buf_temp-aht-stk-line.cost-slt-base       + p-sign * buf_aht-stk-line.cost-slt-base            buf_temp-aht-stk-line.cost-slt-rubl       = buf_temp-aht-stk-line.cost-slt-rubl       + p-sign * buf_aht-stk-line.cost-slt-rubl            buf_temp-aht-stk-line.cost-road-tax-base  = buf_temp-aht-stk-line.cost-road-tax-base  + p-sign * buf_aht-stk-line.cost-road-tax-base       buf_temp-aht-stk-line.cost-road-tax-rubl  = buf_temp-aht-stk-line.cost-road-tax-rubl  + p-sign * buf_aht-stk-line.cost-road-tax-rubl       buf_temp-aht-stk-line.cost-excise-base    = buf_temp-aht-stk-line.cost-excise-base    + p-sign * buf_aht-stk-line.cost-excise-base         buf_temp-aht-stk-line.cost-excise-rubl    = buf_temp-aht-stk-line.cost-excise-rubl    + p-sign * buf_aht-stk-line.cost-excise-rubl         buf_temp-aht-stk-line.cost-transport-base = buf_temp-aht-stk-line.cost-transport-base + p-sign * buf_aht-stk-line.cost-transport-base      buf_temp-aht-stk-line.cost-transport-rubl = buf_temp-aht-stk-line.cost-transport-rubl + p-sign * buf_aht-stk-line.cost-transport-rubl      buf_temp-aht-stk-line.cost-other-base     = buf_temp-aht-stk-line.cost-other-base     + p-sign * buf_aht-stk-line.cost-other-base          buf_temp-aht-stk-line.cost-other-rubl     = buf_temp-aht-stk-line.cost-other-rubl     + p-sign * buf_aht-stk-line.cost-other-rubl          buf_temp-aht-stk-line.cost-discnt-base    = buf_temp-aht-stk-line.cost-discnt-base    + p-sign * buf_aht-stk-line.cost-discnt-base          buf_temp-aht-stk-line.cost-discnt-rubl    = buf_temp-aht-stk-line.cost-discnt-rubl    + p-sign * buf_aht-stk-line.cost-discnt-rubl
                                                                        buf_temp-aht-stk-line.crsa-sum-base       = buf_temp-aht-stk-line.crsa-sum-base       + p-sign * buf_aht-stk-line.crsa-sum-base            buf_temp-aht-stk-line.crsa-sum-rubl       = buf_temp-aht-stk-line.crsa-sum-rubl       + p-sign * buf_aht-stk-line.crsa-sum-rubl            buf_temp-aht-stk-line.crsa-vat-base       = buf_temp-aht-stk-line.crsa-vat-base       + p-sign * buf_aht-stk-line.crsa-vat-base            buf_temp-aht-stk-line.crsa-vat-rubl       = buf_temp-aht-stk-line.crsa-vat-rubl       + p-sign * buf_aht-stk-line.crsa-vat-rubl            buf_temp-aht-stk-line.crsa-slt-base       = buf_temp-aht-stk-line.crsa-slt-base       + p-sign * buf_aht-stk-line.crsa-slt-base            buf_temp-aht-stk-line.crsa-slt-rubl       = buf_temp-aht-stk-line.crsa-slt-rubl       + p-sign * buf_aht-stk-line.crsa-slt-rubl            buf_temp-aht-stk-line.crsa-road-tax-base  = buf_temp-aht-stk-line.crsa-road-tax-base  + p-sign * buf_aht-stk-line.crsa-road-tax-base       buf_temp-aht-stk-line.crsa-road-tax-rubl  = buf_temp-aht-stk-line.crsa-road-tax-rubl  + p-sign * buf_aht-stk-line.crsa-road-tax-rubl       buf_temp-aht-stk-line.crsa-excise-base    = buf_temp-aht-stk-line.crsa-excise-base    + p-sign * buf_aht-stk-line.crsa-excise-base         buf_temp-aht-stk-line.crsa-excise-rubl    = buf_temp-aht-stk-line.crsa-excise-rubl    + p-sign * buf_aht-stk-line.crsa-excise-rubl         buf_temp-aht-stk-line.crsa-transport-base = buf_temp-aht-stk-line.crsa-transport-base + p-sign * buf_aht-stk-line.crsa-transport-base      buf_temp-aht-stk-line.crsa-transport-rubl = buf_temp-aht-stk-line.crsa-transport-rubl + p-sign * buf_aht-stk-line.crsa-transport-rubl      buf_temp-aht-stk-line.crsa-other-base     = buf_temp-aht-stk-line.crsa-other-base     + p-sign * buf_aht-stk-line.crsa-other-base          buf_temp-aht-stk-line.crsa-other-rubl     = buf_temp-aht-stk-line.crsa-other-rubl     + p-sign * buf_aht-stk-line.crsa-other-rubl          buf_temp-aht-stk-line.crsa-discnt-base    = buf_temp-aht-stk-line.crsa-discnt-base    + p-sign * buf_aht-stk-line.crsa-discnt-base          buf_temp-aht-stk-line.crsa-discnt-rubl    = buf_temp-aht-stk-line.crsa-discnt-rubl    + p-sign * buf_aht-stk-line.crsa-discnt-rubl
                                                                        buf_temp-aht-stk-line.sale-sum-base       = buf_temp-aht-stk-line.sale-sum-base       + p-sign * buf_aht-stk-line.sale-sum-base            buf_temp-aht-stk-line.sale-sum-rubl       = buf_temp-aht-stk-line.sale-sum-rubl       + p-sign * buf_aht-stk-line.sale-sum-rubl            buf_temp-aht-stk-line.sale-vat-base       = buf_temp-aht-stk-line.sale-vat-base       + p-sign * buf_aht-stk-line.sale-vat-base            buf_temp-aht-stk-line.sale-vat-rubl       = buf_temp-aht-stk-line.sale-vat-rubl       + p-sign * buf_aht-stk-line.sale-vat-rubl            buf_temp-aht-stk-line.sale-slt-base       = buf_temp-aht-stk-line.sale-slt-base       + p-sign * buf_aht-stk-line.sale-slt-base            buf_temp-aht-stk-line.sale-slt-rubl       = buf_temp-aht-stk-line.sale-slt-rubl       + p-sign * buf_aht-stk-line.sale-slt-rubl            buf_temp-aht-stk-line.sale-road-tax-base  = buf_temp-aht-stk-line.sale-road-tax-base  + p-sign * buf_aht-stk-line.sale-road-tax-base       buf_temp-aht-stk-line.sale-road-tax-rubl  = buf_temp-aht-stk-line.sale-road-tax-rubl  + p-sign * buf_aht-stk-line.sale-road-tax-rubl       buf_temp-aht-stk-line.sale-excise-base    = buf_temp-aht-stk-line.sale-excise-base    + p-sign * buf_aht-stk-line.sale-excise-base         buf_temp-aht-stk-line.sale-excise-rubl    = buf_temp-aht-stk-line.sale-excise-rubl    + p-sign * buf_aht-stk-line.sale-excise-rubl         buf_temp-aht-stk-line.sale-transport-base = buf_temp-aht-stk-line.sale-transport-base + p-sign * buf_aht-stk-line.sale-transport-base      buf_temp-aht-stk-line.sale-transport-rubl = buf_temp-aht-stk-line.sale-transport-rubl + p-sign * buf_aht-stk-line.sale-transport-rubl      buf_temp-aht-stk-line.sale-other-base     = buf_temp-aht-stk-line.sale-other-base     + p-sign * buf_aht-stk-line.sale-other-base          buf_temp-aht-stk-line.sale-other-rubl     = buf_temp-aht-stk-line.sale-other-rubl     + p-sign * buf_aht-stk-line.sale-other-rubl          buf_temp-aht-stk-line.sale-discnt-base    = buf_temp-aht-stk-line.sale-discnt-base    + p-sign * buf_aht-stk-line.sale-discnt-base          buf_temp-aht-stk-line.sale-discnt-rubl    = buf_temp-aht-stk-line.sale-discnt-rubl    + p-sign * buf_aht-stk-line.sale-discnt-rubl
      .
    end.
    else do:
      assign
        v-create-stk = true
      .
      find first buf_temp-aht-stk-line
        where buf_temp-aht-stk-line.obj-type   = p-obj-type
          and buf_temp-aht-stk-line.obj-code   = p-obj-code
          and buf_temp-aht-stk-line.gds-code   = p-gds-code
          and buf_temp-aht-stk-line.fact-order = p-create-line-fact-order
          and buf_temp-aht-stk-line.sum-type   = p-sum-type
        no-error .
      if not available buf_temp-aht-stk-line
      then do:
        create buf_temp-aht-stk-line .
        assign
          buf_temp-aht-stk-line.obj-type   = p-obj-type
          buf_temp-aht-stk-line.obj-code   = p-obj-code
          buf_temp-aht-stk-line.gds-code   = p-gds-code
          buf_temp-aht-stk-line.sum-type   = p-sum-type
          buf_temp-aht-stk-line.fact-order = p-create-line-fact-order
        .
      end.
    end.
    if p-sign = 1
    then do:
      create buf_temp-create-aht-stk-line .
      assign
        buf_temp-create-aht-stk-line.obj-type    = p-obj-type
        buf_temp-create-aht-stk-line.obj-code    = p-obj-code
        buf_temp-create-aht-stk-line.gds-code    = p-gds-code
        buf_temp-create-aht-stk-line.sum-type    = p-sum-type
        buf_temp-create-aht-stk-line.need-create = v-create-stk
      .
    end.
  end.
end procedure.
procedure ahrstutl-create-stk :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define variable v-shift-on                as logical   no-undo .
  define variable v-shift-date              as date      no-undo .
  define variable v-shift-num               as integer   no-undo .
  define variable v-day-end-fact-order      as decimal   no-undo .
  define variable v-shift-end-fact-order    as decimal   no-undo .
  define buffer buf_temp-create-aht-stk-tot  for temp-create-aht-stk-tot .
  define buffer buf_temp-create-aht-stk-line for temp-create-aht-stk-line .
  define buffer buf_temp-aht-stk-tot for temp-aht-stk-tot .
  define buffer buf_aht-stk-tot for ub.aht-stk-tot .
  define buffer buf_temp-aht-stk-line for temp-aht-stk-line .
  define buffer buf_aht-stk-line for ub.aht-stk-line .
  do
  on error undo, return error return-value
  :
    run factord-cut-archive in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-fact-date
      ,output v-shift-on
      ,output v-shift-date
      ,output v-shift-num
      ,output v-day-end-fact-order
      ,output v-shift-end-fact-order
      ) .
    run show-action in this-procedure
      (input "Создание остатка на текущую дату"
      ).
    define variable v-total-count as integer   no-undo .
    for each buf_temp-create-aht-stk-tot
      where buf_temp-create-aht-stk-tot.need-create = true
    on error undo, return error return-value
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input ""
          ).
      end.
      for each buf_temp-aht-stk-tot
        where buf_temp-aht-stk-tot.obj-type   = buf_temp-create-aht-stk-tot.obj-type
          and buf_temp-aht-stk-tot.obj-code   = buf_temp-create-aht-stk-tot.obj-code
          and buf_temp-aht-stk-tot.fact-order = v-day-end-fact-order
          and buf_temp-aht-stk-tot.sum-type   = buf_temp-create-aht-stk-tot.sum-type
      on error undo, return error return-value
      :
        create buf_aht-stk-tot .
        buffer-copy buf_temp-aht-stk-tot to buf_aht-stk-tot
        .
      end.
    end.
    assign
      v-total-count = 0
    .
    for each buf_temp-create-aht-stk-line
      where buf_temp-create-aht-stk-line.need-create = true
    on error undo, return error return-value
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Код товара " + string(buf_temp-create-aht-stk-line.gds-code)
          ).
      end.
      for each buf_temp-aht-stk-line
        where buf_temp-aht-stk-line.obj-type   = buf_temp-create-aht-stk-line.obj-type
          and buf_temp-aht-stk-line.obj-code   = buf_temp-create-aht-stk-line.obj-code
          and buf_temp-aht-stk-line.gds-code   = buf_temp-create-aht-stk-line.gds-code
          and buf_temp-aht-stk-line.fact-order = v-day-end-fact-order
          and buf_temp-aht-stk-line.sum-type   = buf_temp-create-aht-stk-line.sum-type
      on error undo, return error return-value
      :
        create buf_aht-stk-line .
        buffer-copy buf_temp-aht-stk-line to buf_aht-stk-line
        .
      end.
    end.
  end.
end procedure.
procedure ahrstutl-clear-aht :
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-start-fact-order as decimal   no-undo .
  define input  parameter p-fact-date        as date      no-undo .
  define buffer buf_aht-doc      for ub.aht-doc .
  define buffer buf_aht-stk      for ub.aht-stk .
  define buffer buf_aht-ot-tot   for ub.aht-ot-tot .
  define buffer buf_aht-ot-line  for ub.aht-ot-line .
  define buffer buf_aht-stk-tot  for ub.aht-stk-tot .
  define buffer buf_aht-stk-line for ub.aht-stk-line .
  define variable v-shift-on                as logical   no-undo .
  define variable v-shift-date              as date      no-undo .
  define variable v-shift-num               as integer   no-undo .
  define variable v-day-end-fact-order      as decimal   no-undo .
  define variable v-shift-end-fact-order    as decimal   no-undo .
  define variable v-ind as integer no-undo .
  do
  on error undo, return error return-value
  :
    run factord-cut-archive in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-fact-date
      ,output v-shift-on
      ,output v-shift-date
      ,output v-shift-num
      ,output v-day-end-fact-order
      ,output v-shift-end-fact-order
      ) .
    assign
      v-day-end-fact-order   = v-day-end-fact-order   - 0.0000000001
      v-shift-end-fact-order = v-shift-end-fact-order - 0.0000000001
    .
    run show-action in this-procedure
      (input "Удаление информации о наличии документов"
      ).
    for each buf_aht-doc
      where buf_aht-doc.obj-type   = p-obj-type
        and buf_aht-doc.obj-code   = p-obj-code
        and buf_aht-doc.fact-order > p-start-fact-order
        and buf_aht-doc.fact-order <= v-day-end-fact-order
    on error undo, return error
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_aht-doc.doc-code)
          ).
      end.
      delete buf_aht-doc .
    end.
    run show-action in this-procedure
      (input "Удаление информации о наличии остатков по объекту"
      ).
    for each buf_aht-stk
      where buf_aht-stk.obj-type   = p-obj-type
        and buf_aht-stk.obj-code   = p-obj-code
        and buf_aht-stk.fact-order > p-start-fact-order
        and buf_aht-stk.fact-order <= v-day-end-fact-order
    on error undo, return error
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Дата " + string(buf_aht-stk.fact-date)
          ).
      end.
      delete buf_aht-stk .
    end.
    run show-action in this-procedure
      (input "Удаление оборота по документам"
      ).
    assign
      v-ind = 0
    .
    for each buf_aht-ot-tot
      where buf_aht-ot-tot.obj-type   = p-obj-type
        and buf_aht-ot-tot.obj-code   = p-obj-code
        and buf_aht-ot-tot.fact-order > p-start-fact-order
        and buf_aht-ot-tot.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_aht-ot-tot.doc-code)
          ).
      end.
      delete buf_aht-ot-tot .
    end.
    run show-action in this-procedure
      (input "Удаление оборота по строкам документов"
      ).
    assign
      v-ind = 0
    .
    for each buf_aht-ot-line
      where buf_aht-ot-line.obj-type   = p-obj-type
        and buf_aht-ot-line.obj-code   = p-obj-code
        and buf_aht-ot-line.fact-order > p-start-fact-order
        and buf_aht-ot-line.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_aht-ot-line.doc-code)
                  + " Код товара " + string(buf_aht-ot-line.gds-code)
          ).
      end.
      delete buf_aht-ot-line .
    end.
    run show-action in this-procedure
      (input "Удаление остатка по объекту"
      ).
    assign
      v-ind = 0
    .
    for each buf_aht-stk-tot
      where buf_aht-stk-tot.obj-type   = p-obj-type
        and buf_aht-stk-tot.obj-code   = p-obj-code
        and buf_aht-stk-tot.fact-order > p-start-fact-order
        and buf_aht-stk-tot.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        define variable v-fact-date as date      no-undo .
        run factord-to-date in this-procedure
          (input  buf_aht-stk-tot.fact-order
          ,output v-fact-date
          ) .
        run show-count in this-procedure
          (input v-ind
          ,input "Дата " + string(v-fact-date, '99/99/9999':U )
          ).
      end.
      delete buf_aht-stk-tot .
    end.
    run show-action in this-procedure
      (input "Удаление остатка по товарам на объекте"
      ).
    assign
      v-ind = 0
    .
    for each buf_aht-stk-line
      where buf_aht-stk-line.obj-type   = p-obj-type
        and buf_aht-stk-line.obj-code   = p-obj-code
        and buf_aht-stk-line.fact-order > p-start-fact-order
        and buf_aht-stk-line.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Код товара " + string(buf_aht-stk-line.gds-code)
          ).
      end.
      delete buf_aht-stk-line .
    end.
  end.
end procedure.
procedure ahrstutl-delete-copy :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define buffer buf_aht-stk-tot  for ub.aht-stk-tot .
  define buffer buf_aht-stk-line for ub.aht-stk-line .
  define buffer buf_temp-create-aht-stk-tot for temp-create-aht-stk-tot .
  define buffer buf_temp-create-aht-stk-line for temp-create-aht-stk-line .
  define variable v-shift-on                as logical   no-undo .
  define variable v-shift-date              as date      no-undo .
  define variable v-shift-num               as integer   no-undo .
  define variable v-day-end-fact-order      as decimal   no-undo .
  define variable v-shift-end-fact-order    as decimal   no-undo .
  define variable v-ind as integer no-undo .
  do
  on error undo, return error return-value
  :
    run factord-cut-archive in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-fact-date
      ,output v-shift-on
      ,output v-shift-date
      ,output v-shift-num
      ,output v-day-end-fact-order
      ,output v-shift-end-fact-order
      ) .
    run show-action in this-procedure
      (input "Удаление повторных остатков"
      ).
    define variable v-total-count as integer   no-undo .
    assign
      v-total-count = 0
    .
    for each buf_temp-create-aht-stk-tot
    on error undo, return error return-value
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Остатки по объекту"
          ).
      end.
      find last buf_aht-stk-tot exclusive-lock
        where buf_aht-stk-tot.obj-type   = buf_temp-create-aht-stk-tot.obj-type
          and buf_aht-stk-tot.obj-code   = buf_temp-create-aht-stk-tot.obj-code
          and buf_aht-stk-tot.fact-order = v-day-end-fact-order - 0.0000000001
          and buf_aht-stk-tot.sum-type   = buf_temp-create-aht-stk-tot.sum-type
        no-error .
      if available buf_aht-stk-tot
      then do:
        delete buf_aht-stk-tot .
      end.
      else do:
        for each buf_aht-stk-tot exclusive-lock
          where buf_aht-stk-tot.obj-type   = buf_temp-create-aht-stk-tot.obj-type
            and buf_aht-stk-tot.obj-code   = buf_temp-create-aht-stk-tot.obj-code
            and buf_aht-stk-tot.fact-order = v-day-end-fact-order
            and buf_aht-stk-tot.sum-type   = buf_temp-create-aht-stk-tot.sum-type
        on error undo, return error return-value
        :
          delete buf_aht-stk-tot .
        end.
      end.
    end.
    assign
      v-total-count = 0
    .
    for each buf_temp-create-aht-stk-line
    on error undo, return error return-value
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Код товара " + string(buf_temp-create-aht-stk-line.gds-code)
          ).
      end.
      find first buf_aht-stk-line exclusive-lock
        where buf_aht-stk-line.obj-type   = buf_temp-create-aht-stk-line.obj-type
          and buf_aht-stk-line.obj-code   = buf_temp-create-aht-stk-line.obj-code
          and buf_aht-stk-line.gds-code   = buf_temp-create-aht-stk-line.gds-code
          and buf_aht-stk-line.fact-order = v-day-end-fact-order - 0.0000000001
          and buf_aht-stk-line.sum-type   = buf_temp-create-aht-stk-line.sum-type
        no-error .
      if available buf_aht-stk-line
      then do:
        delete buf_aht-stk-line .
      end.
      else do:
        for each buf_aht-stk-line exclusive-lock
          where buf_aht-stk-line.obj-type   = buf_temp-create-aht-stk-line.obj-type
            and buf_aht-stk-line.obj-code   = buf_temp-create-aht-stk-line.obj-code
            and buf_aht-stk-line.gds-code   = buf_temp-create-aht-stk-line.gds-code
            and buf_aht-stk-line.fact-order = v-day-end-fact-order
            and buf_aht-stk-line.sum-type   = buf_temp-create-aht-stk-line.sum-type
        on error undo, return error return-value
        :
          delete buf_aht-stk-line .
        end.
      end.
    end.
    define buffer buf_gds-obj for ub.gds-obj .
    define buffer buf_doclslib-goods for doclslib-goods .
    for each buf_gds-obj no-lock
      where buf_gds-obj.obj-type = p-obj-type
        and buf_gds-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      find first buf_doclslib-goods
        where buf_doclslib-goods.artic     = buf_gds-obj.artic
          and buf_doclslib-goods.prod-type = buf_gds-obj.prod-type
          and buf_doclslib-goods.prod-code = buf_gds-obj.prod-code
        no-error .
      if not available buf_doclslib-goods
      then do:
        for each buf_aht-stk-line exclusive-lock
          where buf_aht-stk-line.obj-type   = buf_gds-obj.obj-type
            and buf_aht-stk-line.obj-code   = buf_gds-obj.obj-code
            and buf_aht-stk-line.gds-code   = buf_gds-obj.gds-code
            and buf_aht-stk-line.fact-order = v-day-end-fact-order
        on error undo, return error return-value
        :
          delete buf_aht-stk-line .
        end.
      end.
    end.
  end.
end procedure.
procedure ahrstutl-update :
  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-first-cut-date     as date      no-undo .
  define input  parameter p-last-cut-date      as date      no-undo .
  define buffer buf_doclslib-goods for doclslib-goods .
  define variable v-shift-on                   as logical   no-undo .
  define variable v-first-shift-date           as date      no-undo .
  define variable v-first-shift-num            as integer   no-undo .
  define variable v-first-day-end-fact-order   as decimal   no-undo .
  define variable v-first-shift-end-fact-order as decimal   no-undo .
  define variable v-last-shift-date            as date      no-undo .
  define variable v-last-shift-num             as integer   no-undo .
  define variable v-last-day-end-fact-order    as decimal   no-undo .
  define variable v-last-shift-end-fact-order  as decimal   no-undo .
  define variable v-gds-goods     as logical   no-undo .
  define variable v-sum-type-list as character no-undo .
  define variable v-ind           as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run factord-cut-archive in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-first-cut-date
      ,output v-shift-on
      ,output v-first-shift-date
      ,output v-first-shift-num
      ,output v-first-day-end-fact-order
      ,output v-first-shift-end-fact-order
      ) .
    run factord-cut-archive in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-last-cut-date
      ,output v-shift-on
      ,output v-last-shift-date
      ,output v-last-shift-num
      ,output v-last-day-end-fact-order
      ,output v-last-shift-end-fact-order
      ) .
    run show-action in this-procedure
      (input "Пересчитываем остаток по объекту"
      ).
    define buffer buf_aht-stk-tot for ub.aht-stk-tot .
    run ahrstutl-tot-sum-type-list in this-procedure
      (output v-sum-type-list
      ) .
    do v-ind = 1 to num-entries(v-sum-type-list)
    :
      run ahrstutl-store-tot in this-procedure
        (input p-obj-type
        ,input p-obj-code
        ,input entry(v-ind, v-sum-type-list)
        ,input v-first-day-end-fact-order
        ,input v-last-day-end-fact-order
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры" 'ahrstutl-store-tot':u skip
          "v-ind" v-ind skip
          "sum-type" entry(v-ind, v-sum-type-list) skip
          return-value skip
          error-status :get-message(1) skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    run show-action in this-procedure
      (input "Пересчитываем остаток по товару"
      ).
    define variable v-total-count as integer   no-undo .
    for each buf_doclslib-goods no-lock
    on error undo, return error return-value
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Артикул " + string(buf_doclslib-goods.artic)
          ).
      end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  buf_doclslib-goods.gds-code
  ,input  'gds-goods=request':u
  ,output v-gds-goods
  ) no-error .
      run ahrstutl-line-sum-type-list in this-procedure
        (input  v-gds-goods
        ,output v-sum-type-list
        ) .
      do v-ind = 1 to num-entries(v-sum-type-list)
      :
        run ahrstutl-store-line in this-procedure
          (input p-obj-type
          ,input p-obj-code
          ,input buf_doclslib-goods.gds-code
          ,input entry(v-ind, v-sum-type-list)
          ,input v-first-day-end-fact-order
          ,input v-last-day-end-fact-order
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры" 'ahrstutl-store-line':u skip
            "Объект" p-obj-type p-obj-code skip
            "Артикул" buf_doclslib-goods.artic buf_doclslib-goods.prod-type buf_doclslib-goods.prod-code skip
            "Код товара" buf_doclslib-goods.gds-code skip
            return-value skip
            error-status :get-message(1) skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
    end.
  end.
end procedure.
procedure ahrstutl-tot-sum-type-list :
  define output parameter p-sum-type-list as character no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-ind                    as integer   no-undo .
    define variable v-num-entries-TDEDT_List as integer   no-undo .
    assign
      v-num-entries-TDEDT_List = num-entries('ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
    .
    assign
      p-sum-type-list =                 'r':U
                      + chr(44) + 'c':U
                      + chr(44) + 'b':U
                      + chr(44) + 's':U
                      + chr(44) + 'o':U
                      + chr(44) + 'v':U
    .
    define variable v-ext-sum-type as character no-undo .
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      run aht_get-stk-sum-type in this-procedure
        (input  'r':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
      .
      run aht_get-stk-sum-type in this-procedure
        (input  'c':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
      .
      run aht_get-stk-sum-type in this-procedure
        (input  'b':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
      .
      run aht_get-stk-sum-type in this-procedure
        (input  's':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
      .
      run aht_get-stk-sum-type in this-procedure
        (input  'o':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
      .
      run aht_get-stk-sum-type in this-procedure
        (input  'v':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
      .
    end.
  end.
end procedure.
procedure ahrstutl-line-sum-type-list :
  define input  parameter p-gds-goods     as logical   no-undo .
  define output parameter p-sum-type-list as character no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-ind                    as integer   no-undo .
    define variable v-num-entries-TDEDT_List as integer   no-undo .
    assign
      v-num-entries-TDEDT_List = num-entries('ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
    .
    assign
      p-sum-type-list =                 'r':U
                      + chr(44) + 'c':U
                      + chr(44) + 'b':U
                      + chr(44) + 's':U
                      + chr(44) + 'o':U
                      + chr(44) + 'v':U
    .
    define variable v-ext-sum-type as character no-undo .
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      run aht_get-stk-sum-type in this-procedure
        (input  'r':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
      .
      run aht_get-stk-sum-type in this-procedure
        (input  'c':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
      .
      run aht_get-stk-sum-type in this-procedure
        (input  'b':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
      .
      run aht_get-stk-sum-type in this-procedure
        (input  's':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
      .
      run aht_get-stk-sum-type in this-procedure
        (input  'o':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
      .
      run aht_get-stk-sum-type in this-procedure
        (input  'v':U
        ,input  entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
        ,output v-ext-sum-type
        ) .
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + v-ext-sum-type
      .
    end.
  end.
end procedure.
procedure ahrstutl-store-tot :
  define input  parameter p-obj-type                   as character no-undo .
  define input  parameter p-obj-code                   as integer   no-undo .
  define input  parameter p-sum-type                   as character no-undo .
  define input  parameter p-first-day-end-fact-order   as decimal   no-undo .
  define input  parameter p-last-day-end-fact-order    as decimal   no-undo .
  define buffer buf_aht-stk-tot for ub.aht-stk-tot .
  define buffer buf_temp-aht-stk-tot for temp-aht-stk-tot .
  do
  on error undo, return error return-value
  :
    for each buf_temp-aht-stk-tot
      where buf_temp-aht-stk-tot.obj-type = p-obj-type
        and buf_temp-aht-stk-tot.obj-code = p-obj-code
        and buf_temp-aht-stk-tot.sum-type = p-sum-type
    on error undo, return error return-value
    :
      if buf_temp-aht-stk-tot.fact-qnty <> 0
      or
                              buf_temp-aht-stk-tot.cost-sum-base       <> 0 or    buf_temp-aht-stk-tot.cost-sum-rubl       <> 0 or    buf_temp-aht-stk-tot.cost-vat-base       <> 0 or    buf_temp-aht-stk-tot.cost-vat-rubl       <> 0 or    buf_temp-aht-stk-tot.cost-slt-base       <> 0 or    buf_temp-aht-stk-tot.cost-slt-rubl       <> 0 or    buf_temp-aht-stk-tot.cost-road-tax-base  <> 0 or    buf_temp-aht-stk-tot.cost-road-tax-rubl  <> 0 or    buf_temp-aht-stk-tot.cost-excise-base    <> 0 or    buf_temp-aht-stk-tot.cost-excise-rubl    <> 0 or    buf_temp-aht-stk-tot.cost-transport-base <> 0 or    buf_temp-aht-stk-tot.cost-transport-rubl <> 0 or    buf_temp-aht-stk-tot.cost-other-base     <> 0 or    buf_temp-aht-stk-tot.cost-other-rubl     <> 0 or    buf_temp-aht-stk-tot.cost-discnt-base    <> 0 or    buf_temp-aht-stk-tot.cost-discnt-rubl    <> 0
      or
                              buf_temp-aht-stk-tot.crsa-sum-base       <> 0 or    buf_temp-aht-stk-tot.crsa-sum-rubl       <> 0 or    buf_temp-aht-stk-tot.crsa-vat-base       <> 0 or    buf_temp-aht-stk-tot.crsa-vat-rubl       <> 0 or    buf_temp-aht-stk-tot.crsa-slt-base       <> 0 or    buf_temp-aht-stk-tot.crsa-slt-rubl       <> 0 or    buf_temp-aht-stk-tot.crsa-road-tax-base  <> 0 or    buf_temp-aht-stk-tot.crsa-road-tax-rubl  <> 0 or    buf_temp-aht-stk-tot.crsa-excise-base    <> 0 or    buf_temp-aht-stk-tot.crsa-excise-rubl    <> 0 or    buf_temp-aht-stk-tot.crsa-transport-base <> 0 or    buf_temp-aht-stk-tot.crsa-transport-rubl <> 0 or    buf_temp-aht-stk-tot.crsa-other-base     <> 0 or    buf_temp-aht-stk-tot.crsa-other-rubl     <> 0 or    buf_temp-aht-stk-tot.crsa-discnt-base    <> 0 or    buf_temp-aht-stk-tot.crsa-discnt-rubl    <> 0
      or
                              buf_temp-aht-stk-tot.sale-sum-base       <> 0 or    buf_temp-aht-stk-tot.sale-sum-rubl       <> 0 or    buf_temp-aht-stk-tot.sale-vat-base       <> 0 or    buf_temp-aht-stk-tot.sale-vat-rubl       <> 0 or    buf_temp-aht-stk-tot.sale-slt-base       <> 0 or    buf_temp-aht-stk-tot.sale-slt-rubl       <> 0 or    buf_temp-aht-stk-tot.sale-road-tax-base  <> 0 or    buf_temp-aht-stk-tot.sale-road-tax-rubl  <> 0 or    buf_temp-aht-stk-tot.sale-excise-base    <> 0 or    buf_temp-aht-stk-tot.sale-excise-rubl    <> 0 or    buf_temp-aht-stk-tot.sale-transport-base <> 0 or    buf_temp-aht-stk-tot.sale-transport-rubl <> 0 or    buf_temp-aht-stk-tot.sale-other-base     <> 0 or    buf_temp-aht-stk-tot.sale-other-rubl     <> 0 or    buf_temp-aht-stk-tot.sale-discnt-base    <> 0 or    buf_temp-aht-stk-tot.sale-discnt-rubl    <> 0
      then do:
        find first buf_aht-stk-tot exclusive-lock
          where buf_aht-stk-tot.obj-type   = buf_temp-aht-stk-tot.obj-type
            and buf_aht-stk-tot.obj-code   = buf_temp-aht-stk-tot.obj-code
            and buf_aht-stk-tot.sum-type   = buf_temp-aht-stk-tot.sum-type
            and buf_aht-stk-tot.fact-order <= p-first-day-end-fact-order
          no-error .
        if not available buf_aht-stk-tot
        then do:
          create buf_aht-stk-tot .
          assign
            buf_aht-stk-tot.obj-type   = buf_temp-aht-stk-tot.obj-type
            buf_aht-stk-tot.obj-code   = buf_temp-aht-stk-tot.obj-code
            buf_aht-stk-tot.fact-order = p-first-day-end-fact-order
            buf_aht-stk-tot.sum-type   = buf_temp-aht-stk-tot.sum-type
          .
        end.
        for each buf_aht-stk-tot exclusive-lock
          where buf_aht-stk-tot.obj-type   = buf_temp-aht-stk-tot.obj-type
            and buf_aht-stk-tot.obj-code   = buf_temp-aht-stk-tot.obj-code
            and buf_aht-stk-tot.sum-type   = buf_temp-aht-stk-tot.sum-type
            and buf_aht-stk-tot.fact-order <= p-last-day-end-fact-order - 0.0000000001
        on error undo, return error return-value
        :
          assign
            buf_aht-stk-tot.fact-qnty = buf_aht-stk-tot.fact-qnty
                                      + buf_temp-aht-stk-tot.fact-qnty
                                                                                                            buf_aht-stk-tot.cost-sum-base       = buf_aht-stk-tot.cost-sum-base       + buf_temp-aht-stk-tot.cost-sum-base            buf_aht-stk-tot.cost-sum-rubl       = buf_aht-stk-tot.cost-sum-rubl       + buf_temp-aht-stk-tot.cost-sum-rubl            buf_aht-stk-tot.cost-vat-base       = buf_aht-stk-tot.cost-vat-base       + buf_temp-aht-stk-tot.cost-vat-base            buf_aht-stk-tot.cost-vat-rubl       = buf_aht-stk-tot.cost-vat-rubl       + buf_temp-aht-stk-tot.cost-vat-rubl            buf_aht-stk-tot.cost-slt-base       = buf_aht-stk-tot.cost-slt-base       + buf_temp-aht-stk-tot.cost-slt-base            buf_aht-stk-tot.cost-slt-rubl       = buf_aht-stk-tot.cost-slt-rubl       + buf_temp-aht-stk-tot.cost-slt-rubl            buf_aht-stk-tot.cost-road-tax-base  = buf_aht-stk-tot.cost-road-tax-base  + buf_temp-aht-stk-tot.cost-road-tax-base       buf_aht-stk-tot.cost-road-tax-rubl  = buf_aht-stk-tot.cost-road-tax-rubl  + buf_temp-aht-stk-tot.cost-road-tax-rubl       buf_aht-stk-tot.cost-excise-base    = buf_aht-stk-tot.cost-excise-base    + buf_temp-aht-stk-tot.cost-excise-base         buf_aht-stk-tot.cost-excise-rubl    = buf_aht-stk-tot.cost-excise-rubl    + buf_temp-aht-stk-tot.cost-excise-rubl         buf_aht-stk-tot.cost-transport-base = buf_aht-stk-tot.cost-transport-base + buf_temp-aht-stk-tot.cost-transport-base      buf_aht-stk-tot.cost-transport-rubl = buf_aht-stk-tot.cost-transport-rubl + buf_temp-aht-stk-tot.cost-transport-rubl      buf_aht-stk-tot.cost-other-base     = buf_aht-stk-tot.cost-other-base     + buf_temp-aht-stk-tot.cost-other-base          buf_aht-stk-tot.cost-other-rubl     = buf_aht-stk-tot.cost-other-rubl     + buf_temp-aht-stk-tot.cost-other-rubl          buf_aht-stk-tot.cost-discnt-base    = buf_aht-stk-tot.cost-discnt-base    + buf_temp-aht-stk-tot.cost-discnt-base          buf_aht-stk-tot.cost-discnt-rubl    = buf_aht-stk-tot.cost-discnt-rubl    + buf_temp-aht-stk-tot.cost-discnt-rubl
                                                                                                            buf_aht-stk-tot.crsa-sum-base       = buf_aht-stk-tot.crsa-sum-base       + buf_temp-aht-stk-tot.crsa-sum-base            buf_aht-stk-tot.crsa-sum-rubl       = buf_aht-stk-tot.crsa-sum-rubl       + buf_temp-aht-stk-tot.crsa-sum-rubl            buf_aht-stk-tot.crsa-vat-base       = buf_aht-stk-tot.crsa-vat-base       + buf_temp-aht-stk-tot.crsa-vat-base            buf_aht-stk-tot.crsa-vat-rubl       = buf_aht-stk-tot.crsa-vat-rubl       + buf_temp-aht-stk-tot.crsa-vat-rubl            buf_aht-stk-tot.crsa-slt-base       = buf_aht-stk-tot.crsa-slt-base       + buf_temp-aht-stk-tot.crsa-slt-base            buf_aht-stk-tot.crsa-slt-rubl       = buf_aht-stk-tot.crsa-slt-rubl       + buf_temp-aht-stk-tot.crsa-slt-rubl            buf_aht-stk-tot.crsa-road-tax-base  = buf_aht-stk-tot.crsa-road-tax-base  + buf_temp-aht-stk-tot.crsa-road-tax-base       buf_aht-stk-tot.crsa-road-tax-rubl  = buf_aht-stk-tot.crsa-road-tax-rubl  + buf_temp-aht-stk-tot.crsa-road-tax-rubl       buf_aht-stk-tot.crsa-excise-base    = buf_aht-stk-tot.crsa-excise-base    + buf_temp-aht-stk-tot.crsa-excise-base         buf_aht-stk-tot.crsa-excise-rubl    = buf_aht-stk-tot.crsa-excise-rubl    + buf_temp-aht-stk-tot.crsa-excise-rubl         buf_aht-stk-tot.crsa-transport-base = buf_aht-stk-tot.crsa-transport-base + buf_temp-aht-stk-tot.crsa-transport-base      buf_aht-stk-tot.crsa-transport-rubl = buf_aht-stk-tot.crsa-transport-rubl + buf_temp-aht-stk-tot.crsa-transport-rubl      buf_aht-stk-tot.crsa-other-base     = buf_aht-stk-tot.crsa-other-base     + buf_temp-aht-stk-tot.crsa-other-base          buf_aht-stk-tot.crsa-other-rubl     = buf_aht-stk-tot.crsa-other-rubl     + buf_temp-aht-stk-tot.crsa-other-rubl          buf_aht-stk-tot.crsa-discnt-base    = buf_aht-stk-tot.crsa-discnt-base    + buf_temp-aht-stk-tot.crsa-discnt-base          buf_aht-stk-tot.crsa-discnt-rubl    = buf_aht-stk-tot.crsa-discnt-rubl    + buf_temp-aht-stk-tot.crsa-discnt-rubl
                                                                                                            buf_aht-stk-tot.sale-sum-base       = buf_aht-stk-tot.sale-sum-base       + buf_temp-aht-stk-tot.sale-sum-base            buf_aht-stk-tot.sale-sum-rubl       = buf_aht-stk-tot.sale-sum-rubl       + buf_temp-aht-stk-tot.sale-sum-rubl            buf_aht-stk-tot.sale-vat-base       = buf_aht-stk-tot.sale-vat-base       + buf_temp-aht-stk-tot.sale-vat-base            buf_aht-stk-tot.sale-vat-rubl       = buf_aht-stk-tot.sale-vat-rubl       + buf_temp-aht-stk-tot.sale-vat-rubl            buf_aht-stk-tot.sale-slt-base       = buf_aht-stk-tot.sale-slt-base       + buf_temp-aht-stk-tot.sale-slt-base            buf_aht-stk-tot.sale-slt-rubl       = buf_aht-stk-tot.sale-slt-rubl       + buf_temp-aht-stk-tot.sale-slt-rubl            buf_aht-stk-tot.sale-road-tax-base  = buf_aht-stk-tot.sale-road-tax-base  + buf_temp-aht-stk-tot.sale-road-tax-base       buf_aht-stk-tot.sale-road-tax-rubl  = buf_aht-stk-tot.sale-road-tax-rubl  + buf_temp-aht-stk-tot.sale-road-tax-rubl       buf_aht-stk-tot.sale-excise-base    = buf_aht-stk-tot.sale-excise-base    + buf_temp-aht-stk-tot.sale-excise-base         buf_aht-stk-tot.sale-excise-rubl    = buf_aht-stk-tot.sale-excise-rubl    + buf_temp-aht-stk-tot.sale-excise-rubl         buf_aht-stk-tot.sale-transport-base = buf_aht-stk-tot.sale-transport-base + buf_temp-aht-stk-tot.sale-transport-base      buf_aht-stk-tot.sale-transport-rubl = buf_aht-stk-tot.sale-transport-rubl + buf_temp-aht-stk-tot.sale-transport-rubl      buf_aht-stk-tot.sale-other-base     = buf_aht-stk-tot.sale-other-base     + buf_temp-aht-stk-tot.sale-other-base          buf_aht-stk-tot.sale-other-rubl     = buf_aht-stk-tot.sale-other-rubl     + buf_temp-aht-stk-tot.sale-other-rubl          buf_aht-stk-tot.sale-discnt-base    = buf_aht-stk-tot.sale-discnt-base    + buf_temp-aht-stk-tot.sale-discnt-base          buf_aht-stk-tot.sale-discnt-rubl    = buf_aht-stk-tot.sale-discnt-rubl    + buf_temp-aht-stk-tot.sale-discnt-rubl
          .
        end.
      end.
    end.
  end.
end procedure.
procedure ahrstutl-store-line :
  define input  parameter p-obj-type                 as character no-undo .
  define input  parameter p-obj-code                 as integer   no-undo .
  define input  parameter p-gds-code                 as integer   no-undo .
  define input  parameter p-sum-type                 as character no-undo .
  define input  parameter p-first-day-end-fact-order as decimal   no-undo .
  define input  parameter p-last-day-end-fact-order  as decimal   no-undo .
  define buffer buf_aht-stk-line for ub.aht-stk-line .
  define buffer buf_temp-aht-stk-line for temp-aht-stk-line .
  do
  on error undo, return error return-value
  :
    for each buf_temp-aht-stk-line
      where buf_temp-aht-stk-line.obj-type  = p-obj-type
        and buf_temp-aht-stk-line.obj-code  = p-obj-code
        and buf_temp-aht-stk-line.gds-code  = p-gds-code
        and buf_temp-aht-stk-line.sum-type  = p-sum-type
    on error undo, return error return-value
    :
      if buf_temp-aht-stk-line.fact-qnty <> 0
      or
                              buf_temp-aht-stk-line.cost-sum-base       <> 0 or    buf_temp-aht-stk-line.cost-sum-rubl       <> 0 or    buf_temp-aht-stk-line.cost-vat-base       <> 0 or    buf_temp-aht-stk-line.cost-vat-rubl       <> 0 or    buf_temp-aht-stk-line.cost-slt-base       <> 0 or    buf_temp-aht-stk-line.cost-slt-rubl       <> 0 or    buf_temp-aht-stk-line.cost-road-tax-base  <> 0 or    buf_temp-aht-stk-line.cost-road-tax-rubl  <> 0 or    buf_temp-aht-stk-line.cost-excise-base    <> 0 or    buf_temp-aht-stk-line.cost-excise-rubl    <> 0 or    buf_temp-aht-stk-line.cost-transport-base <> 0 or    buf_temp-aht-stk-line.cost-transport-rubl <> 0 or    buf_temp-aht-stk-line.cost-other-base     <> 0 or    buf_temp-aht-stk-line.cost-other-rubl     <> 0 or    buf_temp-aht-stk-line.cost-discnt-base    <> 0 or    buf_temp-aht-stk-line.cost-discnt-rubl    <> 0
      or
                              buf_temp-aht-stk-line.crsa-sum-base       <> 0 or    buf_temp-aht-stk-line.crsa-sum-rubl       <> 0 or    buf_temp-aht-stk-line.crsa-vat-base       <> 0 or    buf_temp-aht-stk-line.crsa-vat-rubl       <> 0 or    buf_temp-aht-stk-line.crsa-slt-base       <> 0 or    buf_temp-aht-stk-line.crsa-slt-rubl       <> 0 or    buf_temp-aht-stk-line.crsa-road-tax-base  <> 0 or    buf_temp-aht-stk-line.crsa-road-tax-rubl  <> 0 or    buf_temp-aht-stk-line.crsa-excise-base    <> 0 or    buf_temp-aht-stk-line.crsa-excise-rubl    <> 0 or    buf_temp-aht-stk-line.crsa-transport-base <> 0 or    buf_temp-aht-stk-line.crsa-transport-rubl <> 0 or    buf_temp-aht-stk-line.crsa-other-base     <> 0 or    buf_temp-aht-stk-line.crsa-other-rubl     <> 0 or    buf_temp-aht-stk-line.crsa-discnt-base    <> 0 or    buf_temp-aht-stk-line.crsa-discnt-rubl    <> 0
      or
                              buf_temp-aht-stk-line.sale-sum-base       <> 0 or    buf_temp-aht-stk-line.sale-sum-rubl       <> 0 or    buf_temp-aht-stk-line.sale-vat-base       <> 0 or    buf_temp-aht-stk-line.sale-vat-rubl       <> 0 or    buf_temp-aht-stk-line.sale-slt-base       <> 0 or    buf_temp-aht-stk-line.sale-slt-rubl       <> 0 or    buf_temp-aht-stk-line.sale-road-tax-base  <> 0 or    buf_temp-aht-stk-line.sale-road-tax-rubl  <> 0 or    buf_temp-aht-stk-line.sale-excise-base    <> 0 or    buf_temp-aht-stk-line.sale-excise-rubl    <> 0 or    buf_temp-aht-stk-line.sale-transport-base <> 0 or    buf_temp-aht-stk-line.sale-transport-rubl <> 0 or    buf_temp-aht-stk-line.sale-other-base     <> 0 or    buf_temp-aht-stk-line.sale-other-rubl     <> 0 or    buf_temp-aht-stk-line.sale-discnt-base    <> 0 or    buf_temp-aht-stk-line.sale-discnt-rubl    <> 0
      then do:
        find first buf_aht-stk-line exclusive-lock
          where buf_aht-stk-line.obj-type   = buf_temp-aht-stk-line.obj-type
            and buf_aht-stk-line.obj-code   = buf_temp-aht-stk-line.obj-code
            and buf_aht-stk-line.gds-code   = buf_temp-aht-stk-line.gds-code
            and buf_aht-stk-line.sum-type   = buf_temp-aht-stk-line.sum-type
            and buf_aht-stk-line.fact-order <= p-first-day-end-fact-order
          no-error .
        if not available buf_aht-stk-line
        then do:
          create buf_aht-stk-line .
          assign
            buf_aht-stk-line.obj-type   = buf_temp-aht-stk-line.obj-type
            buf_aht-stk-line.obj-code   = buf_temp-aht-stk-line.obj-code
            buf_aht-stk-line.gds-code   = buf_temp-aht-stk-line.gds-code
            buf_aht-stk-line.fact-order = p-first-day-end-fact-order
            buf_aht-stk-line.sum-type   = buf_temp-aht-stk-line.sum-type
          .
        end.
        for each buf_aht-stk-line exclusive-lock
          where buf_aht-stk-line.obj-type   = buf_temp-aht-stk-line.obj-type
            and buf_aht-stk-line.obj-code   = buf_temp-aht-stk-line.obj-code
            and buf_aht-stk-line.gds-code   = buf_temp-aht-stk-line.gds-code
            and buf_aht-stk-line.sum-type   = buf_temp-aht-stk-line.sum-type
            and buf_aht-stk-line.fact-order <= p-last-day-end-fact-order - 0.0000000001
        on error undo, return error return-value
        :
          assign
            buf_aht-stk-line.fact-qnty = buf_aht-stk-line.fact-qnty
                                      + buf_temp-aht-stk-line.fact-qnty
                                                                                                            buf_aht-stk-line.cost-sum-base       = buf_aht-stk-line.cost-sum-base       + buf_temp-aht-stk-line.cost-sum-base            buf_aht-stk-line.cost-sum-rubl       = buf_aht-stk-line.cost-sum-rubl       + buf_temp-aht-stk-line.cost-sum-rubl            buf_aht-stk-line.cost-vat-base       = buf_aht-stk-line.cost-vat-base       + buf_temp-aht-stk-line.cost-vat-base            buf_aht-stk-line.cost-vat-rubl       = buf_aht-stk-line.cost-vat-rubl       + buf_temp-aht-stk-line.cost-vat-rubl            buf_aht-stk-line.cost-slt-base       = buf_aht-stk-line.cost-slt-base       + buf_temp-aht-stk-line.cost-slt-base            buf_aht-stk-line.cost-slt-rubl       = buf_aht-stk-line.cost-slt-rubl       + buf_temp-aht-stk-line.cost-slt-rubl            buf_aht-stk-line.cost-road-tax-base  = buf_aht-stk-line.cost-road-tax-base  + buf_temp-aht-stk-line.cost-road-tax-base       buf_aht-stk-line.cost-road-tax-rubl  = buf_aht-stk-line.cost-road-tax-rubl  + buf_temp-aht-stk-line.cost-road-tax-rubl       buf_aht-stk-line.cost-excise-base    = buf_aht-stk-line.cost-excise-base    + buf_temp-aht-stk-line.cost-excise-base         buf_aht-stk-line.cost-excise-rubl    = buf_aht-stk-line.cost-excise-rubl    + buf_temp-aht-stk-line.cost-excise-rubl         buf_aht-stk-line.cost-transport-base = buf_aht-stk-line.cost-transport-base + buf_temp-aht-stk-line.cost-transport-base      buf_aht-stk-line.cost-transport-rubl = buf_aht-stk-line.cost-transport-rubl + buf_temp-aht-stk-line.cost-transport-rubl      buf_aht-stk-line.cost-other-base     = buf_aht-stk-line.cost-other-base     + buf_temp-aht-stk-line.cost-other-base          buf_aht-stk-line.cost-other-rubl     = buf_aht-stk-line.cost-other-rubl     + buf_temp-aht-stk-line.cost-other-rubl          buf_aht-stk-line.cost-discnt-base    = buf_aht-stk-line.cost-discnt-base    + buf_temp-aht-stk-line.cost-discnt-base          buf_aht-stk-line.cost-discnt-rubl    = buf_aht-stk-line.cost-discnt-rubl    + buf_temp-aht-stk-line.cost-discnt-rubl
                                                                                                            buf_aht-stk-line.crsa-sum-base       = buf_aht-stk-line.crsa-sum-base       + buf_temp-aht-stk-line.crsa-sum-base            buf_aht-stk-line.crsa-sum-rubl       = buf_aht-stk-line.crsa-sum-rubl       + buf_temp-aht-stk-line.crsa-sum-rubl            buf_aht-stk-line.crsa-vat-base       = buf_aht-stk-line.crsa-vat-base       + buf_temp-aht-stk-line.crsa-vat-base            buf_aht-stk-line.crsa-vat-rubl       = buf_aht-stk-line.crsa-vat-rubl       + buf_temp-aht-stk-line.crsa-vat-rubl            buf_aht-stk-line.crsa-slt-base       = buf_aht-stk-line.crsa-slt-base       + buf_temp-aht-stk-line.crsa-slt-base            buf_aht-stk-line.crsa-slt-rubl       = buf_aht-stk-line.crsa-slt-rubl       + buf_temp-aht-stk-line.crsa-slt-rubl            buf_aht-stk-line.crsa-road-tax-base  = buf_aht-stk-line.crsa-road-tax-base  + buf_temp-aht-stk-line.crsa-road-tax-base       buf_aht-stk-line.crsa-road-tax-rubl  = buf_aht-stk-line.crsa-road-tax-rubl  + buf_temp-aht-stk-line.crsa-road-tax-rubl       buf_aht-stk-line.crsa-excise-base    = buf_aht-stk-line.crsa-excise-base    + buf_temp-aht-stk-line.crsa-excise-base         buf_aht-stk-line.crsa-excise-rubl    = buf_aht-stk-line.crsa-excise-rubl    + buf_temp-aht-stk-line.crsa-excise-rubl         buf_aht-stk-line.crsa-transport-base = buf_aht-stk-line.crsa-transport-base + buf_temp-aht-stk-line.crsa-transport-base      buf_aht-stk-line.crsa-transport-rubl = buf_aht-stk-line.crsa-transport-rubl + buf_temp-aht-stk-line.crsa-transport-rubl      buf_aht-stk-line.crsa-other-base     = buf_aht-stk-line.crsa-other-base     + buf_temp-aht-stk-line.crsa-other-base          buf_aht-stk-line.crsa-other-rubl     = buf_aht-stk-line.crsa-other-rubl     + buf_temp-aht-stk-line.crsa-other-rubl          buf_aht-stk-line.crsa-discnt-base    = buf_aht-stk-line.crsa-discnt-base    + buf_temp-aht-stk-line.crsa-discnt-base          buf_aht-stk-line.crsa-discnt-rubl    = buf_aht-stk-line.crsa-discnt-rubl    + buf_temp-aht-stk-line.crsa-discnt-rubl
                                                                                                            buf_aht-stk-line.sale-sum-base       = buf_aht-stk-line.sale-sum-base       + buf_temp-aht-stk-line.sale-sum-base            buf_aht-stk-line.sale-sum-rubl       = buf_aht-stk-line.sale-sum-rubl       + buf_temp-aht-stk-line.sale-sum-rubl            buf_aht-stk-line.sale-vat-base       = buf_aht-stk-line.sale-vat-base       + buf_temp-aht-stk-line.sale-vat-base            buf_aht-stk-line.sale-vat-rubl       = buf_aht-stk-line.sale-vat-rubl       + buf_temp-aht-stk-line.sale-vat-rubl            buf_aht-stk-line.sale-slt-base       = buf_aht-stk-line.sale-slt-base       + buf_temp-aht-stk-line.sale-slt-base            buf_aht-stk-line.sale-slt-rubl       = buf_aht-stk-line.sale-slt-rubl       + buf_temp-aht-stk-line.sale-slt-rubl            buf_aht-stk-line.sale-road-tax-base  = buf_aht-stk-line.sale-road-tax-base  + buf_temp-aht-stk-line.sale-road-tax-base       buf_aht-stk-line.sale-road-tax-rubl  = buf_aht-stk-line.sale-road-tax-rubl  + buf_temp-aht-stk-line.sale-road-tax-rubl       buf_aht-stk-line.sale-excise-base    = buf_aht-stk-line.sale-excise-base    + buf_temp-aht-stk-line.sale-excise-base         buf_aht-stk-line.sale-excise-rubl    = buf_aht-stk-line.sale-excise-rubl    + buf_temp-aht-stk-line.sale-excise-rubl         buf_aht-stk-line.sale-transport-base = buf_aht-stk-line.sale-transport-base + buf_temp-aht-stk-line.sale-transport-base      buf_aht-stk-line.sale-transport-rubl = buf_aht-stk-line.sale-transport-rubl + buf_temp-aht-stk-line.sale-transport-rubl      buf_aht-stk-line.sale-other-base     = buf_aht-stk-line.sale-other-base     + buf_temp-aht-stk-line.sale-other-base          buf_aht-stk-line.sale-other-rubl     = buf_aht-stk-line.sale-other-rubl     + buf_temp-aht-stk-line.sale-other-rubl          buf_aht-stk-line.sale-discnt-base    = buf_aht-stk-line.sale-discnt-base    + buf_temp-aht-stk-line.sale-discnt-base          buf_aht-stk-line.sale-discnt-rubl    = buf_aht-stk-line.sale-discnt-rubl    + buf_temp-aht-stk-line.sale-discnt-rubl
          .
        end.
      end.
    end.
  end.
end procedure.
procedure cb_rst-aht_overturn-exist :
  define input  parameter p-artic          as character no-undo .
  define input  parameter p-prod-type      as character no-undo .
  define input  parameter p-prod-code      as integer   no-undo .
  define output parameter p-overturn-exist as logical   no-undo .
  define buffer buf_doclslib-goods for doclslib-goods .
  do
  on error undo, return error return-value
  :
    find first buf_doclslib-goods
      where buf_doclslib-goods.artic     = p-artic
        and buf_doclslib-goods.prod-type = p-prod-type
        and buf_doclslib-goods.prod-code = p-prod-code
      no-error .
    if available buf_doclslib-goods
    then do:
      assign
        p-overturn-exist = true
      .
    end.
    else do:
      assign
        p-overturn-exist = false
      .
    end.
  end.
end procedure.
procedure check-md5-signature :
  define input  parameter p-obj-type     as character no-undo .
  define input  parameter p-obj-code     as integer   no-undo .
  define input  parameter p-archive-type as character no-undo .
  define input  parameter p-file-name    as character no-undo .
  define buffer buf_archive-history for ub.archive-history .
  do
  on error undo, return error return-value
  :
    find first buf_archive-history exclusive-lock
      where buf_archive-history.obj-type     = p-obj-type
        and buf_archive-history.obj-code     = p-obj-code
        and buf_archive-history.archive-type = p-archive-type
        and buf_archive-history.file-valid   = true
        and buf_archive-history.file-name    = p-file-name
      no-error .
    if not available buf_archive-history
    then do:
      message
        "Складской архив по типам приобретения" skip
        "Объект" p-obj-type p-obj-code skip
        "Отсутствует информация о выгрузке файла" skip
        "Файл" p-file-name skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    define variable v-md5-signature as character no-undo .
    run gbl/md5.p
      (input  p-file-name
      ,output v-md5-signature
      ) .
    if v-md5-signature <> buf_archive-history.file-md5
    then do:
      message
        "Складской архив по типам приобретения" skip
        "Объект" p-obj-type p-obj-code skip
        "Контрольная сумма файла не совпадает с информацией о выгрузке файла" skip
        "Файл" p-file-name skip
        "Контрольная сумма" v-md5-signature skip
        "Информация о выгрузке файла" buf_archive-history.file-md5 skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure invalidate-md5-signature :
  define input  parameter p-obj-type     as character no-undo .
  define input  parameter p-obj-code     as integer   no-undo .
  define input  parameter p-archive-type as character no-undo .
  define input  parameter p-file-name    as character no-undo .
  define input  parameter p-chip-num     as integer   no-undo .
  define buffer buf_archive-history for ub.archive-history .
  do
  on error undo, return error return-value
  :
    find first buf_archive-history exclusive-lock
      where buf_archive-history.obj-type     = p-obj-type
        and buf_archive-history.obj-code     = p-obj-code
        and buf_archive-history.archive-type = p-archive-type
        and buf_archive-history.file-valid   = true
        and buf_archive-history.file-name    = p-file-name
      no-error .
    if available buf_archive-history
    then do:
      assign
        buf_archive-history.file-valid            = false
        buf_archive-history.file-invalid-chip-num = p-chip-num
      .
    end.
  end.
end procedure.
