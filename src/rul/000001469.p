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
using Ibs.Th.Rul.Next-discount_.
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


/*---------------------------&start-rule-call-param&-------------------------------*/
 define variable p-r-b as character no-undo.
 define variable p-is-over as logical no-undo.
 define variable p-rule-num as integer no-undo.
 define variable p-prev-rule-num as integer no-undo.
 define variable p-tot-caller-id as character no-undo.
 define variable p-nd-caller-id as character no-undo.


/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/
{ trg/dis-hsth.i rul }
{ trg/dis-hsth.i rul }
{ trg/disproph.i rul }
 { rul/dis-rule_f.i 63 }
{ rul/next-discount_f.i get_current_nd_sum-id_by-date }
{ rul/dis-tot-period_f.i get_current_sum-id_by-date }
{ rul/dis-tot-period_f.i get_prev_sum-id_by-date }
{ rul/dis-tot-period_f.i get_sum-id_by-date_dct }














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
 define variable next-discount1 as class Next-discount_ no-undo .
&scop constructor_1 (  input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input p-cont-handle, input v-current-lock, input v-current-wait, input v-save, input 7)
next-discount1 = new Next-discount_{&constructor_1} .
 define variable prev-sum-id as  character no-undo .
 define variable Tot-sum-current as class Dis-tot_ no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input p-cont-handle, input v-current-lock, input v-current-wait, input v-save, input 5)
Tot-sum-current = new Dis-tot_{&constructor_1} .
 define variable Tot-sum-host-current as class Dis-tot_host no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input p-cont-handle, input v-current-lock, input v-current-wait, input v-save, input 5)
Tot-sum-host-current = new Dis-tot_host{&constructor_1} .
 define variable Tot-sum-host-prev as class Dis-tot_host no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input p-cont-handle, input v-current-lock, input v-current-wait, input v-save, input 5)
Tot-sum-host-prev = new Dis-tot_host{&constructor_1} .
 define variable Tot-sum-prev as class Dis-tot_ no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input p-cont-handle, input v-current-lock, input v-current-wait, input v-save, input 5)
Tot-sum-prev = new Dis-tot_{&constructor_1} .
 define variable v-netto-current as  decimal no-undo .
 define variable v-netto-prev as  decimal no-undo .


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
    if retry then do:
      if p-ruleset-id = {&dct-proc_2_batch-card-recalc_5} then do:
        num-rec-calc-err = num-rec-calc-err + 1.
        undo _d-card, next _d-card .
      end.
      else do:
        undo _main, return error return-value .
      end.
    end.
    num-rec = num-rec + 1.
    assign
    v-current-d-card = temp-d-card.d-card
    .
    do transaction
    On end-key undo _d-card, retry _d-card
    On stop undo _d-card, retry _d-card
    On error undo _d-card, retry _d-card:

    /*buffer buf_dis-card_:find-first( substitute("d-card = &1", v-current-d-card), v-current-lock).*/

    /* ------------------------- &start-rule& -----------------------------------*/
/* Суммы накоплений за текущий и предыдущий период -> % скидки на товар в следующем периоде
Алгоритм зависимости будущих скидок от суммы оплаченных покупок в <ТИП ВАЛЮТЫ> за текущий и предыдущий периоды времени <С/БЕЗ УЧЕТА ПЕРЕВЫПУСКА ДК> */

_1469:
do:
                                                                      /* Salience 0 rule_id 1469*/
/* define variable Card1 as class Dis-card_ no-undo .*/
                                                                      /* Salience 1 rule_id 1469*/
/* define variable v-netto-current as  decimal no-undo .*/
                                                                      /* Salience 2 rule_id 1469*/
/* define variable v-netto-prev as  decimal no-undo .*/
                                                                      /* Salience 3 rule_id 1469*/
/* define variable prev-sum-id as  character no-undo .*/
                                                                      /* salience 4 rule_id 1469*/
IF  get_current_sum-id_by-date( INPUT v-current-doc-date, INPUT p-tot-caller-id) = "?"  THEN do:   
/* salience 5 in upper-rule-id 1469*/
  _1490:
  do:
                                                                      /* Salience 0 rule_id 1490*/
   leave _1469 .

  end. /*of rule 1490*/
end. /*of rule 1490*/
                                                                      /* salience 6 rule_id 1469*/
IF  get_current_nd_sum-id_by-date( INPUT v-current-doc-date, INPUT p-nd-caller-id) = "?"  THEN do:   
/* salience 7 in upper-rule-id 1469*/
  _1479:
  do:
                                                                      /* Salience 0 rule_id 1479*/
   leave _1469 .

  end. /*of rule 1479*/
end. /*of rule 1479*/
                                                                      /* Salience 8 rule_id 1469*/
 prev-sum-id = get_prev_sum-id_by-date( INPUT v-current-doc-date, INPUT p-tot-caller-id) .
                                                                      /* salience 10 rule_id 1469*/
IF  Card1:find_dis-card_( INPUT v-current-d-card) = true  THEN do:   
                                                                      /* Salience 11 rule_id 1469*/
 v-netto-current = 0 .
                                                                      /* Salience 12 rule_id 1469*/
 v-netto-prev = 0 .
/* salience 13 in upper-rule-id 1469*/
  _1478:
  do:
                                                                      /* salience 0 rule_id 1478*/
  IF  Card1:emitent-host-code = 0  THEN do:   
/* salience 1 in upper-rule-id 1478*/
    _1471:
    do:
                                                                      /* Salience 0 rule_id 1471*/
/*     define variable Tot-sum-current as class Dis-tot_ no-undo .*/
                                                                      /* Salience 1 rule_id 1471*/
/*     define variable Tot-sum-prev as class Dis-tot_ no-undo .*/
                                                                      /* salience 2 rule_id 1471*/
    IF  prev-sum-id <> "?"  THEN do:   
/* salience 3 in upper-rule-id 1471*/
      _1808:
      do:
                                                                      /* salience 1 rule_id 1808*/
      IF  Tot-sum-prev:find_dis-tot_sum-id( INPUT v-current-d-card, INPUT prev-sum-id, INPUT p-tot-caller-id) = true  THEN do:   
/* salience 2 in upper-rule-id 1808*/
        _1812:
        do:

        end. /*of rule 1812*/
      end. /*of rule 1812*/

      end. /*of rule 1808*/
    end. /*of rule 1808*/
                                                                      /* salience 8 rule_id 1471*/
    IF  Tot-sum-current:find_dis-tot_date( INPUT v-current-d-card, INPUT v-current-doc-date, INPUT p-tot-caller-id) = true  THEN do:   
/* salience 9 in upper-rule-id 1471*/
      _1470:
      do:
                                                                      /* salience 0 rule_id 1470*/
      IF  p-r-b = "rubl" AND p-is-over = false  THEN do:   
/* salience 1 in upper-rule-id 1470*/
        _1486:
        do:
                                                                      /* Salience 0 rule_id 1486*/
         v-netto-current = Tot-sum-current:pay-tot-rubl .

        end. /*of rule 1486*/
      end. /*of rule 1486*/
                                                                      /* salience 2 rule_id 1470*/
      IF  p-r-b = "rubl" AND p-is-over = true  THEN do:   
/* salience 3 in upper-rule-id 1470*/
        _1489:
        do:
                                                                      /* Salience 0 rule_id 1489*/
         v-netto-prev = Tot-sum-current:pay-tot-rubl_byf# .

        end. /*of rule 1489*/
      end. /*of rule 1489*/
                                                                      /* salience 4 rule_id 1470*/
      IF  p-r-b = "base" AND p-is-over = false  THEN do:   
/* salience 5 in upper-rule-id 1470*/
        _1487:
        do:
                                                                      /* Salience 0 rule_id 1487*/
         v-netto-current = Tot-sum-current:pay-tot-base .

        end. /*of rule 1487*/
      end. /*of rule 1487*/
                                                                      /* salience 6 rule_id 1470*/
      IF  p-r-b = "base" AND p-is-over = true  THEN do:   
/* salience 7 in upper-rule-id 1470*/
        _1481:
        do:
                                                                      /* Salience 0 rule_id 1481*/
         v-netto-current = Tot-sum-current:pay-tot-base_byf# .

        end. /*of rule 1481*/
      end. /*of rule 1481*/

      end. /*of rule 1470*/
    end. /*of rule 1470*/

    end. /*of rule 1471*/
  end. /*of rule 1471*/
                                                                      /* salience 2 rule_id 1478*/
  IF  Card1:emitent-host-code > 0  THEN do:   
/* salience 3 in upper-rule-id 1478*/
    _1480:
    do:
                                                                      /* Salience 0 rule_id 1480*/
/*     define variable Tot-sum-host-current as class Dis-tot_host no-undo .*/
                                                                      /* Salience 1 rule_id 1480*/
/*     define variable Tot-sum-host-prev as class Dis-tot_host no-undo .*/
                                                                      /* salience 2 rule_id 1480*/
    IF  prev-sum-id <> "?"  THEN do:   
/* salience 3 in upper-rule-id 1480*/
      _1810:
      do:
                                                                      /* salience 1 rule_id 1810*/
      IF  Tot-sum-host-prev:find_dis-tot_host_sum-id( INPUT v-current-d-card, INPUT v-current-host-code, INPUT prev-sum-id, INPUT p-tot-caller-id) = true  THEN do:   
/* salience 2 in upper-rule-id 1810*/
        _1811:
        do:

        end. /*of rule 1811*/
      end. /*of rule 1811*/

      end. /*of rule 1810*/
    end. /*of rule 1810*/
                                                                      /* salience 7 rule_id 1480*/
    IF  Tot-sum-host-current:find_dis-tot_host_date( INPUT v-current-d-card, INPUT v-current-host-code, INPUT v-current-doc-date, INPUT p-tot-caller-id) = true  THEN do:   
/* salience 8 in upper-rule-id 1480*/
      _1475:
      do:
                                                                      /* salience 0 rule_id 1475*/
      IF  p-r-b = "rubl" AND p-is-over = false  THEN do:   
/* salience 1 in upper-rule-id 1475*/
        _1476:
        do:
                                                                      /* Salience 0 rule_id 1476*/
         v-netto-current = Tot-sum-host-current:pay-tot-rubl .

        end. /*of rule 1476*/
      end. /*of rule 1476*/
                                                                      /* salience 2 rule_id 1475*/
      IF  p-r-b = "rubl" AND p-is-over = true  THEN do:   
/* salience 3 in upper-rule-id 1475*/
        _1485:
        do:
                                                                      /* Salience 0 rule_id 1485*/
         v-netto-current = Tot-sum-host-current:pay-tot-rubl_byf# .

        end. /*of rule 1485*/
      end. /*of rule 1485*/
                                                                      /* salience 4 rule_id 1475*/
      IF  p-r-b = "base" AND p-is-over = false  THEN do:   
/* salience 5 in upper-rule-id 1475*/
        _1488:
        do:
                                                                      /* Salience 0 rule_id 1488*/
         v-netto-current = Tot-sum-host-current:pay-tot-base .

        end. /*of rule 1488*/
      end. /*of rule 1488*/
                                                                      /* salience 6 rule_id 1475*/
      IF  p-r-b = "base" AND p-is-over = true  THEN do:   
/* salience 7 in upper-rule-id 1475*/
        _1474:
        do:
                                                                      /* Salience 0 rule_id 1474*/
         v-netto-current = Tot-sum-host-current:pay-tot-base_byf# .

        end. /*of rule 1474*/
      end. /*of rule 1474*/

      end. /*of rule 1475*/
    end. /*of rule 1475*/

    end. /*of rule 1480*/
  end. /*of rule 1480*/

  end. /*of rule 1478*/
end. /*of rule 1478*/
                                                                      /* salience 14 rule_id 1469*/
IF  prev-sum-id <> "?" AND v-netto-prev = 0  THEN do:   
/* salience 15 in upper-rule-id 1469*/
  _1813:
  do:
                                                                      /* salience 0 rule_id 1813*/
  IF  get_sum-id_by-date_dct( INPUT  Card1:issue-date# , INPUT p-tot-caller-id, input v-emitent-host-code, INPUt v-type) >= prev-sum-id  THEN do:   
/* salience 1 in upper-rule-id 1813*/
    _1814:
    do:
                                                                      /* Salience 0 rule_id 1814*/
     v-netto-prev = v-netto-current .

    end. /*of rule 1814*/
  end. /*of rule 1814*/

  end. /*of rule 1813*/
end. /*of rule 1813*/
                                                                      /* Salience 16 rule_id 1469*/
/* define variable next-discount1 as class Next-discount_ no-undo .*/
                                                                      /* salience 17 rule_id 1469*/
IF  next-discount1:find_next-discount_date( INPUT v-current-d-card, INPUT v-current-doc-date, INPUT p-nd-caller-id) = false  THEN do:   
/* salience 18 in upper-rule-id 1469*/
  _1494:
  do:
                                                                      /* salience 1 rule_id 1494*/
  IF  next-discount1:create_next-discount_date( INPUT v-current-d-card, INPUT v-current-doc-date, INPUT p-nd-caller-id) = false  THEN do:   
/* salience 2 in upper-rule-id 1494*/
    _1495:
    do:
                                                                      /* Salience 0 rule_id 1495*/
     undo _main, return error v-last-error-message .

    end. /*of rule 1495*/
  end. /*of rule 1495*/

  end. /*of rule 1494*/
end. /*of rule 1494*/
                                                                      /* Salience 19 rule_id 1469*/
 next-discount1:d-pcnt = dis-rule_00063( INPUT p-rule-num, INPUT v-current-doc-date, INPUT v-current-doc-time, INPUT v-netto-current, INPUT p-prev-rule-num, INPUT v-netto-prev) .
                                                                      /* salience 20 rule_id 1469*/
IF  next-discount1:next-discount_save( ) = false  THEN do:   
/* salience 21 in upper-rule-id 1469*/
  _1496:
  do:
                                                                      /* Salience 0 rule_id 1496*/
   undo _main, return error v-last-error-message .

  end. /*of rule 1496*/
end. /*of rule 1496*/

end. /*of rule 1469*/


    /* ------------------------- &end-rule -------------------------------------*/
    if p-order-id = 0
    and p-profile-id = 1
    and (p-ruleset-id < {&dct-proc_2_batch-card-recalc_5}
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
Tot-sum-current:Dis-tot_{&release_1} .
&scop release_1 release_ ( )
Tot-sum-prev:Dis-tot_{&release_1} .
&scop release_1 release_ ( )
Tot-sum-host-current:Dis-tot_host{&release_1} .
&scop release_1 release_ ( )
Tot-sum-host-prev:Dis-tot_host{&release_1} .
&scop release_1 release_ ( )
next-discount1:Next-discount_{&release_1} .


    /* ------------------------- &end-release-obj& -------------------------------------*/
    end. /*do transaction*/
      num-rec-ok = num-rec-ok + 1.
      if p-ruleset-id = {&dct-proc_2_batch-card-recalc_5} then do:
        run set-num-rec in p-parent-handle ( input num-rec
                                            ,input num-rec-calc-err
                                            ,input num-rec-value-err
                                            ,input num-rec-ok
                                            ,input no
                                            ) no-error .
      end.
    end. /*for each temp-d-card where*/
    if p-ruleset-id = {&dct-proc_2_batch-card-recalc_5} then do:
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

 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-rule-num"
 no-error.
if available buf_rule-call-param then do:
assign p-rule-num = buf_rule-call-param.param-value-integer.
end.

 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-prev-rule-num"
 no-error.
if available buf_rule-call-param then do:
assign p-prev-rule-num = buf_rule-call-param.param-value-integer.
end.

 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-tot-caller-id"
 no-error.
if available buf_rule-call-param then do:
assign p-tot-caller-id = buf_rule-call-param.param-value-character.
end.

 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-nd-caller-id"
 no-error.
if available buf_rule-call-param then do:
assign p-nd-caller-id = buf_rule-call-param.param-value-character.
end.



/*---------------------------&end-process-rule-call-param&-------------------------------*/
    assign
    vh_dis-card-sale_obj = buffer temp-d-card:handle
    v-save = p-save
    v-current-doc-type = p-doc-type
    .
    case p-ruleset-id:
      when {&dct-proc_2_sale-close_1} then do:
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
      when {&dct-proc_2_sale-delete_2} then do:
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
      when {&dct-proc_2_trn-doc-close_3} or
      when {&dct-proc_2_import_6} then do:
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
      when {&dct-proc_2_trn-doc-delete_4} then do:
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
      when {&dct-proc_2_batch-card-recalc_5} then do:
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





