block-level on error undo, throw.
define input parameter p-silent as logical no-undo .
define input parameter p-rec as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Удаление prop-script".
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
define buffer buf_prop-script  for dictdb.prop-script.
define buffer buf_rule-i-script for ub.rule-i-script.
define buffer buf_pscript-ruleset for ub.pscript-ruleset.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_prop-script exclusive-lock where
          recid(buf_prop-script) = p-rec .
  find first buf_rule-i-script no-lock where
            buf_rule-i-script.script-name = buf_prop-script.script-name
        and buf_rule-i-script.dtm-code = buf_prop-script.dtm-code
        and buf_rule-i-script.revis_id = buf_prop-script.revis_id
            no-error.
  if available buf_rule-i-script  then do:
    v-mess = substitute("Невозможно удалить СКРИПТ &1&2" +
               "СКРИПТ привязан к правилу &3"
               , buf_prop-script.script-name
               , chr(10)
               , buf_rule-i-script.root_rule_id
               ).
   run err-mess in this-procedure ( input-output v-mess) .
   undo, return error (if p-silent = yes then v-mess else '':U).
  end.
  find first buf_pscript-ruleset no-lock where
            buf_pscript-ruleset.dtm-code = buf_prop-script.dtm-code
        and buf_pscript-ruleset.language = buf_prop-script.language
        and buf_pscript-ruleset.script-name = buf_prop-script.script-name
        and buf_pscript-ruleset.revis_id = buf_prop-script.revis_id  no-error.
  if available buf_pscript-ruleset  then do:
    v-mess = substitute("Невозможно удалить СКРИПТ &1&2" +
               "СКРИПТ привязан к своду правил &3 кодекс &4"
               , buf_prop-script.script-name
               , chr(10)
               , buf_pscript-ruleset.ruleset_id
               , buf_pscript-ruleset.codex_id).
   run err-mess in this-procedure ( input-output v-mess) .
   undo, return error (if p-silent = yes then v-mess else '':U).
  end.
  for each buf_ruledict where
          buf_ruledict.uniq-key-rec = buf_prop-script.uniq-key-rec
  on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
   for each buf_ruledict-param where
           buf_ruledict-param.entry-id = buf_ruledict.entry-id
   on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
      delete buf_ruledict-param.
   end.
   delete buf_Ruledict.
  end.
  delete buf_prop-script no-error.
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
      p-mess = substitute("Скрипт: код объекта &1 язык &2 скрипт &3 версия &4:&5&6"
                         , buf_prop-script.dtm-code
                         , buf_prop-script.language
                         , buf_prop-script.script-name
                         , buf_prop-script.revis_id
                         , chr(10)
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
