block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: edocrum.p $
$Archive: str/edocrum.p $

Вызов процедур RUM для обработки операции электронного документооборота

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/01/08
Author: Bakhtadze Natalya
Creation date: 10/01/08

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
define variable vss-workfile    as character no-undo init "$Workfile: edocrum.p $":u .
define variable vss-archive     as character no-undo init "$Archive: str/edocrum.p $":u .
define variable vss-description as character no-undo init "Вызов процедур RUM для обработки операции электронного документооборота" .
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
{ str/ord-list.i ord-list def "new shared" }
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
{ cmp/doc-list.i doc-list def "new shared" }
{ rul/ruleset_.i }

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

define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_ord-chain for ub.ord-chain .
define buffer buf_ord-doc for ub.ord-doc.
define buffer buf_price-doc for ub.price-doc.
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
define buffer buf_inkas for ub.inkas.

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
and (p-process =  {&edoc-proc_xml-esys-import_order}
    or
    p-process = {&edoc-proc_xml-esys-import_rcv}
    or
    p-process = {&edoc-proc_xml-esys-import_price-doc}
    or
    p-process = {&edoc-proc_xml-esys-import_trn-doc}
    or
    p-process = {&edoc-proc_xml-esys-import_inv-doc}
    or
    p-process = {&edoc-proc_xml-esys-import_contract}
    or
    p-process = {&edoc-proc_text-import_specif}
    or
    p-process = {&edoc-proc_excel-import_specif}

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
    when {&edoc-proc_batchwork-export_order}
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
      v-process-file-name =  entry(2, p-doc-code, {&delim-par}) /* имя файла*/
      v-profile-id = p-profile-id
      .
      if v-doc-code <> '' then do:
        do transaction:
        find first buf_ord-doc exclusive-lock where
                  buf_ord-doc.doc-code = v-doc-code.
        create ord-list.
        buffer-copy buf_ord-doc to ord-list
        assign
        /*ord-list.ord-int1   = p-stts*/
        ord-list.dm = buf_ord-doc.whole-send-news
        .
        release ord-list.
      end.
      end.
      assign
      v-codex-id-list = string(p-codex-id)
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = ''
      .
    end.
    when {&edoc-proc_batchwork-routing_order}
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
      if v-doc-code <> '' then do:
        do transaction:
        find first buf_ord-doc exclusive-lock where
                  buf_ord-doc.doc-code = v-doc-code.
        create ord-list.
        buffer-copy buf_ord-doc to ord-list
        assign
        /*ord-list.ord-int1   = p-stts*/
        ord-list.dm = buf_ord-doc.whole-send-news
        .
        release ord-list.
      end.
      end.
      assign
      v-codex-id-list = string(p-codex-id)
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = ''
      .
    end.
    when {&edoc-proc_xml-file-import_order}
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
      v-codex-id-list = string(p-codex-id) + {&comma-char} + string(p-codex-id)
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = string({&edoc-proc_18_batchwork-export_order_1})
      .
      /*
      run xmlischn_fill in this-procedure ( input p-codex-id
                                           ,input p-ruleset-id).
      */
    end.
    when {&edoc-proc_batchwork-routing_price-doc}
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
      if v-doc-code <> '' then do:
        do transaction:
        find first buf_price-doc exclusive-lock where
                  buf_price-doc.doc-num = v-doc-code.
        { cmp/doc-list.i doc-list assign-price-doc buf_price-doc }
        release doc-list.
      end.
      end.
      assign
      v-codex-id-list = string(p-codex-id)
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = ''
      .
    end.
    when {&edoc-proc_batchwork-routing_trn-doc}  then do:
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
      if v-doc-code <> '' then do:
        do transaction:
        find first buf_trn-doc exclusive-lock where
                  buf_trn-doc.doc-code = v-doc-code.
        { cmp/doc-list.i doc-list assign-trn buf_trn-doc }
        release doc-list.
      end.
      end.
      assign
      v-codex-id-list = string(p-codex-id)
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = ''
      .
    end.
    when {&edoc-proc_batchwork-routing_inkas} then do:
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
      if v-doc-code <> '' then do:
        do transaction:
        find first buf_inkas exclusive-lock where
                  buf_inkas.inkas-code = v-doc-code.
        { cmp/doc-list.i doc-list assign-inkas buf_inkas }
        release doc-list.
      end.
      end.
      assign
      v-codex-id-list = string(p-codex-id)
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = ''
      .
    end.
    when {&edoc-proc_xml-esys-import_order}
    or
    when {&edoc-proc_xml-esys-import_rcv}
    or
    when {&edoc-proc_xml-esys-import_price-doc}
    or
    when {&edoc-proc_xml-esys-import_trn-doc}
    or
    when {&edoc-proc_xml-esys-import_inv-doc}
    or
    when {&edoc-proc_xml-esys-import_contract}
    then do:
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
      v-codex-id-list = string(p-codex-id) + (if p-process = {&edoc-proc_xml-esys-import_order}
                                              then ({&comma-char} + string(p-codex-id))
                                              else '')
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = (if p-process = {&edoc-proc_xml-esys-import_order}
                              then string({&edoc-proc_18_batchwork-routing_order_2})
                              else '')
      .
    end.
    when {&edoc-proc_batchwork-export_rcv}
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
      v-process-file-name =  entry(2, p-doc-code, {&delim-par}) /* имя файла*/
      v-profile-id = p-profile-id
      .
      if v-doc-code <> '' then do:
      find first buf_trn-doc where
                buf_trn-doc.doc-code = v-doc-code.
        create ord-list.
        /*Найдем первую поставку по накладной */
        find first buf_ord-chain   no-lock where
            buf_ord-chain.rel-doc-code = buf_trn-doc.doc-code and
            buf_ord-chain.rel-doc-type = "trn" and
            buf_ord-chain.doc-type = "rcv" no-error .
            if error-status :error then return .

        find first buf_ord-doc-rcv no-lock where
                  buf_ord-doc-rcv.rcv-code = buf_ord-chain.doc-code no-error .
        if error-status :error then return .
        find first buf_ord-doc no-lock where
                  buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code no-error .
        if error-status :error then return .

        assign
        ord-list.trn-doc    = entry (1,buf_ord-doc-rcv.sub-par,{&delim-par})
        ord-list.host-code  = buf_ord-doc-rcv.host-code
        ord-list.cli-type   = buf_ord-doc-rcv.cli-type
        ord-list.cli-code   = buf_ord-doc-rcv.cli-code
        ord-list.doc-date   = buf_trn-doc.doc-date
        ord-list.doc-code   = buf_ord-doc-rcv.doc-code
        ord-list.obj-type   = buf_ord-doc-rcv.obj-type
        ord-list.obj-code   = buf_ord-doc-rcv.obj-code
        ord-list.fact-num   = buf_trn-doc.fact-num
        ord-list.fact-date  = buf_trn-doc.fact-date
        ord-list.shift-date = buf_trn-doc.shift-date
        ord-list.shift-num  = buf_trn-doc.shift-num
        ord-list.shift-name = buf_trn-doc.shift-name
        ord-list.fact-order = buf_trn-doc.fact-order
        ord-list.cli-out-doc = buf_ord-doc.cli-out-doc
        ord-list.is-trn-doc = true
        ord-list.doc-type   = buf_trn-doc.doc-code /* засунем суда */
        ord-list.dm = buf_ord-doc.whole-send-news
        .
        release ord-list.
      end.
      assign
      v-codex-id-list = string(p-codex-id)
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = ''
      .
    end.
    when {&edoc-proc_batchwork-routing_rcv}
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
      find first buf_trn-doc where
                buf_trn-doc.doc-code = v-doc-code.

      create ord-list.

      /*Найдем первую поставку по накладной */
      find first buf_ord-chain   no-lock where
          buf_ord-chain.rel-doc-code = buf_trn-doc.doc-code and
          buf_ord-chain.rel-doc-type = "trn" and
          buf_ord-chain.doc-type = "rcv" no-error .
          if error-status :error then return .

      find first buf_ord-doc-rcv no-lock where
                buf_ord-doc-rcv.rcv-code = buf_ord-chain.doc-code no-error .
      if error-status :error then return .
      find first buf_ord-doc no-lock where
                buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code no-error .
      if error-status :error then return .

      assign
      /*ord-list.ord-int1   = p-stts*/
      ord-list.trn-doc    = entry (1,buf_ord-doc-rcv.sub-par,{&delim-par})
      ord-list.host-code  = buf_ord-doc-rcv.host-code
      ord-list.cli-type   = buf_ord-doc-rcv.cli-type
      ord-list.cli-code   = buf_ord-doc-rcv.cli-code
      ord-list.doc-date   = buf_trn-doc.doc-date
      ord-list.doc-code   = buf_ord-doc-rcv.doc-code
      ord-list.obj-type   = buf_ord-doc-rcv.obj-type
      ord-list.obj-code   = buf_ord-doc-rcv.obj-code
      ord-list.fact-num   = buf_trn-doc.fact-num
      ord-list.fact-date  = buf_trn-doc.fact-date
      ord-list.shift-date = buf_trn-doc.shift-date
      ord-list.shift-num  = buf_trn-doc.shift-num
      ord-list.shift-name = buf_trn-doc.shift-name
      ord-list.fact-order = buf_trn-doc.fact-order
      ord-list.is-trn-doc = true
      ord-list.doc-type   = buf_trn-doc.doc-code /* засунем суда */
      ord-list.cli-out-doc = buf_ord-doc.cli-out-doc
      ord-list.dm = buf_ord-doc.whole-send-news
      .
      assign
      v-codex-id-list = string(p-codex-id)
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = ''
      .
    end.
    when {&edoc-proc_text-import_specif}
    or
    when {&edoc-proc_excel-import_specif}
    or
    when {&edoc-proc_text-export_specif}
    or
    when {&edoc-proc_excel-export_specif}
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
      v-process-file-name =  entry(2, p-doc-code, {&delim-par}) /* имя файла*/
      v-profile-id = p-profile-id
      .
      assign
      v-codex-id-list = string(p-codex-id)
      v-ruleset-id-list[1] = string(p-ruleset-id)
      v-ruleset-id-list[2] = ''
      .
    end.
    otherwise do:
      undo _main, return error substitute("&1 &2 &3&4Ошибка входных параметров процедуры edocrum.p&4Невернoе значение p-process = &5"
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
        if p-process = {&edoc-proc_batchwork-routing_ORDER}
        or p-process = {&edoc-proc_batchwork-export_order}
        or p-process = {&edoc-proc_xml-file-import_order}
        or p-process = {&edoc-proc_batchwork-routing_rcv}
        or p-process = {&edoc-proc_batchwork-export_rcv}
        or p-process = {&edoc-proc_xml-file-import_rcv}
        or p-process = {&edoc-proc_batchwork-routing_price-doc}
        or p-process = {&edoc-proc_batchwork-routing_inkas}
        or p-process = {&edoc-proc_batchwork-routing_trn-doc}
        or p-process = {&edoc-proc_text-import_specif}
        or p-process = {&edoc-proc_excel-import_specif}
        or p-process = {&edoc-proc_text-export_specif}
        or p-process = {&edoc-proc_excel-export_specif}
        then do:
          if buf_rule-by-call.profile_id <> v-profile-id then next _rule-by-call.
        end.
        if  (p-process =  {&edoc-proc_xml-esys-import_order}
          or
          p-process = {&edoc-proc_xml-esys-import_rcv}
          or
          p-process = {&edoc-proc_xml-esys-import_price-doc}
          or
          p-process = {&edoc-proc_xml-esys-import_trn-doc}
          )
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
          undo _main, return error substitute("&1&2Ошибка при обработке электронных документов&2" +
                                              "&3&2&4"
                                              ,vss-workfile
                                              ,{&new-line}
                                              , error-status:get-message(1)
                                              , return-value
                                                ).
        end. /*if error-status:error then do:*/
        if v-stop-leave-status > '' then do:
          undo _main, return error substitute("&1&2Процесс обработки электронных документов прерван&2" +
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