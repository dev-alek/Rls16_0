block-level on error undo, throw.
/*

Чистка БД. Таблицы истории. 

Автор: Ростовцев Александр
Дата создания: 07/11/2025
Author: Aleksandr Rostovtsev
Creation date: 11/07/25
*/

&scop Tables История действий пользователя
/*&scop Tables c-user-log ~*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: Nov 07 2025 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 01030000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/01030000.p $".
define variable vss-description as character no-undo init "Чистка УБД..".
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cleandb/defs.i }

define buffer buf_tables         for ub._file.
define buffer buf_fields         for ub._field.

/*run gbl/inidebug.p.*/

LOOP_TABLES:
for each buf_tables no-lock where
         buf_tables._file-name begins "c-"
:
  find first buf_fields no-lock where
             buf_fields._file-recid = recid(buf_tables)
         and buf_fields._field-name = "corr-date"
  no-error.
  if not avail buf_fields then
  /* если в таблице истории нет поля даты корректировки, то пропускаем  */
  /* предполагаем, эти таблицы должны чиститься в "кусте" */
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

{cleandb/setresval.i}
return vResult.
