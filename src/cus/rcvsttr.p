block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rcvsttr.p $
$Archive: cus/rcvsttr.p $

Изменение статуса поставки при закрытии накладной на факт

Автор: Чернова Светлана Александровна
Дата создания: 04/07/06
Author: Svetlana Chernova
Creation date: 04/07/06

*/

define input  parameter parparentproc as handle no-undo .
define input  parameter p-recid as recid no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rcvsttr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/rcvsttr.p $":U .
define variable vss-description as character no-undo init "Изменение статуса поставки при закрытии накладной на факт".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }

define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
define buffer buf_ord-doc for ub.ord-doc.
define variable   to-day  as date  no-undo .

find first buf_trn-doc no-lock where recid(buf_trn-doc) =  p-recid no-error .
    if error-status :error then do:
        message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1)
            "ОШИБКА при поиске Накладной "
            view-as alert-box error .
            return .
    end.

find first  ub.ord-chain no-lock where
            ub.ord-chain.rel-doc-code = buf_trn-doc.doc-code  and
            ub.ord-chain.doc-type = 'rcv'                  and
            ub.ord-chain.rel-doc-type = 'trn' no-error .
    if error-status :error then do:
       return .
    end.

find first buf_ord-doc-rcv no-lock where buf_ord-doc-rcv.rcv-code = ub.ord-chain.doc-code no-error .
    if error-status :error then do:
       return .
    end.


find first buf_ord-doc no-lock where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code and
                                     buf_ord-doc.doc-type = {&o-r} no-error .
if available buf_ord-doc then do:
    if buf_trn-doc.doc-type <> {&income} then do: /* расход */
       run cus/ordorcls.p ( parparentproc, input recid(buf_ord-doc) , input false ) no-error .
    /*
      message "расход: сТАТУС ПОСЛЕ ЗАКРЫТИЕ ЗАКАЗА (ОТГР) = "  buf_ord-doc.STATUS_ skip
      "закоытие расходной накладной на факт" .
      */
    end.
    else do:
       run cus/ordorcls.p ( parparentproc , input recid(buf_ord-doc) , input false ) no-error .
    /*
      message " приход : сТАТУС ПОСЛЕ ЗАКРЫТИЕ  ЗАКАЗА (ФАКТ) = "  buf_ord-doc.STATUS_ skip
    "закоытие расходной накладной на факт" .
    */
    end.

    if error-status :error  and return-value <> "" then do:
    message
      error-status :get-message(1) skip
      return-value skip
      "Заказ нельзя закрыть !"
      view-as alert-box error
    .
    return error .
    end.
end.
/* ЗАКАЗ ПОКУПАТЕЛЮ */
find first buf_ord-doc no-lock where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code and
                                     buf_ord-doc.doc-type = {&p-o} no-error .
if available buf_ord-doc then do:
   run cus/ordpocls.p ( parparentproc , input recid(buf_ord-doc) , input false ) no-error .
   if error-status :error  and return-value begins 'error'  then DO:
      return error substring(return-value , 7) .
   END.
end.

/*  заказ ОП, ФП */
find first buf_ord-doc no-lock
     where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code
     and (
          buf_ord-doc.doc-type = {&o-p}
       or buf_ord-doc.doc-type = {&f-p}
          )
       no-error .
if available buf_ord-doc then do:
    /* закрыть  */
   run cus/ordopcls.p ( parparentproc , input recid(buf_ord-doc) , input false ) no-error .
   if error-status :error  and return-value begins 'error'  then DO:
      return error substring(return-value , 7) .
   END.
end.