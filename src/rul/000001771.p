/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 2

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/08/06
Author: Bakhtadze Natalya
Creation date: 10/08/06


---------------------------&start-codex_id=2;ruleset_id=1;-----------------
ДОКУМЕНТ <-> ДК на ФИРМЕ/ГЛОБАЛЬНО
Обновление данных по ДК на фирме/глобально при операциях по документам продажи/накладным
ПРОДАЖА------->ФАКТ
Закрытие документа продажи до статуса факт в ГБД/Получение продажи, закрытой до статуса факт, по СПН в ГБД

---------------------------&end-codex_id=2;ruleset_id=1;-----------------

---------------------------&start-codex_id=2;ruleset_id=2;-----------------
ДОКУМЕНТ <-> ДК на ФИРМЕ/ГЛОБАЛЬНО
Обновление данных по ДК на фирме/глобально при операциях по документам продажи/накладным
ПРОДАЖА------->DEL
Удаление документа продажи, закрытого до статуса факт ГБД/Получение команды на удаление продажи, закрытой до статуса факт, по СПН в ГБД
---------------------------&end-codex_id=2;ruleset_id=2;-----------------

---------------------------&start-codex_id=2;ruleset_id=3;-----------------
ДОКУМЕНТ <-> ДК на ФИРМЕ/ГЛОБАЛЬНО
Обновление данных по ДК на фирме/глобально при операциях по документам продажи/накладным
НАКЛАДНАЯ с ДК------->ФАКТ
Закрытие накладной с ДК до статуса факт в ГБД/Получение накладной с ДК, закрытой до статуса факт, по СПН в ГБД
---------------------------&end-codex_id=2;ruleset_id=3;-----------------

---------------------------&start-codex_id=2;ruleset_id=4;-----------------
ДОКУМЕНТ <-> ДК на ФИРМЕ/ГЛОБАЛЬНО
Обновление данных по ДК на фирме/глобально при операциях по документам продажи/накладным
НАКЛАДНАЯ с ДК------->DEL
Удаление накладной с ДК, закрытой до статуса факт ГБД/Получение команды на удаление накладной с ДК, закрытой до статуса факт, по СПН в ГБД
---------------------------&end-codex_id=2;ruleset_id=4;-----------------

---------------------------&start-codex_id=2;ruleset_id=5;-----------------
Расчет и установка текущей скидки
---------------------------&end-codex_id=2;ruleset_id=5;-----------------
*/

/*---------------------------&start-using-class&-------------------------------*/
using Ibs.Th.Rul.Dis-card_.
using Ibs.Th.Rul.Dis-tot_.
using Ibs.Th.Rul.Dis-tot_host.
using Ibs.Th.Rul.Gds-dtl_obj.
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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 2".
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


/*---------------------------&start-rule-call-param&-------------------------------*/
 define variable p-rule-nums as integer no-undo.
 define variable p-sum-id as character no-undo.


/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/
{ trg/dis-hsth.i rul }
{ trg/dis-hsth.i rul }
 { rul/context_f.i  get-next-rule-call-param }
 { rul/context_f.i  get-rule-call-param_integer }






&scop scop1 buf_temp-rule-call-param.param-value-integer
&scop scop3 {&cd-type-bo}
{ rul/dis-rule_f.i {&dgr-dis-tot-flag} }



/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run garbcoll_clear in this-procedure .
end.


&scop sign v-sign *

run load-ruleset-context in this-procedure ( input p-ruleset-id).

/* ------------------------- &start-def-vars& -----------------------------------*/
 define variable Card1 as class Dis-card_ no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input p-cont-handle, input v-current-lock, input v-current-wait, input v-save)
Card1 = new Dis-card_{&constructor_1} .
 define variable Gds-line1 as class Gds-dtl_obj no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input p-cont-handle, input v-current-lock, input v-current-wait, input v-save)
Gds-line1 = new Gds-dtl_obj{&constructor_1} .
 define variable Sum-brutto1-base as  decimal no-undo .
 define variable Sum-brutto1-rubl as  decimal no-undo .
 define variable Sum-discnt1-base as  decimal no-undo .
 define variable Sum-discnt1-rubl as  decimal no-undo .
 define variable Sum-netto1-base as  decimal no-undo .
 define variable Sum-netto1-rubl as  decimal no-undo .
 define variable Tot-host-sel-goods1 as class Dis-tot_host no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input p-cont-handle, input v-current-lock, input v-current-wait, input v-save, input 9)
Tot-host-sel-goods1 = new Dis-tot_host{&constructor_1} .
 define variable Tot-sel-goods1 as class Dis-tot_ no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input p-cont-handle, input v-current-lock, input v-current-wait, input v-save, input 9)
Tot-sel-goods1 = new Dis-tot_{&constructor_1} .
 define variable v-index-rule-nums as  integer no-undo .
 define variable v-rule-num as  integer no-undo .


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
    .
    /*buffer buf_dis-card_:find-first( substitute("d-card = &1", v-current-d-card), v-current-lock).*/

    /* ------------------------- &start-rule& -----------------------------------*/
/* Суммы по ДК по одной накладной -> итоги по ДК на фирме и глобально
Итоги по определенной выборке товаров */

_1771:
do:
                                                                      /* Salience 0 rule_id 1771*/
/* define variable Card1 as class Dis-card_ no-undo .*/
                                                                      /* Salience 1 rule_id 1771*/
/* define variable Tot-host-sel-goods1 as class Dis-tot_host no-undo .*/
                                                                      /* Salience 2 rule_id 1771*/
/* define variable Tot-sel-goods1 as class Dis-tot_ no-undo .*/
                                                                      /* Salience 4 rule_id 1771*/
/* define variable Gds-line1 as class Gds-dtl_obj no-undo .*/
                                                                      /* Salience 8 rule_id 1771*/
/* define variable Sum-brutto1-rubl as  decimal no-undo .*/
                                                                      /* Salience 9 rule_id 1771*/
/* define variable Sum-netto1-rubl as  decimal no-undo .*/
                                                                      /* Salience 10 rule_id 1771*/
/* define variable Sum-discnt1-rubl as  decimal no-undo .*/
                                                                      /* Salience 11 rule_id 1771*/
/* define variable Sum-brutto1-base as  decimal no-undo .*/
                                                                      /* Salience 12 rule_id 1771*/
/* define variable Sum-netto1-base as  decimal no-undo .*/
                                                                      /* Salience 13 rule_id 1771*/
/* define variable Sum-discnt1-base as  decimal no-undo .*/
                                                                      /* Salience 14 rule_id 1771*/
/* define variable v-index-rule-nums as  integer no-undo .*/
                                                                      /* Salience 15 rule_id 1771*/
/* define variable v-rule-num as  integer no-undo .*/
                                                                      /* salience 19 rule_id 1771*/
IF  Card1:find_dis-card_( INPUT v-current-d-card) = true  THEN do:   
/* salience 20 in upper-rule-id 1771*/
  _1772:
  do:
                                                                      /* Salience 0 rule_id 1772*/
   Sum-brutto1-rubl = 0 .
                                                                      /* Salience 1 rule_id 1772*/
   Sum-discnt1-rubl = 0 .
                                                                      /* Salience 2 rule_id 1772*/
   Sum-netto1-rubl = 0 .
                                                                      /* Salience 3 rule_id 1772*/
   Sum-brutto1-base = 0 .
                                                                      /* Salience 4 rule_id 1772*/
   Sum-netto1-base = 0 .
                                                                      /* Salience 5 rule_id 1772*/
   Sum-discnt1-base = 0 .
                                                                      /* Salience 6 rule_id 1772*/
   Gds-line1:select_gds-dtl_obj( INPUT  substitute('bufq_gds-dtl_obj.doc-code = "&1" and bufq_trn-doc_obj.d-card = "&2"', v-current-doc-code, v-current-d-card), INPUT " TRUE ") .
                                                                      /* salience 7 rule_id 1772*/
  DO WHILE  Gds-line1:get_gds-dtl_obj( INPUT "next") = true :   
/* salience 8 in upper-rule-id 1772*/
    _1773:
    do:
                                                                      /* Salience 0 rule_id 1773*/
     v-index-rule-nums = 0 .
                                                                      /* salience 1 rule_id 1773*/
    DO WHILE  context_get-next-rule-call-param( input "p-rule-nums", input-output v-index-rule-nums) = true :   
/* salience 2 in upper-rule-id 1773*/
      _1774:
      do:
                                                                      /* Salience 0 rule_id 1774*/
       v-rule-num = context_get-rule-call-param_integer( input "p-rule-nums", input v-index-rule-nums) .
                                                                      /* salience 1 rule_id 1774*/
      IF  Gds-line1:run_dis-rule( INPUT v-rule-num, INPUT {&dgr-dis-tot-flag}, INPUT {&cd-type-bo}) = true AND Gds-line1:get_dis-rule-value_logical( INPUT "") = true  THEN do:   
/* salience 2 in upper-rule-id 1774*/
        _1775:
        do:
                                                                      /* salience 0 rule_id 1775*/
        IF  v-curr-r-b = "rubl"  THEN do:   
/* salience 1 in upper-rule-id 1775*/
          _1777:
          do:
                                                                      /* Salience 0 rule_id 1777*/
           Sum-brutto1-rubl = Sum-brutto1-rubl + v-sign * Gds-line1:fact-qnty * Gds-line1:price-rubl .
                                                                      /* Salience 1 rule_id 1777*/
           Sum-discnt1-rubl = Sum-discnt1-rubl + v-sign * Gds-line1:fact-qnty * Gds-line1:discnt-rubl .
                                                                      /* Salience 2 rule_id 1777*/
           Sum-netto1-rubl = Sum-netto1-rubl + v-sign * Gds-line1:fact-qnty * ( Gds-line1:price-rubl - Gds-line1:discnt-rubl ) .
                                                                      /* Salience 3 rule_id 1777*/
           Sum-brutto1-base = Sum-brutto1-base + v-sign * Gds-line1:fact-qnty * Gds-line1:price-base / ( Gds-line1:base-rate# / Gds-line1:base-scale# ) .
                                                                      /* Salience 4 rule_id 1777*/
           Sum-discnt1-base = Sum-discnt1-base + v-sign * Gds-line1:fact-qnty * Gds-line1:discnt-base / ( Gds-line1:base-rate# / Gds-line1:base-scale# ) .
                                                                      /* Salience 5 rule_id 1777*/
           Sum-netto1-base = Sum-netto1-base + v-sign * Gds-line1:fact-qnty * ( Gds-line1:price-base - Gds-line1:discnt-base ) / ( Gds-line1:base-rate# / Gds-line1:base-scale# ) .

          end. /*of rule 1777*/
        end. /*of rule 1777*/
        else do: /*rule 1778*/
/* salience 2 in upper-rule-id 1775*/
          _1778:
          do:
                                                                      /* Salience 0 rule_id 1778*/
           Sum-brutto1-base = Sum-brutto1-base + v-sign * Gds-line1:fact-qnty * Gds-line1:price-base .
                                                                      /* Salience 1 rule_id 1778*/
           Sum-discnt1-base = Sum-discnt1-base + v-sign * Gds-line1:fact-qnty * Gds-line1:discnt-base .
                                                                      /* Salience 2 rule_id 1778*/
           Sum-netto1-base = Sum-netto1-base + v-sign * Gds-line1:fact-qnty * ( Gds-line1:price-base - Gds-line1:discnt-base ) .
                                                                      /* Salience 3 rule_id 1778*/
           Sum-brutto1-rubl = Sum-brutto1-rubl + v-sign * Gds-line1:fact-qnty * Gds-line1:price-rubl * Gds-line1:base-rate# / Gds-line1:base-scale# .
                                                                      /* Salience 4 rule_id 1778*/
           Sum-discnt1-rubl = Sum-discnt1-rubl + v-sign * Gds-line1:fact-qnty * Gds-line1:discnt-rubl * Gds-line1:base-rate# / Gds-line1:base-scale# .
                                                                      /* Salience 5 rule_id 1778*/
           Sum-netto1-rubl = Sum-netto1-rubl + v-sign * Gds-line1:fact-qnty * ( Gds-line1:price-rubl - Gds-line1:discnt-rubl ) * Gds-line1:base-rate# / Gds-line1:base-scale# .

          end. /*of rule 1778*/
        end. /*of rule 1778*/
                                                                      /* Salience 3 rule_id 1775*/
         leave _1774 .

        end. /*of rule 1775*/
      end. /*of rule 1775*/

      end. /*of rule 1774*/
    end. /*of rule 1774*/

    end. /*of rule 1773*/
  end. /*of rule 1773*/
                                                                      /* salience 9 rule_id 1772*/
  IF  Sum-brutto1-rubl <> 0  THEN do:   
/* salience 10 in upper-rule-id 1772*/
    _1776:
    do:
                                                                      /* salience 0 rule_id 1776*/
    IF  Tot-host-sel-goods1:find_dis-tot_host_sum-id( INPUT v-current-d-card, INPUT v-current-host-code, INPUT p-sum-id, INPUT '':U) = false  THEN do:   
/* salience 1 in upper-rule-id 1776*/
      _1779:
      do:
                                                                      /* salience 0 rule_id 1779*/
      IF  Tot-host-sel-goods1:create_dis-tot_host_sum-id( INPUT v-current-d-card, INPUT v-current-host-code, INPUT p-sum-id, INPUT '':U) = false  THEN do:   
/* salience 1 in upper-rule-id 1779*/
        _1780:
        do:
                                                                      /* Salience 0 rule_id 1780*/
         undo _main, return error v-last-error-message .

        end. /*of rule 1780*/
      end. /*of rule 1780*/

      end. /*of rule 1779*/
    end. /*of rule 1779*/
                                                                      /* Salience 2 rule_id 1776*/
     Tot-host-sel-goods1:gds-tot-base = Tot-host-sel-goods1:gds-tot-base + Sum-brutto1-base .
                                                                      /* Salience 3 rule_id 1776*/
     Tot-host-sel-goods1:gds-dis-base = Tot-host-sel-goods1:gds-dis-base + Sum-discnt1-base .
                                                                      /* Salience 4 rule_id 1776*/
     Tot-host-sel-goods1:pay-tot-base = Tot-host-sel-goods1:pay-tot-base + Sum-netto1-base .
                                                                      /* Salience 5 rule_id 1776*/
     Tot-host-sel-goods1:gds-tot-rubl = Tot-host-sel-goods1:gds-tot-rubl + Sum-brutto1-rubl .
                                                                      /* Salience 6 rule_id 1776*/
     Tot-host-sel-goods1:gds-dis-rubl = Tot-host-sel-goods1:gds-dis-rubl + Sum-discnt1-rubl .
                                                                      /* Salience 7 rule_id 1776*/
     Tot-host-sel-goods1:pay-tot-rubl = Tot-host-sel-goods1:pay-tot-rubl + Sum-netto1-rubl .
                                                                      /* salience 8 rule_id 1776*/
    IF  Tot-host-sel-goods1:dis-tot_hostsave( ) = false  THEN do:   
/* salience 9 in upper-rule-id 1776*/
      _1783:
      do:
                                                                      /* Salience 0 rule_id 1783*/
       undo _main, return error v-last-error-message .

      end. /*of rule 1783*/
    end. /*of rule 1783*/
                                                                      /* salience 10 rule_id 1776*/
    IF  Tot-sel-goods1:find_dis-tot_sum-id( INPUT v-current-d-card, INPUT p-sum-id, INPUT '':U) = false  THEN do:   
/* salience 11 in upper-rule-id 1776*/
      _1781:
      do:
                                                                      /* salience 0 rule_id 1781*/
      IF  Tot-sel-goods1:create_dis-tot_sum-id( INPUT v-current-d-card, INPUT p-sum-id, INPUT '':U) = false  THEN do:   
/* salience 1 in upper-rule-id 1781*/
        _1782:
        do:
                                                                      /* Salience 0 rule_id 1782*/
         undo _main, return error v-last-error-message .

        end. /*of rule 1782*/
      end. /*of rule 1782*/

      end. /*of rule 1781*/
    end. /*of rule 1781*/
                                                                      /* Salience 12 rule_id 1776*/
     Tot-sel-goods1:gds-tot-base = Tot-sel-goods1:gds-tot-base + Sum-brutto1-base .
                                                                      /* Salience 13 rule_id 1776*/
     Tot-sel-goods1:gds-dis-base = Tot-sel-goods1:gds-dis-base + Sum-discnt1-base .
                                                                      /* Salience 14 rule_id 1776*/
     Tot-sel-goods1:pay-tot-base = Tot-sel-goods1:pay-tot-base + Sum-netto1-base .
                                                                      /* Salience 15 rule_id 1776*/
     Tot-sel-goods1:gds-tot-rubl = Tot-sel-goods1:gds-tot-rubl + Sum-brutto1-rubl .
                                                                      /* Salience 16 rule_id 1776*/
     Tot-sel-goods1:gds-dis-rubl = Tot-sel-goods1:gds-dis-rubl + Sum-discnt1-rubl .
                                                                      /* Salience 17 rule_id 1776*/
     Tot-sel-goods1:pay-tot-rubl = Tot-sel-goods1:pay-tot-rubl + Sum-netto1-rubl .
                                                                      /* salience 18 rule_id 1776*/
    IF  Tot-sel-goods1:dis-tot_save( ) = false  THEN do:   
/* salience 19 in upper-rule-id 1776*/
      _1784:
      do:
                                                                      /* Salience 0 rule_id 1784*/
       undo _main, return error v-last-error-message .

      end. /*of rule 1784*/
    end. /*of rule 1784*/

    end. /*of rule 1776*/
  end. /*of rule 1776*/

  end. /*of rule 1772*/
end. /*of rule 1772*/

end. /*of rule 1771*/


    /* ------------------------- &end-rule -------------------------------------*/
    if p-order-id = 0
    and p-profile-id = 1
    and (p-ruleset-id < 5
         or
         p-ruleset-id = 6)
    then do:
      if g#db-num = 0
      and g#news
      then do:
        FOR EACH vchk-pay where vchk-pay.d-card = temp-d-card.d-card
        On error undo _main, return error
        :
          if NOT vchk-pay.cre-pay then do:
        /*надо создать запись payment если это не оплата в кредит!!!*/
          if p-doc-type = {&hn-source-import} then do:
            assign
            p-doc-type = '':U.
          end.
          define variable v-payment-host-code as integer no-undo .
          if p-ruleset-id = 6 then do:
            { gbl/hostcode.i temp-d-card.obj-type temp-d-card.obj-code v-payment-host-code }
          end.
          else do:
            v-payment-host-code = v-current-host-code.
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
                        ,input vchk-pay.pay-code
                        ,input {&fact}
                        ,input '':U /*ps*/
                        ,input g#userid
                        ,input g#userid

                        ) no-error.
            IF ERROR-STATUS:ERROR then do:
                undo _main, return error (substitute("Ошибка создания записи оплаты по дисконтной карте &1: &2", temp-d-card.d-card, return-value )).
            end.
          end.
          delete vchk-pay.
        end. /*      FOR EACH vchk-pay where vchk-pay.d-card = temp-d-card.d-card*/
      end. /*if g#db-num = 0*/
    end. /*if p-order-id = 0*/
     /*это делается в inkasw.p если*/
    /* ------------------------- &start-release-obj& -----------------------------------*/
&scop release_1 release_ ( )
Card1:Dis-card_{&release_1} .
&scop release_1 release_ ( )
Tot-host-sel-goods1:Dis-tot_host{&release_1} .
&scop release_1 release_ ( )
Tot-sel-goods1:Dis-tot_{&release_1} .
&scop release_1 release_ ( )
Gds-line1:Gds-dtl_obj{&release_1} .


    /* ------------------------- &end-release-obj& -------------------------------------*/
      num-rec-ok = num-rec-ok + 1.
      if p-ruleset-id = 5 then do:
        run set-num-rec in p-parent-handle ( input num-rec
                                            ,input num-rec-calc-err
                                            ,input num-rec-value-err
                                            ,input num-rec-ok
                                            ,input no
                                            ) no-error .
      end.
    end. /*for each temp-d-card where*/
    if p-ruleset-id = 5 then do:
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
and buf_rule-call-param.param-name = "p-rule-nums"
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
and buf_rule-call-param.param-name = "p-sum-id"
 no-error.
if available buf_rule-call-param then do:
assign p-sum-id = buf_rule-call-param.param-value-character.
end.



/*---------------------------&end-process-rule-call-param&-------------------------------*/
    assign
    vh_dis-card-sale_obj = buffer temp-d-card:handle
    v-save = p-save
    v-current-doc-type = p-doc-type
    .
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
      when 3 or
      when 6 then do:
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
      when 5 then do:
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
      when 7
      or when 9
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
    end case.
  end. /*doe*/

end procedure. /* load-ruleset-context */

procedure delete-procedure :

  do
  on error undo, return error
  :
      run garbcoll_clear in this-procedure .

  end.

end procedure. /* delete-procedure */





