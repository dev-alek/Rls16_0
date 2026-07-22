block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ordooopn.p $
$Archive: cus/ordooopn.p $

Смена статусов у заказов OO ОТКРЫТИЕ
Переход по графу статусов

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 06/22/04 3:32

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: ordooopn.p $":u .
define variable vss-archive     as character no-undo init "$Archive: cus/ordooopn.p $":u .
define variable vss-description as character no-undo init  "Переход по графу статусов ОТКРЫТИЕ" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/r-pril.i   }

define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-rec as recid no-undo .

define  buffer buf_ord-doc    for ub.ord-doc.
define  buffer x_doc-rcv      for ub.ord-doc-rcv .
define  buffer x_ord-doc-rcv  for ub.ord-doc-rcv.
define  buffer x_ord-doc-line-rcv for ub.ord-line-rcv.
define  buffer x_doc-line     for ub.ord-line.
define  buffer x_doc-line-rcv for ub.ord-line-rcv.
define  buffer x_trn-line     for ub.doc-line.
define  buffer x_trn-doc      for ub.trn-doc.
define variable varchip-code as integer no-undo.


do
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:

find first buf_ord-doc where recid (buf_ord-doc) = p-rec exclusive-lock no-error.

if not( ( buf_ord-doc.status_ = {&ord-req} and buf_ord-doc.flag_ = true  ) or
        ( buf_ord-doc.status_ = {&g___new} and buf_ord-doc.flag_ = true  )  ) then do:
   RELEASE buf_ord-doc.
   message "Открыть можно только заказ в статусе запр+ или новый+ " view-as alert-box information .
   undo, return .
end.

if  buf_ord-doc.status_ = {&ord-req} and buf_ord-doc.flag_ = true  then do:
  for each  X_ord-doc-rcv  exclusive-lock  where
            X_ord-doc-rcv.doc-code = buf_ord-doc.doc-code
      on error undo, return error :
   for each ub.ord-chain no-lock where
            ub.ord-chain.doc-code = x_ord-doc-rcv.rcv-code and
            ub.ord-chain.doc-type = 'rcv'                  and
            ub.ord-chain.rel-doc-type = 'trn'
            :
            find first x_trn-doc  no-lock  where
                       x_trn-doc.doc-code = ub.ord-chain.rel-doc-code no-error .

              if available x_trn-doc then do:
                    if not ( x_trn-doc.status_ = {&inquiry}  and
                             x_trn-doc.flag_   = false )  then do :
                      release buf_ord-doc .
                      message "Уже создана накладная в статусе " x_trn-doc.status_   + string( x_trn-doc.flag_ , "+/-")  " удалять нельзя!  "
                              "Открыть заказ нельзя!"
                              view-as alert-box error .
                              undo,return.
                    end.

              run str/del-doc.p
                  ( input  parParentProc,
                    input  x_trn-doc.doc-code,
                    input  g#db-num,
                    input  "del-doc.err",
                    input  ?,
                    input  ?,
                    input  g#userid,
                    input  x_trn-doc.doc-code,
                    input  ?,
                    output varchip-code )
                    .
           end.
    end.
  delete X_ord-doc-rcv .
  end.

 assign
  buf_ord-doc.status_ = {&ord-req}
  buf_ord-doc.flag_   = false
  .
  RELEASE buf_ord-doc .
  return.
end.


if  buf_ord-doc.status_ = {&g___new} and buf_ord-doc.flag_ = true  then do:
    if not ( ((buf_ord-doc.order-type = 2 or buf_ord-doc.order-type = 0) and g#db-num = 0 ) or
             (buf_ord-doc.order-type = 3  and g#db-num <> 0  )) then do:
      RELEASE buf_ord-doc.
      message "Открыть нельзя, так как распределение назначено в другой БД" view-as alert-box information .
      undo, return .
    end.

    assign
      buf_ord-doc.status_ = {&g___new}
      buf_ord-doc.flag_   = false
      .
      RELEASE buf_ord-doc .
      return.
 end.

end. /* do */