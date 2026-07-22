block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: Nov 07 2025 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 01030000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/01030000.p $".
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
define buffer buf_tables         for ub._file.
define buffer buf_fields         for ub._field.
LOOP_TABLES:
for each buf_tables no-lock where
         buf_tables._file-name begins "c-"
:
  find first buf_fields no-lock where
             buf_fields._file-recid = recid(buf_tables)
         and buf_fields._field-name = "corr-date"
  no-error.
  if not avail buf_fields then
    next LOOP_TABLES.
  run cleanTable in this-procedure (buf_tables._file-name) no-error.
  if error-status:error then
    return error return-value.
end.
procedure cleanTable:
  define input parameter iTable as character no-undo.
  define variable vBuffer as handle no-undo.
  define variable vQuery  as handle no-undo.
  define variable vFor    as character no-undo.
  define variable vCnt    as int64 no-undo.
  create buffer vBuffer for table iTable.
  vBuffer:disable-load-triggers (false).
  create query vQuery.
  vQuery:set-buffers(vBuffer).
  vFor = substitute("FOR EACH &1 where &1.corr-date < &2",
                    vBuffer:name, vardate-actual-docs).
  vQuery:query-prepare(vFor) no-error.
  if error-status:error then
    return error error-status:get-message(1).
  vQuery:query-open().
  vQuery:get-first().
  if error-status:error then
    return error error-status:get-message(1).
  do while vBuffer:available:
    if valid-handle(varcall-back) and vCnt = 0 then
      run callback-write-to-log in varcall-back (
        input substitute("Чистка таблицы &1~n",iTable)
      ) no-error .
    do transaction:
       vBuffer:find-current (exclusive-lock).
       vBuffer:buffer-delete ().
    end.
    vCnt = vCnt + 1.
    if valid-handle(varcall-back) and vCnt mod 100000 = 0 then
    do:
      run callback-write-to-log in varcall-back (
        input Substitute("Удалено &1 записей~n", vCnt)
      ) no-error .
    end.
    vQuery:get-next().
  end.
  if valid-handle(varcall-back) and vCnt <> 0 then
    run callback-write-to-log in varcall-back (
      input Substitute("Удалено &1 записей~n", vCnt)
    ) no-error .
  vDeleted = vDeleted + vCnt.
end procedure.
vResult = substitute("Произведена чистка таблиц: &1~nУдалено записей - &2.", "История действий пользователя", vDeleted).
return vResult.
