block-level on error undo, throw.
define input parameter p-rule-id-1 as integer no-undo .
define input parameter p-rule-id-2 as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "ѕеренос прив€зок с одного правила на другое".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable v-log as logical no-undo .
define variable v-chr as character no-undo .
define buffer src_rule for ub.rule.
define buffer trg_rule for ub.rule.
define buffer src_rule-by-set for ub.rule-by-set.
define buffer trg_rule-by-set for ub.rule-by-set.
define buffer src_ruledict for ub.ruledict.
define buffer trg_ruledict for ub.ruledict.
define buffer src_ruledict-param for ub.ruledict-param.
define buffer trg_ruledict-param for ub.ruledict-param.
define buffer src_rule-by-call for ub.rule-by-call.
define buffer trg_rule-by-call for ub.rule-by-call.
define buffer src_rule-by-profile for ub.rule-by-profile.
define buffer trg_rule-by-profile for ub.rule-by-profile.
define buffer src_rule-call-param for ub.rule-call-param.
define buffer trg_rule-call-param for ub.rule-call-param.
define buffer src_rp-rule-param for ub.rp-rule-param.
define buffer trg_rp-rule-param for ub.rp-rule-param.
main-block:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
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
  if not (src_rule.sts = integer('-1':U)
         or
         src_rule.sts = integer('0':U)) then do:
    undo main-block, return error substitute( "«амен€ющее правило &1 имеет статус &2"
                                             , p-rule-id-2
                                             , entry (lookup (string(src_rule.sts), '-1,-10,0,1,99,98':U), 'готов,нов,исп,удал,удаление,запр.удал':U)).
  end.
  if src_rule.codex_id  <> trg_rule.codex_id then do:
    undo main-block, return error substitute( "«амен€емое правило &1 принадлежит кодексу &2, замен€ющее правило &3 - кодексу &4"
                                             , trg_rule.rule_id
                                             , trg_rule.codex_id
                                             , src_rule.rule_id
                                             , src_rule.codex_id
                                             ).
  end.
  for each trg_rule-by-set no-lock where
          trg_rule-by-set.rule_id = trg_rule.rule_id
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
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
  find first trg_ruledict where
            trg_ruledict.entry-type = 'rule':U
        and trg_ruledict.uniq-key-rec = trg_rule.uniq-key-rec no-error.
  if not available trg_ruledict then do:
    undo main-block, return error substitute( "” замен€емого правила &1 отсутствует прив€зка к словарю правил"
                                            , trg_rule.rule_id
                                            ).
  end.
  find first src_ruledict where
            src_ruledict.entry-type = 'rule':U
        and src_ruledict.uniq-key-rec = src_rule.uniq-key-rec no-error.
  if not available src_ruledict then do:
    undo main-block, return error substitute( "” замен€еющего правила &1 отсутствует прив€зка к словарю правил"
                                            , src_rule.rule_id
                                            ).
  end.
  for each trg_ruledict-param no-lock where
          trg_ruledict-param.entry-id = trg_ruledict.entry-id
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
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
                                              , chr(10)
                                              , v-chr
                                              ).
    end.
  end.
  for each src_ruledict-param no-lock where
          src_ruledict-param.entry-id = src_ruledict.entry-id
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
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
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
    for each trg_rule-call-param where
            trg_rule-call-param.rule_id = trg_rule.rule_id
        and trg_rule-call-param.codex_id = trg_rule-by-call.codex_id
        and trg_rule-call-param.ruleset_id = trg_rule-by-call.ruleset_id
        and trg_rule-call-param.call#_id = trg_rule-by-call.call#_id
        and trg_rule-call-param.order_id = trg_rule-by-call.order_id
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
      assign
      trg_rule-call-param.rule_id = src_rule.rule_id.
    end.
    assign
    trg_rule-by-call.rule_id = src_rule.rule_id
    .
  end.
  for each trg_rule-by-profile where
          trg_rule-by-profile.rule_id = trg_rule.rule_id
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
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
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
    create src_rp-rule-param .
    buffer-copy trg_rp-rule-param except rule_id to src_rp-rule-param
    assign
    src_rp-rule-param.rule_id = src_rule.rule_id
    .
    delete trg_rp-rule-param.
  end.
end.
