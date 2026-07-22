block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ord-buy.p $
$Archive: cus/ord-buy.p $

Вызов заказов покупателей

Автор: Чернова Светлана Александровна
Дата создания: 08/21/01
Author: Svetlana Chernova
Creation date: 08/21/01

*/

define input parameter parParentProc  as widget-handle no-undo.
define input parameter p-type         as character no-undo .
define input parameter p-status       as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-buy.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-buy.p $":U .
define variable vss-description as character no-undo init "Вызов заказов покупателей".

{ cmp/vssrevis.i }
{ cmp/showinf.i }
{ cmp/trg-def.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define variable par-mode      as character no-undo .
define variable pardoc-rec    as recid     no-undo .
define variable p-char        as character no-undo .
define variable p-list        as character no-undo .
define variable b-str         as character no-undo .
b-str = "b-lkp" .
if p-status = "all":U then
   b-str = "b-add,b-chg,b-del,b-lkp,b-close" .
if p-status = {&g___new} then
   b-str = "b-add,b-chg,b-del,b-lkp,b-close" .

case p-type :
      when {&p-o} then do:
        run cus/ordbuyer.w
          ( input  parParentProc ,
            input  b-str  ,
            input  (if p-status = "all":U then {&obj}  else "status":U  )      ,
            input  pardoc-rec   ,
            input  v-cntxt-host-code-obj ,
            input  v-cntxt-obj-code  ,
            input  v-cntxt-obj-type  ,
            input  p-type      ,
            input  (if p-status = "all":U then ? else p-status  ) ,
            input  p-char      ,
            output p-list
            ).
      end.
end case.