/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры, необходимые для функционирования custom формы задания параметров RUM

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/19/09
Author: Bakhtadze Natalya
Creation date: 06/19/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "local-var" &then

DEFINE VARIABLE v-ch AS WIDGET-HANDLE NO-UNDO EXTENT 6.
DEFINE VARIABLE v-dflt-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-rp-dflt-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-rcps-entry-id AS INTEGER NO-UNDO.
DEFINE VARIABLE v-uniq-key-rec AS character NO-UNDO.
DEFINE VARIABLE rule-display-option AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_Rule-profile FOR ub.rule-profile.
DEFINE BUFFER buf_Ruledict FOR ub.ruledict.
DEFINE BUFFER call_tt-rule-call-param FOR tt-rule-call-param.
define buffer term_tt-rule-call-param for tt-rule-call-param.

&global-DEFINE script-parmode term_tt-rule-call-param.param-mode
&global-DEFINE abl-datatype term_tt-rule-call-param.param-data-type
&global-define label-clmn_8 "Значение!(строковое)"
&global-define label-clmn_9 "Значение!(Дата)"
&global-define label-clmn_10 "Значение!(Десятичное)"
&global-define label-clmn_11 "Значение!(Целое)"
&global-define label-clmn_12 "Значение!(Логическое)"
&global-define label-clmn_13 "Точка вызова"
&global-define label-clmn_14 "Значение"

&endif

&if "{1}" = "procedures" &then

procedure rcps_get-profile-id :
define output parameter p-local-profile-id as integer no-undo .

do
on error undo, return error:

p-local-profile-id = p-profile-id.

end.

end procedure. /* rcps_get-profile-id */

PROCEDURE rcps_fill-table :
define input parameter p-clear-params as logical no-undo .
if p-clear-params then do:
FOR EACH tt-rule-call-param:
    DELETE tt-rule-call-param.
END.
end.
 FOR EACH tt0-rule-call-param:
   IF p-mode <> {&add-def} THEN DO:
     IF p-call-id <> '':U and p-call-id <> tt0-rule-call-param.call_id THEN do:
        NEXT.
     end.
     IF p-codex-id <> 0 and p-codex-id <> tt0-rule-call-param.codex_id THEN do:
       NEXT.
     end.
     IF p-ruleset-id <> 0 and p-ruleset-id <> tt0-rule-call-param.ruleset_id THEN do:
       NEXT.
     end.
     IF p-rule-id <> 0 and p-rule-id <> tt0-rule-call-param.RULE_id THEN do:
       NEXT.
     end.
     IF p-order-id <> ? and p-order-id <> tt0-rule-call-param.order_id THEN do:
       NEXT.
     end.
   END.
   if lookup("hidden", tt0-rule-call-param.param-3-data-type) > 0 then do:
     next.
   end.
   IF p-list-mode = {&TABLE_rp-rule-param}
   or p-list-mode = {&TABLE_rp-rule-param}  + {&comma-char} + {&all}
   THEN DO:
      IF p-profile-id <> 0 AND p-profile-id <> tt0-rule-call-param.profile_id THEN do:
        NEXT.
      end.
      IF p-once-more <> ? AND p-once-more <> tt0-rule-call-param.once-more THEN do:
        NEXT.
      end.
   END.
   CREATE tt-rule-call-param.
   BUFFER-COPY tt0-rule-call-param TO tt-rule-call-param.
END.
END PROCEDURE.

procedure rcps_get-value :
&if "{2}" = "full" &then
DEFINE INPUT PARAMETER p-profile-id AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-once-more AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
&endif
DEFINE INPUT PARAMETER p-rp-param-name AS CHARACTER NO-UNDO.
DEFINE INPUT-output PARAMETER pp-index AS integer NO-UNDO.
DEFINE output parameter p-value-character AS CHARACTER NO-UNDO.
DEFINE output parameter p-value-date AS date NO-UNDO.
DEFINE output parameter p-value-decimal AS decimal NO-UNDO.
DEFINE output parameter p-value-integer AS integer NO-UNDO.
DEFINE output parameter p-value-logical AS logical NO-UNDO.
define variable v-current-index as integer no-undo init -1.
define variable v-start as logical no-undo init yes.
DEFINE BUFFER buf_ruledict-param FOR ub.ruledict-param.
DEFINE BUFFER buf_rp-rule-param FOR ub.rp-rule-param.
DEFINE BUFFER buf_tt-rule-call-param FOR tt-rule-call-param.
DEFINE BUFFER buf_term_tt-rule-call-param FOR tt-rule-call-param.

do
on error undo, return error
:
FOR FIRST buf_rp-rule-param WHERE
      buf_rp-rule-param.profile_id = p-profile-id
  AND buf_rp-rule-param.rp-param-name = p-rp-param-name
, each buf_tt-rule-call-param WHERE
   buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
AND buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
AND buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
AND buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
AND buf_tt-rule-call-param.p-index >= pp-index
 ,each buf_term_tt-rule-call-param where
       buf_term_tt-rule-call-param.call_id = buf_tt-rule-call-param.call_id
   and buf_term_tt-rule-call-param.codex_id = buf_tt-rule-call-param.codex_id
   and buf_term_tt-rule-call-param.ruleset_id = buf_tt-rule-call-param.ruleset_id
   and buf_term_tt-rule-call-param.order_id = buf_tt-rule-call-param.order_id
   and buf_term_tt-rule-call-param.param-name = buf_tt-rule-call-param.param-name
   and buf_term_tt-rule-call-param.p-index = buf_tt-rule-call-param.p-index
  by buf_term_tt-rule-call-param.call_id
  by buf_term_tt-rule-call-param.codex_id
  by buf_term_tt-rule-call-param.ruleset_id
  by buf_term_tt-rule-call-param.order_id
  by buf_term_tt-rule-call-param.param-name
  by buf_term_tt-rule-call-param.p-index :
    if v-start
    then do:
      assign
      pp-index = buf_term_tt-rule-call-param.p-index
      p-value-character = buf_term_tt-rule-call-param.param-value-character
      p-value-date      = buf_term_tt-rule-call-param.param-value-date
      p-value-decimal   = buf_term_tt-rule-call-param.param-value-decimal
      p-value-integer   = buf_term_tt-rule-call-param.param-value-integer
      p-value-logical   = buf_term_tt-rule-call-param.param-value-logical
      v-start = no
      .
    end.
    else do:
      if buf_term_tt-rule-call-param.p-index > pp-index then do:
        v-current-index = buf_term_tt-rule-call-param.p-index.
        leave.
      end.
          end.
  end.
  pp-index = v-current-index.
end. /*doe*/
end procedure. /* rcps_get-value */

PROCEDURE rcps_proc-b-add :
&if "{2}" = "full" &then
DEFINE INPUT PARAMETER p-profile-id AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-once-more AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
&endif
DEFINE INPUT PARAMETER p-rp-param-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-index AS integer NO-UNDO.
define variable v-ind as integer no-undo .
define buffer buf_tt-rule-call-param for tt-rule-call-param.
define buffer buf0_tt-rule-call-param for tt-rule-call-param.
define buffer buf2_tt-rule-call-param for tt-rule-call-param.
define buffer buf_rp-rule-param for ub.rp-rule-param.
FOR FIRST buf_rp-rule-param WHERE
          buf_rp-rule-param.profile_id = p-profile-id
      AND buf_rp-rule-param.rp-param-name = p-rp-param-name
    , first buf0_tt-rule-call-param WHERE
       buf0_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
   AND buf0_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
   AND buf0_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
   AND buf0_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name:
  LEAVE.
END.

IF NOT AVAILABLE buf0_tt-rule-call-param THEN do:
  BELL.
  RETURN.
END.
for each buf_rp-rule-param where
        buf_rp-rule-param.rp-param-name = p-rp-param-name
    and buf_rp-rule-param.profile_id = p-profile-id,
    first buf_tt-rule-call-param where
        buf_tt-rule-call-param.call_id = buf0_tt-rule-call-param.call_id
    and buf_tt-rule-call-param.profile_id = buf_rp-rule-param.profile_id
    and buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
    and buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
    and buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
    and buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
    and buf_tt-rule-call-param.once-more = buf0_tt-rule-call-param.once-more
    and buf_tt-rule-call-param.p-index = p-index:
  RETURN. /*уже есть*/
END.

IF lookup("LIST", buf0_tt-rule-call-param.param-3-data-type) = 0
and lookup("SORTED-LIST", buf0_tt-rule-call-param.param-3-data-type) = 0
THEN DO:
  BELL.
  RETURN.
END.
IF buf0_tt-rule-call-param.p-index <> 0 THEN DO:
  BELL.
  RETURN.
END.
find last buf_tt-rule-call-param where
         buf_tt-rule-call-param.call_id = buf0_tt-rule-call-param.call_id
     and buf_tt-rule-call-param.codex_id = buf0_tt-rule-call-param.codex_id
     and buf_tt-rule-call-param.ruleset_id = buf0_tt-rule-call-param.ruleset_id
     and buf_tt-rule-call-param.order_id = buf0_tt-rule-call-param.order_id
     and buf_tt-rule-call-param.param-name = buf0_tt-rule-call-param.param-name no-error .
if available buf_tt-rule-call-param
and (lookup("LIST", buf_tt-rule-call-param.param-3-data-type) > 0
     or
     lookup("SORTED-LIST", buf_tt-rule-call-param.param-3-data-type) > 0
     )
and buf_tt-rule-call-param.p-index > 0 then do:
  v-ind = buf_tt-rule-call-param.p-index.
end.
for each buf_rp-rule-param where
        buf_rp-rule-param.rp-param-name = p-rp-param-name
    and buf_rp-rule-param.profile_id = p-profile-id,
    first buf_tt-rule-call-param where
        buf_tt-rule-call-param.call_id = buf0_tt-rule-call-param.call_id
    and buf_tt-rule-call-param.profile_id = buf_rp-rule-param.profile_id
    and buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
    and buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
    and buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
    and buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
    and buf_tt-rule-call-param.once-more = buf0_tt-rule-call-param.once-more
    and buf_tt-rule-call-param.p-index = 0
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  create buf2_tt-rule-call-param.
  buffer-copy buf_tt-rule-call-param
  except p-index
  to buf2_tt-rule-call-param
  assign
  buf2_tt-rule-call-param.p-index = v-ind + 1
  .
end.
&if "{1}" = "interface" &then
run rcps_Openbr in this-procedure no-error .
&endif
END PROCEDURE.

PROCEDURE rcps_proc-b-del :
&if "{2}" = "full" &then
DEFINE INPUT PARAMETER p-profile-id AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-once-more AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
&endif
DEFINE INPUT PARAMETER p-rp-param-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pp-index AS integer NO-UNDO.

define variable v-ind as integer no-undo .
define variable v-once-more as integer no-undo .
define variable v-call-id as character no-undo .
define buffer buf0_tt-rule-call-param for tt-rule-call-param.
define buffer buf_tt-rule-call-param for tt-rule-call-param.
define buffer buf_rp-rule-param for ub.rp-rule-param.
if pp-index = 0 then do:
  undo, return error substitute("Нельзя удалять корневой параметр &1 (индекс = 0)", p-rp-param-name).
end.
FOR first buf_rp-rule-param WHERE
          buf_rp-rule-param.profile_id = p-profile-id
      AND buf_rp-rule-param.rp-param-name = p-rp-param-name
    , first buf0_tt-rule-call-param WHERE
       buf0_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
   AND buf0_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
   AND buf0_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
   AND buf0_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
   AND buf0_tt-rule-call-param.p-index = pp-index
   :
  LEAVE.
END.
IF NOT AVAILABLE buf0_tt-rule-call-param THEN do:
  FOR first buf_rp-rule-param WHERE
            buf_rp-rule-param.profile_id = p-profile-id
        AND buf_rp-rule-param.rp-param-name = p-rp-param-name
      , last buf0_tt-rule-call-param WHERE
        buf0_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
    AND buf0_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
    AND buf0_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
    AND buf0_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
    AND buf0_tt-rule-call-param.p-index > pp-index :
    leave.
  end.
  IF NOT AVAILABLE buf0_tt-rule-call-param THEN do:
  return "not-found".
  end.
  else do:
    return ''.
  end.
END.
IF lookup("LIST", buf0_tt-rule-call-param.param-3-data-type) = 0
and lookup("SORTED-LIST", buf0_tt-rule-call-param.param-3-data-type) = 0
THEN DO:
  undo, return error substitute("Можно удалять только параметры типа LIST и SORTED-LIST").
END.
IF lookup("READ-ONLY", buf0_tt-rule-call-param.param-3-data-type) > 0 THEN DO:
  undo, return error substitute("Нельзя удалять  параметры типа READ-ONLY").
END.
for each buf_rp-rule-param where
        buf_rp-rule-param.rp-param-name = buf_rp-rule-param.rp-param-name
    and buf_rp-rule-param.profile_id = buf_rp-rule-param.profile_id,
    each buf_tt-rule-call-param where
        buf_tt-rule-call-param.call_id = p-call-id
    and buf_tt-rule-call-param.profile_id = buf_rp-rule-param.profile_id
    and buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
    and buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
    and buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
    and buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
    and buf_tt-rule-call-param.once-more = p-once-more
    and buf_tt-rule-call-param.p-index = pp-index
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile ):
    DELETE buf_tt-rule-call-param.
end.
&if "{1}" = "interface" &then
run rcps_Openbr in this-procedure no-error .
&endif
return ''.
END PROCEDURE.


PROCEDURE rcps_proc-save0 :
FOR EACH tt-rule-call-param
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo , return error substitute( "&1. stop", vss-workfile )
on endkey undo , return error substitute( "&1. endkey", vss-workfile )
:
   find  FIRST tt0-rule-call-param NO-LOCK WHERE
            tt0-rule-call-param.codex_id = tt-rule-call-param.codex_id
       AND  tt0-rule-call-param.ruleset_id = tt-rule-call-param.ruleset_id
       AND tt0-rule-call-param.call_id = tt-rule-call-param.call_id
       AND tt0-rule-call-param.order_id = tt-rule-call-param.order_id
       AND tt0-rule-call-param.param-name = tt-rule-call-param.param-name
       AND tt0-rule-call-param.p-index = tt-rule-call-param.p-index no-error .
   if not available tt0-rule-call-param
   and (lookup("LIST", tt-rule-call-param.param-3-data-type) > 0
        OR
        lookup("SORTED-LIST", tt-rule-call-param.param-3-data-type) > 0
        )
   and tt-rule-call-param.p-index > 0 then do:
     create tt0-rule-call-param.
   end.
   BUFFER-COPY tt-rule-call-param TO tt0-rule-call-param.
END.
FOR EACH tt0-rule-call-param
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo , return error substitute( "&1. stop", vss-workfile )
on endkey undo , return error substitute( "&1. endkey", vss-workfile )
:
  if tt0-rule-call-param.p-index = 0 then next.
  if lookup("hidden", tt0-rule-call-param.param-3-data-type) > 0 then next.
  find  FIRST tt-rule-call-param NO-LOCK WHERE
          tt-rule-call-param.codex_id = tt0-rule-call-param.codex_id
      AND tt-rule-call-param.ruleset_id = tt0-rule-call-param.ruleset_id
      AND tt-rule-call-param.call_id = tt0-rule-call-param.call_id
      AND tt-rule-call-param.order_id = tt0-rule-call-param.order_id
      AND tt-rule-call-param.param-name = tt0-rule-call-param.param-name
      AND tt-rule-call-param.p-index = tt0-rule-call-param.p-index no-error .
  if not available tt-rule-call-param
  and (lookup("LIST", tt0-rule-call-param.param-3-data-type) > 0
      OR
      lookup("SORTED-LIST", tt0-rule-call-param.param-3-data-type) > 0
      )
  and tt0-rule-call-param.p-index > 0
  then do:
     IF p-call-id <> '':U and p-call-id <> tt0-rule-call-param.call_id THEN do:
        NEXT.
     end.
     IF p-codex-id <> 0 and p-codex-id <> tt0-rule-call-param.codex_id THEN do:
       NEXT.
     end.
     IF p-ruleset-id <> 0 and p-ruleset-id <> tt0-rule-call-param.ruleset_id THEN do:
       NEXT.
     end.
     IF p-rule-id <> 0 and p-rule-id <> tt0-rule-call-param.RULE_id THEN do:
       NEXT.
     end.
     IF p-order-id <> ? and p-order-id <> tt0-rule-call-param.order_id THEN do:
       NEXT.
     end.
    IF p-list-mode = {&TABLE_rp-rule-param}
    or p-list-mode = {&TABLE_rp-rule-param}  + {&comma-char} + {&all}
    THEN DO:
      IF p-profile-id <> 0 AND p-profile-id <> tt0-rule-call-param.profile_id THEN do:
        NEXT.
      end.
      IF p-once-more <> ? AND p-once-more <> tt0-rule-call-param.once-more THEN do:
        NEXT.
      end.
    end. /*IF p-list-mode = {&TABLE_rp-rule-param}*/
    delete tt0-rule-call-param.
  end.
end.
END PROCEDURE.

PROCEDURE rcps_set-value :
&if "{2}" = "full" &then
DEFINE INPUT PARAMETER p-profile-id AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-once-more AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
&endif
DEFINE INPUT PARAMETER p-rp-param-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pp-index AS integer NO-UNDO.
DEFINE INPUT parameter p-value-character AS CHARACTER NO-UNDO.
DEFINE INPUT parameter p-value-date AS date NO-UNDO.
DEFINE INPUT parameter p-value-decimal AS decimal NO-UNDO.
DEFINE INPUT parameter p-value-integer AS integer NO-UNDO.
DEFINE INPUT parameter p-value-logical AS logical NO-UNDO.

DEFINE VARIABLE v-codex-id AS integer NO-UNDO.
DEFINE VARIABLE v-ruleset-id AS integer NO-UNDO.
DEFINE VARIABLE v-order-id AS integer NO-UNDO.
DEFINE VARIABLE V-param-name AS character NO-UNDO.
define variable v-found as logical no-undo .

DEFINE BUFFER buf_tt-rule-call-param FOR tt-rule-call-param.
DEFINE BUFFER buf_rp-rule-param FOR ub.rp-rule-param.

FOR FIRST buf_rp-rule-param WHERE
          buf_rp-rule-param.profile_id = p-profile-id
      AND buf_rp-rule-param.rp-param-name = p-rp-param-name
    , first buf_tt-rule-call-param WHERE
       buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
   AND buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
   AND buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
   AND buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name:
  ASSIGN
  v-codex-id = buf_tt-rule-call-param.codex_id
  v-ruleset-id = buf_tt-rule-call-param.ruleset_id
  v-order-id = buf_tt-rule-call-param.order_id
  V-PARAM-NAME = buf_tt-rule-call-param.PARAM-NAME
  .
  LEAVE.
END.
CASE p-list-mode:
  WHEN {&TABLE_rp-rule-param} THEN DO:
    if pp-index > 0
    then do:
      FOR EACH  buf_rp-rule-param NO-LOCK where
          buf_rp-rule-param.profile_id = p-profile-id
          AND buf_rp-rule-param.rp-param-name = p-rp-param-name
          ,EACH buf_tt-rule-call-param WHERE
              buf_tt-rule-call-param.profile_id = p-profile-id
          AND buf_tt-rule-call-param.once-more = p-once-more
          AND buf_tt-rule-call-param.call_id = p-CALL-id
          AND buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
          AND buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
          AND buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
          AND buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
          AND buf_tt-rule-call-param.p-index = pp-index
      ON error undo, return error :
        v-found = yes.
      end.
    end.
    if not v-found then do:
      run rcps_proc-b-add in this-procedure (
      &if "{2}" = "full" &then
                                               input p-profile-id
                                              ,input p-once-more
                                              ,input p-call-id
                                              ,
      &endif
                                               input p-rp-param-name
                                              ,input pp-index).
    end.
    FOR EACH  buf_rp-rule-param NO-LOCK where
        buf_rp-rule-param.profile_id = p-profile-id
        AND buf_rp-rule-param.rp-param-name = p-rp-param-name
        ,EACH buf_tt-rule-call-param WHERE
            buf_tt-rule-call-param.profile_id = p-profile-id
        AND buf_tt-rule-call-param.once-more = p-once-more
        AND buf_tt-rule-call-param.call_id = p-CALL-id
        AND buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
        AND buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
        AND buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
        AND buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
        AND buf_tt-rule-call-param.p-index = pp-index
      ON error undo, return error :
      assign
      buf_tt-rule-call-param.param-value-character = p-value-character
      buf_tt-rule-call-param.param-value-date      = p-value-date
      buf_tt-rule-call-param.param-value-decimal   = p-value-decimal
      buf_tt-rule-call-param.param-value-integer   = p-value-integer
      buf_tt-rule-call-param.param-value-logical   = p-value-logical
      .
    END.
  END.
  WHEN {&TABLE_rule-call-param} THEN DO:
    FIND FIRST buf_tt-rule-call-param WHERE
        buf_tt-rule-call-param.call_id = p-call-id
    AND buf_tt-rule-call-param.codex_id = v-codex-id
    AND buf_tt-rule-call-param.ruleset_id = v-ruleset-id
    AND buf_tt-rule-call-param.order_id = v-order-id
    AND buf_tt-rule-call-param.param-name = V-PARAM-NAME
    AND buf_tt-rule-call-param.p-index = pp-index.
    assign
    buf_tt-rule-call-param.param-value-character = p-value-character
    buf_tt-rule-call-param.param-value-date      = p-value-date
    buf_tt-rule-call-param.param-value-decimal   = p-value-decimal
    buf_tt-rule-call-param.param-value-integer   = p-value-integer
    buf_tt-rule-call-param.param-value-logical   = p-value-logical
    .

  END.
END CASE.
END PROCEDURE.

procedure rcps_get-rule-on-off :
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
define output parameter p-on-off as logical no-undo .
if valid-handle(p-call-handle)
and lookup("rcpscont_get-rule-on-off", p-call-handle:internal-entries) > 0 then do:
  run rcpscont_get-rule-on-off in p-call-handle (
                                           input p-codex-id
                                          ,input p-ruleset-id
                                          ,input p-rule-id
                                          ,input p-profile-id
                                          ,input p-once-more
                                          ,output p-on-off) no-error.
end.
end procedure. /* rcps_get-rule-on-off */

procedure rcps_set-rule-on-off :
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
define input parameter p-on-off as logical no-undo .
if valid-handle(p-call-handle)
and lookup("rcpscont_get-rule-on-off", p-call-handle:internal-entries) > 0 then do:
  run rcpscont_set-rule-on-off in p-call-handle (
                                           input p-codex-id
                                          ,input p-ruleset-id
                                          ,input p-rule-id
                                          ,input p-profile-id
                                          ,input p-once-more
                                          ,input p-on-off) no-error.
end.
end procedure. /* rcps_get-rule-on-off */


&endif /*procedures*/

&if "{1}" = "interface" &then

PROCEDURE rcps_MyEnable0 :
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-ch0 AS widget-handle NO-UNDO.
ASSIGN
term_tt-rule-call-param.param-label:RESIZABLE IN browse br-rcp = YES
X_rp-rule-param.rp-param-name:RESIZABLE IN browse br-rcp = YES
.
ASSIGN
v-ch0 = br-rcp:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
REPEAT WHILE valid-handle(v-ch0):
   IF v-ch0:LABEL = {&label-clmn_8} THEN DO:
     v-ch[1] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = {&label-clmn_9} THEN DO:
     v-ch[2] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = {&label-clmn_10} THEN DO:
     v-ch[3] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = {&label-clmn_11} THEN DO:
     v-ch[4] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = {&label-clmn_12} THEN DO:
     v-ch[5] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = {&label-clmn_13} THEN DO:
     v-ch[6] = v-ch0.
   END.
   IF v-ch0:LABEL = {&label-clmn_14} THEN
   v-ch0:RESIZABLE = YES.
   v-ch0 = v-ch0:NEXT-COLUMN.
END.
assign
X_rp-rule-param.rp-param-name:resizable in browse br-rcp = yes
term_tt-rule-call-param.param-name:resizable in browse br-rcp = yes
term_tt-rule-call-param.param-label:resizable in browse br-rcp = yes
.
CASE p-list-mode:
  WHEN {&TABLE_rule-call-param} THEN DO:
     ASSIGN
     X_rp-rule-param.rp-param-name:VISIBLE IN BROWSE br-rcp = NO
     .
  END.
  WHEN {&TABLE_rp-rule-param}
  or
  when {&TABLE_rp-rule-param} + {&comma-char} + {&all}
  THEN DO:
    assign
    term_tt-rule-call-param.codex_id:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.ruleset_id:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.rule_id:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.order_id:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.param-name:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.param-num:VISIBLE IN BROWSE br-rcp = NO
    .

  END.
END CASE.
 IF p-call-id <> '':U THEN DO:
   v-ch[6]:VISIBLE = NO.
 END.
  IF p-profile-id <> 0 THEN DO:
   term_tt-rule-call-param.profile_id :VISIBLE IN BROWSE br-rcp= NO.
 END.
  IF p-rule-id <> 0 THEN DO:
   term_tt-rule-call-param.RULE_id :VISIBLE IN BROWSE br-rcp= NO.
 END.
  IF p-once-more <> 0 THEN DO:
   term_tt-rule-call-param.once-more :VISIBLE IN BROWSE br-rcp= NO.
 END.
END PROCEDURE.

PROCEDURE rcps_Openbr :
CASE p-list-mode:
  WHEN {&TABLE_rp-rule-param} THEN DO:
      OPEN QUERY br-rcp
      FOR EACH  X_ruledict-param NO-LOCK WHERE X_ruledict-param.entry-id = v-rcps-entry-id
          ,FIRST X_rp-rule-param WHERE
              X_rp-rule-param.profile_id = p-profile-id
          AND X_rp-rule-param.rp-param-name = X_ruledict-param.param-name
        , first tt-rule-call-param WHERE
           tt-rule-call-param.codex_id = X_rp-rule-param.codex_id
       AND tt-rule-call-param.ruleset_id = X_rp-rule-param.ruleset_id
       AND tt-rule-call-param.rule_id = X_rp-rule-param.rule_id
       AND tt-rule-call-param.param-name = X_rp-rule-param.rule-param-name
         ,each term_tt-rule-call-param where
               term_tt-rule-call-param.call_id = tt-rule-call-param.call_id
           and term_tt-rule-call-param.codex_id = tt-rule-call-param.codex_id
           and term_tt-rule-call-param.ruleset_id = tt-rule-call-param.ruleset_id
           and term_tt-rule-call-param.order_id = tt-rule-call-param.order_id
           and term_tt-rule-call-param.param-name = tt-rule-call-param.param-name
      BY tt-rule-call-param.call_id
      BY tt-rule-call-param.codex_id
      BY tt-rule-call-param.ruleset_id
      BY tt-rule-call-param.order_id
      BY tt-rule-call-param.param-num.
  END.
END CASE.
apply "ENTRY" to br-rcp in frame {&frame-name} .
APPLy "VALUE-CHANGED" to br-rcp.
END PROCEDURE.


PROCEDURE rcps_proc-b-chg PRIVATE :
DEFINE VARIABLE v-rec1 AS Rowid NO-UNDO.
DEFINE VARIABLE v-rec2 AS Rowid NO-UNDO.
DEFINE VARIABLE v-rec3 AS Rowid NO-UNDO.
DEFINE VARIABLE v-rec4 AS Rowid NO-UNDO.
define variable v-param-data-type as character no-undo .
define variable v-rid-list as character no-undo .
IF NOT AVAILABLE TERM_tt-rule-call-param  THEN DO:
  RETURN ERROR.
END.

ASSIGN
v-rec1 = rowid(X_ruledict-param)
v-rec2 = rowid(X_rp-rule-param)
v-rec3 = Rowid(tt-rule-call-param)
v-rec4 = Rowid(term_tt-rule-call-param)
.
run rcps_openbr in this-procedure .
REPOSITION br-rcp TO Rowid v-rec1, v-rec2,v-rec3, v-rec4 NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
  REPOSITION br-rcp TO ROW 1 NO-ERROR.
END.
APPLY "ENTRY" TO br-rcp in frame {&frame-name} .
APPLY "VALUE-CHANGED" TO br-rcp in frame {&frame-name} .
END PROCEDURE.

PROCEDURE rcps_set-row-color :
DEFINE INPUT PARAMETER p-data-type AS CHARACTER NO-UNDO.
ASSIGN
v-ch[1]:FGCOLOR = GREY_COLOR
v-ch[1]:BGCOLOR = GREY_Color
v-ch[1]:PFCOLOR = GREY_Color
v-ch[2]:FGCOLOR = GREY_COLOR
v-ch[2]:BGCOLOR = GREY_Color
v-ch[2]:PFCOLOR = GREY_Color
v-ch[3]:FGCOLOR = GREY_COLOR
v-ch[3]:BGCOLOR = GREY_Color
v-ch[3]:PFCOLOR = GREY_Color
v-ch[4]:FGCOLOR = GREY_COLOR
v-ch[4]:BGCOLOR = GREY_Color
v-ch[4]:PFCOLOR = GREY_Color
v-ch[5]:FGCOLOR = GREY_COLOR
v-ch[5]:BGCOLOR = GREY_Color
v-ch[5]:PFCOLOR = GREY_Color
.
CASE entry(1, p-data-type):
     WHEN {&ABL-datatype-character} THEN DO:
      ASSIGN
      v-ch[1]:FGCOLOR = BLACK_COLOR
      v-ch[1]:BGCOLOR = WHITE_Color.
    END.
    WHEN {&ABL-datatype-decimal} THEN DO:
      ASSIGN
      v-ch[3]:FGCOLOR = BLACK_COLOR
      v-ch[3]:BGCOLOR = WHITE_Color.
    END.
    WHEN {&ABL-datatype-integer} THEN DO:
      ASSIGN
      v-ch[4]:FGCOLOR = BLACK_COLOR
      v-ch[4]:BGCOLOR = WHITE_Color.
    END.
    WHEN {&ABL-datatype-date} THEN DO:
      ASSIGN
      v-ch[2]:FGCOLOR = BLACK_COLOR
      v-ch[2]:BGCOLOR = WHITE_Color.
     END.
     WHEN {&ABL-datatype-logical} THEN DO:
       ASSIGN
       v-ch[5]:FGCOLOR = BLACK_COLOR
       v-ch[5]:BGCOLOR = WHITE_Color.
     END.
END CASE.

END PROCEDURE.

&endif /*interface*/

/* $Workfile$ e n d */