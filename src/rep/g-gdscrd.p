block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-gdscrd.p $
$Archive: rep/g-gdscrd.p $

вызов карточки товара

Автор: Чернова Светлана Александровна
Дата создания: 09/12/05
Author: Svetlana Chernova
Creation date: 09/12/05

Creation date: 12/05/01 2:09

*/
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: g-gdscrd.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/g-gdscrd.p $":U .
def var vss-description as character no-undo init " вызов карточки товара   ".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }
{ gbl/getcntxt.i def }

define  input parameter parParentProc  as widget-handle no-undo.
define  input parameter  xartic      like   ub.goods.artic    no-undo .
define  input parameter  xprod-type  like   ub.goods.prod-type no-undo .
define  input parameter  xprod-code  like   ub.goods.prod-code no-undo  .
define  input parameter  xstart-date as date no-undo .
define  input parameter  xend-date   as date no-undo .
define  input parameter  xobj-type   like ub.clients.obj-type no-undo .
define  input parameter  xobj-code   like ub.clients.obj-code no-undo .


define  new shared var   v-x-artic      like   ub.goods.artic    no-undo  .
define  new shared var   v-x-prod-type  like   ub.goods.prod-type no-undo .
define  new shared var   v-x-prod-code  like   ub.goods.prod-code no-undo .
define  new shared var   v-x-start-date as date no-undo .
define  new shared var   v-x-end-date   as date no-undo .
define  new shared var   v-x-obj-type   like ub.clients.obj-type no-undo .
define  new shared var   v-x-obj-code   like ub.clients.obj-code no-undo .

{ gbl/getcntxt.i get  }

Assign
   v-x-artic     = xartic
   v-x-prod-type = xprod-type
   v-x-prod-code = xprod-code
   v-x-start-date = xstart-date
   v-x-end-date   = xend-date
   v-x-obj-type   = xobj-type
   v-x-obj-code   = xobj-code
   .

run rep/d-report.w (
    input parParentProc ,
    input "rep/e-gdscrd.w"      ,
    input  "Карточка товара" + " на объекте " + v-x-obj-type  + " " + string(v-x-obj-code) ,
    input  2  ,
    input  "" ,
    input  "{&o-currency}",
    input  "{&p-cost},{&p-crsa}" ,
    input  "{&v-rubl},{&v-base}",
    input  "all,{&format-folder},X-DATE-START=" + string(v-x-start-date,"99/99/9999" ) + ",X-DATE-END=" + string(v-x-end-date , "99/99/9999") ,
    input  no).