block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 17/09/2025":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00193000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00193000.p $".
define variable vss-description as character no-undo init "Файл пирога чистки БД.".
define buffer wth-doc for ub.wth-doc.
define buffer buf_wth-doc for ub.wth-doc.
define stream LogStream.
on delete of ub.wth-doc   override do: end.
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
for each buf_clients no-lock
   where buf_clients.db-num <> ?
:
  for each wth-doc no-lock where
           wth-doc.host-code = buf_clients.host-code
       and wth-doc.obj-type  = buf_clients.obj-type
       and wth-doc.obj-code  = buf_clients.obj-code
       and wth-doc.status_   = 'факт':U
       and wth-doc.fact-date < vardate-actual-docs
  use-index stat-fact
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    run cleanTables in this-procedure.
    find first buf_wth-doc exclusive-lock where
           recid(buf_wth-doc) = recid(wth-doc) no-error no-wait.
if not avail buf_wth-doc then
do:
  undo, return error "Ошибка удаления wth-doc. Запись занята другим пользователем.".
end.
delete buf_wth-doc.
vDeleted = vDeleted + 1.
  end.
end.
vResult = substitute("Произведена чистка таблиц: &1~nУдалено записей - &2.", "Мат. ценности", vDeleted).
return vResult.
procedure cleanTables :
    define buffer wth-doc-attr for ub.wth-doc-attr.
on delete of ub.wth-doc-attr override do: end.
for each wth-doc-attr exclusive-lock
     where wth-doc-attr.doc-code = wth-doc.doc-code
on error undo, return error
:
      delete wth-doc-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer wth-line for ub.wth-line.
on delete of ub.wth-line override do: end.
for each wth-line exclusive-lock
     where wth-line.doc-code = wth-doc.doc-code
on error undo, return error
:
      delete wth-line no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer wth-line-attr for ub.wth-line-attr.
on delete of ub.wth-line-attr override do: end.
for each wth-line-attr exclusive-lock
     where wth-line-attr.doc-code = wth-doc.doc-code
on error undo, return error
:
      delete wth-line-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer wth-dtl for ub.wth-dtl.
on delete of ub.wth-dtl override do: end.
for each wth-dtl exclusive-lock
     where wth-dtl.doc-code = wth-doc.doc-code
on error undo, return error
:
      delete wth-dtl no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer wth-dtl-attr for ub.wth-dtl-attr.
on delete of ub.wth-dtl-attr override do: end.
for each wth-dtl-attr exclusive-lock
     where wth-dtl-attr.doc-code = wth-doc.doc-code
on error undo, return error
:
      delete wth-dtl-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer wth-parts for ub.wth-parts.
on delete of ub.wth-parts override do: end.
for each wth-parts exclusive-lock
     where wth-parts.out-code = wth-doc.doc-code
on error undo, return error
:
      delete wth-parts no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer chk-doc for ub.chk-doc.
on delete of ub.chk-doc override do: end.
for each chk-doc exclusive-lock
     where chk-doc.out-code = wth-doc.doc-code
on error undo, return error
:
      delete chk-doc no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer c-chk-doc for ub.c-chk-doc.
on delete of ub.c-chk-doc override do: end.
for each c-chk-doc exclusive-lock
     where c-chk-doc.out-code = wth-doc.doc-code
on error undo, return error
:
      delete c-chk-doc no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer chk-doc-attr for ub.chk-doc-attr.
on delete of ub.chk-doc-attr override do: end.
for each chk-doc-attr exclusive-lock
     where chk-doc-attr.out-code = wth-doc.doc-code
on error undo, return error
:
      delete chk-doc-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer c-chk-doc-attr for ub.c-chk-doc-attr.
on delete of ub.c-chk-doc-attr override do: end.
for each c-chk-doc-attr exclusive-lock
     where c-chk-doc-attr.out-code = wth-doc.doc-code
on error undo, return error
:
      delete c-chk-doc-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer chk-pay for ub.chk-pay.
on delete of ub.chk-pay override do: end.
for each chk-pay exclusive-lock
     where chk-pay.out-code = wth-doc.doc-code
on error undo, return error
:
      delete chk-pay no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer c-chk-pay for ub.c-chk-pay.
on delete of ub.c-chk-pay override do: end.
for each c-chk-pay exclusive-lock
     where c-chk-pay.out-code = wth-doc.doc-code
on error undo, return error
:
      delete c-chk-pay no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer chk-pay-attr for ub.chk-pay-attr.
on delete of ub.chk-pay-attr override do: end.
for each chk-pay-attr exclusive-lock
     where chk-pay-attr.out-code = wth-doc.doc-code
on error undo, return error
:
      delete chk-pay-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer doc-attr for ub.doc-attr.
on delete of ub.doc-attr override do: end.
for each doc-attr exclusive-lock
     where doc-attr.doc-code = wth-doc.doc-code
on error undo, return error
:
      delete doc-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer c-doc-attr for ub.c-doc-attr.
on delete of ub.c-doc-attr override do: end.
for each c-doc-attr exclusive-lock
     where c-doc-attr.doc-code = wth-doc.doc-code
on error undo, return error
:
      delete c-doc-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer c-wth-doc for ub.c-wth-doc.
on delete of ub.c-wth-doc override do: end.
for each c-wth-doc exclusive-lock
     where c-wth-doc.doc-code = wth-doc.doc-code
on error undo, return error
:
      delete c-wth-doc no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer c-wth-line for ub.c-wth-line.
on delete of ub.c-wth-line override do: end.
for each c-wth-line exclusive-lock
     where c-wth-line.doc-code = wth-doc.doc-code
on error undo, return error
:
      delete c-wth-line no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer c-wth-dtl     for ub.c-wth-dtl.
    on delete of ub.c-wth-dtl    override do: end.
    for each c-wth-dtl exclusive-lock
       where c-wth-dtl.doc-code         = wth-doc.doc-code
    on error undo, return error
    :
      define buffer c-wth-parts for ub.c-wth-parts.
on delete of ub.c-wth-parts override do: end.
for each c-wth-parts exclusive-lock
    where c-wth-parts.obj-type = wth-doc.obj-type
           and c-wth-parts.obj-code = wth-doc.obj-code
           and c-wth-parts.w-p-code = c-wth-dtl.w-p-code
           and c-wth-parts.wth-code = c-wth-dtl.wth-code
           and c-wth-parts.par-code = c-wth-dtl.par-code
           and c-wth-parts.out-code = wth-doc.doc-code
on error undo, return error
:
      delete c-wth-parts no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
      delete c-wth-dtl.
      vDeleted = vDeleted + 1.
    end.
end procedure.
