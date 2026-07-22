/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/24/07
Author: Bakhtadze Natalya
Creation date: 04/24/07


*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*---------------------------------------------start-of saledc-----------------------------------------*/

&if "{1}" = "saledc" &then
find first buf_temp-pers-proc where
          buf_temp-pers-proc.proc-name = v-proc-name no-error.
if not available buf_temp-pers-proc then do:
  v-proc-handle = ?.
  /* run rules.p*/
  run value(v-proc-name) persistent set v-proc-handle (
                                                        input parparentproc
                                                      ,input this-procedure:handle
                                                      ,input p-log-handle
                                                      ,input v-cont-handle
                                                      ,input v-codex-id
                                                      ,input v-ruleset-id
                                                      ,input buf_rule-by-call.call_id
                                                      ,input buf_rule-by-call.order_id
                                                      ,input buf_rule-by-call.rule_id
                                                      ,input buf_rule-by-call.profile
                                                      ,input buf_rule-by-call.is_dynamic
                                                      ,input p-doc-type
                                                      ,input v-host-code
                                                      ,input v-obj-type
                                                      ,input v-obj-code
                                                      ,input v-doc-code
                                                      ,input v-doc-date
                                                      ,input v-fact-date
                                                      ,input v-save-int
                                                      ,input v-curr-r-b
                                                      ,input v-cmd-proc-handle
                                                      ,input buf_temp-cmd.cmd-code
                                                      ,input table temp-d-card
                                                      ) no-error .
  if error-status:error then do:
    if p-save then  do:
      delete procedure v-cmd-proc-handle .
    end.
    undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  run perproc-create-proc in this-procedure (
                                              input  this-procedure:handle
                                              ,input  v-proc-name /*p-proc-name*/
                                              ,input  v-proc-handle
                                              ,input  no /*p-run*/
                                              ,input  '':U /*v-parameter*/
                                              ,input  g#userid
                                              ,input (if buf_rule-by-call.is_dynamic = no
                                                      then 999999999
                                                      else 0) /*p-rank-to-delete*/
                                              ,output v-id ) no-error.
  if error-status:error then do:
    if return-value = '>':U
    then do:
      run perproc-delete-by-rank in this-procedure .
      run perproc-create-proc in this-procedure (
                                                  input  this-procedure:handle
                                                  ,input  ("rul/" + string(buf_rule-by-call.rule_id, '999999999') + '.p') /*p-proc-name*/
                                                  ,input  v-proc-handle
                                                  ,input  no /*p-run*/
                                                  ,input  '':U /*v-parameter*/
                                                  ,input  g#userid
                                                  ,input (if buf_rule-by-call.is_dynamic = no
                                                          then 999999999
                                                          else 0) /*p-rank-to-delete*/
                                                  ,output v-id ) .
    end. /* = '>'*/
    else do:
      if p-save then  do:
        delete procedure v-cmd-proc-handle .
      end.
      undo _main, return error substitute("&1&2Ошибка при вызове обработки ДК типа &3 эмитент &4"
                                          ,vss-workfile
                                          ,{&new-line}
                                          ,temp-d-card.type
                                          ,temp-d-card.emitent-host-code).
    end.
  end.
  find first buf_temp-pers-proc where
            buf_temp-pers-proc.id = v-id .
  assign
  buf_temp-pers-proc.rank-to-delete = buf_temp-pers-proc.rank-to-delete + 1
  .
end. /*if not available buf_temp-pers-proc*/
else do:
  assign
  buf_temp-pers-proc.rank-to-delete = buf_temp-pers-proc.rank-to-delete + 1
  .
end.
/*обработка всех карт одного типа и эмитента по данной продаже и данному правилу*/
run proc-main in buf_temp-pers-proc.vproc-handle (
                                                    input temp-d-card.type
                                                  ,input temp-d-card.emitent-host-code
                                                  ) no-error .
if error-status:error then do:
  if p-save then  do:
    delete procedure v-cmd-proc-handle .
  end.
  undo _main, return error substitute("&1&2Ошибка при обработке ДК типа &3 эмитент &4&2" +
                                      "&5&2&6"
                                      ,vss-workfile
                                      ,{&new-line}
                                      ,temp-d-card.type
                                      ,temp-d-card.emitent-host-code
                                      , error-status:get-message(1)
                                      , return-value
                                        ).
end. /*if error-status:error then do:*/

&endif

/*---------------------------------------------end-of saledc-----------------------------------------*/


/*---------------------------------------------start-of cmdp-dc-----------------------------------------*/

&if "{1}" = "cmdp-dc" &then
find first buf_temp-pers-proc where
          buf_temp-pers-proc.proc-name = v-proc-name no-error.
if not available buf_temp-pers-proc then do:
  v-proc-handle = ?.
  run value(v-proc-name) persistent set v-proc-handle (
                                                        input parparentproc
                                                      ,input this-procedure:handle
                                                      ,input p-log-handle
                                                      ,input ? /*p-cont-handle*/
                                                      ,input v-codex_id
                                                      ,input v-ruleset_id
                                                      ,input buf_rule-by-call.call_id
                                                      ,input buf_rule-by-call.order_id
                                                      ,input buf_rule-by-call.rule_id
                                                      ,input buf_rule-by-call.profile
                                                      ,input buf_rule-by-call.is_dynamic
                                                      ,input v-doc-type
                                                      ,input v-host-code
                                                      ,input p-obj-type
                                                      ,input p-obj-code
                                                      ,input v-doc-code
                                                      ,input p-doc-date
                                                      ,input p-fact-date
                                                      ,input 0 /*p-save*/
                                                      ,input v-curr-r-b
                                                      ,input v-cmd-proc-handle
                                                      ,input buf_temp-cmd.cmd-code
                                                      ,input table temp-d-card
                                                      ) no-error .
  if error-status:error then do:
    delete procedure v-cmd-proc-handle .
    undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end. /*error-status:error then do:*/

  run perproc-create-proc in this-procedure (
                                              input  this-procedure:handle
                                              ,input  v-proc-name /*p-proc-name*/
                                              ,input  v-proc-handle
                                              ,input  no /*p-run*/
                                              ,input  '':U /*v-parameter*/
                                              ,input  g#userid
                                              ,input (if buf_rule-by-call.is_dynamic
                                                      then 999999999
                                                      else 0) /*p-rank-to-delete*/
                                              ,output v-id ) no-error.
  if error-status:error then do:
    if return-value = '>':U
    then do:
      run perproc-delete-by-rank in this-procedure .
      run perproc-create-proc in this-procedure (
                                                  input  this-procedure:handle
                                                  ,input  ("rul/" + string(buf_rule-by-call.rule_id, '999999999') + '.p') /*p-proc-name*/
                                                  ,input  v-proc-handle
                                                  ,input  no /*p-run*/
                                                  ,input  '':U /*v-parameter*/
                                                  ,input  g#userid
                                                  ,input (if buf_rule-by-call.is_dynamic
                                                          then 999999999
                                                          else 0) /*p-rank-to-delete*/
                                                  ,output v-id ) .
    end. /* = '>'*/
    else do:
      delete procedure v-cmd-proc-handle .
      undo _main, return error substitute("&1&2Ошибка при вызове обработки ДК типа &3 эмитент &4"
                                          ,vss-workfile
                                          ,{&new-line}
                                          ,v-type
                                          ,v-emitent-host-code).
    end.
  end. /*if error-status:error then do:*/
  find first buf_temp-pers-proc where
            buf_temp-pers-proc.id = v-id .
  assign
  buf_temp-pers-proc.rank-to-delete = buf_temp-pers-proc.rank-to-delete + 1
  .
end. /*if not available buf_temp-pers-proc*/
else do:
  assign
  buf_temp-pers-proc.rank-to-delete = buf_temp-pers-proc.rank-to-delete + 1
  .
end.
/*обработка всех карт одного типа и эмитента по данной продаже и данному правилу*/
run proc-main in buf_temp-pers-proc.vproc-handle (
                                                  input v-type
                                                  ,input v-emitent-host-code
                                                  ) no-error .
if error-status:error then do:
  delete procedure v-cmd-proc-handle .
  undo _main, return error substitute("&1&2Ошибка при вызове обработке ДК типа &3 эмитент &4"
                                        ,vss-workfile
                                        ,{&new-line}
                                        ,v-type
                                        ,v-emitent-host-code).
end. /*if error-status:error then do:*/
&endif

/*---------------------------------------------end-of cmdp-dc-----------------------------------------*/