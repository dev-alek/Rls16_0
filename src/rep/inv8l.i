/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

заполнение тела для inv8

Автор: Белоусов Илья Александрович
Дата создания:
Author: Ilia Belousov
Creation date:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

assign
   counter1 = 0
.
for each buf_doc-line where buf_doc-line.doc-code = trn-doc.doc-code
                      no-lock
                      :
  find first buf_goods where buf_goods.prod-type = buf_doc-line.prod-type
                         and buf_goods.prod-code = buf_doc-line.prod-code
                         and buf_goods.artic     = buf_doc-line.artic
                       no-lock
                       no-error
                       .

  find first buf_doc-line-sum no-lock where
             buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
             buf_doc-line-sum.gds-code = buf_goods.gds-code    and
             buf_doc-line-sum.sum-type = {&sum-before-doc}     no-error.
  { gbl/gdsbcode.i buf_goods.gds-code ? v-b-code no-error }

  if error-status :error then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Ошибка при определении бар-кода товара"     skip
            "Артикул товара:" buf_goods.artic            skip
            "Производитель:"  buf_goods.prod-type buf_goods.prod-code skip
            error-status :get-message( 1 ) skip
            error-status :get-message( 2 ) skip
            return-value                   skip( 1 )
    view-as alert-box error.
  end.

  find first buf_prod-bc where buf_prod-bc.b-code = v-b-code
                     no-lock
                     no-error
                     .

  assign
     Counter1 = Counter1 + 1
  .
  { rep/repfrm.i disp Counter1 }
  if v-prn0 = "no" then do:
    if  buf_doc-line-sum.fact-qnty = 0
    and buf_doc-line.fact-qnty     = 0
    then do:
         NEXT.
    end.
  end.

  create temp-str.
  assign temp-str.b-code          = if not available buf_prod-bc then string( v-b-code )
                                                                 else buf_prod-bc.b-str
         temp-str.artic           = buf_goods.artic
         temp-str.prod-type       = buf_goods.prod-type
         temp-str.prod-code       = buf_goods.prod-code
         temp-str.gds-name        = trim( buf_goods.gds-name )
         temp-str.EI              = buf_goods.sort
         temp-str.qntyBuh         = buf_doc-line-sum.fact-qnty
         temp-str.qntyFact        = temp-str.qntyBuh  + buf_doc-line.fact-qnty
         temp-str.WeightItemLigat = buf_goods.wt-base
  .
  assign
     temp-str.WeightItemClear = decimal(buf_goods.Destin)
  no-error.
  if error-status :error then do:
     assign
        temp-str.WeightItemClear = 0.0
     .
  end.


end. /* FOR EACH doc-line */

/* $Workfile$   E n d */