block-level on error undo, throw.
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character        no-undo.
define variable vss-revision    as character no-undo init "$Revision: 9263cff4388a, 1753, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Feb 07 16:50:10 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: inc-wthr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/inc-wthr.p $":U .
define variable vss-description as character no-undo init "Процедура автоматического формирования документов по чекам МЦ".
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
define variable parhost-code like ub.sysconf.host-code no-undo .
define variable parobj-type like ub.clients.obj-type no-undo .
define variable parobj-code like ub.clients.obj-code no-undo .
define variable p-auto         as integer no-undo .
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
DEFINE SHARED TEMP-TABLE temp-cre-doc No-UNDO
FIELD chk-type like ub.chk-doc.chk-type
FIELD inter_ like ub.wth-doc.inter_
FIELD exter_ like ub.wth-doc.exter_
FIELD doc-type like ub.wth-doc.doc-type
FIELD ext-doc-type like ub.wth-doc.ext-doc-type
FIELD cli-type like ub.wth-doc.cli-type
FIELD cli-code like ub.wth-doc.cli-code
FIELD out-w-p-code like ub.wth-place.w-p-code
FIELD doc-date like ub.wth-doc.doc-date
FIELD fact-date like ub.wth-doc.fact-date
FIELD shift-date like ub.wth-doc.shift-date
FIELD shift-num like ub.wth-doc.shift-num
FIELD shift-name like ub.wth-doc.shift-name
index pi is unique primary
chk-type
.
DEFINE TEMP-TABLE temp-cash-doc No-UNDO
FIELD chk-type like ub.chk-doc.chk-type
FIELD chk-doc-code like ub.chk-doc.doc-code
FIELD inter_ like ub.wth-doc.inter_
FIELD exter_ like ub.wth-doc.exter_
FIELD doc-type like ub.wth-doc.doc-type
FIELD ext-doc-type like ub.wth-doc.ext-doc-type
FIELD cli-type like ub.wth-doc.cli-type
FIELD cli-code like ub.wth-doc.cli-code
FIELD w-p-code like ub.wth-place.w-p-code
FIELD out-w-p-code like ub.wth-place.w-p-code
FIELD pay-desk like ub.chk-doc.pay-desk
FIELD cashier like ub.chk-doc.cashier
FIELD doc-code like ub.wth-doc.doc-code
FIELD shift-date like ub.wth-doc.shift-date
FIELD shift-num like ub.wth-doc.shift-num
field shift-name like ub.wth-doc.shift-name
FIELD doc-date like ub.wth-doc.doc-date
FIELD fact-date like ub.wth-doc.fact-date
index pi is unique primary
chk-type
pay-desk
cashier
doc-code
.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE VARIABLE v-err-count as integer no-undo .
DEFINE VARIABLE v-all-count as integer no-undo .
define variable v-ok-count as integer no-undo .
DEFINE VARIABLE vardb-num like ub.db.db-num no-undo.
define variable v-view-log as logical no-undo .
define variable v-esm as character no-undo .
define variable v-input-error as logical no-undo .
define variable log-file-name as character no-undo init "inc-wth.log".
define variable v-closed as integer no-undo .
define buffer buf_obj for ub.clients.
define buffer buf_wth-doc for ub.wth-doc.
define buffer auto-wth-doc-lock_batchprocess for ub.batchprocess .
define buffer buf_temp-cre-doc for temp-cre-doc .
define buffer buf_chk-doc for ub.chk-doc.
define temp-table tt-par-dtl  no-undo like ub.wth-par
FIELD q-ty-doc     AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Кол-во по!документу"
FIELD q-ty-fact    AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Количество!факт"
FIELD doc-sum      like ub.wth-line.doc-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по!документу"
FIELD fact-sum     like ub.wth-line.doc-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма!факт"
FIELD sum-gds-rubl like ub.wth-line.sum-gds-rubl  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по связ.!товарам (рубл)"
FIELD sum-gds-base like ub.wth-line.sum-gds-base  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по связ.!товарам (баз.вал.)"
FIELD price-rubl   like ub.wth-line.price-rubl  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Цена товара!(рубл)"
FIELD price-base   like ub.wth-line.price-base  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Цена товара!(баз.вал.)"
FIELD w-p-code     like ub.wth-dtl.w-p-code
FIELD doc-code     like ub.wth-dtl.doc-code
FIELD gds-code     like ub.wth-gds.gds-code
INDEX tt-pi    IS   PRIMARY UNIQUE par-code  w-p-code doc-code  wth-code
INDEX tt-i1                        par-feat par-unit par-val
INDEX tt-i2                        doc-sum  q-ty-doc
.
define temp-table tt-par-dtl-inv  no-undo like ub.wth-par
FIELD q-ty-bef     AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Кол-во план"
FIELD q-ty-aft     AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Кол-во факт"
FIELD sum-bef  like ub.wth-line.bef-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма план"
FIELD sum-aft  like ub.wth-line.aft-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма факт"
FIELD sum-fact  like ub.wth-line.fact-sum FORM "->,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Расхождение"
INDEX tt-pi    IS   PRIMARY UNIQUE par-code
INDEX tt-i1                        par-feat par-unit par-val
INDEX tt-i2                        sum-bef  q-ty-bef
.
if num-entries(p-parameter, chr(4)) <> 4
then do:
  assign
  v-input-error = yes
  v-esm         = substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 4"
                             , num-entries(p-parameter, chr(4))).
  .
end.
else do:
  assign
  parhost-code         = integer(entry(1, p-parameter, chr(4)))
  parobj-type          = entry(2, p-parameter, chr(4))
  parobj-code          = integer(entry(3, p-parameter, chr(4)))
  p-auto               = integer(entry(4, p-parameter, chr(4)))
  no-error .
  if error-status:error then do:
    assign
    v-esm = error-status:get-message(1)
    v-input-error = yes
    .
  end.
end.
if v-input-error = yes then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , chr(10)
                         , v-esm
                         , return-value
                         )).
  assign
  v-view-log = yes.
  if p-auto = 0 then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  substitute('!!!В процессе Обработки документов МЦ произошли ошибки!!!')  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action5   as character no-undo .
  define variable v-printed5       as logical   no-undo .
  run gbl/prnfilen.w
    (input  (substitute('!!!В процессе Обработки документов МЦ произошли ошибки!!!'))
    ,input  0
    ,input  (string("./":U) + 'inc-wth.log')
    ,input  7
    ,output v-user-action5
    ,output v-printed5
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'inc-wth.log').
end.
                        return "error":U.                  end.
end.
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-clsfact AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  parobj-type
    ,input  parobj-code
    ,input  'wthdoc':U
    ,input  'clsfact':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-clsfact
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
delete object v-tth no-error.
FIND FIRST buf_obj No-LOCK WHERE
                buf_obj.obj-type = parobj-type and
                buf_obj.obj-code = parobj-code No-ERROR.
if not avail buf_obj or parobj-type <> 'маг':U then do:
    message vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова parobj-type и/или parobj-code" parobj-type parobj-code
    view-as alert-box ERROR.
    return.
end.
vardb-num = buf_obj.db-num.
for each temp-cash-doc:
  delete temp-cash-doc.
end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run gbl/lock-prc.p
    (input 'awth':U
    ,input parobj-code
    ,input 0
    ,input 0
    ,input parobj-type
    ,input ""
    ,input ""
    ,input (
             "Код объекта" + ",,," +
             "Тип объекта" +  ",,,Формирование автоматических документов МЦ"
           )
    ,input true
    ,buffer auto-wth-doc-lock_batchprocess
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент уже производится формирование автоматических документов МЦ" skip
      view-as alert-box error .
    undo, return error .
  end.
_chk-doc:
for each  buf_temp-cre-doc NO-LOCK,
    each buf_chk-doc EXCLUSIVE-LOCK where
         buf_chk-doc.obj-type = parobj-type and
         buf_chk-doc.obj-code = parobj-code and
         buf_chk-doc.out-code = ? and
         buf_chk-doc.chk-type = buf_temp-cre-doc.chk-type
         :
  v-all-count = v-all-count + 1.
  if not buf_chk-doc.correct then NEXT _chk-doc.
  if buf_temp-cre-doc.shift-date = ? then do:
    if buf_chk-doc.shift-date <> buf_temp-cre-doc.doc-date then NEXT _chk-doc.
  end.
  else do:
    if NOT (buf_chk-doc.shift-date = buf_temp-cre-doc.shift-date AND
            buf_chk-doc.shift-num = buf_temp-cre-doc.shift-num) then NEXT _chk-doc.
  end.
  if buf_chk-doc.chk-type = integer('7':U) then do:
    FIND FIRST temp-cash-doc where
              temp-cash-doc.chk-type = buf_chk-doc.chk-type
          AND temp-cash-doc.pay-desk = buf_chk-doc.pay-desk
          AND temp-cash-doc.cashier = buf_chk-doc.cashier
          and temp-cash-doc.chk-doc-code = buf_chk-doc.doc-code No-ERROR.
  end.
  else do:
    FIND FIRST temp-cash-doc where
              temp-cash-doc.chk-type = buf_chk-doc.chk-type
          AND temp-cash-doc.pay-desk = buf_chk-doc.pay-desk
          AND temp-cash-doc.cashier = buf_chk-doc.cashier  No-ERROR.
  end.
  if not available temp-cash-doc then do:
    run create-new-wth-doc in this-procedure (
                                               input vardb-num
                                              ,input parobj-type
                                              ,input parobj-code
                                              ,input buf_chk-doc.chk-type
                                              ,input buf_chk-doc.pay-desk
                                              ,input buf_chk-doc.cashier
                                              ,input buf_chk-doc.chk-date
                                              ,buffer temp-cash-doc
                                              )no-error .
    if error-status:error then do:
      NEXT _chk-doc.
    end.
  end.
  run str/inc-wth1.p (
                    buffer buf_chk-doc
                  ,input 1
                  ,input temp-cash-doc.doc-code
                  ,INPUT temp-cash-doc.w-p-code
                  ,input temp-cash-doc.out-w-p-code
                  ,input temp-cash-doc.ext-doc-type
                  ,input temp-cash-doc.chk-type
                  ,input yes
                  ) no-error .
  if error-status:error then do:
      run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Ошибка при включении чека &1 в документ МЦ &2&3&4&3&5"                               , buf_chk-doc.doc-code                               , temp-cash-doc.doc-code                               , chr(10)                               , error-status:get-message(1)                               , return-value )                                       ).
    v-err-count = v-err-count + 1.
    NEXT _chk-doc.
  end.
  else do:
    v-ok-count = v-ok-count + 1.
  end.
  run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Формирование автоматических документов МЦ: просмотрено чеков &1&2обработано &3&2"  +                                "из них успешно &4"                              ,v-all-count                               ,chr(10)                               ,v-ok-count + v-err-count                              ,v-ok-count)                                       ).
END.
_temp-cash-doc:
for each temp-cash-doc No-LOCK:
  FIND FIRST buf_wth-doc Exclusive-lock WHERE
             buf_wth-doc.doc-code = temp-cash-doc.doc-code No-ERROR.
  if avail buf_wth-doc
  and not can-find(first ub.wth-line where ub.wth-line.doc-code = buf_wth-doc.doc-code) then do:
     delete buf_wth-doc.
     next _temp-cash-doc.
  end.
  if v-clsfact then do:
    do while
    buf_wth-doc.status_ <> 'факт':U :
      run str/wth-stts.p (
                   input parparentproc
                  ,BUFFER buf_wth-doc
                  ,INPUT "+":U
                  ,INPUT no
                  ,INPUT buf_wth-doc.obj-type
                  ,INPUT buf_wth-doc.oBJ-code
                  ,input log-file-name ) NO-ERROR.
      if error-status:error THEN DO:
        v-view-log = yes.
        next _temp-cash-doc.
      END.
      find first buf_wth-doc exclusive-lock where
               buf_wth-doc.doc-code = temp-cash-doc.doc-code .
      if buf_wth-doc.status_ = 'факт':U then do:
        v-closed = v-closed + 1.
        next _temp-cash-doc.
      end.
    end.
  end.
end.
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Просмотрено чеков МЦ:&1&2" +             "В автодокументы МЦ удалось включить чеков: &3&2"  +           (if v-clsfact then substitute("до статуса &1 удалось закрыть док-тов: &2", 'факт':U, v-closed) else '')         , v-all-count                                       , chr(10)                                     , v-ok-count)                                       ).
procedure create-new-wth-doc :
define input parameter pardb-num like ub.db.db-num no-undo .
define input parameter parobj-type like ub.clients.obj-type no-undo .
define input parameter parobj-code like ub.clients.obj-code no-undo .
define input parameter parchk-type like ub.chk-doc.chk-type no-undo .
define input parameter parpay-desk like ub.chk-doc.pay-desk no-undo .
define input parameter par-cashier like ub.chk-doc.cashier no-undo .
define input parameter p-chk-date  like ub.chk-doc.chk-date no-undo .
define parameter buffer loc-temp-cash-doc for temp-cash-doc.
DEFINE VARIABLE vardoc-rec as recid no-undo.
DEFINE VARIABLE vardoc-code like ub.wth-doc.doc-code no-undo .
define variable v-cashier-psn-code as integer no-undo .
define buffer buf_wth-doc for ub.wth-doc.
define buffer buf_wth-line for ub.wth-line.
define buffer cashier for ub.person.
define buffer cash_wth-place for ub.wth-place.
DEFINE VARIABLE dops as character no-undo .
  do
  on error undo, return error
  :
    assign dops = entry (lookup (string(parchk-type),  '2,3,4,5,7':U) + 1, ',' + 'Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ':U) no-error.
        run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Создание автоматического документа МЦ - &1" +                                  "Касса: &2&1" +                                   "Кассир: &3&1" +                                  "Тип чека МЦ: &4"                                   , chr(10)                                   , parpay-desk                                   , par-cashier                                   , dops)                                       ).
    v-cashier-psn-code = 0.
    assign
    v-cashier-psn-code = gbclcode-is-this-db-role ( input 'C':U, input vardb-num, input par-cashier, input p-chk-date)
    no-error
    .
    if v-cashier-psn-code = 0 then do:
            v-view-log = yes.
      run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("!!!ОШИБКА: В справочнике нет кассира &1",  par-cashier)                                       ).
      return error.
    end.
    find first CASH_WTh-PLACE no-lock where
               CASH_wth-place.obj-type = parobj-type AND
               CASH_wth-place.obj-code = parobj-code AND
               cash_wth-place.cash-desk = parpay-desk No-ERROR.
    if not available cash_wth-place then do:
            v-view-log = yes.
      run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("!!!ОШИБКА: Не определено МХ для кассы &1",  parpay-desk)                                       ).
      return error.
    end.
    FIND FIRST temp-cre-doc No-LOCK WHERE
               temp-cre-doc.chk-type = parchk-type No-ERROR.
    if not available temp-cre-doc then return error.
    vardoc-rec = ?.
    _buf_wth-doc:
    FOR EACH buf_wth-doc No-LOCK WHERE
              buf_wth-doc.obj-type = parobj-type AND
              buf_wth-doc.obj-code = parobj-code AND
              buf_wth-doc.auto-fill = yes AND
              buf_wth-doc.status_ = 'накл':U AND
              buf_wth-doc.exter_ = temp-cre-doc.exter_ AND
              buf_wth-doc.inter_ = temp-cre-doc.inter_ AND
              buf_wth-doc.doc-type = temp-cre-doc.doc-type AND
              buf_wth-doc.cli-type = temp-cre-doc.cli-type AND
              buf_wth-doc.cli-code = temp-cre-doc.cli-code AND
              buf_wth-doc.doc-date = temp-cre-doc.doc-date AND
              buf_wth-doc.shift-date = temp-cre-doc.shift-date AND
              buf_wth-doc.shift-num = temp-cre-doc.shift-num:
      FIND FIRST buf_wth-line No-LOCK WHERE
                 buf_wth-line.doc-code = buf_wth-doc.doc-code No-ERROR.
      if temp-cre-doc.chk-type = integer('7':U) then do:
        if not avail buf_wth-line then do:
          vardoc-rec = recid(buf_wth-doc).
          LEAVE _buf_wth-doc.
        end.
      end.
      else do:
        if not avail buf_wth-line or
          ((buf_wth-line.out-code = temp-cre-doc.out-w-p-code
            OR
            buf_wth-doc.doc-type = 'инв':U)
            AND
          buf_wth-line.w-p-code = cash_wth-place.w-p-code)
          then do:
          vardoc-rec = recid(buf_wth-doc).
          LEAVE _buf_wth-doc.
        end.
      end.
    END.
    if vardoc-rec <> ? then do:
      create loc-temp-cash-doc.
      assign
      loc-temp-cash-doc.chk-type = parchk-type
      loc-temp-cash-doc.inter_ =  temp-cre-doc.inter_
      loc-temp-cash-doc.exter_  =  temp-cre-doc.exter_
      loc-temp-cash-doc.doc-type  =  temp-cre-doc.doc-type
      loc-temp-cash-doc.cli-type  =  temp-cre-doc.cli-type
      loc-temp-cash-doc.cli-code  =  temp-cre-doc.cli-code
      loc-temp-cash-doc.out-w-p-code = temp-cre-doc.out-w-p-code
      loc-temp-cash-doc.w-p-code = cash_wth-place.w-p-code
      loc-temp-cash-doc.pay-desk = parpay-desk
      loc-temp-cash-doc.cashier = par-cashier
      loc-temp-cash-doc.doc-code =  buf_wth-doc.doc-code
      loc-temp-cash-doc.shift-date = buf_wth-doc.shift-date
      loc-temp-cash-doc.shift-num = buf_wth-doc.shift-num
      loc-temp-cash-doc.shift-name = buf_wth-doc.shift-name
      loc-temp-cash-doc.doc-date = buf_wth-doc.doc-date
      loc-temp-cash-doc.fact-date = buf_wth-doc.fact-date
      .
      return.
    end.
    else do:
     _cre-block:
      DO ON ERROR undo _cre-block, return error   :
        vardoc-code = '':U.
        CASE temp-cre-doc.doc-type:
          when 'инв':U then do:
            run str/wth-inv1.p (
                              input yes
                            ,input-output vardoc-rec
                            ,input 'ДОБАВЛЕНИЕ':U
                            ,input vardoc-code
                            ,input parhost-code
                            ,input parobj-type
                            ,input parobj-code
                            ,input temp-cre-doc.doc-date
                            ,input temp-cre-doc.fact-date
                            ,input temp-cre-doc.shift-date
                            ,input temp-cre-doc.shift-num
                            ,input temp-cre-doc.shift-name
                            ,input v-cashier-psn-code
                            ,input v-cashier-psn-code
                            ,input v-cashier-psn-code
                            ,input v-cashier-psn-code
                            ,input v-cashier-psn-code
                            ,input yes
                            ,input 0
                            ,input 0
                            ,input '':U
                            ,input 'накл':U
                            ,input no
                              ) no-error .
          end.
          otherwise do:
            run str/wth-inc1.p (
                              input yes
                            ,input-output vardoc-rec
                            ,input 'ДОБАВЛЕНИЕ':U
                            ,input vardoc-code
                            ,input parhost-code
                            ,input parobj-type
                            ,input parobj-code
                            ,input temp-cre-doc.cli-type
                            ,input temp-cre-doc.cli-code
                            ,input temp-cre-doc.doc-date
                            ,input temp-cre-doc.fact-date
                            ,input temp-cre-doc.shift-date
                            ,input temp-cre-doc.shift-num
                            ,input temp-cre-doc.shift-name
                            ,input v-cashier-psn-code
                            ,input v-cashier-psn-code
                            ,input v-cashier-psn-code
                            ,input temp-cre-doc.doc-type
                            ,input yes
                            ,input temp-cre-doc.exter_
                            ,input temp-cre-doc.inter_
                            ,input ''
                            ,input '':U
                            ,input no
                            ,input 0
                            ,input 0
                            ,input '':U
                            ,input 'накл':U
                            ,input no
                            ,input temp-cre-doc.ext-doc-type
                              ) no-error .
          end.
        end CASE.
        if error-status:error then do:
          run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("!!!Ошибка при создании док-та МЦ:&1&2&1&3"                                                     , chr(10)                                                         , error-status:get-message(1)                                                     , return-value )                                       ).
          undo _cre-block, return error ''.
        end.
        FIND FIRST buf_wth-doc No-LOCK WHERE
                    recid(buf_wth-doc) = vardoc-rec No-ERROR.
        if error-status:error then do:
          undo _cre-block, return error return-value.
        end.
        create loc-temp-cash-doc.
        assign
        loc-temp-cash-doc.chk-type = parchk-type
        loc-temp-cash-doc.inter_ =  temp-cre-doc.inter_
        loc-temp-cash-doc.exter_  =  temp-cre-doc.exter_
        loc-temp-cash-doc.doc-type  =  temp-cre-doc.doc-type
        loc-temp-cash-doc.cli-type  =  temp-cre-doc.cli-type
        loc-temp-cash-doc.cli-code  =  temp-cre-doc.cli-code
        loc-temp-cash-doc.out-w-p-code  =  temp-cre-doc.out-w-p-code
        loc-temp-cash-doc.w-p-code  =  cash_wth-place.w-p-code
        loc-temp-cash-doc.pay-desk  =  parpay-desk
        loc-temp-cash-doc.cashier = par-cashier
        loc-temp-cash-doc.doc-code =  buf_wth-doc.doc-code
        loc-temp-cash-doc.shift-date = buf_wth-doc.shift-date
        loc-temp-cash-doc.shift-num = buf_wth-doc.shift-num
        loc-temp-cash-doc.shift-name = buf_wth-doc.shift-name
        loc-temp-cash-doc.doc-date = buf_wth-doc.doc-date
        loc-temp-cash-doc.fact-date = buf_wth-doc.fact-date
        loc-temp-cash-doc.ext-doc-type = buf_wth-doc.ext-doc-type
        .
        if buf_chk-doc.chk-type = integer('7':U) then do:
          loc-temp-cash-doc.chk-doc-code = buf_chk-doc.doc-code.
        end.
        return.
      END.
    end.
  end.
end procedure.
