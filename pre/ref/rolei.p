block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo .
define input parameter p-psn-code like ub.person.psn-code no-undo .
define input parameter p-role as character no-undo .
define input parameter p-role-level as character no-undo .
define input-output parameter p-rid as recid no-undo .
define temp-table tt0-staff no-undo like ub.staff.
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR tt0-staff.
define variable vss-revision    as character no-undo init "$Revision: 9d0726b3ce11, 2757, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Сб фев 20 15:59:21 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rolei.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/rolei.p $":U .
define variable vss-description as character no-undo init "Заведение и редактирование ролей".
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
define variable ref-list as character no-undo .
define variable to-grp  as integer no-undo .
define variable v-level as character no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-obj-type like ub.clients.obj-type no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-title as character no-undo .
define variable v-staff-code-label as character no-undo .
define variable v-staff-code-format as character no-undo .
define variable v-password-option as integer no-undo .
define variable v-password-label as character no-undo .
define variable v-password-format as character no-undo .
define variable v-notes as character no-undo .
define variable v-cashier-code as integer no-undo .
define variable v-seller-code as integer no-undo .
define variable v-password as character no-undo .
define variable v-staff-code as integer no-undo .
define variable ri as recid no-undo .
define variable v-ok as logical no-undo .
define variable glog as logical no-undo .
define variable v-id-string as character no-undo .
define variable v-work-place as character no-undo .
define variable v-omron as logical no-undo .
define variable v-ncr as logical no-undo .
define variable v-servis as logical no-undo .
define variable v-date-start as date no-undo .
define variable v-date-end as date no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_cli-grp for ub.cli-grp.
define buffer buf_clients for ub.clients.
define buffer tt-staff for tt0-staff.
define buffer buf_staff for ub.staff.
define buffer buf_cash-desk for ub.cash-desk.
do
on error undo, return error return-value
:
  CASE p-mode :
    when 'ДОБАВЛЕНИЕ':U then do:
      if p-psn-code = 0 then do:
        run ref/cli-grps.w (
                      input parparentproc
                    , input "b-sel,b-mark"
                    , input-output ref-list ) .
        if ref-list <> "" then do:
          FIND buf_cli-grp where recid( buf_cli-grp ) = integer( ref-list ) .
          if can-find( FIRST ub.cli-grp where ub.cli-grp.upper-code = buf_cli-grp.node-code ) then do:
            message
            "Добавлять можно только в группы," skip
            "у которых нет подгрупп." skip
            "Выбирайте другую группу !" view-as alert-box WARNING .
            undo, return error .
          end.
          assign
          to-grp = buf_cli-grp.node-code
          .
          run ref/personi.w (
                         INPUT parparentproc
                        ,input 'ДОБАВЛЕНИЕ':U
                        ,input 0
                        ,input to-grp
                        ,input p-role
                        ,input-output p-rid ) no-error .
          if error-status:error then return error return-value .
        end.
        else do:
          return.
        end.
      end.
      if p-psn-code = ? then do:
        run ref/cli-all.w (
                         input parparentproc
                        ,input "b-sel"
                        ,input 'чел':U
                        ,input 'все':U
                        ,input 'текущие':U
                        ,input ?
                        ,input ",,,,,,NO,,"
                        ,input "lock-cli-type":U
                        ,output ref-list).
        if ref-list = "" then return.
        ri = integer(entry(1, ref-list)) .
        FIND first buf_clients no-lock WHERE recid( buf_clients ) = ri  .
        if g#db-num > 0 then do:
          if p-role = 'C':U then do:
            assign
            v-cashier-code = gbclcode-get-db-role (
                                                    input 'C':U
                                                   ,input g#db-num
                                                   ,input buf_clients.obj-code
                                                   ,input ?
                                                   ,output v-password)
            no-error .
            if v-cashier-code > 0 then do:
              message
              substitute("Данное физическое лицо уже является кассиром в БД &1!"  +
                         "Вы уверены, что хотите дать ему еще один код кассира?&1" +
                         "Это может привести к ошибкам при разборе чеков"
                       , g#db-num)
              view-as alert-box QUESTION buttons YES-NO update glog.
              if not glog then  undo, return.
            end.
          end.
          if p-role = 'S':U then do:
            assign
            v-seller-code = gbclcode-get-db-role ( input 'S':U
                                                  ,input g#db-num
                                                  ,input buf_clients.obj-code
                                                  ,input ?
                                                  ,output v-password)
            no-error .
            if v-seller-code > 0 then do:
              message
              substitute("Данное физическое лицо уже является продавцом в БД &1!"  +
                         "Вы уверены, что хотите дать ему еще один код продавца?&1" +
                         "Это может привести к ошибкам при разборе чеков"
                       , g#db-num)
              view-as alert-box QUESTION buttons YES-NO update glog.
              if not glog then  undo, return.
            end.
          end.
        end.
        assign
        p-psn-code = buf_clients.obj-code
        .
      end.
    end.
  END CASE.
  do
  on error undo, return error
  on stop undo, return error :
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      find first buf_staff exclusive-lock where
              recid(buf_staff) = p-rid.
    end.
    if p-mode = 'ПРОСМОТР':U then do:
      find first buf_staff no-lock where
                recid(buf_staff) = p-rid.
    end.
  end.
  if not (p-mode = 'ДОБАВЛЕНИЕ':U
          and
          p-psn-code = 0)
  or p-mode = 'ИЗМЕНЕНИЕ':U
  or p-mode = ('ДОБАВЛЕНИЕ':U + chr(44) + 'temp') then do:
    assign
    v-db-num = (if p-mode = 'ИЗМЕНЕНИЕ':U
                    or p-mode = 'ПРОСМОТР':U
                    then buf_staff.db-num
                    else (if g#db-num = 0 then ? else g#db-num))
    .
    find first buf_cash-desk no-lock where
            buf_cash-desk.db-num = v-db-num
        and buf_cash-desk.pos-type = 'OMRON-NEW':U no-error.
    if available buf_cash-desk then do:
      v-omron = yes.
    end.
    find first buf_cash-desk no-lock where
            buf_cash-desk.db-num = v-db-num
        and buf_cash-desk.pos-type = 'NCR-GM':U no-error.
    if available buf_cash-desk then do:
      v-ncr = yes.
    end.
    find first buf_cash-desk no-lock where
            buf_cash-desk.db-num = v-db-num
        and buf_cash-desk.pos-type = 'NCR-AS@R':U no-error.
    if available buf_cash-desk then do:
      v-ncr = yes.
    end.
    run cur-time in this-procedure ( output v-today, output v-time).
    case p-role:
      when 'C':U then do:
        assign
        v-staff-code = (if p-mode = 'ПРОСМОТР':U
                        or p-mode = 'ИЗМЕНЕНИЕ':U
                        then buf_staff.staff-code
                        else 0)
        v-level = 'db':U
        v-host-code = 0
        v-obj-type = '':U
        v-obj-code = 0
        v-title = "Данные кассира"
        v-staff-code-label = "Код кассира"
        v-staff-code-format = (if v-omron = yes or v-ncr = yes then ">>>9" else ">>9")
        v-password-option = 2
        v-password-label = "Пароль кассира"
        v-password-format = "X(5)"
        v-notes = substitute("Внимание!&1Диапазон значений <КОДA КАССИРА> и <ПАРОЛЯ> различен для касс и POS разного типа&1"  +
                            "Перед вводом кода и пароля кассира проконсультируйтесь с Вашим администратором"
                            , chr(10))
        v-password = (if p-mode = 'ИЗМЕНЕНИЕ':U
                      or p-mode = 'ПРОСМОТР':U
                      then  buf_staff.password
                      else '':U)
        v-date-start = (if p-mode = 'ИЗМЕНЕНИЕ':U
                      or p-mode = 'ПРОСМОТР':U
                      then  buf_staff.date-start
                      else v-today + 1)
        v-date-end   = (if p-mode = 'ИЗМЕНЕНИЕ':U
                      or p-mode = 'ПРОСМОТР':U
                      then  buf_staff.date-end
                      else 12/31/9999)
        .
      end.
      when 'S':U then do:
        assign
        v-staff-code = (if p-mode = 'ПРОСМОТР':U
                        or p-mode = 'ИЗМЕНЕНИЕ':U
                        then buf_staff.staff-code
                        else 0)
        v-level = 'db':U
        v-host-code = 0
        v-obj-type = '':U
        v-obj-code = 0
        v-title = "Данные продавца (официанта)"
        v-staff-code-label = "Код продавца (официанта)"
        v-staff-code-format = (if v-omron = yes or v-ncr = yes then ">>>9" else ">>9")
        v-password-option = 1
        v-password-label = "Пароль продавца (официанта)"
        v-password-format = "X(3)"
        v-notes = substitute("Внимание!&1Диапазон значений <КОДA ПРОДАВЦА> и <ПАРОЛЯ> различен для касс и POS разного типа&1"  +
                            "Пароль ПРОДАВЦА для некоторых касс и POS не требуется&1" +
                            "Перед вводом кода и пароля продавца (официанта) проконсультируйтесь с Вашим администратором&1"
                            , chr(10))
        v-password = (if p-mode = 'ИЗМЕНЕНИЕ':U
                      or p-mode = 'ПРОСМОТР':U
                      then  buf_staff.password
                      else '':U)
        v-date-start = (if p-mode = 'ИЗМЕНЕНИЕ':U
                      or p-mode = 'ПРОСМОТР':U
                      then  buf_staff.date-start
                      else v-today + 1)
        v-date-end   = (if p-mode = 'ИЗМЕНЕНИЕ':U
                      or p-mode = 'ПРОСМОТР':U
                      then  buf_staff.date-end
                      else 12/31/9999)
        .
      end.
      otherwise do:
        assign
        v-host-code =  (if p-mode = 'ИЗМЕНЕНИЕ':U
                       or p-mode = 'ПРОСМОТР':U
                       then buf_staff.host-code
                       else 0)
        v-obj-type =  (if p-mode = 'ИЗМЕНЕНИЕ':U
                      or p-mode = 'ПРОСМОТР':U
                      then buf_staff.obj-type
                      else '':U)
        v-obj-code =  (if p-mode = 'ИЗМЕНЕНИЕ':U
                      or p-mode = 'ПРОСМОТР':U
                      then buf_staff.obj-code
                      else 0)
          .
      end.
    END CASE.
    run ref/staffi.w (
                     INPUT parparentproc
                    ,INPUT this-procedure
                    ,input p-role
                    ,INPUT p-mode
                    ,input v-level
                    ,INPUT-OUTPUT v-db-num
                    ,INPUT-OUTPUT v-host-code
                    ,INPUT-OUTPUT v-obj-type
                    ,INPUT-OUTPUT v-obj-code
                    ,INPUT v-title
                    ,INPUT v-staff-code-label
                    ,INPUT v-staff-code-format
                    ,INPUT v-password-option
                    ,INPUT v-password-label
                    ,INPUT v-password-format
                    ,INPUT v-notes
                    ,INPUT-OUTPUT v-staff-code
                    ,INPUT-OUTPUT v-password
                    ,input-output v-date-start
                    ,input-output v-date-end
                    ,OUTPUT v-ok
                    ) no-error.
    if not v-ok then undo, return.
    if p-mode = 'ИЗМЕНЕНИЕ':U
    or (p-mode = 'ДОБАВЛЕНИЕ':U and p-psn-code > 0)
    then do:
      run ref/staff01.p (
                     input-output p-rid
                    ,input p-mode
                    ,input no
                    ,input p-role
                    ,input v-staff-code
                    ,input p-psn-code
                    ,input v-level
                    ,input v-date-start
                    ,input v-date-end
                    ,input v-db-num
                    ,input v-host-code
                    ,input v-obj-type
                    ,input v-obj-code
                    ,input (if p-mode = 'ИЗМЕНЕНИЕ':U then buf_staff.work-place else v-work-place)
                    ,input v-password) no-error .
      if error-status:error then do:
        message
        substitute("Ошибка при сохранении записи &1&2&3&2&4"
                   , entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
                   , chr(10)
                   , error-status:get-message(1)
                   , return-value )
        view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    if p-mode = 'ДОБАВЛЕНИЕ':U + chr(44) + 'temp':U then do:
       CASE v-level:
         when 'db':U then do:
            assign
            v-work-place = string(v-db-num, '99999').
         end.
         when 'firm':U then do:
            assign
            v-work-place = string(v-host-code, '99999').
         end.
         when 'object':U then do:
            assign
            v-work-place = v-obj-type + string(v-obj-code, '999999999').
         end.
       END CASE.
       find first tt-staff where
                  tt-staff.role = p-role
             and  tt-staff.role-level = p-role-level
             and  tt-staff.work-place = v-work-place
             and tt-staff.staff-code  = v-staff-code
             and tt-staff.date-start  = v-date-start  no-error.
      if not available tt-staff then do:
        create tt-staff.
        assign
        tt-staff.db-num     = v-db-num
        tt-staff.role       = p-role
        tt-staff.role-level = p-role-level
        tt-staff.work-place = v-work-place
        tt-staff.staff-code  = v-staff-code
        tt-staff.psn-code = p-psn-code
        tt-staff.date-start = v-date-start
        .
      end.
      tt-staff.password = v-password.
    end.
  end.
end.
