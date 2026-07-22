block-level on error undo, throw.
/*

Чистка УБД. Платежи

Автор: Ростовцев Александр
Дата создания: 20/09/2025
Author: Aleksandr Rostovtsev
Creation date: 09/20/25
*/

&scop Tables Платежи с историей ~
Стоп-листы с историей
/*&scop Tables payment ~*/
/*payment-attr ~        */
/*c-payment ~           */
/*c-payment-attr ~      */
/*stop-list ~           */
/*stop-list-attr ~      */
/*stop-list-line ~      */
/*stop-list-line-attr ~ */
/*c-stop-list ~         */
/*c-stop-list-line      */


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00091000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00091000.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 91.".

{ cmp/str-glbl.i }
{ cleandb/defs.i }

define variable v-cash-pay              as integer no-undo .
define variable v-obj-type              as character no-undo .
define variable v-obj-code              as integer no-undo .
define variable v-export                as logical no-undo .


define buffer fin-doc       for ub.fin-doc.
define buffer c-fin-doc     for ub.c-fin-doc.
define buffer ord-doc       for ub.ord-doc.
define buffer trn-doc       for ub.trn-doc.
define buffer c-trn-doc     for ub.trn-doc.
define buffer inkas         for ub.inkas.
define buffer c-inkas       for ub.inkas.
define buffer payment       for ub.payment.
define buffer buf_payment   for ub.payment.
define buffer stop-list     for ub.stop-list.
define buffer buf_stop-list for ub.stop-list.

on delete of ub.payment   override do: end.
on delete of ub.stop-list override do: end.

/*payment.source-type бывает  {&pmnt-cash-desk} {&pmnt-ord-doc} {&pmnt-trn-doc} {&pmnt-fin-doc} */
for each buf_clients no-lock
   where buf_clients.db-num <> ?
:
_payment:
for each payment no-lock where
         payment.host-code = buf_clients.host-code
     and payment.status_ <> ""
     and payment.fact-date < vardate-actual-docs
break
by payment.source-type
by payment.source-ref
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  v-export = no.
  if payment.d-card = '':u
  or not (payment.source-type = {&pmnt-trn-doc}
         or
         payment.source-type = {&pmnt-cash-desk})
  then do:
    case payment.source-type:
      when {&pmnt-fin-doc} then do:
        if payment.pmnt-code begins "-" then do:
          find first c-fin-doc no-lock where
                     c-fin-doc.host-code = payment.host-code
                 and c-fin-doc.fin-doc-code = integer(entry(2, payment.source-ref, "-"))
                 and c-fin-doc.is-del = yes
          no-error.
          if available c-fin-doc then do:
            v-export = yes.
          end.
        end.
        else do:
          find first fin-doc no-lock where
                     fin-doc.host-code = payment.host-code
                 and fin-doc.fin-doc-code = integer(payment.source-ref)
          no-error.
          if available fin-doc then do:
            v-export = yes.
          end.
        end.
      end. /*when {&pmnt-fin-doc} then do:*/
      when {&pmnt-ord-doc} then do:
        find first ord-doc no-lock where
                   ord-doc.doc-code = payment.source-ref no-error.
        if available ord-doc then do:
          v-export = yes.
        end.
      end.
    end case.
    /*копируем*/
    if not v-export then do:
      run cleanPayment in this-procedure.
      { cleandb/delmainrec.i payment}
      next _payment.
    end.
  end.
  else do:
    if payment.source-type = {&pmnt-trn-doc} then do:
      find first trn-doc no-lock where
                 trn-doc.doc-code = payment.source-ref no-error.
      if not available trn-doc then do:
        find first c-trn-doc no-lock where
                   c-trn-doc.doc-code = payment.source-ref no-error.
        if not available c-trn-doc then do:
          run cleanPayment in this-procedure.
          { cleandb/delmainrec.i payment }
        end.
      end.
    end.
    if payment.source-type = {&pmnt-cash-desk} then do:
      find first inkas no-lock where
                 inkas.inkas-code = payment.source-ref no-error.
      if not available inkas then do:
        find first c-inkas no-lock where
                   c-inkas.inkas-code = payment.source-ref no-error.
        if not available c-inkas then do:
          run cleanPayment in this-procedure.
          { cleandb/delmainrec.i payment }
        end.
      end.
    end.
  end.
end.

for each stop-list no-lock where 
         stop-list.status_  = {&fact}
    and stop-list.fact-date < vardate-actual-docs
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  run cleanStopList in this-procedure.
  { cleandb/delmainrec.i stop-list }
end.
end.  /* for first buf_clients */

{cleandb/setresval.i}
return vResult.

procedure cleanPayment:
  {cleandb/dellinkrec.i 
    payment-attr  
    "where payment-attr.pmnt-code = payment.pmnt-code"
  }
  {cleandb/dellinkrec.i 
    c-payment  
    "where c-payment.pmnt-code = c-payment.pmnt-code"
  }
  {cleandb/dellinkrec.i 
    c-payment-attr  
    "where c-payment-attr.pmnt-code = payment.pmnt-code"
  }
end procedure.

procedure cleanStopList:
  {cleandb/dellinkrec.i 
    stop-list-attr  
    "where stop-list-attr.classif-type = stop-list.classif-type
       and stop-list-attr.stop-list-code = stop-list.stop-list-code"
  }
  {cleandb/dellinkrec.i 
    stop-list-line  
    "where stop-list-line.classif-type = stop-list.classif-type
       and stop-list-line.stop-list-code = stop-list.stop-list-code"
  }
  {cleandb/dellinkrec.i 
    stop-list-line-attr  
    "where stop-list-line-attr.classif-type = stop-list.classif-type
       and stop-list-line-attr.stop-list-code = stop-list.stop-list-code"
  }
  {cleandb/dellinkrec.i 
    c-stop-list  
    "where c-stop-list.classif-type = stop-list.classif-type
       and c-stop-list.stop-list-code = stop-list.stop-list-code"
  }
  {cleandb/dellinkrec.i
    c-stop-list-line
    "where c-stop-list-line.classif-type   = stop-list.classif-type
       and c-stop-list-line.stop-list-code = stop-list.stop-list-code"
  }
end procedure.