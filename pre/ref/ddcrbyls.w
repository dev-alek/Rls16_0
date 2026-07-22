DEFINE BUFFER X_clients-obj FOR ub.clients.
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-subject as character no-undo.
define input parameter p-host-code like ub.clients.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Скидки по отдельной ДК." .
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
define new shared temp-table dc-list no-undo like ub.dis-card
  field to-del as logical
  field order-num as integer
  field fdec as decimal
  field fint as integer
  field flog as logical
  field fchar as character
  index pi  is primary unique d-card
  index cn      card-num
  index cli cli-type cli-code
  index host-dscnt  emitent-host-code status_ d-pcnt
  index host-type  emitent-host-code type d-pcnt
  index oi order-num
  .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table dc-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION CIntBinS RETURNS CHARACTER(input vl_int as integer):
def var vl_bin as char no-undo init "".
if vl_int < 0 OR vl_int = ? then return ?.
do while vl_int > 0:
  assign
  vl_bin = (if vl_int modulo 2 = 0
              then "0":U
              else "1":U) + vl_bin
  vl_int = truncate(vl_int / 2,0).
end.
return fill( "0":U, 32 - length(vl_bin)) + vl_bin .
END FUNCTION.
FUNCTION BinMask RETURNS LOGICAL(input vl_int as integer,
                                 input vl_binm as character):
DEFINE VARIABLE vl_bin as character no-undo.
DEFINE VARIABLE ii as integer no-undo.
DEFINE VARIABLE ii-len as integer no-undo.
DEFINE VARIABLE ii-lenm as integer no-undo.
DEFINE VARIABLE mchar as character no-undo.
DEFINE VARIABLE ichar as character no-undo.
if vl_binm = ? then return ?.
vl_bin = CIntBinS(vl_int).
if vl_bin = ? then return ?.
assign
vl_binm = LEFT-TRIM(vl_binm, "X":U)
ii-lenm = LENGTH(vl_binm)
ii-len = LENGTH(vl_bin) - ii-lenm
.
if II-LENM > 32 THEN RETURN ?.
DO II = 1 to II-LENm:
  assign
  mchar = SUBSTR(vl_binm, ii, 1)
  ichar = SUBSTR(vl_bin, ii + ii-len, 1)
  .
  IF not (MCHAR = "0":u or MCHAR = "1":u or MCHAR = "X":u) then return ?.
  IF ichar <> mchar AND mchar <> "X":U then return no.
END.
return yes.
END FUNCTION.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table temp-disc no-undo
field rule-num as integer
field host-code as integer
field obj-type as character
field obj-code as integer
field templ-rl-root as integer
field time-templ-rl-root as integer
field discnt-role as character
field nonunique as character
field cfg-nonunique as character
field pos-type as character
field action as logical
field label_ as character
index pi is  unique primary
pos-type discnt-role nonunique host-code obj-type obj-code action ASCENDING
index action
action
index ipos
pos-type discnt-role
.
procedure temp-dsc-value :
define input  parameter p-pos-type  as character  no-undo .
define input  parameter p-templ-rl-root as integer  no-undo .
define input  parameter p-time-templ-rl-root as integer no-undo .
define input  parameter p-discnt-role  as character  no-undo .
define input  parameter p-cfg-nonunique as character no-undo .
define input  parameter p-host-code as integer no-undo .
define input  parameter p-obj-type  as character no-undo .
define input  parameter p-obj-code as integer no-undo .
define input  parameter p-0mode as character no-undo .
define input  parameter p-mode      as character no-undo .
define input  parameter p-rec as recid no-undo .
define output parameter p-rule-num    as integer no-undo .
define output parameter p-nonunique   as character no-undo .
define buffer buf_temp-disc for temp-disc .
define variable v-discnt-role as character no-undo .
define variable v-rule-num as integer no-undo .
define variable v-nonunique as character no-undo .
define variable v-templ-rl-root as integer no-undo .
define variable v-time-templ-rl-root as integer no-undo .
define variable v-setted         as logical   no-undo .
define variable choice as integer no-undo .
do
on error undo, return error
:
  case 'dis-dc-rule':U:
    when 'dis-gds-rule':U
    then do:
      run discfgru-check  in this-procedure (
                                               input 'dis-gds-rule':U
                                              ,input p-templ-rl-root
                                              ,input p-time-templ-rl-root
                                              ,input p-pos-type
                                              ,output v-discnt-role) no-error.
    end.
    when 'dis-dc-rule':U then do:
      run discfgru-check  in this-procedure (
                                               input 'dis-dc-rule':U
                                              ,input p-templ-rl-root
                                              ,input p-time-templ-rl-root
                                              ,input p-pos-type
                                              ,output v-discnt-role) no-error.
    end.
    when 'dis-cp-rule':U then do:
      run discfgru-check  in this-procedure (
                                               input 'dis-cp-rule':U
                                              ,input p-templ-rl-root
                                              ,input p-time-templ-rl-root
                                              ,input p-pos-type
                                              ,output v-discnt-role) no-error.
    end.
    otherwise do:
      undo, return error .
    end.
  end case.
  if error-status :error
  then do:
    undo, return error return-value .
  end.
  if p-mode = "change":U
  then do:
    if p-rec <> ? then do:
      find first buf_temp-disc no-lock where
            recid(buf_temp-disc) = p-rec
        no-error .
    end.
    else do:
      find first buf_temp-disc no-lock where
                buf_temp-disc.pos-type = p-pos-type
            and buf_temp-disc.discnt-role = p-discnt-role
            and buf_temp-disc.nonunique  = p-nonunique
            and buf_temp-disc.host-code = p-host-code
            and buf_temp-disc.obj-type = p-obj-type
            and buf_temp-disc.obj-code = p-obj-code
        no-error .
    end.
    if avail buf_temp-disc then do:
      assign
      v-rule-num =  buf_temp-disc.rule-num
      v-nonunique = buf_temp-disc.nonunique
      v-templ-rl-root = buf_temp-disc.templ-rl-root
      v-time-templ-rl-root = buf_temp-disc.time-templ-rl-root
      .
    end.
  end.
  CASE 'dis-dc-rule':U:
    when 'dis-dc-rule':U then do:
      run disdcrul-edit in this-procedure (
                                   input 'ИЗМЕНЕНИЕ':U
                                  ,input '':U
                                  ,input p-host-code
                                  ,input p-obj-type
                                  ,input p-obj-code
                                  ,INPUT p-pos-type
                                  ,input p-discnt-role
                                  ,input p-templ-rl-root
                                  ,input p-time-templ-rl-root
                                  ,input p-cfg-nonunique
                                  ,input 1
                                  ,input-output v-rule-num
                                  ,input-output v-nonunique
                                  ,output v-setted ) no-error.
      if error-status :error then do:
        undo, return error substitute("Ошибка при получения значения скидки по отдельной ДК:&1" +
                                      "место использ. &2 тип скидки &3"
                                      , chr(10)
                                      , p-pos-type
                                      , entry (lookup (p-discnt-role, 'debet-pay-pcnt-disc,debet-pay-abs-disc,debet-pay-qnty-disc,debet-pay-sum-disc,debet-pay-free-disc,dc-d-pcnt,dc-cash-d-pcnt,credit-pay-pcnt-disc,credit-pay-abs-disc,credit-pay-qnty-disc,credit-pay-sum-disc,credit-pay-free-disc':u) + 1, ',' + '% Скидка при оплате топлива по дебет.ведомости,ABS Скидка при оплате топлива по дебет.ведомости,Скидка на кол-во при оплате топлива по дебет.ведомости,Скидка на сумму при оплате топлива по дебет.ведомости,Своб скидка при оплате топлива по дебет.ведомости,% скидка на товар по ДК,% скидка на итог чека по ДК,% Скидка при оплате топлива по кредит.ведомости,Abs Скидка при оплате топлива по кредит.ведомости,Скидка на кол-во при оплате топлива по кредит.ведомости,Скидка на сумму при оплате топлива по кредит.ведомости,Своб Скидка на сумму при оплате топлива по кредит.ведомости':u)).
      end.
    end.
  END CASE.
  if v-setted = no then do:
    return "not-set":U.
  end.
  p-rule-num = v-rule-num.
  p-nonunique = v-nonunique.
end.
end procedure.
procedure temp-dsc-write :
  do
  on error undo, return error
  :
    define input parameter p-add      as logical no-undo .
    define input parameter p-pos-type as character  no-undo .
    define input parameter p-templ-rl-root as integer  no-undo .
    define input parameter p-time-templ-rl-root as integer  no-undo .
    define input parameter p-discnt-role as character  no-undo .
    define input parameter p-cfg-nonunique as character no-undo .
    define input parameter p-host-code as integer no-undo .
    define input parameter p-obj-type as character no-undo .
    define input parameter p-obj-code as integer no-undo .
    define input parameter p-rule-num  as integer no-undo .
    define input parameter p-action   like temp-disc.action no-undo .
    define input-output parameter p-rec as recid no-undo .
    define buffer buf_temp-disc for temp-disc .
    define variable v-discnt-role as character no-undo .
    define variable varhost-code like ub.clients.host-code no-undo.
    define variable varobj-type like ub.clients.obj-type no-undo.
    define variable varobj-code like ub.clients.obj-code no-undo.
    define variable choice as integer no-undo .
    define var loc#log as logical no-undo.
    define variable loc-action as logical no-undo.
    define variable v-nonunique as character no-undo .
    define buffer buf_dis-rule for ub.dis-rule.
    case 'dis-dc-rule':U:
      when 'dis-gds-rule':U
      then do:
        run discfgru-check  in this-procedure (
                                                input 'dis-gds-rule':U
                                               ,input p-templ-rl-root
                                               ,input p-time-templ-rl-root
                                               ,input p-pos-type
                                               ,output v-discnt-role) no-error.
      end.
      when 'dis-dc-rule':U
      then do:
        run discfgru-check  in this-procedure (
                                                input 'dis-dc-rule':U
                                               ,input p-templ-rl-root
                                               ,input p-time-templ-rl-root
                                               ,input p-pos-type
                                               ,output v-discnt-role) no-error.
      end.
      when 'dis-cp-rule':U
      then do:
        run discfgru-check  in this-procedure (
                                                input 'dis-cp-rule':U
                                               ,input p-templ-rl-root
                                               ,input p-time-templ-rl-root
                                               ,input p-pos-type
                                               ,output v-discnt-role) no-error.
      end.
      otherwise do:
        undo, return error .
      end.
    END CASE.
    if error-status :error then do:
      undo, return error return-value .
    end.
    if p-cfg-nonunique <> '':U
    and p-rule-num <> 0
    and p-rule-num <> ?
    then do:
      find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-rule-num no-error.
      if not available buf_dis-rule then do:
        undo, return error substitute("Не найдено правило скидок &1", p-rule-num).
      end.
      assign
      v-nonunique = (if p-cfg-nonunique = '':U
                    then '':U
                    else (if p-cfg-nonunique begins "@"
                          then left-trim(p-cfg-nonunique, "@")
                          else string(buffer buf_Dis-rule:handle:buffer-field(p-cfg-nonunique):buffer-value)
                          ))
      .
    end.
    if p-rec <> ? then do:
      find first buf_temp-disc exclusive-lock where
                recid(buf_temp-disc) = p-rec no-error .
    end.
    else do:
      find first buf_temp-disc exclusive-lock where
                buf_temp-disc.pos-type = p-pos-type
              and buf_temp-disc.discnt-role = p-discnt-role
              and buf_temp-disc.host-code = p-host-code
              and buf_temp-disc.obj-type = p-obj-type
              and buf_temp-disc.obj-code = p-obj-code
              and buf_temp-disc.nonunique = v-nonunique
              no-error .
    end.
    if not available buf_temp-disc then do:
      create buf_temp-disc .
      assign
      buf_temp-disc.host-code = p-host-code
      buf_temp-disc.obj-type = p-obj-type
      buf_temp-disc.obj-code = p-obj-code
      buf_temp-disc.rule-num = p-rule-num
      buf_temp-disc.action = p-action
      buf_temp-disc.pos-type = p-pos-type
      buf_temp-disc.discnt-role = p-discnt-role
      buf_temp-disc.cfg-nonunique = p-cfg-nonunique
      buf_temp-disc.rule-num = p-rule-num
      buf_temp-disc.nonunique = v-nonunique
      buf_temp-disc.time-templ-rl-root = p-time-templ-rl-root
      buf_temp-disc.templ-rl-root = p-templ-rl-root
      p-rec = recid(buf_temp-disc)
      no-error
      .
    end.
    ELSE do:
      if p-add then do:
         message
         substitute("Такая скидка уже добавлена&1"
                    ,chr(10)
                )
         view-as alert-box error .
        undo, return error "not-set" .
      end.
      ASSIGN
      buf_temp-disc.rule-num = p-rule-num
      buf_temp-disc.nonunique = v-nonunique
      buf_temp-disc.time-templ-rl-root = p-time-templ-rl-root
      buf_temp-disc.templ-rl-root = p-templ-rl-root
      p-rec = recid(buf_temp-disc)
      no-error.
    end.
  end.
end procedure.
procedure temp-dsc-exist :
define input parameter p-pos-type as character  no-undo .
define input parameter p-templ-rl-root as integer  no-undo .
define input parameter p-time-templ-rl-root as integer no-undo .
define input parameter p-discnt-role as character  no-undo .
define input parameter p-nonunique as character no-undo .
define input parameter p-host-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define output parameter p-exist    as logical no-undo .
define output parameter p-action as logical no-undo .
define variable v-discnt-role as character no-undo .
define buffer buf_temp-disc for temp-disc .
  do
  on error undo, return error
  :
    case 'dis-dc-rule':U:
      when 'dis-gds-rule':U then do:
        run discfgru-check  in this-procedure (
                                                input 'dis-gds-rule':U
                                               ,input p-templ-rl-root
                                               ,input p-time-templ-rl-root
                                               ,input p-pos-type
                                               ,output v-discnt-role) no-error.
      end.
      when 'dis-dc-rule':U then do:
        run discfgru-check  in this-procedure (
                                                input 'dis-dc-rule':U
                                               ,input p-templ-rl-root
                                               ,input p-time-templ-rl-root
                                               ,input p-pos-type
                                               ,output v-discnt-role) no-error.
      end.
      otherwise do:
        undo, return error .
      end.
    end case.
    if error-status :error
    then do:
      undo, return error return-value .
    end.
    find first buf_temp-disc no-lock where
               buf_temp-disc.pos-type = p-pos-type
            and buf_temp-disc.discnt-role = p-discnt-role
            and buf_temp-disc.host-code = p-host-code
            and buf_temp-disc.obj-type = p-obj-type
            and buf_temp-disc.obj-code = p-obj-code
            and buf_temp-disc.nonunique = p-nonunique no-error .
    if available buf_temp-disc then do:
      P-EXIST = YES.
      p-action = buf_temp-disc.action.
    end.
  end.
end procedure.
procedure temp-dsc-delete :
define input parameter p-pos-type as character  no-undo .
define input parameter p-discnt-role as character no-undo .
define input parameter p-nonunique as character no-undo .
define input parameter p-host-code  as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-action as logical no-undo .
define output parameter p-deleted  as logical no-undo .
define buffer buf_temp-disc for temp-disc .
  do
  on error undo, return error :
    case 'dis-dc-rule':U:
      when 'dis-gds-rule':U
      then do:
        error-status:error = no.
      end.
      when 'dis-dc-rule':U
      then do:
        error-status:error = no.
      end.
      when 'dis-cp-rule':U
      then do:
        error-status:error = no.
      end.
      otherwise do:
        undo, return error .
      end.
    END CASE.
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_temp-disc exclusive-lock where
               buf_temp-disc.pos-type = p-pos-type
           and buf_temp-disc.discnt-role = p-discnt-role
           and buf_temp-disc.host-code = p-host-code
           and buf_temp-disc.obj-type = p-obj-type
           and buf_temp-disc.obj-code = p-obj-code
           and buf_temp-disc.nonunique = p-nonunique
           and buf_temp-disc.action = p-action
           no-error .
    if not available buf_temp-disc then do:
      P-DELETED = NO.
    end.
    ELSE DO:
       delete buf_temp-disc.
       P-DELETED = YES.
    END.
  end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = 'орг':U then do:
       par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parhost-code).
       return par-region.
    end.
    if parobj-type = 'регион':U
    then do:
       par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
       return par-region.
    end.
    par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
    return par-region.
END FUNCTION.
FUNCTION get-objregion RETURNS CHARACTER
  (  input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if  parobj-type = "":U and
      parobj-code = 0
  then do:
     par-region = "Глобально".
  end.
  else if parobj-type = 'орг':U
  then do:
     par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parobj-code).
  end.
  else if parobj-type = 'регион':U
  then do:
     par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
  end.
  else
     par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
  return par-region.
END FUNCTION.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-drt-prop no-undo like ub.drt-prop.
procedure disrules-fill-properties:
define input  parameter p-templ-rl-root as integer   no-undo .
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_temp-drt-prop for temp-drt-prop.
do
on error undo, return error return-value
:
  for each buf_temp-drt-prop:
    delete buf_temp-drt-prop.
  end.
  for each buf_drt-prop where buf_drt-prop.templ-rl-root = p-templ-rl-root:
    create buf_temp-drt-prop.
    buffer-copy buf_drt-prop to buf_temp-drt-prop.
  end.
end.
end procedure.
~
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure discfgru-check :
define input parameter p-table-name as character no-undo .
define input parameter p-templ-rl-root as integer no-undo .
define input parameter p-time-templ-rl-root as integer no-undo .
define input parameter p-pos-type as character no-undo .
define output parameter p-disnct-role as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
  do
  on error undo, return error return-value
  :
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.table-name = p-table-name
        and buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
        and (p-time-templ-rl-root = ? or  buf_dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root)
        and buf_dis-cfg-rule.pos-type = p-pos-type no-error.
    if not available buf_dis-cfg-rule
    or p-pos-type = "":U
    then do:
       return error substitute("Для места использования типа &1 не определен тип скидки с шаблоном &2 &3"
                               ,entry (lookup (p-pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U)
                               , p-templ-rl-root
                               , (if p-time-templ-rl-root = ?
                                  then '':U
                                  else substitute("с расписанием типа &1", p-time-templ-rl-root)
                                  )
                               ).
    end.
    assign
    p-disnct-role = buf_dis-cfg-rule.discnt-role
    .
  end.
end procedure.
procedure disdcrul-name :
define buffer buf_dis-rule for ub.dis-rule.
do
  on error undo, return error
  :
  define input  parameter p-templ-rl-root  as integer no-undo .
  define output parameter p-label          as character no-undo .
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-templ-rl-root no-error.
  if available buf_dis-rule then do:
    if buf_dis-rule.rule-num > 0 then
    p-label = buf_dis-rule.des.
  end.
  else do:
    p-label = substitute("Неизвестный тип правила скидки &1", p-templ-rl-root).
  end.
end.
end procedure.
function disdcrul-get-disc-label returns character ( input p-templ-rl-root as integer):
define variable v-rule-label as character no-undo .
run disdcrul-name in this-procedure ( input p-templ-rl-root
                                     ,output v-rule-label) no-error.
return v-rule-label.
end function.
function disdcrul-get-disc-role-label returns character ( input p-discnt-role as character):
define variable v-rule-label as character no-undo .
return entry (lookup (p-discnt-role, 'debet-pay-pcnt-disc,debet-pay-abs-disc,debet-pay-qnty-disc,debet-pay-sum-disc,debet-pay-free-disc,dc-d-pcnt,dc-cash-d-pcnt,credit-pay-pcnt-disc,credit-pay-abs-disc,credit-pay-qnty-disc,credit-pay-sum-disc,credit-pay-free-disc':u) + 1, ',' + '% Скидка при оплате топлива по дебет.ведомости,ABS Скидка при оплате топлива по дебет.ведомости,Скидка на кол-во при оплате топлива по дебет.ведомости,Скидка на сумму при оплате топлива по дебет.ведомости,Своб скидка при оплате топлива по дебет.ведомости,% скидка на товар по ДК,% скидка на итог чека по ДК,% Скидка при оплате топлива по кредит.ведомости,Abs Скидка при оплате топлива по кредит.ведомости,Скидка на кол-во при оплате топлива по кредит.ведомости,Скидка на сумму при оплате топлива по кредит.ведомости,Своб Скидка на сумму при оплате топлива по кредит.ведомости':u).
end function.
procedure disdcrul-write :
  do
  on error undo, return error
  :
    define input parameter p-d-card         like ub.dis-dc-rule.d-card     no-undo .
    define input parameter p-host-code      like ub.dis-dc-rule.host-code  no-undo .
    define input parameter p-obj-type       like ub.dis-dc-rule.obj-type   no-undo .
    define input parameter p-obj-code       like ub.dis-dc-rule.obj-code   no-undo .
    define input parameter p-pos-type       like ub.dis-dc-rule.pos-type   no-undo .
    define input parameter p-discnt-role    like ub.dis-dc-rule.discnt-role no-undo .
    define input parameter p-templ-rl-root  like ub.dis-dc-rule.templ-rl-root  no-undo .
    define input parameter p-time-templ-rl-root  like ub.dis-dc-rule.time-templ-rl-root  no-undo .
    define input parameter p-rule-num       like ub.dis-dc-rule.rule-num    no-undo .
    define input parameter p-nonunique      like ub.dis-dc-rule.nonunique   no-undo .
    define buffer buf_dis-rule for ub.dis-rule.
    define buffer buf_dis-dc-rule for ub.dis-dc-rule .
    define buffer lock_dis-dc-rule for ub.dis-dc-rule .
    define variable v-label          as character no-undo .
    define variable v-discnt-role as character no-undo .
    run discfgru-check in this-procedure (
                                          input 'dis-dc-rule':U
                                         ,input p-templ-rl-root
                                         ,input p-time-templ-rl-root
                                         ,input p-pos-type
                                         ,output v-discnt-role
                                          ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    if p-discnt-role = ? then do:
      p-discnt-role = v-discnt-role.
    end.
    if p-discnt-role <> v-discnt-role then do:
      undo, return error substitute("ДК &1 Фирма &2 &3&4 место использ. &5 скидка типа &6&7не может быть по шаблону &8 и расписанию &9"
                              ,p-d-card
                              ,p-host-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-templ-rl-root
                              ,p-rule-num).
    end.
    if p-pos-type = ? then do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type10 as character no-undo .
define variable v-value-date10 as date no-undo .
define variable v-value-decimal10 as decimal no-undo .
define variable v-value-integer10 as INTEGER no-undo .
define variable v-value-logical10 AS LOGICAL no-undo .
define variable v-tth10 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output p-pos-type
    ,output v-value-date10
    ,output v-value-decimal10
    ,output v-value-integer10
    ,output v-value-logical10
    ,output v-param-type10
    ,INPUT-OUTPUT table-handle v-tth10
    )  .
delete object v-tth10 no-error.
    end.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-rule-num no-error.
    if not available buf_Dis-rule then do:
      undo, return error substitute("ДК &1 Фирма &2 &3&4 место использ. &5 скидка типа &6&7не найдено правило скидки &8"
                              ,p-d-card
                              ,p-host-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-rule-num).
    end.
    if buf_dis-rule.root <> yes then do:
      undo, return error substitute("ДК &1 Фирма &2 &3&4 место использ. &5 скидка типа &6&7правило скидки &8 - некорневое"
                              ,p-d-card
                              ,p-host-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-rule-num).
    end.
    if not (p-host-code = buf_dis-rule.host-code
        and p-obj-type = buf_dis-rule.obj-type
        and p-obj-code = buf_dis-rule.obj-code)
    then do:
      undo, return error (substitute("ДК &1 Фирма &2 &3&4 место использ. &5 скидка типа &6&7правило скидки &8 - некорневое"
                              ,p-d-card
                              ,p-host-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              )
                          +
                          substitute("Правило скидки &1 определено для &2&3" +
                                     "а привязка к ДК для &4"
                                     ,buf_dis-rule.rule-num
                                     ,get-region( buf_Dis-rule.host-code, buf_dis-rule.obj-type, buf_Dis-rule.obj-code)
                                     ,chr(10)
                                     ,get-region( p-host-code, p-obj-type, p-obj-code)
                                     ))
                              .
    end.
    find first buf_dis-dc-rule exclusive-lock where
               buf_dis-dc-rule.d-card  = p-d-card
           AND buf_dis-dc-rule.obj-type  = p-obj-type
           AND buf_dis-dc-rule.host-code = p-host-code
           AND buf_dis-dc-rule.obj-code  = p-obj-code
           AND buf_dis-dc-rule.pos-type  = p-pos-type
           AND buf_dis-dc-rule.discnt-role = p-discnt-role
           and buf_dis-dc-rule.nonunique = p-nonunique
           no-error .
    if not available buf_dis-dc-rule then do:
      create buf_dis-dc-rule .
      assign
      buf_dis-dc-rule.d-card  = p-d-card
      buf_dis-dc-rule.host-code  = p-host-code
      buf_dis-dc-rule.obj-type  = p-obj-type
      buf_dis-dc-rule.obj-code  = p-obj-code
      buf_dis-dc-rule.pos-type = p-pos-type
      buf_dis-dc-rule.discnt-role = v-discnt-role
      buf_dis-dc-rule.rule-num = p-rule-num
      buf_dis-dc-rule.nonunique = p-nonunique
      no-error
      .
    end.
    ASSIGN
    buf_dis-dc-rule.time-templ-rl-root = p-time-templ-rl-root
    buf_dis-dc-rule.rule-num = p-rule-num
    buf_dis-dc-rule.rl-root = buf_Dis-rule.rl-root
    buf_dis-dc-rule.templ-rl-root = p-templ-rl-root
    buf_dis-dc-rule.nonunique = p-nonunique
    no-error.
  end.
end procedure.
procedure disdcrul-edit :
define input parameter p-mode as character no-undo .
define input parameter p-d-card   like ub.dis-dc-rule.d-card no-undo .
define input parameter p-host-code like ub.dis-dc-rule.host-code no-undo .
define input parameter p-obj-type like ub.dis-dc-rule.obj-type no-undo .
define input parameter p-obj-code like ub.dis-dc-rule.obj-code no-undo .
define input parameter p-pos-type like ub.dis-dc-rule.pos-type no-undo .
define input parameter p-discnt-role like ub.dis-dc-rule.discnt-role no-undo .
define input parameter p-templ-rl-root like ub.dis-dc-rule.templ-rl-root no-undo .
define input parameter p-time-templ-rl-root like ub.dis-dc-rule.time-templ-rl-root no-undo .
define input parameter p-cfg-nonunique as character no-undo .
define input parameter p-check as integer no-undo .
define input-output parameter p-rule-num as integer no-undo .
define input-output parameter p-NONUNIQUE like ub.dis-cfg-rule.NONUNIQUE no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
define variable v-sts as integer no-undo .
define variable v-rid-list as character no-undo .
DEFINE VARIABLE v-rule-num as integer no-undo .
define variable v-cd-dr-correct  as logical no-undo .
define variable jj as integer no-undo .
define variable conf-par as character no-undo .
define variable conf-attr as character no-undo .
define variable par-type as character no-undo .
define variable dflt-cd as character no-undo .
define variable v-cd-list as character no-undo .
define variable v-is-time-rule as logical no-undo .
define variable v-label as character no-undo .
define variable v-nonunique as character no-undo .
define variable v-mode as character no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-time-rule for ub.dis-time-rule .
define buffer term_dis-rule for ub.dis-rule.
define buffer buf_dis-dc-rule for ub.dis-dc-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_temp-disc for temp-disc.
assign
v-rule-num = p-rule-num.
v-sts = integer('0':U).
if v-rule-num <> 0
and v-rule-num <> ?
then do:
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = v-rule-num no-error .
  if error-status:error then do:
    message
    "Ошибка при поиске правила с номером" v-rule-num
    view-as alert-box error .
    return .
  end.
  assign
  v-rid-list = string(recid(buf_dis-rule))
  .
end.
run disdcrul-name in this-procedure (
                              input p-templ-rl-root
                              ,output v-label) no-error.
if p-pos-type = ?
or p-pos-type = '':U then do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type11 as character no-undo .
define variable v-value-date11 as date no-undo .
define variable v-value-decimal11 as decimal no-undo .
define variable v-value-integer11 as INTEGER no-undo .
define variable v-value-logical11 AS LOGICAL no-undo .
define variable v-tth11 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date11
    ,output v-value-decimal11
    ,output v-value-integer11
    ,output v-value-logical11
    ,output v-param-type11
    ,INPUT-OUTPUT table-handle v-tth11
    )  .
delete object v-tth11 no-error.
end.
else do:
  dflt-cd = p-pos-type.
end.
v-mode =  ('dis-dc-rule':U + "=" + p-discnt-role).
run ref/dis-ruls.w (
            input parparentproc
            ,input p-host-code
            ,input p-obj-type
            ,input p-obj-code
            ,input "b-add,b-sel":U
            ,input v-mode
            ,input p-templ-rl-root
            ,input p-time-templ-rl-root
            ,input 0
            ,input-output v-sts
            ,input-output v-rid-list ) no-error .
do
on error undo, return error return-value
:
  if v-rid-list <> "":U then do:
    find first buf_dis-rule exclusive-lock where
                recid(buf_dis-rule) = integer(v-rid-list) no-wait no-error .
    if not available buf_dis-rule
    then do:
      message
      "Ошибка при поиске правила с recid" v-rid-list
      view-as alert-box error .
      return .
    end.
    if buf_dis-rule.sts <> integer('0':U) then do:
      message
      "Правило скидки имеет статус" entry (lookup (string(buf_dis-rule.sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U) skip
      "Нельзя привязать к нему скидку на ДК"
      view-as alert-box error .
      return .
    end.
    find first buf_dis-cfg-rule no-lock where
             buf_dis-cfg-rule.templ-rl-root =  buf_dis-rule.templ-rl-root
         and buf_dis-cfg-rule.time-templ-rl-root = (if buf_dis-rule.time-templ-rl-root = 0
                                                    then 0
                                                    else buf_dis-rule.time-templ-rl-root)
        and buf_dis-cfg-rule.pos-type = dflt-cd
        and buf_Dis-cfg-rule.table-name = 'dis-dc-rule':U
        no-error.
    if available buf_dis-cfg-rule then do:
      assign
      v-cd-dr-correct = yes
      .
    end.
    if not v-cd-dr-correct
    then do:
      message
      substitute("Правило скидки &1 неприменимо для касс &2.&3" +
                "(АРМ АДМИНИСТРАТОР-Магазины(Фирмы)-Параметры-Общие опции коммуникации с кассами)"
                ,buf_dis-rule.rule-num
                ,dflt-cd
                ,chr(10)
                )
      view-as alert-box error .
      undo, return error .
    end.
    assign
    v-nonunique = if p-cfg-nonunique = '':U
                  then '':U
                  else string(buffer buf_Dis-rule:handle:buffer-field(p-cfg-nonunique):buffer-value).
    if p-check = 0
    or p-check = 2
    then do:
      find first buf_dis-dc-rule no-lock where
                  buf_dis-dc-rule.obj-type = p-obj-type
              and buf_dis-dc-rule.obj-code = p-obj-code
              and buf_dis-dc-rule.host-code = p-host-code
              and buf_dis-dc-rule.d-card = p-d-card
              and buf_dis-dc-rule.pos-type = p-pos-type
              and buf_dis-dc-rule.discnt-role = p-discnt-role
              and buf_dis-dc-rule.nonunique = v-nonunique no-error .
      if available buf_dis-dc-rule
      and p-mode <> 'ИЗМЕНЕНИЕ':U
      then do:
        message
        "Скидка такого типа на данную ДК уже существует"
        view-as alert-box error .
        return error.
      end.
    end.
    if p-check = 1
    or p-check = 2
    then do:
      find first buf_temp-disc no-lock where
                  buf_temp-disc.obj-type = p-obj-type
              and buf_temp-disc.obj-code = p-obj-code
              and buf_temp-disc.host-code = p-host-code
              and buf_temp-disc.pos-type = p-pos-type
              and buf_temp-disc.templ-rl-root = p-templ-rl-root
              and buf_temp-disc.nonunique = v-nonunique no-error .
      if available buf_temp-disc
      and buf_temp-disc.rule-num <> 0
      and p-mode <> 'ИЗМЕНЕНИЕ':U
      then do:
        message
        "Скидка такого типа на данную ДК уже существует"
        view-as alert-box error .
        return error.
      end.
    end.
    if p-rule-num <> buf_dis-rule.rule-num then do:
      assign
      p-setted = yes
      p-rule-num = buf_dis-rule.rule-num
      p-nonunique = v-nonunique
      .
    end.
  end.
end.
end procedure.
define variable add-option as char no-undo.
DEFINE VARIABLE add-obj-type like ub.clients.obj-type no-undo .
DEFINE VARIABLE add-obj-code like ub.clients.obj-code no-undo .
define variable updated as logical no-undo.
define variable temp-doc-rec as recid no-undo.
define buffer del_temp-disc for temp-disc.
define variable glog as logical no-undo .
define variable v-tab-order AS character no-undo.
define variable loc-glob as logical no-undo .
define variable loc-firm as logical no-undo .
define variable loc-object as logical no-undo .
define variable dflt-cd as character no-undo .
FUNCTION dis-dc-rule-name RETURNS CHARACTER
  ( INPUT p-discnt-role AS character )  FORWARD.
DEFINE MENU MENU-b-add
       MENU-ITEM m_pos-type     LABEL "m_pos-type"
       MENU-ITEM m_no-pos       LABEL "По накладной"
       MENU-ITEM m_bo           LABEL "Бэкофис"       .
DEFINE MENU MENU-b-add-2
       MENU-ITEM m_pos-type-2   LABEL "m_pos-type-2"
       MENU-ITEM m_no-pos-2     LABEL "По накладной"
       MENU-ITEM m_bo-2         LABEL "Бэкофис"       .
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Выбрать скидку для добавления".
DEFINE BUTTON b-add-2
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Выбрать скидку для удаления".
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-chg-2
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-del-2
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-exit
     LABEL "&Ввод"
     SIZE 10 BY 1 TOOLTIP "Установить/изменить/удалить скидки по списку"
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-list
     LABEL "&Список"
     SIZE 10 BY 1 TOOLTIP "Создание списка".
DEFINE BUTTON B-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE f-obj-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.
DEFINE VARIABLE F-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 52.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE Rs-obj-type AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2"
     SIZE 16.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-delete-ok AS LOGICAL INITIAL no
     LABEL "Удалять записи списка в случае удачного изменения"
     VIEW-AS TOGGLE-BOX
     SIZE 52 BY 1 NO-UNDO.
DEFINE QUERY BR-add FOR
      temp-disc SCROLLING.
DEFINE QUERY BR-del FOR
      del_temp-disc SCROLLING.
DEFINE BROWSE BR-add
  QUERY BR-add DISPLAY
      entry (lookup (temp-disc.pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U) column-label "Место использ."  format "X(15)"
dis-dc-rule-name (temp-disc.discnt-role) column-label "Тип скидки" FORMAT "X(255)":U WIDTH 35
temp-disc.templ-rl-root FORMAT ">>>>>>>>9":U COLUMN-LABEL "Код!шаблона"
disdcrul-get-disc-label( INPUT temp-disc.templ-rl-root) FORMAT "X(255)":U WIDTH 45
temp-disc.rule-num COLUMN-LABEL "Код правила" FORMAT ">>>>>>>>9"
get-region(temp-disc.host-code, temp-disc.obj-type, temp-disc.obj-code) COLUMN-LABEL "Действует" FORMAT "X(12)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8
         TITLE "Будут добавлены/изменены скидки".
DEFINE BROWSE BR-del
  QUERY BR-del DISPLAY
      entry (lookup (del_temp-disc.pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U) column-label "Место использ."  format "X(15)"
dis-dc-rule-name ( DEL_temp-disc.discnt-role) column-label "Тип скидки" FORMAT "X(255)":U WIDTH 35
del_temp-disc.templ-rl-root FORMAT ">>>>>>>>9":U COLUMN-LABEL "Код!шаблона"
disdcrul-get-disc-label( INPUT del_temp-disc.templ-rl-root) FORMAT "X(255)":U WIDTH 45
del_temp-disc.rule-num COLUMN-LABEL "Код правила" FORMAT ">>>>>>>>9"
get-region(del_temp-disc.host-code, del_temp-disc.obj-type, del_temp-disc.obj-code) COLUMN-LABEL "Действует" FORMAT "X(12)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8
         TITLE "Будут удалены скидки".
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-list AT ROW 1 COL 41
     B-Help AT ROW 1 COL 95
     Rs-obj-type AT ROW 2.25 COL 1 NO-LABEL
     f-obj-code AT ROW 2.25 COL 16 COLON-ALIGNED NO-LABEL
     B-obj AT ROW 2.25 COL 27
     T-delete-ok AT ROW 3.5 COL 1.5
     b-add AT ROW 4.75 COL 1
     B-chg AT ROW 4.75 COL 11
     B-del AT ROW 4.75 COL 21
     BR-add AT ROW 5.75 COL 1
     b-add-2 AT ROW 14 COL 1
     B-chg-2 AT ROW 14 COL 11 WIDGET-ID 2
     B-del-2 AT ROW 14 COL 21
     BR-del AT ROW 15 COL 1
     F-obj-name AT ROW 2.25 COL 30 COLON-ALIGNED NO-LABEL
     SPACE(14.50) SKIP(20.08)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-add:HANDLE.
ASSIGN
       b-add-2:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-add-2:HANDLE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
   if add-option = '':U then do:
      run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if add-option = '':U then return no-apply.
  run proc-b-add in this-procedure ( input add-option) no-error .
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.
END.
ON CHOOSE OF b-add-2 IN FRAME Dialog-Frame
DO:
    if add-option = '':U then do:
      run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if add-option = '':U then return no-apply.
  run proc-b-add-2 in this-procedure ( input add-option) no-error .
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
  run proc-b-chg in this-procedure ( input "change":U) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-chg-2 IN FRAME Dialog-Frame
DO:
  run proc-b-chg-2 in this-procedure ( input "change":U) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
  define variable loc#log as logical no-undo.
  if not avail temp-disc then return no-apply.
 loc#log = no.
  message "Вы уверены, что хотите удалить скидку"  "<" temp-disc.label_ ">" skip
                     "из списка скидок подлежащих установке/изменению?"  skip
          view-as alert-box QUESTIOn buttons YES-NO update loc#log.
  if NOT loc#log then return no-apply.
    run temp-dsc-delete in this-procedure (
                                             input temp-disc.pos-type
                                            ,input temp-disc.discnt-role
                                            ,input temp-disc.nonunique
                                            ,input temp-disc.host-code
                                            ,input temp-disc.obj-type
                                            ,input temp-disc.obj-code
                                            ,input temp-disc.action
                                            ,output loc#log) no-error .
    if error-status:error or not loc#log then do:
        return no-apply.
    end.
     updated = yes.
    run init-proc in this-procedure .
    APPLY "ENTRY" to br-add.
END.
ON CHOOSE OF B-del-2 IN FRAME Dialog-Frame
DO:
  define variable loc#log as logical no-undo.
  if not avail del_temp-disc then return no-apply.
  loc#log = no.
  message
  "Вы уверены, что хотите удалить скидку" "<" del_temp-disc.label_ ">" skip
  "из списка атрибутов, подлежащих удалению?" skip
   view-as alert-box QUESTIOn buttons YES-NO update loc#log.
  if NOT loc#log then return no-apply.
    run temp-dsc-delete in this-procedure (
                                             input del_temp-disc.pos-type
                                            ,input del_temp-disc.discnt-role
                                            ,input del_temp-disc.nonunique
                                            ,input del_temp-disc.host-code
                                            ,input del_temp-disc.obj-type
                                            ,input del_temp-disc.obj-code
                                            ,input del_temp-disc.action
                                            ,output loc#log) no-error .
    if error-status:error or not loc#log then do:
        return no-apply.
    end.
    updated = yes.
    run init-proc in this-procedure .
    APPLY "ENTRY" to br-del.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  RUN proc-b-exit IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-list IN FRAME Dialog-Frame
DO:
define variable v-host-code as integer no-undo .
  CASE par-subject:
    when 'dis-dc-rule':U
    then do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
      run str/dc-list.w ( input parparentproc, input v-host-code, input p-obj-type, input p-obj-code).
    end.
  END CASE.
  assign
  b-list:width = 10
  b-list:label = "&Список"
  .
END.
ON CHOOSE OF B-obj IN FRAME Dialog-Frame
DO:
  RUN proc-b-obj IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON LEAVE OF f-obj-code IN FRAME Dialog-Frame
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
  if   input frame Dialog-Frame f-obj-code <> 0 then do:
    run check-obj in this-procedure no-error.
    if error-status:error then do:
       return no-apply.
    end.
  end.
END.
ON CHOOSE OF MENU-ITEM m_bo
DO:
   add-option = 'bo':U.
  run proc-b-add in this-procedure ( input add-option ) no-error.
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_bo-2
DO:
      add-option = 'bo':U.
  run proc-b-add-2 in this-procedure ( input add-option ) no-error.
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_no-pos
DO:
      add-option = '-':U.
  run proc-b-add in this-procedure ( input add-option ) no-error.
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_no-pos-2
DO:
     add-option = '-':U.
  run proc-b-add-2 in this-procedure ( input add-option ) no-error.
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_pos-type
DO:
    add-option = dflt-cd.
  run proc-b-add in this-procedure ( input add-option ) no-error.
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_pos-type-2
DO:
    add-option = dflt-cd.
  run proc-b-add-2 in this-procedure ( input add-option ) no-error.
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.
END.
ON VALUE-CHANGED OF Rs-obj-type IN FRAME Dialog-Frame
DO:
    assign
  RS-obj-type.
  if   input frame Dialog-Frame f-obj-code <> 0 then do:
    run check-obj in this-procedure no-error.
    if error-status:error then do:
       return no-apply.
    end.
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
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
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
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
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
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
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
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
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
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
      v-field-group-handle = frame Dialog-Frame :first-child
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
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
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
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
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
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame Dialog-Frame :height)
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
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
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
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
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
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
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
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
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
      v-field-group-handle = frame Dialog-Frame :first-child
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
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
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
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
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
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame Dialog-Frame
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
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
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
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
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
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
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
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BR-add :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON RETURN ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
  if v-tab-order <> '' then do:
    assign
    ii = lookup(self:name, v-tab-order).
    if ii = num-entries(v-tab-order) then do:
        APPLY 'CHOOSE' TO b-exit in frame Dialog-Frame.
        return no-apply.
    end.
    if self:type <> "BUTTON" and
      self:type <> "EDITOR"  then do:
      run proc-move-forward in this-procedure .
      return no-apply.
    end.
    if self:type = "BUTTON" then do:
      APPLY "CHOOSE" to self.
    end.
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return no-apply.
        end.
        else do:
          APPLY "TAB" to hh.
          return no-apply.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
END.
procedure proc-move-forward :
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
do
on error undo, return error
:
  if v-tab-order <> '' then do:
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = lookup(self:name, v-tab-order).
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return.
        end.
        else do:
          assign
          ii = ii + 1
          v-next-widget-name = entry(ii, v-tab-order)
          no-error .
          if error-status:error then do:
            assign
            ii = 1
            v-next-widget-name = entry( ii, v-tab-order)
            .
          end.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
end.
end procedure.
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
  if lookup(par-subject, 'dis-dc-rule':U) = 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра par-subject" par-subject
    view-as alert-box error.
    return error.
  end.
  CASE par-subject:
    when 'dis-dc-rule':U
    then do:
       if v-cntxt-db-num = 0 then do:
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_dc-discount_global_work':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output loc-glob
    )  .
end.
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_dc-discount_firm_work':U
    ,input  'firm':U
    ,input  p-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output loc-firm
    )  .
end.
      end.
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_dc-discount_object_work':U
    ,input  'object':U
    ,input  p-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output loc-object
    )  .
end.
      if ((if v-cntxt-db-num = 0 and loc-glob then 1 else 0) +
      (if v-cntxt-db-num = 0 and loc-firm then 1 else 0) +
      (if loc-object then 1 else 0)) = 0 then do:
        message
        "У Вас отсутствуют права на назначение скидки на ДК как по объекту, так и по фирме и глобально" skip
        "либо Вы находитесь в БД, в которой их назначить невозможно"
        view-as alert-box error .
        undo, return.
      end.
    END.
  END CASE.
  find first X_clients-obj no-lock where
              X_clients-obj.obj-type = p-obj-type AND
              X_clients-obj.obj-code = p-obj-code no-error .
  if not avail X_clients-obj then do:
    message vss-workfile vss-revision vss-description skip
    "Неверное значение параметра p-obj-type и/или p-obj-code" p-obj-type p-obj-code
    view-as alert-box error.
    return error.
  end.
  RUN enable_UI in this-procedure .
  RUN MYenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI in this-procedure .
PROCEDURE check-obj :
define buffer buf_clients for ub.clients.
find first buf_clients no-lock where
              buf_clients.obj-code = input frame Dialog-Frame f-obj-code
         and buf_clients.obj-type = input frame Dialog-Frame RS-obj-type no-error.
if not available buf_clients then do:
  if input frame Dialog-Frame f-obj-code <> ?  then
    message "Неправильный код или тип объекта" .
  apply "entry" to f-obj-code in frame Dialog-Frame.
  return error.
end.
find first X_clients-obj no-lock where recid(X_clients-obj) = recid(buf_clients).
assign
p-obj-type = buf_clients.obj-type
p-obj-code = buf_clients.obj-code
RS-obj-type = buf_clients.obj-type
f-obj-code = buf_clients.obj-code
f-obj-name = buf_clients.obj-name
.
display
RS-obj-type
f-obj-code
f-obj-name
with frame Dialog-Frame.
RUN proc-title IN THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE choose-to-add :
define input parameter p-attr-code as character no-undo .
assign
add-option = p-attr-code
.
 APPLY "CHOOSE" to b-add in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE choose-to-delete :
define input parameter p-attr-code as character no-undo .
assign
add-option = p-attr-code
.
APPLY "CHOOSE" to b-add-2 in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY Rs-obj-type f-obj-code T-delete-ok F-obj-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-list B-Help Rs-obj-type f-obj-code B-obj T-delete-ok
         b-add B-chg B-del BR-add b-add-2 B-chg-2 B-del-2 BR-del F-obj-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-add FOR EACH temp-disc where temp-disc.action = yes NO-LOCK.    OPEN QUERY BR-del FOR EACH del_temp-disc where del_temp-disc.action = no NO-LOCK.
END PROCEDURE.
PROCEDURE init-proc :
assign
add-option = ""
add-obj-type = "":U
add-obj-code = 0
.
OPEN QUERY BR-add FOR EACH temp-disc where temp-disc.action = yes NO-LOCK.    OPEN QUERY BR-del FOR EACH del_temp-disc where del_temp-disc.action = no NO-LOCK.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE ch AS WIDGET-HANDLE NO-UNDO.
ch = br-add:FIRST-COLUMN IN FRAME Dialog-Frame.
DO ii = 1 TO br-add:NUM-COLUMNS IN FRAME Dialog-Frame:
    ASSIGN
    ch:RESIZABLE = YES.
    ch = ch:NEXT-COLUMN.
END.
assign
b-add:MENU-MOUSE in frame Dialog-Frame = 1
b-add-2:MENU-MOUSE in frame Dialog-Frame = 1
.
ASSIGN
RS-obj-type:radio-buttons = "Маг" + chr(44) + 'маг':U + chr(44) +
                                    "Скл" + chr(44) + 'скл':U
RS-obj-type = p-obj-type
f-obj-code = p-obj-code
f-obj-name = X_clients-obj.obj-name
.
DISPLAY
RS-obj-type
f-obj-code
f-obj-name
WITH FRAME Dialog-Frame.
RUN proc-title IN THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE proc-b-add :
define input parameter p-pos-type as character no-undo.
DEFINE VARIABLE v-deleted as logical no-undo .
define variable v-rid-list as character no-undo .
define variable dflt-cd as character no-undo .
define variable v-rec as recid no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-host-code as integer no-undo .
define buffer buf_temp-disc for temp-disc.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
do
on error undo, return error :
  run ref/dis-pos.w ( INPUT parparentproc
                      ,INPUT "b-sel":U
                      ,INPUT "cd-type-list"
                      ,INPUT (if v-cntxt-db-num = 0 and loc-glob then 1 else 0)
                      ,INPUT (if v-cntxt-db-num = 0 and loc-firm then 1 else 0)
                      ,INPUT 1
                      ,input 'dis-dc-rule':U
                      ,input '':U
                      ,input ?
                      ,INPUT p-pos-type
                      ,input '':U
                      ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  IF ERROR-STATUS:ERROR
  OR v-rid-list = '':U THEN DO:
    RETURN.
  END.
  FIND FIRST buf_dis-cfg-rule NO-LOCK where
            recid(buf_dis-cfg-rule) = INTEGER(v-rid-list).
  run set-region in this-procedure ( buffer buf_dis-cfg-rule
                                   , output v-host-code
                                   , output v-obj-type
                                   , output v-obj-code
                                   ).
  run temp-dsc-write in this-procedure (
                                         input yes
                                        ,input buf_dis-cfg-rule.pos-type
                                        ,input buf_dis-cfg-rule.templ-rl-root
                                        ,input buf_dis-cfg-rule.time-templ-rl-root
                                        ,input buf_dis-cfg-rule.discnt-role
                                        ,input buf_dis-cfg-rule.nonunique
                                        ,input v-host-code
                                        ,input v-obj-type
                                        ,input v-obj-code
                                        ,input 0
                                        ,input yes
                                        ,input-output v-rec
                                  ) no-error .
  IF ERROR-STATUS:ERROR THEN DO:
    if return-value = "not-set" then do:
    end.
    else do:
      message "Ошибка при определении названия и типа скидки !"         skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
    end.
    undo,  return error.
  END.
  updated = yes.
  find first buf_temp-disc no-lock where
            recid(buf_temp-disc) = v-rec no-error.
  if avail buf_temp-disc then
  temp-doc-rec = recid(buf_temp-disc).
  else temp-doc-rec = ?.
  Run init-proc in this-procedure no-error.
  if error-status:error then do:
    undo, return error.
  end.
  REPOSITION br-add to recid temp-doc-rec no-error.
  run proc-b-chg in this-procedure ( input "":U) no-error.
  if error-status:error then do:
      run temp-dsc-delete in this-procedure (
                                               input buf_dis-cfg-rule.pos-type
                                              ,input buf_dis-cfg-rule.discnt-role
                                              ,input buf_dis-cfg-rule.nonunique
                                              ,input v-host-code
                                              ,input v-obj-type
                                              ,input v-obj-code
                                              ,input yes
                                              ,output v-deleted
                                              ) no-error .
    Run init-proc in this-procedure no-error.
    undo, return error.
  end.
  APPLY "ENTRY" to br-add in frame Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE proc-b-add-2 :
define input parameter p-pos-type as character no-undo.
DEFINE VARIABLE v-deleted as logical no-undo .
define variable loc#log as logical no-undo.
define variable loc-action as logical no-undo.
define variable v-rid-list as character no-undo .
define variable dflt-cd as character no-undo .
define variable v-rule-num as integer no-undo .
define variable v-nonunique as character no-undo .
define variable v-rec as recid no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-host-code as integer no-undo .
define buffer buf_temp-disc for temp-disc.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
CASE par-subject :
  WHEN 'dis-dc-rule':U THEN DO:
    run ref/dis-pos.w ( INPUT parparentproc
                        ,INPUT "b-sel":U
                        ,INPUT "cd-type-list"
                        ,INPUT (if v-cntxt-db-num = 0 then 1 else 0)
                        ,INPUT (if v-cntxt-db-num = 0 then 1 else 0)
                        ,INPUT 1
                        ,input 'dis-dc-rule':U
                        ,input '':U
                        ,input ?
                        ,INPUT p-pos-type
                        ,input '':U
                        ,INPUT-OUTPUT v-rid-list) NO-ERROR.
    IF ERROR-STATUS:ERROR
    OR v-rid-list = '':U THEN DO:
      RETURN.
    END.
    FIND FIRST buf_dis-cfg-rule NO-LOCK where
              recid(buf_dis-cfg-rule) = INTEGER(v-rid-list).
    run set-region in this-procedure ( buffer buf_dis-cfg-rule
                                    , OUTPUT v-host-code
                                    , output v-obj-type
                                    , output v-obj-code).
    run temp-dsc-write in this-procedure (
                                            input yes
                                           ,input buf_dis-cfg-rule.pos-type
                                           ,input buf_dis-cfg-rule.templ-rl-root
                                           ,input buf_dis-cfg-rule.time-templ-rl-root
                                           ,input buf_dis-cfg-rule.discnt-role
                                           ,input buf_dis-cfg-rule.nonunique
                                           ,input v-host-code
                                           ,input v-obj-type
                                           ,input v-obj-code
                                           ,input v-rule-num
                                           ,input no
                                           ,input-output v-rec
                                               )  no-error.
     IF ERROR-STATUS:ERROR THEN DO:
      if return-value = "not-set" then do:
      end.
      else do:
        message "Ошибка при определении названия и типа скидки !"         skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
        return error.
      end.
    END.
  END.
END CASE.
updated = yes.
find first buf_temp-disc no-lock where
          recid(buf_temp-disc) = v-rec no-error .
if avail buf_temp-disc then
  temp-doc-rec = recid(buf_temp-disc).
  else temp-doc-rec = ?.
Run init-proc in this-procedure .
reposition BR-del to recid temp-doc-rec no-error.
if error-status:error then return error.
run proc-b-chg-2 in this-procedure ( input "":U) no-error.
if error-status:error then do:
    run temp-dsc-delete in this-procedure (
                                             input buf_dis-cfg-rule.pos-type
                                            ,input buf_dis-cfg-rule.discnt-role
                                            ,input buf_dis-cfg-rule.nonunique
                                            ,input v-host-code
                                            ,input v-obj-type
                                            ,input v-obj-code
                                            ,input no
                                            ,output v-deleted
                                            ) no-error .
  Run init-proc in this-procedure no-error.
  undo, return error.
end.
APPLY "ENTRY" to br-del in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-b-chg :
define input parameter p-mode as character no-undo .
define variable v-rule-num as integer no-undo .
define variable v-nonunique as character no-undo .
define variable v-rec as recid no-undo .
if not avail temp-disc then return error.
  RUN temp-dsc-VALUE IN THIS-PROCEDURE (
                                       input temp-disc.pos-type
                                      ,input temp-disc.templ-rl-root
                                      ,input temp-disc.time-templ-rl-root
                                      ,input temp-disc.discnt-role
                                      ,input temp-disc.cfg-nonunique
                                      ,input temp-disc.host-code
                                      ,input temp-disc.obj-type
                                      ,input temp-disc.obj-code
                                      ,input 'ДОБАВЛЕНИЕ':U
                                      ,input p-mode
                                      ,input recid(temp-disc)
                                      ,OUTPUT v-rule-num
                                      ,output v-nonunique
                                      ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    if return-value <> "not-set":U then do:
      message "Ошибка при определении значения скидки !"         skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
      RETURN error.
    end.
    RETURN error.
  END.
  if return-value = "not-set":U
  and p-mode <> "change":U then do:
    delete temp-disc.
    glog = br-add:refresh() in frame Dialog-Frame no-error .
    return .
  end.
  v-rec = recid(temp-disc).
  run temp-dsc-write (
                       input no
                      ,input temp-disc.pos-type
                      ,input temp-disc.templ-rl-root
                      ,input temp-disc.time-templ-rl-root
                      ,input temp-disc.discnt-role
                      ,input temp-disc.cfg-nonunique
                      ,input temp-disc.host-code
                      ,input temp-disc.obj-type
                      ,input temp-disc.obj-code
                      ,input v-rule-num
                      ,input temp-disc.action
                      ,input-output v-rec
                      ) no-error.
  IF not error-status:error then do:
    assign
    updated = yes
    .
  END.
  glog = br-add:refresh() in frame Dialog-Frame no-error .
  APPLY "ENTRY" to br-add.
END PROCEDURE.
PROCEDURE proc-b-chg-2 :
define input parameter p-mode as character no-undo .
define variable v-rule-num as integer no-undo .
define variable v-nonunique as character no-undo .
define variable v-rec as recid no-undo .
if not avail del_temp-disc then return error.
  RUN temp-dsc-VALUE IN THIS-PROCEDURE (
                                       input del_temp-disc.pos-type
                                      ,input del_temp-disc.templ-rl-root
                                      ,input del_temp-disc.time-templ-rl-root
                                      ,input del_temp-disc.discnt-role
                                      ,input del_temp-disc.cfg-nonunique
                                      ,input del_temp-disc.host-code
                                      ,input del_temp-disc.obj-type
                                      ,input del_temp-disc.obj-code
                                      ,input 'удаление':U
                                      ,input p-mode
                                      ,input recid(del_temp-disc)
                                      ,OUTPUT v-rule-num
                                      ,output v-nonunique
                                      ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    if return-value <> "not-set":U then do:
      message "Ошибка при определении значения скидки !"         skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
      RETURN error.
    end.
    RETURN error.
  END.
  if return-value = "not-set":U
  and p-mode <> "change":U then do:
    delete del_temp-disc.
    glog = br-del:refresh() in frame Dialog-Frame no-error .
    return .
  end.
  v-rec = recid(del_temp-disc).
  run temp-dsc-write (
                       input no
                      ,input del_temp-disc.pos-type
                      ,input del_temp-disc.templ-rl-root
                      ,input del_temp-disc.time-templ-rl-root
                      ,input del_temp-disc.discnt-role
                      ,input del_temp-disc.cfg-nonunique
                      ,input del_temp-disc.host-code
                      ,input del_temp-disc.obj-type
                      ,input del_temp-disc.obj-code
                      ,input v-rule-num
                      ,input del_temp-disc.action
                      ,input-output v-rec
                      ) no-error.
  IF not error-status:error then do:
    assign
    updated = yes
    .
  END.
  glog = br-del:refresh() in frame Dialog-Frame no-error .
  APPLY "ENTRY" to br-del.
END PROCEDURE.
PROCEDURE proc-b-exit :
define variable loc#log as logical no-undo .
define variable v-not-all-ok as logical no-undo .
define variable v-host-code as integer no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_temp-disc for temp-disc.
if not can-find(first temp-disc) then do:
    message "Вы не определили список скидок для изменения (добавления, удаления)"
    view-as alert-box.
    return no-apply.
end.
ASSIGN
FRAME Dialog-Frame t-delete-ok.
CASE par-subject:
  when 'dis-dc-rule':U then do:
    if not can-find(first dc-list) then do:
      message "Вы не определили список ДК"
      view-as alert-box.
      return no-apply.
    end.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    for each buf_temp-disc:
      if buf_temp-disc.action = yes then do:
        find first buf_dis-rule no-lock where
                  buf_Dis-rule.rule-num = buf_temp-disc.rule-num no-error.
        if not available buf_dis-rule
        or (buf_Dis-rule.obj-code > 0
        and not (
                buf_dis-rule.obj-type = p-obj-type
                and
                buf_dis-rule.obj-code = p-obj-code)
              )
        or (buf_Dis-rule.host-code > 0
        and not (
                buf_dis-rule.host-code = v-host-code)
              )
        or not (buf_dis-rule.sts = integer('0':U)) then do:
              if buf_dis-rule.obj-code > 0 then do:
            message
            substitute("&1 &2&3: значение кода правила скидки должно указывать&4" +
                        "на существующее правило в статусе &5 и принадлежащее &2&3"
                        ,entry (lookup (buf_temp-disc.discnt-role, 'debet-pay-pcnt-disc,debet-pay-abs-disc,debet-pay-qnty-disc,debet-pay-sum-disc,debet-pay-free-disc,dc-d-pcnt,dc-cash-d-pcnt,credit-pay-pcnt-disc,credit-pay-abs-disc,credit-pay-qnty-disc,credit-pay-sum-disc,credit-pay-free-disc':u) + 1, ',' + '% Скидка при оплате топлива по дебет.ведомости,ABS Скидка при оплате топлива по дебет.ведомости,Скидка на кол-во при оплате топлива по дебет.ведомости,Скидка на сумму при оплате топлива по дебет.ведомости,Своб скидка при оплате топлива по дебет.ведомости,% скидка на товар по ДК,% скидка на итог чека по ДК,% Скидка при оплате топлива по кредит.ведомости,Abs Скидка при оплате топлива по кредит.ведомости,Скидка на кол-во при оплате топлива по кредит.ведомости,Скидка на сумму при оплате топлива по кредит.ведомости,Своб Скидка на сумму при оплате топлива по кредит.ведомости':u)
                        ,p-obj-type
                        ,p-obj-code
                        ,chr(10)
                        ,entry (lookup ('0':U, '0,1,50,99':U), 'тек,удал,блок,удаление':U)
                        )
            view-as alert-box error .
            undo, return error .
          end.
          else do:
            message
            substitute("&1 фирма &2: значение кода правила скидки должно указывать&3" +
                        "на существующее правило в статусе &4 и принадлежащее фирме &2"
                        ,entry (lookup (buf_temp-disc.discnt-role, 'debet-pay-pcnt-disc,debet-pay-abs-disc,debet-pay-qnty-disc,debet-pay-sum-disc,debet-pay-free-disc,dc-d-pcnt,dc-cash-d-pcnt,credit-pay-pcnt-disc,credit-pay-abs-disc,credit-pay-qnty-disc,credit-pay-sum-disc,credit-pay-free-disc':u) + 1, ',' + '% Скидка при оплате топлива по дебет.ведомости,ABS Скидка при оплате топлива по дебет.ведомости,Скидка на кол-во при оплате топлива по дебет.ведомости,Скидка на сумму при оплате топлива по дебет.ведомости,Своб скидка при оплате топлива по дебет.ведомости,% скидка на товар по ДК,% скидка на итог чека по ДК,% Скидка при оплате топлива по кредит.ведомости,Abs Скидка при оплате топлива по кредит.ведомости,Скидка на кол-во при оплате топлива по кредит.ведомости,Скидка на сумму при оплате топлива по кредит.ведомости,Своб Скидка на сумму при оплате топлива по кредит.ведомости':u)
                        ,v-host-code
                        ,chr(10)
                        ,entry (lookup ('0':U, '0,1,50,99':U), 'тек,удал,блок,удаление':U)
                        )
            view-as alert-box error .
            undo, return error .
          end.
        end.
      end.
    end.
    message
    "Вы уверены, что Вы хотите провести изменение (добавление, удаление) скидок по отдельным ДК" SKIP
    "всего определенного Вами списка?"
    view-as alert-box QUESTION buttons YES-NO update loc#log.
    if loc#log then do:
      run str/diallog.w (
              input parparentproc
            , input this-procedure
            , input "ref/ddcr-lst.p":U
            , input (string(p-host-code) + chr(4) + p-obj-type + chr(4) + string(p-obj-code) + chr(4) + string(t-delete-ok))
            , input no
            , input "&Стоп":U
            , input substitute("Изменение скидок на отдельные ДК (фирма &1 объект &2&3) по списку ДК"
                                , p-host-code
                                , p-obj-type
                                , p-obj-code
                                )
        ) no-error.
      assign
      v-not-all-ok = can-find(first dc-list).
    end.
  end.
END CASE.
if v-not-all-ok and t-delete-ok then do:
  assign
  b-list:width = 30
  b-list:label = "Список неизменившихся".
end.
END PROCEDURE.
PROCEDURE proc-b-obj :
define variable v-user-select as logical   no-undo .
define variable v-obj-type    as character no-undo .
define variable v-obj-code    as integer   no-undo .
define variable v-host-code as integer   no-undo .
define buffer buf_clients-obj for ub.clients.
define buffer buf_temp-disc for temp-disc.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output v-user-select
  ,output v-obj-type
  ,output v-obj-code
  )  .
if v-user-select <> true
then do:
  message
  "Объект не выбран"
  view-as alert-box information .
  undo, return error return-value .
end.
find first buf_clients-obj no-lock
  where buf_clients-obj.obj-type = v-obj-type
    and buf_clients-obj.obj-code = v-obj-code
    no-error.
if not avail buf_clients-obj
then do:
  message
    "Не найден объект!" skip
    view-as alert-box error.
  return no-apply.
end.
find first X_clients-obj no-lock where recid(X_clients-obj) = recid(buf_clients-obj).
assign
p-obj-type =  X_clients-obj.obj-type
p-obj-code = X_clients-obj.obj-code
RS-obj-type = X_clients-obj.obj-type
f-obj-code = X_clients-obj.obj-code
f-obj-name  = X_clients-obj.obj-name
.
display
rs-obj-type
f-obj-code
f-obj-name
with frame Dialog-Frame.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
for each buf_temp-disc :
  if (buf_temp-disc.obj-type = 'маг':U
  or buf_temp-disc.obj-type = 'скл':U )
  and not (buf_temp-disc.obj-type = p-obj-type
           and
           buf_temp-disc.obj-code = p-obj-code)
  then do:
    delete buf_temp-disc.
    next.
  end.
  if buf_temp-disc.host-code <> v-host-code then delete buf_temp-disc.
end.
RUN proc-title IN THIS-PROCEDURE.
OPEN QUERY BR-add FOR EACH temp-disc where temp-disc.action = yes NO-LOCK.    OPEN QUERY BR-del FOR EACH del_temp-disc where del_temp-disc.action = no NO-LOCK.
END PROCEDURE.
PROCEDURE proc-title :
IF p-obj-type = 'маг':U THEN DO:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type26 as character no-undo .
define variable v-value-date26 as date no-undo .
define variable v-value-decimal26 as decimal no-undo .
define variable v-value-integer26 as INTEGER no-undo .
define variable v-value-logical26 AS LOGICAL no-undo .
define variable v-tth26 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date26
    ,output v-value-decimal26
    ,output v-value-integer26
    ,output v-value-logical26
    ,output v-param-type26
    ,INPUT-OUTPUT table-handle v-tth26
    )  .
delete object v-tth26 no-error.
END.
if p-obj-type = 'скл':U then do:
  dflt-cd = '-':U.
end.
ASSIGN
MENU-ITEM m_pos-type:LABEL IN MENU menu-b-add  = dflt-cd
MENU-ITEM m_pos-type:sensitive IN MENU menu-b-add  = ((dflt-cd <> '':U) and (dflt-cd <> '-':U))
MENU-ITEM m_pos-type-2:LABEL IN MENU menu-b-add-2  = dflt-cd
MENU-ITEM m_pos-type-2:sensitive IN MENU menu-b-add-2  = ((dflt-cd <> '':U) and (dflt-cd <> '-':U))
.
CASE par-subject:
  WHEN 'dis-dc-rule':U THEN DO:
    frame Dialog-Frame:title = substitute("Изменение скидок на отдельные ДК &1&2 по списку ДК"
                                          ,p-obj-type
                                          ,p-obj-code) .
    assign
    v-tab-order = "b-exit,b-quit,b-list,b-help,rs-obj-type,f-obj-code,b-obj,T-delete-ok,b-add,b-add-2".
  END.
END CASE.
APPLY "ENTRY" TO b-add IN FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-write :
END PROCEDURE.
PROCEDURE set-region :
DEFINE PARAMETER BUFFER buf_dis-cfg-rule FOR ub.dis-cfg-rule.
DEFINE OUTPUT PARAMETER v-host-code AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER v-obj-type AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER v-obj-code AS integer NO-UNDO.
define variable v-sel-vals as character no-undo .
define variable v-sel-labels as character no-undo .
define variable var-region as character no-undo .
  if (buf_dis-cfg-rule.has-global +
      buf_dis-cfg-rule.has-host +
      buf_dis-cfg-rule.has-obj) > 1 then do:
    assign
    v-sel-vals = v-sel-vals +
                  (if buf_dis-cfg-rule.has-global = 1
                  then (fill(chr(32), 3)  + string(0) + chr(44))
                  else "":U)
    v-sel-labels = v-sel-labels +
                  (if buf_dis-cfg-rule.has-global  = 1
                  then ("Глобально" + chr(44))
                  else "":U)
    .
    assign
    v-sel-vals = v-sel-vals +
                  (if buf_dis-cfg-rule.has-host = 1
                  then ('орг':U  + string(v-cntxt-host-code-obj)  + chr(44))
                  else "":U)
    v-sel-labels = v-sel-labels +
                  (if buf_dis-cfg-rule.has-host = 1
                  then ("Фирма"  + string(v-cntxt-host-code-obj) + chr(44))
                  else "":U)
    .
    assign
    v-sel-vals = v-sel-vals +
                  (if buf_dis-cfg-rule.has-obj = 1
                  then (v-cntxt-obj-type  + string(v-cntxt-obj-code)  + chr(44))
                  else "":U)
    v-sel-labels = v-sel-labels +
                  (if buf_dis-cfg-rule.has-obj = 1
                  then (v-cntxt-obj-type  + string(v-cntxt-obj-code)  + chr(44))
                  else "":U)
    .
    run gbl/d-list.w (
                        input "b-sel":U
                        ,input "Выберите область действия"
                        ,input v-sel-vals
                        ,input v-sel-labels
                        ,input chr(44)
                        ,input "":U
                        ,output var-region) no-error.
    if error-status:error then do:
      return error.
    end.
    assign
    v-obj-type = substring(var-region, 1, 3)
    v-obj-code = integer(substring(var-region, 4))
    v-host-code = (IF v-obj-type = "" THEN 0 ELSE v-obj-code)
    v-obj-code = (IF v-obj-type = 'маг':U
                   OR v-obj-type = 'скл':U
                   THEN p-obj-code
                   ELSE 0)
    v-obj-type = (IF v-obj-type = 'маг':U
                   OR v-obj-type = 'скл':U
                   THEN p-obj-type
                   ELSE '':U)
    .
  end.
  else do:
    if buf_dis-cfg-rule.has-obj = 1 then do:
      assign
      v-obj-type = p-obj-type
      v-obj-code = p-obj-code
      .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    end.
    if buf_dis-cfg-rule.has-host = 1 then do:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
      assign
      v-obj-type = "":U
      v-obj-code = 0
      .
    end.
    if buf_dis-cfg-rule.has-glob = 1 then do:
      assign
      v-host-code = 0
      v-obj-type = '':U
      v-obj-code = 0
      .
    end.
  end.
END PROCEDURE.
FUNCTION dis-dc-rule-name RETURNS CHARACTER
  ( INPUT p-discnt-role AS character ) :
DEFINE variable v-dis-dc-rule-name AS CHARACTER NO-UNDO.
v-dis-dc-rule-name = entry (lookup (p-discnt-role, 'debet-pay-pcnt-disc,debet-pay-abs-disc,debet-pay-qnty-disc,debet-pay-sum-disc,debet-pay-free-disc,dc-d-pcnt,dc-cash-d-pcnt,credit-pay-pcnt-disc,credit-pay-abs-disc,credit-pay-qnty-disc,credit-pay-sum-disc,credit-pay-free-disc':u) + 1, ',' + '% Скидка при оплате топлива по дебет.ведомости,ABS Скидка при оплате топлива по дебет.ведомости,Скидка на кол-во при оплате топлива по дебет.ведомости,Скидка на сумму при оплате топлива по дебет.ведомости,Своб скидка при оплате топлива по дебет.ведомости,% скидка на товар по ДК,% скидка на итог чека по ДК,% Скидка при оплате топлива по кредит.ведомости,Abs Скидка при оплате топлива по кредит.ведомости,Скидка на кол-во при оплате топлива по кредит.ведомости,Скидка на сумму при оплате топлива по кредит.ведомости,Своб Скидка на сумму при оплате топлива по кредит.ведомости':u).
RETURN v-dis-dc-rule-name.
END FUNCTION.
