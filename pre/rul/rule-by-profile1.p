block-level on error undo, throw.
define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-profile-id as integer no-undo .
define input parameter        p-codex-id as integer no-undo .
define input parameter        p-ruleset-id as integer no-undo .
define input parameter        p-rule-id as integer no-undo .
define input parameter        p-is-dynamic as logical no-undo .
define input parameter        p-dflt-can-calc as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение привязки rule к profile".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable v-mess as character no-undo .
define variable v-entry as character no-undo .
define buffer buf_ruleset for ub.ruleset.
define buffer buf_rule-by-profile for ub.rule-by-profile.
define buffer buf_rule for ub.rule.
define buffer buf_rule-profile for ub.rule-profile.
define buffer buf_rule-by-set for ub.rule-by-set.
define buffer last_rule-by-profile for ub.rule-by-profile.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_rp-rule-param for ub.rp-rule-param.
if p-mode <> 'ДОБАВЛЕНИЕ':U
and p-mode <> 'ИЗМЕНЕНИЕ':U
then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.
_main:
do for buf_ruleset
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_ruleset no-lock where
            buf_ruleset.codex_id = p-codex-id
        and buf_ruleset.ruleset_id = p-ruleset-id no-error.
  if not available buf_ruleset then do:
    assign
    v-mess = "Не найден набор правил".
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  find first buf_rule no-lock where
            buf_rule.rule_id = p-rule-id no-error.
  if not available buf_rule then do:
    assign
    v-mess = "Не найдено правило c таким №".
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  find first buf_rule share-lock where
            buf_rule.rule_id = p-rule-id no-error.
  if buf_rule.sts = integer('-10':U)
  or buf_rule.sts = integer('1':U)
  or buf_rule.sts = integer('99':U)
  or buf_rule.sts = integer('98':U) then do:
    assign
    v-mess = substitute("Правило находится в статусе &1", entry (lookup (string( buf_rule.sts), '-1,-10,0,1,99,98':U), 'готов,нов,исп,удал,удаление,запр.удал':U)).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'sts':U).
  end.
  find first buf_rule-profile no-lock where
            buf_rule-profile.profile_id = p-profile-id no-error.
  if not available buf_rule then do:
    assign
    v-mess = "Не найден профайл c таким №".
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  find first buf_rule-by-set no-lock where
            buf_rule-by-set.codex_id = p-codex-id
        and  buf_rule-by-set.ruleset_id = p-ruleset-id
        and  buf_rule-by-set.rule_id = p-rule-id no-error.
  if not available buf_rule-by-set then do:
    assign
    v-mess = substitute("Правило с № &1 не привязано к набору правил &2 кодекс &3"
                        , p-rule-id
                        , p-ruleset-id
                        , p-codex-id).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    find last last_rule-by-profile no-lock where
            last_rule-by-profile.profile_id = p-profile-id
        and last_rule-by-profile.codex_id = p-codex-id
        and last_rule-by-profile.ruleset_id = p-ruleset-id  no-error.
    create buf_rule-by-profile.
    assign
    buf_rule-by-profile.codex_id = p-codex-id
    buf_rule-by-profile.ruleset_id = p-ruleset-id
    buf_rule-by-profile.rule_id = p-rule-id
    buf_rule-by-profile.profile_id = p-profile-id
    buf_rule-by-profile.rp_order_id = ( if available last_rule-by-profile
                                     then last_rule-by-profile.rp_order_id + 1
                                     else 0)
    buf_rule-by-profile.is_dynamic = p-is-dynamic
    buf_rule-by-profile.dflt-can-calc = p-dflt-can-calc
    p-rec = recid(buf_rule-by-profile)
    .
    if buf_rule.sts <> integer('0':U) then do:
      buf_rule.sts = integer('0':U).
    end.
  end.
  else do:
    find first buf_rule-by-profile exclusive-lock where
              recid(buf_rule-by-profile) = p-rec .
    assign
    buf_rule-by-profile.is_dynamic = p-is-dynamic
    buf_rule-by-profile.dflt-can-calc = p-dflt-can-calc
    .
  end.
  find first buf_ruledict where
            buf_ruledict.entry-type = 'rule':U
        and buf_ruledict.uniq-key-rec = buf_rule.uniq-key-rec.
  for each buf_ruledict-param where
          buf_ruledict-param.entry-id = buf_ruledict.entry-id
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_rp-rule-param where
              buf_rp-rule-param.profile_id = buf_rule-profile.profile_id
          and buf_rp-rule-param.codex_id = buf_rule-by-profile.codex_id
          and buf_rp-rule-param.ruleset_id = buf_rule-by-profile.ruleset_id
          and buf_rp-rule-param.rp_order_id = buf_rule-by-profile.rp_order_id
          and buf_rp-rule-param.rule_id = buf_rule-by-profile.rule_id
          and buf_rp-rule-param.rule-param-name = buf_ruledict-param.param-name no-error .
    if not available buf_rp-rule-param then do:
      create buf_rp-rule-param.
      assign
      buf_rp-rule-param.profile_id = buf_rule-profile.profile_id
      buf_rp-rule-param.codex_id = buf_rule-by-profile.codex_id
      buf_rp-rule-param.ruleset_id = buf_rule-by-profile.ruleset_id
      buf_rp-rule-param.rp_order_id = buf_rule-by-profile.rp_order_id
      buf_rp-rule-param.rule_id = buf_rule-by-profile.rule_id
      buf_rp-rule-param.rule-param-name = buf_ruledict-param.param-name
      .
    end.
  end.
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Привязка правила к профайлу:&1профайл &2 кодекс &3 набор &4 правило &5"
                         , chr(10)
                         , p-profile-id
                         , p-codex-id
                         , p-ruleset-id
                         , p-rule-id
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
