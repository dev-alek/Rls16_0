define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Форма ввода данных для редактирования списка товаров" .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
  define new shared temp-table  tt-tax no-undo
field tax-code    like ub.tax.tax-code
FIELD individual  like ub.tax.individual
FIELD tax-name    like ub.tax.tax-name format "X(12)" column-label "Налог"
field rate-code   like ub.tax-rate.rate-code
FIELD rate-name   like ub.tax-rate.rate-name FORMAT "X(12)"
FIELD tax-type    like ub.tax.tax-type
field rate-value  like ub.tax-rate-value.rate-value
FIELD tax-rate-gds-rc  as recid
FIELD to-cashdesk like ub.tax.to-cashdesk
FIELD fact-date like ub.tax-rate-value.fact-date
FIELD fact-order like ub.tax-rate-value.fact-order
FIELD next-order like ub.tax-rate-value.fact-order
FIELD corr-user-name like ub.tax-rate-gds.corr-user-name
FIELD corr-user-db-num   like ub.tax-rate-gds.corr-user-db-num
FIELD corr-date like ub.tax-rate-gds.corr-date
FIELD corr-time like ub.tax-rate-gds.corr-time
index tax-code is unique primary tax-code fact-order descending rate-code.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_grplib_grp no-undo
    field sel           as character
    field nabor         as character
    field full-name     as character
    field print-code    as character
    field sort-name     as character
    field node-code     as integer
    field upper-code    as integer
    field calc-method   as character
    field round-method  as character
    field increase-pc   as decimal
    field min-marg      as character
    field max-marg      as character
    field cli-type      as character
    field cli-code      as integer
    field notcorr      as character
    field name          as character
    field level         as integer
    field mark          as character
    index pi is primary unique sort-name
    index fn full-name
    index nc is unique node-code
    index sl sel
    index uc upper-code
.
define temp-table temp_grplib_found-grp no-undo
    field full-name   as character
    field sort-name   as character
    field node-code   as integer
    field level       as integer
    field is-terminal as logical
    index pi is primary unique sort-name
    index fn full-name
    index lv level
    index it is-terminal
.
define temp-table temp_found-result-nodelist no-undo
    field node-code     as recid
    field processed     as logical
    field sort-name     as character
    field full-name     as character
    index pi is primary unique node-code
    index ps processed
.
define variable v-grplib-not-fill-extra-info        as logical      no-undo.
define variable v-grplib-no-warning-grp-amount      as logical      no-undo.
define variable v-grplib-grp-amount-for-load        as integer      no-undo.
procedure grplib-get-parameters :
define input parameter p-store-type     as character        no-undo.
define input parameter p-store-code     as integer          no-undo.
do
on error undo, return error
:
    assign
        v-grplib-not-fill-extra-info = no
    .
end.
end procedure.
procedure grplib-get-sort-name :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define output parameter p-sort-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-sort-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-sort-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-sort-name: Ошибка составления полного имени группы"
    :
        assign
            p-sort-name  = buf_gds-grp.node-name
                         + (if p-sort-name <> "" then chr(2) else "")
                         + p-sort-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-sort-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
end.
end procedure.
define variable vss-include-info7 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
procedure grplib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = 0
    no-error .
    if not available buf_gds-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_gds-grp.node-code
        .
    end.
end.
end procedure.
procedure grplib-find-grp-by-full-name :
do
on error undo, return error
:
define input parameter p-search-name  as character    no-undo.
define input parameter p-fill-path    as logical      no-undo.
define output parameter p-found       as logical      no-undo.
    define variable v-upper-code    as integer          no-undo.
    define variable v-counter       as integer           no-undo.
    define variable v-level         as integer           no-undo.
    define variable v-full-name     as character         no-undo.
    define variable v-sort-name     as character         no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    assign
        p-search-name = replace( p-search-name, chr(47), chr(2) )
    .
    run grplib-get-root-code ( output v-upper-code ) no-error .
    if error-status :error
    then do:
        undo, return error "grplib-expand-name: Ошибка при поиске корневого узла".
    end.
    assign
        v-full-name  = ""
        v-level      = num-entries( p-search-name, chr(2) )
    .
    for each temp_grplib_found-grp
    :
        delete temp_grplib_found-grp.
    end.
    start-name-analyze:
    do v-counter = 1 to v-level
    :
        if v-counter < v-level
        then do:
            find first buf_gds-grp no-lock
                 where buf_gds-grp.upper-code = v-upper-code
                   and buf_gds-grp.node-name  = entry( v-counter, p-search-name, chr(2) )
            no-error .
            if not available buf_gds-grp
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                return error "grplib-expand-name: не найдена группа " + entry( v-level, p-search-name, chr(2) ).
            end.
            else do:
                assign
                    v-full-name = v-full-name + ( if v-full-name = "" then "" else chr(47) )        + buf_gds-grp.node-name
                    v-sort-name = v-sort-name + ( if v-sort-name = "" then "" else chr(2) ) + buf_gds-grp.node-name
                    v-upper-code = buf_gds-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name = v-full-name + chr(47)
                        temp_grplib_found-grp.sort-name = v-sort-name
                        temp_grplib_found-grp.node-code = v-upper-code
                        temp_grplib_found-grp.level     = v-counter
                    .
                end.
            end.
        end.
        else do:
            for each buf_gds-grp no-lock
               where buf_gds-grp.upper-code = v-upper-code
                 and buf_gds-grp.node-name begins entry( v-counter, p-search-name, chr(2) )
            :
                assign
                    p-found = yes
                .
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name = v-full-name
                                                        + (if v-full-name = "" then "" else chr(47) )
                                                        + buf_gds-grp.node-name + chr(47)
                    temp_grplib_found-grp.sort-name = v-sort-name
                                                        + ( if v-sort-name = "" then "" else chr(2) )
                                                        + buf_gds-grp.node-name
                    temp_grplib_found-grp.node-code = buf_gds-grp.node-code
                    temp_grplib_found-grp.level     = v-level
                .
            end.
            if p-found = no
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                for each temp_grplib_found-grp
                :
                    delete temp_grplib_found-grp.
                end.
                assign
                    p-found = no
                .
            end.
        end.
    end.
end.
end procedure.
procedure grplib-find-all-subgroup :
do
on error undo, return error
:
define input parameter p-start-node-code    as integer      no-undo.
define input parameter p-terminal-only      as logical      no-undo.
    define variable v-start-full-name   as character     no-undo.
    define variable v-start-sort-name   as character     no-undo.
    define variable v-not-found         as logical       no-undo.
    define variable v-is-terminal       as logical       no-undo.
    define buffer buf_gds-grp           for ub.gds-grp.
    create temp_found-result-nodelist.
    assign
        temp_found-result-nodelist.node-code = p-start-node-code
        temp_found-result-nodelist.processed = no
    .
    run grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-full-name
    ).
    run grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-sort-name
    ).
    process-nodes:
    do while yes
    :
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.node-code = p-start-node-code
        .
        assign
            temp_found-result-nodelist.processed = yes
        .
        for each buf_gds-grp no-lock
           where buf_gds-grp.upper-code = p-start-node-code
        on error undo, return error
        :
            run grplib-is-terminal in this-procedure (
                  input buf_gds-grp.node-code
                , output v-is-terminal
            ).
            if v-is-terminal = yes
            then do:
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                        chr(47) + buf_gds-grp.node-name + chr(47)
                    temp_grplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                        chr(2) + buf_gds-grp.node-name + chr(2)
                    temp_grplib_found-grp.node-code   = buf_gds-grp.node-code
                    temp_grplib_found-grp.is-terminal = yes
                .
            end.
            else do:
                create temp_found-result-nodelist.
                assign
                    temp_found-result-nodelist.node-code = buf_gds-grp.node-code
                    temp_found-result-nodelist.full-name = right-trim(v-start-full-name, chr(47)) +
                                                           chr(47) + buf_gds-grp.node-name + chr(47)
                    temp_found-result-nodelist.sort-name = right-trim(v-start-sort-name, chr(2)) +
                                                           chr(2) + buf_gds-grp.node-name + chr(2)
                    temp_found-result-nodelist.processed = no
                .
                if p-terminal-only = no
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                            chr(47) + buf_gds-grp.node-name + chr(47)
                        temp_grplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                            chr(2) + buf_gds-grp.node-name + chr(2)
                        temp_grplib_found-grp.node-code   = buf_gds-grp.node-code
                        temp_grplib_found-grp.is-terminal = no
                    .
                end.
            end.
        end.
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.processed = no
        no-error.
        if not available temp_found-result-nodelist
        then do:
            leave process-nodes.
        end.
        else do:
            assign
                p-start-node-code = temp_found-result-nodelist.node-code
                v-start-full-name = temp_found-result-nodelist.full-name
                v-start-sort-name = temp_found-result-nodelist.sort-name
            .
        end.
    end.
end.
end procedure.
procedure grplib-expand-name :
define input parameter p-start-name as character        no-undo.
define output parameter p-end-name  as character        no-undo.
    define variable v-is-terminal   as logical      no-undo.
    define variable v-found         as character    no-undo.
    define buffer buf_temp_grplib_found-grp     for temp_grplib_found-grp.
do
for buf_temp_grplib_found-grp
on error undo, return error
:
    run grplib-find-grp-by-full-name in this-procedure (
          input p-start-name
        , input no
        , output v-found
    ) no-error.
    run grplib-get-max-substring in this-procedure (
                input length( p-start-name )
              , output p-end-name
    ) no-error .
    if error-status :error
    then do:
        assign
            p-end-name = ""
        .
    end.
    else do:
        find first temp_grplib_found-grp
            where temp_grplib_found-grp.full-name = p-end-name
        no-error.
        if available temp_grplib_found-grp
        then do:
            find first buf_temp_grplib_found-grp
                where buf_temp_grplib_found-grp.full-name begins p-end-name
                and recid( buf_temp_grplib_found-grp ) <> recid( temp_grplib_found-grp )
            no-error.
            if not available buf_temp_grplib_found-grp
            then do:
                run grplib-is-terminal in this-procedure (
                    input temp_grplib_found-grp.node-code
                    , output v-is-terminal
                ).
            end.
        end.
    end.
end.
end procedure.
procedure grplib-get-max-substring :
do
on error undo, return error
:
define input parameter p-min-substring-length   as integer      no-undo.
define output parameter p-substring             as character    no-undo.
        define variable v-char-counter  as integer           no-undo.
        define variable v-current-char  as character         no-undo.
        define variable v-names-counter  as integer           no-undo.
        define variable v-base-string   as character         no-undo.
        assign
            v-char-counter  = p-min-substring-length
        .
        find first temp_grplib_found-grp no-error.
        if not available temp_grplib_found-grp
        then do:
            undo, return error "grplib-get-max-substring: Нет строк для вычисления общей подстроки".
        end.
        else do:
            assign
                v-base-string  = temp_grplib_found-grp.full-name
                v-char-counter = 0
            .
            counter-block:
            do while yes
            on error undo, return error "grplib-get-max-substring: Ошибка вычисления продолжения имени группы."
            :
                assign
                    v-char-counter  = v-char-counter + 1
                    v-current-char  = substring( v-base-string, v-char-counter, 1 )
                    v-names-counter = 0
                .
                compare-block:
                for each temp_grplib_found-grp
                :
                    assign
                        v-names-counter = v-names-counter + 1
                    .
                    if v-names-counter = 1
                    then do:
                        next compare-block.
                    end.
                    if substring( temp_grplib_found-grp.full-name, v-char-counter, 1 ) <> v-current-char
                    then do:
                        leave counter-block.
                    end.
                end.
                if v-names-counter = 1
                then do:
                    assign
                        p-substring = v-base-string
                    .
                    return.
                end.
            end.
            assign
                p-substring = substring( v-base-string, 1, v-char-counter - 1 )
            .
        end.
end.
end procedure.
procedure grplib-is-terminal :
do
on error undo, return error "Ошибка процедуры grplib-is-terminal"
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-is-terminal   as logical      no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = p-node-code
    no-error .
    if not available buf_gds-grp
    then do:
        assign
            p-is-terminal = yes
        .
    end.
    else do:
        assign
            p-is-terminal = no
        .
    end.
end.
end procedure.
procedure grplib-have-goods :
do
on error undo, return error
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-have-goods   as logical      no-undo.
    define buffer buf_goods         for ub.goods.
    find first buf_goods no-lock
         where buf_goods.grp-code = p-node-code
    no-error .
    if available buf_goods
    then do:
        assign
            p-have-goods = yes
        .
    end.
    else do:
        assign
            p-have-goods = no
        .
    end.
end.
end procedure.
procedure grplib-find-by-substring :
do
on error undo, return error
:
define input parameter p-start-code         as integer      no-undo.
define input parameter p-full-search-string as character    no-undo.
define output parameter p-found-code        as integer      no-undo.
define output parameter p-full-name         as character    no-undo.
    define variable v-start-code     as integer           no-undo.
    define variable v-found          as logical  init no  no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    search-grp:
    for each buf_gds-grp no-lock
        where buf_gds-grp.node-code > p-start-code
    :
        if index( buf_gds-grp.node-name, p-full-search-string ) <> 0
        then do:
            assign
                p-found-code = buf_gds-grp.node-code
                v-found      = yes
            .
            run grplib-get-full-name in this-procedure (
                  input p-found-code
                , output p-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "grplib-find-by-substring: Ошибка вычисления полного имени группы." + chr(10) + return-value.
            end.
            leave search-grp.
        end.
    end.
    if v-found = yes
    then do:
    end.
    else do:
        assign
            p-full-name  = ""
            p-found-code = 0
        .
    end.
end.
end procedure.
procedure grplib-analyze-grp-name :
do
on error undo, return error
:
define input parameter p-grp-name       as character            no-undo.
define input parameter p-upper-code     as integer              no-undo.
define output parameter p-error-message as character init ""    no-undo.
    define variable v-char-list     as character    no-undo.
    define variable v-char-counter  as integer      no-undo.
    define variable v-full-name     as character    no-undo.
    if p-grp-name = "" then do:
        assign
            p-error-message = "Название группы не может быть пустым.".
        .
    end.
    else do:
        assign
            v-char-list = "47,92,58,63,34,60,62,171,187,183"
        .
        do v-char-counter = 1 to num-entries( v-char-list )
        :
            if index( p-grp-name, chr( integer( entry( v-char-counter, v-char-list ) ) ) ) <> 0
            then do:
                assign
                    p-error-message = 'Название группы не может содержать символы /\:*?"<>|«»·'
                .
                return.
            end.
        end.
        if p-upper-code > 0
        then do:
            run grplib-get-full-name in this-procedure (
                  input p-upper-code
                , output v-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "grplib-analyze-grp-name: Не удалось вычислить полное имя группы." + chr(10) + return-value.
            end.
            if length( v-full-name ) + 1 + length( p-grp-name ) > 350
            then do:
                assign
                    p-error-message = 'Полное название группы не может содержать более 350 символов.'
                .
            end.
        end.
    end.
end.
end procedure.
procedure grplib-get-lvl-num :
define input parameter p-node-code  as integer      no-undo.
define output parameter p-lvl-num   as integer      no-undo.
    define variable v-full-name    as character    no-undo.
do
on error undo, return error
:
    run grplib-get-full-name in this-procedure (
          input p-node-code
        , output v-full-name
    ).
    assign
        p-lvl-num = num-entries( v-full-name, chr(47) ) - 1
    .
    if p-lvl-num = -1
    then do:
        assign
            p-lvl-num = 0
        .
    end.
end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable destin_ like ub.goods.destin no-undo init ?.
define variable attrib_ like ub.goods.attrib no-undo init ?.
define variable user-rule_ like ub.goods.user-rule no-undo init ?.
define variable sert_ like ub.goods.sert no-undo init ?.
define variable struct_ like ub.goods.struct no-undo init ?.
define variable deadline_ like ub.goods.deadline no-undo init ?.
define variable sort_       like ub.goods.sort no-undo init ?.
define variable nationality_       like ub.goods.nationality no-undo init ?.
define variable tnved_       like ub.goods.tnved no-undo init ?.
define variable unit-cst_       like ub.goods.unit-cst no-undo init ?.
define variable cst-base-rate_       like ub.goods.cst-base-rate no-undo init ?.
define variable normal-wastage_ like ub.goods.normal-wastage no-undo init ?.
define variable normal-waste_ like ub.goods.normal-waste no-undo init ?.
define variable cond-keep-code_       like ub.goods.cond-keep-code no-undo init ?.
define variable proof_       like ub.goods.proof no-undo init ?.
define variable glog as logical no-undo .
DEFINE BUTTON add-inf
     LABEL "Доп.инф."
     SIZE 10 BY 1.
DEFINE BUTTON B-add-tt-tax
     LABEL "Налог+"
     SIZE 7.6 BY 1.
DEFINE BUTTON B-del-tt-tax
     LABEL "Налог-"
     SIZE 7.6 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1.
DEFINE BUTTON B-grp
     LABEL "&Группа"
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.
DEFINE BUTTON b-list
     LABEL "Список":L
     SIZE 10 BY 1.
DEFINE BUTTON b-prt
     LABEL "Шкала"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE BUTTON r-alpha1
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.8 BY .93.
DEFINE BUTTON r-base
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.8 BY .93.
DEFINE VARIABLE EDITOR-1 AS CHARACTER INITIAL "Для начала редактирования нажмите левой кнопкой мыши на ~"замке~" соответствующего поля, для отказа от редактирования нажмите правой кнопкой мыши на самом поле"
     VIEW-AS EDITOR LARGE NO-BOX
     SIZE 97.4 BY 1.5
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE PS AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 28.4 BY 2.83
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE alpha1 AS CHARACTER FORMAT "X(2)":U
     VIEW-AS FILL-IN
     SIZE 4.5 BY 1 NO-UNDO.
DEFINE VARIABLE chk-name AS CHARACTER FORMAT "X(25)":U
     VIEW-AS FILL-IN
     SIZE 34.6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE cli-base-rate AS DECIMAL FORMAT ">>,>>9.9999999999":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 19 BY 1 NO-UNDO.
DEFINE VARIABLE country_name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 25.9 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE engl-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 35.8 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U INITIAL "Шкала:"
      VIEW-AS TEXT
     SIZE 6.8 BY .67
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE gds-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 75.5 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE grp-full AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 51.3 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE increase-pc AS DECIMAL FORMAT "->>9.99%":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 6.9 BY 1 NO-UNDO.
DEFINE VARIABLE label-name AS CHARACTER FORMAT "X(80)":U
     VIEW-AS FILL-IN
     SIZE 75.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE max-rate AS DECIMAL FORMAT ">,>>9.9<<":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 11.8 BY 1 NO-UNDO.
DEFINE VARIABLE min-rate AS DECIMAL FORMAT ">,>>9.9<<":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 11.3 BY 1 NO-UNDO.
DEFINE VARIABLE ms-base AS DECIMAL FORMAT ">>,>>9.9<<":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE VARIABLE ms-cart AS DECIMAL FORMAT ">>,>>9.9<<":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE VARIABLE n-alpha1 AS CHARACTER FORMAT "X(256)":U INITIAL "Страна"
      VIEW-AS TEXT
     SIZE 7.6 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-chk-name AS CHARACTER FORMAT "X(80)":U INITIAL "На  чеке"
      VIEW-AS TEXT
     SIZE 10.8 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-cli-base-rate AS CHARACTER FORMAT "X(256)":U INITIAL "Коэф."
      VIEW-AS TEXT
     SIZE 5.3 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-engl-name AS CHARACTER FORMAT "X(256)":U INITIAL "Англ.назв."
      VIEW-AS TEXT
     SIZE 10.8 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-gds-name AS CHARACTER FORMAT "X(256)":U INITIAL "Название"
      VIEW-AS TEXT
     SIZE 9.6 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-grp-full AS CHARACTER FORMAT "X(256)":U INITIAL "Группа:"
      VIEW-AS TEXT
     SIZE 6.9 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-increase-pc AS CHARACTER FORMAT "X(256)":U INITIAL "Наценка:"
      VIEW-AS TEXT
     SIZE 9.1 BY 1 NO-UNDO.
DEFINE VARIABLE n-label-name AS CHARACTER FORMAT "X(80)":U INITIAL "Этикетка"
      VIEW-AS TEXT
     SIZE 10.8 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-max-rate AS CHARACTER FORMAT "X(256)":U INITIAL "Max кол в штуке"
      VIEW-AS TEXT
     SIZE 15.1 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-min-rate AS CHARACTER FORMAT "X(256)":U INITIAL "Min кол в штуке"
      VIEW-AS TEXT
     SIZE 14.8 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-ms-base AS CHARACTER FORMAT "X(256)":U INITIAL "Объем шт."
      VIEW-AS TEXT
     SIZE 10.8 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-ms-cart AS CHARACTER FORMAT "X(256)":U INITIAL "Объем уп."
      VIEW-AS TEXT
     SIZE 10.8 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-okdp AS CHARACTER FORMAT "X(256)":U INITIAL "ОКДП"
      VIEW-AS TEXT
     SIZE 5.6 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-PS AS CHARACTER FORMAT "X(256)":U INITIAL "Прим."
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-qnty-cart AS CHARACTER FORMAT "X(256)":U INITIAL "Кол. в уп."
      VIEW-AS TEXT
     SIZE 10.8 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-unit-cli AS CHARACTER FORMAT "X(256)":U INITIAL "Ед. пост-ка"
      VIEW-AS TEXT
     SIZE 11.6 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-wt-base AS CHARACTER FORMAT "X(256)":U INITIAL "Вес шт."
      VIEW-AS TEXT
     SIZE 10.8 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-wt-cart AS CHARACTER FORMAT "X(256)":U INITIAL "Вес уп."
      VIEW-AS TEXT
     SIZE 10.8 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE OKDP AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 8.3 BY 1 NO-UNDO.
DEFINE VARIABLE qnty-cart AS DECIMAL FORMAT ">,>>9.9<<":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE VARIABLE unit-cli AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 6.4 BY 1 NO-UNDO.
DEFINE VARIABLE wt-base AS DECIMAL FORMAT ">>,>>9.9<<":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE VARIABLE wt-cart AS DECIMAL FORMAT ">>,>>9.9<<":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE IMAGE l-alpha1
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-calc-method
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-chk-name
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-cli-base-rate
     FILENAME "adeicon\lock":U
     SIZE 2.1 BY .93.
DEFINE IMAGE l-engl-name
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-gds-name
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-grp-full
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-increase-pc
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-label-name
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-max-rate
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-min-rate
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-ms-base
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-ms-cart
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-negative-rest
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-node-name
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-okdp
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-PS
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-qnty-cart
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-stts
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-tt-tax
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-unit-cli
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-wt-base
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE IMAGE l-wt-cart
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
DEFINE VARIABLE v-calc-method AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     LIST-ITEMS "1,2"
     SIZE 15.3 BY 2.97 NO-UNDO.
DEFINE VARIABLE negative-rest AS LOGICAL INITIAL no
     LABEL "Отрицательные остатки"
     VIEW-AS TOGGLE-BOX
     SIZE 31.4 BY .77
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE stts AS LOGICAL INITIAL no
     LABEL "Удаленный товар?"
     VIEW-AS TOGGLE-BOX
     SIZE 31.4 BY .77
     FGCOLOR 15  NO-UNDO.
DEFINE QUERY BR-tt-tax FOR
      tt-tax SCROLLING.
DEFINE BROWSE BR-tt-tax
  QUERY BR-tt-tax DISPLAY
      tt-tax.tax-code
      tt-tax.tax-name
      tt-tax.tax-type
      tt-tax.rate-code
      tt-tax.rate-name
      tt-tax.rate-value
    WITH NO-ROW-MARKERS SIZE 58.6 BY 6.3
         TITLE "Ставки налогов".
DEFINE FRAME u-gds-form
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-list AT ROW 1 COL 31
     B-grp AT ROW 1 COL 41
     b-prt AT ROW 1 COL 51
     b-help AT ROW 1 COL 71
     add-inf AT ROW 2 COL 71
     gds-name AT ROW 5.3 COL 15.3 COLON-ALIGNED NO-LABEL
     alpha1 AT ROW 6.3 COL 62.4 COLON-ALIGNED NO-LABEL
     r-alpha1 AT ROW 6.33 COL 69.8
     engl-name AT ROW 6.37 COL 15.4 COLON-ALIGNED NO-LABEL
     label-name AT ROW 7.53 COL 15.5 COLON-ALIGNED NO-LABEL
     chk-name AT ROW 8.53 COL 15.5 COLON-ALIGNED NO-LABEL
     OKDP AT ROW 8.57 COL 69.8 COLON-ALIGNED NO-LABEL
     ms-base AT ROW 9.8 COL 58.8 COLON-ALIGNED NO-LABEL
     unit-cli AT ROW 9.87 COL 14.8 COLON-ALIGNED NO-LABEL
     r-base AT ROW 9.93 COL 24
     v-calc-method AT ROW 10.2 COL 71.4 NO-LABEL
     wt-base AT ROW 10.7 COL 58.8 COLON-ALIGNED NO-LABEL
     min-rate AT ROW 11.13 COL 31.5 COLON-ALIGNED NO-LABEL
     cli-base-rate AT ROW 11.17 COL 6.9 COLON-ALIGNED NO-LABEL
     ms-cart AT ROW 11.7 COL 58.8 COLON-ALIGNED NO-LABEL
     qnty-cart AT ROW 12.47 COL 16.7 COLON-ALIGNED NO-LABEL
     increase-pc AT ROW 12.5 COL 89.6 COLON-ALIGNED NO-LABEL
     wt-cart AT ROW 12.7 COL 58.8 COLON-ALIGNED NO-LABEL
     max-rate AT ROW 13.47 COL 31.1 COLON-ALIGNED NO-LABEL
     B-add-tt-tax AT ROW 13.83 COL 7.8
     B-del-tt-tax AT ROW 13.83 COL 16.9
     PS AT ROW 14.03 COL 68.4 NO-LABEL
     BR-tt-tax AT ROW 14.97 COL 2.5
     negative-rest AT ROW 18.27 COL 65.3
     stts AT ROW 19.3 COL 65.5
     EDITOR-1 AT ROW 21.27 COL 1.8 NO-LABEL
     n-grp-full AT ROW 3.07 COL 32.4 COLON-ALIGNED NO-LABEL
     grp-full AT ROW 3.07 COL 40.1 COLON-ALIGNED NO-LABEL
     FILL-IN-4 AT ROW 4.2 COL 32.8 COLON-ALIGNED NO-LABEL
     ub.gds-prt.node-name AT ROW 4.2 COL 40 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 51.3 BY 1
          BGCOLOR 3 FGCOLOR 15
     n-gds-name AT ROW 5.3 COL 5.3 COLON-ALIGNED NO-LABEL
     n-engl-name AT ROW 6.33 COL 4.4 COLON-ALIGNED NO-LABEL
     country_name AT ROW 6.33 COL 71 COLON-ALIGNED NO-LABEL
     n-alpha1 AT ROW 6.37 COL 54.6 COLON-ALIGNED NO-LABEL
     n-label-name AT ROW 7.53 COL 4.5 COLON-ALIGNED NO-LABEL
     n-chk-name AT ROW 8.63 COL 4.4 COLON-ALIGNED NO-LABEL
     n-okdp AT ROW 8.63 COL 64.9 NO-LABEL
     n-ms-base AT ROW 9.77 COL 47.5 COLON-ALIGNED NO-LABEL
     n-unit-cli AT ROW 9.93 COL 2.6 COLON-ALIGNED NO-LABEL
     n-min-rate AT ROW 10 COL 27.9 COLON-ALIGNED NO-LABEL
     n-wt-base AT ROW 10.7 COL 47.4 COLON-ALIGNED NO-LABEL
     n-increase-pc AT ROW 11.03 COL 87.8 COLON-ALIGNED NO-LABEL
     n-cli-base-rate AT ROW 11.13 COL 1.5 COLON-ALIGNED NO-LABEL
     n-ms-cart AT ROW 11.77 COL 47.5 COLON-ALIGNED NO-LABEL
     n-max-rate AT ROW 12.33 COL 27.8 COLON-ALIGNED NO-LABEL
     n-qnty-cart AT ROW 12.47 COL 5.4 COLON-ALIGNED NO-LABEL
     n-wt-cart AT ROW 12.7 COL 47.4 COLON-ALIGNED NO-LABEL
     n-PS AT ROW 15.27 COL 61.9 NO-LABEL
     l-negative-rest AT ROW 18.17 COL 62.1
     l-grp-full AT ROW 3.13 COL 31.4
     l-okdp AT ROW 8.7 COL 62.5
     l-max-rate AT ROW 13.53 COL 29.8
     l-tt-tax AT ROW 13.93 COL 3
     l-PS AT ROW 14.07 COL 64.5
     l-gds-name AT ROW 5.33 COL 3.1
     l-engl-name AT ROW 6.33 COL 3
     l-alpha1 AT ROW 6.43 COL 53.1
     l-wt-cart AT ROW 13.07 COL 46.5
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON b-list CANCEL-BUTTON b-quit.
DEFINE FRAME u-gds-form
     l-cli-base-rate AT ROW 11 COL 1.8
     l-ms-cart AT ROW 12.07 COL 46.5
     l-min-rate AT ROW 11.13 COL 30.1
     l-unit-cli AT ROW 10 COL 1.8
     l-qnty-cart AT ROW 12.53 COL 4.5
     l-calc-method AT ROW 10 COL 87.4
     l-increase-pc AT ROW 9.93 COL 96.4
     l-node-name AT ROW 4.07 COL 31.5
     l-stts AT ROW 19.13 COL 62.1
     l-chk-name AT ROW 8.63 COL 3
     l-label-name AT ROW 7.53 COL 3.1
     l-wt-base AT ROW 11.07 COL 46.5
     l-ms-base AT ROW 10.07 COL 46.5
     SPACE(50.36) SKIP(11.77)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Введите данные для пакетной обработки по списку товаров"
         DEFAULT-BUTTON b-list CANCEL-BUTTON b-quit.
ASSIGN
       FRAME u-gds-form:SCROLLABLE       = FALSE
       FRAME u-gds-form:HIDDEN           = TRUE.
ASSIGN
       EDITOR-1:RETURN-INSERTED IN FRAME u-gds-form  = TRUE
       EDITOR-1:READ-ONLY IN FRAME u-gds-form        = TRUE.
ON WINDOW-CLOSE OF FRAME u-gds-form
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF add-inf IN FRAME u-gds-form
DO:
      run utl/pu51121.w (
                     input parparentproc
                    ,input v-cntxt-obj-type
                    ,input v-cntxt-obj-code
                    ,output destin_
                    ,output attrib_
                    ,output user-rule_
                    ,output sert_
                    ,output struct_
                    ,output deadline_
                    ,output sort_
                    ,output nationality_
                    ,output tnved_
                    ,output unit-cst_
                    ,output cst-base-rate_
                    ,output normal-wastage_
                    ,output normal-waste_
                    ,output cond-keep-code_
                    ,output proof_).
END.
ON LEAVE OF alpha1 IN FRAME u-gds-form
DO:
    APPLY "RETURN" to alpha1.
END.
ON RETURN OF alpha1 IN FRAME u-gds-form
DO:
 define variable v-rid-list as character no-undo .
    FIND FIRST country where
                        country.alpha1 = input frame u-gds-form alpha1 No-LOCK No-ERROR.
IF NOT AVAIL country then do:
            run ref/countris.w (
                            input parparentproc
                           ,input "b-sel"
                  ,input-output v-rid-list ).
  if v-rid-list = "" then do:
                    apply "entry" to alpha1 in frame u-gds-form.
                    return no-apply.
                end.
            FIND country WHERE recid (country) = integer(v-rid-list) NO-LOCK.
            DISPLAY
            country.alpha1 @ alpha1
            country.short-name @ country_name
            with frame u-gds-form.
    end.
    else do:
        assign
        country_name = country.short-name.
        display country_name with frame u-gds-form.
    end.
END.
ON RIGHT-MOUSE-CLICK OF alpha1 IN FRAME u-gds-form
DO:
    assign
    l-alpha1:fgcolor = 15
    alpha1 = ""
    l-alpha1:visible = true
    country_name = "".
    display alpha1 country_name with frame u-gds-form.
    disable alpha1 with frame u-gds-form.
    disable r-alpha1 with frame u-gds-form.
END.
ON CHOOSE OF B-add-tt-tax IN FRAME u-gds-form
DO:
DEFINE var tax-rate-rid As char NO-UNDO init "".
DEFINE var taxvalue like ub.tax-rate-value.rate-value NO-UNDO.
DEFINE buffer bf-tt-tax for tt-tax.
  run ref/tax-tree.w (
                   input parparentproc
                  ,input "b-seltax-rate":U
                  ,input "ALL-TAX-RATES":U
                  ,input v-cntxt-host-code-obj
                  ,input v-cntxt-obj-type
                  ,input v-cntxt-obj-code
                  ,input ?
                  ,input-output tax-rate-rid) no-error .
  IF ERROR-STATUS:error then return no-apply.
  if tax-rate-rid <> "" then do:
    FIND FIRST ub.tax-rate NO-LOCK WHERE recid(ub.tax-rate) = integer(tax-rate-rid) NO-ERROR.
    if NOT AVAIL ub.tax-rate then return no-apply.
    FIND first bf-tt-tax No-LOCK WHERE
                                   bf-tt-tax.tax-code = ub.tax-rate.tax-code NO-ERROR.
    IF avail bf-tt-tax then do:
        message "В списке ставок налогов уже есть ставка по такому налогу!" view-as
        alert-box ERROR.
        return no-apply.
    end.
    FIND FIRST ub.tax NO-LOCK WHERE ub.tax.tax-code = ub.tax-rate.tax-code NO-ERROR.
    if NOT AVAIL ub.tax then return no-apply.
    if ub.tax.individual then do:
        message "Нельзя редактировать налоги на товар, если налог индивидуальный!"
        view-as alert-box ERROR.
        return no-apply.
    end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  ?
  ,input  ub.tax-rate.tax-code
  ,input  ub.tax-rate.rate-code
  ,input  ?
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output taxvalue
  ) no-error .
    if error-status:error or taxvalue = ? then return no-apply.
    create
    tt-tax.
    assign
    tt-tax.tax-code = ub.tax.tax-code
    tt-tax.tax-name = ub.tax.tax-name
    tt-tax.rate-code = ub.tax-rate.rate-code
    tt-tax.rate-name = ub.tax-rate.rate-name
    tt-tax.tax-type = ub.tax.tax-type
    tt-tax.rate-value = taxvalue
    tt-tax.tax-rate-gds-rc = ?
    .
    OPEN QUERY br-tt-tax for each tt-tax NO-LOCK.
  end.
END.
ON CHOOSE OF B-del-tt-tax IN FRAME u-gds-form
DO:
    DEFINE BUFFER bf-tt-tax for tt-tax.
    IF AVAIL tt-tax then do:
        FIND FIRST bf-tt-tax WHERE bf-tt-tax.tax-code = tt-tax.tax-code NO-ERROR.
        if avail bf-tt-tax then delete bf-tt-tax.
        OPEN QUERY BR-tt-tax for each tt-tax NO-LOCK.
    end.
END.
ON CHOOSE OF b-exit IN FRAME u-gds-form
DO:
  define variable v-parameter as character no-undo .
  define variable glog as logical no-undo .
  define variable mystr as char format "X(500)".
  DEFINE VARIABLE par-date as date no-undo .
  DEFINE VARIABLE v-today as date no-undo .
  DEFINE VARIABLE v-time as integer no-undo .
  DEFINE VARIABLE var-fact-order like ub.tax-rate-value.fact-order no-undo .
  define buffer cli-units for ub.units.
  if NOT can-find(first gds-list) then do:
    BELL.
    message "В списке товаров нет ни одного товара!" view-as alert-box WARNING.
    return no-apply.
  end.
  assign
  v-calc-method cli-base-rate engl-name label-name chk-name gds-name grp-full increase-pc
  ms-base wt-base ms-cart negative-rest OKDP PS min-rate max-rate qnty-cart stts unit-cli wt-cart
  alpha1
  .
  IF cli-base-rate:sensitive and cli-base-rate <> 1 then do:
    message "ВНИМАНИЕ!" skip
    "Для товаров, у которых базовая ед.изм. совпадает с ед.изм.поставщика,"
    "изменения будут отклонены (задан коэф. не равный 1)!" view-as alert-box
    WARNING.
  end.
  IF unit-cli:sensitive then do:
    FIND FIRST cli-units No-LOCK WHERE cli-units.unit-name = unit-cli No-ERROR.
    if LOOKUP('топ':U, cli-units.type) > 0 then
    message "ВНИМАНИЕ!" skip
    "Для товаров, у которых ед.изм.поставщика имеет топливный тип, а  базовая ед.изм. нет,"
    "изменения будут отклонены!" view-as alert-box
    WARNING.
    else
    message "ВНИМАНИЕ!" skip
    "Для товаров, у которых базовая ед.изм. имеет топливный тип, а ед.изм.поставщика нет,"
    "изменения будут отклонены!" view-as alert-box
    WARNING.
  end.
  IF br-tt-tax:sensitive then do:
    message "ВНИМАНИЕ!" skip
    "Для товаров, у которых тип базовой ед.изм. не включен в список типов базовых ед.изм.," skip
    "для которых определен налог, изменения списка ставок налогов по товару" skip
    "                             будут отклонены!" view-as alert-box
    WARNING.
    run gbl/d-prompt.w (
      'title=':u + "Введите дату, с которой начнут действовать новые ставки налогов" + '\':u
    + 'text1=':u + " ДАТА" + '\':u
    + 'format=' + "99/99/9999" + '\':u
    + 'type=' + 'T':U + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=12\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u
    + 'readonly=no\':u
    , input-output par-date
    ).
    if return-value = 'false':u then do:
            return no-apply.
        end.
    run cur-time in this-procedure ( output v-today, output v-time).
    run factord-end-day in this-procedure ( input (if par-date = ? then v-today else par-date) , output var-fact-order).
  end.
  IF min-rate:sensitive OR max-rate:sensitive then do:
    message "ВНИМАНИЕ!" skip
    "Для товаров у которых тип базовой ед.изм. не " '2ед':U "," skip
    "изменения Min или MAx количества в штуке будут отклонены!"
    view-as alert-box WARNING.
  END.
  mystr =   (IF gds-name:sensitive then ("НАЗВАНИЕ="+ gds-name + chr(10) ) else "") +
  (IF engl-name:sensitive then ("АНГЛ.НАЗВАНИЕ=" + engl-name + chr(10) ) else "") +
  (IF label-name:sensitive then ("ЭТИКЕТКА=" + label-name + chr(10) ) else "") +
  (IF chk-name:sensitive then ("НА ЧЕКЕ=" + chk-name + chr(10) ) else "") +
  (IF unit-cli:sensitive then ("Един. изм. пост-ка=" + unit-cli + chr(10) ) else "") +
  (IF cli-base-rate:sensitive then ("Коэффициент к ед. изм. пост-ка=" + string(cli-base-rate)
                                          + chr(10) ) else "") +
  (IF okdp:sensitive then ("ОКДП=" + okdp + chr(10) ) else "") +
  (IF v-calc-method:sensitive then ("Расчет цены по=" + v-calc-method + chr(10) ) else "") +
  (IF increase-pc:sensitive then ("Наценка=" + string(increase-pc) + chr(10) ) else "") +
  (IF negative-rest:sensitive then ("Отриц.остатки разрешены - " + string(negative-rest,"да/нет") + chr(10) )
                                                else "") +
  (IF stts:sensitive then ("Товар удален - " + string(stts,"да/нет") + chr(10) ) else "") +
  (IF min-rate:sensitive then ("Min кол-во в штуке=" + string(min-rate) + chr(10) ) else "") +
  (IF max-rate:sensitive then ("Max кол-во в штуке=" + string(max-rate) + chr(10) ) else "") +
  (IF qnty-cart:sensitive then ("Кол-во в упаковке=" + string(qnty-cart) + chr(10) ) else "") +
  (IF ms-base:sensitive then ("Объем штуки=" + string(ms-base) + chr(10) ) else "") +
  (IF wt-base:sensitive then ("Вес штуки=" + string(wt-base) + chr(10) ) else "") +
  (IF ms-cart:sensitive then ("Объем упаковки=" + string(ms-cart) + chr(10) ) else "") +
  (IF wt-cart:sensitive then ("Вес упаковки=" + string(wt-cart) + chr(10) ) else "") +
  (IF PS:sensitive then ("Примечание=" + PS + chr(10) ) else "") +
  (IF destin_ <> ? then ("Назначение=" + destin_ + chr(10) ) else "") +
  (IF attrib_ <> ? then ("Характеристики=" + attrib_ + chr(10) ) else "") +
  (IF sert_ <> ? then ("Сертификат=" + sert_ + chr(10)) else "") +
  (IF sort_ <> ? then ("Сорт=" + sort_ + chr(10)) else "") +
  (IF normal-wastage_ <> ? then ("Норма ест.убыли=" + string(normal-wastage_, "->9.99%") + chr(10)) else "") +
  (IF normal-waste_ <> ? then ("Норма отходов=" + string(normal-waste_, "->9.99%") + chr(10)) else "") +
  (IF cond-keep-code_ <> ? then ("Код услов.хран.=" + string(cond-keep-code_) + chr(10)) else "") +
  (IF proof_ <> ? then ("Алкоголь %=" + string(proof_) + chr(10)) else "") +
  (IF Struct_ <> ? then ("Состав(комплектность)=" + struct_ + chr(10)) else "") +
  (IF user-rule_ <> ? then ("Правила эксплуатации=" + user-rule_ + chr(10)) else "") +
  (IF Deadline_ <> ? then ("Срок годности=" + string(deadline_) + chr(10)) else "") +
  (IF tnved_ <> ? then ("Код ТНВЭД=" + tnved_ + chr(10)) else "") +
  (IF unit-cst_ <> ? then ("Тамож. ед-ца изм.=" + unit-cst_ + chr(10)) else "") +
  (IF cst-base-rate_ <> ? then ("Коэффициент к тамож.ед=" + string(cst-base-rate_)
                                                             + chr(10)) else "") +
  (IF nationality_ <> ? then ("Статус товара(национальность)=" + nationality_ + chr(10)) else "") +
  (IF alpha1:sensitive then ("Страна изготовления=" + alpha1 + chr(10)) else "").
  IF br-tt-tax:sensitive then do:
    for each tt-tax:
        mystr = mystr + chr(10) + "Ставка налога " + string(tt-tax.rate-code)
                + " текущее значение ставки " + string(tt-tax.rate-value).
    end.
  end.
  if REPLACE(mystr, chr(10), "")  = "" then do:
    message "Не выбраны поля и значения для внесения изменений" view-as alert-box
    Warning.
    return no-apply.
  end.
  message "В выбранных товарах будут произведены следующие изменения:" skip
  mystr skip "Продолжать?"
  view-as alert-box QUESTION buttons YES-NO update glog.
  IF not glog then return no-apply.
  assign
  v-parameter = "gdsuform":U + chr(1) +
                "":U + chr(1) +
              v-cntxt-obj-type                                                                                    + chr(4) +
              string(v-cntxt-obj-code)                                                                            + chr(4) +
              string(var-fact-order)                                                                              + chr(4) +
              (IF gds-name:sensitive then gds-name else "":U)                                                     + chr(4) +
              (IF engl-name:sensitive then engl-name else "":U)                                                   + chr(4) +
              (IF label-name:sensitive then label-name else "":U)                                                 + chr(4) +
              (IF chk-name:sensitive then chk-name else "":U)                                                     + chr(4) +
              (IF alpha1:sensitive then alpha1 else "":U)                                                         + chr(4) +
              (IF unit-cli:sensitive then unit-cli else "":U)                                                     + chr(4) +
              (IF max-rate:sensitive      then string(max-rate)  else "")                                         + chr(4) +
              (IF min-rate:sensitive      then string(min-rate)  else "")                                         + chr(4) +
              (IF cli-base-rate:sensitive then string(cli-base-rate) else "")                                     + chr(4) +
              (IF qnty-cart:sensitive     then string(qnty-cart) else "")                                         + chr(4) +
              (IF ms-base:sensitive       then string(ms-base) else "")                                           + chr(4) +
              (IF wt-base:sensitive       then string(wt-base) else "")                                           + chr(4) +
              (IF ms-cart:sensitive       then string(ms-cart) else "")                                           + chr(4) +
              (IF wt-cart:sensitive       then string(wt-cart) else "")                                           + chr(4) +
              (IF v-calc-method:sensitive then v-calc-method   else "")                                           + chr(4) +
              (IF increase-pc:sensitive   then string(increase-pc) else "")                                       + chr(4) +
              (IF negative-rest:sensitive then string(negative-rest) else "")                                     + chr(4) +
              (IF okdp:sensitive          then okdp else "")                                                      + chr(4) +
              (IF destin_ <> ?            then destin_ else "")                                                   + chr(4) +
              (IF attrib_ <> ?            then attrib_ else "")                                                   + chr(4) +
              (IF user-rule_<> ?          then user-rule_ else "")                                                + chr(4) +
              (IF sert_ <> ?              then sert_ else "")                                                     + chr(4) +
              (IF struct_<> ?             then struct_ else "")                                                   + chr(4) +
              (IF deadline_ <> ?          then string(deadline_) else "")                                         + chr(4) +
              (IF cond-keep-code_ <> ?    then string(cond-keep-code_) else "")                                   + chr(4) +
              (IF sort_ <> ?              then sort_ else "")                                                     + chr(4) +
              (IF proof_ <> ?             then string(proof_) else "")                                            + chr(4) +
              (IF normal-wastage_ <> ?    then string(normal-wastage_) else "")                                   + chr(4) +
              (IF normal-waste_ <> ?      then string(normal-waste_) else "")                                     + chr(4) +
              (IF tnved_ <> ?             then tnved_ else "")                                                    + chr(4) +
              (IF nationality_ <> ?       then nationality_ else "")                                              + chr(4) +
              (IF unit-cst_ <> ?          then unit-cst_ else "")                                                 + chr(4) +
              (IF cst-base-rate_ <> ?     then string(cst-base-rate_) else "")                                    + chr(4) +
              "":U                                                                                                + chr(4) +
              (IF ps:sensitive            then ps else "")                                                        + chr(4) +
              (IF br-tt-tax:sensitive     then string(par-date, "99/99/9999") else "":U)                          + chr(4) +
              (IF stts:sensitive          then string(stts) else "")
.
v-parameter = v-parameter + chr(1).
v-parameter = v-parameter +
              (IF gds-name:sensitive      then "yes" else "no":U)                                                 + chr(4) +
              (IF engl-name:sensitive     then "yes" else "no":U)                                                 + chr(4) +
              (IF label-name:sensitive    then "yes" else "no":U)                                                 + chr(4) +
              (IF chk-name:sensitive      then "yes" else "no":U)                                                 + chr(4) +
              (IF alpha1:sensitive        then "yes" else "no":U)                                                 + chr(4) +
              (IF unit-cli:sensitive      then "yes" else "no":U)                                                 + chr(4) +
              (IF max-rate:sensitive      then "yes" else "no":U)                                                 + chr(4) +
              (IF min-rate:sensitive      then "yes" else "no":U)                                                 + chr(4) +
              (IF cli-base-rate:sensitive then "yes" else "no":U)                                                 + chr(4) +
              (IF qnty-cart:sensitive     then "yes" else "no":U)                                                 + chr(4) +
              (IF ms-base:sensitive       then "yes" else "no":U)                                                 + chr(4) +
              (IF wt-base:sensitive       then "yes" else "no":U)                                                 + chr(4) +
              (IF ms-cart:sensitive       then "yes" else "no":U)                                                 + chr(4) +
              (IF wt-cart:sensitive       then "yes" else "no":U)                                                 + chr(4) +
              (IF v-calc-method:sensitive then "yes" else "no":U)                                                 + chr(4) +
              (IF increase-pc:sensitive   then "yes" else "no":U)                                                 + chr(4) +
              (IF negative-rest:sensitive then "yes" else "no":U)                                                 + chr(4) +
              (IF okdp:sensitive          then "yes" else "no":U)                                                 + chr(4) +
              (IF destin_ <> ?            then "yes" else "no":U)                                                 + chr(4) +
              (IF attrib_ <> ?            then "yes" else "no":U)                                                 + chr(4) +
              (IF user-rule_ <> ?         then "yes" else "no":U)                                                 + chr(4) +
              (IF sert_ <> ?              then "yes" else "no":U)                                                 + chr(4) +
              (IF struct_ <> ?            then "yes" else "no":U)                                                 + chr(4) +
              (IF deadline_ <> ?          then "yes" else "no":U)                                                 + chr(4) +
              (IF cond-keep-code_ <> ?    then "yes" else "no":U)                                                 + chr(4) +
              (IF sort_ <> ?              then "yes" else "no":U)                                                 + chr(4) +
              (IF proof_ <> ?             then "yes" else "no":U)                                                 + chr(4) +
              (IF normal-wastage_ <> ?    then "yes" else "no":U)                                                 + chr(4) +
              (IF normal-waste_ <> ?      then "yes" else "no":U)                                                 + chr(4) +
              (IF tnved_ <> ?             then "yes" else "no":U)                                                 + chr(4) +
              (IF nationality_ <> ?       then "yes" else "no":U)                                                 + chr(4) +
              (IF unit-cst_ <> ?          then "yes" else "no":U)                                                 + chr(4) +
              (IF cst-base-rate_ <> ?     then "yes" else "no":U)                                                 + chr(4) +
              "no":U                                                                                              + chr(4) +
              (IF ps:sensitive            then "yes" else "no":U)                                                 + chr(4) +
              (IF stts:sensitive          then "yes" else "no":U)                                                 + chr(4) +
              (IF br-tt-tax:sensitive     then "yes" else "no":U)
 .
  run str/diallog.w (
                input parparentproc
              , input this-procedure
              , input 'utl/goods01r.p':U
              , input v-parameter
              , input no
              , input "&Стоп"
              , input 'Изменение товаров по списку') .
END.
ON CHOOSE OF B-grp IN FRAME u-gds-form
DO:
define variable v-grp as character no-undo .
define variable glog as logical no-undo .
    glog = yes.
    message "Выберите группу, в которую нужно переместить товары списка."
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
       return no-apply.
    end.
    run ref/gds-grp.w (
                   input parparentproc
                  ,input ('терм':U + ',b-sel')
                  ,input v-cntxt-obj-type
                  ,input v-cntxt-obj-code
                  ,input-output v-grp ).
    if v-grp = "" then do:
       return no-apply.
    end.
    FIND ub.gds-grp WHERE recid (ub.gds-grp) = integer (v-grp) .
    grp-full = "".
    RUN grplib-get-full-name in this-procedure
                                               ( input ub.gds-grp.node-code, output grp-full).
    DISPLAY grp-full with frame u-gds-form.
END.
ON CHOOSE OF b-list IN FRAME u-gds-form
DO:
    run str/gds-list.w (
                         input parparentproc
                       , input v-cntxt-host-code-obj
                       , input v-cntxt-obj-type
                       , input v-cntxt-obj-code) .
END.
ON CHOOSE OF b-prt IN FRAME u-gds-form
DO:
define variable glog as logical no-undo .
define variable ref-rec as recid no-undo .
    message "Выберите шкалу, которую надо приписать товарам списка."
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
       return no-apply.
    end.
   run ref/gdsprts.w (
                       input parparentproc
                      ,input yes
                      ,output ref-rec).
   if ref-rec = ? then do:
      return no-apply.
   end.
   FIND ub.gds-prt WHERE recid (ub.gds-prt) = ref-rec.
   DISPLAY ub.gds-prt.node-name with frame u-gds-form.
END.
ON CHOOSE OF b-quit IN FRAME u-gds-form
DO:
define variable glog as logical no-undo .
    IF can-find( first gds-list) then do:
        message "Вы действительно хотите выйти (список товаров при этом сохранен не будет)?"
        view-as alert-box WARNING buttons YES-NO update glog.
        if not glog then return no-apply.
    end.
END.
ON RIGHT-MOUSE-CLICK OF BR-tt-tax IN FRAME u-gds-form
DO:
    for each tt-tax:
        delete tt-tax.
    end.
    OPEN QUERY br-tt-tax for each tt-tax.
    assign
    l-tt-tax:visible = true.
    display BR-tt-tax with frame u-gds-form.
    disable
    b-add-tt-tax
    b-del-tt-tax
    br-tt-tax
    with frame u-gds-form.
END.
ON RIGHT-MOUSE-CLICK OF chk-name IN FRAME u-gds-form
DO:
    assign
    n-chk-NAME:fgcolor = 15
    chk-NAME = ""
    l-chk-NAME:visible = true.
    display chk-NAME with frame u-gds-form.
    disable chk-NAME with frame u-gds-form.
END.
ON RIGHT-MOUSE-CLICK OF cli-base-rate IN FRAME u-gds-form
DO:
    assign
    n-cli-base-rate:fgcolor = 15
    cli-base-rate = ?
    l-cli-base-rate:visible = true.
    display cli-base-rate with frame u-gds-form.
    disable cli-base-rate r-base with frame u-gds-form.
END.
ON RIGHT-MOUSE-CLICK OF engl-name IN FRAME u-gds-form
DO:
    assign
    n-ENGL-NAME:fgcolor = 15
    ENGL-NAME = ""
    l-ENGL-NAME:visible = true.
    display ENGL-NAME with frame u-gds-form.
    disable ENGL-NAME with frame u-gds-form.
END.
ON RIGHT-MOUSE-CLICK OF gds-name IN FRAME u-gds-form
DO:
    assign
    n-gds-name:fgcolor = 15
    gds-name = ""
    l-gds-name:visible = true.
    display gds-name with frame u-gds-form.
    disable gds-name with frame u-gds-form.
END.
ON RIGHT-MOUSE-CLICK OF increase-pc IN FRAME u-gds-form
DO:
    assign
    n-increase-pc:fgcolor = 15
    increase-pc = ?
    l-increase-pc:visible = true.
    display increase-pc with frame u-gds-form.
    disable increase-pc with frame u-gds-form.
END.
ON MOUSE-SELECT-CLICK OF l-alpha1 IN FRAME u-gds-form
DO:
   IF l-alpha1:visible then do:
    assign
    n-alpha1:fgcolor = ?
    l-alpha1:visible = false.
    enable alpha1 with frame u-gds-form.
    enable r-alpha1 with frame u-gds-form.
   end.
END.
ON MOUSE-SELECT-CLICK OF l-calc-method IN FRAME u-gds-form
DO:
  IF l-calc-method:visible then do:
    assign
    v-calc-method:fgcolor = ?
    l-calc-method:visible = false.
    enable v-calc-method with frame u-gds-form.
    APPLY "ENTRY" TO v-calc-method.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-chk-name IN FRAME u-gds-form
DO:
   IF l-chk-NAME:visible then do:
    assign
    n-chk-NAME:fgcolor = ?
    l-chk-NAME:visible = false.
    enable chk-NAME with frame u-gds-form.
    APPLY "ENTRY" TO chk-name.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-cli-base-rate IN FRAME u-gds-form
DO:
   IF l-cli-base-rate:visible then do:
    assign
    n-cli-base-rate:fgcolor = ?
    l-cli-base-rate:visible = false.
    enable cli-base-rate r-base with frame u-gds-form.
    APPLY "ENTRY" TO cli-base-rate.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-engl-name IN FRAME u-gds-form
DO:
   IF l-ENGL-NAME:visible then do:
    assign
    n-ENGL-NAME:fgcolor = ?
    l-ENGL-NAME:visible = false.
    enable ENGL-NAME with frame u-gds-form.
    APPLY "ENTRY" TO engl-name.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-gds-name IN FRAME u-gds-form
DO:
   IF l-gds-name:visible then do:
    assign
    n-gds-name:fgcolor = ?
    l-gds-name:visible = false.
    enable gds-name with frame u-gds-form.
    APPLY "ENTRY" TO gds-name.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-grp-full IN FRAME u-gds-form
DO:
  message "Редактирование этого поля в пакетном режиме еще не реализовано!"
  view-as alert-box.
END.
ON MOUSE-SELECT-CLICK OF l-increase-pc IN FRAME u-gds-form
DO:
   IF l-increase-pc:visible then do:
    assign
    n-increase-pc:fgcolor = ?
    l-increase-pc:visible = false.
    enable increase-pc with frame u-gds-form.
    APPLY "ENTRY" TO increase-pc.
  end.
END.
ON RIGHT-MOUSE-CLICK OF l-increase-pc IN FRAME u-gds-form
DO:
  IF l-increase-pc:visible then do:
    assign
    n-increase-pc:fgcolor = ?
    l-increase-pc:visible = false.
    enable increase-pc with frame u-gds-form.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-label-name IN FRAME u-gds-form
DO:
   IF l-label-NAME:visible then do:
    assign
    n-label-NAME:fgcolor = ?
    l-label-NAME:visible = false.
    enable label-NAME with frame u-gds-form.
    APPLY "ENTRY" TO label-name.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-max-rate IN FRAME u-gds-form
DO:
   IF l-max-rate:visible then do:
    assign
    n-max-rate:fgcolor = ?
    l-max-rate:visible = false.
    enable max-rate with frame u-gds-form.
    APPLY "ENTRY" TO max-rate.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-min-rate IN FRAME u-gds-form
DO:
   IF l-min-rate:visible then do:
    assign
    n-min-rate:fgcolor = ?
    l-min-rate:visible = false.
    enable min-rate with frame u-gds-form.
    APPLY "ENTRY" TO min-rate.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-ms-base IN FRAME u-gds-form
DO:
   IF l-ms-base:visible then do:
    assign
    n-ms-base:fgcolor = ?
    l-ms-base:visible = false.
    enable ms-base with frame u-gds-form.
    APPLY "ENTRY" TO ms-base.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-ms-cart IN FRAME u-gds-form
DO:
   IF l-ms-cart:visible then do:
    assign
    n-ms-cart:fgcolor = ?
    l-ms-cart:visible = false.
    enable ms-cart with frame u-gds-form.
    APPLY "ENTRY" TO ms-cart.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-negative-rest IN FRAME u-gds-form
DO:
   IF l-negative-rest:visible then do:
    assign
    negative-rest:fgcolor = ?
    l-negative-rest:visible = false.
    enable negative-rest with frame u-gds-form.
    APPLY "ENTRY" TO negative-rest.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-node-name IN FRAME u-gds-form
DO:
  message "Редактирование этого поля в пакетном режиме еще не реализовано!"
  view-as alert-box.
END.
ON MOUSE-SELECT-CLICK OF l-okdp IN FRAME u-gds-form
DO:
   IF l-okdp:visible then do:
    assign
    n-okdp:fgcolor = ?
    l-okdp:visible = false.
    enable okdp with frame u-gds-form.
    APPLY "ENTRY" TO okdp.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-PS IN FRAME u-gds-form
DO:
   IF l-PS:visible then do:
    assign
    n-PS:fgcolor = ?
    l-PS:visible = false.
    enable PS with frame u-gds-form.
    APPLY "ENTRY" TO ps.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-qnty-cart IN FRAME u-gds-form
DO:
   IF l-qnty-cart:visible then do:
    assign
    n-qnty-cart:fgcolor = ?
    l-qnty-cart:visible = false.
    enable qnty-cart with frame u-gds-form.
    APPLY "ENTRY" TO qnty-cart.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-stts IN FRAME u-gds-form
DO:
   IF l-stts:visible then do:
    assign
    stts:fgcolor = ?
    l-stts:visible = false.
    enable stts with frame u-gds-form.
    APPLY "ENTRY" TO stts.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-tt-tax IN FRAME u-gds-form
DO:
   IF l-tt-tax:visible then do:
    assign
    l-tt-tax:visible = false.
    enable
    br-tt-tax
    B-add-tt-tax
    b-del-tt-tax
    with frame u-gds-form.
    APPLY "ENTRY" TO browse br-tt-tax.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-unit-cli IN FRAME u-gds-form
DO:
   IF l-unit-cli:visible then do:
    assign
    n-unit-cli:fgcolor = ?
    l-unit-cli:visible = false.
    enable unit-cli with frame u-gds-form.
    enable r-base with frame u-gds-form.
    APPLY "ENTRY" TO unit-cli.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-wt-base IN FRAME u-gds-form
DO:
   IF l-wt-base:visible then do:
    assign
    n-wt-base:fgcolor = ?
    l-wt-base:visible = false.
    enable wt-base with frame u-gds-form.
    APPLY "ENTRY" TO wt-base.
   end.
END.
ON MOUSE-SELECT-CLICK OF l-wt-cart IN FRAME u-gds-form
DO:
   IF l-wt-cart:visible then do:
    assign
    n-wt-cart:fgcolor = ?
    l-wt-cart:visible = false.
    enable wt-cart with frame u-gds-form.
    APPLY "ENTRY" TO wt-cart.
   end.
END.
ON RIGHT-MOUSE-CLICK OF label-name IN FRAME u-gds-form
DO:
    assign
    n-label-NAME:fgcolor = 15
    label-NAME = ""
    l-label-NAME:visible = true.
    display label-NAME with frame u-gds-form.
    disable label-NAME with frame u-gds-form.
END.
ON RIGHT-MOUSE-CLICK OF max-rate IN FRAME u-gds-form
DO:
    assign
    n-max-rate:fgcolor = 15
    max-rate = ?
    l-max-rate:visible = true.
    display max-rate with frame u-gds-form.
    disable max-rate with frame u-gds-form.
END.
ON RIGHT-MOUSE-CLICK OF min-rate IN FRAME u-gds-form
DO:
    assign
    n-min-rate:fgcolor = 15
    min-rate = ?
    l-min-rate:visible = true.
    display min-rate with frame u-gds-form.
    disable min-rate with frame u-gds-form.
END.
ON RIGHT-MOUSE-CLICK OF ms-base IN FRAME u-gds-form
DO:
    assign
    n-ms-base:fgcolor = 15
    ms-base = ?
    l-ms-base:visible = true.
    display ms-base with frame u-gds-form.
    disable ms-base with frame u-gds-form.
END.
ON RIGHT-MOUSE-CLICK OF ms-cart IN FRAME u-gds-form
DO:
    assign
    n-ms-cart:fgcolor = 15
    ms-cart = ?
    l-ms-cart:visible = true.
    display ms-cart with frame u-gds-form.
    disable ms-cart with frame u-gds-form.
END.
ON RIGHT-MOUSE-CLICK OF negative-rest IN FRAME u-gds-form
DO:
     assign
    negative-rest:fgcolor = 15
    negative-rest = false
    l-negative-rest:visible = true.
    display negative-rest with frame u-gds-form.
    disable negative-rest with frame u-gds-form.
END.
ON RIGHT-MOUSE-CLICK OF OKDP IN FRAME u-gds-form
DO:
   assign
    n-okdp:fgcolor = 15
    okdp = ""
    l-okdp:visible = true.
    display okdp with frame u-gds-form.
    disable okdp with frame u-gds-form.
END.
ON RIGHT-MOUSE-CLICK OF PS IN FRAME u-gds-form
DO:
    assign
    n-PS:fgcolor = 15
    PS = ""
    l-PS:visible = true.
    display PS with frame u-gds-form.
    disable PS with frame u-gds-form.
END.
ON RIGHT-MOUSE-CLICK OF qnty-cart IN FRAME u-gds-form
DO:
    assign
    n-qnty-cart:fgcolor = 15
    qnty-cart = ?
    l-qnty-cart:visible = true.
    display qnty-cart with frame u-gds-form.
    disable qnty-cart with frame u-gds-form.
END.
ON CHOOSE OF r-alpha1 IN FRAME u-gds-form
DO:
define variable v-rid-list as character no-undo .
    run ref/countris.w (
                    input parparentproc
                   ,input "b-sel"
                ,input-output v-rid-list ).
if v-rid-list <> '' then do:
            apply "entry" to r-alpha1 in frame u-gds-form.
            return no-apply.
    end.
    FIND ub.country WHERE recid (ub.country) = integer(v-rid-list) NO-LOCK.
    DISPLAY ub.country.alpha1 @ alpha1
                    ub.country.short-name @ country_name with frame u-gds-form.
END.
ON CHOOSE OF r-base IN FRAME u-gds-form
DO:
define variable v-ref-rec as recid .
run ref/units.w ( input parparentproc
                , input yes
                , output v-ref-rec ).
if v-ref-rec = ? then do:
  apply "entry" to r-base in frame u-gds-form.
  return no-apply.
end.
FIND ub.units WHERE recid (ub.units) = v-ref-rec NO-LOCK.
DISPLAY ub.units.unit-name @ unit-cli with frame u-gds-form.
END.
ON RIGHT-MOUSE-CLICK OF stts IN FRAME u-gds-form
DO:
      assign
    stts:fgcolor = 15
    stts = false
    l-stts:visible = true.
    display stts with frame u-gds-form.
    disable stts with frame u-gds-form.
END.
ON LEAVE OF unit-cli IN FRAME u-gds-form
DO:
    APPLY "RETURN" to unit-cli.
END.
ON RETURN OF unit-cli IN FRAME u-gds-form
DO:
define variable ref-rec as recid no-undo .
  if not can-find( ub.units where
                            ub.units.unit-name = input frame u-gds-form unit-cli ) then do:
     run ref/units.w (
                       input parparentproc
                      ,input yes
                      ,output ref-rec ).
     if ref-rec = ? then   do:
                    apply "entry" to unit-cli in frame u-gds-form.
                    return no-apply.
      end.
      FIND ub.units WHERE recid (ub.units) = ref-rec NO-LOCK.
      DISPLAY ub.units.unit-name @ unit-cli with frame u-gds-form.
  end.
END.
ON RIGHT-MOUSE-CLICK OF unit-cli IN FRAME u-gds-form
DO:
    assign
    n-unit-cli:fgcolor = 15
    unit-cli = ""
    l-unit-cli:visible = true.
    display unit-cli with frame u-gds-form.
    disable unit-cli with frame u-gds-form.
    disable r-base with frame u-gds-form.
END.
ON RIGHT-MOUSE-CLICK OF v-calc-method IN FRAME u-gds-form
DO:
   assign
    v-calc-method:fgcolor = 15
    v-calc-method = 'Учетная':U
    l-calc-method:visible = true.
    display v-calc-method with frame u-gds-form.
    disable v-calc-method with frame u-gds-form.
END.
ON RIGHT-MOUSE-CLICK OF wt-base IN FRAME u-gds-form
DO:
    assign
    n-wt-base:fgcolor = 15
    wt-base = ?
    l-wt-base:visible = true.
    display wt-base with frame u-gds-form.
    disable wt-base with frame u-gds-form.
END.
ON RIGHT-MOUSE-CLICK OF wt-cart IN FRAME u-gds-form
DO:
    assign
    n-wt-cart:fgcolor = 15
    wt-cart = ?
    l-wt-cart:visible = true.
    display wt-cart with frame u-gds-form.
    disable wt-cart with frame u-gds-form.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME u-gds-form:PARENT eq ?
THEN FRAME u-gds-form:PARENT = ACTIVE-WINDOW.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame u-gds-form
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
on choose of b-help in frame u-gds-form
do:
  apply "help":u to frame u-gds-form .
end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame u-gds-form:width - 0.3
                fh            = frame u-gds-form:first-child
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame u-gds-form :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame u-gds-form :height-chars)
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
    if frame u-gds-form :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame u-gds-form :height-chars)
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
            frame u-gds-form :height = v-frame-height
          .
          if frame u-gds-form :scrollable = true
          then do:
            assign
              frame u-gds-form :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame u-gds-form :scrollable = true
          then do:
            assign
              frame u-gds-form :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame u-gds-form :height = v-frame-height
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
      v-frame-height = frame u-gds-form :height
      v-frame-virtual-height = frame u-gds-form :virtual-height
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
      v-field-group-handle = frame u-gds-form :first-child
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
    do with frame u-gds-form
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame u-gds-form :scrollable = true
      then do:
        assign
          frame u-gds-form :virtual-height = frame u-gds-form :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame u-gds-form :height = frame u-gds-form :height + p-change-value
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
        frame u-gds-form :height = frame u-gds-form :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame u-gds-form :scrollable = true
      then do:
        assign
          frame u-gds-form :virtual-height = frame u-gds-form :virtual-height + p-change-value
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
          ,input  string(frame u-gds-form :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame u-gds-form :height)
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
    if frame u-gds-form :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame u-gds-form :width
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
    if frame u-gds-form :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame u-gds-form :width
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
            frame u-gds-form :width = v-frame-width
          .
          if frame u-gds-form :scrollable = true
          then do:
            assign
              frame u-gds-form :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame u-gds-form :scrollable = true
          then do:
            assign
              frame u-gds-form :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame u-gds-form :width = v-frame-width
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
      v-frame-width = frame u-gds-form :width
      v-frame-virtual-width = frame u-gds-form :virtual-width
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
      v-field-group-handle = frame u-gds-form :first-child
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
    do with frame u-gds-form
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame u-gds-form :scrollable = true
      then do:
        assign
          frame u-gds-form :virtual-width = frame u-gds-form :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame u-gds-form :width = v-frame-width + p-change-value
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
        frame u-gds-form :width = frame u-gds-form :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame u-gds-form :scrollable = true
      then do:
        assign
          frame u-gds-form :virtual-width = frame u-gds-form :virtual-width + p-change-value
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
          ,input  string(frame u-gds-form :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame u-gds-form :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame u-gds-form
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame u-gds-form :height - v-diasize-resize-button :height
                  - 1
                  - (frame u-gds-form :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame u-gds-form :width - v-diasize-resize-button :width
                  - 1
                  - (frame u-gds-form :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame u-gds-form
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
      v-row-delta = v-new-row - frame u-gds-form :height
      v-col-delta = v-new-col - frame u-gds-form :width
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
            - frame u-gds-form :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame u-gds-form :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame u-gds-form :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame u-gds-form :height-chars
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
      v-diasize-current-frame-width  = frame u-gds-form :width
      v-diasize-current-frame-height = frame u-gds-form :height
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
    do with frame u-gds-form
    :
      assign
        v-diasize-orig-frame-height = frame u-gds-form :height
        v-diasize-orig-frame-width  = frame u-gds-form :width
        v-diasize-browse-handle     = browse BR-tt-tax :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame u-gds-form :first-child
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
    run diasize_init in this-procedure .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
   FIND ub.db WHERE ub.db.db-num = v-cntxt-db-num NO-LOCK .
   IF NOT ub.db.add-goods then do:
        message "В данной БД не разрешено изменять товары!" view-as alert-box ERROR.
        return.
   end.
   FIND ub.sysconf WHERE ub.sysconf.host-code = v-cntxt-host-code-obj NO-LOCK .
  RUN MyEnable in this-procedure .
  WAIT-FOR GO OF FRAME u-gds-form.
END.
RUN disable_UI in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME u-gds-form.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY gds-name alpha1 engl-name label-name chk-name OKDP ms-base unit-cli
          v-calc-method wt-base min-rate cli-base-rate ms-cart qnty-cart
          increase-pc wt-cart max-rate PS negative-rest stts EDITOR-1 n-grp-full
          grp-full FILL-IN-4 n-gds-name n-engl-name country_name n-alpha1
          n-label-name n-chk-name n-okdp n-ms-base n-unit-cli n-min-rate
          n-wt-base n-increase-pc n-cli-base-rate n-ms-cart n-max-rate
          n-qnty-cart n-wt-cart n-PS
      WITH FRAME u-gds-form.
  IF AVAILABLE ub.gds-prt THEN
    DISPLAY ub.gds-prt.node-name
      WITH FRAME u-gds-form.
  ENABLE b-exit l-negative-rest l-grp-full l-okdp l-max-rate l-tt-tax l-PS
         l-gds-name l-engl-name l-alpha1 l-wt-cart l-cli-base-rate l-ms-cart
         l-min-rate l-unit-cli l-qnty-cart l-calc-method l-increase-pc
         l-node-name l-stts l-chk-name l-label-name l-wt-base l-ms-base b-quit
         b-list b-help add-inf EDITOR-1 n-grp-full grp-full FILL-IN-4
         ub.gds-prt.node-name n-gds-name n-engl-name n-alpha1 n-label-name
         n-chk-name n-okdp n-ms-base n-unit-cli n-min-rate n-wt-base
         n-increase-pc n-cli-base-rate n-ms-cart n-max-rate n-qnty-cart
         n-wt-cart n-PS
      WITH FRAME u-gds-form.
  VIEW FRAME u-gds-form.
  OPEN QUERY BR-tt-tax FOR EACH tt-tax NO-LOCK.
END PROCEDURE.
PROCEDURE MyEnable :
define variable p-list as character no-undo .
run str/pr-listv.p (
                 input 'Учетная,Группа,Учет-резерв,Накладная,Накл-безНДС,Учет-безНДС,Учет+накл,Уч+накл-НДС,Не-считать,Производит,Произв-НДС,ПорогПр-НДС,ПорогПр+НДС,Спецификация':U
               , input "":U
               , output p-list) .
v-calc-method:list-items in frame u-gds-form  = p-list .
  DISPLAY gds-name alpha1 engl-name label-name chk-name OKDP qnty-cart
          v-calc-method unit-cli ms-base wt-base ms-cart wt-cart cli-base-rate increase-pc PS
          negative-rest stts EDITOR-1 n-grp-full grp-full FILL-IN-4 n-gds-name
          n-engl-name country_name n-alpha1 n-label-name n-chk-name n-okdp
          n-qnty-cart n-unit-cli n-ms-base n-wt-base n-ms-cart n-wt-cart n-cli-base-rate
          n-increase-pc n-PS
          max-rate min-rate
          n-max-rate n-min-rate
      WITH FRAME u-gds-form.
  IF AVAILABLE ub.gds-prt THEN
    DISPLAY ub.gds-prt.node-name
      WITH FRAME u-gds-form.
  ENABLE b-exit b-list b-quit b-help add-inf l-grp-full l-node-name
         l-gds-name l-engl-name l-alpha1 l-label-name l-chk-name l-okdp
         l-qnty-cart l-calc-method
         l-unit-cli l-ms-base l-wt-base l-ms-cart l-cli-base-rate l-wt-cart l-increase-pc l-tt-tax
         l-PS l-negative-rest l-stts EDITOR-1 n-grp-full grp-full FILL-IN-4
         gds-prt.node-name n-gds-name n-engl-name n-alpha1 n-label-name
         n-chk-name n-okdp n-qnty-cart n-unit-cli n-ms-base n-wt-base n-ms-cart n-wt-cart
         n-cli-base-rate n-increase-pc n-PS
         n-max-rate n-min-rate
      WITH FRAME u-gds-form.
  VIEW FRAME u-gds-form.
  OPEN QUERY BR-tt-tax FOR EACH tt-tax NO-LOCK.
END PROCEDURE.
