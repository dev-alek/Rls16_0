block-level on error undo, throw.
define input parameter par-recid as recid no-undo.
define input parameter p-silent as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: taxvali2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/taxvali2.p $":U .
define variable vss-description as character no-undo init "Изменение статуса значения ставки налога".
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
DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE is-found as logical no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-mess as character no-undo .
DEFINE BUFFER bf_tax-rate-value for tax-rate-value.
DEFINE BUFFER buf_tax-rate-value for tax-rate-value.
FIND FIRST bf_tax-rate-value WHERE
           recid(bf_tax-rate-value) = par-recid No-ERROR.
if not avail bf_tax-rate-value then return error.
loc#log = no.
CASE bf_tax-rate-value.status_:
  when 'тек':U then do:
    if not p-silent then do:
      message "Вы действительно хотите выключить (логически) запись о значении ставки налога?"
      view-as alert-box QUESTION buttons YES-NO
      update loc#log.
  end.
    else do:
      loc#log = yes.
    end.
  end.
  when 'удал':U then do:
    if not p-silent then do:
      message "Запись о значении ставки налога уже (логически) выключена" skip
      "Восстановить?"
      view-as alert-box QUESTION buttons YES-NO
      update loc#log.
  end.
    else do:
      loc#log = yes.
    end.
  end.
  otherwise do:
      BELL.
      return error.
  end.
END CASE.
if not loc#log then return error.
do
on error undo, return error
:
if bf_tax-rate-value.status_ = 'тек':U then do:
  if bf_tax-rate-value.host-code > 0 and
     bf_tax-rate-value.obj-type = '':U and
     bf_tax-rate-value.obj-code = 0
      then do:
    if can-find(first buf_tax-rate-value No-LOCK WHERE
                      buf_tax-rate-value.tax-code = bf_tax-rate-value.tax-code AND
                      buf_tax-rate-value.rate-code = bf_tax-rate-value.rate-code AND
                      buf_tax-rate-value.host-code = bf_tax-rate-value.host-code AND
                      buf_tax-rate-value.fact-order > bf_tax-rate-value.fact-order AND
                      buf_tax-rate-value.obj-type <> '':U and
                      buf_tax-rate-value.obj-code <> 0 and
                      buf_tax-rate-value.status_ = 'тек':U)
       AND
       Not can-find(first buf_tax-rate-value No-LOCK WHERE
                      buf_tax-rate-value.tax-code = bf_tax-rate-value.tax-code AND
                      buf_tax-rate-value.rate-code = bf_tax-rate-value.rate-code AND
                      buf_tax-rate-value.host-code = bf_tax-rate-value.host-code AND
                      buf_tax-rate-value.fact-order <= bf_tax-rate-value.fact-order AND
                      buf_tax-rate-value.obj-type = '':U and
                      buf_tax-rate-value.obj-code = 0 and
                      buf_tax-rate-value.status_ = 'тек':U) then do:
      v-mess = substitute("Чтобы логически удалить значение ставки по фирме&1"  +
              "сначала удалите логически значения ставок по объектам данной фирмы с более поздней датой действия"
                          , chr(10)).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'salience':U).
    end.
  end.
  if bf_tax-rate-value.host-code = 0 and
     bf_tax-rate-value.obj-type = '':U and
     bf_tax-rate-value.obj-code = 0
      then do:
    if can-find(first buf_tax-rate-value No-LOCK WHERE
                      buf_tax-rate-value.tax-code = bf_tax-rate-value.tax-code AND
                      buf_tax-rate-value.rate-code = bf_tax-rate-value.rate-code AND
                      buf_tax-rate-value.host-code <> 0 AND
                      buf_tax-rate-value.fact-order > bf_tax-rate-value.fact-order AND
                      buf_tax-rate-value.obj-type = '':U and
                      buf_tax-rate-value.obj-code = 0 and
                      buf_tax-rate-value.status_ = 'тек':U)
       AND
       Not can-find(first buf_tax-rate-value No-LOCK WHERE
                      buf_tax-rate-value.tax-code = bf_tax-rate-value.tax-code AND
                      buf_tax-rate-value.rate-code = bf_tax-rate-value.rate-code AND
                      buf_tax-rate-value.host-code = 0 AND
                      buf_tax-rate-value.fact-order <= bf_tax-rate-value.fact-order AND
                      buf_tax-rate-value.obj-type = '':U and
                      buf_tax-rate-value.obj-code = 0 and
                      buf_tax-rate-value.status_ = 'тек':U) then do:
      v-mess = substitute("Чтобы логически удалить глобальное значение ставки&1" +
              "сначала удалите логически значения ставок по фирмам с более поздней датой действия"
                          , chr(10)).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'salience':U).
    end.
    run cur-time in this-procedure(output v-today, output v-time).
    if not can-find (first buf_tax-rate-value No-LOCK WHERE
                           buf_tax-rate-value.tax-code = bf_tax-rate-value.tax-code AND
                           buf_tax-rate-value.rate-code = bf_tax-rate-value.rate-code AND
                           buf_tax-rate-value.status_ = 'тек':U AND
                           buf_tax-rate-value.host-code = 0 AND
                           buf_tax-rate-value.obj-type = '':U AND
                           buf_tax-rate-value.obj-code = 0 AND
                           buf_tax-rate-value.fact-order <= bf_tax-rate-value.fact-order AND
                           recid(buf_tax-rate-value) <> recid(bf_tax-rate-value)) AND
      can-find( first ub.tax-rate-gds No-LOCK WHERE
                      ub.tax-rate-gds.tax-code = bf_tax-rate-value.tax-code AND
                      ub.tax-rate-gds.rate-code = bf_tax-rate-value.rate-code AND
                      ub.tax-rate-gds.fact-order <= bf_tax-rate-value.fact-order AND
                      ub.tax-rate-gds.fact-date <= v-today ) then do:
      v-mess = substitute("Нельзя удалить последнее значение ставки&1"  +
              "имеются товары с такой ставкой"
                          , chr(10)).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'salience':U).
    end.
  end.
end.
if bf_tax-rate-value.status_ = 'тек':U then do:
  FIND FIRST buf_tax-rate-value No-LOCK WHERE
             buf_tax-rate-value.tax-code = bf_tax-rate-value.tax-code AND
             buf_tax-rate-value.rate-code = bf_tax-rate-value.rate-code AND
             buf_tax-rate-value.host-code = bf_tax-rate-value.host-code AND
             buf_tax-rate-value.obj-type  = bf_tax-rate-value.obj-type AND
             buf_tax-rate-value.obj-code = bf_tax-rate-value.obj-code AND
             buf_tax-rate-value.fact-order <= bf_tax-rate-value.fact-order AND
             buf_tax-rate-value.status_ = 'тек':U AND
             recid(buf_tax-rate-value) <> recid(bf_tax-rate-value) No-ERROR.
  if not avail buf_tax-rate-value then do:
    FIND FIRST buf_tax-rate-value No-LOCK WHERE
              buf_tax-rate-value.tax-code = bf_tax-rate-value.tax-code AND
              buf_tax-rate-value.rate-code = bf_tax-rate-value.rate-code AND
              buf_tax-rate-value.host-code = bf_tax-rate-value.host-code AND
              buf_tax-rate-value.obj-type  = "":U AND
              buf_tax-rate-value.obj-code = 0 AND
              buf_tax-rate-value.fact-order <= bf_tax-rate-value.fact-order AND
              buf_tax-rate-value.status_ = 'тек':U AND
              recid(buf_tax-rate-value) <> recid(bf_tax-rate-value) No-ERROR.
    if not avail buf_tax-rate-value then dO:
      FIND FIRST buf_tax-rate-value No-LOCK WHERE
                buf_tax-rate-value.tax-code = bf_tax-rate-value.tax-code AND
                buf_tax-rate-value.rate-code = bf_tax-rate-value.rate-code AND
                buf_tax-rate-value.host-code = 0 AND
                buf_tax-rate-value.obj-type  = "":U AND
                buf_tax-rate-value.obj-code = 0 AND
                buf_tax-rate-value.fact-order <= bf_tax-rate-value.fact-order AND
                buf_tax-rate-value.status_ = 'тек':U AND
                recid(buf_tax-rate-value) <> recid(bf_tax-rate-value) No-ERROR.
      if avail buf_tax-rate-value then
      is-found = yes.
    end.
    else is-found = yes.
  end.
  else is-found = yes.
end.
if not is-found and bf_tax-rate-value.status_ = 'тек':U then do:
  if not p-silent then do:
  message "При логическом удалении данного значения ставки" SKIP
          "не останется ни одного действующего значения по данной ставке"
          "Вы все еще хотите удалить значение ставки?"
  view-as alert-box QUESTION buttons YES-NO update loc#log.
  if not loc#log then
  return error.
end.
end.
assign
bf_tax-rate-value.status_ = (if bf_tax-rate-value.status_ = 'удал':U
                            then 'тек':U
                            else 'удал':U).
release bf_tax-rate-value no-error .
if error-status:error then do:
  v-mess = substitute("Ошибка при сохранении записи ЗНАЧЕНИЕ СТАВКИ НАЛОГА&1&2&1&3"
           , chr(10)
           ,  error-status:get-message(1)
           , return-value).
  run err-mess in this-procedure ( input-output v-mess).
  return error (if p-silent = yes then v-mess else 'salience':U).
end.
end.
procedure err-mess:
define input-output parameter p-mess as character no-undo.
  case p-silent:
    when yes then do:
      assign
      p-mess = substitute("Вкл/Выключ ЗНАЧЕНИЯ ставки налога&1"
                          + "Тип ставки &2&1"
                          + "Код ставки &3&1"
                          + "Код фирмы &4&1"
                          + "Объект &5 &6&1"
                          + "Дата включениия &7&1"
                          + "&8"
                         , chr(10)
                         , buf_tax-rate-value.tax-code
                         , buf_tax-rate-value.rate-code
                         , buf_tax-rate-value.host-code
                         , buf_tax-rate-value.obj-type
                         , buf_tax-rate-value.obj-code
                         , buf_tax-rate-value.fact-date
                         , p-mess)
      .
    end.
    when no then do:
  message
      p-mess
  view-as alert-box error .
end.
  end.
end procedure.
