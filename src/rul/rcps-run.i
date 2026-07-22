/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры работы с rule-call-params в контейнере в момент работы RUM

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/10/09
Author: Bakhtadze Natalya
Creation date: 07/10/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure init-rule-call-params :
define input parameter p-uniq-key-rec as character no-undo .
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_rule-call-param for ub.rule-call-param.

do
on error undo, return error
:
  empty temp-table temp-rule-call-param.
  for each buf_rule-call-param where
          buf_rule-call-param.call_id = p-uniq-key-rec:
    create buf_temp-rule-call-param.
    buffer-copy buf_rule-call-param to buf_temp-rule-call-param.
    if lookup("container", buf_rule-call-param.param-3-data-type) > 0 then do:
      find first buf_temp-rule-call-param where
            buf_temp-rule-call-param.call_id = p-uniq-key-rec
        and buf_temp-rule-call-param.codex_id = 0
        and buf_temp-rule-call-param.ruleset_id = 0
        and buf_temp-rule-call-param.order_id = 0
        and buf_temp-rule-call-param.param-name = buf_rule-call-param.param-name
        and buf_temp-rule-call-param.p-index = buf_rule-call-param.p-index no-error.
      if not available buf_temp-rule-call-param then do:
        create buf_temp-rule-call-param.
        buffer-copy buf_rule-call-param
        except
        codex_id
        ruleset_id
        order_id
        to buf_temp-rule-call-param.
      end.
    end.
  end.
end.

end procedure. /* init-rule-call-params */

procedure update-rule-call-params :
define input parameter p-profile-type as character no-undo .
define input parameter p-uniq-key-rec as character no-undo .

do
on error undo, return error
:
  /*containter*/
  for each temp-rule-call-param where
          temp-rule-call-param.call_id = p-uniq-key-rec
      and temp-rule-call-param.codex_id = 0
      and temp-rule-call-param.ruleset_id = 0
      and temp-rule-call-param.order_id = 0:
    delete temp-rule-call-param.
  end.
  run rul/ruprcall.p (
                       input p-profile-type
                      ,input p-uniq-key-rec
                      ,input {&table_rule-call-param}
                      ,input ? /*p-cmd-proc-handle*/
                      ,input 0 /*p-cmd-code*/
                      ,INPUT TABLE tt0-rp-by-call
                      ,INPUT TABLE tt0-rule-by-call
                      ,INPUT TABLE temp-rule-call-param) no-error .
end.

end procedure. /* update-rule-call-params */


procedure {1}rcps-run_get-value :
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-order-id as integer no-undo .
DEFINE INPUT PARAMETER p-param-name AS CHARACTER NO-UNDO.
DEFINE INPUT-output PARAMETER pp-index AS integer NO-UNDO.
DEFINE output parameter p-value-character AS CHARACTER NO-UNDO.
DEFINE output parameter p-value-date AS date NO-UNDO.
DEFINE output parameter p-value-decimal AS decimal NO-UNDO.
DEFINE output parameter p-value-integer AS integer NO-UNDO.
DEFINE output parameter p-value-logical AS logical NO-UNDO.
define variable v-current-index as integer no-undo init -1.
define variable v-start as logical no-undo init yes.
DEFINE BUFFER buf_temp-rule-call-param FOR temp-rule-call-param.

do
on error undo, return error
:
 for each buf_temp-rule-call-param where
       buf_temp-rule-call-param.call_id = p-call-id
   and buf_temp-rule-call-param.codex_id = p-codex-id
   and buf_temp-rule-call-param.ruleset_id = p-ruleset-id
   and buf_temp-rule-call-param.order_id = p-order-id
   and buf_temp-rule-call-param.param-name = p-param-name
   and buf_temp-rule-call-param.p-index >= pp-index :
  if v-start then do:
      assign
      pp-index = buf_temp-rule-call-param.p-index
      p-value-character = buf_temp-rule-call-param.param-value-character
      p-value-date      = buf_temp-rule-call-param.param-value-date
      p-value-decimal   = buf_temp-rule-call-param.param-value-decimal
      p-value-integer   = buf_temp-rule-call-param.param-value-integer
      p-value-logical   = buf_temp-rule-call-param.param-value-logical
      v-start = no
      .
    end.
    else do:
      if buf_temp-rule-call-param.p-index > pp-index then do:
        v-current-index = buf_temp-rule-call-param.p-index.
        leave.
      end.
    end.
  end.
  pp-index = v-current-index.
end. /*doe*/
end procedure. /* rcps-run_get-value */


PROCEDURE {1}rcps-run_set-value :
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-order-id as integer no-undo .
DEFINE INPUT PARAMETER p-param-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pp-index AS integer NO-UNDO.
define input parameter p-param-mode as character no-undo .
DEFINE INPUT parameter p-value-character AS CHARACTER NO-UNDO.
DEFINE INPUT parameter p-value-date AS date NO-UNDO.
DEFINE INPUT parameter p-value-decimal AS decimal NO-UNDO.
DEFINE INPUT parameter p-value-integer AS integer NO-UNDO.
DEFINE INPUT parameter p-value-logical AS logical NO-UNDO.

define variable v-found as logical no-undo .
define variable v-rp-param-name as character no-undo .
DEFINE BUFFER buf_temp-rule-call-param FOR temp-rule-call-param.
DEFINE BUFFER buf2_temp-rule-call-param FOR temp-rule-call-param.
define buffer buf_rp-rule-param for ub.rp-rule-param.

find first buf_temp-rule-call-param WHERE
        buf_temp-rule-call-param.call_id = p-CALL-id
    AND buf_temp-rule-call-param.codex_id = p-codex-id
    AND buf_temp-rule-call-param.ruleset_id = p-ruleset-id
    AND buf_temp-rule-call-param.order_id = p-order-id
    AND buf_temp-rule-call-param.param-name = p-param-name
    AND buf_temp-rule-call-param.p-index = pp-index no-error.
if pp-index > 0
then do:
  if not available buf_temp-rule-call-param then do:
    find first buf2_temp-rule-call-param WHERE
            buf2_temp-rule-call-param.call_id = p-CALL-id
        AND buf2_temp-rule-call-param.codex_id = p-codex-id
        AND buf2_temp-rule-call-param.ruleset_id = p-ruleset-id
        AND buf2_temp-rule-call-param.order_id = p-order-id
        AND buf2_temp-rule-call-param.param-name = p-param-name
        AND buf2_temp-rule-call-param.p-index = 0 no-error.
    create buf_temp-rule-call-param.
    buffer-copy buf2_temp-rule-call-param
    except p-index
    to buf_temp-rule-call-param
    assign
    buf_temp-rule-call-param.p-index = pp-index
    .
  end.
end.
else do:
  if not available buf_temp-rule-call-param then do:
    undo, return error substitute("Отсутствует параметр &1/&6 для вызова &2 кодекс &3 набор правил &4 порядок &5"
                                  , p-param-name
                                  , p-call-id
                                  , p-codex-id
                                  , p-ruleset-id
                                  , p-order-id
                                  , pp-index).
  end.
end.
assign
buf_temp-rule-call-param.param-value-character = p-value-character
buf_temp-rule-call-param.param-value-date      = p-value-date
buf_temp-rule-call-param.param-value-decimal   = p-value-decimal
buf_temp-rule-call-param.param-value-integer   = p-value-integer
buf_temp-rule-call-param.param-value-logical   = p-value-logical
.
if not (p-codex-id = 0
        and
        p-ruleset-id = 0
        and
        p-order-id = 0) /*not container*/  then do:

find first buf_rp-rule-param no-lock where
         buf_rp-rule-param.profile_id = buf_temp-rule-call-param.profile_id
    and  buf_rp-rule-param.codex_id = p-codex-id
    and  buf_rp-rule-param.ruleset_id = p-ruleset-id
    and  buf_rp-rule-param.rule_id = buf_temp-rule-call-param.rule_id
    and  buf_rp-rule-param.rule-param-name = p-param-name.
assign
v-rp-param-name = buf_rp-rule-param.rp-param-name.
for each buf_rp-rule-param no-lock where
         buf_rp-rule-param.profile_id = buf_temp-rule-call-param.profile_id
     and buf_rp-rule-param.rp-param-name = v-rp-param-name,
    each buf2_temp-rule-call-param where
        buf2_temp-rule-call-param.call_id = p-call-id
    and buf2_temp-rule-call-param.profile_id = buf_temp-rule-call-param.profile_id
    and buf2_temp-rule-call-param.once-more = buf_temp-rule-call-param.once-more
    and buf2_temp-rule-call-param.codex_id = buf_rp-rule-param.codex_id
    and buf2_temp-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
    and buf2_temp-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
    and buf2_temp-rule-call-param.p-index = pp-index
    :
  assign
  buf2_temp-rule-call-param.param-value-character = p-value-character
  buf2_temp-rule-call-param.param-value-date      = p-value-date
  buf2_temp-rule-call-param.param-value-decimal   = p-value-decimal
  buf2_temp-rule-call-param.param-value-integer   = p-value-integer
  buf2_temp-rule-call-param.param-value-logical   = p-value-logical
  .
end.
end.

end procedure. /* rcps-run_set-value */

procedure {1}rcps-run_fill-rcp-from-tt0 :
define input parameter p-call-id as character no-undo .
define input parameter p-bh as handle no-undo .
define buffer buf_tt0-rule-call-param for tt0-rule-call-param.

for each buf_tt0-rule-call-param where
       buf_tt0-rule-call-param.call_id = p-call-id
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo , return error substitute( "&1. stop", vss-workfile )
on endkey undo , return error substitute( "&1. endkey", vss-workfile )
:
  p-bh:buffer-create ().
  p-bh:buffer-copy(buffer buf_tt0-rule-call-param:handle).
  p-bh:buffer-release.


end.

end procedure. /* {1}rcps-run_fill-rcp-from-tt0 */

/* $Workfile$ e n d */