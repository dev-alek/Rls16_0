block-level on error undo, throw.
/*

$Revision: d247db01eab0, 2628, rls $
$Author: ASMorozov $
$Date: Пн окт 19 09:22:02 2020 +0300 $
$Workfile: saledc.p $
$Archive: str/saledc.p $

Вызов обсчета ДК при закрытии документа или форсированном обсчете

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/14/05
Author: Bakhtadze Natalya
Creation date: 10/14/05

при закрытии и удалении документов продажи
при закрытии и удалении накладных с ДК
при закрытии платежа на карту
при пересчете скидок в соответствии с накопленными итогами
при приеме данных с касс ИМПОРТА

*/

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-parent-handle as handle no-undo .
define input  parameter p-log-handle  as handle no-undo .
define input  parameter p-process    as character no-undo .
define input  parameter p-emitent-host-code as integer   no-undo .
define input  parameter p-type as character no-undo .
define input  parameter p-profile-id as integer   no-undo .
define input  parameter p-codex-id as integer   no-undo .
define input  parameter p-ruleset-id as integer   no-undo .
define input  parameter p-db-num like ub.db.db-num no-undo .
define input  parameter p-doc-code   like ub.inkas.inkas-code no-undo .
define input  parameter p-doc-date   like ub.inkas.doc-date no-undo .
define input  parameter p-fact-date  like ub.inkas.fact-date no-undo .
define input  parameter cre-pay      like ub.cash-pay.cdpay-code no-undo.
define input  parameter par-sign      as integer no-undo .
define input  parameter par-direction as integer no-undo .
define input  parameter p-save        as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: d247db01eab0, 2628, rls $":u .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":u .
define variable vss-date        as character no-undo init "$Date: Пн окт 19 09:22:02 2020 +0300 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: saledc.p $":u .
define variable vss-archive     as character no-undo init "$Archive: str/saledc.p $":u .
define variable vss-description as character no-undo init "Вызов обсчета ДК при закрытии документа или форсированном обсчете" .
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6':u
                              ,p-process
                              ,p-db-num
                              ,p-doc-code
                              ,cre-pay
                              ,par-sign
                              ,par-direction
                              )" }
{ cmp/trg-def.i  }
{ str/vchk-pay.i "NEW SHARED" }
{ str/saledcdf.i " NEW SHARED "}
{ cmp/dc-list.i dc-list   def "new shared" }
{ cmp/dcp-list.i dcp-list def "new shared" }
{ str/defc-cli.i "NEW SHARED"}
{ gbl/getcntxt.i def }
{ gbl/perproc.i " " 100 }
{ nws/lib-nws.i }
{ gbl/key-rec.i }
{ gbl/cur-time.i  }
{ rep/r-sale.i }
{ rep/r-cost.i }
{ str/saledc.i def }
{ rul/cl-hist.i "new shared" }
{ rul/calldscr.i }

define variable v-stop-leave-status as character no-undo .
define variable v-cmd-code as integer no-undo .
define variable v-cmd-proc-handle as handle no-undo .
define variable v-command  as character no-undo .
define variable p-step  as integer no-undo init 1.
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
define variable v-dc-list-mode as character no-undo .
define variable v-calc-chr as character no-undo .
define variable v-dct-uniq-key-rec as character no-undo .
define variable v-can-run as logical no-undo .
define variable v-doc-code as character no-undo .
define variable v-doc-type as character no-undo .
define variable v-process-file-name as character no-undo .
define variable v-type as character no-undo .
define variable v-emitent-host-code as integer no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-profile-id as integer no-undo .
define variable v-d-card as character no-undo .
define variable log-file-name as character no-undo .
define variable v-save-int as integer no-undo .
define variable v-charkey_one as character no-undo .
define variable v-charkey_one-2 as character no-undo .
define variable v-num-dc as integer no-undo .
define variable v-is-empty as logical no-undo .
define variable v-rec-ord_ as integer no-undo .

/*
возможные значения v-save-int
0 - при p-save = yes - обычное сохранение
-1 - p-save = no- проверка  пакетный режим расчета по ДК p-process = {&dct-proc_batch-card-recalc} codex=2 ruleset=5 - сохраняются изменения в temp-changes
-2 - одиночный режим расечта по ДК p-process = {&dct-proc_one-card-check} codex=2 ruleset=5 - сохраняются изменения в temp-table.new-tbl-handle
и потом могут быть показаны в интерфейсе view-chg.w
1  - p-save = yes - расчет с сохранением пакетный режим расчета по ДК p-process = {&dct-proc_batch-card-recalc} codex=2 ruleset=5 - сохраняются изменения в temp-changes
*/

define variable v-cont-handle as handle no-undo .
define variable v-xsd-file as character no-undo .
define variable v-param-name as character no-undo .
&scop cmd-proc-handle v-cmd-proc-handle
&scop cmd-code buf_temp-cmd.cmd-code


&scop sign sign *

define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_temp-pers-proc  for temp-pers-proc.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_ret-doc for ub.trn-doc.
define buffer buf_payment for ub.payment.
define buffer buf_fin-doc for ub.fin-doc.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_curr-shop for ub.curr-shop.
define buffer buf_db for ub.db.
define buffer bf_dis-card for ub.dis-card.
define buffer bf_trn-doc  for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_goods for ub.goods.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_inkas for ub.inkas .
define buffer buf_sysconf for ub.sysconf.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_stop-list for ub.stop-list.

{ nws/temp-cmd.i "NEW SHARED" }

define buffer buf_temp-cmd  for temp-cmd.
define buffer buf1_temp-cmd  for temp-cmd.
define buffer buf_temp-smart-route  for temp-smart-route.
define buffer buf_temp-smart-link  for temp-smart-link.
define buffer buf_temp-nws-outline for temp-nws-outline.
define buffer buf_temp-no-route for temp-no-route.

define variable mode-erprn as logical no-undo.

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

  { gbl/conf-rd.i
    "'is-erpRN'"
    0
    "''"
    0
    "''"
    "''"
    "''"
    NO
    conf-par
    par-type
    no-error
    }
  IF not error-status:error and conf-par = "yes":U then mode-erprn = yes.
  else mode-erprn = no.

  { gbl/curr-r-b.i
    v-curr-r-b
  }
  if transaction
  and (p-process = {&thref-proc_xml-esys-import}
  or  p-process = {&dct-proc_text-import})
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Вызов процедуры в действующей транзакции недопустим") skip
      view-as alert-box error .
    return error substitute( "&1. Вызов процедуры в действующей транзакции недопустим", vss-workfile ) .
  end.
  for each temp-d-card:
    delete temp-d-card.
  end.
  for each vchk-pay:
    delete vchk-pay.
  end.
  if not p-save
  and not (p-process = {&dct-proc_batch-card-recalc}
       or p-process = {&dct-proc_one-card-check}) then do:
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
    when {&dct-proc_sale-delete}
    or
    when {&dct-proc_sale-close}
    then do:
      /*str/saleclos.p  str/delfsale.p*/
      sign = par-sign.
      assign
      v-codex-id-list = (if g#db-num = 0
                         then "1,2"
                         else "1")
      v-ruleset-id-list[1] = string(if par-sign = 1
                                  then 1
                                  else 2)
      v-ruleset-id-list[2] = (if g#db-num = 0
                              then (string(if par-sign = 1
                                            then 1
                                            else 2)
                                    )
                              else '':U)
      v-ruleset-id-list[2] = (if g#db-num = 0
                              then (v-ruleset-id-list[2] + {&comma-char} + string(9))
                              else v-ruleset-id-list[2])
      .
      if p-save then do:
        do transaction:
        find first buf_inkas exclusive-lock
          where buf_inkas.inkas-code = p-doc-code
          no-error .
      end.
      end.
      else do:
        find first buf_inkas no-lock
          where buf_inkas.inkas-code = p-doc-code
          no-error .
      end.
      if not available buf_inkas then do:
        undo, return error
        substitute("&1 &2 &3 Ошибка задания входных параметров: не найдена продажа &4"
                  ,vss-workfile
                  ,vss-revision
                  ,vss-description
                  ,p-doc-code)
        .
      end.
      find first buf_trn-doc no-lock where
                buf_trn-doc.doc-code = p-doc-code no-error .
      if not available buf_trn-doc then do:
        undo _main, return error substitute("Не найден документ с номером &1", p-doc-code).
      end.

      find first buf_ret-doc no-lock where
                buf_ret-doc.doc-code = buf_trn-doc.out-code no-error .
      if available buf_ret-doc then do:
        ret-doc-code = buf_ret-doc.doc-code.
      end.
      else do:
        ret-doc-code = '':U.
      end.
      assign
      v-obj-type = buf_inkas.obj-type
      v-obj-code = buf_inkas.obj-code
      v-doc-date = buf_inkas.doc-date
      v-doc-code = p-doc-code
      v-process-file-name = ''
      v-doc-type = {&hn-source-trn-doc}
      v-fact-date = buf_inkas.fact-date
      .
      { gbl/hostcode.i
        buf_inkas.obj-type
        buf_inkas.obj-code
        v-host-code
      }

      { gbl/basecode.i
        v-host-code
        v-base-code
      }
      sign = par-sign.
      { str/saledc.i obj }
    end. /*when {&dct-proc_sale-delete}*/
    when {&dct-proc_trn-doc-close}
    or
    when {&dct-proc_trn-doc-delete}
    then do:
      /*str/lib-trn.p str/trn-stat.p*/
      assign
      v-codex-id-list = (if g#db-num = 0
                         then "1,2"
                         else "1")
      v-ruleset-id-list[1] = string(if par-sign = 1
                                  then 3
                                  else 4)
      v-ruleset-id-list[2] = (if g#db-num = 0
                              then (string(if par-sign = 1
                                            then 3
                                            else 4)
                                  )
                              else '':U)
      v-ruleset-id-list[2] = (if g#db-num = 0
                              then (v-ruleset-id-list[2] + {&comma-char} + string(9))
                              else v-ruleset-id-list[2])
      .

      sign  = par-direction * par-sign.
      if p-save then do:
        do transaction:
        find first bf_trn-doc exclusive-lock where
                  bf_trn-doc.doc-code = p-doc-code no-error .
      end.
      end.
      else do:
        find first bf_trn-doc no-lock where
                  bf_trn-doc.doc-code = p-doc-code no-error .
      end.
      if not available bf_trn-doc then do:
        undo, return error
        substitute("&1 &2 &3 Ошибка задания входных параметров: не найден документ &4"
                  ,vss-workfile
                  ,vss-revision
                  ,vss-description
                  ,p-doc-code)
        .
      end.
      { gbl/hostcode.i
        bf_trn-doc.obj-type
        bf_trn-doc.obj-code
        v-host-code
      }
      { gbl/basecode.i
        v-host-code
        v-base-code
      }
      assign
      v-obj-type = bf_trn-doc.obj-type
      v-obj-code = bf_trn-doc.obj-code
      v-doc-date = bf_trn-doc.doc-date
      v-fact-date = bf_trn-doc.fact-date
      v-doc-code = p-doc-code
      v-process-file-name = ''
      v-doc-type = {&hn-source-trn-doc}
      .
      FIND FIRST bf_dis-card WHERE
                bf_dis-card.d-card = bf_trn-doc.d-card NO-LOCK .
      create temp-d-card.
      assign
      temp-d-card.d-card = bf_dis-card.d-card
      temp-d-card.first-main-card = bf_dis-card.first-main-card
      temp-d-card.main-card = bf_dis-card.main-card
      temp-d-card.first-card = bf_dis-card.first-card
      temp-d-card.card-num = bf_dis-card.card-num
      temp-d-card.emitent-host-code = bf_dis-card.emitent-host-code
      temp-d-card.type              = bf_dis-card.type
      temp-d-card.cli-type          = bf_dis-card.cli-type
      temp-d-card.cli-code          = bf_dis-card.cli-code
      temp-d-card.sale-doc          = bf_trn-doc.doc-code
      temp-d-card.sale-type         = {&table_trn-doc}
      temp-d-card.doc-date          = bf_trn-doc.doc-date
      temp-d-card.action            = par-sign
      temp-d-card.obj-type          = bf_trn-doc.obj-type
      temp-d-card.obj-code          = bf_trn-doc.obj-code
      temp-d-card.host-code          = bf_trn-doc.host-code
      .
      { str/trndc.i def }
      { str/trndc.i }
      release temp-d-card.
    end.
    when {&dct-proc_batch-card-recalc}
    /*utl/dcpcuq1.p */
    or
    when {&dct-proc_one-card-check}
    then do:
      /*ref/dcardi.w*/
      if g#db-num <> 0 then do:
        message
        substitute("Нельзя вызывать расчет по ДК в УБД")
        view-as alert-box error .
        undo _main, return error .
      end.
      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      v-obj-type = '':U
      v-obj-code = 0
      v-host-code = 0
      v-doc-type = {&hn-source-recalc}
      v-doc-date = v-today
      v-fact-date = v-today
      cre-pay = 0
      v-emitent-host-code = p-emitent-host-code
      v-type = p-type
      .
      assign
      v-codex-id-list = (if g#db-num = 0
                         then ",2"
                         else '':U)
      v-ruleset-id-list[1] = '':U
      v-ruleset-id-list[2] = string(5)
      v-ruleset-id-list[2] = (if g#db-num = 0 and p-save
                              then (v-ruleset-id-list[2] + {&comma-char} + string(9))
                              else v-ruleset-id-list[2])
      .
      if p-process = {&dct-proc_batch-card-recalc} then do:
        if p-save then v-save-int = 1.
        v-cont-handle = p-parent-handle.
        assign
        log-file-name = "shd-free.log".
        run get-current-d-card in p-parent-handle ( output v-d-card) no-error.
        if error-status:error then do:
          undo, return error
          substitute("Не удалось заблокировать ДК типа &1 для обсчета: "
                    ,p-doc-code)
          .
        end.
        run fill-for-dcpcuq in this-procedure ( input p-doc-code, input v-d-card)  no-error.
        if error-status:error then do:
          undo, return error
          substitute("&1 &2 &3 Ошибка задания входных параметров: не удалось определить ДК типа &1 для обсчета"
                    ,p-doc-code)
          .
        end.
      end.
      if p-process = {&dct-proc_one-card-check} then do:
        v-cont-handle = p-parent-handle.
        v-save-int = - 2.
        run fill-for-dcardi in this-procedure ( input p-doc-code)  no-error.
        if error-status:error then do:
          undo, return error
          substitute("&1 &2 &3Не удалось заблокировать ДК &1 для обсчета"
                    ,p-doc-code)
          .
        end.
      end.
    end.
    when {&dct-proc_text-import}
    or
    when {&dct-proc_sale-xml-import}
    then do:
      /*utl/imp-dcrd.w*/
      /*cus/dctxtisr.p*/
      /*bge/cmdeigen.p*/
      case p-process:
        when {&dct-proc_text-import} then do:
          if g#db-num <> 0  then do:
            message
            substitute("Нельзя импортировать ДК в УБД")
            view-as alert-box error .
            undo _main, return error .
          end.
          assign
          v-codex-id-list = string(4)
          v-ruleset-id-list[1] = string(1)
          v-ruleset-id-list[2] = '':U
          .
          if not g#auto then do:
            { gbl/getcntxt.i get no-error  }
          end.
        end.
        when {&dct-proc_sale-xml-import} then do:
          if p-ruleset-id = 2 then do:
            assign
            v-codex-id-list = '4'
            v-ruleset-id-list[1] = string(2)
            v-ruleset-id-list[2] = ''
            v-ruleset-id-list[3] = ''
            .
          end.
          if p-ruleset-id = 3 then do:
            if g#db-num > 0 then do:
              assign
              v-codex-id-list = '4,1'
              v-ruleset-id-list[1] = string(3)
              v-ruleset-id-list[2] = string(5)
              v-ruleset-id-list[3] = ''
              .
            end.
            else do:
              assign
              v-codex-id-list = '4,1,2'
              v-ruleset-id-list[1] = string(3)
              v-ruleset-id-list[2] = string(5)
              v-ruleset-id-list[3] = string(3) /*string(6) + {&comma-char} + string(5) + {&comma-char} + string(9)*/
              .
            end.
          end.
        end.
      end case.
      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      v-obj-type = v-cntxt-obj-type
      v-obj-code = v-cntxt-obj-code
      v-host-code = v-cntxt-host-code-obj
      v-doc-date = v-today
      v-fact-date = v-today
      v-doc-type = {&hn-source-import}
      v-doc-code = entry(1, p-doc-code, {&delim-par})  /*виртуальный код док-та */
      v-process-file-name =  entry(2, p-doc-code, {&delim-par}) +
                             (if p-process = {&dct-proc_sale-xml-import} /* имя файла*/
                              then ( {&delim-par} + entry(3, p-doc-code, {&delim-par})
                                  + {&delim-par} + entry(4, p-doc-code, {&delim-par}) /*pack-num*/
                                  + {&delim-par} + entry(5, p-doc-code, {&delim-par}) /*log-file-name*/
                              ) /*handle dataset*/
                              else '')
      v-cont-handle = p-parent-handle
      v-param-name = (if p-process = {&dct-proc_sale-xml-import}
                      then entry(6, p-doc-code, {&delim-par})
                      else '')
      v-xsd-file = (if p-process = {&dct-proc_sale-xml-import}
                   then entry(7, p-doc-code, {&delim-par})
                              else '')
      v-emitent-host-code = p-emitent-host-code
      v-type = p-type
      v-profile-id = p-profile-id
      cre-pay = 0
      .
      find first temp-d-card where
                temp-d-card.d-card = '_':U no-error .
      if not available temp-d-card then do:
        create temp-d-card.
      end.
      assign
      temp-d-card.d-card = '_'
      temp-d-card.type = v-type
      temp-d-card.emitent-host-code = v-emitent-host-code
      temp-d-card.sale-type = ''
      .
      release temp-d-card.
    end.
    when {&dct-proc_text-export}
    then do:
      /*cus/dctxtesr.p*/
      if g#db-num <> 0 then do:
        message
        substitute("Нельзя Экспортировать данные по ДК из УБД")
        view-as alert-box error .
        undo _main, return error .
      end.
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
      v-doc-type = {&export}
      v-doc-code = entry(1, p-doc-code, {&delim-par}) /*виртуальный кодщ док-та */
      v-process-file-name =  entry(2, p-doc-code, {&delim-par}) /* имя файла*/
      v-emitent-host-code = p-emitent-host-code
      v-type = p-type
      v-profile-id = p-profile-id
      cre-pay = 0
      .
      assign
      v-codex-id-list = (if g#db-num = 0
                         then "5"
                         else '':U)
      v-ruleset-id-list[1] = string(1)
      v-ruleset-id-list[2] = ''
      .
      find first temp-d-card where
                temp-d-card.d-card = '_':U no-error .
      if not available temp-d-card then do:
        create temp-d-card.
      end.
      assign
      temp-d-card.d-card = '_'
      temp-d-card.type = v-type
      temp-d-card.emitent-host-code = v-emitent-host-code
      temp-d-card.sale-type = {&export}
      .
      release temp-d-card.
    end.
    when {&dct-proc_one-card-add}
    then do:
      /*ref/dcardi01.p*/
      if g#db-num <> 0 then do:
        message
        substitute("Нельзя добавлять ДК в УБД")
        view-as alert-box error .
        undo _main, return error .
      end.
      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      v-obj-type = '':U
      v-obj-code = 0
      v-host-code = 0
      v-doc-type = '':U
      v-doc-date = v-today
      v-fact-date = v-today
      v-doc-code = p-doc-code
      v-process-file-name = '':u
      cre-pay = 0
      .
      assign
      v-codex-id-list = (if g#db-num = 0
                         then ",3"
                         else '':U)
      v-ruleset-id-list[1] = '':U
      v-ruleset-id-list[2] = string(1)
      .
      run fill-for-dcardi in this-procedure ( input p-doc-code)  no-error.
      if error-status:error then do:
        undo, return error
        substitute("&1 &2 &3Не удалось заблокировать ДК &1 для обсчета"
                  ,p-doc-code)
        .
      end.
    end.
    when {&dct-proc_payment-on-card} then do:
       /*ref/paymento.w*/
      if g#db-num <> 0 then do:
        message
        substitute("Нельзя создавать платежи по ДК в УБД")
        view-as alert-box error .
        undo _main, return error .
      end.
      find first buf_payment no-lock where
                buf_payment.pmnt-code = p-doc-code no-error.
      if not available buf_payment then do:
         undo _main, return error substitute("Не найден платеж с номером &1", p-doc-code).
      end.
      if buf_payment.status_ <> {&fact} then do:
        undo _main, return error substitute("Платеж с номером &1 находится в статусе &2"
                                     , p-doc-code
                                     , buf_payment.status_
                                     ).

      end.
      run str/lock-dc.p ( input ? /*p-log-handle*/
                        ,input this-procedure:handle
                        ,input {&table_payment}
                        ,input p-doc-code
                        ,input buf_payment.d-card
                        ,input 1 /*p-step*/
                        ,input no /*is-news*/
                        ,input '':U /*log-file-name*/
                        ,output v-num-dc) no-error.
      if error-status:error then do:
        undo _main, return error substitute( "Не удалось заблокировать ДК &1 для обсчета:&2&3&2&4"
                                            , buf_payment.d-card
                                            , {&new-line}
                                            , return-value
                                            , error-status :get-message (1)).
      end.
      FIND FIRST bf_dis-card WHERE
                bf_dis-card.d-card = buf_payment.d-card NO-LOCK .
      create temp-d-card.
      assign
      temp-d-card.d-card = bf_dis-card.d-card
      temp-d-card.card-num = bf_dis-card.card-num
      temp-d-card.emitent-host-code = bf_dis-card.emitent-host-code
      temp-d-card.type              = bf_dis-card.type
      temp-d-card.cli-type          = bf_dis-card.cli-type
      temp-d-card.cli-code          = bf_dis-card.cli-code
      temp-d-card.pay-tot-base       = buf_payment.tot-base
      temp-d-card.pay-tot-rubl       = buf_payment.tot-rubl
      temp-d-card.sale-type = {&hn-source-payment}
      .
      release temp-d-card.
      assign
      v-doc-date = p-doc-date
      v-fact-date = p-fact-date
      v-doc-code = p-doc-code
      v-process-file-name = '':u
      v-doc-type = {&hn-source-payment}
      v-obj-type = '':U
      v-obj-code = 0
      v-host-code = buf_payment.host-code
      cre-pay = 0
      sign  = par-sign
      .
      assign
      v-codex-id-list = (if g#db-num = 0
                         then ",2"
                         else '':U)
      v-ruleset-id-list[1] = '':U
      v-ruleset-id-list[2] = string(7) + {&comma-char} + string(5)
      v-ruleset-id-list[2] = (if g#db-num = 0
                              then (v-ruleset-id-list[2] + {&comma-char} + string(9))
                              else v-ruleset-id-list[2])
      .
      v-cont-handle = p-parent-handle.
    end.
    when {&dct-proc_fin-doc-on-card}
    or
    when {&dct-proc_delete-fin-doc-from-card}
    then do:
       /*ref/findstat.p*/
       /*trg/findocdl.p*/
      if g#db-num <> 0 then do:
        message
        substitute("Нельзя создавать платежи по ДК в УБД")
        view-as alert-box error .
        undo _main, return error .
      end.
      find first buf_fin-doc no-lock where
                buf_fin-doc.fin-doc-code = integer(p-doc-code) no-error.
      if not available buf_fin-doc then do:
         undo _main, return error substitute("Не найден платеж с номером &1", p-doc-code).
      end.
      for each buf_payment no-lock where
              buf_payment.source-type = {&pmnt-fin-doc}
          and buf_payment.source-ref = string(buf_fin-doc.fin-doc-code)
      on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
      :

        FIND FIRST bf_dis-card WHERE
                  bf_dis-card.d-card = buf_payment.d-card NO-LOCK .
        create temp-d-card.
        assign
        temp-d-card.d-card = bf_dis-card.d-card
        temp-d-card.card-num = bf_dis-card.card-num
        temp-d-card.emitent-host-code = bf_dis-card.emitent-host-code
        temp-d-card.type              = bf_dis-card.type
        temp-d-card.cli-type          = bf_dis-card.cli-type
        temp-d-card.cli-code          = bf_dis-card.cli-code
        temp-d-card.pay-tot-base       = buf_payment.tot-base
        temp-d-card.pay-tot-rubl       = buf_payment.tot-rubl
        temp-d-card.sale-type = {&hn-source-fin-doc}
        .
        assign
        v-doc-date = p-doc-date
        v-fact-date = p-fact-date
        v-doc-code = string(buf_fin-doc.fin-doc-code)
        v-process-file-name = '':u
        v-doc-type = {&hn-source-fin-doc}
        v-obj-type = '':U
        v-obj-code = 0
        v-host-code = buf_fin-doc.host-code
        cre-pay = 0
        sign  = par-sign
        .
        assign
        v-codex-id-list = (if g#db-num = 0
                          then ",2"
                          else '':U)
        v-ruleset-id-list[1] = '':U
        v-ruleset-id-list[2] = string(7) + {&comma-char} + string(5)
        v-ruleset-id-list[2] = (if g#db-num = 0
                              then (v-ruleset-id-list[2] + {&comma-char} + string(9))
                              else v-ruleset-id-list[2])
        .
        v-cont-handle = p-parent-handle.
      end.
    end.
    when ({&dct-proc_stop-list-import} + {&delim-par} + {&add-def})
    or
    when ({&dct-proc_stop-list-import} + {&delim-par} + {&update})
    then do:
      assign
      v-codex-id-list = (if g#db-num = 0
                        then "6"
                        else '':U)
      v-ruleset-id-list[1] = '1':U
      v-ruleset-id-list[2] = '':U
      .
      if entry(2, p-process, {&delim-par}) = {&update} then do:
        if p-save then do:
          do transaction:
          find first buf_stop-list exclusive-lock
            where buf_stop-list.classif-type = {&table_dis-card}
            and buf_stop-list.stop-list-code = entry(1, p-doc-code, {&delim-par} )
            no-error .
        end.
        end.
        else do:
          find first buf_stop-list no-lock
            where buf_stop-list.classif-type = {&table_dis-card}
            and buf_stop-list.stop-list-code = entry(1, p-doc-code, {&delim-par} )
            no-error .
        end.
        if not available buf_stop-list then do:
          undo, return error
          substitute("&1 &2 &3 Ошибка задания входных параметров: не найден стоплист &4"
                    ,vss-workfile
                    ,vss-revision
                    ,vss-description
                    ,entry(3, p-doc-code, {&delim-par} ))
          .
        end.
      end.
      assign
      v-obj-type = (if available buf_stop-list
                    then buf_stop-list.obj-type
                    else '')
      v-obj-code = (if available buf_stop-list
                    then buf_stop-list.obj-code
                    else 0)
      v-doc-date = (if available buf_stop-list
                    then buf_stop-list.doc-date
                    else ?)
      v-fact-date = ?
      v-doc-code = entry(1, p-doc-code, {&delim-par}) /*виртуальный код док-та */
      v-process-file-name = entry(2, p-doc-code, {&delim-par}) /* имя файла*/
      v-profile-id = p-profile-id
      v-emitent-host-code = p-emitent-host-code
      v-type = p-type
      v-doc-type = {&hn-source-stop-l}
      cre-pay = 0
      sign  = par-sign
      .
      if v-obj-code = 0 then do:
        assign
        v-obj-type = v-cntxt-obj-type
        v-obj-code = v-cntxt-obj-code
        .
      end.
      if v-obj-code > 0 then do:
      { gbl/hostcode.i
        v-obj-type
        v-obj-code
        v-host-code
      }
      end.
      find first temp-d-card where
                temp-d-card.d-card = '_':U no-error .
      if not available temp-d-card then do:
        create temp-d-card.
      end.
      assign
      temp-d-card.d-card = '_'
      temp-d-card.type = v-type
      temp-d-card.emitent-host-code = v-emitent-host-code
      temp-d-card.sale-type = {&hn-source-stop-l}
      .
      release temp-d-card.
    end. /*when {&dct-proc_stop-list-import}*/
    otherwise do:
      undo _main, return error substitute("&1 &2 &3&4Ошибка входных параметров процедуры saledc.p&4Невернoе значение p-process = &5"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,{&new-line}
                                          ,p-process
                                           ).
    end.
  END CASE.


  /*начинаем запускать портянку команду куста*/
  if p-save then do:
    if not valid-handle(v-cmd-proc-handle ) then dO:
      /* инициализируем библиотеку формирования команды */
      run nws/cmd-bush.p persistent set v-cmd-proc-handle no-error .
      if error-status :error
      then do:
        delete procedure v-cmd-proc-handle .
        undo _main, return error substitute("&1 &2 &3&4Ошибка при запуске процедуры cmd-bush.p&4" +
                                            "&5&4&6"
                                            ,vss-workfile
                                            ,vss-revision
                                            ,vss-description
                                            ,{&new-line}
                                            ,error-status:get-message(1)
                                            ,return-value ).
      end.
    end.
  end.
  CASE p-process:
    when {&dct-proc_sale-close}
    or
    when {&dct-proc_sale-delete} then do:
      /*str/saleclos.p str/delfsale.p*/
      v-command = {&cmd-process-saledc} + {&delim-cmd} +
                  string(p-step) + {&delim-cmd} +
                  string(g#db-num)             + {&delim-cmd} +
                  buf_inkas.obj-type + {&delim-cmd} +
                  string(buf_inkas.obj-code) + {&delim-cmd} +
                  buf_inkas.inkas-code + {&delim-cmd} +
                  p-process + {&delim-cmd} +
                  {&TDEDT_RAs_Vnesh_Kass} + {&delim-cmd} +
                  string(v-doc-date) + {&delim-cmd} +
                  string(v-fact-date) + {&delim-cmd} +
                  string(par-sign) + {&delim-cmd} +
                  string(cre-pay).
    end.
    when {&dct-proc_trn-doc-close}
    or
    when {&dct-proc_trn-doc-delete} then do:
      /*str/lib-trn.p str/trn-stat.p*/
      v-command = {&cmd-process-saledc} + {&delim-cmd} +
                  string(p-step) + {&delim-cmd} +
                  string(g#db-num)             + {&delim-cmd} +
                  bf_trn-doc.obj-type + {&delim-cmd} +
                  string(bf_trn-doc.obj-code) + {&delim-cmd} +
                  bf_trn-doc.doc-code + {&delim-cmd} +
                  p-process + {&delim-cmd} +
                  bf_trn-doc.ext-doc-type + {&delim-cmd} +
                  string(v-doc-date) + {&delim-cmd} +
                  string((if v-fact-date = ? then v-doc-date else v-fact-date)) + {&delim-cmd} +
                  string(sign) + {&delim-cmd} +
                  string((if cre-pay = ? then 0 else cre-pay)).
    end.
    when {&dct-proc_batch-card-recalc}
    /*utl/dcpcuq1.p */
    or
    when {&dct-proc_one-card-check}
    /*ref/dcardi.w */
    or
    when ({&dct-proc_one-card-add})
    /*ref/dcardi01.p */
    then do:
      v-command = {&cmd-process-saledc} + {&delim-cmd} +
                  string(p-step) + {&delim-cmd} +
                  string(g#db-num)             + {&delim-cmd} +
                  '':U + {&delim-cmd} +
                  string(v-obj-code) + {&delim-cmd} +
                  '':U + {&delim-cmd} +
                  p-process + {&delim-cmd} +
                  '':U + {&delim-cmd} +
                  string(v-doc-date) + {&delim-cmd} +
                  string(v-fact-date) + {&delim-cmd} +
                  string(par-sign) + {&delim-cmd} +
                  string((if cre-pay = ? then 0 else cre-pay)).
    end.
    when {&dct-proc_text-import}
    or
    when {&dct-proc_sale-xml-import}
    then do:
      v-command = {&cmd-process-saledc} + {&delim-cmd} +
                  string(p-step) + {&delim-cmd} +
                  string(g#db-num)             + {&delim-cmd} +
                  v-cntxt-obj-type + {&delim-cmd} +
                  string(v-cntxt-obj-code) + {&delim-cmd} +
                  v-doc-code + {&delim-cmd} +
                  p-process + {&delim-cmd} +
                  '':U + {&delim-cmd} +
                  string(v-doc-date) + {&delim-cmd} +
                  string(v-fact-date) + {&delim-cmd} +
                  string(par-sign) + {&delim-cmd} +
                  string(cre-pay).

    end.
    when {&dct-proc_payment-on-card} then do:
      v-command = {&cmd-process-saledc} + {&delim-cmd} +
                  string(p-step) + {&delim-cmd} +
                  string(g#db-num)             + {&delim-cmd} +
                  '':U + {&delim-cmd} +
                  string(v-obj-code) + {&delim-cmd} +
                  '':U + {&delim-cmd} +
                  p-process + {&delim-cmd} +
                  '':U + {&delim-cmd} +
                  string(v-doc-date) + {&delim-cmd} +
                  string(v-fact-date) + {&delim-cmd} +
                  string(par-sign) + {&delim-cmd} +
                  string(cre-pay).
    end.
    when {&dct-proc_fin-doc-on-card}
    or
    when {&dct-proc_delete-fin-doc-from-card}
    then do:
      v-command = {&cmd-process-saledc} + {&delim-cmd} +
                  string(p-step) + {&delim-cmd} +
                  string(g#db-num)             + {&delim-cmd} +
                  '':U + {&delim-cmd} +
                  string(v-obj-code) + {&delim-cmd} +
                  '':U + {&delim-cmd} +
                  p-process + {&delim-cmd} +
                  '':U + {&delim-cmd} +
                  string(v-doc-date) + {&delim-cmd} +
                  string(v-fact-date) + {&delim-cmd} +
                  string(par-sign) + {&delim-cmd} +
                  string(cre-pay).
    end.
    when {&dct-proc_stop-list-import} + {&delim-par} + {&add-def}
    or
    when {&dct-proc_stop-list-import} + {&delim-par} + {&update} then do:
      v-command = {&cmd-process-saledc} + {&delim-cmd} +
                  string(p-step) + {&delim-cmd} +
                  string(g#db-num)             + {&delim-cmd} +
                  '':U + {&delim-cmd} +
                  string(v-obj-code) + {&delim-cmd} +
                  '':U + {&delim-cmd} +
                  p-process + {&delim-cmd} +
                  '':U + {&delim-cmd} +
                  (if v-doc-date = ? then {&question-mark} else string(v-doc-date)) + {&delim-cmd} +
                  (if v-fact-date = ? then {&question-mark} else string(v-fact-date)) + {&delim-cmd} +
                  string(par-sign) + {&delim-cmd} +
                  string(cre-pay).
    end.
    otherwise do:
    end.
  END CASE.
  run before-command in this-procedure ( buffer buf_temp-cmd ) no-error.
  if error-status:error then do:
        delete procedure v-cmd-proc-handle .
        undo _main, return error substitute("&1 &2 &3&4Ошибка при создании команды &5&4" +
                                            "&6&4&7"
                                            ,vss-workfile
                                            ,vss-revision
                                            ,vss-description
                                            ,{&new-line}
                                            ,{&cmd-process-saledc}
                                            ,error-status:get-message(1)
                                            ,return-value ).
      end.
  for each temp-d-card
  break
  by temp-d-card.emitent-host-code
  by temp-d-card.type
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  :

    if first-of(temp-d-card.type) then do:
      find first buf_dis-card-type SHARE-LOCK /*!!!!!!!!!!!!!!!!!!*/ where
                buf_dis-card-type.type = temp-d-card.type
           and  buf_dis-card-type.emitent-host-code = temp-d-card.emitent-host-code.
      v-dct-uniq-key-rec = buf_dis-card-type.uniq-key-rec.
      if p-save and (not mode-erprn or p-process = {&dct-proc_one-card-add}) then do:
        run create-nws-outline in this-procedure (
                                                   input v-cmd-proc-handle
                                                  ,input buf_temp-cmd.cmd-code
                                                  ,input {&table_dis-card-type}
                                                  ,input v-charkey_one /*p-charkey_one*/
                                                  ,input '':U /*p-charkey_two */
                                                  ,input '':U /*p-charkey_thre */
                                                  ,input 0 /*p-key#_one */
                                                  ,input 0 /*p-key#_two */
                                                  ,input 0 /*p-key#_three */
                                                  ).
         v-charkey_one = v-dct-uniq-key-rec.
       if p-process = {&dct-proc_batch-card-recalc} then do:
         run create-nws-outline in this-procedure (
                                                   input v-cmd-proc-handle
                                                  ,input buf_temp-cmd.cmd-code
                                                  ,input {&table_dis-card}
                                                  ,input v-charkey_one-2 /*p-charkey_one*/
                                                  ,input '':U /*p-charkey_two */
                                                  ,input '':U /*p-charkey_thre */
                                                  ,input 0 /*p-key#_one */
                                                  ,input 0 /*p-key#_two */
                                                  ,input 0 /*p-key#_three */
                                                  ).
          v-charkey_one-2 = temp-d-card.d-card.
        end.
      end. /*if p-save*/
      /*обработать правила по codex_id */
      define buffer buf_rule-process for ub.rule-process.
      _codex:
      do v-jj = 1 to num-entries(v-codex-id-list):
        if entry(v-jj, v-codex-id-list) = '':U then next _codex.

        v-codex-id = integer(entry(v-jj, v-codex-id-list)).
        do v-ii = 1 to num-entries(v-ruleset-id-list[v-jj]):
           if entry(v-ii, v-ruleset-id-list[v-jj]) = '':U then next.
           v-ruleset-id = integer(entry(v-ii, v-ruleset-id-list[v-jj])).
          _rule-by-call:
          for each buf_rule-by-call no-lock where
                    buf_rule-by-call.call_id = v-dct-uniq-key-rec
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
            if p-save then do:
              if not available buf_temp-cmd then do:
                find first buf_temp-cmd use-index pi .
              end.
            end.
            if (
            (p-process = {&dct-proc_text-import}
            or p-process = {&dct-proc_sale-xml-import})
               and v-codex-id = 4
            or (p-process = {&dct-proc_text-export} and v-codex-id = 5)
            or ((p-process = {&dct-proc_stop-list-import} + {&delim-par} + {&add-def}
            or p-process = {&dct-proc_stop-list-import} + {&delim-par} + {&update})
               and v-codex-id = 6
               )
            )
            then do:
              if buf_rule-by-call.profile_id <> v-profile-id then next _rule-by-call.
            end.
            if p-process = {&dct-proc_sale-xml-import}
            and buf_rule-by-call.ruleset_id = 3
            and buf_rule-by-call.codex_id = 4
            then do:
              find first buf_rule-call-param no-lock where
                        buf_rule-call-param.call_id = buf_rule-by-call.call_id
                    and buf_rule-call-param.codex_id = buf_rule-by-call.codex_id
                    and buf_rule-call-param.ruleset_id = buf_rule-by-call.ruleset_id
                    and buf_rule-call-param.order_id = buf_rule-by-call.order_id
                    and buf_rule-call-param.param-name = v-param-name
                    and buf_rule-call-param.param-value-character = v-xsd-file no-error.
              if not available buf_rule-call-param then next _rule-by-call.
              find first buf_rule-call-param no-lock where
                        buf_rule-call-param.call_id = buf_rule-by-call.call_id
                    and buf_rule-call-param.codex_id = buf_rule-by-call.codex_id
                    and buf_rule-call-param.ruleset_id = buf_rule-by-call.ruleset_id
                    and buf_rule-call-param.order_id = buf_rule-by-call.order_id
                    and buf_rule-call-param.param-name = "p-esys-id"
                    and buf_rule-call-param.param-value-integer = int(v-doc-code) no-error.
              if not available buf_rule-call-param then next _rule-by-call.
            end.
            if p-process = {&dct-proc_batch-card-recalc} then do:
              if v-calc-chr <> '*' then do:
                run is-to-calc-algo in p-parent-handle ( input buf_rule-by-call.uniq-key-rec, output v-calc-chr) no-error.
                if error-status:error then do:
                  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
                end.
                if v-calc-chr <> '*':U and logical(v-calc-chr) = no then do:
                  next _rule-by-call.
                end.
&scop my-message substitute("&1&2Выполнение правила &3&2&4"          ~
                            , calldscr(buf_rule-by-call.call_id)     ~
                            ,~{&new-line~}                           ~
                            , buf_rule-by-call.rule_id               ~
                            ,buf_rule-by-call.algo-des)

                 {&display-message}.
              end.
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
                                                                ,input buf_rule-by-call.profile_id
                                                                ,input buf_rule-by-call.is_dynamic
                                                                ,input v-doc-type
                                                                ,input v-host-code
                                                                ,input v-obj-type
                                                                ,input v-obj-code
                                                                ,input v-doc-code
                                                                ,input v-process-file-name
                                                                ,input v-doc-date
                                                                ,input v-fact-date
                                                                ,input v-save-int
                                                                ,input v-curr-r-b
                                                                ,input v-cmd-proc-handle
                                                                ,input (if p-save
                                                                        then buf_temp-cmd.cmd-code
                                                                        else 0)
                                                                ,input temp-d-card.type
                                                                ,input temp-d-card.emitent-host-code
                                                                ,input table temp-d-card
                                                                ) no-error .
            if error-status:error
            then do:
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
            if v-stop-leave-status > '' then do:
              if p-save then  do:
                delete procedure v-cmd-proc-handle .
              end.
              undo _main, return error substitute("&1&2Процесс обработке ДК типа &3 эмитент &4 ПРЕРВАН&2" +
                                                  "&5&2&6"
                                                  ,vss-workfile
                                                  ,{&new-line}
                                                  ,temp-d-card.type
                                                  ,temp-d-card.emitent-host-code
                                                  , error-status:get-message(1)
                                                  , return-value
                                                    ).
            end.
          end. /*for each buf_rule-by-call no-lock where*/
        end. /*do v-ii = 1 to */
      end. /*do v-jj*/
    end. /*if first-of(temp-d-card.type) then do:*/
  end. /*for each temp-d-card*/
  if p-save and (not mode-erprn or p-process = {&dct-proc_one-card-add}) then do:
  find first buf_temp-cmd.
  run after-command in this-procedure ( buffer buf_temp-cmd) no-error.
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error substitute("&1 &2 &3&4Ошибка при отправке в новости команды с кодом &5 &8&4" +
                                              "&6&4&7"
                                              ,vss-workfile
                                              ,vss-revision
                                              ,vss-description
                                              ,{&new-line}
                                              ,v-cmd-code

                                              ,error-status:get-message(1)
                                              ,return-value
                                              ,(if buf_temp-cmd.db-list = '':u then '':u else substitute(" - БД № &1", buf_temp-cmd.db-list))
                                              ).
      end.
    delete procedure v-cmd-proc-handle .
  end.
end. /*_main*/

/*отсылка на кассу если находимся в ГБД
в УБД все это уедет в офис там пересчитается dis-obj - dis-host - dis-card, dis-card  приедет обратно и
отошлется при приеме новостей!!!*/
/*на кассы магазинов ЧУЖИХ фирм не сотсылается - это отсекается в sendclia.p*/

/*просто по ДК не посылаем если не из режима сохранения продажи*/
/*!!!убрал посылку на кассы если xml-import*/
if not p-process = {&dct-proc_sale-xml-import} and (g#db-num = 0 and p-save) AND can-find(first dc-list NO-LOCK)  then do:
  run str/diallog.w (
                  input parparentproc
                , input this-procedure
                , input 'str/sendclia.p':U
                , input(string(g#db-num) + {&delim-par}  + {&delim-par} + "no":U + {&delim-par} + "S":U)
                , input yes /*p-auto-go*/
                , input '':U
                , input 'Отправка информации по клиентским картам на кассу') no-error .
end.

procedure fill-for-dcpcuq :
define input parameter p-doc-code as character no-undo .
define input parameter p-d-card as character no-undo .

define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-num-dc as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-create-chr as character no-undo .
define variable v-current-d-card as character no-undo .
define buffer buf_dis-card for ub.dis-card.
define buffer buf_dis-card-type for ub.dis-card-type.
main-block:
do
on error undo, return error
:
  run gen-row-keyr in this-procedure
    ( input p-doc-code
     ,input ?
     ,input "ub"
     ,input ?
     ,input NO-LOCK
     ,output v-tbl-row
     ,output v-tbl-name
    ) no-error.
  find first buf_Dis-card-type no-lock where
            rowid(buf_dis-card-type) = v-tbl-row no-error.
  if not available buf_dis-card-type then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден ТИП ДК" p-doc-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  _dis-card:
  for each buf_dis-card no-lock where
          buf_dis-card.type              =  buf_Dis-card-type.type
      and buf_dis-card.emitent-host-code =  buf_dis-card-type.emitent-host-code
      and buf_dis-card.d-card > p-d-card
  by buf_dis-card.d-card
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :

    if v-create-chr <> '*':U then do:
      run is-to-create-d-card in p-parent-handle ( input buf_dis-card.d-card, output v-create-chr) no-error.
      if error-status:error then do:
        undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
      end.
      if v-create-chr = "*"  then do:
        assign
        v-dc-list-mode = "*".
      end.
      else if v-create-chr = 'no' then do:
        v-create-chr = '':U.
        next _dis-card.
      end.
    end.
    v-ii = v-ii + 1.
    create temp-d-card.
    buffer-copy buf_dis-card to temp-d-card
    assign
    temp-d-card.sale-type = {&hn-source-recalc}
    v-current-d-card = buf_dis-card.d-card.
    if v-ii = 50 then do:
      run set-current-d-card in p-parent-handle  ( input temp-d-card.d-card).
      release temp-d-card.
      leave _dis-card.
    end.
  end.
  run str/lock-dc.p ( input ? /*p-log-handle*/
                    ,input this-procedure:handle
                    ,input {&table_dis-card-type}
                    ,input p-doc-code
                    ,input p-d-card
                    ,input 1 /*p-step*/
                    ,input no /*is-news*/
                    ,input '':U /*log-file-name*/
                    ,output v-num-dc) no-error.
  if error-status:error then do:
    undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  find first buf_Dis-card no-lock where
            buf_Dis-card.type = buf_dis-card-type.type
        and buf_Dis-card.emitent-host-code = buf_dis-card-type.emitent-host-code
        and buf_Dis-card.d-card > v-current-d-card no-error.
  if not available buf_Dis-card then do:
    run set-current-d-card in p-parent-handle  ( input "z").
  end.
end.


end procedure. /* fill-for-dcpcuq */

procedure fill-for-dcardi :
define input parameter p-d-card as character no-undo .

define buffer buf_dis-card for ub.dis-card.
define variable v-num-dc as integer no-undo .

main-block:
do
on error undo, return error
:
  find first buf_dis-card no-lock where
       buf_dis-card.d-card = p-d-card no-error.
  if not available buf_dis-card then do:
     return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  if p-process = {&dct-proc_one-card-check} then do:
    create temp-d-card.
    buffer-copy buf_dis-card
    except type
    emitent-host-code
    to temp-d-card
    assign
    temp-d-card.type = v-type
    temp-d-card.emitent-host-code = v-emitent-host-code
    temp-d-card.sale-type = {&hn-source-recalc}
    .
  end.
  if p-process = {&dct-proc_one-card-add} then do:
    create temp-d-card.
    buffer-copy buf_dis-card
    to temp-d-card
    assign
    temp-d-card.sale-type = {&hn-source-recalc}
    .
  end.
  run str/lock-dc.p ( input ? /*p-log-handle*/
                    ,input this-procedure:handle
                    ,input {&table_dis-card}
                    ,input p-doc-code
                    ,input temp-d-card.d-card
                    ,input 1 /*p-step*/
                    ,input no /*is-news*/
                    ,input '':U /*log-file-name*/
                    ,output v-num-dc) no-error.
  if error-status:error then do:
    undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  release temp-d-card.
end.
end procedure. /* fill-for-dcardi */


procedure is-to-lock-d-card :
/*не удалять вызываются через callback*/
define input parameter p-d-card as character no-undo .
define output parameter p-lock-chr as character no-undo .

do
on error undo, return error
:
  if v-dc-list-mode = "*":U then do:
    p-lock-chr = "*".
  end.
  else do:
    find first temp-d-card no-lock where
              temp-d-card.d-card = p-d-card no-error.
    if not available temp-d-card then do:
      p-lock-chr = string(no).
    end.
    else do:
      p-lock-chr = string(yes).
    end.
  end.
end.
end procedure. /* is-to-lock-d-card */

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

procedure create-temp-d-card :
/*не удалять вызываются через callback*/
define input parameter p-bh as handle no-undo .
define variable glog as logical no-undo .
define variable v-num-dc as integer no-undo .
define buffer buf_temp-d-card for temp-d-card.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
    find first buf_temp-d-card where
            buf_temp-d-card.d-card = p-bh::d-card
        and buf_temp-d-card.obj-type = p-bh::obj-type
        and buf_temp-d-card.obj-code = p-bh::obj-code no-error .
    if not available buf_temp-d-card then do:
      create buf_temp-d-card.
      glog = buffer buf_temp-d-card:handle:buffer-copy( p-bh) no-error .
      if error-status:error
      or not glog
      then do:
        undo main-block, return error substitute("&1&2&3"
                                                 , error-status:get-message(1)
                                                 , {&new-line}
                                                 , return-value ).
      end.
      run str/lock-dc.p ( input ? /*p-log-handle*/
                        ,input this-procedure:handle
                        ,input {&table_dis-card}
                        ,input buf_temp-d-card.d-card
                        ,input '':U
                        ,input 1 /*p-step*/
                        ,input no /*is-news*/
                        ,input '':U /*log-file-name*/
                        ,output v-num-dc) no-error.
      if error-status:error then do:
        undo main-block, return error substitute("&1&2&3"
                                                 , error-status:get-message(1)
                                                 , {&new-line}
                                                 , return-value ).
      end.
    end.
end.
end procedure. /* create-temp-d-card */

procedure reset-context :
/*не удалять вызываются через callback*/
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-doc-date as date no-undo .
define input parameter p-doc-type as character no-undo .

do
on error undo, return error
:

  assign
  v-obj-type = p-obj-type
  v-obj-code = p-obj-code
  v-doc-date = p-doc-date
  v-fact-date = v-today
  v-doc-type = p-doc-type
  v-doc-code = p-doc-code
  .
  if v-obj-type = {&shop}
  or v-obj-type = {&stock} then do:
    { gbl/hostcode.i v-obj-type v-obj-code v-host-code }
  end.
end.

end procedure. /* reset-context */

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

procedure before-command :
define parameter buffer buf_temp-cmd for temp-cmd.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  for each buf_temp-cmd:
    delete buf_temp-cmd.
  end.
  for each buf_temp-smart-route:
    delete buf_temp-smart-route.
  end.
  for each buf_temp-smart-link:
    delete buf_temp-smart-link.
  end.
  for each buf_temp-nws-outline:
    delete buf_temp-nws-outline.
  end.
  for each buf_temp-no-route:
    delete buf_temp-no-route.
  end.

  if p-save then do:
    if g#db-num = 0 then do:
      create buf_temp-cmd.
      assign
      buf_temp-cmd.db-list = string( -1)
      .
      for each buf_db no-lock:
        if buf_db.db-num = 0 then next.
        create buf_temp-cmd.
        assign
        buf_temp-cmd.db-list = string(buf_db.db-num)
        .
      end.
    end.
    else do:
      create buf_temp-cmd.
      assign
      buf_temp-cmd.db-list = string(0)
      .
    end.
    for each buf_temp-cmd:
      run begin-create-command in v-cmd-proc-handle
        (input  v-command /* p-command-name */
        ,INPUT  buf_temp-cmd.db-list
        ,output buf_temp-cmd.cmd-code                 /* p-command-code */
        ) no-error.
      if error-status :error
      then do:
        undo,  return error substitute("&1 &2 &3&4Ошибка при создании команды &5&4" +
                                            "&6&4&7"
                                            ,vss-workfile
                                            ,vss-revision
                                            ,vss-description
                                            ,{&new-line}
                                            ,{&cmd-process-saledc}
                                            ,error-status:get-message(1)
                                            ,return-value ).
      end.
    end.
    /*для g#db-num = 0 найдем виртуальную бд -1 для g#db=num > 0 найдем БД 0 */
    find first buf_temp-cmd use-index pi.
  end.
end.
end procedure. /* before-command */


procedure after-command :
define parameter buffer buf_temp-cmd for temp-cmd.
_main:
do transaction
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:


if p-save and (not mode-erprn or p-process = {&dct-proc_one-card-add}) then do:
  /*пустышка разделитель*/
  run create-nws-outline in this-procedure (
                                              input v-cmd-proc-handle
                                            ,input buf_temp-cmd.cmd-code
                                            ,input {&table_dis-card-type}  /*outline-type*/
                                            ,input v-charkey_one /*p-charkey_one*/
                                            ,input '':U /*p-charkey_two */
                                            ,input '':U /*p-charkey_thre */
                                            ,input 0 /*p-key#_one */
                                            ,input 0 /*p-key#_two */
                                            ,input 0 /*p-key#_three */
                                            ).

end.
if {&run-persistent} then do:
  run perproc-delete-from-parent  in this-procedure (
                                                      input this-procedure:handle
                                                      ,input '':U /*p-proc-name */ ).
end.
if p-save and (not mode-erprn or p-process = {&dct-proc_one-card-add}) then do:
  if g#db-num = 0 then do:
    find first buf1_temp-cmd where buf1_temp-cmd.db-list = string(-1).
  end.
  _temp-cmd:
  for each buf_temp-cmd
  on error undo _main, return error :
    if buf_temp-cmd.db-list = string(-1) then next _temp-cmd.
    if g#db-num = 0 then do:
      for each buf_temp-smart-link ,
      first buf_temp-smart-route
      where buf_temp-smart-route.key-field = buf_temp-smart-link.key-field
        and (buf_temp-smart-link.is-smart = no
              or buf_temp-smart-route.db-num = integer(buf_temp-cmd.db-list))
      by buf_temp-smart-link.rec-ord:
        find first buf_temp-no-route where
                    buf_temp-no-route.db-num = integer(buf_temp-cmd.db-list)
                and buf_temp-no-route.rec-ord = buf_temp-smart-link.rec-ord no-error .
        if not available buf_temp-no-route then do:
          &scop cmd-proc-handle v-cmd-proc-handle
          &scop src-cmd-code buf1_temp-cmd.cmd-code
          &scop trg-cmd-code buf_temp-cmd.cmd-code
          &scop uniq-key-rec buf_temp-smart-link.uniq-key-rec
          &scop rec-ord buf_temp-smart-link.rec-ord
          {&copy-dump}.
        end.
        else do:
          delete buf_temp-no-route.
        end.
      end.
      for each buf_temp-smart-route where
              buf_temp-smart-route.db-num = integer(buf_temp-cmd.db-list):
        delete buf_temp-smart-route.
      end. /*for each buf_temp-smart-route where*/
      v-is-empty = no.
      /*
      run is-almost-empty in v-cmd-proc-handle ( input buf_temp-cmd.cmd-code
                                        ,output v-is-empty) no-error.
      if v-is-empty then do:
        run delete-command in v-cmd-proc-handle ( input buf_temp-cmd.cmd-code ). /* p-command-code */
      end.
      */
    end. /*if g#db-num = 0 then do:*/
    if not v-is-empty then do:
      run send-command in v-cmd-proc-handle
        ( input buf_temp-cmd.cmd-code  /* p-command-code */
          ,input buf_temp-cmd.db-list
          ) no-error .

      if error-status :error then do:
        undo _main, return error substitute("&1 &2 &3&4Ошибка при отправке в новости команды с кодом &5 &8&4" +
                                            "&6&4&7"
                                            ,vss-workfile
                                            ,vss-revision
                                            ,vss-description
                                            ,{&new-line}
                                            ,v-cmd-code
                                            ,error-status:get-message(1)
                                            ,return-value
                                            ,(if buf_temp-cmd.db-list = '':u then '':u else substitute(" - БД № &1", buf_temp-cmd.db-list))
                                            ).
      end. /*if error-status :error then do:*/
    end.
  end. /*for each buf_temp-cmd*/
end. /*if p-save*/
end.
end procedure. /* after-command */


procedure cb_create-dc-list :
define input parameter p-bh as handle no-undo .
define variable v-dch as handle no-undo .

  do
  on error undo, return error return-value
  :
    if not g#news then do:
      find first dc-list where
                dc-list.d-card = p-bh::d-card no-error .
      if not available dc-list then do:
        create dc-list.
      end.
      v-dch = buffer dc-list:handle.
      v-dch:buffer-copy(p-bh).
      v-dch:buffer-release().
    end.
  end.

end procedure. /* cb_create-dc-list */