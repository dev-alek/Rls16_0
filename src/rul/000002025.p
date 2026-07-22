/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 20

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/03/09
Author: Bakhtadze Natalya
Creation date: 03/03/09

---------------------------&start-codex_id=20;ruleset_id=1;-------------------------------
Операции над списком групп товаров
Экспорт списка групп товаров в XML файл
---------------------------&end-codex_id=20;ruleset_id=1;-------------------------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 20".
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
{ rul/rum-fn.i }
{ bge/tmpcxmlh.i }

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
define variable log-file-name                as character      no-undo init "process-thref.txt".
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

 define variable p-xsd-file as character no-undo.
 define variable p-pck-num-rec as integer no-undo .
 define variable p-export-grp as logical no-undo .
 define variable p-db-num as integer no-undo .

/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/


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
  define variable v-loc-file-name as character no-undo .
  define variable v-next-file as logical no-undo .
  define variable v-margins-range     as integer           no-undo.
  define variable v-margins-exists    as logical           no-undo.
  define variable v-increase-range    as integer           no-undo.
  define variable v-increase-exists   as logical           no-undo.
  define variable v-min-marg          as decimal           no-undo.
  define variable v-max-marg          as decimal           no-undo.
  define variable v-increase-pc       as decimal           no-undo.
  define variable v-round-method      as character         no-undo .
  define variable v-rmethod-range     as integer           no-undo .
  define variable v-rmethod-exists    as logical           no-undo .
  define variable v-base              as decimal           no-undo .
  define variable v-round-method-str  as character         no-undo .

  define buffer buf_scales for ub.scales.
  define buffer locked_scales for ub.scales.
  define buffer locked_slave-scales for ub.scales.
  define buffer buf_scales-gds for ub.scales-gds.
  define buffer locked_scales-gds for ub.scales-gds.
  define buffer buf_scales-grp for ub.scales-grp.
  define buffer locked_scales-grp for ub.scales-grp.
  define buffer buf_scales-attr for ub.scales-attr.
  define buffer locked_scales-attr for ub.scales-attr.

  v-loc-file-name = file-name.
  _stroka:
  for each buf_scales no-lock where buf_scales.db-num = p-db-num
  and buf_scales.master = 0
  break
  by buf_scales.scales-num
  On error undo _stroka, next _stroka
  :

    assign
    num-rec = num-rec + 1
    .

    /* ------------------------- &start-rule& -----------------------------------*/
    IF num-rec = 1
    or num-rec modulo p-pck-num-rec = 1
    THEN do:
      IF  ExpData1:route-data_read-xmlschema( INPUT p-xsd-file) = false  THEN do:
        undo _main, return error v-last-error-message .
      end.
    end.
    if p-save >= 0 then do:
      find first locked_scales exclusive-lock where
                locked_scales.db-num = p-db-num
            and locked_scales.scales-num = buf_scales.scales-num  no-error.
    end.
    else do:
      find first locked_scales no-lock where
                locked_scales.db-num = p-db-num
            and locked_scales.scales-num = buf_scales.scales-num  no-error.
    end.
    if not available locked_scales then do:
      &scop my-message substitute("Не найдены весы &1 по БД &2", buf_scales.scales-num, buf_scales.db-num)
      {&display-message}.
      next _stroka.
    end.
    ExpData1:route-data_create-record( INPUT "scales-01") .
    ExpData1:route-data_copy-record( INPUT "scales-01", INPUT  (buffer locked_scales:handle) ) .
    for each locked_slave-scales no-lock where
            locked_slave-scales.db-num = buf_scales.db-num
       and  locked_slave-scales.master = buf_scales.scales-num
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
      ExpData1:route-data_create-record( INPUT "slave-scales-01") .
      ExpData1:route-data_copy-record( INPUT "slave-scales-01", INPUT  (buffer locked_slave-scales:handle) ) .
    end.
    for each buf_scales-gds no-lock where
            buf_scales-gds.db-num = buf_scales.db-num
       and  buf_scales-gds.scales-num = buf_scales.scales-num
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
       find first locked_scales-gds exclusive-lock where
                recid(locked_scales-gds) = recid(buf_scales-gds) no-error.
       if not available locked_scales-gds then do:
       end.
       if available locked_scales-gds then do:
        ExpData1:route-data_create-record( INPUT "scales-gds-01") .
        ExpData1:route-data_copy-record( INPUT "scales-gds-01", INPUT  (buffer locked_scales-gds:handle) ) .
       end.
    end.
    for each buf_scales-grp no-lock where
            buf_scales-grp.db-num = buf_scales.db-num
       and  buf_scales-grp.scales-num = buf_scales.scales-num
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
       find first locked_scales-grp exclusive-lock where
                recid(locked_scales-grp) = recid(buf_scales-grp) no-error.
       if not available locked_scales-grp then do:
       end.
       if available locked_scales-grp then do:
        ExpData1:route-data_create-record( INPUT "scales-grp-01") .
        ExpData1:route-data_copy-record( INPUT "scales-grp-01", INPUT  (buffer locked_scales-grp:handle) ) .
       end.
    end.
    for each buf_scales-attr no-lock where
            buf_scales-attr.db-num = buf_scales.db-num
       and  buf_scales-attr.scales-num = buf_scales.scales-num
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
       find first locked_scales-attr exclusive-lock where
                recid(locked_scales-attr) = recid(buf_scales-attr) no-error.
       if not available locked_scales-attr then do:
       end.
       if available locked_scales-attr then do:
        ExpData1:route-data_create-record( INPUT "scales-attr-01") .
        ExpData1:route-data_copy-record( INPUT "scales-attr-01", INPUT  (buffer locked_scales-attr:handle) ) .
       end.
    end.

    /* ------------------------- &end-rule& -------------------------------------*/

    /* ------------------------- &start-release-obj& -----------------------------------*/

    /* ------------------------- &end-release-obj& -------------------------------------*/

    num-rec-ok = num-rec-ok + 1.
    run write-counter in p-log-handle ( input substitute("Обработано весов: &1, из них удачно: &2", num-rec, num-rec-ok)).
    run get-stop-state in p-log-handle ( output v-stop) no-error .
    if v-stop then do:
        run write-log-and-file in p-log-handle (
                                                input 1
                                              , input log-file-name
                                              , input 1
                                              , input substitute("Процесс прерван пользователем")).
        leave _stroka.
    end.
    if num-rec modulo p-pck-num-rec = 0
    or last(buf_scales.scales-num)
    then do:
      v-next-file = yes.
    end.
    if v-next-file
    then do:
      /*записать файл*/
      v-next-file = no.
      if not ExpData1:write-xml(v-loc-file-name, integer(trunc(num-rec / p-pck-num-rec, 0))) then do:
        undo _main, return error .
      end.
      v-loc-file-name = rum-fn_get-next-file-name ( file-name , integer(trunc(num-rec / p-pck-num-rec, 0))).
      &scop release_1 clear-data ( )
      ExpData1:Route-data_{&release_1} .
    end.
  end. /*for each buf_scales  where*/
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Обработано весов: &1, из них удачно: &2", num-rec, num-rec-ok)).
  ExpData1:route-data_clear-xmlschema ( ).

end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for tt0-rule-call-param.

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
and buf_rule-call-param.param-name = "p-xsd-file"
 no-error.
if available buf_rule-call-param then do:
assign p-xsd-file = buf_rule-call-param.param-value-character.
end.

 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-pck-num-rec"
 no-error.
if available buf_rule-call-param then do:
assign p-pck-num-rec = buf_rule-call-param.param-value-integer.
end.

 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-export-grp"
 no-error.
if available buf_rule-call-param then do:
assign p-export-grp = buf_rule-call-param.param-value-logical.
end.

 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-db-num"
 no-error.
if available buf_rule-call-param then do:
assign p-db-num = buf_rule-call-param.param-value-integer.
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