block-level on error undo, throw.
using ibs.th.str.*.
define  shared temp-table tt-susp-chk no-undo like ub.susp-chk .
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input  parameter p-check-cass    as   logical             no-undo.
define input  parameter p-silent        as   logical             no-undo .
define variable vss-revision    as char no-undo init "$Revision$":U .
define variable vss-author      as char no-undo init "$Author$":U .
define variable vss-date        as char no-undo init "$Date$":U .
define variable vss-workfile    as char no-undo init "$Workfile$":U .
define variable vss-archive     as char no-undo init "$Archive$":U .
define variable vss-description as char no-undo init "Закрытие смены".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable s-date                as date      no-undo .
define variable e-date                as date      no-undo .
define variable s-time                as integer   no-undo .
define variable e-time                as integer   no-undo .
define variable s-num                 as integer   no-undo .
define variable s-name                as character no-undo .
define variable is-super              as logical   no-undo .
define variable v-cancel              as logical   no-undo .
define variable glog                  as logical   no-undo .
define variable v-cur-date-error-code as integer   no-undo .
define variable v-err-msg             as character no-undo .
define variable v-rum-err             as logical   no-undo .
define variable v-shift-date          as date      no-undo .
define variable v-shift-num           as integer   no-undo .
define variable v-shift-name          as character no-undo .
define variable v-obj-date            as date      no-undo .
define variable ii                    as integer   no-undo .
define variable place-list            as character no-undo .
define buffer buf_pl-gds     for ub.pl-gds .
define buffer buf_shift-obj  for ub.shift-obj .
define buffer buf_place-attr for ub.place-attr .
define buffer buf_place-imp  for ub.place-imp .
define buffer cur_rvs-doc    for ub.rvs-doc .
define buffer cur_rvs-line   for ub.rvs-line .
define buffer prev_shift-obj for ub.shift-obj .
define buffer prev_rvs-doc   for ub.rvs-doc .
define buffer prev_rvs-line  for ub.rvs-line .
define buffer buf_place      for ub.place .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
assign
    is-super = no
    .
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_shift_super':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output glog
    )  .
end.
if glog
    then
do:
    assign
        is-super = yes
        .
end.
else
do:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_shift_regular':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output glog
    )  .
end.
end.
if not glog then
do:
    assign
        v-err-msg = substitute( "Вы не имеете прав для работы со сменами.&1Объект: &2&3&1", chr(10), p-curr-obj-type, p-curr-obj-code )
        .
    if p-silent <> true then
    do:
        message
            v-err-msg
            view-as alert-box information.
    end.
    undo, return error v-err-msg .
end.
find first buf_shift-obj
    where buf_shift-obj.obj-type = p-curr-obj-type
    and buf_shift-obj.obj-code = p-curr-obj-code
    and buf_shift-obj.status_ = 'тек':U
    use-index pi
    no-error.
if not available buf_shift-obj then
do:
    assign
        v-err-msg = substitute( "Нет открытой смены на объекте: &2&3&1Невозможно закрыть текущую смену.", chr(10), p-curr-obj-type, p-curr-obj-code )
        .
    if p-silent <> true then
    do:
        message
            v-err-msg
            view-as alert-box error.
    end.
    undo, return error v-err-msg .
end.
assign
    s-date       = buf_shift-obj.shift-date
    s-num        = buf_shift-obj.shift-num
    s-name       = buf_shift-obj.shift-name
    s-time       = buf_shift-obj.open-time
    v-shift-date = buf_shift-obj.shift-date
    v-shift-num  = buf_shift-obj.shift-num
    v-shift-name = buf_shift-obj.shift-name
    .
if p-silent <> true then
do:
    glog = no.
    message
        "Закрыть текущую смену по" p-curr-obj-type p-curr-obj-code skip
        "Дата начала смены:" buf_shift-obj.open-date skip
        "Время начала смены:" string( buf_shift-obj.open-time, "HH:MM" ) skip
        "Номер смены:" s-name skip
        "Порядок смены:" s-num "?"
        view-as alert-box question buttons OK-Cancel update glog.
    if not glog then
        return error.
end.
if buf_shift-obj.open-id <> v-cntxt-userid
    and is-super = false
    then
do:
    assign
        v-err-msg = substitute( "Смена должна быть закрыта тем же пользователем,&1"
                            + "который ее открывал или менеджером.&1"
                            + "Невозможно закрыть текущую смену.&1"
                            + "Открыл текущую смену: &2&1"
                            , chr(10)
                            , buf_shift-obj.open-id
                          ) .
    if p-silent <> true then
    do:
        message
            v-err-msg
            view-as alert-box.
    end.
    undo, return error v-err-msg .
end.
if p-check-cass = true then
do:
    run str/deskshft.p
        ( input parparentproc
        ,input p-silent
        ,input p-curr-obj-type
        ,input p-curr-obj-code
        ,input s-date
        ,input s-num
        ,input s-name
        ) no-error.
    if error-status :error then
    do:
        assign
            v-err-msg = substitute( "&1.&2&3&2&4&2"
                                , vss-workfile
                                , chr(10)
                                , return-value
                                , error-status :get-message (1)
                              ).
        if p-silent <> true then
        do:
            message
                v-err-msg
                view-as alert-box error.
        end.
        undo, return error v-err-msg .
    end.
end.
if p-silent <> true then
do:
    run gbl/shift.w
        ( input parparentproc
        ,input p-curr-obj-type
        ,input p-curr-obj-code
        ,input-output s-date
        ,input-output e-date
        ,input-output s-time
        ,input-output e-time
        ,input-output s-num
        ,input-output s-name
        ,input 'time-only':U
        ,output v-cancel
        ) no-error.
    if error-status:error then
    do:
        message
            vss-workfile vss-revision vss-description
            skip
            "Ошибка ввода времени для закрытия смены."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
            view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = true then
    do:
        undo, return error.
    end.
end.
run str/checknakl.p
    ( input parparentproc
    ,input p-silent
    ,input p-curr-obj-type
    ,input p-curr-obj-code
    ,input s-date
    ,input s-num
    ,input s-name
    ,output v-cancel
    ) no-error.
if v-cancel = false then
do:
    undo, return error.
end.
stop-shift:
do transaction
    on error undo stop-shift, return error return-value
    :
define variable prc-dev-mass as decimal no-undo .
define variable dev-paid-trans as decimal no-undo .
define buffer buf_shift-param for ub.shift-param .
define buffer buf_rvs-doc       for ub.rvs-doc .
define buffer buf_rvs-line      for ub.rvs-line .
define buffer buf_chk-doc       for ub.chk-doc .
define buffer buf_chk-gds       for ub.chk-gds.
define buffer bf_chk-gds        for ub.chk-gds.
define buffer buf_bar-code      for ub.bar-code.
define buffer bf_place          for ub.place .
define buffer buf_goods         for ub.goods .
define buffer buf_rvs-line-pump for ub.rvs-line-pump .
define buffer buf_chk-doc-attr  for ub.chk-doc-attr .
define buffer bf_chk-doc-attr   for ub.chk-doc-attr .
define buffer buf_chk-pay       for ub.chk-pay .
define buffer buf_cash-pay      for ub.cash-pay .
define buffer buf_susp-chk      for ub.susp-chk .
define buffer bf_susp-chk       for ub.susp-chk .
define variable v-qnty          like ub.chk-gds.doc-qnty no-undo init 0.
define variable ShiftDate-Start as date      no-undo .
define variable ShiftNum-Start  as integer   no-undo .
define variable v-gds-name      as character no-undo .
define variable v-dop           as decimal   no-undo .
define variable errorTRK        as logical   no-undo init false .
define variable errorMass       as logical   no-undo init false .
define variable errorCheck      as logical   no-undo init false .
define variable v-num           as character no-undo .
define variable v-ok            as logical   no-undo init false.
define variable v-close         as logical   no-undo .
define variable close-date      as date      no-undo .
define variable close-time      as integer   no-undo .
define temp-table t-9 no-undo
    field gds-code           like ub.goods.gds-code
    field gds-name           like ub.goods.gds-name
    field pl-code            like ub.rvs-line-pump.pl-code
    field obj-code           as integer
    field obj-type           as character
    field shift-date         as date
    field shift-name         as character
    field shift-num          as integer
    field pump-code          like ub.rvs-line-pump.pump-code
    field nozzle-code        like ub.rvs-line-pump.nozzle-code
    field start-mh-qnty      like ub.rvs-line-pump.meas-mh-cnt
    field end-mh-qnty        like ub.rvs-line-pump.meas-mh-cnt
    field meas-qnty          like ub.rvs-line-pump.meas-mh-cnt
    field prev-start-mh-qnty like ub.rvs-line-pump.meas-mh-cnt
    field itog-meas-qnty     like ub.rvs-line-pump.meas-mh-cnt
    field start-el-qnty      like ub.rvs-line-pump.meas-el-cnt
    field end-el-qnty        like ub.rvs-line-pump.meas-el-cnt
    field prev-start-el-qnty like ub.rvs-line-pump.meas-el-cnt
    field sale-kg            as decimal
    field itog-sale          as decimal
    field loc1               as character
    field doc-qnty           as decimal   INITIAL 0
    field delta              as decimal   INITIAL 0
    field itog-delta         as decimal   INITIAL 0
    field cancell-qnty       as decimal   INITIAL 0
    field cancell-qnty-notot as decimal   INITIAL 0
    field overflow-qnty      as decimal   INITIAL 0
    field trans-qnty         as decimal   INITIAL 0
    field tech-refuell-qnty  as decimal   INITIAL 0
    index pi is unique primary
    gds-code
    pump-code
    nozzle-code
    .
define temp-table tt-rvs-line no-undo
    field gds-code         as integer
    field pl-code          as integer
    field gds-name         as character
    field fact-stock-start as decimal
    field fact-stock-end   as decimal
    field rast-stock-end   as decimal
    field sale-kg          as decimal
    field tech-refuell     as decimal
    field obj-code         as integer
    field obj-type         as character
    field income           as decimal
    field loc1             as character
    index pi as unique primary
    gds-code
    pl-code
    .
define temp-table tt-chk-doc like ub.susp-chk
    .
define buffer buf_t-9  for t-9 .
define buffer buf2_t-9 for t-9 .
FIND LAST  buf_shift-obj
    WHERE buf_shift-obj.obj-type = p-curr-obj-type
    AND buf_shift-obj.obj-code = p-curr-obj-code
    and (
    (buf_shift-obj.shift-date = v-shift-date
    AND     buf_shift-obj.shift-num < v-shift-num)
    OR
    buf_shift-obj.shift-date < v-shift-date)
    use-index pi
    NO-LOCK
    NO-ERROR
    .
IF AVAILABLE buf_shift-obj THEN
DO:
    ShiftDate-Start = buf_shift-obj.shift-date .
    ShiftNum-Start = buf_shift-obj.shift-num .
    for each buf_rvs-doc
        where  buf_rvs-doc.obj-type  = p-curr-obj-type
        and   buf_rvs-doc.obj-code   = p-curr-obj-code
        and   buf_rvs-doc.status_    = 'факт':U
        and   buf_rvs-doc.shift-date = buf_shift-obj.shift-date
        and   buf_rvs-doc.shift-num  = buf_shift-obj.shift-num
        and   buf_rvs-doc.rvs-type   = 'смена':U
        no-lock:
        for each prev_rvs-line no-lock where prev_rvs-line.rvs-code = buf_rvs-doc.rvs-code and
            prev_rvs-line.obj-code = buf_rvs-doc.obj-code and
            prev_rvs-line.obj-type = buf_rvs-doc.obj-type:
            find first tt-rvs-line where tt-rvs-line.gds-code = prev_rvs-line.gds-code and
                tt-rvs-line.pl-code = prev_rvs-line.pl-code no-error .
            if not available (tt-rvs-line) then
            do:
                create tt-rvs-line .
                assign
                    tt-rvs-line.gds-code = prev_rvs-line.gds-code
                    tt-rvs-line.pl-code  = prev_rvs-line.pl-code
                    .
                find first ub.place no-lock
                    where ub.place.obj-code = prev_rvs-line.obj-code
                    and ub.place.obj-type = prev_rvs-line.obj-type
                    and ub.place.pl-code  = prev_rvs-line.pl-code
                    no-error.
                if available ub.place then
                do:
                    tt-rvs-line.loc1 = ub.place.loc1
                        .
                end.
            end.
            tt-rvs-line.fact-stock-start = prev_rvs-line.state-measure-qnty + prev_rvs-line.state-add-qnty * prev_rvs-line.state-density .
        end.
        FOR EACH    buf_rvs-line-pump
            WHERE buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
            NO-LOCK
            :
            find first buf_t-9
                WHERE  buf_t-9.gds-code    = buf_rvs-line-pump.gds-code
                AND buf_t-9.pump     = buf_rvs-line-pump.pump-code
                and buf_t-9.nozzle-code = buf_rvs-line-pump.nozzle-code
                no-error
                .
            if not available buf_t-9 then
            do:
                find first buf_goods
                    where buf_goods.gds-code = buf_rvs-line-pump.gds-code
                    no-lock
                    no-error
                    .
                IF AVAILABLE buf_goods THEN
                DO:
                    assign
                        v-gds-name = buf_goods.gds-name
                        .
                END.
                else
                do:
                    assign
                        v-gds-name = SUBSTITUTE("Товар &1 не найден", buf_rvs-line-pump.gds-code)
                        .
                end.
                create buf_t-9.
                assign
                    buf_t-9.gds-code    = buf_rvs-line-pump.gds-code
                    buf_t-9.pl-code     = buf_rvs-line-pump.pl-code
                    buf_t-9.pump-code   = buf_rvs-line-pump.pump-code
                    buf_t-9.nozzle-code = buf_rvs-line-pump.nozzle-code
                    buf_t-9.gds-name    = v-gds-name
                    .
                ASSIGN
                    buf_t-9.start-mh-qnty      = buf_rvs-line-pump.state-mh-cnt
                    buf_t-9.end-mh-qnty        = buf_rvs-line-pump.state-mh-cnt
                    buf_t-9.prev-start-mh-qnty = buf_rvs-line-pump.state-mh-cnt
                    buf_t-9.start-el-qnty      = buf_rvs-line-pump.state-el-cnt
                    buf_t-9.end-el-qnty        = buf_rvs-line-pump.state-el-cnt
                    buf_t-9.prev-start-el-qnty = buf_rvs-line-pump.state-el-cnt
                    buf_t-9.delta              = - buf_t-9.meas-qnty
                    .
            end.
        END.
        RELEASE buf_rvs-doc.
    END.
END.
for each buf_shift-obj no-lock where
    buf_shift-obj.obj-type = p-curr-obj-type
    and buf_shift-obj.obj-code = p-curr-obj-code
    and (buf_shift-obj.shift-date > v-shift-date
    or (buf_shift-obj.shift-date = v-shift-date
    and
    buf_shift-obj.shift-num >= v-shift-num))
    and
    (buf_shift-obj.shift-date < v-shift-date
    or (buf_shift-obj.shift-date = v-shift-date
    and
    buf_shift-obj.shift-num <= v-shift-num))
    by buf_shift-obj.shift-date
    by buf_shift-obj.shift-num:
    for first buf_rvs-doc
        where  buf_rvs-doc.obj-type  = p-curr-obj-type
        and   buf_rvs-doc.obj-code   = p-curr-obj-code
        and   buf_rvs-doc.status_    = 'факт':U
        and   buf_rvs-doc.shift-date = buf_shift-obj.shift-date
        and   buf_rvs-doc.shift-num  = buf_shift-obj.shift-num
        and   buf_rvs-doc.rvs-type   = 'смена':U
        no-lock:
            assign
            close-date = buf_rvs-doc.fact-date
            close-time = buf_rvs-doc.fact-order
            .
        FOR EACH    buf_rvs-line-pump
            WHERE buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
            NO-LOCK
            :
            find first buf_t-9
                WHERE  buf_t-9.gds-code    = buf_rvs-line-pump.gds-code
                AND buf_t-9.pump-code       = buf_rvs-line-pump.pump-code
                and buf_t-9.nozzle-code = buf_rvs-line-pump.nozzle-code
                no-error
                .
            if not available buf_t-9 then
            do:
                find first buf2_t-9
                    WHERE   buf2_t-9.pump-code        = buf_rvs-line-pump.pump-code
                    and buf_t-9.nozzle-code = buf_rvs-line-pump.nozzle-code
                    no-error
                    .
                find first buf_goods
                    where buf_goods.gds-code = buf_rvs-line-pump.gds-code
                    no-lock
                    no-error
                    .
                IF AVAILABLE buf_goods THEN
                DO:
                    assign
                        v-gds-name = buf_goods.gds-name
                        .
                END.
                else
                do:
                    assign
                        v-gds-name = SUBSTITUTE("Товар &1 не найден", buf_rvs-line-pump.gds-code)
                        .
                end.
                create buf_t-9.
                assign
                    buf_t-9.gds-code    = buf_rvs-line-pump.gds-code
                    buf_t-9.pl-code     = buf_rvs-line-pump.pl-code
                    buf_t-9.pump-code   = buf_rvs-line-pump.pump-code
                    buf_t-9.nozzle-code = buf_rvs-line-pump.nozzle-code
                    buf_t-9.gds-name    = v-gds-name
                    .
                if available buf2_t-9 then
                do:
                    assign
                        buf_t-9.start-mh-qnty      = buf2_t-9.prev-start-mh-qnty
                        buf_t-9.end-mh-qnty        = buf2_t-9.prev-start-mh-qnty
                        buf_t-9.prev-start-mh-qnty = buf2_t-9.prev-start-mh-qnty
                        buf_t-9.start-el-qnty      = buf2_t-9.prev-start-el-qnty
                        buf_t-9.end-el-qnty        = buf2_t-9.prev-start-el-qnty
                        buf_t-9.prev-start-el-qnty = buf2_t-9.prev-start-el-qnty
                        .
                end.
                else
                do:
                    v-dop = ?.
                    run get-state-mh-cnt-from-icnt-doc in this-procedure (
                        input p-curr-obj-type
                        ,input p-curr-obj-code
                        ,input buf_shift-obj.shift-date
                        ,input buf_shift-obj.shift-num
                        ,input buf_rvs-doc.fact-order
                        ,input buf_t-9.gds-code
                        ,input buf_t-9.pl-code
                        ,input buf_t-9.pump-code
                        ,input buf_t-9.nozzle-code
                        ,input-output buf_t-9.prev-start-mh-qnty
                        ,input-output buf_t-9.prev-start-el-qnty
                        ).
                    ASSIGN
                        buf_t-9.start-mh-qnty = buf_t-9.prev-start-mh-qnty
                        buf_t-9.end-mh-qnty   = buf_t-9.prev-start-mh-qnty
                        buf_t-9.start-el-qnty = buf_t-9.prev-start-el-qnty
                        buf_t-9.end-el-qnty   = buf_t-9.prev-start-el-qnty
                        .
                end.
            end.
            if buf_rvs-line-pump.state-mh-cnt <  buf_t-9.end-mh-qnty then
            do:
                v-dop = ?.
                run get-state-mh-cnt-from-icnt-doc in this-procedure (
                    input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input buf_shift-obj.shift-date
                    ,input buf_shift-obj.shift-num
                    ,input buf_rvs-doc.fact-order
                    ,input buf_t-9.gds-code
                    ,input buf_t-9.pl-code
                    ,input buf_t-9.pump-code
                    ,input buf_t-9.nozzle-code
                    ,input-output buf_t-9.prev-start-mh-qnty
                    ,input-output buf_t-9.prev-start-el-qnty
                    ).
            end.
            ASSIGN
                buf_t-9.end-mh-qnty        = buf_rvs-line-pump.state-mh-cnt
                buf_t-9.end-el-qnty        = buf_rvs-line-pump.state-el-cnt
                buf_t-9.meas-qnty          = buf_t-9.meas-qnty + buf_rvs-line-pump.state-el-cnt - buf_t-9.prev-start-el-qnty
                buf_t-9.delta              = - buf_t-9.meas-qnty
                buf_t-9.prev-start-mh-qnty = buf_rvs-line-pump.state-mh-cnt
                buf_t-9.prev-start-el-qnty = buf_rvs-line-pump.state-el-cnt
                .
        END.
        for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code and
            buf_rvs-line.obj-code = buf_rvs-doc.obj-code and
            buf_rvs-line.obj-type = buf_rvs-doc.obj-type:
            find first tt-rvs-line where tt-rvs-line.gds-code = buf_rvs-line.gds-code and
                tt-rvs-line.pl-code = buf_rvs-line.pl-code no-error .
            if not available (tt-rvs-line) then
            do:
                find first buf_goods
                    where buf_goods.gds-code = buf_rvs-line.gds-code
                    no-lock
                    no-error
                    .
                IF AVAILABLE buf_goods THEN
                DO:
                    assign
                        v-gds-name = buf_goods.gds-name
                        .
                END.
                else
                do:
                    assign
                        v-gds-name = SUBSTITUTE("Товар &1 не найден", buf_rvs-line.gds-code)
                        .
                end.
                create tt-rvs-line .
                assign
                    tt-rvs-line.gds-code = buf_rvs-line.gds-code
                    tt-rvs-line.gds-name = v-gds-name
                    tt-rvs-line.pl-code  = buf_rvs-line.pl-code
                    tt-rvs-line.obj-code = buf_rvs-line.obj-code
                    tt-rvs-line.obj-type = buf_rvs-line.obj-type .
                find first ub.place no-lock
                    where ub.place.obj-code = buf_rvs-line.obj-code
                    and ub.place.obj-type = buf_rvs-line.obj-type
                    and ub.place.pl-code  = buf_rvs-line.pl-code
                    no-error.
                if available ub.place then
                do:
                    tt-rvs-line.loc1 = ub.place.loc1
                        .
                end.
            end.
            tt-rvs-line.fact-stock-end = buf_rvs-line.state-measure-qnty + buf_rvs-line.state-add-qnty * buf_rvs-line.state-density .
        end.
    END.
end.
for each tt-rvs-line:
    for each ub.trn-doc no-lock
        where ub.trn-doc.obj-type   = p-curr-obj-type
        and ub.trn-doc.obj-code   = p-curr-obj-code
        and ub.trn-doc.shift-date = v-shift-date
        and ub.trn-doc.shift-num = v-shift-num
        and ub.trn-doc.status_    = 'факт':U
        and ub.trn-doc.doc-type   = 'при':U
        on error undo, return error return-value
        :
        for each ub.doc-pl no-lock
            where ub.doc-pl.gds-code = tt-rvs-line.gds-code
            and ub.doc-pl.obj-code = tt-rvs-line.obj-code
            and ub.doc-pl.obj-type = tt-rvs-line.obj-type
            and ub.doc-pl.out-code = ub.trn-doc.doc-code
            and ub.doc-pl.pl-code  = tt-rvs-line.pl-code
            on error undo, return error return-value
            :
            assign
                tt-rvs-line.income = tt-rvs-line.income + ub.doc-pl.cli-fact-qnty
                .
        end.
    end.
end.
_shift-chk:
FOR EACH buf_chk-doc
    WHERE buf_chk-doc.obj-type = p-curr-obj-type
    AND   buf_chk-doc.obj-code = p-curr-obj-code
    AND   buf_chk-doc.shift-date = v-shift-date
    and  buf_chk-doc.shift-num = v-shift-num
    and buf_chk-doc.shift-name = v-shift-name
    NO-LOCK
    :
    for each buf_chk-gds
        where buf_chk-gds.doc-code = buf_chk-doc.doc-code
        no-lock,
        first buf_bar-code
        where buf_bar-code.b-code = buf_chk-gds.b-code
        no-lock,
        first buf_goods where buf_goods.gds-code = buf_bar-code.gds-code no-lock
        :
        find first tt-rvs-line no-lock where tt-rvs-line.gds-code = buf_goods.gds-code no-error .
        if available (tt-rvs-line) then
        do:
            find first buf_t-9
                WHERE
                buf_t-9.gds-code    = buf_bar-code.gds-code and
                buf_t-9.pump-code   = buf_chk-gds.pump and
                buf_t-9.nozzle-code = buf_chk-gds.nozzle-code
                no-error
                .
            if not available buf_t-9 then
            do:
                create buf_t-9.
                assign
                    buf_t-9.gds-code    = buf_bar-code.gds-code
                    buf_t-9.gds-name    = buf_goods.gds-name
                    buf_t-9.pl-code     = buf_chk-gds.pl-code
                    buf_t-9.pump-code   = buf_chk-gds.pump
                    buf_t-9.nozzle-code = buf_chk-gds.nozzle-code
                    .
            end.
        end.
        v-qnty        = buf_chk-gds.doc-qnty .
        case buf_chk-doc.chk-type:
            WHEN integer('1':U) or
            WHEN integer('6':U)
            then
                do:
                    if available (tt-rvs-line) then
                    do:
                        assign
                            buf_t-9.doc-qnty    = buf_t-9.doc-qnty + v-qnty
                            buf_t-9.delta       = buf_t-9.delta + v-qnty
                            tt-rvs-line.sale-kg = buf_t-9.doc-qnty * buf_chk-gds.density
                            buf_t-9.sale-kg     = buf_t-9.doc-qnty
                            .
                    end.
                end.
            WHEN integer('17':U) THEN
                DO:
                    if available (tt-rvs-line) then
                    do:
                        assign
                            buf_t-9.tech-refuell-qnty = buf_t-9.tech-refuell-qnty + v-qnty
                            tt-rvs-line.tech-refuell  = tt-rvs-line.tech-refuell + v-qnty
                            .
                    end.
                end.
            OTHERWISE
            DO:
            end.
        END case.
    end.
    case buf_chk-doc.chk-type:
        WHEN integer('1':U) then
            do:
                for each buf_chk-doc-attr no-lock where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code and
                    buf_chk-doc-attr.attr-code = "create-type" and
                    buf_chk-doc-attr.attr-value = "manual":
                    if can-find (first buf_chk-gds where buf_chk-gds.doc-code = buf_chk-doc.doc-code
                        and buf_chk-gds.pass-gds = 1) then
                    do:
                        if not can-find (ub.chk-doc-attr where chk-doc-attr.doc-code = buf_chk-doc.doc-code and
                            ub.chk-doc-attr.attr-code = "CHFiscalDocNumber") then
                        do:
                            find first tt-chk-doc where tt-chk-doc.doc-code = buf_chk-doc.doc-code no-error .
                            if not available (tt-chk-doc) then
                            do:
                                create tt-chk-doc.
                                assign
                                    tt-chk-doc.chk-date   = buf_chk-doc.chk-date
                                    tt-chk-doc.chk-time   = buf_chk-doc.chk-time
                                    tt-chk-doc.chk-num    = buf_chk-doc.chk-num
                                    tt-chk-doc.chk-type   = buf_chk-doc.chk-type
                                    tt-chk-doc.doc-code   = buf_chk-doc.doc-code
                                    tt-chk-doc.obj-code   = buf_chk-doc.obj-code
                                    tt-chk-doc.obj-type   = buf_chk-doc.obj-type
                                    tt-chk-doc.pay-desk   = buf_chk-doc.pay-desk
                                    tt-chk-doc.shift-date = buf_chk-doc.shift-date
                                    tt-chk-doc.shift-name = buf_chk-doc.shift-name
                                    tt-chk-doc.shift-num  = buf_chk-doc.shift-num
                                    .
                            end.
                            if tt-chk-doc.office = "" then tt-chk-doc.office = "сухой чек прихода в ТН" .
                            else tt-chk-doc.office = tt-chk-doc.office + ", " + "сухой чек прихода в ТН" .
                        end.
                    end.
                end.
                if available (tt-rvs-line) then
                do:
                    find first bar-code no-lock where bar-code.gds-code = tt-rvs-line.gds-code no-error .
                    find first buf_chk-gds where buf_chk-gds.doc-code = buf_chk-doc.doc-code
                        and buf_chk-gds.b-code = bar-code.b-code and buf_chk-gds.pass-gds = 1 no-lock no-error.
                    IF AVAILABLE buf_chk-gds THEN
                    DO:
                        if not can-find (ub.chk-doc-attr where chk-doc-attr.doc-code = buf_chk-doc.doc-code and
                            ub.chk-doc-attr.attr-code = "CHFiscalDocNumber") then next .
                        find first tt-chk-doc where tt-chk-doc.doc-code = buf_chk-doc.doc-code no-error .
                        if not available (tt-chk-doc) then
                        do:
                            create tt-chk-doc.
                            assign
                                tt-chk-doc.chk-date   = buf_chk-doc.chk-date
                                tt-chk-doc.chk-time   = buf_chk-doc.chk-time
                                tt-chk-doc.chk-num    = buf_chk-doc.chk-num
                                tt-chk-doc.chk-type   = buf_chk-doc.chk-type
                                tt-chk-doc.doc-code   = buf_chk-doc.doc-code
                                tt-chk-doc.obj-code   = buf_chk-doc.obj-code
                                tt-chk-doc.obj-type   = buf_chk-doc.obj-type
                                tt-chk-doc.pay-desk   = buf_chk-doc.pay-desk
                                tt-chk-doc.shift-date = buf_chk-doc.shift-date
                                tt-chk-doc.shift-name = buf_chk-doc.shift-name
                                tt-chk-doc.shift-num  = buf_chk-doc.shift-num
                                .
                        end.
                        if tt-chk-doc.office = "" then tt-chk-doc.office = "сухой чек прихода топлива на кассе" .
                        else tt-chk-doc.office = tt-chk-doc.office + ", сухой чек прихода топлива на кассе" .
                    end.
                end.
            end.
        WHEN integer('6':U)
        then
            do:
                if available (tt-rvs-line) then
                do:
                    find first buf_chk-doc-attr where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
                        and buf_chk-doc-attr.attr-code = 'CHFlag1' and (buf_chk-doc-attr.attr-value = "4" or
                        buf_chk-doc-attr.attr-value = "3" or buf_chk-doc-attr.attr-value = "2") no-lock no-error.
                    IF AVAILABLE buf_chk-doc-attr THEN
                    DO:
                        find first bf_chk-doc-attr where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
                            and bf_chk-doc-attr.attr-code = 'CHMgrKey' and bf_chk-doc-attr.attr-value = "1" no-lock no-error .
                        if available (bf_chk-doc-attr) then
                        do:
                            find first tt-chk-doc where tt-chk-doc.doc-code = buf_chk-doc.doc-code no-error .
                            if not available (tt-chk-doc) then
                            do:
                                create tt-chk-doc.
                                assign
                                    tt-chk-doc.chk-date   = buf_chk-doc.chk-date
                                    tt-chk-doc.chk-time   = buf_chk-doc.chk-time
                                    tt-chk-doc.chk-num    = buf_chk-doc.chk-num
                                    tt-chk-doc.chk-type   = buf_chk-doc.chk-type
                                    tt-chk-doc.doc-code   = buf_chk-doc.doc-code
                                    tt-chk-doc.obj-code   = buf_chk-doc.obj-code
                                    tt-chk-doc.obj-type   = buf_chk-doc.obj-type
                                    tt-chk-doc.pay-desk   = buf_chk-doc.pay-desk
                                    tt-chk-doc.shift-date = buf_chk-doc.shift-date
                                    tt-chk-doc.shift-name = buf_chk-doc.shift-name
                                    tt-chk-doc.shift-num  = buf_chk-doc.shift-num
                                    .
                            end.
                            if tt-chk-doc.office = "" then tt-chk-doc.office = "полный возврат" .
                            else tt-chk-doc.office = tt-chk-doc.office + ", полный возврат" .
                        end.
                    end.
                end.
            end.
        WHEN integer('14':U) THEN
            DO:
                find first tt-chk-doc where tt-chk-doc.doc-code = buf_chk-doc.doc-code no-error .
                if not available (tt-chk-doc) then
                do:
                    create tt-chk-doc.
                    assign
                        tt-chk-doc.chk-date   = buf_chk-doc.chk-date
                        tt-chk-doc.chk-time   = buf_chk-doc.chk-time
                        tt-chk-doc.chk-num    = buf_chk-doc.chk-num
                        tt-chk-doc.chk-type   = buf_chk-doc.chk-type
                        tt-chk-doc.doc-code   = buf_chk-doc.doc-code
                        tt-chk-doc.obj-code   = buf_chk-doc.obj-code
                        tt-chk-doc.obj-type   = buf_chk-doc.obj-type
                        tt-chk-doc.pay-desk   = buf_chk-doc.pay-desk
                        tt-chk-doc.shift-date = buf_chk-doc.shift-date
                        tt-chk-doc.shift-name = buf_chk-doc.shift-name
                        tt-chk-doc.shift-num  = buf_chk-doc.shift-num
                        .
                end.
                if tt-chk-doc.office = "" then tt-chk-doc.office = "сброс топл.транзакции" .
                else tt-chk-doc.office = tt-chk-doc.office + ", сброс топл.транзакции" .
            end.
        OTHERWISE
        DO:
        end.
    END case.
    if available (tt-rvs-line) then
    do:
        define variable disp_ as character no-undo .
        for each buf_chk-pay no-lock where buf_chk-pay.doc-code = buf_chk-doc.doc-code and (buf_chk-pay.pay-code = 0064 or buf_chk-pay.pay-code = 4006):
            if buf_chk-pay.pay-code = 0064 then disp_ = "постоплата" .
            else disp_ = "криминальный уезд" .
            find first tt-chk-doc where tt-chk-doc.doc-code = buf_chk-doc.doc-code no-error .
            if not available (tt-chk-doc) then
            do:
                create tt-chk-doc.
                assign
                    tt-chk-doc.chk-date   = buf_chk-doc.chk-date
                    tt-chk-doc.chk-time   = buf_chk-doc.chk-time
                    tt-chk-doc.chk-num    = buf_chk-doc.chk-num
                    tt-chk-doc.chk-type   = buf_chk-doc.chk-type
                    tt-chk-doc.doc-code   = buf_chk-doc.doc-code
                    tt-chk-doc.obj-code   = buf_chk-doc.obj-code
                    tt-chk-doc.obj-type   = buf_chk-doc.obj-type
                    tt-chk-doc.pay-desk   = buf_chk-doc.pay-desk
                    tt-chk-doc.shift-date = buf_chk-doc.shift-date
                    tt-chk-doc.shift-name = buf_chk-doc.shift-name
                    tt-chk-doc.shift-num  = buf_chk-doc.shift-num
                    .
            end.
            if tt-chk-doc.office = "" then tt-chk-doc.office = disp_ .
            else tt-chk-doc.office = tt-chk-doc.office + ", " + disp_ .
        end.
    end.
END.
define buffer buf_tt-rvs-line for tt-rvs-line .
define buffer bf_shift-param  for ub.shift-param .
find first ub.shift-param no-lock where ub.shift-param.obj-code = p-curr-obj-code and
    ub.shift-param.obj-type = p-curr-obj-type and
    ub.shift-param.shift-date = v-shift-date and
    ub.shift-param.shift-name = v-shift-name and
    ub.shift-param.shift-num = v-shift-num and
    ub.shift-param.gds-code = 0 and
    ub.shift-param.pl-code = 0 no-error .
if not available (ub.shift-param) then
do:
    find first ub.shift-param no-lock where ub.shift-param.obj-code = 0 and
        ub.shift-param.obj-type = "" and
        ub.shift-param.shift-date = 01/01/1900 no-error .
    if not available (ub.shift-param) then
    do:
        assign
            prc-dev-mass   = 0.65
            dev-paid-trans = 1
            .
    end.
    else
    do:
        assign
            prc-dev-mass   = ub.shift-param.prc-dev-mass
            dev-paid-trans = ub.shift-param.dev-paid-trans
            .
    end.
end.
else
    assign
        prc-dev-mass   = ub.shift-param.prc-dev-mass
        dev-paid-trans = ub.shift-param.dev-paid-trans
        .
for each ub.shift-param exclusive-lock where ub.shift-param.obj-code = p-curr-obj-code and
    ub.shift-param.obj-type = p-curr-obj-type and
    ub.shift-param.shift-date = v-shift-date and
    ub.shift-param.shift-name = v-shift-name and
    ub.shift-param.shift-num = v-shift-num and
    ub.shift-param.gds-code <> 0 and
    ub.shift-param.pl-code <> 0 :
    delete ub.shift-param .
end.
define variable v-com-tanks     as character no-undo .
define variable v-main-tanks    as character no-undo .
define variable v-num-com-tanks as integer   no-undo .
define buffer com_temp-rvs-line for tt-rvs-line .
define buffer com_t-9           for t-9 .
procedure placelib_write-attr:
define input  parameter p-code     like ub.place-attr.attr-code .
define input  parameter p-obj-code like ub.place-attr.obj-code .
define input  parameter p-obj-type like ub.place-attr.obj-type .
define input  parameter p-pl-code  like ub.place-attr.pl-code .
define input  parameter p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if not available buf_place-attr then do :
        create buf_place-attr.
        assign
          buf_place-attr.attr-code   = p-code
          buf_place-attr.attr-value  = p-value
          buf_place-attr.obj-code    = p-obj-code
          buf_place-attr.obj-type    = p-obj-type
          buf_place-attr.pl-code     = p-pl-code
        .
        p-ok = true.
     end.
     else do:
        buf_place-attr.attr-value  = p-value .
        p-ok = true.
     end.
  end.
end.
procedure placelib_get-attr:
define input  parameter  p-code     like ub.place-attr.attr-code .
define input  parameter  p-obj-code like ub.place-attr.obj-code .
define input  parameter  p-obj-type like ub.place-attr.obj-type .
define input  parameter  p-pl-code  like ub.place-attr.pl-code .
define output parameter  p-value    like ub.place-attr.attr-value .
define output parameter  p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr no-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
       p-value = buf_place-attr.attr-value.
       p-ok = true.
     end.
     else do :
       p-ok = false.
     end.
  end.
end.
procedure placelib_del-attr:
define input parameter  p-code     like ub.place-attr.attr-code .
define input parameter  p-obj-code like ub.place-attr.obj-code .
define input parameter  p-obj-type like ub.place-attr.obj-type .
define input parameter  p-pl-code  like ub.place-attr.pl-code .
define input parameter  p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
        delete buf_place-attr.
        p-ok = true.
     end.
  end.
end.
define temp-table with-action no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
field t_name as character
field num_ as integer
field uniq-key-rec as character
field action as integer
field fNotChange as logical
index pi is unique primary
num_
t_name
f_name
index
Chan
fnotChange
t_name
f_name
index imain uniq-key-rec
.
procedure c-place_get-attr :
  define input parameter attr-code as character no-undo .
  define input parameter obj-code as integer no-undo .
  define input parameter obj-type as character no-undo .
  define input parameter pl-code as integer no-undo .
  define input parameter endDate as date no-undo .
  define input parameter endTime as integer no-undo .
  define output parameter attr-value as character no-undo .
  define buffer bf_c-place-attr for ub.c-place-attr .
  define variable is-place-attr as logical no-undo .
  find last bf_c-place-attr no-lock where bf_c-place-attr.pl-code = pl-code and
    bf_c-place-attr.obj-code = obj-code and
    bf_c-place-attr.obj-type = obj-type and
    bf_c-place-attr.attr-code = attr-code and
    ((bf_c-place-attr.corr-date = endDate and
    bf_c-place-attr.corr-time < endTime) or
    bf_c-place-attr.corr-date < endDate) no-error .
  if available (bf_c-place-attr) then attr-value = bf_c-place-attr.attr-value .
  else attr-value = "true" .
end procedure.
FUNCTION get_max-qnty returns decimal (
  input obj-code as integer,
  input obj-type as character,
  input pl-code as integer,
  input endDate as date,
  input endTime as integer ):
  define buffer bf_c-place     for ub.c-place .
  define buffer buf_c-place    for ub.c-place .
  define buffer bf_place       for ub.place .
  define buffer curr_c-place   for c-place .
  define buffer buf_c-plc-hist for ub.c-plc-hist .
  define variable ii      as integer no-undo init 0.
  define variable is-max-qnty as logical no-undo .
  define variable is-true as logical no-undo .
  find last curr_c-place no-lock where curr_c-place.pl-code = pl-code and
    curr_c-place.obj-code = obj-code and
    curr_c-place.obj-type = obj-type and
    ((curr_c-place.corr-date = endDate and
    curr_c-place.corr-time < endTime) or
    curr_c-place.corr-date < endDate) no-error .
  if available (curr_c-place) then
  do:
    find first buf_c-plc-hist no-lock where
      buf_c-plc-hist.obj-type = obj-type
      AND buf_c-plc-hist.obj-code = obj-code
      AND buf_c-plc-hist.pl-code = pl-code
      AND buf_c-plc-hist.subject  = "place"
      and buf_c-plc-hist.chip-num = curr_c-place.chip-num no-error .
    if available (buf_c-plc-hist) then
    do:
      define variable v-label-param as character no-undo .
      v-label-param =
        "max-qnty" + chr(4) + "Максимальное количество" + chr(4) + "" .
      run proc-full-temp-changes in this-procedure (
        input buf_c-plc-hist.action = integer('1':U)
        ,input buf_c-plc-hist.action = integer('99':U)
        ,input  buffer curr_c-place:handle
        ,input  'place':U
        ,input  "max-qnty"
        ,input  v-label-param).
    end.
  end.
  for each with-action:
    return decimal(with-action.v_new) .
  end.
  if available (curr_c-place) then
  do:
    return curr_c-place.max-qnty .
  end.
  find first bf_place no-lock where bf_place.pl-code = pl-code and
    bf_place.obj-code = obj-code and
    bf_place.obj-type = obj-type no-error .
  return bf_place.max-qnty .
end function.
FUNCTION get_meas returns logical (
  input obj-code as integer,
  input obj-type as character,
  input pl-code as integer,
  input endDate as date,
  input endTime as integer ):
  define buffer bf_c-place     for ub.c-place .
  define buffer buf_c-place    for ub.c-place .
  define buffer bf_place       for ub.place .
  define buffer curr_c-place   for c-place .
  define buffer buf_c-plc-hist for ub.c-plc-hist .
  define variable ii      as integer no-undo init 0.
  define variable is-meas as logical no-undo .
  define variable is-true as logical no-undo .
  find last curr_c-place no-lock where curr_c-place.pl-code = pl-code and
    curr_c-place.obj-code = obj-code and
    curr_c-place.obj-type = obj-type and
    ((curr_c-place.corr-date = endDate and
    curr_c-place.corr-time < endTime) or
    curr_c-place.corr-date < endDate) no-error .
  if available (curr_c-place) then
  do:
    find first buf_c-plc-hist no-lock where
      buf_c-plc-hist.obj-type = obj-type
      AND buf_c-plc-hist.obj-code = obj-code
      AND buf_c-plc-hist.pl-code = pl-code
      AND buf_c-plc-hist.subject  = "place"
      and buf_c-plc-hist.chip-num = curr_c-place.chip-num no-error .
    if available (buf_c-plc-hist) then
    do:
      define variable v-label-param as character no-undo .
      v-label-param =
        "is-meas" + chr(4) + "Измеряется приборами" + chr(4) + "" .
      run proc-full-temp-changes in this-procedure (
        input buf_c-plc-hist.action = integer('1':U)
        ,input buf_c-plc-hist.action = integer('99':U)
        ,input  buffer curr_c-place:handle
        ,input  'place':U
        ,input  "is-meas"
        ,input  v-label-param).
    end.
  end.
  for each with-action:
    return logical (with-action.v_new) .
  end.
  find first bf_place no-lock where bf_place.pl-code = pl-code and
    bf_place.obj-code = obj-code and
    bf_place.obj-type = obj-type no-error .
  return bf_place.is-meas .
end function.
FUNCTION get_com-vessel returns logical (
  input obj-code as integer,
  input obj-type as character,
  input attr-code as character,
  input pl-code as integer,
  input openDate as date,
  input endDate as date,
  input openTime as integer,
  input endTime as integer ):
  define buffer current_c-place-attr for c-place-attr .
  define buffer buf_c-plc-hist       for ub.c-plc-hist .
  define variable ii      as integer   no-undo init 0.
  define variable is-meas as logical   no-undo .
  define variable is-true as logical   no-undo .
  define variable v-label as character no-undo .
  define variable p-ok    as logical   no-undo .
  find last current_c-place-attr no-lock where
    current_c-place-attr.obj-type = obj-type
    AND current_c-place-attr.obj-code = obj-code
    AND current_c-place-attr.pl-code = pl-code
    and current_c-place-attr.attr-code = attr-code
    and ((current_c-place-attr.corr-date = endDate
    and current_c-place-attr.corr-time < endTime) or
    current_c-place-attr.corr-date < endDate)
    no-error .
  if avail current_c-place-attr then
  do:
    find first buf_c-plc-hist no-lock where
      buf_c-plc-hist.obj-type = obj-type
      AND buf_c-plc-hist.obj-code = obj-code
      AND buf_c-plc-hist.pl-code = pl-code
      AND buf_c-plc-hist.subject  = "place-attr"
      and buf_c-plc-hist.chip-num = current_c-place-attr.chip-num no-error .
    if available (buf_c-plc-hist) then
    do:
      define variable v-label-param as character no-undo .
      if current_c-place-attr.attr-code = "place-SI"
        or current_c-place-attr.attr-code = "place-SI-temp"
        or current_c-place-attr.attr-code = "place-SI-dens"
        or current_c-place-attr.attr-code = "place-SI-level"
        then
      do :
        v-label-param =
          "attr-value" + chr(4) + "Значение атрибута" + chr(4) + "getSIname" + chr(8)
          + "attr-code" + chr(4) + "Код атрибута" + chr(4) + "getPlaceAttrCode"   .
      end .
      else
      do :
        v-label-param =
          "attr-value" + chr(4) + "Значение атрибута" + chr(4) + "getPlaceAttrValue" + chr(8)
          + "attr-code" + chr(4) + "Код атрибута" + chr(4) + "getPlaceAttrCode" + chr(8)
          + "PS" + chr(4) + "Примечание" + chr(4) + "" + chr(8)
          + "status_" + chr(4) + "Статус" + chr(4) + ""  .
      end .
      run proc-full-temp-changes in this-procedure (
        input buf_c-plc-hist.action = integer('1':U)
        ,input buf_c-plc-hist.action = integer('99':U)
        ,input  buffer current_c-place-attr:handle
        ,input  'place-attr':U
        ,input  "attr-code,attr-value,PS,status_"
        ,input  v-label-param).
    end.
  end.
  for each with-action:
    p-ok = logical (with-action.v_new) no-error .
    if error-status:error then p-ok = false .
    return   p-ok .
  end.
  return no .
end function.
FUNCTION get_com-tanks returns character (
  input obj-code as integer,
  input obj-type as character,
  input attr-code as character,
  input pl-code as integer,
  input openDate as date,
  input endDate as date,
  input openTime as integer,
  input endTime as integer ):
  define buffer current_c-place-attr for ub.c-place-attr .
    define buffer buf_c-plc-hist       for ub.c-plc-hist .
  define variable ii        as integer   no-undo init 0.
  define variable is-meas   as logical   no-undo .
  define variable is-true   as logical   no-undo .
  define variable v-label   as character no-undo .
  define variable p-ok as character no-undo .
  find last current_c-place-attr no-lock where
    current_c-place-attr.obj-type = obj-type
    AND current_c-place-attr.obj-code = obj-code
    AND current_c-place-attr.pl-code = pl-code
    and current_c-place-attr.attr-code = attr-code
    and ((current_c-place-attr.corr-date = endDate
    and current_c-place-attr.corr-time < endTime) or
    current_c-place-attr.corr-date < endDate)
    no-error .
  if avail current_c-place-attr then
  do:
    find first buf_c-plc-hist no-lock where
      buf_c-plc-hist.obj-type = obj-type
      AND buf_c-plc-hist.obj-code = obj-code
      AND buf_c-plc-hist.pl-code = pl-code
      AND buf_c-plc-hist.subject  = "place-attr"
      and buf_c-plc-hist.chip-num = current_c-place-attr.chip-num no-error .
    if available (buf_c-plc-hist) then
    do:
      define variable v-label-param as character no-undo .
      if current_c-place-attr.attr-code = "place-SI"
        or current_c-place-attr.attr-code = "place-SI-temp"
        or current_c-place-attr.attr-code = "place-SI-dens"
        or current_c-place-attr.attr-code = "place-SI-level"
        then
      do :
        v-label-param =
          "attr-value" + chr(4) + "Значение атрибута" + chr(4) + "getSIname" + chr(8)
          + "attr-code" + chr(4) + "Код атрибута" + chr(4) + "getPlaceAttrCode"   .
      end .
      else
      do :
        v-label-param =
          "attr-value" + chr(4) + "Значение атрибута" + chr(4) + "getPlaceAttrValue" + chr(8)
          + "attr-code" + chr(4) + "Код атрибута" + chr(4) + "getPlaceAttrCode" + chr(8)
          + "PS" + chr(4) + "Примечание" + chr(4) + "" + chr(8)
          + "status_" + chr(4) + "Статус" + chr(4) + ""  .
      end .
      run proc-full-temp-changes in this-procedure (
        input buf_c-plc-hist.action = integer('1':U)
        ,input buf_c-plc-hist.action = integer('99':U)
        ,input  buffer current_c-place-attr:handle
        ,input  'place-attr':U
        ,input  "attr-code,attr-value,PS,status_"
        ,input  v-label-param).
    end.
  end.
  for each with-action:
     p-ok = with-action.v_new no-error .
     if error-status:error then p-ok = "" .
    return   p-ok .
  end.
  return "" .
end function.
function getSIname returns character (si-code as char) :
  for first sr-izmerenia no-lock where sr-izmerenia.node-code = integer(si-code) :
    return sr-izmerenia.sr-model .
  end .
end .
function  getPlaceAttrCode returns character (istr as char ):
  define variable OStr as character no-undo.
  if istr eq "disable-level-alarm"
    then
    OStr = "Сообщения о переполнении".
  else if istr eq "disable-water-alarm"
      then
      OStr = "Сообщения по воде".
    else if istr eq "place-need-RVD-rvs"
        then
        OStr = "Необходимо сделать сверку с РВД".
      else if istr eq "place-SI-level"
          then
          OStr = "Доп. средство измерения уровня".
        else if istr eq "place-SI-dens"
            then
            OStr = "Доп. средство измерения плотности".
          else if istr eq "place-SI-temp"
              then
              OStr = "Доп. средство измерения температуры".
            else if istr eq "place-SI"
                then
                OStr = "Основное средство измерения".
              else
                OStr = istr.
  return OStr.
end.
function  getPlaceAttrValue returns character (istr as char ):
  define variable OStr  as character no-undo.
  define variable vFlag as logical   no-undo.
  if    entry(1,istr,chr(4)) eq "enable"
    then
    assign
      OStr  = "Включено"
      vFlag = yes
      .
  else if    entry(1,istr,chr(4)) eq "disable"
      then
      assign
        OStr  = "Выключено"
        vFlag = yes
        .
    else
      OStr = istr.
  if     vFlag
    and num-entries (istr,chr(4)) > 2
    then
    OStr = OStr + " для смены № " + entry(3,istr,chr(4)) + " Дата " + entry(2,istr,chr(4)).
  return OStr.
end.
PROCEDURE proc-full-temp-changes :
  define input  parameter p-act-create as logical   no-undo .
  define input  parameter p-act-delete as logical   no-undo .
  define input  parameter p-hst-handle as handle    no-undo .
  define input  parameter p-main-table as character no-undo .
  define input  parameter p-field-list as character no-undo .
  define input  parameter p-label-form as character no-undo .
  define variable h-new-buf         as handle    no-undo .
  define variable h-main-buf        as handle    no-undo .
  define variable h-for-comp        as handle    no-undo .
  define variable v-inform          as character no-undo .
  define variable v-ind             as integer   no-undo .
  define variable v-idx-field-qnty  as integer   no-undo .
  define variable v-num-entries     as integer   no-undo .
  define variable fh                as handle    no-undo .
  define variable fh-main           as handle    no-undo .
  define variable fh-old            as handle    no-undo .
  define variable fh-new            as handle    no-undo .
  define variable v-field-name      as character no-undo .
  define variable v-field-lvl       as character no-undo .
  define variable v-field-form      as character no-undo .
  define variable v-search-exp      as character no-undo .
  define variable v-srch-main       as character no-undo .
  define variable v-word-link       as character no-undo .
  define variable v-av-chip-num     as logical   no-undo .
  define variable v-main-pi-fld-lst as character no-undo .
  define variable v-main-fld-lst    as character no-undo .
  define variable v-delim-list      as character no-undo .
  define variable v-label           as character no-undo .
  define variable v-old-value       as character no-undo case-sensitive.
  define variable v-new-value       as character no-undo case-sensitive.
  define variable v-chg-fields      as character no-undo.
  for each with-action:
    delete with-action.
  end.
  if not p-hst-handle:available then
  do:
    return .
  end.
  create buffer h-new-buf  for table p-hst-handle .
  create buffer h-main-buf for table p-main-table .
  assign
    v-inform = h-main-buf:index-information(1)
    v-ind    = 2
    .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
    assign
      v-inform = h-main-buf:index-information( v-ind )
      v-ind    = v-ind + 1
      .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
    then
  do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, h-main-buf:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
    .
  if v-idx-field-qnty < 2 then
  do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, h-main-buf:name ).
  end.
  assign
    v-srch-main   = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
    v-delim-list  = "":U
    .
  do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
    assign
      v-field-name      = entry( 4 + v-ind, v-inform, ",":U )
      fh                = p-hst-handle:buffer-field( v-field-name )
      fh-main           = h-main-buf:buffer-field( v-field-name )
      v-srch-main       = substitute( "&1 &2 &3.&4 =", v-srch-main, v-word-link, fh-main:table, v-field-name )
      v-main-pi-fld-lst = v-main-pi-fld-lst + v-delim-list + v-field-name
      .
    if fh:data-type ="character":U then
    do:
      assign
        v-srch-main = substitute( '&1 "&2"', v-srch-main, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
        .
    end.
    else
    do:
      assign
        v-srch-main = substitute( "&1 &2", v-srch-main, fh:buffer-value() )
        .
    end.
    if v-delim-list = "":U then
    do:
      assign
        v-delim-list = ",":U
        .
    end.
    if v-word-link = "":U then
    do:
      assign
        v-word-link = "and":U
        .
    end.
  end.
  assign
    v-delim-list = "":U
    .
  do v-ind = 1 to h-main-buf:num-fields
    on error undo, return error
    :
    assign
      fh-main      = h-main-buf:buffer-field( v-ind )
      v-field-name = fh-main:name
      .
    assign
      v-main-fld-lst = v-main-fld-lst + v-delim-list + v-field-name
      .
    if v-delim-list = "":U then
    do:
      assign
        v-delim-list = ",":U
        .
    end.
  end.
  assign
    v-inform = p-hst-handle:index-information(1)
    v-ind    = 2
    .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
    assign
      v-inform = p-hst-handle:index-information( v-ind )
      v-ind    = v-ind + 1
      .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
    then
  do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, p-hst-handle:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
    .
  if v-idx-field-qnty < 2 then
  do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, p-hst-handle:name ).
  end.
  assign
    v-search-exp  = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
    .
  do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
    assign
      v-field-name = entry( 4 + v-ind, v-inform, ",":U )
      fh           = p-hst-handle:buffer-field( v-field-name )
      v-search-exp = substitute( "&1 &2 &3.&4", v-search-exp, v-word-link, fh:table, v-field-name )
      .
    if v-field-name = "chip-num":U then
    do:
      assign
        v-search-exp  = substitute( "&1 >", v-search-exp )
        v-av-chip-num = true
        .
    end.
    else
    do:
      assign
        v-search-exp = substitute( "&1 =", v-search-exp )
        .
    end.
    if fh:data-type ="character":U then
    do:
      assign
        v-search-exp = substitute( '&1 "&2"', v-search-exp, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
        .
    end.
    else
    do:
      assign
        v-search-exp = substitute( '&1 &2', v-search-exp, fh:buffer-value() )
        .
    end.
    if v-word-link = "":U then
    do:
      assign
        v-word-link = "and":U
        .
    end.
  end.
  if v-av-chip-num = false then
  do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Таблица &2 не содержит поля chip-num.", vss-workfile, p-hst-handle:name ) skip
      "Использование данной процедуры невозможно!" skip
      view-as alert-box error .
    return error .
  end.
  h-new-buf:find-first( v-search-exp, no-lock ) no-error .
  if not h-new-buf:available then
  do:
    h-main-buf:find-first( v-srch-main, no-lock ) no-error .
    if not h-main-buf:available then
    do:
      assign
        h-for-comp = ?
        .
    end.
    else
    do:
      assign
        h-for-comp = h-main-buf
        .
    end.
  end.
  else
  do:
    assign
      h-for-comp = h-new-buf
      .
  end.
  assign
    v-num-entries = num-entries( v-main-fld-lst, ",":U )
    .
  do v-ind = 1 to v-num-entries
    on error undo, return error return-value
    :
    assign
      v-field-name = entry( v-ind, v-main-fld-lst )
      fh-old       = p-hst-handle:buffer-field( v-field-name )
      v-old-value  = fh-old:buffer-value()
      v-label      = trim( fh-old:label )
      .
    if ( trim( p-field-list ) <> "":U
      and lookup( v-field-name, p-field-list ) > 0
      )
      or trim( p-field-list ) = "":U
      then
    do:
      if h-for-comp <> ? then
      do:
        assign
          fh-new      = h-for-comp:buffer-field( v-field-name )
          v-new-value = fh-new:buffer-value()
          .
      end.
      else
      do:
        assign
          v-new-value = "":U
          .
      end.
      if p-act-create = true then
      do:
        assign
          v-old-value = "":U
          .
      end.
      if p-act-delete = true then
      do:
        assign
          v-new-value = "":U
          .
      end.
      if v-old-value <> v-new-value
        then
      do:
        create with-action.
        assign
          with-action.t_name     = p-main-table
          with-action.f_name     = v-field-name
          with-action.l_name     = replace( v-label, "&":U, "":U )
          with-action.v_old      = trim( v-old-value )
          with-action.v_new      = trim( v-new-value )
          with-action.num_       = 0
          with-action.fNotChange = v-old-value eq v-new-value
          .
      end.
    end.
  end.
  assign
    v-num-entries = num-entries( p-label-form, chr(8) )
    .
  do v-ind = 1 to v-num-entries
    on error undo, return error return-value
    :
    if num-entries( entry( v-ind, p-label-form, chr(8) ), chr(4) ) = 3 then
    do:
      assign
        v-field-name = entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-lvl  = entry( 2, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-form = entry( 3, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        .
      find first with-action
        where with-action.f_name = v-field-name
        no-error .
      if available with-action then
      do:
        if trim( v-field-lvl ) <> "":U then
        do:
          assign
            with-action.l_name = v-field-lvl
            .
        end.
        if trim( v-field-form ) <> "":U then
        do:
          assign
            with-action.v_old = dynamic-function( v-field-form, with-action.v_old )
            .
          if h-for-comp <> ? then
          do:
            assign
              with-action.v_new = dynamic-function( v-field-form, with-action.v_new )
              .
          end.
        end.
      end.
    end.
    else
    do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка! Список должен содержать три поля с разделителем delim-par!" skip
        substitute( "список для поля '&1': '&2'"
        ,entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        ,entry( v-ind, p-label-form, chr(8) )
        ) skip
        substitute( "полный список: &2", p-label-form ) skip
        view-as alert-box error .
    end.
  end.
  delete object h-new-buf .
  delete object h-main-buf .
END PROCEDURE.
for first ub.shift-obj no-lock where ub.shift-obj.obj-code = p-curr-obj-code and
    ub.shift-obj.obj-type = p-curr-obj-type and ub.shift-obj.shift-date = v-shift-date and
    ub.shift-obj.shift-num = v-shift-num:
    for each buf_tt-rvs-line break by buf_tt-rvs-line.gds-code by buf_tt-rvs-line.pl-code:
        v-main-tanks = "" .
        v-com-tanks = "" .
        for each tt-rvs-line where tt-rvs-line.gds-code = buf_tt-rvs-line.gds-code:
            if get_com-vessel(p-curr-obj-code, p-curr-obj-type, "place-com-vessel", tt-rvs-line.pl-code, ub.shift-obj.open-date,
                close-date, ub.shift-obj.open-time, close-time) then
            do:
                v-com-tanks = get_com-tanks(p-curr-obj-code, p-curr-obj-type, "place-com-tanks", tt-rvs-line.pl-code,
                    ub.shift-obj.open-date, close-date, ub.shift-obj.open-time, close-time) .
                if v-com-tanks > "" then
                do:
                    v-main-tanks = trim(v-main-tanks,",") .
                    if lookup(v-main-tanks, v-com-tanks, ",") <> 0 then next .
                    if not get_com-vessel(p-curr-obj-code, p-curr-obj-type, "place-is-main", tt-rvs-line.pl-code, ub.shift-obj.open-date,
                        close-date, ub.shift-obj.open-time, close-time) then next .
                    else
                    do :
                        v-main-tanks = v-main-tanks + "," + tt-rvs-line.loc1 .
                        v-num-com-tanks = num-entries(v-com-tanks) + 1 .
                        do ii = 1 to num-entries(v-com-tanks) :
                            find first buf_place no-lock where buf_place.obj-type = p-curr-obj-type
                                and buf_place.obj-code = p-curr-obj-code
                                and buf_place.loc1 = entry(ii, v-com-tanks)
                                and buf_place.status_ = ""
                                no-error .
                            if not available buf_place
                                then
                            do :
                                undo, return error ("Не найден сообщающийся резервуар " + entry(ii, v-com-tanks)) .
                            end .
                            find first com_temp-rvs-line where com_temp-rvs-line.gds-code = tt-rvs-line.gds-code
                                and com_temp-rvs-line.pl-code  = buf_place.pl-code
                                no-error .
                            if not available com_temp-rvs-line
                                then
                            do :
                            end .
                            else
                            do :
                                tt-rvs-line.tech-refuell = tt-rvs-line.tech-refuell + com_temp-rvs-line.tech-refuell .
                                tt-rvs-line.rast-stock-end = tt-rvs-line.rast-stock-end + com_temp-rvs-line.rast-stock-end .
                                tt-rvs-line.fact-stock-end = tt-rvs-line.fact-stock-end + com_temp-rvs-line.fact-stock-end .
                                tt-rvs-line.fact-stock-start = tt-rvs-line.fact-stock-start + com_temp-rvs-line.fact-stock-start .
                                tt-rvs-line.income = tt-rvs-line.income + com_temp-rvs-line.income .
                                tt-rvs-line.sale-kg = tt-rvs-line.sale-kg + com_temp-rvs-line.sale-kg .
                                tt-rvs-line.rast-stock-end = tt-rvs-line.fact-stock-start + tt-rvs-line.income - tt-rvs-line.sale-kg - tt-rvs-line.tech-refuell .
                                tt-rvs-line.loc1 = tt-rvs-line.loc1 + "," + v-com-tanks .
                                delete com_temp-rvs-line .
                            end .
                        end.
                    end.
                end.
            end.
        end.
    end.
    for each buf_t-9 break by buf_t-9.gds-code by buf_t-9.pl-code:
        v-main-tanks = "" .
        v-com-tanks = "" .
        for each t-9 where t-9.gds-code = buf_t-9.gds-code:
            if get_com-vessel(p-curr-obj-code, p-curr-obj-type, "place-com-vessel", t-9.pl-code, ub.shift-obj.open-date,
                ub.shift-obj.close-date, ub.shift-obj.open-time, ub.shift-obj.close-time) then
            do:
                v-com-tanks = get_com-tanks(p-curr-obj-code, p-curr-obj-type, "place-com-tanks", t-9.pl-code,
                    ub.shift-obj.open-date, ub.shift-obj.close-date, ub.shift-obj.open-time, ub.shift-obj.close-time) .
                if v-com-tanks > "" then
                do:
                    v-main-tanks = trim(v-main-tanks,",") .
                    if lookup(v-main-tanks, v-com-tanks, ",") <> 0 then next .
                    if not get_com-vessel(p-curr-obj-code, p-curr-obj-type, "place-is-main", t-9.pl-code, ub.shift-obj.open-date,
                        ub.shift-obj.close-date, ub.shift-obj.open-time, ub.shift-obj.close-time) then next .
                    else
                    do :
                        v-main-tanks = v-main-tanks + "," + t-9.loc1 .
                        v-num-com-tanks = num-entries(v-com-tanks) + 1 .
                        do ii = 1 to num-entries(v-com-tanks) :
                            find first buf_place no-lock where buf_place.obj-type = p-curr-obj-type
                                and buf_place.obj-code = p-curr-obj-code
                                and buf_place.loc1 = entry(ii, v-com-tanks)
                                and buf_place.status_ = ""
                                no-error .
                            if not available buf_place
                                then
                            do :
                                undo, return error ("Не найден сообщающийся резервуар " + entry(ii, v-com-tanks)) .
                            end .
                            find first com_t-9 where com_t-9.gds-code = t-9.gds-code
                                and com_t-9.pl-code  = buf_place.pl-code
                                no-error .
                            if not available com_t-9
                                then
                            do :
                            end .
                            else
                            do :
                                t-9.delta = t-9.delta + com_t-9.delta .
                                t-9.meas-qnty = t-9.meas-qnty + com_t-9.meas-qnty .
                                t-9.sale-kg = t-9.sale-kg + com_t-9.sale-kg .
                                t-9.loc1 = t-9.loc1 + "," + v-com-tanks .
                                delete com_t-9 .
                            end .
                        end.
                    end.
                end.
            end.
        end.
    end.
end.
for each buf_tt-rvs-line no-lock:
    find first buf_shift-param exclusive-lock where buf_shift-param.gds-code = buf_tt-rvs-line.gds-code and
        buf_shift-param.pl-code = buf_tt-rvs-line.pl-code and
        buf_shift-param.obj-code = p-curr-obj-code and
        buf_shift-param.obj-type = p-curr-obj-type and
        buf_shift-param.shift-date = v-shift-date and
        buf_shift-param.shift-name = v-shift-name and
        buf_shift-param.shift-num = v-shift-num no-error .
    if not available (buf_shift-param) then
    do:
        create buf_shift-param .
        assign
            buf_shift-param.gds-code       = buf_tt-rvs-line.gds-code
            buf_shift-param.pl-code        = buf_tt-rvs-line.pl-code
            buf_shift-param.obj-code       = p-curr-obj-code
            buf_shift-param.obj-type       = p-curr-obj-type
            buf_shift-param.shift-date     = v-shift-date
            buf_shift-param.shift-name     = v-shift-name
            buf_shift-param.shift-num      = v-shift-num
            buf_shift-param.diff-cash-trk  = 0
            buf_shift-param.diff-stock-end = 0
            .
        buf_shift-param.loc1 = buf_tt-rvs-line.loc1 .
    end.
    buf_tt-rvs-line.rast-stock-end = buf_tt-rvs-line.fact-stock-start + buf_tt-rvs-line.income - buf_tt-rvs-line.sale-kg - buf_tt-rvs-line.tech-refuell .
    assign
        buf_shift-param.tech-refuell    = buf_tt-rvs-line.tech-refuell
        buf_shift-param.prc-dev-mass    = prc-dev-mass
        buf_shift-param.dev-paid-trans  = dev-paid-trans
        buf_shift-param.diff-stock-end  = absolut(buf_tt-rvs-line.rast-stock-end - buf_tt-rvs-line.fact-stock-end)
        buf_shift-param.dev-mass        = buf_tt-rvs-line.fact-stock-end * buf_shift-param.prc-dev-mass / 100
        buf_shift-param.system-cli-qnty = buf_tt-rvs-line.rast-stock-end
        buf_shift-param.fact-stock-end  = buf_tt-rvs-line.fact-stock-end
        buf_shift-param.disc-diffMass   = ""
        .
end.
for each buf_t-9:
    find first buf_shift-param exclusive-lock where buf_shift-param.gds-code = buf_t-9.gds-code and
        buf_shift-param.pl-code = buf_t-9.pl-code and
        buf_shift-param.obj-code = p-curr-obj-code and
        buf_shift-param.obj-type = p-curr-obj-type and
        buf_shift-param.shift-date = v-shift-date and
        buf_shift-param.shift-name = v-shift-name and
        buf_shift-param.shift-num = v-shift-num no-error .
    if not available (buf_shift-param) then
    do:
        create buf_shift-param .
        assign
            buf_shift-param.gds-code       = buf_t-9.gds-code
            buf_shift-param.pl-code        = buf_t-9.pl-code
            buf_shift-param.obj-code       = p-curr-obj-code
            buf_shift-param.obj-type       = p-curr-obj-type
            buf_shift-param.shift-date     = v-shift-date
            buf_shift-param.shift-name     = v-shift-name
            buf_shift-param.shift-num      = v-shift-num
            buf_shift-param.diff-cash-trk  = 0
            buf_shift-param.diff-stock-end = 0
            .
        buf_shift-param.loc1 = buf_t-9.loc1 .
    end.
    buf_shift-param.disc-diffTRK = "" .
    buf_shift-param.diff-cash-trk = buf_shift-param.diff-cash-trk + absolut(buf_t-9.delta - buf_t-9.tech-refuell-qnty) .
    buf_shift-param.meas-qnty = buf_shift-param.meas-qnty + buf_t-9.meas-qnty.
    buf_shift-param.cash-qnty = buf_shift-param.cash-qnty + buf_t-9.sale-kg.
end.
assign
    errorCheck = false
    errorMass  = false
    errorTRK   = false
    .
for each bf_susp-chk exclusive-lock where bf_susp-chk.shift-date = v-shift-date and
    bf_susp-chk.shift-num = v-shift-num and
    bf_susp-chk.shift-name = v-shift-name and
    bf_susp-chk.obj-code = p-curr-obj-code and
    bf_susp-chk.obj-type = p-curr-obj-type:
    find first tt-chk-doc where tt-chk-doc.doc-code = bf_susp-chk.doc-code no-lock no-error .
    if not available (tt-chk-doc) then delete bf_susp-chk .
end.
for each tt-chk-doc:
    errorCheck = true .
    find first bf_susp-chk exclusive-lock where bf_susp-chk.doc-code = tt-chk-doc.doc-code no-error .
    if not available (bf_susp-chk) then
    do:
        create bf_susp-chk .
        buffer-copy tt-chk-doc to bf_susp-chk .
    end.
    bf_susp-chk.chk-time = tt-chk-doc.chk-time .
end.
for each ub.shift-param no-lock where ub.shift-param.obj-code = p-curr-obj-code and
    ub.shift-param.obj-type = p-curr-obj-type and
    ub.shift-param.shift-date = v-shift-date and
    ub.shift-param.shift-num = v-shift-num and
    ub.shift-param.shift-name = v-shift-name and
    ub.shift-param.gds-code > 0:
    for first buf_shift-param exclusive-lock where buf_shift-param.obj-code = ub.shift-param.obj-code and
        buf_shift-param.obj-type = ub.shift-param.obj-type and
        buf_shift-param.shift-date = ub.shift-param.shift-date and
        buf_shift-param.shift-name = ub.shift-param.shift-name and
        buf_shift-param.shift-num = ub.shift-param.shift-num and
        buf_shift-param.gds-code = ub.shift-param.gds-code and
        buf_shift-param.pl-code = ub.shift-param.pl-code:
        if absolute(buf_shift-param.diff-stock-end) > buf_shift-param.dev-mass then
            assign
                buf_shift-param.error-mass = true
                errorMass                  = true .
            .
        if absolute(buf_shift-param.diff-cash-trk) > buf_shift-param.dev-paid-trans then
            assign
                buf_shift-param.error-paid-trans = true
                errorTRK                         = true .
    end.
end.
if errorCheck or errorMass or errorTRK then
do:
    define variable v-text-button as character no-undo .
    if errorMass then v-text-button = v-text-button + '|' + "errorMass" .
    if errorTRK then v-text-button = v-text-button + '|' + "errorTRK" .
    if errorCheck then v-text-button = v-text-button + '|' + "errorCheck" .
    v-text-button = trim(v-text-button,'|') .
    run gbl/d-askwShiftClose.w
        (input parparentproc
        ,input "Закрытие смены"
        ,input "При закрытии смены выявлены ошибки"
        ,input "|^"
        ,input string(errorMass) + '|' + string(errorTRK) + '|' + string(errorCheck)
        ,input "Просмотр|Просмотр|Просмотр"
        ,input "Превышено допустимое отклонение по 1 части сменного отчета|"
        + "Превышено допустимое отклонение по 9 части сменного отчета|"
        + 'Найдены «подозрительные» чеки'
        ,input 4
        ,input 5
        ,input v-text-button
        ,input  p-curr-obj-type
        ,input  p-curr-obj-code
        ,input  v-shift-date
        ,input  v-shift-num
        ,input  v-shift-name
        ,output v-num
        ) no-error.
    if error-status:error then
    do:
        message return-value
            view-as alert-box.
    end.
    case v-num:
        when "closeWith" then
            do:
                if errorMass then
                do:
                    run str/diffShiftClose.w (
                        input parparentproc,
                        input 'ИЗМЕНЕНИЕ':U,
                        input p-curr-obj-type,
                        input p-curr-obj-code,
                        input v-shift-date,
                        input v-shift-num,
                        input v-shift-name,
                        input "diff-mass",
                        output v-ok)  no-error .
                    if not v-ok then
                    do:
                        return error .
                    end.
                end.
                if errorTRK then
                do:
                    run str/diffShiftClose.w (
                        input parparentproc,
                        input 'ИЗМЕНЕНИЕ':U,
                        input p-curr-obj-type,
                        input p-curr-obj-code,
                        input v-shift-date,
                        input v-shift-num,
                        input v-shift-name,
                        input "diff-TRK",
                        output v-ok)  no-error .
                    if not v-ok then
                    do:
                        return error .
                    end.
                end.
                run str/susp-chk.w (
                    input parparentproc,
                    input 'ИЗМЕНЕНИЕ':U,
                    input p-curr-obj-type,
                    input p-curr-obj-code,
                    input v-shift-date,
                    input v-shift-num,
                    input v-shift-name,
                    output table tt-susp-chk,
                    output v-ok) no-error .
                if not v-ok then
                do:
                    return error.
                end.
            end.
        when "cancel" then
            do:
                for each buf_shift-param exclusive-lock where buf_shift-param.obj-code = p-curr-obj-code and
                    buf_shift-param.obj-type = p-curr-obj-type and
                    buf_shift-param.shift-date = v-shift-date and
                    buf_shift-param.shift-num = v-shift-num:
                    delete buf_shift-param .
                end.
                return error .
            end.
    end case .
end.
procedure get-state-mh-cnt-from-icnt-doc :
    define input parameter p-obj-type as character no-undo .
    define input parameter p-obj-code as integer no-undo .
    define input parameter p-from-shift-date as date no-undo.
    define input parameter p-from-shift-num as integer no-undo.
    define input parameter p-fact-order as decimal no-undo.
    define input parameter p-gds-code as integer no-undo .
    define input parameter p-pl-code as integer no-undo .
    define input parameter p-pump-code as integer no-undo .
    define input parameter p-nozzle-code as integer no-undo .
    define input-output parameter p-state-mh-cnt as decimal no-undo .
    define input-output parameter p-state-el-cnt as decimal no-undo .
    define buffer buf_icnt-doc  for ub.icnt-doc.
    define buffer buf_icnt-line for ub.icnt-line.
    for each buf_icnt-doc no-lock
        where buf_icnt-doc.obj-type = p-obj-type
        and buf_icnt-doc.obj-code = p-obj-code
        and buf_icnt-doc.status_ = 'факт':U
        and buf_icnt-doc.fact-order < p-fact-order
        by buf_icnt-doc.fact-order
        descending
        on error undo, return error return-value
        :
        for each buf_icnt-line no-lock where
            buf_icnt-line.doc-code = buf_icnt-doc.doc-code
            and buf_icnt-line.obj-code = buf_icnt-doc.obj-code
            and buf_icnt-line.obj-type = buf_icnt-doc.obj-type
            and buf_icnt-line.gds-code = p-gds-code
            and buf_icnt-line.pl-code = p-pl-code
            and buf_icnt-line.pump-code = p-pump-code
            and buf_icnt-line.nozzle-code = p-nozzle-code:
            assign
                p-state-mh-cnt = p-state-mh-cnt + buf_icnt-line.state-mh-cnt.
            p-state-el-cnt = p-state-el-cnt + buf_icnt-line.state-el-cnt.
            leave.
        end.
    end.
end procedure.
find first ub.shift-param exclusive-lock where ub.shift-param.obj-code = p-curr-obj-code and
    ub.shift-param.obj-type = p-curr-obj-type and
    ub.shift-param.shift-date = v-shift-date and
    ub.shift-param.shift-name = v-shift-name and
    ub.shift-param.shift-num = v-shift-num and
    ub.shift-param.gds-code = 0 and
    ub.shift-param.pl-code = 0 no-error .
if not available (ub.shift-param) then
do:
    create ub.shift-param .
    assign
        ub.shift-param.obj-code   = p-curr-obj-code
        ub.shift-param.obj-type   = p-curr-obj-type
        ub.shift-param.shift-date = v-shift-date
        ub.shift-param.shift-name = v-shift-name
        ub.shift-param.shift-num  = v-shift-num .
end.
assign
    ub.shift-param.prc-dev-mass   = prc-dev-mass
    ub.shift-param.dev-paid-trans = dev-paid-trans
    .
find first buf_shift-obj
    where buf_shift-obj.obj-type = p-curr-obj-type
    and buf_shift-obj.obj-code = p-curr-obj-code
    and buf_shift-obj.status_ = 'тек':U
    use-index pi
    no-error.
    if not g#news then
    do:
        run str/diallog.w ( input parparentproc
            , input this-procedure
            , input ('local-rum':U + chr(4) +
            "1" + chr(4) +
            "1" + chr(4) +
            "1" + chr(4) +
            "1" + chr(4) +
            "yes")
            , input string(1)
            , input p-silent
            , input ''
            , input 'Операции, выполняемые перед закрытием смены') no-error .
    end.
    if v-rum-err then
    do:
        undo stop-shift, return error .
    end.
    for each buf_pl-gds
        where buf_pl-gds.obj-type = p-curr-obj-type
        and buf_pl-gds.obj-code = p-curr-obj-code
        on error undo stop-shift, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
        :
        run trg/lockplgd.p
            ( input p-curr-obj-type
            ,input p-curr-obj-code
            ,input buf_pl-gds.pl-code
            ,input buf_pl-gds.gds-code
            ,input "assign-rvs-on=true":U
            ,input "":U
            ,input true
            ) no-error.
        if error-status:error then
        do:
            assign
                v-err-msg = substitute( "&1.&2&3&2&4&2"
                                , vss-workfile
                                , chr(10)
                                , return-value
                                , error-status :get-message (1)
                              ).
            if p-silent <> true then
            do:
                message
                    v-err-msg
                    view-as alert-box error.
            end.
            undo, return error v-err-msg .
        end.
    end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  buf_shift-obj.obj-type
  ,input  buf_shift-obj.obj-code
  ,output v-obj-date
  )  .
    assign
        buf_shift-obj.status_    = 'зкр':U
        buf_shift-obj.close-date = v-obj-date
        .
    if p-silent <> true then
    do:
        if s-time > 86400 then
        do:
            assign
                s-time = s-time - 86400.
        end.
        assign
            buf_shift-obj.close-time = s-time
            .
    end.
    else
    do:
        if buf_shift-obj.close-time = 0 then
        do:
            assign
                v-err-msg = substitute( "Не задано время закрытия смены.&1"
                                , chr(10)
                              ) .
            if p-silent <> true then
            do:
                message
                    v-err-msg
                    view-as alert-box.
            end.
            undo, return error v-err-msg .
        end.
    end.
    for each buf_pl-gds
        where buf_pl-gds.obj-type = p-curr-obj-type
        and buf_pl-gds.obj-code = p-curr-obj-code
        on error undo stop-shift, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
        :
        run trg/lockplgd.p
            ( input p-curr-obj-type
            ,input p-curr-obj-code
            ,input buf_pl-gds.pl-code
            ,input buf_pl-gds.gds-code
            ,input "assign-rvs-on=false":U
            ,input "":U
            ,input true
            ) no-error.
        if error-status:error then
        do:
            assign
                v-err-msg = substitute( "&1.&2&3&2&4&2"
                                , vss-workfile
                                , chr(10)
                                , return-value
                                , error-status :get-message (1)
                              ).
            if p-silent <> true then
            do:
                message
                    v-err-msg
                    view-as alert-box error.
            end.
            undo, return error v-err-msg .
        end.
    end.
    release buf_shift-obj no-error.
    if error-status:error then
    do:
        if not p-silent then
        do:
            undo stop-shift, return error.
        end.
        else
        do:
            undo stop-shift, return error substitute("Ошибка при закрытии смены: &1&2 От &3 П. &4&5&6&5&7"
                , p-curr-obj-type
                , p-curr-obj-code
                , s-date
                , s-num
                , chr(10)
                , error-status:get-message(1)
                , return-value ).
        end.
    end.
end.
run str/calc-shift-period.p (input parparentproc,
    input p-curr-obj-type,
    input p-curr-obj-code,
    input v-shift-date,
    input v-shift-num)
    no-error .
if error-status:error then
do:
    assign
        v-err-msg = substitute( "&1.&2&3&2&4&2"
                            , vss-workfile
                            , chr(10)
                            , return-value
                            , error-status :get-message (1)
                          ).
    if p-silent <> true then
    do:
        message
            v-err-msg
            view-as alert-box error.
    end.
end.
run str/prep1C-shift-period.p (input parparentproc,
    input p-curr-obj-type,
    input p-curr-obj-code,
    input v-shift-date,
    input v-shift-num)
    no-error .
if error-status:error then
do:
    assign
        v-err-msg = substitute( "&1.&2&3&2&4&2"
                            , vss-workfile
                            , chr(10)
                            , return-value
                            , error-status :get-message (1)
                          ).
    if p-silent <> true then
    do:
        message
            v-err-msg
            view-as alert-box error.
    end.
end.
find first cur_rvs-doc no-lock
    where cur_rvs-doc.obj-type   = p-curr-obj-type
    and cur_rvs-doc.obj-code   = p-curr-obj-code
    and cur_rvs-doc.shift-date = v-shift-date
    and cur_rvs-doc.shift-num  = v-shift-num
    and cur_rvs-doc.status_    = 'факт':U
    and cur_rvs-doc.rvs-type   = 'смена':U
    no-error.
find last prev_shift-obj no-lock
    where prev_shift-obj.obj-type = p-curr-obj-type
    and prev_shift-obj.obj-code = p-curr-obj-code
    and prev_shift-obj.status_  = 'зкр':U
    and ( prev_shift-obj.shift-date < v-shift-date
    or prev_shift-obj.shift-date = v-shift-date
    and prev_shift-obj.shift-num  < v-shift-num
    )
    use-index stts
    no-error.
if available prev_shift-obj
    then
do :
    find first prev_rvs-doc no-lock
        where prev_rvs-doc.obj-type   = prev_shift-obj.obj-type
        and prev_rvs-doc.obj-code   = prev_shift-obj.obj-code
        and prev_rvs-doc.shift-date = prev_shift-obj.shift-date
        and prev_rvs-doc.shift-num  = prev_shift-obj.shift-num
        and prev_rvs-doc.status_    = 'факт':U
        and prev_rvs-doc.rvs-type   = 'смена':U
        no-error.
end .
if available cur_rvs-doc
    and available prev_rvs-doc
    then
do :
    for each cur_rvs-line no-lock where cur_rvs-line.rvs-code = cur_rvs-doc.rvs-code
        and cur_rvs-line.obj-type = cur_rvs-doc.obj-type
        and cur_rvs-line.obj-code = cur_rvs-doc.obj-code,
        first buf_place no-lock where buf_place.pl-code = cur_rvs-line.pl-code
        :
        find first prev_rvs-line no-lock where prev_rvs-line.rvs-code = prev_rvs-doc.rvs-code
            and prev_rvs-line.obj-type = prev_rvs-doc.obj-type
            and prev_rvs-line.obj-code = prev_rvs-doc.obj-code
            and prev_rvs-line.pl-code  = cur_rvs-line.pl-code
            no-error .
        if not available prev_rvs-line
            or (available prev_rvs-line and prev_rvs-line.gds-code <> cur_rvs-line.gds-code)
            then
        do :
            place-list = place-list + string(recid(buf_place)) + "," .
        end .
    end .
    place-list = trim(place-list, ",") .
    if place-list > ""
        then
    do :
        run utl/init-shift-period.p (input place-list) .
    end .
end .
for each buf_place-attr exclusive-lock where buf_place-attr.obj-type = p-curr-obj-type
    and buf_place-attr.obj-code = p-curr-obj-code
    and buf_place-attr.attr-code = "pending-table-version"
    :
    do ii = 1 to num-entries(buf_place-attr.attr-value) :
        find first buf_place-imp no-lock where buf_place-imp.obj-type = buf_place-attr.obj-type
            and buf_place-imp.obj-code = buf_place-attr.obj-code
            and buf_place-imp.pl-code  = buf_place-attr.pl-code
            and buf_place-imp.table-version = integer(entry(ii, buf_place-attr.attr-value))
            no-error .
        if available buf_place-imp
            and buf_place-imp.status_ = 0
            then
        do :
            run str/apply_place-imp.p (input buf_place-imp.obj-type,
                input buf_place-imp.obj-code,
                input buf_place-imp.pl-code,
                input buf_place-imp.table-version)
                no-error .
            if error-status:error
                then
            do :
                assign
                    v-err-msg = substitute( "&1.&2&3&2&4&2"
                                  , vss-workfile
                                  , chr(10)
                                  , return-value
                                  , "Ошибка при применении новых параметров резервуара "
                                ).
                if p-silent <> true then
                do:
                    message
                        v-err-msg
                        view-as alert-box error.
                end.
            end .
        end .
    end .
    delete buf_place-attr .
end .
if p-silent <> true then
do:
    run mainmenu-disp-mutable in parparentproc (
        output v-cur-date-error-code
        ).
    message
        "Текущая смена закрыта."
        view-as alert-box information.
end.
run str/diallog.w ( input parparentproc
    , input this-procedure
    , input ('local-rum':U + chr(4) +
    "1" + chr(4) +
    "0" + chr(4) +
    "1" + chr(4) +
    "1" + chr(4) +
    "yes")
    , input string(2)
    , input p-silent
    , input ''
    , input 'Операции, выполняемые после закрытия смены') no-error .
define variable v-base-code like ub.sysconf.base-code no-undo .
define buffer buf_currency for ub.currency.
define variable v_dataseth  as handle    no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output v-base-code
  )  .
find first buf_currency no-lock
    where buf_currency.curr-code = v-base-code
    .
run str/reportSend.p (
    input parparentproc,
    input v-cntxt-userid,
    input v-shift-date,
    input v-shift-num,
    input v-shift-name,
    input p-curr-obj-code,
    input p-curr-obj-type) .
return .
procedure  local-rum:
    define input parameter parparentproc as widget-handle no-undo .
    define input parameter p-parent-handle  as widget-handle no-undo .
    define input parameter p-log-handle  as handle no-undo .
    define input parameter p-parameter   as character no-undo .
    define variable v-uniq-key-rec       as character no-undo .
    define variable v-shift-uniq-key-rec as character no-undo .
    define variable v-list               as character no-undo extent 2.
    define variable v-thobj-type-list    as character no-undo extent 2.
    define variable v-entry0             as character no-undo .
    define variable v-entry              as character no-undo .
    define variable v-thobj-type0        as character no-undo .
    define variable v-thobj-type         as character no-undo .
    define variable v-obj-type           as character no-undo .
    define variable v-obj-code           as integer   no-undo .
    define variable v-upper-code         as character no-undo .
    define variable v-ii                 as integer   no-undo .
    define variable v-jj                 as integer   no-undo .
    define variable v-step               as integer   no-undo .
    define buffer buf_thbj-attr for ub.thbj-attr.
    assign
        v-list[1]            = 'fdoc':U
        v-list[2]            = 'rep':U + chr(44) + 'rep':U
        v-thobj-type-list[1] = "global"
        v-thobj-type-list[2] = 'объект':U + chr(44) + "global"
        .
    main-block:
    do
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
        v-step = integer(p-parameter).
        run gen-key-rec in this-procedure (
            input  'shift-obj':U
            ,input (buffer buf_shift-obj:handle)
            ,output v-shift-uniq-key-rec).
        _v-ii:
        do v-ii = 1 to num-entries(v-list[v-step], chr(4) ):
            v-entry0  = entry(v-ii, v-list[v-step], chr(4)).
            v-thobj-type0 = entry(v-ii, v-thobj-type-list[v-step], chr(4)).
            _v-jj:
            do v-jj = 1 to num-entries(v-entry0):
                assign
                    v-entry      = entry(v-jj, v-entry0)
                    v-thobj-type = entry(v-jj, v-thobj-type0).
                .
                case v-thobj-type:
                    when "global" then
                        do:
                            v-obj-type = ''.
                            v-obj-code = 0.
                            v-upper-code = 'rum':U.
                        end.
                    when 'объект':U then
                        do:
                            v-obj-type = buf_shift-obj.obj-type.
                            v-obj-code = buf_shift-obj.obj-code.
                            v-upper-code = 'rum_obj':U.
                        end.
                end case.
                find first buf_thbj-attr no-lock where
                    buf_thbj-attr.upper-prop-code = v-upper-code
                    and buf_thbj-attr.prop-code = v-entry
                    and buf_thbj-attr.obj-type = v-obj-type
                    and buf_thbj-attr.obj-code = v-obj-code
                    and buf_thbj-attr.property-value-logical = yes
                    no-error.
                if not available buf_thbj-attr then
                do:
                    next _v-jj.
                end.
                else
                do:
                    leave _v-jj.
                end.
            end.
            if available buf_thbj-attr
                then
            do:
                run gen-key-rec in this-procedure (
                    input  'thbj-attr':U
                    ,input (buffer buf_thbj-attr:handle)
                    ,output v-uniq-key-rec).
                case v-entry:
                    when 'fdoc':U then
                        do:
                            run str/fdocrum.p
                                (
                                input parparentproc
                                ,input p-parent-handle
                                ,input p-log-handle
                                ,input 'work_fin-doc':U
                                ,input 0
                                ,input 24
                                ,input 1
                                ,input g#db-num
                                ,input v-uniq-key-rec
                                ,input v-shift-uniq-key-rec
                                ,input yes
                                ) no-error .
                        end.
                    when 'rep':U then
                        do:
                            run rep/reprum.p
                                (
                                input parparentproc
                                ,input p-parent-handle
                                ,input p-log-handle
                                ,input 'close-shift':U
                                ,input 0
                                ,input 22
                                ,input 5
                                ,input 0
                                ,input g#db-num
                                ,input v-uniq-key-rec
                                ,input v-shift-uniq-key-rec + chr(4) + ""
                                ,input yes
                                ) no-error .
                        end.
                end case.
                if error-status:error then
                do:
                    assign
                        v-rum-err = yes.
                    undo main-block, return error .
                end.
            end.
        end.
    end.
end procedure.
