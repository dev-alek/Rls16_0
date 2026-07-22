/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

общий кусочек для gen-flp     задание начальных переменных для формирования ФО расходных

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06


Creation date: 02/18/04 5:57

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable p-ri       as recid   no-undo .
define variable p-doc-code             like         ub.fin-ob.doc-code         no-undo .
define variable n-doc-date             like         ub.fin-ob.doc-date         no-undo .
define variable n-doc-type             like     ub.fin-ob.doc-type             no-undo .
define variable n-payer-name           like         ub.fin-ob.payer-name       no-undo .
define variable n-receiver-name        like         ub.fin-ob.receiver-name    no-undo .
define variable n-curr-code            like         ub.fin-ob.curr-code        no-undo .
define variable n-sum-doc              like         ub.fin-ob.sum-doc          no-undo .
define variable n-user-db-num-doc      like         ub.fin-ob.user-db-num-doc  no-undo .
define variable n-user-name-doc        like         ub.fin-ob.user-name-doc    no-undo .
define variable n-base-rate            like         ub.fin-ob.base-rate        no-undo .
define variable n-base-scale           like         ub.fin-ob.base-scale       no-undo .
define variable n-receiver-code        like         ub.fin-ob.receiver-code    no-undo .
define variable n-receiver-type        like         ub.fin-ob.receiver-type    no-undo .
define variable n-contract-code        like         ub.fin-ob.contract-code    no-undo .
define variable n-exch-rate            like         ub.fin-ob.exch-rate        no-undo .
define variable n-exch-scale           like         ub.fin-ob.exch-scale       no-undo .
define variable n-contract-curr        like         ub.fin-ob.contract-curr    no-undo .
define variable n-contract-rate        like         ub.fin-ob.contract-rate    no-undo .
define variable n-contract-scale       like         ub.fin-ob.contract-scale   no-undo .
define variable n-fact-date            like         ub.fin-ob.fact-date        no-undo .
define variable n-fact-order           like         ub.fin-ob.fact-order       no-undo .
define variable n-payer-code           like         ub.fin-ob.payer-code       no-undo .
define variable n-payer-type           like         ub.fin-ob.payer-type       no-undo .
define variable n-pay-date             like         ub.fin-ob.pay-date         no-undo .
define variable n-prn-doc-code         like         ub.fin-ob.prn-doc-code     no-undo .
define variable n-sum-base-orig        like         ub.fin-ob.sum-base-orig    no-undo .
define variable n-sum-base             like         ub.fin-ob.sum-base         no-undo .
define variable n-sum-doc-orig         like         ub.fin-ob.sum-doc-orig     no-undo .
define variable n-sum-rubl-orig        like         ub.fin-ob.sum-rubl-orig    no-undo .
define variable n-sum-rubl             like         ub.fin-ob.sum-rubl         no-undo .
define variable n-sum-contract         like         ub.fin-ob.sum-contract     no-undo .
define variable n-trn-doc-code         like         ub.fin-ob.trn-doc-code     no-undo .
define variable n-trn-doc-code-orig    like         ub.fin-ob.trn-doc-code     no-undo .
define variable n-user-db-num-fact     like         ub.fin-ob.user-db-num-fact no-undo .
define variable n-user-db-num-pay      like         ub.fin-ob.user-db-num-pay  no-undo .
define variable n-user-name-fact       like         ub.fin-ob.user-name-fact   no-undo .
define variable n-user-name-pay        like         ub.fin-ob.user-name-pay    no-undo .
define variable n-in-type              like         ub.fin-ob.in-type          no-undo .
define variable n-sum-tax-base         like         ub.fin-ob.sum-tax-base     no-undo .
define variable n-sum-tax-doc          like         ub.fin-ob.sum-tax-doc      no-undo .
define variable n-sum-tax-rubl         like         ub.fin-ob.sum-tax-rubl     no-undo .
define variable n-sum-tax-contract     like         ub.fin-ob.sum-tax-contract no-undo .
define variable n-obj-code             like         ub.fin-ob.obj-code       no-undo .
define variable n-obj-type             like         ub.fin-ob.obj-type       no-undo .


define variable col-part   as integer   no-undo .
define variable n-abbr-doc as character no-undo .
define variable v-date-pay as date      no-undo .
define variable var-date as date no-undo .



if not available buf_contract then return .

if not can-find (first temp-parts no-lock ) then return .
/*
SV
where
temp-parts.contract-code = buf_contract.contract-code
*/


/* Обязательство создается по текущему контракту на некую сумму  в      р у б л я х  */

{ gbl/baserate.i
  par-host-code
  today
  n-base-rate
  n-base-scale   }

  n-curr-code          = buf_contract.curr-code.

{ gbl/exchrate.i
  n-curr-code
  today
  n-exch-rate
  n-exch-scale
  n-abbr-doc }

 /*  формируем расходные ФО */
assign
  n-doc-type            =  {&expense}
  n-receiver-code       =  buf_contract.cli-code
  n-receiver-type       =  buf_contract.cli-type
  n-receiver-name       =  buf_contract.cli-name
  n-payer-code          =  par-host-code
  n-payer-type          =  {&cmp}
  n-payer-name          =  buf_contract.own-name
.
 if lookup ( buf_contract.usl-opl , "{&bef-contr-pay-fact-in},{&bef-contr-pay-fact-out},{&bef-contr-pay-fact-out-prc}") > 0
   then v-date-pay = today  .
   else dO:
        if p-cons = 2 and available   buf_trn-doc then do: /* раздельно */
            var-date = buf_trn-doc.fact-date + (if buf_contract.srok-opl <> ? then buf_contract.srok-opl else 0 ) .
            if var-date < today then var-date = today.
            v-date-pay = var-date.
        end.
   end.


 if p-cons = 2 then do:
      if available   buf_trn-doc
         then
         assign
           n-trn-doc-code       =  buf_trn-doc.doc-code
         .

         else  n-trn-doc-code       = ?   .
     end.
     else do:
       if pfo = true and available   buf_trn-doc
         then  assign
           n-trn-doc-code       =  buf_trn-doc.doc-code
         .

         else  n-trn-doc-code      = ?   .

     end.

assign
  n-user-db-num-doc    = g#db-num
  n-user-name-doc      = g#userid
  n-contract-code      = buf_contract.contract-code
  n-contract-curr      = n-curr-code
  n-contract-rate      = n-exch-rate
  n-contract-scale     = n-exch-scale
  n-pay-date           = v-date-pay

  n-sum-rubl-orig      = v-sum-rubl
  n-sum-base-orig      = /* (  n-base-scale   / n-base-rate ) * v-sum-rubl */    v-sum-base
  n-sum-contract       = /* (  n-exch-scale   / n-exch-rate ) * v-sum-rubl  */   v-sum-contract

  n-sum-base           = n-sum-base-orig
  n-sum-doc-orig       = n-sum-contract
  n-sum-doc            = n-sum-contract
  n-sum-rubl           = n-sum-rubl-orig

  n-trn-doc-code-orig  = if available  buf_parts-attr then buf_parts-attr.income-in-code else  ?
  n-in-type            = 0
  n-sum-tax-base       = 0
  n-sum-tax-doc        = 0
  n-sum-tax-rubl       = 0
  n-sum-tax-contract   = 0
  n-doc-date           = if p-type-date  = 1 then  date(cur-time-date()) else p-date-end

  /*
  n-fact-date          =
  n-fact-order         =
  n-user-db-num-fact   =
  n-user-db-num-pay    =
  n-user-name-fact     =
  n-user-name-pay      =
  */

 .


/* $Workfile$ e n d */