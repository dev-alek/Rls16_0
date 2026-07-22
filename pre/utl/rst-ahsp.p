block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rst-ahsp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/rst-ahsp.p $":U .
define variable vss-description as character no-undo init "Восстановление складского архива по поставщикам".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define temp-table temp-goods no-undo
  field gds-code  as integer
  field artic     as character
  field prod-type as character
  field prod-code as integer
  index xpk is primary unique artic prod-type prod-code
  index xie gds-code
  .
define temp-table temp-stk-supp-tot no-undo like ub.stk-supp-tot   field new-fact-qnty      like ub.stk-supp-tot.fact-qnty      column-label 'new-fact-qnty'           field new-sum-base       like ub.stk-supp-tot.sum-base       column-label 'new-sum-base'            field new-sum-rubl       like ub.stk-supp-tot.sum-rubl       column-label 'new-sum-rubl'            field new-vat-base       like ub.stk-supp-tot.vat-base       column-label 'new-vat-base'            field new-vat-rubl       like ub.stk-supp-tot.vat-rubl       column-label 'new-vat-rubl'            field new-slt-base       like ub.stk-supp-tot.slt-base       column-label 'new-slt-base'            field new-slt-rubl       like ub.stk-supp-tot.slt-rubl       column-label 'new-slt-rubl'            field new-road-tax-base  like ub.stk-supp-tot.road-tax-base  column-label 'new-road-tax-base'       field new-road-tax-rubl  like ub.stk-supp-tot.road-tax-rubl  column-label 'new-road-tax-rubl'       field new-excise-base    like ub.stk-supp-tot.excise-base    column-label 'new-excise-base'         field new-excise-rubl    like ub.stk-supp-tot.excise-rubl    column-label 'new-excise-rubl'         field new-transport-base like ub.stk-supp-tot.transport-base column-label 'new-transport-base'      field new-transport-rubl like ub.stk-supp-tot.transport-rubl column-label 'new-transport-rubl'      field new-other-base     like ub.stk-supp-tot.other-base     column-label 'new-other-base'          field new-other-rubl     like ub.stk-supp-tot.other-rubl     column-label 'new-other-rubl'        index pi is primary unique  obj-type obj-code cli-type cli-code fact-order sum-type cat-id   index category              obj-type obj-code cli-type cli-code sum-type cat-id fact-order   index sum-type              sum-type cat-id .
define temp-table temp-stk-supp-line no-undo like ub.stk-supp-line   field new-fact-qnty      like ub.stk-supp-line.fact-qnty      column-label 'new-fact-qnty'           field new-sum-base       like ub.stk-supp-line.sum-base       column-label 'new-sum-base'            field new-sum-rubl       like ub.stk-supp-line.sum-rubl       column-label 'new-sum-rubl'            field new-vat-base       like ub.stk-supp-line.vat-base       column-label 'new-vat-base'            field new-vat-rubl       like ub.stk-supp-line.vat-rubl       column-label 'new-vat-rubl'            field new-slt-base       like ub.stk-supp-line.slt-base       column-label 'new-slt-base'            field new-slt-rubl       like ub.stk-supp-line.slt-rubl       column-label 'new-slt-rubl'            field new-road-tax-base  like ub.stk-supp-line.road-tax-base  column-label 'new-road-tax-base'       field new-road-tax-rubl  like ub.stk-supp-line.road-tax-rubl  column-label 'new-road-tax-rubl'       field new-excise-base    like ub.stk-supp-line.excise-base    column-label 'new-excise-base'         field new-excise-rubl    like ub.stk-supp-line.excise-rubl    column-label 'new-excise-rubl'         field new-transport-base like ub.stk-supp-line.transport-base column-label 'new-transport-base'      field new-transport-rubl like ub.stk-supp-line.transport-rubl column-label 'new-transport-rubl'      field new-other-base     like ub.stk-supp-line.other-base     column-label 'new-other-base'          field new-other-rubl     like ub.stk-supp-line.other-rubl     column-label 'new-other-rubl'        index pi is primary unique obj-type obj-code cli-type cli-code artic prod-type prod-code fact-order sum-type cat-id   index category             obj-type obj-code cli-type cli-code artic prod-type prod-code sum-type cat-id fact-order   index sum-type             sum-type cat-id .
define temp-table temp-shift-stk-supp-tot no-undo like ub.stk-supp-tot   field new-fact-qnty      like ub.stk-supp-tot.fact-qnty      column-label 'new-fact-qnty'           field new-sum-base       like ub.stk-supp-tot.sum-base       column-label 'new-sum-base'            field new-sum-rubl       like ub.stk-supp-tot.sum-rubl       column-label 'new-sum-rubl'            field new-vat-base       like ub.stk-supp-tot.vat-base       column-label 'new-vat-base'            field new-vat-rubl       like ub.stk-supp-tot.vat-rubl       column-label 'new-vat-rubl'            field new-slt-base       like ub.stk-supp-tot.slt-base       column-label 'new-slt-base'            field new-slt-rubl       like ub.stk-supp-tot.slt-rubl       column-label 'new-slt-rubl'            field new-road-tax-base  like ub.stk-supp-tot.road-tax-base  column-label 'new-road-tax-base'       field new-road-tax-rubl  like ub.stk-supp-tot.road-tax-rubl  column-label 'new-road-tax-rubl'       field new-excise-base    like ub.stk-supp-tot.excise-base    column-label 'new-excise-base'         field new-excise-rubl    like ub.stk-supp-tot.excise-rubl    column-label 'new-excise-rubl'         field new-transport-base like ub.stk-supp-tot.transport-base column-label 'new-transport-base'      field new-transport-rubl like ub.stk-supp-tot.transport-rubl column-label 'new-transport-rubl'      field new-other-base     like ub.stk-supp-tot.other-base     column-label 'new-other-base'          field new-other-rubl     like ub.stk-supp-tot.other-rubl     column-label 'new-other-rubl'        index pi is primary unique  obj-type obj-code cli-type cli-code fact-order sum-type cat-id   index category              obj-type obj-code cli-type cli-code sum-type cat-id fact-order   index sum-type              sum-type cat-id .
define temp-table temp-shift-stk-supp-line no-undo like ub.stk-supp-line   field new-fact-qnty      like ub.stk-supp-line.fact-qnty      column-label 'new-fact-qnty'           field new-sum-base       like ub.stk-supp-line.sum-base       column-label 'new-sum-base'            field new-sum-rubl       like ub.stk-supp-line.sum-rubl       column-label 'new-sum-rubl'            field new-vat-base       like ub.stk-supp-line.vat-base       column-label 'new-vat-base'            field new-vat-rubl       like ub.stk-supp-line.vat-rubl       column-label 'new-vat-rubl'            field new-slt-base       like ub.stk-supp-line.slt-base       column-label 'new-slt-base'            field new-slt-rubl       like ub.stk-supp-line.slt-rubl       column-label 'new-slt-rubl'            field new-road-tax-base  like ub.stk-supp-line.road-tax-base  column-label 'new-road-tax-base'       field new-road-tax-rubl  like ub.stk-supp-line.road-tax-rubl  column-label 'new-road-tax-rubl'       field new-excise-base    like ub.stk-supp-line.excise-base    column-label 'new-excise-base'         field new-excise-rubl    like ub.stk-supp-line.excise-rubl    column-label 'new-excise-rubl'         field new-transport-base like ub.stk-supp-line.transport-base column-label 'new-transport-base'      field new-transport-rubl like ub.stk-supp-line.transport-rubl column-label 'new-transport-rubl'      field new-other-base     like ub.stk-supp-line.other-base     column-label 'new-other-base'          field new-other-rubl     like ub.stk-supp-line.other-rubl     column-label 'new-other-rubl'        index pi is primary unique obj-type obj-code cli-type cli-code artic prod-type prod-code fact-order sum-type cat-id   index category             obj-type obj-code cli-type cli-code artic prod-type prod-code sum-type cat-id fact-order   index sum-type             sum-type cat-id .
define temp-table temp-import-ot-supp-tot no-undo like ub.ot-supp-tot
  .
define temp-table temp-import-ot-supp-line no-undo like ub.ot-supp-line
  field gds-code as integer
  .
define temp-table temp-import-stk-supp-tot no-undo like ub.stk-supp-tot
  .
define temp-table temp-import-stk-supp-line no-undo like ub.stk-supp-line
  field gds-code as integer
  .
define temp-table temp-create-stk-supp-tot no-undo
   field obj-type as character
   field obj-code as integer
   field cli-type as character
   field cli-code as integer
   field sum-type as character
   field need-create as logical
   index xpk is primary unique obj-type obj-code cli-type cli-code sum-type
   index xie1 need-create
.
define temp-table temp-create-stk-supp-line no-undo
   field obj-type  as character
   field obj-code  as integer
   field cli-type  as character
   field cli-code  as integer
   field artic     as character
   field prod-type as character
   field prod-code as integer
   field sum-type  as character
   field need-create as logical
   index xpk is primary unique obj-type obj-code cli-type cli-code artic prod-type prod-code sum-type
   index xie1 need-create
   index xie2 obj-type obj-code artic prod-type prod-code sum-type
.
define temp-table doclslib-clients no-undo
  field cli-type  as character
  field cli-code  as integer
  index xpk is primary unique cli-type cli-code
  .
define temp-table doclslib-clients-goods no-undo
  field cli-type  as character
  field cli-code  as integer
  field artic     as character
  field prod-type as character
  field prod-code as integer
  index xpk is primary unique cli-type cli-code artic prod-type prod-code
  index xie1 artic prod-type prod-code
  .
define stream slog .
define stream sinp .
define stream sout .
define buffer calc-supp-arh-lock_batchprocess for ub.batchprocess .
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
  define buffer restore-ahsp-lock_batchprocess for ub.batchprocess .
  run gbl/lock-prc.p
    (input 'rsas':U
    ,input v-obj-code
    ,input 0
    ,input 0
    ,input v-obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Восстановление складского архива по поставщикам"
    ,input true
    ,buffer restore-ahsp-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент восстанавливается складской архив по поставщикам" skip
        "Невозможно произвести восстановлением складского архива по поставщикам" skip
        view-as alert-box error .
    end.
    undo, return error "В данный момент восстанавливается складской архив по поставщикам" .
  end.
  run gbl/lock-prc.p
    (input 'ahsp':U
    ,input v-obj-code
    ,input 0
    ,input 0
    ,input v-obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Расчет складского архива по поставщикам"
    ,input true
    ,buffer calc-supp-arh-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент рассчитывается складской архив по поставщикам" skip
        "Невозможно произвести расчёт складского архива по поставщикам" skip
        view-as alert-box error .
    end.
    undo, return error "В данный момент рассчитывается складской архив по поставщикам" .
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
  define variable v-ahsp-calc          as logical   no-undo .
  define variable v-ahsp-del           as logical   no-undo .
  define variable v-ahsp-start-date    as date      no-undo .
  define variable v-ahsp-detail-date   as date      no-undo .
  define variable v-ahsp-recalc-date   as date      no-undo .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'ahsp-calc':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-ahsp-calc = (lookup(v-attr-value, 'yes,true') > 0)
  .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'ahsp-del':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-ahsp-del = (lookup(v-attr-value, 'yes,true') > 0)
  .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'ahsp-start':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-ahsp-start-date = date(v-attr-value)
  .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'ahsp-detail':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-ahsp-detail-date = date(v-attr-value)
  .
  run clntattr-value in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'ahsp-recalc':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-ahsp-recalc-date = date(v-attr-value)
  .
  if (v-ahsp-start-date <> ?
     and v-ahsp-detail-date = ?)
  or (v-ahsp-start-date = ?
     and v-ahsp-detail-date <> ?)
  then do:
    message
      "Складской архив по поставщикам" skip
      "Объект" v-obj-type v-obj-code skip
      "Невозможно произвести восстановление складского архива по поставщикам" skip
      "Противоречивая информация в датах инициализации складского архива по поставщикам" skip
      "Дата начала складского архива по поставщикам" string(v-ahsp-start-date, '99/99/9999':u) skip
      "Дата начала подробного складского архива по поставщикам" string(v-ahsp-detail-date, '99/99/9999':u) skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if v-ahsp-detail-date = ?
  then do:
    message
      "Складской архив по поставщикам" skip
      "Объект" v-obj-type v-obj-code skip
      "На объекте рассчитан складской архив по поставщикам за все даты" skip
      "Операция восстановления не может быть произведена" skip
      view-as alert-box information .
    return .
  end.
  define variable v-year  as integer   no-undo .
  define variable v-month as integer   no-undo .
  define variable v-day   as integer   no-undo .
  assign
    v-year  = year(v-ahsp-detail-date)
    v-month = month(v-ahsp-detail-date)
    v-day   = day(v-ahsp-detail-date)
  .
  assign
    v-file-name = 'ahspdel':u
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
  define variable v-full-file-name as character no-undo .
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
           + "Произвести восстановление подробного складского архива по поставщикам" + chr(10)
           + "Дата начала подробного складского архива по поставщикам " + string(v-ahsp-detail-date, '99/99/9999':U) + chr(10)
           + "Сегодня " + string(v-today, '99/99/9999':U) + chr(10)
    ,input '|^':u
    ,input "Из файла" + '^confirm':u + (if v-restore-from-file = true then '':u else '^disable':u)
    + '|':u + "Резервная копия" + '^confirm':u + (if v-restore-backup = true then '':u else '^disable':u)
    + '|':u + "Документы" + '^confirm':u + (if v-ahsp-del = true then '^disable':u else '':u)
    + '|':u + "Отказ"
    ,input (if v-restore-from-file then substitute("Восстановить из файла &1", v-full-file-name)
            else substitute("Файл с сохраненным архивом &1 не найден", v-file-name ) )
        + "|":u +
           (if v-restore-from-file then substitute("Восстановить из резервной копии &1", v-backup-file-name)
            else substitute("Файл резервной копии &1 не найден", v-backup-file-name) )
        + "|":u + (if v-ahsp-del
                   then "Была ошибка при предыдущем Удалении/Восстановлении" + chr(10)
                        + "Складской архив по поставщикам можно восстановить только из файла"
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
        ,input  'ahsp':U
        ,input  v-file-name
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Складской архив по поставщикам" skip
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
        ,input  v-ahsp-detail-date
        ,input  v-file-name
        ,output v-restore-start-date
        ,output v-restore-detail-date
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Складской архив по поставщикам" skip
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
        ,input  'ahsp':U
        ,input  v-file-name
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Складской архив по поставщикам" skip
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
        ,input  v-ahsp-detail-date
        ,input  v-file-name
        ,output v-restore-start-date
        ,output v-restore-detail-date
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Складской архив по поставщикам" skip
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
    when 3
    then do:
      if v-ahsp-del = true
      then do:
        message
          "Складской архив по поставщикам" skip
          "Объект" v-obj-type v-obj-code skip
          "Невозможно произвести восстановление на основании документов" skip
          "Остатки по архивам не рассчитаны" skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if  v-ahsp-recalc-date <> ?
      and v-ahsp-recalc-date <= v-ahsp-detail-date
      then do:
        message
          "Складской архив по поставщикам" skip
          "Объект" v-obj-type v-obj-code skip
          "Невозможно произвести восстановление на основании документов" skip
          "Дата перерасчета меньше даты начала подробного складского архива по поставщикам" skip
          "Дата перерасчета" string(v-ahsp-recalc-date, '99/99/9999':u) skip
          "Дата начала подробного складского архива по поставщикам" string(v-ahsp-detail-date, '99/99/9999':u) skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      assign
        v-restore-from-file = false
        v-restore-backup    = false
      .
      assign
        v-month = month(v-ahsp-detail-date)
        v-year  = year(v-ahsp-start-date)
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
          "Складской архив по поставщикам" skip
          "Объект" v-obj-type v-obj-code skip
          "Дата расчета складского архива по товарам не задана" skip
          "Восстановление архива не было произведено" skip
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
          "Складской архив по поставщикам" skip
          "Объект" v-obj-type v-obj-code skip
          "Ошибка при выборе даты" skip
          "Месяц" v-month skip
          "Год" v-year skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if v-restore-detail-date >= v-ahsp-detail-date
      then do:
        message
          "Складской архив по поставщикам" skip
          "Объект" v-obj-type v-obj-code skip
          "Неправильная дата расчета складского архива по поставщикам" skip
          "Дата расчета архива не может быть больше, чем дата на которую" skip
          "имеется рассчитанный складской архив по поставщикам" skip
          "Дата на которую запрошено восстановление подробного складского архива по поставщикам" string(v-restore-detail-date, '99/99/9999':u) skip
          "Дата начала подробного складского архива по поставщикам" string(v-ahsp-detail-date, '99/99/9999':u) skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if v-restore-detail-date >= v-ahsp-start-date
      then do:
        assign
          v-clear-start = false
          v-restore-start-date = v-ahsp-start-date
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
        "Складской архив по поставщикам" skip
        "Объект" v-obj-type v-obj-code skip
        "Внутрення ошибка" skip
        "Неизвестное значение" v-num skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .
  assign
    v-ok = false
  .
  define variable v-ahsp-source as character no-undo .
  if v-restore-from-file = true
  then do:
    assign
      v-ahsp-source = "Будет восстановлен складской архив по поставщикам из файла " + v-file-name
    .
  end.
  else do:
    assign
      v-ahsp-source = "Складской архив по поставщикам будет рассчитан на основании первичных документов"
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
      "Складской архив по поставщикам" skip
      "Объект" v-obj-type v-obj-code skip
      "Внутренняя ошибка" skip
      "Противоречивая информация в датах начала складского архива и начала подробного складского архива" skip
      "Дата начала складского архива" string(v-restore-start-date, '99/99/9999':u) skip
      "Дата начала подробного складского архива" string(v-restore-detail-date, '99/99/9999':u) skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  message
    "Складской архив по поставщикам" skip
    "Объект" v-obj-type v-obj-code skip
    "ВНИМАНИЕ!" skip
    "Последнее предупреждение перед восстановлением складского архива по поставщикам." skip
    "Дата с которой существует складской архив по поставщикам" string(v-ahsp-start-date, '99/99/9999':u) skip
    "Дата с которой имеются подробный складской архив по поставщикам" string(v-ahsp-detail-date, '99/99/9999':u) skip
    "" skip
    "Дата с которой будет начинаться складской архив по поставщикам после восстановления" string(v-restore-start-date, '99/99/9999':u) skip
    "Дата с которой будет начинаться подробный складской архив по поставщикам после восстановления" string(v-restore-detail-date, '99/99/9999':u) skip
    ""
    "" skip
    "Сегодня" string(v-today, '99/99/9999':u) skip
    "" v-ahsp-source skip
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
    title "Расчет складского архива по поставщикам"
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
    (input  v-ahsp-detail-date - 1
    ,output v-day-end-fact-order
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Складской архив по поставщикам" skip
      "Объект" v-obj-type v-obj-code skip
      "Ошибка при вызове процедуры factord"
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if  v-ahsp-del       = false
  and v-restore-backup = false
  then do:
    run create-log-file in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input v-ahsp-start-date
      ,input v-ahsp-detail-date
      ,input v-ahsp-start-date
      ,input v-ahsp-detail-date
      ,input v-backup-file-name
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по поставщикам" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при создании файла архивации" skip
        "Имя файла архивации" v-file-name skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run trg/ah-clicl.p
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
        "Складской архив по поставщикам" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при cохранении складского архива по поставщикам"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run close-log-file in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input v-ahsp-start-date
      ,input v-ahsp-detail-date
      ,input v-ahsp-start-date
      ,input v-ahsp-detail-date
      ,input v-backup-file-name
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по поставщикам" skip
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
      ,input  'ahsp':U
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
      ,input  'ahsp':U
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
        "Складской архив по поставщикам" skip
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
      ,input 'ahsp-del':U
      ,input 'true':u
      ) .
    run trg/ah-clicl.p
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
        "Складской архив по поставщикам" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при удалении складского архива по поставщикам" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    input stream sinp from value(v-file-name) .
    run validate-file-name in this-procedure
      (input  v-obj-type
      ,input  v-obj-code
      ,input  v-ahsp-detail-date
      ,input  v-file-name
      ,output v-restore-start-date
      ,output v-restore-detail-date
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по поставщикам" skip
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
      ,input  v-ahsp-detail-date
      ,input  v-file-name
      ,output v-close-restore-start-date
      ,output v-close-restore-detail-date
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по поставщикам" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при закрытии файла архивации" skip
        "Имя файла архивации" v-file-name skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if v-close-restore-start-date  <> v-restore-start-date
    or v-close-restore-detail-date <> v-restore-detail-date
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по поставщикам" skip
        "Объект" v-obj-type v-obj-code skip
        "Ошибка при закрытии файла архивации" skip
        "Не соответствие дат начала архива и начала подробнго архива в конце и в начала файла" skip
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
      ,input 'ahsp-start':U
      ,input string(v-restore-start-date, '99/99/9999':u)
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты начала складского архива по поставщикам" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run clntattr-write in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input 'ahsp-detail':U
      ,input string(v-restore-detail-date, '99/99/9999':u)
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты начала подробного складского архива по поставщикам" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    define variable v-delete-ahsp-del as logical   no-undo .
    run clntattr-delete in this-procedure
      (input  v-obj-type
      ,input  v-obj-code
      ,input  'ahsp-del':U
      ,output v-delete-ahsp-del
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
      undo, return error return-value .
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
      undo, return error return-value .
    end.
    run doclslib-clear-rst in this-procedure
      (input v-ahsp-detail-date
      ) .
    run doclslib-init-goods in this-procedure .
    run rst-ahsp-init-clients-goods in this-procedure .
    run rst-ahsp-init-clients in this-procedure .
    run clntattr-write in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input 'ahsp-rest':U
      ,input 'true':u
      ) .
    run temp-supp-gds-fill in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input v-day-end-fact-order
      ) .
    run temp-supp-gds-from-doclslib in this-procedure .
    run ahrstutl-init in this-procedure
      (input  v-obj-type
      ,input  v-obj-code
      ,input  v-ahsp-detail-date - 1
      ,input  false
      ) .
    run ahrstutl-create-stk in this-procedure
      (input  v-obj-type
      ,input  v-obj-code
      ,input  v-ahsp-detail-date - 1
      ) .
    run ahrstutl-clear-ahsp in this-procedure
      (input  v-obj-type
      ,input  v-obj-code
      ,input  v-start-day-end-fact-order
      ,input  v-ahsp-detail-date - 1
      ) .
    find current calc-supp-arh-lock_batchprocess no-lock .
    if v-clear-start = true
    then do:
      run show-action in this-procedure
        (input "Инициализация остатка на дату нового начала складского архива"
        ).
      run trg/inahsp.p
        (input  this-procedure :handle
        ,input  v-obj-type
        ,input  v-obj-code
        ,input  v-restore-start-date - 1
        ,input  v-ahsp-detail-date - 1
        ) .
    end.
    run show-action in this-procedure
      (input "Расчёт складского архива по поставщикам"
      ).
    run doclslib-calc-ahsp in this-procedure
      (input this-procedure
      ,input v-obj-type
      ,input v-obj-code
      ,input v-ahsp-detail-date - 1
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
        ,input v-ahsp-detail-date - 1
        ,input true
        ) .
      run ahrstutl-update in this-procedure
        (input v-obj-type
        ,input v-obj-code
        ,input v-restore-detail-date - 1
        ,input v-ahsp-detail-date - 1
        ) .
    end.
    run show-action in this-procedure
      (input "Блокировка расчёта складского архива по поставщикам"
      ).
    define variable v-need-stop-ahsp as logical   no-undo .
    assign
      v-need-stop-ahsp = false
    .
    run gbl/lock-prc.p
      (input 'ahsp':U
      ,input v-obj-code
      ,input 0
      ,input 0
      ,input v-obj-type
      ,input ""
      ,input ""
      ,input "Объект,,, ,,,Расчет складского архива по поставщикам"
      ,input false
      ,buffer calc-supp-arh-lock_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры блокировки расчета складского архива по поставщикам" skip
          "Невозможно продолжить восстановление складского архива по поставщикам" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error "Ошибка при вызове процедуры блокировки расчёта складского архива по поставщикам" .
      end.
      assign
        v-need-stop-ahsp = true
      .
    end.
    define buffer stop-ahsp-restore-lock_btpr for batchprocess .
    if v-need-stop-ahsp = true
    then do:
      do transaction
      on error undo, return error return-value
      :
        create stop-ahsp-restore-lock_btpr .
        assign
          stop-ahsp-restore-lock_btpr.bp_type       = 'lock':U + 'rsss':U
          stop-ahsp-restore-lock_btpr.bp_status     = 'N':U
          stop-ahsp-restore-lock_btpr.Key#_One      = v-obj-code
          stop-ahsp-restore-lock_btpr.Key#_Two      = 0
          stop-ahsp-restore-lock_btpr.Key#_Three    = 0
          stop-ahsp-restore-lock_btpr.CharKey_One   = v-obj-type
          stop-ahsp-restore-lock_btpr.CharKey_Two   = ""
          stop-ahsp-restore-lock_btpr.CharKey_Three = ""
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
            (input waitfram-join-function("Складской архив рассчитывается на другой машине"
                                         ,"Отправлено сообщение о необходимости остановки расчёта складского архива"
                                         ,substitute("Ожидание освобождения ресурса расчёта складского архива &1", string(v-start-lock-second, 'HH:MM:SS':U))
                                         )
            ) .
          run gbl/lock-prc.p
            (input 'ahsp':U
            ,input v-obj-code
            ,input 0
            ,input 0
            ,input v-obj-type
            ,input ""
            ,input ""
            ,input "Объект,,, ,,,Расчет складского архива по поставщикам"
            ,input false
            ,buffer calc-supp-arh-lock_batchprocess
            ) no-error .
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры блокировки расчета складского архива по поставщикам" skip
                "Невозможно продолжить восстановление складского архива по поставщикам" skip
                view-as alert-box error .
              undo, return error "В данный момент рассчитывается складской архив по поставщикам" .
            end.
          end.
          else do:
            run waitfram-hide in this-procedure .
            leave wait_block .
          end.
          pause 1 no-message .
        end.
        delete stop-ahsp-restore-lock_btpr .
      end.
    end.
    run show-action in this-procedure
      (input "Удаление повторных записей остатков"
      ).
    run ahrstutl-delete-copy in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input v-ahsp-detail-date - 1
      ) .
    run show-action in this-procedure
      (input "Обновление атрибутов складского архива"
      ).
    run clntattr-write in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input 'ahsp-start':U
      ,input string(v-restore-start-date, '99/99/9999':u)
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты начала складского архива по поставщикам" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run clntattr-write in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ,input 'ahsp-detail':U
      ,input string(v-restore-detail-date, '99/99/9999':u)
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при записи даты начала подробного складского архива по поставщикам" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    define variable v-delete-ahsp-rest as logical   no-undo .
    run clntattr-delete in this-procedure
      (input  v-obj-type
      ,input  v-obj-code
      ,input  'ahsp-rest':U
      ,output v-delete-ahsp-rest
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
      v-action-type = 'rstfil-stop':U
    .
  end.
  run utl/arhiscr.p
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'ahsp':U
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
    ,input  'ahsp':U
    ,input  v-file-name
    ,input  v-create-chip-num
    ) .
  run invalidate-md5-signature in this-procedure
    (input  v-obj-type
    ,input  v-obj-code
    ,input  'ahsp':U
    ,input  v-backup-file-name
    ,input  v-create-chip-num
    ) .
  message
    "Восстановление складского архива по поставщикам успешно закончилось" skip
    "Объект" v-obj-type v-obj-code skip
    "" + (if v-restore-detail-date <> ?
         then substitute("На объекте существуют подробный складской архив с даты &1", string(v-restore-detail-date, '99/99/9999':u))
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
        when 'ot-supp-tot':U
        then do:
          define buffer buf_temp-import-ot-supp-tot for temp-import-ot-supp-tot .
          create buf_temp-import-ot-supp-tot .
          import stream sinp buf_temp-import-ot-supp-tot no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при импорте таблицы temp-import-ot-supp-tot" skip
              "Строка" v-line-num skip
              error-status :get-message(1) skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-line-num = v-line-num + 1
          .
          define buffer buf_ot-supp-tot for ub.ot-supp-tot .
          create buf_ot-supp-tot .
          buffer-copy buf_temp-import-ot-supp-tot to buf_ot-supp-tot .
          delete buf_temp-import-ot-supp-tot .
        end.
        when 'ot-supp-line':U
        then do:
          define buffer buf_temp-import-ot-supp-line for temp-import-ot-supp-line .
          create buf_temp-import-ot-supp-line .
          import stream sinp buf_temp-import-ot-supp-line except artic prod-type prod-code
            no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при импорте таблицы temp-import-ot-supp-line" skip
              "Строка" v-line-num skip
              error-status :get-message(1) skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-line-num = v-line-num + 1
          .
          run fill-artic in this-procedure
            (input  buf_temp-import-ot-supp-line.gds-code
            ,output buf_temp-import-ot-supp-line.artic
            ,output buf_temp-import-ot-supp-line.prod-type
            ,output buf_temp-import-ot-supp-line.prod-code
            ) .
          define buffer buf_ot-supp-line for ub.ot-supp-line .
          create buf_ot-supp-line .
          buffer-copy buf_temp-import-ot-supp-line to buf_ot-supp-line .
          delete buf_temp-import-ot-supp-line .
        end.
        when 'stk-supp-tot':U
        then do:
          define buffer buf_temp-import-stk-supp-tot for temp-import-stk-supp-tot .
          create buf_temp-import-stk-supp-tot .
          import stream sinp buf_temp-import-stk-supp-tot no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при импорте таблицы temp-import-stk-supp-tot" skip
              "Строка" v-line-num skip
              error-status :get-message(1) skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-line-num = v-line-num + 1
          .
          define buffer buf_stk-supp-tot for ub.stk-supp-tot .
          create buf_stk-supp-tot .
          buffer-copy buf_temp-import-stk-supp-tot to buf_stk-supp-tot .
          delete buf_temp-import-stk-supp-tot .
        end.
        when 'stk-supp-line':U
        then do:
          define buffer buf_temp-import-stk-supp-line for temp-import-stk-supp-line .
          create buf_temp-import-stk-supp-line .
          import stream sinp buf_temp-import-stk-supp-line except artic prod-type prod-code
            no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при импорте таблицы temp-import-stk-supp-line" skip
              "Строка" v-line-num skip
              error-status :get-message(1) skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-line-num = v-line-num + 1
          .
          run fill-artic in this-procedure
            (input  buf_temp-import-stk-supp-line.gds-code
            ,output buf_temp-import-stk-supp-line.artic
            ,output buf_temp-import-stk-supp-line.prod-type
            ,output buf_temp-import-stk-supp-line.prod-code
            ) .
          define buffer buf_stk-supp-line for ub.stk-supp-line .
          create buf_stk-supp-line .
          buffer-copy buf_temp-import-stk-supp-line to buf_stk-supp-line .
          delete buf_temp-import-stk-supp-line .
        end.
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
            "Складской архив по поставщикам" skip
            "Объект" v-obj-type v-obj-code skip
            "Неизвестный код таблицы" v-key-value skip
            "Строка" v-line-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .
    end.
    if v-data-finished = false
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по поставщикам" skip
        "Объект" v-obj-type v-obj-code skip
        "Не найден признак окончания данных" skip
        "Неправильный формат файла" v-file-name skip
        "Строка" v-line-num skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure validate-file-name :
  define input parameter  p-obj-type            as character no-undo .
  define input parameter  p-obj-code            as integer   no-undo .
  define input parameter  v-ahsp-detail-date     as date      no-undo .
  define input parameter  p-file-name           as character no-undo .
  define output parameter p-restore-start-date  as date      no-undo .
  define output parameter p-restore-detail-date as date      no-undo .
  do
  on error undo, return error return-value
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
        "Складской архив по поставщикам" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    import stream sinp v-param-code v-param-value .
    assign
      v-line-num = v-line-num + 1
    .
    if v-param-code <> 'obj-type':u
    or v-param-value <> p-obj-type
    then do:
      message
        "Складской архив по поставщикам" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    import stream sinp v-param-code v-param-value .
    assign
      v-line-num = v-line-num + 1
    .
    if v-param-code <> 'obj-code':u
    or v-param-value <> string(p-obj-code)
    then do:
      message
        "Складской архив по поставщикам" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    import stream sinp v-param-code v-param-value .
    assign
      v-line-num = v-line-num + 1
    .
    if v-param-code <> 'old-start-date':u
    then do:
      message
        "Складской архив по поставщикам" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error return-value .
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
        "Складской архив по поставщикам" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error return-value .
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
        "Складской архив по поставщикам" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    import stream sinp v-param-code v-param-value .
    assign
      v-line-num = v-line-num + 1
    .
    if v-param-code <> 'new-detail-date':u
    then do:
      message
        "Складской архив по поставщикам" skip
        "Объект" p-obj-type p-obj-code skip
        "Неправильный формат файла" p-file-name skip
        "Строка" v-line-num skip
        "Значения" v-param-code v-param-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if v-ahsp-detail-date <> date(v-param-value)
    then do:
      message
        "Складской архив по поставщикам" skip
        "Объект" p-obj-type p-obj-code skip
        "Несоответствие текущей даты начала подробного складского архива по поставщикам" skip
        "и даты начала подробного архива в файле" p-file-name skip
        "Строка" v-line-num skip
        "Текущая дата начала подробного архива" string(v-ahsp-detail-date) skip
        "Дата начала подробного архива в файле" v-param-value skip
        "Восстановление складского архива по поставщикам невозможно" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure show-action :
  do
  on error undo, return error return-value
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
  on error undo, return error return-value
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
  on error undo, return error return-value
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
  on error undo, return error return-value
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
define temp-table temp-supp no-undo
  field cli-type as character
  field cli-code as integer
  index xpk is primary unique cli-type cli-code
  .
define temp-table temp-supp-gds no-undo
  field cli-type  as character
  field cli-code  as integer
  field artic     as character
  field prod-type as character
  field prod-code as integer
  index xpk is primary unique cli-type cli-code artic prod-type prod-code
  .
procedure store-temp :
  define buffer buf_temp-stk-supp-tot         for temp-stk-supp-tot .
  define buffer buf_temp-stk-supp-line        for temp-stk-supp-line .
  define buffer buf_temp-shift-stk-supp-tot   for temp-shift-stk-supp-tot .
  define buffer buf_temp-shift-stk-supp-line  for temp-shift-stk-supp-line .
  define buffer buf_temp-supp                 for temp-supp .
  define buffer buf_temp-supp-gds             for temp-supp-gds .
  define buffer buf_temp-create-stk-supp-tot  for temp-create-stk-supp-tot .
  define buffer buf_temp-create-stk-supp-line for temp-create-stk-supp-line .
  define buffer buf_doclslib-clients          for doclslib-clients .
  define buffer buf_doclslib-clients-goods    for doclslib-clients-goods .
  define buffer buf_doclslib-goods            for doclslib-goods .
  do
  on error undo, return error return-value
  :
    output stream sout to value ("rst-ahsp.txt") append .
    export stream sout 'export':u string(today, '99/99/9999':u) string(time, 'hh:mm:ss':u) .
    for each buf_temp-stk-supp-tot
    on error undo, return error return-value
    :
      export stream sout 'temp-stk-supp-tot':u .
      export stream sout buf_temp-stk-supp-tot .
    end.
    for each buf_temp-stk-supp-line
    on error undo, return error return-value
    :
      export stream sout 'temp-stk-supp-line':u .
      export stream sout buf_temp-stk-supp-line .
    end.
    for each buf_temp-shift-stk-supp-tot
    on error undo, return error return-value
    :
      export stream sout 'temp-shift-stk-supp-tot':u .
      export stream sout buf_temp-shift-stk-supp-tot .
    end.
    for each buf_temp-shift-stk-supp-line
    on error undo, return error return-value
    :
      export stream sout 'temp-shift-stk-supp-line':u .
      export stream sout buf_temp-shift-stk-supp-line .
    end.
    for each buf_temp-supp
    on error undo, return error return-value
    :
      export stream sout 'temp-supp':u .
      export stream sout buf_temp-supp .
    end.
    for each buf_temp-supp-gds
    on error undo, return error return-value
    :
      export stream sout 'temp-supp-gds':u .
      export stream sout buf_temp-supp-gds .
    end.
    for each buf_temp-create-stk-supp-tot
    on error undo, return error return-value
    :
      export stream sout 'temp-create-stk-supp-tot':u .
      export stream sout buf_temp-create-stk-supp-tot .
    end.
    for each buf_temp-create-stk-supp-line
    on error undo, return error return-value
    :
      export stream sout 'temp-create-stk-supp-line':u .
      export stream sout buf_temp-create-stk-supp-line .
    end.
    for each buf_doclslib-clients
    on error undo, return error return-value
    :
      export stream sout 'doclslib-clients':u .
      export stream sout buf_doclslib-clients.
    end.
    for each buf_doclslib-clients-goods
    on error undo, return error return-value
    :
      export stream sout 'doclslib-clients-goods':u .
      export stream sout buf_doclslib-clients-goods.
    end.
    for each buf_doclslib-goods
    on error undo, return error return-value
    :
      export stream sout 'doclslib-goods':u .
      export stream sout buf_doclslib-goods.
    end.
    output stream sout close .
  end.
end procedure.
procedure temp-supp-clear :
  define buffer buf_temp-supp for temp-supp .
  do
  on error undo, return error return-value
  :
    for each buf_temp-supp
    on error undo, return error return-value
    :
      delete buf_temp-supp .
    end.
  end.
end procedure.
procedure temp-supp-create :
  define input  parameter p-cli-type                  like ub.stk-supp-line.cli-type  no-undo .
  define input  parameter p-cli-code                  like ub.stk-supp-line.cli-code  no-undo .
  define buffer buf_temp-supp for temp-supp .
  do
  on error undo, return error return-value
  :
    find first buf_temp-supp
      where buf_temp-supp.cli-type  = p-cli-type
        and buf_temp-supp.cli-code  = p-cli-code
      no-error .
    if not available buf_temp-supp
    then do:
      create buf_temp-supp .
      assign
        buf_temp-supp.cli-type  = p-cli-type
        buf_temp-supp.cli-code  = p-cli-code
      .
    end.
  end.
end procedure.
procedure temp-supp-gds-clear :
  define buffer buf_temp-supp-gds for temp-supp-gds .
  do
  on error undo, return error return-value
  :
    for each buf_temp-supp-gds
    on error undo, return error return-value
    :
      delete buf_temp-supp-gds .
    end.
  end.
end procedure.
procedure temp-supp-gds-create :
  define input  parameter p-cli-type                  like ub.stk-supp-line.cli-type  no-undo .
  define input  parameter p-cli-code                  like ub.stk-supp-line.cli-code  no-undo .
  define input  parameter p-artic                     like ub.stk-supp-line.artic     no-undo .
  define input  parameter p-prod-type                 like ub.stk-supp-line.prod-type no-undo .
  define input  parameter p-prod-code                 like ub.stk-supp-line.prod-code no-undo .
  define buffer buf_temp-supp-gds for temp-supp-gds .
  do
  on error undo, return error return-value
  :
    find first buf_temp-supp-gds
      where buf_temp-supp-gds.cli-type  = p-cli-type
        and buf_temp-supp-gds.cli-code  = p-cli-code
        and buf_temp-supp-gds.artic     = p-artic
        and buf_temp-supp-gds.prod-type = p-prod-type
        and buf_temp-supp-gds.prod-code = p-prod-code
      no-error .
    if not available buf_temp-supp-gds
    then do:
      create buf_temp-supp-gds .
      assign
        buf_temp-supp-gds.cli-type  = p-cli-type
        buf_temp-supp-gds.cli-code  = p-cli-code
        buf_temp-supp-gds.artic     = p-artic
        buf_temp-supp-gds.prod-type = p-prod-type
        buf_temp-supp-gds.prod-code = p-prod-code
      .
    end.
  end.
end procedure.
procedure temp-supp-gds-fill :
  define input  parameter p-obj-type   as character no-undo .
  define input  parameter p-obj-code   as integer   no-undo .
  define input  parameter p-fact-order as decimal   no-undo .
  define buffer buf_stk-supp-line for ub.stk-supp-line .
  do
  on error undo, return error return-value
  :
    for each buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type   = p-obj-type
        and buf_stk-supp-line.obj-code   = p-obj-code
        and buf_stk-supp-line.fact-order <= p-fact-order
    on error undo, return error return-value
    :
      run temp-supp-create in this-procedure
        (input buf_stk-supp-line.cli-type
        ,input buf_stk-supp-line.cli-code
        ) .
      run temp-supp-gds-create in this-procedure
        (input buf_stk-supp-line.cli-type
        ,input buf_stk-supp-line.cli-code
        ,input buf_stk-supp-line.artic
        ,input buf_stk-supp-line.prod-type
        ,input buf_stk-supp-line.prod-code
        ) .
    end.
  end.
end procedure.
procedure temp-supp-gds-from-doclslib :
  define buffer buf_doclslib-clients for doclslib-clients .
  define buffer buf_doclslib-clients-goods for doclslib-clients-goods .
  define buffer buf_temp-supp for temp-supp .
  define buffer buf_temp-supp-gds for temp-supp-gds .
  do
  on error undo, return error return-value
  :
    for each buf_doclslib-clients
    on error undo, return error return-value
    :
      run temp-supp-create in this-procedure
        (input buf_doclslib-clients.cli-type
        ,input buf_doclslib-clients.cli-code
        ) .
    end.
    for each buf_doclslib-clients-goods
    on error undo, return error return-value
    :
      run temp-supp-gds-create in this-procedure
        (input buf_doclslib-clients-goods.cli-type
        ,input buf_doclslib-clients-goods.cli-code
        ,input buf_doclslib-clients-goods.artic
        ,input buf_doclslib-clients-goods.prod-type
        ,input buf_doclslib-clients-goods.prod-code
        ) .
    end.
  end.
end procedure.
procedure ahrstutl-init :
  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-fact-date          as date      no-undo .
  define input  parameter p-save-new           as logical   no-undo .
  define buffer buf_doclslib-clients for doclslib-clients .
  define buffer buf_doclslib-clients-goods for doclslib-clients-goods .
  define variable v-shift-on                as logical   no-undo .
  define variable v-shift-date              as date      no-undo .
  define variable v-shift-num               as integer   no-undo .
  define variable v-day-end-fact-order      as decimal   no-undo .
  define variable v-shift-end-fact-order    as decimal   no-undo .
  define variable v-create-fact-order       as decimal   no-undo .
  define variable v-shift-create-fact-order as decimal   no-undo .
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
    if p-save-new = true
    then do:
      assign
        v-day-end-fact-order   = v-day-end-fact-order - 0.0000000001
        v-shift-end-fact-order = v-shift-end-fact-order - 0.0000000001
      .
    end.
    run ahrstutl-supp-tot-sum-type-list in this-procedure
      (output v-sum-type-list
      ) .
    run show-action in this-procedure
      (input "Остаток по поставщикам. Считывание"
      ).
    define variable v-ind as integer   no-undo .
    do v-ind = 1 to num-entries(v-sum-type-list)
    :
      for each buf_doclslib-clients
      on error undo, return error return-value
      :
        run ahrstutl-init-supp-tot in this-procedure
          (input p-obj-type
          ,input p-obj-code
          ,input buf_doclslib-clients.cli-type
          ,input buf_doclslib-clients.cli-code
          ,input entry(v-ind, v-sum-type-list)
          ,input p-fact-date
          ,input v-day-end-fact-order
          ,input v-create-fact-order
          ,input v-shift-on
          ,input v-shift-date
          ,input v-shift-num
          ,input v-shift-end-fact-order
          ,input v-shift-create-fact-order
          ,input p-save-new
          ) .
      end.
    end.
    run ahrstutl-supp-line-sum-type-list in this-procedure
      (output v-sum-type-list
      ) .
    run show-action in this-procedure
      (input "Остаток по поставщикам и товарам. Считывание"
      ).
    define variable v-total-count as integer   no-undo .
    for each buf_doclslib-clients-goods
    on error undo, return error return-value
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Артикул " + string(buf_doclslib-clients-goods.artic)
          ).
      end.
      do v-ind = 1 to num-entries(v-sum-type-list)
      :
        run ahrstutl-init-supp-line in this-procedure
          (input p-obj-type
          ,input p-obj-code
          ,input buf_doclslib-clients-goods.cli-type
          ,input buf_doclslib-clients-goods.cli-code
          ,input buf_doclslib-clients-goods.artic
          ,input buf_doclslib-clients-goods.prod-type
          ,input buf_doclslib-clients-goods.prod-code
          ,input entry(v-ind, v-sum-type-list)
          ,input p-fact-date
          ,input v-day-end-fact-order
          ,input v-create-fact-order
          ,input v-shift-on
          ,input v-shift-date
          ,input v-shift-num
          ,input v-shift-end-fact-order
          ,input v-shift-create-fact-order
          ,input p-save-new
          ) .
      end.
    end.
  end.
end procedure.
procedure ahrstutl-init-supp-tot :
  define input  parameter p-obj-type                      as character no-undo .
  define input  parameter p-obj-code                      as integer   no-undo .
  define input  parameter p-cli-type                      as character no-undo .
  define input  parameter p-cli-code                      as integer   no-undo .
  define input  parameter p-root-sum-type                 as character no-undo .
  define input  parameter p-fact-date                     as date      no-undo .
  define input  parameter p-stk-supp-tot-fact-order       as decimal   no-undo .
  define input  parameter p-create-tot-fact-order         as decimal   no-undo .
  define input  parameter p-shift-on                      as logical   no-undo .
  define input  parameter p-shift-date                    as date      no-undo .
  define input  parameter p-shift-num                     as integer   no-undo .
  define input  parameter p-shift-stk-supp-tot-fact-order as decimal   no-undo .
  define input  parameter p-shift-create-tot-fact-order   as decimal   no-undo .
  define input  parameter p-save-new                      as logical   no-undo .
  define buffer buf_stk-supp-tot for ub.stk-supp-tot .
  define buffer buf_temp-stk-supp-tot for temp-stk-supp-tot .
  define buffer buf_temp-shift-stk-supp-tot for temp-shift-stk-supp-tot .
  define buffer buf_temp-create-stk-supp-tot for temp-create-stk-supp-tot .
  define variable v-prev-stk-supp-tot-fact-order  like ub.stk-supp-tot.fact-order no-undo .
  define variable v-create-stk as logical   no-undo .
  do
  on error undo, return error return-value
  :
    find last buf_stk-supp-tot no-lock
      where buf_stk-supp-tot.obj-type   = p-obj-type
        and buf_stk-supp-tot.obj-code   = p-obj-code
        and buf_stk-supp-tot.cli-type   = p-cli-type
        and buf_stk-supp-tot.cli-code   = p-cli-code
        and buf_stk-supp-tot.sum-type   = p-root-sum-type
        and buf_stk-supp-tot.cat-id     = '##':U
        and buf_stk-supp-tot.fact-order <= p-stk-supp-tot-fact-order
      use-index category
      no-error .
    if available buf_stk-supp-tot
    then do:
      assign
        v-prev-stk-supp-tot-fact-order = buf_stk-supp-tot.fact-order
      .
      if v-prev-stk-supp-tot-fact-order <> p-stk-supp-tot-fact-order
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
      for each buf_stk-supp-tot no-lock
        where buf_stk-supp-tot.obj-type   = p-obj-type
          and buf_stk-supp-tot.obj-code   = p-obj-code
          and buf_stk-supp-tot.cli-type   = p-cli-type
          and buf_stk-supp-tot.cli-code   = p-cli-code
          and buf_stk-supp-tot.fact-order = v-prev-stk-supp-tot-fact-order
          and buf_stk-supp-tot.sum-type   begins p-root-sum-type
      on error undo, return error return-value
      :
        find first buf_temp-stk-supp-tot
          where buf_temp-stk-supp-tot.obj-type   = buf_stk-supp-tot.obj-type
            and buf_temp-stk-supp-tot.obj-code   = buf_stk-supp-tot.obj-code
            and buf_temp-stk-supp-tot.cli-type   = buf_stk-supp-tot.cli-type
            and buf_temp-stk-supp-tot.cli-code   = buf_stk-supp-tot.cli-code
            and buf_temp-stk-supp-tot.fact-order = p-create-tot-fact-order
            and buf_temp-stk-supp-tot.sum-type   = buf_stk-supp-tot.sum-type
            and buf_temp-stk-supp-tot.cat-id     = buf_stk-supp-tot.cat-id
          no-error .
        if not available buf_temp-stk-supp-tot
        then do:
          create buf_temp-stk-supp-tot .
          assign
                                    buf_temp-stk-supp-tot.obj-type     = buf_stk-supp-tot.obj-type     buf_temp-stk-supp-tot.obj-code     = buf_stk-supp-tot.obj-code     buf_temp-stk-supp-tot.cli-type     = buf_stk-supp-tot.cli-type     buf_temp-stk-supp-tot.cli-code     = buf_stk-supp-tot.cli-code     buf_temp-stk-supp-tot.fact-order   = buf_stk-supp-tot.fact-order   buf_temp-stk-supp-tot.sum-type     = buf_stk-supp-tot.sum-type     buf_temp-stk-supp-tot.cat-id       = buf_stk-supp-tot.cat-id       buf_temp-stk-supp-tot.fact-date    = buf_stk-supp-tot.fact-date    buf_temp-stk-supp-tot.shift-num    = buf_stk-supp-tot.shift-num    buf_temp-stk-supp-tot.shift-date   = buf_stk-supp-tot.shift-date
            buf_temp-stk-supp-tot.fact-order = p-create-tot-fact-order
            buf_temp-stk-supp-tot.fact-date  = p-fact-date
            buf_temp-stk-supp-tot.shift-num  = 0
            buf_temp-stk-supp-tot.shift-date = ?
          .
        end.
        if p-save-new = true
        then do:
          assign
                                                                                    buf_temp-stk-supp-tot.new-fact-qnty      = buf_stk-supp-tot.fact-qnty            buf_temp-stk-supp-tot.new-sum-base       = buf_stk-supp-tot.sum-base             buf_temp-stk-supp-tot.new-sum-rubl       = buf_stk-supp-tot.sum-rubl             buf_temp-stk-supp-tot.new-vat-base       = buf_stk-supp-tot.vat-base             buf_temp-stk-supp-tot.new-vat-rubl       = buf_stk-supp-tot.vat-rubl             buf_temp-stk-supp-tot.new-slt-base       = buf_stk-supp-tot.slt-base             buf_temp-stk-supp-tot.new-slt-rubl       = buf_stk-supp-tot.slt-rubl             buf_temp-stk-supp-tot.new-road-tax-base  = buf_stk-supp-tot.road-tax-base        buf_temp-stk-supp-tot.new-road-tax-rubl  = buf_stk-supp-tot.road-tax-rubl        buf_temp-stk-supp-tot.new-excise-base    = buf_stk-supp-tot.excise-base          buf_temp-stk-supp-tot.new-excise-rubl    = buf_stk-supp-tot.excise-rubl          buf_temp-stk-supp-tot.new-transport-base = buf_stk-supp-tot.transport-base       buf_temp-stk-supp-tot.new-transport-rubl = buf_stk-supp-tot.transport-rubl       buf_temp-stk-supp-tot.new-other-base     = buf_stk-supp-tot.other-base           buf_temp-stk-supp-tot.new-other-rubl     = buf_stk-supp-tot.other-rubl
          .
        end.
        else do:
          assign
                                                                                    buf_temp-stk-supp-tot.fact-qnty      = buf_stk-supp-tot.fact-qnty            buf_temp-stk-supp-tot.sum-base       = buf_stk-supp-tot.sum-base             buf_temp-stk-supp-tot.sum-rubl       = buf_stk-supp-tot.sum-rubl             buf_temp-stk-supp-tot.vat-base       = buf_stk-supp-tot.vat-base             buf_temp-stk-supp-tot.vat-rubl       = buf_stk-supp-tot.vat-rubl             buf_temp-stk-supp-tot.slt-base       = buf_stk-supp-tot.slt-base             buf_temp-stk-supp-tot.slt-rubl       = buf_stk-supp-tot.slt-rubl             buf_temp-stk-supp-tot.road-tax-base  = buf_stk-supp-tot.road-tax-base        buf_temp-stk-supp-tot.road-tax-rubl  = buf_stk-supp-tot.road-tax-rubl        buf_temp-stk-supp-tot.excise-base    = buf_stk-supp-tot.excise-base          buf_temp-stk-supp-tot.excise-rubl    = buf_stk-supp-tot.excise-rubl          buf_temp-stk-supp-tot.transport-base = buf_stk-supp-tot.transport-base       buf_temp-stk-supp-tot.transport-rubl = buf_stk-supp-tot.transport-rubl       buf_temp-stk-supp-tot.other-base     = buf_stk-supp-tot.other-base           buf_temp-stk-supp-tot.other-rubl     = buf_stk-supp-tot.other-rubl
          .
        end.
        if p-shift-on
        then do:
          find first buf_temp-shift-stk-supp-tot
            where buf_temp-shift-stk-supp-tot.obj-type   = buf_stk-supp-tot.obj-type
              and buf_temp-shift-stk-supp-tot.obj-code   = buf_stk-supp-tot.obj-code
              and buf_temp-shift-stk-supp-tot.cli-type   = buf_stk-supp-tot.cli-type
              and buf_temp-shift-stk-supp-tot.cli-code   = buf_stk-supp-tot.cli-code
              and buf_temp-shift-stk-supp-tot.fact-order = p-shift-create-tot-fact-order
              and buf_temp-shift-stk-supp-tot.sum-type   = buf_stk-supp-tot.sum-type
              and buf_temp-shift-stk-supp-tot.cat-id     = buf_stk-supp-tot.cat-id
            no-error .
          if not available buf_temp-shift-stk-supp-tot
          then do:
            create buf_temp-shift-stk-supp-tot .
            assign
                                          buf_temp-shift-stk-supp-tot.obj-type     = buf_stk-supp-tot.obj-type     buf_temp-shift-stk-supp-tot.obj-code     = buf_stk-supp-tot.obj-code     buf_temp-shift-stk-supp-tot.cli-type     = buf_stk-supp-tot.cli-type     buf_temp-shift-stk-supp-tot.cli-code     = buf_stk-supp-tot.cli-code     buf_temp-shift-stk-supp-tot.fact-order   = buf_stk-supp-tot.fact-order   buf_temp-shift-stk-supp-tot.sum-type     = buf_stk-supp-tot.sum-type     buf_temp-shift-stk-supp-tot.cat-id       = buf_stk-supp-tot.cat-id       buf_temp-shift-stk-supp-tot.fact-date    = buf_stk-supp-tot.fact-date    buf_temp-shift-stk-supp-tot.shift-num    = buf_stk-supp-tot.shift-num    buf_temp-shift-stk-supp-tot.shift-date   = buf_stk-supp-tot.shift-date
              buf_temp-shift-stk-supp-tot.fact-order = p-shift-create-tot-fact-order
              buf_temp-shift-stk-supp-tot.fact-date  = p-fact-date
              buf_temp-shift-stk-supp-tot.shift-date = p-shift-date
              buf_temp-shift-stk-supp-tot.shift-num  = p-shift-num
            .
          end.
          if p-save-new = true
          then do:
            assign
                                                                                                  buf_temp-shift-stk-supp-tot.new-fact-qnty      = buf_stk-supp-tot.fact-qnty            buf_temp-shift-stk-supp-tot.new-sum-base       = buf_stk-supp-tot.sum-base             buf_temp-shift-stk-supp-tot.new-sum-rubl       = buf_stk-supp-tot.sum-rubl             buf_temp-shift-stk-supp-tot.new-vat-base       = buf_stk-supp-tot.vat-base             buf_temp-shift-stk-supp-tot.new-vat-rubl       = buf_stk-supp-tot.vat-rubl             buf_temp-shift-stk-supp-tot.new-slt-base       = buf_stk-supp-tot.slt-base             buf_temp-shift-stk-supp-tot.new-slt-rubl       = buf_stk-supp-tot.slt-rubl             buf_temp-shift-stk-supp-tot.new-road-tax-base  = buf_stk-supp-tot.road-tax-base        buf_temp-shift-stk-supp-tot.new-road-tax-rubl  = buf_stk-supp-tot.road-tax-rubl        buf_temp-shift-stk-supp-tot.new-excise-base    = buf_stk-supp-tot.excise-base          buf_temp-shift-stk-supp-tot.new-excise-rubl    = buf_stk-supp-tot.excise-rubl          buf_temp-shift-stk-supp-tot.new-transport-base = buf_stk-supp-tot.transport-base       buf_temp-shift-stk-supp-tot.new-transport-rubl = buf_stk-supp-tot.transport-rubl       buf_temp-shift-stk-supp-tot.new-other-base     = buf_stk-supp-tot.other-base           buf_temp-shift-stk-supp-tot.new-other-rubl     = buf_stk-supp-tot.other-rubl
            .
          end.
          else do:
            assign
                                                                                                  buf_temp-shift-stk-supp-tot.fact-qnty      = buf_stk-supp-tot.fact-qnty            buf_temp-shift-stk-supp-tot.sum-base       = buf_stk-supp-tot.sum-base             buf_temp-shift-stk-supp-tot.sum-rubl       = buf_stk-supp-tot.sum-rubl             buf_temp-shift-stk-supp-tot.vat-base       = buf_stk-supp-tot.vat-base             buf_temp-shift-stk-supp-tot.vat-rubl       = buf_stk-supp-tot.vat-rubl             buf_temp-shift-stk-supp-tot.slt-base       = buf_stk-supp-tot.slt-base             buf_temp-shift-stk-supp-tot.slt-rubl       = buf_stk-supp-tot.slt-rubl             buf_temp-shift-stk-supp-tot.road-tax-base  = buf_stk-supp-tot.road-tax-base        buf_temp-shift-stk-supp-tot.road-tax-rubl  = buf_stk-supp-tot.road-tax-rubl        buf_temp-shift-stk-supp-tot.excise-base    = buf_stk-supp-tot.excise-base          buf_temp-shift-stk-supp-tot.excise-rubl    = buf_stk-supp-tot.excise-rubl          buf_temp-shift-stk-supp-tot.transport-base = buf_stk-supp-tot.transport-base       buf_temp-shift-stk-supp-tot.transport-rubl = buf_stk-supp-tot.transport-rubl       buf_temp-shift-stk-supp-tot.other-base     = buf_stk-supp-tot.other-base           buf_temp-shift-stk-supp-tot.other-rubl     = buf_stk-supp-tot.other-rubl
            .
          end.
        end.
      end.
    end.
    else do:
      assign
        v-create-stk = true
      .
      find first buf_temp-stk-supp-tot
        where buf_temp-stk-supp-tot.obj-type   = p-obj-type
          and buf_temp-stk-supp-tot.obj-code   = p-obj-code
          and buf_temp-stk-supp-tot.cli-type   = p-cli-type
          and buf_temp-stk-supp-tot.cli-code   = p-cli-code
          and buf_temp-stk-supp-tot.fact-order = p-create-tot-fact-order
          and buf_temp-stk-supp-tot.sum-type   = p-root-sum-type
          and buf_temp-stk-supp-tot.cat-id     = '##':U
        no-error .
      if not available buf_temp-stk-supp-tot
      then do:
        create buf_temp-stk-supp-tot .
        assign
          buf_temp-stk-supp-tot.obj-type   = p-obj-type
          buf_temp-stk-supp-tot.obj-code   = p-obj-code
          buf_temp-stk-supp-tot.cli-type   = p-cli-type
          buf_temp-stk-supp-tot.cli-code   = p-cli-code
          buf_temp-stk-supp-tot.sum-type   = p-root-sum-type
          buf_temp-stk-supp-tot.cat-id     = '##':U
          buf_temp-stk-supp-tot.fact-order = p-create-tot-fact-order
          buf_temp-stk-supp-tot.fact-date  = p-fact-date
          buf_temp-stk-supp-tot.shift-num  = 0
          buf_temp-stk-supp-tot.shift-date = ?
        .
      end.
      if p-shift-on = true
      then do:
        find first buf_temp-shift-stk-supp-tot
          where buf_temp-shift-stk-supp-tot.obj-type   = p-obj-type
            and buf_temp-shift-stk-supp-tot.obj-code   = p-obj-code
            and buf_temp-shift-stk-supp-tot.cli-type   = p-cli-type
            and buf_temp-shift-stk-supp-tot.cli-code   = p-cli-code
            and buf_temp-shift-stk-supp-tot.fact-order = p-shift-create-tot-fact-order
            and buf_temp-shift-stk-supp-tot.sum-type   = p-root-sum-type
            and buf_temp-shift-stk-supp-tot.cat-id     = '##':U
          no-error .
        if not available buf_temp-shift-stk-supp-tot
        then do:
          create buf_temp-shift-stk-supp-tot .
          assign
            buf_temp-shift-stk-supp-tot.obj-type   = p-obj-type
            buf_temp-shift-stk-supp-tot.obj-code   = p-obj-code
            buf_temp-shift-stk-supp-tot.cli-type   = p-cli-type
            buf_temp-shift-stk-supp-tot.cli-code   = p-cli-code
            buf_temp-shift-stk-supp-tot.sum-type   = p-root-sum-type
            buf_temp-shift-stk-supp-tot.cat-id     = '##':U
            buf_temp-shift-stk-supp-tot.fact-order = p-shift-create-tot-fact-order
            buf_temp-shift-stk-supp-tot.fact-date  = p-fact-date
            buf_temp-shift-stk-supp-tot.shift-date = p-shift-date
            buf_temp-shift-stk-supp-tot.shift-num  = p-shift-num
          .
        end.
      end.
    end.
    if p-save-new = false
    then do:
      create buf_temp-create-stk-supp-tot .
      assign
        buf_temp-create-stk-supp-tot.obj-type    = p-obj-type
        buf_temp-create-stk-supp-tot.obj-code    = p-obj-code
        buf_temp-create-stk-supp-tot.cli-type    = p-cli-type
        buf_temp-create-stk-supp-tot.cli-code    = p-cli-code
        buf_temp-create-stk-supp-tot.sum-type    = p-root-sum-type
        buf_temp-create-stk-supp-tot.need-create = v-create-stk
      .
    end.
  end.
end procedure.
procedure ahrstutl-init-supp-line :
  define input  parameter p-obj-type                       like ub.stk-supp-line.obj-type  no-undo .
  define input  parameter p-obj-code                       like ub.stk-supp-line.obj-code  no-undo .
  define input  parameter p-cli-type                       like ub.stk-supp-line.cli-type  no-undo .
  define input  parameter p-cli-code                       like ub.stk-supp-line.cli-code  no-undo .
  define input  parameter p-artic                          like ub.stk-supp-line.artic     no-undo .
  define input  parameter p-prod-type                      like ub.stk-supp-line.prod-type no-undo .
  define input  parameter p-prod-code                      like ub.stk-supp-line.prod-code no-undo .
  define input  parameter p-root-sum-type                  as character no-undo .
  define input  parameter p-fact-date                      as date      no-undo .
  define input  parameter p-stk-supp-line-fact-order       as decimal   no-undo .
  define input  parameter p-create-line-fact-order         as decimal   no-undo .
  define input  parameter p-shift-on                       as logical   no-undo .
  define input  parameter p-shift-date                     as date      no-undo .
  define input  parameter p-shift-num                      as integer   no-undo .
  define input  parameter p-shift-stk-supp-line-fact-order as decimal   no-undo .
  define input  parameter p-shift-create-line-fact-order   as decimal   no-undo .
  define input  parameter p-save-new                       as logical   no-undo .
  define buffer buf_stk-supp-line for ub.stk-supp-line .
  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_temp-shift-stk-supp-line for temp-shift-stk-supp-line .
  define buffer buf_temp-create-stk-supp-line for temp-create-stk-supp-line .
  define variable v-prev-stk-supp-line-fact-order like ub.stk-line.fact-order no-undo .
  define variable v-create-stk as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-create-stk = false
    .
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type   = p-obj-type
        and buf_stk-supp-line.obj-code   = p-obj-code
        and buf_stk-supp-line.cli-type   = p-cli-type
        and buf_stk-supp-line.cli-code   = p-cli-code
        and buf_stk-supp-line.artic      = p-artic
        and buf_stk-supp-line.prod-type  = p-prod-type
        and buf_stk-supp-line.prod-code  = p-prod-code
        and buf_stk-supp-line.sum-type   = p-root-sum-type
        and buf_stk-supp-line.fact-order <= p-stk-supp-line-fact-order
      use-index category
      no-error .
    if available buf_stk-supp-line
    then do:
      assign
        v-prev-stk-supp-line-fact-order = buf_stk-supp-line.fact-order
      .
      if v-prev-stk-supp-line-fact-order <> p-stk-supp-line-fact-order
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
      for each buf_stk-supp-line no-lock
        where buf_stk-supp-line.obj-type   = p-obj-type
          and buf_stk-supp-line.obj-code   = p-obj-code
          and buf_stk-supp-line.cli-type   = p-cli-type
          and buf_stk-supp-line.cli-code   = p-cli-code
          and buf_stk-supp-line.artic      = p-artic
          and buf_stk-supp-line.prod-type  = p-prod-type
          and buf_stk-supp-line.prod-code  = p-prod-code
          and buf_stk-supp-line.fact-order = v-prev-stk-supp-line-fact-order
          and buf_stk-supp-line.sum-type   begins p-root-sum-type
      on error undo, return error return-value
      :
        find first buf_temp-stk-supp-line
          where buf_temp-stk-supp-line.obj-type   = buf_stk-supp-line.obj-type
            and buf_temp-stk-supp-line.obj-code   = buf_stk-supp-line.obj-code
            and buf_temp-stk-supp-line.cli-type   = buf_stk-supp-line.cli-type
            and buf_temp-stk-supp-line.cli-code   = buf_stk-supp-line.cli-code
            and buf_temp-stk-supp-line.artic      = buf_stk-supp-line.artic
            and buf_temp-stk-supp-line.prod-type  = buf_stk-supp-line.prod-type
            and buf_temp-stk-supp-line.prod-code  = buf_stk-supp-line.prod-code
            and buf_temp-stk-supp-line.fact-order = p-create-line-fact-order
            and buf_temp-stk-supp-line.sum-type   = buf_stk-supp-line.sum-type
            and buf_temp-stk-supp-line.cat-id     = buf_stk-supp-line.cat-id
          no-error .
        if not available buf_temp-stk-supp-line
        then do:
          create buf_temp-stk-supp-line .
          assign
                                    buf_temp-stk-supp-line.obj-type     = buf_stk-supp-line.obj-type     buf_temp-stk-supp-line.obj-code     = buf_stk-supp-line.obj-code     buf_temp-stk-supp-line.cli-type     = buf_stk-supp-line.cli-type     buf_temp-stk-supp-line.cli-code     = buf_stk-supp-line.cli-code     buf_temp-stk-supp-line.artic        = buf_stk-supp-line.artic        buf_temp-stk-supp-line.prod-type    = buf_stk-supp-line.prod-type    buf_temp-stk-supp-line.prod-code    = buf_stk-supp-line.prod-code    buf_temp-stk-supp-line.fact-order   = buf_stk-supp-line.fact-order   buf_temp-stk-supp-line.sum-type     = buf_stk-supp-line.sum-type     buf_temp-stk-supp-line.cat-id       = buf_stk-supp-line.cat-id       buf_temp-stk-supp-line.fact-date    = buf_stk-supp-line.fact-date    buf_temp-stk-supp-line.shift-num    = buf_stk-supp-line.shift-num    buf_temp-stk-supp-line.shift-date   = buf_stk-supp-line.shift-date
            buf_temp-stk-supp-line.fact-order = p-create-line-fact-order
            buf_temp-stk-supp-line.fact-date  = p-fact-date
            buf_temp-stk-supp-line.shift-num  = 0
            buf_temp-stk-supp-line.shift-date = ?
          .
        end.
        if p-save-new = true
        then do:
          assign
                                                                                    buf_temp-stk-supp-line.new-fact-qnty      = buf_stk-supp-line.fact-qnty            buf_temp-stk-supp-line.new-sum-base       = buf_stk-supp-line.sum-base             buf_temp-stk-supp-line.new-sum-rubl       = buf_stk-supp-line.sum-rubl             buf_temp-stk-supp-line.new-vat-base       = buf_stk-supp-line.vat-base             buf_temp-stk-supp-line.new-vat-rubl       = buf_stk-supp-line.vat-rubl             buf_temp-stk-supp-line.new-slt-base       = buf_stk-supp-line.slt-base             buf_temp-stk-supp-line.new-slt-rubl       = buf_stk-supp-line.slt-rubl             buf_temp-stk-supp-line.new-road-tax-base  = buf_stk-supp-line.road-tax-base        buf_temp-stk-supp-line.new-road-tax-rubl  = buf_stk-supp-line.road-tax-rubl        buf_temp-stk-supp-line.new-excise-base    = buf_stk-supp-line.excise-base          buf_temp-stk-supp-line.new-excise-rubl    = buf_stk-supp-line.excise-rubl          buf_temp-stk-supp-line.new-transport-base = buf_stk-supp-line.transport-base       buf_temp-stk-supp-line.new-transport-rubl = buf_stk-supp-line.transport-rubl       buf_temp-stk-supp-line.new-other-base     = buf_stk-supp-line.other-base           buf_temp-stk-supp-line.new-other-rubl     = buf_stk-supp-line.other-rubl
          .
        end.
        else do:
          assign
                                                                                    buf_temp-stk-supp-line.fact-qnty      = buf_stk-supp-line.fact-qnty            buf_temp-stk-supp-line.sum-base       = buf_stk-supp-line.sum-base             buf_temp-stk-supp-line.sum-rubl       = buf_stk-supp-line.sum-rubl             buf_temp-stk-supp-line.vat-base       = buf_stk-supp-line.vat-base             buf_temp-stk-supp-line.vat-rubl       = buf_stk-supp-line.vat-rubl             buf_temp-stk-supp-line.slt-base       = buf_stk-supp-line.slt-base             buf_temp-stk-supp-line.slt-rubl       = buf_stk-supp-line.slt-rubl             buf_temp-stk-supp-line.road-tax-base  = buf_stk-supp-line.road-tax-base        buf_temp-stk-supp-line.road-tax-rubl  = buf_stk-supp-line.road-tax-rubl        buf_temp-stk-supp-line.excise-base    = buf_stk-supp-line.excise-base          buf_temp-stk-supp-line.excise-rubl    = buf_stk-supp-line.excise-rubl          buf_temp-stk-supp-line.transport-base = buf_stk-supp-line.transport-base       buf_temp-stk-supp-line.transport-rubl = buf_stk-supp-line.transport-rubl       buf_temp-stk-supp-line.other-base     = buf_stk-supp-line.other-base           buf_temp-stk-supp-line.other-rubl     = buf_stk-supp-line.other-rubl
          .
        end.
        if p-shift-on
        then do:
          find first buf_temp-shift-stk-supp-line
            where buf_temp-shift-stk-supp-line.obj-type   = buf_stk-supp-line.obj-type
              and buf_temp-shift-stk-supp-line.obj-code   = buf_stk-supp-line.obj-code
              and buf_temp-shift-stk-supp-line.cli-type   = buf_stk-supp-line.cli-type
              and buf_temp-shift-stk-supp-line.cli-code   = buf_stk-supp-line.cli-code
              and buf_temp-shift-stk-supp-line.artic      = buf_stk-supp-line.artic
              and buf_temp-shift-stk-supp-line.prod-type  = buf_stk-supp-line.prod-type
              and buf_temp-shift-stk-supp-line.prod-code  = buf_stk-supp-line.prod-code
              and buf_temp-shift-stk-supp-line.fact-order = p-shift-create-line-fact-order
              and buf_temp-shift-stk-supp-line.sum-type   = buf_stk-supp-line.sum-type
              and buf_temp-shift-stk-supp-line.cat-id     = buf_stk-supp-line.cat-id
            no-error .
          if not available buf_temp-shift-stk-supp-line
          then do:
            create buf_temp-shift-stk-supp-line .
            assign
                                          buf_temp-shift-stk-supp-line.obj-type     = buf_stk-supp-line.obj-type     buf_temp-shift-stk-supp-line.obj-code     = buf_stk-supp-line.obj-code     buf_temp-shift-stk-supp-line.cli-type     = buf_stk-supp-line.cli-type     buf_temp-shift-stk-supp-line.cli-code     = buf_stk-supp-line.cli-code     buf_temp-shift-stk-supp-line.artic        = buf_stk-supp-line.artic        buf_temp-shift-stk-supp-line.prod-type    = buf_stk-supp-line.prod-type    buf_temp-shift-stk-supp-line.prod-code    = buf_stk-supp-line.prod-code    buf_temp-shift-stk-supp-line.fact-order   = buf_stk-supp-line.fact-order   buf_temp-shift-stk-supp-line.sum-type     = buf_stk-supp-line.sum-type     buf_temp-shift-stk-supp-line.cat-id       = buf_stk-supp-line.cat-id       buf_temp-shift-stk-supp-line.fact-date    = buf_stk-supp-line.fact-date    buf_temp-shift-stk-supp-line.shift-num    = buf_stk-supp-line.shift-num    buf_temp-shift-stk-supp-line.shift-date   = buf_stk-supp-line.shift-date
              buf_temp-shift-stk-supp-line.fact-order = p-shift-create-line-fact-order
              buf_temp-shift-stk-supp-line.fact-date  = p-fact-date
              buf_temp-shift-stk-supp-line.shift-date = p-shift-date
              buf_temp-shift-stk-supp-line.shift-num  = p-shift-num
            .
          end.
          if p-save-new = true
          then do:
            assign
                                                                                                  buf_temp-shift-stk-supp-line.new-fact-qnty      = buf_stk-supp-line.fact-qnty            buf_temp-shift-stk-supp-line.new-sum-base       = buf_stk-supp-line.sum-base             buf_temp-shift-stk-supp-line.new-sum-rubl       = buf_stk-supp-line.sum-rubl             buf_temp-shift-stk-supp-line.new-vat-base       = buf_stk-supp-line.vat-base             buf_temp-shift-stk-supp-line.new-vat-rubl       = buf_stk-supp-line.vat-rubl             buf_temp-shift-stk-supp-line.new-slt-base       = buf_stk-supp-line.slt-base             buf_temp-shift-stk-supp-line.new-slt-rubl       = buf_stk-supp-line.slt-rubl             buf_temp-shift-stk-supp-line.new-road-tax-base  = buf_stk-supp-line.road-tax-base        buf_temp-shift-stk-supp-line.new-road-tax-rubl  = buf_stk-supp-line.road-tax-rubl        buf_temp-shift-stk-supp-line.new-excise-base    = buf_stk-supp-line.excise-base          buf_temp-shift-stk-supp-line.new-excise-rubl    = buf_stk-supp-line.excise-rubl          buf_temp-shift-stk-supp-line.new-transport-base = buf_stk-supp-line.transport-base       buf_temp-shift-stk-supp-line.new-transport-rubl = buf_stk-supp-line.transport-rubl       buf_temp-shift-stk-supp-line.new-other-base     = buf_stk-supp-line.other-base           buf_temp-shift-stk-supp-line.new-other-rubl     = buf_stk-supp-line.other-rubl
            .
          end.
          else do:
            assign
                                                                                                  buf_temp-shift-stk-supp-line.fact-qnty      = buf_stk-supp-line.fact-qnty            buf_temp-shift-stk-supp-line.sum-base       = buf_stk-supp-line.sum-base             buf_temp-shift-stk-supp-line.sum-rubl       = buf_stk-supp-line.sum-rubl             buf_temp-shift-stk-supp-line.vat-base       = buf_stk-supp-line.vat-base             buf_temp-shift-stk-supp-line.vat-rubl       = buf_stk-supp-line.vat-rubl             buf_temp-shift-stk-supp-line.slt-base       = buf_stk-supp-line.slt-base             buf_temp-shift-stk-supp-line.slt-rubl       = buf_stk-supp-line.slt-rubl             buf_temp-shift-stk-supp-line.road-tax-base  = buf_stk-supp-line.road-tax-base        buf_temp-shift-stk-supp-line.road-tax-rubl  = buf_stk-supp-line.road-tax-rubl        buf_temp-shift-stk-supp-line.excise-base    = buf_stk-supp-line.excise-base          buf_temp-shift-stk-supp-line.excise-rubl    = buf_stk-supp-line.excise-rubl          buf_temp-shift-stk-supp-line.transport-base = buf_stk-supp-line.transport-base       buf_temp-shift-stk-supp-line.transport-rubl = buf_stk-supp-line.transport-rubl       buf_temp-shift-stk-supp-line.other-base     = buf_stk-supp-line.other-base           buf_temp-shift-stk-supp-line.other-rubl     = buf_stk-supp-line.other-rubl
            .
          end.
        end.
      end.
    end.
    else do:
      assign
        v-create-stk = true
      .
      find first buf_temp-stk-supp-line
        where buf_temp-stk-supp-line.obj-type   = p-obj-type
          and buf_temp-stk-supp-line.obj-code   = p-obj-code
          and buf_temp-stk-supp-line.cli-type   = p-cli-type
          and buf_temp-stk-supp-line.cli-code   = p-cli-code
          and buf_temp-stk-supp-line.artic      = p-artic
          and buf_temp-stk-supp-line.prod-type  = p-prod-type
          and buf_temp-stk-supp-line.prod-code  = p-prod-code
          and buf_temp-stk-supp-line.fact-order = p-create-line-fact-order
          and buf_temp-stk-supp-line.sum-type   = p-root-sum-type
          and buf_temp-stk-supp-line.cat-id     = '##':U
        no-error .
      if not available buf_temp-stk-supp-line
      then do:
        create buf_temp-stk-supp-line .
        assign
          buf_temp-stk-supp-line.obj-type   = p-obj-type
          buf_temp-stk-supp-line.obj-code   = p-obj-code
          buf_temp-stk-supp-line.cli-type   = p-cli-type
          buf_temp-stk-supp-line.cli-code   = p-cli-code
          buf_temp-stk-supp-line.artic      = p-artic
          buf_temp-stk-supp-line.prod-type  = p-prod-type
          buf_temp-stk-supp-line.prod-code  = p-prod-code
          buf_temp-stk-supp-line.sum-type   = p-root-sum-type
          buf_temp-stk-supp-line.cat-id     = '##':U
          buf_temp-stk-supp-line.fact-order = p-create-line-fact-order
          buf_temp-stk-supp-line.fact-date  = p-fact-date
          buf_temp-stk-supp-line.shift-num  = 0
          buf_temp-stk-supp-line.shift-date = ?
        .
      end.
      if p-shift-on = true
      then do:
        find first buf_temp-shift-stk-supp-line
          where buf_temp-shift-stk-supp-line.obj-type   = p-obj-type
            and buf_temp-shift-stk-supp-line.obj-code   = p-obj-code
            and buf_temp-shift-stk-supp-line.cli-type   = p-cli-type
            and buf_temp-shift-stk-supp-line.cli-code   = p-cli-code
            and buf_temp-shift-stk-supp-line.artic      = p-artic
            and buf_temp-shift-stk-supp-line.prod-type  = p-prod-type
            and buf_temp-shift-stk-supp-line.prod-code  = p-prod-code
            and buf_temp-shift-stk-supp-line.fact-order = p-shift-create-line-fact-order
            and buf_temp-shift-stk-supp-line.sum-type   = p-root-sum-type
            and buf_temp-shift-stk-supp-line.cat-id     = '##':U
          no-error .
        if not available buf_temp-shift-stk-supp-line
        then do:
          create buf_temp-shift-stk-supp-line .
          assign
            buf_temp-shift-stk-supp-line.obj-type   = p-obj-type
            buf_temp-shift-stk-supp-line.obj-code   = p-obj-code
            buf_temp-shift-stk-supp-line.cli-type   = p-cli-type
            buf_temp-shift-stk-supp-line.cli-code   = p-cli-code
            buf_temp-shift-stk-supp-line.artic      = p-artic
            buf_temp-shift-stk-supp-line.prod-type  = p-prod-type
            buf_temp-shift-stk-supp-line.prod-code  = p-prod-code
            buf_temp-shift-stk-supp-line.sum-type   = p-root-sum-type
            buf_temp-shift-stk-supp-line.cat-id     = '##':U
            buf_temp-shift-stk-supp-line.fact-order = p-shift-create-line-fact-order
            buf_temp-shift-stk-supp-line.fact-date  = p-fact-date
            buf_temp-shift-stk-supp-line.shift-date = p-shift-date
            buf_temp-shift-stk-supp-line.shift-num  = p-shift-num
          .
        end.
      end.
    end.
    if p-save-new = false
    then do:
      create buf_temp-create-stk-supp-line .
      assign
        buf_temp-create-stk-supp-line.obj-type    = p-obj-type
        buf_temp-create-stk-supp-line.obj-code    = p-obj-code
        buf_temp-create-stk-supp-line.cli-type    = p-cli-type
        buf_temp-create-stk-supp-line.cli-code    = p-cli-code
        buf_temp-create-stk-supp-line.artic       = p-artic
        buf_temp-create-stk-supp-line.prod-type   = p-prod-type
        buf_temp-create-stk-supp-line.prod-code   = p-prod-code
        buf_temp-create-stk-supp-line.sum-type    = p-root-sum-type
        buf_temp-create-stk-supp-line.need-create = v-create-stk
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
  define buffer buf_temp-create-stk-supp-tot  for temp-create-stk-supp-tot .
  define buffer buf_temp-create-stk-supp-line for temp-create-stk-supp-line .
  define buffer buf_temp-stk-supp-tot for temp-stk-supp-tot .
  define buffer buf_stk-supp-tot for ub.stk-supp-tot .
  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_stk-supp-line for ub.stk-supp-line .
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
    for each buf_temp-create-stk-supp-tot
      where buf_temp-create-stk-supp-tot.need-create = true
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
      for each buf_temp-stk-supp-tot
        where buf_temp-stk-supp-tot.obj-type   = buf_temp-create-stk-supp-tot.obj-type
          and buf_temp-stk-supp-tot.obj-code   = buf_temp-create-stk-supp-tot.obj-code
          and buf_temp-stk-supp-tot.cli-type   = buf_temp-create-stk-supp-tot.cli-type
          and buf_temp-stk-supp-tot.cli-code   = buf_temp-create-stk-supp-tot.cli-code
          and buf_temp-stk-supp-tot.fact-order = v-day-end-fact-order
          and buf_temp-stk-supp-tot.sum-type   begins buf_temp-create-stk-supp-tot.sum-type
      on error undo, return error return-value
      :
        create buf_stk-supp-tot .
        buffer-copy buf_temp-stk-supp-tot to buf_stk-supp-tot
        .
      end.
      if v-shift-on = true
      then do:
        for each buf_temp-stk-supp-tot
          where buf_temp-stk-supp-tot.obj-type   = buf_temp-create-stk-supp-tot.obj-type
            and buf_temp-stk-supp-tot.obj-code   = buf_temp-create-stk-supp-tot.obj-code
            and buf_temp-stk-supp-tot.cli-type   = buf_temp-create-stk-supp-tot.cli-type
            and buf_temp-stk-supp-tot.cli-code   = buf_temp-create-stk-supp-tot.cli-code
            and buf_temp-stk-supp-tot.fact-order = v-shift-end-fact-order
            and buf_temp-stk-supp-tot.sum-type   begins buf_temp-create-stk-supp-tot.sum-type
        on error undo, return error return-value
        :
          create buf_stk-supp-tot .
          buffer-copy buf_temp-stk-supp-tot to buf_stk-supp-tot
          .
        end.
      end.
    end.
    assign
      v-total-count = 0
    .
    for each buf_temp-create-stk-supp-line
      where buf_temp-create-stk-supp-line.need-create = true
    on error undo, return error return-value
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Артикул " + buf_temp-create-stk-supp-line.artic
          ).
      end.
      for each buf_temp-stk-supp-line
        where buf_temp-stk-supp-line.obj-type   = buf_temp-create-stk-supp-line.obj-type
          and buf_temp-stk-supp-line.obj-code   = buf_temp-create-stk-supp-line.obj-code
          and buf_temp-stk-supp-line.cli-type   = buf_temp-create-stk-supp-line.cli-type
          and buf_temp-stk-supp-line.cli-code   = buf_temp-create-stk-supp-line.cli-code
          and buf_temp-stk-supp-line.artic      = buf_temp-create-stk-supp-line.artic
          and buf_temp-stk-supp-line.prod-type  = buf_temp-create-stk-supp-line.prod-type
          and buf_temp-stk-supp-line.prod-code  = buf_temp-create-stk-supp-line.prod-code
          and buf_temp-stk-supp-line.fact-order = v-day-end-fact-order
          and buf_temp-stk-supp-line.sum-type   begins buf_temp-create-stk-supp-line.sum-type
      on error undo, return error return-value
      :
        create buf_stk-supp-line .
        buffer-copy buf_temp-stk-supp-line to buf_stk-supp-line
        .
      end.
      if v-shift-on = true
      then do:
        for each buf_temp-stk-supp-line
          where buf_temp-stk-supp-line.obj-type   = buf_temp-create-stk-supp-line.obj-type
            and buf_temp-stk-supp-line.obj-code   = buf_temp-create-stk-supp-line.obj-code
            and buf_temp-stk-supp-line.cli-type   = buf_temp-create-stk-supp-line.cli-type
            and buf_temp-stk-supp-line.cli-code   = buf_temp-create-stk-supp-line.cli-code
            and buf_temp-stk-supp-line.artic      = buf_temp-create-stk-supp-line.artic
            and buf_temp-stk-supp-line.prod-type  = buf_temp-create-stk-supp-line.prod-type
            and buf_temp-stk-supp-line.prod-code  = buf_temp-create-stk-supp-line.prod-code
            and buf_temp-stk-supp-line.fact-order = v-shift-end-fact-order
            and buf_temp-stk-supp-line.sum-type   begins buf_temp-create-stk-supp-line.sum-type
        on error undo, return error return-value
        :
          create buf_stk-supp-line .
          buffer-copy buf_temp-stk-supp-line to buf_stk-supp-line
          .
        end.
      end.
    end.
  end.
end procedure.
procedure ahrstutl-clear-ahsp :
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-start-fact-order as decimal   no-undo .
  define input  parameter p-fact-date        as date      no-undo .
  define buffer buf_ot-supp-tot   for ub.ot-supp-tot .
  define buffer buf_ot-supp-line  for ub.ot-supp-line .
  define buffer buf_stk-supp-tot  for ub.stk-supp-tot .
  define buffer buf_stk-supp-line for ub.stk-supp-line .
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
      (input "Удаление оборота по документам"
      ).
    assign
      v-ind = 0
    .
    for each buf_ot-supp-tot
      where buf_ot-supp-tot.obj-type   = p-obj-type
        and buf_ot-supp-tot.obj-code   = p-obj-code
        and buf_ot-supp-tot.fact-order > p-start-fact-order
        and buf_ot-supp-tot.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_ot-supp-tot.doc-code)
          ).
      end.
      delete buf_ot-supp-tot .
    end.
    run show-action in this-procedure
      (input "Удаление оборота по строкам документов"
      ).
    assign
      v-ind = 0
    .
    for each buf_ot-supp-line
      where buf_ot-supp-line.obj-type   = p-obj-type
        and buf_ot-supp-line.obj-code   = p-obj-code
        and buf_ot-supp-line.fact-order > p-start-fact-order
        and buf_ot-supp-line.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Документ " + string(buf_ot-supp-line.doc-code)
                  + " Артикул " + string(buf_ot-supp-line.artic)
          ).
      end.
      delete buf_ot-supp-line .
    end.
    run show-action in this-procedure
      (input "Удаление остатка по объекту"
      ).
    assign
      v-ind = 0
    .
    for each buf_stk-supp-tot
      where buf_stk-supp-tot.obj-type   = p-obj-type
        and buf_stk-supp-tot.obj-code   = p-obj-code
        and buf_stk-supp-tot.fact-order > p-start-fact-order
        and buf_stk-supp-tot.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Дата " + string(buf_stk-supp-tot.fact-date, '99/99/9999':U )
          ).
      end.
      if buf_stk-supp-tot.shift-date = ?
      or (buf_stk-supp-tot.shift-date <> ?
          and
          buf_stk-supp-tot.fact-order <= v-shift-end-fact-order
         )
      then do:
        delete buf_stk-supp-tot .
      end.
    end.
    run show-action in this-procedure
      (input "Удаление остатка по товарам на объекте"
      ).
    assign
      v-ind = 0
    .
    for each buf_stk-supp-line
      where buf_stk-supp-line.obj-type   = p-obj-type
        and buf_stk-supp-line.obj-code   = p-obj-code
        and buf_stk-supp-line.fact-order > p-start-fact-order
        and buf_stk-supp-line.fact-order <= v-day-end-fact-order
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-ind
          ,input "Артикул " + string(buf_stk-supp-line.artic)
          ).
      end.
      if buf_stk-supp-line.shift-date = ?
      or (buf_stk-supp-line.shift-date <> ?
          and
          buf_stk-supp-line.fact-order <= v-shift-end-fact-order
         )
      then do:
        delete buf_stk-supp-line .
      end.
    end.
  end.
end procedure.
procedure ahrstutl-delete-copy :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define buffer buf_stk-supp-tot  for ub.stk-supp-tot .
  define buffer buf_stk-supp-line for ub.stk-supp-line .
  define buffer buf_temp-create-stk-supp-tot for temp-create-stk-supp-tot .
  define buffer buf_temp-create-stk-supp-line for temp-create-stk-supp-line .
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
    for each buf_temp-create-stk-supp-tot
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
      find last buf_stk-supp-tot no-lock
        where buf_stk-supp-tot.obj-type   = buf_temp-create-stk-supp-tot.obj-type
          and buf_stk-supp-tot.obj-code   = buf_temp-create-stk-supp-tot.obj-code
          and buf_stk-supp-tot.cli-type   = buf_temp-create-stk-supp-tot.cli-type
          and buf_stk-supp-tot.cli-code   = buf_temp-create-stk-supp-tot.cli-code
          and buf_stk-supp-tot.fact-order = v-day-end-fact-order - 0.0000000001
          and buf_stk-supp-tot.sum-type   = buf_temp-create-stk-supp-tot.sum-type
          and buf_stk-supp-tot.cat-id     = '##':U
        no-error .
      if available buf_stk-supp-tot
      then do:
        for each buf_stk-supp-tot exclusive-lock
          where buf_stk-supp-tot.obj-type   = buf_temp-create-stk-supp-tot.obj-type
            and buf_stk-supp-tot.obj-code   = buf_temp-create-stk-supp-tot.obj-code
            and buf_stk-supp-tot.cli-type   = buf_temp-create-stk-supp-tot.cli-type
            and buf_stk-supp-tot.cli-code   = buf_temp-create-stk-supp-tot.cli-code
            and buf_stk-supp-tot.fact-order = v-day-end-fact-order - 0.0000000001
            and buf_stk-supp-tot.sum-type   begins buf_temp-create-stk-supp-tot.sum-type
        on error undo, return error return-value
        :
          delete buf_stk-supp-tot .
        end.
      end.
      else do:
        for each buf_stk-supp-tot exclusive-lock
          where buf_stk-supp-tot.obj-type   = buf_temp-create-stk-supp-tot.obj-type
            and buf_stk-supp-tot.obj-code   = buf_temp-create-stk-supp-tot.obj-code
            and buf_stk-supp-tot.cli-type   = buf_temp-create-stk-supp-tot.cli-type
            and buf_stk-supp-tot.cli-code   = buf_temp-create-stk-supp-tot.cli-code
            and buf_stk-supp-tot.fact-order = v-day-end-fact-order
            and buf_stk-supp-tot.sum-type   begins buf_temp-create-stk-supp-tot.sum-type
        on error undo, return error return-value
        :
          delete buf_stk-supp-tot .
        end.
      end.
      if v-shift-on = true
      then do:
        find last buf_stk-supp-tot no-lock
          where buf_stk-supp-tot.obj-type   = buf_temp-create-stk-supp-tot.obj-type
            and buf_stk-supp-tot.obj-code   = buf_temp-create-stk-supp-tot.obj-code
            and buf_stk-supp-tot.cli-type   = buf_temp-create-stk-supp-tot.cli-type
            and buf_stk-supp-tot.cli-code   = buf_temp-create-stk-supp-tot.cli-code
            and buf_stk-supp-tot.fact-order = v-shift-end-fact-order - 0.0000000001
            and buf_stk-supp-tot.sum-type   = buf_temp-create-stk-supp-tot.sum-type
            and buf_stk-supp-tot.cat-id     = '##':U
          no-error .
        if available buf_stk-supp-tot
        then do:
          for each buf_stk-supp-tot exclusive-lock
            where buf_stk-supp-tot.obj-type   = buf_temp-create-stk-supp-tot.obj-type
              and buf_stk-supp-tot.obj-code   = buf_temp-create-stk-supp-tot.obj-code
              and buf_stk-supp-tot.cli-type   = buf_temp-create-stk-supp-tot.cli-type
              and buf_stk-supp-tot.cli-code   = buf_temp-create-stk-supp-tot.cli-code
              and buf_stk-supp-tot.fact-order = v-shift-end-fact-order - 0.0000000001
              and buf_stk-supp-tot.sum-type   begins buf_temp-create-stk-supp-tot.sum-type
          on error undo, return error return-value
          :
            delete buf_stk-supp-tot .
          end.
        end.
        else do:
          for each buf_stk-supp-tot exclusive-lock
            where buf_stk-supp-tot.obj-type   = buf_temp-create-stk-supp-tot.obj-type
              and buf_stk-supp-tot.obj-code   = buf_temp-create-stk-supp-tot.obj-code
              and buf_stk-supp-tot.cli-type   = buf_temp-create-stk-supp-tot.cli-type
              and buf_stk-supp-tot.cli-code   = buf_temp-create-stk-supp-tot.cli-code
              and buf_stk-supp-tot.fact-order = v-shift-end-fact-order
              and buf_stk-supp-tot.sum-type   begins buf_temp-create-stk-supp-tot.sum-type
          on error undo, return error return-value
          :
            delete buf_stk-supp-tot .
          end.
        end.
      end.
    end.
    assign
      v-total-count = 0
    .
    for each buf_temp-create-stk-supp-line
    on error undo, return error return-value
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Артикул " + buf_temp-create-stk-supp-line.artic
          ).
      end.
      find first buf_stk-supp-line no-lock
        where buf_stk-supp-line.obj-type   = buf_temp-create-stk-supp-line.obj-type
          and buf_stk-supp-line.obj-code   = buf_temp-create-stk-supp-line.obj-code
          and buf_stk-supp-line.cli-type   = buf_temp-create-stk-supp-line.cli-type
          and buf_stk-supp-line.cli-code   = buf_temp-create-stk-supp-line.cli-code
          and buf_stk-supp-line.artic      = buf_temp-create-stk-supp-line.artic
          and buf_stk-supp-line.prod-type  = buf_temp-create-stk-supp-line.prod-type
          and buf_stk-supp-line.prod-code  = buf_temp-create-stk-supp-line.prod-code
          and buf_stk-supp-line.fact-order = v-day-end-fact-order - 0.0000000001
          and buf_stk-supp-line.sum-type   = buf_temp-create-stk-supp-line.sum-type
          and buf_stk-supp-line.cat-id     = '##':U
        no-error .
      if available buf_stk-supp-line
      then do:
        for each buf_stk-supp-line exclusive-lock
          where buf_stk-supp-line.obj-type   = buf_temp-create-stk-supp-line.obj-type
            and buf_stk-supp-line.obj-code   = buf_temp-create-stk-supp-line.obj-code
            and buf_stk-supp-line.cli-type   = buf_temp-create-stk-supp-line.cli-type
            and buf_stk-supp-line.cli-code   = buf_temp-create-stk-supp-line.cli-code
            and buf_stk-supp-line.artic      = buf_temp-create-stk-supp-line.artic
            and buf_stk-supp-line.prod-type  = buf_temp-create-stk-supp-line.prod-type
            and buf_stk-supp-line.prod-code  = buf_temp-create-stk-supp-line.prod-code
            and buf_stk-supp-line.fact-order = v-day-end-fact-order - 0.0000000001
            and buf_stk-supp-line.sum-type   begins buf_temp-create-stk-supp-line.sum-type
        on error undo, return error return-value
        :
          delete buf_stk-supp-line .
        end.
      end.
      else do:
        for each buf_stk-supp-line exclusive-lock
          where buf_stk-supp-line.obj-type   = buf_temp-create-stk-supp-line.obj-type
            and buf_stk-supp-line.obj-code   = buf_temp-create-stk-supp-line.obj-code
            and buf_stk-supp-line.cli-type   = buf_temp-create-stk-supp-line.cli-type
            and buf_stk-supp-line.cli-code   = buf_temp-create-stk-supp-line.cli-code
            and buf_stk-supp-line.artic      = buf_temp-create-stk-supp-line.artic
            and buf_stk-supp-line.prod-type  = buf_temp-create-stk-supp-line.prod-type
            and buf_stk-supp-line.prod-code  = buf_temp-create-stk-supp-line.prod-code
            and buf_stk-supp-line.fact-order = v-day-end-fact-order
            and buf_stk-supp-line.sum-type   begins buf_temp-create-stk-supp-line.sum-type
        on error undo, return error return-value
        :
          delete buf_stk-supp-line .
        end.
      end.
      if v-shift-on = true
      then do:
        find first buf_stk-supp-line no-lock
          where buf_stk-supp-line.obj-type   = buf_temp-create-stk-supp-line.obj-type
            and buf_stk-supp-line.obj-code   = buf_temp-create-stk-supp-line.obj-code
            and buf_stk-supp-line.cli-type   = buf_temp-create-stk-supp-line.cli-type
            and buf_stk-supp-line.cli-code   = buf_temp-create-stk-supp-line.cli-code
            and buf_stk-supp-line.artic      = buf_temp-create-stk-supp-line.artic
            and buf_stk-supp-line.prod-type  = buf_temp-create-stk-supp-line.prod-type
            and buf_stk-supp-line.prod-code  = buf_temp-create-stk-supp-line.prod-code
            and buf_stk-supp-line.fact-order = v-shift-end-fact-order - 0.0000000001
            and buf_stk-supp-line.sum-type   = buf_temp-create-stk-supp-line.sum-type
            and buf_stk-supp-line.cat-id     = '##':U
          no-error .
        if available buf_stk-supp-line
        then do:
          for each buf_stk-supp-line exclusive-lock
            where buf_stk-supp-line.obj-type   = buf_temp-create-stk-supp-line.obj-type
              and buf_stk-supp-line.obj-code   = buf_temp-create-stk-supp-line.obj-code
              and buf_stk-supp-line.cli-type   = buf_temp-create-stk-supp-line.cli-type
              and buf_stk-supp-line.cli-code   = buf_temp-create-stk-supp-line.cli-code
              and buf_stk-supp-line.artic      = buf_temp-create-stk-supp-line.artic
              and buf_stk-supp-line.prod-type  = buf_temp-create-stk-supp-line.prod-type
              and buf_stk-supp-line.prod-code  = buf_temp-create-stk-supp-line.prod-code
              and buf_stk-supp-line.fact-order = v-shift-end-fact-order - 0.0000000001
              and buf_stk-supp-line.sum-type   begins buf_temp-create-stk-supp-line.sum-type
          on error undo, return error return-value
          :
            delete buf_stk-supp-line .
          end.
        end.
        else do:
          for each buf_stk-supp-line exclusive-lock
            where buf_stk-supp-line.obj-type   = buf_temp-create-stk-supp-line.obj-type
              and buf_stk-supp-line.obj-code   = buf_temp-create-stk-supp-line.obj-code
              and buf_stk-supp-line.cli-type   = buf_temp-create-stk-supp-line.cli-type
              and buf_stk-supp-line.cli-code   = buf_temp-create-stk-supp-line.cli-code
              and buf_stk-supp-line.artic      = buf_temp-create-stk-supp-line.artic
              and buf_stk-supp-line.prod-type  = buf_temp-create-stk-supp-line.prod-type
              and buf_stk-supp-line.prod-code  = buf_temp-create-stk-supp-line.prod-code
              and buf_stk-supp-line.fact-order = v-shift-end-fact-order
              and buf_stk-supp-line.sum-type   begins buf_temp-create-stk-supp-line.sum-type
          on error undo, return error return-value
          :
            delete buf_stk-supp-line .
          end.
        end.
      end.
    end.
    define buffer buf_doclslib-clients-goods for doclslib-clients-goods .
    for each buf_temp-create-stk-supp-line
    on error undo, return error return-value
    :
      find first buf_doclslib-clients-goods
        where buf_doclslib-clients-goods.cli-type  = buf_temp-create-stk-supp-line.cli-type
          and buf_doclslib-clients-goods.cli-code  = buf_temp-create-stk-supp-line.cli-code
          and buf_doclslib-clients-goods.artic     = buf_temp-create-stk-supp-line.artic
          and buf_doclslib-clients-goods.prod-type = buf_temp-create-stk-supp-line.prod-type
          and buf_doclslib-clients-goods.prod-code = buf_temp-create-stk-supp-line.prod-code
        no-error .
      if not available buf_doclslib-clients-goods
      then do:
        for each buf_stk-supp-line exclusive-lock
          where buf_stk-supp-line.obj-type   = p-obj-type
            and buf_stk-supp-line.obj-code   = p-obj-code
            and buf_stk-supp-line.cli-type   = buf_temp-create-stk-supp-line.cli-type
            and buf_stk-supp-line.cli-code   = buf_temp-create-stk-supp-line.cli-code
            and buf_stk-supp-line.artic      = buf_temp-create-stk-supp-line.artic
            and buf_stk-supp-line.prod-type  = buf_temp-create-stk-supp-line.prod-type
            and buf_stk-supp-line.prod-code  = buf_temp-create-stk-supp-line.prod-code
            and buf_stk-supp-line.fact-order = v-day-end-fact-order
        on error undo, return error return-value
        :
          delete buf_stk-supp-line .
        end.
        if v-shift-on = true
        then do:
          for each buf_stk-supp-line exclusive-lock
            where buf_stk-supp-line.obj-type   = p-obj-type
              and buf_stk-supp-line.obj-code   = p-obj-code
              and buf_stk-supp-line.cli-type   = buf_temp-create-stk-supp-line.cli-type
              and buf_stk-supp-line.cli-code   = buf_temp-create-stk-supp-line.cli-code
              and buf_stk-supp-line.artic      = buf_temp-create-stk-supp-line.artic
              and buf_stk-supp-line.prod-type  = buf_temp-create-stk-supp-line.prod-type
              and buf_stk-supp-line.prod-code  = buf_temp-create-stk-supp-line.prod-code
              and buf_stk-supp-line.fact-order = v-shift-end-fact-order
          on error undo, return error return-value
          :
            delete buf_stk-supp-line .
          end.
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
  define buffer buf_temp-supp for temp-supp .
  define buffer buf_temp-supp-gds for temp-supp-gds .
  define variable v-shift-on                   as logical   no-undo .
  define variable v-first-shift-date           as date      no-undo .
  define variable v-first-shift-num            as integer   no-undo .
  define variable v-first-day-end-fact-order   as decimal   no-undo .
  define variable v-first-shift-end-fact-order as decimal   no-undo .
  define variable v-last-shift-date            as date      no-undo .
  define variable v-last-shift-num             as integer   no-undo .
  define variable v-last-day-end-fact-order    as decimal   no-undo .
  define variable v-last-shift-end-fact-order  as decimal   no-undo .
  define variable v-sum-type-list as character no-undo .
  define variable v-ind as integer   no-undo .
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
      (input "Пересчитываем остаток по поставщикам"
      ).
    run ahrstutl-supp-tot-sum-type-list in this-procedure
      (output v-sum-type-list
      ) .
    do v-ind = 1 to num-entries(v-sum-type-list)
    :
      for each buf_temp-supp
      on error undo, return error return-value
      :
        run ahrstutl-store-supp-tot in this-procedure
          (input p-obj-type
          ,input p-obj-code
          ,input buf_temp-supp.cli-type
          ,input buf_temp-supp.cli-code
          ,input entry(v-ind, v-sum-type-list)
          ,input v-shift-on
          ,input p-first-cut-date
          ,input p-last-cut-date
          ,input v-first-day-end-fact-order
          ,input v-first-shift-end-fact-order
          ,input v-first-shift-date
          ,input v-first-shift-num
          ,input v-last-day-end-fact-order
          ,input v-last-shift-end-fact-order
          ,input v-last-shift-date
          ,input v-last-shift-num
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры" 'ahrstutl-store-supp-tot':u skip
            "Клиент" buf_temp-supp.cli-type buf_temp-supp.cli-code skip
            "v-ind" v-ind skip
            "sum-type" entry(v-ind, v-sum-type-list) skip
            return-value skip
            error-status :get-message(1) skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
    end.
    run show-action in this-procedure
      (input "Пересчитываем остаток по поставщикам, товарам"
      ).
    run ahrstutl-supp-line-sum-type-list in this-procedure
      (output v-sum-type-list
      ) .
    define variable v-total-count as integer   no-undo .
    for each buf_temp-supp-gds
    on error undo, return error return-value
    :
      assign
        v-total-count = v-total-count + 1
      .
      if v-total-count modulo 10 = 0
      then do:
        run show-count in this-procedure
          (input v-total-count
          ,input "Артикул " + string(buf_temp-supp-gds.artic)
          ).
      end.
      do v-ind = 1 to num-entries(v-sum-type-list)
      :
        run ahrstutl-store-supp-line in this-procedure
          (input p-obj-type
          ,input p-obj-code
          ,input buf_temp-supp-gds.cli-type
          ,input buf_temp-supp-gds.cli-code
          ,input buf_temp-supp-gds.artic
          ,input buf_temp-supp-gds.prod-type
          ,input buf_temp-supp-gds.prod-code
          ,input entry(v-ind, v-sum-type-list)
          ,input v-shift-on
          ,input p-first-cut-date
          ,input p-last-cut-date
          ,input v-first-day-end-fact-order
          ,input v-first-shift-end-fact-order
          ,input v-first-shift-date
          ,input v-first-shift-num
          ,input v-last-day-end-fact-order
          ,input v-last-shift-end-fact-order
          ,input v-last-shift-date
          ,input v-last-shift-num
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры" 'ahrstutl-store-supp-line':u skip
            "Объект" p-obj-type p-obj-code skip
            "Клиент" buf_temp-supp-gds.cli-type buf_temp-supp-gds.cli-code skip
            "Артикул" buf_temp-supp-gds.artic buf_temp-supp-gds.prod-type buf_temp-supp-gds.prod-code skip
            return-value skip
            error-status :get-message(1) skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
    end.
  end.
end procedure.
procedure ahrstutl-supp-tot-sum-type-list :
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
      p-sum-type-list = 'cost':U
    .
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + 'sadt':U + entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
      .
    end.
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + 'csdt':U + entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
      .
    end.
  end.
end procedure.
procedure ahrstutl-supp-line-sum-type-list :
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
      p-sum-type-list = 'cost':U
    .
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + 'sadt':U + entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
      .
    end.
    do v-ind = 1 to v-num-entries-TDEDT_List
    :
      assign
        p-sum-type-list = p-sum-type-list
                        + chr(44)
                        + 'csdt':U + entry(v-ind, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
      .
    end.
  end.
end procedure.
procedure ahrstutl-store-supp-tot :
  define input  parameter p-obj-type                   as character no-undo .
  define input  parameter p-obj-code                   as integer   no-undo .
  define input  parameter p-cli-type                   as character no-undo .
  define input  parameter p-cli-code                   as integer   no-undo .
  define input  parameter p-sum-type                   as character no-undo .
  define input  parameter p-shift-on                   as logical   no-undo .
  define input  parameter p-first-cut-date             as date      no-undo .
  define input  parameter p-last-cut-date              as date      no-undo .
  define input  parameter p-first-day-end-fact-order   as decimal   no-undo .
  define input  parameter p-first-shift-end-fact-order as decimal   no-undo .
  define input  parameter p-first-shift-date           as date      no-undo .
  define input  parameter p-first-shift-num            as integer   no-undo .
  define input  parameter p-last-day-end-fact-order    as decimal   no-undo .
  define input  parameter p-last-shift-end-fact-order  as decimal   no-undo .
  define input  parameter p-last-shift-date            as date      no-undo .
  define input  parameter p-last-shift-num             as integer   no-undo .
  define buffer buf_stk-supp-tot            for ub.stk-supp-tot .
  define buffer buf_temp-stk-supp-tot       for temp-stk-supp-tot .
  define buffer buf_temp-shift-stk-supp-tot for temp-shift-stk-supp-tot .
  define buffer sub_temp-stk-supp-tot       for temp-stk-supp-tot .
  define buffer sub_stk-supp-tot            for ub.stk-supp-tot .
  define buffer sub_temp-shift-stk-supp-tot for temp-stk-supp-tot .
  do
  on error undo, return error return-value
  :
    for each buf_temp-stk-supp-tot
      where buf_temp-stk-supp-tot.obj-type = p-obj-type
        and buf_temp-stk-supp-tot.obj-code = p-obj-code
        and buf_temp-stk-supp-tot.cli-type = p-cli-type
        and buf_temp-stk-supp-tot.cli-code = p-cli-code
        and buf_temp-stk-supp-tot.sum-type = p-sum-type
    on error undo, return error return-value
    :
      if
                                          buf_temp-stk-supp-tot.fact-qnty      <> buf_temp-stk-supp-tot.new-fact-qnty        or    buf_temp-stk-supp-tot.sum-base       <> buf_temp-stk-supp-tot.new-sum-base         or    buf_temp-stk-supp-tot.sum-rubl       <> buf_temp-stk-supp-tot.new-sum-rubl         or    buf_temp-stk-supp-tot.vat-base       <> buf_temp-stk-supp-tot.new-vat-base         or    buf_temp-stk-supp-tot.vat-rubl       <> buf_temp-stk-supp-tot.new-vat-rubl         or    buf_temp-stk-supp-tot.slt-base       <> buf_temp-stk-supp-tot.new-slt-base         or    buf_temp-stk-supp-tot.slt-rubl       <> buf_temp-stk-supp-tot.new-slt-rubl         or    buf_temp-stk-supp-tot.road-tax-base  <> buf_temp-stk-supp-tot.new-road-tax-base    or    buf_temp-stk-supp-tot.road-tax-rubl  <> buf_temp-stk-supp-tot.new-road-tax-rubl    or    buf_temp-stk-supp-tot.excise-base    <> buf_temp-stk-supp-tot.new-excise-base      or    buf_temp-stk-supp-tot.excise-rubl    <> buf_temp-stk-supp-tot.new-excise-rubl      or    buf_temp-stk-supp-tot.transport-base <> buf_temp-stk-supp-tot.new-transport-base   or    buf_temp-stk-supp-tot.transport-rubl <> buf_temp-stk-supp-tot.new-transport-rubl   or    buf_temp-stk-supp-tot.other-base     <> buf_temp-stk-supp-tot.new-other-base       or    buf_temp-stk-supp-tot.other-rubl     <> buf_temp-stk-supp-tot.new-other-rubl
      then do:
        find first buf_stk-supp-tot exclusive-lock
          where buf_stk-supp-tot.obj-type   = buf_temp-stk-supp-tot.obj-type
            and buf_stk-supp-tot.obj-code   = buf_temp-stk-supp-tot.obj-code
            and buf_stk-supp-tot.cli-type   = buf_temp-stk-supp-tot.cli-type
            and buf_stk-supp-tot.cli-code   = buf_temp-stk-supp-tot.cli-code
            and buf_stk-supp-tot.sum-type   = buf_temp-stk-supp-tot.sum-type
            and buf_stk-supp-tot.cat-id     = buf_temp-stk-supp-tot.cat-id
            and buf_stk-supp-tot.fact-order <= p-first-day-end-fact-order
            and buf_stk-supp-tot.shift-date = ?
          no-error .
        if not available buf_stk-supp-tot
        then do:
          create buf_stk-supp-tot .
          assign
            buf_stk-supp-tot.obj-type   = buf_temp-stk-supp-tot.obj-type
            buf_stk-supp-tot.obj-code   = buf_temp-stk-supp-tot.obj-code
            buf_stk-supp-tot.cli-type   = buf_temp-stk-supp-tot.cli-type
            buf_stk-supp-tot.cli-code   = buf_temp-stk-supp-tot.cli-code
            buf_stk-supp-tot.fact-order = p-first-day-end-fact-order
            buf_stk-supp-tot.sum-type   = buf_temp-stk-supp-tot.sum-type
            buf_stk-supp-tot.cat-id     = buf_temp-stk-supp-tot.cat-id
            buf_stk-supp-tot.fact-date  = p-first-cut-date
            buf_stk-supp-tot.shift-num  = 0
            buf_stk-supp-tot.shift-date = ?
          .
        end.
        for each buf_stk-supp-tot exclusive-lock
          where buf_stk-supp-tot.obj-type   = buf_temp-stk-supp-tot.obj-type
            and buf_stk-supp-tot.obj-code   = buf_temp-stk-supp-tot.obj-code
            and buf_stk-supp-tot.cli-type   = buf_temp-stk-supp-tot.cli-type
            and buf_stk-supp-tot.cli-code   = buf_temp-stk-supp-tot.cli-code
            and buf_stk-supp-tot.sum-type   = buf_temp-stk-supp-tot.sum-type
            and buf_stk-supp-tot.cat-id     = buf_temp-stk-supp-tot.cat-id
            and buf_stk-supp-tot.fact-order <= p-last-day-end-fact-order - 0.0000000001
            and buf_stk-supp-tot.shift-date = ?
        on error undo, return error return-value
        :
          for each sub_temp-stk-supp-tot
            where sub_temp-stk-supp-tot.obj-type   = buf_temp-stk-supp-tot.obj-type
              and sub_temp-stk-supp-tot.obj-code   = buf_temp-stk-supp-tot.obj-code
              and sub_temp-stk-supp-tot.cli-type   = buf_temp-stk-supp-tot.cli-type
              and sub_temp-stk-supp-tot.cli-code   = buf_temp-stk-supp-tot.cli-code
              and sub_temp-stk-supp-tot.fact-order = buf_temp-stk-supp-tot.fact-order
              and sub_temp-stk-supp-tot.sum-type   begins buf_temp-stk-supp-tot.sum-type
          on error undo, return error return-value
          :
            if
                                                                                    sub_temp-stk-supp-tot.fact-qnty      <> sub_temp-stk-supp-tot.new-fact-qnty        or    sub_temp-stk-supp-tot.sum-base       <> sub_temp-stk-supp-tot.new-sum-base         or    sub_temp-stk-supp-tot.sum-rubl       <> sub_temp-stk-supp-tot.new-sum-rubl         or    sub_temp-stk-supp-tot.vat-base       <> sub_temp-stk-supp-tot.new-vat-base         or    sub_temp-stk-supp-tot.vat-rubl       <> sub_temp-stk-supp-tot.new-vat-rubl         or    sub_temp-stk-supp-tot.slt-base       <> sub_temp-stk-supp-tot.new-slt-base         or    sub_temp-stk-supp-tot.slt-rubl       <> sub_temp-stk-supp-tot.new-slt-rubl         or    sub_temp-stk-supp-tot.road-tax-base  <> sub_temp-stk-supp-tot.new-road-tax-base    or    sub_temp-stk-supp-tot.road-tax-rubl  <> sub_temp-stk-supp-tot.new-road-tax-rubl    or    sub_temp-stk-supp-tot.excise-base    <> sub_temp-stk-supp-tot.new-excise-base      or    sub_temp-stk-supp-tot.excise-rubl    <> sub_temp-stk-supp-tot.new-excise-rubl      or    sub_temp-stk-supp-tot.transport-base <> sub_temp-stk-supp-tot.new-transport-base   or    sub_temp-stk-supp-tot.transport-rubl <> sub_temp-stk-supp-tot.new-transport-rubl   or    sub_temp-stk-supp-tot.other-base     <> sub_temp-stk-supp-tot.new-other-base       or    sub_temp-stk-supp-tot.other-rubl     <> sub_temp-stk-supp-tot.new-other-rubl
            then do:
              find first sub_stk-supp-tot exclusive-lock
                where sub_stk-supp-tot.obj-type   = buf_stk-supp-tot.obj-type
                  and sub_stk-supp-tot.obj-code   = buf_stk-supp-tot.obj-code
                  and sub_stk-supp-tot.cli-type   = buf_stk-supp-tot.cli-type
                  and sub_stk-supp-tot.cli-code   = buf_stk-supp-tot.cli-code
                  and sub_stk-supp-tot.fact-order = buf_stk-supp-tot.fact-order
                  and sub_stk-supp-tot.sum-type   = sub_temp-stk-supp-tot.sum-type
                  and sub_stk-supp-tot.cat-id     = sub_temp-stk-supp-tot.cat-id
                no-error .
              if not available sub_stk-supp-tot
              then do:
                create sub_stk-supp-tot .
                assign
                  sub_stk-supp-tot.obj-type   = buf_stk-supp-tot.obj-type
                  sub_stk-supp-tot.obj-code   = buf_stk-supp-tot.obj-code
                  sub_stk-supp-tot.cli-type   = buf_stk-supp-tot.cli-type
                  sub_stk-supp-tot.cli-code   = buf_stk-supp-tot.cli-code
                  sub_stk-supp-tot.fact-order = buf_stk-supp-tot.fact-order
                  sub_stk-supp-tot.sum-type   = sub_temp-stk-supp-tot.sum-type
                  sub_stk-supp-tot.cat-id     = sub_temp-stk-supp-tot.cat-id
                  sub_stk-supp-tot.fact-date  = buf_stk-supp-tot.fact-date
                  sub_stk-supp-tot.shift-num  = buf_stk-supp-tot.shift-num
                  sub_stk-supp-tot.shift-date = buf_stk-supp-tot.shift-date
                .
              end.
              assign
                                                                                                                                                                                sub_stk-supp-tot.fact-qnty      = sub_stk-supp-tot.fact-qnty      + sub_temp-stk-supp-tot.fact-qnty      - sub_temp-stk-supp-tot.new-fact-qnty           sub_stk-supp-tot.sum-base       = sub_stk-supp-tot.sum-base       + sub_temp-stk-supp-tot.sum-base       - sub_temp-stk-supp-tot.new-sum-base            sub_stk-supp-tot.sum-rubl       = sub_stk-supp-tot.sum-rubl       + sub_temp-stk-supp-tot.sum-rubl       - sub_temp-stk-supp-tot.new-sum-rubl            sub_stk-supp-tot.vat-base       = sub_stk-supp-tot.vat-base       + sub_temp-stk-supp-tot.vat-base       - sub_temp-stk-supp-tot.new-vat-base            sub_stk-supp-tot.vat-rubl       = sub_stk-supp-tot.vat-rubl       + sub_temp-stk-supp-tot.vat-rubl       - sub_temp-stk-supp-tot.new-vat-rubl            sub_stk-supp-tot.slt-base       = sub_stk-supp-tot.slt-base       + sub_temp-stk-supp-tot.slt-base       - sub_temp-stk-supp-tot.new-slt-base            sub_stk-supp-tot.slt-rubl       = sub_stk-supp-tot.slt-rubl       + sub_temp-stk-supp-tot.slt-rubl       - sub_temp-stk-supp-tot.new-slt-rubl            sub_stk-supp-tot.road-tax-base  = sub_stk-supp-tot.road-tax-base  + sub_temp-stk-supp-tot.road-tax-base  - sub_temp-stk-supp-tot.new-road-tax-base       sub_stk-supp-tot.road-tax-rubl  = sub_stk-supp-tot.road-tax-rubl  + sub_temp-stk-supp-tot.road-tax-rubl  - sub_temp-stk-supp-tot.new-road-tax-rubl       sub_stk-supp-tot.excise-base    = sub_stk-supp-tot.excise-base    + sub_temp-stk-supp-tot.excise-base    - sub_temp-stk-supp-tot.new-excise-base         sub_stk-supp-tot.excise-rubl    = sub_stk-supp-tot.excise-rubl    + sub_temp-stk-supp-tot.excise-rubl    - sub_temp-stk-supp-tot.new-excise-rubl         sub_stk-supp-tot.transport-base = sub_stk-supp-tot.transport-base + sub_temp-stk-supp-tot.transport-base - sub_temp-stk-supp-tot.new-transport-base      sub_stk-supp-tot.transport-rubl = sub_stk-supp-tot.transport-rubl + sub_temp-stk-supp-tot.transport-rubl - sub_temp-stk-supp-tot.new-transport-rubl      sub_stk-supp-tot.other-base     = sub_stk-supp-tot.other-base     + sub_temp-stk-supp-tot.other-base     - sub_temp-stk-supp-tot.new-other-base          sub_stk-supp-tot.other-rubl     = sub_stk-supp-tot.other-rubl     + sub_temp-stk-supp-tot.other-rubl     - sub_temp-stk-supp-tot.new-other-rubl
              .
            end.
          end.
        end.
      end.
    end.
    if p-shift-on = true
    then do:
      for each buf_temp-shift-stk-supp-tot
        where buf_temp-shift-stk-supp-tot.obj-type = p-obj-type
          and buf_temp-shift-stk-supp-tot.obj-code = p-obj-code
          and buf_temp-shift-stk-supp-tot.cli-type = p-cli-type
          and buf_temp-shift-stk-supp-tot.cli-code = p-cli-code
          and buf_temp-shift-stk-supp-tot.sum-type = p-sum-type
      on error undo, return error return-value
      :
        if
                                                        buf_temp-shift-stk-supp-tot.fact-qnty      <> buf_temp-shift-stk-supp-tot.new-fact-qnty        or    buf_temp-shift-stk-supp-tot.sum-base       <> buf_temp-shift-stk-supp-tot.new-sum-base         or    buf_temp-shift-stk-supp-tot.sum-rubl       <> buf_temp-shift-stk-supp-tot.new-sum-rubl         or    buf_temp-shift-stk-supp-tot.vat-base       <> buf_temp-shift-stk-supp-tot.new-vat-base         or    buf_temp-shift-stk-supp-tot.vat-rubl       <> buf_temp-shift-stk-supp-tot.new-vat-rubl         or    buf_temp-shift-stk-supp-tot.slt-base       <> buf_temp-shift-stk-supp-tot.new-slt-base         or    buf_temp-shift-stk-supp-tot.slt-rubl       <> buf_temp-shift-stk-supp-tot.new-slt-rubl         or    buf_temp-shift-stk-supp-tot.road-tax-base  <> buf_temp-shift-stk-supp-tot.new-road-tax-base    or    buf_temp-shift-stk-supp-tot.road-tax-rubl  <> buf_temp-shift-stk-supp-tot.new-road-tax-rubl    or    buf_temp-shift-stk-supp-tot.excise-base    <> buf_temp-shift-stk-supp-tot.new-excise-base      or    buf_temp-shift-stk-supp-tot.excise-rubl    <> buf_temp-shift-stk-supp-tot.new-excise-rubl      or    buf_temp-shift-stk-supp-tot.transport-base <> buf_temp-shift-stk-supp-tot.new-transport-base   or    buf_temp-shift-stk-supp-tot.transport-rubl <> buf_temp-shift-stk-supp-tot.new-transport-rubl   or    buf_temp-shift-stk-supp-tot.other-base     <> buf_temp-shift-stk-supp-tot.new-other-base       or    buf_temp-shift-stk-supp-tot.other-rubl     <> buf_temp-shift-stk-supp-tot.new-other-rubl
        then do:
          find first buf_stk-supp-tot exclusive-lock
            where buf_stk-supp-tot.obj-type   = buf_temp-shift-stk-supp-tot.obj-type
              and buf_stk-supp-tot.obj-code   = buf_temp-shift-stk-supp-tot.obj-code
              and buf_stk-supp-tot.cli-type   = buf_temp-shift-stk-supp-tot.cli-type
              and buf_stk-supp-tot.cli-code   = buf_temp-shift-stk-supp-tot.cli-code
              and buf_stk-supp-tot.sum-type   = buf_temp-shift-stk-supp-tot.sum-type
              and buf_stk-supp-tot.cat-id     = buf_temp-shift-stk-supp-tot.cat-id
              and buf_stk-supp-tot.fact-order <= p-first-shift-end-fact-order
              and buf_stk-supp-tot.shift-date <> ?
            no-error .
          if not available buf_stk-supp-tot
          then do:
            create buf_stk-supp-tot .
            assign
              buf_stk-supp-tot.obj-type   = buf_temp-shift-stk-supp-tot.obj-type
              buf_stk-supp-tot.obj-code   = buf_temp-shift-stk-supp-tot.obj-code
              buf_stk-supp-tot.cli-type   = buf_temp-shift-stk-supp-tot.cli-type
              buf_stk-supp-tot.cli-code   = buf_temp-shift-stk-supp-tot.cli-code
              buf_stk-supp-tot.fact-order = p-first-shift-end-fact-order
              buf_stk-supp-tot.sum-type   = buf_temp-shift-stk-supp-tot.sum-type
              buf_stk-supp-tot.cat-id     = buf_temp-shift-stk-supp-tot.cat-id
              buf_stk-supp-tot.fact-date  = p-first-cut-date
              buf_stk-supp-tot.shift-num  = p-first-shift-num
              buf_stk-supp-tot.shift-date = p-first-shift-date
            .
          end.
          for each buf_stk-supp-tot exclusive-lock
            where buf_stk-supp-tot.obj-type   = buf_temp-shift-stk-supp-tot.obj-type
              and buf_stk-supp-tot.obj-code   = buf_temp-shift-stk-supp-tot.obj-code
              and buf_stk-supp-tot.cli-type   = buf_temp-shift-stk-supp-tot.cli-type
              and buf_stk-supp-tot.cli-code   = buf_temp-shift-stk-supp-tot.cli-code
              and buf_stk-supp-tot.sum-type   = buf_temp-shift-stk-supp-tot.sum-type
              and buf_stk-supp-tot.cat-id     = buf_temp-shift-stk-supp-tot.cat-id
              and buf_stk-supp-tot.fact-order <= p-last-shift-end-fact-order - 0.0000000001
              and buf_stk-supp-tot.shift-date <> ?
          on error undo, return error return-value
          :
            for each sub_temp-shift-stk-supp-tot
              where sub_temp-shift-stk-supp-tot.obj-type   = buf_temp-shift-stk-supp-tot.obj-type
                and sub_temp-shift-stk-supp-tot.obj-code   = buf_temp-shift-stk-supp-tot.obj-code
                and sub_temp-shift-stk-supp-tot.cli-type   = buf_temp-shift-stk-supp-tot.cli-type
                and sub_temp-shift-stk-supp-tot.cli-code   = buf_temp-shift-stk-supp-tot.cli-code
                and sub_temp-shift-stk-supp-tot.fact-order = buf_temp-shift-stk-supp-tot.fact-order
                and sub_temp-shift-stk-supp-tot.sum-type   begins buf_temp-shift-stk-supp-tot.sum-type
            on error undo, return error return-value
            :
              if
                                                                                                  sub_temp-shift-stk-supp-tot.fact-qnty      <> sub_temp-shift-stk-supp-tot.new-fact-qnty        or    sub_temp-shift-stk-supp-tot.sum-base       <> sub_temp-shift-stk-supp-tot.new-sum-base         or    sub_temp-shift-stk-supp-tot.sum-rubl       <> sub_temp-shift-stk-supp-tot.new-sum-rubl         or    sub_temp-shift-stk-supp-tot.vat-base       <> sub_temp-shift-stk-supp-tot.new-vat-base         or    sub_temp-shift-stk-supp-tot.vat-rubl       <> sub_temp-shift-stk-supp-tot.new-vat-rubl         or    sub_temp-shift-stk-supp-tot.slt-base       <> sub_temp-shift-stk-supp-tot.new-slt-base         or    sub_temp-shift-stk-supp-tot.slt-rubl       <> sub_temp-shift-stk-supp-tot.new-slt-rubl         or    sub_temp-shift-stk-supp-tot.road-tax-base  <> sub_temp-shift-stk-supp-tot.new-road-tax-base    or    sub_temp-shift-stk-supp-tot.road-tax-rubl  <> sub_temp-shift-stk-supp-tot.new-road-tax-rubl    or    sub_temp-shift-stk-supp-tot.excise-base    <> sub_temp-shift-stk-supp-tot.new-excise-base      or    sub_temp-shift-stk-supp-tot.excise-rubl    <> sub_temp-shift-stk-supp-tot.new-excise-rubl      or    sub_temp-shift-stk-supp-tot.transport-base <> sub_temp-shift-stk-supp-tot.new-transport-base   or    sub_temp-shift-stk-supp-tot.transport-rubl <> sub_temp-shift-stk-supp-tot.new-transport-rubl   or    sub_temp-shift-stk-supp-tot.other-base     <> sub_temp-shift-stk-supp-tot.new-other-base       or    sub_temp-shift-stk-supp-tot.other-rubl     <> sub_temp-shift-stk-supp-tot.new-other-rubl
              then do:
                find first sub_stk-supp-tot exclusive-lock
                  where sub_stk-supp-tot.obj-type   = buf_stk-supp-tot.obj-type
                    and sub_stk-supp-tot.obj-code   = buf_stk-supp-tot.obj-code
                    and sub_stk-supp-tot.cli-type   = buf_stk-supp-tot.cli-type
                    and sub_stk-supp-tot.cli-code   = buf_stk-supp-tot.cli-code
                    and sub_stk-supp-tot.fact-order = buf_stk-supp-tot.fact-order
                    and sub_stk-supp-tot.sum-type   = sub_temp-shift-stk-supp-tot.sum-type
                    and sub_stk-supp-tot.cat-id     = sub_temp-shift-stk-supp-tot.cat-id
                  no-error .
                if not available sub_stk-supp-tot
                then do:
                  create sub_stk-supp-tot .
                  assign
                    sub_stk-supp-tot.obj-type   = buf_stk-supp-tot.obj-type
                    sub_stk-supp-tot.obj-code   = buf_stk-supp-tot.obj-code
                    sub_stk-supp-tot.cli-type   = buf_stk-supp-tot.cli-type
                    sub_stk-supp-tot.cli-code   = buf_stk-supp-tot.cli-code
                    sub_stk-supp-tot.fact-order = buf_stk-supp-tot.fact-order
                    sub_stk-supp-tot.sum-type   = sub_temp-shift-stk-supp-tot.sum-type
                    sub_stk-supp-tot.cat-id     = sub_temp-shift-stk-supp-tot.cat-id
                    sub_stk-supp-tot.fact-date  = buf_stk-supp-tot.fact-date
                    sub_stk-supp-tot.shift-num  = buf_stk-supp-tot.shift-num
                    sub_stk-supp-tot.shift-date = buf_stk-supp-tot.shift-date
                  .
                end.
                assign
                                                                                                                                                                                                      sub_stk-supp-tot.fact-qnty      = sub_stk-supp-tot.fact-qnty      + sub_temp-shift-stk-supp-tot.fact-qnty      - sub_temp-shift-stk-supp-tot.new-fact-qnty           sub_stk-supp-tot.sum-base       = sub_stk-supp-tot.sum-base       + sub_temp-shift-stk-supp-tot.sum-base       - sub_temp-shift-stk-supp-tot.new-sum-base            sub_stk-supp-tot.sum-rubl       = sub_stk-supp-tot.sum-rubl       + sub_temp-shift-stk-supp-tot.sum-rubl       - sub_temp-shift-stk-supp-tot.new-sum-rubl            sub_stk-supp-tot.vat-base       = sub_stk-supp-tot.vat-base       + sub_temp-shift-stk-supp-tot.vat-base       - sub_temp-shift-stk-supp-tot.new-vat-base            sub_stk-supp-tot.vat-rubl       = sub_stk-supp-tot.vat-rubl       + sub_temp-shift-stk-supp-tot.vat-rubl       - sub_temp-shift-stk-supp-tot.new-vat-rubl            sub_stk-supp-tot.slt-base       = sub_stk-supp-tot.slt-base       + sub_temp-shift-stk-supp-tot.slt-base       - sub_temp-shift-stk-supp-tot.new-slt-base            sub_stk-supp-tot.slt-rubl       = sub_stk-supp-tot.slt-rubl       + sub_temp-shift-stk-supp-tot.slt-rubl       - sub_temp-shift-stk-supp-tot.new-slt-rubl            sub_stk-supp-tot.road-tax-base  = sub_stk-supp-tot.road-tax-base  + sub_temp-shift-stk-supp-tot.road-tax-base  - sub_temp-shift-stk-supp-tot.new-road-tax-base       sub_stk-supp-tot.road-tax-rubl  = sub_stk-supp-tot.road-tax-rubl  + sub_temp-shift-stk-supp-tot.road-tax-rubl  - sub_temp-shift-stk-supp-tot.new-road-tax-rubl       sub_stk-supp-tot.excise-base    = sub_stk-supp-tot.excise-base    + sub_temp-shift-stk-supp-tot.excise-base    - sub_temp-shift-stk-supp-tot.new-excise-base         sub_stk-supp-tot.excise-rubl    = sub_stk-supp-tot.excise-rubl    + sub_temp-shift-stk-supp-tot.excise-rubl    - sub_temp-shift-stk-supp-tot.new-excise-rubl         sub_stk-supp-tot.transport-base = sub_stk-supp-tot.transport-base + sub_temp-shift-stk-supp-tot.transport-base - sub_temp-shift-stk-supp-tot.new-transport-base      sub_stk-supp-tot.transport-rubl = sub_stk-supp-tot.transport-rubl + sub_temp-shift-stk-supp-tot.transport-rubl - sub_temp-shift-stk-supp-tot.new-transport-rubl      sub_stk-supp-tot.other-base     = sub_stk-supp-tot.other-base     + sub_temp-shift-stk-supp-tot.other-base     - sub_temp-shift-stk-supp-tot.new-other-base          sub_stk-supp-tot.other-rubl     = sub_stk-supp-tot.other-rubl     + sub_temp-shift-stk-supp-tot.other-rubl     - sub_temp-shift-stk-supp-tot.new-other-rubl
                .
              end.
            end.
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure ahrstutl-store-supp-line :
  define input  parameter p-obj-type                   as character no-undo .
  define input  parameter p-obj-code                   as integer   no-undo .
  define input  parameter p-cli-type                   as character no-undo .
  define input  parameter p-cli-code                   as integer   no-undo .
  define input  parameter p-artic                      as character no-undo .
  define input  parameter p-prod-type                  as character no-undo .
  define input  parameter p-prod-code                  as integer   no-undo .
  define input  parameter p-sum-type                   as character no-undo .
  define input  parameter p-shift-on                   as logical   no-undo .
  define input  parameter p-first-cut-date             as date      no-undo .
  define input  parameter p-last-cut-date              as date      no-undo .
  define input  parameter p-first-day-end-fact-order   as decimal   no-undo .
  define input  parameter p-first-shift-end-fact-order as decimal   no-undo .
  define input  parameter p-first-shift-date           as date      no-undo .
  define input  parameter p-first-shift-num            as integer   no-undo .
  define input  parameter p-last-day-end-fact-order    as decimal   no-undo .
  define input  parameter p-last-shift-end-fact-order  as decimal   no-undo .
  define input  parameter p-last-shift-date            as date      no-undo .
  define input  parameter p-last-shift-num             as integer   no-undo .
  define buffer buf_stk-supp-line for ub.stk-supp-line .
  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_temp-shift-stk-supp-line for temp-shift-stk-supp-line .
  define buffer sub_temp-stk-supp-line for temp-stk-supp-line .
  define buffer sub_stk-supp-line for ub.stk-supp-line .
  define buffer sub_temp-shift-stk-supp-line for temp-shift-stk-supp-line .
  do
  on error undo, return error return-value
  :
    for each buf_temp-stk-supp-line
      where buf_temp-stk-supp-line.obj-type   = p-obj-type
        and buf_temp-stk-supp-line.obj-code   = p-obj-code
        and buf_temp-stk-supp-line.cli-type   = p-cli-type
        and buf_temp-stk-supp-line.cli-code   = p-cli-code
        and buf_temp-stk-supp-line.artic      = p-artic
        and buf_temp-stk-supp-line.prod-type  = p-prod-type
        and buf_temp-stk-supp-line.prod-code  = p-prod-code
        and buf_temp-stk-supp-line.sum-type   = p-sum-type
    on error undo, return error return-value
    :
      if
                                          buf_temp-stk-supp-line.fact-qnty      <> buf_temp-stk-supp-line.new-fact-qnty        or    buf_temp-stk-supp-line.sum-base       <> buf_temp-stk-supp-line.new-sum-base         or    buf_temp-stk-supp-line.sum-rubl       <> buf_temp-stk-supp-line.new-sum-rubl         or    buf_temp-stk-supp-line.vat-base       <> buf_temp-stk-supp-line.new-vat-base         or    buf_temp-stk-supp-line.vat-rubl       <> buf_temp-stk-supp-line.new-vat-rubl         or    buf_temp-stk-supp-line.slt-base       <> buf_temp-stk-supp-line.new-slt-base         or    buf_temp-stk-supp-line.slt-rubl       <> buf_temp-stk-supp-line.new-slt-rubl         or    buf_temp-stk-supp-line.road-tax-base  <> buf_temp-stk-supp-line.new-road-tax-base    or    buf_temp-stk-supp-line.road-tax-rubl  <> buf_temp-stk-supp-line.new-road-tax-rubl    or    buf_temp-stk-supp-line.excise-base    <> buf_temp-stk-supp-line.new-excise-base      or    buf_temp-stk-supp-line.excise-rubl    <> buf_temp-stk-supp-line.new-excise-rubl      or    buf_temp-stk-supp-line.transport-base <> buf_temp-stk-supp-line.new-transport-base   or    buf_temp-stk-supp-line.transport-rubl <> buf_temp-stk-supp-line.new-transport-rubl   or    buf_temp-stk-supp-line.other-base     <> buf_temp-stk-supp-line.new-other-base       or    buf_temp-stk-supp-line.other-rubl     <> buf_temp-stk-supp-line.new-other-rubl
      then do:
        find first buf_stk-supp-line exclusive-lock
          where buf_stk-supp-line.obj-type   = buf_temp-stk-supp-line.obj-type
            and buf_stk-supp-line.obj-code   = buf_temp-stk-supp-line.obj-code
            and buf_stk-supp-line.cli-type   = buf_temp-stk-supp-line.cli-type
            and buf_stk-supp-line.cli-code   = buf_temp-stk-supp-line.cli-code
            and buf_stk-supp-line.artic      = buf_temp-stk-supp-line.artic
            and buf_stk-supp-line.prod-type  = buf_temp-stk-supp-line.prod-type
            and buf_stk-supp-line.prod-code  = buf_temp-stk-supp-line.prod-code
            and buf_stk-supp-line.sum-type   = buf_temp-stk-supp-line.sum-type
            and buf_stk-supp-line.cat-id     = buf_temp-stk-supp-line.cat-id
            and buf_stk-supp-line.fact-order <= p-first-day-end-fact-order
            and buf_stk-supp-line.shift-date = ?
          no-error .
        if not available buf_stk-supp-line
        then do:
          create buf_stk-supp-line .
          assign
            buf_stk-supp-line.obj-type   = buf_temp-stk-supp-line.obj-type
            buf_stk-supp-line.obj-code   = buf_temp-stk-supp-line.obj-code
            buf_stk-supp-line.cli-type   = buf_temp-stk-supp-line.cli-type
            buf_stk-supp-line.cli-code   = buf_temp-stk-supp-line.cli-code
            buf_stk-supp-line.artic      = buf_temp-stk-supp-line.artic
            buf_stk-supp-line.prod-type  = buf_temp-stk-supp-line.prod-type
            buf_stk-supp-line.prod-code  = buf_temp-stk-supp-line.prod-code
            buf_stk-supp-line.fact-order = p-first-day-end-fact-order
            buf_stk-supp-line.sum-type   = buf_temp-stk-supp-line.sum-type
            buf_stk-supp-line.cat-id     = buf_temp-stk-supp-line.cat-id
            buf_stk-supp-line.fact-date  = p-first-cut-date
            buf_stk-supp-line.shift-num  = 0
            buf_stk-supp-line.shift-date = ?
          .
        end.
        for each buf_stk-supp-line exclusive-lock
          where buf_stk-supp-line.obj-type   = buf_temp-stk-supp-line.obj-type
            and buf_stk-supp-line.obj-code   = buf_temp-stk-supp-line.obj-code
            and buf_stk-supp-line.cli-type   = buf_temp-stk-supp-line.cli-type
            and buf_stk-supp-line.cli-code   = buf_temp-stk-supp-line.cli-code
            and buf_stk-supp-line.artic      = buf_temp-stk-supp-line.artic
            and buf_stk-supp-line.prod-type  = buf_temp-stk-supp-line.prod-type
            and buf_stk-supp-line.prod-code  = buf_temp-stk-supp-line.prod-code
            and buf_stk-supp-line.sum-type   = buf_temp-stk-supp-line.sum-type
            and buf_stk-supp-line.cat-id     = buf_temp-stk-supp-line.cat-id
            and buf_stk-supp-line.fact-order <= p-last-day-end-fact-order - 0.0000000001
            and buf_stk-supp-line.shift-date = ?
        on error undo, return error return-value
        :
          for each sub_temp-stk-supp-line
            where sub_temp-stk-supp-line.obj-type   = buf_temp-stk-supp-line.obj-type
              and sub_temp-stk-supp-line.obj-code   = buf_temp-stk-supp-line.obj-code
              and sub_temp-stk-supp-line.cli-type   = buf_temp-stk-supp-line.cli-type
              and sub_temp-stk-supp-line.cli-code   = buf_temp-stk-supp-line.cli-code
              and sub_temp-stk-supp-line.artic      = buf_temp-stk-supp-line.artic
              and sub_temp-stk-supp-line.prod-type  = buf_temp-stk-supp-line.prod-type
              and sub_temp-stk-supp-line.prod-code  = buf_temp-stk-supp-line.prod-code
              and sub_temp-stk-supp-line.fact-order = buf_temp-stk-supp-line.fact-order
              and sub_temp-stk-supp-line.sum-type   begins buf_temp-stk-supp-line.sum-type
          on error undo, return error return-value
          :
            if
                                                                                    sub_temp-stk-supp-line.fact-qnty      <> sub_temp-stk-supp-line.new-fact-qnty        or    sub_temp-stk-supp-line.sum-base       <> sub_temp-stk-supp-line.new-sum-base         or    sub_temp-stk-supp-line.sum-rubl       <> sub_temp-stk-supp-line.new-sum-rubl         or    sub_temp-stk-supp-line.vat-base       <> sub_temp-stk-supp-line.new-vat-base         or    sub_temp-stk-supp-line.vat-rubl       <> sub_temp-stk-supp-line.new-vat-rubl         or    sub_temp-stk-supp-line.slt-base       <> sub_temp-stk-supp-line.new-slt-base         or    sub_temp-stk-supp-line.slt-rubl       <> sub_temp-stk-supp-line.new-slt-rubl         or    sub_temp-stk-supp-line.road-tax-base  <> sub_temp-stk-supp-line.new-road-tax-base    or    sub_temp-stk-supp-line.road-tax-rubl  <> sub_temp-stk-supp-line.new-road-tax-rubl    or    sub_temp-stk-supp-line.excise-base    <> sub_temp-stk-supp-line.new-excise-base      or    sub_temp-stk-supp-line.excise-rubl    <> sub_temp-stk-supp-line.new-excise-rubl      or    sub_temp-stk-supp-line.transport-base <> sub_temp-stk-supp-line.new-transport-base   or    sub_temp-stk-supp-line.transport-rubl <> sub_temp-stk-supp-line.new-transport-rubl   or    sub_temp-stk-supp-line.other-base     <> sub_temp-stk-supp-line.new-other-base       or    sub_temp-stk-supp-line.other-rubl     <> sub_temp-stk-supp-line.new-other-rubl
            then do:
              find first sub_stk-supp-line exclusive-lock
                where sub_stk-supp-line.obj-type   = buf_stk-supp-line.obj-type
                  and sub_stk-supp-line.obj-code   = buf_stk-supp-line.obj-code
                  and sub_stk-supp-line.cli-type   = buf_stk-supp-line.cli-type
                  and sub_stk-supp-line.cli-code   = buf_stk-supp-line.cli-code
                  and sub_stk-supp-line.artic      = buf_stk-supp-line.artic
                  and sub_stk-supp-line.prod-type  = buf_stk-supp-line.prod-type
                  and sub_stk-supp-line.prod-code  = buf_stk-supp-line.prod-code
                  and sub_stk-supp-line.fact-order = buf_stk-supp-line.fact-order
                  and sub_stk-supp-line.sum-type   = sub_temp-stk-supp-line.sum-type
                  and sub_stk-supp-line.cat-id     = sub_temp-stk-supp-line.cat-id
                no-error .
              if not available sub_stk-supp-line
              then do:
                create sub_stk-supp-line .
                assign
                  sub_stk-supp-line.obj-type   = buf_stk-supp-line.obj-type
                  sub_stk-supp-line.obj-code   = buf_stk-supp-line.obj-code
                  sub_stk-supp-line.cli-type   = buf_stk-supp-line.cli-type
                  sub_stk-supp-line.cli-code   = buf_stk-supp-line.cli-code
                  sub_stk-supp-line.artic      = buf_stk-supp-line.artic
                  sub_stk-supp-line.prod-type  = buf_stk-supp-line.prod-type
                  sub_stk-supp-line.prod-code  = buf_stk-supp-line.prod-code
                  sub_stk-supp-line.fact-order = buf_stk-supp-line.fact-order
                  sub_stk-supp-line.sum-type   = sub_temp-stk-supp-line.sum-type
                  sub_stk-supp-line.cat-id     = sub_temp-stk-supp-line.cat-id
                  sub_stk-supp-line.fact-date  = buf_stk-supp-line.fact-date
                  sub_stk-supp-line.shift-num  = buf_stk-supp-line.shift-num
                  sub_stk-supp-line.shift-date = buf_stk-supp-line.shift-date
                .
              end.
              assign
                                                                                                                                                                                sub_stk-supp-line.fact-qnty      = sub_stk-supp-line.fact-qnty      + sub_temp-stk-supp-line.fact-qnty      - sub_temp-stk-supp-line.new-fact-qnty           sub_stk-supp-line.sum-base       = sub_stk-supp-line.sum-base       + sub_temp-stk-supp-line.sum-base       - sub_temp-stk-supp-line.new-sum-base            sub_stk-supp-line.sum-rubl       = sub_stk-supp-line.sum-rubl       + sub_temp-stk-supp-line.sum-rubl       - sub_temp-stk-supp-line.new-sum-rubl            sub_stk-supp-line.vat-base       = sub_stk-supp-line.vat-base       + sub_temp-stk-supp-line.vat-base       - sub_temp-stk-supp-line.new-vat-base            sub_stk-supp-line.vat-rubl       = sub_stk-supp-line.vat-rubl       + sub_temp-stk-supp-line.vat-rubl       - sub_temp-stk-supp-line.new-vat-rubl            sub_stk-supp-line.slt-base       = sub_stk-supp-line.slt-base       + sub_temp-stk-supp-line.slt-base       - sub_temp-stk-supp-line.new-slt-base            sub_stk-supp-line.slt-rubl       = sub_stk-supp-line.slt-rubl       + sub_temp-stk-supp-line.slt-rubl       - sub_temp-stk-supp-line.new-slt-rubl            sub_stk-supp-line.road-tax-base  = sub_stk-supp-line.road-tax-base  + sub_temp-stk-supp-line.road-tax-base  - sub_temp-stk-supp-line.new-road-tax-base       sub_stk-supp-line.road-tax-rubl  = sub_stk-supp-line.road-tax-rubl  + sub_temp-stk-supp-line.road-tax-rubl  - sub_temp-stk-supp-line.new-road-tax-rubl       sub_stk-supp-line.excise-base    = sub_stk-supp-line.excise-base    + sub_temp-stk-supp-line.excise-base    - sub_temp-stk-supp-line.new-excise-base         sub_stk-supp-line.excise-rubl    = sub_stk-supp-line.excise-rubl    + sub_temp-stk-supp-line.excise-rubl    - sub_temp-stk-supp-line.new-excise-rubl         sub_stk-supp-line.transport-base = sub_stk-supp-line.transport-base + sub_temp-stk-supp-line.transport-base - sub_temp-stk-supp-line.new-transport-base      sub_stk-supp-line.transport-rubl = sub_stk-supp-line.transport-rubl + sub_temp-stk-supp-line.transport-rubl - sub_temp-stk-supp-line.new-transport-rubl      sub_stk-supp-line.other-base     = sub_stk-supp-line.other-base     + sub_temp-stk-supp-line.other-base     - sub_temp-stk-supp-line.new-other-base          sub_stk-supp-line.other-rubl     = sub_stk-supp-line.other-rubl     + sub_temp-stk-supp-line.other-rubl     - sub_temp-stk-supp-line.new-other-rubl
              .
            end.
          end.
        end.
      end.
    end.
    if p-shift-on = true
    then do:
      for each buf_temp-shift-stk-supp-line
        where buf_temp-shift-stk-supp-line.obj-type  = p-obj-type
          and buf_temp-shift-stk-supp-line.obj-code  = p-obj-code
          and buf_temp-shift-stk-supp-line.cli-type  = p-cli-type
          and buf_temp-shift-stk-supp-line.cli-code  = p-cli-code
          and buf_temp-shift-stk-supp-line.artic     = p-artic
          and buf_temp-shift-stk-supp-line.prod-type = p-prod-type
          and buf_temp-shift-stk-supp-line.prod-code = p-prod-code
          and buf_temp-shift-stk-supp-line.sum-type  = p-sum-type
      on error undo, return error return-value
      :
        if
                                                        buf_temp-shift-stk-supp-line.fact-qnty      <> buf_temp-shift-stk-supp-line.new-fact-qnty        or    buf_temp-shift-stk-supp-line.sum-base       <> buf_temp-shift-stk-supp-line.new-sum-base         or    buf_temp-shift-stk-supp-line.sum-rubl       <> buf_temp-shift-stk-supp-line.new-sum-rubl         or    buf_temp-shift-stk-supp-line.vat-base       <> buf_temp-shift-stk-supp-line.new-vat-base         or    buf_temp-shift-stk-supp-line.vat-rubl       <> buf_temp-shift-stk-supp-line.new-vat-rubl         or    buf_temp-shift-stk-supp-line.slt-base       <> buf_temp-shift-stk-supp-line.new-slt-base         or    buf_temp-shift-stk-supp-line.slt-rubl       <> buf_temp-shift-stk-supp-line.new-slt-rubl         or    buf_temp-shift-stk-supp-line.road-tax-base  <> buf_temp-shift-stk-supp-line.new-road-tax-base    or    buf_temp-shift-stk-supp-line.road-tax-rubl  <> buf_temp-shift-stk-supp-line.new-road-tax-rubl    or    buf_temp-shift-stk-supp-line.excise-base    <> buf_temp-shift-stk-supp-line.new-excise-base      or    buf_temp-shift-stk-supp-line.excise-rubl    <> buf_temp-shift-stk-supp-line.new-excise-rubl      or    buf_temp-shift-stk-supp-line.transport-base <> buf_temp-shift-stk-supp-line.new-transport-base   or    buf_temp-shift-stk-supp-line.transport-rubl <> buf_temp-shift-stk-supp-line.new-transport-rubl   or    buf_temp-shift-stk-supp-line.other-base     <> buf_temp-shift-stk-supp-line.new-other-base       or    buf_temp-shift-stk-supp-line.other-rubl     <> buf_temp-shift-stk-supp-line.new-other-rubl
        then do:
          find first buf_stk-supp-line exclusive-lock
            where buf_stk-supp-line.obj-type   = buf_temp-shift-stk-supp-line.obj-type
              and buf_stk-supp-line.obj-code   = buf_temp-shift-stk-supp-line.obj-code
              and buf_stk-supp-line.cli-type   = buf_temp-shift-stk-supp-line.cli-type
              and buf_stk-supp-line.cli-code   = buf_temp-shift-stk-supp-line.cli-code
              and buf_stk-supp-line.artic      = buf_temp-shift-stk-supp-line.artic
              and buf_stk-supp-line.prod-type  = buf_temp-shift-stk-supp-line.prod-type
              and buf_stk-supp-line.prod-code  = buf_temp-shift-stk-supp-line.prod-code
              and buf_stk-supp-line.sum-type   = buf_temp-shift-stk-supp-line.sum-type
              and buf_stk-supp-line.cat-id     = buf_temp-shift-stk-supp-line.cat-id
              and buf_stk-supp-line.fact-order <= p-first-shift-end-fact-order
              and buf_stk-supp-line.shift-date <> ?
            no-error .
          if not available buf_stk-supp-line
          then do:
            create buf_stk-supp-line .
            assign
              buf_stk-supp-line.obj-type   = buf_temp-shift-stk-supp-line.obj-type
              buf_stk-supp-line.obj-code   = buf_temp-shift-stk-supp-line.obj-code
              buf_stk-supp-line.cli-type   = buf_temp-shift-stk-supp-line.cli-type
              buf_stk-supp-line.cli-code   = buf_temp-shift-stk-supp-line.cli-code
              buf_stk-supp-line.artic      = buf_temp-shift-stk-supp-line.artic
              buf_stk-supp-line.prod-type  = buf_temp-shift-stk-supp-line.prod-type
              buf_stk-supp-line.prod-code  = buf_temp-shift-stk-supp-line.prod-code
              buf_stk-supp-line.fact-order = p-first-shift-end-fact-order
              buf_stk-supp-line.sum-type   = buf_temp-shift-stk-supp-line.sum-type
              buf_stk-supp-line.cat-id     = buf_temp-shift-stk-supp-line.cat-id
              buf_stk-supp-line.fact-date  = p-first-cut-date
              buf_stk-supp-line.shift-num  = p-first-shift-num
              buf_stk-supp-line.shift-date = p-first-shift-date
            .
          end.
          for each buf_stk-supp-line exclusive-lock
            where buf_stk-supp-line.obj-type   = buf_temp-shift-stk-supp-line.obj-type
              and buf_stk-supp-line.obj-code   = buf_temp-shift-stk-supp-line.obj-code
              and buf_stk-supp-line.cli-type   = buf_temp-shift-stk-supp-line.cli-type
              and buf_stk-supp-line.cli-code   = buf_temp-shift-stk-supp-line.cli-code
              and buf_stk-supp-line.artic      = buf_temp-shift-stk-supp-line.artic
              and buf_stk-supp-line.prod-type  = buf_temp-shift-stk-supp-line.prod-type
              and buf_stk-supp-line.prod-code  = buf_temp-shift-stk-supp-line.prod-code
              and buf_stk-supp-line.sum-type   = buf_temp-shift-stk-supp-line.sum-type
              and buf_stk-supp-line.cat-id     = buf_temp-shift-stk-supp-line.cat-id
              and buf_stk-supp-line.fact-order <= p-last-shift-end-fact-order - 0.0000000001
              and buf_stk-supp-line.shift-date <> ?
          on error undo, return error return-value
          :
            for each sub_temp-shift-stk-supp-line
              where sub_temp-shift-stk-supp-line.obj-type   = buf_temp-shift-stk-supp-line.obj-type
                and sub_temp-shift-stk-supp-line.obj-code   = buf_temp-shift-stk-supp-line.obj-code
                and sub_temp-shift-stk-supp-line.cli-type   = buf_temp-shift-stk-supp-line.cli-type
                and sub_temp-shift-stk-supp-line.cli-code   = buf_temp-shift-stk-supp-line.cli-code
                and sub_temp-shift-stk-supp-line.artic      = buf_temp-shift-stk-supp-line.artic
                and sub_temp-shift-stk-supp-line.prod-type  = buf_temp-shift-stk-supp-line.prod-type
                and sub_temp-shift-stk-supp-line.prod-code  = buf_temp-shift-stk-supp-line.prod-code
                and sub_temp-shift-stk-supp-line.fact-order = buf_temp-shift-stk-supp-line.fact-order
                and sub_temp-shift-stk-supp-line.sum-type   begins buf_temp-shift-stk-supp-line.sum-type
            on error undo, return error return-value
            :
              if
                                                                                                  sub_temp-shift-stk-supp-line.fact-qnty      <> sub_temp-shift-stk-supp-line.new-fact-qnty        or    sub_temp-shift-stk-supp-line.sum-base       <> sub_temp-shift-stk-supp-line.new-sum-base         or    sub_temp-shift-stk-supp-line.sum-rubl       <> sub_temp-shift-stk-supp-line.new-sum-rubl         or    sub_temp-shift-stk-supp-line.vat-base       <> sub_temp-shift-stk-supp-line.new-vat-base         or    sub_temp-shift-stk-supp-line.vat-rubl       <> sub_temp-shift-stk-supp-line.new-vat-rubl         or    sub_temp-shift-stk-supp-line.slt-base       <> sub_temp-shift-stk-supp-line.new-slt-base         or    sub_temp-shift-stk-supp-line.slt-rubl       <> sub_temp-shift-stk-supp-line.new-slt-rubl         or    sub_temp-shift-stk-supp-line.road-tax-base  <> sub_temp-shift-stk-supp-line.new-road-tax-base    or    sub_temp-shift-stk-supp-line.road-tax-rubl  <> sub_temp-shift-stk-supp-line.new-road-tax-rubl    or    sub_temp-shift-stk-supp-line.excise-base    <> sub_temp-shift-stk-supp-line.new-excise-base      or    sub_temp-shift-stk-supp-line.excise-rubl    <> sub_temp-shift-stk-supp-line.new-excise-rubl      or    sub_temp-shift-stk-supp-line.transport-base <> sub_temp-shift-stk-supp-line.new-transport-base   or    sub_temp-shift-stk-supp-line.transport-rubl <> sub_temp-shift-stk-supp-line.new-transport-rubl   or    sub_temp-shift-stk-supp-line.other-base     <> sub_temp-shift-stk-supp-line.new-other-base       or    sub_temp-shift-stk-supp-line.other-rubl     <> sub_temp-shift-stk-supp-line.new-other-rubl
              then do:
                find first sub_stk-supp-line exclusive-lock
                  where sub_stk-supp-line.obj-type   = buf_stk-supp-line.obj-type
                    and sub_stk-supp-line.obj-code   = buf_stk-supp-line.obj-code
                    and sub_stk-supp-line.cli-type   = buf_stk-supp-line.cli-type
                    and sub_stk-supp-line.cli-code   = buf_stk-supp-line.cli-code
                    and sub_stk-supp-line.artic      = buf_stk-supp-line.artic
                    and sub_stk-supp-line.prod-type  = buf_stk-supp-line.prod-type
                    and sub_stk-supp-line.prod-code  = buf_stk-supp-line.prod-code
                    and sub_stk-supp-line.fact-order = buf_stk-supp-line.fact-order
                    and sub_stk-supp-line.sum-type   = sub_temp-shift-stk-supp-line.sum-type
                    and sub_stk-supp-line.cat-id     = sub_temp-shift-stk-supp-line.cat-id
                  no-error .
                if not available sub_stk-supp-line
                then do:
                  create sub_stk-supp-line .
                  assign
                    sub_stk-supp-line.obj-type   = buf_stk-supp-line.obj-type
                    sub_stk-supp-line.obj-code   = buf_stk-supp-line.obj-code
                    sub_stk-supp-line.cli-type   = buf_stk-supp-line.cli-type
                    sub_stk-supp-line.cli-code   = buf_stk-supp-line.cli-code
                    sub_stk-supp-line.artic      = buf_stk-supp-line.artic
                    sub_stk-supp-line.prod-type  = buf_stk-supp-line.prod-type
                    sub_stk-supp-line.prod-code  = buf_stk-supp-line.prod-code
                    sub_stk-supp-line.fact-order = buf_stk-supp-line.fact-order
                    sub_stk-supp-line.sum-type   = sub_temp-shift-stk-supp-line.sum-type
                    sub_stk-supp-line.cat-id     = sub_temp-shift-stk-supp-line.cat-id
                    sub_stk-supp-line.fact-date  = buf_stk-supp-line.fact-date
                    sub_stk-supp-line.shift-num  = buf_stk-supp-line.shift-num
                    sub_stk-supp-line.shift-date = buf_stk-supp-line.shift-date
                  .
                end.
                assign
                                                                                                                                                                                                      sub_stk-supp-line.fact-qnty      = sub_stk-supp-line.fact-qnty      + sub_temp-shift-stk-supp-line.fact-qnty      - sub_temp-shift-stk-supp-line.new-fact-qnty           sub_stk-supp-line.sum-base       = sub_stk-supp-line.sum-base       + sub_temp-shift-stk-supp-line.sum-base       - sub_temp-shift-stk-supp-line.new-sum-base            sub_stk-supp-line.sum-rubl       = sub_stk-supp-line.sum-rubl       + sub_temp-shift-stk-supp-line.sum-rubl       - sub_temp-shift-stk-supp-line.new-sum-rubl            sub_stk-supp-line.vat-base       = sub_stk-supp-line.vat-base       + sub_temp-shift-stk-supp-line.vat-base       - sub_temp-shift-stk-supp-line.new-vat-base            sub_stk-supp-line.vat-rubl       = sub_stk-supp-line.vat-rubl       + sub_temp-shift-stk-supp-line.vat-rubl       - sub_temp-shift-stk-supp-line.new-vat-rubl            sub_stk-supp-line.slt-base       = sub_stk-supp-line.slt-base       + sub_temp-shift-stk-supp-line.slt-base       - sub_temp-shift-stk-supp-line.new-slt-base            sub_stk-supp-line.slt-rubl       = sub_stk-supp-line.slt-rubl       + sub_temp-shift-stk-supp-line.slt-rubl       - sub_temp-shift-stk-supp-line.new-slt-rubl            sub_stk-supp-line.road-tax-base  = sub_stk-supp-line.road-tax-base  + sub_temp-shift-stk-supp-line.road-tax-base  - sub_temp-shift-stk-supp-line.new-road-tax-base       sub_stk-supp-line.road-tax-rubl  = sub_stk-supp-line.road-tax-rubl  + sub_temp-shift-stk-supp-line.road-tax-rubl  - sub_temp-shift-stk-supp-line.new-road-tax-rubl       sub_stk-supp-line.excise-base    = sub_stk-supp-line.excise-base    + sub_temp-shift-stk-supp-line.excise-base    - sub_temp-shift-stk-supp-line.new-excise-base         sub_stk-supp-line.excise-rubl    = sub_stk-supp-line.excise-rubl    + sub_temp-shift-stk-supp-line.excise-rubl    - sub_temp-shift-stk-supp-line.new-excise-rubl         sub_stk-supp-line.transport-base = sub_stk-supp-line.transport-base + sub_temp-shift-stk-supp-line.transport-base - sub_temp-shift-stk-supp-line.new-transport-base      sub_stk-supp-line.transport-rubl = sub_stk-supp-line.transport-rubl + sub_temp-shift-stk-supp-line.transport-rubl - sub_temp-shift-stk-supp-line.new-transport-rubl      sub_stk-supp-line.other-base     = sub_stk-supp-line.other-base     + sub_temp-shift-stk-supp-line.other-base     - sub_temp-shift-stk-supp-line.new-other-base          sub_stk-supp-line.other-rubl     = sub_stk-supp-line.other-rubl     + sub_temp-shift-stk-supp-line.other-rubl     - sub_temp-shift-stk-supp-line.new-other-rubl
                .
              end.
            end.
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure cb_rst-ahsp_overturn-exist :
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
procedure cb_rst-ahsp_get-temp-supp-gds :
  define input  parameter p-callback-handle as handle    no-undo .
  define input  parameter p-procedure-name  as character no-undo .
  define buffer buf_temp-supp-gds for temp-supp-gds .
  do
  on error undo, return error return-value
  :
    for each buf_temp-supp-gds
    on error undo, return error return-value
    :
      run value(p-procedure-name) in p-callback-handle
        (input  buf_temp-supp-gds.cli-type
        ,input  buf_temp-supp-gds.cli-code
        ,input  buf_temp-supp-gds.artic
        ,input  buf_temp-supp-gds.prod-type
        ,input  buf_temp-supp-gds.prod-code
        ) .
    end.
  end.
end procedure.
procedure rst-ahsp-init-clients :
  define buffer buf_doclslib-clients for doclslib-clients .
  define buffer buf_doclslib-clients-goods for doclslib-clients-goods .
  do
  on error undo, return error return-value
  :
    for each buf_doclslib-clients
    on error undo, return error return-value
    :
      delete buf_doclslib-clients .
    end.
    for each buf_doclslib-clients-goods
    on error undo, return error return-value
    :
      find first buf_doclslib-clients
        where buf_doclslib-clients.cli-type = buf_doclslib-clients-goods.cli-type
          and buf_doclslib-clients.cli-code = buf_doclslib-clients-goods.cli-code
        no-error .
      if not available buf_doclslib-clients
      then do:
        create buf_doclslib-clients .
        assign
          buf_doclslib-clients.cli-type = buf_doclslib-clients-goods.cli-type
          buf_doclslib-clients.cli-code = buf_doclslib-clients-goods.cli-code
        .
      end.
    end.
  end.
end procedure.
procedure rst-ahsp-init-clients-goods :
  define buffer buf_doclslib-clients-goods for doclslib-clients-goods .
  define buffer buf_doc-list       for doc-list .
  define buffer buf_parts          for ub.parts .
  define variable v-gds-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    for each buf_doclslib-clients-goods
    on error undo, return error return-value
    :
      delete buf_doclslib-clients-goods .
    end.
    for each buf_doc-list
    on error undo, return error return-value
    :
      for each buf_parts no-lock
        where buf_parts.out-code = buf_doc-list.doc-code
      on error undo, return error return-value
      :
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_parts.artic
  ,input  buf_parts.prod-type
  ,input  buf_parts.prod-code
  ,output v-gds-code
  )  .
        find first buf_doclslib-clients-goods
          where buf_doclslib-clients-goods.cli-type  = buf_parts.supp-type
            and buf_doclslib-clients-goods.cli-code  = buf_parts.supp-code
            and buf_doclslib-clients-goods.artic     = buf_parts.artic
            and buf_doclslib-clients-goods.prod-type = buf_parts.prod-type
            and buf_doclslib-clients-goods.prod-code = buf_parts.prod-code
          no-error .
        if not available buf_doclslib-clients-goods
        then do:
          create buf_doclslib-clients-goods .
          assign
            buf_doclslib-clients-goods.cli-type  = buf_parts.supp-type
            buf_doclslib-clients-goods.cli-code  = buf_parts.supp-code
            buf_doclslib-clients-goods.artic     = buf_parts.artic
            buf_doclslib-clients-goods.prod-type = buf_parts.prod-type
            buf_doclslib-clients-goods.prod-code = buf_parts.prod-code
          .
        end.
      end.
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
        "Складской архив по поставщикам" skip
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
        "Складской архив по поставщикам" skip
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
procedure fill-artic :
  define input  parameter p-gds-code  as integer   no-undo .
  define output parameter p-artic     as character no-undo .
  define output parameter p-prod-type as character no-undo .
  define output parameter p-prod-code as integer   no-undo .
  define buffer buf_temp-goods for temp-goods .
  define buffer buf_goods for ub.goods .
  do
  on error undo, return error return-value
  :
    find first buf_temp-goods
      where buf_temp-goods.gds-code = p-gds-code
      no-error .
    if not available buf_temp-goods
    then do:
      find first buf_goods no-lock
        where buf_goods.gds-code = p-gds-code
        no-error .
      if not available buf_goods
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден товар" skip
          "Код товара" p-gds-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      create buf_temp-goods .
      assign
        buf_temp-goods.gds-code  = p-gds-code
        buf_temp-goods.artic     = buf_goods.artic
        buf_temp-goods.prod-type = buf_goods.prod-type
        buf_temp-goods.prod-code = buf_goods.prod-code
      .
    end.
    assign
      p-artic     = buf_temp-goods.artic
      p-prod-type = buf_temp-goods.prod-type
      p-prod-code = buf_temp-goods.prod-code
    .
  end.
end procedure.
