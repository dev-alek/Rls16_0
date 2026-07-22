block-level on error undo, throw.
define input parameter  p-process-key    as character no-undo .
define input parameter  p-Key#_One       like ub.batchprocess.Key#_One      no-undo .
define input parameter  p-Key#_Two       like ub.batchprocess.Key#_Two      no-undo .
define input parameter  p-Key#_Three     like ub.batchprocess.Key#_Three    no-undo .
define input parameter  p-CharKey_One    like ub.batchprocess.CharKey_One   no-undo .
define input parameter  p-CharKey_Two    like ub.batchprocess.CharKey_Two   no-undo .
define input parameter  p-CharKey_Three  like ub.batchprocess.CharKey_Three no-undo .
define input parameter  p-key-descr-list as character no-undo .
define input parameter  p-message-on     as logical no-undo .
define parameter buffer lock_batchprocess for ub.batchprocess .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: lock-prc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/lock-prc.p $":U .
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
      p-vss-parameters = substitute('&1|&2|&3|&4|&5|&6|&7|&8|&9':u,p-process-key,p-Key#_One,p-Key#_Two,p-Key#_Three,p-CharKey_One,p-CharKey_Two,p-CharKey_Three,p-key-descr-list,p-message-on)
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
  define variable v-today as date      no-undo .
  define variable v-time  as integer   no-undo .
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
      "p-message-on"    p-message-on    skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if g#auto = true then do:
    assign
      p-message-on = false
    .
  end.
  def var v-bp_type like ub.batchprocess.bp_type no-undo .
  assign
    v-bp_type = 'lock':U + p-process-key
  .
  find first ub.batchprocess no-lock
    where ub.batchprocess.bp_type   = v-bp_type
      and ub.batchprocess.bp_status = 'N':U
      and  ub.batchprocess.key#_one  = p-Key#_One
      and ub.batchprocess.key#_two = p-Key#_Two
      and ub.batchprocess.key#_three = p-Key#_Three
      and ub.batchprocess.charkey_one = p-CharKey_One
      and ub.batchprocess.charkey_two = p-CharKey_Two
      and ub.batchprocess.charkey_three = p-CharKey_Three
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
      ub.BatchProcess.Key#_One      = p-Key#_One
      ub.BatchProcess.Key#_Two      = p-Key#_Two
      ub.BatchProcess.Key#_Three    = p-Key#_Three
      ub.BatchProcess.CharKey_One   = p-CharKey_One
      ub.BatchProcess.CharKey_Two   = p-CharKey_Two
      ub.BatchProcess.CharKey_Three = p-CharKey_Three
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
  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).
  assign
    lock_batchprocess.bp_execuser_id    = g#userid
    lock_batchprocess.bp_execsysdate    = v-today
    lock_batchprocess.bp_execsystime    = string(v-time, 'hh:mm')
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
    run lock-record in this-procedure
      (buffer buf_batchprocess
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
      delete ub.batchprocess .
      undo, return error return-value .
    end.
  end.
  find current lock_batchprocess share-lock .
  return .
end.
procedure lock-record :
  define parameter buffer other_batchprocess for ub.batchprocess .
  define parameter buffer buf_batchprocess for ub.batchprocess .
  def var v-resource-id as character no-undo .
  do
  on error undo, return error return-value
  :
    find buf_batchprocess exclusive-lock
      where recid(buf_batchprocess) = recid(other_batchprocess)
      no-wait
      no-error .
    if not available buf_batchprocess
    then do:
      if locked buf_batchprocess
      then do:
        define variable v-message as character no-undo .
        assign
          p-key-descr-list = p-key-descr-list + ",,,,,,":u
        .
        assign
          v-resource-id = "Код ресурса " + string(p-process-key) + chr(10)
                        + (if entry(7, p-key-descr-list) > ""
                          then entry(7, p-key-descr-list) + chr(10)
                          else ""
                          )
                        + (if p-Key#_One <> 0
                          then entry(1, p-key-descr-list) + " "
                              + string(p-Key#_One) + chr(10)
                          else ""
                          )
                        + (if p-Key#_Two <> 0
                          then entry(2, p-key-descr-list) + " "
                              + string(p-Key#_Two) + chr(10)
                          else ""
                          )
                        + (if p-Key#_Three <> 0
                          then entry(3, p-key-descr-list) + " "
                              + string(p-Key#_Three) + chr(10)
                          else ""
                          )
                        + (if p-CharKey_One <> ""
                          then entry(4, p-key-descr-list) + " "
                              + string(p-CharKey_One) + chr(10)
                          else ""
                          )
                        + (if p-CharKey_Two <> ""
                          then entry(5, p-key-descr-list) + " "
                              + string(p-CharKey_Two) + chr(10)
                          else ""
                          )
                        + (if p-CharKey_Three <> ""
                          then entry(6, p-key-descr-list) + " "
                              + string(p-CharKey_Three) + chr(10)
                          else ""
                          )
        .
        assign
          v-message = "Другой пользователь уже захватил ресурс" + chr(10)
                    + substitute("Пользователь &1", other_batchprocess.bp_execuser_id) + chr(10)
                    + substitute("Дата начала работы &1", other_batchprocess.bp_execsysdate) + chr(10)
                    + substitute("Время начала работы &1", other_batchprocess.bp_execsystime) + chr(10)
                    + substitute('&1':u, v-resource-id)
        .
        if p-message-on
        then do:
          message
            v-message
            view-as alert-box error .
        end.
      end.
      else do:
        assign
          v-message = substitute('&1 &2 &3':u, vss-workfile, vss-revision, vss-description) + chr(10)
                    + "Внутренняя ошибка при блокировании ресурса" + chr(10)
                    + "Отсутствует запись о блокировке ресурса" + chr(10)
        .
        if p-message-on
        then do:
          message
            v-message
            view-as alert-box error.
        end.
      end.
      undo, return error v-message .
    end.
  end.
end procedure.
