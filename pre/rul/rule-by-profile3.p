block-level on error undo, throw.
define input parameter p-silent as logical no-undo .
define input parameter p-rec as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Удаление rule-by-profile".
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
define buffer buf_rule-by-profile  for dictdb.rule-by-profile.
define buffer buf_rule  for ub.rule.
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_rp-rule-param for ub.rp-rule-param.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_rule-by-profile exclusive-lock where
          recid(buf_rule-by-profile) = p-rec .
  find first buf_rp-by-call where
           buf_rp-by-call.profile_id = buf_rule-by-profile.profile_id no-error.
  if available buf_rp-by-call then do:
    v-mess = substitute("Есть привязки к профайлу &1 (&2) удаление запрещено"
                        , buf_rp-by-call.profile_id
                        , buf_rp-by-call.call_id).
   run err-mess in this-procedure ( input-output v-mess) .
   undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
  find first buf_rule no-lock where
            buf_rule.rule_id = buf_rule-by-profile.rule_id no-error.
  if available buf_rule then do:
    find  current buf_rule exclusive-lock .
  end.
  for each buf_rp-rule-param where
          buf_rp-rule-param.profile_id = buf_rule-by-profile.profile_id
          and buf_rp-rule-param.codex_id = buf_rule-by-profile.codex_id
          and buf_rp-rule-param.ruleset_id = buf_rule-by-profile.ruleset_id
          and buf_rp-rule-param.rp_order_id = buf_rule-by-profile.rp_order_id
          and buf_rp-rule-param.rule_id = buf_rule-by-profile.rule_id
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    delete buf_rp-rule-param.
  end.
  delete buf_rule-by-profile no-error.
  if error-status:error then do:
    v-mess = substitute("Ошибка при удалении: &1&2&3"
                         , error-status:get-message(1)
                         , chr(10)
                         , return-value ).
   run err-mess in this-procedure ( input-output v-mess) .
   undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
  if available buf_rule then do:
    define variable v-ok as logical no-undo .
    run trg/rule-chk.p ( input 'удаление':U
                        ,input buf_rule.rule_id
                        ,output v-ok
                        ,output v-mess
                        ) no-error.
    if not error-status:error
    and not v-ok then do:
      if buf_rule.sts <> integer('-1':U) then do:
        buf_rule.sts = integer('-1':U).
      end.
    end.
  end.
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Привязка правила к профайлу:&1профайл &2 кодекс &3 набор &4 порядок вызова &5 № правила &6:&1&6"
                         , chr(10)
                         , buf_rule-by-profile.profile_id
                         , buf_rule-by-profile.codex_id
                         , buf_rule-by-profile.ruleset_id
                         , buf_rule-by-profile.rule_id
                         , buf_rule-by-profile.rp_order_id
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
