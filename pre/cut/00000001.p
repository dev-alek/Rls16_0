block-level on error undo, throw.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define input parameter vartype-cut            as integer   no-undo.
define input parameter varlist-db             as character no-undo.
define input parameter vardate-actual-goods   as date      no-undo.
define input parameter vardate-actual-docs    as date      no-undo.
define input parameter vardate-actual-findoc  as date      no-undo.
define input parameter vardate-output-zone    as date      no-undo.
define input parameter varstay-recipe-goods   as logical   no-undo.
define input parameter varstay-weight-goods   as logical   no-undo.
define input parameter varnot-copy-del-goods  as logical   no-undo.
define input parameter varstay-history        as logical   no-undo.
define input parameter vargen-file            as character no-undo.
define stream str-gen.
output stream str-gen to vargen-file append.
if not connected("src") then do:
   return error "Нет коннекта с базой 'src'.".
end.
if not connected("dst") then do:
   return error "Нет коннекта с базой 'dst'.".
end.
find src.sys-ctrl no-lock.
if not available src.sys-ctrl then do:
   return error "В базе данных src не найдена уникальная запись sys-ctrl.".
end.
if src.sys-ctrl.db-num <> 0 then do:
   return error "Пакет обрезания работает только в главной базе данных. В данной версии удаленные БД создаются выгрузкой из главных.".
end.
if vardate-actual-docs <> ? and
   (vardate-actual-goods   > vardate-actual-docs or
    vardate-actual-goods   = ? )   then do:
      return error SUBSTITUTE("Ошибка при задании дат актуальности." +
                              "Дата актуальности товаров &1."        +
                              "Дата актуальности документов &2."     +
                              "Дата актуальности документов должна быть больше или равна дат актуальностей товаров.",
                              vardate-actual-goods,
                              vardate-actual-docs).
end.
define buffer new_file for dst._file.
define buffer newflt_file for ubfltdst._file.
define variable v-ok as logical no-undo .
define variable v-skip-tables as character no-undo .
define variable v-skip-flt-tables as character no-undo .
for each new_file no-lock
  where new_file._hidden = false
:
  if lookup(new_file._file-name, v-skip-tables) > 0 then next.
  run check-clear in this-procedure ( input "dst." + new_file._file-name
                                     ,output v-ok) no-error.
  if error-status:error then do:
    return error substitute("Ошибка при проверке пуста ли таблица &1 в БД-приемнике", new_file._file-name).
  end.
  if not v-ok then do:
    return error substitute("База данных dst не пуста. Eсть записи в таблице &1", new_file._file-name).
  end.
end.
if sdbname( "ubfltdst" ) <> sdbname( "dst" ) then do:
  for each newflt_file no-lock
    where newflt_file._hidden = false
  :
    if lookup(newflt_file._file-name, v-skip-flt-tables) > 0 then next.
    run check-clear in this-procedure ( input "ubfltdst." + newflt_file._file-name
                                       ,output v-ok) no-error.
    if error-status:error then do:
      return error substitute("Ошибка при проверке пуста ли таблица &1 в БД-приемнике для фильтров", newflt_file._file-name).
    end.
    if not v-ok then do:
      return error substitute("База данных ubfltdst не пуста. Eсть записи в таблице &1", newflt_file._file-name).
    end.
  end.
end.
output stream str-gen close.
return "Проверили, что все таблицы в базе данных dst пусты.".
end.
procedure check-clear :
define input parameter p-tbl-name as character no-undo .
define output parameter p-ok as logical no-undo .
define variable v-bh as handle no-undo .
do
on error undo, return error
:
  create buffer v-bh for table p-tbl-name.
  v-ok = v-bh:find-first( " where true ") no-error.
  if v-bh:available then do:
    delete widget v-bh.
  end.
  else do:
    delete widget v-bh.
    p-ok = yes.
  end.
end.
end procedure.
