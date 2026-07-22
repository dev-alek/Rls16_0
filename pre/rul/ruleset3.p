block-level on error undo, throw.
define input parameter p-silent as logical no-undo .
define input parameter p-rec as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Удаление ruleset".
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
define buffer buf_ruleset  for dictdb.ruleset.
define buffer buf_prop-ruleset  for dictdb.prop-ruleset.
define buffer buf_pscript-ruleset  for dictdb.pscript-ruleset.
define buffer buf_rule  for dictdb.rule.
define buffer buf_rule-by-set  for dictdb.rule-by-set.
define buffer buf_rule-call-param  for dictdb.rule-call-param.
define buffer buf_rule-by-profile  for dictdb.rule-by-profile.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if g#db-num <> 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Данная процедуры не может вызываться в УБД"
    view-as alert-box error .
    undo main-block, return error .
  end.
  find first buf_ruleset exclusive-lock where
        recid(buf_ruleset) = p-rec .
  if buf_ruleset.ruleset_id = 0 then do:
    find first buf_rule no-lock where
              buf_rule.codex_id = buf_ruleset.codex_id no-error .
    if available buf_rule then do:
      v-mess = substitute("К данному ruleset привязано правило &1&2Удаление невозможно"
                          , buf_rule.rule_id
                          , chr(10)
                          ).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
  end.
  find first buf_rule-by-set no-lock where
          buf_rule-by-set.codex_id = buf_ruleset.codex_id
      and buf_rule-by-set.ruleset_id = buf_ruleset.ruleset_id
          no-error .
  if available buf_rule-by-set then do:
  v-mess = substitute("К данному ruleset привязано правило &1&2Удаление невозможно"
                      , buf_rule-by-set.rule_id
                      , chr(10)
                      ).
  run err-mess in this-procedure ( input-output v-mess).
  return error (if p-silent = yes then v-mess else '':U).
  end.
  find first buf_prop-ruleset no-lock where
          buf_prop-ruleset.codex_id = buf_ruleset.codex_id
      and buf_prop-ruleset.ruleset_id = buf_ruleset.ruleset_id no-error .
  if available buf_prop-ruleset then do:
    v-mess = substitute("К данному ruleset привязан объект &1&2Удаление невозможно"
                        , buf_prop-ruleset.dtm-code
                        , chr(10)
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
 find first buf_pscript-ruleset no-lock where
          buf_pscript-ruleset.codex_id = buf_ruleset.codex_id
      and buf_pscript-ruleset.ruleset_id = buf_ruleset.ruleset_id no-error .
  if available buf_pscript-ruleset then do:
    v-mess = substitute("К данному ruleset привязан скрипт &1 для объекта &2&3Удаление невозможно"
                        , buf_pscript-ruleset.script-name
                        , buf_pscript-ruleset.dtm-code
                        , chr(10)
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  find first buf_rule-by-profile no-lock where
            buf_rule-by-profile.codex_id = buf_ruleset.codex_id
       and buf_rule-by-profile.ruleset_id = buf_ruleset.ruleset_id no-error .
  if available buf_rule-by-profile then do:
    v-mess = substitute("К данному ruleset привязано правило &1из профайла &2&3Удаление невозможно"
                        , buf_rule-by-profile.rule_id
                        , buf_rule-by-profile.profile_id
                        , chr(10)
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  find first buf_rule-call-param no-lock where
            buf_rule-call-param.codex_id = buf_ruleset.codex_id
       and buf_rule-call-param.ruleset_id = buf_ruleset.ruleset_id no-error .
  if available buf_rule-call-param then do:
    v-mess = substitute("К данному ruleset привязан параметр вызова из точки &1&4(порядок вызова &2 имя параметра &3)&4Удаление невозможно"
                        , buf_rule-call-param.call_id
                        , buf_rule-call-param.order_id
                        , buf_rule-call-param.param-name
                        , chr(10)
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  delete buf_ruleset.
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Набор/кодекс правил: кодекс &1 набор &2: &3"
                         , buf_ruleset.codex_id
                         , buf_ruleset.ruleset_id
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
