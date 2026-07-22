block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-imp-handle as handle    no-undo .
define input parameter p-uniq-key-rec as character no-undo .
define input parameter p-counter  as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Обработка команды отсылки настроек машины правил (для объекта TH)".
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
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function octal-to-char return character
( p-string as character ) :
  def var v-asc     as integer no-undo .
  def var v-new-asc as integer no-undo .
  def var ind       as integer no-undo .
  if length(p-string) <> 3 then do:
    return ? .
  end.
  assign
    v-asc = 0
  .
  do ind = 1 to length(p-string)
  :
    assign
      v-new-asc = asc(substring(p-string, ind, 1)) - asc('0')
    .
    if v-new-asc < 0 or v-new-asc >= 8 then do:
      return ? .
    end.
    assign
      v-asc = v-asc * 8 + v-new-asc
    .
  end.
  return chr(v-asc) .
end function .
function char-to-octal return character
( p-chr as character ) :
  def var v-asc    as integer   no-undo .
  def var ind      as integer   no-undo .
  def var v-string as character no-undo .
  if length(p-chr) <> 1 then do:
    return ? .
  end.
  assign
    v-asc    = asc(p-chr)
    v-string = ""
  .
  do ind = 1 to 3
  :
    assign
      v-string = chr( v-asc mod 8 + asc('0')) + v-string
    .
    assign
      v-asc = truncate(v-asc / 8, 0)
    .
  end.
  return v-string .
end.
function str-encode return character
(   p-init-string       as character
  , p-encode-char       as character
  , p-special-char-list as character
) :
  def var p-encode-string as character no-undo .
  def var ind                as integer no-undo .
  def var v-num-special-char as integer no-undo .
  def var v-special-char     as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = ? then do:
    return "?" .
  end.
  if p-init-string = "?" then do:
    return p-encode-char + char-to-octal("?") .
  end.
  assign
    v-num-special-char = length(p-special-char-list)
    p-encode-string    = replace(p-init-string
                                ,p-encode-char
                                ,p-encode-char + char-to-octal(p-encode-char)
                                )
  .
  do ind = 1 to v-num-special-char
  :
    assign
      v-special-char = substring(p-special-char-list, ind, 1)
    .
    if v-special-char <> p-encode-char then do:
      assign
        p-encode-string = replace (p-encode-string
                                  ,v-special-char
                                  ,p-encode-char + char-to-octal(v-special-char)
                                  )
      .
    end.
  end.
  return p-encode-string .
end.
function str-decode returns character
  (p-init-string   as character
  ,p-encode-char   as character
  ) :
  def var p-decode-string as character no-undo .
  def var ind                       as integer no-undo .
  def var v-num-entries-init-string as integer no-undo .
  def var v-sub-phrase              as character no-undo .
  def var v-special-char            as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = "?" then do:
    return ? .
  end.
  assign
    v-num-entries-init-string = num-entries(p-init-string, p-encode-char)
  .
  if v-num-entries-init-string > 1 then do:
    assign
      p-decode-string = entry(1, p-init-string, p-encode-char)
    .
    do ind = 2 to v-num-entries-init-string
    :
      assign
        v-sub-phrase = entry(ind, p-init-string, p-encode-char)
      .
      assign
        v-special-char = octal-to-char(substring(v-sub-phrase, 1, 3))
      .
      if v-special-char <> ? then do:
        assign
          p-decode-string = p-decode-string
                          + v-special-char
                          + substring(v-sub-phrase, 4)
        .
      end.
      else do:
        assign
          p-decode-string = p-decode-string
                          + p-encode-char
                          + v-sub-phrase
        .
      end.
    end.
  end.
  else do:
    assign
      p-decode-string = p-init-string
    .
  end.
  return p-decode-string .
end.
define variable counter    as integer   no-undo .
define variable rec-full   as character no-undo .
define variable v-rec-name as character no-undo .
define variable log-file-name as character no-undo .
define variable v-action as character no-undo .
define variable v-curr-rowid as rowid no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-db-list     as character no-undo .
define variable v-command     as character no-undo .
define variable v-cmd-code    as integer no-undo .
define variable v-cmd-proc-handle as handle no-undo .
define variable v-run-parovoz as logical no-undo .
define variable v-rec-ord as recid no-undo .
define variable v-is-obj as logical no-undo .
define variable v-obj-db-num as integer no-undo .
define buffer buf_schedule for ub.schedule.
define buffer buf_db for ub.db.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr
field action  as integer
.
define buffer buf_temp-thbj-attr for temp-thbj-attr.
define buffer buf_thbj-attr for ub.thbj-attr.
define temp-table temp-prop-ref-call no-undo like ub.prop-ref-call
field action as integer
.
define temp-table temp-rule-call-param no-undo like ub.rule-call-param
field action as integer
.
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_rule-call-param for ub.rule-call-param.
define temp-table temp-rule-by-call no-undo like ub.rule-by-call
field action as integer
.
define buffer buf_temp-rule-by-call for temp-rule-by-call.
define buffer buf_rule-by-call for ub.rule-by-call.
define temp-table temp-rp-by-call no-undo like ub.rp-by-call
field action as integer
.
define buffer buf_temp-rp-by-call for temp-rp-by-call .
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_temp-prop-ref-call for temp-prop-ref-call.
define buffer buf_prop-ref-call for ub.prop-ref-call.
main-block:
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  do counter = 1 to p-counter
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    run waitfram-show in this-procedure
      (input substitute("Получение настроек машины правил. &1 Получено записей: &2"
                        , p-uniq-key-rec
                        , counter)
      ) .
    if counter = 1 then do:
    run gen-row-keyr in this-procedure (
                                           input  p-uniq-key-rec
                                          ,input  ?
                                          ,input  "ub"
                                          ,input  ?
                                          ,input  EXCLUSIVE-LOCK
                                          ,output v-tbl-row
                                          ,output v-tbl-name   ) .
    end.
    run nws-imps in p-imp-handle
      ( input-output counter
       ,output       rec-full
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    assign
      v-rec-name = entry( 1, rec-full, chr(1) )
      v-action = entry(2, rec-full, chr(1))
    .
    CASE v-rec-name :
      when 'thbj-attr':U
      then do:
        run proc-load-standart in p-imp-handle
          ( input 'thbj-attr':U
            ,input '':U
            ,input (buffer buf_temp-thbj-attr:handle)
            ,input p-imp-handle
            ,input 0
            ,output v-curr-rowid
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
        define variable v-field-list as character no-undo .
        define variable v-value-list as character no-undo .
        define variable v-obj-type as character no-undo .
        define variable v-obj-code as integer no-undo .
        run  gen-key-fv in this-procedure ( input p-uniq-key-rec
                                          ,output v-field-list
                                          ,output v-value-list).
        if lookup("obj-type", v-field-list, chr(3)) > 0 then do:
          assign
          v-obj-type = entry(lookup("obj-type", v-field-list, chr(3)), v-value-list, chr(3))
          v-obj-code = integer(entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3)) )
          v-is-obj = not (v-obj-type = '' and v-obj-code = 0)
          .
        end.
      end.
      when 'rule-call-param':U
      then do:
        run proc-load-standart in p-imp-handle
          ( input 'rule-call-param':U
            ,input '':U
            ,input (buffer buf_temp-rule-call-param:handle)
            ,input p-imp-handle
            ,input 0
            ,output v-curr-rowid
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
        if v-action = "+delete" then do:
          find first buf_temp-rule-call-param where
                    rowid(buf_temp-rule-call-param) = v-curr-rowid.
          buf_temp-rule-call-param.action = integer('99':U).
        end.
      end.
      when 'rule-by-call':U
      then do:
        run proc-load-standart in p-imp-handle
          ( input 'rule-by-call':U
            ,input '':U
            ,input (buffer buf_temp-rule-by-call:handle)
            ,input p-imp-handle
            ,input 0
            ,output v-curr-rowid
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
        if v-action = "+delete" then do:
          find first buf_temp-rule-by-call where
                    rowid(buf_temp-rule-by-call) = v-curr-rowid.
          buf_temp-rule-by-call.action = integer('99':U).
        end.
      end.
      when 'rp-by-call':U
      then do:
        run proc-load-standart in p-imp-handle
          ( input 'rp-by-call':U
            ,input '':U
            ,input (buffer buf_temp-rp-by-call:handle)
            ,input p-imp-handle
            ,input 0
            ,output v-curr-rowid
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
        if v-action = "+delete" then do:
          find first buf_temp-rp-by-call where
                    rowid(buf_temp-rp-by-call) = v-curr-rowid.
          buf_temp-rp-by-call.action = integer('99':U).
        end.
      end.
      when 'prop-ref-call':U
      then do:
        run proc-load-standart in p-imp-handle
          ( input 'prop-ref-call':U
            ,input '':U
            ,input (buffer buf_temp-prop-ref-call:handle)
            ,input p-imp-handle
            ,input 0
            ,output v-curr-rowid
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
        if v-action = "+delete" then do:
          find first buf_temp-prop-ref-call where
                    rowid(buf_temp-prop-ref-call) = v-curr-rowid.
          buf_temp-prop-ref-call.action = integer('99':U).
        end.
      end.
      otherwise do:
        run waitfram-hide in this-procedure .
        message
          vss-workfile vss-revision vss-description skip
          "Не предусмотрен прием таблицы " v-rec-name skip
          "в составе команды" 'cmd-dct-send':U skip
          view-as alert-box error .
        return error .
      end.
    END CASE.
  end.
  run waitfram-show in this-procedure ( substitute("           Обновление информации по &1:"
                                                   , p-uniq-key-rec
                                                   )
                                       ).
  if p-uniq-key-rec begins 'schedule':U
  or (p-uniq-key-rec begins 'thbj-attr':U and v-is-obj)
  and p-counter > 0
  then do:
    case entry(1, p-uniq-key-rec, chr(3)):
      when 'schedule':U then do:
        find first buf_schedule no-lock where
                  rowid(buf_schedule) = v-tbl-row no-error.
        if not available buf_schedule
        and g#db-num = 0
        then do:
          v-run-parovoz = no.
        end.
        else do:
          if g#db-num = 0 then do:
            if buf_schedule.cre-db-num = g#news-source-db
            then do:
              v-run-parovoz = no.
            end.
            else do:
              v-run-parovoz = no.
            end.
          end.
        end.
      end.
      when 'thbj-attr':U then do:
        find first buf_thbj-attr no-lock where
                  rowid(buf_thbj-attr) = v-tbl-row no-error.
        if not available buf_thbj-attr
        and g#db-num = 0
        then do:
          v-run-parovoz = yes.
        end.
        else do:
          if g#db-num = 0 then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_thbj-attr.obj-type
  ,input  buf_thbj-attr.obj-code
  ,output v-obj-db-num
  )  .
            if v-obj-db-num = g#news-source-db
            then do:
              v-run-parovoz = yes.
            end.
            else do:
              v-run-parovoz = no.
            end.
          end.
        end.
      end.
    end.
    if v-run-parovoz then do:
      if not valid-handle(v-cmd-proc-handle ) then dO:
        run nws/cmd-bush.p persistent set v-cmd-proc-handle no-error .
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          undo main-block, return error substitute("&1 &2 &3&4Ошибка при запуске процедуры cmd-bush.p&4" +
                                              "&5&4&6"
                                              ,vss-workfile
                                              ,vss-revision
                                              ,vss-description
                                              ,chr(10)
                                              ,error-status:get-message(1)
                                              ,return-value ).
        end.
      end.
      assign
      v-command =  substitute("&2&1&3&1"
                            , chr(6)
                            , 'cmd-rum-send':U
                            ,  str-encode( p-uniq-key-rec
                                          , ""
                                          , chr(3))
                            ).
      if g#db-num = 0 then do:
        for each buf_db no-lock:
          if buf_db.db-num = 0 then next.
          if g#news
           and buf_db.db-num = g#news-source-db
          then next.
          assign
          v-db-list = v-db-list + chr(1) + string(buf_db.db-num).
          v-db-list = trim(v-db-list, chr(1)).
        end.
      end.
      else do:
        assign
        v-db-list = string(0)
        .
      end.
      run begin-create-command in v-cmd-proc-handle
        (input  v-command
        ,INPUT  v-db-list
        ,output v-cmd-code
        ) no-error.
      if error-status :error
      then do:
        delete procedure v-cmd-proc-handle .
        undo main-block, return error substitute("&1 &2 &3&4Ошибка при создании команды &5&4" +
                                            "&6&4&7"
                                            ,vss-workfile
                                            ,vss-revision
                                            ,vss-description
                                            ,chr(10)
                                            ,'cmd-rum-send':U
                                            ,error-status:get-message(1)
                                            ,return-value ).
      end.
    end.
  end.
  for each buf_temp-rp-by-call
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_rp-by-call where
              buf_rp-by-call.call#_id = buf_temp-rp-by-call.call#_id
          and buf_rp-by-call.profile_id = buf_temp-rp-by-call.profile_id
          and buf_rp-by-call.once-more = buf_temp-rp-by-call.once-more
          no-error .
    if buf_temp-rp-by-call.action = integer('99':U) then do:
      if not available buf_rp-by-call then do:
      end.
      else do:
            if v-run-parovoz then do : run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'rp-by-call':U                                                                                          ,input '+delete'                                                                                         ,input buffer buf_rp-by-call:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo main-block, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'rp-by-call':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.                                                                                                         end.
        delete buf_rp-by-call.
      end.
    end.
    else do:
      if not available buf_rp-by-call then do:
          find first buf_rp-by-call where
              buf_rp-by-call.call_id = buf_temp-rp-by-call.call_id
          and buf_rp-by-call.profile_id = buf_temp-rp-by-call.profile_id
          and buf_rp-by-call.once-more = buf_temp-rp-by-call.once-more
          no-error .
          if not available buf_rp-by-call then
          create buf_rp-by-call.
      end.
      buffer-copy buf_temp-rp-by-call to buf_rp-by-call.
            if v-run-parovoz then do : run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'rp-by-call':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_rp-by-call:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo main-block, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'rp-by-call':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.                                                                                                         end.
    end.
  end.
  for each buf_temp-rule-by-call
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_rule-by-call where
              buf_rule-by-call.call#_id = buf_temp-rule-by-call.call#_id
          and buf_rule-by-call.codex_id = buf_temp-rule-by-call.codex_id
          and buf_rule-by-call.ruleset_id = buf_temp-rule-by-call.ruleset_id
          and buf_rule-by-call.order_id = buf_temp-rule-by-call.order_id  no-error .
    if buf_temp-rule-by-call.action = integer('99':U) then do:
      if not available buf_rule-by-call then do:
      end.
      else do:
            if v-run-parovoz then do : run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'rule-by-call':U                                                                                          ,input '+delete'                                                                                         ,input buffer buf_rule-by-call:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo main-block, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'rule-by-call':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.                                                                                                         end.
        delete buf_rule-by-call.
      end.
    end.
    else do:
      if not available buf_rule-by-call then do:
          create buf_rule-by-call.
      end.
      buffer-copy buf_temp-rule-by-call to buf_rule-by-call.
            if v-run-parovoz then do : run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'rule-by-call':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_rule-by-call:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo main-block, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'rule-by-call':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.                                                                                                         end.
    end.
  end.
  for each buf_temp-rule-call-param
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_rule-call-param where
              buf_rule-call-param.call#_id = buf_temp-rule-call-param.call#_id
          and buf_rule-call-param.codex_id = buf_temp-rule-call-param.codex_id
          and buf_rule-call-param.ruleset_id = buf_temp-rule-call-param.ruleset_id
          and buf_rule-call-param.order_id = buf_temp-rule-call-param.order_id
          and buf_rule-call-param.param-name = buf_temp-rule-call-param.param-name
          and buf_rule-call-param.p-index = buf_temp-rule-call-param.p-index    no-error .
    if buf_temp-rule-call-param.action = integer('99':U) then do:
      if not available buf_rule-call-param then do:
      end.
      else do:
            if v-run-parovoz then do : run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'rule-call-param':U                                                                                          ,input '+delete'                                                                                         ,input buffer buf_rule-call-param:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo main-block, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'rule-call-param':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.                                                                                                         end.
        delete buf_rule-call-param.
      end.
    end.
    else do:
      if not available buf_rule-call-param then do:
         find first buf_rule-call-param where
              buf_rule-call-param.call_id = buf_temp-rule-call-param.call_id
          and buf_rule-call-param.codex_id = buf_temp-rule-call-param.codex_id
          and buf_rule-call-param.ruleset_id = buf_temp-rule-call-param.ruleset_id
          and buf_rule-call-param.order_id = buf_temp-rule-call-param.order_id
          and buf_rule-call-param.param-name = buf_temp-rule-call-param.param-name
          and buf_rule-call-param.p-index = buf_temp-rule-call-param.p-index    no-error .
          if not available buf_rule-call-param then
          create buf_rule-call-param.
      end.
      buffer-copy buf_temp-rule-call-param to buf_rule-call-param.
            if v-run-parovoz then do : run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'rule-call-param':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_rule-call-param:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo main-block, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'rule-call-param':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.                                                                                                         end.
    end.
  end.
  for each buf_temp-prop-ref-call
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_prop-ref-call where
              buf_prop-ref-call.call#_id = buf_temp-prop-ref-call.call#_id
          and buf_prop-ref-call.dt-code = buf_temp-prop-ref-call.dt-code no-error .
    if buf_temp-prop-ref-call.action = integer('99':U) then do:
      if not available buf_prop-ref-call then do:
      end.
      else do:
            if v-run-parovoz then do : run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'prop-ref-call':U                                                                                          ,input '+delete'                                                                                         ,input buffer buf_prop-ref-call:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo main-block, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'prop-ref-call':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.                                                                                                         end.
        delete buf_prop-ref-call.
      end.
    end.
    else do:
      if not available buf_prop-ref-call then do:
          create buf_prop-ref-call.
      end.
      buffer-copy buf_temp-prop-ref-call to buf_prop-ref-call.
            if v-run-parovoz then do : run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'prop-ref-call':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_prop-ref-call:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo main-block, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'prop-ref-call':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.                                                                                                         end.
    end.
  end.
  for each buf_temp-thbj-attr
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_thbj-attr where
             buf_thbj-attr.upper-prop-code = buf_temp-thbj-attr.upper-prop-code
         and buf_thbj-attr.prop-code = buf_temp-thbj-attr.prop-code
         and buf_thbj-attr.obj-type = buf_temp-thbj-attr.obj-type
         and buf_thbj-attr.obj-code = buf_temp-thbj-attr.obj-code no-error.
    if not available buf_thbj-attr then do:
      create buf_thbj-attr.
    end.
    buffer-copy buf_temp-thbj-attr to buf_thbj-attr.
            if v-run-parovoz then do : run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'thbj-attr':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_thbj-attr:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo main-block, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'thbj-attr':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.                                                                                                         end.
  end.
  if v-run-parovoz then do:
    run send-command in v-cmd-proc-handle
       ( input v-cmd-code
        ,input v-db-list
        ) no-error .
    if error-status:error then do:
      delete procedure v-cmd-proc-handle .
      message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при отсылке команды &1", 'cmd-rum-send':U ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
      undo main-block, return error .
    end.
    delete procedure v-cmd-proc-handle .
  end.
  run waitfram-hide in this-procedure .
  return ''.
end.
procedure write-to-log :
define input parameter p-mess as character no-undo .
  do
  on error undo, return error
  :
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input p-mess).
  end.
end procedure.
