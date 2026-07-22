/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вызов процедур RUM в событиях изменения сущностей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/21/08
Author: Bakhtadze Natalya
Creation date: 05/21/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/key-rec.i }

procedure rum-runa :
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-parent-handle as handle no-undo .
define input  parameter p-log-handle  as handle no-undo .
define input  parameter p-process    as character no-undo .
define input  parameter p-oldbh as handle no-undo .
define input  parameter p-newbh as handle no-undo .
define input  parameter p-changes-list as character no-undo .
define input  parameter p-doc-code-file-name as character no-undo .


define variable v-proc-handle as handle no-undo .
define variable v-proc-name as character no-undo .
define variable v-ruleset-id as integer no-undo .
define variable v-ruleset-id-list as character no-undo extent 3.
define variable v-codex-id as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable sign as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-codex-id-list as character no-undo .
define variable v-doc-code as character no-undo .
define variable v-doc-type as character no-undo .
define variable v-process-file-name as character no-undo .
define variable v-cont-handle as handle no-undo .
define variable v-prop-code as character no-undo .
define variable v-curr-r-b as character no-undo .


define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_thbj-attr for ub.thbj-attr.

_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

  if p-log-handle = ? then do:
    { gbl/get-lgh.i p-log-handle }
  end.
  assign
  v-ruleset-id-list[2] = ''
  v-doc-code = substitute("&2&1&3&1&4&1&5"
                          , {&delim-par}
                          ,entry(1, p-doc-code-file-name, {&delim-par}) /*виртуальный код док-та */
                          ,p-oldbh
                          ,p-newbh
                          ,p-changes-list)
  v-process-file-name =  (if num-entries(p-doc-code-file-name, {&delim-par}) > 1
                          then entry(2, p-doc-code-file-name, {&delim-par})
                          else '')
                          /* имя файла*/
  .
  CASE p-process:
    when {&goods-proc_gdsadd}
    or
    when {&goods-proc_gdsupdate}
    or
    when {&goods-proc_rengdscode}
    then do:
      assign
      v-codex-id-list = string(11)
      v-ruleset-id-list[1] = string(5)
      v-prop-code = {&attr-rum_goods}
      v-curr-r-b = ?
      .
    end.
    when {&goods-proc_addlcode}
    or
    when {&goods-proc_dellcode}
    or
    when {&goods-proc_updatelcode}
    then do:
      assign
      v-codex-id-list = string(11)
      v-ruleset-id-list[1] = string(6)
      v-prop-code = {&attr-rum_goods}
      v-curr-r-b = ?
      .
    end.
    when {&goods-proc_addprcode}
    or
    when {&goods-proc_delprcode}
    or
    when {&goods-proc_updateprcode}
    then do:
      assign
      v-codex-id-list = string(11)
      v-ruleset-id-list[1] = string(7)
      v-prop-code = {&attr-rum_goods}
      v-curr-r-b = ?
      .
    end.
    when {&goods-proc_rest-update}
    then do:
      assign
      v-codex-id-list = string(11)
      v-ruleset-id-list[1] = string(8)
      v-prop-code = {&attr-rum_goods}
      .
      { gbl/curr-r-b.i v-curr-r-b }
    end.
    when {&clients-proc_cliadd}
    or
    when {&clients-proc_cliupdate}
    then do:
      assign
      v-codex-id-list = string(12)
      v-ruleset-id-list[1] = string(6)
      v-prop-code = {&attr-rum_clients}
      v-curr-r-b = ?
      .
    end.
    when {&thref-proc_recadd}
    or
    when {&thref-proc_recupdate}
    then do:
      assign
      v-codex-id-list = string(20)
      v-ruleset-id-list[1] = string(5)
      v-prop-code = {&attr-rum_thref}
      v-curr-r-b = ?
      .
    end.
    when {&thref-proc_ref-event}
    then do:
      assign
      v-codex-id-list = string(20)
      v-ruleset-id-list[1] = string(100)
      v-prop-code = {&attr-rum_thref}
      v-curr-r-b = ?
      .
    end.
    when {&edoc-proc_event_price-doc}
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(110)
      v-prop-code = {&attr-rum_edoc}
      .
      { gbl/curr-r-b.i v-curr-r-b }
    end.
    when {&edoc-proc_event_trn-doc}
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(115)
      v-prop-code = {&attr-rum_edoc}
      .
      { gbl/curr-r-b.i v-curr-r-b }
    end.
    when  {&edoc-proc_event_rcv}
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(105)
      v-prop-code = {&attr-rum_edoc}
      .
      { gbl/curr-r-b.i v-curr-r-b }
    end.
    when  {&edoc-proc_event_order}
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(100)
      v-prop-code = {&attr-rum_edoc}
      .
      { gbl/curr-r-b.i v-curr-r-b }
    end.
    when  {&edoc-proc_event_intorder}
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(125)
      v-prop-code = {&attr-rum_edoc}
      .
      { gbl/curr-r-b.i v-curr-r-b }
    end.
    when {&edoc-proc_event_inkas}
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(130)
      v-prop-code = {&attr-rum_edoc}
      .
      { gbl/curr-r-b.i v-curr-r-b }
    end.
    when {&edoc-proc_event_rvs-doc}
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(135)
      v-prop-code = {&attr-rum_edoc}
      .
      { gbl/curr-r-b.i v-curr-r-b }
    end.
    when {&edoc-proc_event_inkas}
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(130)
      v-prop-code = {&attr-rum_edoc}
      .
      { gbl/curr-r-b.i v-curr-r-b }
    end.
    when {&edoc-proc_event_shift}
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(140)
      v-prop-code = {&attr-rum_edoc}
      .
      { gbl/curr-r-b.i v-curr-r-b }
    end.
    when {&edoc-proc_event_icnt-doc}
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(145)
      v-prop-code = {&attr-rum_edoc}
      .
      { gbl/curr-r-b.i v-curr-r-b }
    end.
    when {&edoc-proc_event_fin-doc}
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(150)
      v-prop-code = {&attr-rum_edoc}
      .
      { gbl/curr-r-b.i v-curr-r-b }
    end.
    when {&edoc-proc_event_fbr-doc}
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(155)
      v-prop-code = {&attr-rum_edoc}
      .
      { gbl/curr-r-b.i v-curr-r-b }
    end.
    when {&edoc-proc_event_utd}
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(160)
      v-prop-code = {&attr-rum_edoc}
      .
      { gbl/curr-r-b.i v-curr-r-b }
    end.
    when {&edoc-proc_event_mark}
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(165)
      v-prop-code = {&attr-rum_edoc}
      .
      { gbl/curr-r-b.i v-curr-r-b }
    end.
    when {&edoc-proc_event_user-action}
    then do:
      assign
      v-codex-id-list = string(18)
      v-ruleset-id-list[1] = string(170)
      v-prop-code = {&attr-rum_edoc}
      .
      { gbl/curr-r-b.i v-curr-r-b }
    end.

    otherwise do:
      undo _main, return error substitute("&1 &2 &3&4Ошибка входных параметров процедуры rum-run.p&4Невернoе значение p-process = &5"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,{&new-line}
                                          ,p-process
                                           ).
    end.
  END CASE.
  find first buf_thbj-attr no-lock where
            buf_thbj-attr.upper-prop-code = {&attr-rum}
       and  buf_thbj-attr.prop-code = v-prop-code no-error.
  if not available buf_thbj-attr
  or buf_thbj-attr.property-value-logical = no
  then return ''.
  run gen-key-rec in this-procedure ( input {&table_thbj-attr}
                                     ,input (buffer buf_thbj-attr:handle)
                                     ,output v-uniq-key-rec).

  _codex:
  do v-jj = 1 to num-entries(v-codex-id-list):
    if entry(v-jj, v-codex-id-list) = '':U then next _codex.
    v-codex-id = integer(entry(v-jj, v-codex-id-list)).
    do v-ii = 1 to num-entries(v-ruleset-id-list[v-jj]):
        if entry(v-ii, v-ruleset-id-list[v-jj]) = '':U then next.
        v-ruleset-id = integer(entry(v-ii, v-ruleset-id-list[v-jj])).
      _rule-by-call:
      for each buf_rule-by-call no-lock where
                buf_rule-by-call.call_id = v-uniq-key-rec
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
        run value(v-proc-name)  (
                                                              input parparentproc
                                                            ,input p-parent-handle
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
                                                            ,input 0 /*v-host-code*/
                                                            ,input '' /*v-obj-type*/
                                                            ,input 0 /*v-obj-code*/
                                                            ,input v-doc-code
                                                            ,input v-process-file-name
                                                            ,input 0 /*v-save-int*/
                                                            ,input v-curr-r-b
                                                            ,input ? /*p-cmd-proc-handle*/
                                                            ,input 0 /*temp-cmd.cmd-code пока*/
                                                            ) .
/* к сожалению этот код проглатывает ошибку и не пробрасывает ее на верх
no-error .

        if error-status:error
        then do:
          undo _main, return error substitute("&1&2Ошибка при маршрутизации&2" +
                                              "&3&2&4"
                                              ,vss-workfile
                                              ,{&new-line}
                                              , error-status:get-message(1)
                                              , return-value
                                                ).

        end. /*if error-status:error then do:*/ */
      end. /*for each buf_rule-by-call no-lock where*/
    end. /*do v-ii = 1 to */
  end. /*do v-jj*/
end. /*_main*/
end procedure. /* rum-run */