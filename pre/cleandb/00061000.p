block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: Sep 17 2025  $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00061000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00061000.p $":U .
define variable vss-description as character no-undo init "Чистка УБД1.".
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
define buffer cd-doc            for ub.cd-doc.
define buffer buf_cd-doc        for ub.cd-doc.
define buffer cd-event-log      for ub.cd-event-log.
define buffer buf_cd-event-log  for ub.cd-event-log.
on delete of ub.cd-doc            override do: end.
on delete of ub.cd-event-log      override do: end.
for each buf_clients no-lock
    where buf_clients.db-num <> ?
:
  for each cd-doc no-lock where
           cd-doc.obj-type    = buf_clients.obj-type
       and cd-doc.obj-code    = buf_clients.obj-code
       and cd-doc.datekey_one < vardate-actual-docs
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    run cleanTable in this-procedure.
    find first buf_cd-doc exclusive-lock where
           recid(buf_cd-doc) = recid(cd-doc) no-error no-wait.
if not avail buf_cd-doc then
do:
  undo, return error "Ошибка удаления cd-doc. Запись занята другим пользователем.".
end.
delete buf_cd-doc.
vDeleted = vDeleted + 1.
  end.
  for each cd-event-log no-lock where
           cd-event-log.obj-type   = buf_clients.obj-type
       and cd-event-log.obj-code   = buf_clients.obj-code
       and cd-event-log.event-date < vardate-actual-docs
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    define buffer cd-event-log-attr for ub.cd-event-log-attr.
on delete of ub.cd-event-log-attr override do: end.
for each cd-event-log-attr exclusive-lock
    where cd-event-log-attr.db-num   = cd-event-log.db-num
         and cd-event-log-attr.trans-id = cd-event-log.trans-id
on error undo, return error
:
      delete cd-event-log-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    find first buf_cd-event-log exclusive-lock where
           recid(buf_cd-event-log) = recid(cd-event-log) no-error no-wait.
if not avail buf_cd-event-log then
do:
  undo, return error "Ошибка удаления cd-event-log. Запись занята другим пользователем.".
end.
delete buf_cd-event-log.
vDeleted = vDeleted + 1.
  end.
end.
vResult = substitute("Произведена чистка таблиц: &1~nУдалено записей - &2.", "Документы на кассе с историей", vDeleted).
return vResult.
procedure cleanTable :
  define buffer cd-doc-attr for ub.cd-doc-attr.
on delete of ub.cd-doc-attr override do: end.
for each cd-doc-attr exclusive-lock
    where cd-doc-attr.obj-type = cd-doc.obj-type       and cd-doc-attr.obj-code = cd-doc.obj-code       and cd-doc-attr.pos-type = cd-doc.pos-type       and cd-doc-attr.doc-type = cd-doc.doc-type       and cd-doc-attr.doc-code = cd-doc.doc-code
on error undo, return error
:
      delete cd-doc-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer cd-doc-line for ub.cd-doc-line.
on delete of ub.cd-doc-line override do: end.
for each cd-doc-line exclusive-lock
    where cd-doc-line.obj-type = cd-doc.obj-type       and cd-doc-line.obj-code = cd-doc.obj-code       and cd-doc-line.pos-type = cd-doc.pos-type       and cd-doc-line.doc-type = cd-doc.doc-type       and cd-doc-line.doc-code = cd-doc.doc-code
on error undo, return error
:
      delete cd-doc-line no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer cd-doc-line-attr for ub.cd-doc-line-attr.
on delete of ub.cd-doc-line-attr override do: end.
for each cd-doc-line-attr exclusive-lock
    where cd-doc-line-attr.obj-type = cd-doc.obj-type       and cd-doc-line-attr.obj-code = cd-doc.obj-code       and cd-doc-line-attr.pos-type = cd-doc.pos-type       and cd-doc-line-attr.doc-type = cd-doc.doc-type       and cd-doc-line-attr.doc-code = cd-doc.doc-code
on error undo, return error
:
      delete cd-doc-line-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-cd-doc for ub.c-cd-doc.
on delete of ub.c-cd-doc override do: end.
for each c-cd-doc exclusive-lock
    where c-cd-doc.obj-type = cd-doc.obj-type       and c-cd-doc.obj-code = cd-doc.obj-code       and c-cd-doc.pos-type = cd-doc.pos-type       and c-cd-doc.doc-type = cd-doc.doc-type       and c-cd-doc.doc-code = cd-doc.doc-code
on error undo, return error
:
      delete c-cd-doc no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-cd-doc-line for ub.c-cd-doc-line.
on delete of ub.c-cd-doc-line override do: end.
for each c-cd-doc-line exclusive-lock
    where c-cd-doc-line.obj-type = cd-doc.obj-type       and c-cd-doc-line.obj-code = cd-doc.obj-code       and c-cd-doc-line.pos-type = cd-doc.pos-type       and c-cd-doc-line.doc-type = cd-doc.doc-type       and c-cd-doc-line.doc-code = cd-doc.doc-code
on error undo, return error
:
      delete c-cd-doc-line no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
end procedure.
