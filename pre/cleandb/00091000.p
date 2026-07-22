block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00091000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00091000.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 91.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define input parameter vardate-actual-docs    as date      no-undo.
define input parameter varcall-back           as handle no-undo.
define variable vDeleted as int64     no-undo.
define variable vResult  as character no-undo.
define buffer buf_clients for ub.clients.
find ub.sys-ctrl no-lock.
if not available ub.sys-ctrl then do:
   return error "Не найдена уникальная запись sys-ctrl.".
end.
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
  or not (payment.source-type = 'накл':U
         or
         payment.source-type = 'касс':U)
  then do:
    case payment.source-type:
      when 'платеж':U then do:
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
      end.
      when 'заказ':U then do:
        find first ord-doc no-lock where
                   ord-doc.doc-code = payment.source-ref no-error.
        if available ord-doc then do:
          v-export = yes.
        end.
      end.
    end case.
    if not v-export then do:
      run cleanPayment in this-procedure.
      find first buf_payment exclusive-lock where
           recid(buf_payment) = recid(payment) no-error no-wait.
if not avail buf_payment then
do:
  undo, return error "Ошибка удаления payment. Запись занята другим пользователем.".
end.
delete buf_payment.
vDeleted = vDeleted + 1.
      next _payment.
    end.
  end.
  else do:
    if payment.source-type = 'накл':U then do:
      find first trn-doc no-lock where
                 trn-doc.doc-code = payment.source-ref no-error.
      if not available trn-doc then do:
        find first c-trn-doc no-lock where
                   c-trn-doc.doc-code = payment.source-ref no-error.
        if not available c-trn-doc then do:
          run cleanPayment in this-procedure.
          find first buf_payment exclusive-lock where
           recid(buf_payment) = recid(payment) no-error no-wait.
if not avail buf_payment then
do:
  undo, return error "Ошибка удаления payment. Запись занята другим пользователем.".
end.
delete buf_payment.
vDeleted = vDeleted + 1.
        end.
      end.
    end.
    if payment.source-type = 'касс':U then do:
      find first inkas no-lock where
                 inkas.inkas-code = payment.source-ref no-error.
      if not available inkas then do:
        find first c-inkas no-lock where
                   c-inkas.inkas-code = payment.source-ref no-error.
        if not available c-inkas then do:
          run cleanPayment in this-procedure.
          find first buf_payment exclusive-lock where
           recid(buf_payment) = recid(payment) no-error no-wait.
if not avail buf_payment then
do:
  undo, return error "Ошибка удаления payment. Запись занята другим пользователем.".
end.
delete buf_payment.
vDeleted = vDeleted + 1.
        end.
      end.
    end.
  end.
end.
for each stop-list no-lock where
         stop-list.status_  = 'факт':U
    and stop-list.fact-date < vardate-actual-docs
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  run cleanStopList in this-procedure.
  find first buf_stop-list exclusive-lock where
           recid(buf_stop-list) = recid(stop-list) no-error no-wait.
if not avail buf_stop-list then
do:
  undo, return error "Ошибка удаления stop-list. Запись занята другим пользователем.".
end.
delete buf_stop-list.
vDeleted = vDeleted + 1.
end.
end.
vResult = substitute("Произведена чистка таблиц: &1~nУдалено записей - &2.", "Платежи с историей Стоп-листы с историей", vDeleted).
return vResult.
procedure cleanPayment:
  define buffer payment-attr for ub.payment-attr.
on delete of ub.payment-attr override do: end.
for each payment-attr exclusive-lock
    where payment-attr.pmnt-code = payment.pmnt-code
on error undo, return error
:
      delete payment-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-payment for ub.c-payment.
on delete of ub.c-payment override do: end.
for each c-payment exclusive-lock
    where c-payment.pmnt-code = c-payment.pmnt-code
on error undo, return error
:
      delete c-payment no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-payment-attr for ub.c-payment-attr.
on delete of ub.c-payment-attr override do: end.
for each c-payment-attr exclusive-lock
    where c-payment-attr.pmnt-code = payment.pmnt-code
on error undo, return error
:
      delete c-payment-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
end procedure.
procedure cleanStopList:
  define buffer stop-list-attr for ub.stop-list-attr.
on delete of ub.stop-list-attr override do: end.
for each stop-list-attr exclusive-lock
    where stop-list-attr.classif-type = stop-list.classif-type
       and stop-list-attr.stop-list-code = stop-list.stop-list-code
on error undo, return error
:
      delete stop-list-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer stop-list-line for ub.stop-list-line.
on delete of ub.stop-list-line override do: end.
for each stop-list-line exclusive-lock
    where stop-list-line.classif-type = stop-list.classif-type
       and stop-list-line.stop-list-code = stop-list.stop-list-code
on error undo, return error
:
      delete stop-list-line no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer stop-list-line-attr for ub.stop-list-line-attr.
on delete of ub.stop-list-line-attr override do: end.
for each stop-list-line-attr exclusive-lock
    where stop-list-line-attr.classif-type = stop-list.classif-type
       and stop-list-line-attr.stop-list-code = stop-list.stop-list-code
on error undo, return error
:
      delete stop-list-line-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-stop-list for ub.c-stop-list.
on delete of ub.c-stop-list override do: end.
for each c-stop-list exclusive-lock
    where c-stop-list.classif-type = stop-list.classif-type
       and c-stop-list.stop-list-code = stop-list.stop-list-code
on error undo, return error
:
      delete c-stop-list no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-stop-list-line for ub.c-stop-list-line.
on delete of ub.c-stop-list-line override do: end.
for each c-stop-list-line exclusive-lock
    where c-stop-list-line.classif-type   = stop-list.classif-type
       and c-stop-list-line.stop-list-code = stop-list.stop-list-code
on error undo, return error
:
      delete c-stop-list-line no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
end procedure.
