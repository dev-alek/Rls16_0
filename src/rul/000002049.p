/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 20, набор 2

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/13/09
Author: Bakhtadze Natalya
Creation date: 10/13/09

---------------------------&start-codex_id=20;ruleset_id=2;-------------------------------

---------------------------&end-codex_id=20;ruleset_id=2;-------------------------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 20, набор 2".
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
{ ref/cntrlist.i cntrlist def "shared" }

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
define variable log-file-name                as character      no-undo init "process-thref.txt".
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
define variable v-name as character no-undo .
define variable v-alpha1 as character no-undo .
define variable v-countries-dump-ord as logical no-undo .
define buffer buf_country for ub.country.


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
  for each cntrlist
  break
  by cntrlist.alpha1
  On error undo _stroka, next _stroka
  On stop undo _stroka, next _stroka
  :
    /*Мы посылаем каждый баркод как отдельный товар в силу того что для "расширенной" схемы работы с ценами в ДКLink
    когда можно назначить отдельные цены по каждому объекту
    цена назначается на как бы на товар
    сделаем их как бы товар = наш баркод
    */
    assign
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
      v-countries-dump-ord = no
      .
    end.
    find first buf_country exclusive-lock where
              buf_country.alpha1 = cntrlist.alpha1
              no-error.
    if not available buf_country then do:
      &scop my-message substitute("Не найдена содержащаяся в списке страна &1", cntrlist.alpha1)
      {&display-message}.
      next _stroka.
    end.
    ExpData1:route-data_create-record( INPUT "countries") .
    if v-countries-dump-ord = no then do:
      IF ExpData1:esys-add-dump( INPUT "countries", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_dump-order=Rec_ID') = false  THEN do:
        v-err-mess = substitute("Ошибка при маршрутизации записи страны  &1:&2&3"
                                , buf_country.alpha1
                                , {&new-line}
                                , v-last-error-message
                                ).
        undo _main, return error v-last-error-message .
      end.
      v-countries-dump-ord.
    end.
    ExpData1:route-data_copy-field-character( INPUT "countries", "ID", INPUT  buf_country.alpha1 ) .
    ExpData1:route-data_copy-field-character( INPUT "countries", "Action", INPUT  {&gen-line-update} ) .
    ExpData1:route-data_copy-field-character( INPUT "countries", "Name", INPUT  buf_country.short-name).
    IF ExpData1:esys-add-dump( INPUT "countries", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи страны &1:&2&3"
                              , buf_country.alpha1
                              , {&new-line}
                              , v-last-error-message
                              ).
      undo _main, return error v-last-error-message .
    end.

    /* ------------------------- &end-rule& -------------------------------------*/

    /* ------------------------- &start-release-obj& -----------------------------------*/

    /* ------------------------- &end-release-obj& -------------------------------------*/

    num-rec-ok = num-rec-ok + 1.
    run write-counter in p-log-handle ( input substitute("Обработано записей списка: &1, из них удачно: &2", num-rec, num-rec-ok)).
    run get-stop-state in p-log-handle ( output v-stop) no-error .
    if v-stop then do:
        run write-log-and-file in p-log-handle (
                                                input 1
                                              , input log-file-name
                                              , input 1
                                              , input substitute("Процесс прерван пользователем")).
        leave _stroka.
    end.
    if last( cntrlist.alpha1)
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
define variable v-h as handle no-undo .
define variable v-changes-list2 as character no-undo .
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
      when {&thref-proc_20_batchwork-routing_2} then do:
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