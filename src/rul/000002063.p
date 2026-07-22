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

define variable p-tog as logical no-undo extent 10.
define variable p-weight as logical no-undo .
define variable p-classify as character no-undo .
define variable p-sorttype as character no-undo .
define variable p-level as integer no-undo .
define variable p-pump-one as logical no-undo .
define variable p-whole-gds as logical no-undo .
define variable p-el-icnt as logical no-undo .
define variable p-cp-grp as logical no-undo .
define variable p-output-type as character no-undo .
define variable p-line-of-page as integer no-undo .
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


define buffer buf_currency for ub.currency.
define buffer buf_clients for ub.clients.


define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf2_temp-rule-call-param for temp-rule-call-param.


_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
:
  /*заполняем шапку отчета*/
  empty temp-table report-headert.
  empty temp-table report-parameterst.
  empty temp-table report-errorst.
  empty temp-table report-destinationt.
  v-report-id = substitute("&1/&2", p-profile-id, p-rule-id).
  { gbl/hostcode.i buf_shift-obj.obj-type buf_shift-obj.obj-code v-host-code }
  { gbl/basecode.i v-host-code v-base-code }
  find first buf_currency no-lock
    where buf_currency.curr-code = v-base-code
  .
  find first buf_clients no-lock where
            buf_clients.obj-type = buf_shift-obj.obj-type
       and  buf_clients.obj-code = buf_shift-obj.obj-code.
  v-start-datetime = cur-time-datetime().
  assign
  X-date-start = buf_shift-obj.shift-date
  X-shift-start = buf_shift-obj.shift-num
  X-date-end = buf_shift-obj.shift-date
  X-shift-end = buf_shift-obj.shift-num
  .
  define variable classify as character no-undo .
  define variable sorttype as character no-undo .
  classify = p-classify.
  sorttype  = p-sorttype.
  { rep/claslabl.i }
  assign
  reportname = "СМЕННЫЙ ОТЧЕТ"
  str1 = "Выбор товара: по всем товарам"
  str2 = "Выбор объекта: " + {&new-line} + buf_clients.obj-name
  ReportHeader = "Классификация : " + t-class +
                ( IF p-tog[3] = YES AND Classify = "n-level":U THEN STRING( p-level ) ELSE " " ) + {&new-line} +
                "Сортировка " + t-Sort + {&new-line}
  .
  if lookup({&output-type-excel}, p-output-type) > 0 then do:
    make-excel = yes.
    my-handle = parparentproc.
    run get-report-num in parparentproc ( output g#report-num).
    run OpenForExcel in this-procedure  .
  end.
  run rep/r-shift.p
  ( input parparentproc
  ,input p-parent-handle
  ,input p-log-handle
  ,input p-cont-handle
  ,input this-procedure:handle
  ,input (buffer report-errorst:handle)
  ,input (buffer report-destinationt:handle)
  ,input substitute("&1/&2", p-profile-id, p-rule-id)
  ,input ''
  ,input log-file-name
  ,input integer({&repcalc-type-event}) /*p-batch*/
  ,input p-codex-id
  ,input p-ruleset-id
  ,INPUT buf_shift-obj.obj-code
  ,INPUT buf_shift-obj.obj-type
  ,INPUT buf_currency.curr-abbr
  ,INPUT v-base-code
  ,input p-line-of-page
  ,input p-weight
  ,INPUT p-Classify
  ,INPUT p-SortType
  ,input (p-level > 0)
  ,input p-level
  ,INPUT p-tog[1]
  ,INPUT p-tog[2]
  ,input p-tog[3]
  ,input p-tog[4]
  ,input p-tog[5]
  ,input p-tog[6]
  ,input p-tog[7]
  ,input p-tog[8]
  ,input p-tog[9]
  ,input p-tog[10]
  ,input p-pump-one
  ,input p-whole-gds  /*товар на одной странице*/
  ,input p-el-icnt /*tog-1-out-pump-with-icnt  колонка расход по показанимя электр счетчика*/
  ,input p-cp-grp /*tog-2-cp-grp итоги по группам платежей*/
  ,input lookup({&output-type-plain-text}, p-output-type) > 0
  ,input lookup({&output-type-excel}, p-output-type) > 0
  ,input entry(1, v-dirs, {&vertical-line}) /*p-dir-txt*/
  ,input-output p-reporth
  ,input table temp-xml-tables
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
                                                ,input "shift"
                                                ,input "Сменный отчет"
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


for each buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-tog"
and buf_rule-call-param.p-index > 0:
  if buf_rule-call-param.p-index <= 10 then do:
    p-tog[buf_rule-call-param.p-index]  = buf_rule-call-param.param-value-logical.
  end.
end.

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-classify"
 no-error.
if available buf_rule-call-param then do:
assign p-classify = buf_rule-call-param.param-value-character.
end.

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-sorttype"
 no-error.
if available buf_rule-call-param then do:
assign p-sorttype = buf_rule-call-param.param-value-character.
end.

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-level"
 no-error.
if available buf_rule-call-param then do:
assign p-level = buf_rule-call-param.param-value-integer.
end.


  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-weight"
 no-error.
if available buf_rule-call-param then do:
assign p-weight = buf_rule-call-param.param-value-logical.
end.
  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-pump-one"
 no-error.
if available buf_rule-call-param then do:
assign p-pump-one = buf_rule-call-param.param-value-logical.
end.

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-whole-gds"
 no-error.
if available buf_rule-call-param then do:
assign p-whole-gds = buf_rule-call-param.param-value-logical.
end.

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-el-icnt"
 no-error.
if available buf_rule-call-param then do:
assign p-el-icnt = buf_rule-call-param.param-value-logical.
end.

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-cp-grp"
 no-error.
if available buf_rule-call-param then do:
assign p-cp-grp = buf_rule-call-param.param-value-logical.
end.

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

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-line-of-page"
 no-error.
if available buf_rule-call-param then do:
assign p-line-of-page = buf_rule-call-param.param-value-integer.
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