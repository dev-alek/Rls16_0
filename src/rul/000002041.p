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
{ cmp/r-page1.i new }
{ cmp/r-pril.i  new }



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



{ str/dia2auto.i }
{ rul/seterror.i }


&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)




/*---------------------------&start-rule-call-param&-------------------------------*/

  define variable p-period-type as character no-undo .
  define variable p-gds-by-am as logical no-undo .
  define variable p-group-by-order as logical no-undo .
  define variable p-group-by-post as logical no-undo .
  define variable p-critical-qnty-balance as decimal   no-undo .
  define variable p-critical-qnty-sale    as decimal   no-undo .
  define variable p-critical-qnty-order   as decimal   no-undo .
  define variable p-days-wt-goods         as integer   no-undo .



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
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-date1 as date no-undo .
define variable v-date2 as date no-undo .

_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
:
  run cur-time in this-procedure ( output v-today, output v-time).
  case p-period-type:
    when {&period-type-yesterday} then do:
      assign
        v-date1 = v-today - 1
        v-date2 = v-today - 1
      .
    end.
    when {&period-type-week-last} then do:
    assign
      v-date1 = (v-today - ((weekday(today) + 5) modulo 7) - 7)
      v-date2   = (v-today - ((weekday(today) + 5) modulo 7))
    .
    end.
    when {&period-type-month-last} then do:
      assign
        v-date1 = if month(v-today) = 1
                      then  date( 12, 1, year(v-today) - 1 )
                      else  date( month(v-today) - 1, 1, year(v-today) )
        v-date2 = date( month(v-today), 1, year(v-today))
      .
    end.
    otherwise do:
      undo, return error substitute("Не заданы ни даты ни тип периода").
    end.
  end case.


  run rep/r-ctrasm.p (
                       input parparentproc
                      ,input this-procedure :handle
                      ,input yes /*p-is-schedule*/
                      ,input v-date1
                      ,input v-date2
                      ,input p-gds-by-am
                      ,input p-group-by-order
                      ,input p-group-by-post
                      ,input p-critical-qnty-balance
                      ,input p-critical-qnty-sale
                      ,input p-critical-qnty-order
                      ,input p-days-wt-goods
                      ,input entry(1, v-dirs, {&vertical-line})
                      ,input v-current-rep-code
                      ,input yes  /*p-igt-all*/
                      ,input no /*p-igt-new*/
                      ,input no /*p-igt-com*/
                      ,input no /*p-igt-spec*/
                      ,input no /*p-igt-del*/
                      ,input no /*p-igt-empty*/
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
and buf_rule-call-param.param-name = "p-period-type"
 no-error.
if available buf_rule-call-param then do:
assign p-period-type = buf_rule-call-param.param-value-character.
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

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-gds-by-am"
 no-error.
if available buf_rule-call-param then do:
assign p-gds-by-am = buf_rule-call-param.param-value-logical.
end.

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-group-by-post"
 no-error.
if available buf_rule-call-param then do:
assign p-group-by-post = buf_rule-call-param.param-value-logical.
end.

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-critical-qnty-balance"
 no-error.
if available buf_rule-call-param then do:
assign p-critical-qnty-balance = buf_rule-call-param.param-value-decimal.
end.

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-critical-qnty-sale"
 no-error.
if available buf_rule-call-param then do:
assign p-critical-qnty-sale = buf_rule-call-param.param-value-decimal.
end.

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-critical-qnty-order"
 no-error.
if available buf_rule-call-param then do:
assign p-critical-qnty-order = buf_rule-call-param.param-value-decimal.
end.

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-days-wt-goods"
 no-error.
if available buf_rule-call-param then do:
assign p-days-wt-goods = buf_rule-call-param.param-value-integer.
end.

/*---------------------------&end-process-rule-call-param&-------------------------------*/
    case p-ruleset-id:
      when 1
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

procedure cb_get-objects :
define input parameter p-caller-handle as handle no-undo .
define buffer buf_temp-rule-call-param for temp-rule-call-param.
do
on error undo, return error
:
  for each buf_temp-rule-call-param no-lock
    where buf_temp-rule-call-param.param-name = "p-objects"
    and buf_temp-rule-call-param.p-index > 0 :
    run cb_set-objects in p-caller-handle ( input buf_temp-rule-call-param.param-value-character ).
  end.

end.

end procedure. /* cb_set-shops */

/*не удалять!!!!*/