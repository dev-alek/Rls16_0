block-level on error undo, throw.
TRIGGER PROCEDURE FOR DELETE OF ub.prod-bc.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление prod-bc".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
procedure prod-bch_write-prod-bc-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-action  as integer no-undo .
define input parameter p-gds-code  like ub.goods.gds-code no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_c-prod-bc for ub.c-prod-bc.
define buffer buf_c-bar-code for ub.c-bar-code.
  do
  on error undo, return error
  :
    if g#news then do:
      define variable v-send as integer no-undo .
      v-send = integer('0':U).
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'prod-bc':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  0
  ,input  0
  ,input  'nws-to-hist'
  ,output v-send
  ) no-error .
      if v-send < 0 then return.
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-prod-bc.
    buffer-copy ub.prod-bc to buf_c-prod-bc
    assign
    buf_c-prod-bc.b-code             = (if p-new-record then ub.prod-bc.b-code else ub.prod-bc.b-code)
    buf_c-prod-bc.b-str              = (if p-new-record then ub.prod-bc.b-str  else ub.prod-bc.b-str)
    buf_c-prod-bc.chip-num           = next-value (s-gds-chip, ub)
    buf_c-prod-bc.corr-time          = v-time
    buf_c-prod-bc.corr-user-db-num   = g#db-num
    buf_c-prod-bc.corr-user-name     = (if g#news
                                        then (chr(4) +  'СПН':U)
                                        else (if g#esys
                                             then (chr(4) +  'ВС':U)
                                             else g#userid)
                                       )
    buf_c-prod-bc.corr-date          = v-date
    .
    create buf_c-bar-code.
    assign
    buf_c-bar-code.b-code             = (if p-new-record then ub.prod-bc.b-code else ub.prod-bc.b-code)
    buf_c-bar-code.gds-code           = p-gds-code
    buf_c-bar-code.chip-num           = buf_c-prod-bc.chip-num
    buf_c-bar-code.corr-time          = v-time
    buf_c-bar-code.corr-user-db-num   = g#db-num
    buf_c-bar-code.corr-user-name     = (if g#news
                                        then (chr(4) +  'СПН':U)
                                        else (if g#esys
                                             then (chr(4) +  'ВС':U)
                                             else g#userid)
                                       )
    buf_c-bar-code.corr-date          = v-date
    .
    create buf_c-gds-hist.
    buffer-copy buf_c-prod-bc to buf_c-gds-hist
    assign
    buf_c-gds-hist.gds-code           = p-gds-code
    buf_c-gds-hist.action = (if p-new-record
                              then integer('1':U)
                              else p-action
                            )
    buf_c-gds-hist.subject = 'prod-bc':U
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.source-type = (if g#news
                                  then 'db':U
                                  else (if g#esys
                                        then 'esys':U
                                        else "":U)
                                  )
    buf_c-gds-hist.source-ref = (if g#news
                                  then string(g#news-source-db)
                                  else (if g#esys
                                        then string(g#esys-source-esys)
                                        else "":U)
                                  )
    .
  end.
end procedure.
procedure prod-bch_write-prod-bc-proc  :
define parameter buffer buf_prod-bc for ub.prod-bc .
define input parameter p-action  as integer no-undo .
define input parameter p-gds-code  like ub.goods.gds-code no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_c-prod-bc for ub.c-prod-bc.
define buffer buf_c-bar-code for ub.c-bar-code.
  do
  on error undo, return error
  :
    if not available buf_prod-bc then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не определен БАР-КОД" skip
        view-as alert-box error .
      undo, return error .
    end.
    if g#news then do:
      define variable v-send as integer no-undo .
      v-send = integer('0':U).
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'prod-bc':U
  ,input  'nws-to-hist'
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  0
  ,input  0
  ,output v-send
  ) no-error .
      if v-send < 0 then return.
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-prod-bc.
    buffer-copy buf_prod-bc to buf_c-prod-bc
    assign
    buf_c-prod-bc.b-code            = buf_c-prod-bc.b-code
    buf_c-prod-bc.b-str             = buf_c-prod-bc.b-str
    buf_c-prod-bc.chip-num           = next-value (s-gds-chip, ub)
    buf_c-prod-bc.corr-time          = v-time
    buf_c-prod-bc.corr-user-db-num   = g#db-num
    buf_c-prod-bc.corr-user-name     = (if g#news
                                        then (chr(4) +  'СПН':U)
                                        else (if g#esys
                                             then (chr(4) +  'ВС':U)
                                             else g#userid)
                                       )
    buf_c-prod-bc.corr-date          = v-date
    .
    create buf_c-bar-code.
    assign
    buf_c-bar-code.b-code             = buf_c-bar-code.b-code
    buf_c-bar-code.gds-code           = p-gds-code
    buf_c-bar-code.chip-num           = buf_c-prod-bc.chip-num
    buf_c-bar-code.corr-time          = v-time
    buf_c-bar-code.corr-user-db-num   = g#db-num
    buf_c-bar-code.corr-user-name     = (if g#news
                                        then (chr(4) +  'СПН':U)
                                        else (if g#esys
                                             then (chr(4) +  'ВС':U)
                                             else g#userid)
                                       )
    buf_c-bar-code.corr-date          = v-date
    .
    create buf_c-gds-hist.
    buffer-copy buf_c-prod-bc to buf_c-gds-hist
    assign
    buf_c-gds-hist.gds-code           = p-gds-code
    buf_c-gds-hist.action = integer(p-action)
    buf_c-gds-hist.subject = 'prod-bc':U
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.source-type = (if g#news
                                  then 'db':U
                                  else (if g#esys
                                        then 'esys':U
                                        else "":U)
                                  )
    buf_c-gds-hist.source-ref = (if g#news
                                  then string(g#news-source-db)
                                  else (if g#esys
                                        then string(g#esys-source-esys)
                                        else "":U)
                                  )
    .
  end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer buf_bar-code for ub.bar-code.
define buffer buf_prod-bc-db for ub.prod-bc-db.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find buf_bar-code where buf_bar-code.b-code = ub.prod-bc.b-code no-lock no-error .
  if available buf_bar-code then do:
    run prod-bch_write-prod-bc-trigger in this-procedure  (
                                         input no
                                        ,input integer('99':U)
                                        ,input buf_bar-code.gds-code
                                        ,input (if g#news
                                                then 'db':U
                                                else (if g#esys
                                                      then 'esys':U
                                                      else "":U)
                                                )
                                        ,input (if g#news
                                                then string(g#news-source-db)
                                                else (if g#esys
                                                      then string(g#esys-source-esys)
                                                      else  "":U)
                                                )
                                      ) .
  end.
  define variable l-prod-bc-global as logical no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  'global=request':u
  ,output l-prod-bc-global
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
      "Основной бар-код" ub.prod-bc.b-code skip
      "Дополнительный бар-код" ub.prod-bc.b-str skip
      "Действие global=request" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  if not g#news
  and not l-prod-bc-global then do:
  define variable l-prod-bc-weight as logical no-undo .
  define variable l-prod-bc-scaleable as logical no-undo .
  define variable l-prod-bc-pgweight as logical no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  'weight=request':u
  ,output l-prod-bc-weight
  ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
        "Основной бар-код" ub.prod-bc.b-code skip
        "Дополнительный бар-код" ub.prod-bc.b-str skip
        "Действие weight=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
    if not l-prod-bc-weight then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  'scaleable=request':u
  ,output l-prod-bc-scaleable
  ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
          "Основной бар-код" ub.prod-bc.b-code skip
          "Дополнительный бар-код" ub.prod-bc.b-str skip
          "Действие scaleable=request" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo main-block, return error .
      end.
    end.
    if not g#news
    and (l-prod-bc-weight or l-prod-bc-scaleable or ub.prod-bc.bc-on-type = 'pglc':U)
    then do:
        find first buf_prod-bc-db where
                  buf_prod-bc-db.b-str = ub.prod-bc.b-str
              AND  buf_prod-bc-db.b-code = ub.prod-bc.b-code
              AND  buf_prod-bc-db.db-num = g#db-num no-error.
        if available buf_prod-bc-db then do:
          delete buf_prod-bc-db.
        end.
      end.
    end.
  if l-prod-bc-global or prod-bc.bc-on-type eq 'GTIN':U then do:
    run nws/cmd-del.p
      ( input 'prod-bc':U
       ,input (buffer ub.prod-bc:handle)
       ,input "":U
      ) no-error .
    if error-status :error then do:
      undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'delprcode':U
  ,input  buffer ub.prod-bc:handle
  ,input ?
  ,input ''
  ,input ''
  ) no-error .
  if error-status:error
  then do:
    if not g#news then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры rum-runa.i" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    undo main-block,  return error return-value .
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input 'delete':U
        , input 'prod-bc':U
        , input ( buffer ub.prod-bc:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , chr(10)
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.
for each prod-bc-attr where prod-bc-attr.b-code eq prod-bc.b-code
                        and prod-bc-attr.b-str  eq prod-bc.b-str
   exclusive-lock:
       delete prod-bc-attr.
end.
