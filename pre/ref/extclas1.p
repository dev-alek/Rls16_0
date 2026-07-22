block-level on error undo, throw.
define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-classif-subject as character no-undo .
define input parameter        p-classif-name    as character no-undo .
define input parameter        p-db-num as integer no-undo .
define input parameter        p-Key#_One as integer no-undo .
define input parameter        p-Key#_Two as integer no-undo .
define input parameter        p-key#_Three as integer no-undo .
define input parameter        p-CharKey_One as character no-undo .
define input parameter        p-CharKey_two as character no-undo .
define input parameter        p-CharKey_Three as character no-undo .
define input parameter        p-nonunique as integer no-undo .
define input parameter        p-uniq-key-rec as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: 7e2ad33a7a6f, 2391, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2020/06/10 18:13:43 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: extclas1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/extclas1.p $":U .
define variable vss-description as character no-undo init "Сохранение записи во внешнем классификаторе".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable v-mess as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-obj-db-num as integer no-undo .
define variable v-gds-code as integer no-undo .
define variable v-tbl-rid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-guid1      as character no-undo .
define variable v-guid2      as character no-undo .
define variable v-guid1_     as character no-undo .
define variable v-guid2_     as character no-undo .
define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_ext-system for ub.ext-system.
define variable choice         as LOGICAL   NO-UNDO .
define buffer bf_ext-system   for ub.ext-system.
define buffer buf2_ext-classif for ub.ext-classif.
define buffer buf2_ext-system for ub.ext-system.
define buffer bf_ext-classif  for ub.ext-classif.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.
_main:
do for buf_ext-classif
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  if lookup(p-classif-subject, ('clients':U + chr(44) + 'goods':U + chr(44) + 'cli-grp':U + chr(44) + 'gds-grp':U + chr(44) + 'EGAIS':U)) = 0 then do:
    v-mess = substitute("Неверное значение типа внешнего классификатора = &1", p-classif-subject).
    run err-mess in this-procedure ( input-output v-mess).
    undo _main, return error (if p-silent = yes then v-mess else 'classif-subject':U).
  end.
  if lookup(p-classif-name, 'inn,exp-parus-code,exp-parus-2-code,GLN,th-th150_clients,th-th14_clients,exite-edi,th-th150_goods,th-th14_goods,exp-accor-gds-code,exp-esys-gds-code,msf-code,clients-esys,exp-easyfuel-talon-gds-code,clients-edoc-nn,gds-grp,th-th_gds-grp,rpm_gds-grp,goods_fib,code_firm_ext,code_org_client,id_diadok_client,oss-ref,egais-transId,FormF1-esys':U) = 0
  or p-classif-name = ''
  then do:
    v-mess = substitute("Неверное значение названия внешнего классификатора = &1", p-classif-name).
    run err-mess in this-procedure ( input-output v-mess).
    undo _main, return error (if p-silent = yes then v-mess else 'classif-name':U).
  end.
  if p-uniq-key-rec <> '' then do:
  run gen-key-fv in this-procedure (
                                      input p-uniq-key-rec
                                      ,output v-field-list
                                      ,output v-value-list).
  end.
  case p-classif-subject:
    when 'clients':U then do:
      case p-classif-name:
        when 'exp-parus-code':U then do:
          if g#db-num > 0 then do:
            v-mess = substitute("Запрещено добавлять коды клиента системы ПАРУС в УБД").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          assign
          v-obj-type = entry(lookup("obj-type":U
                                            , v-field-list
                                            , chr(3))
                                      , v-value-list, chr(3))
          v-obj-code = integer(entry(lookup("obj-code":U
                                            , v-field-list
                                            , chr(3))
                                      , v-value-list, chr(3)))
          no-error .
          if not (v-obj-type = 'орг':U
                  or
                  v-obj-type = 'чел':U) then do:
            v-mess = substitute("В классификатор Клиенты системы ПАРУС можно добавлять только &1 или &2", 'орг':U, 'чел':U).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
        end.
        end.
        when 'exp-parus-2-code':U then do:
          if g#db-num > 0 then do:
            v-mess = substitute("Запрещено добавлять коды клиента системы ПАРУС-2 в УБД").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          assign
          v-obj-type = entry(lookup("obj-type":U
                                            , v-field-list
                                            , chr(3))
                                      , v-value-list, chr(3))
          v-obj-code = integer(entry(lookup("obj-code":U
                                            , v-field-list
                                            , chr(3))
                                      , v-value-list, chr(3)))
          no-error .
          if not (v-obj-type = 'орг':U
                  or
                  v-obj-type = 'чел':U) then do:
            v-mess = substitute("В классификатор Клиенты системы ПАРУС-2 можно добавлять только &1 или &2", 'орг':U, 'чел':U).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          if trim(p-charkey_one, "0123456789") <> "" then do:
            v-mess = substitute("Код в классификаторе Клиенты системы ПАРУС-2 может содержать только цифры").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
        end.
        when 'clients-esys':U then do:
          find first buf_ext-system no-lock where
                    buf_Ext-system.esys-id = p-key#_one
                and buf_Ext-system.db-num = 0 no-error.
          if available buf_Ext-system and buf_Ext-system.whole-send-news <> integer('10':U) then do :
              if g#db-num > 0 then do:
                v-mess = substitute("Запрещено добавлять коды объектов внешних систем в УБД").
                run err-mess in this-procedure ( input-output v-mess).
                undo _main, return error (if p-silent = yes then v-mess else '':U).
              end.
    find first buf_ext-classif no-lock where
              buf_ext-classif.classif-subject = p-classif-subject
          and buf_ext-classif.classif-name = p-classif-name
          and buf_ext-classif.db-num = p-db-num
          and buf_ext-classif.uniq-key-rec  = p-uniq-key-rec
          and buf_ext-classif.key#_one = p-key#_one
          and buf_ext-classif.nonunique = p-nonunique
          and buf_ext-system.esys-type <> integer('10':U)  no-error.
    if available buf_ext-classif then do:
     v-mess = substitute("Вн.система &1 с таким объектом/контрагентом &2 &3 уже существует", buf_ext-system.esys-name, string(ENTRY(2, p-uniq-key-rec, chr(3))), string(ENTRY(3, p-uniq-key-rec, chr(3)))).
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
    end.
    if buf_ext-system.esys-type = integer('10':U) then do:
    for each buf_ext-classif no-lock where
              buf_ext-system.esys-type = integer('10':U)
          and buf_ext-classif.classif-subject = p-classif-subject
          and buf_ext-classif.classif-name = p-classif-name
          and buf_ext-classif.db-num = p-db-num
          and buf_ext-classif.key#_one = p-key#_one
          and buf_ext-classif.key#_two = p-key#_two
          and buf_ext-classif.nonunique = p-nonunique  :
      v-guid1 = entry(1,buf_ext-classif.charkey_two,chr(6)) .
      v-guid2 = entry(2,buf_ext-classif.charkey_two,chr(6)) .
      v-guid1_ = entry(1,p-charkey_two,chr(6)) .
      v-guid2_ = entry(2,p-charkey_two,chr(6)) .
      if entry(2,p-uniq-key-rec,chr(3)) = 'орг':U then do:
        find first bf_ext-classif no-lock where
              bf_ext-classif.classif-subject = p-classif-subject
          and bf_ext-classif.classif-name = p-classif-name
          and bf_ext-classif.db-num = p-db-num
          and bf_ext-classif.uniq-key-rec  = p-uniq-key-rec
          and bf_ext-classif.key#_one = p-key#_one
          and bf_ext-classif.nonunique = p-nonunique
          and buf_ext-system.esys-type = integer('10':U)  no-error.
        if available (bf_ext-classif) then do:
          if bf_ext-classif.CharKey_Two <> "" and entry(2,bf_ext-classif.charkey_two,chr(6)) = "" then do:
            v-mess = substitute("Уже есть запись c GUID хоз Субъекта для этой фирмы").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
        end.
      end.
      if v-guid1 <> "" and v-guid1 = v-guid1_ and v-guid2 = v-guid2_ and v-guid2 <> ""
      then do:
        v-mess = substitute("Уже есть запись c GUID хоз Субъекта: &1 и GUID площадки: &2", v-guid1, v-guid2).
        run err-mess in this-procedure ( input-output v-mess).
        undo _main, return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
    end.
          end.
          if not available buf_ext-system then do:
            v-mess = substitute("Не найдена внешняя система &1 для БД &2"
                               , p-key#_one
                               , 0).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          assign
          v-obj-type = entry(lookup("obj-type":U
                                            , v-field-list
                                            , chr(3))
                                      , v-value-list, chr(3))
          v-obj-code = integer(entry(lookup("obj-code":U
                                            , v-field-list
                                            , chr(3))
                                      , v-value-list, chr(3)))
          no-error .
          if not (v-obj-type = 'маг':U
                  or
                  v-obj-type = 'орг':U
                  or
                  v-obj-type = 'скл':U
                  or
                  v-obj-type = ''
                  or v-obj-type = 'чел':U
                  ) then do:
            v-mess = substitute("В классификатор Объекты внешних систем можно добавлять только <&1> или <&2> или <>", 'маг':U, 'скл':U).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
        end.
        when 'clients-edoc-nn':U then do:
          if g#db-num > 0 then do:
            v-mess = substitute("Запрещено добавлять привязку поставщиков к внешним системам в УБД").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          find first buf_ext-system no-lock where
                    buf_Ext-system.esys-id = p-key#_one
                and buf_Ext-system.db-num = 0 no-error.
          if not available buf_ext-system then do:
            v-mess = substitute("Не найдена внешняя система &1 для БД &2"
                               , p-key#_one
                               , 0).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          for each buf2_ext-classif no-lock where
                       buf2_ext-classif.classif-subject = p-classif-subject
                   and buf2_ext-classif.classif-name = p-classif-name
                   and buf2_ext-classif.uniq-key-rec = p-uniq-key-rec,
             first buf2_ext-system no-lock where
                    buf2_Ext-system.esys-id = buf2_ext-classif.key#_one
                and buf2_Ext-system.db-num = 0 :
            if buf2_ext-system.esys-db-num-exp = buf_ext-system.esys-db-num-exp
            and recid(buf_ext-system) <> recid(buf2_ext-system)
            and (p-mode = 'ДОБАВЛЕНИЕ':U or recid(buf_ext-classif) <> recid(buf2_ext-classif))
            then do:
              v-mess = substitute("Для данного поставщика уже определена внешняя система &2 с экспортом в БД &1"
                                , buf2_ext-system.esys-id
                                , buf2_ext-system.esys-db-num-exp).
              run err-mess in this-procedure ( input-output v-mess).
              undo _main, return error (if p-silent = yes then v-mess else '':U).
            end.
          end.
        end.
        when 'exite-edi':U then do:
          if g#db-num > 0 then do:
            v-mess = substitute("Запрещено добавлять привязку к EDI в УБД").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          find first buf_ext-system no-lock where
                    buf_Ext-system.esys-id = p-key#_one
                and buf_Ext-system.db-num = 0 no-error.
          if not available buf_ext-system then do:
            v-mess = substitute("Не найдена внешняя система &1 для БД &2"
                               , p-key#_one
                               , 0).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          if buf_ext-system.esys-type <> integer('9':U) then do:
            v-mess = substitute("Внешняя система &1 имеет не предусмотренный тип"
                               , p-key#_one
                               , 0).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          assign
          v-obj-type = entry(lookup("obj-type":U
                                            , v-field-list
                                            , chr(3))
                                      , v-value-list, chr(3))
          v-obj-code = integer(entry(lookup("obj-code":U
                                            , v-field-list
                                            , chr(3))
                                      , v-value-list, chr(3)))
          no-error .
          if ((v-obj-type = 'орг':U and not can-find(first ub.sysconf no-lock where ub.sysconf.host-code = v-obj-code)
             )
          or v-obj-type = 'чел':U )
          and  not (p-charkey_one = 'without-ordrsp':U
                  or
                  p-charkey_one = 'with-ordrsp':U ) then do:
            v-mess = substitute("Неверное значение Параметра работы через EDI (&1)"
                               , p-charkey_one
                               , 0).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          if (v-obj-type = 'маг':U
          or v-obj-type = 'скл':U) and buf_ext-system.esys-db-num-exp ne 0 then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output v-obj-db-num
  )  .
            if buf_ext-system.esys-db-num-exp <> v-obj-db-num then do:
              v-mess = substitute("Нельзя привязать объект &1&2 к ВС, которая работает в другой БД"
                                , v-obj-type
                                , v-obj-code).
              run err-mess in this-procedure ( input-output v-mess).
              undo _main, return error (if p-silent = yes then v-mess else '':U).
            end.
            for each buf2_ext-classif no-lock where
                        buf2_ext-classif.classif-subject = p-classif-subject
                    and buf2_ext-classif.classif-name = p-classif-name
                    and buf2_ext-classif.uniq-key-rec = p-uniq-key-rec,
              first buf2_ext-system no-lock where
                      buf2_Ext-system.esys-id = buf2_ext-classif.key#_one
                  and buf2_Ext-system.db-num = 0 :
              if (buf2_ext-system.esys-db-num-exp = buf_ext-system.esys-db-num-exp
                  or
                  buf2_ext-system.esys-db-num-imp = buf_ext-system.esys-db-num-imp)
              and recid(buf_ext-system) <> recid(buf2_ext-system)
              and (p-mode = 'ДОБАВЛЕНИЕ':U or recid(buf_ext-classif) <> recid(buf2_ext-classif))
              then do:
                v-mess = substitute("Для данного объекта уже определена внешняя система &1 с экспортом/импортом в БД &2"
                                  , buf2_ext-system.esys-id
                                  , buf2_ext-system.esys-db-num-exp).
                run err-mess in this-procedure ( input-output v-mess).
                undo _main, return error (if p-silent = yes then v-mess else '':U).
              end.
            end.
          end.
          else do:
            for each buf2_ext-classif no-lock where
                        buf2_ext-classif.classif-subject = p-classif-subject
                    and buf2_ext-classif.classif-name = 'clients-edoc-nn':U
                    and buf2_ext-classif.uniq-key-rec = p-uniq-key-rec,
              first buf2_ext-system no-lock where
                    buf2_ext-system.esys-id = buf2_ext-classif.key#_one
                  and buf2_ext-system.esys-db-num-exp = buf_ext-system.esys-db-num-exp
                  and buf2_ext-system.esys-have-export = yes
                  :
              v-mess = substitute("Для данного контрагента уже определена работа по EDOC-NN по ВС &1 с экспортом/импортом в БД &2"
                                , buf2_ext-system.esys-id
                                , buf2_ext-system.esys-db-num-exp).
              run err-mess in this-procedure ( input-output v-mess).
              undo _main, return error (if p-silent = yes then v-mess else '':U).
            end.
          end.
        end.
        when 'GLN':U then do:
          if g#db-num > 0 then do:
            v-mess = substitute("Запрещено добавлять GLN коды клиента в УБД").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          find first buf2_ext-classif no-lock where
                        buf2_ext-classif.classif-subject = p-classif-subject
                    and buf2_ext-classif.classif-name = p-classif-name
                    and buf2_ext-classif.uniq-key-rec = p-uniq-key-rec
                    and (p-mode = 'ДОБАВЛЕНИЕ':U
                         or
                         (p-mode <> 'ДОБАВЛЕНИЕ':U
                         and
                         recid(buf2_ext-classif) <> recid(buf_ext-classif))
                         ) no-error.
          if available buf2_ext-classif then do:
            v-mess = substitute("Нельзя завести более одного GLN кода для одного клиента").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          if p-mode = 'ДОБАВЛЕНИЕ':U then do:
            find first buf2_ext-classif no-lock where
                          buf2_ext-classif.classif-subject = p-classif-subject
                      and buf2_ext-classif.classif-name = p-classif-name
                      and buf2_ext-classif.charkey_one = p-charkey_one no-error.
            if available buf2_ext-classif then do:
              v-mess = substitute("Уже есть клиент с GLN &1", p-charkey_one).
              run err-mess in this-procedure ( input-output v-mess).
              undo _main, return error (if p-silent = yes then v-mess else '':U).
            end.
          end.
          assign
          v-obj-type = entry(lookup("obj-type":U
                                            , v-field-list
                                            , chr(3))
                                      , v-value-list, chr(3))
          v-obj-code = integer(entry(lookup("obj-code":U
                                            , v-field-list
                                            , chr(3))
                                      , v-value-list, chr(3)))
          no-error .
          if trim(p-charkey_one, "0123456789") <> "" then do:
            v-mess = substitute("Не верно введен GLN (&1)", p-charkey_one).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          define variable v-v-gln as decimal no-undo .
          define variable v-v-gln1 as decimal no-undo .
          assign
          v-v-gln = decimal(p-charkey_one)
          v-v-gln1 = decimal(substring(p-charkey_one, 1 ,12))
          .
          run str/chk-sum.p ( input-output v-v-gln1 ) no-error .
          if error-status :error then do:
            v-mess = substitute("Ошибка при проверке GLN (&1)&2&3&2&4"
                                , p-charkey_one
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value
                                ).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          if v-v-gln  <>  v-v-gln1 then do:
            v-mess = substitute("Неверная КЦ в GLN (&1)", p-charkey_one).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
        end.
        when 'id_diadok_client':U then
            do:
              find first buf2_ext-classif no-lock where
                buf2_ext-classif.classif-subject = p-classif-subject
                and buf2_ext-classif.classif-name = p-classif-name
                and buf2_ext-classif.uniq-key-rec = p-uniq-key-rec
                and (p-mode = 'ДОБАВЛЕНИЕ':U
                or
                (p-mode <> 'ДОБАВЛЕНИЕ':U
                and
                recid(buf2_ext-classif) <> recid(buf_ext-classif))
                ) no-error.
              if available buf2_ext-classif then
              do:
                v-mess = substitute("Нельзя завести более одного ИД ДИАДОК для одного клиента").
                run err-mess in this-procedure ( input-output v-mess).
                undo _main, return error (if p-silent = yes then v-mess else '':U).
              end.
              if p-mode = 'ДОБАВЛЕНИЕ':U then
              do:
                find first buf2_ext-classif no-lock where
                  buf2_ext-classif.classif-subject = p-classif-subject
                  and buf2_ext-classif.classif-name = p-classif-name
                  and buf2_ext-classif.CharKey_Three = p-CharKey_three no-error.
                if available buf2_ext-classif then
                do:
                  v-mess = "Уже есть клиент с ДИАДОК: " + p-CharKey_three .
                  run err-mess in this-procedure ( input-output v-mess).
                  undo _main, return error (if p-silent = yes then v-mess else '':U).
                end.
              end.
              assign
                v-obj-type = entry(lookup("obj-type":U
                                            , v-field-list
                                            , chr(3))
                                      , v-value-list, chr(3))
                v-obj-code = integer(entry(lookup("obj-code":U
                                            , v-field-list
                                            , chr(3))
                                      , v-value-list, chr(3)))
          no-error .
            end.
        when 'code_firm_ext':U then do:
          if g#db-num > 0 then do:
            v-mess = substitute("Запрещено добавлять соответствия номеров фирм в ТН номерам наших фирм в системах клиентов в УБД").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          assign
          v-obj-type = entry(lookup("obj-type":U
                                            , v-field-list
                                            , chr(3))
                                      , v-value-list, chr(3))
          v-obj-code = integer(entry(lookup("obj-code":U
                                            , v-field-list
                                            , chr(3))
                                      , v-value-list, chr(3)))
          no-error .
          if not (v-obj-type = 'орг':U
                  or
                  v-obj-type = 'чел':U)
          then do:
            v-mess = substitute("В классификатор соответствия номеров фирм в ТН номерам наших фирм в системах клиентов можно добавлять только &1 или &2", 'орг':U, 'чел':U).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
        end.
        when 'code_org_client':U then do:
            for each buf2_ext-classif no-lock
              where buf2_ext-classif.classif-subject = p-classif-subject
                and buf2_ext-classif.classif-name = 'code_org_client':U
                and buf2_ext-classif.uniq-key-rec = p-uniq-key-rec
            :
              v-mess = substitute( "Для клиента &1 &2 уже определен контрагент &3 &4"
                                , buf2_ext-classif.CharKey_One
                                , buf2_ext-classif.Key#_One
                                , buf2_ext-classif.CharKey_two
                                , buf2_ext-classif.charkey_three
                                ).
              run err-mess in this-procedure ( input-output v-mess).
              undo _main, return error (if p-silent = yes then v-mess else '':U).
            end.
        end.
      end case.
    end.
    when 'goods':U then do:
      define variable v-petr as logical   no-undo .
      define variable v-s   as logical   no-undo .
      define buffer buf_goods for ub.goods.
      case p-classif-name:
        when 'exp-accor-gds-code':U
        or
        when 'exp-easyfuel-talon-gds-code':U
        then do:
          if g#db-num > 0 then do:
            case p-classif-name:
              when 'exp-accor-gds-code':U then do:
                v-mess = substitute("Запрещено добавлять типы топлива в классификатор АККОР в УБД").
              end.
              when 'exp-easyfuel-talon-gds-code':U then do:
                v-mess = substitute("Запрещено добавлять типы топлива в классификатор EasyFuel в УБД").
              end.
            end case.
            run err-mess in this-procedure ( input-output v-mess).
            return error (if p-silent = yes then v-mess else '':U).
          end.
          assign
          v-gds-code = integer(entry(lookup("gds-code":U
                                            , v-field-list
                                            , chr(3))
                                      , v-value-list, chr(3)))
          no-error .
          find first buf_goods no-lock where
                    buf_goods.gds-code = v-gds-code no-error.
          if not available buf_goods then do:
            v-mess = substitute("Не найден товар с уникальным ключом &1", p-uniq-key-rec).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output v-petr
  , output v-s
  ) .
          if v-petr = false then do:
            v-mess = substitute("В классификатор можно добавлять только топливо").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          if p-classif-name = 'exp-easyfuel-talon-gds-code':U
          and p-mode = 'ИЗМЕНЕНИЕ':U
          and buf_ext-classif.key#_one <> p-key#_one then do:
            run gen-row-keyr in this-procedure ( input buf_ext-classif.uniq-key-rec
                                                ,input ?
                                                ,input "ub"
                                                ,input ?
                                                ,input NO-LOCK
                                                ,output v-tbl-rid
                                                ,output v-tbl-name) .
            find first buf_goods no-lock where
                      rowid(buf_goods) = v-tbl-rid.
            define buffer buf_dis-card-property for ub.dis-card-property.
            define variable v-node-list as character no-undo .
            define variable v-ii as integer no-undo .
            v-node-list = string(5) +  chr(44) +
                          string(6) +  chr(44) +
                          string(7) +  chr(44) +
                          string(8) .
            _do:
            do v-ii = 1 to 4:
              for each buf_dis-card-property no-lock where
                      buf_dis-card-property.dtm-code = 25
                  and buf_dis-card-property.node-code = integer(entry(v-ii, v-node-list))
                  and buf_dis-card-property.property-value-integer = buf_goods.gds-code:
                leave.
              end.
              if available buf_dis-card-property then leave _do.
            end.
            if available buf_dis-card-property then do:
              v-mess = substitute("Нельзя удалить тип топлива EsayFuel&1Есть МБ EasyFuel, использующие этот код").
              run err-mess in this-procedure ( input-output v-mess).
              return error (if p-silent = yes then v-mess else '':U).
            end.
          end.
        end.
      end case.
    end.
    when 'gds-grp':U then do:
      case p-classif-name:
        when 'rpm_gds-grp':U then do:
          if g#db-num > 0 then do:
            v-mess = substitute("Запрещено создавать/изменять группы RPM в УБД").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          if p-uniq-key-rec = '' then do:
            v-mess = substitute("Группа RPM может существовать ТОЛЬКО с привязкой к группе IBS TH").
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
        end.
      end case.
    end.
  end case.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create buf_ext-classif.
    assign
    buf_ext-classif.classif-subject = p-classif-subject
    buf_ext-classif.classif-name = p-classif-name
    buf_ext-classif.db-num = p-db-num
    buf_ext-classif.key#_one = p-key#_one
    buf_ext-classif.key#_two = p-key#_two
    buf_ext-classif.key#_three = p-key#_three
    buf_ext-classif.charkey_one = p-charkey_one
    buf_ext-classif.charkey_two = p-charkey_two
    buf_ext-classif.charkey_three = p-charkey_three
    buf_ext-classif.nonunique = p-nonunique no-error.
    if error-status:error then do:
      message "Ошибка добавления записи в справочник!" view-as alert-box .
      buf_ext-classif.db-num = p-db-num .
      return no-apply .
    end.
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    find first buf_ext-classif exclusive-lock where
              recid(buf_ext-classif) = p-rec no-error.
    if not available buf_ext-classif then do:
      v-mess = substitute("Неправильно указана запись с recid=&1", p-rec).
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
    end.
    if not ( buf_ext-classif.classif-subject = p-classif-subject
          and buf_ext-classif.classif-name = p-classif-name
          and buf_ext-classif.db-num = p-db-num
          and buf_ext-classif.key#_one = p-key#_one
          and buf_ext-classif.key#_two = p-key#_two
          and buf_ext-classif.key#_three = p-key#_three
          and buf_ext-classif.charkey_one = p-charkey_one
          and buf_ext-classif.charkey_two = p-charkey_two
          and buf_ext-classif.charkey_three = p-charkey_three
          and buf_ext-classif.nonunique = p-nonunique) then do:
      v-mess = substitute("Запись внешнего классификатора не может изменять поля первичного ключа при редактировании").
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
  end.
  end.
  assign
  buf_ext-classif.uniq-key-rec = p-uniq-key-rec
  p-rec = recid(buf_ext-classif)
  .
end.
PROCEDURE err-mess:
DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
CASE p-silent:
  when yes then do:
    case p-classif-subject:
      when 'clients':U then do:
        case p-classif-name:
          when 'inn':U then do:
            assign
          p-mess = substitute("ИНН &1 для клиента &2&3&4&5"
                              , p-key#_one
                              , v-obj-type
                              , v-obj-code
                              , chr(10)
                              , p-mess)
            .
          end.
          when 'exp-parus-code':U then do:
            assign
          p-mess = substitute("Код клиента в системе ПАРУС: &1 для клиента &2&3&4&5"
                              , p-key#_one
                              , v-obj-type
                              , v-obj-code
                              , chr(10)
                              , p-mess)
            .
          end.
        when 'exp-parus-2-code':U then do:
          assign
          p-mess = substitute("Код клиента в системе ПАРУС-2: &1 для клиента &2&3&4&5"
                            , p-charkey_one
                            , v-obj-type
                            , v-obj-code
                            , chr(10)
                            , p-mess)
          .
        end.
          when 'clients-esys':U then do:
            assign
            p-mess = substitute("Объект во внешней системе &1: &2&3 для объекта &4&5 &6&7"
                              , p-key#_one
                              , p-charkey_one
                            , p-charkey_three
                              , v-obj-type
                              , v-obj-code
                              , chr(10)
                              , p-mess)
            .
          end.
        end.
      end.
      when 'goods':U then do:
        case p-classif-name:
          when  'exp-accor-gds-code':U then do:
            assign
          p-mess = substitute("Код товара &1&2&3"
                              , v-gds-code
                              , chr(10)
                              , p-mess)
            .
          end.
          when  'msf-code':U then do:
            assign
          p-mess = substitute("Код товара &1&2&3"
                            , v-gds-code
                            , chr(10)
                            , p-mess)
            .
          end.
          when  'exp-easyfuel-talon-gds-code':U then do:
            assign
            p-mess = substitute("Код товара &1&2&3"
                              , v-gds-code
                              , chr(10)
                              , p-mess)
            .
          end.
        end case.
      end.
    when 'gds-grp':U then do:
      case p-classif-name:
        when 'rpm_gds-grp':U then do:
          assign
          p-mess = substitute("Узел товарного классификатора RPM &1/&2/&3/&4&5&6&5&7"
                             , p-charkey_one
                             , p-key#_one
                             , p-key#_two
                             , p-key#_three
                             ,chr(10)
                             , error-status:get-message(1)
                             , p-mess ).
        end.
      end case.
    end.
    end case.
  end.
  when no then do:
    message
    p-mess
    view-as alert-box error .
  end.
end case.
END PROCEDURE.
