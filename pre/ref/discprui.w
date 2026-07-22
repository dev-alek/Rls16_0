DEFINE TEMP-TABLE temp-cpdisc NO-UNDO LIKE ub.dis-cp-rule
       field rule-label as character.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as char no-undo.
define input parameter p-cdpay-code like ub.dis-cp-rule.cdpay-code no-undo.
define input parameter p-curr-code  like ub.dis-cp-rule.curr-code no-undo .
define input parameter p-host-code like ub.dis-cp-rule.host-code no-undo.
define input parameter p-obj-type like ub.dis-cp-rule.obj-type no-undo.
define input parameter p-obj-code like ub.dis-cp-rule.obj-code no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Скидки на платеж".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    ,output p-pos-type
    ,output v-value-date5
    ,output v-value-decimal5
    ,output v-value-integer5
    ,output v-value-logical5
    ,output v-param-type5
    ,INPUT-OUTPUT table-handle v-tth5
    )  .
delete object v-tth5 no-error.
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type6 as character no-undo .
define variable v-value-date6 as date no-undo .
define variable v-value-decimal6 as decimal no-undo .
define variable v-value-integer6 as INTEGER no-undo .
define variable v-value-logical6 AS LOGICAL no-undo .
define variable v-tth6 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date6
    ,output v-value-decimal6
    ,output v-value-integer6
    ,output v-value-logical6
    ,output v-param-type6
    ,INPUT-OUTPUT table-handle v-tth6
    )  .
delete object v-tth6 no-error.
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
define variable updated as logical no-undo.
DEFINE VARIABLE added  as logical no-undo .
define variable add-option as char no-undo.
define variable temp-doc-rec as recid no-undo.
DEFINE VARIABLE dflt-cd AS CHARACTER NO-UNDO.
define variable v-tab-order as character no-undo .
define variable loc-glob as logical no-undo .
define variable loc-firm as logical no-undo .
define variable loc-object as logical no-undo .
DEFINE MENU MENU-b-ins
       MENU-ITEM m_pos-type     LABEL "m_pos-type"
       MENU-ITEM m_bo           LABEL "Бэкофис"      .
DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить скидку на платеж".
DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить скидку на платеж".
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.
DEFINE BUTTON b-ins
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Добавить скидку на платеж".
DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE 10 BY 1 TOOLTIP "Просмотр скидки на платеж".
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1 TOOLTIP "Выход из режима".
DEFINE VARIABLE cd-cdpay-code AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "Код типа платежа"
      VIEW-AS TEXT
     SIZE 9.6 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE cd-curr-code AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Код валюты"
      VIEW-AS TEXT
     SIZE 6 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE v-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 55 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE QUERY BR-dis-cp FOR
      temp-cpdisc SCROLLING.
DEFINE BROWSE BR-dis-cp
  QUERY BR-dis-cp DISPLAY
      temp-cpdisc.templ-rl-root COLUMN-LABEL "" FORMAT ">9":U
discpru-get-disc-label(temp-cpdisc.templ-rl-root) COLUMN-LABEL "Тип скидки" FORMAT "X(50)":U
get-region(temp-cpdisc.host-code, temp-cpdisc.obj-type, temp-cpdisc.obj-code) COLUMN-LABEL "Действует" FORMAT "X(12)":U
    WIDTH 13
temp-cpdisc.rule-num COLUMN-LABEL "№ правила" FORMAT ">>>>>>>>9":U
temp-cpdisc.rl-root COLUMN-LABEL "№ корн.!правила" FORMAT ">>>>>>>>9":U
entry (lookup (temp-cpdisc.pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U) FORMAT "X(20)":U COLUMN-LABEL "Место использ."
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.33.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-ins AT ROW 1 COL 21
     b-lkp AT ROW 1 COL 31
     b-chg AT ROW 1 COL 41
     b-del AT ROW 1 COL 51
     b-help AT ROW 1 COL 95
     BR-dis-cp AT ROW 4.47 COL 1
     v-obj-name AT ROW 2 COL 2.5 NO-LABEL
     cd-cdpay-code AT ROW 3.27 COL 2.5
     cd-curr-code AT ROW 3.27 COL 33.5
     SPACE(47.59) SKIP(15.69)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Скидки на платеж".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-ins:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-ins:HANDLE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
  if not avail temp-cpdisc then return no-apply.
  run proc-add-chg in this-procedure ( input no, input temp-cpdisc.pos-type) no-error .
  if error-status:error then return no-apply.
  RUN init-proc in this-procedure .
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
define variable v-deleted as logical no-undo.
define variable loc#log as logical no-undo .
define variable v-rule-label as character no-undo .
  if not avail temp-cpdisc then return no-apply.
    run discpru-name in this-procedure
      (input  temp-cpdisc.templ-rl-root
      ,output v-rule-label
      ) no-error .
    if error-status :error then do:
      return no-apply .
    end.
  loc#log = no.
  message
  substitute("Вы уверены, что хотите удалить скидку &1 (POS &2) на фирме &3 &4&5 для платежа"
           ,v-rule-label
           ,entry (lookup (temp-cpdisc.pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U)
           ,temp-cpdisc.host-code
           ,temp-cpdisc.obj-type
           ,temp-cpdisc.obj-code
           )
          view-as alert-box QUESTIOn buttons YES-NO update loc#log.
  if NOT loc#log then return no-apply.
  run discpru-delete in this-procedure(
                                   input p-cdpay-code
                                  ,input p-curr-code
                                  ,input temp-cpdisc.host-code
                                  ,input temp-cpdisc.obj-type
                                  ,input temp-cpdisc.obj-code
                                  ,input temp-cpdisc.pos-type
                                  ,input temp-cpdisc.discnt-role
                                  ,input temp-cpdisc.nonunique
                                  ,output v-deleted
                                  ) no-error .
  if error-status:error then do:
    return no-apply.
  end.
  delete temp-cpdisc.
  updated = yes.
  run init-proc in this-procedure .
END.
ON CHOOSE OF b-ins IN FRAME Dialog-Frame
DO:
 if add-option = '':U then do:
       run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if add-option = '':U then return no-apply.
  run proc-add-chg in this-procedure ( input yes, input add-option ) no-error.
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
  IF not AVAILABLE temp-cpdisc then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
END.
ON MOUSE-SELECT-DBLCLICK OF BR-dis-cp IN FRAME Dialog-Frame
DO:
  IF not AVAILABLE temp-cpdisc then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON RETURN OF BR-dis-cp IN FRAME Dialog-Frame
DO:
  IF not AVAILABLE temp-cpdisc then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON VALUE-CHANGED OF BR-dis-cp IN FRAME Dialog-Frame
DO:
  IF v-cntxt-db-num > 0
  AND (temp-cpdisc.obj-type = 'орг':U
  OR temp-cpdisc.obj-type = '':U) THEN DO:
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-dis-cp :handle
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
 frame Dialog-Frame:TITLE = frame Dialog-Frame:TITLE.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if v-cntxt-db-num = 0 then do:
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_сp-discount_global_work':U
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
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cp-discount_firm_work':U
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
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cp-discount_object_work':U
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
    "У Вас отсутствуют права на назначение скидки на тип платежа как по объекту, так и по фирме и глобально" skip
    "либо Вы находитесь в БД, в которой их назначить невозможно"
    view-as alert-box error .
    undo, return.
  end.
  RUN MyEnable in this-procedure no-error.
  if error-status:error then return error.
  Run init-proc in this-procedure .
  view frame Dialog-Frame .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI in this-procedure .
if updated then return 'ИЗМЕНЕНИЕ':U.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-obj-name cd-cdpay-code cd-curr-code
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-ins b-lkp b-chg b-del b-help v-obj-name cd-cdpay-code
         cd-curr-code
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-dis-cp FOR EACH temp-cpdisc NO-LOCK.
END PROCEDURE.
PROCEDURE init-proc :
define variable v-rule-label as character no-undo .
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
for each temp-cpdisc:
  if p-mode = 'ИЗМЕНЕНИЕ':U
  and (temp-cpdisc.obj-type = p-obj-type
    and
    temp-cpdisc.obj-code = p-obj-code)
  or (v-cntxt-db-num = 0
    and temp-cpdisc.obj-type = '':U
    and
    temp-cpdisc.obj-code = 0)
  or (v-cntxt-db-num = 0
    and temp-cpdisc.obj-type = 'орг':U
    and temp-cpdisc.obj-code = p-host-code)
    then do:
  end.
  else do:
    delete temp-cpdisc.
  end.
end.
add-option = "".
find first buf_cash-pay where
        buf_cash-pay.cdpay-code =  p-cdpay-code
    AND buf_cash-pay.curr-code = p-curr-code   no-lock no-error .
Assign
cd-cdpay-code = buf_cash-pay.cdpay-code
cd-curr-code = buf_cash-pay.curr-code
.
display
cd-cdpay-code
cd-curr-code
with frame Dialog-Frame  .
For each buf_dis-cp-rule where
        buf_dis-cp-rule.cdpay-code  = p-cdpay-code
    and  buf_dis-cp-rule.curr-code  = p-curr-code no-lock
on error undo, return error
    :
  find first temp-cpdisc where
            temp-cpdisc.cdpay-code = buf_dis-cp-rule.cdpay-code
       and  temp-cpdisc.curr-code = buf_dis-cp-rule.curr-code
       and  temp-cpdisc.host-code = buf_dis-cp-rule.host-code
       and  temp-cpdisc.obj-type = buf_dis-cp-rule.obj-type
       and  temp-cpdisc.obj-code = buf_dis-cp-rule.obj-code
       and  temp-cpdisc.pos-type = buf_dis-cp-rule.pos-type
       and  temp-cpdisc.discnt-role = buf_dis-cp-rule.discnt-role
       and  temp-cpdisc.nonunique = buf_dis-cp-rule.nonunique no-error.
  if not available temp-cpdisc then do:
    create temp-cpdisc.
    assign
    temp-cpdisc.cdpay-code = buf_dis-cp-rule.cdpay-code
    temp-cpdisc.curr-code = buf_dis-cp-rule.curr-code
    temp-cpdisc.host-code = buf_dis-cp-rule.host-code
    temp-cpdisc.obj-type = buf_dis-cp-rule.obj-type
    temp-cpdisc.obj-code = buf_dis-cp-rule.obj-code
    temp-cpdisc.pos-type = buf_dis-cp-rule.pos-type
    temp-cpdisc.discnt-role = buf_dis-cp-rule.discnt-role
    temp-cpdisc.nonunique = buf_dis-cp-rule.nonunique
    .
  end.
  assign
  temp-cpdisc.rule-num = buf_Dis-cp-rule.rule-num
  temp-cpdisc.rl-root = buf_Dis-cp-rule.rl-root
  temp-cpdisc.templ-rl-root = buf_Dis-cp-rule.templ-rl-root
  temp-cpdisc.time-templ-rl-root = buf_Dis-cp-rule.time-templ-rl-root
  .
  run discpru-name ( input buf_dis-cp-rule.templ-rl-root
                      ,output v-rule-label
                        ).
  assign
  temp-cpdisc.rule-label = v-rule-label
  .
End.
OPEN QUERY BR-dis-cp FOR EACH temp-cpdisc NO-LOCK.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE BUFFER buf_Cash-pay FOR ub.cash-pay.
DEFINE VARIABLE v-h AS WIDGET-HANDLE NO-UNDO.
v-h = br-dis-cp:FIRST-COLUMN IN FRAME Dialog-Frame.
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type14 as character no-undo .
define variable v-value-date14 as date no-undo .
define variable v-value-decimal14 as decimal no-undo .
define variable v-value-integer14 as INTEGER no-undo .
define variable v-value-logical14 AS LOGICAL no-undo .
define variable v-tth14 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date14
    ,output v-value-decimal14
    ,output v-value-integer14
    ,output v-value-logical14
    ,output v-param-type14
    ,INPUT-OUTPUT table-handle v-tth14
    )  .
delete object v-tth14 no-error.
END.
if p-obj-type = 'скл':U then do:
  dflt-cd = '-':U.
end.
ASSIGN
b-ins:POPUP-MENU IN FRAME Dialog-Frame = MENU MENU-b-ins:HANDLE
b-ins:MENU-MOUSE = 1
MENU-ITEM m_pos-type:LABEL IN MENU menu-b-ins  = dflt-cd
MENU-ITEM m_pos-type:sensitive IN MENU menu-b-ins  = ((dflt-cd <> '':U) and (dflt-cd <> '-':U))
MENU-ITEM m_bo:sensitive IN MENU menu-b-ins  = no
.
assign
v-tab-order = "b-quit,b-ins,b-lkp,b-chg,b-del,b-help,br-dis-cp".
FIND FIRST buf_Cash-pay NO-LOCK WHERE
            buf_Cash-pay.cdpay-code = p-cdpay-code
      AND   buf_Cash-pay.curr-code = p-curr-code NO-ERROR.
IF AVAILABLE buf_cash-pay THEN DO:
    ASSIGN
    v-obj-name = buf_cash-pay.obj-name.
END.
ASSIGN b-ins:MENU-MOUSE in frame Dialog-Frame  = 1.
DISPLAY
v-obj-name
WITH FRAME Dialog-Frame .
ENABLE
b-quit
b-del when p-mode = 'ИЗМЕНЕНИЕ':U
b-ins when p-mode = 'ИЗМЕНЕНИЕ':U
b-chg when p-mode = 'ИЗМЕНЕНИЕ':U
b-lkp
b-help BR-dis-cp
WITH FRAME Dialog-Frame .
VIEW FRAME Dialog-Frame .
OPEN QUERY BR-dis-cp FOR EACH temp-cpdisc NO-LOCK.
APPLY "ENTRY" to br-dis-cp.
END PROCEDURE.
PROCEDURE proc-add-chg :
define input parameter p-add as logical no-undo .
define input parameter p-pos-type as character no-undo .
define variable v-rule-label as character no-undo .
DEFINE VARIABLE v-rule-num as integer no-undo .
define variable v-setted as logical no-undo .
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-templ-rl-root as integer no-undo .
define variable v-time-templ-rl-root as integer no-undo .
define variable v-cfg-nonunique as character no-undo .
define variable v-nonunique as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
define buffer buf_temp-cpdisc for temp-cpdisc.
DEFINE VARIABLE v-deleted as logical no-undo .
define variable v-check as character no-undo .
define variable v-error-code as character no-undo .
define variable v-correct as logical no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-obj-type like ub.clients.obj-type no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-ask-labels as character no-undo .
define variable choice as integer no-undo .
define variable v-discnt-role as character no-undo .
define var loc#log as logical no-undo.
CASE p-add:
  when yes then do:
    run ref/dis-pos.w ( INPUT parparentproc
                        ,INPUT "b-sel":U
                        ,INPUT "cd-type-list"
                        ,INPUT (if v-cntxt-db-num = 0 and loc-glob  then 1 else 0)
                        ,INPUT (if v-cntxt-db-num = 0 and loc-firm  then 1 else 0)
                        ,INPUT (if loc-object then 1 else 0)
                        ,input 'dis-cp-rule':U
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
    assign
    v-templ-rl-root = buf_dis-cfg-rule.templ-rl-root
    v-time-templ-rl-root = buf_dis-cfg-rule.time-templ-rl-root
    V-cfg-NONUNIQUE = buf_dis-cfg-rule.nonunique
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
      v-obj-type = trim(substring(var-region, 1, 3))
      v-obj-code = integer(substring(var-region, 4))
      v-host-code = (if var-region begins 'орг':U
                     then integer(substring(var-region, 4))
                     else 0)
      v-obj-code = (if v-obj-type = 'орг':U then 0 else v-obj-code)
      v-obj-type = (if v-obj-type = 'орг':U then "" else v-obj-type)
    .
      if v-host-code = 0
       and v-obj-type <> '':U then do:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
      end.
      if buf_dis-cfg-rule.has-host = 1 then do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
              buf_dis-cfg-rule.table-name = 'dis-cp-rule':U
          and buf_dis-cfg-rule.discnt-role = temp-cpdisc.discnt-role
          and buf_dis-cfg-rule.pos-type = temp-cpdisc.pos-type
          no-error .
    if available buf_dis-cfg-rule then do:
      assign
      v-nonunique = buf_dis-cfg-rule.nonunique.
    end.
    v-rule-num  = temp-cpdisc.rule-num.
  end.
END CASE.
run discpru-edit in this-procedure (   input (if p-add then 'ДОБАВЛЕНИЕ':U else 'ИЗМЕНЕНИЕ':U)
                                      ,input p-cdpay-code
                                      ,input p-curr-code
                                      ,input (if p-add then v-host-code else temp-cpdisc.host-code)
                                      ,input (if p-add then v-obj-type  else temp-cpdisc.obj-type)
                                      ,input (if p-add then v-obj-code  else temp-cpdisc.obj-code)
                                      ,INPUT (if p-add then p-pos-type else temp-cpdisc.pos-type)
                                      ,INPUT (if p-add then v-discnt-role else temp-cpdisc.discnt-role)
                                      ,input (if p-add then v-templ-rl-root else temp-cpdisc.templ-rl-root)
                                      ,input (if p-add then v-time-templ-rl-root else temp-cpdisc.time-templ-rl-root)
                                      ,input v-cfg-nonunique
                                      ,input 1
                                      ,input-output v-rule-num
                                      ,input-output v-nonunique
                                      ,output v-setted ) no-error.
if not v-setted then return error.
run discpru-write in this-procedure (
                                        input p-cdpay-code
                                        ,input p-curr-code
                                        ,input (if p-add then v-host-code else temp-cpdisc.host-code)
                                        ,input (if p-add then v-obj-type else temp-cpdisc.obj-type)
                                        ,input (if p-add then v-obj-code else temp-cpdisc.obj-code)
                                        ,input (if p-add then add-option else temp-cpdisc.pos-type)
                                        ,input (if p-add then v-discnt-role else temp-cpdisc.discnt-role)
                                        ,input (if p-add then v-templ-rl-root else temp-cpdisc.templ-rl-root)
                                        ,input (if p-add then v-time-templ-rl-root else temp-cpdisc.time-templ-rl-root)
                                        ,input v-rule-num
                                        ,input v-nonunique
                                      ) no-error .
  IF NOT error-status:error then do:
      assign
      updated = yes
      .
  END.
Run init-proc in this-procedure .
find first buf_temp-cpdisc no-lock where
          buf_temp-cpdisc.host-code =  (if p-add then v-host-code else temp-cpdisc.host-code)
      AND buf_temp-cpdisc.obj-type = (if p-add then v-obj-type else temp-cpdisc.obj-type)
      AND buf_temp-cpdisc.obj-code = (if p-add then v-obj-code else temp-cpdisc.obj-code)
      AND buf_temp-cpdisc.pos-type = (if p-add then add-option else temp-cpdisc.pos-type)
      AND buf_temp-cpdisc.pos-type = (if p-add then add-option else temp-cpdisc.pos-type)
      AND buf_temp-cpdisc.discnt-role = (if p-add then v-discnt-role else temp-cpdisc.discnt-role)
      AND buf_temp-cpdisc.nonunique = (if p-add then v-nonunique else temp-cpdisc.nonunique)
      no-error.
add-option = "":U.
if avail buf_temp-cpdisc then
temp-doc-rec = recid(buf_temp-cpdisc).
else temp-doc-rec = ?.
reposition BR-dis-cp to recid temp-doc-rec no-error.
if error-status:error then return no-apply.
END PROCEDURE.
PROCEDURE proc-b-lkp :
define variable disc-label as character no-undo .
run discpru-name in this-procedure (
                                      input temp-cpdisc.templ-rl-root
                                    , output disc-label
                                ) no-error.
IF ERROR-STATUS:ERROR THEN DO:
    return error.
END.
run ref/show-dr.p ( input parparentproc
                   ,input temp-cpdisc.rule-num) no-error.
END PROCEDURE.
