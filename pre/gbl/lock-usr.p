block-level on error undo, throw.
define input  parameter p-user-id         as character no-undo .
define input  parameter p-resource-key    as character no-undo .
define input  parameter p-message-on      as logical   no-undo .
define input  parameter p-message-txt     as character no-undo .
define input  parameter p-max-user-lock   as integer   no-undo .
define parameter buffer lock_batchprocess for ub.batchprocess .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: lock-usr.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/lock-usr.p $":U .
def var vss-description as character no-undo init "Программа блокировки ресурсов".
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
      p-vss-parameters = substitute('':u,p-user-id,p-resource-key,p-message-on,p-max-user-lock)
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
def buffer buf_batchprocess for ub.batchprocess .
def buffer delete_batchprocess for ub.batchprocess .
define buffer trylock_batchprocess for ub.batchprocess .
define variable g#userid as character no-undo .
assign
  g#userid = p-user-id
.
do
on error undo, return error
:
  if p-resource-key = ?
  or p-resource-key = ""
  or length(p-resource-key) > 4
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания параметров" skip
      "Код ресурса должен быть задан"
      "и не может превышать 4 символа" skip
      "Код ресурса" p-resource-key skip
      view-as alert-box error .
    undo, return error .
  end.
  def var v-bp_type like ub.batchprocess.bp_type no-undo .
  assign
    v-bp_type = 'lusr':u + p-resource-key
  .
  define variable v-count-lock as integer   no-undo .
  assign
    v-count-lock = 0
  .
  define variable v-Key#_One as integer   no-undo .
  define variable v-prev-Key#_One as integer   no-undo .
  assign
    v-Key#_One = 0
    v-prev-Key#_One = 1
  .
  for each buf_batchprocess no-lock
    where buf_batchprocess.bp_type = v-bp_type
      and buf_batchprocess.bp_status = 'N':U
  by buf_batchprocess.Key#_One
  on error undo, return error return-value
  :
    do transaction
    on error undo, return error return-value
    :
      find first trylock_batchprocess exclusive-lock
        where recid(trylock_batchprocess) = recid(buf_batchprocess)
        no-error
        no-wait
        .
      if available trylock_batchprocess then do:
        delete trylock_batchprocess .
        next .
      end.
      else do:
        assign
          v-count-lock = v-count-lock + 1
        .
      end.
      if buf_batchprocess.Key#_one > v-prev-Key#_One + 1
      then do:
        assign
          v-Key#_One = v-prev-Key#_One + 1
        .
      end.
      assign
        v-prev-Key#_One = buf_batchprocess.Key#_one
      .
      if p-max-user-lock < v-count-lock + 1 then do:
        if p-message-on
        then do:
          message
            substitute(p-message-txt, p-max-user-lock) skip
            view-as alert-box error .
        end.
        undo, return error .
      end.
    end.
  end.
  if v-key#_one = 0
  then do:
    assign
      v-Key#_One = v-prev-Key#_One + 1
    .
  end.
  do transaction
  on error undo, return error return-value
  :
  find first ub.batchprocess no-lock
    where ub.batchprocess.bp_type   = v-bp_type
      and ub.batchprocess.bp_status = 'N':U
      and  ub.batchprocess.key#_one  = v-Key#_One
  no-error .
  if not available ub.BatchProcess then do:
    create ub.BatchProcess .
        define variable v-btpr_upd-today-1 as date      no-undo.
    define variable v-btpr_upd-time-1  as integer   no-undo.
    run cur-time in this-procedure ( output v-btpr_upd-today-1
                                   , output v-btpr_upd-time-1
                                   ).
    assign
      ub.BatchProcess.BP_Type       = v-bp_type
      ub.BatchProcess.BP_Status     = 'N':U
      ub.BatchProcess.BatchProcess# = next-value( s-btpr, ub )
      ub.BatchProcess.User_ID       = g#userid
      ub.BatchProcess.BP_SysDate    = v-btpr_upd-today-1
      ub.BatchProcess.BP_SysTime    = string( v-btpr_upd-time-1, 'HH:MM' )
      ub.BatchProcess.BP_SysTimeInt = v-btpr_upd-time-1
    .
    assign
      ub.BatchProcess.Key#_One      = v-Key#_One
    .
  end.
    validate ub.batchprocess .
  end.
  run lock-record in this-procedure
    (buffer ub.batchprocess
    ,buffer lock_batchprocess
    ) no-error .
  if error-status :error then do:
    if error-status :get-message(1) <> "" then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры lock-record" skip
        view-as alert-box error .
    end.
    undo, return error .
  end.
end.
procedure lock-record :
  define parameter buffer other_batchprocess for ub.batchprocess .
  define parameter buffer buf_batchprocess for ub.batchprocess .
  def var v-resource-id as character no-undo .
  do
  on error undo, return error
  :
    find buf_batchprocess exclusive-lock
      where recid(buf_batchprocess) = recid(other_batchprocess)
      no-wait
      no-error .
    if not available buf_batchprocess then do:
      if locked buf_batchprocess then do:
        if p-message-on then do:
          message
            "Другой пользователь уже захватил ресурс" skip
            "Пользователь" other_batchprocess.bp_execuser_id skip
            "Дата начала работы " other_batchprocess.bp_execsysdate skip
            "Время начала работы " other_batchprocess.bp_execsystime skip
            v-resource-id skip
            view-as alert-box error .
        end.
      end.
      else do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка при блокировании ресурса" skip
          "Отсутствует запись о блокировке ресурса" skip
          view-as alert-box error.
      end.
      undo, return error.
    end.
    assign
      lock_batchprocess.bp_execuser_id    = g#userid
      lock_batchprocess.bp_execsysdate    = today
      lock_batchprocess.bp_execsystime    = string(time, 'hh:mm')
    .
  end.
end procedure.
