block-level on error undo, throw.
define input parameter p-silent as logical no-undo .
define input parameter p-rec as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Удаление rule".
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
define variable v-mess as character no-undo .
define buffer buf_rule  for ub.rule.
define buffer buf2_rule  for ub.rule.
define buffer buf_rule-by-profile  for ub.rule-by-profile.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_rule-script for ub.rule-script.
define buffer buf_rule-i-script for ub.rule-i-script.
define buffer buf_rule-by-call  for ub.rule-by-call.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_rule exclusive-lock where
          recid(buf_rule) = p-rec .
  if buf_rule.sts = integer('99':U)
  or buf_rule.sts = integer('98':U)
  or buf_rule.sts = integer('0':U)
  then do:
    assign
    v-mess = substitute("Правило находится в статусе &1, удаление невозможно", entry (lookup (string(buf_rule.sts), '-1,-10,0,1,99,98':U), 'готов,нов,исп,удал,удаление,запр.удал':U)).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  find first buf_rule-by-call no-lock where
            buf_rule-by-call.rule_id = buf_rule.rule_id no-error.
  if available buf_rule-by-call then do:
    v-mess = substitute("Нельзя удалить правило - правило вызывается:&1" +
                        "Точка вызова &2(&3), кодекс &4, набор правил &5"
                       , chr(10)
                       , buf_rule-by-call.call#_id
                       , buf_rule-by-call.call_id
                       , buf_rule-by-call.codex_id
                       , buf_rule-by-call.ruleset_id
                       ).
   run err-mess in this-procedure ( input-output v-mess) .
   undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
  find first buf_rule-by-profile no-lock where
            buf_rule-by-profile.rule_id = buf_rule.rule_id no-error.
  if available buf_rule-by-profile then do:
    v-mess = substitute("Нельзя удалить правило - есть привязанный профайл &1"
                       , buf_rule-by-profile.profile_id ).
   run err-mess in this-procedure ( input-output v-mess) .
   undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
  for each buf_ruledict where
        buf_ruledict.entry-type = 'rule':U
    and buf_ruledict.uniq-key-rec = buf_rule.uniq-key-rec
  on error undo main-block, return error:
    for each buf_ruledict-param where
          buf_ruledict-param.entry-id = buf_ruledict.entry-id
    on error undo main-block, return error:
      delete buf_ruledict-param.
    end.
    delete buf_ruledict.
  end.
  for each buf2_rule where
        buf2_rule.upper_rule_id = buf_rule.rule_id
  on error undo main-block, return error :
     delete buf2_rule.
  end.
  for each buf_rule-script where
        buf_rule-script.rule_id = buf_rule.rule_id
  on error undo main-block, return error :
     delete buf_rule-script.
  end.
  for each buf_rule-i-script where
        buf_rule-i-script.root_rule_id = buf_rule.rule_id
  on error undo main-block, return error :
     delete buf_rule-i-script.
  end.
  delete buf_rule no-error.
  if error-status:error then do:
    v-mess = substitute("Ошибка при удалении: &1&2&3"
                         , error-status:get-message(1)
                         , chr(10)
                         , return-value ).
   run err-mess in this-procedure ( input-output v-mess) .
   undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Правило &1: &2"
                         , buf_rule.rule_id
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
