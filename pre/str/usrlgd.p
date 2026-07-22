block-level on error undo, throw.
define input parameter parparentproc    as handle           no-undo.
define input parameter p-table-name     as character        no-undo.
define input parameter p-unique-key-rec as character        no-undo.
define variable vss-revision    as character no-undo init "$Revision: 2facc70d13d4, 1596, rls $":U .
define variable vss-author      as character no-undo init "$Author: SPalagin $":U .
define variable vss-date        as character no-undo init "$Date: Tue Nov 06 04:41:37 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: usrlgd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/usrlgd.p $":U .
define variable vss-description as character no-undo init "Вызов истории по документу из истории пользователя".
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
define new shared temp-table cnf no-undo
    field param-code    as character   format "x(8)"        column-label "Код"                               field param-type    as character                        column-label "Тип"                               field param-value   as character   format "x(250)"      column-label "Значение"                          field param-encoded as character                        column-label "Кодированное значение"             field host-code     as integer                          column-label "Фирма"                             field obj-type      as character                        column-label "Тип объекта"                       field obj-code      as integer     format ">>>>>>"      column-label "Код объекта"                       field conf-type     as character                        column-label "Кодировка"                         field beg-date      as date                             column-label "Начало действия параметра"         field end-date      as date                             column-label "Окончание действия параметра"      field db-num        as integer     format ">>>>>"       column-label "БД"                                field stts          as integer                          column-label "Статус"
    field db-key        as character   format "x(12)"       column-label "Ключ БД"
    field param-PS      as character   format "x(40)"       column-label "PS"
    field param-name    as character   format "x(30)"       column-label "Название"
    field is-changed    as logical initial false            column-label "Изменен"
    field NotUsed       as logical initial False            column-label "Выключен"
    field ErrorExist    as integer initial 0  format ">>"   column-label "Уровень ошибки"
    index pi
      is unique
      param-code
      host-code
      obj-type
      obj-code
      beg-date
      end-date
      db-num
    index db-num
      db-num
    index db-key
      db-key
    index par-name
      is word-index
      param-name
    index par-value
      is word-index
      param-value
 .
def new shared temp-table log-table no-undo
    field stroka       as character format "x(256)".
def new shared variable err-level as integer no-undo.
define variable v-list             as character no-undo.
define variable v-field-list       as character no-undo.
define variable v-field-value-list as character no-undo.
do
    on error undo, return error
    :
    run gen-key-fv in this-procedure (
        input p-unique-key-rec
        , output v-field-list
        , output v-field-value-list
        ).
    case p-table-name
        :
        when "c-fbr-doc":U or when "fbr-doc"
        then
            do:
                run str/fbrdocsh.w (
                    input parparentproc
                    , input entry( 1, v-field-value-list, chr(3) )
                    ) no-error .
            end.
        when "c-sht-hist":U
        then
            do:
                DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
                run ref/cshthist.w (
                    INPUT parParentProc
                    ,input ''
                    ,input ?
                    ,input '':U
                    ,input 'one':U
                    ,INPUT entry( 1, v-field-value-list, chr(3) )
                    ,INPUT entry( 2, v-field-value-list, chr(3) )
                    ,INPUT entry( 3, v-field-value-list, chr(3) )
                    ,INPUT entry( 4, v-field-value-list, chr(3) )
                    ,INPUT '':U
                    ,INPUT-OUTPUT v-list) NO-ERROR.
            end.
        when "c-trn-doc" then
            do:
                define variable doc-rec as recid no-undo .
                find first ub.c-trn-doc where ub.c-trn-doc.doc-code = entry( 1, v-field-value-list, chr(3) ) no-error.
                if AVAILABLE (ub.c-trn-doc) then
                do:
                    doc-rec = recid(ub.c-trn-doc) .
                    run str/calldocs.w
                        (input parparentproc
                        ,input "doc"
                        ,input ""
                        ,input ""
                        ,input ?
                        ,input no
                        ,input '':U
                        ,input ub.c-trn-doc.doc-code
                        ,input ?
                        ,input doc-rec
                        ,input ub.c-trn-doc.obj-type
                        ,input ub.c-trn-doc.obj-code
                        ,output v-list
                        ) no-error .
                end.
            end.
        when "trn-doc" or when "c-trn-doc" then
            do:
                find first ub.trn-doc where ub.trn-doc.doc-code = entry( 1, v-field-value-list, chr(3) ) no-error.
                if AVAILABLE (ub.trn-doc) then
                do:
                    doc-rec = recid(ub.trn-doc) .
                    run str/calldocs.w
                        (input parparentproc
                        ,input "doc"
                        ,input ""
                        ,input ""
                        ,input ?
                        ,input no
                        ,input '':U
                        ,input ub.trn-doc.doc-code
                        ,input ?
                        ,input doc-rec
                        ,input ub.trn-doc.obj-type
                        ,input ub.trn-doc.obj-code
                        ,output v-list
                        ) no-error .
                end.
            end.
        when "rvs-doc" or when "c-rvs-doc" then
            do:
                    run str/rvscdocs.w
                    (   input        parparentproc,
                        input        "":U,
                        input        "one":U,
                        input        entry( 1, v-field-value-list, chr(3) ),
                        input-output v-list                  )
                        no-error .
        end.
        when "c-inkas" then
            do:
                find first ub.c-inkas where ub.c-inkas.inkas-code = entry( 1, v-field-value-list, chr(3) ) no-error.
                if AVAILABLE (ub.c-inkas) then
                do:
                    run str/salclist.w (
                        input parparentproc
                        ,input '':U
                        ,input 'one':U
                        ,input ub.c-inkas.inkas-code
                        ,input ub.c-inkas.host-code
                        ,input ub.c-inkas.obj-type
                        ,input ub.c-inkas.obj-code
                        ,input-output v-list    ) no-error .
                end.
            end.
        when "c-price-doc" then
            do:
                find first ub.c-price-doc where ub.c-price-doc.doc-num = entry( 1, v-field-value-list, chr(3) ) no-error.
                if AVAILABLE (ub.c-price-doc) then
                do:
                    run str/pr-cdoc.w ( parParentProc, ub.c-price-doc.host-code, ub.c-price-doc.doc-num ) no-error.
                end.
            end.
        when "price-doc" then
            do:
                find first ub.price-doc where ub.price-doc.doc-num = entry( 1, v-field-value-list, chr(3) ) no-error.
                if AVAILABLE (ub.price-doc) then
                do:
                    run str/pr-cdoc.w ( parParentProc, ub.price-doc.host-code, ub.price-doc.doc-num ) no-error.
                end.
            end.
        when "c-chk-doc" then
            do:
                find first ub.c-chk-doc where ub.c-chk-doc.doc-code = entry( 1, v-field-value-list, chr(3) ) no-error.
                if AVAILABLE (ub.c-chk-doc) then
                do:
                    run str/cchkdocs.w (
                        input parparentproc
                        , "":U
                        , "one":U
                        , ub.c-chk-doc.doc-code
                        , ub.c-chk-doc.obj-type
                        , ub.c-chk-doc.obj-code
                        , input-output v-list
                        ) no-error.
                end.
            end.
        when "chk-doc" then
            do:
                find first ub.chk-doc where ub.chk-doc.doc-code = entry( 1, v-field-value-list, chr(3) ) no-error.
                if AVAILABLE (ub.chk-doc) then
                do:
                    run str/cchkdocs.w (
                        input parparentproc
                        , "":U
                        , "one":U
                        , ub.chk-doc.doc-code
                        , ub.chk-doc.obj-type
                        , ub.chk-doc.obj-code
                        , input-output v-list
                        ) no-error.
                end.
                else
                do:
                    find first ub.c-chk-doc where ub.c-chk-doc.doc-code = entry( 1, v-field-value-list, chr(3) ) no-error.
                    if AVAILABLE (ub.c-chk-doc) then
                    do:
                        run str/cchkdocs.w (
                            input parparentproc
                            , "":U
                            , "one":U
                            , ub.c-chk-doc.doc-code
                            , ub.c-chk-doc.obj-type
                            , ub.c-chk-doc.obj-code
                            , input-output v-list
                            ) no-error.
                    end.
                end.
            end.
        when "price-doc-forming" or
        when "c-price-doc-forming" then
            do:
                run ref/cpr-form.w
                    ( parParentProc
                    ,entry( 1, v-field-value-list, chr(3) )
                    ,entry( 2, v-field-value-list, chr(3) )
                    ,entry( 3, v-field-value-list, chr(3) )
                    ,entry( 4, v-field-value-list, chr(3) )
                    ) no-error.
            end.
        when "cash-pay" then
            do:
                run ref/ccashpay.w (
                    input parparentproc
                    , INPUT "":U
                    , INPUT "one":U
                    , OUTPUT  v-list
                    , INPUT integer(entry( 1, v-field-value-list, chr(3) ))
                    , INPUT integer(entry( 2, v-field-value-list, chr(3) ))
                    , input "":U
                    ) no-error .
            end.
        when "goods" then
            do:
                run ref/cgdshisth.w (
                    input parparentproc
                    , input "":U
                    , input "one":U
                    , input integer(entry(1, v-field-value-list, chr(3)))
                    , input ?
                    , input ?
                    , input ?
                    , input ?
                    , input "":U
                    , input "":U
                    , input-output v-list  ) no-error .
            end.
        when "place" then
            do:
                run ref/cplchist.w
                    ( input parparentproc
                    , input entry(1, v-field-value-list, chr(3))
                    , input integer(entry(2, v-field-value-list, chr(3)))
                    , input "":u
                    , input "one":u
                    , input entry(1, v-field-value-list, chr(3))
                    , input integer(entry(2, v-field-value-list, chr(3)))
                    , input integer(entry(3, v-field-value-list, chr(3)))
                    , input 0
                    , input 0
                    , input 0
                    , input '':u
                    , input-output v-list
                    ) no-error .
            end.
        when "cli-grp" then
            do:
                run ref/ccgrphis.w (
                    input parparentproc
                    ,INPUT "":U
                    ,INPUT "cli-grp":U
                    ,INPUT integer(entry(1, v-field-value-list, chr(3)))
                    ,INPUT yes
                    ,OUTPUT v-list
                    ) .
            end.
        when "clients" then
            do:
                run ref/cclihisth.w (
                    input parparentproc
                    , input 0
                    , input "":U
                    , input 0
                    , input "":U
                    , "one":U
                    , input entry(1, v-field-value-list, chr(3))
                    , input integer(entry(2, v-field-value-list, chr(3)))
                    , input ?
                    , input ?
                    , input "":U
                    , input "":U
                    , input-output v-list  ) no-error .
            end.
        when "units" then
            do:
                run ref/c-units.w (
                    INPUT parparentproc
                    ,INPUT '':U
                    ,INPUT 'one':U
                    ,INPUT entry(1, v-field-value-list, chr(3))
                    ,INPUT-OUTPUT v-list) NO-ERROR.
            end.
        when "dis-card-type" then
            do:
                run ref/dcctypes.w (
                    input parparentproc
                    ,input '':U
                    ,input  ?
                    ,input  integer(entry(1, v-field-value-list, chr(3)))
                    ,input  integer(entry(3, v-field-value-list, chr(3)))
                    ,input  entry(4, v-field-value-list, chr(3))
                    ,input  integer(entry(5, v-field-value-list, chr(3)))
                    ,input  entry(2, v-field-value-list, chr(3))
                    ,input "one":U
                    ,input '':U
                    ,output v-list ) no-error.
            end.
        when "dis-card" then
            do:
                find first ub.dis-card where ub.dis-card.d-card = entry(1, v-field-value-list, chr(3)) no-error .
                if AVAILABLE (ub.dis-card) then
                do:
                    run ref/cdchisth.w (
                        INPUT parparentproc
                        ,input "":U
                        ,input "one":U
                        ,input ub.dis-card.d-card
                        ,input ub.dis-card.card-num
                        ,input ?
                        ,input "":U
                        ,input "":U
                        ,input ?
                        ,input-output v-list
                        ) no-error .
                end.
            end.
        when "cash-desk" then
            do:
                run ref/ccshlist.w (
                    input parparentproc
                    , INPUT "":U
                    , INPUT 'все':U
                    , OUTPUT  v-list
                    , INPUT integer(entry(1, v-field-value-list, chr(3)))
                    , INPUT 'маг':U
                    , INPUT integer(entry(2, v-field-value-list, chr(3)))
                    , input entry(3, v-field-value-list, chr(3))
                    , input integer(entry(4, v-field-value-list, chr(3)))
                    , input "":U
                    ) no-error.
            end.
        when "gds-grp" then
            do:
                find first ub.gds-grp no-lock where ub.gds-grp.node-code = integer(entry(1, v-field-value-list, chr(3))) no-error .
                if AVAILABLE (ub.gds-grp) then
                do:
                    run ref/cggrphis.w (
                        input parparentproc
                        ,INPUT "":U
                        ,INPUT "gds-grp":U
                        ,INPUT integer(entry(1, v-field-value-list, chr(3)))
                        , "":U
                        , INPUT 0
                        , INPUT "":U
                        , INPUT 0
                        , INPUT 0
                        , INPUT NO
                        ,input "":U
                        ,OUTPUT v-list
                        ) .
                end.
                else
                do:
                    run ref/cggrphis.w (
                        input parparentproc
                        ,INPUT "":U
                        ,INPUT "gds-grp":U
                        ,INPUT integer(entry(1, v-field-value-list, chr(3)))
                        , "":U
                        , INPUT 0
                        , INPUT "":U
                        , INPUT 0
                        , INPUT 0
                        , INPUT yes
                        ,input "":U
                        ,OUTPUT v-list
                        ) .
                end.
            end.
        when "thbj-attr" then
            do:
                run ref/cthbjatrh.w (
                    input parparentproc
                    ,input ''
                    ,input "section"
                    ,input entry(1, v-field-value-list, chr(3))
                    ,input integer(entry(2, v-field-value-list, chr(3)))
                    ,input entry(3, v-field-value-list, chr(3))
                    ,input entry(4, v-field-value-list, chr(3))
                    ,input ?
                    ,input "":U
                    ,input "":U
                    ,input-output v-rid-list  ) no-error .
            end.
        when "pl-gds" then
            do:
                run ref/cplchisth.w (
                    INPUT parParentProc
                    , input "":U
                    , input "subject":U
                    , input entry(1, v-field-value-list, chr(3))
                    , input INTEGER (entry(2, v-field-value-list, chr(3)))
                    , input INTEGER (entry(3, v-field-value-list, chr(3)))
                    , input INTEGER (entry(4, v-field-value-list, chr(3)))
                    , input 0
                    , input 0
                    , input 'pl-gds':U
                    , input-output v-list
                    ) no-error .
            end.
        when "pl-gds-pump" then
            do:
                run ref/cplchisth.w (
                    INPUT parParentProc
                    , input "":U
                    , input "subject":U
                    , input entry(1, v-field-value-list, chr(3))
                    , input INTEGER (entry(2, v-field-value-list, chr(3)))
                    , input INTEGER (entry(5, v-field-value-list, chr(3)))
                    , input INTEGER (entry(3, v-field-value-list, chr(3)))
                    , input INTEGER (entry(4, v-field-value-list, chr(3)))
                    , input 0
                    , input 'pl-gds-pump':U
                    , input-output v-list
                    ) no-error .
            end.
        when "staff" then
            do:
                run ref/cstaffsh.w (
                    input parparentproc
                    , input "":U
                    , "one":U
                    , input entry(1, v-field-value-list, chr(3))
                    , input entry(2, v-field-value-list, chr(3))
                    , input entry(3, v-field-value-list, chr(3))
                    , input integer(entry(4, v-field-value-list, chr(3)))
                    , input date(entry(5, v-field-value-list, chr(3)))
                    , input-output v-list  ) no-error .
            end.
        when "fin-bank" then
            do:
                run ref/fincbnksh.w
                    (
                    input parParentProc
                    ,input "":U
                    ,input "one":U
                    ,input integer(entry(1, v-field-value-list, chr(3)))
                    ,input integer(entry(2, v-field-value-list, chr(3)))
                    ,input-output v-list
                    ) no-error .
            end.
        when "ord-doc" then
            do:
                run cus/ordcdoch.w
                    (
                    parParentProc,
                    entry(1, v-field-value-list, chr(3)),
                    "" ) .
            end.
        when "auto-tank" then
            do:
                run str/c-auto-tn.w (
                    INPUT parParentProc
                    ,input '':U
                    ,input 'one':U
                    ,INPUT entry(1, v-field-value-list, chr(3))
                    ,INPUT-OUTPUT v-rid-list) NO-ERROR.
            end.
        when "config" then
            do:
                find first ub.config where ub.config.param-code = entry(1, v-field-value-list, chr(3)) no-error .
                if AVAILABLE (ub.config) then
                do:
                    create cnf .
                    buffer-copy ub.config to cnf .
                    assign
                        cnf.param-name = entry(1, v-field-value-list, chr(3))
                        cnf.host-code  = integer(entry(2, v-field-value-list, chr(3)))
                        cnf.obj-type   = entry(3, v-field-value-list, chr(3))
                        cnf.obj-code   = integer(entry(4, v-field-value-list, chr(3)))
                        cnf.beg-date   = date(entry(5, v-field-value-list, chr(3)))
                        cnf.end-date   = date(entry(6, v-field-value-list, chr(3)))
                        cnf.db-num     = integer(entry(7, v-field-value-list, chr(3)))
                        .
                end.
                run adm/cfg-hist.w
                    ( input parparentproc
                    ,buffer cnf
                    ) no-error .
            end.
        when "action-role" or
        when "action-role-item" then
            do:
                run ref/cactnrole.w (
                    INPUT parparentproc
                    , INPUT "":U
                    , INPUT "one":U
                    , OUTPUT  v-list
                    , INPUT INTEGER (entry(1, v-field-value-list, chr(3)))
                    , INPUT INTEGER (entry(2, v-field-value-list, chr(3)))
                    , INPUT INTEGER (entry(3, v-field-value-list, chr(3)))
                    , input "":U
                    ).
            end.
        when "c-plc-hist" then
            do:
                if entry(6, v-field-value-list, chr(3)) = "pl-gds-pump" then
                do:
                    find first ub.c-pl-gds-pump no-lock where ub.c-pl-gds-pump.chip-num = INTEGER (entry(5, v-field-value-list, chr(3))) no-error .
                    if AVAILABLE (ub.c-pl-gds-pump) then
                    do:
                        run ref/cplchisth.w (
                            INPUT parParentProc
                            , input "":U
                            , input "subject":U
                            , input ub.c-pl-gds-pump.obj-type
                            , input ub.c-pl-gds-pump.obj-code
                            , input ub.c-pl-gds-pump.pl-code
                            , input ub.c-pl-gds-pump.gds-code
                            , input ub.c-pl-gds-pump.pump-code
                            , input 0
                            , input 'pl-gds-pump':U
                            , input-output v-list
                            ) no-error .
                    end.
                end.
            end.
        when "tech-prol-pwd" then
            do:
               def var vEntity as utl.tech-prol-pwd no-undo.
               def var vRepo   as utl.repoPwd no-undo.
               def var vFrm    as utl.gpwdfrm no-undo.
               assign
                  vEntity = new utl.tech-prol-pwd()
                  vEntity:id = int64(v-field-value-list)
                  vRepo = new utl.repoPwd(vEntity)
               .
               vRepo:Refresh().
               vFrm = utl.gpwdfrm:GetObject("view",vEntity).
               wait-for vFrm:ShowDialog().
            end.
    end case.
end.
