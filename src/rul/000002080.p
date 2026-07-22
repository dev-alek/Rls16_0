/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 1

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/06/10
Author: Bakhtadze Natalya
Creation date: 11/06/10


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
using Ibs.Th.Rul.Dis-card_.
using Ibs.Th.Rul.Dis-tot_obj.
using Ibs.Th.Rul.Discount_obj.
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
define input parameter p-host-code like ub.inkas.host-code no-undo .
define input parameter p-obj-type like ub.inkas.obj-type no-undo .
define input parameter p-obj-code like ub.inkas.obj-code no-undo .
define input parameter p-doc-code like ub.inkas.inkas-code no-undo .
define input parameter p-process-file-name as character no-undo .
define input parameter p-doc-date like ub.inkas.doc-date no-undo .
define input parameter p-fact-date like ub.inkas.fact-date no-undo .
define input parameter p-save   as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .
/*если вызывается персистентно то эти два параметра не играют значения*/
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .

{ str/saledcdf.i " " }
define INPUT parameter table for temp-d-card.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 1".
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
{ rul/library-cls.i "non-class-part" }
{ gbl/key-rec.i }
{ gbl/gate-clb.i }
{ rul/ruleset_.i }

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
define variable v-current-doc-type as character no-undo .
define variable v-last-error-message as character no-undo .
define variable v-emitent-host-code as integer no-undo .
define variable v-type as character no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .

/*****************************/

define variable v-sign as integer no-undo .
define variable num-rec as integer no-undo .
define variable num-rec-calc-err as integer no-undo .
define variable num-rec-value-err as integer no-undo .
define variable num-rec-ok as integer no-undo .



{ rul/seterror.i }

define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_temp-cmd for temp-cmd.
/*это у нас объект 3*/
define buffer buf_dis-card-sale_obj for temp-d-card.
define variable vh_dis-card-sale_obj as handle no-undo .
define temp-table temp-dis-rule no-undo like ub.dis-rule.


/*---------------------------&start-rule-call-param&-------------------------------*/
 define variable p-r-b as character no-undo.
 define variable p-is-over as logical no-undo.
 define variable p-rule-num-obj as integer no-undo.


/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/
{ trg/discardh.i rul }
{ trg/dis-objh.i rul }
{ trg/disproph.i rul }
 { rul/dis-rule_f.i 57 }





/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run garbcoll_clear in this-procedure .
end.


&scop sign v-sign *

run load-ruleset-context in this-procedure ( input p-ruleset-id).
if return-value = "return" then return ''.

/* ------------------------- &start-def-vars& -----------------------------------*/
 define variable Card1 as class Dis-card_ no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input p-cont-handle, input v-current-lock, input v-current-wait, input v-save)
Card1 = new Dis-card_{&constructor_1} .
 define variable Tot-sum-obj1 as class Dis-tot_obj no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input p-cont-handle, input v-current-lock, input v-current-wait, input v-save)
Tot-sum-obj1 = new Dis-tot_obj{&constructor_1} .
 define variable Discount-obj1 as class Discount_obj no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input p-cont-handle, input v-current-lock, input v-current-wait, input v-save, input 26)
Discount-obj1 = new Discount_obj{&constructor_1} .

 define variable v-netto-sum1 as  decimal no-undo .


/* ------------------------- &end-def-vars& -----------------------------------*/


if not this-procedure:persistent then do:
  run proc-main in this-procedure ( input p-type
                              ,input p-emitent-host-code ) no-error .
  if error-status:error then do:
      run garbcoll_clear in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  run garbcoll_clear in this-procedure .
  empty temp-table temp-dis-rule.
end.


procedure proc-main :
define input parameter p-type like ub.dis-card.type no-undo .
define input parameter p-emitent-host-code like ub.dis-card.emitent-host-code no-undo .

_main:
do
on error undo, return error return-value
:

assign
v-emitent-host-code = p-emitent-host-code
v-type = p-type.


/*надо найти настройки маршрутизации и записи истории для данного типа ДК для всех объектов*/

&glob card-type p-type
&scop emitent-host-code p-emitent-host-code

/* ------------------------- &start-hn-option& -----------------------------------*/





/* ------------------------- &end-hn-option -----------------------------------*/
  _d-card:
  for each temp-d-card where
          temp-d-card.type = p-type
      and temp-d-card.emitent-host-code = p-emitent-host-code
  break
  by temp-d-card.d-card
  On error undo _d-card, retry _d-card:

    if temp-d-card.d-card = '_' then next.
    num-rec = num-rec + 1.
    if retry then do:
      if p-ruleset-id = 5 then do:
        num-rec-calc-err = num-rec-calc-err + 1.
        undo _d-card, next _d-card .
      end.
      else do:
        undo _main, return error return-value .
      end.
    end.
    assign
    v-current-d-card = temp-d-card.d-card
    v-netto-sum1 = 0
    .

    /* ------------------------- &start-rule& -----------------------------------*/

   IF  Card1:find_dis-card_( INPUT v-current-d-card) = true  THEN do:
    IF  Tot-sum-obj1:find_Dis-tot_obj( INPUT v-current-d-card, INPUT v-current-obj-type, INPUT v-current-obj-code) = true  THEN do:
      IF  p-r-b = "rubl" AND p-is-over = false  THEN do:
         v-netto-sum1 = Tot-sum-obj1:pay-tot-rubl .
      end.
      IF  p-r-b = "rubl" AND p-is-over = true  THEN do:
         v-netto-sum1 = Tot-sum-obj1:pay-tot-rubl_byf# .
      end.
      IF  p-r-b = "base" AND p-is-over = false  THEN do:
         v-netto-sum1 = Tot-sum-obj1:pay-tot-base .
      end.
      IF  p-r-b = "base" AND p-is-over = true  THEN do:
         v-netto-sum1 = Tot-sum-obj1:pay-tot-base_byf# .
      end.
    end.
   end.

IF  Discount-obj1:find_discount_obj( INPUT v-current-d-card, INPUT v-current-obj-type, INPUT v-current-obj-code) = false  THEN do:

  IF  Discount-obj1:create_discount_obj( INPUT v-current-d-card, INPUT v-current-obj-type, INPUT v-current-obj-code) = false  THEN do:
     undo _main, return error v-last-error-message .
  end.
end.

 DIscount-obj1:d-pcnt = dis-rule_00057( INPUT p-rule-num-obj, INPUT v-current-doc-date, INPUT v-current-doc-time, INPUT v-netto-sum1) .
 IF  Discount-obj1:discount_objsave( ) = false  THEN do:
   undo _main, return error v-last-error-message .

end.

    /* ------------------------- &end-rule -------------------------------------*/

    /* ------------------------- &start-release-obj& -----------------------------------*/
&scop release_1 release_ ( )
Card1:Dis-card_{&release_1} .
&scop release_1 release_ ( )
Tot-sum-obj1:Dis-tot_obj{&release_1} .
&scop release_1 release_ ( )
Discount-obj1:Discount_obj{&release_1} .




    /* ------------------------- &end-release-obj& -------------------------------------*/
      num-rec-ok = num-rec-ok + 1.
      if p-ruleset-id = {&dct-proc_1_import_5} then do:
        run set-num-rec in p-parent-handle ( input num-rec
                                            ,input num-rec-calc-err
                                            ,input num-rec-value-err
                                            ,input num-rec-ok
                                            ,input no
                                            ) no-error .
      end.
    end. /*for each temp-d-card where*/
    if p-ruleset-id = {&dct-proc_1_import_5} then do:
      run set-num-rec in p-parent-handle ( input num-rec
                                          ,input num-rec-calc-err
                                          ,input num-rec-value-err
                                          ,input num-rec-ok
                                          ,input yes
                                          ) no-error .
    end.
  end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_dis-rule for ub.dis-rule.

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
and buf_rule-call-param.param-name = "p-r-b"
 no-error.
if available buf_rule-call-param then do:
assign p-r-b = buf_rule-call-param.param-value-character.
end.

 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-is-over"
 no-error.
if available buf_rule-call-param then do:
assign p-is-over = buf_rule-call-param.param-value-logical.
end.

 for each buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-rule-num-obj"
and buf_rule-call-param.p-index > 0,
  first Buf_dis-rule no-lock where
        buf_dis-rule.rule-num = buf_rule-call-param.param-value-integer:
  find first temp-dis-rule no-lock where
            temp-dis-rule.rule-num = buf_dis-rule.rule-num no-error.
  if not available temp-dis-rule then do:
    create temp-dis-rule.
    buffer-copy buf_dis-rule to temp-dis-rule.
    release temp-dis-rule.
  end.
end.

/*---------------------------&end-process-rule-call-param&-------------------------------*/

    assign
    vh_dis-card-sale_obj = buffer temp-d-card:handle
    .
    case p-ruleset-id:
      when {&dct-proc_1_sale-close_1} then do:
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
      when {&dct-proc_1_sale-delete_2} then do:
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
      when {&dct-proc_1_trn-doc-close_3} then do:
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
      when {&dct-proc_1_trn-doc-delete_4} then do:
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
      otherwise do:
        undo, return error substitute("Неверный вызов &1 для набора правил &2", vss-workfile , p-ruleset-id).
      end.
    end case.
    find first temp-dis-rule no-lock where
                temp-dis-rule.obj-type = v-current-obj-type
            and temp-dis-rule.obj-code = v-current-obj-code no-error.
    if not available temp-dis-rule then do:
      find first temp-dis-rule no-lock where
                  temp-dis-rule.host-code = v-current-host-code no-error.
    end.
    if not available temp-dis-rule then do:
      empty temp-table temp-dis-rule.
      return "return".
    end.
    p-rule-num-obj = temp-dis-rule.rule-num.


  end. /*doe*/

end procedure. /* load-ruleset-context */

procedure delete-procedure :

  do
  on error undo, return error
  :
      run garbcoll_clear in this-procedure .

  end.

end procedure. /* delete-procedure */
