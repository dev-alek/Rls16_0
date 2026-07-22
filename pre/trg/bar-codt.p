block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для распределенной обработки бар-кодов".
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
procedure is-prt-bar-code :
define input parameter p-b-code like ub.bar-code.b-code no-undo .
define input parameter p-node-code like ub.bar-code.node-code no-undo .
define input parameter p-part-code like ub.bar-code.part-code no-undo .
define input parameter p-in-code    like ub.bar-code.in-code no-undo .
define input parameter p-unit-cli   like ub.bar-code.unit-cli no-undo .
define output parameter p-is as logical no-undo .
define variable vss-description as character no-undo init "is-prt-bar-code-01: определяет является ли бар-код бар-кодом признака".
  do
  on error undo, return error
  :
    define buffer buf_gds-prt for ub.gds-prt.
    define buffer root_gds-prt for ub.gds-prt.
    find first buf_gds-prt no-lock where
               buf_gds-prt.node-code = p-node-code  no-error .
    if not available buf_gds-prt then do:
      return error substitute( "&1. Не найден узел шкалы для бар-кода &2", vss-workfile, string(p-b-code) ).
    end.
    find first root_gds-prt no-lock where
               root_gds-prt.prt-root = buf_gds-prt.prt-root
          AND  root_gds-prt.root     = yes no-error .
    if not avail root_gds-prt
    or root_gds-prt.node-name = '_Пустая шкала':U
    then do:
      return error substitute( "&1. Узел шкалы для бар-кода &2, относится к <ПУСТОЙ ШКАЛЕ>", vss-workfile, string(p-b-code) ).
    end.
    if p-in-code <> "":u
    and root_gds-prt.root = yes
    then do:
      return error substitute( "&1. Бар-код &2, является бар-кодом ПАРТИИ", vss-workfile, string(p-b-code) ).
    end.
    assign
    p-is = yes
    .
    return "":U.
  end.
end procedure.
procedure is-part-bar-code :
define input parameter p-b-code like ub.bar-code.b-code no-undo .
define input parameter p-node-code like ub.bar-code.node-code no-undo .
define input parameter p-part-code like ub.bar-code.part-code no-undo .
define input parameter p-in-code    like ub.bar-code.in-code no-undo .
define input parameter p-unit-cli   like ub.bar-code.unit-cli no-undo .
define output parameter p-is as logical no-undo .
define variable vss-description as character no-undo init "is-part-bar-code-01: определяет является ли бар-код партионным".
  do
  on error undo, return error
  :
    define buffer buf_gds-prt for ub.gds-prt.
    find first buf_gds-prt no-lock where
               buf_gds-prt.node-code = p-node-code  no-error .
    if not available buf_gds-prt
    then do:
      return error substitute( "&1. Не найден узел шкалы для бар-кода &2", vss-workfile, string(p-b-code) ).
    end.
    if p-in-code = "":U then do:
      return error substitute( "&1. Бар-код &2, относится НЕ к <ПАРТИИ>", vss-workfile, string(p-b-code) ).
    end.
    if buf_gds-prt.root <> yes
    then do:
      return error substitute( "&1. Узел шкалы для бар-кода &2, не является корневым", vss-workfile, string(p-b-code) ).
    end.
    assign
    p-is = yes
    .
    return "":U.
  end.
end procedure.
procedure is-ucli-bar-code :
define input parameter p-b-code like ub.bar-code.b-code no-undo .
define input parameter p-node-code like ub.bar-code.node-code no-undo .
define input parameter p-part-code like ub.bar-code.part-code no-undo .
define input parameter p-in-code    like ub.bar-code.in-code no-undo .
define input parameter p-unit-cli   like ub.bar-code.unit-cli no-undo .
define input parameter p-gds-code like ub.bar-code.gds-code no-undo .
define output parameter p-is as logical no-undo .
define variable vss-description as character no-undo init "is-ucli-bar-code-01: определяет является ли бар-код бар-кодом на доп.ед.изм.".
  do
  on error undo, return error
  :
    define buffer buf_goods for ub.goods.
    find first buf_goods no-lock where
              buf_goods.gds-code = p-gds-code no-error .
    if not available buf_goods then do:
      return error substitute( "&1. Не найден товар для бар-кода &2", vss-workfile, string(p-b-code) ).
    end.
    if buf_goods.unit-base = p-unit-cli then do:
      return error substitute( "&1. Бар-код &2, относится к осн ед.изм.: осн.ид.изм. &3, ед.изм.бар-кода &4", vss-workfile, string(p-b-code), buf_goods.unit-base, p-unit-cli).
    end.
    assign
    p-is = yes
    .
    return "":U.
  end.
end procedure.
def new shared var bc-frmt as character no-undo .
def new shared var bc-pfx  as character no-undo .
def var bc-par-type as character no-undo .
    run gbl/conf-rd.p ("bc-frmt", "", "", 0, "", "", "",  no , output bc-frmt, output bc-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR bc-par-type <> "C":U OR not can-do ("EAN8,EAN13", bc-frmt) ) then
        do:
            message "Не задан или не верно задан ТИП собственного бар-кода!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
    run gbl/conf-rd.p ("bc-pfx", "", "", 0, "", "", "",  no , output bc-pfx, output bc-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR bc-par-type <> "C":U ) then
        do:
            message "Не задан или не верно задан ПРЕФИКС бар-кода складского места!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
PROCEDURE gen-bc:
  def input  parameter internal-b-code like ub.bar-code.b-code no-undo .
  def output parameter full-b-code     as character init ""    no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str2  as character no-undo.
  define variable tmp-num2  as character no-undo.
  define variable i2        as integer   no-undo.
  define variable sum2      as integer   no-undo.
  define variable len-code2 as integer   no-undo.
  define variable varcont2  as logical   initial yes no-undo.
  CASE bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str2 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str2 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " bc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont2 = yes then do:
    if integer( substring( tmp-str2, 1, length( bc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = bc-pfx + substring( tmp-str2, length( bc-pfx ) + 1, length( tmp-str2 ) - length( bc-pfx ) )
        len-code2    = length( full-b-code )
      .
      define variable v-sum-char2 as character no-undo .
      assign
        sum2 = 0
      .
      do i2 = 1 to len-code2 by 2
      :
        assign
          v-sum-char2 = substr(full-b-code, len-code2 - i2 + 1, 1)
        .
        if v-sum-char2 < "0"
        or v-sum-char2 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum2 = sum2 + integer(v-sum-char2)
        .
      end.
      if varcont2 = yes then do:
        assign
          sum2 = sum2 * 3
        .
        do i2 = 2 to len-code2 by 2
        :
          assign
            v-sum-char2 = substr(full-b-code, len-code2 - i2 + 1, 1)
          .
          if v-sum-char2 < "0"
          or v-sum-char2 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum2 = sum2 + integer(v-sum-char2)
          .
        end.
        if varcont2 = yes then do:
           if sum2 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum2 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
END PROCEDURE.
procedure block-del-prt-bar-code :
define input  parameter pc-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pc-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pc-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pc-parameters   as   character                   no-undo .
define output parameter pc-err-msg      as   character                   no-undo .
  do
  on error undo, return error
  :
    define variable v-rowid    as rowid     no-undo .
    define variable v-tbl-name as character no-undo .
    define variable v-is-prt-bar-code as logical no-undo .
    define variable l-terminal-prt as logical no-undo .
    define variable l-is-used as logical no-undo init yes.
    define variable v-old-stts as integer no-undo .
    define buffer buf_bar-code for ub.bar-code.
    define buffer buf_gds-prt for ub.gds-prt.
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
    if v-tbl-name <> 'bar-code':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей бар-кодов", vss-workfile ).
    end.
    find first buf_bar-code
      where rowid( buf_bar-code ) = v-rowid
      no-error .
    if not available buf_bar-code then do:
      return error substitute( "&1. Нет необходимого бар-кода &2", vss-workfile, pc-uniq-key-rec ).
    end.
    if buf_bar-code.stts = integer('99':U) then do:
      assign
      pc-err-msg = substitute( "Бар-код &1 уже заблокирован или удален!!! Блокировка невозможна!!!", pc-uniq-key-rec )
      .
      return .
    end.
    if buf_bar-code.stts_ <> 0
    and not (buf_bar-code.stts_ = integer('79':U))
    then do:
      return error substitute( "&1. Необходимый бар-код &2 находится в статусе &3", vss-workfile, buf_bar-code.b-code, buf_bar-code.stts_  ).
    end.
    run is-prt-bar-code in this-procedure (
                                           input buf_bar-code.b-code
                                          ,input buf_bar-code.node-code
                                          ,input buf_bar-code.part-code
                                          ,input buf_bar-code.in-code
                                          ,input buf_bar-code.unit-cli
                                          ,output v-is-prt-bar-code) no-error .
    if error-status:error then do:
      return error substitute( "&1. Ошибка при проверке является ли бар-код &2 бар-кодом признака: &3", vss-workfile, buf_bar-code.b-code, return-value ).
    end.
    if not v-is-prt-bar-code then do:
      return error substitute( "&1. Бар-код &2 не является бар-кодом признака", vss-workfile, buf_bar-code.b-code ).
    end.
    find first buf_gds-prt no-lock where
               buf_gds-prt.node-code = buf_bar-code.node-code  no-error .
    if not available buf_gds-prt then do:
      return error substitute( "&1. Не найден узел шкалы для бар-кода &2", vss-workfile, buf_bar-code.b-code ).
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  buf_gds-prt.node-code
  ,input  'terminal-prt=request':u
  ,output l-terminal-prt
  ) no-error .
    if error-status :error
    then do:
      message return-value error-status:get-message(1) view-as alert-box .
      return error substitute( "&1. Ошибка при определении терминальности признака для бар-кода &2", vss-workfile, buf_bar-code.b-code ).
    end.
    do
    on error undo, return error
    on stop undo, return error
    :
      assign
      v-old-stts = buf_bar-code.stts_
      buf_bar-code.stts_ = integer('99':U)
      .
      run proc-is-used-prt-bar-code in this-procedure (buffer buf_bar-code, input pc-db-num, input l-terminal-prt, output l-is-used) no-error .
      if error-status :error
      then do:
        undo, return error substitute( "&1. Ошибка при проверке на использование в товародвижении бар-кода &2:&3&4"
                                      , vss-workfile
                                      , buf_bar-code.b-code
                                      , chr(10)
                                      , error-status:get-message(1)
                                      ).
      end.
      if l-is-used then do:
        assign
        buf_bar-code.stts_ = v-old-stts
        pc-err-msg = substitute( "&1. Бар-код &2 используется в товародвижении:&3&4"
                                 , vss-workfile
                                 , buf_bar-code.b-code
                                 , chr(10)
                                 , return-value
                                  )
        .
        return pc-err-msg.
      end.
    end.
  end.
end procedure.
procedure delete-prt-bar-code :
define input  parameter pe-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pe-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pe-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pe-parameters   as   character                   no-undo .
define output parameter pe-err-msg      as   character                   no-undo .
  do
  on error undo, return error
  :
    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v_bp-rowid         as rowid     no-undo .
    define variable v-is-prt-bar-code as logical no-undo .
    define variable v-b-code like ub.bar-code.b-code no-undo .
    define variable l-is-used          as logical    no-undo .
    define buffer buf_bar-code         for ub.bar-code .
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
    if v-tbl-name <> 'bar-code':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей бар-кодов", vss-workfile ).
    end.
    assign
    v-b-code = integer(entry(1, pe-parameters, chr(4)))
    .
    find first buf_bar-code exclusive-lock where
              buf_bar-code.b-code = v-b-code no-wait no-error.
    if not available buf_bar-code
    and not locked(buf_bar-code) then do:
      find first buf_bar-code no-lock where
                  buf_bar-code.b-code = v-b-code no-error.
      if not available buf_bar-code then return.
    end.
    if not available buf_bar-code then do:
      return error substitute( "&1. Не найден или занят бар-код &2", vss-workfile, v-b-code ).
    end.
    if buf_bar-code.stts_ <> integer('99':U) then do:
      return error substitute( "&1. Бар-код &2 не заблокирован для удаления", vss-workfile, buf_bar-code.b-code ).
    end.
    run is-prt-bar-code in this-procedure (
                                           input buf_bar-code.b-code
                                          ,input buf_bar-code.node-code
                                          ,input buf_bar-code.part-code
                                          ,input buf_bar-code.in-code
                                          ,input buf_bar-code.unit-cli
                                          , output v-is-prt-bar-code) no-error .
    if error-status:error then do:
      return error substitute( "&1. Ошибка при проверке является ли бар-код &2 бар-кодом признака: &3", vss-workfile, buf_bar-code.b-code, return-value ).
    end.
    if not v-is-prt-bar-code then do:
      return error substitute( "&1. Бар-код &2 не является бар-кодом признака", vss-workfile, buf_bar-code.b-code).
    end.
    run proc-is-used-prt-bar-code in this-procedure (buffer buf_bar-code, input pe-db-num, input ?, output l-is-used) no-error .
    if error-status :error
    then do:
      undo, return error substitute( "&1. Ошибка при проверке на использование в товародвижении бар-кода &2:&3&4"
                                     , vss-workfile
                                     , buf_bar-code.b-code
                                     , chr(10)
                                     , error-status:get-message(1)
                                       ).
    end.
    if l-is-used then do:
      undo, return error substitute( "&1. Бар-код &2 используется в товародвижении&3&4"
                                    , vss-workfile
                                    , buf_bar-code.b-code
                                    , chr(10)
                                    , return-value
                                    ).
    end.
    do
    on error undo, return error
    on stop undo, return error
    :
      delete buf_bar-code.
    end.
  end.
end procedure.
procedure undo-delete-prt-bar-code :
define input  parameter pr-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pr-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pr-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pr-parameters   as   character                   no-undo .
define output parameter pr-err-msg      as   character                   no-undo .
  do
  on error undo, return error
  :
    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v_bp-rowid         as rowid     no-undo .
    define variable v-gds-code like ub.goods.gds-code no-undo .
    define variable v-b-code like ub.bar-code.b-code no-undo .
    define variable v-node-code like ub.bar-code.node-code no-undo .
    define variable v-part-code like ub.bar-code.part-code no-undo .
    define variable v-in-code    like ub.bar-code.in-code no-undo .
    define variable v-unit-cli   like ub.bar-code.unit-cli no-undo .
    define variable v-cli-base-rate like ub.bar-code.cli-base-rate no-undo .
    define variable v-new  as logical no-undo .
    define variable v-old-stts as integer no-undo .
    define buffer buf_db-rec-attr    for ub.db-rec-attr .
    define buffer buf_bar-code       for ub.bar-code    .
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
    if v-tbl-name <> 'bar-code':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей бар-кодов", vss-workfile ).
    end.
    find first buf_bar-code exclusive-lock where
               rowid(buf_bar-code) = v-rowid no-error  .
    if not available buf_bar-code then do:
      assign
      v-b-code = integer(entry(1, pr-parameters, chr(4)))
      v-old-stts = integer(entry(8, pr-parameters, chr(4)))
      .
      find first buf_bar-code exclusive-lock where
                 buf_bar-code.b-code = v-b-code no-error no-wait.
      if not available buf_bar-code
      AND not LOCKED(buf_bar-code)
      then do:
        find first buf_bar-code no-lock where
                 buf_bar-code.b-code = v-b-code no-error.
        if not available buf_bar-code then do:
          return .
        end.
        return error substitute( "&1. Нт найден или занят бакрод &2", vss-workfile, v-b-code ).
      end.
    end.
    do
    on error undo, return error
    on stop undo, return error
    :
      if buf_bar-code.stts_ = integer('99':U) then do:
        assign
        buf_bar-code.stts_ = v-old-stts.
        release buf_bar-code.
      end.
    end.
  end.
end procedure.
procedure proc-is-used-prt-bar-code :
define parameter buffer buf_bar-code for ub.bar-code.
define input parameter p-db-num like ub.db.db-num no-undo .
define input parameter p-terminal-prt  as logical no-undo .
define output parameter p-is-used as logical no-undo init yes.
  do
  on error undo, return error
  :
    define variable v-artic  like ub.goods.artic no-undo .
    define variable v-prod-type  like ub.goods.prod-type no-undo .
    define variable v-prod-code  like ub.goods.prod-code no-undo .
    define variable v-is-prt-bar-code as logical no-undo .
    define buffer buf_goods for ub.goods.
    define buffer buf_prt-obj for ub.prt-obj.
    define buffer buf_prod-bc for ub.prod-bc.
    define buffer buf_prod-bc-db for ub.prod-bc-db.
    define buffer buf_clients for ub.clients.
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_scales-gds for ub.scales-gds.
    define buffer buf_sert-join for ub.sert-join.
    define buffer buf_price-list for ub.price-list.
    define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds.
    define buffer buf_dis-gds-rule for ub.dis-gds-rule.
    define buffer buf_gds-dtl for ub.gds-dtl.
    define buffer buf_ord-dtl for ub.ord-dtl.
    define buffer buf_ord-dtl-cons for ub.ord-dtl-cons.
    define buffer buf_ord-dtl-rcv for ub.ord-dtl-rcv.
    define buffer buf_tmp-sale-dtl for ub.tmp-sale-dtl.
    run is-prt-bar-code in this-procedure (
                                           input buf_bar-code.b-code
                                          ,input buf_bar-code.node-code
                                          ,input buf_bar-code.part-code
                                          ,input buf_bar-code.in-code
                                          ,input buf_bar-code.unit-cli
                                          , output v-is-prt-bar-code) no-error .
    if error-status:error then do:
      return error substitute( "&1. Ошибка при проверке является ли бар-код &2 бар-кодом признака: &3", vss-workfile, string(buf_bar-code.b-code), return-value ).
    end.
    if not v-is-prt-bar-code then do:
      return error substitute( "&1. Бар-код &2 не является бар-кодом признака", vss-workfile, buf_bar-code.b-code).
    end.
    find first buf_goods no-lock where
               buf_goods.gds-code = buf_bar-code.gds-code no-error .
    if not avail buf_goods then return error.
    find first buf_prt-obj no-lock where
               buf_prt-obj.artic = buf_goods.artic
           AND buf_prt-obj.prod-type = buf_goods.prod-type
           AND buf_prt-obj.prod-code = buf_goods.prod-code
           AND buf_prt-obj.prt-code  = buf_bar-code.node-code no-error .
    if available buf_prt-obj then
    return substitute("prt-obj объект &1&2", buf_prt-obj.obj-type, buf_prt-obj.obj-code).
    find first buf_prod-bc no-lock where
               buf_prod-bc.b-code = buf_bar-code.b-code no-error .
    if available buf_prod-bc then
    return substitute("prod-bc ДопБК &1" + buf_prod-bc.b-str).
    find first buf_prod-bc-db no-lock where
               buf_prod-bc-db.b-code = buf_bar-code.b-code no-error .
    if available buf_prod-bc-db then
    return substitute("prod-bc-db ДопБК &1" + buf_prod-bc-db.b-str).
    find first buf_sert-join no-lock where
               buf_sert-join.b-code = buf_bar-code.b-code no-error .
    if available buf_sert-join then
    return substitute("sert-join Сертификат &1" + buf_sert-join.sert-code).
    find first buf_ord-dtl no-lock where
               buf_ord-dtl.artic = buf_goods.artic
           AND buf_ord-dtl.prod-type = buf_goods.prod-type
           AND buf_ord-dtl.prod-code = buf_goods.prod-code
           AND buf_ord-dtl.node-code = buf_bar-code.node-code   no-error .
    if available buf_ord-dtl then
    return substitute("ord-dtl Код заказа &1" + buf_ord-dtl.doc-code).
    find first buf_ord-dtl-cons no-lock where
               buf_ord-dtl-cons.artic = buf_goods.artic
           AND buf_ord-dtl-cons.prod-type = buf_goods.prod-type
           AND buf_ord-dtl-cons.prod-code = buf_goods.prod-code
           AND buf_ord-dtl-cons.node-code = buf_bar-code.node-code   no-error .
    if available buf_ord-dtl-cons then
    return substitute("ord-dtl-cons Код заказа &1" + buf_ord-dtl-cons.cons-code).
    find first buf_ord-dtl-rcv no-lock where
               buf_ord-dtl-rcv.artic = buf_goods.artic
           AND buf_ord-dtl-rcv.prod-type = buf_goods.prod-type
           AND buf_ord-dtl-rcv.prod-code = buf_goods.prod-code
           AND buf_ord-dtl-rcv.node-code = buf_bar-code.node-code   no-error .
    if available buf_ord-dtl-rcv then
    return substitute("ord-dtl-rcv Код заказа &1" + buf_ord-dtl-rcv.doc-code).
    find first buf_tmp-sale-dtl no-lock where
               buf_tmp-sale-dtl.artic = buf_goods.artic
           AND buf_tmp-sale-dtl.prod-type = buf_goods.prod-type
           AND buf_tmp-sale-dtl.prod-code = buf_goods.prod-code
           AND buf_tmp-sale-dtl.node-code = buf_bar-code.node-code   no-error .
    if available buf_tmp-sale-dtl then
    return substitute("tmp-sale-dtl Код типа темпов продаж &1", buf_tmp-sale-dtl.tmp-code).
    for each buf_clients no-lock where
             p-db-num = 0
          or buf_clients.db-num = p-db-num:
      find first buf_price-list no-lock where
                 buf_price-list.obj-type = buf_clients.obj-type
             AND buf_price-list.obj-code = buf_clients.obj-code
             AND buf_price-list.b-code   = buf_bar-code.b-code no-error .
      if available buf_price-list then
      return substitute("price-list объект &1&2 Номер переоценки &3",
                         buf_price-list.obj-type, string(buf_price-list.obj-code),  buf_price-list.doc-num   ).
      find first buf_gds-dtl no-lock where
                 buf_gds-dtl.obj-type = buf_clients.obj-type
             AND buf_gds-dtl.obj-code = buf_clients.obj-code
             AND buf_gds-dtl.prod-type = buf_goods.prod-type
             AND buf_gds-dtl.prod-code = buf_goods.prod-code
             AND buf_gds-dtl.artic = buf_goods.artic
             AND buf_gds-dtl.prt-code = buf_bar-code.node-code no-error .
     if available buf_gds-dtl then
     return substitute("gds-dtl объект &1&2 Номер накладной &3",
                        buf_gds-dtl.obj-type, string(buf_gds-dtl.obj-code),  buf_gds-dtl.doc-code  ).
    end.
    find first buf_chk-gds no-lock where
            buf_chk-gds.b-code = buf_bar-code.b-code  no-error .
    if available buf_chk-gds then
    return substitute("chk-gds Чек &1", buf_chk-gds.doc-code).
    find first buf_price-doc-forming-gds no-lock where
              buf_price-doc-forming-gds.b-code   = buf_bar-code.b-code no-error .
    if available buf_price-doc-forming-gds then
    return substitute("price-doc-forming-gds Номер ДНЦ &1 БД &2"
                        ,  buf_price-doc-forming-gds.pdf-id
                        ,  buf_price-doc-forming-gds.pdf-db  ).
    for each buf_dis-gds-rule no-lock where
            buf_dis-gds-rule.gds-code = buf_bar-code.gds-code:
      if buf_dis-gds-rule.nonunique = string(buf_bar-code.b-code) then do:
        return substitute("dis-gds-rule Роль скидки &1 Объект &2&3"
                            , buf_dis-gds-rule.discnt-role
                            , buf_dis-gds-rule.obj-type
                            , buf_dis-gds-rule.obj-code
                              ).
      end.
    end.
    assign
    p-is-used = no
    .
    return "":U.
  end.
end procedure.
procedure block-del-part-bar-code :
define input  parameter pc-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pc-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pc-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pc-parameters   as   character                   no-undo .
define output parameter pc-err-msg      as   character                   no-undo .
  do
  on error undo, return error
  :
    define variable v-rowid    as rowid     no-undo .
    define variable v-tbl-name as character no-undo .
    define variable v-is-part-bar-code as logical no-undo .
    define variable l-is-used as logical no-undo init yes.
    define variable v-old-stts as integer no-undo .
    define buffer buf_bar-code for ub.bar-code.
    define buffer buf_gds-prt for ub.gds-prt.
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
    if v-tbl-name <> 'bar-code':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей бар-кодов", vss-workfile ).
    end.
    find first buf_bar-code
      where rowid( buf_bar-code ) = v-rowid
      no-error .
    if not available buf_bar-code then do:
      return error substitute( "&1. Нет необходимого бар-кода &2", vss-workfile, pc-uniq-key-rec ).
    end.
    if buf_bar-code.stts = integer('99':U) then do:
      assign
      pc-err-msg = substitute( "Бар-код &1 уже заблокирован или удален!!! Блокировка невозможна!!!", pc-uniq-key-rec )
      .
      return .
    end.
    if buf_bar-code.stts_ <> 0
    and not (buf_bar-code.stts = integer('79':U))
    then do:
      return error substitute( "&1. Необходимый бар-код &2 находится в статусе &3", vss-workfile, buf_bar-code.b-code, buf_bar-code.stts_  ).
    end.
    run is-part-bar-code in this-procedure (
                                           input buf_bar-code.b-code
                                          ,input buf_bar-code.node-code
                                          ,input buf_bar-code.part-code
                                          ,input buf_bar-code.in-code
                                          ,input buf_bar-code.unit-cli
                                          , output v-is-part-bar-code) no-error .
    if error-status:error then do:
      return error substitute( "&1. Ошибка при проверке является ли бар-код &2 бар-кодом партии: &3", vss-workfile, buf_bar-code.b-code, return-value ).
    end.
    if not v-is-part-bar-code then do:
      return error substitute( "&1. Бар-код &2 не является бар-кодом партии", vss-workfile, buf_bar-code.b-code ).
    end.
    if buf_bar-code.stts_ <> 0
    and not buf_bar-code.stts_ = integer('79':U)
    then do:
      return error substitute( "&1. Необходимый бар-код &2 находится в статусе &3", vss-workfile, buf_bar-code.b-code, buf_bar-code.stts_  ).
    end.
    do
    on error undo, return error
    on stop undo, return error
    :
      assign
      v-old-stts = buf_bar-code.stts_
      buf_bar-code.stts_ = integer('99':U)
      .
      run proc-is-used-part-bar-code in this-procedure (buffer buf_bar-code, input pc-db-num, output l-is-used) no-error .
      if error-status:error  then do:
        undo, return error substitute( "&1. Ошибка при проверке на использование в товародвижении бар-кода &2:&3&4"
                                      , vss-workfile
                                      , buf_bar-code.b-code
                                      , chr(10)
                                      , error-status:get-message(1)
                                      ).
      end.
      if l-is-used then do:
        assign
        buf_bar-code.stts_ = v-old-stts
        .
        assign
        pc-err-msg = substitute( "&1. Бар-код &2 используется в товародвижении:&3&4"
                                  , vss-workfile
                                  , buf_bar-code.b-code
                                  , chr(10)
                                  , return-value
                                    )
        .
        return pc-err-msg.
      end.
    end.
  end.
end procedure.
procedure delete-part-bar-code :
define input  parameter pe-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pe-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pe-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pe-parameters   as   character                   no-undo .
define output parameter pe-err-msg      as   character                   no-undo .
  do
  on error undo, return error
  :
    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v_bp-rowid         as rowid     no-undo .
    define variable v-is-part-bar-code as logical no-undo .
    define variable v-b-code           like ub.bar-code.b-code no-undo .
    define variable l-is-used          as logical   no-undo .
    define buffer buf_bar-code         for ub.bar-code .
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
    if v-tbl-name <> 'bar-code':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей бар-кодов", vss-workfile ).
    end.
    assign
    v-b-code = integer(entry(1, pe-parameters, chr(4)))
    .
    find first buf_bar-code exclusive-lock where
              buf_bar-code.b-code = v-b-code no-wait no-error.
    if not available buf_bar-code
    AND not locked(buf_bar-code) then do:
      find first buf_bar-code no-lock where
                  buf_bar-code.b-code = v-b-code no-error.
      if not available buf_bar-code then return.
    end.
    if not available buf_bar-code then do:
      return error substitute( "&1. Не найден или занят бар-код &2", vss-workfile, v-b-code ).
    end.
    if not available buf_bar-code then do:
      return error substitute( "&1. Нет необходимого бар-кода &2", vss-workfile, v-b-code ).
    end.
    if buf_bar-code.stts_ <> integer('99':U) then do:
      return error substitute( "&1. Бар-код &2 не заблокирован для удаления", vss-workfile, buf_bar-code.b-code ).
    end.
    run is-part-bar-code in this-procedure (
                                           input buf_bar-code.b-code
                                          ,input buf_Bar-code.node-code
                                          ,input buf_Bar-code.part-code
                                          ,input buf_Bar-code.in-code
                                          ,input buf_Bar-code.unit-cli
                                          , output v-is-part-bar-code) no-error .
    if error-status:error then do:
      return error substitute( "&1. Ошибка при проверке является ли бар-код &2 бар-кодом партии: &3", vss-workfile, buf_bar-code.b-code, return-value ).
    end.
    if not v-is-part-bar-code then do:
      return error substitute( "&1. Бар-код &2 не является бар-кодом партии", vss-workfile, buf_bar-code.b-code).
    end.
    run proc-is-used-part-bar-code in this-procedure (buffer buf_bar-code, input pe-db-num, output l-is-used) no-error .
    if error-status :error
    then do:
      undo, return error substitute( "&1. Ошибка при проверке на использование в товародвижении бар-кода &2:&3&4"
                                      , vss-workfile
                                      , buf_bar-code.b-code
                                      , chr(10)
                                      , error-status:get-message(1)
                                      ).
    end.
    if l-is-used then do:
      undo, return  error substitute( "&1. Бар-код &2 используется в товародвижении:&3&4"
                                     , vss-workfile
                                     , buf_bar-code.b-code
                                     , chr(10)
                                     , return-value
                                     ).
    end.
    do
    on error undo, return error
    on stop undo, return error
    :
      delete buf_bar-code.
    end.
  end.
end procedure.
procedure undo-delete-part-bar-code :
define input  parameter pr-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pr-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pr-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pr-parameters   as   character                   no-undo .
define output parameter pr-err-msg      as   character                   no-undo .
  do
  on error undo, return error
  :
    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v_bp-rowid         as rowid     no-undo .
    define variable v-gds-code like ub.goods.gds-code no-undo .
    define variable v-b-code like ub.bar-code.b-code no-undo .
    define variable v-node-code like ub.bar-code.node-code no-undo .
    define variable v-part-code like ub.bar-code.part-code no-undo .
    define variable v-in-code    like ub.bar-code.in-code no-undo .
    define variable v-unit-cli   like ub.bar-code.unit-cli no-undo .
    define variable v-cli-base-rate like ub.bar-code.cli-base-rate no-undo .
    define variable v-new  as logical no-undo .
    define variable v-old-stts as integer no-undo .
    define buffer buf_db-rec-attr    for ub.db-rec-attr .
    define buffer buf_bar-code       for ub.bar-code    .
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
    if v-tbl-name <> 'bar-code':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей бар-кодов", vss-workfile ).
    end.
    find first buf_bar-code exclusive-lock where
               rowid(buf_bar-code) = v-rowid no-error  .
    if not available buf_bar-code then do:
      assign
      v-b-code = integer(entry(1, pr-parameters, chr(4)))
      v-old-stts = integer(entry(8, pr-parameters, chr(4)))
      .
      find first buf_bar-code exclusive-lock where
                 buf_bar-code.b-code = v-b-code no-error no-wait.
      if not available buf_bar-code
      AND not LOCKED(buf_bar-code)
      then do:
        find first buf_bar-code no-lock where
                 buf_bar-code.b-code = v-b-code no-error.
        if not available buf_bar-code then do:
          return .
        end.
        return error substitute( "&1. Не найден или занят бар-код &2", vss-workfile, v-b-code ).
      end.
    end.
    do
    on error undo, return error
    on stop undo, return error
    :
      if buf_bar-code.stts_ = integer('99':U) then do:
        assign
        buf_bar-code.stts_ = v-old-stts.
        release buf_bar-code.
      end.
      assign
      v-gds-code  = integer(entry(2, pr-parameters, chr(4)))
      v-node-code = integer(entry(3, pr-parameters, chr(4)))
      v-part-code = entry(4, pr-parameters, chr(4))
      v-in-code   = entry(5, pr-parameters, chr(4))
      v-unit-cli  = entry(6, pr-parameters, chr(4))
      v-cli-base-rate = integer(entry(7, pr-parameters, chr(4)))
      v-old-stts = integer(entry(8, pr-parameters, chr(4)))
      .
    end.
  end.
end procedure.
procedure proc-is-used-part-bar-code :
define parameter buffer buf_bar-code for ub.bar-code.
define input parameter p-db-num like ub.db.db-num no-undo .
define output parameter p-is-used as logical no-undo init yes.
  do
  on error undo, return error
  :
    define variable v-artic  like ub.goods.artic no-undo .
    define variable v-prod-type  like ub.goods.prod-type no-undo .
    define variable v-prod-code  like ub.goods.prod-code no-undo .
    define variable v-is-part-bar-code as logical no-undo .
    define buffer buf_goods for ub.goods.
    define buffer buf_trn-doc for ub.trn-doc.
    define buffer buf_doc-prts for ub.doc-prts.
    define buffer buf_prod-bc for ub.prod-bc.
    define buffer buf_prod-bc-db for ub.prod-bc-db.
    define buffer buf_clients for ub.clients.
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_sert-join for ub.sert-join.
    define buffer buf_price-list for ub.price-list.
    define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds.
    define buffer buf_dis-gds-rule for ub.dis-gds-rule.
    run is-part-bar-code in this-procedure (
                                           input buf_bar-code.b-code
                                          ,input buf_bar-code.node-code
                                          ,input buf_bar-code.part-code
                                          ,input buf_bar-code.in-code
                                          ,input buf_bar-code.unit-cli
                                          ,output v-is-part-bar-code) no-error .
    if error-status:error then do:
      return error substitute( "&1. Ошибка при проверке является ли бар-код &2 бар-кодом партии: &3", vss-workfile, string(buf_bar-code.b-code), return-value ).
    end.
    if not v-is-part-bar-code then do:
      return error substitute( "&1. Бар-код &2 не является бар-кодом партии", vss-workfile, string(buf_bar-code.b-code) ).
    end.
    find first buf_goods no-lock where
               buf_goods.gds-code = buf_bar-code.gds-code no-error .
    if not avail buf_goods then return error.
    find first buf_trn-doc no-lock where
               buf_trn-doc.doc-code = buf_bar-code.in-code no-error .
    if available buf_trn-doc then
    return substitute("trn-doc объект &1&2 Номер документа &3",
                       buf_trn-doc.obj-type, string(buf_trn-doc.obj-code),  buf_trn-doc.doc-code   ).
    find first buf_prod-bc no-lock where
               buf_prod-bc.b-code = buf_bar-code.b-code no-error .
    if available buf_prod-bc then
    return substitute("prod-bc ДопБК &1", buf_prod-bc.b-str).
    find first buf_prod-bc-db no-lock where
               buf_prod-bc-db.b-code = buf_bar-code.b-code no-error .
    if available buf_prod-bc-db then
    return substitute("prod-bc-db ДопБК &1", buf_prod-bc-db.b-str).
    find first buf_sert-join no-lock where
               buf_sert-join.b-code = buf_bar-code.b-code no-error .
    if available buf_sert-join then
    return substitute("sert-join Сертификат &1", buf_sert-join.sert-code).
    for each buf_clients no-lock where
             p-db-num = 0
          or buf_clients.db-num = p-db-num:
      find first buf_price-list no-lock where
                 buf_price-list.obj-type = buf_clients.obj-type
             AND buf_price-list.obj-code = buf_clients.obj-code
             AND buf_price-list.b-code   = buf_bar-code.b-code no-error .
      if available buf_price-list then
      return substitute("price-list объект &1&2 Номер переоценки &3",
                         buf_price-list.obj-type, string(buf_price-list.obj-code),  buf_price-list.doc-num   ).
    end.
    find first buf_chk-gds no-lock where
            buf_chk-gds.b-code = buf_bar-code.b-code  no-error .
    if available buf_chk-gds then
    return substitute("chk-gds Чек &1", buf_chk-gds.doc-code).
    find first buf_price-doc-forming-gds no-lock where
            buf_price-doc-forming-gds.b-code   = buf_bar-code.b-code no-error .
    if available buf_price-doc-forming-gds then
    return substitute("price-doc-forming-gds Номер ДНЦ &1 БД &2"
                        ,  buf_price-doc-forming-gds.pdf-id
                        ,  buf_price-doc-forming-gds.pdf-db  ).
    for each buf_dis-gds-rule no-lock where
            buf_dis-gds-rule.gds-code = buf_bar-code.gds-code:
      if buf_dis-gds-rule.nonunique = string(buf_bar-code.b-code) then do:
        return substitute("dis-gds-rule Роль скидки &1 Объект &2&3"
                            , buf_dis-gds-rule.discnt-role
                            , buf_dis-gds-rule.obj-type
                            , buf_dis-gds-rule.obj-code
                              ).
      end.
    end.
    assign
    p-is-used = no
    .
    return "":U.
  end.
end procedure.
procedure block-del-ucli-bar-code :
define input  parameter pc-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pc-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pc-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pc-parameters   as   character                   no-undo .
define output parameter pc-err-msg      as   character                   no-undo .
  do
  on error undo, return error
  :
    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v-is-ucli-bar-code as logical no-undo .
    define variable l-terminal-prt     as logical no-undo .
    define variable l-is-used          as logical no-undo init yes.
    define variable v-prod-bc          as character no-undo .
    define variable v-bar-code         as integer   no-undo .
    define variable v-old-stts         as integer no-undo .
    define buffer buf_bar-code for ub.bar-code.
    define buffer buf_prod-bc for ub.prod-bc .
    define buffer buf_gds-prt for ub.gds-prt.
    define buffer buf_units-base for ub.units.
    define buffer buf_units-cli for ub.units.
    define buffer buf_goods for ub.goods.
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
    if v-tbl-name <> 'bar-code':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей бар-кодов", vss-workfile ).
    end.
    assign
      v-bar-code = integer( entry( 2, pc-uniq-key-rec, chr(3) ) )
      v-old-stts = integer( entry( 8, pc-parameters, chr(4) ) )
    .
    find first buf_bar-code
      where rowid( buf_bar-code ) = v-rowid
      no-error .
    if not available buf_bar-code then do:
      run gen-bc in this-procedure
        ( input v-bar-code
         ,output v-prod-bc
        ).
      find first buf_prod-bc exclusive-lock
        where buf_prod-bc.b-str = v-prod-bc
        no-error.
      if available buf_prod-bc then do:
        find next buf_prod-bc share-lock
          where buf_prod-bc.b-str = v-prod-bc
          no-error.
        if available buf_prod-bc then do:
          return error substitute( "&1. Системная ошибка!!! Найдено несколько порожденных Доп.БК с одинаковыми кодами (&2)", vss-workfile, v-prod-bc) .
        end.
        else do:
          assign
            pc-err-msg = substitute( "Бар-код &1 был преобразован в Доп.БК &2!", v-bar-code, v-prod-bc )
          .
          return .
        end.
      end.
      else do:
        return error substitute( "&1. Нет необходимого бар-кода &2", vss-workfile, pc-uniq-key-rec ).
      end.
    end.
    if buf_bar-code.stts = integer('99':U) then do:
      assign
      pc-err-msg = substitute( "Бар-код &1 уже заблокирован или удален!!! Блокировка невозможна!!!", pc-uniq-key-rec )
      .
      return .
    end.
    if buf_bar-code.stts_ <> 0
    and not buf_bar-code.stts_ = integer('79':U)
    then do:
      return error substitute( "&1. Необходимый бар-код &2 находится в статусе &3", vss-workfile, buf_bar-code.b-code, buf_bar-code.stts_  ).
    end.
    run is-ucli-bar-code in this-procedure (
                                           input buf_bar-code.b-code
                                          ,input buf_bar-code.node-code
                                          ,input buf_bar-code.part-code
                                          ,input buf_bar-code.in-code
                                          ,input buf_bar-code.unit-cli
                                          ,input buf_bar-code.gds-code
                                          ,output v-is-ucli-bar-code) no-error .
    if error-status:error then do:
      return error substitute( "&1. Ошибка при проверке является ли бар-код &2 бар-кодом на доп. ед.изм: &3", vss-workfile, buf_bar-code.b-code, return-value ).
    end.
    if not v-is-ucli-bar-code then do:
      return error substitute( "&1. Бар-код &2 не является бар-кодом на доп.ед.изм.", vss-workfile, buf_bar-code.b-code ).
    end.
    do
    on error undo, return error
    on stop undo, return error
    :
        assign
        buf_bar-code.stts_ = integer('99':U)
        .
        run proc-is-used-ucli-bar-code in this-procedure (buffer buf_bar-code, input pc-db-num, output l-is-used) no-error .
        if error-status :error
        then do:
          undo, return error substitute( "&1. Ошибка при проверке на использование в товародвижении бар-кода &2:&3&4"
                                         , vss-workfile
                                         , buf_bar-code.b-code
                                         , chr(10)
                                         , error-status:get-message(1)
                                         ).
        end.
        if l-is-used then do:
                  assign
          buf_bar-code.stts_ = v-old-stts
          pc-err-msg = substitute( "&1. Бар-код &2 используется в товародвижении:&3&4"
                                    , vss-workfile
                                    , buf_bar-code.b-code
                                    , chr(10)
                                    , return-value
                                     )
          .
          return pc-err-msg.
        end.
    end.
  end.
end procedure.
procedure delete-ucli-bar-code :
define input  parameter pe-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pe-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pe-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pe-parameters   as   character                   no-undo .
define output parameter pe-err-msg      as   character                   no-undo .
  main-block:
  do
  on error undo main-block, return error
  :
    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v_bp-rowid         as rowid     no-undo .
    define variable v-is-ucli-bar-code as logical no-undo .
    define variable v-b-code like ub.bar-code.b-code no-undo .
    define variable l-is-used          as logical   no-undo .
    define buffer buf_bar-code         for ub.bar-code .
    define buffer buf_bar-code-attr    for ub.bar-code-attr .
    define buffer buf_bar-code-obj-attr    for ub.bar-code-obj-attr .
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
    if v-tbl-name <> 'bar-code':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей бар-кодов", vss-workfile ).
    end.
     assign
     v-b-code = integer(entry(1, pe-parameters, chr(4)))
     .
    find first buf_bar-code exclusive-lock where
              buf_bar-code.b-code = v-b-code no-wait no-error.
    if not available buf_bar-code
    and not locked(buf_bar-code) then do:
      find first buf_bar-code no-lock where
                  buf_bar-code.b-code = v-b-code no-error.
      if not available buf_bar-code then return.
    end.
    if not available buf_bar-code then do:
      return error substitute( "&1. Не найден или занят бар-код &2", vss-workfile, v-b-code ).
    end.
    if buf_bar-code.stts_ <> integer('99':U) then do:
      return error substitute( "&1. Бар-код &2 не заблокирован для удаления", vss-workfile, buf_bar-code.b-code ).
    end.
    run is-ucli-bar-code in this-procedure (
                                           input buf_bar-code.b-code
                                          ,input buf_bar-code.node-code
                                          ,input buf_bar-code.part-code
                                          ,input buf_bar-code.in-code
                                          ,input buf_bar-code.unit-cli
                                          ,input buf_bar-code.gds-code
                                          , output v-is-ucli-bar-code) no-error .
    if error-status:error then do:
      return error substitute( "&1. Ошибка при проверке является ли бар-код &2 бар-кодом на доп.ед.изм.: &3", vss-workfile, buf_bar-code.b-code, return-value ).
    end.
    if not v-is-ucli-bar-code then do:
      return error substitute( "&1. Бар-код &2 не является бар-кодом на доп.ед.изм.", vss-workfile, buf_bar-code.b-code).
    end.
    run proc-is-used-ucli-bar-code in this-procedure (buffer buf_bar-code, input pe-db-num, output l-is-used) no-error .
    if error-status :error
    then do:
      undo main-block, return error substitute( "&1. Ошибка при проверке на использование в товародвижении бар-кода &2:&3&4"
                                     , vss-workfile
                                     , buf_bar-code.b-code
                                     , chr(10)
                                     , error-status:get-message(1)
                                     ).
    end.
    if l-is-used then do:
      undo main-block, return error substitute( "&1. Бар-код &2 используется в товародвижении:&3&4"
                                    , vss-workfile
                                    , buf_bar-code.b-code
                                    , chr(10)
                                    , return-value
                                    ).
    end.
    for each buf_bar-code-attr share-lock where
            buf_bar-code-attr.b-code = buf_bar-code.b-code
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      delete buf_bar-code-attr.
    end.
    for each buf_bar-code-obj-attr share-lock where
            buf_bar-code-obj-attr.b-code = buf_bar-code.b-code
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      delete buf_bar-code-obj-attr.
    end.
    do
    on error undo main-block, return error
    on stop undo main-block, return error
    :
      delete buf_bar-code.
    end.
  end.
end procedure.
procedure undo-delete-ucli-bar-code :
define input  parameter pr-db-num       like ub.db-rec-attr.db-num       no-undo .
define input  parameter pr-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
define input  parameter pr-attr-code    like ub.db-rec-attr.attr-code    no-undo .
define input  parameter pr-parameters   as   character                   no-undo .
define output parameter pr-err-msg      as   character                   no-undo .
  do
  on error undo, return error
  :
    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v_bp-rowid         as rowid     no-undo .
    define variable v-gds-code like ub.goods.gds-code no-undo .
    define variable v-b-code like ub.bar-code.b-code no-undo .
    define variable v-new  as logical no-undo .
    define variable v-old-stts as integer no-undo .
    define buffer buf_db-rec-attr    for ub.db-rec-attr .
    define buffer buf_bar-code       for ub.bar-code    .
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
    if v-tbl-name <> 'bar-code':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей бар-кодов", vss-workfile ).
    end.
    find first buf_bar-code exclusive-lock where
               rowid(buf_bar-code) = v-rowid no-error  .
    if not available buf_bar-code then do:
      assign
      v-b-code = integer(entry(1, pr-parameters, chr(4)))
      v-old-stts = integer(entry(8, pr-parameters, chr(4)))
      .
      find first buf_bar-code exclusive-lock where
                 buf_bar-code.b-code = v-b-code no-error no-wait.
      if not available buf_bar-code
      AND not LOCKED(buf_bar-code)
      then do:
        find first buf_bar-code no-lock where
                 buf_bar-code.b-code = v-b-code no-error.
        if not available buf_bar-code then do:
          return .
        end.
        return error substitute( "&1. Не найден или занят бар-код &2", vss-workfile, v-b-code ).
      end.
    end.
    do
    on error undo, return error
    on stop undo, return error
    :
      if buf_bar-code.stts_ = integer('99':U) then do:
        assign
        buf_bar-code.stts_ = v-old-stts.
        release buf_bar-code.
      end.
    end.
  end.
end procedure.
procedure proc-is-used-ucli-bar-code :
define parameter buffer buf_bar-code for ub.bar-code.
define input parameter p-db-num like ub.db.db-num no-undo .
define output parameter p-is-used as logical no-undo init yes.
  do
  on error undo, return error
  :
    define variable v-artic  like ub.goods.artic no-undo .
    define variable v-prod-type  like ub.goods.prod-type no-undo .
    define variable v-prod-code  like ub.goods.prod-code no-undo .
    define variable v-is-ucli-bar-code as logical no-undo .
    define buffer buf_goods for ub.goods.
    define buffer buf_prt-obj for ub.prt-obj.
    define buffer buf_prod-bc for ub.prod-bc.
    define buffer buf_prod-bc-db for ub.prod-bc-db.
    define buffer buf_clients for ub.clients.
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_scales-gds for ub.scales-gds.
    define buffer buf_sert-join for ub.sert-join.
    define buffer buf_price-list for ub.price-list.
    define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds.
    define buffer buf_dis-gds-rule for ub.dis-gds-rule.
    define buffer buf_gds-dtl for ub.gds-dtl.
    define buffer buf_ord-dtl for ub.ord-dtl.
    define buffer buf_ord-dtl-cons for ub.ord-dtl-cons.
    define buffer buf_ord-dtl-rcv for ub.ord-dtl-rcv.
    define buffer buf_tmp-sale-dtl for ub.tmp-sale-dtl.
    run is-ucli-bar-code in this-procedure (
                                           input buf_bar-code.b-code
                                          ,input buf_bar-code.node-code
                                          ,input buf_bar-code.part-code
                                          ,input buf_bar-code.in-code
                                          ,input buf_bar-code.unit-cli
                                          ,input buf_bar-code.gds-code
                                          , output v-is-ucli-bar-code) no-error .
    if error-status:error then do:
      return error substitute( "&1. Ошибка при проверке является ли бар-код &2 бар-кодом на доп.ед.изм.: &3", vss-workfile, string(buf_bar-code.b-code), return-value ).
    end.
    if not v-is-ucli-bar-code then do:
      return error substitute( "&1. Бар-код &2 не является бар-кодом на доп ед.изм.", vss-workfile, buf_bar-code.b-code).
    end.
    find first buf_goods no-lock where
               buf_goods.gds-code = buf_bar-code.gds-code no-error .
    if not avail buf_goods then return error.
    find first buf_prod-bc no-lock where
               buf_prod-bc.b-code = buf_bar-code.b-code no-error .
    if available buf_prod-bc then
    return substitute("prod-bc ДопБК &1" + buf_prod-bc.b-str).
    find first buf_prod-bc-db no-lock where
               buf_prod-bc-db.b-code = buf_bar-code.b-code no-error .
    if available buf_prod-bc-db then
    return substitute("prod-bc-db ДопБК &1" + buf_prod-bc-db.b-str).
    find first buf_sert-join no-lock where
               buf_sert-join.b-code = buf_bar-code.b-code no-error .
    if available buf_sert-join then
    return substitute("sert-join Сертификат &1" + buf_sert-join.sert-code).
    for each buf_clients no-lock where
             p-db-num = 0
          or buf_clients.db-num = p-db-num:
      find first buf_price-list no-lock where
                 buf_price-list.obj-type = buf_clients.obj-type
             AND buf_price-list.obj-code = buf_clients.obj-code
             AND buf_price-list.b-code   = buf_bar-code.b-code no-error .
      if available buf_price-list then
      return substitute("price-list объект &1&2 Номер переоценки &3",
                         buf_price-list.obj-type, string(buf_price-list.obj-code),  buf_price-list.doc-num   ).
    end.
    find first buf_chk-gds no-lock where
            buf_chk-gds.b-code = buf_bar-code.b-code  no-error .
    if available buf_chk-gds then
    return substitute("chk-gds Чек &1", buf_chk-gds.doc-code).
    find first buf_price-doc-forming-gds no-lock where
              buf_price-doc-forming-gds.b-code   = buf_bar-code.b-code no-error .
    if available buf_price-doc-forming-gds then
    return substitute("price-doc-forming-gds Номер ДНЦ &1 БД &2"
                        ,  buf_price-doc-forming-gds.pdf-id
                        ,  buf_price-doc-forming-gds.pdf-db  ).
    for each buf_dis-gds-rule no-lock where
            buf_dis-gds-rule.gds-code = buf_bar-code.gds-code:
      if buf_dis-gds-rule.nonunique = string(buf_bar-code.b-code) then do:
        return substitute("dis-gds-rule Роль скидки &1 Объект &2&3"
                            , buf_dis-gds-rule.discnt-role
                            , buf_dis-gds-rule.obj-type
                            , buf_dis-gds-rule.obj-code
                              ).
      end.
    end.
    assign
    p-is-used = no
    .
    return "":U.
  end.
end procedure.
