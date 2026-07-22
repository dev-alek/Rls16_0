/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры проверяющие 1:1:1 в Заказе ОП-поставка-накладна

Автор: Чернова Светлана Александровна
Дата создания: 05/26/10
Author: Svetlana Chernova
Creation date: 05/26/10

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ gbl/getsect.i def }

procedure ver-qnty-rcv-from-ord :
define input  parameter p-ord-doc as character no-undo .
define output parameter p-is-lim as logical    no-undo .

define buffer buf_ord-doc     for ub.ord-doc      .
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .

define variable v-kol as integer   no-undo .
define variable v-ver as logical   no-undo .

  do
  on error undo, return error return-value
  :
   p-is-lim = false .

  find first buf_ord-doc no-lock where buf_ord-doc.doc-code = p-ord-doc no-error .
  if buf_ord-doc.doc-type <> {&O-P} then return .

  { gbl/getsect.i run buf_ord-doc.obj-type buf_ord-doc.obj-code {&attr-ord-obj} }

  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = {&attr-ord-obj_ord-11} then v-ver = thbjattr_thbj-attr.property-value-logical .
  end.



v-kol = 0.

  if v-ver then do:
     for each buf_ord-doc-rcv no-lock where
              buf_ord-doc-rcv.doc-code = p-ord-doc :
       v-kol = v-kol + 1.
       leave.
     end.
   if v-kol > 0 then p-is-lim = true .
  end.
end.

end procedure. /* ver-qnty-rcv-from-ord */

procedure ver-qnty-trn-from-rcv :
define input  parameter p-rcv-code as character no-undo .
define output parameter p-is-lim as logical   no-undo .
define buffer buf_ord-doc for ub.ord-doc  .
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
define buffer buf_ord-chain for ub.ord-chain .
define buffer buf_trn-doc for ub.trn-doc  .

define variable v-kol as integer   no-undo .
define variable v-ver as logical   no-undo .

  do
  on error undo, return error return-value
  :

   p-is-lim = false .

  find first buf_ord-doc-rcv no-lock where buf_ord-doc-rcv.rcv-code = p-rcv-code no-error .
  find first buf_ord-doc no-lock where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code no-error .
  if buf_ord-doc.doc-type <> {&O-P} then return .

  { gbl/getsect.i run buf_ord-doc.obj-type buf_ord-doc.obj-code {&attr-ord-obj} }

  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = {&attr-ord-obj_ord-11} then v-ver = thbjattr_thbj-attr.property-value-logical .
  end.

    if v-ver then do:
    v-kol = 0.
        for each buf_ord-chain no-lock where
                buf_ord-chain.doc-code = p-rcv-code and
                buf_ord-chain.doc-type = 'rcv' and
                buf_ord-chain.rel-doc-type = 'trn' ,
            first buf_trn-doc NO-LOCK where
                  buf_trn-doc.doc-code = buf_ord-chain.rel-doc-code
                  :
            v-kol = v-kol + 1.
            leave.
        end.
        if v-kol > 0 then p-is-lim = true .
    end.
  end.
end procedure. /* ver-qnty-trn-from-rcv */
/* $Workfile$ e n d */