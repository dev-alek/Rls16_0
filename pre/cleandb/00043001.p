block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 36493b7e3299, 155, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: Sep 15 2025 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00043000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00043000.p $".
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
define buffer trn-doc    for ub.trn-doc .
define buffer parts      for ub.parts .
define buffer buf_parts  for ub.parts .
define buffer free_parts for ub.parts .
on delete of ub.parts         override do: end.
for each parts no-lock where
         parts.out-code  = 'out-zone':U
     and (parts.fact-date < vardate-actual-docs
          or parts.fact-date = ?)
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  find first trn-doc no-lock where
             trn-doc.doc-code = parts.in-code
  no-error.
  if not avail trn-doc and
     not can-find(first free_parts where
                        free_parts.obj-type  = parts.obj-type
                    and free_parts.obj-code  = parts.obj-code
                    and free_parts.artic     = parts.artic
                    and free_parts.prod-type = parts.prod-type
                    and free_parts.prod-code = parts.prod-code
                    and free_parts.in-code   = parts.in-code
                    and free_parts.out-code  = 'free-zone':U
                    and free_parts.part-code = parts.part-code
                    and free_parts.fact-qnty > 0) then
  do:
    run cleanTable in this-procedure.
    find first buf_parts exclusive-lock where
           recid(buf_parts) = recid(parts) no-error no-wait.
if not avail buf_parts then
do:
  undo, return error "Ошибка удаления parts. Запись занята другим пользователем.".
end.
delete buf_parts.
vDeleted = vDeleted + 1.
  end.
end.
vResult = substitute("Произведена чистка таблиц: &1~nУдалено записей - &2.", "Партии. расходная зона", vDeleted).
return vResult.
procedure cleanTable:
  define buffer goods for ub.goods.
  for first goods no-lock where
            goods.artic     =  parts.artic
        and goods.prod-type =  parts.prod-type
        and goods.prod-code =  parts.prod-code
  :
    define buffer parts-attr for ub.parts-attr.
on delete of ub.parts-attr override do: end.
for each parts-attr exclusive-lock
    where parts-attr.in-code   = parts.in-code
         and parts-attr.gds-code  = goods.gds-code
         and parts-attr.part-code = parts.part-code
on error undo, return error
:
      delete parts-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer c-parts-attr for ub.c-parts-attr.
on delete of ub.c-parts-attr override do: end.
for each c-parts-attr exclusive-lock
    where c-parts-attr.in-code   = parts.in-code
         and c-parts-attr.gds-code  = goods.gds-code
         and c-parts-attr.part-code = parts.part-code
on error undo, return error
:
      delete c-parts-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  end.
  define buffer c-parts for ub.c-parts.
on delete of ub.c-parts override do: end.
for each c-parts exclusive-lock
    where c-parts.obj-type  = parts.obj-type
        and c-parts.obj-code  = parts.obj-code
        and c-parts.artic     = parts.artic
        and c-parts.prod-type = parts.prod-type
        and c-parts.prod-code = parts.prod-code
        and c-parts.in-code   = parts.in-code
        and c-parts.out-code  = parts.out-code
        and c-parts.part-code = parts.part-code
on error undo, return error
:
      delete c-parts no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
end procedure.
