block-level on error undo, throw.
define input  parameter p-process-key    as character no-undo .
define input  parameter p-Key#_One       like ub.batchprocess.Key#_One      no-undo .
define input  parameter p-Key#_Two       like ub.batchprocess.Key#_Two      no-undo .
define input  parameter p-Key#_Three     like ub.batchprocess.Key#_Three    no-undo .
define input  parameter p-CharKey_One    like ub.batchprocess.CharKey_One   no-undo .
define input  parameter p-CharKey_Two    like ub.batchprocess.CharKey_Two   no-undo .
define input  parameter p-CharKey_Three  like ub.batchprocess.CharKey_Three no-undo .
define input  parameter p-lock-type      as character no-undo .
define parameter buffer lock_batchprocess for ub.batchprocess .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: lockshpr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/lockshpr.p $":U .
define variable vss-description as character no-undo init "Программа блокировки ресурсов".
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
      p-vss-parameters = substitute('&1|&2':u,substitute('&1|&2|&3|&4|&5':u,p-process-key,p-Key#_One,p-Key#_Two,p-Key#_Three,p-CharKey_One),substitute('&1|&2|&3':u,p-CharKey_Two,p-CharKey_Three,p-lock-type))
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
define buffer buf_batchprocess for ub.batchprocess .
define buffer delete_batchprocess for ub.batchprocess .
do
on error undo, return error return-value
:
  if length(p-process-key) > 4
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания параметров" skip
      "Ключ блокирования процесса не может превышать 4 символа" skip
      "p-process-key"   p-process-key   skip
      "p-Key#_One"      p-Key#_One      skip
      "p-Key#_Two"      p-Key#_Two      skip
      "p-Key#_Three"    p-Key#_Three    skip
      "p-CharKey_One"   p-CharKey_One   skip
      "p-CharKey_Two"   p-CharKey_Two   skip
      "p-CharKey_Three" p-CharKey_Three skip
      "p-lock-type"     p-lock-type     skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if  p-lock-type <> 'share-lock':u
  and p-lock-type <> 'exclusive-lock':u
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания параметров" skip
      "Неизвестный тип блокирования процесса" skip
      "p-process-key"   p-process-key   skip
      "p-Key#_One"      p-Key#_One      skip
      "p-Key#_Two"      p-Key#_Two      skip
      "p-Key#_Three"    p-Key#_Three    skip
      "p-CharKey_One"   p-CharKey_One   skip
      "p-CharKey_Two"   p-CharKey_Two   skip
      "p-CharKey_Three" p-CharKey_Three skip
      "p-lock-type"     p-lock-type     skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  def var v-bp_type like ub.batchprocess.bp_type no-undo .
  assign
    v-bp_type = 'lock':U + p-process-key
  .
  find first ub.batchprocess no-lock
    where ub.batchprocess.bp_type       = v-bp_type
      and ub.batchprocess.bp_status     = 'N':U
      and ub.batchprocess.key#_one      = p-Key#_One
      and ub.batchprocess.key#_two      = p-Key#_Two
      and ub.batchprocess.key#_three    = p-Key#_Three
      and ub.batchprocess.charkey_one   = p-CharKey_One
      and ub.batchprocess.charkey_two   = p-CharKey_Two
      and ub.batchprocess.charkey_three = p-CharKey_Three
    no-error .
  if not available ub.batchprocess
  then do:
    create ub.batchprocess .
    define variable v-btpr_upd-today as date      no-undo.
    define variable v-btpr_upd-time  as integer   no-undo.
    run cur-time in this-procedure
      (output v-btpr_upd-today
      ,output v-btpr_upd-time
      ).
    assign
      ub.batchprocess.batchprocess# = next-value(s-btpr, ub)
      ub.batchprocess.bp_type       = v-bp_type
      ub.batchprocess.bp_status     = 'N':U
      ub.batchprocess.user_id       = g#userid
      ub.batchprocess.bp_sysdate    = v-btpr_upd-today
      ub.batchprocess.bp_systime    = string( v-btpr_upd-time, 'hh:mm':u )
      ub.batchprocess.bp_systimeint = v-btpr_upd-time
      ub.batchprocess.key#_one      = p-Key#_One
      ub.batchprocess.key#_two      = p-Key#_Two
      ub.batchprocess.key#_three    = p-Key#_Three
      ub.batchprocess.charkey_one   = p-CharKey_One
      ub.batchprocess.charkey_two   = p-CharKey_Two
      ub.batchprocess.charkey_three = p-CharKey_Three
    .
  end.
  validate ub.batchprocess .
  run lock-record in this-procedure
    (buffer ub.batchprocess
    ,buffer lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры lock-record" skip
        view-as alert-box error .
    end.
    undo, return error return-value .
  end.
  if p-lock-type = 'exclusive-lock':u
  then do:
    define variable v-today as date      no-undo .
    define variable v-time  as integer   no-undo .
    run cur-time in this-procedure
      (output v-today
      ,output v-time
      ).
    assign
      lock_batchprocess.bp_execuser_id    = g#userid
      lock_batchprocess.bp_execsysdate    = v-today
      lock_batchprocess.bp_execsystime    = string(v-time, 'hh:mm':u)
      lock_batchprocess.bp_execsystimeint = v-time
    .
  end.
  define variable v-lock-success as logical   no-undo .
  assign
    v-lock-success = true
  .
  for each buf_batchprocess no-lock
    where buf_batchprocess.bp_type       = v-bp_type
      and buf_batchprocess.bp_status     = 'N':U
      and buf_batchprocess.Key#_One      = p-Key#_One
      and buf_batchprocess.Key#_Two      = p-Key#_Two
      and buf_batchprocess.Key#_Three    = p-Key#_Three
      and buf_batchprocess.CharKey_One   = p-CharKey_One
      and buf_batchprocess.CharKey_Two   = p-CharKey_Two
      and buf_batchprocess.CharKey_Three = p-CharKey_Three
      and recid(buf_batchprocess) <> recid(lock_batchprocess)
  on error undo, return error return-value
  :
    assign
      v-lock-success = false
    .
    define buffer buf_delete_batchprocess for ub.batchprocess .
    find first buf_delete_batchprocess exclusive-lock
      where recid(buf_delete_batchprocess) = recid(buf_batchprocess)
      no-wait
      no-error .
    if available (buf_delete_batchprocess)
    then do:
      delete buf_delete_batchprocess .
    end.
  end.
  if v-lock-success <> true
  then do:
    find current ub.batchprocess exclusive-lock
      no-wait
      no-error .
    if available ub.batchprocess
    then do:
      delete ub.batchprocess .
    end.
    undo, return error substitute("Попытка одновременного захвата ресурса &1", v-bp_type) .
  end.
  return .
end.
procedure lock-record :
  define parameter buffer other_batchprocess for ub.batchprocess .
  define parameter buffer buf_batchprocess for ub.batchprocess .
  def var v-resource-id as character no-undo .
  do
  on error undo, return error return-value
  :
    if p-lock-type = 'exclusive-lock':u
    then do:
      find first buf_batchprocess exclusive-lock
        where recid(buf_batchprocess) = recid(other_batchprocess)
        no-error .
    end.
    else do:
      find first buf_batchprocess share-lock
        where recid(buf_batchprocess) = recid(other_batchprocess)
        no-error .
    end.
    if not available buf_batchprocess
    then do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка при блокировании ресурса" skip
          "Отсутствует запись о блокировке ресурса" skip
          view-as alert-box error.
      undo, return error substitute("Другой пользователь захватил ресурс &1", v-resource-id) .
    end.
  end.
end procedure.
