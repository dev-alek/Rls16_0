block-level on error undo, throw.
/*

$Revision: 8f531171ff56, 1872, rls $
$Author: SSlivenko $
$Date: Thu May 16 15:50:49 2019 +0300 $
$Workfile: cmdp-dc.p $
$Archive: nws/cmdp-dc.p $

Обработка команды изменения данных по ДК по документу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/04/06
Author: Bakhtadze Natalya
Creation date: 11/04/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input  parameter p-imp-handle as handle    no-undo .
define input  parameter p-counter  as integer   no-undo .
define input  parameter p-step     as integer   no-undo .
define input  parameter p-source-db-num as integer no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer no-undo .
define input  parameter p-cmd-doc-code as character no-undo .
define input  parameter p-cmd-doc-type as character no-undo .
define input  parameter p-ext-doc-type as character no-undo .
define input  parameter p-doc-date as date no-undo .
define input  parameter p-fact-date as date no-undo .
define input  parameter p-sign     as integer no-undo .
define input  parameter cre-pay    as integer no-undo .
define input  parameter p-cmd-name as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 8f531171ff56, 1872, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Thu May 16 15:50:49 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cmdp-dc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/cmdp-dc.p $":U .
define variable vss-description as character no-undo init "Обработка команды изменения данных по ДК по документу".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,p-counter)" }
{ cmp/trg-def.i  }
{ cmp/dc-list.i  dc-list  def "shared" }
{ cmp/dcp-list.i  dcp-list  def "shared" }
{ gbl/perproc.i " " 100 }
{ nws/lib-nws.i }
{ nws/temp-cmd.i "NEW SHARED" }
define buffer buf_temp-cmd  for temp-cmd.
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ str/saledcdf.i "NEW SHARED" }
{ str/vchk-pay.i "NEW SHARED" }
{ rul/cl-hist.i "new shared" }
{ rep/r-sale.i }
{ rep/r-cost.i }
{ rul/tempcxml.i "shared" }
{ str/trdcalib.i }


define buffer buf_temp-d-card for temp-d-card.
{ gbl/key-rec.i }
define variable v-cmd-proc-handle as handle no-undo .
define variable p-doc-type as character no-undo .
define variable p-doc-code as character no-undo .
&scop cmd-proc-handle v-cmd-proc-handle
&scop cmd-code buf_temp-cmd.cmd-code

define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define temp-table temp-dis-obj no-undo like ub.dis-obj.
define buffer buf_dis-obj for ub.dis-obj.
define buffer buf_temp-dis-obj  for temp-dis-obj.
{ trg/dis-objh.i rul }
define temp-table temp-dis-host no-undo like ub.dis-host.
define buffer buf_dis-host for ub.dis-host.
define buffer buf_temp-dis-host  for temp-dis-host.
{ trg/dis-hsth.i rul }
define temp-table temp-dis-card no-undo like ub.dis-card.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_temp-dis-card  for temp-dis-card.
{ trg/discardh.i rul }
define temp-table temp-dis-card-property no-undo like ub.dis-card-property.
define buffer buf_dis-card-property for ub.dis-card-property.
define buffer buf_temp-dis-card-property  for temp-dis-card-property.
{ trg/disproph.i rul }
define temp-table temp-clients no-undo like ub.clients.
define buffer buf_clients for ub.clients.
define buffer buf_temp-clients  for temp-clients.
define temp-table temp-firm no-undo like ub.firm.
define buffer buf_firm for ub.firm.
define buffer buf_temp-firm  for temp-firm.
define temp-table temp-person no-undo like ub.person.
define buffer buf_person for ub.person.
define buffer buf_temp-person  for temp-person.
{ trg/clientsh.i rul }

define temp-table temp-prop-ref no-undo like ub.prop-ref.
define buffer buf_temp-xml-tables for temp-xml-tables.
define variable counter    as integer   no-undo .
define variable rec-full   as character no-undo .
define variable v-rec-name as character no-undo .
define variable v-today    as date      no-undo .
define variable v-time     as integer   no-undo .
define variable v-step     as integer   no-undo .
define variable v-proc-name as character no-undo .
define variable v-db-list     as character no-undo .
define variable v-command     as character no-undo .
define variable v-cmd-code    as integer no-undo .
define variable log-file-name as character no-undo .
define variable v-num-dc      as integer no-undo .
define variable v-doc-code as character no-undo .
define variable v-process-file-name as character no-undo .
define variable v-ruleset_id as integer no-undo .
define variable v-ruleset_id-list as character no-undo .
define variable v-codex_id as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-call-id as character no-undo .
define variable v-type as character no-undo .
define variable v-emitent-host-code as integer no-undo .
define variable v-proc-handle as handle no-undo .
define variable v-id as integer no-undo .
define variable v-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-h-action as integer no-undo .
define variable v-doc-type as character no-undo .
define variable v-temp-d-card-mode as logical no-undo .
define variable type# as character no-undo .
define variable emitent-host-code# as integer no-undo .
define variable dtm-code# as integer no-undo .
define variable v-save-int as integer no-undo .
define variable v-nws-to-cd as integer   no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-curr-rowid as rowid no-undo .
define variable sign as integer no-undo .
define variable v-stop-leave-status as character no-undo .
define variable v-is-empty as logical no-undo .

define buffer buf_db for ub.db.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_temp-pers-proc  for temp-pers-proc.

define buffer buf_Inkas for ub.inkas.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_ret-doc for ub.trn-doc.
define buffer buf_curr-shop for ub.curr-shop.
define buffer buf_Doc-line for ub.doc-line.
define buffer bf_trn-doc for ub.trn-doc.
define buffer buf_dis-card-type for ub.dis-card-type.

define buffer buf1_temp-cmd  for temp-cmd.
define buffer buf_temp-smart-route  for temp-smart-route.
define buffer buf_temp-smart-link  for temp-smart-link.
define buffer buf_temp-nws-outline for temp-nws-outline.
define buffer buf_temp-no-route  for temp-no-route.

define variable conf-par as character no-undo.
define variable mode-erprn as logical no-undo.
define variable par-type as character no-undo.


&scop sign sign *

&scop run-persistent no
&scop verify-d-card ~
          run proc-verify-d-card in this-procedure (  ~
                                                     input entry(1, v-rec-name, ~{&delim-par~}) ~
                                                     ,input ~{&d-card~} ~
                                                     ,input  ~{&dt-code~} ~
                                                     ,output type#     ~
                                                     ,output emitent-host-code#  ~
                                                     ,output dtm-code#) no-error . ~
          if error-status:error then do: ~
            delete procedure v-cmd-proc-handle . ~
            undo _main, return error return-value .  ~
          end


_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
 /*страховка*/
  if p-step > 3
  or p-step = 3 and g#db-num > 0 then return.
  
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

  file-info:filename = "cmdp-dc.log".
  if file-info:full-pathname <> ? then do:
    assign
    log-file-name = "cmdp-dc.log".
  end.
  if (p-step = 2
     and
     g#db-num = 0)
  or p-step = 3 then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Прием в БД &1 подтверждения получения данных по ДК в БД &2: &3 &4&5"
                          , g#db-num
                          , g#news-source-db
                          , p-cmd-doc-code
                          , p-obj-type
                          , (if p-obj-code > 0 then string(p-obj-code) else '':U))) no-error .

  end.
  else do:
&scop dct-proc-code p-cmd-doc-type
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Получение данных по ДК из БД &1: &2 &3 &4&5"
                          , g#news-source-db
                          , {&dct-proc-name}
                          , p-cmd-doc-code
                          , p-obj-type
                          , (if p-obj-code > 0 then string(p-obj-code) else '':U))) no-error .
  end.

  for each temp-d-card:
    delete temp-d-card.
  end.
  for each temp-hist-nws-option:
    delete temp-hist-nws-option.
  end.
  for each temp-dis-obj:
    delete temp-dis-obj.
  end.
  for each temp-dis-host:
    delete temp-dis-host.
  end.
  for each temp-dis-card:
    delete temp-dis-card.
  end.
  for each temp-dis-card-property:
    delete temp-dis-card-property.
  end.
  for each temp-prop-ref:
    delete temp-prop-ref.
  end.
  for each temp-clients:
    delete temp-clients.
  end.
  for each temp-firm:
    delete temp-firm.
  end.
  for each temp-person:
    delete temp-person.
  end.
  assign
  v-current-obj-type = p-obj-type
  v-current-obj-code = p-obj-code
  .
  if not (p-cmd-doc-type = {&dct-proc_batch-card-recalc}
          or
          p-cmd-doc-type = {&dct-proc_one-card-check}
          or
          p-cmd-doc-type = {&dct-proc_one-card-add}
          or
          p-cmd-doc-type = {&dct-proc_sale-xml-import}
          or
          p-cmd-doc-type = {&dct-proc_payment-on-card}
          or
          p-cmd-doc-type = {&dct-proc_fin-doc-on-card}
          or
          p-cmd-doc-type = {&dct-proc_delete-fin-doc-from-card}
          or
          p-cmd-doc-type = ({&dct-proc_stop-list-import} + {&delim-par} + {&add-def})
          or
          p-cmd-doc-type = ({&dct-proc_stop-list-import} + {&delim-par} + {&update})
          ) then do:
    { gbl/hostcode.i v-current-obj-type v-current-obj-code v-host-code }
  end.
  if p-cmd-doc-type <> {&dct-proc_batch-card-recalc} then do:
    if g#db-num = 0
    and p-step = 1 then do:
      define variable v-lock-dc-type as character no-undo .
      case p-cmd-doc-type:
        when {&dct-proc_sale-close}
        or
        when {&dct-proc_sale-delete}
        then do:
           v-lock-dc-type = {&table_inkas}.
        end.
        when {&dct-proc_trn-doc-close}
        or
        when {&dct-proc_trn-doc-delete}
        then do:
           v-lock-dc-type = {&table_trn-doc}.
        end.
        when {&dct-proc_one-card-recalc}
        or
        when {&dct-proc_one-card-add}
        then do:
          v-lock-dc-type = {&table_dis-card}.
        end.
      end case.
      run str/lock-dc.p (
                    input p-log-handle
                    ,input this-procedure:handle
                    ,input v-lock-dc-type
                    ,input p-cmd-doc-code
                    ,input '':U
                    ,input p-step
                    ,input g#news
                    ,input log-file-name
                    ,output v-num-dc
                    ) no-error.
      if error-status:error then do:
        undo _main, return error substitute("&1 &2 &3&4Ошибка при блокировании ДК по документу &7&4" +
                                          "&5&4&6"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,{&new-line}
                                          ,error-status:get-message(1)
                                          ,return-value
                                          ,p-cmd-doc-code
                                          ).
      end.
    end.
  end.
  define variable v-base-code as integer   no-undo .
  if v-host-code > 0 then do:
    { gbl/basecode.i
      v-host-code
      v-base-code
    }
  end.
  define variable v-curr-r-b as character no-undo .
  { gbl/curr-r-b.i
    v-curr-r-b
  }
  v-cntxt-db-num = g#db-num.
  case p-cmd-doc-type:
    when {&dct-proc_sale-close}
    or
    when {&dct-proc_sale-delete}
    then do:
      if g#db-num = 0
      and p-step = 1 then do:
        { str/saledc.i def }
        find first buf_inkas exclusive-lock
          where buf_inkas.inkas-code = p-cmd-doc-code
          no-error .
        if not available buf_inkas then do:
          undo, return error
          substitute("&1 &2 &3 Ошибка задания входных параметров: не найдена продажа &4"
                    ,vss-workfile
                    ,vss-revision
                    ,vss-description
                    ,p-cmd-doc-code)
          .
        end.
        find first buf_trn-doc no-lock where
                  buf_trn-doc.doc-code = p-cmd-doc-code no-error .
        if not available buf_trn-doc then do:
          undo , return error substitute("Не найден документ с номером &1", p-cmd-doc-code).
        end.

        find first buf_ret-doc no-lock where
                  buf_ret-doc.doc-code = buf_trn-doc.out-code no-error .
        if available buf_ret-doc then do:
          ret-doc-code = buf_ret-doc.doc-code.
        end.
        else do:
          ret-doc-code = '':U.
        end.
      end.
      assign
      sign = p-sign
      v-doc-type = {&hn-source-trn-doc}
      p-doc-type = {&hn-source-trn-doc}
      v-doc-code = p-cmd-doc-code
      v-process-file-name = '':U
      p-doc-code = p-cmd-doc-code
      .
      assign
      v-ruleset_id =  (if p-sign = 1
                      then 1
                      else 2)
      v-codex_id = 2
      v-ruleset_id-list = (if g#db-num = 0 and p-step = 1
                          then (string(v-ruleset_id) + {&comma-char} + string(9))
                          else '':U)
      /*в УБД просто кладем*/
      .
      /*
      if g#db-num = 0
      and p-step = 1 then do:
        { str/saledc.i obj }
      end.
      */
    end. /*whne {&dct-proc_sale-close}*/
    when {&dct-proc_trn-doc-close}
    or
    when {&dct-proc_trn-doc-delete}
    then do:
      if g#db-num = 0
      and p-step = 1 then do:
        { str/trndc.i def }
        find first bf_trn-doc no-lock where
                  bf_trn-doc.doc-code = p-cmd-doc-code no-error .
        if not available bf_trn-doc then do:
          undo , return error substitute("Не найден документ с номером &1", p-cmd-doc-code).
        end.
        FIND FIRST buf_dis-card WHERE
                  buf_dis-card.d-card = bf_trn-doc.d-card NO-LOCK .
      end.
      assign
      v-doc-type = {&hn-source-trn-doc}
      p-doc-type = {&hn-source-trn-doc}
      v-doc-code = p-cmd-doc-code
      v-process-file-name = '':U
      p-doc-code = p-cmd-doc-code
      sign  = p-sign
      .
      assign
      v-ruleset_id = (if p-sign = 1
                      then 3
                      else 4)
      v-codex_id = 2
      v-ruleset_id-list = (if g#db-num = 0 and p-step = 1
                          then (string(v-ruleset_id)  + {&comma-char} + string(9))
                          else '':U)
      /*в УБД просто кладем*/
      .
      /*
      if g#db-num = 0
      and p-step = 1 then do:
        { str/trndc.i }
        release temp-d-card.
      end.
      */
    end. /*when {&table_trn-doc}*/
    when {&dct-proc_batch-card-recalc}
    or
    when {&dct-proc_one-card-check}
    then do:
      assign
      v-doc-type = {&hn-source-recalc}
      p-doc-type = {&hn-source-recalc}
      v-doc-code = '':U
      v-process-file-name = '':U
      p-doc-code = '':U
      v-ruleset_id-list = '':U
      sign = p-sign
      .
      /*только прием данных*/
    end.
    when {&dct-proc_text-import}
    then do:
      assign
      v-doc-type = {&hn-source-import}
      p-doc-type = {&hn-source-import}
      v-doc-code = p-cmd-doc-code
      v-process-file-name = '':U
      p-doc-code = p-cmd-doc-code
      /*только прием данных*/
      v-ruleset_id-list = '':U
      sign = p-sign
      .
    end.
    when {&dct-proc_sale-xml-import}
    then do:
      assign
      v-doc-type = {&hn-source-import}
      p-doc-type = {&hn-source-import}
      v-doc-code = p-cmd-doc-code
      v-process-file-name = '':U
      p-doc-code = p-cmd-doc-code
      v-codex_id = (if g#db-num = 0 and p-step = 1
                    then 2
                    else 0)
      v-ruleset_id-list = (if g#db-num = 0 and p-step = 1
                          then (string(6)  + {&comma-char} + string(5) + {&comma-char} + string(9))
                          else '':U)
      sign = p-sign
      .
    end.
    when {&dct-proc_one-card-add} then do:
      assign
      v-doc-type = '':U
      p-doc-type = '':U
      v-doc-code = p-cmd-doc-code
      v-process-file-name = '':U
      p-doc-code = p-cmd-doc-code
      /*только прием данных*/
      v-ruleset_id-list = '':U
      sign = p-sign
      .
    end.
    when {&dct-proc_payment-on-card} then do:
      assign
      v-doc-type = {&hn-source-payment}
      p-doc-type = {&hn-source-payment}
      v-doc-code = p-cmd-doc-code
      v-process-file-name = '':U
      p-doc-code = p-cmd-doc-code
      /*только прием данных*/
      v-ruleset_id-list = '':U
      sign = p-sign
      .
    end.
    when {&dct-proc_fin-doc-on-card}
    or
    when {&dct-proc_delete-fin-doc-from-card}
    then do:
      assign
      v-doc-type = {&hn-source-payment}
      p-doc-type = {&hn-source-payment}
      v-doc-code = p-cmd-doc-code
      v-process-file-name = '':U
      p-doc-code = p-cmd-doc-code
      /*только прием данных*/
      v-ruleset_id-list = '':U
      sign = p-sign
      .
    end.
    when ({&dct-proc_stop-list-import} + {&delim-par} +  {&add-def})
    or
    when ({&dct-proc_stop-list-import} + {&delim-par} +  {&update})
    then do:
      assign
      v-doc-type = {&hn-source-stop-l}
      p-doc-type = {&hn-source-stop-l}
      v-doc-code = p-cmd-doc-code
      v-process-file-name = '':U
      p-doc-code = p-cmd-doc-code
      /*только прием данных*/
      v-ruleset_id-list = '':U
      sign = p-sign
      .
    end.
    otherwise do:
      undo _main, return error substitute("&1 &2 &3&4Ошибка входных параметров процедуры cmdp-dc.p&4Невернoе значение p-cmd-doc-type = &5"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,{&new-line}
                                          ,p-cmd-doc-type
                                          ).
    end.
  end case.
  if p-step < 2
  or g#db-num > 0 /*все остальное отсекли выше*/
  then do:
    v-step = p-step + 1.
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
    for each buf_temp-cmd:
      delete buf_temp-cmd.
    end.
    for each buf_temp-smart-route:
      delete buf_temp-smart-route.
    end.
    for each buf_temp-smart-link:
      delete buf_temp-smart-link.
    end.
    for each buf_temp-no-route:
      delete buf_temp-no-route.
    end.
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
    define variable v-ii as integer no-undo .
    v-command = {&cmd-process-saledc} + {&delim-cmd} +
                string(v-step) + {&delim-cmd} +
                string(p-source-db-num)             + {&delim-cmd} +
                p-obj-type + {&delim-cmd} +
                string(p-obj-code) + {&delim-cmd} +
                p-cmd-doc-code + {&delim-cmd} +
                p-cmd-doc-type + {&delim-cmd} +
                p-ext-doc-type + {&delim-cmd} +
                (if p-doc-date = ? then {&question-mark} else string(p-doc-date)) + {&delim-cmd} +
                (if p-fact-date = ? then {&question-mark} else string(p-fact-date)) + {&delim-cmd} +
                string(p-sign) + {&delim-cmd} +
                string(cre-pay).

    for each buf_temp-cmd:
      run begin-create-command in v-cmd-proc-handle
        (input  v-command /* p-command-name */
        ,INPUT  buf_temp-cmd.db-list
        ,output buf_temp-cmd.cmd-code                 /* p-command-code */
        ) no-error.
      if error-status :error
      then do:
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
      end. /*if error-status :error*/
    end. /*for each buf_temp-cmd:*/
    /*для g#db-num = 0 найдем виртуальную бд -1 для g#db=num > 0 найдем БД 0 */
    find first buf_temp-cmd use-index pi.

  end. /*if p-step < 2*/

  do counter = 1 to p-counter
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
  :

    if counter modulo 10 = 0
    then do:
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Получено записей &1", counter)) no-error.
    end.
    run nws-imps in p-imp-handle
      ( input-output counter
       ,output       rec-full
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    assign
      v-rec-name = entry( 1, rec-full, {&delim-nws} )
    .
    /*принимаем все*/
    CASE entry(1, v-rec-name, {&delim-par}) :
      when {&table_nws-outline} then do:
        /*начало секции*/
        create buf_temp-nws-outline .
        run nws-impl-without-check in p-imp-handle
          ( input (buffer buf_temp-nws-outline:handle)
          ) no-error.
        if error-status :error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error return-value .
        end.
        if g#db-num = 0 and p-step = 1 then do:
          if buf_temp-nws-outline.outline-type = {&table_dis-card}
          then do:
            if p-cmd-doc-type = {&dct-proc_batch-card-recalc}
            and p-step = 1
            then do:
              run str/lock-dc.p (
                            input p-log-handle
                            ,input this-procedure:handle
                            ,input p-cmd-doc-type
                            ,input p-cmd-doc-code
                            ,input buf_temp-nws-outline.charkey_one
                            ,input p-step
                            ,input g#news
                            ,input log-file-name
                            ,output v-num-dc
                            ) no-error.
              if error-status:error then do:
                delete procedure v-cmd-proc-handle .
                undo _main, return error substitute("&1 &2 &3&4Ошибка при блокировании ДК по документу &7&4" +
                                                  "&5&4&6&4&7"
                                                  ,vss-workfile
                                                  ,vss-revision
                                                  ,vss-description
                                                  ,{&new-line}
                                                  ,error-status:get-message(1)
                                                  ,return-value
                                                  ,p-cmd-doc-code
                                                  ,buf_temp-nws-outline.charkey_one
                                                  ).
              end. /*if error-status:error then do:*/
            end. /*if p-cmd-doc-type = {&dct-proc_batch-card-recalc} then do:*/
          end. /*if buf_temp-nws-outline.outline-type = {&table_dis-card}*/
          if buf_temp-nws-outline.no-id > 1
          and buf_temp-nws-outline.outline-type = {&table_dis-card-type}
          then do:
            v-call-id = buf_temp-nws-outline.charkey_one.
            run gen-row-keyr in this-procedure (
                                                 input v-call-id
                                                ,input ? /* буфер записи которую будем искать. если ищем по key-rec то ? */
                                                ,input "ub"
                                                ,input ? /* буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
                                                ,input no-lock
                                                ,output v-tbl-row
                                                ,output v-tbl-name).
           find first buf_dis-card-type no-lock where
                    rowid(buf_dis-card-type) = v-tbl-row.
            do  v-ii = 1 to num-entries(v-ruleset_id-list):
              v-ruleset_id = integer(entry(v-ii, v-ruleset_id-list)).
              _rule-by-call:
              for each buf_rule-by-call no-lock where
                        buf_rule-by-call.call_id = v-call-id
                  and buf_rule-by-call.can-calc = yes
                  and buf_rule-by-call.codex_id = v-codex_id
                  and buf_rule-by-call.ruleset_id = v-ruleset_id
              by buf_rule-by-call.call_id
              by buf_rule-by-call.codex_id
              by buf_rule-by-call.ruleset_id
              by buf_rule-by-call.order_id
              on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
              on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
              on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ) :
                v-proc-name = "rul/" + string(buf_rule-by-call.rule_id, '999999999') + '.p'.
                if {&run-persistent} then do:
                  { rul/rulpersi.i cmdp-dc }
                end.
                else do:
                  run value(v-proc-name) (
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
                                                                      ,input v-process-file-name
                                                                      ,input p-doc-date
                                                                      ,input p-fact-date
                                                                      ,input 0 /*p-save*/
                                                                      ,input v-curr-r-b
                                                                      ,input v-cmd-proc-handle
                                                                      ,input buf_temp-cmd.cmd-code
                                                                      ,input buf_dis-card-type.type
                                                                      ,input buf_dis-card-type.emitent-host-code
                                                                      ,input table temp-d-card
                                                                      ) no-error .
                  if error-status:error then do:
                    delete procedure v-cmd-proc-handle .
                    undo _main, return error substitute("&1&2Ошибка при вызове обработке ДК типа &3 эмитент &4&2&5&2&6"
                                                          ,vss-workfile
                                                          ,{&new-line}
                                                          ,buf_dis-card-type.type
                                                          ,buf_dis-card-type.emitent-host-code
                                                          ,error-status:get-message(1)
                                                          ,return-value
                                                          ).
                  end. /*if error-status:error then do:*/
                  if v-stop-leave-status > '' then do:
                    delete procedure v-cmd-proc-handle .
                    undo _main, return error substitute("&1&2Процесс обработке ДК типа &3 эмитент &4 ПРЕРВАН&2" +
                                                        "&5&2&6"
                                                        ,vss-workfile
                                                        ,{&new-line}
                                                        ,buf_dis-card-type.type
                                                        ,buf_dis-card-type.emitent-host-code
                                                        ,error-status:get-message(1)
                                                        ,return-value
                                                          ).
                  end.
                end.
              end. /*for each buf_rule-by-call no-lock where*/
            end. /*do v-ii = 1*/
            assign
            v-call-id = buf_temp-nws-outline.charkey_one
            .
          end. /*if buf_temp-nws-outline.no-id > 1*/
        end. /*if g#db-num = 0 then do:*/
      end. /*when {&table_nws-outline} then do:*/
      when {&table_hist-nws-option} then do:
        run proc-load-standart in p-imp-handle
          ( input {&table_hist-nws-option}
            ,input '':U
            ,input (buffer buf_temp-hist-nws-option:handle)
            ,input p-imp-handle
            ,input 0
            ,output v-curr-rowid
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
      end. /*when {&table_hist-nws-option} then do:*/
      when {&table_dis-obj} then do:
        v-h-action = integer({&hn-update}).
        create buf_temp-dis-obj.
        run nws-impl-without-check in p-imp-handle
          ( input (buffer buf_temp-dis-obj:handle)
          ) no-error.
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error return-value .
        end.
        &scop d-card buf_temp-dis-obj.d-card
        &scop dt-code buf_temp-dis-obj.dt-code
        {&verify-d-card}.
        find first buf_dis-obj exclusive-lock where
                buf_dis-obj.d-card = buf_temp-dis-obj.d-card
            and buf_dis-obj.obj-type = buf_temp-dis-obj.obj-type
            and buf_dis-obj.obj-code = buf_temp-dis-obj.obj-code
            and buf_dis-obj.dt-code = buf_temp-dis-obj.dt-code
            no-error.
        if not available buf_dis-obj then do:
          create buf_dis-obj.
          buffer-copy buf_temp-dis-obj
          using d-card host-code obj-type obj-code dt-code main-card first-card first-main-card card-num
          to buf_dis-obj.
          v-h-action = integer({&hn-create}).
        end.
        run dis-objh_write-dis-obj-rul  in this-procedure (
                                                  buffer buf_dis-obj
                                                ,input type#
                                                ,input emitent-host-code#
                                                ,input dtm-code#
                                                ,input v-h-action).
        buffer-copy buf_temp-Dis-obj to buf_dis-obj.
        if g#db-num = 0
        and p-step = 1 then do:
          run dis-objh_send-dis-obj-rul  in this-procedure (
                                                  buffer buf_dis-obj
                                                  ,input type#
                                                  ,input emitent-host-code#
                                                  ,input dtm-code#
                                                  ,input v-h-action).
        end.
        if g#db-num = 0 then do:
          v-nws-to-cd = integer({&hn-is-on}).
        { gbl/get-hn.i
          g#db-num
          {&table_dis-obj}
          0
          '':U
          0
          type#
          '':U
          '':U
          emitent-host-code#
          dtm-code#
          0
          {&nws-to-cd}
          v-nws-to-cd
          no-error
          }
          if v-nws-to-cd >= 0 then do:
            find first dc-list where
                      dc-list.d-card = buf_temp-dis-obj.d-card no-error .
            if not available dc-list then do:
              create dc-list.
            end.
            buffer-copy buf_temp-dis-obj to dc-list.
          end.
        end.
        delete buf_temp-dis-obj.
      end. /*when {&table_dis-obj}*/
      when 'temp-d-card' then do:
        find first buf_temp-xml-tables where
                  buf_temp-xml-tables.tbl-name = 'temp-d-card'  /*без no-error если не надум то отвалимся*/.
        buf_temp-xml-tables.tbl-handle_:buffer-create().
        run nws-impl-without-check in p-imp-handle
          ( input buf_temp-xml-tables.tbl-handle_
          ) no-error.
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error return-value .
        end.
        find first buf_temp-d-card where
                buf_temp-d-card.d-card = buf_temp-xml-tables.tbl-handle_:buffer-field("d-card"):buffer-value
            and buf_temp-d-card.obj-type = buf_temp-xml-tables.tbl-handle_:buffer-field("obj-type"):buffer-value
            and buf_temp-d-card.obj-code = buf_temp-xml-tables.tbl-handle_:buffer-field("obj-code"):buffer-value
            no-error.
        if not available buf_temp-d-card then do:
          create buf_temp-d-card.
          buffer buf_temp-d-card:handle:buffer-copy (buf_temp-xml-tables.tbl-handle_).
        end.
        buf_temp-xml-tables.tbl-handle_:buffer-delete().
      end. /*when "temp-d-card"*/
      when 'vchk-pay' then do:
        find first buf_temp-xml-tables where
                  buf_temp-xml-tables.tbl-name = 'vchk-pay'  /*без no-error если не надум то отвалимся*/.
        buf_temp-xml-tables.tbl-handle_:buffer-create().
        run nws-impl-without-check in p-imp-handle
          ( input buf_temp-xml-tables.tbl-handle_
          ) no-error.
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error return-value .
        end.
        find first vchk-pay where
                vchk-pay.d-card = buf_temp-xml-tables.tbl-handle_:buffer-field("d-card"):buffer-value
            and vchk-pay.pay-code = buf_temp-xml-tables.tbl-handle_:buffer-field("pay-code"):buffer-value
            and vchk-pay.curr-code = buf_temp-xml-tables.tbl-handle_:buffer-field("curr-code"):buffer-value
            and vchk-pay.doc-date = buf_temp-xml-tables.tbl-handle_:buffer-field("doc-date"):buffer-value
            and vchk-pay.cre-pay = buf_temp-xml-tables.tbl-handle_:buffer-field("cre-pay"):buffer-value
            and vchk-pay.exch-rate = buf_temp-xml-tables.tbl-handle_:buffer-field("exch-rate"):buffer-value
            and vchk-pay.base-rate = buf_temp-xml-tables.tbl-handle_:buffer-field("base-rate"):buffer-value
            no-error.
        if not available vchk-pay then do:
          create vchk-pay.
          buffer vchk-pay:handle:buffer-copy (buf_temp-xml-tables.tbl-handle_).
        end.
        buf_temp-xml-tables.tbl-handle_:buffer-delete().
      end. /*when "vpay-chk"*/
      when {&table_dis-host} then do:
        v-h-action = integer({&hn-update}).
        create buf_temp-dis-host.
        run nws-impl-without-check in p-imp-handle
          ( input (buffer buf_temp-dis-host:handle)
          ) no-error.
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error return-value .
        end.
        &scop d-card buf_temp-dis-host.d-card
        &scop dt-code buf_temp-dis-host.dt-code
        {&verify-d-card}.
        find first buf_dis-host exclusive-lock where
                buf_dis-host.d-card = buf_temp-dis-host.d-card
            and buf_dis-host.host-code = buf_temp-dis-host.host-code
            and buf_dis-host.dt-code = buf_temp-dis-host.dt-code
            no-error.
        if not available buf_dis-host then do:
          create buf_dis-host.
          buffer-copy buf_temp-dis-host
          using d-card host-code dt-code main-card first-card first-main-card card-num
          to buf_dis-host.
          v-h-action = integer({&hn-create}).
        end.
        run dis-hsth_write-dis-host-rul  in this-procedure (
                                                  buffer buf_dis-host
                                                ,input type#
                                                ,input emitent-host-code#
                                                ,input dtm-code#
                                                ,input v-h-action).
        buffer-copy buf_temp-dis-host to buf_dis-host.
        if g#db-num = 0
        and p-step = 1 then do:
          run dis-hsth_send-dis-host-rul  in this-procedure (
                                                    buffer buf_dis-host
                                                  ,input type#
                                                  ,input emitent-host-code#
                                                  ,input dtm-code#
                                                  ,input v-h-action).
        end.
        if g#db-num > 0 then do:
          v-nws-to-cd = integer({&hn-is-on}).
        { gbl/get-hn.i
          g#db-num
          {&table_dis-host}
          0
          '':U
          0
          type#
          '':U
          '':U
          emitent-host-code#
          dtm-code#
          0
          {&nws-to-cd}
          v-nws-to-cd
          no-error
          }
          if v-nws-to-cd >= 0 then do:
            find first dc-list where
                      dc-list.d-card = buf_temp-dis-host.d-card no-error .
            if not available dc-list then do:
              create dc-list.
            end.
            buffer-copy buf_temp-dis-host to dc-list.
          end.
        end.
        delete buf_temp-dis-host.
      end.  /*{&table_dis-host}*/
      when {&table_dis-card} then do:
        v-h-action = integer({&hn-update}).
        create buf_temp-dis-card.
        run nws-impl-without-check in p-imp-handle
          ( input (buffer buf_temp-dis-card:handle)
          ) no-error.
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error return-value .
        end.
        if p-cmd-doc-type <> {&dct-proc_text-import} then do:
          &scop d-card buf_temp-dis-card.d-card
          &scop dt-code -1
          {&verify-d-card}.
        end.
        find first buf_dis-card exclusive-lock where
                buf_dis-card.d-card = buf_temp-dis-card.d-card no-error.
        if not available buf_dis-card then do:
          find first buf_dis-card no-lock where
                  buf_dis-card.d-card = buf_temp-dis-card.d-card no-error.
          create buf_dis-card.
          buffer-copy buf_temp-dis-card
          using d-card card-num card-num
          to buf_dis-card
          .
          v-h-action = integer({&hn-create}).
        end.
        run discardh_write-dis-card-rul in this-procedure (
                                                  buffer buf_dis-card
                                                ,input buf_temp-dis-card.type
                                                ,input buf_temp-dis-card.emitent-host-code
                                                ,input v-h-action).
        buffer-copy buf_temp-dis-card to buf_dis-card
        ASSIGN
        buf_dis-card.trg-param = {&trg-param-no-hist} + {&comma-char} + {&trg-param-no-callnews}
        .
        if g#db-num = 0
        and p-step = 1
        then do:
          run discardh_send-dis-card-rul in this-procedure (
                                                    buffer buf_dis-host
                                                  ,input buf_temp-dis-card.type
                                                  ,input buf_temp-dis-card.emitent-host-code
                                                  ,input v-h-action).
        end.
        find first  dc-list where
                   dc-list.d-card = buf_temp-dis-card.d-card no-error .
        if not available dc-list then do:
          create dc-list.
        end.
        buffer-copy buf_temp-dis-card to dc-list.
        delete buf_temp-dis-card.
      end.
      when {&table_dis-card-property} then do:
        v-h-action = integer({&hn-update}).
        create buf_temp-dis-card-property.
        run nws-impl-without-check in p-imp-handle
          ( input (buffer buf_temp-dis-card-property:handle)
          ) no-error.
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error return-value .
        end.
        &scop d-card buf_temp-dis-card-property.d-card
        &scop dt-code buf_temp-dis-card-property.dt-code
        {&verify-d-card}.
        find first buf_dis-card-property exclusive-lock where
                buf_dis-card-property.d-card = buf_temp-dis-card-property.d-card
            and buf_dis-card-property.dt-code = buf_temp-dis-card-property.dt-code
            and buf_dis-card-property.node-code = buf_temp-dis-card-property.node-code
            and buf_dis-card-property.host-code = buf_temp-dis-card-property.host-code
            and buf_dis-card-property.obj-type = buf_temp-dis-card-property.obj-type
            and buf_dis-card-property.obj-code = buf_temp-dis-card-property.obj-code   no-error.
        if not available buf_dis-card-property then do:
          create buf_dis-card-property.
          v-h-action = integer({&hn-create}).
          buffer-copy buf_temp-dis-card-property
          using d-card host-code obj-type obj-code dt-code node-code main-card first-card first-main-card card-num
          to buf_dis-card-property.
        end.
        run disproph_write-dis-card-property-rul  in this-procedure (
                                                  buffer buf_dis-card-property
                                                ,input type#
                                                ,input emitent-host-code#
                                                ,input dtm-code#
                                                ,input v-h-action).
        buffer-copy buf_temp-dis-card-property to buf_dis-card-property.
        if g#db-num = 0
        and p-step = 1
        then do:
          run disproph_send-dis-card-property-rul  in this-procedure (
                                                    buffer buf_dis-card-property
                                                  ,input type#
                                                  ,input emitent-host-code#
                                                  ,input dtm-code#
                                                  ,input v-h-action).
        end.
        if g#db-num > 0 then do:
          v-nws-to-cd = integer({&hn-is-on}).
        { gbl/get-hn.i
          g#db-num
          {&table_dis-card-property}
          0
          '':U
          0
          type#
          '':U
          '':U
          emitent-host-code#
          dtm-code#
          0
          {&nws-to-cd}
          v-nws-to-cd
          no-error
          }
          if v-nws-to-cd >= 0 then do:
            find first dc-list where
                      dc-list.d-card = buf_temp-dis-card-property.d-card no-error .
            if not available dc-list then do:
              create dc-list.
            end.
            buffer-copy buf_temp-dis-card-property to dc-list.
          end.
        end.
        delete buf_temp-dis-card-property.
      end.
      when {&table_clients} then do:
        v-h-action = integer({&hn-update}).
        create buf_temp-clients.
        run nws-impl-without-check in p-imp-handle
          ( input (buffer buf_temp-clients:handle)
          ) no-error.
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error return-value .
        end.
        find first buf_clients exclusive-lock where
                buf_clients.obj-type = buf_temp-clients.obj-type
            and buf_clients.obj-code = buf_temp-clients.obj-code no-error.
        if not available buf_clients then do:
          create buf_clients.
          buffer-copy buf_temp-clients
          using obj-type obj-code
          to buf_clients.
          v-h-action = integer({&hn-create}).
        end.
        run clientsh_write-clients-rul  in this-procedure (
                                                  buffer buf_clients
                                                ,input v-h-action).
        buffer-copy buf_temp-clients to buf_clients.
        if g#db-num = 0
        and p-step = 1
        then do:
          run clientsh_send-clients-rul  in this-procedure (
                                                    buffer buf_clients
                                                  ,input v-h-action).
        end.
        for each buf_dis-card where
                buf_dis-card.cli-type = buf_clients.obj-type
            AND buf_dis-card.cli-code = buf_clients.obj-code
        on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
        on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ) :
          find first dc-list where
                    dc-list.d-card = buf_dis-card.d-card no-lock no-error.
          if not available dc-list then do:
            create dc-list.
          end.
          buffer-copy buf_dis-card to dc-list.
        end. /*for each*/
        delete buf_temp-clients.
      end.
      when {&table_firm} then do:
        v-h-action = integer({&hn-update}).
        create buf_temp-firm.
        run nws-impl-without-check in p-imp-handle
          ( input (buffer buf_temp-firm:handle)
          ) no-error.
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error return-value .
        end.
        find first buf_firm exclusive-lock where
                buf_firm.firm-code = buf_temp-firm.firm-code no-error.
        if not available buf_firm then do:
          create buf_firm.
          buffer-copy buf_temp-firm
          using firm-code
          to buf_firm.
          v-h-action = integer({&hn-create}).
        end.
        run clientsh_write-firm-rul  in this-procedure (
                                                  buffer buf_firm
                                                ,input v-h-action).
        buffer-copy buf_temp-firm to buf_firm.
        if g#db-num = 0
        and p-step = 1
        then do:
          run clientsh_send-firm-rul  in this-procedure (
                                                    buffer buf_firm
                                                  ,input v-h-action).
        end.
        for each buf_dis-card where
                buf_dis-card.cli-type = {&cmp}
            AND buf_dis-card.cli-code = buf_firm.firm-code
        on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
        on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ) :
          find first dc-list where
                    dc-list.d-card = buf_dis-card.d-card no-lock no-error.
          if not available dc-list then do:
            create dc-list.
          end.
          buffer-copy buf_dis-card to dc-list.
        end. /*for each*/
        delete buf_temp-firm.
      end.
      when {&table_person} then do:
        v-h-action = integer({&hn-update}).
        create buf_temp-person.
        run nws-impl-without-check in p-imp-handle
          ( input (buffer buf_temp-person:handle)
          ) no-error.
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error return-value .
        end.
        find first buf_person exclusive-lock where
                buf_person.psn-code = buf_temp-person.psn-code no-error.
        if not available buf_person then do:
          create buf_person.
          buffer-copy buf_temp-person
          using psn-code
          to buf_person.
          v-h-action = integer({&hn-create}).
        end.
        run clientsh_write-person-rul  in this-procedure (
                                                  buffer buf_person
                                                ,input v-h-action).
        buffer-copy buf_temp-person to buf_person.
        if g#db-num = 0
        and p-step = 1
        then do:
          run clientsh_send-person-rul  in this-procedure (
                                                    buffer buf_person
                                                  ,input v-h-action).
        end.
        for each buf_dis-card where
                buf_dis-card.cli-type = {&prs}
            AND buf_dis-card.cli-code = buf_person.psn-code
        on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
        on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ) :
          find first dc-list where
                    dc-list.d-card = buf_dis-card.d-card no-lock no-error.
          if not available dc-list then do:
            create dc-list.
          end.
          buffer-copy buf_dis-card to dc-list.
        end. /*for each*/
        delete buf_temp-person.
      end.
      when {&table_c-dis-obj}
      or
      when {&table_c-dis-host}
      or
      when {&table_c-dc-hist}
      or
      when {&table_c-dis-card-property}
      or
      when {&table_c-clients}
      or
      when {&table_c-cli-hist}
      or
      when {&table_c-firm}
      or
      when {&table_c-person}
      or
      when {&table_c-dis-card}
      then do:
        run proc-load-standart in p-imp-handle
            (  input v-rec-name
              ,input '':U
              ,input ?
              ,input p-imp-handle
              ,input 0 /*указатель того что это не куст*/
              ,output v-curr-rowid
              ) no-error.
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo _main, return error return-value .
        end.
      end.
      otherwise do:
        message
        vss-workfile vss-revision vss-description skip
        substitute("НЕ ПРЕДУСМОТРЕН ПРИЕМ ТАБЛИЦЫ &1 В ПРОЦЕДУРЕ", v-rec-name)
        view-as alert-box error .
        delete procedure v-cmd-proc-handle .
        undo _main, return error return-value .
      end. /*otherwise*/
    end case.
  end. /*do counter = 1 to p-counter*/
  run hide-counter in p-log-handle no-error .
  if {&run-persistent} then do:
    run perproc-delete-from-parent  in this-procedure (
                                                        input this-procedure:handle
                                                        ,input '':U /*p-proc-name */ ).
  end.
  if g#db-num = 0
  and  p-step < 2
  then do:
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
    end. /*if g#db-num = 0 then do:*/
    v-is-empty = no.
    run is-almost-empty in v-cmd-proc-handle ( input buf_temp-cmd.cmd-code
                                      ,output v-is-empty) no-error.
    if v-is-empty then do:
      run delete-command in v-cmd-proc-handle ( input buf_temp-cmd.cmd-code ). /* p-command-code */
    end.
    if not v-is-empty and not mode-erprn then do:
      run send-command in v-cmd-proc-handle
        ( input buf_temp-cmd.cmd-code  /* p-command-code */
          ,input buf_temp-cmd.db-list
          ) no-error .

      if error-status :error then do:
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
      end. /*if error-status :error then do:*/
    end.
  end. /*for each buf_temp-cmd*/
  case p-cmd-doc-type:
    when {&dct-proc_sale-close}
    or
    when {&dct-proc_trn-doc-close}
    then do:
      define variable v-deleted as logical no-undo .
      if p-step = 1
      and g#db-num = 0
      then do:
        /*удаленная накладная приходит первой и мы уже приняли инфо по ДК - можно стереть атрибут*/
        { str/tdat-del.i
            p-cmd-doc-code
            ~{&trdcattr-need-saledc~}
            v-deleted
            no-error
          }
       end.
    end.
    when {&dct-proc_sale-delete}
    or
    when {&dct-proc_trn-doc-delete}
    then do:
      if p-step = 1
      and g#db-num = 0
      then do:
        /*первой приходит команда по ДК и мы уже приняли инфо по ДК - надо поставить атрибут*/
        /*знак действия - НАЧИСЛЕНИЕ СУММ а не списание - т.е. если удаление накладной не примем то обратно надо начислить*/
        { str/tdat-wrt.i
            p-cmd-doc-code
            ~{&trdcattr-need-saledc~}
            string(1)
            no-error
          }
       end.
    end.
    otherwise do:
    end.
  end case.
  if valid-handle(v-cmd-proc-handle) then do:
    delete procedure v-cmd-proc-handle .
  end.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Данные по ДК: &1 ЗАВЕРШЕНО ", p-cmd-doc-code)) no-error .

end. /*doe*/

procedure write-to-log : /*не удалять!!!*/
define input parameter p-mess as character no-undo .

  do
  on error undo, return error
  :

  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input p-mess).
  end.

end procedure. /* write-to-log */


procedure proc-verify-d-card :
define input parameter p-rec-name as character no-undo .
define input parameter p-d-card as character no-undo .
define input parameter p-dt-code as integer no-undo .
define output parameter p-type as character no-undo .
define output parameter p-emitent-host-code as integer no-undo .
define output parameter p-dtm-code as integer no-undo .

define variable v-call#-id as integer no-undo .
define buffer buf_temp-d-card for temp-d-card.
define buffer buf_temp-prop-ref for temp-prop-ref .
define buffer buf_dis-card for ub.dis-card.
define buffer buf_prop-ref for ub.prop-ref.

do
on error undo, return error
:
find first buf_temp-d-card no-lock where
        buf_temp-d-card.d-card = p-d-card no-error .
if not available buf_temp-d-card then do:
  find first buf_Dis-card no-lock where
            buf_Dis-card.d-card = p-d-card no-error.
  if not available buf_Dis-card
  then do:
    if p-cmd-doc-type = {&dct-proc_sale-xml-import} then return.
    undo, return error substitute("Ошибка при поиске ДК &1:Получена запись таблицы &2 для этой карты"
                                      ,p-d-card
                                      ,p-rec-name
                                      ).
  end.
  assign
  p-type = buf_dis-card.type
  p-emitent-host-code = buf_dis-card.emitent-host-code
  .
end.
else do:
  assign
  p-type = buf_temp-d-card.type
  p-emitent-host-code = buf_temp-d-card.emitent-host-code
  .

end.
if p-dt-code <> -1 then do:
  find first buf_temp-prop-ref no-lock where
            buf_temp-prop-ref.dt-code = p-dt-code no-error.
  if not available buf_temp-prop-ref then do:
    find first buf_prop-ref no-lock where
              buf_prop-ref.dt-code = p-dt-code no-error.
    if not available buf_prop-ref then do:
      undo, return error substitute("Ошибка при поиске ДК &1:Получена запись таблицы &2 для этой карты&3Неизвестный срез/итог &4"
                                        ,p-d-card
                                        ,p-rec-name
                                        ,{&new-line}
                                        ,p-dt-code
                                        ).
    end.
    create buf_temp-prop-ref.
    buffer-copy buf_prop-ref to buf_temp-prop-ref.
  end.
  p-dtm-code  = buf_temp-prop-ref.dtm-code.
  v-call-id = substitute("&2&1&3&1&4&1&5&1&6&1&7"
                        , {&delim-key}
                        , {&table_dis-card-type}
                        , p-emitent-host-code
                        , p-type
                        , 0
                        , '':U
                        , 0).
end.
end.

end procedure. /* proc-verify-d-card */

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

procedure cb_create-dc-list :
define input parameter p-bh as handle no-undo .
define variable v-dch as handle no-undo .

do
on error undo, return error return-value
:
  /*здесь у нас пустышка - потому что и так все отсылается на кассу*/
end.

end procedure. /* cb_create-dc-list */
