/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение № Поставки и заказа по № Накладной

Автор: Чернова Светлана Александровна
Дата создания: 06/26/09
Author: Svetlana Chernova
Creation date: 06/26/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure rcv_ord-from-trn :
define input  parameter p-trn-doc-code as character no-undo .   /* Номер накладной */
define output  parameter p-rcv-doc-code as character no-undo .  /*  Номер поставки */
define output  parameter p-ord-doc-code as character no-undo .  /*   Номер заказа   */

  do
  on error undo, return error return-value
  :


define buffer buf_trn-doc for ub.trn-doc  .
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
define buffer buf_ord-doc for ub.ord-doc  .
define buffer buf_ord-chain for ub.ord-chain  .

find first buf_trn-doc no-lock  where
           buf_trn-doc.doc-code = p-trn-doc-code no-error .

if error-status :error then do:
   return error  substitute("Нет накладной с номером &1" , p-trn-doc-code ) .
end.

p-rcv-doc-code = ""  .
p-ord-doc-code = "" .

 for each buf_ord-chain no-lock where
          buf_ord-chain.doc-type = 'rcv'                 and
          buf_ord-chain.rel-doc-type = 'trn'             and
          buf_ord-chain.rel-doc-code = buf_trn-doc.doc-code ,
     first  buf_ord-doc-rcv no-lock where
            buf_ord-doc-rcv.rcv-code = buf_ord-chain.doc-code :
              assign
                p-rcv-doc-code = buf_ord-doc-rcv.rcv-code
                p-ord-doc-code = buf_ord-doc-rcv.doc-code
              .
              leave.
 end.
  end.

end procedure. /* rcv_ord-from-trn */

/* $Workfile$ e n d */