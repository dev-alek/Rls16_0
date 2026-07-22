block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: csh-lst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/csh-lst.p $":U .
define variable vss-description as character no-undo init "Пакетное изменение по списку скидок кассовых платежей по объекту".
DEFINE TEMP-TABLE temp-cpdisc NO-UNDO LIKE ub.dis-cp-rule
       field rule-label as character.
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
DEFINE VARIABLE var-object as character no-undo init 'dis-cp-rule':U.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define SHARED temp-table temp-disc no-undo
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
  case var-object:
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
  CASE var-object:
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
    case var-object:
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
    case var-object:
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
    case var-object:
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
define variable p-rid-list  as character              no-undo .
define variable v-no-ask      as logical   no-undo .
define variable v-view-log    as logical   no-undo .
define variable log-file-name as character no-undo init "csh-lst.txt".
define variable v-stop        as logical   no-undo .
define variable v-choice      as integer   no-undo .
define variable v-i           as integer   no-undo .
define variable v-err-cnt     as integer   no-undo init 0 .
define variable v-deleted     as logical   no-undo .
DEFINE VARIABLE num-rec       as integer no-undo .
DEFINE VARIABLE num-rec-ok    as integer no-undo .
define variable v-cdpay-code like ub.dis-cp-rule.cdpay-code no-undo .
define variable v-curr-code  like ub.dis-cp-rule.curr-code  no-undo .
define variable v-obj-name   as character no-undo .
define variable v-rule-num   as integer   no-undo .
define variable v-nonunique  as character no-undo .
def buffer buf_cash-pay    for ub.cash-pay .
def buffer buf_dis-cp-rule for ub.dis-cp-rule .
assign
p-rid-list = p-parameter
no-error
.
if error-status:error then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При изменении скидок кассовых платежей на объекте по списку кассовых платежей произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action10   as character no-undo .
  define variable v-printed10       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При изменении скидок кассовых платежей на объекте по списку кассовых платежей произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'csh-lst.txt')
    ,input  7
    ,output v-user-action10
    ,output v-printed10
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
  OS-DELETE value(string("./":U) + 'csh-lst.txt').
end.
  return.
end.
run write-log  in p-log-handle( input 0, "&DLine").
_rid-list:
do v-i = 1 to num-entries(p-rid-list) :
    find first buf_cash-pay no-lock
    where recid(buf_cash-pay) = int( entry( v-i, p-rid-list ) ) no-error .
    if not avail buf_cash-pay then do:
       v-err-cnt = v-err-cnt + 1.
       run write-log-and-file in p-log-handle (
           input 1
         , input log-file-name
         , input 1
         , input substitute("Некорректный recid кассового платежа: &1", entry( v-i, p-rid-list ) ) ).
       next _rid-list.
    end.
    assign
      v-cdpay-code = buf_cash-pay.cdpay-code
      v-curr-code  = buf_cash-pay.curr-code
      v-obj-name   = buf_cash-pay.obj-name
    .
    _main:
    do
    on error undo, return error
    :
        _temp-disc:
        for each temp-disc no-lock break by temp-disc.obj-code
            on error undo _main, return error:
            if first-of (temp-disc.obj-code) then do:
                run write-log-and-file in p-log-handle (
                      input 1
                    , input log-file-name
                    , input 1
                    , input substitute("Изменение скидок платежа &3 на объекте &1&2 по списку кассовых платежей", temp-disc.obj-type, temp-disc.obj-code, v-obj-name)).
            end.
            assign
               v-nonunique = temp-disc.nonunique
               v-rule-num  = temp-disc.rule-num
            .
            CASE temp-disc.action:
            when yes then do:
                run discpru-write in this-procedure (
                                         input v-cdpay-code
                                        ,input v-curr-code
                                        ,input temp-disc.host-code
                                        ,input temp-disc.obj-type
                                        ,input temp-disc.obj-code
                                        ,input temp-disc.pos-type
                                        ,input temp-disc.discnt-role
                                        ,input temp-disc.templ-rl-root
                                        ,input temp-disc.time-templ-rl-root
                                        ,input v-rule-num
                                        ,input v-nonunique
                                      ) no-error .
                if error-status:error then do:
                    assign
                      num-rec = num-rec + 1
                      v-err-cnt = v-err-cnt + 1
                    .
                    run write-log-and-file in p-log-handle (
                         input 1
                       , input log-file-name
                       , input 1
                       , input substitute("Не удалось привязать скидку по платежу &7 на объекте &1&2: &3&4&5&6&4&8"
                                        , temp-disc.obj-type
                                        , temp-disc.obj-code
                                        , entry( v-i, p-rid-list )
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , return-value
                                        , v-obj-name
                                        , temp-disc.label_
                                         ) ).
                    next _temp-disc .
                end.
                else do:
                    assign
                      num-rec = num-rec + 1
                      num-rec-ok = num-rec-ok + 1
                    .
                end.
                run show-counter in p-log-handle .
                run write-counter in p-log-handle (substitute("Обработано изменений &1 из них успешно &2"
                                                            , num-rec
                                                            , num-rec-ok
                                                            )) no-error.
                run get-stop-state in p-log-handle ( output v-stop ).
                if v-stop then do:
                  leave _rid-list.
                end.
            end.
            when no then do:
                run discpru-delete_m in this-procedure (
                                         input v-cdpay-code
                                        ,input v-curr-code
                                        ,input temp-disc.host-code
                                        ,input temp-disc.obj-type
                                        ,input temp-disc.obj-code
                                        ,input temp-disc.pos-type
                                        ,input temp-disc.discnt-role
                                        ,input v-nonunique
                                        ,input temp-disc.rule-num
                                        ,output v-deleted
                                      ) no-error .
                if error-status:error or not v-deleted then do:
                    assign
                      num-rec = num-rec + 1
                      v-err-cnt = v-err-cnt + 1
                    .
                    run write-log-and-file in p-log-handle (
                         input 1
                       , input log-file-name
                       , input 1
                       , input substitute("Не удалось удалить скидку по платежу &7 на объекте &1&2: &3&4&5&6&4&8"
                                        , temp-disc.obj-type
                                        , temp-disc.obj-code
                                        , entry( v-i, p-rid-list )
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , return-value
                                        , v-obj-name
                                        , temp-disc.label_
                                         ) ).
                    next _temp-disc .
                end.
                else do:
                    assign
                      num-rec = num-rec + 1
                      num-rec-ok = num-rec-ok + 1
                    .
                end.
                run show-counter in p-log-handle .
                run write-counter in p-log-handle (substitute("Обработано изменений &1 из них успешно &2"
                                                            , num-rec
                                                            , num-rec-ok
                                                            )) no-error.
                run get-stop-state in p-log-handle ( output v-stop ).
                if v-stop then do:
                  leave _rid-list.
                end.
            end.
            END CASE.
        end.
    end.
end.
run write-log-and-file in p-log-handle (
    input 1
  , input log-file-name
  , input 1
  , input substitute("Пакетное изменение скидок по списку завершено: из &1 успешно изменено &2", num-rec, num-rec-ok )).
.
procedure discpru-delete_m :
define input parameter p-cdpay-code     like ub.dis-cp-rule.cdpay-code  no-undo .
define input parameter p-curr-code      like ub.dis-cp-rule.curr-code  no-undo .
define input parameter p-host-code      like ub.dis-cp-rule.host-code   no-undo .
define input parameter p-obj-type       like ub.dis-cp-rule.obj-type   no-undo .
define input parameter p-obj-code       like ub.dis-cp-rule.obj-code   no-undo .
define input parameter p-pos-type       like ub.dis-cp-rule.pos-type   no-undo .
define input parameter p-discnt-role    like ub.dis-cp-rule.discnt-role no-undo .
define input parameter p-nonunique      like ub.dis-cp-rule.nonunique   no-undo .
define input parameter p-rule-num       like ub.dis-cp-rule.rule-num   no-undo .
define output parameter p-deleted       as logical no-undo .
define variable v-rule-label as character no-undo .
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
DO
on error undo, return error
:
if not ( p-rule-num = ? or p-rule-num = 0 ) then do:
    find first buf_dis-cp-rule exclusive-lock
    where buf_dis-cp-rule.rule-num = p-rule-num no-error.
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
end.
else do:
    find first buf_dis-cp-rule no-lock
    where buf_dis-cp-rule.cdpay-code  = p-cdpay-code
      and buf_dis-cp-rule.curr-code   = p-curr-code
      and buf_dis-cp-rule.obj-type    = p-obj-type
      and buf_dis-cp-rule.host-code   = p-host-code
      and buf_dis-cp-rule.obj-code    = p-obj-code
      and buf_dis-cp-rule.pos-type    = p-pos-type
      and buf_dis-cp-rule.discnt-role = p-discnt-role
      and buf_dis-cp-rule.nonunique   = p-nonunique no-error.
    if not available buf_dis-cp-rule then do:
      return '':U.
    end.
    for each buf_dis-cp-rule exclusive-lock
    where buf_dis-cp-rule.cdpay-code  = p-cdpay-code
      and buf_dis-cp-rule.curr-code   = p-curr-code
      and buf_dis-cp-rule.obj-type    = p-obj-type
      and buf_dis-cp-rule.host-code   = p-host-code
      and buf_dis-cp-rule.obj-code    = p-obj-code
      and buf_dis-cp-rule.pos-type    = p-pos-type
      and buf_dis-cp-rule.discnt-role = p-discnt-role
      and buf_dis-cp-rule.nonunique   = p-nonunique
    :
        delete buf_dis-cp-rule no-error.
        if error-status:error then do:
            run discpru-name in this-procedure (
                 input  buf_dis-cp-rule.templ-rl-root
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
    end.
end.
p-deleted = yes.
return '':U.
END.
end procedure.
