/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Задание и просмотр параметров вызова правил - профайл 68

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/22/09
Author: Bakhtadze Natalya
Creation date: 06/22/09

*/

DEFINE TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE TEMP-TABLE tt-rule-call-param NO-UNDO LIKE ub.rule-call-param.

DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-call-handle as handle no-undo .
DEFINE INPUT PARAMETER bttns AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-list-mode AS CHARACTER NO-UNDO.
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-order-id as integer no-undo .
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-title AS CHARACTER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR tt0-rule-call-param.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Задание и просмотр параметров вызова правил - профайл 68".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ rul/calldscr.i }
{ gbl/key-rec.i }
{ rul/rulcalpa.i }
{ cmp/r-page0.i new }
{ rul/rcps.i local-var }
{ rul/rcps.i procedures }

define variable v-ii as integer no-undo .
define variable v-obj-type as character no-undo .
define variable v-keys as character no-undo .
define buffer find_rp-by-call for ub.rp-by-call.


IF p-list-mode = {&TABLE_rp-rule-param}
or p-list-mode = {&TABLE_rp-rule-param}  + {&comma-char} + {&all}
THEN DO:
  FIND FIRST buf_rule-profile NO-LOCK WHERE
            buf_rule-profile.profile_id = p-profile-id.
  run gen-key-rec in this-procedure ( input {&table_rule-profile}
                                  ,input buffer buf_rule-profile:handle
                                  ,output v-uniq-key-rec).

  FIND FIRST buf_ruledict NO-LOCK WHERE
            buf_ruledict.entry-type = {&rdict-etype-rule-profile}
      AND  buf_ruledict.uniq-key-rec = v-uniq-key-rec.
  v-rcps-entry-id = buf_ruledict.entry-id.
END.
RUN rcps_fill-table IN THIS-PROCEDURE ( input yes).

define variable custom-par as character no-undo .
custom-par = substitute("params-only=yes,params-only-mode=&1,parent-handle=&2,call=rp-by-call"
                      , p-mode
                      , this-procedure:handle)   .
custom-par = "all,{&Arc-OT-yes},{&Arc-Supp-yes}" + {&comma-char} + "TOG-Shift-2 = yes" + {&comma-char} + custom-par.


if entry(1, p-call-id, {&delim-key}) = {&table_thbj-attr}
and p-mode <> {&lookup}
then do:
  /*если глоб контекст то нам надо чтобы при добавлении алгоритма все галки были бы включены
  а для параметров типа list tt-rule-call-param.p-index > 0 в этом месте программы еще быть не может
  */
  assign
  v-keys = buffer ub.thbj-attr:handle:keys.
  assign
  v-obj-type = entry(lookup("obj-type", v-keys, {&comma-char}) + 1, p-call-id, {&delim-key})
  .
  if v-obj-type = '' then do:
    find first find_rp-by-call no-lock where
              find_rp-by-call.call_id = p-call-id
          and find_rp-by-call.profile_id = p-profile-id
          and find_rp-by-call.once-more = p-once-more no-error.
    if not available find_rp-by-call then do:
      do v-ii = 1 to 9 :
        RUN rcps_set-value IN this-procedure  (
                                        input "p-tog"
                                        ,INPUT v-ii
                                        ,input '' /*p-value-character*/
                                        ,input ?  /*p-value-date*/
                                        ,input 0.0 /*p-value-decimal*/
                                        ,input 0 /*p-value-integer*/
                                        ,input yes /*p-value-logical*/
                                        ) no-error .

      end.
    end.
  end.
end.
run rep/d-report.w
    ( input parparentproc      /* 0 */
    , input 'rep/e-shift.w'   /* 1 */
    , input "СМЕННЫЙ ОТЧЕТ"   /* 2 */
    , input 0                  /* 3 date нет дат */
    , input ""                 /* 4 нет товаров*/
    , input "{&o-currency}"      /* 5 */
    , input ""                 /* 6 */
    , input ""                 /* 7 */
    , input custom-par         /* 8 */
    , input NO                 /* 9 */
    ).


run rcps_proc-save0 in this-procedure .