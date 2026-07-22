/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 11, набор 5

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/07/09
Author: Bakhtadze Natalya
Creation date: 10/07/09

---------------------------&start-codex_id=11;ruleset_id=5;-------------------------------
Операции с джокументами

---------------------------&end-codex_id=11;ruleset_id=5;-------------------------------

*/


/*---------------------------&start-using-class&-------------------------------*/
using Ibs.Th.Rul.Route-data_.
block-level on error undo, throw.

/*---------------------------&end-using-class&---------------------------------*/


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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 11, набор 5".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/ruleset_.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
{ gbl/gate-clb.i }
{ gbl/key-rec.i }
{ bge/tmpcxmlh.i }
{ gbl/lib-gate.i }
&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)


/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-doc-code as character no-undo .
define variable v-current-gds-code as integer no-undo .
define variable v-newbh as handle no-undo .
define variable v-oldbh as handle no-undo .
define variable v-has-newbh as logical no-undo .
define variable v-has-oldbh as logical no-undo .
define variable v-changes-list as character no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .
define variable log-file-name                as character      no-undo init "process-gds.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-last-error-message as character no-undo .
/*****************************/
define variable file-name as char.
define variable v-sign as integer no-undo .
define variable v-gate-rec as character no-undo .
define variable num-rec-pre as integer no-undo .
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable l-res as integer no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define variable v-esys-id-list as character no-undo .
define variable v-err-mess as character no-undo .
define variable v-gds-list-bh as handle no-undo .
define variable v-gds-list-handle as handle no-undo .
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.

{ str/dia2auto.i }
{ rul/seterror.i }
{ cmp/gds-list.i gds-list def "new shared" }

&scop display-message ~
          if valid-handle(p-log-handle) then ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)




/*---------------------------&start-rule-call-param&-------------------------------*/

  define variable p-xsd-file as character no-undo.

/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/

 { rul/context_f.i  begin-esys-command }
 { rul/context_f.i  send-esys-command }
 { rul/context_f.i  delete-command }



/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run garbcoll_clear in this-procedure .
end.
run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error.
if error-status:error then do:
  undo, return error return-value .
end.
if return-value = "return" then return ''.

/* ------------------------- &start-def-vars& -----------------------------------*/

define variable ExpData1 as class Route-data_ no-undo .
{ gbl/gaterout.i
  parparentproc
  p-parent-handle
  p-log-handle
  this-procedure:handle
  ExpData1
}

/* ------------------------- &end-def-vars& -----------------------------------*/

if not this-procedure:persistent then do:
  run proc-main in this-procedure no-error .
  if error-status:error then do:
    v-esm = error-status :get-message (1).
    v-es = error-status:error .
    v-rv = return-value .
  end.
  if v-es then do:
      run garbcoll_clear in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, v-rv, {&new-line}, v-esm).
  end.
  run garbcoll_clear in this-procedure .
end.

procedure proc-main :

_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
on stop undo, return error substitute( "&1&2&3", return-value, {&new-line}, error-status :get-message (1))
:

define variable v-err as logical no-undo .
define variable v-gds-name as character no-undo .
define variable v-pck-num-rec as integer no-undo init 1000.
define buffer buf_goods for ub.goods.



  /* ------------------------- &end-hn-option& -----------------------------------*/
_stroka:
do while true:
  /* ------------------------- &start-rule& -----------------------------------*/
  if num-rec modulo v-pck-num-rec = 0
  then do:
    IF  ExpData1:route-data_push-xmlschema( INPUT p-xsd-file ) = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
    IF  context_begin-esys-command( input v-esys-id-list
                                  , input-output v-esys-cmd-proc-handle
                                  , output v-esys-cmd-code) = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
  end.
  num-rec = num-rec + 1.
  case p-ruleset-id:
    when {&goods-proc_11_batchwork-routing_2} then do:
      if v-gds-list-bh:available then do:
        v-gds-list-bh:buffer-delete().
      end.
      run cb_get-next-gds-by-gds-code in v-gds-list-handle ( input v-current-gds-code
                                                            ,input v-gds-list-bh
                                                            ).
      if v-gds-list-bh:available then do:
        if num-rec-pre > 0 then do:
          run write-counter in p-log-handle ( input substitute("Просмотрено товаров списка &1, обработано  &2, из них удачно: &3", num-rec-pre, num-rec, num-rec-ok)).
        end.
        num-rec-pre = num-rec-pre + 1.
        v-current-gds-code = v-gds-list-bh:buffer-field("gds-code"):buffer-value.
        v-gds-name = v-gds-list-bh:buffer-field("gds-name"):buffer-value.
      END.
      else do:
        v-current-gds-code = 0.
      end.
    end.
    when {&goods-proc_11_gds_5} then do:
      v-current-gds-code = v-newbh:buffer-field("gds-code"):buffer-value.
      v-gds-name = v-newbh:buffer-field("gds-name"):buffer-value.
    end.
  end.
  if v-current-gds-code > 0 then do:
    num-rec = num-rec + 1.
    find first buf_goods no-lock where
              buf_goods.gds-code = v-current-gds-code no-error.
    if not available buf_goods then do:
        undo _main, return error substitute("Не найден товар с кодом &1", v-current-gds-code).
    end.
    ExpData1:route-data_create-record( INPUT "good") .
    ExpData1:route-data_copy-field-integer( INPUT "good", "gds-code", INPUT  buf_goods.gds-code) .
    ExpData1:route-data_copy-field-character(INPUT "good", "name", INPUT  buf_goods.gds-name).
    ExpData1:route-data_copy-field-character(INPUT "good", "units", INPUT  buf_goods.unit-base ).
    ExpData1:route-data_copy-field-character(INPUT "good", "artic", INPUT  buf_goods.artic ).
    ExpData1:route-data_copy-field-character(INPUT "good", "prodtype", INPUT  buf_goods.prod-type ).
    ExpData1:route-data_copy-field-integer(INPUT "good", "prodcode", INPUT  buf_goods.prod-code ).
    ExpData1:route-data_copy-field-character(INPUT "good", "okdp", INPUT  buf_goods.okdp).
    ExpData1:route-data_copy-field-character(INPUT "good", "type", INPUT  buf_goods.gds-type ).
    ExpData1:route-data_copy-field-logical( INPUT "good", "deleted", INPUT  buf_goods.stts <> integer({&current-status-int}) ) .
    IF ExpData1:esys-add-dump( INPUT "good", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи товара с кодом &1:&2&3"
                              , v-current-gds-code
                              , {&new-line}
                              , v-last-error-message
                              ).
      undo _main, return error v-last-error-message .
    end.
    num-rec-ok = num-rec-ok + 1.
    if p-ruleset-id = {&goods-proc_11_batchwork-routing_2} then do:
      run write-counter in p-log-handle ( input substitute("Обработано товаров списка: &1, из них удачно: &2", num-rec, num-rec-ok)).
      run get-stop-state in p-log-handle ( output v-stop) no-error .
      if v-stop then do:
          run write-log-and-file in p-log-handle (
                                                  input 1
                                                , input log-file-name
                                                , input 1
                                                , input substitute("Процесс прерван пользователем")).
          leave _stroka.
      end.
    end.
  end.
  if p-ruleset-id = {&goods-proc_11_gds_5}
  or (p-ruleset-id = {&goods-proc_11_batchwork-routing_2} and  num-rec modulo v-pck-num-rec = 0)
  or not v-gds-list-bh:available
  or v-current-gds-code = 0
  then do:
    IF  context_send-esys-command( input v-esys-id-list
                                , input v-esys-cmd-proc-handle
                                , input v-esys-cmd-code
                                , input g#userid) = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
  end.
  num-rec-ok = num-rec-ok + 1.
  &scop release_1 clear-data ( )
  ExpData1:Route-data_{&release_1} .
  if p-ruleset-id = {&goods-proc_11_gds_5}
  or not v-gds-list-bh:available
  or v-current-gds-code = 0
  then do:
    leave _stroka.
  end.
  if p-ruleset-id = {&goods-proc_11_batchwork-routing_2} then do:
    run get-stop-state in p-log-handle ( output v-stop) no-error .
    if v-stop then do:
      &scop my-message substitute("Процесс прерван пользователем")
      {&display-message}.
      leave _stroka.
    end.
  end.

  /* ------------------------- &end-rule& -------------------------------------*/
end.
  /* ------------------------- &start-release-obj& -----------------------------------*/
if p-ruleset-id = {&goods-proc_11_batchwork-routing_2}
then do:
  &scop my-message substitute("Просмотрено товаров списка &1, обработано  &2, из них удачно: &3", num-rec-pre, num-rec, num-rec-ok)
  {&display-message}.
end.


  /* ------------------------- &end-release-obj& -------------------------------------*/

  /*нет удаления схемы!!!!!*/
  /*ExpData1:route-data_clear-xmlschema ( ).*/
end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define variable v-flag as logical no-undo .
define variable v-ii as integer no-undo .
define variable v-changes-list2 as character no-undo .
define variable v-h as handle no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_ext-system for ub.ext-system.

do
on error undo, return error
:

case p-ruleset-id:
  when {&goods-proc_11_batchwork-routing_2} then do:
    /*найдем процедуру которая управляет списком*/
    { gbl/calltree.i 'cb_get-next-gds-by-gds-code' this-procedure:handle p-cont-handle v-gds-list-handle }

    { gbl/calltree.i 'cb_rcps-run_fill-rcp-from-tt0' this-procedure:handle p-cont-handle v-h }
    run  cb_rcps-run_fill-rcp-from-tt0 in v-h ( input p-call-id
                                              ,input buffer buf_temp-rule-call-param:handle
                                                            ).

    for each buf_temp-rule-call-param no-lock where
    buf_temp-rule-call-param.codex_id = p-codex-id
    and buf_temp-rule-call-param.ruleset_id = p-ruleset-id
    and buf_temp-rule-call-param.call_id = p-call-id
    and buf_temp-rule-call-param.order_id = p-order-id
    and buf_temp-rule-call-param.rule_id = p-rule-id
    and buf_temp-rule-call-param.param-name = "p-esys-id-list",
      first buf_ext-system no-lock where
            buf_Ext-system.esys-id = buf_temp-rule-call-param.param-value-integer
        and buf_Ext-system.db-num = 0
        and buf_Ext-system.esys-have-export = yes
        and buf_Ext-system.esys-db-num-exp = g#db-num:
      v-esys-id-list = v-esys-id-list + (if v-esys-id-list = '' then '' else {&delim-nws}) + string(buf_ext-system.esys-id).
    end.
    if v-esys-id-list = '' then return "return".

      /*---------------------------&start-process-rule-call-param&-------------------------------*/
    find first buf_temp-rule-call-param no-lock where
    buf_temp-rule-call-param.codex_id = p-codex-id
    and buf_temp-rule-call-param.ruleset_id = p-ruleset-id
    and buf_temp-rule-call-param.call_id = p-call-id
    and buf_temp-rule-call-param.order_id = p-order-id
    and buf_temp-rule-call-param.rule_id = p-rule-id
    and buf_temp-rule-call-param.param-name = "p-xsd-file"
    no-error.
    if available buf_temp-rule-call-param then do:
      assign p-xsd-file = buf_temp-rule-call-param.param-value-character.
    end.
    v-gds-list-bh = buffer gds-list:handle.
  end.
  when {&goods-proc_11_gds_5} then do:
      assign
      v-oldbh = widget-handle (entry(2, p-doc-code, {&delim-par}))
      v-newbh = widget-handle (entry(3, p-doc-code, {&delim-par}))
      v-changes-list = entry(4, p-doc-code, {&delim-par})
      file-name  = p-process-file-name
      v-has-oldbh = valid-handle(v-oldbh) and v-oldbh:available
      v-has-newbh = valid-handle(v-newbh) and v-newbh:available
      .
      if not v-has-newbh then do:
        undo, return error substitute("Не определен новый буфер").
      end.
      if not v-has-newbh
      and not v-has-oldbh then do:
        undo, return error substitute("Не определено ни одного буфера - ни старый, ни новый").
      end.
      if not v-has-oldbh
      and v-changes-list  = '' then do:
        undo, return error substitute("Не определен старый буфер и список изменений").
      end.
      if v-has-newbh
      and v-newbh:table <> {&table_goods} then do:
        undo, return error substitute("Передан неверный буфер вместо буфера для &1",  {&table_goods}).
      end.
      if v-changes-list = '' then do:
        v-changes-list2 = "gds-code,artic,prod-type,prod-code,stts,okdp,gds-name,gds-type,unit-base".
        do v-ii = 1 to num-entries(v-changes-list2 ):
          if v-oldbh:buffer-field(entry(v-ii, v-changes-list2)):buffer-value <> v-newbh:buffer-field(entry(v-ii, v-changes-list2)):buffer-value then do:
            v-flag = yes.
            leave.
          end.
        end.
        if not v-flag then return "return".
      end.
      else do:
        if lookup("gds-code", v-changes-list) = 0
        and lookup("stts", v-changes-list) = 0
        and lookup("unit-base", v-changes-list) = 0
        and lookup("artic", v-changes-list) = 0
        and lookup("prod-type", v-changes-list) = 0
        and lookup("prod-code", v-changes-list) = 0
        and lookup("okdp", v-changes-list) = 0
        and lookup("gds-name", v-changes-list) = 0
        and lookup("gds-type", v-changes-list) = 0
        and not(v-newbh:new) then do:
          return 'return'.
        end.
      end.
      for each buf_rule-call-param no-lock where
      buf_rule-call-param.codex_id = p-codex-id
      and buf_rule-call-param.ruleset_id = p-ruleset-id
      and buf_rule-call-param.call_id = p-call-id
      and buf_rule-call-param.order_id = p-order-id
      and buf_rule-call-param.rule_id = p-rule-id
      and buf_rule-call-param.param-name = "p-esys-id-list",
        first buf_ext-system no-lock where
              buf_Ext-system.esys-id = buf_rule-call-param.param-value-integer
          and buf_Ext-system.db-num = 0
          and buf_Ext-system.esys-have-export = yes
          and buf_Ext-system.esys-db-num-exp = g#db-num:
        v-esys-id-list = v-esys-id-list + (if v-esys-id-list = '' then '' else {&delim-nws}) + string(buf_ext-system.esys-id).
      end.
      if v-esys-id-list = '' then return "return".

      /*---------------------------&start-process-rule-call-param&-------------------------------*/
      find first buf_rule-call-param no-lock where
    buf_rule-call-param.codex_id = p-codex-id
    and buf_rule-call-param.ruleset_id = p-ruleset-id
    and buf_rule-call-param.call_id = p-call-id
    and buf_rule-call-param.order_id = p-order-id
    and buf_rule-call-param.rule_id = p-rule-id
    and buf_rule-call-param.param-name = "p-xsd-file"
    no-error.
    if available buf_rule-call-param then do:
      assign p-xsd-file = buf_rule-call-param.param-value-character.
    end.
  end. /*when {&goods-proc_11_gds_5}*/
  otherwise do:
    undo, return error substitute("Неверный вызов &1 для набора правил &2", vss-workfile , p-ruleset-id).
  end.
/*---------------------------&end-process-rule-call-param&-------------------------------*/
end case.
end. /*doe*/

end procedure. /* load-ruleset-context */