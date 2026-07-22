DEFINE TEMP-TABLE temp-odisc NO-UNDO LIKE ub.dis-dct-rule
       field rule-label as character.
DEFINE TEMP-TABLE tt0-dis-dct-rule NO-UNDO LIKE ub.dis-dct-rule.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo.
define input parameter p-type as character no-undo.
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input parameter p-pos-type as character no-undo .
define input parameter p-discnt-role-list as character no-undo .
define INPUT-OUTPUT parameter table for tt0-dis-dct-rule.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Скидки на тип ДК".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure disdctru-name :
define buffer buf_dis-rule for ub.dis-rule.
do
  on error undo, return error
  :
  define input  parameter p-templ-rl-root  as integer no-undo .
  define output parameter p-label          as character no-undo .
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-templ-rl-root no-error.
  if available buf_dis-rule then do:
    p-label = buf_dis-rule.des.
  end.
  else do:
    p-label = substitute("Неизвестный тип правила скидки &1", p-templ-rl-root).
  end.
end.
end procedure.
function disdctru-get-disc-label returns character ( input p-templ-rl-root as integer):
define variable v-rule-label as character no-undo .
run disdctru-name in this-procedure ( input p-templ-rl-root
                                     ,output v-rule-label) no-error.
return v-rule-label.
end function.
function disdctru-get-disc-role-label returns character ( input p-discnt-role as character):
define variable v-rule-label as character no-undo .
return entry (lookup (p-discnt-role, 'calc-d-pcnt,calc-cash-d-pcnt,calc-categ,dis-tot-flag,def-categ,def-pcnt,def-cash-pcnt':u) + 1, ',' + 'Расчет %скидки ДК на товар,Расчет %скидки ДК на итог,Расчет категории ДК,Участие в итогах по ДК,Категория ДК по умолчанию,% скидки ДК на товар по умолч.,% скидки ДК на итог по умолч.':u).
end function.
procedure disdctru-write :
  do
  on error undo, return error
  :
    define input parameter p-type           like ub.dis-dct-rule.type       no-undo .
    define input parameter p-emitent-host-code      like ub.dis-dct-rule.emitent-host-code  no-undo .
    define input parameter p-host-code      like ub.dis-dct-rule.host-code  no-undo .
    define input parameter p-obj-type       like ub.dis-dct-rule.obj-type   no-undo .
    define input parameter p-obj-code       like ub.dis-dct-rule.obj-code   no-undo .
    define input parameter p-pos-type       like ub.dis-dct-rule.pos-type   no-undo .
    define input parameter p-discnt-role    like ub.dis-dct-rule.discnt-role no-undo .
    define input parameter p-templ-rl-root  like ub.dis-dct-rule.templ-rl-root  no-undo .
    define input parameter p-time-templ-rl-root  like ub.dis-dct-rule.time-templ-rl-root  no-undo .
    define input parameter p-rule-num       like ub.dis-dct-rule.rule-num    no-undo .
    define input parameter p-NONUNIQUE as character no-undo .
    define buffer buf_dis-dct-rule for ub.dis-dct-rule .
    define buffer lock_dis-dct-rule for ub.dis-dct-rule .
    define buffer buf_dis-rule for ub.dis-rule.
    define variable v-label          as character no-undo .
    define variable v-discnt-role as character no-undo .
    run discfgru-check in this-procedure (
                                          input 'dis-dct-rule':U
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
      undo, return error substitute("Тип ДК &1 код валюты &2 фирма &3 &4 место использ. &5 скидка типа &6&7не может быть по шаблону &8 и расписанию &9"
                              ,p-type
                              ,p-emitent-host-code
                              ,p-host-code
                              ,p-obj-type + string(p-obj-code)
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'calc-d-pcnt,calc-cash-d-pcnt,calc-categ,dis-tot-flag,def-categ,def-pcnt,def-cash-pcnt':u) + 1, ',' + 'Расчет %скидки ДК на товар,Расчет %скидки ДК на итог,Расчет категории ДК,Участие в итогах по ДК,Категория ДК по умолчанию,% скидки ДК на товар по умолч.,% скидки ДК на итог по умолч.':u)
                              ,chr(10)
                              ,p-templ-rl-root
                              ,p-rule-num).
    end.
    if p-pos-type = ? then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type4 as character no-undo .
define variable v-value-date4 as date no-undo .
define variable v-value-decimal4 as decimal no-undo .
define variable v-value-integer4 as INTEGER no-undo .
define variable v-value-logical4 AS LOGICAL no-undo .
define variable v-tth4 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output p-pos-type
    ,output v-value-date4
    ,output v-value-decimal4
    ,output v-value-integer4
    ,output v-value-logical4
    ,output v-param-type4
    ,INPUT-OUTPUT table-handle v-tth4
    )  .
delete object v-tth4 no-error.
    end.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-rule-num no-error.
    if not available buf_Dis-rule then do:
      undo, return error substitute("Тип ДК &1 код валюты &2 фирма &3 &4 место использ. &5 скидка типа &6&7не найдено правило скидки &9"
                              ,p-type
                              ,p-emitent-host-code
                              ,p-host-code
                              ,p-obj-type + string(p-obj-code)
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'calc-d-pcnt,calc-cash-d-pcnt,calc-categ,dis-tot-flag,def-categ,def-pcnt,def-cash-pcnt':u) + 1, ',' + 'Расчет %скидки ДК на товар,Расчет %скидки ДК на итог,Расчет категории ДК,Участие в итогах по ДК,Категория ДК по умолчанию,% скидки ДК на товар по умолч.,% скидки ДК на итог по умолч.':u)
                              ,chr(10)
                              ,p-templ-rl-root
                              ,p-rule-num).
    end.
    if buf_dis-rule.root <> yes then do:
      undo, return error substitute("Тип ДК &1 код валюты &2 фирма &3 &4 место использ. &5 скидка типа &6&7правило скидки &9 - некорневое"
                              ,p-type
                              ,p-emitent-host-code
                              ,p-host-code
                              ,p-obj-type + string(p-obj-code)
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'calc-d-pcnt,calc-cash-d-pcnt,calc-categ,dis-tot-flag,def-categ,def-pcnt,def-cash-pcnt':u) + 1, ',' + 'Расчет %скидки ДК на товар,Расчет %скидки ДК на итог,Расчет категории ДК,Участие в итогах по ДК,Категория ДК по умолчанию,% скидки ДК на товар по умолч.,% скидки ДК на итог по умолч.':u)
                              ,chr(10)
                              ,p-templ-rl-root
                              ,p-rule-num).
    end.
    find first buf_dis-dct-rule exclusive-lock where
               buf_dis-dct-rule.type  = p-type
           AND buf_dis-dct-rule.emitent-host-code = p-emitent-host-code
           AND buf_dis-dct-rule.obj-type  = p-obj-type
           AND buf_dis-dct-rule.host-code = p-host-code
           AND buf_dis-dct-rule.obj-code  = p-obj-code
           AND buf_dis-dct-rule.pos-type  = p-pos-type
           AND buf_dis-dct-rule.discnt-role = p-discnt-role  no-error .
    if not available buf_dis-dct-rule then do:
      create buf_dis-dct-rule .
      assign
      buf_dis-dct-rule.type  = p-type
      buf_dis-dct-rule.emitent-host-code  = p-emitent-host-code
      buf_dis-dct-rule.host-code  = p-host-code
      buf_dis-dct-rule.obj-type  = p-obj-type
      buf_dis-dct-rule.obj-code  = p-obj-code
      buf_dis-dct-rule.pos-type = p-pos-type
      buf_dis-dct-rule.discnt-role = v-discnt-role
      buf_dis-dct-rule.rule-num = p-rule-num no-error
      .
    end.
    ELSE
    ASSIGN
    buf_dis-dct-rule.rule-num = p-rule-num
    buf_dis-dct-rule.rl-root = buf_Dis-rule.rl-root
    buf_dis-dct-rule.time-templ-rl-root = p-time-templ-rl-root
    buf_dis-dct-rule.templ-rl-root = p-templ-rl-root
    buf_dis-dct-rule.nonunique = p-nonunique
    no-error.
  end.
end procedure.
procedure disdctru-delete :
define input parameter p-cdpay-code     like ub.dis-dct-rule.emitent-host-code no-undo .
define input parameter p-curr-code      like ub.dis-dct-rule.type no-undo .
define input parameter p-host-code      like ub.dis-dct-rule.host-code   no-undo .
define input parameter p-obj-type       like ub.dis-dct-rule.obj-type   no-undo .
define input parameter p-obj-code       like ub.dis-dct-rule.obj-code   no-undo .
define input parameter p-pos-type       like ub.dis-dct-rule.pos-type   no-undo .
define input parameter p-discnt-role    like ub.dis-dct-rule.discnt-role no-undo .
define input parameter p-nonunique      like ub.dis-dct-rule.nonunique   no-undo .
define output parameter p-deleted       as logical no-undo .
define variable v-rule-label as character no-undo .
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
do
on error undo, return error
:
find first buf_dis-dct-rule exclusive-lock where
            buf_dis-dct-rule.emitent-host-code  = p-host-code
        AND buf_dis-dct-rule.type  = p-type
        AND buf_dis-dct-rule.obj-type  = p-obj-type
        AND buf_dis-dct-rule.host-code = p-host-code
        AND buf_dis-dct-rule.obj-code  = p-obj-code
        AND buf_dis-dct-rule.pos-type  = p-pos-type
        AND buf_dis-dct-rule.discnt-role = p-discnt-role
        and buf_dis-dct-rule.nonunique = p-nonunique
        no-error .
if not available buf_dis-dct-rule then do:
  return '':U.
end.
delete buf_dis-dct-rule no-error.
if error-status:error then do:
  run disdctru-name in this-procedure
    (input  buf_dis-dct-rule.templ-rl-root
    ,output v-rule-label
    ) no-error .
  undo, return error substitute("Ошибка при удалении скидки по типу ДК:&1" +
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
procedure disdctru-edit :
define input parameter p-mode as character no-undo .
define input parameter p-type   like ub.dis-dct-rule.type no-undo .
define input parameter p-emitent-host-code like ub.dis-dct-rule.emitent-host-code no-undo .
define input parameter p-host-code like ub.dis-dct-rule.host-code no-undo .
define input parameter p-obj-type like ub.dis-dct-rule.obj-type no-undo .
define input parameter p-obj-code like ub.dis-dct-rule.obj-code no-undo .
define input parameter p-pos-type like ub.dis-dct-rule.pos-type no-undo .
define input parameter p-discnt-role    like ub.dis-dct-rule.discnt-role no-undo .
define input parameter p-templ-rl-root like ub.dis-dct-rule.templ-rl-root no-undo .
define input parameter p-time-templ-rl-root like ub.dis-dct-rule.time-templ-rl-root no-undo .
define input parameter p-cfg-NONUNIQUE as character no-undo .
define input parameter p-check as integer no-undo .
define input-output parameter p-rule-num as integer no-undo .
define input-output parameter p-NONUNIQUE like ub.dis-dct-rule.NONUNIQUE no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
define variable v-sts as integer no-undo .
define variable v-rid-list as character no-undo .
define variable v-templ-rl-root like ub.dis-rule.templ-rl-root no-undo .
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
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-time-rule for ub.dis-time-rule .
define buffer term_dis-rule for ub.dis-rule.
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_temp-odisc for temp-odisc.
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
  run disdctru-name in this-procedure (
                                input p-templ-rl-root
                                ,output v-label) no-error.
if p-pos-type = ?
or p-pos-type = '':U then do:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type5 as character no-undo .
define variable v-value-date5 as date no-undo .
define variable v-value-decimal5 as decimal no-undo .
define variable v-value-integer5 as INTEGER no-undo .
define variable v-value-logical5 AS LOGICAL no-undo .
define variable v-tth5 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date5
    ,output v-value-decimal5
    ,output v-value-integer5
    ,output v-value-logical5
    ,output v-param-type5
    ,INPUT-OUTPUT table-handle v-tth5
    )  .
delete object v-tth5 no-error.
end.
else do:
  dflt-cd = p-pos-type.
end.
run ref/dis-ruls.w (
            input parparentproc
            ,input p-host-code
            ,input p-obj-type
            ,input p-obj-code
            ,input "b-add,b-sel":U
            ,input (if p-obj-code > 0
                    then "upper-rule-num-object"
                    else ( if p-host-code > 0
                           then "upper-rule-num-host"
                           else "upper-rule-num-global"
                         )
                   )
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
      "Нельзя привязать к нему скидку на тип ДК"
      view-as alert-box error .
      return .
    end.
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
        and buf_dis-cfg-rule.time-templ-rl-root = (if buf_dis-rule.time-templ-rl-root = 0
                                                   then 0
                                                   else buf_dis-rule.time-templ-rl-root)
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
    v-nonunique = if p-cfg-nonunique = '':U
                  then '':U
                  else string(buffer buf_Dis-rule:handle:buffer-field(p-cfg-nonunique):buffer-value).
    if p-check = 0
    or p-check = 2
    then do:
      find first buf_dis-dct-rule no-lock where
                 buf_dis-dct-rule.host-code = p-host-code
              and buf_dis-dct-rule.obj-type = p-obj-type
              and buf_dis-dct-rule.obj-code = p-obj-code
              and buf_dis-dct-rule.type = p-type
              and buf_dis-dct-rule.emitent-host-code = p-emitent-host-code
              and buf_dis-dct-rule.pos-type = p-pos-type
              and buf_dis-dct-rule.discnt-role = p-discnt-role
              and buf_dis-dct-rule.nonunique = v-nonunique no-error .
      if available buf_dis-dct-rule
      then do:
        if p-mode = 'ДОБАВЛЕНИЕ':U then do:
          message
          "Скидка такого типа на данный тип ДК уже существует"
          view-as alert-box error .
          return error.
        end.
      end.
    end.
    if p-check = 1
    or p-check = 2
    then do:
      find first buf_temp-odisc no-lock where
                 buf_temp-odisc.host-code = p-host-code
              and buf_temp-odisc.obj-type = p-obj-type
              and buf_temp-odisc.obj-code = p-obj-code
              and buf_temp-odisc.type = p-type
              and buf_temp-odisc.emitent-host-code = p-emitent-host-code
              and buf_temp-odisc.pos-type = p-pos-type
              and buf_temp-odisc.discnt-role = p-discnt-role
              and buf_temp-odisc.nonunique = v-nonunique no-error .
      if available buf_temp-odisc
      and buf_temp-odisc.rule-num <> 0
      then do:
        if p-mode = 'ДОБАВЛЕНИЕ':U then do:
          message
        "Скидка такого типа на данный тип ДК уже существует"
          view-as alert-box error .
          return error.
        end.
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
define variable updated as logical no-undo.
DEFINE VARIABLE added  as logical no-undo .
define variable add-option as CHARACTER no-undo.
define variable ini-title as char no-undo.
define variable temp-doc-rec as recid no-undo.
define variable dops as character no-undo.
define variable dopst as character no-undo.
define variable v-tab-order as character no-undo .
DEFINE VARIABLE dflt-cd AS CHARACTER NO-UNDO.
define variable loc-glob as logical no-undo .
define variable loc-firm as logical no-undo .
define variable loc-object as logical no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable send-ref as logical no-undo.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'send-ref'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output dops
  ,output dopst
  ) no-error .
  send-ref = (IF error-status:error or dops <> "yes" then no else yes).
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE MENU MENU-b-add
       MENU-ITEM m_pos-type     LABEL "m_pos-type"
       MENU-ITEM m_no-pos       LABEL "По накладной"
       MENU-ITEM m_bo           LABEL "Бэкофис"      .
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Добавить скидку на тип ДК".
DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить скидку на тип ДК".
DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалитиь  скидку на тип ДК".
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1 TOOLTIP "Выход с сохранением".
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.
DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1 TOOLTIP "Выход из режима".
DEFINE VARIABLE card-emitent AS INTEGER FORMAT ">>>>>>>>>>9":U INITIAL 0
     LABEL "Эмитент"
      VIEW-AS TEXT
     SIZE 16.4 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE card-type AS CHARACTER FORMAT "X(16)":U
     LABEL "Тип карты"
      VIEW-AS TEXT
     SIZE 16.4 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE QUERY br-dis-dct FOR
      temp-odisc SCROLLING.
DEFINE BROWSE br-dis-dct
  QUERY br-dis-dct DISPLAY
      temp-odisc.templ-rl-root COLUMN-LABEL "Тип правила" FORMAT ">>>9":U
disdctru-get-disc-label(temp-odisc.templ-rl-root) COLUMN-LABEL 'Тип скидки' FORMAT "X(255)":U WIDTH 50
temp-odisc.rule-num COLUMN-LABEL "№ правила" FORMAT ">>>>>>>>9":U
temp-odisc.rl-root COLUMN-LABEL "№ корн.!правила" FORMAT ">>>>>>>>9":U
get-region(temp-odisc.host-code, temp-odisc.obj-type, temp-odisc.obj-code) COLUMN-LABEL "Действует" FORMAT "X(12)":U
entry (lookup (temp-odisc.pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U) FORMAT "X(20)":U COLUMn-LABEL "Место использ."
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-add AT ROW 1 COL 21
     B-lookup AT ROW 1 COL 31
     b-chg AT ROW 1 COL 41
     b-del AT ROW 1 COL 51
     b-help AT ROW 1 COL 95
     br-dis-dct AT ROW 4 COL 1
     card-type AT ROW 2.27 COL 1
     card-emitent AT ROW 2.27 COL 30.5 WIDGET-ID 2
     SPACE(43.10) SKIP(18.92)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Скидки на типы ДК".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-add:HANDLE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
  if p-pos-type = '':U then do:
    if add-option = '':U then do:
      run gbl/pop-up.p ( input self:handle, input no) no-error.
    end.
    if add-option = '':U then return no-apply.
  end.
  run proc-add-chg in this-procedure ( input yes, input add-option ) no-error.
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
  if not avail temp-odisc then return no-apply.
  run proc-add-chg in this-procedure ( input no, input temp-odisc.pos-type) no-error .
  if error-status:error then return no-apply.
  OPEN QUERY br-dis-dct FOR EACH temp-odisc NO-LOCK.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo.
define variable v-deleted as logical no-undo .
define variable v-rule-label as character no-undo .
  if not avail temp-odisc then return no-apply.
    run disdctru-name in this-procedure
      (input  temp-odisc.templ-rl-root
      ,output v-rule-label
      ) no-error .
    if error-status :error then do:
      return no-apply .
    end.
  loc#log = no.
  message
  substitute("Вы уверены, что хотите удалить скидку &1 (место использ &2) для типа ДК &3 (эмитент &4)"
           ,temp-odisc.templ-rl-root
           ,entry (lookup (temp-odisc.pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U)
           ,p-type
           ,p-emitent-host-code
           )
          view-as alert-box QUESTIOn buttons YES-NO update loc#log.
  if NOT loc#log then return no-apply.
  delete temp-odisc.
  updated = yes.
 OPEN QUERY br-dis-dct FOR EACH temp-odisc NO-LOCK.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame
DO:
  if not avail temp-odisc then return no-apply.
  RUN proc-b-lookup IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON MOUSE-SELECT-DBLCLICK OF br-dis-dct IN FRAME Dialog-Frame
DO:
  if not avail temp-odisc then return no-apply.
  RUN proc-b-lookup IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON RETURN OF br-dis-dct IN FRAME Dialog-Frame
DO:
  if not avail temp-odisc then return no-apply.
  RUN proc-b-lookup IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON VALUE-CHANGED OF br-dis-dct IN FRAME Dialog-Frame
DO:
  IF v-cntxt-db-num > 0
  AND (temp-odisc.obj-type = '':U
  OR temp-odisc.host-code = 0) THEN DO:
     DISABLE
     b-chg
     with FRAME Dialog-Frame.
  END.
  ELSE DO:
      enable
      b-chg WHEN (p-mode <> 'ПРОСМОТР':U)
      with FRAME Dialog-Frame.
  END.
END.
ON CHOOSE OF MENU-ITEM m_bo
DO:
    add-option = 'bo':U.
  run proc-add-chg in this-procedure ( input yes, input add-option ) no-error.
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_no-pos
DO:
  add-option = '-':U.
  run proc-add-chg in this-procedure ( input yes, input add-option ) no-error.
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_pos-type
DO:
  add-option = dflt-cd.
  run proc-add-chg in this-procedure ( input yes, input add-option ) no-error.
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.
END.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse br-dis-dct :handle
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-dis-dct :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
  OPEN QUERY br-dis-dct FOR EACH temp-odisc NO-LOCK.
    apply "VALUE-CHANGED" to br-dis-dct.
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
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
ON BACK-TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  assign
  ii = lookup(self:name, v-tab-order).
  .
  assign
  ii = (if ii = 1
        then  num-entries(v-tab-order)
        else ii - 1
        )
  v-next-widget-name = entry(ii, v-tab-order)
  .
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
      APPLY "BACK-TAB" to hh.
      return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
  end.
END.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  ini-title  = frame Dialog-Frame:TITLE.
  if NOT (p-mode = 'ПРОСМОТР':U
        or p-mode = 'ИЗМЕНЕНИЕ':U
        or p-mode = 'ДОБАВЛЕНИЕ':U
        ) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова p-mode" p-mode
    view-as alert-box ERROR.
    return error.
  end.
  for each  temp-odisc share-lock:
    delete temp-odisc.
  end.
  RUN MyEnable in this-procedure .
  Run init-proc in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI in this-procedure .
if updated then return 'ИЗМЕНЕНИЕ':U.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY card-type card-emitent
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-add B-lookup b-chg b-del b-help card-type card-emitent
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-dis-dct FOR EACH temp-odisc NO-LOCK.
END PROCEDURE.
PROCEDURE init-proc :
define variable v-rule-label as character no-undo .
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_clients for ub.clients.
for each  temp-odisc share-lock:
  if p-mode = 'ИЗМЕНЕНИЕ':U
  and (temp-odisc.obj-type = p-obj-type
      and
      temp-odisc.obj-code = p-obj-code)
  or (v-cntxt-db-num = 0
      and temp-odisc.obj-type = '':U
      and
      temp-odisc.obj-code = 0)
  or (v-cntxt-db-num = 0
      and temp-odisc.obj-type = 'орг':U
      and temp-odisc.obj-code = p-host-code)
      then do:
  end.
  else do:
    delete temp-odisc.
  end.
end.
if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
  Assign
  card-type = p-TYPE
  card-emitent = p-emitent-host-code
  .
  display
  card-type
  card-emitent
  with frame Dialog-Frame  .
end.
 For each tt0-dis-dct-rule where
         tt0-dis-dct-rule.type  = p-type
    and  tt0-dis-dct-rule.emitent-host-code  = p-emitent-host-code
    no-lock :
    if p-pos-type <> '':U
    and p-pos-type <> tt0-dis-dct-rule.pos-type then do:
      NEXT.
    end.
    if lookup(tt0-dis-dct-rule.discnt-role, p-discnt-role-list) = 0 then next.
    run disdctru-name ( input tt0-dis-dct-rule.templ-rl-root
                        ,output v-rule-label
                         ).
    find first temp-odisc where
              temp-odisc.discnt-role = tt0-dis-dct-rule.discnt-role
          AND temp-odisc.host-code = tt0-dis-dct-rule.host-code
          AND temp-odisc.obj-code = tt0-dis-dct-rule.obj-code
          AND temp-odisc.obj-type = tt0-dis-dct-rule.obj-type
          AND temp-odisc.type = tt0-dis-dct-rule.type
          AND temp-odisc.emitent-host-code = tt0-dis-dct-rule.emitent-host-code
          AND temp-odisc.nonunique = tt0-dis-dct-rule.nonunique
          AND temp-odisc.pos-type = tt0-dis-dct-rule.pos-type
          no-error.
    if not available temp-odisc then do:
      create temp-odisc.
      assign
      temp-odisc.host-code = tt0-dis-dct-rule.host-code
      temp-odisc.obj-code = tt0-dis-dct-rule.obj-code
      temp-odisc.obj-type = tt0-dis-dct-rule.obj-type
      temp-odisc.type = tt0-dis-dct-rule.type
      temp-odisc.emitent-host-code = tt0-dis-dct-rule.emitent-host-code
      temp-odisc.pos-type = tt0-dis-dct-rule.pos-type
      temp-odisc.nonunique = tt0-dis-dct-rule.nonunique
      temp-odisc.discnt-role = tt0-dis-dct-rule.discnt-role
      .
    end.
    assign
    temp-odisc.templ-rl-root = tt0-dis-dct-rule.templ-rl-root
    temp-odisc.time-templ-rl-root = tt0-dis-dct-rule.time-templ-rl-root
    temp-odisc.rule-num =  tt0-dis-dct-rule.rule-num
    temp-odisc.rl-root =  tt0-dis-dct-rule.rl-root
    temp-odisc.rule-label = v-rule-label
    .
  End.
  OPEN QUERY br-dis-dct FOR EACH temp-odisc NO-LOCK.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-h AS WIDGET-HANDLE NO-UNDO.
v-h = br-dis-dct:FIRST-COLUMN IN FRAME Dialog-Frame.
DO while valid-handle(v-h) :
  if v-h:LABEL = 'Тип скидки' then do:
    v-h:RESIZABLE = YES.
    leave.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.
IF p-obj-type = 'маг':U THEN DO:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type18 as character no-undo .
define variable v-value-date18 as date no-undo .
define variable v-value-decimal18 as decimal no-undo .
define variable v-value-integer18 as INTEGER no-undo .
define variable v-value-logical18 AS LOGICAL no-undo .
define variable v-tth18 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date18
    ,output v-value-decimal18
    ,output v-value-integer18
    ,output v-value-logical18
    ,output v-param-type18
    ,INPUT-OUTPUT table-handle v-tth18
    )  .
delete object v-tth18 no-error.
END.
if p-obj-type = 'скл':U then do:
  dflt-cd = '-':U.
end.
ASSIGN
b-add:POPUP-MENU IN FRAME Dialog-Frame = MENU MENU-b-add:HANDLE
b-add:MENU-MOUSE = 1
MENU-ITEM m_pos-type:LABEL IN MENU menu-b-add  = dflt-cd
MENU-ITEM m_pos-type:sensitive IN MENU menu-b-add  = ((dflt-cd <> '':U) and (dflt-cd <> '-':U))
.
if p-pos-type <> '':U then do:
  assign
  MENU-ITEM m_pos-type:sensitive IN MENU menu-b-add  = (MENU-ITEM m_pos-type:LABEL IN MENU menu-b-add = p-pos-type)
  MENU-ITEM m_bo:sensitive IN MENU menu-b-add  = (p-pos-type = 'bo':U)
  MENU-ITEM m_no-pos:sensitive IN MENU menu-b-add  = (p-pos-type = '-':U)
  .
end.
assign
v-tab-order = "b-exit,b-quit,b-add,b-lookup,b-chg,b-del,b-help,br-dis-dct".
                        .
DISPLAY
card-type
card-emitent
WITH FRAME Dialog-Frame.
ENABLE
b-exit when (p-mode <> 'ПРОСМОТР':U )
b-quit
b-del when (p-mode <> 'ПРОСМОТР':U )
b-add when (p-mode <> 'ПРОСМОТР':U )
b-chg when (p-mode <> 'ПРОСМОТР':U )
b-lookup
b-help br-dis-dct
card-type
WITH FRAME Dialog-Frame .
VIEW FRAME Dialog-Frame .
if p-mode = 'ПРОСМОТР':U then do:
  hide
  b-exit
  in frame Dialog-Frame .
  assign
  b-quit:label = "&Выход"
  b-quit:col    = 1
  .
end.
OPEN QUERY br-dis-dct FOR EACH temp-odisc NO-LOCK.
APPLY "ENTRY" to br-dis-dct.
END PROCEDURE.
PROCEDURE proc-add-chg :
define input parameter p-add as logical no-undo.
define input parameter p-pos-type as character no-undo.
define variable v-rule-label as character no-undo .
DEFINE VARIABLE v-rule-num as integer no-undo .
define variable v-setted as logical no-undo .
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-templ-rl-root as integer no-undo .
define variable v-time-templ-rl-root as integer no-undo .
define variable v-cfg-nonunique as character no-undo .
define variable v-nonunique as character no-undo .
define variable v-pos-type as character no-undo .
define variable v-discnt-role as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-host-code as integer no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
define buffer buf_temp-odisc for temp-odisc.
CASE p-add:
  when yes then do:
    run ref/dis-pos.w ( INPUT parparentproc
                        ,INPUT "b-sel":U
                        ,INPUT (if p-pos-type = '':U then 'все':U else "cd-type-list")
                        ,INPUT (if v-cntxt-db-num = 0 and loc-glob  then 1 else 0)
                        ,INPUT (if v-cntxt-db-num = 0 and loc-firm  then 1 else 0)
                        ,INPUT (if loc-object then 1 else 0)
                        ,input 'dis-dct-rule':U
                        ,input '':U
                        ,input ?
                        ,INPUT p-pos-type
                        ,input p-discnt-role-list
                        ,INPUT-OUTPUT v-rid-list) NO-ERROR.
   IF ERROR-STATUS:ERROR
   OR v-rid-list = '':U THEN DO:
      RETURN.
   END.
   FIND FIRST buf_dis-cfg-rule NO-LOCK where
             recid(buf_dis-cfg-rule) = INTEGER(v-rid-list).
    assign
    v-templ-rl-root = buf_dis-cfg-rule.templ-rl-root
    v-time-templ-rl-root = buf_dis-cfg-rule.time-templ-rl-root
    V-cfg-NONUNIQUE = buf_dis-cfg-rule.nonunique
    v-pos-type   = buf_dis-cfg-rule.pos-type
    v-discnt-role = buf_dis-cfg-rule.discnt-role
    .
    assign
    added = yes.
    v-rule-num = 0.
   if (buf_dis-cfg-rule.has-global +
       buf_dis-cfg-rule.has-host +
       buf_dis-cfg-rule.has-obj) > 1 then do:
      define variable v-sel-vals as character no-undo .
      define variable v-sel-labels as character no-undo .
      define variable var-region as character no-undo .
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
      v-obj-type = (if var-region begins 'орг':U
                    then ''
                    else trim(substring(var-region, 1, 3))
                    )
      v-obj-code = (if var-region begins 'орг':U
                    then 0
                    else  integer(substring(var-region, 4))
                    )
      v-host-code = (if var-region begins 'орг':U
                      then integer(substring(var-region, 4))
                      else 0)
      .
      if v-host-code = 0
       and v-obj-type <> '':U then do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output v-host-code
  )  .
      end.
    end.
    else do:
      if buf_dis-cfg-rule.has-obj = 1 then do:
        assign
        v-obj-type = p-obj-type
        v-obj-code = p-obj-code
        .
      end.
      if buf_dis-cfg-rule.has-host = 1 then do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
        assign
        v-obj-type = ""
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
  end.
  when no then do:
    find first buf_dis-cfg-rule no-lock where
              buf_dis-cfg-rule.table-name = 'dis-dct-rule':U
          and buf_dis-cfg-rule.discnt-role = temp-odisc.discnt-role
          and buf_dis-cfg-rule.pos-type = temp-odisc.pos-type
          no-error .
    if available buf_dis-cfg-rule then do:
      assign
      v-nonunique = buf_dis-cfg-rule.nonunique.
    end.
    v-rule-num  = temp-odisc.rule-num.
  end.
END CASE.
run disdctru-edit in this-procedure (
                                       input (if p-add then 'ДОБАВЛЕНИЕ':U else 'ИЗМЕНЕНИЕ':U)
                                      ,input p-type
                                      ,input p-emitent-host-code
                                      ,input (if p-add then v-host-code else temp-odisc.host-code)
                                      ,input (if p-add then v-obj-type  else temp-odisc.obj-type)
                                      ,input (if p-add then v-obj-code  else temp-odisc.obj-code)
                                      ,INPUT (if p-add then v-pos-type else temp-odisc.pos-type)
                                      ,input (if p-add then v-discnt-role else temp-odisc.discnt-role)
                                      ,input (if p-add then v-templ-rl-root else temp-odisc.templ-rl-root)
                                      ,input (if p-add then v-time-templ-rl-root else temp-odisc.time-templ-rl-root)
                                      ,input v-cfg-nonunique
                                      ,input 1
                                      ,input-output v-rule-num
                                      ,input-output v-nonunique
                                      ,output v-setted ) no-error.
if not v-setted then return error.
run temp-disdcrul-write in this-procedure (
                                           input p-type
                                          ,input p-emitent-host-code
                                          ,input (if p-add then v-host-code else temp-odisc.host-code)
                                          ,input (if p-add then v-obj-type else temp-odisc.obj-type)
                                          ,input (if p-add then v-obj-code else temp-odisc.obj-code)
                                          ,input (if p-add then v-pos-type else temp-odisc.pos-type)
                                          ,input (if p-add then v-templ-rl-root else temp-odisc.templ-rl-root)
                                          ,input (if p-add then v-time-templ-rl-root else temp-odisc.time-templ-rl-root)
                                          ,input (if p-add then v-discnt-role else temp-odisc.discnt-role)
                                          ,input (if p-add then ? else temp-odisc.nonunique)
                                          ,input v-rule-num
                                          ,input v-nonunique
                                          ) no-error .
IF not error-status:error then do:
  assign
  updated = yes
  .
  br-dis-dct:refresh() in frame Dialog-Frame no-error .
END.
assign
added = no.
if p-add = yes then do:
  OPEN QUERY br-dis-dct FOR EACH temp-odisc NO-LOCK.
  find first buf_temp-odisc no-lock where
            buf_temp-odisc.pos-type = add-option
        AND buf_temp-odisc.templ-rl-root = v-templ-rl-root
        AND buf_temp-odisc.nonunique = v-nonunique
       and buf_temp-odisc.pos-type = add-option
       and buf_temp-odisc.host-code = v-host-code
       and buf_temp-odisc.obj-type = v-obj-type
       and buf_temp-odisc.obj-code = v-obj-code
      no-error.
  add-option = '':U.
  if avail buf_temp-odisc then
      temp-doc-rec = recid(buf_temp-odisc).
      else temp-doc-rec = ?.
  reposition br-dis-dct to recid temp-doc-rec no-error.
  if error-status:error then return no-apply.
end.
END PROCEDURE.
PROCEDURE proc-b-lookup :
define variable disc-label as character no-undo .
run disdctru-name in this-procedure (
                                      input temp-odisc.templ-rl-root
                                    , output disc-label
                                ) no-error.
IF ERROR-STATUS:ERROR THEN DO:
    message "Ошибка при определении названия и типа скидки на тип ДК!"         skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
    return error.
END.
run ref/show-dr.p ( input parparentproc
                   ,input temp-odisc.rule-num) no-error.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-updated AS LOGICAL NO-UNDO.
define variable v-created as logical no-undo .
define variable v-deleted as logical no-undo .
define variable v-updated-str as character no-undo .
for each temp-odisc NO-LOCK where
         temp-odisc.type = p-type
     and temp-odisc.emitent-host-code = p-emitent-host-code
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo , return error substitute( "&1. stop", vss-workfile )
on endkey undo , return error substitute( "&1. endkey", vss-workfile ):
  if temp-odisc.obj-type = "" and v-cntxt-db-num <> 0 then next.
  if temp-odisc.host-code = 0 and v-cntxt-db-num <> 0 then next.
  find first tt0-dis-dct-rule NO-LOCK WHERE
          tt0-dis-dct-rule.type = temp-odisc.type
    AND   tt0-dis-dct-rule.host-code = temp-odisc.host-code
    AND   tt0-dis-dct-rule.obj-type = temp-odisc.obj-type
    AND   tt0-dis-dct-rule.obj-code = temp-odisc.obj-code
    AND   tt0-dis-dct-rule.pos-type = temp-odisc.pos-type
    AND   tt0-dis-dct-rule.discnt-role = temp-odisc.discnt-role
    AND tt0-dis-dct-rule.nonunique = temp-odisc.nonunique
    no-error.
  assign
  v-updated = no.
  if available  tt0-dis-dct-rule then do:
    BUFFER-COMPARE temp-odisc
                TO tt0-dis-dct-rule
                case-sensitive
                SAVE result IN v-updated-str.
    assign
    v-created = yes
    v-updated = (v-updated-str <> "":U)
    .
  end.
  else do:
    assign
    v-updated = yes.
  end.
  if v-updated then do:
    run tt0-disdcrul-write in this-procedure(
                                     input p-type
                                    ,input p-emitent-host-code
                                    ,input temp-odisc.host-code
                                    ,input temp-odisc.obj-type
                                    ,input temp-odisc.obj-code
                                    ,input temp-odisc.pos-type
                                    ,input temp-odisc.templ-rl-root
                                    ,input temp-odisc.time-templ-rl-root
                                    ,input temp-odisc.discnt-role
                                    ,input temp-odisc.rule-num
                                    ,input temp-odisc.nonunique
                                    )  no-error.
    if error-status:error then do:
      message
      "Ошибка при сохранении скидки на тип ДК" skip
      "Тип" p-type skip
      "Эмитент" p-emitent-host-code skip
      "объект" temp-odisc.obj-type temp-odisc.obj-code
      "Фирма" temp-odisc.host-code
      "Тип скидки" temp-odisc.templ-rl-root
      "Место использ." temp-odisc.pos-type
      view-as alert-box  error .
      undo, return error  .
    end.
    updated = yes.
  end.
End.
FOR EACH tt0-dis-dct-rule where
         tt0-dis-dct-rule.type = p-type
     and tt0-dis-dct-rule.emitent-host-code = p-emitent-host-code
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo , return error substitute( "&1. stop", vss-workfile )
on endkey undo , return error substitute( "&1. endkey", vss-workfile ):
  if p-pos-type <> '':U
  and p-pos-type <> tt0-dis-dct-rule.pos-type then do:
    NEXT.
  end.
  if tt0-dis-dct-rule.obj-type = "" and v-cntxt-db-num <> 0 then next.
  if tt0-dis-dct-rule.host-code = 0 and v-cntxt-db-num <> 0 then next.
  FIND FIRST temp-odisc NO-LOCK WHERE
            temp-odisc.type = tt0-dis-dct-rule.type
        AND temp-odisc.host-code = tt0-dis-dct-rule.host-code
        AND temp-odisc.obj-type = tt0-dis-dct-rule.obj-type
        AND temp-odisc.obj-code = tt0-dis-dct-rule.obj-code
        AND temp-odisc.pos-type = tt0-dis-dct-rule.pos-type
        AND temp-odisc.discnt-role = tt0-dis-dct-rule.discnt-role
        AND temp-odisc.nonunique = tt0-dis-dct-rule.nonunique
        NO-ERROR.
    IF NOT AVAILABLE temp-odisc THEN DO:
      DELETE tt0-dis-dct-rule.
      assign
      v-deleted = yes.
    END.
END.
END PROCEDURE.
PROCEDURE temp-disdcrul-write :
do
  on error undo, return error
  :
    define input parameter p-type like ub.dis-dct-rule.type   no-undo .
    define input parameter p-emitent-host-code like ub.dis-dct-rule.emitent-host-code no-undo .
    define input parameter p-host-code like ub.dis-dct-rule.host-code no-undo .
    define input parameter p-obj-type like ub.dis-dct-rule.obj-type   no-undo .
    define input parameter p-obj-code like ub.dis-dct-rule.obj-code   no-undo .
    define input parameter p-pos-type like ub.dis-dct-rule.pos-type  no-undo .
    define input parameter p-templ-rl-root     like ub.dis-dct-rule.templ-rl-root  no-undo .
    define input parameter p-time-templ-rl-root     like ub.dis-dct-rule.time-templ-rl-root  no-undo .
    define input parameter p-discnt-role like ub.dis-dct-rule.discnt-role no-undo .
    define input parameter p-was-nonunique like ub.dis-dct-rule.nonunique no-undo .
    define input parameter p-rule-num  like ub.dis-dct-rule.rule-num no-undo .
    define input parameter p-nonunique like ub.dis-dct-rule.nonunique no-undo .
    define variable v-rule-label as character no-undo .
    define buffer buf_temp-odisc for temp-odisc .
    define buffer buf_Dis-rule for ub.dis-rule.
    run disdctru-name in this-procedure (
                                           input  p-templ-rl-root
                                          ,output v-rule-label
                                          ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_temp-odisc exclusive-lock where
               buf_temp-odisc.type  = p-type
           and buf_temp-odisc.emitent-host-code = p-emitent-host-code
           AND buf_temp-odisc.host-code  = p-host-code
           AND buf_temp-odisc.obj-type  = p-obj-type
           AND buf_temp-odisc.obj-code  = p-obj-code
           AND buf_temp-odisc.pos-type  = p-pos-type
           AND buf_temp-odisc.discnt-role = p-discnt-role
           AND buf_temp-odisc.nonunique = (if p-was-nonunique = ? then p-nonunique else p-was-nonunique)
           no-error no-wait .
    if not available buf_temp-odisc then do:
      create buf_temp-odisc .
      assign
      buf_temp-odisc.type  = p-type
      buf_temp-odisc.emitent-host-code = p-emitent-host-code
      buf_temp-odisc.obj-type  = p-obj-type
      buf_temp-odisc.obj-code  = p-obj-code
      buf_temp-odisc.host-code  = p-host-code
      buf_temp-odisc.pos-type  = p-pos-type
      buf_temp-odisc.rule-num = p-rule-num
      buf_temp-odisc.nonunique = p-nonunique
      buf_temp-odisc.discnt-role = p-discnt-role
      no-error
      .
    end.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-rule-num.
    ASSIGN
    buf_temp-odisc.rule-num =  p-rule-num
    buf_temp-odisc.time-templ-rl-root = p-time-templ-rl-root
    buf_temp-odisc.nonunique = p-nonunique
    buf_temp-odisc.templ-rl-root = p-templ-rl-root
    buf_temp-odisc.rl-root = buf_dis-rule.rl-root
    no-error.
  end.
END PROCEDURE.
PROCEDURE tt0-disdcrul-write :
do
on error undo, return error
:
  define input parameter p-type like ub.dis-dct-rule.type   no-undo .
  define input parameter p-emitent-host-code like ub.dis-dct-rule.emitent-host-code no-undo .
  define input parameter p-host-code like ub.dis-dct-rule.host-code no-undo .
  define input parameter p-obj-type like ub.dis-dct-rule.obj-type   no-undo .
  define input parameter p-obj-code like ub.dis-dct-rule.obj-code   no-undo .
  define input parameter p-pos-type like ub.dis-dct-rule.pos-type   no-undo .
  define input parameter p-templ-rl-root     like ub.dis-dct-rule.templ-rl-root  no-undo .
  define input parameter p-time-templ-rl-root     like ub.dis-dct-rule.time-templ-rl-root  no-undo .
  define input parameter p-discnt-role       like ub.dis-dct-rule.discnt-role no-undo .
  define input parameter p-rule-num    like ub.dis-dct-rule.rule-num no-undo .
  define input parameter p-nonunique like ub.dis-dct-rule.nonunique no-undo .
  define variable v-rule-label          as character no-undo .
  define buffer buf_tt0-dis-dct-rule for tt0-dis-dct-rule .
  define buffer buf_Dis-rule for ub.dis-rule.
  run disdctru-name in this-procedure (
                                      input  p-templ-rl-root
                                      ,output v-rule-label
                                      ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.
  find first buf_tt0-dis-dct-rule exclusive-lock where
              buf_tt0-dis-dct-rule.type  = p-type
          and buf_tt0-dis-dct-rule.emitent-host-code  = p-emitent-host-code
          AND buf_tt0-dis-dct-rule.host-code  = p-host-code
          AND buf_tt0-dis-dct-rule.obj-type  = p-obj-type
          AND buf_tt0-dis-dct-rule.obj-code  = p-obj-code
          AND buf_tt0-dis-dct-rule.pos-type  = p-pos-type
          AND buf_tt0-dis-dct-rule.discnt-role = p-discnt-role
          AND buf_tt0-dis-dct-rule.nonunique = p-nonunique
          no-error .
  if not available buf_tt0-dis-dct-rule then do:
    create buf_tt0-dis-dct-rule .
    assign
    buf_tt0-dis-dct-rule.type  = p-type
    buf_tt0-dis-dct-rule.emitent-host-code  = p-emitent-host-code
    buf_tt0-dis-dct-rule.obj-type  = p-obj-type
    buf_tt0-dis-dct-rule.obj-code  = p-obj-code
    buf_tt0-dis-dct-rule.host-code  = p-host-code
    buf_tt0-dis-dct-rule.pos-type  = p-pos-type
    buf_tt0-dis-dct-rule.nonunique = p-nonunique
    buf_tt0-dis-dct-rule.discnt-role = p-discnt-role
    no-error
    .
  end.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-rule-num.
  ASSIGN
  buf_tt0-dis-dct-rule.templ-rl-root = p-templ-rl-root
  buf_tt0-dis-dct-rule.rule-num = p-rule-num
  buf_tt0-dis-dct-rule.rl-root = buf_Dis-rule.rl-root
  buf_tt0-dis-dct-rule.time-templ-rl-root = p-time-templ-rl-root
  buf_tt0-dis-dct-rule.nonunique = p-nonunique
  no-error.
  release buf_tt0-dis-dct-rule no-error .
  if error-status:error then do:
    undo, return error return-value .
  end.
end.
END PROCEDURE.
