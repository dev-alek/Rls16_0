/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 22

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/26/08
Author: Bakhtadze Natalya
Creation date: 05/26/08

---------------------------&start-codex_id=22;ruleset_id=2;-------------------------------
Отчеты
Маршрутизация отчетов во ВС
---------------------------&end-codex_id=22;ruleset_id=2;-------------------------------

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
define input parameter p0-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-process-dirs as character no-undo .
define input parameter p-save       as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 22, набор 2".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ rul/cl-hist.i "shared" }
{ gbl/key-rec.i }
{ gbl/gate-clb.i }
{ rul/tempcxml.i  }

/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-rep-code as character no-undo .
define variable v-current-doc-code as character no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .
define variable log-file-name                as character      no-undo init "calc-rep.log".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-last-error-message as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
define variable v-p-index as integer no-undo .
/*****************************/
define variable v-dirs as character no-undo .
define variable v-sign as integer no-undo .
define variable v-type as character no-undo .
define variable l-res as integer no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define variable v-xmlh as handle no-undo .
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_temp-xml-tables for temp-xml-tables.
v-xmlh = buffer buf_temp-xml-tables:handle.


{ str/dia2auto.i }
{ rul/seterror.i }


&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)




/*---------------------------&start-rule-call-param&-------------------------------*/

define variable p-esys-id as integer no-undo .
define variable p-xsd-file as character no-undo.
define variable p-dataseth as handle no-undo .

/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/

 { rul/context_f.i  begin-nws2esys-command }
 { rul/context_f.i  send-nws2esys-command }
 { rul/context_f.i  set-custom-esys-pck-name }
 { rul/context_f.i  delete-command }


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
&scop constructor_2 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input p-dataseth, input v-xmlh)
ExpData1 = new Route-data_{&constructor_2} .


/* ------------------------- &end-def-vars& -----------------------------------*/

if not this-procedure:persistent then do:
  run proc-main in this-procedure no-error .
  if error-status:error then do:
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
define variable v-err-mess as character no-undo .
define variable v_qh as handle no-undo .
define variable glog as logical no-undo .
define buffer buf_ext-system for ub.ext-system.

_main:
do transaction
on error  undo _main, retry _main
on stop   undo _main, retry _main
on endkey undo _main, retry _main
:
  if retry then do:
    v-esm = v-err-mess.
    if valid-handle(v_qh) then do:
      delete object v_qh no-error.
    end.
    if valid-handle(p-dataseth) then do:
      delete object p-dataseth no-error.
    end.
    &scop release_1 clear-data ( )
    ExpData1:Route-data_{&release_1} .
    if p-ruleset-id = 2
    then do:
      run write-log  in p-log-handle (
                                      input 0
                                    , "&DLine").
      &scop my-message substitute(".............(&1) Маршрутизация отчета закончилась ошибкой", p-rule-id)
      {&display-message}.
      &scop my-message substitute(".............&1", v-esm)
      {&display-message}.
      &scop my-message substitute(".............&1", v-rv)
      {&display-message}.
      v-rv = v-esm + {&new-line} + v-rv.
    end.
    return error v-rv.
  end. /*if retry then do:*/
  else do:
    if valid-handle(p-dataseth) = no then do:
      v-err-mess = substitute("Не удалось получить данные для маршрутизации - маршрутизация невозможна:&1&2&1&3"
                             , {&new-line}
                             , error-status:get-message(1)
                             , return-value
                             ).
      undo _main, retry _main .
    end.
    ExpData1:change-direction( 1). /*экспорт*/
    find first buf_ext-system no-lock where
              buf_ext-system.esys-id = p-esys-id
          and buf_ext-system.db-num = 0
              no-error.
    if not available buf_ext-system then do:
      v-err-mess = substitute("Не найдена ВС &1", p-esys-id).
      undo _main, retry _main .
    end.
    if not (buf_ext-system.esys-type > integer({&openxml-type-ordinal})) then do:
      v-err-mess = substitute("ВС &1 не имеет типа СПЕЦИАЛЬНАЯ - маршрутизация невозможна", p-esys-id).
      undo _main, retry _main .
    end.
    if buf_ext-system.esys-have-export = no then do:
      v-err-mess = substitute("Для ВС &1 не определена операция экспорта - маршрутизация невозможна", p-esys-id).
      undo _main, retry _main .
    end.
    /*можем маршрутизировать сразу сейчас - все уже лежит в dataset*/
    IF  context_begin-nws2esys-command ( input p-esys-id
                                      ,input buf_ext-system.esys-db-num-exp
                                      ,input p-dataseth:private-data
                                      ,input-output v-esys-cmd-proc-handle
                                      ,output v-esys-cmd-code) = false  THEN do:
      v-err-mess = v-last-error-message.
      undo _main, retry _main  .
    end.
    /*пройдем по всем таблицам*/
    for each buf_temp-xml-tables:
      create query v_qh.
      glog = v_qh:set-buffers( buf_temp-xml-tables.tbl-handle) no-error.
      if error-status:error
      or
      not glog then do:
        v-err-mess = substitute("Ошибка при попытке получить записи &1&2&3&2&4"
                                                                , buf_temp-xml-tables.tbl-name
                                                                , {&new-line}
                                                                , error-status:get-message(1)
                                                                , return-value).
        undo _main, retry _main .
      end.
      glog = v_qh:query-prepare( substitute( "for each &1 ", buf_temp-xml-tables.tbl-name)) no-error .
      if error-status:error
      or
      not glog then do:
        v-err-mess = substitute("Ошибка при попытке получить записи &1&2&3&2&4"
                                                                , buf_temp-xml-tables.tbl-name
                                                                , {&new-line}
                                                                , error-status:get-message(1)
                                                                , return-value).
        undo _main, retry _main .
      end.
      glog = v_qh:query-open no-error .
      if error-status:error
      or not glog then do:
        v-err-mess =  substitute("Ошибка при попытке получить записи &1&2&3&2&4"
                                      , buf_temp-xml-tables.tbl-name
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      , return-value).

        undo _main, retry _main.
      end.
      _stroka:
      repeat:
        v_qh:get-next().
        if v_qh:query-off-end then do:
          leave _stroka.
        end.
        /*маршрутизируем*/
        IF  ExpData1:esys-add-dump( INPUT buf_temp-xml-tables.tbl-name
                                  , INPUT v-esys-cmd-proc-handle
                                  , INPUT v-esys-cmd-code
                                  , '+update') = false  THEN do:
          v-err-mess = v-last-error-message .
          undo _main, retry _main.
        end.
      end.
      delete object v_qh.
    end. /*for each buf_temp-xml-tables*/
    IF  context_send-nws2esys-command( input p-esys-id
                                     , input buf_ext-system.esys-db-num-exp
                                     , input p-dataseth:private-data
                                     , input v-esys-cmd-proc-handle
                                     , input v-esys-cmd-code
                                     , input g#userid) = false  THEN do:
      v-err-mess = v-last-error-message.
      undo _main, retry _main  .
    end.
    &scop release_1 clear-data ( )
    ExpData1:Route-data_{&release_1} .
    if valid-handle(p-dataseth) then do:
      delete object p-dataseth no-error.
    end.
  end. /*else not retry*/
end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.

do
on error undo, return error
:
/*---------------------------&start-process-rule-call-param&-------------------------------*/


for each buf_temp-rule-call-param:
  delete buf_temp-rule-call-param.
end.

 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-esys-id"
 no-error.

if available buf_rule-call-param then do:
assign p-esys-id = buf_rule-call-param.param-value-integer.
end.

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
run cb_rcps-run_get-value in p-cont-handle ( input p-call-id
                                            ,input p-codex-id
                                            ,input p-ruleset-id
                                            ,input p-order-id
                                            ,input "p-dataseth"
                                            ,input-output v-p-index
                                            ,output v-value-character
                                            ,output v-value-date
                                            ,output v-value-decimal
                                            ,output v-value-integer
                                            ,output v-value-logical).
p-dataseth = widget-handle(v-value-character).





/*---------------------------&end-process-rule-call-param&-------------------------------*/
    case p-ruleset-id:
      when 2
      then do:
        assign
        v-sign = 0
        v-current-host-code = p0-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        v-dirs  = p-process-dirs
        v-current-rep-code  = p-doc-code
        .
        run gate-clb_fill-xml-tables in this-procedure ( input p-dataseth
                                                      ,input-output v-xmlh) no-error.
        if error-status:error then do:
          run gate-clear in this-procedure ( input p-dataseth
                                           , input v-xmlh) no-error.
          undo, return error substitute("Ошибка при получении схемы данных отчета:&1&2&1&3"
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value ).
        end.
      end.
   end case.
end. /*doe*/

end procedure. /* load-ruleset-context */

/*не удалять!!!!*/