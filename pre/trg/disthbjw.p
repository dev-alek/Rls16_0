block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.dis-thbj-rule old old_dis-thbj-rule.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись скидок по объектам".
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
      p-vss-parameters = substitute('&1|&2|&3|&4|&5|&6'
                        ,  ub.dis-thbj-rule.host-code
                        ,  ub.dis-thbj-rule.obj-type
                        ,  ub.dis-thbj-rule.obj-code
                        ,  ub.dis-thbj-rule.pos-type
                        ,  ub.dis-thbj-rule.discnt-role
                        ,  ub.dis-thbj-rule.nonunique
                        )
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
define new global shared variable g#lib-nws as handle no-undo .
define variable v-host-code as integer no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-obj-db-num as integer no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define buffer buf_c-dis-thbj-rule for ub.c-dis-thbj-rule.
define buffer buf_c-cli-hist for ub.c-cli-hist.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news
  and g#db-num > 0
  and (
      ub.dis-thbj-rule.obj-type  = '':U
      or
      ub.dis-thbj-rule.obj-code = 0
      or
      ub.dis-thbj-rule.host-code  = 0
      ) then do:
    message
    vss-workfile vss-revision vss-description skip
    substitute("&1&2 POS &3 тип скидки &4&5" +
               "Нельзя изменять запись СКИДОК ПО ОБЪЕКТАМ/ФИРМАМ в УБД"
               ,ub.dis-thbj-rule.obj-type
               ,ub.dis-thbj-rule.obj-code
               ,ub.dis-thbj-rule.pos-type
               ,ub.dis-thbj-rule.discnt-role)
    view-as alert-box error .
    undo main-block, return error .
  end.
  if not g#news
  and (ub.dis-thbj-rule.obj-type = 'маг':U
  or ub.dis-thbj-rule.obj-type = 'скл':U) then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  ub.dis-thbj-rule.obj-type
  ,input  ub.dis-thbj-rule.obj-code
  ,output v-obj-db-num
  )  .
    if v-obj-db-num <> g#db-num
    and g#db-num <> 0 then do:
      message
      vss-workfile vss-revision vss-description skip
      substitute("&1&2 POS &3 тип скидки &4&5" +
                "Нельзя изменять запись СКИДОК ПО ОБЪЕКТАМ/ФИРМАМ в чужой БД"
               ,ub.dis-thbj-rule.obj-type
               ,ub.dis-thbj-rule.obj-code
               ,ub.dis-thbj-rule.pos-type
               ,ub.dis-thbj-rule.discnt-role)
      view-as alert-box error .
      undo main-block, return error .
    end.
  end.
  run str/callnews.p
    ( input 'dis-thbj-rule':U
      ,input (buffer ub.dis-thbj-rule:handle)
    ) .
  if g#news then do:
    define variable v-send as integer no-undo .
    v-send = integer('0':U).
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'dis-thbj-rule':U
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
  end.
  if not g#news
  or v-send >= 0 then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-dis-thbj-rule.
    buffer-copy old_dis-thbj-rule
    except
    pos-type
    templ-rl-root
    host-code
    obj-type
    obj-code
    nonunique
    to buf_c-dis-thbj-rule
    assign
    buf_c-dis-thbj-rule.pos-type           = ub.dis-thbj-rule.pos-type
    buf_c-dis-thbj-rule.discnt-role        = ub.dis-thbj-rule.discnt-role
    buf_c-dis-thbj-rule.obj-type           = ub.dis-thbj-rule.obj-type
    buf_c-dis-thbj-rule.obj-code           = ub.dis-thbj-rule.obj-code
    buf_c-dis-thbj-rule.host-code          = ub.dis-thbj-rule.host-code
    buf_c-dis-thbj-rule.nonunique          = ub.dis-thbj-rule.nonunique
    buf_c-dis-thbj-rule.chip-num           = next-value (s-cli-chip, ub)
    buf_c-dis-thbj-rule.corr-time          = v-time
    buf_c-dis-thbj-rule.corr-user-db-num   = g#db-num
    buf_c-dis-thbj-rule.corr-user-name     = (if g#news
                                              then (chr(4) +  'СПН':U)
                                              else (if g#esys
                                                    then (chr(4) +  'ВС':U)
                                                    else g#userid
                                                    )
                                              )
    buf_c-dis-thbj-rule.corr-date          = v-date
    .
    if not (ub.dis-thbj-rule.obj-type = '':U
           and
           ub.dis-thbj-rule.obj-code = 0
           and
           ub.dis-thbj-rule.host-code = 0) then do:
      if ub.dis-thbj-rule.obj-type = 'маг':U
      or ub.dis-thbj-rule.obj-type = 'скл':U then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  ub.dis-thbj-rule.obj-type
  ,input  ub.dis-thbj-rule.obj-code
  ,output v-host-code
  )  .
        assign
        v-obj-type = ub.dis-thbj-rule.obj-type
        v-obj-code = ub.dis-thbj-rule.obj-code
        .
      end.
      if ub.dis-thbj-rule.obj-type = 'орг':U then do:
        assign
        v-obj-type = 'орг':U
        v-obj-code = ub.dis-thbj-rule.host-code
        v-host-code = ub.dis-thbj-rule.obj-code.
      end.
      create buf_c-cli-hist.
      buffer-copy buf_c-dis-thbj-rule
      except obj-type obj-code
      to buf_c-cli-hist
      assign
      buf_c-cli-hist.action = (if new (ub.dis-thbj-rule )
                              then integer('1':U)
                              else integer('2':U))
      buf_c-cli-hist.subject = 'dis-thbj-rule':U
      buf_c-cli-hist.obj-type = v-obj-type
      buf_c-cli-hist.obj-code = v-obj-code
      buf_c-cli-hist.host-code = v-host-code
      buf_c-cli-hist.is-news = g#news
      buf_c-cli-hist.source-type = (if g#news
                                    then 'db':U
                                    else (if g#esys
                                          then 'esys':U
                                          else "":U)
                                    )
      buf_c-cli-hist.source-ref = (if g#news
                                  then string(g#news-source-db)
                                  else (if g#esys
                                        then string(g#esys-source-esys)
                                        else "":U)
                                  )
      .
    end.
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input 'update':U
        , input 'dis-thbj-rule':U
        , input ( buffer ub.dis-thbj-rule:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , chr(10)
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
  end.
end.
