block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур проверки валидности чека".
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
define new global shared variable g#libchkvl as handle no-undo .
function libchkvl_right-netto-sign returns integer ( input p-chk-type as integer) in G#libchkvl.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2dr-flddf: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define  temp-table libchkvl_context  no-undo
field parparentproc       as widget-handle
field p-log-handle        as handle
field p-log-file-name     as character
field view-log            as logical
field ll                  as integer
field tt-wd-bh            as handle
field pos-type            as character
field cash-num            as integer
field obj-type            as character init 'маг':U
field obj-code            as integer
field db-num              as integer
field r-b                 as character
field host-code           as integer
field base-code           as integer
field cre-pay             as integer
field is-catering         as logical
field is-cdinv            as logical
field is-ptrl             as logical
field is-wth              as logical
field process-sale        as logical
field dc-mask             as logical
field card-by-mask        as logical
field sclspref            as character
field scpgpref            as character
field scpgpref-pre        as character
field doc-prt             as logical
field shift-on            as logical
field cas-shft            as logical
field t-shft              as integer
field v-shft              as integer
field ptrl-check          as logical
field annu-check          as logical
field z-check             as logical
field hnum                as logical
field is-100-discnt       as logical
field zero-cashier        as integer
field rnd-znak            as integer
field cas-curs            as logical
field nam-2str            as logical
field nam-artc            as logical
field cod-pcod            as logical
field name-2cd            as character
field how-temp-disc       as character
field nalc                as integer
field rmethod-type        as character
field rmethod-coeff       as decimal
field serial-code         as character
field salesman-mandatory  as integer
field sales-man           as integer
field salesman-psn-code   as integer
field pos-type-for-discnt as character
field manual-discnt       as integer
field is-grp-totals       as logical
field is-gds-totals       as logical
field cash-counter        as decimal
field pre-cash-counter    as decimal
field qnty-change         as logical
field log-level           as integer
field chk-discnt-table    as handle
help 'cntxt_chk-discnt-table':U
field chk-gds-table       as handle
help 'cntxt_chk-gds-table':U
field chk-pay-table       as handle
help  'cntxt_chk-pay-table':U
field z-number            as integer
field shift-num           as integer
field shift-date          as date
field shift-name          as character
field emulator-mode       as integer
field ibmgroup            as logical
index pi is unique primary
db-num
obj-code
pos-type
cash-num
.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var cr as integer no-undo.
DEFINE  TEMP-TABLE t-gds No-UNDO
FIELD b-code like ub.chk-gds.b-code
FIELD doc-qnty like ub.chk-gds.doc-qnty
FIELD VAT-pc like ub.chk-gds.VAT-pc
FIELD price-base like ub.chk-gds.price-base
FIELD price-sum like ub.chk-gds.price-base
FIELD discnt-sum like ub.chk-gds.discnt
FIELD unit-base like ub.goods.unit-base
FIELD num-lines as integer
FIELD was-return as logical
FIELD was-write-off as logical
FIELD is-modificator as logical
FIELD is-null-price as logical
FIELD crf as integer
FIELD drc as recid
FIELD grc as recid
FIELD type like ub.units.type
field corr-discnt-rank as decimal
field first-line-num as integer
field last-included-in-sale as integer
index pi is PRIMARY b-code
index crfi crf
index icorr-discnt drc corr-discnt-rank
.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable crp as integer no-undo.
DEFINE  TEMP-TABLE t-pay No-UNDO
FIELD pay-code like UB.chk-pay.pay-code
FIELD curr-code like ub.chk-pay.curr-code
field tot-base as decimal
field tot-rubl as decimal
FIELD num-lines as integer
FIELD was-return as logical
FIELD crf as integer
FIELD pay-card as character
field drc as recid
FIELD is-cash like ub.cash-pay.is-cash
field byval as character
index pi is PRIMARY pay-code curr-code
index crfi crf.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE crwth as integer no-undo.
DEFINE VARIABLE var-sum-r-b as decimal no-undo .
DEFINE  TEMP-TABLE t-wth No-UNDO
FIELD pay-code like ub.chk-pay.pay-code
FIELD curr-code like ub.chk-pay.curr-code
FIELD wth-code like ub.wealth.wth-code
FIELD tot-sum like ub.chk-pay.tot-sum
FIELD sum-r-b as decimal
FIELD num-lines as integer
field byval as character
FIELD crf as integer
FIELD drc as recid
index pi is PRIMARY pay-code curr-code
index crfi crf.
define new global shared variable g#libbcrcn as handle no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function check-by-mask returns logical (
  input p-mask  as character
  ,input p-str as character
   ,output p-descr as character
  ).
define variable ii as integer no-undo .
define variable v-max as integer no-undo .
define variable v-mask-char as character no-undo .
assign
v-max = length (p-mask).
_do:
do ii = 1 to v-max:
  assign
  v-mask-char = substring(p-mask, ii, 1).
  if v-mask-char = chr(63) then NEXT _do.
  if v-mask-char = "*":U then do:
    if ii < v-max then do:
      assign
      p-descr = substitute("неверная маска &1: звездочка может быть только последним символом маски").
      return no .
    end.
    return yes.
  end.
  else do:
    if v-mask-char <> substring(p-str, ii, 1) then do:
      assign
      p-descr = substitute("№ ДК &1 не соответствует МАСКЕ &2", p-str, p-mask).
      return no.
    end.
    next _do.
  end.
end.
if v-mask-char = chr(63) and v-max = length(p-str) then return yes.
end function.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function card-by-mask returns CHARACTER (
                                             input p-cli-mask  as character
                                            ,input p-cc-run as INTEGER
                                            ,input p-full-number as character
                                            ):
define variable ii as integer no-undo .
define variable v-cli-mask as character no-undo .
define variable v-full-number as character no-undo .
define variable v-short-number as character no-undo .
  if length(p-cli-mask) <> length(p-full-number) then return '':U.
  v-cli-mask = p-cli-mask.
  do ii = 1 to length(p-cli-mask):
    if substring(v-cli-mask, ii, 1) = 'D' then do:
      substring(v-cli-mask, ii, 1) = substring(p-full-number, ii, 1).
      assign
      v-short-number = v-short-number  + substring(p-full-number, ii, 1)
      v-full-number = v-full-number + substring(p-full-number, ii, 1)
      .
    end.
    else do:
       if substring(v-cli-mask, ii, 1) = 'C' then do:
         v-full-number = v-full-number + substring(p-full-number, ii, 1).
       end.
       else do:
         v-full-number = v-full-number + substring(p-cli-mask, ii, 1).
       end.
    end.
  END.
  if v-full-number <> p-full-number then return '':U.
  v-full-number = ''.
  if index(v-cli-mask, 'C') > 0 then do:
    if p-cc-run = 0 then return '':U.
    CASE p-cc-run:
      when integer('1':U) then do:
        run gbl/pluhnalg.p ( input v-cli-mask, output v-full-number) no-error .
      end.
      otherwise do:
        error-status:error = yes.
      end.
    end case.
    if error-status:error then do:
      return '':U.
    end.
    if v-full-number <> p-full-number then return '':U.
  end.
  return v-short-number.
end function.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION libchkvl_get-ranged-shift-num returns integer (input p-shift-num-list as character
                                              ,input p-status-list as character):
 if num-entries(p-shift-num-list) = 1 then return integer(p-shift-num-list).
 if index(p-status-list, '3') > 0 then return integer(entry(lookup('3', p-status-list) ,p-shift-num-list )).
 if index(p-status-list, '2') > 0 then return integer(entry(lookup('2', p-status-list) ,p-shift-num-list )).
 if index(p-status-list, '1') > 0 then return integer(entry(lookup('1', p-status-list) ,p-shift-num-list )).
 if index(p-status-list, '0') > 0 then return integer(entry(lookup('0', p-status-list) ,p-shift-num-list )).
END FUNCTION.
procedure libchkvl_get-shift-num :
define input parameter p-obj-type like ub.chk-doc.obj-type no-undo .
define input parameter p-obj-code like ub.chk-doc.obj-code no-undo .
define input parameter p-shift-date like ub.chk-doc.shift-date no-undo .
define input parameter p-shift-name as character no-undo .
define output parameter p-shift-num as integer no-undo .
define variable v-shift-num-list as character no-undo .
define variable v-status-list as character no-undo .
define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error
  :
    for each  buf_shift-obj no-lock  where
            buf_shift-obj.obj-type    = p-obj-type
        AND  buf_shift-obj.obj-code   = p-obj-code
        AND  buf_shift-obj.shift-date = p-shift-date
        and  buf_shift-obj.shift-name = p-shift-name
        on error undo, return error return-value :
      assign
      v-shift-num-list = string(buf_shift-obj.shift-num) +
                        (if v-shift-num-list = '':U then '':U else chr(44)) + v-shift-num-list
      v-status-list    = entry(lookup(buf_shift-obj.status_, 'ожд,тек,зкр,отм':U), '2,3,1,0':U) +
                        (if v-status-list = '':U then '':U else chr(44)) + v-status-list
      .
    end.
    if v-shift-num-list = '':U then do:
      p-shift-num = 0.
    end.
    else do:
      assign
      p-shift-num = libchkvl_get-ranged-shift-num(v-shift-num-list, v-status-list).
    end.
  end.
end procedure.
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
define temp-table libchkvl_dis-card-mask no-undo
like ub.dis-card-mask
.
function ChkGdsPromo returns logical
    (input iDocCode as character)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromo as logical no-undo.
    vPromo = no.
    cspr:
    for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and buf_chk-gds-attr.attr-value <> "0":
       vPromo = yes.
       leave cspr.
    end.
    return vPromo.
end.
function ChkPromoLine returns logical
    (input iDocCode as character,
    input iLineNum as integer)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromo as logical no-undo.
    vPromo = no.
    find first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = iDocCode
             and buf_chk-gds-attr.line-num  = iLineNum
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and buf_chk-gds-attr.attr-value <> "0"
    no-error.
    if avail buf_chk-gds-attr then vPromo = yes.
    return vPromo.
end.
function ChkPromoSum returns decimal
    (input iDocCode as character,
     input iLineNum as integer)
    :
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable vSumPromo as decimal no-undo.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromoSum"
      no-error.
   if avail buf_chk-gds-attr then
      vSumPromo = DEC(buf_chk-gds-attr.attr-value) no-error.
   return vSumPromo.
end function.
function ChkPromoPrice returns logical
    (input iDocCode as character,
     input iLineNum as integer)
    :
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable v-is-promo as logical no-undo.
   v-is-promo = no.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromo"
      no-error.
   if avail buf_chk-gds-attr
     and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
   then v-is-promo = yes.
   return v-is-promo.
end function.
function ChkDopLitr returns logical
    (input iDocCode as character,
     input iLineNum as integer)
    :
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable v-is-promo as logical no-undo.
   v-is-promo = no.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromo"
      no-error.
   if avail buf_chk-gds-attr and
     buf_chk-gds-attr.attr-value = "3"
   then v-is-promo = yes.
   return v-is-promo.
end function.
function RoundUp return decimal
    (input iQnty as decimal,
     input iPrice as decimal):
    def var vSum  as decimal no-undo.
    def var vSumR as decimal no-undo.
    vSum = ABSOLUTE(iQnty) * iPrice.
    vSumR = Round(vSum,2).
    if vSumR < vSum then vSumR = vSumR + 0.01.
    if iQnty < 0 then vSumR = - vSumR.
    return vSumR.
end function.
function GetPromoSum returns decimal
    (input iDocCode as character)
    :
    define buffer buf_chk-doc for ub.chk-doc.
    define buffer buf2_chk-doc for ub.chk-doc.
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define buffer buf2_chk-gds for ub.chk-gds.
    define buffer buf2_chk-gds-attr for ub.chk-gds-attr.
    define variable v-price-base as decimal no-undo.
    define variable v-doc-qnty as decimal no-undo.
    define variable v-sum-base as decimal no-undo.
    define variable v-sum-all as decimal no-undo.
    define variable v-sum-promo as decimal no-undo.
    define variable v-sum-chk as decimal no-undo.
    assign
       v-price-base = 0
       v-doc-qnty = 0
       v-sum-all = 0
       v-sum-chk = 0
       v-sum-promo = 0
       .
    for each buf_chk-gds no-lock where
             buf_chk-gds.doc-code = iDocCode,
       first buf_chk-gds-attr no-lock where
             buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
         and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
         and buf_chk-gds-attr.attr-code = "CSPromoSum"
       :
       v-sum-promo = Dec(buf_chk-gds-attr.attr-value).
    end.
    if v-sum-promo = 0 then do:
        for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("1,6", buf_chk-gds-attr.attr-value)
           :
           assign
             v-price-base = buf_chk-gds.price-base
             v-doc-qnty   = if buf_chk-gds.doc-qnty = ? then buf_chk-gds.src-qnty else buf_chk-gds.doc-qnty
             v-sum-base = if buf_chk-gds.sum-base = ? then round(v-doc-qnty * v-price-base, 2) else buf_chk-gds.sum-base
             .
        end.
        for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
           :
           if v-price-base = 0 then do:
              find first buf_chk-doc no-lock where
                         buf_chk-doc.doc-code = iDocCode
                  no-error.
              if avail buf_chk-doc and
                 buf_chk-doc.chk-type = int('6':U) and
                 buf_chk-doc.doc-num2 > ""  and
                 num-entries(buf_chk-doc.doc-num2,":") = 2
              then
              for first buf2_chk-doc no-lock where
                        buf2_chk-doc.obj-code = buf_chk-doc.obj-code
                    and buf2_chk-doc.obj-type = buf_chk-doc.obj-type
                    and buf2_chk-doc.chk-type = int('1':U)
                    and buf2_chk-doc.chk-num = int(entry(1,buf_chk-doc.doc-num2,":"))
                    and buf2_chk-doc.z-number = int(entry(2, buf_chk-doc.doc-num2,":"))
                    :
                for each buf2_chk-gds no-lock where
                         buf2_chk-gds.doc-code = buf2_chk-doc.doc-code,
                   first buf2_chk-gds-attr no-lock where
                         buf2_chk-gds-attr.doc-code = buf2_chk-gds.doc-code
                     and buf2_chk-gds-attr.line-num  = buf2_chk-gds.line-num
                     and buf2_chk-gds-attr.attr-code = "CSPromo"
                     and can-do("1,6", buf2_chk-gds-attr.attr-value)
                   :
                    v-price-base = buf2_chk-gds.price-base.
                end.
              end.
           end.
           if buf_chk-gds.sum-base = ? or buf_chk-gds.src-qnty = 0 then do:
               assign
                  v-sum-all = (buf_chk-gds.src-qnty + v-doc-qnty) * v-price-base
                  v-sum-chk = v-sum-base + RoundUp(buf_chk-gds.src-qnty, buf_chk-gds.src-price)
                  .
           end.
           else do:
              assign
              v-sum-all = (buf_chk-gds.doc-qnty + v-doc-qnty ) * v-price-base
              v-sum-chk = v-sum-base + buf_chk-gds.sum-base
              .
           end.
        end.
        v-sum-promo = Round(v-sum-all, 2) - Round(v-sum-chk, 2).
    end.
    return v-sum-promo.
end function.
function GetUnBaseSum returns decimal
    (input iDocCode as character,
     input iLineNum as integer,
     input iQnty as decimal,
     input iPrice as decimal):
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable vBaseSum as decimal no-undo.
   define variable vDiscSum as decimal no-undo.
   vDiscSum = 0.
   find first buf_chk-gds-attr no-lock where
                     buf_chk-gds-attr.doc-code = iDocCode
                 and buf_chk-gds-attr.line-num  = iLineNum
                 and buf_chk-gds-attr.attr-code = "CSPromoSum"
          no-error.
   if avail buf_chk-gds-attr then
      vDiscSum = dec(buf_chk-gds-attr.attr-value) no-error.
   vBaseSum = iQnty * iPrice + vDiscSum.
   if vDiscSum = 0 and ChkPromoPrice(iDocCode, iLineNum) then
      vBaseSum = RoundUp(iQnty, iPrice).
   return vBaseSum.
end function.
function GetRoundSum returns decimal
    (input iDocCode as character,
     input iLineNum as integer,
     input iQnty as decimal,
     input iPrice as decimal):
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable vBaseSum as decimal no-undo.
   if ChkPromoPrice(iDocCode, iLineNum) then
      vBaseSum = RoundUp(iQnty, iPrice).
   else vBaseSum = iQnty * iPrice.
   return vBaseSum.
end function.
function GetRoundSumChkDel returns decimal
    (input iDocCode as character,
     input iLineNum as integer,
     input iChipNum as integer,
     input iQnty as decimal,
     input iPrice as decimal):
   define buffer  buf_c-chk-doc-attr for ub.c-chk-doc-attr.
   define variable vBaseSum as decimal no-undo.
   define variable vIsPromo as logical no-undo.
   for each buf_c-chk-doc-attr no-lock where
            buf_c-chk-doc-attr.doc-code = iDocCode
        and buf_c-chk-doc-attr.chip-num = iChipNum
       :
       if num-entries(buf_c-chk-doc-attr.attr-code, chr(4)) > 1
       then do :
         if entry(1, buf_c-chk-doc-attr.attr-code, chr(4)) begins "gds="
         and entry(2, buf_c-chk-doc-attr.attr-code, chr(4)) = "CSPromo"
         and entry(2, entry(1, buf_c-chk-doc-attr.attr-code, chr(4)), "=") = String(iLineNum)
         and can-do("2,4,5,7", buf_c-chk-doc-attr.attr-value)
         then vIsPromo = yes.
       end.
   end.
   if ChkPromoPrice(iDocCode, iLineNum) then
      vBaseSum = RoundUp(iQnty, iPrice).
   else vBaseSum = iQnty * iPrice.
   return vBaseSum.
end function.
function GetSaleRetDisc returns decimal
    (input iDocCode as character,
     input iSaleCode as character):
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define buffer buf_chk-gds for ub.chk-gds.
   define variable vQntyPromoRet as decimal no-undo.
   define variable vQntyPromoSel as decimal no-undo.
   define variable vDiscSumRet   as decimal no-undo.
   define variable vDiscSumSale  as decimal no-undo.
   vDiscSumRet = 0.
   cspr:
   for each  buf_chk-gds no-lock where
             buf_chk-gds.doc-code = iDocCode,
       first buf_chk-gds-attr no-lock where
             buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
         and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
         and buf_chk-gds-attr.attr-code = "CSPromo"
         and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
       :
       vQntyPromoRet = buf_chk-gds.src-qnty.
       leave cspr.
   end.
   if vQntyPromoRet <> 0 then
   for each  buf_chk-gds no-lock where
             buf_chk-gds.doc-code = iSaleCode:
       find first buf_chk-gds-attr no-lock where
                  buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
              and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
              and buf_chk-gds-attr.attr-code = "CSPromo"
       no-error.
       if avail buf_chk-gds-attr
            and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
       then
         vQntyPromoSel = buf_chk-gds.src-qnty.
       find first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromoSum"
       no-error.
       if avail buf_chk-gds-attr then
          vDiscSumSale = dec(buf_chk-gds-attr.attr-value) no-error.
   end.
   if vQntyPromoRet <> 0 and
      vQntyPromoSel = -1 * vQntyPromoRet
   then vDiscSumRet = -1 * vDiscSumSale.
   return vDiscSumRet.
end function.
function SetPromoDisc return logical
 (input iDocCode as character,
     input iLineNum as integer
     )
    :
   define buffer buf_chk-doc for ub.chk-doc.
   define buffer buf2_chk-doc for ub.chk-doc.
   define buffer buf_chk-gds for ub.chk-gds.
   define buffer buf2_chk-gds for ub.chk-gds.
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define buffer buf2_chk-gds-attr for ub.chk-gds-attr.
   define buffer buf_chk-discnt for ub.chk-discnt.
   define buffer buf2_chk-discnt for ub.chk-discnt.
   define buffer buf_chk-discnt-attr for ub.chk-discnt-attr.
   define buffer buf2_chk-discnt-attr for ub.chk-discnt-attr.
   define variable v-promo-sum as decimal no-undo.
   define variable v-disc-promo-id as character no-undo.
   define variable var-discnt-id as integer no-undo.
   define variable v-chk-sale as character no-undo.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromo"
      no-error.
   if avail buf_chk-gds-attr
     then do:
     find first buf_chk-discnt no-lock where
                buf_chk-discnt.doc-code = buf_chk-gds-attr.doc-code
            and buf_chk-discnt.line-num = buf_chk-gds-attr.line-num
            and buf_chk-discnt.record-type = 0
            and buf_chk-discnt.promo-id > ""
            no-error.
     if not avail buf_chk-discnt then do:
        find first buf_chk-doc no-lock where
                   buf_chk-doc.doc-code = iDocCode
           no-error.
        find first buf_chk-gds no-lock where
                   buf_chk-gds.doc-code = iDocCode
              and  buf_chk-gds.line-num = iLineNum
           no-error.
       for first buf2_chk-doc no-lock where
                 buf2_chk-doc.obj-code = buf_chk-doc.obj-code
             and buf2_chk-doc.obj-type = buf_chk-doc.obj-type
             and buf2_chk-doc.pay-desk = buf_chk-doc.pay-desk
             and buf2_chk-doc.chk-type = int('1':U)
             and buf2_chk-doc.chk-num  = int(entry(1,buf_chk-doc.doc-num2,":"))
             and buf2_chk-doc.z-number = int(entry(2, buf_chk-doc.doc-num2,":"))
           :
           find first buf2_chk-gds no-lock where
                      buf2_chk-gds.doc-code = buf2_chk-doc.doc-code
                 and  buf2_chk-gds.b-code   = buf_chk-gds.b-code
           no-error.
           if not avail buf2_chk-gds then return no.
           v-chk-sale = buf2_chk-doc.doc-code.
           find first buf_chk-discnt no-lock where
                      buf_chk-discnt.doc-code =  buf2_chk-doc.doc-code and
                      buf_chk-discnt.record-type = 1 and
                      buf_chk-discnt.object-line-num = buf2_chk-gds.line-num and
                      buf_chk-discnt.promo-id > ""
           no-error .
           if avail buf_chk-discnt
           then do:
              v-disc-promo-id = buf_chk-discnt.promo-id.
              find first buf2_chk-discnt no-lock where
                buf2_chk-discnt.doc-code = iDocCode and
                buf2_chk-discnt.record-type = 5 and
                buf2_chk-discnt.line-num = 0 and
                buf2_chk-discnt.promo-id =  v-disc-promo-id
              no-error.
              find first buf2_chk-discnt-attr no-lock where
                         buf2_chk-discnt-attr.doc-code = iDocCode and
                         buf2_chk-discnt-attr.record-type = 5 and
                         buf2_chk-discnt-attr.line-num = 0 and
                         buf2_chk-discnt-attr.attr-code = "promo-id" and
                         buf2_chk-discnt-attr.attr-value = v-disc-promo-id
                    no-error .
              if not avail buf2_chk-discnt
              then do:
                  for each buf_chk-discnt no-lock where
                           buf_chk-discnt.doc-code = buf_chk-gds-attr.doc-code
                       and buf_chk-discnt.record-type = 5:
                       var-discnt-id  = var-discnt-id + 1.
                  end.
                  create buf2_chk-discnt.
                  assign
                    buf2_chk-discnt.doc-code = iDocCode
                    buf2_chk-discnt.record-type = 5
                    buf2_chk-discnt.line-num = 0
                    buf2_chk-discnt.promo-id = v-disc-promo-id
                    buf2_chk-discnt.object-sum = 0
                    buf2_chk-discnt.discnt-id = if avail buf2_chk-discnt-attr
                                                   then buf2_chk-discnt-attr.discnt-id
                                                   else (var-discnt-id + 1)
                    var-discnt-id = 0
                    buf2_chk-discnt.object-line-num = 0
                    buf2_chk-discnt.pay-desk = buf_chk-doc.pay-desk
                    buf2_chk-discnt.obj-code = buf_chk-doc.obj-code
                    buf2_chk-discnt.obj-type = buf_chk-doc.obj-type
                    buf2_chk-discnt.chk-date = buf_chk-doc.chk-date
                    buf2_chk-discnt.shift-date = buf_chk-doc.shift-date
                    buf2_chk-discnt.shift-num = buf_chk-doc.shift-num
                    buf2_chk-discnt.chk-time = buf_chk-doc.chk-time
                    .
              end.
              if avail buf2_chk-discnt and
                 not avail buf2_chk-discnt-attr
              then do:
                 create buf2_chk-discnt-attr.
                 assign
                    buf2_chk-discnt-attr.doc-code = iDocCode
                    buf2_chk-discnt-attr.discnt-id = buf2_chk-discnt.discnt-id
                    buf2_chk-discnt-attr.record-type     = 5
                    buf2_chk-discnt-attr.line-num        = 0
                    buf2_chk-discnt-attr.object-line-num = 0
                    buf2_chk-discnt-attr.attr-code       = "promo-id"
                    buf2_chk-discnt-attr.attr-value      = v-disc-promo-id
                    .
              end.
           end.
       end.
        v-promo-sum = 0.
        if can-do("1,6,7", buf_chk-gds-attr.attr-value)
        then do:
           if v-chk-sale <> ? and v-chk-sale <> "" then
              v-promo-sum = GetSaleRetDisc(iDocCode,v-chk-sale).
           v-promo-sum = if v-promo-sum = 0 then GetPromoSum(iDocCode) else v-promo-sum.
           if v-promo-sum <> 0 then do:
               find first buf2_chk-gds-attr no-lock where
                          buf2_chk-gds-attr.doc-code = iDocCode
                      and buf2_chk-gds-attr.line-num  = iLineNum
                      and buf2_chk-gds-attr.attr-code = "CSPromoSum"
                  no-error.
               if not avail buf2_chk-gds-attr then do:
                   create buf2_chk-gds-attr.
                   assign
                      buf2_chk-gds-attr.doc-code = iDocCode
                      buf2_chk-gds-attr.line-num  = iLineNum
                      buf2_chk-gds-attr.attr-code = "CSPromoSum"
                      buf2_chk-gds-attr.attr-value = string(Round(v-promo-sum,2))
                      .
               end.
           end.
        end.
        for each buf_chk-discnt no-lock where
                buf_chk-discnt.doc-code = buf_chk-gds-attr.doc-code
            and buf_chk-discnt.record-type = 0:
           var-discnt-id  = var-discnt-id + 1.
        end.
        create buf_chk-discnt.
        assign
            buf_chk-discnt.doc-code = iDocCode
            buf_chk-discnt.line-num = iLineNum
            buf_chk-discnt.record-type = 0
            buf_chk-discnt.discnt-id = (var-discnt-id + 1)
            buf_chk-discnt.time-oper = buf_chk-gds.time-oper
            buf_chk-discnt.line-type = integer('1':U)
            buf_chk-discnt.line-sign = no
            buf_chk-discnt.pass-discnt = integer('0':U)
            buf_chk-discnt.value-type = integer('2':U)
            buf_chk-discnt.src-d-card = buf_chk-gds.src-d-card
            buf_chk-discnt.d-card = buf_chk-gds.d-card
            buf_chk-discnt.discnt-value-abs = 0
            buf_chk-discnt.discnt-value-pcnt = 0
            buf_chk-discnt.object-line-num = iLineNum
            buf_chk-discnt.pay-desk = buf_chk-doc.pay-desk
            buf_chk-discnt.obj-code = buf_chk-doc.obj-code
            buf_chk-discnt.obj-type = buf_chk-doc.obj-type
            buf_chk-discnt.chk-date = buf_chk-doc.chk-date
            buf_chk-discnt.chk-time = buf_chk-doc.chk-time
            buf_chk-discnt.shift-date = buf_chk-doc.shift-date
            buf_chk-discnt.shift-num = buf_chk-doc.shift-num
            buf_chk-discnt.object-qnty = buf_chk-gds.src-qnty
            buf_chk-discnt.object-sum = buf_chk-gds.src-sum
            var-discnt-id = var-discnt-id + 1
            buf_chk-discnt.promo-id = v-disc-promo-id
            buf_chk-discnt.discnt-type = integer('7':U)
            .
        find first buf_chk-discnt-attr no-lock where
                   buf_chk-discnt-attr.attr-code = "promo-id"
               and buf_chk-discnt-attr.discnt-id = buf_chk-discnt.discnt-id
               and buf_chk-discnt-attr.doc-code = buf_chk-discnt.doc-code
               and buf_chk-discnt-attr.line-num = buf_chk-discnt.line-num
               no-error.
        if not avail buf_chk-discnt-attr then
        do:
            create buf_chk-discnt-attr .
            assign
                buf_chk-discnt-attr.attr-code = "promo-id"
                buf_chk-discnt-attr.attr-value = buf_chk-discnt.promo-id
                buf_chk-discnt-attr.discnt-id = buf_chk-discnt.discnt-id
                buf_chk-discnt-attr.doc-code = buf_chk-discnt.doc-code
                buf_chk-discnt-attr.line-num = buf_chk-discnt.line-num
                buf_chk-discnt-attr.object-line-num = buf_chk-discnt.object-line-num
                buf_chk-discnt-attr.record-type = buf_chk-discnt.record-type
                .
         end.
     end.
   end.
   return yes.
end function.
function GetPromoPriceSum returns decimal
    (input iDocCode as character)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromoSum as decimal no-undo.
    vPromoSum = 0.
    cspr:
    for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("2,4,5,7", buf_chk-gds-attr.attr-value):
       vPromoSum = RoundUp(buf_chk-gds.src-qnty, buf_chk-gds.src-price).
       leave cspr.
    end.
    return vPromoSum.
end.
function GetPromoPriceLine returns integer
    (input iDocCode as character)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromoLine as integer no-undo.
    vPromoLine = 0.
    cspr:
    for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("2,4,5,7", buf_chk-gds-attr.attr-value):
       vPromoLine = buf_chk-gds-attr.line-num.
       leave cspr.
    end.
    return vPromoLine.
end.
define variable log-file-name as character no-undo init "get-chkf.log".
define variable log-file-name0 as character no-undo init "get-chkf.log".
if valid-handle (g#libchkvl)
and g#libchkvl <> this-procedure :handle
and g#libchkvl :get-signature('libchkvl_get-dc-mask-array ':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки для проверки валидности чека" skip
    g#libchkvl skip
    g#libchkvl :type skip
    g#libchkvl :file-name skip
    valid-handle(g#libchkvl) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#libchkvl = this-procedure :handle
  .
end.
on delete of this-procedure do:
  assign
    g#libchkvl = ?
  .
end.
procedure libchkvl_get-dc-mask-array :
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define buffer buf_dis-card-mask for ub.dis-card-mask.
define buffer buf_libchkvl_dis-card-mask for libchkvl_dis-card-mask.
for each buf_libchkvl_dis-card-mask:
  delete buf_libchkvl_dis-card-mask.
end.
_maska:
for each buf_dis-card-mask no-lock where
    buf_Dis-card-mask.stts              = integer('0':U)
by buf_Dis-card-mask.host-code
by buf_Dis-card-mask.obj-type
by buf_Dis-card-mask.obj-code
by buf_Dis-card-mask.rank
:
  if buf_dis-card-mask.host-code <> 0
  And buf_dis-card-mask.host-code <> p-host-code then next _maska.
  if (buf_dis-card-mask.obj-type <> "":U
  AND buf_dis-card-mask.obj-type <> p-obj-type)
  or (buf_dis-card-mask.obj-code <> 0
  and buf_dis-card-mask.obj-code <> p-obj-code)
  then NEXT _maska.
  if buf_dis-card-mask.use-on = integer('1':U) then NEXT _Maska.
  create buf_libchkvl_dis-card-mask.
  buffer-copy buf_dis-card-mask to
  buf_libchkvl_dis-card-mask.
end.
end.
function libchkvl_right-netto-sign returns integer ( input p-chk-type as integer):
if p-chk-type > 200 then p-chk-type = p-chk-type - 100.
if p-chk-type > 100 then p-chk-type = p-chk-type - 100.
case p-chk-type:
  when integer('1':U)
  or
  when integer('201':U)
  or
  when integer('3':U)
  or
  when integer('7':U)
    then do:
    return 1.
  end.
  when integer('6':U)
  or
  when integer('96':U)
  or
  when integer('206':U)
  or
  when integer('2':U)
  or
  when integer('5':U)
  then do:
    return -1.
  end.
  when integer('8':U)
  or
  when integer('208':U)
  or
  when integer('11':U)
  or
  when integer('12':U)
  or
  when integer('69':U)
  or
  when integer('14':U)
  or
  when integer('15':U)
  or
  when integer('16':U)
  or
  when integer('17':U)
  or
  when integer('13':U)
  or
  when integer('40':U)
  or
  when integer('4':U)
  then do:
    return 0.
  end.
end case.
end function.
FUNCTION libchkvl_direct-sign returns logical ( input p-chk-type as integer
                                               ,input p-qnty as decimal):
return yes.
end.
procedure libchkvl_get-cash-shift :
define input parameter p-context-bh as handle no-undo .
define parameter buffer buf_shift-cash for ub.shift-cash.
define input parameter p-cash-num as integer no-undo .
define input parameter p-shift-date as date no-undo .
define input parameter p-shift-name as character no-undo .
define input parameter p-z-number as integer no-undo .
define input parameter p-chk-date as date no-undo .
define input parameter p-chk-time as integer no-undo .
define input parameter p-shift-open-time as integer no-undo .
DEFINE VARIABLE current-cas-shift-num      as   integer               no-undo .
DEFINE VARIABLE current-cas-shift-name     as   character             no-undo .
DEFINE VARIABLE current-cas-shift-date     as   date                  no-undo .
DEFINE VARIABLE current-cas-shift-status_  as   char                  no-undo .
DEFINE VARIABLE current-shift-status_      as   character             no-undo init 'тек':U.
define variable vrecid as recid no-undo .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-parparentproc       as widget-handle           no-undo .
define variable v-p-log-handle        as handle                  no-undo .
define variable v-p-log-file-name     as character               no-undo .
define variable v-view-log            as logical                 no-undo .
define variable v-ll                  as integer                 no-undo .
define variable v-tt-wd-bh            as handle                  no-undo .
define variable v-pos-type            as character               no-undo .
define variable v-cash-num            as integer                 no-undo .
define variable v-obj-type            as character init 'маг':U  no-undo .
define variable v-obj-code            as integer                 no-undo .
define variable v-db-num              as integer                 no-undo .
define variable v-r-b                 as character               no-undo .
define variable v-host-code           as integer                 no-undo .
define variable v-base-code           as integer                 no-undo .
define variable v-cre-pay             as integer                 no-undo .
define variable v-is-catering         as logical                 no-undo .
define variable v-is-cdinv            as logical                 no-undo .
define variable v-is-ptrl             as logical                 no-undo .
define variable v-is-wth              as logical                 no-undo .
define variable v-process-sale        as logical                 no-undo .
define variable v-dc-mask             as logical                 no-undo .
define variable v-card-by-mask        as logical                 no-undo .
define variable v-sclspref            as character               no-undo .
define variable v-scpgpref            as character               no-undo .
define variable v-scpgpref-pre        as character               no-undo .
define variable v-doc-prt             as logical                 no-undo .
define variable v-shift-on            as logical                 no-undo .
define variable v-cas-shft            as logical                 no-undo .
define variable v-t-shft              as integer                 no-undo .
define variable v-v-shft              as integer                 no-undo .
define variable v-ptrl-check          as logical                 no-undo .
define variable v-annu-check          as logical                 no-undo .
define variable v-z-check             as logical                 no-undo .
define variable v-hnum                as logical                 no-undo .
define variable v-is-100-discnt       as logical                 no-undo .
define variable v-zero-cashier        as integer                 no-undo .
define variable v-rnd-znak            as integer                 no-undo .
define variable v-cas-curs            as logical                 no-undo .
define variable v-nam-2str            as logical                 no-undo .
define variable v-nam-artc            as logical                 no-undo .
define variable v-cod-pcod            as logical                 no-undo .
define variable v-name-2cd            as character               no-undo .
define variable v-how-temp-disc       as character               no-undo .
define variable v-nalc                as integer                 no-undo .
define variable v-rmethod-type        as character               no-undo .
define variable v-rmethod-coeff       as decimal                 no-undo .
define variable v-serial-code         as character               no-undo .
define variable v-salesman-mandatory  as integer                 no-undo .
define variable v-sales-man           as integer                 no-undo .
define variable v-salesman-psn-code   as integer                 no-undo .
define variable v-pos-type-for-discnt as character               no-undo .
define variable v-manual-discnt       as integer                 no-undo .
define variable v-is-grp-totals       as logical                 no-undo .
define variable v-is-gds-totals       as logical                 no-undo .
define variable v-cash-counter        as decimal                 no-undo .
define variable v-pre-cash-counter    as decimal                 no-undo .
define variable v-qnty-change         as logical                 no-undo .
define variable v-log-level           as integer                 no-undo .
define variable v-chk-discnt-table    as handle                  no-undo .
define variable v-chk-gds-table       as handle                  no-undo .
define variable v-chk-pay-table       as handle                  no-undo .
define variable v-z-number            as integer                 no-undo .
define variable v-shift-num           as integer                 no-undo .
define variable v-shift-date          as date                    no-undo .
define variable v-shift-name          as character               no-undo .
define variable v-emulator-mode       as integer                 no-undo .
define variable v-ibmgroup            as logical                 no-undo .
define buffer buf_shift-obj for ub.shift-obj.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
v-parparentproc                      =  p-context-bh::parparentproc
v-p-log-handle                       =  p-context-bh::p-log-handle
v-p-log-file-name                    =  p-context-bh::p-log-file-name
v-view-log                           =  p-context-bh::view-log
v-ll                                 =  p-context-bh::ll
v-tt-wd-bh                           =  p-context-bh::tt-wd-bh
v-pos-type                           =  p-context-bh::pos-type
v-cash-num                           =  p-context-bh::cash-num
v-obj-type                           =  p-context-bh::obj-type
v-db-num                             =  p-context-bh::db-num
v-obj-code                           =  p-context-bh::obj-code
v-r-b                                =  p-context-bh::r-b
v-host-code                          =  p-context-bh::host-code
v-base-code                          =  p-context-bh::base-code
v-cre-pay                            =  p-context-bh::cre-pay
v-is-catering                        =  p-context-bh::is-catering
v-is-cdinv                           =  p-context-bh::is-cdinv
v-is-ptrl                            =  p-context-bh::is-ptrl
v-is-wth                             =  p-context-bh::is-wth
v-dc-mask                            =  p-context-bh::dc-mask
v-card-by-mask                       =  p-context-bh::card-by-mask
v-sclspref                           =  p-context-bh::sclspref
v-scpgpref                           =  p-context-bh::scpgpref
v-scpgpref-pre                       =  p-context-bh::scpgpref-pre
v-doc-prt                            =  p-context-bh::doc-prt
v-shift-on                           =  p-context-bh::shift-on
v-cas-shft                           =  p-context-bh::cas-shft
v-t-shft                             =  p-context-bh::t-shft
v-v-shft                             =  p-context-bh::v-shft
v-ptrl-check                         =  p-context-bh::ptrl-check
v-annu-check                         =  p-context-bh::annu-check
v-z-check                            =  p-context-bh::z-check
v-hnum                               =  p-context-bh::hnum
v-is-100-discnt                      =  p-context-bh::is-100-discnt
v-zero-cashier                       =  p-context-bh::zero-cashier
v-rnd-znak                           =  p-context-bh::rnd-znak
v-cas-curs                           =  p-context-bh::cas-curs
v-nam-2str                           =  p-context-bh::nam-2str
v-nam-artc                           =  p-context-bh::nam-artc
v-cod-pcod                           =  p-context-bh::cod-pcod
v-name-2cd                           =  p-context-bh::name-2cd
v-how-temp-disc                      =  p-context-bh::how-temp-disc
v-nalc                               =  p-context-bh::nalc
v-serial-code                        =  p-context-bh::serial-code
v-salesman-mandatory                 =  p-context-bh::salesman-mandatory
v-sales-man                          =  p-context-bh::sales-man
v-salesman-psn-code                  =  p-context-bh::salesman-psn-code
v-pos-type-for-discnt                =  p-context-bh::pos-type-for-discnt
v-manual-discnt                      =  p-context-bh::manual-discnt
v-is-grp-totals                      =  p-context-bh::is-grp-totals
v-is-gds-totals                      =  p-context-bh::is-gds-totals
v-chk-discnt-table                   =  p-context-bh::chk-discnt-table
v-chk-gds-table                      =  p-context-bh::chk-gds-table
v-chk-pay-table                      =  p-context-bh::chk-pay-table
v-z-number                           =  p-context-bh::z-number
v-shift-num                          =  p-context-bh::shift-num
v-shift-date                         =  p-context-bh::shift-date
v-shift-name                         =  p-context-bh::shift-name
v-emulator-mode                      =  p-context-bh::emulator-mode
v-ibmgroup                           =  p-context-bh::ibmgroup
.
  if v-p-log-file-name <> ""
  or v-p-log-file-name <> ? then do:
    log-file-name = v-p-log-file-name.
  end.
  else do:
    log-file-name = log-file-name0.
  end.
  if v-shift-on then do:
    _sc:
    for each  buf_shift-cash Exclusive-LOCK WHERE
              (buf_shift-cash.obj-type = v-obj-type
          AND buf_shift-cash.obj-code = v-obj-code
          AND buf_shift-cash.cash-num = p-cash-num
          AND buf_shift-cash.shift-date = p-shift-date
          AND buf_shift-cash.src-shift-name = p-shift-name)
      or
              (buf_shift-cash.obj-type = v-obj-type
          AND buf_shift-cash.obj-code = v-obj-code
          AND buf_shift-cash.cash-num = p-cash-num
          AND buf_shift-cash.shift-date = p-shift-date
          AND buf_shift-cash.shift-name = p-shift-name) :
      if BUF_shift-cash.src-shift-name = p-shift-name
      or BUF_shift-cash.shift-name = p-shift-name
      then do:
        IF buf_shift-cash.shift-date = p-chk-date
        and BUF_shift-cash.shift-open-time = p-chk-time
        and BUF_shift-cash.src-shift-name = p-shift-name
        and p-z-number = ?
        and buf_shift-cash.opened = 'прием-чек':U
        then  do:
          LEAVE _sc.
        end.
        IF BUF_shift-cash.shift-close-date = p-chk-date
        and BUF_shift-cash.shift-close-time = p-chk-time
        and (BUF_shift-cash.src-shift-name = p-shift-name
            or
            (BUF_shift-cash.shift-name = p-shift-name
            and
            buf_shift-cash.opened <> 'прием-чек':U)
            or
            (BUF_shift-cash.shift-name = p-shift-name
            and
            BUF_shift-cash.src-shift-name <> p-shift-name)
          )
        and (p-z-number <> ?
            and
            buf_shift-cash.status_ = 'зкр':U)
        then  do:
          LEAVE _sc.
        end.
        if buf_shift-cash.opened <> 'прием-чек':U
        and buf_shift-cash.shift-num <> ? then do:
          find first buf_shift-obj no-lock where
                    buf_shift-obj.obj-type = v-obj-type
                AND buf_shift-obj.obj-code = v-obj-code
                AND buf_shift-obj.shift-date = buf_shift-cash.shift-date
                and buf_shift-obj.shift-num = buf_shift-cash.shift-num No-ERROR.
          if available buf_shift-obj and
          buf_shift-obj.status_ = 'факт':U then next _sc.
        end.
        leave _sc.
      end.
    end.
     IF AVAIL buf_shift-cash
     and buf_shift-cash.shift-num <> 0
     and buf_shift-cash.shift-num <> ?
     and buf_shift-cash.opened eq 'прием-чек':U
     then
     assign
     current-cas-shift-num  = buf_shift-cash.shift-num
     current-cas-shift-name = p-shift-name
     current-cas-shift-date = buf_shift-cash.shift-date
     current-cas-shift-status_ = buf_shift-cash.status_
     .
     else do:
       run str/shftccr.p (
                        input v-obj-type
                       ,input v-obj-code
                       ,input p-cash-num
                       ,input p-shift-date
                       ,input (if not v-shift-on then ? else p-shift-name)
                       ,input p-shift-name
                       ,input (if not v-shift-on then ? else integer(p-shift-name))
                       ,input (if p-z-number <> ?
                               then p-shift-open-time
                               else (if p-chk-date = p-shift-date then p-chk-time else ?)
                               )
                       ,input p-z-number
                       ,input 'прием-чек':U
                       ,output vrecid) no-error.
       if error-status:error then do:
         if valid-handle( v-p-log-handle) then do:
           run write-log-and-file in v-p-log-handle (
                 input 1
               , input log-file-name
               , input 1
               , input substitute( "!!!Произошла ошибка при попытке создания записи кассовой смены для кассы &1: смена N&2 за &3"
                                   , p-cash-num
                                   , p-shift-name
                                   , string(p-shift-date, "99/99/9999")
                                 )
                                                 ).
           v-view-log = yes.
         end.
       end.
       else do:
         FIND FIRST buf_shift-cash WHERE recid(buf_shift-cash) = vrecid.
         assign
         current-cas-shift-name = p-shift-name
         current-cas-shift-num = buf_shift-cash.shift-num
         current-cas-shift-date = p-shift-date
         current-cas-shift-status_ = 'тек':U
         .
       end.
     end.
     if avail buf_shift-cash then do:
       if v-shift-on then do:
         if current-cas-shift-num  = ? then do:
           run libchkvl_get-shift-num  in this-procedure (
                                                  input  v-obj-type
                                                 ,input  v-obj-code
                                                 ,input  current-cas-shift-date
                                                 ,input  current-cas-shift-name
                                                 ,output current-cas-shift-num ) no-error .
         end.
         if current-cas-shift-num <> ? then do:
           FIND FIRST buf_shift-obj NO-LOCK WHERE
                       buf_shift-obj.obj-type = v-obj-type AND
                       buf_shift-obj.obj-code = v-obj-code AND
                       buf_shift-obj.shift-date = current-cas-shift-date AND
                       buf_shift-obj.shift-num = current-cas-shift-num No-ERROR.
         end.
         else release buf_shift-obj.
         if avail buf_shift-obj then
         current-shift-status_ = buf_shift-obj.status_.
         else
         current-shift-status_ = 'тек':U.
       end.
       if p-z-number <> ?  then do:
         assign
         buf_shift-cash.status_ = 'зкр':U
         buf_shift-cash.z-num = p-z-number
         buf_shift-cash.closed = 'прием-чек':U
         buf_shift-cash.shift-num = (if buf_shift-cash.shift-num = ?
                                 and not can-find(first ub.shift-cash where
                                                       ub.shift-cash.obj-type = buf_shift-cash.obj-type
                                                   and  ub.shift-cash.obj-code = buf_shift-cash.obj-code
                                                   and  ub.shift-cash.cash-num = current-cas-shift-num
                                                   and  ub.shift-cash.shift-date = buf_shift-cash.shift-date
                                                   and  ub.shift-cash.shift-num = buf_shift-cash.shift-num
                                                   and  ub.shift-cash.src-shift-name = buf_shift-cash.src-shift-name
                                                   and  recid(ub.shift-cash) <> recid(buf_shift-cash)
                                                   )
                                 then current-cas-shift-num
                                 else buf_shift-cash.shift-num)
         buf_shift-cash.shift-name = if buf_shift-cash.shift-num <> ?
                                     then current-cas-shift-name
                                     else buf_shift-cash.shift-name
         buf_shift-cash.shift-open-time  = (if buf_shift-cash.shift-open-time > p-shift-open-time
                                             then p-shift-open-time
                                             else buf_shift-cash.shift-open-time)
         buf_shift-cash.shift-close-date = (if buf_shift-cash.shift-close-date = ?
                                             or buf_shift-cash.shift-close-date < p-chk-date
                                             then p-chk-date
                                             else buf_shift-cash.shift-close-date)
         buf_shift-cash.shift-close-time = (if buf_shift-cash.shift-close-time = 0
                                             or (buf_shift-cash.shift-close-date = p-chk-date
                                                 and
                                                 buf_shift-cash.shift-close-time < p-chk-time)
                                             then p-chk-time
                                             else buf_shift-cash.shift-close-time)
         .
       end.
     end.
  end.
end.
end procedure.
procedure libchkvl_chk-gds-wro :
define input parameter p-chk-type as integer no-undo .
define input parameter p-line-num as integer no-undo .
define input parameter p-src-qnty as decimal no-undo .
define input parameter p-wro-code as integer no-undo .
define output parameter p-valid as logical no-undo .
define output parameter p-mess as character no-undo .
main-block:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  if (p-wro-code <> ?
      and p-wro-code <> 0 )
      or
    p-chk-type = integer('96':U)
    or
    p-chk-type = integer('69':U)
    then do:
    if (lookup(string(p-chk-type), '1,69,14,15,16,36':U) > 0
    and p-wro-code < 0)
    or
    (lookup(string(p-chk-type), '6,96':U) > 0
    and p-wro-code > 0 and p-src-qnty <> 0)
    or
    (p-chk-type = integer('96':U)
    and (p-wro-code = 0
        or
        p-wro-code = ?)
      )
    or
    (p-chk-type = integer('69':U)
    and (p-wro-code = 0
        or
        p-wro-code = ?)
      )
    then do:
              p-mess = substitute("&1В товарной строке №&2 тип списания &3 не соответствует типу чека&4 &1"
                            , chr(10)
                            , p-line-num
                            , entry (lookup (string(if p-wro-code <> ? then p-wro-code else 0 ),  '?,0,1,-6,-9,2,-2,3,-3,-4,17':U), ',,Без_оплаты,Отмена_позиции,Полн_Отмена,Модификатор,Модификатор,Модификатор(+спис),Модификатор(-спис),Модификатор(-спис),Техпролив':U)
                            , entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)
                          ).
    end.
    else do:
      p-valid = yes.
    end.
  end.
  else do:
    p-valid = yes.
  end.
end.
end procedure.
procedure libchkvl_unit-type-qnty :
define input parameter p-chk-type as integer no-undo .
define input parameter p-line-num as integer no-undo .
define input parameter p-unit-type as character no-undo .
define input parameter p-unit-cli-type as character no-undo .
define input parameter p-src-code as character no-undo .
define input parameter p-in-code as character no-undo .
define input parameter p-src-qnty as decimal no-undo .
define input parameter p-min-rate as decimal no-undo .
define input parameter p-max-rate as decimal no-undo .
define output parameter p-valid as logical no-undo .
define output parameter p-mess as character no-undo .
define output parameter p-chr-err as character no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  if LOOKUP( 'сер':U, p-unit-type ) > 0  AND abs(p-src-qnty) <> 1 then do:
    p-mess = p-mess + chr(10) + substitute("Товар по коду &1 - серийный, кол-во должно быть=1", p-src-code).
    p-chr-err = p-chr-err + chr(44) + 'сер-ош':U.
  end.
  if LOOKUP( 'сер':U, p-unit-type ) > 0
  AND ( p-in-code = "" ) then do:
    p-mess =  substitute("Товар по коду &1 нельзя продавать БЕЗ учета серийного номера"
                        , p-src-code  ).
    p-chr-err = p-chr-err + chr(44) + 'сер-ош':U.
  end.
  if (LOOKUP( 'сер':U, p-unit-type ) > 0
  OR LOOKUP( '2ед':U, p-unit-type ) > 0 )
  AND NOT libchkvl_direct-sign(p-chk-type, p-src-qnty)
   then do:
    p-mess =  substitute("Не может быть строки аннуляции или отмены для товара по коду &2 с типом единицы измерения &1"
                        , p-unit-type
                        ,p-src-code).
    p-chr-err = p-chr-err + chr(44) + (if LOOKUP( 'сер':U, p-unit-type ) > 0
                                             then 'сер-ош':U
                                             else 'кол-ош':U).
  end.
  if lookup('2ед':U, p-unit-type) > 0  and (p-min-RATE = 0 or p-max-RATE = 0 )  then do:
    p-mess = substitute("Товар по коду &1 в справочнике имеет неверные значения полей КОЛИЧЕСТВО ДРОБНОГО В ШТУКЕ"
                         , p-src-code).
    p-chr-err = p-chr-err + chr(44) + 'кол-ош':U.
  end.
  if (lookup('2ед':U, p-unit-type) > 0 AND (abs(p-src-qnty) < p-min-RATE or abs(p-src-qnty) > p-max-RATE)) OR
      (lookup('доп':U, p-unit-type) > 0 AND NOT abs(p-src-qnty) = 1) then do:
    p-mess =  substitute("Товар по коду &1 не может быть продан с несоответствием количеств по основной и дополнительной единицам измерения"
                         , p-src-code ).
    p-chr-err = p-chr-err + chr(44) + 'кол-ош':U.
  end.
  p-chr-err = trim(p-chr-err, chr(44)).
  if p-chr-err = "" then
  p-valid = yes.
end.
end procedure.
procedure libchkvl_part-valid :
define input parameter p-chk-type as integer no-undo .
define input parameter p-line-num as integer no-undo .
define input parameter p-unit-type as character no-undo .
define input parameter p-unit-cli-type as character no-undo .
define input parameter p-src-code as character no-undo .
define input parameter p-in-code as character no-undo .
define input parameter p-part-code as character no-undo .
define input parameter p-cashparts as logical no-undo .
define input parameter p-src-qnty as decimal no-undo .
define output parameter p-valid as logical no-undo .
define output parameter p-mess as character no-undo .
define output parameter p-chr-err as character no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  if LOOKUP('сер':U, p-unit-type) = 0 then do:
    if p-cashparts and p-in-code = "" then do:
      p-mess = substitute("Партионный товар по коду &1 не может быть продан БЕЗ учета N партии"
                          , p-src-code).
      p-chr-err = p-chr-err + chr(44) + 'прт-ош':U .
    end.
    if NOT p-cashparts AND NOT (p-in-code = "" AND p-part-code = "") then do:
      p-mess = substitute("НЕПартионный товар по коду &1 не может быть продан по коду партии"
                              , p-src-code
                            ) .
      p-chr-err = p-chr-err + chr(44) + 'прт-ош':U.
    end.
  end.
  if lookup(p-unit-type, 'шту':U) > 0
  AND ( p-src-qnty - TRUNCATE( p-src-qnty , 0 ) <> 0) then do:
     p-mess =substitute("Штучный товар по коду &1 не может быть продан с дробным количеством"
                        , p-src-code
                            ).
    p-chr-err = p-chr-err + chr(44) + 'кол-ош':U.
  end.
  p-chr-err = trim(p-chr-err, chr(44)).
  if p-chr-err = "" then
  p-valid = yes.
end.
end procedure.
procedure libchkvl_prt-valid :
define input parameter p-chk-type as integer no-undo .
define input parameter p-line-num as integer no-undo .
define input parameter p-doc-prt as logical no-undo .
define input parameter p-src-code as character no-undo .
define input parameter p-empty-scale as logical no-undo .
define input parameter p-root-node-code as integer no-undo .
define input parameter p-node-code as integer no-undo .
define output parameter p-valid as logical no-undo .
define output parameter p-mess as character no-undo .
define output parameter p-chr-err as character no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  if p-doc-prt then do:
    if not p-empty-scale
    AND  can-find( first ub.gds-prt where ub.gds-prt.upper-code = p-node-code ) then do:
      p-mess = substitute("Товар по коду &1 не может быт продан БЕЗ признаков"
                         , p-src-code
                            ).
      p-chr-err = p-chr-err  + chr(44) + 'при-ош':U.
    end.
  end.
  else do:
    if p-root-node-code <> p-node-code then do:
      p-mess = substitute("Товар по коду &1 не может быть продан c признаками на объекте, где они выключены"
                          , p-src-code
                            ) .
      p-chr-err = p-chr-err + chr(44)  + 'при-ош':U.
    end.
  end.
  p-chr-err = trim(p-chr-err, chr(44)).
  if p-chr-err = "" then
  p-valid = yes.
end.
end procedure.
procedure libchkvl_fbr-valid :
define input parameter p-chk-type as integer no-undo .
define input parameter p-line-num as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-is-catering as logical no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-src-code as character no-undo .
define input parameter p-gds-code as integer no-undo .
define input parameter p-src-price as decimal no-undo .
define input parameter p-src-discnt as decimal no-undo .
define input parameter p-write-off-code as integer no-undo .
define input-output parameter p-depart-type as character no-undo .
define input-output parameter p-depart-code as integer no-undo .
define output parameter p-null-price as logical no-undo .
define output parameter p-valid as logical no-undo .
define output parameter p-mess as character no-undo .
define output parameter p-chr-err as character no-undo .
define variable v-depart-code as integer no-undo .
define variable v-depart-type as character no-undo .
define variable v-modificator-null-price as logical no-undo .
define buffer buf_shop for ub.shop.
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if p-is-catering
  and (
     p-pos-type = 'MAGIA-XML':U
  or p-pos-type = 'IBM':U
  or p-pos-type = 'IBM-XML':U
  or p-pos-type = 'r-keeper':U
  or p-pos-type = 'IBS-TH':U
  or p-pos-type = 'NCR-AS@R':U
  )
  then do:
    find first buf_fbr-gds-obj no-lock where
                buf_fbr-gds-obj.obj-type = p-obj-type
            AND buf_fbr-gds-obj.obj-code = p-obj-code
            AND buf_fbr-gds-obj.gds-code = p-gds-code no-error .
    if p-depart-code > 0 then v-depart-code = p-depart-code.
    else do:
      if available buf_fbr-gds-obj
      AND (buf_fbr-gds-obj.is-menu
           or
           buf_fbr-gds-obj.is-semi-finished)
      then do:
            assign
            v-depart-code = buf_fbr-gds-obj.fbr-obj-code
            v-depart-type = 'маг':U
            .
          if v-depart-code = ?
          or v-depart-code = 0  then do:
            p-mess = substitute("Произведенный товар по кодом &1 продан без ссылки  на ОБЪЕКТ  ПРОИЗВОДСТВА (кухню)"
                                , p-src-code
                                  ) .
            p-chr-err = p-chr-err + chr(44)  + 'тов-ош':U.
          end.
      end.
    end.
    if available buf_fbr-gds-obj
    and (buf_fbr-gds-obj.is-modificator
        and
        buf_fbr-gds-obj.is-null-price) then do:
      assign
      v-modificator-null-price = yes.
    end.
    else  do:
      assign
      v-modificator-null-price = no.
    end.
        if (lookup (STRING(if p-write-off-code <> ? then p-write-off-code else 0),  '2,-2,3,-3,-4':U) > 0) then do:
      if not v-modificator-null-price then do:
        p-mess = substitute("Указанный в чеке товар-модификатор по коду &1 с 0 ценой (&2) не имеет соответствующих признаков в атрибутах РЕСТОРАН &3&4"
                            , p-src-code
                            ,p-obj-type
                            ,p-obj-code
                              ) .
        p-chr-err = p-chr-err + chr(44)  + 'тов-ош':U.
      end.
      if p-src-price <> 0
      or p-src-discnt <> 0 then do:
        p-mess = substitute("Указанный в чеке товар-модификатор по коду &1 с 0 ценой (&2) имеет в чеке НЕНУЛЕВУЮ ЦЕНУ &4 или СКИДКУ &5"
                            , p-src-code
                            ,p-obj-type
                            ,p-obj-code
                              ) .
        p-chr-err = p-chr-err + chr(44)  + 'тов-ош':U.
      end.
    end.
  end.
  else do:
    assign
    v-depart-code = 0
    v-depart-type = ''
    .
  end.
  if v-depart-code <> ? and
      v-depart-code <> 0
  and v-depart-code <> p-obj-code    then do:
    find first buf_shop no-lock where
              buf_shop.obj-code = v-depart-code no-error .
    if not available buf_shop then do:
      assign
      v-depart-code = 0
      p-mess = substitute("Не найдена кухня &1&2, произведшая товар  с кодом &3"
                          ,'маг':U
                          ,p-obj-code
                          ,p-src-code
                            ) .
      p-chr-err = p-chr-err + chr(44)  + 'тов-ош':U.
    end.
    else do:
      assign
      v-depart-code = (if v-depart-code = ? then 0 else v-depart-code)
      v-depart-type = 'маг':U
      .
    end.
  end.
  if p-src-price = 0
  and not (lookup (STRING(if p-write-off-code <> ? then p-write-off-code else 0),  '2,-2,3,-3,-4':U) > 0)
  and not v-modificator-null-price
  and not p-chk-type = integer('11':U)
  and not p-pos-type = 'Autotank':U
  and not p-pos-type = 'IBM-XML':U
  and not p-pos-type = 'IBM':U
  and not p-pos-type = 'MAGIA-XML':U
  then do:
    p-mess = substitute("Товар с кодом &1: цена = 0"
                        ,p-src-code
                          ) .
    p-chr-err = p-chr-err + chr(44)  + 'сум-ош':U.
  end.
  assign
  p-depart-code = v-depart-code
  p-depart-type = v-depart-type
  p-chr-err = trim(p-chr-err, chr(44)).
  if p-chr-err = "" then
  p-valid = yes.
end.
end procedure.
procedure libchkvl_place-valid :
define input parameter p-chk-type as integer no-undo .
define input parameter p-line-num as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-src-code as character no-undo .
define input parameter p-gds-code as integer no-undo .
define input parameter p-loc1 as character no-undo .
define input parameter p-src-pl-code as integer no-undo .
define output parameter p-pl-code as integer no-undo .
define output parameter p-valid as logical no-undo .
define output parameter p-mess as character no-undo .
define output parameter p-chr-err as character no-undo .
define variable v-loc1-setted as logical no-undo .
define variable v-src-pl-code-setted as logical no-undo .
define buffer buf_place for ub.place.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  assign
  v-loc1-setted = p-loc1 <> '':U
                  and
                  p-loc1 <> ?
  v-src-pl-code-setted = p-src-pl-code <> ?
                          and
                          p-src-pl-code <> 0
  .
  if v-loc1-setted
  or v-src-pl-code-setted then do:
    find first buf_place no-lock where
              buf_place.obj-type = p-obj-type
          and buf_place.obj-code = p-obj-code
          and (buf_place.loc1 = p-loc1 or not v-loc1-setted)
          and (buf_place.pl-code = p-pl-code or not v-src-pl-code-setted)
    no-error.
    if not available buf_place then do:
      p-mess = substitute("Товар с кодом &1: указано неверное складское место &2 или резервуар &3"
                          ,p-src-code
                          ,p-loc1
                          ,p-src-pl-code
                            ) .
      p-chr-err = p-chr-err + chr(44)  + 'кол-ош':U.
    end.
    else do:
       p-pl-code = buf_place.pl-code.
    end.
  end.
  if p-chr-err = "" then
  p-valid = yes.
  end.
end procedure.
procedure libchkvl_petrol-valid :
define input parameter p-chk-type as integer no-undo .
define input parameter p-line-num as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-src-code as character no-undo .
define input parameter p-gds-code as integer no-undo .
define input parameter p-unit-type as character no-undo .
define input parameter p-pump as integer no-undo .
define input parameter p-nozzle-code as integer no-undo .
define output parameter p-valid as logical no-undo .
define output parameter p-mess as character no-undo .
define output parameter p-chr-err as character no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if lookup(string(p-chk-type), '14,15,16,17,36':U) > 0
  and LOOKUP('топ':U, p-unit-type) = 0
  then do:
      p-mess = substitute("Чек типа &2, но товар с кодом &1 не топливный&2"
                           , entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)
                          ,p-src-code
                            ) .
      p-chr-err = p-chr-err + chr(44)  + 'тов-ош':U.
  end.
  IF  p-pump > 0
  and LOOKUP('топ':U, p-unit-type) = 0 then do:
      p-mess = substitute("Номер ТРК > 0, но товар с кодом &1 не топливный&2"
                          ,p-src-code
                            ) .
      p-chr-err = p-chr-err + chr(44)  + 'тов-ош':U.
  end.
  IF p-pump = 0
  and LOOKUP('топ':U, p-unit-type) > 0
  AND LOOKUP('шту':U, p-unit-type) = 0 then do:
    p-mess = substitute("Товар с кодом &1 топливо, но номер ТРК = 0"
                        ,p-src-code
                          ) .
    p-chr-err = p-chr-err + chr(44)  + 'тов-ош':U.
  end.
  if p-chr-err = "" then
  p-valid = yes.
end.
end procedure.
procedure libchkvl_create-context :
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-context-bh as handle no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable v-conf-par as character no-undo .
define variable v-par-type as character no-undo .
define buffer buf_sysconf for ub.sysconf.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_clients for ub.clients.
define buffer buf_shop for ub.shop.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-parparentproc       as widget-handle           no-undo .
define variable v-p-log-handle        as handle                  no-undo .
define variable v-p-log-file-name     as character               no-undo .
define variable v-view-log            as logical                 no-undo .
define variable v-ll                  as integer                 no-undo .
define variable v-tt-wd-bh            as handle                  no-undo .
define variable v-pos-type            as character               no-undo .
define variable v-cash-num            as integer                 no-undo .
define variable v-obj-type            as character init 'маг':U  no-undo .
define variable v-obj-code            as integer                 no-undo .
define variable v-db-num              as integer                 no-undo .
define variable v-r-b                 as character               no-undo .
define variable v-host-code           as integer                 no-undo .
define variable v-base-code           as integer                 no-undo .
define variable v-cre-pay             as integer                 no-undo .
define variable v-is-catering         as logical                 no-undo .
define variable v-is-cdinv            as logical                 no-undo .
define variable v-is-ptrl             as logical                 no-undo .
define variable v-is-wth              as logical                 no-undo .
define variable v-process-sale        as logical                 no-undo .
define variable v-dc-mask             as logical                 no-undo .
define variable v-card-by-mask        as logical                 no-undo .
define variable v-sclspref            as character               no-undo .
define variable v-scpgpref            as character               no-undo .
define variable v-scpgpref-pre        as character               no-undo .
define variable v-doc-prt             as logical                 no-undo .
define variable v-shift-on            as logical                 no-undo .
define variable v-cas-shft            as logical                 no-undo .
define variable v-t-shft              as integer                 no-undo .
define variable v-v-shft              as integer                 no-undo .
define variable v-ptrl-check          as logical                 no-undo .
define variable v-annu-check          as logical                 no-undo .
define variable v-z-check             as logical                 no-undo .
define variable v-hnum                as logical                 no-undo .
define variable v-is-100-discnt       as logical                 no-undo .
define variable v-zero-cashier        as integer                 no-undo .
define variable v-rnd-znak            as integer                 no-undo .
define variable v-cas-curs            as logical                 no-undo .
define variable v-nam-2str            as logical                 no-undo .
define variable v-nam-artc            as logical                 no-undo .
define variable v-cod-pcod            as logical                 no-undo .
define variable v-name-2cd            as character               no-undo .
define variable v-how-temp-disc       as character               no-undo .
define variable v-nalc                as integer                 no-undo .
define variable v-rmethod-type        as character               no-undo .
define variable v-rmethod-coeff       as decimal                 no-undo .
define variable v-serial-code         as character               no-undo .
define variable v-salesman-mandatory  as integer                 no-undo .
define variable v-sales-man           as integer                 no-undo .
define variable v-salesman-psn-code   as integer                 no-undo .
define variable v-pos-type-for-discnt as character               no-undo .
define variable v-manual-discnt       as integer                 no-undo .
define variable v-is-grp-totals       as logical                 no-undo .
define variable v-is-gds-totals       as logical                 no-undo .
define variable v-cash-counter        as decimal                 no-undo .
define variable v-pre-cash-counter    as decimal                 no-undo .
define variable v-qnty-change         as logical                 no-undo .
define variable v-log-level           as integer                 no-undo .
define variable v-chk-discnt-table    as handle                  no-undo .
define variable v-chk-gds-table       as handle                  no-undo .
define variable v-chk-pay-table       as handle                  no-undo .
define variable v-z-number            as integer                 no-undo .
define variable v-shift-num           as integer                 no-undo .
define variable v-shift-date          as date                    no-undo .
define variable v-shift-name          as character               no-undo .
define variable v-emulator-mode       as integer                 no-undo .
define variable v-ibmgroup            as logical                 no-undo .
define buffer buf_libchkvl_dis-card-mask for libchkvl_dis-card-mask.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if p-obj-type <> 'маг':U then do:
    undo, return error substitute("Неверный тип объекта = &1", p-obj-type).
  end.
  for each buf_libchkvl_dis-card-mask:
    delete buf_libchkvl_dis-card-mask.
  end.
  p-context-bh:empty-temp-table().
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-r-b
  )  .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref-type19 as character no-undo.
v-sclspref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-sclspref
  ,output varscales-pref-type19
  ) no-error .
if v-sclspref = ? then do:
  assign
  v-sclspref = '21,23,25':U.
end.
define variable varpgscales-pref-type19 as character no-undo.
v-scpgpref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-scpgpref
  ,output varpgscales-pref-type19
  ) no-error .
if v-scpgpref = ? then do:
  assign
  v-scpgpref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
  v-scpgpref-pre = v-scpgpref.
  define variable v-ii as integer no-undo .
  do v-ii = 1 to num-entries(v-scpgpref):
    entry(v-ii, v-scpgpref-pre) = substring(entry(v-ii, v-scpgpref-pre), 1, 2).
  end.
  v-conf-par = "".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-cdinv'
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  NO
  ,output v-conf-par
  ,output v-par-type
  ) NO-ERROR .
  assign
  v-is-cdinv = logical(v-conf-par)
  no-error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-ptrl'
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  NO
  ,output v-conf-par
  ,output v-par-type
  ) NO-ERROR .
  assign
  v-is-ptrl = logical(v-conf-par)
  no-error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-wth'
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  NO
  ,output v-conf-par
  ,output v-par-type
  ) NO-ERROR .
  assign
  v-is-wth = logical(v-conf-par)
  no-error .
  find first buf_sysconf no-lock where
          buf_sysconf.host-code = v-host-code.
  .
  assign
  v-base-code = buf_sysconf.base-code.
  find first buf_shop no-lock where
            buf_shop.obj-code = p-obj-code no-error .
  assign
  v-obj-code = p-obj-code
  v-obj-type = 'маг':U
  v-doc-prt = buf_shop.doc-prt
  v-shift-on = buf_shop.shift-on
  v-is-catering = buf_shop.is-catering
  .
  find first buf_clients no-lock where
            buf_clients.obj-type = p-obj-type
        AND  buf_clients.obj-code = p-obj-code.
  assign
  v-db-num = buf_clients.db-num
  .
  v-rnd-znak = 2.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'nakl-glob':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'rnd-znk':U then v-rnd-znak = thbjattr_thbj-attr.property-value-integer .
end.
empty temp-table thbjattr_thbj-attr.
  find first buf_Cash-pay no-lock where
            buf_cash-pay.cdpay-code = buf_sysconf.credit-pay no-error.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'iscredit'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-conf-par
  ,output v-par-type
  ) no-error .
  if error-status:error
  or not available buf_cash-pay
  or buf_cash-pay.is-credit = no
  or v-conf-par <> "yes"
  then do:
      assign
      v-cre-pay = 0
      .
  end.
  else do:
    assign
    v-cre-pay = buf_sysconf.credit-pay
    .
  end.
  assign
  v-tth = buffer thbjattr_thbj-attr:table-handle .
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
  run adm/shattri.p (
      input "get":U
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  'get-chk':U
      ,input  ''
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  IF error-status:error then do:
    delete object v-tth.
    undo, return error  substitute("Ошибка при получении опций закачки чеков НА ОБЪЕКТЕ &1&2:&3&4 &5"
              , p-obj-type
              , p-obj-code
              , chr(10)
              , error-status:get-message(1)
              , return-value ).
  end.
  for each thbjattr_thbj-attr  where
          thbjattr_thbj-attr.obj-type = p-obj-type
      and thbjattr_thbj-attr.obj-code = p-obj-code
      and thbjattr_thbj-attr.upper-prop-code = 'get-chk':U
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    case thbjattr_thbj-attr.prop-code:
      when 'cas-shft':U then do:
        v-cas-shft = thbjattr_thbj-attr.property-value-logical.
      end.
      when 'cas-curs':U then do:
        v-cas-curs = thbjattr_thbj-attr.property-value-logical.
      end.
      when 'hnum':U then do:
        v-hnum = thbjattr_thbj-attr.property-value-logical.
      end.
      when 't-shft':U then do:
        v-t-shft = thbjattr_thbj-attr.property-value-integer.
      end.
      when 'v-shft':U then do:
        v-v-shft = thbjattr_thbj-attr.property-value-integer.
      end.
      when 'dc-mask':U then do:
        v-dc-mask = thbjattr_thbj-attr.property-value-logical.
      end.
      when 'card-by-mask':U then do:
        v-card-by-mask = thbjattr_thbj-attr.property-value-logical.
      end.
      when 'ptrl-check':U then do:
        v-ptrl-check = thbjattr_thbj-attr.property-value-logical.
      end.
      when 'annu-check':U then do:
        v-annu-check = thbjattr_thbj-attr.property-value-logical.
      end.
      when 'z-check':U then do:
        v-z-check = thbjattr_thbj-attr.property-value-logical.
      end.
      when 'is-100-discnt':U then do:
        v-is-100-discnt = thbjattr_thbj-attr.property-value-logical.
      end.
      when 'zero-cashier':U then do:
        v-zero-cashier = thbjattr_thbj-attr.property-value-integer.
      end.
    end case.
  end.
  if v-dc-mask or v-card-by-mask then do:
    run libchkvl_get-dc-mask-array in this-procedure (
                                                      input v-host-code
                                                    , input p-obj-type
                                                    , input p-obj-code).
  end.
  p-context-bh:buffer-create().
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
p-context-bh::parparentproc                      =  v-parparentproc
p-context-bh::p-log-handle                       =  v-p-log-handle
p-context-bh::p-log-file-name                    =  v-p-log-file-name
p-context-bh::view-log                           =  v-view-log
p-context-bh::ll                                 =  v-ll
p-context-bh::tt-wd-bh                           =  v-tt-wd-bh
p-context-bh::pos-type                           =  v-pos-type
p-context-bh::cash-num                           =  v-cash-num
p-context-bh::obj-type                           =  v-obj-type
p-context-bh::db-num                             =  v-db-num
p-context-bh::obj-code                           =  v-obj-code
p-context-bh::r-b                                =  v-r-b
p-context-bh::host-code                          =  v-host-code
p-context-bh::base-code                          =  v-base-code
p-context-bh::cre-pay                            =  v-cre-pay
p-context-bh::is-catering                        =  v-is-catering
p-context-bh::is-cdinv                           =  v-is-cdinv
p-context-bh::is-ptrl                            =  v-is-ptrl
p-context-bh::is-wth                             =  v-is-wth
p-context-bh::dc-mask                            =  v-dc-mask
p-context-bh::card-by-mask                       =  v-card-by-mask
p-context-bh::sclspref                           =  v-sclspref
p-context-bh::scpgpref                           =  v-scpgpref
p-context-bh::scpgpref-pre                       =  v-scpgpref-pre
p-context-bh::doc-prt                            =  v-doc-prt
p-context-bh::shift-on                           =  v-shift-on
p-context-bh::cas-shft                           =  v-cas-shft
p-context-bh::t-shft                             =  v-t-shft
p-context-bh::v-shft                             =  v-v-shft
p-context-bh::ptrl-check                         =  v-ptrl-check
p-context-bh::annu-check                         =  v-annu-check
p-context-bh::z-check                            =  v-z-check
p-context-bh::hnum                               =  v-hnum
p-context-bh::is-100-discnt                      =  v-is-100-discnt
p-context-bh::zero-cashier                       =  v-zero-cashier
p-context-bh::rnd-znak                           =  v-rnd-znak
p-context-bh::cas-curs                           =  v-cas-curs
p-context-bh::nam-2str                           =  v-nam-2str
p-context-bh::nam-artc                           =  v-nam-artc
p-context-bh::cod-pcod                           =  v-cod-pcod
p-context-bh::name-2cd                           =  v-name-2cd
p-context-bh::how-temp-disc                      =  v-how-temp-disc
p-context-bh::nalc                               =  v-nalc
p-context-bh::serial-code                        =  v-serial-code
p-context-bh::salesman-mandatory                 =  v-salesman-mandatory
p-context-bh::sales-man                          =  v-sales-man
p-context-bh::salesman-psn-code                  =  v-salesman-psn-code
p-context-bh::pos-type-for-discnt                =  v-pos-type-for-discnt
p-context-bh::manual-discnt                      =  v-manual-discnt
p-context-bh::is-grp-totals                      =  v-is-grp-totals
p-context-bh::is-gds-totals                      =  v-is-gds-totals
p-context-bh::chk-discnt-table                   =  v-chk-discnt-table
p-context-bh::chk-gds-table                      =  v-chk-gds-table
p-context-bh::chk-pay-table                      =  v-chk-pay-table
p-context-bh::z-number                           =  v-z-number
p-context-bh::shift-num                          =  v-shift-num
p-context-bh::shift-date                         =  v-shift-date
p-context-bh::shift-name                         =  v-shift-name
p-context-bh::emulator-mode                      =  v-emulator-mode
p-context-bh::ibmgroup                           =  v-ibmgroup
.
  p-context-bh:buffer-release().
  delete object v-tth.
end.
end procedure.
procedure libchkvl_getcheck :
define input parameter p-context-bh as handle no-undo .
define input parameter p-wmode as character no-undo .
define input parameter p-edit-mode as character no-undo .
define input parameter p-close-check as logical no-undo .
define input parameter p-get-cash-shift as logical no-undo .
define input parameter p-netto as decimal no-undo .
define input parameter p-lng-sub-d as integer no-undo .
define input parameter p-sub-d as decimal no-undo .
define input parameter p-discnt-id as integer no-undo .
define input-output parameter p-prev-code like ub.chk-doc.doc-code no-undo .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-parparentproc       as widget-handle           no-undo .
define variable v-p-log-handle        as handle                  no-undo .
define variable v-p-log-file-name     as character               no-undo .
define variable v-view-log            as logical                 no-undo .
define variable v-ll                  as integer                 no-undo .
define variable v-tt-wd-bh            as handle                  no-undo .
define variable v-pos-type            as character               no-undo .
define variable v-cash-num            as integer                 no-undo .
define variable v-obj-type            as character init 'маг':U  no-undo .
define variable v-obj-code            as integer                 no-undo .
define variable v-db-num              as integer                 no-undo .
define variable v-r-b                 as character               no-undo .
define variable v-host-code           as integer                 no-undo .
define variable v-base-code           as integer                 no-undo .
define variable v-cre-pay             as integer                 no-undo .
define variable v-is-catering         as logical                 no-undo .
define variable v-is-cdinv            as logical                 no-undo .
define variable v-is-ptrl             as logical                 no-undo .
define variable v-is-wth              as logical                 no-undo .
define variable v-process-sale        as logical                 no-undo .
define variable v-dc-mask             as logical                 no-undo .
define variable v-card-by-mask        as logical                 no-undo .
define variable v-sclspref            as character               no-undo .
define variable v-scpgpref            as character               no-undo .
define variable v-scpgpref-pre        as character               no-undo .
define variable v-doc-prt             as logical                 no-undo .
define variable v-shift-on            as logical                 no-undo .
define variable v-cas-shft            as logical                 no-undo .
define variable v-t-shft              as integer                 no-undo .
define variable v-v-shft              as integer                 no-undo .
define variable v-ptrl-check          as logical                 no-undo .
define variable v-annu-check          as logical                 no-undo .
define variable v-z-check             as logical                 no-undo .
define variable v-hnum                as logical                 no-undo .
define variable v-is-100-discnt       as logical                 no-undo .
define variable v-zero-cashier        as integer                 no-undo .
define variable v-rnd-znak            as integer                 no-undo .
define variable v-cas-curs            as logical                 no-undo .
define variable v-nam-2str            as logical                 no-undo .
define variable v-nam-artc            as logical                 no-undo .
define variable v-cod-pcod            as logical                 no-undo .
define variable v-name-2cd            as character               no-undo .
define variable v-how-temp-disc       as character               no-undo .
define variable v-nalc                as integer                 no-undo .
define variable v-rmethod-type        as character               no-undo .
define variable v-rmethod-coeff       as decimal                 no-undo .
define variable v-serial-code         as character               no-undo .
define variable v-salesman-mandatory  as integer                 no-undo .
define variable v-sales-man           as integer                 no-undo .
define variable v-salesman-psn-code   as integer                 no-undo .
define variable v-pos-type-for-discnt as character               no-undo .
define variable v-manual-discnt       as integer                 no-undo .
define variable v-is-grp-totals       as logical                 no-undo .
define variable v-is-gds-totals       as logical                 no-undo .
define variable v-cash-counter        as decimal                 no-undo .
define variable v-pre-cash-counter    as decimal                 no-undo .
define variable v-qnty-change         as logical                 no-undo .
define variable v-log-level           as integer                 no-undo .
define variable v-chk-discnt-table    as handle                  no-undo .
define variable v-chk-gds-table       as handle                  no-undo .
define variable v-chk-pay-table       as handle                  no-undo .
define variable v-z-number            as integer                 no-undo .
define variable v-shift-num           as integer                 no-undo .
define variable v-shift-date          as date                    no-undo .
define variable v-shift-name          as character               no-undo .
define variable v-emulator-mode       as integer                 no-undo .
define variable v-ibmgroup            as logical                 no-undo .
DEFINE VARIABLE var-pcnt-discnt            as   recid                 no-undo .
DEFINE VARIABLE CorrValue                  as   decimal               no-undo .
define variable corr-sign                  as   integer               no-undo .
DEFINE VARIABLE str-dec                    as   decimal               no-undo .
DEFINE VARIABLE temp-d                     as   decimal               no-undo .
DEFINE VARIABLE cashparts                  like ub.gds-obj.cash-parts    no-undo .
DEFINE VARIABLE iserr                      like ub.chk-gds.is-error      no-undo .
DEFINE VARIABLE var-gds-for-discnt         as decimal                 no-undo .
DEFINE VARIABLE v-discnt-sum               as decimal                 no-undo .
DEFINE VARIABLE netto-for-tot-d-pcnt       as decimal                 no-undo .
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
DEFINE VARIABLE v-price-from-check           like ub.chk-gds.price-base    no-undo .
DEFINE VARIABLE v-units-rate                 as   decimal               no-undo .
DEFINE VARIABLE v-units-dpcnt                as   decimal               no-undo .
DEFINE VARIABLE v-b-c                        like ub.bar-code.b-code       no-undo .
DEFINE VARIABLE v-bc-buf                     as   character             no-undo .
DEFINE VARIABLE v-bc-buf2                    as   character             no-undo .
define variable v-is-null-price              as logical no-undo .
define variable accum-pay                    as decimal                 no-undo .
define variable accum-count                  as integer                 no-undo .
define variable accum-pay-count              as integer                 no-undo .
define variable v-rb                         as logical                 no-undo .
define variable v-card-correct               as logical                 no-undo .
define variable v-write-off-sum              as decimal                 no-undo .
define variable main-gds-type                like ub.goods.gds-type no-undo .
define variable v-doc-rec                    as recid                   no-undo .
define variable v-d-card                     like ub.dis-card.d-card    no-undo .
define variable v-src-d-card                 like ub.chk-doc.src-d-card no-undo .
define variable v-found                      as logical                 no-undo .
define variable v-descr                      as character               no-undo .
define variable v-is-correct                 as logical                 no-undo .
define variable v-th-mask                    as logical                 no-undo .
define variable v-short-number               like ub.dis-card.d-card    no-undo .
define variable v-is-petrol-check            as logical                 no-undo .
define variable v-is-annu-check              as logical                 no-undo .
define variable v-cashier-psn-code           like ub.person.psn-code    no-undo .
define variable v-seller-psn-code            like ub.person.psn-code    no-undo .
define variable v-is-inventory               as logical                 no-undo .
define variable v-is-z-rep                   as logical                 no-undo .
define variable v-is-shft-open-close         as logical                 no-undo .
define variable v-is-ord-check               as logical                 no-undo .
define variable v-bc-rcnz-only-bc            as logical                 no-undo .
define variable v-d-mask                     as character no-undo .
define variable v-kriv-z-qnty                as logical                 no-undo .
DEFINE VARIABLE for-chk-type               as   character             no-undo init "".
DEFINE VARIABLE shift-name_                like ub.chk-doc.shift-name  no-undo .
DEFINE VARIABLE var-discnt-id             as   integer               no-undo .
DEFINE VARIABLE NoExchRate                 as   logical init FALSE    no-undo .
DEFINE VARIABLE r-bar-code                 like ub.bar-code.b-code       no-undo .
define variable v-fttwd as logical no-undo .
define variable v-pos-type-int               as integer                 no-undo .
define variable v-is-petrol-promo            as logical                 no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable mask_s-c as character no-undo .
define variable v-tth as handle no-undo .
define variable vSumRound as decimal no-undo.
define variable iii as integer no-undo .
define variable v-promo-sum as decimal no-undo.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer for-gds for ub.chk-gds.
define buffer for-goods for ub.goods.
define buffer for-bar for ub.bar-code.
define buffer b1-gds-prt for ub.gds-prt .
define buffer buf_shop for ub.clients.
define buffer buf_cash-desk for ub.cash-desk.
define buffer buf_libchkvl_dis-card-mask for libchkvl_dis-card-mask.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
define buffer buf_curr-shop for ub.curr-shop.
define buffer buf_shift-cash for ub.shift-cash.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf0_chk-discnt for ub.chk-discnt.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_place for ub.place.
define buffer buf_goods for ub.goods.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_units for ub.units.
define buffer buf_marking-chk for ub.marking-chk .
define buffer buf_chk-gds-attr for ub.chk-gds-attr .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if p-prev-code = "":U then return.
  FIND buf_chk-doc share-lock WHERE
        buf_chk-doc.doc-code = p-prev-code NO-ERROR.
  if not avail buf_chk-doc then do:
    return.
  end.
run adm/shattri.p (
    input "get":U
    ,input  chk-doc.obj-type
    ,input  chk-doc.obj-code
    ,input  'cd-sending':U
    ,input  'mask_s-c':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF not error-status:error
then mask_s-c = v-value-character.
else mask_s-c = "".
delete object v-tth no-error.
  define buffer buf66_chk-discnt for ub.chk-discnt.
  find first buf66_chk-discnt no-lock where
            buf66_chk-discnt.doc-code = p-prev-code
        and buf66_chk-discnt.record-type = 2 no-error.
  if available buf66_chk-discnt then do:
    message
    "Попытка повторного вызова процедуры getcheck зовите программистов"
    view-as alert-box error .
    run gbl/inidebug.p .
  end.
  if buf_chk-doc.prev-chk-type = ? then do:
    buf_chk-doc.prev-chk-type = 0.
  end.
  var-discnt-id = p-discnt-id.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
v-parparentproc                      =  p-context-bh::parparentproc
v-p-log-handle                       =  p-context-bh::p-log-handle
v-p-log-file-name                    =  p-context-bh::p-log-file-name
v-view-log                           =  p-context-bh::view-log
v-ll                                 =  p-context-bh::ll
v-tt-wd-bh                           =  p-context-bh::tt-wd-bh
v-pos-type                           =  p-context-bh::pos-type
v-cash-num                           =  p-context-bh::cash-num
v-obj-type                           =  p-context-bh::obj-type
v-db-num                             =  p-context-bh::db-num
v-obj-code                           =  p-context-bh::obj-code
v-r-b                                =  p-context-bh::r-b
v-host-code                          =  p-context-bh::host-code
v-base-code                          =  p-context-bh::base-code
v-cre-pay                            =  p-context-bh::cre-pay
v-is-catering                        =  p-context-bh::is-catering
v-is-cdinv                           =  p-context-bh::is-cdinv
v-is-ptrl                            =  p-context-bh::is-ptrl
v-is-wth                             =  p-context-bh::is-wth
v-dc-mask                            =  p-context-bh::dc-mask
v-card-by-mask                       =  p-context-bh::card-by-mask
v-sclspref                           =  p-context-bh::sclspref
v-scpgpref                           =  p-context-bh::scpgpref
v-scpgpref-pre                       =  p-context-bh::scpgpref-pre
v-doc-prt                            =  p-context-bh::doc-prt
v-shift-on                           =  p-context-bh::shift-on
v-cas-shft                           =  p-context-bh::cas-shft
v-t-shft                             =  p-context-bh::t-shft
v-v-shft                             =  p-context-bh::v-shft
v-ptrl-check                         =  p-context-bh::ptrl-check
v-annu-check                         =  p-context-bh::annu-check
v-z-check                            =  p-context-bh::z-check
v-hnum                               =  p-context-bh::hnum
v-is-100-discnt                      =  p-context-bh::is-100-discnt
v-zero-cashier                       =  p-context-bh::zero-cashier
v-rnd-znak                           =  p-context-bh::rnd-znak
v-cas-curs                           =  p-context-bh::cas-curs
v-nam-2str                           =  p-context-bh::nam-2str
v-nam-artc                           =  p-context-bh::nam-artc
v-cod-pcod                           =  p-context-bh::cod-pcod
v-name-2cd                           =  p-context-bh::name-2cd
v-how-temp-disc                      =  p-context-bh::how-temp-disc
v-nalc                               =  p-context-bh::nalc
v-serial-code                        =  p-context-bh::serial-code
v-salesman-mandatory                 =  p-context-bh::salesman-mandatory
v-sales-man                          =  p-context-bh::sales-man
v-salesman-psn-code                  =  p-context-bh::salesman-psn-code
v-pos-type-for-discnt                =  p-context-bh::pos-type-for-discnt
v-manual-discnt                      =  p-context-bh::manual-discnt
v-is-grp-totals                      =  p-context-bh::is-grp-totals
v-is-gds-totals                      =  p-context-bh::is-gds-totals
v-chk-discnt-table                   =  p-context-bh::chk-discnt-table
v-chk-gds-table                      =  p-context-bh::chk-gds-table
v-chk-pay-table                      =  p-context-bh::chk-pay-table
v-z-number                           =  p-context-bh::z-number
v-shift-num                          =  p-context-bh::shift-num
v-shift-date                         =  p-context-bh::shift-date
v-shift-name                         =  p-context-bh::shift-name
v-emulator-mode                      =  p-context-bh::emulator-mode
v-ibmgroup                           =  p-context-bh::ibmgroup
.
  if v-p-log-file-name <> ""
  and v-p-log-file-name <> ? then do:
     log-file-name = v-p-log-file-name.
  end.
  else do:
    log-file-name = log-file-name0.
  end.
    v-pos-type-int = integer(entry(lookup(v-pos-type, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,r-keeper,Emulator-NKT-IBM,MARIA,IBS-TH,IBS-TH-MOB':U), '2,13,1,3,4,5,6,7,8,9,11,12,14,15':U)).
  for each t-gds :
    delete t-gds.
  end.
  for each t-pay :
    delete t-pay.
  end.
  if not v-ibmgroup AND
    (
    LOOKUP('сумма':U, for-chk-type ) > 0 and
    LOOKUP('т':U, for-chk-type ) = 0 AND
    LOOKUP('у':U, for-chk-type ) = 0 AND
    LOOKUP('тов-ош':U, for-chk-type ) = 0 AND
    LOOKUP("0":U, for-chk-type ) = 0
    )  then do:
    _sum-chk:
    do
    on error undo, return error
    :
      for each buf_chk-gds where
              buf_chk-gds.doc-code = buf_chk-doc.doc-code
      on error undo _sum-chk, return error :
        delete buf_chk-gds.
      end.
      for each buf_chk-pay where
              buf_chk-pay.doc-code = buf_chk-doc.doc-code
      on error undo _sum-chk, return error :
        delete buf_chk-pay.
      end.
      for each buf_chk-discnt where
              buf_chk-discnt.doc-code = buf_chk-doc.doc-code
      on error undo _sum-chk, return error :
        delete buf_chk-discnt.
      end.
      for each buf_chk-gds-pay where
              buf_chk-gds-pay.doc-code = buf_chk-doc.doc-code
      on error undo _sum-chk, return error :
        delete buf_chk-gds-pay.
      end.
      delete buf_chk-doc.
      p-prev-code = "":U.
      v-ll = v-ll - 1.
      return.
    end.
  end.
  if lookup(string(buf_chk-doc.chk-type) , '14,15,16,17,36':U) > 0 then do:
    v-is-petrol-check = yes.
  end.
  if lookup(string(buf_chk-doc.chk-type), '8,108,208':U) > 0 then do:
    assign
    v-is-annu-check = yes.
  end.
  if lookup(string(buf_chk-doc.chk-type), '201,206,208,301,306':U) > 0 then do:
    assign
    v-is-ord-check = yes.
  end.
  if buf_chk-doc.chk-type = integer('11':U) then do:
    assign
    v-is-inventory = yes.
  end.
  if buf_chk-doc.chk-type = integer('12':U) then do:
    assign
    v-is-z-rep = yes.
    if buf_chk-doc.z-number = 0 then do:
      if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                               "!!!Чек &1 - ошибочный. &2 Нет сведений о № z-отчета&2"                               , buf_chk-doc.doc-code                               , chr(10)                             ) ).
    end.
  end.
  if    buf_chk-doc.chk-type = integer('13':U)
     or buf_chk-doc.chk-type = integer('40':U)
  then do:
    assign
    v-is-shft-open-close = yes.
  end.
  if v-hnum then do:
    find first buf_shop no-lock where
          buf_shop.obj-code = buf_chk-doc.obj-code
      and buf_shop.obj-type = 'маг':U no-error .
    if not available buf_shop
    or buf_shop.db-num <> g#db-num
    then do:
      assign
      for-chk-type = for-chk-type + 'сум-ош':U + chr(44)
      v-view-log = yes
      buf_chk-doc.correct = no
      .
      if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                               "!!!Чек &1 - ошибочный. &2 Нет сведений о магазине &3 или он принадлежит другой БД&2" +                               "(номер магазина получен из спула в соответствии с настройками)&2" +                                "ЧЕК БУДЕТ ПРИПИСАН К МАГАЗИНУ &4 ДЛЯ ВОЗМОЖНОСТИ ПОСЛЕДУЮЩЕГО УДАЛЕНИЯ"                               , buf_chk-doc.doc-code                               , chr(10)                               , buf_chk-doc.obj-code                               , v-obj-code) ).
      buf_chk-doc.obj-code = v-obj-code.
      for each buf_chk-pay where
              buf_chk-pay.doc-code = buf_chk-doc.doc-code
      on error undo, return error :
        buf_chk-pay.obj-code = v-obj-code.
      end.
      for each buf_chk-discnt where
              buf_chk-discnt.doc-code = buf_chk-doc.doc-code
      on error undo, return error :
        buf_chk-discnt.obj-code = v-obj-code.
      end.
    end.
  end.
  if buf_chk-doc.pay-desk <> 0 then do:
    find first buf_cash-desk no-lock where
              buf_cash-desk.cash-num = buf_chk-doc.pay-desk
        AND buf_cash-desk.obj-code = buf_chk-doc.obj-code
        AND buf_cash-desk.pos-type = v-pos-type no-error .
  end.
  if buf_chk-doc.pay-desk = 0
  or not available buf_cash-desk
  or buf_cash-desk.is-del then do:
    if can-find(first ub.cash-desk where
                        ub.cash-desk.cash-num = 0
                    and ub.cash-desk.obj-code = buf_chk-doc.obj-code
                    and ub.cash-desk.pos-type = 'Autotank':U
                    )
          and can-find(first ub.cash-desk where
                        ub.cash-desk.cash-num = buf_chk-doc.pay-desk
                    and ub.cash-desk.obj-code = buf_chk-doc.obj-code
                    and ub.cash-desk.pos-type = 'Autotank':U
                    and buf_chk-doc.pay-desk > 0 )
    then do:
      v-pos-type-int = integer('13':U).
    end.
    else do:
      find first buf_cash-desk no-lock where
              buf_cash-desk.cash-num = buf_chk-doc.pay-desk
          AND buf_cash-desk.obj-code = buf_chk-doc.obj-code no-error.
      if available buf_cash-desk then do:
                v-pos-type-int = integer(entry(lookup(buf_cash-desk.pos-type, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,r-keeper,Emulator-NKT-IBM,MARIA,IBS-TH,IBS-TH-MOB':U), '2,13,1,3,4,5,6,7,8,9,11,12,14,15':U)).
      end.
      else do:
        v-pos-type-int = integer('0':U).
      end.
      assign
      for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
      v-view-log = yes
      buf_chk-doc.correct = no
      .
      if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                             "!!!Чек &1 - ошибочный. &2 Нет сведений о кассе &3 с типом &4"                             , buf_chk-doc.doc-code                             , chr(10)                             , buf_chk-doc.pay-desk                             , v-pos-type) ).
    end.
  end.
  if v-is-z-rep = yes
  and available buf_cash-desk then do:
    entry(1, buf_chk-doc.doc-num2, chr(4)) = buf_cash-desk.registration-code + chr(44) +  buf_cash-desk.serial-code .
  end.
  assign
  buf_chk-doc.shift-date = if v-t-shft < 0 AND buf_chk-doc.chk-time < abs(v-t-shft)
                        then (buf_chk-doc.chk-date - 1)
                        else (if buf_chk-doc.src-shift-date = ?
                              then buf_chk-doc.chk-date
                              else
                                  (If p-wmode = 'ИЗМЕНЕНИЕ':U
                                    then
                                          (if index(buf_chk-doc.ps, "shift!") = 0
                                          then buf_chk-doc.src-shift-date
                                          else buf_chk-doc.shift-date)
                                    else
                                          buf_chk-doc.src-shift-date
                                    )
                              )
  .
  if v-cas-shft then do:
    if buf_chk-doc.shift-name = ''
    or trim(buf_chk-doc.shift-name, '0') = '':U
      then  do:
      assign
      for-chk-type = for-chk-type + 'смн-ош':U + chr(44)
      buf_chk-doc.shift-date = 01/01/1990
      buf_chk-doc.correct = no
      .
    end.
    else do:
      if v-v-shft > 0 then do:
        run str/v-shftg.p (
                            buffer buf_chk-doc
                            ,input v-parparentproc
                            ,input v-p-log-handle
                            ,input p-wmode
                            ,input v-obj-code
                            ,input v-obj-type
                            ,input v-v-shft
                            ,input v-t-shft
                            ,input 'смн-ош':U
                            ,input-output for-chk-type
                            ,input-output v-view-log
                    ).
      end.
      if v-shift-on then do:
        if  (p-wmode = 'ИЗМЕНЕНИЕ':U and  index(buf_chk-doc.ps, "shift!") = 0)
        or  p-wmode = 'ДОБАВЛЕНИЕ':U
        then do:
          run libchkvl_get-shift-num in this-procedure (
                                                input buf_chk-doc.obj-type
                                              ,input buf_chk-doc.obj-code
                                              ,input buf_chk-doc.shift-date
                                              ,input buf_chk-doc.shift-name
                                              ,output buf_chk-doc.shift-num) no-error .
          if error-status:error
          or buf_chk-doc.shift-num = ?
          or buf_chk-doc.shift-num = 0 then do:
          assign
          for-chk-type = for-chk-type + 'смн-ош':U + chr(44)
          buf_chk-doc.shift-num = 0
          buf_chk-doc.correct = no
          .
          end.
        end.
      end.
      if (p-wmode = 'ИЗМЕНЕНИЕ':U and index(buf_chk-doc.ps, "shift!") = 0)
      or p-wmode = 'ДОБАВЛЕНИЕ':U
      then do:
        assign
        shift-name_ = (if p-wmode = 'ИЗМЕНЕНИЕ':U
                        then (if p-edit-mode = 'ДОБАВЛЕНИЕ':U
                            then buf_chk-doc.shift-name
                            else buf_chk-doc.src-shift-name)
                        else buf_chk-doc.src-shift-name)
        .
        if v-cas-shft then do:
          if p-get-cash-shift then do:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_get-cash-shift in g#libchkvl
  (input  p-context-bh
  ,buffer buf_shift-cash
  ,input  buf_chk-doc.pay-desk
  ,input  buf_chk-doc.src-shift-date
  ,input  shift-name_
  ,input ?
  ,input buf_chk-doc.chk-date
  ,input buf_chk-doc.chk-time
  ,input 0
    ) no-error .
          end.
        end.
      end.
    end.
  end.
  if (buf_chk-doc.src-d-card <> ? and buf_chk-doc.src-d-card <> "":U)
  or buf_chk-doc.d-card <> "":U
  then do:
    if v-is-petrol-check
    or v-is-inventory
    or v-is-z-rep
    or v-is-shft-open-close
    then do:
      if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                               "!!!Чек &1 - ошибочный. &2 Не может быть указана дисконтная карта в чеке типа &3"                               , buf_chk-doc.doc-code                               , chr(10)                               , entry (lookup (string(buf_chk-doc.chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)                             ) ).
      assign
      for-chk-type = for-chk-type + 'карт-ош':U + chr(44)
      v-view-log = yes
      buf_chk-doc.correct = no
      .
    end.
    else do:
      if buf_chk-doc.src-d-card = "-0":U then do:
        if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                             "!!!Чек &1 - ошибочный. &2 В чеке имеются строки продажи на разные дисконтные карты&2&3"                             , buf_chk-doc.doc-code                             , chr(10)                             ,(if p-wmode = 'ИЗМЕНЕНИЕ':U                               then "Введите ПРАВИЛЬНЫЙ НОМЕР дисконтной карты в поле <ДК В ЧЕКЕ>"                               else chr(10) )) ).
        assign
        for-chk-type = for-chk-type + 'карт-ош':U + chr(44)
        v-view-log = yes
        buf_chk-doc.correct = no
        .
      end.
      else do:
        v-d-card = (if buf_chk-doc.d-card = "":U
                    and buf_chk-doc.src-d-card <> ?
                    and buf_chk-doc.src-d-card <> '':U
                    then buf_chk-doc.src-d-card
                    else buf_chk-doc.d-card).
        v-src-d-card = buf_chk-doc.src-d-card.
        FIND FIRST buf_dis-card NO-LOCK where
                  buf_dis-card.d-card = v-d-card  NO-ERROR.
        if not available buf_dis-card then do:
          if (v-dc-mask or v-card-by-mask) then do:
            _maska:
            for each buf_libchkvl_dis-card-mask no-lock
            by buf_libchkvl_Dis-card-mask.rank:
              assign
              v-found = yes
              v-descr = "":U
              v-short-number = '':U
              v-is-correct = no
              .
              if v-card-by-mask then do:
                assign
                v-short-number = card-by-mask (buf_libchkvl_dis-card-mask.cli-mask, buf_libchkvl_dis-card-mask.cc-run, v-src-d-card)
                no-error
                .
                if error-status:error then do:
                  assign
                  for-chk-type = for-chk-type + 'карт-ош':U + chr(44)
                  v-view-log = yes
                  buf_chk-doc.correct = no
                  .
                  leave _maska.
                end.
                v-d-mask = buf_libchkvl_dis-card-mask.cli-mask.
              end.
              if v-short-number = '':U then do:
                if v-dc-mask then do:
                  assign
                  v-is-correct = check-by-mask (buf_libchkvl_dis-card-mask.mask, v-src-d-card, output v-descr)
                  no-error
                  .
                  if error-status:error then do:
                    assign
                    for-chk-type = for-chk-type + 'карт-ош':U + chr(44)
                    v-view-log = yes
                    buf_chk-doc.correct = no
                    .
                  end.
                  v-d-mask = buf_libchkvl_dis-card-mask.mask.
                end.
              end.
              if v-is-correct or v-short-number <> '':U then do:
                find first buf_dis-card no-lock where
                          buf_dis-card.d-card = (if v-short-number <> '':U then v-short-number else buf_libchkvl_dis-card-mask.mask) no-error .
                if available buf_dis-card
                and buf_dis-card.type = buf_libchkvl_dis-card-mask.type
                and buf_dis-card.emitent-host-code = buf_libchkvl_dis-card-mask.emitent-host-code
                then do:
                  assign
                  buf_chk-doc.src-d-card = (if buf_chk-doc.src-d-card = ? or
                                        buf_chk-doc.src-d-card = '':U
                                        then v-d-card else buf_chk-doc.src-d-card)
                  buf_chk-doc.d-card = buf_dis-card.d-card
                  v-th-mask = yes
                  buf_chk-doc.d-mask = v-d-mask
                  .
                  LEAVE _maska.
                end.
              end.
            end.
            if not available buf_dis-card then do:
              assign
              for-chk-type = for-chk-type + 'карт-ош':U + chr(44)
              v-view-log = yes
              buf_chk-doc.correct = no
              .
                if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute("!!!Чек &1 - ошибочный.&2&3"                                       , buf_chk-doc.doc-code                                       , chr(10)                                       , if not v-found                                          then substitute("Для карты &1 не определено ни одной действующей маски", v-d-card)                                         else substitute("Карта &1 не соответствует ни одной действующей маске", v-d-card)) ).
            end.
          end.
          else do:
            if  v-src-d-card <> v-d-card then do:
              FIND FIRST buf_dis-card NO-LOCK where
                        buf_dis-card.d-card = v-src-d-card  NO-ERROR.
            end.
          end.
        end.
        if avail buf_dis-card
        then find first buf_dis-card-type No-LOCK WHERE
                          buf_dis-card-type.type = buf_dis-card.type
                    AND  buf_dis-card-type.emitent-host-code = buf_dis-card.emitent-host-code
                    AND  buf_dis-card-type.host-code = 0
                    AND  buf_dis-card-type.obj-type = "":U
                    AND  buf_dis-card-type.obj-code = 0 NO-ERROR.
        else release buf_dis-card-type.
        IF NOT avail buf_dis-card
        or NOT avail buf_dis-card-type
        OR (buf_dis-card.emitent-host-code <> v-host-code and buf_dis-card.emitent-host-code <> 0)
        or (lookup(string(v-obj-code), buf_dis-card-type.DCBYSHOP) > 0  and buf_dis-card.issue-code <> v-obj-code)
        then do:
          assign
          for-chk-type = for-chk-type + 'карт-ош':U + chr(44)
          v-view-log = yes
          buf_chk-doc.correct = no
          .
            if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                                   "!!!Чек &1 - ошибочный. &2 Нет сведений о карте клиента &3 или карта выдана другим магазином"                                   , buf_chk-doc.doc-code                                   , chr(10)                                   , buf_chk-doc.src-d-card ) ).
        end.
        if avail buf_dis-card
        and buf_dis-card.emitent-host-code = 0
        and buf_dis-card.credit-card then do:
          assign
          for-chk-type = for-chk-type + 'карт-ош':U + chr(44)
          v-view-log = yes
          buf_chk-doc.correct = no
          .
            if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                                   "!!!Чек &1 - ошибочный. &2 Глобальная карта &3 не может быть кредитной"                                   , buf_chk-doc.doc-code                                   , chr(10)                                   , buf_chk-doc.d-card ) ).
        end.
        if p-wmode <> 'ИЗМЕНЕНИЕ':U then do:
          if avail buf_dis-card
          and buf_dis-card.mask-card = yes
          and not v-th-mask
          AND (buf_dis-card.cli-type <> buf_chk-doc.src-cli-type
              OR
              buf_dis-card.cli-code <> (if buf_chk-doc.src-cli-code > 999999999
                                  then (buf_chk-doc.src-cli-code - 1000000000)
                                  else buf_chk-doc.src-cli-code)) then do:
              if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                                     "!!!Чек &1 - ошибочный. &2 Маска карты &3 соответствует другому клиенту"                                     , buf_chk-doc.doc-code                                     , chr(10)                                     , buf_chk-doc.d-card ) ).
            assign
            for-chk-type = for-chk-type + 'карт-ош':U + chr(44)
            v-view-log = yes
            buf_chk-doc.correct = no
            .
          end.
        END.
      end.
      if avail buf_dis-card
      and buf_dis-card.status_ <> 'тек':U then do:
        IF p-wmode = 'ИЗМЕНЕНИЕ':U then do:
          if buf_dis-card.status_ = 'неисп':U
          or buf_dis-card.status_ = 'смкли':U
          then do:
              if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                                 "!!!Чек &1 - ошибочный.&2Карта &3 имеет статус &4&2" +                                 "&5&2"                                 , buf_chk-doc.doc-code                                 , chr(10)                                 , buf_dis-card.d-card                                 , buf_dis-card.status_                                  , (if buf_dis-card.status_ = 'неисп':U                                   then "карта НЕ МОЖЕТ БЫТЬ ИСПОЛЬЗОВАНА и подлежит ПОЛНОМУ И ОКОНЧАТЕЛЬНОМУ УДАЛЕНИЮ"                                   else "карта будет доступна по окончании процесса смены владельца")                               ) ).
            assign
            for-chk-type = for-chk-type + 'карт-ош':U + chr(44)
            v-view-log = yes
            buf_chk-doc.correct = no
            .
          end.
          else do:
              if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                               "!!!Чек &1 - потенциально ошибочный.&2Карта &3 имеет статус &4 - если карта накопительная,&2" +                               "то при пересчете % скидки или категории клиента МОЖЕТ ВОЗНИКНУТЬ СИТУАЦИЯ когда пересчет&2" +                               "будет осуществляться для ДРУГОЙ карты, перевыпущенной к данной, и имеющей статус &5"                               , buf_chk-doc.doc-code                               , chr(10)                               , buf_dis-card.d-card                               , buf_dis-card.status_                                , 'тек':U                              ) ).
          end.
        end.
        else do:
          assign
          for-chk-type = for-chk-type + 'карт-ош':U + chr(44)
          v-view-log = yes
          buf_chk-doc.correct = no
          .
            if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                                 "!!!Чек &1 - ошибочный. &2 Карта &3 имеет статус &4"                                 , buf_chk-doc.doc-code                                 , chr(10)                                 , buf_dis-card.d-card                                 , buf_dis-card.status_                               ) ).
        end.
      end.
    end.
    if LOOKUP('карт-ош':U, for-chk-type) = 0 then do:
      assign
      buf_chk-doc.d-card = (if buf_chk-doc.d-card = "":u
                        then buf_chk-doc.src-d-card
                        else buf_chk-doc.d-card)
      buf_chk-doc.cli-type = (if avail buf_dis-card
                          then buf_dis-card.cli-type
                          else buf_chk-doc.cli-type)
      buf_chk-doc.cli-code = (if avail buf_dis-card
                          then buf_dis-card.cli-code
                          else buf_chk-doc.cli-code)
      v-card-correct  = yes
      .
    end.
    if ((buf_chk-doc.src-d-card <> "":U
        and buf_chk-doc.src-d-card <> ?
        and buf_chk-doc.src-d-pcnt <> 0.0
        )
        or
        buf_chk-doc.src-d-pcnt <> 0.0 ) AND
        p-sub-d = 0 and not v-is-petrol-check
    then do:
      create buf0_chk-discnt.
      assign
      buf0_chk-discnt.doc-code = buf_chk-doc.doc-code
      buf0_chk-discnt.record-type = 0
      buf0_chk-discnt.discnt-id = (var-discnt-id + 1)
      buf0_chk-discnt.line-num = p-lng-sub-d
      buf0_chk-discnt.time-oper = buf_chk-doc.chk-time
      buf0_chk-discnt.line-type = integer('4':U)
      buf0_chk-discnt.line-sign = yes
      buf0_chk-discnt.pass-discnt = integer('0':U)
      buf0_chk-discnt.value-type = integer('1':U)
      buf0_chk-discnt.discnt-type = (if buf_chk-doc.d-card <> "":U
                                then integer('1':U)
                                else integer('5':U)
                                )
      buf0_chk-discnt.src-d-card = buf_chk-doc.src-d-card
      buf0_chk-discnt.d-card     = if buf0_chk-discnt.d-card = ? or buf0_chk-discnt.d-card = "" then  buf_chk-doc.d-card else buf0_chk-discnt.d-card
      buf0_chk-discnt.discnt-value-pcnt = buf_chk-doc.src-d-pcnt
      buf0_chk-discnt.object-line-num = 0
      buf0_chk-discnt.pay-desk = buf_chk-doc.pay-desk
      buf0_chk-discnt.obj-code = buf_chk-doc.obj-code
      buf0_chk-discnt.obj-type = buf_chk-doc.obj-type
      buf0_chk-discnt.chk-date = buf_chk-doc.chk-date
      buf0_chk-discnt.chk-time = buf_chk-doc.chk-time
      var-discnt-id = var-discnt-id + 1
      var-pcnt-discnt = recid(buf0_chk-discnt)
      .
    end.
  end.
  if v-pos-type <> 'IPC-Servis+':U then do:
    if buf_chk-doc.cashier = 0
    and (buf_chk-doc.chk-type = integer('8':U)
          or
          buf_chk-doc.chk-type = integer('69':U)
          )
    and v-pos-type = 'MAGIA-XML':U then do:
      buf_chk-doc.cashier = v-zero-cashier.
    end.
    assign
    v-cashier-psn-code = gbclcode-is-this-db-role ( input 'C':U, input g#db-num, input buf_chk-doc.cashier, input buf_chk-doc.chk-date)
    .
    if v-cashier-psn-code = 0
    and buf_chk-doc.chk-type <> integer('12':U)
    and buf_chk-doc.chk-type <> integer('13':U)
    and buf_chk-doc.chk-type <> integer('40':U)
    then do:
      assign
      for-chk-type = for-chk-type + 'перс-ош':U + chr(44)
      buf_chk-doc.correct = no
      v-view-log = yes
      .
      if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                               "!!!Чек &1 - ошибочный. &2 Нет сведений о кассире &3"                               , buf_chk-doc.doc-code                               , chr(10)                               , buf_chk-doc.cashier                             ) ).
    end.
    else do:
      assign
      buf_chk-doc.cashier-psn-code = v-cashier-psn-code
      .
    end.
    if buf_chk-doc.sales-man > 0 then do:
      assign
      v-seller-psn-code = gbclcode-is-this-db-role ( input 'S':U
                                                      ,input g#db-num
                                                    , input ( buf_chk-doc.sales-man - (
                                                                                    if v-pos-type = 'MAGIA-XML':U
                                                                                    or v-pos-type = 'MAGIA-XML':U
                                                                                    THEN 10000
                                                                                    ELSE 0)
                                                              )
                                                      , input buf_chk-doc.chk-date
                                                            ) no-error .
      if v-seller-psn-code = 0 then do:
        assign
        for-chk-type = for-chk-type + 'перс-ош':U + chr(44)
        buf_chk-doc.correct = no
        v-view-log = YES
        .
        if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                                 "!!!Чек &1 - ошибочный. &2 Нет сведений о продавце(официанте) &3&2&4"                                 , buf_chk-doc.doc-code                                 , chr(10)                                 , buf_chk-doc.sales-man - (if v-pos-type = 'MAGIA-XML':U                                                       or v-pos-type = 'MAGIA-XML':U                                                       then 10000                                                       else 0)                                 ,(if v-pos-type = 'MAGIA-XML':U or v-pos-type = 'MAGIA-XML':U                                   then substitute('Для кассы типа &1 код продавца (официанта) = [код в IBS TH] + 10000', 'MAGIA-XML':U)                                   else '':u)                               ) ).
      end.
      else do:
        assign
        buf_chk-doc.salesman-psn-code = v-seller-psn-code
        .
      end.
    end.
  end.
  if v-base-code = 0 then do:
    assign
    buf_chk-doc.base-rate = 1.
  end.
  if v-r-b = 'base':U
  and v-base-code <> 0 then do:
    if buf_chk-doc.cash-rate = 0
    or buf_chk-doc.cash-rate = ?
    or buf_chk-doc.cash-rate = 1 then do:
      if available buf_curr-shop then release buf_curr-shop.
      run libchkval_get-curr-shop in this-procedure ( input v-obj-type
                                                     ,input v-obj-code
                                                     ,input v-base-code
                                                     ,input buf_chk-doc.chk-date
                                                     ,input buf_chk-doc.chk-time
                                                     ,buffer buf_curr-shop) no-error.
      if available buf_curr-shop then do:
        assign
        buf_chk-doc.cash-rate = buf_curr-shop.exch-rate
        buf_chk-doc.cash-scale = buf_curr-shop.exch-scale
        buf_chk-doc.base-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
        .
      end.
      else do:
        if NOT NoExchRate then do:
          if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                                   "!!!Чек &1 - ошибочный. &2 Нет магазинного курса базовой валюты для &3&4 на дату &5"                                   , buf_chk-doc.doc-code                                   , chr(10)                                   , buf_chk-doc.obj-type                                   , buf_chk-doc.obj-code                                   , buf_chk-doc.chk-date                                  ) ).
          NoExchRate = TRUE .
        end.
        assign
        for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
        buf_chk-doc.correct = no
        v-view-log = yes
        .
      end.
    end.
  end.
  if v-r-b = 'rubl':U
  and v-base-code <> 0 then do:
    if buf_chk-doc.base-rate = 0
    or buf_chk-doc.base-rate = ?
    or buf_chk-doc.base-rate = 1 then do:
      if available buf_curr-shop then release buf_curr-shop.
      run libchkval_get-curr-shop in this-procedure ( input v-obj-type
                                                     ,input v-obj-code
                                                     ,input v-base-code
                                                     ,input buf_chk-doc.chk-date
                                                     ,input buf_chk-doc.chk-time
                                                     ,buffer buf_curr-shop) no-error.
      if available buf_curr-shop then do:
        assign
        buf_chk-doc.base-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
        .
      end.
      else do:
        if NOT NoExchRate then do:
          if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                                   "!!!Чек &1 - ошибочный. &2 Нет магазинного курса базовой валюты для &3&4 на дату &5"                                   , buf_chk-doc.doc-code                                   , chr(10)                                   , buf_chk-doc.obj-type                                   , buf_chk-doc.obj-code                                    , buf_chk-doc.chk-date                                  ) ).
          NoExchRate = TRUE .
        end.
        assign
        for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
        buf_chk-doc.correct = no
        v-view-log = yes
        .
      end.
    end.
  end.
  buf_chk-doc.doc-qnty = 0.
  for each buf_chk-gds where
            buf_chk-gds.doc-code = buf_chk-doc.doc-code
  BY buf_chk-gds.LINE-NUM
            :
    assign
    accum-count = accum-count + 1
    buf_chk-gds.is-error = ?
    buf_chk-gds.d-card   = ( if buf_chk-doc.src-d-card = buf_chk-gds.src-d-card
                          and v-card-correct
                          then buf_chk-doc.d-card
                          else buf_chk-gds.d-card)
    buf_chk-gds.cli-type = ( if buf_chk-doc.src-cli-type = buf_chk-gds.src-cli-type
                          and v-card-correct
                          then buf_chk-doc.cli-type
                          else buf_chk-gds.cli-type)
    buf_chk-gds.cli-code = ( if buf_chk-doc.src-cli-code = buf_chk-gds.src-cli-code
                          and v-card-correct
                          then buf_chk-doc.cli-code
                          else buf_chk-gds.cli-code)
    .
    if buf_chk-gds.sales-man = 0
    or buf_chk-gds.sales-man = ? then do:
      assign
      buf_chk-gds.sales-man = buf_chk-doc.sales-man
      buf_chk-gds.salesman-psn-code = buf_chk-doc.salesman-psn-code
      .
    end.
    else do:
      v-seller-psn-code = 0.
      assign
      v-seller-psn-code = gbclcode-is-this-db-role (  input 'S':U
                                                      ,input g#db-num
                                                      ,input ( buf_chk-gds.sales-man - (
                                                                if v-pos-type = 'MAGIA-XML':U
                                                                or v-pos-type = 'MAGIA-XML':U
                                                                THEN 10000
                                                                ELSE 0))
                                                      ,input buf_chk-doc.chk-date
                                                                ) no-error .
      if v-seller-psn-code = 0 then do:
        assign
        for-chk-type = for-chk-type + 'перс-ош':U + chr(44)
        buf_chk-doc.correct = no
        v-view-log = YES
        .
        if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                                 "!!!Чек &1 - ошибочный. &2 Нет сведений о продавце(официанте) &3&2Строка &4&2&5"                                 , buf_chk-doc.doc-code                                 , chr(10)                                 , buf_chk-gds.sales-man                                 , buf_chk-gds.line-num                                  ,(if v-pos-type = 'MAGIA-XML':U or v-pos-type = 'MAGIA-XML':U                                   then substitute('Для кассы типа &1 код продавца (официанта) = [код в IBS TH] + 10000', 'MAGIA-XML':U)                                   else '':u)                               ) ).
      end.
      else do:
        assign
        buf_chk-doc.salesman-psn-code = (IF buf_chk-doc.SALESMAN-PSN-CODE = 0
                                      OR buf_chk-doc.SALESMAN-PSN-CODE = ?
                                      THEN v-seller-psn-code
                                      ELSE (if buf_chk-doc.salesman-psn-code <> v-seller-psn-code
                                            then 0
                                            else buf_chk-doc.SALESMAN-PSN-CODE)
                                    )
        .
      end.
    end.
    CASE buf_chk-gds.grp-code:
      when 0 then do:
        assign
        v-units-rate = 1
        v-units-dpcnt = 0
        v-bc-buf = entry(1, buf_chk-gds.src-code, chr(4))
        v-price-from-check = buf_chk-gds.src-price
        v-bc-buf     = (if buf_chk-gds.b-code <> 0
                        and (v-pos-type = 'IBM-XML':U
                            or
                            v-pos-type = 'IBS-TH':U
                            or
                            v-pos-type = 'IBS-TH-MOB':U
                            or
                            v-pos-type = 'Autotank':U
                            )
                        then string(buf_chk-gds.b-code)
                        else v-bc-buf)
        .
if p-wmode = 'ИЗМЕНЕНИЕ':U then do:
if p-edit-mode = 'ДОБАВЛЕНИЕ':U then do:
          assign
          v-bc-buf = string(entry(1, buf_chk-gds.src-code, chr(4)))
          v-bc-rcnz-only-bc = (string(buf_chk-gds.b-code) = entry(1, buf_chk-gds.src-code, chr(4)))
          .
end.
if p-edit-mode = 'ИЗМЕНЕНИЕ':U then do:
          assign
          v-bc-buf = string(buf_chk-gds.b-code)
          v-bc-rcnz-only-bc = yes
          .
end.
end.
if p-wmode = 'ИЗМЕНЕНИЕ':U then do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  v-parparentproc
,input  v-bc-buf
,input  v-price-from-check
,input  v-obj-type
,input  v-obj-code
,input  yes
,input  v-bc-rcnz-only-bc
,input  v-sclspref
,input  v-scpgpref
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
end.
else do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  v-parparentproc
,input  v-bc-buf
,input  v-price-from-check
,input  v-obj-type
,input  v-obj-code
,input   ( if g#auto then no else yes )
,input  no
,input  v-sclspref
,input  v-scpgpref
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
end.
if avail buf_bar-code then do:
  if buf_bar-code.stts_ <> integer('99':U) then do:
    if p-wmode = 'ИЗМЕНЕНИЕ':U then do:
      assign
      v-units-rate = (if buf_chk-gds.src-qnty = 0
                      then  buf_bar-code.cli-base-rate
                      else buf_chk-gds.doc-qnty / buf_chk-gds.src-qnty)
      iserr = no
      .
    end.
    else do:
      assign
      v-units-rate = buf_bar-code.cli-base-rate
      iserr = no
      .
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_bar-code.gds-code
  ,input  buf_bar-code.node-code
  ,output r-bar-code
  ) no-error .
          if error-status:error then v-b-c = ?.
          else do:
            if buf_bar-code.in-code = "":U and buf_bar-code.part-code = "":U then do:
                assign
                v-b-c = r-bar-code
                .
            end.
            else do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspcode in g#library
  (input  buf_bar-code.gds-code
  ,input  buf_bar-code.node-code
  ,input  buf_bar-code.in-code
  ,input  buf_bar-code.part-code
  ,output r-bar-code
  )  .
                assign
                v-b-c = (if error-status:error
                      then ?
                      else r-bar-code)
                .
            end.
            end.
          end.
          else do:
            assign
            v-b-c = ?
            iserr = yes
            .
            if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                                 "!!!Чек &1 - ошибочный. &2 В чеке имеется бар-код &3 помеченный для удаления:&4&5"                                 , buf_chk-doc.doc-code                                 , chr(10)                                 , v-bc-buf                                      , chr(10)                                 , string(varresult, "X(80)")                               ) ).
          end.
        end.
        else do:
          if mask_s-c <> "" then do :
              iii_ :
              do iii = 1 to num-entries(mask_s-c) :
                if length(v-bc-buf) = (num-entries(entry(iii, mask_s-c), '*') - 1) then do :
                  v-bc-buf2 = entry(1, entry(iii, mask_s-c), '*') + v-bc-buf.
                  if p-wmode = 'ИЗМЕНЕНИЕ':U then do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  v-parparentproc
,input  v-bc-buf2
,input  v-price-from-check
,input  v-obj-type
,input  v-obj-code
,input  yes
,input  v-bc-rcnz-only-bc
,input  v-sclspref
,input  v-scpgpref
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
                  end.
                  else do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  v-parparentproc
,input  v-bc-buf2
,input  v-price-from-check
,input  v-obj-type
,input  v-obj-code
,input   ( if g#auto then no else yes )
,input  no
,input  v-sclspref
,input  v-scpgpref
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
                  end.
                  if avail buf_bar-code then do:
                    v-bc-buf = v-bc-buf2.
                    if buf_bar-code.stts_ <> integer('99':U) then do:
                      if p-wmode = 'ИЗМЕНЕНИЕ':U then do:
                        assign
                        v-units-rate = (if buf_chk-gds.src-qnty = 0
                                        then  buf_bar-code.cli-base-rate
                                        else buf_chk-gds.doc-qnty / buf_chk-gds.src-qnty)
                        iserr = no
                        .
                    end.
                    else do :
                      assign
                      v-units-rate = buf_bar-code.cli-base-rate
                      iserr = no
                      .
                    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_bar-code.gds-code
  ,input  buf_bar-code.node-code
  ,output r-bar-code
  ) no-error .
                    if error-status:error then v-b-c = ?.
                    else do:
                      if buf_bar-code.in-code = "":U and buf_bar-code.part-code = "":U then do:
                          assign
                          v-b-c = r-bar-code
                          .
                      end.
                      else do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspcode in g#library
  (input  buf_bar-code.gds-code
  ,input  buf_bar-code.node-code
  ,input  buf_bar-code.in-code
  ,input  buf_bar-code.part-code
  ,output r-bar-code
  )  .
                        assign
                          v-b-c = (if error-status:error
                                then ?
                                else r-bar-code)
                          .
                      end.
                      end.
                    end.
                    else do:
                      assign
                      v-b-c = ?
                      iserr = yes
                      .
          if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                               "!!!Чек &1 - ошибочный. &2 В чеке имеется нераспознанный бар-код &3:&4&5"                               , buf_chk-doc.doc-code                               , chr(10)                               , v-bc-buf                               , chr(10)                               , string(varresult, "X(80)")                             ) ).
                    end.
                    leave iii_ .
                  end.
                  else next iii_ .
                end.
              end.
            end.
        if not available buf_bar-code
        and buf_chk-doc.chk-type <> integer('43':U)
        and buf_chk-doc.chk-type <> integer('44':U)
        then do :
          assign
          v-b-c = ?
          iserr = yes
          .
          if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                               "!!!Чек &1 - ошибочный. &2 В чеке имеется нераспознанный бар-код &3:&4&5"                               , buf_chk-doc.doc-code                               , chr(10)                               , v-bc-buf                               , chr(10)                               , string(varresult, "X(80)")                             ) ).
        end.
      end.
        if buf_chk-doc.chk-type <> integer('43':U)
        and buf_chk-doc.chk-type <> integer('44':U)
        then do :
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-valid28 as logical no-undo .
define variable v-mess28 as character no-undo .
define variable v-chr-err28 as character no-undo .
if v-b-c <> ? then do:
  iserr = no.
  if buf_chk-gds.src-qnty = 0
  and not(lookup(string(buf_chk-doc.chk-type), '6,96':U) > 0
         and buf_chk-gds.write-off-code > 0)
  and not (lookup(string(buf_chk-doc.chk-type), '14,15,16,17,36':U) > 0
           and (
                (buf_chk-gds.src-price <> 0
                and
                buf_chk-gds.src-sum / buf_chk-gds.src-price <> 0)
                or buf_chk-doc.chk-type = integer('14':U)
               )
           )
  and not v-pos-type = 'Autotank':U and not v-pos-type = 'IBM-XML':U and not v-pos-type = 'IBM':U
  then do:
    assign
    iserr = yes
    for-chk-type = for-chk-type + 'кол-ош':U + chr(44)
    buf_chk-doc.correct = no
    v-view-log = yes
    .
    if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                             "!!!Чек &1 - ошибочный. &2 Товар с кодом &3: количество = 0"                             , buf_chk-doc.doc-code                             , chr(10)                             , buf_chk-gds.src-code                           ) ).
  end.
    FIND FIRST buf_goods WHERE
             buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK.
  FIND FIRST ub.gds-obj No-LOCK WHERE
             ub.gds-obj.gds-code = buf_bar-code.gds-code AND
             ub.gds-obj.obj-type =  buf_chk-doc.obj-type AND
             ub.gds-obj.obj-code =   buf_chk-doc.obj-code NO-ERROR.
  cashparts = IF AVAIL ub.gds-obj then ub.gds-obj.cash-parts else no.
  FIND FIRST buf_units WHERE buf_units.unit-name = buf_goods.unit-base NO-LOCK .
  if LOOKUP(buf_goods.gds-type, for-chk-type) = 0 then
  do:
    assign
    for-chk-type = for-chk-type + buf_goods.gds-type + chr(44)
    main-gds-type = buf_goods.gds-type
    .
  end.
  if (LOOKUP('т':U, for-chk-type) > 0
      OR
      LOOKUP('у':U, for-chk-type) > 0
      )
  and LOOKUP('сумма':U, for-chk-type) > 0 then do:
    .
    assign
    for-chk-type = for-chk-type + buf_goods.gds-type + chr(44)
    buf_chk-doc.correct = no
    buf_chk-gds.is-err = yes
    v-view-log = yes
    .
  end.
  find first ub.goods-attr where ub.goods-attr.gds-code = buf_goods.gds-code and ub.goods-attr.attr-code = 'ptrl-as-good':U no-error.
  if LOOKUP('топ':U, buf_units.type) = 0 and (available (ub.goods-attr) and ub.goods-attr.attr-value= 'yes') then do:
    buf_chk-gds.nozzle-code = 0.
    buf_chk-gds.pump = 0.
  end.
  IF buf_chk-gds.pump > 0 and LOOKUP('топ':U, buf_units.type) = 0 and buf_goods.gds-type = 'у':U then do:
    buf_chk-gds.pump = 0.
  end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_petrol-valid in g#libchkvl
  (input  buf_chk-doc.chk-type
  ,input  buf_chk-gds.line-num
  ,input  buf_chk-doc.obj-type
  ,input  buf_chk-doc.obj-code
  ,input  v-pos-type
  ,input  buf_chk-gds.src-code
  ,input  buf_goods.gds-code
  ,input  buf_units.type
  ,input  buf_chk-gds.pump
  ,input  buf_chk-gds.nozzle-code
  ,output v-valid28
  ,output v-mess28
  ,output v-chr-err28
  ) no-error .
  if error-status:error
  or not v-valid28 then do:
    assign
    for-chk-type = for-chk-type + v-chr-err28 + chr(44)
    buf_chk-gds.is-err = yes
    iserr = yes
    v-view-log = yes
    .
  end.
  if LOOKUP( 'сер':U, buf_units.type ) > 0 OR
     lookup('2ед':U, buf_units.type) > 0 OR
     lookup('доп':U, buf_units.type) > 0 then do:
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_unit-type-qnty in g#libchkvl
  (input  buf_chk-doc.chk-type
  ,input  buf_chk-gds.line-num
  ,input  buf_units.type
  ,input  ''
  ,input  buf_chk-gds.src-code
  ,input  buf_bar-code.in-code
  ,input  buf_chk-gds.src-qnty
  ,input  buf_goods.min-rate
  ,input  buf_goods.max-rate
  ,output v-valid28
  ,output v-mess28
  ,output v-chr-err28
  ) no-error .
    if error-status:error
    or not v-valid28 then do:
      if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute("!!!Чек &1 - ошибочный.&2"                             , buf_chk-doc.doc-code                              ,v-mess28) ).
      assign
      for-chk-type = for-chk-type + v-chr-err28 + chr(44)
      buf_chk-gds.is-err = yes
      iserr = yes
      v-view-log = yes
      .
    end.
  end.
  if LOOKUP('сер':U, buf_units.type) = 0 then do:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_part-valid in g#libchkvl
  (input  buf_chk-doc.chk-type
  ,input  buf_chk-gds.line-num
  ,input  buf_units.type
  ,input  ''
  ,input  buf_chk-gds.src-code
  ,input  buf_bar-code.in-code
  ,input  buf_bar-code.part-code
  ,input  cashparts
  ,input  buf_chk-gds.src-qnty
  ,output v-valid28
  ,output v-mess28
  ,output v-chr-err28
  ) no-error .
    if error-status:error
    or not v-valid28 then do:
      if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute("!!!Чек &1 - ошибочный.&2"                             , buf_chk-doc.doc-code                             ,v-mess28) ).
      assign
      for-chk-type = for-chk-type + v-chr-err28 + chr(44)
      buf_chk-gds.is-err = yes
      iserr = yes
      v-view-log = yes
      .
    end.
  end.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_place-valid in g#libchkvl
  (input  buf_chk-doc.chk-type
  ,input  buf_chk-gds.line-num
  ,input  buf_chk-doc.obj-type
  ,input  buf_chk-doc.obj-code
  ,input  buf_chk-gds.src-code
  ,input  buf_goods.gds-code
  ,input  buf_chk-gds.loc1
  ,input  buf_chk-gds.src-pl-code
  ,output buf_chk-gds.pl-code
  ,output v-valid28
  ,output v-mess28
  ,output v-chr-err28
  ) no-error .
  if error-status:error
  or not v-valid28 then do:
    .
    assign
    for-chk-type = for-chk-type + v-chr-err28 + chr(44)
    buf_chk-gds.is-err = yes
    iserr = yes
    v-view-log = yes
    .
  end.
  FIND buf_gds-prt WHERE buf_gds-prt.upper-code = buf_goods.prt-root NO-LOCK .
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_prt-valid in g#libchkvl
  (input  buf_chk-doc.chk-type
  ,input  buf_chk-gds.line-num
  ,input  v-doc-prt
  ,input  buf_chk-gds.src-code
  ,input  (buf_gds-prt.node-name <> '_Пустая шкала':U)
  ,input  buf_gds-prt.node-code
  ,input  buf_bar-code.node-code
  ,output v-valid28
  ,output v-mess28
  ,output v-chr-err28
  ) no-error .
  if error-status:error
  or not v-valid28 then do:
    if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute("!!!Чек &1 - ошибочный.&2"                           , buf_chk-doc.doc-code                           ,v-mess28) ).
    assign
    for-chk-type = for-chk-type + v-chr-err28 + chr(44)
    buf_chk-gds.is-err = yes
    iserr = yes
    v-view-log = yes
    .
  end.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_fbr-valid in g#libchkvl
  (input  buf_chk-doc.chk-type
  ,input  buf_chk-gds.line-num
  ,input  buf_chk-doc.obj-type
  ,input  buf_chk-doc.obj-code
  ,input  v-is-catering
  ,input  v-pos-type
  ,input  buf_chk-gds.src-code
  ,input  buf_goods.gds-code
  ,input  buf_chk-gds.src-price
  ,input  buf_chk-gds.src-discnt
  ,input  buf_chk-gds.write-off-code
  ,input-output  buf_chk-gds.depart-type
  ,input-output  buf_chk-gds.depart-code
  ,output v-is-null-price
  ,output v-valid28
  ,output v-mess28
  ,output v-chr-err28
  ) no-error .
  if error-status:error
  or not v-valid28 then do:
    if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute("!!!Чек &1 - ошибочный.&2"                           , buf_chk-doc.doc-code                           ,v-mess28) ).
    assign
    for-chk-type = for-chk-type + v-chr-err28 + chr(44)
    buf_chk-gds.is-err = yes
    iserr = yes
    v-view-log = yes
    .
  end.
end.
else do:
  if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                             "!!!Чек &1 - ошибочный. &2Товар с кодом &3 отсутствует в БД"                             , buf_chk-doc.doc-code                             , chr(10)                             , buf_chk-gds.src-code                           ) ).
  assign
  for-chk-type = for-chk-type + "0" + chr(44)
  buf_chk-gds.is-err = yes
  iserr = yes
  v-view-log = yes
  .
end.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_chk-gds-wro in g#libchkvl
  (input  buf_chk-doc.chk-type
  ,input  buf_chk-gds.line-num
  ,input  buf_chk-gds.src-qnty
  ,input  buf_chk-gds.write-off-code
  ,output v-valid28
  ,output v-mess28
  ) no-error .
if error-status:error
or not v-valid28 then do:
  if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute("!!!Чек &1 - ошибочный.&2"                          ,buf_chk-doc.doc-code                          ,v-mess28) ).
  assign
  for-chk-type = for-chk-type + "0" + chr(44)
  buf_chk-gds.is-err = yes
  iserr = yes
  v-view-log = yes
  .
end.
        end.
        IF v-b-c = ?
        and buf_chk-doc.chk-type <> integer('43':U)
        and buf_chk-doc.chk-type <> integer('44':U)
        then
        buf_chk-doc.PS = buf_chk-doc.PS + "@":U +
                    "строка" + chr(32) + string(buf_chk-gds.LINE-NUM) + chr(32) +
                    "код = ?" + "@":u
        .
        v-price-from-check = buf_chk-gds.SRC-PRICE * abs( buf_chk-gds.src-qnty ) .
        assign
        buf_chk-gds.b-code = ( if v-b-c <> ? then v-b-c else 0)
        buf_chk-gds.is-error = (if buf_chk-gds.is-error = ? then no else buf_chk-gds.is-error) or iserr
        v-kriv-z-qnty =   (if buf_chk-gds.src-qnty = 0
                            and  lookup(string(buf_chk-doc.chk-type), '14,15,16,17,36':U) > 0
                            and buf_chk-gds.src-price <> 0
                            then  yes
                            else v-kriv-z-qnty)
        buf_chk-gds.doc-qnty = (if buf_chk-gds.src-qnty = 0
                              and  lookup(string(buf_chk-doc.chk-type), '14,15,16,17,36':U) > 0
                              and buf_chk-gds.src-price <> 0
                              then  buf_chk-gds.src-sum / buf_chk-gds.src-price
                              else round(buf_chk-gds.src-qnty *  v-units-rate, 3)
                              )
        buf_chk-gds.price-base = (if buf_chk-gds.src-qnty = 0
                              then buf_chk-gds.src-price / v-units-rate
                              else (if round(buf_chk-gds.src-price, 2) <> buf_chk-gds.src-price
                                    and v-units-rate = 1
                                    then buf_chk-gds.src-price
                                    else  round( v-price-from-check / abs( buf_chk-gds.doc-qnty ), 2 )
                                    )
                              )
        buf_chk-gds.line-type = (if avail buf_goods
                            then buf_goods.gds-type
                            else "":U)
        .
        if buf_chk-doc.chk-type <> integer('43':U)
        and buf_chk-doc.chk-type <> integer('44':U)
        then do :
          buf_chk-gds.depart-type = (if buf_chk-gds.depart-code > 0 then 'маг':U else "":U) .
        end .
        if buf_chk-doc.chk-type = integer('43':U)
        or buf_chk-doc.chk-type = integer('44':U)
        then do :
          buf_chk-gds.b-code = integer(v-bc-buf) .
        end .
        if buf_chk-gds.src-qnty <> 0
        or (buf_chk-gds.doc-qnty <> 0 and v-is-petrol-check)
        then do:
          assign
          buf_chk-gds.discnt =  if buf_chk-gds.src-discnt = buf_chk-gds.src-price
                            then buf_chk-gds.price-base
                            else ( if v-is-petrol-check
                                  then  buf_chk-gds.discnt
                                  else (
                                        if buf_chk-gds.write-off-code <> ?
                                        and buf_chk-gds.write-off-code > 0
                                        then 0
                                        else (
                                              if v-units-rate = 1
                                              then (if (buf_chk-gds.pump > 0)
                                                    then
                                                    (buf_chk-gds.src-discnt  +
                                                      (abs(buf_chk-gds.src-qnty * buf_chk-gds.src-price) - abs(buf_chk-gds.src-sum) )
                                                      / abs(buf_chk-gds.src-qnty)
                                                    )
                                                    else buf_chk-gds.src-discnt
                                                    )
                                              else
                                                  ( ( buf_chk-gds.src-discnt / abs( v-units-rate) +
                                                    ( v-price-from-check / abs( buf_chk-gds.doc-qnty )  - buf_chk-gds.src-price / abs( v-units-rate ) ) +
                                                    ( v-price-from-check / abs( buf_chk-gds.doc-qnty ) - buf_chk-gds.price-base ) )
                                                  )
                                            ))
                                    )
          .
          if ChkPromoPrice(buf_chk-gds.doc-code, buf_chk-gds.line-num )
          then assign
                 vSumRound = RoundUp(buf_chk-gds.doc-qnty, buf_chk-gds.price-base)
                 buf_chk-gds.discnt = 0
                 .
          else vSumRound = buf_chk-gds.doc-qnty * buf_chk-gds.price-base.
          assign
          buf_chk-gds.sum-base = vSumRound
          buf_chk-doc.tot-doc = buf_chk-doc.tot-doc + (if v-is-petrol-check
                                                or v-is-inventory
                                                then 0 else  buf_chk-gds.sum-base)
          buf_chk-doc.discnt = buf_chk-doc.discnt + (if buf_chk-gds.write-off-code <> ?
                                              and buf_chk-gds.write-off-code > 0
                                              then 0
                                              else buf_chk-gds.discnt * buf_chk-gds.doc-qnty)
          buf_chk-doc.netto = buf_chk-doc.tot-doc - buf_chk-doc.discnt
          buf_chk-doc.doc-qnty = buf_chk-doc.doc-qnty + buf_chk-gds.doc-qnty
          buf_chk-doc.src-tot-doc = (if buf_chk-doc.tot-doc <> 0
                                then (buf_chk-doc.src-tot-doc + buf_chk-gds.src-sum)
                                else buf_chk-doc.src-tot-doc)
          no-error
          .
          if buf_chk-gds.discnt > buf_chk-gds.price-base then do:
                        if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                                         "!!!Чек &1 - ошибочный. &2В строке &3 скидка превысила цену!"                                         , buf_chk-doc.doc-code                                         , chr(10)                                         , buf_chk-gds.line-num                                       ) ).
            assign
            for-chk-type = for-chk-type + 'скидка-ош':U + chr(44)
            buf_chk-doc.correct = no
            v-view-log = yes
            .
          end.
          if buf_chk-doc.chk-type = integer('6':U) then
             SetPromoDisc(buf_chk-gds.doc-code, buf_chk-gds.line-num  ).
          if buf_chk-gds.discnt <> 0 or ChkPromoLine(buf_chk-gds.doc-code, buf_chk-gds.line-num )
          then do:
            _chk-discnt-gds:
            for each buf0_chk-discnt where
                      buf0_chk-discnt.doc-code = buf_chk-doc.doc-code and
                      buf0_chk-discnt.line-num = buf_chk-gds.line-num and
                      buf0_chk-discnt.record-type = 0 and
                      buf0_chk-discnt.object-line-num = buf_chk-gds.line-num:
              if not buf0_chk-discnt.line-type = integer('1':U) then next _chk-discnt-gds.
              create buf_chk-discnt.
              buffer-copy buf0_chk-discnt to buf_chk-discnt
              assign
              buf_chk-discnt.record-type = 1
              buf_chk-discnt.object-qnty = buf_chk-gds.doc-qnty
              buf_chk-discnt.discnt-value-pcnt = if buf0_chk-discnt.object-sum <> 0
                                                then buf0_chk-discnt.discnt-value-abs / buf0_chk-discnt.object-sum * 100
                                                else 0
              buf0_chk-discnt.d-card       = if buf0_chk-discnt.d-card = ? or buf0_chk-discnt.d-card = "" then buf_chk-gds.d-card else buf0_chk-discnt.d-card
              buf_chk-discnt.d-card       = if buf_chk-discnt.d-card = ? or buf_chk-discnt.d-card = "" then buf_chk-gds.d-card else buf_chk-discnt.d-card
              .
            end.
          end.
        end.
        if buf_chk-gds.src-qnty <> 0
        or (buf_chk-gds.src-qnty = 0
            and
            buf_chk-gds.doc-qnty <> 0) then do:
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if buf_chk-gds.grp-code = 0 then   do:
  if cr > 0 then
  find first t-gds WHERE
              t-gds.b-code = buf_chk-gds.b-code and
              t-gds.drc = recid(buf_chk-doc)
              NO-ERROR.
  if not avail t-gds or cr = 0 OR (t-gds.grc <> ? AND t-gds.grc <> recid(buf_chk-gds)) then  do:
    FIND FIRST t-gds where t-gds.crf = cr + 1 use-index crfi No-ERROR.
    if not avail t-gds then
    create t-gds.
    assign
    t-gds.crf = cr + 1
    cr = cr + 1
    t-gds.b-code = buf_chk-gds.b-code
    t-gds.unit-base = if v-b-c <> ? then buf_goods.unit-base else ""
    t-gds.doc-qnty = 0
    t-gds.drc = recid(buf_chk-doc)
    t-gds.price-sum = 0
    t-gds.discnt-sum = 0
    t-gds.grc = if v-b-c <> ?
                then (if LOOKUP('2ед':U, buf_units.type) > 0 then recid(t-gds) else ?)
                else ?
    t-gds.type = if v-b-c <> ? then buf_units.type else ""
    t-gds.num-lines = 0
    t-gds.was-return = no
    t-gds.was-write-off = no
    t-gds.is-modificATOR = no
    t-gds.is-null-price = no
    t-gds.first-line-num = 0
    t-gds.corr-discnt-rank = 0
    .
  end.
  ELSE DO:
    ASSIGN
    t-gds.is-modificATOR = no
    t-gds.is-null-price = no
    .
  END.
  assign
  t-gds.doc-qnty = t-gds.doc-qnty + buf_chk-gds.doc-qnty
  t-gds.num-lines = t-gds.num-lines + 1
  t-gds.price-sum = t-gds.price-sum +
                    (buf_chk-gds.price-base + buf_chk-gds.price-service ) * buf_chk-gds.doc-qnty
  t-gds.discnt-sum  = t-gds.discnt-sum +
                      buf_chk-gds.discnt * buf_chk-gds.doc-qnty
  t-gds.was-return = if t-gds.was-return
                      then t-gds.was-return
                      else (buf_chk-gds.line-sign = no)
  t-gds.was-write-off = if t-gds.was-write-off
                      then t-gds.was-write-off
                      else (buf_chk-gds.write-off-code <> ? and buf_chk-gds.write-off-code <> 0)
  t-gds.is-modificator =  if (t-gds.was-write-off
                          and (lookup (STRING(if buf_chk-gds.write-off-code <> ? then buf_chk-gds.write-off-code else 0),  '2,-2,3,-3,-4':U) > 0)
                          )
                          or t-gds.is-modificator
                          then yes
                          else t-gds.is-modificator
  t-gds.is-null-price =  no
t-gds.last-included-in-sale = (if (t-gds.price-sum - t-gds.discnt-sum) = 0
                                then 0
                                else (if buf_chk-gds.line-sign
                                      then buf_chk-gds.line-num
                                      else t-gds.last-included-in-sale)
                                )
  .
end.
        end.
        for each buf_marking-chk exclusive-lock where buf_marking-chk.doc-code = chk-gds.doc-code
                                                  and buf_marking-chk.line-num = chk-gds.line-num
                                                  :
          if v-units-rate = 10
          then do :
            assign buf_marking-chk.unit = "LEVEL1" .
          end .
          else do :
            assign buf_marking-chk.unit = "UNIT" .
          end .
        end.
      end.
      otherwise do:
        assign
        for-chk-type = for-chk-type + 'сумма':U + chr(44)
        buf_chk-doc.tot-doc = buf_chk-doc.tot-doc + buf_chk-gds.price-base * buf_chk-gds.doc-qnty
        buf_chk-doc.discnt = buf_chk-doc.discnt + buf_chk-gds.discnt * buf_chk-gds.doc-qnty
        buf_chk-doc.netto = buf_chk-doc.netto + ( buf_chk-gds.price-base * buf_chk-gds.doc-qnty ) - buf_chk-gds.src-discnt
        buf_chk-doc.doc-qnty = buf_chk-doc.doc-qnty + buf_chk-gds.doc-qnty
        .
        if buf_chk-gds.src-discnt <> 0 then do:
          create buf0_chk-discnt.
          assign
          buf0_chk-discnt.doc-code = buf_chk-doc.doc-code
          buf0_chk-discnt.record-type = 0
          buf0_chk-discnt.discnt-id = (var-discnt-id + 1)
          buf0_chk-discnt.line-num = buf_chk-gds.line-num
          buf0_chk-discnt.time-oper = buf_chk-doc.chk-time
          buf0_chk-discnt.line-type = integer('1':U)
          buf0_chk-discnt.line-sign =  (buf_chk-gds.src-qnty >= 0 ) Eq (buf_chk-gds.src-discnt > 0 )
          buf0_chk-discnt.pass-discnt = integer('0':U)
          buf0_chk-discnt.value-type = integer('0':U)
          buf0_chk-discnt.discnt-type = integer('0':U)
          buf0_chk-discnt.d-card = buf_chk-doc.d-card
          buf0_chk-discnt.d-card = if buf0_chk-discnt.d-card = ? or buf0_chk-discnt.d-card = "" then buf_chk-doc.d-card else buf0_chk-discnt.d-card
          buf0_chk-discnt.src-d-card = buf_chk-doc.src-d-card
          buf0_chk-discnt.discnt-value-abs = buf_chk-gds.src-discnt
          buf0_chk-discnt.object-qnty = buf_chk-gds.src-qnty
          buf0_chk-discnt.object-sum = buf_chk-gds.src-sum
          buf0_chk-discnt.discnt-value-pcnt = if buf_chk-gds.src-sum <> 0
                                          then (buf_chk-gds.src-discnt / buf_chk-gds.src-sum) * 100
                                          else 0
          buf0_chk-discnt.object-line-num = buf_chk-gds.line-num
          buf0_chk-discnt.pay-desk = buf_chk-doc.pay-desk
          buf0_chk-discnt.obj-code = buf_chk-doc.obj-code
          buf0_chk-discnt.obj-type = buf_chk-doc.obj-type
          buf0_chk-discnt.chk-date = buf_chk-doc.chk-date
          buf0_chk-discnt.chk-time = buf_chk-doc.chk-time
          buf_chk-gds.discnt = buf_chk-gds.src-discnt / abs( buf_chk-gds.doc-qnty )
          buf_chk-gds.src-discnt = buf_chk-gds.src-discnt / buf_chk-gds.src-qnty
          var-discnt-id = var-discnt-id + 1
          .
        end.
      end.
    end CASE.
    if buf_chk-gds.is-error = ? then
    buf_chk-gds.is-error = no.
    if buf_chk-gds.write-off-code <> 0
    and buf_chk-gds.write-off-code <> ?
    and not v-is-petrol-check
    then do:
      assign
      v-write-off-sum = v-write-off-sum + (if buf_chk-gds.write-off-code > 0 then 1 else - 1) *
                        buf_chk-gds.doc-qnty * buf_chk-gds.price-base
      .
    end.
  end.
  if ((buf_chk-doc.chk-type = integer('16':U)
  and accum-count <> 2)
  or ((buf_chk-doc.chk-type = integer('14':U)
        or
        buf_chk-doc.chk-type = integer('15':U)
        or
        buf_chk-doc.chk-type = integer('17':U)
        or
        buf_chk-doc.chk-type = integer('36':U)
      )
      and
      accum-count <> 1) )
  or (v-is-z-rep and accum-count <> 0)
  or (v-is-shft-open-close and accum-count <> 0)
  then do:
    if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                             "!!!Чек &1 - ошибочный. &2Товарных строк - &3&2В чеке типа &4 кол-во товарных строк может быть только  - &5"                             , buf_chk-doc.doc-code                             , chr(10)                             , accum-count                                , entry (lookup (string(buf_chk-doc.chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)                             , (if buf_chk-doc.chk-type = integer('16':U)                                 then 2                                 else (if v-is-z-rep or v-is-shft-open-close then 0 else 1))                           ) ).
    assign
    for-chk-type = for-chk-type + 'сум-ош':U + chr(44)
    buf_chk-doc.correct = no
    v-view-log = yes
    .
  end.
  assign
  v-rb = ?
  accum-pay-count = 0
  .
  for each buf_chk-pay where
            buf_chk-pay.doc-code = buf_chk-doc.doc-code:
    run libchkvl_process-chk-pay in this-procedure (
                                           input p-context-bh
                                          ,buffer buf_chk-doc
                                          ,buffer buf_chk-pay
                                          ,input-output noexchrate
                                          ,input-output for-chk-type
                                          ) no-error .
    assign
    accum-pay = accum-pay + (if v-r-b = 'base':U
                              then buf_chk-pay.tot-base
                              else buf_chk-pay.tot-rubl)
    accum-pay-count = accum-pay-count + 1
    v-rb = ((if v-r-b = 'base':U
            then buf_chk-pay.tot-base
            else buf_chk-pay.tot-rubl) = buf_chk-pay.tot-sum)
    .
  END.
  if p-netto  <> ? then do:
    if ABS(ABS(p-netto - ACCUM-pay)/ p-netto) > 0.01
    AND accum-pay-count = 1
    AND buf_chk-doc.chk-type = integer('6':U)
    AND v-rb
    then do:
      find first buf_chk-pay where
                buf_chk-pay.doc-code = buf_chk-doc.doc-code.
      assign
      accum-pay = accum-pay - buf_chk-pay.tot-sum
      buf_chk-pay.tot-sum = p-netto
      accum-pay = accum-pay + buf_chk-pay.tot-sum
      buf_chk-pay.is-error = ?
      .
      run libchkvl_process-chk-pay in this-procedure (
                                             input p-context-bh
                                            ,buffer buf_chk-doc
                                            ,buffer buf_chk-pay
                                            ,input-output noexchrate
                                            ,input-output for-chk-type
                                            ) no-error .
    end.
  end.
  if p-wmode = 'ИЗМЕНЕНИЕ':U then do:
    define variable loc#log as logical no-undo .
    if p-edit-mode = 'ДОБАВЛЕНИЕ':U then do:
      define variable v-netto-virtual as decimal no-undo .
      assign
      v-netto-virtual = buf_chk-doc.netto
      .
      if (buf_chk-doc.d-card <> "":U or
        buf_chk-doc.src-d-pcnt <> 0 ) AND
        p-sub-d = 0
      then  do:
        v-netto-virtual = v-netto-virtual * (1 - buf_chk-doc.src-d-pcnt / 100).
      end.
      else do:
        if p-sub-d <> 0 then do:
          v-netto-virtual = v-netto-virtual - p-sub-d.
        end.
      end.
      if not v-is-annu-check
      and not v-is-inventory
      and not v-is-z-rep
      and abs(v-netto-virtual -
            (if buf_chk-doc.chk-type = integer('1':U)
              or buf_chk-doc.chk-type = integer('69':U)
              then v-write-off-sum
              else 0) - accum-pay) > 0.01 then do:
        message
        substitute(("Сумма нетто по чеку &1 не совпадает с суммой оплат&2" +
        "разница составляет &3&2" +
        "Сумма нетто=&4 Сумма оплат=&5&2" +
        "Вы уверены, что создали правильный чек?")
        , (if v-write-off-sum <> 0 then "(с учетом суммы списания)" else '')
        , chr(10)
        , abs(v-netto-virtual - accum-pay)
        , v-netto-virtual
        , accum-pay)
        view-as alert-box  question buttons YES-NO update loc#log.
        if not loc#log then return error.
      end.
    end.
  end.
  if (buf_chk-doc.netto = 0
      and not v-is-petrol-check
      and not v-is-annu-check
      and not v-is-inventory
      and not v-is-z-rep
      and not v-is-shft-open-close
      and not v-is-ord-check
      and not (v-is-100-discnt and accum-pay-count > 0)
      )
  or (buf_chk-doc.netto <> 0 and v-is-petrol-check)
  or (buf_chk-doc.netto <> 0 and v-is-shft-open-close)
  or (buf_chk-doc.doc-qnty <> 0 and buf_chk-doc.chk-type = integer('16':U))
  or (buf_chk-doc.doc-qnty = 0
      and v-is-petrol-check
      and not (buf_chk-doc.chk-type = integer('16':U)
              or
              buf_chk-doc.chk-type = integer('14':U)
              or
              buf_chk-doc.chk-type = integer('36':U)
              )
      )
  then do:
    assign
    for-chk-type = for-chk-type + 'сум-ош':U + chr(44)
    buf_chk-doc.correct = no
    v-view-log = yes
    .
    if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input (if v-is-petrol-check                 then (if buf_chk-doc.netto <> 0                       then substitute(                             "!!!Чек &1 - ошибочный. &2Сумма по чеку <> 0.Чек типа &3"                             , buf_chk-doc.doc-code                             , chr(10)                             , entry (lookup (string(buf_chk-doc.chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))                       else   (if buf_chk-doc.doc-qnty <> 0 and buf_chk-doc.chk-type = integer('16':U)                               then substitute("!!!Чек &1 - ошибочный. &2Кол-во по чеку <> 0.Чек типа &3"                                             , buf_chk-doc.doc-code                                               , chr(10)                                             , entry (lookup (string(buf_chk-doc.chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))                               else substitute("!!!Чек &1 - ошибочный. &2Кол-во по чеку = 0.Чек типа &3"                                             , buf_chk-doc.doc-code                                             , chr(10)                                             , entry (lookup (string(buf_chk-doc.chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))                               )                       )                 else substitute(                             "!!!Чек &1 - ошибочный. &2Сумма по чеку = 0. &2Возможно, это ошибка кассира и Вам следует просто удалить этот чек"                             , buf_chk-doc.doc-code                             , chr(10))                  ) ).
  end.
  CorrValue = 0.
  if p-sub-d <> 0 then do:
    def var v-excsum as dec no-undo.
    FOR EACH chk-gds WHERE
              chk-gds.doc-code = chk-doc.doc-code,
        first t-gds where
              t-gds.b-code = chk-gds.b-code and
              t-gds.drc = recid(chk-doc):
      find first ub.bar-code where ub.bar-code.b-code = buf_chk-gds.b-code no-error.
      find first ub.dis-gds-rule where ub.dis-gds-rule.gds-code = ub.bar-code.gds-code and ub.dis-gds-rule.templ-rl-root = 55 no-error.
      find first ub.clients where ub.clients.obj-type = v-obj-type and ub.clients.obj-code = v-obj-code no-error.
      if can-find (first ub.dis-rule no-lock where ub.dis-rule.rule-num = ub.dis-gds-rule.rule-num and
                         ((ub.dis-rule.host-code = 0 and ub.dis-rule.obj-code = 0 and ub.dis-rule.obj-type = "")
                      or (ub.dis-rule.host-code = ub.clients.host-code and ub.dis-rule.obj-code = 0 and ub.dis-rule.obj-type = "")
                      or (ub.dis-rule.obj-code = v-obj-code and ub.dis-rule.obj-type = v-obj-type))
                    )
      then do:
        v-excsum = chk-gds.src-sum + v-excsum.
      end.
    end.
    for each buf0_chk-discnt where
              buf0_chk-discnt.doc-code = buf_chk-doc.doc-code
          AND buf0_chk-discnt.record-type = 0 :
      if NOT (buf0_chk-discnt.line-type = integer('2':U) or
              buf0_chk-discnt.line-type = integer('3':U) or
              buf0_chk-discnt.line-type = integer('4':U) or
              buf0_chk-discnt.line-type = integer('5':U)
            ) then NEXT.
      if recid(buf0_chk-discnt) = var-pcnt-discnt then NEXT.
      if abs(buf0_chk-discnt.object-sum) < abs(buf0_chk-discnt.discnt-value-abs)
      and not(abs(abs(buf0_chk-discnt.object-sum) - abs(buf0_chk-discnt.discnt-value-abs)) < 0.2
                    and
                    v-is-100-discnt)
      then do:
        assign
        for-chk-type = for-chk-type + 'сум-ош':U + chr(44)
        buf_chk-doc.correct = no
        v-view-log = yes
        .
        if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                                 "!!!Чек &1 - ошибочный. &2 Скидка по чеку больше или равна сумме чека&2" +                                 "(за вычетом товаров, на которые скидка на итог распределяться не должна)&2" +                                 "Чек придется пересоздать руками"                                 , buf_chk-doc.doc-code                                 , chr(10)                               ) ).
      end.
      assign
      buf_chk-doc.discnt = buf_chk-doc.discnt + buf0_chk-discnt.discnt-value-abs
      buf_chk-doc.netto = buf_chk-doc.netto - buf0_chk-discnt.discnt-value-abs
      .
      assign
      v-discnt-sum = 0
      .
        _buf_chk-gds:
        FOR EACH buf_chk-gds WHERE
                  buf_chk-gds.doc-code = buf_chk-doc.doc-code AND
                  (buf_chk-gds.line-num <= buf0_chk-discnt.line-num
                  or buf0_chk-discnt.line-type = integer('4':U)
                  or buf0_chk-discnt.line-type = integer('5':U)),
            first t-gds where
                  t-gds.b-code = buf_chk-gds.b-code and
                  t-gds.drc = recid(buf_chk-doc):
          if buf_chk-gds.doc-qnty = 0 then do:
            NEXT _buf_chk-gds.
          end.
          v-fttwd = no.
          assign
          v-fttwd = v-tt-wd-bh:find-first( substitute(' where doc-code = "&1" and record-type = 0 and line-type = &2 and line-num = &3 and discnt-id < &4'
                                                             , buf_chk-gds.doc-code
                                                             , integer('7':U)
                                                             , buf_chk-gds.line-num
                                                             , buf0_chk-discnt.discnt-id))
          no-error.
          if v-tt-wd-bh:available
          then do:
            NEXT _buf_chk-gds.
          end.
          if (buf_chk-doc.chk-type = integer('1':U)
          or buf_chk-doc.chk-type = integer('6':U)
          )
          and buf_chk-gds.write-off-code <> ?
          and buf_chk-gds.write-off-code > 0 then do:
            NEXT _buf_chk-gds.
          end.
          find first ub.bar-code where ub.bar-code.b-code = buf_chk-gds.b-code no-error.
          find first ub.dis-gds-rule where ub.dis-gds-rule.gds-code = ub.bar-code.gds-code and ub.dis-gds-rule.templ-rl-root = 55 no-error.
          find first ub.clients where ub.clients.obj-type = v-obj-type and ub.clients.obj-code = v-obj-code no-error.
          if can-find (first ub.dis-rule no-lock where ub.dis-rule.rule-num = ub.dis-gds-rule.rule-num and
                             ((ub.dis-rule.host-code = 0 and ub.dis-rule.obj-code = 0 and ub.dis-rule.obj-type = "")
                          or (ub.dis-rule.host-code = ub.clients.host-code and ub.dis-rule.obj-code = 0 and ub.dis-rule.obj-type = "")
                          or (ub.dis-rule.obj-code = v-obj-code and ub.dis-rule.obj-type = v-obj-type))
                        )
          then do:
            NEXT _buf_chk-gds.
          end.
          if buf0_chk-discnt.object-sum - v-excsum = 0
          then do:
            v-excsum = v-excsum - buf_chk-gds.doc-qnty.
          end.
          if ChkPromoPrice(buf_chk-gds.doc-code, buf_chk-gds.line-num)
          then
             var-gds-for-discnt = RoundUp(buf_chk-gds.doc-qnty, (buf_chk-gds.price-base - buf_chk-gds.discnt) ).
          else
             var-gds-for-discnt = (buf_chk-gds.price-base - buf_chk-gds.discnt) * buf_chk-gds.doc-qnty.
          assign
          str-dec = if buf0_chk-discnt.object-sum <> 0
                    then (if buf0_chk-discnt.discnt-value-pcnt = 100
                          and buf0_chk-discnt.value-type= integer('1':U)
                          then (buf_chk-gds.price-base - buf_chk-gds.discnt)
                          else (buf_chk-gds.price-base - buf_chk-gds.discnt) * (buf0_chk-discnt.discnt-value-abs / buf0_chk-discnt.object-sum - v-excsum)
                          )
                    else 0
          v-discnt-sum = v-discnt-sum + str-dec * buf_chk-gds.doc-qnty
          buf_chk-gds.discnt = buf_chk-gds.discnt + str-dec
          t-gds.discnt-sum = t-gds.discnt-sum + buf_chk-gds.doc-qnty * str-dec
          .
          create buf_chk-discnt.
          buffer-copy buf0_chk-discnt to buf_chk-discnt
          assign
          buf_chk-discnt.record-type = 1
          buf_chk-discnt.object-line-num = buf_chk-gds.line-num
          buf_chk-discnt.object-qnty = buf_chk-gds.doc-qnty
          buf_chk-discnt.object-sum = var-gds-for-discnt
          buf_chk-discnt.discnt-value-abs =  buf_chk-gds.doc-qnty * str-dec
          buf_chk-discnt.discnt-value-pcnt = if buf_chk-discnt.object-sum <> 0
                                            then (if buf0_chk-discnt.discnt-value-pcnt = 100
                                                  and buf0_chk-discnt.value-type= integer('1':U)
                                                  then 100
                                                  else (buf_chk-discnt.discnt-value-abs / buf_chk-discnt.object-sum * 100)
                                                  )
                                            else 0
          .
        end.
      if abs(v-discnt-sum - buf0_chk-discnt.DISCNT-VALUE-ABS) > 0.0000000001 then do:
        if buf0_chk-discnt.discnt-value-pcnt = 100
        and buf0_chk-discnt.value-type = integer('1':U) then do:
          assign
          buf_chk-doc.discnt = buf_chk-doc.discnt - (buf0_chk-discnt.discnt-value-abs - v-discnt-sum)
          buf_chk-doc.netto = buf_chk-doc.netto + (buf0_chk-discnt.discnt-value-abs - v-discnt-sum)
          .
        end.
        else do:
          assign
          corrvalue = abs(v-discnt-sum) - abs(buf0_chk-discnt.DISCNT-VALUE-ABS)
          corr-sign = (if buf_chk-doc.netto >= 0 then 1 else -1) *  (if buf0_chk-discnt.DISCNT-VALUE-ABS >= 0 then 1 else -1)
          .
          if not v-is-annu-check then
          run libchkvl_set-corr-discnt in this-procedure (
                                                 input p-context-bh
                                                ,buffer buf_chk-doc
                                                ,input CorrValue
                                                ,input no
                                                ,input no
                                                ,input corr-sign
                                                ,input-output v-write-off-sum
                                                ,input-output for-chk-type
                                                ,input-output var-discnt-id
                                                ) .
        end.
      end.
    end.
  end.
  if var-pcnt-discnt <> ? then do:
    assign
    COrrValue = 0
    .
    find first buf_chk-discnt where
                recid(buf_chk-discnt) = var-pcnt-discnt no-error .
    if not avail buf_chk-discnt then do:
    end.
    else  do:
      if NOT can-do( for-chk-type, 'сумма':U ) then do:
        assign
        netto-for-tot-d-pcnt = 0
        v-discnt-sum = 0
        .
        FOR EACH buf_chk-gds WHERE
                buf_chk-gds.doc-code = buf_chk-doc.doc-code:
          if buf_chk-discnt.line-num > 0 and buf_chk-gds.line-num > buf_chk-discnt.line-num then NEXT.
          if (buf_chk-doc.chk-type = integer('1':U)
          or buf_chk-doc.chk-type = integer('6':U)
          )
          and buf_chk-gds.write-off-code <> ?
          and buf_chk-gds.write-off-code > 0  then NEXT.
          if buf_chk-gds.doc-qnty = 0 then NEXT.
          assign
          str-dec = (buf_chk-gds.price-base - buf_chk-gds.discnt)  / 100 * ( buf_chk-discnt.discnt-value-pcnt )
          var-gds-for-discnt = (buf_chk-gds.price-base - buf_chk-gds.discnt) * buf_chk-gds.doc-qnty
          netto-for-tot-d-pcnt = netto-for-tot-d-pcnt + var-gds-for-discnt
          buf_chk-gds.discnt = buf_chk-gds.discnt +  str-dec
          v-discnt-sum = v-discnt-sum + str-dec * buf_chk-gds.doc-qnty
          .
          create buf0_chk-discnt.
          buffer-copy buf_chk-discnt to buf0_chk-discnt
          assign
          buf0_chk-discnt.record-type = 1
          buf0_chk-discnt.discnt-value-abs = str-dec * buf_chk-gds.doc-qnty
          buf0_chk-discnt.object-qnty = buf_chk-gds.doc-qnty
          buf0_chk-discnt.object-sum = var-gds-for-discnt
          buf0_chk-discnt.object-line-num = buf_chk-gds.line-num
          buf0_chk-discnt.d-card      = if buf0_chk-discnt.d-card = ? or buf0_chk-discnt.d-card = "" then buf_chk-gds.d-card else buf0_chk-discnt.d-card
          buf_chk-discnt.d-card      = if buf_chk-discnt.d-card = ? or buf_chk-discnt.d-card = "" then buf_chk-gds.d-card else buf_chk-discnt.d-card
          .
        END .
        assign
        buf_chk-doc.discnt = buf_chk-doc.discnt + ( netto-for-tot-d-pcnt / 100 * ( buf_chk-discnt.discnt-value-pcnt ) )
        buf_chk-doc.netto = buf_chk-doc.netto - ( netto-for-tot-d-pcnt / 100 * ( buf_chk-discnt.discnt-value-pcnt ) )
        buf_chk-discnt.discnt-value-abs = netto-for-tot-d-pcnt * buf_chk-discnt.discnt-value-pcnt * 0.01
        buf_chk-discnt.object-sum = netto-for-tot-d-pcnt
        .
        if abs(v-discnt-sum - buf_chk-discnt.DISCNT-VALUE-ABS) > 0.0000000001 then do:
          assign
          corrvalue = abs(v-discnt-sum) - abs(buf_chk-discnt.DISCNT-VALUE-ABS)
          corr-sign = (if buf_chk-discnt.discnt-value-abs >= 0
                        then 1
                        else -1)
          .
          if not v-is-annu-check then
          run libchkvl_set-corr-discnt in this-procedure (
                                                 input p-context-bh
                                                ,buffer buf_chk-doc
                                                ,input CorrValue
                                                ,input no
                                                ,input no
                                                ,input corr-sign
                                                ,input-output v-write-off-sum
                                                ,input-output for-chk-type
                                                ,input-output var-discnt-id
                                                ) .
        end.
      end.
      else do:
      end.
    end.
  end.
  for each buf0_chk-discnt where
          buf0_chk-discnt.doc-code = buf_chk-doc.doc-code
      and buf0_chk-discnt.record-type  = 4
  :
    if buf0_chk-discnt.line-type = integer('1':U)
    and buf0_chk-discnt.object-line-num > 0
    then do:
      find first buf_chk-gds no-lock where
                buf_Chk-gds.doc-code = buf_chk-doc.doc-code
            and buf_Chk-gds.line-num = buf0_chk-discnt.object-line-num no-error.
      if not available buf_chk-gds
      then do:
        assign
        buf0_chk-discnt.discnt-value-pcnt = 0
        for-chk-type = for-chk-type + 'скидка-ош':U
        v-view-log = yes
        buf_chk-doc.correct = no
        .
        if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                                 "!!!Чек &1 - ошибочный.&2Бонус в строке &3 указывает на товар &4 строки &5&2" +                                 "но код товара для строки &3 равен &6"                                 , buf_chk-doc.doc-code                                 , chr(10)                                 , buf0_chk-discnt.line-num                                 , buf0_chk-discnt.discnt-value-pcnt                                 , buf0_chk-discnt.object-line-num                                 , (if available buf_chk-gds then  buf_chk-gds.src-code else chr(63))                               ) ).
      end.
      else do:
        if  buf0_chk-discnt.kateg = -1
        or ((buf0_chk-discnt.kateg = 0
              and v-r-b = 'rubl':U
              )
              or
              (buf0_chk-discnt.kateg = v-base-code
              and v-r-b = 'base':U)
            )
        then do:
          assign
          buf0_chk-discnt.object-qnty = buf_chk-gds.src-qnty
          buf0_chk-discnt.object-sum = buf_chk-gds.src-sum
          buf0_chk-discnt.discnt-value-pcnt =  buf0_chk-discnt.discnt-value-abs / buf_chk-gds.src-sum * 100
          .
        end.
        create buf_chk-discnt.
        buffer-copy buf0_chk-discnt
        except record-type
        to buf_chk-discnt
        assign
        buf_chk-discnt.record-type = 5
        buf_chk-discnt.object-qnty = buf_chk-gds.doc-qnty
        buf_chk-discnt.object-sum  = buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt)
        .
      end.
    end.
    if buf0_chk-discnt.line-type = integer('2':U)
    or buf0_chk-discnt.line-type = integer('1':U)
    then do:
      define variable v-cycle as integer no-undo .
      if buf0_chk-discnt.line-type = integer('2':U) then do:
        assign
        buf0_chk-discnt.object-qnty = 0
        buf0_chk-discnt.object-sum  = 0
        .
      end.
      do v-cycle = 1 to (if buf0_chk-discnt.line-type = integer('1':U)
                          then 1
                          else 2):
        _buf_chk-gds:
        FOR EACH buf_chk-gds WHERE
                  buf_chk-gds.doc-code = buf_chk-doc.doc-code AND
                  buf_chk-gds.line-num <= buf0_chk-discnt.object-line-num,
            first t-gds where
                  t-gds.b-code = buf_chk-gds.b-code and
                  t-gds.drc = recid(buf_chk-doc):
          if buf_chk-gds.doc-qnty = 0 then do:
              NEXT _buf_chk-gds.
            end.
            if buf0_chk-discnt.line-type = integer('1':U)
            and decimal(buf_chk-gds.src-code) <> buf0_chk-discnt.discnt-value-pcnt then next _buf_chk-gds.
            if (buf_chk-doc.chk-type = integer('1':U)
            or buf_chk-doc.chk-type = integer('6':U)
            )
            and buf_chk-gds.write-off-code <> ?
            and buf_chk-gds.write-off-code > 0 then do:
              NEXT _buf_chk-gds.
            end.
            if v-cycle = 1
            and (buf0_chk-discnt.kateg = -1
                  or
                  ((buf0_chk-discnt.kateg = 0
                  and v-r-b = 'rubl':U
                  )
                  or
                  (buf0_chk-discnt.kateg = v-base-code
                  and v-r-b = 'base':U)
                  )
                  )
            then do:
              assign
              buf0_chk-discnt.object-qnty = buf0_chk-discnt.object-qnty + buf_chk-gds.doc-qnty
              buf0_chk-discnt.object-sum  = buf0_chk-discnt.object-sum + buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt)
              buf0_chk-discnt.discnt-value-pcnt = (if buf0_chk-discnt.object-sum = 0
                                              then 0
                                              else buf0_chk-discnt.discnt-value-abs / buf0_chk-discnt.object-sum   * 100)
              .
            end.
          if (v-cycle = 2 and buf0_chk-discnt.line-type = integer('2':U))
          then do:
              create buf_chk-discnt.
              buffer-copy buf0_chk-discnt to buf_chk-discnt
              assign
              buf_chk-discnt.record-type = 5
              buf_chk-discnt.object-line-num = buf_chk-gds.line-num
              buf_chk-discnt.object-qnty = buf_chk-gds.doc-qnty
              buf_chk-discnt.object-sum = (buf_chk-gds.price-base - buf_chk-gds.discnt) * buf_chk-gds.doc-qnty
              buf_chk-discnt.discnt-value-abs  = (if buf0_chk-discnt.object-sum = 0
                                                  then 0
                                                  else buf0_chk-discnt.discnt-value-abs * buf_chk-discnt.object-sum / buf0_chk-discnt.object-sum)
              buf_chk-discnt.discnt-value-pcnt = if buf_chk-discnt.object-sum <> 0
                                                then buf_chk-discnt.discnt-value-abs / buf_chk-discnt.object-sum * 100
                                                else 0
              .
          end.
        end.
      end.
    end.
  end.
  if not v-is-annu-check then do:
    assign
    buf_chk-doc.sub-discnt = v-write-off-sum
    buf_chk-doc.tot-doc    = buf_chk-doc.tot-doc - (if buf_chk-doc.chk-type = integer('6':U)
                                            or buf_chk-doc.chk-type = integer('96':U)
                                            then 0
                                            else buf_chk-doc.sub-discnt)
    buf_chk-doc.netto      = buf_chk-doc.netto -
                        (if (buf_chk-doc.chk-type = integer('6':U)
                        or buf_chk-doc.chk-type = integer('96':U)
                                            )
                                            then 0
                        else buf_chk-doc.sub-discnt)
    .
    if p-netto <> ? then do:
      if (buf_chk-doc.chk-type = integer('69':U)
      or buf_chk-doc.chk-type = integer('96':U) ) then do:
        if p-netto <> ((if lookup(string(buf_chk-doc.chk-type), '1,69,14,15,16,36':U) > 0
                        then 1
                        else - 1) * (buf_chk-doc.sub-discnt +
                                    (if buf_chk-doc.chk-type = integer('96':U)
                                    then buf_chk-doc.discnt
                                    else 0
                                    ))
                      )
          and not v-is-z-rep and not v-pos-type-int = integer('7':U)
          then do:
          if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                                "!!!Чек &1 - ошибочный (Номер по кассе: &2 Касса: &3)&4" +                               "Сумма транзакции не совпадает с суммой списания по чеку&4" +                                "Сумма транзакции = &5, сумма списания по чеку = &6&4" +                               "Обратитесь к администратору Вашей системы"                                , buf_chk-doc.doc-code                               , buf_chk-doc.chk-num                                 , buf_chk-doc.pay-desk                                , chr(10)                               , p-netto                               , buf_chk-doc.sub-discnt                             ) ).
          assign
          for-chk-type = for-chk-type + 'сум-ош':U + chr(44)
          buf_chk-doc.correct = no
          v-view-log = yes
          .
        end.
      end.
      else do:
        if not v-is-petrol-check
        and ((p-netto = 0 and accum-pay <> 0)
        or (p-netto <> 0 and  ABS(ABS(p-netto - ACCUM-pay) / p-netto ) > 0.01))
        and not v-is-z-rep
        and not v-is-ord-check
        then do:
              if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                                 "!!!Чек &1 - ошибочный (Номер по кассе: &2 Касса: &3)&4" +                               "Сумма транзакции не совпадает с суммой оплат по чеку&4" +                               "Сумма транзакции = &5, сумма оплат по чеку = &6&4" +                                     "Обратитесь к администратору Вашей системы"                                             , buf_chk-doc.doc-code                                                                  , buf_chk-doc.chk-num                                                                   , buf_chk-doc.pay-desk                                                                  , chr(10)                                                                           , p-netto                                                                               , accum-pay                                                                           ) ).
              assign
              for-chk-type = for-chk-type + 'сум-ош':U + chr(44)
              buf_chk-doc.correct = no
              v-view-log = yes
              .
        end.
      end.
    end.
    if (buf_chk-doc.netto >= 0
        and (buf_chk-doc.chk-type = integer('6':U)
            or
            buf_chk-doc.chk-type = integer('96':U)
            )
        and not (v-is-100-discnt
                  and buf_chk-doc.netto <= (if buf_chk-doc.cash-rate > 1
                                        then 0.001 * buf_chk-doc.cash-rate
                                        else 0.01)
                  and buf_chk-doc.chk-type = integer('6':U))
        )
    or (buf_chk-doc.netto < 0
        and (buf_chk-doc.chk-type = integer('1':U)
                            or
                            buf_chk-doc.chk-type = integer('69':U))
        and not (v-is-100-discnt
                  and abs(buf_chk-doc.netto) < (if buf_chk-doc.cash-rate > 1
                                          then 0.001 * buf_chk-doc.cash-rate
                                          else 0.01)
                  and buf_chk-doc.chk-type = integer('1':U))
        )
    then do:
        assign
        for-chk-type = for-chk-type + 'сум-ош':U + chr(44)
        buf_chk-doc.correct = no
        v-view-log = yes
        .
                if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                                 "!!!Чек &1 - ошибочный&2" +                                 "Сумма нетто &3 не соответствует типу чека: &4"                                 , buf_chk-doc.doc-code                                 , chr(10)                                 , buf_chk-doc.netto                                 , entry (lookup (string(buf_chk-doc.chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)                               ) ).
            end.
    if (v-is-z-rep
    or  v-is-shft-open-close)
    and buf_chk-doc.discnt <> 0 then do:
            assign
        for-chk-type = for-chk-type + 'сум-ош':U + chr(44)
        buf_chk-doc.correct = no
        v-view-log = yes
        .
    end.
    if v-is-petrol-check
    or v-is-inventory
    or v-is-ord-check
    then do:
      if accum-pay <> 0
      or (accum-pay-count <> 0
            and lookup(string(buf_chk-doc.chk-type), ('17':U + "," + '36':U + "," + '16':U + "," + '14':U)) = 0)
      or (buf_chk-doc.discnt <> 0 and not v-is-ord-check)
      then do:
        assign
        for-chk-type = for-chk-type + 'сум-ош':U + chr(44)
        buf_chk-doc.correct = no
        v-view-log = yes
        .
          substitute("!!!Чек &1 - ошибочный&2" +                               "В чеке типа &3 не может быть платежей и/или скидок!"                               , buf_chk-doc.doc-code                               , chr(10)                               , entry (lookup (string(buf_chk-doc.chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)).
      end.
    end.
    else do:
      if v-is-z-rep
      or v-is-shft-open-close
      or buf_chk-doc.chk-type = integer('43':U) or buf_chk-doc.chk-type = integer('44':U)
      then do:
      end.
      else do:
        if (
        ((ACCUM-pay  = 0)
        and (buf_chk-doc.sub-discnt = 0
            or
            (buf_chk-doc.chk-type <> integer('1':U)
            and
            buf_chk-doc.chk-type <> integer('69':U)
            )
            )
          and not (v-is-100-discnt
                  and
                  accum-pay-count > 0)
          )
        OR
          (NOT ( (accum-pay > 0) = (buf_chk-doc.netto > 0)) and buf_chk-doc.sub-discnt = 0
            and not (v-is-100-discnt
                                and accum-pay-count > 0
                                and accum-pay = 0
                                and buf_chk-doc.netto = 0
                                )
          )
        )
        and not
          (abs(abs(accum-pay) - abs(buf_chk-doc.netto)) < 0.01
          and (v-is-100-discnt
              and accum-pay-count > 0
              and accum-pay = 0
              )
          )
        and not
          (accum-pay < 0
           and buf_chk-doc.chk-type = int('6':U)
           and round(buf_chk-doc.netto,8) = 0
           and v-is-100-discnt
          )
        then do:
          assign
          for-chk-type = for-chk-type + 'сум-ош':U + chr(44)
          buf_chk-doc.correct = no
          v-view-log = yes
          .
          if aCCUM-pay = 0
          and
          (buf_chk-doc.sub-discnt = 0
            or (buf_chk-doc.chk-type <> integer('1':U)
                and
                buf_chk-doc.chk-type <> integer('69':U))
            )
          and not (v-is-100-discnt and accum-pay-count > 0)
          then do:
            if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                                     "!!!Чек &1 - ошибочный&2" +                                     "Сумма оплат = 0"                                     , buf_chk-doc.doc-code                                     , chr(10)                                   ) ).
          end.
          else do:
            if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                                     "!!!Чек &1 - ошибочный&2" +                                     "Сумма оплат и сумма по товарам имеют разные знаки!"                                     , buf_chk-doc.doc-code                                     , chr(10)                                   ) ).
          end.
        end.
        else dO:
          if ABS(  ACCUM-pay - buf_chk-doc.netto ) > 0.0000000001 then do:
            if accum-pay = 0
            and v-is-100-discnt then do:
              assign
              for-chk-type = for-chk-type + 'сум-ош':U + chr(44)
              buf_chk-doc.correct = no
              v-view-log = yes
              .
              if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                                       "!!!Чек &1 - ошибочный&2" +                                       "Сумма нетто <> 0 для чека с 100% скидкой!"                                       , buf_chk-doc.doc-code                                       , chr(10)                                     ) ).
            end.
            else do:
              assign
              temp-d =  ABS(ACCUM-pay) - ABS(buf_chk-doc.netto)
              corr-sign = 1
              .
              if not v-is-annu-check then
              run libchkvl_set-corr-discnt in this-procedure (
                                                     input p-context-bh
                                                    ,buffer buf_chk-doc
                                                    ,input temp-d
                                                    ,input yes
                                                    ,input yes
                                                    ,input corr-sign
                                                    ,input-output v-write-off-sum
                                                    ,input-output for-chk-type
                                                    ,input-output var-discnt-id
                                                    ) .
            end.
          end.
        end.
          FOR EACH t-gds No-LOCK WHERE
                  t-gds.drc = recid(buf_chk-doc):
          if t-gds.doc-qnty <> 0 or abs(t-gds.price-sum - t-gds.discnt-sum) > 0.0005 then do:
            IF  NOT (t-gds.doc-qnty > 0) = (t-gds.price-sum - t-gds.discnt-sum > 0) OR
                NOT (t-gds.doc-qnty < 0) = (t-gds.price-sum - t-gds.discnt-sum < 0) OR
                    ((t-gds.doc-qnty < 0) AND (buf_chk-doc.netto > 0)) OR
                    ((t-gds.doc-qnty > 0) AND (buf_chk-doc.netto < 0))  then do:
              if (abs(t-gds.price-sum - t-gds.discnt-sum) = 0
              AND
              (
              (
                (t-gds.doc-qnty <> 0
                AND t-gds.is-modificator)
                or
                (t-gds.is-null-price and t-gds.b-code <> ?)
              )
              or (t-gds.doc-qnty <> 0
                and
                (v-is-100-discnt AND ACCUM-PAY-COUNT > 0)
                )
                )
              )
              or (abs(abs(t-gds.price-sum) - abs(t-gds.discnt-sum)) < 0.01
                  and
                  v-is-100-discnt)
              then do:
              end.
              else do:
                assign
                for-chk-type = for-chk-type + 'сум-ош':U + chr(44)
                buf_chk-doc.correct = no
                .
                if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                             "!!!Чек &1 - ошибочный&2" +                              "По товару с бар-кодом &3, проданном &4 строками чека, имеются несоответствия количества и суммы" +                             "&5 либо имеются несоответствия типа чека (продажа/возврат) знаку товарной суммы"                             , buf_chk-doc.doc-code                             , chr(10)                             , t-gds.b-code                             , t-gds.num-lines                             , chr(10)                           ) ).
              end.
            END.
          END.
        END.
        FOR EACH t-pay No-LOCK WHERE
                  t-pay.drc = recid(buf_chk-doc):
          if t-pay.tot-rubl <> 0
          or t-pay.tot-base <> 0
          then do:
            IF ((v-r-b = 'rubl':U
                and
                t-pay.tot-rubl < 0)
              AND (buf_chk-doc.netto > 0)
              )
          OR
          ((v-r-b = 'base':U
              and
              t-pay.tot-base < 0)
              AND (buf_chk-doc.netto > 0)
            )
            or
          ((v-r-b = 'rubl':U
              and
              t-pay.tot-rubl > 0)
              AND (buf_chk-doc.netto < 0)
            )
            or
          ((v-r-b = 'base':U
              and
              t-pay.tot-base > 0)
              AND (buf_chk-doc.netto < 0)
            )
            or
            ((t-pay.tot-rubl >= 0) <> (t-pay.tot-base >= 0))
          then do:
              assign
              for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
              buf_chk-doc.correct = no
              .
              if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                             "!!!Чек &1 - ошибочный&2" +                             "По платежу с кодом &3, с &4 строками оплат чека, имеются несоответствия количества и суммы" +                             "&5 либо имеются несоответствия типа чека (продажа/возврат) знаку суммы платежа"                             , buf_chk-doc.doc-code                             , chr(10)                             , t-pay.pay-code                             , t-pay.num-lines                             , chr(10)                           ) ).
            END.
          END.
        END.
      end.
    end.
  end.
  if ChkGdsPromo(buf_chk-doc.doc-code) then
     v-promo-sum = GetPromoSum(buf_chk-doc.doc-code).
  else v-promo-sum = 0.
  assign
  buf_chk-doc.tot-doc = buf_chk-doc.tot-doc + v-promo-sum
  buf_chk-doc.discnt = buf_chk-doc.discnt + v-promo-sum
  buf_chk-doc.d-pcnt = if buf_chk-doc.tot-doc = 0
                    then 0
                    else ( buf_chk-doc.discnt / buf_chk-doc.tot-doc * 100 )
  .
  if buf_chk-doc.chk-type = integer('8':U)
  or buf_chk-doc.chk-type = integer('301':U)
  or buf_chk-doc.chk-type = integer('306':U)
  or buf_chk-doc.chk-type = integer('306':U)
  then do:
    assign
    buf_chk-doc.tot-doc = 0
    buf_chk-doc.netto = 0
    buf_chk-doc.discnt = 0
    buf_chk-doc.sub-discnt = 0
    buf_chk-doc.doc-qnty = 0
    .
  end.
  assign
  buf_chk-doc.office = RIGHT-TRIM(for-chk-type, chr(44)) +
                       (if not p-close-check
                        then (chr(44) + 'готов':U)
                        else '')
  buf_chk-doc.whole-send-news = v-pos-type-int
  buf_chk-doc.correct =  (if
                      replace(replace(replace(replace(buf_chk-doc.office
                                                    , 'т':U
                                                    , '':U)
                                            , 'у':U
                                            , '':U)
                                      , 'готов':U
                                      , '':U)
                              , chr(44)
                              , '':U) = '':U
                      then (if buf_chk-doc.correct = ?
                            or buf_chk-doc.correct = yes
                            then yes
                            else no)
                      else no)
  .
  find first ub.chk-gds no-lock where ub.chk-gds.doc-code = buf_chk-doc.doc-code no-error.
  if trim(buf_chk-doc.office) = "" and not available ub.chk-gds then
      buf_chk-doc.office = 'т':U.
  if v-pos-type-int <> integer('7':U)  then p-prev-code = "" .
end.
error-status:error = no.
end procedure.
procedure libchkvl_set-corr-discnt private:
define input parameter p-context-bh as handle no-undo .
define parameter buffer buf_chk-doc for ub.chk-doc.
define input parameter p-corr-value as decimal no-undo .
define input parameter p-fix-discnt as logical no-undo .
define input parameter p-fix-netto  as logical no-undo .
define input parameter p-corr-sign as integer no-undo .
define input-output parameter p-write-off-sum as decimal no-undo .
define input-output parameter for-chk-type as character no-undo .
define input-output parameter p-discnt-id as integer no-undo .
DEFINE VARIABLE nd                         as   logical             no-undo .
DEFINE VARIABLE var-gds-for-discnt         as decimal               no-undo .
define variable v-old-discnt               as decimal               no-undo .
define variable v-log-handle as handle no-undo .
define variable v-old-corr-discnt-rank as decimal no-undo.
define variable v-fttwd as logical no-undo .
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf0_chk-discnt for ub.chk-discnt.
do
on error undo, return error
:
  if p-context-bh::p-log-file-name <> ""
  and p-context-bh::p-log-file-name <> ? then do:
    log-file-name = p-context-bh::p-log-file-name.
  end.
  else do:
    log-file-name = log-file-name0.
  end.
  v-log-handle = p-context-bh::p-log-handle.
  assign
  nd = yes
  .
  if  LOOKUP('сумма':U, for-chk-type ) > 0 then do:
    FOR EACH buf_chk-gds WHERE
            buf_chk-gds.doc-code = buf_chk-doc.doc-code
    by buf_chk-gds.line-num:
      nd = no.
      leave.
    end.
  end.
  else do:
    _repeat:
      FOR EACH buf_chk-gds WHERE
                buf_chk-gds.doc-code = buf_chk-doc.doc-code,
          FIRST t-gds where
                t-gds.b-code = buf_chk-gds.b-code AND
                t-gds.drc = recid(buf_chk-doc)
                :
        v-old-corr-discnt-rank = t-gds.corr-discnt-rank.
        if t-gds.first-line-num = 0
        or t-gds.first-line-num > buf_chk-gds.line-num
        then do:
          t-gds.first-line-num = buf_chk-gds.line-num.
        end.
        if t-gds.was-return and t-gds.doc-qnty <> 0 then do:
        t-gds.corr-discnt-rank = t-gds.corr-discnt-rank + 2.
        end.
        v-fttwd = no.
        assign
        v-fttwd = p-context-bh::tt-wd-bh:find-first( substitute(' where doc-code = "&1" and record-type = 0 and line-type = &2 and line-num = &3 '
                                                             , buf_chk-gds.doc-code
                                                             , integer('7':U)
                                                             , buf_chk-gds.line-num
                                                             ))
        no-error
        .
        if v-fttwd then do:
          t-gds.corr-discnt-rank = t-gds.corr-discnt-rank + 3.
        end.
        if t-gds.was-return and t-gds.doc-qnty = 0 then do:
          t-gds.corr-discnt-rank = t-gds.corr-discnt-rank + 4.
        end.
        if buf_chk-gds.price-base < abs(p-corr-value / buf_chk-gds.doc-qnty)
        and not( p-fix-netto = yes and p-corr-value > 0) then do:
          t-gds.corr-discnt-rank = t-gds.corr-discnt-rank + 5.
        end.
        if t-gds.was-write-off  then do:
          t-gds.corr-discnt-rank = t-gds.corr-discnt-rank + 6.
        end.
        if (buf_chk-gds.price-base <= buf_chk-gds.discnt - 0.2) then do:
          t-gds.corr-discnt-rank = t-gds.corr-discnt-rank + 7.
        end.
        if buf_chk-doc.chk-type = integer('96':U)
        or buf_chk-doc.chk-type = integer('69':U) then do:
          t-gds.corr-discnt-rank = t-gds.corr-discnt-rank + 8.
        end.
        if p-context-bh::is-100-discnt
        and buf_chk-doc.d-pcnt = 100
        then do:
          t-gds.corr-discnt-rank = t-gds.corr-discnt-rank + 9.
        end.
        if t-gds.corr-discnt-rank = v-old-corr-discnt-rank then do:
          assign
            t-gds.corr-discnt-rank = 0
            t-gds.first-line-num = buf_chk-gds.line-num
          .
        end.
        if t-gds.price-sum = t-gds.discnt-sum then t-gds.corr-discnt-rank = t-gds.corr-discnt-rank + 10.
        if buf_chk-gds.discnt <> 0 then do:
        t-gds.corr-discnt-rank = t-gds.corr-discnt-rank - 0.1.
        end.
        if buf_chk-gds.doc-qnty = 1 then do:
          t-gds.corr-discnt-rank = t-gds.corr-discnt-rank - 0.1.
        end.
      if t-gds.corr-discnt-rank <= 0
        then do:
          nd = no.
          leave _repeat.
        end.
      END.
    if not available t-gds
    or t-gds.corr-discnt-rank > 0
    then do:
      find first  t-gds where
              t-gds.drc = recid(buf_chk-doc) use-index icorr-discnt no-error .
    end.
  end.
  if nd = yes
  and (not available t-gds
  or (available t-gds and t-gds.first-line-num = 0)
  )
  then do:
    assign
    for-chk-type = for-chk-type + 'сум-ош':U + chr(44)
    nd = yes
    buf_chk-doc.correct = no
    .
    if valid-handle(v-log-handle) then run write-log-and-file in v-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                             "!!!Чек &1 - ошибочный. &2  - не найдена строка чека, на которую можно уложить погрешность по суммам!"                             , buf_chk-doc.doc-code                             , chr(10)                           ) ).
    p-context-bh::view-log = yes.
  end.
  if available t-gds
  and t-gds.first-line-num > 0
  and t-gds.corr-discnt-rank <= 0
  then do:
    find first buf_chk-gds where
            buf_chk-gds.doc-code = buf_chk-doc.doc-code
        and buf_chk-gds.line-num = t-gds.first-line-num.
    nd = no.
  end.
  if available t-gds
  and t-gds.first-line-num > 0
  and t-gds.corr-discnt-rank > 0
  then do:
  if t-gds.last-included-in-sale > 0 then  do:
      find first buf_chk-gds where
              buf_chk-gds.doc-code = buf_chk-doc.doc-code
          and buf_chk-gds.line-num = t-gds.last-included-in-sale  use-index ln.
      nd = no.
    end.
    else do:
      assign
      for-chk-type = for-chk-type + 'сум-ош':U + chr(44)
      nd = yes
      buf_chk-doc.correct = no
      .
        if valid-handle(v-log-handle) then run write-log-and-file in v-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                               "!!!Чек &1 - ошибочный. &2  - не найдена строка чека, на которую можно уложить погрешность по суммам!"                               , buf_chk-doc.doc-code                               , chr(10)                             ) ).
      p-context-bh::view-log = yes.
    end.
  end.
  if not nd then do:
    assign
    var-gds-for-discnt = buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt)
    v-old-discnt = buf_chk-gds.discnt
    buf_chk-gds.discnt = ( buf_chk-gds.discnt * abs( buf_chk-gds.doc-qnty ) - p-corr-value * p-corr-sign ) /  abs( buf_chk-gds.doc-qnty )
    buf_chk-doc.discnt = if p-fix-discnt
                      then (buf_chk-doc.discnt - (IF buf_chk-doc.chk-type = integer('1':U)
                                              then p-corr-value
                                              else ( - p-corr-value)) * p-corr-sign)
                      else buf_chk-doc.discnt
    buf_chk-doc.netto = if p-fix-netto
                    then (buf_chk-doc.netto +  (IF buf_chk-doc.chk-type = integer('1':U)
                                            then p-corr-value
                                            else ( - p-corr-value)) * p-corr-sign )
                    else buf_chk-doc.netto
    .
    create buf0_chk-discnt.
    assign
    buf0_chk-discnt.doc-code = buf_chk-doc.doc-code
    buf0_chk-discnt.line-num = 0
    buf0_chk-discnt.time-oper = buf_chk-doc.chk-time
    buf0_chk-discnt.line-type = integer('4':U)
    buf0_chk-discnt.pass-discnt = integer('0':U)
    buf0_chk-discnt.record-type = 2
    buf0_chk-discnt.discnt-id = p-discnt-id + 1
    buf0_chk-discnt.line-sign =  ?
    buf0_chk-discnt.value-type = integer('2':U)
    buf0_chk-discnt.discnt-type = integer('999':U)
    buf0_chk-discnt.discnt-value-abs = - p-corr-value * p-corr-sign
    buf0_chk-discnt.object-qnty = buf_chk-gds.doc-qnty
    buf0_chk-discnt.object-sum = var-gds-for-discnt
    buf0_chk-discnt.discnt-value-pcnt = if var-gds-for-discnt <> 0
                                    then (buf0_chk-discnt.discnt-value-abs / buf0_chk-discnt.object-sum) * 100
                                    else 0
    buf0_chk-discnt.object-line-num = buf_chk-gds.line-num
    buf0_chk-discnt.pay-desk = buf_chk-doc.pay-desk
    buf0_chk-discnt.obj-code = buf_chk-doc.obj-code
    buf0_chk-discnt.obj-type = buf_chk-doc.obj-type
    buf0_chk-discnt.chk-date = buf_chk-doc.chk-date
    buf0_chk-discnt.chk-time = buf_chk-doc.chk-time
    p-discnt-id = p-discnt-id + 1
    .
    if abs(buf0_chk-discnt.discnt-value-abs) > 0.01
    and search("getcheck.dbg") <> ? then do:
      assign
      for-chk-type = for-chk-type + 'сум-ош':U + chr(44)
      buf_chk-doc.correct = no
      p-context-bh::view-log = yes
      .
      if valid-handle(v-log-handle) then run write-log-and-file in v-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                             "!!!Значение скидки погрешности превышает пороговое (0.01)&1" +                             "   № чека в БД&2"                             , chr(10)                             , buf_chk-doc.doc-code                           ) ).
    end.
  end.
end.
end procedure.
procedure libchkvl_process-chk-pay private:
define input parameter p-context-bh as handle no-undo .
define parameter buffer buf_chk-doc for ub.chk-doc.
define parameter buffer buf_chk-pay for ub.chk-pay.
define input-output parameter p-noexchrate as logical no-undo .
define input-output parameter for-chk-type as character no-undo .
DEFINE VARIABLE v-pay_code                   like ub.cash-pay.cdpay-code   no-undo .
DEFINE VARIABLE v-curr_code                  like ub.cash-pay.curr-code    no-undo .
DEFINE VARIABLE curr-rate                    like ub.curr-shop.exch-rate   no-undo .
DEFINE VARIABLE curr-scale                   like ub.curr-shop.exch-scale  no-undo .
define variable v-get-qnty-method            as character   no-undo .
define variable v-get-qnty-method1           as character   no-undo .
define buffer buf_curr-shop for ub.curr-shop.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_wealth for ub.wealth.
define buffer buf_wth-par for ub.wth-par.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-parparentproc       as widget-handle           no-undo .
define variable v-p-log-handle        as handle                  no-undo .
define variable v-p-log-file-name     as character               no-undo .
define variable v-view-log            as logical                 no-undo .
define variable v-ll                  as integer                 no-undo .
define variable v-tt-wd-bh            as handle                  no-undo .
define variable v-pos-type            as character               no-undo .
define variable v-cash-num            as integer                 no-undo .
define variable v-obj-type            as character init 'маг':U  no-undo .
define variable v-obj-code            as integer                 no-undo .
define variable v-db-num              as integer                 no-undo .
define variable v-r-b                 as character               no-undo .
define variable v-host-code           as integer                 no-undo .
define variable v-base-code           as integer                 no-undo .
define variable v-cre-pay             as integer                 no-undo .
define variable v-is-catering         as logical                 no-undo .
define variable v-is-cdinv            as logical                 no-undo .
define variable v-is-ptrl             as logical                 no-undo .
define variable v-is-wth              as logical                 no-undo .
define variable v-process-sale        as logical                 no-undo .
define variable v-dc-mask             as logical                 no-undo .
define variable v-card-by-mask        as logical                 no-undo .
define variable v-sclspref            as character               no-undo .
define variable v-scpgpref            as character               no-undo .
define variable v-scpgpref-pre        as character               no-undo .
define variable v-doc-prt             as logical                 no-undo .
define variable v-shift-on            as logical                 no-undo .
define variable v-cas-shft            as logical                 no-undo .
define variable v-t-shft              as integer                 no-undo .
define variable v-v-shft              as integer                 no-undo .
define variable v-ptrl-check          as logical                 no-undo .
define variable v-annu-check          as logical                 no-undo .
define variable v-z-check             as logical                 no-undo .
define variable v-hnum                as logical                 no-undo .
define variable v-is-100-discnt       as logical                 no-undo .
define variable v-zero-cashier        as integer                 no-undo .
define variable v-rnd-znak            as integer                 no-undo .
define variable v-cas-curs            as logical                 no-undo .
define variable v-nam-2str            as logical                 no-undo .
define variable v-nam-artc            as logical                 no-undo .
define variable v-cod-pcod            as logical                 no-undo .
define variable v-name-2cd            as character               no-undo .
define variable v-how-temp-disc       as character               no-undo .
define variable v-nalc                as integer                 no-undo .
define variable v-rmethod-type        as character               no-undo .
define variable v-rmethod-coeff       as decimal                 no-undo .
define variable v-serial-code         as character               no-undo .
define variable v-salesman-mandatory  as integer                 no-undo .
define variable v-sales-man           as integer                 no-undo .
define variable v-salesman-psn-code   as integer                 no-undo .
define variable v-pos-type-for-discnt as character               no-undo .
define variable v-manual-discnt       as integer                 no-undo .
define variable v-is-grp-totals       as logical                 no-undo .
define variable v-is-gds-totals       as logical                 no-undo .
define variable v-cash-counter        as decimal                 no-undo .
define variable v-pre-cash-counter    as decimal                 no-undo .
define variable v-qnty-change         as logical                 no-undo .
define variable v-log-level           as integer                 no-undo .
define variable v-chk-discnt-table    as handle                  no-undo .
define variable v-chk-gds-table       as handle                  no-undo .
define variable v-chk-pay-table       as handle                  no-undo .
define variable v-z-number            as integer                 no-undo .
define variable v-shift-num           as integer                 no-undo .
define variable v-shift-date          as date                    no-undo .
define variable v-shift-name          as character               no-undo .
define variable v-emulator-mode       as integer                 no-undo .
define variable v-ibmgroup            as logical                 no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
v-parparentproc                      =  p-context-bh::parparentproc
v-p-log-handle                       =  p-context-bh::p-log-handle
v-p-log-file-name                    =  p-context-bh::p-log-file-name
v-view-log                           =  p-context-bh::view-log
v-ll                                 =  p-context-bh::ll
v-tt-wd-bh                           =  p-context-bh::tt-wd-bh
v-pos-type                           =  p-context-bh::pos-type
v-cash-num                           =  p-context-bh::cash-num
v-obj-type                           =  p-context-bh::obj-type
v-db-num                             =  p-context-bh::db-num
v-obj-code                           =  p-context-bh::obj-code
v-r-b                                =  p-context-bh::r-b
v-host-code                          =  p-context-bh::host-code
v-base-code                          =  p-context-bh::base-code
v-cre-pay                            =  p-context-bh::cre-pay
v-is-catering                        =  p-context-bh::is-catering
v-is-cdinv                           =  p-context-bh::is-cdinv
v-is-ptrl                            =  p-context-bh::is-ptrl
v-is-wth                             =  p-context-bh::is-wth
v-dc-mask                            =  p-context-bh::dc-mask
v-card-by-mask                       =  p-context-bh::card-by-mask
v-sclspref                           =  p-context-bh::sclspref
v-scpgpref                           =  p-context-bh::scpgpref
v-scpgpref-pre                       =  p-context-bh::scpgpref-pre
v-doc-prt                            =  p-context-bh::doc-prt
v-shift-on                           =  p-context-bh::shift-on
v-cas-shft                           =  p-context-bh::cas-shft
v-t-shft                             =  p-context-bh::t-shft
v-v-shft                             =  p-context-bh::v-shft
v-ptrl-check                         =  p-context-bh::ptrl-check
v-annu-check                         =  p-context-bh::annu-check
v-z-check                            =  p-context-bh::z-check
v-hnum                               =  p-context-bh::hnum
v-is-100-discnt                      =  p-context-bh::is-100-discnt
v-zero-cashier                       =  p-context-bh::zero-cashier
v-rnd-znak                           =  p-context-bh::rnd-znak
v-cas-curs                           =  p-context-bh::cas-curs
v-nam-2str                           =  p-context-bh::nam-2str
v-nam-artc                           =  p-context-bh::nam-artc
v-cod-pcod                           =  p-context-bh::cod-pcod
v-name-2cd                           =  p-context-bh::name-2cd
v-how-temp-disc                      =  p-context-bh::how-temp-disc
v-nalc                               =  p-context-bh::nalc
v-serial-code                        =  p-context-bh::serial-code
v-salesman-mandatory                 =  p-context-bh::salesman-mandatory
v-sales-man                          =  p-context-bh::sales-man
v-salesman-psn-code                  =  p-context-bh::salesman-psn-code
v-pos-type-for-discnt                =  p-context-bh::pos-type-for-discnt
v-manual-discnt                      =  p-context-bh::manual-discnt
v-is-grp-totals                      =  p-context-bh::is-grp-totals
v-is-gds-totals                      =  p-context-bh::is-gds-totals
v-chk-discnt-table                   =  p-context-bh::chk-discnt-table
v-chk-gds-table                      =  p-context-bh::chk-gds-table
v-chk-pay-table                      =  p-context-bh::chk-pay-table
v-z-number                           =  p-context-bh::z-number
v-shift-num                          =  p-context-bh::shift-num
v-shift-date                         =  p-context-bh::shift-date
v-shift-name                         =  p-context-bh::shift-name
v-emulator-mode                      =  p-context-bh::emulator-mode
v-ibmgroup                           =  p-context-bh::ibmgroup
.
  if v-p-log-file-name <> ""
  and v-p-log-file-name <> ? then do:
    log-file-name = v-p-log-file-name.
  end.
  else do:
    log-file-name = log-file-name0.
  end.
  if buf_chk-doc.chk-type = integer('43':U) or buf_chk-doc.chk-type = integer('44':U)
  then do :
    assign
      buf_chk-pay.tot-rubl = buf_chk-pay.tot-sum
      buf_chk-pay.exch-date = buf_chk-doc.chk-date
      buf_chk-pay.exch-time = buf_chk-doc.chk-time
      buf_chk-pay.exch-rate = 1
      buf_chk-pay.exch-scale = 1
      buf_chk-pay.calc-rate = 1
    .
    return .
  end .
  assign
  buf_chk-pay.is-error = ?
  v-pay_code = buf_chk-pay.pay-code
  v-curr_code = buf_chk-pay.curr-code
  .
  if buf_chk-doc.chk-type = integer('12':U) then do:
    if buf_chk-pay.pay-code <> 0 then do:
      if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                           "!!!Чек &1 - ошибочный&2" +                           "В чеке типа &3 не может быть строк оплат"                           , buf_chk-doc.doc-code                           , chr(10)                           , entry (lookup (string(buf_chk-doc.chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)                         ) ).
      assign
      buf_chk-pay.is-error = yes
      for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
      buf_chk-doc.correct = no
      v-view-log = yes
      .
    end.
    if buf_chk-pay.curr-code <> 0 then do:
      if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                           "!!!Чек &1 - ошибочный&2" +                           "Показания фискальных счетчиков в чеке типа &3&2должны быть в нац. валюте"                           , buf_chk-doc.doc-code                           ,chr(10)                           ,entry (lookup (string(buf_chk-doc.chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)                         ) ).
      assign
      buf_chk-pay.is-error = yes
      for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
      buf_chk-doc.correct = no
      v-view-log = yes
      .
    end.
  end.
  else do:
    FIND FIRST buf_cash-pay WHERE
              buf_cash-pay.cdpay-code = buf_chk-pay.pay-code AND
              buf_cash-pay.curr-code = buf_chk-pay.curr-code NO-LOCK NO-ERROR.
    if NOT available buf_cash-pay then do:
      if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                           "!!!Чек &1 - ошибочный&2" +                            "В базе отсутствует тип кассового платежа c кодом &3 и кодом валюты &4"                           , buf_chk-doc.doc-code                           , chr(10)                           , buf_chk-pay.pay-code                           , buf_chk-pay.curr-code                          ) ).
      assign
      buf_chk-pay.is-error = yes
      for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
      buf_chk-doc.correct = no
      v-view-log = yes
      .
    end.
    else do:
      if buf_cash-pay.cdpay-code = v-cre-pay and
          buf_chk-pay.pay-card <> "":U then do:
        if buf_chk-doc.d-card = "" then do:
          assign
          buf_chk-doc.d-card = buf_chk-pay.pay-card
          .
        end.
        else do:
          if buf_chk-doc.d-card <> buf_chk-pay.pay-card then do:
            if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                           "!!!Чек &1 - ошибочный&2" +                           "Номер дисконтной карты в шапке чека: &3 не равен номеру дисконтной карты &4: по платежу В КРЕДИТ"                           , buf_chk-doc.doc-code                           , chr(10)                           , buf_chk-doc.d-card                           , buf_chk-pay.pay-card                         ) ).
            assign
            buf_chk-pay.is-error = yes
            for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
            buf_chk-doc.correct = no
            v-view-log = yes
            .
          end.
        end.
      end.
      if buf_cash-pay.is-credit = yes
      and buf_cash-pay.cdpay-code <> v-cre-pay then do:
        if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                           ("!!!Чек &1 - ошибочный&2" +                           "Нельзя использовать тип кассового платежа c кодом &3 и кодом валюты &4&2" +                           "Данный тип кассового платежа определен как ПЛАТЕЖ В КРЕДИТ, &5")                           , buf_chk-doc.doc-code                           , chr(10)                           , buf_chk-pay.pay-code                           , buf_chk-pay.curr-code                            , (if v-cre-pay = 0                             then substitute("а такие платежи для фирмы &1 запрещены - настроечный параметр iscredit", v-host-code)                             else substitute("а  для фирмы &1 используется платеж &2 как платеж В КРЕДИТ - см настройки фирмы в АРМ Администратор", v-host-code, v-cre-pay)                             )                         ) ).
        assign
        buf_chk-pay.is-error = yes
        for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
        buf_chk-doc.correct = no
        v-view-log = yes
        .
      end.
      if buf_cash-pay.is-credit = yes
      and buf_chk-doc.d-card = "":U then do:
        if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                           ("!!!Чек &1 - ошибочный&2" +                           "Нельзя использовать тип кассового платежа c кодом &3 и кодом валюты &4&2" +                           "Данный тип кассового платежа определен как ПЛАТЕЖ В КРЕДИТ,&2 но в чеке не указана карта клиента")                           , buf_chk-doc.doc-code                           , chr(10)                           , buf_chk-pay.pay-code                           , buf_chk-pay.curr-code                         ) ).
        assign
        buf_chk-pay.is-error = yes
        for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
        buf_chk-doc.correct = no
        v-view-log = yes
        .
      end.
      if buf_cash-pay.register > 0
      and buf_chk-doc.d-card = '':U then do:
        if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                           ("!!!Чек &1 - ошибочный&2" +                           "Нельзя использовать тип кассового платежа c кодом &3 и кодом валюты &4&2" +                           "Данный тип кассового платежа определен как ВЕДОМОСТЬ,&2 но в чеке не указана карта клиента")                           , buf_chk-doc.doc-code                           , chr(10)                           , buf_chk-pay.pay-code                           , buf_chk-pay.curr-code                         ) ).
        assign
        buf_chk-pay.is-error = yes
        for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
        buf_chk-doc.correct = no
        v-view-log = yes
        .
      end.
      if available buf_wealth then release buf_wealth.
      if available buf_wth-par then release buf_wth-par.
      v-get-qnty-method = ''.
      if buf_cash-pay.wth-code > 0 then do:
        find first buf_wealth no-lock where
                  buf_wealth.wth-code = buf_cash-pay.wth-code no-error.
        if not available buf_wealth then do:
          if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                           ("!!!Чек &1 - ошибочный&2" +                           "Тип кассового платежа c кодом &3 и кодом валюты &4&2 ссылается на несуществующую МЦ с кодом &5")                            , buf_chk-doc.doc-code                           , chr(10)                           , buf_chk-pay.pay-code                           , buf_chk-pay.curr-code                           , buf_cash-pay.wth-code ) ).
          assign
          buf_chk-pay.is-error = yes
          for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
          buf_chk-doc.correct = no
          v-view-log = yes
          v-get-qnty-method = ''
          .
        end.
      end.
      if available buf_wealth then do:
        if buf_chk-pay.src-val <> 0 then do:
          find first buf_wth-par no-lock where
                    buf_wth-par.wth-code = buf_cash-pay.wth-code
                and ((buf_wth-par.par-val = integer(buf_chk-pay.src-val)
                     and buf_wth-par.par-rate > 1)
                or ( buf_wth-par.par-rate < 1
                    and buf_wth-par.par-val = integer(buf_chk-pay.src-val * 100)
                    )
                     )
                and (
                     buf_chk-pay.par-code = 0
                     or buf_wth-par.par-code  = buf_chk-pay.par-code)
                no-error.
          if not available buf_wth-par then do:
            if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                           ("!!!Чек &1 - ошибочный&2" +                           "Тип кассового платежа c кодом &3 и кодом валюты &4&2 ссылается&2на несуществующий номинал &5 для МЦ &6")                            , buf_chk-doc.doc-code                           , chr(10)                           , buf_chk-pay.pay-code                           , buf_chk-pay.curr-code                           , buf_chk-pay.src-val                           , buf_wealth.wth-name ) ).
            assign
            buf_chk-pay.is-error = yes
            for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
            buf_chk-doc.correct = no
            v-view-log = yes
            v-get-qnty-method = ''
            .
          end.
        end.
        assign
        v-get-qnty-method1 = (if buf_chk-pay.src-val <> 0
                             then '=val-qnty':U
                             else buf_wealth.get-qnty-method)
        v-get-qnty-method = v-get-qnty-method1
        .
        case v-get-qnty-method1:
          when '' then do:
            assign
            buf_chk-pay.wth-code = 0
            buf_chk-pay.doc-qnty = 0
            buf_chk-pay.par-val = 0
            .
          end.
          when '=sum':U then do:
            assign
            buf_chk-pay.doc-qnty = buf_chk-pay.tot-sum
            buf_chk-pay.par-val = 0
            buf_chk-pay.wth-code = (if available buf_wealth
                                   then buf_wealth.wth-code
                                   else 0)
            buf_chk-pay.par-code = (if available buf_wth-par
                                   then buf_wth-par.par-code
                                   else 0)
            .
          end.
          when '=1':U  then do:
            assign
            buf_chk-pay.doc-qnty = 1
            buf_chk-pay.par-val = 0
            buf_chk-pay.wth-code = (if available buf_wealth
                                   then buf_wealth.wth-code
                                   else 0)
            buf_chk-pay.par-code = (if available buf_wth-par
                                   then buf_wth-par.par-code
                                   else 0)
            .
          end.
          when '=val-qnty':U then do:
            define variable v-qnty as decimal no-undo .
            define variable v-val as integer   no-undo .
            if available buf_wth-par then do:
              assign
              v-qnty = buf_chk-pay.tot-sum / buf_chk-pay.src-val / (if buf_wth-par.par-rate < 1 then buf_wth-par.par-rate / buf_chk-pay.src-val else 1)
              v-val = buf_chk-pay.tot-sum / buf_chk-pay.src-qnty * (if buf_wth-par.par-rate < 1 then buf_wth-par.par-rate / buf_chk-pay.src-val else 1)
              buf_chk-pay.doc-qnty = (if v-qnty = buf_chk-pay.src-qnty
                                     then v-qnty
                                     else 0)
              buf_chk-pay.par-val = (if v-val = buf_chk-pay.src-val
                                     then v-val
                                     else 0)
              buf_chk-pay.par-code = (if buf_chk-pay.par-code = 0
                                      then buf_wth-par.par-code
                                      else buf_chk-pay.par-code)
              .
            end.
            else do:
              assign
              buf_chk-pay.doc-qnty = 0
              buf_chk-pay.par-val = 0
              buf_chk-pay.wth-code = 0
              .
              if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                           ("!!!Чек &1 - ошибочный&2" +                           "Для типа кассового платежа c кодом &3 и кодом валюты &4&2 должен быть задан номинал соответствущей МЦ &5")                            , buf_chk-doc.doc-code                           , chr(10)                           , buf_chk-pay.pay-code                           , buf_chk-pay.curr-code                           , buf_wealth.wth-name                         ) ).
              assign
              buf_chk-pay.is-error = yes
              for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
              buf_chk-doc.correct = no
              v-view-log = yes
              v-get-qnty-method =''
              .
            end.
          end.
        end case.
      end.
    end.
  end.
  CASE ABS(buf_chk-pay.curr-code):
    when 0 then do:
      assign
      buf_chk-pay.tot-rubl = buf_chk-pay.tot-sum
      buf_chk-pay.exch-date = buf_chk-doc.chk-date
      buf_chk-pay.exch-time = buf_chk-doc.chk-time
      buf_chk-pay.exch-rate = 1
      buf_chk-pay.exch-scale = 1
      buf_chk-pay.calc-rate = 1
      .
      if v-cas-curs and v-r-b = 'base':U then do:
        assign
        buf_chk-pay.tot-base = buf_chk-pay.tot-sum / buf_chk-pay.cash-rate .
      end.
      else do:
        if available buf_curr-shop then release buf_curr-shop.
        run libchkval_get-curr-shop in this-procedure (
                                                       input v-obj-type
                                                     , input v-obj-code
                                                      ,input v-base-code
                                                      ,input buf_chk-doc.chk-date
                                                      ,input buf_chk-doc.chk-time
                                                      ,buffer buf_curr-shop) no-error.
        if available buf_curr-shop
        then
        buf_chk-pay.tot-base = buf_chk-pay.tot-sum / buf_curr-shop.exch-rate * buf_curr-shop.exch-scale.
        else do:
          if NOT p-NoExchRate then do:
            if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                           "!!!Чек &1 - ошибочный. &2 Нет магазинного курса базовой валюты для &3&4 на дату &5"                           , buf_chk-doc.doc-code                           , chr(10)                           , buf_chk-doc.obj-type                           , buf_chk-doc.obj-code                           , buf_chk-doc.chk-date                          ) ).
            p-NoExchRate = TRUE .
          end.
          assign
          for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
          buf_chk-doc.correct = no
          buf_chk-pay.is-error = yes
          v-view-log = yes
          .
        end.
      end.
    end.
    when v-base-code then do:
      assign
      buf_chk-pay.tot-base = buf_chk-pay.tot-sum
      .
      if v-cas-curs then do:
        assign
        buf_chk-pay.tot-rubl = if v-r-b = 'base':U
                            then buf_chk-pay.tot-sum * buf_chk-doc.cash-rate
                            else buf_chk-pay.tot-sum / buf_chk-pay.cash-rate
        buf_chk-pay.calc-rate = buf_chk-pay.tot-rubl /  buf_chk-pay.tot-sum
        .
        if available buf_curr-shop then release buf_curr-shop.
        run libchkval_get-curr-shop in this-procedure (
                                                       input v-obj-type
                                                      ,input v-obj-code
                                                      ,input v-base-code
                                                      ,input buf_chk-doc.chk-date
                                                      ,input buf_chk-doc.chk-time
                                                      ,buffer buf_curr-shop) no-error.
        if available buf_curr-shop then do:
          assign
          buf_chk-pay.exch-date = buf_curr-shop.exch-date
          buf_chk-pay.exch-time = buf_curr-shop.exch-time
          buf_chk-pay.exch-rate = buf_curr-shop.exch-rate
          buf_chk-pay.exch-scale = buf_curr-shop.exch-scale
          .
        end.
        else do:
          if NOT p-NoExchRate then do:
            if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                           "!!!Чек &1 - ошибочный. &2 Нет магазинного курса базовой валюты для &3&4 на дату &5"                           , buf_chk-doc.doc-code                           , chr(10)                           , buf_chk-doc.obj-type                           , buf_chk-doc.obj-code                           , buf_chk-doc.chk-date                         ) ).
            p-NoExchRate = TRUE .
          end.
          assign
          for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
          buf_chk-doc.correct = no
          buf_chk-pay.is-error = yes
          v-view-log = yes
          .
        end.
      end.
      else do:
        if available buf_curr-shop then release buf_curr-shop.
        run libchkval_get-curr-shop in this-procedure (
                                                       input v-obj-type
                                                      ,input v-obj-code
                                                      ,input v-base-code
                                                      ,input buf_chk-doc.chk-date
                                                      ,input buf_chk-doc.chk-time
                                                      ,buffer buf_curr-shop) no-error.
        if available buf_curr-shop then do:
          assign
          buf_chk-pay.tot-rubl = buf_chk-pay.tot-sum * buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
          buf_chk-pay.exch-date = buf_curr-shop.exch-date
          buf_chk-pay.exch-time = buf_curr-shop.exch-time
          buf_chk-pay.exch-rate = buf_curr-shop.exch-rate
          buf_chk-pay.exch-scale = buf_curr-shop.exch-scale
          buf_chk-pay.calc-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
          .
        end.
        else do:
          if NOT p-NoExchRate then do:
            if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                         "!!!Чек &1 - ошибочный. &2 Нет магазинного курса базовой валюты для &3&4 на дату &5"                         , buf_chk-doc.doc-code                         , chr(10)                         , buf_chk-doc.obj-type                         , buf_chk-doc.obj-code                         , buf_chk-doc.chk-date                       ) ).
            p-NoExchRate = TRUE .
          end.
          assign
          for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
          buf_chk-doc.correct = no
          buf_chk-pay.is-error = yes
          v-view-log = yes
          .
        end.
      end.
    end.
    otherwise do:
      if v-cas-curs then do:
        assign
        buf_chk-pay.tot-base = if v-r-b = 'base':U
                            then buf_chk-pay.tot-sum / buf_chk-pay.cash-rate
                            else buf_chk-pay.tot-sum
        buf_chk-pay.tot-rubl = if v-r-b = 'base':U
                            then buf_chk-pay.tot-sum / buf_chk-pay.cash-rate * buf_chk-doc.cash-rate
                            else buf_chk-pay.tot-sum / buf_chk-pay.cash-rate
        buf_chk-pay.calc-rate = buf_chk-pay.tot-rubl /  buf_chk-pay.tot-sum
        .
        if not v-r-b = 'base':U then do:
          if available buf_curr-shop then release buf_curr-shop.
          run libchkval_get-curr-shop in this-procedure (
                                                         input v-obj-type
                                                        ,input v-obj-code
                                                        ,input v-base-code
                                                        ,input buf_chk-doc.chk-date
                                                        ,input buf_chk-doc.chk-time
                                                        ,buffer buf_curr-shop) no-error.
          if available buf_curr-shop then do:
            assign
            buf_chk-pay.tot-base = buf_chk-pay.tot-sum * buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
            .
          end.
          else do:
            if NOT p-NoExchRate then do:
              if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                           "!!!Чек &1 - ошибочный. &2 Нет магазинного курса валюты &3 для &4&5 на дату &6"                           , buf_chk-doc.doc-code                           , chr(10)                           , v-base-code                              , buf_chk-doc.obj-type                           , buf_chk-doc.obj-code                           , buf_chk-doc.chk-date                         ) ).
              p-NoExchRate = TRUE .
            end.
            assign
            for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
            buf_chk-doc.correct = no
            buf_chk-pay.is-error = yes
            v-view-log = yes
            .
          end.
          if available buf_curr-shop then release buf_curr-shop.
          run libchkval_get-curr-shop in this-procedure (
                                                         input v-obj-type
                                                        ,input v-obj-code
                                                        ,input buf_chk-pay.curr-code
                                                        ,input buf_chk-doc.chk-date
                                                        ,input buf_chk-doc.chk-time
                                                        ,buffer buf_curr-shop) no-error.
          if available buf_curr-shop then do:
            assign
            buf_chk-pay.exch-date = buf_curr-shop.exch-date
            buf_chk-pay.exch-time = buf_curr-shop.exch-time
            buf_chk-pay.exch-rate = buf_curr-shop.exch-rate
            buf_chk-pay.exch-scale = buf_curr-shop.exch-scale
            .
          end.
          else do:
            if NOT p-NoExchRate then do:
            if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                             "!!!Чек &1 - ошибочный. &2 Нет магазинного курса валюты &6 для &3&4 на дату &5"                             , buf_chk-doc.doc-code                             , chr(10)                             , buf_chk-doc.obj-type                             , buf_chk-doc.obj-code                             , buf_chk-doc.chk-date                             , buf_chk-pay.curr-code                           ) ).
            end.
            assign
            for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
            buf_chk-doc.correct = no
            buf_chk-pay.is-error = yes
            v-view-log = yes
            .
          end.
        end.
      end.
      else do:
        if available buf_curr-shop then release buf_curr-shop.
        run libchkval_get-curr-shop in this-procedure (
                                                       input v-obj-type
                                                      ,input v-obj-code
                                                      ,input buf_chk-pay.curr-code
                                                      ,input buf_chk-doc.chk-date
                                                      ,input buf_chk-doc.chk-time
                                                      ,buffer buf_curr-shop) no-error.
        if available buf_curr-shop then do:
          assign
          buf_chk-pay.tot-rubl = buf_chk-pay.tot-sum * buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
          curr-rate = buf_curr-shop.exch-rate
          curr-scale = buf_curr-shop.exch-scale
          buf_chk-pay.exch-date = buf_curr-shop.exch-date
          buf_chk-pay.exch-time = buf_curr-shop.exch-time
          buf_chk-pay.exch-rate = buf_curr-shop.exch-rate
          buf_chk-pay.exch-scale = buf_curr-shop.exch-scale
          buf_chk-pay.calc-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
          .
          FIND LAST buf_curr-shop WHERE
                    buf_curr-shop.obj-type = v-obj-type
                AND  buf_curr-shop.obj-code = v-obj-code
                AND  buf_curr-shop.curr-code = v-base-code
                AND ( ( buf_curr-shop.exch-date = buf_chk-doc.chk-date
                      AND
                      buf_curr-shop.exch-time <= buf_chk-doc.chk-time )
                    OR  buf_curr-shop.exch-date < buf_chk-doc.chk-date ) NO-ERROR .
          if available buf_curr-shop  then do:
            assign
            buf_chk-pay.tot-base = buf_chk-pay.tot-sum * (curr-rate / curr-scale)  /
                                buf_curr-shop.exch-rate * buf_curr-shop.exch-scale
            .
          end.
          else do:
            if NOT p-NoExchRate then do:
              if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                             "!!!Чек &1 - ошибочный. &2 Нет магазинного курса базовой валюты для &3&4 на дату &5"                             , buf_chk-doc.doc-code                             , chr(10)                             , buf_chk-doc.obj-type                             , buf_chk-doc.obj-code                             , buf_chk-doc.chk-date                           ) ).
            end.
            assign
            for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
            buf_chk-doc.correct = no
            buf_chk-pay.is-error = yes
            v-view-log = yes
            .
          end.
        end.
        else do:
          if NOT p-NoExchRate then do:
            if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                             "!!!Чек &1 - ошибочный. &2 Нет магазинного курса валюты &3 для &4&5 на дату &6"                             , buf_chk-doc.doc-code                             , chr(10)                             , buf_chk-pay.curr-code                             , buf_chk-doc.obj-type                             , buf_chk-doc.obj-code                             , buf_chk-doc.chk-date                           ) ).
            p-NoExchRate = TRUE .
          end.
          assign
          for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
          buf_chk-doc.correct = no
          buf_chk-pay.is-error = yes
          v-view-log = yes
          .
        end.
      end.
    end.
  END CASE.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  if crp > 0 then
  find first t-pay WHERE
              t-pay.pay-code = buf_chk-pay.pay-code
         and (t-pay.curr-code = (if buf_chk-pay.pay-code = 1
                                then -1
                                else buf_chk-pay.curr-code)
              or buf_chk-pay.pay-code <> 1)
        and t-pay.pay-card = (if buf_chk-pay.pay-card = "0"
                              then "":U
                              else buf_chk-pay.pay-card)
              NO-ERROR.
  if not avail t-pay
  or crp = 0
  then  do:
    FIND FIRST t-pay where t-pay.crf = crp + 1 use-index crfi No-ERROR.
    if not avail t-pay then
    create t-pay.
    assign
    t-pay.crf = crp + 1
    crp = crp + 1
    t-pay.pay-code = buf_chk-pay.pay-code
    t-pay.curr-code = (if buf_chk-pay.pay-code = 1
                       then -1
                       else buf_chk-pay.curr-code)
    t-pay.is-cash = (if (available buf_cash-pay)
                    then buf_cash-pay.is-cash
                    else no)
    t-pay.pay-card = (if (available buf_cash-pay)
                then (if buf_chk-pay.pay-card <> '':U
                     and buf_chk-pay.pay-card <> '0'
                     then buf_chk-pay.pay-card
                     else "")
                else "")
    t-pay.drc = recid(buf_chk-doc)
    t-pay.tot-rubl = 0
    t-pay.tot-base = 0
    t-pay.num-lines = 0
    t-pay.was-return = no
    t-pay.byval = ''
    .
  end.
  assign
  t-pay.tot-base = t-pay.tot-base + buf_chk-pay.tot-base
  t-pay.tot-rubl = t-pay.tot-rubl + buf_chk-pay.tot-rubl
  t-pay.num-lines = t-pay.num-lines + 1
  t-pay.was-return = if t-pay.was-return
                      then t-pay.was-return
                      else (buf_chk-pay.line-sign = no)
  t-pay.byval = (if t-pay.byval = ''
                then (if buf_chk-pay.src-val = 0
                      then 'nbyval'
                      else 'byval'
                      )
                else (if (t-pay.byval = 'byval'
                      and buf_chk-pay.src-val = 0)
                      or (t-pay.byval = 'nbyval'
                      and buf_chk-pay.src-val <> 0)
                      then 'error'
                      else t-pay.byval)
                )
  .
    if t-pay.byval  = 'error' then do:
        if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                               "!!!Чек &1 - ошибочный (Номер по кассе: &2 Касса: &3)&4" +                               "Для типа кассового платеже с кодом &1 и кодом валюты &2 СМЕШАНЫ строки с пустыми и непустыми номиналами"                               , buf_chk-doc.doc-code                               , buf_chk-doc.chk-num                                , buf_chk-doc.pay-desk                                , chr(10)                               , t-pay.pay-code                               , t-pay.curr-code                             ) ).
      assign
      for-chk-type = for-chk-type + 'сум-ош':U + chr(44)
      buf_chk-doc.correct = no
      v-view-log = yes
      .
    end.
    if buf_chk-pay.is-error = ? then
  buf_chk-pay.is-error = no.
end.
end procedure.
procedure libchkval_get-curr-shop :
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-curr-code as integer no-undo .
define input parameter p-date as date no-undo .
define input parameter p-time as integer no-undo .
define parameter buffer buf_curr-shop for ub.curr-shop.
find last  buf_curr-shop where
           buf_curr-shop.obj-type = p-obj-type
      AND  buf_curr-shop.obj-code = p-obj-code
      AND  buf_curr-shop.curr-code = p-curr-code
      AND ( ( buf_curr-shop.exch-date = p-date
            AND
            buf_curr-shop.exch-time <= p-time )
          OR  buf_curr-shop.exch-date < p-date ) NO-ERROR .
end procedure.
procedure libchkvl_getwcheck :
define input parameter p-context-bh as handle no-undo .
define input parameter p-wmode as character no-undo .
define input parameter p-edit-mode as character no-undo .
define input parameter p-close-check as logical no-undo .
define input parameter p-get-cash-shift as logical no-undo .
define input parameter p-netto as decimal no-undo .
define input-output parameter p-mc-prev-code like ub.chk-doc.doc-code no-undo .
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-parparentproc       as widget-handle           no-undo .
define variable v-p-log-handle        as handle                  no-undo .
define variable v-p-log-file-name     as character               no-undo .
define variable v-view-log            as logical                 no-undo .
define variable v-ll                  as integer                 no-undo .
define variable v-tt-wd-bh            as handle                  no-undo .
define variable v-pos-type            as character               no-undo .
define variable v-cash-num            as integer                 no-undo .
define variable v-obj-type            as character init 'маг':U  no-undo .
define variable v-obj-code            as integer                 no-undo .
define variable v-db-num              as integer                 no-undo .
define variable v-r-b                 as character               no-undo .
define variable v-host-code           as integer                 no-undo .
define variable v-base-code           as integer                 no-undo .
define variable v-cre-pay             as integer                 no-undo .
define variable v-is-catering         as logical                 no-undo .
define variable v-is-cdinv            as logical                 no-undo .
define variable v-is-ptrl             as logical                 no-undo .
define variable v-is-wth              as logical                 no-undo .
define variable v-process-sale        as logical                 no-undo .
define variable v-dc-mask             as logical                 no-undo .
define variable v-card-by-mask        as logical                 no-undo .
define variable v-sclspref            as character               no-undo .
define variable v-scpgpref            as character               no-undo .
define variable v-scpgpref-pre        as character               no-undo .
define variable v-doc-prt             as logical                 no-undo .
define variable v-shift-on            as logical                 no-undo .
define variable v-cas-shft            as logical                 no-undo .
define variable v-t-shft              as integer                 no-undo .
define variable v-v-shft              as integer                 no-undo .
define variable v-ptrl-check          as logical                 no-undo .
define variable v-annu-check          as logical                 no-undo .
define variable v-z-check             as logical                 no-undo .
define variable v-hnum                as logical                 no-undo .
define variable v-is-100-discnt       as logical                 no-undo .
define variable v-zero-cashier        as integer                 no-undo .
define variable v-rnd-znak            as integer                 no-undo .
define variable v-cas-curs            as logical                 no-undo .
define variable v-nam-2str            as logical                 no-undo .
define variable v-nam-artc            as logical                 no-undo .
define variable v-cod-pcod            as logical                 no-undo .
define variable v-name-2cd            as character               no-undo .
define variable v-how-temp-disc       as character               no-undo .
define variable v-nalc                as integer                 no-undo .
define variable v-rmethod-type        as character               no-undo .
define variable v-rmethod-coeff       as decimal                 no-undo .
define variable v-serial-code         as character               no-undo .
define variable v-salesman-mandatory  as integer                 no-undo .
define variable v-sales-man           as integer                 no-undo .
define variable v-salesman-psn-code   as integer                 no-undo .
define variable v-pos-type-for-discnt as character               no-undo .
define variable v-manual-discnt       as integer                 no-undo .
define variable v-is-grp-totals       as logical                 no-undo .
define variable v-is-gds-totals       as logical                 no-undo .
define variable v-cash-counter        as decimal                 no-undo .
define variable v-pre-cash-counter    as decimal                 no-undo .
define variable v-qnty-change         as logical                 no-undo .
define variable v-log-level           as integer                 no-undo .
define variable v-chk-discnt-table    as handle                  no-undo .
define variable v-chk-gds-table       as handle                  no-undo .
define variable v-chk-pay-table       as handle                  no-undo .
define variable v-z-number            as integer                 no-undo .
define variable v-shift-num           as integer                 no-undo .
define variable v-shift-date          as date                    no-undo .
define variable v-shift-name          as character               no-undo .
define variable v-emulator-mode       as integer                 no-undo .
define variable v-ibmgroup            as logical                 no-undo .
define variable v-cashier-psn-code like ub.person.psn-code no-undo .
DEFINE VARIABLE for-chk-type               as   character             no-undo init "".
DEFINE VARIABLE shift-name_                like ub.chk-doc.shift-name  no-undo .
define variable par-val_ as integer no-undo .
define variable accum-pay as decimal no-undo .
define variable accum-pay-inst as decimal no-undo .
define variable v-pay-code as integer no-undo .
define variable v-wth-code as integer no-undo .
define variable v-is-error as logical no-undo .
define variable v-line-num as integer no-undo .
define variable v-inst-sum as decimal no-undo .
define variable v-curr-code as integer no-undo .
DEFINE VARIABLE curr-rate                    like ub.curr-shop.exch-rate   no-undo .
DEFINE VARIABLE curr-scale                   like ub.curr-shop.exch-scale  no-undo .
define variable v-get-qnty-method as character no-undo .
define variable v-get-qnty-method1           as character   no-undo .
define variable v-pos-type-int               as integer                 no-undo .
define buffer buf_cash-desk for ub.cash-desk.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_shift-cash for ub.shift-cash.
define buffer buf_wealth for ub.wealth.
define buffer buf_wth-par for ub.wth-par.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_curr-shop for ub.curr-shop.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if p-mc-prev-code = "":U then return.
  FIND buf_chk-doc share-lock WHERE
        buf_chk-doc.doc-code = p-mc-prev-code NO-ERROR.
  if not avail buf_chk-doc then do:
    return.
  end.
  for each t-wth:
    delete t-wth.
  end.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
v-parparentproc                      =  p-context-bh::parparentproc
v-p-log-handle                       =  p-context-bh::p-log-handle
v-p-log-file-name                    =  p-context-bh::p-log-file-name
v-view-log                           =  p-context-bh::view-log
v-ll                                 =  p-context-bh::ll
v-tt-wd-bh                           =  p-context-bh::tt-wd-bh
v-pos-type                           =  p-context-bh::pos-type
v-cash-num                           =  p-context-bh::cash-num
v-obj-type                           =  p-context-bh::obj-type
v-db-num                             =  p-context-bh::db-num
v-obj-code                           =  p-context-bh::obj-code
v-r-b                                =  p-context-bh::r-b
v-host-code                          =  p-context-bh::host-code
v-base-code                          =  p-context-bh::base-code
v-cre-pay                            =  p-context-bh::cre-pay
v-is-catering                        =  p-context-bh::is-catering
v-is-cdinv                           =  p-context-bh::is-cdinv
v-is-ptrl                            =  p-context-bh::is-ptrl
v-is-wth                             =  p-context-bh::is-wth
v-dc-mask                            =  p-context-bh::dc-mask
v-card-by-mask                       =  p-context-bh::card-by-mask
v-sclspref                           =  p-context-bh::sclspref
v-scpgpref                           =  p-context-bh::scpgpref
v-scpgpref-pre                       =  p-context-bh::scpgpref-pre
v-doc-prt                            =  p-context-bh::doc-prt
v-shift-on                           =  p-context-bh::shift-on
v-cas-shft                           =  p-context-bh::cas-shft
v-t-shft                             =  p-context-bh::t-shft
v-v-shft                             =  p-context-bh::v-shft
v-ptrl-check                         =  p-context-bh::ptrl-check
v-annu-check                         =  p-context-bh::annu-check
v-z-check                            =  p-context-bh::z-check
v-hnum                               =  p-context-bh::hnum
v-is-100-discnt                      =  p-context-bh::is-100-discnt
v-zero-cashier                       =  p-context-bh::zero-cashier
v-rnd-znak                           =  p-context-bh::rnd-znak
v-cas-curs                           =  p-context-bh::cas-curs
v-nam-2str                           =  p-context-bh::nam-2str
v-nam-artc                           =  p-context-bh::nam-artc
v-cod-pcod                           =  p-context-bh::cod-pcod
v-name-2cd                           =  p-context-bh::name-2cd
v-how-temp-disc                      =  p-context-bh::how-temp-disc
v-nalc                               =  p-context-bh::nalc
v-serial-code                        =  p-context-bh::serial-code
v-salesman-mandatory                 =  p-context-bh::salesman-mandatory
v-sales-man                          =  p-context-bh::sales-man
v-salesman-psn-code                  =  p-context-bh::salesman-psn-code
v-pos-type-for-discnt                =  p-context-bh::pos-type-for-discnt
v-manual-discnt                      =  p-context-bh::manual-discnt
v-is-grp-totals                      =  p-context-bh::is-grp-totals
v-is-gds-totals                      =  p-context-bh::is-gds-totals
v-chk-discnt-table                   =  p-context-bh::chk-discnt-table
v-chk-gds-table                      =  p-context-bh::chk-gds-table
v-chk-pay-table                      =  p-context-bh::chk-pay-table
v-z-number                           =  p-context-bh::z-number
v-shift-num                          =  p-context-bh::shift-num
v-shift-date                         =  p-context-bh::shift-date
v-shift-name                         =  p-context-bh::shift-name
v-emulator-mode                      =  p-context-bh::emulator-mode
v-ibmgroup                           =  p-context-bh::ibmgroup
.
  if v-p-log-file-name <> ""
  and v-p-log-file-name <> ? then do:
    log-file-name = v-p-log-file-name.
  end.
  else do:
    log-file-name = log-file-name0.
  end.
    v-pos-type-int = integer(entry(lookup(v-pos-type, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,r-keeper,Emulator-NKT-IBM,MARIA,IBS-TH,IBS-TH-MOB':U), '2,13,1,3,4,5,6,7,8,9,11,12,14,15':U)).
  if buf_chk-doc.pay-desk <> 0 then do:
    find first buf_cash-desk no-lock where
              buf_cash-desk.cash-num = buf_chk-doc.pay-desk
        AND buf_cash-desk.obj-code = buf_chk-doc.obj-code
        AND buf_cash-desk.pos-type = v-pos-type no-error .
  end.
  if buf_chk-doc.pay-desk = 0
  or not available buf_cash-desk
  or buf_cash-desk.is-del then do:
    if can-find(first ub.cash-desk where
                        ub.cash-desk.cash-num = 0
                    and ub.cash-desk.obj-code = buf_chk-doc.obj-code
                    and ub.cash-desk.pos-type = 'Autotank':U
                    )
          and can-find(first ub.cash-desk where
                        ub.cash-desk.cash-num = buf_chk-doc.pay-desk
                    and ub.cash-desk.obj-code = buf_chk-doc.obj-code
                    and ub.cash-desk.pos-type = 'Autotank':U
                    and buf_chk-doc.pay-desk > 0 )
    then do:
      v-pos-type-int = integer('13':U).
    end.
    else do:
      find first buf_cash-desk no-lock where
              buf_cash-desk.cash-num = buf_chk-doc.pay-desk
          AND buf_cash-desk.obj-code = buf_chk-doc.obj-code no-error.
      if available buf_cash-desk then do:
                v-pos-type-int = integer(entry(lookup(buf_cash-desk.pos-type, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,r-keeper,Emulator-NKT-IBM,MARIA,IBS-TH,IBS-TH-MOB':U), '2,13,1,3,4,5,6,7,8,9,11,12,14,15':U)).
      end.
      else do:
        v-pos-type-int = integer('0':U).
      end.
      assign
      for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
      v-view-log = yes
      buf_chk-doc.correct = no
      .
      if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                             "!!!Чек &1 - ошибочный. &2 Нет сведений о кассе &3 с типом &4"                             , buf_chk-doc.doc-code                             , chr(10)                             , buf_chk-doc.pay-desk                             , v-pos-type) ).
    end.
  end.
  if p-edit-mode <> "shift-change" then do:
    assign
    buf_chk-doc.shift-date = if v-t-shft < 0
                               AND buf_chk-doc.chk-time < abs(v-t-shft)
                               then (buf_chk-doc.chk-date - 1)
                               else (if buf_chk-doc.src-shift-date = ?
                                    then buf_chk-doc.chk-date
                                    else (if p-wmode = 'ИЗМЕНЕНИЕ':U
                                          then
                                                (if index(buf_chk-doc.ps, "shift!") = 0
                                                then buf_chk-doc.src-shift-date
                                                else buf_chk-doc.shift-date)
                                          else  buf_chk-doc.src-shift-date)
                                     )
    .
  end.
  if v-cas-shft then do:
    if buf_chk-doc.shift-name = '':U
    or trim(buf_chk-doc.shift-name, '0') = '':U
      then  do:
      assign
      for-chk-type = for-chk-type + 'смн-ош':U + chr(44)
      buf_chk-doc.shift-date = 01/01/1990
      buf_chk-doc.correct = no
      .
    end.
    else do:
      if v-v-shft > 0 then do:
        run str/v-shftg.p (
                            buffer buf_chk-doc
                          ,input v-parparentproc
                          ,input v-p-log-handle
                          ,input p-wmode
                          ,input v-obj-type
                          ,input v-obj-code
                          ,input v-v-shft
                          ,input v-t-shft
                          ,input 'смн-ош':U
                          ,input-output for-chk-type
                          ,input-output v-view-log
                            ).
      end.
      if v-shift-on then do:
        if (p-wmode = 'ИЗМЕНЕНИЕ':U and  index(buf_chk-doc.ps, "shift!") = 0)
        or (p-wmode <> 'ИЗМЕНЕНИЕ':U)  then do:
          run libchkvl_get-shift-num in this-procedure (
                                               input buf_chk-doc.obj-type
                                              ,input buf_chk-doc.obj-code
                                              ,input buf_chk-doc.shift-date
                                              ,input buf_chk-doc.shift-name
                                              ,output buf_chk-doc.shift-num) no-error .
          if error-status:error
          or buf_chk-doc.shift-num = ?
          or buf_chk-doc.shift-num = 0 then do:
          assign
          for-chk-type = for-chk-type + 'смн-ош':U + chr(44)
          buf_chk-doc.shift-num = 0
          buf_chk-doc.correct = no
          .
          end.
        end.
      end.
      if (p-wmode = 'ИЗМЕНЕНИЕ':U and index(buf_chk-doc.ps, "shift!") = 0)
      or p-wmode <> 'ИЗМЕНЕНИЕ':U
      then do:
        assign
        shift-name_ = (if p-wmode = 'ИЗМЕНЕНИЕ':U
                      then  (if p-edit-mode = 'ДОБАВЛЕНИЕ':U
                              then buf_chk-doc.shift-name
                              else buf_chk-doc.src-shift-name)
                      else buf_chk-doc.src-shift-name
                      )
        .
        if v-cas-shft then do:
          if p-get-cash-shift then do:
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_get-cash-shift in g#libchkvl
  (input  p-context-bh:handle
  ,buffer buf_shift-cash
  ,input  buf_chk-doc.pay-desk
  ,input  buf_chk-doc.src-shift-date
  ,input  shift-name_
  ,input ?
  ,input buf_chk-doc.chk-date
  ,input buf_chk-doc.chk-time
  ,input 0
    ) no-error .
          end.
        end.
      end.
    end.
  end.
  assign
  v-cashier-psn-code = gbclcode-is-this-db-role ( input 'C':U, input v-db-num, input buf_chk-doc.cashier, input buf_chk-doc.chk-date)
  no-error
  .
  if v-cashier-psn-code = 0 then do:
    assign
    for-chk-type = for-chk-type + 'перс-ош':U + chr(44)
    buf_chk-doc.correct = no
    v-view-log = yes
    .
    if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                             "!!!Чек МЦ &1 - ошибочный. &2 Нет сведений о кассире &3"                             , buf_chk-doc.doc-code                             , chr(10)                             , buf_chk-doc.cashier                           ) ).
  end.
  else do:
    assign
    buf_chk-doc.cashier-psn-code = v-cashier-psn-code
    .
  end.
  for each buf_chk-pay where
            buf_chk-pay.doc-code = buf_chk-doc.doc-code:
    assign
    buf_chk-pay.is-error = no
    accum-pay = accum-pay +  buf_chk-pay.tot-sum / buf_chk-pay.cash-rate
    .
    if available buf_wealth then release buf_wealth.
    if available buf_wth-par then release buf_wth-par.
    FIND FIRST buf_cash-pay WHERE
              buf_cash-pay.cdpay-code = buf_chk-pay.pay-code AND
              buf_cash-pay.curr-code = buf_chk-pay.curr-code NO-LOCK NO-ERROR.
    if NOT available buf_cash-pay
    or buf_cash-pay.wth-code = 0
    then do:
      if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                               "!!!Чек МЦ &1 - ошибочный&2" +                               (if not available buf_cash-pay                                 then "В базе отсутствует тип кассового платежа c кодом &3 и кодом валюты &4"                               else "Типу кассового платежа с кодом &3 и кодом валюты &4 не соответствует МЦ")                               , buf_chk-doc.doc-code                               , chr(10)                               , buf_chk-pay.pay-code                               , buf_chk-pay.curr-code                             ) ).
      assign
      for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
      buf_chk-doc.correct = no
      v-view-log = yes
      .
    end.
    else do:
      assign
      buf_chk-pay.wth-code = buf_cash-pay.wth-code
      .
      v-get-qnty-method = ''.
      find first buf_wealth no-lock where
                buf_wealth.wth-code = buf_cash-pay.wth-code no-error.
      if not available buf_wealth then do:
        if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                         ("!!!Чек &1 - ошибочный&2" +                         "Тип кассового платежа c кодом &3 и кодом валюты &4&2 ссылается на несуществующую МЦ с кодом &5")                          , buf_chk-doc.doc-code                         , chr(10)                         , buf_chk-pay.pay-code                         , buf_chk-pay.curr-code                         , buf_cash-pay.wth-code ) ).
        assign
        buf_chk-pay.is-error = yes
        for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
        buf_chk-doc.correct = no
        v-view-log = yes
        v-get-qnty-method = ''
        .
      end.
      if available buf_wealth then do:
        if buf_chk-pay.src-val <> 0 then do:
          find first buf_wth-par no-lock where
                    buf_wth-par.wth-code = buf_cash-pay.wth-code
                and ((buf_wth-par.par-rate >= 1 and buf_wth-par.par-val = integer(buf_chk-pay.src-val))
                     or
                     (buf_wth-par.par-rate < 1 and buf_wth-par.par-val = integer(buf_chk-pay.src-val) * 100))
                and (buf_chk-pay.par-code = 0
                     or
                     buf_wth-par.par-code  = buf_chk-pay.par-code)
                no-error.
          if not available buf_wth-par then do:
            if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                           ("!!!Чек &1 - ошибочный&2" +                           "Тип кассового платежа c кодом &3 и кодом валюты &4&2 ссылается&2на несуществующий номинал &5 для МЦ &6")                            , buf_chk-doc.doc-code                           , chr(10)                           , buf_chk-pay.pay-code                           , buf_chk-pay.curr-code                           , buf_chk-pay.src-val                           , buf_wealth.wth-name ) ).
            assign
            buf_chk-pay.is-error = yes
            for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
            buf_chk-doc.correct = no
            v-view-log = yes
            v-get-qnty-method = ''
            .
          end.
        end.
        assign
        v-get-qnty-method1 = (if buf_chk-pay.src-val <> 0
                              then '=val-qnty':U
                              else buf_wealth.get-qnty-method)
        v-get-qnty-method = v-get-qnty-method1
        .
        case v-get-qnty-method1:
          when '' then do:
            assign
            buf_chk-pay.wth-code = 0
            buf_chk-pay.doc-qnty = 0
            buf_chk-pay.par-val = 0
            .
          end.
          when '=sum':U then do:
            assign
            buf_chk-pay.doc-qnty = buf_chk-pay.tot-sum
            buf_chk-pay.par-val = 0
            buf_chk-pay.wth-code = (if available buf_wealth
                                   then buf_wealth.wth-code
                                   else 0)
            buf_chk-pay.par-code = (if available buf_wth-par
                                   then buf_wth-par.par-code
                                   else 0)
            .
          end.
          when '=1':U  then do:
            assign
            buf_chk-pay.doc-qnty = 1
            buf_chk-pay.par-val = 0
            buf_chk-pay.wth-code = (if available buf_wealth
                                   then buf_wealth.wth-code
                                   else 0)
            buf_chk-pay.par-code = (if available buf_wth-par
                                   then buf_wth-par.par-code
                                   else 0)
            .
          end.
          when '=val-qnty':U then do:
            define variable v-qnty as decimal no-undo .
            define variable v-val as integer   no-undo .
            if available buf_wth-par then do:
              assign
              v-qnty = buf_chk-pay.tot-sum / buf_chk-pay.src-val / (if buf_wth-par.par-rate < 1 then buf_wth-par.par-rate / buf_chk-pay.src-val else 1)
              v-val = buf_chk-pay.tot-sum / buf_chk-pay.src-qnty * (if buf_wth-par.par-rate < 1 then buf_wth-par.par-rate / buf_chk-pay.src-val else 1)
              buf_chk-pay.doc-qnty = (if v-qnty = buf_chk-pay.src-qnty
                                     then v-qnty
                                     else 0)
              buf_chk-pay.par-val = (if v-val = buf_chk-pay.src-val
                                     then v-val
                                     else 0)
              buf_chk-pay.par-code = (if buf_chk-pay.par-code = 0
                                      then buf_wth-par.par-code
                                      else buf_chk-pay.par-code)
              .
            end.
            else do:
              assign
              buf_chk-pay.doc-qnty = 0
              buf_chk-pay.par-val = 0
              buf_chk-pay.wth-code = 0
              .
              if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                           ("!!!Чек &1 - ошибочный&2" +                           "Для типа кассового платежа c кодом &3 и кодом валюты &4&2 должен быть задан номинал соответствущей МЦ &5")                            , buf_chk-doc.doc-code                           , chr(10)                           , buf_chk-pay.pay-code                           , buf_chk-pay.curr-code                           , buf_wealth.wth-name                         ) ).
              assign
              buf_chk-pay.is-error = yes
              for-chk-type = for-chk-type + 'опл-ош':U + chr(44)
              buf_chk-doc.correct = no
              v-view-log = yes
              v-get-qnty-method =''
              .
            end.
          end.
        end case.
      end.
      CASE ABS(buf_chk-pay.curr-code):
        when 0 then do:
          assign
          buf_chk-pay.tot-rubl = buf_chk-pay.tot-sum
          buf_chk-pay.exch-date = buf_chk-doc.chk-date
          buf_chk-pay.exch-time = buf_chk-doc.chk-time
          buf_chk-pay.exch-rate = 1
          buf_chk-pay.exch-scale = 1
          buf_chk-pay.calc-rate = 1
          .
          if v-cas-curs and v-r-b = 'base':U then do:
            assign
            buf_chk-pay.tot-base = buf_chk-pay.tot-sum / buf_chk-pay.cash-rate .
          end.
          else do:
            if available buf_curr-shop then release buf_curr-shop.
            run libchkval_get-curr-shop in this-procedure (
                                                          input buf_chk-doc.obj-type
                                                        , input buf_chk-doc.obj-code
                                                          ,input v-base-code
                                                          ,input buf_chk-doc.chk-date
                                                          ,input buf_chk-doc.chk-time
                                                          ,buffer buf_curr-shop) no-error.
            if available buf_curr-shop
            then
            buf_chk-pay.tot-base = buf_chk-pay.tot-sum / buf_curr-shop.exch-rate * buf_curr-shop.exch-scale.
            else do:
                               if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                               "!!!Чек &1 - ошибочный. &2 Нет магазинного курса базовой валюты для &3&4 на дату &5"                               , buf_chk-doc.doc-code                               , chr(10)                               , buf_chk-doc.obj-type                               , buf_chk-doc.obj-code                               , buf_chk-doc.chk-date                              ) ).
            end.
          end.
        end.
        when v-base-code then do:
          assign
          buf_chk-pay.tot-base = buf_chk-pay.tot-sum
          .
          if v-cas-curs then do:
            assign
            buf_chk-pay.tot-rubl = if v-r-b = 'base':U
                                then buf_chk-pay.tot-sum * buf_chk-doc.cash-rate
                                else buf_chk-pay.tot-sum / buf_chk-pay.cash-rate
            buf_chk-pay.calc-rate = buf_chk-pay.tot-rubl /  buf_chk-pay.tot-sum
            .
            if available buf_curr-shop then release buf_curr-shop.
            run libchkval_get-curr-shop in this-procedure (
                                                          input buf_chk-doc.obj-type
                                                          ,input buf_chk-doc.obj-code
                                                          ,input v-base-code
                                                          ,input buf_chk-doc.chk-date
                                                          ,input buf_chk-doc.chk-time
                                                          ,buffer buf_curr-shop) no-error.
            if available buf_curr-shop then do:
              assign
              buf_chk-pay.exch-date = buf_curr-shop.exch-date
              buf_chk-pay.exch-time = buf_curr-shop.exch-time
              buf_chk-pay.exch-rate = buf_curr-shop.exch-rate
              buf_chk-pay.exch-scale = buf_curr-shop.exch-scale
              .
            end.
            else do:
                    if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                               "!!!Чек &1 - ошибочный. &2 Нет магазинного курса базовой валюты для &3&4 на дату &5"                               , buf_chk-doc.doc-code                               , chr(10)                               , buf_chk-doc.obj-type                               , buf_chk-doc.obj-code                               , buf_chk-doc.chk-date                             ) ).
            end.
          end.
          else do:
            if available buf_curr-shop then release buf_curr-shop.
            run libchkval_get-curr-shop in this-procedure (
                                                          input buf_chk-doc.obj-type
                                                          ,input buf_chk-doc.obj-code
                                                          ,input v-base-code
                                                          ,input buf_chk-doc.chk-date
                                                          ,input buf_chk-doc.chk-time
                                                          ,buffer buf_curr-shop) no-error.
            if available buf_curr-shop then do:
              assign
              buf_chk-pay.tot-rubl = buf_chk-pay.tot-sum * buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
              buf_chk-pay.exch-date = buf_curr-shop.exch-date
              buf_chk-pay.exch-time = buf_curr-shop.exch-time
              buf_chk-pay.exch-rate = buf_curr-shop.exch-rate
              buf_chk-pay.exch-scale = buf_curr-shop.exch-scale
              buf_chk-pay.calc-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
              .
            end.
            else do:
                    if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                             "!!!Чек &1 - ошибочный. &2 Нет магазинного курса базовой валюты для &3&4 на дату &5"                             , buf_chk-doc.doc-code                             , chr(10)                             , buf_chk-doc.obj-type                             , buf_chk-doc.obj-code                             , buf_chk-doc.chk-date                           ) ).
            end.
          end.
        end.
        otherwise do:
          if v-cas-curs then do:
            assign
            buf_chk-pay.tot-base = if v-r-b = 'base':U
                                then buf_chk-pay.tot-sum / buf_chk-pay.cash-rate
                                else buf_chk-pay.tot-sum
            buf_chk-pay.tot-rubl = if v-r-b = 'base':U
                                then buf_chk-pay.tot-sum / buf_chk-pay.cash-rate * buf_chk-doc.cash-rate
                                else buf_chk-pay.tot-sum / buf_chk-pay.cash-rate
            buf_chk-pay.calc-rate = buf_chk-pay.tot-rubl /  buf_chk-pay.tot-sum
            .
            if not v-r-b = 'base':U then do:
              if available buf_curr-shop then release buf_curr-shop.
              run libchkval_get-curr-shop in this-procedure (
                                                            input buf_chk-doc.obj-type
                                                            ,input buf_chk-doc.obj-code
                                                            ,input v-base-code
                                                            ,input buf_chk-doc.chk-date
                                                            ,input buf_chk-doc.chk-time
                                                            ,buffer buf_curr-shop) no-error.
              if available buf_curr-shop then do:
                assign
                buf_chk-pay.tot-base = buf_chk-pay.tot-sum * buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
                .
              end.
              else do:
                      if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                               "!!!Чек &1 - ошибочный. &2 Нет магазинного курса валюты &3 для &4&5 на дату &6"                               , buf_chk-doc.doc-code                               , chr(10)                               , V-base-code                                  , buf_chk-doc.obj-type                               , buf_chk-doc.obj-code                               , buf_chk-doc.chk-date                             ) ).
              end.
              if available buf_curr-shop then release buf_curr-shop.
              run libchkval_get-curr-shop in this-procedure (
                                                            input buf_chk-doc.obj-type
                                                            ,input buf_chk-doc.obj-code
                                                            ,input buf_chk-pay.curr-code
                                                            ,input buf_chk-doc.chk-date
                                                            ,input buf_chk-doc.chk-time
                                                            ,buffer buf_curr-shop) no-error.
              if available buf_curr-shop then do:
                assign
                buf_chk-pay.exch-date = buf_curr-shop.exch-date
                buf_chk-pay.exch-time = buf_curr-shop.exch-time
                buf_chk-pay.exch-rate = buf_curr-shop.exch-rate
                buf_chk-pay.exch-scale = buf_curr-shop.exch-scale
                .
              end.
              else do:
                    if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                                 "!!!Чек &1 - ошибочный. &2 Нет магазинного курса валюты &6 для &3&4 на дату &5"                                 , buf_chk-doc.doc-code                                 , chr(10)                                 , buf_chk-doc.obj-type                                 , buf_chk-doc.obj-code                                 , buf_chk-doc.chk-date                                 , buf_chk-pay.curr-code                               ) ).
              end.
            end.
          end.
          else do:
            if available buf_curr-shop then release buf_curr-shop.
            run libchkval_get-curr-shop in this-procedure (
                                                          input buf_chk-doc.obj-type
                                                          ,input buf_chk-doc.obj-code
                                                          ,input buf_chk-pay.curr-code
                                                          ,input buf_chk-doc.chk-date
                                                          ,input buf_chk-doc.chk-time
                                                          ,buffer buf_curr-shop) no-error.
            if available buf_curr-shop then do:
              assign
              buf_chk-pay.tot-rubl = buf_chk-pay.tot-sum * buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
              curr-rate = buf_curr-shop.exch-rate
              curr-scale = buf_curr-shop.exch-scale
              buf_chk-pay.exch-date = buf_curr-shop.exch-date
              buf_chk-pay.exch-time = buf_curr-shop.exch-time
              buf_chk-pay.exch-rate = buf_curr-shop.exch-rate
              buf_chk-pay.exch-scale = buf_curr-shop.exch-scale
              buf_chk-pay.calc-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
              .
              FIND LAST buf_curr-shop WHERE
                        buf_curr-shop.obj-type = buf_chk-doc.obj-type
                    AND  buf_curr-shop.obj-code = buf_chk-doc.obj-code
                    AND  buf_curr-shop.curr-code = v-base-code
                    AND ( ( buf_curr-shop.exch-date = buf_chk-doc.chk-date
                          AND
                          buf_curr-shop.exch-time <= buf_chk-doc.chk-time )
                        OR  buf_curr-shop.exch-date < buf_chk-doc.chk-date ) NO-ERROR .
              if available buf_curr-shop  then do:
                assign
                buf_chk-pay.tot-base = buf_chk-pay.tot-sum * (curr-rate / curr-scale)  /
                                    buf_curr-shop.exch-rate * buf_curr-shop.exch-scale
                .
              end.
              else do:
                      if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                                 "!!!Чек &1 - ошибочный. &2 Нет магазинного курса базовой валюты для &3&4 на дату &5"                                 , buf_chk-doc.doc-code                                 , chr(10)                                 , buf_chk-doc.obj-type                                 , buf_chk-doc.obj-code                                 , buf_chk-doc.chk-date                               ) ).
              end.
            end.
            else do:
                    if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                                 "!!!Чек &1 - ошибочный. &2 Нет магазинного курса валюты &3 для &4&5 на дату &6"                                 , buf_chk-doc.doc-code                                 , chr(10)                                 , buf_chk-pay.curr-code                                 , buf_chk-doc.obj-type                                 , buf_chk-doc.obj-code                                 , buf_chk-doc.chk-date                               ) ).
            end.
          end.
        end.
      END CASE.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if crwth > 0 then
find first t-wth WHERE
            t-wth.pay-code = buf_chk-pay.pay-code and
            t-wth.curr-code = buf_chk-pay.curr-code and
            t-wth.drc = recid(buf_chk-doc)
            NO-ERROR.
if not avail t-wth or crwth = 0 then  do:
  FIND FIRST t-wth where t-wth.crf = crwth + 1 use-index crfi No-ERROR.
  if not avail t-wth then
  create t-wth.
  assign
  t-wth.crf = crwth + 1
  crwth = crwth + 1
  t-wth.pay-code = buf_chk-pay.pay-code
  t-wth.curr-code = buf_chk-pay.curr-code
  t-wth.drc = recid(buf_chk-doc)
  t-wth.tot-sum = 0
  t-wth.num-lines = 0
  t-wth.byval = ''
  .
end.
assign
t-wth.tot-sum = t-wth.tot-sum + buf_chk-pay.tot-sum
t-wth.num-lines = t-wth.num-lines + 1
t-wth.sum-r-b = t-wth.sum-r-b + buf_chk-pay.tot-sum / buf_chk-pay.cash-rate
t-wth.byval = (if t-wth.byval = ''
               then (if buf_chk-pay.src-val = 0
                     then 'nbyval'
                     else 'byval'
                     )
               else (if (t-wth.byval = 'byval'
                     and buf_chk-pay.src-val = 0)
                     or (t-wth.byval = 'nbyval'
                     and buf_chk-pay.src-val <> 0)
                     then 'error'
                     else t-wth.byval)
               )
.
    end.
  end.
  if p-netto <> ? then do:
    if  ((p-netto = 0 and accum-pay <> 0)
    or (p-netto <> 0 and  ABS(ABS(p-netto - ACCUM-pay) / p-netto ) > 0.01))
    then do:
        if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                               "!!!Чек &1 - ошибочный (Номер по кассе: &2 Касса: &3)&4" +                               "Сумма транзакции не совпадает с суммой оплат по чеку&4" +                               "Сумма транзакции = &5, сумма оплат по чеку = &6&4" +                                "Обратитесь к администратору Вашей системы"                               , buf_chk-doc.doc-code                               , buf_chk-doc.chk-num                                , buf_chk-doc.pay-desk                                , chr(10)                               , p-netto                               , accum-pay                             ) ).
      assign
      for-chk-type = for-chk-type + 'сум-ош':U + chr(44)
      buf_chk-doc.correct = no
      v-view-log = yes
      .
    end.
  end.
  var-sum-r-b = 0.
  for each t-wth No-LOCK where
          t-wth.drc = recid(buf_chk-doc):
    if t-wth.byval  = 'error' then do:
        if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                               "!!!Чек &1 - ошибочный (Номер по кассе: &2 Касса: &3)&4" +                               "Для типа кассового платеже с кодом &1 и кодом валюты &2 СМЕШАНЫ строки с пустыми и непустыми номиналами"                               , buf_chk-doc.doc-code                               , buf_chk-doc.chk-num                                , buf_chk-doc.pay-desk                                , chr(10)                               , t-wth.pay-code                               , t-wth.curr-code                             ) ).
      assign
      for-chk-type = for-chk-type + 'сум-ош':U + chr(44)
      buf_chk-doc.correct = no
      v-view-log = yes
      .
    end.
    if buf_chk-doc.chk-type <> 0 then do:
      if ( (string(buf_chk-doc.chk-type) = '2':U or string(buf_chk-doc.chk-type) = '5':U) AND
        t-wth.sum > 0) OR
        (string(buf_chk-doc.chk-type) = '3':U AND t-wth.sum < 0)
        then do:
        assign
        for-chk-type = for-chk-type + 'сум-ош':U + chr(44)
        buf_chk-doc.correct = no
        v-view-log = yes
        .
            if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                               "!!!Чек МЦ &1 - ошибочный&2Знак суммы по всем строкам МЦ не соответствует типу чека &3&2" +                               "Код оплаты МЦ: &4 код валюты МЦ &5"                               , buf_chk-doc.doc-code                               , chr(10)                               , entry (lookup (string(buf_chk-doc.chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)                               , t-wth.pay-code                               , t-wth.curr-code                             ) ).
      end.
      if string(buf_chk-doc.chk-type) = '4':U then do:
        assign
        var-sum-r-b = var-sum-r-b + t-wth.sum-r-b
        .
      end.
    end.
  end.
  if string(buf_chk-doc.chk-type) = '4':U AND ABS(var-sum-r-b) > 0.05 then do:
    assign
    for-chk-type = for-chk-type + 'сум-ош':U + chr(44)
    buf_chk-doc.correct = no
    v-view-log = yes
    .
        if valid-handle(v-p-log-handle) then run write-log-and-file in v-p-log-handle (               input 1             , input log-file-name             , input 1             , input substitute(                             "!!!Чек МЦ &1 - ошибочный&2Знак суммы по всем строкам МЦ не соответствует типу чека &3"                             , buf_chk-doc.doc-code                             , chr(10)                             , entry (lookup (string(buf_chk-doc.chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)                           ) ).
  end.
  assign
  buf_chk-doc.PS = (if index(buf_chk-doc.ps, 'shift!':U) > 0
                  then '!shift!'
                  else (if index(buf_chk-doc.ps, '!':U) > 0 then '!' else '':U)
                  ) + RIGHT-TRIM(for-chk-type, chr(44))
  buf_chk-doc.whole-send-news = v-pos-type-int
  buf_chk-doc.office = RIGHT-TRIM(for-chk-type, chr(44)) +
                       (if not p-close-check
                        then (chr(44) + 'готов':U)
                        else '')
  buf_chk-doc.correct = if replace(replace(for-chk-type
                                            , 'готов':U
                                            , '':U)
                                    , chr(44)
                                    , '') = '':U
                         then (if buf_chk-doc.correct = ?
                               or buf_chk-doc.correct = yes
                               then yes
                               else no)
                        else no
  .
  find first ub.chk-gds no-lock where ub.chk-gds.doc-code = buf_chk-doc.doc-code no-error.
  if trim(buf_chk-doc.office) = "" and not available ub.chk-gds then
      buf_chk-doc.office = 'т':U.
  p-mc-prev-code = "" .
end.
end procedure.
