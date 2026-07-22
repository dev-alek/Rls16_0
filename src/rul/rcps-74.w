/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Задание и просмотр параметров вызова правил - профайл 74

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/01/10
Author: Bakhtadze Natalya
Creation date: 06/01/10

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
define variable vss-description as character no-undo init "Задание и просмотр параметров вызова правил - профайл 74".
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
define new shared variable is-doc as logical no-undo .
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
define variable v-index-id as integer no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
define variable v-price-type as integer no-undo .
define variable v-r-b as character no-undo .


define variable custom-par as character no-undo .
custom-par = substitute("params-only=yes,params-only-mode=&1,parent-handle=&2,call=rp-by-call"
                      , p-mode
                      , this-procedure:handle)   .
custom-par = "{&shop},{&send-check}"  + {&comma-char} +
              substitute("X-SET_val_TYPE=&1", {&v-rubl}) + {&comma-char} +
             custom-par.

is-doc = yes.

run rep/d-report.w
    ( input parparentproc      /* 0 */
    , input 'rep/e-km7.w'   /* 1 */
    , input "КМ-7":U
    , input 0                  /* 3 date нет дат */
    , input ""                 /* 4 нет товаров*/
    , input "{&o-currency}"      /* 5 */
    , input ""
    , input "{&v-rubl}"
    , input custom-par         /* 8 */
    , input NO                 /* 9 */
    ).

run rcps_proc-save0 in this-procedure .