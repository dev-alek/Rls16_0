block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: b1849e93de2b, 967, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 03/10/2025":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00994000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00994000.p $".
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
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-bh as handle no-undo .
define variable lob-reslist-date-egais as character no-undo .
define variable v-ii as integer no-undo .
define variable v-entry as character no-undo .
define variable v-doc-code as character no-undo .
define buffer clob-bind     for ub.clob-bind.
define buffer buf_clob-bind for ub.clob-bind.
define buffer clob-data     for ub.clob-data.
on delete of ub.clob-bind             override do: end.
on delete of ub.clob-data             override do: end.
lob-reslist-date-egais = 'egais-ab':U + chr(44) + 'egais-awo':U + chr(44)
  + chr(44) + 'egais-ab_shop':U + chr(44) + 'egais-awo_shop':U.
do v-ii = 1 to num-entries(lob-reslist-date-egais):
  v-entry = entry(v-ii, lob-reslist-date-egais).
  cicl0_:
  for each clob-bind no-lock where
           clob-bind.resource-type = v-entry
       and clob-bind.sys-date      < vardate-actual-docs
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    for each clob-data exclusive-lock where
             clob-data.db-num = clob-bind.db-num
         and clob-data.int64-id = clob-bind.int64-id
    :
      delete clob-data.
      vDeleted = vDeleted + 1.
    end.
    find first buf_clob-bind exclusive-lock where
           recid(buf_clob-bind) = recid(clob-bind) no-error no-wait.
if not avail buf_clob-bind then
do:
  undo, return error "Ошибка удаления clob-bind. Запись занята другим пользователем.".
end.
delete buf_clob-bind.
vDeleted = vDeleted + 1.
  end.
end.
vResult = substitute("Произведена чистка таблиц: &1~nУдалено записей - &2.", "Двоичные данные документов", vDeleted).
return vResult.
