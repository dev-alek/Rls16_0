CREATE WIDGET-POOL.
define input parameter parparentproc as handle    no-undo .
define input parameter p-pid      as integer          no-undo.
define input parameter p-user-id  as character        no-undo.
define input parameter p-cash-num as integer          no-undo.
define input parameter p-emul     as logical          no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Основное окно АРМа Касса".
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
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define stream slip-out.
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table tt-cdm no-undo
   field cd-mode       as character
   field cdm-name       as character
   field cdm-next-modes as character
   field cdm-btns       as character
   index pi is primary unique
      cd-mode
.
define temp-table tt-func-key no-undo
   field cd-mode     as character
   field cd-submode  as character
   field key-name    as character
   field key_label   as character
   field key_func    as character
   field cng-context as logical
   field func-param  as character
   index pi is primary unique
      cd-mode
      cd-submode
      key-name
.
define temp-table tt-head-check no-undo
    field doc-code      as character
    field chk-type      as INTEGER
    field exch-rate     as decimal
    field exch-scales   as decimal
    field cash-rate     as decimal
    field cash-scales   as integer
    field chk-seller-name    as character
    field chk-seller-code    as integer
    field d-card        as character
    field cli-type      as character
    field cli-code      as integer
    field obj-name      as character
    field hand-discounted as character
    index pi as primary unique
          doc-code
.
define temp-table tt-line no-undo
    field type             as integer
    field num              as integer
    field line-code        as integer
    field curr-code        as integer
    field fr-pay-code      as integer
    field line-name        as character
    field line-name-2      as character
    field qnty             as decimal
    field price            as decimal
    field price-rub        as decimal
    field summ-brutto      as decimal
    field summ-brutto-rub  as decimal
    field qnty-str         as character
    field price-str        as character
    field summ-netto       as decimal
    field summ-netto-rub   as decimal
    field summ-discont     as decimal
    field summ-discont-rub as decimal
    field src              as character
    field pass             as integer
    field ord-chk-num      as character
    field ord-line-num     as integer
    field slip             as character
    field pay-card         as character
    field line-seller-name as character
    field line-seller-code as integer
    field printed          as logical
    field hand-discounted  as character
    field unit-base        as character
    index pi as primary unique
          type
          num
    index by-src
          src
    index by-ord
          ord-chk-num
          ord-line-num
    index by-hand
          hand-discounted
.
define temp-table tt-open-check no-undo
    field doc-code      as character
    field chk-type      as INTEGER
    index pi as primary unique
          doc-code
.
define buffer bufbr_tt-line for tt-line .
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#fr-lib as handle no-undo.
define variable vss-include-info3 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#sb-lib as handle no-undo.
define variable vss-include-info4 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#disp-lib as handle no-undo.
define variable vss-include-info5 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#eventlib as handle no-undo.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#libthpos as handle no-undo .
define temp-table libthpos_cash-desk-attr like ub.cash-desk-attr.
temP-TABLE libthpos_cash-desk-attr:HANDLE:SCHEMA-MARSHAL = "NONE".
define dataset libthpos_params  for libthpos_cash-desk-attr.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info9 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table temp-layout-elem-rule no-undo like ub.layout-elem-rule.
define  temp-table temp-rule-call-param no-undo like ub.rule-call-param
field layout-type as character
field device-type as character
field mode-id as character
field widget-id as character
index pi is unique primary
layout-type
device-type
mode-id
widget-id
param-name
p-index
.
define variable v-serial-code       as char              no-undo .
define variable v-r-b               as character         no-undo .
define variable v-base-code         as integer           no-undo .
define variable v-src               as character         no-undo .
define variable v-src-qnty          as decimal           no-undo .
define variable v-src-price         as decimal           no-undo .
define variable v-src-price-rub     as decimal           no-undo .
define variable v-src-discnt        as decimal           no-undo .
define variable v-src-discnt-rub    as decimal           no-undo .
define variable v-src-sum           as decimal no-undo .
define variable v-src-sum-rub       as decimal no-undo .
define variable v-src-sum-netto     as decimal no-undo .
define variable v-src-sum-netto-rub as decimal no-undo .
define variable v-for-discnt-doc    as decimal no-undo .
define variable v-for-discnt-rubl   as decimal no-undo .
define variable v-for-discnt-r-b    as decimal no-undo .
define variable v-unit-base         as character no-undo .
define variable v-pay-type          as integer  INIT ?   no-undo .
define variable v-curr-num-0        as integer           no-undo .
define variable v-curr-type-0       as integer           no-undo .
define variable v-2-tot-sum         as decimal           no-undo .
define variable v-fr-shift-open     as integer           no-undo .
define variable v-null-summ         as decimal           no-undo .
define variable v-fr-last-shift-num as integer           no-undo .
define variable v-fr-width          as integer           no-undo .
define variable v-fr-width-bold     as integer           no-undo .
define variable v-emul-mode         as logical           no-undo .
define variable v-curr-base-code    as integer           no-undo .
define variable v-cd-base-code      as integer           no-undo .
define variable v-cd-base-name      as character         no-undo .
define variable v-discnt-chk        as decimal           no-undo .
define variable v-fix-summ-pay      as decimal           no-undo .
define variable v-exch-rate         as decimal           no-undo .
define variable v-exch-scales       as decimal           no-undo .
define variable v-cash-rate         as decimal           no-undo .
define variable v-cash-scales       as integer           no-undo .
define variable v-input-time        as integer           no-undo .
define variable v-time-close        as integer           no-undo .
define variable v-cashier           as integer           no-undo .
define variable v-cashier-psn-code  as integer           no-undo .
define variable v-context-serial    as char           no-undo .
define variable v-cd-mode-pre       as character INIT "0"   no-undo .
define variable v-cd-submode-pre    as character INIT "0"   no-undo .
define variable v-cd-mode-user-pre       as character INIT "0"   no-undo .
define variable v-cd-submode-user-pre    as character    no-undo .
define variable v-recalc    as logical      no-undo.
define variable v-d-card            as character no-undo .
define variable v-cli-type          as character no-undo .
define variable v-cli-code          as integer no-undo .
define variable v-obj-name          as character no-undo .
define variable v-aux-mess          as character no-undo .
define variable v-summ-netto        as decimal      no-undo .
define variable v-summ-brutto       as decimal      no-undo .
define variable v-summ-discont      as decimal      no-undo .
define variable v-summ-pay          as decimal      no-undo .
define variable v-summ-netto-rub    as decimal      no-undo .
define variable v-summ-brutto-rub   as decimal      no-undo .
define variable v-summ-discont-rub  as decimal      no-undo .
define variable v-summ-pay-rub      as decimal      no-undo .
define variable v-summ-fr           as decimal      no-undo .
define variable v-sum-for-pay       as decimal      no-undo .
define variable v-pump           as integer no-undo .
define variable v-nozzle-code    as integer no-undo .
define variable v-pl-code        as integer no-undo .
define variable v-pass-gds       as integer no-undo .
define variable v-fbr-depart     as integer no-undo .
define variable v-write-off-code as integer no-undo .
define variable v-num            as integer      no-undo.
define variable v-ord-chk-num    as character no-undo .
define variable v-ord-line-num   as integer no-undo .
define variable v-disc-type    as character   no-undo.
define variable v-rmethod-coeff    as decimal      no-undo.
define variable v-rmethod-type    as character    no-undo.
define variable v-nalc    as integer      no-undo.
define variable v-manual-discnt    as logical      no-undo.
define variable v-salesman-mandatory    as logical      no-undo.
define variable v-customer-display-adv    as character    no-undo.
define variable v-cash-drawer-limit    as decimal      no-undo.
define variable v-cashless-system    as character    no-undo.
define variable v-cash-drawer-open    as logical      no-undo.
define variable v-cash-shift    as logical      no-undo.
define variable v-max-netto    as decimal      no-undo.
define variable v-print-good-code    as logical      no-undo.
define variable v-cliche-lines    as character  no-undo.
define variable v-advert-text    as character   no-undo.
define variable v-cash-drawer-level    as integer      no-undo.
define variable v-customer-display-plug    as logical      no-undo.
define variable v-card-reader-plug    as logical      no-undo.
define variable v-cutter    as logical      no-undo.
define variable v-cash-drawer-plug-port    as integer      no-undo.
define variable v-cash-drawer-plug    as logical      no-undo.
define variable v-cash-drawer-plug-imp    as integer      no-undo.
define variable v-keyboard-type    as character      no-undo.
define variable v-close-good-chk    as logical      no-undo.
define variable v-cp-lst    as character    no-undo.
define variable v-cash-drawer-plug-type   as integer   no-undo .
define variable v-keyboard-layout-id      as character no-undo .
define variable v-customer-display-type   as character no-undo .
define variable v-customer-display-port   as character no-undo .
define variable v-log-level               as integer   INIT -1 no-undo .
define variable v-clear-cash-counter      as LOGICAL   no-undo .
define variable v-qnty-change             as LOGICAL   no-undo .
define variable v-screen-type             as character no-undo .
define variable v-screen-layout-id        as character no-undo .
define variable v-with-context            as LOGICAL   INIT TRUE no-undo .
define variable v-chk-name        as character no-undo .
define variable v-gds-code        as integer no-undo .
define variable v-frpay-code as integer no-undo .
define variable v-pay-names    as character  no-undo.
define variable v-cashier-name    as character    no-undo.
define variable v-disp-msg-1    as character    no-undo.
define variable v-disp-msg-2    as character    no-undo.
define variable v-found-num     as integer      no-undo.
define variable v-found-str     as character      no-undo.
define buffer buf_temp-layout-elem-rule      for temp-layout-elem-rule .
define variable v-doc-prt        as logical     no-undo.
procedure fill-tt :
do
on error undo, return error
:
   run add-cdm in this-procedure ( "0"      , ""                    , "1,2,3,4,5,6", "" ) .
   run add-cdm in this-procedure ( "1"       , "Продажа"             , "0,3,4"      , "" ) .
   run add-cdm in this-procedure ( "2"        , "Возврат"             , "0,3,4"      , "" ) .
   run add-cdm in this-procedure ( "4"      , "Блокировка"          , "0,6"        , "" ) .
   run add-cdm in this-procedure ( "5"       , "Доп. функция"        , "0"          , "" ) .
   run add-cdm in this-procedure ( "6", "Смена закрыта"       , "0"          , "" ) .
   run add-cdm in this-procedure ( "7"        , "Инвентаризация"      , "0,3"        , "" ) .
   run add-cdm in this-procedure ( "8"        , "Чеки МЦ"             , "0,3"        , "" ) .
   run add-cdm in this-procedure ( "9" , "Блокировка"          , "0,6"        , "" ) .
     run add-key-func  in this-procedure ( "0", "0"   , "F1"            , "Товар (F1)"         , "1978"           , YES , "" ) .
     run add-key-func  in this-procedure ( "0", "0"   , "CTRL-S"        , "Выгрузка в XML"       , "export-chk-to-xml"     , NO  , "" ) .
     run add-key-func  in this-procedure ( "0", "0", "-"         , "Дата"          , "set-date"         , YES  , "" ) .
   run add-key-func  in this-procedure ( "0", "0"   , "v-src-input"   , "Код товара"    , "add-sale"         , YES , "" ) .
   run add-key-func  in this-procedure ( "0", "0"   , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "0", "0"   , "b-exit"        , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "0"    , "del"           , "Удалить"       , "del-gds-line"     , YES  , "" ) .
   run add-key-func  in this-procedure ( "1", "0"    , "F1"            , "Товар (F1)"         , "1978"       , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "0"    , "v-src-input"   , "Код товара"    , "add-gds-line"     , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "0"    , "*"             , "Коррекция"     , "2010"     , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "0"    , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "0"    , "b-exit"        , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "0"    , "CTRL-S"        , "Выгрузка в XML"       , "export-chk-to-xml"     , NO  , "" ) .
   run add-key-func  in this-procedure ( "1", "1"  , "b-exit"        , "Выход"         , "pr-esc"           , YES  , "" ) .
   run add-key-func  in this-procedure ( "1", "1"  , "v-src-input"   , "Количество"    , "upd-line"         , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "1"  , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "3" , "b-exit"        , "Выход"         , "pr-esc"           , YES  , "" ) .
   run add-key-func  in this-procedure ( "1", "3" , "v-src-input"   , "Номер карты"   , "input-card"       , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "3" , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "3" , "F1"            , "Карта (F1)"         , "card-select"      , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "2"      , "del"           , "Удалить"       , "del-gds-line"     , YES  , "" ) .
   run add-key-func  in this-procedure ( "1", "2"      , "b-exit"        , "Выход"         , "pr-esc"           , YES  , "" ) .
   run add-key-func  in this-procedure ( "1", "2"      , "F1"            , "Тип опл. (F1)"         , "pay-select"       , no   , "" ) .
   run add-key-func  in this-procedure ( "1", "2"      , "v-src-input"   , "Сумма оплаты"  , "input-pay-sale"   , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "2"      , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "8"   , "b-exit"        , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "8"   , "v-src-input"   , "Код продавца"  , "input-saller"     , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "8"   , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "8"   , "F1"            , "Продавец(F1)"         , "saller-select"    , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "6" , "b-exit"        , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "6" , "v-src-input"   , "Код товара"    , "input-find-str"   , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "6" , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "5"    , "b-exit"        , "Выход"         , "pr-esc"             , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "5"    , "v-src-input"   , "   "       , "input-discont"      , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "5"    , "F1"             , "Тип скидки (F1)"         , "disc-type-select"       , NO  , "" ) .
   run add-key-func  in this-procedure ( "1", "5"  , "ESC"           , "Выход"         , "pr-esc"             , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "4"  , "b-exit"          , "Выход"        , "pr-esc"             , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "4"  , "v-src-input"     , "   "      , "input-discont"      , YES , "" ) .
   run add-key-func  in this-procedure ( "1", "4"          , "F1"             , "Тип скидки (F1)"         , "disc-type-select"       , NO  , "" ) .
   run add-key-func  in this-procedure ( "1", "4"  , "ESC"             , "Выход"        , "pr-esc"             , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "0"     , "F1"            , "Товар (F1)"         , "1978"       , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "0"     , "v-src-input"   , "Код товара"    , "add-gds-line"     , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "0"     , "*"             , "Коррекция"     , "2010"     , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "0"     , "del"           , "Удалить"       , "del-gds-line"     , YES  , "" ) .
   run add-key-func  in this-procedure ( "2", "0"     , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "0"     , "b-exit"        , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "0"     , "CTRL-S"        , "Выгрузка в XML"       , "export-chk-to-xml"     , NO  , "" ) .
   run add-key-func  in this-procedure ( "2", "1"   , "v-src-input"   , "Количество" , "upd-line"            , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "1"   , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "1"   , "b-exit"        , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "7"     , "v-src-input"   , "Цена"          , "input-price"      , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "7"     , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "7"     , "b-exit"        , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "2"       , "v-src-input"   , "Сумма оплаты"  , "input-pay-sale"   , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "2"       , "F1"            , "Тип платежа(F1)"         , "pay-select"       , no  , "" ) .
   run add-key-func  in this-procedure ( "2", "2"       , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "2"       , "b-exit"        , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "6"  , "v-src-input"   , "Код товара"    , "input-find-str"   , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "6"  , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "6"  , "b-exit"        , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "3" , "b-exit"        , "Выход"         , "pr-esc"           , YES  , "" ) .
   run add-key-func  in this-procedure ( "2", "3" , "v-src-input"   , "Номер карты"   , "input-card"       , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "3" , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "3" , "F1"            , "Карта (F1)"         , "card-select"      , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "8"   , "b-exit"        , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "8"   , "v-src-input"   , "Код продавца"  , "input-saller"     , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "8"   , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "2", "8"   , "F1"            , "Продавец(F1)"         , "saller-select"    , YES , "" ) .
   run add-key-func  in this-procedure ( "9", "0"   , "b-exit"   , "Выход"         , "pr-esc"         , YES  , "" ) .
   run add-key-func  in this-procedure ( "9", "0"   , "ESC"      , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "4", "0"   , "F12"           , "Дата"          , "set-date"         , YES   , "" ) .
   run add-key-func  in this-procedure ( "4", "0"   , "b-exit"        , "Выход"         , "pr-esc"           , YES  , "sht-cls" ) .
   run add-key-func  in this-procedure ( "4", "0"   , "ESC"           , "Выход"         , "pr-esc"           , YES  , "sht-cls" ) .
   run add-key-func  in this-procedure ( "5", "0"    , "b-exit"        , "Выход"         , "pr-esc"         , YES  , "" ) .
   run add-key-func  in this-procedure ( "5", "0"    , "v-src-input"   , "Ввод"          , "input-adv"        , YES , "" ) .
   run add-key-func  in this-procedure ( "5", "0"     , "ESC"          , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "6", "0", "v-src-input", "Код товара"    , "add-sale"         , YES , "" ) .
   run add-key-func  in this-procedure ( "6", "0", "ESC"        , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "6", "0", "b-exit"     , "Выход"         , "pr-esc"         , YES  , "" ) .
   run add-key-func  in this-procedure ( "8", "0"          , "F1"            , "Тип чека (F1)"         , "wth-type-select"       , YES  , "" ) .
   run add-key-func  in this-procedure ( "8", "0"          , "v-src-input"   , "   "         , "wait-wth-type"       , NO , "" ) .
   run add-key-func  in this-procedure ( "8", "0"          , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "8", "0"          , "b-exit"        , "Выход"         , "pr-esc"         , YES  , "" ) .
   run add-key-func  in this-procedure ( "8", "0"          , "del"           , "Удалить"       , "del-gds-line"     , YES  , "" ) .
   run add-key-func  in this-procedure ( "8", "2"       , "v-src-input"   , "Сумма"         , "input-summ"       , YES , "" ) .
   run add-key-func  in this-procedure ( "8", "2"       , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "8", "2"       , "b-exit"        , "Выход"         , "pr-esc"         , YES  , "" ) .
   run add-key-func  in this-procedure ( "8", "2"       , "del"           , "Удалить"       , "del-gds-line"     , YES  , "" ) .
   run add-key-func  in this-procedure ( "7", "0"    , "F1"             , "Товар (F1)"         , "1978"       , YES  , "" ) .
   run add-key-func  in this-procedure ( "7", "0"    , "*"              , "Коррекция"     , "2010"     , YES , "" ) .
   run add-key-func  in this-procedure ( "7", "0"    , "CURSOR-UP"      , "Вверх"         , "cr-down"          , NO  , "" ) .
   run add-key-func  in this-procedure ( "7", "0"    , "CURSOR-DOWN"    , "Вниз"          , "cr-up"            , NO  , "" ) .
   run add-key-func  in this-procedure ( "7", "0"    , "v-src-input"    , "Код товара"    , "add-gds-line"     , YES  , "" ) .
   run add-key-func  in this-procedure ( "7", "0"    , "del"            , "Удалить"       , "del-gds-line"     , yes  , "" ) .
   run add-key-func  in this-procedure ( "7", "0"    , "ESC"            , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "7", "0"    , "b-exit"         , "Выход"         , "pr-esc"         , YES  , "" ) .
   run add-key-func  in this-procedure ( "7", "1"  , "v-src-input"   , "Изменение количества" , "upd-line"   , YES , "" ) .
   run add-key-func  in this-procedure ( "7", "1"  , "ESC"           , "Выход"          , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "7", "1"  , "b-exit"        , "Выход"          , "pr-esc"         , YES  , "" ) .
   run add-key-func  in this-procedure ( "7", "6" , "v-src-input"   , "Код товара"     , "input-find-str"   , YES , "" ) .
   run add-key-func  in this-procedure ( "7", "6" , "ESC"           , "Выход"          , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( "7", "6" , "b-exit"        , "Выход"          , "pr-esc"         , YES  , "" ) .
end.
end procedure.
procedure add-cdm :
define input parameter p-cd-mode as character          no-undo.
define input parameter p-name as character        no-undo.
define input parameter p-next as character        no-undo.
define input parameter p-btns as character        no-undo.
do
on error undo, return error
:
   create tt-cdm.
   assign
      tt-cdm.cd-mode       = p-cd-mode
      tt-cdm.cdm-name       = p-name
      tt-cdm.cdm-next-modes = p-next
      tt-cdm.cdm-btns       = p-btns
   .
end.
end procedure.
procedure add-key-func :
define input parameter p-cdm         as character        no-undo .
define input parameter p-cdsm        as character        no-undo .
define input parameter p-name        as character        no-undo .
define input parameter p-label       as character        no-undo .
define input parameter p-func        as character        no-undo .
define input parameter p-cng-context as LOGICAL          no-undo .
define input parameter p-func-param  as character        no-undo .
do
on error undo, return error
:
   create tt-func-key.
   assign
      tt-func-key.cd-mode     = p-cdm
      tt-func-key.cd-submode  = p-cdsm
      tt-func-key.key-name    = p-name
      tt-func-key.key_label   = p-label
      tt-func-key.key_func    = p-func
      tt-func-key.cng-context = p-cng-context
      tt-func-key.func-param  = p-func-param
   .
end.
end procedure.
procedure shift-open :
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   if not v-emul-mode
      then do:
define variable vss-include-info14 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-shtop in g#fr-lib
    ( output       p-message
    , output       p-ok
    ) no-error .
end.
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
      end.
   end.
   else do:
      assign
         p-ok = TRUE
      .
   end.
end.
end procedure.
procedure 1989 :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
define variable v-chk-fr-num    as character    no-undo.
define variable v-doc-code      as character no-undo .
define variable v-reg-value    as character    no-undo.
define variable v-reg-name     as character    no-undo.
define variable glog as logical no-undo .
do
on error undo, return error
:
   if p-cd-mode = "0"
   and p-cd-submode = "0"
   then do:
     message
     substitute("Вы действительно хотите сделать Z-отчет?")
     view-as alert-box question buttons yes-no update glog.
     if not glog then return.
   end.
define variable vss-include-info15 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  78
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
   run adm/chk-pass.w   ( input parparentproc
                        , input v-cntxt-userid
                        , input v-cntxt-db-num
                        , input "actn_ibsthpos-z-rep"
                        , input FALSE
                        , output p-message
                        , output p-ok
                        ) .
   if not p-ok
   then do:
define variable vss-include-info16 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
      return.
   end.
   define variable v-fr-mode            as integer      no-undo.
   define variable v-fr-time            as integer      no-undo.
   define variable v-fr-date            as date         no-undo.
   define variable v-fr-last-shift-date as date         no-undo.
   define variable v-fr-lic             as character    no-undo.
   define variable v-fr-serial          as char    no-undo.
   if not v-emul-mode
   then do:
define variable vss-include-info17 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-ctrl in g#fr-lib
    ( input        v-cash-drawer-open
    , output       p-message
    , output       p-ok
    , output       v-fr-mode
    , output       v-fr-time
    , output       v-fr-date
    , output       v-fr-last-shift-date
    , output       v-fr-last-shift-num
    , output       v-fr-lic
    , output       v-fr-shift-open
    , output       v-fr-serial
    ) no-error .
end.
      if v-fr-shift-open = 0
      or  v-fr-mode = 4
      then do:
         assign
            p-message = "Смена закрыта. Отчет снять нельзя."
            p-ok = No
         .
         return .
      end.
   end.
   run 2001 in this-procedure ( input-output p-cd-mode
                              , input-output p-cd-submode
                              , output p-message
                              , output p-ok
                              ) .
   if not p-ok
   then do:
define variable vss-include-info18 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
      return.
   end.
   if v-clear-cash-counter
   then do:
      if  v-fr-shift-open = 24
      then do:
         message
            'Истекли 24 часа открытой смены. Инкассацию сделать нельзя.'
            skip 'Счетчик наличности будет обнулен без чека инкассации'
         view-as alert-box information.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_clear-cash-counter in g#libthpos
    .
      end.
      else do:
         assign
            p-cd-mode    = "8"
         .
         run chk-inc-open  ( input-output p-cd-mode
                           , input-output p-cd-submode
                           , output p-message
                           , output p-ok
                           ) .
         if not p-ok
         then do:
define variable vss-include-info20 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
define variable vss-include-info21 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-get-reg in g#fr-lib
    ( input       'cash':U
    , input       241
    , output      v-reg-value
    , output      v-reg-name
    , output      p-message
    , output      p-ok
    ) no-error .
end.
         if error-status:error
         then do:
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info22 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
         else do:
            assign
               v-src = v-reg-value
            .
         end.
         run input-summ in this-procedure ( input-output p-cd-mode
                                          , input-output p-cd-submode
                                          , output p-message
                                          , output p-ok
                                          ) .
         if not p-ok
         then do:
define variable vss-include-info23 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_clear-cash-counter in g#libthpos
    .
      end.
   end.
   if not v-emul-mode
      then do:
define variable vss-include-info25 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-shtcl in g#fr-lib
    ( output       p-message
    , output       p-ok
    ) no-error .
end.
      if error-status:error
      OR not p-ok
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
define variable vss-include-info26 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
   end.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_create-chk-doc in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  INTEGER('12':U)
  ,input  v-cashier
  ,input  v-cashier-psn-code
  ,output v-doc-code
  ,output v-exch-rate
  ,output v-exch-scales
  ,output v-cash-rate
  ,output v-cash-scales
  ) no-error .
   if error-status:error
   then do:
      assign
         p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
define variable vss-include-info28 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
      return.
   end.
   if  not v-emul-mode
   then do:
define variable vss-include-info29 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-get-reg in g#fr-lib
    ( input       'cash':U
    , input       0
    , output      v-reg-value
    , output      v-reg-name
    , output      p-message
    , output      p-ok
    ) no-error .
end.
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
define variable vss-include-info30 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
      else do:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_cfr in g#libthpos
  (input  v-doc-code
  ,input  '17':U
  ,input  'Sales':U
  ,input  DECIMAL(v-reg-value)
  ,input  0
  ) no-error .
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info32 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
      end.
define variable vss-include-info33 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-get-reg in g#fr-lib
    ( input       'cash':U
    , input       64
    , output      v-reg-value
    , output      v-reg-name
    , output      p-message
    , output      p-ok
    ) no-error .
end.
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
define variable vss-include-info34 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
      else do:
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_cfr in g#libthpos
  (input  v-doc-code
  ,input  '17':U
  ,input  'SaleDisk':U
  ,input  DECIMAL(v-reg-value)
  ,input  0
  ) no-error .
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info36 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
      end.
define variable vss-include-info37 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-get-reg in g#fr-lib
    ( input       'cash':U
    , input       68
    , output      v-reg-value
    , output      v-reg-name
    , output      p-message
    , output      p-ok
    ) no-error .
end.
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
define variable vss-include-info38 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
      else do:
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_cfr in g#libthpos
  (input  v-doc-code
  ,input  '17':U
  ,input  'SaleUpLift':U
  ,input  DECIMAL(v-reg-value)
  ,input  0
  ) no-error .
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info40 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
      end.
define variable vss-include-info41 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-get-reg in g#fr-lib
    ( input       'cash':U
    , input       72
    , output      v-reg-value
    , output      v-reg-name
    , output      p-message
    , output      p-ok
    ) no-error .
end.
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
define variable vss-include-info42 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
      else do:
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_cfr in g#libthpos
  (input  v-doc-code
  ,input  '17':U
  ,input  'PayCash':U
  ,input  DECIMAL(v-reg-value)
  ,input  0
  ) no-error .
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info44 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
      end.
define variable vss-include-info45 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-get-reg in g#fr-lib
    ( input       'cash':U
    , input       76
    , output      v-reg-value
    , output      v-reg-name
    , output      p-message
    , output      p-ok
    ) no-error .
end.
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
define variable vss-include-info46 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
      else do:
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_cfr in g#libthpos
  (input  v-doc-code
  ,input  '17':U
  ,input  'PayCoup':U
  ,input  DECIMAL(v-reg-value)
  ,input  0
  ) no-error .
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info48 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
      end.
define variable vss-include-info49 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-get-reg in g#fr-lib
    ( input       'cash':U
    , input       80
    , output      v-reg-value
    , output      v-reg-name
    , output      p-message
    , output      p-ok
    ) no-error .
end.
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
define variable vss-include-info50 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
      else do:
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_cfr in g#libthpos
  (input  v-doc-code
  ,input  '17':U
  ,input  'PayCard':U
  ,input  DECIMAL(v-reg-value)
  ,input  0
  ) no-error .
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info52 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
      end.
define variable vss-include-info53 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-get-reg in g#fr-lib
    ( input       'cash':U
    , input       84
    , output      v-reg-value
    , output      v-reg-name
    , output      p-message
    , output      p-ok
    ) no-error .
end.
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
define variable vss-include-info54 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
      else do:
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_cfr in g#libthpos
  (input  v-doc-code
  ,input  '17':U
  ,input  'PayAux':U
  ,input  DECIMAL(v-reg-value)
  ,input  0
  ) no-error .
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info56 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
      end.
define variable vss-include-info57 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-get-reg in g#fr-lib
    ( input       'cash':U
    , input       2
    , output      v-reg-value
    , output      v-reg-name
    , output      p-message
    , output      p-ok
    ) no-error .
end.
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
define variable vss-include-info58 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
      else do:
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_cfr in g#libthpos
  (input  v-doc-code
  ,input  '17':U
  ,input  'Returns':U
  ,input  DECIMAL(v-reg-value)
  ,input  0
  ) no-error .
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info60 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
      end.
define variable vss-include-info61 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-get-reg in g#fr-lib
    ( input       'cash':U
    , input       66
    , output      v-reg-value
    , output      v-reg-name
    , output      p-message
    , output      p-ok
    ) no-error .
end.
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
define variable vss-include-info62 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
      else do:
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_cfr in g#libthpos
  (input  v-doc-code
  ,input  '17':U
  ,input  'RetDisc':U
  ,input  DECIMAL(v-reg-value)
  ,input  0
  ) no-error .
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info64 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
      end.
define variable vss-include-info65 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-get-reg in g#fr-lib
    ( input       'cash':U
    , input       70
    , output      v-reg-value
    , output      v-reg-name
    , output      p-message
    , output      p-ok
    ) no-error .
end.
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
define variable vss-include-info66 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
      else do:
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_cfr in g#libthpos
  (input  v-doc-code
  ,input  '17':U
  ,input  'RetUpLift':U
  ,input  DECIMAL(v-reg-value)
  ,input  0
  ) no-error .
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info68 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
      end.
define variable vss-include-info69 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-get-reg in g#fr-lib
    ( input       'cash':U
    , input       74
    , output      v-reg-value
    , output      v-reg-name
    , output      p-message
    , output      p-ok
    ) no-error .
end.
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
define variable vss-include-info70 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
      else do:
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_cfr in g#libthpos
  (input  v-doc-code
  ,input  '17':U
  ,input  'RetCash':U
  ,input  DECIMAL(v-reg-value)
  ,input  0
  ) no-error .
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info72 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
      end.
define variable vss-include-info73 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-get-reg in g#fr-lib
    ( input       'cash':U
    , input       78
    , output      v-reg-value
    , output      v-reg-name
    , output      p-message
    , output      p-ok
    ) no-error .
end.
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
define variable vss-include-info74 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
      else do:
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_cfr in g#libthpos
  (input  v-doc-code
  ,input  '17':U
  ,input  'RetCoup':U
  ,input  DECIMAL(v-reg-value)
  ,input  0
  ) no-error .
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info76 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
      end.
define variable vss-include-info77 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-get-reg in g#fr-lib
    ( input       'cash':U
    , input       82
    , output      v-reg-value
    , output      v-reg-name
    , output      p-message
    , output      p-ok
    ) no-error .
end.
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
define variable vss-include-info78 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
      else do:
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_cfr in g#libthpos
  (input  v-doc-code
  ,input  '17':U
  ,input  'RetCard':U
  ,input  DECIMAL(v-reg-value)
  ,input  0
  ) no-error .
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info80 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
      end.
define variable vss-include-info81 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-get-reg in g#fr-lib
    ( input       'cash':U
    , input       86
    , output      v-reg-value
    , output      v-reg-name
    , output      p-message
    , output      p-ok
    ) no-error .
end.
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
define variable vss-include-info82 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
      else do:
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_cfr in g#libthpos
  (input  v-doc-code
  ,input  '17':U
  ,input  'RetAux':U
  ,input  DECIMAL(v-reg-value)
  ,input  0
  ) no-error .
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info84 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
      end.
define variable vss-include-info85 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-get-reg in g#fr-lib
    ( input       'cash':U
    , input       242
    , output      v-reg-value
    , output      v-reg-name
    , output      p-message
    , output      p-ok
    ) no-error .
end.
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
define variable vss-include-info86 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
      else do:
define variable vss-include-info87 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_cfr in g#libthpos
  (input  v-doc-code
  ,input  '17':U
  ,input  'InCash':U
  ,input  DECIMAL(v-reg-value)
  ,input  0
  ) no-error .
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info88 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
      end.
define variable vss-include-info89 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-get-reg in g#fr-lib
    ( input       'cash':U
    , input       243
    , output      v-reg-value
    , output      v-reg-name
    , output      p-message
    , output      p-ok
    ) no-error .
end.
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
define variable vss-include-info90 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
      else do:
define variable vss-include-info91 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_cfr in g#libthpos
  (input  v-doc-code
  ,input  '17':U
  ,input  'OutCash':U
  ,input  DECIMAL(v-reg-value)
  ,input  0
  ) no-error .
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info92 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
      end.
   end.
   else do:
      assign
         p-ok = TRUE
      .
   end.
define variable vss-include-info93 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_getcheck in g#libthpos
  (input  v-doc-code
  ,input  no
  ) no-error .
   if error-status:error then do:
      assign
         p-message = substitute("gch &1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
define variable vss-include-info94 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
      return.
   end.
define variable vss-include-info95 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_close-check in g#libthpos
  (input  v-doc-code
  ,input  v-fr-last-shift-num
  ) no-error .
   if error-status:error then do:
      assign
         p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = TRUE
      .
define variable vss-include-info96 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  80
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
      return.
   end.
define variable vss-include-info97 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  78
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
   run clear-tt-chk in this-procedure.
   assign
      p-message    = "Z-отчет снят"
      p-ok         = true
   .
end.
end procedure.
procedure chk-sale-open :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   run clear-tt-chk in this-procedure.
   run chk-open   ( input integer('1':U)
                  , INPUt-OUTPUT p-cd-mode
                  , INPUt-output p-cd-submode
                  , output p-message
                  , output p-ok
                  ) .
   if p-ok
   then do:
      assign
         p-message    = "Чек продажи открыт"
         p-cd-mode    = "1"
         p-cd-submode = "0"
      .
   end.
end.
end procedure.
procedure chk-open :
define input         parameter p-chk-type    as INTEGER        no-undo.
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
define variable v-doc-code      as character no-undo .
do
on error undo, return error
:
   case p-cd-mode:
      WHEN "0" OR
      WHEN "6"
      then do:
define variable vss-include-info98 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_create-chk-doc in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  p-chk-type
  ,input  v-cashier
  ,input  v-cashier-psn-code
  ,output v-doc-code
  ,output v-exch-rate
  ,output v-exch-scales
  ,output v-cash-rate
  ,output v-cash-scales
  ) no-error .
         if error-status:error
         then do:
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            return.
         end.
         CREATE tt-head-check.
         assign
            tt-head-check.doc-code    = v-doc-code
            tt-head-check.exch-rate   = v-exch-rate
            tt-head-check.exch-scales = v-exch-scales
            tt-head-check.cash-rate   = if v-r-b = 'base':U then v-cash-rate    else 1
            tt-head-check.cash-scales = if v-r-b = 'base':U then v-cash-scales  else 1
            tt-head-check.chk-type    = p-chk-type
            p-cd-submode = "0"
            p-ok = TRUE
         .
         case STRING(p-chk-type):
         WHEN '1':U then do:
            assign
               p-cd-mode    = "1"
            .
         end.
         WHEN '6':U then do:
            assign
               p-cd-mode    = "2"
            .
         end.
         WHEN '11':U then do:
            assign
               p-cd-mode    = "7"
            .
         end.
         OTHERWISE DO:
         end.
         end case.
      end.
      WHEN "8"
      then do:
define variable vss-include-info99 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_create-chk-title in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  p-chk-type
  ,input  v-cashier
  ,input  v-cashier-psn-code
  ,output v-doc-code
  ,output v-exch-rate
  ,output v-exch-scales
  ,output v-cash-rate
  ,output v-cash-scales
  ) no-error .
         if error-status:error
         then do:
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            return.
         end.
         CREATE tt-head-check.
         assign
            tt-head-check.doc-code    = v-doc-code
            tt-head-check.exch-rate   = v-exch-rate
            tt-head-check.exch-scales = v-exch-scales
            tt-head-check.cash-rate   = if v-r-b = 'base':U then v-cash-rate    else 1
            tt-head-check.cash-scales = if v-r-b = 'base':U then v-cash-scales  else 1
            tt-head-check.chk-type    = p-chk-type
            p-ok = TRUE
         .
      end.
      OTHERWISE DO:
      end.
   end case.
end.
end procedure.
procedure 1982 :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
define buffer buf_tt-line     for tt-line .
define variable v-chk-fr-num     as character    no-undo .
define variable v-price-rub      as decimal      no-undo .
define variable v-disc-rub       as decimal      no-undo .
define variable v-disc-rub-total as decimal      no-undo .
define variable v-print-line     as character    no-undo .
define variable v-rest-summ      as decimal      no-undo .
define variable v-summ-1  as decimal      no-undo.
define variable v-summ-2  as decimal      no-undo.
define variable v-summ-3  as decimal      no-undo.
define variable v-summ-4  as decimal      no-undo.
do
on error undo, return error
:
  define variable v-fr-mode            as integer      no-undo.
  define variable v-fr-time            as integer      no-undo.
  define variable v-fr-date            as date         no-undo.
  define variable v-fr-last-shift-date as date         no-undo.
  define variable v-fr-lic             as character    no-undo.
  define variable v-fr-serial          as char    no-undo.
define variable vss-include-info100 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-ctrl in g#fr-lib
    ( input        v-cash-drawer-open
    , output       p-message
    , output       p-ok
    , output       v-fr-mode
    , output       v-fr-time
    , output       v-fr-date
    , output       v-fr-last-shift-date
    , output       v-fr-last-shift-num
    , output       v-fr-lic
    , output       v-fr-shift-open
    , output       v-fr-serial
    ) no-error .
end.
  if  not p-ok
  AND v-fr-shift-open = 24
  then do:
    assign
    p-message = "Истекли 24 часа открытой смены. Чек можно только отложить."
    p-ok = FALSE
    .
    return.
  end.
  if  ABS( v-summ-brutto-rub  ) > v-summ-fr
  AND p-cd-mode = "2"
  AND not v-emul-mode
  then do:
    assign
    p-message = substitute("Суммы в ДЯ &1 недостаточно для выплаты", v-summ-fr)
    .
    return.
  end.
  find tt-head-check .
define variable vss-include-info101 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  63
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
  assign
  v-disc-rub-total = 0
  .
  assign
  v-rest-summ = ?
  .
  define variable v-first-line    as character    no-undo.
  define variable v-chk-num    as character    no-undo.
  assign
  v-summ-1 = 0
  v-summ-2 = 0
  v-summ-3 = 0
  v-summ-4 = 0
   .
  for each  buf_tt-line
      where buf_tt-line.type = 1
      :
    case buf_tt-line.fr-pay-code :
      WHEN 1 then do:
        assign
        v-summ-1 = v-summ-1 + if p-cd-mode = "2" then - buf_tt-line.summ-netto else buf_tt-line.summ-netto
        .
      end.
      WHEN 2 then do:
        assign
        v-summ-2 = v-summ-2 + if p-cd-mode = "2" then - buf_tt-line.summ-netto else buf_tt-line.summ-netto
        .
      end.
      WHEN 3 then do:
        assign
        v-summ-3 = v-summ-3 + if p-cd-mode = "2" then - buf_tt-line.summ-netto else buf_tt-line.summ-netto
        .
      end.
      WHEN 4 then do:
        assign
        v-summ-4 = v-summ-4 + if p-cd-mode = "2" then - buf_tt-line.summ-netto else buf_tt-line.summ-netto
        .
      end.
      OTHERWISE DO:
      end.
    end case.
  end.
  if  v-summ-netto-rub < v-summ-pay-rub
  AND ((v-summ-pay-rub - v-summ-netto-rub) > v-summ-1)
  then do:
    if (tt-head-check.chk-type = integer('6':U))
    then do:
      assign
      p-message = "В возврате запрещена сдача"
      p-ok      = FALSE
      .
      return.
    end.
    assign
    p-message = substitute("Сумма сдачи (&1) в чеке превышает сумму платежей (&2) с кодом в ФР=1, на которые сдача разрешена"
                          , (v-summ-pay-rub - v-summ-netto-rub)
                          , v-summ-1
                          )
    p-ok      = TRUE
    .
    return.
  end.
  run rest-back in this-procedure ( INPUT-output v-rest-summ, output p-message, output p-ok) .
  if not p-ok
  then do:
    return.
  end.
  define variable v-st-r-b as decimal no-undo .
  define variable v-st-rubl as decimal no-undo .
  define variable v-st-base as decimal no-undo .
  define variable v-tot-doc as decimal no-undo .
  define variable v-netto as decimal no-undo .
  define variable v-netto-rubl as decimal no-undo .
  define variable v-netto-base as decimal no-undo .
  define variable v-all-discnt as decimal no-undo .
  define variable v-all-discnt-rubl as decimal no-undo .
  define variable v-all-discnt-base as decimal no-undo .
  define variable v-pay-disc    as decimal      no-undo.
  define variable v-tot-disc    as decimal      no-undo.
  define variable v-err-disc    as decimal      no-undo.
define variable vss-include-info102 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_sub-total in g#libthpos
  (input  tt-head-check.doc-code
  ,input  ''
  ,output p-ok
  ,input-output v-st-r-b
  ,input-output v-st-rubl
  ,input-output v-st-base
  ,input-output v-tot-doc
  ,input-output v-discnt-chk
  ,output v-netto
  ,output v-netto-rubl
  ,output v-netto-base
  ,output v-all-discnt
  ,output v-all-discnt-rubl
  ,output v-all-discnt-base
  ) no-error .
  assign
  v-summ-discont-rub = v-all-discnt-rubl
  v-summ-netto-rub   = ABS(v-netto-rubl)
  .
  define variable v-integer   as integer      no-undo.
  define variable v-character as character    no-undo.
  define variable v-decimal   as decimal      no-undo.
  define variable v-logical   as logical      no-undo.
  define variable v-date    as date         no-undo.
  define variable v-handle    as handle       no-undo.
  define variable v-cont    as integer    no-undo.
  define variable v-data-type    as character    no-undo.
define variable vss-include-info103 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-context-property in g#libthpos
  (input  2
  ,input  'pay-discnt-rubl'
  ,output v-character
  ,output v-date
  ,output v-pay-disc
  ,output v-integer
  ,output v-logical
  ,output v-handle
  ,output v-data-type
  ,output p-ok
  ) no-error .
  if error-status:error
  OR not p-ok
  then do:
    assign
    p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
    p-ok = FALSE
    .
    return .
  end.
define variable vss-include-info104 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-context-property in g#libthpos
  (input  2
  ,input  'tot-discnt'
  ,output v-character
  ,output v-date
  ,output v-tot-disc
  ,output v-integer
  ,output v-logical
  ,output v-handle
  ,output v-data-type
  ,output p-ok
  ) no-error .
  if error-status:error
  OR not p-ok
  then do:
    assign
    p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
    p-ok = FALSE
    .
    return .
  end.
define variable vss-include-info105 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_getcheck in g#libthpos
  (input  tt-head-check.doc-code
  ,input  no
  ) no-error .
  if error-status:error then do:
    if v-rest-summ > 0
    then do:
      run del-rest (output p-message, output p-ok) .
    end.
    assign
    p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
    p-ok = FALSE
    .
define variable vss-include-info106 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  65
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
    return.
  end.
  for each  buf_tt-line
      where buf_tt-line.type = 0
        AND buf_tt-line.printed = FALSE
      :
    case tt-head-check.chk-type:
      WHEN integer('1':U)
      then do:
        if not v-emul-mode
        then do:
          assign
          v-price-rub = buf_tt-line.price-rub
          v-disc-rub  = - buf_tt-line.summ-discont-rub
          v-disc-rub-total = v-disc-rub-total - v-disc-rub
          .
          run str-fix-width ( input (if v-print-good-code then STRING(buf_tt-line.src) + " " else "":U) + buf_tt-line.line-name
                            , input "":U
                            , input v-fr-width
                            , YES
                            , output v-print-line
                            , output p-message
                            , output p-ok
                            ) .
define variable vss-include-info107 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-add-sale in g#fr-lib
    ( input       '':U
    , input       v-print-line
    , input       v-price-rub
    , input       buf_tt-line.qnty
    , input       buf_tt-line.unit-base
    , input       v-d-card
    , input       v-disc-rub
    , output      p-message
    , output      p-ok
    ) no-error .
end.
          if error-status:error
          then do:
            if v-rest-summ > 0
            then do:
              run del-rest (output p-message, output p-ok) .
            end.
            assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
            .
define variable vss-include-info108 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  65
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
          end.
        end.
        else do:
          assign
          p-ok = TRUE
                .
        end.
      end.
      WHEN integer('6':U)
      then do:
        if not v-emul-mode
        then do:
          assign
          v-price-rub      =  buf_tt-line.price-rub
          v-disc-rub       = - buf_tt-line.summ-discont-rub
          v-disc-rub-total = v-disc-rub-total - v-disc-rub
          .
          run str-fix-width ( input (if v-print-good-code then STRING(buf_tt-line.src) + " " else "":U) + buf_tt-line.line-name
                            , input "":U
                            , input v-fr-width
                            , YES
                            , output v-print-line
                            , output p-message
                            , output p-ok
                            ) .
define variable vss-include-info109 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-add-ret in g#fr-lib
    ( input       '':U
    , input       v-print-line
    , input       v-price-rub
    , input       buf_tt-line.qnty
    , input       buf_tt-line.unit-base
    , input       v-d-card
    , input       v-disc-rub
    , output      p-message
    , output      p-ok
    ) no-error .
end.
          if error-status:error
          then do:
            if v-rest-summ > 0
            then do:
              run del-rest (output p-message, output p-ok) .
            end.
            assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
            .
define variable vss-include-info110 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  65
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
            return .
          end.
        end.
        else do:
          assign
          p-ok = TRUE
          .
        end.
      end.
      OTHERWISE DO:
      end.
    end case.
    assign
    buf_tt-line.printed = TRUE
    .
  end.
  if not v-emul-mode
  then do:
    define variable v-dsk-tot-name    as character    no-undo.
    assign
    v-dsk-tot-name       = "Скидки на тип платежа"
    .
    if v-pay-disc <> 0
    then do:
define variable vss-include-info111 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-discount in g#fr-lib
    ( input       v-pay-disc
    , input       v-dsk-tot-name
    , output      p-message
    , output      p-ok
    )  .
end.
    end.
  end.
  if not v-emul-mode
  then do:
    assign
    v-dsk-tot-name       = "Скидка на итог"
    .
    if v-tot-disc <> 0
    then do:
define variable vss-include-info112 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-discount in g#fr-lib
    ( input       v-tot-disc
    , input       v-dsk-tot-name
    , output      p-message
    , output      p-ok
    )  .
end.
    end.
    define variable v-fr-summ    as decimal      no-undo.
    if lookup(string(tt-head-check.chk-type), '14,15,16,36,,17,11,12,13,40,114,115,116,117,111,112,136,,113,8,108,208,2,3,4,5,7':U) = 0 then do:
define variable vss-include-info113 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-subtotal-without-print in g#fr-lib
    ( output      v-fr-summ
    , output      p-message
    , output      p-ok
    ) no-error .
end.
      if error-status:error
      or not p-ok
      then do:
        if v-rest-summ > 0
        then do:
          run del-rest (output p-message, output p-ok) .
        end.
        assign
        p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
        p-ok = FALSE
        .
define variable vss-include-info114 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  65
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
        return .
      end.
    end.
  end.
  assign
  v-rest-summ = if v-rest-summ = ? then 0 else v-rest-summ
  v-err-disc = (v-fr-summ + v-rest-summ - ABS( v-summ-1 + v-summ-2 + v-summ-3 + v-summ-4 ))
  .
   if not v-emul-mode
   then do:
    if lookup(string(tt-head-check.chk-type), '14,15,16,36,,17,11,12,13,40,114,115,116,117,111,112,136,,113,8,108,208,2,3,4,5,7':U) = 0 then do:
      if v-err-disc > 0
      then do:
        assign
        v-dsk-tot-name       = "Скидка на округление"
        .
define variable vss-include-info115 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-discount in g#fr-lib
    ( input       v-err-disc
    , input       v-dsk-tot-name
    , output      p-message
    , output      p-ok
    )  .
end.
      end.
      else do:
        if v-err-disc < 0
        then do:
          assign
          v-dsk-tot-name       = "Надбавка на округление"
          .
define variable vss-include-info116 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-discount in g#fr-lib
    ( input       v-err-disc
    , input       v-dsk-tot-name
    , output      p-message
    , output      p-ok
    )  .
end.
        end.
      end.
    end.
  end.
  if not v-emul-mode
  AND tt-head-check.d-card <> "":U
  then do:
    assign
    v-first-line = substitute("Карта &1", tt-head-check.d-card)
    .
define variable vss-include-info117 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-print-str in g#fr-lib
    ( input       v-first-line
    , output      p-message
    , output      p-ok
    ) no-error .
end.
    if error-status:error then do:
      if v-rest-summ > 0
      then do:
        run del-rest (output p-message, output p-ok) .
      end.
      assign
      p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
      p-ok = FALSE
      .
define variable vss-include-info118 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  0
    , input  '':U
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  67
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
      return.
    end.
    assign
    v-first-line = "":U
    .
define variable vss-include-info119 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-print-str in g#fr-lib
    ( input       tt-head-check.obj-name
    , output      p-message
    , output      p-ok
    ) no-error .
end.
    if error-status:error then do:
      if v-rest-summ > 0
      then do:
        run del-rest (output p-message, output p-ok) .
      end.
      assign
      p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
      p-ok = FALSE
      .
define variable vss-include-info120 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  0
    , input  '':U
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  67
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
      return.
    end.
  end.
  if not v-emul-mode
  then do:
    define variable v-card    as character    no-undo.
    define variable v-rest-summ-2    as decimal      no-undo.
    case tt-head-check.chk-type:
      WHEN integer('1':U) OR
      WHEN integer('6':U)
      then do:
define variable vss-include-info121 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-chkcl in g#fr-lib
    (
      input       v-summ-1
    , input       v-summ-2
    , input       v-summ-3
    , input       v-summ-4
    , input       tt-head-check.d-card
    , output      v-chk-fr-num
    , output      v-rest-summ-2
    , output      p-message
    , output      p-ok
    ) no-error .
end.
        if error-status:error
        OR not p-ok
        then do:
          if v-rest-summ > 0
          then do:
            run del-rest (output p-message, output p-ok) .
          end.
          assign
          p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
          p-ok = FALSE
          .
define variable vss-include-info122 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  65
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
          return .
        end.
      end.
      WHEN integer('2':U)
      then do:
define variable vss-include-info123 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-cashoutcome in g#fr-lib
    ( INPUT       v-summ-1
    , output      p-message
    , output      p-ok
    ) no-error .
end.
        if error-status:error
        OR not p-ok
        then do:
          assign
          p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
          p-ok = FALSE
          .
define variable vss-include-info124 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  65
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
          return .
        end.
      end.
      WHEN integer('3':U)
      then do:
define variable vss-include-info125 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-cashincome in g#fr-lib
    ( INPUT       v-summ-1
    , output      p-message
    , output      p-ok
    ) no-error .
end.
        if error-status:error
        OR not p-ok
        then do:
          assign
          p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
          p-ok = FALSE
          .
define variable vss-include-info126 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  65
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
          return .
        end.
      end.
      OTHERWISE DO:
      end.
   end case.
  end.
  else do:
    assign
    v-rest-summ = ?
    p-ok = TRUE
    .
  end.
   if error-status:error
   OR not p-ok
   then do:
      assign
      p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
      p-ok = FALSE
      .
define variable vss-include-info127 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  65
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
      return .
   end.
define variable vss-include-info128 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_close-check in g#libthpos
  (input  tt-head-check.doc-code
  ,input  v-chk-fr-num
  ) no-error .
  if error-status:error then do:
    if v-rest-summ > 0
    then do:
      run del-rest (output p-message, output p-ok) .
    end.
    assign
    p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
    p-ok = FALSE
    .
define variable vss-include-info129 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  65
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
    return.
  end.
  define buffer buf_tt-open-check     for tt-open-check .
  if CAN-find(first buf_tt-open-check)
  then do:
    for each  buf_tt-open-check
        where buf_tt-open-check.chk-type = integer('201':U)
          OR  buf_tt-open-check.chk-type = integer('206':U)
            :
define variable vss-include-info130 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_close-postpone in g#libthpos
  (input  tt-head-check.doc-code
  ,input  buf_tt-open-check.doc-code
  ,input  1
  ) no-error .
      if error-status:error
      then do:
        assign
        p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
        p-ok = FALSE
        .
define variable vss-include-info131 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  65
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
        return.
      end.
    end.
  end.
define variable vss-include-info132 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  64
    , input  TIME
    , input  'S':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
  if not v-emul-mode
  AND v-with-context
  AND p-cd-mode = "1"
  then do:
    assign
    v-disp-msg-1 = "Сдача" + STRING(ABS( TRUNCATE(v-summ-netto-rub, 2) ) - ABS( TRUNCATE(v-summ-pay-rub,2 )  )) + " " + v-cd-base-name
    v-disp-msg-2 = "":U
    .
define variable vss-include-info133 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#disp-lib ) <> TRUE then do:       run gbl/disp-lib.p persistent no-error.       if error-status :error or valid-handle( g#disp-lib ) <> TRUE then do:         message "Error starting disp-lib.p" skip( 0 )           g#disp-lib                        skip( 0 )           g#disp-lib    :type               skip( 0 )           g#disp-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run disp-str in g#disp-lib
    ( INPUT  v-disp-msg-1
    , INPUT  v-disp-msg-2
    , output v-disp-msg-2
    , output p-ok
    )  .
end.
  end.
  run clear-tt-chk in this-procedure.
  assign
  p-cd-mode         = "0"
  p-cd-submode      = "0"
  v-time-close      = TIME
  p-ok              = true
  .
end.
end procedure.
procedure 1987 :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
define buffer buf_tt-head-check     for tt-head-check .
do
on error undo, return error
:
define variable vss-include-info134 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  0
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  69
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
   run adm/chk-pass.w   ( input parparentproc
                        , input v-cntxt-userid
                        , input v-cntxt-db-num
                        , input "actn_ibsthpos-return"
                        , input FALSE
                        , output p-message
                        , output p-ok
                        ) .
   if not p-ok
   then do:
define variable vss-include-info135 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  0
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  71
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
      return.
   end.
   run clear-tt-chk in this-procedure.
   run chk-open   ( input integer('6':U)
                  , INPUt-OUTPUT p-cd-mode
                  , INPUt-output p-cd-submode
                  , output p-message
                  , output p-ok
                  ) .
   if p-ok
   then do:
      find buf_tt-head-check.
define variable vss-include-info136 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  70
    , input  TIME
    , input  'S':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
      assign
         p-message    = "Чек возврата открыт"
         p-cd-mode    = "2"
         p-cd-submode = "0"
      .
   end.
   else do:
define variable vss-include-info137 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  0
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  71
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
   end.
end.
end procedure.
procedure 1993 :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
define buffer buf_tt-head-check     for tt-head-check .
define variable v-doc-code    as character    no-undo.
define variable v-chk-type    as integer      no-undo.
do
on error undo, return error
:
   find first buf_tt-head-check NO-LOCK no-error.
   if available buf_tt-head-check
   then do:
      assign
         v-doc-code = buf_tt-head-check.doc-code
         v-chk-type = buf_tt-head-check.chk-type
      .
   end.
define variable vss-include-info138 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  1
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  v-chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  v-doc-code
    , input  '':U
    , input  TODAY
    , input  52
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
   p-ok = FALSE.
   DO WHILE not p-ok
   :
      run adm/chk-pass.w   ( input parparentproc
                           , input v-cntxt-userid
                           , input v-cntxt-db-num
                           , input "":U
                           , input TRUE
                           , output p-message
                           , output p-ok
                           ) no-error.
   end.
define variable vss-include-info139 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  1
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  v-chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  v-doc-code
    , input  '':U
    , input  TODAY
    , input  53
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
end.
end procedure.
procedure cd-unblock :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   run adm/chk-pass.w   ( input parparentproc
                        , input v-cntxt-userid
                        , input v-cntxt-db-num
                        , input "actn_ibsthpos-unblock"
                        , input TRUE
                        , output p-message
                        , output p-ok
                        ) .
   if p-ok
   then do:
      assign
         p-cd-mode    = v-cd-mode-user-pre
         p-cd-submode = v-cd-submode-user-pre
      .
   end.
end.
end procedure.
procedure key-enable :
define input  parameter p-cd-mode      as character          no-undo.
define input  parameter p-cd-submode   as character        no-undo.
define input  parameter p-name         as character        no-undo.
define output parameter p-ok           as logical          no-undo.
define output parameter p-label        as character        no-undo.
define output parameter p-tooltip      as character        no-undo.
define variable v-md    as character    no-undo.
define variable v-msg   as character    no-undo.
define buffer buf_temp-layout-elem-rule      for temp-layout-elem-rule .
do
on error undo, return error
:
   if p-cd-mode = "1"
   OR p-cd-mode = "2"
   then do:
      assign
         v-md = substitute("&1.&2", p-cd-mode, p-cd-submode)
      .
   end.
   else do:
      assign
         v-md = p-cd-mode
      .
   end.
   find first buf_temp-layout-elem-rule
        where buf_temp-layout-elem-rule.layout-id  = v-screen-layout-id
          and buf_temp-layout-elem-rule.mode-id    = v-md
          and buf_temp-layout-elem-rule.widget-id  = p-name
          no-error
          .
   if available buf_temp-layout-elem-rule then do:
      assign
         p-label     = buf_temp-layout-elem-rule.elem-label
         p-tooltip   = buf_temp-layout-elem-rule.elem-tooltip
         p-ok        = TRUE
      .
      RELEASE buf_temp-layout-elem-rule.
   end.
   else do:
      find first tt-func-key
           where tt-func-key.cd-mode     = p-cd-mode
             and tt-func-key.cd-submode  = p-cd-submode
             AND tt-func-key.key-name    = p-name
            NO-LOCK
            No-error
            .
      if not available tt-func-key
      then return.
      assign
         p-label = tt-func-key.key_label
         p-ok    = TRUE
      .
   end.
   return.
end.
end procedure.
procedure key-run :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define input         parameter p-name        as character      no-undo .
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
define variable v-msg    as character    no-undo.
do
on error undo, return error
:
   find first tt-func-key
        where tt-func-key.cd-mode    = p-cd-mode
         AND  tt-func-key.cd-submode = p-cd-submode
         AND  tt-func-key.key-name   = p-name
        NO-LOCK
        No-error
        .
   if not available tt-func-key
   then do:
      return.
   end.
   assign
      v-fix-summ-pay = DECIMAL(TRIM(tt-func-key.key_label, " %"))
   no-error
   .
   if error-status:error
   then do:
      assign
         v-fix-summ-pay = 0
      no-error .
   end.
   if tt-func-key.cng-context
   then do:
      run VALUE( tt-func-key.key_func )  ( INPUt-OUTPUT p-cd-mode
                                         , INPUt-output p-cd-submode
                                         , output p-message
                                         , output p-ok
                                         ) .
   end.
   else do:
      run VALUE( tt-func-key.key_func ) ( output p-message
                                        , output p-ok
                                        ) .
   end.
   if not p-ok
   then do:
      return.
   end.
   if p-cd-mode <> "4"
   then do:
      assign
         v-msg            = p-message
         v-cd-mode-pre    = p-cd-mode
         v-cd-submode-pre = p-cd-submode
      .
   end.
   run cd-context ( INPUt-OUTPUT p-cd-mode
                  , INPUt-output p-cd-submode
                  , output       p-message
                  , output p-ok
                  ) .
   if not p-ok
   then do:
      return.
   end.
   if p-cd-mode <> "4"
   then do:
      assign
         p-message        = v-msg
         v-cd-mode-pre    = p-cd-mode
         v-cd-submode-pre = p-cd-submode
      .
   end.
   return.
end.
end procedure.
procedure rule-run :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define input         parameter p-name        as character      no-undo .
define input         parameter p-type        as character      no-undo .
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
define variable v-msg    as character    no-undo.
define variable v-md    as character    no-undo.
define buffer b_temp-layout-elem-rule for temp-layout-elem-rule .
define buffer b_tt-func-key for tt-func-key .
do
on error undo, return error
:
   if p-cd-mode = "1"
   OR p-cd-mode = "2"
   then do:
      assign
         v-md = substitute("&1.&2", p-cd-mode, p-cd-submode)
      .
   end.
   else do:
      assign
         v-md = p-cd-mode
      .
   end.
   case p-type:
      WHEN 'th-pos-keyboard':U then do:
         if  v-keyboard-layout-id <> "":U
         AND v-keyboard-layout-id <> ?
         then do:
            find first buf_temp-layout-elem-rule
               where buf_temp-layout-elem-rule.layout-id = v-keyboard-layout-id
                  and buf_temp-layout-elem-rule.widget-id = p-name
                  no-error
                  .
            if avail buf_temp-layout-elem-rule then
            do:
               find first b_temp-layout-elem-rule no-lock where
                          b_temp-layout-elem-rule.rule_id =  buf_temp-layout-elem-rule.rule_id
                    and   b_temp-layout-elem-rule.mode-id = v-md
                    no-error
                    .
               if not avail b_temp-layout-elem-rule then
               do:
                  find first b_tt-func-key no-lock where b_tt-func-key.cd-mode = p-cd-mode
                                          and b_tt-func-key.cd-submode = p-cd-submode
                                          and b_tt-func-key.key_func = string(buf_temp-layout-elem-rule.rule_id)
                                          no-error.
                  if not avail b_tt-func-key then
                  do:
                    assign p-ok = no
                           p-message = "В данном режиме клавиша не работает"
                         .
                    return  .
                  end.
               end.
            end.
         end.
         else do:
            find first buf_temp-layout-elem-rule
               where buf_temp-layout-elem-rule.layout-id = v-screen-layout-id
                  and buf_temp-layout-elem-rule.mode-id   = v-md
                  and buf_temp-layout-elem-rule.widget-id = p-name
                  no-error
                  .
         end.
      end.
      WHEN 'th-pos-screen':U then do:
         find first buf_temp-layout-elem-rule
              where buf_temp-layout-elem-rule.layout-id = v-screen-layout-id
                and buf_temp-layout-elem-rule.mode-id   = v-md
                and buf_temp-layout-elem-rule.widget-id = p-name
               no-error
               .
      end.
      OTHERWISE DO:
      end.
   end case.
   if available buf_temp-layout-elem-rule then do:
      run value( substitute("&1", string(buf_temp-layout-elem-rule.rule_id, "9999"))) in this-procedure
               ( input-output p-cd-mode
               , input-output p-cd-submode
               , output p-message
               , output p-ok
               ) no-error.
      RELEASE buf_temp-layout-elem-rule.
   end.
   else do:
      run key-run in this-procedure ( input-output p-cd-mode
                                    , input-output p-cd-submode
                                    , input p-name
                                    , output p-message
                                    , output p-ok
                                    ) no-error.
   end.
   if error-status:error
   then do:
      assign
         p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
      return.
   end.
   if not p-ok
   then do:
      return.
   end.
   if p-cd-mode <> "4"
   then do:
      assign
         v-msg            = p-message
         v-cd-mode-pre    = p-cd-mode
         v-cd-submode-pre = p-cd-submode
      .
   end.
   run cd-context ( INPUt-OUTPUT p-cd-mode
                  , INPUt-output p-cd-submode
                  , output       p-message
                  , output       p-ok
                  ) .
   if not p-ok
   then do:
      return.
   end.
   if p-cd-mode <> "4"
   then do:
      assign
         p-message        = v-msg
         v-cd-mode-pre    = p-cd-mode
         v-cd-submode-pre = p-cd-submode
      .
   end.
   return.
end.
end procedure.
procedure func-param :
define input   parameter p-name        as character      no-undo .
define output  parameter p-message     as character      no-undo .
define output  parameter p-ok          as logical        no-undo .
do
on error undo, return error
:
      run VALUE( p-name ) in this-procedure ( output p-message, output p-ok ) no-error.
      if error-status:error
      then do:
         assign
            p-ok = FALSE
            p-message = substitute  ( "&1 &2 &3 &4"
                                    , return-VALUE
                                    , error-status:get-message(1)
                                    , error-status:get-message(2)
                                    , error-status:get-message(3)
                                    )
         .
      end.
end.
end procedure.
procedure pr-empty :
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
define variable v-choice as logical no-undo init yes.
do
on error undo, return error
:
   message
   "Вы действительно хотите  выйти из АРМа  'Кассир' ?"
   view-as alert-box question buttons yes-no update v-choice .
   if v-choice then.
   else return no-apply.
   if not v-emul-mode
   then do:
define variable vss-include-info140 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#disp-lib ) <> TRUE then do:       run gbl/disp-lib.p persistent no-error.       if error-status :error or valid-handle( g#disp-lib ) <> TRUE then do:         message "Error starting disp-lib.p" skip( 0 )           g#disp-lib                        skip( 0 )           g#disp-lib    :type               skip( 0 )           g#disp-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run disp-clear in g#disp-lib
    ( output p-message
    , output p-ok
    ) no-error .
end.
define variable vss-include-info141 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#disp-lib ) <> TRUE then do:       run gbl/disp-lib.p persistent no-error.       if error-status :error or valid-handle( g#disp-lib ) <> TRUE then do:         message "Error starting disp-lib.p" skip( 0 )           g#disp-lib                        skip( 0 )           g#disp-lib    :type               skip( 0 )           g#disp-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run disp-str in g#disp-lib
    ( INPUT  '':U
    , INPUT  '':U
    , output p-message
    , output p-ok
    ) no-error .
end.
define variable vss-include-info142 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#disp-lib ) <> TRUE then do:       run gbl/disp-lib.p persistent no-error.       if error-status :error or valid-handle( g#disp-lib ) <> TRUE then do:         message "Error starting disp-lib.p" skip( 0 )           g#disp-lib                        skip( 0 )           g#disp-lib    :type               skip( 0 )           g#disp-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run disp-terminate in g#disp-lib
    ( output p-message
    , output p-ok
    ) no-error .
end.
   end.
   QUIT.
end.
end procedure.
procedure set-date :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
      if not v-emul-mode
         then do:
define variable vss-include-info143 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-dtset in g#fr-lib
    ( output       p-message
    , output       p-ok
    ) no-error .
end.
         if error-status:error
         then do:
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            return .
         end.
define variable vss-include-info144 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-tmset in g#fr-lib
    ( output       p-message
    , output       p-ok
    ) no-error .
end.
         if error-status:error
         then do:
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            return.
         end.
      end.
      else do:
         assign
            p-cd-mode    = "0"
            p-cd-submode = "0"
            p-ok = TRUE
         .
      end.
end.
end procedure.
procedure add-gds-line :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define buffer buf_tt-line     for tt-line .
define buffer prev_tt-line    for tt-line .
define buffer buf_goods       for ub.goods .
define buffer buf_tt-head-check     for tt-head-check .
define variable v-b-code          as integer no-undo .
define variable v-second-name     as character no-undo .
define variable v-next    as character    no-undo.
do
on error undo, return error
:
   find last  prev_tt-line
        where prev_tt-line.type = 0
        NO-LOCK
        no-error
        .
   if ((p-cd-mode = "1"
   OR  p-cd-mode = "2")
   AND p-cd-submode = "0")
   OR  not v-with-context
   then do:
      assign
         v-pump            = 0
         v-nozzle-code     = 0
         v-pl-code         = 0
         v-fbr-depart      = 0
         v-src-price       = if (p-cd-mode = "1") then ? else v-src-price
         v-write-off-code  = 0
         v-num             = if v-num = 0 then (if (not available prev_tt-line) then 1
                                                                             else prev_tt-line.num + 1)
                                          else v-num
      .
      find buf_tt-head-check.
      assign
         v-src-qnty = if v-src-qnty = 0 then 1 else v-src-qnty
      .
      if p-cd-mode = "2"
      then do:
         define variable v-curr-qnty   as decimal      no-undo .
         define variable v-old-qnty    as decimal      no-undo .
         define variable v-found       as logical      no-undo .
         run accum-chk-gds ( input  v-src
                           , output v-found
                           , output v-old-qnty
                           ) .
         run accum-curr-chk-gds  ( input  v-src
                                 , output v-curr-qnty
                                 ) .
         if ( ( v-curr-qnty + v-src-qnty ) > v-old-qnty )
         AND v-found
         then do:
            if v-old-qnty = 0
            then do:
               assign
                  p-message = "В исходном чеке продажи не было такого товара"
                  p-ok = FALSE
               .
               return.
            end.
            else do:
               assign
                  p-message = substitute( "По данному чеку продажи можно вернуть только &1 товара с кодом &2"
                                       , v-old-qnty
                                       , v-src
                                       )
                  p-ok = FALSE
               .
               return.
            end.
         end.
         define buffer buf_chk-gds     for ub.chk-gds .
         define buffer buf_tt-open-check     for tt-open-check .
         find first buf_tt-open-check
            where buf_tt-open-check.chk-type = INTEGER('1':U)
            no-lock
            no-error
            .
         find first buf_chk-gds
            where buf_chk-gds.doc-code = buf_tt-open-check.doc-code
               AND   buf_chk-gds.src-code = v-src
            NO-LOCK
            no-error
            .
         if available buf_chk-gds
         AND v-src-price = 0
         then do:
            assign
               v-src-price       = buf_chk-gds.price-base - buf_chk-gds.discnt
               v-src-discnt      = buf_chk-gds.discnt
            .
         end.
      end.
      if p-cd-mode = "2"
      then do:
         assign
            v-src-qnty = - ABS( v-src-qnty )
         no-error.
      end.
      else do:
         assign
            v-src-qnty = ABS( v-src-qnty )
         no-error.
      end.
      case v-pass-gds :
         WHEN 0
         then do:
            if v-with-context
            then do:
define variable vss-include-info145 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  1
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  0
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  11
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
               if error-status:error
               then do:
                  message
                     "Z"  11
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.
            end.
         end.
         WHEN 1
         then do:
            if v-with-context
            then do:
define variable vss-include-info146 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  0
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  12
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
               if error-status:error
               then do:
                  message
                     "Z"  12
                     skip error-status:get-message(1)
                     skip return-value
                     skip 1
                     skip v-cntxt-db-num
                     skip '':U
                     skip p-cash-num
                     skip "substitute( '&1.&2' , p-cd-mode, p-cd-submode)"
                     skip buf_tt-head-check.chk-type
                     skip '':U
                     skip '*':U
                     skip 0
                     skip buf_tt-head-check.doc-code
                     skip '':U
                     skip TODAY
                     skip 11
                     skip TIME
                     skip 'U':U
                     skip 0
                     skip v-cntxt-obj-code
                     skip '':U
                     skip 'IBS-TH':U
                     skip 0
                     skip ?
                     skip '':U
                     skip 0
                     skip v-src
                     skip 0
                     skip v-cntxt-userid
                  view-as alert-box information.
               end.
            end.
         end.
         OTHERWISE DO:
            if v-with-context
            then do:
define variable vss-include-info147 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  0
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  13
    , input  TIME
    , input  'S':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
               if error-status:error
               then do:
                  message
                     "Z"  13
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.
            end.
            assign
               v-pass-gds = 0
            .
         end.
      end case.
      if v-with-context
      then do:
         assign
            v-chk-name = "":U
            v-gds-code = 0
         .
define variable vss-include-info148 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_gds-line in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  v-num
  ,input  'ДОБАВЛЕНИЕ':U
  ,input  1
  ,input  v-src
  ,input-output  v-src-qnty
  ,input  v-pump
  ,input  v-nozzle-code
  ,input  v-pl-code
  ,input  v-pass-gds
  ,input  v-write-off-code
  ,input  v-fbr-depart
  ,output p-ok
  ,output v-next
  ,output v-b-code
  ,output v-gds-code
  ,output v-chk-name
  ,output v-second-name
  ,input-output v-src-price
  ,output v-src-price-rub
  ,output v-src-discnt
  ,output v-src-discnt-rub
  ,output v-src-sum
  ,output v-src-sum-rub
  ,output v-src-sum-netto
  ,output v-src-sum-netto-rub
  ,output v-unit-base
  ) no-error .
         if error-status:error
         then do:
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info149 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  1
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  0
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  15
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
               if error-status:error
               then do:
                  message
                     "Z"  15
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.
              assign
                v-src = '' .
            return.
         end.
      end.
      if v-with-context
      then do:
define variable vss-include-info150 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  1
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  0
    , input  buf_tt-head-check.doc-code
    , input  v-src-qnty
    , input  TODAY
    , input  14
    , input  TIME
    , input  'U':U
    , input  v-gds-code
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  v-src-sum-netto
    , input  v-cntxt-userid
    ) no-error .
end.
         if error-status:error
         then do:
            message
               "Z"  14
               skip error-status:get-message(1)
               skip return-value
            view-as alert-box information.
         end.
      end.
      define variable v-str-end    as character    no-undo.
      define variable v-msg    as character    no-undo.
      CREATE buf_tt-line.
      assign
         v-disp-msg-1             = v-chk-name
         v-disp-msg-2             = substitute  ( "&1 x &2 &3"
                                                , if p-cd-mode = "2" then - v-src-qnty else v-src-qnty
                                                , v-src-price
                                                , v-cd-base-name
                                                )
         buf_tt-line.type         = 0
         buf_tt-line.num          = v-num
         buf_tt-line.line-code    = v-gds-code
         buf_tt-line.line-name    = v-chk-name
         buf_tt-line.line-name-2  = v-second-name
         buf_tt-line.qnty           = ABSOLUTE(v-src-qnty)                              buf_tt-line.qnty-str         = STRING(ABSOLUTE(v-src-qnty), "->>,>>>,>>9.999":U)                              buf_tt-line.price            = ABS(v-src-price)                              buf_tt-line.price-rub        = ABS(v-src-price-rub)                              buf_tt-line.price-STR        = STRING(ABSOLUTE(v-src-price-rub), "->>,>>>,>>9.99":U)                             buf_tt-line.summ-netto       = ABSOLUTE(v-src-sum-netto)                                                      buf_tt-line.summ-netto-rub   = ABSOLUTE(v-src-sum-netto-rub)                                                      buf_tt-line.summ-brutto      = ABSOLUTE(v-src-sum)                                                             buf_tt-line.summ-brutto-rub  = ABSOLUTE(v-src-sum-rub)                                                             buf_tt-line.unit-base        = v-unit-base                             buf_tt-line.summ-discont     = ABSOLUTE(v-src-discnt)                             buf_tt-line.summ-discont-rub = ABSOLUTE(v-src-discnt-rub)
         buf_tt-line.src          = v-src
         buf_tt-line.ord-chk-num  = v-ord-chk-num
         buf_tt-line.ord-line-num = v-ord-line-num
         buf_tt-line.line-seller-code = buf_tt-head-check.chk-seller-code
         buf_tt-line.line-seller-name = buf_tt-head-check.chk-seller-name
         v-curr-num-0             = v-num
         v-curr-type-0            = 0
         v-src                    = ""
         v-src-qnty               = 0.0
         v-src-price              = 0.0
         v-src-price-rub          = 0.0
         v-num                    = 0
         p-ok                     = TRUE
         p-message = substitute  ( "&1 &2x&3"                                      , substring(buf_tt-line.line-name + fill(' ':U,38),                                                1, 38 - 1 - length(trim(string(buf_tt-line.qnty,"->>>,>>>,>>9.<<<")) + 'X' + trim(string(buf_tt-line.price,"->>>,>>>,>>9.99")))  )                                    , trim(string(buf_tt-line.qnty,"->>>,>>>,>>9.<<<"))                                    , trim(string(buf_tt-line.price,"->>>,>>>,>>9.99"))           )
         v-msg            = p-message
      .
      if not v-emul-mode
      AND v-with-context
      then do:
define variable vss-include-info151 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#disp-lib ) <> TRUE then do:       run gbl/disp-lib.p persistent no-error.       if error-status :error or valid-handle( g#disp-lib ) <> TRUE then do:         message "Error starting disp-lib.p" skip( 0 )           g#disp-lib                        skip( 0 )           g#disp-lib    :type               skip( 0 )           g#disp-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run disp-str in g#disp-lib
    ( INPUT  v-disp-msg-1
    , INPUT  v-disp-msg-2
    , output v-disp-msg-2
    , output p-ok
    )  .
end.
      end.
      define variable v-num-str    as integer      no-undo.
      define variable v-gds-yes    as integer      no-undo.
      define variable v-pay-yes    as integer      no-undo.
      define variable v-num-local   as integer      no-undo.
      define variable v-type-local  as integer      no-undo.
      if  v-with-context
      AND INDEX(v-next, "=") > 0
      AND not v-recalc
      then do:
         assign
            v-recalc  = TRUE
            v-next    = TRIM(v-next, "recalc=")
            v-num-str = INTEGER(ENTRY(1, v-next, ","))
            v-gds-yes = INTEGER(ENTRY(2, v-next, ","))
            v-pay-yes = INTEGER(ENTRY(3, v-next, ","))
            v-num-local  = v-curr-num-0
            v-type-local = v-curr-type-0
         .
         run recalc-lines in this-procedure
                        ( input v-num-str
                        , input v-gds-yes
                        , input v-pay-yes
                        , input-output p-cd-mode
                        , INPUt-output p-cd-submode
                        , output p-message
                        , output p-ok
                        ) .
         assign
            v-recalc         = FALSE
            v-src            = ""
            v-src-qnty       = 0.0
            v-src-price      = 0.0
            v-src-price-rub  = 0.0
            v-curr-num-0     = v-num-local
            v-curr-type-0    = v-type-local
         .
      end.
      if  p-cd-mode = "2"
      AND v-ord-chk-num  = "":U
      AND v-ord-line-num = 0
      then do:
         assign
            p-cd-submode = "7"
            p-message    = "Подтвердите цену товара"
            p-ok         = TRUE
            v-src        = STRING(buf_tt-line.price)
            v-src-price  = buf_tt-line.price
            v-src-price-rub  = buf_tt-line.price-rub
         .
         run 2004 ( INPUt-OUTPUT p-cd-mode
                  , INPUt-output p-cd-submode
                  , output p-message
                  , output p-ok
                  ) .
      end.
   end.
   assign
      p-message    =  v-msg
      v-src        = ""
      v-src-qnty   = 0.0
      v-src-price  = 0.0
      v-src-price-rub  = 0.0
   .
end.
end procedure.
procedure cd-context :
define INPUt-output parameter p-cd-mode    as character        no-undo.
define INPUt-output parameter p-cd-submode as character        no-undo.
define output       parameter p-message    as character        no-undo.
define output       parameter p-ok         as logical          no-undo.
do
on error undo, return error
:
define variable v-fr-mode            as integer      no-undo.
define variable v-fr-time            as integer      no-undo.
define variable v-fr-date            as date         no-undo.
define variable v-fr-last-shift-date as date         no-undo.
define variable v-fr-last-shift-old  as integer      no-undo.
define variable v-fr-lic             as character    no-undo.
define variable v-diff-time            as decimal   no-undo .
define variable v-max-diff-seconds      as integer   no-undo initial 120 .
define variable v-integer   as integer      no-undo.
define variable v-character as character    no-undo.
define variable v-decimal   as decimal      no-undo.
define variable v-logical   as logical      no-undo.
define variable v-date    as date         no-undo.
define variable v-handle    as handle       no-undo.
define variable v-cont    as integer    no-undo.
define variable v-data-type    as character    no-undo.
define variable v-fr-serial          as char    no-undo.
   if not v-emul-mode
      then do:
      assign
         v-fr-last-shift-old = v-fr-last-shift-num
      .
define variable vss-include-info152 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-ctrl in g#fr-lib
    ( input        v-cash-drawer-open
    , output       p-message
    , output       p-ok
    , output       v-fr-mode
    , output       v-fr-time
    , output       v-fr-date
    , output       v-fr-last-shift-date
    , output       v-fr-last-shift-num
    , output       v-fr-lic
    , output       v-fr-shift-open
    , output       v-fr-serial
    ) no-error .
end.
      if not p-ok
      then do:
         if  v-fr-shift-open = 24 then
         do:
          if ( p-cd-mode = "1"
          OR   p-cd-mode = "2"
             )
          then do:
            assign
               p-ok = TRUE
            .
            return.
          end .
          assign
            p-cd-mode    = "4"
            p-cd-submode = "0"
          .
          return .
         end.
         define buffer bf_tt-head-check     for tt-head-check .
         find first bf_tt-head-check no-error.
         define variable vv-chk-type    as integer    no-undo.
         define variable vv-doc-code    as character    no-undo.
         if available bf_tt-head-check
         then do:
            assign
               vv-chk-type = bf_tt-head-check.chk-type
               vv-doc-code = bf_tt-head-check.doc-code
            .
            RELEASE bf_tt-head-check.
         end.
define variable vss-include-info153 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  vv-chk-type
    , input  '':U
    , input  p-message
    , input  0
    , input  vv-doc-code
    , input  '':U
    , input  TODAY
    , input  4
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            if error-status:error
            then do:
               message
                  "Z"  4
                  skip error-status:get-message(1)
                  skip return-value
               view-as alert-box information.
            end.
         assign
            p-cd-mode    = "4"
            p-cd-submode = "0"
         .
         return.
      end.
      else do:
         if p-cd-mode    = "4"
         then do:
            assign
               p-message    = " ":U
               p-cd-mode    = v-cd-mode-pre
               p-cd-submode = v-cd-submode-pre
            .
         end.
      end.
      if v-fr-serial <> v-context-serial
      then do:
         assign
            p-message = substitute ( "Серийный номер ФР (&1) отличается от указанного в настройках (&2)"
                                   , v-fr-serial
                                   , v-context-serial
                                   )
            p-cd-mode = "4"
            p-ok      = FALSE
         .
      end.
      if  v-fr-shift-open = 0
      AND not p-cd-mode <> "1"
      AND not p-cd-mode <> "2"
      then do:
         assign
            p-cd-mode    = "6"
            p-cd-submode = "0"
         .
         return.
      end.
      assign
         v-diff-time = v-fr-time - time
      .
      if absolute(v-diff-time) > v-max-diff-seconds
      then do:
         assign
            p-message =
            "Неверное время на фискальном регистраторе " +
            string(v-fr-time,"HH:MM:SS") +  " "  + string(time,"HH:MM:SS")  +  " "  +
            string(v-max-diff-seconds)
             + chr(10) +
            "Необходимо закрыть смену на кассе и выставить время"
             + chr(10)
             + STRING(v-diff-time) + "-" + STRING(v-fr-time, "HH:MM:SS") + "-" + STRING( time, "HH:MM:SS")
            p-cd-mode = "4"
            p-ok      = FALSE
         .
      end.
   end.
   else do:
      assign
         p-ok = TRUE
         v-fr-last-shift-num = 99999
      .
   end.
   if v-fr-last-shift-old <> v-fr-last-shift-num
   then do:
      assign
         v-fr-last-shift-old = v-fr-last-shift-num
         v-integer = v-fr-last-shift-num
         v-cont    = 1
      .
define variable vss-include-info154 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_set-context-property in g#libthpos
  (input  v-cont
  ,input  'z-number'
  ,input  v-character
  ,input  v-date
  ,input  v-decimal
  ,input  v-integer
  ,input  v-logical
  ,input  v-handle
  ,output p-ok
  ) no-error .
      if error-status:error
      OR not p-ok
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         return .
      end.
      assign
         v-integer = ?
      .
   end.
   if p-cd-mode = "0"
   then do:
define variable vss-include-info155 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-context-property in g#libthpos
  (input  1
  ,input  'cash-counter'
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-handle
  ,output v-data-type
  ,output p-ok
  ) no-error .
      if error-status:error
      OR not p-ok
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         return .
      end.
      if v-decimal > v-cash-drawer-limit
      then do:
         assign
            p-message = substitute( "Наличность в денежном ящике: &1 превысила допустимый предел &2", v-decimal, v-cash-drawer-limit )
            p-ok = FALSE
         .
         return.
      end.
   end.
   assign
      p-ok = TRUE
   .
end.
end procedure.
procedure 1983 :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
define variable v-st-r-b as decimal no-undo .
define variable v-st-rubl as decimal no-undo .
define variable v-st-base as decimal no-undo .
define variable v-tot-doc as decimal no-undo .
define variable v-netto as decimal no-undo .
define variable v-netto-rubl as decimal no-undo .
define variable v-netto-base as decimal no-undo .
define variable v-all-discnt as decimal no-undo .
define variable v-all-discnt-rubl as decimal no-undo .
define variable v-all-discnt-base as decimal no-undo .
do
on error undo, return error
:
   if p-cd-mode = "1"
   OR p-cd-mode = "2"
   then do:
      if p-cd-submode = "0"
      then do:
         find tt-head-check.
define variable vss-include-info156 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_sub-total in g#libthpos
  (input  tt-head-check.doc-code
  ,input  ''
  ,output p-ok
  ,input-output v-st-r-b
  ,input-output v-st-rubl
  ,input-output v-st-base
  ,input-output v-tot-doc
  ,input-output v-discnt-chk
  ,output v-netto
  ,output v-netto-rubl
  ,output v-netto-base
  ,output v-all-discnt
  ,output v-all-discnt-rubl
  ,output v-all-discnt-base
  ) no-error .
         if error-status:error then do:
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            return.
         end.
         assign
            v-disp-msg-1 = "К оплате"
            v-disp-msg-2 = STRING(ABS( v-netto-rubl )) + " " + v-cd-base-name
         .
         if not v-emul-mode
         then do:
define variable vss-include-info157 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#disp-lib ) <> TRUE then do:       run gbl/disp-lib.p persistent no-error.       if error-status :error or valid-handle( g#disp-lib ) <> TRUE then do:         message "Error starting disp-lib.p" skip( 0 )           g#disp-lib                        skip( 0 )           g#disp-lib    :type               skip( 0 )           g#disp-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run disp-str in g#disp-lib
    ( INPUT  v-disp-msg-1
    , INPUT  v-disp-msg-2
    , output p-message
    , output p-ok
    )  .
end.
         end.
         assign
            p-message    = "Наличными"
            p-cd-submode = "2"
            p-ok         = TRUE
         .
      end.
      if p-cd-submode =  "2"
      then do:
         define buffer buf_rule-call-param   for ub.rule-call-param .
         define buffer buf_cash-pay          for ub.cash-pay .
         define variable v-pay    as logical      no-undo.
         define variable v-sum    as logical      no-undo.
         for each  buf_rule-call-param
               where buf_rule-call-param.call_id = buf_temp-layout-elem-rule.uniq-key-rec
               no-lock
            :
            case buf_rule-call-param.param-name:
               WHEN "p-cash-pay"
               then do:
                  if NUM-ENTRIES ( buf_rule-call-param.param-value-character ) > 1
                  then do:
                     assign
                        v-pay-type        = INTEGER( ENTRY( 1, buf_rule-call-param.param-value-character ) )
                        v-curr-base-code  = INTEGER( ENTRY( 2, buf_rule-call-param.param-value-character ) )
                        v-pay             = TRUE
                     no-error
                     .
                     if error-status:error
                     then do:
                        assign
                           p-message = substitute( "Неправильно настроен тип платежа для данной функции: &1", buf_rule-call-param.param-value-character)
                        .
                        return.
                     end.
                  end.
               end.
               WHEN "p-tot-sum"
               then do:
                  if  buf_rule-call-param.param-value-decimal <> 0
                  AND buf_rule-call-param.param-value-decimal <> ?
                  then
                  assign
                     v-src = STRING(buf_rule-call-param.param-value-decimal)
                     v-sum = if (buf_rule-call-param.param-value-decimal <> 0) then TRUE else FALSE
                  .
               end.
               OTHERWISE DO:
               end.
            end case.
         end.
         if v-pay
         then do:
            if v-sum
            then do:
               run input-pay-sale  ( INPUt-OUTPUT p-cd-mode
                                    , INPUt-output p-cd-submode
                                    , output p-message
                                    , output p-ok
                                    ) .
            end.
            else do:
               find first buf_cash-pay
                    where buf_cash-pay.cdpay-code = v-pay-type
                      AND buf_cash-pay.curr-code  = v-curr-base-code
                    NO-LOCK
                    no-error
                     .
               if not available buf_cash-pay
               then do:
                  assign
                     p-message = substitute( "Не найден тип платежа: &1", buf_rule-call-param.param-value-character)
                  .
                  return.
               end.
               assign
                  p-message = buf_cash-pay.obj-name
                  p-ok      = TRUE
               .
               RELEASE buf_cash-pay.
            end.
         end.
         else do:
            assign
               p-message = "Не задан тип платежа"
            .
            return.
         end.
      end.
   end.
end.
end procedure.
procedure 2004 :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   if CAN-find( first tt-open-check where tt-open-check.chk-type = INTEGER('1':U))
   then do:
      assign
        p-message = "Чек возврата привязан к чеку продажи, ИЗМЕНИТЬ ЦЕНУ НЕВОЗМОЖНО"
        p-ok      = false
      .
      return.
   end.
   if p-cd-mode = "2"
   then do:
      assign
        p-message    = "Подтвердите цену товара"
        p-cd-submode = "7"
        p-ok         = TRUE
      .
   end.
end.
end procedure.
procedure set-all-summ :
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
define buffer buf_tt-line     for tt-line .
do
on error undo, return error
:
   assign
      v-summ-netto-rub   = 0.0
      v-summ-brutto-rub  = 0.0
      v-summ-discont-rub = 0.0
      v-summ-pay-rub     = 0.0
   .
   for each  buf_tt-line
       where buf_tt-line.type = 1
   :
      assign
         v-summ-pay-rub = v-summ-pay-rub + ABS(buf_tt-line.summ-netto-rub)
      .
   end.
   define variable v-st-r-b as decimal no-undo .
   define variable v-st-rubl as decimal no-undo .
   define variable v-st-base as decimal no-undo .
   define variable v-tot-doc as decimal no-undo .
   define variable v-netto as decimal no-undo .
   define variable v-netto-rubl as decimal no-undo .
   define variable v-netto-base as decimal no-undo .
   define variable v-all-discnt as decimal no-undo .
   define variable v-all-discnt-rubl as decimal no-undo .
   define variable v-all-discnt-base as decimal no-undo .
   find tt-head-check no-error.
   if not available tt-head-check then return.
define variable vss-include-info158 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_sub-total in g#libthpos
  (input  tt-head-check.doc-code
  ,input  ''
  ,output p-ok
  ,input-output v-st-r-b
  ,input-output v-st-rubl
  ,input-output v-st-base
  ,input-output v-tot-doc
  ,input-output v-discnt-chk
  ,output v-netto
  ,output v-netto-rubl
  ,output v-netto-base
  ,output v-all-discnt
  ,output v-all-discnt-rubl
  ,output v-all-discnt-base
  ) no-error .
   define variable v-reg-value    as character    no-undo.
   define variable v-reg-name     as character    no-undo.
define variable vss-include-info159 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-get-reg in g#fr-lib
    ( input       'cash':U
    , input       241
    , output      v-reg-value
    , output      v-reg-name
    , output      p-message
    , output      p-ok
    ) no-error .
end.
   if error-status:error
   then do:
      assign
         p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
      return.
   end.
   else do:
      assign
         v-summ-fr = DECIMAL(v-reg-value)
      .
   end.
   assign
      v-summ-brutto-rub  = v-st-rubl
      v-summ-discont-rub = v-all-discnt-rubl
      v-summ-netto-rub   = ABS(v-netto-rubl)
      p-ok           = TRUE
   .
end.
end procedure.
procedure get-all-summ :
define output parameter p-summ-brutto  as decimal          no-undo.
define output parameter p-summ-netto   as decimal          no-undo.
define output parameter p-summ-discont as decimal          no-undo.
define output parameter p-sum-pay      as decimal          no-undo.
define output parameter p-sum-fr       as decimal          no-undo.
define output parameter p-summ-for-pay as decimal          no-undo.
define output parameter p-disc-pay     as decimal          no-undo.
define output parameter p-message      as character      no-undo .
define output parameter p-ok           as logical          no-undo.
do
on error undo, return error
:
   run set-all-summ  ( output p-message
                     , output p-ok
                     ) .
   if p-ok
   then do:
      assign
         p-summ-brutto  = ABS( v-summ-brutto-rub  )
         p-summ-netto   = ABS( v-summ-netto-rub   )
         p-summ-discont = ABS( v-summ-discont-rub - (ABS(v-summ-brutto-rub) - ABS(v-summ-netto-rub)))
         p-sum-pay      = ABS( v-summ-pay-rub     )
         p-sum-fr       = v-summ-fr
         p-summ-for-pay = v-sum-for-pay
         p-disc-pay     = (ABS(v-summ-brutto-rub) - ABS(v-summ-netto-rub))
      .
   end.
end.
end procedure.
procedure 1998 :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
define buffer buf_rule-call-param   for ub.rule-call-param .
define variable v-card    as logical      no-undo.
do
on error undo, return error
:
   case p-cd-submode:
      WHEN "0" OR
      WHEN "3"
      then do:
         if p-cd-mode = "0"
         then do:
            run chk-sale-open ( INPUt-OUTPUT p-cd-mode
                              , INPUt-output p-cd-submode
                              , output p-message
                              , output p-ok
                              ) .
         end.
         for each  buf_rule-call-param
               where buf_rule-call-param.call_id = buf_temp-layout-elem-rule.uniq-key-rec
               no-lock
            :
            case buf_rule-call-param.param-name:
               WHEN "p-d-card"
               then do:
                  if  buf_rule-call-param.param-value-character <> "":U
                  AND buf_rule-call-param.param-value-character <> ?
                  then
                  assign
                     v-src = buf_rule-call-param.param-value-character
                     v-card = TRUE
                  .
               end.
               OTHERWISE DO:
               end.
            end case.
         end.
         if v-card
         then do:
            run input-card ( INPUt-OUTPUT p-cd-mode
                           , INPUt-output p-cd-submode
                           , output p-message
                           , output p-ok
                           ) .
         end.
         else do:
            if p-cd-submode = "0"
            then do:
               assign
                  p-message    = "Регистрация дисконтной карты"
                  p-cd-submode = "3"
                  p-ok         = TRUE
               .
            end.
            else do:
               assign
                  p-message = "Не задан номер карты"
               .
            end.
            return.
         end.
      end.
      OTHERWISE DO:
      end.
   end case.
end.
end procedure.
procedure cr-down :
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
end.
end procedure.
procedure cr-up :
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
end.
end procedure.
procedure set-src :
define input  parameter p-src as character        no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   assign
      v-src = p-src
      p-ok  = TRUE
   .
end.
end procedure.
procedure input-qnty :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   if p-cd-mode = "1"
   OR p-cd-mode = "2"
   then do:
      assign
         v-src-qnty = DECIMAL( v-src )
      no-error.
      if error-status:error
      then do:
         assign
            p-message = substitute( "Вы ввели не число: &1 Введите количество правильно.", v-src )
            p-ok = FALSE
         .
         return.
      end.
      assign
         p-cd-submode = "0"
         p-ok = TRUE
      .
   end.
end.
end procedure.
procedure input-price :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
define buffer buf_tt-line        for tt-line .
define buffer buf_tt-head-check  for tt-head-check .
define variable v-next    as character    no-undo.
define variable v-b-code          as integer no-undo .
define variable v-gds-code        as integer no-undo .
define variable v-chk-name        as character no-undo .
define variable v-second-name     as character no-undo .
define variable v-src-sum         as decimal no-undo .
define variable v-src-sum-netto   as decimal no-undo .
do
on error undo, return error
:
   if v-curr-num-0 <> 0
   AND  p-cd-mode = "2"
   then do:
      find first buf_tt-line
           where buf_tt-line.num  = v-curr-num-0
             and buf_tt-line.type = v-curr-type-0
           no-lock
           .
      find buf_tt-head-check.
define variable vss-include-info160 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  49
    , input  TIME
    , input  'U':U
    , input  buf_tt-line.line-code
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  buf_tt-line.price
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  buf_tt-line.summ-netto
    , input  v-cntxt-userid
    ) no-error .
end.
      assign
         v-src-price = DECIMAL( v-src )
      no-error.
      if error-status:error
      then do:
         assign
            p-message = substitute( "Вы ввели не число: &1 Введите количество правильно.", v-src )
            p-ok = FALSE
         .
define variable vss-include-info161 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  buf_tt-line.qnty
    , input  TODAY
    , input  51
    , input  TIME
    , input  'U':U
    , input  buf_tt-line.line-code
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  buf_tt-line.price
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  buf_tt-line.summ-netto
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
      case buf_tt-line.type:
         WHEN 0 then do:
            assign
               v-pump            = 0
               v-nozzle-code     = 0
               v-pl-code         = 0
               v-pass-gds        = 0
               v-fbr-depart      = 0
               v-write-off-code  = 0
               v-src-qnty        = if p-cd-mode = "2" then - buf_tt-line.qnty else buf_tt-line.qnty
               v-src             = buf_tt-line.src
            .
define variable vss-include-info162 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_gds-line in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  v-curr-num-0
  ,input  'ИЗМЕНЕНИЕ':U
  ,input  0
  ,input  v-src
  ,input-output  v-src-qnty
  ,input  v-pump
  ,input  v-nozzle-code
  ,input  v-pl-code
  ,input  v-pass-gds
  ,input  v-write-off-code
  ,input  v-fbr-depart
  ,output p-ok
  ,output v-next
  ,output v-b-code
  ,output v-gds-code
  ,output v-chk-name
  ,output v-second-name
  ,input-output v-src-price
  ,output v-src-price-rub
  ,output v-src-discnt
  ,output v-src-discnt-rub
  ,output v-src-sum
  ,output v-src-sum-rub
  ,output v-src-sum-netto
  ,output v-src-sum-netto-rub
  ,output v-unit-base
  ) no-error .
            if error-status:error
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
define variable vss-include-info163 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  buf_tt-line.qnty
    , input  TODAY
    , input  51
    , input  TIME
    , input  'U':U
    , input  buf_tt-line.line-code
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  buf_tt-line.price
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  buf_tt-line.summ-netto
    , input  v-cntxt-userid
    ) no-error .
end.
               return.
            end.
            define variable v-msg    as character    no-undo.
            assign
               v-msg                = substitute  ( "&1 &2x&3"
                                                      , buf_tt-line.line-name
                                                      , if p-cd-mode = "2" then - v-src-qnty else v-src-qnty
                                                      , v-src-price
                                                      )
               v-disp-msg-1             = v-chk-name
               v-disp-msg-2             = substitute  ( "&1 x &2 &3"
                                                      , if p-cd-mode = "2" then - v-src-qnty else v-src-qnty
                                                      , v-src-price
                                                      , v-cd-base-name
                                                      )
               buf_tt-line.qnty           = ABSOLUTE(v-src-qnty)                              buf_tt-line.qnty-str         = STRING(ABSOLUTE(v-src-qnty), "->>,>>>,>>9.999":U)                              buf_tt-line.price            = ABS(v-src-price)                              buf_tt-line.price-rub        = ABS(v-src-price-rub)                              buf_tt-line.price-STR        = STRING(ABSOLUTE(v-src-price-rub), "->>,>>>,>>9.99":U)                             buf_tt-line.summ-netto       = ABSOLUTE(v-src-sum-netto)                                                      buf_tt-line.summ-netto-rub   = ABSOLUTE(v-src-sum-netto-rub)                                                      buf_tt-line.summ-brutto      = ABSOLUTE(v-src-sum)                                                             buf_tt-line.summ-brutto-rub  = ABSOLUTE(v-src-sum-rub)                                                             buf_tt-line.unit-base        = v-unit-base                             buf_tt-line.summ-discont     = ABSOLUTE(v-src-discnt)                             buf_tt-line.summ-discont-rub = ABSOLUTE(v-src-discnt-rub)
               p-message = substitute  ( "&1 &2x&3"                                      , substring(buf_tt-line.line-name + fill(' ':U,38),                                                1, 38 - 1 - length(trim(string(buf_tt-line.qnty,"->>>,>>>,>>9.<<<")) + 'X' + trim(string(buf_tt-line.price,"->>>,>>>,>>9.99")))  )                                    , trim(string(buf_tt-line.qnty,"->>>,>>>,>>9.<<<"))                                    , trim(string(buf_tt-line.price,"->>>,>>>,>>9.99"))           )
            .
            if not v-emul-mode
            then do:
define variable vss-include-info164 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#disp-lib ) <> TRUE then do:       run gbl/disp-lib.p persistent no-error.       if error-status :error or valid-handle( g#disp-lib ) <> TRUE then do:         message "Error starting disp-lib.p" skip( 0 )           g#disp-lib                        skip( 0 )           g#disp-lib    :type               skip( 0 )           g#disp-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run disp-str in g#disp-lib
    ( INPUT  v-disp-msg-1
    , INPUT  v-disp-msg-2
    , output p-message
    , output p-ok
    )  .
end.
            end.
            else do:
               assign
                  p-ok         = TRUE
               .
            end.
         end.
         WHEN 1 then do:
         end.
         OTHERWISE DO:
         end.
      end case.
   end.
   define variable v-num-str    as integer      no-undo.
   define variable v-gds-yes    as integer      no-undo.
   define variable v-pay-yes    as integer      no-undo.
define variable vss-include-info165 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  buf_tt-line.qnty
    , input  TODAY
    , input  50
    , input  TIME
    , input  'S':U
    , input  buf_tt-line.line-code
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  buf_tt-line.price
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  v-src-sum-netto
    , input  v-cntxt-userid
    ) no-error .
end.
   assign
      v-msg = p-message
   .
   define variable v-num-local   as integer      no-undo.
   define variable v-type-local  as integer      no-undo.
   if  INDEX(v-next, "=") > 0
   AND not v-recalc
   then do:
      assign
         v-recalc  = TRUE
         v-next    = TRIM(v-next, "recalc=")
         v-num-str = INTEGER(ENTRY(1, v-next, ","))
         v-gds-yes = INTEGER(ENTRY(2, v-next, ","))
         v-pay-yes = INTEGER(ENTRY(3, v-next, ","))
         v-num-local  = v-curr-num-0
         v-type-local = v-curr-type-0
      .
      run recalc-lines in this-procedure
                     ( input v-num-str
                     , input v-gds-yes
                     , input v-pay-yes
                     , input-output p-cd-mode
                     , INPUt-output p-cd-submode
                     , output p-message
                     , output p-ok
                     ) .
      assign
         v-src            = ""
         v-src-qnty       = 0.0
         v-src-price      = 0.0
         v-src-price-rub  = 0.0
         v-recalc  = FALSE
         v-curr-num-0     = v-num-local
         v-curr-type-0    = v-type-local
      .
   end.
   assign
      p-message    = v-msg
      v-src        = ""
      v-src-qnty   = 0.0
      v-src-price  = 0.0
      v-src-price-rub  = 0.0
      v-num        = 0
      p-cd-submode = "0"
      p-ok         = TRUE
   .
end.
end procedure.
procedure input-card :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
define buffer buf_tt-head-check     for tt-head-check .
define buffer buf_clients           for ub.clients .
define variable v-num-str    as integer      no-undo.
define variable v-gds-yes    as integer      no-undo.
define variable v-pay-yes    as integer      no-undo.
define variable v-msg    as character    no-undo.
do
on error undo, return error
:
   if p-cd-mode = "1"
   OR p-cd-mode = "2"
   then do:
      find buf_tt-head-check.
define variable vss-include-info166 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  v-d-card
    , input  '*':U
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  36
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
define variable vss-include-info167 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_set-card in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  v-src
  ,output v-d-card
  ,output v-cli-type
  ,output v-cli-code
  ,output v-obj-name
  ) no-error .
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok  = FALSE
            v-src = "":u
         .
define variable vss-include-info168 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  v-d-card
    , input  p-message
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  38
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
      find first buf_clients
           where buf_clients.obj-type = v-cli-type
             AND buf_clients.obj-code = v-cli-code
           NO-LOCK
           .
      assign
         v-obj-name   = if v-obj-name = "":U then buf_clients.obj-name else v-obj-name
         p-message    = substitute("Карта &1 клиент &2&3", v-src, buf_clients.obj-name)
         v-msg        = substitute("Карта &1 клиент &2&3", v-src, buf_clients.obj-name)
         p-cd-submode = "0"
         p-ok = TRUE
         v-src = "":u
         v-disp-msg-1             = buf_clients.obj-name
         v-disp-msg-2             = "":U
         buf_tt-head-check.d-card   = v-d-card
         buf_tt-head-check.cli-type = v-cli-type
         buf_tt-head-check.cli-code = v-cli-code
         buf_tt-head-check.obj-name = substitute("клиент &2 &3", v-cli-code, buf_clients.obj-name)
      .
define variable vss-include-info169 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  v-d-card
    , input  '*':U
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  37
    , input  TIME
    , input  'S':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
      if not v-emul-mode
      then do:
define variable vss-include-info170 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#disp-lib ) <> TRUE then do:       run gbl/disp-lib.p persistent no-error.       if error-status :error or valid-handle( g#disp-lib ) <> TRUE then do:         message "Error starting disp-lib.p" skip( 0 )           g#disp-lib                        skip( 0 )           g#disp-lib    :type               skip( 0 )           g#disp-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run disp-str in g#disp-lib
    ( INPUT  v-disp-msg-1
    , INPUT  v-disp-msg-2
    , output p-message
    , output p-ok
    )  .
end.
      end.
      define variable v-num-local   as integer      no-undo.
      define variable v-type-local  as integer      no-undo.
      assign
         v-num-local  = v-curr-num-0
         v-type-local = v-curr-type-0
      .
      run refresh-lines in this-procedure
                     (  output p-message
                     , output p-ok
                     ) .
      assign
         v-curr-num-0     = v-num-local
         v-curr-type-0    = v-type-local
         v-src            = ""
         v-src-qnty       = 0.0
         v-src-price      = 0.0
         v-src-price-rub  = 0.0
      .
   end.
end.
end procedure.
procedure set-input-time :
define input      parameter p-time as INTEGER        no-undo.
define output     parameter p-message     as character      no-undo .
define output     parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   assign
      v-input-time = p-time
   .
   if p-time > 500
   then do:
      assign
         v-pass-gds = 1
      .
   end.
   else do:
      if p-time < 0
      then do:
         assign
            v-pass-gds = -1
         .
      end.
      else do:
         assign
            v-pass-gds = 0
         .
      end.
   end.
end.
end procedure.
procedure clear-tt-chk :
define buffer buf_tt-head-check     for tt-head-check .
define buffer buf_tt-line           for tt-line .
define buffer buf_tt-open-check     for tt-open-check .
do
on error undo, return error
:
   EMPTY TEMP-TABLE buf_tt-head-check.
   EMPTY TEMP-TABLE buf_tt-line.
   EMPTY TEMP-TABLE buf_tt-open-check.
   assign
      v-src                = ""
      v-src-qnty           = 0
      v-curr-num-0         = 0
      v-curr-type-0        = 0
      v-input-time         = 0
      v-pay-type           = ?
      v-curr-base-code     = v-cd-base-code
      v-d-card             = ""
      v-cli-type           = ""
      v-cli-code           = 0
      v-obj-name           = ""
      v-summ-netto         = 0
      v-summ-brutto        = 0
      v-summ-discont       = 0
      v-summ-netto-rub     = 0
      v-summ-brutto-rub    = 0
      v-summ-discont-rub   = 0
      v-discnt-chk         = 0
      v-summ-pay           = 0
      v-summ-pay-rub       = 0
      v-disc-type          = "":U
      v-with-context       = TRUE
      v-num                = 0
      v-ord-chk-num        = "":U
      v-ord-line-num       = 0
      v-aux-mess           = ''
   .
end.
end procedure.
procedure set-cashier :
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
define variable vss-include-info171 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
   define buffer buf_user-account      for ub.user-account .
   define buffer buf_staff      for ub.staff .
   define buffer buf_clients     for ub.clients .
   define buffer buf_person      for ub.person .
   define variable v-first-name    as character    no-undo.
   define variable v-second-name    as character    no-undo.
   find first buf_user-account
        where buf_user-account.user-id = v-cntxt-userid
        no-lock
        .
   find  first buf_staff
         where buf_staff.role  = 'C':U
      and buf_staff.role-level = 'db':U
      and buf_staff.date-start <= today
      and buf_staff.date-end >= today
      and buf_staff.psn-code = buf_user-account.psn-code
      and buf_staff.db-num     = v-cntxt-db-num
      no-lock
      no-error.
   if not available buf_staff
   then do:
       message
         "Пользователь"
         SKIP "ID:"        buf_user-account.user-id
         SKIP "Фамилия:"   buf_user-account.last-name
         skip "Псевдоним:" buf_user-account.nik
         skip "БД:"        v-cntxt-db-num
         skip "не является кассиром. Работа с кассой невозможна."
       view-as alert-box error.
       return.
   end.
   find first buf_clients
        where buf_clients.obj-type = 'чел':U
          AND buf_clients.obj-code = buf_user-account.psn-code
        NO-LOCK
        .
   find first buf_person
        where buf_person.psn-code = buf_user-account.psn-code
        NO-LOCK
        .
   assign
      v-first-name  = SUBSTRING(TRIM(buf_person.name1), 1, 1)
      v-second-name = SUBSTRING(TRIM(buf_person.name2), 1, 1)
   .
   Assign
      v-cashier          = buf_staff.staff-code
      v-cashier-psn-code = buf_user-account.psn-code
      v-cashier-name     = Substitute( "Кассир &1 &2&3 &4&5"
                                     , buf_clients.obj-name
                                     , v-first-name
                                     , if v-first-name <> "":U then "." else "":U
                                     , v-second-name
                                     , if v-second-name <> "":U then "." else "":U
                                     )
      p-ok               = TRUE
   .
end.
end procedure.
procedure subm-qnty :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   if p-cd-mode = "1"
   OR p-cd-mode = "2"
   then do:
      assign
         p-cd-submode = "1"
         p-ok         = TRUE
      .
   end.
end.
end procedure.
procedure 1997 :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
define buffer buf_rule-call-param   for ub.rule-call-param .
define variable v-sel    as logical      no-undo.
do
on error undo, return error
:
   case p-cd-mode :
      WHEN "1" OR
      WHEN "2" then do:
         if p-cd-submode = "0"
         then do:
            assign
               p-message    = "Регистрация продавца"
               p-cd-submode = "8"
               p-ok         = TRUE
            .
         end.
         if p-cd-submode = "8"
         then do:
            for each  buf_rule-call-param
               where buf_rule-call-param.call_id = buf_temp-layout-elem-rule.uniq-key-rec
               no-lock
               :
               case buf_rule-call-param.param-name:
                  WHEN "p-seller"
                  then do:
                     if  buf_rule-call-param.param-value-integer <> 0
                     AND buf_rule-call-param.param-value-integer <> ?
                     then do:
                     assign
                        v-src = STRING(buf_rule-call-param.param-value-integer)
                        v-sel = TRUE
                     .
                     end.
                  end.
                  OTHERWISE DO:
                  end.
               end case.
            end.
            if v-sel
            then do:
               run input-saller  ( INPUt-OUTPUT p-cd-mode
                                 , INPUt-output p-cd-submode
                                 , output p-message
                                 , output p-ok
                                 ) .
            end.
         end.
      end.
      OTHERWISE DO:
      end.
   end case.
end.
end procedure.
procedure get-mode-name :
define input  parameter p-cd-mode     as character          no-undo.
define input  parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define buffer buf_tt-head-check     for tt-head-check .
define variable v-type    as integer    no-undo.
do
on error undo, return error
:
   find  first tt-cdm
         where tt-cdm.cd-mode = p-cd-mode
         NO-LOCK
         no-error
         .
   if available tt-cdm
   then do:
      case p-cd-mode:
         WHEN "8"
         then do:
            find first buf_tt-head-check no-error.
            if available buf_tt-head-check
            then do:
               assign
                  v-type = buf_tt-head-check.chk-type
               .
            end.
                  assign
                     p-message = "Чеки МЦ"
                     p-ok      = TRUE
                  .
         end.
         OTHERWISE DO:
            assign
               p-message = tt-cdm.cdm-name
               p-ok      = TRUE
            .
         end.
      end case.
   end.
   else do:
      assign
         p-message = "   "
      .
   end.
end.
end procedure.
procedure get-submode-name :
define input  parameter p-cd-mode     as character          no-undo.
define input  parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   find first tt-func-key
        where tt-func-key.cd-mode    = p-cd-mode
         AND  tt-func-key.cd-submode = p-cd-submode
         AND  tt-func-key.key-name   = "v-src-input"
        NO-LOCK
        No-error
        .
   if available tt-func-key
   then do:
      assign
         p-message = tt-func-key.key_label
         p-ok      = TRUE
      .
   end.
   else do:
      assign
         p-message = "   "
      .
   end.
end.
end procedure.
procedure get-chk-num :
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
  find tt-head-check no-error.
  if available tt-head-check
  then do:
     assign
         p-message =  STRING( tt-head-check.doc-code )
     .
  end.
  else do:
     assign
         p-ok = TRUE
     no-error.
  end.
end.
end procedure.
procedure input-saller :
define input-OUTPUT parameter p-cd-mode     as character          no-undo.
define input-OUTPUT parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define buffer buf_tt-head-check     for tt-head-check .
define buffer buf_tt-line     for tt-line .
define buffer buf_clients     for ub.clients .
define buffer buf_person      for ub.person .
define variable v-num-line    as integer      no-undo.
define variable v-password    as character    no-undo.
define variable v-seller-code as integer      no-undo.
define variable v-psn-seller-code as integer      no-undo.
do
on error undo, return error
:
   if v-curr-type-0 <> 0
   then do:
      assign
         p-message = "Продавца можно установить только на товарную строку"
         p-ok = FALSE
      .
      return.
   end.
   if p-cd-mode = "1"
   OR p-cd-mode = "2"
   then do:
      find buf_tt-head-check.
      find last  buf_tt-line
           where buf_tt-line.type = 0
             AND buf_tt-line.num  = v-curr-num-0
           no-error
           .
define variable vss-include-info172 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  1
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  v-psn-seller-code
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  39
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
      assign
         v-seller-code = INTEGER(v-src)
      no-error.
      if error-status:error
      then do:
         assign
            p-message = substitute("Введенный код &1- не число.", v-seller-code)
            p-ok      = FALSE
         .
define variable vss-include-info173 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  1
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  41
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return .
      end.
      assign
         v-num-line = v-curr-num-0
      .
      v-psn-seller-code = gbclcode-is-this-db-role ( input 'S':U
                                                   , input v-cntxt-db-num
                                                   , input v-seller-code
                                                   , input TODAY
                                                   ) .
      if v-psn-seller-code = 0
      then do:
         assign
            p-message = substitute("Не найден продавец с кодом &1", v-seller-code )
            p-ok = FALSE
         .
         return.
      end.
define variable vss-include-info174 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_set-salesman in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  v-num-line
  ,input  v-seller-code
  ,input  v-psn-seller-code
  ,output p-ok
  ) no-error .
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
define variable vss-include-info175 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  1
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  41
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
      find first buf_clients
           where buf_clients.obj-type = 'чел':U
             AND buf_clients.obj-code = v-psn-seller-code
           NO-LOCK
           .
      find first buf_person
           where buf_person.psn-code = v-psn-seller-code
           NO-LOCK
           .
      assign
         p-message    = substitute("Продавец &1 &2&3 &4&5"
                        , buf_clients.obj-name
                        , SUBSTRING( buf_person.name1, 1, 1 )
                        , if buf_person.name1 = "":U then "" else ".":U
                        , SUBSTRING( buf_person.name2, 1, 1 )
                        , if buf_person.name2 = "":U then "" else ".":U
                        )
         v-disp-msg-1 = "Продавец"
         v-disp-msg-2 = substitute("&1 &2&3 &4&5"
                        , buf_clients.obj-name
                        , SUBSTRING( buf_person.name1, 1, 1 )
                        , if buf_person.name1 = "":U then "" else ".":U
                        , SUBSTRING( buf_person.name2, 1, 1 )
                        , if buf_person.name2 = "":U then "" else ".":U
                        )
         p-cd-submode = "0"
         p-ok = TRUE
      .
      if not v-emul-mode
      then do:
define variable vss-include-info176 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#disp-lib ) <> TRUE then do:       run gbl/disp-lib.p persistent no-error.       if error-status :error or valid-handle( g#disp-lib ) <> TRUE then do:         message "Error starting disp-lib.p" skip( 0 )           g#disp-lib                        skip( 0 )           g#disp-lib    :type               skip( 0 )           g#disp-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run disp-str in g#disp-lib
    ( INPUT  v-disp-msg-1
    , INPUT  v-disp-msg-2
    , output p-message
    , output p-ok
    )  .
end.
      end.
      if v-num-line = 0
      then do:
         assign
            buf_tt-head-check.chk-seller-code = v-seller-code
            buf_tt-head-check.chk-seller-name = buf_clients.obj-name
         .
      end.
      else do:
         assign
            buf_tt-head-check.chk-seller-code = v-seller-code
            buf_tt-head-check.chk-seller-name = buf_clients.obj-name
            buf_tt-line.line-seller-code      = v-seller-code
            buf_tt-line.line-seller-name      = buf_clients.obj-name
         .
      end.
define variable vss-include-info177 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  1
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  v-disp-msg-2
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  40
    , input  TIME
    , input  'S':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
   end.
end.
end procedure.
procedure get-card-num :
define output parameter p-card     as character      no-undo .
define output parameter p-clients     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   assign
      p-card    = v-d-card
      p-clients = v-obj-name
      p-ok      = TRUE
   .
end.
end procedure.
procedure get-aux-mess :
define output parameter p-aux-mess  as character     no-undo.
define output parameter p-ok as logical no-undo .
do
on error undo, return error
:
   assign
      p-aux-mess    = v-aux-mess
      p-ok      = TRUE
   .
end.
end procedure.
procedure input-pay-sale :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define buffer buf_tt-line     for tt-line .
define buffer buf_tt-head-check     for tt-head-check .
define buffer buf_cash-pay    for ub.cash-pay .
define variable v-pline-num as integer no-undo .
define variable v-mode as character no-undo .
define variable v-pass-pay as integer no-undo .
define variable v-pay-card as character no-undo .
define variable v-tot-sum as decimal no-undo .
define variable v-tot-rubl as decimal no-undo .
define variable v-tot-base as decimal no-undo .
define variable v-par-code as integer   no-undo .
define variable v-src-qnty as decimal no-undo .
define variable v-get-qnty-method as character no-undo .
define variable v-2-cdpay-code as integer no-undo .
define variable v-2-curr-code as integer no-undo .
define variable v-2-tot-base as decimal no-undo .
define variable v-2-tot-rubl as decimal no-undo .
define variable v-2-frpay-code as integer no-undo .
define variable v-slip        as character    no-undo.
define variable v-found-pay   as logical      no-undo .
define variable v-summ-pay-2  as decimal      no-undo .
define variable v-summ-pay-curr  as decimal      no-undo .
define variable v-card-lst    as character    no-undo.
define variable v-card-num    as character    no-undo.
define variable v-card-type   as character    no-undo.
define variable v-src-discnt-local    as decimal      no-undo.
define variable v-src-discnt-local-rub    as decimal      no-undo.
define variable v-for-discnt-local-doc    as decimal no-undo .
define variable v-for-discnt-local-rubl   as decimal no-undo .
define variable v-for-discnt-local-r-b    as decimal no-undo .
do
on error undo, return error
:
   find buf_tt-head-check.
   find last buf_tt-line where buf_tt-line.type = 1 no-error.
   assign
      v-pline-num = if available buf_tt-line then buf_tt-line.num + 1 else 1
      v-mode = 'ДОБАВЛЕНИЕ':U
      v-pass-pay  = 0
      v-pay-card  = "0"
      v-tot-sum   = if ((p-cd-mode = "2") OR (buf_tt-head-check.chk-type = INTEGER('2':U))) then - DECIMAL(v-src) else DECIMAL(v-src)
      v-tot-rubl  = if ((p-cd-mode = "2") OR (buf_tt-head-check.chk-type = INTEGER('2':U))) then - DECIMAL(v-src) else DECIMAL(v-src)
      v-tot-base  = ?
   .
   if v-with-context
   then do:
define variable vss-include-info178 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  0
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  19
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-src
    , input  v-cntxt-userid
    ) no-error .
end.
      if error-status:error
      then do:
         message
            "Z"  19
            skip error-status:get-message(1)
            skip return-value
         view-as alert-box information.
      end.
   end.
   case p-cd-mode:
      WHEN "1"
      then do:
         if v-with-context
         then do:
            assign
               v-frpay-code = ?
            .
define variable vss-include-info179 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_pay-line in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  v-pline-num
  ,input  v-mode
  ,input-output  v-pay-type
  ,input-output  v-curr-base-code
  ,input  v-par-code
  ,input  v-src-qnty
  ,output v-frpay-code
  ,input  v-pass-pay
  ,input  v-pay-card
  ,input-output  v-tot-sum
  ,input-output  v-tot-rubl
  ,input-output  v-tot-base
  ,output v-get-qnty-method
  ,output v-2-cdpay-code
  ,output v-2-curr-code
  ,output v-2-frpay-code
  ,output v-2-tot-sum
  ,output v-2-tot-rubl
  ,output v-2-tot-base
  ,output v-src-discnt
  ,output v-src-discnt-rub
  ,output v-for-discnt-doc
  ,output v-for-discnt-rubl
  ,output v-for-discnt-r-b
  ,output p-ok
  ) no-error .
            if error-status:error
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
define variable vss-include-info180 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  0
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  21
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-tot-sum
    , input  v-cntxt-userid
    ) no-error .
end.
               if error-status:error
               then do:
                  message
                     "Z"  21
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.
               return.
            end.
         end.
         find first buf_cash-pay
               where buf_cash-pay.cdpay-code = v-pay-type
                  AND buf_cash-pay.curr-code  = v-curr-base-code
               NO-LOCK
               no-error
               .
         if buf_cash-pay.atr16
         AND not v-emul-mode
         AND v-with-context
         then do:
define variable vss-include-info181 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  22
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-tot-rubl
    , input  v-cntxt-userid
    ) no-error .
end.
define variable vss-include-info182 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#sb-lib ) <> TRUE then do:       run gbl/sb-lib.p persistent no-error.       if error-status :error or valid-handle( g#sb-lib ) <> TRUE then do:         message "Error starting sb-lib.p" skip( 0 )           g#sb-lib                        skip( 0 )           g#sb-lib    :type               skip( 0 )           g#sb-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run sb-sale in g#sb-lib
    ( input  v-tot-rubl
    , output v-slip
    , output v-pay-card
    , output p-message
    , output p-ok
    ) no-error .
end.
            if error-status:error
            OR not p-ok
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
define variable vss-include-info183 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  0
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  21
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-tot-rubl
    , input  v-cntxt-userid
    ) no-error .
end.
               if error-status:error
               then do:
                  message
                     "Z"  21
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.
define variable vss-include-info184 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  24
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  v-pay-card
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-tot-rubl
    , input  v-cntxt-userid
    ) no-error .
end.
            end.
            else do:
               run print-slip in this-procedure (input v-slip, output p-message, output p-ok) .
               run print-head-chk   ( output p-message
                                    , output p-ok
                                    ) .
            end.
define variable vss-include-info185 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  23
    , input  TIME
    , input  'S':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  v-pay-card
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-tot-rubl
    , input  v-cntxt-userid
    ) no-error .
end.
            if not p-ok
            then do:
               assign
                  v-mode = 'удаление':U
               .
define variable vss-include-info186 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_pay-line in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  v-pline-num
  ,input  v-mode
  ,input-output  v-pay-type
  ,input-output  v-curr-base-code
  ,input  v-par-code
  ,input  v-src-qnty
  ,output v-frpay-code
  ,input  v-pass-pay
  ,input  v-pay-card
  ,input-output  v-null-summ
  ,input-output  v-null-summ
  ,input-output  v-tot-base
  ,output v-get-qnty-method
  ,output v-2-cdpay-code
  ,output v-2-curr-code
  ,output v-2-frpay-code
  ,output v-2-tot-sum
  ,output v-2-tot-rubl
  ,output v-2-tot-base
  ,output v-src-discnt-local
  ,output v-src-discnt-local-rub
  ,output v-for-discnt-local-doc
  ,output v-for-discnt-local-rubl
  ,output v-for-discnt-local-r-b
  ,output p-ok
  ) no-error .
               if error-status:error
               then do:
                  assign
                     p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                     p-ok = FALSE
                  .
                  return.
               end.
               return.
            end.
            assign
               v-mode = 'ИЗМЕНЕНИЕ':U
            .
define variable vss-include-info187 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_pay-line in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  v-pline-num
  ,input  v-mode
  ,input-output  v-pay-type
  ,input-output  v-curr-base-code
  ,input  v-par-code
  ,input  v-src-qnty
  ,output v-frpay-code
  ,input  v-pass-pay
  ,input  v-pay-card
  ,input-output  v-tot-sum
  ,input-output  v-tot-rubl
  ,input-output  v-tot-base
  ,output v-get-qnty-method
  ,output v-2-cdpay-code
  ,output v-2-curr-code
  ,output v-2-frpay-code
  ,output v-2-tot-sum
  ,output v-2-tot-rubl
  ,output v-2-tot-base
  ,output v-src-discnt-local
  ,output v-src-discnt-local-rub
  ,output v-for-discnt-local-doc
  ,output v-for-discnt-local-rubl
  ,output v-for-discnt-local-r-b
  ,output p-ok
  ) no-error .
            if error-status:error
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
define variable vss-include-info188 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  0
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  21
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-tot-sum
    , input  v-cntxt-userid
    ) no-error .
end.
               if error-status:error
               then do:
                  message
                     "Z"  21
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.
               return.
            end.
         end.
         CREATE buf_tt-line.
         assign
            buf_tt-line.type         = 1
            buf_tt-line.num          = v-pline-num
            buf_tt-line.line-name    = substitute("    Оплата &1", buf_cash-pay.obj-name  )
            buf_tt-line.line-code    = v-pay-type
            buf_tt-line.curr-code    = v-curr-base-code
            buf_tt-line.fr-pay-code  = v-frpay-code
            buf_tt-line.summ-netto-rub = ABSOLUTE(v-tot-rubl)
            buf_tt-line.summ-netto   = ABSOLUTE(v-tot-base)
            buf_tt-line.pay-card     = v-pay-card
            buf_tt-line.summ-discont = v-src-discnt
            buf_tt-line.summ-discont-rub = v-src-discnt-rub
            buf_tt-line.qnty         = v-tot-sum
            buf_tt-line.src          = STRING(v-pay-type)
            buf_tt-line.summ-brutto  = v-for-discnt-rubl
            buf_tt-line.line-name-2  = v-src
            buf_tt-line.slip         = v-slip
            v-curr-base-code         = v-cd-base-code
            p-ok                     = TRUE
            v-pay-type               = ?
            v-curr-num-0             = v-pline-num
            v-curr-type-0            = 1
         .
         if v-with-context
         then do:
            run set-all-summ ( output p-message
                           , output p-ok
                           ) no-error.
         end.
         if TRUNCATE(v-summ-netto-rub, 2) <= TRUNCATE(v-summ-pay-rub, 2)
         then do:
            assign
               p-cd-submode       = "0"
            .
         end.
         assign
            v-disp-msg-1             = substitute  ( " Оплата &1"
                                                   , buf_cash-pay.obj-name
                                                   )
            v-disp-msg-2             = substitute  ( "&1 &2"
                                                   , if (p-cd-mode = "2") then - v-tot-rubl else v-tot-rubl
                                                   , v-cd-base-name
                                                   )
         .
         assign
            p-message    = substitute  ( "Оплата &1 &2"
                                       , buf_cash-pay.obj-name
                                       , if (p-cd-mode = "2") then - v-tot-rubl else v-tot-rubl
                                       )
         .
      end.
      WHEN "2"
      then do:
         if v-with-context
         then do:
            assign
               v-frpay-code = ?
            .
define variable vss-include-info189 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_pay-line in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  v-pline-num
  ,input  v-mode
  ,input-output  v-pay-type
  ,input-output  v-curr-base-code
  ,input  v-par-code
  ,input  v-src-qnty
  ,output v-frpay-code
  ,input  v-pass-pay
  ,input  v-pay-card
  ,input-output  v-tot-sum
  ,input-output  v-tot-rubl
  ,input-output  v-tot-base
  ,output v-get-qnty-method
  ,output v-2-cdpay-code
  ,output v-2-curr-code
  ,output v-2-frpay-code
  ,output v-2-tot-sum
  ,output v-2-tot-rubl
  ,output v-2-tot-base
  ,output v-src-discnt
  ,output v-src-discnt-rub
  ,output v-for-discnt-doc
  ,output v-for-discnt-rubl
  ,output v-for-discnt-r-b
  ,output p-ok
  ) no-error .
            if error-status:error
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
define variable vss-include-info190 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  0
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  21
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-tot-sum
    , input  v-cntxt-userid
    ) no-error .
end.
               if error-status:error
               then do:
                  message
                     "Z"  21
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.
               return.
            end.
         end.
         find first buf_cash-pay
              where buf_cash-pay.cdpay-code = v-pay-type
                AND buf_cash-pay.curr-code  = v-curr-base-code
              NO-LOCK
              no-error
              .
         run accum-curr-chk-pay in this-procedure ( input  buf_cash-pay.pay-code
                                             , input  v-curr-base-code
                                             , input  v-card-num
                                             , output v-summ-pay-curr
                                             ) .
         run accum-chk-pay in this-procedure ( input  buf_cash-pay.cdpay-code
                                             , input  v-curr-base-code
                                             , input  v-card-num
                                             , output v-found-pay
                                             , output v-summ-pay-2
                                             ) .
         if  v-summ-pay-2 < (ABS(v-tot-rubl) - v-summ-pay-curr)
         AND v-found-pay
         then do:
            message
            "Максимальная сумма, которую вы можете вернуть" skip
            "этим типом платежа, по этому чеку:" SKIP
            v-summ-pay-2 skip
            view-as alert-box information.
            assign
            v-mode = 'удаление':U
            .
define variable vss-include-info191 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_pay-line in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  v-pline-num
  ,input  v-mode
  ,input-output  v-pay-type
  ,input-output  v-curr-base-code
  ,input  v-par-code
  ,input  v-src-qnty
  ,output v-frpay-code
  ,input  v-pass-pay
  ,input  v-pay-card
  ,input-output  v-null-summ
  ,input-output  v-null-summ
  ,input-output  v-tot-base
  ,output v-get-qnty-method
  ,output v-2-cdpay-code
  ,output v-2-curr-code
  ,output v-2-frpay-code
  ,output v-2-tot-sum
  ,output v-2-tot-rubl
  ,output v-2-tot-base
  ,output v-src-discnt-local
  ,output v-src-discnt-local-rub
  ,output v-for-discnt-local-doc
  ,output v-for-discnt-local-rubl
  ,output v-for-discnt-local-r-b
  ,output p-ok
  ) no-error .
            if error-status:error
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
define variable vss-include-info192 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  0
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  21
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-tot-sum
    , input  v-cntxt-userid
    ) no-error .
end.
               if error-status:error
               then do:
                  message
                     "Z"  21
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.
               return.
            end.
            return .
         end.
         if buf_cash-pay.atr16
         AND not v-emul-mode
         and v-with-context
         then do:
define variable vss-include-info193 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#sb-lib ) <> TRUE then do:       run gbl/sb-lib.p persistent no-error.       if error-status :error or valid-handle( g#sb-lib ) <> TRUE then do:         message "Error starting sb-lib.p" skip( 0 )           g#sb-lib                        skip( 0 )           g#sb-lib    :type               skip( 0 )           g#sb-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run sb-cardinfo in g#sb-lib
    ( output v-card-num
    , output v-card-type
    , output p-message
    , output p-ok
    ) no-error .
end.
            if error-status:error
            OR not p-ok
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
define variable vss-include-info194 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  0
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  21
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-tot-sum
    , input  v-cntxt-userid
    ) no-error .
end.
               if error-status:error
               then do:
                  message
                     "Z"  21
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.
            end.
define variable vss-include-info195 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  22
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-tot-rubl
    , input  v-cntxt-userid
    ) no-error .
end.
define variable vss-include-info196 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#sb-lib ) <> TRUE then do:       run gbl/sb-lib.p persistent no-error.       if error-status :error or valid-handle( g#sb-lib ) <> TRUE then do:         message "Error starting sb-lib.p" skip( 0 )           g#sb-lib                        skip( 0 )           g#sb-lib    :type               skip( 0 )           g#sb-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run sb-ret in g#sb-lib
    ( input  v-tot-rubl
    , input  v-pay-card
    , output v-slip
    , output p-message
    , output p-ok
    ) no-error .
end.
            if error-status:error
            OR not p-ok
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
define variable vss-include-info197 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  0
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  21
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-tot-rubl
    , input  v-cntxt-userid
    ) no-error .
end.
define variable vss-include-info198 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  24
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  v-pay-card
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-tot-rubl
    , input  v-cntxt-userid
    ) no-error .
end.
               if error-status:error
               then do:
                  message
                     "Z"  21
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.
            end.
            else do:
               run print-slip in this-procedure (input v-slip, output p-message, output p-ok) .
               run print-head-chk   ( output p-message
                                    , output p-ok
                                    ) .
            end.
define variable vss-include-info199 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  23
    , input  TIME
    , input  'S':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  v-pay-card
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-tot-rubl
    , input  v-cntxt-userid
    ) no-error .
end.
            if not p-ok
            then do:
               assign
                  v-mode = 'удаление':U
               .
define variable vss-include-info200 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_pay-line in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  v-pline-num
  ,input  v-mode
  ,input-output  v-pay-type
  ,input-output  v-curr-base-code
  ,input  v-par-code
  ,input  v-src-qnty
  ,output v-frpay-code
  ,input  v-pass-pay
  ,input  v-pay-card
  ,input-output  v-null-summ
  ,input-output  v-null-summ
  ,input-output  v-tot-base
  ,output v-get-qnty-method
  ,output v-2-cdpay-code
  ,output v-2-curr-code
  ,output v-2-frpay-code
  ,output v-2-tot-sum
  ,output v-2-tot-rubl
  ,output v-2-tot-base
  ,output v-src-discnt-local
  ,output v-src-discnt-local-rub
  ,output v-for-discnt-local-doc
  ,output v-for-discnt-local-rubl
  ,output v-for-discnt-local-r-b
  ,output p-ok
  ) no-error .
               if error-status:error
               then do:
                  assign
                     p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                     p-ok = FALSE
                  .
                  return.
               end.
               return.
            end.
            assign
               v-mode = 'ИЗМЕНЕНИЕ':U
            .
define variable vss-include-info201 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_pay-line in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  v-pline-num
  ,input  v-mode
  ,input-output  v-pay-type
  ,input-output  v-curr-base-code
  ,input  v-par-code
  ,input  v-src-qnty
  ,output v-frpay-code
  ,input  v-pass-pay
  ,input  v-pay-card
  ,input-output  v-tot-sum
  ,input-output  v-tot-rubl
  ,input-output  v-tot-base
  ,output v-get-qnty-method
  ,output v-2-cdpay-code
  ,output v-2-curr-code
  ,output v-2-frpay-code
  ,output v-2-tot-sum
  ,output v-2-tot-rubl
  ,output v-2-tot-base
  ,output v-src-discnt-local
  ,output v-src-discnt-local-rub
  ,output v-for-discnt-local-doc
  ,output v-for-discnt-local-rubl
  ,output v-for-discnt-local-r-b
  ,output p-ok
  ) no-error .
            if error-status:error
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
define variable vss-include-info202 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  0
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  21
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-tot-sum
    , input  v-cntxt-userid
    ) no-error .
end.
            if error-status:error
            then do:
               message
                  "Z"  21
                  skip error-status:get-message(1)
                  skip return-value
               view-as alert-box information.
            end.
               return.
            end.
         end.
         CREATE buf_tt-line.
         assign
            buf_tt-line.type        = 1
            buf_tt-line.num         = v-pline-num
            buf_tt-line.line-name   = substitute("    Оплата &1", buf_cash-pay.obj-name  )
            buf_tt-line.line-code   = v-pay-type
            buf_tt-line.curr-code   = v-curr-base-code
            buf_tt-line.fr-pay-code = v-frpay-code
            buf_tt-line.summ-netto-rub = ABSOLUTE(v-tot-rubl)
            buf_tt-line.summ-netto   = ABSOLUTE(v-tot-base)
            buf_tt-line.pay-card    = v-pay-card
            buf_tt-line.qnty         = v-tot-sum
            buf_tt-line.summ-discont = v-src-discnt
            buf_tt-line.summ-discont-rub = v-src-discnt-rub
            buf_tt-line.src          = STRING(v-pay-type)
            buf_tt-line.summ-brutto  = ABSOLUTE(v-for-discnt-rubl)
            buf_tt-line.line-name-2  = v-src
            buf_tt-line.slip        = v-slip
            v-curr-base-code        = v-cd-base-code
            p-ok                    = TRUE
            v-pay-type              = ?
            v-curr-num-0            = v-pline-num
            v-curr-type-0           = 1
         .
         if v-with-context
         then do:
            run set-all-summ ( output p-message
                           , output p-ok
                           ) no-error.
         end.
         if v-summ-netto-rub <= v-summ-pay-rub
         then do:
            assign
               p-cd-submode       = "0"
            .
         end.
         assign
            p-message    = substitute("Оплата &1 &2"
                                    , buf_cash-pay.obj-name
                                    , if (p-cd-mode = "2") then - v-tot-rubl else v-tot-rubl
                                    )
            v-disp-msg-1             = substitute(" Оплата &1"
                                                  , buf_cash-pay.obj-name
                                                  )
            v-disp-msg-2             = substitute  ( "&1 &2"
                                                   , if (p-cd-mode = "2") then - v-tot-rubl else v-tot-rubl
                                                   , v-cd-base-name
                                                   )
         .
      end.
      WHEN "8"
      then do:
         if v-with-context
         then do:
            if buf_tt-head-check.chk-type = integer('2':U)
            and not v-emul-mode then do:
              define variable v-reg-value    as character    no-undo.
              define variable v-reg-name     as character    no-undo.
define variable vss-include-info203 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-get-reg in g#fr-lib
    ( input       'cash':U
    , input       241
    , output      v-reg-value
    , output      v-reg-name
    , output      p-message
    , output      p-ok
    ) no-error .
end.
              if error-status:error
              then do:
                assign
                p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                p-ok = FALSE
                .
                return.
              end.
              else do:
                assign
                v-summ-fr = DECIMAL(v-reg-value)
                .
              end.
              if  abs(v-tot-sum) > v-summ-fr
              then do:
                assign
                p-message = substitute("Суммы в ДЯ &1 недостаточно для инкассации", v-summ-fr)
                p-ok = no
                .
                return.
              end.
            end.
define variable vss-include-info204 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_inst-line in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  1
  ,input  'ДОБАВЛЕНИЕ':U
  ,input-output  v-pay-type
  ,input-output  v-curr-base-code
  ,input  v-par-code
  ,input  v-src-qnty
  ,output v-frpay-code
  ,input  v-pass-pay
  ,input  v-pay-card
  ,input-output  v-tot-sum
  ,input-output  v-tot-rubl
  ,input-output  v-tot-base
  ,output v-get-qnty-method
  ,output p-ok
  ) no-error .
            if error-status:error
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
define variable vss-include-info205 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  0
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  21
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-tot-sum
    , input  v-cntxt-userid
    ) no-error .
end.
               if error-status:error
               then do:
                  message
                     "Z"  21
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.
               return.
            end.
         end.
         find first buf_cash-pay
              where buf_cash-pay.cdpay-code = v-pay-type
                AND buf_cash-pay.curr-code  = v-curr-base-code
              NO-LOCK
              no-error
              .
         CREATE buf_tt-line.
         assign
            v-disp-msg-1            = if buf_tt-head-check.chk-type = INTEGER('2':U) then "Инкассация" else "Внесение денег"
            v-disp-msg-2            = substitute("&1 &2"
                                     , buf_cash-pay.obj-name
                                     , if (buf_tt-head-check.chk-type = INTEGER('2':U)) then - v-tot-rubl else v-tot-rubl
                                     )
            buf_tt-line.type         = 1
            buf_tt-line.num          = v-pline-num
            buf_tt-line.line-name    = substitute("Оплата &1", buf_cash-pay.obj-name  )
            buf_tt-line.line-code    = v-pay-type
            buf_tt-line.curr-code    = v-curr-base-code
            buf_tt-line.pay-card     = v-pay-card
            buf_tt-line.fr-pay-code  = v-frpay-code
            buf_tt-line.qnty         = v-tot-sum
            buf_tt-line.summ-netto-rub = ABSOLUTE(v-tot-rubl)
            buf_tt-line.summ-netto   = ABSOLUTE(v-tot-base)
            buf_tt-line.summ-brutto  = v-for-discnt-rubl
            buf_tt-line.line-name-2  = v-src
            buf_tt-line.src          = STRING(v-pay-type)
            v-curr-base-code         = v-cd-base-code
            p-ok                     = TRUE
            v-pay-type               = ?
            v-curr-num-0             = v-pline-num
            v-curr-type-0            = 1
         .
      end.
      OTHERWISE DO:
      end.
   end case.
   if v-with-context
   then do:
define variable vss-include-info206 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  0
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  20
    , input  TIME
    , input  'S':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  v-pay-card
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  buf_tt-line.summ-netto
    , input  v-cntxt-userid
    ) no-error .
end.
      if error-status:error
      then do:
         message
            "Z"  20
            skip error-status:get-message(1)
            skip return-value
         view-as alert-box information.
      end.
   end.
   if not v-emul-mode
   and    v-with-context
   then do:
define variable vss-include-info207 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#disp-lib ) <> TRUE then do:       run gbl/disp-lib.p persistent no-error.       if error-status :error or valid-handle( g#disp-lib ) <> TRUE then do:         message "Error starting disp-lib.p" skip( 0 )           g#disp-lib                        skip( 0 )           g#disp-lib    :type               skip( 0 )           g#disp-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run disp-str in g#disp-lib
    ( INPUT  v-disp-msg-1
    , INPUT  v-disp-msg-2
    , output p-message
    , output p-ok
    )  .
end.
   end.
   else do:
      assign
         p-ok = TRUE
      .
   end.
   assign
      v-src        = ""
      v-src-qnty   = 0.0
      v-src-price  = 0.0
      v-src-price-rub  = 0.0
      p-message = v-disp-msg-1 + " ":U + v-disp-msg-2
   .
end.
end PROCEDURE.
procedure pr-esc :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   define buffer bf_tt-head-check     for tt-head-check .
   find first bf_tt-head-check no-error.
   define variable vv-chk-type    as integer    no-undo.
   define variable vv-doc-code    as character    no-undo.
   if available bf_tt-head-check
   then do:
      assign
         vv-chk-type = bf_tt-head-check.chk-type
         vv-doc-code = bf_tt-head-check.doc-code
      .
      RELEASE bf_tt-head-check.
   end.
define variable vss-include-info208 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  2
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  vv-chk-type
    , input  '':U
    , input  '*':U
    , input  0
    , input  vv-doc-code
    , input  '':U
    , input  TODAY
    , input  8
    , input  TIME
    , input  'S':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            if error-status:error
            then do:
               message
                  "Z"  8
                  skip error-status:get-message(1)
                  skip return-value
               view-as alert-box information.
            end.
   assign
      v-disc-type = "":U
      p-message   = chr(10)
   .
   if p-cd-mode = "0"
   then do:
define variable vss-include-info209 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  2
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  vv-chk-type
    , input  '':U
    , input  '*':U
    , input  0
    , input  vv-doc-code
    , input  '':U
    , input  TODAY
    , input  9
    , input  TIME
    , input  'S':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            if error-status:error
            then do:
               message
                  "Z"  9
                  skip error-status:get-message(1)
                  skip return-value
               view-as alert-box information.
            end.
      run pr-empty in this-procedure (output p-message, output p-ok) .
   end.
   else do:
      if p-cd-submode <> "0"
      AND p-cd-mode <> "8"
      then do:
         assign
            v-src = ""
            p-cd-submode = "0"
            p-ok         = TRUE
         .
      end.
      else do:
         if p-cd-mode  = "1"
         OR p-cd-mode  = "2"
         OR p-cd-mode  = "7"
         OR (p-cd-mode = "8" AND CAN-find(tt-head-check))
         then do:
            assign
                              p-message = (if p-cd-mode = "8"
                            then substitute("Закройте или аннулируйте открытый чек (&1)", entry (lookup (string(vv-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))
                            else "Закройте, отложите или аннулируйте открытый чек."
                            )
               p-ok      = FALSE
            .
define variable vss-include-info210 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  2
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  vv-chk-type
    , input  '':U
    , input  p-message
    , input  0
    , input  vv-doc-code
    , input  '':U
    , input  TODAY
    , input  10
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            if error-status:error
            then do:
               message
                  "Z"  10
                  skip error-status:get-message(1)
                  skip return-value
               view-as alert-box information.
            end.
         end.
         else do:
            assign
               v-src        = ""
               p-cd-mode    = "0"
               p-cd-submode = "0"
               p-ok         = TRUE
            .
         end.
      end.
      if p-ok
      then do:
define variable vss-include-info211 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  2
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  vv-chk-type
    , input  '':U
    , input  '*':U
    , input  0
    , input  vv-doc-code
    , input  '':U
    , input  TODAY
    , input  9
    , input  TIME
    , input  'S':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            if error-status:error
            then do:
               message
                  "Z"  9
                  skip error-status:get-message(1)
                  skip return-value
               view-as alert-box information.
            end.
      end.
   end.
end.
end procedure.
procedure 1985 :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define buffer buf_chk-doc     for ub.chk-doc .
define buffer buf_chk-gds     for ub.chk-gds .
define buffer buf_tt-line     for tt-line .
define buffer buf_tt-head-check     for tt-head-check .
define variable v-doc-code    as character    no-undo.
define variable v-doc-code-list    as character    no-undo.
define variable v-chk-type    as integer      no-undo.
define variable v-b-code as integer no-undo .
define variable v-chk-name as character no-undo .
define variable v-second-name as character no-undo .
define variable v-setted as logical no-undo .
define variable v-gds-code as integer no-undo .
define variable v-src-sum as decimal no-undo .
define variable v-src-sum-netto as decimal no-undo .
define variable v-rid-list    as character    no-undo.
define variable v-count    as integer      no-undo.
define buffer buf_tt-open-check     for tt-open-check .
define variable v-chk-list-type    as logical      no-undo.
do
on error undo, return error
:
   case p-cd-mode:
      WHEN "1"
      then do:
         run str/chk-docs.w   ( input parparentproc
                              , input "b-sel,b-mark"
                              , input 'IBS-TH':U
                              , input ?
                              , input v-cntxt-obj-type
                              , input v-cntxt-obj-code
                              , input '':U
                              , input '':U
                              , input p-cash-num
                              , input ?
                              , input ?
                              , input integer('201':U)
                              , output v-rid-list) no-error.
         assign
            v-chk-type = integer('201':U)
         .
      end.
      WHEN "2"
      then do:
         run str/chk-docs.w   ( input parparentproc
                              , input "b-sel,b-mark"
                              , input 'IBS-TH':U
                              , input ?
                              , input v-cntxt-obj-type
                              , input v-cntxt-obj-code
                              , input '':U
                              , input '':U
                              , input p-cash-num
                              , input ?
                              , input ?
                              , input integer('206':U)
                              , output v-rid-list) no-error.
         assign
            v-chk-type = integer('206':U)
         .
      end.
      WHEN "0"
      then do:
         assign
            v-chk-list-type = ?
         .
         message
            "Открыть отложенный чек?"
            SKIP "ДА  - открыть отложенную продажу"
            skip "НЕТ - открыть отложенный возврат"
            SKIP "ОТМЕНА - отказ от выбора"
         view-as alert-box question
         BUTTONS YES-NO-CANCEL
         UPDATE v-chk-list-type
         .
         if v-chk-list-type = ?
         then do:
            assign
               p-message = "Отказ от выбора отложенного чека"
               p-ok = TRUE
            .
            return.
         end.
         if v-chk-list-type
         then do:
            run str/chk-docs.w   ( input parparentproc
                                 , input "b-sel,b-mark"
                                 , input 'IBS-TH':U
                                 , input ?
                                 , input v-cntxt-obj-type
                                 , input v-cntxt-obj-code
                                 , input '':U
                                 , input '':U
                                 , input p-cash-num
                                 , input ?
                                 , input ?
                                 , input integer('201':U)
                                 , output v-rid-list) no-error.
            assign
               v-chk-type = integer('201':U)
            .
            end.
         else do:
            run str/chk-docs.w   ( input parparentproc
                                 , input "b-sel,b-mark"
                                 , input 'IBS-TH':U
                                 , input ?
                                 , input v-cntxt-obj-type
                                 , input v-cntxt-obj-code
                                 , input '':U
                                 , input '':U
                                 , input p-cash-num
                                 , input ?
                                 , input ?
                                 , input integer('206':U)
                                 , output v-rid-list) no-error.
            assign
               v-chk-type = integer('206':U)
            .
         end.
      end.
      OTHERWISE DO:
      end.
   end case.
   if v-rid-list = "":U
   then do:
      return.
   end.
   run set-input-time in this-procedure ( input 0, output p-message, output p-ok ).
   if p-cd-mode = "0"
   then do:
      if v-chk-list-type
      then do:
         run chk-sale-open in this-procedure ( INPUt-OUTPUT p-cd-mode
                                             , input-output p-cd-submode
                                             , output p-message
                                             , output p-ok
                                             ) .
      end.
      else do:
         run 1987 in this-procedure ( INPUt-OUTPUT p-cd-mode
                                    , input-output p-cd-submode
                                    , output p-message
                                    , output p-ok
                                    ) .
      end.
   end.
   _proc-body:
   DO v-count = 1 to NUM-ENTRIES(v-rid-list)
   on error undo, NEXT
   :
      find first buf_chk-doc
         where RECID(buf_chk-doc) = INTEGER(ENTRY(v-count, v-rid-list))
         share-lock
         no-error
         NO-WAIT
         .
      if  not available buf_chk-doc
      and not locked buf_chk-doc
      then do:
         UNDO _proc-body, NEXT _proc-body .
      end.
      if locked buf_chk-doc
      then do:
         UNDO _proc-body, NEXT _proc-body .
      end.
      if  buf_chk-doc.chk-type <> integer('201':U)
      AND buf_chk-doc.chk-type <> integer('206':U)
      then do:
         UNDO _proc-body, NEXT _proc-body .
      end.
      if  buf_chk-doc.src-d-card <> ?
      AND buf_chk-doc.src-d-card <> ''
      then do:
         assign
            v-src = buf_chk-doc.src-d-card
         .
         run input-card in this-procedure ( INPUt-OUTPUT p-cd-mode
                                          , INPUt-output p-cd-submode
                                          , output p-message
                                          , output p-ok
                                          ) .
         if not p-ok then do:
            UNDO _proc-body, LEAVE _proc-body .
         end.
      end.
      assign
         v-pass-gds = 0
         v-doc-code-list = v-doc-code-list + "," + buf_chk-doc.doc-code
      .
      for each buf_chk-gds
         where buf_chk-gds.doc-code = buf_chk-doc.doc-code
         no-lock
      :
         find first buf_tt-line
              where buf_tt-line.ord-chk-num  = buf_chk-gds.doc-code
                AND buf_tt-line.ord-line-num = buf_chk-gds.line-num
              no-lock no-error.
         if available buf_tt-line then NEXT.
         case buf_chk-doc.chk-type:
            when integer('6':U) then do:
            assign
            v-write-off-code = 0
            .
            end.
         end case.
         assign
            v-src-price    = buf_chk-gds.src-price
            v-src-qnty     = buf_chk-gds.src-qnty
            v-num          = 0
            v-src          = buf_chk-gds.src-code
            v-pump         = buf_chk-gds.pump
            v-nozzle-code  = buf_chk-gds.nozzle-code
            v-pl-code      = buf_chk-gds.pl-code
            v-fbr-depart   = buf_chk-gds.depart-id
            v-ord-chk-num  = buf_chk-gds.doc-code
            v-ord-line-num = buf_chk-gds.line-num
         .
         run add-gds-line in this-procedure  ( INPUt-OUTPUT p-cd-mode
                                             , INPUt-output p-cd-submode
                                             , output p-message
                                             , output p-ok
                                             ) .
         if not p-ok then do:
            UNDO _proc-body, LEAVE _proc-body .
         end.
         if buf_chk-gds.sales-man > 0
         then do:
            find first buf_tt-line
               where buf_tt-line.ord-chk-num  = buf_chk-gds.doc-code
                  AND buf_tt-line.ord-line-num = buf_chk-gds.line-num
               no-lock
               .
            assign
               v-src = STRING(buf_chk-gds.sales-man)
            .
            run input-saller in this-procedure (input-output p-cd-mode, input-output p-cd-submode, output p-message, output p-ok).
         end.
      end.
      if not CAN-find (first buf_tt-open-check
                       where buf_tt-open-check.doc-code = buf_chk-doc.doc-code
                         AND buf_tt-open-check.chk-type = buf_chk-doc.chk-type
                       )
      then do:
         create buf_tt-open-check.
         assign
            buf_tt-open-check.doc-code = buf_chk-doc.doc-code
            buf_tt-open-check.chk-type = buf_chk-doc.chk-type
         .
      end.
   end.
   assign
      v-doc-code-list = TRIM( v-doc-code-list , "," )
   .
define variable vss-include-info212 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  1
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  v-chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  v-doc-code-list
    , input  '':U
    , input  TODAY
    , input  60
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-rid-list
    , input  v-cntxt-userid
    ) no-error .
end.
end.
end procedure.
procedure 1994 :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   assign
      p-message = "Поиск товара по чеку"
      p-cd-submode = "6"
      p-ok              = TRUE
   .
end.
end procedure.
procedure 1981 :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define buffer buf_tt-line     for tt-line .
do
on error undo, return error
:
     if p-cd-submode = "0"
      then do:
      run adm/chk-pass.w   ( input parparentproc
                              , input v-cntxt-userid
                              , input v-cntxt-db-num
                              , input "actn_ibsthpos-discont"
                              , input FALSE
                              , output p-message
                              , output p-ok
                              ) .
         if CAN-find (first buf_tt-line where buf_tt-line.type = 1 NO-LOCK)
         then do:
            assign
               p-message = "Скидка должна быть задана до принятия платежей"
               p-ok      = FALSE
            .
         end.
         if not p-ok
         then return.
         assign
            p-message   = "Cкидка на итог"
            p-cd-submode = "5"
            p-ok = TRUE
         .
      end.
     if p-cd-submode =  "5"
      then do:
         define buffer buf_rule-call-param   for ub.rule-call-param .
         define buffer buf_cash-pay          for ub.cash-pay .
         define variable v-type    as logical      no-undo.
         define variable v-value    as logical      no-undo.
         for each  buf_rule-call-param
               where buf_rule-call-param.call_id = buf_temp-layout-elem-rule.uniq-key-rec
               no-lock
            :
            case buf_rule-call-param.param-name:
               WHEN "p-discnt-v-type"
               then do:
                  if  buf_rule-call-param.param-value-integer <> 0
                  AND buf_rule-call-param.param-value-integer <> ?
                  then
                  assign
                     v-disc-type       = STRING(buf_rule-call-param.param-value-integer)
                     v-type            = TRUE
                  .
               end.
               WHEN "p-discnt-value"
               then do:
                  if  buf_rule-call-param.param-value-decimal <> 0
                  AND buf_rule-call-param.param-value-decimal <> ?
                  then
                  assign
                     v-src = STRING(buf_rule-call-param.param-value-decimal)
                     v-value = TRUE
                  .
               end.
               OTHERWISE DO:
               end.
            end case.
         end.
         if v-type
         then do:
            if v-value
            then do:
               run input-discont ( INPUt-OUTPUT p-cd-mode
                                 , INPUt-output p-cd-submode
                                 , output p-message
                                 , output p-ok
                                 ) .
            end.
            else do:
               case v-disc-type:
                  WHEN '10':U
                  then do:
                     assign
                        p-message = "Абсолютная скидка на итог чека"
                        p-ok      = TRUE
                     .
                  end.
                  WHEN '1':U
                  then do:
                     assign
                        p-message = "Процентная скидка на итог чека"
                        p-ok      = TRUE
                     .
                  end.
                  OTHERWISE DO:
                     assign
                        p-message = substitute("Неизвестный тип скидки - &1",v-disc-type)
                     .
                  end.
               end case.
            end.
         end.
         else do:
            assign
               p-message = "Укажите тип скидки на итог чека"
            .
            return.
         end.
      end.
end.
end procedure.
procedure upd-line :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
define buffer buf_tt-line     for tt-line .
define buffer buf_tt-head-check     for tt-head-check .
define variable v-b-code          as integer no-undo .
define variable v-gds-code        as integer no-undo .
define variable v-chk-name        as character no-undo .
define variable v-second-name     as character no-undo .
define variable v-src-sum         as decimal no-undo .
define variable v-src-sum-netto   as decimal no-undo .
define variable v-next    as character    no-undo.
define variable v-qnty-old    as decimal      no-undo.
define variable v-src-discnt-local    as decimal      no-undo.
define variable v-src-discnt-local-rub    as decimal      no-undo.
define variable v-for-discnt-local-doc    as decimal no-undo .
define variable v-for-discnt-local-rubl   as decimal no-undo .
define variable v-for-discnt-local-r-b    as decimal no-undo .
do
on error undo, return error
:
   if v-curr-num-0 <> 0
   AND (p-cd-mode = "1"
   OR   p-cd-mode = "2")
   then do:
      find buf_tt-head-check.
      find first buf_tt-line
         where buf_tt-line.num  = v-curr-num-0
           and buf_tt-line.type = v-curr-type-0
         no-lock
         .
define variable vss-include-info213 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  0
    , input  buf_tt-head-check.doc-code
    , input  v-src
    , input  TODAY
    , input  16
    , input  TIME
    , input  'U':U
    , input  buf_tt-line.line-code
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            if error-status:error
            then do:
               message
                  "Z"  16
                  skip error-status:get-message(1)
                  skip return-value
               view-as alert-box information.
            end.
      assign
         v-src-qnty = DECIMAL( v-src )
      no-error.
      if error-status:error
      then do:
         assign
            p-message = substitute( "Вы ввели не число: &1 Введите количество правильно.", v-src )
            p-ok = FALSE
         .
define variable vss-include-info214 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  0
    , input  buf_tt-head-check.doc-code
    , input  v-src
    , input  TODAY
    , input  18
    , input  TIME
    , input  'S':U
    , input  buf_tt-line.line-code
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            if error-status:error
            then do:
               message
                  "Z"  18
                  skip error-status:get-message(1)
                  skip return-value
               view-as alert-box information.
            end.
         return.
      end.
      if v-src-qnty <= 0
      then do:
         assign
            v-src-qnty = 0
            p-message = "Количество должно быть больше нуля."
            p-ok = FALSE
         .
         return.
      end.
      if p-cd-mode = "2"
      then do:
         define variable v-curr-qnty   as decimal      no-undo .
         define variable v-old-qnty    as decimal      no-undo .
         define variable v-found       as logical      no-undo .
         run accum-chk-gds ( input  buf_tt-line.src
                           , output v-found
                           , output v-old-qnty
                           ) .
         run accum-curr-chk-gds  ( input  buf_tt-line.src
                                 , output v-curr-qnty
                                 ) .
         if ( ( v-curr-qnty + v-src-qnty - buf_tt-line.qnty) > v-old-qnty )
         AND v-found
         then do:
            assign
               p-message = substitute( "По данному чеку продажи можно вернуть только &1 товара с кодом &2"
                                    , v-old-qnty
                                    , buf_tt-line.src
                                    )
               p-ok = FALSE
            .
            return.
         end.
      end.
      assign
         v-qnty-old = buf_tt-line.qnty
      .
      if p-cd-mode = "2"
      then do:
         assign
            v-src-qnty = - ABS( v-src-qnty )
         no-error.
      end.
      else do:
         assign
            v-src-qnty = ABS( v-src-qnty )
         no-error.
      end.
      case buf_tt-line.type:
         WHEN 0 then do:
            if buf_tt-line.printed = TRUE
            then do:
               assign
                  p-message   = "Отправленную на ФР строку изменять нельзя."
                  p-ok        = FALSE
               .
               return.
            end.
            assign
               v-pump            = 0
               v-nozzle-code     = 0
               v-pl-code         = 0
               v-pass-gds        = 0
               v-fbr-depart      = 0
               v-src-price       = if p-cd-submode = "7"
                                   AND not v-recalc
                                   then v-src-price
                                   else buf_tt-line.price-rub
               v-write-off-code  = 0
               v-src             = buf_tt-line.src
            .
define variable vss-include-info215 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_gds-line in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  v-curr-num-0
  ,input  'ИЗМЕНЕНИЕ':U
  ,input  0
  ,input  v-src
  ,input-output  v-src-qnty
  ,input  v-pump
  ,input  v-nozzle-code
  ,input  v-pl-code
  ,input  v-pass-gds
  ,input  v-write-off-code
  ,input  v-fbr-depart
  ,output p-ok
  ,output v-next
  ,output v-b-code
  ,output v-gds-code
  ,output v-chk-name
  ,output v-second-name
  ,input-output v-src-price
  ,output v-src-price-rub
  ,output v-src-discnt
  ,output v-src-discnt-rub
  ,output v-src-sum
  ,output v-src-sum-rub
  ,output v-src-sum-netto
  ,output v-src-sum-netto-rub
  ,output v-unit-base
  ) no-error .
            if error-status:error
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
                  v-src-qnty = 0
               .
define variable vss-include-info216 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  0
    , input  buf_tt-head-check.doc-code
    , input  v-src-qnty
    , input  TODAY
    , input  18
    , input  TIME
    , input  'S':U
    , input  buf_tt-line.line-code
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
               if error-status:error
               then do:
                  message
                     "Z"  18
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.
               return.
            end.
            assign
               v-disp-msg-1 = buf_tt-line.line-name
               v-disp-msg-2 = substitute  ( "&1 x &2 &3"
                                          , if p-cd-mode = "2" then - v-src-qnty else v-src-qnty
                                          , v-src-price
                                          , v-cd-base-name
                                          )
               buf_tt-line.qnty           = ABSOLUTE(v-src-qnty)                              buf_tt-line.qnty-str         = STRING(ABSOLUTE(v-src-qnty), "->>,>>>,>>9.999":U)                              buf_tt-line.price            = ABS(v-src-price)                              buf_tt-line.price-rub        = ABS(v-src-price-rub)                              buf_tt-line.price-STR        = STRING(ABSOLUTE(v-src-price-rub), "->>,>>>,>>9.99":U)                             buf_tt-line.summ-netto       = ABSOLUTE(v-src-sum-netto)                                                      buf_tt-line.summ-netto-rub   = ABSOLUTE(v-src-sum-netto-rub)                                                      buf_tt-line.summ-brutto      = ABSOLUTE(v-src-sum)                                                             buf_tt-line.summ-brutto-rub  = ABSOLUTE(v-src-sum-rub)                                                             buf_tt-line.unit-base        = v-unit-base                             buf_tt-line.summ-discont     = ABSOLUTE(v-src-discnt)                             buf_tt-line.summ-discont-rub = ABSOLUTE(v-src-discnt-rub)
            .
            if not v-emul-mode
            then do:
define variable vss-include-info217 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#disp-lib ) <> TRUE then do:       run gbl/disp-lib.p persistent no-error.       if error-status :error or valid-handle( g#disp-lib ) <> TRUE then do:         message "Error starting disp-lib.p" skip( 0 )           g#disp-lib                        skip( 0 )           g#disp-lib    :type               skip( 0 )           g#disp-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run disp-str in g#disp-lib
    ( INPUT  v-disp-msg-1
    , INPUT  v-disp-msg-2
    , output p-message
    , output p-ok
    )  .
end.
            end.
define variable vss-include-info218 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  0
    , input  buf_tt-head-check.doc-code
    , input  v-src-qnty
    , input  TODAY
    , input  17
    , input  TIME
    , input  'S':U
    , input  buf_tt-line.line-code
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  v-src-sum-netto
    , input  v-cntxt-userid
    ) no-error .
end.
            if error-status:error
            then do:
               message
                  "Z"  17
                  skip error-status:get-message(1)
                  skip return-value
               view-as alert-box information.
            end.
            define variable v-num-str    as integer      no-undo.
            define variable v-gds-yes    as integer      no-undo.
            define variable v-pay-yes    as integer      no-undo.
            define variable v-msg    as character    no-undo.
            define variable v-num-local   as integer      no-undo.
            define variable v-type-local  as integer      no-undo.
            if  INDEX(v-next, "=") > 0
            AND not v-recalc
            then do:
               assign
                  v-msg     = p-message
                  v-recalc  = TRUE
                  v-next    = TRIM(v-next, "recalc=")
                  v-num-str = INTEGER(ENTRY(1, v-next, ","))
                  v-gds-yes = INTEGER(ENTRY(2, v-next, ","))
                  v-pay-yes = INTEGER(ENTRY(3, v-next, ","))
                  v-num-local  = v-curr-num-0
                  v-type-local = v-curr-type-0
               .
               run recalc-lines in this-procedure
                              ( input v-num-str
                              , input v-gds-yes
                              , input v-pay-yes
                              , input-output p-cd-mode
                              , INPUt-output p-cd-submode
                              , output p-message
                              , output p-ok
                              ) .
               assign
                  v-recalc  = FALSE
                  p-message    = v-msg
                  v-curr-num-0     = v-num-local
                  v-curr-type-0    = v-type-local
               .
            end.
            assign
               v-src            = ""
               v-src-qnty       = 0.0
               v-src-price      = 0.0
               v-src-price-rub  = 0.0
            .
            assign
            p-message  = substitute  ( "&1 &2x&3"                                      , substring(buf_tt-line.line-name + fill(' ':U,38),                                                1, 38 - 1 - length(trim(string(buf_tt-line.qnty,"->>>,>>>,>>9.<<<")) + 'X' + trim(string(buf_tt-line.price,"->>>,>>>,>>9.99")))  )                                    , trim(string(buf_tt-line.qnty,"->>>,>>>,>>9.<<<"))                                    , trim(string(buf_tt-line.price,"->>>,>>>,>>9.99"))           )
            v-src-price = if v-recalc then ? else v-src-price
            .
         end.
         WHEN 1 then do:
            if v-recalc
            then do:
               define buffer buf_cash-pay    for ub.cash-pay .
               define variable v-mode as character no-undo .
               define variable v-pass-pay as integer no-undo .
               define variable v-pay-card as character no-undo .
               define variable v-tot-sum as decimal no-undo .
               define variable v-tot-rubl as decimal no-undo .
               define variable v-tot-base as decimal no-undo .
               define variable v-par-code as integer  no-undo .
               define variable v-get-qnty-method as character no-undo .
               define variable v-2-cdpay-code as integer no-undo .
               define variable v-2-curr-code as integer no-undo .
               define variable v-2-tot-base as decimal no-undo .
               define variable v-2-tot-rubl as decimal no-undo .
               define variable v-2-frpay-code as integer no-undo .
               assign
                  v-mode      = 'ИЗМЕНЕНИЕ':U
                  v-pass-pay  = 0
                  v-pay-card  = ""
                  v-tot-sum   = 0
                  v-tot-rubl  = 0
                  v-tot-base  = 0
                  v-pay-type  = buf_tt-line.line-code
                  v-tot-sum   = if ((p-cd-mode = "2") OR (buf_tt-head-check.chk-type = INTEGER('2':U))) then - DECIMAL(buf_tt-line.qnty) else DECIMAL(buf_tt-line.qnty)
                  v-tot-rubl  = if ((p-cd-mode = "2") OR (buf_tt-head-check.chk-type = INTEGER('2':U))) then - DECIMAL(buf_tt-line.summ-netto-rub) else DECIMAL(buf_tt-line.summ-netto-rub)
                  v-tot-base  = if ((p-cd-mode = "2") OR (buf_tt-head-check.chk-type = INTEGER('2':U))) then - DECIMAL(buf_tt-line.summ-netto) else DECIMAL(buf_tt-line.summ-netto)
               .
               assign
                  v-disp-msg-1 = buf_tt-line.line-name
                  v-disp-msg-2 = substitute  ( "&1 &2"
                                             , if (p-cd-mode = "2") then - buf_tt-line.summ-netto else buf_tt-line.summ-netto
                                             , v-cd-base-name
                                             )
               .
               find first buf_cash-pay
                  where buf_cash-pay.cdpay-code = buf_tt-line.line-code
                     AND buf_cash-pay.curr-code  = buf_tt-line.curr-code
                  NO-LOCK
                  no-error
                  .
               if buf_cash-pay.atr16
               then do:
                  message
                     "Нельзя корректировать строку оплаты банковской картой."
                     skip
                  view-as alert-box error.
               end.
               else do:
                  if p-cd-mode = "8" then do:
define variable vss-include-info219 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_inst-line in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  buf_tt-line.num
  ,input  v-mode
  ,input-output  buf_tt-line.line-code
  ,input-output  v-curr-base-code
  ,input  v-par-code
  ,input  v-src-qnty
  ,output v-frpay-code
  ,input  v-pass-pay
  ,input  v-pay-card
  ,input-output  v-tot-sum
  ,input-output  v-tot-rubl
  ,input-output  v-tot-base
  ,output v-get-qnty-method
  ,output p-ok
  ) no-error .
                     if error-status:error
                     then do:
                        assign
                           p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                           p-ok = FALSE
                        .
                        return.
                     end.
                  end.
                  else do:
define variable vss-include-info220 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_pay-line in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  buf_tt-line.num
  ,input  v-mode
  ,input-output  buf_tt-line.line-code
  ,input-output  buf_tt-line.curr-code
  ,input  v-par-code
  ,input  v-src-qnty
  ,output v-frpay-code
  ,input  v-pass-pay
  ,input  buf_tt-line.pay-card
  ,input-output  v-tot-sum
  ,input-output  v-tot-rubl
  ,input-output  v-tot-base
  ,output v-get-qnty-method
  ,output v-2-cdpay-code
  ,output v-2-curr-code
  ,output v-2-frpay-code
  ,output v-2-tot-sum
  ,output v-2-tot-rubl
  ,output v-2-tot-base
  ,output v-src-discnt-local
  ,output v-src-discnt-local-rub
  ,output v-for-discnt-local-doc
  ,output v-for-discnt-local-rubl
  ,output v-for-discnt-local-r-b
  ,output p-ok
  ) no-error .
                     if error-status:error
                     then do:
                        assign
                           p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                           p-ok = FALSE
                        .
                        return.
                     end.
                  end.
                  assign
                     buf_tt-line.summ-netto-rub    = ABSOLUTE(v-tot-rubl)
                     buf_tt-line.summ-netto        = ABSOLUTE(v-tot-base)
                     buf_tt-line.summ-discont      = v-src-discnt-local
                     buf_tt-line.summ-discont-rub  = v-src-discnt-local-rub
                     buf_tt-line.summ-brutto  = (if p-cd-mode <> "8"
                                                then v-for-discnt-local-rubl
                                                else buf_tt-line.summ-brutto)
                     p-message                = substitute  ( "&1 &2"
                                                            , buf_tt-line.line-name
                                                            , if p-cd-mode = "2" then - v-src-qnty else v-src-qnty
                                                            )
                     v-src        = ""
                     v-src-qnty   = 0.0
                     v-src-price  = 0.0
                     v-src-price-rub  = 0.0
                  .
               end.
               RELEASE buf_cash-pay.
            end.
            else do:
               assign
                  p-message = "Запрещена коррекция строк оплаты. Используйте удаление."
               .
            end.
         end.
         OTHERWISE DO:
         end.
      end case.
   end.
   assign
      v-src            = ""
      v-src-qnty       = 0.0
      v-src-price      = 0.0
      v-src-price-rub  = 0.0
      v-num            = 0
      p-cd-submode     = "0"
      p-ok             = TRUE
   .
end.
end procedure.
procedure 2010 :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define buffer buf_tt-line     for tt-line .
do
on error undo, return error
:
   if not v-qnty-change
   then do:
      assign
         p-message   = "Коррекция количества запрещена"
         p-ok        = FALSE
      .
      return.
   end.
   if v-curr-num-0 <> 0
   then do:
      find first buf_tt-line
         where buf_tt-line.num  = v-curr-num-0
           and buf_tt-line.type = v-curr-type-0
         no-lock
         .
      if not available buf_tt-line
      then do:
         assign
            p-message   = "Нет строки чека для коррекции"
            p-ok        = FALSE
         .
         return.
      end.
   end.
   else do:
      assign
         p-message   = "Нет строки чека для коррекции"
         p-ok        = FALSE
      .
      return.
   end.
   if buf_tt-line.type = 1
   then do:
      assign
         p-message   = "Cтроку оплаты корректировать нельзя."
         p-ok        = FALSE
      .
      return.
   end.
   define buffer buf_rule-call-param   for ub.rule-call-param .
   define variable v-qnty    as logical      no-undo.
   for each  buf_rule-call-param
         where buf_rule-call-param.call_id = buf_temp-layout-elem-rule.uniq-key-rec
         no-lock
      :
      case buf_rule-call-param.param-name:
         WHEN "p-gds-qnty"
         then do:
            if  buf_rule-call-param.param-value-decimal <> 0
            AND buf_rule-call-param.param-value-decimal <> ?
            then
            assign
               v-src = STRING(buf_rule-call-param.param-value-decimal)
               v-qnty = if (buf_rule-call-param.param-value-decimal <> 0) then TRUE else FALSE
            .
         end.
         OTHERWISE DO:
         end.
      end case.
   end.
   if v-qnty
   then do:
      run upd-line  ( INPUt-OUTPUT p-cd-mode
                        , INPUt-output p-cd-submode
                        , output p-message
                        , output p-ok
                        ) .
   end.
   else do:
      if p-cd-mode = "1"
      OR p-cd-mode = "2"
      then do:
         assign
            p-cd-submode = "1"
            p-ok         = TRUE
         .
      end.
   end.
end.
end procedure.
procedure 1984 :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define buffer buf_tt-line     for tt-line .
define buffer buf_tt-head-check     for tt-head-check .
do
on error undo, return error
:
   find first buf_tt-head-check NO-LOCK no-error.
   if not available buf_tt-head-check
   then do:
      return.
   end.
define variable vss-include-info221 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  57
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
   run adm/chk-pass.w   ( input parparentproc
                        , input v-cntxt-userid
                        , input v-cntxt-db-num
                        , input "actn_ibsthpos-ord-chk"
                        , input FALSE
                        , output p-message
                        , output p-ok
                        ) .
   if not p-ok
   then do:
define variable vss-include-info222 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  1
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  59
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
      return.
   end.
   if CAN-find (first buf_tt-line       where buf_tt-line.hand-discounted       <> "":U )
   OR CAN-find (first buf_tt-head-check where buf_tt-head-check.hand-discounted <> "":U )
   then do:
       message
              "В отложенном чеке не будут сохранены ручные скидки."
         skip "Отложить чек?"
       view-as alert-box warning
       buttons yes-no
       update p-ok
       .
       if not p-ok
       then do:
         return.
       end.
       for each buf_tt-line
           where buf_tt-line.hand-discounted       <> "":U
           no-lock
           :
            assign
               v-disc-type = buf_tt-line.hand-discounted
               v-src       = STRING(0.0)
               p-cd-submode = "4"
            .
               run input-discont ( INPUt-OUTPUT p-cd-mode
                                 , INPUt-output p-cd-submode
                                 , output p-message
                                 , output p-ok
                                 ) .
       end.
       for each buf_tt-head-check
           where buf_tt-head-check.hand-discounted <> "":U
           no-lock
           :
            assign
               v-disc-type = buf_tt-head-check.hand-discounted
               v-src       = STRING(0.0)
               p-cd-submode = "5"
            .
               run input-discont ( INPUt-OUTPUT p-cd-mode
                                 , INPUt-output p-cd-submode
                                 , output p-message
                                 , output p-ok
                                 ) .
       end.
   end.
   find first buf_tt-head-check NO-LOCK no-error.
   if CAN-find (first buf_tt-line where buf_tt-line.type = 1 )
   then do:
      assign
         p-message = "Оплаченный чек отложить нельзя."
         p-ok = FALSE
      .
define variable vss-include-info223 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  1
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  59
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
      return.
   end.
define variable vss-include-info224 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_postpone in g#libthpos
  (input  buf_tt-head-check.doc-code
  ) no-error .
   if error-status:error
   then do:
      assign
         p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
define variable vss-include-info225 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  1
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  59
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
      return.
   end.
define variable vss-include-info226 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  1
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  58
    , input  TIME
    , input  'S':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
   run clear-tt-chk in this-procedure.
   run reset-summ-for-pay in this-procedure.
   run set-all-summ  ( output p-message
                     , output p-ok
                     ) .
   assign
      p-cd-mode    = "0"
      p-cd-submode = "0"
      p-ok         = TRUE
      p-message    = "Чек отложен"
   .
   if not v-emul-mode
   then do:
define variable vss-include-info227 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#disp-lib ) <> TRUE then do:       run gbl/disp-lib.p persistent no-error.       if error-status :error or valid-handle( g#disp-lib ) <> TRUE then do:         message "Error starting disp-lib.p" skip( 0 )           g#disp-lib                        skip( 0 )           g#disp-lib    :type               skip( 0 )           g#disp-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run disp-str in g#disp-lib
    ( INPUT  p-message
    , INPUT  '':U
    , output p-message
    , output p-ok
    )  .
end.
   end.
end.
end procedure.
procedure add-sale :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define variable v-local-src    as character    no-undo.
do
on error undo, return error
:
   assign
      v-local-src = v-src
   .
   run clear-tt-chk in this-procedure.
   run chk-open   ( input integer('1':U)
                  , INPUt-OUTPUT p-cd-mode
                  , INPUt-output p-cd-submode
                  , output p-message
                  , output p-ok
                  ) .
   if not p-ok
   then do:
      return.
   end.
   assign
      p-cd-mode    = "1"
      p-cd-submode = "0"
   .
   assign
      v-src = v-local-src
   .
   run add-gds-line  ( INPUt-OUTPUT p-cd-mode
                     , INPUt-output p-cd-submode
                     , output p-message
                     , output p-ok
                     ) .
end.
end procedure.
procedure del-gds-line :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define buffer buf_tt-line     for tt-line .
define buffer buf_tt-head-check     for tt-head-check .
define buffer buf_cash-pay    for ub.cash-pay .
define variable v-b-code          as integer no-undo .
define variable v-gds-code        as integer no-undo .
define variable v-chk-name        as character no-undo .
define variable v-second-name     as character no-undo .
define variable v-src-sum         as decimal no-undo .
define variable v-src-sum-netto   as decimal no-undo .
define variable v-pline-num as integer no-undo .
define variable v-mode as character no-undo .
define variable v-pass-pay as integer no-undo .
define variable v-pay-card as character no-undo .
define variable v-tot-sum as decimal no-undo .
define variable v-tot-rubl as decimal no-undo .
define variable v-tot-base as decimal no-undo .
define variable v-par-code as integer  no-undo .
define variable v-src-qnty as decimal no-undo .
define variable v-get-qnty-method as character no-undo .
define variable v-2-cdpay-code as integer no-undo .
define variable v-2-curr-code as integer no-undo .
define variable v-2-tot-base as decimal no-undo .
define variable v-2-tot-rubl as decimal no-undo .
define variable v-next    as character    no-undo.
define variable v-frpay-code as integer no-undo .
define variable v-2-frpay-code as integer no-undo .
define variable v-src-discnt-local    as decimal      no-undo.
define variable v-src-discnt-local-rub    as decimal      no-undo.
define variable v-for-discnt-local-doc    as decimal no-undo .
define variable v-for-discnt-local-rubl   as decimal no-undo .
define variable v-for-discnt-local-r-b    as decimal no-undo .
do
on error undo, return error
:
  if v-curr-num-0 <> 0
  then do:
    find buf_tt-head-check.
    find first buf_tt-line
        where buf_tt-line.num  = v-curr-num-0
          AND buf_tt-line.type = v-curr-type-0
        no-lock
        .
    if not available buf_tt-line
    then do:
      assign
      v-src                    = ""
      v-src-qnty               = 0.0
      v-src-price              = 0.0
      v-src-price-rub          = 0.0
      v-num                    = 0
      p-ok                     = TRUE
      .
      return.
    end.
    if buf_tt-line.printed = TRUE
    then do:
      assign
      p-message   = "Отправленную на ФР строку удалять нельзя."
      p-ok        = FALSE
      .
      return.
    end.
    case buf_tt-line.type:
      WHEN 0 then do:
define variable vss-include-info228 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  0
    , input  buf_tt-head-check.doc-code
    , input  buf_tt-line.qnty
    , input  TODAY
    , input  27
    , input  TIME
    , input  'U':U
    , input  buf_tt-line.line-code
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  buf_tt-line.summ-netto
    , input  v-cntxt-userid
    ) no-error .
end.
        if error-status:error
        then do:
          message
          "Z"  27
          skip error-status:get-message(1)
          skip return-value
          view-as alert-box information.
        end.
        if p-cd-mode <> "8" then do:
          run adm/chk-pass.w   ( input parparentproc
                                , input v-cntxt-userid
                                , input v-cntxt-db-num
                                , input (if p-cd-mode = "2"
                                        then "actn_ibsthpos-annul-return"
                                        else "actn_ibsthpos-annul-sale"
                                        )
                                , input FALSE
                                , output p-message
                                , output p-ok
                                ) .
          if not p-ok
          then do:
define variable vss-include-info229 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  buf_tt-line.qnty
    , input  TODAY
    , input  29
    , input  TIME
    , input  'E':U
    , input  v-gds-code
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  buf_tt-line.summ-netto
    , input  v-cntxt-userid
    ) no-error .
end.
              return.
            end.
          end.
          assign
          v-pump            = 0
          v-nozzle-code     = 0
          v-pl-code         = 0
          v-pass-gds        = 0
          v-fbr-depart      = 0
          v-src-price       = ?
          v-src-price-rub   = ?
          v-write-off-code  = 0
          .
          assign
          v-src-qnty = 0
          v-src      = buf_tt-line.src
          .
          assign
          v-disp-msg-1 = buf_tt-line.line-name
          v-disp-msg-2 = substitute  ( "-&1 x &2 &3"
                                    , if p-cd-mode = "2" then - buf_tt-line.qnty else buf_tt-line.qnty
                                    , buf_tt-line.price
                                    , v-cd-base-name
                                    )
          .
define variable vss-include-info230 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_gds-line in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  v-curr-num-0
  ,input  'удаление':U
  ,input  0
  ,input  v-src
  ,input-output  v-src-qnty
  ,input  v-pump
  ,input  v-nozzle-code
  ,input  v-pl-code
  ,input  v-pass-gds
  ,input  v-write-off-code
  ,input  v-fbr-depart
  ,output p-ok
  ,output v-next
  ,output v-b-code
  ,output v-gds-code
  ,output v-chk-name
  ,output v-second-name
  ,input-output v-src-price
  ,output v-src-price-rub
  ,output v-src-discnt
  ,output v-src-discnt-rub
  ,output v-src-sum
  ,output v-src-sum-rub
  ,output v-src-sum-netto
  ,output v-src-sum-netto-rub
  ,output v-unit-base
  ) no-error .
          if error-status:error
          then do:
            assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
            .
define variable vss-include-info231 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  buf_tt-line.qnty
    , input  TODAY
    , input  29
    , input  TIME
    , input  'E':U
    , input  v-gds-code
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  buf_tt-line.summ-netto
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
          end.
          DELETE buf_tt-line.
define variable vss-include-info232 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  0
    , input  buf_tt-head-check.doc-code
    , input  0
    , input  TODAY
    , input  28
    , input  TIME
    , input  'S':U
    , input  v-gds-code
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
          if error-status:error
          then do:
            message
            "Z"  28
            skip error-status:get-message(1)
            skip return-value
            view-as alert-box information.
          end.
        end.
        WHEN 1 then do:
          assign
          v-mode  = 'удаление':U
          v-pass-pay  = 0
          v-pay-card  = ""
          v-tot-sum   = 0
          v-tot-rubl  = 0
          v-tot-base  = 0
          v-pay-type  = buf_tt-line.line-code
          .
          assign
          v-disp-msg-1 = buf_tt-line.line-name
          v-disp-msg-2 = substitute  ( "&1 &2"
                                    , if (p-cd-mode = "2") then - buf_tt-line.summ-netto else buf_tt-line.summ-netto
                                    , v-cd-base-name
                                    )
          .
define variable vss-include-info233 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  30
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  buf_tt-line.summ-netto
    , input  v-cntxt-userid
    ) no-error .
end.
          find first buf_cash-pay
                where buf_cash-pay.cdpay-code = buf_tt-line.line-code
                  AND buf_cash-pay.curr-code  = buf_tt-line.curr-code
                NO-LOCK
                no-error
                .
          if buf_cash-pay.atr16
          AND not v-emul-mode
          then do:
define variable vss-include-info234 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  92
    , input  TIME
    , input  'S':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  v-pay-card
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  buf_tt-line.summ-netto
    , input  v-cntxt-userid
    ) no-error .
end.
            run adm/chk-pass.w   ( input parparentproc
                                , input v-cntxt-userid
                                , input v-cntxt-db-num
                                , input "actn_ibsthpos-annul-card-pay"
                                , input FALSE
                                , output p-message
                                , output p-ok
                                ) .
            if not p-ok
            then do:
define variable vss-include-info235 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  32
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  buf_tt-line.summ-netto
    , input  v-cntxt-userid
    ) no-error .
end.
define variable vss-include-info236 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  26
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  v-pay-card
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  buf_tt-line.summ-netto
    , input  v-cntxt-userid
    ) no-error .
end.
              return.
            end.
            define variable v-slip    as character    no-undo.
define variable vss-include-info237 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#sb-lib ) <> TRUE then do:       run gbl/sb-lib.p persistent no-error.       if error-status :error or valid-handle( g#sb-lib ) <> TRUE then do:         message "Error starting sb-lib.p" skip( 0 )           g#sb-lib                        skip( 0 )           g#sb-lib    :type               skip( 0 )           g#sb-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run sb-revert in g#sb-lib
    ( input  v-tot-rubl
    , output v-slip
    , output v-pay-card
    , output p-message
    , output p-ok
    )  .
end.
            if error-status:error
            OR not p-ok
            then do:
              assign
              p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
              p-ok = FALSE
              .
define variable vss-include-info238 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  26
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  v-pay-card
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  buf_tt-line.summ-netto
    , input  v-cntxt-userid
    ) no-error .
end.
            end.
            else do:
              run print-slip in this-procedure (input v-slip, output p-message, output p-ok) .
              run print-head-chk   ( output p-message
                                    , output p-ok
                                    ) .
define variable vss-include-info239 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_pay-line in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  buf_tt-line.num
  ,input  v-mode
  ,input-output  buf_tt-line.line-code
  ,input-output  v-curr-base-code
  ,input  v-par-code
  ,input  v-src-qnty
  ,output v-frpay-code
  ,input  v-pass-pay
  ,input  v-pay-card
  ,input-output  v-tot-sum
  ,input-output  v-tot-rubl
  ,input-output  v-tot-base
  ,output v-get-qnty-method
  ,output v-2-cdpay-code
  ,output v-2-curr-code
  ,output v-2-frpay-code
  ,output v-2-tot-sum
  ,output v-2-tot-rubl
  ,output v-2-tot-base
  ,output v-src-discnt-local
  ,output v-src-discnt-local-rub
  ,output v-for-discnt-local-doc
  ,output v-for-discnt-local-rubl
  ,output v-for-discnt-local-r-b
  ,output p-ok
  ) no-error .
              if error-status:error
              then do:
                assign
                p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                p-ok = FALSE
                .
                return.
              end.
              DELETE buf_tt-line.
define variable vss-include-info240 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  25
    , input  TIME
    , input  'S':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  v-pay-card
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-tot-rubl
    , input  v-cntxt-userid
    ) no-error .
end.
            end.
          end.
          else do:
            if p-cd-mode = "8"
            then do:
define variable vss-include-info241 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_inst-line in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  buf_tt-line.num
  ,input  v-mode
  ,input-output  buf_tt-line.line-code
  ,input-output  v-curr-base-code
  ,input  v-par-code
  ,input  v-src-qnty
  ,output v-frpay-code
  ,input  v-pass-pay
  ,input  v-pay-card
  ,input-output  v-tot-sum
  ,input-output  v-tot-rubl
  ,input-output  v-tot-base
  ,output v-get-qnty-method
  ,output p-ok
  ) no-error .
              if error-status:error
              then do:
                assign
                p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                p-ok = FALSE
                  .
                return.
              end.
            end.
            else do:
define variable vss-include-info242 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_pay-line in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  buf_tt-line.num
  ,input  v-mode
  ,input-output  buf_tt-line.line-code
  ,input-output  v-curr-base-code
  ,input  v-par-code
  ,input  v-src-qnty
  ,output v-frpay-code
  ,input  v-pass-pay
  ,input  v-pay-card
  ,input-output  v-tot-sum
  ,input-output  v-tot-rubl
  ,input-output  v-tot-base
  ,output v-get-qnty-method
  ,output v-2-cdpay-code
  ,output v-2-curr-code
  ,output v-2-frpay-code
  ,output v-2-tot-sum
  ,output v-2-tot-rubl
  ,output v-2-tot-base
  ,output v-src-discnt-local
  ,output v-src-discnt-local-rub
  ,output v-for-discnt-local-doc
  ,output v-for-discnt-local-rubl
  ,output v-for-discnt-local-r-b
  ,output p-ok
  ) no-error .
              if error-status:error
              then do:
                assign
                p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                p-ok = FALSE
                .
                return.
              end.
            end.
            DELETE buf_tt-line.
          end.
          RELEASE buf_cash-pay.
define variable vss-include-info243 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  31
    , input  TIME
    , input  'S':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-tot-rubl
    , input  v-cntxt-userid
    ) no-error .
end.
        end.
        OTHERWISE DO:
        end.
    end case.
    if CAN-find(buf_tt-line where buf_tt-line.num  = v-curr-num-0 + 1
                                AND buf_tt-line.type = v-curr-type-0 ) then do:
      assign
      v-curr-num-0             = v-curr-num-0 + 1
      .
    end.
    else do:
      find first buf_tt-line no-lock no-error.
      if available buf_tt-line
      then do:
        assign
        v-curr-num-0             = buf_tt-line.num
        v-curr-type-0            = buf_tt-line.type
        .
      end.
      else do:
        assign
        v-curr-num-0             = 0
        v-curr-type-0            = 0
        .
      end.
    end.
    define variable v-num-str     as integer      no-undo.
    define variable v-gds-yes     as integer      no-undo.
    define variable v-pay-yes     as integer      no-undo.
    define variable v-msg         as character    no-undo.
    define variable v-num-local   as integer      no-undo.
    define variable v-type-local  as integer      no-undo.
    if INDEX(v-next, "=") > 0
    AND not v-recalc
    then do:
      assign
      v-recalc  = TRUE
      v-msg     = p-message
      v-next    = TRIM(v-next, "recalc=")
      v-num-str = INTEGER(ENTRY(1, v-next, ","))
      v-gds-yes = INTEGER(ENTRY(2, v-next, ","))
      v-pay-yes = INTEGER(ENTRY(3, v-next, ","))
      v-num-local  = v-curr-num-0
      v-type-local = v-curr-type-0
      .
      run recalc-lines in this-procedure
                    ( input v-num-str
                    , input v-gds-yes
                    , input v-pay-yes
                    , input-output p-cd-mode
                    , INPUt-output p-cd-submode
                    , output p-message
                    , output p-ok
                    ) .
      assign
      v-src            = ""
      v-src-qnty       = 0.0
      v-src-price      = 0.0
      v-src-price-rub  = 0.0
      v-recalc  = FALSE
      p-message = v-msg
      v-curr-num-0     = v-num-local
      v-curr-type-0    = v-type-local
      .
    end.
    if not v-emul-mode
    then do:
define variable vss-include-info244 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#disp-lib ) <> TRUE then do:       run gbl/disp-lib.p persistent no-error.       if error-status :error or valid-handle( g#disp-lib ) <> TRUE then do:         message "Error starting disp-lib.p" skip( 0 )           g#disp-lib                        skip( 0 )           g#disp-lib    :type               skip( 0 )           g#disp-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run disp-str in g#disp-lib
    ( INPUT  v-disp-msg-1
    , INPUT  v-disp-msg-2
    , output p-message
    , output p-ok
    )  .
end.
    end.
    assign
    v-src                    = ""
    v-src-qnty               = 0.0
    v-src-price              = 0.0
    v-src-price-rub          = 0.0
    v-num                    = 0
    p-ok                     = TRUE
    .
  end.
end.
end procedure.
procedure set-curr-num :
define input parameter p-type       as integer        no-undo.
define input parameter p-num        as integer        no-undo.
define output parameter p-message   as character      no-undo .
define output parameter p-ok        as logical        no-undo.
do
on error undo, return error
:
   assign
      v-curr-num-0 = p-num
      v-curr-type-0 = p-type
      p-ok  = TRUE
   .
end.
end procedure.
procedure get-curr-num :
define output parameter p-type as integer          no-undo.
define output parameter p-num as integer          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   assign
      p-num  = v-curr-num-0
      p-type = v-curr-type-0
      p-ok   = TRUE
   .
end.
end procedure.
procedure rest-back :
define input-output  parameter p-rest-summ   as decimal          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define variable v-pline-num as integer no-undo .
define variable v-mode as character no-undo .
define variable v-pass-pay as integer no-undo .
define variable v-pay-card as character no-undo .
define variable v-tot-sum as decimal no-undo .
define variable v-tot-rubl as decimal no-undo .
define variable v-tot-base as decimal no-undo .
define variable v-par-code as integer no-undo .
define variable v-src-qnty as decimal no-undo .
define variable v-get-qnty-method as character no-undo .
define variable v-2-cdpay-code as integer no-undo .
define variable v-2-curr-code as integer no-undo .
define variable v-2-tot-base as decimal no-undo .
define variable v-2-tot-rubl as decimal no-undo .
define variable v-frpay-code as integer no-undo .
define variable v-2-frpay-code as integer no-undo .
define variable v-src-discnt-local    as decimal      no-undo.
define variable v-src-discnt-local-rub    as decimal      no-undo.
define variable v-for-discnt-local-doc    as decimal no-undo .
define variable v-for-discnt-local-rubl   as decimal no-undo .
define variable v-for-discnt-local-r-b    as decimal no-undo .
define buffer buf_tt-line     for tt-line .
define buffer buf_tt-head-check     for tt-head-check .
do
on error undo, return error
:
   if v-summ-netto-rub < v-summ-pay-rub
   then do:
      find buf_tt-head-check.
      find last buf_tt-line where buf_tt-line.type = 1 no-lock.
      if not available buf_tt-line
      then do:
         assign
            p-message = "В чеке нет оплат"
            p-ok      = FALSE
         .
         return.
      end.
      if p-rest-summ = ?
      then do:
         assign
            v-pline-num = buf_tt-line.num + 1
            v-mode      = 'ДОБАВЛЕНИЕ':U
            v-pass-pay  = 0
            v-pay-card  = ""
            v-tot-base  = ?
            v-tot-sum   = if (buf_tt-head-check.chk-type = integer('6':U)) then - (v-summ-netto-rub - v-summ-pay-rub) else v-summ-netto-rub - v-summ-pay-rub
            v-tot-rubl  = if (buf_tt-head-check.chk-type = integer('6':U)) then - (v-summ-netto-rub - v-summ-pay-rub) else v-summ-netto-rub - v-summ-pay-rub
            v-tot-base  = if (buf_tt-head-check.chk-type = integer('6':U)) then - (v-summ-netto - v-summ-pay) else v-summ-netto - v-summ-pay
            v-pay-type  = ?
         .
      end.
      else do:
         assign
            v-pline-num = buf_tt-line.num + 1
            v-mode      = 'ДОБАВЛЕНИЕ':U
            v-pass-pay  = 0
            v-pay-card  = ""
            v-tot-base  = ?
            v-tot-sum   = if (buf_tt-head-check.chk-type = integer('6':U)) then p-rest-summ else - p-rest-summ
            v-tot-rubl  = if (buf_tt-head-check.chk-type = integer('6':U)) then p-rest-summ else - p-rest-summ
            v-tot-base  = if (buf_tt-head-check.chk-type = integer('6':U)) then p-rest-summ else - p-rest-summ
            v-pay-type  = ?
         .
      end.
define variable vss-include-info245 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_pay-line in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  v-pline-num
  ,input  v-mode
  ,input-output  v-pay-type
  ,input-output  v-curr-base-code
  ,input  v-par-code
  ,input  v-src-qnty
  ,output v-frpay-code
  ,input  v-pass-pay
  ,input  v-pay-card
  ,input-output  v-tot-sum
  ,input-output  v-tot-rubl
  ,input-output  v-tot-base
  ,output v-get-qnty-method
  ,output v-2-cdpay-code
  ,output v-2-curr-code
  ,output v-2-frpay-code
  ,output v-2-tot-sum
  ,output v-2-tot-rubl
  ,output v-2-tot-base
  ,output v-src-discnt-local
  ,output v-src-discnt-local-rub
  ,output v-for-discnt-local-doc
  ,output v-for-discnt-local-rubl
  ,output v-for-discnt-local-r-b
  ,output p-ok
  ) no-error .
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         return.
      end.
      assign
         p-rest-summ = ABS(v-tot-rubl)
      .
define variable vss-include-info246 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  0
    , input  '':U
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  68
    , input  TIME
    , input  'S':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-tot-rubl
    , input  v-cntxt-userid
    ) no-error .
end.
   end.
   else do:
      if TRUNCATE(v-summ-netto-rub, 2) > TRUNCATE(v-summ-pay-rub, 2)
      then do:
         assign
            p-message = "Чек оплачен не полностью"
            p-ok      = FALSE
         .
         return.
      end.
      else do:
         assign
            p-ok = TRUE
         .
      end.
   end.
end.
end procedure.
procedure del-rest:
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define variable v-pline-num as integer no-undo .
define variable v-mode as character no-undo .
define variable v-pass-pay as integer no-undo .
define variable v-pay-card as character no-undo .
define variable v-tot-sum as decimal no-undo .
define variable v-tot-rubl as decimal no-undo .
define variable v-tot-base as decimal no-undo .
define variable v-par-code as integer no-undo .
define variable v-src-qnty as decimal no-undo .
define variable v-get-qnty-method as character no-undo .
define variable v-2-cdpay-code as integer no-undo .
define variable v-2-curr-code as integer no-undo .
define variable v-2-tot-base as decimal no-undo .
define variable v-2-tot-rubl as decimal no-undo .
define variable v-frpay-code as integer no-undo .
define variable v-2-frpay-code as integer no-undo .
define variable v-src-discnt-local    as decimal      no-undo.
define variable v-src-discnt-local-rub    as decimal      no-undo.
define variable v-for-discnt-local-doc    as decimal no-undo .
define variable v-for-discnt-local-rubl   as decimal no-undo .
define variable v-for-discnt-local-r-b    as decimal no-undo .
define buffer buf_tt-line     for tt-line .
define buffer buf_tt-head-check     for tt-head-check .
do
on error undo, return error
:
   find buf_tt-head-check.
   if (buf_tt-head-check.chk-type = integer('6':U))
   then do:
      assign
         p-message = "В возврате запрещена сдача"
         p-ok      = FALSE
      .
      return.
   end.
   find last buf_tt-line where buf_tt-line.type = 1 no-lock.
   if not available buf_tt-line
   then do:
      assign
         p-message = "В чеке нет оплат"
         p-ok      = FALSE
      .
      return.
   end.
   assign
      v-pline-num = buf_tt-line.num + 1
      v-mode      = 'удаление':U
      v-pass-pay  = 0
      v-pay-card  = ""
      v-tot-base  = 0
      v-tot-sum   = 0
      v-tot-rubl  = 0
      v-tot-base  = 0
      v-pay-type  = 1
   .
define variable vss-include-info247 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_pay-line in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  v-pline-num
  ,input  v-mode
  ,input-output  v-pay-type
  ,input-output  v-curr-base-code
  ,input  v-par-code
  ,input  v-src-qnty
  ,output v-frpay-code
  ,input  v-pass-pay
  ,input  v-pay-card
  ,input-output  v-tot-sum
  ,input-output  v-tot-rubl
  ,input-output  v-tot-base
  ,output v-get-qnty-method
  ,output v-2-cdpay-code
  ,output v-2-curr-code
  ,output v-2-frpay-code
  ,output v-2-tot-sum
  ,output v-2-tot-rubl
  ,output v-2-tot-base
  ,output v-src-discnt-local
  ,output v-src-discnt-local-rub
  ,output v-for-discnt-local-doc
  ,output v-for-discnt-local-rubl
  ,output v-for-discnt-local-r-b
  ,output p-ok
  ) no-error .
   if error-status:error
   then do:
      assign
         p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
      return.
   end.
end.
end procedure.
procedure 1979 :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define buffer buf_tt-head-check     for tt-head-check .
define buffer buf_tt-line           for tt-line .
define variable v-chk-fr-num    as character    no-undo.
do
on error undo, return error
:
  define variable v-fr-mode            as integer      no-undo.
  define variable v-fr-time            as integer      no-undo.
  define variable v-fr-date            as date         no-undo.
  define variable v-fr-last-shift-date as date         no-undo.
  define variable v-fr-lic             as character    no-undo.
  define variable v-fr-serial          as char    no-undo.
  define variable loc-log              as logical no-undo .
define variable v-price-rub      as decimal      no-undo .
define variable v-disc-rub       as decimal      no-undo .
define variable v-disc-rub-total as decimal      no-undo .
define variable v-print-line     as character    no-undo .
define variable v-rest-summ      as decimal      no-undo .
define variable vss-include-info248 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-ctrl in g#fr-lib
    ( input        v-cash-drawer-open
    , output       p-message
    , output       p-ok
    , output       v-fr-mode
    , output       v-fr-time
    , output       v-fr-date
    , output       v-fr-last-shift-date
    , output       v-fr-last-shift-num
    , output       v-fr-lic
    , output       v-fr-shift-open
    , output       v-fr-serial
    ) no-error .
end.
  if  not p-ok
  AND v-fr-shift-open = 24
  then do:
    assign
    p-message = "Истекли 24 часа открытой смены. Чек можно только отложить."
    p-ok = FALSE
    .
    return.
  end.
  find first buf_tt-head-check no-error.
  if not available buf_tt-head-check
  then return.
  message
  "Вы действительно хотите аннулировать чек?"
  view-as alert-box question buttons yes-no update loc-log.
  if not loc-log then do:
    assign
    p-ok = FALSE
    .
    return.
  end.
define variable vss-include-info249 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  54
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
  if p-cd-mode <> "8"  then do:
    run adm/chk-pass.w   ( input parparentproc
                        , input v-cntxt-userid
                        , input v-cntxt-db-num
                        , input (if p-cd-mode = "2"
                                then "actn_ibsthpos-annul-return"
                                else "actn_ibsthpos-annul-sale"
                                )
                        , input FALSE
                        , output p-message
                        , output p-ok
                        ) .
    if not p-ok then do:
define variable vss-include-info250 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  56
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
      return.
    end.
  end.
  if p-cd-mode = "1"
  OR p-cd-mode = "2"
  OR p-cd-mode = "8"
  then do:
    if not v-emul-mode then do:
      if CAN-find ( first buf_tt-line
                    where buf_tt-line.type = 1
                        NO-LOCK )
      then do:
        assign
        p-message = "Чек нельзя аннулировать - в чеке есть линии оплаты."
        p-ok      = FALSE
        .
define variable vss-include-info251 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  56
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
        return.
      end.
      if p-cd-mode <> "8"
      then do:
define variable vss-include-info252 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-ctrl in g#fr-lib
    ( input        v-cash-drawer-open
    , output       p-message
    , output       p-ok
    , output       v-fr-mode
    , output       v-fr-time
    , output       v-fr-date
    , output       v-fr-last-shift-date
    , output       v-fr-last-shift-num
    , output       v-fr-lic
    , output       v-fr-shift-open
    , output       v-fr-serial
    ) no-error .
end.
        if v-fr-mode <> 8 then do:
          define variable v-num-ch    as integer      no-undo.
          case buf_tt-head-check.chk-type:
            WHEN integer('1':U) then do:
define variable vss-include-info253 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-open-chk in g#fr-lib
    ( input       0
    , output      v-num-ch
    , output      p-message
    , output      p-ok
    ) no-error .
end.
            end.
            WHEN integer('6':U) then do:
define variable vss-include-info254 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-open-chk in g#fr-lib
    ( input       2
    , output      v-num-ch
    , output      p-message
    , output      p-ok
    ) no-error .
end.
            end.
            OTHERWISE DO:
            end.
          end case.
          if error-status:error
          OR not p-ok
          then do:
            assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
            .
define variable vss-include-info255 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  56
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
            return .
          end.
         end.
  for each  buf_tt-line
      where buf_tt-line.type = 0
        AND buf_tt-line.printed = FALSE
      :
    case tt-head-check.chk-type:
      WHEN integer('1':U)
      then do:
        if not v-emul-mode
        then do:
          assign
          v-price-rub = buf_tt-line.price-rub
          v-disc-rub  = - buf_tt-line.summ-discont-rub
          v-disc-rub-total = v-disc-rub-total - v-disc-rub
          .
          run str-fix-width ( input (if v-print-good-code then STRING(buf_tt-line.src) + " " else "":U) + buf_tt-line.line-name
                            , input "":U
                            , input v-fr-width
                            , YES
                            , output v-print-line
                            , output p-message
                            , output p-ok
                            ) .
define variable vss-include-info256 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-add-sale in g#fr-lib
    ( input       '':U
    , input       v-print-line
    , input       v-price-rub
    , input       buf_tt-line.qnty
    , input       buf_tt-line.unit-base
    , input       v-d-card
    , input       v-disc-rub
    , output      p-message
    , output      p-ok
    ) no-error .
end.
          if error-status:error
          then do:
            if v-rest-summ > 0
            then do:
              run del-rest (output p-message, output p-ok) .
            end.
            assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
            .
define variable vss-include-info257 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  65
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
          end.
        end.
        else do:
          assign
          p-ok = TRUE
                .
        end.
      end.
      WHEN integer('6':U)
      then do:
        if not v-emul-mode
        then do:
          assign
          v-price-rub      =  buf_tt-line.price-rub
          v-disc-rub       = - buf_tt-line.summ-discont-rub
          v-disc-rub-total = v-disc-rub-total - v-disc-rub
          .
          run str-fix-width ( input (if v-print-good-code then STRING(buf_tt-line.src) + " " else "":U) + buf_tt-line.line-name
                            , input "":U
                            , input v-fr-width
                            , YES
                            , output v-print-line
                            , output p-message
                            , output p-ok
                            ) .
define variable vss-include-info258 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-add-ret in g#fr-lib
    ( input       '':U
    , input       v-print-line
    , input       v-price-rub
    , input       buf_tt-line.qnty
    , input       buf_tt-line.unit-base
    , input       v-d-card
    , input       v-disc-rub
    , output      p-message
    , output      p-ok
    ) no-error .
end.
          if error-status:error
          then do:
            if v-rest-summ > 0
            then do:
              run del-rest (output p-message, output p-ok) .
            end.
            assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
            .
define variable vss-include-info259 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  65
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
            return .
          end.
        end.
        else do:
          assign
          p-ok = TRUE
          .
        end.
      end.
      OTHERWISE DO:
      end.
    end case.
    assign
    buf_tt-line.printed = TRUE
    .
  end.
define variable vss-include-info260 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-chk-annul in g#fr-lib
    ( output       v-chk-fr-num
    , output       p-message
    , output       p-ok
    ) no-error .
end.
          if error-status:error
          OR not p-ok
          then do:
            assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
            .
define variable vss-include-info261 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  56
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
            return .
          end.
       end.
    end.
    else do:
      assign
      p-ok = TRUE
      .
    end.
define variable vss-include-info262 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_annulate in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  0
  ) no-error .
    if error-status:error
    then do:
      assign
      p-message = substitute("libthpos_annulate &1 &2 &3", error-status:get-message(1), return-value, p-message)
      p-ok = FALSE
      .
define variable vss-include-info263 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  56
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
      return.
    end.
define variable vss-include-info264 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  55
    , input  TIME
    , input  'S':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-summ-netto-rub
    , input  v-cntxt-userid
    ) no-error .
end.
    run clear-tt-chk in this-procedure.
    run reset-summ-for-pay in this-procedure.
    run set-all-summ ( output p-message
                      , output p-ok
                      ) .
    assign
    p-message    = "Чек аннулирован"
    p-cd-mode    = "0"
    p-cd-submode = "0"
    p-ok         = TRUE
    .
    if not v-emul-mode
    then do:
define variable vss-include-info265 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#disp-lib ) <> TRUE then do:       run gbl/disp-lib.p persistent no-error.       if error-status :error or valid-handle( g#disp-lib ) <> TRUE then do:         message "Error starting disp-lib.p" skip( 0 )           g#disp-lib                        skip( 0 )           g#disp-lib    :type               skip( 0 )           g#disp-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run disp-str in g#disp-lib
    ( INPUT  p-message
    , INPUT  '':U
    , output p-message
    , output p-ok
    )  .
end.
    end.
    else do:
      assign
      p-ok = TRUE
    .
    end.
  end.
end.
end procedure.
procedure 1978 :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define buffer buf_goods    for ub.goods .
define variable v-ref-list    as character    no-undo.
define variable v-count      as integer      no-undo.
define buffer buf_tt-head-check     for tt-head-check .
DEFINE buffer loc_bar-code for ub.bar-code.
DEFINE buffer root_bar-code for ub.bar-code.
define buffer loc_gds-prt for ub.gds-prt.
do
on error undo, return error
:
define buffer buf_rule-call-param   for ub.rule-call-param .
define variable v-gds    as logical      no-undo.
for each  buf_rule-call-param
    where buf_rule-call-param.call_id = buf_temp-layout-elem-rule.uniq-key-rec
    no-lock
:
  case buf_rule-call-param.param-name:
    WHEN "p-gds-code"  then do:
      if  buf_rule-call-param.param-value-integer <> 0
      AND buf_rule-call-param.param-value-integer <> ?
      then
      assign
      v-src = STRING(buf_rule-call-param.param-value-integer)
      v-gds = TRUE
      .
    end.
    OTHERWISE DO:
    end.
   end case.
 end.
if v-src <> '' then
do:
  assign
   v-gds = yes .
end.
if v-gds then do:
  if not CAN-find ( buf_tt-head-check )
   then do:
         run clear-tt-chk in this-procedure.
         run chk-sale-open   ( INPUt-OUTPUT p-cd-mode
                           , INPUt-output p-cd-submode
                           , output p-message
                           , output p-ok
                           ) .
         if not p-ok
         then do:
            return.
         end.
   end.
   run set-input-time in this-procedure ( input -1, output p-message, output p-ok ).
   run add-gds-line in this-procedure (input-output p-cd-mode, input-output p-cd-submode, output p-message, output p-ok).
end.
else do:
  run ref/gds-ref.p
      ( parParentProc
      , "b-sel"
      , 'все':U
      , 'все':U
      , 'факт':U
      , ?
      , ?
      , ?
      , ?
      , v-cntxt-obj-type
      , v-cntxt-obj-code
      , ?
      , output v-ref-list).
  if v-ref-list = ""
  then do:
      return.
  end.
  if not CAN-find ( buf_tt-head-check )
  then do:
    run clear-tt-chk in this-procedure.
    run chk-sale-open   ( INPUt-OUTPUT p-cd-mode
                      , INPUt-output p-cd-submode
                      , output p-message
                      , output p-ok
                      ) .
    if not p-ok
    then do:
       return.
     end.
  end.
  DO v-count = 1 TO NUM-ENTRIES(v-ref-list)
  on error undo, next
  :
    find first buf_goods
      where recid( buf_goods ) = INTEGER(ENTRY(v-count, v-ref-list))
      NO-LOCK
      no-error.
    if available buf_goods then do:
      if v-doc-prt then do:
        find first ub.gds-prt where
                ub.gds-prt.upper-code = buf_goods.prt-root NO-LOCK .
        if v-doc-prt and  gds-prt.node-name <> '_Пустая шкала':U then do:
          define variable v-sel-node-code as integer   no-undo .
          run str/prt-ref.w
            (input parparentproc
            ,input  buf_goods.gds-code
            ,input  'выбор':U
            ,input  v-cntxt-obj-type
            ,input  v-cntxt-obj-code
            ,input  ""
            ,input  ""
            ,output v-sel-node-code
            ) .
          if v-sel-node-code <> ? then do:
            find first loc_gds-prt No-LOCK
              where loc_gds-prt.node-code = v-sel-node-code
              No-error.
            if not avail loc_gds-prt then return error.
              if not loc_gds-prt.is-term then do:
                message
                "Признак" loc_gds-prt.f-name "нетерминальный" skip
                view-as alert-box Warning.
              end.
            find first loc_bar-code where
                  loc_bar-code.node-code = ub.gds-prt.node-code AND
                  loc_bar-code.gds-code = buf_goods.gds-code AND
                  loc_bar-code.in-code = "" AND
                  loc_bar-code.part-code = ""  AND
                  loc_bar-code.unit-cli = buf_goods.unit-base NO-LOCK .
            find first root_bar-code No-LOCK where
                    root_bar-code.gds-code = loc_bar-code.gds-code AND
                    root_bar-code.unit-cli = loc_bar-code.unit-cli AND
                    root_bar-code.in-code   = "" AND
                    root_bar-code.part-code = "" AND
                    root_bar-code.node-code  = loc_gds-prt.node-code no-error.
            if AVAIl root_bar-code then do:
                v-src = string(root_bar-code.b-code).
            end.
            else do:
              message
              "Отсутствует бар-код для признака" loc_gds-prt.f-name
              view-as alert-box WARNING.
              return.
            end.
          end.
          else return.
        end.
        else do:
          assign
          v-src = STRING(buf_goods.gds-code)
          .
        end.
      end.
      else do:
        assign
        v-src = STRING(buf_goods.gds-code)
        .
      end.
      case p-cd-mode:
        when "1"
        or
        when "2"
        or
        when "7"
        then do:
          case p-cd-submode:
            when "6" then do:
              run input-find-str in this-procedure (
                                                    input-output p-cd-mode
                                                   ,input-output p-cd-submode
                                                   ,output p-message
                                                   ,output p-ok
                                                   ).
            end.
            otherwise do:
              run set-input-time in this-procedure ( input -1, output p-message, output p-ok ).
              run add-gds-line in this-procedure (input-output p-cd-mode, input-output p-cd-submode, output p-message, output p-ok).
            end.
          end  case.
        end.
        otherwise do:
        end.
      end case.
    end.
  end.
end.
end.
end procedure.
procedure card-select :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define buffer buf_dis-card    for ub.dis-card .
define variable v-ref-list    as character    no-undo.
define variable v-count      as integer      no-undo.
do
on error undo, return error
:
   run ref/discards.w
      ( parParentProc
      , "b-sel"
      , 'все':U
      , v-cntxt-host-code-obj
      , v-cntxt-obj-type
      , v-cntxt-obj-code
      , ?
      , ?
      , output v-ref-list
      ) .
   if v-ref-list = ""
   then do:
      return.
   end.
   DO v-count = 1 TO NUM-ENTRIES(v-ref-list)
   on error undo, next
   :
      find first buf_dis-card
         where recid( buf_dis-card ) = INTEGER(ENTRY(v-count, v-ref-list))
         NO-LOCK
         no-error.
      if available buf_dis-card then do:
         assign
            v-src = STRING(buf_dis-card.d-card)
         .
         run input-card in this-procedure (input-output p-cd-mode, input-output p-cd-submode, output p-message, output p-ok).
      end.
   end.
end.
end procedure.
procedure saller-select :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define buffer buf_staff    for ub.staff .
define variable v-ref-list    as character    no-undo.
define variable v-count      as integer      no-undo.
do
on error undo, return error
:
   run ref/staffs.w
      ( parParentProc
      , "b-sel"
      , 'S':U
      , v-cntxt-db-num
      , 0
      , output v-ref-list
      ) .
   if v-ref-list = ""
   then do:
      return.
   end.
   DO v-count = 1 TO NUM-ENTRIES(v-ref-list)
   on error undo, next
   :
      find first buf_staff
         where recid( buf_staff ) = INTEGER(ENTRY(v-count, v-ref-list))
         NO-LOCK
         no-error.
      if available buf_staff then do:
         assign
            v-src = STRING(buf_staff.staff-code)
         .
         run input-saller in this-procedure (input-output p-cd-mode, input-output p-cd-submode, output p-message, output p-ok).
      end.
   end.
end.
end procedure.
procedure 1986 :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define buffer buf_chk-doc        for ub.chk-doc .
define buffer buf_chk-gds        for ub.chk-gds .
define buffer buf_tt-line        for tt-line .
define buffer buf_tt-open-check  for tt-open-check .
define variable v-doc-code-list    as character    no-undo.
define variable v-rid-list    as character    no-undo.
define variable v-b-code        as integer no-undo .
define variable v-chk-name      as character no-undo .
define variable v-second-name   as character no-undo .
define variable v-setted        as logical no-undo .
define variable v-gds-code      as integer no-undo .
define variable v-src-sum       as decimal no-undo .
define variable v-src-sum-netto as decimal no-undo .
define variable v-chk-type      as character    no-undo.
define variable v-chk-list-type    as logical      no-undo.
define variable v-count         as integer      no-undo.
do
on error undo, return error
:
   if CAN-find( first buf_tt-open-check where buf_tt-open-check.chk-type = INTEGER('1':U))
   then do:
      assign
         p-message = "Чек возврата уже привязан к чеку продажи"
         p-ok      = TRUE
      .
      return.
   end.
   if CAN-find( first tt-line )
   then do:
      assign
         p-message = "В текущем чеке есть строки, выбрать чек возврата НЕВОЗМОЖНО"
         p-ok      = no
      .
      return.
   end.
   run str/chk-docs.w   ( input parparentproc
                        , input "b-sel"
                        , input 'IBS-TH':U
                        , input ?
                        , input v-cntxt-obj-type
                        , input v-cntxt-obj-code
                        , input '':U
                        , input '':U
                        , input p-cash-num
                        , input ?
                        , input ?
                        , input integer('1':U)
                        , output v-rid-list) no-error.
   if v-rid-list = "":U
   then do:
      assign
         p-message = "Отказ от выбора чека"
         p-ok      = TRUE
      .
      return.
   end.
   if p-cd-mode = "0"
   then do:
      run 1987 in this-procedure ( INPUt-OUTPUT p-cd-mode
                                 , input-output p-cd-submode
                                 , output p-message
                                 , output p-ok
                                 ) .
   end.
   define buffer buf_rule-call-param   for ub.rule-call-param .
   define variable v-dont-load-lines    as logical      no-undo.
   for each  buf_rule-call-param
         where buf_rule-call-param.call_id = buf_temp-layout-elem-rule.uniq-key-rec
         no-lock
      :
      case buf_rule-call-param.param-name:
         WHEN "p-dont-load-lines"
         then do:
            if buf_rule-call-param.param-value-logical <> ?
            then
            assign
               v-dont-load-lines        = buf_rule-call-param.param-value-logical
            .
         end.
         OTHERWISE DO:
         end.
      end case.
   end.
   if v-dont-load-lines = FALSE then
   _proc-body:
   DO v-count = 1 TO 1
   on error undo, NEXT
   :
      find first buf_chk-doc
         where RECID(buf_chk-doc) = INTEGER(ENTRY(v-count, v-rid-list))
         no-lock
         no-error
         no-wait
         .
      if  buf_chk-doc.chk-type <> integer('1':U)
      then do:
         UNDO _proc-body, NEXT _proc-body .
      end.
      assign
         v-chk-type = '6':U
         v-doc-code-list = v-doc-code-list + "," + buf_chk-doc.doc-code
      .
      assign
         v-pass-gds = 0
      .
      for each buf_chk-gds
         where buf_chk-gds.doc-code = buf_chk-doc.doc-code
         no-lock
      :
         find first buf_tt-line
              where buf_tt-line.ord-chk-num  = buf_chk-gds.doc-code
                AND buf_tt-line.ord-line-num = buf_chk-gds.line-num
              no-lock no-error.
         if available buf_tt-line then NEXT.
         assign
            v-write-off-code  = 0
            v-src-price       = (buf_chk-gds.price-base - buf_chk-gds.discnt) * ( buf_chk-gds.doc-qnty / buf_chk-gds.src-qnty)
            v-src-discnt      = buf_chk-gds.discnt
            v-src-qnty        = buf_chk-gds.src-qnty
            v-num             = 0
            v-src             = buf_chk-gds.src-code
            v-pump            = buf_chk-gds.pump
            v-nozzle-code     = buf_chk-gds.nozzle-code
            v-pl-code         = buf_chk-gds.pl-code
            v-fbr-depart      = buf_chk-gds.depart-id
            v-ord-chk-num     = buf_chk-gds.doc-code
            v-ord-line-num    = buf_chk-gds.line-num
         .
         run add-gds-line in this-procedure  ( INPUt-OUTPUT p-cd-mode
                                             , INPUt-output p-cd-submode
                                             , output p-message
                                             , output p-ok
                                             ) .
         assign
            v-write-off-code  = 0
            v-src-price       = 0
            v-src-qnty        = 0
            v-num             = 0
            v-src             = "":U
         .
         if not p-ok then do:
            UNDO _proc-body, LEAVE _proc-body .
         end.
         if buf_chk-gds.sales-man > 0
         then do:
            find first buf_tt-line
               where buf_tt-line.ord-chk-num  = buf_chk-gds.doc-code
                  AND buf_tt-line.ord-line-num = buf_chk-gds.line-num
               no-lock
               .
            assign
               v-src = STRING(buf_chk-gds.sales-man)
            .
            run input-saller in this-procedure (input-output p-cd-mode, input-output p-cd-submode, output p-message, output p-ok).
         end.
      end.
      if not CAN-find (first buf_tt-open-check
                       where buf_tt-open-check.doc-code = buf_chk-doc.doc-code
                         AND buf_tt-open-check.chk-type = buf_chk-doc.chk-type
                       )
      then do:
         create buf_tt-open-check.
         assign
            buf_tt-open-check.doc-code = buf_chk-doc.doc-code
            buf_tt-open-check.chk-type = buf_chk-doc.chk-type
         .
         v-aux-mess = substitute("Возврат по чеку: &1", buf_chk-doc.doc-code).
      end.
   end.
   assign
      v-doc-code-list = TRIM( v-doc-code-list , "," )
   .
define variable vss-include-info266 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  1
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  v-chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  v-doc-code-list
    , input  '':U
    , input  TODAY
    , input  61
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-rid-list
    , input  v-cntxt-userid
    ) no-error .
end.
   if p-ok
   then do:
      find first buf_tt-line no-lock no-error.
      if available buf_tt-line
      then do:
         assign
            v-curr-num-0  = buf_tt-line.num
            v-curr-type-0 = buf_tt-line.type
         .
      end.
   end.
   else do:
      for each buf_tt-open-check
         :
         DELETE buf_tt-open-check.
      end.
   end.
end.
end procedure.
procedure 1990 :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define variable v-chk-fr-num    as character    no-undo.
define variable v-doc-code      as character no-undo .
do
on error undo, return error
:
   run adm/chk-pass.w   ( input parparentproc
                        , input v-cntxt-userid
                        , input v-cntxt-db-num
                        , input "actn_ibsthpos-add-rep"
                        , input FALSE
                        , output p-message
                        , output p-ok
                        ) .
   if not p-ok
   then return.
   if not v-emul-mode
      then do:
define variable vss-include-info267 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-x-rep in g#fr-lib
    ( output       p-message
    , output       p-ok
    ) no-error .
end.
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         return.
      end.
   end.
   else do:
      assign
         p-ok = TRUE
      .
   end.
define variable vss-include-info268 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  1
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  77
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
end.
end procedure.
procedure set-emul-mode :
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   assign
      v-emul-mode = TRUE
      p-ok        = TRUE
   .
end.
end procedure.
procedure pay-select :
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define variable v-ref-list    as character    no-undo.
define buffer buf_cash-pay    for ub.cash-pay .
do
on error undo, return error
:
   run ref/cashpays.w   ( input parparentproc
                        , input "b-sel":U
                        , input 'все':U
                        , input v-cntxt-host-code-obj
                        , input v-cntxt-obj-type
                        , input v-cntxt-obj-code
                        , output v-ref-list
                        ) .
   if v-ref-list = ""
   then do:
      return.
   end.
   find first buf_cash-pay
        where recid( buf_cash-pay ) = INTEGER(ENTRY(1, v-ref-list))
        NO-LOCK
        no-error
        .
   if available buf_cash-pay then do:
      assign
         v-pay-type        = buf_cash-pay.cdpay-code
         v-curr-base-code  = buf_cash-pay.curr-code
         p-message         = buf_cash-pay.obj-name
         p-ok              = TRUE
      .
   end.
end.
end procedure.
procedure set-cd-base-code :
define input parameter p-base-code as integer          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define buffer buf_currency    for ub.currency .
do
on error undo, return error
:
   find first buf_currency
         where buf_currency.curr-code = p-base-code
         no-lock
         no-error
         .
   if not available buf_currency
   then do:
      assign
         p-ok             = TRUE
         p-message = substitute("Не найдена базовая валюта &1", p-base-code)
      .
      return.
   end.
   assign
      v-cd-base-name   = buf_currency.curr-abbr
      v-cd-base-code   = p-base-code
      v-curr-base-code = p-base-code
      p-ok             = TRUE
   .
end.
end procedure.
procedure input-find-str :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define buffer buf_tt-line     for tt-line .
define buffer buf_tt-head-check     for tt-head-check .
define variable v-search-code    as integer      no-undo.
do
on error undo, return error
:
   find first buf_tt-head-check.
define variable vss-include-info269 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  2
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  v-src
    , input  '':U
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  48
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
   if v-found-str <> v-src
   then do:
      assign
         v-found-num  = 0
      .
   end.
   assign
      v-found-str = v-src
   .
   find first buf_tt-line
        where buf_tt-line.type = 0
          AND buf_tt-line.src  = v-found-str
          AND buf_tt-line.num  > v-found-num
        NO-LOCK
        no-error
        .
   if not available buf_tt-line
   then do:
      if v-found-num > 0
      then do:
         assign
            v-found-num  = 0
         .
         find first buf_tt-line
            where buf_tt-line.type = 0
               AND buf_tt-line.src  = v-found-str
               AND buf_tt-line.num  > v-found-num
            NO-LOCK
            no-error
            .
      end.
      else do:
         assign
            p-message    = "По запросу ничего не найдено."
            p-cd-submode = "0"
            v-found-num  = 0
            p-ok         = FALSE
         .
         return.
      end.
   end.
   assign
      v-curr-num-0   = buf_tt-line.num
      v-found-num    = buf_tt-line.num
      v-curr-type-0  = 0
      p-cd-submode = "0"
      p-ok         = TRUE
   .
end.
end procedure.
procedure chk-inv-open :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   run clear-tt-chk in this-procedure.
   run chk-open   ( input integer('11':U)
                  , INPUt-OUTPUT p-cd-mode
                  , INPUt-output p-cd-submode
                  , output p-message
                  , output p-ok
                  ) .
   if p-ok
   then do:
      assign
         p-message    = "Инвентаризация"
         p-cd-mode    = "1"
         p-cd-submode = "0"
      .
   end.
end.
end procedure.
procedure chk-inc-open :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
define variable vss-include-info270 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  84
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
   run clear-tt-chk in this-procedure.
   run chk-open   ( input integer('2':U)
                  , INPUt-OUTPUT p-cd-mode
                  , INPUt-output p-cd-submode
                  , output p-message
                  , output p-ok
                  ) .
   if p-ok
   then do:
                v-aux-mess =  entry (lookup ('2':U, '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U).
      assign
         p-message    = "Инкассация"
         p-cd-mode    = "8"
         p-cd-submode = "2"
      .
   end.
end.
end procedure.
procedure chk-fnd-open :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
define variable vss-include-info271 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  87
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
   run clear-tt-chk in this-procedure.
   run chk-open   ( input integer('3':U)
                  , INPUt-OUTPUT p-cd-mode
                  , INPUt-output p-cd-submode
                  , output p-message
                  , output p-ok
                  ) .
   if p-ok
   then do:
                v-aux-mess =  entry (lookup ('3':U, '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U).
      assign
         p-message    = "Кассовый фонд"
         p-cd-mode    = "8"
         p-cd-submode = "2"
      .
   end.
end.
end procedure.
procedure 1999 :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   assign
      p-cd-mode     = "8"
      p-cd-submode  = "0"
      p-ok          = TRUE
   .
   case p-cd-mode:
      WHEN "0"
       OR
      WHEN "8"
      then do:
         define buffer buf_rule-call-param   for ub.rule-call-param .
         define variable v-type     as logical      no-undo.
         define variable v-chk-type as integer      no-undo.
         for each  buf_rule-call-param
               where buf_rule-call-param.call_id = buf_temp-layout-elem-rule.uniq-key-rec
               no-lock
            :
            case buf_rule-call-param.param-name:
               WHEN "p-chk-type"
               then do:
                  if  buf_rule-call-param.param-value-integer <> 0
                  AND buf_rule-call-param.param-value-integer <> ?
                  then
                  assign
                     v-chk-type  = buf_rule-call-param.param-value-integer
                     v-type      = TRUE
                  .
               end.
               OTHERWISE DO:
               end.
            end case.
         end.
         if v-type
         then do:
            if v-cash-drawer-plug
            then do:
               run 1988 in this-procedure ( INPUt-OUTPUT p-cd-mode
                                          , INPUt-output p-cd-submode
                                          , output p-message
                                          , output p-ok
                                          ) .
            end.
            case v-chk-type:
               WHEN INTEGER('3':U)
               then do:
                  run chk-fnd-open  ( INPUt-OUTPUT p-cd-mode
                                    , INPUt-output p-cd-submode
                                    , output p-message
                                    , output p-ok
                                    ) .
               end.
               WHEN INTEGER('2':U)
               then do:
                  run chk-inc-open  ( INPUt-OUTPUT p-cd-mode
                                    , INPUt-output p-cd-submode
                                    , output p-message
                                    , output p-ok
                                    ) .
               end.
               OTHERWISE DO:
                                  message
                 substitute("К сожалению, в настоящий момент работа с чеком типа &1 НЕ РЕАЛИЗОВАНА", entry (lookup (string(v-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))
                 view-as alert-box error .
               end.
            end case.
         end.
         else do:
            assign
               p-message = "Укажите тип чека МЦ"
            .
            return.
         end.
      end.
      OTHERWISE DO:
      end.
   end case.
end.
end procedure.
procedure input-summ :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define buffer buf_tt-head-check     for tt-head-check .
define variable v-pline-num as integer no-undo .
define variable v-pass-pay as integer no-undo .
define variable v-pay-card as character no-undo .
define variable v-tot-sum as decimal no-undo .
define variable v-tot-rubl as decimal no-undo .
define variable v-tot-base as decimal no-undo .
define variable v-2-cdpay-code as integer no-undo .
define variable v-2-curr-code as integer no-undo .
define variable v-2-tot-base as decimal no-undo .
define variable v-2-tot-rubl as decimal no-undo .
define variable v-frpay-code as integer no-undo .
define variable v-2-frpay-code as integer no-undo .
define variable v-msg    as character    no-undo.
do
on error undo, return error
:
   if DECIMAL(v-src) < 0
   then do:
      assign
         p-message = "Сумма должна быть не меньше нуля"
         p-ok      = FALSE
      .
      return.
   end.
   run input-pay-sale in this-procedure ( input-output p-cd-mode
                                       , input-output p-cd-submode
                                       , output p-message
                                       , output p-ok
                                       ) no-error.
   if error-status:error
   OR not p-ok
   then do:
      assign
         p-message = substitute("pay &1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
      return.
   end.
   assign
      v-msg = p-message
   .
   run 1982 in this-procedure ( input-output p-cd-mode
                              , input-output p-cd-submode
                              , output p-message
                              , output p-ok
                              ) no-error.
   if error-status:error
   OR not p-ok
   then do:
      assign
         p-message = substitute("cl &1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
      return.
   end.
   assign
      p-message     = v-msg
      p-cd-mode     = "0"
      p-cd-submode  = "0"
      p-ok          = TRUE
   .
end.
end procedure.
procedure 1988 :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define buffer buf_tt-head-check     for tt-head-check .
define variable v-doc-code      as character no-undo .
define variable v-chk-type    as integer      no-undo.
do
on error undo, return error
:
   if not v-emul-mode
   then do:
define variable vss-include-info272 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-draop in g#fr-lib
    ( output      p-message
    , output      p-ok
    )  .
end.
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         return.
      end.
      find first buf_tt-head-check no-error.
      if available buf_tt-head-check
      then do:
         assign
            v-doc-code = buf_tt-head-check.doc-code
            v-chk-type = buf_tt-head-check.chk-type
         .
      end.
define variable vss-include-info273 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  1
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  v-chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  v-doc-code
    , input  '':U
    , input  TODAY
    , input  62
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
   end.
   else do:
      assign
         p-ok = TRUE
      .
   end.
end.
end procedure.
procedure 2003 :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
do
on error undo, return
:
define variable vss-include-info274 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  2
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  0
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  76
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
   run str/stockscr.w ( v-cntxt-userid ) no-error.
   assign
      p-ok = TRUE
   .
end.
end procedure.
procedure pay-fix-summ :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   assign
      v-src = STRING(v-fix-summ-pay)
   .
   run input-pay-sale  ( INPUt-OUTPUT p-cd-mode
                     , INPUt-output p-cd-submode
                     , output p-message
                     , output p-ok
                     ) .
end.
end procedure.
procedure 1995 :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
define variable v-integer   as integer      no-undo.
define variable v-character as character    no-undo.
define variable v-decimal   as decimal      no-undo.
define variable v-logical   as logical      no-undo.
define variable v-handle as handle no-undo .
define variable v-date    as date         no-undo.
define variable v-data-type    as character    no-undo.
define variable v-setted as logical   no-undo .
do
on error undo, return error
:
define variable vss-include-info275 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-context-property in g#libthpos
  (input  1
  ,input  'cash-counter'
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-handle
  ,output v-data-type
  ,output v-setted
  ) no-error .
define variable vss-include-info276 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  1
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  75
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-decimal
    , input  v-cntxt-userid
    ) no-error .
end.
   message
      "Наличность в денежном ящике:"
      skip v-decimal
      skip "Предел наличности в денежном ящике:"
      skip v-cash-drawer-limit
   view-as alert-box information.
   assign
      p-ok = TRUE
   .
end.
end procedure.
procedure input-discont :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
define buffer buf_tt-head-check     for tt-head-check .
define variable v-next    as character    no-undo.
define variable v-st-r-b as decimal no-undo .
define variable v-st-rubl as decimal no-undo .
define variable v-st-base as decimal no-undo .
define variable v-tot-doc as decimal no-undo .
define variable v-netto as decimal no-undo .
define variable v-netto-rubl as decimal no-undo .
define variable v-netto-base as decimal no-undo .
define variable v-all-discnt as decimal no-undo .
define variable v-all-discnt-rubl as decimal no-undo .
define variable v-all-discnt-base as decimal no-undo .
define variable v-type-name    as character    no-undo.
define variable v-obj-name     as character    no-undo.
define variable v-end          as character    no-undo.
define variable v-local-src    as character    no-undo.
define variable v-dsk    as character    no-undo.
do
on error undo, return error
:
   case v-disc-type:
      WHEN '10':U
      then do:
         assign
            v-type-name = "Абсолютная"
            v-end       = "":U
         .
      end.
      WHEN '1':U
      then do:
         assign
            v-type-name = "Процентная"
            v-end       = "%":U
         .
      end.
      OTHERWISE DO:
      end.
   end case.
   assign
      v-local-src = v-src
      v-dsk       = v-disc-type + " " + v-src
   .
   find buf_tt-head-check.
   case p-cd-submode:
      WHEN "5"
      then do:
define variable vss-include-info277 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  v-dsk
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  45
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
define variable vss-include-info278 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_sub-total in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  ''
  ,output p-ok
  ,input-output v-st-r-b
  ,input-output v-st-rubl
  ,input-output v-st-base
  ,input-output v-tot-doc
  ,input-output v-discnt-chk
  ,output v-netto
  ,output v-netto-rubl
  ,output v-netto-base
  ,output v-all-discnt
  ,output v-all-discnt-rubl
  ,output v-all-discnt-base
  ) no-error .
         if error-status:error then do:
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info279 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  v-dsk
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  47
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
define variable vss-include-info280 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_set-subtotal-manual-discnt in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  INTEGER(v-disc-type)
  ,input  DECIMAL(v-src)
  ,output p-ok
  ,output v-next
  ,input-output v-st-r-b
  ,input-output v-st-rubl
  ,input-output v-st-base
  ,input-output v-tot-doc
  ,input-output v-discnt-chk
  ) no-error .
         if error-status:error
         then do:
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info281 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  v-dsk
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  47
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
define variable vss-include-info282 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  v-dsk
    , input  buf_tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  46
    , input  TIME
    , input  'S':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  v-discnt-chk
    , input  v-cntxt-userid
    ) no-error .
end.
         assign
            v-obj-name = "на итог"
            buf_tt-head-check.hand-discounted = v-disc-type
         .
      end.
      WHEN "4"
      then do:
define variable vss-include-info283 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  v-dsk
    , input  buf_tt-head-check.doc-code
    , input  bufbr_tt-line.qnty
    , input  TODAY
    , input  42
    , input  TIME
    , input  'U':U
    , input  bufbr_tt-line.line-code
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  bufbr_tt-line.summ-netto
    , input  v-cntxt-userid
    ) no-error .
end.
         if not available bufbr_tt-line
         then do:
            assign
               p-message = "Чек пуст"
               p-ok      = FALSE
            .
define variable vss-include-info284 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  v-dsk
    , input  buf_tt-head-check.doc-code
    , input  0
    , input  TODAY
    , input  43
    , input  TIME
    , input  'S':U
    , input  '':U
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
           return .
         end.
         if bufbr_tt-line.type <> 0
         then do:
            assign
               p-message = "Скидка устанавливается только на товарную строку"
               p-ok      = FALSE
            .
define variable vss-include-info285 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  v-dsk
    , input  buf_tt-head-check.doc-code
    , input  0
    , input  TODAY
    , input  43
    , input  TIME
    , input  'S':U
    , input  '':U
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return .
         end.
define variable vss-include-info286 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_set-gds-manual-discnt in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  bufbr_tt-line.num
  ,input  INTEGER(v-disc-type)
  ,input  DECIMAL(v-src)
  ,output p-ok
  ,output v-next
  ,input-output bufbr_tt-line.summ-discont
  ,input-output bufbr_tt-line.summ-brutto
  ,input-output bufbr_tt-line.summ-netto
  ) no-error .
         if error-status:error
         then do:
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info287 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  v-dsk
    , input  buf_tt-head-check.doc-code
    , input  bufbr_tt-line.qnty
    , input  TODAY
    , input  43
    , input  TIME
    , input  'S':U
    , input  bufbr_tt-line.line-code
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  bufbr_tt-line.summ-netto
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
         assign
            v-obj-name = "на строку"
            bufbr_tt-line.hand-discounted = v-disc-type
         .
      end.
      OTHERWISE DO:
      end.
   end case.
define variable vss-include-info288 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  buf_tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  v-dsk
    , input  buf_tt-head-check.doc-code
    , input  bufbr_tt-line.qnty
    , input  TODAY
    , input  44
    , input  TIME
    , input  'E':U
    , input  bufbr_tt-line.line-code
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  v-src
    , input  bufbr_tt-line.summ-netto
    , input  v-cntxt-userid
    ) no-error .
end.
   define variable v-num-local   as integer      no-undo.
   define variable v-type-local  as integer      no-undo.
   assign
      v-num-local  = v-curr-num-0
      v-type-local = v-curr-type-0
   .
   run refresh-lines in this-procedure
                  ( output p-message
                  , output p-ok
                  ) .
   assign
      v-curr-num-0     = v-num-local
      v-curr-type-0    = v-type-local
      v-src-qnty  = 0
   .
   if p-ok
   then do:
      assign
         p-message = substitute  ( "&1 скидка &2 &3&4"
                                 , v-type-name
                                 , v-obj-name
                                 , v-local-src
                                 , v-end
                                 )
         p-cd-submode = "0"
         v-disc-type  = "":U
      .
   end.
end.
end procedure.
procedure discont-abs :
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   assign
      p-message   = "Абсолютная скидка"
      v-disc-type = '10':U
      p-ok        = TRUE
   .
end.
end procedure.
procedure discont-per :
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
   assign
      p-message   = "Процентная скидка"
      v-disc-type = '1':U
      p-ok        = TRUE
   .
do
on error undo, return error
:
end.
end procedure.
procedure discont-fix :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   assign
      v-src = STRING(v-fix-summ-pay)
   .
   run input-discont  ( input-output p-cd-mode
                     , INPUt-output p-cd-submode
                     , output p-message
                     , output p-ok
                     ) .
end.
end procedure.
procedure 1980 :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
define buffer buf_tt-line     for tt-line .
do
on error undo, return error
:
      if  p-cd-submode = "0"
      then do:
         if not available bufbr_tt-line
         then do:
            assign
               p-message = "Чек пуст"
               p-ok      = FALSE
            .
            return .
         end.
         if bufbr_tt-line.type <> 0
         then do:
            assign
               p-message = "Скидка устанавливается только на товарную строку"
               p-ok      = FALSE
            .
            return .
         end.
         run adm/chk-pass.w   ( input parparentproc
                              , input v-cntxt-userid
                              , input v-cntxt-db-num
                              , input "actn_ibsthpos-discont"
                              , input FALSE
                              , output p-message
                              , output p-ok
                              ) .
         if CAN-find (first buf_tt-line where buf_tt-line.type = 1 NO-LOCK)
         then do:
            assign
               p-message = "Скидка должна быть задана до принятия платежей"
               p-ok      = FALSE
            .
         end.
         if not p-ok
         then return.
         assign
            p-message   = "Cкидка на товарную строку чека"
            p-cd-submode = "4"
            p-ok = TRUE
         .
      end.
      if  p-cd-submode = "4"
      then do:
         define buffer buf_rule-call-param   for ub.rule-call-param .
         define buffer buf_cash-pay          for ub.cash-pay .
         define variable v-type    as logical      no-undo.
         define variable v-value    as logical      no-undo.
         for each  buf_rule-call-param
               where buf_rule-call-param.call_id = buf_temp-layout-elem-rule.uniq-key-rec
               no-lock
            :
            case buf_rule-call-param.param-name:
               WHEN "p-discnt-v-type"
               then do:
                  if  buf_rule-call-param.param-value-integer <> 0
                  AND buf_rule-call-param.param-value-integer <> ?
                  then
                  assign
                     v-disc-type       = STRING(buf_rule-call-param.param-value-integer)
                     v-type            = TRUE
                  .
               end.
               WHEN "p-discnt-value"
               then do:
                  if  buf_rule-call-param.param-value-decimal <> 0
                  AND buf_rule-call-param.param-value-decimal <> ?
                  then
                  assign
                     v-src = STRING(buf_rule-call-param.param-value-decimal)
                     v-value = TRUE
                  .
               end.
               OTHERWISE DO:
               end.
            end case.
         end.
         if v-type
         then do:
            if v-value
            then do:
               run input-discont ( INPUt-OUTPUT p-cd-mode
                                 , INPUt-output p-cd-submode
                                 , output p-message
                                 , output p-ok
                                 ) .
            end.
            else do:
               case v-disc-type:
                  WHEN '10':U
                  then do:
                     assign
                        p-message = "Абсолютная скидка на товарную строку"
                        p-ok      = TRUE
                     .
                  end.
                  WHEN '1':U
                  then do:
                     assign
                        p-message = "Процентная скидка на товарную строку"
                        p-ok      = TRUE
                     .
                  end.
                  OTHERWISE DO:
                     assign
                        p-message = substitute("Неизвестный тип скидки - &1",v-disc-type)
                     .
                  end.
               end case.
            end.
         end.
         else do:
            assign
               p-message = "Укажите тип скидки на товарную строку чека"
            .
            return.
         end.
      end.
end.
end procedure.
procedure recalc-lines :
define input         parameter p-start-line as integer          no-undo.
define input         parameter p-st as integer          no-undo.
define input         parameter p-pay as integer          no-undo.
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output  parameter p-message     as character      no-undo .
define output  parameter p-ok          as logical          no-undo.
define buffer buf_tt-line     for tt-line .
do
on error undo, return error
:
   for each  buf_tt-line
       where buf_tt-line.type =  0
         AND buf_tt-line.num  >= p-start-line
       NO-LOCK
       :
       assign
         v-src = STRING(buf_tt-line.qnty)
         v-curr-num-0  = buf_tt-line.num
         v-curr-type-0 = buf_tt-line.type
       .
       run upd-line in this-procedure
                     ( input-output p-cd-mode
                     , INPUt-output p-cd-submode
                     , output p-message
                     , output p-ok
                     ) .
   end.
   run set-all-summ ( output p-message
                      , output p-ok
                      ) .
   if p-pay > 0
   then do:
      for each  buf_tt-line
         where buf_tt-line.type =  1
         NO-LOCK
         :
         assign
            v-src         = STRING(buf_tt-line.line-name-2)
            v-curr-num-0  = buf_tt-line.num
            v-curr-type-0 = buf_tt-line.type
         .
         run upd-line in this-procedure
                        ( input-output p-cd-mode
                        , INPUt-output p-cd-submode
                        , output p-message
                        , output p-ok
                        ) .
         assign
            v-src         = ""
         .
      end.
   end.
   if p-st > 0
   then do:
      run set-all-summ ( output p-message
                       , output p-ok
                       ) .
   end.
end.
end procedure.
procedure refresh-lines :
define output  parameter p-message     as character      no-undo .
define output  parameter p-ok          as logical          no-undo.
define buffer buf_tt-line     for tt-line .
do
on error undo, return error
:
   for each  buf_tt-line
       where buf_tt-line.type =  0
       NO-LOCK
       :
       assign
         v-curr-num-0  = buf_tt-line.num
         v-curr-type-0 = buf_tt-line.type
       .
       run refresh-gds-line in this-procedure ( output p-message
                                              , output p-ok
                                              ) .
   end.
      run set-all-summ ( output p-message
                       , output p-ok
                       ) .
end.
end procedure.
procedure refresh-gds-line :
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.
define buffer buf_tt-line     for tt-line .
define buffer buf_tt-head-check     for tt-head-check .
define variable v-b-code          as integer no-undo .
define variable v-gds-code        as integer no-undo .
define variable v-chk-name        as character no-undo .
define variable v-second-name     as character no-undo .
define variable v-src-sum         as decimal no-undo .
define variable v-src-sum-netto   as decimal no-undo .
define variable v-next    as character    no-undo.
define variable v-qnty-old    as decimal      no-undo.
define variable v-src-discnt-local    as decimal      no-undo.
define variable v-src-discnt-local-rub    as decimal      no-undo.
define variable v-for-discnt-local-doc    as decimal no-undo .
define variable v-for-discnt-local-rubl   as decimal no-undo .
define variable v-for-discnt-local-r-b    as decimal no-undo .
do
on error undo, return error
:
   if  v-curr-num-0 <> 0
   then do:
      find buf_tt-head-check.
      find first buf_tt-line
         where buf_tt-line.num  = v-curr-num-0
           and buf_tt-line.type = v-curr-type-0
         no-lock
         .
      case buf_tt-line.type:
         WHEN 0 then do:
            define variable v-qqq    as decimal      no-undo.
            assign
               v-pump            = 0
               v-nozzle-code     = 0
               v-pl-code         = 0
               v-pass-gds        = 0
               v-fbr-depart      = 0
               v-src-price       = buf_tt-line.price-rub
               v-src-qnty        = if buf_tt-head-check.chk-type = INTEGER('6':U) then - buf_tt-line.qnty else buf_tt-line.qnty
               v-write-off-code  = 0
               v-src             = buf_tt-line.src
            .
define variable vss-include-info289 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_gds-line in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  v-curr-num-0
  ,input  'ПРОСМОТР':U
  ,input  0
  ,input  buf_tt-line.src
  ,input-output  v-src-qnty
  ,input  v-pump
  ,input  v-nozzle-code
  ,input  v-pl-code
  ,input  v-pass-gds
  ,input  v-write-off-code
  ,input  v-fbr-depart
  ,output p-ok
  ,output v-next
  ,output v-b-code
  ,output v-gds-code
  ,output v-chk-name
  ,output v-second-name
  ,input-output v-src-price
  ,output v-src-price-rub
  ,output v-src-discnt
  ,output v-src-discnt-rub
  ,output v-src-sum
  ,output v-src-sum-rub
  ,output v-src-sum-netto
  ,output v-src-sum-netto-rub
  ,output v-unit-base
  ) no-error .
            if error-status:error
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
               return.
            end.
            assign
               buf_tt-line.qnty           = ABSOLUTE(v-src-qnty)                              buf_tt-line.qnty-str         = STRING(ABSOLUTE(v-src-qnty), "->>,>>>,>>9.999":U)                              buf_tt-line.price            = ABS(v-src-price)                              buf_tt-line.price-rub        = ABS(v-src-price-rub)                              buf_tt-line.price-STR        = STRING(ABSOLUTE(v-src-price-rub), "->>,>>>,>>9.99":U)                             buf_tt-line.summ-netto       = ABSOLUTE(v-src-sum-netto)                                                      buf_tt-line.summ-netto-rub   = ABSOLUTE(v-src-sum-netto-rub)                                                      buf_tt-line.summ-brutto      = ABSOLUTE(v-src-sum)                                                             buf_tt-line.summ-brutto-rub  = ABSOLUTE(v-src-sum-rub)                                                             buf_tt-line.unit-base        = v-unit-base                             buf_tt-line.summ-discont     = ABSOLUTE(v-src-discnt)                             buf_tt-line.summ-discont-rub = ABSOLUTE(v-src-discnt-rub)
            .
         end.
         WHEN 1 then do:
         end.
         OTHERWISE DO:
         end.
      end case.
   end.
   assign
      p-ok         = TRUE
   .
end.
end procedure.
define variable vss-include-info290 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure prep-lay_get-layout :
define input parameter p-layout-type as character no-undo .
define input parameter p-device-type as character no-undo .
define input parameter p-layout-id as character no-undo .
define buffer buf_layout for ub.layout.
define buffer buf_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_temp-layout-elem-rule for temp-layout-elem-rule.
define buffer buf_temp-rule-call-param for temp-rule-call-param .
main-block:
do
on error undo, return error
:
  for each buf_temp-layout-elem-rule where buf_temp-layout-elem-rule.layout-id = p-layout-id:
    for each buf_temp-rule-call-param where
            buf_temp-rule-call-param.call_id = buf_temp-layout-elem-rule.uniq-key-rec
    :
      delete buf_temp-rule-call-param.
    end.
    delete buf_temp-layout-elem-rule.
  end.
  find first buf_layout share-lock where
            buf_layout.layout-id = p-layout-id no-error.
  if not available buf_layout
  or buf_layout.sts <> integer('0':U) then do:
    find first buf_layout share-lock where
            buf_layout.layout-type = p-layout-type
        and buf_layout.device-type = p-device-type
        and buf_layout.is-default = integer('1':U) no-error .
    if not available buf_layout then do:
      undo, return error substitute("Не найдено ни один подходящей раскладки типа &1 для &2"
                                  ,p-layout-type
                                  ,p-device-type).
    end.
  end.
  for each buf_layout-elem-rule no-lock where
          buf_layout-elem-rule.layout-id = buf_layout.layout-id
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    create buf_temp-layout-elem-rule.
    buffer-copy buf_layout-elem-rule to buf_temp-layout-elem-rule.
    for each buf_rule-call-param no-lock where
            buf_rule-call-param.call_id = buf_layout-elem-rule.uniq-key-rec
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
        create buf_temp-rule-call-param.
        buffer-copy buf_rule-call-param to buf_temp-rule-call-param
        assign
        buf_temp-rule-call-param.layout-type = buf_layout.layout-type
        buf_temp-rule-call-param.device-type = buf_layout.device-type
        buf_temp-rule-call-param.mode-id = buf_layout-elem-rule.mode-id
        buf_temp-rule-call-param.widget-id = buf_layout-elem-rule.widget-id
        .
    end.
  end.
end.
end procedure.
procedure set-cd-prop :
define output  parameter p-message     as character      no-undo .
define output  parameter p-ok          as logical          no-undo.
define variable v-character   as character no-undo .
define variable v-date        as date no-undo .
define variable v-decimal     as decimal no-undo .
define variable v-integer     as integer no-undo .
define variable v-logical     as logical no-undo .
define variable v-data-type   as character no-undo .
define variable v-code        as character    no-undo.
define variable v-upper-code  as character    no-undo.
define variable v-count    as integer      no-undo.
define variable v-no-error    as logical      no-undo.
define variable v-handle as handle no-undo .
do
on error undo, return error
:
   assign
      v-upper-code = 'IBS-TH_devices':U
   .
   assign
      v-code       = 'cash-drawer-plug':U
   .
define variable vss-include-info291 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-cash-drawer-plug = logical(v-integer)
   .
   assign
      v-code       = 'cash-drawer-plug-type':U
   .
define variable vss-include-info292 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-cash-drawer-plug-type = v-integer
   .
   assign
      v-code       = 'cash-drawer-plug-port':U
   .
define variable vss-include-info293 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-cash-drawer-plug-port = v-integer
   .
   assign
      v-code       = 'cash-drawer-plug-imp':U
   .
define variable vss-include-info294 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-cash-drawer-plug-imp = v-integer
   .
   assign
      v-code       = 'cash-drawer-open':U
   .
define variable vss-include-info295 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-cash-drawer-open = logical(v-integer)
   .
   assign
      v-code       = 'cash-drawer-limit':U
   .
define variable vss-include-info296 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-cash-drawer-limit = v-decimal
   .
   assign
      v-code       = 'cashless-system':U
   .
define variable vss-include-info297 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-cashless-system = v-character
   .
   assign
      v-code       = 'card-reader-plug':U
   .
define variable vss-include-info298 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-card-reader-plug = logical(v-integer)
   .
   assign
      v-code       = 'customer-display-plug':U
   .
define variable vss-include-info299 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-customer-display-plug = logical(v-integer)
   .
   assign
      v-code       = 'customer-display-adv':U
   .
define variable vss-include-info300 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-customer-display-adv = v-character
   .
   assign
      v-code       = 'keyboard-type':U
   .
define variable vss-include-info301 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-keyboard-type = v-character
   .
   assign
      v-code       = 'keyboard-layout-id':U
   .
define variable vss-include-info302 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-keyboard-layout-id = v-character
   .
   assign
      v-code       = 'customer-display-type':U
   .
define variable vss-include-info303 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-customer-display-type = v-character
   .
   assign
      v-code       = 'customer-display-port':U
   .
define variable vss-include-info304 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-customer-display-port = v-character
   .
   assign
      v-upper-code = 'IBS-TH_fisreg':U
   .
   assign
      v-code       = 'cash-drawer-level':U
   .
define variable vss-include-info305 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-cash-drawer-level = v-integer
   .
   assign
      v-code       = 'cash-pay-list':U
   .
define variable vss-include-info306 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-cp-lst
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-code       = 'pay-names':U
   .
define variable vss-include-info307 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-pay-names = v-character
   .
   assign
      v-code       = 'cutter':U
   .
define variable vss-include-info308 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-cutter = logical(v-integer)
   .
define variable vss-include-info309 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-context-property in g#libthpos
  (input  1
  ,input  'doc-prt'
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-handle
  ,output v-data-type
  ,output p-ok
  ) no-error .
      if error-status:error
      OR not p-ok
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         return .
      end.
      assign v-doc-prt =  v-logical.
   assign
      v-upper-code = 'IBS-TH_rec-print':U
   .
   assign
      v-code       = 'max-netto':U
   .
define variable vss-include-info310 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-max-netto = v-decimal
   .
   assign
      v-code       = 'advert-text':U
   .
define variable vss-include-info311 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-advert-text = v-character
   .
   assign
      v-code       = 'cliche-lines':U
   .
define variable vss-include-info312 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-cliche-lines = v-character
   .
   assign
      v-code       =  'print-good-code':U
   .
define variable vss-include-info313 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-print-good-code = logical(v-integer)
   .
   assign
      v-code       = 'rmethod-type':U
   .
define variable vss-include-info314 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-rmethod-type = v-character
   .
   assign
      v-code       =  'rmethod-coeff':U
   .
define variable vss-include-info315 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-rmethod-coeff = v-decimal
   .
   assign
      v-upper-code = 'IBS-TH_main':U
   .
   assign
      v-code       = 'cash-shift':U
   .
define variable vss-include-info316 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-cash-shift = logical(v-integer)
   .
   assign
      v-code       = 'log-level':U
   .
define variable vss-include-info317 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-log-level = v-integer
   .
define variable vss-include-info318 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-log-level in g#eventlib
  (input  v-log-level
  ,output p-ok
  ) no-error .
   assign
      v-code       = 'nalc':U
   .
define variable vss-include-info319 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-nalc = v-integer
   .
   assign
      v-code       = 'salesman-mandatory':U
   .
define variable vss-include-info320 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-salesman-mandatory = logical(v-integer)
   .
   assign
      v-code       = 'manual-discnt':U
   .
define variable vss-include-info321 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-manual-discnt = logical(v-integer)
   .
   assign
      v-code       = 'log-level':U
   .
define variable vss-include-info322 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-log-level = v-integer
   .
   assign
      v-code       = 'clear-cash-counter':U
   .
define variable vss-include-info323 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-clear-cash-counter = LOGICAL(v-integer)
   .
   assign
      v-code       = 'qnty-change':U
   .
define variable vss-include-info324 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-qnty-change = LOGICAL(v-integer)
   .
   assign
      v-upper-code = 'IBS-TH_interface':U
   .
   assign
      v-code       = 'screen-type':U
   .
define variable vss-include-info325 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-screen-type = v-character
   .
   assign
      v-code       = 'screen-layout-id':U
   .
define variable vss-include-info326 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_get-cda in g#libthpos
  (input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,input  v-upper-code
  ,input  v-code
  ,output v-character
  ,output v-date
  ,output v-decimal
  ,output v-integer
  ,output v-logical
  ,output v-data-type
  ) no-error .
   assign
      v-screen-layout-id = v-character
   .
   if not v-emul-mode
   then do:
      assign
         p-ok = TRUE
      no-error .
define variable vss-include-info327 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-set in g#fr-lib
    ( input  v-pay-names
    , input  v-clear-cash-counter
    , input  v-cashier-name
    , input  v-cash-drawer-plug
    , input  v-cash-drawer-plug-imp
    , input  v-cutter
    , input  v-cash-drawer-level
    , input  v-advert-text
    , input  v-cliche-lines
    , input  v-print-good-code
    , input  v-max-netto
    , input  v-cash-shift
    , input  v-cash-drawer-open
    , input  v-cash-drawer-limit
    , input  v-clear-cash-counter
    , output p-message
    , output p-ok
    ) no-error .
end.
      if error-status:error
      OR not p-ok
      then do:
          if   p-message = "":U
          then p-message = "Нет связи с фискальным регистратором".
          return.
      end.
   end.
   assign
      p-ok = TRUE
   no-error .
   run prep-lay_get-layout in this-procedure ( input 'th-pos-screen':U
                           , input v-screen-type
                           , input v-screen-layout-id ) no-error.
   if error-status:error then do:
      message
                         substitute("Нельзя работать с POS IBS TH:&1&2&1&3"
                               , chr(10)
                               , error-status:get-message(1)
                               , return-value )
      view-as alert-box error.
      return error .
   end.
   if  v-keyboard-layout-id <> "":U
   AND v-keyboard-layout-id <> ?
   then do:
      run prep-lay_get-layout in this-procedure ( input 'th-pos-keyboard':U
                              , input v-keyboard-type
                              , input v-keyboard-layout-id ) no-error.
      if error-status:error then do:
         message
                           substitute("Нельзя работать с POS IBS TH:&1&2&1&3"
                                 , chr(10)
                                 , error-status:get-message(1)
                                 , return-value )
         view-as alert-box error.
         return error .
      end.
   end.
end.
end procedure.
procedure set-context-serial :
define input   parameter p-serial      as char          no-undo.
define input   parameter p-model       as integer          no-undo.
define output  parameter p-message     as character      no-undo .
define output  parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   assign
      v-context-serial = p-serial
   .
   case p-model:
      WHEN 4
      then do:
         assign
            v-fr-width        = 36
            v-fr-width-bold   = 18
         .
      end.
      WHEN 9
      then do:
         assign
            v-fr-width = 48
            v-fr-width-bold   = 24
         .
      end.
      WHEN 8
      then do:
         assign
            v-fr-width = 40
            v-fr-width-bold   = 28
         .
      end.
      OTHERWISE DO:
         assign
            v-fr-width = 20
            v-fr-width-bold   = 26
         .
      end.
   end case.
end.
end procedure.
procedure get-disc-type :
define output   parameter p-disc-type  as character          no-undo.
define output  parameter p-message     as character      no-undo .
define output  parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   assign
      p-disc-type = v-disc-type
   .
end.
end procedure.
procedure hour24 :
define output  parameter p-message     as character      no-undo .
define output  parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   if v-fr-shift-open = 24
   then do:
      assign
         p-ok = TRUE
      .
   end.
   else do:
      assign
         p-ok = FALSE
      .
   end.
end.
end procedure.
procedure sht-cls :
define output  parameter p-message     as character      no-undo .
define output  parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   if v-fr-shift-open = 0
   then do:
      assign
         p-ok = TRUE
      .
   end.
   else do:
      assign
         p-ok = FALSE
      .
   end.
end.
end procedure.
procedure get-display-adv :
define output  parameter p-disp-message-1  as character          no-undo.
define output  parameter p-disp-message-2  as character          no-undo.
define output  parameter p-message     as character      no-undo .
define output  parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   if num-entries(v-customer-display-adv, chr(4)) >= 2
   then do:
      assign
         p-disp-message-1 = entry(1, v-customer-display-adv, chr(4))
         p-disp-message-2 = entry(2, v-customer-display-adv, chr(4))
      .
   end.
   else do:
      assign
         p-disp-message-1 = v-customer-display-adv
         p-ok   = TRUE
      .
   end.
end.
end procedure.
procedure 2001 :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output  parameter p-message     as character      no-undo .
define output  parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
define variable vss-include-info328 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  81
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
   run adm/chk-pass.w   ( input parparentproc
                        , input v-cntxt-userid
                        , input v-cntxt-db-num
                        , input "actn_ibsthpos-bank-day"
                        , input FALSE
                        , output p-message
                        , output p-ok
                        ) .
   if not p-ok
   then do:
define variable vss-include-info329 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  83
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
      return.
   end.
   if not v-emul-mode
   then do:
define variable vss-include-info330 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#sb-lib ) <> TRUE then do:       run gbl/sb-lib.p persistent no-error.       if error-status :error or valid-handle( g#sb-lib ) <> TRUE then do:         message "Error starting sb-lib.p" skip( 0 )           g#sb-lib                        skip( 0 )           g#sb-lib    :type               skip( 0 )           g#sb-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run sb-day in g#sb-lib
    ( output p-message
    , output p-ok
    ) no-error .
end.
   end.
   if error-status:error
   then do:
      assign
         p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
define variable vss-include-info331 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  p-message
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  83
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
   end.
define variable vss-include-info332 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  p-cash-num
    , input  substitute( '&1.&2' , p-cd-mode, p-cd-submode)
    , input  '':U
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  '':U
    , input  '':U
    , input  TODAY
    , input  82
    , input  TIME
    , input  'S':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
end.
end procedure.
procedure print-slip :
define input   parameter p-slip     as character no-undo .
define output  parameter p-message  as character no-undo .
define output  parameter p-ok       as logical   no-undo .
define variable v-iii    as integer      no-undo .
define variable v-ccc    as character    no-undo .
do
on error undo, return error
:
   DO v-iii = 1 TO NUM-ENTRIES(p-slip, chr(10))
   :
      v-ccc = ENTRY(v-iii, p-slip, chr(10)).
      if INDEX(v-ccc, chr(01)) > 0
      then do:
         if v-cutter
         then do:
define variable vss-include-info333 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-cut in g#fr-lib
    ( INPUT       FALSE
    , output      p-message
    , output      p-ok
    ) no-error .
end.
         end.
      end.
      v-ccc = REPLACE(v-ccc,chr(01) , "":U).
define variable vss-include-info334 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-print-str in g#fr-lib
    ( input       v-ccc
    , output      p-message
    , output      p-ok
    ) no-error .
end.
   end.
   assign
      p-ok     = TRUE
   .
end.
end procedure.
procedure accum-chk-pay :
define input   parameter p-pay-code  as integer   no-undo .
define input   parameter p-curr-code as integer   no-undo .
define input   parameter p-card-num  as character no-undo .
define output  parameter p-found-pay as logical   no-undo .
define output  parameter p-summ-pay  as decimal   no-undo .
define buffer buf_chk-pay        for ub.chk-pay .
define buffer buf_tt-open-check  for tt-open-check .
define buffer buf_tt-line        for tt-line .
do
on error undo, return error
:
   if p-pay-code = 0
   then do:
      for each  buf_tt-line
         where buf_tt-line.ord-chk-num <> "":U
         no-lock
         BREAK BY buf_tt-line.ord-chk-num
         :
         if first-OF(buf_tt-line.ord-chk-num)
         then do:
            if CAN-find (first buf_tt-open-check
                         where buf_tt-open-check.doc-code = buf_tt-line.ord-chk-num
                           AND buf_tt-open-check.chk-type = INTEGER('1':U))
            then do:
               assign
                     p-found-pay = TRUE
               .
               for each  buf_chk-pay
                     where buf_chk-pay.doc-code  = buf_tt-line.ord-chk-num
                     NO-LOCK
                     :
                     assign
                        p-summ-pay = p-summ-pay + buf_chk-pay.tot-sum
                     .
               end.
            end.
         end.
         else do:
            NEXT.
         end.
      end.
   end.
   else do:
      for each  buf_tt-line
         where buf_tt-line.ord-chk-num <> "":U
         no-lock
         BREAK BY buf_tt-line.ord-chk-num
         :
         if first-OF(buf_tt-line.ord-chk-num)
         then do:
            if CAN-find (first buf_tt-open-check
                         where buf_tt-open-check.doc-code = buf_tt-line.ord-chk-num
                           AND buf_tt-open-check.chk-type = INTEGER('1':U))
            then do:
               assign
                     p-found-pay = TRUE
               .
               for each  buf_chk-pay
                     where buf_chk-pay.doc-code    = buf_tt-line.ord-chk-num
                     AND buf_chk-pay.pay-code    = p-pay-code
                     AND buf_chk-pay.curr-code   = p-curr-code
                     AND buf_chk-pay.pay-card    = p-card-num
                     NO-LOCK
                     :
                     assign
                        p-summ-pay = p-summ-pay + buf_chk-pay.tot-rubl
                     .
               end.
            end.
         end.
         else do:
            NEXT.
         end.
      end.
   end.
   assign
      p-summ-pay = ABS( p-summ-pay )
   .
end.
end procedure.
procedure accum-curr-chk-pay :
define input   parameter p-pay-code  as integer   no-undo .
define input   parameter p-curr-code as integer   no-undo .
define input   parameter p-card-num  as character no-undo .
define output  parameter p-summ-pay  as decimal   no-undo .
define buffer buf_tt-line     for tt-line .
do
on error undo, return error
:
   if p-pay-code = 0
   then do:
      for each  buf_tt-line
         where buf_tt-line.type = 1
         :
         assign
            p-summ-pay = p-summ-pay + buf_tt-line.summ-netto-rub
         .
      end.
   end.
   else do:
      for each buf_tt-line
         where buf_tt-line.type        = 1
           AND buf_tt-line.line-code   = p-pay-code
           AND buf_tt-line.curr-code   = p-curr-code
           AND buf_tt-line.pay-card    = p-card-num
         :
         assign
            p-summ-pay = p-summ-pay + buf_tt-line.summ-netto-rub
         .
      end.
   end.
end.
end procedure.
PROCEDURE annul-lost-chk :
define output  parameter p-message   as character no-undo .
define output  parameter p-ok        as logical   no-undo .
define buffer buf_chk-doc     for ub.chk-doc .
do
on error undo, return error
:
  find last  buf_chk-doc
      where buf_chk-doc.obj-type = v-cntxt-obj-type
        AND buf_chk-doc.obj-code = v-cntxt-obj-code
        AND buf_chk-doc.pay-desk = p-cash-num
        AND buf_chk-doc.office   = ?
      NO-LOCK
      no-error
      .
  if available buf_chk-doc
  then do:
define variable vss-include-info335 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_annu-lost-check in g#libthpos
  (input  buf_chk-doc.doc-code
  ) no-error .
    if error-status:error
    then do:
      assign
      p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
      p-ok = FALSE
      .
    end.
    else do:
      message
      substitute("Найден и аннулирован незавершенный чек &1", buf_chk-doc.doc-code )
      view-as alert-box warning.
    end.
  end.
  assign
  p-ok = TRUE
  .
end.
end PROCEDURE.
PROCEDURE non-fisk-doc :
define input-output  parameter p-cd-mode     as character no-undo .
define input-output  parameter p-cd-submode  as character no-undo .
define input parameter p-title as character        no-undo.
define output  parameter p-message   as character no-undo .
define output  parameter p-ok        as logical   no-undo .
define buffer buf_tt-line     for tt-line .
define variable v-chk-fr-num    as character    no-undo.
define variable v-price-rub    as decimal      no-undo.
define variable v-disc-rub-total    as decimal      no-undo.
define variable v-print-line    as character    no-undo.
define variable v-rest-summ      as decimal      no-undo .
do
on error undo, return error
:
   if v-emul-mode then return.
   find tt-head-check .
   if  v-close-good-chk
   AND v-with-context
   AND p-title begins ('ТОВАРНЫЙ ЧЕК' + chr(32))
   then do:
      assign
         v-rest-summ = ?
      .
      run rest-back in this-procedure ( input-output v-rest-summ, output p-message, output p-ok) .
      if error-status:error
      OR not p-ok
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         return .
      end.
   end.
   if  v-close-good-chk
   AND v-with-context
   then do:
define variable vss-include-info336 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_getcheck in g#libthpos
  (input  tt-head-check.doc-code
  ,input  no
  ) no-error .
      if error-status:error then do:
         if v-rest-summ > 0
         AND v-close-good-chk
         then do:
            run del-rest (output p-message, output p-ok) .
         end.
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
define variable vss-include-info337 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  0
    , input  '':U
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  67
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
   end.
   define variable v-num    as character    no-undo.
   define variable v-name    as character    no-undo.
   if v-with-context
   then do:
      assign
         v-num  = '0000'
         v-name = p-title
      .
   end.
   else do:
      assign
         v-num  = '0000'
         v-name = p-title
      .
   end.
define variable vss-include-info338 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-DocTitle in g#fr-lib
    ( input       v-num
    , input       v-name
    , output      p-message
    , output      p-ok
    ) no-error .
end.
   if error-status:error then do:
      if v-rest-summ > 0
      AND v-close-good-chk
      then do:
         run del-rest (output p-message, output p-ok) .
      end.
      assign
         p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
define variable vss-include-info339 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  0
    , input  '':U
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  67
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
      return.
   end.
   for each  buf_tt-line
       where buf_tt-line.type = 0
      :
      run str-fix-width ( input (if v-print-good-code then STRING(buf_tt-line.src) + " " else "":U) + buf_tt-line.line-name
                        , input "":U
                        , input v-fr-width
                        , YES
                        , output v-print-line
                        , output p-message
                        , output p-ok
                        ) .
define variable vss-include-info340 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-print-str in g#fr-lib
    ( input       v-print-line
    , output      p-message
    , output      p-ok
    ) no-error .
end.
      if error-status:error then do:
         if v-rest-summ > 0
         AND v-close-good-chk
         then do:
            run del-rest (output p-message, output p-ok) .
         end.
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
define variable vss-include-info341 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  0
    , input  '':U
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  67
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
      if buf_tt-line.qnty > 1
      then do:
         run str-fix-width ( input ""
                           , input (TRIM(STRING(buf_tt-line.qnty)) + " X " + TRIM(STRING(buf_tt-line.price-rub, ">>>,>>9.99")))
                           , input v-fr-width
                           , YES
                           , output v-print-line
                           , output p-message
                           , output p-ok
                           ) .
define variable vss-include-info342 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-print-str in g#fr-lib
    ( input       v-print-line
    , output      p-message
    , output      p-ok
    ) no-error .
end.
         if error-status:error then do:
            if v-rest-summ > 0
            AND v-close-good-chk
            then do:
               run del-rest (output p-message, output p-ok) .
            end.
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info343 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  0
    , input  '':U
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  67
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
      end.
      run str-fix-width ( input ""
                        , input ("=" + TRIM(STRING((buf_tt-line.price-rub * buf_tt-line.qnty), "->>>,>>9.99")))
                        , input v-fr-width
                        , YES
                        , output v-print-line
                        , output p-message
                        , output p-ok
                        ) .
define variable vss-include-info344 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-print-str in g#fr-lib
    ( input       v-print-line
    , output      p-message
    , output      p-ok
    ) no-error .
end.
      if error-status:error then do:
         if v-rest-summ > 0
         AND v-close-good-chk
         then do:
            run del-rest (output p-message, output p-ok) .
         end.
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
define variable vss-include-info345 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  0
    , input  '':U
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  67
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
         return.
      end.
         assign
            v-disc-rub-total = v-disc-rub-total + buf_tt-line.summ-discont-rub
         .
         run str-fix-width ( input "СКИДКА"
                           , input ("=" + TRIM(STRING(buf_tt-line.summ-discont-rub, ">>>,>>9.99")))
                           , input v-fr-width
                           , YES
                           , output v-print-line
                           , output p-message
                           , output p-ok
                           ) .
         if buf_tt-line.summ-discont-rub > 0
         then do:
define variable vss-include-info346 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-print-str in g#fr-lib
    ( input       v-print-line
    , output      p-message
    , output      p-ok
    ) no-error .
end.
            if error-status:error then do:
               if v-rest-summ > 0
               AND v-close-good-chk
               then do:
                  run del-rest (output p-message, output p-ok) .
               end.
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
define variable vss-include-info347 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  0
    , input  '':U
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  67
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
               return.
            end.
         end.
   end.
   define variable v-summ-1  as decimal      no-undo.
   define variable v-summ-2  as decimal      no-undo.
   define variable v-summ-3  as decimal      no-undo.
   define variable v-summ-4  as decimal      no-undo.
   assign
      v-summ-1 = 0
      v-summ-2 = 0
      v-summ-3 = 0
      v-summ-4 = 0
   .
   for each  buf_tt-line
      where buf_tt-line.type = 1
   :
      case buf_tt-line.fr-pay-code :
         WHEN 1 then do:
            assign
               v-summ-1 = v-summ-1 + if p-cd-mode = "2" then - buf_tt-line.summ-netto-rub else buf_tt-line.summ-netto-rub
            .
         end.
         WHEN 2 then do:
            assign
               v-summ-2 = v-summ-2 + if p-cd-mode = "2" then - buf_tt-line.summ-netto-rub else buf_tt-line.summ-netto-rub
            .
         end.
         WHEN 3 then do:
            assign
               v-summ-3 = v-summ-3 + if p-cd-mode = "2" then - buf_tt-line.summ-netto-rub else buf_tt-line.summ-netto-rub
            .
         end.
         WHEN 4 then do:
            assign
               v-summ-4 = v-summ-4 + if p-cd-mode = "2" then - buf_tt-line.summ-netto-rub else buf_tt-line.summ-netto-rub
            .
         end.
         OTHERWISE DO:
         end.
      end case.
   end.
   if not v-with-context
   then do:
      assign
         v-summ-pay-rub = v-summ-1 + v-summ-2 + v-summ-3 + v-summ-4
      .
   end.
   define variable v-card    as character    no-undo.
   case tt-head-check.chk-type:
      WHEN integer('1':U)
      then do:
         assign
            v-summ-discont-rub   = (v-summ-discont-rub - v-disc-rub-total)
         .
         if v-summ-discont-rub <> 0
         then do:
            run str-fix-width ( input "СКИДКА"
                              , input ("=" + TRIM(STRING(v-summ-discont-rub, ">>>,>>9.99")))
                              , input v-fr-width
                              , YES
                              , output v-print-line
                              , output p-message
                              , output p-ok
                              ) .
define variable vss-include-info348 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-print-str in g#fr-lib
    ( input       v-print-line
    , output      p-message
    , output      p-ok
    ) no-error .
end.
         end.
         if tt-head-check.d-card <> "":U
         then do:
            assign
               v-print-line = substitute("Карта &1", tt-head-check.d-card)
            .
define variable vss-include-info349 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-print-str in g#fr-lib
    ( input       v-print-line
    , output      p-message
    , output      p-ok
    ) no-error .
end.
            if error-status:error then do:
               if v-rest-summ > 0
               AND v-close-good-chk
               then do:
                  run del-rest (output p-message, output p-ok) .
               end.
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
define variable vss-include-info350 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  0
    , input  '':U
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  67
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
               return.
            end.
         end.
         assign
            v-print-line = "-------------------------------------"
         .
define variable vss-include-info351 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-print-str in g#fr-lib
    ( input       v-print-line
    , output      p-message
    , output      p-ok
    ) no-error .
end.
         run str-fix-width ( input "ИТОГ"
                           , input ("=" + TRIM(STRING(v-summ-netto-rub, ">>>,>>9.99")))
                           , input v-fr-width-bold
                           , YES
                           , output v-print-line
                           , output p-message
                           , output p-ok
                           ) .
define variable vss-include-info352 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-wide-print-str in g#fr-lib
    ( input       v-print-line
    , output      p-message
    , output      p-ok
    ) no-error .
end.
         if error-status:error then do:
            if v-rest-summ > 0
            AND v-close-good-chk
            then do:
               run del-rest (output p-message, output p-ok) .
            end.
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info353 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  0
    , input  '':U
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  67
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
         if v-summ-1 > 0
         then do:
            run str-fix-width ( input " НАЛИЧНЫМИ"
                              , input ("=" + TRIM(STRING(v-summ-1, ">>>,>>9.99")))
                              , input v-fr-width
                              , YES
                              , output v-print-line
                              , output p-message
                              , output p-ok
                              ) .
define variable vss-include-info354 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-print-str in g#fr-lib
    ( input       v-print-line
    , output      p-message
    , output      p-ok
    ) no-error .
end.
            if error-status:error then do:
               if v-rest-summ > 0
               AND v-close-good-chk
               then do:
                  run del-rest (output p-message, output p-ok) .
               end.
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
define variable vss-include-info355 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  0
    , input  '':U
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  67
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
               return.
            end.
         end.
         if v-summ-2 > 0
         then do:
            run str-fix-width ( input ENTRY(1, v-pay-names, chr(4))
                              , input ("=" + TRIM(STRING(v-summ-2, ">>>,>>9.99")))
                              , input v-fr-width
                              , YES
                              , output v-print-line
                              , output p-message
                              , output p-ok
                              ) .
define variable vss-include-info356 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-print-str in g#fr-lib
    ( input       v-print-line
    , output      p-message
    , output      p-ok
    ) no-error .
end.
            if error-status:error then do:
               if v-rest-summ > 0
               AND v-close-good-chk
               then do:
                  run del-rest (output p-message, output p-ok) .
               end.
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
define variable vss-include-info357 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  0
    , input  '':U
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  67
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
               return.
            end.
         end.
         if v-summ-3 > 0
         then do:
            run str-fix-width ( input ENTRY(2, v-pay-names, chr(4))
                              , input ("=" + TRIM(STRING(v-summ-3, ">>>,>>9.99")))
                              , input v-fr-width
                              , YES
                              , output v-print-line
                              , output p-message
                              , output p-ok
                              ) .
define variable vss-include-info358 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-print-str in g#fr-lib
    ( input       v-print-line
    , output      p-message
    , output      p-ok
    ) no-error .
end.
            if error-status:error then do:
               if v-rest-summ > 0
               AND v-close-good-chk
               then do:
                  run del-rest (output p-message, output p-ok) .
               end.
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
define variable vss-include-info359 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  0
    , input  '':U
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  67
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
               return.
            end.
         end.
         if v-summ-4 > 0
         then do:
            run str-fix-width ( input ENTRY(3, v-pay-names, chr(4))
                              , input ("=" + TRIM(STRING(v-summ-4, ">>>,>>9.99")))
                              , input v-fr-width
                              , YES
                              , output v-print-line
                              , output p-message
                              , output p-ok
                              ) .
define variable vss-include-info360 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-print-str in g#fr-lib
    ( input       v-print-line
    , output      p-message
    , output      p-ok
    ) no-error .
end.
            if error-status:error then do:
               if v-rest-summ > 0
               AND v-close-good-chk
               then do:
                  run del-rest (output p-message, output p-ok) .
               end.
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
define variable vss-include-info361 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  0
    , input  '':U
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  67
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
               return.
            end.
         end.
         if ( v-summ-pay-rub - v-summ-netto-rub ) > 0
         then do:
            run str-fix-width ( input "СДАЧА"
                              , input ("=" + TRIM(STRING(( v-summ-pay-rub - v-summ-netto-rub ), ">>>,>>9.99")))
                              , input v-fr-width
                              , YES
                              , output v-print-line
                              , output p-message
                              , output p-ok
                              ) .
define variable vss-include-info362 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-print-str in g#fr-lib
    ( input       v-print-line
    , output      p-message
    , output      p-ok
    ) no-error .
end.
            if error-status:error then do:
               if v-rest-summ > 0
               AND v-close-good-chk
               then do:
                  run del-rest (output p-message, output p-ok) .
               end.
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
define variable vss-include-info363 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  0
    , input  '':U
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  67
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
               return.
            end.
         end.
define variable vss-include-info364 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-FeedDocument in g#fr-lib
    ( input       6
    , output      p-message
    , output      p-ok
    ) no-error .
end.
         if error-status:error then do:
            if v-rest-summ > 0
            AND v-close-good-chk
            then do:
               run del-rest (output p-message, output p-ok) .
            end.
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info365 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  0
    , input  '':U
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  67
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
         if v-cutter
         then do:
define variable vss-include-info366 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-cut in g#fr-lib
    ( INPUT       FALSE
    , output      p-message
    , output      p-ok
    ) no-error .
end.
         end.
         if error-status:error then do:
            if v-rest-summ > 0
            AND v-close-good-chk
            then do:
               run del-rest (output p-message, output p-ok) .
            end.
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
define variable vss-include-info367 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  0
    , input  '':U
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  67
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
            return.
         end.
      end.
      OTHERWISE DO:
      end.
   end case.
define variable vss-include-info368 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  0
    , input  '':U
    , input  tt-head-check.chk-type
    , input  '':U
    , input  '*':U
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  66
    , input  TIME
    , input  'U':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
   if  v-close-good-chk
   AND v-with-context
   AND p-title begins ('ТОВАРНЫЙ ЧЕК' + chr(32))
   then do:
      run 1988 in this-procedure ( INPUt-OUTPUT p-cd-mode
                                 , INPUt-output p-cd-submode
                                 , output p-message
                                 , output p-ok
                                 ) .
      define buffer buf_tt-open-check     for tt-open-check .
      if CAN-find(first buf_tt-open-check)
      then do:
         for each buf_tt-open-check:
define variable vss-include-info369 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_close-postpone in g#libthpos
  (input  tt-head-check.doc-code
  ,input  buf_tt-open-check.doc-code
  ,input  1
  ) no-error .
            if error-status:error
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
define variable vss-include-info370 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#eventlib ) <> TRUE then do:       run gbl/eventlib.p persistent no-error.       if error-status :error or valid-handle( g#eventlib ) <> TRUE then do:         message "Error starting eventlib.p" skip( 0 )           g#eventlib                        skip( 0 )           g#eventlib    :type               skip( 0 )           g#eventlib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run eventlib-event-log in g#eventlib
    ( input  0
    , input  v-cntxt-db-num
    , input  '':U
    , input  0
    , input  '':U
    , input  tt-head-check.chk-type
    , input  '':U
    , input  p-message
    , input  '':U
    , input  tt-head-check.doc-code
    , input  '':U
    , input  TODAY
    , input  67
    , input  TIME
    , input  'E':U
    , input  0
    , input  v-cntxt-obj-type
    , input  v-cntxt-obj-code
    , input  '':U
    , input  'IBS-TH':U
    , input  0
    , input  ?
    , input  '':U
    , input  0
    , input  '':U
    , input  0
    , input  v-cntxt-userid
    ) no-error .
end.
               return.
            end.
         end.
      end.
define variable vss-include-info371 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_close-check in g#libthpos
  (input  tt-head-check.doc-code
  ,input  v-chk-fr-num
  ) no-error .
      if error-status:error then do:
         if v-rest-summ > 0
         AND v-close-good-chk
         then do:
            run del-rest (output p-message, output p-ok) .
         end.
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         return.
      end.
      run clear-tt-chk in this-procedure.
      assign
         p-cd-mode    = "0"
         p-cd-submode = "0"
         p-message    = "Чек закрыт"
      .
   end.
   assign
      p-ok         = true
   .
end.
end PROCEDURE.
PROCEDURE str-fix-width :
define input  parameter p-left-str  as character no-undo .
define input  parameter p-right-str as character no-undo .
define input  parameter p-width     as integer   no-undo .
define input  parameter p-cut       as logical   no-undo.
define output parameter p-fix-str   as character no-undo .
define output parameter p-message   as character no-undo .
define output parameter p-ok        as logical   no-undo .
define variable v-left-width    as integer       no-undo.
define variable v-right-width    as integer      no-undo.
do
on error undo, return error
:
   assign
      v-left-width  = LENGTH( p-left-str )
      v-right-width = LENGTH( p-right-str )
   .
   if v-right-width > p-width
   then do:
      return error "правая часть больше ширины строки".
   end.
   if (v-right-width + v-left-width) > p-width + 1
   then do:
      if not p-cut
      then do:
         return error "суммарная длина больше ширины строки".
      end.
      assign
         p-left-str = SUBSTRING(p-left-str, 1, (p-width - v-right-width - 1) ) + " "
      .
   end.
   else do:
      assign
         p-left-str = p-left-str + FILL( " ", (p-width - v-right-width - v-left-width) )
      .
   end.
   assign
      p-fix-str = p-left-str + p-right-str
      p-ok      = true
   .
end.
end PROCEDURE.
PROCEDURE print-head-chk :
define output parameter p-message   as character no-undo .
define output parameter p-ok        as logical   no-undo .
define variable  v-count     as integer   no-undo .
define variable v-line    as character      no-undo.
do
on error undo, return error
:
   DO v-count = 1 TO NUM-ENTRIES(v-cliche-lines, chr(4)):
      assign
         v-line = ENTRY(v-count, v-cliche-lines, chr(4))
      .
      if v-line = "":U
      then do:
         NEXT.
      end.
define variable vss-include-info372 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-print-str in g#fr-lib
    ( input       v-line
    , output      p-message
    , output      p-ok
    ) no-error .
end.
   end.
   assign
      p-ok      = true
   .
end.
end PROCEDURE.
PROCEDURE 1991 :
define input-output  parameter p-cd-mode     as character no-undo .
define input-output  parameter p-cd-submode  as character no-undo .
define output  parameter p-message   as character no-undo .
define output  parameter p-ok        as logical   no-undo .
define variable v-rid-list    as character    no-undo.
define variable v-md    as character    no-undo.
define variable v-msg    as character    no-undo.
define buffer buf_wi-mode     for ub.wi-mode .
define buffer buf_rule-by-set for ub.rule-by-set .
do
on error undo, return error
:
   if p-cd-mode = "1"
   OR p-cd-mode = "2"
   then do:
      assign
         v-md = substitute("&1.&2", p-cd-mode, p-cd-submode)
      .
   end.
   else do:
      assign
         v-md = p-cd-mode
      .
   end.
   find first  buf_wi-mode
       where buf_wi-mode.mode-type  = 'cd-IBS-TH':U
         AND buf_wi-mode.mode-id    = v-md
       NO-LOCK
       no-error
       .
   if not available buf_wi-mode
   then do:
      assign
         p-message    = substitute( "Недоступен список функций для режима &1", v-md )
         p-ok         = true
      .
      return .
   end.
   run rul/rule-by-set-s.w ( input parparentproc
                           , input "b-sel":U
                           , input "wi-mode"
                           , input buf_wi-mode.codex_id
                           , input buf_wi-mode.ruleset_id
                           , input 0
                           , input-output v-rid-list
                           ) .
   if v-rid-list = "":U
   OR v-rid-list = ?
   then do:
      assign
         p-message = "Отказ от выбора функции"
         p-ok      = TRUE
      .
      return.
   end.
   find first buf_rule-by-set
      where RECID(buf_rule-by-set) = INTEGER(ENTRY(1, v-rid-list))
      no-lock
      no-error
      .
   if not available buf_rule-by-set
   then do:
      assign
         p-message = "Не найдена выбранная функция"
         p-ok      = TRUE
      .
      return.
   end.
   run value( substitute("&1", string(buf_rule-by-set.rule_id, "9999"))) in this-procedure
            ( input-output p-cd-mode
            , input-output p-cd-submode
            , output p-message
            , output p-ok
            ) no-error.
   if error-status:error
   then do:
      assign
         p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
      return.
   end.
   if not p-ok
   then do:
      return.
   end.
   if p-cd-mode <> "4"
   then do:
      assign
         v-msg            = p-message
         v-cd-mode-pre    = p-cd-mode
         v-cd-submode-pre = p-cd-submode
      .
   end.
   run cd-context ( INPUt-OUTPUT p-cd-mode
                  , INPUt-output p-cd-submode
                  , output       p-message
                  , output       p-ok
                  ) .
   if not p-ok
   then do:
      message
         SKIP return-VALUE
         SKIP trim(error-status :get-message(1))
         SKIP trim(error-status :get-message(2))
         SKIP trim(error-status :get-message(3))
         sKIP p-message
      view-as alert-box information.
      return.
   end.
   if p-cd-mode <> "4"
   then do:
      assign
         p-message        = v-msg
         v-cd-mode-pre    = p-cd-mode
         v-cd-submode-pre = p-cd-submode
      .
   end.
   return.
end.
end PROCEDURE.
PROCEDURE 2000 :
define input-output  parameter p-cd-mode     as character no-undo .
define input-output  parameter p-cd-submode  as character no-undo .
define output  parameter p-message   as character no-undo .
define output  parameter p-ok        as logical   no-undo .
define variable v-rid-list    as character    no-undo.
define variable v-md    as character    no-undo.
define variable v-msg    as character    no-undo.
define variable  v-count     as integer   no-undo .
define variable v-cd-mode-local    as character    no-undo.
define variable v-fr-num    as integer    no-undo.
define buffer buf_chk-doc     for ub.chk-doc .
define buffer buf_chk-gds     for ub.chk-gds .
define buffer buf_tt-line     for tt-line .
define buffer buf_goods       for ub.goods  .
define buffer buf_bar-code    for ub.bar-code .
define buffer buf_chk-pay     for ub.chk-pay .
define buffer buf_cash-pay    for ub.cash-pay .
do
on error undo, return error
:
   if p-cd-mode <> "0"
   then do:
      return.
   end.
   run str/chk-docs.w   ( input parparentproc
                        , input "b-sel"
                        , input 'IBS-TH':U
                        , input ?
                        , input v-cntxt-obj-type
                        , input v-cntxt-obj-code
                        , input '':U
                        , input '':U
                        , input p-cash-num
                        , input ?
                        , input ?
                        , input integer('1':U)
                        , output v-rid-list) no-error.
   if v-rid-list = "":U
   then do:
      assign
         p-message = "Отказ от выбора чека"
         p-ok      = TRUE
      .
      return.
   end.
   assign
      v-with-context = FALSE
      v-count = 1
   .
   _proc-body:
   DO
   on error undo, return
   :
      assign
         v-cd-mode-local = "1"
      .
      find first buf_chk-doc
         where RECID(buf_chk-doc) = INTEGER(ENTRY(v-count, v-rid-list))
         NO-lock
         no-error
         .
      if  not available buf_chk-doc
      then do:
         UNDO _proc-body, LEAVE _proc-body .
      end.
      if  buf_chk-doc.chk-type <> integer('1':U)
      AND buf_chk-doc.chk-type <> integer('6':U)
      then do:
         UNDO _proc-body, LEAVE _proc-body .
      end.
      CREATE tt-head-check.
      assign
         tt-head-check.doc-code    = buf_chk-doc.doc-code
         v-fr-num                  = buf_chk-doc.chk-num
         tt-head-check.chk-type    = buf_chk-doc.chk-type
         tt-head-check.cash-rate   = if v-r-b = 'base':U then v-cash-rate    else 1
         tt-head-check.cash-scales = if v-r-b = 'base':U then v-cash-scales  else 1
      .
      if  buf_chk-doc.src-d-card <> ?
      AND buf_chk-doc.src-d-card <> ''
      then do:
         if v-with-context
         then do:
            assign
               v-src = buf_chk-doc.src-d-card
            .
            run input-card in this-procedure ( INPUt-OUTPUT p-cd-mode
                                             , INPUt-output p-cd-submode
                                             , output p-message
                                             , output p-ok
                                             ) .
            if not p-ok then do:
               UNDO _proc-body, LEAVE _proc-body .
            end.
         end.
         else do:
            assign
               tt-head-check.d-card = buf_chk-doc.src-d-card
            .
         end.
      end.
      assign
         v-pass-gds = 0
      .
      for each buf_chk-gds
         where buf_chk-gds.doc-code = buf_chk-doc.doc-code
         no-lock
         ,
         first buf_bar-code
         where buf_bar-code.b-code = buf_chk-gds.b-code
         No-LOCK
         ,
         first buf_goods
         where buf_goods.gds-code = buf_bar-code.gds-code
         No-LOCK
         by buf_chk-gds.line-num
      :
         find first buf_tt-line
              where buf_tt-line.ord-chk-num  = buf_chk-gds.doc-code
                AND buf_tt-line.ord-line-num = buf_chk-gds.line-num
              no-lock no-error.
         if available buf_tt-line then NEXT.
         case buf_chk-doc.chk-type:
            when integer('6':U) then do:
            assign
            v-write-off-code = 0
            .
            end.
         end case.
         assign
            v-src-price          = buf_chk-gds.src-price
            v-src-price-rub      = buf_chk-gds.src-price * tt-head-check.cash-scales
            v-src-discnt         = buf_chk-gds.src-discnt
            v-src-discnt-rub     = buf_chk-gds.src-discnt * tt-head-check.cash-scales
            v-src-qnty           = buf_chk-gds.src-qnty
            v-num                = 0
            v-src                = buf_chk-gds.src-code
            v-pump               = buf_chk-gds.pump
            v-nozzle-code        = buf_chk-gds.nozzle-code
            v-pl-code            = buf_chk-gds.pl-code
            v-fbr-depart         = buf_chk-gds.depart-id
            v-chk-name           = buf_goods.chk-name
            v-gds-code           = buf_goods.gds-code
            v-src-sum-netto      = buf_chk-gds.src-price * buf_chk-gds.src-qnty
            v-src-sum-netto-rub  = buf_chk-gds.src-price * buf_chk-gds.src-qnty * tt-head-check.cash-scales
            v-summ-netto-rub     = v-summ-netto-rub + buf_chk-gds.src-price * buf_chk-gds.src-qnty * tt-head-check.cash-scales
         .
         run add-gds-line in this-procedure  ( INPUt-OUTPUT p-cd-mode
                                             , INPUt-output p-cd-submode
                                             , output p-message
                                             , output p-ok
                                             ) .
         if not p-ok then do:
            UNDO _proc-body, LEAVE _proc-body .
         end.
      end.
      define variable v-ii as integer no-undo .
      define variable v-jj as integer no-undo .
      define variable v-dop1 as character no-undo .
      define variable v-fr-code as integer no-undo .
      define variable v-cp-list as character no-undo .
      for each  buf_chk-pay
          where buf_chk-pay.doc-code = buf_chk-doc.doc-code
            AND buf_chk-pay.tot-rubl > 0
          no-lock
          :
         if buf_chk-pay.tot-rubl <= 0 then NEXT.
         assign
            v-src             = STRING(buf_chk-pay.tot-rubl)
            v-pay-type        = buf_chk-pay.pay-code
            v-curr-base-code  = buf_chk-pay.curr-code
         .
         if buf_chk-pay.pay-code = 1
         then do:
            assign
               v-frpay-code = 1
            .
         end.
         else
         _pay:
         DO v-ii = 1 TO num-entries(v-cp-lst, chr(4)):
            v-dop1 = ENTRY(v-ii, v-cp-lst, chr(4)).
            assign
               v-fr-code = INTEGER(ENTRY(1, v-dop1, "="))
               v-cp-list = ENTRY(2, v-dop1, "=")
            no-error.
            if v-fr-code >= 2
            AND v-fr-code <= 4 then do:
               DO v-jj = 1 TO num-entries(v-cp-list, ";"):
                  if  buf_chk-pay.pay-code   = integer(ENTRY(1, ENTRY(v-jj, v-cp-list, ";"), chr(58)))
                  AND buf_chk-pay.curr-code  = integer(ENTRY(2, ENTRY(v-jj, v-cp-list, ";"), chr(58)))
                  then do:
                     assign
                        v-frpay-code = v-fr-code
                     .
                     LEAVE _pay.
                  end.
               end.
            end.
         end.
         run input-pay-sale in this-procedure ( INPUt-OUTPUT v-cd-mode-local
                                              , INPUt-output p-cd-submode
                                              , output p-message
                                              , output p-ok
                                              ) .
         if not p-ok then do:
            UNDO _proc-body, LEAVE _proc-body .
         end.
      end.
      if v-with-context
      then do:
         run set-all-summ ( output p-message
                        , output p-ok
                        ) no-error .
      end.
      assign
         v-summ-discont-rub = v-summ-netto-rub - buf_chk-doc.netto * tt-head-check.cash-scales
         v-summ-netto-rub = buf_chk-doc.netto * tt-head-check.cash-scales
      .
      run non-fisk-doc in this-procedure ( INPUt-OUTPUT v-cd-mode-local
                                         , input-output p-cd-submode
                                         , input substitute('КОПИЯ ЧЕКА &1 (&2)', v-fr-num, tt-head-check.doc-code)
                                         , output p-message
                                         , output p-ok
                                         ) .
   end.
   run clear-tt-chk in this-procedure.
   return.
end.
end PROCEDURE.
PROCEDURE 2007 :
define input-output  parameter p-cd-mode     as character no-undo .
define input-output  parameter p-cd-submode  as character no-undo .
define output  parameter p-message   as character no-undo .
define output  parameter p-ok        as logical   no-undo .
define variable v-rid-list    as character    no-undo.
define variable v-md    as character    no-undo.
define variable v-msg    as character    no-undo.
define variable  v-count     as integer   no-undo .
define variable v-cd-mode-local    as character    no-undo.
define buffer buf_chk-doc     for ub.chk-doc .
define buffer buf_chk-gds     for ub.chk-gds .
define buffer buf_tt-line     for tt-line .
define buffer buf_goods       for ub.goods  .
define buffer buf_bar-code    for ub.bar-code .
define buffer buf_chk-pay     for ub.chk-pay .
define buffer buf_cash-pay    for ub.cash-pay .
do
on error undo, return error
:
   if p-cd-mode = "0"
   then do:
      run str/chk-docs.w   ( input parparentproc
                           , input "b-sel"
                           , input 'IBS-TH':U
                           , input ?
                           , input v-cntxt-obj-type
                           , input v-cntxt-obj-code
                           , input '':U
                           , input '':U
                           , input p-cash-num
                           , input ?
                           , input ?
                           , input integer('1':U)
                           , output v-rid-list
                           ) no-error.
      if v-rid-list = "":U
      then do:
         assign
            p-message = "Отказ от выбора чека"
            p-ok      = TRUE
         .
         return.
      end.
      assign
         v-with-context = FALSE
         v-count = 1
      .
      _proc-body:
      DO
      on error undo, return
      :
         assign
            v-cd-mode-local = "1"
         .
         find first buf_chk-doc
            where RECID(buf_chk-doc) = INTEGER(ENTRY(v-count, v-rid-list))
            NO-lock
            no-error
            .
         if  not available buf_chk-doc
         then do:
            UNDO _proc-body, LEAVE _proc-body .
         end.
         if  buf_chk-doc.chk-type <> integer('1':U)
         AND buf_chk-doc.chk-type <> integer('6':U)
         then do:
            UNDO _proc-body, LEAVE _proc-body .
         end.
         CREATE tt-head-check.
         assign
            tt-head-check.doc-code    = buf_chk-doc.doc-code
            tt-head-check.chk-type    = buf_chk-doc.chk-type
            tt-head-check.cash-rate   = if v-r-b = 'base':U then v-cash-rate    else 1
            tt-head-check.cash-scales = if v-r-b = 'base':U then v-cash-scales  else 1
         .
         if  buf_chk-doc.src-d-card <> ?
         AND buf_chk-doc.src-d-card <> ''
         then do:
            if v-with-context
            then do:
               assign
                  v-src = buf_chk-doc.src-d-card
               .
               run input-card in this-procedure ( INPUt-OUTPUT p-cd-mode
                                                , INPUt-output p-cd-submode
                                                , output p-message
                                                , output p-ok
                                                ) .
               if not p-ok then do:
                  UNDO _proc-body, LEAVE _proc-body .
               end.
            end.
            else do:
               assign
                  tt-head-check.d-card = buf_chk-doc.src-d-card
               .
            end.
         end.
         assign
            v-pass-gds = 0
         .
         for each buf_chk-gds
            where buf_chk-gds.doc-code = buf_chk-doc.doc-code
            no-lock
            ,
            first buf_bar-code
            where buf_bar-code.b-code = buf_chk-gds.b-code
            No-LOCK
            ,
            first buf_goods
            where buf_goods.gds-code = buf_bar-code.gds-code
            No-LOCK
            by buf_chk-gds.line-num
         :
            find first buf_tt-line
               where buf_tt-line.ord-chk-num  = buf_chk-gds.doc-code
                  AND buf_tt-line.ord-line-num = buf_chk-gds.line-num
               no-lock no-error.
            if available buf_tt-line then NEXT.
            case buf_chk-doc.chk-type:
               when integer('6':U) then do:
               assign
               v-write-off-code = 0
               .
               end.
            end case.
            assign
               v-src-price          = buf_chk-gds.src-price
               v-src-price-rub      = buf_chk-gds.src-price * tt-head-check.cash-scales
               v-src-discnt         = buf_chk-gds.src-discnt
               v-src-discnt-rub     = buf_chk-gds.src-discnt * tt-head-check.cash-scales
               v-src-qnty           = buf_chk-gds.src-qnty
               v-num                = 0
               v-src                = buf_chk-gds.src-code
               v-pump               = buf_chk-gds.pump
               v-nozzle-code        = buf_chk-gds.nozzle-code
               v-pl-code            = buf_chk-gds.pl-code
               v-fbr-depart         = buf_chk-gds.depart-id
               v-chk-name           = buf_goods.chk-name
               v-gds-code           = buf_goods.gds-code
               v-src-sum-netto      = buf_chk-gds.src-price * buf_chk-gds.src-qnty
               v-src-sum-netto-rub  = buf_chk-gds.src-price * buf_chk-gds.src-qnty * tt-head-check.cash-scales
               v-summ-netto-rub     = v-summ-netto-rub + buf_chk-gds.src-price * buf_chk-gds.src-qnty * tt-head-check.cash-scales
            .
            run add-gds-line in this-procedure  ( INPUt-OUTPUT p-cd-mode
                                                , INPUt-output p-cd-submode
                                                , output p-message
                                                , output p-ok
                                                ) .
            if not p-ok then do:
               UNDO _proc-body, LEAVE _proc-body .
            end.
         end.
         define variable v-ii as integer no-undo .
         define variable v-jj as integer no-undo .
         define variable v-dop1 as character no-undo .
         define variable v-fr-code as integer no-undo .
         define variable v-cp-list as character no-undo .
         for each  buf_chk-pay
            where buf_chk-pay.doc-code = buf_chk-doc.doc-code
            no-lock
            :
            if buf_chk-pay.tot-rubl <= 0 then NEXT.
            assign
               v-src             = STRING(buf_chk-pay.tot-rubl)
               v-pay-type        = buf_chk-pay.pay-code
               v-curr-base-code  = buf_chk-pay.curr-code
            .
            if buf_chk-pay.pay-code = 1
            then do:
               assign
                  v-frpay-code = 1
               .
            end.
            else
            _pay:
            DO v-ii = 1 TO num-entries(v-cp-lst, chr(4)):
               v-dop1 = ENTRY(v-ii, v-cp-lst, chr(4)).
               assign
                  v-fr-code = INTEGER(ENTRY(1, v-dop1, "="))
                  v-cp-list = ENTRY(2, v-dop1, "=")
               no-error.
               if v-fr-code >= 2
               AND v-fr-code <= 4 then do:
                  DO v-jj = 1 TO num-entries(v-cp-list, ";"):
                     if  buf_chk-pay.pay-code = integer(ENTRY(1, ENTRY(v-jj, v-cp-list, ";"), chr(58)))
                     AND buf_chk-pay.curr-code  = integer(ENTRY(2, ENTRY(v-jj, v-cp-list, ";"), chr(58)))
                     then do:
                        assign
                           v-frpay-code = v-fr-code
                        .
                        LEAVE _pay.
                     end.
                  end.
               end.
            end.
            run input-pay-sale in this-procedure ( INPUt-OUTPUT v-cd-mode-local
                                                , INPUt-output p-cd-submode
                                                , output p-message
                                                , output p-ok
                                                ) .
            if not p-ok then do:
               UNDO _proc-body, LEAVE _proc-body .
            end.
         end.
         if v-with-context
         then do:
            run set-all-summ ( output p-message
                           , output p-ok
                           ) no-error .
         end.
         assign
            v-summ-discont-rub = v-summ-netto-rub - buf_chk-doc.netto * tt-head-check.cash-scales
            v-summ-netto-rub = buf_chk-doc.netto * tt-head-check.cash-scales
         .
         run non-fisk-doc in this-procedure ( INPUt-OUTPUT v-cd-mode-local
                                          , input-output p-cd-submode
                                          , input substitute('ТОВАРНЫЙ ЧЕК &1 (&2)', buf_chk-doc.chk-num, buf_chk-doc.doc-code)
                                          , output p-message
                                          , output p-ok
                                          ) .
      end.
      run clear-tt-chk in this-procedure.
   end.
   else do:
      define buffer buf_rule-call-param   for ub.rule-call-param .
      for each  buf_rule-call-param
            where buf_rule-call-param.call_id = buf_temp-layout-elem-rule.uniq-key-rec
            no-lock
         :
         case buf_rule-call-param.param-name:
            WHEN "p-close"
            then do:
               if  buf_rule-call-param.param-value-logical <> ?
               then
                  assign
                     v-close-good-chk = buf_rule-call-param.param-value-logical
                  .
            end.
            OTHERWISE DO:
            end.
         end case.
      end.
      run non-fisk-doc in this-procedure ( INPUt-OUTPUT p-cd-mode
                                         , input-output p-cd-submode
                                         , input 'ТОВАРНЫЙ ЧЕК'
                                         , output p-message
                                         , output p-ok
                                         ) .
      assign
         v-close-good-chk = FALSE
      .
   end.
   return.
end.
end PROCEDURE.
PROCEDURE get-time-close :
define output parameter p-time as integer          no-undo.
do
on error undo, return error
:
   if v-time-close <> 0
   then do:
      assign
         p-time = TIME - v-time-close
      .
   end.
end.
end PROCEDURE.
PROCEDURE reset-time-close :
do
on error undo, return error
:
   assign
      v-time-close = 0
   .
end.
end PROCEDURE.
procedure accum-chk-gds :
define input   parameter p-code     as character   no-undo .
define output  parameter p-found    as logical   no-undo .
define output  parameter p-gds-qnty as decimal   no-undo .
define buffer buf_chk-gds        for ub.chk-gds .
define buffer buf_tt-open-check  for tt-open-check .
define buffer buf_tt-line        for tt-line .
do
on error undo, return error
:
   for each buf_tt-open-check
      where buf_tt-open-check.chk-type = INTEGER('1':U)
      no-lock
      :
         assign
            p-found    = TRUE
         .
         for each buf_chk-gds
            where buf_chk-gds.doc-code = buf_tt-open-check.doc-code
            AND   buf_chk-gds.src-code = p-code
            NO-LOCK
            :
            assign
               p-gds-qnty = p-gds-qnty + ABS(buf_chk-gds.src-qnty)
            .
         end.
   end.
end.
end procedure.
procedure accum-curr-chk-gds :
define input   parameter p-gds-code  as character   no-undo .
define output  parameter p-gds-qnty  as decimal   no-undo .
define buffer buf_tt-line     for tt-line .
do
on error undo, return error
:
   for each buf_tt-line
      where buf_tt-line.type = 0
        AND buf_tt-line.src  = p-gds-code
      :
      assign
         p-gds-qnty = p-gds-qnty + ABS(buf_tt-line.qnty)
      .
   end.
end.
end procedure.
procedure summ-for-pay :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.
define buffer buf_tt-head-check  for tt-head-check .
define buffer buf_tt-line        for tt-line .
define variable v-pline-num as integer no-undo .
define variable v-mode as character no-undo .
define variable v-pass-pay as integer no-undo .
define variable v-pay-card as character no-undo .
define variable v-tot-sum as decimal no-undo .
define variable v-tot-rubl as decimal no-undo .
define variable v-tot-base as decimal no-undo .
define variable v-par-code as integer   no-undo .
define variable v-src-qnty as decimal no-undo .
define variable v-get-qnty-method as character no-undo .
define variable v-2-cdpay-code as integer no-undo .
define variable v-2-curr-code as integer no-undo .
define variable v-2-tot-base as decimal no-undo .
define variable v-2-tot-rubl as decimal no-undo .
define variable v-2-frpay-code as integer no-undo .
define variable v-src-discnt-local    as decimal      no-undo.
define variable v-src-discnt-local-rub    as decimal      no-undo.
define variable v-for-discnt-local-doc    as decimal no-undo .
define variable v-for-discnt-local-rubl   as decimal no-undo .
define variable v-for-discnt-local-r-b    as decimal no-undo .
do
on error undo, return error
:
   find buf_tt-head-check.
   find last buf_tt-line where buf_tt-line.type = 1 no-error.
   if not available buf_tt-head-check
   then do:
      assign
         v-sum-for-pay = 0
      .
   end.
   if p-cd-submode = "2"
   then do:
      assign
         v-pline-num = if available buf_tt-line then buf_tt-line.num + 1 else 1
         v-mode = 'check'
         v-pass-pay  = 0
         v-pay-card  = "0"
         v-tot-sum   = ?
         v-tot-rubl  = ?
         v-tot-base  = ?
      .
      assign
         v-frpay-code = ?
      .
define variable vss-include-info373 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_pay-line in g#libthpos
  (input  buf_tt-head-check.doc-code
  ,input  v-pline-num
  ,input  v-mode
  ,input-output  v-pay-type
  ,input-output  v-curr-base-code
  ,input  v-par-code
  ,input  v-src-qnty
  ,output v-frpay-code
  ,input  v-pass-pay
  ,input  v-pay-card
  ,input-output  v-tot-sum
  ,input-output  v-sum-for-pay
  ,input-output  v-tot-base
  ,output v-get-qnty-method
  ,output v-2-cdpay-code
  ,output v-2-curr-code
  ,output v-2-frpay-code
  ,output v-2-tot-sum
  ,output v-2-tot-rubl
  ,output v-2-tot-base
  ,output v-src-discnt
  ,output v-src-discnt-rub
  ,output v-for-discnt-doc
  ,output v-for-discnt-rubl
  ,output v-for-discnt-r-b
  ,output p-ok
  ) no-error .
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
            v-sum-for-pay = 0
         .
         return.
      end.
      return.
   end.
   else do:
      assign
         v-sum-for-pay = 0
         p-ok = FALSE
      .
      return.
   end.
end.
end PROCEDURE.
procedure wth-type-select:
define input-output  parameter p-cd-mode     as character no-undo .
define input-output  parameter p-cd-submode  as character no-undo .
define output        parameter p-message     as character no-undo .
define output        parameter p-ok          as logical   no-undo .
define variable v-chk-type    as character    no-undo.
do
on error undo, return error
:
   run gbl/d-list.w  ( input "b-sel":U
                     , input "Выберите тип чека МЦ"
                     , input chr(44) + '3':U + chr(44) + '2':U
                     , input "Тип чека МЦ не задан" + chr(44) + "Кассовый фонд" + chr(44) + 'Инкассация':U
                     , input chr(44)
                     , input "":U
                     , output v-chk-type
                     ) .
   if v-chk-type = "":u then do:
      assign
         p-message = "Не выбран тип чека МЦ"
      .
      return.
   end.
   case v-chk-type:
      WHEN '3':U
      then do:
         run chk-fnd-open  ( INPUt-OUTPUT p-cd-mode
                           , INPUt-output p-cd-submode
                           , output p-message
                           , output p-ok
                           ) .
      end.
      WHEN '2':U
      then do:
         run chk-inc-open  ( INPUt-OUTPUT p-cd-mode
                           , INPUt-output p-cd-submode
                           , output p-message
                           , output p-ok
                           ) .
      end.
      OTHERWISE DO:
      end.
   end case.
end.
end procedure.
procedure reset-summ-for-pay :
do
on error undo, return error
:
   assign
      v-sum-for-pay  = 0
   .
   return.
end.
end PROCEDURE.
procedure disc-type-select:
define output        parameter p-message     as character no-undo .
define output        parameter p-ok          as logical   no-undo .
define variable v-chk-type    as character    no-undo.
do
on error undo, return error
:
   run gbl/d-list.w  ( input "b-sel":U
                     , input "Выберите тип скидки"
                     , input chr(44) + '10':U + chr(44) + '1':U
                     , input "Тип чека МЦ не задан" + chr(44) + "Абсолютная скидка" + chr(44) + "Процентная скидка"
                     , input chr(44)
                     , input "":U
                     , output v-disc-type
                     ) .
   if v-disc-type = "":u then do:
      assign
         p-message = "Не выбран тип скидки"
      .
      return.
   end.
   case v-disc-type:
      WHEN '10':U
      then do:
         assign
            p-message = "Абсолютная скидка на товарную строку"
            p-ok      = TRUE
         .
      end.
      WHEN '1':U
      then do:
         assign
            p-message = "Процентная скидка на товарную строку"
            p-ok      = TRUE
         .
      end.
      OTHERWISE DO:
         assign
            p-message = substitute("Неизвестный тип скидки - &1",v-disc-type)
         .
      end.
   end case.
end.
end procedure.
procedure wait-wth-type :
define output        parameter p-message     as character no-undo .
define output        parameter p-ok          as logical   no-undo .
do
on error undo, return error
:
   assign
      p-message = "Выберите тип чека МЦ"
      p-ok      = FALSE
   .
   return.
end.
end procedure.
procedure export-chk-to-xml :
define output        parameter p-message     as character no-undo .
define output        parameter p-ok          as logical   no-undo .
do
on error undo, return error
:
define variable vss-include-info374 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_print-dataset in g#libthpos
  (input  yes
  ) no-error .
end.
end procedure.
define variable vss-include-info375 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE new SHARED TEMP-TABLE TT-tnved NO-UNDO
FIELD tnved  AS CHAR FORMAT "X(10)"  LABEL 'Код ТНВЭД':U
FIELD f-name AS CHAR FORMAT "X(255)" LABEL 'Полное наименование':U
INDEX tnved IS UNIQUE PRIMARY  tnved.
DEFINE VARIABLE v-h-timer     AS COM-HANDLE           NO-UNDO .
define variable v-etime       as INT64                no-undo.
define variable v-delta-time  as INT64             no-undo.
define variable v-cd-mode     as character INIT "0"   no-undo.
define variable v-cd-submode  as character INIT "0"   no-undo.
define variable v-psn-name    as character    no-undo.
define variable v-curr-num    as integer      no-undo.
define variable v-curr-type   as integer      no-undo.
define variable v-summ-nett    as decimal      no-undo.
define variable v-ok          as logical      no-undo.
define variable v-err-message as character    no-undo.
define variable v-qnt         as decimal      no-undo.
define variable v-message     as character    no-undo.
define variable v-disp-message-1    as character    no-undo.
define variable v-disp-message-2    as character    no-undo.
define variable v-fr-model    as integer      no-undo.
define variable v-summ-fr-1    as decimal      no-undo.
define variable v-summ-for-pay    as decimal   no-undo.
define variable v-fr-type         as character no-undo .
define variable v-time-chk-close  as integer   no-undo.
define variable v-com-port        as character no-undo .
define variable v-layout-id       as character no-undo .
define variable v-layout-id-screen       as character no-undo .
define buffer buf_cash-desk for ub.cash-desk .
define buffer buf_cash-desk-attr for ub.cash-desk-attr .
define buffer buf_layout-elem-rule for layout-elem-rule .
      define variable v-font-ed-msgs_big   as integer no-undo.
define variable v-font-ed-msgs_small as integer no-undo.
define variable v-font-br-line       as integer no-undo.
define variable v-font-br-line_bold  as integer no-undo.
FUNCTION f_src-label RETURNS CHARACTER
  ( vf-src-label as char )  FORWARD.
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.
DEFINE SUB-MENU m_whelp
       MENU-ITEM m_version      LABEL "О программе"
       RULE
       MENU-ITEM m_cash         LABEL "Справка по АРМу ~"Кассир~"" ACCELERATOR "CTRL-F1".
DEFINE MENU MENU-BAR-C-Win MENUBAR
       SUB-MENU  m_whelp        LABEL "Справка"       .
DEFINE VARIABLE CtrlFrame AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chCtrlFrame AS COMPONENT-HANDLE NO-UNDO.
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "Выход"
     SIZE 11 BY 1.46.
DEFINE BUTTON f1
     LABEL "F1":U
     SIZE 8.5 BY 1.46
     BGCOLOR 8 .
DEFINE BUTTON f10
     LABEL "F10":U
     SIZE 11 BY 1.46.
DEFINE BUTTON f11
     LABEL "F11":U
     SIZE 11 BY 1.46.
DEFINE BUTTON f12
     LABEL "F12":U
     SIZE 11 BY 1.46.
DEFINE BUTTON f2
     LABEL "F2":U
     SIZE 11 BY 1.46.
DEFINE BUTTON f3
     LABEL "F3":U
     SIZE 11 BY 1.46.
DEFINE BUTTON f4
     LABEL "F4":U
     SIZE 11 BY 1.46.
DEFINE BUTTON f5
     LABEL "F5":U
     SIZE 11 BY 1.46.
DEFINE BUTTON f6
     LABEL "F6":U
     SIZE 11 BY 1.46.
DEFINE BUTTON f7
     LABEL "F7":U
     SIZE 11 BY 1.46.
DEFINE BUTTON f8
     LABEL "F8":U
     SIZE 11 BY 1.46.
DEFINE BUTTON f9
     LABEL "F9":U
     SIZE 11 BY 1.46.
DEFINE VARIABLE v-ed-message AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 65 BY 1.5
     BGCOLOR 8 FONT 20 NO-UNDO.
DEFINE VARIABLE v-balance AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99":U INITIAL 0
      VIEW-AS TEXT
     SIZE 39.5 BY 2.5
     FGCOLOR 4 FONT 30 NO-UNDO.
DEFINE VARIABLE v-card-num AS CHARACTER FORMAT "X(20)":U
     LABEL "Карта"
      VIEW-AS TEXT
     SIZE 14 BY .58 NO-UNDO.
DEFINE VARIABLE v-chk-num AS CHARACTER FORMAT "X(256)":U
     LABEL "Чек №"
      VIEW-AS TEXT
     SIZE 12.5 BY .67 NO-UNDO.
DEFINE VARIABLE v-client-name AS CHARACTER FORMAT "X(40)":U
     LABEL "Клиент"
      VIEW-AS TEXT
     SIZE 34 BY .58 NO-UNDO.
DEFINE VARIABLE v-date AS DATE FORMAT "99/99/9999":U INITIAL 01/01/001
      VIEW-AS TEXT
     SIZE 7.5 BY .67 NO-UNDO.
DEFINE VARIABLE v-disc-pay AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Скидка"
      VIEW-AS TEXT
     SIZE 8.38 BY .67 NO-UNDO.
DEFINE VARIABLE v-discount AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Скидка"
      VIEW-AS TEXT
     SIZE 8.38 BY .67 NO-UNDO.
DEFINE VARIABLE v-dop-mess AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 30 BY .67 NO-UNDO.
DEFINE VARIABLE v-label-balance AS CHARACTER FORMAT "X(20)":U
      VIEW-AS TEXT
     SIZE 10 BY 2
     FONT 28 NO-UNDO.
DEFINE VARIABLE v-mode-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 12 BY .79
     FGCOLOR 4 FONT 1 NO-UNDO.
DEFINE VARIABLE v-payment AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Оплата"
      VIEW-AS TEXT
     SIZE 8.38 BY .67 NO-UNDO.
DEFINE VARIABLE v-src-input AS CHARACTER FORMAT "X(45)":U
     VIEW-AS FILL-IN
     SIZE 24.13 BY 1.21
     BGCOLOR 8 FONT 28 NO-UNDO.
DEFINE VARIABLE v-src-label AS CHARACTER FORMAT "X(55)":U
      VIEW-AS TEXT
     SIZE 28.5 BY .67
     FONT 6 NO-UNDO.
DEFINE VARIABLE v-time AS CHARACTER FORMAT "X(8)":U INITIAL "0"
      VIEW-AS TEXT
     SIZE 5.38 BY .67 NO-UNDO.
DEFINE VARIABLE v-total AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Итого"
      VIEW-AS TEXT
     SIZE 8.38 BY .67 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 31.5 BY 1.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 14 BY 1.
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 65 BY .88.
DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 31.5 BY 1.
DEFINE QUERY br-line FOR
      bufbr_tt-line SCROLLING.
DEFINE BROWSE br-line
  QUERY br-line DISPLAY
      bufbr_tt-line.src        COLUMN-LABEL "Код"             FORMAT "x(16)":U  WIDTH 10
    bufbr_tt-line.line-name    COLUMN-LABEL "Товар/Оплата"  FORMAT "x(40)":U  WIDTH 18
    substring(bufbr_tt-line.qnty-str,6) @ bufbr_tt-line.qnty-str    COLUMN-LABEL "Кол-во"        FORMAT "x(11)":U  WIDTH 9
    substring(bufbr_tt-line.price-str,5) @ bufbr_tt-line.price-str   COLUMN-LABEL "Цена"          FORMAT "x(20)":U  WIDTH 9
    bufbr_tt-line.summ-netto-rub   COLUMN-LABEL "Сумма"         FORMAT "->>,>>>,>>9.99":U WIDTH 10
    bufbr_tt-line.summ-discont-rub COLUMN-LABEL "Скидка"        FORMAT "->>,>>>,>>9.99":U WIDTH 6
    bufbr_tt-line.summ-brutto  COLUMN-LABEL "Стоим. б/с"    FORMAT "->>,>>>,>>9.99":U WIDTH 10
    bufbr_tt-line.num          COLUMN-LABEL "№"             FORMAT ">>9":U           WIDTH 5
    bufbr_tt-line.line-seller-name COLUMN-LABEL "Продавец" FORMAT "x(20)":U          WIDTH 10
    WITH NO-ROW-MARKERS SEPARATORS SIZE 65 BY 11.29
         FONT 25 ROW-HEIGHT-CHARS .6.
DEFINE FRAME DEFAULT-FRAME
     v-src-label AT ROW 3 COL 3.5 NO-LABEL WIDGET-ID 104
     v-date AT ROW 19.29 COL 62.38 COLON-ALIGNED NO-LABEL WIDGET-ID 100
     v-ed-message AT ROW 1 COL 65 RIGHT-ALIGNED NO-LABEL WIDGET-ID 98
     v-mode-name AT ROW 19.21 COL 1.5 NO-LABEL WIDGET-ID 96
     v-label-balance AT ROW 16.75 COL 16 NO-LABEL WIDGET-ID 80
     v-card-num AT ROW 15.58 COL 4.38 COLON-ALIGNED WIDGET-ID 70
     v-client-name AT ROW 15.58 COL 29.5 COLON-ALIGNED WIDGET-ID 72
     v-chk-num AT ROW 19.29 COL 17 COLON-ALIGNED WIDGET-ID 68
     v-src-input AT ROW 2.67 COL 30.75 COLON-ALIGNED NO-LABEL WIDGET-ID 32
     f1 AT ROW 2.54 COL 57.5 WIDGET-ID 4
     br-line AT ROW 4.08 COL 1 WIDGET-ID 200
     f2 AT ROW 2.5 COL 66.5 WIDGET-ID 6
     f3 AT ROW 4 COL 66.5 WIDGET-ID 8
     f4 AT ROW 5.5 COL 66.5 WIDGET-ID 10
     f5 AT ROW 7 COL 66.5 WIDGET-ID 12
     f6 AT ROW 8.54 COL 66.5 WIDGET-ID 14
     f7 AT ROW 10.04 COL 66.5 WIDGET-ID 16
     f8 AT ROW 11.54 COL 66.5 WIDGET-ID 18
     f9 AT ROW 13.04 COL 66.5 WIDGET-ID 20
     f10 AT ROW 14.54 COL 66.5 WIDGET-ID 22
     f11 AT ROW 16.04 COL 66.5 WIDGET-ID 24
     f12 AT ROW 17.54 COL 66.5 WIDGET-ID 26
     v-balance AT ROW 16.5 COL 26.5 NO-LABEL WIDGET-ID 38
     v-time AT ROW 19.29 COL 72 NO-LABEL WIDGET-ID 62
     v-total AT ROW 16.33 COL 14.38 RIGHT-ALIGNED WIDGET-ID 42
     v-discount AT ROW 16.92 COL 5 COLON-ALIGNED WIDGET-ID 44
     v-payment AT ROW 17.79 COL 5 COLON-ALIGNED WIDGET-ID 46
     b-exit AT ROW 1 COL 66.5 WIDGET-ID 82
     v-disc-pay AT ROW 18.38 COL 5 COLON-ALIGNED WIDGET-ID 112
     v-dop-mess AT ROW 19.29 COL 31.5 COLON-ALIGNED NO-LABEL WIDGET-ID 114
     RECT-1 AT ROW 19.13 COL 1 WIDGET-ID 34
     RECT-4 AT ROW 19.13 COL 64 WIDGET-ID 84
     RECT-5 AT ROW 15.46 COL 1 WIDGET-ID 92
     RECT-6 AT ROW 19.13 COL 32.5 WIDGET-ID 110
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 77 BY 19.17
         FONT 24 WIDGET-ID 100.
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Касса IBS TH POS"
         HEIGHT             = 19.17
         WIDTH              = 77
         MAX-HEIGHT         = 19.17
         MAX-WIDTH          = 77.5
         VIRTUAL-HEIGHT     = 19.17
         VIRTUAL-WIDTH      = 77.5
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE C-Win = CURRENT-WINDOW.
ASSIGN C-Win:MENUBAR    = MENU MENU-BAR-C-Win:HANDLE.
ASSIGN
       br-line:NUM-LOCKED-COLUMNS IN FRAME DEFAULT-FRAME     = 2.
ASSIGN
       v-balance:AUTO-RESIZE IN FRAME DEFAULT-FRAME      = TRUE.
ASSIGN
       v-card-num:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.
ASSIGN
       v-chk-num:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.
ASSIGN
       v-client-name:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.
ASSIGN
       v-date:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.
ASSIGN
       v-dop-mess:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.
ASSIGN
       v-ed-message:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.
ASSIGN
       v-label-balance:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.
ASSIGN
       v-mode-name:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.
CREATE CONTROL-FRAME CtrlFrame ASSIGN
       FRAME           = FRAME DEFAULT-FRAME:HANDLE
       ROW             = 18.75
       COLUMN          = 73.5
       HEIGHT          = 1.25
       WIDTH           = 4
       WIDGET-ID       = 60
       HIDDEN          = yes
       SENSITIVE       = yes.
      CtrlFrame:MOVE-AFTER(f11:HANDLE IN FRAME DEFAULT-FRAME).
ON END-ERROR OF C-Win
OR ENDKEY OF C-Win ANYWHERE DO:
   RUN rule-run        IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT KEYLABEL(LASTKEY), INPUT 'th-pos-keyboard':U,   OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   ASSIGN
      v-src-input = "":U
   .
   RUN Post_Enable_Ui IN THIS-PROCEDURE.
   RETURN no-apply.
END.
ON WINDOW-CLOSE OF C-Win
DO:
  IF v-cd-mode = "0" then APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.
ON WINDOW-RESIZED OF C-Win
DO:
   define variable v-delta-x    as decimal      no-undo.
   define variable v-delta-y    as decimal      no-undo.
   define variable v-prp-x    as decimal      no-undo.
   define variable v-prp-y    as decimal      no-undo.
   define variable ii    as integer      no-undo.
   define variable v-hcol    as handle      no-undo.
   if C-Win :WIDTH-CHARS < 77.50
   then do:
      assign
      C-Win :WIDTH-CHARS = 77.50
      .
   end.
   if C-Win :HEIGHT-CHARS < 19.17
   then do:
      assign
      C-Win :HEIGHT-CHARS = 19.17
      .
   end.
   assign
      v-delta-x = (frame DEFAULT-FRAME :WIDTH-PIXELS  - C-Win :WIDTH-PIXELS )
      v-delta-y = (frame DEFAULT-FRAME :HEIGHT-PIXELS - C-Win :HEIGHT-PIXELS)
      v-prp-x = (C-Win :WIDTH-PIXELS / frame DEFAULT-FRAME :WIDTH-PIXELS )
      v-prp-y = (C-Win :HEIGHT-PIXELS / frame DEFAULT-FRAME :HEIGHT-PIXELS ) .
   if v-prp-x >= 1 then assign
      frame DEFAULT-FRAME :WIDTH-PIXELS          = C-Win :WIDTH-PIXELS
      frame DEFAULT-FRAME :virtual-width-PIXELS  = C-Win :WIDTH-PIXELS.
   if v-prp-y >= 1 then assign
           frame DEFAULT-FRAME :HEIGHT-PIXELS          = C-Win :HEIGHT-PIXELS
           frame DEFAULT-FRAME :virtual-HEIGHT-PIXELS  = C-Win :HEIGHT-PIXELS
   .
   define variable v-widget   as handle       no-undo.
   assign
      v-widget = FRAME DEFAULT-FRAME:FIRST-CHILD
      v-widget = v-widget:FIRST-CHILD
   .
   DO WHILE  VALID-HANDLE(v-widget)
   :
      CASE v-widget:TYPE:
      OTHERWISE do:
              assign
               v-widget :WIDTH-PIXELS  = v-widget :WIDTH-PIXELS  * v-prp-x
               v-widget :HEIGHT-PIXELS = v-widget :HEIGHT-PIXELS * v-prp-y
               v-widget :x  = v-widget :x  * v-prp-x
               v-widget :y = v-widget :y * v-prp-y
            .
      end.
      END CASE.
      assign
         v-widget = v-widget:NEXT-SIBLING
      .
   END.
   if v-prp-x < 1 then assign
      frame DEFAULT-FRAME:virtual-width-PIXELS    = C-Win :WIDTH-PIXELS
      frame DEFAULT-FRAME :WIDTH-PIXELS           = C-Win :WIDTH-PIXELS
       .
   if v-prp-y < 1 then assign
          frame DEFAULT-FRAME :virtual-HEIGHT-PIXELS  = C-Win :HEIGHT-PIXELS
          frame DEFAULT-FRAME :HEIGHT-PIXELS          = C-Win :HEIGHT-PIXELS
             .
if   C-Win :WIDTH-CHARS >= 130
   and   C-Win :HEIGHT-CHARS >= 28
then do:
FRAME DEFAULT-FRAME:font = 26. br-line:font =     41. v-balance:font =   32. v-src-label:font = 38. v-src-input:font = 29. v-mode-name:font  = 38. v-font-ed-msgs_big   = 23. v-font-ed-msgs_small = 20. v-font-br-line       = 41. v-font-br-line_bold  = 35. v-label-balance:font = 38. br-line:ROW-HEIGHT-PIXELS = 20.
end.
else if   C-Win :WIDTH-CHARS >= 107
   and   C-Win :HEIGHT-CHARS >= 20
then do:
FRAME DEFAULT-FRAME:font = 25. br-line:font =     40. v-balance:font =   31. v-src-label:font = 37. v-src-input:font = 28. v-mode-name:font  = 37. v-font-ed-msgs_big   = 22. v-font-ed-msgs_small = 19. v-font-br-line       = 40. v-font-br-line_bold  = 34. v-label-balance:font = 37. br-line:ROW-HEIGHT-PIXELS = 20.
end.
else do:
 FRAME DEFAULT-FRAME:font = 24. br-line:font =     39. v-balance:font =   30. v-src-label:font = 36. v-src-input:font = 27. v-mode-name:font  = 36. v-font-ed-msgs_big   = 21. v-font-ed-msgs_small = 18. v-font-br-line       = 39. v-font-br-line_bold  = 33. v-label-balance:font = 36. br-line:ROW-HEIGHT-PIXELS = 14.
end.
run p_ed-msgs(input v-ed-message:screen-value, input ?).
br-line:refresh() no-error.
   def var v-hb as handle no-undo.
   def var v-colwdt as dec no-undo.
   do ii = 1 to br-line:num-columns:
    v-hb = br-line:GET-BROWSE-COLUMN(ii).
    v-hb:WIDTH-PIXELS = v-hb:WIDTH-PIXELS * v-prp-x.
    v-hb:COLUMN-FONT = 24.
   end.
END.
ON CHOOSE OF b-exit IN FRAME DEFAULT-FRAME
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT b-exit:name, INPUT 'th-pos-screen':U, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
   apply "ENTRY":U TO v-src-input.
END.
ON ROW-DISPLAY OF br-line IN FRAME DEFAULT-FRAME
DO:
  IF bufbr_tt-line.type = 1
  THEN DO:
    assign
      bufbr_tt-line.num             :font in browse br-line = v-font-br-line_bold
      bufbr_tt-line.line-name       :font in browse br-line = v-font-br-line_bold
      bufbr_tt-line.summ-netto-rub  :font in browse br-line = v-font-br-line_bold
      bufbr_tt-line.summ-discont-rub:font in browse br-line = v-font-br-line_bold
      bufbr_tt-line.src             :font in browse br-line = v-font-br-line_bold
      bufbr_tt-line.qnty-str        :font in browse br-line = v-font-br-line_bold
      bufbr_tt-line.price-str       :font in browse br-line = v-font-br-line_bold
      bufbr_tt-line.summ-brutto     :font in browse br-line = v-font-br-line_bold
      bufbr_tt-line.line-seller-name:font in browse br-line = v-font-br-line_bold
     .
     bufbr_tt-line.src:screen-value in browse br-line = '':U.
  END.
  ELSE DO:
    assign
      bufbr_tt-line.num             :font in browse br-line = v-font-br-line
      bufbr_tt-line.line-name       :font in browse br-line = v-font-br-line
      bufbr_tt-line.summ-netto-rub  :font in browse br-line = v-font-br-line
      bufbr_tt-line.summ-discont-rub:font in browse br-line = v-font-br-line
      bufbr_tt-line.src             :font in browse br-line = v-font-br-line
      bufbr_tt-line.qnty-str        :font in browse br-line = v-font-br-line
      bufbr_tt-line.price-str       :font in browse br-line = v-font-br-line
      bufbr_tt-line.summ-brutto     :font in browse br-line = v-font-br-line
      bufbr_tt-line.line-seller-name:font in browse br-line = v-font-br-line
    .
  END.
END.
ON VALUE-CHANGED OF br-line IN FRAME DEFAULT-FRAME
DO:
   assign
      v-curr-num = bufbr_tt-line.num
      v-curr-type = bufbr_tt-line.type
   .
   RUN set-curr-num IN THIS-PROCEDURE (INPUT v-curr-type, INPUT v-curr-num, OUTPUT v-message, OUTPUT v-ok).
END.
PROCEDURE CtrlFrame.PSTimer.Tick .
define variable v-old-cd-mode    as character    no-undo.
define variable v-old-cd-submode    as character    no-undo.
define variable v-old-ok    as logical      no-undo.
define variable v-message-local    as character    no-undo.
define variable v-ok-local          as logical      no-undo.
   ASSIGN
      v-time = STRING(TIME, "HH:MM:SS":U)
      v-date = TODAY
      v-old-cd-mode    = v-cd-mode
      v-old-cd-submode = v-cd-submode
      v-old-ok         = v-ok
   .
   IF TIME modulo 1 = 0
   THEN DO:
      DISPLAY v-time v-date
      WITH FRAME  DEFAULT-FRAME.
   END.
END PROCEDURE.
ON CHOOSE OF f1 IN FRAME DEFAULT-FRAME
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT f1:name, INPUT 'th-pos-screen':U, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
   return no-apply.
END.
ON CHOOSE OF f10 IN FRAME DEFAULT-FRAME
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT f10:name, INPUT 'th-pos-screen':U, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
END.
ON CHOOSE OF f11 IN FRAME DEFAULT-FRAME
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT f11:name, INPUT 'th-pos-screen':U, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
END.
ON CHOOSE OF f12 IN FRAME DEFAULT-FRAME
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT f12:name, INPUT 'th-pos-screen':U, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
END.
ON CHOOSE OF f2 IN FRAME DEFAULT-FRAME
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT f2:name, INPUT 'th-pos-screen':U, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
END.
ON CHOOSE OF f3 IN FRAME DEFAULT-FRAME
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT f3:name, INPUT 'th-pos-screen':U, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
END.
ON CHOOSE OF f4 IN FRAME DEFAULT-FRAME
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT f4:name, INPUT 'th-pos-screen':U, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
END.
ON CHOOSE OF f5 IN FRAME DEFAULT-FRAME
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT f5:name, INPUT 'th-pos-screen':U, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
END.
ON CHOOSE OF f6 IN FRAME DEFAULT-FRAME
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT f6:name, INPUT 'th-pos-screen':U, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
END.
ON CHOOSE OF f7 IN FRAME DEFAULT-FRAME
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT f7:name, INPUT 'th-pos-screen':U, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
END.
ON CHOOSE OF f8 IN FRAME DEFAULT-FRAME
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT f8:name, INPUT 'th-pos-screen':U, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
END.
ON CHOOSE OF f9 IN FRAME DEFAULT-FRAME
DO:
   RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode, INPUT-OUTPUT v-cd-submode, INPUT f9:name, INPUT 'th-pos-screen':U, OUTPUT v-message, OUTPUT v-ok ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   RUN post_enable_UI IN THIS-PROCEDURE.
END.
ON CHOOSE OF MENU-ITEM m_cash
DO:
  message
  "Навигация между элементами интерфейса осуществляется табуляцией," skip
  "по браузеру – клавишами «Вверх/Вниз/Влево/Вправо»." skip(2)
  "Функциональные клавиши на PC-клавиатуре:" skip
  "Enter  - ввод данных" skip
  "Esc    - выход из режима/системы" skip
  "Del    - удаление выделенной линии чека" skip
  "*      - перевод кассы в режим ввода количества"  skip
  "F1     - нажатие на кнопку выбора (кнопка рядом с полем для ввода). Открывает справочник, соответствующий состоянию кассы."  skip
  "F2-F12 - соответсвуют функциональным кнопкам на экране"
  view-as alert-box.
END.
ON CHOOSE OF MENU-ITEM m_version
DO:
   run gbl/version.p no-error.
END.
ON ENTRY OF v-ed-message IN FRAME DEFAULT-FRAME
DO:
define variable vss-include-info376 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-exit :type in frame DEFAULT-FRAME
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame DEFAULT-FRAME skip
    "Тип" self :type in frame DEFAULT-FRAME skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-exit in frame DEFAULT-FRAME .
  if focus :handle <> b-exit :handle in frame DEFAULT-FRAME then do:
    return no-apply .
  end.
end.
  undo, return no-apply.
END.
ON ENTER OF v-src-input IN FRAME DEFAULT-FRAME
DO:
  def var v-md as char no-undo .
  def var v-egalite as int initial 0  no-undo .
  def var v-widget-id as char no-undo .
   ASSIGN
      v-src-input
   .
   if substr(v-src-input,1,1) = ";" and
      substr(v-src-input,length(v-src-input),1) = "?"
      then
   do:
     if v-cd-mode = "1"
           OR v-cd-mode = "2" then
     do:
      assign
         v-md = substitute("&1.&2", v-cd-mode, v-cd-submode)
      .
     end.
     else
     do:
      assign
         v-md = v-cd-mode
      .
     end.
     v-egalite = index(v-src-input,"=") .
     if v-egalite = 0 then
     do:
       v-egalite = length(v-src-input)   .
     end.
     v-src-input = substr(v-src-input,2,v-egalite - 2) .
     if v-cd-submode = "0" then
     do:
      find first buf_layout-elem-rule no-lock where
                 buf_layout-elem-rule.layout-id = v-layout-id-screen
             and buf_layout-elem-rule.mode-id   = v-md
             and buf_layout-elem-rule.rule_id = 1998
             no-error.
      if avail buf_layout-elem-rule then
      do:
       v-widget-id  = buf_layout-elem-rule.widget-id .
       RUN rule-run        IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode
                                             , INPUT-OUTPUT v-cd-submode
                                             , INPUT v-widget-id
                                             , INPUT 'th-pos-screen':U
                                             , OUTPUT v-message
                                             , OUTPUT v-ok ) NO-ERROR.
       IF ERROR-STATUS:ERROR  THEN
       DO:
        ASSIGN
         v-ok = FALSE
         .
       END.
       RUN enable_UI IN THIS-PROCEDURE.
       RUN post_enable_UI IN THIS-PROCEDURE.
      end .
     end.
   end.
   ASSIGN
      v-src-input  = IF INDEX(v-src-input, ".":U) > 0 THEN REPLACE(v-src-input,",":U,"":U)
                                                      ELSE REPLACE(v-src-input,",":U,".":U)
      v-delta-time = ETIME - v-etime
      v-etime      = 0
   .
   IF  v-src-input <> "":U
   THEN DO:
      RUN set-input-time IN THIS-PROCEDURE ( INPUT v-delta-time, OUTPUT v-err-message, OUTPUT v-ok ).
      RUN set-src IN THIS-PROCEDURE ( INPUT v-src-input,  OUTPUT v-err-message, OUTPUT v-ok ).
      RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode
                                     , INPUT-OUTPUT v-cd-submode
                                     , INPUT v-src-input:name
                                     , INPUT 'th-pos-screen':U
                                     , OUTPUT v-message
                                     , OUTPUT v-ok ) NO-ERROR.
      IF ERROR-STATUS:ERROR
      THEN DO:
         ASSIGN
            v-ok = FALSE
         .
      END.
      ASSIGN
         v-src-input = "":U
      .
      RUN Enable_Ui IN THIS-PROCEDURE.
      RUN Post_Enable_Ui IN THIS-PROCEDURE.
      RETURN NO-APPLY.
   END.
END.
ON VALUE-CHANGED OF v-src-input IN FRAME DEFAULT-FRAME
DO:
  IF (v-etime = 0)
  THEN DO:
  assign
     v-etime = ETIME
  .
  END.
END.
ASSIGN CURRENT-WINDOW                = C-Win
       THIS-PROCEDURE:CURRENT-WINDOW = C-Win.
ON CLOSE OF THIS-PROCEDURE
   RUN disable_UI.
PAUSE 0 BEFORE-HIDE.
on any-key OF C-Win ANYWHERE
do :
   DO
   WITH FRAME DEFAULT-FRAME
   :
   define variable v-old-cd-mode    as character    no-undo.
   define variable v-old-cd-submode    as character    no-undo.
   define variable v-key    as character    no-undo.
   define variable v-c-src-input as char  no-undo .
   assign v-key = string(lastkey)
          v-ok = no .
   if v-layout-id <> '' then
   do:
     find first buf_layout-elem-rule no-lock
               where buf_layout-elem-rule.layout-id = v-layout-id
               and buf_layout-elem-rule.widget-id = v-key
               no-error.
     if avail buf_layout-elem-rule then
     do:
         v-c-src-input = input v-src-input .
         if buf_layout-elem-rule.rule_id = 1978 then
         do:
            RUN set-src IN THIS-PROCEDURE ( INPUT v-c-src-input,
                                            OUTPUT v-err-message,
                                            OUTPUT v-ok ) .
         end.
         RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode
                                         , INPUT-OUTPUT v-cd-submode
                                         , INPUT v-key
                                         , INPUT 'th-pos-keyboard':U
                                         , OUTPUT v-message
                                         , OUTPUT v-ok
                                         ) NO-ERROR
                                        .
         IF ERROR-STATUS:ERROR
         THEN DO:
            ASSIGN
               v-ok = FALSE
            .
         END.
         if v-ok = no then
            assign
               v-src-input = ""
               v-c-src-input = "" .
         if buf_layout-elem-rule.rule_id = 1978 then
         do:
           v-src-input = '' .
         end.
           RUN enable_UI IN THIS-PROCEDURE .
           RUN post_enable_UI IN THIS-PROCEDURE .
           if v-c-src-input <> '' then
           do:
             assign
               v-src-input = v-c-src-input .
            RUN set-src IN THIS-PROCEDURE ( INPUT v-src-input,
                                            OUTPUT v-err-message,
                                            OUTPUT v-ok ) .
            RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode
                                             , INPUT-OUTPUT v-cd-submode
                                             , INPUT "v-src-input"
                                             , INPUT 'th-pos-screen':U
                                             , OUTPUT v-message
                                             , OUTPUT v-ok ) NO-ERROR.
             IF ERROR-STATUS:ERROR
             THEN DO:
                 ASSIGN
                   v-ok = FALSE
                    .
             END.
             assign v-src-input = "" .
             RUN Enable_Ui IN THIS-PROCEDURE.
             RUN Post_Enable_Ui IN THIS-PROCEDURE.
           end.
           Return no-apply .
     end.
   end.
   assign
      v-key = KEYLABEL(LASTKEY)
   .
   CASE v-key:
      WHEN "CURSOR-UP":U OR
      WHEN "CURSOR-DOWN":U
      THEN DO:
         APPLY "ENTRY":U TO br-line.
         IF NOT AVAILABLE bufbr_tt-line
         THEN DO:
            IF CAN-FIND (tt-line NO-LOCK)
            THEN DO:
               query br-line :handle :get-first( no-lock ).
               reposition br-line to rowid rowid( bufbr_tt-line ) no-error.
               assign
                  v-curr-num = bufbr_tt-line.num
                  v-curr-type = bufbr_tt-line.type
               .
               RUN set-curr-num IN THIS-PROCEDURE (INPUT v-curr-type, INPUT v-curr-num, OUTPUT v-message, OUTPUT v-ok).
            END.
         END.
         ELSE DO:
            IF v-key = "CURSOR-UP":U
            THEN DO:
               query br-line :handle :get-prev( no-lock ).
               reposition br-line to rowid rowid( bufbr_tt-line ) no-error.
               assign
                  v-curr-num = bufbr_tt-line.num
                  v-curr-type = bufbr_tt-line.type
               .
               RUN set-curr-num IN THIS-PROCEDURE (INPUT v-curr-type, INPUT v-curr-num, OUTPUT v-message, OUTPUT v-ok).
            END.
            ELSE DO:
               query br-line :handle :get-next( no-lock ).
               reposition br-line to rowid rowid( bufbr_tt-line ) no-error.
               assign
                  v-curr-num = bufbr_tt-line.num
                  v-curr-type = bufbr_tt-line.type
               .
               RUN set-curr-num IN THIS-PROCEDURE (INPUT v-curr-type, INPUT v-curr-num, OUTPUT v-message, OUTPUT v-ok).
            END.
            CASE bufbr_tt-line.type:
               WHEN 0
               THEN DO:
                  assign
                     v-message                = SUBSTITUTE  ( "&1 &2x&3"
                                                            , bufbr_tt-line.line-name
                                                            , bufbr_tt-line.qnty
                                                            , bufbr_tt-line.price
                                                            )
                  .
               END.
               WHEN 1
               THEN DO:
                  assign
                     v-message                = SUBSTITUTE  ( "&1 &2"
                                                            , bufbr_tt-line.line-name
                                                            , bufbr_tt-line.summ-netto
                                                            )
                  .
               END.
               OTHERWISE DO:
               END.
            END CASE.
         END.
      END.
      WHEN "CURSOR-LEFT":U
      THEN DO:
         APPLY "CURSOR-LEFT"  TO br-line .
      END.
      WHEN "CURSOR-RIGHT":U
      THEN DO:
         APPLY "CURSOR-RIGHT"  TO br-line .
      END.
      WHEN "*":U
      THEN DO:
      END.
      WHEN "F1":U OR
      WHEN "F2":U OR
      WHEN "F3":U OR
      WHEN "F4":U OR
      WHEN "F5":U OR
      WHEN "F6":U OR
      WHEN "F7":U OR
      WHEN "F8":U OR
      WHEN "F9":U OR
      WHEN "F10":U OR
      WHEN "F11":U OR
      WHEN "F12":U OR
      WHEN "CTRL-S":U
      THEN DO:
         RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode
                                         , INPUT-OUTPUT v-cd-submode
                                         , INPUT v-key
                                         , INPUT 'th-pos-screen':U
                                         , OUTPUT v-message
                                         , OUTPUT v-ok
                                         ) NO-ERROR.
         IF ERROR-STATUS:ERROR
         THEN DO:
            ASSIGN
               v-ok = FALSE
            .
         END.
         RUN enable_UI IN THIS-PROCEDURE.
         RUN post_enable_UI IN THIS-PROCEDURE.
      END.
      WHEN "ENTER":U
      THEN DO:
         IF focus:name = "v-src-input":U
         THEN DO:
            APPLY "LEAVE":U TO v-src-input.
            RETURN NO-APPLY.
         END.
         IF focus:name = "v-ed-message":U
         THEN DO:
            RETURN NO-APPLY.
         END.
         RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode
                                         , INPUT-OUTPUT v-cd-submode
                                         , INPUT focus:name
                                         , INPUT 'th-pos-keyboard':U
                                         , OUTPUT v-message
                                         , OUTPUT v-ok
                                         ) NO-ERROR.
         IF ERROR-STATUS:ERROR
         THEN DO:
            ASSIGN
               v-ok = FALSE
            .
         END.
         RUN enable_UI IN THIS-PROCEDURE.
         RUN post_enable_UI IN THIS-PROCEDURE.
      END.
      OTHERWISE DO:
      END.
   END CASE.
   END.
end.
on "*":U OF FRAME DEFAULT-FRAME , v-src-input , br-line do :
   DO
   WITH FRAME DEFAULT-FRAME
   :
      RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode
                                     , INPUT-OUTPUT v-cd-submode
                                     , INPUT "*":U
                                     , INPUT 'th-pos-keyboard':U
                                     , OUTPUT v-message
                                     , OUTPUT v-ok
                                     ) NO-ERROR.
      IF ERROR-STATUS:ERROR
      THEN DO:
            ASSIGN
               v-ok = FALSE
            .
      END.
      RUN enable_UI IN THIS-PROCEDURE.
      RUN post_enable_UI IN THIS-PROCEDURE.
      RETURN NO-APPLY.
   END.
END.
on "DEL":U OF FRAME DEFAULT-FRAME , v-src-input , br-line do :
   DO
   WITH FRAME DEFAULT-FRAME
   :
      RUN rule-run IN THIS-PROCEDURE ( INPUT-OUTPUT v-cd-mode
                                     , INPUT-OUTPUT v-cd-submode
                                     , INPUT "DEL":U
                                     , INPUT 'th-pos-keyboard':U
                                     , OUTPUT v-message
                                     , OUTPUT v-ok
                                     ) NO-ERROR.
      IF ERROR-STATUS:ERROR
      THEN DO:
            ASSIGN
               v-ok = FALSE
            .
      END.
      RUN enable_UI IN THIS-PROCEDURE.
      RUN post_enable_UI IN THIS-PROCEDURE.
      RETURN NO-APPLY.
   END.
END.
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   IF p-emul
   THEN DO:
      run set-emul-mode IN THIS-PROCEDURE (OUTPUT v-message, OUTPUT v-ok).
   END.
   define buffer buf_user-account      for ub.user-account .
   FIND FIRST buf_user-account
        where buf_user-account.user-id = p-user-id
        no-lock
        .
   ASSIGN
      v-psn-name = SUBSTITUTE ( "&1 &2&3&4&5":U
                              , buf_user-account.last-name
                              , SUBSTRING(buf_user-account.first-name, 1, 1)
                              , IF buf_user-account.first-name <> "":U THEN ".":U ELSE "":U
                              , SUBSTRING(buf_user-account.second-name, 1, 1)
                              , IF buf_user-account.first-name <> "":U
                                AND buf_user-account.second-name <> "":U THEN ".":U ELSE "":U
                              )
   .
   assign
      C-Win :max-width          = session :width-chars
      C-Win :virtual-width      = session :width-chars
      C-Win :max-height         = session :height-chars
      C-Win :virtual-height     = session :height-chars
   .
    RUN set-cashier IN THIS-PROCEDURE  ( output v-message
                                       , output v-ok
                                       ) .
    if v-ok = no then
    do:
      return .
    end .
    DO
    TRANSACTION
    :
      FIND FIRST buf_cash-desk
           WHERE buf_cash-desk.db-num   = v-cntxt-db-num
             AND buf_cash-desk.obj-code = v-cntxt-obj-code
             AND buf_cash-desk.pos-type = 'IBS-TH':U
             AND buf_cash-desk.cash-num = p-cash-num
           EXCLUSIVE-LOCK
           NO-WAIT
           NO-ERROR
           .
      IF NOT AVAILABLE buf_cash-desk
      THEN DO:
         IF LOCKED buf_cash-desk
         THEN DO:
            message
               SUBSTITUTE("Касса &1 уже работает", p-cash-num)
               skip
            view-as alert-box information.
            RETURN.
         END.
         ELSE DO:
            message
               "Касса №" p-cash-num
               skip "на объекте" v-cntxt-obj-type v-cntxt-obj-code
               SKIP "не найдена"
            view-as alert-box information.
            RETURN.
         END.
      END.
      assign
        v-fr-type = buf_cash-desk.fr-type
        .
      find first   buf_cash-desk-attr no-lock where
                    buf_cash-desk-attr.db-num = buf_cash-desk.db-num
                and buf_cash-desk-attr.obj-code = buf_cash-desk.obj-code
                and buf_cash-desk-attr.pos-type = buf_cash-desk.pos-type
                and buf_cash-desk-attr.cash-num = buf_cash-desk.cash-num
            and buf_cash-desk-attr.upper-attr-code = 'IBS-TH_fisreg':U
            and buf_cash-desk-attr.attr-code = 'com-port':U
        no-error.
     if avail buf_cash-desk-attr then
     do:
      assign
         v-com-port = buf_cash-desk-attr.attr-value-character
      .
     end.
      find first   buf_cash-desk-attr no-lock where
                    buf_cash-desk-attr.db-num = buf_cash-desk.db-num
                and buf_cash-desk-attr.obj-code = buf_cash-desk.obj-code
                and buf_cash-desk-attr.pos-type = buf_cash-desk.pos-type
                and buf_cash-desk-attr.cash-num = buf_cash-desk.cash-num
  and buf_cash-desk-attr.upper-attr-code = 'IBS-TH_devices':U
  and buf_cash-desk-attr.attr-code = 'keyboard-layout-id':U
        no-error.
     if avail buf_cash-desk-attr then
     do:
      assign
         v-layout-id = buf_cash-desk-attr.attr-value-character
      .
     end.
      find first   buf_cash-desk-attr no-lock where
                    buf_cash-desk-attr.db-num = buf_cash-desk.db-num
                and buf_cash-desk-attr.obj-code = buf_cash-desk.obj-code
                and buf_cash-desk-attr.pos-type = buf_cash-desk.pos-type
                and buf_cash-desk-attr.cash-num = buf_cash-desk.cash-num
  and buf_cash-desk-attr.upper-attr-code = 'IBS-TH_interface':U
  and buf_cash-desk-attr.attr-code = 'screen-layout-id':U
        no-error.
     if avail buf_cash-desk-attr then
     do:
      assign
         v-layout-id-screen = buf_cash-desk-attr.attr-value-character
      .
     end.
    END.
define variable vss-include-info377 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info378 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libthpos) <> true) then do:   run str/libthpos.p persistent no-error .   if error-status :error or (valid-handle(g#libthpos) <> true) then do:     message       "Error starting nws/libthpos.p" skip       g#libthpos skip       g#libthpos :type skip       g#libthpos :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libthpos_create-context in g#libthpos
  (input  parparentproc
  ,input  ?
  ,input  v-cntxt-db-num
  ,input  v-cntxt-obj-code
  ,input  'IBS-TH':U
  ,input  p-cash-num
  ,output v-serial-code
  ,output v-r-b
  ,output v-base-code
  ) no-error .
   IF ERROR-STATUS:ERROR
   THEN DO:
      message  "Ошибка инициализации кассы IBS TH №"   p-cash-num
         skip "магазина №"                             v-cntxt-obj-code
         skip "БД №"                                   v-cntxt-db-num
         skip RETURN-VALUE
         SKIP error-status :get-message(1)
         SKIP error-status :get-message(2)
         SKIP error-status :get-message(3)
      view-as alert-box information.
      QUIT.
   END.
   run set-cd-base-code in this-procedure (INPUT v-base-code, OUTPUT v-message, OUTPUT v-ok) .
   IF ERROR-STATUS:ERROR
   OR NOT v-ok
   THEN DO:
      assign
         v-ok = no
         v-message = v-err-message
      .
      message
         SKIP RETURN-VALUE
         SKIP trim(error-status :get-message(1))
         SKIP trim(error-status :get-message(2))
         SKIP trim(error-status :get-message(3))
         SKIP v-err-message
      view-as alert-box information.
      RETURN NO-APPLY.
   END.
   IF NOT p-emul
   THEN DO:
define variable vss-include-info379 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#fr-lib ) <> TRUE then do:       run gbl/fr-lib.p persistent no-error.       if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do:         message "Error starting fr-lib.p" skip( 0 )           g#fr-lib                        skip( 0 )           g#fr-lib    :type               skip( 0 )           g#fr-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run fr-init in g#fr-lib
    ( input  p-cash-num
    , input  v-cntxt-obj-code
    , input  v-serial-code
    , input  v-fr-type
    , input  v-com-port
    , output v-fr-model
    , output v-err-message
    , output v-ok
    ) NO-ERROR .
end.
      IF ERROR-STATUS:ERROR
      OR NOT v-ok
      THEN DO:
         message
         SKIP RETURN-VALUE
         SKIP trim(error-status :get-message(1))
         SKIP trim(error-status :get-message(2))
         SKIP trim(error-status :get-message(3))
         SKIP v-err-message
         view-as alert-box information.
         RETURN.
      END.
      IF NOT v-ok
      THEN DO:
         assign
            v-message = v-err-message
         .
      END.
      RUN set-context-serial ( INPUT v-serial-code
                             , INPUT v-fr-model
                             , OUTPUT v-message
                             , OUTPUT v-ok
                             ) .
   END.
   RUN set-cd-prop IN THIS-PROCEDURE (OUTPUT v-message, OUTPUT v-ok).
   IF NOT v-ok
   THEN DO:
      message
         v-message
         skip
      view-as alert-box error.
      RETURN.
   END.
   IF NOT p-emul
   THEN DO:
      RUN get-display-adv IN THIS-PROCEDURE  ( OUTPUT v-disp-message-1
                                             , OUTPUT v-disp-message-2
                                             , OUTPUT v-message
                                             , OUTPUT v-ok
                                             ) .
define variable vss-include-info380 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#sb-lib ) <> TRUE then do:       run gbl/sb-lib.p persistent no-error.       if error-status :error or valid-handle( g#sb-lib ) <> TRUE then do:         message "Error starting sb-lib.p" skip( 0 )           g#sb-lib                        skip( 0 )           g#sb-lib    :type               skip( 0 )           g#sb-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run sb-init in g#sb-lib
    ( input  v-cashless-system
    , output v-err-message
    , output v-ok
    ) NO-ERROR .
end.
      IF ERROR-STATUS:ERROR
      OR NOT v-ok
      THEN DO:
         message
         SKIP RETURN-VALUE
         SKIP trim(error-status :get-message(1))
         SKIP trim(error-status :get-message(2))
         SKIP trim(error-status :get-message(3))
         SKIP v-err-message
         view-as alert-box information.
         RETURN NO-APPLY.
      END.
      IF v-customer-display-plug
      THEN DO:
define variable vss-include-info381 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#disp-lib ) <> TRUE then do:       run gbl/disp-lib.p persistent no-error.       if error-status :error or valid-handle( g#disp-lib ) <> TRUE then do:         message "Error starting disp-lib.p" skip( 0 )           g#disp-lib                        skip( 0 )           g#disp-lib    :type               skip( 0 )           g#disp-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run disp-init in g#disp-lib
    ( input  v-disp-message-1
    , input  v-disp-message-2
    , input  v-customer-display-type
    , input  v-customer-display-port
    , output v-message
    , output v-ok
    ) NO-ERROR .
end.
         IF ERROR-STATUS:ERROR
         OR NOT v-ok
         THEN DO:
            message
            SKIP RETURN-VALUE
            SKIP trim(error-status :get-message(1))
            SKIP trim(error-status :get-message(2))
            SKIP trim(error-status :get-message(3))
            SKIP v-err-message
            view-as alert-box information.
            RETURN NO-APPLY.
         END.
      END.
   END.
   RUN fill-tt IN THIS-PROCEDURE.
   RUN cd-context ( INPUt-OUTPUT v-cd-mode
                  , INPUt-output v-cd-submode
                  , output v-message
                  , output v-ok
                  ) .
   RUN annul-lost-chk IN THIS-PROCEDURE ( output v-message
                                        , output v-ok
                                        ) .
   IF NOT v-ok
   THEN DO:
      message
         v-message
         skip
      view-as alert-box error.
   END.
   RUN enable_UI IN THIS-PROCEDURE.
   C-Win :HEIGHT-CHARS = C-Win :FULL-HEIGHT-CHARS.
   C-Win :width-CHARS = C-Win :FULL-width-CHARS.
   C-Win :X = session:WORK-AREA-X.
   C-Win :Y = session:WORK-AREA-Y.
   apply "window-resized":U to c-win.
   RUN post_enable_UI IN THIS-PROCEDURE.
define variable vss-include-info382 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if valid-handle( g#disp-lib ) <> TRUE then do:       run gbl/disp-lib.p persistent no-error.       if error-status :error or valid-handle( g#disp-lib ) <> TRUE then do:         message "Error starting disp-lib.p" skip( 0 )           g#disp-lib                        skip( 0 )           g#disp-lib    :type               skip( 0 )           g#disp-lib    :file-name          skip( 0 )           error-status :get-message( 1 )  skip( 0 )           return-value                    skip( 0 )         view-as alert-box error.         stop.       end.      end.     run disp-str in g#disp-lib
    ( INPUT  v-cashier-name
    , INPUT  '':U
    , output v-err-message
    , output v-ok
    ) NO-ERROR .
end.
   IF NOT THIS-PROCEDURE:PERSISTENT THEN
      WAIT-FOR CLOSE OF THIS-PROCEDURE FOCUS v-src-input.
   RELEASE buf_cash-desk.
END.
PROCEDURE control_load :
DEFINE VARIABLE UIB_S    AS LOGICAL    NO-UNDO.
DEFINE VARIABLE OCXFile  AS CHARACTER  NO-UNDO.
OCXFile = SEARCH( "exe\wrx\gbl\maincash.wrx":U ).
IF OCXFile = ? THEN
  OCXFile = SEARCH(SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1,
                     R-INDEX(THIS-PROCEDURE:FILE-NAME, ".":U), "CHARACTER":U) + "wrx":U).
IF OCXFile <> ? THEN
DO:
  ASSIGN
    chCtrlFrame = CtrlFrame:COM-HANDLE
    UIB_S = chCtrlFrame:LoadControls( OCXFile, "CtrlFrame":U)
    CtrlFrame:NAME = "CtrlFrame":U
  .
  RUN initialize-controls IN THIS-PROCEDURE NO-ERROR.
END.
ELSE MESSAGE "exe\wrx\gbl\maincash.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".
END PROCEDURE.
PROCEDURE disable_UI :
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
  THEN DELETE WIDGET C-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE enable_UI :
  RUN control_load.
  DISPLAY v-src-label v-date v-ed-message v-mode-name v-label-balance v-card-num
          v-client-name v-chk-num v-src-input v-balance v-time v-total
          v-discount v-payment v-disc-pay v-dop-mess
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE v-src-label v-date v-ed-message v-mode-name v-label-balance v-card-num
         v-client-name v-chk-num v-src-input f1 br-line f2 f3 f4 f5 f6 f7 f8 f9
         f10 f11 f12 v-balance v-time v-total v-discount v-payment b-exit
         v-disc-pay v-dop-mess RECT-1 RECT-4 RECT-5 RECT-6
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  OPEN QUERY br-line FOR EACH bufbr_tt-line.
  VIEW C-Win.
END PROCEDURE.
PROCEDURE post_enable_UI :
do
on error undo, LEAVE
:
   define variable v-ok-local          as logical      no-undo.
   define variable v-widget      as handle       no-undo.
   define variable v-label       as character    no-undo.
   define variable v-tooltip       as character    no-undo.
   define variable v-cd-subname  as character    no-undo.
   define variable v-ccc    as character    no-undo.
   define variable v-message-local    as character    no-undo.
   define buffer buf_tt-line     for tt-line .
   RUN get-mode-name IN THIS-PROCEDURE ( INPUT v-cd-mode
                                     , INPUT v-cd-submode
                                     , OUTPUT v-mode-name
                                     , OUTPUT v-ok-local
                                     ) .
    define variable v-title as character no-undo .
    define variable v-version-name as character no-undo .
    define variable v-version-name-str as character no-undo .
    define variable v-host-str         as character no-undo .
    define variable v-obj-str          as character no-undo .
    define variable v-user-str         as character no-undo .
    define variable v-db-num-str       as character no-undo .
    define variable v-user-id-str      as character no-undo .
    define variable v-process-id-str   as character no-undo .
    run gbl/getvers.p
      (output v-version-name
      ) .
    assign
      v-version-name-str = substitute("ITH &1", v-version-name)
    .
    assign
      v-db-num-str = substitute("БД: &1", v-cntxt-db-num)
    .
    assign
      v-user-id-str = substitute("Кассир: &1", v-psn-name)
    .
    assign
      v-host-str = substitute("Фирма: &1 &2"
                              ,'орг':U
                              ,v-cntxt-host-code-obj
                              )
    .
    assign
      v-obj-str = substitute("Объект: &1 &2"
                            ,v-cntxt-obj-type
                            ,v-cntxt-obj-code
                            )
    .
    assign
      v-title = substitute('Касса IBS TH POS &1, &2, &3, &4, &5, &6, PID &7':U
                          ,p-cash-num
                          ,v-db-num-str
                          ,v-host-str
                          ,v-obj-str
                          ,v-user-id-str
                          ,v-version-name-str
                          ,p-pid
                          )
    .
   ASSIGN
      C-Win:TITLE = v-title
   .
   RUN get-submode-name IN THIS-PROCEDURE ( INPUT v-cd-mode
                                       , INPUT v-cd-submode
                                       , OUTPUT v-cd-subname
                                       , OUTPUT v-ok-local
                                       ) .
   ASSIGN
      v-src-label:screen-value IN FRAME DEFAULT-FRAME = f_src-label(v-cd-subname)
   .
   RUN get-chk-num  IN THIS-PROCEDURE  ( OUTPUT v-chk-num
                                       , OUTPUT v-ok-local
                                       ) .
   run get-aux-mess in this-procedure (
                                          output v-dop-mess
                                        , OUTPUT v-ok-local
                                        ).
   RUN get-card-num ( OUTPUT v-card-num
                    , OUTPUT v-client-name
                    , OUTPUT v-ok-local
                    ) .
   IF v-cd-mode = "1"
   OR v-cd-mode = "2"
   THEN DO:
      RUN summ-for-pay  ( INPUt-OUTPUT v-cd-mode
                        , INPUt-output v-cd-submode
                        , output v-message-local
                        , output v-ok-local
                        ) .
   END.
   IF  v-cd-mode <> "0"
   AND v-cd-mode <> "4"
   THEN DO:
      RUN get-all-summ (  OUTPUT v-total
                        , OUTPUT v-summ-nett
                        , OUTPUT v-discount
                        , OUTPUT v-payment
                        , OUTPUT v-summ-fr-1
                        , OUTPUT v-summ-for-pay
                        , OUTPUT v-disc-pay
                        , OUTPUT v-message-local
                        , OUTPUT v-ok-local
                        ) .
   END.
   IF v-summ-for-pay = 0
   THEN DO:
      ASSIGN
         v-summ-for-pay =  IF v-cd-mode = "2" THEN v-payment - v-summ-nett
                                                         ELSE v-summ-nett - v-payment
      .
   END.
   IF  v-payment = 0
   AND v-cd-mode = "0"
   THEN DO:
      ASSIGN
         v-summ-for-pay = 0
      .
   END.
   ASSIGN
      v-label-balance = IF v-cd-mode = "2" THEN IF (v-summ-for-pay) > 0 THEN "Сдача:" ELSE "К оплате:"
                                                      ELSE IF (v-summ-for-pay) < 0 THEN "Сдача:" ELSE "К оплате:"
      v-balance = ABS(v-summ-for-pay)
   .
   RUN get-curr-num ( OUTPUT v-curr-type
                    , OUTPUT v-curr-num
                    , OUTPUT v-message-local
                    , OUTPUT v-ok-local
                    ) .
   IF v-curr-num <> 0
   THEN DO:
      find first buf_tt-line
         where buf_tt-line.num  = v-curr-num
           AND buf_tt-line.type = v-curr-type
         no-lock
         no-error
         .
      IF AVAILABLE buf_tt-line
      THEN DO:
         reposition br-line to rowid rowid( buf_tt-line ) no-error.
      END.
   END.
   CASE v-cd-mode:
      WHEN "1" OR
      WHEN "2" THEN DO:
         IF v-cd-submode = "7"
         AND AVAILABLE bufbr_tt-line
         THEN DO:
            ASSIGN
               v-src-input = trim(STRING(bufbr_tt-line.price, "->>>>>>>>9.99"))
            .
         END.
      END.
      OTHERWISE DO:
      END.
   END CASE.
   run get-disc-type IN THIS-PROCEDURE ( OUTPUT v-disc-type
                                       , OUTPUT v-message-local
                                       , OUTPUT v-ok-local
                                       ) .
   CASE v-disc-type:
      WHEN '10':U
      THEN DO:
         assign
            v-src-label:screen-value IN FRAME DEFAULT-FRAME = f_src-label("Сумма скидки")
         .
      END.
      WHEN '1':U
      THEN DO:
         assign
            v-src-label:screen-value IN FRAME DEFAULT-FRAME = f_src-label("Процент скидки")
         .
      END.
      OTHERWISE DO:
      END.
   END CASE.
   DISPLAY
      v-src-input
      v-chk-num
      v-dop-mess
      v-card-num
      v-client-name
      v-payment
      v-total
      v-balance
      v-discount
      v-disc-pay
      v-label-balance
      v-mode-name
   WITH FRAME DEFAULT-FRAME.
   IF v-message <> "":U
   THEN DO:
      run p_ed-msgs(input v-message, input v-ok) no-error.
   END.
   assign
      v-widget = FRAME DEFAULT-FRAME:FIRST-CHILD
      v-widget = v-widget:FIRST-CHILD
   .
   DO WHILE  VALID-HANDLE(v-widget)
   :
      IF  v-widget:TYPE = "BUTTON":U
      THEN DO:
         RUN key-enable IN THIS-PROCEDURE ( INPUT v-cd-mode
                                          , INPUT v-cd-submode
                                          , INPUT v-widget:NAME
                                          , OUTPUT v-ok-local
                                          , OUTPUT v-label
                                          , OUTPUT v-tooltip
                                          ) NO-ERROR.
         IF v-ok-local
         AND ERROR-STATUS:ERROR = FALSE
         THEN DO:
            ASSIGN
               v-widget:SENSITIVE = TRUE
               v-widget:LABEL = v-label
               v-widget:tooltip = v-tooltip
            .
         END.
         ELSE DO:
            ASSIGN
               v-widget:SENSITIVE = FALSE
               v-widget:LABEL     = v-widget:NAME
            .
         END.
      END.
      assign
         v-widget = v-widget:NEXT-SIBLING
      .
   END.
end.
IF ERROR-STATUS:ERROR
THEN DO:
   message
      202 v-message-local
      skip RETURN-VALUE
      SKIP error-status :get-message(1)
   view-as alert-box error.
END.
apply 'entry':U to v-src-input.
END PROCEDURE.
PROCEDURE p_ed-msgs :
define input parameter p-msgs as character no-undo.
define input parameter p-ok  as logical no-undo.
v-ed-message:screen-value in frame DEFAULT-FRAME = p-msgs.
if p-ok then v-ed-message:FGCOLOR in frame DEFAULT-FRAME = Black_COLOR.
else if p-ok  = no then  v-ed-message:FGCOLOR in frame DEFAULT-FRAME = RED_COLOR.
 IF LENGTH(p-msgs) > 38
      OR INDEX(v-ed-message, chr(10)) > 0
 THEN v-ed-message:FONT  = v-font-ed-msgs_small.
 else v-ed-message:FONT  = v-font-ed-msgs_big .
END PROCEDURE.
FUNCTION f_src-label RETURNS CHARACTER
  ( vf-src-label as char ) :
if  vf-src-label > "" then do:
    return fill(" ":U,38 - length(vf-src-label)) + vf-src-label  + ':':U.
end.
  RETURN "".
END FUNCTION.
