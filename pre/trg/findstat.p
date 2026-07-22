block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-host-code      like ub.fin-doc.host-code no-undo .
define input parameter p-fin-doc-code   like ub.fin-doc.fin-doc-code no-undo .
define input parameter p-close-mode     as character no-undo .
define input parameter p-author         as character no-undo .
define input parameter p-status_        as character no-undo .
define input-output parameter p-status-date    like ub.fin-doc.fact-date no-undo .
define input parameter p-silent                       as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Перевод статусов для платежей".
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
define new global shared variable g#lib-farh as handle no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fd-attr-code :
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
            when 'shift-date':U then do:     assign     p-label = "Дата смены"     p-type = 'T':U      p-format = "99/99/9999"     p-label = "Дата смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'shift-num':U then do:     assign     p-label = "П.смены"     p-type = 'I':U      p-format = "99"     p-label = "П.смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'shift-name':U then do:     assign     p-label = "№ смены"     p-type = 'C':U      p-format = "X(2)"     p-label = "№ смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'barcode':U then do:     assign     p-label = "Штрих-код"     p-type = 'C':U      p-format = "X(20)"     p-label = "Штрих-код"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'lockid':U then do:     assign     p-label = "ID блокировки чека"     p-type = 'C':U      p-format = "X(2)"     p-label = "ID блокировки чека"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'cover_sheet':U then do:     assign     p-label = "Разбиение по номиналам"     p-type = 'C':U      p-format = "X(4000)"     p-label = "Разбиение по номиналам"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'pre-vedom':U then do:     assign     p-label = "Атрибут для препроводительной ведомости"     p-type = 'C':U      p-format = "X(256)"     p-label = "Атрибут для препроводительной ведомости"     p-user-can-edit  = false     p-output-display = false     p-other = '':u      .   end.
            when 'contr-kb':U then do:     assign     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-type = 'I':U      p-format = ">>>9"     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure fd-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-tooltip = "Дата смены"     p-label = "Дата смены" .   end.
            when 'shift-num':U then do:     assign     p-tooltip = "П.смены"     p-label = "П.смены" .   end.
            when 'shift-name':U then do:     assign     p-tooltip = "№ смены"     p-label = "№ смены" .   end.
            when 'barcode':U then do:     assign     p-tooltip = "Штрих-код"     p-label = "Штрих-код" .   end.
            when 'lockid':U then do:     assign     p-tooltip = "ID блокировки чека"     p-label = "ID блокировки чека" .   end.
            when 'cover_sheet':U then do:     assign     p-tooltip = "Разбиение по номиналам"     p-label = "Разбиение по номиналам" .   end.
            when 'pre-vedom':U then do:     assign     p-tooltip = "Атрибут для препроводительной ведомости"     p-label = "Атрибут для препроводительной ведомости" .   end.
            when 'contr-kb':U then do:     assign     p-tooltip = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами" .   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure fin-doc-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
define input parameter p-attr-code     like ub.fin-doc-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.fin-doc-attr.attr-value no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-doc-attr for ub.fin-doc-attr.
run fd-attr-code in this-procedure
                                  (input  p-attr-code
                                  ,output v-type
                                  ,output v-format
                                  ,output v-label
                                  ,output v-user-can-edit
                                  ,output v-output-display
                                  ,output v-other
                                  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_fin-doc-attr  exclusive-lock  where
          buf_fin-doc-attr.attr-code    = p-attr-code
      AND buf_fin-doc-attr.host-code    = p-host-code
      AND buf_fin-doc-attr.fin-doc-code     = p-fin-doc-code  no-error .
  if not available  buf_fin-doc-attr then do:
      create buf_fin-doc-attr.
      assign
      buf_fin-doc-attr.attr-code    = p-attr-code
      buf_fin-doc-attr.attr-value   = p-attr-value
      buf_fin-doc-attr.host-code    = p-host-code
      buf_fin-doc-attr.fin-doc-code     = p-fin-doc-code
      .
  end.
  else do:
       assign
       buf_fin-doc-attr.attr-value = p-attr-value.
  end.
 end.
end procedure.
procedure fd-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
    define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
    define input parameter p-code          like ub.fin-doc-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_fin-doc-attr for ub.fin-doc-attr .
    define variable  v-type           as character no-undo .
    define variable  v-format         as character no-undo .
    define variable  v-label          as character no-undo .
    define variable  v-user-can-edit  as logical   no-undo .
    define variable  v-output-display as logical   no-undo .
    define variable  v-other          as character no-undo .
    run fd-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_fin-doc-attr exclusive-lock
      where buf_fin-doc-attr.host-code  = p-host-code
        and buf_fin-doc-attr.fin-doc-code  = p-fin-doc-code
        and buf_fin-doc-attr.attr-code = p-code
      no-error .
    if  available buf_fin-doc-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure fd-attr-delete :
  do
  on error undo, return error
  :
  define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
  define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
  define input parameter p-code          like ub.fin-doc-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
    define buffer buf_fin-doc-attr for ub.fin-doc-attr .
    define variable  v-type           as character no-undo .
    define variable  v-format         as character no-undo .
    define variable  v-label          as character no-undo .
    define variable  v-user-can-edit  as logical   no-undo .
    define variable  v-output-display as logical   no-undo .
    define variable  v-other          as character no-undo .
    run fd-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_fin-doc-attr exclusive-lock
      where buf_fin-doc-attr.host-code  = p-host-code
        and buf_fin-doc-attr.fin-doc-code  = p-fin-doc-code
        and buf_fin-doc-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_fin-doc-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_fin-doc-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure fin-doc-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.fin-doc-attr.fin-doc-code     no-undo .
define input  parameter p-attr-code    like ub.fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-doc-attr for ub.fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_fin-doc-attr no-lock where
          buf_fin-doc-attr.attr-code    = p-attr-code
      AND buf_fin-doc-attr.host-code     = p-host-code
      AND buf_fin-doc-attr.fin-doc-code = p-fin-doc-code      no-error .
  if available  buf_fin-doc-attr then do:
    assign
    p-attr-value = buf_fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
procedure fd-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-news = no.   end.
            when 'shift-num':U then do:     assign     p-news = no.   end.
            when 'shift-name':U then do:     assign     p-news = no.   end.
            when 'barcode':U then do:     assign     p-news = no.   end.
            when 'lockid':U then do:     assign     p-news = no.   end.
            when 'cover_sheet':U then do:     assign     p-news = no.   end.
            when 'pre-vedom':U then do:     assign     p-news = no.   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа " + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure c-fin-doc-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.c-fin-doc-attr.host-code  no-undo .
define input parameter p-fin-doc-code  like ub.c-fin-doc-attr.fin-doc-code   no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input parameter p-attr-code     like ub.c-fin-doc-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.c-fin-doc-attr.attr-value no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
                                  (input  p-attr-code
                                  ,output v-type
                                  ,output v-format
                                  ,output v-label
                                  ,output v-user-can-edit
                                  ,output v-output-display
                                  ,output v-other
                                  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_c-fin-doc-attr  exclusive-lock  where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      AND buf_c-fin-doc-attr.host-code    = p-host-code
      AND buf_c-fin-doc-attr.fin-doc-code     = p-fin-doc-code
      AND buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      AND buf_c-fin-doc-attr.chip-num         = p-chip-num      no-error .
  if not available  buf_c-fin-doc-attr then do:
      create buf_c-fin-doc-attr.
      assign
      buf_c-fin-doc-attr.attr-code    = p-attr-code
      buf_c-fin-doc-attr.attr-value   = p-attr-value
      buf_c-fin-doc-attr.host-code    = p-host-code
      buf_c-fin-doc-attr.fin-doc-code     = p-fin-doc-code
      .
  end.
  else do:
        buf_c-fin-doc-attr.attr-value   = p-attr-value .
  end.
 end.
end procedure.
procedure c-fin-doc-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.c-fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.c-fin-doc-attr.fin-doc-code     no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input  parameter p-attr-code    like ub.c-fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.c-fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_c-fin-doc-attr no-lock where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      AND buf_c-fin-doc-attr.fin-doc-code      = p-fin-doc-code
      AND buf_c-fin-doc-attr.host-code      = p-host-code
      AND buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      AND buf_c-fin-doc-attr.chip-num         = p-chip-num      no-error .
  if available  buf_c-fin-doc-attr then do:
    assign
    p-attr-value = buf_c-fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
procedure c-fin-doc-attr-value-nextchip :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.c-fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.c-fin-doc-attr.fin-doc-code     no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input  parameter p-attr-code    like ub.c-fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.c-fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_c-fin-doc-attr no-lock where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      and buf_c-fin-doc-attr.fin-doc-code      = p-fin-doc-code
      and buf_c-fin-doc-attr.host-code      = p-host-code
      and buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      and buf_c-fin-doc-attr.chip-num         > p-chip-num      no-error .
  if available  buf_c-fin-doc-attr then do:
    assign
    p-attr-value = buf_c-fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info7, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info7, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
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
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-fact-order as decimal no-undo .
define variable v-shift-fact-order as decimal no-undo .
define variable v-fact-num as integer no-undo .
define variable v-shift-end-fact-order as decimal no-undo .
define variable v-day-end-fact-order as decimal no-undo .
define variable v-pre-status_ as character no-undo .
define variable v-curr-abbr like ub.currency.curr-abbr no-undo.
define variable v-status_ as character no-undo .
define variable v-ask-date as logical no-undo .
define variable v-ask-message as character no-undo .
define variable v-correct as logical no-undo .
define variable v-err-mess as character no-undo .
define variable v-ret-mess as character no-undo .
define variable v-datestr as character no-undo .
define variable v-prn-doc-code like ub.fin-doc.prn-doc-code no-undo .
define variable v-fin-doc-type like ub.fin-doc.fin-doc-type no-undo .
define variable v-line-rec as recid no-undo .
define variable v-update-counter-flag as logical no-undo .
define variable v-update-counter as integer no-undo .
define variable mValue as character no-undo .
define variable MParam as character no-undo.
define variable mask-pko as character no-undo .
define variable mask-rko as character no-undo .
define variable current-pko-rko as character no-undo .
define variable current-ruleID as character no-undo .
define variable v-current-num as integer no-undo .
define variable v-prev-prn-doc-code as character no-undo .
define variable v-matches as character no-undo .
define variable v-key     as character no-undo.
define buffer buf_fin-doc for ub.fin-doc.
define buffer buf_fin-statement-line for ub.fin-statement-line.
define buffer locked_fin-statement-line for ub.fin-statement-line.
define buffer buf_payment for ub.payment.
define buffer buf_thbj-attr for ub.thbj-attr.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_fin-doc exclusive-lock where
            buf_fin-doc.host-code = p-host-code
         AND buf_fin-doc.fin-doc-code = p-fin-doc-code .
  assign
  v-prn-doc-code = buf_fin-doc.prn-doc-code
  v-fin-doc-type = buf_fin-doc.fin-doc-type
  .
  run trg/findgraf.p (
                  input  buf_fin-doc.host-code
                  ,input  buf_fin-doc.fin-doc-code
                  ,input  p-close-mode
                  ,input  p-author
                  ,input  buf_fin-doc.status_
                  ,input  ?
                  ,output v-status_
                  ,output v-ask-date
                  ,output v-ask-message
                  ) no-error.
  if error-status:error
  or v-status_ <> p-status_
  or (v-ask-date and p-status-date = ?)
  then do:
    run err-mess ("Ошибка при проверке возможности открытия/закрытия/отказа", output v-ret-mess).
    undo main-block, return error v-ret-mess.
  end.
  assign
  v-pre-status_ = buf_fin-doc.status_
  .
  if p-status-date = ? and v-ask-date then do:
    run gbl/d-prompt.w (
      'title=':u + "Дата смены статуса" + '\':u
    + 'text1=':u + "Введите дату" + '\':u
    + 'format=99/99/9999' + '\':u
    + 'type=' + 'T':U + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u
    + 'readonly=no' + '\':u
    , input-output v-datestr
    ).
    if return-value = 'false':u then undo main-block, return error v-ret-mess.
    assign
    v-date = date(integer(substr(v-datestr, 4, 2))
                ,integer(substr(v-datestr, 1, 2))
                ,integer(substr(v-datestr, 7, 4)))
    no-error .
    if error-status:error then do:
      message
      "Вы ввели неверную дату"
      view-as alert-box error .
      undo main-block, return error .
    end.
    assign
    p-status-date = v-date
    .
  end.
  else do:
    if p-status-date = ? then do:
      run cur-time in this-procedure(output v-date, output v-time).
    end.
    if p-status-date <> ? then do:
      assign
      v-date = p-status-date
      .
    end.
  end.
  CASE buf_fin-doc.fin-doc-type:
    when 'пко':U then do:
      run check-income-cash in this-procedure no-error .
      if error-status:error then do:
        run err-mess (input return-value , output v-ret-mess).
        undo main-block, return error  v-ret-mess.
      end.
    end.
    when 'рко':U then do:
      run check-expense-cash in this-procedure no-error .
      if error-status:error then do:
        run err-mess (input return-value , output v-ret-mess).
        undo main-block, return error  v-ret-mess.
      end.
    end.
    when 'ппп':U then do:
      run check-income-cashless in this-procedure no-error .
      if error-status:error then do:
        run err-mess (input return-value , output v-ret-mess).
        undo main-block, return error  v-ret-mess.
      end.
    end.
    when 'рпп':U then do:
      run check-expense-cashless in this-procedure no-error .
      if error-status:error then do:
        run err-mess (input return-value , output v-ret-mess).
        undo main-block, return error  v-ret-mess.
      end.
    end.
    when 'апп':U then do:
      run check-income-payoff in this-procedure no-error .
      if error-status:error then do:
        run err-mess (input return-value , output v-ret-mess).
        undo main-block, return error  v-ret-mess.
      end.
    end.
    when 'апр':U then do:
      run check-expense-payoff in this-procedure no-error .
      if error-status:error then do:
        run err-mess (input return-value , output v-ret-mess).
        undo main-block, return error  v-ret-mess.
      end.
    end.
  END CASE.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  buf_fin-doc.host-code
  ,input  v-date
  ,output buf_fin-doc.actual-base-rate
  ,output buf_fin-doc.actual-base-scale
  ) no-error .
  if error-status:error then do:
    if return-value <> "":U then do:
      if not p-silent then
      message
      return-value view-as alert-box .
      undo main-block, return error  return-value .
    end.
  end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  buf_fin-doc.curr-code
  ,input  v-date
  ,output buf_fin-doc.actual-exch-rate
  ,output buf_fin-doc.actual-exch-scale
  ,output v-curr-abbr
  ) no-error .
  if error-status:error then do:
    if return-value <> "":U then do:
      if not p-silent then
      message
      return-value view-as alert-box .
      undo main-block, return error  return-value .
    end.
  end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  buf_fin-doc.contract-curr
  ,input  v-date
  ,output buf_fin-doc.actual-contract-rate
  ,output buf_fin-doc.actual-contract-scale
  ,output v-curr-abbr
  ) no-error .
  if error-status:error then do:
    if return-value <> "":U then do:
      if not p-silent then
      message
      return-value view-as alert-box .
      undo main-block, return error  return-value .
    end.
  end.
  if error-status:error then do:
    if return-value <> "":U then do:
      if not p-silent then
      message
      return-value view-as alert-box .
      undo main-block, return error  return-value .
    end.
  end.
  CASE p-status_:
    when 'новый':U then do:
      assign
      buf_fin-doc.status_ = p-status_
      buf_fin-doc.user-db-num-perm = ?
      buf_fin-doc.user-name-perm = "":U
      buf_fin-doc.perm-date = ?
      buf_fin-doc.user-db-num-pl = ?
      buf_fin-doc.user-name-pl = "":U
      buf_fin-doc.pay-date = ?
      buf_fin-doc.user-db-num-fact = ?
      buf_fin-doc.user-name-fact = "":U
      buf_fin-doc.fact-date = ?
      buf_fin-doc.fact-order = 0
      .
    end.
    when 'разрешен':U then do:
      assign
      buf_fin-doc.status_ = p-status_
      buf_fin-doc.user-db-num-perm = g#db-num
      buf_fin-doc.user-name-perm = g#userid
      buf_fin-doc.perm-date = (if p-close-mode = '<открытие документа>':U then buf_fin-doc.perm-date else v-date)
      buf_fin-doc.user-db-num-pl = ?
      buf_fin-doc.user-name-pl = "":U
      buf_fin-doc.pay-date = ?
      buf_fin-doc.user-name-fact = "":U
      buf_fin-doc.user-db-num-fact = ?
      buf_fin-doc.fact-date = ?
      buf_fin-doc.fact-order = 0
      .
      if not (buf_fin-doc.obj-type = ''
      and buf_fin-doc.obj-code = 0)
      and p-close-mode = '<открытие документа>':U
      and lookup(buf_fin-doc.fin-ext-doc-type, 'пко,рко':U) > 0
      then do:
        run fill-shift in this-procedure ( buffer buf_fin-doc
                                        ) no-error.
        if error-status :error then do:
          run err-mess in this-procedure ( substitute( "Ошибка при заполнении даты и номера смены&1&2&1&3"
                                                    ,chr(10), error-status :get-message (1), return-value  )
                                                    ,output v-ret-mess).
          undo main-block, return error v-ret-mess.
        end.
      end.
    end.
    when 'банк':U then do:
      assign
      buf_fin-doc.status_ = p-status_
      buf_fin-doc.user-db-num-pl = g#db-num
      buf_fin-doc.user-name-pl = g#userid
      buf_fin-doc.pay-date = (if p-close-mode = '<открытие документа>':U then buf_fin-doc.pay-date else v-date)
      buf_fin-doc.user-name-fact = "":U
      buf_fin-doc.user-db-num-fact = ?
      buf_fin-doc.fact-date = ?
      buf_fin-doc.fact-order = 0
      buf_fin-doc.fact-author = '':U
      .
      if p-close-mode = '<открытие документа>':U then do:
        for each buf_fin-statement-line no-lock where
              buf_fin-statement-line.host-code = buf_fin-doc.host-code
          and buf_fin-statement-line.fin-doc-code = buf_fin-doc.fin-doc-code
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
          find first locked_fin-statement-line exclusive-lock where
                    recid(locked_fin-statement-line) = recid(buf_fin-statement-line).
          v-line-rec = RECID(buf_fin-statement-line).
          run ref/finsttml.p (
                        INPUT NO
                        ,INPUT-OUTPUT v-line-rec
                        ,INPUT 'удаление':U
                        ,INPUT buf_fin-statement-line.host-code
                        ,INPUT buf_fin-statement-line.sttm-code
                        ,INPUT buf_fin-statement-line.fin-doc-code
                        ,INPUT buf_fin-statement-line.pay-date
                        ,INPUT buf_fin-statement-line.prn-doc-code
                        ,INPUT buf_fin-statement-line.fin-ext-doc-type
                        ,input buf_fin-statement-line.rp-bik
                        ,input buf_fin-statement-line.rp-bank-name
                        ,input buf_fin-statement-line.rp-bank-city
                        ,input buf_fin-statement-line.rp-c-schet
                        ,input buf_fin-statement-line.rp-r-schet
                        ,input buf_fin-statement-line.rp-name
                        ,input buf_fin-statement-line.rp-inn
                        ,input buf_fin-statement-line.rp-kpp
                        ,INPUT buf_fin-statement-line.sum-doc
                        ,input p-author
                        ,INPUT buf_fin-statement-line.ps
                          )
              no-error.
          if error-status:error then do:
            run err-mess in this-procedure ( substitute( "Ошибка при удалении строки банковской выписки &1&2&3"
                                                      ,return-value, chr(10), error-status :get-message (1) )
                                                      ,output v-ret-mess).
            undo main-block, return error v-ret-mess.
          end.
        end.
      end.
    end.
    when 'отказ':U then do:
      run get-fact-num in this-procedure ( input buf_fin-doc.host-code
                                          ,output v-fact-num).
      run factord in this-procedure (
                                       input  v-date
                                      ,input  v-time
                                      ,input  v-fact-num
                                      ,input  ?
                                      ,input  0
                                      ,input  no
                                      ,output v-fact-order
                                      ,output v-shift-end-fact-order
                                      ,output v-day-end-fact-order
                                      ).
      if buf_fin-doc.shift-date <> ? then do:
        run factord in this-procedure (
                                        input  v-date
                                        ,input  v-time
                                        ,input  v-fact-num
                                        ,input  buf_fin-doc.shift-date
                                        ,input  buf_fin-doc.shift-num
                                        ,input  yes
                                        ,output v-shift-fact-order
                                        ,output v-shift-end-fact-order
                                        ,output v-day-end-fact-order
                                        ).
      end.
      assign
      buf_fin-doc.status_ = p-status_
      buf_fin-doc.user-db-num-fact = g#db-num
      buf_fin-doc.user-name-fact = g#userid
      buf_fin-doc.fact-date = v-date
      buf_fin-doc.fact-order = v-fact-order
      buf_fin-doc.fact-order = v-shift-fact-order
      buf_fin-doc.fact-num = v-fact-num
      .
    end.
    when 'факт':U then do:
      run get-fact-num in this-procedure ( input buf_fin-doc.host-code
                                          ,output v-fact-num).
      run factord in this-procedure (
                                       input  v-date
                                      ,input  v-time
                                      ,input  v-fact-num
                                      ,input  ?
                                      ,input  0
                                      ,input  no
                                      ,output v-fact-order
                                      ,output v-shift-end-fact-order
                                      ,output v-day-end-fact-order
                                      ).
      if buf_fin-doc.shift-date <> ? then do:
        run factord in this-procedure (
                                        input  v-date
                                        ,input  v-time
                                        ,input  v-fact-num
                                        ,input  buf_fin-doc.shift-date
                                        ,input  buf_fin-doc.shift-num
                                        ,input  yes
                                        ,output v-shift-fact-order
                                        ,output v-shift-end-fact-order
                                        ,output v-day-end-fact-order
                                        ).
      end.
      define variable varobj-shift-date as date no-undo .
      define variable varobj-shift-num as integer no-undo .
      define variable varobj-shift-name as character no-undo .
      if not (buf_fin-doc.obj-type = ''
      and buf_fin-doc.obj-code = 0)
      and p-close-mode = '<открытие документа>':U
      and lookup(buf_fin-doc.fin-ext-doc-type, 'пко,рко':U) > 0
      then do:
        run fill-shift in this-procedure ( buffer buf_fin-doc
                                        ) no-error.
        if error-status :error then do:
          run err-mess in this-procedure ( substitute( "Ошибка при заполнении даты и номера смены&1&2&1&3"
                                                    ,chr(10), error-status :get-message (1), return-value  )
                                                    ,output v-ret-mess).
          undo main-block, return error v-ret-mess.
        end.
      end.
      assign
      buf_fin-doc.status_ = p-status_
      buf_fin-doc.user-db-num-fact = g#db-num
      buf_fin-doc.user-name-fact = g#userid
      buf_fin-doc.fact-date = v-date
      buf_fin-doc.fact-order = v-fact-order
      buf_fin-doc.shift-fact-order = v-shift-fact-order
      buf_fin-doc.fact-author = p-author
      buf_fin-doc.fact-num = v-fact-num
      .
      define variable v-today as date no-undo .
      run cur-time in this-procedure ( output v-today, output v-time).
      if buf_fin-doc.fact-date < v-today then do:
        assign
        buf_fin-doc.is-back-date = yes.
      end.
      else do:
        if buf_fin-doc.shift-flag = integer('1':U)
        and buf_fin-doc.shift-date <> ? then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  buf_fin-doc.obj-type
  ,input  buf_fin-doc.obj-code
  ,output varobj-shift-date
  ,output varobj-shift-num
  ,output varobj-shift-name
  )  .
          if not (buf_fin-doc.shift-date = varobj-shift-date and
                  buf_fin-doc.shift-num  = varobj-shift-num  )   then do:
            assign
              buf_fin-doc.is-back-date = yes.
          end.
        end.
      end.
      if not p-author = 'auto':U
      and buf_fin-doc.shift-flag = integer('1':U)
      and buf_fin-doc.is-back-date = yes
      then do:
        define variable var-log as logical no-undo .
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  g#db-num
    ,input  g#userid
    ,input  0
    ,input  'actn_fin-doc_create-back-shift':U
    ,input  'object':U
    ,input  buf_fin-doc.host-code
    ,input  buf_fin-doc.obj-type
    ,input  buf_fin-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output var-log
    )  .
end.
        if not var-log then do:
          run err-mess in this-procedure ( substitute( "Ошибка про проверке возможности изменения статуса задней сменой&1&2&1&3"
                                                    ,chr(10)
                                                    , error-status :get-message (1)
                                                    , return-value  )
                                                    ,output v-ret-mess).
          undo main-block, return error v-ret-mess.
        end.
      end.
      if buf_fin-doc.contract-code > 0 then do:
        run str/calc-bal.p (
                             input "findoc"
                            ,input yes
                            ,input buf_fin-doc.fin-ext-doc-type
                            ,input buf_fin-doc.host-code
                            ,input buf_fin-doc.contract-code
                            ,input buf_fin-doc.sum-contr
                            ,input buf_fin-doc.sum-rubl
                            ,input buf_fin-doc.sum-base) no-error .
        if error-status:error then do:
          run err-mess in this-procedure ( substitute("Ошибка при расчете баланса по договору&1&2&1&3"
                                                      ,chr(10)
                                                      , error-status:get-message(1)
                                                      , return-value )
                                         ,output v-ret-mess).
          undo main-block, return error v-ret-mess.
        end.
      end.
      if buf_fin-doc.fin-ext-doc-type = 'пко':U
      or buf_fin-doc.fin-ext-doc-type = 'ппп':U
      or buf_fin-doc.fin-ext-doc-type = 'апп':U then do:
        define variable v-num-dc as integer no-undo .
        run str/lock-dc.p ( input ?
                    ,input this-procedure:handle
                    ,input 'fin-doc':U
                    ,input string(buf_fin-doc.fin-doc-code)
                    ,input '':U
                    ,input 1
                    ,input no
                    ,input '':U
                    ,output v-num-dc) no-error.
        if error-status:error then do:
          run err-mess in this-procedure ( substitute("Ошибка при блокировании ДК, к котоым привязан платеж&1&2&1&3"
                                                      ,chr(10)
                                                      , error-status:get-message(1)
                                                      , return-value )
                                         ,output v-ret-mess).
          undo main-block, return error v-ret-mess.
        end.
        if v-num-dc > 0 then do:
          for each buf_payment exclusive-lock where
                  buf_payment.source-type = 'платеж':U
              and buf_payment.source-ref = string(buf_fin-doc.fin-doc-code)
          on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
          on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
          on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
          :
            assign
            buf_payment.fact-date = buf_fin-doc.fact-date
            buf_payment.closid = buf_fin-doc.user-name-fact
            buf_payment.status_ = 'факт':U
            .
          end.
          run str/saledc.p
            (
            input parparentproc
            ,input this-procedure :handle
            ,input ?
            ,input 'fin-doc-on-card':U
            ,input ?
            ,input ""
            ,input 0
            ,input 0
            ,input 0
            ,input g#db-num
            ,input string(buf_fin-doc.fin-doc-code)
            ,input buf_fin-doc.doc-date
            ,input buf_fin-doc.fact-date
            ,input 0
            ,input 1
            ,input ?
            ,input yes
            ) no-error .
          if error-status:error then do:
            undo, return error return-value .
          end.
        end.
      end.
    end.
  END CASE.
  release buf_fin-doc no-error .
  if error-status:error then do:
    run err-mess (substitute("Ошибка при смене статуса на &1", p-status_), output v-ret-mess).
    undo main-block, return error v-ret-mess.
  end.
  if p-status_ = 'факт':U then do:
if (valid-handle(g#lib-farh) <> true) then do:   run str/lib-farh.p persistent no-error .   if error-status :error or (valid-handle(g#lib-farh) <> true) then do:     message       "Error starting lib-farh.p" skip       g#lib-farh skip       g#lib-farh :type skip       g#lib-farh :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-farh_taskclcd in g#lib-farh
(input p-host-code
,input p-fin-doc-code
,input 'all':U
,input g#userid
,input 'close':u
) no-error
.
    if error-status:error then do:
      run err-mess (substitute("Ошибка при расчете архивов по платежу: &1 &2", return-value, error-status:get-message(1)), output v-ret-mess).
      undo main-block, return error v-ret-mess.
    end.
    run release-auto-fill-prn-doc-code in this-procedure (input v-update-counter-flag, input v-update-counter).
  end.
end.
procedure check-income-cash :
  do
  on error undo, return error return-value
  :
    if p-close-mode = '<закрытие документа>':U and buf_fin-doc.doc-date <> v-date then do:
       run err-mess (substitute("Для платежа типа &1 дата &2 должна равняться дате док", buf_fin-doc.fin-doc-type, p-status_), output v-ret-mess).
       undo, return error (if p-silent = ? then v-ret-mess else '':U).
    end.
    if p-status_ = 'факт':U then do:
      run auto-fill-prn-doc-code in this-procedure (output v-update-counter-flag, output v-update-counter).
    end.
        run ref/findoc01.p (
                    input 'ИЗМЕНЕНИЕ':U
                    ,input p-close-mode
                    ,input buf_fin-doc.host-code            ,input buf_fin-doc.fin-doc-code         ,input buf_fin-doc.an-uchet-code        ,input buf_fin-doc.an-uchet-value       ,input buf_fin-doc.base-rate            ,input buf_fin-doc.base-scale           ,input buf_fin-doc.cel-nazn-code        ,input buf_fin-doc.cel-nazn-value       ,input buf_fin-doc.contract-code        ,input buf_fin-doc.contract-curr        ,input buf_fin-doc.contract-rate        ,input buf_fin-doc.contract-scale       ,input buf_fin-doc.cor-acc              ,input buf_fin-doc.cor-acc-value        ,input buf_fin-doc.cor-acc1             ,input buf_fin-doc.cor-acc1-value       ,input buf_fin-doc.curr-code            ,input buf_fin-doc.doc-date             ,input buf_fin-doc.shift-date           ,input buf_fin-doc.shift-num            ,input buf_fin-doc.shift-name           ,input buf_fin-doc.enclosure            ,input buf_fin-doc.exch-rate            ,input buf_fin-doc.exch-scale           ,input buf_fin-doc.f104                 ,input buf_fin-doc.f105                 ,input buf_fin-doc.f106                 ,input buf_fin-doc.f107                 ,input buf_fin-doc.f108                 ,input buf_fin-doc.f109                 ,input buf_fin-doc.f110                 ,input buf_fin-doc.f22                  ,input buf_fin-doc.f23                  ,input buf_fin-doc.fact-date            ,input buf_fin-doc.fin-doc-type         ,input buf_fin-doc.fin-ext-doc-type     ,input buf_fin-doc.in-doc-code          ,input buf_fin-doc.in-host-code         ,input buf_fin-doc.including            ,input buf_fin-doc.nazn-pl              ,input buf_fin-doc.naznach-plat         ,input buf_fin-doc.ocher-pl             ,input buf_fin-doc.out-doc-code         ,input buf_fin-doc.out-host-code        ,input buf_fin-doc.pay-date             ,input buf_fin-doc.payer-bank-name      ,input buf_fin-doc.payer-bank-city      ,input buf_fin-doc.payer-bik            ,input buf_fin-doc.payer-c-schet        ,input buf_fin-doc.payer-code           ,input buf_fin-doc.payer-code-schet     ,input buf_fin-doc.payer-dop1           ,input buf_fin-doc.payer-dop2           ,input buf_fin-doc.payer-inn            ,input buf_fin-doc.payer-kpp            ,input buf_fin-doc.payer-name           ,input buf_fin-doc.payer-okpo           ,input buf_fin-doc.payer-passport      ,input buf_fin-doc.payer-r-schet        ,input buf_fin-doc.payer-type           ,input buf_fin-doc.perm-date            ,input buf_fin-doc.prn-doc-code         ,input buf_fin-doc.PS                   ,input buf_fin-doc.receiver-bank-name   ,input buf_fin-doc.receiver-bank-city   ,input buf_fin-doc.receiver-bik         ,input buf_fin-doc.receiver-c-schet     ,input buf_fin-doc.receiver-code        ,input buf_fin-doc.receiver-code-schet  ,input buf_fin-doc.receiver-dop1        ,input buf_fin-doc.receiver-dop2        ,input buf_fin-doc.receiver-inn         ,input buf_fin-doc.receiver-kpp         ,input buf_fin-doc.receiver-name        ,input buf_fin-doc.receiver-okpo        ,input buf_fin-doc.receiver-passport    ,input buf_fin-doc.receiver-r-schet     ,input buf_fin-doc.receiver-type        ,input buf_fin-doc.srok-pl              ,input buf_fin-doc.stat-pl              ,input buf_fin-doc.str-podr-code        ,input buf_fin-doc.str-podr-type        ,input buf_fin-doc.str-podr-name        ,input buf_fin-doc.sum-base             ,input buf_fin-doc.sum-doc              ,input buf_fin-doc.sum-rubl             ,input buf_fin-doc.sum-contr            ,input buf_fin-doc.trn-doc-code         ,input buf_fin-doc.vid-opl              ,input buf_fin-doc.vid-plat
                    ,input buf_fin-doc.con-sum-rubl         ,input buf_fin-doc.con-sum-base         ,input buf_fin-doc.con-sum-doc          ,input buf_fin-doc.con-sum-contr        ,input buf_fin-doc.con-stat             ,input buf_fin-doc.payer-sign1                ,input buf_fin-doc.payer-sign2                ,input buf_fin-doc.payer-sign3                ,input buf_fin-doc.payer-sign4                ,input buf_fin-doc.receiver-sign1                ,input buf_fin-doc.receiver-sign2                ,input buf_fin-doc.receiver-sign3                ,input buf_fin-doc.receiver-sign4                ,input buf_fin-doc.obj-type                   ,input buf_fin-doc.obj-code                   ,input buf_fin-doc.doc-author                 ,input buf_fin-doc.fact-author                ,input buf_fin-doc.CashBookId
                    ,input p-status_
                    ,input v-date
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
     if error-status:error then do:
       undo, return error substitute("&1 &2", error-status:get-message(1), return-value ).
     end.
     if not v-correct then do:
       undo, return error substitute("Ошибка при проверке корректности платежа типа &1 при переводе на статус &2: &3", buf_fin-doc.fin-doc-type, p-status_, v-err-mess).
     end.
  end.
end procedure.
procedure check-expense-cash :
  do
  on error undo, return error
  :
    if p-close-mode = '<закрытие документа>':U and buf_fin-doc.doc-date <> v-date then do:
       run err-mess (substitute("Для платежа типа &1 дата &2 должна равняться дате док", buf_fin-doc.fin-doc-type, p-status_)
                      ,output v-ret-mess).
       undo, return error (if p-silent = ? then v-ret-mess else '':U).
    end.
    if p-status_ = 'факт':U then do:
      run auto-fill-prn-doc-code in this-procedure (output v-update-counter-flag, output v-update-counter).
    end.
        run ref/findoc02.p (
                    input 'ИЗМЕНЕНИЕ':U
                    ,input p-close-mode
                    ,input buf_fin-doc.host-code            ,input buf_fin-doc.fin-doc-code         ,input buf_fin-doc.an-uchet-code        ,input buf_fin-doc.an-uchet-value       ,input buf_fin-doc.base-rate            ,input buf_fin-doc.base-scale           ,input buf_fin-doc.cel-nazn-code        ,input buf_fin-doc.cel-nazn-value       ,input buf_fin-doc.contract-code        ,input buf_fin-doc.contract-curr        ,input buf_fin-doc.contract-rate        ,input buf_fin-doc.contract-scale       ,input buf_fin-doc.cor-acc              ,input buf_fin-doc.cor-acc-value        ,input buf_fin-doc.cor-acc1             ,input buf_fin-doc.cor-acc1-value       ,input buf_fin-doc.curr-code            ,input buf_fin-doc.doc-date             ,input buf_fin-doc.shift-date           ,input buf_fin-doc.shift-num            ,input buf_fin-doc.shift-name           ,input buf_fin-doc.enclosure            ,input buf_fin-doc.exch-rate            ,input buf_fin-doc.exch-scale           ,input buf_fin-doc.f104                 ,input buf_fin-doc.f105                 ,input buf_fin-doc.f106                 ,input buf_fin-doc.f107                 ,input buf_fin-doc.f108                 ,input buf_fin-doc.f109                 ,input buf_fin-doc.f110                 ,input buf_fin-doc.f22                  ,input buf_fin-doc.f23                  ,input buf_fin-doc.fact-date            ,input buf_fin-doc.fin-doc-type         ,input buf_fin-doc.fin-ext-doc-type     ,input buf_fin-doc.in-doc-code          ,input buf_fin-doc.in-host-code         ,input buf_fin-doc.including            ,input buf_fin-doc.nazn-pl              ,input buf_fin-doc.naznach-plat         ,input buf_fin-doc.ocher-pl             ,input buf_fin-doc.out-doc-code         ,input buf_fin-doc.out-host-code        ,input buf_fin-doc.pay-date             ,input buf_fin-doc.payer-bank-name      ,input buf_fin-doc.payer-bank-city      ,input buf_fin-doc.payer-bik            ,input buf_fin-doc.payer-c-schet        ,input buf_fin-doc.payer-code           ,input buf_fin-doc.payer-code-schet     ,input buf_fin-doc.payer-dop1           ,input buf_fin-doc.payer-dop2           ,input buf_fin-doc.payer-inn            ,input buf_fin-doc.payer-kpp            ,input buf_fin-doc.payer-name           ,input buf_fin-doc.payer-okpo           ,input buf_fin-doc.payer-passport      ,input buf_fin-doc.payer-r-schet        ,input buf_fin-doc.payer-type           ,input buf_fin-doc.perm-date            ,input buf_fin-doc.prn-doc-code         ,input buf_fin-doc.PS                   ,input buf_fin-doc.receiver-bank-name   ,input buf_fin-doc.receiver-bank-city   ,input buf_fin-doc.receiver-bik         ,input buf_fin-doc.receiver-c-schet     ,input buf_fin-doc.receiver-code        ,input buf_fin-doc.receiver-code-schet  ,input buf_fin-doc.receiver-dop1        ,input buf_fin-doc.receiver-dop2        ,input buf_fin-doc.receiver-inn         ,input buf_fin-doc.receiver-kpp         ,input buf_fin-doc.receiver-name        ,input buf_fin-doc.receiver-okpo        ,input buf_fin-doc.receiver-passport    ,input buf_fin-doc.receiver-r-schet     ,input buf_fin-doc.receiver-type        ,input buf_fin-doc.srok-pl              ,input buf_fin-doc.stat-pl              ,input buf_fin-doc.str-podr-code        ,input buf_fin-doc.str-podr-type        ,input buf_fin-doc.str-podr-name        ,input buf_fin-doc.sum-base             ,input buf_fin-doc.sum-doc              ,input buf_fin-doc.sum-rubl             ,input buf_fin-doc.sum-contr            ,input buf_fin-doc.trn-doc-code         ,input buf_fin-doc.vid-opl              ,input buf_fin-doc.vid-plat
                    ,input buf_fin-doc.con-sum-rubl         ,input buf_fin-doc.con-sum-base         ,input buf_fin-doc.con-sum-doc          ,input buf_fin-doc.con-sum-contr        ,input buf_fin-doc.con-stat             ,input buf_fin-doc.payer-sign1                ,input buf_fin-doc.payer-sign2                ,input buf_fin-doc.payer-sign3                ,input buf_fin-doc.payer-sign4                ,input buf_fin-doc.receiver-sign1                ,input buf_fin-doc.receiver-sign2                ,input buf_fin-doc.receiver-sign3                ,input buf_fin-doc.receiver-sign4                ,input buf_fin-doc.obj-type                   ,input buf_fin-doc.obj-code                   ,input buf_fin-doc.doc-author                 ,input buf_fin-doc.fact-author                ,input buf_fin-doc.CashBookId
                    ,input p-status_
                    ,input v-date
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
     if error-status:error then do:
       undo, return error substitute("&1 &2", error-status:get-message(1), return-value ).
     end.
     if not v-correct then do:
       undo, return error substitute("Ошибка при проверке корректности платежа типа &1 при переводе на статус &2: &3", buf_fin-doc.fin-doc-type, p-status_, v-err-mess).
     end.
  end.
end procedure.
procedure check-income-cashless :
  do
  on error undo, return error
  :
        run ref/findoc03.p (
                    input 'ИЗМЕНЕНИЕ':U
                    ,input p-close-mode
                    ,input buf_fin-doc.host-code            ,input buf_fin-doc.fin-doc-code         ,input buf_fin-doc.an-uchet-code        ,input buf_fin-doc.an-uchet-value       ,input buf_fin-doc.base-rate            ,input buf_fin-doc.base-scale           ,input buf_fin-doc.cel-nazn-code        ,input buf_fin-doc.cel-nazn-value       ,input buf_fin-doc.contract-code        ,input buf_fin-doc.contract-curr        ,input buf_fin-doc.contract-rate        ,input buf_fin-doc.contract-scale       ,input buf_fin-doc.cor-acc              ,input buf_fin-doc.cor-acc-value        ,input buf_fin-doc.cor-acc1             ,input buf_fin-doc.cor-acc1-value       ,input buf_fin-doc.curr-code            ,input buf_fin-doc.doc-date             ,input buf_fin-doc.shift-date           ,input buf_fin-doc.shift-num            ,input buf_fin-doc.shift-name           ,input buf_fin-doc.enclosure            ,input buf_fin-doc.exch-rate            ,input buf_fin-doc.exch-scale           ,input buf_fin-doc.f104                 ,input buf_fin-doc.f105                 ,input buf_fin-doc.f106                 ,input buf_fin-doc.f107                 ,input buf_fin-doc.f108                 ,input buf_fin-doc.f109                 ,input buf_fin-doc.f110                 ,input buf_fin-doc.f22                  ,input buf_fin-doc.f23                  ,input buf_fin-doc.fact-date            ,input buf_fin-doc.fin-doc-type         ,input buf_fin-doc.fin-ext-doc-type     ,input buf_fin-doc.in-doc-code          ,input buf_fin-doc.in-host-code         ,input buf_fin-doc.including            ,input buf_fin-doc.nazn-pl              ,input buf_fin-doc.naznach-plat         ,input buf_fin-doc.ocher-pl             ,input buf_fin-doc.out-doc-code         ,input buf_fin-doc.out-host-code        ,input buf_fin-doc.pay-date             ,input buf_fin-doc.payer-bank-name      ,input buf_fin-doc.payer-bank-city      ,input buf_fin-doc.payer-bik            ,input buf_fin-doc.payer-c-schet        ,input buf_fin-doc.payer-code           ,input buf_fin-doc.payer-code-schet     ,input buf_fin-doc.payer-dop1           ,input buf_fin-doc.payer-dop2           ,input buf_fin-doc.payer-inn            ,input buf_fin-doc.payer-kpp            ,input buf_fin-doc.payer-name           ,input buf_fin-doc.payer-okpo           ,input buf_fin-doc.payer-passport      ,input buf_fin-doc.payer-r-schet        ,input buf_fin-doc.payer-type           ,input buf_fin-doc.perm-date            ,input buf_fin-doc.prn-doc-code         ,input buf_fin-doc.PS                   ,input buf_fin-doc.receiver-bank-name   ,input buf_fin-doc.receiver-bank-city   ,input buf_fin-doc.receiver-bik         ,input buf_fin-doc.receiver-c-schet     ,input buf_fin-doc.receiver-code        ,input buf_fin-doc.receiver-code-schet  ,input buf_fin-doc.receiver-dop1        ,input buf_fin-doc.receiver-dop2        ,input buf_fin-doc.receiver-inn         ,input buf_fin-doc.receiver-kpp         ,input buf_fin-doc.receiver-name        ,input buf_fin-doc.receiver-okpo        ,input buf_fin-doc.receiver-passport    ,input buf_fin-doc.receiver-r-schet     ,input buf_fin-doc.receiver-type        ,input buf_fin-doc.srok-pl              ,input buf_fin-doc.stat-pl              ,input buf_fin-doc.str-podr-code        ,input buf_fin-doc.str-podr-type        ,input buf_fin-doc.str-podr-name        ,input buf_fin-doc.sum-base             ,input buf_fin-doc.sum-doc              ,input buf_fin-doc.sum-rubl             ,input buf_fin-doc.sum-contr            ,input buf_fin-doc.trn-doc-code         ,input buf_fin-doc.vid-opl              ,input buf_fin-doc.vid-plat
                    ,input buf_fin-doc.con-sum-rubl         ,input buf_fin-doc.con-sum-base         ,input buf_fin-doc.con-sum-doc          ,input buf_fin-doc.con-sum-contr        ,input buf_fin-doc.con-stat             ,input buf_fin-doc.payer-sign1                ,input buf_fin-doc.payer-sign2                ,input buf_fin-doc.payer-sign3                ,input buf_fin-doc.payer-sign4                ,input buf_fin-doc.receiver-sign1                ,input buf_fin-doc.receiver-sign2                ,input buf_fin-doc.receiver-sign3                ,input buf_fin-doc.receiver-sign4                ,input buf_fin-doc.obj-type                   ,input buf_fin-doc.obj-code                   ,input buf_fin-doc.doc-author                 ,input buf_fin-doc.fact-author                ,input buf_fin-doc.CashBookId
                    ,input p-status_
                    ,input v-date
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
     if error-status:error then do:
       undo, return error substitute("&1 &2", error-status:get-message(1), return-value ).
     end.
     if not v-correct then do:
       undo, return error substitute("Ошибка при проверке корректности платежа типа &1 при переводе на статус &2: &3", buf_fin-doc.fin-doc-type, p-status_, v-err-mess).
     end.
  end.
end procedure.
procedure check-expense-cashless :
  do
  on error undo, return error
  :
        run ref/findoc04.p (
                    input 'ИЗМЕНЕНИЕ':U
                    ,input p-close-mode
                    ,input buf_fin-doc.host-code            ,input buf_fin-doc.fin-doc-code         ,input buf_fin-doc.an-uchet-code        ,input buf_fin-doc.an-uchet-value       ,input buf_fin-doc.base-rate            ,input buf_fin-doc.base-scale           ,input buf_fin-doc.cel-nazn-code        ,input buf_fin-doc.cel-nazn-value       ,input buf_fin-doc.contract-code        ,input buf_fin-doc.contract-curr        ,input buf_fin-doc.contract-rate        ,input buf_fin-doc.contract-scale       ,input buf_fin-doc.cor-acc              ,input buf_fin-doc.cor-acc-value        ,input buf_fin-doc.cor-acc1             ,input buf_fin-doc.cor-acc1-value       ,input buf_fin-doc.curr-code            ,input buf_fin-doc.doc-date             ,input buf_fin-doc.shift-date           ,input buf_fin-doc.shift-num            ,input buf_fin-doc.shift-name           ,input buf_fin-doc.enclosure            ,input buf_fin-doc.exch-rate            ,input buf_fin-doc.exch-scale           ,input buf_fin-doc.f104                 ,input buf_fin-doc.f105                 ,input buf_fin-doc.f106                 ,input buf_fin-doc.f107                 ,input buf_fin-doc.f108                 ,input buf_fin-doc.f109                 ,input buf_fin-doc.f110                 ,input buf_fin-doc.f22                  ,input buf_fin-doc.f23                  ,input buf_fin-doc.fact-date            ,input buf_fin-doc.fin-doc-type         ,input buf_fin-doc.fin-ext-doc-type     ,input buf_fin-doc.in-doc-code          ,input buf_fin-doc.in-host-code         ,input buf_fin-doc.including            ,input buf_fin-doc.nazn-pl              ,input buf_fin-doc.naznach-plat         ,input buf_fin-doc.ocher-pl             ,input buf_fin-doc.out-doc-code         ,input buf_fin-doc.out-host-code        ,input buf_fin-doc.pay-date             ,input buf_fin-doc.payer-bank-name      ,input buf_fin-doc.payer-bank-city      ,input buf_fin-doc.payer-bik            ,input buf_fin-doc.payer-c-schet        ,input buf_fin-doc.payer-code           ,input buf_fin-doc.payer-code-schet     ,input buf_fin-doc.payer-dop1           ,input buf_fin-doc.payer-dop2           ,input buf_fin-doc.payer-inn            ,input buf_fin-doc.payer-kpp            ,input buf_fin-doc.payer-name           ,input buf_fin-doc.payer-okpo           ,input buf_fin-doc.payer-passport      ,input buf_fin-doc.payer-r-schet        ,input buf_fin-doc.payer-type           ,input buf_fin-doc.perm-date            ,input buf_fin-doc.prn-doc-code         ,input buf_fin-doc.PS                   ,input buf_fin-doc.receiver-bank-name   ,input buf_fin-doc.receiver-bank-city   ,input buf_fin-doc.receiver-bik         ,input buf_fin-doc.receiver-c-schet     ,input buf_fin-doc.receiver-code        ,input buf_fin-doc.receiver-code-schet  ,input buf_fin-doc.receiver-dop1        ,input buf_fin-doc.receiver-dop2        ,input buf_fin-doc.receiver-inn         ,input buf_fin-doc.receiver-kpp         ,input buf_fin-doc.receiver-name        ,input buf_fin-doc.receiver-okpo        ,input buf_fin-doc.receiver-passport    ,input buf_fin-doc.receiver-r-schet     ,input buf_fin-doc.receiver-type        ,input buf_fin-doc.srok-pl              ,input buf_fin-doc.stat-pl              ,input buf_fin-doc.str-podr-code        ,input buf_fin-doc.str-podr-type        ,input buf_fin-doc.str-podr-name        ,input buf_fin-doc.sum-base             ,input buf_fin-doc.sum-doc              ,input buf_fin-doc.sum-rubl             ,input buf_fin-doc.sum-contr            ,input buf_fin-doc.trn-doc-code         ,input buf_fin-doc.vid-opl              ,input buf_fin-doc.vid-plat
                    ,input buf_fin-doc.con-sum-rubl         ,input buf_fin-doc.con-sum-base         ,input buf_fin-doc.con-sum-doc          ,input buf_fin-doc.con-sum-contr        ,input buf_fin-doc.con-stat             ,input buf_fin-doc.payer-sign1                ,input buf_fin-doc.payer-sign2                ,input buf_fin-doc.payer-sign3                ,input buf_fin-doc.payer-sign4                ,input buf_fin-doc.receiver-sign1                ,input buf_fin-doc.receiver-sign2                ,input buf_fin-doc.receiver-sign3                ,input buf_fin-doc.receiver-sign4                ,input buf_fin-doc.obj-type                   ,input buf_fin-doc.obj-code                   ,input buf_fin-doc.doc-author                 ,input buf_fin-doc.fact-author                ,input buf_fin-doc.CashBookId
                    ,input p-status_
                    ,input v-date
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
     if error-status:error then do:
       undo, return error substitute("&1 &2", error-status:get-message(1), return-value ).
     end.
     if not v-correct then do:
       undo, return error substitute("Ошибка при проверке корректности платежа типа &1 при переводе на статус &2: &3", buf_fin-doc.fin-doc-type, p-status_, v-err-mess).
     end.
  end.
end procedure.
procedure check-income-payoff :
  do
  on error undo, return error
  :
        run ref/findoc05.p (
                    input 'ИЗМЕНЕНИЕ':U
                    ,input p-close-mode
                    ,input buf_fin-doc.host-code            ,input buf_fin-doc.fin-doc-code         ,input buf_fin-doc.an-uchet-code        ,input buf_fin-doc.an-uchet-value       ,input buf_fin-doc.base-rate            ,input buf_fin-doc.base-scale           ,input buf_fin-doc.cel-nazn-code        ,input buf_fin-doc.cel-nazn-value       ,input buf_fin-doc.contract-code        ,input buf_fin-doc.contract-curr        ,input buf_fin-doc.contract-rate        ,input buf_fin-doc.contract-scale       ,input buf_fin-doc.cor-acc              ,input buf_fin-doc.cor-acc-value        ,input buf_fin-doc.cor-acc1             ,input buf_fin-doc.cor-acc1-value       ,input buf_fin-doc.curr-code            ,input buf_fin-doc.doc-date             ,input buf_fin-doc.shift-date           ,input buf_fin-doc.shift-num            ,input buf_fin-doc.shift-name           ,input buf_fin-doc.enclosure            ,input buf_fin-doc.exch-rate            ,input buf_fin-doc.exch-scale           ,input buf_fin-doc.f104                 ,input buf_fin-doc.f105                 ,input buf_fin-doc.f106                 ,input buf_fin-doc.f107                 ,input buf_fin-doc.f108                 ,input buf_fin-doc.f109                 ,input buf_fin-doc.f110                 ,input buf_fin-doc.f22                  ,input buf_fin-doc.f23                  ,input buf_fin-doc.fact-date            ,input buf_fin-doc.fin-doc-type         ,input buf_fin-doc.fin-ext-doc-type     ,input buf_fin-doc.in-doc-code          ,input buf_fin-doc.in-host-code         ,input buf_fin-doc.including            ,input buf_fin-doc.nazn-pl              ,input buf_fin-doc.naznach-plat         ,input buf_fin-doc.ocher-pl             ,input buf_fin-doc.out-doc-code         ,input buf_fin-doc.out-host-code        ,input buf_fin-doc.pay-date             ,input buf_fin-doc.payer-bank-name      ,input buf_fin-doc.payer-bank-city      ,input buf_fin-doc.payer-bik            ,input buf_fin-doc.payer-c-schet        ,input buf_fin-doc.payer-code           ,input buf_fin-doc.payer-code-schet     ,input buf_fin-doc.payer-dop1           ,input buf_fin-doc.payer-dop2           ,input buf_fin-doc.payer-inn            ,input buf_fin-doc.payer-kpp            ,input buf_fin-doc.payer-name           ,input buf_fin-doc.payer-okpo           ,input buf_fin-doc.payer-passport      ,input buf_fin-doc.payer-r-schet        ,input buf_fin-doc.payer-type           ,input buf_fin-doc.perm-date            ,input buf_fin-doc.prn-doc-code         ,input buf_fin-doc.PS                   ,input buf_fin-doc.receiver-bank-name   ,input buf_fin-doc.receiver-bank-city   ,input buf_fin-doc.receiver-bik         ,input buf_fin-doc.receiver-c-schet     ,input buf_fin-doc.receiver-code        ,input buf_fin-doc.receiver-code-schet  ,input buf_fin-doc.receiver-dop1        ,input buf_fin-doc.receiver-dop2        ,input buf_fin-doc.receiver-inn         ,input buf_fin-doc.receiver-kpp         ,input buf_fin-doc.receiver-name        ,input buf_fin-doc.receiver-okpo        ,input buf_fin-doc.receiver-passport    ,input buf_fin-doc.receiver-r-schet     ,input buf_fin-doc.receiver-type        ,input buf_fin-doc.srok-pl              ,input buf_fin-doc.stat-pl              ,input buf_fin-doc.str-podr-code        ,input buf_fin-doc.str-podr-type        ,input buf_fin-doc.str-podr-name        ,input buf_fin-doc.sum-base             ,input buf_fin-doc.sum-doc              ,input buf_fin-doc.sum-rubl             ,input buf_fin-doc.sum-contr            ,input buf_fin-doc.trn-doc-code         ,input buf_fin-doc.vid-opl              ,input buf_fin-doc.vid-plat
                    ,input buf_fin-doc.con-sum-rubl         ,input buf_fin-doc.con-sum-base         ,input buf_fin-doc.con-sum-doc          ,input buf_fin-doc.con-sum-contr        ,input buf_fin-doc.con-stat             ,input buf_fin-doc.payer-sign1                ,input buf_fin-doc.payer-sign2                ,input buf_fin-doc.payer-sign3                ,input buf_fin-doc.payer-sign4                ,input buf_fin-doc.receiver-sign1                ,input buf_fin-doc.receiver-sign2                ,input buf_fin-doc.receiver-sign3                ,input buf_fin-doc.receiver-sign4                ,input buf_fin-doc.obj-type                   ,input buf_fin-doc.obj-code                   ,input buf_fin-doc.doc-author                 ,input buf_fin-doc.fact-author                ,input buf_fin-doc.CashBookId
                    ,input p-status_
                    ,input v-date
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
     if error-status:error then do:
       undo, return error substitute("&1 &2", error-status:get-message(1), return-value ).
     end.
     if not v-correct then do:
       undo, return error substitute("Ошибка при проверке корректности платежа типа &1 при переводе на статус &2: &3", buf_fin-doc.fin-doc-type, p-status_, v-err-mess).
     end.
  end.
end procedure.
procedure check-expense-payoff :
  do
  on error undo, return error
  :
        run ref/findoc06.p (
                    input 'ИЗМЕНЕНИЕ':U
                    ,input p-close-mode
                    ,input buf_fin-doc.host-code            ,input buf_fin-doc.fin-doc-code         ,input buf_fin-doc.an-uchet-code        ,input buf_fin-doc.an-uchet-value       ,input buf_fin-doc.base-rate            ,input buf_fin-doc.base-scale           ,input buf_fin-doc.cel-nazn-code        ,input buf_fin-doc.cel-nazn-value       ,input buf_fin-doc.contract-code        ,input buf_fin-doc.contract-curr        ,input buf_fin-doc.contract-rate        ,input buf_fin-doc.contract-scale       ,input buf_fin-doc.cor-acc              ,input buf_fin-doc.cor-acc-value        ,input buf_fin-doc.cor-acc1             ,input buf_fin-doc.cor-acc1-value       ,input buf_fin-doc.curr-code            ,input buf_fin-doc.doc-date             ,input buf_fin-doc.shift-date           ,input buf_fin-doc.shift-num            ,input buf_fin-doc.shift-name           ,input buf_fin-doc.enclosure            ,input buf_fin-doc.exch-rate            ,input buf_fin-doc.exch-scale           ,input buf_fin-doc.f104                 ,input buf_fin-doc.f105                 ,input buf_fin-doc.f106                 ,input buf_fin-doc.f107                 ,input buf_fin-doc.f108                 ,input buf_fin-doc.f109                 ,input buf_fin-doc.f110                 ,input buf_fin-doc.f22                  ,input buf_fin-doc.f23                  ,input buf_fin-doc.fact-date            ,input buf_fin-doc.fin-doc-type         ,input buf_fin-doc.fin-ext-doc-type     ,input buf_fin-doc.in-doc-code          ,input buf_fin-doc.in-host-code         ,input buf_fin-doc.including            ,input buf_fin-doc.nazn-pl              ,input buf_fin-doc.naznach-plat         ,input buf_fin-doc.ocher-pl             ,input buf_fin-doc.out-doc-code         ,input buf_fin-doc.out-host-code        ,input buf_fin-doc.pay-date             ,input buf_fin-doc.payer-bank-name      ,input buf_fin-doc.payer-bank-city      ,input buf_fin-doc.payer-bik            ,input buf_fin-doc.payer-c-schet        ,input buf_fin-doc.payer-code           ,input buf_fin-doc.payer-code-schet     ,input buf_fin-doc.payer-dop1           ,input buf_fin-doc.payer-dop2           ,input buf_fin-doc.payer-inn            ,input buf_fin-doc.payer-kpp            ,input buf_fin-doc.payer-name           ,input buf_fin-doc.payer-okpo           ,input buf_fin-doc.payer-passport      ,input buf_fin-doc.payer-r-schet        ,input buf_fin-doc.payer-type           ,input buf_fin-doc.perm-date            ,input buf_fin-doc.prn-doc-code         ,input buf_fin-doc.PS                   ,input buf_fin-doc.receiver-bank-name   ,input buf_fin-doc.receiver-bank-city   ,input buf_fin-doc.receiver-bik         ,input buf_fin-doc.receiver-c-schet     ,input buf_fin-doc.receiver-code        ,input buf_fin-doc.receiver-code-schet  ,input buf_fin-doc.receiver-dop1        ,input buf_fin-doc.receiver-dop2        ,input buf_fin-doc.receiver-inn         ,input buf_fin-doc.receiver-kpp         ,input buf_fin-doc.receiver-name        ,input buf_fin-doc.receiver-okpo        ,input buf_fin-doc.receiver-passport    ,input buf_fin-doc.receiver-r-schet     ,input buf_fin-doc.receiver-type        ,input buf_fin-doc.srok-pl              ,input buf_fin-doc.stat-pl              ,input buf_fin-doc.str-podr-code        ,input buf_fin-doc.str-podr-type        ,input buf_fin-doc.str-podr-name        ,input buf_fin-doc.sum-base             ,input buf_fin-doc.sum-doc              ,input buf_fin-doc.sum-rubl             ,input buf_fin-doc.sum-contr            ,input buf_fin-doc.trn-doc-code         ,input buf_fin-doc.vid-opl              ,input buf_fin-doc.vid-plat
                    ,input buf_fin-doc.con-sum-rubl         ,input buf_fin-doc.con-sum-base         ,input buf_fin-doc.con-sum-doc          ,input buf_fin-doc.con-sum-contr        ,input buf_fin-doc.con-stat             ,input buf_fin-doc.payer-sign1                ,input buf_fin-doc.payer-sign2                ,input buf_fin-doc.payer-sign3                ,input buf_fin-doc.payer-sign4                ,input buf_fin-doc.receiver-sign1                ,input buf_fin-doc.receiver-sign2                ,input buf_fin-doc.receiver-sign3                ,input buf_fin-doc.receiver-sign4                ,input buf_fin-doc.obj-type                   ,input buf_fin-doc.obj-code                   ,input buf_fin-doc.doc-author                 ,input buf_fin-doc.fact-author                ,input buf_fin-doc.CashBookId
                    ,input p-status_
                    ,input v-date
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
     if error-status:error then do:
       undo, return error substitute("&1 &2", error-status:get-message(1), return-value ).
     end.
     if not v-correct then do:
       undo, return error substitute("Ошибка при проверке корректности платежа типа &1 при переводе на статус &2: &3", buf_fin-doc.fin-doc-type, p-status_, v-err-mess).
     end.
  end.
end procedure.
PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  define output parameter p-ret-mess as character no-undo .
  CASE p-silent:
    when yes then do:
      if available buf_fin-doc then
      assign
      p-ret-mess =  substitute("ПЛАТЕЖ &1: фирма: &2 N: &3,&5вн.код платежа &4 Статус &5&6&7"
                                , buf_fin-doc.prn-doc-code
                                , buf_fin-doc.host-code
                                , buf_fin-doc.fin-doc-type
                                , buf_fin-doc.fin-doc-code
                                , buf_fin-doc.status_
                                , chr(10)
                                , p-mess
                                ).
      else
      assign
      p-ret-mess =  substitute("ПЛАТЕЖ &1: фирма: &2 N: &3,&5вн.код платежа &4&5&6"
                                , v-prn-doc-code
                                , p-host-code
                                , v-fin-doc-type
                                , p-fin-doc-code
                                , chr(10)
                                , p-mess
                                ).
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
procedure auto-fill-prn-doc-code :
define output parameter p-update-counter-flag as logical no-undo .
define output parameter p-update-counter as integer no-undo .
define variable glog as logical no-undo .
define variable choice as integer no-undo .
define variable v-sl as integer no-undo .
define variable v-pl as integer no-undo .
define variable v-loc-update-counter-flag as logical no-undo .
define variable v-my-counter as integer no-undo .
define variable v-obj-db-num as integer   no-undo .
define variable mCashBook as class ibs.th.ref.cashbookstorage no-undo .
if buf_fin-doc.trn-doc-code <> ''
and not (buf_fin-doc.obj-type = ''
          and
          buf_fin-doc.obj-code = 0)
then do:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_fin-doc.obj-type
  ,input  buf_fin-doc.obj-code
  ,output v-obj-db-num
  )  .
  if    v-obj-db-num <> g#db-num
     or (buf_fin-doc.prn-doc-code <> "" and buf_fin-doc.prn-doc-code <> ? and buf_fin-doc.prn-doc-code <> "тех_")
  then do:
    return.
  end .
  mCashBook = new ibs.th.ref.cashbookstorage () .
  mask-pko = mCashBook:getSinglRule(buf_fin-doc.CashBookId, buf_fin-doc.obj-type, buf_fin-doc.obj-code, "PkoMask") .
  mask-rko = mCashBook:getSinglRule(buf_fin-doc.CashBookId, buf_fin-doc.obj-type, buf_fin-doc.obj-code, "RkoMask") .
  if mask-pko > ""
  then.
  else mask-pko = "[NNNN]/[obj-code]" .
  if mask-rko > ""
  then.
  else mask-rko = "[NNNN]/[obj-code]" .
  MParam = if mCashBook:getSinglRule(buf_fin-doc.cashbookId, buf_fin-doc.obj-type,buf_fin-doc.obj-code, "uchet") eq "1"
           then "year," + string(year(buf_fin-doc.shift-date))
           else "".
  delete object mCashBook no-error .
  subscribe   to "getCounter" anywhere run-procedure "Mycounter".
  case buf_fin-doc.fin-ext-doc-type:
    when 'пко':U then do:
      find first ub.CashBookRule exclusive-lock where ub.CashBookRule.CashBookID = buf_fin-doc.CashBookId
                                           and ub.CashBookRule.Obj-type = buf_fin-doc.obj-type
                                           and ub.CashBookRule.Obj-code = buf_fin-doc.obj-code
                                           and ub.CashBookRule.Code = "currPko"
                                           no-error .
      if not available ub.CashBookRule
      then do :
        create ub.CashBookRule .
        assign
          ub.CashBookRule.CashBookID = buf_fin-doc.CashBookId
          ub.CashBookRule.Obj-type = buf_fin-doc.obj-type
          ub.CashBookRule.Obj-code = buf_fin-doc.obj-code
          ub.CashBookRule.Code = "currPko"
          ub.CashBookRule.Status_ = 0
          ub.CashBookRule.RuleValue = "1"
        .
      end.
      run gen-key-rec in this-procedure ( input 'CashBookRule':U
                                         ,input (buffer CashBookRule:handle)
                                         ,output v-key).
      assign
        current-pko-rko = "currPKO"
        current-ruleID = v-key
      .
      run utl/maskproc.p(parparentproc, mask-pko, "cashbook", buf_fin-doc.CashBookId, output mValue).
    end.
    when 'рко':U then do:
      find first ub.CashBookRule exclusive-lock where ub.CashBookRule.CashBookID = buf_fin-doc.CashBookId
                                           and ub.CashBookRule.Obj-type = buf_fin-doc.obj-type
                                           and ub.CashBookRule.Obj-code = buf_fin-doc.obj-code
                                           and ub.CashBookRule.Code = "currRko"
                                           no-error .
      if not available ub.CashBookRule
      then do :
        create ub.CashBookRule .
        assign
          ub.CashBookRule.CashBookID = buf_fin-doc.CashBookId
          ub.CashBookRule.Obj-type = buf_fin-doc.obj-type
          ub.CashBookRule.Obj-code = buf_fin-doc.obj-code
          ub.CashBookRule.Code = "currRko"
          ub.CashBookRule.Status_ = 0
          ub.CashBookRule.RuleValue = "1"
        .
      end.
      run gen-key-rec in this-procedure ( input 'CashBookRule':U
                                         ,input (buffer CashBookRule:handle)
                                         ,output v-key).
      assign
        current-pko-rko = "currRKO"
        current-ruleID = v-key
      .
      run utl/maskproc.p(parparentproc, mask-rko, "cashbook", buf_fin-doc.CashBookId, output mValue).
    end.
  end case.
  unsubscribe to "getCounter".
  v-prn-doc-code = v-prn-doc-code + mValue.
  if buf_fin-doc.doc-author = 'auto':U then do:
    assign
    buf_fin-doc.prn-doc-code = v-prn-doc-code.
    p-update-counter-flag = yes.
  end.
end.
end procedure.
procedure release-auto-fill-prn-doc-code :
define input parameter p-update as logical no-undo .
define input parameter p-counter as integer no-undo .
end procedure.
procedure fill-shift :
define parameter buffer buf_fin-doc for ub.fin-doc.
define variable v-obj-db-num as integer no-undo .
define variable l-shift-on as logical no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_fin-doc.obj-type
  ,input  buf_fin-doc.obj-code
  ,output v-obj-db-num
  )  .
  if v-obj-db-num = g#db-num then do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  buf_fin-doc.obj-type
  ,input  buf_fin-doc.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
    if l-shift-on
    and buf_fin-doc.shift-flag = integer('1':U)
    then do:
      if buf_fin-doc.shift-date = ?
      or buf_fin-doc.shift-num = 0
      or buf_fin-doc.shift-name = ''
      then do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  buf_fin-doc.obj-type
  ,input  buf_fin-doc.obj-code
  ,output varobj-shift-date
  ,output varobj-shift-num
  ,output varobj-shift-name
  )  .
        run gbl/chk-date.p
        ( input buf_fin-doc.obj-type
        , input buf_fin-doc.obj-code
        , input buf_fin-doc.fact-date
        , input v-time
        , input varobj-shift-date
        , input varobj-shift-num
        , input no) no-error.
        if error-status:error then do:
          undo main-block, return error substitute( "Ошибка при проверке сменной даты&1&2&1&3"
                                            ,chr(10), error-status :get-message (1), return-value  )   .
        end.
        assign
        buf_fin-doc.shift-date = varobj-shift-date
        buf_fin-doc.shift-num = varobj-shift-num
        buf_fin-doc.shift-name = varobj-shift-name
        .
      end.
    end.
    else do:
      l-shift-on = no.
    end.
  end.
end.
end procedure.
procedure get-fact-num :
define input parameter p-host-code as integer no-undo .
define output parameter p-fact-num as integer no-undo .
define buffer buf_sysconf for ub.sysconf.
find first buf_sysconf no-lock where
          buf_sysconf.host-code = p-host-code.
do while true:
  p-fact-num =  next-value(s-fin-doc-fact , ub).
  if g#db-num = buf_sysconf.firm-db-num
  and p-fact-num modulo 10 > 0 then do:
    leave.
  end.
  if g#db-num <> buf_sysconf.firm-db-num
  and p-fact-num modulo 10 = 0 then do:
    leave.
  end.
end.
end procedure.
procedure Mycounter:
define input  parameter iFileName as character no-undo.
define input  parameter ikey      as character no-undo.
define input  parameter icode     as character no-undo.
define output parameter oCount    as int64 no-undo.
run utl/getnextcount.p ("cashbookrule", current-ruleID, current-pko-rko, mparam  ,output oCount    ).
end procedure.
