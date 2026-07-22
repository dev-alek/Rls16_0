block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Копирование правил

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/07/07
Author: Bakhtadze Natalya
Creation date: 03/07/07

Из  привязок копируется только rule-by-set

*/

define input  parameter p-rule-id1 as integer no-undo .
define output parameter p-rule-id2 as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Копирование правил ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }
{ gbl/key-rec.i }

define variable v-for-script-rule-id as integer no-undo .
define variable v1-entry-id as integer no-undo .
define variable v2-entry-id as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define buffer buf1_rule for ub.rule.
define buffer buf2_rule for ub.rule.
define buffer tree1_rule for ub.rule.
define buffer tree2_rule for ub.rule.
define buffer buf1_rule-script for ub.rule-script.
define buffer buf2_rule-script for ub.rule-script.
define buffer buf1r_rule-script for ub.rule-script.
define buffer buf2r_rule-script for ub.rule-script.

define buffer buf1_rule-i-script for ub.rule-i-script.
define buffer buf2_rule-i-script for ub.rule-i-script.
define buffer buf1_rule-by-set for ub.rule-by-set.
define buffer buf2_rule-by-set for ub.rule-by-set.
define buffer buf1_ruledict for ub.ruledict.
define buffer buf2_ruledict for ub.ruledict.
define buffer last_ruledict for ub.ruledict.

define buffer buf1_ruledict-param for ub.ruledict-param.
define buffer buf2_ruledict-param for ub.ruledict-param.

define temp-table temp-rule no-undo
field rule_id1 as integer
field rule_id2 as integer
index pi is unique primary
rule_id1.

define buffer tree_temp-rule for temp-rule.
define buffer upper_temp-rule for temp-rule.

run waitfram-show in this-procedure ( input "Ждите..." ).
main-block:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):

  find first buf1_rule exclusive-lock where
            buf1_rule.rule_id = p-rule-id1 .
  if buf1_rule.root_rule_id <> buf1_rule.rule_id then do:
     undo main-block, return error substitute( "&1. &2Скопировать можно только корневое правило", vss-workfile, {&new-line} ).
  end.
  create buf2_rule.
  buffer-copy buf1_rule
  except rule_id sts uniq-key-rec root_rule_id
  to buf2_rule
  assign
  buf2_rule.rule_id = next-value(s-rule-id, {&db-name_schema})
  buf2_rule.sts = integer({&new-status-int})
  buf2_rule.root_rule_id = buf2_rule.rule_id
  .
  create temp-rule.
  assign
  temp-rule.rule_id1 = buf1_rule.rule_id
  temp-rule.rule_id2 = buf2_rule.rule_id
  .
  release temp-rule.
  for each tree1_rule where
          tree1_rule.root_rule_id =  buf1_rule.rule_id
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    find first tree_temp-rule no-lock where
              tree_temp-rule.rule_id1 = tree1_rule.rule_id  no-error.
    if not available tree_temp-rule then do:
      create tree_temp-rule.
      assign
      tree_temp-rule.rule_id1 = tree1_rule.rule_id
      tree_temp-rule.rule_id2 = next-value(s-rule-id, {&db-name_schema})
      .
    end.
    IF tree1_rule.rule_id <> buf1_rule.rule_id then do:
      find first upper_temp-rule no-lock where
                upper_temp-rule.rule_id1 = tree1_rule.upper_rule_id  no-error.
      if not available upper_temp-rule then do:
        create upper_temp-rule.
        assign
        upper_temp-rule.rule_id1 = tree1_rule.upper_rule_id
        upper_temp-rule.rule_id2 = next-value(s-rule-id, {&db-name_schema})
        .
      end.
      create tree2_rule.
      buffer-copy tree1_rule
      except rule_id sts uniq-key-rec upper_rule_id root_rule_id
      to tree2_rule
      assign
      tree2_rule.rule_id = tree_temp-rule.rule_id2
      tree2_rule.root_rule_id = buf2_rule.rule_id
      tree2_rule.upper_rule_id = upper_temp-rule.rule_id2
      buf2_rule.sts = integer({&new-status-int})
      v-for-script-rule-id = tree2_rule.rule_id
      .
    end. /*IF tree1_rule.rule_id <> buf1_rule.rule_id then do:*/
    else do:
      v-for-script-rule-id = buf2_rule.rule_id.
    end.
    for each buf1_rule-script where
            buf1_rule-script.rule_id = tree1_rule.rule_id
       and  buf1_rule-script.language = "ABL"
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      create buf2_rule-script.
      buffer-copy buf1_rule-script
      except rule_id root_rule_id
      to buf2_rule-script
      assign
      buf2_rule-script.script_id = next-value(s-rule-script-id, {&db-name_schema})
      buf2_rule-script.rule_id = v-for-script-rule-id
      buf2_rule-script.root_rule_id = buf2_rule.rule_id
      .
      if buf1_rule-script.language = "ABL" then do:
        for each buf1_rule-i-script where
                buf1_rule-i-script.root_rule_id = buf1_rule.rule_id
            and buf1_rule-i-script.script_id = buf1_rule-script.script_id
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        :
          create buf2_rule-i-script.
          buffer-copy buf1_rule-i-script
          except script_id root_rule_id
          to buf2_rule-i-script
          assign
          buf2_rule-i-script.script_id = buf2_rule-script.script_id
          buf2_rule-i-script.root_rule_id = buf2_rule.rule_id
          .
        end. /*for each buf1_rule-i-script where*/
      end.

      find first buf1r_rule-script where
                buf1r_rule-script.script_id = buf1_rule-script.script_id
            and buf1r_rule-script.language = "RUS" no-error .
      if available buf1r_rule-script then do:
        create buf2r_rule-script.
        buffer-copy buf1r_rule-script
        except rule_id root_rule_id script_id
        to buf2r_rule-script
        assign
        buf2r_rule-script.script_id = buf2_rule-script.script_id
        buf2r_rule-script.rule_id =  buf2_rule-script.rule_id
        buf2r_rule-script.root_rule_id = buf2_rule.rule_id
        .
      end.
    end. /*for each buf1_rule-script where*/
  end. /*for each tree1_rule where*/
  find first buf1_ruledict no-lock where
          buf1_ruledict.entry-type = {&rdict-etype-rule}
      and buf1_ruledict.uniq-key-rec = buf1_rule.uniq-key-rec .
  assign
  v1-entry-id = buf1_ruledict.entry-id.
  run gen-key-rec in this-procedure ( input {&table_rule}
                                      ,input buffer buf2_rule:handle
                                      ,output v-uniq-key-rec).
  assign
  buf2_rule.uniq-key-rec = v-uniq-key-rec
  .
  find first buf2_ruledict where
            buf2_ruledict.entry-type = {&rdict-etype-rule}
        and buf2_ruledict.uniq-key-rec =  v-uniq-key-rec no-error.
  if not available buf2_ruledict then do:
    find last last_ruledict no-lock use-index pi.
    create buf2_ruledict.
    assign
    buf2_ruledict.entry-type = {&rdict-etype-rule}
    buf2_ruledict.uniq-key-rec = v-uniq-key-rec
    buf2_ruledict.entry-id = last_ruledict.entry-id + 1
    buf2_ruledict.language = "ABL"
    v2-entry-id = buf2_ruledict.entry-id
    .
  end.


  for each buf1_ruledict-param where
          buf1_ruledict-param.entry-id = v1-entry-id
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      :
    create buf2_ruledict-param.
    buffer-copy buf1_ruledict-param
    except entry-id
    to buf2_ruledict-param
    assign
    buf2_ruledict-param.entry-id = v2-entry-id
    .
  end. /*for each buf1_ruledict-param where*/
  /*
  for each buf1_rule-by-set where
          buf1_rule-by-set.rule_id = buf1_rule.rule_id
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      :
    create buf2_rule-by-set.
    buffer-copy buf1_rule-by-set
    except rule_id
    to buf2_rule-by-set
    assign
    buf2_rule-by-set.rule_id = buf2_rule.rule_id
    .
  end. /*for each buf1_rule-by-set where*/
  */
  p-rule-id2 = buf2_rule.rule_id.
end. /*doe*/

run waitfram-hide in this-procedure .