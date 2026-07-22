block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт спецификации

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/14/10
Author: Bakhtadze Natalya
Creation date: 07/14/10

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-is-dynamic as logical no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-process-file-name as character no-undo .
define input parameter p-save       as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экспорт спецификации".
{ cmp/vssrevis.i }


{ cmp/trg-def.i }
{ cmp/library.i }
{ str/libbcrcn.i }
{ gbl/key-rec.i }
{ rul/ruleset_.i }
{ str/cntspcie.i }
{ str/specattr.i } /*read-bonus*/

define variable file-name as character no-undo .
define variable p-delimiter as character no-undo.
define variable p-start-row as integer no-undo.

define variable log-file-name                as character      no-undo init "process-edoc.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-rid                        as recid          no-undo .


define stream Outstream.
{ gbl/dyneximp.i Outstream }
define stream logstream .
define variable my-mess as char.
/*вспомогат*/
define variable num-rec as integer.
define variable num-rec-ok as integer.
define variable ii as integer.
define variable dopdec as decimal no-undo.
define variable v-return-value as character no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type as character no-undo.
define variable v-ask as logical no-undo .
define variable v-write-hist as logical no-undo .
define variable v-order as character no-undo .
define variable v-bar-code as integer no-undo .

define variable glog as logical no-undo .
define variable v-mess as character no-undo .
define variable v-cntspcie as handle no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-contract-code as integer no-undo .
define variable v-contract-cli-type as character no-undo .
define variable v-contract-cli-code as integer no-undo .
define variable v-str as character no-undo .
define variable v-bonus as decimal no-undo .
define variable v-price-sale as decimal no-undo .
/* Список дополнительный БАР кодов по товару   */
DEFINE VARIABLE v-cList-DopBK as CHARACTER NO-UNDO INITIAL "".
/*% отклонения в меньшую сторону*/
define variable v-prc-min as decimal no-undo.
/*  */
define buffer buf_prod-bc  for ub.prod-bc.
define buffer buf_bar-code  for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_contract for ub.contract.
define buffer buf_contract-specif for ub.contract-specif.
define buffer buf_ext-artic for ub.ext-artic.
DEFINE BUFFER buf_Clients   FOR ub.Clients.

define shared temp-table tt0-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_rule-call-param for tt0-rule-call-param.

&scop display-message ~
      run write-log-and-file in p-log-handle ( ~
            input 1 ~
          , input log-file-name ~
          , input 1 ~
          , input ~{&my-message~})



&scop view-log   ~{ str/cdviewlg.i   ~
                    "'!!!При экспорте информации произошли ошибки!!!'" ~
                    "'process-edoc.txt'" ~}   ~
                    return


run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error.
if error-status:error then do:
  &scop my-message substitute("Ошибка при подготовке к экспорту данных из спецификацию:&1&2&1&3" ~
                           , ~{&new-line~} ~
                           , error-status:get-message(1)  ~
                           , return-value )
  {&display-message}.
  v-view-log = yes.
  {&view-log}.
end.
empty temp-table cntspcie.
v-cntspcie = buffer cntspcie:handle.                                /* Для экспорта таблицы спецификации  */
for each buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-fields"
and buf_rule-call-param.p-index > 0
by buf_rule-call-param.p-index
:
  v-order = v-order + (if v-order = '' then '' else {&comma-char}) + entry(2, buf_rule-call-param.param-value-character, ".").
end.
run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
if p-ruleset-id = {&edoc-proc_18_text-export_specif_223} then do:
  &scop my-message substitute("Экспорт данных в файл &1", file-name)
  {&display-message}.
  output stream Outstream to value(file-name).
end.
else do:
  &scop my-message substitute("Подготовка данных для экспорта")
  {&display-message}.
end.

_stroka:
for each buf_contract-specif no-lock where
        buf_contract-specif.host-code = v-current-host-code
    and buf_contract-specif.contract-num = v-contract-code
on error  undo _stroka, retry
on stop   undo _stroka, retry
on endkey undo _stroka, retry
:
  if retry then do:
    my-mess = substitute("&1 (товар &2)", v-mess, buf_contract-specif.gds-code).
    &scop my-message v-mess
    {&display-message}.
    v-view-log = yes.
    next _stroka.
  end.
  num-rec = num-rec + 1.
  find first buf_goods no-lock where
            buf_goods.gds-code = buf_contract-specif.gds-code no-error.
  if not available buf_goods then do:
    v-mess = substitute("Не найден товар с кодом &1!", buf_contract-specif.gds-code).
    v-view-log = yes.
    undo _stroka, retry _stroka.

  end.
  run read-bonus in this-procedure ( input buf_contract-specif.contract-num
                                    , input buf_contract-specif.host-code
                                    , input buf_contract-specif.gds-code
                                    , output v-bonus
                                    ) no-error .
  if error-status:error then do:
    v-mess = substitute("Ошибка при попытке получения значения бонуса!&1&2&1&4"
                          ,{&new-line}
                          , error-status:get-message(1)
                          , return-value
                          ).

    v-view-log = yes.
    undo _stroka, retry _stroka.
  end.
  run read-prc-min in this-procedure ( input buf_contract-specif.contract-num
                                    , input buf_contract-specif.host-code
                                    , input buf_contract-specif.gds-code
                                    , output v-prc-min
                                    ) no-error .
  if error-status:error then do:
    v-mess = substitute("Ошибка при попытке получения значения % отклонения в меньшую сторону!&1&2&1&4"
                          ,{&new-line}
                          , error-status:get-message(1)
                          , return-value
                          ).

    v-view-log = yes.
    undo _stroka, retry _stroka.
  end.
  { gbl/gdsbcode.i buf_contract-specif.gds-code ? v-bar-code no-error }
  if error-status:error then do:
    v-mess = substitute("Ошибка при попытке получения корневого бар-кода товара!&1&2&1&4"
                          ,{&new-line}
                          , error-status:get-message(1)
                          , return-value
                          ).
    v-view-log = yes.
    undo _stroka, retry _stroka.
  end.
  find first buf_ext-artic where
            buf_ext-artic.cli-type   = v-contract-cli-type
        and buf_ext-artic.cli-code   = v-contract-cli-code
        and buf_ext-artic.gds-code   = buf_contract-specif.gds-code
        and buf_ext-artic.status_    <> {&deleted-status} no-error .

  /*
  #2095
  find first buf_prod-bc no-lock where
            buf_prod-bc.b-code = v-bar-code
        and buf_prod-bc.bc-on = yes
            no-error.
  */
  /* Собираем все дополнительные Бар коды в список,
     если они имеются  */
  ASSIGN
     v-cList-DopBK = "".
  /*  */
  FOR EACH buf_prod-bc WHERE
           buf_prod-bc.b-code = v-bar-code
      NO-LOCK:
      /*  */
      ASSIGN
         v-cList-DopBK = v-cList-DopBK + (IF v-cList-DopBK = "" THEN "" ELSE "," ) + buf_prod-bc.b-str.
  END.
  /* И добавляем производителя */
  FIND FIRST buf_Clients WHERE
             buf_Clients.obj-type = buf_contract-specif.prod-type
         AND buf_Clients.obj-code = buf_contract-specif.prod-code
       NO-LOCK NO-ERROR.
  /*  */
  create cntspcie.
  assign
  cntspcie.line-num = num-rec
  cntspcie.artic  = buf_contract-specif.artic
  cntspcie.prod-type  = buf_contract-specif.prod-type
  cntspcie.prod-code  = buf_contract-specif.prod-code
  cntspcie.price-cli  = buf_contract-specif.price-cli
  cntspcie.prc        = buf_contract-specif.prc
  cntspcie.qnty       = buf_contract-specif.qnty
  cntspcie.cli-base-rate = buf_contract-specif.cli-base-rate
  cntspcie.vat-type   = buf_contract-specif.vat-type
  cntspcie.vat-pc     = buf_contract-specif.vat-pc
  cntspcie.gds-name   = buf_goods.gds-name
  cntspcie.qnty-cart  = buf_goods.qnty-cart
  cntspcie.ext-artic  = (if available buf_ext-artic
                          then buf_ext-artic.ext-artic
                          else '')
  cntspcie.price-sale = v-price-sale
  cntspcie.b-str      = v-cList-DopBK   /* #2095 Сюда выводим список Дополнительных бар кодов */
  cntspcie.bonus      =  v-bonus
  /* #2095 */
  CntSpcIE.DeadLine   = buf_Goods.DeadLine                                             /* Срок хранения (дней) */
  CntSpcIE.Obj-Name   = (IF AVAILABLE buf_Clients THEN buf_Clients.Obj-Name ELSE "" )  /* Наименование производителя */
  cntspcie.prc-min    = v-prc-min   /* % отклонения в меньшую сторону */
  .
  /*  */
  if p-ruleset-id = {&edoc-proc_18_text-export_specif_223} then do:
    v-str = dyneximp_export  (
                              INPUT v-cntspcie
                              ,INPUT p-delimiter
                              ,input v-order
                              ,input '' /*p-except-field-list */
                              ) no-error.

    if error-status:error then do:
      v-mess = substitute("Строчка &1 не проэкспортирована!&2&3"
                            ,num-rec
                            ,{&new-line}
                            ,v-mess).

      v-view-log = yes.
      undo _stroka, retry _stroka.
    end.
    put stream outstream unformatted v-str skip.
    num-rec-ok = num-rec-ok + 1.
    run show-counter in p-log-handle .
    run write-counter in p-log-handle (substitute("Просмотрено &1 из них экспортировано &2"
                                                , num-rec
                                                , num-rec-ok
                                                )) no-error.
    delete cntspcie.
    run get-stop-state in p-log-handle (
        output v-stop
    ).
    if v-stop then do:
      leave _stroka.
    end.
  end.
  else do:
    release cntspcie.
  end.

end.
if v-stop then do:
  &scop my-mess substitute("Экспорт данных из спецификации прерван пользователем")
  {&display-message}.
  v-view-log = yes.
  {&view-log}.
end.
if p-ruleset-id = {&edoc-proc_18_text-export_specif_223} then do:
  output stream Outstream close.
  &scop my-message  substitute("Запись данных в файл &1 завершена: из &2 записей успешно записано &3" ~
                        , file-name ~
                        , num-rec   ~
                        , num-rec-ok ~
                        )
  {&display-message}.
end. /*if p-ruleset-id = {&edoc-proc_18_text-export_specif_223} then do:*/
num-rec = 0.
if p-ruleset-id = {&edoc-proc_18_excel-export_specif_225} then do:
  run dyneximp_export-excel in this-procedure (
                                              input file-name
                                             ,input p-start-row /*p-start-row */
                                             ,input v-cntspcie /*p-bh*/
                                             ,input v-order
                                             ,input '' /* p-except-field-list */
                                             ,input this-procedure:handle
                                             ,input "cb_err"
                                             ,output num-rec
                                             ,output num-rec-ok
                                             ) no-error.

  output stream Outstream close.
  &scop my-message  substitute("Запись данных в файл &1 завершена: из &2 записей успешно записано &3" ~
                        , file-name ~
                        , num-rec   ~
                        , num-rec-ok ~
                        )
  {&display-message}.
end. /*if p-ruleset-id = {&edoc-proc_18_excel-import_specif_226} then do:*/

{&view-log}.


procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for tt0-rule-call-param.
define buffer buf_contract for ub.contract.

do
on error undo, return error
:
/*---------------------------&start-process-rule-call-param&-------------------------------*/

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-delimiter"
 no-error.
if available buf_rule-call-param then do:
assign p-delimiter = buf_rule-call-param.param-value-character.
end.

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-start-row"
 no-error.
if available buf_rule-call-param then do:
assign p-start-row = buf_rule-call-param.param-value-integer.
end.



/*---------------------------&end-process-rule-call-param&-------------------------------*/
    case p-ruleset-id:
      when {&edoc-proc_18_text-export_specif_223}
      or
      when {&edoc-proc_18_excel-export_specif_225}
      then do:
        assign
        v-current-host-code = p-host-code
        v-contract-code = integer(p-doc-code)
        file-name  = p-process-file-name
        .
        find first buf_contract exclusive-lock where
                  buf_contract.host-code = v-current-host-code
              and buf_contract.contract-code = v-contract-code no-error.
        if not available  buf_contract then do:
           undo, return error substitute("Не найден договор № &1 (по фирме &2)", v-contract-code, v-current-host-code).
        end.
        assign
        v-contract-cli-type = buf_contract.cli-type
        v-contract-cli-code = buf_contract.cli-code
        .
      end.
      otherwise do:

      end.
    end case.
    assign
    file-name            = p-process-file-name
    .
    /*
    FIND FIRST ub.db WHERE ub.db.db-num = g#db-num NO-LOCK .
    if g#db-num = 0 then do:
      &scop my-message substitute("Импорт клиентов возможен только в ГБД", ~{&new-line~})
      {&display-message}.
      assign
      v-view-log = yes.
      {&view-log}.
    end.
    */
    { str/sclspref.i varscales-pref varpgscales-pref }
  end. /*doe*/

end procedure. /* load-ruleset-context */

procedure cb_err :
define input parameter p-err-mess as character no-undo .

do
on error undo, return error
:
  &scop my-message p-err-mess
  {&display-message}.
  v-view-log = yes.
end.

end procedure. /* cb_err */