block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-param-data-type as character no-undo .
define input parameter p-param-2-data-type as character no-undo .
define input parameter p-param-3-data-type as character no-undo .
define input parameter p-p-index as integer no-undo .
define input-output parameter p-value-character as character no-undo .
define input-output parameter p-value-data as date no-undo .
define input-output parameter p-value-decimal as decimal no-undo .
define input-output parameter p-value-integer as integer no-undo .
define input-output parameter p-value-logical as integer no-undo .
define output parameter p-ok as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: 993a05482fd8, 1104, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:53 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rule-dtt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/rule-dtt.p $":U .
define variable vss-description as character no-undo init "Обработка сложных типов данных для параметров правил".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable v-rid-list as character no-undo .
define variable v-ok as logical no-undo .
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer no-undo .
define variable v-mess as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define variable glog as logical no-undo .
define variable v-chk-type as character no-undo .
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-kk as integer no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    if lookup(p-mode, 'ПРОВЕРКА':U + chr(44) + 'ИЗМЕНЕНИЕ':U) = 0 then do:
      message
      "Неправильное значение параметра p-mode" p-mode
      view-as alert-box error .
      undo, return error .
    end.
    if p-p-index = 0
    and (lookup("LIST", p-param-3-data-type) > 0
         or
         lookup("SORTED-LIST", p-param-3-data-type) > 0
         )
    then do:
       assign
       p-ok = yes.
       return '':U.
    end.
    if p-mode <> 'ПРОВЕРКА':U then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    end.
    if p-param-2-data-type = 'shop':U  then do:
      define buffer buf_shop for ub.shop.
      find first buf_shop no-lock where
                buf_shop.obj-code = p-value-integer no-error.
      if available buf_shop then do:
        if p-mode = 'ПРОВЕРКА':U then do:
          p-ok = yes.
          return '':U.
        end.
        v-rid-list = string(recid(buf_shop)).
      end.
      else do:
        if p-mode = 'ПРОВЕРКА':U then do:
          undo, return error substitute("Нет магазина с кодом &1", p-value-integer).
        end.
        v-rid-list = '':U.
      end.
      run adm/shops.w ( input parparentproc
                      , input "b-sel"
                      , input-output v-rid-list
                      , no).
      if v-rid-list = '':U
      or v-rid-list = string(recid(buf_shop)) then return error.
      find first buf_shop no-lock where
                recid(buf_shop) = integer(v-rid-list) no-error.
      if not available buf_shop then return error.
      assign
      p-value-integer = buf_shop.obj-code
      p-ok = yes
      .
    end.
if entry(1, p-param-2-data-type, "_") = 'sysconf':U then do:
      define buffer buf_sysconf for ub.sysconf.
      find first buf_sysconf no-lock
                        where buf_sysconf.host-code = p-value-integer no-error.
      if available buf_sysconf then do:
        if p-mode = 'ПРОВЕРКА':U then do:
          p-ok = yes.
          return '':U.
        end.
        v-rid-list = string(recid(buf_sysconf)).
      end.
      else do:
        if p-mode = 'ПРОВЕРКА':U then do:
          if num-entries(p-param-2-data-type, "_") > 1
          and entry(2, p-param-2-data-type, "_") = "0" then do:
            p-ok = yes.
            return '':U.
          end.
          undo, return error substitute("Нет фирмы с кодом &1", p-value-integer).
        end.
        v-rid-list = '':U.
      end.
      define variable v-firm-code as integer no-undo .
      run adm/sconfs.w (
            input parParentProc
          , input "b-sel":U
          , input no
          , input 0
          , output v-firm-code
          , input-output v-rid-list
      ) no-error.
      if v-rid-list = '':U
      or v-rid-list = string(recid(buf_sysconf)) then do:
        if num-entries(p-param-2-data-type, "_") > 1
        and entry(2, p-param-2-data-type, "_") = "0" then do:
          assign
          p-value-integer = 0
          p-ok = yes
          .
          return ''.
        end.
        return error.
      end.
      find first buf_sysconf no-lock where
                recid(buf_sysconf) = integer(v-rid-list) no-error.
      if not available buf_sysconf then return error.
      assign
      p-value-integer = buf_sysconf.host-code
      p-ok = yes
      .
    end.
    if p-param-2-data-type = 'clients':U
    or p-param-2-data-type = 'clients':U  + "_null"
    or p-param-2-data-type = "objects"
    then do:
      define buffer buf_clients for ub.clients.
      find first buf_clients no-lock where
                buf_clients.obj-type = substring(p-value-character, 1, 3)
            and buf_clients.obj-code = integer(substring(p-value-character, 4)) no-error.
      if available buf_clients then do:
        if p-mode = 'ПРОВЕРКА':U then do:
          p-ok = yes.
          return '':U.
        end.
        v-rid-list = string(recid(buf_clients)).
      end.
      else do:
        if p-mode = 'ПРОВЕРКА':U then do:
          if p-param-2-data-type = 'clients':U  + "_null"
          and p-value-character = "0" then do:
            p-ok = yes.
            return '':U.
          end.
          else do:
            undo, return error substitute("Нет клиента &1", p-value-character).
          end.
        end.
        v-rid-list = '':U.
      end.
      run ref/selcli.p (
                        input  parparentproc
                       ,input ?
                       ,input (if p-param-2-data-type = "objects"
                               then 'объект':U
                               else 'чел':U)
                       ,input (if p-param-2-data-type = "objects"
                               then yes
                               else no)
                       ,output v-ok
                       ,output v-cli-type
                       ,output v-cli-code ) no-error.
      if error-status:error then return error.
      if v-ok = no then do:
        if p-param-2-data-type = 'clients':U  + "_null"
        then do:
          message
          "Вы хотите оставить ПУСТОЕ значение параметра?"
          view-as alert-box question buttons yes-no update glog.
          if glog then do:
              assign
              p-value-character = "0"
              p-ok = yes
              .
              return ''.
           end.
           else do:
             return error .
           end.
        end.
        else do:
          return error.
        end.
      end.
      assign
      p-value-character = v-cli-type + string(v-cli-code)
      p-ok = yes
      .
    end.
    if p-param-2-data-type = 'cli-grp':U  then do:
      define buffer buf_cli-grp for ub.cli-grp.
      find first buf_cli-grp no-lock where
                buf_cli-grp.node-code = p-value-integer no-error.
      if available buf_cli-grp
      and not can-find(ub.cli-grp where ub.cli-grp.upper-code = buf_cli-grp.node-code) then do:
        if p-mode = 'ПРОВЕРКА':U then do:
          p-ok = yes.
          return '':U.
        end.
        v-rid-list = string(recid(buf_cli-grp)).
      end.
      else do:
        if p-mode = 'ПРОВЕРКА':U then do:
          undo, return error substitute("Нет группы клиентов с вн.кодом группы &1 или эта группа НЕтерминальная", p-value-integer).
        end.
        v-rid-list = '':U.
      end.
      run ref/cli-grps.w ( input parparentproc
                        ,input ('терм':U + ",b-sel")
                        ,input-output v-rid-list ).
      if v-rid-list = '':U then return error.
      find first buf_cli-grp no-lock where
                recid(buf_cli-grp) = integer(v-rid-list) no-error.
      if not available buf_cli-grp then return error.
      assign
      p-value-integer = buf_cli-grp.node-code
      p-ok = yes
      .
    end.
    if p-param-2-data-type = 'r-b':U then do:
      if p-value-character = 'rubl':U
      or p-value-character = 'base':U then do:
        if p-mode = 'ПРОВЕРКА':U then do:
          p-ok = yes.
          return '':U.
        end.
      end.
      else do:
        if p-mode = 'ПРОВЕРКА':U then do:
          undo, return error substitute("Неверное значение типа валюты продаж  = &1", p-value-character).
        end.
      end.
      run gbl/s-r-b.w ( input "Выбор типа валюты накоплений"
                      ,input-output p-value-character
                      ,output v-ok ) no-error.
      if not v-ok then return error.
      assign
      p-value-character = p-value-character
      p-ok = yes
      .
    end.
    if entry(1, p-param-2-data-type, "_") = 'period-type':U then do:
      if lookup(p-value-character, 'day,week,month,year,hour,hour-last,shift,shift-last,yesterday,week-last,month-last,year-last,halfyear,halfyear-last,quarter,quarter-last':U) > 0 then do:
        if p-mode = 'ПРОВЕРКА':U then do:
          p-ok = yes.
          return '':U.
        end.
      end.
      else do:
        if p-mode = 'ПРОВЕРКА':U then do:
          undo, return error substitute("Неверное значение типа периода  = &1", p-value-character).
        end.
      end.
      run gbl/period-t.w ( input "Выбор типа периода"
                       ,input (if num-entries(p-param-2-data-type, "_") > 1
                         then entry(2, p-param-2-data-type, "_")
                         else '')
                      ,input-output p-value-character
                      ,output v-ok ) no-error.
      if not v-ok then return error.
      assign
      p-value-character = p-value-character
      p-ok = yes
      .
    end.
    if entry(1, p-param-2-data-type, "_") = 'output-type':U then do:
      v-kk = 0.
      _ii:
      do v-ii = 1 to num-entries(p-value-character):
        do v-jj = 1 to num-entries(entry(2, p-param-2-data-type, "_")):
           if lookup(entry(v-ii, p-value-character)
                   , entry(v-jj, entry(2, p-param-2-data-type, "_"))) > 0 then do:
             v-kk = v-kk + 1.
             next _ii.
           end.
        end.
      end.
      if v-kk >= num-entries(p-value-character) then do:
        if p-mode = 'ПРОВЕРКА':U then do:
          p-ok = yes.
          return '':U.
        end.
      end.
      else do:
        if p-mode = 'ПРОВЕРКА':U then do:
          undo, return error substitute("Неверное значение типа периода  = &1", p-value-character).
        end.
      end.
      run gbl/output-t.w ( input "Выбор типа периода"
                       ,input (if num-entries(p-param-2-data-type, "_") > 1
                         then entry(2, p-param-2-data-type, "_")
                         else '')
                      ,input-output p-value-character
                      ,output v-ok ) no-error.
      if not v-ok then return error.
      assign
      p-value-character = p-value-character
      p-ok = yes
      .
    end.
    if p-param-2-data-type begins ('dis-rule':U + "_") then do:
      define variable v-sts as integer no-undo .
      define variable v-templ-rl-root as integer no-undo .
      define buffer buf_dis-rule for ub.dis-rule.
      v-templ-rl-root = integer(entry(2, p-param-2-data-type, "_")).
      find first buf_dis-rule no-lock where
                buf_dis-rule.rule-num = p-value-integer   no-error.
      if available buf_dis-rule then do:
        if p-mode = 'ПРОВЕРКА':U then do:
          p-ok = yes.
          return '':U.
        end.
        v-rid-list = string(recid(buf_dis-rule)).
      end.
      else do:
        if p-mode = 'ПРОВЕРКА':U then do:
          undo, return error substitute("Нет правила скидок с кодом &1", p-value-integer).
        end.
        v-rid-list = '':U.
      end.
      run ref/dis-ruls.w (   input  parparentproc
                            ,input 0
                            ,input '':U
                            ,input 0
                            ,input "b-sel,b-add"
                            ,input "upper-rule-num"
                            ,input v-templ-rl-root
                            ,input ?
                            ,input 0
                            ,input-output v-sts
                            ,input-OUTPUT v-rid-list) NO-ERROR.
      if v-rid-list <> '':U then do:
        find first buf_dis-rule no-lock where
                  recid(buf_dis-rule) = integer(v-rid-list) no-error.
        if not available buf_dis-rule then return error substitute("Не найдено правило скидки c recid &1", v-rid-list).
        assign
        p-value-integer = buf_dis-rule.rule-num
        p-ok = yes
        .
      end.
    end.
    if p-param-2-data-type begins ('prop-ref':U + "_") then do:
      define variable v-dtm-code as integer no-undo init -1.
      define buffer buf_prop-ref for ub.prop-ref.
      assign
      v-dtm-code = integer(entry(2, p-param-2-data-type, "_"))
      no-error
      .
      find first buf_prop-ref no-lock where
          buf_prop-ref.dtm-code = v-dtm-code
      and buf_prop-ref.sum-id = p-value-character no-error .
      if available buf_prop-ref then do:
        if p-mode = 'ПРОВЕРКА':U then do:
          p-ok = yes.
          return '':U.
        end.
        assign
        v-rid-list = string(recid(buf_prop-ref)).
      end.
      else do:
        if p-mode = 'ПРОВЕРКА':U then do:
          undo, return error substitute("Нет среза с идентификатором &1 для объекта-операнда &2", p-value-character, v-dtm-code).
        end.
        v-rid-list = '':U.
      end.
      run ref/proprefs.w (   input  parparentproc
                            ,input "b-sel,b-add"
                            ,input "dtm-code"
                            ,input  v-dtm-code
                            ,input '':U
                            ,input '':U
                            ,input-OUTPUT v-rid-list) NO-ERROR.
      if v-rid-list <> '':U then do:
        find first buf_prop-ref no-lock where
                  recid(buf_prop-ref) = integer(v-rid-list) no-error.
        if not available buf_prop-ref then return error substitute("Не найден Итог/срез c recid &1", v-rid-list).
        assign
        p-value-character = buf_prop-ref.sum-id
        p-ok = yes
        .
      end.
    end.
    if p-param-2-data-type begins 'ext-system':U then do:
      define variable v-uniq-key-rec as character no-undo .
      define variable v-tbl-row as rowid no-undo .
      define variable v-tbl-name as character no-undo .
      define buffer buf_ext-system for ub.ext-system.
      if p-value-integer <> 0 then do:
        find first buf_ext-system no-lock where
                  buf_ext-system.db-num = 0
              and buf_ext-system.esys-id = p-value-integer no-error.
        if available buf_ext-system
        and buf_ext-system.esys-type > integer('0':U)
        and (num-entries(p-param-2-data-type, "_") = 1
             or
             buf_ext-system.esys-type = integer(entry(2,  p-param-2-data-type, "_"))
             )
        then do:
          if p-mode = 'ПРОВЕРКА':U then do:
            p-ok = yes.
            return '':U.
          end.
          run gen-key-rec in this-procedure (
                                              input 'ext-system':U
                                              ,input buffer buf_ext-system:handle
                                              ,output v-uniq-key-rec) .
        end.
        else do:
          if p-mode = 'ПРОВЕРКА':U then do:
            undo, return error substitute("Нет Внешней системы с идентификатором &1  для  ГБД", p-value-integer).
          end.
          v-rid-list = '':U.
        end.
      end.
      run bge/oxmlexts.p (
            input parparentproc
          , input 2
          , input (if num-entries(p-param-2-data-type, "_") = 1
                   then substitute("esys-type > &1", '0':U)
                   else substitute("esys-type = &1", entry(2, p-param-2-data-type, "_" ))
                   )
          , input v-uniq-key-rec
          , output v-rid-list
          , output v-ok
      ).
      if v-ok then do:
        run gen-row-keyr in this-procedure
          ( input v-rid-list
           ,input ?
           ,input "ub"
           ,input ?
           ,input no-lock
           ,output v-tbl-row
           ,output v-tbl-name
         ).
        find first buf_ext-system no-lock where
                  rowid(buf_ext-system) = v-tbl-row.
        if num-entries(p-param-2-data-type, "_") = 1 then do:
          if not (buf_ext-system.esys-type > integer('0':U)) then do:
          message
          "Нужно выбрать ВНЕШНЮЮ СИСТЕМУ типа СПЕЦИАЛЬНЫЙ"
          view-as alert-box error .
          undo, return error.
        end.
        end.
        else do:
          if not (buf_ext-system.esys-type = integer(entry(2, p-param-2-data-type, "_"))) then do:
                        message
            substitute("Нужно выбрать ВНЕШНЮЮ СИСТЕМУ типа &1", entry (lookup (entry(2, p-param-2-data-type, "_"), '0,1,2,3,4,5,6,7,8,9,10,11,12':U), 'НЕспециальная,Специальная,IBS TH,Oracle Retail,Lantab,EDOC-НН,Панель Руководителя,ДатаКрат DKLink,1C,EDI,Меркурий,ИС МОТП,ИС Диадок':U))
            view-as alert-box error .
            undo, return error.
          end.
        end.
        assign
        p-value-integer = buf_Ext-system.esys-id
        p-ok = yes
        .
      end.
    end.
    if p-param-2-data-type = "file" then do:
      define variable v-path                    as character                no-undo .
      DEFINE VARIABLE v-full-path               as character                no-undo .
      DEFINE VARIABLE v-file-name               as character                no-undo .
      DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
      DEFINE VARIABLE v-file-name-ext           as character                no-undo .
      run gbl/filename.p (
               input p-value-character
              ,output v-full-path
              ,output v-path
              ,output v-file-name
              ,output v-file-name-no-ext
              ,output v-file-name-ext
              ) no-error .
      if not error-status:error then do:
        assign
        p-ok = yes
        .
      end.
    end.
    if p-param-2-data-type = "xsd"
    and p-param-data-type = 'character':U
    then do:
      define buffer buf_clob-bind for ub.clob-bind.
      find first buf_clob-bind no-lock where
                buf_clob-bind.uniq-key-rec = p-value-character
            and buf_clob-bind.resource-type = 'gate':U no-error.
      if not error-status :error then do:
        assign
        p-ok = yes
        .
      end.
    end.
    if lookup(p-param-2-data-type, 'gds-discnt-role,subtotal-discnt-role,pay-discnt-role':U) > 0  then do:
      if not p-call-id begins 'thbj-attr':U then do:
        undo, return error substitute("Неверный тип-2 параметра &1 для вызова &2"
                                      , p-param-2-data-type
                                      , p-call-id).
      end.
      run gen-key-fv  in this-procedure (
                                         input p-call-id
                                        ,output v-field-list
                                        ,output v-value-list
                                        ).
      if p-mode = 'ПРОВЕРКА':U then do:
        if p-value-character = '' then return.
        find first buf_dis-cfg-rule no-lock where
                  buf_dis-cfg-rule.pos-type = entry(2, entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)), "_")
              and buf_dis-cfg-rule.discnt-role = p-value-character no-error.
        if available buf_dis-cfg-rule then do:
          assign
          p-ok = yes
          .
        end.
        return.
      end.
      define variable v-subject-type as character no-undo .
      case p-param-2-data-type:
        when 'gds-discnt-role':U then do:
          assign
          v-subject-type = '1':U.
        end.
        when 'subtotal-discnt-role':U then do:
          assign
          v-subject-type = '2':U.
        end.
        when 'pay-discnt-role':U then do:
          assign
          v-subject-type = '5':U.
        end.
      end case.
      run ref/dis-pos.w ( INPUT parparentproc
                            ,INPUT "b-sel":U
                            ,INPUT "rum"
                            ,INPUT 1
                            ,INPUT 1
                            ,INPUT 1
                            ,input '':U
                            ,input '':U
                            ,input v-subject-type
                            ,INPUT entry(2, entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)), "_")
                            ,input '':U
                            ,INPUT-OUTPUT v-rid-list) NO-ERROR.
      IF ERROR-STATUS:ERROR
      OR v-rid-list = '':U THEN DO:
          RETURN.
      END.
      find first buf_dis-cfg-rule no-lock where
                recid(buf_dis-cfg-rule) =integer(v-rid-list).
      assign
      p-value-character = buf_dis-cfg-rule.discnt-role
      p-ok = yes
      .
    end.
    if p-param-2-data-type = 'goods':U
    or p-param-2-data-type = 'goods':U + "_null"
    then do:
      define buffer buf_goods for ub.goods.
      find first buf_goods no-lock where
                buf_goods.gds-code = p-value-integer no-error.
      if available buf_goods then do:
        if p-mode = 'ПРОВЕРКА':U then do:
          p-ok = yes.
          return '':U.
        end.
        v-rid-list = string(recid(buf_goods)).
      end.
      else do:
        if p-mode = 'ПРОВЕРКА':U then do:
          if p-param-2-data-type = 'goods':U + "_null"
          and p-value-integer = 0
          then do:
            p-ok = yes.
            return '':U.
          end.
          else do:
            undo, return error substitute("Нет товара с кодом товара &1", p-value-integer).
          end.
        end.
        v-rid-list = '':U.
      end.
      run ref/gds-ref.p (    INPUT ParParentProc
                      ,  INPUT "b-sel"
                      ,  INPUT ?
                      ,  INPUT ?
                      ,  INPUT ?
                      ,  INPUT ?
                      ,  INPUT ?
                      ,  INPUT ?
                      ,  INPUT ?
                      ,  INPUT ?
                      ,  INPUT ?
                      ,  INPUT ?
                      , OUTPUT v-rid-list ) no-error .
      if error-status:error then return error .
      if v-rid-list = '':U then do:
        if p-param-2-data-type = 'goods':U + "_null"
        then do:
          message
          "Вы хотите оставить ПУСТОЕ значение параметра?"
          view-as alert-box question buttons yes-no update glog.
          if glog then do:
            assign
            p-value-integer = 0
            p-ok =  yes
            .
          end.
          else do:
            return error ''.
          end.
        end.
        else do:
          return error ''.
        end.
      end.
      find first buf_goods no-lock where
                recid(buf_goods) = integer(v-rid-list) no-error.
      if not available buf_goods then return error.
      assign
      p-value-integer = buf_goods.gds-code
      p-ok = yes
      .
    end.
    if p-param-2-data-type = 'discnt-v-type-manual':U then do:
      if p-value-integer = integer('1':U)
      or p-value-integer = integer('10':U)
      or p-value-integer = integer('0':U)
      then do:
        if p-mode = 'ПРОВЕРКА':U then do:
          p-ok = yes.
          return '':U.
        end.
      end.
      else do:
        if p-mode = 'ПРОВЕРКА':U then do:
          undo, return error substitute("Неверный тип значения ручной скидки  = &1", p-value-integer).
        end.
      end.
      run gbl/s-dvt.w ( input "Выбор тип значения ручной скидки"
                      ,input-output p-value-integer
                      ,output v-ok ) no-error.
      if not v-ok then return error.
      assign
      p-value-integer = p-value-integer
      p-ok = yes
      .
    end.
    if p-param-2-data-type = 'cash-pay':U
    or p-param-2-data-type = 'cash-pay':U + "_null"
    then do:
      define buffer buf_cash-pay for ub.cash-pay.
      find first buf_cash-pay no-lock where
                buf_cash-pay.cdpay-code = integer(entry(1, p-value-character))
            and buf_cash-pay.curr-code = integer(entry(2, p-value-character))
                no-error.
      if available buf_cash-pay then do:
        if p-mode = 'ПРОВЕРКА':U then do:
          p-ok = yes.
          return '':U.
        end.
        v-rid-list = string(recid(buf_cash-pay)).
      end.
      else do:
        if p-mode = 'ПРОВЕРКА':U then do:
          if p-value-character = substitute("&1,&2", 0, 0)
          and p-param-2-data-type = 'cash-pay':U + "_null" then do:
            p-ok = yes.
            return '':U.
          end.
          else do:
            undo, return error substitute("Нет типа касс.платежа с кодом &1 и кодом валюты &2"
                                        , entry(1, p-value-character)
                                        , entry(2, p-value-character)
                                        ).
          end.
        end.
        v-rid-list = '':U.
      end.
      run ref/cashpays.w (
               input parparentproc
              ,input  "b-sel":U
              ,input 'все':U
              ,input 0
              ,input ''
              ,input 0
              ,OUTPUT v-rid-list) NO-ERROR.
      if error-status:error then return error.
      if v-rid-list = '':U then do:
        if p-param-2-data-type = 'cash-pay':U + "_null" then do:
          message
          "Вы хотите оставить ПУСТОЕ значение параметра?"
          view-as alert-box question buttons yes-no update glog.
          if glog then do:
            assign
            p-value-character = substitute("&1,&2", 0, 0)
            p-ok =  yes
            .
          end.
        end.
        else do:
          return error.
        end.
      end.
      find first buf_cash-pay no-lock where
                recid(buf_cash-pay) = integer(v-rid-list) no-error.
      if not available buf_cash-pay then return error.
      assign
      p-value-character = substitute("&1,&2", buf_cash-pay.cdpay-code, buf_cash-pay.curr-code)
      p-ok = yes
      .
    end.
    if p-param-2-data-type = 'dis-card':U
    or p-param-2-data-type = 'dis-card':U  + "_null"
    then do:
      define buffer buf_dis-card for ub.dis-card.
      find first buf_dis-card no-lock where
                buf_dis-card.d-card = p-value-character
                no-error.
      if available buf_dis-card then do:
        if p-mode = 'ПРОВЕРКА':U then do:
          p-ok = yes.
          return '':U.
        end.
        v-rid-list = string(recid(buf_dis-card)).
      end.
      else do:
        if p-mode = 'ПРОВЕРКА':U then do:
          if p-value-character = ""
          and p-param-2-data-type = 'dis-card':U + "_null" then do:
            p-ok = yes.
            return '':U.
          end.
          else do:
            undo, return error substitute("Нет ДК &1"
                                        , p-value-character
                                        ).
          end.
        end.
        v-rid-list = '':U.
      end.
      run ref/discards.w (
                           input parparentproc
                          ,input "b-sel"
                          ,input 'все':U
                          ,input v-cntxt-host-code-obj
                          ,input v-cntxt-obj-type
                          ,input v-cntxt-obj-code
                          ,input ''
                          ,input ?
                          ,output v-rid-list) no-error.
      if error-status:error then return error .
      if v-rid-list = '':U then do:
        if p-param-2-data-type = 'dis-card':U + "_null" then do:
          message
          "Вы хотите оставить ПУСТОЕ значение параметра?"
          view-as alert-box question buttons yes-no update glog.
          if glog then do:
            assign
            p-value-character = ""
            p-ok =  yes
            .
          end.
        end.
        else do:
          return error.
        end.
      end.
      find first buf_dis-card no-lock where
                recid(buf_dis-card) = integer(v-rid-list) no-error.
      if not available buf_dis-card then return error.
      assign
      p-value-character = buf_dis-card.d-card
      p-ok = yes
      .
    end.
    if p-param-2-data-type = 'chk-doc':U + "_wth-type_null"
    or p-param-2-data-type = 'chk-doc':U + "_wth-type" then do:
      if lookup(string(p-value-integer), '2,3,4,5,7':U) > 0
      or (p-value-integer = 0 and p-param-2-data-type = 'chk-doc':U + "_wth_type_null")
      then do:
        if p-mode = 'ПРОВЕРКА':U then do:
          p-ok = yes.
          return '':U.
        end.
      end.
      else do:
        if p-mode = 'ПРОВЕРКА':U then do:
          undo, return error substitute("Неверное значение типа валюты продаж  = &1", p-value-character).
        end.
      end.
      run gbl/d-list.w (
                    INPUT "b-sel":U
                    ,INPUT "Выберите тип чека МЦ"
                    ,INPUT chr(44) + '2,3,4,5,7':U
                    ,INPUT "Тип чека МЦ не задан" + chr(44) + 'Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ':U
                    ,INPUT chr(44)
                    ,INPUT "":U
                    ,output v-chk-type).
      IF v-chk-type = "":u THEN do:
        RETURN error.
      end.
      assign
      p-value-integer = integer(v-chk-type)
      p-ok = yes
      .
    end.
    if (p-param-2-data-type begins "list_"
    or p-param-2-data-type begins "list-macro_")
    and p-param-data-type = 'character':U
    then do:
      define variable v-res-type as character no-undo .
      define buffer buf_clob-data for ub.clob-data.
      v-res-type = if p-param-2-data-type begins "list_"
                  then 'list':U
                  else 'list-macro':U.
      find first buf_clob-bind no-lock where
                buf_clob-bind.uniq-key-rec = entry(1, p-value-character, "_")
            and buf_clob-bind.field-name_ = entry(2, p-value-character, "_")
            and buf_clob-bind.resource-type = v-res-type no-error.
      if available buf_clob-bind then do:
       find first buf_clob-data no-lock where
                  buf_clob-data.db-num = buf_clob-bind.db-num
              and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
      end.
      if (available buf_clob-bind and available buf_clob-data and buf_clob-data.is-cs = yes)
      or p-value-character = "_"
      then do:
        if p-mode = 'ПРОВЕРКА':U then do:
          assign
          p-ok = yes
          .
          return ''.
        end.
        v-rid-list = (if available buf_clob-bind then string(recid(buf_clob-bind)) else '').
      end.
      else do:
        if p-mode = 'ПРОВЕРКА':U then do:
          undo, return error
          (if v-res-type = 'list':U
          then substitute("Нет СПИСКА &1 или он ДОСТУПЕН НЕ ДЛЯ ВСЕХ БД", p-value-character)
          else substitute("Нет МАКРОСА ФОРМИРОВАНИЯ СПИСКА &1 или он ДОСТУПЕН НЕ ДЛЯ ВСЕХ БД", p-value-character)
          )
          .
        end.
        v-rid-list = '':U.
      end.
      v-uniq-key-rec = entry(2, p-param-2-data-type, "_").
      run ref/clobbnds.w ( input parparentproc
                          ,input this-procedure:handle
                          ,input 'b-sel'
                          ,input "uniq-key-rec"
                          ,input ""
                          ,input v-res-type
                          ,input v-uniq-key-rec
                          ,input -1
                          ,input-output v-rid-list) no-error.
      if v-rid-list <> '':U then do:
        FIND FIRST buf_clob-bind NO-LOCK WHERE
                    recid(buf_clob-bind) = INTEGER(v-rid-list) NO-ERROR.
        IF not AVAILABLE buf_clob-bind THEN DO:
          if v-res-type = 'list':U
          then
          return error substitute("Не найден список c recid &1", v-rid-list).
          else
          return error substitute("Не найден макрос c recid &1", v-rid-list).
        end.
        assign
        p-value-character =  SUBSTITUTE("&1_&2"
                                      , buf_clob-bind.uniq-key-rec
                                      , buf_clob-bind.field-name_)
        p-ok = yes
        .
      end.
    end.
   if p-param-2-data-type begins "tpl_"
    and p-param-data-type = 'character':U
    then do:
      define buffer buf_price-list-type for ub.price-list-type.
      find first buf_price-list-type no-lock where
                buf_price-list-type.plt-id = integer(entry(1, p-value-character, "-"))
            and buf_price-list-type.db-num = integer(entry(2, p-value-character, "-")) no-error.
      if available buf_price-list-type then do:
        if p-mode = 'ПРОВЕРКА':U then do:
          assign
          p-ok = yes
          .
          return ''.
        end.
        v-rid-list = string(recid(buf_price-list-type)).
      end.
      else do:
        if p-mode = 'ПРОВЕРКА':U then do:
          undo, return error substitute("Нет ТПЛ &1", p-value-character).
        end.
        v-rid-list = '':U.
      end.
      v-templ-rl-root = integer(entry(2, p-param-2-data-type, "_")).
      v-rid-list = string(v-templ-rl-root).
      run ref/typepric.w (
                            input  parParentProc
                          ,INPUT "b-sel,mode=ban-discnt"
                          ,INPUT-OUTPUT v-rid-list ) NO-ERROR.
      if v-rid-list <> '':U then do:
        FIND FIRST buf_price-list-type NO-LOCK WHERE
                    recid(buf_price-list-type) = INTEGER(v-rid-list) NO-ERROR.
        IF not AVAILABLE buf_price-list-type THEN DO:
          return error substitute("Не найден ТПЛ c recid &1", v-rid-list).
        end.
        assign
        p-value-character =  SUBSTITUTE("&1-&2"
                                      , buf_price-list-type.plt-id
                                      , buf_price-list-type.plt-db-num)
        p-ok = yes
        .
      end.
    end.
    if p-param-2-data-type = "sub-type" then do:
      if p-mode = 'ПРОВЕРКА':U then do:
        p-ok = yes.
        return '':U.
      end.
      assign
      p-value-character = p-value-character
      p-ok = yes
      .
    end.
    if p-param-2-data-type = "id" then do:
      if p-mode = 'ПРОВЕРКА':U then do:
        p-ok = yes.
        return '':U.
      end.
      run gbl/d-prompt.w (
          'title=':u + "ВВЕДИТЕ ЗНАЧЕНИЕ" + '\':u
        + 'text1=' + substitute("ЗНАЧЕНИЕ") + '\':u
        + 'format=' + "X(40)" + '\':u
        + 'type=' + 'C':U + '\':u
        + 'fillin_row=2\':u
        + 'fillin_col=4\':u
        + 'fillin_width=20\':u
        + 'fillin_height=1\':u
        + 'max-chars=70\':u
        + 'readonly=no\':u
        , input-output p-value-character
        ).
      assign
      p-ok = yes
      .
    end.
end.
