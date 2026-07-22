block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 13.10.2025 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 01000000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/01000000.p $".
define variable vss-description as character no-undo init "Чистка УБД..".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define input parameter vardate-actual-docs    as date      no-undo.
define input parameter varcall-back           as handle no-undo.
define variable vDeleted as int64     no-undo.
define variable vResult  as character no-undo.
define buffer buf_clients for ub.clients.
find ub.sys-ctrl no-lock.
if not available ub.sys-ctrl then do:
   return error "Не найдена уникальная запись sys-ctrl.".
end.
define buffer utd            for ub.utd.
define buffer buf_utd        for ub.utd.
on delete of ub.utd       override do: end.
for each buf_clients no-lock where
         buf_clients.db-num <> ?
:
  for each utd no-lock
     where utd.host-code    = buf_clients.host-code
       and utd.DocumentDate < vardate-actual-docs
       and utd.sts          = 8
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    run cleanTable in this-procedure.
    find first buf_utd exclusive-lock where
           recid(buf_utd) = recid(utd) no-error no-wait.
if not avail buf_utd then
do:
  undo, return error "Ошибка удаления utd. Запись занята другим пользователем.".
end.
delete buf_utd.
vDeleted = vDeleted + 1.
  end.
end.
vResult = substitute("Произведена чистка таблиц: &1~nУдалено записей - &2.", "Упд с историей", vDeleted).
return vResult.
procedure cleanTable:
  define buffer utd-attr for ub.utd-attr.
on delete of ub.utd-attr override do: end.
for each utd-attr exclusive-lock
     where utd-attr.db-num = utd.db-num
        and utd-attr.doc-id = utd.doc-id
on error undo, return error
:
      delete utd-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer utd-err for ub.utd-err.
on delete of ub.utd-err override do: end.
for each utd-err exclusive-lock
     where utd-err.db-num = utd.db-num
        and utd-err.doc-id = utd.doc-id
on error undo, return error
:
      delete utd-err no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer utd-err-attr for ub.utd-err-attr.
on delete of ub.utd-err-attr override do: end.
for each utd-err-attr exclusive-lock
     where utd-err-attr.db-num = utd.db-num
        and utd-err-attr.doc-id = utd.doc-id
on error undo, return error
:
      delete utd-err-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer utd-lines for ub.utd-lines.
on delete of ub.utd-lines override do: end.
for each utd-lines exclusive-lock
     where utd-lines.db-num = utd.db-num
        and utd-lines.doc-id = utd.doc-id
on error undo, return error
:
      delete utd-lines no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer utd-lines-attr for ub.utd-lines-attr.
on delete of ub.utd-lines-attr override do: end.
for each utd-lines-attr exclusive-lock
     where utd-lines-attr.db-num = utd.db-num
        and utd-lines-attr.doc-id = utd.doc-id
on error undo, return error
:
      delete utd-lines-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer utd-marking-lines for ub.utd-marking-lines.
on delete of ub.utd-marking-lines override do: end.
for each utd-marking-lines exclusive-lock
     where utd-marking-lines.db-num = utd.db-num
        and utd-marking-lines.doc-id = utd.doc-id
on error undo, return error
:
      delete utd-marking-lines no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer utd-marking-lines-attr for ub.utd-marking-lines-attr.
on delete of ub.utd-marking-lines-attr override do: end.
for each utd-marking-lines-attr exclusive-lock
     where utd-marking-lines-attr.db-num = utd.db-num
        and utd-marking-lines-attr.doc-id = utd.doc-id
on error undo, return error
:
      delete utd-marking-lines-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-utd for ub.c-utd.
on delete of ub.c-utd override do: end.
for each c-utd exclusive-lock
     where c-utd.db-num = utd.db-num
        and c-utd.doc-id = utd.doc-id
on error undo, return error
:
      delete c-utd no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-utd-head for ub.c-utd-head.
on delete of ub.c-utd-head override do: end.
for each c-utd-head exclusive-lock
     where c-utd-head.db-num = utd.db-num
        and c-utd-head.doc-id = utd.doc-id
on error undo, return error
:
      delete c-utd-head no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-utd-attr for ub.c-utd-attr.
on delete of ub.c-utd-attr override do: end.
for each c-utd-attr exclusive-lock
     where c-utd-attr.db-num = utd.db-num
        and c-utd-attr.doc-id = utd.doc-id
on error undo, return error
:
      delete c-utd-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-utd-err for ub.c-utd-err.
on delete of ub.c-utd-err override do: end.
for each c-utd-err exclusive-lock
     where c-utd-err.db-num = utd.db-num
        and c-utd-err.doc-id = utd.doc-id
on error undo, return error
:
      delete c-utd-err no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-utd-err-attr for ub.c-utd-err-attr.
on delete of ub.c-utd-err-attr override do: end.
for each c-utd-err-attr exclusive-lock
     where c-utd-err-attr.db-num = utd.db-num
        and c-utd-err-attr.doc-id = utd.doc-id
on error undo, return error
:
      delete c-utd-err-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-utd-lines for ub.c-utd-lines.
on delete of ub.c-utd-lines override do: end.
for each c-utd-lines exclusive-lock
     where c-utd-lines.db-num = utd.db-num
        and c-utd-lines.doc-id = utd.doc-id
on error undo, return error
:
      delete c-utd-lines no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-utd-lines-attr for ub.c-utd-lines-attr.
on delete of ub.c-utd-lines-attr override do: end.
for each c-utd-lines-attr exclusive-lock
     where c-utd-lines-attr.db-num = utd.db-num
        and c-utd-lines-attr.doc-id = utd.doc-id
on error undo, return error
:
      delete c-utd-lines-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-utd-marking-lines for ub.c-utd-marking-lines.
on delete of ub.c-utd-marking-lines override do: end.
for each c-utd-marking-lines exclusive-lock
     where c-utd-marking-lines.db-num = utd.db-num
        and c-utd-marking-lines.doc-id = utd.doc-id
on error undo, return error
:
      delete c-utd-marking-lines no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-utd-marking-lines-attr for ub.c-utd-marking-lines-attr.
on delete of ub.c-utd-marking-lines-attr override do: end.
for each c-utd-marking-lines-attr exclusive-lock
     where c-utd-marking-lines-attr.db-num = utd.db-num
        and c-utd-marking-lines-attr.doc-id = utd.doc-id
on error undo, return error
:
      delete c-utd-marking-lines-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
end procedure.
