block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.dis-dc-rule OLD olddis-dc-rule.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись в таблице dis-dc-rule".
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
      p-vss-parameters = substitute('&1|&2|&3|&4|&5|&6|&7|&8'
                         , ub.dis-dc-rule.d-card
                        , ub.dis-dc-rule.host-code
                        , ub.dis-dc-rule.obj-type
                        , ub.dis-dc-rule.obj-code
                        , ub.dis-dc-rule.pos-type
                        , ub.dis-dc-rule.discnt-role
                        , ub.dis-dc-rule.nonunique
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
procedure disdcruh_write-dis-dc-rule-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-source-type like ub.c-dc-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-dc-hist.source-ref no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-dc-rule for ub.c-dis-dc-rule.
  do
  on error undo, return error
  :
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-dis-dc-rule.
    buffer-copy olddis-dc-rule to buf_c-dis-dc-rule
    assign
    buf_c-dis-dc-rule.d-card             = ub.dis-dc-rule.d-card
    buf_c-dis-dc-rule.card-num           = ub.dis-dc-rule.card-num
    buf_c-dis-dc-rule.obj-type           = ub.dis-dc-rule.obj-type
    buf_c-dis-dc-rule.obj-code           = ub.dis-dc-rule.obj-code
    buf_c-dis-dc-rule.host-code          = ub.dis-dc-rule.host-code
    buf_c-dis-dc-rule.pos-type           = ub.dis-dc-rule.pos-type
    buf_c-dis-dc-rule.discnt-role        = ub.dis-dc-rule.discnt-role
    buf_c-dis-dc-rule.nonunique          = ub.dis-dc-rule.nonunique
    buf_c-dis-dc-rule.chip-num           = next-value (s-dc-chip, ub)
    buf_c-dis-dc-rule.corr-time          = v-time
    buf_c-dis-dc-rule.corr-user-db-num   = g#db-num
    buf_c-dis-dc-rule.corr-user-name     = (if g#news
                                            then (chr(4) +  'СПН':U)
                                            else (if g#esys
                                                 then (chr(4) +  'ВС':U)
                                                 else g#userid
                                                 )
                                            )
    buf_c-dis-dc-rule.corr-date          = v-date
    .
    create buf_c-dc-hist.
    buffer-copy buf_c-dis-dc-rule to buf_c-dc-hist
    assign
    buf_c-dc-hist.action = (if p-new-record then integer('1':U) else integer('2':U))
    buf_c-dc-hist.subject = 'dis-dc-rule':U
    buf_c-dc-hist.is-news  = g#news
    buf_c-dc-hist.source-type = p-source-type
    buf_c-dc-hist.source-ref =  p-source-ref
    .
  end.
end procedure.
procedure disdcruh_write-dis-dc-rule-proc :
define input parameter p-d-card      like ub.c-dis-dc-rule.d-card no-undo .
define input parameter p-card-num    like ub.c-dis-dc-rule.card-num no-undo .
define input parameter p-host-code   like ub.c-dis-dc-rule.host-code no-undo .
define input parameter p-obj-type    like ub.c-dis-dc-rule.obj-type  no-undo .
define input parameter p-obj-code    like ub.c-dis-dc-rule.obj-code  no-undo .
define input parameter p-pos-type    like ub.c-dis-dc-rule.pos-type  no-undo .
define input parameter p-discnt-role  like ub.c-dis-dc-rule.discnt-role no-undo .
define input parameter p-nonunique   like ub.c-dis-dc-rule.nonunique no-undo .
define input parameter p-action      as integer no-undo .
define input parameter p-source-type like ub.c-dc-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-dc-hist.source-ref no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-dc-rule for ub.c-dis-dc-rule.
  do
  on error undo, return error
  :
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-dis-dc-rule.
    assign
    buf_c-dis-dc-rule.d-card             = p-d-card
    buf_c-dis-dc-rule.card-num           = p-card-num
    buf_c-dis-dc-rule.obj-type           = p-obj-type
    buf_c-dis-dc-rule.obj-code           = p-obj-code
    buf_c-dis-dc-rule.host-code          = p-host-code
    buf_c-dis-dc-rule.pos-type           = p-pos-type
    buf_c-dis-dc-rule.discnt-role        = p-discnt-role
    buf_c-dis-dc-rule.nonunique          = p-nonunique
    buf_c-dis-dc-rule.chip-num           = next-value (s-dc-chip, ub)
    buf_c-dis-dc-rule.corr-time          = v-time
    buf_c-dis-dc-rule.corr-user-db-num   = g#db-num
    buf_c-dis-dc-rule.corr-user-name     = (if g#news
                                            then (chr(4) +  'СПН':U)
                                            else (if g#esys
                                                 then (chr(4) +  'ВС':U)
                                                 else g#userid
                                                 )
                                            )
    buf_c-dis-dc-rule.corr-date          = v-date
    .
    create buf_c-dc-hist.
    buffer-copy buf_c-dis-dc-rule to buf_c-dc-hist
    assign
    buf_c-dc-hist.action = p-action
    buf_c-dc-hist.subject = 'dis-dc-rule':U
    buf_c-dc-hist.is-news  = g#news
    buf_c-dc-hist.source-type = p-source-type
    buf_c-dc-hist.source-ref =  p-source-ref
    .
  end.
end procedure.
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-manual-editing as integer no-undo .
define buffer buf_c-dis-dc-rule for ub.c-dis-dc-rule.
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer locked_dis-dc-rule for ub.dis-dc-rule.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not ub.dis-dc-rule.templ-rl-root = 0 then do:
    Find first locked_dis-dc-rule exclusive-lock  where
            locked_dis-dc-rule.d-card    = ub.dis-dc-rule.d-card
        AND locked_dis-dc-rule.obj-type  = '':U
        AND locked_dis-dc-rule.obj-code  = 0
        AND locked_dis-dc-rule.host-code = 0
        and locked_dis-dc-rule.pos-type = '':U
        and locked_dis-dc-rule.discnt-role = '':U
        and locked_dis-dc-rule.nonunique = '':U
        no-error no-wait.
    if locked locked_dis-dc-rule then
    undo main-block, return error substitute("СКИДКА по ДК карта &1 место использ. &2 тип скидки &3 занята"
                                              , ub.dis-dc-rule.d-card
                                              , ub.dis-dc-rule.pos-type
                                              , entry (lookup (ub.dis-dc-rule.discnt-role, 'debet-pay-pcnt-disc,debet-pay-abs-disc,debet-pay-qnty-disc,debet-pay-sum-disc,debet-pay-free-disc,dc-d-pcnt,dc-cash-d-pcnt,credit-pay-pcnt-disc,credit-pay-abs-disc,credit-pay-qnty-disc,credit-pay-sum-disc,credit-pay-free-disc':u) + 1, ',' + '% Скидка при оплате топлива по дебет.ведомости,ABS Скидка при оплате топлива по дебет.ведомости,Скидка на кол-во при оплате топлива по дебет.ведомости,Скидка на сумму при оплате топлива по дебет.ведомости,Своб скидка при оплате топлива по дебет.ведомости,% скидка на товар по ДК,% скидка на итог чека по ДК,% Скидка при оплате топлива по кредит.ведомости,Abs Скидка при оплате топлива по кредит.ведомости,Скидка на кол-во при оплате топлива по кредит.ведомости,Скидка на сумму при оплате топлива по кредит.ведомости,Своб Скидка на сумму при оплате топлива по кредит.ведомости':u)
                                              ).
  end.
  if ub.dis-dc-rule.obj-type  = '':U
        AND ub.dis-dc-rule.obj-code  = 0
        AND ub.dis-dc-rule.host-code = 0
        and ub.dis-dc-rule.pos-type = '':U
        and ub.dis-dc-rule.discnt-role = '':U
        and ub.dis-dc-rule.nonunique = '':U then do:
 end.
 else do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable send-ref as logical no-undo.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'send-ref'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
  send-ref = (IF error-status:error or conf-par <> "yes" then no else yes).
    if send-ref and not g#news then do:
      run trg/nu_dcard.p (
                    input  ub.dis-dc-rule.d-card
                    ,input  ub.dis-dc-rule.host-code
                    ,input  "":U
                    ,input  0
                    ,input  "U":U
                  ).
    end.
      run disdcruh_write-dis-dc-rule-trigger in this-procedure  (
                                          input new(ub.dis-dc-rule)
                                        ,input (if g#news
                                                then 'db':U
                                                else (if g#esys
                                                      then 'esys':U
                                                      else "":U)
                                                )
                                        ,input  (if g#news
                                                  then string(g#news-source-db)
                                                  else (if g#esys
                                                        then string(g#esys-source-esys)
                                                        else "":U)
                                                  )
                                        ) .
    run str/callnews.p
      ( input 'dis-dc-rule':U
      ,input (buffer ub.dis-dc-rule:handle )
      ) no-error .
    if error-status:error then undo main-block, return error return-value .
    if g#oxml = yes
    then do:
      run str/calloxml.p (
            input 'update':U
          , input 'dis-dc-rule':U
          , input ( buffer ub.dis-dc-rule:handle )
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
end.
