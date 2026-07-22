/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 1

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/08/06
Author: Bakhtadze Natalya
Creation date: 10/08/06

---------------------------&start-codex_id=1;ruleset_id=1;-------------------------------
ДОКУМЕНТ <-> ДК на объекте
Обновление данных по ДК на объекте при операциях по документам продажи/накладным
ПРОДАЖА->ФАКТ
Закрытие документа продажи до статуса факт
---------------------------&end-codex_id=1;ruleset_id=1;-------------------------------

---------------------------&start-codex_id=1;ruleset_id=2;------------------------------
ДОКУМЕНТ <-> ДК на объекте
Обновление данных по ДК на объекте при операциях по документам продажи/накладным
ПРОДАЖА->DEL
Удаление документа продажи, закрытого до статуса факт
---------------------------&end-codex_id=1;ruleset_id=2;-------------------------------

---------------------------&start-codex_id=1;ruleset_id=3;-------------------------------
ДОКУМЕНТ <-> ДК на объекте
Обновление данных по ДК на объекте при операциях по документам продажи/накладным
НАКЛАДНАЯ с ДК->ФАКТ
Закрытие накладной с ДК до статуса факт
---------------------------&end-codex_id=1;ruleset_id=3;-------------------------------

---------------------------&start-codex_id=1;ruleset_id=4;-------------------------------
ДОКУМЕНТ <-> ДК на объекте
Обновление данных по ДК на объекте при операциях по документам продажи/накладным
НАКЛАДНАЯ с ДК->DEL
Удаление накладной с ДК, закрытой до статуса факт
---------------------------&end-codex_id=1;ruleset_id=1;------------------------------

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
define input parameter p-host-code like ub.inkas.host-code no-undo .
define input parameter p-obj-type like ub.inkas.obj-type no-undo .
define input parameter p-obj-code like ub.inkas.obj-code no-undo .
define input parameter p-doc-code like ub.inkas.inkas-code no-undo .
define input parameter p-process-file-name as character no-undo .
define input parameter p-doc-date like ub.inkas.doc-date no-undo .
define input parameter p-fact-date like ub.inkas.fact-date no-undo .
define input parameter p-save       as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .
/*если вызывается персистентно то эти два параметра не играют значения*/
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .
{ str/saledcdf.i " "  }
define INPUT parameter table for temp-d-card .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 1 набором 1".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }

{ cmp/dc-list.i dc-list   def "shared" }
{ cmp/dcp-list.i dcp-list def "shared" }
{ str/vchk-pay.i "SHARED" }
{ nws/lib-nws.i }
&glob cmd-proc-handle p-cmd-proc-handle
&glob cmd-code p-cmd-code
{ nws/temp-cmd.i "SHARED" }
{ rul/cl-hist.i "shared" }
{ gbl/gate-clb.i }

{ rul/library-cls.i "non-class-part"  }

/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-d-card as character no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-current-doc-code as character no-undo .
define variable v-current-doc-date as date no-undo .
define variable v-current-doc-time as integer no-undo .
define variable v-current-doc-fact-date as date no-undo .
define variable v-current-date as date no-undo .
define variable v-current-fact-date as date no-undo .
define variable v-last-error-message as character no-undo .
/*****************************/
define variable v-sign as integer no-undo .
define variable v-temp-d-card-rec-ord as integer   no-undo .
define variable v-vchk-pay-rec-ord as integer   no-undo .
define variable v-gate-rec as character no-undo .


{ rul/seterror.i }

define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_temp-cmd for temp-cmd.

/*это у нас объект 3*/
define buffer buf_dis-card-sale_obj for temp-d-card.
define variable vh_dis-card-sale_obj as handle no-undo .

/*---------------------------&start-rule-call-param&-------------------------------*/


/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/


/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run garbcoll_clear in this-procedure .
end.



&scop sign v-sign *

run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error.
if error-status:error then do:
  undo, return error return-value .
end.

/* ------------------------- &start-def-vars& -----------------------------------*/


/* ------------------------- &end-def-vars& -----------------------------------*/

if not this-procedure:persistent then do:
  run proc-main in this-procedure ( input p-type
                              ,input p-emitent-host-code ) no-error .
  if error-status:error then do:
      run garbcoll_clear in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  run garbcoll_clear in this-procedure .
end.


procedure proc-main :
define input parameter p-type like ub.dis-card.type no-undo .
define input parameter p-emitent-host-code like ub.dis-card.emitent-host-code no-undo .

_main:
do
on error undo, return error return-value
:

/*надо найти настройки маршрутизации и записи истории для данного типа ДК для всех объектов*/

&glob card-type p-type
&scop emitent-host-code p-emitent-host-code

/* ------------------------- &start-hn-option& -----------------------------------*/





/* ------------------------- &end-hn-option& -----------------------------------*/

  for each temp-d-card where
          temp-d-card.type = p-type
      and temp-d-card.emitent-host-code = p-emitent-host-code
  On error undo _main, return error return-value
  :
    if temp-d-card.d-card = '_' then next.
    assign
    v-current-d-card = temp-d-card.d-card
    .
    /* ------------------------- &start-rule& -----------------------------------*/


    /* ------------------------- &end-rule& -------------------------------------*/

    if p-order-id = 0
    and p-profile-id = 1
    and p-ruleset-id < 6 then do:

        FOR EACH vchk-pay where vchk-pay.d-card = temp-d-card.d-card
        On error undo _main, return error
        :
          if g#db-num = 0 then do:
            if NOT vchk-pay.cre-pay then do:
          /*надо создать запись payment если это не оплата в кредит!!!*/
            if p-doc-type = {&hn-source-import} then do:
              assign
              p-doc-type = '':U.
            end.
            define variable v-payment-host-code as integer no-undo .
            if p-ruleset-id < 5 then do:
              v-payment-host-code = v-current-host-code.
            end.
            else do:
              { gbl/hostcode.i temp-d-card.obj-type temp-d-card.obj-code v-payment-host-code }
            end.
            run ref/payment1.p (
                          input {&add-def}
                          ,input yes /*p-silent*/
                          ,input-output vchk-pay.pmnt-code
                          ,input temp-d-card.cli-type
                          ,input temp-d-card.cli-code
                          ,input temp-d-card.cli-type
                          ,input temp-d-card.cli-code
                          ,input v-payment-host-code
                          ,input {&sign} vchk-pay.tot-sum
                          ,input {&sign} vchk-pay.tot-base
                          ,input {&sign} vchk-pay.tot-rubl
                          ,input vchk-pay.doc-date
                          ,input vchk-pay.curr-code
                          ,input vchk-pay.exch-rate
                          ,input 1 /*exch-scale*/
                          ,input vchk-pay.base-rate
                          ,input 1 /*base-scale*/
                          ,input ? /*p-due-date*/
                          ,input p-fact-date
                          ,input temp-d-card.sale-type
                          ,input p-doc-code
                          ,input temp-d-card.d-card
                          ,input vchk-pay.pay-code /**/
                          ,input {&fact} /*p-status*/
                          ,input '':U /*PS*/
                          ,input g#userid
                          ,input g#userid
                          )
                          no-error.
              IF ERROR-STATUS:ERROR then do:
                  undo _main, return error (substitute("Ошибка создания записи оплаты по дисконтной карте &1: &2", temp-d-card.d-card, return-value )).
              end.
            end.
          end. /*end. /*if g#db-num = 0 then do:*/*/
          if not g#news then do:
            /*пошлем в новости*/
            &scop table__  'vchk-pay'
            &scop buffer-handle buffer vchk-pay:handle
            &scop rec-ord v-vchk-pay-rec-ord
            &scop action__ '+update'
            &scop gate-rec v-gate-rec

            {&add-dump-ext}.
          end.
          delete vchk-pay.
        end. /*FOR EACH vchk-pay where vchk-pay.d-card = temp-d-card.d-card*/

      /*пошлем в новости*/
      if temp-d-card.exp-imp = no then do:
  &scop table__ 'temp-d-card'
  &scop buffer-handle buffer temp-d-card:handle
  &scop rec-ord v-temp-d-card-rec-ord
  &scop action__ '+update'
  &scop gate-rec v-gate-rec

  {&add-dump-ext}.
        temp-d-card.exp-imp = yes.
      end.

    end.
    /* ------------------------- &start-release-obj& -----------------------------------*/


    /* ------------------------- &end-release-obj& -------------------------------------*/
  end. /*for each temp-d-card where*/
end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.

  do
  on error undo, return error
  :
/*---------------------------&start-process-rule-call-param&-------------------------------*/


/*---------------------------&end-process-rule-call-param&-------------------------------*/
    assign
    vh_dis-card-sale_obj = buffer temp-d-card:handle
    .
    run get-gate-rec in this-procedure ( input "exe/temp-d-card-ds.xsd", output v-gate-rec) no-error.
    if error-status :error then do:
      undo, return error return-value .
    end.
    case p-ruleset-id:
      when 1 then do:
        assign
        v-sign = 1
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        v-current-doc-code = p-doc-code
        v-current-doc-date = p-doc-date
        v-current-doc-fact-date = p-fact-date
        v-current-date = p-doc-date
        v-current-fact-date = p-fact-date
        .
      end.
      when 2 then do:
        assign
        v-sign = -1
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        v-current-doc-code = p-doc-code
        v-current-doc-date = p-doc-date
        v-current-doc-fact-date = p-fact-date
        v-current-date = p-doc-date
        v-current-fact-date = p-fact-date
        .
      end.
      when 3
      or when 5
      then do:
        assign
        v-sign = 1
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        v-current-doc-code = p-doc-code
        v-current-doc-date = p-doc-date
        v-current-doc-time = 0
        v-current-doc-fact-date = p-fact-date
        v-current-date = p-doc-date
        v-current-fact-date = p-fact-date
        .
      end.
      when 4 then do:
        assign
        v-sign = -1
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        v-current-doc-code = p-doc-code
        v-current-doc-date = p-doc-date
        v-current-doc-time = 0
        v-current-doc-fact-date = p-fact-date
        v-current-date = p-doc-date
        v-current-fact-date = p-fact-date
        .
      end.
    end case.
  end. /*doe*/

end procedure. /* load-ruleset-context */

/*не удалять!!!!*/