block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cr-ordop.p $
$Archive: cus/cr-ordop.p $

Cоздание заказа

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 06/27/05
*/

define input  parameter  parParentProc   AS WIDGET-HANDLE NO-UNDO.
define input  parameter  par-ord-type    as character no-undo .
define input  parameter  par-cli-code    as integer   no-undo .
define input  parameter  par-cli-type    as character no-undo .
define input  parameter  par-date-post   as date   no-undo .
define input  parameter  par-date-1      as date   no-undo .
define input  parameter  par-date-2      as date   no-undo .
define input  parameter  p-recid         as character no-undo .
define output parameter  par-ord-doc-recid  as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cr-ordop.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/cr-ordop.p $":U .
define variable vss-description as character no-undo init "создание заказа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ cus/ord-lib.i  create-ord-line }
{ cus/ord-lib.i  last-price      }
{ cus/z-qnty.i   def }
{ cus/ord-code.i def }
{ gbl/getcntxt.i def }

define buffer buf_clients              for ub.clients.
define buffer buf_currency             for ub.currency.
define buffer buf_curr-accnt           for ub.curr-accnt .
define buffer buf_abc-analysis-obj     for ub.abc-analysis-obj.
define buffer buf_abc-analysis-goods   for ub.abc-analysis-goods.
define buffer buf_analysis-gds-obj     for ub.abc-analysis-gds-obj.
define buffer buf_abc-analysis-gds-obj for ub.abc-analysis-gds-obj.
define buffer buf_analysis-goods       for ub.abc-analysis-goods.
define buffer buf_goods                for ub.goods.

define variable var-ok-assort-pol   as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable par-ord-doc-code    as character no-undo .

define variable v-host-code as integer    no-undo .
define variable v-obj-code  as integer    no-undo .
define variable v-obj-type  as character  no-undo .
define variable store-code  as integer    no-undo .
define variable store-type  as character  no-undo .
define variable ship-day    as integer    no-undo .
define variable pay-day     as integer    no-undo .
define variable all-day     as integer    no-undo .
define variable v-e-method as character no-undo .

define buffer tmp#zakaz  for ub.goods.  /* ВНИМАНИЕ !!! */
{ gbl/getcntxt.i get }
assign
  v-host-code = v-cntxt-host-code-obj
  v-obj-type  = v-cntxt-obj-type
  v-obj-code  = v-cntxt-obj-code
  store-code  = v-obj-code
  store-type  = v-obj-type
  v-e-method = "Методы расчета темпа продаж : Базовый способ;"
  .


find first buf_clients no-lock where
           buf_clients.obj-code = par-cli-code and
           buf_clients.obj-type = par-cli-type
           no-error .

if not available buf_clients then return error .

define variable v-kol-rec as integer no-undo .
define variable v-i       as integer no-undo .
define variable v-qnty    as decimal no-undo .

v-kol-rec = num-entries (p-recid) .

   find first buf_abc-analysis-goods no-lock where
              recid(buf_abc-analysis-goods) = int(entry(1 , p-recid))
              no-error .
    if not available buf_abc-analysis-goods then return error .

define variable v-abc-id     as integer   no-undo .
define variable v-abc-db-num as integer   no-undo .
define variable v-doc-db-num as integer   no-undo .

v-abc-id      = buf_abc-analysis-goods.abc-id.
v-abc-db-num  = buf_abc-analysis-goods.db-num.

if par-ord-type = {&O-P} then do:
    for each buf_abc-analysis-obj no-lock where
             buf_abc-analysis-obj.abc-id =      v-abc-id     and
             buf_abc-analysis-obj.db-num =  v-abc-db-num :
             { gbl/hostcode.i  buf_abc-analysis-obj.obj-type buf_abc-analysis-obj.obj-code v-host-code }

      { gbl/objdbnum.i
        buf_abc-analysis-obj.obj-type
        buf_abc-analysis-obj.obj-code
        v-doc-db-num
        }
      if v-doc-db-num = v-cntxt-db-num then do:
        run create-ord (
            v-host-code ,
            buf_abc-analysis-obj.obj-code ,
            buf_abc-analysis-obj.obj-type ).
      end.
    end.
end.

if par-ord-type = {&F-P} then do:
   run create-ord (
        v-host-code ,
        store-code  ,
        store-type  ) .
end.
par-ord-doc-recid = trim (par-ord-doc-recid , "," ) .

procedure create-ord :

  do
  on error undo, return error return-value
  :
define input  parameter p-host-code as integer   no-undo .
define input  parameter p-obj-code  as integer   no-undo .
define input  parameter p-obj-type  as character no-undo .


define variable to-day       as date      no-undo .
define variable v-base-code  as integer   no-undo .

{ gbl/curobjdt.i p-obj-type p-obj-code to-day }
ship-day = par-date-post - to-day .
pay-day  = par-date-2 - par-date-1  + 1 .

define variable v-i-doc as character no-undo .

{ cus/ord-code.i
  'main'
  v-cntxt-db-num
  v-cntxt-obj-type
  v-cntxt-obj-code
  v-i-doc
  par-ord-doc-code
}

{ gbl/basecode.i p-host-code v-base-code }

/* создание шапки */
   create ub.ord-doc.
   assign
      ub.ord-doc.doc-code    = par-ord-doc-code
      ub.ord-doc.cli-code    = buf_clients.obj-code
      ub.ord-doc.cli-type    = buf_clients.obj-type
      ub.ord-doc.cli-name    = buf_clients.obj-name
      ub.ord-doc.cons-code   = ""
      ub.ord-doc.host-code   = p-host-code
      ub.ord-doc.obj-code    = p-obj-code
      ub.ord-doc.obj-type    = p-obj-type
      ub.ord-doc.doc-type    = par-ord-type
      ub.ord-doc.status_     = {&g___new}
      ub.ord-doc.start-date  = ?
      ub.ord-doc.end-date    = ?
      ub.ord-doc.doc-date    = to-day
      ub.ord-doc.ship-date   = par-date-post
      ub.ord-doc.date-sale-1 = par-date-1
      ub.ord-doc.date-sale-2 = par-date-2
      ub.ord-doc.ship-time   = 0
      ub.ord-doc.vat-type    = {&inc-vat}
      ub.ord-doc.slt-type    = {&without-slt}
      ub.ord-doc.pay-code    = 1
      ub.ord-doc.tot-lines   = v-kol-rec
      .

      /* Валюта поставщика */
      ub.ord-doc.exch-code = 0 .
      find buf_currency no-lock  where buf_currency.curr-code = ub.ord-doc.exch-code no-error.
        if available buf_currency then do:
            find last buf_curr-accnt no-lock   where buf_curr-accnt.curr-code = buf_currency.curr-code  use-index pi no-error.
              if available buf_curr-accnt then
                assign
                    ub.ord-doc.exch-rate = buf_curr-accnt.exch-rate
                    ub.ord-doc.exch-scale = buf_curr-accnt.exch-scale
                    .
       end.

      /* Базовая валюта */
      find last buf_curr-accnt no-lock  where buf_curr-accnt.curr-code = v-base-code  use-index pi no-error .
        if available buf_curr-accnt then
            assign
              ub.ord-doc.base-rate  = buf_curr-accnt.exch-rate
              ub.ord-doc.base-scale = buf_curr-accnt.exch-scale
              .

   par-ord-doc-recid = par-ord-doc-recid + "," + string(recid(ub.ord-doc)) .


/* создание строк */
repeat v-i = 1 to v-kol-rec :
   find first buf_abc-analysis-goods no-lock where
              recid(buf_abc-analysis-goods) = int(entry(v-i , p-recid))
              no-error .

     if available buf_abc-analysis-goods then do:
     find first buf_goods no-lock where buf_goods.gds-code = buf_abc-analysis-goods.gds-code no-error .
        if not available buf_goods then next.
        var-ok-assort-pol = true .
        if par-ord-type <> {&f-p} then do:
            { gbl/goassizt.i
              par-ord-type
              buf_goods.gds-code
              p-obj-type
              p-obj-code
              true
              var-ok-assort-pol
              var-mess-assort-pol
            }
        end.
        if var-ok-assort-pol = false then
        do:
           next .
        end.

        find first tmp#zakaz no-lock where recid(tmp#zakaz) = recid(buf_goods) no-error .
        run calc-zakz ( output v-qnty) .
        run create-ord-line
        ( input  par-ord-doc-code
         ,input  v-i
         ,input  buf_goods.artic
         ,input  buf_goods.prod-code
         ,input  buf_goods.prod-type
         ,input  buf_goods.cli-base-rate
         ,input  v-qnty
         ,input  buf_goods.unit-cli ) no-error .
         if error-status :error then next.
     end.
end.

/* создание признаков */
/**/

  end.
end procedure. /* create-ord */

procedure calc-zakz :
  do
  on error undo, return error return-value
  :
define output parameter par-ord-qnty as decimal   no-undo .
define variable v-temp      as decimal   no-undo .
define variable v-min-stock as decimal   no-undo .
define variable v-min-order as decimal   no-undo .
define variable v-qnty-stk  as decimal   no-undo .
define variable v-corr-coeff as decimal  no-undo init 1.

define variable       v-neg-sale     as logical   no-undo .
define variable       v-gds-way-all  as decimal   no-undo .
define variable       v-min-zapas    as logical   no-undo .
define variable       v-min-ost      as logical   no-undo .
define variable       v-deadline     as logical   no-undo .  /* ? */

define variable p-return-AssMin         as logical   no-undo .
define variable p-return-igt            as character no-undo .
define variable p-grop-max-stock        as decimal   no-undo .
define variable p-grop-level-always-presence     as decimal   no-undo .
define variable to-day        as date      no-undo .
define variable vs-min-stock  as decimal   no-undo .
define variable vs-min-order  as decimal   no-undo .


pay-day  = par-date-2 - par-date-1  + 1 .
all-day = pay-day .

if par-ord-type = {&O-P} then do:
    find first buf_abc-analysis-gds-obj no-lock where
               buf_abc-analysis-gds-obj.abc-id   =  buf_abc-analysis-obj.abc-id and
               buf_abc-analysis-gds-obj.db-num   =  buf_abc-analysis-obj.db-num and
               buf_abc-analysis-gds-obj.obj-code =  buf_abc-analysis-obj.obj-code and
               buf_abc-analysis-gds-obj.obj-type =  buf_abc-analysis-obj.obj-type and
               buf_abc-analysis-gds-obj.gds-code =  buf_goods.gds-code
               no-error .
  if available buf_abc-analysis-gds-obj then do:
{ gbl/gdsobjpr.i
    buf_abc-analysis-gds-obj.obj-type
    buf_abc-analysis-gds-obj.obj-code
    ?
    ?
    ?
    buf_abc-analysis-gds-obj.gds-code
    p-return-AssMin
    p-return-igt
    v-min-stock
    p-grop-max-stock
    p-grop-level-always-presence
    v-min-order }

    { gbl/curobjdt.i buf_abc-analysis-gds-obj.obj-type buf_abc-analysis-gds-obj.obj-code to-day }
    ship-day = par-date-post - to-day .

    v-temp     = buf_abc-analysis-gds-obj.abog-temp-sale-goods.
    v-qnty-stk = buf_abc-analysis-gds-obj.abog-stock-qnty .
    { cus/z-qnty.i
      calc
      v-qnty-stk
      buf_goods.negative-rest
      ship-day
      pay-day
      v-temp
      v-min-stock
      par-ord-qnty
      v-neg-sale
      v-gds-way-all
      v-min-zapas
      v-min-order
      buf_goods.unit-base
      v-min-ost
      v-deadline
      buf_goods.deadline
      v-e-method
      v-media-qnty
      v-corr-coeff
    }
   end.
end.

if par-ord-type = {&F-P} then do:

v-temp     = 0 .
v-qnty-stk = 0 .
vs-min-stock = 0 .
vs-min-order = 0 .

    for each   buf_abc-analysis-obj no-lock where
               buf_abc-analysis-obj.abc-id =  v-abc-id and
               buf_abc-analysis-obj.db-num =  v-abc-db-num

               :

{ gbl/gdsobjpr.i
    buf_abc-analysis-obj.obj-type
    buf_abc-analysis-obj.obj-code
    ?
    ?
    ?
    buf_goods.gds-code
    p-return-AssMin
    p-return-igt
    v-min-stock
    p-grop-max-stock
    p-grop-level-always-presence
    v-min-order }

    vs-min-stock  = vs-min-stock + v-min-stock .
    vs-min-order  = vs-min-order + v-min-order.
    v-temp     = v-temp     +  buf_abc-analysis-goods.abcg-temp-sale-goods.
    v-qnty-stk = v-qnty-stk +  buf_abc-analysis-goods.abcg-stock-qnty .
end.
    { cus/z-qnty.i
      calc
      v-qnty-stk
      buf_goods.negative-rest
      ship-day
      pay-day
      v-temp
      vs-min-stock
      par-ord-qnty
      v-neg-sale
      v-gds-way-all
      v-min-zapas
      vs-min-order
      buf_goods.unit-base
      v-min-ost
      v-deadline
      buf_goods.deadline
      v-e-method
      v-media-qnty
      v-corr-coeff
    }

end.





  end.

end procedure. /* calc-zakz */