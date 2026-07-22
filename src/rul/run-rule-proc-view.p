block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запуск просмотра процессов в RUM

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/27/08
Author: Bakhtadze Natalya
Creation date: 02/27/08

*/

define input parameter p-pchain-type as character no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-mode as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запуск просмотра процессов в RUM".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ rul/pch-link.i "NEW SHARED" }

define variable v-ii as integer no-undo .
define variable v-codes as character no-undo .
define variable v-labels as character no-undo .
define variable v-sel-code as character no-undo .
define variable v-pchain-id-list as character no-undo .
define variable v-pchain-id-name as character no-undo .
define variable v-found as logical no-undo .
define buffer buf_rule-by-profile for ub.rule-by-profile.
define buffer buf_rule-process for ub.rule-process.


case p-pchain-type:
  when {&table_dis-card-type} then do:
    v-pchain-id-list = {&dct-proc-list}.
  end.
  when {&table_goods} then do:
    v-pchain-id-list = {&goods-proc-list}.
  end.
  when {&table_clients} then do:
    v-pchain-id-list = {&clients-proc-list}.
  end.
  when {&table_gds-grp} then do:
    v-pchain-id-list = {&gds-grp-proc-list}.
  end.
  when {&table_cli-grp} then do:
    v-pchain-id-list = {&cli-grp-proc-list}.
  end.
  when {&table_chk-doc} + "_" + {&cd-type-ibs-th} then do:
    v-pchain-id-list = {&chk-doc-proc-list}.
  end.
  when {&table_chk-doc} + "_" + {&cd-type-ibs-th-mob} then do:
    v-pchain-id-list = {&chk-doc-proc-list}.
  end.
  when {&edoc} then do:
    v-pchain-id-list = {&edoc-proc-list}.
  end.
  when {&thref} then do:
    v-pchain-id-list = {&thref-proc-list}.
  end.
  when {&pdf} then do:
    v-pchain-id-list = {&pdf-proc-list}.
  end.
  when {&rep} then do:
    v-pchain-id-list = {&rep-proc-list}.
  end.
  otherwise do:
  end.
END case.

DO v-ii = 1 TO NUM-ENTRIES(v-pchain-id-list):
  for each buf_rule-process
  where buf_rule-process.pchain-type = p-pchain-type
  and buf_rule-process.pchain-id = entry(v-ii, v-pchain-id-list)
  break
  by buf_rule-process.pchain-type
  by buf_rule-process.pchain-id
  by buf_rule-process.start-from
  :

    if first-of(buf_rule-process.pchain-id) then do:
      case p-pchain-type:
        when {&table_dis-card-type} then do:
&scop dct-proc-code buf_rule-process.pchain-id
          v-pchain-id-name = {&dct-proc-name}.
        end.
        when {&table_goods} then do:
&scop goods-proc-code buf_rule-process.pchain-id
          v-pchain-id-name = {&goods-proc-name}.
        end.
        when {&table_clients} then do:
&scop clients-proc-code buf_rule-process.pchain-id
          v-pchain-id-name = {&clients-proc-name}.
        end.
        when {&table_gds-grp} then do:
&scop gds-grp-proc-code buf_rule-process.pchain-id
          v-pchain-id-name = {&gds-grp-proc-name}.
        end.
        when {&table_cli-grp} then do:
&scop cli-grp-proc-code buf_rule-process.pchain-id
          v-pchain-id-name = {&cli-grp-proc-name}.
        end.
        when {&table_chk-doc} + "_" + {&cd-type-ibs-th}
        or
        when {&table_chk-doc} + "_" + {&cd-type-ibs-th-mob}
        then do:
&scop chk-doc-proc-code buf_rule-process.pchain-id
          v-pchain-id-name = {&chk-doc-proc-name}.
        end.
        when {&edoc} then do:
&scop edoc-proc-code buf_rule-process.pchain-id
          v-pchain-id-name = {&edoc-proc-name}.
        end.
        when {&thref} then do:
&scop thref-proc-code buf_rule-process.pchain-id
          v-pchain-id-name = {&thref-proc-name}.
        end.
        when {&pdf} then do:
&scop pdf-proc-code buf_rule-process.pchain-id
          v-pchain-id-name = {&pdf-proc-name}.
        end.
        when {&rep} then do:
&scop rep-proc-code buf_rule-process.pchain-id
          v-pchain-id-name = {&rep-proc-name}.
        end.
      end case.
    end. /*if first-of(buf_rule-process.start-from) then do:*/
    if first-of(buf_rule-process.start-from) then do:
      v-found = no.
    end.
    if p-profile-id > 0 then do:
      find first buf_rule-by-profile no-lock where
                buf_rule-by-profile.codex_id = buf_rule-process.codex_id
            and buf_rule-by-profile.ruleset_id = buf_rule-process.ruleset_id
            and buf_rule-by-profile.profile_id = p-profile-id no-error.
      if available buf_rule-by-profile then v-found = yes.
    end.
    if last-of(buf_rule-process.start-from) then do:
      if p-profile-id = 0
      or v-found = yes then do:
        assign
        v-codes = v-codes +
                (if v-codes = '':U then "" else "|") +
                substitute("&1=&2"
                            ,entry(v-ii, v-pchain-id-list)
                            ,(if buf_rule-process.start-from = 0 then "0" else "1")
              )
        v-labels = v-labels +
                (if v-labels = '':U then "" else "|") +
                substitute("&1 Активная сторона - &2"
                          ,string(v-pchain-id-name, "X(50)")
                          ,(if buf_rule-process.start-from > 0 then "УБД" else "ГБД")
              ).
      end.
    end. /*if last-of(buf_rule-process.start-from) then do:*/
  end. /*  for each buf_rule-process*/
end.

run gbl/d-list.w (
               INPUT "b-sel":U
              ,INPUT "Выберите процесс"
              ,INPUT v-codes
              ,INPUT v-labels
              ,INPUT "|"
              ,INPUT "":U
              ,output v-sel-code).
IF v-sel-code = "":u THEN do:
  RETURN ''.
end.

run rul/rule-proc-view.p ( input p-pchain-type
                          ,input entry(1, v-sel-code, "=")
                          ,input integer(entry(2, v-sel-code, "="))
                          ,input p-call-id
                          ,input p-profile-id /*p-profile-id*/
                          ,input -1 /* все имеющиеся привязыки этого профайла или неважно*/
                          ,input p-mode
                          ,input ? /*где добавлять строки - handle*/
                          ) no-error.
if error-status:error then do:
  return error return-value .
end.