/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Задание и просмотр параметров вызова правил - профайл 60

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
define variable vss-description as character no-undo init "Задание и просмотр параметров вызова правил - профайл 52".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ rul/calldscr.i }
{ gbl/key-rec.i }
{ rul/rulcalpa.i }
{ cmp/r-page0.i new }
{ rul/rcps.i local-var full }
{ rul/rcps.i procedures full }
{ gbl/onewin.i   }

define variable p-cmb-call-id as character no-undo .
define variable p-cmb-profile-id as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-cur-ext-key as character no-undo .
define variable v-accepted as logical no-undo .
define variable v-index-id as integer no-undo .
define variable v-profile-id-list as character no-undo .
define variable v-call-id-list as character no-undo .
define variable v-once-more-list as character no-undo .

define buffer cmb_rule-profile for ub.rule-profile.
define buffer buf_profile-by-profile for ub.profile-by-profile.
define buffer buf2_rule-profile for ub.rule-profile.
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_ext-system  for ub.ext-system .
define buffer buf_temp_onewin_itemsSelected for temp_onewin_itemsSelected.

p-cmb-call-id = p-call-id.
p-cmb-profile-id = p-profile-id.

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

/*это заполненеие для cmb профайла*/
RUN rcps_fill-table IN THIS-PROCEDURE ( input yes).

if p-mode = {&add-def} then do:
  for each buf_profile-by-profile no-lock where
          buf_profile-by-profile.profile_id = p-cmb-profile-id,
      first buf2_rule-profile no-lock where
            buf2_rule-profile.profile_id = buf_profile-by-profile.child-profile_id:
    assign
    p-call-id = p-cmb-call-id.
    entry(lookup({&cmb}, p-cmb-call-id, {&delim-key}), p-call-id, {&delim-key}) = buf2_rule-profile.profile-type.
    p-profile-id = buf_profile-by-profile.child-profile_id.
    /*to-do с 1 что-то надо делать*/
    assign
    v-call-id-list = v-call-id-list + (if v-call-id-list = '' then '' else {&delim-par})  +  p-call-id
    v-profile-id-list = v-profile-id-list + (if v-profile-id-list = '' then '' else {&comma-char}) + string(p-profile-id)
    v-once-more-list = v-once-more-list + (if v-once-more-list = '' then '' else {&comma-char})  +  string(1)
    .
    RUN rcps_fill-table IN THIS-PROCEDURE ( input no).
  end.
end.
else do:
  do v-ii = 1 to num-entries({&profile-type-list}):
    assign
    p-call-id = p-cmb-call-id.
    entry(lookup({&cmb}, p-cmb-call-id, {&delim-key}), p-call-id, {&delim-key}) = entry(v-ii, {&profile-type-list}).
    for each buf_rp-by-call no-lock where
            buf_rp-by-call.call_id = p-call-id
        and (
            (buf_rp-by-call.profile_id = 60
             and buf_rp-by-call.once-more = p-once-more)
             or
             (buf_rp-by-call.parent-profile_id = 60
              and buf_rp-by-call.parent-once-more = p-once-more)
            )
        :
      p-profile-id = buf_rp-by-call.profile_id.
      assign
      v-call-id-list = v-call-id-list + (if v-call-id-list = '' then '' else {&delim-par})  +  p-call-id
      v-profile-id-list = v-profile-id-list + (if v-profile-id-list = '' then '' else {&comma-char}) + string(p-profile-id)
      v-once-more-list = v-once-more-list + (if v-once-more-list = '' then '' else {&comma-char})  +  string(buf_rp-by-call.once-more)
      .
      RUN rcps_fill-table IN THIS-PROCEDURE ( input no).
    end.
  end.
end.
for each tt-rule-call-param where
        tt-rule-call-param.param-name = "p-esys-id-list"
  and tt-rule-call-param.p-index > 0
break
by tt-rule-call-param.p-index:
  if first-of(tt-rule-call-param.p-index) then do:
    find first buf_ext-system no-lock where
              buf_ext-system.db-num = 0
          and buf_ext-system.esys-id = tt-rule-call-param.param-value-integer.
          run onewin_add-item in this-procedure (
                input string(buf_ext-system.esys-id)
              , input buf_ext-system.esys-name
              , ''
              , input yes
          ).
  END.
END.
run gbl/onewin.w (
      input parparentproc
    , input 1
    , input "Список внешних систем типа ДКLink"
    , input "":U
    , input "&Тест"
    , input table temp_onewin_items
    , output table temp_onewin_itemsSelected
    , output v-cur-ext-key
    , output v-accepted
).
IF v-accepted THEN DO:
  FOR EACH buf_temp_onewin_itemsSelected:
    FIND FIRST buf_ext-system NO-LOCK WHERE
              buf_ext-system.esys-id = integer(buf_temp_onewin_itemsSelected.itmextkey)
        AND buf_ext-system.db-num = 0
        NO-ERROR.
    IF AVAILABLE buf_ext-system THEN DO:
      v-index-id = v-index-id + 1.
      do v-ii =1 to num-entries(v-call-id-list, {&delim-par} ):
        RUN rcps_set-value IN this-procedure  (
                                         input integer(entry(v-ii, v-profile-id-list))
                                        ,input integer(entry(v-ii, v-once-more-list))
                                        ,input entry(v-ii, v-call-id-list, {&delim-par} )
                                        ,input "p-esys-id-list"
                                        ,INPUT v-index-id
                                        ,input '' /*p-value-character*/
                                        ,input ?  /*p-value-date*/
                                        ,input 0.0 /*p-value-decimal*/
                                        ,input buf_ext-system.esys-id /*p-value-integer*/
                                        ,input no /*p-value-logical*/
                                        ) no-error .
        if error-status:error then do:
          message
          error-status:get-message(1) return-value
          view-as alert-box .
          undo, return error .
        end.
      end. /*      do v-ii =1 to num-entries(v-call-id-list, {&delim-par} ):*/
    END.
  END.
  for each tt-rule-call-param where
          tt-rule-call-param.param-name = "p-esys-id-list"
    and tt-rule-call-param.p-index > v-index-id
  break
  by tt-rule-call-param.p-index:
    run rcps_proc-b-del in this-procedure (
                                             input tt-rule-call-param.profile_id
                                            ,input tt-rule-call-param.once-more
                                            ,input tt-rule-call-param.call_id
                                            ,input "p-esys-id-list"
                                            ,input tt-rule-call-param.p-index
                                            ).
  END.
end.
do v-ii = 1 to num-entries(v-call-id-list, {&delim-par} ):
  assign
  p-call-id = entry(v-ii, v-call-id-list, {&delim-par} )
  p-profile-id = integer(entry(v-ii, v-profile-id-list, {&comma-char} ))
  p-once-more = integer(entry(v-ii, v-once-more-list, {&comma-char} ))
  .
run rcps_proc-save0 in this-procedure .
end.


PROCEDURE onewin_custom-add-item :
DEFINE INPUT PARAMETER p-onewin-handle AS HANDLE NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-uniq-key-rec as character no-undo .
define variable v-ok as logical no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-exists as logical no-undo .
define buffer buf_ext-system for ub.ext-system.
define buffer buf_temp_onewin_items for temp_onewin_items.

run bge/oxmlexts.p (
      input parparentproc
    , input 1                         /* 2- Единичный выбор - 0. Множественный - 1*/
    , input substitute("esys-type = &1", {&openxml-type-dklink}) /*p-where-string*/
    , input v-uniq-key-rec        /* То, что уже выбрано (список) */
    , output v-rid-list          /* Список выбранных подсистем ( string( db-num ) + chr(6) + string( esys-id ) )*/
    , output v-ok               /* yes, если выбор был сделан. no - Если был отказ от выбора */
).
if v-ok then do:
  do v-ii = 1 to num-entries(v-rid-list):
    run gen-row-keyr in this-procedure
      ( input entry(v-ii, v-rid-list)
        ,input ?
        ,input "ub"
        ,input ?
        ,input no-lock
        ,output v-tbl-row
        ,output v-tbl-name
      ).
    find first buf_ext-system no-lock where
              rowid(buf_ext-system) = v-tbl-row.
    if not (buf_ext-system.esys-type = integer({&openxml-type-dklink})) then do:
      message
      "Нужно выбрать ВНЕШНЮЮ СИСТЕМУ типа ДатаКрат DKLink"
      view-as alert-box error .
      undo, return error.
    end.
    find first buf_temp_onewin_items where
            buf_temp_onewin_items.itmextkey = string(buf_ext-system.esys-id) no-error.
    if not available temp_onewin_items then do:
      run onewin_check-item in p-onewin-handle (
                                                  input string(buf_ext-system.esys-id)
                                                ,output v-exists) no-error.
      if v-exists then do:
        message
        substitute("Вы уже выбрали ВС &1!", buf_ext-system.esys-id)
        view-as alert-box warning.
        return.
      end.
      run onewin_add-item in p-onewin-handle (
            input string(buf_ext-system.esys-id)
          , input buf_ext-system.esys-name
          , ''
          , input yes
      ).
    end.
    else do:
      message
      substitute("Вы уже выбрали ВС &1!", buf_ext-system.esys-id)
      view-as alert-box warning.
      return.
    end.
  end.
end. /*if v-ok then do:*/
END PROCEDURE.


PROCEDURE onewin_get-bttns :
DEFINE OUTPUT PARAMETER p-bttns as character no-undo .
if p-mode = {&lookup} then do:
  if  lookup("b-chg", bttns) = 0
and lookup("running", bttns) = 0
then do:
  p-bttns = "".
end.
else do:
  p-bttns = "b-del,b-exit".
end.
end.
else do:
  p-bttns = "b-add,b-del,b-exit".
end.
END PROCEDURE.