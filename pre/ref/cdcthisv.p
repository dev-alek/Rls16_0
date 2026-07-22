block-level on error undo, throw.
define input parameter p-emitent-host-code  like ub.c-dis-card-type.emitent-host-code no-undo .
define input parameter p-type               like ub.c-dis-card-type.type no-undo .
define input parameter p-chip-num like ub.c-cli-hist.chip-num no-undo .
define input parameter p-corr-user-db-num like ub.c-dis-card-type.corr-user-db-num no-undo .
define input parameter p-obj-type like ub.c-dis-card-type.obj-type no-undo .
define input parameter p-obj-code like ub.c-dis-card-type.obj-code no-undo .
define input parameter p-host-code like ub.c-dis-card-type.host-code no-undo .
define input parameter p-subject like ub.c-dis-card-type.subject no-undo .
define input parameter p-action   like ub.c-dis-card-type.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cdcthisv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cdcthisv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории ДК".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = 'орг':U then do:
       par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parhost-code).
       return par-region.
    end.
    if parobj-type = 'регион':U
    then do:
       par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
       return par-region.
    end.
    par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
    return par-region.
END FUNCTION.
FUNCTION get-objregion RETURNS CHARACTER
  (  input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if  parobj-type = "":U and
      parobj-code = 0
  then do:
     par-region = "Глобально".
  end.
  else if parobj-type = 'орг':U
  then do:
     par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parobj-code).
  end.
  else if parobj-type = 'регион':U
  then do:
     par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
  end.
  else
     par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
  return par-region.
END FUNCTION.
FUNCTION calldscr returns character ( input p-call-id as character):
define variable v-descr as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo.
define variable v-prop-label as character no-undo .
define variable v-node-label as character no-undo .
define variable v-dt-code as integer no-undo .
define variable v-host-code as integer no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-label as character no-undo .
define variable v-node-code as integer no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-map for ub.prop-map.
run gen-key-fv in this-procedure ( input p-call-id
                                  ,output v-field-list
                                  ,output v-value-list) no-error .
if error-status:error then return p-call-id.
CASE entry(1, p-call-id, chr(3)):
  when 'dis-card-type':U then do:
    v-descr = substitute("Тип ДК: эмитент &1 тип: &2"
                         ,integer(entry(lookup("emitent-host-code", v-field-list, chr(3)), v-value-list, chr(3)) )
                         ,entry(lookup("type", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
  when 'dis-card':U then do:
    v-descr = substitute("ДК: № &1"
                         ,entry(lookup("d-card", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
  when 'dis-card-property':U then do:
    v-dt-code = integer(entry(lookup("dt-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    v-node-code = integer(entry(lookup("node-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    v-host-code = integer(entry(lookup("host-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    v-obj-type = entry(lookup("obj-type", v-field-list, chr(3)), v-value-list, chr(3)) .
    v-obj-code = integer(entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    find first buf_prop-ref no-lock where
              buf_prop-ref.dt-code = v-dt-code no-error .
    if available buf_prop-ref then do:
      find first buf_prop-head no-lock where
                buf_prop-head.dtm-code = buf_prop-ref.dtm-code no-error .
      v-prop-label = buf_prop-head.prop-label.
      find first buf_prop-map no-lock where
                buf_prop-map.dtm-code = buf_prop-ref.dtm-code
            and buf_prop-map.node-code = v-node-code no-error .
      if available buf_prop-map then do:
        v-label = buf_prop-map.node-label.
      end.
    end.
    v-descr = substitute("ДК: № &1 &2:&3 &4"
                         ,entry(lookup("d-card", v-field-list, chr(3)), v-value-list, chr(3))
                         ,v-prop-label
                         ,v-label
                         ,get-region(v-host-code, v-obj-type, v-obj-code)
                         ).
  end.
  when 'clients':U then do:
    v-descr = substitute("&1&2"
                         ,entry(lookup("obj-type", v-field-list, chr(3)), v-value-list, chr(3))
                         ,integer(entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3)) )
                         ).
  end.
  when 'ext-system':U then do:
    v-descr = substitute("Внешняя система &1"
                         ,integer(entry(lookup("esys-id", v-field-list, chr(3)), v-value-list, chr(3)))
                         ).
  end.
  WHEN 'thbj-attr':U then do:
    if entry(lookup("upper-prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'rum':U
    or entry(lookup("upper-prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'rum_obj':U
    then do:
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'goods':U then do:
        v-descr = "Операции с товарами".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'clients':U then do:
        v-descr = "Операции с клиентами".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'gds-grp':U then do:
        v-descr = "Операции с группами товаров".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'cli-grp':U then do:
        v-descr = "Операции с группами клиентов".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'chk-doc_ibs-th':U then do:
        v-descr = "Операции с чеками на POS IBS-TH".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'chk-doc_ibs-th-mob':U then do:
        v-descr = "Операции с чеками на POS IBS-TH-MOB".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'edoc':U then do:
        v-descr = "Операции в системе электронного документооборота".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'thref':U then do:
        v-descr = "Операции со справочниками".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'pdf':U then do:
        v-descr = "Операции с ДНЦ и переоценками".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'rep':U then do:
        v-descr = "Отчеты".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'ord':U then do:
        v-descr = "Операции с заказами".
      end.
    end.
  end.
  when 'cash-desk':U then do:
    v-descr = substitute("БД &1 Маг &2 Касса № &4 &3"
                         ,entry(lookup("db-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("cash-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("pos-type", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
  when 'ext-file':U then do:
    v-descr = substitute("БД &1 Файл № &3 (из БД &2)"
                         ,entry(lookup("db-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("from-db-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("file-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
end case.
return v-descr.
end function.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-drt-prop no-undo like ub.drt-prop.
procedure disrules-fill-properties:
define input  parameter p-templ-rl-root as integer   no-undo .
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_temp-drt-prop for temp-drt-prop.
do
on error undo, return error return-value
:
  for each buf_temp-drt-prop:
    delete buf_temp-drt-prop.
  end.
  for each buf_drt-prop where buf_drt-prop.templ-rl-root = p-templ-rl-root:
    create buf_temp-drt-prop.
    buffer-copy buf_drt-prop to buf_temp-drt-prop.
  end.
end.
end procedure.
~
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure discfgru-check :
define input parameter p-table-name as character no-undo .
define input parameter p-templ-rl-root as integer no-undo .
define input parameter p-time-templ-rl-root as integer no-undo .
define input parameter p-pos-type as character no-undo .
define output parameter p-disnct-role as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
  do
  on error undo, return error return-value
  :
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.table-name = p-table-name
        and buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
        and (p-time-templ-rl-root = ? or  buf_dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root)
        and buf_dis-cfg-rule.pos-type = p-pos-type no-error.
    if not available buf_dis-cfg-rule
    or p-pos-type = "":U
    then do:
       return error substitute("Для места использования типа &1 не определен тип скидки с шаблоном &2 &3"
                               ,entry (lookup (p-pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U)
                               , p-templ-rl-root
                               , (if p-time-templ-rl-root = ?
                                  then '':U
                                  else substitute("с расписанием типа &1", p-time-templ-rl-root)
                                  )
                               ).
    end.
    assign
    p-disnct-role = buf_dis-cfg-rule.discnt-role
    .
  end.
end procedure.
procedure disdctru-name :
define buffer buf_dis-rule for ub.dis-rule.
do
  on error undo, return error
  :
  define input  parameter p-templ-rl-root  as integer no-undo .
  define output parameter p-label          as character no-undo .
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-templ-rl-root no-error.
  if available buf_dis-rule then do:
    p-label = buf_dis-rule.des.
  end.
  else do:
    p-label = substitute("Неизвестный тип правила скидки &1", p-templ-rl-root).
  end.
end.
end procedure.
function disdctru-get-disc-label returns character ( input p-templ-rl-root as integer):
define variable v-rule-label as character no-undo .
run disdctru-name in this-procedure ( input p-templ-rl-root
                                     ,output v-rule-label) no-error.
return v-rule-label.
end function.
function disdctru-get-disc-role-label returns character ( input p-discnt-role as character):
define variable v-rule-label as character no-undo .
return entry (lookup (p-discnt-role, 'calc-d-pcnt,calc-cash-d-pcnt,calc-categ,dis-tot-flag,def-categ,def-pcnt,def-cash-pcnt':u) + 1, ',' + 'Расчет %скидки ДК на товар,Расчет %скидки ДК на итог,Расчет категории ДК,Участие в итогах по ДК,Категория ДК по умолчанию,% скидки ДК на товар по умолч.,% скидки ДК на итог по умолч.':u).
end function.
procedure disdctru-write :
  do
  on error undo, return error
  :
    define input parameter p-type           like ub.dis-dct-rule.type       no-undo .
    define input parameter p-emitent-host-code      like ub.dis-dct-rule.emitent-host-code  no-undo .
    define input parameter p-host-code      like ub.dis-dct-rule.host-code  no-undo .
    define input parameter p-obj-type       like ub.dis-dct-rule.obj-type   no-undo .
    define input parameter p-obj-code       like ub.dis-dct-rule.obj-code   no-undo .
    define input parameter p-pos-type       like ub.dis-dct-rule.pos-type   no-undo .
    define input parameter p-discnt-role    like ub.dis-dct-rule.discnt-role no-undo .
    define input parameter p-templ-rl-root  like ub.dis-dct-rule.templ-rl-root  no-undo .
    define input parameter p-time-templ-rl-root  like ub.dis-dct-rule.time-templ-rl-root  no-undo .
    define input parameter p-rule-num       like ub.dis-dct-rule.rule-num    no-undo .
    define input parameter p-NONUNIQUE as character no-undo .
    define buffer buf_dis-dct-rule for ub.dis-dct-rule .
    define buffer lock_dis-dct-rule for ub.dis-dct-rule .
    define buffer buf_dis-rule for ub.dis-rule.
    define variable v-label          as character no-undo .
    define variable v-discnt-role as character no-undo .
    run discfgru-check in this-procedure (
                                          input 'dis-dct-rule':U
                                         ,input p-templ-rl-root
                                         ,input p-time-templ-rl-root
                                         ,input p-pos-type
                                         ,output v-discnt-role
                                          ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    if p-discnt-role = ? then do:
      p-discnt-role = v-discnt-role.
    end.
    if p-discnt-role <> v-discnt-role then do:
      undo, return error substitute("Тип ДК &1 код валюты &2 фирма &3 &4 место использ. &5 скидка типа &6&7не может быть по шаблону &8 и расписанию &9"
                              ,p-type
                              ,p-emitent-host-code
                              ,p-host-code
                              ,p-obj-type + string(p-obj-code)
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'calc-d-pcnt,calc-cash-d-pcnt,calc-categ,dis-tot-flag,def-categ,def-pcnt,def-cash-pcnt':u) + 1, ',' + 'Расчет %скидки ДК на товар,Расчет %скидки ДК на итог,Расчет категории ДК,Участие в итогах по ДК,Категория ДК по умолчанию,% скидки ДК на товар по умолч.,% скидки ДК на итог по умолч.':u)
                              ,chr(10)
                              ,p-templ-rl-root
                              ,p-rule-num).
    end.
    if p-pos-type = ? then do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type6 as character no-undo .
define variable v-value-date6 as date no-undo .
define variable v-value-decimal6 as decimal no-undo .
define variable v-value-integer6 as INTEGER no-undo .
define variable v-value-logical6 AS LOGICAL no-undo .
define variable v-tth6 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output p-pos-type
    ,output v-value-date6
    ,output v-value-decimal6
    ,output v-value-integer6
    ,output v-value-logical6
    ,output v-param-type6
    ,INPUT-OUTPUT table-handle v-tth6
    )  .
delete object v-tth6 no-error.
    end.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-rule-num no-error.
    if not available buf_Dis-rule then do:
      undo, return error substitute("Тип ДК &1 код валюты &2 фирма &3 &4 место использ. &5 скидка типа &6&7не найдено правило скидки &9"
                              ,p-type
                              ,p-emitent-host-code
                              ,p-host-code
                              ,p-obj-type + string(p-obj-code)
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'calc-d-pcnt,calc-cash-d-pcnt,calc-categ,dis-tot-flag,def-categ,def-pcnt,def-cash-pcnt':u) + 1, ',' + 'Расчет %скидки ДК на товар,Расчет %скидки ДК на итог,Расчет категории ДК,Участие в итогах по ДК,Категория ДК по умолчанию,% скидки ДК на товар по умолч.,% скидки ДК на итог по умолч.':u)
                              ,chr(10)
                              ,p-templ-rl-root
                              ,p-rule-num).
    end.
    if buf_dis-rule.root <> yes then do:
      undo, return error substitute("Тип ДК &1 код валюты &2 фирма &3 &4 место использ. &5 скидка типа &6&7правило скидки &9 - некорневое"
                              ,p-type
                              ,p-emitent-host-code
                              ,p-host-code
                              ,p-obj-type + string(p-obj-code)
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'calc-d-pcnt,calc-cash-d-pcnt,calc-categ,dis-tot-flag,def-categ,def-pcnt,def-cash-pcnt':u) + 1, ',' + 'Расчет %скидки ДК на товар,Расчет %скидки ДК на итог,Расчет категории ДК,Участие в итогах по ДК,Категория ДК по умолчанию,% скидки ДК на товар по умолч.,% скидки ДК на итог по умолч.':u)
                              ,chr(10)
                              ,p-templ-rl-root
                              ,p-rule-num).
    end.
    find first buf_dis-dct-rule exclusive-lock where
               buf_dis-dct-rule.type  = p-type
           AND buf_dis-dct-rule.emitent-host-code = p-emitent-host-code
           AND buf_dis-dct-rule.obj-type  = p-obj-type
           AND buf_dis-dct-rule.host-code = p-host-code
           AND buf_dis-dct-rule.obj-code  = p-obj-code
           AND buf_dis-dct-rule.pos-type  = p-pos-type
           AND buf_dis-dct-rule.discnt-role = p-discnt-role  no-error .
    if not available buf_dis-dct-rule then do:
      create buf_dis-dct-rule .
      assign
      buf_dis-dct-rule.type  = p-type
      buf_dis-dct-rule.emitent-host-code  = p-emitent-host-code
      buf_dis-dct-rule.host-code  = p-host-code
      buf_dis-dct-rule.obj-type  = p-obj-type
      buf_dis-dct-rule.obj-code  = p-obj-code
      buf_dis-dct-rule.pos-type = p-pos-type
      buf_dis-dct-rule.discnt-role = v-discnt-role
      buf_dis-dct-rule.rule-num = p-rule-num no-error
      .
    end.
    ELSE
    ASSIGN
    buf_dis-dct-rule.rule-num = p-rule-num
    buf_dis-dct-rule.rl-root = buf_Dis-rule.rl-root
    buf_dis-dct-rule.time-templ-rl-root = p-time-templ-rl-root
    buf_dis-dct-rule.templ-rl-root = p-templ-rl-root
    buf_dis-dct-rule.nonunique = p-nonunique
    no-error.
  end.
end procedure.
procedure disdctru-delete :
define input parameter p-cdpay-code     like ub.dis-dct-rule.emitent-host-code no-undo .
define input parameter p-curr-code      like ub.dis-dct-rule.type no-undo .
define input parameter p-host-code      like ub.dis-dct-rule.host-code   no-undo .
define input parameter p-obj-type       like ub.dis-dct-rule.obj-type   no-undo .
define input parameter p-obj-code       like ub.dis-dct-rule.obj-code   no-undo .
define input parameter p-pos-type       like ub.dis-dct-rule.pos-type   no-undo .
define input parameter p-discnt-role    like ub.dis-dct-rule.discnt-role no-undo .
define input parameter p-nonunique      like ub.dis-dct-rule.nonunique   no-undo .
define output parameter p-deleted       as logical no-undo .
define variable v-rule-label as character no-undo .
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
do
on error undo, return error
:
find first buf_dis-dct-rule exclusive-lock where
            buf_dis-dct-rule.emitent-host-code  = p-host-code
        AND buf_dis-dct-rule.type  = p-type
        AND buf_dis-dct-rule.obj-type  = p-obj-type
        AND buf_dis-dct-rule.host-code = p-host-code
        AND buf_dis-dct-rule.obj-code  = p-obj-code
        AND buf_dis-dct-rule.pos-type  = p-pos-type
        AND buf_dis-dct-rule.discnt-role = p-discnt-role
        and buf_dis-dct-rule.nonunique = p-nonunique
        no-error .
if not available buf_dis-dct-rule then do:
  return '':U.
end.
delete buf_dis-dct-rule no-error.
if error-status:error then do:
  run disdctru-name in this-procedure
    (input  buf_dis-dct-rule.templ-rl-root
    ,output v-rule-label
    ) no-error .
  undo, return error substitute("Ошибка при удалении скидки по типу ДК:&1" +
                               "скидка &2 (POS &3) на фирме &4 &5&6 для платежа&1&7&1&8"
                                ,chr(10)
                                ,v-rule-label
                                ,p-pos-type
                                ,p-host-code
                                ,p-obj-type
                                ,p-obj-code
                                ,error-status:get-message(1)
                                ,return-value ).
end.
p-deleted = yes.
return '':U.
end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure dct-attr-code :
  do
  on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-range          as integer   no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-code :
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа дисконтной карты &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure dct-attr-tooltip :
  do
  on error undo, return error return-value
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-code :
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа дисконтной карты &1",  p-code ).
      end.
    end.
  end.
end procedure.
procedure dct-attr-value :
  do
  on error undo, return error return-value
  :
    define input parameter p-emitent-host-code  like ub.dis-card-type.emitent-host-code no-undo .
    define input parameter p-type-card               like ub.dis-card-type.type no-undo .
    define input  parameter p-host-code like ub.dis-card-type-attr.host-code  no-undo .
    define input  parameter p-obj-type  like ub.dis-card-type-attr.obj-type   no-undo .
    define input  parameter p-obj-code  like ub.dis-card-type-attr.obj-code   no-undo .
    define input  parameter p-code      like ub.dis-card-type-attr.attr-code  no-undo .
    define output parameter p-value     like ub.dis-card-type-attr.attr-value no-undo .
    define output parameter p-type      as character no-undo .
    define buffer buf_dis-card-type-attr for ub.dis-card-type-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-range          as integer   no-undo .
    run dct-attr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    if v-range <= 4 then do:
      CASE v-range:
        when 1 then do:
          assign
          p-host-code = 0
          p-obj-type = "":U
          p-obj-code = 0
          .
        end.
        when 2 then do:
          assign
          p-obj-type = "":U
          p-obj-code = 0
          .
        end.
        when 4 then do:
        end.
      END CASE.
    end.
    find first buf_dis-card-type-attr no-lock
      where
            buf_dis-card-type-attr.emitent-host-code   = p-emitent-host-code
        and buf_dis-card-type-attr.type                = p-type-card
        and buf_dis-card-type-attr.host-code = p-host-code
        and buf_dis-card-type-attr.obj-type  = p-obj-type
        and buf_dis-card-type-attr.obj-code  = p-obj-code
        and buf_dis-card-type-attr.attr-code = p-code
      no-error .
    if avail buf_dis-card-type-attr then do:
      assign
        p-value =  buf_dis-card-type-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure dct-attr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-emitent-host-code  like ub.dis-card-type.emitent-host-code no-undo .
    define input parameter p-type               like ub.dis-card-type.type no-undo .
    define input parameter p-host-code like ub.dis-card-type-attr.host-code  no-undo .
    define input parameter p-obj-type  like ub.dis-card-type-attr.obj-type   no-undo .
    define input parameter p-obj-code  like ub.dis-card-type-attr.obj-code   no-undo .
    define input parameter p-code      like ub.dis-card-type-attr.attr-code  no-undo .
    define input parameter p-value     like ub.dis-card-type-attr.attr-value no-undo .
    define input parameter p-cmd-proc-handle as handle no-undo .
    define input parameter p-cmd-code as integer no-undo .
    define buffer buf_dis-card-type-attr for ub.dis-card-type-attr .
    define buffer buf_dis-card-type for ub.dis-card-type.
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-send           as logical   no-undo .
    run dct-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_dis-card-type-attr exclusive-lock
      where
            buf_dis-card-type-attr.emitent-host-code   = p-emitent-host-code
        and buf_dis-card-type-attr.type                = p-type
        and buf_dis-card-type-attr.host-code = p-host-code
        and buf_dis-card-type-attr.obj-type  = p-obj-type
        and buf_dis-card-type-attr.obj-code  = p-obj-code
        and buf_dis-card-type-attr.attr-code = p-code
      no-error .
    if not available buf_dis-card-type-attr then do:
      find first buf_dis-card-type no-lock where
            buf_dis-card-type.emitent-host-code   = p-emitent-host-code
        and buf_dis-card-type.type                = p-type
                 .
      create buf_dis-card-type-attr .
      assign
        buf_dis-card-type-attr.emitent-host-code = p-emitent-host-code
        buf_dis-card-type-attr.type = p-type
        buf_dis-card-type-attr.host-code = p-host-code
        buf_dis-card-type-attr.emitent-host-code = p-emitent-host-code
        buf_dis-card-type-attr.obj-type  = p-obj-type
        buf_dis-card-type-attr.obj-code  = p-obj-code
        buf_dis-card-type-attr.attr-code = p-code
      .
      assign
      v-send = yes.
    end.
    else do:
      if p-value <> buf_Dis-card-type-attr.attr-value then do:
        v-send = yes.
      end.
    end.
    assign
      buf_dis-card-type-attr.attr-value = p-value
    .
    if v-send
    and valid-handle(p-cmd-proc-handle) then do:
      run add-dump in p-cmd-proc-handle
        (input p-cmd-code
        ,input 'dis-card-type-attr':U
        ,input '+update'
        ,input buffer buf_dis-card-type-attr:handle
        ,input '':U
        ) no-error .
      if error-status:error then do:
          undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
      end.
    end.
  end.
end procedure.
procedure dct-attr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-emitent-host-code  like ub.dis-card-type.emitent-host-code no-undo .
    define input parameter p-type               like ub.dis-card-type.type no-undo .
    define input parameter p-host-code like ub.dis-card-type-attr.host-code  no-undo .
    define input parameter p-obj-type  like ub.dis-card-type-attr.obj-type   no-undo .
    define input parameter p-obj-code  like ub.dis-card-type-attr.obj-code   no-undo .
    define input parameter p-code      like ub.dis-card-type-attr.attr-code  no-undo .
    define output parameter p-exist    as logical  no-undo .
    define buffer buf_dis-card-type-attr for ub.dis-card-type-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable V-RANGE          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run dct-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,OUTPUT V-RANGE
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_dis-card-type-attr no-lock
      where
            buf_dis-card-type-attr.emitent-host-code   = p-emitent-host-code
        and buf_dis-card-type-attr.type                = p-type
       and buf_dis-card-type-attr.host-code = p-host-code
        and buf_dis-card-type-attr.obj-type  = p-obj-type
        and buf_dis-card-type-attr.obj-code  = p-obj-code
        and buf_dis-card-type-attr.attr-code = p-code
      no-error .
    if  available buf_dis-card-type-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure dct-attr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-emitent-host-code  like ub.dis-card-type.emitent-host-code no-undo .
    define input parameter p-type               like ub.dis-card-type.type no-undo .
    define input parameter p-host-code like ub.dis-card-type-attr.host-code  no-undo .
    define input parameter p-obj-type like ub.dis-card-type-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.dis-card-type-attr.obj-code   no-undo .
    define input parameter p-code     like ub.dis-card-type-attr.attr-code  no-undo .
    define input parameter p-cmd-proc-handle as handle no-undo .
    define input parameter p-cmd-code as integer no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_dis-card-type-attr for ub.dis-card-type-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-rec-ord_        as integer no-undo .
    run dct-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_dis-card-type-attr exclusive-lock
      where
            buf_dis-card-type-attr.emitent-host-code   = p-emitent-host-code
        and buf_dis-card-type-attr.type                = p-type
        and buf_dis-card-type-attr.host-code = p-host-code
        and buf_dis-card-type-attr.obj-type  = p-obj-type
        and buf_dis-card-type-attr.obj-code  = p-obj-code
        and buf_dis-card-type-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_dis-card-type-attr then do:
      p-deleted = no.
    end.
    else do:
      if valid-handle(p-cmd-proc-handle) then do:
        run add-dump in p-cmd-proc-handle
          (input p-cmd-code
          ,input 'dis-card-type-attr':U
          ,input '+delete'
          ,input buffer buf_dis-card-type-attr:handle
          ,input '':U
          ,output v-rec-ord_
          ) no-error .
        if error-status:error then do:
          undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
        end.
      end.
      delete buf_dis-card-type-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure dct-attr-news :
  do
  on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-code :
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа дисконтной карты &1", p-code ).
      end.
    end.
  end.
end procedure.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess  as character no-undo .
define buffer buf_c-dis-card-type for ub.c-dis-card-type.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define SHARED temp-table temp-changes no-undo
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
FUNCTION get-all-fields returns character (p-file-name as character ):
define variable v-dop as character no-undo .
  find first _file no-lock where _file._file-name = p-file-name no-error .
  if not available _file then return "":U.
  for each _field no-lock where
           _field._file-recid = recid(_file) :
    assign
    v-dop = v-dop + _field._field-name + chr(44)
    .
  end.
  return trim(v-dop).
END FUNCTION.
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
  define variable v-chg-fields as character no-undo.
  for each temp-changes:
    delete temp-changes.
  end.
  if not p-hst-handle:available then do:
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
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, h-main-buf:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
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
    if fh:data-type ="character":U then do:
      assign
        v-srch-main = substitute( '&1 "&2"', v-srch-main, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-srch-main = substitute( "&1 &2", v-srch-main, fh:buffer-value() )
      .
    end.
    if v-delim-list = "":U then do:
      assign
        v-delim-list = ",":U
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  assign
    v-delim-list  = "":U
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
      if v-delim-list = "":U then do:
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
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, p-hst-handle:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
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
    if v-field-name = "chip-num":U then do:
      assign
        v-search-exp  = substitute( "&1 >", v-search-exp )
        v-av-chip-num = true
      .
    end.
    else do:
      assign
        v-search-exp = substitute( "&1 =", v-search-exp )
      .
    end.
    if fh:data-type ="character":U then do:
      assign
        v-search-exp = substitute( '&1 "&2"', v-search-exp, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-search-exp = substitute( '&1 &2', v-search-exp, fh:buffer-value() )
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  if v-av-chip-num = false then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Таблица &2 не содержит поля chip-num.", vss-workfile, p-hst-handle:name ) skip
      "Использование данной процедуры невозможно!" skip
      view-as alert-box error .
    return error .
  end.
  h-new-buf:find-first( v-search-exp, no-lock ) no-error .
  if not h-new-buf:available then do:
    h-main-buf:find-first( v-srch-main, no-lock ) no-error .
    if not h-main-buf:available then do:
      assign
        h-for-comp = ?
      .
    end.
    else do:
      assign
        h-for-comp = h-main-buf
      .
    end.
  end.
  else do:
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
    then do:
      if h-for-comp <> ? then do:
        assign
          fh-new      = h-for-comp:buffer-field( v-field-name )
          v-new-value = fh-new:buffer-value()
        .
      end.
      else do:
        assign
          v-new-value = "":U
        .
      end.
        if p-act-create = true then do:
          assign
            v-old-value = "":U
          .
        end.
        if p-act-delete = true then do:
          assign
            v-new-value = "":U
          .
        end.
      if v-old-value <> v-new-value
      then do:
        create temp-changes.
        assign
          temp-changes.t_name = p-main-table
          temp-changes.f_name = v-field-name
          temp-changes.l_name = replace( v-label, "&":U, "":U )
          temp-changes.v_old  = trim( v-old-value )
          temp-changes.v_new  = trim( v-new-value )
          temp-changes.num_   = 0
          temp-changes.fNotChange = v-old-value eq v-new-value
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
    if num-entries( entry( v-ind, p-label-form, chr(8) ), chr(4) ) = 3 then do:
      assign
        v-field-name = entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-lvl  = entry( 2, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-form = entry( 3, entry( v-ind, p-label-form, chr(8) ), chr(4) )
      .
      find first temp-changes
        where temp-changes.f_name = v-field-name
        no-error .
      if available temp-changes then do:
        if trim( v-field-lvl ) <> "":U then do:
          assign
            temp-changes.l_name = v-field-lvl
          .
        end.
        if trim( v-field-form ) <> "":U then do:
          assign
            temp-changes.v_old = dynamic-function( v-field-form, temp-changes.v_old )
          .
          if h-for-comp <> ? then do:
            assign
              temp-changes.v_new = dynamic-function( v-field-form, temp-changes.v_new )
            .
          end.
        end.
      end.
    end.
    else do:
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
find first buf_c-dis-card-type no-lock where
          buf_c-dis-card-type.emitent-host-code = p-emitent-host-code
      AND buf_c-dis-card-type.type              = p-type
      AND buf_c-dis-card-type.host-code         = p-host-code
      AND buf_c-dis-card-type.obj-type          = p-obj-type
      AND buf_c-dis-card-type.obj-code          = p-obj-code
      AND buf_c-dis-card-type.chip-num = p-chip-num
      AND buf_c-dis-card-type.corr-user-db-num = p-corr-user-db-num  no-error .
if not available buf_c-dis-card-type then do:
  return error .
end.
CASE p-subject:
  when 'dis-card-type':U then do:
    run dis-card-type-proc in this-procedure(output p-description) no-error .
  end.
  when 'dis-card-type-attr':U then do:
    run dis-card-type-attr-proc in this-procedure(output p-description) no-error .
  end.
  when 'dis-card-mask':U then do:
    run dis-card-mask-proc in this-procedure(output p-description) no-error .
  end.
  when 'rp-by-call':U then do:
    run rp-by-call-proc in this-procedure(output p-description) no-error .
  end.
  when 'rule-by-call':U then do:
    run rule-by-call-proc in this-procedure(output p-description) no-error .
  end.
  when 'rule-call-param':U then do:
    run rule-call-param-proc in this-procedure(output p-description) no-error .
  end.
  when 'dis-dct-rule':U then do:
    run dis-dct-rule-proc in this-procedure(output p-description) no-error .
  end.
  when 'hist-nws-option':U then do:
    run hist-nws-option-proc in this-procedure(output p-description) no-error .
  end.
END CASE.
if error-status:error then do:
  return error .
end.
procedure dis-card-type-proc :
define output parameter p-description as character no-undo .
define buffer current_c-dis-card-type for ub.c-dis-card-type  .
  do
  on error undo, return error return-value
  :
    find first current_c-dis-card-type no-lock where
               current_c-dis-card-type.emitent-host-code = p-emitent-host-code
           AND current_c-dis-card-type.type              = p-type
           AND current_c-dis-card-type.host-code         = p-host-code
           AND current_c-dis-card-type.obj-type          = p-obj-type
           AND current_c-dis-card-type.obj-code          = p-obj-code
           AND current_c-dis-card-type.chip-num          = p-chip-num
           AND current_c-dis-card-type.corr-user-db-num  = p-corr-user-db-num no-error .
    if not avail current_c-dis-card-type then do:
       v-mess = "Неверная ссылка на c-dis-card-type в таблице c-dis-card-type".
       run err-mess(input-output v-mess).
       return error.
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "card-media" + chr(4) + "Тип носителя карты" + chr(4) + "" + chr(8)
 + "cardname-sent" + chr(4) + "На кассу в поле ИМЯ" + chr(4) + "" + chr(8)
 + "custom-sent" + chr(4) + "На кассу в настраиваемом поле" + chr(4) + "" + chr(8)
 + "d-pcnt-byshop" + chr(4) + "Скидка по объектам" + chr(4) + "" + chr(8)
 + "dc-pfx" + chr(4) + "Префикс карты" + chr(4) + "" + chr(8)
 + "dcbyshop" + chr(4) + "Только СВОИ карты" + chr(4) + "" + chr(8)
 + "dflt-credit-card" + chr(4) + "Кредитная карта" + chr(4) + "" + chr(8)
 + "dflt-d-pcnt-method" + chr(4) + "Тип скидки" + chr(4) + "" + chr(8)
 + "dflt-debet-card" + chr(4) + "Дебетовая карта" + chr(4) + "" + chr(8)
 + "dflt-staff-card" + chr(4) + "Карта персонала" + chr(4) + "" + chr(8)
 + "emitent-host-code" + chr(4) + "Код фирмы-эмитента" + chr(4) + "" + chr(8)
 + "fiscal-pay" + chr(4) + "Фискальный платеж" + chr(4) + "" + chr(8)
 + "host-code" + chr(4) + "Своя организация (код)" + chr(4) + "" + chr(8)
 + "lim-kr" + chr(4) + "Лимит кредита по умолчанию" + chr(4) + "" + chr(8)
 + "mixed-pay" + chr(4) + "Смешанная оплата" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта учета" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "pay-code" + chr(4) + "Касс.платеж" + chr(4) + "" + chr(8)
 + "service-db-num" + chr(4) + "№ обслуживающей БД" + chr(4) + "" + chr(8)
 + "type" + chr(4) + "Тип карты" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dis-card-type.action = integer('1':U))
                                            ,input  (buf_c-dis-card-type.action = integer('99':U))
                                            ,input  buffer current_c-dis-card-type:handle
                                            ,input  'dis-card-type':U
                                            ,input  "card-media,cardname-sent,d-pcnt-byshop,dc-pfx,dcbyshop,dflt-cash-pcnt,dflt-credit-card," +          "dflt-d-pcnt-method,dflt-debet-card,dflt-pcnt,dflt-pcnt-kat,dflt-staff-card,emitent-host-code,fiscal-pay,host-code,lim-kr,mixed-pay," +          "obj-code,obj-type,pay-code,type"
                                            ,input  v-label-param).
end.
end procedure.
procedure dis-card-type-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-dis-card-type-attr for ub.c-dis-card-type-attr  .
  do
  on error undo, return error return-value
  :
    find first current_c-dis-card-type-attr no-lock where
               current_c-dis-card-type-attr.emitent-host-code = p-emitent-host-code
           AND current_c-dis-card-type-attr.type = p-type
           AND current_c-dis-card-type-attr.host-code = p-host-code
           AND current_c-dis-card-type-attr.obj-type = p-obj-type
           AND current_c-dis-card-type-attr.obj-code = p-obj-code
           AND current_c-dis-card-type-attr.chip-num = p-chip-num
           AND current_c-dis-card-type-attr.corr-user-db-num = p-corr-user-db-num
           AND current_c-dis-card-type-attr.attr-code = buf_c-dis-card-type.attr-code
           no-error .
    if not avail current_c-dis-card-type-attr then do:
       v-mess = "Неверная ссылка на c-dis-card-type-attr в таблице c-dis-card-type".
       run err-mess(input-output v-mess).
    end.
    run dct-attr-tooltip in this-procedure (
                input  string(current_c-dis-card-type-attr.attr-code)
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + chr(32) + v-label
    .
define variable v-label-param as character no-undo .
v-label-param =
  "attr-value" + chr(4) + "Значение атрибута" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "host-code" + chr(4) + "Код фирмы" + chr(4) + "" + chr(8)
 + "attr-code" + chr(4) + "Атрибут" + chr(4) + "" + chr(8)
 + "type" + chr(4) + "Тип карты" + chr(4) + "" + chr(8)
 + "emitent-host-code" + chr(4) + "Код фирмы-эмитента" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dis-card-type.action = integer('1':U))
                                            ,input  (buf_c-dis-card-type.action = integer('99':U))
                                            ,input  buffer current_c-dis-card-type-attr:handle
                                            ,input  'dis-card-type-attr':U
                                            ,input  "attr-value,obj-type,obj-code,host-code,attr-code,type,emitent-host-code"
                                            ,input  v-label-param).
end.
end procedure.
function view-cc-run returns character ( input p-cc-run-chr as character):
if p-cc-run-chr = '' then p-cc-run-chr = '0':U.
return  entry (lookup (p-cc-run-chr, '0,1':U), 'Нет_алгоритма,Алгоритм_Луна':U).
end.
function view-use-on returns character ( input p-use-on-chr as character):
if p-use-on-chr = '' then p-use-on-chr = '0':U.
return  entry (lookup (p-use-on-chr, '0,1,2':U), 'Касса_и_TH,ТОЛЬКО_касса,ТОЛЬКО_TH':U).
end.
procedure dis-card-mask-proc :
define output parameter p-description as character no-undo .
define buffer current_c-dis-card-mask for ub.c-dis-card-mask  .
  do
  on error undo, return error
  :
    find first current_c-dis-card-mask no-lock where
               current_c-dis-card-mask.chip-num = p-chip-num
           AND current_c-dis-card-mask.corr-user-db-num = p-corr-user-db-num
           AND current_c-dis-card-mask.mask-num = buf_c-dis-card-type.mask-num
           no-error .
    if not avail current_c-dis-card-mask then do:
       v-mess = "Неверная ссылка на c-dis-card-mask в таблице c-dis-card-type".
       run err-mess(input-output v-mess).
    end.
              define variable v-label-param as character no-undo .
v-label-param =
  "emitent-host-code" + chr(4) + "Код фирмы-эмитента" + chr(4) + "" + chr(8)
 + "host-code" + chr(4) + "Код фирмы" + chr(4) + "" + chr(8)
 + "cli-code" + chr(4) + "Код контрагента" + chr(4) + "" + chr(8)
 + "cli-mask" + chr(4) + "Маска КОРОТКОГО №" + chr(4) + "" + chr(8)
 + "cli-type" + chr(4) + "Тип контрагента" + chr(4) + "" + chr(8)
 + "mask" + chr(4) + "Маска" + chr(4) + "" + chr(8)
 + "mask-num" + chr(4) + "Номер маски" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "rank" + chr(4) + "Ранг (приоритет)" + chr(4) + "" + chr(8)
 + "stts" + chr(4) + "Статус" + chr(4) + "" + chr(8)
 + "cc-run" + chr(4) + "Алгоритм КЦ" + chr(4) + "view-cc-run" + chr(8)
 + "use-on" + chr(4) + "Используется на" + chr(4) + "view-use-on" + chr(8)
 + "type" + chr(4) + "Тип карты" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dis-card-type.action = integer('1':U))
                                            ,input  (buf_c-dis-card-type.action = integer('99':U))
                                            ,input  buffer current_c-dis-card-mask:handle
                                            ,input  'dis-card-mask':U
                                            ,input  "emitent-host-code,host-code,cli-code,cli-mask,cli-type,mask,mask-num,obj-code,obj-type,rank,stts,cc-run,use-on,type"
                                            ,input  v-label-param).
end.
end procedure.
procedure rp-by-call-proc :
define output parameter p-description as character no-undo .
define buffer current_c-rp-by-call for ub.c-rp-by-call .
  do
  on error undo, return error
  :
    find first current_c-rp-by-call no-lock where
               current_c-rp-by-call.chip-num = buf_c-dis-card-type.chip-num
           AND current_c-rp-by-call.corr-user-db-num = buf_c-dis-card-type.corr-user-db-num
           AND current_c-rp-by-call.call_id = buf_c-dis-card-type.uniq-key-rec no-error .
    if not avail current_c-rp-by-call then do:
       v-mess = "Неверная ссылка на c-rp-by-call в таблице c-dis-card-type".
       run err-mess(input-output v-mess).
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "call_id" + chr(4) + "Точка вызова" + chr(4) + "calldscr" + chr(8)
 + "call#_id" + chr(4) + "Уник.идент.точки вызова" + chr(4) + "" + chr(8)
 + "profile_id" + chr(4) + "Профайл" + chr(4) + "" .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dis-card-type.action = integer('1':U))
                                            ,input  (buf_c-dis-card-type.action = integer('99':U))
                                            ,input  buffer current_c-rp-by-call:handle
                                            ,input  'rp-by-call':U
                                            ,input  "call_id,call#_id,profile_id"
                                            ,input  v-label-param).
end.
end procedure.
procedure rule-by-call-proc :
define output parameter p-description as character no-undo .
define buffer current_c-rule-by-call for ub.c-rule-by-call .
  do
  on error undo, return error
  :
    find first current_c-rule-by-call no-lock where
               current_c-rule-by-call.chip-num = buf_c-dis-card-type.chip-num
           AND current_c-rule-by-call.corr-user-db-num = buf_c-dis-card-type.corr-user-db-num
           AND current_c-rule-by-call.call_id = buf_c-dis-card-type.uniq-key-rec no-error .
    if not avail current_c-rule-by-call then do:
       v-mess = "Неверная ссылка на c-rule-by-call в таблице c-dis-card-type".
       run err-mess(input-output v-mess).
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "call_id" + chr(4) + "Точка вызова" + chr(4) + "calldscr" + chr(8)
 + "call#_id" + chr(4) + "Уник.идент.точки вызова" + chr(4) + "" + chr(8)
 + "profile_id" + chr(4) + "Профайл" + chr(4) + ""  + chr(8)
 + "can-calc" + chr(4) + "Включено" + chr(4) + ""  + chr(8)
 + "can-run" + chr(4) + "Может быть включено" + chr(4) + ""  + chr(8)
 + "codex_id" + chr(4) + "Кодекс" + chr(4) + ""  + chr(8)
 + "ruleset_id" + chr(4) + "Набор правил" + chr(4) + ""  + chr(8)
 + "order_id" + chr(4) + "Порядок вызова" + chr(4) + ""  + chr(8)
 + "rule_id" + chr(4) + "№ правила" + chr(4) + ""  + chr(8)
 + "algo-des" + chr(4) + "Описание правила" + chr(4) + ""  + chr(8)
 + "is_dynamic" + chr(4) + "Отключаемое" + chr(4) + ""
 .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dis-card-type.action = integer('1':U))
                                            ,input  (buf_c-dis-card-type.action = integer('99':U))
                                            ,input  buffer current_c-rule-by-call:handle
                                            ,input  'rule-by-call':U
                                            ,input  "call_id,call#_id,profile_id,can-calc,can-run,codex_id,ruleset_id,order_id,algo-des,rule_id,is_dynamic"
                                            ,input  v-label-param).
end.
end procedure.
procedure rule-call-param-proc :
define output parameter p-description as character no-undo .
define buffer current_c-rule-call-param for ub.c-rule-call-param .
  do
  on error undo, return error
  :
    find first current_c-rule-call-param no-lock where
               current_c-rule-call-param.chip-num = buf_c-dis-card-type.chip-num
           AND current_c-rule-call-param.corr-user-db-num = buf_c-dis-card-type.corr-user-db-num
           AND current_c-rule-call-param.call_id = buf_c-dis-card-type.uniq-key-rec no-error .
    if not avail current_c-rule-call-param then do:
       v-mess = "Неверная ссылка на c-rule-call-param в таблице c-dis-card-type".
       run err-mess(input-output v-mess).
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "call_id" + chr(4) + "Точка вызова" + chr(4) + "calldscr" + chr(8)
 + "call#_id" + chr(4) + "Уник.идент.точки вызова" + chr(4) + "" + chr(8)
 + "profile_id" + chr(4) + "Профайл" + chr(4) + ""  + chr(8)
 + "codex_id" + chr(4) + "Кодекс" + chr(4) + ""  + chr(8)
 + "ruleset_id" + chr(4) + "Набор правил" + chr(4) + ""  + chr(8)
 + "order_id" + chr(4) + "Порядок вызова" + chr(4) + ""  + chr(8)
 + "rule_id" + chr(4) + "№ правила" + chr(4) + ""  + chr(8)
 + "param-des" + chr(4) + "Описание параметра" + chr(4) + ""  + chr(8)
 + "param-data-type" + chr(4) + "Тип данных" + chr(4) + ""  + chr(8)
 + "param-2-data-type" + chr(4) + "Тип данных2" + chr(4) + ""  + chr(8)
 + "param-3-data-type" + chr(4) + "Тип данных3" + chr(4) + ""  + chr(8)
 + "param-label" + chr(4) + "Лейбл параметра" + chr(4) + ""  + chr(8)
 + "param-mode" + chr(4) + "Мода параметра" + chr(4) + ""  + chr(8)
 + "param-name" + chr(4) + "Имя параметра" + chr(4) + ""  + chr(8)
 + "p-index" + chr(4) + "Индекс" + chr(4) + ""  + chr(8)
 + "param-num" + chr(4) + "№ параметра" + chr(4) + ""  + chr(8)
 + "param-value-character" + chr(4) + "Значение параметра" + chr(4) + ""  + chr(8)
 + "param-value-date" + chr(4) + "Значение параметра" + chr(4) + ""  + chr(8)
 + "param-value-decimal" + chr(4) + "Значение параметра" + chr(4) + ""  + chr(8)
 + "param-value-integer" + chr(4) + "Значение параметра" + chr(4) + ""  + chr(8)
 + "param-value-logical" + chr(4) + "Значение параметра" + chr(4) + ""
 .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dis-card-type.action = integer('1':U))
                                            ,input  (buf_c-dis-card-type.action = integer('99':U))
                                            ,input  buffer current_c-rule-call-param:handle
                                            ,input  'rule-call-param':U
                                            ,input  "call_id,call#_id,profile_id,codex_id,ruleset_id,order_id,rule_id,param-des,param-data-type,param-label,param-mode,param-name,param-num,param-value-character,param-value-date,param-value-decimal,param-value-integer,param-value-logical"
                                            ,input  v-label-param).
end.
end procedure.
procedure dis-dct-rule-proc :
define output parameter p-description as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-dis-dct-rule for ub.c-dis-dct-rule  .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first current_c-dis-dct-rule no-lock where
               current_c-dis-dct-rule.type = p-type
           and current_c-dis-dct-rule.emitent-host-code = p-emitent-host-code
           AND current_c-dis-dct-rule.chip-num = p-chip-num
           AND current_c-dis-dct-rule.corr-user-db-num = p-corr-user-db-num    no-error .
    if not avail current_c-dis-dct-rule then do:
       v-mess = "Неверная ссылка на c-dis-dct-rule в таблице c-dc-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.
    run disdctru-name in this-procedure (
                input  current_c-dis-dct-rule.templ-rl-root
                ,output v-label
                ) no-error .
    assign
    p-description = substitute("Тип скидки &1", v-label)
    .
define variable v-label-param as character no-undo .
v-label-param =
  "rule-num" + chr(4) + "Номер правила скидки" + chr(4) + "" + chr(8)
 + "pos-type" + chr(4) + "Место использ" + chr(4) + "cd-type-name-f" + chr(8)
 + "templ-rl-root" + chr(4) + "Тип шаблона" + chr(4) + "disdctru-get-disc-label"  + chr(8)
 + "discnt-role" + chr(4) + "Тип скидки" + chr(4) + "disdctru-get-disc-role-label" + chr(8)
 + "host-code" + chr(4) + "Код фирмы" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4)  + ""
 .
  run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dis-card-type.action = integer('1':U))
                                            ,input  (buf_c-dis-card-type.action = integer('99':U))
                                            ,input  buffer current_c-dis-dct-rule:handle
                                            ,input  'dis-dct-rule':U
                                            ,input  "rule-num,pos-type,templ-rl-root,discnt-role,host-code,obj-type,obj-code"
                                            ,input  v-label-param).
end.
end procedure.
FUNCTION get-hn-label RETURNS CHARACTER
  ( INPUT p-hn-option AS character ) :
  RETURN entry (lookup (p-hn-option, '0,-1,1,10,-10':U) + 1, ',' + 'Да,Нет,Смарт2,Всегда,Никогда':U).
END FUNCTION.
function cd-type-name-f returns character ( input p-cd-type-code as character):
if p-cd-type-code = '':U then return '':U.
return entry (lookup (p-cd-type-code, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U).
end function.
procedure hist-nws-option-proc :
define output parameter p-description as character no-undo .
define buffer buf_c-table-bind for ub.c-table-bind.
define buffer curr_c-hist-nws-option for ub.c-hist-nws-option .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
    find first buf_c-table-bind no-lock where
              buf_c-table-bind.corr-user-db-num = buf_c-dis-card-type.corr-user-db-num
          AND buf_c-table-bind.tbl-name-rec     = 'c-dis-card-type':U
          AND buf_c-table-bind.chip-num-rec     = buf_c-dis-card-type.chip-num no-error .
    if not available buf_c-table-bind then do:
      v-mess = "Неверная ссылка на c-table-bind в таблице c-dis-card-type".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    find first curr_c-hist-nws-option no-lock where
               curr_c-hist-nws-option.subject-group = 'c-dc-hist':U
           AND curr_c-hist-nws-option.charkey_one = buf_c-dis-card-type.type
           AND curr_c-hist-nws-option.host-code = buf_c-dis-card-type.emitent-host-code
           AND curr_c-hist-nws-option.corr-user-db-num = buf_c-table-bind.corr-user-db-num
           AND curr_c-hist-nws-option.chip-num = buf_c-table-bind.chip-num-src  no-error .
    if not avail curr_c-hist-nws-option then do:
      v-mess = "Неверная ссылка на c-hist-nws-option в таблице c-table-bind".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    assign
    p-description = substitute("&1 (для БД &2)", curr_C-hist-nws-option.option-descr, curr_C-hist-nws-option.db-num).
define variable v-label-param as character no-undo .
v-label-param =
  "option-descr" + chr(4) + "Описание" + chr(4) + "" + chr(8)
 + "db-num" + chr(4) + "БД" + chr(4) + "" + chr(8)
 + "hn-id" + chr(4) + "ID" + chr(4) + "" + chr(8)
 + "table-name" + chr(4) + "Таблица/Сущность" + chr(4) + "" + chr(8)
 + "subject-group" + chr(4) + "Группа данных" + chr(4) + "" + chr(8)
 + "get-hist-from-nws" + chr(4) + "Прием истории из другой УБД" + chr(4) + "get-hn-label" + chr(8)
 + "hist-from-prim" + chr(4) + "Запись истории при непосред.изменении" + chr(4) + "get-hn-label" + chr(8)
 + "hist-to-nws" + chr(4) + "Пересылка ист. в другие БД" + chr(4) + "get-hn-label" + chr(8)
 + "nws-to-hist" + chr(4) + "Создание ист. при приеме по СПН" + chr(4) + "get-hn-label" + chr(8)
 + "smart-nws" + chr(4) + "Оптимизированная маршрутизация" + chr(4) + "get-hn-label" + chr(8)
 + "nws-to-cd" + chr(4) + "Активация посылки на кассу при приеме из СПН" + chr(4) + "get-hn-label"
 .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dis-card-type.action = integer('1':U))
                                            ,input  (buf_c-dis-card-type.action = integer('99':U))
                                            ,input  buffer curr_c-hist-nws-option:handle
                                            ,input  'hist-nws-option':U
                                            ,input  "option-descr,db-num,hn-id,table-name,subject-group,get-hist-form-nws,hist-from-prim,hist-to-nws,nws-to-hist,smart-nws,nws-to-cd"
                                            ,input  v-label-param).
  end.
end procedure.
PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  p-mess =
  substitute("История типов ДК: Эмитент &1 тип &2: щепка &6 БД:&7 фирма: &3 объект: &4&5 Предмет изменений &8"
              ,p-emitent-host-code
              ,p-type
              ,p-host-code
              ,p-obj-type
              ,p-obj-code
              ,p-chip-num
              ,p-corr-user-db-num
              ,p-subject) + chr(10) + p-mess
              .
  CASE p-silent:
    when yes then do:
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
