block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создание и обработка кустовых команд".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info1 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info1, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info1, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info1, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info1, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info1 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info1, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info1 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info1, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info1, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info1, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info1, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info1, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info1, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info1 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info1 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info1, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info1, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info1, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info1 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info1 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info1, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info1, v-inform, v-tbl-name ).
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
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table t-raw no-undo
  field t-raw-field as raw
.
procedure cre-raw :
  define input  parameter p-tbl-name   as character no-undo.
  define input  parameter p-tbl-handle as handle    no-undo.
  define output parameter p-raw        as raw       no-undo.
  define variable bh_t-raw        as handle    no-undo .
  define variable v-ok            as logical   no-undo .
  define variable v-msg           as character no-undo .
    define variable tth             as handle    no-undo .
    define variable tt-name         as character no-undo .
    define variable bh_tt           as handle    no-undo .
  do
  on error  undo, throw
  :
    create temp-table tth.
    assign
      tth:undo = false
      tt-name  = "tt_" + p-tbl-handle:table
    .
    v-ok = tth:create-like( p-tbl-handle ) .
    v-ok = tth:temp-table-prepare( tt-name ) .
    bh_tt = tth:default-buffer-handle .
    v-ok = bh_tt:buffer-create .
    v-ok = bh_tt:buffer-copy( p-tbl-handle ) .
    empty temp-table t-raw .
    create t-raw.
    bh_t-raw = buffer t-raw:handle .
    v-ok =        bh_tt:raw-transfer ( true, bh_t-raw:buffer-field("t-raw-field":U) ) .
    p-raw = t-raw.t-raw-field .
  catch exAppErrors as class Progress.Lang.AppError :
    v-msg = substitute( "&1 (cre-raw). raw-transfer не прошел для таблицы &2&3&4&3&5",
      vss-include-info2,
      p-tbl-name,
      chr(10),
      error-status:get-message (error-status:num-messages),
      exAppErrors:CallStack
    ) .
    undo, throw new Progress.Lang.AppError(v-msg)  .
  end catch .
  catch exProErrors as class Progress.Lang.ProError :
    undo, throw exProErrors .
  end catch .
  catch exAnyErrors as class Progress.Lang.Error:
    undo, throw exAnyErrors .
  end catch .
  finally :
    empty temp-table t-raw .
    v-ok = tth:clear() no-error .
    delete object tth.
  end finally .
  end.
end procedure.
procedure cre-raw-delta :
  define input  parameter p-tbl-name       as character no-undo.
  define input  parameter p-old-raw        as raw       no-undo.
  define input  parameter p-new-buf-handle as handle    no-undo.
  define output parameter p-raw            as raw       no-undo.
  do
  on error  undo, return error substitute( "&1 (cre-raw-delta). &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-raw-delta). stop", vss-include-info2 )
  on endkey undo, return error substitute( "&1 (cre-raw-delta). endkey", vss-include-info2 )
  :
    define variable tt-name         as character no-undo .
    define variable tth             as handle    no-undo .
    define variable bh-dlt_tt       as handle    no-undo .
    define variable bh-old_tt       as handle    no-undo .
    define variable bh_t-raw        as handle    no-undo .
    define variable v-num-fields    as integer   no-undo .
    define variable v-ind           as integer   no-undo .
    define variable v-name-field    as character no-undo .
    define variable v-fh-tt         as handle    no-undo .
    define variable v-fh-old        as handle    no-undo .
    define variable v-fh-new        as handle    no-undo .
    define variable v-ok            as logical   no-undo .
    if not p-new-buf-handle:available then do:
      return error substitute( "&1 (cre-raw-delta). Переданый буфер с новым значением таблицы &2 не доступен", vss-include-info2, p-tbl-name ).
    end.
    if p-old-raw = ?
    then do:
      return error substitute( "&1 (cre-raw-delta). Переданый буфер со старым значением таблицы &2 не доступен", vss-include-info2, p-tbl-name ).
    end.
    create temp-table tth.
    assign
      tth:undo = false
      tt-name  = "tt_" + p-tbl-name
    .
    assign
      v-ok = tth:create-like( p-new-buf-handle ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (cre-raw-delta). Ошибка при создании временной таблицы &2 (1)", vss-include-info2, tt-name ) .
    end.
    assign
      v-ok = tth:temp-table-prepare( tt-name ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (cre-raw-delta). Ошибка при создании временной таблицы &2 (2)", vss-include-info2, tt-name ) .
    end.
    assign
      bh-dlt_tt = tth:default-buffer-handle
    .
    assign
      v-ok = bh-dlt_tt:buffer-create no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (cre-raw-delta). Ошибка при создании буфера временной таблицы для новых значений.", vss-include-info2, p-tbl-name ).
    end.
    create buffer bh-old_tt for table tth.
    assign
      v-ok = bh-old_tt:buffer-create no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (cre-raw-delta). Ошибка при создании буфера временной таблицы для старых значений.", vss-include-info2, p-tbl-name ).
    end.
    create t-raw.
    assign
      t-raw.t-raw-field = p-old-raw
      bh_t-raw          = buffer t-raw:handle
    .
    assign
      v-ok = bh-old_tt:raw-transfer ( false, bh_t-raw:buffer-field("t-raw-field":U) ) no-error
    .
    delete t-raw.
    if v-ok <> true then do:
      return error substitute( "&1 (cre-raw-delta). raw-transfer не прошел для таблицы &2 со старыми значениями", vss-include-info2, p-tbl-name ).
    end.
    assign
      v-num-fields = p-new-buf-handle:num-fields
    .
    do v-ind = 1 to v-num-fields
    on error undo, return error substitute( "&1 (cre-raw-delta). &2", vss-include-info2, error-status :get-message ( 1 ) )
    :
      assign
        v-fh-new     = p-new-buf-handle:buffer-field( v-ind )
        v-name-field = v-fh-new:name
        v-fh-old     = bh-old_tt:buffer-field( v-name-field )
        v-fh-tt      = bh-dlt_tt:buffer-field( v-name-field )
      .
      if v-fh-new:buffer-value <> v-fh-old:buffer-value then do:
        assign
          bh-dlt_tt:buffer-field( v-name-field ):buffer-value = v-fh-new:buffer-value
        .
      end.
    end.
    create t-raw.
    assign
      bh_t-raw = buffer t-raw:handle
    .
    assign
      v-ok = bh-dlt_tt:raw-transfer ( true, bh_t-raw:buffer-field("t-raw-field":U) ) no-error
    .
    assign
      p-raw = t-raw.t-raw-field
    .
    delete t-raw.
    if v-ok <> true then do:
      return error substitute( "&1. raw-transfer не прошел для таблицы &2", vss-include-info2, p-tbl-name ).
    end.
    assign
      v-ok = tth:clear() no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1. Ошибка при очистке временной таблицы &2", vss-include-info2, tt-name ) .
    end.
    delete object bh-old_tt no-error .
    if error-status:error then do:
      return error substitute( "&1. Ошибка при удалении ссылки на буфер временной таблицы &2", vss-include-info2, tt-name ).
    end.
    delete object tth no-error .
    if error-status:error then do:
      return error substitute( "&1. Ошибка при удалении временной таблицы для &2", vss-include-info2, tt-name ).
    end.
  end.
end procedure.
PROCEDURE cre-route-dump :
  define input        parameter p-act-name   as character           no-undo .
  define input        parameter p-tbl-name   as character           no-undo.
  define input        parameter p-tbl-handle as handle              no-undo.
  define input        parameter p-dmp-ord    like ub.route.dump-ord no-undo.
  define input-output parameter p-rc-ord     as integer             no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-route-dump). &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-route-dump). stop", vss-include-info2 )
  on endkey undo, return error substitute( "&1 (cre-route-dump). endkey", vss-include-info2 )
  :
    define variable loc-key-rec like ub.route.uniq-key-rec   no-undo .
    define variable v-value-rec like ub.route-dump.value-rec no-undo .
    define variable bh_tbl-name  as handle    no-undo .
    define variable fh_tbl-name  as handle    no-undo .
    define variable v-ok         as logical   no-undo .
    define buffer buf_sys-ctrl for ub.sys-ctrl .
    if not p-tbl-handle:available then do:
      return error substitute( "&1. Переданый буфер таблицы &2 не доступен", vss-include-info2, p-tbl-name ).
    end.
    assign
      p-rc-ord = p-rc-ord + 1
    .
    run gen-key-rec in this-procedure
      ( input p-tbl-name
       ,input p-tbl-handle
       ,output loc-key-rec
      ) no-error.
    if error-status :error then do:
      return error substitute( "&1. Ошибка при генерации уникального ключа по таблице &2. &3"
                               ,vss-include-info2
                               ,p-tbl-name
                               ,return-value
                             ).
    end.
    run cre-raw in this-procedure
      ( input p-tbl-name
       ,input p-tbl-handle
       ,output v-value-rec
      ) no-error.
    if error-status :error then do:
      return error substitute( "&1. Ошибка при сжатии записи по таблице &2. &3"
                               ,vss-include-info2
                               ,p-tbl-name
                               ,return-value
                             ).
    end.
    case p-act-name :
      when 'send-tbl':U then do:
        create buffer bh_tbl-name for table "ub.route-dump":U .
      end.
      when 'send-tbl-oxml':U
      then do:
        create buffer bh_tbl-name for table "ub.esys-route-dump":U .
      end.
    end case.
    assign
      v-ok = bh_tbl-name:buffer-create no-error
    .
    if v-ok <> true
      or error-status :error
    then do:
      return error substitute( "&1. Ошибка при создании буфера таблицы маршрутизации &2&3&4.", vss-include-info2, p-tbl-name, chr(10), error-status :get-message(1) ).
    end.
    case p-act-name :
      when 'send-tbl':U then do:
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("dump-name":U)
          fh_tbl-name:buffer-value = p-tbl-name
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("dump-ord":U)
          fh_tbl-name:buffer-value = p-dmp-ord
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("rec-ord":U)
          fh_tbl-name:buffer-value = p-rc-ord
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("uniq-key-rec":U)
          fh_tbl-name:buffer-value = loc-key-rec
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("value-rec":U)
          fh_tbl-name:buffer-value = v-value-rec
        .
define variable vss-include-info3 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_route-dump-write in g#lib-nws
  ( input p-tbl-name
  , input bh_tbl-name
  , input p-tbl-handle
  , input p-dmp-ord
  , input p-rc-ord
  ) no-error .
        if error-status :error then do:
          return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ).
        end.
      end.
      when 'send-tbl-oxml':U
      then do:
        find first buf_sys-ctrl no-lock .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("esrd-cr-db-num":U)
          fh_tbl-name:buffer-value = buf_sys-ctrl.db-num
          .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("esrd-dump-name":U)
          fh_tbl-name:buffer-value = p-tbl-name
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("esrd-dump-ord":U)
          fh_tbl-name:buffer-value = p-dmp-ord
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("esrd-rec-ord":U)
          fh_tbl-name:buffer-value = p-rc-ord
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("esrd-uniq-key-rec":U)
          fh_tbl-name:buffer-value = loc-key-rec
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("esrd-value-rec":U)
          fh_tbl-name:buffer-value = v-value-rec
        .
      end.
    end case.
    delete object bh_tbl-name.
  end.
END PROCEDURE.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable tempcxml_v-num_ as integer no-undo .
define  temp-table temp-xml-tables no-undo
field order as integer
field tbl-name as character
field tbl-handle_ as handle
field table-handle_ as handle
field uniq-gate-rec as character
field gate-name as character
field gate-handle_ as handle
field is-parent as logical
index pi is unique primary
uniq-gate-rec
tbl-name
index iorder
order
index gr
uniq-gate-rec
index gh
gate-handle_
index iparent
is-parent
.
define  temp-table temp-xml-records no-undo
field tbl-name as character
field uniq-key-rec as character
index pi is unique primary
tbl-name
uniq-key-rec
.
def var vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure get-gate-file-name :
define input parameter p-gate-rec as character no-undo .
define output  parameter p-gate-file-name as character no-undo .
define buffer buf_clob-data for ub.clob-data.
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
run gen-row-keyr in this-procedure ( input p-gate-rec
                                    ,input ?
                                    ,input "ub"
                                    ,input ?
                                    ,input no-lock
                                    ,output v-tbl-row
                                    ,output v-tbl-name) no-error.
if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                        ,vss-include-info5
                                                        ,p-gate-rec).
find first buf_clob-data no-lock where
          rowid(buf_clob-data) = v-tbl-row no-error.
if not available buf_clob-data then do:
  if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                          ,vss-include-info5
                                                          ,p-gate-rec).
end.
p-gate-file-name = buf_clob-data.file-name.
end procedure.
procedure get-gate-rec :
define input  parameter p-gate-name as character no-undo .
define output parameter p-gate-rec as character no-undo .
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info5, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info5 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info5 )
:
    find first buf_clob-bind no-lock where
              buf_clob-bind.uniq-key-rec = p-gate-name
          and buf_clob-bind.field-name = '':U
          and buf_clob-bind.part-num = 1
          and buf_clob-bind.resource-type = 'gate':U
          no-error.
    if not available buf_clob-bind then do:
      undo, return error substitute("Неверная ссылка на XSD -файл &1 для gate"
                                      , p-gate-name
                                      ).
    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = buf_clob-bind.db-num
          and buf_clob-data.int64-i= buf_clob-bind.int64-id no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB c ДБ &1 id &2 - файл &3"
                                      , buf_clob-bind.db-num
                                      , buf_clob-bind.int64-id
                                      , p-gate-name
                                      ).
    end.
    run gen-key-rec in this-procedure ( input 'clob-data':U
                              ,input buffer buf_clob-data:handle
                              ,output p-gate-rec).
end.
end procedure.
procedure get-gate-by-name :
define input  parameter p-gate-name as character no-undo .
define output parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
define variable v-db-num as integer no-undo .
define variable v-int64-id as int64 no-undo .
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info5, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info5 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info5 )
:
    find first buf_clob-bind no-lock where
              buf_clob-bind.uniq-key-rec = p-gate-name
          and buf_clob-bind.field-name = '':U
          and buf_clob-bind.part-num = 1
          and buf_clob-bind.resource-type = 'gate':U
          no-error.
    if not available buf_clob-bind then do:
      undo, return error substitute("Неверная ссылка на XSD -файл &1 для gate"
                                      , p-gate-name
                                      ).
    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = buf_clob-bind.db-num
          and buf_clob-data.int64-i= buf_clob-bind.int64-id no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB c ДБ &1 id &2 - файл &3"
                                      , buf_clob-bind.db-num
                                      , buf_clob-bind.int64-id
                                      , p-gate-name
                                      ).
    end.
    assign
    v-longchar = buf_clob-data.cdata
    .
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, buf_clob-data.file-name_, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "LONGCHAR"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    v-longchar = '':U.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему &1 из БД:&2&3", p-gate-name, chr(10), error-status:get-message(1) ).
    end.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    run gen-key-rec in this-procedure ( input 'clob-data':U
                              ,input buffer buf_clob-data:handle
                              ,output p-gate-rec).
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
      end.
    end.
end.
end procedure.
procedure get-gate-by-rec :
define input  parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define input-output parameter p-longchar  as longchar no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info5, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info5 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info5 )
:
  run gen-row-keyr in this-procedure (
                                        input  p-gate-rec
                                        ,input  ?
                                        ,input  "ub"
                                        ,input  ?
                                        ,input  NO-LOCK
                                        ,output v-rowid
                                        ,output v-tbl-name   ) no-error.
    find first buf_clob-data no-lock where
              rowid(buf_clob-data) = v-rowid  no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB  &1"
                                      , p-gate-rec
                                      ).
    end.
    assign
    v-longchar = buf_clob-data.cdata
    .
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, buf_clob-data.file-name_, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "LONGCHAR"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    define variable v-esm as character no-undo .
    v-esm = error-status:get-message(1) .
    if p-longchar <> ? then do:
      p-longchar = v-longchar.
    end.
    v-longchar = '':U.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему &1 (&2) из БД&3&4"
                                   , p-gate-rec
                                   , p-gate-rec
                                   , v-esm
                                   ).
    end.
    p-dsh:private-data = buf_clob-data.file-name_ + chr(4) + p-gate-rec.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
end.
end procedure.
procedure get-gate-by-file :
define input  parameter p-schema-file-name as character no-undo .
define input  parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info5, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info5 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info5 )
:
    COPY-LOB
    FROM  FILE p-schema-file-name
    TO  OBJECT v-longchar
    no-convert
    NO-ERROR .
    if error-status :error then do:
        undo, return error substitute("Не удалось считать файл схемы &1 в память&2&3"
                                  , p-schema-file-name
                              , chr(10)
                              , error-status:get-message(1) ).
    end.
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, p-schema-file-name, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "longchar"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    v-longchar = ''.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему из файла &1&2&3"
                                   , p-schema-file-name
                                   ,chr(10)
                                   , error-status:get-message(1)
                                   ).
    end.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1" and  uniq-gate-rec = "&2" '
                                   ,p-dsh:get-buffer-handle(v-ii):name
                                   ,p-gate-rec
                                   )) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):table
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
end.
end procedure.
procedure gate-clear :
define input  parameter p-dsh as handle no-undo .
define input  parameter p-xmlh as handle no-undo .
define variable v-dsh as handle no-undo .
define variable v-th as handle no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-dsh) then do:
      delete object p-dsh.
      v-dsh = p-dsh.
      p-dsh = ?.
    end.
    repeat while true:
      p-xmlh:find-first( substitute( " where gate-handle_ = &1 ", v-dsh)
                         , share-lock) no-error.
      if p-xmlh:available then do:
        assign
        v-th = p-xmlh:buffer-field("table-handle_"):buffer-value.
        if valid-handle(p-xmlh:buffer-field("table-handle_"))
        and valid-handle(v-th)
        and v-th:dynamic = yes
        then do:
          delete object p-xmlh:buffer-field("table-handle_"):buffer-value.
          p-xmlh:buffer-field("table-handle_"):buffer-value = ?.
        end.
        p-xmlh:buffer-delete().
      end.
      else do:
        leave.
      end.
    end.
    if p-xmlh:dynamic = yes
    and valid-handle(p-xmlh)
    then do:
      delete object p-xmlh:table-handle.
      p-xmlh = ?.
    end.
    v-dsh = ?.
  end.
end procedure.
procedure all-gates-clear :
define parameter buffer buf_temp-xml-tables for temp-xml-tables.
do
on error undo, return error
:
  for each buf_temp-xml-tables
  break
  by buf_temp-xml-tables.uniq-gate-rec
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
      if first-of(buf_temp-xml-tables.uniq-gate-rec) then do:
        delete object buf_temp-xml-tables.gate-handle_.
        buf_temp-xml-tables.gate-handle_ = ?.
      end.
      if valid-handle(buf_temp-xml-tables.table-handle_)
      and buf_temp-xml-tables.table-handle_:dynamic = no
      then do:
        delete object buf_temp-xml-tables.table-handle_.
        buf_temp-xml-tables.table-handle_ = ?.
      end.
      delete buf_temp-xml-tables.
  end.
end.
end procedure.
procedure fix-schemalocation :
define input-output  parameter p-longchar as longchar no-undo .
DEFINE VARIABLE hdoc AS HANDLE.
DEFINE VARIABLE hroot AS HANDLE.
DEFINE VARIABLE hnode-child AS HANDLE.
DEFINE VARIABLE hnode-attr AS HANDLE.
define variable v-jj as integer   no-undo .
define variable ok as logical   no-undo .
define variable v-path1                    as character                no-undo .
DEFINE VARIABLE v-full-path1               as character                no-undo .
DEFINE VARIABLE v-file-name1               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext1        as character                no-undo .
DEFINE VARIABLE v-file-name-ext1           as character                no-undo .
define variable v-schema-location          as character                no-undo .
do
on error undo, return error return-value
:
  CREATE X-DOCUMENT hdoc.
  CREATE X-noderef hroot.
  CREATE X-noderef hnode-child.
  CREATE X-noderef hnode-attr.
  hdoc:load("longchar", p-longchar, no) no-error.
  iF ERROR-STATUS:GET-MESSAGE(1) <> '' THEN message ERROR-STATUS:GET-MESSAGE(1) view-as alert-box .
  hdoc:get-document-element(hroot).
  _repeat:
  REPEAT v-jj = 1 TO hroot:NUM-CHILDREN:
    ok = hroot:GET-CHILD(hNode-Child, v-jj).
    if not ok then next.
    if hNode-Child:local-name = "include"
    then do:
      ok = hNode-Child:GET-ATTRIBUTE-NODE( hnode-attr, "schemaLocation" ).
        v-schema-location = hnode-attr:node-value.
        run gbl/filename.p (
                        input "exe/" + hnode-attr:node-value
                      ,output v-full-path1
                      ,output v-path1
                      ,output v-file-name1
                      ,output v-file-name-no-ext1
                      ,output v-file-name-ext1
                      ) no-error .
        if error-status :error then do:
          delete object hnode-attr.
          delete object hnode-child.
          delete object hroot.
          delete object hdoc.
          undo, return error substitute("Не удалось определить расположение схемы &1", v-schema-location).
        end.
      ok = hNode-Child:sET-ATTRIBUTE(  "schemaLocation", v-full-path1 ).
      leave  _repeat.
    end.
  END.
  hdoc:save("longchar", p-longchar).
  delete object hnode-attr.
  delete object hnode-child.
  delete object hroot.
  delete object hdoc.
end.
end procedure.
procedure gate-clb_fill-xml-tables :
define input parameter p-dsh as handle no-undo .
define input-output parameter p-xmlh as handle no-undo .
define variable v-ii as integer no-undo .
  do
  on error undo, return error
  :
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = entry(2, p-dsh:private-data, chr(4))
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
  end.
end procedure.
procedure all-gates-empty :
define buffer buf_temp-xml-tables for temp-xml-tables.
do
on error undo, return error
:
  for each buf_temp-xml-tables
  break
  by buf_temp-xml-tables.uniq-gate-rec
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    if valid-handle(buf_temp-xml-tables.tbl-handle_) then do:
      buf_temp-xml-tables.tbl-handle_:empty-temp-table().
    end.
  end.
end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure esallatr-name :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
    case p-code :
            when 'custom-pack-name':U then do:     assign     p-label = "Имя файла в ВС"     p-type = 'C':U      p-format = "X(255)"     p-label = "Имя файла в ВС"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
            when 'route-custom-pack-name':U then do:     assign     p-label = "Иям файла в ВС"     p-type = 'C':U      p-format = "X(255)"     p-label = "Иям файла в ВС"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут ВС &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure esallatr-value :
do
  on error undo, return error
  :
  define input  parameter p-table-name as character no-undo .
  define input  parameter p-key1     as int64 no-undo .
  define input  parameter p-key2     as int64 no-undo .
  define input  parameter p-key3     as character no-undo .
  define input  parameter p-key4     as character no-undo .
  define input  parameter p-key5     as int64 no-undo .
  define input  parameter p-key6     as int64 no-undo .
  define input  parameter p-key7     as character no-undo .
  define input  parameter p-key8     as character no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  define buffer buf_esys-all-attr for ub.esys-all-attr.
  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-user-can-edit  as logical   no-undo .
  define variable v-output-display as logical   no-undo .
  define variable v-other          as character no-undo .
    run esallatr-name in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    Find first  buf_esys-all-attr no-lock where
                buf_esys-all-attr.attr-code = p-code
           and  buf_esys-all-attr.table-name  = p-table-name
           and  buf_esys-all-attr.key1  = p-key1
           and  buf_esys-all-attr.key2  = p-key2
           and  buf_esys-all-attr.key3  = p-key3
           and  buf_esys-all-attr.key4  = p-key4
           and  buf_esys-all-attr.key5  = p-key5
           and  buf_esys-all-attr.key6  = p-key6
           and  buf_esys-all-attr.key7  = p-key7
           and  buf_esys-all-attr.key8  = p-key8  no-error .
   if avail buf_esys-all-attr then do:
    assign
    p-value = buf_esys-all-attr.attr-value.
   end.
   else do:
    assign
    p-value = if p-type = 'L':U then "no":U else "".
   end.
end.
end procedure.
define temp-table for-route no-undo
  field name-rec as character
  field db-list  as character
  field dump-ord like ub.route.dump-ord
  field uniq-gate-rec like ub.route.uniq-gate-rec
  field custom-pck-name as character
  field action as character
  index pi is primary unique dump-ord
.
define temp-table for-route-dump no-undo like ub.route-dump
    field blob-value-rec as blob.
on delete of this-procedure do:
  for each for-route
  :
    delete for-route.
  end.
  for each for-route-dump
  :
    delete for-route-dump.
  end.
end.
procedure begin-create-command :
  define input  parameter p-command-name as character no-undo .
  define input  parameter p-db-list      as character no-undo .
  define output parameter p-command-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1 (begin-create-command). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (begin-create-command). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (begin-create-command). endkey", vss-workfile )
  :
    if num-entries( p-command-name, chr(1) ) > 1
      or num-entries( p-command-name, chr(3) ) > 1
    then do:
      return error substitute( "&1 (begin-create-command). Название команды не может содержать символы chr(1), chr(3)!!!", vss-workfile ) .
    end.
    if trim( p-command-name ) = "":U
      or p-command-name = ?
    then do:
      return error substitute( "&1 (begin-create-command). Команда должна иметь название!!!", vss-workfile ) .
    end.
    find last for-route
      no-error .
    if available for-route then do:
      assign
        p-command-code = for-route.dump-ord + 1
      .
    end.
    else do:
      assign
        p-command-code = 1
      .
    end.
    create for-route .
    assign
      for-route.name-rec = p-command-name
      for-route.db-list  = p-db-list
      for-route.dump-ord = p-command-code
    .
  end.
  return.
end procedure.
procedure add-dump :
  define input  parameter p-command-code as integer   no-undo .
  define input  parameter p-dump-name    as character no-undo .
  define input  parameter p-action       as character no-undo .
  define input  parameter p-tbl-handle   as handle    no-undo .
  define input  parameter p-uniq-gate-rec as character no-undo .
  define output parameter p-rec-ord      as integer   no-undo .
  do
  on error  undo, return error substitute( "&1 (add-dump). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (add-dump). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (add-dump). endkey", vss-workfile )
  :
    define variable v-rec-ord      like ub.route-dump.rec-ord .
    define variable v-uniq-key-rec like ub.route-dump.uniq-key-rec .
    define variable v-value-rec    like ub.route-dump.value-rec .
    define variable v-first-char as character no-undo .
    define variable v-cre-raw    as logical   no-undo .
    find first for-route
      where for-route.dump-ord = p-command-code
      no-error .
    if not available for-route then do:
      return error substitute( "&1 (add-dump). Команда с кодом &2 еще не создана!", vss-workfile, p-command-code ) .
    end.
    if p-uniq-gate-rec <> '' then do:
      if for-route.uniq-gate-rec = '':U then do:
        for-route.uniq-gate-rec = p-uniq-gate-rec.
      end.
      else do:
        if for-route.uniq-gate-rec <> p-uniq-gate-rec then do:
            undo, return error
            substitute( "&1 (add-dump). &2&3&4"
                        , vss-workfile
                        , return-value
                        , chr(10)
                        , substitute("в route-dump указан непустой gate &1 отличный от gate route (&2)"
                                     , for-route-dump.uniq-gate-rec
                                     , for-route.uniq-gate-rec)
                        ).
        end.
      end.
    end.
    assign
      v-first-char = substring( p-action, 1, 1 )
      v-cre-raw    = true
    .
    if trim( p-action ) <> "":U then do:
      if lookup( v-first-char, "+,-,_":U, ",":U ) = 0 then do:
        return error substitute( "&1 (add-dump). Ошибка задания входных параметров! &2"
                                + "Задан параметр action. Первый его символ должен быть '+' или '-' или '_'. "
                                + "Текущее значение: &3"
                                ,vss-workfile
                                ,chr(10)
                                ,p-action
                              ) .
      end.
      else do:
        if v-first-char = "-":U
        or v-first-char = "_":U
        then do:
          assign
            v-cre-raw = false
          .
        end.
      end.
    end.
    find last for-route-dump
      where for-route-dump.dump-ord = p-command-code
      no-error .
    if available for-route-dump then do:
      assign
        v-rec-ord = for-route-dump.rec-ord + 1
      .
    end.
    else do:
      assign
        v-rec-ord = 1
      .
    end.
    if v-first-char <> '_' then do:
    run gen-key-rec in this-procedure
      ( input  p-dump-name
       ,input  p-tbl-handle
       ,output v-uniq-key-rec
      ) no-error.
    if error-status :error then do:
      return error substitute( "&1 (add-dump). Ошибка при генерации уникального ключа по таблице &2 для команды с кодом &3.&4&5&4&6"
                               ,vss-workfile
                               ,p-dump-name
                               ,p-command-code
                               ,chr(10)
                               ,return-value
                               ,error-status :get-message ( 1 )
                              ) .
    end.
    end.
    if v-cre-raw = true then do:
      run cre-raw in this-procedure
        ( input  p-dump-name
         ,input  p-tbl-handle
         ,output v-value-rec
        ) no-error.
      if error-status :error then do:
        return error substitute( "&1 (add-dump). Ошибка при сжатии записи по таблице &2 в команду с кодом &3.&4&5&4&6"
                                ,vss-workfile
                                ,p-dump-name
                                ,p-command-code
                                ,chr(10)
                                ,return-value
                                ,error-status :get-message ( 1 )
                                ) .
      end.
    end.
    create for-route-dump .
    assign
      for-route-dump.dump-name    = entry(1, p-dump-name, chr(4))
      for-route-dump.action       = p-action
      for-route-dump.dump-ord     = p-command-code
      for-route-dump.rec-ord      = v-rec-ord
      for-route-dump.uniq-key-rec = v-uniq-key-rec
      for-route-dump.value-rec    = v-value-rec
      for-route-dump.uniq-gate-rec = p-uniq-gate-rec
      p-rec-ord                   = v-rec-ord
    .
  end.
  return.
end procedure.
procedure add-dump-data :
  define input  parameter p-command-code as integer   no-undo .
  define input  parameter p-dump-name    as character no-undo .
  define input  parameter p-action       as character no-undo .
  define input  parameter p-data         as memptr    no-undo .
  define output parameter p-rec-ord      as integer   no-undo .
  do
  on error  undo, return error substitute( "&1 (add-dump). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (add-dump). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (add-dump). endkey", vss-workfile )
  :
    define variable v-rec-ord      like ub.route-dump.rec-ord .
    define variable v-first-char as character no-undo .
    find first for-route
      where for-route.dump-ord = p-command-code
      no-error .
    if not available for-route then do:
      return error substitute( "&1 (add-dump). Команда с кодом &2 еще не создана!", vss-workfile, p-command-code ) .
    end.
    assign
      v-first-char = substring( p-action, 1, 1 ).
    if trim( p-action ) <> "":U then do:
      if lookup( v-first-char, "+,-,_":U, ",":U ) = 0 then do:
        return error substitute( "&1 (add-dump). Ошибка задания входных параметров! &2"
                                + "Задан параметр action. Первый его символ должен быть '+' или '-' или '_'. "
                                + "Текущее значение: &3"
                                ,vss-workfile
                                ,chr(10)
                                ,p-action
                              ) .
      end.
    end.
    find last for-route-dump
      where for-route-dump.dump-ord = p-command-code
      no-error .
    if available for-route-dump then do:
      assign
        v-rec-ord = for-route-dump.rec-ord + 1
      .
    end.
    else do:
      assign
        v-rec-ord = 1
      .
    end.
    create for-route-dump .
    assign
      for-route-dump.dump-name    = entry(1, p-dump-name, chr(4))
      for-route-dump.uniq-key-rec = if num-entries(p-dump-name, chr(4)) > 1 then  entry(2, p-dump-name, chr(4)) else ""
      for-route-dump.action       = p-action
      for-route-dump.dump-ord     = p-command-code
      for-route-dump.rec-ord      = v-rec-ord
      for-route-dump.blob-value-rec    = p-data
      p-rec-ord                   = v-rec-ord
    .
  end.
  return.
end procedure.
procedure delete-command :
  define input parameter p-command-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1 (delete-command). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (delete-command). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (delete-command). endkey", vss-workfile )
  :
    for each for-route
      where for-route.dump-ord = p-command-code
    on error undo, return error substitute( "&1 (delete-command). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    :
      delete for-route.
    end.
    for each for-route-dump
      where for-route-dump.dump-ord = p-command-code
    on error undo, return error substitute( "&1 (delete-command). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    :
      delete for-route-dump.
    end.
  end.
  return.
end procedure.
procedure send-command :
  define input parameter p-command-code as integer   no-undo .
  define input parameter p-db-list      as character no-undo .
  do
  on error  undo, return error substitute( "&1 (send-command). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (send-command). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (send-command). endkey", vss-workfile )
  :
    define buffer buf_route      for ub.route .
    define buffer buf_route-dump for ub.route-dump .
    define buffer buf_db         for ub.db .
    define variable v-ind as integer no-undo .
    define variable v-dmp-ord      like ub.route.dump-ord     no-undo .
    define variable v-rec-ord      like ub.route-dump.rec-ord no-undo .
    define variable v-command-name like ub.route.name-rec     no-undo .
    define variable v-rt-count     as   integer               no-undo .
    define variable v_dataseth as handle no-undo .
    define variable v-xmlh as handle no-undo .
    define variable v-h as handle no-undo .
    define buffer buf_temp-xml-tables for temp-xml-tables.
    v-xmlh = buffer buf_temp-xml-tables:handle.
    find first for-route
      where for-route.dump-ord = p-command-code
      no-error
    .
    if not available for-route then do:
      return error substitute( "&1 (send-command). Команда с номером &2 не создана!", vss-workfile, p-command-code ) .
    end.
    if trim( for-route.db-list ) <> "":U then do:
      assign
        p-db-list = for-route.db-list
      .
    end.
    block_cre-route:
    do transaction
    on error  undo block_cre-route, return error substitute( "&1 (send-command). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on stop   undo block_cre-route, return error substitute( "&1 (send-command). stop", vss-workfile )
    on endkey undo block_cre-route, return error substitute( "&1 (send-command). endkey", vss-workfile )
    :
      assign
        v-dmp-ord = next-value( s-news-dord, ub )
        v-rec-ord = 0
      .
      if for-route.uniq-gate-rec <> '':U then do:
        define variable v-longchar as longchar no-undo .
        v-longchar = ?.
        run get-gate-by-rec in this-procedure ( input for-route.uniq-gate-rec
                                               ,output v_dataseth
                                               ,input-output v-xmlh
                                               ,input-output v-longchar
                                               ) no-error.
        if error-status:error
        then do:
          return error substitute( "&1 (send-command) Ошибка при создании структуры маршрутизируемых данных согласно гейту: &2. &4&5&6"
                                    , vss-workfile
                                    , for-route.uniq-gate-rec
                                    , return-value
                                    , chr(10)
                                    , error-status :get-message ( 1 ) ).
        end.
      end.
      for each for-route-dump
        where for-route-dump.dump-ord = for-route.dump-ord
      on error undo, return error substitute( "&1 (send-command). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
      :
        assign
          v-rec-ord = v-rec-ord + 1
        .
        create buf_route-dump .
        buffer-copy for-route-dump to buf_route-dump
          assign
            buf_route-dump.dump-ord     = v-dmp-ord
            buf_route-dump.rec-ord      = v-rec-ord
        .
        if for-route-dump.uniq-gate-rec <> '':u then do:
          find first buf_temp-xml-tables where
                    buf_temp-xml-tables.tbl-name = for-route-dump.dump-name.
          v-h = buf_temp-xml-tables.tbl-handle_.
        end.
        else do:
          v-h = ?.
        end.
define variable vss-include-info9 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_route-dump-write in g#lib-nws
  ( input for-route-dump.dump-name
  , input (buffer buf_route-dump:handle)
  , input v-h
  , input v-dmp-ord
  , input v-rec-ord
  ) no-error .
        if error-status :error then do:
          undo block_cre-route, return error substitute( "&1 (send-command). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ).
        end.
      end.
      assign
        v-command-name = "command":U + chr(1) + "bush":U + chr(1) + for-route.name-rec
        v-rt-count     = 0
      .
      do v-ind = 1 to num-entries(p-db-list, chr(1) )
      on error undo block_cre-route, return error substitute( "&1 (send-command). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
      :
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf10_db    for ub.db .
define buffer buf10_route for ub.route .
define variable v-msg#10    as character no-undo .
define variable v-lock#10   as logical   no-undo .
define variable v-ok#10     as logical   no-undo .
find first buf10_db no-lock
  where buf10_db.db-num = integer(entry(v-ind,p-db-list,chr(1)))
  no-error
.
if not available buf10_db then do:
  message
    vss-include-info10 skip
    vss-workfile vss-revision vss-description skip
    substitute( "Попытка создать маршрутизацию на несуществующую БД &1", integer(entry(v-ind,p-db-list,chr(1))) ) skip
    return-value skip
    error-status :get-message ( error-status :num-messages )
    view-as alert-box error
  .
end.
if "ub":U <> "ub":U
   or ( trim( buf10_db.db-key ) <> "":U
        and buf10_db.db-key <> ?
      )
then do:
  create buf10_route .
  assign
    buf10_route.last-pack    = -1
    buf10_route.name-rec     = v-command-name
    buf10_route.db-num       = integer(entry(v-ind,p-db-list,chr(1)))
    buf10_route.uniq-key-rec = '':U
    buf10_route.num-dump     = v-rec-ord
    buf10_route.tbl-ord      = dynamic-next-value( "s-news-ord":U, "ub":U )
    .
    assign
      buf10_route.dump-ord = v-dmp-ord
    .
    assign
    buf10_route.uniq-gate-rec = for-route.uniq-gate-rec
    .
    assign
      v-rt-count = v-rt-count + 1
    .
end.
else do:
define variable vss-include-info11 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_lock-route in g#lib-nws
  ( input  'check'
  , input  integer(entry(v-ind,p-db-list,chr(1)))
  , input  0
  , input  ''
  , output v-msg#10
  , output v-lock#10
  , output v-ok#10
  ) no-error .
  if error-status :error
    or v-lock#10 = true
    or v-ok#10   = false
  then do:
    return error substitute( "&1. Маршрутизация записи &2.&3Ключ записи: &4&3&3"
                             ,vss-include-info10
                             ,v-command-name
                             ,chr(10)
                             ,'':U
                           )
                + substitute( "&1&2&2&3&2&2&4"
                              ,v-msg#10
                              ,chr(10)
                              ,return-value
                              ,error-status :get-message( error-status :num-messages )
                            ) .
  end.
end.
      end.
      if v-rt-count = 0 then do:
        do v-ind = 1 to num-entries( p-db-list, chr(1) )
        on error  undo block_cre-route, return error substitute( "&1. (check-db-list) &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
        on stop   undo block_cre-route, return error substitute( "&1. (check-db-list) stop", vss-workfile )
        on endkey undo block_cre-route, return error substitute( "&1. (check-db-list) endkey", vss-workfile )
        :
          find buf_db no-lock
            where buf_db.db-num = integer( entry( v-ind, p-db-list, chr(1) ) )
          .
          if buf_db.db-key <> ?
            and buf_db.db-key <> "":U
          then do:
            undo block_cre-route, return error substitute( "&1. Есть список БД для отправки, но ни одна запись не маршрутизировалась!!!", vss-workfile ) .
          end.
        end.
        undo block_cre-route, leave block_cre-route .
      end.
    end.
    for each for-route-dump
      where for-route-dump.dump-ord = for-route.dump-ord
    on error undo, return error substitute( "&1 (send-command). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    :
      delete for-route-dump .
    end.
    delete for-route .
    run gate-clear in this-procedure
      ( input v_dataseth
      , input v-xmlh
      ) no-error.
  end.
  return.
end procedure.
procedure send-command-esys :
  define input parameter p-command-code as integer   no-undo .
  define input parameter p-esys-id-list      as character no-undo .
  define input parameter p-user-name    as character no-undo .
  define output parameter p-dmp-ord as int64 no-undo .
  do
  on error  undo, return error substitute( "&1 (send-command-esys). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (send-command-esys). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (send-command-esys). endkey", vss-workfile )
  :
    define buffer buf_esys-route      for ub.esys-route .
    define buffer buf_esys-route-dump for ub.esys-route-dump .
    define variable v-ind as integer no-undo .
    define variable v-dmp-ord      like ub.esys-route.esr-dump-ord .
    define variable v-rec-ord      like ub.esys-route-dump.esrd-rec-ord .
    define variable v-command-name like ub.esys-route.esr-name-rec .
    DEFINE VARIABLE v-cre-date as date no-undo .
    DEFINE VARIABLE v-cre-time as integer no-undo .
    define variable v-cre-user as character no-undo .
    define variable v-act-name as character no-undo .
    define variable v-oper     as character no-undo .
    define buffer buf_sys-ctrl for ub.sys-ctrl.
    define buffer buf_esys-all-attr for ub.esys-all-attr.
    find first for-route
      where for-route.dump-ord = p-command-code
      no-error
    .
    if not available for-route then do:
      return error substitute( "&1 (send-command-esys). Команда с номером &2 не создана!", vss-workfile, p-command-code ) .
    end.
    find first buf_sys-ctrl no-lock.
    if trim( for-route.db-list ) <> "":U then do:
      assign
        p-esys-id-list = for-route.db-list
      .
    end.
    do transaction
    on error  undo, return error substitute( "&1 (send-command-esys). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1 (send-command-esys). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (send-command-esys). endkey", vss-workfile )
    :
      assign
        v-dmp-ord = next-value( s-news-dord, ub )
        v-rec-ord = 0
        v-oper = ""
      .
      for each for-route-dump
        where for-route-dump.dump-ord = for-route.dump-ord
      on error undo, return error substitute( "&1 (send-command-esys). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
      :
        assign
          v-rec-ord = v-rec-ord + 1
        .
        create buf_esys-route-dump .
        assign
        buf_esys-route-dump.esrd-action       = for-route-dump.action
        buf_esys-route-dump.esrd-cr-db-num    = buf_sys-ctrl.db-num
        buf_esys-route-dump.esrd-dump-name    = for-route-dump.dump-name
        buf_esys-route-dump.esrd-dump-ord     = v-dmp-ord
        buf_esys-route-dump.esrd-rec-ord      = v-rec-ord
        buf_esys-route-dump.esrd-uniq-key-rec = for-route-dump.uniq-key-rec
        buf_esys-route-dump.uniq-gate-rec     = for-route-dump.uniq-gate-rec
        buf_esys-route-dump.esrd-value-rec    = for-route-dump.value-rec
        .
        buf_esys-route-dump.esrd-blob-value-rec = for-route-dump.blob-value-rec .
        v-oper = buf_esys-route-dump.esrd-dump-name .
      end.
      assign
        v-command-name = "command":U + chr(1) + "bush":U + chr(1) + for-route.name-rec
      .
      run cur-time in this-procedure
        ( output v-cre-date
        ,output v-cre-time
        ) no-error.
      if error-status :error then do:
        return error substitute( "&1. Ошибка при определении текущего времени", vss-workfile ) .
      end.
      assign
        v-cre-user = p-user-name
        v-act-name = 'send-tbl-oxml':U
      .
      do v-ind = 1 to num-entries(p-esys-id-list, chr(1) )
      on error  undo, return error substitute( "&1 (send-command-esys). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
      :
def var vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-msg#12         as character no-undo .
define variable v-lock#12        as logical   no-undo .
define variable v-ok#12          as logical   no-undo .
define variable v-cur-db-num#12  as integer      no-undo.
define buffer buf12_ext-system for ub.ext-system .
find first buf12_ext-system no-lock
  where buf12_ext-system.esys-id = integer(entry(v-ind,p-esys-id-list,chr(1)))
    and buf12_ext-system.db-num = 0
  no-error
.
if not available buf12_ext-system then do:
  message
    vss-include-info12 skip
    vss-workfile vss-revision vss-description skip
    substitute( "Попытка создать маршрутизацию на несуществующую внешнюю систему &1 для БД &2", integer(entry(v-ind,p-esys-id-list,chr(1))), 0 ) skip
    return-value skip
    error-status :get-message ( error-status :num-messages )
    view-as alert-box error
  .
end.
if buf_sys-ctrl.db-num <> buf12_ext-system.esys-db-num-exp and buf12_ext-system.esys-db-num-exp <> 0 then do:
  message
    vss-include-info12 skip
    vss-workfile vss-revision vss-description skip
    substitute( "Попытка создать маршрутизацию на ВС &1 для БД &2,&3" +
                "в БД &4,&3" +
                "как БД экспорта указана БД &5"
                , integer(entry(v-ind,p-esys-id-list,chr(1)))
                , 0
                , chr(10)
                , buf_sys-ctrl.db-num
                , buf12_ext-system.esys-db-num-exp
                ) skip
    return-value skip
    error-status :get-message ( error-status :num-messages )
    view-as alert-box error
  .
end.
  create ub.esys-route .
  assign
    ub.esys-route.esr-name-rec     = v-command-name
      ub.esys-route.esr-tbl-ord = next-value( s-news-ord, ub )
    ub.esys-route.esr-last-pack    = -1
    ub.esys-route.esys-id          = integer(entry(v-ind,p-esys-id-list,chr(1)))
    ub.esys-route.db-num           = 0
    ub.esys-route.esr-status       = 0
    ub.esys-route.esr-cr-db-num    = buf_sys-ctrl.db-num
    ub.esys-route.esr-dump-ord     = v-dmp-ord
    ub.esys-route.esr-uniq-key-rec = '':U
    ub.esys-route.uniq-gate-rec    = for-route.uniq-gate-rec
    ub.esys-route.esr-num-dump     = v-rec-ord
    ub.esys-route.esr-action       = (if for-route.action = '' then 'command-bush':U else for-route.action)
    ub.esys-route.esr-oper         = v-oper
    .
    assign
      ub.esys-route.esr-CreDate      = v-cre-date
    .
    assign
      ub.esys-route.esr-CreTimeInt   = v-cre-time
      ub.esys-route.esr-CreTime      = string(v-cre-time,"HH:MM:SS":U)
    .
    assign
      ub.esys-route.esr-CreUserName  = v-cre-user
    .
        if for-route.custom-pck-name > '' then do:
          create buf_esys-all-attr.
          assign
          buf_esys-all-attr.attr-code = 'route-custom-pack-name':U
          buf_esys-all-attr.table-name = 'esys-route':U
          buf_esys-all-attr.key1 = v-dmp-ord
          buf_esys-all-attr.key2 = integer(entry(v-ind,p-esys-id-list,chr(1)))
          buf_esys-all-attr.key5 = 0
          buf_esys-all-attr.attr-value  = for-route.custom-pck-name
          buf_esys-all-attr.key6 = buf_sys-ctrl.db-num
          .
        end.
      end.
    end.
    for each for-route-dump
      where for-route-dump.dump-ord = for-route.dump-ord
    on error undo, return error substitute( "&1 (send-command-esys). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    :
      delete for-route-dump .
    end.
    delete for-route .
    p-dmp-ord = v-dmp-ord.
    for each buf_esys-route where buf_esys-route.esr-dump-ord = v-dmp-ord and buf_esys-route.whole-send-news = 1:
      delete buf_esys-route.
      for each buf_esys-all-attr where buf_esys-all-attr.table-name = 'esys-route':U and buf_esys-all-attr.key1 = v-dmp-ord:
        delete buf_esys-all-attr.
      end.
    end.
  end.
  return.
end procedure.
procedure set-custom-esys-pck-name :
  define input parameter p-command-code as integer   no-undo .
  define input parameter p-custom-pck-name as character no-undo .
  do
  on error  undo, return error substitute( "&1 (set-custom-esys-pck-name). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (set-custom-esys-pck-name). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (set-custom-esys-pck-name). endkey", vss-workfile )
  :
    find first for-route
      where for-route.dump-ord = p-command-code
      no-error
    .
    if not available for-route then do:
      return error substitute( "&1 (set-custom-esys-pck-name). Команда с номером &2 не создана!", vss-workfile, p-command-code ) .
    end.
    assign
    for-route.custom-pck-name = p-custom-pck-name.
  end.
  return.
end procedure.
procedure get-db-list :
  define input  parameter p-command-code as integer   no-undo .
  define output parameter p-db-list      as character no-undo .
  do
  on error  undo, return error substitute( "&1 (get-db-list). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-db-list). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-db-list). endkey", vss-workfile )
  :
    find first for-route
      where for-route.dump-ord = p-command-code
      no-error
    .
    if not available for-route then do:
      return error substitute( "&1 (get-db-list). Команда с номером &2 не создана!", vss-workfile, p-command-code ) .
    end.
    assign
      p-db-list = for-route.db-list
    .
  end.
end procedure.
procedure copy-dump :
  define input parameter p-src-command-code as integer   no-undo .
  define input parameter p-trg-command-code as integer   no-undo .
  define input parameter p-rec-ord          as integer   no-undo .
  define input parameter p-uniq-key-rec     as character no-undo .
  do
  on error  undo, return error substitute( "&1 (copy-dump). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (copy-dump). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (copy-dump). endkey", vss-workfile )
  :
    define variable v-rec-ord      like ub.route-dump.rec-ord .
    define variable v-uniq-key-rec like ub.route-dump.uniq-key-rec .
    define variable v-value-rec    like ub.route-dump.value-rec .
    define buffer buf_src-route for for-route.
    define buffer buf_trg-route for for-route.
    define buffer buf_src-route-dump for for-route-dump.
    define buffer buf_trg-route-dump for for-route-dump.
    find first buf_src-route-dump
      where buf_src-route-dump.dump-ord = p-src-command-code
        and buf_src-route-dump.rec-ord = p-rec-ord
      no-error .
    if not available buf_src-route-dump then do:
      return error substitute( "&1 (copy-dump). Запись-источник (код команды &2, код записи &3) еще не создана!", vss-workfile, p-trg-command-code, p-rec-ord ) .
    end.
    find first buf_trg-route-dump
      where buf_trg-route-dump.dump-ord = p-trg-command-code
        and buf_trg-route-dump.rec-ord = p-rec-ord
      no-error .
    if not available buf_trg-route-dump then do:
      create buf_trg-route-dump.
      assign
      buf_trg-route-dump.dump-ord = p-trg-command-code
      buf_trg-route-dump.rec-ord = p-rec-ord
      .
    end.
    buffer-copy buf_src-route-dump except dump-ord
    to buf_trg-route-dump.
  end.
  return.
end procedure.
procedure is-almost-empty :
define input parameter p-cmd-code as integer no-undo .
define output parameter p-is-empty as logical no-undo .
define buffer buf_for-route-dump for for-route-dump.
  do
  on error undo, return error
  :
    find first buf_for-route-dump no-lock where
              buf_for-route-dump.dump-ord = p-cmd-code
         and  buf_for-route-dump.dump-name < 'nws-outline':U
              no-error.
    if not available buf_for-route-dump then do:
      find first buf_for-route-dump no-lock where
                buf_for-route-dump.dump-ord = p-cmd-code
          and  buf_for-route-dump.dump-name > 'nws-outline':U  no-error.
      if not available buf_for-route-dump then do:
        assign
        p-is-empty = yes.
      end.
    end.
  end.
end procedure.
procedure is-empty :
define input parameter p-cmd-code as integer no-undo .
define output parameter p-is-empty as logical no-undo .
define buffer buf_for-route-dump for for-route-dump.
  do
  on error undo, return error
  :
    find first buf_for-route-dump no-lock where
              buf_for-route-dump.dump-ord = p-cmd-code no-error.
    if not available buf_for-route-dump then do:
      assign
      p-is-empty = yes.
    end.
  end.
end procedure.
procedure get-last-rec-ord :
define input parameter p-cmd-code as integer no-undo .
define output parameter p-last-rec-ord as integer no-undo .
  do
  on error  undo, return error substitute( "&1 (get-last-rec-ord). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-last-rec-ord). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-last-rec-ord). endkey", vss-workfile )
  :
    find last for-route-dump
      where for-route-dump.dump-ord = p-cmd-code
      no-error
    .
    if not available for-route-dump then do:
      p-last-rec-ord = 0.
    end.
    else do:
      p-last-rec-ord = for-route-dump.rec-ord.
    end.
  end.
end procedure.
procedure undo-from-rec-ord :
define input parameter p-cmd-code as integer no-undo .
define input parameter p-last-rec-ord as integer no-undo .
  do
  on error undo, return error
  :
    for each for-route-dump where
            for-route-dump.dump-ord = p-cmd-code
        and for-route-dump.rec-ord > p-last-rec-ord
    on error  undo, return error substitute( "&1 (undo-from-rec-ord). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1 (undo-from-rec-ord). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (undo-from-rec-ord). endkey", vss-workfile ):
       delete for-route-dump.
    end.
  end.
end procedure.
procedure set-esys-command-action :
define input parameter p-command-code as integer   no-undo .
define input parameter p-action as character no-undo .
  do
  on error  undo, return error substitute( "&1 (set-esys-command-action ). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (set-esys-command-action ). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (set-esys-command-action ). endkey", vss-workfile )
  :
    find first for-route
      where for-route.dump-ord = p-command-code
      no-error
    .
    if not available for-route then do:
      return error substitute( "&1 (set-esys-command-action ). Команда с номером &2 не создана!", vss-workfile, p-command-code ) .
    end.
    assign
    for-route.action = p-action.
  end.
end procedure.
