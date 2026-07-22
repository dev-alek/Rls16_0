/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура для контейнера загружающего rcps - процедуры редактирования параметров правил

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/07/10
Author: Bakhtadze Natalya
Creation date: 04/07/10

*/

procedure rcpscont_get-rule-on-off :
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
define output parameter p-on-off as logical no-undo .

define buffer buf_tt0-rule-by-call for {1}.
find first buf_tt0-rule-by-call where
         buf_tt0-rule-by-call.codex_id = p-codex-id
     and buf_tt0-rule-by-call.ruleset_id = p-ruleset-id
     and buf_tt0-rule-by-call.profile_id = p-profile-id
     and buf_tt0-rule-by-call.once-more = p-once-more
     and buf_tt0-rule-by-call.rule_id = p-rule-id
     no-error .
if available buf_tt0-rule-by-call then do:
   p-on-off = buf_tt0-rule-by-call.can-calc.
end.
end procedure. /* rcpscont_get-rule-on-off */

procedure rcpscont_set-rule-on-off :
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
define input parameter p-on-off as logical no-undo .
define variable v-h as handle no-undo .
define buffer buf_tt0-rule-by-call for {1}.
v-h = buffer {1}:handle.
if v-h:table <> ''
and v-h:table <> ? then do:
  find first buf_tt0-rule-by-call where
          buf_tt0-rule-by-call.codex_id = p-codex-id
      and buf_tt0-rule-by-call.ruleset_id = p-ruleset-id
      and buf_tt0-rule-by-call.profile_id = p-profile-id
      and buf_tt0-rule-by-call.once-more = p-once-more
      and buf_tt0-rule-by-call.rule_id = p-rule-id   no-error .
  if not available buf_tt0-rule-by-call then do:
    undo, return error .
  end.
  buf_tt0-rule-by-call.can-calc = p-on-off .
  release buf_tt0-rule-by-call.
end.
{2}
end procedure. /* rcpscont_set-rule-on-off */

/* $Workfile$ e n d */