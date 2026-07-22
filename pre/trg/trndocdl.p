block-level on error undo, throw.
using ibs.th.str.alcohol.*.
define input  parameter p-doc-code like ub.trn-doc.doc-code   no-undo .
define input  parameter p-chip-num like ub.c-trn-doc.chip-num no-undo .
define variable chg-qnty      as   decimal no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Процедура удаления закрытого документа".
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
      p-vss-parameters = substitute('&1':u,p-doc-code)
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
define temp-table temp-trndocrs-gds-dtl-rsrv no-undo
  field prt-code         like ub.gds-dtl.prt-code
  field rsrv-qnty        like ub.gds-dtl.fact-qnty
  field rsrv-out-qnty    like ub.gds-dtl.fact-qnty
  index xpk is primary unique prt-code
.
define temp-table temp-trndocrs-pl-gds-rsrv no-undo
  field pl-code          like ub.pl-gds.pl-code
  field rsrv-qnty        like ub.pl-gds.free-qnty
  field cli-rsrv-qnty    like ub.pl-gds.cli-free-qnty
  field rsrv-out-qnty    like ub.pl-gds.fact-qnty
  field before-free-qnty like ub.pl-gds.fact-qnty
  field before-out-qnty  like ub.pl-gds.fact-qnty
  field after-free-qnty  like ub.pl-gds.fact-qnty
  field after-out-qnty   like ub.pl-gds.fact-qnty
  field fact-qnty        like ub.pl-gds.fact-qnty
  field cli-qnty         like ub.pl-gds.cli-qnty
  field cli-fact-qnty    like ub.pl-gds.cli-fact-qnty
  index xpk is primary unique pl-code
.
procedure trndocrs-gds-dtl-clear :
  define buffer buf_temp-trndocrs-gds-dtl-rsrv for temp-trndocrs-gds-dtl-rsrv .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-gds-dtl-rsrv
    on error undo, return error return-value
    :
      delete buf_temp-trndocrs-gds-dtl-rsrv .
    end.
  end.
end procedure.
procedure trndocrs-pl-gds-clear :
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-pl-gds-rsrv
    on error undo, return error return-value
    :
      delete buf_temp-trndocrs-pl-gds-rsrv .
    end.
  end.
end procedure.
procedure trndocrs-clear :
  define buffer buf_temp-trndocrs-gds-dtl-rsrv for temp-trndocrs-gds-dtl-rsrv .
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-gds-dtl-rsrv
    on error undo, return error return-value
    :
      delete buf_temp-trndocrs-gds-dtl-rsrv .
    end.
    for each buf_temp-trndocrs-pl-gds-rsrv
    on error undo, return error return-value
    :
      delete buf_temp-trndocrs-pl-gds-rsrv .
    end.
  end.
end procedure.
procedure trndocrs-pl-gds-accum :
  define input parameter p-pl-code       like ub.pl-gds.pl-code       no-undo .
  define input parameter p-rsrv-qnty     like ub.pl-gds.free-qnty     no-undo .
  define input parameter p-cli-rsrv-qnty like ub.pl-gds.cli-free-qnty no-undo .
  define input parameter p-fact-qnty     like ub.pl-gds.fact-qnty     no-undo .
  define input parameter p-cli-fact-qnty like ub.pl-gds.cli-fact-qnty no-undo .
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    find first buf_temp-trndocrs-pl-gds-rsrv
      where buf_temp-trndocrs-pl-gds-rsrv.pl-code = p-pl-code
      no-error .
    if not available buf_temp-trndocrs-pl-gds-rsrv then do:
      create buf_temp-trndocrs-pl-gds-rsrv .
      assign
        buf_temp-trndocrs-pl-gds-rsrv.pl-code = p-pl-code
      .
    end.
    assign
      buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty     = buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty     + p-rsrv-qnty
      buf_temp-trndocrs-pl-gds-rsrv.cli-rsrv-qnty = buf_temp-trndocrs-pl-gds-rsrv.cli-rsrv-qnty + p-cli-rsrv-qnty
      buf_temp-trndocrs-pl-gds-rsrv.fact-qnty     = buf_temp-trndocrs-pl-gds-rsrv.fact-qnty     + p-fact-qnty
      buf_temp-trndocrs-pl-gds-rsrv.cli-fact-qnty = buf_temp-trndocrs-pl-gds-rsrv.cli-fact-qnty + p-cli-fact-qnty
    .
  end.
end procedure.
procedure trndocrs-gds-dtl-accum :
  define input parameter p-prt-code   like ub.gds-dtl.prt-code   no-undo .
  define input parameter p-rsrv-qnty like ub.gds-dtl.fact-qnty no-undo .
  define buffer buf_temp-trndocrs-gds-dtl-rsrv  for temp-trndocrs-gds-dtl-rsrv .
  do
  on error undo, return error return-value
  :
    find first buf_temp-trndocrs-gds-dtl-rsrv
      where buf_temp-trndocrs-gds-dtl-rsrv.prt-code = p-prt-code
      no-error .
    if not available buf_temp-trndocrs-gds-dtl-rsrv then do:
      create buf_temp-trndocrs-gds-dtl-rsrv .
      assign
        buf_temp-trndocrs-gds-dtl-rsrv.prt-code = p-prt-code
      .
    end.
    assign
      buf_temp-trndocrs-gds-dtl-rsrv.rsrv-qnty = buf_temp-trndocrs-gds-dtl-rsrv.rsrv-qnty
                                             + p-rsrv-qnty
    .
  end.
end procedure.
procedure trndocrs-pl-gds-request :
  define input parameter p-doc-code               like ub.doc-line.doc-code  no-undo .
  define input parameter p-doc-type               like ub.trn-doc.doc-type   no-undo .
  define input parameter p-obj-type               like ub.doc-line.obj-type  no-undo .
  define input parameter p-obj-code               like ub.doc-line.obj-code  no-undo .
  define input parameter p-artic                  like ub.doc-line.artic     no-undo .
  define input parameter p-prod-type              like ub.doc-line.prod-type no-undo .
  define input parameter p-prod-code              like ub.doc-line.prod-code no-undo .
  define input parameter p-field-accum            as character no-undo .
  define variable vss-description as character no-undo init "trndocrs-pl-gds-request: Сбор информации о партиях на складских местах".
  define buffer buf_temp-trndocrs-pl-gds-rsrv for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    if lookup(p-field-accum, "before,after":u ) = 0 then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info4 skip
        "Ошибка задания входных параметров параметров" skip
        "Неизвестное значение параметра" skip
        "p-field-accum" p-field-accum skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    case p-field-accum :
      when "before":u then do:
        for each buf_temp-trndocrs-pl-gds-rsrv
        on error undo, return error return-value
        :
          assign
            buf_temp-trndocrs-pl-gds-rsrv.before-free-qnty = 0
            buf_temp-trndocrs-pl-gds-rsrv.before-out-qnty  = 0
          .
        end.
      end.
      when "after":u then do:
        for each buf_temp-trndocrs-pl-gds-rsrv
        on error undo, return error return-value
        :
          assign
            buf_temp-trndocrs-pl-gds-rsrv.after-free-qnty  = 0
            buf_temp-trndocrs-pl-gds-rsrv.after-out-qnty   = 0
          .
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info4 skip
          "Ошибка задания входных параметров параметров" skip
          "Неизвестное значение параметра" skip
          "p-field-accum" p-field-accum skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    define buffer buf_parts for ub.parts.
    for each buf_parts no-lock
      where buf_parts.out-code  = p-doc-code
        and buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
    on error undo, return error return-value
    :
      find first buf_temp-trndocrs-pl-gds-rsrv
        where buf_temp-trndocrs-pl-gds-rsrv.pl-code = buf_parts.pl-code
        no-error .
      if not available buf_temp-trndocrs-pl-gds-rsrv then do:
        create buf_temp-trndocrs-pl-gds-rsrv .
        assign
          buf_temp-trndocrs-pl-gds-rsrv.pl-code = buf_parts.pl-code
        .
      end.
      if can-do('при,рас,спи':U, p-doc-type)
      or (p-doc-type = 'инв':U
          and buf_parts.fact-qnty < 0)
      then do:
        case p-field-accum :
          when "before":u then do:
            assign
              buf_temp-trndocrs-pl-gds-rsrv.before-free-qnty
                = buf_temp-trndocrs-pl-gds-rsrv.before-free-qnty
                + abs(buf_parts.fact-qnty)
            .
          end.
          when "after":u then do:
            assign
              buf_temp-trndocrs-pl-gds-rsrv.after-free-qnty
                = buf_temp-trndocrs-pl-gds-rsrv.after-free-qnty
                + abs(buf_parts.fact-qnty)
            .
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info4 skip
              "Ошибка задания входных параметров параметров" skip
              "Неизвестное значение параметра" skip
              "p-field-accum" p-field-accum skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
      end.
      else do:
        case p-field-accum :
          when "before":u then do:
            assign
              buf_temp-trndocrs-pl-gds-rsrv.before-out-qnty
                = buf_temp-trndocrs-pl-gds-rsrv.before-out-qnty
                + abs(buf_parts.fact-qnty)
            .
          end.
          when "after":u then do:
            assign
              buf_temp-trndocrs-pl-gds-rsrv.after-out-qnty
                = buf_temp-trndocrs-pl-gds-rsrv.after-out-qnty
                + abs(buf_parts.fact-qnty)
            .
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info4 skip
              "Ошибка задания входных параметров параметров" skip
              "Неизвестное значение параметра" skip
              "p-field-accum" p-field-accum skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure trndocrs-pl-gds-calc-rsrv :
  define variable vss-description as character no-undo init "trndocrs-pl-gds-calc-rsrv: Сбор информации о партиях на складских местах".
  define buffer buf_temp-trndocrs-pl-gds-rsrv for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-pl-gds-rsrv
    on error undo, return error return-value
    :
      assign
        buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty
          = buf_temp-trndocrs-pl-gds-rsrv.after-free-qnty
          - buf_temp-trndocrs-pl-gds-rsrv.before-free-qnty
        buf_temp-trndocrs-pl-gds-rsrv.rsrv-out-qnty
          = buf_temp-trndocrs-pl-gds-rsrv.after-out-qnty
          - buf_temp-trndocrs-pl-gds-rsrv.before-out-qnty
      .
    end.
  end.
end procedure.
procedure trndocrs-need-rsrv :
  define input  parameter p-doc-type     like ub.trn-doc.doc-type no-undo .
  define input  parameter p-artic        like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type    like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code    like ub.doc-line.prod-code no-undo .
  define output parameter p-need-rsrv    as logical   no-undo .
  define buffer buf_goods   for ub.goods .
  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      .
    if buf_goods.gds-type = 'т':U
    and ( p-doc-type = 'рас':U
          or p-doc-type = 'спи':U
        )
    then do:
      assign
        p-need-rsrv = true
      .
    end.
    else do:
      assign
        p-need-rsrv = false
      .
    end.
  end.
end procedure.
procedure trndocrs-need-create-doc-pl :
  define input  parameter p-extended-doc-type  as character no-undo .
  define input  parameter p-news               as logical   no-undo .
  define input  parameter p-sale-auto          as logical   no-undo .
  define output parameter p-need-create-doc-pl as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if  not p-news
    and p-extended-doc-type <> 'ie':U
    and p-extended-doc-type <> 'es':U
    and p-extended-doc-type <> 'rs':U
    and not p-sale-auto
    then do:
      assign
        p-need-create-doc-pl = true
      .
    end.
    else do:
      assign
        p-need-create-doc-pl = false
      .
    end.
  end.
end procedure.
procedure trndocrs-validate :
  define input parameter p-place-rsrv as logical no-undo .
  define input parameter p-chg-qnty   as decimal no-undo .
  define buffer buf_temp-trndocrs-gds-dtl-rsrv for temp-trndocrs-gds-dtl-rsrv .
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  define variable v-total-gds-dtl-rsrv-qnty as decimal no-undo .
  define variable v-total-pl-gds-rsrv-qnty as decimal no-undo .
  assign
    v-total-gds-dtl-rsrv-qnty = 0
    v-total-pl-gds-rsrv-qnty  = 0
  .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-gds-dtl-rsrv
    on error undo, return error return-value
    :
      assign
        v-total-gds-dtl-rsrv-qnty = v-total-gds-dtl-rsrv-qnty
                                  + buf_temp-trndocrs-gds-dtl-rsrv.rsrv-qnty
      .
    end.
    for each buf_temp-trndocrs-pl-gds-rsrv
    on error undo, return error return-value
    :
      assign
        v-total-pl-gds-rsrv-qnty = v-total-pl-gds-rsrv-qnty
                                 + buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty
      .
    end.
    if round(v-total-gds-dtl-rsrv-qnty, 0) <> round(p-chg-qnty, 0) then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info4 skip
        "Ошибка при резервировании свободных количеств" skip
        "Запрошено резервирование:" skip
        "По товару" p-chg-qnty skip
        "По признакам" v-total-gds-dtl-rsrv-qnty skip
        "По складским местам" v-total-pl-gds-rsrv-qnty skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-place-rsrv then do:
      if round(v-total-pl-gds-rsrv-qnty, 0) <> round(p-chg-qnty, 0) then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info4 skip
          "Ошибка при резервировании свободных количеств" skip
          "Запрошено резервирование:" skip
          "По товару" p-chg-qnty skip
          "По признакам" v-total-gds-dtl-rsrv-qnty skip
          "По складским местам" v-total-pl-gds-rsrv-qnty skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure trndocrs :
  define input parameter p-doc-code   like ub.doc-line.doc-code  no-undo .
  define input parameter p-obj-type   like ub.doc-line.obj-type  no-undo .
  define input parameter p-obj-code   like ub.doc-line.obj-code  no-undo .
  define input parameter p-artic      like ub.doc-line.artic     no-undo .
  define input parameter p-prod-type  like ub.doc-line.prod-type no-undo .
  define input parameter p-prod-code  like ub.doc-line.prod-code no-undo .
  define input parameter p-chg-qnty   as decimal no-undo .
  define buffer buf_db         for ub.db .
  define buffer buf_gds-obj    for ub.gds-obj .
  define buffer buf_prt-obj    for ub.prt-obj .
  define buffer buf_gds-prt    for ub.gds-prt .
  define buffer buf_goods      for ub.goods .
  define buffer buf_pl-gds     for ub.pl-gds .
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  define buffer buf_temp-trndocrs-gds-dtl-rsrv for temp-trndocrs-gds-dtl-rsrv .
  define variable v-node-code   like ub.gds-prt.node-code no-undo .
  define variable v-curr-db-num like ub.db.db-num         no-undo .
  define variable v-cmd         as   character            no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info4 skip
        "Ошибка при поиске товара на объекте" skip
        "p-obj-type"  p-obj-type  skip
        "p-obj-code"  p-obj-code  skip
        "p-artic"     p-artic     skip
        "p-prod-type" p-prod-type skip
        "p-prod-code" p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find current buf_gds-obj exclusive-lock .
    run trndocrs-validate in this-procedure
      (input buf_gds-obj.place-rsrv
      ,input p-chg-qnty
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info4 skip
        "Противоречивые данные для резервирования" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      buf_gds-obj.free-qnty   = buf_gds-obj.free-qnty - p-chg-qnty
      buf_gds-obj.on-line-rest = buf_gds-obj.free-qnty
    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input  'rest-update':U
  ,input ?
  ,input  buffer buf_gds-obj:handle
  ,input 'fact-qnty,free-qnty'
  ,input ''
  ) no-error .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-curr-db-num
  )  .
    find first buf_db no-lock
      where buf_db.db-num = v-curr-db-num
      .
    if buf_db.db-num <> 0
      and buf_db.on-line-rest = true
    then do:
      assign
        v-cmd = "command":U + chr(1)
                + "create":U + chr(1)
                + "on-line-rest":U + chr(1)
                + substitute( "&1", buf_gds-obj.obj-type ) + chr(1)
                + substitute( "&1", buf_gds-obj.obj-code ) + chr(1)
                + substitute( "&1", buf_gds-obj.artic ) + chr(1)
                + substitute( "&1", buf_gds-obj.prod-type ) + chr(1)
                + substitute( "&1", buf_gds-obj.prod-code ) + chr(1)
                + substitute( "&1", buf_gds-obj.free-qnty ) + chr(1)
      .
      run nws/cr-route.p
        ( input 'send-cmd':U
          ,input v-cmd
          ,input ?
          ,input "0":U
        ).
    end.
    if buf_gds-obj.place-rsrv = true then do:
      for each buf_temp-trndocrs-pl-gds-rsrv
      on error undo, return error return-value
      :
        find first buf_goods no-lock
          where buf_goods.artic     = p-artic
            and buf_goods.prod-type = p-prod-type
            and buf_goods.prod-code = p-prod-code
          no-error .
        if not available buf_goods then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info4 skip
            "Не найдена товар" skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        find first buf_pl-gds exclusive-lock
          where buf_pl-gds.obj-type = p-obj-type
            and buf_pl-gds.obj-code = p-obj-code
            and buf_pl-gds.gds-code = buf_goods.gds-code
            and buf_pl-gds.pl-code  = buf_temp-trndocrs-pl-gds-rsrv.pl-code
          no-error .
        if not available buf_pl-gds then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info4 skip
            "Не найдена привязка товара к складскому месту" skip
            "Код товара" buf_temp-trndocrs-pl-gds-rsrv.pl-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        assign
          buf_pl-gds.free-qnty     = buf_pl-gds.free-qnty     - buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty
          buf_pl-gds.cli-free-qnty = buf_pl-gds.cli-free-qnty - buf_temp-trndocrs-pl-gds-rsrv.cli-rsrv-qnty
        .
        if buf_pl-gds.free-qnty = buf_pl-gds.fact-qnty
          and absolute( buf_pl-gds.cli-free-qnty - buf_pl-gds.cli-fact-qnty ) <= 0.01
        then do:
          assign
            buf_pl-gds.cli-free-qnty = buf_pl-gds.cli-fact-qnty
          .
        end.
      end.
    end.
    for each buf_temp-trndocrs-gds-dtl-rsrv
    on error undo, return error return-value
    :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  buf_temp-trndocrs-gds-dtl-rsrv.prt-code
  ,output v-node-code
  ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info4 skip
          "Ошибка при определении первого терминального признака" skip
          "prt-code" buf_temp-trndocrs-gds-dtl-rsrv.prt-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find first buf_gds-prt no-lock
        where buf_gds-prt.node-code = v-node-code
        .
      do while available buf_gds-prt
      on error undo, return error return-value
      :
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  buf_gds-prt.node-code
  ,buffer buf_prt-obj
  )  .
        find current buf_prt-obj exclusive-lock .
        assign
          buf_prt-obj.free-qnty = buf_prt-obj.free-qnty - buf_temp-trndocrs-gds-dtl-rsrv.rsrv-qnty
        .
        assign
          v-node-code = buf_gds-prt.upper-code
        .
        find first buf_gds-prt no-lock
          where buf_gds-prt.node-code = v-node-code
          no-error .
      end.
    end.
  end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure trndocgs :
  define input  parameter p-doc-code      like ub.doc-line.doc-code  no-undo .
  define input  parameter p-artic         like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type     like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code     like ub.doc-line.prod-code no-undo .
  define input  parameter p-root-node     like ub.prt-obj.prt-code  no-undo .
  define input  parameter p-news          as logical no-undo .
  define input  parameter p-trn-doc-close as logical   no-undo .
  define input  parameter p-update-host   as logical no-undo .
  define buffer buf_db       for ub.db .
  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_gds-dtl  for ub.gds-dtl .
  define buffer buf_gds-obj  for ub.gds-obj .
  define buffer buf_prt-obj  for ub.prt-obj .
  define buffer buf_goods    for ub.goods .
  define buffer buf_gds-prt  for ub.gds-prt .
  define buffer buf_pl-gds   for ub.pl-gds .
  define buffer buf_doc-pl   for ub.doc-pl .
  define variable v-obj-type      like ub.gds-obj.obj-type  no-undo .
  define variable v-obj-code      like ub.gds-obj.obj-code  no-undo .
  define variable curr-node       like ub.gds-prt.node-code no-undo .
  define variable l-need-rsrv     as logical                no-undo .
  define variable l-goods-twounit as logical                no-undo .
  define variable v-cmd           as character              no-undo .
  define variable v-curr-db-num   like ub.db.db-num         no-undo .
  define variable v-update-sign   as decimal   no-undo .
  define variable v-doc-sign      as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    if p-trn-doc-close = true
    then do:
      assign
        v-update-sign = 1.0
      .
    end.
    else do:
      assign
        v-update-sign = -1.0
      .
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Товар" p-artic p-prod-code p-prod-type skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if buf_doc-line.fact-order = ?
    or buf_doc-line.fact-order = 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не задан логический номер строки документа" skip
        "Документ" buf_doc-line.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        "Логический номер документа" buf_doc-line.fact-order skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      .
    assign
      v-obj-type  = buf_doc-line.obj-type
      v-obj-code  = buf_doc-line.obj-code
    .
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscr in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,input  p-root-node
  ,buffer buf_gds-obj
  ,buffer buf_prt-obj
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании информации о товаре на фирме" skip
        error-status :get-message(1) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find current buf_gds-obj exclusive-lock .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if  buf_gds-obj.first-doc <> ?
and buf_gds-obj.first-doc > buf_trn-doc.fact-date then do:
  assign
    buf_gds-obj.first-doc  = buf_trn-doc.fact-date
  .
end.
if  buf_gds-obj.last-doc <> ?
and buf_gds-obj.last-doc < buf_trn-doc.fact-date then do:
  assign
    buf_gds-obj.last-doc   = buf_trn-doc.fact-date
  .
end.
    if p-trn-doc-close = true
    then do:
      run trndocrs-need-rsrv in this-procedure
        (input  buf_trn-doc.doc-type
        ,input  buf_doc-line.artic
        ,input  buf_doc-line.prod-type
        ,input  buf_doc-line.prod-code
        ,output l-need-rsrv
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры trndocrs-need-rsrv" skip
          "Документ" buf_trn-doc.doc-type skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    else do:
      assign
        l-need-rsrv = false
      .
    end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,input  'twounit=request':u
  ,output l-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        'twounit=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run trndocrs-clear in this-procedure
      .
    if buf_goods.gds-type = 'т':U
    then do:
      define variable v-change-qnty        as decimal no-undo .
      define variable v-change-base-total  as decimal no-undo .
      define variable v-change-rubl-total  as decimal no-undo .
      define variable v-total-qnty         as decimal no-undo .
      define variable v-total-cli-qnty     as decimal no-undo .
      define variable v-total-base-total   as decimal no-undo .
      define variable v-total-rubl-total   as decimal no-undo .
      define variable v-return-qnty        as decimal no-undo .
      define variable v-return-base-total  as decimal no-undo .
      define variable v-return-rubl-total  as decimal no-undo .
      define variable v-expense-qnty       as decimal no-undo .
      define variable v-expense-base-total as decimal no-undo .
      define variable v-expense-rubl-total as decimal no-undo .
      define variable v-total-rsrv-qnty    as decimal no-undo .
      run tdparts in this-procedure
        (input  buf_trn-doc.host-code
        ,input  buf_trn-doc.doc-type
        ,input  buf_trn-doc.internal
        ,input  buf_trn-doc.discnt-type
        ,input  buf_trn-doc.doc-code
        ,input  buf_doc-line.obj-type
        ,input  buf_doc-line.obj-code
        ,input  buf_doc-line.artic
        ,input  buf_doc-line.prod-type
        ,input  buf_doc-line.prod-code
        ,input  l-need-rsrv
        ,input  buf_gds-obj.place-rsrv
        ,input  l-goods-twounit
        ,output v-change-qnty
        ,output v-change-base-total
        ,output v-change-rubl-total
        ,output v-total-qnty
        ,output v-total-cli-qnty
        ,output v-total-base-total
        ,output v-total-rubl-total
        ,output v-return-qnty
        ,output v-return-base-total
        ,output v-return-rubl-total
        ,output v-expense-qnty
        ,output v-expense-base-total
        ,output v-expense-rubl-total
        ,output v-total-rsrv-qnty
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при обработке архивных партий" skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    else do:
      assign
        v-total-qnty       = (if buf_trn-doc.doc-type = 'рас':U
                              or buf_trn-doc.doc-type = 'спи':U
                              then - buf_doc-line.fact-qnty
                              else   buf_doc-line.fact-qnty
                             )
        v-total-rsrv-qnty  = 0
        v-total-base-total = buf_doc-line.price-base * v-total-qnty
        v-total-rubl-total = buf_doc-line.price-rubl * v-total-qnty
      .
      if l-goods-twounit
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Услуга не может учитываться по двум единицам измерения" skip
          "Документ" buf_trn-doc.doc-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    define variable v-gds-dtl-qnty        as decimal no-undo .
    define variable v-gds-dtl-rsrv-qnty   as decimal no-undo .
    for each buf_gds-dtl
      where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
        and buf_gds-dtl.artic     = buf_doc-line.artic
        and buf_gds-dtl.prod-type = buf_doc-line.prod-type
        and buf_gds-dtl.prod-code = buf_doc-line.prod-code
    on error undo, return error return-value
    :
      case buf_trn-doc.doc-type :
        when 'при':U or
        when 'возврат':U
        then do:
          assign
            v-gds-dtl-qnty      = buf_gds-dtl.fact-qnty
            v-gds-dtl-rsrv-qnty = buf_gds-dtl.doc-qnty
          .
        end.
        when 'рас':U or
        when 'спи':U
        then do:
          assign
            v-gds-dtl-qnty      = - buf_gds-dtl.fact-qnty
            v-gds-dtl-rsrv-qnty = - buf_gds-dtl.doc-qnty
          .
        end.
        when 'инв':U
        then do:
          assign
            v-gds-dtl-qnty = buf_gds-dtl.doc-qnty
            v-gds-dtl-rsrv-qnty = 0
          .
        end.
      end.
      if l-need-rsrv
      then do:
        run trndocrs-gds-dtl-accum in this-procedure
          (input buf_gds-dtl.prt-code
          ,input v-gds-dtl-rsrv-qnty
                * v-update-sign
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при изменении зарезервированных количеств trndocrs-gds-dtl-accum" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  buf_gds-dtl.prt-code
  ,output curr-node
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно найти терминальный признак" skip
          "prt-code" buf_gds-dtl.prt-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find first buf_gds-prt no-lock
        where buf_gds-prt.node-code = curr-node
        .
      do while available buf_gds-prt:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtobjcr in g#library
  (input  buf_gds-dtl.obj-type
  ,input  buf_gds-dtl.obj-code
  ,input  buf_gds-dtl.artic
  ,input  buf_gds-dtl.prod-type
  ,input  buf_gds-dtl.prod-code
  ,input  buf_gds-prt.node-code
  ,buffer buf_prt-obj
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при создании признака на объекте" skip
            "obj-type"  buf_gds-dtl.obj-type skip
            "obj-code"  buf_gds-dtl.obj-code skip
            "artic"     buf_gds-dtl.artic skip
            "prod-type" buf_gds-dtl.prod-type skip
            "prod-code" buf_gds-dtl.prod-code skip
            "node-code" buf_gds-prt.node-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        find current buf_prt-obj exclusive-lock .
        if buf_goods.gds-type = 'т':U
        then do:
          find first doc-fbr-gds no-lock where (doc-fbr-gds.out-code = buf_doc-line.doc-code or
                                                doc-fbr-gds.out-code = replace(buf_doc-line.doc-code, "=", "-") )
                                           and doc-fbr-gds.gds-code = buf_goods.gds-code
                                           no-error .
          if available doc-fbr-gds
          then do :
            assign
              buf_prt-obj.fact-qnty = buf_prt-obj.fact-qnty + v-gds-dtl-rsrv-qnty
                                                            * v-update-sign
              buf_prt-obj.free-qnty = buf_prt-obj.free-qnty + v-gds-dtl-rsrv-qnty
                                                            * v-update-sign
            .
          end.
          else do :
            assign
              buf_prt-obj.fact-qnty = buf_prt-obj.fact-qnty + v-gds-dtl-qnty
                                                            * v-update-sign
              buf_prt-obj.free-qnty = buf_prt-obj.free-qnty + v-gds-dtl-qnty
                                                            * v-update-sign
            .
          end.
        end.
        assign
          curr-node = buf_gds-prt.upper-code
        .
        find first buf_gds-prt no-lock
          where buf_gds-prt.node-code = curr-node
          no-error.
      end.
    end.
    if l-need-rsrv
    then do:
      run trndocrs in this-procedure
        (input p-doc-code
        ,input v-obj-type
        ,input v-obj-code
        ,input p-artic
        ,input p-prod-type
        ,input p-prod-code
        ,input v-total-rsrv-qnty
              * v-update-sign
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при изменении зарезервированных количеств trndocrs" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    if buf_goods.gds-type = 'т':U
    then do:
      define variable v-old-fact-qnty            as decimal   no-undo .
      define variable v-old-fact-cli-qnty        as decimal   no-undo .
      define variable v-old-pl-gds-fact-qnty     as decimal   no-undo .
      define variable v-old-pl-gds-free-qnty     as decimal   no-undo .
      define variable v-old-pl-gds-cli-qnty      as decimal   no-undo .
      define variable v-old-pl-gds-cli-fact-qnty as decimal   no-undo .
      define variable v-old-pl-gds-cli-free-qnty as decimal   no-undo .
      define variable v-old-fact-base            as decimal   no-undo .
      define variable v-old-fact-rubl            as decimal   no-undo .
      define variable v-old-fact-sale            as decimal   no-undo .
      assign
        v-old-fact-qnty     = buf_gds-obj.fact-qnty
        v-old-fact-cli-qnty = buf_gds-obj.fact-cli-qnty
        v-old-fact-base     = buf_gds-obj.fact-base
        v-old-fact-rubl     = buf_gds-obj.fact-rubl
        v-old-fact-sale     = buf_gds-obj.fact-sale
      .
      assign
        buf_gds-obj.fact-qnty     = buf_gds-obj.fact-qnty     + v-total-qnty
                                                              * v-update-sign
        buf_gds-obj.free-qnty     = buf_gds-obj.free-qnty     + v-total-qnty
                                                              * v-update-sign
        buf_gds-obj.fact-base     = buf_gds-obj.fact-base     + v-total-base-total
                                                              * v-update-sign
        buf_gds-obj.fact-rubl     = buf_gds-obj.fact-rubl     + v-total-rubl-total
                                                              * v-update-sign
        buf_gds-obj.on-line-rest  = buf_gds-obj.free-qnty
      .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input  'rest-update':U
  ,input ?
  ,input  buffer buf_gds-obj:handle
  ,input 'fact-qnty,free-qnty'
  ,input ''
  ) no-error .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-curr-db-num
  )  .
      find first buf_db no-lock
        where buf_db.db-num = v-curr-db-num
        .
      if buf_db.db-num <> 0
        and buf_db.on-line-rest = true
      then do:
        assign
          v-cmd = "command":U + chr(1)
                  + "create":U + chr(1)
                  + "on-line-rest":U + chr(1)
                  + substitute( "&1", buf_gds-obj.obj-type ) + chr(1)
                  + substitute( "&1", buf_gds-obj.obj-code ) + chr(1)
                  + substitute( "&1", buf_gds-obj.artic ) + chr(1)
                  + substitute( "&1", buf_gds-obj.prod-type ) + chr(1)
                  + substitute( "&1", buf_gds-obj.prod-code ) + chr(1)
                  + substitute( "&1", buf_gds-obj.free-qnty ) + chr(1)
        .
        run nws/cr-route.p
          ( input 'send-cmd':U
           ,input v-cmd
           ,input ?
           ,input "0":U
          ).
      end.
      if l-goods-twounit
      then do:
        assign
          buf_gds-obj.fact-cli-qnty = buf_gds-obj.fact-cli-qnty + v-total-cli-qnty
                                                                * v-update-sign
        .
      end.
      run gdsobjcl in this-procedure
        (input recid(buf_gds-obj)
        ,input false
        ) no-error.
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при расчете суммы остатка в учетных и продажных ценах по объекту" skip
          "Документ" buf_trn-doc.doc-code skip
          "Объект" buf_gds-obj.obj-type buf_gds-obj.obj-code skip
          "Артикул" buf_gds-obj.artic buf_gds-obj.prod-type buf_gds-obj.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box.
        undo, return error return-value .
      end.
      define variable p-action-type as character no-undo .
      if p-trn-doc-close = true
      then do:
        assign
          p-action-type = 'close':U
        .
      end.
      else do:
        assign
          p-action-type = 'delete':U
        .
      end.
      if buf_gds-obj.place-rsrv = true then do:
        for each buf_doc-pl no-lock
          where buf_doc-pl.obj-type = v-obj-type
            and buf_doc-pl.obj-code = v-obj-code
            and buf_doc-pl.out-code = p-doc-code
            and buf_doc-pl.gds-code = buf_goods.gds-code
        on error undo, return error return-value
        :
          find first buf_pl-gds exclusive-lock
            where buf_pl-gds.obj-type = buf_doc-pl.obj-type
              and buf_pl-gds.obj-code = buf_doc-pl.obj-code
              and buf_pl-gds.gds-code = buf_doc-pl.gds-code
              and buf_pl-gds.pl-code  = buf_doc-pl.pl-code
            no-error .
          if not available buf_pl-gds  then do:
            if p-news = true then do:
              create buf_pl-gds .
              assign
                buf_pl-gds.obj-type = buf_doc-pl.obj-type
                buf_pl-gds.obj-code = buf_doc-pl.obj-code
                buf_pl-gds.gds-code = buf_doc-pl.gds-code
                buf_pl-gds.pl-code  = buf_doc-pl.pl-code
              .
            end.
            else do:
              message
                vss-workfile vss-revision vss-description skip
                "Не найдена привязка товара к складскому месту" skip
                "Документ" buf_doc-pl.out-code skip
                "Объект" buf_doc-pl.obj-type buf_doc-pl.obj-code skip
                "Складское место" buf_doc-pl.pl-code skip
                "Код товара" buf_doc-pl.gds-code skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.
          if buf_trn-doc.doc-type = 'рас':U
            or buf_trn-doc.doc-type = 'спи':U
          then do:
            assign
              v-doc-sign = -1.0
            .
          end.
          else do:
            assign
              v-doc-sign = 1.0
            .
          end.
          assign
            v-old-pl-gds-fact-qnty     = buf_pl-gds.fact-qnty
            v-old-pl-gds-free-qnty     = buf_pl-gds.free-qnty
            v-old-pl-gds-cli-qnty      = buf_pl-gds.cli-qnty
            v-old-pl-gds-cli-fact-qnty = buf_pl-gds.cli-fact-qnty
            v-old-pl-gds-cli-free-qnty = buf_pl-gds.cli-free-qnty
            buf_pl-gds.fact-qnty       = buf_pl-gds.fact-qnty     + buf_doc-pl.fact-qnty     * v-update-sign * v-doc-sign
            buf_pl-gds.free-qnty       = buf_pl-gds.free-qnty     + buf_doc-pl.fact-qnty     * v-update-sign * v-doc-sign
            buf_pl-gds.cli-qnty        = buf_pl-gds.cli-qnty      + buf_doc-pl.cli-qnty      * v-update-sign * v-doc-sign
            buf_pl-gds.cli-fact-qnty   = buf_pl-gds.cli-fact-qnty + buf_doc-pl.cli-fact-qnty * v-update-sign * v-doc-sign
            buf_pl-gds.cli-free-qnty   = buf_pl-gds.cli-free-qnty + buf_doc-pl.cli-fact-qnty * v-update-sign * v-doc-sign
          .
          if buf_pl-gds.free-qnty = buf_pl-gds.fact-qnty
            and absolute( buf_pl-gds.cli-free-qnty - buf_pl-gds.cli-fact-qnty ) <= 0.01
          then do:
            assign
              buf_pl-gds.cli-free-qnty = buf_pl-gds.cli-fact-qnty
            .
          end.
          if buf_pl-gds.fact-qnty < 0.0 then do:
              message
                vss-workfile vss-revision vss-description skip
                "Фактическое количество в резервуаре после закрытия станет меньше нуля: " buf_pl-gds.fact-qnty skip
                "Документ" p-doc-code skip
                "Объект" v-obj-type v-obj-code skip
                "Место хранения" buf_doc-pl.pl-code skip
                "Код товара" buf_goods.gds-code skip
                view-as alert-box error .
              undo, return error return-value .
          end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run plgohist in g#library
  (input  buf_pl-gds.obj-type
  ,input  buf_pl-gds.obj-code
  ,input  buf_pl-gds.pl-code
  ,input  buf_pl-gds.gds-code
  ,input  p-action-type
  ,input  buf_pl-gds.fact-qnty
  ,input  buf_pl-gds.cli-qnty
  ,input  buf_pl-gds.free-qnty
  ,input  buf_pl-gds.cli-fact-qnty
  ,input  buf_pl-gds.cli-free-qnty
  ,input  v-old-pl-gds-fact-qnty
  ,input  v-old-pl-gds-cli-qnty
  ,input  v-old-pl-gds-free-qnty
  ,input  v-old-pl-gds-cli-fact-qnty
  ,input  v-old-pl-gds-cli-free-qnty
  ,input  'trn-doc':U
  ,input  buf_trn-doc.doc-code
  ,input  buf_trn-doc.fact-date
  ,input  buf_trn-doc.user-db-num
  ,input  buf_trn-doc.user-name
  ,input  buf_trn-doc.sys-date
  ,input  buf_trn-doc.sys-time-int
  ,input  buf_trn-doc.sys-time
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при создании истории по товару на складском месте" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
      end.
      define variable v-corr-date   as date      no-undo .
      define variable v-corr-time   as integer   no-undo .
      run cur-time in this-procedure
        (output v-corr-date
        ,output v-corr-time
        ) .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gohist in g#library
  (input  buf_gds-obj.obj-type
  ,input  buf_gds-obj.obj-code
  ,input  buf_gds-obj.gds-code
  ,input  p-action-type
  ,input  buf_gds-obj.fact-qnty
  ,input  buf_gds-obj.fact-cli-qnty
  ,input  buf_gds-obj.fact-base
  ,input  buf_gds-obj.fact-rubl
  ,input  buf_gds-obj.fact-sale
  ,input  v-old-fact-qnty
  ,input  v-old-fact-cli-qnty
  ,input  v-old-fact-base
  ,input  v-old-fact-rubl
  ,input  v-old-fact-sale
  ,input  'trn-doc':U
  ,input  buf_trn-doc.doc-code
  ,input  buf_trn-doc.fact-date
  ,input  buf_trn-doc.user-db-num
  ,input  buf_trn-doc.user-name
  ,input  buf_trn-doc.sys-date
  ,input  buf_trn-doc.sys-time-int
  ,input  buf_trn-doc.sys-time
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при создании истории по товару на объекте" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    if buf_goods.gds-type = 'т':U
    then do:
      if buf_trn-doc.doc-type = 'при':U
      and buf_doc-line.fact-qnty <> 0
      then do:
        if p-trn-doc-close = true
        then do:
          if buf_gds-obj.in-date = ?
          or buf_gds-obj.in-date <= buf_trn-doc.fact-date
          then do:
            assign
              buf_gds-obj.last-base = buf_doc-line.price-base
              buf_gds-obj.last-rubl = buf_doc-line.price-rubl
              buf_gds-obj.in-code   = buf_trn-doc.doc-code
              buf_gds-obj.in-date   = buf_trn-doc.fact-date
            .
          end.
        end.
        else do:
          define buffer income_buf_doc-line for ub.doc-line .
          define buffer income_buf_trn-doc for ub.trn-doc .
          for each income_buf_doc-line no-lock
            where income_buf_doc-line.obj-type     = buf_doc-line.obj-type
              and income_buf_doc-line.obj-code     = buf_doc-line.obj-code
              and income_buf_doc-line.artic        = buf_doc-line.artic
              and income_buf_doc-line.prod-type    = buf_doc-line.prod-type
              and income_buf_doc-line.prod-code    = buf_doc-line.prod-code
              and income_buf_doc-line.status_      = 'факт':U
              and income_buf_doc-line.doc-code    <> buf_doc-line.doc-code
          ,first income_buf_trn-doc no-lock
             where income_buf_trn-doc.doc-code = income_buf_doc-line.doc-code
               and income_buf_trn-doc.doc-type = 'при':U
          by income_buf_doc-line.fact-order descending
          on error undo, return error return-value
          :
            assign
              buf_gds-obj.last-base = income_buf_doc-line.price-base
              buf_gds-obj.last-rubl = income_buf_doc-line.price-rubl
              buf_gds-obj.in-code   = income_buf_trn-doc.doc-code
              buf_gds-obj.in-date   = income_buf_trn-doc.fact-date
            .
            leave .
          end.
        end.
      end.
    end.
  end.
end procedure.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tdparts :
  define input parameter  p-trn-doc-host-code   like ub.trn-doc.host-code   no-undo .
  define input parameter  p-trn-doc-doc-type    like ub.trn-doc.doc-type    no-undo .
  define input parameter  p-trn-doc-internal    like ub.trn-doc.internal    no-undo .
  define input parameter  p-trn-doc-discnt-type like ub.trn-doc.discnt-type no-undo .
  define input parameter  p-trn-doc-doc-code    like ub.trn-doc.doc-code    no-undo .
  define input parameter  p-obj-type            like ub.doc-line.obj-type   no-undo .
  define input parameter  p-obj-code            like ub.doc-line.obj-code   no-undo .
  define input parameter  p-artic               like ub.doc-line.artic      no-undo .
  define input parameter  p-prod-type           like ub.doc-line.prod-type  no-undo .
  define input parameter  p-prod-code           like ub.doc-line.prod-code  no-undo .
  define input parameter  p-need-rsrv           as logical no-undo .
  define input parameter  p-place-rsrv          as logical no-undo .
  define input parameter  p-goods-twounit       as logical no-undo .
  define output parameter p-change-qnty         like ub.gds-obj.fact-qnty no-undo .
  define output parameter p-change-base-total   like ub.gds-obj.avrg-base no-undo .
  define output parameter p-change-rubl-total   like ub.gds-obj.avrg-rubl no-undo .
  define output parameter p-total-qnty          like ub.gds-obj.fact-qnty no-undo .
  define output parameter p-total-cli-qnty      like ub.gds-obj.fact-qnty no-undo .
  define output parameter p-total-base-total    like ub.gds-obj.avrg-base no-undo .
  define output parameter p-total-rubl-total    like ub.gds-obj.avrg-rubl no-undo .
  define output parameter p-return-qnty         like ub.gds-obj.fact-qnty no-undo .
  define output parameter p-return-base-total   like ub.gds-obj.avrg-base no-undo .
  define output parameter p-return-rubl-total   like ub.gds-obj.avrg-rubl no-undo .
  define output parameter p-expense-qnty        like ub.gds-obj.fact-qnty no-undo .
  define output parameter p-expense-base-total  like ub.gds-obj.avrg-base no-undo .
  define output parameter p-expense-rubl-total  like ub.gds-obj.avrg-rubl no-undo .
  define output parameter p-total-rsrv-qnty     like ub.gds-obj.fact-qnty no-undo .
  define variable vss-description as character no-undo initial "tdparts: Сбор информации по партиям".
  define buffer archive_parts                 for ub.parts .
  define buffer check_archive_parts           for ub.parts .
  define buffer buf_goods                     for ub.goods .
  define buffer buf_doc-pl                    for ub.doc-pl .
  define buffer buf_temp-trndocrs-pl-gds-rsrv for temp-trndocrs-pl-gds-rsrv .
  define variable v-change-price-base as decimal no-undo .
  define variable v-change-price-rubl as decimal no-undo .
  define variable v-change-qnty       as decimal no-undo .
  define variable v-rsrv-qnty         as decimal no-undo .
  define variable v-change-cli-qnty   as decimal no-undo .
  define variable v-pl-change-qnty    as decimal no-undo .
  define variable v-cli-change-qnty   as decimal no-undo .
  define variable v-cli-rsrv-qnty     as decimal no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-change-qnty        = 0
      p-change-base-total  = 0
      p-change-rubl-total  = 0
      p-total-qnty         = 0
      p-total-cli-qnty     = 0
      p-total-base-total   = 0
      p-total-rubl-total   = 0
      p-return-qnty        = 0
      p-return-base-total  = 0
      p-return-rubl-total  = 0
      p-expense-qnty       = 0
      p-expense-base-total = 0
      p-expense-rubl-total = 0
      p-total-rsrv-qnty    = 0
    .
    define variable v-prihod  as logical no-undo .
    define variable v-vozvrat as logical no-undo .
    assign
      v-prihod = false
    .
    if (p-trn-doc-doc-type = 'при':U
          and( p-trn-doc-internal = no
            or
            (p-trn-doc-internal = yes
                and p-trn-doc-discnt-type = 'прво':U
            )
          )
      )
    then do:
      assign
        v-prihod = true
      .
    end.
    for each archive_parts no-lock
      where archive_parts.out-code  = p-trn-doc-doc-code
        and archive_parts.obj-type  = p-obj-type
        and archive_parts.obj-code  = p-obj-code
        and archive_parts.artic     = p-artic
        and archive_parts.prod-type = p-prod-type
        and archive_parts.prod-code = p-prod-code
    on error undo, return error return-value
    :
      assign
        v-change-qnty = archive_parts.fact-qnty
        v-rsrv-qnty   = archive_parts.qnty
      .
      if p-goods-twounit = true
      then do:
        if archive_parts.fact-qnty = 0
        then do:
          assign
            v-change-cli-qnty = 0
          .
        end.
        else do:
          if archive_parts.fact-qnty = archive_parts.qnty
          then do:
            assign
              v-change-cli-qnty = archive_parts.cli-qnty
            .
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              "Фактическое количество не совпадает с количеством по документу" skip
              "Документ" archive_parts.out-code skip
              "Артикул" archive_parts.artic archive_parts.prod-type archive_parts.prod-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
      end.
      else do:
        assign
          v-change-cli-qnty = archive_parts.fact-qnty / archive_parts.cli-base-rate
        .
      end.
      if p-trn-doc-doc-type = 'рас':U
      or p-trn-doc-doc-type = 'спи':U
      then do:
        assign
          v-change-qnty     = - v-change-qnty
          v-rsrv-qnty       = - v-rsrv-qnty
          v-change-cli-qnty = - v-change-cli-qnty
        .
      end.
      if p-place-rsrv = true then do:
        run trndocrs-pl-gds-accum in this-procedure
          (input archive_parts.pl-code
          ,input (if p-need-rsrv = true then v-rsrv-qnty else 0.0)
          ,input 0.0
          ,input v-change-qnty
          ,input 0.0
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при изменении зарезервированных количеств trndocrs-pl-gds-accum" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      assign
        v-change-price-base = archive_parts.price-base * v-change-qnty
        v-change-price-rubl = archive_parts.price-rubl * v-change-qnty
      .
      assign
        p-total-qnty       = p-total-qnty       + v-change-qnty
        p-total-cli-qnty   = p-total-cli-qnty   + v-change-cli-qnty
        p-total-base-total = p-total-base-total + v-change-price-base
        p-total-rubl-total = p-total-rubl-total + v-change-price-rubl
        p-total-rsrv-qnty  = p-total-rsrv-qnty  + v-rsrv-qnty
      .
      if v-change-qnty > 0
      then do:
        assign
          p-return-qnty        = p-return-qnty        + v-change-qnty
          p-return-base-total  = p-return-base-total  + v-change-price-base
          p-return-rubl-total  = p-return-rubl-total  + v-change-price-rubl
        .
      end.
      else do:
        assign
          p-expense-qnty       = p-expense-qnty       + v-change-qnty
          p-expense-base-total = p-expense-base-total + v-change-price-base
          p-expense-rubl-total = p-expense-rubl-total + v-change-price-rubl
        .
      end.
      assign
        v-vozvrat = false
      .
      if p-trn-doc-doc-type = 'возврат':U
      or (p-trn-doc-doc-type = 'инв':U
          and archive_parts.fact-qnty > 0
         )
      then do:
        assign
          v-vozvrat = true
        .
      end.
      if  v-prihod  <> true
      and v-vozvrat <> true
      and archive_parts.in-code = archive_parts.out-code
      then do:
        next.
      end.
      if v-vozvrat = true
      then do:
        find first check_archive_parts no-lock
          where check_archive_parts.obj-type   = archive_parts.obj-type
            and check_archive_parts.obj-code   = archive_parts.obj-code
            and check_archive_parts.artic      = archive_parts.artic
            and check_archive_parts.prod-type  = archive_parts.prod-type
            and check_archive_parts.prod-code  = archive_parts.prod-code
            and check_archive_parts.in-code    = archive_parts.in-code
            and check_archive_parts.out-code   = 'free-zone':U
            and check_archive_parts.part-code  = archive_parts.part-code
          no-error .
        if not available check_archive_parts
        or check_archive_parts.fact-qnty <= 0
        then do:
          next.
        end.
      end.
      assign
        p-change-qnty       = p-change-qnty       + v-change-qnty
        p-change-base-total = p-change-base-total + v-change-price-base
        p-change-rubl-total = p-change-rubl-total + v-change-price-rubl
      .
    end.
    if p-place-rsrv = true then do:
      find first buf_goods no-lock
        where buf_goods.artic     = p-artic
          and buf_goods.prod-type = p-prod-type
          and buf_goods.prod-code = p-prod-code
        .
      for each buf_doc-pl no-lock
        where buf_doc-pl.obj-type = p-obj-type
          and buf_doc-pl.obj-code = p-obj-code
          and buf_doc-pl.out-code = p-trn-doc-doc-code
          and buf_doc-pl.gds-code = buf_goods.gds-code
      on error undo, return error return-value
      :
        assign
          v-pl-change-qnty  = buf_doc-pl.fact-qnty
          v-cli-change-qnty = buf_doc-pl.cli-fact-qnty
          v-cli-rsrv-qnty   = (if p-need-rsrv = true then buf_doc-pl.cli-doc-qnty else 0.0)
        .
        if p-trn-doc-doc-type = 'рас':U
        or p-trn-doc-doc-type = 'спи':U
        then do:
          assign
            v-pl-change-qnty  = - v-pl-change-qnty
            v-cli-change-qnty = - v-cli-change-qnty
            v-cli-rsrv-qnty   = - v-cli-rsrv-qnty
          .
        end.
        run trndocrs-pl-gds-accum in this-procedure
          (input buf_doc-pl.pl-code
          ,input 0.0
          ,input v-cli-rsrv-qnty
          ,input 0.0
          ,input v-cli-change-qnty
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при изменении зарезервированных количеств trndocrs-pl-gds-accum" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        find first buf_temp-trndocrs-pl-gds-rsrv
          where buf_temp-trndocrs-pl-gds-rsrv.pl-code = buf_doc-pl.pl-code
          .
        if v-pl-change-qnty <> buf_temp-trndocrs-pl-gds-rsrv.fact-qnty
          and v-pl-change-qnty <> 0.00
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Количество по партиям не совпадает с количеством по складским местам." skip
            substitute( "Документ: &1", p-trn-doc-doc-code ) skip
            substitute( "Товар: &1", buf_goods.gds-code )  skip
            substitute( "Место хранения: &1", buf_doc-pl.pl-code )  skip
            substitute( "Количество по партиям: &1 (&2)",  buf_temp-trndocrs-pl-gds-rsrv.fact-qnty , buf_goods.unit-base ) skip
            substitute( "Количество по местам хр.: &1 (&2)", buf_doc-pl.fact-qnty, buf_goods.unit-base ) skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
  end.
end procedure.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure partrqst :
  define input  parameter p-doc-code                   like ub.doc-line.doc-code  no-undo .
  define input  parameter p-obj-type                   like ub.doc-line.obj-type  no-undo .
  define input  parameter p-obj-code                   like ub.doc-line.obj-code  no-undo .
  define input  parameter p-artic                      like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type                  like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code                  like ub.doc-line.prod-code no-undo .
  define output parameter p-total-parts-qnty           like ub.parts.qnty         no-undo .
  define output parameter p-total-parts-fact-qnty      like ub.parts.fact-qnty    no-undo .
  define output parameter p-total-parts-cli-qnty       like ub.parts.cli-qnty     no-undo .
  define output parameter p-total-parts-fact-cli-qnty  like ub.parts.cli-qnty     no-undo .
  define output parameter p-total-parts-price-cli      as decimal                 no-undo .
  define output parameter p-total-parts-price-base     as decimal                 no-undo .
  define output parameter p-total-parts-price-rubl     as decimal                 no-undo .
  define output parameter p-total-parts-transport-base as decimal                 no-undo .
  define output parameter p-total-parts-transport-rubl as decimal                 no-undo .
  define output parameter p-total-parts-other-base     as decimal                 no-undo .
  define output parameter p-total-parts-other-rubl     as decimal                 no-undo .
  define variable vss-description as character no-undo init "partrqst: Суммарная информация по всем зарезервированным партиям строки документа".
  do
  on error undo, return error return-value
  :
    assign
      p-total-parts-qnty           = 0
      p-total-parts-fact-qnty      = 0
      p-total-parts-cli-qnty       = 0
      p-total-parts-fact-cli-qnty  = 0
      p-total-parts-price-cli      = 0
      p-total-parts-price-base     = 0
      p-total-parts-price-rubl     = 0
      p-total-parts-transport-base = 0
      p-total-parts-transport-rubl = 0
      p-total-parts-other-base     = 0
      p-total-parts-other-rubl     = 0
    .
    define buffer buf_parts for ub.parts .
    for each buf_parts no-lock
      where buf_parts.out-code  = p-doc-code
        and buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
    on error undo, return error return-value
    :
      define variable v-parts-fact-multiplier as decimal   no-undo .
      assign
        v-parts-fact-multiplier = 1
      .
      if buf_parts.qnty <> 0 then do:
        assign
          v-parts-fact-multiplier = buf_parts.fact-qnty / buf_parts.qnty
        .
      end.
      assign
        p-total-parts-qnty            = p-total-parts-qnty       + buf_parts.qnty
        p-total-parts-fact-qnty       = p-total-parts-fact-qnty  + buf_parts.fact-qnty
        p-total-parts-cli-qnty        = p-total-parts-cli-qnty   + buf_parts.cli-qnty
        p-total-parts-fact-cli-qnty   = p-total-parts-fact-cli-qnty
                                      + buf_parts.cli-qnty * v-parts-fact-multiplier
        p-total-parts-price-cli       = p-total-parts-price-cli  + buf_parts.cli-qnty  * buf_parts.price-cli
        p-total-parts-price-base      = p-total-parts-price-base + buf_parts.fact-qnty * buf_parts.price-base
        p-total-parts-price-rubl      = p-total-parts-price-rubl + buf_parts.fact-qnty * buf_parts.price-rubl
        p-total-parts-transport-base  = p-total-parts-transport-base
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.transport-base <> ?
                                          then buf_parts.transport-base
                                          else 0
                                          )
        p-total-parts-transport-rubl  = p-total-parts-transport-rubl
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.transport-rubl <> ?
                                          then buf_parts.transport-rubl
                                          else 0
                                          )
        p-total-parts-other-base      = p-total-parts-other-base
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.other-base <> ?
                                          then buf_parts.other-base
                                          else 0
                                          )
        p-total-parts-other-rubl      = p-total-parts-other-rubl
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.other-rubl <> ?
                                          then buf_parts.other-rubl
                                          else 0
                                          )
      .
    end.
  end.
end procedure.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
function hvrdtax return logical (input parrecid as recid):
define variable varresult as logical no-undo.
run hvrdtax-proc (input parrecid, output varresult).
return varresult.
end function.
procedure hvrdtax-proc:
define input  parameter parrecid  as recid   no-undo.
define output parameter parresult as logical no-undo.
define buffer bf_goods for ub.goods.
define buffer bf_units for ub.units.
define buffer rt_tax   for ub.tax.
find first rt_tax   where rt_tax.tax-code    = integer('3':U) no-lock no-error.
find first bf_goods where recid(bf_goods)    = parrecid              no-lock.
find first bf_units where bf_units.unit-name = bf_goods.unit-base    no-lock.
if available rt_tax and
    can-find(first ub.tax-units No-LOCK WHERE
                   ub.tax-units.tax-code = rt_tax.tax-code AND
                   LOOKUP(ub.tax-units.type, bf_units.type) > 0) then assign parresult = yes.
                                                    else assign parresult = no.
end procedure.
def var vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info18 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info18, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info18, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info18, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info18, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info18 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info18, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info18 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info18, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info18, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info18, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info18, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info18, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info18, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info18 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info18 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info18, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info18, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info18, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info18 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info18 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info18, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info18, v-inform, v-tbl-name ).
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
def var vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info20 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable mMRCCode  as logical    no-undo.
define variable mTypeMark as character  no-undo.
function IS-NeedMark returns logical
( input ib-code as integer  ,
  input ib-str as character ):
   define buffer buf_prod-bc-attr for ub.prod-bc-attr.
   find first buf_prod-bc-attr where buf_prod-bc-attr.b-code eq ib-code
                                 and buf_prod-bc-attr.b-str  eq ib-str
                                 and buf_prod-bc-attr.attr-code eq 'mark':U
     no-lock no-error.
   return if available buf_prod-bc-attr then logical(buf_prod-bc-attr.attr-value) else no .
end.
function repTegforDm return char
(iDM as char ):
    define variable vTeglist as character no-undo init "01,02,11,13,17,21,8005,37".
    define variable vteg as character no-undo.
    define variable oDM as character no-undo.
    define variable vi as integer no-undo.
    oDM = iDm.
    do vi = 1 to num-entries(vTeglist):
       vTeg = entry(vi,vTeglist).
       oDM = replace(oDM,"(" + vTeg + ")",vTeg).
    end.
    return oDM.
end.
function repSpecSimbforDm return char
(iDM as char ):
    define variable oDM as character no-undo.
  run
    xmlchar-decode(iDM, output oDM).
  return repTegforDm (oDM).
end.
function CheckGtin return logical
(iGtin as char):
   define variable bar_code as character no-undo.
   define variable vGtin as logical no-undo init "yes".
   if length(iGtin) eq 14
   then do:
      bar_code = substr (iGtin, 1, length (iGtin) - 1).
      run str/chk-sum.p
       (input-output bar_code ) no-error .
      if iGtin ne  bar_code
      then
         vGtin = no.
   end.
   else
      vGtin = no.
   return vgtin.
end.
function repSpecSimbforXlm return char
(iDM as char ):
    iDM = replace(iDM,chr(29),"").
    return iDM.
end.
function getGtinByDM return char
(IDM as char):
   define variable VTXT as char no-undo.
   define variable vGtin as char no-undo.
   vTXt = IdM.
   vGtin = IDM.
   if    length(vtxt) > 14
   then do:
      if   vtxt begins "(01)"
             or vtxt begins "(02)"
      then
         vGtin = substring(vtxt,5,14).
      else if   (vtxt begins "01"
             or vtxt begins "02" )
             and (   (    substring(iDm,17,2) eq "21"
                      and length(vtxt) >= 21)
                  or substring(iDm,17,2) eq "37"
                  or substring(iDm,17,4) eq "(37)" )
      then do:
         vGtin = substring(vtxt,3,14).
         if not checkGtin(vGtin)
         then
            vGtin = substring(vtxt,1,14).
      end.
      else if     length(vtxt) eq 14 + 7 + 4 + 4
          or length(vtxt) eq 14 + 7 + 4
          or length(vtxt) eq 14 + 7
      then
         vGtin = substring(vtxt,1,14).
   end.
   if not checkGtin(vGtin)
   then
      vGtin = "".
   return vgtin.
end.
function getGdsCodeByGtin return int
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin  and prod-bc.bc-on no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.gds-code else ?.
end.
function getQntyCodeByGtin return decimal
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.cli-base-rate else ?.
end.
function getGdsCodeByDM return int
(iDm as char):
   define variable vGtin as char no-undo.
   define buffer prod-bc for ub.prod-bc.
   vGtin  = getGtinByDM (IDM ).
   return getGdsCodeByGtin (vGtin).
end.
function ChekTypeMarkByGds return logical
(iGds-code as integer ):
   define buffer goods-attr for ub.goods-attr.
   find first goods-attr where goods-attr.gds-code   = iGds-code
                           and goods-attr.attr-code  = 'mark-type':U
   no-lock no-error.
   if available goods-attr
   then do:
      mTypeMark = goods-attr.attr-value.
      return goods-attr.attr-value = objsrv:Env:Marking:Types:tabak:NameProp
        .
   end.
   else
      return no.
end.
function ChekTypeMarkByDm return logical
(iDM as char ):
   return ChekTypeMarkByGds(getGdsCodeByDM(idm)).
end.
function ChekTypeMarkByGtin return logical
(iGtin as char ):
   return ChekTypeMarkByGds(getGdsCodeByGtin(iGtin)).
end.
function GetNextElement return character
  (input iAllTeg        as logical
  ,output oteg          as character
  ,output otegval       as character
  ,input-output pstr    as character
   ):
     define variable vlistElem   as character no-undo init "00,01,02,21,17,11,13,(01),(02),(21),(17),(11),(13)".
     define variable vlistleng   as character no-undo init "27,14,14,13,06,06,06,0014,0014,0013,0006,0006,0006".
     define variable vlistElemDop   as character no-undo init ",37,(37),(8005),8005,93,(93)".
     define variable vlistlengDop   as character no-undo init ",08,0008,000006,0006,04,0004".
     define variable vTeg as character no-undo.
     define variable vLength as integer no-undo.
     define variable vi as integer no-undo.
     define variable vj as integer no-undo.
     define buffer code for ub.code.
     find first code where Code.parent eq "MarkType"
                       and Code.CodeValue   eq mTypeMark
                       no-lock no-error.
     if     available code
        and Code.misc1 ne ""
        and Code.misc1 ne ?
     then do:
        integer (Code.misc1) no-error.
        if not error-status:error
        then
          entry (4,vlistleng) = Code.misc1.
     end.
     if iAllTeg
     then
        assign
           vlistElem     = vlistElem    + vlistElemDop
           vlistleng     = vlistleng    + vlistlengDop
        .
     else if mMRCCode
     then
        assign
           vlistElem     = vlistElem    + ",(8005),8005"
           vlistleng     = vlistleng    + ",000006,0006"
        .
    block-elem:
    do vi = 1 to num-entries(vlistElem):
       vTeg = entry(vi,vlistElem).
       if pstr begins vTeg
       then do:
          if    vTeg eq "21"
          then
             vLength = index(pstr,chr(29)) - 2 no-error.
          if vLength  <= 0
          then
             vLength = int(entry(vi,vlistleng)).
          otegval = substring (pstr,length(vteg) + 1, vLength).
          oteg = replace(replace(vteg,")",""),"(","").
          vTeg = vteg + otegval.
          otegval = replace(otegval,chr(29),"").
          oteg = replace(replace(oteg,")",""),"(","").
          pstr = substring (pstr,length(vTeg)+ 1).
          vTeg = replace(vTeg,chr(29),"").
          leave block-elem.
       end.
       else
          vTeg = "".
    end.
    return vteg.
end.
function GetCodeIdent return character
(iDm as char):
   define variable Velement   as character no-undo init "first".
   define variable oCodeIdent as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define variable vGtin as character no-undo.
   define buffer marking for ub.marking.
   for first marking no-lock where
             marking.mark eq iDm
         and marking.unit-ext = "LEVEL2"
   :
     return iDm.
   end.
   vGtin  = getGtinByDM (iDm ).
   ChekTypeMarkByDm(idm).
   if iDm begins 'tech_':U
   then
      oCodeIdent = iDm.
   else if length(iDm) < 21
   then do:
      find first marking where marking.mark eq idm
      no-lock no-error.
      oCodeIdent = if available marking then marking.mark else  ?.
   end.
   else if     length(iDm) eq 29
      and not iDm begins "01"
      and not iDm begins "02"
   then
      oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21 ).
   else  if     length(iDm) >= 24
            and (  iDm begins "01"
                or iDm begins "02")
            and  substring(iDm,17,2) ne "21"
   then do:
      if checkGtin(substring(iDm,1,14)) and ( (length(idm) eq 25 and substring(iDm,22,1) eq "A")
                                                or (length(idm) eq 29 and substring(iDm,22,1) eq "A"))
      then
         oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21).
      else
         oCodeIdent = iDM.
   end.
   else  if     (   length(iDm) eq 25
                 or length(iDm) eq 21)
            and (not iDm begins "01"
            and  not iDm begins "02")
   then
      oCodeIdent = substring(iDm,1,21).
   else if vGtin = substring(iDm,1,14) and checkGtin(substring(iDm,1,14)) and ( length(idm) eq 21 or (length(idm) eq 25 and substring(iDm,22,1) eq "A"))
   then
      oCodeIdent = substring(iDm,1,21).
   else do while Velement ne "" and idm ne "":
      Velement = GetNextElement(no,output vteg, output vtegval, input-output idm).
      oCodeIdent = oCodeIdent + Velement.
   end.
   return oCodeIdent.
end.
function GetTegCod return character
(icodeIdent as char, iTeg as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo init ?.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if     ((length(icodeIdent) eq 21
      and not icodeIdent begins "01"
      and not icodeIdent begins "02")
      or
          ( length(icodeIdent) eq 25
            and not icodeIdent begins "01"
            and not icodeIdent begins "02"))
   then do:
      if iTeg eq "01" or iTeg eq "02"
      then
         oTeg = substring(icodeIdent,1,21).
      else  if  iTeg eq "21"
      then
         oTeg = substring(icodeIdent,15,7).
   end.
   else do:
      ChekTypeMarkByDm(icodeIdent).
      block-teg:
         do while Velement ne "" and icodeIdent ne "":
         Velement = GetNextElement(yes,output vteg, output vtegval, input-output icodeIdent).
         if    Velement begins iTeg
            or Velement begins "(" + iTeg + ")"
         then do:
            oTeg = vtegval.
            leave block-teg.
         end.
      end.
   end.
   return oTeg.
end.
function isOAD return logical
(icodeIdent as character):
   return length(icodeIdent) > 18 and GetTegCod(icodeIdent,"37") ne ? and GetTegCod(icodeIdent,"02") ne ?.
end.
function isMark return logical
(icodeIdent as character):
   define buffer buf_marking for ub.marking.
   return can-find(first buf_marking where buf_marking.mark begins icodeIdent) or
          (length(icodeIdent) > 20 and not isOAD(icodeIdent)).
end.
function addBracketForCode return character
(icodeIdent as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define buffer marking for ub.marking.
   find first marking no-lock where
              marking.mark begins icodeIdent no-error.
   if    not ChekTypeMarkByDm(icodeIdent)
      or length(icodeIdent) le 24
      or (avail marking and marking.unit-ext = "LEVEL2")
   then
      oTeg = icodeIdent.
   else do:
      if (  icodeIdent begins "01"
         or icodeIdent begins "02"
         ) and CheckGtin(substring (icodeIdent,3,14))
         and substring (icodeIdent,17,2) eq "21"
      then do:
         mMRCCode = yes.
         ChekTypeMarkByDm(icodeIdent).
         block-teg:
         do while Velement ne "" and icodeIdent ne "":
            Velement = GetNextElement(no,output vteg, output vtegval, input-output icodeIdent).
            if vteg ne ""
            then
               oTeg = oTeg + "(" + vteg + ")" + vtegval .
         end.
         mMRCCode = no.
      end.
      else do:
         oTeg = icodeIdent.
      end.
   end.
   return oTeg.
end.
function getlevelByCodId return int
(iCode as char):
   define variable vLength as int no-undo.
   define variable vLevel  as int no-undo.
   if not ChekTypeMarkByDM (icode) then return ?.
   vLength = length(iCode).
   if    vLength eq 18
      or vLength eq 20
   then
      Vlevel = 4.
   else if vLength eq 21
   then
      Vlevel = 1.
   else if vLength eq 25
   then do:
      if  iCode begins "01"
      then
         Vlevel = 3.
      else
         Vlevel = 1.
   end.
   else if     vLength >= 26
           and vLength <= 46
   then do:
      if    substring(iCode,17,2) eq "11"
         or substring(iCode,17,2) eq "13"
         or (    substring(iCode,17,2) eq "21"
             and vLength >= 33
             and substring(iCode,26,4) ne "8005")
      then
         Vlevel = 4.
      else if    vLength eq 31
              or vLength eq 38
              or vLength eq 39
              or vLength eq 45
      then
         Vlevel = 1.
      else if    vLength eq 35
              or vLength eq 43
      then
         Vlevel = 3.
      else
         Vlevel = ?.
   end.
   else
      Vlevel = ?.
   return Vlevel.
end.
function getLevelMotpBycodid return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 6
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByLevelMotp return character
(iUnit as char):
   define variable vLevel as integer no-undo.
   define variable vListMOTP    as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   define variable vListutd as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = lookup(iUnit,vListMOTP).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vListutd).
end.
function getLevelMotpByDM return character
(iDm as char):
   return getLevelMotpByCodId(GetCodeIdent(iDm)).
end.
function getLevelUTDByCodId return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByDM return character
(iDm as char):
   return getLevelUTDByCodId(GetCodeIdent(iDm)).
end.
define variable mNotMarkQnty as logical no-undo.
function getQntyUTDByCodId return decimal
(iDM as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "1,5,10,500".
   define variable vGtin as character no-undo.
   define variable vqnty as decimal no-undo init ?.
   vqnty = dec(GetTegCod(iDM,"37")) no-error.
   if vqnty eq ?
   then do:
      if not mNotMarkQnty
      then do:
         define buffer marking for ub.marking.
         define variable vCodident as character no-undo.
         vCodident = GetCodeIdent(idm).
         find first marking where marking.mark begins vCodident no-lock no-error.
         if     available marking
            and marking.box-qnty ne ?
         then
            return marking.box-qnty.
      end.
      vGtin = getGtinByDm(iDM).
      if ChekTypeMarkByGtin (vGtin)
      then do:
         vLevel = getlevelByCodId(iDM).
         if     vLevel >= 1
            and vLevel <= 4
         then
            vqnty = int(entry(vlevel,vList)).
      end.
      else
         vqnty = getQntyCodeByGtin(vgtin).
   end.
   return vqnty.
end.
function getQntyUTDByDM return decimal
(iDm as char):
   define variable vDM as character no-undo.
   if     length (iDm) ne 25
      and length (iDm) ne 29
      and substring (iDm,length (iDm) - 6 + 1, 2 ) eq "93"
   then
      vDM = substring (iDm,1,length (iDm) - 6 ).
   else
      vDM = substring (iDm,1,length (iDm) - 4 ).
   return getQntyUTDByCodId(vDM).
end.
function getMRC4 return decimal
(iMRC as char):
   define variable oMrc     as decimal no-undo init ?.
   define variable vAlphabet as character no-undo init "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!~"%&'*+-./_,:;=<>?".
   define variable vi       as integer no-undo.
   define variable vfound   as integer no-undo.
   define variable vposStart   as integer no-undo.
   do:
   OMRc = 0.
   do vi = 1 to 4:
      define variable vsimb as character no-undo.
      vsimb = substring(iMRC,vi,1).
      vposStart = if keycode("Z") < keycode(vsimb) then 27 else 1.
      vfound = index(vAlphabet,vsimb,vposStart) - 1.
      if vfound > 0
      then
         OMRc = OMRc + exp (80,(4 - vi) ) * vfound  .
      end.
      OMRc = OMRc / 100.
   end.
   return OMRc.
end.
function getMRCByDM return decimal
(iDm as char):
   define variable vMRC     as character no-undo.
   define variable oMrc     as decimal no-undo init ?.
   define variable Velement as character no-undo init "empty".
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if    length(idm) eq 14 + 7 + 4 + 4
      or length(idm) eq 14 + 7 + 4
   then do:
      vMRC = substring(idm,22,4).
      omrc = getMRC4(vMRC).
   end.
   else do:
       ChekTypeMarkByDm(iDm).
       block-mrc:
       do while Velement ne "" and idm ne "":
          Velement = GetNextElement(yes,output vteg, output vtegval, input-output idm).
          if Velement begins "8005"
          then do:
             vMRC = substring(Velement,5,6).
             leave block-mrc.
          end.
          else if Velement begins "(8005)"
          then do:
             vMRC = substring(Velement,7,6).
             leave block-mrc.
          end.
       end.
       if vMRC ne ""
       then
          OMRc = dec(vmrc) / 100 no-error.
   end.
   return OMRc.
end.
function MoveDate return Date
(idate as date,
 iMonth as int64):
   define variable vMonth   as int64 no-undo.
   define variable vYear    as int64 no-undo.
   define variable vDateNew as date  no-undo.
    define variable vDay     as int64 no-undo.
    vMonth = month(iDate) + iMonth.
    vYear =  year(iDate).
    if vMonth <= 0
    then assign
       vMonth = vMonth + 12
        vYear  = vYear - 1
    .
    else if vMonth > 12
    then assign
       vMonth = vMonth - 12
        vYear  = vYear + 1
    .
    vDateNew = date(vMonth,day(iDate),vYear) no-error.
    do while error-status:error eq yes:
       VDay = vDay + 1.
       vDateNew = date(vMonth,day(iDate) - vDay,vYear) no-error.
    end.
    if VDay > 0
    then
       vDateNew + 1.
    return vDateNew.
end.
procedure checkEMRC:
define input  parameter iDm as character no-undo.
define output parameter vok as logical   no-undo init yes.
   define variable v-value-emrc as character no-undo.
   define variable v-type-emrc  as character no-undo.
   define variable vDateIso     as character no-undo.
   define variable vMRC         as decimal no-undo.
   define variable vqnty        as decimal no-undo.
   define variable vPrice       as decimal no-undo.
   define variable vparent      as character no-undo.
   define variable vgds-code    as integer no-undo.
   define buffer code for ub.code.
   vMRC = getMRCByDM(iDm).
   if vMRC > 0
   then do:
      vgds-code = getGdsCodeByDM(iDm).
      vqnty     = getQntyUTDByDM(iDm).
            if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
         (
          input   vgds-code
         ,input   'emrc-type':U
         ,output   v-value-emrc
         ,output   v-type-emrc
       ) no-error.
       if     v-value-emrc ne ""
          and v-value-emrc ne ?
       then do:
          vDateIso = iso-date(today).
          vPrice = vMRC / vqnty.
          vparent ="emc" + chr(4) + v-value-emrc.
          find last code where Code.parent      eq vparent
                           and Code.code        le vDateIso
                           and code.status_  eq 0
          no-lock no-error.
          if not available code or ( vPrice  >= dec(Code.CodeValue))
          then
             vOk = true .
          else do:
              define variable vText      as character no-undo.
              define variable vDate      as date no-undo.
              define variable vDateLast  as character no-undo.
              define variable vDateFirst as character no-undo.
              define variable vDate3     as date no-undo.
              vdate = date(code.misc1).
              vDateLast = code.misc1.
              vDate3 = MoveDate(today, - 3 ).
              vText =  substitute ("ТОВАР ИМЕЕТ ОГРАНИЧЕННЫЙ СРОК РЕАЛИЗАЦИИ. Если товар произведен после &2, то его приемка и продажа запрещена.",
                                   string(vDate3  , "99/99/9999"),
                                   string(vDate   , "99/99/9999")
                                   ).
              vdateIso = iso-date(vdate3).
              find last code  where Code.parent      eq vparent
                                and Code.code        le vDateIso
                                and code.status_  eq 0 no-lock no-error.
              if available code
              then
                 vDateIso = code.code.
              vDateFirst = vDateIso.
              vDateLast = iso-date(vdate).
              define variable vGood as logical no-undo.
              define variable vDateSale as date no-undo.
              define buffer bcode for code.
              for last code where Code.parent   eq vparent
                              and code.status_  eq 0
                              and code.code     < vDateLast
                              and code.code     >= vDateFirst
              no-lock:
                 find first bcode where bCode.parent   eq vparent
                                    and bcode.status_  eq 0
                                    and bcode.code     > code.code no-lock no-error.
                 if available bcode
                 then do:
                    if vPrice < dec(Code.CodeValue)
                    then
                       vText = vtext + substitute ("&1Если товар произведен с &2 до &3, ТО ЕГО ПРИЕМКА И ПРОДАЖА ЗАПРЕЩЕНА",
                                                  chr(10),
                                                  string(    date( code.misc1)       ,"99/99/9999"),
                                                  string(    date(bcode.misc1)       ,"99/99/9999")
                                                  ).
                    else do:
                       vGood = yes.
                       vDateSale = MoveDate(date(bcode.misc1), 3) - 1.
                       vText = vtext + substitute ("&1Если товар произведен до &3, то продажа разрешена до &4.~Осталось &5 дней.",
                                                  chr(10),
                                                  string(    date( code.misc1)         ,"99/99/9999"),
                                                  string(    date(bcode.misc1)         ,"99/99/9999"),
                                                  string(         vDateSale            ,"99/99/9999"),
                                                  string(vDateSale - today)
                                                  ).
                    end.
                 end.
              end.
              if vgood
              then do:
                 define variable choice as integer no-undo .
                 run gbl/d-askw.w (input "Уточнение"
                        ,input  vText
                        ,input "|"
                        ,input "Принять|Вернуть"
                        ,input "Принять данный товар|Вернуть товар постащику"
                        ,input 1
                        ,input 2
                        ,output choice) no-error.
                 vok = choice eq 1.
              end.
              else
                 vok =false.
          end.
       end.
   end.
end.
function addGs2Mark return character
(iMark as char):
   define variable vDM   as character no-undo.
   define variable vIdx  as integer   no-undo.
   if index(iMark,chr(29),1) > 0
   then return iMark.
   if substring(iMark,26,4) = "8005" then
   do:
     vIdx = index(iMark,"93",26 + 4 + 5).
     if vIdx > 1 then do:
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,25),
                        substring(iMark,26,vIdx - 25 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       vIdx = index(vDm,"240",vIdx + 4).
       if vIdx > 0 then
       do:
         vDM = substitute("&1&3&2",
                          substring(vDm,1,vIdx - 1),
                          substring(vDm,vIdx),
                          chr(29)) no-error.
       end.
     end.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,25),
                        substring(iMark,26),
                        chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "91" then
   do:
     vIdx = index(iMark,"92",32).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,31),
                        substring(iMark,32,vIdx - 31 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,31),
                        substring(iMark,32),
                        chr(29)) no-error.
   end.
   else if substring(iMark,39,2) = "91" then
   do:
     vIdx = index(iMark,"92",38).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,38),
                        substring(iMark,39,vIdx - 38 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,38),
                        substring(iMark,39),
                        chr(29)) no-error.
   end.
   else if substring(iMark,25,2) = "93" then
   do:
     vIdx = index(iMark,"92",25).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vIdx = index(iMark,"3103",25).
       if vIdx > 0 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       else
         vDM = substitute("&1&3&2",
                          substring(iMark,1,24),
                          substring(iMark,25),
                          chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "93" then
   do:
     vDM = substitute("&1&3&2",
           substring(iMark,1,31),
           substring(iMark,32),
           chr(29)) no-error.
   end.
   return if vDM <> "" then vDm else iMark.
end.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure partcopy :
  define input parameter  p-free-output-copy as logical   no-undo .
  define input parameter  p-out-code         like ub.parts.out-code no-undo .
  define parameter buffer buf_orig_parts     for ub.parts .
  define parameter buffer buf_parts          for ub.parts .
  define input parameter  p-mark             as character no-undo .
  define variable vss-description as character no-undo init "partcopy-01: процедура копирования партии".
  define variable v-value-character as character no-undo .
  define variable v-value-date      as date no-undo .
  define variable v-value-decimal   as decimal no-undo .
  define variable v-value-integer   as integer no-undo .
  define variable v-izlcstpr        as logical no-undo .
  define variable v-tth             as handle no-undo .
  define variable v-type            as character no-undo .
  define variable part-key-rec      as character no-undo .
  define variable orig-part-key-rec as character no-undo .
  define variable del-part-key-rec  as character no-undo .
  define variable objMarks as class excisemarks  no-undo .
  define variable v-parent-mark-sts as integer   no-undo .
  define variable v-mark-sts-list   as character no-undo .
  define variable oMarkSts as class ibs.th.str.marking.sts.mark .
  oMarkSts = objSrv:Env:Marking:Sts:Mark.
  define buffer buf_gen-attr for ub.gen-attr .
  define buffer buf1_gen-attr for ub.gen-attr .
  define buffer buf_doc-line  for ub.doc-line .
  define buffer buf_marking for ub.marking .
  define buffer buf_marking-childs for ub.marking .
  define buffer orig_marking-lines for ub.marking-lines .
  define buffer orig_marking-lines-childs for ub.marking-lines .
  define buffer buf_marking-lines for ub.marking-lines .
  define buffer buf_marking-lines-childs for ub.marking-lines .
  define buffer buf_marking-pack for ub.marking .
  define buffer buf_marking-chk for ub.marking-chk .
  define buffer buf_goods for ub.goods .
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer pri_trn-doc for ub.trn-doc .
  define buffer buf_chk-doc for ub.chk-doc .
  do
  on error undo, return error return-value
  :
    if p-free-output-copy = true
    then do:
      if  p-out-code <> 'free-zone':U
      and p-out-code <> 'out-zone':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info21 skip
          "Ошибка задания входных параметров процедуры partcopy" skip
          "p-free-output-copy" p-free-output-copy skip
          "p-out-code" p-out-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    if buf_orig_parts.out-code <> p-out-code
    then do:
      find first buf_parts exclusive-lock
        where buf_parts.obj-type  = buf_orig_parts.obj-type
          and buf_parts.obj-code  = buf_orig_parts.obj-code
          and buf_parts.artic     = buf_orig_parts.artic
          and buf_parts.prod-type = buf_orig_parts.prod-type
          and buf_parts.prod-code = buf_orig_parts.prod-code
          and buf_parts.in-code   = buf_orig_parts.in-code
          and buf_parts.out-code  = p-out-code
          and buf_parts.part-code = buf_orig_parts.part-code
        no-error.
      if not available buf_parts
      then do:
        define variable v-rsrv-free as logical   no-undo .
        if p-out-code = 'free-zone':U
        or p-out-code = 'out-zone':U
        then do:
          assign
            v-rsrv-free =
       (if p-out-code = 'free-zone':U then yes else no)
          .
        end.
        else do:
          assign
            v-rsrv-free = ?
          .
        end.
        create buf_parts .
        buffer-copy buf_orig_parts to buf_parts
        assign
          buf_parts.out-code  = p-out-code
          buf_parts.status_   = no
          buf_parts.rsrv-free = v-rsrv-free
          buf_parts.qnty      = 0
          buf_parts.fact-qnty = 0
          buf_parts.real-qnty = 0
          buf_parts.cli-qnty  = 0
        .
        validate buf_parts .
      end.
      run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer buf_orig_parts:handle)
                                        ,output orig-part-key-rec).
      run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer buf_parts:handle)
                                        ,output part-key-rec).
      for each ub.gen-attr no-lock where ub.gen-attr.table-name = 'excise-mark':U
            and ub.gen-attr.p-key =  orig-part-key-rec:
          if not valid-object (objMarks)
            then objMarks = new excisemarks (buf_parts.obj-type, buf_parts.obj-code).
            if p-out-code = 'free-zone':U
            and (entry(7,orig-part-key-rec,chr(3)) = entry(8,orig-part-key-rec,chr(3)) )
             then
            do:
                objMarks:CrFreeMarkForParts(buffer buf_orig_parts, buffer buf_parts, ub.gen-attr.attr-code) .
                if objMarks:StatusErr
                    then
                do:
                    message objMarks:ReturnMsg view-as alert-box error.
                    delete object objMarks no-error.
                    undo, return error.
                end.
            end.
          if (entry(7,orig-part-key-rec,chr(3)) <> entry(8,orig-part-key-rec,chr(3)) ) then
          do:
              if p-mark <> "" then do:
              if p-out-code = 'free-zone':U then do:
                objMarks:RezervMarkForParts(buffer buf_parts, buffer buf_orig_parts, p-mark) .
              end.
              else do:
                objMarks:RezervMarkForParts(buffer buf_orig_parts, buffer buf_parts, p-mark) .
              end.
              if objMarks:StatusErr
                then
              do:
                message objMarks:ReturnMsg view-as alert-box error.
                delete object objMarks no-error.
                undo, return error.
              end.
            end.
          end.
          if p-out-code = 'out-zone':U then
          do:
              objMarks:CrOutMarkForParts(buffer buf_orig_parts, buffer buf_parts, ub.gen-attr.attr-code) .
              if objMarks:StatusErr
                  then
              do:
                  message objMarks:ReturnMsg view-as alert-box error.
                  delete object objMarks no-error.
                  undo, return error.
              end.
          end.
      end.
      delete object objMarks no-error.
      if p-mark = "news" then return .
      find first pri_trn-doc no-lock where pri_trn-doc.doc-code = buf_orig_parts.out-code no-error .
      find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-out-code no-error.
      if not available buf_trn-doc
      then
         find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_orig_parts.out-code no-error .
      if (
          p-out-code = 'free-zone':U
          and buf_orig_parts.in-code = buf_orig_parts.out-code
         )
      or
         (
          p-out-code = 'free-zone':U
          and available pri_trn-doc
          and (pri_trn-doc.ext-doc-type = 'iv':U or pri_trn-doc.ext-doc-type = 'rv':U)
         )
      or
         (
          available buf_trn-doc
          and p-out-code = buf_trn-doc.doc-code
          and buf_trn-doc.ext-doc-type = 'vt':U
         )
      or
         (
          p-mark = ""
          and available buf_trn-doc
          and p-out-code = 'free-zone':U
          and buf_trn-doc.ext-doc-type = 'vt':U
         )
      or
         (
          p-mark = ""
          and available buf_trn-doc
          and p-out-code = 'free-zone':U
          and buf_trn-doc.ext-doc-type = 'rs':U
         )
      then do :
        find first ub.goods no-lock where ub.goods.artic = buf_parts.artic
          and ub.goods.prod-type = buf_parts.prod-type
          and ub.goods.prod-code = buf_parts.prod-code.
        def buffer buf_orig_ml for ub.marking-lines.
        for each buf_orig_ml where buf_orig_ml.gds-code = ub.goods.gds-code
          and buf_orig_ml.obj-type = buf_orig_parts.obj-type
          and buf_orig_ml.obj-code = buf_orig_parts.obj-code
          and buf_orig_ml.in-code = buf_orig_parts.in-code
          and buf_orig_ml.out-code = buf_orig_parts.out-code
          and buf_orig_ml.part-code = buf_orig_parts.part-code
          and buf_orig_ml.prt-code = buf_orig_parts.prt-code:
          if available pri_trn-doc
          and pri_trn-doc.ext-doc-type = 'iv':U
          and buf_orig_ml.sts <> objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
          then do :
            for first buf_marking exclusive-lock where buf_marking.mark = buf_orig_ml.mark :
              assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB .
            end .
            next .
          end .
          find first ub.marking-lines no-lock where ub.marking-lines.mark     = buf_orig_ml.mark
                                                and ub.marking-lines.gds-code = buf_orig_ml.gds-code
                                                and ub.marking-lines.obj-type = buf_orig_ml.obj-type
                                                and ub.marking-lines.obj-code = buf_orig_ml.obj-code
                                                and ub.marking-lines.in-code  = buf_orig_ml.in-code
                                                and ub.marking-lines.out-code = p-out-code
                                                and ub.marking-lines.part-code = buf_orig_ml.part-code
                                                and ub.marking-lines.prt-code = buf_orig_ml.prt-code
                                                no-error .
          if not available ub.marking-lines
          then do :
            create ub.marking-lines.
            buffer-copy buf_orig_ml to ub.marking-lines
            assign
              ub.marking-lines.out-code  = p-out-code
              ub.marking-lines.fact-order = pri_trn-doc.fact-order when available pri_trn-doc
            .
            validate ub.marking-lines.
          end .
          if avail buf_trn-doc and buf_trn-doc.doc-type <> 'инв':U then do:
          for first buf_marking exclusive-lock where buf_marking.mark = buf_orig_ml.mark
            and not (buf_marking.sts = oMarkSts:MarkError:KeyIntDB and available (buf_trn-doc) and buf_trn-doc.ext-doc-type = 'vt':U):
            if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB and
               buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB and
               not can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(buf_marking.sts)) and
               not can-do(objSrv:Env:Marking:Sts:Mark:Doc_Status,string(buf_marking.sts)) and
               buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
            then do:
              buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
              validate buf_marking.
            end.
          end .
        end .
        end.
      end .
      define variable v-doc-type  as character no-undo .
      define variable   v-status    as character no-undo .
      define variable v-fact-qnty   as  decimal no-undo .
      define variable ii    as integer no-undo .
      find first buf_goods no-lock where buf_goods.artic = buf_orig_parts.artic
                                     and buf_goods.prod-type = buf_orig_parts.prod-type
                                     and buf_goods.prod-code = buf_orig_parts.prod-code
                                     .
      if available pri_trn-doc
      and pri_trn-doc.ext-doc-type = 'rs':U
      then do :
        if p-mark <> ""
        then do :
        end .
        else do :
        end .
      end .
      else do :
        if buf_orig_parts.in-code <> buf_orig_parts.out-code
        and p-mark <> ""
        then do :
          if p-out-code = 'free-zone':U
          then do:
              if chg-qnty < 0
              then do :
                find first orig_marking-lines no-lock where orig_marking-lines.mark       = p-mark
                                                        and orig_marking-lines.gds-code   = buf_goods.gds-code
                                                        and orig_marking-lines.obj-type   = buf_orig_parts.obj-type
                                                        and orig_marking-lines.obj-code   = buf_orig_parts.obj-code
                                                        and orig_marking-lines.in-code    = buf_orig_parts.in-code
                                                        and orig_marking-lines.out-code   = buf_orig_parts.out-code
                                                        and orig_marking-lines.part-code  = buf_orig_parts.part-code
                                                        and orig_marking-lines.prt-code   = buf_orig_parts.prt-code
                                                        no-error .
                if available orig_marking-lines
                then do :
                  find first buf_marking-lines no-lock where buf_marking-lines.mark       = p-mark
                                                         and buf_marking-lines.gds-code   = buf_goods.gds-code
                                                         and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                         and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                         and buf_marking-lines.in-code    = buf_parts.in-code
                                                         and buf_marking-lines.out-code   = buf_parts.out-code
                                                         and buf_marking-lines.part-code  = buf_parts.part-code
                                                         and buf_marking-lines.prt-code   = buf_parts.prt-code
                                                         no-error .
                  if not available buf_marking-lines
                  then do :
                    create buf_marking-lines .
                    assign
                      buf_marking-lines.mark       = p-mark
                      buf_marking-lines.doc-level  = orig_marking-lines.doc-level
                      buf_marking-lines.gds-code   = buf_goods.gds-code
                      buf_marking-lines.obj-type   = buf_parts.obj-type
                      buf_marking-lines.obj-code   = buf_parts.obj-code
                      buf_marking-lines.in-code    = buf_parts.in-code
                      buf_marking-lines.out-code   = buf_parts.out-code
                      buf_marking-lines.part-code  = buf_parts.part-code
                      buf_marking-lines.prt-code   = buf_parts.prt-code
                    .
                    validate buf_marking-lines.
                  end .
                  for first buf_marking exclusive-lock where buf_marking.mark = p-mark :
                    assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
                    for each buf_marking-chk exclusive-lock where buf_marking-chk.mark begins buf_marking.mark :
                      for first buf_chk-doc no-lock where buf_chk-doc.doc-code = buf_marking-chk.doc-code
                                                      and buf_chk-doc.out-code = buf_orig_parts.out-code
                                                      :
                        assign buf_marking-chk.sts = 0 .
                        validate buf_marking-chk.
                      end .
                    end .
                    if buf_marking.unit-ext <> "UNIT" or
                       (buf_marking.unit-ext = ? and buf_marking.box-qnty > 1)
                    then do :
                      run addChildMarkingLines in this-procedure (
                        buf_marking.mark,
                        objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB,
                        buffer buf_marking-lines,
                        buffer buf_parts,
                        buffer orig_marking-lines,
                        buffer buf_orig_parts,
                        buffer buf_goods
                      ).
                    end .
                  end.
                  find current orig_marking-lines exclusive-lock .
                  delete orig_marking-lines .
                end .
              end .
          end.
          else do:
            find first orig_marking-lines exclusive-lock where orig_marking-lines.mark       = p-mark
                                                           and orig_marking-lines.gds-code   = buf_goods.gds-code
                                                           and orig_marking-lines.obj-type   = buf_orig_parts.obj-type
                                                           and orig_marking-lines.obj-code   = buf_orig_parts.obj-code
                                                           and orig_marking-lines.in-code    = buf_orig_parts.in-code
                                                           and orig_marking-lines.out-code   = buf_orig_parts.out-code
                                                           and orig_marking-lines.part-code  = buf_orig_parts.part-code
                                                           and orig_marking-lines.prt-code   = buf_orig_parts.prt-code
                                                           no-error .
              find first buf_marking-lines no-lock where  buf_marking-lines.mark       = p-mark
                                                      and buf_marking-lines.gds-code   = buf_goods.gds-code
                                                      and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                      and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                      and buf_marking-lines.in-code    = buf_parts.in-code
                                                      and buf_marking-lines.out-code   = buf_parts.out-code
                                                      and buf_marking-lines.part-code  = buf_parts.part-code
                                                      and buf_marking-lines.prt-code   = buf_parts.prt-code
                                                      no-error .
              if not available buf_marking-lines
              then do :
                create buf_marking-lines .
                assign
                  buf_marking-lines.mark       = p-mark
                  buf_marking-lines.doc-level  = 1
                  buf_marking-lines.gds-code   = buf_goods.gds-code
                  buf_marking-lines.obj-type   = buf_parts.obj-type
                  buf_marking-lines.obj-code   = buf_parts.obj-code
                  buf_marking-lines.in-code    = buf_parts.in-code
                  buf_marking-lines.out-code   = buf_parts.out-code
                  buf_marking-lines.part-code  = buf_parts.part-code
                  buf_marking-lines.prt-code   = buf_parts.prt-code
                  buf_marking-lines.sts        = objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB
                .
                validate buf_marking-lines.
              end .
              for first buf_marking exclusive-lock where buf_marking.mark = p-mark :
                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB .
                validate buf_marking.
                for first buf_marking-childs exclusive-lock where
                          buf_marking-childs.mark = buf_marking.mark-parent:
                  buf_marking-childs.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB .
                  validate buf_marking-childs.
                end.
                for each buf_marking-chk exclusive-lock where buf_marking-chk.mark begins buf_marking.mark :
                  for first buf_chk-doc no-lock where buf_chk-doc.doc-code = buf_marking-chk.doc-code
                                                  and buf_chk-doc.out-code = buf_parts.out-code
                                                  :
                    if buf_marking-chk.sts <> 2 then
                    do:
                       assign buf_marking-chk.sts = 1 .
                       validate buf_marking-chk.
                    end.
                  end .
                end .
                if buf_marking.unit-ext <> "UNIT" or
                   (buf_marking.unit-ext = ? and buf_marking.box-qnty > 1)
                then do :
                  run addChildMarkingLines in this-procedure (
                    buf_marking.mark,
                    buf_marking.sts,
                    buffer buf_marking-lines,
                    buffer buf_parts,
                    buffer orig_marking-lines,
                    buffer buf_orig_parts,
                    buffer buf_goods
                  ).
                end .
              end.
              if available orig_marking-lines then
                delete orig_marking-lines .
          end.
        end.
      end .
      if p-out-code = 'out-zone':U
      and trim(p-mark) = ""
      then do :
        for each orig_marking-lines no-lock where orig_marking-lines.gds-code   = buf_goods.gds-code
                                              and orig_marking-lines.obj-type   = buf_orig_parts.obj-type
                                              and orig_marking-lines.obj-code   = buf_orig_parts.obj-code
                                              and orig_marking-lines.in-code    = buf_orig_parts.in-code
                                              and orig_marking-lines.out-code   = buf_orig_parts.out-code
                                              and orig_marking-lines.part-code  = buf_orig_parts.part-code
                                              and orig_marking-lines.prt-code   = buf_orig_parts.prt-code
                                              :
          find first buf_marking-lines no-lock where  buf_marking-lines.mark       = orig_marking-lines.mark
                                                  and buf_marking-lines.gds-code   = buf_goods.gds-code
                                                  and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                  and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                  and buf_marking-lines.out-code   = p-out-code
                                                  no-error .
          if available buf_marking-lines
          then do :
            find current buf_marking-lines exclusive-lock .
            delete buf_marking-lines .
            for first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
              if buf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB
              then do :
                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
                validate buf_marking.
              end.
            end .
          end .
          else do :
            if avail buf_trn-doc and buf_trn-doc.doc-type <> 'инв':U and buf_parts.out-code <> 'out-zone':U then do:
            create buf_marking-lines .
            assign
              buf_marking-lines.mark       = orig_marking-lines.mark
              buf_marking-lines.doc-level  = orig_marking-lines.doc-level
              buf_marking-lines.gds-code   = buf_goods.gds-code
              buf_marking-lines.obj-type   = buf_parts.obj-type
              buf_marking-lines.obj-code   = buf_parts.obj-code
              buf_marking-lines.in-code    = buf_parts.in-code
              buf_marking-lines.out-code   = buf_parts.out-code
              buf_marking-lines.part-code  = buf_parts.part-code
              buf_marking-lines.prt-code   = buf_parts.prt-code
            .
            validate buf_marking-lines.
            if buf_parts.out-code <> buf_parts.in-code
            and buf_parts.out-code <> 'free-zone':U
            and buf_parts.out-code <> 'out-zone':U
            then do :
              find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_parts.out-code no-error .
              if available buf_trn-doc then buf_marking-lines.fact-order = buf_trn-doc.fact-order .
            end .
            end.
          end .
          release buf_marking-lines no-error .
        end.
      end .
      if p-mark <> "" and available (buf_trn-doc) and buf_trn-doc.ext-doc-type = 'vt':U
      then do:
        for each orig_marking-lines no-lock where orig_marking-lines.mark         = p-mark
                                                and orig_marking-lines.gds-code   = buf_goods.gds-code
                                                and orig_marking-lines.obj-type   = buf_orig_parts.obj-type
                                                and orig_marking-lines.obj-code   = buf_orig_parts.obj-code
                                                and orig_marking-lines.in-code    = buf_orig_parts.in-code
                                                and orig_marking-lines.out-code   = buf_orig_parts.out-code
                                                and orig_marking-lines.part-code  = buf_orig_parts.part-code
                                                and orig_marking-lines.prt-code   = buf_orig_parts.prt-code
                                                .
          find first buf_marking-lines no-lock where buf_marking-lines.mark       = p-mark
                                                 and buf_marking-lines.gds-code   = buf_goods.gds-code
                                                 and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                 and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                 and buf_marking-lines.in-code    = buf_parts.in-code
                                                 and buf_marking-lines.out-code   = buf_orig_parts.out-code
                                                 and buf_marking-lines.part-code  = buf_parts.part-code
                                                 no-error .
          for each ub.marking where ub.marking.mark = buf_marking-lines.mark:
            if p-out-code = 'free-zone':U and not ub.marking.sts = oMarkSts:MarkError:KeyIntDB
              then assign ub.marking.sts = oMarkSts:FreeZone:KeyIntDB.
            if p-out-code = 'out-zone':U and not ub.marking.sts = oMarkSts:MarkError:KeyIntDB
              then assign ub.marking.sts = oMarkSts:OutZone:KeyIntDB.
            validate ub.marking.
          end.
          run partcopy-to-childs-mark (buffer buf_marking-lines, buffer orig_marking-lines, input buf_parts.out-code, oMarkSts).
          if available (buf_marking-lines)
          then do:
            assign
              buf_marking-lines.mark       = p-mark
              buf_marking-lines.doc-level  = orig_marking-lines.doc-level
              buf_marking-lines.gds-code   = buf_goods.gds-code
              buf_marking-lines.obj-type   = buf_parts.obj-type
              buf_marking-lines.obj-code   = buf_parts.obj-code
              buf_marking-lines.in-code    = buf_parts.in-code
              buf_marking-lines.out-code   = buf_parts.out-code
              buf_marking-lines.part-code  = buf_parts.part-code
            .
            validate buf_marking-lines.
          end.
        end.
      end.
    end.
    else do:
      find first buf_parts exclusive-lock
        where recid(buf_parts) = recid(buf_orig_parts)
        .
    end.
    if p-out-code = 'free-zone':U
    or p-out-code = 'out-zone':U
    then do:
      if buf_parts.rsrv-free <>
       (if buf_parts.out-code = 'free-zone':U then yes else no)
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info21 skip
          "Ошибка типа резерва партии" skip
          "Объект" buf_parts.obj-type buf_parts.obj-code  skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Партия" buf_parts.in-code buf_parts.part-code skip
          "Резерв" buf_parts.out-code skip
          "Статус" buf_parts.status_ skip
          "Тип резерва" buf_parts.rsrv-free skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
end procedure.
procedure partcopy-to-childs-mark :
  define parameter buffer buf_ml for ub.marking-lines .
  define parameter buffer buf_orig-ml for ub.marking-lines .
  define input parameter p-out-code as character no-undo .
  define input parameter THMarkSts as class ibs.th.str.marking.sts.mark no-undo .
  define buffer buf_ml-childs for ub.marking-lines .
  for each ub.marking where ub.marking.mark-parent = buf_ml.mark:
    if p-out-code = 'free-zone':U and not ub.marking.sts = THMarkSts:MarkError:KeyIntDB
      then assign ub.marking.sts = THMarkSts:FreeZone:KeyIntDB.
    if p-out-code = 'out-zone':U and not ub.marking.sts = THMarkSts:MarkError:KeyIntDB
      then assign ub.marking.sts = THMarkSts:OutZone:KeyIntDB.
    for each buf_ml-childs exclusive-lock where buf_ml-childs.mark = ub.marking.mark
      and buf_ml-childs.obj-type  = buf_orig-ml.obj-type
      and buf_ml-childs.obj-code  = buf_orig-ml.obj-code
      and buf_ml-childs.in-code   = buf_orig-ml.in-code
      and buf_ml-childs.out-code  = buf_orig-ml.out-code
      and buf_ml-childs.part-code = buf_orig-ml.part-code
      and buf_ml-childs.prt-code  = buf_orig-ml.prt-code
      :
      assign
        buf_ml-childs.out-code  = p-out-code
      .
      run partcopy-to-childs-mark (buffer buf_ml-childs, buffer buf_orig-ml, input p-out-code, input THMarkSts).
    end.
  end.
end.
procedure partcopy-update-parts :
  define input  parameter p-doc-code  like ub.doc-line.doc-code  no-undo .
  define input  parameter p-obj-type  like ub.doc-line.obj-type  no-undo .
  define input  parameter p-obj-code  like ub.doc-line.obj-code  no-undo .
  define input  parameter p-artic     like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code like ub.doc-line.prod-code no-undo .
  define variable vss-description as character no-undo init "partcopy-update-parts-01: процедура обработки партий при закрытии документа".
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer archive_parts for ub.parts .
  define buffer buf_parts   for ub.parts .
  define buffer orig_marking-lines for ub.marking-lines .
  define buffer buf_marking for ub.marking .
  define buffer buf_goods for ub.goods .
  define variable v-rsrv-code     as character no-undo .
  define variable v-goods-twounit as logical   no-undo .
  define variable v-value-character as character no-undo .
  define variable v-value-date      as date no-undo .
  define variable v-value-decimal   as decimal no-undo .
  define variable v-value-integer   as integer no-undo .
  define variable v-izlcstpr        as logical no-undo .
  define variable v-tth             as handle no-undo .
  define variable v-type            as character no-undo .
  define variable v-exch-rate  like ub.curr-accnt.exch-rate no-undo .
  define variable v-exch-scale like ub.curr-accnt.exch-scale no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info21 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_goods no-lock where buf_goods.artic = p-artic
                                   and buf_goods.prod-type = p-prod-type
                                   and buf_goods.prod-code = p-prod-code
                                   no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info21 skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_trn-doc.ext-doc-type = 'vt':U
    then do :
        delete object v-tth no-error.
        run adm/shattri.p (
           input "get":U
          ,input buf_trn-doc.obj-type
          ,input buf_trn-doc.obj-code
          ,input 'inv-obj':U
          ,input  "izlcstpr"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-izlcstpr
          ,output v-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
          delete object v-tth no-error.
        if error-status:error then do:
          v-izlcstpr = false .
        end.
    end.
    else do :
        v-izlcstpr = false .
    end.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info21 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    define query partcopy-select-parts for archive_parts .
    open query partcopy-select-parts preselect each archive_parts
      where archive_parts.obj-type  = p-obj-type
        and archive_parts.obj-code  = p-obj-code
        and archive_parts.artic     = p-artic
        and archive_parts.prod-type = p-prod-type
        and archive_parts.prod-code = p-prod-code
        and archive_parts.out-code  = p-doc-code
      .
    get first partcopy-select-parts .
    if buf_trn-doc.doc-type = 'при':U
    then do:
      do while available archive_parts
      on error undo, return error return-value
      :
        if can-do('рас,спи':U, buf_trn-doc.doc-type)
        or (buf_trn-doc.doc-type = 'инв':U
            and archive_parts.fact-qnty < 0)
        then do:
          assign
            v-rsrv-code = 'out-zone':U
          .
        end.
        else do:
          assign
            v-rsrv-code = 'free-zone':U
          .
        end.
        assign
          archive_parts.status_   = yes
          archive_parts.rsrv-free = ?
        .
        if archive_parts.in-code = p-doc-code
        then do:
          assign
            archive_parts.fact-num  = buf_trn-doc.fact-num
            archive_parts.fact-date = buf_trn-doc.fact-date
            archive_parts.doc-type  = buf_trn-doc.doc-type
          .
        end.
        if archive_parts.fact-qnty <> 0
        then do:
          run partcopy in this-procedure
            (input  true
            ,input  v-rsrv-code
            ,buffer archive_parts
            ,buffer buf_parts
            ,input  ""
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info21 skip
              "Ошибка при создании партии" skip
              "Документ" p-doc-code skip
              "Объект" p-obj-type p-obj-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              "Партия" archive_parts.in-code archive_parts.part-code skip
              "Резерв" v-rsrv-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
          assign
            buf_parts.qnty      = buf_parts.qnty     + archive_parts.fact-qnty
            buf_parts.fact-qnty = buf_parts.qnty
          .
          if v-goods-twounit = true
          then do:
            assign
              buf_parts.cli-qnty = buf_parts.cli-qnty + archive_parts.cli-qnty
            .
            case buf_trn-doc.ext-doc-type :
              when 'ie':U
              then do:
                if archive_parts.cli-qnty <> truncate(archive_parts.cli-qnty, 0 )
                then do:
                  message
                    vss-workfile vss-revision vss-description skip
                    vss-include-info21 skip
                    "Клиентское количество для товара," skip
                    "который учитывается по двум единицам измерения" skip
                    "должно равняться единице" skip
                    "Документ" p-doc-code skip
                    "Объект" p-obj-type p-obj-code skip
                    "Артикул" p-artic p-prod-type p-prod-code skip
                    "Партия" archive_parts.in-code archive_parts.part-code skip
                    "Количество по документу" archive_parts.qnty skip
                    "Фактическое количество" archive_parts.fact-qnty skip
                    "Клиентское количество" archive_parts.cli-qnty skip
                    view-as alert-box error .
                  undo, return error .
                end.
              end.
              when 'iv':U
              then do:
                if archive_parts.cli-qnty <> 1
                then do:
                  message
                    vss-workfile vss-revision vss-description skip
                    vss-include-info21 skip
                    "Клиентское количество для товара," skip
                    "который учитывается по двум единицам измерения" skip
                    "должно равняться единице" skip
                    "Документ" p-doc-code skip
                    "Объект" p-obj-type p-obj-code skip
                    "Артикул" p-artic p-prod-type p-prod-code skip
                    "Партия" archive_parts.in-code archive_parts.part-code skip
                    "Количество по документу" archive_parts.qnty skip
                    "Фактическое количество" archive_parts.fact-qnty skip
                    "Клиентское количество" archive_parts.cli-qnty skip
                    view-as alert-box error .
                  undo, return error .
                end.
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info21 skip
                  "Товар учитывается по двум единицам измерения" skip
                  "Для приходов разрешен только внешний приход или приход перемещение" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type archive_parts.prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
          end.
          else do:
            if buf_parts.cli-base-rate <> 0
            then do:
              assign
                buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
              .
            end.
            else do:
              assign
                buf_parts.cli-qnty = 0
              .
            end.
          end.
          if  buf_parts.qnty      = 0
          and buf_parts.fact-qnty = 0
          then do:
            if v-goods-twounit = true
            then do:
              if buf_parts.cli-qnty <> 0
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info21 skip
                  "Ошибка при удалении партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" buf_parts.in-code buf_parts.part-code skip
                  "Резерв" buf_parts.out-code skip
                  "qnty" buf_parts.qnty skip
                  "fact-qnty" buf_parts.fact-qnty skip
                  "cli-qnty" buf_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            delete buf_parts .
          end.
        end.
        else do :
          if buf_trn-doc.ext-doc-type = 'iv':U
          then
          for each orig_marking-lines no-lock where orig_marking-lines.gds-code   = buf_goods.gds-code
                                                and orig_marking-lines.obj-type   = archive_parts.obj-type
                                                and orig_marking-lines.obj-code   = archive_parts.obj-code
                                                and orig_marking-lines.in-code    = archive_parts.in-code
                                                and orig_marking-lines.out-code   = archive_parts.out-code
                                                and orig_marking-lines.part-code  = archive_parts.part-code,
          first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
            assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB .
          end .
        end .
        get next partcopy-select-parts .
      end.
    end.
    if buf_trn-doc.doc-type = 'рас':U
    or buf_trn-doc.doc-type = 'спи':U
    or buf_trn-doc.doc-type = 'возврат':U
    or buf_trn-doc.doc-type = 'инв':U
    then do:
      do while available archive_parts
      on error undo, return error return-value
      :
        assign
          archive_parts.status_   = yes
          archive_parts.rsrv-free = ?
        .
        if archive_parts.fact-qnty <> archive_parts.qnty
        then do:
          define variable v-is-hold as logical   no-undo .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info21
              "Ошибка при определении типа документа hold-doc.i" skip
              "Документ" p-doc-code skip
              "Объект" p-obj-type p-obj-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
          if buf_trn-doc.ext-doc-type = 'vt':U
          or (buf_trn-doc.ext-doc-type = 're':U and v-is-hold = true)
          or buf_trn-doc.ext-doc-type = 'ap':U
          or buf_trn-doc.ext-doc-type = 'pc':U
          or buf_trn-doc.ext-doc-type = 'mp':U
          or  buf_trn-doc.ext-doc-type = 'vp':U
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info21 skip
              "Фактическое количество не может отличаться от количества по документу" skip
              "для документов инвентаризации, внутреннего возврата и автоматического возврата между фирмами" skip
              "Документ" p-doc-code skip
              "Объект" p-obj-type p-obj-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              "Партия" archive_parts.in-code archive_parts.part-code skip
              "Количество по документу" archive_parts.qnty skip
              "Фактическое количество" archive_parts.fact-qnty skip
              "Клиентское количество" archive_parts.cli-qnty skip
              view-as alert-box error .
            undo, return error .
          end.
          if archive_parts.in-code <> archive_parts.out-code
          then do:
            if can-do('рас,спи':U,buf_trn-doc.doc-type)
            or (buf_trn-doc.doc-type = 'инв':U
                and archive_parts.fact-qnty < 0)
            then do:
              assign
                v-rsrv-code = 'free-zone':U
              .
            end.
            else do:
              assign
                v-rsrv-code = 'out-zone':U
              .
            end.
            run partcopy in this-procedure
              (input  true
              ,input  v-rsrv-code
              ,buffer archive_parts
              ,buffer buf_parts
              ,input  ""
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info21 skip
                "Ошибка при создании партии" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Резерв" v-rsrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              buf_parts.qnty      = buf_parts.qnty + (archive_parts.qnty - archive_parts.fact-qnty)
              buf_parts.fact-qnty = buf_parts.qnty
            .
            if v-goods-twounit = true
            then do:
              if archive_parts.cli-qnty <> 1
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info21 skip
                  "Клиентское количество для товара," skip
                  "который учитывается по двум единицам измерения" skip
                  "должно равняться единице" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
              if archive_parts.fact-qnty = 0
              then do:
                assign
                  buf_parts.cli-qnty = buf_parts.cli-qnty + archive_parts.cli-qnty
                .
              end.
              else do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info21 skip
                  "Фактическое количество для товара," skip
                  "который учитывается по двум единицам измерения" skip
                  "должно равняться нулю или количеству по документу" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            else do:
              if buf_parts.cli-base-rate <> 0
              then do:
                assign
                  buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
                .
              end.
              else do:
                assign
                  buf_parts.cli-qnty = 0
                .
              end.
            end.
          end.
          if  available buf_parts
          and buf_parts.qnty      = 0
          and buf_parts.fact-qnty = 0
          then do:
            if v-goods-twounit = true
            then do:
              if buf_parts.cli-qnty <> 0
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info21 skip
                  "Ошибка при удалении партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" buf_parts.in-code buf_parts.part-code skip
                  "Резерв" buf_parts.out-code skip
                  "qnty" buf_parts.qnty skip
                  "fact-qnty" buf_parts.fact-qnty skip
                  "cli-qnty" buf_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            delete buf_parts .
          end.
        end.
        if archive_parts.in-code = buf_trn-doc.doc-code
        then do:
          assign
            archive_parts.fact-num  = buf_trn-doc.fact-num
            archive_parts.fact-date = buf_trn-doc.fact-date
            archive_parts.doc-type  = buf_trn-doc.doc-type
          .
        end.
        if archive_parts.fact-qnty <> 0
        then do:
          if can-do('рас,спи':U, buf_trn-doc.doc-type)
          or (buf_trn-doc.doc-type = 'инв':U
              and archive_parts.fact-qnty < 0
            )
          then do:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info21
                "Ошибка при определении типа документа hold-doc.i" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              v-rsrv-code = 'out-zone':U
            .
            if buf_trn-doc.ext-doc-type  = 'ep':U
            or (buf_trn-doc.ext-doc-type = 'ap':U )
            or (buf_trn-doc.ext-doc-type = 'pc':U )
            then do:
              assign
                v-rsrv-code = ""
              .
              for each orig_marking-lines no-lock where orig_marking-lines.gds-code   = buf_goods.gds-code
                                                    and orig_marking-lines.obj-type   = archive_parts.obj-type
                                                    and orig_marking-lines.obj-code   = archive_parts.obj-code
                                                    and orig_marking-lines.in-code    = archive_parts.in-code
                                                    and orig_marking-lines.out-code   = archive_parts.out-code
                                                    and orig_marking-lines.part-code  = archive_parts.part-code,
              first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB .
              end .
            end.
          end.
          else do:
            assign
              v-rsrv-code = 'free-zone':U
            .
          end.
          if v-rsrv-code <> ""
          then do:
            run partcopy in this-procedure
              (input  true
              ,input  v-rsrv-code
              ,buffer archive_parts
              ,buffer buf_parts
              ,input  ""
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info21 skip
                "Ошибка при создании партии" skip
                "Документ" buf_trn-doc.doc-code skip
                "Объект" archive_parts.obj-type archive_parts.obj-code skip
                "Артикул" archive_parts.artic archive_parts.prod-type archive_parts.prod-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Резерв" v-rsrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              buf_parts.qnty      = buf_parts.qnty + abs(archive_parts.fact-qnty)
              buf_parts.fact-qnty = buf_parts.qnty
            .
            if v-goods-twounit = true
            then do:
              define variable v-qnty-sign as integer   no-undo .
              assign
                v-qnty-sign = 1
              .
              if  buf_trn-doc.doc-type = 'инв':U
              and archive_parts.fact-qnty < 0
              then do:
                assign
                  v-qnty-sign = - 1
                .
              end.
              if archive_parts.cli-qnty <> v-qnty-sign
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info21 skip
                  "Клиентское количество для товара," skip
                  "который учитывается по двум единицам измерения" skip
                  "должно равняться" v-qnty-sign skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
              if archive_parts.fact-qnty = archive_parts.qnty
              then do:
                assign
                  buf_parts.cli-qnty = buf_parts.cli-qnty + abs(archive_parts.cli-qnty)
                .
              end.
              else do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info21 skip
                  "Фактическое количество для товара," skip
                  "который учитывается по двум единицам измерения" skip
                  "должно равняться нулю или количеству по документу" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            else do:
              if buf_parts.cli-base-rate <> 0
              then do:
                assign
                  buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
                .
              end.
              else do:
                assign
                  buf_parts.cli-qnty = 0
                .
              end.
            end.
            if  buf_parts.qnty      = 0
            and buf_parts.fact-qnty = 0
            then do:
              if v-goods-twounit = true
              then do:
                if buf_parts.cli-qnty <> 0
                then do:
                  message
                    vss-workfile vss-revision vss-description skip
                    vss-include-info21 skip
                    "Ошибка при удалении партии" skip
                    "Документ" p-doc-code skip
                    "Объект" p-obj-type p-obj-code skip
                    "Артикул" p-artic p-prod-type p-prod-code skip
                    "Партия" buf_parts.in-code buf_parts.part-code skip
                    "Резерв" buf_parts.out-code skip
                    "qnty" buf_parts.qnty skip
                    "fact-qnty" buf_parts.fact-qnty skip
                    "cli-qnty" buf_parts.cli-qnty skip
                    view-as alert-box error .
                  undo, return error .
                end.
              end.
              delete buf_parts .
            end.
          end.
        end.
        if  ( archive_parts.in-code = buf_trn-doc.doc-code
        and archive_parts.supp-type =
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-type else buf_trn-doc.obj-type )
        and archive_parts.supp-code =
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-code else buf_trn-doc.obj-code )
        )
        or buf_trn-doc.ext-doc-type = 'rv':U
        then do:
          if can-do('рас,спи':U,buf_trn-doc.doc-type)
          or (buf_trn-doc.doc-type = 'инв':U
              and archive_parts.fact-qnty < 0
            )
          then do:
            assign
              v-rsrv-code = 'free-zone':U
            .
          end.
          else do:
            assign
              v-rsrv-code = 'out-zone':U
            .
          end.
          if not v-izlcstpr
          then do :
              run partcopy in this-procedure
                (input  true
                ,input  v-rsrv-code
                ,buffer archive_parts
                ,buffer buf_parts
                ,input  ""
                ) no-error .
              if error-status :error
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info21 skip
                  "Ошибка при создании партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Резерв" v-rsrv-code skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error .
              end.
              assign
                buf_parts.qnty      = buf_parts.qnty - abs(archive_parts.fact-qnty)
                buf_parts.fact-qnty = buf_parts.qnty
              .
              if buf_trn-doc.ext-doc-type = 'rv':U
              then
              for each orig_marking-lines no-lock where orig_marking-lines.gds-code   = buf_goods.gds-code
                                                    and orig_marking-lines.obj-type   = archive_parts.obj-type
                                                    and orig_marking-lines.obj-code   = archive_parts.obj-code
                                                    and orig_marking-lines.in-code    = archive_parts.in-code
                                                    and orig_marking-lines.out-code   = archive_parts.out-code
                                                    and orig_marking-lines.part-code  = archive_parts.part-code
                                                    and orig_marking-lines.prt-code   = archive_parts.prt-code,
              first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
                if buf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB
                then
                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
              end .
              if v-goods-twounit = true
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info21 skip
                  "Запрещено порождение партий," skip
                  "который учитывается по двум единицам измерения" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
              else do:
                if buf_parts.cli-base-rate <> 0
                then do:
                  assign
                    buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
                  .
                end.
                else do:
                  assign
                    buf_parts.cli-qnty = 0
                  .
                end.
              end.
          end.
        end.
        get next partcopy-select-parts .
      end.
    end.
  end.
end procedure.
procedure partcopy-update-parts-delete :
  define input  parameter p-doc-code  like ub.doc-line.doc-code  no-undo .
  define input  parameter p-obj-type  like ub.doc-line.obj-type  no-undo .
  define input  parameter p-obj-code  like ub.doc-line.obj-code  no-undo .
  define input  parameter p-artic     like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code like ub.doc-line.prod-code no-undo .
  define variable objMarks as class excisemarks no-undo.
  define variable vss-description as character no-undo init "partcopy-update-parts-delete-01: процедура обработки партий при удалении документа".
  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer archive_parts  for ub.parts .
  define buffer buf_parts      for ub.parts .
  define buffer buf_parts-attr for ub.parts-attr .
  define variable v-rsrv-code as character no-undo .
  define variable v-unrv-code as character no-undo .
  define variable v-need-rsrv as logical   no-undo .
  define variable v-need-unrv as logical   no-undo .
  define variable v-rsrv-sign as integer   no-undo .
  define variable v-unrv-sign as integer   no-undo .
  define variable v-goods-twounit as logical   no-undo .
  define variable v-value-character as character no-undo .
  define variable v-value-date      as date no-undo .
  define variable v-value-decimal   as decimal no-undo .
  define variable v-value-integer   as integer no-undo .
  define variable v-izlcstpr        as logical no-undo .
  define variable v-tth             as handle no-undo .
  define variable v-type            as character no-undo .
  define buffer buf_marking-lines for ub.marking-lines .
  define buffer del_marking-lines for ub.marking-lines .
  define buffer free_marking-lines for ub.marking-lines .
  define buffer buf_marking for ub.marking .
  define buffer buf_marking-chk for ub.marking-chk .
  define buffer buf_chk-doc for ub.chk-doc .
  define variable part-key-rec as character no-undo .
  define variable part-key-rec_arhive   as character no-undo .
  define buffer buf1_gen-attr for ub.gen-attr .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info21 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_trn-doc.ext-doc-type = 'vt':U
    then do :
        delete object v-tth no-error.
        run adm/shattri.p (
           input "get":U
          ,input buf_trn-doc.obj-type
          ,input buf_trn-doc.obj-code
          ,input 'inv-obj':U
          ,input  "izlcstpr"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-izlcstpr
          ,output v-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
          delete object v-tth no-error.
        if error-status:error then do:
          v-izlcstpr = false .
        end.
    end.
    else do :
        v-izlcstpr = false .
    end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info21 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    define variable v-gds-code as integer   no-undo .
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  ) no-error .
    for each archive_parts
      where archive_parts.obj-type  = p-obj-type
        and archive_parts.obj-code  = p-obj-code
        and archive_parts.artic     = p-artic
        and archive_parts.prod-type = p-prod-type
        and archive_parts.prod-code = p-prod-code
        and archive_parts.out-code  = p-doc-code
    on error undo, return error return-value
    :
      if archive_parts.fact-qnty <> 0
      then do:
        define variable v-create-part as logical   no-undo .
        define variable v-old-return  as logical   no-undo .
        assign
          v-create-part = false
          v-old-return  = false
        .
        if archive_parts.in-code = buf_trn-doc.doc-code
        then do:
          assign
            v-create-part = true
          .
          if archive_parts.supp-type <>
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-type else buf_trn-doc.obj-type )
          or archive_parts.supp-code <>
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-code else buf_trn-doc.obj-code )
          then do:
            assign
              v-old-return = true
            .
          end.
        end.
        define variable v-is-hold as logical   no-undo .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info21
            "Ошибка при определении типа документа hold-doc.i" skip
            "Документ" p-doc-code skip
            "Объект" p-obj-type p-obj-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partcond in g#library
  (input  buf_trn-doc.ext-doc-type
  ,input  v-is-hold
  ,input  archive_parts.fact-qnty
  ,input  v-create-part
  ,input  v-old-return
  ,output v-rsrv-code
  ,output v-unrv-code
  ,output v-need-rsrv
  ,output v-need-unrv
  ,output v-rsrv-sign
  ,output v-unrv-sign
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info21
            "Ошибка при определении параметров резервирования партии" skip
            "Документ" p-doc-code skip
            "Объект" p-obj-type p-obj-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        if v-izlcstpr and archive_parts.fact-qnty > 0 then v-need-unrv = false .
        if v-need-rsrv = true
        then do:
          release buf_parts no-error .
          if archive_parts.out-code <> v-rsrv-code and v-rsrv-sign = -1 and v-izlcstpr
          then do:
              find first buf_parts exclusive-lock
                where buf_parts.obj-type  = archive_parts.obj-type
                  and buf_parts.obj-code  = archive_parts.obj-code
                  and buf_parts.artic     = archive_parts.artic
                  and buf_parts.prod-type = archive_parts.prod-type
                  and buf_parts.prod-code = archive_parts.prod-code
                  and buf_parts.in-code   = archive_parts.out-code
                  and buf_parts.out-code  = v-rsrv-code
                  and buf_parts.part-code = archive_parts.part-code
                no-error.
          end .
          if not available  buf_parts
          then do :
              run partcopy in this-procedure
                (input  true
                ,input  v-rsrv-code
                ,buffer archive_parts
                ,buffer buf_parts
                ,input  ""
                ) no-error .
              if error-status :error
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info21 skip
                  "Ошибка при создании партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Необходимо резервировать" v-need-rsrv skip
                  "Резерв" v-rsrv-code skip
                  "Необходимо снятие резервов" v-need-unrv skip
                  "Снятие резервов" v-unrv-code skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error .
              end.
          end.
          if new(buf_parts)
          then do:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info21 skip
                "Ошибка при определении кода товара" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            find first buf_parts-attr no-lock
              where buf_parts-attr.in-code   = buf_parts.in-code
                and buf_parts-attr.gds-code  = v-gds-code
                and buf_parts-attr.part-code = buf_parts.part-code
              no-error .
            if not available buf_parts-attr
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info21 skip
                "Не найден атрибут партии" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            define variable v-fact-num as integer   no-undo .
            define variable v-doc-type as character no-undo .
            run factord-to-fact-num in this-procedure
              (input  buf_parts-attr.fact-order
              ,output v-fact-num
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info21 skip
                "Ошибка при определении порядкового номера партии" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run trnextdt in g#library
  (input  buf_parts-attr.ext-doc-type
  ,output v-doc-type
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info21 skip
                "Ошибка при определении типа документа" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              buf_parts.fact-date = buf_parts-attr.fact-date
              buf_parts.fact-num  = v-fact-num
              buf_parts.doc-type  = v-doc-type
            .
          end.
          assign
            buf_parts.qnty      = buf_parts.qnty  + v-rsrv-sign * archive_parts.fact-qnty
            buf_parts.fact-qnty = buf_parts.qnty
          .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_parts.artic
  ,input  buf_parts.prod-type
  ,input  buf_parts.prod-code
  ,output v-gds-code
  ) no-error .
          if buf_parts.out-code = 'free-zone':U
          then
          for each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = v-gds-code
                                                      and buf_marking-lines.obj-type = archive_parts.obj-type
                                                      and buf_marking-lines.obj-code = archive_parts.obj-code
                                                      and buf_marking-lines.in-code  = archive_parts.in-code
                                                      and buf_marking-lines.out-code = archive_parts.out-code
                                                      and buf_marking-lines.part-code = archive_parts.part-code
                                                      and buf_marking-lines.prt-code = archive_parts.prt-code:
            for first buf_marking exclusive-lock where buf_marking.mark = buf_marking-lines.mark :
              find first free_marking-lines exclusive-lock where free_marking-lines.mark       = buf_marking-lines.mark
                                                            and free_marking-lines.gds-code   = buf_marking-lines.gds-code
                                                            and free_marking-lines.obj-type   = buf_parts.obj-type
                                                            and free_marking-lines.obj-code   = buf_parts.obj-code
                                                            and free_marking-lines.in-code    = buf_parts.in-code
                                                            and free_marking-lines.out-code   = buf_parts.out-code
                                                            and free_marking-lines.part-code  = buf_parts.part-code
                                                            and free_marking-lines.prt-code   = buf_parts.prt-code
                                                            no-error .
              if available free_marking-lines
              then do :
                delete free_marking-lines .
              end .
              if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB and
                 not can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(buf_marking.sts))
              then do:
                buf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB .
              end.
            end .
          end.
          if v-goods-twounit = true
          then do:
            assign
              buf_parts.cli-qnty = buf_parts.cli-qnty + v-rsrv-sign * archive_parts.cli-qnty
            .
          end.
          else do:
            if buf_parts.cli-base-rate <> 0
            then do:
              assign
                buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
              .
            end.
            else do:
              assign
                buf_parts.cli-qnty = 0
              .
            end.
          end.
          if  buf_parts.qnty      = 0
          and buf_parts.fact-qnty = 0
          then do:
            if v-goods-twounit = true
            then do:
              if buf_parts.cli-qnty <> 0
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info21 skip
                  "Ошибка при удалении партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" buf_parts.in-code buf_parts.part-code skip
                  "Резерв" buf_parts.out-code skip
                  "qnty" buf_parts.qnty skip
                  "fact-qnty" buf_parts.fact-qnty skip
                  "cli-qnty" buf_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer buf_parts:handle)
                                        ,output part-key-rec).
            run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer archive_parts:handle)
                                        ,output part-key-rec_arhive).
            for each ub.gen-attr no-lock where ub.gen-attr.table-name = 'excise-mark':U
                                                  and ub.gen-attr.p-key =  part-key-rec
            :
              if not valid-object (objMarks)
                then objMarks = new excisemarks (buf_parts.obj-type, buf_parts.obj-code).
              objMarks:DelMarkForParts(buffer buf_parts, buffer archive_parts, ub.gen-attr.attr-code) .
              if objMarks:StatusErr
                  then
              do:
                  message objMarks:ReturnMsg view-as alert-box error.
                  delete object objMarks no-error.
                  undo, return error.
              end.
            end.
            for each del_marking-lines exclusive-lock where del_marking-lines.gds-code = v-gds-code
                                                        and del_marking-lines.obj-type = buf_parts.obj-type
                                                        and del_marking-lines.obj-code = buf_parts.obj-code
                                                        and del_marking-lines.in-code = buf_parts.in-code
                                                        and del_marking-lines.out-code = buf_parts.out-code
                                                        and del_marking-lines.part-code = buf_parts.part-code
                                                        and del_marking-lines.prt-code = buf_parts.prt-code:
              delete del_marking-lines .
            end.
            delete buf_parts .
          end.
        end.
        delete object objMarks no-error.
        if v-need-unrv = true
        then do:
          release buf_parts no-error .
          if archive_parts.out-code <> v-unrv-code and v-unrv-sign = -1 and v-izlcstpr
          then do:
              find first buf_parts exclusive-lock
                where buf_parts.obj-type  = archive_parts.obj-type
                  and buf_parts.obj-code  = archive_parts.obj-code
                  and buf_parts.artic     = archive_parts.artic
                  and buf_parts.prod-type = archive_parts.prod-type
                  and buf_parts.prod-code = archive_parts.prod-code
                  and buf_parts.in-code   = archive_parts.out-code
                  and buf_parts.out-code  = v-unrv-code
                  and buf_parts.part-code = archive_parts.part-code
                no-error.
          end .
          if not available  buf_parts
          then do :
              run partcopy in this-procedure
                (input  true
                ,input  v-unrv-code
                ,buffer archive_parts
                ,buffer buf_parts
                ,input  ""
                ) no-error .
              if error-status :error
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info21 skip
                  "Ошибка при создании партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Необходимо резервировать" v-need-rsrv skip
                  "Резерв" v-rsrv-code skip
                  "Необходимо снятие резервов" v-need-unrv skip
                  "Снятие резервов" v-unrv-code skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error .
              end.
          end.
          if new(buf_parts)
          then do:
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info21 skip
                "Ошибка при определении кода товара" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            find first buf_parts-attr no-lock
              where buf_parts-attr.in-code   = buf_parts.in-code
                and buf_parts-attr.gds-code  = v-gds-code
                and buf_parts-attr.part-code = buf_parts.part-code
              no-error .
            if not available buf_parts-attr
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info21 skip
                "Не найден атрибут партии" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            run factord-to-fact-num in this-procedure
              (input  buf_parts-attr.fact-order
              ,output v-fact-num
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info21 skip
                "Ошибка при определении порядкового номера партии" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run trnextdt in g#library
  (input  buf_parts-attr.ext-doc-type
  ,output v-doc-type
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info21 skip
                "Ошибка при определении типа документа" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              buf_parts.fact-date = buf_parts-attr.fact-date
              buf_parts.fact-num  = v-fact-num
              buf_parts.doc-type  = v-doc-type
            .
          end.
          assign
            buf_parts.qnty      = buf_parts.qnty  + v-unrv-sign * archive_parts.fact-qnty
            buf_parts.fact-qnty = buf_parts.qnty
          .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_parts.artic
  ,input  buf_parts.prod-type
  ,input  buf_parts.prod-code
  ,output v-gds-code
  ) no-error .
          if buf_parts.out-code = 'free-zone':U
          then
          for each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = v-gds-code
                                                      and buf_marking-lines.obj-type = archive_parts.obj-type
                                                      and buf_marking-lines.obj-code = archive_parts.obj-code
                                                      and buf_marking-lines.in-code  = archive_parts.in-code
                                                      and buf_marking-lines.out-code = archive_parts.out-code
                                                      and buf_marking-lines.part-code = archive_parts.part-code
                                                      and buf_marking-lines.prt-code = archive_parts.prt-code:
            for first buf_marking exclusive-lock where buf_marking.mark = buf_marking-lines.mark :
              find first free_marking-lines no-lock where free_marking-lines.mark       = buf_marking-lines.mark
                                                      and free_marking-lines.gds-code   = buf_marking-lines.gds-code
                                                      and free_marking-lines.obj-type   = buf_parts.obj-type
                                                      and free_marking-lines.obj-code   = buf_parts.obj-code
                                                      and free_marking-lines.in-code    = buf_parts.in-code
                                                      and free_marking-lines.out-code   = buf_parts.out-code
                                                      and free_marking-lines.part-code  = buf_parts.part-code
                                                      and free_marking-lines.prt-code   = buf_parts.prt-code
                                                      no-error .
              if not available free_marking-lines
              then do :
                create free_marking-lines .
                assign
                  free_marking-lines.mark       = buf_marking-lines.mark
                  free_marking-lines.doc-level  = buf_marking-lines.doc-level
                  free_marking-lines.gds-code   = buf_marking-lines.gds-code
                  free_marking-lines.obj-type   = buf_parts.obj-type
                  free_marking-lines.obj-code   = buf_parts.obj-code
                  free_marking-lines.in-code    = buf_parts.in-code
                  free_marking-lines.out-code   = buf_parts.out-code
                  free_marking-lines.part-code  = buf_parts.part-code
                  free_marking-lines.prt-code   = buf_parts.prt-code
                .
              end .
              if avail buf_trn-doc and buf_trn-doc.doc-type <> 'инв':U and buf_trn-doc.doc-type <> 'спи':U and
                 not (buf_marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB and available (buf_trn-doc) and buf_trn-doc.ext-doc-type = 'vt':U)
                then assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
              if buf_trn-doc.ext-doc-type = 'es':U
              then do :
                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB .
              end .
              for each buf_marking-chk exclusive-lock where buf_marking-chk.mark begins buf_marking.mark :
                assign buf_marking-chk.sts = 0 .
              end .
            end .
            delete buf_marking-lines .
          end.
          if v-goods-twounit = true
          then do:
            assign
              buf_parts.cli-qnty = buf_parts.cli-qnty + v-unrv-sign * archive_parts.cli-qnty
            .
          end.
          else do:
            if buf_parts.cli-base-rate <> 0
            then do:
              assign
                buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
              .
            end.
            else do:
              assign
                buf_parts.cli-qnty = 0
              .
            end.
          end.
          if  buf_parts.qnty      = 0
          and buf_parts.fact-qnty = 0
          then do:
            if v-goods-twounit = true
            then do:
              if buf_parts.cli-qnty <> 0
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info21 skip
                  "Ошибка при удалении партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" buf_parts.in-code buf_parts.part-code skip
                  "Резерв" buf_parts.out-code skip
                  "qnty" buf_parts.qnty skip
                  "fact-qnty" buf_parts.fact-qnty skip
                  "cli-qnty" buf_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            for each del_marking-lines exclusive-lock where del_marking-lines.gds-code = v-gds-code
                                                        and del_marking-lines.obj-type = buf_parts.obj-type
                                                        and del_marking-lines.obj-code = buf_parts.obj-code
                                                        and del_marking-lines.in-code = buf_parts.in-code
                                                        and del_marking-lines.out-code = buf_parts.out-code
                                                        and del_marking-lines.part-code = buf_parts.part-code
                                                        and del_marking-lines.prt-code = buf_parts.prt-code:
              delete del_marking-lines .
            end.
            run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer buf_parts:handle)
                                        ,output part-key-rec).
            for each ub.gen-attr no-lock where ub.gen-attr.table-name = 'excise-mark':U
                                     and ub.gen-attr.p-key =  part-key-rec
            :
              find first buf1_gen-attr no-lock where recid (buf1_gen-attr) = recid (ub.gen-attr).
              find current buf1_gen-attr exclusive-lock.
              delete buf1_gen-attr .
            end.
            delete buf_parts .
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure partcopy-rsrv-parts :
  define input  parameter p-doc-code-rowid as rowid no-undo .
  define input  parameter p-parts-rowid    as rowid no-undo .
  define input  parameter p-rsrv-direction as logical   no-undo .
  define input  parameter p-goods-twounit  as logical   no-undo .
  define input  parameter p-is-hold        as logical   no-undo .
  define variable vss-description as character no-undo init "partcopy-rsrv-parts-01: процедура обработки партий при удалении документа".
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer archive_parts for ub.parts .
  define buffer buf_parts   for ub.parts .
  define buffer orig_marking-lines for ub.marking-lines .
  define buffer buf_marking-lines for ub.marking-lines .
  define buffer buf_marking   for ub.marking .
  define buffer buf_goods for ub.goods .
  define variable v-rsrv-code as character no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where rowid(buf_trn-doc) = p-doc-code-rowid
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info21 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" string(p-doc-code-rowid) skip
        "Партия" string(p-parts-rowid) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    find first archive_parts
      where rowid(archive_parts) = p-parts-rowid
      no-error .
    if not available archive_parts
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info21 skip
        "Ошибка задания входных параметров" skip
        "Не найдена партия" skip
        "Документ" string(p-doc-code-rowid) skip
        "Партия" string(p-parts-rowid) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if  archive_parts.out-code <> archive_parts.in-code
    and archive_parts.qnty <> 0
    and (buf_trn-doc.doc-type = 'при':U and buf_trn-doc.internal = yes ) = false
    and (buf_trn-doc.doc-type = 'возврат':U and p-is-hold = true  ) = false
    then do:
      assign
        v-rsrv-code =
        ( if (lookup(buf_trn-doc.doc-type, 'рас,спи':U) > 0 )
      or (buf_trn-doc.doc-type = 'инв':U and archive_parts.qnty < 0)
      then 'free-zone':U
      else 'out-zone':U )
      .
      run partcopy in this-procedure
        (input  true
        ,input  v-rsrv-code
        ,buffer archive_parts
        ,buffer buf_parts
        ,input  "news"
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info21 skip
          "Ошибка при создании партии" skip
          "Документ" buf_trn-doc.doc-code skip
          "Объект" archive_parts.obj-type archive_parts.obj-code skip
          "Артикул" archive_parts.artic archive_parts.prod-type archive_parts.prod-code skip
          "Партия" archive_parts.in-code archive_parts.part-code skip
          "Количество" archive_parts.qnty skip
          "Резерв" v-rsrv-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      assign
        buf_parts.qnty      = buf_parts.qnty     - abs(archive_parts.qnty)
                                                  * (if p-rsrv-direction = true
                                                    then 1
                                                    else -1
                                                    )
        buf_parts.fact-qnty = buf_parts.qnty
      .
      find first buf_goods no-lock where buf_goods.artic = archive_parts.artic
                                     and buf_goods.prod-type = archive_parts.prod-type
                                     and buf_goods.prod-code = archive_parts.prod-code
                                     .
      for each orig_marking-lines no-lock where orig_marking-lines.gds-code   = buf_goods.gds-code
                                            and orig_marking-lines.obj-type   = archive_parts.obj-type
                                            and orig_marking-lines.obj-code   = archive_parts.obj-code
                                            and orig_marking-lines.in-code    = archive_parts.in-code
                                            and orig_marking-lines.out-code   = archive_parts.out-code
                                            and orig_marking-lines.part-code  = archive_parts.part-code
                                            and orig_marking-lines.prt-code   = archive_parts.prt-code
                                            :
        find first buf_marking-lines no-lock where  buf_marking-lines.mark       = orig_marking-lines.mark
                                                and buf_marking-lines.gds-code   = buf_goods.gds-code
                                                and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                and buf_marking-lines.in-code    = buf_parts.in-code
                                                and buf_marking-lines.out-code   = buf_parts.out-code
                                                and buf_marking-lines.part-code  = buf_parts.part-code
                                                and buf_marking-lines.prt-code   = buf_parts.prt-code
                                                no-error .
        if available buf_marking-lines
        then do :
          find current buf_marking-lines exclusive-lock .
          delete buf_marking-lines .
          for first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
            assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB .
          end .
        end .
        else do :
          create buf_marking-lines .
          assign
            buf_marking-lines.mark       = orig_marking-lines.mark
            buf_marking-lines.doc-level  = orig_marking-lines.doc-level
            buf_marking-lines.gds-code   = buf_goods.gds-code
            buf_marking-lines.obj-type   = buf_parts.obj-type
            buf_marking-lines.obj-code   = buf_parts.obj-code
            buf_marking-lines.in-code    = buf_parts.in-code
            buf_marking-lines.out-code   = buf_parts.out-code
            buf_marking-lines.part-code  = buf_parts.part-code
            buf_marking-lines.prt-code   = buf_parts.prt-code
          .
          if buf_parts.out-code <> buf_parts.in-code
          and buf_parts.out-code <> 'free-zone':U
          and buf_parts.out-code <> 'out-zone':U
          then do :
            find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_parts.out-code no-error .
            if available buf_trn-doc then buf_marking-lines.fact-order = buf_trn-doc.fact-order .
          end .
          for first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
            assign
              buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB when buf_parts.out-code = 'free-zone':U
              buf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB when buf_parts.out-code = 'out-zone':U
            .
          end .
        end .
        release buf_marking-lines no-error .
      end.
      if p-goods-twounit = true
      then do:
        assign
          buf_parts.cli-qnty = buf_parts.cli-qnty - abs(archive_parts.cli-qnty)
                                                  * (if p-rsrv-direction = true
                                                    then 1
                                                    else -1
                                                    )
        .
      end.
      if  buf_parts.qnty      = 0
      and buf_parts.fact-qnty = 0
      then do:
        if p-goods-twounit = true
        then do:
          if buf_parts.cli-qnty <> 0
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info21 skip
              "Ошибка при удалении партии" skip
              "Документ" buf_trn-doc.doc-code skip
              "Объект" buf_parts.obj-type buf_parts.obj-code skip
              "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
              "Партия" buf_parts.in-code buf_parts.part-code skip
              "Резерв" buf_parts.out-code skip
              "qnty" buf_parts.qnty skip
              "fact-qnty" buf_parts.fact-qnty skip
              "cli-qnty" buf_parts.cli-qnty skip
              view-as alert-box error .
            undo, return error .
          end.
        end.
        delete buf_parts .
      end.
    end.
  end.
end procedure.
procedure partcopy-update-doc-line-tot-fact :
  define input  parameter p-doc-code  like ub.doc-line.doc-code  no-undo .
  define input  parameter p-artic     like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code like ub.doc-line.prod-code no-undo .
  define variable vss-description as character no-undo init "partcopy-update-doc-line-tot-fact-01: процедура обновления средней учетной цены в строке документа".
    define variable v-total-parts-qnty           like ub.parts.qnty      no-undo .   define variable v-total-parts-fact-qnty      like ub.parts.fact-qnty no-undo .   define variable v-total-parts-cli-qnty       like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-fact-cli-qnty  like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-price-cli      as decimal no-undo .   define variable v-total-parts-price-base     as decimal no-undo .   define variable v-total-parts-price-rubl     as decimal no-undo .   define variable v-total-parts-transport-base as decimal no-undo .   define variable v-total-parts-transport-rubl as decimal no-undo .   define variable v-total-parts-other-base     as decimal no-undo .   define variable v-total-parts-other-rubl     as decimal no-undo .
  define buffer buf_doc-line for ub.doc-line .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line exclusive-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info21 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    run partrqst in this-procedure
      (input buf_doc-line.doc-code
      ,input buf_doc-line.obj-type
      ,input buf_doc-line.obj-code
      ,input buf_doc-line.artic
      ,input buf_doc-line.prod-type
      ,input buf_doc-line.prod-code
            ,output v-total-parts-qnty   ,output v-total-parts-fact-qnty   ,output v-total-parts-cli-qnty   ,output v-total-parts-fact-cli-qnty   ,output v-total-parts-price-cli   ,output v-total-parts-price-base   ,output v-total-parts-price-rubl   ,output v-total-parts-transport-base   ,output v-total-parts-transport-rubl   ,output v-total-parts-other-base   ,output v-total-parts-other-rubl
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info21 skip
        "Ошибка при сборе информации по партиям" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-total-parts-fact-qnty <> 0
    then do:
      assign
        buf_doc-line.price-base      = v-total-parts-price-base
                                     / v-total-parts-fact-qnty
        buf_doc-line.price-rubl      = v-total-parts-price-rubl
                                     / v-total-parts-fact-qnty
        buf_doc-line.transport-base  = v-total-parts-transport-base
                                     / v-total-parts-fact-qnty
        buf_doc-line.transport-rubl  = v-total-parts-transport-rubl
                                     / v-total-parts-fact-qnty
        buf_doc-line.other-base      = v-total-parts-other-base
                                     / v-total-parts-fact-qnty
        buf_doc-line.other-rubl      = v-total-parts-other-rubl
                                     / v-total-parts-fact-qnty
      .
    end.
    else do:
    end.
  end.
end procedure.
procedure partcopy-change-purch-code :
  define input parameter  p-in-code          like ub.parts.in-code no-undo .
  define input parameter  p-dest-purch-code  like ub.parts.purch-code no-undo .
  define parameter buffer buf_orig_parts     for ub.parts .
  define parameter buffer buf1_parts         for ub.parts .
  define parameter buffer buf2_parts         for ub.parts .
  define variable vss-description as character no-undo init "partcopy-change-purch-code01: процедура копирования партии при смене purch-code".
  define variable var-out-code  like ub.parts.out-code no-undo .
  define variable var-part-code like ub.parts.part-code no-undo .
  define buffer buf_goods        for ub.goods .
  define buffer buf_parts-root   for ub.parts-root.
  define buffer buf_trn-doc      for ub.trn-doc.
  define buffer buf-orig_trn-doc for ub.trn-doc.
  define buffer buf_units        for ub.units .
  do
  on error undo, return error return-value
  :
    if buf_orig_parts.out-code = p-in-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info21 skip
        "Ошибка задания входных параметров процедуры partcopy" skip
        "buf_orig_parts.out-code" buf_orig_parts.out-code skip
        "p-in-code" p-in-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-in-code
      .
    find first buf-orig_trn-doc where buf-orig_trn-doc.doc-code = buf_orig_parts.out-code.
    find first buf_goods no-lock
      where buf_goods.artic = buf_orig_parts.artic
        and buf_goods.prod-type = buf_orig_parts.prod-type
        and buf_goods.prod-code = buf_orig_parts.prod-code
      .
    find first buf_units where buf_units.unit-name = buf_goods.unit-base no-lock.
    find first buf1_parts exclusive-lock
      where buf1_parts.obj-type  = buf_orig_parts.obj-type
        and buf1_parts.obj-code  = buf_orig_parts.obj-code
        and buf1_parts.artic     = buf_orig_parts.artic
        and buf1_parts.prod-type = buf_orig_parts.prod-type
        and buf1_parts.prod-code = buf_orig_parts.prod-code
        and buf1_parts.in-code   = buf_orig_parts.in-code
        and buf1_parts.out-code  = p-in-code
        and buf1_parts.part-code = buf_orig_parts.part-code
      no-error.
    if not available buf1_parts
    then do:
      create buf1_parts .
      buffer-copy buf_orig_parts to buf1_parts
      assign
        buf1_parts.in-code    = buf_orig_parts.in-code
        buf1_parts.out-code   = p-in-code
        buf1_parts.status_    = no
        buf1_parts.qnty       = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then buf_orig_parts.fact-qnty else - buf_orig_parts.fact-qnty )
        buf1_parts.fact-qnty  = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then buf_orig_parts.fact-qnty else - buf_orig_parts.fact-qnty )
        buf1_parts.cli-qnty   = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then buf_orig_parts.cli-qnty  else - buf_orig_parts.cli-qnty  )
        buf1_parts.purch-code = buf_orig_parts.purch-code
        buf1_parts.rsrv-free  = ?
        buf1_parts.status_    = yes
      .
      validate buf1_parts .
    end.
    if  lookup('сер':U, buf_units.type) > 0
    then do:
       var-part-code = buf_orig_parts.part-code.
    end.
    else do:
        run holdprts-get-part-code in this-procedure
          (input  p-in-code
          ,output var-part-code
          ) no-error .
        if error-status :error
        then dO:
          undo, return error return-value.
        end.
    end.
    find first buf2_parts exclusive-lock
      where buf2_parts.obj-type  = buf_orig_parts.obj-type
        and buf2_parts.obj-code  = buf_orig_parts.obj-code
        and buf2_parts.artic     = buf_orig_parts.artic
        and buf2_parts.prod-type = buf_orig_parts.prod-type
        and buf2_parts.prod-code = buf_orig_parts.prod-code
        and buf2_parts.in-code   = p-in-code
        and buf2_parts.out-code  = p-in-code
        and buf2_parts.part-code = var-part-code
      no-error.
    if not available buf2_parts
    then do:
      create buf2_parts .
      buffer-copy buf_orig_parts to buf2_parts
      assign
        buf2_parts.in-code   = p-in-code
        buf2_parts.out-code  = p-in-code
        buf2_parts.qnty      = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then - buf_orig_parts.fact-qnty else buf_orig_parts.fact-qnty )
        buf2_parts.fact-qnty = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then - buf_orig_parts.fact-qnty else buf_orig_parts.fact-qnty )
        buf2_parts.cli-qnty  = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then - buf_orig_parts.cli-qnty  else buf_orig_parts.cli-qnty  )
        buf2_parts.purch-code = p-dest-purch-code
        buf2_parts.part-code  = var-part-code
        buf2_parts.rsrv-free  = ?
        buf2_parts.status_    = yes
      .
      validate buf2_parts .
    end.
    assign
      buf_orig_parts.in-code    = p-in-code
      buf_orig_parts.part-code  = buf2_parts.part-code
      buf_orig_parts.purch-code = buf2_parts.purch-code
    .
    find first buf_parts-root
      where buf_parts-root.doc-code       = p-in-code
        and buf_parts-root.in-code        = p-in-code
        and buf_parts-root.gds-code       = buf_goods.gds-code
        and buf_parts-root.part-code      = buf2_parts.part-code
        and buf_parts-root.orig-in-code   = buf1_parts.in-code
        and buf_parts-root.orig-gds-code  = buf_goods.gds-code
        and buf_parts-root.orig-part-code = buf1_parts.part-code
      no-error .
    if not available buf_parts-root
    then do:
      create buf_parts-root.
      assign
      buf_parts-root.doc-code       = p-in-code
      buf_parts-root.in-code        = p-in-code
      buf_parts-root.gds-code       = buf_goods.gds-code
      buf_parts-root.part-code      = buf2_parts.part-code
      buf_parts-root.orig-in-code   = buf1_parts.in-code
      buf_parts-root.orig-gds-code  = buf_goods.gds-code
      buf_parts-root.orig-part-code = buf1_parts.part-code
      .
    end.
  end.
end procedure.
procedure addChildMarkingLines:
  define input parameter iMark as character no-undo.
  define input parameter iSts  as integer   no-undo.
  define parameter buffer buf_marking-lines  for ub.marking-lines.
  define parameter buffer buf_parts          for ub.parts.
  define parameter buffer orig_marking-lines for ub.marking-lines.
  define parameter buffer buf_orig_parts     for ub.parts.
  define parameter buffer buf_goods          for ub.goods.
  define buffer buf_marking-childs        for ub.marking.
  define buffer buf_marking-lines-childs  for ub.marking-lines.
  define buffer buf_marking-chk           for ub.marking-chk.
  define buffer buf_chk-doc               for ub.chk-doc.
  define buffer orig_marking-lines-childs for ub.marking-lines.
  for each buf_marking-childs exclusive-lock where
           buf_marking-childs.mark-parent = iMark :
      find first buf_marking-lines-childs no-lock where
                 buf_marking-lines-childs.mark       = buf_marking-childs.mark
             and buf_marking-lines-childs.gds-code   = buf_marking-lines.gds-code
             and buf_marking-lines-childs.obj-type   = buf_marking-lines.obj-type
             and buf_marking-lines-childs.obj-code   = buf_marking-lines.obj-code
             and buf_marking-lines-childs.in-code    = buf_marking-lines.in-code
             and buf_marking-lines-childs.out-code   = buf_marking-lines.out-code
             and buf_marking-lines-childs.part-code  = buf_marking-lines.part-code
             and buf_marking-lines-childs.prt-code   = buf_marking-lines.prt-code
      no-error .
      if not available buf_marking-lines-childs then
      do:
        create buf_marking-lines-childs .
        assign
          buf_marking-lines-childs.mark       = buf_marking-childs.mark
          buf_marking-lines-childs.gds-code   = buf_marking-lines.gds-code
          buf_marking-lines-childs.obj-type   = buf_marking-lines.obj-type
          buf_marking-lines-childs.obj-code   = buf_marking-lines.obj-code
          buf_marking-lines-childs.in-code    = buf_marking-lines.in-code
          buf_marking-lines-childs.out-code   = buf_marking-lines.out-code
          buf_marking-lines-childs.part-code  = buf_marking-lines.part-code
          buf_marking-lines-childs.prt-code   = buf_marking-lines.prt-code
          buf_marking-lines-childs.fact-order = buf_marking-lines.fact-order
          buf_marking-lines-childs.doc-level  = buf_marking-lines.doc-level + 1
        .
        validate buf_marking-childs.
      end .
      buf_marking-childs.sts = iSts .
      for each buf_marking-chk exclusive-lock where
               buf_marking-chk.mark begins buf_marking-childs.mark
      :
        for first buf_chk-doc no-lock where
                  buf_chk-doc.doc-code = buf_marking-chk.doc-code
              and buf_chk-doc.out-code = buf_parts.out-code
        :
          buf_marking-chk.sts = 0 .
          validate buf_marking-chk.
        end .
      end .
      if available orig_marking-lines
      then do :
        find first orig_marking-lines-childs exclusive-lock where
                   orig_marking-lines-childs.mark       = buf_marking-childs.mark
               and orig_marking-lines-childs.gds-code   = buf_goods.gds-code
               and orig_marking-lines-childs.obj-type   = buf_orig_parts.obj-type
               and orig_marking-lines-childs.obj-code   = buf_orig_parts.obj-code
               and orig_marking-lines-childs.in-code    = buf_orig_parts.in-code
               and orig_marking-lines-childs.out-code   = buf_orig_parts.out-code
               and orig_marking-lines-childs.part-code  = buf_orig_parts.part-code
               and orig_marking-lines-childs.prt-code   = buf_orig_parts.prt-code
        no-error .
        if available orig_marking-lines-childs then
          delete orig_marking-lines-childs .
      end.
      run addChildMarkingLines in this-procedure (
        buf_marking-childs.mark,
        iSts,
        buffer buf_marking-lines,
        buffer buf_parts,
        buffer orig_marking-lines,
        buffer buf_orig_parts,
        buffer buf_goods
      ).
  end .
end.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdsobjcl :
  define input parameter p-gds-obj-recid    as recid no-undo .
  define input parameter p-update-fact-qnty as logical   no-undo .
  define variable vss-description as character no-undo init "$Workfile$ gdsobjcl: расчет записи товар на объекте ".
  define buffer buf_parts for ub.parts .
  define variable v-total-avrg-base as decimal no-undo .
  define variable v-total-avrg-rubl as decimal no-undo .
  define variable v-total-avrg-qnty as decimal no-undo .
  define variable v-parts-avrg-qnty as decimal no-undo .
  define variable v-total-fact-base as decimal no-undo .
  define variable v-total-fact-rubl as decimal no-undo .
  define variable v-total-fact-qnty as decimal no-undo .
  define variable v-parts-fact-qnty as decimal   no-undo .
  define buffer buf_gds-obj for ub.gds-obj .
  define buffer buf_prt-obj for ub.prt-obj .
  define buffer buf_gds-prt for ub.gds-prt .
  do
  on error undo, return error return-value
  :
    find first buf_gds-obj exclusive-lock
      where recid(buf_gds-obj) = p-gds-obj-recid
      no-error .
    if not available buf_gds-obj
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найдена запись товар на объекте" skip
        "Код записи (recid)" p-gds-obj-recid skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      v-total-avrg-base = 0
      v-total-avrg-rubl = 0
      v-total-avrg-qnty = 0
      v-total-fact-base = 0
      v-total-fact-rubl = 0
      v-total-fact-qnty = 0
    .
    for each buf_parts no-lock
      where buf_parts.obj-type  = buf_gds-obj.obj-type
        and buf_parts.obj-code  = buf_gds-obj.obj-code
        and buf_parts.artic     = buf_gds-obj.artic
        and buf_parts.prod-type = buf_gds-obj.prod-type
        and buf_parts.prod-code = buf_gds-obj.prod-code
        and buf_parts.status_   = no
        and buf_parts.rsrv-free = yes
        and buf_parts.in-code   <> buf_parts.out-code
        and buf_parts.doc-type  <> 'акт':U
    on error undo, return error return-value
    :
      assign
        v-parts-avrg-qnty = 0
        v-parts-fact-qnty = 0
      .
      if buf_parts.out-code = 'free-zone':U
      then do:
        if buf_parts.fact-qnty > 0
        then do:
          assign
            v-parts-avrg-qnty = buf_parts.qnty
          .
        end.
        assign
          v-parts-fact-qnty = buf_parts.qnty
        .
      end.
      else do:
        assign
          v-parts-avrg-qnty = abs(buf_parts.qnty)
          v-parts-fact-qnty = abs(buf_parts.qnty)
        .
      end.
      assign
        v-total-avrg-base = v-total-avrg-base
                          + (buf_parts.price-base * v-parts-avrg-qnty)
        v-total-avrg-rubl = v-total-avrg-rubl
                          + (buf_parts.price-rubl * v-parts-avrg-qnty)
        v-total-avrg-qnty = v-total-avrg-qnty
                          + v-parts-avrg-qnty
        v-total-fact-base = v-total-fact-base
                          + (buf_parts.price-base * v-parts-fact-qnty)
        v-total-fact-rubl = v-total-fact-rubl
                          + (buf_parts.price-rubl * v-parts-fact-qnty)
        v-total-fact-qnty = v-total-fact-qnty
                          + v-parts-fact-qnty
      .
    end.
    if v-total-avrg-qnty < 0
    or v-total-avrg-qnty = ?
    then do:
      undo, return error
        vss-description + chr(10)
        + "Количество положительных партий в свободной зоне не может быть отрицательным или неопределенным" + chr(10)
        + "v-total-avrg-qnty " + (if v-total-avrg-qnty <> ? then string(v-total-avrg-qnty) else "?")
        .
    end.
    if v-total-fact-base = ?
    or v-total-fact-rubl = ?
    then do:
      undo, return error
        vss-description + chr(10)
        + "Сумма учетных цен по товару на объекте не может иметь неопределенное значение" + chr(10)
        + "v-total-fact-base " + (if v-total-fact-base <> ? then string(v-total-fact-base) else "?") + chr(10)
        + "v-total-fact-rubl " + (if v-total-fact-rubl <> ? then string(v-total-fact-rubl) else "?") + chr(10)
        .
    end.
    assign
      buf_gds-obj.avrg-qnty = v-total-avrg-qnty
      buf_gds-obj.fact-base = v-total-fact-base
      buf_gds-obj.fact-rubl = v-total-fact-rubl
    .
    if p-update-fact-qnty
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров"
        "В данной версии обновление фактического количества не реализовано" skip
        "p-update-fact-qnty" p-update-fact-qnty skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if buf_gds-obj.fact-qnty <> v-total-fact-qnty
    then do:
      undo, return error
        vss-description + chr(10)
        + "Не совпадает общее количество по партиям и фактическое количество по товару на объекте" + chr(10)
        + "buf_gds-obj.fact-qnty " + (if buf_gds-obj.fact-qnty <> ? then string(buf_gds-obj.fact-qnty) else "?") + chr(10)
        + "v-total-fact-qnty "     + (if v-total-fact-qnty     <> ? then string(v-total-fact-qnty)     else "?") + chr(10)
        .
    end.
    if v-total-avrg-qnty > 0
    then do:
      assign
        buf_gds-obj.avrg-base = v-total-avrg-base / v-total-avrg-qnty
        buf_gds-obj.avrg-rubl = v-total-avrg-rubl / v-total-avrg-qnty
      .
    end.
    else do:
      if  buf_gds-obj.last-base > 0
      and buf_gds-obj.last-rubl > 0
      then do:
        assign
          buf_gds-obj.avrg-base = buf_gds-obj.last-base
          buf_gds-obj.avrg-rubl = buf_gds-obj.last-rubl
        .
      end.
    end.
    define variable v-total-sale-fact-qnty as decimal   no-undo .
    define variable v-total-fact-sale      as decimal   no-undo .
    assign
      v-total-sale-fact-qnty = 0
      v-total-fact-sale      = 0
    .
    for each buf_prt-obj
      where buf_prt-obj.obj-type  = buf_gds-obj.obj-type
        and buf_prt-obj.obj-code  = buf_gds-obj.obj-code
        and buf_prt-obj.artic     = buf_gds-obj.artic
        and buf_prt-obj.prod-type = buf_gds-obj.prod-type
        and buf_prt-obj.prod-code = buf_gds-obj.prod-code
        and buf_prt-obj.is-term   = true
    on error undo, return error return-value
    :
      assign
        v-total-sale-fact-qnty  = v-total-sale-fact-qnty
                                + buf_prt-obj.fact-qnty
        v-total-fact-sale       = v-total-fact-sale
                                + buf_prt-obj.fact-qnty * buf_prt-obj.price-sale
      .
    end.
    if v-total-fact-sale = ?
    then do:
      undo, return error
        vss-description + chr(10)
        + "Сумма продажных цен по товару на объекте не может иметь неопределенное значение" + chr(10)
        + "v-total-fact-sale " + (if v-total-fact-sale <> ? then string(v-total-fact-sale) else "?") + chr(10)
        .
    end.
    if buf_gds-obj.fact-qnty <> v-total-sale-fact-qnty
    then do:
      undo, return error
        vss-description + chr(10)
        + "Не совпадает общее количество по признакам и фактическое количество по товару на объекте" + chr(10)
        + "buf_gds-obj.fact-qnty "  + (if buf_gds-obj.fact-qnty <> ?  then string(buf_gds-obj.fact-qnty)  else "?") + chr(10)
        + "v-total-sale-fact-qnty " + (if v-total-sale-fact-qnty <> ? then string(v-total-sale-fact-qnty) else "?") + chr(10)
        .
    end.
    assign
      buf_gds-obj.fact-sale = v-total-fact-sale
    .
  end.
end procedure .
procedure gdsobjcl-calc-goods :
  define input parameter p-artic     like ub.goods.artic     no-undo .
  define input parameter p-prod-type like ub.goods.prod-type no-undo .
  define input parameter p-prod-code like ub.goods.prod-code no-undo .
  define variable vss-description as character no-undo init "$Workfile$ gdsobjcl-calc-goods".
  do
  on error undo, return error return-value
  :
    define buffer buf_gds-obj for ub.gds-obj .
    define buffer buf_prt-obj for ub.prt-obj .
    do
    on error undo, return error return-value
    :
      for each buf_prt-obj
        where buf_prt-obj.artic     = p-artic
          and buf_prt-obj.prod-type = p-prod-type
          and buf_prt-obj.prod-code = p-prod-code
      on error undo, return error return-value
      :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtobjup in g#library
  (buffer buf_prt-obj
  ) no-error .
        if error-status :error
        then do:
          undo, return error
            "объект "  + string(buf_prt-obj.obj-type) + " " + string(buf_prt-obj.obj-code) + chr(10)
            + "артикул " + string(buf_prt-obj.artic) + " " + string(buf_prt-obj.prod-type) + " " + string(buf_prt-obj.prod-code) + chr(10)
            + "признак " + string(buf_prt-obj.prt-code) + chr(10)
            + return-value .
        end.
      end.
      for each buf_gds-obj
        where buf_gds-obj.artic     = p-artic
          and buf_gds-obj.prod-type = p-prod-type
          and buf_gds-obj.prod-code = p-prod-code
      on error undo, return error return-value
      :
        run gdsobjcl in this-procedure
          (input recid(buf_gds-obj)
          ,input false
          ) no-error .
        if error-status :error
        then do:
          undo, return error
            "объект " + string(buf_gds-obj.obj-type) + " " + string(buf_gds-obj.obj-code) + chr(10)
            + return-value .
        end.
      end.
    end.
  end.
end procedure.
define new global shared variable g#libtfarh as handle no-undo .
  define new global shared variable g#lib-rvs as handle no-undo.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
do
on error undo, return error return-value
:
  define buffer buf_trn-doc   for ub.trn-doc .
  define buffer buf_doc-line  for ub.doc-line .
  define buffer buf_parts     for ub.parts .
  define buffer buf_price-doc for ub.price-doc.
  define buffer buf_rvs-doc   for ub.rvs-doc .
  define buffer buf_gen-attr  for ub.gen-attr .
  define buffer buf_marking-lines for ub.marking-lines .
  define buffer free_marking-lines for ub.marking-lines .
  define buffer buf_marking   for ub.marking .
  define variable v-root-node         like ub.gds-prt.node-code no-undo .
  define variable v-ind-goods            as integer   no-undo .
  define variable v-start-time           as int64     no-undo .
  define variable v-current-time         as character no-undo .
  define variable v-current-action         as character no-undo .
  define variable v-description-doc-type as character no-undo .
  define variable v-doc-line-artic       like ub.doc-line.artic no-undo .
  define variable part-key-rec as character no-undo .
  define variable part-key-rec_free as character no-undo .
  define variable part-key-rec_out as character no-undo .
  define frame a
    buf_trn-doc.doc-code                       label "Документ" skip
    v-description-doc-type                     label "Тип документа" skip
    v-current-action         format "x(40)"      no-label skip
    v-ind-goods            format ">>>>>>>9"   label "Обработано артикулов" skip
    v-doc-line-artic                           label "Текущий артикул" skip
    v-current-time         format "x(8)"       label "Время" skip
    with view-as dialog-box side-labels three-d
    title "Удаление документа"
    .
  find first buf_trn-doc exclusive-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if not available buf_trn-doc
  then do:
    undo, return error substitute( "&1. Ошибка задания входных параметров.&2"
                                    + "Не найден документ &3&2"
                                    ,vss-workfile
                                    ,chr(10)
                                    ,p-doc-code
                                  ).
  end.
  view frame a.
  display
    buf_trn-doc.doc-code
    v-description-doc-type
    with frame a.
  assign
    v-start-time = etime
  .
  assign
    v-description-doc-type = buf_trn-doc.doc-type
                          + " " + string(buf_trn-doc.internal, "внут/внеш")
  .
  if buf_trn-doc.status_ <> 'факт':U
  or buf_trn-doc.is-del  <> true
  then do:
    undo, return error substitute( "&1. Данная программа может удалить только помеченные закрытые документы.&2"
                                    + "Документ &3&2"
                                    + "Статус &4&2"
                                    + "Отметка &5&2"
                                    ,vss-workfile
                                    ,chr(10)
                                    ,p-doc-code
                                    ,buf_trn-doc.status_
                                    ,buf_trn-doc.is-del
                                  ).
  end.
  if buf_trn-doc.status_ = 'факт':U
  then do:
    run show-action in this-procedure
      (input "Блокировка товаров на объекте"
      ).
    run trg/lock-gds.p
      (input buf_trn-doc.doc-code
      ,input true
      ,input no
      ,input (if buf_trn-doc.is-back-date = yes
            then 0
            else buf_trn-doc.fact-order)
      ,input 0
      ,input (buf_trn-doc.status_ = 'факт':U)
      ,input g#news
      ) no-error .
    if error-status :error
    then do:
      undo, return error substitute( "&1. Не удалось наложить блокировку на все товары принадлежащие документу.&2"
                                      + "Логический номер документа &3&2&4&2&5&2"
                                      ,vss-workfile
                                      ,chr(10)
                                      ,buf_trn-doc.fact-order
                                      ,error-status :get-message(1)
                                      ,return-value
                                    ).
    end.
    run show-action in this-procedure
      (input "Регистрация удаления документа"
      ).
    run trg/markdoc.p
      (input buf_trn-doc.doc-code
      ,input 'doc-delete':u
      ) no-error .
    if error-status :error
    then do:
      undo, return error substitute( "&1. Не удалось зарегистрировать удаление документа.&2"
                                      + "Логический номер документа &3&2&4&2&5&2"
                                      ,vss-workfile
                                      ,chr(10)
                                      ,buf_trn-doc.fact-order
                                      ,error-status :get-message(1)
                                      ,return-value
                                    ).
    end.
    if buf_trn-doc.status_ = 'факт':U then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'event_trn-doc':U
  ,input  buffer buf_trn-doc:handle
  ,input ?
  ,input ''
  ,input ''
  ) no-error .
      if error-status:error
      then do:
        define variable v-message as character no-undo .
        v-message = substitute("&1 &2 &3&4Ошибка при вызове процедуры rum-runa.i&4&5&4&5&6"
                                ,vss-workfile
                                ,vss-revision
                                ,vss-description
                                ,chr(10)
                                , error-status:get-message(1)
                                , return-value ).
        if not g#news
        and not g#auto
        and not g#esys
        then do:
          message
          v-message
          view-as alert-box error .
        end.
        undo,  return error v-message.
      end.
    end.
    run show-action in this-procedure
      (input "Удаление сверок связанных с документом"
      ).
    for each buf_rvs-doc exclusive-lock
      where buf_rvs-doc.out-code = buf_trn-doc.doc-code
    on error undo, return error return-value
    :
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_hstc-rvs in g#lib-rvs
( buffer buf_rvs-doc
 ,input integer('99':U)
 ,input buf_trn-doc.doc-code
 ,input p-chip-num
) no-error.
      if error-status :error then do:
        undo, return error return-value.
      end.
      assign
        buf_rvs-doc.is-del = yes
      .
      delete buf_rvs-doc.
    end.
    run show-action in this-procedure
      (input "Удаление финансовых архивов по документу"
      ).
if (valid-handle(g#libtfarh) <> true) then do:   run str/libtfarh.p persistent no-error .   if error-status :error or (valid-handle(g#libtfarh) <> true) then do:     message       "Error starting libtfarh.p" skip       g#libtfarh skip       g#libtfarh :type skip       g#libtfarh :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libtfarh_datrncnt in g#libtfarh
(input  buf_trn-doc.doc-code
) .
    run show-action in this-procedure
      (input "Удаление строк документа"
      ).
    for each buf_doc-line
      where buf_doc-line.doc-code = buf_trn-doc.doc-code
    on error undo, return error
    :
      assign
        v-ind-goods = v-ind-goods + 1
      .
      if v-ind-goods mod 10 = 0
      then do:
        assign
          v-current-time = string(integer(truncate((etime - v-start-time) / 1000, 0)), 'HH:MM:SS':U)
        .
        assign
          v-doc-line-artic = buf_doc-line.artic
        .
        display
          v-ind-goods v-doc-line-artic v-current-time v-current-action
          with frame a.
      end.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output v-root-node
  ) no-error .
      if error-status :error
      then do:
        undo, return error substitute( "&1. Ошибка при определении корневого признака товара.&2"
                                       + "Товар &3 &4 &5&2"
                                       + "Логический номер документа &6&2&7&2&8&2"
                                       ,vss-workfile
                                       ,chr(10)
                                       ,buf_doc-line.artic
                                       ,buf_doc-line.prod-type
                                       ,buf_doc-line.prod-code
                                       ,buf_doc-line.fact-order
                                       ,error-status :get-message(1)
                                       ,return-value
                                      ).
      end.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscheck in g#library
  (input buf_doc-line.obj-type
  ,input buf_doc-line.obj-code
  ,input buf_doc-line.artic
  ,input buf_doc-line.prod-type
  ,input buf_doc-line.prod-code
  ,input v-root-node
  ,input ''
  ) no-error .
      if error-status :error
      then do:
        undo, return error substitute( "&1. Ошибка при проверке целостности товара.&2"
                                       + "Товар &3 &4 &5&2"
                                       + "Логический номер документа &6&2&7&2&8&2"
                                       ,vss-workfile
                                       ,chr(10)
                                       ,buf_doc-line.artic
                                       ,buf_doc-line.prod-type
                                       ,buf_doc-line.prod-code
                                       ,buf_doc-line.fact-order
                                       ,error-status :get-message(1)
                                       ,return-value
                                      ).
      end.
      run partcopy-update-parts-delete in this-procedure
        (input buf_doc-line.doc-code
        ,input buf_doc-line.obj-type
        ,input buf_doc-line.obj-code
        ,input buf_doc-line.artic
        ,input buf_doc-line.prod-type
        ,input buf_doc-line.prod-code
        ) no-error .
      if error-status :error
      then do:
        undo, return error substitute( "&1. Ошибка при обработке партий.&2"
                                       + "Товар &3 &4 &5&2"
                                       + "Логический номер документа &6&2&7&2&8&2"
                                       ,vss-workfile
                                       ,chr(10)
                                       ,buf_doc-line.artic
                                       ,buf_doc-line.prod-type
                                       ,buf_doc-line.prod-code
                                       ,buf_doc-line.fact-order
                                       ,error-status :get-message(1)
                                       ,return-value
                                      ).
      end.
      run trndocgs in this-procedure
        (input buf_doc-line.doc-code
        ,input buf_doc-line.artic
        ,input buf_doc-line.prod-type
        ,input buf_doc-line.prod-code
        ,input v-root-node
        ,input false
        ,input false
        ,input true
        ) no-error .
      if error-status :error
      then do:
        undo, return error substitute( "&1. Ошибка при обработке архивов по строке.&2"
                                       + "Товар &3 &4 &5&2"
                                       + "Логический номер документа &6&2&7&2&8&2"
                                       ,vss-workfile
                                       ,chr(10)
                                       ,buf_doc-line.artic
                                       ,buf_doc-line.prod-type
                                       ,buf_doc-line.prod-code
                                       ,buf_doc-line.fact-order
                                       ,error-status :get-message(1)
                                       ,return-value
                                      ).
      end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_reclcptr in g#lib-trn3
( input ?
 ,input (buffer buf_doc-line :handle)
 ,input -1.0
 ,input buf_doc-line.ext-doc-type
 ,input p-chip-num
) no-error .
      if error-status :error then do:
        undo, return error substitute( "&1. Ошибка при пересчете сверок и нарастающего итога.&2"
                                       + "Товар &3 &4 &5&2&6&2"
                                       ,vss-workfile
                                       ,chr(10)
                                       ,buf_doc-line.artic
                                       ,buf_doc-line.prod-type
                                       ,buf_doc-line.prod-code
                                       ,return-value
                                     ).
      end.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscheck in g#library
  (input buf_doc-line.obj-type
  ,input buf_doc-line.obj-code
  ,input buf_doc-line.artic
  ,input buf_doc-line.prod-type
  ,input buf_doc-line.prod-code
  ,input v-root-node
  ,input ''
  ) no-error .
      if error-status :error
      then do:
        undo, return error substitute( "&1. Ошибка при проверке целостности товара.&2"
                                       + "Товар &3 &4 &5&2"
                                       + "Логический номер документа &6&2&7&2&8&2"
                                       ,vss-workfile
                                       ,chr(10)
                                       ,buf_doc-line.artic
                                       ,buf_doc-line.prod-type
                                       ,buf_doc-line.prod-code
                                       ,buf_doc-line.fact-order
                                       ,error-status :get-message(1)
                                       ,return-value
                                      ).
      end.
    end.
    run show-action in this-procedure
      (input "Обновление остатков по поставщику на фирме"
      ).
    run trg/trn-supp.p
      (input  buf_trn-doc.doc-code
      ,input  false
      ,input  true
      ,input  false
      ) no-error .
    if error-status :error
    then do:
      undo, return error substitute( "&1. Ошибка при обновлении остатков по поставщику на фирме.&2"
                                      + "Логический номер документа &3&2"
                                      + "Расширенный тип документа &4&2&5&2&6&2"
                                      ,vss-workfile
                                      ,chr(10)
                                      ,buf_trn-doc.fact-order
                                      ,buf_trn-doc.ext-doc-type
                                      ,error-status :get-message(1)
                                      ,return-value
                                    ).
    end.
    run show-action in this-procedure
      (input "Удаление архивных партий"
      ).
    for each buf_parts exclusive-lock
      where buf_parts.out-code = buf_trn-doc.doc-code
    on error undo, return error return-value
    :
      run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer buf_parts:handle)
                                        ,output part-key-rec).
      part-key-rec_free = part-key-rec .
      part-key-rec_out = part-key-rec .
      entry(8,part-key-rec_free,chr(3)) = 'free-zone':U .
      entry(8,part-key-rec_out,chr(3)) = 'out-zone':U .
      for each ub.gen-attr where ub.gen-attr.table-name = 'excise-mark':U
                                     and ub.gen-attr.p-key =  part-key-rec
      on error undo, return error substitute( "&1&2&3", vss-workfile, chr(10), return-value )
      :
          delete ub.gen-attr.
      end.
      if buf_trn-doc.doc-type = 'при':U then do:
      for each ub.gen-attr where ub.gen-attr.table-name = 'excise-mark':U
                                     and ub.gen-attr.p-key =  part-key-rec_free
      on error undo, return error substitute( "&1&2&3", vss-workfile, chr(10), return-value )
      :
          delete ub.gen-attr.
      end.
      end.
      else do:
      for each ub.gen-attr where ub.gen-attr.table-name = 'excise-mark':U
                                     and ub.gen-attr.p-key =  part-key-rec_out
      on error undo, return error substitute( "&1&2&3", vss-workfile, chr(10), return-value )
      :
                find first buf_gen-attr exclusive-lock where buf_gen-attr.table-name = 'excise-mark':U
                    and buf_gen-attr.attr-code = ub.gen-attr.attr-code
                    and num-entries (buf_gen-attr.p-key, chr(3)) >= 8
                    and entry(8, buf_gen-attr.p-key, chr(3)) = 'free-zone':U
                    no-error .
                if not available (buf_gen-attr) then do:
                   buffer-copy ub.gen-attr except ub.gen-attr.p-key to buf_gen-attr .
                    assign
                        buf_gen-attr.p-key = part-key-rec_free
                        .
                end.
          delete ub.gen-attr.
      end.
      end.
      define variable vsds as class ibs.th.str.mercury.vsdsubs no-undo.
      define variable vsdstr as class ibs.th.gbl.storage.vsdtostorage no-undo.
      define variable ii as integer no-undo.
      vsds = new ibs.th.str.mercury.vsdsubs ().
      vsdstr = new ibs.th.gbl.storage.vsdtostorage ().
      vsds = vsdstr:getVSDsubs(input "part-key", input part-key-rec).
      do ii = 1 to vsds:GetItem(ii):
        vsdstr:deleteDB(vsds:VsdObjCurr).
      end.
      delete object vsds no-error.
      delete object vsdstr no-error.
      define variable v-gds-code as integer   no-undo .
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_parts.artic
  ,input  buf_parts.prod-type
  ,input  buf_parts.prod-code
  ,output v-gds-code
  ) no-error .
      for each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = v-gds-code
                                                  and buf_marking-lines.obj-type = buf_parts.obj-type
                                                  and buf_marking-lines.obj-code = buf_parts.obj-code
                                                  and buf_marking-lines.in-code  = buf_parts.in-code
                                                  and buf_marking-lines.out-code = buf_parts.out-code
                                                  and buf_marking-lines.part-code = buf_parts.part-code
                                                  and buf_marking-lines.prt-code = buf_parts.prt-code:
        for first buf_marking exclusive-lock where buf_marking.mark = buf_marking-lines.mark :
          if buf_trn-doc.doc-type = 'при':U
          or buf_trn-doc.doc-type = 'возврат':U
          then do :
          end .
          else do :
            find first free_marking-lines no-lock where free_marking-lines.mark       = buf_marking-lines.mark
                                                    and free_marking-lines.gds-code   = buf_marking-lines.gds-code
                                                    and free_marking-lines.obj-type   = buf_marking-lines.obj-type
                                                    and free_marking-lines.obj-code   = buf_marking-lines.obj-code
                                                    and free_marking-lines.in-code    = buf_marking-lines.in-code
                                                    and free_marking-lines.out-code   = 'free-zone':U
                                                    and free_marking-lines.part-code  = buf_marking-lines.part-code
                                                    and free_marking-lines.prt-code   = buf_marking-lines.prt-code
                                                    no-error .
            if not available free_marking-lines
            then do :
              create free_marking-lines .
              assign
                free_marking-lines.mark       = buf_marking-lines.mark
                free_marking-lines.doc-level  = buf_marking-lines.doc-level
                free_marking-lines.gds-code   = buf_marking-lines.gds-code
                free_marking-lines.obj-type   = buf_marking-lines.obj-type
                free_marking-lines.obj-code   = buf_marking-lines.obj-code
                free_marking-lines.in-code    = buf_marking-lines.in-code
                free_marking-lines.out-code   = 'free-zone':U
                free_marking-lines.part-code  = buf_marking-lines.part-code
                free_marking-lines.prt-code   = buf_marking-lines.prt-code
              .
            end .
            if not (buf_marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB and available (buf_trn-doc) and buf_trn-doc.ext-doc-type = 'vt':U)
              then assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
          end .
        end .
        delete buf_marking-lines .
      end.
      delete buf_parts .
    end.
    define buffer buf_parts-root for ub.parts-root .
    for each buf_parts-root exclusive-lock
      where buf_parts-root.doc-code = buf_trn-doc.doc-code
    on error undo, return error return-value
    :
      delete buf_parts-root .
    end.
    define buffer buf_parts-attr for ub.parts-attr .
    for each buf_parts-attr exclusive-lock
      where buf_parts-attr.in-code = buf_trn-doc.doc-code
    on error undo, return error return-value
    :
      define buffer buf_goods for ub.goods .
      find first buf_goods no-lock
        where buf_goods.gds-code = buf_parts-attr.gds-code
        no-error .
      if not available buf_goods
      then do:
        undo, return error substitute( "&1. Не найден товар.&2"
                                       + "Код товара &3&2"
                                       + "Логический номер документа &4&2"
                                       + "Расширенный тип документа &5&2"
                                       ,vss-workfile
                                       ,chr(10)
                                       ,buf_parts-attr.gds-code
                                       ,buf_doc-line.fact-order
                                       ,buf_trn-doc.ext-doc-type
                                      ).
      end.
      if not g#news then for each buf_parts no-lock
        where buf_parts.artic     = buf_goods.artic
          and buf_parts.prod-type = buf_goods.prod-type
          and buf_parts.prod-code = buf_goods.prod-code
          and buf_parts.in-code   = buf_parts-attr.in-code
          and buf_parts.part-code = buf_parts-attr.part-code
      on error undo, return error return-value
      :
        find first buf_price-doc no-lock
          where buf_price-doc.doc-num = buf_parts.out-code
          no-error .
        if available buf_price-doc
        then do:
        end.
        else do:
          undo, return error substitute( "&1. Удаление невозможно.&2Найдены партии для атрибутов.&2"
                                          + "Логический номер документа &3&2"
                                          + "Расширенный тип документа &4&2"
                                          + "Объект партии &5 &6&2"
                                          ,vss-workfile
                                          ,chr(10)
                                          ,buf_trn-doc.fact-order
                                          ,buf_trn-doc.ext-doc-type
                                          ,buf_parts.obj-type
                                          ,buf_parts.obj-code
                                        )
                           + substitute( "Товар &2&1&3&1&4&1"
                                          + "Резерв &5&2"
                                          + "Партия &6 &7&2"
                                          + "Количество &8&2"
                                          + "Фактическое количество &9&2"
                                          ,chr(10)
                                          ,buf_parts.artic
                                          ,buf_parts.prod-type
                                          ,buf_parts.prod-code
                                          ,buf_parts.out-code
                                          ,buf_parts.in-code
                                          ,buf_parts.part-code
                                          ,buf_parts.qnty
                                          ,buf_parts.fact-qnty
                                        ).
        end.
      end.
      delete buf_parts-attr .
    end.
  end.
  if buf_trn-doc.ext-doc-type = 'vt':U then do:
     run str/del-invc.p
       ( input buf_trn-doc.doc-code
        ,input buf_trn-doc.obj-type
        ,input buf_trn-doc.obj-code
       ) no-error .
    if error-status :error
    then do:
      undo, return error substitute( "&1. Не удалось удалить чеки по документу инвентаризации.&2"
                                      + "Логический номер документа &3&2"
                                      + "Расширенный тип документа &4&2&5&2&6&2"
                                      ,vss-workfile
                                      ,chr(10)
                                      ,buf_trn-doc.fact-order
                                      ,buf_trn-doc.ext-doc-type
                                      ,error-status :get-message(1)
                                      ,return-value
                                    ).
    end.
  end.
  if g#news
  and g#db-num = 0
  and (buf_trn-doc.ext-doc-type = 're':U OR
        buf_trn-doc.ext-doc-type = 'ee':U)
        and buf_trn-doc.d-card       <> ""
        and buf_trn-doc.d-card       <> ?
  then do:
    define variable v-deleted as logical no-undo .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-del in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'need-saledc':U ,
                       output v-deleted ) no-error .
  end.
  if g#news
  and g#db-num = 0
  and (buf_trn-doc.ext-doc-type = 'vt':U
    or buf_trn-doc.ext-doc-type = 'wm':U
    or buf_trn-doc.ext-doc-type = 'we':U)
  then do :
    define buffer buf_utd for ub.utd .
    for each buf_utd exclusive-lock where buf_utd.doc-code = buf_trn-doc.doc-code :
      case buf_utd.sts :
        when ObjSrv:Env:Utd:Sts:TH:LK_RECEIPT_New:KeyIntDB
        or when ObjSrv:Env:Utd:Sts:TH:LK_RECEIPT_Signed:KeyIntDB
        then do :
          buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:LK_RECEIPT_NewDelete:KeyIntDB .
        end .
        when ObjSrv:Env:Utd:Sts:TH:LK_RECEIPT_Sent:KeyIntDB
        or when ObjSrv:Env:Utd:Sts:TH:LK_RECEIPT_Error:KeyIntDB
        or when ObjSrv:Env:Utd:Sts:TH:LK_RECEIPT_Confirmed:KeyIntDB
        then do :
          buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:LK_RECEIPT_SentDelete:KeyIntDB .
        end .
      end case .
    end .
  end .
  run show-action in this-procedure
    (input "Документ удален"
    ).
end.
procedure show-action :
  do
  on error undo, return error
  :
    define input parameter p-action as character no-undo .
    assign
      v-current-time = string(integer(truncate((etime - v-start-time) / 1000, 0)), 'HH:MM:SS':U)
      v-current-action = p-action
    .
    display
      v-current-time v-current-action
      with frame a.
  end.
end procedure.
