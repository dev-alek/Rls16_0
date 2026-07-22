block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: Oct 28 2025 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 01020000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/01020000.p $".
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
define buffer tran-fuel         for ub.tran-fuel.
on delete of ub.tran-fuel       override do: end.
for each tran-fuel exclusive-lock
   where  tran-fuel.date-end < datetime(vardate-actual-docs,0)
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
    delete tran-fuel.
    vDeleted = vDeleted + 1.
end.
vResult = substitute("Произведена чистка таблиц: &1~nУдалено записей - &2.", "Топливные транзакции", vDeleted).
return vResult.
