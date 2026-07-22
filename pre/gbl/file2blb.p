block-level on error undo, throw.
define input parameter p-mode      as character no-undo .
define input parameter p-blob-mode as character no-undo .
define input parameter p-bh        as handle no-undo.
define input parameter p-uniq-key-rec as character no-undo .
define input parameter p-field as character no-undo .
define input parameter p-descr as character no-undo .
define input-output parameter p-part-num as integer no-undo .
define input parameter p-resource-type as character no-undo .
define input-output parameter p-blob-db-num as integer no-undo .
define input-output parameter p-int64-id as int64 no-undo .
define input parameter p-file as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: file2blb.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/file2blb.p $":U .
define variable vss-description as character no-undo init "Копирование файла в blob".
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
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define variable v-uniq-key-rec            as character no-undo .
define variable v-md5-signature           as character no-undo .
define variable v-part-num as integer no-undo .
define variable glog as logical no-undo .
define variable v-int64-id as int64 no-undo .
define variable v-blob-db-num as integer no-undo .
define variable v-longchar1 as longchar no-undo .
define variable v-longchar2 as longchar no-undo .
define variable v-file-size as integer no-undo .
define variable v-save-blob as logical no-undo .
define buffer buf_blob-data for ub.blob-data.
define buffer other_blob-data for ub.blob-data.
define buffer other_blob-bind for ub.blob-bind.
define buffer self_blob-bind for ub.blob-bind.
FUNCTION is-abs-path returns logical ( input p-path-string as character):
if index(p-path-string, ":") > 0
or p-path-string begins (chr(47) + chr(47))
or p-path-string begins (chr(92) + chr(92))
or (index(p-path-string, chr(47)) = 0
and index(p-path-string, chr(92)) = 0) then return yes.
return no.
end function.
do
on error undo, return error
:
if p-mode <> 'ПРОСМОТР':U   and
   p-mode <> 'удаление':U  then do:
    run gbl/filename.p (
                   input p-file
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
  if error-status:error then do:
    return error substitute("Не удается найти файл &1", p-file).
  end.
end.
if p-resource-type = 'data':U then do:
  run gen-key-rec in this-procedure ( input p-bh:table
                                    ,input p-bh
                                    ,output v-uniq-key-rec) no-error .
  if error-status:error then do:
    return error return-value .
  end.
  glog = p-bh:find-current( exclusive-lock) no-error.
  if error-status:error
  or not glog
  then do:
    undo, return error substitute("Не удалось заблокировать &1 для записи файла &2  в blob&3&4&3&5"
                                  ,v-uniq-key-rec
                                  ,p-file
                                  ,chr(10)
                                  , error-status:get-message(1)
                                  , return-value ).
  end.
end.
else do:
  v-uniq-key-rec = p-uniq-key-rec.
end.
case p-mode :
  when 'ПРОСМОТР':U then do:
    find first self_blob-bind  no-lock where
            self_blob-bind.uniq-key-rec = v-uniq-key-rec
        and self_blob-bind.field-name = p-field
        and self_blob-bind.part-num = p-part-num
        no-error.
    if not available self_blob-bind then do:
      undo, return error substitute("Не найдена ссылка на blob для &1 &2 номер части &3"
                                    ,v-uniq-key-rec
                                    ,p-field
                                    ,p-part-num).
    end.
    find first buf_blob-data  no-lock where
            buf_blob-data.db-num = self_blob-bind.db-num
        and buf_blob-data.int64-id = self_blob-bind.int64-id no-error.
    if not available buf_blob-data then do:
      undo, return error substitute("Не найден blob БД &1 id &2 для &3 &4 номер части &5"
                                    ,self_blob-bind.db-num
                                    ,self_blob-bind.int64-id
                                    ,v-uniq-key-rec
                                    ,p-field
                                    ,p-part-num).
    end.
    assign
    p-blob-db-num = self_blob-bind.db-num
    p-int64-id = self_blob-bind.int64-id
    .
    v-full-path = string(session :temp-directory) + 'tempBlob.jpg' .
    COPY-LOB
      FROM  OBJECT buf_blob-data.bdata
      TO    FILE   v-full-path
      No-convert
      NO-ERROR .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка"
        view-as alert-box error
      .
     os-command silent value( 'start ' + v-full-path ) .
    return '':U.
  end.
  when 'ДОБАВЛЕНИЕ':U then do:
    run gbl/md5.p (
                            input  v-full-path
                            ,output v-md5-signature
                            ) no-error .
    if error-status:error then do:
      undo, return error substitute("&1 &2 &3&4&5&4&6"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    , error-status:get-message(1)
                                    , return-value ).
    end.
    assign
    file-info:file-name = v-full-path.
    v-file-size = file-info:file-size.
    if v-file-size > 100000000 then do:
      undo, return error substitute("Слишком большой файл &1 (> 100000000Б)", v-full-path).
    end.
    if not (p-blob-db-num = ?
            and
            p-int64-id = 0) then do:
      find first buf_blob-data  share-lock where
              buf_blob-data.db-num = p-blob-db-num
          and buf_blob-data.int64-id = p-int64-id no-error.
      if not available buf_blob-data then do:
        undo, return error substitute("Не найден blob БД &1 id &2"
                                      ,p-blob-db-num
                                      ,p-int64-id).
      end.
    end.
    find last self_blob-bind  no-lock where
            self_blob-bind.uniq-key-rec = v-uniq-key-rec
        and self_blob-bind.field-name = p-field no-error.
    if available self_blob-bind then do:
      assign
      v-part-num = self_blob-bind.part-num + 1.
    end.
    else do:
      v-part-num = 1.
    end.
    if not available buf_blob-data then do:
      create buf_blob-data.
      assign
      buf_blob-data.int64-id   = next-value( s-blob-int64, ub)
      buf_blob-data.db-num = g#db-num
      buf_blob-data.crc-field  = v-md5-signature
      buf_blob-data.file-size  = v-file-size
      buf_blob-data.resource-type = p-resource-type
      .
      buf_blob-data.file-name_ = (if is-abs-path(p-file) then v-file-name else p-file).
      COPY-LOB
      FROM  FILE v-full-path
      TO  OBJECT buf_blob-data.bdata
      No-convert
      NO-ERROR .
      if error-status:error then do:
        if error-status :error then do:
          v-longchar1 = '':U.
          v-longchar2 = '':U.
          undo, return error substitute("Ошибка при записи файла в БД&1:&2&3"
                                        , v-full-path
                                        , chr(10)
                                        , error-status:get-message(1) ).
        end.
      end.
    end.
    create self_blob-bind.
    assign
    self_blob-bind.uniq-key-rec = v-uniq-key-rec
    self_blob-bind.field-name = p-field
    self_blob-bind.part-num = v-part-num
    self_blob-bind.resource-type = p-resource-type
    self_blob-bind.db-num = buf_blob-data.db-num
    self_blob-bind.int64-id = buf_blob-data.int64-id
    self_blob-bind.descr = p-descr
    p-part-num = self_blob-bind.part-num
    p-blob-db-num = self_blob-bind.db-num
    p-int64-id = self_blob-bind.int64-id
    .
    release self_blob-bind no-error.
    if error-status:error then do:
      undo, return error substitute("&1 &2 &3Ошибки при сохранении связи BLOB с записью-владельцем &4 &5 &6&7&6&8"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,v-uniq-key-rec
                                    ,p-field
                                    ,chr(10)
                                    , error-status:get-message(1)
                                    , return-value ).
    end.
    release buf_blob-data no-error.
    if error-status:error then do:
      undo, return error substitute("&1 &2 &3Ошибки при сохранении BLOB для &6&7&6&8"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,v-uniq-key-rec
                                    ,p-field
                                    ,chr(10)
                                    , error-status:get-message(1)
                                    , return-value ).
    end.
  end.
  when 'ИЗМЕНЕНИЕ':U then do:
    if p-blob-mode <> "override"
    and p-blob-mode <> "add-new" then do:
      undo, return error  substitute("Неверное значение параметра p-clob-mode = &1", p-blob-mode).
    end.
    v-save-blob = yes.
    run gbl/md5.p (
                            input  v-full-path
                            ,output v-md5-signature
                            ) no-error .
    if error-status:error then do:
      undo, return error substitute("&1 &2 &3&4&5&4&6"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    , error-status:get-message(1)
                                    , return-value ).
    end.
    assign
    file-info:file-name = v-full-path.
    v-file-size = file-info:file-size.
    if v-file-size > 100000000 then do:
      undo, return error substitute("Слишком большой файл &1 (> 100000000Б)", v-full-path).
    end.
    find first self_blob-bind  exclusive-lock where
            self_blob-bind.uniq-key-rec = v-uniq-key-rec
        and self_blob-bind.field-name = p-field
        and self_blob-bind.part-num = p-part-num
        no-error.
    if not available self_blob-bind then do:
      undo, return error substitute("Не найдена ссылка на blob для &1 &2 номер части &3"
                                    ,v-uniq-key-rec
                                    ,p-field
                                    ,p-part-num).
    end.
    find first buf_blob-data  share-lock where
            buf_blob-data.db-num = self_blob-bind.db-num
        and buf_blob-data.int64-id = self_blob-bind.int64-id no-error.
    if not available buf_blob-data then do:
      undo, return error substitute("Не найден blob БД &1 id &2 для &3 &4 номер части &5"
                                    ,self_blob-bind.db-num
                                    ,self_blob-bind.int64-id
                                    ,v-uniq-key-rec
                                    ,p-field
                                    ,p-part-num).
    end.
    if p-blob-mode = "override" then do:
      for each other_blob-bind no-lock where
                other_blob-bind.db-num = self_blob-bind.db-num
            and other_blob-bind.int64-id = self_blob-bind.int64-id:
        if not (other_blob-bind.uniq-key-rec = self_blob-bind.uniq-key-rec
                and
                other_blob-bind.field-name = self_blob-bind.field-name
                and
                other_blob-bind.part-num = self_blob-bind.part-num
                ) then leave.
      end.
    end.
    if available other_blob-bind
    or p-blob-mode = "add-new"
    then do:
      create buf_blob-data.
      assign
      buf_blob-data.int64-id   = next-value( s-blob-int64, ub)
      buf_blob-data.db-num = g#db-num
      buf_blob-data.crc-field  = v-md5-signature
      buf_blob-data.file-size  = v-file-size
      buf_blob-data.resource-type = p-resource-type
      v-save-blob = yes
      .
      buf_blob-data.file-name_ = (if is-abs-path(p-file) then v-file-name else p-file)
      .
    end.
    else do:
      if buf_blob-data.crc-field = v-md5-signature
      and buf_blob-data.file-name_ = (if is-abs-path(p-file) then v-file-name else p-file) then do:
        v-save-blob = no.
      end.
      if v-save-blob then do:
        assign
        buf_blob-data.crc-field  = v-md5-signature
        buf_blob-data.file-size  = v-file-size
        buf_blob-data.file-name_ = (if is-abs-path(p-file) then v-file-name else p-file)
        .
      end.
    end.
    if v-save-blob then do:
      COPY-LOB
      FROM  FILE v-full-path
      TO  OBJECT buf_blob-data.bdata
      No-convert
      NO-ERROR .
      if error-status :error then do:
        undo, return error substitute("Ошибка при записи файла в БД&1:&2&3"
                                      , v-full-path
                                      , chr(10)
                                      , error-status:get-message(1) ).
      end.
      assign
      self_blob-bind.resource-type = p-resource-type
      self_blob-bind.db-num = buf_blob-data.db-num
      self_blob-bind.int64-id = buf_blob-data.int64-id
      self_blob-bind.descr = p-descr
      p-part-num = self_blob-bind.part-num
      p-blob-db-num = self_blob-bind.db-num
      p-int64-id = self_blob-bind.int64-id
      .
    end.
    release self_blob-bind no-error.
    if error-status:error then do:
      undo, return error substitute("&1 &2 &3Ошибки при сохранении связи BLOB с записью-владельцем &4 &5 &6&7&6&8"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,v-uniq-key-rec
                                    ,p-field
                                    ,chr(10)
                                    , error-status:get-message(1)
                                    , return-value ).
    end.
    release buf_blob-data no-error.
    if error-status:error then do:
      undo, return error substitute("&1 &2 &3Ошибки при сохранении BLOB для &6&7&6&8"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,v-uniq-key-rec
                                    ,p-field
                                    ,chr(10)
                                    , error-status:get-message(1)
                                    , return-value ).
    end.
  end.
  when 'удаление':U then do:
    if p-blob-mode <> "delete"
    and p-blob-mode <> "leave" then do:
      undo, return error  substitute("Неверное значение параметра p-blob-mode = &1", p-blob-mode).
    end.
    find first self_blob-bind  exclusive-lock where
            self_blob-bind.uniq-key-rec = v-uniq-key-rec
        and self_blob-bind.field-name = p-field
        and self_blob-bind.part-num = p-part-num
        no-error.
    if not available self_blob-bind then do:
      undo, return error substitute("Не найдена ссылка на blob для &1 &2 номер части &3"
                                    ,v-uniq-key-rec
                                    ,p-field
                                    ,p-part-num).
    end.
    assign
    v-blob-db-num = self_blob-bind.db-num
    v-int64-id = self_blob-bind.int64-id
    .
    delete self_blob-bind no-error .
    if error-status:error then do:
      undo, return error substitute("&1 &2 &3Ошибки при удалении связи BLOB с записью-владельцем &4 &5 &6&7&6&8"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,v-uniq-key-rec
                                    ,p-field
                                    ,chr(10)
                                    , error-status:get-message(1)
                                    , return-value ).
    end.
    if p-blob-mode = "delete" then do:
      find first buf_blob-data exclusive-lock where
                buf_blob-data.db-num = v-blob-db-num
           and  buf_blob-data.int64-id  = v-int64-id.
      delete buf_blob-data no-error.
      if error-status:error then do:
        undo, return error substitute("&1 &2 &3Ошибки при удалении BLOB для &6&7&6&8"
                                      ,vss-workfile
                                      ,vss-revision
                                      ,vss-description
                                      ,v-uniq-key-rec
                                      ,p-field
                                      ,chr(10)
                                      , error-status:get-message(1)
                                      , return-value ).
      end.
    end.
    assign
    p-part-num = ?
    p-blob-db-num = ?
    p-int64-id = 0
    .
  end.
  otherwise do:
    undo, return error  substitute("Неверное значение параметра p-mode = &1", p-mode).
  end.
end case.
end.
