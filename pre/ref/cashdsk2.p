block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-recid as recid no-undo.
define input-output parameter par-cash-on like ub.cash-desk.cash-on no-undo .
define variable vss-revision    as character no-undo init "$Revision: 79dbeab10a26, 2672, rls $":U .
define variable vss-author      as character no-undo init "$Author: Ostroukhov $":U .
define variable vss-date        as character no-undo init "$Date: Вт ноя 17 10:53:20 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cashdsk2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cashdsk2.p $":U .
define variable vss-description as character no-undo init "Изменение статуса вкл/выкл кассы".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define  NEW SHARED  temp-table cash-obj no-undo
field km-objcode  as integer
field km-objname as character
field km-objtype as integer
field on-addr like ub.cash-desk.addr-path
field off-addr like ub.cash-desk.addr-path
field shop-nums as character
field obj-lock as integer
field firm-name as character
field jur-address as character
field post-address as character
field INN as character
field KPP as character
index pi is unique primary
km-objtype km-objcode km-objname
.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE varold-cash-on like ub.cash-desk.cash-on no-undo .
define variable l-shift-on as logical no-undo.
define variable v-shift-date as date no-undo.
define variable v-shift-num as integer no-undo.
define variable v-shift-name as character no-undo.
define variable v-result as integer no-undo .
DEFINE BUFFER bf_cash-desk for ub.cash-desk.
DEFINE BUFFER buf_cash-desk for ub.cash-desk.
define buffer bfcdm_cash-desk for ub.cash-desk.
define buffer buf_shift-cash for ub.shift-cash.
_main:
do
on error undo, return error
:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
FIND FIRST bf_cash-desk WHERE
           recid(bf_cash-desk) = par-recid.
varold-cash-on = bf_cash-desk.cash-on.
if par-cash-on = ? then do:
  CASE bf_cash-desk.cash-on:
    when yes then do:
      assign
      par-cash-on = no.
    end.
    when no then do:
      assign
      par-cash-on = yes.
    end.
  END CASE.
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  'маг':U
  ,input  bf_cash-desk.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
CASE par-cash-on:
 when yes then do:
    run proc-b-on in this-procedure ( buffer bf_cash-desk
                                     ,output v-result
                                     ) no-error.
    if error-status:error then do:
      undo _main, return error return-value.
    end.
    if v-result = 1
    and return-value <> '':U
    then do:
       message
       return-value
       view-as alert-box .
    end.
    run proc-on-off in this-procedure (input-output par-cash-on) no-error.
    if error-status:error then do:
      undo _main, return error return-value.
    end.
 end.
 when no then do:
    run proc-b-off in this-procedure (buffer bf_cash-desk) no-error.
    if error-status:error then do:
      undo _main, return error return-value .
    end.
    if l-shift-on then do:
        FIND FIRST buf_shift-cash WHERE
                  buf_shift-cash.obj-type = 'маг':U
              AND buf_shift-cash.obj-code = bf_cash-desk.obj-code
              AND buf_shift-cash.cash-num = bf_cash-desk.cash-num
              AND buf_shift-cash.shift-date = v-shift-date
              AND buf_shift-cash.z-status = '' No-ERROR.
        if avail buf_shift-cash then do:
            if buf_shift-cash.status_ = 'зкр':U then.
            else delete buf_shift-cash.
        end.
    end.
    run proc-on-off in this-procedure (input-output par-cash-on) no-error.
    if error-status:error then do:
      undo _main, return error return-value .
    end.
 end.
 END CASE.
end.
procedure proc-on-off:
define input-output parameter par-cash-on like ub.cash-desk.cash-on no-undo .
  do
  on error undo, return error
  :
    assign
    bf_cash-desk.cash-on = par-cash-on.
    if bf_cash-desk.pos-type = 'IBM-XML':U
    and bf_cash-desk.autonomy <> integer('0':U)
    then do:
      for each cash-obj:
        delete cash-obj.
      end.
      find first cash-obj where
              cash-obj.km-objtype = (if buf_cash-desk.autonomy = integer('2':U) then 2 else 3)
          AND cash-obj.km-objcode = bf_cash-desk.cash-num no-error .
      if not available cash-obj then do:
        create cash-obj.
        assign
        cash-obj.km-objcode = bf_cash-desk.cash-num
        cash-obj.km-objtype = (if bf_cash-desk.autonomy = integer('2':U) then 2 else 3)
        cash-obj.km-objname = (if bf_cash-desk.autonomy = integer('2':U)
                               then "КМ"
                               else ("касса" + string(bf_cash-desk.cash-num))
                               )
        cash-obj.on-addr    = (if bf_cash-desk.autonomy = integer('2':U)
                              then bf_cash-desk.addr-path
                              else (entry(1, bf_cash-desk.addr-path, chr(4))
                                    + "://":U
                                    + entry(2, bf_cash-desk.addr-path, chr(4))
                                  )
                              )
        cash-obj.off-addr   = (if bf_cash-desk.autonomy = integer('2':U)
                              then bf_cash-desk.addr-path
                              else (entry(1, bf_cash-desk.addr-path, chr(4))
                                    + "://":U
                                    + entry(2, bf_cash-desk.addr-path, chr(4))
                                  )
                              )
        cash-obj.shop-nums  = if bf_cash-desk.autonomy = integer('1':U)
                              then  string(bf_cash-desk.obj-code)
                              else "":U
        cash-obj.obj-lock   = if bf_cash-desk.cash-on then 0 else 1
        .
        if bf_cash-desk.autonomy = integer('2':U) then do:
          for each bfcdm_cash-desk no-lock where
                  bfcdm_cash-desk.db-num = bf_cash-desk.db-num
            AND  bfcdm_cash-desk.pos-type = 'IBM-XML':U
            AND  bfcdm_cash-desk.autonomy = integer('2':U)
            AND  bfcdm_cash-desk.cash-on = yes
            :
            assign
            cash-obj.shop-nums = cash-obj.shop-nums
                                  + (if cash-obj.shop-nums = "":u then "":U else chr(44))
                                  + string(bfcdm_cash-desk.obj-code)
            .
          end.
        end.
        if can-find(first ub.cash-desk no-lock where
                         ub.cash-desk.db-num = bf_cash-desk.db-num
                     and ub.cash-desk.obj-code = bf_cash-desk.obj-code
                     and ub.cash-desk.pos-type = 'IBM-XML':U) then
        run str/diallog.w (
                      input parparentproc
                    , input this-procedure
                    , 'str/send-obj.p':U
                    , input (string(bf_cash-desk.db-num) + chr(4) +
                            string(bf_cash-desk.obj-code) + chr(4) +
                            "R":U )
                    , no
                    , ''
                    , substitute('Отправка информации по объектам БД на кассовый менеджер &1', 'IBM-XML':U)).
      end.
    end.
    release bf_cash-desk no-error .
    if error-status:error then do:
      message
      "Ошибка при сохранении записи КАССА" skip
      error-status:get-message(1) skip
      return-value
      view-as alert-box error .
      undo , return error .
    end.
    par-cash-on = ?.
  end.
end procedure.
PROCEDURE proc-b-off :
DEFINE PARAMETER BUFFER t-cash-desk for ub.cash-desk.
define variable glog as logical no-undo .
define variable v-shift-date as date no-undo.
define variable v-shift-num as integer no-undo.
if l-shift-on then do:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  'маг':U
  ,input  t-cash-desk.obj-code
  ,output v-shift-date
  ,output v-shift-num
  ,output v-shift-name
  ) no-error .
   if error-status:error and v-shift-num = 0 then return.
  define variable v-chk-act-host-code as integer   no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  'маг':U
  ,input  bf_cash-desk.obj-code
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_shift_super':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  'маг':U
    ,input  bf_cash-desk.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output glog
    )  .
end.
  if not glog then do:
      return error  ( substitute("Включена смена на магазине &1&2Выключить кассу невозможно"
                                ,t-cash-desk.obj-code
                                , chr(10))).
  end.
end.
END PROCEDURE.
PROCEDURE proc-b-on :
DEFINE PARAMETER BUFFER t-cash-desk for ub.cash-desk.
define output parameter p-result as integer no-undo .
define variable vrecid as recid no-undo.
define variable predmet as char.
define variable hr as recid.
DEFINE VARIABLE hour AS INTEGER.
DEFINE VARIABLE minute AS INTEGER.
DEFINE VARIABLE sec AS INTEGER.
DEFINE VARIABLE timeleft AS INTEGER.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-shift-date as date no-undo.
define variable v-shift-num as integer no-undo.
define variable varshift-name     as character no-undo.
define variable varshift-name-num as character no-undo.
define buffer buf_c-cash-desk for ub.c-cash-desk.
if l-shift-on then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  'маг':U
  ,input  t-cash-desk.obj-code
  ,output v-shift-date
  ,output v-shift-num
  ,output v-shift-name
  ) no-error .
  if not error-status:error and v-shift-num > 0 then do:
    FIND FIRST buf_shift-cash NO-LOCK WHERE
              buf_shift-cash.obj-type = 'маг':U
          AND buf_shift-cash.obj-code = t-cash-desk.obj-code
          AND buf_shift-cash.cash-num = t-cash-desk.cash-num
          AND buf_shift-cash.shift-date = v-shift-date
          AND buf_shift-cash.shift-num = v-shift-num No-ERROR.
    if not avail buf_shift-cash then do:
        run cur-time in this-procedure ( output v-today, output v-time).
        run str/shftccr.p (input 'маг':U
                      ,input t-cash-desk.obj-code
                      ,input t-cash-desk.cash-num
                      ,input v-shift-date
                      ,input v-shift-num
                      ,input string(v-shift-num)
                      ,input v-shift-name
                      ,input v-time
                      ,input 0
                      ,input 'касса-вкл':U
                      ,output vrecid
                      ) no-error.
        if error-status:error then return error
        ("Не удалось создать запись открытия смены на кассе " + string(t-cash-desk.cash-num)).
    end.
    else do:
      if buf_shift-cash.status_ = 'зкр':U then.
      else do:
         p-result = 1.
      end.
    end.
  end.
end.
FOR EACH buf_c-cash-desk no-lock where
        buf_c-cash-desk.db-num = t-cash-desk.db-num
    AND buf_c-cash-desk.obj-code = t-cash-desk.obj-code
    AND buf_c-cash-desk.pos-type = t-cash-desk.pos-type
    AND buf_c-cash-desk.cash-num = t-cash-desk.cash-num
BY buf_c-cash-desk.chip-num descending:
  if buf_c-cash-desk.cash-on
  AND
  buf_c-cash-desk.cash-on <> t-cash-desk.cash-on
  and not (t-cash-desk.pos-type = 'IBS-TH':U
           or
           t-cash-desk.pos-type = 'IBS-TH-MOB':U
          )
  then do:
    run cur-time in this-procedure(output v-today, output v-time).
    if v-today > buf_c-cash-desk.corr-date then do:
        message
        substitute("ВНИМАНИЕ! Касса &1 магазина  &2&3" +
                   "была выключена &4 дней!&3" +
                   "Перешлите на кассы все сделанные за это время изменения!"
                    ,t-cash-desk.cash-num
                    ,t-cash-desk.obj-code
                    ,chr(10)
                    ,string(v-today - buf_c-cash-desk.corr-date))
       view-as alert-box WARNING.
    end.
    else do:
      timeleft = v-time - buf_c-cash-desk.corr-time.
      sec = timeleft MOD 60.
      timeleft = (timeleft - sec) / 60.
      minute = timeleft MOD 60.
      hour = (timeleft - minute) / 60.
      message
      substitute("ВНИМАНИЕ! Касса &1 магазина  &2&3" +
                 "была выключена в течении &4 часов &5 минут &6 секунд!&3" +
                 "Перешлите на кассы все сделанные за это время изменения!"
                  ,t-cash-desk.cash-num
                  ,t-cash-desk.obj-code
                  ,chr(10)
                 ,hour
                 ,minute
                 ,sec)
      view-as alert-box WARNING.
    end.
    LEAVE.
  end.
END.
if p-result = 1 then do:
  return substitute("ВНИМАНИЕ! Попытка повторно открыть смену на кассе "  +
                              string(t-cash-desk.cash-num)).
end.
END PROCEDURE.
