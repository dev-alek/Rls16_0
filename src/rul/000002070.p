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

---------------------------&start-codex_id=22;ruleset_id=5;-------------------------------
Отчеты
Выполнение отчетов по расписанию
---------------------------&end-codex_id=22;ruleset_id=5;-------------------------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 22, набор 5".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ rul/cl-hist.i "shared" }
{ gbl/key-rec.i }
{ rep/tmpcxmlr.i tables-def,dataset-def t }
{ cmp/r-page1.i new }
{ cmp/r-pril.i  new }
{ rul/ruleset_.i }
{ rul/tempcxml.i }
define variable G#REPORT-NUM as integer no-undo .
{ rep/opclexcl.i }

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
define buffer buf_shift-obj for ub.shift-obj.
{ str/dia2auto.i }
{ rul/seterror.i }


&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)




/*---------------------------&start-rule-call-param&-------------------------------*/

define variable p-output-type as character no-undo .
define variable p-reporth as handle no-undo .


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
define variable glog as logical no-undo .
define variable v-host-code as integer no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
define variable v-p-index as integer no-undo .
define variable v-previous-shift-date as date no-undo .
define variable v-current-shift-date as date no-undo .

define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf2_temp-rule-call-param for temp-rule-call-param.
define buffer buf_cash-desk for ub.cash-desk.


_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
:
  /*заполняем шапку отчета*/
  empty temp-table report-headert.
  empty temp-table report-parameterst.
  empty temp-table report-errorst.
  empty temp-table report-destinationt.
  empty temp-table obj-list.
  v-report-id = substitute("&1/&2", p-profile-id, p-rule-id).
  { gbl/hostcode.i buf_shift-obj.obj-type buf_shift-obj.obj-code v-host-code }
  v-start-datetime = cur-time-datetime().
  assign
  X-date-start = buf_shift-obj.shift-date
  X-shift-start = buf_shift-obj.shift-num
  X-date-end = buf_shift-obj.shift-date
  X-shift-end = buf_shift-obj.shift-num
  X-shift-alone = buf_shift-obj.shift-num
  X-tog-shift = yes
  x-SET_val_TYPE = {&v-rubl}
  .
  run  create_obj-list in this-procedure ( input buf_shift-obj.obj-type
                                          ,input buf_shift-obj.obj-code
                                          ).
  assign
  str1 = substitute(" По смене № &1 дата открытия &2"
                   , string(X-Shift-Alone)
                   , string(X-Date-Start,"99/99/9999")
                    ).
  run rep/r-km7.p
  ( input parparentproc
  ,input p-parent-handle
  ,input p-log-handle
  ,input p-cont-handle
  ,input this-procedure:handle
  ,input (buffer report-errorst:handle)
  ,input (buffer report-destinationt:handle)
  ,input v-report-id
  ,input log-file-name
  ,input integer({&repcalc-type-event}) /*p-batch*/
  ,input p-codex-id
  ,input p-ruleset-id
  ,input lookup({&output-type-plain-text}, p-output-type) > 0
  ,input lookup({&output-type-excel}, p-output-type) > 0
  ,input entry(1, v-dirs, {&vertical-line}) /*p-dir-txt*/

  ) no-error.
  if error-status:error then do:
    &scop my-message substitute("!!Ошибка при выполнении отчета!!! &1&2&1&3" ~
                                , ~{&new-line~} ~
                                , error-status:get-message(1) ~
                                , return-value )
    {&display-message}.
    if lookup({&output-type-excel}, p-output-type) > 0 then do:
      run CloseForExcel in this-procedure  .
    end.
    return error ''.
  end.
  if lookup({&output-type-excel}, p-output-type) > 0 then do:
    run CloseForExcel in this-procedure  .
  end.
  run cb_fill-report-header in p-parent-handle ( input buffer buf_report-header:handle
                                                ,input v-report-id
                                                ,input "km-7"
                                                ,input "Сведения о показаниях счетчиков ККМ и выручке организации по форме КМ-7"
                                                ,input v-start-datetime
                                                ,input cur-time-datetime()
                                                ).
  run cb_fill-report-parameters in p-parent-handle ( input buffer buf_report-parameters:handle
                                                    ,input v-report-id
                                                    ).
  /*запишем в output параметры в контейнер данные ОБ отчете*/
  v-p-index = 0.
  run cb_rcps-run_get-value in p-cont-handle (
                                               input p-call-id
                                              ,input 0 /*p-codex-id*/
                                              ,input 0 /*p-ruleset-id*/
                                              ,input 0 /*p-order-id*/
                                              ,INPUT "p-reporth"
                                              ,INPUT-OUTPUT v-p-index
                                              ,output v-value-character
                                              ,output v-value-date
                                              ,output v-value-decimal
                                              ,output v-value-integer
                                              ,output v-value-logical
                                              ) no-error.
  if error-status:error then do:
    &scop my-message substitute("!!Не удалось передать OUTPUT параметры правила!!! &1&2&1&3" ~
                                , ~{&new-line~} ~
                                , error-status:get-message(1) )
    {&display-message}.
    delete object p-reporth no-error.
    return error ''.
  end.
  assign
  p-reporth = widget-handle(v-value-character)
  no-error.
  if not valid-handle(p-reporth) then do:
    create dataset p-reporth.
  end.
  glog = p-reporth:copy-dataset (
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
    delete object p-reporth no-error.
    return error ''.
  end.
  run cb_rcps-run_set-value in p-cont-handle (
                                                input p-call-id
                                              ,input 0 /*p-codex-id*/
                                              ,input 0 /*p-ruleset-id*/
                                              ,input 0 /*p-order-id*/
                                              ,INPUT "p-reporth"
                                              ,INPUT 0 /*p-index*/
                                              ,input {&script-parmode-output}
                                              ,INPUT string(p-reporth) /*p-value-character*/
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
    delete object p-reporth no-error.
    return error ''.
  end.
end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.

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
and buf_rule-call-param.param-name = "p-output-type"
 no-error.
if available buf_rule-call-param then do:
assign p-output-type = buf_rule-call-param.param-value-character.
end.


/*не удалять!!!!*/




/*---------------------------&end-process-rule-call-param&-------------------------------*/
    case p-ruleset-id:
      when {&rep-proc_22_close-shift_5}
      then do:
        if g#news = yes then do:
          return "return".
        end.
        run gen-row-keyr in this-procedure (
                                              input  p-doc-code /*uniq-key-rec смены*/
                                              ,input ? /*p-key-handle буфер записи которую будем искать. если ищем по key-rec то ? */
                                              ,input  "ub"
                                              ,input  ? /*p-tt-handle   буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
                                              ,input  no-lock
                                              ,output v-rowid
                                              ,output v-tbl-name ) .
        find first buf_shift-obj no-lock where
                  rowid(buf_shift-obj) = v-rowid.
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