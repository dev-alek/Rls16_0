block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: oo-mkrcv.p $
$Archive: cus/oo-mkrcv.p $

Формирование строки  поставки для ОО ОРЦ заказа . Чтобы видна была созданная щепка .

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 07/23/04 3:34

*/
define parameter buffer buf_old_trn-doc for  ub.trn-doc .
define parameter buffer buf_new_trn-doc for  ub.trn-doc .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: oo-mkrcv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/oo-mkrcv.p $":U .
define variable vss-description as character no-undo init " Формирование связи заказ накладная".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/waitfram.i }
{ cus/ord-code.i def }
{ cus/ord-lib.i create-chain }
define variable store-type as character no-undo .
define variable store-code as integer no-undo .

define buffer buf_ord-doc-rcv  for ub.ord-doc-rcv .
define buffer old_ord-doc-rcv  for ub.ord-doc-rcv .
define buffer buf_ord-line-rcv for ub.ord-line-rcv.
define buffer buf_doc-line     for ub.doc-line.
define buffer buf_goods for ub.goods.

define variable loc-rcv-num as character no-undo .

main:
do on stop undo main, return error on error undo main, return error :

find first ub.ord-chain no-lock where
           ub.ord-chain.rel-doc-code = buf_old_trn-doc.doc-code and
           ub.ord-chain.rel-doc-type = 'trn' and
           ub.ord-chain.doc-type     = 'rcv'
           no-error .
find first old_ord-doc-rcv no-lock where
           old_ord-doc-rcv.rcv-code =  ub.ord-chain.doc-code
           no-error .
if not available old_ord-doc-rcv then do:
    return .
end.

 run waitfram-show in this-procedure ("Создание связи Заказ-Накладная") .

 store-type = buf_old_trn-doc.obj-type .
 store-code = buf_old_trn-doc.obj-code .

define variable  v-i-doc as character no-undo .
{ cus/ord-code.i
    'main'
    g#db-num
    buf_old_trn-doc.obj-type
    buf_old_trn-doc.obj-code
    v-i-doc
    loc-rcv-num
    }

      /* Шапка поставки */
      create buf_ord-doc-rcv.
      buffer-copy old_ord-doc-rcv to buf_ord-doc-rcv
        assign
            buf_ord-doc-rcv.rcv-code  = loc-rcv-num
            buf_ord-doc-rcv.doc-type  = {&ord-req}
            buf_ord-doc-rcv.doc-date  = today
            buf_ord-doc-rcv.status_  = {&ord-req}
            buf_ord-doc-rcv.obj-code = buf_new_trn-doc.obj-code
            buf_ord-doc-rcv.obj-type = buf_new_trn-doc.obj-type
            buf_ord-doc-rcv.cli-code = buf_new_trn-doc.cli-code
            buf_ord-doc-rcv.cli-type = buf_new_trn-doc.cli-type
      .

      run create-chain in this-procedure
      ( buf_ord-doc-rcv.rcv-code
       , 'rcv'
       , buf_new_trn-doc.doc-code
       , 'trn'
       , ''
       , '' ) no-error .
       if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "Ошибка создания цепочки"
            view-as alert-box error
          .
       end.


     /* строки */
      for each  buf_doc-line no-lock  where
          buf_doc-line.doc-code =  buf_new_trn-doc.doc-code
          on error undo main, return error :
          find first buf_goods where
              buf_goods.artic      = buf_doc-line.artic      and
              buf_goods.prod-type  = buf_doc-line.prod-type  and
              buf_goods.prod-code  = buf_doc-line.prod-code
              no-lock no-error .

            create buf_ord-line-rcv.
            buffer-copy  buf_doc-line to buf_ord-line-rcv
            assign
                buf_ord-line-rcv.gds-code  = buf_goods.gds-code
                buf_ord-line-rcv.rcv-code  = loc-rcv-num
                buf_ord-line-rcv.doc-code  = buf_ord-doc-rcv.doc-code
                buf_ord-line-rcv.qnty      = buf_doc-line.fact-qnty
            .
      end.

run waitfram-hide in this-procedure .

end.