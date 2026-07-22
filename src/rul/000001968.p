/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 14

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/19/08
Author: Bakhtadze Natalya
Creation date: 06/19/08

---------------------------&start-codex_id=13;ruleset_id=1;-------------------------------
Операции над списком групп клиентов
Маршрутизация списка групп клиентов во внешнюю систему
---------------------------&end-codex_id=13;ruleset_id=1;-------------------------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 13".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
&glob cmd-proc-handle p-cmd-proc-handle
&glob cmd-code p-cmd-code
{ nws/temp-cmd.i "SHARED" }
{ rul/cl-hist.i "shared" }
{ gbl/gate-clb.i }
{ ref/cgrplist.i cgrp-list def "SHARED" }

/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-node-code as integer no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .
define variable log-file-name                as character      no-undo init "process-cli-grp-list.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-last-error-message as character no-undo .
/*****************************/
define variable file-name as char.
define variable v-sign as integer no-undo .
define variable v-gate-rec as character no-undo .
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable v-esys-id-list-start as character no-undo .
define variable v-pck-num-rec as integer no-undo init 1000.


{ rul/seterror.i }

define buffer buf_temp-cmd for temp-cmd.
define shared temp-table tt0-rule-call-param no-undo like ub.rule-call-param.

&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~).            ~
          assign v-view-log = yes



/*---------------------------&start-rule-call-param&-------------------------------*/

 define variable p-esys-id-list as integer no-undo.
 define variable p-xsd-file as character no-undo.

/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/
{ rul/context_f.i  begin-esys-command }
{ rul/context_f.i  send-esys-command }


/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run garbcoll_clear in this-procedure .
end.

run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error.
if error-status:error then do:
  undo, return error return-value .
end.

/* ------------------------- &start-def-vars& -----------------------------------*/

define variable ExpData1 as class Route-data_ no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle)
ExpData1 = new Route-data_{&constructor_1} .

/* ------------------------- &end-def-vars& -----------------------------------*/

if not this-procedure:persistent then do:
  run proc-main in this-procedure no-error .
  if error-status:error then do:
      run garbcoll_clear in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  run garbcoll_clear in this-procedure .
end.

procedure proc-main :

_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
:

  define variable v-ii as integer no-undo .
  define variable v-pck-num-rec as integer no-undo init 1000.
  define variable v-next-file as logical no-undo .
  define buffer buf_cli-grp for ub.cli-grp.
  define buffer buf_ext-system for ub.ext-system.

/*надо найти настройки маршрутизации и записи истории для групп клиентов*/

  _stroka:
  for each cgrp-list
  break
  by entry(1, cgrp-list.full-name, {&slash-char})
  On error undo _stroka, next _stroka
  :
    assign
    v-current-node-code = cgrp-list.node-code
    num-rec = num-rec + 1
    .

    /* ------------------------- &start-rule& -----------------------------------*/
    IF num-rec = 1
    or num-rec modulo v-pck-num-rec = 1
    THEN do:
      IF  ExpData1:route-data_read-xmlschema( INPUT p-xsd-file) = false  THEN do:
        undo _main, return error v-last-error-message .
      end.
      IF  context_begin-esys-command( input v-esys-id-list-start, input-output v-esys-cmd-proc-handle, output v-esys-cmd-code) = false  THEN do:
        undo _main, return error v-last-error-message .
      end.
    end.
    if p-save >= 0 then do:
      find first buf_cli-grp exclusive-lock where
                buf_cli-grp.node-code = cgrp-list.node-code no-error.
    end.
    else do:
      find first buf_cli-grp no-lock where
                buf_cli-grp.node-code = cgrp-list.node-code no-error.
    end.
    if not available buf_cli-grp then do:
      &scop my-message substitute("Не найдена содержащаяся в списке группа клиентов с вн.кодом &1", cgrp-list.node-code)
      {&display-message}.
      next _stroka.
    end.
    ExpData1:route-data_create-record( INPUT "cli-grp-01") .
    ExpData1:route-data_copy-record( INPUT "cli-grp-01", INPUT  (buffer cgrp-list:handle) ) .
    ExpData1:route-data_copy-field( INPUT "cli-grp-01"
                                    , INPUT "full-name"
                                    , INPUT (buffer cgrp-list:handle:buffer-field("full-name")) ) .

    IF  ExpData1:esys-add-dump( INPUT "cli-grp-01", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      undo _main, return error v-last-error-message .
    end.

    /* ------------------------- &end-rule& -------------------------------------*/

    /* ------------------------- &start-release-obj& -----------------------------------*/

    /* ------------------------- &end-release-obj& -------------------------------------*/

    num-rec-ok = num-rec-ok + 1.
    run write-counter in p-log-handle ( input substitute("Обработано групп клиентов: &1, из них удачно: &2", num-rec, num-rec-ok)).
    run get-stop-state in p-log-handle ( output v-stop) no-error .
    if v-stop then do:
        run write-log-and-file in p-log-handle (
                                                input 1
                                              , input log-file-name
                                              , input 1
                                              , input substitute("Процесс прерван пользователем")).
        leave _stroka.
    end.
    if num-rec modulo v-pck-num-rec = 0 then do:
      v-next-file = yes.
    end.
    if last( entry(1, cgrp-list.full-name, {&slash-char}))
    or (v-next-file  and last-of(entry(1, cgrp-list.full-name, {&slash-char})))
    then do:
      v-next-file = no.
      IF  context_send-esys-command( input v-esys-id-list-start, input v-esys-cmd-proc-handle, input v-esys-cmd-code, input g#userid) = false  THEN do:
        undo _main, return error v-last-error-message .
      end.
      &scop release_1 clear-data ( )
      ExpData1:Route-data_{&release_1} .
    end.
  end. /*for each temp_grplib_grp where*/
  ExpData1:route-data_clear-xmlschema ( ).
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Обработано групп клиентов: &1, из них удачно: &2", num-rec, num-rec-ok)).
  ExpData1:route-data_clear-xmlschema ( ).

end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for tt0-rule-call-param.
define buffer buf_ext-system for ub.ext-system.

  do
  on error undo, return error
  :
/*---------------------------&start-process-rule-call-param&-------------------------------*/
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
  v-esys-id-list-start = v-esys-id-list-start + (if v-esys-id-list-start = '' then '' else {&delim-nws}) + string(buf_ext-system.esys-id).
  assign
  v-pck-num-rec = min(v-pck-num-rec, (if buf_ext-system.esys-max-p-size > 0
                                      then buf_ext-system.esys-max-p-size
                                      else v-pck-num-rec)).

end.
if v-esys-id-list-start = '' then return "return".

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


/*---------------------------&end-process-rule-call-param&-------------------------------*/
    case p-ruleset-id:
      when 1 then do:
        assign
        v-sign = 1
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        file-name  = p-process-file-name
        .
      end.
    end case.
  end. /*doe*/

end procedure. /* load-ruleset-context */

/*не удалять!!!!*/