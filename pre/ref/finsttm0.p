block-level on error undo, throw.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define input parameter p-silent                       as logical no-undo .
define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-mode                         as character no-undo .
define input parameter p-author                       as character no-undo .
define input parameter p-host-code           like ub.fin-statement.host-code            no-undo . define input parameter p-sttm-code           like ub.fin-statement.sttm-code            no-undo . define input parameter p-curr-code           like ub.fin-statement.curr-code            no-undo . define input parameter p-doc-date            like ub.fin-statement.doc-date             no-undo . define input parameter p-bank-date           like ub.fin-statement.doc-date             no-undo . define input parameter p-fact-date           like ub.fin-statement.fact-date            no-undo . define input parameter p-fins-doc-type       like ub.fin-statement.fins-doc-type        no-undo . define input parameter p-fins-ext-doc-type   like ub.fin-statement.fins-ext-doc-type    no-undo . define input parameter p-code-bank           like ub.fin-statement.code-bank            no-undo . define input parameter p-bank-name           like ub.fin-statement.bank-name            no-undo . define input parameter p-bank-city           like ub.fin-statement.bank-city            no-undo . define input parameter p-bik                 like ub.fin-statement.bik                  no-undo . define input parameter p-code-schet          like ub.fin-statement.code-schet           no-undo . define input parameter p-r-schet             like ub.fin-statement.r-schet              no-undo . define input parameter p-c-schet             like ub.fin-statement.c-schet              no-undo . define input parameter p-cli-name            like ub.fin-statement.cli-name             no-undo . define input parameter p-prn-doc-code        like ub.fin-statement.prn-doc-code         no-undo . define input parameter p-PS                  like ub.fin-statement.PS                   no-undo . define input parameter p-sum-doc             like ub.fin-statement.sum-doc              no-undo . define input parameter p-start-sum-doc-th    like ub.fin-statement.start-sum-doc-th     no-undo . define input parameter p-start-sum-doc       like ub.fin-statement.start-sum-doc        no-undo . define input parameter p-in-sum-doc          like ub.fin-statement.in-sum-doc           no-undo . define input parameter p-out-sum-doc         like ub.fin-statement.out-sum-doc          no-undo . define input parameter p-end-sum-doc         like ub.fin-statement.end-sum-doc          no-undo . define input parameter p-num-docs            like ub.fin-statement.num-docs             no-undo . define input parameter p-start-date          like ub.fin-statement.start-date           no-undo . define input parameter p-end-date            like ub.fin-statement.end-date             no-undo .
define input parameter p-status_ as character no-undo .
define input parameter p-lines-exist as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: finsttm0.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/finsttm0.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в банковских выписках".
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
define variable v-db-num like ub.db.db-num no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-correct as logical no-undo .
define variable v-err-mess as character no-undo .
define variable v-acc as decimal no-undo .
define variable v-year-start-date as date no-undo .
define variable v-year-end-date as date no-undo .
define variable v-in-sum-doc  like ub.fin-statement.in-sum-doc no-undo .
define variable v-in-sum-base like ub.fin-statement.in-sum-base no-undo .
define variable v-in-sum-rubl like ub.fin-statement.in-sum-rubl no-undo .
define variable v-out-sum-doc like ub.fin-statement.out-sum-doc no-undo .
define variable v-out-sum-base like ub.fin-statement.out-sum-base no-undo .
define variable v-out-sum-rubl like ub.fin-statement.out-sum-rubl no-undo .
define variable v-start-sum-doc like ub.fin-statement.start-sum-doc no-undo .
define variable v-start-sum-base like ub.fin-statement.start-sum-base no-undo .
define variable v-start-sum-rubl like ub.fin-statement.start-sum-rubl no-undo .
define variable v-end-sum-doc  like ub.fin-statement.end-sum-doc no-undo .
define variable v-end-sum-base like ub.fin-statement.end-sum-base no-undo .
define variable v-end-sum-rubl like ub.fin-statement.end-sum-rubl no-undo .
define variable v-sum-doc like ub.fin-statement.sum-doc no-undo .
define variable v-sum-base like ub.fin-statement.sum-base no-undo .
define variable v-sum-rubl like ub.fin-statement.sum-rubl no-undo .
define variable v-exch-rate like ub.curr-accnt.exch-rate no-undo .
define variable v-exch-scale like ub.curr-accnt.exch-scale no-undo .
define variable v-base-rate like ub.curr-accnt.exch-rate no-undo .
define variable v-base-scale like ub.curr-accnt.exch-scale no-undo .
define variable v-curr-abbr like ub.currency.curr-abbr no-undo .
define variable v-mes  as character no-undo .
define variable v-type as character no-undo .
define variable v-ret-mess as character no-undo .
define buffer buf_sysconf  for ub.sysconf.
define buffer buf_fin-statement for ub.fin-statement.
define buffer buf_clients for ub.clients.
define buffer buf_currency for ub.currency.
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_fin-statement-line for ub.fin-statement-line.
define buffer buf_c-fin-statement for ub.c-fin-statement.
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-fin-statement no-undo like ub.fin-statement.
procedure fin-statementh_write-fin-statement-history :
define parameter buffer buf_fin-statement for tt-fin-statement.
define input parameter p-host-code like ub.fin-statement.host-code no-undo .
define input parameter p-sttm-code  like ub.fin-statement.sttm-code no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-message as character no-undo .
define variable v-create-hist as logical no-undo .
define variable v-result as character no-undo .
define buffer buf_c-fin-statement for ub.c-fin-statement.
define buffer buf_c-fin-statement-line for ub.c-fin-statement-line.
define buffer buf_c-fin-statement-attr for ub.c-fin-statement-attr.
define buffer prev_c-fin-statement-line for ub.c-fin-statement-line.
define buffer prev_c-fin-statement-attr for ub.c-fin-statement-attr.
do
on error undo, return error return-value
:
  run cur-time in this-procedure ( output v-date, output v-time).
  create buf_c-fin-statement.
  buffer-copy buf_fin-statement to buf_c-fin-statement
  assign
  buf_c-fin-statement.sttm-code          = p-sttm-code
  buf_c-fin-statement.host-code          = p-host-code
  buf_c-fin-statement.chip-num           = next-value (s-fin-corr-chip, ub)
  buf_c-fin-statement.corr-time          = v-time
  buf_c-fin-statement.corr-user-db-num   = g#db-num
  buf_c-fin-statement.corr-user-name     = g#userid
  buf_c-fin-statement.corr-date          = v-date
  .
  for each ub.fin-statement-line where
          ub.fin-statement-line.sttm-code = buf_fin-statement.sttm-code:
    create buf_c-fin-statement-line.
    buffer-copy ub.fin-statement-line to buf_c-fin-statement-line
    assign
    buf_c-fin-statement-line.chip-num           = buf_c-fin-statement.chip-num
    buf_c-fin-statement-line.corr-user-db-num   = buf_c-fin-statement.corr-user-db-num
    .
  end.
  for each ub.fin-statement-attr where
          ub.fin-statement-attr.sttm-code = buf_fin-statement.sttm-code:
    create buf_c-fin-statement-attr.
    buffer-copy ub.fin-statement-attr to buf_c-fin-statement-attr
    assign
    buf_c-fin-statement-attr.chip-num           = buf_c-fin-statement.chip-num
    buf_c-fin-statement-attr.corr-user-db-num   = buf_c-fin-statement.corr-user-db-num
    .
  end.
    release buf_c-fin-statement.
end.
end procedure.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U
then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  undo, return error '':u.
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
find first buf_sysconf no-lock where
                buf_sysconf.host-code = p-host-code.
if not avail buf_sysconf then dO:
  run err-mess in this-procedure ( input substitute("Не найдена фирма с кодом &1", string(p-host-code)), output v-ret-mess).
  undo, return error (if p-silent = no then "host-code":U else v-ret-mess).
end.
if v-db-num <> buf_sysconf.firm-db-num
then do:
  run err-mess in this-procedure ( input substitute("Нельзя изменять запись ВЫПИСКИ в БД, отличной от главной БД фирмы&3:" +
                           "номер текущей БД &1, номер главной БД фирмы &2", v-db-num, buf_sysconf.firm-db-num, chr(10)), output v-err-mess).
  undo, return error (if p-silent = no then "host-code":U else v-ret-mess).
end.
assign
v-base-code = buf_sysconf.base-code
.
if p-prn-doc-code <> "":U
then do:
  assign
  v-year-start-date = date(1, 1, year(p-doc-date))
  v-year-end-date = date(12, 31, year(p-doc-date))
  .
  IF can-find(first buf_fin-statement no-lock where
                    buf_fin-statement.host-code = p-host-code
                AND buf_fin-statement.prn-doc-code = p-prn-doc-code
                AND buf_fin-statement.fins-doc-type = p-fins-doc-type
                AND (buf_fin-statement.doc-date >= v-year-start-date
                     and
                     buf_fin-statement.doc-date <= v-year-end-date)
                AND (p-mode = 'ДОБАВЛЕНИЕ':U OR p-doc-rec <> recid(buf_fin-statement))
                ) then do:
    run err-mess in this-procedure ( input substitute("Уже есть ВЫПИСКА с номером &1 для фирмы &2 за &3 год"
                              , p-prn-doc-code
                              , p-host-code
                              , year(p-doc-date)), output v-ret-mess).
    undo, return error (if p-silent = no then "prn-doc-code":U else v-ret-mess).
  end.
end.
if p-doc-date = ? then do:
  run err-mess in this-procedure ( input "Неверная дата составления ВЫПИСКИ", output v-ret-mess).
  undo, return error (if p-silent = no then "doc-date":U else v-ret-mess).
end.
if p-curr-code <> 0 then do:
  find first buf_currency no-lock where
            buf_currency.curr-code = p-curr-code no-error.
  if not available buf_currency then do:
    run err-mess in this-procedure ( input substitute("Не найдена валюта с кодом &1", p-curr-code), output v-ret-mess).
    undo, return error (if p-silent = no then "curr-code":U else v-ret-mess) .
  end.
end.
if p-cli-name = '':U then do:
  run err-mess in this-procedure ( input substitute("Не задано имя держателя счета для выписки"), output v-ret-mess).
  undo, return error (if p-silent = no then "cli-name":U else v-ret-mess) .
end.
if p-bank-name = '':U then do:
  run err-mess in this-procedure ( input substitute("Не задано название банка для выписки"), output v-ret-mess).
  undo, return error (if p-silent = no then "cli-name":U else v-ret-mess) .
end.
if p-bank-city = '':U then do:
  run err-mess in this-procedure ( input substitute("Не задан город банка для выписки"), output v-ret-mess).
  undo, return error (if p-silent = no then "cli-name":U else v-ret-mess) .
end.
if p-lines-exist then do:
  find first buf_fin-schet no-lock where
            buf_fin-schet.host-code = p-host-code
        AND buf_fin-schet.code-schet = p-code-schet no-error.
  if not available buf_fin-schet then do:
    run err-mess in this-procedure ( input substitute("Не найден РАСЧЕТНЫЙ СЧЕТ: фирма &1 код счета &2"
                                                    , p-host-code
                                                    , p-code-schet)
                                  , output v-ret-mess).
    undo, return error (if p-silent = no then "code-schet":U else v-ret-mess).
  end.
  if buf_fin-schet.curr-code <> p-curr-code then do:
    run err-mess in this-procedure ( input substitute("Валюта РАСЧЕТНОГО СЧЕТА: фирма &1 код счета &2 валюта &3 - не совпадает с валютой ВЫПИСКИ &4",
    p-host-code, p-code-schet, buf_fin-schet.curr-code, p-curr-code) , output v-ret-mess).
    undo, return error (if p-silent = no then "code-schet":U else v-ret-mess).
  end.
  if buf_fin-schet.code-bank <> p-code-bank then do:
    run err-mess in this-procedure ( input substitute("Банк РАСЧЕТНОГО СЧЕТА: фирма &1 код счета &2 код банка &3 - не совпадает с кодом банка ВЫПИСКИ &4",
    p-host-code, p-code-schet, buf_fin-schet.code-bank, p-code-bank) , output v-ret-mess).
    undo, return error (if p-silent = no then "code-schet":U else v-ret-mess).
  end.
  if not (buf_fin-schet.cli-type = 'орг':U
  and buf_fin-schet.cli-code = p-host-code ) then do:
    run err-mess in this-procedure ( input substitute("Держатель РАСЧЕТНОГО СЧЕТА (фирма &1 р/счет &2 код счета &3)&6&4&5 - не является СВОЕЙ ФИРМОЙ&6" +
                                                       "выписку можно создавать только для счетов СВОЕЙ ФИРМЫ"
                                                       ,p-host-code
                                                       ,buf_fin-schet.r-schet
                                                       ,buf_fin-schet.code-schet
                                                       ,buf_fin-schet.cli-type
                                                       ,buf_fin-schet.cli-code
                                                       ,chr(10)
                                                       )
                                              , output v-ret-mess).
    undo, return error (if p-silent = no then "code-schet":U else v-ret-mess).
  end.
end.
if p-status_ <> 'новый':U
and p-author <> '':U
then do:
  if v-base-code <> 0 then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  v-base-code
  ,input  p-fact-date
  ,output v-base-rate
  ,output v-base-scale
  ,output v-curr-abbr
  )  .
  end.
  if p-curr-code <> 0 then do:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  p-curr-code
  ,input  p-fact-date
  ,output v-exch-rate
  ,output v-exch-scale
  ,output v-curr-abbr
  )  .
  end.
  assign
  v-sum-doc = p-sum-doc
  v-sum-rubl = (if p-curr-code = 0
                then p-sum-doc
                else (p-sum-doc * v-exch-rate / v-exch-scale))
  v-sum-base = if v-base-code = 0
                then v-sum-rubl
                else (v-sum-rubl / v-base-rate * v-base-scale)
  v-in-sum-doc = p-in-sum-doc
  v-in-sum-rubl = (if p-curr-code = 0
                then p-in-sum-doc
                else (p-in-sum-doc * v-exch-rate / v-exch-scale))
  v-in-sum-base = if v-base-code = 0
                then v-in-sum-rubl
                else (v-in-sum-rubl / v-base-rate * v-base-scale)
  v-out-sum-doc = p-out-sum-doc
  v-out-sum-rubl = (if p-curr-code = 0
                then p-out-sum-doc
                else (p-out-sum-doc * v-exch-rate / v-exch-scale))
  v-out-sum-base = if v-base-code = 0
                then v-out-sum-rubl
                else (v-out-sum-rubl / v-base-rate * v-base-scale)
  v-start-sum-doc = p-start-sum-doc
  v-start-sum-rubl = (if p-curr-code = 0
                then p-start-sum-doc
                else (p-start-sum-doc * v-exch-rate / v-exch-scale))
  v-start-sum-base = if v-base-code = 0
                then v-start-sum-rubl
                else (v-start-sum-rubl / v-base-rate * v-base-scale)
  v-end-sum-doc = p-end-sum-doc
  v-end-sum-rubl = (if p-curr-code = 0
                then p-end-sum-doc
                else (p-end-sum-doc * v-exch-rate / v-exch-scale))
  v-end-sum-base = if v-base-code = 0
                then v-end-sum-rubl
                else (v-end-sum-rubl / v-base-rate * v-base-scale)
  .
end.
if lookup(p-fins-ext-doc-type, 'стд':U) = 0 then do:
  run err-mess in this-procedure ( input substitute("Неверный расширенный тип выписки &1", p-fins-ext-doc-type), output v-ret-mess ).
  undo, return error (if p-silent = no then  "fins-ext-doc-type":U  else v-ret-mess).
end.
CASE p-fins-doc-type:
  when 'стд':U then do:
    run ref/finstm01.p (
                    input p-mode
                    ,input "":U
                    ,input p-host-code            ,input p-sttm-code            ,input p-curr-code            ,input p-doc-date             ,input p-bank-date            ,input p-fact-date            ,input p-fins-doc-type        ,input p-fins-ext-doc-type    ,input p-code-bank            ,input p-bank-name            ,input p-bank-city            ,input p-bik                  ,input p-code-schet           ,input p-r-schet              ,input p-c-schet              ,input p-cli-name             ,input p-prn-doc-code         ,input p-PS                   ,input p-sum-doc              ,input p-start-sum-doc-th     ,input p-start-sum-doc        ,input p-in-sum-doc           ,input p-out-sum-doc          ,input p-end-sum-doc          ,input p-num-docs             ,input p-start-date           ,input p-end-date
                    ,input "":U
                    ,input ?
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
  end.
END CASE.
_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    if p-sttm-code = 0 then do:
      assign
      p-sttm-code = next-value(s-fin-sttm, ub)
      .
    end.
    create ub.fin-statement.
    assign
    ub.fin-statement.host-code = p-host-code
    ub.fin-statement.sttm-code = p-sttm-code
    ub.fin-statement.status_ = 'новый':U
    p-doc-rec = recid(ub.fin-statement)
    .
  end.
  else do:
    FIND FIRST ub.fin-statement where
              recid(ub.fin-statement) = p-doc-rec No-ERROR.
    if not available ub.fin-statement then do:
      run err-mess in this-procedure ( input substitute("Не найдена запись ВЫПИСКИ - p-doc-rec &1", p-doc-rec), output v-ret-mess).
      undo, return error (if p-silent = no then  '':u  else v-ret-mess).
    end.
    if ub.fin-statement.host-code <> p-host-code
    OR ub.fin-statement.sttm-code <> p-sttm-code
    OR ub.fin-statement.fins-doc-type <> p-fins-doc-type
    OR ub.fin-statement.fins-doc-type <> p-fins-doc-type
    OR (p-lines-exist
        AND (
        ub.fin-statement.bank-name           <> p-bank-name
        or
        ub.fin-statement.bik                 <> p-bik
        or
        ub.fin-statement.c-schet             <> p-c-schet
        or
        ub.fin-statement.code-schet          <> p-code-schet
        or
        ub.fin-statement.r-schet             <> p-r-schet
            )
    )
    then do:
      run err-mess in this-procedure ( input substitute("Для уже имеющейся записи нельзя изменить&1" +
                               "код фирмы, внутренний № выписки, тип выписки, счет&1"
                               , chr(10)), output v-ret-mess).
      undo, return error (if p-silent = no then  '':U  else v-ret-mess).
    end.
    if ub.fin-statement.status_ <> 'новый':U
    then do:
      if
      ub.fin-statement.start-sum-doc       <> p-start-sum-doc
      or
      ub.fin-statement.end-sum-doc         <> p-end-sum-doc
      or
      ub.fin-statement.in-sum-doc          <> p-in-sum-doc
      or
      ub.fin-statement.out-sum-doc         <> p-out-sum-doc
      or
      ub.fin-statement.sum-doc             <> p-sum-doc
      then do:
        run err-mess in this-procedure ( input substitute("Для ВЫПИСКИ в статусе не &1&2" +
                                "НЕЛЬЗЯ менять суммы остатков, оборотов, счет, валюту платежа&2"
                                ,'новый':U
                                , chr(10))
                      , output v-ret-mess).
        undo, return error (if p-silent = no then  '':U  else v-ret-mess).
      end.
    end.
  end.
  create tt-fin-statement.
  buffer-copy ub.fin-statement to tt-fin-statement.
  assign
  ub.fin-statement.curr-code           = p-curr-code
  ub.fin-statement.doc-date            = p-doc-date
  ub.fin-statement.fins-doc-type       = p-fins-doc-type
  ub.fin-statement.fins-ext-doc-type   = p-fins-ext-doc-type
  ub.fin-statement.bank-name           = p-bank-name
  ub.fin-statement.bank-city           = p-bank-city
  ub.fin-statement.bik                 = p-bik
  ub.fin-statement.c-schet             = p-c-schet
  ub.fin-statement.code-schet          = p-code-schet
  ub.fin-statement.code-bank           = p-code-bank
  ub.fin-statement.r-schet             = p-r-schet
  ub.fin-statement.prn-doc-code        = p-prn-doc-code
  ub.fin-statement.PS                  = p-PS
  ub.fin-statement.cli-name            = p-cli-name
  ub.fin-statement.start-date          = p-start-date
  ub.fin-statement.end-date            = p-end-date
  .
  if p-author <> '':U
  or p-status_ = 'новый':U
  then do:
    assign
    ub.fin-statement.sum-base            = v-sum-base
    ub.fin-statement.sum-doc             = p-sum-doc
    ub.fin-statement.sum-rubl            = v-sum-rubl
    ub.fin-statement.in-sum-base         = v-in-sum-base
    ub.fin-statement.in-sum-doc          = p-in-sum-doc
    ub.fin-statement.in-sum-rubl         = v-in-sum-rubl
    ub.fin-statement.out-sum-base        = v-out-sum-base
    ub.fin-statement.out-sum-doc         = p-out-sum-doc
    ub.fin-statement.out-sum-rubl        = v-out-sum-rubl
    ub.fin-statement.start-sum-base      = v-start-sum-base
    ub.fin-statement.start-sum-doc       = p-start-sum-doc
    ub.fin-statement.start-sum-doc-th    = p-start-sum-doc-th
    ub.fin-statement.start-sum-rubl      = v-start-sum-rubl
    ub.fin-statement.end-sum-base        = v-end-sum-base
    ub.fin-statement.end-sum-doc         = p-end-sum-doc
    ub.fin-statement.end-sum-rubl        = v-end-sum-rubl
    ub.fin-statement.num-docs            = p-num-docs
    .
  end.
  release ub.fin-statement no-error.
  if error-status:error then do:
   run err-mess in this-procedure ( input substitute("Ошибка при сохранении записи ПЛАТЕЖА &1: &2", ERROR-STATUS:GET-message(1), return-value ), output v-ret-mess).
    undo, return error (if p-silent = no then  "":U  else v-ret-mess).
  end.
  find last buf_c-fin-statement no-lock where
            buf_c-fin-statement.host-code = p-host-code
        AND  buf_c-fin-statement.sttm-code = p-sttm-code
        AND  buf_c-fin-statement.corr-user-db-num = g#db-num no-error.
  if not available buf_c-fin-statement
  or (available buf_c-fin-statement
  and buf_c-fin-statement.corr-user-name <> g#userid)
  then do:
    run fin-statementh_write-fin-statement-history in this-procedure (
                                                            buffer tt-fin-statement
                                                            ,input p-host-code
                                                            ,input p-sttm-code
                                                            ) no-error .
    if error-status:error then do:
        v-mes = error-status:get-message(1) .
        run err-mess in this-procedure ( input v-mes, output v-ret-mess).
        undo _main, return error (if p-silent  = no then '':U else v-ret-mess).
    end.
  end.
end.
PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  define output parameter p-ret-mess as character no-undo .
  assign
  p-ret-mess =  substitute("ВЫПИСКА &1: фирма: &2 N: &3,&4 вн. № &5&4&6"
                            , p-fins-doc-type
                            , p-host-code
                            , p-prn-doc-code
                            , chr(10)
                            , p-sttm-code
                            , p-mess
                            ).
  CASE p-silent:
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
