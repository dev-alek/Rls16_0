/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры необходимые для добавления типа ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/28/09
Author: Bakhtadze Natalya
Creation date: 03/28/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


PROCEDURE dc-typei_fill-table :
define input  parameter p-mode as character no-undo .
define input  parameter p-silent as logical   no-undo .
define output parameter f-dflt-pcnt as decimal no-undo .
define output parameter f-dflt-cash-pcnt as decimal no-undo .
define output parameter f-dflt-pcnt-kat as integer   no-undo .
DEFINE VARIABLE v-dct-algo-call-id AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_hist-nws-option FOR ub.hist-nws-option.
DEFINE BUFFER buf_rule-by-call FOR ub.rule-by-call.
DEFINE BUFFER buf_rp-by-call FOR ub.rp-by-call.
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
DEFINE BUFFER buf_rule-by-profile FOR ub.rule-by-profile.
DEFINE BUFFER buf_rule-call-param FOR ub.rule-call-param.
DEFINE BUFFER buf_dis-dct-rule FOR ub.dis-dct-rule.
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
fill-block:
do
on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
:

IF p-mode <> {&add-def} THEN DO:
  FOR EACH buf_hist-nws-option  NO-LOCK WHERE
        buf_hist-nws-option.db-num = 0
    AND buf_hist-nws-option.host-code = temp-dc-type.emitent-host-code
    AND buf_hist-nws-option.obj-type = '':U
    AND buf_hist-nws-option.obj-code = 0
    and buf_hist-nws-option.charkey_one = temp-dc-type.TYPE
    and buf_hist-nws-option.subject-group = {&table_c-dc-hist}
    and buf_hist-nws-option.host-code = temp-dc-type.emitent-host-code
    on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
    :
    CREATE tt0-hist-nws-option.
    BUFFER-COPY buf_hist-nws-option TO tt0-hist-nws-option.
  END.
  FOR EACH buf_dis-dct-rule NO-LOCK WHERE
          buf_dis-dct-rule.TYPE = temp-dc-type.TYPE
       AND buf_dis-dct-rule.emitent-host-code = temp-dc-type.emitent-host-code
      on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
      :
    CREATE tt0-dis-dct-rule.
    BUFFER-COPY buf_dis-dct-rule TO tt0-dis-dct-rule.
    if (buf_dis-dct-rule.discnt-role = {&ddctr-def-pcnt}
        or
        buf_dis-dct-rule.discnt-role = {&ddctr-def-cash-pcnt}
        or
        buf_dis-dct-rule.discnt-role = {&ddctr-def-categ}) then do:
      IF buf_dis-dct-rule.host-code = 0
      AND buf_dis-dct-rule.obj-type = '':U
      AND buf_dis-dct-rule.obj-code = 0 THEN DO:
        FIND FIRST buf_dis-rule NO-LOCK WHERE
                  buf_dis-rule.rule-num = buf_dis-dct-rule.rule-num NO-ERROR.
        IF AVAILABLE buf_Dis-rule THEN DO:

          CASE buf_dis-dct-rule.discnt-role:
            WHEN {&ddctr-def-pcnt} THEN DO:
                f-dflt-pcnt = buf_Dis-rule.discnt-value.
            END.
              WHEN {&ddctr-def-cash-pcnt} THEN DO:
                f-dflt-cash-pcnt = buf_Dis-rule.discnt-value.
              END.
              WHEN {&ddctr-def-categ} THEN DO:
                f-dflt-pcnt-kat = buf_Dis-rule.dis-kat.
              END.

          END CASE.
        END.
      END.
    end.
    release tt0-dis-dct-rule.
  END.
  FOR EACH buf_rp-by-call NO-LOCK WHERE
           buf_rp-by-call.call_id = temp-dc-type.uniq-key-rec
    on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
    :
    CREATE tt0-rp-by-call.
    BUFFER-COPY buf_rp-by-call TO tt0-rp-by-call.
  END.
  FOR EACH buf_rule-by-call  NO-LOCK WHERE
            buf_rule-by-call.call_id = temp-dc-type.uniq-key-rec
  on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
  :
    CREATE tt0-rule-by-call.
    BUFFER-COPY buf_rule-by-call TO tt0-rule-by-call.
    FOR EACH buf_rule-call-param NO-LOCK WHERE
          buf_rule-call-param.codex_id = tt0-rule-by-call.codex_id
      AND buf_rule-call-param.ruleset_id = tt0-rule-by-call.ruleset_id
      AND buf_rule-call-param.call_id = tt0-rule-by-call.call_id
      AND buf_rule-call-param.order_id = tt0-rule-by-call.order_id
    on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
    :
      CREATE tt0-rule-call-param.
      BUFFER-COPY buf_rule-call-param TO tt0-rule-call-param.
    END.
  END.
END.
IF p-mode = {&add-def} THEN DO:
  /*заполнить нерушимыми правилами*/
  FOR EACH buf_rule-profile NO-LOCK WHERE
            buf_rule-profile.profile-type = {&TABLE_dis-card-type}
       AND buf_rule-profile.IS_dynamic = no
    on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
    :

    run dc-typei_proc-b-addalgo in this-procedure (  input p-silent
                                                    ,input yes
                                                    ,buffer buf_rule-profile) no-error .
    if error-status:error then do:
      undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
  END.
  _rule-profile:
  FOR EACH buf_rule-profile NO-LOCK WHERE
            buf_rule-profile.profile-type = {&TABLE_dis-card-type}
       AND buf_rule-profile.IS_dynamic = ?
    on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
    :
    if buf_rule-profile.param-code <> '':U then do:
      define variable v-par-val as character no-undo .
      define variable v-par-type as character no-undo .
      /*проверим параметр*/
      if buf_rule-profile.param-code = 'sys-key' then do:
        { gbl/currsysk.i
          v-par-val
          no-error
        }
        if error-status:error then do:
          message
          substitute("Ошибка при определении значения конфигурационного параметра &1,&2" +
                      "который должен быть включен для работы профайла &3"
                      ,buf_rule-profile.param-code
                      ,{&new-line}
                      ,buf_rule-profile.profile_id)
          view-as alert-box error .
          next.
        end.
      end.
      else do:
        { gbl/conf-rd.i
          buf_rule-profile.param-code
          "''"
          "''"
          0
          "''"
          "''"
          "''"
          no
          v-par-val
          v-par-type
          no-error }
        if error-status:error then do:
          message
          substitute("Ошибка при определении значения конфигурационного параметра &1,&2" +
                      "который должен быть включен для работы профайла &3"
                      ,buf_rule-profile.param-code
                      ,{&new-line}
                      ,buf_rule-profile.profile_id)
          view-as alert-box error .
          next.
        end.
      end.

      if lookup(v-par-val, buf_rule-profile.param-value, {&delim-par}) = 0
      and not (buf_rule-profile.param-code = 'sys-key'
                and
                v-par-val = 'IBS')
      then do:
        next _rule-profile.
      end.
      if buf_rule-profile.param-code = 'sys-key'
      and v-par-val = 'IBS' then next _rule-profile.
    end. /*if buf_rule-profile.param-code <> '':U then do:*/

    run dc-typei_proc-b-addalgo in this-procedure (  input p-silent
                                           ,input yes /*p-start*/
                                           ,buffer buf_rule-profile) no-error .
    if error-status:error then do:
      undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
  END.

  run fill-tt0-hist-nws-option in this-procedure ( input 0 /*p-emitent-host-code*/
                                                  ,input ''  /*type*/
                                                  ) no-error .
  if error-status:error then do:
    undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
END.
end. /*doe fill-block*/

END PROCEDURE.


procedure dc-typei_proc-b-addalgo :
define input  parameter p-silent as logical   no-undo .
define input  parameter p-start as logical   no-undo .
DEFINE PARAMETER BUFFER buf_rule-profile FOR ub.rule-profile.
DEFINE VARIABLE v-order-id AS INTEGER NO-UNDO.
define variable v-rule-uniq-key-rec as character no-undo .
define variable v-dcta-uniq-key-rec as character no-undo .
define variable v-found-params as logical no-undo .
define variable v-found-can-calc as logical no-undo .
define variable v-disabled as logical no-undo .
define variable glog as logical no-undo .
define variable v-once-more as integer no-undo .
define variable v-par-val as character no-undo .
define variable v-par-type as character no-undo .
define variable v-rule-profile-uniq-key-rec as character no-undo .
DEFINE BUFFER buf_tt0-rp-by-call FOR tt0-rp-by-call.
DEFINE BUFFER buf_rule-by-profile FOR ub.rule-by-profile.
DEFINE BUFFER buf_rule FOR ub.RULE.
DEFINE BUFFER buf_tt0-rule-by-call FOR tt0-rule-by-call.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict2 for ub.ruledict.
define buffer buf_tt0-rule-call-param for tt0-rule-call-param.
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_ruledict-param2 for ub.ruledict-param.
define buffer buf_rp-rule-param for ub.rp-rule-param.

main-block:
do
on error undo, return error return-value
:


FIND LAST buf_tt0-rp-by-call NO-LOCK WHERE
          buf_tt0-rp-by-call.call_id = temp-dc-type.uniq-key-rec
      AND buf_tt0-rp-by-call.profile_id = buf_rule-profile.profile_id NO-ERROR.
IF AVAILABLE buf_tt0-rp-by-call THEN DO:
  v-once-more = buf_tt0-rp-by-call.once-more.
  if buf_rule-profile.is_dynamic = no
  or buf_rule-profile.reusable-params = '-':U
  then do:
   RETURN ERROR substitute("алгоритм &1 уже подключен к данному типу ДК", buf_rule-profile.is_dynamic).
  end.
  v-disabled = yes.
  for each buf_rule-by-profile no-lock where
         buf_rule-by-profile.profile_id = buf_rule-profile.profile_id,
     first buf_rule no-lock where
          buf_rule.rule_id = buf_rule-by-profile.rule_id:
     v-disabled = v-disabled and (buf_rule.reusable-params = "-":U).
  end.
  if v-disabled then do:
    RETURN ERROR substitute( "Алгоритм &1 уже подключен к типу ДК &2&3" +
                             "В нем нет ни одного правила, которое можно выполнить повторно"
                             , buf_rule-profile.is_dynamic
                             , temp-dc-type.type
                             , {&new-line}
                             ).
  end.
  else do:
    if not p-silent then do:
      MESSAGE
      "Данный алгоритм уже подключен к данному типу ДК" skip
      "Выполнение привязанных к нему правил повторно возможно только при указании соответствущих значений параметров" skip
      "Все равно подключить алгоритм"
      VIEW-AS ALERT-BOX question buttons YES-NO update glog.
      if not glog then    RETURN ERROR.
    end.
    else do:
      return error substitute("Алгоритм &1 уже подключен к типу ДК &2&3"  +
                              "Выполнение привязанных к нему правил повторно возможно только при указании соответствущих значений параметров"
                              ,buf_rule-profile.is_dynamic
                              ,temp-dc-type.type
                              , {&new-line}
                              ).
    end.
  end.
  if buf_rule-profile.param-code <> '':U then do:
    /*проверим параметр*/
    { gbl/conf-rd.i
      buf_rule-profile.param-code
      "''"
      "''"
      0
      "''"
      "''"
      "''"
      no
      v-par-val
      v-par-type
      no-error }
    if error-status:error then do:
      undo main-block, return error
      substitute("Ошибка при определении значения конфигурационного параметра &1,&2" +
                  "который должен быть включен для работы профайла &3"
                  ,buf_rule-profile.param-code
                  ,{&new-line}
                  ,buf_rule-profile.profile_id).
    end.
    if lookup(v-par-val, buf_rule-profile.param-value, {&delim-par}) = 0 then do:
      undo main-block, return error
      substitute("Значения конфигурационного параметра &1=&2,&3" +
                  "что не удовлетворяет условиям работы профайла &4"
                  ,buf_rule-profile.param-code
                  ,v-par-val
                  ,{&new-line}
                  ,buf_rule-profile.profile_id).

    end.
  end.
END.
define variable v-ps as character no-undo .
if not p-silent then do:
  run gbl/d-prompt.w (
    'title=':u + "Комментарий к привязке" + '\':u
  + 'text1=':u + "Вы можете добавить поясняющий комментарий"  + '\':u
  + 'format=' + "X(256)" + '\':u
  + 'type=' + 'EDIT' + '\':u
  + 'fillin_row=2\':u
  + 'fillin_col=4\':u
  + 'fillin_width=70\':u
  + 'fillin_height=4\':u
  + 'max-chars=280\':u     /*- максимальное количество символов для редактора*/
  + 'readonly=no' +  '\':u
  , input-output v-ps
      ).
end.
CREATE buf_tt0-rp-by-call.
BUFFER-COPY buf_rule-profile TO buf_tt0-rp-by-call
ASSIGN
buf_tt0-rp-by-call.CALL_id = temp-dc-type.uniq-key-rec
buf_tt0-rp-by-call.once-more = v-once-more + 1
buf_tt0-rp-by-call.ps = v-ps
.
for each tt2-rule-call-param:
  delete tt2-rule-call-param.
end.
_rule-by-profile:
FOR EACH buf_rule-by-profile NO-LOCK WHERE
        buf_rule-by-profile.profile_id = buf_tt0-rp-by-call.profile_id
BY buf_rule-by-profile.profile_id
BY buf_rule-by-profile.codex_id
BY buf_rule-by-profile.ruleset_id
BY buf_rule-by-profile.rp_order_id
ON error undo, return error :
 FIND FIRST buf_rule NO-LOCK WHERE
                buf_rule.RULE_id = buf_rule-by-profile.RULE_id NO-ERROR.
 IF NOT AVAILABLE buf_rule THEN DO:
   undo main-block, return error
   SUBSTITUTE("Не найдено правило &1, которое должно быть подключено по алгоритму &2&3" +
                   "кодекс правил &4, свод правил &5"
                   , buf_rule-by-profile.RULE_id
                   , buf_rule-by-profile.profile_id
                   , {&NEW-LINE}
                   , buf_rule-by-profile.codex_id
                   , buf_rule-by-profile.ruleset_id).
 END.
  FIND LAST buf_tt0-rule-by-call WHERE
            buf_tt0-rule-by-call.codex_id =  buf_rule-by-profile.codex_id
        AND buf_tt0-rule-by-call.ruleset_id = buf_rule-by-profile.ruleset_id
  USE-INDEX imain NO-ERROR.
  IF AVAILABLE buf_tt0-rule-by-call THEN DO:
     v-order-id = buf_tt0-rule-by-call.order_id + 1.
  END.
  ELSE DO:
     v-order-id = 0.
  END.
  CREATE buf_tt0-rule-by-call.
  BUFFER-COPY buf_rule-by-profile TO buf_tt0-rule-by-call
  ASSIGN
  buf_tt0-rule-by-call.order_id = v-order-id
  buf_tt0-rule-by-call.algo-des = substitute("Профайл &1. &2", buf_rule-profile.profile_id, buf_rule.NAME)
  buf_tt0-rule-by-call.is_dynamic = buf_rule-by-profile.IS_dynamic
  buf_tt0-rule-by-call.can-calc = (IF buf_tt0-rule-by-call.is_dynamic
                                     THEN buf_rule-by-profile.dflt-can-calc
                                     ELSE YES)
  buf_tt0-rule-by-call.call_id = temp-dc-type.uniq-key-rec
  buf_tt0-rule-by-call.once-more = v-once-more + 1
  v-found-can-calc = v-found-can-calc or buf_tt0-rule-by-call.can-calc
  .
  find first buf_ruledict no-lock where
          buf_ruledict.entry-type = {&rdict-etype-rule}
      and  buf_ruledict.uniq-key-rec = buf_rule.uniq-key-rec.

  run gen-key-rec in this-procedure (
                                     input  {&table_rule-profile}
                                    ,input buffer buf_rule-profile:handle
                                    ,output v-rule-profile-uniq-key-rec).
  find first buf_ruledict2 no-lock where
          buf_ruledict2.entry-type = {&rdict-etype-rule-profile}
      and  buf_ruledict2.uniq-key-rec = v-rule-profile-uniq-key-rec.
  for each buf_ruledict-param no-lock where
          buf_ruledict-param.entry-id = buf_ruledict.entry-id
  on error undo, return error:
  find first buf_rp-rule-param no-lock where
            buf_rp-rule-param.profile_id = buf_rule-profile.profile_id
        and buf_rp-rule-param.rule-param-name = buf_ruledict-param.param-name
        and buf_rp-rule-param.codex_id = buf_rule-by-profile.codex_id
        and buf_rp-rule-param.ruleset_id = buf_rule-by-profile.ruleset_id
        and buf_rp-rule-param.rule_id = buf_rule-by-profile.rule_id
        and buf_rp-rule-param.rp_order_id = buf_rule-by-profile.rp_order_id.
    find first buf_ruledict-param2 no-lock where
          buf_ruledict-param2.entry-id = buf_ruledict2.entry-id
      and buf_ruledict-param2.param-name = buf_rp-rule-param.rp-param-name.
    create buf_tt0-rule-call-param.
    assign
    buf_tt0-rule-call-param.codex_id = buf_tt0-rule-by-call.codex_id
    buf_tt0-rule-call-param.ruleset_id = buf_tt0-rule-by-call.ruleset_id
    buf_tt0-rule-call-param.call_id  = buf_tt0-rule-by-call.call_id
    buf_tt0-rule-call-param.order_id = buf_tt0-rule-by-call.order_id
    buf_tt0-rule-call-param.rule_id = buf_rule.rule_id
    buf_tt0-rule-call-param.param-name = buf_ruledict-param.param-name
    buf_tt0-rule-call-param.p-index = 0
    buf_tt0-rule-call-param.param-des = buf_ruledict-param.documentation
    buf_tt0-rule-call-param.param-num = buf_ruledict-param.param-num
    buf_tt0-rule-call-param.param-label = buf_ruledict-param.param-label
    buf_tt0-rule-call-param.param-mode = buf_ruledict-param.param-mode
    buf_tt0-rule-call-param.param-data-type = buf_ruledict-param.param-data-type
    buf_tt0-rule-call-param.param-2-data-type = buf_ruledict-param.param-2-data-type
    buf_tt0-rule-call-param.param-3-data-type = buf_ruledict-param.param-3-data-type
    buf_tt0-rule-call-param.param-value-character = buf_ruledict-param2.init-value-character
    buf_tt0-rule-call-param.param-value-date = buf_ruledict-param2.init-value-date
    buf_tt0-rule-call-param.param-value-decimal = buf_ruledict-param2.init-value-decimal
    buf_tt0-rule-call-param.param-value-integer = buf_ruledict-param2.init-value-integer
    buf_tt0-rule-call-param.param-value-logical = buf_ruledict-param2.init-value-logical
    buf_tt0-rule-call-param.profile_id          = buf_tt0-rule-by-call.profile_id
    buf_tt0-rule-call-param.once-more           = buf_tt0-rule-by-call.once-more
    .
    if buf_ruledict-param.param-2-data-type = "r-b" then do:
      buf_tt0-rule-call-param.param-value-character = (if v-curr-r-b = {&r-b-rubl}
                                                       then {&r-b-rubl}
                                                       else {&r-b-base}).

    end.
    assign
    v-found-params = yes.
    create tt2-rule-call-param.
    buffer-copy buf_tt0-rule-call-param to tt2-rule-call-param.
    release tt2-rule-call-param.
  end.
END.
if v-found-params
and v-found-can-calc = yes
and not p-start
and not p-silent
then do:
 define variable v-param-form as character no-undo .
  assign
  v-param-form = (if buf_rule-profile.custom-param-form > 0
                  then  substitute("rul/rcps-&1.w", buf_rule-profile.profile_id)
                  else "ref/rulercps.w")
  .
  run value(v-param-form) (
                       input parparentproc
                      ,input this-procedure:handle
                      ,input "b-chg":U
                      ,input {&add-def}
                      ,input {&table_rp-rule-param}
                      ,input buf_tt0-rp-by-call.profile_id
                      ,input buf_tt0-rp-by-call.once-more
                      ,input buf_tt0-rp-by-call.call_id /*p-call-id*/
                      ,input 0 /*p-codex-id*/
                      ,input 0 /*p-ruleset-id*/
                      ,INPUT 0 /*p-order-id*/
                      ,input 0 /*p-rule-id*/
                      ,INput substitute("алгоритм &1 &2"
                                       , buf_rule-profile.name
                                       , calldscr(buf_tt0-rp-by-call.call_id)
                                       )  /**/
                      ,input-output table tt2-rule-call-param) no-error.
  if not error-status:error then do:
    for each tt2-rule-call-param
    on error undo, return error:
      find first buf_tt0-rule-call-param where
                buf_tt0-rule-call-param.call_id = tt2-rule-call-param.call_id
            and buf_tt0-rule-call-param.codex_id = tt2-rule-call-param.codex_id
            and buf_tt0-rule-call-param.ruleset_id = tt2-rule-call-param.ruleset_id
            and buf_tt0-rule-call-param.order_id = tt2-rule-call-param.order_id
            and buf_tt0-rule-call-param.param-name = tt2-rule-call-param.param-name
            and buf_tt0-rule-call-param.p-index = tt2-rule-call-param.p-index no-error .
      if not available buf_tt0-rule-call-param
      and lookup("LIST", tt2-rule-call-param.param-3-data-type) > 0
      then do:
        create buf_tt0-rule-call-param.
      end.
      buffer-copy tt2-rule-call-param to buf_tt0-rule-call-param.
      delete tt2-rule-call-param.
    end.
  end.
end.

end.
end procedure. /* dc-typei_proc-b-dc-addalgo */


/* $Workfile$ e n d */