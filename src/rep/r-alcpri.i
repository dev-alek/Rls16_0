/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Заполнение временной таблицы отчета

Автор: Хныкин Павел Андреевич
Дата создания: 03/22/06
Author: Pavel Khnykin
Creation date: 03/22/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ rep/repfrm.i on 1 }
assign
  v-repfrm-str = "Расчет по объектам..."
.
{ rep/repfrm.i disp v-counter v-repfrm-str }

for each obj-list no-lock,
    each {1} no-lock,
    first ub.gds-obj no-lock
        where ub.gds-obj.obj-type  = obj-list.obj-type
          and ub.gds-obj.obj-code  = obj-list.obj-code
          and ub.gds-obj.artic     = {1}.artic
          and ub.gds-obj.prod-type = {1}.prod-type
          and ub.gds-obj.prod-code = {1}.prod-code
          by obj-list.obj-code
          by obj-list.obj-type
:
  if v-obj-code <> obj-list.obj-code or v-obj-type <> obj-list.obj-type then do:
    assign
      v-obj-code    = obj-list.obj-code
      v-obj-type    = obj-list.obj-type
      v-counter     = 0
      v-repfrm-str  = "Расчет по объекту " + obj-list.obj-name + " (" + string( obj-list.obj-code ) + ")"
    .
    { rep/repfrm.i disp v-counter v-repfrm-str}
  end.
/*
  INDEX-FIELD "obj-type" ASCENDING
  INDEX-FIELD "obj-code" ASCENDING
  INDEX-FIELD "status_" ASCENDING
  INDEX-FIELD "fact-date" ASCENDING
  INDEX-FIELD "fact-num" ASCENDING
 */
  for each buf_trn-doc no-lock
        where buf_trn-doc.obj-type     = obj-list.obj-type
          and buf_trn-doc.obj-code     = obj-list.obj-code
          and buf_trn-doc.status_      = {&fact}
          and buf_trn-doc.fact-date   >= X-date-start
          and buf_trn-doc.fact-date   <= X-date-end
          and buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh},  /* вот это сильно тормозит запрос */
      each buf_doc-line no-lock
        where buf_doc-line.doc-code    = buf_trn-doc.doc-code
          and buf_doc-line.artic       = {1}.artic
          and buf_doc-line.prod-type   = {1}.prod-type
          and buf_doc-line.prod-code   = {1}.prod-code
  :
  assign
    v-counter = v-counter + 1
  .
  { rep/repfrm.i disp v-counter v-repfrm-str}
  find first {2} no-lock
    where {2}.obj-code = buf_trn-doc.cli-code
      and {2}.obj-type = buf_trn-doc.cli-type
      no-error .
  if p-RADpost = 1 or available {2} then do:
  run clcprtsl_calc-line (recid(buf_doc-line)).
  find first tt-allsum-line where tt-allsum-line.sum-type = {&sum-general} no-error.
  if error-status:error then do:
    message substitute ("Не найдена запись по типу &1 для товара &2 &3 &4 в документе &5. ", {&sum-general}, buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code, buf_doc-line.doc-code) view-as alert-box error .
  end.
  create temp-str.
  assign
    temp-str.doc-code     = buf_doc-line.doc-code
    temp-str.artic        = buf_doc-line.artic
    temp-str.prod-type    = buf_doc-line.prod-type
    temp-str.prod-code    = buf_doc-line.prod-code
    temp-str.gds-code     = {1}.gds-code
    temp-str.gds-name     = {1}.gds-name
    temp-str.fact-date    = buf_trn-doc.fact-date
    temp-str.cli-code     = buf_trn-doc.cli-code
    temp-str.cli-type     = buf_trn-doc.cli-type
    temp-str.cli-name     = buf_trn-doc.cli-name
    temp-str.fact-qnty    = buf_doc-line.fact-qnty
  .
  if available tt-allsum-line then do:
    assign
      temp-str.price        = if v-print-rubl = yes then
                                ( tt-allsum-line.sum-dsc-rubl-doc / tt-allsum-line.fact-qnty )
                              else
                                ( tt-allsum-line.sum-dsc-base-doc / tt-allsum-line.fact-qnty )
      temp-str.sum-noNDS    = if v-print-rubl = yes then
                                ( tt-allsum-line.sum-dsc-rubl-doc - tt-allsum-line.vat-rubl-doc - tt-allsum-line.slt-rubl-doc )
                              else
                                ( tt-allsum-line.sum-dsc-base-doc - tt-allsum-line.vat-base-doc - tt-allsum-line.slt-base-doc )
      temp-str.sum-withNDS  = if v-print-rubl = yes then
                                ( tt-allsum-line.sum-dsc-rubl-doc )
                              else
                                ( tt-allsum-line.sum-dsc-base-doc )
    .
  end.
  else do:
    assign
      temp-str.price        = 0
      temp-str.sum-noNDS    = 0
      temp-str.sum-withNDS  = 0
    .
  end.
  end. /* if available g#post-f */

 end. /* for each trn-doc */
end. /* for each obj-list */
{ rep/repfrm.i off}
 /* $Workfile$ e n d */