block-level on error undo, throw.
define input-output parameter par-rid as recid no-undo .
define input parameter par-mode as character no-undo .
define input parameter p-silent as logical   no-undo .
define input parameter partax-code like ub.tax-rate-value.tax-code no-undo .
define input parameter parrate-code like ub.tax-rate-value.rate-code no-undo .
define input parameter parrate-value like ub.tax-rate-value.rate-value no-undo .
define input parameter parfact-date like ub.tax-rate-value.fact-date no-undo .
define input parameter parhost-code like ub.tax-rate-value.host-code no-undo .
define input parameter parobj-type like ub.tax-rate-value.obj-type no-undo .
define input parameter parobj-code like ub.tax-rate-value.obj-code no-undo .
define input parameter parstatus  like ub.tax-rate-value.status_ no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: taxvali1.p $":U .
def var vss-archive     as character no-undo init "$Archive: ref/taxvali1.p $":U .
def var vss-description as character no-undo init "Сохранение изменений в карточке значений ставки налога".
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
main-block:
do transaction
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  define variable var-entry as character no-undo .
  define variable var-fact-order like ub.tax-rate-value.fact-order no-undo .
  define variable dop-rid as recid no-undo .
  define variable is-found as logical no-undo .
  define variable loc#log as logical no-undo .
  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.
  define variable varfact-date as date no-undo .
  define variable v-first-value as logical no-undo .
  define variable v-mess as character no-undo .
  define buffer b_tax-rate-value     for ub.tax-rate-value.
  define buffer buf_tax-rate-value   for ub.tax-rate-value.
  define buffer first_tax-rate-value for ub.tax-rate-value.
  define buffer new_tax-rate-value   for ub.tax-rate-value .
  define buffer up_tax-rate-value    for ub.tax-rate-value .
  if par-mode <> 'ДОБАВЛЕНИЕ':U then do:
    assign
      v-mess = substitute( "&1 (&2). Ошибка задания входных параметров. Неверный параметр par-mode (&3).", vss-workfile, vss-revision, par-mode )
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else '':U ).
  end.
  FIND FIRST ub.tax-rate No-LOCK where
            ub.tax-rate.tax-code = partax-code AND
            ub.tax-rate.rate-code = parrate-code No-ERROR.
  if not available ub.tax-rate then do:
    assign
      v-mess = substitute( "Не найдена ставка." )
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else '':U ).
  end.
  if ub.tax-rate.status_ = 'удал':U then do:
    assign
      v-mess = substitute( "Нельзя добавить значениe к удаленной ставке." )
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else '':U ).
  end.
  find first first_tax-rate-value no-lock where
            first_tax-rate-value.tax-code = partax-code
        AND first_tax-rate-value.rate-code = parrate-code no-error .
  if not available first_tax-rate-value then do:
    assign
    v-first-value = true
    .
  end.
  if v-first-value = true then do:
    assign
    v-today = 01/01/1990
    .
  end.
  else do:
    if parobj-type = ""
    or parobj-code = 0
    then do:
        run cur-time in this-procedure ( output v-today
                                      , output v-time
                                      ).
    end.
    else do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-today
  )  .
    end.
  end.
  if parfact-date = ? then do:
      assign
      v-mess = substitute( "Не указана дата начала действия данного значения ставки." )
        var-entry = "fact-date":U
      .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else var-entry ).
  end.
  if p-silent = no
    and parfact-date < v-today
  then do:
    assign
      v-mess = substitute( "Указана дата начала действия данного значения ставки меньше текущей." )
      var-entry = "fact-date":U
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else var-entry ).
  end.
  assign
  varfact-date = parfact-date
  .
  run factord-end-day in this-procedure (input parfact-date, output var-fact-order).
  find last b_tax-rate-value no-lock
    where b_tax-rate-value.tax-code = partax-code
      and b_tax-rate-value.rate-code = parrate-code
      and b_tax-rate-value.fact-order <= var-fact-order
      and b_tax-rate-value.host-code = parhost-code
      and b_tax-rate-value.obj-type = parobj-type
      and b_tax-rate-value.obj-code = parobj-code
      and b_tax-rate-value.status_ = 'тек':U
    no-error.
  if available b_tax-rate-value
    and b_tax-rate-value.rate-value = parrate-value
  then do:
    assign
      v-mess = substitute( "Уже есть ТАКОЕ ЖЕ значение ставки налога, которое действует с &1", string( b_tax-rate-value.fact-date, "99/99/9999" ) )
      var-entry = "rate-value":U
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else var-entry ).
  end.
  else do:
    FIND LAST b_tax-rate-value No-LOCK WHERE
              b_tax-rate-value.tax-code = partax-code AND
              b_tax-rate-value.rate-code = parrate-code AND
              b_tax-rate-value.fact-order <= var-fact-order AND
              b_tax-rate-value.host-code = parhost-code AND
              b_tax-rate-value.obj-type = parobj-type AND
              b_tax-rate-value.obj-code = parobj-code
              NO-ERROR.
    if not available b_tax-rate-value then do:
      assign
      varfact-date = 01/01/1990
      .
      run factord-end-day in this-procedure (input varfact-date, output var-fact-order).
    end.
  end.
  FIND FIRST b_tax-rate-value  NO-LOCK where
            b_tax-rate-value.tax-code = partax-code AND
            b_tax-rate-value.rate-code = parrate-code AND
            b_tax-rate-value.fact-order = var-fact-order AND
            b_tax-rate-value.host-code = parhost-code AND
            b_tax-rate-value.obj-type = parobj-type AND
            b_tax-rate-value.obj-code = parobj-code AND
            b_tax-rate-value.status_ = 'тек':U
            No-ERROR.
  if available b_tax-rate-value then do:
    if parfact-date > v-today then do:
      if p-silent = no then do:
        message "Уже есть значение ставки налога" skip
                "с такой датой начала действия"
                "Переписать значение? "
        view-as alert-box QUESTION
        buttons YES-NO update loc#log.
      end.
      else do:
        assign
          loc#log = true
        .
      end.
      if loc#log = false then do:
        assign
          var-entry = "fact-date":U
        .
        return error var-entry.
      end.
      else do:
        assign
          dop-rid = recid(b_tax-rate-value)
          is-found = yes
        .
      end.
    end.
    else do:
      assign
        v-mess = substitute( "Уже есть значение ставки налога действующее с &1", string( b_tax-rate-value.fact-date, "99/99/9999" ) )
        var-entry = "fact-date":U
      .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else var-entry ).
    end.
  end.
  else do:
    FIND FIRST b_tax-rate-value  NO-LOCK where
              b_tax-rate-value.tax-code = partax-code AND
              b_tax-rate-value.rate-code = parrate-code AND
              b_tax-rate-value.fact-order = var-fact-order AND
              b_tax-rate-value.host-code = parhost-code AND
              b_tax-rate-value.obj-type = parobj-type AND
              b_tax-rate-value.obj-code = parobj-code AND
              b_tax-rate-value.status_ = 'удал':U
              No-ERROR.
    if available b_tax-rate-value then do:
      if p-silent = no then do:
        message substitute( "Уже есть удаленное значение ставки налога (&1)", b_tax-rate-value.rate-value ) skip
                substitute( "с такой же датой начала действия (&1)", b_tax-rate-value.fact-date ) skip
                "Восстановить и переписать значение? "
        view-as alert-box QUESTION
        buttons YES-NO update loc#log.
        if not loc#log then do:
          var-entry = "fact-date":U.
          return error var-entry.
        end.
        else do:
          assign
          dop-rid = recid(b_tax-rate-value)
          is-found = yes.
        end.
      end.
      else do:
        if parstatus = 'тек':U then do:
          assign
          dop-rid = recid(b_tax-rate-value)
          is-found = yes.
        end.
        else do:
          assign
            v-mess = substitute( "Уже есть удаленное значение ставки налога (&1) с такой датой начала действия (&2)", b_tax-rate-value.rate-value, b_tax-rate-value.fact-date )
            var-entry = "fact-date":U
          .
          run err-mess in this-procedure ( input-output v-mess ).
          undo main-block, return error (if p-silent = yes then v-mess else var-entry ).
        end.
      end.
    end.
  end.
  if is-found = true then do:
    FIND FIRST b_tax-rate-value EXCLUSIVE-LOCK where
              recid( b_tax-rate-value) = dop-rid No-ERROR.
    if not available b_tax-rate-value then do:
      assign
        v-mess = substitute( "Не удалось переписать значение ставки налога" )
      .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else '':U ).
    end.
    assign
    b_tax-rate-value.rate-value = parrate-value
    b_tax-rate-value.status_ = 'тек':U
    par-rid = recid( b_tax-rate-value )
    .
    release b_tax-rate-value no-error .
    if error-status:error then do:
      assign
        v-mess = substitute( "&2 (&3). Ошибка при сохранении записи ЗНАЧЕНИЕ СТАВКИ НАЛОГА.&1&4&1&5"
                              , chr(10)
                              , vss-workfile
                              , vss-revision
                              , error-status:get-message(1)
                              , return-value )
      .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else '':U ).
    end.
  end.
  else do:
    create new_tax-rate-value.
    assign
    new_tax-rate-value.tax-code = partax-code
    new_tax-rate-value.rate-code = parrate-code
    new_tax-rate-value.rate-value = parrate-value
    new_tax-rate-value.fact-date = varfact-date
    new_tax-rate-value.fact-order = var-fact-order
    new_tax-rate-value.status_ = 'тек':U
    new_tax-rate-value.host-code = parhost-code
    new_tax-rate-value.obj-type = parobj-type
    new_tax-rate-value.obj-code = parobj-code
    par-rid = recid( new_tax-rate-value )
    .
    if parobj-code <> 0 then do:
      find last buf_tax-rate-value no-lock where
                buf_tax-rate-value.tax-code = partax-code AND
                buf_tax-rate-value.rate-code = parrate-code AND
                buf_tax-rate-value.host-code = parhost-code AND
                buf_tax-rate-value.obj-type = "":U AND
                buf_tax-rate-value.obj-code = 0 AND
                buf_tax-rate-value.fact-order <= var-fact-order  NO-ERROR.
      IF not available buf_tax-rate-value OR
        (buf_tax-rate-value.status_ = 'удал':U AND
        NOT can-find(first up_tax-rate-value where
                        up_tax-rate-value.tax-code = partax-code AND
                        up_tax-rate-value.rate-code = parrate-code AND
                        up_tax-rate-value.host-code = parhost-code AND
                        up_tax-rate-value.obj-type = '':U AND
                        up_tax-rate-value.obj-code = 0 AND
                        up_tax-rate-value.fact-order <= var-fact-order AND
                        recid(up_tax-rate-value) <> recid(buf_tax-rate-value)
                      ) AND
        buf_tax-rate-value.fact-order <> var-fact-order
        ) then do:
        if g#db-num > 0 then do:
          assign
            v-mess = substitute( "При создании значения ставки налога на объекте&1"
                                  + "в БД уже должна быть определено значение ставки налога по фирме, которой принадлежит объект &1"
                                  + "Введите значение ставки налога на фирме в ОФИСЕ и перешлите его по СПН&1"
                                  , chr(10)
                                ) .
          run err-mess in this-procedure ( input-output v-mess ).
          undo main-block, return error (if p-silent = yes then v-mess else '':U ).
        end.
        create up_tax-rate-value.
        assign
        up_tax-rate-value.tax-code = partax-code
        up_tax-rate-value.rate-code = parrate-code
        up_tax-rate-value.rate-value = parrate-value
        up_tax-rate-value.fact-date = varfact-date
        up_tax-rate-value.fact-order = var-fact-order
        up_tax-rate-value.status_ = 'тек':U
        up_tax-rate-value.host-code = parhost-code
        up_tax-rate-value.obj-type = "":U
        up_tax-rate-value.obj-code = 0
        .
      end.
      else do:
        if not available buf_tax-rate-value then do:
          find LAST up_tax-rate-value where
                    up_tax-rate-value.tax-code = partax-code AND
                    up_tax-rate-value.rate-code = parrate-code AND
                    up_tax-rate-value.host-code = parhost-code AND
                    up_tax-rate-value.obj-type = '':U AND
                    up_tax-rate-value.obj-code = 0 AND
                    up_tax-rate-value.fact-order <= var-fact-order AND
                    up_tax-rate-value.status_ = 'удал':U NO-WAIT No-ERROR.
          if not available up_tax-rate-value then do:
            assign
              v-mess = substitute( "Не удается создать запись-родитель для значения ставки" )
            .
            run err-mess in this-procedure ( input-output v-mess ).
            undo main-block, return error (if p-silent = yes then v-mess else '':U ).
          end.
          assign
          up_tax-rate-value.status_ = 'тек':U
          .
        end.
      end.
      if available up_tax-rate-value then do:
        release up_tax-rate-value no-error .
        if error-status:error then do:
          assign
            v-mess = substitute( "&2 (&3). Ошибка при сохранении записи-родителя для значения ставки.&1&4&1&5"
                                  , chr(10)
                                  , vss-workfile
                                  , vss-revision
                                  , error-status:get-message(1)
                                  , return-value )
          .
          run err-mess in this-procedure ( input-output v-mess ).
          undo main-block, return error (if p-silent = yes then v-mess else '':U ).
        end.
      end.
    end.
    if parhost-code <> 0 then do:
      FIND  LAST BUF_TAX-RATE-VALUe NO-LOCK where
                  buf_tax-rate-value.tax-code = partax-code AND
                  buf_tax-rate-value.rate-code = parrate-code AND
                  buf_tax-rate-value.host-code = 0 AND
                  buf_tax-rate-value.obj-type = "":U AND
                  buf_tax-rate-value.obj-code = 0 AND
                  buf_tax-rate-value.fact-order <= var-fact-order NO-ERROR.
      IF not available buf_tax-rate-value OR
        (buf_tax-rate-value.status_ = 'удал':U AND
        NOT can-find(first up_tax-rate-value where
                        up_tax-rate-value.tax-code = partax-code AND
                        up_tax-rate-value.rate-code = parrate-code AND
                        up_tax-rate-value.host-code = 0 AND
                        up_tax-rate-value.obj-type = '':U AND
                        up_tax-rate-value.obj-code = 0 AND
                        up_tax-rate-value.fact-order <= var-fact-order AND
                        recid(up_tax-rate-value) <> recid(buf_tax-rate-value)
                      ) AND
        buf_tax-rate-value.fact-order <> var-fact-order
        ) then do:
        create up_tax-rate-value.
        assign
        up_tax-rate-value.tax-code = partax-code
        up_tax-rate-value.rate-code = parrate-code
        up_tax-rate-value.rate-value = parrate-value
        up_tax-rate-value.fact-date = varfact-date
        up_tax-rate-value.fact-order = var-fact-order
        up_tax-rate-value.status_ = 'тек':U
        up_tax-rate-value.host-code = 0
        up_tax-rate-value.obj-type = "":U
        up_tax-rate-value.obj-code = 0
        .
      end.
      else do:
        if not available buf_tax-rate-value then do:
          find LAST up_tax-rate-value where
                    up_tax-rate-value.tax-code = partax-code AND
                    up_tax-rate-value.rate-code = parrate-code AND
                    up_tax-rate-value.host-code = 0 AND
                    up_tax-rate-value.obj-type = '':U AND
                    up_tax-rate-value.obj-code = 0 AND
                    up_tax-rate-value.fact-order <= var-fact-order AND
                    up_tax-rate-value.status_ = 'удал':U No-ERROR.
          if not available up_tax-rate-value then do:
            assign
              v-mess = substitute( "Не удается создать запись-родитель для значения ставки." )
            .
            run err-mess in this-procedure ( input-output v-mess ).
            undo main-block, return error (if p-silent = yes then v-mess else '':U ).
          end.
          assign
          up_tax-rate-value.status_ = 'тек':U
          .
        end.
      end.
      if available up_tax-rate-value then do:
        release up_tax-rate-value no-error .
        if error-status:error then do:
          assign
            v-mess = substitute( "&2 (&3). Ошибка при сохранении записи-родителя для значения ставки.&1&4&1&5"
                                  , chr(10)
                                  , vss-workfile
                                  , vss-revision
                                  , error-status:get-message(1)
                                  , return-value )
          .
          run err-mess in this-procedure ( input-output v-mess ).
          undo main-block, return error (if p-silent = yes then v-mess else '':U ).
        end.
      end.
    end.
    release new_tax-rate-value no-error .
    if error-status:error then do:
      assign
        v-mess = substitute( "&2 (&3). Ошибка при сохранении записи ЗНАЧЕНИЕ СТАВКИ НАЛОГА.&1&4&1&5"
                              , chr(10)
                              , vss-workfile
                              , vss-revision
                              , error-status:get-message(1)
                              , return-value )
      .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else '':U ).
    end.
  end.
  return '':U.
end.
procedure err-mess:
  define input-output parameter p-mess as character no-undo.
  case p-silent:
    when yes then do:
      assign
      p-mess = substitute("Сохранение изменений в карточке ЗНАЧЕНИЙ ставки налога&1"
                          + "Тип ставки &2&1"
                          + "Код ставки &3&1"
                          + "Код фирмы &4&1"
                          + "Объект &5 &6&1"
                          + "Дата включениия &7&1"
                          + "&8"
                         , chr(10)
                         , partax-code
                         , parrate-code
                         , parhost-code
                         , parobj-type
                         , parobj-code
                         , parfact-date
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
end procedure.
