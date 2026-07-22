block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.shift-obj old buffer oldb.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись смены".
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
      p-vss-parameters = substitute('&1|&2|&3|&4|&5':u,ub.shift-obj.obj-type,ub.shift-obj.obj-code,ub.shift-obj.shift-date,ub.shift-obj.shift-num,ub.shift-obj.status_)
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gds-attr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
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
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
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
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
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
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable v-today          as date      no-undo.
define variable v-time           as integer   no-undo.
define variable v-obj-date       as date      no-undo.
define variable v-sys-time       as integer   no-undo.
define variable v-sys-date       as date      no-undo.
define variable v-max-shift-days as integer   no-undo.
define variable v-par-type       as character no-undo.
define variable v-host-code      like ub.shop.host-code no-undo.
define buffer prev-shift      for ub.shift-obj.
define buffer buf_shift-obj   for ub.shift-obj.
define buffer buf_c-shift-obj for ub.c-shift-obj.
define buffer buf_c-sht-hist  for ub.c-sht-hist.
define variable l-shift-on         as logical   no-undo .
define variable lok                as logical   no-undo .
define variable v-avail-petrol     as logical   no-undo .
define variable v-is-petrol        as logical   no-undo .
define variable v-is-pieces        as logical   no-undo .
define variable v-ptrl-without-rvs as character no-undo .
define variable v-attr-type        as character no-undo .
define variable v-edit-time        as logical   no-undo .
define variable v-vid-action       as integer   no-undo .
define variable v-vid-ok           as logical   no-undo .
define variable v-vid-mes          as character no-undo .
define variable v-vid-param        as longchar  no-undo .
define variable v-shift-staff-list as character no-undo .
define variable v-shift-manager    as character no-undo .
define buffer buf_inkas    for ub.inkas .
define buffer buf_pl-gds   for ub.pl-gds .
define buffer buf_goods    for ub.goods .
define buffer buf_rvs-doc  for ub.rvs-doc .
define buffer buf_rvs-line for ub.rvs-line .
define variable v-fact-status-list as character no-undo .
define variable ii                 as integer   no-undo .
main-block:
do
    on error undo, return error return-value
    :
    v-fact-status-list = (if 'факт':U < 'запрос':U
        then ('факт':U + chr(44) + 'запрос':U)
        else ('запрос':U + chr(44) + 'факт':U)).
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  ub.shift-obj.obj-type
  ,input  ub.shift-obj.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) no-error .
    if error-status :error then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при запуске процедуры objat" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        undo main-block, return error .
    end.
    if l-shift-on <> yes then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "На объекте выключены смены" skip
            "Работа со сменами невозможна" skip
            "Объект" ub.shift-obj.obj-type ub.shift-obj.obj-code skip
            view-as alert-box error .
        undo main-block, return error .
    end.
    if lookup (ub.shift-obj.status_, 'ожд,тек,зкр,отм':U) = 0
        then
    do:
        message
            "Смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
            "Недопустимый статус смены" ub.shift-obj.status_ skip
            "Невозможно выполнить операцию со сменой" skip
            view-as alert-box error .
        undo main-block, return error .
    end.
    if not new( ub.shift-obj )
        and ( ub.shift-obj.obj-type     <> oldb.obj-type
        or ub.shift-obj.obj-code   <> oldb.obj-code
        or ub.shift-obj.shift-date <> oldb.shift-date
        or ub.shift-obj.shift-num  <> oldb.shift-num
        )
        then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Нельзя менять уникальные параметры смены" skip
            "Объект:" ub.shift-obj.obj-type ub.shift-obj.obj-code skip
            "Смена:" ub.shift-obj.shift-date skip
            "Порядок:" ub.shift-obj.shift-num skip
            view-as alert-box error .
        undo main-block, return error .
    end.
    if not new( ub.shift-obj )
        and ub.shift-obj.shift-name <> oldb.shift-name
        then
    do:
        find first buf_shift-obj no-lock
            where buf_shift-obj.obj-type   = ub.shift-obj.obj-type
            and buf_shift-obj.obj-code   = ub.shift-obj.obj-code
            and buf_shift-obj.shift-date = ub.shift-obj.shift-date
            and buf_shift-obj.shift-name = ub.shift-obj.shift-name
            and rowid( buf_shift-obj )   <> rowid( ub.shift-obj )
            no-error .
        if available buf_shift-obj then
        do:
            message
                vss-workfile vss-revision vss-description skip(1)
                "Уже существует смена с номером:" ub.shift-obj.shift-name
                "Дата:" string( ub.shift-obj.shift-date, "99/99/9999" ) skip
                "Объект:" ub.shift-obj.obj-type ub.shift-obj.obj-code skip
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.
    if ub.shift-obj.shift-date = ?
        or ub.shift-obj.shift-num  = ?
        or ub.shift-obj.shift-name = ?
        then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Заданы не все основные параметры смены" skip
            "Объект:" ub.shift-obj.obj-type ub.shift-obj.obj-code skip
            "Смена:" ub.shift-obj.shift-date skip
            "Номер:" ub.shift-obj.shift-name skip
            "Порядок:" ub.shift-obj.shift-num skip
            "Статус:" ub.shift-obj.status_ skip
            view-as alert-box error .
        undo main-block, return error .
    end.
    if not g#news and ub.shift-obj.status_ = 'зкр':U and oldb.status_ = 'зкр':U then
    do:
        run gbl/sht-time-check.p(
            ub.shift-obj.shift-date,
            ub.shift-obj.shift-num,
            ub.shift-obj.obj-type,
            ub.shift-obj.obj-code,
            ub.shift-obj.open-time,
            ub.shift-obj.close-time,
            ub.shift-obj.open-date,
            ub.shift-obj.close-date
            ) no-error.
        if error-status:error then
            return error return-value.
        v-edit-time = true.
    end.
    if ub.shift-obj.status_ = 'ожд':U then
    do:
        find last prev-shift
            where prev-shift.obj-type = ub.shift-obj.obj-type
            and prev-shift.obj-code = ub.shift-obj.obj-code
            and prev-shift.status_ = 'тек':U
            no-error .
        if  available prev-shift
            and ( prev-shift.shift-date > ub.shift-obj.shift-date
            or ( prev-shift.shift-date = ub.shift-obj.shift-date
            and prev-shift.shift-num  > ub.shift-obj.shift-num ) )
            then
        do:
            message
                "Была найдена смена со статусом" prev-shift.status_ skip
                "Любая текущая или закрытая смена должна дату или номер больший чем у ожидаемой смены" skip
                "Ожидаемая смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                "Найдена смена" prev-shift.shift-date "Номер" prev-shift.shift-num skip
                view-as alert-box error .
            undo main-block, return error .
        end.
        find last prev-shift where
            prev-shift.obj-type = ub.shift-obj.obj-type and
            prev-shift.obj-code = ub.shift-obj.obj-code and
            prev-shift.status_ = 'зкр':U
            use-index pi no-error.
        if available prev-shift
            and ( prev-shift.shift-date > ub.shift-obj.shift-date
            or ( prev-shift.shift-date = ub.shift-obj.shift-date
            and prev-shift.shift-num  > ub.shift-obj.shift-num ) )
            then
        do:
            message
                "Найдена смена со статусом" prev-shift.status_ skip
                "Любая текущая или закрытая смена должна иметь дату или номер больший чем у ожидаемой смены" skip
                "Одидаемая смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num  skip
                "Найдена смена" prev-shift.shift-date "Номер" prev-shift.shift-name "Порядок" prev-shift.shift-num
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  ub.shift-obj.obj-type
  ,input  ub.shift-obj.obj-code
  ,output v-obj-date
  )  .
    if not g#news and not v-edit-time then
    do:
        run cur-time in this-procedure ( output v-sys-date
            , output v-sys-time
            ).
        if oldb.status_ = ub.shift-obj.status_ then
        do:
            if  oldb.shift-date = ub.shift-obj.shift-date
                and oldb.shift-num  = ub.shift-obj.shift-num
                and ( oldb.status_ <> 'ожд':U
                or oldb.open-time <> ub.shift-obj.open-time )
                then
            do:
                undo main-block, return error "Любое изменение смены без изменения статуса должно затрагивать дату, номер или время смены." .
            end.
            else
            do:
                if ub.shift-obj.status_ <> 'ожд':U then
                do:
                    message
                        "Дату или номер смены можно менять только для ожидаемой смены" skip
                        "Дата смены" oldb.shift-date skip
                        "Номер" oldb.shift-name skip
                        "Порядок" oldb.shift-num
                        view-as alert-box error .
                    undo main-block, return error .
                end.
            end.
        end.
        else
        do:
            define variable v-valid-status-change as character no-undo .
            assign
                v-valid-status-change = (''              + '-' + 'ожд':U)
          + "," + (''              + '-' + 'тек':U )
          + "," + ('ожд':U + '-' + 'тек':U )
          + "," + ('тек':U  + '-' + 'зкр':U  )
          + "," + ('ожд':U + '-' + 'отм':U)
          + "," + ('тек':U  + '-' + 'ожд':U)
          + "," + ('зкр':U   + '-' + 'тек':U )
                .
            if lookup( (oldb.status_ + '-' + ub.shift-obj.status_), v-valid-status-change) > 0
                then
            do:
            end.
            else
            do:
                message
                    "Смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                    "Недопустимая замена статуса" oldb.status_ "->" ub.shift-obj.status_ skip
                    "Невозможно выполнить операцию со сменой" skip
                    view-as alert-box error .
                undo main-block, return error .
            end.
            if  ub.shift-obj.status_ = 'тек':U
                and (oldb.status_        = 'ожд':U
                or oldb.status_        = ""
                )
                then
            do:
                if ub.shift-obj.shift-num < 1
                    or ub.shift-obj.shift-num > 24
                    then
                do:
                    message
                        "Неправильный номер смены" skip
                        "Невозможно открыть новую смену" skip
                        "Текущая смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                if ub.shift-obj.shift-date <> v-obj-date then
                do:
                    message
                        "Неправильная дата начала смены" skip
                        "Смену можно открыть только сегодняшним днем" skip
                        "Невозможно открыть новую смену" skip
                        "Текущая смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                find first prev-shift
                    where prev-shift.obj-type = ub.shift-obj.obj-type
                    and prev-shift.obj-code = ub.shift-obj.obj-code
                    and prev-shift.status_ = 'тек':U
                    and recid (prev-shift) <> recid (ub.shift-obj)
                    no-error .
                if available prev-shift then
                do:
                    message
                        "Не закрыта текущая смена" skip
                        "Невозможно открыть новую смену" skip
                        "Текущая смена" prev-shift.shift-date "Номер" prev-shift.shift-name "Порядок" prev-shift.shift-num skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                find first buf_rvs-doc
                    where buf_rvs-doc.obj-type = ub.shift-obj.obj-type
                    and buf_rvs-doc.obj-code = ub.shift-obj.obj-code
                    and buf_rvs-doc.rvs-type <> 'проверка':U
                    and buf_rvs-doc.status_  <> 'факт':U
                    no-error .
                if available buf_rvs-doc then
                do:
                    message
                        "Найдена незакрытая сверка" skip
                        "Невозможно открыть новую смену" skip
                        "Сверка" buf_rvs-doc.rvs-code skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                do ii = 0 to num-entries(v-fact-status-list):
                    CASE ii:
                        when 0 then
                            do:
                                find first buf_inkas no-lock
                                    where buf_inkas.obj-type = ub.shift-obj.obj-type
                                    and buf_inkas.obj-code = ub.shift-obj.obj-code
                                    and buf_inkas.status_ < entry(1, v-fact-status-list) no-error .
                            end.
                        when num-entries(v-fact-status-list) then
                            do:
                                find first buf_inkas no-lock
                                    where buf_inkas.obj-type = ub.shift-obj.obj-type
                                    and buf_inkas.obj-code = ub.shift-obj.obj-code
                                    and buf_inkas.status_ > entry(num-entries(v-fact-status-list), v-fact-status-list) no-error .
                            end.
                        otherwise
                        do:
                            find first buf_inkas no-lock
                                where buf_inkas.obj-type = ub.shift-obj.obj-type
                                and buf_inkas.obj-code = ub.shift-obj.obj-code
                                and buf_inkas.status_ > entry(ii, v-fact-status-list)
                                and buf_inkas.status_ < entry(ii + 1, v-fact-status-list)
                                no-error .
                        end.
                    END CASE.
                    if available buf_inkas then
                    do:
                        message
                            "Найдена незакрытая продажа" skip
                            "Невозможно открыть новую смену" skip
                            "Продажа" buf_inkas.inkas-code skip
                            view-as alert-box error .
                        undo main-block, return error.
                    end.
                end.
                find last prev-shift
                    where prev-shift.obj-type = ub.shift-obj.obj-type
                    and prev-shift.obj-code = ub.shift-obj.obj-code
                    and prev-shift.status_ = 'зкр':U
                    use-index pi
                    no-error .
                if available prev-shift then
                do:
                    if  ub.shift-obj.shift-date > prev-shift.shift-date
                        or  ( ub.shift-obj.shift-date = prev-shift.shift-date
                        and ub.shift-obj.shift-num  > prev-shift.shift-num
                        )
                        then
                    do:
                        .
                    end.
                    else
                    do:
                        message
                            "Найдена смена со статусом" 'зкр':U skip
                            "Найденная смена" prev-shift.shift-date "Номер" prev-shift.shift-name "Порядок" prev-shift.shift-num skip
                            "Новая смена должна по времени идти после закрытой" skip
                            "Невозможно открыть новую смену" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                            view-as alert-box error .
                        undo main-block, return error .
                    end.
                    if prev-shift.close-date < v-obj-date
                        or ( prev-shift.close-date = v-obj-date
                        and prev-shift.close-time < shift-obj.open-time    ) then
                    do:
                    end.
                    else
                    do:
                        message
                            "Найдена смена со статусом" 'зкр':U skip
                            "Найденная смена" prev-shift.shift-date "Номер" prev-shift.shift-name "Порядок" prev-shift.shift-num skip
                            "Закрыта" prev-shift.close-date string (prev-shift.close-time, "HH:MM") skip
                            "Сейчас" v-obj-date string (ub.shift-obj.open-time, "HH:MM") skip
                            "Новая смена должна быть открыта после закрытия предыдущей" skip
                            "Невозможно открыть новую смену" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                            view-as alert-box error .
                        undo main-block, return error .
                    end.
                end.
                find first prev-shift where
                    prev-shift.obj-type = ub.shift-obj.obj-type and
                    prev-shift.obj-code = ub.shift-obj.obj-code and
                    prev-shift.status_ = 'ожд':U
                    use-index pi no-error.
                if available prev-shift then
                do:
                    if oldb.status_ = 'ожд':U then
                    do:
                        if (prev-shift.shift-date < ub.shift-obj.shift-date or
                            prev-shift.shift-date = ub.shift-obj.shift-date and
                            prev-shift.shift-num < ub.shift-obj.shift-num) then
                        do:
                            message
                                "Найдена более ранняя смена со статусом" 'ожд':U skip
                                "Найденная смена" prev-shift.shift-date "Номер" prev-shift.shift-name "Порядок" prev-shift.shift-num skip
                                "Новую смену можно открыть только из нее" skip
                                "Невозможно открыть новую смену" skip
                                view-as alert-box error .
                            undo main-block, return error .
                        end.
                    end.
                    else
                    do:
                        message
                            "Найдена смена со статусом" 'ожд':U skip
                            "Найденная смена" prev-shift.shift-date "Номер" prev-shift.shift-name "Порядок" prev-shift.shift-num skip
                            "Новую смену можно открыть, только изменив статус на" 'тек':U skip
                            "Невозможно открыть новую смену" skip
                            view-as alert-box error .
                        undo main-block, return error .
                    end.
                end.
                if ub.shift-obj.shift-date <> v-obj-date then
                do:
                    message
                        "Открываемая смена" ub.shift-obj.shift-date ub.shift-obj.shift-name ub.shift-obj.shift-num skip
                        "Новая смена должна открываться сегодняшним числом" skip
                        "Невозможно открыть новую смену"
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                assign
                    ub.shift-obj.open-id   = g#userid
                    ub.shift-obj.open-date = v-obj-date
                    .
                v-vid-action = 51 .
                v-vid-param = "SHOP_NUM=" + string(ub.shift-obj.obj-code) + chr(4) +
                    "SHIFT_NUM=" + string(ub.shift-obj.shift-num) + string(ub.shift-obj.shift-date, "99999999") + chr(4) +
                    "RESULT=0" + chr(4) +
                    "Description=".
            end.
            if ub.shift-obj.status_ = 'зкр':U then
            do:
                if ub.shift-obj.open-date < v-obj-date
                    or (ub.shift-obj.open-date = v-obj-date
                    and ub.shift-obj.open-time < ub.shift-obj.close-time
                    )
                    then
                do:
                end.
                else
                do:
                    message
                        "Время и дата открытия должны быть раньше закрытия" skip
                        "Открыта" ub.shift-obj.open-date string (ub.shift-obj.open-time, "HH:MM") skip
                        "Сейчас" v-obj-date string (ub.shift-obj.close-time, "HH:MM") skip
                        "Невозможно закрыть смену N" ub.shift-obj.shift-name "порядок" ub.shift-obj.shift-num "от" ub.shift-obj.shift-date skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                find first prev-shift
                    where prev-shift.obj-type = ub.shift-obj.obj-type
                    and prev-shift.obj-code = ub.shift-obj.obj-code
                    and prev-shift.status_ = 'тек':U
                    and recid (prev-shift) <> recid (ub.shift-obj)
                    no-error .
                if available prev-shift then
                do:
                    message
                        "Найдена другая открытая смена" skip
                        "Невозможно закрыть текущую смену" skip
                        "Найденная смена" prev-shift.shift-date "Номер" prev-shift.shift-name "Порядок" prev-shift.shift-num skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                find first buf_rvs-doc
                    where buf_rvs-doc.obj-type = ub.shift-obj.obj-type
                    and buf_rvs-doc.obj-code = ub.shift-obj.obj-code
                    and buf_rvs-doc.rvs-type <> 'проверка':U
                    and buf_rvs-doc.status_  <> 'факт':U
                    no-error .
                if available buf_rvs-doc then
                do:
                    message
                        "Найдена незакрытая сверка" skip
                        "Невозможно закрыть текущую смену" skip
                        "Сверка" buf_rvs-doc.rvs-code
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                assign
                    v-avail-petrol = false
                    .
                _block_chk-ptrl:
                for each buf_pl-gds
                    where buf_pl-gds.obj-type = ub.shift-obj.obj-type
                    and buf_pl-gds.obj-code = ub.shift-obj.obj-code
                    on error undo main-block, return error
                    :
                    find first buf_goods no-lock
                        where buf_goods.gds-code = buf_pl-gds.gds-code
                        .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output v-is-petrol
  , output v-is-pieces
  ) no-error.
                    if v-is-petrol = true
                        and v-is-pieces = false
                        then
                    do:
                        assign
                            v-avail-petrol = true
                            .
                        leave _block_chk-ptrl.
                    end.
                end.
                if v-avail-petrol = true then
                do:
                    find  buf_rvs-doc
                        where buf_rvs-doc.obj-type   = ub.shift-obj.obj-type
                        and buf_rvs-doc.obj-code   = ub.shift-obj.obj-code
                        and buf_rvs-doc.shift-date = ub.shift-obj.shift-date
                        and buf_rvs-doc.shift-num  = ub.shift-obj.shift-num
                        and buf_rvs-doc.status_    = 'факт':U
                        and buf_rvs-doc.rvs-type   = 'смена':U
                        no-error .
                    if not available buf_rvs-doc then
                    do:
                        message
                            "Нет закрытой сверки сменой сверки" skip
                            "Невозможно закрыть текущую смену" skip
                            "Закрываемая смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num
                            view-as alert-box error .
                        undo main-block, return error .
                    end.
                    if ub.shift-obj.shift-name <> buf_rvs-doc.shift-name then
                    do:
                        message
                            "Последняя закрытая сверка за смену не соответствует текущей смене." skip
                            "Невозможно закрыть текущую смену." skip
                            "Закрываемая смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                            "Сверка" buf_rvs-doc.rvs-code skip
                            "Сверка принадлежит смене" buf_rvs-doc.shift-date "Номер" buf_rvs-doc.shift-name "Порядок" buf_rvs-doc.shift-num skip
                            "Дата фактического закрытия сверки" buf_rvs-doc.fact-date skip
                            view-as alert-box error .
                        undo main-block, return error .
                    end.
                    find last ub.trn-doc
                        where ub.trn-doc.obj-type = ub.shift-obj.obj-type
                        and ub.trn-doc.obj-code = ub.shift-obj.obj-code
                        and ub.trn-doc.status_  = 'факт':U
                        use-index stat-fact
                        no-error .
                    if available ub.trn-doc
                        and ub.trn-doc.fact-order > buf_rvs-doc.fact-order
                        then
                    do:
                        message
                            "Найдена накладная, которая закрыта позже закрывающей сверки" skip
                            "Невозможно закрыть текущую смену" skip
                            "Закрываемая смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                            "Сверка" buf_rvs-doc.rvs-code skip
                            "Накладная" ub.trn-doc.doc-code
                            view-as alert-box error .
                        undo main-block, return error .
                    end.
                    find last ub.price-doc
                        where ub.price-doc.obj-type = ub.shift-obj.obj-type
                        and ub.price-doc.obj-code = ub.shift-obj.obj-code
                        and ub.price-doc.status_ = 'акт':U
                        use-index fact-close
                        no-error .
                    if available ub.price-doc
                        and ub.price-doc.fact-order > buf_rvs-doc.fact-order
                        then
                    do:
                        message
                            "Найдена переоценка, которая закрыта позже закрывающей сверки" skip
                            "Невозможно закрыть текущую смену" skip
                            "Закрываемая смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                            "Сверка" buf_rvs-doc.rvs-code skip
                            "Переоценка" ub.price-doc.doc-num
                            view-as alert-box error .
                        undo main-block, return error .
                    end.
                    for each buf_pl-gds
                        where buf_pl-gds.obj-type = ub.shift-obj.obj-type
                        and buf_pl-gds.obj-code = ub.shift-obj.obj-code,
                        first ub.place no-lock where ub.place.obj-type = buf_pl-gds.obj-type
                        and ub.place.obj-code = buf_pl-gds.obj-code
                        and ub.place.pl-code = buf_pl-gds.pl-code
                        and ub.place.status_ = ''
                        on error undo main-block, return error
                        :
                        find first buf_goods no-lock
                            where buf_goods.gds-code = buf_pl-gds.gds-code
                            .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output v-is-petrol
  , output v-is-pieces
  ) no-error.
                        if v-is-petrol = true
                            and v-is-pieces = false
                            then
                        do:
                            run gds-attr-value in this-procedure
                                ( input  buf_goods.gds-code
                                , input  'ptrl-without-rvs':U
                                , output v-ptrl-without-rvs
                                , output v-attr-type
                                ) .
                            if lookup(v-ptrl-without-rvs, 'true,yes':u) = 0 then
                            do:
                                find first buf_rvs-line
                                    where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                    and buf_rvs-line.gds-code = buf_pl-gds.gds-code
                                    and buf_rvs-line.pl-code  = buf_pl-gds.pl-code
                                    and buf_rvs-line.obj-type = ub.shift-obj.obj-type
                                    and buf_rvs-line.obj-code = ub.shift-obj.obj-code
                                    no-error .
                                if not available buf_rvs-line then
                                do:
                                    message
                                        "Закрывающая сверка по смене не содержит всех действующих мест хранения топлива" skip
                                        "Невозможно закрыть текущую смену" skip
                                        "Закрываемая смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                                        "Сверка" buf_rvs-doc.rvs-code skip
                                        "Код места хранения" buf_pl-gds.pl-code skip
                                        "Локальный код товара" buf_pl-gds.gds-code skip
                                        view-as alert-box error .
                                    undo main-block, return error .
                                end.
                            end.
                        end.
                    end.
                end.
                find first ub.inkas
                    where ub.inkas.obj-type = ub.shift-obj.obj-type
                    and ub.inkas.obj-code = ub.shift-obj.obj-code
                    and ub.inkas.status_  > 'факт':U
                    no-error .
                if not available ub.inkas then
                do:
                    find first ub.inkas
                        where ub.inkas.obj-type = ub.shift-obj.obj-type
                        and ub.inkas.obj-code = ub.shift-obj.obj-code
                        and ub.inkas.status_  < 'факт':U
                        no-error .
                end.
                if available ub.inkas then
                do:
                end.
                do ii = 0 to num-entries(v-fact-status-list):
                    CASE ii:
                        when 0 then
                            do:
                                find first buf_inkas no-lock
                                    where buf_inkas.obj-type = ub.shift-obj.obj-type
                                    and buf_inkas.obj-code = ub.shift-obj.obj-code
                                    and buf_inkas.status_ < entry(1, v-fact-status-list) no-error .
                            end.
                        when num-entries(v-fact-status-list) then
                            do:
                                find first buf_inkas no-lock
                                    where buf_inkas.obj-type = ub.shift-obj.obj-type
                                    and buf_inkas.obj-code = ub.shift-obj.obj-code
                                    and buf_inkas.status_ > entry(num-entries(v-fact-status-list), v-fact-status-list) no-error .
                            end.
                        otherwise
                        do:
                            find first buf_inkas no-lock
                                where buf_inkas.obj-type = ub.shift-obj.obj-type
                                and buf_inkas.obj-code = ub.shift-obj.obj-code
                                and buf_inkas.status_ > entry(ii, v-fact-status-list)
                                and buf_inkas.status_ < entry(ii + 1, v-fact-status-list)
                                no-error .
                        end.
                    END CASE.
                    if available buf_inkas then
                    do:
                        message
                            "Найдена незакрытая продажа" skip
                            "Невозможно закрыть текущую смену" skip
                            "Закрываемая смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                            "Продажа" buf_inkas.inkas-code skip
                            view-as alert-box error .
                        undo main-block, return error .
                    end.
                end.
                run gbl/chk-date.p (
                    input shift-obj.obj-type
                    ,input shift-obj.obj-code
                    ,input v-obj-date
                    ,input shift-obj.close-time
                    ,input shift-obj.shift-date
                    ,input shift-obj.shift-num
                    ,input yes) no-error.
                if error-status :error then
                do:
                    message "Ошибка при определении даты смены."
                        view-as alert-box error.
                    undo main-block, return error .
                end.
                assign
                    ub.shift-obj.close-id       = g#userid
                    ub.shift-obj.close-sys-date = v-sys-date
                    ub.shift-obj.close-sys-time = v-sys-time
                    .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  ub.shift-obj.obj-type
  ,input  ub.shift-obj.obj-code
  ,output v-host-code
  )  .
                define variable v-value-character as character no-undo .
                define variable v-value-date      as date      no-undo .
                define variable v-value-decimal   as decimal   no-undo .
                define variable v-value-logical   as logical   no-undo .
                define variable v-tth             as handle    no-undo .
                define variable v-param-type      as character no-undo .
                run adm/shattri.p ( input "get":U
                    , input  ub.shift-obj.obj-type
                    , input  ub.shift-obj.obj-code
                    , input  'obj-date':U
                    , input  'diffshft':U
                    , output v-value-character
                    , output v-value-date
                    , output v-value-decimal
                    , output v-max-shift-days
                    , output v-value-logical
                    , output v-param-type
                    , input-output table-handle v-tth
                    ) no-error .
                if error-status :error then
                do:
                    assign
                        v-max-shift-days = 3.
                end.
                if ub.shift-obj.close-date > ub.shift-obj.open-date + v-max-shift-days then
                do:
                    message
                        "С момента открытия смены прошло более " v-max-shift-days " дней" skip
                        "Смена не может быть закрыта датой " ub.shift-obj.close-date skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                find first ub.wth-doc no-lock
                    where ub.wth-doc.obj-type    = ub.shift-obj.obj-type
                    and ub.wth-doc.obj-code    = ub.shift-obj.obj-code
                    and ub.wth-doc.shift-date  = ub.shift-obj.shift-date
                    and ub.wth-doc.shift-num   = ub.shift-obj.shift-num
                    and ub.wth-doc.status_    <> 'факт':U
                    no-error .
                if available ub.wth-doc then
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Ошибка при закрытии смены" skip
                        "Есть отркытые документы перемещения материальных ценностей" skip
                        "Документ МЦ" ub.wth-doc.doc-code skip
                        "Тип документа" ub.wth-doc.doc-type skip
                        "Дата" ub.wth-doc.doc-date skip
                        "Статус" ub.wth-doc.status_ skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                define variable v-fact-order           as decimal no-undo .
                define variable v-shift-end-fact-order as decimal no-undo .
                define variable v-day-end-fact-order   as decimal no-undo .
                run factord in this-procedure
                    (input  ub.shift-obj.close-date
                    ,input  ub.shift-obj.close-time
                    ,input  1
                    ,input  ub.shift-obj.shift-date
                    ,input  ub.shift-obj.shift-num
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
                        "Ошибка при определении фактического номера смены" skip
                        "obj-type"                ub.shift-obj.obj-type   skip
                        "obj-code"                ub.shift-obj.obj-code   skip
                        "fact-date"               ub.shift-obj.close-date skip
                        "fact-time"               ub.shift-obj.close-time skip
                        "shift-date"              ub.shift-obj.shift-date skip
                        "shift-num"               ub.shift-obj.shift-num  skip
                        "v-fact-order"            v-fact-order            skip
                        "v-shift-end-fact-order"  v-shift-end-fact-order  skip
                        "v-day-end-fact-order"    v-day-end-fact-order    skip
                        error-status :get-message(1) skip
                        return-value skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                assign
                    ub.shift-obj.fact-order = v-shift-end-fact-order
                    .
                for each ub.shift-staff no-lock where ub.shift-staff.obj-type = ub.shift-obj.obj-type
                    and ub.shift-staff.obj-code = ub.shift-obj.obj-code
                    and ub.shift-staff.shift-num = ub.shift-obj.shift-num
                    and ub.shift-staff.shift-date = ub.shift-obj.shift-date
                    and ub.shift-staff.next-shift = no :
                    if ub.shift-staff.staff-role
                        then
                        assign
                            v-shift-manager = ub.shift-staff.name
                            .
                    else
                        assign
                            v-shift-staff-list = v-shift-staff-list + (if v-shift-staff-list = "" then "" else ", ") + ub.shift-staff.name
                            .
                end.
                v-vid-action = 62 .
                v-vid-param = "SHOP_NUM=" + string(ub.shift-obj.obj-code) + chr(4) +
                    "SHIFT_NUM=" + string(ub.shift-obj.shift-num) + string(ub.shift-obj.shift-date, "99999999") + chr(4) +
                    "ShiftManager=" + v-shift-manager + chr(4) +
                    "ShiftStaff=" + v-shift-staff-list + chr(4) +
                    "RESULT=0" + chr(4) +
                    "Description=".
            end.
            if ub.shift-obj.status_ = 'тек':U and
                oldb.status_         = 'зкр':U then
            do:
                find first prev-shift where
                    prev-shift.obj-type = ub.shift-obj.obj-type and
                    prev-shift.obj-code = ub.shift-obj.obj-code and
                    prev-shift.status_ = 'тек':U and
                    recid (prev-shift) <> recid (ub.shift-obj) no-error.
                if available prev-shift then
                do:
                    message
                        "Найдена другая открытая смена" skip
                        "Невозможно отменить закрытую смену" skip
                        "Найденная смена" prev-shift.shift-date "Номер" prev-shift.shift-name "Порядок" prev-shift.shift-num skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                find last prev-shift where
                    prev-shift.obj-type = ub.shift-obj.obj-type and
                    prev-shift.obj-code = ub.shift-obj.obj-code and
                    prev-shift.status_ = 'зкр':U
                    use-index pi no-error .
                if not available prev-shift or
                    prev-shift.shift-date < ub.shift-obj.shift-date or
                    prev-shift.shift-date = ub.shift-obj.shift-date and
                    prev-shift.shift-num < ub.shift-obj.shift-num then
                    .
                else
                do:
                    message
                        "Найдена смена со статусом" 'зкр':U skip
                        "Найденная смена" prev-shift.shift-date "Номер" prev-shift.shift-name "Порядок" prev-shift.shift-num skip
                        "Отменяемая закрытая смена должна быть последней" skip
                        "Невозможно отменить смену" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                ub.shift-obj.fact-order = 0.
                for each ub.shift-staff no-lock where ub.shift-staff.obj-type = ub.shift-obj.obj-type
                    and ub.shift-staff.obj-code = ub.shift-obj.obj-code
                    and ub.shift-staff.shift-num = ub.shift-obj.shift-num
                    and ub.shift-staff.shift-date = ub.shift-obj.shift-date
                    and ub.shift-staff.next-shift = no :
                    if ub.shift-staff.staff-role
                        then
                        assign
                            v-shift-manager = ub.shift-staff.name
                            .
                    else
                        assign
                            v-shift-staff-list = v-shift-staff-list + (if v-shift-staff-list = "" then "" else ", ") + ub.shift-staff.name
                            .
                end.
                v-vid-action = 53 .
                v-vid-param = "SHOP_NUM=" + string(ub.shift-obj.obj-code) + chr(4) +
                    "SHIFT_NUM=" + string(ub.shift-obj.shift-num) + string(ub.shift-obj.shift-date, "99999999") + chr(4) +
                    "ShiftManager=" + v-shift-manager + chr(4) +
                    "ShiftStaff=" + v-shift-staff-list + chr(4) +
                    "RESULT=0" + chr(4) +
                    "Description=".
            end.
            if ub.shift-obj.status_ = 'ожд':U and
                oldb.status_         = 'тек':U then
            do:
                find first ub.trn-doc where
                    ub.trn-doc.obj-type   = ub.shift-obj.obj-type   and
                    ub.trn-doc.obj-code   = ub.shift-obj.obj-code   and
                    ub.trn-doc.shift-date = ub.shift-obj.shift-date and
                    ub.trn-doc.shift-num  = ub.shift-obj.shift-num  and
                    ub.trn-doc.status_ = 'факт':U
                    use-index stat-fact no-error.
                if available ub.trn-doc then
                do:
                    message
                        "Найдена накладная, которая закрыта в течение смены" skip
                        "Невозможно отменить текущую смену" skip
                        "Смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                        "Накладная" ub.trn-doc.doc-code
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                find first ub.price-doc where
                    ub.price-doc.obj-type   = ub.shift-obj.obj-type and
                    ub.price-doc.obj-code   = ub.shift-obj.obj-code and
                    ub.price-doc.shift-date = ub.shift-obj.shift-date and
                    ub.price-doc.shift-num  = ub.shift-obj.shift-num  and
                    ub.price-doc.status_    = 'акт':U
                    use-index fact-close no-error.
                if available ub.price-doc then
                do:
                    message
                        "Найдена переоценка, которая закрыта в течение смены" skip
                        "Невозможно отменить текущую смену" skip
                        "Смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                        "Переоценка" ub.price-doc.doc-num
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                find first buf_rvs-doc
                    where buf_rvs-doc.obj-type = ub.shift-obj.obj-type
                    and buf_rvs-doc.obj-code = ub.shift-obj.obj-code
                    and buf_rvs-doc.rvs-type <> 'проверка':U
                    and buf_rvs-doc.status_  <> 'факт':U
                    no-error .
                if available buf_rvs-doc then
                do:
                    message
                        "Найдена незакрытая сверка" skip
                        "Невозможно отменить текущую смену" skip
                        "Смена" ub.shift-obj.shift-date "Номер" ub.shift-obj.shift-name "Порядок" ub.shift-obj.shift-num skip
                        "Сверка" buf_rvs-doc.rvs-code skip
                        view-as alert-box error .
                    undo main-block, return error .
                end.
                for each ub.shift-staff no-lock where ub.shift-staff.obj-type = ub.shift-obj.obj-type
                    and ub.shift-staff.obj-code = ub.shift-obj.obj-code
                    and ub.shift-staff.shift-num = ub.shift-obj.shift-num
                    and ub.shift-staff.shift-date = ub.shift-obj.shift-date
                    and ub.shift-staff.next-shift = no :
                    if ub.shift-staff.staff-role
                        then
                        assign
                            v-shift-manager = ub.shift-staff.name
                            .
                    else
                        assign
                            v-shift-staff-list = v-shift-staff-list + (if v-shift-staff-list = "" then "" else ", ") + ub.shift-staff.name
                            .
                end.
                v-vid-action = 53 .
                v-vid-param = "SHOP_NUM=" + string(ub.shift-obj.obj-code) + chr(4) +
                    "SHIFT_NUM=" + string(ub.shift-obj.shift-num) + string(ub.shift-obj.shift-date, "99999999") + chr(4) +
                    "ShiftManager=" + v-shift-manager + chr(4) +
                    "ShiftStaff=" + v-shift-staff-list + chr(4) +
                    "RESULT=0" + chr(4) +
                    "Description=".
            end.
        end.
    end.
    if not g#news then
    do:
        run cur-time in this-procedure
            ( output v-today
            ,output v-time
            ).
        create buf_c-shift-obj.
        buffer-copy oldb except
            obj-type
            obj-code
            shift-date
            shift-num
            to buf_c-shift-obj
            .
        assign
            buf_c-shift-obj.obj-type         = ub.shift-obj.obj-type
            buf_c-shift-obj.obj-code         = ub.shift-obj.obj-code
            buf_c-shift-obj.shift-date       = ub.shift-obj.shift-date
            buf_c-shift-obj.shift-num        = ub.shift-obj.shift-num
            buf_c-shift-obj.chip-num         = next-value (s-shift-chip, ub)
            buf_c-shift-obj.corr-time        = v-time
            buf_c-shift-obj.corr-user-db-num = g#db-num
            buf_c-shift-obj.corr-user-name   = g#userid
            buf_c-shift-obj.corr-date        = v-today
            .
        if new( ub.shift-obj ) then
        do:
            assign
                buf_c-shift-obj.shift-name = ub.shift-obj.shift-name
                .
        end.
        create buf_c-sht-hist.
        buffer-copy buf_c-shift-obj to buf_c-sht-hist
            assign
            buf_c-sht-hist.action             = integer( if new( ub.shift-obj )
                                              then '1':U
                                              else '2':U)
            buf_c-sht-hist.subject = 'shift-obj':U
            buf_c-sht-hist.is-news = g#news
            .
        if ub.shift-obj.status_ <> "" then
        do:
            run str/callnews.p
                (input 'shift-obj':U
                ,input (buffer ub.shift-obj:handle)
                ) no-error .
            if error-status :error then
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Невозможно маршрутизировать shift-obj для отправки в новости" skip
                    error-status :get-message(1) skip
                    return-value skip
                    view-as alert-box error .
                undo main-block, return error .
            end.
        end.
        if ub.shift-obj.status_ = 'зкр':U then
        do:
            define buffer buf_user-account for ub.user-account .
            define variable user-id as character no-undo .
            define variable fio     as character no-undo .
            find first buf_user-account no-lock where buf_user-account.user-id = g#userid no-error .
            if available (buf_user-account) then
            do:
                assign
                    user-id = buf_user-account.user-id
                    fio     = buf_user-account.last-name + " " + buf_user-account.first-name + " " + buf_user-account.second-name .
            end.
            define buffer buf_reportShift for ub.reportShift .
            define buffer buf_shift-attr  for ub.shift-obj-attr .
            find first buf_reportShift exclusive-lock where buf_reportShift.shift-date = ub.shift-obj.shift-date and
                buf_reportShift.shift-num = ub.shift-obj.shift-num and buf_reportShift.obj-code = ub.shift-obj.obj-code and
                buf_reportShift.obj-type = ub.shift-obj.obj-type and buf_reportShift.report-type = 0 no-error .
            if not available (buf_reportShift) then
            do:
                find first buf_shift-attr exclusive-lock where buf_shift-attr.attr-code = "reportShift" and
                    buf_shift-attr.obj-code = ub.shift-obj.obj-code and
                    buf_shift-attr.obj-type = ub.shift-obj.obj-type and
                    buf_shift-attr.shift-date = 01/01/1970 and
                    buf_shift-attr.shift-num = 1 no-error .
                if available (buf_shift-attr) then
                do:
                    buf_shift-attr.attr-value = string(integer(buf_shift-attr.attr-value) + 1) .
                end.
                else
                do:
                    create buf_shift-attr .
                    assign
                        buf_shift-attr.attr-code  = "reportShift"
                        buf_shift-attr.obj-code   = ub.shift-obj.obj-code
                        buf_shift-attr.obj-type   = ub.shift-obj.obj-type
                        buf_shift-attr.shift-date = 01/01/1970
                        buf_shift-attr.shift-num  = 1
                        buf_shift-attr.attr-value = string(next-value(s-reportShift, ub)).
                end.
                create buf_reportShift.
                assign
                    buf_reportShift.id          = integer(buf_shift-attr.attr-value)
                    buf_reportShift.obj-code    = ub.shift-obj.obj-code
                    buf_reportShift.obj-type    = ub.shift-obj.obj-type
                    buf_reportShift.report-type = 0
                    buf_reportShift.shift-date  = ub.shift-obj.shift-date
                    buf_reportShift.shift-num   = ub.shift-obj.shift-num
                    .
            end.
            assign
                buf_reportShift.date       = today
                buf_reportShift.user-id    = user-id
                buf_reportShift.fio        = fio
                buf_reportShift.time_      = time
                buf_reportShift.shift-name = ub.shift-obj.shift-name
                .
            find first ub.susp-chk no-lock where ub.susp-chk.obj-code = ub.shift-obj.obj-code and
                ub.susp-chk.obj-type = ub.shift-obj.obj-type and
                ub.susp-chk.shift-date = ub.shift-obj.shift-date and
                ub.susp-chk.shift-name = ub.shift-obj.shift-name and
                ub.susp-chk.shift-num = ub.shift-obj.shift-num no-error .
            if available (ub.susp-chk) then buf_reportShift.flag = true .
        end.
    end.
    if g#oxml = yes
        then
    do:
        run str/calloxml.p (
            input 'update':U
            , input 'shift-obj':U
            , input ( buffer ub.shift-obj:handle )
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
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'event_shift':U
  ,input  buffer oldb:handle
  ,input  buffer ub.shift-obj:handle
  ,input ''
  ,input ''
  ) no-error .
    if error-status :error
        then
    do:
        return error substitute( "&2&1Ошибка маршрутизации записи в машину правил&1&3&1&4"
            , chr(10)
            , vss-workfile
            , return-value
            , error-status :get-message ( 1 ) ).
    end.
end.
if g#news <> yes
    then
do:
    run trg/userlog.p (
        input 'update':U
        , input 'c-sht-hist':U
        , input ( buffer buf_c-sht-hist :handle )
        , input v-vid-action
        , input v-vid-param
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
