block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: clisrum.p $
$Archive: str/clisrum.p $

Вызов процедур RUM для обработки клиентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/26/08
Author: Bakhtadze Natalya
Creation date: 05/26/08

*/

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-parent-handle as handle no-undo .
define input  parameter p-log-handle  as handle no-undo .
define input  parameter p-process    as character no-undo .
define input  parameter p-profile-id as integer   no-undo .
define input  parameter p-codex-id as integer   no-undo .
define input  parameter p-ruleset-id as integer   no-undo .
define input  parameter p-db-num like ub.db.db-num no-undo .
define input  parameter p-uniq-key-rec as character no-undo .
define input  parameter p-doc-code as character no-undo .
define input  parameter p-save        as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: clisrum.p $":u .
define variable vss-archive     as character no-undo init "$Archive: str/clisrum.p $":u .
define variable vss-description as character no-undo init "Вызов процедур RUM для обработки клиентов" .
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
define variable v-process-file-name as character no-undo .
define variable v-profile-id as integer no-undo .
define variable log-file-name as character no-undo init "process-cli-list.txt".
define variable v-save-int as integer no-undo .
define variable v-charkey_one as character no-undo .
define variable v-charkey_one-2 as character no-undo .
define variable v-num-dc as integer no-undo .
define variable v-is-empty as logical no-undo .
define variable v-rec-ord_ as integer no-undo .
define variable v-param-name as character no-undo .
define variable v-xsd-file as character no-undo .


/*
возможные значения v-save-int
0 - при p-save = yes - обычное сохранение
-1 - p-save = no- проверка  пакетный режим расчета по ДК p-process = {&dct-proc_batch-card-recalc} codex=2 ruleset=5 - сохраняются изменения в temp-changes
-2 - одиночный режим расечта по ДК p-process = {&dct-proc_one-card-check} codex=2 ruleset=5 - сохраняются изменения в temp-table.new-tbl-handle
и потом могут быть показаны в интерфейсе view-chg.w
1  - p-save = yes - расчет с сохранением пакетный режим расчета по ДК p-process = {&dct-proc_batch-card-recalc} codex=2 ruleset=5 - сохраняются изменения в temp-changes
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
and p-process = {&clients-proc_xml-esys-import}
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
    when {&clients-proc_batchwork-export}
    or
    when {&clients-proc_batchwork-routing}
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
      v-doc-code = entry(1, p-doc-code, {&delim-par}) /*виртуальный кодщ док-та */
      v-process-file-name =  entry(2, p-doc-code, {&delim-par}) /* имя файла*/
      v-profile-id = p-profile-id
      .
      assign
      v-codex-id-list = string(p-codex-id)
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = ''
      .
    end.
    when {&clients-proc_xml-file-import}
    or when {&clients-proc_text-import}
     then do:
      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      v-obj-type = v-cntxt-obj-type
      v-obj-code = v-cntxt-obj-code
      v-host-code = v-cntxt-host-code-obj
      v-doc-date = v-today
      v-fact-date = v-today
      v-doc-code = entry(1, p-doc-code, {&delim-par}) /*виртуальный код док-та */
      v-process-file-name =  entry(2, p-doc-code, {&delim-par})
      v-profile-id = p-profile-id
      .
      assign
      v-codex-id-list = string(p-codex-id)
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = ''
      .
      /*
      run xmlischn_fill in this-procedure ( input p-codex-id
                                           ,input p-ruleset-id).
      */
    end.
   when {&clients-proc_xml-esys-import} then do:
      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      v-obj-type = v-cntxt-obj-type
      v-obj-code = v-cntxt-obj-code
      v-host-code = v-cntxt-host-code-obj
      v-doc-date = v-today
      v-fact-date = v-today
      v-doc-code = entry(1, p-doc-code, {&delim-par}) /*виртуальный код док-та */
      v-process-file-name =  entry(2, p-doc-code, {&delim-par}) +
                              {&delim-par} + entry(3, p-doc-code, {&delim-par}) /*handle dataset*/
                              + {&delim-par} + entry(4, p-doc-code, {&delim-par}) /*pack-num*/
                              + {&delim-par} + entry(5, p-doc-code, {&delim-par}) /*log-file-name*/
      v-profile-id = p-profile-id
      v-cont-handle = p-parent-handle
      v-param-name = entry(6, p-doc-code, {&delim-par})
      v-xsd-file = entry(7, p-doc-code, {&delim-par})
      .
      assign
      v-codex-id-list = string(p-codex-id)
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = ''
      .
    end.
    otherwise do:

      undo _main, return error substitute("&1 &2 &3&4Ошибка входных параметров процедуры clientsrum.p&4Невернoе значение p-process = &5"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,{&new-line}
                                          ,p-process
                                           ).
    end.
  END CASE.

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

        if p-process = {&clients-proc_batchwork-export}
        or p-process = {&clients-proc_batchwork-routing}
        /*or p-process = {&clients-proc_xml-file-import}*/
        then do:
          if buf_rule-by-call.profile_id <> v-profile-id then next _rule-by-call.
        end.
        if p-process = {&clients-proc_xml-esys-import}
        and buf_rule-by-call.ruleset_id = 5
        then do:
          find first buf_rule-call-param no-lock where
                    buf_rule-call-param.call_id = buf_rule-by-call.call_id
                and buf_rule-call-param.codex_id = buf_rule-by-call.codex_id
                and buf_rule-call-param.ruleset_id = buf_rule-by-call.ruleset_id
                and buf_rule-call-param.order_id = buf_rule-by-call.order_id
                and buf_rule-call-param.param-name = v-param-name
                and buf_rule-call-param.param-value-character = v-xsd-file no-error.
          if not available buf_rule-call-param then next _rule-by-call.
        end.
        v-proc-name = "rul/" + string(buf_rule-by-call.rule_id, '999999999') + '.p'.
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
                                                            ,input v-process-file-name
                                                            ,input v-save-int
                                                            ,input v-curr-r-b
                                                            ,input v-cmd-proc-handle
                                                            ,input 0 /*temp-cmd.cmd-code пока*/
                                                            ) no-error .

        if error-status:error
        then do:
          undo _main, return error substitute("&1&2Ошибка при обработке списка клиентов&2" +
                                              "&3&2&4"
                                              ,vss-workfile
                                              ,{&new-line}
                                              , error-status:get-message(1)
                                              , return-value
                                                ).
        end. /*if error-status:error then do:*/
        if v-stop-leave-status > '' then do:
          undo _main, return error substitute("&1&2Процесс обработки клиентов прерван&2" +
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
end. /*_main*/

/*отсылка на кассу*/
/*
if p-save then do:
  run str/diallog.w (
                  input parparentproc
                , input this-procedure
                , input 'str/send-gds.p':U
                , input(string(g#db-num) + {&delim-par}  + {&delim-par} + "no":U + {&delim-par} + "S":U)
                , input yes /*p-auto-go*/
                , input '':U
                , input 'Отправка информации по клиентов на кассу') no-error .
end.
*/

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