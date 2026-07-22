/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет Сальдо по поставщикам

Автор: Демин Алексей Сергеевич
Дата создания: 09/14/05
Author: Alexey Demin
Creation date: 09/14/05

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

  for each buf_fin-ob no-lock
    where buf_fin-ob.host-code     = buf_contract.host-code
      and buf_fin-ob.contract-code = buf_contract.contract-code
      and buf_fin-ob.status_       = {&fact}
    :
    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 }

    if x-SET_val_TYPE = 1  then assign temp-doc.sum4 = temp-doc.sum4 + buf_fin-ob.sum-rubl .
    else                        assign temp-doc.sum4 = temp-doc.sum4 + buf_fin-ob.sum-base .
  end.
  for each buf_fin-doc no-lock
    where buf_fin-doc.host-code     = buf_contract.host-code
      and buf_fin-doc.contract-code = buf_contract.contract-code
      and buf_fin-doc.status_       = {&fin-fact}
    :
    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 }
    if buf_contract.doc-type = {&income} then do:
        if buf_fin-doc.fin-doc-type = {&income-cashless} or buf_fin-doc.fin-doc-type = {&income-cash} or buf_fin-doc.fin-doc-type = {&income-payoff}  then do:
          if x-SET_val_TYPE = 1  then assign temp-doc.sum4 = temp-doc.sum4 + buf_fin-doc.sum-rubl .
          else                        assign temp-doc.sum4 = temp-doc.sum4 + buf_fin-doc.sum-base .
        end.
        else do:
          if x-SET_val_TYPE = 1  then assign temp-doc.sum4 = temp-doc.sum4 - buf_fin-doc.sum-rubl .
          else                        assign temp-doc.sum4 = temp-doc.sum4 - buf_fin-doc.sum-base .
        end.
    end.
    else do:  /* Для покупателей платежы влияют на баланс с обратным знаком */
        if buf_fin-doc.fin-doc-type = {&income-cashless} or buf_fin-doc.fin-doc-type = {&income-cash} or buf_fin-doc.fin-doc-type = {&income-payoff}  then do:
          if x-SET_val_TYPE = 1  then assign temp-doc.sum4 = temp-doc.sum4 - buf_fin-doc.sum-rubl .
          else                        assign temp-doc.sum4 = temp-doc.sum4 - buf_fin-doc.sum-base .
        end.
        else do:
          if x-SET_val_TYPE = 1  then assign temp-doc.sum4 = temp-doc.sum4 + buf_fin-doc.sum-rubl .
          else                        assign temp-doc.sum4 = temp-doc.sum4 + buf_fin-doc.sum-base .
        end.
    end.
  end.

/* $Workfile$ e n d */