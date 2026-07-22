block-level on error undo, throw.
define input parameter p-exit-on-error as logical no-undo .
define input parameter p-doc-code like ub.chk-doc.doc-code no-undo .
define input parameter p-doc-type as integer no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.chk-doc.obj-type no-undo .
define input parameter p-obj-code like ub.chk-doc.obj-code no-undo .
define input parameter p-chk-date like ub.chk-doc.chk-date no-undo .
define input parameter p-chk-time like ub.chk-doc.chk-time no-undo .
define input parameter p-shift-date like ub.chk-doc.shift-date no-undo .
define input parameter p-shift-num like ub.chk-doc.shift-num no-undo .
define input parameter p-shift-name like ub.chk-doc.shift-name no-undo .
define input parameter p-pay-desk like ub.chk-doc.pay-desk no-undo .
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
define input-output    parameter p-cash-rate like ub.chk-doc.cash-rate no-undo .
define input parameter p-cashier like ub.chk-doc.cashier no-undo .
define input parameter p-sales-man like ub.chk-doc.sales-man no-undo .
define input parameter p-d-card like ub.chk-doc.d-card no-undo .
define input parameter p-z-number like ub.chk-doc.z-number no-undo .
define input parameter p-PS like ub.chk-doc.PS no-undo .
define input parameter p-lines-exist as logical no-undo .
define input parameter r-b as character no-undo .
define input parameter cas-shft as logical no-undo .
define input parameter l-shift-on as logical no-undo .
define input parameter t-shft as integer no-undo .
define input parameter v-shft as integer no-undo .
define input parameter cas-curs as logical no-undo .
define input parameter hnum as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка корректности шапки чека МЦ".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-is-this-db-code returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'u'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code no-error .
if available buf_code-range then return yes.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and  buf_code-range.stts = 'a'
      and buf_code-range.first-code <= p-code
      no-error .
 if available buf_code-range then return yes.
end.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'f'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code
    no-error .
if available buf_code-range then return yes.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-code-short returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and buf_code-range.first-code <= p-code
      and buf_code-range.last-code >= p-code no-error .
  if available buf_code-range then return yes.
end.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-role returns integer ( input p-role as character
                                                    ,input p-db-num as integer
                                                    ,input p-staff-code as integer
                                                    ,input p-date as date
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
      and buf_staff.staff-code = p-staff-code
      and buf_staff.date-end >= p-date use-index pi  no-error .
if available buf_staff then do:
  return buf_staff.psn-code.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-this-db-first-role returns integer ( input p-role as character
                                                          ,input p-db-num as integer
                                                          ,input p-date as date
                                                              ):
define buffer buf_staff for ub.staff.
define buffer buf2_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each  buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.db-num = p-db-num,
first buf2_staff no-lock where
      buf2_staff.role = p-role
  and buf2_staff.role-level = 'db':U
  and buf2_staff.staff-code = buf_staff.staff-code
  and buf2_staff.date-start <= p-date
  and buf2_staff.date-end >= p-date
by buf_staff.staff-code
by date-start descending:
  return buf_staff.staff-code.
end.
end FUNCTION.
FUNCTION gbclcode-get-db-role returns integer ( input p-role as character
                                               ,input p-db-num as integer
                                               ,input p-psn-code as integer
                                               ,input p-date as date
                                               ,output p-c-password as character
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
     and buf_staff.date-end >= p-date
     and buf_staff.psn-code = p-psn-code use-index irole-psn no-error .
if available buf_staff
then do:
  assign
  p-c-password = buf_staff.password.
  return buf_staff.staff-code.
end.
p-c-password = ''.
return 0.
end FUNCTION.
FUNCTION gbclcode-is-psn-role returns integer (
                                              input p-role as character
                                              ,input p-psn-code as integer
                                              ,input p-date as date
                                                  ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each buf_staff no-lock where
          buf_staff.psn-code = p-psn-code
     and  buf_staff.role = p-role
by buf_staff.role-level
by buf_staff.date-start
     :
  if  buf_staff.date-start <= p-date and
  buf_staff.date-end >= p-date  then do:
    return buf_staff.staff-code.
  end.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-role-name returns character ( input p-role as character):
define variable v-role-name as character no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
no-error .
return v-role-name.
END.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-get-position returns character ( input p-role as character
                                                  ,input p-role-level as character
                                                  ,input p-work-place as character
                                                  ,input p-staff-code as integer
                                                             ):
define variable v-role-name as character no-undo .
define variable v-role-level as character no-undo .
define variable v-staff-code as integer no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
v-role-level = substitute("&1 &2", entry (lookup (p-role-level, 'global,db,firm,object':U) + 1, ',':U + 'Глобально,БД,Фирма,Объект':U) , p-work-place)
v-staff-code = p-staff-code
no-error .
return substitute("&1, &2, Код &3"
                ,v-role-name
                ,v-role-level
                ,(if p-staff-code = 0 then chr(63) else string(p-staff-code))).
END.
FUNCTION gbclcode-get-work-place returns character (
                                                input p-role as character
                                               ,input p-role-level as character
                                               ,input p-db-num as integer
                                               ,input p-host-code as integer
                                               ,input p-obj-type as character
                                               ,input p-obj-code as integer
                                               ) :
define variable v-work-place as character no-undo .
define variable v-obj-type as character no-undo .
  case p-role-level:
    when 'db':U then do:
      v-work-place = string(p-db-num, "99999").
    end.
    when 'firm':U then do:
      v-work-place = string(p-host-code, "99999").
    end.
    when 'object':U then do:
      assign
      v-work-place = p-obj-type + string(p-obj-code, "999999999")
      .
    end.
  END CASE.
  return v-work-place.
END FUNCTION.
FUNCTION gbclcode-get-level-last-code returns integer (
                                                        input p-role as character
                                                      , input p-role-level as character
                                                      , input p-work-place as character
                                                      , input p-date-start as date
                                                      ):
DEFINE VARIABLE v-today as date no-undo .
define buffer buf_staff for ub.staff.
if p-work-place = chr(63) then return ?.
if p-date-start = ? then do:
  v-today = today .
end.
else do:
  v-today = p-date-start.
end.
find last buf_staff no-lock where
          buf_staff.role = p-role
     and  buf_staff.role-level = p-role-level
     and  buf_staff.work-place = p-work-place
     and  buf_staff.date-start <= v-today + 1
     and  buf_staff.date-end >= v-today + 1
     use-index pi  no-error .
if available buf_staff
then return buf_staff.staff-code.
return 0.
end FUNCTION.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE VARIABLE var-chk-type as character no-undo .
DEFINE VARIABLE var-entry as character no-undo .
DEFINE VARIABLE vardb-num like ub.clients.db-num no-undo .
DEFINE VARIABLE v-shift-date as date no-undo.
DEFINE VARIABLE v-shift-num as integer no-undo.
DEFINE VARIABLE v-shift-name as character no-undo.
DEFINE VARIABLE varbase-code like ub.sysconf.base-code no-undo .
define buffer cashier for ub.person.
define buffer sales-man for ub.person.
define buffer buf_cash-desk for ub.cash-desk.
define buffer buf_clients for ub.clients.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_dis-card-type for ub.dis-card-type.
do
on error undo, return error return-value
:
  FIND FIRST ub.sysconf No-LOCK WHERE
            ub.sysconf.host-code = p-host-code No-ERROR.
  IF NOT AVAIL ub.sysconf THEN DO:
    undo, return error substitute("Не найдена фирма &1!", p-host-code).
  END.
  varbase-code = ub.sysconf.base-code.
  FIND FIRST buf_clients No-LOCK WHERE
            buf_clients.obj-type = p-obj-type AND
            buf_clients.obj-code = p-obj-code NO-ERROR.
  IF NOT AVAIL buf_clients THEN DO:
    undo, return error substitute("Не найден объект &1&2!", p-obj-type, p-obj-code).
  END.
  vardb-num = buf_clients.db-num.
  if cas-shft or l-shift-on then do:
      if ABS(p-SHIFT-date - p-CHK-date) > 1 then do:
         undo, return error substitute("Чек &1 - ошибочный.&2" +
                                       "Несоответствуют друг другу дата чека &3 и дата начала смены &4!"
                                      , p-doc-code
                                      , chr(10)
                                      , p-chk-date
                                      ,p-shift-date
                                      ).
      end.
      if p-shift-num = 0 then do:
        undo, return error substitute("Чек &1 - ошибочный.&2" +
                                      "Номер смены не может равняться 0!"
                                      , p-doc-code
                                      , chr(10)).
      end.
      if l-shift-on then do:
        run curshift in this-procedure no-error.
        if error-status:error then.
        else do:
          if p-shift-date <> v-shift-date OR
            p-shift-num <> v-shift-num then do:
          undo, return error substitute("Чек &1 - ошибочный.&2" +
                                        "Несоответствуют друг другу дата/номер смены чека &3/&4&2" +
                                         "и дата/номер смены на объекте &5/&6!"
                                        ,p-doc-code
                                        ,chr(10)
                                        ,p-shift-date
                                        ,p-shift-name
                                        ,v-shift-date
                                        ,v-shift-num
                                        ).
          end.
        end.
      if v-shft >= 0 then do:
        FOR EACH ub.shift-cash No-LOCK WHERE
                ub.shift-cash.obj-type = p-obj-type AND
                ub.shift-cash.obj-code = p-obj-code AND
                ub.shift-cash.cash-num = p-pay-desk AND
                (ub.shift-cash.shift-date = p-shift-date OR
                ub.shift-cash.shift-date = p-shift-date - 1) AND
                ub.shift-cash.shift-num = p-shift-num:
          if ub.shift-cash.sale-date = p-shift-date then LEAVE.
        END.
        if not avail ub.shift-cash then do:
         undo, return error substitute("Чек &1 - ошибочный.&2" +
                                       "На кассе &3 &4&5&2" +
                                       "не  было смены c пор. N &2 за &7"
                                       ,p-doc-code
                                       ,chr(10)
                                       ,p-pay-desk
                                       ,p-obj-type
                                       ,p-obj-code
                                       ,p-shift-num
                                       ,string(p-shift-date, "99/99/9999")).
        END.
      end.
  end.
  ELSE DO:
    if (p-chk-date - p-shift-date) > 1
    then do:
      undo, return error substitute("Чек &1 - ошибочный.&2" +
                                    "Не соответствуют друг другу дата чека &3 и дата начала смены &4!"
                                  , p-doc-code
                                  , chr(10)
                                  , p-chk-date
                                  ,p-shift-date
                                  ).
    end.
  END.
  if not cas-curs then do:
    if varbase-code = 0 or r-b = "rubl":U then
    assign
    p-cash-rate = 1
    .
    else do:
      FIND FIRST ub.curr-shop No-LOCK WHERE
                  ub.curr-shop.obj-type = p-obj-type AND
                  ub.curr-shop.obj-code = p-obj-code AND
                  ub.curr-shop.curr-code = varbase-code AND
              ( ( ub.curr-shop.exch-date = p-chk-date AND
                  ub.curr-shop.exch-time <= p-chk-time ) OR
                ub.curr-shop.exch-date < p-chk-date ) NO-ERROR .
      if  not available ub.curr-shop then do:
        undo, return error
        substitute("Чек &1 - ошибочный.&2" +
                   "Нет магазинного курса базовой валюты на дату и время чека-&2&3 &4!"
                  , p-doc-code
                  , chr(10)
                  ,string(p-chk-date, "99/99/9999")
                  ,string(p-chk-time, "hh:mm")).
      end.
      p-cash-rate = ub.curr-shop.exch-rate / ub.curr-shop.exch-scale.
    end.
  end.
  else do:
    if p-cash-rate = 0 then do:
      undo, return error
      substitute("Чек &1 - ошибочный.&2" +
                 "Неверный курс базовой валюты базовой валюты на дату и время чека-&2&3 &4 = &5!"
                , p-doc-code
                , chr(10)
                ,string(p-chk-date, "99/99/9999")
                ,string(p-chk-time, "hh:mm")
                ,p-cash-rate
                ).
    end.
  end.
  if gbclcode-is-this-db-role ( input 'C':U, input vardb-num, input p-cashier, input p-chk-date) = 0 then do:
     undo, return error substitute(
                              "!!!Чек МЦ &1 - ошибочный. &2 Нет сведений о кассире &3 на &4"
                              , p-doc-code
                              , chr(10)
                              , p-cashier
                              , string(p-chk-date, "99/99/9999")
                            ).
  end.
  if p-doc-type = 0 then do:
    if gbclcode-is-this-db-role( input 'S':U, input vardb-num, input p-sales-man, input p-chk-date) = 0 then do:
     undo, return error substitute(
                              "!!!Чек МЦ &1 - ошибочный. &2 Нет сведений о продавце &3 на &4"
                              , p-doc-code
                              , chr(10)
                              , p-sales-man
                              , string(p-chk-date, "99/99/9999")
                            ).
    end.
  end.
  find first ub.sys-ctrl No-LOCK.
  FIND FIRST buf_cash-desk where
            buf_cash-desk.db-num = ub.sys-ctrl.db-num AND
            buf_cash-desk.obj-code = p-obj-code AND
            buf_cash-desk.cash-num = p-pay-desk no-error.
  if not available buf_cash-desk then dO:
    undo, return error substitute("!!!Чек &1 - ошибочный. &2 Нет сведений о кассе &3 с типом &4"
                              , p-doc-code
                              , chr(10)
                              , p-pay-desk
                              , p-pos-type
                            ).
  end.
  end.
 return var-chk-type.
end.
procedure curshift :
   do
  on error undo, return error return-value
  :
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-shift-date
  ,output v-shift-num
  ,output v-shift-name
  ) no-error .
    if error-status:error then do:
      undo, return error substitute("&1 &2 &3&4Не удалось определить дату и время текущей смены&4&5&4&6"
                                   ,vss-workfile
                                   ,vss-revision
                                   ,vss-description
                                   , error-status:get-message(1)
                                   , return-value ).
    end.
  end.
end procedure.
