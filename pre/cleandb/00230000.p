block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 03/10/2025":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00230000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00230000.p $".
define variable vss-description as character no-undo init "Файл пирога чистки БД.".
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
define buffer add-doc                for ub.add-doc                  .
define buffer buf_add-doc            for ub.add-doc                  .
on delete of ub.add-doc               override do: end.
for each buf_clients no-lock
   where buf_clients.db-num <> ?
:
  for each add-doc no-lock where
           add-doc.obj-type   = buf_clients.obj-type
       and add-doc.obj-code   = buf_clients.obj-code
       and add-doc.status_    = 'акт':U
       and add-doc.fact-date  < vardate-actual-docs
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    run cleanTables in this-procedure.
    find first buf_add-doc exclusive-lock where
           recid(buf_add-doc) = recid(add-doc) no-error no-wait.
if not avail buf_add-doc then
do:
  undo, return error "Ошибка удаления add-doc. Запись занята другим пользователем.".
end.
delete buf_add-doc.
vDeleted = vDeleted + 1.
  end.
end.
vResult = substitute("Произведена чистка таблиц: &1~nУдалено записей - &2.", "Документы доп.расходов с историей", vDeleted).
return vResult.
procedure cleanTable :
  define buffer c-add-doc for ub.c-add-doc.
on delete of ub.c-add-doc override do: end.
for each c-add-doc exclusive-lock
     where c-add-doc.doc-code = add-doc.doc-code
on error undo, return error
:
      delete c-add-doc no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer add-line for ub.add-line.
on delete of ub.add-line override do: end.
for each add-line exclusive-lock
     where add-line.doc-code = add-doc.doc-code
on error undo, return error
:
      delete add-line no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-add-line for ub.c-add-line.
on delete of ub.c-add-line override do: end.
for each c-add-line exclusive-lock
     where c-add-line.doc-code = add-doc.doc-code
on error undo, return error
:
      delete c-add-line no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer add-trn for ub.add-trn.
on delete of ub.add-trn override do: end.
for each add-trn exclusive-lock
     where add-trn.doc-code = add-doc.doc-code
on error undo, return error
:
      delete add-trn no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer add-trn-attr for ub.add-trn-attr.
on delete of ub.add-trn-attr override do: end.
for each add-trn-attr exclusive-lock
     where add-trn-attr.doc-code = add-doc.doc-code
on error undo, return error
:
      delete add-trn-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
end procedure.
