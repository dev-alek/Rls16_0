/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет Динамика финансового движения по счету

Автор: Демин Алексей Сергеевич
Дата создания: 09/13/05
Author: Alexey Demin
Creation date: 09/13/05

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


      for each buf_fin-doc no-lock
        where buf_fin-doc.host-code = p-curr-host-code
          and ( buf_fin-doc.receiver-code-schet = buf_fin-schet.code-schet or buf_fin-doc.payer-code-schet = buf_fin-schet.code-schet )
          and buf_fin-doc.status_ = {&fin-fact}
          and buf_fin-doc.fact-order >= v-fact-order1
          and buf_fin-doc.fact-order < v-fact-order2
          and (buf_fin-doc.fin-doc-type = {&income-cashless} or buf_fin-doc.fin-doc-type = {&expense-cashless})
      break by {1} by {2}  by {3}  :
         run prn-line in this-procedure .
      end.
/* $Workfile$ e n d */