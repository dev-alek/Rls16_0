block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-is-dynamic as logical no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-process-file-name as character no-undo .
define input parameter p-save       as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экспорт спецификации".
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
define new global shared variable g#libbcrcn as handle no-undo .
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
define temp-table cntspcie no-undo
field has-line-num as logical initial yes
field line-num as integer
field has-artic as logical initial no
field artic as character column-label "Артикул в IBS TH"
field has-prod-type as logical initial no
field prod-type as character column-label "Тип производителя в IBS TH"
field has-prod-code as logical initial no
field prod-code as integer  column-label "Код производителя в IBS TH"
field has-price-cli as logical initial no
field price-cli as decimal column-label "Цена поставщика"
field has-prc as logical initial no
field prc as decimal column-label "% отклонения в большую сторону"
field has-qnty as logical initial no
field qnty as decimal column-label "Количество"
field has-cli-base-rate as logical initial no
field cli-base-rate as decimal initial 1 column-label "Коэфф.ед.изм"
field has-vat-type as logical initial no
field vat-type as character initial 'в т. ч.':U column-label "Тип НДС"
field has-vat-pc as logical initial no
field vat-pc as decimal column-label "НДС"
field has-bonus as logical initial no
field bonus as decimal column-label "Бонус"
field has-gds-name as logical initial no
field gds-name as character  column-label "Наименование в IBS TH"
field has-qnty-cart as logical initial no
field qnty-cart as decimal column-label "Кол-во в упаковке"
field has-ext-artic as logical initial no
field ext-artic as character column-label "Артикул поставщика"
field has-price-sale as logical initial no
field price-sale as decimal column-label "Текущая цена в IBS TH"
field has-b-str as logical initial no
field b-str as character column-label "ДопБК"
FIELD has-DeadLine AS LOGICAL   INITIAL NO
FIELD DeadLine     AS INTEGER   COLUMN-LABEL "Срок хранения (дней)"
FIELD has-Obj-Name AS LOGICAL   INITIAL NO
FIELD Obj-Name     AS CHARACTER COLUMN-LABEL "Наименование производителя"
FIELD has-prc-min AS LOGICAL   INITIAL NO
FIELD prc-min     AS decimal COLUMN-LABEL "% отклонения в меньшую сторону"
index pi is unique primary line-num
.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE write-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-bonus as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
               ub.contract-specif-attr.contract-num = p-contract-num  and
               ub.contract-specif-attr.host-code    = p-host-code     and
               ub.contract-specif-attr.gds-code     = p-gds-code      and
               ub.contract-specif-attr.attr-code    = 'bonus':U
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = 'bonus':U
         .
      end.
      ub.contract-specif-attr.attr-value  = string (v-bonus) .
end.
END PROCEDURE.
PROCEDURE read-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-bonus as decimal   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = 'bonus':U
           no-error .
   if available ub.contract-specif-attr then  v-bonus = decimal (ub.contract-specif-attr.attr-value ) .
                                        else  v-bonus = 0 .
end.
END PROCEDURE.
PROCEDURE write-prc-min :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-prc-min        as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
              ub.contract-specif-attr.contract-num = p-contract-num  and
              ub.contract-specif-attr.host-code    = p-host-code     and
              ub.contract-specif-attr.gds-code     = p-gds-code      and
              ub.contract-specif-attr.attr-code    = 'prc-min':U
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = 'prc-min':U
              ub.contract-specif-attr.attr-value  = string (v-prc-min)
         .
      end.
      else do:
         ub.contract-specif-attr.attr-value  = string (v-prc-min) .
      end.
    find first ub.contract-specif exclusive-lock where
        ub.contract-specif.contract-num = p-contract-num and
        ub.contract-specif.host-code    = p-host-code    and
        ub.contract-specif.gds-code     = p-gds-code.
        ub.contract-specif.whole-send-news  = ub.contract-specif.whole-send-news + 1.
end.
END PROCEDURE.
PROCEDURE read-prc-min :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-prc-min as decimal   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = 'prc-min':U
           no-error .
   if available ub.contract-specif-attr then  v-prc-min = decimal (ub.contract-specif-attr.attr-value ) .
                                        else  v-prc-min = 0 .
end.
END PROCEDURE.
PROCEDURE write-retro-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-retro-bonus as character   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
              ub.contract-specif-attr.contract-num = p-contract-num  and
              ub.contract-specif-attr.host-code    = p-host-code     and
              ub.contract-specif-attr.gds-code     = p-gds-code      and
              ub.contract-specif-attr.attr-code    = "retro-bonus"
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = "retro-bonus"
         .
         ub.contract-specif-attr.attr-value  = v-retro-bonus no-error.
         if error-status:error then
            message "Превышен допустимый объем информации о ретро-бонусах. Удалите исторические или неактуальны периоды" view-as alert-box error.
      end.
      else do:
         ub.contract-specif-attr.attr-value  = v-retro-bonus no-error.
         if error-status:error then
            message "Превышен допустимый объем информации о ретро-бонусах. Удалите исторические или неактуальны периоды" view-as alert-box error.
      end.
    find first ub.contract-specif exclusive-lock where
        ub.contract-specif.contract-num = p-contract-num and
        ub.contract-specif.host-code    = p-host-code    and
        ub.contract-specif.gds-code     = p-gds-code.
        ub.contract-specif.whole-send-news  = ub.contract-specif.whole-send-news + 1.
end.
END PROCEDURE.
PROCEDURE read-retro-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-retro-bonus as character   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = "retro-bonus"
           no-error .
   if available ub.contract-specif-attr then  v-retro-bonus = ub.contract-specif-attr.attr-value  .
                                        else  v-retro-bonus = "" .
end.
END PROCEDURE.
define variable file-name as character no-undo .
define variable p-delimiter as character no-undo.
define variable p-start-row as integer no-undo.
define variable log-file-name                as character      no-undo init "process-edoc.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-rid                        as recid          no-undo .
define stream Outstream.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION dyneximp_export returns character (
                                              INPUT p-bh  AS HANDLE
                                             ,INPUT p-delim   AS CHARACTER
                                             ,input p-order as character
                                             ,input p-except-field-list as character
                                             ):
define variable v-fh    AS HANDLE no-undo .
define variable v-ii    AS INTEGER no-undo .
define variable iextnt  as integer no-undo .
define variable v-char   as character no-undo .
define variable carray  as character no-undo .
define variable v-result as character no-undo .
define variable v-num-fields as integer no-undo .
if p-bh:type <> "buffer" then do:
  return ?.
end.
if p-order = '' then do:
  v-num-fields = p-bh:num-fields.
end.
else do:
  v-num-fields = num-entries(p-order).
  if v-num-fields > p-bh:num-fields then do:
    return ?.
  end.
end.
_do:
do v-ii = 1 to v-num-fields:
  if p-order = '' then do:
    assign
    v-fh = p-bh:buffer-field(v-ii)
    no-error
    .
  end.
  else do:
    assign
    v-fh = p-bh:buffer-field(entry(v-ii, p-order))
    no-error
    .
  end.
  if error-status:error
  or not valid-handle(v-fh) then do:
  return ?.
  end.
  if lookup(v-fh:name, p-except-field-list) > 0 then next _do.
  if v-fh:extent = 0 then do:
    assign
    v-char = (if v-fh:buffer-value = ?
              then chr(63)
              else (if v-fh:data-type = 'character':U
                    then (if p-delim = chr(32)
                          then quoter(v-fh:buffer-value)
                          else string(v-fh:buffer-value))
                    else (if v-fh:data-type = 'raw':U
                          then ( if p-delim = chr(32)
                                 then (chr(34) + string(v-fh:buffer-value) + chr(34))
                                 else string(v-fh:buffer-value) )
                          else string(v-fh:buffer-value)
                          )
                   )
              )
     v-result = (if v-ii = 1
                 then v-char
                 else v-result + p-delim + v-char)
     .
  end.
  else do:
    do iextnt = 1 to v-fh:extent:
      assign
      v-char = (if v-fh:buffer-value(iextnt) = ?
                then chr(63)
                else (if v-fh:data-type = 'character':U
                      then (if p-delim = chr(32)
                            then quoter(v-fh:buffer-value(iextnt))
                            else string(v-fh:buffer-value(iextnt))
                            )
                      else (if v-fh:data-type = 'raw':U
                           then (if p-delim = chr(32)
                                 then (chr(34) + string(v-fh:buffer-value(iextnt)) + chr(34))
                                 else string(v-fh:buffer-value(iextnt)))
                           else string(v-fh:buffer-value(iextnt))
                           )
                      )
               )
      carray = (if iextnt = 1
                then v-char
               else carray + p-delim + v-char)
      .
    end.
    assign
    v-result = (if v-ii = 1
                then carray
               else v-result + p-delim + carray)
    .
  end.
end.
return v-result.
end FUNCTION.
procedure dyneximp_dump-import  :
define input parameter p-bh as handle no-undo .
define input parameter p-order as character no-undo .
define input parameter p-except-field-list as character no-undo .
define input parameter p-line-num-field as character no-undo .
define input parameter p-call-handle as handle no-undo .
define input parameter p-err-proc as character no-undo .
define output parameter p-num-rec as integer no-undo .
define output parameter p-num-rec-ok as integer no-undo .
define variable v-import  as character   no-undo extent 512.
define variable v-iimp    as integer     no-undo .
define variable v-ii      as integer     no-undo .
define variable v-iextnt    as integer     no-undo .
define variable v-fh      as handle      no-undo .
define variable v-result  as logical no-undo .
define variable v-line-num as integer no-undo .
define variable v-lnfh as handle no-undo .
define variable glog as logical no-undo .
define variable v-num-fields as integer no-undo .
if p-bh:type <> "buffer" then do:
  return error substitute("Неверный тип handle передан процедуре").
end.
if p-line-num-field <> '' then do:
  assign
  v-lnfh = p-bh:buffer-field(p-line-num-field)
  no-error .
  if not valid-handle(v-lnfh) then do:
    return error substitute("Нет поля &1 в таблице &2, буфер которой передан", p-line-num-field, p-bh:name).
  end.
end.
if p-order = '' then do:
  v-num-fields = p-bh:num-fields.
end.
else do:
  v-num-fields = num-entries(p-order).
end.
if v-num-fields > p-bh:num-fields then do:
  return error substitute("В переданной последовательности полей &1 число полей больше, чем в таблице &2, буффер которой передан"
                           , p-order
                           , p-bh:name
                           ).
end.
_repeat:
repeat:
  assign
  v-import = ""
  v-iimp = 0
  v-line-num = v-line-num + 1
  .
  import stream Outstream v-import.
  p-num-rec = p-num-rec + 1.
  p-bh:buffer-create().
  if valid-handle(v-lnfh) then do:
    v-lnfh:buffer-value = v-line-num.
  end.
  _do:
  do v-ii = 1 to v-num-fields:
    if p-order = '' then do:
      assign
      v-fh = p-bh:buffer-field(v-ii)
      no-error
      .
    end.
    else do:
      assign
      v-fh = p-bh:buffer-field(entry(v-ii, p-order))
      no-error
      .
    end.
    if error-status:error
    or not valid-handle(v-fh) then do:
      return error substitute("В переданной последовательности полей &1 указано несуществующее в таблице &2 поле &3"
                              , p-order
                              , p-bh:name
                              , entry(v-ii, p-order)
                              ).
    end.
    if lookup(v-fh:name, p-except-field-list) > 0 then next _do.
    if v-fh:extent = 0 then do:
      assign
      v-iimp = v-iimp + 1
      v-fh:buffer-value = v-import[v-iimp]
      no-error
      .
      if error-status:error then do:
        p-bh:buffer-delete().
        run value(p-err-proc) in p-call-handle ( input substitute("Ошибка при импорте поля &1 (&5) записи из строки &2&3&4"
                                                                , v-fh:column-label
                                                                , v-line-num
                                                                , chr(10)
                                                                , error-status:get-message(1)
                                                                , v-fh:name
                                                                )
                                                                )
                                                                .
        next _repeat.
      end.
    end.
    else do:
      do v-iextnt = 1 to v-fh:extent:
        assign
        v-iimp = v-iimp + 1
        v-fh:buffer-value(v-iextnt) = v-import[v-iimp]
        no-error
        .
        if error-status:error then do:
          p-bh:buffer-delete().
          run value(p-err-proc) in p-call-handle ( input substitute("Ошибка при импорте поля &1 (&5) записи из строки &2&3&4"
                                                                  , v-fh:column-label
                                                                  , v-line-num
                                                                  , chr(10)
                                                                  , error-status:get-message(1)
                                                                  , v-fh:name
                                                                  )
                                                                  )
                                                                .
          next _repeat.
        end.
      end.
    end.
  end.
  assign
  glog = p-bh:buffer-validate()
  no-error
  .
  if error-status:error then do:
    p-bh:buffer-delete().
    run value(p-err-proc) in p-call-handle ( substitute("Ошибка при импорте записи из строки &1&2&3"
                                                , v-line-num
                                                , chr(10)
                                                , error-status:get-message(1) )) no-error .
    next _repeat.
  end.
  p-num-rec-ok = p-num-rec-ok + 1.
end.
end procedure.
function dyneximp_import returns logical (
                                           input p-bh as handle
                                          ,input p-delim as character
                                          ,input p-str as character
                                          ,input p-order as character
                                          ,input p-except-field-list as character
                                          ,output p-mes as character
                                          ):
define variable v-entries as integer no-undo .
define variable v-num-fields as integer no-undo .
define variable v-except-fields as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-fh as handle no-undo .
define variable v-iimp as integer no-undo .
define variable v-iextnt as integer no-undo .
define variable v-created as logical no-undo .
if p-bh:type <> "buffer" then do:
  p-mes = "Для импорта передан handle неверного типа".
  return no.
end.
if p-order = '' then do:
  v-num-fields = p-bh:num-fields.
end.
else do:
  v-num-fields = num-entries(p-order) .
  if v-num-fields > p-bh:num-fields then do:
    p-mes =  substitute("В переданной последовательности полей &1 число полей больше, чем в таблице &2, буффер которой передан"
                            , p-order
                            , p-bh:name
                            ).
    return no.
  end.
end.
v-entries = num-entries(p-str, p-delim).
v-except-fields = (if p-except-field-list = '' then 0 else num-entries(p-except-field-list)).
if v-entries < v-num-fields - v-except-fields then do:
  p-mes = substitute("Количество полей в строке импорта (&1) с учетом разделителя (&2) меньше количества выбранных полей (&3)"
                     , num-entries(p-str, p-delim)
                     , p-delim
                     , v-num-fields
                    )
                   .
  return no.
end.
if p-bh:available = no then do:
  v-created = yes.
  p-bh:buffer-create().
end.
do v-ii = 1 to v-num-fields:
  if p-order = '' then do:
    assign
    v-fh = p-bh:buffer-field(v-ii)
    no-error
    .
  end.
  else do:
    assign
    v-fh = p-bh:buffer-field(entry(v-ii, p-order))
    no-error
    .
  end.
  if error-status:error
  or not valid-handle(v-fh) then do:
    p-mes = substitute("В переданной последовательности полей &1 указано несуществующее в таблице &2 поле &3"
                            , p-order
                            , p-bh:name
                            , entry(v-ii, p-order)
                            ).
    if v-created then do:
      p-bh:buffer-delete().
    end.
    return no.
  end.
  if v-fh:extent = 0 then do:
    assign
    v-iimp = v-iimp + 1
    .
    if v-iimp > v-entries - v-except-fields then do:
      p-mes = substitute("Количество полей в строке импорта (&1) с учетом разделителя (&2) меньше количества выбранных полей (&3) "
                        , num-entries(p-str, p-delim)
                        , p-delim
                        , v-num-fields
                        )
                          .
      if v-created then do:
        p-bh:buffer-delete().
      end.
      return no.
    end.
    assign
    v-fh:buffer-value = entry(v-iimp, p-str, p-delim)
    no-error
    .
    if error-status:error then do:
      if v-created then do:
        p-bh:buffer-delete().
      end.
      p-mes = substitute("Ошибка при импорте поля номер &1:&2&3"
                         , v-iimp
                         ,chr(10)
                         , error-status:get-message(1) ).
      return no.
    end.
  end.
  else do:
    do v-iextnt = 1 to v-fh:extent:
      assign
      v-iimp = v-iimp + 1
      .
      if v-iimp > v-entries - v-except-fields then do:
        p-mes = substitute("Количество полей в строке импорта (&1) с учетом разделителя (&2) меньше количества выбранных полей (&3) "
                          , num-entries(p-str, p-delim)
                          , p-delim
                          , v-num-fields
                          )
                            .
        if v-created then do:
          p-bh:buffer-delete().
        end.
        return no.
      end.
      assign
      v-fh:buffer-value(v-iextnt) = entry(v-iimp, p-str, p-delim)
      no-error
      .
      if error-status:error then do:
        if v-created then do:
          p-bh:buffer-delete().
        end.
        p-mes = substitute("Ошибка при импорте поля номер &1:&2&3"
                          , v-iimp
                          ,chr(10)
                          , error-status:get-message(1) ).
        return no.
      end.
    end.
  end.
end.
return yes.
end function.
function dyneximp_excel-col-name returns character ( input p-col as integer):
define variable v-str as character no-undo init "ABCDEFGHIJKLMNOPQRSTUVWZYX".
return substring(v-str, p-col, 1).
end.
procedure dyneximp_export-excel :
define input parameter p-filename as character no-undo .
define input parameter p-start-row as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-order as character no-undo .
define input parameter p-except-field-list as character no-undo .
define input parameter p-call-handle as handle no-undo .
define input parameter p-err-proc as character no-undo .
define output parameter p-num-rec as integer no-undo .
define output parameter p-num-rec-ok as integer no-undo .
define variable chExcelApplication as com-handle no-undo .
define variable chWorkbook         as com-handle no-undo .
define variable chWorksheet        as com-handle no-undo .
define variable chRange            as com-handle no-undo .
define variable v-last-row as integer no-undo .
define variable v-last-column as integer no-undo .
define variable v-row as integer no-undo .
define variable v-head-row as integer no-undo .
define variable v-num-fields as integer no-undo .
define variable v-ii as integer no-undo .
DEFINE VARIABLE v-dec-separ      as character no-undo .
DEFINE VARIABLE v-th-separ       as character no-undo .
define variable v-line-num as integer no-undo .
define variable v-lnfh as handle no-undo .
define variable v-fh as handle no-undo .
define variable v-text as character no-undo .
define variable v-dop as character no-undo .
define variable v-excel-general-format as character no-undo .
define variable v-excel-short-date as character no-undo .
define variable v-excel-dec-separ as character no-undo .
define variable v-excel-th-separ as character no-undo .
define variable v-excel-date-separ as character no-undo .
define variable v-qh as handle no-undo .
define variable v-print as logical no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if p-bh:type <> "buffer" then do:
    return error "Для экспорта передан handle неверного типа".
  end.
  if p-order = '' then do:
    v-num-fields = p-bh:num-fields.
  end.
  else do:
    v-num-fields = num-entries(p-order) .
    if v-num-fields > p-bh:num-fields then do:
      return error  substitute("В переданной последовательности полей &1 число полей больше, чем в таблице &2, буффер которой передан"
                              , p-order
                              , p-bh:name
                              ).
    end.
  end.
  create "Excel.Application" chExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
  assign
  chExcelApplication:interactive     = false
  chExcelApplication:ScreenUpdating  = false
  chExcelApplication:visible         = false
  chExcelApplication:DisplayAlerts   = false
  .
  assign
  v-excel-general-format =  chExcelApplication:International(26  )
  v-excel-short-date =  chExcelApplication:International(32  )
  v-excel-dec-separ = chExcelApplication:International(3  )
  v-excel-th-separ = chExcelApplication:International(4  )
  v-excel-date-separ = chExcelApplication:International(17  )
  no-error
  .
  v-head-row = maximum(p-start-row - 1, 0).
  v-row = v-head-row - 1.
  chExcelApplication:WorkBooks:Add().
  chWorkbook = chExcelApplication:WorkBooks:Item(1).
  chWorksheet = chWorkbook:ActiveSheet.
  if v-head-row > 0 then do:
    chWorkSheet:Rows(substitute("&1:&1", v-head-row)):Select.
    chExcelApplication:Selection:Font:Bold = True.
  end.
  _row:
  do while true
  on error  undo _row, retry
  on stop   undo _row, retry
  on endkey undo _row, retry
  :
    if retry then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chWorkSheet) then
RELEASE OBJECT chWorkSheet no-error.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chWorkBook) then
RELEASE OBJECT chWorkBook no-error.
      chExcelApplication:Quit() no-error.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chExcelApplication) then
RELEASE OBJECT chExcelApplication no-error.
      delete object v-qh no-error.
      return error substitute("Ошибка при экспорте в файл &1:&2&3"
                              , p-filename
                              , chr(10)
                              , error-status:get-message(1)
                              ).
    end.
    v-row = v-row + 1.
    if v-row > v-head-row then do:
      p-num-rec = p-num-rec + 1.
    end.
    do v-ii = 1 to v-num-fields:
      v-text = ''.
      if p-order = '' then do:
        assign
        v-fh = p-bh:buffer-field(v-ii)
        no-error
        .
      end.
      else do:
        assign
        v-fh = p-bh:buffer-field(entry(v-ii, p-order))
        no-error
        .
      end.
      if error-status:error
      or not valid-handle(v-fh) then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chWorkSheet) then
RELEASE OBJECT chWorkSheet no-error.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chWorkBook) then
RELEASE OBJECT chWorkBook no-error.
        chExcelApplication:Quit() no-error.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chExcelApplication) then
RELEASE OBJECT chExcelApplication no-error.
        delete object v-qh.
        return error substitute("В переданной последовательности полей &1 указано несуществующее в таблице &2 поле &3"
                                , p-order
                                , p-bh:name
                                , entry(v-ii, p-order)
                                ).
      end.
      if v-row = v-head-row then do:
        if v-ii = 1 then do:
          create query v-qh.
          v-qh:set-buffers(p-bh).
          v-qh:query-prepare( substitute(" for each &1 ", p-bh:name )) .
          v-qh:query-open().
        end.
        if v-head-row > 0 then do:
          assign
          chWorkSheet:range( substitute("&1&2", dyneximp_excel-col-name(v-ii), v-head-row)):value = v-fh:column-label
          no-error
          .
        end.
        chWorkSheet:Columns( substitute("&1:&1", dyneximp_excel-col-name(v-ii), dyneximp_excel-col-name(v-ii))):Select.
        case v-fh:data-type:
          when 'character':U then do:
            chExcelApplication:Selection:NumberFormat = "@".
          end.
          when 'date':U then do:
            case v-excel-short-date:
              when string(0) then do:
                chExcelApplication:Selection:NumberFormat = substitute("mm&1dd&1yyyy", v-excel-date-separ).
              end.
              when string(1) then do:
                chExcelApplication:Selection:NumberFormat = substitute("dd&1mm&1yyyy", v-excel-date-separ).
              end.
              when string(2) then do:
                chExcelApplication:Selection:NumberFormat = substitute("yyyy&1mm&1dddd", v-excel-date-separ).
              end.
            end case.
          end.
          when 'decimal':U then do:
            chExcelApplication:Selection:NumberFormat = replace(substitute("0.&1"
                                                                          , fill(string(0), length(entry(2, v-fh:format, ".")))
                                                                          ), ".", v-excel-dec-separ).
          end.
          when 'integer':U then do:
            chExcelApplication:Selection:NumberFormat = "0".
          end.
          when 'logical':U then do:
            chExcelApplication:Selection:NumberFormat = "@".
          end.
        end case.
      end.
      else do:
        if v-ii = 1 then do:
          v-qh:get-next() no-error.
          if v-qh:query-off-end then do:
            p-num-rec = p-num-rec - 1.
            leave _row.
          end.
        end.
        v-print = yes.
        case v-fh:data-type:
          when 'character':U then do:
            if v-fh:buffer-value = ? then do:
              v-text = chr(63).
            end.
            else do:
              assign
              v-text = v-fh:buffer-value
              .
            end.
          end.
          when 'date':U then do:
            if v-fh:buffer-value = ? then do:
              v-print = no.
            end.
            else do:
              assign
              v-dop = string(v-fh:buffer-value, "99/99/9999")
              .
              case v-excel-short-date:
                when string(0) then do:
                  assign
                  v-text = v-dop.
                end.
                when string(1) then do:
                  assign
                  v-text = entry(2, v-dop, chr(47)) + chr(47) +
                          entry(1, v-dop, chr(47)) + chr(47) +
                          entry(3, v-dop, chr(47))
                  no-error
                  .
                end.
                when string(2) then do:
                  assign
                  v-text = entry(3, v-dop, chr(47)) + chr(47) +
                          entry(1, v-dop, chr(47)) + chr(47) +
                          entry(2, v-dop, chr(47))
                  no-error
                  .
                end.
              end case.
            end.
          end.
          when 'decimal':U then do:
            if v-fh:buffer-value = ? then do:
              v-print = no.
            end.
            else do:
              assign
              v-dop = string(v-fh:buffer-value)
              v-text = replace(v-dop, ".", chr(1))
              v-text = replace(v-dop, ",", chr(2))
              v-text = replace(v-dop, chr(1), v-excel-dec-separ)
              v-text = replace(v-dop, chr(2), v-excel-th-separ)
              .
            end.
          end.
          when 'integer':U then do:
            if v-fh:buffer-value = ? then do:
              v-print = no.
            end.
            else do:
              assign
              v-text = string(v-fh:buffer-value)
              .
            end.
          end.
          when 'logical':U then do:
            if v-fh:buffer-value = ? then do:
              v-print = no.
            end.
            assign
            v-text = string(v-fh:buffer-value, "true/false")
            no-error
            .
          end.
        end case.
      end.
      if v-print then do:
        assign
        chWorkSheet:range( substitute("&1&2", dyneximp_excel-col-name(v-ii), v-row)):value = v-text
        no-error
        .
        if error-status:error then do:
          run value(p-err-proc) in p-call-handle ( input substitute("Ошибка при импорте поля &1 (&5) из строки &2:&3&4"
                                          , v-fh:column-label
                                          , v-row
                                          , chr(10)
                                          , error-status:get-message(1)
                                          , v-fh:name
                                          )) no-error .
          next _row.
        end.
      end.
    end.
    if v-row > v-head-row then do:
    p-num-rec-ok = p-num-rec-ok + 1.
    end.
  end.
  delete object v-qh no-error.
  chWorkSheet:Columns("A:Z"):Select.
  chExcelApplication:Selection:Columns:AutoFit.
  chWorkbook:SaveAs(p-filename , -4143 , "" , "", false, false , 1).
  chWorkbook:Close().
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chWorkSheet) then
RELEASE OBJECT chWorkSheet no-error.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chWorkBook) then
RELEASE OBJECT chWorkBook no-error.
  chExcelApplication:Quit() no-error.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chExcelApplication) then
RELEASE OBJECT chExcelApplication no-error.
end.
end procedure.
procedure dyneximp_import-excel:
define input parameter p-filename as character no-undo .
define input parameter p-start-row as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-order as character no-undo .
define input parameter p-except-field-list as character no-undo .
define input parameter p-line-num-field as character no-undo .
define input parameter p-call-handle as handle no-undo .
define input parameter p-err-proc as character no-undo .
define output parameter p-num-rec as integer no-undo .
define output parameter p-num-rec-ok as integer no-undo .
define variable chExcelApplication as com-handle no-undo .
define variable chWorkbook         as com-handle no-undo .
define variable chWorksheet        as com-handle no-undo .
define variable chRange            as com-handle no-undo .
define variable v-last-row as integer no-undo .
define variable v-last-column as integer no-undo .
define variable v-row as integer no-undo .
define variable v-num-fields as integer no-undo .
define variable v-ii as integer no-undo .
DEFINE VARIABLE v-dec-separ      as character no-undo .
DEFINE VARIABLE v-th-separ       as character no-undo .
define variable v-line-num as integer no-undo .
define variable v-lnfh as handle no-undo .
define variable v-fh as handle no-undo .
define variable v-text as character no-undo .
define variable v-dop as character no-undo .
define variable v-excel-general-format as character no-undo .
define variable v-excel-short-date as character no-undo .
define variable v-excel-dec-separ as character no-undo .
define variable v-excel-th-separ as character no-undo .
define variable v-excel-date-separ as character no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if p-bh:type <> "buffer" then do:
    return error "Для импорта передан handle неверного типа".
  end.
  if p-order = '' then do:
    v-num-fields = p-bh:num-fields.
  end.
  else do:
    v-num-fields = num-entries(p-order) .
    if v-num-fields > p-bh:num-fields then do:
      return error  substitute("В переданной последовательности полей &1 число полей больше, чем в таблице &2, буффер которой передан"
                              , p-order
                              , p-bh:name
                              ).
    end.
  end.
  if p-line-num-field <> '' then do:
    assign
    v-lnfh = p-bh:buffer-field(p-line-num-field)
    no-error .
    if not valid-handle(v-lnfh) then do:
      return error substitute("Нет поля &1 в таблице &2, буфер которой передан", p-line-num-field, p-bh:name).
    end.
  end.
  create "Excel.Application" chExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
  assign
  chExcelApplication:interactive     = false
  chExcelApplication:ScreenUpdating  = false
  chExcelApplication:visible         = false
  chExcelApplication:DisplayAlerts   = false
  .
  assign
  v-excel-general-format =  chExcelApplication:International(26  )
  v-excel-short-date =  chExcelApplication:International(32  )
  v-excel-dec-separ = chExcelApplication:International(3  )
  v-excel-th-separ = chExcelApplication:International(4  )
  v-excel-date-separ = chExcelApplication:International(17  )
  no-error
  .
  chWorkBook   = chExcelApplication:WorkBooks:open( p-filename ).
  chWorkSheet  = chExcelApplication:Sheets:item (1).
  assign
  v-last-row = chWorkSheet:Cells:SpecialCells(11):Row
  v-last-column = chWorkSheet:Cells:SpecialCells(11):Column
  no-error .
  if v-last-row = ? or v-last-row = 0
  then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chWorkSheet) then
RELEASE OBJECT chWorkSheet no-error.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chWorkBook) then
RELEASE OBJECT chWorkBook no-error.
     chExcelApplication:Quit() no-error.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chExcelApplication) then
RELEASE OBJECT chExcelApplication no-error.
    return error substitute("В файле не удалось определить диапазон данных по строке крайней используемой ячейки."
                            , p-filename
                            ).
  end.
  if v-last-row <= p-start-row - 1
  then do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chWorkSheet) then
RELEASE OBJECT chWorkSheet no-error.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chWorkBook) then
RELEASE OBJECT chWorkBook no-error.
    chExcelApplication:Quit() no-error.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chExcelApplication) then
RELEASE OBJECT chExcelApplication no-error.
    return error substitute("Количества строк в шапке файла &1 задано равным &2, номер последней строки в листе=&3,&4диапазон данных на листе задан неверно или данных нет."
                            , p-filename
                            , p-start-row - 1
                            , v-last-row
                            , chr(10)
                            ).
  end.
  if v-last-column = ? or v-last-column = 0
  then do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chWorkSheet) then
RELEASE OBJECT chWorkSheet no-error.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chWorkBook) then
RELEASE OBJECT chWorkBook no-error.
    chExcelApplication:Quit() no-error.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chExcelApplication) then
RELEASE OBJECT chExcelApplication no-error.
    return error substitute("В файле &1 не удалось определить диапазон данных по столбцу крайней используемой ячейки."
                            , p-filename
                            ).
  end.
  if v-last-column < v-num-fields then do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chWorkSheet) then
RELEASE OBJECT chWorkSheet no-error.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chWorkBook) then
RELEASE OBJECT chWorkBook no-error.
    chExcelApplication:Quit() no-error.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chExcelApplication) then
RELEASE OBJECT chExcelApplication no-error.
    return error substitute("В файле &1 количество используемых столбцов = &2, а количество заданных для импорта полей =&3."
                            , p-filename
                            , v-last-column
                            , v-num-fields
                            ).
  end.
  chWorkSheet:Columns("A:Z"):Select.
  chExcelApplication:Selection:Columns:AutoFit.
  _row:
  do v-row = p-start-row to v-last-row
  on error  undo _row, retry
  on stop   undo _row, retry
  on endkey undo _row, retry
  :
    if retry then do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chWorkSheet) then
RELEASE OBJECT chWorkSheet no-error.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chWorkBook) then
RELEASE OBJECT chWorkBook no-error.
      chExcelApplication:Quit() no-error.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chExcelApplication) then
RELEASE OBJECT chExcelApplication no-error.
      return error substitute("Ошибка при импорте из файла &1:&2&3"
                              , p-filename
                              , chr(10)
                              , error-status:get-message(1)
                              ).
    end.
    v-line-num = v-line-num + 1.
    p-num-rec = p-num-rec + 1.
    p-bh:buffer-create().
    if valid-handle(v-lnfh) then do:
      v-lnfh:buffer-value = v-line-num.
    end.
    do v-ii = 1 to v-num-fields:
      v-text = ''.
      assign
      v-text = chWorkSheet:range( substitute("&1&2", dyneximp_excel-col-name(v-ii), v-row)):text
      .
      if p-order = '' then do:
        assign
        v-fh = p-bh:buffer-field(v-ii)
        no-error
        .
      end.
      else do:
        assign
        v-fh = p-bh:buffer-field(entry(v-ii, p-order))
        no-error
        .
      end.
      if error-status:error
      or not valid-handle(v-fh) then do:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chWorkSheet) then
RELEASE OBJECT chWorkSheet no-error.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chWorkBook) then
RELEASE OBJECT chWorkBook no-error.
        chExcelApplication:Quit() no-error.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chExcelApplication) then
RELEASE OBJECT chExcelApplication no-error.
        return error substitute("В переданной последовательности полей &1 указано несуществующее в таблице &2 поле &3"
                                , p-order
                                , p-bh:name
                                , entry(v-ii, p-order)
                                ).
      end.
      case v-fh:data-type:
        when 'character':U then do:
          assign
          v-fh:buffer-value =  v-text
          no-error
          .
        end.
        when 'date':U then do:
          assign
          v-dop = replace(v-text, v-excel-date-separ, chr(47))
          no-error
          .
          case v-excel-short-date:
            when string(0) then do:
              assign
              v-fh:buffer-value =  date(integer(entry(1, v-dop, chr(47)))
                                       ,integer(entry(2, v-dop, chr(47)))
                                       ,integer(entry(3, v-dop, chr(47)))
                                       )
              no-error
              .
            end.
            when string(1) then do:
              assign
              v-fh:buffer-value =  date(integer(entry(2, v-dop, chr(47)))
                                       ,integer(entry(1, v-dop, chr(47)))
                                       ,integer(entry(3, v-dop, chr(47)))
                                       )
              no-error
              .
            end.
            when string(2) then do:
              assign
              v-fh:buffer-value =  date(integer(entry(2, v-dop, chr(47)))
                                       ,integer(entry(3, v-dop, chr(47)))
                                       ,integer(entry(1, v-dop, chr(47)))
                                       )
              no-error
              .
            end.
          end case.
        end.
        when 'decimal':U then do:
          v-dop = replace(v-text, v-excel-th-separ, "").
          v-dop = replace(v-dop, v-excel-dec-separ, ".").
          assign
          v-fh:buffer-value = decimal(v-dop)
          no-error
          .
        end.
        when 'integer':U then do:
          assign
          v-dop = replace(v-text, v-excel-th-separ, "").
          v-fh:buffer-value = integer(v-dop)
          no-error
          .
        end.
        when 'logical':U then do:
          assign
          v-fh:buffer-value = logical(v-dop)
          no-error
          .
        end.
      end case.
      if error-status:error then do:
         p-bh:buffer-delete().
         run value(p-err-proc) in p-call-handle ( input substitute("Ошибка при импорте поля &1 (&5) из строки &2:&3&4"
                                        , v-fh:column-label
                                        , v-row
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , v-fh:name
                                        )) no-error .
        next _row.
      end.
    end.
    p-num-rec-ok = p-num-rec-ok + 1.
  end.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chWorkSheet) then
RELEASE OBJECT chWorkSheet no-error.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chWorkBook) then
RELEASE OBJECT chWorkBook no-error.
  chExcelApplication:Quit() no-error.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(chExcelApplication) then
RELEASE OBJECT chExcelApplication no-error.
end.
end procedure.
define stream logstream .
define variable my-mess as char.
define variable num-rec as integer.
define variable num-rec-ok as integer.
define variable ii as integer.
define variable dopdec as decimal no-undo.
define variable v-return-value as character no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type as character no-undo.
define variable v-ask as logical no-undo .
define variable v-write-hist as logical no-undo .
define variable v-order as character no-undo .
define variable v-bar-code as integer no-undo .
define variable glog as logical no-undo .
define variable v-mess as character no-undo .
define variable v-cntspcie as handle no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-contract-code as integer no-undo .
define variable v-contract-cli-type as character no-undo .
define variable v-contract-cli-code as integer no-undo .
define variable v-str as character no-undo .
define variable v-bonus as decimal no-undo .
define variable v-price-sale as decimal no-undo .
DEFINE VARIABLE v-cList-DopBK as CHARACTER NO-UNDO INITIAL "".
define variable v-prc-min as decimal no-undo.
define buffer buf_prod-bc  for ub.prod-bc.
define buffer buf_bar-code  for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_contract for ub.contract.
define buffer buf_contract-specif for ub.contract-specif.
define buffer buf_ext-artic for ub.ext-artic.
DEFINE BUFFER buf_Clients   FOR ub.Clients.
define shared temp-table tt0-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_rule-call-param for tt0-rule-call-param.
run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error.
if error-status:error then do:
    run write-log-and-file in p-log-handle (             input 1           , input log-file-name           , input 1           , input substitute("Ошибка при подготовке к экспорту данных из спецификацию:&1&2&1&3"                            , chr(10)                            , error-status:get-message(1)                             , return-value )).
  v-view-log = yes.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При экспорте информации произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action35   as character no-undo .
  define variable v-printed35       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При экспорте информации произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'process-edoc.txt')
    ,input  7
    ,output v-user-action35
    ,output v-printed35
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'process-edoc.txt').
end.
                        return.
end.
empty temp-table cntspcie.
v-cntspcie = buffer cntspcie:handle.
for each buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-fields"
and buf_rule-call-param.p-index > 0
by buf_rule-call-param.p-index
:
  v-order = v-order + (if v-order = '' then '' else chr(44)) + entry(2, buf_rule-call-param.param-value-character, ".").
end.
run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
if p-ruleset-id = 223 then do:
    run write-log-and-file in p-log-handle (             input 1           , input log-file-name           , input 1           , input substitute("Экспорт данных в файл &1", file-name)).
  output stream Outstream to value(file-name).
end.
else do:
    run write-log-and-file in p-log-handle (             input 1           , input log-file-name           , input 1           , input substitute("Подготовка данных для экспорта")).
end.
_stroka:
for each buf_contract-specif no-lock where
        buf_contract-specif.host-code = v-current-host-code
    and buf_contract-specif.contract-num = v-contract-code
on error  undo _stroka, retry
on stop   undo _stroka, retry
on endkey undo _stroka, retry
:
  if retry then do:
    my-mess = substitute("&1 (товар &2)", v-mess, buf_contract-specif.gds-code).
        run write-log-and-file in p-log-handle (             input 1           , input log-file-name           , input 1           , input v-mess).
    v-view-log = yes.
    next _stroka.
  end.
  num-rec = num-rec + 1.
  find first buf_goods no-lock where
            buf_goods.gds-code = buf_contract-specif.gds-code no-error.
  if not available buf_goods then do:
    v-mess = substitute("Не найден товар с кодом &1!", buf_contract-specif.gds-code).
    v-view-log = yes.
    undo _stroka, retry _stroka.
  end.
  run read-bonus in this-procedure ( input buf_contract-specif.contract-num
                                    , input buf_contract-specif.host-code
                                    , input buf_contract-specif.gds-code
                                    , output v-bonus
                                    ) no-error .
  if error-status:error then do:
    v-mess = substitute("Ошибка при попытке получения значения бонуса!&1&2&1&4"
                          ,chr(10)
                          , error-status:get-message(1)
                          , return-value
                          ).
    v-view-log = yes.
    undo _stroka, retry _stroka.
  end.
  run read-prc-min in this-procedure ( input buf_contract-specif.contract-num
                                    , input buf_contract-specif.host-code
                                    , input buf_contract-specif.gds-code
                                    , output v-prc-min
                                    ) no-error .
  if error-status:error then do:
    v-mess = substitute("Ошибка при попытке получения значения % отклонения в меньшую сторону!&1&2&1&4"
                          ,chr(10)
                          , error-status:get-message(1)
                          , return-value
                          ).
    v-view-log = yes.
    undo _stroka, retry _stroka.
  end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_contract-specif.gds-code
  ,input  ?
  ,output v-bar-code
  ) no-error .
  if error-status:error then do:
    v-mess = substitute("Ошибка при попытке получения корневого бар-кода товара!&1&2&1&4"
                          ,chr(10)
                          , error-status:get-message(1)
                          , return-value
                          ).
    v-view-log = yes.
    undo _stroka, retry _stroka.
  end.
  find first buf_ext-artic where
            buf_ext-artic.cli-type   = v-contract-cli-type
        and buf_ext-artic.cli-code   = v-contract-cli-code
        and buf_ext-artic.gds-code   = buf_contract-specif.gds-code
        and buf_ext-artic.status_    <> 'удал':U no-error .
  ASSIGN
     v-cList-DopBK = "".
  FOR EACH buf_prod-bc WHERE
           buf_prod-bc.b-code = v-bar-code
      NO-LOCK:
      ASSIGN
         v-cList-DopBK = v-cList-DopBK + (IF v-cList-DopBK = "" THEN "" ELSE "," ) + buf_prod-bc.b-str.
  END.
  FIND FIRST buf_Clients WHERE
             buf_Clients.obj-type = buf_contract-specif.prod-type
         AND buf_Clients.obj-code = buf_contract-specif.prod-code
       NO-LOCK NO-ERROR.
  create cntspcie.
  assign
  cntspcie.line-num = num-rec
  cntspcie.artic  = buf_contract-specif.artic
  cntspcie.prod-type  = buf_contract-specif.prod-type
  cntspcie.prod-code  = buf_contract-specif.prod-code
  cntspcie.price-cli  = buf_contract-specif.price-cli
  cntspcie.prc        = buf_contract-specif.prc
  cntspcie.qnty       = buf_contract-specif.qnty
  cntspcie.cli-base-rate = buf_contract-specif.cli-base-rate
  cntspcie.vat-type   = buf_contract-specif.vat-type
  cntspcie.vat-pc     = buf_contract-specif.vat-pc
  cntspcie.gds-name   = buf_goods.gds-name
  cntspcie.qnty-cart  = buf_goods.qnty-cart
  cntspcie.ext-artic  = (if available buf_ext-artic
                          then buf_ext-artic.ext-artic
                          else '')
  cntspcie.price-sale = v-price-sale
  cntspcie.b-str      = v-cList-DopBK
  cntspcie.bonus      =  v-bonus
  CntSpcIE.DeadLine   = buf_Goods.DeadLine
  CntSpcIE.Obj-Name   = (IF AVAILABLE buf_Clients THEN buf_Clients.Obj-Name ELSE "" )
  cntspcie.prc-min    = v-prc-min
  .
  if p-ruleset-id = 223 then do:
    v-str = dyneximp_export  (
                              INPUT v-cntspcie
                              ,INPUT p-delimiter
                              ,input v-order
                              ,input ''
                              ) no-error.
    if error-status:error then do:
      v-mess = substitute("Строчка &1 не проэкспортирована!&2&3"
                            ,num-rec
                            ,chr(10)
                            ,v-mess).
      v-view-log = yes.
      undo _stroka, retry _stroka.
    end.
    put stream outstream unformatted v-str skip.
    num-rec-ok = num-rec-ok + 1.
    run show-counter in p-log-handle .
    run write-counter in p-log-handle (substitute("Просмотрено &1 из них экспортировано &2"
                                                , num-rec
                                                , num-rec-ok
                                                )) no-error.
    delete cntspcie.
    run get-stop-state in p-log-handle (
        output v-stop
    ).
    if v-stop then do:
      leave _stroka.
    end.
  end.
  else do:
    release cntspcie.
  end.
end.
if v-stop then do:
    run write-log-and-file in p-log-handle (             input 1           , input log-file-name           , input 1           , input v-mess).
  v-view-log = yes.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При экспорте информации произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action37   as character no-undo .
  define variable v-printed37       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При экспорте информации произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'process-edoc.txt')
    ,input  7
    ,output v-user-action37
    ,output v-printed37
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'process-edoc.txt').
end.
                        return.
end.
if p-ruleset-id = 223 then do:
  output stream Outstream close.
    run write-log-and-file in p-log-handle (             input 1           , input log-file-name           , input 1           , input substitute("Запись данных в файл &1 завершена: из &2 записей успешно записано &3"                         , file-name                         , num-rec                           , num-rec-ok                         )).
end.
num-rec = 0.
if p-ruleset-id = 225 then do:
  run dyneximp_export-excel in this-procedure (
                                              input file-name
                                             ,input p-start-row
                                             ,input v-cntspcie
                                             ,input v-order
                                             ,input ''
                                             ,input this-procedure:handle
                                             ,input "cb_err"
                                             ,output num-rec
                                             ,output num-rec-ok
                                             ) no-error.
  output stream Outstream close.
    run write-log-and-file in p-log-handle (             input 1           , input log-file-name           , input 1           , input substitute("Запись данных в файл &1 завершена: из &2 записей успешно записано &3"                         , file-name                         , num-rec                           , num-rec-ok                         )).
end.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При экспорте информации произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action39   as character no-undo .
  define variable v-printed39       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При экспорте информации произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'process-edoc.txt')
    ,input  7
    ,output v-user-action39
    ,output v-printed39
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'process-edoc.txt').
end.
                        return.
procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for tt0-rule-call-param.
define buffer buf_contract for ub.contract.
do
on error undo, return error
:
  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-delimiter"
 no-error.
if available buf_rule-call-param then do:
assign p-delimiter = buf_rule-call-param.param-value-character.
end.
  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-start-row"
 no-error.
if available buf_rule-call-param then do:
assign p-start-row = buf_rule-call-param.param-value-integer.
end.
    case p-ruleset-id:
      when 223
      or
      when 225
      then do:
        assign
        v-current-host-code = p-host-code
        v-contract-code = integer(p-doc-code)
        file-name  = p-process-file-name
        .
        find first buf_contract exclusive-lock where
                  buf_contract.host-code = v-current-host-code
              and buf_contract.contract-code = v-contract-code no-error.
        if not available  buf_contract then do:
           undo, return error substitute("Не найден договор № &1 (по фирме &2)", v-contract-code, v-current-host-code).
        end.
        assign
        v-contract-cli-type = buf_contract.cli-type
        v-contract-cli-code = buf_contract.cli-code
        .
      end.
      otherwise do:
      end.
    end case.
    assign
    file-name            = p-process-file-name
    .
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref-type40 as character no-undo.
varscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref
  ,output varscales-pref-type40
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type40 as character no-undo.
varpgscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref
  ,output varpgscales-pref-type40
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
  end.
end procedure.
procedure cb_err :
define input parameter p-err-mess as character no-undo .
do
on error undo, return error
:
    run write-log-and-file in p-log-handle (             input 1           , input log-file-name           , input 1           , input p-err-mess).
  v-view-log = yes.
end.
end procedure.
