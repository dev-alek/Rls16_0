block-level on error undo, throw.
/*

$Revision: 8f5f559ebdb3, 2359, rls $
$Author: ARostovtsev $
$Date: Ср мар  21:13:34 2020 +0300 $
$Workfile: r-rsrv-plan.p $
$Archive: rep/r-rsrv-plan.p $

Создание заказа по планированию

Автор: Ростовцев Александр Михайлович
Дата создания: 05/03/25
Author: Rostovtsev Aleksandr
Creation date: 03/05/25

*/

{ rep/tt-date.i }

define input parameter parparentproc as handle    no-undo .
define input parameter iDateOrder    as date      no-undo.
define input parameter iClientType   like ub.clients.obj-type no-undo.
define input parameter iClientCode   like ub.clients.obj-code no-undo.
define input parameter iParams       as character             no-undo.

define variable vss-revision    as character no-undo init "$Revision: 8f5f559ebdb3, 2359, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:34 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-rsrv-plan.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-rsrv-plan.p $":U .
define variable vss-description as character no-undo init "Отчет по планированию заказов".

{ cmp/vssrevis.i }
{ cmp/trg-def.i  } 
{ cmp/str-glbl.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/order.i }
{ rep/tt-zakaz.i }

define variable vDocCode as integer no-undo.
define variable vLine    as integer no-undo.
 
define buffer buf_order-doc       for ub.order-doc .
define buffer buf_order-line      for ub.order-line .
define buffer buf_clients         for ub.clients .
define buffer buf_goods           for ub.goods .
define buffer buf_contract-specif for ub.contract-specif .

define variable orderStatus  as class ibs.th.str.order.sts.order no-undo .
orderStatus =  new ibs.th.str.order.sts.order().

if not can-find (first tt-zakaz) then
  return.

MAIN:
do transaction on error undo MAIN, leave MAIN:
    
    find first buf_clients no-lock where
               buf_clients.obj-type = iClientType
           and buf_clients.obj-code = iClientCode.

    for each tt-zakaz no-lock /*where
             tt-zakaz.order-qnty > 0*/
             break by tt-zakaz.contract-code by tt-zakaz.gds-code:

      if first-of(tt-zakaz.contract-code) then
      do:
        subscribe "getNextseq" anywhere run-procedure "MySeqForOrder".
        create buf_order-doc.
        assign 
          vDocCode                        = next-value (s-order-code, {&db-name_schema})
          buf_order-doc.obj-type          = v-cntxt-obj-type
          buf_order-doc.obj-code          = v-cntxt-obj-code
          buf_order-doc.doc-code          = vDocCode
          buf_order-doc.doc-date          = now
          buf_order-doc.order-date        = today + 1
          buf_order-doc.cli-type          = iClientType 
          buf_order-doc.cli-code          = iClientCode 
          buf_order-doc.cli-name          = if avail buf_clients then buf_clients.obj-name else "" 
          buf_order-doc.contract-code     = tt-zakaz.contract-code
          buf_order-doc.contract-prn-code = tt-zakaz.contract-prn-code
          buf_order-doc.user-id           = v-cntxt-userid
          buf_order-doc.sts               = orderStatus:NewStatus:KeyIntDB
          buf_order-doc.params            = iParams
        .
        validate buf_order-doc.
      end.
      else do:
        find first buf_order-doc exclusive-lock where
                   buf_order-doc.db-num   = g#db-num
               and buf_order-doc.doc-code = vDocCode no-error. 
        if not avail  buf_order-doc then
        do:
          message "Ошибка при создании заказа. Заказы созданы не будут." view-as alert-box.
          undo MAIN, leave MAIN.  
        end.
      end.
      
      find first buf_goods no-lock where
                 buf_goods.gds-code = tt-zakaz.gds-code.
       
                 
      create buf_order-line.
      assign
         vLine = vLine + 1
         buf_order-line.doc-code      = buf_order-doc.doc-code
         buf_order-line.db-num        = buf_order-doc.db-num
         buf_order-line.line-num      = vLine
         buf_order-line.gds-code      = tt-zakaz.gds-code
         buf_order-line.artic         = tt-zakaz.artic  
         buf_order-line.prod-type     = if avail buf_goods then buf_goods.prod-type else ""
         buf_order-line.prod-code     = if avail buf_goods then buf_goods.prod-code else 0
         buf_order-line.order-qnty    = tt-zakaz.order-qnty
         buf_order-line.fact-qnty     = tt-zakaz.order-qnty
         buf_order-line.rest          = tt-zakaz.rest
         buf_order-line.sales         = tt-zakaz.sales
         buf_order-line.average-sales = tt-zakaz.average-sales
         buf_order-line.stock-goods   = if tt-zakaz.average-sales = 0 and tt-zakaz.ostatokDay <> 0 then -1 else integer(tt-zakaz.ostatokGoods)
         buf_order-line.volume-goods  = tt-zakaz.volume-goods
         buf_order-line.volume-stock  = if tt-zakaz.minZapas > tt-zakaz.rest then tt-zakaz.minZapas else tt-zakaz.volMinZapas
         buf_order-line.min-stock     = tt-zakaz.min-stock
         buf_order-line.garant-stock  = tt-zakaz.garant-stock
         buf_order-line.promo         = tt-zakaz.promo
/*         buf_order-line.unit          = buf_goods.unit-base*/
      .
/*      for first buf_contract-specif no-lock where                                                                                */
/*                buf_contract-specif.contract-num = tt-zakaz.contract-code                                                        */
/*            and buf_contract-specif.gds-code      = tt-zakaz.gds-code                                                            */
/*          :                                                                                                                      */
/*        assign                                                                                                                   */
/*          buf_order-line.price        = buf_contract-specif.price-cli                                                            */
/*          buf_order-line.unit         = buf_contract-specif.unit-base                                                            */
/*          buf_order-line.amount = buf_order-line.price * (if buf_order-line.order-qnty > 0 then buf_order-line.order-qnty else 0)*/
/*          buf_order-doc.amount  = buf_order-doc.amount + buf_order-line.amount                                                   */
/*        .                                                                                                                        */
/*      end.                                                                                                                       */
      validate buf_order-line.
      validate buf_order-doc.
      if last-of(tt-zakaz.contract-code) then
      do:
        unsubscribe "getNextseq".
      end.
    end.
end.