block-level on error undo, throw.
define input  parameter p-doc-code   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создать запись о том, что необходимо пересчитать межфирменные архивы по документу".
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
      p-vss-parameters = substitute('&1',p-doc-code)
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
define variable v-start-date as date      no-undo .
define buffer buf_trn-doc   for ub.trn-doc   .
define buffer buf_hold-time for ub.hold-time .
define buffer buf_hold-trn  for ub.hold-trn  .
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
      "Ошибка задания входных параметров" skip
      "Не найден документ" p-doc-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if buf_trn-doc.fact-date = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не задана дата фактического закрытия документа" skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    v-start-date = date(month(buf_trn-doc.fact-date), 1, year(buf_trn-doc.fact-date))
  .
  find first buf_hold-time no-lock
    where buf_hold-time.cat-code   = 1
      and buf_hold-time.time-type  = 'мес':U
      and buf_hold-time.start-date = v-start-date
    no-error .
  if available buf_hold-time
  then do:
    find first buf_hold-trn no-lock
      where buf_hold-trn.cat-code  = 1
        and buf_hold-trn.doc-code  = p-doc-code
        and buf_hold-trn.time-code = buf_hold-time.time-code
      no-error .
    if available buf_hold-trn
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "ВНИМАНИЕ!!!!" skip
        "Попытка повторного создания записи расчета межфирменного архива" skip
        "Пожалуйста, не закрывайте это сообщение и позвните в службу поддержки" skip
        "Межфирменный архив по приходам и продажам" skip
        "Документ" p-doc-code skip
        "Дата фактического закрытия" buf_trn-doc.fact-date skip
        "Дата начала периода" v-start-date skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
  find first buf_hold-time no-lock
    where buf_hold-time.cat-code   = 2
      and buf_hold-time.time-type  = 'мес':U
      and buf_hold-time.start-date = v-start-date
    no-error .
  if available buf_hold-time
  then do:
    find first buf_hold-trn no-lock
      where buf_hold-trn.cat-code  = 2
        and buf_hold-trn.doc-code  = p-doc-code
        and buf_hold-trn.time-code = buf_hold-time.time-code
      no-error .
    if available buf_hold-trn
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "ВНИМАНИЕ!!!!" skip
        "Попытка повторного создания записи расчета межфирменного архива" skip
        "Пожалуйста, не закрывайте это сообщение и позвните в службу поддержки" skip
        "Межфирменный архив по инвентаризациям" skip
        "Документ" p-doc-code skip
        "Дата фактического закрытия" buf_trn-doc.fact-date skip
        "Дата начала периода" v-start-date skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
  find first buf_hold-time no-lock
    where buf_hold-time.cat-code   = 3
      and buf_hold-time.time-type  = 'мес':U
      and buf_hold-time.start-date = v-start-date
    no-error .
  if available buf_hold-time
  then do:
    find first buf_hold-trn no-lock
      where buf_hold-trn.cat-code  = 3
        and buf_hold-trn.doc-code  = p-doc-code
        and buf_hold-trn.time-code = buf_hold-time.time-code
      no-error .
    if available buf_hold-trn
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "ВНИМАНИЕ!!!!" skip
        "Попытка повторного создания записи расчета межфирменного архива" skip
        "Пожалуйста, не закрывайте это сообщение и позвните в службу поддержки" skip
        "Межфирменный архив по списаниям" skip
        "Документ" p-doc-code skip
        "Дата фактического закрытия" buf_trn-doc.fact-date skip
        "Дата начала периода" v-start-date skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
  find first ub.batchprocess no-lock
    where ub.batchprocess.bp_type   = 'hold':U
      and ub.batchprocess.bp_status = 'N':U
      and ub.batchprocess.charkey_one = p-doc-code
  no-error .
  if not available ub.BatchProcess then do:
    create ub.BatchProcess .
        define variable v-btpr_upd-today-1 as date      no-undo.
    define variable v-btpr_upd-time-1  as integer   no-undo.
    run cur-time in this-procedure ( output v-btpr_upd-today-1
                                   , output v-btpr_upd-time-1
                                   ).
    assign
      ub.BatchProcess.BP_Type       = 'hold':U
      ub.BatchProcess.BP_Status     = 'N':U
      ub.BatchProcess.BatchProcess# = next-value( s-btpr, ub )
      ub.BatchProcess.User_ID       = g#userid
      ub.BatchProcess.BP_SysDate    = v-btpr_upd-today-1
      ub.BatchProcess.BP_SysTime    = string( v-btpr_upd-time-1, 'HH:MM' )
      ub.BatchProcess.BP_SysTimeInt = v-btpr_upd-time-1
    .
    assign
      ub.BatchProcess.CharKey_One   = p-doc-code
    .
  end.
  find first ub.batchprocess no-lock
    where ub.batchprocess.bp_type   = 'hinv':U
      and ub.batchprocess.bp_status = 'N':U
      and ub.batchprocess.charkey_one = p-doc-code
  no-error .
  if not available ub.BatchProcess then do:
    create ub.BatchProcess .
        define variable v-btpr_upd-today-2 as date      no-undo.
    define variable v-btpr_upd-time-2  as integer   no-undo.
    run cur-time in this-procedure ( output v-btpr_upd-today-2
                                   , output v-btpr_upd-time-2
                                   ).
    assign
      ub.BatchProcess.BP_Type       = 'hinv':U
      ub.BatchProcess.BP_Status     = 'N':U
      ub.BatchProcess.BatchProcess# = next-value( s-btpr, ub )
      ub.BatchProcess.User_ID       = g#userid
      ub.BatchProcess.BP_SysDate    = v-btpr_upd-today-2
      ub.BatchProcess.BP_SysTime    = string( v-btpr_upd-time-2, 'HH:MM' )
      ub.BatchProcess.BP_SysTimeInt = v-btpr_upd-time-2
    .
    assign
      ub.BatchProcess.CharKey_One   = p-doc-code
    .
  end.
  find first ub.batchprocess no-lock
    where ub.batchprocess.bp_type   = 'hspi':U
      and ub.batchprocess.bp_status = 'N':U
      and ub.batchprocess.charkey_one = p-doc-code
  no-error .
  if not available ub.BatchProcess then do:
    create ub.BatchProcess .
        define variable v-btpr_upd-today-3 as date      no-undo.
    define variable v-btpr_upd-time-3  as integer   no-undo.
    run cur-time in this-procedure ( output v-btpr_upd-today-3
                                   , output v-btpr_upd-time-3
                                   ).
    assign
      ub.BatchProcess.BP_Type       = 'hspi':U
      ub.BatchProcess.BP_Status     = 'N':U
      ub.BatchProcess.BatchProcess# = next-value( s-btpr, ub )
      ub.BatchProcess.User_ID       = g#userid
      ub.BatchProcess.BP_SysDate    = v-btpr_upd-today-3
      ub.BatchProcess.BP_SysTime    = string( v-btpr_upd-time-3, 'HH:MM' )
      ub.BatchProcess.BP_SysTimeInt = v-btpr_upd-time-3
    .
    assign
      ub.BatchProcess.CharKey_One   = p-doc-code
    .
  end.
end.
