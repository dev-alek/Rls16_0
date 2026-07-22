/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 12, набор 2

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/13/09
Author: Bakhtadze Natalya
Creation date: 10/13/09

---------------------------&start-codex_id=12;ruleset_id=2;-------------------------------

---------------------------&end-codex_id=12;ruleset_id=2;-------------------------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 12, набор 2".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ rul/ruleset_.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
{ gbl/gate-clb.i }
{ gbl/key-rec.i }
{ bge/tmpcxmlh.i }
{ gbl/lib-gate.i }
{ cmp/cli-list.i cli-list def "shared" }

&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)


/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-gds-code as integer no-undo .
define variable v-current-artic as character no-undo .
define variable v-current-prod-type as character no-undo .
define variable v-current-prod-code as integer no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-doc-code as character no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .
define variable log-file-name                as character      no-undo init "process-cli.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-last-error-message as character no-undo .
/*****************************/
define variable file-name as char.
define variable v-sign as integer no-undo .
define variable v-gate-rec as character no-undo .
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable l-res as integer no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define variable v-esys-id-list as character no-undo .
define variable v-err-mess as character no-undo .
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.

{ str/dia2auto.i }
{ rul/seterror.i }

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
on stop undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
:

define variable v-err as logical no-undo .
define variable v-pck-num-rec as integer no-undo init 1000.
define variable v-obj-name as character no-undo .
define variable v-obj-type-code as integer no-undo .
define variable v-clients-dump-ord as logical no-undo .
define variable v-stores-dump-ord as logical no-undo .
define buffer buf_clients for ub.clients.


/* ------------------------- &end-hn-option& -----------------------------------*/
  /* ------------------------- &start-rule& -----------------------------------*/
  IF  ExpData1:route-data_push-xmlschema( INPUT p-xsd-file ) = false  THEN do:
    &scop my-message substitute("Ошибка при создании гейта &1 для маршрутизации:&2&3&2&4" ~
                                , p-xsd-file ~
                                , ~{&new-line~} ~
                                , error-status:get-message(1) ~
                                , v-last-error-message)
    {&display-message}.
    undo _main, return error '' .
  end.
  _stroka:
  for each cli-list
  break
  by cli-list.obj-type
  by cli-list.obj-code
  On error undo _stroka, next _stroka
  On stop undo _stroka, next _stroka
  :
    /*Мы посылаем каждый баркод как отдельный товар в силу того что для "расширенной" схемы работы с ценами в ДКLink
    когда можно назначить отдельные цены по каждому объекту
    цена назначается на как бы на товар
    сделаем их как бы товар = наш баркод
    */
    assign
    v-current-obj-code = cli-list.obj-code
    v-current-obj-type = cli-list.obj-type
    v-obj-name = cli-list.obj-name
    num-rec = num-rec + 1
    .
    /* ------------------------- &start-rule& -----------------------------------*/
    IF num-rec = 1
    or num-rec modulo v-pck-num-rec = 1
    THEN do:
      IF  context_begin-esys-command( input v-esys-id-list
                                    , input-output v-esys-cmd-proc-handle
                                    , output v-esys-cmd-code) = false  THEN do:
        &scop my-message substitute("Ошибка при инициации маршрутизации через гейт &1&2:&3&2&4" ~
                                     ,p-xsd-file ~
                                     , ~{&new-line~} ~
                                     , error-status:get-message(1)  ~
                                     , v-last-error-message)
        {&display-message}.
        undo _main, return error ''.
      end.
      assign
      v-clients-dump-ord = no
      v-stores-dump-ord = no
      .
    end.
    find first buf_clients exclusive-lock where
              buf_clients.obj-type = cli-list.obj-type
          and buf_clients.obj-code = cli-list.obj-code
              no-error.
    if not available buf_clients then do:
      &scop my-message substitute("Не найден содержащийся в списке контрагент &1&2", cli-list.obj-type, cli-list.obj-code)
      {&display-message}.
      next _stroka.
    end.
    case buf_clients.obj-type:
      when {&prs}
      or when {&cmp} then do:
        v-obj-type-code = (if buf_clients.obj-type = {&cmp}
                          then  1000000000
                          else 0) +
                          buf_clients.obj-code.
        ExpData1:route-data_create-record( INPUT "clients") .
        if v-clients-dump-ord = no then do:
          IF ExpData1:esys-add-dump( INPUT "clients", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_dump-order=Rec_ID') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации записи по клиенту  &1&2:&3&4"
                                    , buf_clients.obj-type
                                    , buf_clients.obj-code
                                    , {&new-line}
                                    , v-last-error-message
                                    ).
            undo _main, return error v-last-error-message .
          end.
          v-clients-dump-ord = yes.
        end.
        ExpData1:route-data_copy-field-integer( INPUT "clients", "ID", INPUT  v-obj-type-code ) .
        ExpData1:route-data_copy-field-character( INPUT "clients", "Action", INPUT  {&gen-line-update} ) .
        ExpData1:route-data_copy-field-character( INPUT "clients", "Name", INPUT  buf_clients.obj-name).
        IF ExpData1:esys-add-dump( INPUT "clients", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
          v-err-mess = substitute("Ошибка при маршрутизации записи клиента &1&2:&3&4"
                                  , buf_clients.obj-type
                                  , buf_clients.obj-code
                                  , {&new-line}
                                  , v-last-error-message
                                  ).
          undo _main, return error v-last-error-message .
        end.
      end.
      when {&shop}
      or when {&stock} then do:
        v-obj-type-code = (if buf_clients.obj-type = {&stock}
                          then  100000
                          else 0) +
                          buf_clients.obj-code.
        ExpData1:route-data_create-record( INPUT "stores") .
        if v-stores-dump-ord = no then do:
          IF ExpData1:esys-add-dump( INPUT "stores", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_dump-order=Rec_ID') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации записи по клиенту  &1&2:&3&4"
                                    , buf_clients.obj-type
                                    , buf_clients.obj-code
                                    , {&new-line}
                                    , v-last-error-message
                                    ).
            undo _main, return error v-last-error-message .
          end.
          v-stores-dump-ord = yes.
        end.
        ExpData1:route-data_copy-field-integer( INPUT "stores", "ID", INPUT  v-obj-type-code ) .
        ExpData1:route-data_copy-field-character( INPUT "stores", "Name", INPUT  buf_clients.obj-name).
        ExpData1:route-data_copy-field-character( INPUT "stores", "Action", INPUT  {&gen-line-update} ) .
        ExpData1:route-data_copy-field-integer( INPUT "stores", "Price_income",    INPUT  v-obj-type-code).
        ExpData1:route-data_copy-field-integer( INPUT "stores", "Price_outcome",   INPUT  v-obj-type-code).
        ExpData1:route-data_copy-field-integer( INPUT "stores", "Price_inventory", INPUT  v-obj-type-code).
        IF ExpData1:esys-add-dump( INPUT "stores", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
          v-err-mess = substitute("Ошибка при маршрутизации записи клиента &1&2:&3&4"
                                  , buf_clients.obj-type
                                  , buf_clients.obj-code
                                  , {&new-line}
                                  , v-last-error-message
                                  ).
          undo _main, return error v-last-error-message .
        end.
      end.
    end case.

    /* ------------------------- &end-rule& -------------------------------------*/

    /* ------------------------- &start-release-obj& -----------------------------------*/

    /* ------------------------- &end-release-obj& -------------------------------------*/

    num-rec-ok = num-rec-ok + 1.
    run write-counter in p-log-handle ( input substitute("Обработано контрагентов списка: &1, из них удачно: &2", num-rec, num-rec-ok)).
    run get-stop-state in p-log-handle ( output v-stop) no-error .
    if v-stop then do:
        run write-log-and-file in p-log-handle (
                                                input 1
                                              , input log-file-name
                                              , input 1
                                              , input substitute("Процесс прерван пользователем")).
        leave _stroka.
    end.
    if last( cli-list.obj-code)
    or num-rec modulo v-pck-num-rec = 0
    then do:
      IF  context_send-esys-command( input v-esys-id-list, input v-esys-cmd-proc-handle, input v-esys-cmd-code, input g#userid) = false  THEN do:
        undo _main, return error v-last-error-message .
      end.
      &scop release_1 clear-data ( )
      ExpData1:Route-data_{&release_1} .
    end.
  end. /*for each gds-list where*/

  /* ------------------------- &end-rule& -------------------------------------*/

  /* ------------------------- &start-release-obj& -----------------------------------*/


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
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_ext-system for ub.ext-system.

do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo , return error substitute( "&1. stop", vss-workfile )
on endkey undo , return error substitute( "&1. endkey", vss-workfile )
:


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

/*---------------------------&end-process-rule-call-param&-------------------------------*/

    case p-ruleset-id:
      when {&clients-proc_12_batchwork-routing_2} then do:
        assign
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        .
      end.
      otherwise do:
        undo, return error substitute("Неверный вызов &1 для набора правил &2", vss-workfile , p-ruleset-id).
      end.
    end case.
end. /*doe*/

end procedure. /* load-ruleset-context */