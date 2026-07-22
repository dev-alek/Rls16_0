/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура редактирования doc-pl в документах

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/

procedure update-doc-pl :
  define input parameter par-rec-doc-line as recid no-undo.

  find first doc-line where recid( doc-line ) = par-rec-doc-line.
  find first goods no-lock where
             goods.artic     = doc-line.artic     and
             goods.prod-type = doc-line.prod-type and
             goods.prod-code = doc-line.prod-code .
  /* Пока приходная накладная может быть лишь с одним местом хранения */
  find first doc-pl where
             doc-pl.obj-type = t-doc.obj-type and
             doc-pl.obj-code = t-doc.obj-code and
             doc-pl.out-code = t-doc.doc-code and
             doc-pl.gds-code = goods.gds-code no-error .
  if available doc-pl then do:
     assign doc-pl.doc-qnty      = doc-line.doc-qnty
            doc-pl.fact-qnty     = doc-line.fact-qnty
            doc-pl.cli-doc-qnty  = doc-line.doc-qnty  / doc-line.cli-base-rate
            doc-pl.cli-fact-qnty = doc-line.fact-qnty / doc-line.cli-base-rate.
  end.
end procedure. /* update-doc-pl */

/* $Workfile$   E n d */