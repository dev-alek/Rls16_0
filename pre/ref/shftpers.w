define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER pobj-type like  ub.shift-obj.obj-type no-undo.
DEFINE INPUT PARAMETER pobj-code like  ub.shift-obj.obj-code no-undo.
DEFINE INPUT PARAMETER pshift-date like ub.shift-obj.shift-date no-undo.
DEFINE INPUT PARAMETER pshift-num like  ub.shift-obj.shift-num no-undo.
DEFINE INPUT PARAMETER bttns as char no-UNDO.
DEFINE INPUT PARAMETER call-point as char no-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Процедура выбора персонала смены".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table shft-pers no-undo
FIELD FIO as CHARACTER format "X(40)"
FIELD staff-role AS LOGICAL format "+/ "
FIELD psn-code like ub.person.psn-code
FIELD cashier  as integer
FIELD next-shift as logical
field psn-num like ub.shift-staff.psn-num
index staff-role is primary next-shift
                            staff-role DESCENDING
index pc is unique next-shift psn-code psn-num
.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE BUFFER next-shft-pers for shft-pers.
DEFINE variable add-option as char no-undo.
define variable v-need-rec as recid no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character AS character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-noanshftstaff as logical no-undo .
define variable v-tth as handle no-undo .
define variable v-close as logical no-undo .
define variable par-type as character no-undo .
define variable par-is-cctv as character no-undo .
define variable is-cctv as logical no-undo .
define variable v-vid-action        as integer no-undo .
define variable v-vid-ok            as logical  no-undo .
define variable v-vid-mes           as character no-undo .
define variable v-vid-param         as longchar no-undo .
define variable v-shift-staff-list  as character no-undo .
define variable v-shift-manager     as character no-undo .
define variable conf-par as character no-undo .
define variable v-1C     as logical   no-undo .
DEFINE BUFFER next-shift-obj for shift-obj.
DEFINE BUFFER previous-shift-obj for shift-obj.
DEFINE BUFFER previous-shift-obj2 for shift-obj.
DEFINE MENU MENU-B-add
       MENU-ITEM m-add-ref      LABEL "Из справочника"
       MENU-ITEM m-add-blank    LABEL "Произвольно"   .
DEFINE MENU MENU-B-add-next
       MENU-ITEM m-add-next-ref LABEL "Из справочника"
       MENU-ITEM m-add-next-blank LABEL "Произвольно"   .
DEFINE MENU MENU-BR-staff
       MENU-ITEM m-br-ref       LABEL "Из справочника"
       MENU-ITEM m-br-blank     LABEL "Произвольно"   .
DEFINE MENU MENU-BR-staff-next
       MENU-ITEM m-br-next-ref  LABEL "Из справочника"
       MENU-ITEM m-br-next-blank LABEL "Произвольно"   .
DEFINE BUTTON B-add
     LABEL "Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-add-next
     LABEL "Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-chg
     LABEL "Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-chg-next
     LABEL "Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-del
     LABEL "Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-del-next
     LABEL "Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-mng
     LABEL "Менеджер"
     SIZE 10 BY 1.
DEFINE BUTTON B-mng-next
     LABEL "Менеджер"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 86.4 BY 9.87.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 86.1 BY 6.53.
DEFINE QUERY BR-staff FOR
      shft-pers SCROLLING.
DEFINE QUERY BR-staff-next FOR
      next-shft-pers SCROLLING.
DEFINE BROWSE BR-staff
  QUERY BR-staff SHARE-LOCK NO-WAIT DISPLAY
      shft-pers.FIO column-label " ФИО"
      shft-pers.cashier column-label "Код!кассира"
      shft-pers.staff-role column-label "Менеджер"
      shft-pers.psn-code COLUMN-LABEL "Код!физ.лица"
      ENABLE
      shft-pers.FIO
      shft-pers.cashier
    WITH SEPARATORS SIZE 83.8 BY 7.53
         TITLE "Персонал текущей смены".
DEFINE BROWSE BR-staff-next
  QUERY BR-staff-next SHARE-LOCK NO-WAIT DISPLAY
      next-shft-pers.FIO column-label " ФИО"
      next-shft-pers.cashier column-label "Код!кассира"
      next-shft-pers.staff-role column-label "Менеджер"
      next-shft-pers.psn-code COLUMN-LABEL "Код!физ.лица"
      ENABLE
      NEXt-shft-pers.FIO
      next-shft-pers.cashier
    WITH SEPARATORS SIZE 84.1 BY 4.17
         TITLE "Персонал принимающей смены".
DEFINE FRAME PERS-Frame
     B-exit AT ROW 1 COL 1.1
     b-quit AT ROW 1 COL 11.1
     B-Help AT ROW 1 COL 80
     B-add AT ROW 3 COL 3.9
     B-del AT ROW 3 COL 13.9
     B-chg AT ROW 3 COL 23.9
     B-mng AT ROW 3 COL 33.9
     BR-staff AT ROW 4.3 COL 3.6
     B-add-next AT ROW 13.03 COL 3.9
     B-del-next AT ROW 13.03 COL 13.9
     B-chg-next AT ROW 13.03 COL 23.9
     B-mng-next AT ROW 13.03 COL 33.9
     BR-staff-next AT ROW 14.43 COL 3.3
     RECT-1 AT ROW 2.37 COL 2.4
     RECT-2 AT ROW 12.7 COL 2.3
     SPACE(1.72) SKIP(0.39)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Персонал  смены"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME PERS-Frame:SCROLLABLE       = FALSE
       FRAME PERS-Frame:HIDDEN           = TRUE.
ASSIGN
       B-add:POPUP-MENU IN FRAME PERS-Frame       = MENU MENU-B-add:HANDLE.
ASSIGN
       B-add-next:POPUP-MENU IN FRAME PERS-Frame       = MENU MENU-B-add-next:HANDLE.
ASSIGN
       B-mng-next:HIDDEN IN FRAME PERS-Frame           = TRUE.
ASSIGN
       BR-staff:POPUP-MENU IN FRAME PERS-Frame             = MENU MENU-BR-staff:HANDLE.
ASSIGN
       BR-staff-next:POPUP-MENU IN FRAME PERS-Frame             = MENU MENU-BR-staff-next:HANDLE.
ON END-ERROR OF FRAME PERS-Frame
DO:
  apply "choose" to b-exit in frame PERS-Frame.
  return no-apply.
END.
ON GO OF FRAME PERS-Frame
DO:
    IF FOCUS:NAME <> "B-exit" and FOCUS:NAME <> "B-QUIT" THEN DO:
    RETURN NO-APPLY.
    END.
    run fill-db in this-procedure no-error.
    if error-status:error then return no-apply.
    for each ub.shift-staff no-lock where ub.shift-staff.obj-type = pobj-type
                                      and ub.shift-staff.obj-code = pobj-code
                                      and ub.shift-staff.shift-num = pshift-num
                                      and ub.shift-staff.shift-date = pshift-date
                                      and ub.shift-staff.next-shift = no :
        if ub.shift-staff.staff-role
        then
        assign
            v-shift-manager = ub.shift-staff.name
        .
        else
        assign
            v-shift-staff-list = v-shift-staff-list + (if v-shift-staff-list = "" then "" else ", ") + ub.shift-staff.name
        .
        run trg/userlog.p (
              input 'update':U
            , input 'shift-staff':U
            , input ( buffer ub.shift-staff :handle )
            , input ?
            , input ""
        ) no-error.
        if error-status :error
        then do:
            undo, return no-apply .
        end.
    end.
    find first ub.shift-obj no-lock where ub.shift-obj.obj-type = pobj-type
                                      and ub.shift-obj.obj-code = pobj-code
                                      and ub.shift-obj.shift-num = pshift-num
                                      and ub.shift-obj.shift-date = pshift-date .
    v-vid-action = 52 .
    v-vid-param = "SHOP_NUM=" + string(ub.shift-obj.obj-code) + chr(4) +
                  "SHIFT_NUM=" + string(ub.shift-obj.shift-num) + string(ub.shift-obj.shift-date, "99999999") + chr(4) +
                  "ShiftManager=" + v-shift-manager + chr(4) +
                  "ShiftStaff=" + v-shift-staff-list + chr(4) +
                  "RESULT=0" + chr(4) +
                  "Description=".
    run trg/userlog.p (
          input 'update':U
        , input 'shift-obj':U
        , input ( buffer ub.shift-obj :handle )
        , input v-vid-action
        , input v-vid-param
    ) no-error.
    if error-status :error
    then do:
        undo, return no-apply .
    end.
END.
ON stop OF FRAME PERS-Frame
DO:
    apply "choose" to b-exit in frame PERS-Frame.
  return no-apply.
END.
ON WINDOW-CLOSE OF FRAME PERS-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME PERS-Frame
DO:
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if add-option = "" then
  run gbl/pop-up.p ( input self:handle, input no) no-error.
  if error-status:error then return no-apply.
  run create-pers in this-procedure ( input 0) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-add-next IN FRAME PERS-Frame
DO:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if add-option = "" then
  run gbl/pop-up.p ( input self:handle, input no) no-error.
  run create-pers in this-procedure ( input 1) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-chg IN FRAME PERS-Frame
DO:
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
    if avail shft-pers then do:
        if shft-pers.psn-code <> ? then do:
            MESSAGE "Нельзя изменить эту запись - она была выбрана из справочника"
            VIEW-AS ALERT-BOX ERROR.
            return no-apply.
        end.
      assign
      shft-pers.fio:read-only in browse br-staff = false
      shft-pers.cashier:read-only in browse br-staff = false
      .
      APPLY "ENTRY" to shft-pers.fio in browse br-staff.
    end.
END.
ON CHOOSE OF B-chg-next IN FRAME PERS-Frame
DO:
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
    if avail next-shft-pers then do:
        if next-shft-pers.psn-code <> ? then do:
            MESSAGE "Нельзя изменить эту запись - она была выбрана из справочника"
            VIEW-AS ALERT-BOX ERROR.
            return no-apply.
        end.
      assign
      next-shft-pers.fio:read-only in browse br-staff-next = false
      next-shft-pers.cashier:read-only in browse br-staff-next = false
      .
      APPLY "ENTRY" to br-staff-next.
    end.
END.
ON CHOOSE OF B-del IN FRAME PERS-Frame
DO:
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run delete-pers  in this-procedure ( input 0, buffer shft-pers) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-del-next IN FRAME PERS-Frame
DO:
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run delete-pers  in this-procedure ( input 1, buffer next-shft-pers) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-exit IN FRAME PERS-Frame
DO:
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
    if v-1C
    then do :
      find first shft-pers no-lock where shft-pers.next-shift = no
                                     and shft-pers.psn-code <> -1
                                     no-error .
      if not available shft-pers
      then do :
        message "Включен обмен с 1С. Ввод персонала смены обязателен." view-as alert-box .
        return no-apply .
      end .
    end .
END.
ON CHOOSE OF B-quit IN FRAME PERS-Frame
DO:
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
    if v-1C
    then do :
      find first ub.shift-staff no-lock where ub.shift-staff.obj-type = pobj-type
                                          and ub.shift-staff.obj-code = pobj-code
                                          and ub.shift-staff.shift-num = pshift-num
                                          and ub.shift-staff.shift-date = pshift-date
                                          and ub.shift-staff.next-shift = no
                                          no-error .
      if not available ub.shift-staff
      then do :
        message "Включен обмен с 1С. Ввод персонала смены обязателен." view-as alert-box .
        return no-apply .
      end .
    end .
END.
ON CHOOSE OF B-mng IN FRAME PERS-Frame
DO:
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run mng-pers  in this-procedure ( input 0, buffer shft-pers) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-mng-next IN FRAME PERS-Frame
DO:
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run mng-pers  in this-procedure ( input 1, buffer next-shft-pers) no-error.
  if error-status:error then return no-apply.
END.
ON + OF BR-staff IN FRAME PERS-Frame
DO:
  run mng-pers  in this-procedure ( input 0, buffer shft-pers) no-error.
  if error-status:error then return no-apply.
END.
ON DELETE-CHARACTER OF BR-staff IN FRAME PERS-Frame
DO:
  IF lookup("b-add", bttns) = 0 then return no-apply.
  run delete-pers  in this-procedure ( input 0, buffer shft-pers) no-error.
  if error-status:error then return NO-apply.
END.
ON INSERT-MODE OF BR-staff IN FRAME PERS-Frame
DO:
  IF lookup("b-add", bttns) = 0 then return no-apply.
  run gbl/pop-up.p ( input self:handle, input yes) no-error.
  if error-status:error then return no-apply.
  run create-pers  in this-procedure ( input 0) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF BR-staff IN FRAME PERS-Frame
or mouse-select-dblclick of br-STAFF in frame PERS-Frame DO:
  IF AVAIL SHFT-PERS AND SHFT-PERS.PSN-CODE = ? AND B-add:SENSITIVE IN FRAME PERS-Frame THEN DO:
        apply "entry" to br-staff in frame PERS-Frame.
  END.
END.
ON ROW-LEAVE OF BR-staff IN FRAME PERS-Frame
DO:
  run upd-shft-pers in this-procedure no-error.
  if error-status:error then return no-apply.
return no-apply.
END.
ON + OF BR-staff-next IN FRAME PERS-Frame
DO:
  run mng-pers  in this-procedure ( input 1, buffer next-shft-pers) no-error.
  if error-status:error then return no-apply.
END.
ON DELETE-CHARACTER OF BR-staff-next IN FRAME PERS-Frame
DO:
  IF lookup("b-add-next", bttns) = 0 then return no-apply.
  run delete-pers  in this-procedure ( input 1, buffer next-shft-pers) no-error.
  if error-status:error then return no-apply.
END.
ON INSERT-MODE OF BR-staff-next IN FRAME PERS-Frame
DO:
  IF lookup("b-add-next", bttns) = 0 then return no-apply.
  run gbl/pop-up.p ( input self:handle, input yes) no-error.
  if error-status:error then return no-apply.
  run create-pers in this-procedure ( input 1) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF BR-staff-next IN FRAME PERS-Frame
or mouse-select-dblclick of br-STAFF-next in frame PERS-Frame DO:
  IF AVAIL NEXT-SHFT-PERS AND NEXT-SHFT-PERS.PSN-CODE = ? AND B-add-NEXT:SENSITIVE IN FRAME PERS-Frame THEN DO:
        apply "entry" to br-staff-NEXT in frame PERS-Frame.
  END.
END.
ON CHOOSE OF MENU-ITEM m-add-blank
DO:
  add-option = "blank":U.
  run create-pers in this-procedure ( input 0) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m-add-next-blank
DO:
    add-option = "blank":U.
    run create-pers in this-procedure ( input 1) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m-add-next-ref
DO:
    add-option = "ref":U.
    run create-pers in this-procedure ( input 1) no-error.
    if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m-add-ref
DO:
    add-option = "ref":U.
  run create-pers in this-procedure ( input 0) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m-br-blank
DO:
  add-option = "blank":U.
  run create-pers in this-procedure ( input 0) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m-br-next-blank
DO:
    add-option = "blank":U.
    run create-pers in this-procedure ( input 1) no-error.
    if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m-br-next-ref
DO:
    add-option = "ref":U.
    run create-pers in this-procedure ( input 1) no-error.
    if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m-br-ref
DO:
    add-option = "ref":U.
    run create-pers in this-procedure ( input 0) no-error.
    if error-status:error then return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME PERS-Frame:PARENT eq ?
THEN FRAME PERS-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame PERS-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame PERS-Frame
do:
  apply "help":u to frame PERS-Frame .
end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame PERS-Frame:width - 0.3
                fh            = frame PERS-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame PERS-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame PERS-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame PERS-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame PERS-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame PERS-Frame :height = v-frame-height
          .
          if frame PERS-Frame :scrollable = true
          then do:
            assign
              frame PERS-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame PERS-Frame :scrollable = true
          then do:
            assign
              frame PERS-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame PERS-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame PERS-Frame :height
      v-frame-virtual-height = frame PERS-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame PERS-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame PERS-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame PERS-Frame :scrollable = true
      then do:
        assign
          frame PERS-Frame :virtual-height = frame PERS-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame PERS-Frame :height = frame PERS-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame PERS-Frame :height = frame PERS-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame PERS-Frame :scrollable = true
      then do:
        assign
          frame PERS-Frame :virtual-height = frame PERS-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame PERS-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame PERS-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame PERS-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame PERS-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame PERS-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame PERS-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame PERS-Frame :width = v-frame-width
          .
          if frame PERS-Frame :scrollable = true
          then do:
            assign
              frame PERS-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame PERS-Frame :scrollable = true
          then do:
            assign
              frame PERS-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame PERS-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame PERS-Frame :width
      v-frame-virtual-width = frame PERS-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame PERS-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame PERS-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame PERS-Frame :scrollable = true
      then do:
        assign
          frame PERS-Frame :virtual-width = frame PERS-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame PERS-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame PERS-Frame :width = frame PERS-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame PERS-Frame :scrollable = true
      then do:
        assign
          frame PERS-Frame :virtual-width = frame PERS-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame PERS-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame PERS-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame PERS-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame PERS-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame PERS-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame PERS-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame PERS-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame PERS-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame PERS-Frame :height
      v-col-delta = v-new-col - frame PERS-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame PERS-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame PERS-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame PERS-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame PERS-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame PERS-Frame :width
      v-diasize-current-frame-height = frame PERS-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame PERS-Frame
    :
      assign
        v-diasize-orig-frame-height = frame PERS-Frame :height
        v-diasize-orig-frame-width  = frame PERS-Frame :width
        v-diasize-browse-handle     = browse BR-staff :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame PERS-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
on end-error of SHFT-PERS.FIO, SHFT-PERS.CASHIER In browse br-STAFF do:
  disp SHFT-PERS.FIO SHFT-PERS.CASHIER with browse br-STAFF.
  return no-apply.
end.
on end-error of NEXT-SHFT-PERS.FIO, NEXT-SHFT-PERS.CASHIER In browse br-STAFF-NEXT do:
  disp NEXT-SHFT-PERS.FIO NEXT-SHFT-PERS.CASHIER with browse br-STAFF-NEXT.
  return no-apply.
end.
On RETURN OF shft-pers.cashier in browse br-staff
OR RETURN OF shft-pers.FIO in browse br-staff
OR TAB OF shft-pers.cashier in browse br-staff
DO:
  run upd-shft-pers in this-procedure no-error.
  if error-status:error then return no-apply.
  return no-apply.
end.
On RETURN OF next-shft-pers.cashier in browse br-staff-next
OR RETURN OF next-shft-pers.FIO in browse br-staff-next
OR TAB OF next-shft-pers.cashier in browse br-staff-next
DO:
  run upd-NEXT-shft-pers in this-procedure no-error.
  if error-status:error then return no-apply.
 return no-apply.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  FIND FIRST ub.shift-obj SHARE-LOCK WHERE
             ub.shift-obj.obj-type = pobj-type AND
             ub.shift-obj.obj-code = pobj-code AND
             ub.shift-obj.shift-num = pshift-num AND
             ub.shift-obj.shift-date = pshift-date NO-ERROR.
  IF NOT AVAIL shift-obj then do:
    message
    vss-workfile vss-revision vss-description skip
    "Отсутствует запись о смене на объекте" skip
    "объект" pobj-type pobj-code
    "смена" pshift-date "порядок" pshift-num
    view-as alert-box ERROR.
    return error.
  END.
  IF call-point = 'смена-объект-откр':U then do:
    if can-find(first ub.shift-staff no-lock where
                      ub.shift-staff.obj-type = pobj-type AND
                      ub.shift-staff.obj-code = pobj-code AND
                      ub.shift-staff.shift-num = pshift-num AND
                      ub.shift-staff.shift-date = pshift-date) then
    call-point = "".
    else do:
      FIND LAST  previous-shift-obj SHARE-LOCK WHERE
                previous-shift-obj.obj-type = pobj-type
            AND previous-shift-obj.obj-code = pobj-code
            AND (previous-shift-obj.shift-date = pshift-date
            AND previous-shift-obj.shift-num < pshift-num) use-index pi no-error.
      FIND LAST  previous-shift-obj2 SHARE-LOCK WHERE
                previous-shift-obj2.obj-type = pobj-type
            AND previous-shift-obj2.obj-code = pobj-code
            AND previous-shift-obj2.shift-date < pshift-date use-index pi no-error.
      v-need-rec = ?.
      if available previous-shift-obj then do:
        v-need-rec = recid(previous-shift-obj).
      end.
      else do:
        if available previous-shift-obj2 then do:
          v-need-rec = recid(previous-shift-obj2).
        end.
      end.
      if v-need-rec <> ? then do:
        find first previous-shift-obj where recid(previous-shift-obj) = v-need-rec.
      end.
    end.
  end.
  FIND first next-shift-obj NO-LOCK WHERE
             recid(next-shift-obj) = recid(shift-obj) NO-ERROR.
  FIND NEXT  next-shift-obj SHARE-LOCK WHERE
             next-shift-obj.obj-type = pobj-type AND
             next-shift-obj.obj-code = pobj-code
                use-index pi NO-ERROR.
  if avail next-shift-obj then do:
    if next-shift-obj.status_ = 'ожд':U then release next-shift-obj.
    else if next-shift-obj.status_ = 'зкр':U or next-shift-obj.status_ = 'тек':U then
    bttns = replace(bttns, "b-add-next", "").
  end.
  run adm/shattri.p (
    input "get":U
    ,input  pobj-type
    ,input  pobj-code
    ,input  'staff':U
    ,input  'noanshftstaff':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-noanshftstaff
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  delete object v-tth no-error.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-erpRN'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  NO
  ,output conf-par
  ,output par-type
  ) no-error .
  IF not error-status:error and conf-par = "yes":U
  then do:
    v-1C = true .
  end .
  else do :
    v-1C = false .
  end .
  RUN MYenable in this-procedure .
  WAIT-FOR GO OF FRAME PERS-Frame.
END.
RUN disable_UI in this-procedure .
PROCEDURE Create-pers :
DEFINE INPUT PARAMETER pnext-shift as logical no-undo.
define variable cli-list as char no-undo.
define variable cli-rec as recid no-undo.
define variable ii as integer no-undo.
define variable for-name as char no-undo.
define buffer loc-shft-pers for shft-pers.
define buffer buf_staff for ub.staff.
if add-option = "" then return error.
CASE add-option:
  when "ref":U then do:
    run ref/staffs.w ( input parparentproc
                    , input (if pnext-shift then "b-sel" else "b-sel,b-mark")
                    , input 'C':U
                    , input v-cntxt-db-num
                    , input 0
                    , output cli-list ) .
    if cli-list <> "" then do:
        DO ii = 1 to NUM-ENTRIES(cli-list):
            cli-rec = integer(entry(ii, cli-list)).
            FIND FIRSt buf_staff No-LOCK WHERE
                       recid(buf_staff) = cli-rec No-ERROR.
            if not avail buf_staff then do:
                add-option = "".
                return error substitute("Не найден кассир - recid &1", cli-rec).
            end.
            FIND FIRSt ub.person No-LOCK WHERE
                       ub.person.psn-code  = buf_staff.psn-code No-ERROR.
            if not avail person then do:
                add-option = "".
                return error.
            end.
            FIND FIRSt ub.clients No-LOCK WHERE
                       ub.clients.obj-type = 'чел':U AND
                       ub.clients.obj-code = ub.person.psn-code No-ERROR.
            if not avail ub.clients then do:
                add-option = "".
                return error.
            end.
            FIND FIRST loc-shft-pers No-LOCK WHERE
                       loc-shft-pers.psn-code = person.psn-code AND
                       loc-shft-pers.next-shift = pnext-shift No-ERROR.
            if not avail loc-shft-pers then do:
                create loc-shft-pers.
                assign
                loc-shft-pers.FIO = clients.obj-name + chr(32) +
                                person.name1 + chr(32) + person.name2
                loc-shft-pers.psn-code = buf_staff.psn-code
                loc-shft-pers.cashier  = buf_staff.staff-code
                loc-shft-pers.next-shift = pnext-shift
                loc-shft-pers.staff-role = if pnext-shift then yes else no
                CLI-REC = RECID(loc-shft-pers)
                .
                RELEASE LOC-SHFT-PERS.
            end.
            else do:
                message substitute("&1 &2 &3 уже входит в состав персонала &4"
                                   , clients.obj-name
                                   , person.name1
                                   , person.name2
                                   , (if NOT pnext-shift
                                    then "передающей смены"
                                    else "принимающей смены"))
                view-as alert-box ERROR.
            end.
        END.
    end.
    else do:
      undo, return error .
    end.
  END.
  WHEN "blank":U then do:
    if v-noanshftstaff then do:
      message
      "Для данного объекта действует запрет на ввод произвольных данных по персоналу"
      view-as alert-box error .
      undo, return error .
    end.
    run gbl/d-prompt.w (
      'title=':u + "Введите ФИО оператора или старшего по смене" + '\':u
    + 'text1=':u + " ФИО" + '\':u
    + 'format=' + "X(40)" + '\':u
    + 'type=' + 'C':U + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u
    + 'readonly=no\':u
    , input-output for-name
    ).
  if return-value = 'false':u then do:
    add-option = "".
    return error.
  end.
    create loc-shft-pers.
    assign
    loc-shft-pers.cashier = 0
    loc-shft-pers.psn-code = ?
    loc-shft-pers.fio = for-name
    loc-shft-pers.next-shift = pnext-shift
    loc-shft-pers.staff-role = if pnext-shift then yes else no
    cli-rec = recid(loc-shft-pers)
    .
    release loc-shft-pers.
    if NOT pnext-shift then do:
      assign
      shft-pers.fio:read-only in browse br-staff = false
      shft-pers.cashier:read-only in browse br-staff = false
      .
    end.
    else do:
      assign
      next-shft-pers.fio:read-only in browse br-staff-next = false
      next-shft-pers.cashier:read-only in browse br-staff-next = false
      .
    end.
    add-option = "".
  END.
END CASE.
    if NOT pnext-shift then do:
        OPEN QUERY BR-staff FOR EACH shft-pers       WHERE shft-pers.next-shift = no SHARE-LOCK     BY shft-pers.staff-role DESCENDING.
        reposition br-staff to recid cli-rec no-error.
        apply "entry" to br-staff in frame PERS-Frame.
    end.
    else do:
        OPEN QUERY BR-staff-next FOR EACH next-shft-pers       WHERE next-shft-pers.next-shift = yes SHARE-LOCK     BY next-shft-pers.staff-role DESCENDING.
        reposition br-staff-next to recid cli-rec no-error.
        DISABLE b-add-next with frame PERS-Frame.
        apply "entry" to br-staff-next in frame PERS-Frame.
    end.
END PROCEDURE.
PROCEDURE delete-pers :
DEFINE INPUT PARAMETER pnext-shift as logical no-undo.
DEFINE PARAMETER BUFFER loc-shft-pers for shft-pers.
define variable glog as logical no-undo .
  if avail loc-shft-pers then do:
  glog = yes.
  message "Удалить "
  (if NOT pnext-shift
   then shft-pers.fio
   else next-shft-pers.fio)
   "из состава персонала"
  (if NOT pnext-shift
   then "передающей смены"
   else "принимающей смены")
    "?"
   view-as alert-box question buttons OK-Cancel update glog.
  if glog <> true then return error.
  delete loc-shft-pers.
  if NOT pnext-shift then do:
      OPEN QUERY BR-staff FOR EACH shft-pers       WHERE shft-pers.next-shift = no SHARE-LOCK     BY shft-pers.staff-role DESCENDING.
      reposition br-staff to row 1 no-error.
      apply "entry" to br-staff in frame PERS-Frame.
  end.
  else do:
      OPEN QUERY BR-staff-next FOR EACH next-shft-pers       WHERE next-shft-pers.next-shift = yes SHARE-LOCK     BY next-shft-pers.staff-role DESCENDING.
      reposition br-staff-next to row 1 no-error.
      apply "entry" to br-staff-next in frame PERS-Frame.
      ENABLE b-add-next with frame PERS-Frame.
  end.
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME PERS-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-quit B-Help RECT-1 RECT-2 B-add B-del B-chg B-mng BR-staff
         B-add-next B-del-next B-chg-next BR-staff-next
      WITH FRAME PERS-Frame.
  Display B-exit with frame PERS-Frame .
  VIEW FRAME PERS-Frame.
  OPEN QUERY BR-staff FOR EACH shft-pers       WHERE shft-pers.next-shift = no SHARE-LOCK     BY shft-pers.staff-role DESCENDING.    OPEN QUERY BR-staff-next FOR EACH next-shft-pers       WHERE next-shft-pers.next-shift = yes SHARE-LOCK     BY next-shft-pers.staff-role DESCENDING.
END PROCEDURE.
PROCEDURE fill-db :
define variable for-psn-num like ub.shift-staff.psn-num no-undo init 0.
define buffer buf_shift-staff for ub.shift-staff.
    FOR EACH shft-pers NO-LOCK where
         shft-pers.next-shift = no and
         shft-pers.psn-code <> -1
         by shft-pers.staff-role
         by shft-pers.fio:
       FIND FIRST buf_shift-staff where
                  buf_shift-staff.OBJ-TYPE = POBJ-TYPE and
                  buf_shift-staff.obj-code = pobj-code AND
                  buf_shift-staff.shift-num = pshift-num AND
                  buf_shift-staff.shift-date = pshift-date AND
                  buf_shift-staff.next-shift = no AND
                  buf_shift-staff.psn-num = for-psn-num no-error.
        if not avail buf_shift-staff then do:
            create buf_shift-staff.
            assign
            buf_shift-staff.obj-type = pobj-type
            buf_shift-staff.obj-code = pobj-code
            buf_shift-staff.shift-num = pshift-num
            buf_shift-staff.shift-name = shift-obj.shift-name
            buf_shift-staff.shift-date = pshift-date
            buf_shift-staff.psn-num = for-psn-num
            buf_shift-staff.next-shift = no
            .
        end.
        if avail buf_shift-staff THEN DO:
            ASSIGN
            buf_shift-staff.NAME = SHft-pers.fio
            buf_shift-staff.psn-code = shft-pers.psn-code
            buf_shift-staff.cashier = shft-pers.cashier
            buf_shift-staff.staff-role = shft-pers.staff-role
            .
        END.
        for-psn-num = for-psn-num + 1.
    END.
    FOR EACH buf_shift-staff where
             buf_shift-staff.OBJ-TYPE = POBJ-TYPE and
             buf_shift-staff.obj-code = pobj-code AND
             buf_shift-staff.shift-num = pshift-num AND
             buf_shift-staff.shift-date = pshift-date AND
             buf_shift-staff.next-shift = no AND
             buf_shift-staff.psn-num >= for-psn-num:
        delete buf_shift-staff.
    END.
    for-psn-num = 0.
    FOR EACH shft-pers NO-LOCK where
      shft-pers.next-shift = yes
      by shft-pers.staff-role
      by shft-pers.fio:
        FIND FIRST buf_shift-staff where
                  buf_shift-staff.OBJ-TYPE = POBJ-TYPE and
                  buf_shift-staff.obj-code = pobj-code AND
                  buf_shift-staff.shift-num = pshift-num AND
                  buf_shift-staff.shift-date = pshift-date AND
                  buf_shift-staff.next-shift = yes AND
                  buf_shift-staff.psn-num = for-psn-num no-error.
        if not avail buf_shift-staff then do:
            create buf_shift-staff.
            assign
            buf_shift-staff.obj-type   = pobj-type
            buf_shift-staff.obj-code   = pobj-code
            buf_shift-staff.shift-num  = pshift-num
            buf_shift-staff.shift-name = shift-obj.shift-name
            buf_shift-staff.shift-date = pshift-date
            buf_shift-staff.psn-num    = for-psn-num
            buf_shift-staff.next-shift = yes
            .
        end.
    if avail buf_shift-staff THEN DO:
        ASSIGN
        buf_shift-staff.NAME = SHft-pers.fio
        buf_shift-staff.next-shift = shft-pers.next-shift
        buf_shift-staff.cashier = shft-pers.cashier
        buf_shift-staff.staff-role = shft-pers.staff-role
         buf_shift-staff.psn-code = shft-pers.psn-code
        .
    END.
    for-psn-num = for-psn-num + 1.
    END.
    FOR EACH buf_shift-staff where
              buf_shift-staff.OBJ-TYPE = POBJ-TYPE and
              buf_shift-staff.obj-code = pobj-code AND
              buf_shift-staff.shift-num = pshift-num AND
              buf_shift-staff.shift-date = pshift-date AND
              buf_shift-staff.next-shift = yes AND
              buf_shift-staff.psn-num >= for-psn-num:
        delete buf_shift-staff.
    END.
    for-psn-num = 0.
    if avail next-shift-obj and next-shift-obj.status_ <> 'зкр':U then do:
        FOR EACH shft-pers NO-LOCK where
         shft-pers.next-shift = yes
         by shft-pers.staff-role
         by shft-pers.fio:
           FIND FIRST buf_shift-staff where
                      buf_shift-staff.OBJ-TYPE = POBJ-TYPE and
                      buf_shift-staff.obj-code = pobj-code AND
                      buf_shift-staff.shift-num = next-shift-obj.shift-num AND
                      buf_shift-staff.shift-date = next-shift-obj.shift-date AND
                      buf_shift-staff.next-shift = no AND
                      buf_shift-staff.psn-num = for-psn-num no-error.
            if not avail buf_shift-staff then do:
                create buf_shift-staff.
                assign
                buf_shift-staff.obj-type   = pobj-type
                buf_shift-staff.obj-code   = pobj-code
                buf_shift-staff.shift-num  = next-shift-obj.shift-num
                buf_shift-staff.shift-name = next-shift-obj.shift-name
                buf_shift-staff.shift-date = next-shift-obj.shift-date
                buf_shift-staff.psn-num    = for-psn-num
                buf_shift-staff.next-shift = no
                .
            end.
          if avail buf_shift-staff THEN DO:
              ASSIGN
              buf_shift-staff.NAME = SHft-pers.fio
              buf_shift-staff.next-shift = no
              buf_shift-staff.cashier = shft-pers.cashier
              buf_shift-staff.staff-role = shft-pers.staff-role
              buf_shift-staff.psn-code = shft-pers.psn-code
              .
          END.
        for-psn-num = for-psn-num + 1.
        END.
        FOR EACH buf_shift-staff where
                  buf_shift-staff.OBJ-TYPE = POBJ-TYPE and
                  buf_shift-staff.obj-code = pobj-code AND
                  buf_shift-staff.shift-num = next-shift-obj.shift-num AND
                  buf_shift-staff.shift-date = next-shift-obj.shift-date AND
                  buf_shift-staff.next-shift = no AND
                  buf_shift-staff.psn-num >= for-psn-num:
            delete buf_shift-staff.
        END.
    end.
END PROCEDURE.
PROCEDURE fill-table :
DEFINE OUTPUT PARAMETER find-mng-next as logical no-undo.
define buffer buf_shift-staff for ub.shift-staff.
for each shft-pers:
    delete shft-pers.
end.
if call-point = 'смена-объект-откр':U and avail previous-shift-obj then do:
  FOR EACH buf_shift-staff No-LOCK WHERE
          buf_shift-staff.obj-type = pobj-type AND
          buf_shift-staff.obj-code = pobj-code AND
          buf_shift-staff.shift-num = previous-shift-obj.shift-num AND
          buf_shift-staff.shift-date = previous-shift-obj.shift-date AND
          buf_shift-staff.next-shift = yes use-index pi:
          create shft-pers.
          assign
          shft-pers.psn-code = buf_shift-staff.psn-code
          shft-pers.cashier = buf_shift-staff.cashier
          shft-pers.fio = buf_shift-staff.name
          shft-pers.staff-role = buf_shift-staff.staff-role
          shft-pers.next-shift = no
          .
  END.
end.
else
FOR EACH buf_shift-staff No-LOCK WHERE
         buf_shift-staff.obj-type = pobj-type AND
         buf_shift-staff.obj-code = pobj-code AND
         buf_shift-staff.shift-num = pshift-num AND
         buf_shift-staff.shift-date = pshift-date AND
         buf_shift-staff.next-shift = no use-index pi:
         create shft-pers.
         assign
         shft-pers.psn-code = buf_shift-staff.psn-code
         shft-pers.cashier = buf_shift-staff.cashier
         shft-pers.fio = buf_shift-staff.name
         shft-pers.staff-role = buf_shift-staff.staff-role
         shft-pers.next-shift = buf_shift-staff.next-shift
         .
END.
IF AVAIL next-shift-obj then do:
  FOR EACH buf_shift-staff No-LOCK WHERE
          buf_shift-staff.obj-type = next-shift-obj.obj-type AND
          buf_shift-staff.obj-code = next-shift-obj.obj-code AND
          buf_shift-staff.shift-num = next-shift-obj.shift-num AND
          buf_shift-staff.shift-date = next-shift-obj.shift-date AND
          buf_shift-staff.staff-role = yes AND
          buf_shift-staff.next-shift = no use-index pi:
          create shft-pers.
          assign
          shft-pers.psn-code = buf_shift-staff.psn-code
          shft-pers.cashier = buf_shift-staff.cashier
          shft-pers.fio = buf_shift-staff.name
          shft-pers.staff-role = buf_shift-staff.staff-role
          shft-pers.next-shift = yes
          .
    find-mng-next = yes.
  END.
end.
else
FOR EACH buf_shift-staff No-LOCK WHERE
         buf_shift-staff.obj-type = pobj-type AND
         buf_shift-staff.obj-code = pobj-code AND
         buf_shift-staff.shift-num = pshift-num AND
         buf_shift-staff.shift-date = pshift-date AND
         buf_shift-staff.next-shift = yes use-index pi:
         create shft-pers.
         assign
         shft-pers.psn-code = buf_shift-staff.psn-code
         shft-pers.cashier = buf_shift-staff.cashier
         shft-pers.fio = buf_shift-staff.name
         shft-pers.staff-role = buf_shift-staff.staff-role
         shft-pers.next-shift = buf_shift-staff.next-shift
         .
    find-mng-next = yes.
END.
END PROCEDURE.
PROCEDURE Mng-pers :
DEFINE INPUT PARAMETER pnext-shift as integer no-undo.
DEFINE PARAMETER BUFFER loc-shft-pers for shft-pers.
define variable cli-rec as recid no-undo.
define buffer b-shft-pers for shft-pers.
if avail loc-shft-pers then do:
   DO TRANSACTION ON ERROR UNDO, return error:
    if loc-shft-pers.staff-role = no THEN DO:
        FOR EACH b-shft-pers where
                 b-shft-pers.next-shift = loc-shft-pers.next-shift AND
                 b-shft-pers.staff-role = yes:
            assign
            b-shft-pers.staff-role = no.
        END.
    end.
    assign
    loc-shft-pers.staff-role = NOT loc-shft-pers.staff-role
    cli-rec = recid(loc-shft-pers)
    .
    END.
   if pnext-shift = 0 then do:
    OPEN QUERY BR-staff FOR EACH shft-pers       WHERE shft-pers.next-shift = no SHARE-LOCK     BY shft-pers.staff-role DESCENDING.
    reposition br-staff to recid cli-rec no-error.
    apply "entry" to br-staff in frame PERS-Frame.
   end.
   else do:
    OPEN QUERY BR-staff-next FOR EACH next-shft-pers       WHERE next-shft-pers.next-shift = yes SHARE-LOCK     BY next-shft-pers.staff-role DESCENDING.
    reposition br-staff-NEXT to recid cli-rec no-error.
    apply "entry" to br-staff-next in frame PERS-Frame.
   end.
end.
END PROCEDURE.
PROCEDURE MyEnable :
define variable varshift-name as character no-undo .
define variable varshift-name-next as character no-undo .
define variable varshift-name-num as character no-undo .
define variable varshift-name-num-next as character no-undo .
define variable glog as logical no-undo .
define variable v-obj-db-num as integer no-undo .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  pobj-type
  ,input  pobj-code
  ,output v-obj-db-num
  )  .
ASSIGN b-add:POPUP-MENU IN FRAME PERS-Frame = MENU menu-b-add:HANDLE.
ASSIGN b-add:MENU-MOUSE = 1.
ASSIGN b-add-next:POPUP-MENU IN FRAME PERS-Frame = MENU menu-b-add-next:HANDLE.
ASSIGN b-add-next:MENU-MOUSE = 1.
if lookup("b-add", bttns) > 0 and v-obj-db-num = v-cntxt-db-num then do:
  assign
  B-add:POPUP-MENU IN FRAME PERS-Frame       = MENU MENU-B-add:HANDLE
  BR-staff:POPUP-MENU IN FRAME PERS-Frame             = MENU MENU-BR-staff:HANDLE
  .
end.
else do:
  assign
  B-add:POPUP-MENU IN FRAME PERS-Frame       = ?
  BR-staff:POPUP-MENU IN FRAME PERS-Frame    = ?
  .
end.
if lookup("b-add-next", bttns) > 0 and v-obj-db-num = v-cntxt-db-num then do:
  ASSIGN
  B-add-next:POPUP-MENU IN FRAME PERS-Frame       = MENU MENU-B-add-next:HANDLE
  BR-staff-next:POPUP-MENU IN FRAME PERS-Frame    = MENU MENU-BR-staff-next:HANDLE
  .
end.
else do:
  ASSIGN
  B-add-next:POPUP-MENU IN FRAME PERS-Frame       = ?
  BR-staff-next:POPUP-MENU IN FRAME PERS-Frame    = ?
  .
end.
ENABLE
B-exit
b-quit
B-Help
RECT-1
RECT-2
B-add when lookup("b-add", bttns) > 0 and v-obj-db-num = v-cntxt-db-num
B-del when lookup("b-add", bttns) > 0 and v-obj-db-num = v-cntxt-db-num
b-mng when lookup("b-add", bttns) > 0 and v-obj-db-num = v-cntxt-db-num
b-chg when lookup("b-add", bttns) > 0 and v-obj-db-num = v-cntxt-db-num
BR-staff
B-add-next when lookup("b-add-next", bttns) > 0 and v-obj-db-num = v-cntxt-db-num
B-del-next when lookup("b-add-next", bttns) > 0 and v-obj-db-num = v-cntxt-db-num
b-chg-next when lookup("b-add-next", bttns) > 0 and v-obj-db-num = v-cntxt-db-num
BR-staff-next
WITH FRAME PERS-Frame.
VIEW FRAME PERS-Frame.
run fill-table in this-procedure ( output glog) no-error.
if glog then
disable b-add-next with frame PERS-Frame.
OPEN QUERY BR-staff FOR EACH shft-pers       WHERE shft-pers.next-shift = no SHARE-LOCK     BY shft-pers.staff-role DESCENDING.    OPEN QUERY BR-staff-next FOR EACH next-shft-pers       WHERE next-shft-pers.next-shift = yes SHARE-LOCK     BY next-shft-pers.staff-role DESCENDING.
assign
shft-pers.fio:read-only in browse br-staff = true
shft-pers.cashier:read-only in browse br-staff = true
.
assign
next-shft-pers.fio:read-only in browse br-staff-next = true
next-shft-pers.cashier:read-only in browse br-staff-next = true
.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_shiftnam in g#lib-trn3
  (
     input pobj-type
  ,  input pobj-code
  ,  input pshift-date
  ,  input pshift-num
  , output varshift-name
  , output varshift-name-num
  )        no-error .
if available next-shift-obj then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_shiftnam in g#lib-trn3
  (
     input pobj-type
  ,  input pobj-code
  ,  input next-shift-obj.shift-date
  ,  input next-shift-obj.shift-num
  , output varshift-name-next
  , output varshift-name-num-next
  )        no-error .
end.
assign
MENU-ITEM m-add-blank:sensitive   in MENU MENU-B-add = not v-noanshftstaff
MENU-ITEM m-add-next-blank:sensitive in menu menu-b-add-next = not v-noanshftstaff
MENU-ITEM m-br-blank:sensitive in menu menu-br-staff = not v-noanshftstaff
MENU-ITEM m-br-next-blank:sensitive in menu menu-br-staff-next = not v-noanshftstaff
.
ASSIGN
browse br-staff:title = substitute("&1 &2 &3"
                                    , browse br-staff:title
                                    , string(pshift-date, "99/99/9999")
                                    , varshift-name-num)
browse br-staff-next:title = substitute("&1 &2 &3"
                                        , browse br-staff-next:title
                                        , (if available next-shift-obj
                                          then string(next-shift-obj.shift-date, "99/99/9999")
                                          else '':U)
                                        , (if available next-shift-obj
                                          then  varshift-name-num-next
                                          else '':U) )
.
if b-add:sensitive in frame PERS-Frame then do:
  APPLY "ENTRY" to b-add.
end.
if lookup("b-add", bttns) = 0
and lookup("b-add-next", bttns) = 0 then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
  hide
  b-exit in frame PERS-Frame
  .
end.
END PROCEDURE.
PROCEDURE upd-next-shft-pers :
  IF AVAIL next-shft-pers THEN DO:
  IF next-shft-pers.PSN-CODE <> ? THEN DO:
    MESSAGE "Нельзя изменить эту запись - она была выбрана из справочника"
    VIEW-AS ALERT-BOX ERROR.
    DISPLAY
    next-shft-pers.fio
    next-shft-pers.cashier
    with browse br-staff-next
    .
    RETURN error.
  END.
  assign
  next-shft-pers.fio = next-shft-pers.fio:screen-value in browse br-staff-next
  next-shft-pers.cashier = integer(next-shft-pers.cashier:screen-value in browse br-staff-next)
  .
  DISPLAY
  next-shft-pers.fio
  next-shft-pers.cashier
  with browse br-staff-next
  .
  assign
  next-shft-pers.fio:read-only in browse br-staff-next = true
  next-shft-pers.cashier:read-only in browse br-staff-next = true
  .
  end.
  run gbl/frcclick.p (
                        input br-staff-next:handle in frame PERS-Frame
                       ,input next-shft-pers.staff-role:handle in browse br-staff-next
                       ,input no) no-error.
END PROCEDURE.
PROCEDURE upd-shft-pers :
  IF AVAIL SHFT-PERS THEN DO:
  IF SHFT-PERS.PSN-CODE <> ? THEN DO:
    MESSAGE "Нельзя изменить эту запись - она была выбрана из справочника"
    VIEW-AS ALERT-BOX ERROR.
    DISPLAY
    shft-pers.fio
    shft-pers.cashier
    with browse br-staff
    .
    RETURN error.
  END.
  assign
  shft-pers.fio = shft-pers.fio:screen-value in browse br-staff
  shft-pers.cashier = integer(shft-pers.cashier:screen-value in browse br-staff)
  .
  DISPLAY
  shft-pers.fio
  shft-pers.cashier
  with browse br-staff
  .
  assign
  shft-pers.fio:read-only in browse br-staff = true
  shft-pers.cashier:read-only in browse br-staff = true
  .
  end.
  run gbl/frcclick.p (
                       input br-staff:handle in frame PERS-Frame
                      ,input shft-pers.staff-role:handle in browse br-staff
                      ,input no) no-error.
END PROCEDURE.
