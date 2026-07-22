block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: b1849e93de2b, 967, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Tue Apr 18 18:36:50 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00994000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00994000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 107.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-bh as handle no-undo .
define variable lob-res-list as character no-undo .
define variable lob-reslist-date-egais as character no-undo .
define variable lob-reslist-egais-doc as character no-undo .
define variable v-ii as integer no-undo .
define variable v-entry as character no-undo .
define variable v-doc-code as character no-undo .
define buffer old-clob-bind for src.clob-bind.
define buffer new-clob-bind for dst.clob-bind.
define buffer old-clob-data for src.clob-data.
define buffer new-clob-data for dst.clob-data.
define buffer old-blob-bind for src.blob-bind.
define buffer new-blob-bind for dst.blob-bind.
define buffer old-blob-data for src.blob-data.
define buffer new-blob-data for dst.blob-data.
define buffer old-trn-doc   for src.trn-doc.
define buffer new-trn-doc   for dst.trn-doc.
define buffer buf_new-clob-bind for dst.clob-bind.
define buffer old-ext-classif for src.ext-classif.
define buffer new-ext-classif for dst.ext-classif.
define buffer old-doc-attr    for src.doc-attr.
define buffer new-doc-attr    for dst.doc-attr.
on write of dst.ext-classif   override
  do:
  end.
on write of dst.ext-classif-attr override
  do:
  end.
on delete of dst.ext-classif   override
  do:
  end.
on delete of dst.ext-classif-attr override
  do:
  end.
on write of dst.clob-bind   override
  do:
  end.
on write of dst.clob-bind override
  do:
  end.
on delete of dst.clob-bind   override
  do:
  end.
on delete of dst.clob-bind override
  do:
  end.
do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
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
on WRITE of dst.clob-bind             override do: end.
on WRITE of dst.clob-data             override do: end.
on WRITE of dst.blob-bind             override do: end.
on WRITE of dst.blob-data             override do: end.
lob-res-list = 'data':U + chr(44) + 'ref':U + chr(44) + 'list':U + chr(44) + 'list-macro':U.
lob-reslist-date-egais = 'egais-ab':U + chr(44) + 'egais-awo':U + chr(44)
  + chr(44) + 'egais-ab_shop':U + chr(44) + 'egais-awo_shop':U.
lob-reslist-egais-doc = 'egais-wb':U + chr(44) + 'egais-ref-b':U + chr(44) + 'egais-wb-act':U + chr(44) + 'egais-ticket':U + chr(44) + 'egais-wb-ticket':U.
do v-ii = 1 to num-entries(lob-res-list):
  v-entry = entry(v-ii, lob-res-list).
for each old-clob-bind no-lock where
      old-clob-bind.resource-type = v-entry
and old-clob-bind.db-num = 0
and old-clob-bind.int64-id > 0
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    if v-entry = 'data':U then do:
    run gen-row-keyr  in this-procedure (
                                      input  old-clob-bind.uniq-key-rec
                                    ,input  ?
                                    ,input "dst"
                                    ,input  ?
                                    ,input NO-LOCK
                                    ,output v-tbl-row
                                    ,output v-tbl-name ) no-error.
   if error-status:error then next.
   create buffer v-bh for table "dst." + v-tbl-name .
   v-bh:find-by-rowid( v-tbl-row, exclusive-lock ) no-error .
   if not v-bh:available then do:
      delete widget v-bh.
      next.
   end.
   delete widget v-bh.
    end.
   create new-clob-bind.
   buffer-copy old-clob-bind to new-clob-bind.
   for  EACH old-clob-data NO-LOCK
      where      (old-clob-data.db-num = old-clob-bind.db-num
              and old-clob-data.int64-id = old-clob-bind.int64-id )
              or (old-clob-data.file-name = old-clob-bind.uniq-key-rec
                  and
                  old-clob-bind.uniq-key-rec begins "exe/")
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    create new-clob-data.
    buffer-copy old-clob-data to new-clob-data.
   end.
end.
for each old-blob-bind no-lock where
      old-blob-bind.resource-type = v-entry
and old-blob-bind.db-num = 0
and old-blob-bind.int64-id > 0
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    if v-entry = 'data':U then do:
    run gen-row-keyr  in this-procedure (
                                      input  old-blob-bind.uniq-key-rec
                                    ,input  ?
                                    ,input "dst"
                                    ,input  ?
                                    ,input NO-LOCK
                                    ,output v-tbl-row
                                    ,output v-tbl-name ) no-error.
   if error-status:error then next.
   create buffer v-bh for table "dst." + v-tbl-name .
   v-bh:find-by-rowid( v-tbl-row, exclusive-lock ) no-error .
   if not v-bh:available then do:
      delete widget v-bh.
      next.
   end.
   delete widget v-bh.
    end.
   create new-blob-bind.
   buffer-copy old-blob-bind to new-blob-bind.
   for  EACH old-blob-data NO-LOCK
      where      (old-blob-data.db-num = old-blob-bind.db-num
              and old-blob-data.int64-id = old-blob-bind.int64-id )
              or (old-blob-data.file-name = old-blob-bind.uniq-key-rec
                  and
                  old-blob-bind.uniq-key-rec begins "exe/")
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    create new-blob-data.
    buffer-copy old-blob-data to new-blob-data.
   end.
end.
end.
do v-ii = 1 to num-entries(lob-reslist-date-egais):
  v-entry = entry(v-ii, lob-reslist-date-egais).
  cicl0_:
  for each old-clob-bind no-lock where
      old-clob-bind.resource-type = v-entry and old-clob-bind.sys-date >= vardate-actual-docs
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    create new-clob-bind.
    buffer-copy old-clob-bind to new-clob-bind no-error.
    if error-status:error then do:
      delete new-clob-bind.
      next cicl0_.
    end.
    for  EACH old-clob-data NO-LOCK
        where old-clob-data.db-num = old-clob-bind.db-num
                and old-clob-data.int64-id = old-clob-bind.int64-id
      on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      create new-clob-data.
      buffer-copy old-clob-data to new-clob-data no-error.
      if error-status:error then do:
        delete new-clob-data.
        next cicl0_.
      end.
    end.
  end.
end.
cicl1_:
for each old-clob-bind no-lock where
    old-clob-bind.resource-type = 'egais-wb':U
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  v-doc-code = entry (6, old-clob-bind.descr, chr(4)) no-error.
  if v-doc-code <> ? and v-doc-code <> ""
  then do:
    if not can-find (first new-trn-doc where new-trn-doc.doc-code = v-doc-code)
      then next cicl1_.
  end.
  else next cicl1_.
  create new-clob-bind.
  buffer-copy old-clob-bind to new-clob-bind no-error.
  if error-status:error then do:
    delete new-clob-bind.
    next cicl1_.
  end.
  for  EACH old-clob-data NO-LOCK
        where old-clob-data.db-num = old-clob-bind.db-num
                and old-clob-data.int64-id = old-clob-bind.int64-id
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    create new-clob-data.
    buffer-copy old-clob-data to new-clob-data no-error.
    if error-status:error then do:
      delete new-clob-data.
      next cicl1_.
    end.
  end.
end.
cicl2_:
for each old-clob-bind no-lock where
    old-clob-bind.resource-type = 'egais-ref-b':U
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  if not can-find (first new-clob-bind where new-clob-bind.uniq-key-rec = old-clob-bind.uniq-key-rec )
    then next cicl2_.
  create new-clob-bind.
  buffer-copy old-clob-bind to new-clob-bind no-error.
  if error-status:error then do:
    delete new-clob-bind.
    next cicl2_.
  end.
  for  EACH old-clob-data NO-LOCK
        where old-clob-data.db-num = old-clob-bind.db-num
                and old-clob-data.int64-id = old-clob-bind.int64-id
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    create new-clob-data.
    buffer-copy old-clob-data to new-clob-data no-error.
    if error-status:error then do:
      delete new-clob-data.
      next cicl2_.
    end.
  end.
end.
cicl5_:
for each old-clob-bind no-lock where
    (old-clob-bind.resource-type = 'egais-tts':U or old-clob-bind.resource-type = 'egais-tfs':U)
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  create new-clob-bind.
  buffer-copy old-clob-bind to new-clob-bind no-error.
  if error-status:error then do:
    delete new-clob-bind.
    next cicl5_.
  end.
  for  EACH old-clob-data NO-LOCK
        where old-clob-data.db-num = old-clob-bind.db-num
                and old-clob-data.int64-id = old-clob-bind.int64-id
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    create new-clob-data.
    buffer-copy old-clob-data to new-clob-data no-error.
    if error-status:error then do:
      delete new-clob-data.
      next cicl5_.
    end.
  end.
end.
for each buf_new-clob-bind where buf_new-clob-bind.resource-type = 'egais-wb':U no-lock:
for each old-ext-classif  where old-ext-classif.classif-name = 'egais-transId':U and old-ext-classif.CharKey_One = buf_new-clob-bind.uniq-key-rec no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-ext-classif.
   buffer-copy old-ext-classif to new-ext-classif.
end.
  cicl6_:
  for each old-clob-bind where (old-clob-bind.resource-type = 'egais-ticket':U and old-clob-bind.uniq-key-rec begins buf_new-clob-bind.uniq-key-rec)
                              or (not old-clob-bind.uniq-key-rec begins buf_new-clob-bind.uniq-key-rec and old-clob-bind.resource-type = 'egais-ticket':U and lookup (old-clob-bind.field-name_, buf_new-clob-bind.field-name_) > 0)
                              or can-find (first new-ext-classif where new-ext-classif.classif-name = 'egais-transId':U
                                and new-ext-classif.db-num = 0
                                and new-ext-classif.CharKey_One = buf_new-clob-bind.uniq-key-rec
                                and new-ext-classif.CharKey_Two = old-clob-bind.field-name_)
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    create new-clob-bind.
    buffer-copy old-clob-bind to new-clob-bind no-error.
    if error-status:error then do:
      delete new-clob-bind.
      next cicl6_.
    end.
    for  EACH old-clob-data NO-LOCK
        where old-clob-data.db-num = old-clob-bind.db-num
                and old-clob-data.int64-id = old-clob-bind.int64-id
      on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      create new-clob-data.
      buffer-copy old-clob-data to new-clob-data no-error.
      if error-status:error then do:
        delete new-clob-data.
        next cicl6_.
      end.
    end.
  end.
  cicl7_:
  for each old-clob-bind where old-clob-bind.resource-type = 'egais-wb-ticket':U and old-clob-bind.uniq-key-rec begins buf_new-clob-bind.uniq-key-rec
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    create new-clob-bind.
    buffer-copy old-clob-bind to new-clob-bind no-error.
    if error-status:error then do:
      delete new-clob-bind.
      next cicl7_.
    end.
    for  EACH old-clob-data NO-LOCK
        where old-clob-data.db-num = old-clob-bind.db-num
                and old-clob-data.int64-id = old-clob-bind.int64-id
      on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      create new-clob-data.
      buffer-copy old-clob-data to new-clob-data no-error.
      if error-status:error then do:
        delete new-clob-data.
        next cicl7_.
      end.
    end.
  end.
end.
for each old-ext-classif where old-ext-classif.classif-name = 'egais-transId':U and can-find (first new-trn-doc where new-trn-doc.doc-code = old-ext-classif.CharKey_One):
  create new-ext-classif.
  buffer-copy old-ext-classif to new-ext-classif.
  cicl3_:
  for each old-clob-bind where
    old-ext-classif.CharKey_Two = old-clob-bind.field-name_
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    create new-clob-bind.
    buffer-copy old-clob-bind to new-clob-bind no-error.
    if error-status:error then do:
      delete new-clob-bind.
      next cicl3_.
    end.
    for  EACH old-clob-data NO-LOCK
        where old-clob-data.db-num = old-clob-bind.db-num
                and old-clob-data.int64-id = old-clob-bind.int64-id
      on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      create new-clob-data.
      buffer-copy old-clob-data to new-clob-data no-error.
      if error-status:error then do:
        delete new-clob-data.
        next cicl3_.
      end.
    end.
  end.
end.
cicl4_:
for each old-clob-bind where
      old-clob-bind.resource-type = 'egais-wb-act':U
  and can-find (first new-doc-attr where new-doc-attr.attr-code = 'negais':U and old-clob-bind.uniq-key-rec matches ("*" + new-doc-attr.attr-value + "*"))
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  create new-clob-bind.
  buffer-copy old-clob-bind to new-clob-bind no-error.
  if error-status:error then do:
    delete new-clob-bind.
    next cicl4_.
  end.
  for  EACH old-clob-data NO-LOCK
        where old-clob-data.db-num = old-clob-bind.db-num
                and old-clob-data.int64-id = old-clob-bind.int64-id
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    create new-clob-data.
    buffer-copy old-clob-data to new-clob-data no-error.
    if error-status:error then do:
      delete new-clob-data.
      next cicl4_.
    end.
  end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: clob-data clob-bind blob-bind blob-data.".
end.
