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
{ cmp/r-page1.i new }
{ cmp/r-pril.i  new }
{ trg/factord.i }
{ gbl/gate-clb.i }
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
define variable p-shift-days-to-report as integer no-undo .


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
define variable v-report-id as character no-undo .
define variable v-start-datetime as datetime no-undo .
define variable v-base-code as integer no-undo .
define variable v-dataseth as handle no-undo .
define variable v-xmlh as handle no-undo .
define variable glog as logical no-undo .
define variable v-found as logical no-undo .
define variable v-last-shift-fact-order as decimal no-undo .
define variable v-fact-order  as decimal no-undo .
define variable v-shift-end-fact-order as decimal no-undo .
define variable v-day-end-fact-order as decimal no-undo .
define variable l-shift-on as logical no-undo .
define variable v-gate-rec as character no-undo .
define variable v-longchar as longchar no-undo .
v-xmlh = buffer temp-xml-tables:handle.


define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf2_temp-rule-call-param for temp-rule-call-param.
define buffer buf_clients for ub.clients.
define buffer buf_shift-obj for ub.shift-obj.
define buffer buf_currency for ub.currency.
_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
:
  /*заполняем шапку отчета*/
  empty temp-table report-headert.
  empty temp-table report-parameterst.
  empty temp-table report-errorst.
  v-report-id = substitute("&1/&2", p-profile-id, p-rule-id).
  v-start-datetime = cur-time-datetime().
  run get-gate-rec in this-procedure ( input p-xsd-file
                                      ,output v-gate-rec) no-error.
  if error-status:error then do:
    undo, return error substitute("Не найдено описание xsd-схемы &1 в БД", p-xsd-file).
  end.
  /*create p_dataset внутри get-gate-by-rec*/
  v-longchar = ?.
  run get-gate-by-rec in this-procedure ( input v-gate-rec
                                        ,output v-dataseth
                                        ,input-output v-xmlh
                                        ,input-output v-longchar
                                        ) no-error.
  if error-status:error then do:
    &scop my-message substitute("Ошибка при создании структуры маршрутизируемых данных согласно гейту:&1&2&3&2&4" ~
                              , v-gate-rec ~
                              , ~{&new-line~} ~
                              , error-status:get-message(1) ~
                              , return-value )
    {&display-message}.
    delete object v-dataseth no-error.
    undo _main, retry _main.
  end.
  _clients:
  for each buf_temp-rule-call-param where
          buf_temp-rule-call-param.param-name = "p-objects"
      and buf_temp-rule-call-param.p-index > 0 :
    find first buf_clients no-lock where
              buf_clients.obj-type = substring(buf_temp-rule-call-param.param-value-character, 1, 3)
         and  buf_clients.obj-code = integer(substring(buf_temp-rule-call-param.param-value-character, 4)) no-error.
   if available buf_clients then do:
      /*найдем сменный ли объект*/
      l-shift-on = no.
      { gbl/objat.i
        buf_clients.obj-type
        buf_clients.obj-code
        "'shift-on=request'"
        l-shift-on
        no-error
      }
      if not l-shift-on then do:
        &scop my-message substitute("&1&2 не является сменным объектом - пропускаем ....", buf_clients.obj-type, buf_clients.obj-code)
        /*{&display-message}.*/
        next _clients.
      end.
      { gbl/basecode.i buf_clients.host-code v-base-code }
      find first buf_currency no-lock
        where buf_currency.curr-code = v-base-code
      .
      v-last-shift-fact-order = 0.0.
      find first buf2_temp-rule-call-param where
               buf2_temp-rule-call-param.call_id = buf_temp-rule-call-param.call_id
          and  buf2_temp-rule-call-param.codex_id = buf_temp-rule-call-param.codex_id
          and  buf2_temp-rule-call-param.ruleset_id = buf_temp-rule-call-param.ruleset_id
          and  buf2_temp-rule-call-param.order_id = buf_temp-rule-call-param.order_id
          and  buf2_temp-rule-call-param.param-name = "p-last-shift"
          and  buf2_temp-rule-call-param.p-index = buf_temp-rule-call-param.p-index no-error.
      if not available buf2_temp-rule-call-param then do:
        run cur-time in this-procedure ( output v-today, output v-time).
        run factord in this-procedure
          (input  (v-today - p-shift-days-to-report)   /* p-fact-date            */
          ,input  v-time  /* p-fact-time            */
          ,input  1                         /* p-fact-num             */
          ,input  (v-today - p-shift-days-to-report)   /* p-shift-date           */
          ,input  1  /* p-shift-num            */
          ,input  yes                /* p-shift-on             */
          ,output v-fact-order              /* p-fact-order           */
          ,output v-shift-end-fact-order    /* p-shift-end-fact-order */
          ,output v-day-end-fact-order      /* p-day-end-fact-order   */
          ) no-error .
        if not error-status:error then do:
          v-last-shift-fact-order = v-shift-end-fact-order.
        end.
        run cb_rcps-run_set-value in p-parent-handle (
                                                  input p-call-id
                                                  ,input p-codex-id
                                                  ,input p-ruleset-id
                                                  ,input p-order-id
                                                  ,input "p-last-shift"
                                                  ,input buf_temp-rule-call-param.p-index
                                                  ,input {&script-parmode-inout}
                                                  ,input ''
                                                  ,input ?
                                                  ,input v-last-shift-fact-order
                                                  ,input 0
                                                  ,input no
                                                  ).

      end.
      else do:
        v-last-shift-fact-order = buf2_temp-rule-call-param.param-value-decimal.
      end.
      v-found = no.

      for each  buf_shift-obj no-lock where
              buf_shift-obj.obj-type = buf_clients.obj-type
          and buf_shift-obj.obj-code = buf_clients.obj-code
          and buf_shift-obj.fact-order >  v-last-shift-fact-order
          and buf_shift-obj.status_ = {&sht-closed}:
        assign
        X-date-start = buf_shift-obj.shift-date
        X-shift-start = buf_shift-obj.shift-num
        X-date-end = buf_shift-obj.shift-date
        X-shift-end = buf_shift-obj.shift-num
        .
        v-found = yes.
        run rep/r-shift.p
          ( input parparentproc
          ,input p-parent-handle
          ,input p-log-handle
          ,input p-cont-handle
          ,input this-procedure:handle
          ,input (buffer report-errorst:handle)
          ,input (buffer report-destinationt:handle)
          ,input substitute("&1/&2", p-profile-id, p-rule-id)
          ,input p-xsd-file
          ,input log-file-name
          ,input integer({&repcalc-type-schedule}) /*p-batch*/
          ,input p-codex-id
          ,input p-ruleset-id
          ,INPUT buf_clients.obj-code
          ,INPUT buf_clients.obj-type
          ,INPUT buf_currency.curr-abbr
          ,INPUT v-base-code
          ,input {&LS_PS_A4} /*f-line-of-page*/
          ,input no /*p-weight*/
          ,INPUT "no-classify" /* Classify*/ /*группы первого уровня*/
          ,INPUT "sort-code" /*SortType*/
          ,input no /*tog-level*/
          ,input 1 /*var-level*/
          ,INPUT yes /*tog-1*/
          ,INPUT yes /*tog-2*/
          ,input yes /*tog-3*/
          ,input no /*tog-4*/
          ,input no /*tog-5 */
          ,input no /*tog-6 */
          ,input no /*tog-7 */
          ,input no /*tog-8 */
          ,input no /*tog-9 */
          ,input no /*tog-10 */
          ,input no /*tog-1-pump-one - счетчики ТРК в одной строке */
          ,input no /*tog-1-whole-gds  товар на одной странице*/
          ,input no /*tog-1-out-pump-with-icnt  колонка расход по показанимя электр счетчика*/
          ,input no /*tog-2-cp-grp итоги по группам платежей*/
          ,input no /*lookup({&output-type-plain-text}, p-output-type) > 0*/
          ,input no /*lookup({&output-type-excel}, p-output-type) > 0*/
          ,input "" /*entry(1, v-dirs, {&vertical-line}) /*p-dir-txt*/*/
          ,input-output v-dataseth
          ,input table temp-xml-tables
          ) no-error.
         if error-status:error then do:
           next _clients.
         end.
         else do:
           run cb_rcps-run_set-value in p-parent-handle (
                                                      input p-call-id
                                                     ,input p-codex-id
                                                     ,input p-ruleset-id
                                                     ,input p-order-id
                                                     ,input "p-last-shift"
                                                     ,input buf_temp-rule-call-param.p-index
                                                     ,input {&script-parmode-inout}
                                                     ,input ''
                                                     ,input ?
                                                     ,input buf_shift-obj.fact-order
                                                     ,input 0
                                                     ,input no
                                                    ).
         end.
       end. /*      for each  buf_shift-obj no-lock where*/
       if not v-found then do:
          &scop my-message substitute("Нет смен для расчета для &1&2", buf_clients.obj-type, buf_clients.obj-code)
          {&display-message}.
          run cb_write-report-error in p-parent-handle ( input buffer report-errorst:handle
                                                        ,input v-report-id
                                                        ,input ?
                                                        ,input {&severity-low}
                                                        ,input substitute("Нет смен для расчета для &1&2"
                                                                           , buf_clients.obj-type
                                                                           , buf_clients.obj-code)
                                                        ) no-error.
       end.
    end. /*if available buf_clients*/
  end. /*for each buf_temp-rule-cl*/
  run cb_fill-report-header in p-parent-handle ( input buffer buf_report-header:handle
                                                ,input v-report-id
                                                ,input "shift"
                                                ,input "Сменный отчет"
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
    &scop my-message substitute("!!Не удалось передать OUTPUT параметры правила!!! &1&2&1&3" ~
                                , ~{&new-line~} ~
                                , error-status:get-message(1) )
    {&display-message}.
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
and buf_rule-call-param.param-name = "p-objects"
and buf_rule-call-param.p-index > 0:
  create buf_temp-rule-call-param.
  buffer-copy buf_rule-call-param to buf_temp-rule-call-param.
  release buf_temp-rule-call-param.
end.

for each buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-last-shift"
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

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-shift-days-to-report"
 no-error.
if available buf_rule-call-param then do:
assign p-shift-days-to-report = buf_rule-call-param.param-value-integer.
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