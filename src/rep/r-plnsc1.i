/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет Планируемые платежи

Автор: Демин Алексей Сергеевич
Дата создания: 09/14/05
Author: Alexey Demin
Creation date: 09/14/05

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


   create temp-doc .
   assign
     temp-doc.contr      = buf_contract.contract-code
     temp-doc.contr-name = buf_contract.contract-prn-code
     temp-doc.cli-name   = buf_clients.obj-name
     temp-doc.cli-type   = buf_clients.obj-type
     temp-doc.cli-code   = buf_clients.obj-code
     no-fo               = yes
   .

  for each buf_fin-doc no-lock
    where buf_fin-doc.host-code     = buf_contract.host-code
      and buf_fin-doc.contract-code = buf_contract.contract-code
      and buf_fin-doc.status_       = {&fin-fact}
      and buf_fin-doc.fact-order    <  v-fact-order
      and buf_fin-doc.con-stat      < 2
    :
    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 }
/*message*/
/*  buf_fin-doc.sum-rubl buf_fin-doc.con-sum-rubl  buf_fin-doc.sum-contr buf_fin-doc.con-sum-contr*/
/*  view-as alert-box.*/
    if buf_fin-doc.fin-doc-type = {&income-cashless} or buf_fin-doc.fin-doc-type = {&income-cash} or buf_fin-doc.fin-doc-type = {&income-payoff}  then do:
      if x-SET_val_TYPE = 1  then assign temp-doc.sum-pl = temp-doc.sum-pl - buf_fin-doc.sum-rubl + buf_fin-doc.con-sum-rubl .
      else                        assign temp-doc.sum-pl = temp-doc.sum-pl - buf_fin-doc.sum-base + buf_fin-doc.con-sum-base .
    end.
    else do:
      if x-SET_val_TYPE = 1  then assign temp-doc.sum-pl = temp-doc.sum-pl + buf_fin-doc.sum-rubl - buf_fin-doc.con-sum-rubl .
      else                        assign temp-doc.sum-pl = temp-doc.sum-pl + buf_fin-doc.sum-base - buf_fin-doc.con-sum-base .
    end.
  end.

  for each buf_fin-ob no-lock
    where buf_fin-ob.host-code     = buf_contract.host-code
      and buf_fin-ob.contract-code = buf_contract.contract-code
      and buf_fin-ob.status_       = {&fact}
      and buf_fin-ob.con-stat      < 2
      and buf_fin-ob.pay-date      <= x-Date-Alone
    :
    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 }

    create temp-contr .
    assign
      temp-contr.dat       = buf_fin-ob.pay-date
      temp-contr.day       = if buf_fin-ob.pay-date < today then ( today - buf_fin-ob.pay-date ) else  0
      temp-contr.num       = buf_fin-ob.prn-doc-code
      temp-contr.contr     = buf_contract.contract-code
      no-fo                = no
    .
/*message*/
/*  buf_fin-ob.sum-rubl buf_fin-ob.con-sum-rubl  buf_fin-ob.sum-contr buf_fin-ob.con-sum-contr*/
/*  view-as alert-box.*/
    if x-SET_val_TYPE = 1  then assign temp-contr.sum = buf_fin-ob.sum-rubl - buf_fin-ob.con-sum-rubl .
    else                        assign temp-contr.sum = buf_fin-ob.sum-base - buf_fin-ob.con-sum-base .
    assign temp-doc.sum-fo = temp-doc.sum-fo + temp-contr.sum .
  end.
  if temp-doc.sum-pl = 0 and no-fo then delete temp-doc .

/* $Workfile$ e n d */