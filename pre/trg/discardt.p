block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для распределенной обработки ДК".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure discardh_write-dis-card-proc  :
define parameter buffer buf_dis-card for ub.dis-card .
define input parameter p-source-type like ub.c-dc-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-dc-hist.source-ref no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-card for ub.c-dis-card.
  do
  on error undo, return error
  :
    if not available buf_dis-card then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не определена ДК" skip
        view-as alert-box error .
      undo, return error .
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-dis-card.
    buffer-copy buf_dis-card to buf_c-dis-card
    assign
    buf_c-dis-card.d-card             = buf_dis-card.d-card
    buf_c-dis-card.card-num           = buf_dis-card.card-num
    buf_c-dis-card.chip-num           = next-value (s-dc-chip, ub)
    buf_c-dis-card.corr-time          = v-time
    buf_c-dis-card.corr-user-db-num   = g#db-num
    buf_c-dis-card.corr-user-name     = (if g#news
                                         then (chr(4) +  'СПН':U)
                                         else (if g#esys
                                               then (chr(4) +  'ВС':U)
                                               else g#userid
                                              )
                                         )
    buf_c-dis-card.corr-date          = v-date
    .
    create buf_c-dc-hist.
    buffer-copy buf_c-dis-card to buf_c-dc-hist
    assign
    buf_c-dc-hist.action =  integer('2':U)
    buf_c-dc-hist.subject = 'dis-card':U
    buf_c-dc-hist.host-code =  buf_dis-card.emitent-host-code
    buf_c-dc-hist.is-news = g#news
    buf_c-dc-hist.source-type = p-source-type
    buf_c-dc-hist.source-ref = p-source-ref
    .
    if not ( g#db-num > 0 )
    or (g#news
        and ( g#db-num > 0 )
        and buf_c-dis-card.corr-user-name = (chr(4) +  'СПН':U)
        )
    then do:
      run str/callnews.p
        (input 'c-dis-card':U
        ,input (buffer buf_c-dis-card:handle)
        ).
      run str/callnews.p
        (input 'c-dc-hist':U
        ,input (buffer buf_c-dc-hist:handle)
        ).
    end.
  end.
end procedure.
procedure block-del-dis-card :
define input  parameter pc-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pc-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pc-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pc-parameters   as   character                   no-undo .
define output parameter pc-err-msg      as   character                   no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-rowid    as rowid     no-undo .
    define variable v-tbl-name as character no-undo .
    define variable v-is-prt-bar-code as logical no-undo .
    define variable l-terminal-prt as logical no-undo .
    define variable l-is-used as logical no-undo init yes.
    define variable v-old-status as character no-undo .
    define variable v-return-value as character no-undo .
    define buffer buf_dis-card for ub.dis-card.
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
    if v-tbl-name <> 'dis-card':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей ДК", vss-workfile ).
    end.
    find first buf_dis-card
      where rowid( buf_dis-card ) = v-rowid
      no-error .
    if not available buf_dis-card then do:
      return error substitute( "&1. Нет необходимой ДК &2", vss-workfile, pc-uniq-key-rec ).
    end.
    if buf_dis-card.status_ = 'неисп':U
    or buf_dis-card.status_ = 'смкли':U then do:
      assign
      pc-err-msg = substitute( "ДК &1 уже заблокирована или удалена!!! Блокировка невозможна!!!", pc-uniq-key-rec )
      .
      return .
    end.
    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :
      run discardh_write-dis-card-proc in this-procedure  (
                                                    buffer buf_dis-card
                                                    ,input (if g#news
                                                            then 'db':U
                                                            else (if g#esys
                                                                  then 'esys':U
                                                                  else "":U)
                                                            )
                                                    ,input  (if g#news
                                                              then string(g#news-source-db)
                                                              else (if g#esys
                                                                    then string(g#esys-source-esys)
                                                                    else "":U)
                                                              )
                                                  ) .
      assign
      v-old-status = buf_dis-card.status_
      buf_dis-card.status_ = 'неисп':U
      .
      run proc-is-used-dis-card in this-procedure ( buffer buf_dis-card
                                                 , input pc-db-num
                                                 , output l-is-used) no-error .
      v-return-value = return-value.
      if error-status :error
      then do:
        undo, return error substitute( "&1. Ошибка при проверке на использование ДК &2:&3&4"
                                      , vss-workfile
                                      , buf_dis-card.d-card
                                      , chr(10)
                                      , error-status:get-message(1)
                                      ).
      end.
      if l-is-used then do:
        run discardh_write-dis-card-proc in this-procedure  (
                                                      buffer buf_dis-card
                                                      ,input (if g#news
                                                              then 'db':U
                                                              else (if g#esys
                                                                    then 'esys':U
                                                                    else "":U)
                                                              )
                                                      ,input  (if g#news
                                                                then string(g#news-source-db)
                                                                else (if g#esys
                                                                      then string(g#esys-source-esys)
                                                                      else "":U)
                                                                )
                                                    ) .
        assign
        buf_dis-card.status_  = v-old-status
        pc-err-msg = substitute( "&1. ДК &2 используется:&3&4"
                                 , vss-workfile
                                 , buf_dis-card.d-card
                                 , chr(10)
                                 , v-return-value
                                  )
        .
        return pc-err-msg.
      end.
    end.
  end.
end procedure.
procedure delete-dis-card :
define input  parameter pe-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pe-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pe-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pe-parameters   as   character                   no-undo .
define output parameter pe-err-msg      as   character                   no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v_bp-rowid         as rowid     no-undo .
    define variable v-d-card           like ub.dis-card.d-card no-undo .
    define variable l-is-used          as logical    no-undo .
    define variable v-old-status_      as character no-undo .
    define variable v-return-value     as character no-undo .
    define buffer buf_dis-card         for ub.dis-card .
    define buffer buf_c-dc-hist        for ub.c-dc-hist .
    define buffer buf_dis-card-property    for ub.dis-card-property .
    define buffer buf_c-dis-card-property  for ub.c-dis-card-property .
    define buffer buf_dis-obj          for ub.dis-obj .
    define buffer buf_c-dis-obj        for ub.c-dis-obj .
    define buffer buf_dis-host         for ub.dis-host .
    define buffer buf_c-dis-host       for ub.c-dis-host .
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
    if v-tbl-name <> 'dis-card':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей ДК", vss-workfile ).
    end.
    assign
    v-d-card = entry(1, pe-parameters, chr(4))
    v-old-status_ = entry(2, pe-parameters, chr(4))
    .
    find first buf_dis-card exclusive-lock where
              buf_dis-card.d-card = v-d-card no-wait no-error.
    if not available buf_dis-card
    and not locked(buf_dis-card) then do:
      find first buf_dis-card no-lock where
                  buf_dis-card.d-card = v-d-card no-error.
      if not available buf_dis-card then return.
    end.
    if not available buf_dis-card then do:
      return error substitute( "&1. Не найдена или занята ДК &2", vss-workfile, v-d-card ).
    end.
    if buf_dis-card.status_ <> 'неисп':U then do:
      return error substitute( "&1. ДК &2 не заблокирована для удаления", vss-workfile, buf_dis-card.d-card ).
    end.
    run proc-is-used-dis-card in this-procedure ( buffer buf_dis-card, input pe-db-num, output l-is-used) no-error .
    v-return-value = return-value .
    if error-status :error
    then do:
      undo, return error substitute( "&1. Ошибка при проверке на использование ДК &2:&3&4"
                                     , vss-workfile
                                     , buf_dis-card.d-card
                                     , chr(10)
                                     , error-status:get-message(1)
                                       ).
    end.
    if l-is-used then do:
      undo, return error substitute( "&1. ДК &2 используется &3&4"
                                    , vss-workfile
                                    , buf_dis-card.d-card
                                    , chr(10)
                                    , v-return-value
                                    ).
    end.
    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :
      delete buf_dis-card.
    end.
  end.
end procedure.
procedure undo-delete-dis-card :
define input  parameter pr-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pr-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pr-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pr-parameters   as   character                   no-undo .
define output parameter pr-err-msg      as   character                   no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v_bp-rowid         as rowid     no-undo .
    define variable v-d-card           like ub.dis-card.d-card no-undo .
    define variable v-new              as logical no-undo .
    define variable v-old-status_      as character no-undo .
    define buffer buf_db-rec-attr    for ub.db-rec-attr .
    define buffer buf_dis-card       for ub.dis-card    .
    define buffer buf_c-dis-card     for ub.c-dis-card.
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
    if v-tbl-name <> 'dis-card':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей ДК", vss-workfile ).
    end.
    assign
    v-d-card = entry(1, pr-parameters, chr(4))
    v-old-status_ = entry(2, pr-parameters, chr(4))
    .
    find first buf_dis-card exclusive-lock where
               rowid(buf_dis-card) = v-rowid no-error  .
    if not available buf_dis-card then do:
      find first buf_dis-card exclusive-lock where
                 buf_dis-card.d-card = v-d-card no-error no-wait.
      if not available buf_dis-card
      AND not LOCKED(buf_dis-card)
      then do:
        find first buf_dis-card no-lock where
                 buf_dis-card.d-card = v-d-card no-error.
        if not available buf_dis-card then do:
          find last buf_c-dis-card no-lock where
                    buf_c-dis-card.d-card = v-d-card
                and buf_c-dis-card.corr-user-db-num = g#db-num no-error.
          if available buf_c-dis-card then do:
             create buf_dis-card.
             buffer-copy buf_c-dis-card to buf_dis-card.
              run discardh_write-dis-card-proc in this-procedure  (
                                                            buffer buf_dis-card
                                                          ,input (if g#news
                                                                  then 'db':U
                                                                  else (if g#esys
                                                                        then 'esys':U
                                                                        else "":U)
                                                                  )
                                                          ,input  (if g#news
                                                                    then string(g#news-source-db)
                                                                    else (if g#esys
                                                                          then string(g#esys-source-esys)
                                                                          else "":U)
                                                                    )
                                                          ) .
             assign
             buf_dis-card.status_ = v-old-status_
             .
             return.
          end.
        end.
        return error substitute( "&1. Не найдена или занята ДК &2", vss-workfile, v-d-card ).
      end.
    end.
    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :
      if buf_dis-card.status_ = 'неисп':U then do:
        run discardh_write-dis-card-proc in this-procedure  (
                                                      buffer buf_dis-card
                                                    ,input (if g#news
                                                            then 'db':U
                                                            else (if g#esys
                                                                  then 'esys':U
                                                                  else "":U)
                                                            )
                                                    ,input  (if g#news
                                                              then string(g#news-source-db)
                                                              else (if g#esys
                                                                    then string(g#esys-source-esys)
                                                                    else "":U)
                                                              )
                                                    ) .
        assign
        buf_dis-card.status_ = v-old-status_
        .
        release buf_dis-card.
      end.
    end.
  end.
end procedure.
procedure proc-is-used-dis-card :
define parameter buffer buf_dis-card for ub.dis-card.
define input parameter p-db-num like ub.db.db-num no-undo .
define output parameter p-is-used as logical no-undo init yes.
  do
  on error undo, return error return-value
  :
    define buffer buf_dis-card-property for ub.dis-card-property.
    define buffer buf_dis-obj for ub.dis-obj.
    define buffer buf2_dis-card for ub.dis-card.
    define buffer buf_dis-host for ub.dis-host.
    define buffer buf_chk-doc for ub.chk-doc.
    define buffer buf_clients for ub.clients.
    define buffer buf_payment for ub.payment.
    define buffer buf_sysconf for ub.sysconf.
    for each buf2_dis-card no-lock where
            buf2_dis-card.card-num = buf_dis-card.card-num:
      if buf2_dis-card.d-card = buf_dis-card.d-card then next.
      return substitute("dis-card Перевыпущенная карта &1 для карты &2", buf2_dis-card.d-card, buf_dis-card.d-card).
    end.
    for each buf_sysconf,
        each buf_payment no-lock where
            buf_payment.cli-type = buf_dis-card.cli-type
        and buf_payment.cli-code = buf_dis-card.cli-code
        and buf_payment.d-card = buf_dis-card.d-card :
      return substitute("payment Платеж &1 на фирму &2 для карты &2", buf_payment.pmnt-code, buf_payment.host-code, buf_dis-card.d-card).
    end.
    for each buf_clients no-lock where
            buf_clients.obj-type = 'маг':U
        and buf_clients.db-num = g#db-num:
       find first buf_chk-doc no-lock where
                buf_chk-doc.obj-type = buf_Clients.obj-type
            and buf_chk-doc.obj-code = buf_Clients.obj-code
            and buf_chk-doc.d-card = buf_dis-card.d-card no-error.
       if available buf_chk-doc then do:
         return substitute("chk-doc Чек &1 для карты &2", buf_chk-doc.doc-code, buf_dis-card.d-card).
       end.
    end.
    for each buf_dis-obj no-lock where
            buf_dis-obj.d-card = buf_dis-card.d-card:
      if buf_dis-obj.pay-tot-rubl <> 0
      or buf_dis-obj.num-chk <> 0
      or buf_dis-obj.gds-tot-rubl <> 0  then do:
        return substitute("dis-obj Итоги на объекте &1&2 для карты &3", buf_dis-obj.obj-type, buf_dis-obj.obj-code, buf_dis-card.d-card).
      end.
    end.
    for each buf_dis-host no-lock where
            buf_dis-host.d-card = buf_dis-card.d-card:
      if buf_dis-host.pay-tot-rubl <> 0
      or buf_dis-host.num-chk <> 0
      or buf_dis-host.gds-tot-rubl <> 0  then do:
        if buf_dis-host.host-code > 0 then
        return substitute("dis-host Итоги на фирме &1 для карты &2", buf_dis-host.host-code, buf_dis-card.d-card).
        else
        return substitute("dis-host Глобальные итоги").
      end.
    end.
    assign
    p-is-used = no
    .
    return "":U.
  end.
end procedure.
procedure block-chown-dis-card :
define input  parameter pc-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pc-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pc-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pc-parameters   as   character                   no-undo .
define output parameter pc-err-msg      as   character                   no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-rowid    as rowid     no-undo .
    define variable v-tbl-name as character no-undo .
    define variable v-is-prt-bar-code as logical no-undo .
    define variable l-terminal-prt as logical no-undo .
    define variable l-is-used as logical no-undo init yes.
    define variable v-old-status as character no-undo .
    define variable v-return-value as character no-undo .
    define buffer buf_dis-card for ub.dis-card.
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
    if v-tbl-name <> 'dis-card':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей ДК", vss-workfile ).
    end.
    find first buf_dis-card
      where rowid( buf_dis-card ) = v-rowid
      no-error .
    if not available buf_dis-card then do:
      return error substitute( "&1. Нет необходимой ДК &2", vss-workfile, pc-uniq-key-rec ).
    end.
    if buf_dis-card.status_ = 'смкли':U
    or buf_dis-card.status_ = 'неисп':U
    then do:
      assign
      pc-err-msg = substitute( "ДК &1 уже заблокирована или удалена!!! Блокировка невозможна!!!", pc-uniq-key-rec )
      .
      return .
    end.
    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :
      run discardh_write-dis-card-proc in this-procedure  (
                                                    buffer buf_dis-card
                                                    ,input (if g#news
                                                            then 'db':U
                                                            else (if g#esys
                                                                  then 'esys':U
                                                                  else "":U)
                                                            )
                                                    ,input  (if g#news
                                                              then string(g#news-source-db)
                                                              else (if g#esys
                                                                    then string(g#esys-source-esys)
                                                                    else "":U)
                                                              )
                                                  ) .
      assign
      v-old-status = buf_dis-card.status_
      buf_dis-card.status_ = 'неисп':U
      .
      run proc-is-used-trn-doc-dis-card in this-procedure ( buffer buf_dis-card
                                                          , input pc-db-num
                                                          , output l-is-used) no-error .
      v-return-value = return-value .
      if error-status :error
      then do:
        undo, return error substitute( "&1. Ошибка при проверке на использование ДК &2:&3&4"
                                      , vss-workfile
                                      , buf_dis-card.d-card
                                      , chr(10)
                                      , error-status:get-message(1)
                                      ).
      end.
      if l-is-used then do:
        run discardh_write-dis-card-proc in this-procedure  (
                                                      buffer buf_dis-card
                                                    ,input (if g#news
                                                            then 'db':U
                                                            else (if g#esys
                                                                  then 'esys':U
                                                                  else "":U)
                                                            )
                                                    ,input  (if g#news
                                                              then string(g#news-source-db)
                                                              else (if g#esys
                                                                    then string(g#esys-source-esys)
                                                                    else "":U)
                                                              )
                                                    ) .
        assign
        buf_dis-card.status_  = v-old-status
        pc-err-msg = substitute( "&1. ДК &2 используется:&3&4"
                                  , vss-workfile
                                  , buf_dis-card.d-card
                                  , chr(10)
                                  , v-return-value
                                  )
        .
        return pc-err-msg.
      end.
    end.
  end.
end procedure.
procedure chown-dis-card :
define input  parameter pe-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pe-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pe-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pe-parameters   as   character                   no-undo .
define output parameter pe-err-msg      as   character                   no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v_bp-rowid         as rowid     no-undo .
    define variable v-d-card           like ub.dis-card.d-card no-undo .
    define variable l-is-used          as logical    no-undo .
    define variable v-old-status_      as character no-undo .
    define variable v-cli-type         like ub.dis-card.cli-type.
    define variable v-cli-code         like ub.dis-card.cli-code.
    define variable v-old-cli-type     like ub.dis-card.cli-type.
    define variable v-old-cli-code     like ub.dis-card.cli-code.
    define variable v-return-value     as character no-undo .
    define buffer buf_dis-card         for ub.dis-card .
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
    if v-tbl-name <> 'dis-card':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей ДК", vss-workfile ).
    end.
    assign
    v-d-card = entry(1, pe-parameters, chr(4))
    v-old-status_ = entry(2, pe-parameters, chr(4))
    v-cli-type = entry(3, pe-parameters, chr(4))
    v-cli-code = integer(entry(4, pe-parameters, chr(4)))
    v-old-cli-type = entry(5, pe-parameters, chr(4))
    v-old-cli-code = integer(entry(6, pe-parameters, chr(4)))
    .
    find first buf_dis-card exclusive-lock where
              buf_dis-card.d-card = v-d-card no-wait no-error.
    if not available buf_dis-card
    and not locked(buf_dis-card) then do:
      find first buf_dis-card no-lock where
                  buf_dis-card.d-card = v-d-card no-error.
      if not available buf_dis-card then return.
    end.
    if not available buf_dis-card then do:
      return error substitute( "&1. Не найдена или занята ДК &2", vss-workfile, v-d-card ).
    end.
    if buf_dis-card.status_ <> 'смкли':U then do:
      return error substitute( "&1. ДК &2 не заблокирована для смены владельца", vss-workfile, buf_dis-card.d-card ).
    end.
    run proc-is-used-trn-doc-dis-card in this-procedure ( buffer buf_dis-card, input pe-db-num, output l-is-used) no-error .
    v-return-value = return-value .
    if error-status :error
    then do:
      undo, return error substitute( "&1. Ошибка при проверке на использование ДК &2:&3&4"
                                     , vss-workfile
                                     , buf_dis-card.d-card
                                     , chr(10)
                                     , error-status:get-message(1)
                                       ).
    end.
    if l-is-used then do:
      undo, return error substitute( "&1. ДК &2 используется &3&4"
                                    , vss-workfile
                                    , buf_dis-card.d-card
                                    , chr(10)
                                    , v-return-value
                                    ).
    end.
    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :
       run proc-chown-dis-card in this-procedure ( buffer buf_dis-card
                                                  ,input v-cli-type
                                                  ,input v-cli-code
                                                  ).
    end.
  end.
end procedure.
procedure undo-chown-dis-card :
define input  parameter pr-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pr-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pr-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pr-parameters   as   character                   no-undo .
define output parameter pr-err-msg      as   character                   no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v_bp-rowid         as rowid     no-undo .
    define variable v-d-card           like ub.dis-card.d-card no-undo .
    define variable v-new              as logical no-undo .
    define variable v-old-status_      as character no-undo .
    define variable v-cli-type         like ub.dis-card.cli-type.
    define variable v-cli-code         like ub.dis-card.cli-code.
    define variable v-old-cli-type     like ub.dis-card.cli-type.
    define variable v-old-cli-code     like ub.dis-card.cli-code.
    define buffer buf_db-rec-attr    for ub.db-rec-attr .
    define buffer buf_dis-card       for ub.dis-card    .
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
    if v-tbl-name <> 'dis-card':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей ДК", vss-workfile ).
    end.
    assign
    v-d-card = entry(1, pr-parameters, chr(4))
    v-old-status_ = entry(2, pr-parameters, chr(4))
    v-cli-type = entry(3, pr-parameters, chr(4))
    v-cli-code = integer(entry(4, pr-parameters, chr(4)))
    v-old-cli-type = entry(5, pr-parameters, chr(4))
    v-old-cli-code = integer(entry(6, pr-parameters, chr(4)))
    .
    find first buf_dis-card exclusive-lock where
               rowid(buf_dis-card) = v-rowid no-error  .
    if not available buf_dis-card then do:
      find first buf_dis-card exclusive-lock where
                 buf_dis-card.d-card = v-d-card no-error no-wait.
      if not available buf_dis-card
      AND not LOCKED(buf_dis-card)
      then do:
        find first buf_dis-card no-lock where
                 buf_dis-card.d-card = v-d-card no-error.
        if not available buf_dis-card then do:
          return .
        end.
        return error substitute( "&1. Не найдена или занята ДК &2", vss-workfile, v-d-card ).
      end.
    end.
    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :
      if not (buf_dis-card.cli-type = v-old-cli-type
        and    buf_dis-card.cli-code = v-old-cli-code) then do:
        run proc-chown-dis-card in this-procedure ( buffer buf_dis-card
                                                    ,input v-old-cli-type
                                                    ,input v-old-cli-code
                                                    ).
      end.
    end.
  end.
end procedure.
procedure after-chown-dis-card :
define input  parameter pa-action       as character no-undo .
define input  parameter pa-uniq-key-rec as character no-undo .
define input  parameter pa-db-init      as integer   no-undo .
define input  parameter pa-parameters   as character no-undo .
define output parameter pa-err-msg      as character no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v_bp-rowid         as rowid     no-undo .
    define variable v-d-card           like ub.dis-card.d-card no-undo .
    define variable l-is-used          as logical    no-undo .
    define variable v-old-status_      as character no-undo .
    define variable v-cli-type         like ub.dis-card.cli-type.
    define variable v-cli-code         like ub.dis-card.cli-code.
    define variable v-old-cli-type     like ub.dis-card.cli-type.
    define variable v-old-cli-code     like ub.dis-card.cli-code.
    define buffer buf_dis-card         for ub.dis-card .
    run gen-row-keyr in this-procedure
      ( input  pa-uniq-key-rec
       ,input ?
       ,input "ub":U
       ,input ?
       ,input share-lock
       ,output v-rowid
       ,output v-tbl-name
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при определении rowid записи для ключа &2. chr(10) &3", vss-workfile, pa-uniq-key-rec, return-value ).
    end.
    if v-tbl-name <> 'dis-card':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей ДК", vss-workfile ).
    end.
    assign
    v-d-card = entry(1, pa-parameters, chr(4))
    v-old-status_ = entry(2, pa-parameters, chr(4))
    v-cli-type = entry(3, pa-parameters, chr(4))
    v-cli-code = integer(entry(4, pa-parameters, chr(4)))
    v-old-cli-type = entry(5, pa-parameters, chr(4))
    v-old-cli-code = integer(entry(6, pa-parameters, chr(4)))
    .
    find first buf_dis-card exclusive-lock where
              buf_dis-card.d-card = v-d-card no-wait no-error.
    if not available buf_dis-card
    and not locked(buf_dis-card) then do:
      find first buf_dis-card no-lock where
                  buf_dis-card.d-card = v-d-card no-error.
      if not available buf_dis-card then return.
    end.
    if not available buf_dis-card then do:
      return error substitute( "&1. Не найдена или занята ДК &2", vss-workfile, v-d-card ).
    end.
    do
    on error undo, return error return-value
    on stop undo, return error return-value
    :
       if buf_dis-card.status_ = 'смкли':U then do:
          run discardh_write-dis-card-proc in this-procedure  (
                                                        buffer buf_dis-card
                                                      ,input (if g#news
                                                              then 'db':U
                                                              else (if g#esys
                                                                    then 'esys':U
                                                                    else "":U)
                                                              )
                                                      ,input  (if g#news
                                                                then string(g#news-source-db)
                                                                else (if g#esys
                                                                      then string(g#esys-source-esys)
                                                                      else "":U)
                                                                )
                                                      ) .
        assign
        buf_dis-card.status_ = v-old-status_
        .
      end.
    end.
  end.
end procedure.
procedure proc-is-used-trn-doc-dis-card :
define parameter buffer buf_dis-card for ub.dis-card.
define input parameter p-db-num like ub.db.db-num no-undo .
define output parameter p-is-used as logical no-undo init yes.
  do
  on error undo, return error return-value
  :
    define buffer buf_dis-card-property for ub.dis-card-property.
    define buffer buf_dis-obj for ub.dis-obj.
    define buffer buf2_dis-card for ub.dis-card.
    define buffer buf_clients for ub.clients.
    define buffer buf_sysconf for ub.sysconf.
    define buffer buf_payment for ub.payment.
    define buffer buf_trn-doc for ub.trn-doc.
    for each buf2_dis-card no-lock where
            buf2_dis-card.card-num = buf_dis-card.card-num:
      if buf2_dis-card.d-card = buf_dis-card.d-card then next.
      return substitute("dis-card Перевыпущенная карта &1 для карты &2", buf2_dis-card.d-card, buf_dis-card.d-card).
    end.
    for each buf_sysconf,
        each buf_payment no-lock where
            buf_payment.cli-type = buf_dis-card.cli-type
        and buf_payment.cli-code = buf_dis-card.cli-code
        and buf_payment.d-card = buf_dis-card.d-card :
      if buf_payment.source-type <> 'касс':U then do:
        return substitute("payment Платеж &1 на фирму &2 для документа &3 для карты &4"
                         , buf_payment.pmnt-code
                         , buf_payment.host-code
                         , buf_payment.source-ref
                         , buf_dis-card.d-card
                         ).
      end.
    end.
    for each buf_clients no-lock where
           buf_clients.db-num = g#db-num:
       for each buf_trn-doc no-lock where
                buf_trn-doc.obj-type = buf_Clients.obj-type
            and buf_trn-doc.obj-code = buf_Clients.obj-code
            and buf_trn-doc.cli-type = buf_dis-card.cli-type
            and buf_trn-doc.cli-code = buf_dis-card.cli-code:
         if buf_trn-doc.d-card = buf_dis-card.d-card then do:
           return substitute("trn-doc Документ &1 для карты &2", buf_trn-doc.doc-code, buf_dis-card.d-card).
         end.
       end.
    end.
    assign
    p-is-used = no
    .
    return "":U.
  end.
end procedure.
procedure proc-chown-dis-card :
define parameter buffer buf_dis-card for ub.dis-card.
define input parameter p-cli-type like ub.dis-card.cli-type no-undo .
define input parameter p-cli-code like ub.dis-card.cli-code no-undo .
define variable v-is-update as logical no-undo .
define variable v-chip-num as integer no-undo .
define buffer buf_chk-doc          for ub.chk-doc .
define buffer buf_chk-gds          for ub.chk-gds .
define buffer buf_clients          for ub.clients.
define buffer buf_sysconf          for ub.sysconf.
define buffer buf_payment          for ub.payment.
  do
  on error undo, return error return-value
  :
    for each buf_sysconf,
        each buf_payment where
            buf_payment.host-code = buf_sysconf.host-code
        and buf_payment.d-card = buf_dis-card.d-card
    on error undo, return error return-value
        :
      if buf_payment.source-type = 'касс':U then do:
        if buf_payment.payer-type = buf_payment.cli-type
        and buf_payment.payer-code = buf_payment.cli-code
        then
        assign
        buf_payment.payer-type = p-cli-type
        buf_payment.payer-code = p-cli-code
        .
        assign
        buf_payment.cli-type = p-cli-type
        buf_payment.cli-code = p-cli-code
        .
      end.
    end.
    for each buf_clients no-lock where
            buf_clients.obj-type = 'маг':U:
      for each buf_chk-doc where
                buf_chk-doc.obj-type = buf_Clients.obj-type
            and buf_chk-doc.obj-code = buf_Clients.obj-code
            and buf_chk-doc.d-card = buf_dis-card.d-card:
          run trg/chk-doch.p (
                          buffer buf_chk-doc
                        , input no
                        , input no
                        , input no
                        , input-output v-chip-num
                        , output v-is-update).
        for each buf_chk-gds where
                buf_chk-gds.doc-code = buf_chk-doc.doc-code:
          if buf_chk-gds.d-card = buf_dis-card.d-card
          then
          assign
          buf_chk-gds.cli-type = p-cli-type
          buf_chk-gds.cli-code = p-cli-code
          .
        end.
        assign
        buf_chk-doc.cli-type = p-cli-type
        buf_chk-doc.cli-code = p-cli-code
        .
        run trg/chk-doch.p (
                        buffer buf_chk-doc
                      , input yes
                      , input no
                      , input no
                      , input-output v-chip-num
                      , output v-is-update).
      end.
      assign
      buf_dis-card.cli-type = p-cli-type
      buf_dis-card.cli-code = p-cli-code
      .
    end.
  end.
end procedure.
