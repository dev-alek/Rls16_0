DEFINE BUFFER X_clients-obj FOR ub.clients.
DEFINE TEMP-TABLE temp-clients  NO-UNDO LIKE ub.clients.
DEFINE TEMP-TABLE temp-dis-rule NO-UNDO LIKE ub.dis-rule
       field old-des as character.
DEFINE TEMP-TABLE temp-cpdisc NO-UNDO LIKE ub.dis-cp-rule
       field rule-label as character.
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-subject as character no-undo.
define input parameter p-host-code like ub.dis-cp-rule.host-code no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Установка/удаление скидок по видам кассовых платежей".
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
  case 'dis-cp-rule':U:
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
  CASE 'dis-cp-rule':U:
    when 'dis-cp-rule':U then do:
      if p-0mode = 'удаление':U then do:
        run gbl/d-askw.w (   input "Вопрос"
                            ,input "Вы хотите удалить скидки"
                            ,input "|"
                            ,input "Конкретная|Все ТАКИЕ|Отмена"
                            ,input "по одному КОНКРЕТНОМУ правилу|СКИДКИ НА ПЛАТЕЖ ЭТОГО ТИПА ПО ЭТОМУ ШАБЛОНУ|Ничего не делать"
                            ,input 1
                            ,input 3
                            ,output choice).
    end.
    else do:
      choice = 1.
    end.
    if choice = 3
    then do:
      undo, return "not-set".
    end.
    if choice = 2 then do:
       v-rule-num = ?.
       v-setted = yes.
     end.
     else do:
      run discpru-edit in this-procedure (
                                       input 'ИЗМЕНЕНИЕ':U
                                      ,input 0
                                      ,input 0
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
        undo, return error substitute("Ошибка при получения значения скидки по платежу:&1" +
                                      "место использ. &2 тип скидки &3"
                                      , chr(10)
                                      , p-pos-type
                                      , entry (lookup (p-discnt-role, 'simple-pay,qnty-pay':u) + 1, ',' + 'Скидка при оплате,Скидка на количество при оплате':u)).
        end.
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
    case 'dis-cp-rule':U:
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
    case 'dis-cp-rule':U:
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
    case 'dis-cp-rule':U:
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
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure discpru-name :
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
    p-label = substitute("Неизвестный шаблон правила скидки &1", p-templ-rl-root).
  end.
end.
end procedure.
function discpru-get-disc-label returns character ( input p-templ-rl-root as integer):
define variable v-rule-label as character no-undo .
run discpru-name in this-procedure ( input p-templ-rl-root
                                     ,output v-rule-label) no-error.
return v-rule-label.
end function.
function discpru-get-disc-role-label returns character ( input p-discnt-role as character):
define variable v-rule-label as character no-undo .
return entry (lookup (p-discnt-role, 'simple-pay,qnty-pay':u) + 1, ',' + 'Скидка при оплате,Скидка на количество при оплате':u).
end function.
procedure discpru-write :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code     like ub.dis-cp-rule.cdpay-code  no-undo .
    define input parameter p-curr-code      like ub.dis-cp-rule.curr-code  no-undo .
    define input parameter p-host-code      like ub.dis-cp-rule.host-code   no-undo .
    define input parameter p-obj-type       like ub.dis-cp-rule.obj-type   no-undo .
    define input parameter p-obj-code       like ub.dis-cp-rule.obj-code   no-undo .
    define input parameter p-pos-type       like ub.dis-cp-rule.pos-type   no-undo .
    define input parameter p-discnt-role    like ub.dis-cp-rule.discnt-role no-undo .
    define input parameter p-templ-rl-root  like ub.dis-cp-rule.templ-rl-root  no-undo .
    define input parameter p-time-templ-rl-root  like ub.dis-cp-rule.time-templ-rl-root  no-undo .
    define input parameter p-rule-num       like ub.dis-cp-rule.rule-num    no-undo .
    define input parameter p-nonunique      like ub.dis-cp-rule.nonunique   no-undo .
    define buffer buf_dis-rule for ub.dis-rule.
    define buffer buf_dis-cp-rule for ub.dis-cp-rule .
    define buffer lock_dis-cp-rule for ub.dis-cp-rule .
    define variable v-label          as character no-undo .
    define variable v-discnt-role as character no-undo .
    run discfgru-check in this-procedure (
                                          input 'dis-cp-rule':U
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
      undo, return error substitute("Тип платежа &1 код валюты &2 фирма &3 &4 место использ. &5 скидка типа &6&7не может быть по шаблону &8 и расписанию &9"
                              ,p-cdpay-code
                              ,p-curr-code
                              ,p-host-code
                              ,(p-obj-type + string(p-obj-code))
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'simple-pay,qnty-pay':u) + 1, ',' + 'Скидка при оплате,Скидка на количество при оплате':u)
                              ,chr(10)
                              ,p-templ-rl-root
                              ,p-rule-num).
    end.
    if p-pos-type = ? then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type8 as character no-undo .
define variable v-value-date8 as date no-undo .
define variable v-value-decimal8 as decimal no-undo .
define variable v-value-integer8 as INTEGER no-undo .
define variable v-value-logical8 AS LOGICAL no-undo .
define variable v-tth8 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output p-pos-type
    ,output v-value-date8
    ,output v-value-decimal8
    ,output v-value-integer8
    ,output v-value-logical8
    ,output v-param-type8
    ,INPUT-OUTPUT table-handle v-tth8
    )  .
delete object v-tth8 no-error.
    end.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-rule-num no-error.
    if not available buf_Dis-rule then do:
      undo, return error substitute("Тип платежа &1 код валюты &2 фирма &3 &4 место использ. &5 скидка типа &6&7не найдено правило скидки &8"
                              ,p-cdpay-code
                              ,p-curr-code
                              ,p-host-code
                              ,(p-obj-type + string(p-obj-code))
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'simple-pay,qnty-pay':u) + 1, ',' + 'Скидка при оплате,Скидка на количество при оплате':u)
                              ,chr(10)
                              ,p-rule-num).
    end.
    if buf_dis-rule.root <> yes then do:
      undo, return error substitute("Тип платежа &1 код валюты &2 фирма &3 &4 место использ. &5 скидка типа &6&7правило скидки &8 - некорневое"
                              ,p-cdpay-code
                              ,p-curr-code
                              ,p-host-code
                              ,(p-obj-type + string(p-obj-code))
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'simple-pay,qnty-pay':u) + 1, ',' + 'Скидка при оплате,Скидка на количество при оплате':u)
                              ,chr(10)
                              ,p-rule-num).
    end.
    if not (p-obj-type = buf_dis-rule.obj-type
        and p-obj-code = buf_dis-rule.obj-code) then do:
      undo, return error (substitute("Тип платежа &1 код валюты &2 фирма &3 &4 место использ. &5 скидка типа &6&7правило скидки &8"
                              ,p-cdpay-code
                              ,p-curr-code
                              ,p-host-code
                              ,(p-obj-type + string(p-obj-code))
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'simple-pay,qnty-pay':u) + 1, ',' + 'Скидка при оплате,Скидка на количество при оплате':u)
                              ,chr(10)
                              ,p-rule-num)
                          +
                          substitute("Правило скидки &1 определено для &1&2" +
                                     "а привязка к ДК для &3"
                                     ,get-region( buf_Dis-rule.host-code, buf_dis-rule.obj-type, buf_Dis-rule.obj-code)
                                     ,chr(10)
                                     ,get-region( p-host-code, p-obj-type, p-obj-code)
                                     ))
                              .
    end.
    find first buf_dis-cp-rule exclusive-lock where
               buf_dis-cp-rule.cdpay-code  = p-cdpay-code
           AND buf_dis-cp-rule.curr-code  = p-curr-code
           AND buf_dis-cp-rule.obj-type  = p-obj-type
           AND buf_dis-cp-rule.host-code = p-host-code
           AND buf_dis-cp-rule.obj-code  = p-obj-code
           AND buf_dis-cp-rule.pos-type  = p-pos-type
           AND buf_dis-cp-rule.discnt-role = p-discnt-role
           and buf_dis-cp-rule.nonunique = p-nonunique
           no-error .
    if not available buf_dis-cp-rule then do:
      create buf_dis-cp-rule .
      assign
      buf_dis-cp-rule.cdpay-code  = p-cdpay-code
      buf_dis-cp-rule.curr-code  = p-curr-code
      buf_dis-cp-rule.host-code  = p-host-code
      buf_dis-cp-rule.obj-type  = p-obj-type
      buf_dis-cp-rule.obj-code  = p-obj-code
      buf_dis-cp-rule.pos-type = p-pos-type
      buf_dis-cp-rule.discnt-role = v-discnt-role
      buf_dis-cp-rule.rule-num = p-rule-num
      buf_dis-cp-rule.nonunique = p-nonunique
      no-error
      .
    end.
    ASSIGN
    buf_dis-cp-rule.rule-num = p-rule-num
    buf_dis-cp-rule.rl-root = buf_Dis-rule.rl-root
    buf_dis-cp-rule.templ-rl-root = p-templ-rl-root
    buf_dis-cp-rule.time-templ-rl-root = p-time-templ-rl-root
    buf_dis-cp-rule.nonunique = p-nonunique
    no-error.
  end.
end procedure.
procedure discpru-delete :
define input parameter p-cdpay-code     like ub.dis-cp-rule.cdpay-code  no-undo .
define input parameter p-curr-code      like ub.dis-cp-rule.curr-code  no-undo .
define input parameter p-host-code      like ub.dis-cp-rule.host-code   no-undo .
define input parameter p-obj-type       like ub.dis-cp-rule.obj-type   no-undo .
define input parameter p-obj-code       like ub.dis-cp-rule.obj-code   no-undo .
define input parameter p-pos-type       like ub.dis-cp-rule.pos-type   no-undo .
define input parameter p-discnt-role    like ub.dis-cp-rule.discnt-role no-undo .
define input parameter p-nonunique      like ub.dis-cp-rule.nonunique   no-undo .
define output parameter p-deleted       as logical no-undo .
define variable v-rule-label as character no-undo .
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
do
on error undo, return error
:
find first buf_dis-cp-rule exclusive-lock where
            buf_dis-cp-rule.cdpay-code  = p-cdpay-code
        AND buf_dis-cp-rule.curr-code  = p-curr-code
        AND buf_dis-cp-rule.obj-type  = p-obj-type
        AND buf_dis-cp-rule.host-code = p-host-code
        AND buf_dis-cp-rule.obj-code  = p-obj-code
        AND buf_dis-cp-rule.pos-type  = p-pos-type
        AND buf_dis-cp-rule.discnt-role = p-discnt-role
        and buf_dis-cp-rule.nonunique = p-nonunique
        no-error .
if not available buf_dis-cp-rule then do:
  return '':U.
end.
delete buf_dis-cp-rule no-error.
if error-status:error then do:
  run discpru-name in this-procedure
    (input  buf_dis-cp-rule.templ-rl-root
    ,output v-rule-label
    ) no-error .
  undo, return error substitute("Ошибка при удалении скидки по типу касс. платежа:&1" +
                               "скидка &2 (POS &3) на фирме &4 &5&6 для платежа&1&7&1&8"
                                ,chr(10)
                                ,v-rule-label
                                ,p-pos-type
                                ,p-host-code
                                ,p-obj-type
                                ,p-obj-code
                                ,error-status:get-message(1)
                                ,return-value ).
end.
p-deleted = yes.
return '':U.
end.
end procedure.
procedure discpru-edit :
define input parameter p-mode as character no-undo .
define input parameter p-cdpay-code   like ub.dis-cp-rule.cdpay-code no-undo .
define input parameter p-curr-code   like ub.dis-cp-rule.curr-code no-undo .
define input parameter p-host-code like ub.dis-cp-rule.host-code no-undo .
define input parameter p-obj-type like ub.dis-cp-rule.obj-type no-undo .
define input parameter p-obj-code like ub.dis-cp-rule.obj-code no-undo .
define input parameter p-pos-type like ub.dis-cp-rule.pos-type no-undo .
define input parameter p-discnt-role    like ub.dis-cp-rule.discnt-role no-undo .
define input parameter p-templ-rl-root like ub.dis-cp-rule.templ-rl-root no-undo .
define input parameter p-time-templ-rl-root like ub.dis-cp-rule.time-templ-rl-root no-undo .
define input parameter p-cfg-NONUNIQUE as character no-undo .
define input parameter p-check as integer no-undo .
define input-output parameter p-rule-num as integer no-undo .
define input-output parameter p-nonunique as character no-undo .
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
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_temp-cpdisc for temp-cpdisc.
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
  run discpru-name in this-procedure (
                                input p-templ-rl-root
                                ,output v-label) no-error.
if p-pos-type = ?
or p-pos-type = '':U then do:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type9 as character no-undo .
define variable v-value-date9 as date no-undo .
define variable v-value-decimal9 as decimal no-undo .
define variable v-value-integer9 as INTEGER no-undo .
define variable v-value-logical9 AS LOGICAL no-undo .
define variable v-tth9 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date9
    ,output v-value-decimal9
    ,output v-value-integer9
    ,output v-value-logical9
    ,output v-param-type9
    ,INPUT-OUTPUT table-handle v-tth9
    )  .
delete object v-tth9 no-error.
end.
else do:
  dflt-cd = p-pos-type.
end.
v-mode =  'dis-cp-rule':U + "=" + p-discnt-role + "=" + (if p-host-code = 0
                                                             then "global"
                                                             else (if p-obj-type = ''
                                                                  then "host"
                                                                  else "object")
                                                             ) .
run ref/dis-ruls.w (
            input parparentproc
            ,input p-host-code
            ,input p-obj-type
            ,input p-obj-code
            ,input "b-add,b-sel":U
            ,input "upper-rule-num-object":u
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
      "Нельзя привязать к нему скидку на платеж"
      view-as alert-box error .
      return .
    end.
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
        and buf_dis-cfg-rule.time-templ-rl-root = (if buf_dis-rule.time-templ-rl-root = -1
                                                   then 0
                                                   else buf_dis-rule.time-templ-rl-root)
        and buf_dis-cfg-rule.table-name = 'dis-cp-rule':U
        and buf_dis-cfg-rule.pos-type = dflt-cd no-error.
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
      find first buf_dis-cp-rule no-lock where
                 buf_dis-cp-rule.host-code = p-host-code
              and buf_dis-cp-rule.obj-type = p-obj-type
              and buf_dis-cp-rule.obj-code = p-obj-code
              and buf_dis-cp-rule.curr-code = p-curr-code
              and buf_dis-cp-rule.cdpay-code = p-cdpay-code
              and buf_dis-cp-rule.pos-type = p-pos-type
              and buf_dis-cp-rule.discnt-role = p-discnt-role
              and buf_dis-cp-rule.nonunique = v-nonunique no-error .
      if available buf_dis-cp-rule
      and p-mode <> 'ИЗМЕНЕНИЕ':U
      then do:
        message
        "Скидка такого типа на данный тип платежа уже существует"
        view-as alert-box error .
        return error.
      end.
    end.
    if p-check = 1
    or p-check = 2
    then do:
      find first buf_temp-cpdisc no-lock where
                 buf_temp-cpdisc.host-code = p-host-code
              and buf_temp-cpdisc.obj-type = p-obj-type
              and buf_temp-cpdisc.obj-code = p-obj-code
              and buf_temp-cpdisc.cdpay-code = p-cdpay-code
              and buf_temp-cpdisc.curr-code = p-curr-code
              and buf_temp-cpdisc.pos-type = p-pos-type
              and buf_temp-cpdisc.discnt-role = p-discnt-role
              and buf_temp-cpdisc.nonunique = v-nonunique no-error .
      if available buf_temp-cpdisc
      and buf_temp-cpdisc.rule-num <> 0
      and p-mode <> 'ИЗМЕНЕНИЕ':U
      then do:
        message
      "Скидка такого типа на данный тип платежа уже существует"
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-b-code :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter p-b-code  like ub.bar-code.b-code       no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-b-code). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-b-code). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-b-code). endkey", vss-workfile )
  :
    define buffer buf_thbj-attr     for ub.thbj-attr .
    define buffer buf_sys-ctrl   for ub.sys-ctrl .
    define buffer buf_code-range for ub.code-range .
    define variable l-code         as   integer              no-undo .
    define variable v-db-num       like ub.db.db-num         no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .
    if type-code = 'sslc':U
    or type-code = 'ssgb':U
    then do:
      message
        "Нельзя генерировать локальный или глобальный взвешиваемый код." skip
        "Обратитесь к администратору системы."
        view-as alert-box error .
      undo, return error (if type-code = 'sslc':U then "loc-ss-code":U else "gbl-ss-code" ) .
    end.
    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    run get-next-seq( input  type-code,
                      output l-code
                    ).
    find first buf_sys-ctrl no-lock.
    if type-code = 'sclc':U
    or type-code = 'pglc':U
    then do:
      assign
        v-db-num = 0
      .
    end.
    else do:
      assign
        v-db-num = buf_sys-ctrl.db-num
      .
    end.
    find first buf_code-range no-lock
      where buf_code-range.db-num     = v-db-num
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "a"
      use-index stts
      no-error .
    if available buf_code-range
       and l-code <= buf_code-range.last-code
       and l-code >= buf_code-range.first-code then do:
      assign
        p-b-code = l-code
      .
    end.
    else do:
      if available buf_code-range
         and l-code < buf_code-range.last-code then do:
        message
          substitute( "Последовательность для создания кодов с типом &1 имеет неверное значение.", type-code ) skip
          "Обратитесь к администратору системы."
          view-as alert-box error .
        undo, return error "sequence":U .
      end.
      do transaction
      on error undo, return error
      :
        find first buf_thbj-attr exclusive-lock
          where buf_thbj-attr.upper-prop-code = 'code-range':U
            and buf_thbj-attr.prop-code = cfg-param-code
            and buf_thbj-attr.obj-type   = 'БД':U
            and buf_thbj-attr.obj-code   = v-db-num
          no-error .
        if not available buf_thbj-attr then do:
          find first buf_thbj-attr exclusive-lock
            where buf_thbj-attr.upper-prop-code = 'code-range':U
              and buf_thbj-attr.prop-code = cfg-param-code
              and buf_thbj-attr.obj-type   = ''
              and buf_thbj-attr.obj-code   = 0
            no-error .
          if not available buf_thbj-attr then do:
            if not locked buf_thbj-attr then do:
              message
                substitute( "Отсутствует параметр 'длина диапазона кодов' (&1) для БД &2.", cfg-param-code, buf_sys-ctrl.db-num ) skip
                "Обратитесь к администратору системы."
                view-as alert-box error .
            end.
            undo, return error "config":U .
          end.
        end.
        run get-next-seq( input type-code,
                          output l-code
                        ).
        find first buf_code-range
          where buf_code-range.db-num     = v-db-num
            and buf_code-range.range-type = type-code
            and buf_code-range.stts       = "a"
          use-index stts
          no-error .
        if available buf_code-range
        and l-code <= buf_code-range.last-code
        and l-code >= buf_code-range.first-code
        then do:
          assign
            p-b-code = l-code
          .
        end.
        else do:
          if available buf_code-range then do:
            assign
              buf_code-range.stts = "u"
            .
          end.
          find first buf_code-range
            where buf_code-range.db-num     = v-db-num
              and buf_code-range.range-type = type-code
              and buf_code-range.stts       = "f"
            use-index stts
            no-error .
          if not available buf_code-range then do:
            message
              substitute( "Отсутствует свободный диапазон для кодов с типом &1.", type-code ) skip
              "Обратитесь к администратору системы"
              view-as alert-box error .
            undo, return error "code-range":U .
          end.
          assign
            buf_code-range.stts           = "a"
          .
          if buf_code-range.first-code = 1 then do:
            run set-seq-cr( input type-code,
                            input buf_code-range.first-code
                          ).
            assign
              p-b-code = 1
            .
          end.
          else do:
            run set-seq-cr( input type-code,
                            input ( buf_code-range.first-code - 1 )
                          ).
            run get-next-seq( input type-code,
                              output p-b-code
                            ).
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure get-next-seq :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter next-seq  as   integer                  no-undo .
  do
  on error  undo, return error substitute( "&1 (get-next-seq). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-next-seq). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-next-seq). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          next-seq = next-value(s-bcgb-code, ub)
        .
      end.
      when 'scgb':U then do:
        assign
          next-seq = next-value(s-scgb-code, ub)
        .
      end.
      when 'sclc':U then do:
        assign
          next-seq = next-value(s-sclc-code, ub)
        .
      end.
      when 'pglc':U then do:
        assign
          next-seq = next-value(s-pglc-code, ub)
        .
      end.
      when 'dcgb':U then do:
        assign
          next-seq = next-value(s-dcgb-code, ub)
        .
      end.
      when 'ctgb':U then do:
        assign
          next-seq = next-value(s-ctgb-code, ub)
        .
      end.
      when 'drgb':U then do:
        assign
          next-seq = next-value(s-drgb-code, ub)
        .
      end.
      when 'fmgb':U then do:
        assign
          next-seq = next-value(s-fmgb-code, ub)
        .
      end.
      when 'pngb':U then do:
        assign
          next-seq = next-value(s-pngb-code, ub)
        .
      end.
      when 'cagb':U then do:
        assign
          next-seq = next-value(s-cagb-code, ub)
        .
      end.
      when 'fdgb':U then do:
        assign
          next-seq = next-value(s-fin-doc, ub)
        .
      end.
    end case.
  end.
end procedure.
procedure set-seq-cr :
  define input parameter type-code like ub.code-range.range-type no-undo .
  define input parameter set-val   like ub.code-range.first-code no-undo .
  do
  on error  undo, return error substitute( "&1 (set-seq-cr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (set-seq-cr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (set-seq-cr). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          current-value(s-bcgb-code, ub) = set-val
        .
      end.
      when 'scgb':U then do:
        assign
          current-value(s-scgb-code, ub) = set-val
        .
      end.
      when 'sclc':U then do:
        assign
          current-value(s-sclc-code, ub) = set-val
        .
      end.
      when 'pglc':U then do:
        assign
          current-value(s-pglc-code, ub) = set-val
        .
      end.
      when 'dcgb':U then do:
        assign
          current-value(s-dcgb-code, ub) = set-val
        .
      end.
      when 'ctgb':U then do:
        assign
          current-value(s-ctgb-code, ub) = set-val
        .
      end.
      when 'drgb':U then do:
        assign
          current-value(s-drgb-code, ub) = set-val
        .
      end.
      when 'fmgb':U then do:
        assign
          current-value(s-fmgb-code, ub) = set-val
        .
      end.
      when 'pngb':U then do:
        assign
          current-value(s-pngb-code, ub) = set-val
        .
      end.
      when 'cagb':U then do:
        assign
          current-value(s-cagb-code, ub) = set-val
        .
      end.
      when 'fdgb':U then do:
        assign
          current-value(s-fin-doc, ub) = set-val
        .
      end.
    end case.
  end.
end procedure.
procedure new-bcod-gen-code-range :
  do
  on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
  :
    define input parameter p-db-num  like ub.db.db-num             no-undo .
    define input parameter type-code like ub.code-range.range-type no-undo .
    define buffer buf_code-range      for ub.code-range .
    define buffer last_code-range     for ub.code-range .
    define buffer last-1_code-range   for ub.code-range .
    define buffer last-2_code-range   for ub.code-range .
    define buffer last-3_code-range   for ub.code-range .
    define buffer buf_sys-ctrl        for ub.sys-ctrl .
    define variable conf-par       as character no-undo .
    define variable par-type       as character no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .
    define variable v-cre-cdrg as logical   no-undo .
    define variable v-cre-str  as character no-undo .
    define variable v-cr1      as integer no-undo .
    define variable v-cr2      as integer no-undo .
    define variable v-cr3      as integer no-undo .
    define variable v-cmax     as integer no-undo .
    find first buf_sys-ctrl no-lock .
    if buf_sys-ctrl.db-num <> 0 and type-code <> 'cagb':U then do:
      undo, return error substitute("&1 &2 &3&4Диапазоны кодов можно создавать только в ГБД&4База данных &5"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    , p-db-num
                                   ).
    end.
    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    for each buf_code-range
      where buf_code-range.db-num     = -1
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "f"
    by buf_code-range.first-code
    on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
    :
      assign
        buf_code-range.db-num = p-db-num
      .
      return .
    end.
    assign
      v-cre-cdrg = TRUE
    .
    case type-code:
      when 'sclc':U
      or when 'scgb':U
      or when 'pglc':U
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = 'sclc':U
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = 'scgb':U
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = 'pglc':U
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
        if last_code-range.last-code + 1 > 99999 then do:
          assign
            v-cre-cdrg = FALSE
          .
        end.
      end.
      when 'bcgb':U
      or when 'sslc':U
      or when 'ssgb':U
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = 'sslc':U
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = 'bcgb':U
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = 'ssgb':U
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
      end.
      otherwise do:
        find last last_code-range no-lock
          where last_code-range.range-type = type-code
          no-error .
      end.
    end case.
    if not available last_code-range then do:
      undo, return error substitute("&1 &2 &3&4В БД нет ни одного диапазона с типом &5&4Не была проведена инициализация диапазонов!"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    , chr(10)
                                    , type-code
                                   ) .
    end.
    define variable v-mes10 as character no-undo .
    define variable v-param-type10 as character no-undo .
    define variable v-value-character10 as INTEGER no-undo .
    define variable v-value-date10 as date no-undo .
    define variable v-value-decimal10 as decimal no-undo .
    define variable v-value-integer10 AS integer no-undo .
    define variable v-value-logical10 AS LOGICAL no-undo .
    define variable v-tth10 as handle no-undo .
    run adm/shattri.p (
        input "get":U
        ,input  'БД':U
        ,input  p-db-num
        ,input  'code-range':U
        ,input  cfg-param-code
        ,output v-value-character10
        ,output v-value-date10
        ,output v-value-decimal10
        ,output v-value-integer10
        ,output v-value-logical10
        ,output v-param-type10
        ,INPUT-OUTPUT table-handle v-tth10
        ) no-error .
    if error-status :error then do:
      delete object v-tth10.
      v-mes10 = substitute("Ошибка при получении размера диапазона собственных глобальных кодов&2&1&2&3"
                         , error-status:get-message(1)
                         , chr(10)
                         , return-value ).
      undo, return error v-mes10.
    end.
    delete object v-tth10.
    if v-cre-cdrg = TRUE then do:
      create buf_code-range .
      assign
        buf_code-range.db-num     = p-db-num
        buf_code-range.range-type = type-code
        buf_code-range.stts       = "f"
        buf_code-range.first-code = last_code-range.last-code + 1
        buf_code-range.last-code  = last_code-range.last-code + integer(v-value-integer10)
        v-cre-str = "Свободный диапазон успешно создан"
      .
    end.
    else do:
      assign
        v-cre-str = "Нет возможности создать свободный диапазон." + chr(10)
                    + substitute( "Превышен предел диапазонов c типом &1", type-code )
      .
    end.
  end.
  return v-cre-str .
end procedure.
procedure gen-new-code-range-if-neces :
  define input parameter v-db-num           like ub.db.db-num             no-undo .
  define input parameter v-range-type       like ub.code-range.range-type no-undo .
  define input parameter v-cur-code         as   integer                  no-undo .
  define input parameter v-g#news           as   logical                  no-undo .
  define input parameter v-g#db-num         like ub.db.db-num             no-undo .
  define input parameter v-g#news-source-db like ub.db.db-num             no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-new-code-range-if-neces). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-new-code-range-if-neces). endkey", vss-workfile )
  :
    define variable l-code-range-exist as logical   no-undo init false .
    define variable v-db-for-send      as character no-undo .
    define buffer buf_code-range  for ub.code-range .
    define buffer buf1_code-range for ub.code-range .
    define buffer buf_db          for ub.db .
    find first buf_code-range
      where buf_code-range.range-type = v-range-type
        and buf_code-range.last-code >= v-cur-code
      use-index last-codei
      no-error .
    if
    (
       available buf_code-range
       and
      (buf_code-range.db-num = v-db-num
        and
      buf_code-range.first-code <= v-cur-code
      )
    or
      (
        v-range-type = 'drgb':U
        AND
        v-cur-code = 0
      )
   )
   then do:
      assign
        l-code-range-exist = true
      .
      if v-g#news
      and buf_code-range.stts = "f" then do:
        assign
          buf_code-range.stts = "u"
        .
      end.
    end.
    if not l-code-range-exist
       and v-g#news-source-db <> 0
    then do:
      undo, return error substitute("&1 &2 &3&4Отсутствует диапазон кодов для БД &5 Тип диапазона кодов &6 Код &7"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    ,v-db-num
                                    ,v-range-type
                                    ,v-cur-code
                                   ).
    end.
    if (not l-code-range-exist
        or ( v-cur-code >= int( (buf_code-range.first-code + buf_code-range.last-code) / 2 ) )
       )
    and ( not can-find (first buf1_code-range no-lock
                        where buf1_code-range.db-num = v-db-num
                          and buf1_code-range.range-type = v-range-type
                          and buf1_code-range.stts = "f"
                       )
        )
    then do:
      if v-g#db-num = 0 then do:
        run new-bcod-gen-code-range in this-procedure
          (input v-db-num,
           input v-range-type
          ) no-error .
        if error-status :error then do:
          undo, return error substitute("Ошибка при создании нового свободного диапазона &1 Тип диапазона кодов &2 Код &3:&4&5 &6"
                                        , substitute("&1 &2 &3", vss-workfile, vss-revision, vss-description)
                                        ,v-db-num
                                        ,v-range-type
                                        ,v-cur-code
                                        ,chr(10)
                                        ,error-status:get-message(1)
                                        ,return-value
                                       ).
        end.
      end.
      else do:
        if v-range-type = 'sclc':U
        or v-range-type = 'pglc':U
        then do:
          assign
            v-db-for-send = "":U
          .
          if v-g#db-num = 0 then do:
            for each buf_db no-lock
              where buf_db.db-num > 0
                and buf_db.db-num <> v-g#news-source-db
            on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
            :
              assign
                v-db-for-send = v-db-for-send + chr(1) + string( buf_db.db-num )
              .
            end.
            assign
              v-db-for-send = right-trim( v-db-for-send, chr(1) )
            .
          end.
          else do:
            if not v-g#news then do:
              assign
                v-db-for-send = "0":U
              .
            end.
          end.
          run nws/cr-route.p ( input 'send-cmd':U
                        ,input ("command":U + chr(1) + "create":U + chr(1) +
                               "code-range":U + chr(1) +
                               (if v-range-type = 'sclc':U
                                then string( current-value(s-sclc-code, ub))
                                else string( current-value(s-pglc-code, ub))
                                ) + chr(1) +
                                v-range-type)
                        ,input ?
                        ,input v-db-for-send
                        ) no-error .
          if error-status :error then do:
            undo, return error return-value.
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure cre-loc-sc-code-range :
  define input parameter v-cur-code as integer no-undo .
define input parameter p-cdrg-type as character no-undo .
  do
  on error  undo, return error substitute( "&1 (cre-loc-sc-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (cre-loc-sc-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (cre-loc-sc-code-range). endkey", vss-workfile )
  :
    define buffer buf_code-range for ub.code-range .
    find first buf_code-range
         where buf_code-range.range-type = p-cdrg-type
           and buf_code-range.first-code >= v-cur-code
         no-error .
    if not available buf_code-range then do:
      run new-bcod-gen-code-range in this-procedure
        ( input 0,
          input p-cdrg-type
        ) no-error .
      if error-status :error then do:
        undo, return error substitute( "Ошибка при создании нового свободного диапазона локальных весовых или штучных кодов&1"
                                       + "Код &2&1&3 &4"
                                      , chr(10)
                                      , v-cur-code
                                      , error-status:get-message(1)
                                      , return-value
                                     ) .
      end.
    end.
  end.
end procedure.
procedure mark-used-if-need :
define input parameter p-cur-code as integer no-undo .
define input parameter p-range-type like ub.code-range.range-type no-undo .
define input parameter p-db-num like ub.code-range.db-num no-undo .
  do
  on error  undo, return error substitute( "&1 (mark-used-if-need). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (mark-used-if-need). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (mark-used-if-need). endkey", vss-workfile )
  :
    DEFINE VARIABLE v-db-num like ub.code-range.db-num no-undo .
    define buffer buf_code-range for ub.code-range .
    assign
    v-db-num = if p-range-type = 'sclc':U
               then 0
               else p-db-num
    .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer locK-batchprocess11 for ub.batchprocess.
run gbl/lock-prc.p
    (input 'lscc':U
    ,input 0
    ,input 0
    ,input 0
    ,input ""
    ,input ""
    ,input ""
    ,input (
            ",,,Вкл/выкл лок. вес. кодов"
           )
    ,input true
    ,buffer lock-batchprocess11
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент идет процесс вкл/выкл лок. вес. кодов" skip
      view-as alert-box error .
    undo, return error .
  end.
    find first buf_code-range
         where buf_code-range.range-type = p-range-type
           and buf_code-range.first-code >= p-cur-code
           and buf_code-range.last-code <= p-cur-code
           and buf_code-range.db-num = v-db-num
         no-error .
    if not available buf_code-range then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании поиске диапазона" skip
        "База данных" p-db-num skip
        "Код" p-cur-code skip
        "Тип" p-range-type
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_code-range.stts = "f":U then do:
      assign
      buf_code-range.stts = "u":U
      .
    end.
  end.
end procedure.
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable add-obj-type like ub.clients.obj-type no-undo .
define variable add-obj-code like ub.clients.obj-code no-undo .
define variable add-option   as character no-undo.
define variable updated      as logical   no-undo.
define variable temp-doc-rec as recid     no-undo.
define variable glog         as logical   no-undo .
define variable v-tab-order  as character no-undo.
define variable loc-glob     as logical   no-undo .
define variable loc-firm     as logical   no-undo .
define variable loc-object   as logical   no-undo .
define variable dflt-cd      as character no-undo .
define variable v-auto-go    as logical   no-undo init NO .
define variable v-rid-list as character no-undo .
define temp-table tt-dis-rule       no-undo like ub.dis-rule.
define temp-table tt0-term_dis-rule no-undo like ub.dis-rule.
define temp-table old-temp-disc     no-undo like temp-disc.
define buffer del_temp-disc for temp-disc.
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
     LABEL "&Список платежей"
     SIZE 20 BY 1 TOOLTIP "Создание списка".
DEFINE BUTTON B-obj
     LABEL "&Список объектов"
     SIZE 20 BY 1 TOOLTIP "Создание списка".
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE QUERY BR-add FOR
      temp-disc SCROLLING.
DEFINE QUERY BR-del FOR
      del_temp-disc SCROLLING.
DEFINE BROWSE BR-add
  QUERY BR-add DISPLAY
      entry (lookup (temp-disc.pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U) column-label "Место!использ."  format "X(10)"
discpru-get-disc-role-label (temp-disc.discnt-role) column-label "Тип скидки" FORMAT "X(255)":U WIDTH 35
temp-disc.templ-rl-root FORMAT ">>>>>>>>9":U COLUMN-LABEL "Код!шаблона"
temp-disc.time-templ-rl-root FORMAT ">>>>>>>>9":U COLUMN-LABEL "Код!типа!распис"
discpru-get-disc-label( INPUT temp-disc.templ-rl-root) FORMAT "X(255)":U WIDTH 45
temp-disc.rule-num COLUMN-LABEL "Код правила" FORMAT ">>>>>>>>9"
get-objregion(temp-disc.obj-type, temp-disc.obj-code) COLUMN-LABEL "Действует" FORMAT "X(12)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8
         TITLE "Будут добавлены/изменены скидки".
DEFINE BROWSE BR-del
  QUERY BR-del DISPLAY
      entry (lookup (del_temp-disc.pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U)                               column-label "Место!использ."  format "X(10)"
      discpru-get-disc-role-label ( DEL_temp-disc.discnt-role) column-label "Тип скидки"      FORMAT "X(255)":U WIDTH 35
      del_temp-disc.templ-rl-root                    COLUMN-LABEL "Код!шаблона"     FORMAT ">>>>>>>>9":U
      del_temp-disc.time-templ-rl-root               COLUMN-LABEL "Код!типа!распис" FORMAT ">>>>>>>>9":U
      discpru-get-disc-label( INPUT del_temp-disc.templ-rl-root)                   FORMAT "X(255)":U WIDTH 45
      del_temp-disc.rule-num                         COLUMN-LABEL "Код правила"     FORMAT ">>>>>>>>9"
      get-objregion(del_temp-disc.obj-type, del_temp-disc.obj-code) COLUMN-LABEL "Действует" FORMAT "X(12)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8
         TITLE "Будут удалены скидки".
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-obj AT ROW 1 COL 26.5
     B-list AT ROW 1 COL 47.5
     B-Help AT ROW 1 COL 92
     b-add AT ROW 2.5 COL 1
     B-chg AT ROW 2.5 COL 11
     B-del AT ROW 2.5 COL 21
     BR-add AT ROW 3.5 COL 1
     b-add-2 AT ROW 12.75 COL 1
     B-chg-2 AT ROW 12.75 COL 11 WIDGET-ID 2
     B-del-2 AT ROW 12.75 COL 21
     BR-del AT ROW 14 COL 1
     SPACE(0.00) SKIP(0.33)
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
  message
     "Вы уверены, что хотите удалить скидку" skip
     "из списка скидок подлежащих установке/изменению?" skip
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
     "Вы уверены, что хотите удалить скидку" skip
     "из списка скидок, подлежащих удалению?" skip
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
      run ref/cashpays.w (
          parparentproc
          ,"b-sel,b-mark"
          ,'все':U
          ,p-host-code
          ,parobj-type
          ,parobj-code
          ,output v-rid-list ) .
  assign
  b-list:label = "&Список платежей"
  .
END.
ON CHOOSE OF B-obj IN FRAME Dialog-Frame
DO:
  RUN proc-b-obj IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if lookup(par-subject, 'dis-cp-rule':U) = 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра par-subject" par-subject
    view-as alert-box error.
    return error.
  end.
  CASE par-subject:
    when 'dis-cp-rule':U
    then do:
      if v-cntxt-db-num = 0 then do:
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cp-discount_global_work':U
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
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cp-discount_firm_work':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
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
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cp-discount_object_work':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
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
        "У Вас отсутствуют права на назначение скидки на тип платежа как по объекту, так и по фирме и глобально" skip
        "либо Вы находитесь в БД, в которой их назначить невозможно"
        view-as alert-box error .
        undo, return.
      end.
    end.
  END CASE.
  find first X_clients-obj no-lock where
              X_clients-obj.obj-type = parobj-type AND
              X_clients-obj.obj-code = parobj-code no-error .
  if not avail X_clients-obj then do:
    message vss-workfile vss-revision vss-description skip
    "Неверное значение параметра parobj-type и/или parobj-code" parobj-type parobj-code
    view-as alert-box error.
    return error.
  end.
  RUN enable_UI in this-procedure .
  RUN MYenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI in this-procedure .
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
  ENABLE B-exit b-quit B-obj B-list B-Help b-add B-chg B-del BR-add b-add-2
         B-chg-2 B-del-2 BR-del
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
RUN proc-title IN THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE proc-b-add :
define input parameter p-pos-type as character no-undo.
define variable v-deleted       as logical   no-undo .
define variable v-rid           as character no-undo .
define variable v-rec           as recid     no-undo .
define variable v-cfg-nonunique as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_temp-disc    for temp-disc.
do
on error undo, return error :
  run ref/dis-pos.w ( input parparentproc
                     ,input "b-sel":U
                     ,input "cd-type-list"
                     ,input (if v-cntxt-db-num = 0 and loc-glob then 1 else 0)
                     ,input (if v-cntxt-db-num = 0 and loc-firm then 1 else 0)
                     ,input 1
                     ,input 'dis-cp-rule':U
                     ,input '':U
                     ,input ?
                     ,input p-pos-type
                     ,input '':U
                     ,input-output v-rid ) no-error.
  IF ERROR-STATUS:ERROR
  OR v-rid = '':U THEN DO:
    RETURN.
  END.
  find first buf_dis-cfg-rule where recid(buf_dis-cfg-rule) = int(v-rid) no-lock no-error.
  if not avail buf_dis-cfg-rule then do:
      RETURN.
  end.
  v-cfg-nonunique = substitute("@&1", buf_dis-cfg-rule.nonunique).
  run temp-dsc-write in this-procedure (
                                         input yes
                                        ,input buf_dis-cfg-rule.pos-type
                                        ,input buf_dis-cfg-rule.templ-rl-root
                                        ,input buf_dis-cfg-rule.time-templ-rl-root
                                        ,input buf_dis-cfg-rule.discnt-role
                                        ,input v-cfg-nonunique
                                        ,input p-host-code
                                        ,input parobj-type
                                        ,input parobj-code
                                        ,input 0
                                        ,input yes
                                        ,input-output v-rec
                                  ) no-error .
  IF ERROR-STATUS:ERROR THEN DO:
    if not return-value = "not-set" then do:
      message "Ошибка при определении названия и типа скидки на платеж!"         skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
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
                                              ,input v-cfg-nonunique
                                              ,input p-host-code
                                              ,input parobj-type
                                              ,input parobj-code
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
define variable v-rid as character no-undo .
define variable v-rule-num as integer no-undo .
define variable v-cfg-nonunique as character no-undo .
define variable v-nonunique as character no-undo .
define variable v-rec as recid no-undo .
define buffer buf_temp-disc for temp-disc.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
CASE par-subject :
  WHEN 'dis-cp-rule':U THEN DO:
    run ref/dis-pos.w ( INPUT parparentproc
                        ,INPUT "b-sel":U
                        ,INPUT "cd-type-list"
                        ,INPUT (if v-cntxt-db-num = 0 then 1 else 0)
                        ,INPUT (if v-cntxt-db-num = 0 then 1 else 0)
                        ,INPUT 1
                        ,input 'dis-cp-rule':U
                        ,input '':U
                        ,input ?
                        ,INPUT p-pos-type
                        ,input '':U
                        ,INPUT-OUTPUT v-rid) NO-ERROR.
    IF ERROR-STATUS:ERROR
    OR v-rid = '':U THEN DO:
      RETURN.
    END.
    find first buf_dis-cfg-rule where recid(buf_dis-cfg-rule) = int(v-rid) no-lock no-error.
    if not avail buf_dis-cfg-rule then do:
        RETURN.
    end.
    v-cfg-nonunique = substitute("@&1", buf_dis-cfg-rule.nonunique).
    run temp-dsc-write in this-procedure (
                                            input yes
                                           ,input buf_dis-cfg-rule.pos-type
                                           ,input buf_dis-cfg-rule.templ-rl-root
                                           ,input buf_dis-cfg-rule.time-templ-rl-root
                                           ,input buf_dis-cfg-rule.discnt-role
                                           ,input v-cfg-nonunique
                                           ,input p-host-code
                                           ,input parobj-type
                                           ,input parobj-code
                                           ,input v-rule-num
                                           ,input no
                                           ,input-output v-rec )  no-error .
     IF ERROR-STATUS:ERROR THEN DO:
      if not return-value = "not-set" then do:
        message "Ошибка при определении названия и типа скидки на платеж!"         skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
        return error .
      end .
    END .
    define buffer bb_temp-disc for temp-disc .
    find first bb_temp-disc no-error .
  END .
END CASE .
updated = yes .
find first buf_temp-disc no-lock where
          recid(buf_temp-disc) = v-rec no-error .
if avail buf_temp-disc then
  temp-doc-rec = recid(buf_temp-disc) .
  else temp-doc-rec = ? .
Run init-proc in this-procedure .
reposition BR-del to recid temp-doc-rec no-error .
if error-status:error then return error .
run proc-b-chg-2 in this-procedure ( input "":U) no-error .
if error-status:error then do:
    run temp-dsc-delete in this-procedure (
                                             input buf_dis-cfg-rule.pos-type
                                            ,input buf_dis-cfg-rule.discnt-role
                                            ,input v-cfg-nonunique
                                            ,input p-host-code
                                            ,input parobj-type
                                            ,input parobj-code
                                            ,input no
                                            ,output v-deleted
                                            ) no-error .
  Run init-proc in this-procedure no-error .
  undo, return error .
end .
APPLY "ENTRY" to br-del in frame Dialog-Frame .
END PROCEDURE .
PROCEDURE proc-b-chg :
define input parameter p-mode as character no-undo .
define variable v-rule-num as integer no-undo .
define variable v-nonunique as character no-undo .
define variable v-rec as recid no-undo .
if not avail temp-disc then return error .
  RUN temp-dsc-VALUE IN THIS-PROCEDURE (
                                       input temp-disc.pos-type
                                      ,input temp-disc.templ-rl-root
                                      ,input temp-disc.time-templ-rl-root
                                      ,input temp-disc.discnt-role
                                      ,input temp-disc.nonunique
                                      ,input temp-disc.host-code
                                      ,input temp-disc.obj-type
                                      ,input temp-disc.obj-code
                                      ,input 'ДОБАВЛЕНИЕ':U
                                      ,input p-mode
                                      ,input recid(temp-disc)
                                      ,OUTPUT v-rule-num
                                      ,output v-nonunique
                                      ) NO-ERROR .
  IF ERROR-STATUS:ERROR THEN DO:
    if return-value <> "not-set":U then do:
      message "Ошибка при определении значения скидки на платеж!"         skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
      RETURN error .
    end .
  END .
  if return-value = "not-set":U
  and p-mode <> "change":U then do:
    delete temp-disc.
    glog = br-add:refresh() in frame Dialog-Frame no-error .
    return .
  end .
  v-rec = recid(temp-disc) .
  run temp-dsc-write (
                       input no
                      ,input temp-disc.pos-type
                      ,input temp-disc.templ-rl-root
                      ,input temp-disc.time-templ-rl-root
                      ,input temp-disc.discnt-role
                      ,input temp-disc.nonunique
                      ,input temp-disc.host-code
                      ,input temp-disc.obj-type
                      ,input temp-disc.obj-code
                      ,input v-rule-num
                      ,input temp-disc.action
                      ,input-output v-rec
                      ) no-error .
  IF not error-status:error then do:
    assign
    updated = yes
    .
  END .
  glog = br-add:refresh() in frame Dialog-Frame no-error .
  APPLY "ENTRY" to br-add.
END PROCEDURE .
PROCEDURE proc-b-chg-2 :
define input parameter p-mode as character no-undo .
define variable v-rule-num as integer no-undo .
define variable v-nonunique as character no-undo .
define variable v-rec as recid no-undo .
if not avail del_temp-disc then return error .
  RUN temp-dsc-VALUE IN THIS-PROCEDURE (
                                       input del_temp-disc.pos-type
                                      ,input del_temp-disc.templ-rl-root
                                      ,input del_temp-disc.time-templ-rl-root
                                      ,input del_temp-disc.discnt-role
                                      ,input del_temp-disc.nonunique
                                      ,input del_temp-disc.host-code
                                      ,input del_temp-disc.obj-type
                                      ,input del_temp-disc.obj-code
                                      ,input 'удаление':U
                                      ,input p-mode
                                      ,input recid(del_temp-disc)
                                      ,OUTPUT v-rule-num
                                      ,output v-nonunique
                                      ) NO-ERROR .
  IF ERROR-STATUS:ERROR THEN DO:
    if return-value <> "not-set":U then do:
      message "Ошибка при определении значения скидки на платеж!"         skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
      RETURN error .
    end .
  END .
  if return-value = "not-set":U
  and p-mode <> "change":U then do:
    delete del_temp-disc .
    glog = br-del:refresh() in frame Dialog-Frame no-error .
    return .
  end .
  v-rec = recid(del_temp-disc) .
  run temp-dsc-write (
                       input no
                      ,input del_temp-disc.pos-type
                      ,input del_temp-disc.templ-rl-root
                      ,input del_temp-disc.time-templ-rl-root
                      ,input del_temp-disc.discnt-role
                      ,input del_temp-disc.nonunique
                      ,input del_temp-disc.host-code
                      ,input del_temp-disc.obj-type
                      ,input del_temp-disc.obj-code
                      ,input v-rule-num
                      ,input del_temp-disc.action
                      ,input-output v-rec
                      ) no-error .
  IF not error-status:error then do:
    assign
    updated = yes
    .
  END .
  glog = br-del:refresh() in frame Dialog-Frame no-error .
  APPLY "ENTRY" to br-del.
END PROCEDURE .
PROCEDURE proc-b-exit :
define variable loc#log      as logical no-undo .
define variable v-not-all-ok as logical no-undo .
define variable v-des           like ub.dis-rule.des .
define variable v-templ-rl-root like ub.dis-rule.templ-rl-root .
define variable p-parent-handle  as widget-handle no-undo .
define variable v-view-log       as logical       no-undo .
define variable v-host-code      like temp-disc.host-code .
define buffer buf_temp-disc              for temp-disc.
define buffer buf_dis-rule               for ub.dis-rule.
define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
if not can-find(first temp-disc) then do:
    message "Вы не определили список скидок для изменения (добавления, удаления)"
    view-as alert-box .
    return no-apply .
end .
if v-rid-list = ''
then do:
    message "Вы не определили список платежей"
    view-as alert-box .
    return no-apply .
end .
if not can-find(first buf_userobjs_temp-user-obj) then do:
    message "Вы не определили список объектов, скидки" skip
            "будут применены только к текущему объекту." skip
            "Продолжить?"
    view-as alert-box question buttons yes-no update loc#log .
    if not loc#log then do:
      return no-apply .
    end .
end .
for each buf_userobjs_temp-user-obj exclusive-lock:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_userobjs_temp-user-obj.obj-type
  ,input  buf_userobjs_temp-user-obj.obj-code
  ,output v-host-code
  )  .
    if not p-host-code = v-host-code then do:
        message "Вы выбрали " buf_userobjs_temp-user-obj.obj-type buf_userobjs_temp-user-obj.obj-code " не принадлежащий текущей фирме" skip
                buf_userobjs_temp-user-obj.obj-type buf_userobjs_temp-user-obj.obj-code " будет исключен из списка объектов." skip
                "Продолжить?"
        view-as alert-box question buttons yes-no update loc#log .
        if not loc#log then do:
            return no-apply .
        end .
        else do:
            delete buf_userobjs_temp-user-obj .
        end.
    end.
end.
message
"Вы уверены, что Вы хотите провести изменение (добавление, удаление) скидок платежей на объекте" SKIP
"по всему определенному Вами списку?"
view-as alert-box QUESTION buttons YES-NO update loc#log .
if loc#log then do:
 run save-temp-disc in this-procedure no-error.
 _main:
 DO
 on error undo, return no-apply
 :
    run make-full-temp-disc in this-procedure no-error.
    CASE par-subject:
    when 'dis-cp-rule':U then do:
        run str/diallog.w (
                input parparentproc
              , input this-procedure
              , input "ref/csh-lst.p":U
              , input v-rid-list
              , input v-auto-go
              , input "&Стоп":U
              , input "Изменение скидок платежей по списку"
        ) no-error .
        if error-status:error then do:
            undo _main, return error .
        end.
    end .
    END CASE .
  END.
  run rest-temp-disc in this-procedure no-error.
end .
END PROCEDURE .
PROCEDURE proc-title :
IF parobj-type = 'маг':U THEN DO:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type21 as character no-undo .
define variable v-value-date21 as date no-undo .
define variable v-value-decimal21 as decimal no-undo .
define variable v-value-integer21 as INTEGER no-undo .
define variable v-value-logical21 AS LOGICAL no-undo .
define variable v-tth21 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  parobj-type
    ,input  parobj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date21
    ,output v-value-decimal21
    ,output v-value-integer21
    ,output v-value-logical21
    ,output v-param-type21
    ,INPUT-OUTPUT table-handle v-tth21
    )  .
delete object v-tth21 no-error.
END .
if parobj-type = 'скл':U then do:
  dflt-cd = '-':U .
end .
ASSIGN
MENU-ITEM m_pos-type:LABEL IN MENU menu-b-add  = dflt-cd
MENU-ITEM m_pos-type:sensitive IN MENU menu-b-add  = ((dflt-cd <> '':U) and (dflt-cd <> '-':U))
MENU-ITEM m_pos-type-2:LABEL IN MENU menu-b-add-2  = dflt-cd
MENU-ITEM m_pos-type-2:sensitive IN MENU menu-b-add-2  = ((dflt-cd <> '':U) and (dflt-cd <> '-':U))
.
frame Dialog-Frame:title = substitute("Изменение скидок на платежи, &1 &2"
                                          ,parobj-type
                                          ,parobj-code) .
assign
v-tab-order = "b-exit,b-quit,b-list,b-help,b-obj,b-add,b-add-2" .
APPLY "ENTRY" TO b-add IN FRAME Dialog-Frame .
END PROCEDURE .
PROCEDURE proc-b-obj :
define variable v-user-select as logical   no-undo .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  p-host-code
  ,input  parobj-type
  ,input  parobj-code
  ,output v-user-select
  )  .
define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
find first buf_userobjs_temp-user-obj no-lock no-error.
if not avail buf_userobjs_temp-user-obj
then do:
  message
  "Объект не выбран"
  view-as alert-box information .
  undo, return error return-value .
end.
END PROCEDURE .
PROCEDURE cb_set-cp-list :
  define output parameter p-rid-list as character no-undo.
  assign
    p-rid-list = v-rid-list
  .
END PROCEDURE .
PROCEDURE rest-temp-disc :
  define buffer buf_temp-disc              for temp-disc.
  define buffer buf_old-temp-disc          for old-temp-disc.
  for each temp-disc exclusive-lock :
     delete temp-disc.
  end.
  for each buf_old-temp-disc no-lock :
     create buf_temp-disc.
     buffer-copy buf_old-temp-disc to buf_temp-disc.
  end.
  glog = br-del:refresh() in frame Dialog-Frame no-error .
  glog = br-add:refresh() in frame Dialog-Frame no-error .
END PROCEDURE .
PROCEDURE save-temp-disc :
  define buffer buf_temp-disc              for temp-disc.
  define buffer buf_old-temp-disc          for old-temp-disc.
  for each old-temp-disc exclusive-lock :
      delete old-temp-disc.
  end.
  for each buf_temp-disc no-lock :
      create buf_old-temp-disc.
      buffer-copy buf_temp-disc to buf_old-temp-disc.
  end.
END PROCEDURE .
PROCEDURE make-full-temp-disc :
  define buffer buf_temp-disc              for temp-disc.
  define buffer buf_dis-rule               for ub.dis-rule.
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  define variable v-des           like ub.dis-rule.des .
  define variable v-templ-rl-root like ub.dis-rule.templ-rl-root .
  define variable v-discnt-value  like ub.dis-rule.discnt-value .
  define variable v-discnt-type   like ub.dis-rule.discnt-type .
  _userobjs_temp-user-obj:
  for each buf_userobjs_temp-user-obj no-lock :
      if buf_userobjs_temp-user-obj.obj-type = parobj-type and
         buf_userobjs_temp-user-obj.obj-code = parobj-code then do:
           next _userobjs_temp-user-obj .
      end.
      _temp-disc:
      for each temp-disc exclusive-lock
      where temp-disc.obj-type = parobj-type
        and temp-disc.obj-code = parobj-code :
          find first buf_temp-disc no-lock
          where buf_temp-disc.obj-type           = buf_userobjs_temp-user-obj.obj-type
            and buf_temp-disc.obj-code           = buf_userobjs_temp-user-obj.obj-code
            and buf_temp-disc.templ-rl-root      = temp-disc.templ-rl-root
            and buf_temp-disc.time-templ-rl-root = temp-disc.time-templ-rl-root
            and buf_temp-disc.discnt-role        = temp-disc.discnt-role
            and buf_temp-disc.nonunique          = temp-disc.nonunique
            and buf_temp-disc.cfg-nonunique      = temp-disc.cfg-nonunique
            and buf_temp-disc.pos-type           = temp-disc.pos-type
            and buf_temp-disc.action             = temp-disc.action
          no-error.
          if avail buf_temp-disc then do:
              next _temp-disc.
          end.
          create buf_temp-disc.
          buffer-copy temp-disc
          except obj-type obj-code
          to buf_temp-disc
          assign
            buf_temp-disc.obj-type = buf_userobjs_temp-user-obj.obj-type
            buf_temp-disc.obj-code = buf_userobjs_temp-user-obj.obj-code
          .
          if not ( temp-disc.rule-num = ? or temp-disc.rule-num = 0 ) then do:
              find first buf_dis-rule no-lock
              where buf_dis-rule.rule-num = temp-disc.rule-num no-error.
              if avail buf_dis-rule then do:
                  assign
                    v-des           = buf_dis-rule.des
                    v-templ-rl-root = buf_dis-rule.templ-rl-root
                    v-discnt-value  = buf_dis-rule.discnt-value
                    v-discnt-type   = buf_dis-rule.discnt-type
                  .
                  find first buf_dis-rule no-lock
                  where buf_dis-rule.des           = v-des
                    and buf_dis-rule.host-code     = temp-disc.host-code
                    and buf_dis-rule.obj-type      = buf_userobjs_temp-user-obj.obj-type
                    and buf_dis-rule.obj-code      = buf_userobjs_temp-user-obj.obj-code
                    and buf_dis-rule.templ-rl-root = v-templ-rl-root
                    and buf_dis-rule.discnt-value  = v-discnt-value
                    and buf_dis-rule.discnt-type   = v-discnt-type
                    and buf_dis-rule.root          = yes no-error.
                  if avail buf_dis-rule then do:
                      assign
                        buf_temp-disc.rule-num = buf_dis-rule.rule-num
                      .
                  end.
                  else do:
                      run copy-rule in this-procedure (
                            input  temp-disc.rule-num
                           ,input  buf_userobjs_temp-user-obj.obj-type
                           ,input  buf_userobjs_temp-user-obj.obj-code
                           ,output buf_temp-disc.rule-num
                           ,input-output buf_temp-disc.label_
                      ) no-error.
                  end.
              end.
          end.
      end.
  end.
END PROCEDURE .
PROCEDURE copy-rule :
  define input  param p-rule-num as integer   no-undo .
  define input  param p-obj-type as character no-undo .
  define input  param p-obj-code as integer   no-undo .
  define output param p-new-rnum as integer   no-undo init ? .
  define input-output param p-err-msg as character no-undo .
  define variable v-cd-type as character no-undo .
  define buffer src_dis-rule for ub.dis-rule .
  define buffer trg_dis-rule for ub.dis-rule .
  run check-possible-copy in this-procedure (
         input  p-rule-num
        ,input  p-obj-type
        ,input  p-obj-code
        ,output p-new-rnum
  ) no-error.
  if error-status :error then do:
      if not p-err-msg = '' then p-err-msg = p-err-msg + ', ' .
      p-err-msg = error-status:get-message(1) .
      return .
  end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type23 as character no-undo .
define variable v-value-date23 as date no-undo .
define variable v-value-decimal23 as decimal no-undo .
define variable v-value-integer23 as INTEGER no-undo .
define variable v-value-logical23 AS LOGICAL no-undo .
define variable v-tth23 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output v-cd-type
    ,output v-value-date23
    ,output v-value-decimal23
    ,output v-value-integer23
    ,output v-value-logical23
    ,output v-param-type23
    ,INPUT-OUTPUT table-handle v-tth23
    )  .
delete object v-tth23 no-error.
  _lmain:
  DO
  on error undo, return
  :
      find first src_dis-rule no-lock
      where src_dis-rule.rule-num = p-rule-num no-error .
      if error-status:error then do:
          if not p-err-msg = '' then p-err-msg = p-err-msg + ', ' .
          p-err-msg = error-status:get-message(1) .
          undo _lmain, return error .
      end.
      create trg_dis-rule no-error.
      if error-status:error then do:
          if not p-err-msg = '' then p-err-msg = p-err-msg + ', ' .
          p-err-msg = error-status:get-message(1) .
          undo _lmain, return error .
      end.
      buffer-copy src_dis-rule
      except rule-num rl-root obj-type obj-code
      to trg_dis-rule
      assign
        trg_dis-rule.rule-num = p-new-rnum
        trg_dis-rule.rl-root  = p-new-rnum
        trg_dis-rule.obj-type = p-obj-type
        trg_dis-rule.obj-code = p-obj-code
      no-error.
      if error-status:error then do:
          if not p-err-msg = '' then p-err-msg = p-err-msg + ', ' .
          p-err-msg = error-status:get-message(1) .
          undo _lmain, return error .
      end.
  END.
END PROCEDURE .
PROCEDURE check-possible-copy :
  define input  param p-rule-num as integer   no-undo .
  define input  param p-obj-type as character no-undo .
  define input  param p-obj-code as integer   no-undo .
  define output param p-new-rnum as integer   no-undo init ?.
  define variable v-err-msg as character no-undo init ''.
  define variable v-cd-type as character no-undo .
  define buffer buf_dis-rule     for ub.dis-rule .
  define buffer buf_dis-cfg-rule for ub.dis-cfg-rule .
  find first buf_dis-rule no-lock
  where buf_dis-rule.rule-num = p-rule-num no-error .
  if not avail buf_dis-rule then do:
      v-err-msg = substitute("Не найдено правило &1", p-rule-num ) .
      return error v-err-msg .
  end.
  if not (buf_dis-rule.sts = int('0':U)) then do:
      v-err-msg = substitute("Нельзя копировать правило в статусе &1", '0':U) .
      return error v-err-msg .
  end.
  if buf_dis-rule.obj-type = ''
  or not (buf_dis-rule.obj-type = 'маг':U or
          buf_dis-rule.obj-type = 'скл':U) then do:
      v-err-msg = substitute("Нельзя копировать правило, которое действует &1", get-region( p-host-code, parobj-type, parobj-code )) .
      return error v-err-msg .
  end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type24 as character no-undo .
define variable v-value-date24 as date no-undo .
define variable v-value-decimal24 as decimal no-undo .
define variable v-value-integer24 as INTEGER no-undo .
define variable v-value-logical24 AS LOGICAL no-undo .
define variable v-tth24 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output v-cd-type
    ,output v-value-date24
    ,output v-value-decimal24
    ,output v-value-integer24
    ,output v-value-logical24
    ,output v-param-type24
    ,INPUT-OUTPUT table-handle v-tth24
    )  .
delete object v-tth24 no-error.
  find first buf_dis-cfg-rule no-lock
  where buf_dis-cfg-rule.table-name    = 'dis-cp-rule':U
    and buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
    and buf_dis-cfg-rule.pos-type      = v-cd-type no-error .
  if not avail buf_dis-cfg-rule then do:
      v-err-msg = substitute("Не найдено правило скидки с шаблоном &1 POS &2 для &3&4"
                            , buf_dis-rule.templ-rl-root
                            , v-cd-type
                            , p-obj-type
                            , p-obj-code ) .
      return error v-err-msg .
  end.
  if not (v-cd-type = 'bo':U or v-cd-type = '-':U) then do:
      if p-obj-type = 'скл':U then do:
          v-err-msg = substitute("Нельзя скопировать правила скидки на объект &1&2"
                                , p-obj-type
                                , p-obj-code ) .
          return error v-err-msg .
      end.
  end.
  run gen-b-code in this-procedure ( input 'drgb':U, output p-new-rnum) no-error .
  if error-status:error then do:
      v-err-msg = substitute("Не удалось расчитать новый номер правила скидки &1 (gen-b-code) на &2&3&4&5&4&6" ~
                            , p-rule-num
                            , p-obj-type
                            , p-obj-code
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value ) .
      assign
        p-new-rnum = ?
      .
      return error v-err-msg .
  end.
END PROCEDURE .
