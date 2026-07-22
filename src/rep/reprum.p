block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: reprum.p $
$Archive: rep/reprum.p $

Вызов процедур RUM для обработки отчетов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/17/09
Author: Bakhtadze Natalya
Creation date: 06/17/09

*/

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-parent-handle as handle no-undo .
define input  parameter p-log-handle  as handle no-undo .
define input  parameter p-process    as character no-undo .
define input  parameter p-profile-id as integer   no-undo .
define input  parameter p-codex-id as integer   no-undo .
define input  parameter p-ruleset-id as integer   no-undo .
define input  parameter p-once-more as integer no-undo .
define input  parameter p-db-num like ub.db.db-num no-undo .
define input  parameter p-uniq-key-rec as character no-undo .
define input  parameter p-doc-code as character no-undo .
define input  parameter p-save        as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: reprum.p $":u .
define variable vss-archive     as character no-undo init "$Archive: rep/reprum.p $":u .
define variable vss-description as character no-undo init "Вызов процедур RUM для обработки отчетов" .
{ cmp/vssrevis.i "substitute('&1|&2|&3':u
                              ,p-process
                              ,p-db-num
                              ,p-doc-code
                              )" }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }
{ gbl/perproc.i " " 100 }
{ nws/lib-nws.i }
{ gbl/key-rec.i }
{ gbl/cur-time.i  }
{ rul/cl-hist.i "new shared" }
{ rul/calldscr.i }
{ rul/xmlischn.i "new shared" }
{ rul/ruleset_.i }
{ cmp/ini-lib.i }
{ gbl/fileslsh.i }

define variable v-stop-leave-status as character no-undo .
define variable v-cmd-code as integer no-undo .
define variable v-cmd-proc-handle as handle no-undo .
define variable v-command  as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-host-code as integer   no-undo .
define variable v-base-code as integer   no-undo .
define variable v-doc-date as date no-undo .
define variable v-fact-date as date no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-id as integer no-undo .
define variable v-proc-handle as handle no-undo .
define variable v-proc-name as character no-undo .
define variable v-ruleset-id as integer no-undo .
define variable v-ruleset-id-list as character no-undo extent 3.
define variable v-codex-id as integer no-undo .
define variable v-codex-in-db as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable sign as integer no-undo .
define variable v-codex-id-list as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-calc-chr as character no-undo .
define variable v-can-run as logical no-undo .
define variable v-doc-code as character no-undo .
define variable v-doc-type as character no-undo .
define variable v-dirs0 as character no-undo .
define variable v-dirs as character no-undo .
define variable v-process-dir-name as character no-undo .
define variable v-profile-id as integer no-undo .
define variable log-file-name as character no-undo init "calc-rep.log".
define variable v-save-int as integer no-undo .
define variable v-charkey_one as character no-undo .
define variable v-charkey_one-2 as character no-undo .
define variable v-num-dc as integer no-undo .
define variable v-is-empty as logical no-undo .
define variable v-rec-ord_ as integer no-undo .
define variable v-param-name as character no-undo .
define variable v-xsd-file as character no-undo .
define variable v-task-num as integer no-undo .
define variable v-batch-dir-1 as character no-undo .
define variable v-batch-dir-2 as character no-undo .
define variable v-container-params as logical no-undo .
define variable v-found as logical no-undo .
define temp-table tt0-rp-by-call no-undo like ub.rp-by-call.
define temp-table tt0-rule-by-call no-undo like ub.rule-by-call.
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define temp-table tt0-rule-call-param no-undo like ub.rule-call-param.
{ rul/rcps-run.i cb_ }


/*
возможные значения v-save-int
*/

define variable v-cont-handle as handle no-undo .
&scop cmd-proc-handle v-cmd-proc-handle
&scop cmd-code buf_temp-cmd.cmd-code


&scop sign sign *

define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_temp-pers-proc  for temp-pers-proc.
define buffer buf_db for ub.db.
define buffer buf_sysconf for ub.sysconf.

{ nws/temp-cmd.i "NEW SHARED" }

define buffer buf_temp-cmd  for temp-cmd.
define buffer buf1_temp-cmd  for temp-cmd.
define buffer buf_temp-smart-route  for temp-smart-route.
define buffer buf_temp-smart-link  for temp-smart-link.
define buffer buf_temp-nws-outline for temp-nws-outline.
define buffer buf_temp-no-route for temp-no-route.

&scop run-persistent no


&scop display-message    if log-file-name <> '':U then run write-log-and-file in p-log-handle (  ~
    input 1                                                      ~
  , input log-file-name                                          ~
  , input 1                                                      ~
  , input ~{&my-message~})
if transaction
and (p-process =  {&rep-proc_rep-batchwork}
    )
then do:
  message
    vss-workfile vss-revision vss-description skip
    substitute("Вызов процедуры в действующей транзакции недопустим") skip
    view-as alert-box error .
  return error substitute( "&1. Вызов процедуры в действующей транзакции недопустим", vss-workfile ) .
end.


_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

  { gbl/curr-r-b.i
    v-curr-r-b
  }
  if not p-save

        then do:
    message
    substitute("Неверное значение параметра p-save = &1,&2" +
               "в ситуации когда p-process = &3"
               , p-save
               , {&new-line}
               , p-process)
    view-as alert-box error .
    undo _main, return error .
  end.
  v-save-int = (if p-save
                then 0
                else -1).
  CASE p-process:
    when {&rep-proc_rep-batchwork}
    then do:
      if not g#auto then do:
        { gbl/getcntxt.i get }
      end.
      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      v-obj-type = v-cntxt-obj-type
      v-obj-code = v-cntxt-obj-code
      v-host-code = v-cntxt-host-code-obj
      v-doc-date = v-today
      v-fact-date = v-today
      v-doc-code = entry(1, p-doc-code, {&delim-par}) /*виртуальный код док-та */
      v-task-num = integer(entry(2, p-doc-code, {&delim-par})) /*код строки расписания*/
      v-dirs0 =  entry(3, p-doc-code, {&delim-par}) /* имя директории*/
      v-profile-id = p-profile-id
      .
      assign
      v-codex-id-list = string(p-codex-id)
      v-ruleset-id-list[1] = string({&rep-proc_22_batchwork_3}) + {&comma-char} +
                              string({&rep-proc_22_batchwork_1}) + {&comma-char} +
                              string({&rep-proc_22_batchwork_2}) + {&comma-char} +
                              string({&rep-proc_22_batchwork_4})
     /*действия до расчет отчет - пересылка в  действия после*/
      v-ruleset-id-list[2] = ''
      v-cont-handle = this-procedure:handle
      .
      run verify-write-to-dir in this-procedure ( input v-dirs0
                                                  ,output v-dirs) no-error.
      if error-status:error then do:
        undo _main, return error .
        end.
        end.
    when {&rep-proc_rep-close-shift}
    then do:
      if not g#auto then do:
        { gbl/getcntxt.i get }
      end.
      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      v-obj-type = v-cntxt-obj-type
      v-obj-code = v-cntxt-obj-code
      v-host-code = v-cntxt-host-code-obj
      v-doc-date = v-today
      v-fact-date = v-today
      v-doc-code = entry(1, p-doc-code, {&delim-par}) /*uniq-key-rec смены*/
      v-profile-id = p-profile-id
      .
      run get-batch-rep-dir in this-procedure ( input-output v-batch-dir-1
                                              ,input-output v-batch-dir-2
                                              ,input yes) no-error.
        if error-status:error then do:
          undo _main, return error .
        end.
      assign
      v-dirs0 =  v-batch-dir-1 + "|" + v-batch-dir-2
      .
      assign
      v-codex-id-list = string(p-codex-id)
      v-ruleset-id-list[1] = string({&rep-proc_22_close-shift_5}) + {&comma-char} +
                             string({&rep-proc_22_print-report_6})
      v-ruleset-id-list[2] = ''
      v-cont-handle = this-procedure:handle
      .
      run verify-write-to-dir in this-procedure ( input v-dirs0
                                                  ,output v-dirs) no-error.
      if error-status:error then do:
        undo _main, return error .
      end.
    end.
    otherwise do:
      undo _main, return error substitute("&1 &2 &3&4Ошибка входных параметров процедуры reprum.p&4Невернoе значение p-process = &5"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,{&new-line}
                                          ,p-process
                                           ).
    end.
  END CASE.
  run init-rule-call-params in this-procedure (input p-uniq-key-rec).
  _codex:
  do v-jj = 1 to num-entries(v-codex-id-list):
    if entry(v-jj, v-codex-id-list) = '':U then next _codex.
    v-codex-id = integer(entry(v-jj, v-codex-id-list)).
    do v-ii = 1 to num-entries(v-ruleset-id-list[v-jj]):
        if entry(v-ii, v-ruleset-id-list[v-jj]) = '':U then next.
        v-ruleset-id = integer(entry(v-ii, v-ruleset-id-list[v-jj])).
      _rule-by-call:
      for each buf_rule-by-call no-lock where
                buf_rule-by-call.call_id = p-uniq-key-rec
          and buf_rule-by-call.can-calc = yes
          and buf_rule-by-call.codex_id = v-codex-id
          and buf_rule-by-call.ruleset_id = v-ruleset-id
      by buf_rule-by-call.call_Id
      by buf_rule-by-call.codex_id
      by buf_rule-by-call.ruleset_id
      by buf_rule-by-call.order_id
      on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ) :
        v-proc-name = "rul/" + string(buf_rule-by-call.rule_id, '999999999') + '.p'.
          run write-log  in p-log-handle (
                                          input 0
                                        , "&DLine").
          &scop my-message substitute("...(&2) &1", buf_rule-by-call.algo-des, buf_rule-by-call.rule_id)
          {&display-message}.
        v-found = yes.
        run value(v-proc-name)  (
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
                                                            ,input v-doc-type
                                                            ,input v-host-code
                                                            ,input v-obj-type
                                                            ,input v-obj-code
                                                            ,input v-doc-code
                                                            ,input v-dirs
                                                            ,input v-save-int
                                                            ,input v-curr-r-b
                                                            ,input v-cmd-proc-handle
                                                            ,input 0 /*temp-cmd.cmd-code пока*/
                                                            ) no-error .
        /*иногада для  отчетов все равно*/
        if error-status:error
        then do:
          case v-ruleset-id:
            when integer({&rep-proc_22_batchwork_3}) then do:
            undo _rule-by-call, return error substitute("&1&2Ошибка при обработке отчетов&2" +
                                              "&3&2&4"
                                              ,vss-workfile
                                              ,{&new-line}
                                              , error-status:get-message(1)
                                              , return-value
                                                ).
          end.
            when integer({&rep-proc_22_close-shift_5}) then do:
            end.
            when integer({&rep-proc_22_print-report_6}) then do:
               /*пропускаем*/
            end.
            otherwise do:
           return error substitute("&1&2Ошибка при обработке отчетов&2" +
                                              "&3&2&4"
                                              ,vss-workfile
                                              ,{&new-line}
                                              , error-status:get-message(1)
                                              , return-value
                                                ).
          end.
          end case.
        end. /*if error-status:error then do:*/
        if not error-status:error then do:
          if v-ruleset-id = integer({&rep-proc_22_batchwork_1})
          then do:
            run write-log  in p-log-handle (
                                            input 0
                                          , "&DLine").
            &scop my-message substitute("...(&1) - Закончен", buf_rule-by-call.rule_id)
            {&display-message}.
          end.
        end.
        if v-stop-leave-status > '' then do:
          undo _main, return error substitute("&1&2Процесс обработки отчетов&2" +
                                              "&3&2&4"
                                              ,vss-workfile
                                              ,{&new-line}
                                              , error-status:get-message(1)
                                              , return-value
                                                ).
        end.
      end. /*for each buf_rule-by-call no-lock where*/
    end. /*do v-ii = 1 to */
  end. /*do v-jj*/
  run update-rule-call-params in this-procedure ( input {&rep}
                                                 ,input p-uniq-key-rec ).
 if not v-found then do:
   return "return".
 end.
end. /*_main*/


procedure set-num-rec :
/*не удалять вызываются через callback*/
define input parameter p-num-rec as integer no-undo .
define input parameter p-num-rec-calc-err as integer no-undo .
define input parameter p-num-rec-value-err as integer no-undo .
define input parameter p-num-rec-ok as integer no-undo .
define input parameter p-display as logical no-undo .

define variable v-ok as logical no-undo .

do
on error undo, return error
:
  if not (p-process = {&dct-proc_batch-card-recalc}) then do:
    return.
  end.
  run set-num-rec in p-parent-handle ( input p-num-rec
                                      ,input p-num-rec-calc-err
                                      ,input p-num-rec-value-err
                                      ,input p-num-rec-ok
                                      ,buffer buf_rule-by-call
                                      ,input p-display
                                      ).
end. /*doe*/

end procedure. /* set-num-rec */



procedure set-stop-leave-status :
/*не удалять вызываются через callback*/
define input parameter p-stop-leave-status as character no-undo .

do
on error undo, return error
:
  assign
  v-stop-leave-status = p-stop-leave-status.
end.

end procedure. /* set-stop-leave-status */

procedure cb_get-rule-call-params :
define input parameter p-call-handle as handle no-undo .
define buffer buf_temp-rule-call-param for temp-rule-call-param.

do
on error undo, return error
:
  for each buf_temp-rule-call-param no-lock:
    /*if buf_temp-rule-call-param.param-mode = {&script-parmode-output} then do:*/
      run cb_rcps-run_set-value in p-call-handle (
                                                 input buf_temp-rule-call-param.call_id
                                                ,input buf_temp-rule-call-param.codex_id
                                                ,input buf_temp-rule-call-param.ruleset_id
                                                ,input buf_temp-rule-call-param.order_id
                                                ,INPUT buf_temp-rule-call-param.param-name
                                                ,INPUT buf_temp-rule-call-param.p-index
                                                ,input buf_temp-rule-call-param.param-mode
                                                ,INPUT buf_temp-rule-call-param.param-value-character
                                                ,INPUT buf_temp-rule-call-param.param-value-date
                                                ,INPUT buf_temp-rule-call-param.param-value-decimal
                                                ,INPUT buf_temp-rule-call-param.param-value-integer
                                                ,INPUT buf_temp-rule-call-param.param-value-logical
                                                ) no-error.
    /*end.*/
  end.

end.
end procedure. /* cb_get-rule-call-param */

procedure cb_fill-report-header :
define input parameter p-rbh as handle no-undo .
define input parameter p-report-id as character no-undo .
define input parameter p-report-name  as character no-undo .
define input parameter p-report-label as character no-undo .
define input parameter p-datestart as datetime no-undo .
define input parameter p-dateend as datetime no-undo .

do
on error undo, return error
:

p-rbh:buffer-create().
assign
p-rbh::datetimeEnd   = p-dateend
p-rbh::datetimeStart  = p-datestart
p-rbh::report-name   = p-report-name
p-rbh::report-label  = p-report-label
p-rbh::report-id     = p-report-id
p-rbh::report-db-num = g#db-num
p-rbh::task-num      = v-task-num
.
p-rbh:buffer-release.
end.

end procedure. /* cb_fill-report-header */


procedure cb_fill-report-parameters :
define input parameter p-rpbh as handle no-undo .
define input parameter p-report-id as character no-undo .
main-block:
for each buf_rule-call-param where
        buf_rule-call-param.call_id = p-uniq-key-rec
    and buf_rule-call-param.codex_id = v-codex-id
    and buf_rule-call-param.ruleset_id = v-ruleset-id
    and buf_rule-call-param.order_id = buf_rule-by-call.order_id
 on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
 on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
 on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
 :
  if lookup("hidden", buf_rule-call-param.param-3-data-type) > 0 then next.
  if buf_rule-call-param.param-mode <> {&script-parmode-input} then next.
  if buf_rule-call-param.p-index = 0
  and lookup("LIST", buf_rule-call-param.param-3-data-type) > 0 then next.


  p-rpbh:buffer-create().
  assign
  p-rpbh::report-id     = p-report-id
  p-rpbh::parameter-name    = buf_rule-call-param.param-name
  p-rpbh::parameter-label   = buf_rule-call-param.param-label
  p-rpbh::parameter-value-type = buf_rule-call-param.param-data-type
  p-rpbh::parameter-value = if buf_rule-call-param.param-data-type = {&abl-datatype-character}
                        then buf_rule-call-param.param-value-character
                        else p-rpbh::parameter-value
  p-rpbh::parameter-value = if buf_rule-call-param.param-data-type = {&abl-datatype-date}
                        then string(buf_rule-call-param.param-value-date, "99/99/9999")
                        else p-rpbh::parameter-value
  p-rpbh::parameter-value = if buf_rule-call-param.param-data-type = {&abl-datatype-decimal}
                        then string(buf_rule-call-param.param-value-decimal)
                        else p-rpbh::parameter-value
  p-rpbh::parameter-value = if buf_rule-call-param.param-data-type = {&abl-datatype-logical}
                        then string(buf_rule-call-param.param-value-logical)
                        else p-rpbh::parameter-value
  p-rpbh::parameter-value = if buf_rule-call-param.param-data-type = {&abl-datatype-integer}
                        then string(buf_rule-call-param.param-value-integer)
                        else p-rpbh::parameter-value
  p-rpbh::parameter-index = buf_rule-call-param.p-index
  p-rpbh::parameter-des = buf_rule-call-param.param-des
  .
  p-rpbh:buffer-release.
end.
end procedure. /* cb_fill-report-header */


procedure cb_write-report-error :
define input parameter p-rebh as handle no-undo .
define input parameter p-report-id as character no-undo .
define input parameter p-errcode as integer no-undo .
define input parameter p-errseverity as integer no-undo .
define input parameter p-errmessage as character no-undo .

define variable v-errnum as integer no-undo .
do
on error undo, return error
:
  p-rebh:find-last() no-error.
  if not p-rebh:available then do:
    v-errnum = 1.
  end.
  else do:
   v-errnum = p-rebh::ErrNum + 1.
  end.

  p-rebh:buffer-create().
  assign
  p-rebh::report-id     = p-report-id
  p-rebh::errNum        = v-errnum
  p-rebh::errCode       = p-errcode
  p-rebh::errSeverity   = p-errSeverity
  p-rebh::errMessage    = p-errMessage
  .
  p-rebh:buffer-release().
end.
end procedure. /* cb_write-report-err */


procedure cb_write-report-parameter :
define input parameter p-rpbh as handle no-undo .
define input parameter p-report-id as character no-undo .
define input parameter p-param-name as character no-undo .
define input parameter p-param-label as character no-undo .
define input parameter p-param-data-type as character no-undo .
define input parameter p-param-value-character as character no-undo .
define input parameter p-param-value-date as date no-undo .
define input parameter p-param-value-decimal as decimal no-undo .
define input parameter p-param-value-integer as integer no-undo .
define input parameter p-param-value-logical as logical no-undo .
define input parameter pp-index as integer no-undo .
define input parameter p-param-des as character no-undo .

do
on error undo, return error
:
  p-rpbh:buffer-create().
  assign
  p-rpbh::report-id     = p-report-id
  p-rpbh::parameter-name    = p-param-name
  p-rpbh::parameter-label   = p-param-label
  p-rpbh::parameter-value-type = p-param-data-type
  p-rpbh::parameter-value = if p-param-data-type = {&abl-datatype-character}
                        then p-param-value-character
                        else p-rpbh::parameter-value
  p-rpbh::parameter-value = if p-param-data-type = {&abl-datatype-date}
                        then string(p-param-value-date, "99/99/9999")
                        else p-rpbh::parameter-value
  p-rpbh::parameter-value = if p-param-data-type = {&abl-datatype-decimal}
                        then string(p-param-value-decimal)
                        else p-rpbh::parameter-value
  p-rpbh::parameter-value = if p-param-data-type = {&abl-datatype-logical}
                        then string(p-param-value-logical)
                        else p-rpbh::parameter-value
  p-rpbh::parameter-value = if p-param-data-type = {&abl-datatype-integer}
                        then string(p-param-value-integer)
                        else p-rpbh::parameter-value
  p-rpbh::parameter-index = pp-index
  p-rpbh::parameter-des = p-param-des
  .
  p-rpbh:buffer-release.

end.
end procedure. /* cb_write-report-err */


procedure cb_fill-report-destination :
define input parameter p-rdbh as handle no-undo .
define input parameter p-report-id as character no-undo .
define input parameter p-destination-id as character no-undo .
define input parameter p-destination as character no-undo .
define input parameter p-destination-details as character no-undo . /*типа номер шрифта ориентация и т.д.*/
do
on error undo, return error
:

p-rdbh:buffer-create().
assign
p-rdbh::destination-id  = p-destination-id
p-rdbh::report-id       = p-report-id
p-rdbh::destination     = p-destination
p-rdbh::destination-details     = p-destination-details
.
p-rdbh:buffer-release.
end.

end procedure. /* cb_fill-report-destination */


procedure get-batch-rep-dir :
define input-output parameter p-batch-rep-1 as character no-undo .
define input-output parameter p-batch-rep-2 as character no-undo .
define input parameter p-allow-current-dir as logical no-undo .
define variable glog as logical no-undo .
define variable v-flag-1 as logical no-undo .
define variable v-flag-2 as logical no-undo .
run  verify-ini-entry in this-procedure ( input "batch-rep"
                                          ,input "REP-SETS"
                                          ,input substitute("не указан путь к директории для сохранения отчетов, выполняемых в пакетном режиме")
                                          ,input yes /*p-silence*/
                                          ,output p-batch-rep-1
                                          ) no-error.
if error-status:error or p-batch-rep-1 = ? then do:
  &scop my-message return-value
  {&display-message}.
  if p-allow-current-dir then do:
    file-info:file-name = ".".
    assign
    p-batch-rep-1 = file-info:full-pathname.
    &scop my-message substitute("Отчеты, выводимые в текстовом виде и в EXCEL, будут сохраняться в рабочей директории")
    {&display-message}.
    v-flag-1 = yes.
  end.
  else do:
    undo, return error .
  end.
end.
if not v-flag-1 then do:
  p-batch-rep-1 = prepare-path2(p-batch-rep-1) + {&back-slash-char}.
  RUN verify-file in this-procedure
                                    ( input p-batch-rep-1
                                    , input substitute("Не найден каталог &1 параметр batch-rep, секция [REP-SETS] ini-файла", p-batch-rep-1)
                                    , input yes
                                    ,output glog) no-error.
  if error-status:error
  or not glog then do:
    &scop my-message return-value
    {&display-message}.
    if p-allow-current-dir then do:
      file-info:file-name = ".".
      assign
      p-batch-rep-1 = file-info:full-pathname.
      &scop my-message substitute("Отчеты, выводимые в текстовом виде и EXCEL будут сохраняться в рабочей директории")
      {&display-message}.
    end.
    else do:
      undo, return error .
    end.
  end.
end.
run  verify-ini-entry in this-procedure ( input "batch-rep-xml"
                                          ,input "REP-SETS"
                                          ,input substitute("не указан путь к директории для сохранения отчетов, выполняемых в пакетном режиме")
                                          ,input yes /*p-silence*/
                                          ,output p-batch-rep-2
                                          ) no-error.
if error-status:error or p-batch-rep-2 = ? then do:
  &scop my-message return-value
  {&display-message}.
  if p-allow-current-dir then do:
    assign
    p-batch-rep-2 = ".".
    v-flag-2 = yes.
    &scop my-message substitute("Отчеты, выводимые в XML, будут сохраняться в рабочей директории")
    {&display-message}.
  end.
  else do:
    undo, return error .
  end.
end.
if v-flag-2 then do:
  p-batch-rep-2 = prepare-path2(p-batch-rep-2) + {&back-slash-char}.
  RUN verify-file in this-procedure
                                    ( input p-batch-rep-2
                                    , input substitute("Не найден каталог &1 параметр batch-rep-xml, секция [REP-SETS] ini-файла", p-batch-rep-1)
                                    , input yes
                                    ,output glog) no-error.
  if error-status:error
  or not glog then do:
    &scop my-message return-value
    {&display-message}.
    if p-allow-current-dir then do:
      assign
      p-batch-rep-2 = ".".
      &scop my-message substitute("Отчеты, выводимые в XML, будут сохраняться в рабочей директории")
      {&display-message}.
    end.
    else do:
      undo, return error .
    end.
  end.
end.
end procedure. /* get-bath-rep-dir */

procedure verify-write-to-dir :
define input parameter p-dirs0 as character no-undo .
define output parameter p-dirs as character no-undo .
define variable v-ii as integer no-undo .
define variable v-process-file-name as character no-undo .
do
on error undo, return error
:
  do v-ii = 1 to num-entries( p-dirs0, {&vertical-line}):
    v-process-dir-name = entry(v-ii, p-dirs0, {&vertical-line}).
    if v-process-dir-name = ?
    or v-process-dir-name = '' then do:
      v-process-dir-name = ".".
    end.
    else do:
      /*приведем к каноническому виду*/
      v-process-dir-name = right-trim(v-process-dir-name, {&back-slash-char}).
      v-process-dir-name = v-process-dir-name  + {&back-slash-char}.
    end.
    /*проверим директорию на запись*/
    run gbl/dir-canw.p ( input v-process-dir-name) no-error.
    if error-status:error then do:
      &scop my-message substitute("!!!! Нет возможности вывести отчет в директорию &1&2&3&2&4" ~
                                , v-process-dir-name ~
                                , ~{&new-line~} ~
                                , error-status:get-message(1)  ~
                                , return-value )
      {&display-message}.
      undo, return error .
    end.
    p-dirs = p-dirs + (if v-ii = 1 then '' else {&vertical-line}) + v-process-dir-name.
  end.
end.
end procedure. /* verify-write-to-dir */