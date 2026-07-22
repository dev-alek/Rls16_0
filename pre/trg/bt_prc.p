block-level on error undo, throw.
define input  parameter p-obj-type          as character no-undo .
define input  parameter p-obj-code          as integer   no-undo .
define input  parameter p-check-act         as logical   no-undo .
define input  parameter p-check-act-db-num  as integer   no-undo .
define input  parameter p-check-act-user-id as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Перерасчет переоценок, которые изменились в связи с закрытием или удалением документов".
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
      p-vss-parameters = substitute('&1|&2|&3':u,p-obj-type,p-obj-code,p-check-act)
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
procedure get-ro_get-read-only :
  define output parameter p-ro-set as logical   no-undo .
  do
  on error  undo, return error substitute( "&1(get-ro_get-read-only). &2&3&4", vss-include-info1, return-value, error-status :get-message( 1 ) )
  on stop   undo, return error substitute( "&1(get-ro_get-read-only). stop", vss-include-info1 )
  on endkey undo, return error substitute( "&1(get-ro_get-read-only). endkey", vss-include-info1 )
  :
    if lookup( 'READ-ONLY':U, DBRESTRICTIONS('ub':U) ) > 0
    then do:
      assign
        p-ro-set = true
      .
    end.
    else do:
      assign
        p-ro-set = false
      .
    end.
  end.
end procedure.
define buffer buf_batchprocess for ub.batchprocess .
define buffer exec_batchprocess for ub.batchprocess .
define buffer buf_price-doc for ub.price-doc .
define variable v-was-processing as logical   no-undo .
define variable v-get-ro_read-only      as logical   no-undo .
do
on error undo, return error return-value
:
  define buffer calc-prc-lock_batchprocess for ub.batchprocess .
  run get-ro_get-read-only in this-procedure
    (output v-get-ro_read-only
    ) .
  if v-get-ro_read-only = false
  then do:
    run gbl/lock-prc.p
      (input  'ahpr':U
      ,input  p-obj-code
      ,input  0
      ,input  0
      ,input  p-obj-type
      ,input  ""
      ,input  ""
      ,input  "Объект,,, ,,,Перерасчет переоценок"
      ,input  false
      ,buffer calc-prc-lock_batchprocess
      ) no-error .
    if error-status :error then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "В данный момент рассчитываются переоценки" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error "В данный момент рассчитываются переоценки" .
    end.
  end.
  for each buf_BatchProcess no-lock
    where buf_BatchProcess.bp_type       = 'prc':U
      and buf_BatchProcess.bp_status     = 'N':U
      and buf_BatchProcess.CharKey_Three = p-obj-type
      and buf_BatchProcess.Key#_One      = p-obj-code
  on error undo, return error
  :
    if p-check-act = true
    then do:
      define variable v-ok as logical   no-undo .
      define variable v-chk-act-host-code as integer   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  p-check-act-db-num
    ,input  p-check-act-user-id
    ,input  0
    ,input  'actn_archive-prc_update':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-ok
    )  .
end.
      if v-ok <> true
      then do:
        undo, return error substitute("Отсутствуют права на перерасчёт переоценок. &1"
                                     ,return-value
                                     ) .
      end.
    end.
    if v-get-ro_read-only = false
    then do:
      find first buf_price-doc no-lock
        where buf_price-doc.doc-num = buf_batchprocess.charkey_one
        no-error .
      if not available buf_price-doc then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден документ переоценки" skip
          "Переоценка" buf_batchprocess.charkey_one skip
          view-as alert-box error .
        undo, return error .
      end.
      assign
        v-was-processing = true
      .
      do transaction
      on error undo, return error return-value
      :
  find first exec_batchprocess exclusive-lock
    where rowid(exec_batchprocess) = rowid(buf_batchprocess)
    no-error .
  if not available exec_batchprocess then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись пересчета архива" skip
      view-as alert-box error .
    undo, return error .
  end.
  if exec_batchprocess.bp_status <> 'N':U then do:
    message
      vss-workfile vss-revision vss-description skip
      "Запись пересчета архива имеет статус, отличный от" 'N':U skip
      "BP_Type"       exec_batchprocess.BP_Type       skip
      "BP_Status"     exec_batchprocess.BP_Status     skip
      "Key#_One"      exec_batchprocess.Key#_One      skip
      "Key#_Two"      exec_batchprocess.Key#_Two      skip
      "Key#_Three"    exec_batchprocess.Key#_Three    skip
      "CharKey_One"   exec_batchprocess.CharKey_One   skip
      "CharKey_Two"   exec_batchprocess.CharKey_Two   skip
      "CharKey_Three" exec_batchprocess.CharKey_Three skip
      view-as alert-box error .
    undo, return error .
  end.
    define variable v-btpr_upd-today-4 as date      no-undo.
  define variable v-btpr_upd-time-4  as integer   no-undo.
  run cur-time in this-procedure ( output v-btpr_upd-today-4
                                 , output v-btpr_upd-time-4
                                 ).
  assign
    exec_batchprocess.bp_status         = 'D':U
    exec_batchprocess.bp_execcounttries = exec_batchprocess.bp_execcounttries + 1
    exec_batchprocess.bp_execuser_id    = g#userid
    exec_batchprocess.bp_execsysdate    = v-btpr_upd-today-4
    exec_batchprocess.bp_execsystime    = string(v-btpr_upd-time-4, 'hh:mm')
    exec_batchprocess.bp_execsystimeint = v-btpr_upd-time-4
  .
        run str/pr-oldd.p
          (input buf_price-doc.doc-num
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при перерасчете переоценки" skip
            "Переоценка" buf_price-doc.doc-num skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
    else do:
      undo, return error substitute("Перерасчет переоценок. Объект &1 &2. Имеются нерассчитанные переоценки. Переценки невозможно рассчитать при подключении только_для_чтения"
                                   ,p-obj-type
                                   ,p-obj-code
                                   ) .
    end.
  end.
end.
if v-was-processing then do:
  return "true":u .
end.
else do:
  return "":u .
end.
