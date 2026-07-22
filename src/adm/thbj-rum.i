/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры для работы с привязками по RUM

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/29/09
Author: Bakhtadze Natalya
Creation date: 03/29/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/chk-entr.i }

PROCEDURE thbj-rum_fill-table :
define input  parameter p-profile-type as character no-undo .
define input  parameter p-mode as character no-undo .
define input  parameter p-silent as logical   no-undo .
define input  parameter p-uniq-key-rec as character no-undo .

DEFINE VARIABLE v-dct-algo-call-id AS CHARACTER NO-UNDO.
define variable v-profile-id-list as character no-undo .
define variable v-call-id-list as character no-undo .
define variable v-once-more-list as character no-undo .
define variable v-current-profile-id as integer no-undo .
define variable v-current-uniq-key-rec as character no-undo .
define variable v-current-once-more as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-obj-fill as logical no-undo .
DEFINE BUFFER buf_rule-by-call FOR ub.rule-by-call.
DEFINE BUFFER buf_rp-by-call FOR ub.rp-by-call.
DEFINE BUFFER buf2_rp-by-call FOR ub.rp-by-call.
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
DEFINE BUFFER buf_rule-by-profile FOR ub.rule-by-profile.
DEFINE BUFFER buf_rule-call-param FOR ub.rule-call-param.
fill-block:
do
on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
:  .
if num-entries (p-mode, {&delim-par}) > 1 then do:
  assign
  v-obj-fill = (entry(2, p-mode, {&delim-par} ) = "obj")
  p-mode = entry(1, p-mode, {&delim-par} )
  .
end.
IF p-mode <> {&add-def} THEN DO:
  FOR EACH buf_rp-by-call NO-LOCK WHERE
           buf_rp-by-call.call_id = p-uniq-key-rec
    on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
    :
    find first buf_rule-profile no-lock where
              buf_rule-profile.profile_id = buf_rp-by-call.profile_id no-error.
    if v-obj-fill
    and lookup("obj", buf_rule-profile.short-name) = 0 then next.
    assign
    v-call-id-list = v-call-id-list +  (if v-call-id-list = '' then '' else {&delim-par})  +  buf_rp-by-call.call_id
    v-profile-id-list = v-profile-id-list + (if v-profile-id-list = '' then '' else {&comma-char}) + string(buf_rp-by-call.profile_id)
    v-once-more-list = v-once-more-list + (if v-once-more-list = '' then '' else {&comma-char})  +  string(buf_rp-by-call.once-more)
    .
    if available buf_rule-profile
    and buf_rule-profile.profile-type = {&cmb} then do:
      do v-ii = 1 to num-entries({&profile-type-list})  :
        v-current-uniq-key-rec = p-uniq-key-rec.
        entry(lookup({&cmb}, p-uniq-key-rec, {&delim-key}), v-current-uniq-key-rec, {&delim-key}) = entry(v-ii, {&profile-type-list}).
        for each buf2_rp-by-call no-lock where
                buf2_rp-by-call.call_id = v-current-uniq-key-rec
            and buf2_rp-by-call.parent-profile_id = buf_rp-by-call.profile_id
            and buf2_rp-by-call.parent-once-more = buf_rp-by-call.once-more
            :
          v-current-profile-id = buf_rp-by-call.profile_id.
          assign
          v-call-id-list = v-call-id-list +  {&delim-par}  +  buf2_rp-by-call.call_id
          v-profile-id-list = v-profile-id-list + {&comma-char} + string(buf2_rp-by-call.profile_id)
          v-once-more-list = v-once-more-list +  {&comma-char}  +  string(buf2_rp-by-call.once-more)
          .
        end.
      end.
    end.
  END.
  do v-ii = 1 to num-entries(v-call-id-list, {&delim-par} )  :
    v-current-uniq-key-rec = entry(v-ii, v-call-id-list, {&delim-par}).
    v-current-profile-id = integer(entry(v-ii, v-profile-id-list)).
    v-current-once-more = integer(entry(v-ii, v-once-more-list)).
    FOR EACH buf_rp-by-call NO-LOCK WHERE
            buf_rp-by-call.call_id = v-current-uniq-key-rec
      on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
      :
      find first buf_rule-profile no-lock where
                buf_rule-profile.profile_id = buf_rp-by-call.profile_id no-error.

      if v-obj-fill
      and lookup("obj", buf_rule-profile.short-name) = 0 then next.

      find first tt0-rp-by-call where
                tt0-rp-by-call.call_id = buf_rp-by-call.call_id
           and  tt0-rp-by-call.profile_id = buf_rp-by-call.profile_id
           and  tt0-rp-by-call.once-more = buf_rp-by-call.once-more no-error.
      if not available tt0-rp-by-call then do:
    CREATE tt0-rp-by-call.
    BUFFER-COPY buf_rp-by-call TO tt0-rp-by-call.
    end.
    end.
  FOR EACH buf_rule-by-call  NO-LOCK WHERE
              buf_rule-by-call.call_id = v-current-uniq-key-rec
  on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
  :
      find first tt0-rule-by-call where
              tt0-rule-by-call.call_id = buf_rule-by-call.call_id
          and tt0-rule-by-call.codex_id = buf_rule-by-call.codex_id
          and tt0-rule-by-call.ruleset_id = buf_rule-by-call.ruleset_id
          and tt0-rule-by-call.order_id = buf_rule-by-call.order_id no-error.
      if not available tt0-rule-by-call then do:
    CREATE tt0-rule-by-call.
    BUFFER-COPY buf_rule-by-call TO tt0-rule-by-call.
    FOR EACH buf_rule-call-param NO-LOCK WHERE
          buf_rule-call-param.codex_id = tt0-rule-by-call.codex_id
      AND buf_rule-call-param.ruleset_id = tt0-rule-by-call.ruleset_id
      AND buf_rule-call-param.call_id = tt0-rule-by-call.call_id
      AND buf_rule-call-param.order_id = tt0-rule-by-call.order_id
        AND buf_rule-call-param.profile_id = tt0-rule-by-call.profile_id
        AND buf_rule-call-param.once-more = tt0-rule-by-call.once-more
    on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
    :
      CREATE tt0-rule-call-param.
      BUFFER-COPY buf_rule-call-param TO tt0-rule-call-param.
    END.
      end. /*if not available tt0-rule-by-call then do:*/
  END.
  end. /*  do v-ii = 1 to num-entries(v-call-id-list, {&delim-par} ):*/
END.
IF p-mode = {&add-def} THEN DO:
  /*заполнить нерушимыми правилами*/
  FOR EACH buf_rule-profile NO-LOCK WHERE
            buf_rule-profile.profile-type = p-profile-type
       AND buf_rule-profile.IS_dynamic = no
    on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
    :
    run thbj-rum_proc-b-addalgo in this-procedure (  input p-silent
                                           ,input yes /*v-start*/
                                           ,input p-uniq-key-rec
                                           ,buffer buf_rule-profile
                                            ) no-error .
    if error-status:error then do:
      undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
  END.
END.
end. /*doe fill-block*/

END PROCEDURE.


PROCEDURE thbj-rum_rename-call-id :
define input  parameter p-from-call-id as character no-undo .
define input  parameter p-to-call-id as character no-undo .
fill-block:
do
on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
:

for each tt0-rp-by-call
on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
:
  if tt0-rp-by-call.call_id = p-from-call-id then do:
    assign
    tt0-rp-by-call.call_id = p-to-call-id.
  end.
end.
for each tt0-rule-by-call
on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
:
  if tt0-rule-by-call.call_id = p-from-call-id then do:
    assign
    tt0-rule-by-call.call_id = p-to-call-id.
  end.
end.
for each tt0-rule-call-param
on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
:
  if tt0-rule-call-param.call_id = p-from-call-id then do:
    assign
    tt0-rule-call-param.call_id = p-to-call-id.
  end.
end.
end.
END PROCEDURE.



PROCEDURE thbj-rum_proc-b-addalgo :
define input  parameter p-silent as logical   no-undo .
define input  parameter p-start as logical   no-undo .
define input  parameter p-uniq-key-rec as character no-undo .
DEFINE PARAMETER BUFFER buf_rule-profile FOR ub.rule-profile.
DEFINE VARIABLE v-order-id AS INTEGER NO-UNDO.
define variable v-rule-uniq-key-rec as character no-undo .
define variable v-dcta-uniq-key-rec as character no-undo .
define variable v-found-params as logical no-undo .
define variable v-found-can-calc as logical no-undo .
define variable v-disabled as logical no-undo .
define variable glog as logical no-undo .
define variable v-once-more as integer no-undo .
define variable v-main-once-more as integer no-undo .
define variable v-par-val as character no-undo .
define variable v-par-type as character no-undo .
define variable v-rule-profile-uniq-key-rec as character no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-param-form as character no-undo .
define variable v-profile-list  as character no-undo .
define variable v-uniq-key-rec-list as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
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
define buffer buf3_tt0-rp-by-call for tt0-rp-by-call.
FIND LAST buf_tt0-rp-by-call NO-LOCK WHERE
          buf_tt0-rp-by-call.call_id = p-uniq-key-rec
      AND buf_tt0-rp-by-call.profile_id = buf_rule-profile.profile_id NO-ERROR.
if buf_rule-profile.parent-feature = integer({&rp-parentf-only-in-combo}) then do:
  undo, return error substitute("Подключение данного алгоритма возможно только через комбинированный алгоритм").
end.
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
run  gen-key-fv in this-procedure ( input p-uniq-key-rec
                                   ,output v-field-list
                                   ,output v-value-list).
if lookup("obj-type", v-field-list, {&delim-key}) > 0 then do:
  assign
  v-obj-type = entry(lookup("obj-type", v-field-list, {&delim-key}), v-value-list, {&delim-key})
  v-obj-code = integer(entry(lookup("obj-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}) )
  .
end.
if lookup(buf_rule-profile.short-name, "obj") = 0
and v-obj-type <> ''
then do:
  undo, return error substitute("Данный алгоритм НЕЛЬЗЯ добавлять в контексте объекта!").
end.
IF AVAILABLE buf_tt0-rp-by-call THEN do:
  v-main-once-more = buf_tt0-rp-by-call.once-more.
  if buf_rule-profile.is_dynamic = no
  then do:
   undo, return error substitute("Алгоритм &1 уже подключен", buf_rule-profile.profile_id).
  end.
  v-disabled = yes.
  for each buf_rule-by-profile no-lock where
         buf_rule-by-profile.profile_id = buf_rule-profile.profile_id,
     first buf_rule no-lock where
          buf_rule.rule_id = buf_rule-by-profile.rule_id:
     v-disabled = v-disabled and (buf_rule.reusable-params = "-":U).
  end.
  if v-disabled then do:
    undo, return error substitute("Алгоритм &1 уже подключен&2" +
                                  "В нем нет ни одного правила, которое можно выполнить повторно"
                                  ,buf_rule-profile.profile_id
                                  ,{&new-line}
                                  ).
  end.
  else do:
    if p-silent = no then do:
      MESSAGE
      substitute("Алгоритм уже подключен&1"+
                "Выполнение привязанных к нему правил повторно возможно только при указании соответствущих значений параметров&1" +
                "Все равно подключить алгоритм?"
                , {&new-line})
      VIEW-AS ALERT-BOX question buttons YES-NO update glog.
      if not glog then    RETURN ERROR.
    end.
    else do:
      undo, return error substitute("Алгоритм &1 уже подключен&2"+
                                    "Выполнение привязанных к нему правил повторно возможно только при указании соответствущих значений параметров").

    end.
  end.
END.
if buf_rule-profile.param-code <> '':U then do:
  if buf_rule-profile.param-code = 'sys-key' then do:
    { gbl/currsysk.i
      v-par-val
      no-error
    }
    if error-status:error then do:
      undo, return error
      substitute("Ошибка при определении значения конфигурационного параметра &1,&2" +
                  "который должен быть включен для работы профайла &3"
                  ,buf_rule-profile.param-code
                  ,{&new-line}
                  ,buf_rule-profile.profile_id).
    end.
    if check-entry-with-mask(v-par-val, buf_rule-profile.param-value, {&delim-par}) = no
    and not (buf_rule-profile.param-code = 'sys-key'
              and
              v-par-val = 'IBS')
    then do:
      undo, return error
      substitute("Значения sys-key=&1,&2" +
                  "что не удовлетворяет условиям работы профайла &3"
                  ,v-par-val
                  ,{&new-line}
                  ,buf_rule-profile.profile_id).

    end. /*if (buf_rule-profile.param-code = 'sys-key'*/
  end.
  else do:
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
      undo, return error
      substitute("Ошибка при определении значения конфигурационного параметра &1,&2" +
                  "который должен быть включен для работы профайла &3"
                  ,buf_rule-profile.param-code
                  ,{&new-line}
                  ,buf_rule-profile.profile_id).
    end.
    if lookup(v-par-val, buf_rule-profile.param-value, {&delim-par}) = 0
    then do:
      undo, return error
      substitute("Значения конфигурационного параметра &1=&2,&3" +
                  "что не удовлетворяет условиям работы профайла &4"
                  ,buf_rule-profile.param-code
                  ,v-par-val
                  ,{&new-line}
                  ,buf_rule-profile.profile_id).
    end.
  end.
end. /*if buf_rule-profile.param-code <> '':U then do:*/
v-profile-list = string(buf_rule-profile.profile_id).
v-uniq-key-rec-list = p-uniq-key-rec.
if buf_rule-profile.profile-type = {&cmb} then do:
  define variable v-once-more-list as character no-undo .
  define variable v-ii as integer no-undo .
  define variable v-current-uniq-key-rec as character no-undo .
  define buffer buf2_rule-profile for ub.rule-profile.
  define buffer buf_profile-by-profile for ub.profile-by-profile.
  /*надо получить список профайлов*/
  for each buf_profile-by-profile no-lock where
          buf_profile-by-profile.profile_id = buf_rule-profile.profile_id,
     first buf2_rule-profile no-lock where
          buf2_rule-profile.profile_id = buf_profile-by-profile.child-profile_id
  on error undo, return error:
    v-profile-list = v-profile-list + {&comma-char} + string(buf2_rule-profile.profile_id).
    v-current-uniq-key-rec = p-uniq-key-rec.
    entry(lookup({&cmb}, p-uniq-key-rec, {&delim-key}), v-current-uniq-key-rec, {&delim-key}) = buf2_rule-profile.profile-type.
    v-uniq-key-rec-list = v-uniq-key-rec-list + {&delim-par} + v-current-uniq-key-rec.
  end.
end. /*if buf_rule-profile.profile-type = {&cmb} then do:*/
for each tt2-rule-call-param:
  delete tt2-rule-call-param.
end.
do v-ii = 1 to num-entries(v-profile-list):
find first buf2_rule-profile no-lock where
          buf2_rule-profile.profile_id = integer(entry(v-ii, v-profile-list)).
FIND LAST buf3_tt0-rp-by-call NO-LOCK WHERE
          buf3_tt0-rp-by-call.call_id = p-uniq-key-rec
      AND buf3_tt0-rp-by-call.profile_id = integer(entry(v-ii, v-profile-list)) NO-ERROR.
if available buf3_tt0-rp-by-call then do:
  v-once-more = buf3_tt0-rp-by-call.once-more.
end.
CREATE buf_tt0-rp-by-call.
BUFFER-COPY buf2_rule-profile TO buf_tt0-rp-by-call
ASSIGN
buf_tt0-rp-by-call.CALL_id = entry(v-ii, v-uniq-key-rec-list, {&delim-par} )
buf_tt0-rp-by-call.once-more = v-once-more + 1
buf_tt0-rp-by-call.parent-profile_id = (if buf_rule-profile.profile-type = {&cmb}
                                      and buf2_rule-profile.profile-type <> {&cmb}
                                      then buf_rule-profile.profile_id else 0)
buf_tt0-rp-by-call.parent-once-more = (if buf_rule-profile.profile-type = {&cmb}
                                      and buf2_rule-profile.profile-type <> {&cmb}
                                      then v-main-once-more else 0)
v-once-more-list = v-once-more-list + (if v-once-more-list = '' then '' else {&comma-char}) + string(buf_tt0-rp-by-call.once-more)
.
if buf2_rule-profile.profile_id = buf_rule-profile.profile_id then do:
  v-main-once-more = buf_tt0-rp-by-call.once-more.
end.
/*надо заполнить данным обучных профайлов если мы добавляем cmb */
if buf_rule-profile.profile-type = {&cmb}
and buf2_rule-profile.profile-type <> {&cmb} then do:
  run  thbj-rum_fill-table in this-procedure ( input buf2_rule-profile.profile-type
                                              ,input {&update}
                                              ,input yes /*p-silent*/
                                              ,input buf_tt0-rp-by-call.CALL_id ).
end.

_rule-by-profile:
FOR EACH buf_rule-by-profile NO-LOCK WHERE
        buf_rule-by-profile.profile_id = buf_tt0-rp-by-call.profile_id
BY buf_rule-by-profile.profile_id
BY buf_rule-by-profile.codex_id
BY buf_rule-by-profile.ruleset_id
BY buf_rule-by-profile.rp_order_id
ON error undo, return error :
  if buf2_rule-profile.profile-type <> {&cmb} then do:
 FIND FIRST buf_rule NO-LOCK WHERE
                buf_rule.RULE_id = buf_rule-by-profile.RULE_id NO-ERROR.
 IF NOT AVAILABLE buf_rule THEN DO:
   undo, return error
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
    buf_tt0-rule-by-call.algo-des = substitute("Профайл &1. &2", buf2_rule-profile.profile_id, buf_rule.NAME)
  buf_tt0-rule-by-call.is_dynamic = buf_rule-by-profile.IS_dynamic
  buf_tt0-rule-by-call.can-calc = (IF not buf_tt0-rule-by-call.is_dynamic
                                   or (buf_tt0-rule-by-call.codex_id = 22
                                       and
                                       buf_tt0-rule-by-call.ruleset_id = 1)
                                     THEN yes
                                     ELSE no)
  buf_tt0-rule-by-call.call_id = entry(v-ii, v-uniq-key-rec-list, {&delim-par} )
  buf_tt0-rule-by-call.once-more = v-once-more + 1
  v-found-can-calc = v-found-can-calc or buf_tt0-rule-by-call.can-calc
  .
  find first buf_ruledict no-lock where
          buf_ruledict.entry-type = {&rdict-etype-rule}
      and  buf_ruledict.uniq-key-rec = buf_rule.uniq-key-rec.

  run gen-key-rec in this-procedure (
                                     input  {&table_rule-profile}
                                      ,input buffer buf2_rule-profile:handle
                                    ,output v-rule-profile-uniq-key-rec).
  find first buf_ruledict2 no-lock where
          buf_ruledict2.entry-type = {&rdict-etype-rule-profile}
      and  buf_ruledict2.uniq-key-rec = v-rule-profile-uniq-key-rec.
  for each buf_ruledict-param no-lock where
          buf_ruledict-param.entry-id = buf_ruledict.entry-id
  on error undo, return error:
  find first buf_rp-rule-param no-lock where
              buf_rp-rule-param.profile_id = buf2_rule-profile.profile_id
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
      { gbl/curr-r-b.i v-curr-r-b }
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
  end. /*if buf2_rule-profile.profile-type <> {&cmb} then do*/
END. /*FOR EACH buf_rule-by-profile NO-LOCK WHERE*/
end. /*do v-ii = 1 to num-entries(v-profile-list):*/
if v-found-params
/*and v-found-can-calc = yes*/
and not p-start
and not p-silent
then do:
  if search( substitute("rul/rcps-&1.w", buf_rule-profile.profile_id)) <> ?
  or search( substitute("rul/rcps-&1.r", buf_rule-profile.profile_id)) <> ?
  then do:
    v-param-form = substitute("rul/rcps-&1.w", buf_rule-profile.profile_id).
  end.
  else do:
    v-param-form = "ref/rulercps.w" .
  end.
  if buf_rule-profile.profile-type = {&cmb}
  and v-param-form = "ref/rulercps.w" then do:
    message
    "Для комбинированных алгоритмов необходимо написать отдельную форму задания параметров!"
    view-as alert-box error .
    return error.
  end.
  if v-obj-type <> ''
  and lookup("obj", buf_rule-profile.short-name) = 0
  then do:
    message
    "Данный алгоритм НЕЛЬЗЯ добавлять в контексте объекта!"
    view-as alert-box error .
    return error.
  end.
  run value(v-param-form) (
                       input parparentproc
                      ,input this-procedure:handle
                      ,input "b-chg":U
                      ,input {&add-def}
                      ,input {&table_rp-rule-param}
                      ,input buf_rule-profile.profile_id
                      ,input v-main-once-more
                      ,input p-uniq-key-rec /*p-call-id*/
                      ,input 0 /*p-codex-id*/
                      ,input 0 /*p-ruleset-id*/
                      ,INPUT 0 /*p-order-id*/
                      ,input 0 /*p-rule-id*/
                      ,INput substitute("алгоритм &1 &2"
                                       , buf_rule-profile.name
                                      , calldscr(p-uniq-key-rec)
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
      and (lookup("LIST", tt2-rule-call-param.param-3-data-type) > 0
           or
           lookup("SORTED-LIST", tt2-rule-call-param.param-3-data-type) > 0
           )
      then do:
        create buf_tt0-rule-call-param.
      end.
      buffer-copy tt2-rule-call-param to buf_tt0-rule-call-param.
      delete tt2-rule-call-param.
    end.
  end.
end.
END PROCEDURE.

/* $Workfile$ e n d */