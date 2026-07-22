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

  create temp-doc .
  assign
    temp-doc.cli-type = buf_clients.obj-type
    temp-doc.cli-code = buf_clients.obj-code
    temp-doc.cli-name = buf_clients.obj-name
    temp-doc.sum1     = 0
    temp-doc.sum2     = 0
    temp-doc.sum3     = 0
    temp-doc.sum4     = 0
  .

  for each temp-obj :
    for each buf_parts no-lock
      where buf_parts.host-code = v-cntxt-host-code-obj
        and buf_parts.supp-type = buf_clients.obj-type
        and buf_parts.supp-code = buf_clients.obj-code
        and buf_parts.status_   = no
        and buf_parts.obj-type  = temp-obj.obj-type
        and buf_parts.obj-code  = temp-obj.obj-code
        and buf_parts.rsrv-free = yes
        and buf_parts.out-code  = {&free-code}
      :
      assign Counter1 = Counter1 + 1.
      { rep/repfrm.i disp Counter1 }

      case string(buf_parts.purch-code) :
        when {&repayment-code}           then do:           /* "выкуп"                  */
          if x-SET_val_TYPE = 1  then assign sum1 = sum1 + buf_parts.fact-qnty * buf_parts.price-rubl .
          else                        assign sum1 = sum1 + buf_parts.fact-qnty * buf_parts.price-base .
        end.
        when {&consignation-code}        then do:           /* "консигнация"            */
          if x-SET_val_TYPE = 1  then assign sum3 = sum3 + buf_parts.fact-qnty * buf_parts.price-rubl .
          else                        assign sum3 = sum3 + buf_parts.fact-qnty * buf_parts.price-base .
        end.
        when {&responsible-storage-code} or                 /* "ответственное хранение" */
        when {&old-consignation-code}    then do:           /* "старая консигнация"     */
          if x-SET_val_TYPE = 1  then assign sum2 = sum2 + buf_parts.fact-qnty * buf_parts.price-rubl .
          else                        assign sum2 = sum2 + buf_parts.fact-qnty * buf_parts.price-base .
        end.
      end.
    end.
  end.

/* $Workfile$ e n d */