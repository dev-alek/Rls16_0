/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Задание и просмотр параметров вызова правил - профайл 50

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/22/09
Author: Bakhtadze Natalya
Creation date: 06/22/09

no_app_help.i

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
define variable vss-description as character no-undo init "Задание и просмотр параметров вызова правил - профайл 50".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ rul/calldscr.i }
{ gbl/key-rec.i }
{ rul/rulcalpa.i }
{ cmp/r-page0.i new }
{ rul/rcps.i local-var }
{ rul/rcps.i procedures }

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

run rep/d-report.w
    ( input parparentproc      /* 0 */
    , input 'rep/e-dispet.w'   /* 1 */
    , input "Отчет диспетчера" /* 2 */
    , input 0                  /* 3 date нет дат */
    , input ""                 /* 4 */
    , input "{&o-choice}"      /* 5 */
    , input ""                 /* 6 */
    , input ""                 /* 7 */
    , input substitute("shop,{&Excel-yes},params-only=yes,params-only-mode=&1,parent-handle=&2,call=schedule"
                      , p-mode
                      , this-procedure:handle)     /* 8 */
    , input NO                 /* 9 */
    ).


run rcps_proc-save0 in this-procedure .