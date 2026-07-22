block-level on error undo, throw.
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

---------------------------&start-codex_id=22;ruleset_id=1;-------------------------------
Отчеты
Выполнение отчетов по расписанию
---------------------------&end-codex_id=22;ruleset_id=1;-------------------------------

*/


/*---------------------------&start-using-class&-------------------------------*/

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 22, набор 1".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ rul/cl-hist.i "shared" }
{ gbl/key-rec.i }
{ rep/tmpcxmlr.i tables-def,dataset-def t }
{ rul/ruleset_.i }

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
/*****************************/
define variable v-dirs as character no-undo .
define variable v-sign as integer no-undo .
define variable v-type as character no-undo .
define variable l-res as integer no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_report-header for report-headert.
define buffer buf_report-parameters for report-parameterst.
define buffer buf_report-errors for report-errorst.


{ str/dia2auto.i }
{ rul/seterror.i }


&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)




/*---------------------------&start-rule-call-param&-------------------------------*/

define variable p-xsd-file as character no-undo.


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
define variable p-data-datetime as datetime no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-cli-list as character no-undo .
define variable v-report-id as character no-undo .
define variable v-start-datetime as datetime no-undo .
define variable v-dataseth as handle no-undo .
define variable v-xmlh as handle no-undo .
define variable glog as logical no-undo .
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_clients for ub.clients.
_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
:
  for each buf_temp-rule-call-param where
          buf_temp-rule-call-param.param-name ="p-shops"
      and buf_temp-rule-call-param.p-index > 0 :
    find first buf_clients no-lock where
              buf_clients.obj-type = {&shop}
         and  buf_clients.obj-code = buf_temp-rule-call-param.param-value-integer no-error.
    if available buf_clients then do:
      v-cli-list = v-cli-list + (if v-cli-list = '' then '' else {&comma-char}) + string(recid(buf_clients)).
     end.
  end.
  /*заполняем шапку отчета*/
  empty temp-table report-headert.
  empty temp-table report-parameterst.
  empty temp-table report-errorst.
  v-report-id = substitute("&1/&2", p-profile-id, p-rule-id).
  v-start-datetime = cur-time-datetime().
  p-data-datetime =  cur-time-datetime().
  v-today = date(p-data-datetime).
  v-time = mtime(p-data-datetime) / 1000.
  run cb_write-report-parameter in p-parent-handle (
                                                      input (buffer report-parameterst:handle)
                                                     ,input v-report-id
                                                     ,input "p-data-datetime"
                                                     ,input "Дата-время"
                                                     ,input {&abl-datatype-character}
                                                     ,input string(p-data-datetime)
                                                     ,input ?
                                                     ,input 0.0
                                                     ,input 0
                                                     ,input no
                                                     ,input 0
                                                     ,input 'Дата-время актуальность данных отчета'
                                                     ).

  run rep/r-dispet.p (
                       input parparentproc
                      ,input p-parent-handle
                      ,input p-log-handle
                      ,input p-cont-handle
                      ,input this-procedure:handle /*p-call-handle*/
                      ,input (buffer report-errorst:handle)
                      ,input (buffer report-destinationt:handle)
                      ,input substitute("&1/&2", p-profile-id, p-rule-id)
                      ,input p-xsd-file
                      ,input log-file-name
                      ,input integer({&repcalc-type-schedule}) /*p-batch*/
                      ,input p-codex-id
                      ,input p-ruleset-id
                      ,input v-time
                      ,input v-today
                      ,input v-cli-list
                      ,input no  /*p-excel*/
                      ,input yes  /*p-xml*/
                      ,input '' /*p-dir-excel*/
                      ,input '' /*p-dir-xml*/
                      ,output v-dataseth
                      ,output v-xmlh
                      ) no-error.
  if error-status:error then do:
    v-esm = error-status :get-message (1).
    v-rv = return-value .
    if p-ruleset-id = 1
    then do:
      run write-log  in p-log-handle (
                                      input 0
                                    , "&DLine").
      &scop my-message substitute(".............Расчет отчета &1 закончился ошибкой", p-rule-id)
      {&display-message}.
      &scop my-message substitute(".............&1", v-esm)
      {&display-message}.
      &scop my-message substitute(".............&1", v-rv)
      {&display-message}.
      v-rv = v-esm + {&new-line} + v-rv.
    end.
    return error v-rv.
  end.
  else do:
    run cb_fill-report-header in p-parent-handle ( input buffer buf_report-header:handle
                                                  ,input v-report-id
                                                  ,input "dispet"
                                                  ,input "Отчет диспетчера"
                                                  ,input v-start-datetime
                                                  ,input cur-time-datetime()
                                                  ).
    run cb_fill-report-parameters in p-parent-handle ( input buffer buf_report-parameters:handle
                                                      ,input v-report-id
                                                      ).
    glog = v-dataseth:copy-dataset (
                            dataset reportheadertypet:handle
                          , no /*append-mode*/
                          , yes /*replace-mode*/
                          , yes /*loose-mode*/
                          ) no-error .
    if error-status:error
    or not glog
    then do:
      &scop my-message substitute("!!Не удалось заполнить блок параметров!!! &1" ~
                                  , error-status:get-message(1) )
      {&display-message}.
    end.
    /*запишем в output параметры в контейнер*/
    run cb_rcps-run_set-value in p-cont-handle (
                                                 input p-call-id
                                                ,input p-codex-id
                                                ,input p-ruleset-id
                                                ,input p-order-id
                                                ,INPUT "p-dataseth"
                                                ,INPUT 0 /*p-index*/
                                                ,input {&script-parmode-output}
                                                ,INPUT string(v-dataseth) /*p-value-character*/
                                                ,INPUT ? /*p-value-date*/
                                                ,INPUT 0.0 /*p-value-decimal*/
                                                ,INPUT 0 /*p-value-integer*/
                                                ,INPUT no /*p-value-logical*/
                                                ) no-error.
    if error-status:error then do:
      &scop my-message substitute("!!Не удалось заполнить передать OUTPUT параметры правила!!! &1&2&1&3" ~
                                 , ~{&new-line~} ~
                                  , error-status:get-message(1) )
      {&display-message}.
    end.
  end.
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

for each buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-shops"
and buf_rule-call-param.p-index > 0:
  create buf_temp-rule-call-param.
  buffer-copy buf_rule-call-param to buf_temp-rule-call-param.
  release buf_temp-rule-call-param.
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



/*---------------------------&end-process-rule-call-param&-------------------------------*/
    case p-ruleset-id:
      when {&rep-proc_22_batchwork_1}
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
      end.
   end case.
end. /*doe*/

end procedure. /* load-ruleset-context */

/*не удалять!!!!*/