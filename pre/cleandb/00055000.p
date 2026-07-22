block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: Sep 15 2025 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00055000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00055000.p $".
define variable vss-description as character no-undo init "Чистка УБД.".
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
define buffer fbr-doc      for ub.fbr-doc.
define buffer buf_fbr-doc  for ub.fbr-doc.
define buffer fbr-pln      for ub.fbr-pln.
define buffer buf_fbr-pln  for ub.fbr-pln.
on delete of ub.fbr-doc override do: end.
on delete of ub.fbr-pln override do: end.
for each buf_clients no-lock
    where buf_clients.db-num <> ?
:
  for each fbr-doc no-lock
     where fbr-doc.obj-type  = buf_clients.obj-type
       and fbr-doc.obj-code  = buf_clients.obj-code
       and fbr-doc.fact-date < vardate-actual-docs
  on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    run cleanFbrTable in this-procedure.
    find first buf_fbr-doc exclusive-lock where
           recid(buf_fbr-doc) = recid(fbr-doc) no-error no-wait.
if not avail buf_fbr-doc then
do:
  undo, return error "Ошибка удаления fbr-doc. Запись занята другим пользователем.".
end.
delete buf_fbr-doc.
vDeleted = vDeleted + 1.
  end.
  for each fbr-pln no-lock
     where fbr-pln.obj-type  = buf_clients.obj-type
       and fbr-pln.obj-code  = buf_clients.obj-code
       and fbr-pln.fact-date < vardate-actual-docs
  on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    run cleanPlnTable in this-procedure.
    find first buf_fbr-pln exclusive-lock where
           recid(buf_fbr-pln) = recid(fbr-pln) no-error no-wait.
if not avail buf_fbr-pln then
do:
  undo, return error "Ошибка удаления fbr-pln. Запись занята другим пользователем.".
end.
delete buf_fbr-pln.
vDeleted = vDeleted + 1.
  end.
end.
vResult = substitute("Произведена чистка таблиц: &1~nУдалено записей - &2.", "Документы производства с историей Документы план-меню c историей", vDeleted).
return vResult.
procedure cleanFbrTable :
  define buffer fbr-line       for ub.fbr-line.
  define buffer fbr-recipe     for ub.fbr-recipe.
  on delete of ub.fbr-line   override do: end.
  on delete of ub.fbr-recipe override do: end.
  for each fbr-line exclusive-lock
     where fbr-line.doc-code = fbr-doc.doc-code
  :
    if fbr-line.recipe-code <> ? and
       fbr-line.recipe-code <> "":U
    then do:
      if fbr-line.is-comp = yes
      then do:
        define buffer recipe-develop for ub.recipe-develop.
on delete of ub.recipe-develop override do: end.
for each recipe-develop exclusive-lock
    where recipe-develop.recipe-code = fbr-line.recipe-code
             and recipe-develop.doc-code = fbr-line.doc-code
on error undo, return error
:
      delete recipe-develop no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
        define buffer c-recipe-develop for ub.c-recipe-develop.
on delete of ub.c-recipe-develop override do: end.
for each c-recipe-develop exclusive-lock
    where c-recipe-develop.recipe-code = fbr-line.recipe-code
             and c-recipe-develop.doc-code = fbr-line.doc-code
on error undo, return error
:
      delete c-recipe-develop no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
        for each fbr-recipe exclusive-lock
           where fbr-recipe.doc-code    = fbr-line.doc-code
             and fbr-recipe.recipe-code = fbr-line.recipe-code
        :
          define buffer fbr-recipe-gds for ub.fbr-recipe-gds.
on delete of ub.fbr-recipe-gds override do: end.
for each fbr-recipe-gds exclusive-lock
    where fbr-recipe-gds.doc-code = fbr-recipe.doc-code
               and fbr-recipe-gds.recipe-code = fbr-recipe.recipe-code
on error undo, return error
:
      delete fbr-recipe-gds no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
          delete fbr-recipe.
          vDeleted = vDeleted + 1.
        end.
      end.
    end.
    delete fbr-line.
    vDeleted = vDeleted + 1.
  end.
  define buffer doc-attr for ub.doc-attr.
on delete of ub.doc-attr override do: end.
for each doc-attr exclusive-lock
    where doc-attr.doc-code = fbr-doc.doc-code
on error undo, return error
:
      delete doc-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-fbr-doc for ub.c-fbr-doc.
on delete of ub.c-fbr-doc override do: end.
for each c-fbr-doc exclusive-lock
    where c-fbr-doc.doc-code = fbr-doc.doc-code
on error undo, return error
:
      delete c-fbr-doc no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-doc-attr for ub.c-doc-attr.
on delete of ub.c-doc-attr override do: end.
for each c-doc-attr exclusive-lock
    where c-doc-attr.doc-code = fbr-doc.doc-code
on error undo, return error
:
      delete c-doc-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-fbr-line for ub.c-fbr-line.
on delete of ub.c-fbr-line override do: end.
for each c-fbr-line exclusive-lock
    where c-fbr-line.doc-code = fbr-doc.doc-code
on error undo, return error
:
      delete c-fbr-line no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer fbr-history for ub.fbr-history.
on delete of ub.fbr-history override do: end.
for each fbr-history exclusive-lock
    where fbr-history.obj-type = fbr-doc.obj-type and fbr-history.obj-code = fbr-doc.obj-code and fbr-history.doc-code = fbr-doc.doc-code
on error undo, return error
:
      delete fbr-history no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
end procedure.
procedure cut-pln-table :
  define buffer fbr-pln-line   for ub.fbr-pln-line.
  on delete of ub.fbr-pln-line override do: end.
  define buffer c-fbr-pln for ub.c-fbr-pln.
on delete of ub.c-fbr-pln override do: end.
for each c-fbr-pln exclusive-lock
     where c-fbr-pln.doc-code  = fbr-pln.doc-code
on error undo, return error
:
      delete c-fbr-pln no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  for each fbr-pln-line exclusive-lock
     where fbr-pln-line.doc-code = fbr-pln.doc-code
  :
    define buffer c-fbr-pln-line for ub.c-fbr-pln-line.
on delete of ub.c-fbr-pln-line override do: end.
for each c-fbr-pln-line exclusive-lock
     where c-fbr-pln-line.doc-code     = fbr-pln.doc-code and              c-fbr-pln-line.fbr-obj-type = fbr-pln-line.fbr-obj-type  and              c-fbr-pln-line.fbr-obj-code = fbr-pln-line.fbr-obj-code  and              c-fbr-pln-line.gds-code     = fbr-pln-line.gds-code      and              c-fbr-pln-line.recipe-code  = fbr-pln-line.recipe-code
on error undo, return error
:
      delete c-fbr-pln-line no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    delete fbr-pln-line.
    vDeleted = vDeleted + 1.
  end.
  define buffer fbr-history for ub.fbr-history.
on delete of ub.fbr-history override do: end.
for each fbr-history exclusive-lock
     where fbr-history.obj-type = fbr-pln.obj-type        and fbr-history.obj-code = fbr-pln.obj-code        and fbr-history.doc-code = fbr-pln.doc-code
on error undo, return error
:
      delete fbr-history no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
end procedure.
