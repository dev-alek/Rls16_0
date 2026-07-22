block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ѕеренос прив€зок с одного правила на другое

јвтор: Ѕахтадзе Ќаталь€ ¬икторовна
ƒата создани€: 03/07/07
Author: Bakhtadze Natalya
Creation date: 03/07/07

*/


define input parameter p-rule-id-1 as integer no-undo .
define input parameter p-rule-id-2 as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "ѕеренос прив€зок с одного правила на другое".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-log as logical no-undo .
define variable v-chr as character no-undo .
define buffer src_rule for ub.rule.  /*замен€ющее*/
define buffer trg_rule for ub.rule. /*замен€емое*/
define buffer src_rule-by-set for ub.rule-by-set.  /*замен€ющее*/
define buffer trg_rule-by-set for ub.rule-by-set. /*замен€емое*/
define buffer src_ruledict for ub.ruledict.  /*замен€ющее*/
define buffer trg_ruledict for ub.ruledict. /*замен€емое*/
define buffer src_ruledict-param for ub.ruledict-param.  /*замен€ющее*/
define buffer trg_ruledict-param for ub.ruledict-param. /*замен€емое*/
define buffer src_rule-by-call for ub.rule-by-call.  /*замен€ющее*/
define buffer trg_rule-by-call for ub.rule-by-call. /*замен€емое*/
define buffer src_rule-by-profile for ub.rule-by-profile.  /*замен€ющее*/
define buffer trg_rule-by-profile for ub.rule-by-profile. /*замен€емое*/
define buffer src_rule-call-param for ub.rule-call-param.  /*замен€ющее*/
define buffer trg_rule-call-param for ub.rule-call-param. /*замен€емое*/
define buffer src_rp-rule-param for ub.rp-rule-param.  /*замен€ющее*/
define buffer trg_rp-rule-param for ub.rp-rule-param. /*замен€емое*/


main-block:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  find first trg_rule exclusive-lock where
          trg_rule.rule_id = p-rule-id-1 no-error.
  find first src_rule exclusive-lock where
          src_rule.rule_id = p-rule-id-2 no-error.

  if src_rule.rule_id = trg_rule.rule_id then do:
    undo main-block, return error substitute( "Ќельз€ замен€ть правило самим собой: замен€емое правило &1, замен€ющее правило &2"
                                             , p-rule-id-1
                                             , p-rule-id-2).
  end.
  if not (src_rule.sts = integer({&ready-status-int})
         or
         src_rule.sts = integer({&used-status-int})) then do:
&scop status-code string(src_rule.sts)
    undo main-block, return error substitute( "«амен€ющее правило &1 имеет статус &2"
                                             , p-rule-id-2
                                             , {&rule-status-int-name}).

  end.

  if src_rule.codex_id  <> trg_rule.codex_id then do:
    undo main-block, return error substitute( "«амен€емое правило &1 принадлежит кодексу &2, замен€ющее правило &3 - кодексу &4"
                                             , trg_rule.rule_id
                                             , trg_rule.codex_id
                                             , src_rule.rule_id
                                             , src_rule.codex_id
                                             ).

  end.
  /*сравним rulesetы*/
  for each trg_rule-by-set no-lock where
          trg_rule-by-set.rule_id = trg_rule.rule_id
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
     find first src_rule-by-set no-lock where
                src_rule-by-set.rule_id = src_rule.rule_id
            and src_rule-by-set.codex_id = trg_rule-by-set.codex_id
            and src_rule-by-set.ruleset_id = trg_rule-by-set.ruleset_id no-error.
    if not available src_rule-by-set then do:
      undo main-block, return error substitute( "” замен€ющего правила &1 отсутствует прив€зка к кодексу &2 набору правил &3, имеюща€с€ у замен€емого правила &4"
                                              , src_rule.rule_id
                                              , trg_rule-by-set.codex_id
                                              , trg_rule-by-set.ruleset_id
                                              , trg_rule.rule_id
                                              ).
    end.
  end.
  /*сравним ruledict-param*/
  find first trg_ruledict where
            trg_ruledict.entry-type = {&rdict-etype-rule}
        and trg_ruledict.uniq-key-rec = trg_rule.uniq-key-rec no-error.
  if not available trg_ruledict then do:
    undo main-block, return error substitute( "” замен€емого правила &1 отсутствует прив€зка к словарю правил"
                                            , trg_rule.rule_id
                                            ).
  end.

  find first src_ruledict where
            src_ruledict.entry-type = {&rdict-etype-rule}
        and src_ruledict.uniq-key-rec = src_rule.uniq-key-rec no-error.
  if not available src_ruledict then do:
    undo main-block, return error substitute( "” замен€еющего правила &1 отсутствует прив€зка к словарю правил"
                                            , src_rule.rule_id
                                            ).
  end.

  for each trg_ruledict-param no-lock where
          trg_ruledict-param.entry-id = trg_ruledict.entry-id
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
     find first src_ruledict-param no-lock where
                src_ruledict-param.entry-id = src_ruledict.entry-id
            and src_ruledict-param.language = trg_ruledict-param.language
            and src_ruledict-param.param-num = trg_ruledict-param.param-num no-error.
    if not available src_rule-by-set then do:
      undo main-block, return error substitute( "” замен€ющего правила &1 отсутствует параметр &2 (&3), имеющийс€ у замен€емого правила &4"
                                              , src_rule.rule_id
                                              , trg_ruledict-param.param-num
                                              , trg_ruledict-param.param-name
                                              , trg_rule.rule_id
                                              ).
    end.
    buffer-compare trg_ruledict-param
    except entry-id whole-send-news documentation param-label
    init-value-character init-value-date init-value-decimal init-value-integer init-value-logical
    to src_ruledict-param
    save result in v-chr.
    if v-chr <> '':U then do:
      undo main-block, return error substitute( "ѕараметр &2(&3) замен€ющего правила &1, отличаетс€ от аналогичного параметра замен€емого правила &4&5&6"
                                              , src_rule.rule_id
                                              , trg_ruledict-param.param-num
                                              , trg_ruledict-param.param-name
                                              , trg_rule.rule_id
                                              , {&new-line}
                                              , v-chr
                                              ).
    end.
  end.
  for each src_ruledict-param no-lock where
          src_ruledict-param.entry-id = src_ruledict.entry-id
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
     find first trg_ruledict-param no-lock where
                trg_ruledict-param.entry-id = trg_ruledict.entry-id
            and trg_ruledict-param.language = src_ruledict-param.language
            and trg_ruledict-param.param-num = src_ruledict-param.param-num no-error.
    if not available src_rule-by-set then do:
      undo main-block, return error substitute( "” замен€ющего правила &1 присутствует параметр &2 (&3), отсутствующий у замен€емого правила &4"
                                              , src_rule.rule_id
                                              , trg_ruledict-param.param-num
                                              , trg_ruledict-param.param-name
                                              , trg_rule.rule_id
                                              ).
    end.
  end.
  for each trg_rule-by-call where
          trg_rule-by-call.rule_id = trg_rule.rule_id
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
    for each trg_rule-call-param where
            trg_rule-call-param.rule_id = trg_rule.rule_id
        and trg_rule-call-param.codex_id = trg_rule-by-call.codex_id
        and trg_rule-call-param.ruleset_id = trg_rule-by-call.ruleset_id
        and trg_rule-call-param.call#_id = trg_rule-by-call.call#_id
        and trg_rule-call-param.order_id = trg_rule-by-call.order_id
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
      assign
      trg_rule-call-param.rule_id = src_rule.rule_id.
    end.
    assign
    trg_rule-by-call.rule_id = src_rule.rule_id
    .
  end.
  for each trg_rule-by-profile where
          trg_rule-by-profile.rule_id = trg_rule.rule_id
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
    create
    src_rule-by-profile.
    buffer-copy trg_rule-by-profile
    except rule_id
    to src_rule-by-profile
    assign
    src_rule-by-profile.rule_id = src_rule.rule_id
    .
    trg_rule-by-profile.is_dynamic = ?.
    delete trg_rule-by-profile.
  end.
  for each trg_rp-rule-param where
          trg_rp-rule-param.rule_id = trg_rule.rule_id
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
    create src_rp-rule-param .
    buffer-copy trg_rp-rule-param except rule_id to src_rp-rule-param
    assign
    src_rp-rule-param.rule_id = src_rule.rule_id
    .
    delete trg_rp-rule-param.
  end.
end. /*doe*/