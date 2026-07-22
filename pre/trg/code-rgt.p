block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "библиотека для работы с записями code-range".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info0 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info0, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info0, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info0, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info0, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info0 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info0, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info0 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info0, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info0, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info0, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info0, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info0, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info0, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info0 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info0 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info0, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info0, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info0, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info0 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info0 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info0, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info0, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
define temp-table temp-clients no-undo like ub.clients.
procedure comm-crush-cdrg :
  define input  parameter pc-db-num       like ub.db-rec-attr.db-num       no-undo .
  define input  parameter pc-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
  define input  parameter pc-attr-code    like ub.db-rec-attr.attr-code    no-undo .
  define input  parameter pc-parameters   as   character                   no-undo .
  define output parameter pc-err-msg      as   character                   no-undo .
  do
  on error undo, return error
  :
    define buffer buf_code-range  for ub.code-range .
    define variable v-rowid    as rowid     no-undo .
    define variable v-tbl-name as character no-undo .
    run gen-row-keyr in this-procedure
      ( input  pc-uniq-key-rec
       ,input ?
       ,input "ub":U
       ,input ?
       ,input share-lock
       ,output v-rowid
       ,output v-tbl-name
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при определении rowid записи для ключа &2. &3 &4", vss-workfile, pc-uniq-key-rec, chr(10), return-value ).
    end.
    if v-tbl-name <> 'code-range':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей диапазонов кодов", vss-workfile ).
    end.
    find first buf_code-range
      where rowid( buf_code-range ) = v-rowid
      no-error .
    if not available buf_code-range then do:
      return error substitute( "&1. Нет необходимого диапазона кодов &2", vss-workfile, pc-uniq-key-rec ).
    end.
    if buf_code-range.range-type = entry( 1, pc-parameters, chr(4) )
       and buf_code-range.first-code = integer( entry( 2, pc-parameters, chr(4) ) )
       and buf_code-range.last-code = integer( entry( 3, pc-parameters, chr(4) ) )
    then do:
      if buf_code-range.stts = "u":U then do:
        assign
          buf_code-range.PS   = buf_code-range.stts + chr(4) + "Диапазон заблокирован" + chr(4) + buf_code-range.PS
          buf_code-range.stts = "c":U
        .
      end.
      else do:
        if buf_code-range.stts = "c":U
          and num-entries( buf_code-range.PS, chr(4) ) >= 3
        then do:
          assign
            pc-err-msg = substitute( "Диапазон &1 уже заблокирован!!! Блокировка невозможна!!!", pc-uniq-key-rec )
          .
        end.
        else do:
          assign
            pc-err-msg = substitute( "Диапазон &1 имеет статус &2. Блокировка невозможна!!!", pc-uniq-key-rec, buf_code-range.stts )
          .
        end.
      end.
    end.
    else do:
      return error substitute( "&1. Обнаружено фатальное отличие диапазонов", vss-workfile )
                   + chr(10)
                   + substitute( "Должно быть: тип &1 начало &2 конец &3", entry( 1, pc-parameters, chr(4) )
                                                                         , entry( 2, pc-parameters, chr(4) )
                                                                         , entry( 3, pc-parameters, chr(4) ) )
                   + chr(10)
                   + substitute( "В текущей БД: тип &1 начало &2 конец &3", buf_code-range.range-type
                                                                          , buf_code-range.first-code
                                                                          , buf_code-range.last-code )
      .
    end.
  end.
  return.
end procedure.
procedure exec-crush-cdrg :
  define input  parameter pe-db-num       like ub.db-rec-attr.db-num       no-undo .
  define input  parameter pe-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
  define input  parameter pe-attr-code    like ub.db-rec-attr.attr-code    no-undo .
  define input  parameter pe-parameters   as   character                   no-undo .
  define output parameter pe-err-msg      as   character                   no-undo .
  do
  on error undo, return error
  :
    define buffer buf_code-range     for ub.code-range .
    define buffer buf-new_code-range for ub.code-range .
    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v-new-range-length as integer   no-undo .
    define variable v-range-type       as character no-undo .
    define variable v-old-first-code   as integer   no-undo .
    define variable v-old-last-code    as integer   no-undo .
    define variable v-new-first-code   as integer   no-undo .
    define variable v-new-last-code    as integer   no-undo .
    run gen-row-keyr in this-procedure
      ( input  pe-uniq-key-rec
       ,input ?
       ,input "ub":U
       ,input ?
       ,input share-lock
       ,output v-rowid
       ,output v-tbl-name
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при определении rowid записи для ключа &2. chr(10) &3", vss-workfile, pe-uniq-key-rec, return-value ).
    end.
    if v-tbl-name <> 'code-range':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей диапазонов кодов", vss-workfile ).
    end.
    find first buf_code-range
      where rowid( buf_code-range ) = v-rowid
      no-error .
    if not available buf_code-range then do:
      return error substitute( "&1. Нет необходимого диапазона кодов &2", vss-workfile, pe-uniq-key-rec ).
    end.
    if buf_code-range.stts <> "c":U then do:
      return error substitute( "&1. Диапазон кодов &2 не заблокирован", vss-workfile, pe-uniq-key-rec ).
    end.
    assign
      v-range-type             = entry( 1, pe-parameters, chr(4) )
      v-old-first-code         = integer( entry( 2, pe-parameters, chr(4) ) )
      v-old-last-code          = integer( entry( 3, pe-parameters, chr(4) ) )
      v-new-range-length       = integer( entry( 4, pe-parameters, chr(4) ) )
      buf_code-range.last-code = buf_code-range.first-code - 1 + v-new-range-length
      v-new-first-code         = buf_code-range.last-code + 1
      v-new-last-code          = v-new-first-code - 1 + v-new-range-length
    .
    do while v-new-first-code < v-old-last-code
    on error undo, return error
    :
      if v-new-last-code > v-old-last-code then do:
        assign
          v-new-last-code = v-old-last-code
        .
      end.
      create buf-new_code-range .
      buffer-copy buf_code-range to buf-new_code-range
        assign
          buf-new_code-range.stts       = "c":U
          buf-new_code-range.first-code = v-new-first-code
          buf-new_code-range.last-code  = v-new-last-code
      .
      assign
        v-new-first-code = buf-new_code-range.last-code + 1
        v-new-last-code  = v-new-first-code - 1 + v-new-range-length
      .
    end.
    for each buf_code-range
      where buf_code-range.range-type = v-range-type
        and buf_code-range.first-code >= v-old-first-code
        and buf_code-range.first-code <  v-old-last-code
    on error undo, return error
    :
      assign
        buf_code-range.stts = entry( 1, buf_code-range.PS, chr(4) )
        buf_code-range.PS   = "Диапазон получен разбиением"
      .
    end.
  end.
  return.
end procedure.
procedure rcvr-crush-cdrg :
  define input  parameter pr-db-num       like ub.db-rec-attr.db-num       no-undo .
  define input  parameter pr-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
  define input  parameter pr-attr-code    like ub.db-rec-attr.attr-code    no-undo .
  define input  parameter pr-parameters   as   character                   no-undo .
  define output parameter pr-err-msg      as   character                   no-undo .
  do
  on error undo, return error
  :
    define buffer buf_db-rec-attr    for ub.db-rec-attr .
    define buffer buf_code-range     for ub.code-range .
    define buffer buf-del_code-range for ub.code-range .
    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v-range-type       as character no-undo .
    define variable v-old-first-code   as integer   no-undo .
    define variable v-old-last-code    as integer   no-undo .
    define variable v-update-cdrg      as logical   no-undo .
    run gen-row-keyr in this-procedure
      ( input  pr-uniq-key-rec
       ,input ?
       ,input "ub":U
       ,input ?
       ,input share-lock
       ,output v-rowid
       ,output v-tbl-name
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при определении rowid записи для ключа &2. chr(10) &3", vss-workfile, pr-uniq-key-rec, return-value ).
    end.
    if v-tbl-name <> 'code-range':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей диапазонов кодов", vss-workfile ).
    end.
    find first buf_code-range
      where rowid( buf_code-range ) = v-rowid
      no-error .
    if not available buf_code-range then do:
      return error substitute( "&1. Нет необходимого диапазона кодов &2", vss-workfile, pr-uniq-key-rec ).
    end.
    assign
      v-range-type             = entry( 1, pr-parameters, chr(4) )
      v-old-first-code         = integer( entry( 2, pr-parameters, chr(4) ) )
      v-old-last-code          = integer( entry( 3, pr-parameters, chr(4) ) )
    .
    assign
      v-update-cdrg = false
    .
    if buf_code-range.stts = "c":U then do:
      assign
        v-update-cdrg = true
      .
    end.
    else do:
      if buf_code-range.last-code <> v-old-last-code then do:
        for each buf-del_code-range
          where buf-del_code-range.range-type = v-range-type
            and buf-del_code-range.first-code > v-old-first-code
            and buf-del_code-range.first-code < v-old-last-code
        on error undo, return error
        :
          assign
            buf-del_code-range.stts = "c":U
          .
          delete buf-del_code-range .
        end.
        assign
          buf_code-range.PS        = buf_code-range.stts + chr(4) + chr(4) + buf_code-range.PS
          buf_code-range.stts      = "c":U
          buf_code-range.last-code = v-old-last-code
          v-update-cdrg            = true
        .
      end.
    end.
    if v-update-cdrg = true then do:
      assign
        buf_code-range.stts = entry( 1, buf_code-range.PS, chr(4) )
        buf_code-range.PS   = entry( 3, buf_code-range.PS, chr(4) )
      .
    end.
  end.
  return.
end procedure.
procedure comm-del-cdrg :
  define input  parameter pc-db-num       like ub.db-rec-attr.db-num       no-undo .
  define input  parameter pc-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
  define input  parameter pc-attr-code    like ub.db-rec-attr.attr-code    no-undo .
  define input  parameter pc-parameters   as   character                   no-undo .
  define output parameter pc-err-msg      as   character                   no-undo .
  do
  on error undo, return error
  :
    define buffer buf_db-rec-attr for ub.db-rec-attr .
    define buffer buf_code-range  for ub.code-range .
    define variable v-rowid    as rowid     no-undo .
    define variable v-tbl-name as character no-undo .
    define variable v-old-stts as character no-undo .
    define variable v-old-ps as character no-undo .
    define variable l-has-prevention as logical no-undo .
    find first buf_db-rec-attr exclusive-lock
      where buf_db-rec-attr.db-num       = pc-db-num
        and buf_db-rec-attr.uniq-key-rec = pc-uniq-key-rec
        and buf_db-rec-attr.attr-code    = pc-attr-code
    no-error.
    run gen-row-keyr in this-procedure
      ( input  pc-uniq-key-rec
       ,input ?
       ,input "ub":U
       ,input ?
       ,input share-lock
       ,output v-rowid
       ,output v-tbl-name
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при определении rowid записи для ключа &2. chr(10) &3", vss-workfile, pc-uniq-key-rec, return-value ).
    end.
    if v-tbl-name <> 'code-range':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей диапазонов кодов", vss-workfile ).
    end.
    find first buf_code-range
      where rowid( buf_code-range ) = v-rowid
      no-error .
    if not available buf_code-range then do:
      return error substitute( "&1. Нет необходимого диапазона кодов &2", vss-workfile, pc-uniq-key-rec ).
    end.
    if buf_code-range.range-type = entry( 1, pc-parameters, chr(4) )
       and buf_code-range.first-code = integer( entry( 2, pc-parameters, chr(4) ) )
       and buf_code-range.last-code = integer( entry( 3, pc-parameters, chr(4) ) )
    then do:
      if ( buf_code-range.stts = "u":U
          or buf_code-range.stts = "f":U
          or buf_code-range.stts = "a":U
        )
      then do:
        assign
        v-old-stts = buf_code-range.stts
          buf_code-range.stts = "c":U
        .
        l-has-prevention = yes.
        run proc-has-prevention in this-procedure ( buffer buf_code-range, output l-has-prevention) no-error.
        if error-status:error then do:
          undo, return error substitute( "&1. Ошибка при поиске препятствий удаления диапазона с типом &2 для БД &3 (&4-&5):&6&7&6&8"
                                        , vss-workfile
                                        , buf_code-range.range-type
                                        , buf_code-range.db-num
                                        , buf_code-range.first-code
                                        , buf_code-range.last-code
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , return-value
                                        ).
        end.
        if l-has-prevention then do:
          assign
          buf_code-range.stts = v-old-stts
          buf_code-range.ps = v-old-ps
          pc-err-msg = substitute( "&1. Есть препятствия удалению диапазона с типом &2 для БД &3 (&4-&5):&6&7&6&8"
                                  , vss-workfile
                                  , buf_code-range.range-type
                                  , buf_code-range.db-num
                                  , buf_code-range.first-code
                                  , buf_code-range.last-code
                                  , chr(10)
                                  , error-status:get-message(1)
                                  , return-value
                                  ).
          return pc-err-msg.
      end.
      end.
      else do:
        assign
          pc-err-msg = substitute( "Блокировка записи &1 невозможна!!!", pc-uniq-key-rec )
        .
      end.
    end.
    else do:
      return error substitute( "&1. Обнаружено фатальное отличие диапазонов", vss-workfile )
                   + chr(10)
                   + substitute( "Должно быть: тип &1 начало &2 конец &3", entry( 1, pc-parameters, chr(4) )
                                                                         , entry( 2, pc-parameters, chr(4) )
                                                                         , entry( 3, pc-parameters, chr(4) ) )
                   + chr(10)
                   + substitute( "В текущей БД: тип &1 начало &2 конец &3", buf_code-range.range-type
                                                                          , buf_code-range.first-code
                                                                          , buf_code-range.last-code )
      .
    end.
  end.
  return.
end procedure.
procedure exec-del-cdrg :
  define input  parameter pe-db-num       like ub.db-rec-attr.db-num       no-undo .
  define input  parameter pe-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
  define input  parameter pe-attr-code    like ub.db-rec-attr.attr-code    no-undo .
  define input  parameter pe-parameters   as   character                   no-undo .
  define output parameter pe-err-msg      as   character                   no-undo .
  do
  on error undo, return error
  :
    define buffer buf_code-range     for ub.code-range .
    define buffer buf-new_code-range for ub.code-range .
    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v-new-range-length as integer   no-undo .
    define variable v-range-type       as character no-undo .
    define variable v-stts         as character no-undo .
    define variable v-db-num as integer no-undo .
    define variable v-ps as character no-undo .
    define variable v-first-code   as integer   no-undo .
    define variable v-last-code    as integer   no-undo .
    define variable l-has-prevention as logical no-undo .
    run gen-row-keyr in this-procedure
      ( input  pe-uniq-key-rec
       ,input ?
       ,input "ub":U
       ,input ?
       ,input share-lock
       ,output v-rowid
       ,output v-tbl-name
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при определении rowid записи для ключа &2. chr(10) &3", vss-workfile, pe-uniq-key-rec, return-value ).
    end.
    if v-tbl-name <> 'code-range':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей диапазонов кодов", vss-workfile ).
    end.
    find first buf_code-range
      where rowid( buf_code-range ) = v-rowid
      no-error .
    if not available buf_code-range then do:
      return error substitute( "&1. Нет необходимого диапазона кодов &2", vss-workfile, pe-uniq-key-rec ).
    end.
    if buf_code-range.stts <> "c":U then do:
      return error substitute( "&1. Диапазон кодов &2 не заблокирован", vss-workfile, pe-uniq-key-rec ).
    end.
    assign
    v-range-type         = entry( 1, pe-parameters, chr(4) )
    v-first-code         = integer( entry( 2, pe-parameters, chr(4) ) )
    v-last-code          = integer( entry( 3, pe-parameters, chr(4) ) )
    v-stts               = entry( 4, pe-parameters, chr(4) )
    v-db-num             = integer( entry( 5, pe-parameters, chr(4) ) )
    v-ps                 = entry( 6, pe-parameters, chr(4) )
    .
    l-has-prevention = yes.
    run proc-has-prevention in this-procedure ( buffer buf_code-range, output l-has-prevention) no-error.
    if error-status:error then do:
      undo, return error substitute( "&1. Ошибка при поиске препятствий удаления диапазона с типом &2 для БД &3 (&4-&5):&6&7&6&8"
                                    , vss-workfile
                                    , buf_code-range.range-type
                                    , buf_code-range.db-num
                                    , buf_code-range.first-code
                                    , buf_code-range.last-code
                                    , chr(10)
                                    , error-status:get-message(1)
                                    , return-value
                                    ).
    end.
    if l-has-prevention then do:
      assign
      buf_code-range.stts = v-stts
      pe-err-msg = substitute( "&1. Есть препятствия удалению диапазона с типом &2 для БД &3 (&4-&5):&6&7&6&8"
                              , buf_code-range.range-type
                              , buf_code-range.db-num
                              , buf_code-range.first-code
                              , buf_code-range.last-code
                              , chr(10)
                              , error-status:get-message(1)
                              , return-value
                              ).
      undo, return error substitute( "&1. Ошибка при поиске препятствий удаления диапазона с типом &2 для БД &3 (&4-&5):&6&7&6&8"
                                    , vss-workfile
                                    , buf_code-range.range-type
                                    , buf_code-range.db-num
                                    , buf_code-range.first-code
                                    , buf_code-range.last-code
                                    , chr(10)
                                    , error-status:get-message(1)
                                    , return-value
                                    ).
    end.
    on delete of ub.code-range override do: end.
    delete buf_code-range no-error.
    if error-status:error then do:
      undo, return error substitute( "&1. Ошибка при удаления диапазона с типом &2 для БД &3 (&4-&5):&6&7&6&8"
                                    , vss-workfile
                                    , buf_code-range.range-type
                                    , buf_code-range.db-num
                                    , buf_code-range.first-code
                                    , buf_code-range.last-code
                                    , chr(10)
                                    , error-status:get-message(1)
                                    , return-value
                                    ).
    end.
    on delete of ub.code-range revert.
  end.
  return.
end procedure.
procedure rcvr-del-cdrg :
  define input  parameter pr-db-num       like ub.db-rec-attr.db-num       no-undo .
  define input  parameter pr-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
  define input  parameter pr-attr-code    like ub.db-rec-attr.attr-code    no-undo .
  define input  parameter pr-parameters   as   character                   no-undo .
  define output parameter pr-err-msg      as   character                   no-undo .
  do
  on error undo, return error
  :
    define buffer buf_db-rec-attr    for ub.db-rec-attr .
    define buffer buf_code-range     for ub.code-range .
    define buffer buf-del_code-range for ub.code-range .
    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v-range-type       as character no-undo .
    define variable v-first-code   as integer   no-undo .
    define variable v-last-code    as integer   no-undo .
    define variable v-db-num as integer no-undo .
    define variable v-stts as character no-undo .
    define variable v-ps as character no-undo .
    define variable v-update-cdrg      as logical   no-undo .
    run gen-row-keyr in this-procedure
      ( input  pr-uniq-key-rec
       ,input ?
       ,input "ub":U
       ,input ?
       ,input share-lock
       ,output v-rowid
       ,output v-tbl-name
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при определении rowid записи для ключа &2. chr(10) &3", vss-workfile, pr-uniq-key-rec, return-value ).
    end.
    if v-tbl-name <> 'code-range':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей диапазонов кодов", vss-workfile ).
    end.
    find first buf_code-range
      where rowid( buf_code-range ) = v-rowid
      no-error .
    assign
    v-range-type        = entry( 1, pr-parameters, chr(4) )
    v-first-code        = integer( entry( 2, pr-parameters, chr(4) ) )
    v-last-code         = integer( entry( 3, pr-parameters, chr(4) ) )
    v-stts              =  entry( 4, pr-parameters, chr(4) )
    v-db-num            = integer(entry( 5, pr-parameters, chr(4) ))
    v-ps                = entry( 6, pr-parameters, chr(4) )
    .
    if not available buf_code-range then do:
      find first buf_code-range exclusive-lock where
                 buf_code-range.range-type = v-range-type
             and buf_code-range.first-code = v-first-code     no-error no-wait.
      if not available buf_code-range
      AND not LOCKED(buf_code-range)
      then do:
        find first buf_code-range no-lock where
                 buf_code-range.range-type = v-range-type
            and  buf_code-range.first-code = v-first-code  no-error.
        if not available buf_code-range then do:
          create buf_code-range.
          assign
          buf_code-range.range-type = v-range-type
          buf_code-range.db-num = v-db-num
          buf_code-range.first-code = v-first-code
          buf_code-range.last-code = v-last-code
          buf_code-range.ps = v-ps
          .
          release buf_code-range no-error.
          if error-status:error then do:
            undo, return error substitute( "&1. Ошибка при восстановлении диапазона с типом &2 для БД &3 (&4-&5):&6&7&6&8"
                                          , vss-workfile
                                          , v-range-type
                                          , v-db-num
                                          , v-first-code
                                          , v-last-code
                                          , chr(10)
                                          , error-status:get-message(1)
                                          , return-value
                                          ).
          end.
          return .
        end.
        else do:
          if buf_code-range.db-num <> v-db-num
          or buf_code-range.last-code <> v-last-code then do:
            undo, return error substitute( "&1. Ошибка при восстановлении диапазона с типом &2 для БД &3 (&4-&5):&6" +
                                           "Восстанавливаемый диапазон отличается от исходного (БД = &7 верхняя граница 8)"
                                          , vss-workfile
                                          , v-range-type
                                          , v-db-num
                                          , v-first-code
                                          , v-last-code
                                          , chr(10)
                                          , v-db-num
                                          , v-last-code
                                          ).
          end.
        end.
      end.
    end.
    else do:
      if buf_code-range.db-num <> v-db-num
      or buf_code-range.last-code <> v-last-code then do:
        undo, return error substitute( "&1. Ошибка при восстановлении диапазона с типом &2 для БД &3 (&4-&5):&6" +
                                        "Имеющийся восстанавливаемый диапазон отличается от исходного (БД = &7 верхняя граница 8)"
                                      , vss-workfile
                                      , v-range-type
                                      , v-db-num
                                      , v-first-code
                                      , v-last-code
                                      , chr(10)
                                      , v-db-num
                                      , v-last-code
                                      ).
      end.
    end.
    do
    on error undo, return error
    on stop undo, return error
    :
      if buf_code-range.stts <> v-stts then do:
        assign
        buf_code-range.stts = v-stts
        .
        release buf_code-range no-error.
        if error-status:error then do:
            undo, return error substitute( "&1. Ошибка при восстановлении диапазона с типом &2 для БД &3 (&4-&5):&6&7&6&8"
                                          , vss-workfile
                                          , v-range-type
                                          , v-db-num
                                          , v-first-code
                                          , v-last-code
                                          , chr(10)
                                          , error-status:get-message(1)
                                          , return-value
                                          ).
        end.
      end.
    end.
  end.
  return.
end procedure.
procedure proc-has-prevention :
define parameter buffer buf_code-range for ub.code-range.
define output parameter p-has-prevention as logical no-undo init yes.
define buffer buf_clients for ub.clients.
define variable l-prod-bc-weight as logical no-undo .
define variable l-prod-bc-global as logical no-undo .
define variable l-prod-bc-pgweight as logical no-undo .
define buffer buf_sys-ctrl for ub.sys-ctrl.
define buffer buf_prod-bc for ub.prod-bc.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not available buf_code-range then do:
    undo, return error substitute("Не определен диапазон").
  end.
  find first buf_sys-ctrl.
  case buf_code-range.range-type:
    when 'sclc':U
    or when 'pglc':U
    or when 'scgb':U
    then do:
      empty temp-table temp-clients.
      for each buf_clients no-lock where
              buf_clients.db-num = buf_sys-ctrl.db-num
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :
        create temp-clients.
        buffer-copy buf_clients to temp-clients.
        release temp-clients.
      end.
      for each buf_prod-bc no-lock where
              buf_prod-bc.b-str >= string(buf_code-range.first-code, "99999")
          and buf_prod-bc.b-str <= string(buf_code-range.last-code, "99999")
          and length(buf_prod-bc.b-str) = 5
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :
        assign
        l-prod-bc-global = ?
        l-prod-bc-weight = ?
        l-prod-bc-pgweight = ?
        .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer buf_prod-bc
  ,input  'global=request':u
  ,output l-prod-bc-global
  ) no-error .
        if buf_code-range.range-type = 'scgb':U
        or buf_code-range.range-type = 'sclc':U then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer buf_prod-bc
  ,input  'weight=request':u
  ,output l-prod-bc-weight
  ) no-error .
        end.
        if buf_code-range.range-type = 'pglc':U then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer buf_prod-bc
  ,input  'pgweight=request':u
  ,output l-prod-bc-weight
  ) no-error .
        end.
        case buf_code-range.range-type:
          when 'sclc':U then do:
            if l-prod-bc-weight = yes
            and l-prod-bc-global = no then do:
              return substitute("prod-bc ДопБК &1" + buf_prod-bc.b-str).
            end.
          end.
          when 'pglc':U then do:
            if l-prod-bc-pgweight = yes
            and l-prod-bc-global = no then do:
              return substitute("prod-bc ДопБК &1" + buf_prod-bc.b-str).
            end.
          end.
          when 'scgb':U then do:
            if l-prod-bc-weight = yes
            and l-prod-bc-global = yes then do:
              return substitute("prod-bc ДопБК &1" + buf_prod-bc.b-str).
            end.
          end.
        end case.
      end.
      p-has-prevention = no.
    end.
    otherwise do:
      return.
    end.
  end case.
end.
end procedure.
