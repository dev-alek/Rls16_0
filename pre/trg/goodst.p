block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "библиотека для работы с записями goods".
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
procedure comm-ren-art :
  define input  parameter pc-db-num       like ub.db-rec-attr.db-num       no-undo .
  define input  parameter pc-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
  define input  parameter pc-attr-code    like ub.db-rec-attr.attr-code    no-undo .
  define input  parameter pc-parameters   as   character                   no-undo .
  define output parameter pc-err-msg      as   character                   no-undo .
  do
  on error undo, return error
  :
    define buffer buf_goods        for ub.goods .
    define buffer buf-check_goods  for ub.goods .
    define buffer buf_BatchProcess for ub.BatchProcess .
    define variable v-rowid    as rowid     no-undo .
    define variable v-tbl-name as character no-undo .
    define variable v-gds-code      like ub.goods.gds-code  no-undo .
    define variable v-old-artic     like ub.goods.artic     no-undo .
    define variable v-old-prod-type like ub.goods.prod-type no-undo .
    define variable v-old-prod-code like ub.goods.prod-code no-undo .
    define variable v-new-artic     like ub.goods.artic     no-undo .
    define variable v-new-prod-type like ub.goods.prod-type no-undo .
    define variable v-new-prod-code like ub.goods.prod-code no-undo .
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
    if v-tbl-name <> 'goods':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей товаров", vss-workfile ).
    end.
    find first buf_goods exclusive-lock
      where rowid( buf_goods ) = v-rowid
      no-error .
    if not available buf_goods then do:
      return error substitute( "&1. Нет необходимого товара &2", vss-workfile, pc-uniq-key-rec ).
    end.
    assign
      v-gds-code      = integer( entry( 1, pc-parameters, chr(4) ) )
      v-old-artic     = entry( 2, pc-parameters, chr(4) )
      v-old-prod-type = entry( 3, pc-parameters, chr(4) )
      v-old-prod-code = integer( entry( 4, pc-parameters, chr(4) ) )
      v-new-artic     = entry( 5, pc-parameters, chr(4) )
      v-new-prod-type = entry( 6, pc-parameters, chr(4) )
      v-new-prod-code = integer( entry( 7, pc-parameters, chr(4) ) )
    .
    if v-old-artic        = v-new-artic
      and v-old-prod-type = v-new-prod-type
      and v-old-prod-code = v-new-prod-code
    then do:
      assign
        pc-err-msg = substitute( "Новый артикул &1 производитель &2 &3 должен отличаться от старого. Блокировка невозможна!!!"
                                  ,v-new-artic
                                  ,v-new-prod-type
                                  ,v-new-prod-code
                                )
      .
    end.
    else do:
      if buf_goods.artic = v-old-artic
        and buf_goods.prod-type = v-old-prod-type
        and buf_goods.prod-code = v-old-prod-code
      then do:
        find first buf-check_goods no-lock
          where buf-check_goods.artic     = v-new-artic
            and buf-check_goods.prod-type = v-new-prod-type
            and buf-check_goods.prod-code = v-new-prod-code
            and rowid( buf-check_goods ) <> v-rowid
          no-error
        .
        if available buf-check_goods then do:
          assign
            pc-err-msg = substitute( "Уже существует товар с артикулом &1 производителя &2 &3. Блокировка невозможна!!!"
                                    ,buf-check_goods.artic
                                    ,buf-check_goods.prod-type
                                    ,buf-check_goods.prod-code
                                  )
          .
        end.
        else do:
  find first buf_BatchProcess exclusive-lock
    where buf_BatchProcess.bp_type   = 'rnar':U
      and buf_BatchProcess.bp_status = 'N':U
      and  buf_BatchProcess.key#_one  = v-new-prod-code
      and buf_BatchProcess.charkey_one = v-new-artic
      and buf_BatchProcess.charkey_two = v-new-prod-type
  no-error .
          if available buf_BatchProcess then do:
            assign
              pc-err-msg = substitute( "Уже идет операция в результате которой появится товар с артикулом &1 производителем &2 &3. Блокировка невозможна!!!"
                                      ,v-new-artic
                                      ,v-new-prod-type
                                      ,v-new-prod-code
                                    )
            .
          end.
          else do:
            if buf_goods.stts = integer('0':U) then do:
              assign
                buf_goods.stts = integer('50':U)
              .
  find first ub.batchprocess no-lock
    where ub.batchprocess.bp_type   = 'rnar':U
      and ub.batchprocess.bp_status = 'N':U
      and  ub.batchprocess.key#_one  = v-old-prod-code
      and ub.batchprocess.charkey_one = v-old-artic
      and ub.batchprocess.charkey_two = v-old-prod-type
  no-error .
  if not available ub.BatchProcess then do:
    create ub.BatchProcess .
        define variable v-btpr_upd-today-2 as date      no-undo.
    define variable v-btpr_upd-time-2  as integer   no-undo.
    run cur-time in this-procedure ( output v-btpr_upd-today-2
                                   , output v-btpr_upd-time-2
                                   ).
    assign
      ub.BatchProcess.BP_Type       = 'rnar':U
      ub.BatchProcess.BP_Status     = 'N':U
      ub.BatchProcess.BatchProcess# = next-value( s-btpr, ub )
      ub.BatchProcess.User_ID       = g#userid
      ub.BatchProcess.BP_SysDate    = v-btpr_upd-today-2
      ub.BatchProcess.BP_SysTime    = string( v-btpr_upd-time-2, 'HH:MM' )
      ub.BatchProcess.BP_SysTimeInt = v-btpr_upd-time-2
    .
    assign
      ub.BatchProcess.Key#_One      = v-old-prod-code
      ub.BatchProcess.CharKey_One   = v-old-artic
      ub.BatchProcess.CharKey_Two   = v-old-prod-type
    .
  end.
  find first ub.batchprocess no-lock
    where ub.batchprocess.bp_type   = 'rnar':U
      and ub.batchprocess.bp_status = 'N':U
      and  ub.batchprocess.key#_one  = v-new-prod-code
      and ub.batchprocess.charkey_one = v-new-artic
      and ub.batchprocess.charkey_two = v-new-prod-type
  no-error .
  if not available ub.BatchProcess then do:
    create ub.BatchProcess .
        define variable v-btpr_upd-today-3 as date      no-undo.
    define variable v-btpr_upd-time-3  as integer   no-undo.
    run cur-time in this-procedure ( output v-btpr_upd-today-3
                                   , output v-btpr_upd-time-3
                                   ).
    assign
      ub.BatchProcess.BP_Type       = 'rnar':U
      ub.BatchProcess.BP_Status     = 'N':U
      ub.BatchProcess.BatchProcess# = next-value( s-btpr, ub )
      ub.BatchProcess.User_ID       = g#userid
      ub.BatchProcess.BP_SysDate    = v-btpr_upd-today-3
      ub.BatchProcess.BP_SysTime    = string( v-btpr_upd-time-3, 'HH:MM' )
      ub.BatchProcess.BP_SysTimeInt = v-btpr_upd-time-3
    .
    assign
      ub.BatchProcess.Key#_One      = v-new-prod-code
      ub.BatchProcess.CharKey_One   = v-new-artic
      ub.BatchProcess.CharKey_Two   = v-new-prod-type
    .
  end.
            end.
            else do:
              assign
                pc-err-msg = substitute( "Товар &1 уже заблокирован или удален!!! Блокировка невозможна!!!", pc-uniq-key-rec )
              .
            end.
          end.
        end.
      end.
      else do:
        return error substitute( "&1. Обнаружено фатальное отличие товаров", vss-workfile )
                    + chr(10)
                    + substitute( "Должно быть: артикул &1 производитель &2 &3", v-old-artic
                                                                                , v-old-prod-type
                                                                                , v-old-prod-code )
                    + chr(10)
                    + substitute( "В текущей БД: артикул &1 производитель &2 &3", buf_goods.artic
                                                                                , buf_goods.prod-type
                                                                                , buf_goods.prod-code )
        .
      end.
    end.
  end.
  return.
end procedure.
procedure exec-ren-art :
  define input  parameter pe-db-num       like ub.db-rec-attr.db-num       no-undo .
  define input  parameter pe-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
  define input  parameter pe-attr-code    like ub.db-rec-attr.attr-code    no-undo .
  define input  parameter pe-parameters   as   character                   no-undo .
  define output parameter pe-err-msg      as   character                   no-undo .
  do
  on error undo, return error return-value
  :
    define buffer buf_goods     for ub.goods .
    define buffer buf-new_goods for ub.goods .
    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .
    define variable v-gds-code      like ub.goods.gds-code  no-undo .
    define variable v-old-artic     like ub.goods.artic     no-undo .
    define variable v-old-prod-type like ub.goods.prod-type no-undo .
    define variable v-old-prod-code like ub.goods.prod-code no-undo .
    define variable v-new-artic     like ub.goods.artic     no-undo .
    define variable v-new-prod-type like ub.goods.prod-type no-undo .
    define variable v-new-prod-code like ub.goods.prod-code no-undo .
    define variable v-error-message as   character          no-undo .
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
    if v-tbl-name <> 'goods':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей товаров", vss-workfile ).
    end.
    find first buf_goods
      where rowid( buf_goods ) = v-rowid
      no-error .
    if not available buf_goods then do:
      return error substitute( "&1. Нет необходимого товара &2", vss-workfile, pe-uniq-key-rec ).
    end.
    if buf_goods.stts <> integer('50':U) then do:
      return error substitute( "&1. Товар &2 не заблокирован для переименования артикула", vss-workfile, pe-uniq-key-rec ).
    end.
    assign
      v-gds-code      = integer( entry( 1, pe-parameters, chr(4) ) )
      v-old-artic     = entry( 2, pe-parameters, chr(4) )
      v-old-prod-type = entry( 3, pe-parameters, chr(4) )
      v-old-prod-code = integer( entry( 4, pe-parameters, chr(4) ) )
      v-new-artic     = entry( 5, pe-parameters, chr(4) )
      v-new-prod-type = entry( 6, pe-parameters, chr(4) )
      v-new-prod-code = integer( entry( 7, pe-parameters, chr(4) ) )
    .
    run utl/ren-art.p
      (input  v-gds-code
      ,input  v-old-artic
      ,input  v-old-prod-type
      ,input  v-old-prod-code
      ,input  v-new-artic
      ,input  v-new-prod-type
      ,input  v-new-prod-code
      ) no-error.
    if error-status :error then do:
      return error substitute( "&1. Артикул товара &2 не изменен: &3&4&5", vss-workfile, pe-uniq-key-rec, v-error-message, chr(10), return-value ).
    end.
    if buf_goods.stts = integer('50':U) then do:
      assign
        buf_goods.stts = integer('0':U)
      .
    end.
  end.
  return.
end procedure.
procedure rcvr-ren-art :
  define input  parameter pr-db-num       like ub.db-rec-attr.db-num       no-undo .
  define input  parameter pr-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
  define input  parameter pr-attr-code    like ub.db-rec-attr.attr-code    no-undo .
  define input  parameter pr-parameters   as   character                   no-undo .
  define output parameter pr-err-msg      as   character                   no-undo .
  do
  on error undo, return error
  :
    define buffer buf_goods        for ub.goods .
    define buffer buf_BatchProcess for ub.BatchProcess .
    define variable v-rowid    as rowid     no-undo .
    define variable v-tbl-name as character no-undo .
    define variable v-gds-code      like ub.goods.gds-code  no-undo .
    define variable v-old-artic     like ub.goods.artic     no-undo .
    define variable v-old-prod-type like ub.goods.prod-type no-undo .
    define variable v-old-prod-code like ub.goods.prod-code no-undo .
    define variable v-new-artic     like ub.goods.artic     no-undo .
    define variable v-new-prod-type like ub.goods.prod-type no-undo .
    define variable v-new-prod-code like ub.goods.prod-code no-undo .
    define variable v-error-message as   character          no-undo .
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
    if v-tbl-name <> 'goods':U then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей товаров", vss-workfile ).
    end.
    find first buf_goods
      where rowid( buf_goods ) = v-rowid
      no-error .
    if not available buf_goods then do:
      return error substitute( "&1. Нет необходимого товара &2", vss-workfile, pr-uniq-key-rec ).
    end.
    assign
      v-gds-code      = integer( entry( 1, pr-parameters, chr(4) ) )
      v-old-artic     = entry( 2, pr-parameters, chr(4) )
      v-old-prod-type = entry( 3, pr-parameters, chr(4) )
      v-old-prod-code = integer( entry( 4, pr-parameters, chr(4) ) )
      v-new-artic     = entry( 5, pr-parameters, chr(4) )
      v-new-prod-type = entry( 6, pr-parameters, chr(4) )
      v-new-prod-code = integer( entry( 7, pr-parameters, chr(4) ) )
    .
    if buf_goods.artic = v-old-artic
      and buf_goods.prod-type = v-old-prod-type
      and buf_goods.prod-code = v-old-prod-code
    then do:
    end.
    else do:
      if buf_goods.artic = v-new-artic
        and buf_goods.prod-type = v-new-prod-type
        and buf_goods.prod-code = v-new-prod-code
      then do:
        run utl/ren-art.p
          (input  v-gds-code
          ,input  v-new-artic
          ,input  v-new-prod-type
          ,input  v-new-prod-code
          ,input  v-old-artic
          ,input  v-old-prod-type
          ,input  v-old-prod-code
          ) no-error.
        if error-status :error
          or return-value <> ""
        then do:
          return error substitute( "&1. Артикул и(или) производитель товара &2 не изменен: &3", vss-workfile, pr-uniq-key-rec, v-error-message ).
        end.
      end.
      else do:
        return error substitute( "&1. Артикул и(или) производитель товара &2 был изменен на &3 &4 &5. Это недопустимо!!!"
                                 ,vss-workfile
                                 ,pr-uniq-key-rec
                                 ,buf_goods.artic
                                 ,buf_goods.prod-type
                                 ,buf_goods.prod-code
                                ).
      end.
    end.
    if buf_goods.stts = integer('50':U)
      or buf_goods.stts = integer('51':U)
    then do:
      assign
        buf_goods.stts = integer('0':U)
      .
    end.
  find first buf_BatchProcess exclusive-lock
    where buf_BatchProcess.bp_type   = 'rnar':U
      and buf_BatchProcess.bp_status = 'N':U
      and  buf_BatchProcess.key#_one  = v-old-prod-code
      and buf_BatchProcess.charkey_one = v-old-artic
      and buf_BatchProcess.charkey_two = v-old-prod-type
  no-error .
    if available buf_BatchProcess then do:
      delete buf_BatchProcess.
    end.
  find first buf_BatchProcess exclusive-lock
    where buf_BatchProcess.bp_type   = 'rnar':U
      and buf_BatchProcess.bp_status = 'N':U
      and  buf_BatchProcess.key#_one  = v-new-prod-code
      and buf_BatchProcess.charkey_one = v-new-artic
      and buf_BatchProcess.charkey_two = v-new-prod-type
  no-error .
    if available buf_BatchProcess then do:
      delete buf_BatchProcess.
    end.
  end.
  return.
end procedure.
procedure after-ren-art :
  define input  parameter pa-action       as character no-undo .
  define input  parameter pa-uniq-key-rec as character no-undo .
  define input  parameter pa-db-init      as integer   no-undo .
  define input  parameter pa-parameters   as character no-undo .
  define output parameter pa-err-msg      as character no-undo .
  do
  on error undo, return error
  :
    define buffer buf_BatchProcess for ub.BatchProcess .
    define variable v-gds-code      like ub.goods.gds-code  no-undo .
    define variable v-old-artic     like ub.goods.artic     no-undo .
    define variable v-old-prod-type like ub.goods.prod-type no-undo .
    define variable v-old-prod-code like ub.goods.prod-code no-undo .
    define variable v-new-artic     like ub.goods.artic     no-undo .
    define variable v-new-prod-type like ub.goods.prod-type no-undo .
    define variable v-new-prod-code like ub.goods.prod-code no-undo .
    assign
      v-gds-code      = integer( entry( 1, pa-parameters, chr(4) ) )
      v-old-artic     = entry( 2, pa-parameters, chr(4) )
      v-old-prod-type = entry( 3, pa-parameters, chr(4) )
      v-old-prod-code = integer( entry( 4, pa-parameters, chr(4) ) )
      v-new-artic     = entry( 5, pa-parameters, chr(4) )
      v-new-prod-type = entry( 6, pa-parameters, chr(4) )
      v-new-prod-code = integer( entry( 7, pa-parameters, chr(4) ) )
    .
  find first buf_BatchProcess exclusive-lock
    where buf_BatchProcess.bp_type   = 'rnar':U
      and buf_BatchProcess.bp_status = 'N':U
      and  buf_BatchProcess.key#_one  = v-old-prod-code
      and buf_BatchProcess.charkey_one = v-old-artic
      and buf_BatchProcess.charkey_two = v-old-prod-type
  no-error .
    if available buf_BatchProcess then do:
      delete buf_BatchProcess.
    end.
  find first buf_BatchProcess exclusive-lock
    where buf_BatchProcess.bp_type   = 'rnar':U
      and buf_BatchProcess.bp_status = 'N':U
      and  buf_BatchProcess.key#_one  = v-new-prod-code
      and buf_BatchProcess.charkey_one = v-new-artic
      and buf_BatchProcess.charkey_two = v-new-prod-type
  no-error .
    if available buf_BatchProcess then do:
      delete buf_BatchProcess.
    end.
  end.
  return.
end procedure.
