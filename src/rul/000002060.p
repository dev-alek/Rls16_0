/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 12, набор 2, 6

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/13/09
Author: Bakhtadze Natalya
Creation date: 10/13/09

---------------------------&start-codex_id=12;ruleset_id=2;-------------------------------
---------------------------&start-codex_id=12;ruleset_id=6;-------------------------------

---------------------------&end-codex_id=12;ruleset_id=2;-------------------------------
---------------------------&end-codex_id=12;ruleset_id=6;-------------------------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 12, набор 2,6".
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
{ bge/edoccl01.i }
&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)


/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-doc-code as character no-undo .
define variable v-newbh as handle no-undo .
define variable v-oldbh as handle no-undo .
define variable v-has-newbh as logical no-undo .
define variable v-has-oldbh as logical no-undo .
define variable v-changes-list as character no-undo .
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
define variable num-rec-pre as integer no-undo .
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable l-res as integer no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define variable v-esys-id-list as character no-undo .
define variable v-err-mess as character no-undo .
define variable v-cli-list-bh as handle no-undo .
define variable v-cli-list-handle as handle no-undo .
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.


{ str/dia2auto.i }
{ rul/seterror.i }
{ cmp/cli-list.i cli-list def "new shared" }

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
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-obj-name as character no-undo .
define variable v-obj-type-code as integer no-undo .
define variable v-stts as integer no-undo .
define variable v-pck-num-rec as integer no-undo init 1000.

define buffer buf_clients for ub.clients.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_firm for ub.firm.
define buffer buf_person for ub.person.



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
    when {&clients-proc_12_batchwork-routing_2} then do:
      if v-cli-list-bh:available then do:
        v-cli-list-bh:buffer-delete().
      end.
      run cb_get-next-cli-by-obj-type-code in v-cli-list-handle ( input v-current-obj-type
                                                                 ,input v-current-obj-code
                                                            ,input v-cli-list-bh
                                                            ).
      if v-cli-list-bh:available then do:
        if num-rec-pre > 0 then do:
          run write-counter in p-log-handle ( input substitute("Просмотрено клиентов списка &1, обработано  &2, из них удачно: &3", num-rec-pre, num-rec, num-rec-ok)).
        end.
        num-rec-pre = num-rec-pre + 1.
        v-current-obj-type = v-cli-list-bh:buffer-field("obj-type"):buffer-value.
        v-current-obj-code = v-cli-list-bh:buffer-field("obj-code"):buffer-value.
        v-obj-name = v-cli-list-bh:buffer-field("obj-name"):buffer-value.
      END.
      else do:
        v-current-obj-type = ''.
        v-current-obj-code = 0.
      end.
      if v-current-obj-code > 0 then do:
        num-rec = num-rec + 1.
        create firm.
        assign
        firm.referenceNo = v-current-obj-type + string(v-current-obj-code)
        firm.orgtype = v-current-obj-type
        firm.name = v-cli-list-bh::obj-name
        firm.stts = v-cli-list-bh::stts
        .
        if v-current-obj-type = {&cmp} then do:
          find first buf_sysconf no-lock where
                    buf_sysconf.host-code = v-current-obj-code no-error.
          firm.selfhost =  (available buf_sysconf).
          find first buf_firm no-lock where
                    buf_firm.firm-code = v-current-obj-code.
          assign
          firm.inn = buf_firm.inn
          firm.kpp =  buf_firm.kpp
          firm.okonh = buf_firm.okonh
          firm.okpo = buf_firm.okpo
          .
        end.
        if v-current-obj-type = {&prs} then do:
          assign
          firm.selfhost =  no
          .
          find first buf_person no-lock where
                    buf_person.psn-code = v-current-obj-code.
          assign
          firm.inn = buf_person.inn
          firm.kpp =  buf_person.kpp
          firm.okonh = buf_person.okonh
          firm.okpo = buf_person.okpo
          .
        end.
      end.
    end.
    when {&clients-proc_12_cli_6} then do:
      create firm.
      case v-newbh:table:
        when {&table_sysconf} then do:
          assign
          v-current-obj-type = {&cmp}
          v-current-obj-code = v-newbh:buffer-field("host-code"):buffer-value.
          find first buf_clients no-lock where
                  buf_clients.obj-type =  v-current-obj-type
              and buf_clients.obj-code = v-current-obj-code no-error.
          if not available buf_clients
          and v-newbh:new then return "return".
          assign
          firm.referenceNo = {&cmp} + string(v-current-obj-code)
          firm.orgtype = {&cmp}
          firm.name = buf_clients.obj-name
          firm.stts = buf_clients.stts
          firm.selfhost =  yes
          .
        end.
        when {&table_clients} then  do:
          assign
          v-current-obj-type = v-newbh:buffer-field("obj-type"):buffer-value
          v-current-obj-code = v-newbh:buffer-field("obj-code"):buffer-value.
          assign
          firm.referenceNo = v-current-obj-type + string(v-current-obj-code)
          firm.orgtype = v-current-obj-type
          firm.name = v-newbh::obj-name
          firm.stts = v-newbh::stts
          .
          if v-current-obj-type = {&cmp} then do:
            find first buf_sysconf no-lock where
                      buf_sysconf.host-code = v-current-obj-code no-error.
            firm.selfhost =  (available buf_sysconf).
            if not (v-newbh:new) then do:
              find first buf_firm no-lock where
                        buf_firm.firm-code = v-current-obj-code.
              assign
              firm.inn = buf_firm.inn
              firm.kpp =  buf_firm.kpp
              firm.okonh = buf_firm.okonh
              firm.okpo = buf_firm.okpo
              .
            end.
          end.
          if v-current-obj-type = {&prs} then do:
            assign
            firm.selfhost =  no
            .
            if not (v-newbh:new) then do:
              find first buf_person no-lock where
                        buf_person.psn-code = v-current-obj-code.
              assign
              firm.inn = buf_person.inn
              firm.kpp =  buf_person.kpp
              firm.okonh = buf_person.okonh
              firm.okpo = buf_person.okpo
              .
            end.
          end.
        end. /*when {&table_clients} then  do:*/
        when {&table_firm} then do:
          assign
          v-current-obj-type = {&cmp}
          v-current-obj-code = v-newbh:buffer-field("firm-code"):buffer-value
          .
          find first buf_firm no-lock where
                    buf_firm.firm-code = v-current-obj-code.
          find first buf_clients no-lock where
                    buf_clients.obj-type = v-current-obj-type
                and buf_clients.obj-code = v-current-obj-code.
          find first buf_sysconf no-lock where
                    buf_sysconf.host-code = v-current-obj-code no-error.
          assign
          firm.referenceNo = v-current-obj-type + string( v-current-obj-code)
          firm.orgtype = v-current-obj-type
          firm.name = buf_clients.obj-name
          firm.stts = buf_clients.stts
          firm.selfhost =  (available buf_sysconf)
          firm.inn = buf_firm.inn
          firm.kpp =  buf_firm.kpp
          firm.okonh = buf_firm.okonh
          firm.okpo = buf_firm.okpo
          .
        end.
        when {&table_person} then do:
          assign
          v-current-obj-type = {&prs}
          v-current-obj-code = v-newbh:buffer-field("psn-code"):buffer-value
          .
          find first buf_person no-lock where
                    buf_person.psn-code = v-current-obj-code.
          find first buf_clients no-lock where
                    buf_clients.obj-type = v-current-obj-type
                and buf_clients.obj-code = v-current-obj-code.
          assign
          firm.referenceNo = v-current-obj-type + string( v-current-obj-code)
          firm.orgtype = v-current-obj-type
          firm.name = buf_clients.obj-name
          firm.stts = buf_clients.stts
          firm.selfhost = no
          firm.inn = buf_person.inn
          firm.kpp =  buf_person.kpp
          firm.okonh = buf_person.okonh
          firm.okpo = buf_person.okpo
          .
        end.
      end case.
    end.
  end case.
  if v-current-obj-code > 0 then do:
    ExpData1:route-data_create-record( INPUT "firm") .
    ExpData1:route-data_copy-record( INPUT "firm", input (buffer firm:handle)) .
    IF ExpData1:esys-add-dump( INPUT "firm", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи клиента &1&2:&3&4"
                              , v-current-obj-type
                              , v-current-obj-code
                              , {&new-line}
                              , v-last-error-message
                              ).
      undo _main, return error v-last-error-message .
    end.
  end.
  if p-ruleset-id = {&clients-proc_12_cli_6}
  or (p-ruleset-id = {&clients-proc_12_batchwork-routing_2} and  num-rec modulo v-pck-num-rec = 0)
  or not v-cli-list-bh:available
  or v-current-obj-code = 0
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
  if p-ruleset-id = {&clients-proc_12_cli_6}
  or not v-cli-list-bh:available
  or v-current-obj-code = 0
  then do:
    leave _stroka.
  end.
  if p-ruleset-id = {&clients-proc_12_batchwork-routing_2} then do:
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
  when {&clients-proc_12_batchwork-routing_2} then do:
    /*найдем процедуру которая управляет списком*/
    { gbl/calltree.i 'cb_get-next-cli-by-obj-type-code' this-procedure:handle p-cont-handle v-cli-list-handle }

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
    v-cli-list-bh = buffer cli-list:handle.
  end.
  when {&clients-proc_12_cli_6} then do:
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
    case p-ruleset-id:
      when {&clients-proc_12_cli_6} then do:
        if v-has-newbh
        and lookup(v-newbh:table,  {&table_clients} + {&comma-char} +
                                  {&table_sysconf} + {&comma-char} +
                                    {&table_firm} + {&comma-char} +
                                    {&table_person} + {&comma-char} +
                                    {&table_shop} + {&comma-char} +
                                    {&table_store} ) = 0 then do:
          undo, return error substitute("Передан неверный буфер &1",  v-newbh:table).
        end.
      end.
    end case.
    if v-changes-list = '' then do:
      case v-newbh:table:
        when {&table_clients} then do:
          v-changes-list2 = "obj-type,obj-code,obj-name,stts,PS".
        end.
        when {&table_firm} then do:
          v-changes-list2 = "inn,kpp,okpo,okonh".
        end.
        when {&table_person} then do:
          v-changes-list2 = "inn,kpp,okpo,okonh".
        end.
        when {&table_sysconf} then do:
          v-changes-list2 = "host-code".
        end.
        otherwise do:
          return "return".
        end.
      end case.
      do v-ii = 1 to num-entries(v-changes-list2 ):
        if v-oldbh:buffer-field(entry(v-ii, v-changes-list2)):buffer-value <> v-newbh:buffer-field(entry(v-ii, v-changes-list2)):buffer-value then do:
          v-flag = yes.
          leave.
        end.
      end.
      if not v-flag then return "return".
    end.
    else do:
      case v-newbh:table:
        when {&table_clients} then do:
          v-changes-list2 = "obj-type,obj-code,obj-name,stts,PS".
        end.
        when {&table_firm} then do:
          v-changes-list2 = "inn,kpp,okpo,okonh".
        end.
        when {&table_person} then do:
          v-changes-list2 = "inn,kpp,okpo,okonh".
        end.
        when {&table_sysconf} then do:
          v-changes-list2 = "host-code".
        end.
      end case.
      _v-ii:
      do v-ii = 1 to num-entries(v-changes-list2):
        if lookup(entry(v-ii, v-changes-list2), v-changes-list) > 0 then do:
          v-flag = yes.
          leave _v-ii.
        end.
      end.
      if v-flag = no then return "return".
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
  end. /*when {&clients-proc_12_cli_6}*/
  otherwise do:
    undo, return error substitute("Неверный вызов &1 для набора правил &2", vss-workfile , p-ruleset-id).
  end.
end case.

/*---------------------------&end-process-rule-call-param&-------------------------------*/

end. /*doe*/

end procedure. /* load-ruleset-context */