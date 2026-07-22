/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

кусок какойто от реестра нефтепродуктов

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/30/09
Author: Dmitry Ukhanov
Creation date: 01/30/09

Автор1: Суслов Алексей Юрьевич
Дата создания1: 03/27/06

Creation date: 09/04/03 3:08

*/

find first buf_clients-attr no-lock
  where buf_clients-attr.obj-type  = buf_trn-doc.cli-type
    and buf_clients-attr.obj-code   = buf_trn-doc.cli-code
    and buf_clients-attr.attr-code  = {&attr-shftrep2}
    and buf_clients-attr.attr-value = "yes":U
  no-error .
if available  buf_clients-attr then next .

  str-inv1 = "" .
  str-inv = ""  .
  find first buf_doc-attr no-lock
    where buf_doc-attr.doc-code  = buf_trn-doc.doc-code
      and buf_doc-attr.attr-code = {&trdcattr-nids}
  no-error .
  if avail buf_doc-attr then assign  str-inv1 = buf_doc-attr.attr-value .

  find first buf_doc-attr no-lock
    where buf_doc-attr.doc-code  = buf_trn-doc.doc-code
      and buf_doc-attr.attr-code = {&trdcattr-dids}
  no-error .
  if avail buf_doc-attr then assign  str-inv1 = str-inv1  +  ( if  buf_doc-attr.attr-value <> ? and buf_doc-attr.attr-value <> ""  then (  " от " + buf_doc-attr.attr-value ) else " " ).

  if trim(str-inv1) <> "" then assign str-inv = "Основ. " .

assign vardoc-qnty = vardoc-qnty + buf_doc-line.doc-qnty
       varcli-qnty = varcli-qnty + buf_doc-line.cli-qnty
       l-ps = str-inv1
       .

display stream PrnLibStream
  sym1 string(buf_trn-doc.fact-date) + ":" + string(buf_trn-doc.shift-name) @ vardate-shift
  sym2 buf_trn-doc.doc-code
  sym3 buf_doc-line.doc-qnty
  sym4 vardoc-qnty
  sym5 buf_doc-line.doc-density
  sym6 buf_doc-line.cli-qnty
  sym7 varcli-qnty
  sym8 l-PS
  sym9
  with frame doc-line-frm .
  down stream PrnLibStream 1 with frame doc-line-frm.

/* $Workfile$ e n d */