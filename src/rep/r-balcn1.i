/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Баланс фин.обязательств и выплат по контрагенту за период

Автор: Демин Алексей Сергеевич
Дата создания: 03/22/06
Author: Alexey Demin
Creation date: 03/22/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  create temp-contr .
  assign
    temp-contr.sum        = 0
    temp-contr.contr      = buf_contract.contract-code
    temp-contr.contr-name = buf_contract.contract-prn-code
  .

  for each buf_fin-ob no-lock
    where buf_fin-ob.host-code     = buf_contract.host-code
      and buf_fin-ob.contract-code = buf_contract.contract-code
      and buf_fin-ob.status_       = {&fact}
/*      and buf_fin-ob.fact-order    >= v-fact-order-start*/
      and buf_fin-ob.fact-order    <  v-fact-order-end
    :
    if buf_fin-ob.fact-order >= v-fact-order-start then do:
      nn = 1 .
      for each buf_fin-ob-trn exclusive-lock where buf_fin-ob-trn.doc-code = buf_fin-ob.doc-code :
        if nn = 1 then v-nakl = buf_fin-ob-trn.trn-doc-code .
        else do:
        v-nakl = v-nakl + "," + buf_fin-ob-trn.trn-doc-code .
        end.
        nn = nn + 1 .
      end.  
      create temp-doc .
      assign
        temp-doc.f-o       = buf_fin-ob.fact-order
        temp-doc.dat       = buf_fin-ob.fact-date
        temp-doc.num       = buf_fin-ob.prn-doc-code
        temp-doc.nakl      = v-nakl
        temp-doc.contr     = buf_contract.contract-code
        temp-doc.contr-type = buf_contract.doc-type
        temp-doc.cli-type  = buf_clients.obj-type
        temp-doc.cli-code  = buf_clients.obj-code
        temp-doc.typ       = 0
        temp-doc.styp      = "ФО"
      .
      if x-SET_val_TYPE = 1  then assign temp-doc.sum = buf_fin-ob.sum-rubl .
      else                        assign temp-doc.sum = buf_fin-ob.sum-base .
    end.
    else do:
      if x-SET_val_TYPE = 1  then assign temp-contr.sum = temp-contr.sum + buf_fin-ob.sum-rubl .
      else                        assign temp-contr.sum = temp-contr.sum + buf_fin-ob.sum-base .
    end.
  end.
  for each buf_fin-doc no-lock
    where buf_fin-doc.host-code     = buf_contract.host-code
      and buf_fin-doc.contract-code = buf_contract.contract-code
      and buf_fin-doc.status_       = {&fin-fact}
/*      and buf_fin-doc.fact-order    >= v-fact-order-start*/
      and buf_fin-doc.fact-order    <  v-fact-order-end
    :
    if buf_fin-doc.fact-order >= v-fact-order-start then do:

v-nakl = "".      
FOR EACH buf_fin-connect NO-LOCK where buf_fin-connect.fin-doc-code = buf_fin-doc.fin-doc-code, 
first buf_fin-ob NO-LOCK where buf_fin-ob.host-code = buf_fin-connect.host-code and buf_fin-ob.doc-code = buf_fin-connect.fin-ob-code:
      for each buf_fin-ob-trn no-lock where buf_fin-ob-trn.doc-code = buf_fin-ob.doc-code :
        nn = 1 .
        if nn = 1 then v-nakl = buf_fin-ob-trn.trn-doc-code .
        else do:
        v-nakl = v-nakl + "," + buf_fin-ob-trn.trn-doc-code .
        nn = nn + 1 .
        end.
      end.  
end.
      create temp-doc .
      assign
        temp-doc.f-o        = buf_fin-doc.fact-order
        temp-doc.dat        = buf_fin-doc.fact-date
        temp-doc.num        = buf_fin-doc.prn-doc-code
        temp-doc.nakl       = v-nakl 
        temp-doc.contr      = buf_contract.contract-code
        temp-doc.contr-type = buf_contract.doc-type
        temp-doc.cli-type   = buf_clients.obj-type
        temp-doc.cli-code   = buf_clients.obj-code
        temp-doc.typ        = 1
        temp-doc.styp       = buf_fin-doc.fin-doc-type
      .

          if x-SET_val_TYPE = 1  then assign temp-doc.sum = buf_fin-doc.sum-rubl .
          else                        assign temp-doc.sum = buf_fin-doc.sum-base .
      end.
      else do:
      if buf_contract.doc-type = {&income} then do:  
          if buf_fin-doc.fin-doc-type = {&income-cashless} or buf_fin-doc.fin-doc-type = {&income-cash} or buf_fin-doc.fin-doc-type = {&income-payoff}  then do:
            if x-SET_val_TYPE = 1  then assign temp-contr.sum = temp-contr.sum + buf_fin-doc.sum-rubl .
            else                        assign temp-contr.sum = temp-contr.sum + buf_fin-doc.sum-base .
          end.
          else do:
            if x-SET_val_TYPE = 1  then assign temp-contr.sum = temp-contr.sum - buf_fin-doc.sum-rubl .
            else                        assign temp-contr.sum = temp-contr.sum - buf_fin-doc.sum-base .
          end.
      end.
      else do:
          if buf_fin-doc.fin-doc-type = {&income-cashless} or buf_fin-doc.fin-doc-type = {&income-cash} or buf_fin-doc.fin-doc-type = {&income-payoff}  then do:
            if x-SET_val_TYPE = 1  then assign temp-contr.sum = temp-contr.sum - buf_fin-doc.sum-rubl .
            else                        assign temp-contr.sum = temp-contr.sum - buf_fin-doc.sum-base .
          end.
          else do:
            if x-SET_val_TYPE = 1  then assign temp-contr.sum = temp-contr.sum + buf_fin-doc.sum-rubl .
            else                        assign temp-contr.sum = temp-contr.sum + buf_fin-doc.sum-base .
          end.
      end.
    end.
  end.
  assign temp-cli.sum = temp-cli.sum  + temp-contr.sum .
/* $Workfile$ e n d */