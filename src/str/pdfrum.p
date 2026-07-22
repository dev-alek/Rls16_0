block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: pdfrum.p $
$Archive: str/pdfrum.p $

Вызов процедур RUM для обработки операций по ДНЦ и переоценкам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/20/09
Author: Bakhtadze Natalya
Creation date: 04/20/09

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
define input  parameter p-doc-code as character no-undo . /*для чего-нибудь*/
define input  parameter p-plt-id as integer no-undo .
define input  parameter p-plt-db-num as integer no-undo .
define input  parameter p-pdf-id as integer no-undo .
define input  parameter p-pdf-db-num as integer no-undo .
define input  parameter p-save        as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: pdfrum.p $":u .
define variable vss-archive     as character no-undo init "$Archive: str/pdfrum.p $":u .
define variable vss-description as character no-undo init "Вызов процедур RUM для обработки операций по ДНЦ и переоценкам" .
{ cmp/vssrevis.i "substitute('&1|&2|&3':u
                              ,p-process
                              ,p-db-num
                              ,p-plt-id
                              ,p-plt-db-num
                              ,p-pdf-id
                              ,p-pdf-db-num
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
{ str/pdf-list.i pdf-list def "new shared" }

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
define variable v-plt-id as integer no-undo .
define variable v-plt-db-num as integer no-undo .
define variable v-pdf-id as integer no-undo .
define variable v-pdf-db-num as integer no-undo .
define variable v-process-file-name as character no-undo .
define variable v-profile-id as integer no-undo .
define variable log-file-name as character no-undo init "process-pdf-list.txt".
define variable v-save-int as integer no-undo .
define variable v-charkey_one as character no-undo .
define variable v-charkey_one-2 as character no-undo .
define variable v-num-dc as integer no-undo .
define variable v-is-empty as logical no-undo .
define variable v-rec-ord_ as integer no-undo .
define variable v-param-name as character no-undo .
define variable v-xsd-file as character no-undo .

define variable v-cont-handle as handle no-undo .
&scop cmd-proc-handle v-cmd-proc-handle
&scop cmd-code buf_temp-cmd.cmd-code


&scop sign sign *

define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_temp-pers-proc  for temp-pers-proc.
define buffer buf_db for ub.db.
define buffer buf_sysconf for ub.sysconf.

define buffer buf_price-doc for ub.price-doc.
define buffer buf_price-doc-forming for ub.price-doc-forming.

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
    when {&pdf-proc_pdf-main-doc-close}
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
      /*
      v-doc-code = entry(1, p-doc-code, {&delim-par}) /*виртуальный код док-та */
      v-process-file-name =  entry(2, p-doc-code, {&delim-par}) /* имя файла*/
      */
      v-plt-id = p-plt-id
      v-plt-db-num = p-plt-db-num
      v-pdf-id = p-pdf-id
      v-pdf-db-num = p-pdf-db-num
      v-profile-id = p-profile-id
      v-codex-id-list = "21"
      v-ruleset-id-list[1] = "1"
      v-ruleset-id-list[2] = ""
      .
      if v-plt-id <> 0
      and v-pdf-id <> 0
      then do:
        find first buf_price-doc-forming exclusive-lock where
                  buf_price-doc-forming.plt-id = v-plt-id
              and buf_price-doc-forming.plt-db-num = v-plt-db-num
              and buf_price-doc-forming.pdf-id = v-pdf-id
              and buf_price-doc-forming.pdf-db = v-pdf-db-num.
        create pdf-list.
        buffer-copy buf_price-doc-forming to pdf-list
        .
        release pdf-list.
      end.
    end.
    otherwise do:
      undo _main, return error substitute("&1 &2 &3&4Ошибка входных параметров процедуры pdfrum.p&4Невернoе значение p-process = &5"
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
                                                            ,input v-plt-id
                                                            ,input v-plt-db-num
                                                            ,input v-pdf-id
                                                            ,input v-pdf-db-num
                                                            ,input v-process-file-name
                                                            ,input v-save-int
                                                            ,input v-curr-r-b
                                                            ,input v-cmd-proc-handle
                                                            ,input 0 /*temp-cmd.cmd-code пока*/
                                                            ) no-error .
        if error-status:error
        then do:
          undo _main, return error substitute("&1&2Ошибка при обработке ДНЦ и/или переоценок&2" +
                                              "&3&2&4"
                                              ,vss-workfile
                                              ,{&new-line}
                                              , error-status:get-message(1)
                                              , return-value
                                                ).
        end. /*if error-status:error then do:*/
        if v-stop-leave-status > '' then do:
          undo _main, return error substitute("&1&2Ошибка при обработке ДНЦ и/или переоценок&2" +
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