block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ord-shoo.p $
$Archive: cus/ord-shoo.p $

Создание щепки заказа

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 06/25/04 4:26
Анализируются сделанные по нему поставки и формируется новый заказ с недостающим кол-вом
*/
define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-recid as recid no-undo .
define output parameter loc-ord-num as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-shoo.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-shoo.p $":U .
define variable vss-description as character no-undo init "Создание щепки заказа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ cus/ord-code.i def }
{ gbl/getcntxt.i get }

define buffer buf_ord-doc for ub.ord-doc.
define buffer buf_ord-line for ub.ord-line.
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
define buffer buf_ord-line-rcv for ub.ord-line-rcv.

define buffer   buf2-ord-doc-rcv  for ub.ord-doc-rcv .
define buffer   buf2-doc-line     for ub.doc-line     .

define temp-table temp-ord-line  no-undo like ub.ord-line.

find first  buf_ord-doc no-lock where recid (buf_ord-doc) = p-recid no-error .
if error-status :error then return .

define variable v-qnty as decimal no-undo .
define variable v-sum-qnty as decimal no-undo .
define variable kk as integer init 0 no-undo .
define variable k-q      as decimal init 0 no-undo .
define variable k-s-rubl as decimal init 0 no-undo .
define variable k-s-base as decimal init 0 no-undo .

define variable v-temp as character no-undo .
define buffer new_ord-doc for ub.ord-doc.
define buffer new_ord-line for ub.ord-line.


for each temp-ord-line
    on error undo, return error :
    delete temp-ord-line .
end. /* for each */

for each buf_ord-line no-lock where
         buf_ord-line.doc-code = buf_ord-doc.doc-code
    /* on error undo, return error  */ :
        v-qnty = 0 .
        v-sum-qnty = 0 .
        for each buf_ord-line-rcv no-lock
            where buf_ord-line-rcv.doc-code = buf_ord-doc.doc-code and
                  buf_ord-line-rcv.artic     = buf_ord-line.artic and
                  buf_ord-line-rcv.prod-type = buf_ord-line.prod-type and
                  buf_ord-line-rcv.prod-code = buf_ord-line.prod-code,
                  first buf2-ord-doc-rcv no-lock where
                        buf2-ord-doc-rcv.rcv-code =  buf_ord-line-rcv.rcv-code and
                        buf2-ord-doc-rcv.doc-code =  buf_ord-line-rcv.doc-code    ,
                  each ub.ord-chain no-lock where
                            ub.ord-chain.doc-code = buf2-ord-doc-rcv.rcv-code and
                            ub.ord-chain.doc-type = 'rcv'                  and
                            ub.ord-chain.rel-doc-type = 'trn'              ,
                  first buf2-doc-line no-lock where
                        buf2-doc-line.doc-code     =  ub.ord-chain.rel-doc-code  and
                        buf2-doc-line.artic        =  buf_ord-line-rcv.artic    and
                        buf2-doc-line.prod-code    =  buf_ord-line-rcv.prod-code and
                        buf2-doc-line.prod-type    =  buf_ord-line-rcv.prod-type

                  /* on error undo, return error  */:
                  v-sum-qnty = v-sum-qnty + buf2-doc-line.fact-qnty .
        end. /* for each  */

        /* по строке заказа */
        if (v-sum-qnty < buf_ord-line.qnty) and
          (buf_ord-line.qnty - v-sum-qnty) <> ? then do:
          kk = kk + 1.

          create temp-ord-line .
          buffer-copy buf_ord-line to temp-ord-line
          assign
            temp-ord-line.qnty      = buf_ord-line.qnty - v-sum-qnty
            temp-ord-line.cli-qnty  = temp-ord-line.qnty / temp-ord-line.cli-base-rate
            temp-ord-line.sum-rubl  = temp-ord-line.qnty  * temp-ord-line.price-rubl
            temp-ord-line.sum-base  = temp-ord-line.qnty  * temp-ord-line.price-base
          .
          assign
            k-q      = k-q + temp-ord-line.qnty
            k-s-rubl = k-s-rubl + temp-ord-line.sum-rubl
            k-s-base = k-s-base + temp-ord-line.sum-base
          .

        end.
end. /* for each */



if kk > 0 then do:

{ cus/ord-code.i
    'chip'
    v-cntxt-db-num
    buf_ord-doc.obj-type
    buf_ord-doc.obj-code
    buf_ord-doc.doc-code
    loc-ord-num
    }


  create new_ord-doc.
  BUFFER-COPY buf_ord-doc to new_ord-doc
  assign
    new_ord-doc.doc-code = loc-ord-num
    new_ord-doc.doc-date = today
    new_ord-doc.status_  = {&g___new}
    new_ord-doc.flag_    = true
    new_ord-doc.creid    = v-cntxt-userid
    new_ord-doc.qnty     = k-q
    new_ord-doc.sum-rubl = k-s-rubl
    new_ord-doc.sum-base = k-s-base
    new_ord-doc.tot-lines = kk
      .
  for each temp-ord-line
      on error undo, return error :
    create new_ord-line.
    BUFFER-COPY temp-ord-line to new_ord-line
    assign
     new_ord-line.doc-code = loc-ord-num
    .
  end. /* for each */
  message "Не все количество товаров удалось распределить из заказа " buf_ord-doc.doc-code skip
           "Остальное количество товара перенесено в новый заказ "  loc-ord-num
            view-as alert-box .
end.