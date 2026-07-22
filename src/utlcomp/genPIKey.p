block-level on error undo, throw.
define variable mOutFile as character no-undo.

function gen-key-rec character ( i-tbl-name    as character ):
   define variable v-inform         as character no-undo .
   define variable v-ind            as integer   no-undo .
   define variable v-idx-field-qnty as integer   no-undo .
    
   define variable oKeyField as character no-undo.

   if    i-tbl-name = ?
      or i-tbl-name = "":U
   then do:
      return error substitute( "Ошибка задания входных параметров. Не задано имя таблицы." ).
   end.
   define variable bh_tbl-name as handle no-undo.
   create buffer bh_tbl-name for table i-tbl-name no-error.
   if error-status:error
   then
      return error "Нет таблицы".
   assign
      v-inform  = bh_tbl-name:index-information(1)
      v-ind     = 2
   .
   do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
   on error undo, return error
   :
      assign
         v-inform = bh_tbl-name:index-information( v-ind )
         v-ind    = v-ind + 1
      .
   end.
   delete object bh_tbl-name.
   if    v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
   then do:
      return error substitute( "Таблица &1 не имеет первичного ключа в БД", i-tbl-name ).
   end.
   else do:
      v-idx-field-qnty = num-entries( v-inform ) - 4 .
      if v-idx-field-qnty < 2 then do:
         return error substitute( "Определенный первичный индекс (&1) не содержит списка полей для таблицы &2", v-inform, i-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
         oKeyField = oKeyField + entry( 4 + v-ind, v-inform, ",":U ) + " ".
      end.
  end.
  return oKeyField.
end . 

define variable vField as character no-undo.

mOutFile = replace (search(program-name (1)),"genPIKey.p","pikey.i").
output to value(mOutFile).
Block-file:
for each _file no-lock:
   if _file-name begins "_"
   then
      leave Block-file.
   vField = gen-key-rec(_file._file-name).
   if     vField ne ?
      and vField ne ""
   then
      put unformatted "&" + substitute ("glob &1_primary_key &2",_file._file-name,vField) skip.
end.
output close.

