block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 03/10/2025":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00221000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00221000.p $".
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
define buffer price-doc-forming     for ub.price-doc-forming.
define buffer buf_price-doc-forming for ub.price-doc-forming.
on delete of ub.price-doc-forming           override do: end.
for each price-doc-forming no-lock
   where price-doc-forming.sys-date < vardate-actual-docs
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
  run cleanTables in this-procedure.
  find first buf_price-doc-forming exclusive-lock where
           recid(buf_price-doc-forming) = recid(price-doc-forming) no-error no-wait.
if not avail buf_price-doc-forming then
do:
  undo, return error "Ошибка удаления price-doc-forming. Запись занята другим пользователем.".
end.
delete buf_price-doc-forming.
vDeleted = vDeleted + 1.
end.
vResult = substitute("Произведена чистка таблиц: &1~nУдалено записей - &2.", "Документ формирования цены с историей", vDeleted).
return vResult.
procedure cleanTables :
  define buffer c-price-doc-forming for ub.c-price-doc-forming.
on delete of ub.c-price-doc-forming override do: end.
for each c-price-doc-forming exclusive-lock
on error undo, return error
:
      delete c-price-doc-forming no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer price-doc-forming-attr for ub.price-doc-forming-attr.
on delete of ub.price-doc-forming-attr override do: end.
for each price-doc-forming-attr exclusive-lock
    where price-doc-forming-attr.plt-id     = price-doc-forming.plt-id       and price-doc-forming-attr.plt-db-num = price-doc-forming.plt-db-num       and price-doc-forming-attr.pdf-id     = price-doc-forming.pdf-id       and price-doc-forming-attr.pdf-db     = price-doc-forming.pdf-db
on error undo, return error
:
      delete price-doc-forming-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-price-doc-forming-attr for ub.c-price-doc-forming-attr.
on delete of ub.c-price-doc-forming-attr override do: end.
for each c-price-doc-forming-attr exclusive-lock
    where c-price-doc-forming-attr.plt-id     = price-doc-forming.plt-id       and c-price-doc-forming-attr.plt-db-num = price-doc-forming.plt-db-num       and c-price-doc-forming-attr.pdf-id     = price-doc-forming.pdf-id       and c-price-doc-forming-attr.pdf-db     = price-doc-forming.pdf-db
on error undo, return error
:
      delete c-price-doc-forming-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer price-doc-forming-gds for ub.price-doc-forming-gds.
on delete of ub.price-doc-forming-gds override do: end.
for each price-doc-forming-gds exclusive-lock
    where price-doc-forming-gds.plt-id     = price-doc-forming.plt-id       and price-doc-forming-gds.plt-db-num = price-doc-forming.plt-db-num       and price-doc-forming-gds.pdf-id     = price-doc-forming.pdf-id       and price-doc-forming-gds.pdf-db     = price-doc-forming.pdf-db
on error undo, return error
:
      delete price-doc-forming-gds no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-price-doc-forming-gds for ub.c-price-doc-forming-gds.
on delete of ub.c-price-doc-forming-gds override do: end.
for each c-price-doc-forming-gds exclusive-lock
    where c-price-doc-forming-gds.plt-id     = price-doc-forming.plt-id       and c-price-doc-forming-gds.plt-db-num = price-doc-forming.plt-db-num       and c-price-doc-forming-gds.pdf-id     = price-doc-forming.pdf-id       and c-price-doc-forming-gds.pdf-db     = price-doc-forming.pdf-db
on error undo, return error
:
      delete c-price-doc-forming-gds no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer price-doc-forming-gdsattr for ub.price-doc-forming-gdsattr.
on delete of ub.price-doc-forming-gdsattr override do: end.
for each price-doc-forming-gdsattr exclusive-lock
    where price-doc-forming-gdsattr.plt-id     = price-doc-forming.plt-id       and price-doc-forming-gdsattr.plt-db-num = price-doc-forming.plt-db-num       and price-doc-forming-gdsattr.pdf-id     = price-doc-forming.pdf-id       and price-doc-forming-gdsattr.pdf-db     = price-doc-forming.pdf-db
on error undo, return error
:
      delete price-doc-forming-gdsattr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-price-doc-forming-gdsattr for ub.c-price-doc-forming-gdsattr.
on delete of ub.c-price-doc-forming-gdsattr override do: end.
for each c-price-doc-forming-gdsattr exclusive-lock
    where c-price-doc-forming-gdsattr.plt-id     = price-doc-forming.plt-id       and c-price-doc-forming-gdsattr.plt-db-num = price-doc-forming.plt-db-num       and c-price-doc-forming-gdsattr.pdf-id     = price-doc-forming.pdf-id       and c-price-doc-forming-gdsattr.pdf-db     = price-doc-forming.pdf-db
on error undo, return error
:
      delete c-price-doc-forming-gdsattr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer price-doc-forming-gds-qnty for ub.price-doc-forming-gds-qnty.
on delete of ub.price-doc-forming-gds-qnty override do: end.
for each price-doc-forming-gds-qnty exclusive-lock
    where price-doc-forming-gds-qnty.plt-id     = price-doc-forming.plt-id       and price-doc-forming-gds-qnty.plt-db-num = price-doc-forming.plt-db-num       and price-doc-forming-gds-qnty.pdf-id     = price-doc-forming.pdf-id       and price-doc-forming-gds-qnty.pdf-db     = price-doc-forming.pdf-db
on error undo, return error
:
      delete price-doc-forming-gds-qnty no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-price-doc-forming-gds-qnty for ub.c-price-doc-forming-gds-qnty.
on delete of ub.c-price-doc-forming-gds-qnty override do: end.
for each c-price-doc-forming-gds-qnty exclusive-lock
    where c-price-doc-forming-gds-qnty.plt-id     = price-doc-forming.plt-id       and c-price-doc-forming-gds-qnty.plt-db-num = price-doc-forming.plt-db-num       and c-price-doc-forming-gds-qnty.pdf-id     = price-doc-forming.pdf-id       and c-price-doc-forming-gds-qnty.pdf-db     = price-doc-forming.pdf-db
on error undo, return error
:
      delete c-price-doc-forming-gds-qnty no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer price-doc-forming-gds-sum for ub.price-doc-forming-gds-sum.
on delete of ub.price-doc-forming-gds-sum override do: end.
for each price-doc-forming-gds-sum exclusive-lock
    where price-doc-forming-gds-sum.plt-id     = price-doc-forming.plt-id       and price-doc-forming-gds-sum.plt-db-num = price-doc-forming.plt-db-num       and price-doc-forming-gds-sum.pdf-id     = price-doc-forming.pdf-id       and price-doc-forming-gds-sum.pdf-db     = price-doc-forming.pdf-db
on error undo, return error
:
      delete price-doc-forming-gds-sum no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-price-doc-forming-gds-sum for ub.c-price-doc-forming-gds-sum.
on delete of ub.c-price-doc-forming-gds-sum override do: end.
for each c-price-doc-forming-gds-sum exclusive-lock
    where c-price-doc-forming-gds-sum.plt-id     = price-doc-forming.plt-id       and c-price-doc-forming-gds-sum.plt-db-num = price-doc-forming.plt-db-num       and c-price-doc-forming-gds-sum.pdf-id     = price-doc-forming.pdf-id       and c-price-doc-forming-gds-sum.pdf-db     = price-doc-forming.pdf-db
on error undo, return error
:
      delete c-price-doc-forming-gds-sum no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer price-doc-forming-gds-tnv for ub.price-doc-forming-gds-tnv.
on delete of ub.price-doc-forming-gds-tnv override do: end.
for each price-doc-forming-gds-tnv exclusive-lock
    where price-doc-forming-gds-tnv.plt-id     = price-doc-forming.plt-id       and price-doc-forming-gds-tnv.plt-db-num = price-doc-forming.plt-db-num       and price-doc-forming-gds-tnv.pdf-id     = price-doc-forming.pdf-id       and price-doc-forming-gds-tnv.pdf-db     = price-doc-forming.pdf-db
on error undo, return error
:
      delete price-doc-forming-gds-tnv no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-price-doc-forming-gds-tnv for ub.c-price-doc-forming-gds-tnv.
on delete of ub.c-price-doc-forming-gds-tnv override do: end.
for each c-price-doc-forming-gds-tnv exclusive-lock
    where c-price-doc-forming-gds-tnv.plt-id     = price-doc-forming.plt-id       and c-price-doc-forming-gds-tnv.plt-db-num = price-doc-forming.plt-db-num       and c-price-doc-forming-gds-tnv.pdf-id     = price-doc-forming.pdf-id       and c-price-doc-forming-gds-tnv.pdf-db     = price-doc-forming.pdf-db
on error undo, return error
:
      delete c-price-doc-forming-gds-tnv no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer price-all for ub.price-all.
  define buffer price-all-attr for ub.price-all-attr.
  on delete of ub.price-all      override do: end.
  on delete of ub.price-all-attr override do: end.
  for each price-all exclusive-lock
     where price-all.plt-id     = price-doc-forming.plt-id
       and price-all.plt-db-num = price-doc-forming.plt-db-num
       and price-all.pdf-id     = price-doc-forming.pdf-id
       and price-all.pdf-db     = price-doc-forming.pdf-db
  on error undo, return error
  :
    for each price-all-attr exclusive-lock
       where price-all-attr.pal-p      = price-all.pal-p
         and price-all-attr.pal-id     = price-all.pal-id
         and price-all-attr.pal-db-num = price-all.pal-db-num
    on error undo, return error
    :
      delete price-all-attr.
      vDeleted = vDeleted + 1.
    end.
    delete price-all.
    vDeleted = vDeleted + 1.
  end.
end procedure.
