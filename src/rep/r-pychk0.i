/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Разброска товаров по платежам - внутри одного чека и запись в chk-gds-pay

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "defalgo" &then
&global-define current-algo-1 "1.8"

&else

&if "{1}" = "def" &then
define variable pychk_kk as integer no-undo .  /*текущая позиция в полученном списке товаров*/
define variable pychk_jj as integer no-undo .  /*текущая позиция в полученном списке товаров*/
define variable pychk_jjp as integer no-undo .  /*текущая позиция в полученном списке товаров- бензин*/
define variable pychk_jjo as integer no-undo .  /*текущая позиция в полученном списке товаров - небензин*/
define variable pychk_pay-sum as decimal no-undo .  /*сумма неразбросанного*/
DEFINE VARIABLE pychk_No-EXCH as logical no-undo. /*если все в р у б л я х то курс пересчета 1 к базовой валюте */
DEFINE VARIABLE pychk_No-EXCH-rubl as logical no-undo. /*если r-b- base  и base-code <> 0 то курс пересчета <> 1*/
DEFINE VARIABLE pychk_dop-sump as decimal No-UNDO. /*сумма неразбросанной текущей оплаты*/
DEFINE VARIABLE pychk_dop-sumg as decimal No-UNDO. /*сумма неразбросанного текцщего товара*/
DEFINE VARIABLE pychk_dop-sumk as decimal No-UNDO. /*квант товар-оплата*/
DEFINE VARIABLE pychk_exch as decimal No-UNDO. /*курс платежа*/
DEFINE VARIABLE pychk_exch-rubl as decimal No-UNDO. /*курс платежа*/
define variable pychk_rec-type as integer no-undo .
define variable pychk_line-type as integer no-undo .
define variable pychk_create as logical no-undo .
define variable pychk_pays_count as integer no-undo .
define variable pychk_zero-gds as decimal no-undo .
define variable pychk_zero-pay as decimal no-undo .
define variable pychk_zero-n as decimal no-undo .
define variable pychk_value as character no-undo .
define variable pychk_type as character no-undo .
define variable pychk_line-type-chr as character no-undo .
define variable pychk_payline_rrn as character no-undo .
define variable vSum as decimal no-undo.
define variable vSumRound as decimal no-undo.
define variable pychk_sum-promo as decimal no-undo. /* сумма оплаты по промо цене (НП) */
define variable vPromoLineNum as integer no-undo. /* номер строки  чеке по промо цене */

define temp-table temp-ptrl-goods no-undo
field b-code as integer
field gds-code as integer
field ptrl-good as logical /*no -good yes -petrol*/
index pi as unique primary
b-code
.

define buffer buf_temp-chk-gds for temp-chk-gds.
define buffer buf_temp-chk-gds2 for temp-chk-gds.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
define buffer buf2_chk-doc for ub.chk-doc.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_chk-pay-attr for ub.chk-pay-attr .

{ str/cspromo-chk.i } /* функции для работы с промоакциями по НП */

&else
if first-of(ub.CHK-pay.DOC-CODE) THEN Do:
  pychk_create = not can-find (first buf_chk-gds-pay
                               where buf_chk-gds-pay.doc-code = ub.chk-doc.doc-code
                                 and buf_chk-gds-pay.algo-num = {&current-algo-1}) .
  if pychk_create then do:
    for each temp-chk-pay:
      delete temp-chk-pay.
    end.
    for each temp-chk-gds:
      delete temp-chk-gds.
    end.
    for each temp-chk-dp:
      delete temp-chk-dp.
    end.
    assign
    pychk_kk = 0 /*текущая позиция в полученном списке товаров*/
    pychk_jj = 1 /*всего записей temp-chk-gds*/
    pychk_jjp = 0 /*записей топлива*/
    pychk_jjo = 0 /*записей нетоплива*/
    pychk_pay-sum = ub.chk-doc.netto /*сумма неразбросанного*/
    pychk_dop-sumg = 0
    pychk_pays_count = 0
    .
  end .
end.
if pychk_create  /* and ub.chk-doc.doc-code eq "38/47470" */ then do:
create-block:
do transaction
/*on error  undo create-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))*/
on stop   undo create-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo create-block, return error substitute( "&1. endkey", vss-workfile )
on error  undo, throw:
  find first buf2_chk-doc exclusive-lock where
         recid(buf2_chk-doc) = recid(ub.chk-doc).

  if first-of(ub.CHK-pay.DOC-CODE) THEN Do:
    FOR EACH ub.chk-gds No-LOCK WHERE
            ub.chk-gds.doc-code = ub.chk-pay.doc-code
    BY ub.chk-gds.line-num:
      if   ub.chk-gds.write-off-code > 0 
        or ub.chk-gds.doc-qnty  eq 0  
        or ub.chk-gds.doc-qnty  eq ?
      then NEXT.
      find first buf_bar-code no-lock where
                buf_bar-code.b-code = ub.chk-gds.b-code no-error.
      if not available buf_bar-code then do:
        undo create-block, return error substitute("Не найден товар для бар-кода &1: чек &2 &3&4 строка &5"
                                                    , ub.chk-gds.b-code
                                                    , ub.chk-gds.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code
                                                    , ub.chk-gds.line-num).
      end.

      /*топливо*/
      if ub.chk-gds.pump <> 0 then do:
        pychk_rec-type = 1.
        find first temp-ptrl-goods where
                   temp-ptrl-goods.b-code = ub.chk-gds.b-code no-error.
        if not available temp-ptrl-goods then do:
          /*найдем атрибут ptrl-as-good*/
          run gds-attr-value in this-procedure (
                                                 input buf_bar-code.gds-code
                                                ,input {&attr-ptrl-as-good}
                                                ,output pychk_value
                                                ,output pychk_type) no-error.
          create temp-ptrl-goods.
          assign
          temp-ptrl-goods.gds-code = buf_bar-code.gds-code
          temp-ptrl-goods.b-code = buf_bar-code.b-code
          temp-ptrl-goods.ptrl-good = (not logical(pychk_value)) /*здесь возникает ошибка так как на товаре нет атрибута {&attr-ptrl-as-good}*/
          no-error.
        end.
        pychk_line-type = if temp-ptrl-goods.ptrl-good then 1 else 0 .
        release temp-ptrl-goods.
      end.
      else do:
        assign
        pychk_rec-type = 0
        pychk_line-type = 0
        .
      end.
      find first temp-chk-gds where
                temp-chk-gds.doc-code = ub.chk-gds.doc-code
            AND temp-chk-gds.rec-type = pychk_rec-type
            and temp-chk-gds.b-code = ub.chk-gds.b-code
            and temp-chk-gds.line-num = 0
            no-error.
      if not available temp-chk-gds then do:
        find first temp-chk-gds use-index ijj where
                temp-chk-gds.jj_ = pychk_jj
            and temp-chk-gds.line-num = 0
                no-error.
        if not available temp-chk-gds then do:
          create temp-chk-gds.
          assign
          temp-chk-gds.jj_ = pychk_jj
          temp-chk-gds.b-code = ub.chk-gds.b-code
          temp-chk-gds.doc-code = ub.chk-gds.doc-code
          temp-chk-gds.line-num = 0
          temp-chk-gds.rec-type = pychk_rec-type
          temp-chk-gds.gds-code = buf_bar-code.gds-code.
          .

        end.
        else do:
          assign
          temp-chk-gds.b-code = ub.chk-gds.b-code
          temp-chk-gds.doc-code = ub.chk-gds.doc-code
          temp-chk-gds.line-num = 0
          temp-chk-gds.rec-type = pychk_rec-type
          temp-chk-gds.sum = 0
          temp-chk-gds.jjp_ = 0
          temp-chk-gds.jjo_ = 0
          temp-chk-gds.line-type = '':U
          temp-chk-gds.num-lines = 0
          temp-chk-gds.doc-qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.flag  = no
          .
        end.
        assign
        temp-chk-gds.line-type = (if pychk_line-type = 1
                                then {&petrolium}
                                else entry(1, ub.chk-gds.line-type, {&delim-par})
                                ) + {&delim-par} +
                                (if num-entries(ub.chk-gds.line-type, {&delim-par}) > 1
                                then entry(2, ub.chk-gds.line-type, {&delim-par})
                                else '')
        temp-chk-gds.line-num = 0
        temp-chk-gds.num-lines = 0
        temp-chk-gds.density   = ub.chk-gds.density
        pychk_jj = pychk_jj + 1
        .
        if pychk_rec-type = 1 then do:
          assign
          temp-chk-gds.jjp_ = pychk_jjp + 1
          pychk_jjp = pychk_jjp + 1
          .
        end.
        else do:
          assign
          temp-chk-gds.jjo_ = pychk_jjo + 1
          pychk_jjo = pychk_jjo + 1
          .
        end.
      end. /*if not available temp-chk-gds then do:*/
      
      vSumRound = ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt).
      if ChkPromoPrice(ub.chk-gds.doc-code, ub.chk-gds.line-num) then vSumRound = ub.chk-gds.src-sum.
                
      assign
      temp-chk-gds.doc-qnty = temp-chk-gds.doc-qnty + ub.chk-gds.doc-qnty
      temp-chk-gds.sum = temp-chk-gds.sum + vSumRound
      temp-chk-gds.num-lines = temp-chk-gds.num-lines  + 1
      .
      find first temp-chk-gds use-index ijj where
              temp-chk-gds.jj_ = 0
          and temp-chk-gds.line-num = ub.chk-gds.line-num
              no-error.
      if not available temp-chk-gds then do:
        create temp-chk-gds.
        assign
        temp-chk-gds.jj_ = 0
        temp-chk-gds.line-num = ub.chk-gds.line-num
        temp-chk-gds.doc-code = ub.chk-gds.doc-code
        temp-chk-gds.b-code = ub.chk-gds.b-code
        temp-chk-gds.gds-code = buf_bar-code.gds-code
        temp-chk-gds.rec-type = pychk_rec-type
        temp-chk-gds.line-num = ub.chk-gds.line-num
        .

      end.
      else do:
        assign
        temp-chk-gds.doc-qnty = 0
        temp-chk-gds.doc-code = ub.chk-gds.doc-code
        temp-chk-gds.b-code = ub.chk-gds.b-code
        temp-chk-gds.gds-code = buf_bar-code.gds-code
        temp-chk-gds.rec-type = pychk_rec-type
        temp-chk-gds.line-num = ub.chk-gds.line-num
        temp-chk-gds.jjp_ = 0
        temp-chk-gds.jjo_ = 0
        temp-chk-gds.line-type = '':U
                .
      end.
      assign
      temp-chk-gds.doc-code = ub.chk-gds.doc-code
      temp-chk-gds.b-code = ub.chk-gds.b-code
      temp-chk-gds.doc-qnty = ub.chk-gds.doc-qnty
      temp-chk-gds.price-base = ub.chk-gds.price-base
      temp-chk-gds.price-service = ub.chk-gds.price-service
      temp-chk-gds.line-type = (if pychk_line-type = 1
                              then {&petrolium}
                              else entry(1, ub.chk-gds.line-type, {&delim-par})
                              ) + {&delim-par} +
                              (if num-entries(ub.chk-gds.line-type, {&delim-par}) > 1
                              then entry(2, ub.chk-gds.line-type, {&delim-par})
                              else '')
      temp-chk-gds.line-sign = ub.chk-gds.line-sign
      temp-chk-gds.discnt = ub.chk-gds.discnt
      temp-chk-gds.sum = vSumRound
      temp-chk-gds.rec-type = pychk_rec-type
      temp-chk-gds.line-num = ub.chk-gds.line-num
      temp-chk-gds.num-lines = 1
      temp-chk-gds.density   = ub.chk-gds.density
      .
    END. /* FOR EACH ub.chk-gds No-LOCK WHERE */
    for each chk-discnt no-lock
       where chk-discnt.doc-code = ub.chk-doc.doc-code
         and record-type = 10
         and chk-discnt.discnt-value-abs <> 0,
        first ub.chk-gds of ub.chk-doc where ub.chk-gds.line-num =  chk-discnt.object-line-num :
            if ub.chk-doc.chk-type = 1 and chk-discnt.object-qnty < 0 then do:  /*Если есть */
                for first temp-chk-dp where temp-chk-dp.doc-code = ub.chk-doc.doc-code
                and temp-chk-dp.b-code = chk-gds.b-code:
                    temp-chk-dp.sum = temp-chk-dp.sum - abs(chk-discnt.discnt-value-abs * chk-discnt.object-qnty).
                end.    
            end.
            else do: 
                  
                /*создаем временную структуру для принудительного распределения */
                create temp-chk-dp .
                assign
                temp-chk-dp.doc-code = ub.chk-doc.doc-code
                temp-chk-dp.sum = abs(chk-discnt.discnt-value-abs) * chk-discnt.object-qnty
                temp-chk-dp.line-num = chk-discnt.object-line-num
                temp-chk-dp.pay-code = chk-discnt.rank
                temp-chk-dp.b-code = chk-gds.b-code
                temp-chk-dp.qnty   = abs(chk-discnt.discnt-value-pcnt)
                temp-chk-dp.all-sum =  chk-discnt.discnt-value-abs * chk-discnt.discnt-value-pcnt
                .
            end.            
    end. 
    
  end. /*if first-of ub.chk-pay.DOC-CODE*/

  FIND FIRST ub.cash-pay No-LOCK WHERE
            ub.cash-pay.cdpay-code = ub.chk-pay.pay-code AND
            ub.cash-pay.curr-code = ub.chk-pay.curr-code No-ERROR.
  if available ub.cash-pay then do:
    /* 28/XI-2018  в месте, где платежи складываюся вставить еще проверку на RRN */
    pychk_payline_rrn = "" .
    if not ub.cash-pay.is-cash then do :
      for first buf_chk-pay-attr no-lock
          where buf_chk-pay-attr.doc-code  = ub.CHK-pay.DOC-CODE
            and buf_chk-pay-attr.attr-code = "cpdoc":U
            and buf_chk-pay-attr.line-num  = ub.CHK-pay.line-num :
        pychk_payline_rrn = buf_chk-pay-attr.attr-value .
      end .
    end .
    
      find first temp-chk-pay where
              temp-chk-pay.doc-code = ub.chk-pay.doc-code
          and temp-chk-pay.pay-code = ub.chk-pay.pay-code
          and temp-chk-pay.pay-card = ub.chk-pay.pay-card
          and temp-chk-pay.curr-code = ub.chk-pay.curr-code
          and temp-chk-pay.rrn       = pychk_payline_rrn
                 no-error.
    if not available temp-chk-pay then do:
      /*if (ub.chk-pay.tot-sum >= 0) NE (ub.chk-doc.netto >= 0)
      and ub.chk-pay.tot-sum <> 0
      and abs(ub.chk-doc.netto) > 0.00000001
      then do:
*/
        /*сдача*/
        find first temp-chk-pay where
                temp-chk-pay.doc-code = ub.chk-pay.doc-code
            and temp-chk-pay.pay-code = ub.chk-pay.pay-code
            and temp-chk-pay.pay-card = ub.chk-pay.pay-card
            and temp-chk-pay.curr-code = ub.chk-pay.curr-code
            and abs(temp-chk-pay.tot-r-b) >= abs(ub.chk-pay.tot-sum)
            and (temp-chk-pay.tot-r-b >=0) NE (ub.chk-pay.tot-sum >=0)
            no-error.
            /*
        if not available temp-chk-pay then do:
          /*сдача наличными  в баз вал касы*/
          
          find first temp-chk-pay where
                  temp-chk-pay.doc-code = ub.chk-pay.doc-code
              and temp-chk-pay.pay-code = 1
              and temp-chk-pay.curr-code = (if v-curr-r-b = {&r-b-rubl}
                                            then 0
                                            else v-base-code) /*баз вал кассы*/
              and abs(temp-chk-pay.tot-rubl) >= abs(ub.chk-pay.tot-rubl )
              and (temp-chk-pay.tot-r-b >=0) NE (ub.chk-pay.tot-sum >=0)
              no-error.
          if not available temp-chk-pay then do:
            /*сдача на первый попавшийся в баз вал касы*/
            find first temp-chk-pay where
                    temp-chk-pay.doc-code = ub.chk-pay.doc-code
                and abs(temp-chk-pay.tot-rubl) >= abs(ub.chk-pay.tot-rubl  )
                and (temp-chk-pay.tot-r-b >=0) NE (ub.chk-pay.tot-sum >=0)
                no-error.
            /*if not available temp-chk-pay then do:
              if not g#auto then do:
                message
                substitute("Не могу обработать чек &1&2&3&4 смена &5 пор.&6 касса &7 № на кассе &8"
                          ,ub.chk-doc.doc-code
                          ,{&new-line}
                          ,ub.chk-doc.obj-type
                          ,ub.chk-doc.obj-code
                          ,ub.chk-doc.shift-date
                          ,ub.chk-doc.shift-num
                          ,ub.chk-doc.pay-desk
                          ,ub.chk-doc.chk-num)
                view-as alert-box error .
              end.
              next _chk-doc.
            end.
          end. /*if not available temp-chk-pay then do:*/
          */
        end. /*if not available temp-chk-pay then do:*/
  /*    end. /*if (ub.chk-pay.tot-sum >= 0) NEQ (ub.chk-doc.netto >= 0) then do:*/
      else */ */
      if not  avail temp-chk-pay then do:
        /*прямой платеж*/
        find first temp-chk-pay where
                  temp-chk-pay.doc-code = ub.chk-pay.doc-code
              and temp-chk-pay.line-num = ub.chk-pay.line-num use-index pi no-error.
        if not available temp-chk-pay then do:
          create temp-chk-pay.
          assign
          temp-chk-pay.line-num = ub.chk-pay.line-num
          temp-chk-pay.doc-code = ub.chk-doc.doc-code
          temp-chk-pay.pay-code = ub.chk-pay.pay-code
          temp-chk-pay.curr-code = /*(if ub.chk-pay.pay-code = 1 then 0 else ub.chk-pay.curr-code)*/ ub.chk-pay.curr-code
          temp-chk-pay.rrn       = pychk_payline_rrn
          pychk_pays_count = pychk_pays_count + 1
          .
        end.
        assign
        temp-chk-pay.doc-code = ub.chk-doc.doc-code
        temp-chk-pay.pet-good = integer(cash-pay.atr64) * 2 + integer(cash-pay.is-cash) + 2 * int(can-find(first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code ))
        temp-chk-pay.pay-code = ub.chk-pay.pay-code
        temp-chk-pay.curr-code = /*(if ub.chk-pay.pay-code = 1 then 0 else ub.chk-pay.curr-code)*/ ub.chk-pay.curr-code
        temp-chk-pay.is-cash  = ub.cash-pay.is-cash
        temp-chk-pay.register = ub.cash-pay.register
        temp-chk-pay.pay-card = ub.chk-pay.pay-card
        temp-chk-pay.tot-rubl = 0
        temp-chk-pay.tot-base = 0
        temp-chk-pay.num-lines = 0
        temp-chk-pay.flag  = no
        .
      end. /*else if (ub.chk-pay.tot-sum >= 0) NEQ (ub.chk-doc.netto >= 0) then do:*/
    end. /*if not available temp-chk-pay then do:*/
    assign
    temp-chk-pay.tot-r-b = temp-chk-pay.tot-r-b + (if v-curr-r-b = {&r-b-rubl}
                                                   then ub.chk-pay.tot-rubl
                                                   else ub.chk-pay.tot-base)
    temp-chk-pay.tot-rubl = temp-chk-pay.tot-rubl + ub.chk-pay.tot-rubl
    temp-chk-pay.tot-base = temp-chk-pay.tot-base + ub.chk-pay.tot-base
    temp-chk-pay.num-lines = temp-chk-pay.num-lines  + 1
    .
  end.
  if available temp-chk-pay then RELEASE TEMP-CHK-PAY.

  if last-of(ub.chk-pay.doc-code) then do:
     /* Проверим что все оплаты со знаком отличным от знака чека схлопнулись */
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-doc.doc-code:
       if    (temp-chk-pay.tot-r-b  >= 0) NE (ub.chk-doc.netto >= 0)
          and temp-chk-pay.tot-r-b <> 0
          and abs(ub.chk-doc.netto) > 0.00000001
       then do:
          if not g#auto then do:
             message
                substitute("Не могу обработать чек &1&2&3&4 смена &5 пор.&6 касса &7 № на кассе &8"
                          ,ub.chk-doc.doc-code
                          ,{&new-line}
                          ,ub.chk-doc.obj-type
                          ,ub.chk-doc.obj-code
                          ,ub.chk-doc.shift-date
                          ,ub.chk-doc.shift-num
                          ,ub.chk-doc.pay-desk
                          ,ub.chk-doc.chk-num)
                view-as alert-box error .
          end.
          next _chk-doc.
       end.
    end.
    
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-doc.doc-code
    break
    by temp-chk-pay.pet-good descending
    /*
    by temp-chk-pay.pay-code
    by temp-chk-pay.curr-code*/
    by temp-chk-pay.line-num:
        /* Сначала распределяем принудительные платежи. */
       dp:
       for each temp-chk-dp no-lock 
          where temp-chk-dp.pay-code = temp-chk-pay.pay-code 
            and temp-chk-dp.doc-code = temp-chk-pay.doc-code 
            and temp-chk-dp.sum <> 0 :        
            find first buf_temp-chk-gds2 where
                buf_temp-chk-gds2.doc-code = ub.chk-doc.doc-code            
            and buf_temp-chk-gds2.line-num  =  temp-chk-dp.line-num no-error.
            if available buf_temp-chk-gds2 then
            for each buf_temp-chk-gds where
                buf_temp-chk-gds.b-code = buf_temp-chk-gds2.b-code
                and buf_temp-chk-gds.line-num ne 0
            no-lock by buf_temp-chk-gds.line-num  ne  temp-chk-dp.line-num :
                     
                 if         temp-chk-dp.all-sum  eq ?
                    or abs(temp-chk-dp.all-sum) <= 0.001
                then
                   next dp.      
                find first  temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code     
                    and buf_temp-chk-gds.b-code = temp-chk-gds.b-code          
                  and temp-chk-gds.line-num = 0
                no-error .
                if not available temp-chk-gds then next dp.
                case num-entries(buf_temp-chk-gds.line-type, {&delim-par}):
                    when 1 then do:
                      pychk_line-type-chr = temp-chk-gds.line-type + {&delim-par} + {&delim-par} + string(temp-chk-pay.num-lines).
                    end.
                    when 2 then do:
                      pychk_line-type-chr = temp-chk-gds.line-type +                {&delim-par} + string(temp-chk-pay.num-lines).
                    end.
                end case.                
                pychk_dop-sumk =  if temp-chk-dp.sum >= 0  
                then min(temp-chk-dp.all-sum,temp-chk-dp.sum,buf_temp-chk-gds.sum,temp-chk-pay.tot-r-b) 
                else max(temp-chk-dp.all-sum,temp-chk-dp.sum,buf_temp-chk-gds.sum).
                if abs(temp-chk-pay.tot-r-b - pychk_dop-sumk) <= 0.001 
                then 
                   pychk_dop-sumk = temp-chk-pay.tot-r-b.
                temp-chk-dp.all-sum           = temp-chk-dp.all-sum - pychk_dop-sumk.
                
                /* из-за ошибок платежей в чеке такая запись уже может быть, тогда не добавляем чек в документ продажи */                               
                if can-find (first buf_chk-gds-pay no-lock where 
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code 
                               and buf_chk-gds-pay.algo-num = {&current-algo-1}
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)  
                                   )
                then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code 
                                                    , buf_temp-chk-gds.line-num                                                                                                       
                                                    , temp-chk-pay.line-num).                               
                create buf_chk-gds-pay.
                  assign
                  buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                  buf_chk-gds-pay.chk-type = ub.chk-doc.chk-type
                  buf_chk-gds-pay.algo-num = {&current-algo-1}
                  buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
                  buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
                  buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                  buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)
                  buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
                  buf_chk-gds-pay.tot-r-b =  pychk_dop-sumk
                                            
                  buf_chk-gds-pay.eff-base-rate = 1
                  buf_chk-gds-pay.eff-doc-qnty = (if (temp-chk-gds.num-lines = 1
                                                  and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                                  and pychk_pays_count = 1) 
                                                  or (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt) = 0 
                                                  then temp-chk-gds.doc-qnty
                                                  else (buf_chk-gds-pay.tot-r-b / (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt))
                                                  )
                  buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
                  buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
                  buf_chk-gds-pay.price-base = buf_temp-chk-gds.price-base
                  buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
                  buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
                  buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
                  buf_chk-gds-pay.line-type = pychk_line-type-chr
                  buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
                  buf_chk-gds-pay.density  = buf_temp-chk-gds.density
                  buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
                  buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
                  buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
                  buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
                  buf_chk-gds-pay.out-code = ub.chk-doc.out-code
                  buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
                  buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
                  buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
                  .
                  
                assign 
                buf_temp-chk-gds.sum = buf_temp-chk-gds.sum - buf_chk-gds-pay.tot-r-b
                temp-chk-gds.sum =  temp-chk-gds.sum - buf_chk-gds-pay.tot-r-b
                buf_temp-chk-gds.doc-qnty = buf_temp-chk-gds.doc-qnty - buf_chk-gds-pay.eff-doc-qnty
                temp-chk-pay.tot-r-b = temp-chk-pay.tot-r-b - buf_chk-gds-pay.tot-r-b
                pychk_dop-sumk = pychk_dop-sumk - buf_chk-gds-pay.tot-r-b
                .
                 if (ub.chk-doc.chk-type = {&bef-rcpt-sale} and temp-chk-pay.tot-r-b <= 0) or (ub.chk-doc.chk-type <> {&bef-rcpt-sale} and temp-chk-pay.tot-r-b >= 0) then leave dp.  /* это подстраховка, если касса лишнего прислала в распределении */
            end.    
        end.    
      assign
      pychk_dop-sump = temp-chk-pay.tot-r-b
      pychk_exch = if pychk_No-exch then 1
                   else (if temp-chk-pay.tot-base = 0
                         then 0
                         else temp-chk-pay.tot-rubl / temp-chk-pay.tot-base)
      pychk_exch-rubl = if pychk_No-exch-rubl
                        then 1
                        else (if temp-chk-pay.tot-base = 0
                              then 0
                              else temp-chk-pay.tot-rubl / temp-chk-pay.tot-base)
      temp-chk-pay.flag = (if abs(temp-chk-pay.tot-rubl) < 0.001 then no else yes)
      .
      _repeat:
      REPEAT WHILE  abs(pychk_dop-sump) > 0 :
        if pychk_dop-sumg = 0 then do:
          assign
          pychk_kk = pychk_kk + 1
          .
          if pychk_kk >= pychk_jj then LEAVE _repeat.
          if pychk_kk <= pychk_jjp then do:
            find first temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                  and temp-chk-gds.jjp_ = pychk_kk
                  and temp-chk-gds.line-num = 0
                no-error .
          end.
          else do:
            find first temp-chk-gds where
                    temp-chk-gds.doc-code = ub.chk-doc.doc-code
                  and temp-chk-gds.jjo_ = pychk_kk - pychk_jjp
                  and temp-chk-gds.line-num = 0
                no-error .
          end.
          if not available temp-chk-gds
          or (temp-chk-gds.sum = 0
              or
              (temp-chk-gds.sum <= 0  and ub.chk-doc.netto > 0)
              )
          then do:
            /*в некоторвых магазинах сумма нетто получалаь < 0 - например на пакетах стоимостью 1 коп*/
            NEXT _repeat.
          end.
          assign
          pychk_dop-sumg = if available temp-chk-gds then temp-chk-gds.sum else 0
          temp-chk-gds.flag = yes
          .
        end. /*if pychk_dop-sumg = 0 then do:*/
        assign
        pychk_dop-sumk = min(abs(pychk_dop-sumg), abs(pychk_dop-sump))  * (if pychk_dop-sump > 0 then 1 else -1 ) * (if pychk_dop-sumg < 0 AND ub.chk-doc.chk-type = {&bef-rcpt-sale} then -1 else 1 ) /*квант*/
        pychk_pay-sum = pychk_pay-sum - pychk_dop-sumk
        pychk_dop-sump = pychk_dop-sump - pychk_dop-sumk
        pychk_dop-sumg = pychk_dop-sumg - pychk_dop-sumk        
        pychk_sum-promo = GetPromoPriceSum(ub.chk-doc.doc-code)
        .           
        if pychk_sum-promo <> 0 then 
           vPromoLineNum = GetPromoPriceLine(ub.chk-doc.doc-code).
        else vPromoLineNum = 0.
                                      
        for each buf_temp-chk-gds where
                buf_temp-chk-gds.doc-code = ub.chk-doc.doc-code
            and buf_temp-chk-gds.b-code = temp-chk-gds.b-code
            and buf_temp-chk-gds.line-num  > 0
        by buf_temp-chk-gds.doc-code
        by buf_temp-chk-gds.rec-type descending
        by buf_temp-chk-gds.line-num
         :
          case num-entries(buf_temp-chk-gds.line-type, {&delim-par}):
            when 1 then do:
              pychk_line-type-chr = buf_temp-chk-gds.line-type + {&delim-par} + {&delim-par} + string(temp-chk-pay.num-lines).
            end.
            when 2 then do:
              pychk_line-type-chr = buf_temp-chk-gds.line-type +                {&delim-par} + string(temp-chk-pay.num-lines).
            end.
          end case.
                       
          /* если на промоцену уже распределили оплату, то пропускаем */
          if  vPromoLineNum <> 0 and 
              temp-chk-gds.num-lines > 1 and 
              buf_temp-chk-gds.line-num = vPromoLineNum and
              can-find(first buf_chk-gds-pay no-lock where 
                             buf_chk-gds-pay.doc-code = buf_temp-chk-gds.doc-code
                         and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num)
          then .               
          else
          /* если строчка была принудительно размазана, то пропускаем ее */
          if not (buf_temp-chk-gds.sum = 0 and can-find (first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code and buf_temp-chk-gds.line-num  =  temp-chk-dp.line-num)) then do:
              
              /* для промо цены всю сумму считаем оплаченой с первой оплаты */                           
              if vPromoLineNum <> 0 and 
                 buf_temp-chk-gds.line-num = vPromoLineNum 
              then do:
                 vSum = RoundUp(buf_temp-chk-gds.doc-qnty, buf_temp-chk-gds.price-base). 
              end.
              else if vPromoLineNum <> 0 and 
                      temp-chk-gds.num-lines > 1 and 
                      pychk_sum-promo <> 0 and
                      ChkPromoLine(buf_temp-chk-gds.doc-code, buf_temp-chk-gds.line-num)
              then do:
                  /* если уже учли оплату промо, то больше не учитываем */
                  if can-find(first buf_chk-gds-pay no-lock where 
                                    buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                                and buf_chk-gds-pay.line-num = vPromoLineNum
                                )
                   then vSum = (pychk_dop-sumk * buf_temp-chk-gds.sum / (temp-chk-gds.sum - pychk_sum-promo)).
                   else vSum = ((pychk_dop-sumk - pychk_sum-promo) * buf_temp-chk-gds.sum / (temp-chk-gds.sum - pychk_sum-promo)).             
              end.
              else             
              vSum                     = (if    temp-chk-gds.num-lines = 1
                                            and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                          then pychk_dop-sumk
                                          else (pychk_dop-sumk * buf_temp-chk-gds.sum / temp-chk-gds.sum)
                                         )
              .
              
              if can-find (first temp-chk-dp no-lock where temp-chk-dp.pay-code = temp-chk-pay.pay-code and temp-chk-dp.doc-code = temp-chk-pay.doc-code) then do:
                  find first buf_chk-gds-pay where buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                  and buf_chk-gds-pay.algo-num = {&current-algo-1}
                  and buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
                  and buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
                  and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                  and buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
                  and buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card exclusive-lock no-error.
                  if not available buf_chk-gds-pay then do:                     
                     /* из-за ошибок платежей в чеке такая запись уже может быть, тогда не добавляем чек в документ продажи */                          
                     if can-find (first buf_chk-gds-pay no-lock where 
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code 
                               and buf_chk-gds-pay.algo-num = {&current-algo-1}
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)  
                                   )
                     then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code 
                                                    , buf_temp-chk-gds.line-num                                                                                                       
                                                    , temp-chk-pay.line-num).                            
                     create buf_chk-gds-pay.
                  end.   
              end.    
              else do:                  
                   /* из-за ошибок платежей в чеке такая запись уже может быть, тогда не добавляем чек в документ продажи */                            
                   if can-find (first buf_chk-gds-pay no-lock where 
                                   buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code 
                               and buf_chk-gds-pay.algo-num = {&current-algo-1}
                               and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                               and buf_chk-gds-pay.cpline-num = int(temp-chk-pay.line-num)  
                                   )
                   then undo create-block, return error substitute("Уже есть платеж: чек &1 &2&3 строка &4 строка &5"
                                                    , temp-chk-pay.doc-code
                                                    , ub.chk-doc.obj-type
                                                    , ub.chk-doc.obj-code 
                                                    , buf_temp-chk-gds.line-num                                                                                                       
                                                    , temp-chk-pay.line-num).                              
                   create buf_chk-gds-pay.
              end.     
                     
              assign
              buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
              buf_chk-gds-pay.chk-type = ub.chk-doc.chk-type
              buf_chk-gds-pay.algo-num = {&current-algo-1}
              buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
              buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
              buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
              buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
              buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
              buf_chk-gds-pay.tot-r-b = buf_chk-gds-pay.tot-r-b  + vSum
              buf_chk-gds-pay.eff-base-rate = pychk_exch  
              buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
              buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
              buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
              buf_chk-gds-pay.price-base = buf_temp-chk-gds.price-base
              buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
              buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
              buf_chk-gds-pay.line-type = pychk_line-type-chr
              buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
              buf_chk-gds-pay.density  = buf_temp-chk-gds.density
              buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
              buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
              buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
              buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
              buf_chk-gds-pay.out-code = ub.chk-doc.out-code
              buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
              buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
              buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
              buf_temp-chk-gds.flag = yes               
              .
                                                                             
              if buf_temp-chk-gds.line-num = vPromoLineNum /* для акционной цены кол-во не вычисляем */ 
              then do:                                   
                 buf_chk-gds-pay.eff-doc-qnty = buf_temp-chk-gds.doc-qnty.                                              
              end.   
              else 
              buf_chk-gds-pay.eff-doc-qnty = (if buf_chk-gds-pay.eff-doc-qnty = ? then 0 else buf_chk-gds-pay.eff-doc-qnty) + (if (temp-chk-gds.num-lines = 1
                                              and abs(pychk_dop-sumk) <= abs(temp-chk-gds.sum)
                                              and pychk_pays_count = 1) 
                                              or (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt) = 0 
                                              then temp-chk-gds.doc-qnty
                                              else (vSum / (buf_temp-chk-gds.price-base - buf_temp-chk-gds.discnt))
                                              )
              .            
            end.
        end.
        /*--------------------записали в нужную таблицу квант товар-оплата--------------------------*/
        
      end. /*    REPEAT WHILE  abs(pychk_dop-sump) > 0 :*/
    end. /*for each temp-chk-pay :*/
    if available temp-chk-gds then release temp-chk-gds.
    if available temp-chk-pay then release temp-chk-pay.
    pychk_zero-gds = 0.
    pychk_zero-pay = 0.
    for each temp-chk-gds where
            temp-chk-gds.doc-code = ub.chk-pay.doc-code
        and temp-chk-gds.flag = no
        and temp-chk-gds.line-num  > 0
        :
       pychk_zero-gds = pychk_zero-gds + 1.
    end.
    for each temp-chk-pay where
            temp-chk-pay.doc-code = ub.chk-pay.doc-code
        and temp-chk-pay.flag = no:
       pychk_zero-pay = pychk_zero-pay + 1.
    end.
    
    
    /* создаем распределяем неоплаченые товары по не использованым оплатам равномерно */
    /* если нет оплаты по которой не было оплаты товара все неоплаченые товары привяжем к первой оплате */
    find first temp-chk-pay where temp-chk-pay.doc-code = ub.chk-pay.doc-code
                              and temp-chk-pay.flag = no
    no-lock no-error.
    if not available temp-chk-pay
    then do:
       block-pay:
       for each temp-chk-pay where temp-chk-pay.doc-code = ub.chk-pay.doc-code:
          assign
             pychk_zero-pay = pychk_zero-pay +  1
             temp-chk-pay.flag = no
          .
          leave block-pay.
       end.
    end.
    
    for each temp-chk-pay
    where   temp-chk-pay.doc-code = ub.chk-pay.doc-code
        and temp-chk-pay.flag = no:
      pychk_zero-n = 0.
      for each buf_temp-chk-gds
      where   buf_temp-chk-gds.doc-code = ub.chk-pay.doc-code
          and buf_temp-chk-gds.flag = no
          and buf_temp-chk-gds.line-num  > 0 :
        pychk_zero-n = pychk_zero-n + 1.
        if  temp-chk-pay.tot-r-b = 0 and buf_temp-chk-gds.discnt = 0 and abs(buf_temp-chk-gds.sum) > 0 then next.  
/*Если вдруг лег полностью нулевой платеж, то создавалась запись на все количество, с нормальной ценой, но нулевой суммой.  это неправильно отражалось в отчетах*/
        case num-entries(buf_temp-chk-gds.line-type, {&delim-par}):
          when 1 then do:
            pychk_line-type-chr = buf_temp-chk-gds.line-type + {&delim-par} + {&delim-par} + string(temp-chk-pay.num-lines).
          end.
          when 2 then do:
            pychk_line-type-chr = buf_temp-chk-gds.line-type +                {&delim-par} + string(temp-chk-pay.num-lines).
          end.
        end case.
        /* если уже распределяли этот платеж, то повторно не пытаемся его создать */
        if can-find(first buf_chk-gds-pay no-lock where 
                          buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
                      and buf_chk-gds-pay.algo-num = {&current-algo-1}
                      and buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
                      and buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num) 
        then do:
            buf_temp-chk-gds.flag = yes.
        end.    
        else do:
            create buf_chk-gds-pay.
            assign
            buf_chk-gds-pay.doc-code = temp-chk-pay.doc-code
            buf_chk-gds-pay.algo-num = {&current-algo-1}
            buf_chk-gds-pay.pay-code = temp-chk-pay.pay-code
            buf_chk-gds-pay.curr-code = temp-chk-pay.curr-code
            buf_chk-gds-pay.line-num = buf_temp-chk-gds.line-num
            buf_chk-gds-pay.cpline-num = temp-chk-pay.line-num
            buf_chk-gds-pay.pay-card = temp-chk-pay.pay-card
            buf_chk-gds-pay.tot-r-b = 0
            buf_chk-gds-pay.eff-base-rate = pychk_exch
            buf_chk-gds-pay.eff-doc-qnty = buf_temp-chk-gds.doc-qnty
            buf_chk-gds-pay.b-code = buf_temp-chk-gds.b-code
            buf_chk-gds-pay.gds-code = buf_temp-chk-gds.gds-code
            buf_chk-gds-pay.discnt = buf_temp-chk-gds.discnt
            buf_chk-gds-pay.price-base = (if temp-chk-pay.tot-r-b = 0 and buf_temp-chk-gds.discnt = 0 then 0 else buf_temp-chk-gds.price-base)
            buf_chk-gds-pay.price-service = buf_temp-chk-gds.price-service
            buf_chk-gds-pay.line-sign = buf_temp-chk-gds.line-sign
            buf_chk-gds-pay.line-type = pychk_line-type-chr
            buf_chk-gds-pay.rec-type = buf_temp-chk-gds.rec-type
            buf_chk-gds-pay.density  = buf_temp-chk-gds.density
            buf_chk-gds-pay.chk-date = ub.chk-doc.chk-date
            buf_chk-gds-pay.chk-time = ub.chk-doc.chk-time
            buf_chk-gds-pay.obj-type = ub.chk-doc.obj-type
            buf_chk-gds-pay.obj-code = ub.chk-doc.obj-code
            buf_chk-gds-pay.out-code = ub.chk-doc.out-code
            buf_chk-gds-pay.shift-date = ub.chk-doc.shift-date
            buf_chk-gds-pay.shift-num = ub.chk-doc.shift-num
            buf_chk-gds-pay.shift-name= ub.chk-doc.shift-name
            buf_temp-chk-gds.flag = yes
            .
        end.    
        if pychk_zero-n > pychk_zero-gds / pychk_zero-pay then leave.
      end. /*for each temp-chk-gds*/
      temp-chk-pay.flag = yes.
    end. /*for each temp-chk-pay*/
  end. /*if last-of(chk-pay.doc-code) then do:*/
end. /*if pychk_create*/
end.
/*
output to r-pychk0.txt append.
for each temp-chk-gds:
  export temp-chk-gds.
end.
for each temp-chk-pay:
  export temp-chk-pay.
end.
for each buf_chk-gds-pay where buf_Chk-gds-pay.doc-code = ub.chk-doc.doc-code:
  export buf_chk-gds-pay.
end.
output close.
*/

&endif
&endif
/* $Workfile$   E n d */