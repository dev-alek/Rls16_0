block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: layout3.p $
$Archive: adm/layout3.p $

Удаление раскладки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/30/08
Author: Bakhtadze Natalya
Creation date: 09/30/08

*/

define input parameter p-silent as logical no-undo .
define input parameter p-rec as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: layout3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/layout3.p $":U .
define variable vss-description as character no-undo init "Удаление раскладки".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/get-regf.i }
{ trg/layouth.i }
{ adm/layoutus.i }

define variable v-mess as character no-undo .
define variable v-chip-num as integer no-undo .
define variable v-is-used as logical no-undo .
define buffer buf_layout  for ub.layout.
define buffer buf_layout-elem-rule  for ub.layout-elem-rule.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_rule-by-call for ub.rule-by-call.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_layout exclusive-lock where
          recid(buf_layout) = p-rec .
  if buf_layout.is-default = integer({&layout-default})
  or buf_layout.is-default = integer({&layout-mandatory})
  then do:
    if g#db-num > 0 then do:
     v-mess = substitute("Нельзя удалять ШАБЛОН раскладки и ОБЯЗАТЕЛЬНУЮ РАСКЛАДКУ в УБД"
                          , buf_layout.layout-id ).
      run err-mess in this-procedure ( input-output v-mess) .
      undo main-block, return error (if p-silent = yes then v-mess else '':U).

    end.
  end.
  v-is-used = yes.
  run  layoutus_is-used in this-procedure (
                                            input buf_layout.layout-type
                                           ,input buf_layout.layout-id
                                           ,output v-is-used
                                           ,output v-mess) no-error .
  if error-status:error
  or v-is-used then do:
    run err-mess in this-procedure ( input-output v-mess) .
    undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
  run  layouth_create-layout_h  in this-procedure (
                                                  input {&deletion}
                                                 ,input buf_layout.layout-id
                                                 ,buffer buf_layout
                                                 ,output v-chip-num).

  for each buf_layout-elem-rule where
          buf_layout-elem-rule.layout-id  = buf_layout.layout-id
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    for each buf_rule-call-param where
            buf_rule-call-param.call_id  = buf_layout-elem-rule.uniq-key-rec
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      run  layouth_create-rule-call-param_h  in this-procedure (
                                                      input {&deletion}
                                                    ,input buf_rule-call-param.call#_id
                                                    ,input buf_rule-call-param.codex_id
                                                    ,input buf_rule-call-param.ruleset_id
                                                    ,input buf_rule-call-param.order_id
                                                    ,input buf_rule-call-param.param-name
                                                    ,input buf_rule-call-param.p-index
                                                    ,input buf_rule-call-param.call_id
                                                    ,buffer buf_rule-call-param
                                                    ,input v-chip-num).
      delete buf_rule-call-param.
    end.
    for each buf_rule-by-call where
            buf_rule-by-call.call_id  = buf_layout-elem-rule.uniq-key-rec
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      delete buf_rule-by-call.
    end.
    run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                    input {&deletion}
                                                  ,input buf_layout-elem-rule.layout-id
                                                  ,input buf_layout-elem-rule.mode-id
                                                  ,input buf_layout-elem-rule.widget-id
                                                  ,buffer buf_layout-elem-rule
                                                  ,input v-chip-num).
    delete buf_layout-elem-rule.
  end.
  delete buf_layout no-error.
  if error-status:error then do:
    v-mess = substitute("Ошибка при удалении: &1&2&3"
                         , error-status:get-message(1)
                         , {&new-line}
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
      p-mess = substitute("Раскладка &1: &2"
                         , buf_layout.layout-id
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