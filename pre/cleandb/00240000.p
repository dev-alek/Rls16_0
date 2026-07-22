block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 03/10/2025":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00240000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00240000.p $".
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
define buffer schet-fact-doc     for ub.schet-fact-doc.
define buffer buf_schet-fact-doc for ub.schet-fact-doc.
on delete of ub.schet-fact-doc override do: end.
for each buf_clients no-lock where
         buf_clients.db-num <> ?
:
  for each schet-fact-doc no-lock where
          schet-fact-doc.obj-type  = buf_clients.obj-type
      and schet-fact-doc.obj-code  = buf_clients.obj-code
      and schet-fact-doc.fact-date < vardate-actual-docs
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    run cleanTables in this-procedure.
    find first buf_schet-fact-doc exclusive-lock where
           recid(buf_schet-fact-doc) = recid(schet-fact-doc) no-error no-wait.
if not avail buf_schet-fact-doc then
do:
  undo, return error "Ошибка удаления schet-fact-doc. Запись занята другим пользователем.".
end.
delete buf_schet-fact-doc.
vDeleted = vDeleted + 1.
  end.
end.
vResult = substitute("Произведена чистка таблиц: &1~nУдалено записей - &2.", "Счета-фактуры с историей", vDeleted).
return vResult.
procedure cleanTables :
  define buffer factur-connect           for ub.factur-connect.
  define buffer factur-connect-attr      for ub.factur-connect-attr.
  define buffer factur-connect-line      for ub.factur-connect-line.
  define buffer factur-connect-line-attr for ub.factur-connect-line-attr.
  on delete of ub.factur-connect               override do: end.
  on delete of ub.factur-connect-attr          override do: end.
  on delete of ub.factur-connect-line          override do: end.
  on delete of ub.factur-connect-line-attr     override do: end.
  define buffer schet-fact-doc-attr for ub.schet-fact-doc-attr.
on delete of ub.schet-fact-doc-attr override do: end.
for each schet-fact-doc-attr exclusive-lock
     where schet-fact-doc-attr.doc-code = schet-fact-doc.doc-code and schet-fact-doc-attr.db-num   = schet-fact-doc.db-num
on error undo, return error
:
      delete schet-fact-doc-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer schet-fact-line for ub.schet-fact-line.
on delete of ub.schet-fact-line override do: end.
for each schet-fact-line exclusive-lock
     where schet-fact-line.doc-code = schet-fact-doc.doc-code and schet-fact-line.db-num   = schet-fact-doc.db-num
on error undo, return error
:
      delete schet-fact-line no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-schet-fact-line for ub.c-schet-fact-line.
on delete of ub.c-schet-fact-line override do: end.
for each c-schet-fact-line exclusive-lock
     where c-schet-fact-line.doc-code = schet-fact-doc.doc-code and c-schet-fact-line.db-num   = schet-fact-doc.db-num
on error undo, return error
:
      delete c-schet-fact-line no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer schet-fact-line-attr for ub.schet-fact-line-attr.
on delete of ub.schet-fact-line-attr override do: end.
for each schet-fact-line-attr exclusive-lock
     where schet-fact-line-attr.doc-code = schet-fact-doc.doc-code and schet-fact-line-attr.db-num   = schet-fact-doc.db-num
on error undo, return error
:
      delete schet-fact-line-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-schet-fact-doc for ub.c-schet-fact-doc.
on delete of ub.c-schet-fact-doc override do: end.
for each c-schet-fact-doc exclusive-lock
     where c-schet-fact-doc.doc-code = schet-fact-doc.doc-code and c-schet-fact-doc.db-num   = schet-fact-doc.db-num
on error undo, return error
:
      delete c-schet-fact-doc no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  for each factur-connect exclusive-lock where
           factur-connect.factur-doc-code = schet-fact-doc.doc-code
       and factur-connect.db-num          = schet-fact-doc.db-num
  :
    for each factur-connect-attr exclusive-lock where
             factur-connect-attr.db-num       = factur-connect.db-num
         and factur-connect-attr.connect-code = factur-connect.connect-code
    :
      delete factur-connect-attr.
      vDeleted = vDeleted + 1.
    end.
    for each factur-connect-line exclusive-lock where
             factur-connect-line.db-num       =  factur-connect.db-num
         and factur-connect-line.connect-code = factur-connect.connect-code
    :
      delete factur-connect-line.
      vDeleted = vDeleted + 1.
    end.
    for each factur-connect-line-attr exclusive-lock where
             factur-connect-line-attr.db-num       =  factur-connect.db-num
         and factur-connect-line-attr.connect-code = factur-connect.connect-code
    :
      delete factur-connect-line-attr.
      vDeleted = vDeleted + 1.
    end.
    delete factur-connect.
    vDeleted = vDeleted + 1.
  end.
end procedure.
