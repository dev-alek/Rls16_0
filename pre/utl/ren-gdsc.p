block-level on error undo, throw.
define input  parameter old-gds-code  like ub.goods.gds-code  no-undo .
define input  parameter new-gds-code  like ub.goods.gds-code  no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ren-gdsc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ren-gdsc.p $":U .
define variable vss-description as character no-undo init "Изменение gds-code для одного товара".
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
    assign
      p-vss-parameters = substitute('&1|&2':u,old-gds-code,new-gds-code)
    .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
procedure goodsh_write-goods-proc  :
define parameter buffer buf_goods for ub.goods .
define input parameter p-action as integer no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_c-goods for ub.c-goods.
  do
  on error undo, return error
  :
    if not available buf_goods then do:
      undo, return error (vss-workfile + chr(32) + vss-revision + chr(32) + vss-description  + chr(10) +
                    "Ошибка задания входных параметров:Не определен товар" ).
    end.
    if g#news then do:
      define variable v-send as integer no-undo .
      v-send = integer('0':U).
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'goods':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  0
  ,input  0
  ,input  'nws-to-hist'
  ,output v-send
  ) no-error .
      if v-send < 0 then return.
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-goods.
    buffer-copy buf_goods to buf_c-goods
    assign
    buf_c-goods.gds-code             = buf_goods.gds-code
    buf_c-goods.chip-num           = next-value (s-gds-chip, ub)
    buf_c-goods.corr-time          = v-time
    buf_c-goods.corr-user-db-num   = g#db-num
    buf_c-goods.corr-user-name     = (if g#news then (chr(4) +  'СПН':U)
                                      else (if g#esys
                                            then (chr(4) +  'ВС':U)
                                            else g#userid)
                                            )
    buf_c-goods.corr-date          = v-date
    .
    create buf_c-gds-hist.
    buffer-copy buf_c-goods to buf_c-gds-hist
    assign
    buf_c-gds-hist.action =  p-action
    buf_c-gds-hist.subject = 'goods':U
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.source-type = p-source-type
    buf_c-gds-hist.source-ref = p-source-ref
    .
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable attach-list as character no-undo initial '~
abc-analysis-attr~
,abc-analysis-doc~
,abc-analysis-gds-obj~
,abc-analysis-gds-obj-attr~
,abc-analysis-goods~
,abc-analysis-goods-attr~
,abc-analysis-grp~
,abc-analysis-obj~
,abc-analysis-period~
,abc-analysis-prod~
,abcxyz-analysis-attr~
,abcxyz-analysis-goods~
,abcxyz-analysis-goods-attr~
,add-line~
,add-trn~
,add-trn-attr~
,arh-trn-doc-contract~
,c-buyer-in-buyer-group~
,c-buyer-group~
,c-pl-gds-obj~
,c-sht-hist~
,cd-doc-line~
,c-cd-doc-line~
,chk-discnt~
,chk-discnt-attr~
,c-chk-discnt~
,chk-doc~
,chk-doc-attr~
,c-chk-doc-attr~
,chk-gds~
,chk-gds-attr~
,marking-chk~
,c-marking-chk~
,c-marking-attr~
,c-chk-gds~
,chk-pay~
,chk-gds-attr~
,chk-pay-attr~
,c-chk-pay~
,contract-line~
,contract-specif-attr~
,c-contract-line~
,db-grp-obj-price~
,c-db-grp-obj-price~
,doc-abc-def-doc~
,doc-abc-def-obj~
,c-doc-attr~
,doc-fbr-gds~
,c-doc-fbr-gds~
,doc-line~
,c-doc-line~
,doc-line-attr~
,c-doc-line-attr~
,doc-line-sum~
,c-doc-line-sum~
,doc-pl~
,c-doc-pl~
,doc-pl-pump~
,c-doc-pl-pump~
,doc-prts~
,c-doc-prts~
,doc-xyz-def-doc~
,doc-xyz-def-obj~
,esys-route-dump~
,factur-connect-line~
,fbr-line~
,c-fbr-line~
,fbr-pln-line~
,c-fbr-pln-line~
,c-fin-code-an-uchet~
,c-fin-code-cel-nazn~
,c-fin-code-cor-acc~
,fin-doc-attr~
,c-fin-doc-attr~
,fin-doc-tax~
,c-fin-doc-tax~
,fin-gds-part~
,c-fin-gds-part~
,fin-ob-attr~
,c-fin-ob-attr~
,fin-ob-tax~
,c-fin-ob-tax~
,fin-ob-tax-before~
,fin-ob-trn~
,fin-statement-attr~
,c-fin-statement-attr~
,fin-statement-line~
,c-fin-statement-line~
,gds-dtl~
,c-gds-dtl~
,c-global-state~
,global-state-attr~
,c-global-state-attr~
,host-grp-obj-price~
,c-host-grp-obj-price~
,icnt-line~
,inkas-pay~
,c-inkas-pay~
,inkas-pay-desk~
,c-inkas-pay-desk~
,inkas-pay-wth~
,c-inkas-pay-wth~
,inv-doc~
,inv-line~
,c-inv-line~
,layout-elem-rule~
,obj-grp-obj-price~
,c-obj-grp-obj-price~
,ord-cons-attr~
,ord-cons-line-attr~
,ord-doc-attr~
,c-ord-doc-attr~
,ord-dtl~
,c-ord-dtl~
,ord-dtl-cons~
,ord-dtl-rcv~
,ord-gds-cons~
,ord-line~
,c-ord-line~
,ord-line-attr~
,c-ord-line-attr~
,ord-line-rcv~
,ord-rcv-attr~
,ord-rcv-line-attr~
,c-parts~
,c-parts-attr~
,parts-root~
,c-parts-root~
,esys-pck-keys~
,c-price-doc-forming~
,price-doc-forming-attr~
,c-price-doc-forming-attr~
,price-doc-forming-gds~
,c-price-doc-forming-gds~
,price-doc-forming-gdsattr~
,c-price-doc-forming-gdsattr~
,price-doc-forming-gds-qnty~
,c-price-doc-forming-gds-qnty~
,price-doc-forming-gds-sum~
,c-price-doc-forming-gds-sum~
,price-doc-forming-gds-tnv~
,c-price-doc-forming-gds-tnv~
,price-list~
,c-price-list~
,price-list-attr~
,c-price-list-attr~
,price-list-type-attr~
,c-price-list-type-attr~
,price-list-type-cash-pay~
,c-price-list-type-cash-pay~
,price-list-type-cassa~
,c-price-list-type-cassa~
,price-list-type-gds-grp~
,c-price-list-type-gds-grp~
,price-list-type-pay-type~
,c-price-list-type-pay-type~
,c-qnty-group~
,qnty-in-qnty-group~
,c-qnty-in-qnty-group~
,rang-abc-def-obj~
,rang-xyz-def-obj~
,rule-i-script~
,rule-script~
,rule-trans-memo~
,rvs-line~
,rvs-line-attr~
,c-rvs-line~
,rvs-line-pump~
,c-rvs-line-pump~
,rvs-pump~
,sale-doc~
,c-sale-doc~
,schet-fact-line~
,c-schet-fact-line~
,shift-cash~
,c-shift-obj~
,shift-staff~
,c-shift-staff~
,shift-attr~
,c-shift-attr~
,stop-list-line~
,c-sum-group~
,sum-in-sum-group~
,c-sum-in-sum-group~
,c-turnover-group~
,tnv-in-turnover-group~
,c-tnv-in-turnover-group~
,trn-doc-sum~
,c-trn-doc-sum~
,c-trn-reason~
,trn-reason-host~
,c-trn-reason-host~
,trn-reason-obj~
,c-trn-reason-obj~
,trn-rsn-attr~
,c-trn-rsn-attr~
,turnover-buyer~
,turnover-buyer-attr~
,turnover-buyer-gds~
,turnover-buyer-gds-attr~
,wi-mode~
,wth-dtl~
,c-wth-dtl~
,wth-line~
,c-wth-line~
,wth-parts~
,c-wth-parts~
,xyz-analysis-attr~
,xyz-analysis-doc~
,xyz-analysis-gds-obj~
,xyz-analysis-gds-obj-attr~
,xyz-analysis-goods~
,xyz-analysis-goods-attr~
,xyz-analysis-obj~
,xyz-analysis-period~
,utd-lines~
,utd-marking-lines~
,utd-err~
,utd-attr~
,utd-lines-attr~
,utd-marking-lines-attr~
,utd-err-attr~
,marking~
,marking-lines~
,order-doc~
,order-line~
,reportShift~
,shift-param~
,susp-chk~
':U .
define variable news-list as character no-undo initial '~
abc-analysis~
,abcxyz-analysis~
,add-doc~
,action-post~
,action-post-host~
,action-post-menu-group~
,action-post-obj~
,action-post-role~
,action-post-user-login~
,action-role~
,c-action-role~
,action-role-item~
,c-action-role-item~
,action-role-item-gds~
,action-role-item-gds-grp~
,alc-sale-lic~
,c-alc-sale-lic~
,alc-sale-lic-attr~
,c-alc-sale-lic-attr~
,alc-sale-lic-type~
,c-alc-sale-lic-type~
,alc-supp-lic~
,c-alc-supp-lic~
,alc-supp-lic-attr~
,c-alc-supp-lic-attr~
,alc-supp-lic-type~
,c-alc-supp-lic-type~
,alc-type~
,c-alc-type~
,alc-type-attr~
,c-alc-type-attr~
,alc-type-gds~
,c-alc-type-gds~
,arh-fin-doc-an~
,arh-fin-doc-an-nal~
,arh-fin-doc-c-schet-tax-nal~
,arh-fin-doc-contr-schet~
,arh-fin-doc-contr-schet-nal~
,arh-fin-doc-contr-schet-tax~
,arh-fin-doc-schet~
,arh-fin-doc-schet-nal~
,arh-fin-doc-schet-tax~
,arh-fin-doc-schet-tax-nal~
,arh-fin-doc-contr-schet-obj~
,arh-fin-doc-contr-s-nal-obj~
,arh-fin-doc-contr-s-tax-obj~
,arh-fin-doc-c-s-tax-nal-obj~
,arh-fin-doc-schet-obj~
,arh-fin-doc-schet-nal-obj~
,arh-fin-ob-contr~
,attr-prop~
,auto-tank~
,c-auto-tank~
,auto-tank-meas~
,auto-tank-attr~
,auto-section~
,c-auto-section~
,auto-section-attr~
,c-auto-section-attr~
,auto-section-table~
,c-auto-section-table~
,bar-code~
,c-bar-code~
,bar-code-attr~
,c-bar-code-attr~
,bar-code-obj-attr~
,c-bar-code-obj-attr~
,blob-bind~
,buyer-group~
,buyer-in-buyer-group~
,c-cli-hist~
,c-dc-hist~
,c-fbr-gds-grp-hist~
,c-gds-grp-hist~
,c-gds-hist~
,c-nzl-hist~
,c-plc-hist~
,c-pmp-hist~
,c-recipe-hist~
,c-table-bind~
,c-tax-hist~
,c-usr-hist~
,c-wth-hist~
,cash-desk~
,c-cash-desk~
,cash-desk-attr~
,c-cash-desk-attr~
,cash-pay~
,c-cash-pay~
,cash-pay-attr~
,c-cash-pay-attr~
,cd-clu~
,c-cd-clu~
,cd-dlu~
,c-cd-dlu~
,cd-doc~
,c-cd-doc~
,cd-events~
,cd-events-attr~
,cd-event-log~
,cd-event-log-attr~
,cd-grp~
,c-cd-grp~
,cd-plu~
,c-cd-plu~
,c-chk-doc~
,cd-trans~
,cd-video-link~
,cd-video-link-attr~
,cli-art~
,cli-gds~
,cli-grp~
,c-cli-grp~
,clients~
,c-clients~
,clients-attr~
,c-clients-attr~
,clob-bind~
,code-range~
,condition-keeping~
,c-condition-keeping~
,config~
,c-config~
,contract~
,c-contract~
,contract-attr~
,contract-specif~
,c-contract-specif~
,country~
,c-country~
,criterion-analysis~
,cshr-month~
,curr-accnt~
,c-curr-accnt~
,curr-bank~
,c-curr-bank~
,curr-shop~
,currency~
,custom-labels~
,datatype-exp~
,datatype-exp-attr~
,datatype-imp~
,datatype-imp-attr~
,datatype-table~
,datatype-table-exp~
,datatype-table-field~
,datatype-table-field-exp~
,datatype-table-field-imp~
,datatype-table-imp~
,db~
,c-db~
,db-attr~
,db-info~
,db-status~
,deliv-type-cond-keep~
,c-deliv-type-cond-keep~
,delivery-subject~
,c-delivery-subject~
,delivery-type~
,c-delivery-type~
,delivery-type-subject~
,c-delivery-type-subject~
,dis-card~
,c-dis-card~
,dis-card-long~
,c-dis-card-long~
,dis-card-mask~
,c-dis-card-mask~
,dis-card-mask-attr~
,c-dis-card-mask-attr~
,dis-card-property~
,c-dis-card-property~
,dis-card-type~
,c-dis-card-type~
,dis-card-type-attr~
,c-dis-card-type-attr~
,dis-cfg-rule~
,c-dis-cfg-rule~
,dis-cp-rule~
,c-dis-cp-rule~
,dis-dc-rule~
,c-dis-dc-rule~
,dis-dct-rule~
,c-dis-dct-rule~
,dis-gds-rule~
,c-dis-gds-rule~
,dis-gds-rule-attr~
,dis-grp-rule~
,c-dis-grp-rule~
,dis-host~
,c-dis-host~
,dis-obj~
,c-dis-obj~
,dis-rule~
,c-dis-rule~
,dis-some-rule~
,c-dis-some-rule~
,dis-thbj-rule~
,c-dis-thbj-rule~
,dis-time-rule~
,c-dis-time-rule~
,doc-abc-def~
,doc-attr~
,doc-xyz-def~
,drt-prop~
,c-drt-prop~
,edi-status~
,esys-all-attr~
,esys-datatype-exp~
,c-esys-datatype-exp~
,esys-datatype-imp~
,c-esys-datatype-imp~
,esys-pck-rcvd~
,esys-pck-rcvd-err~
,esys-pck-sent~
,esys-route~
,ex-mark~
,c-ex-mark~
,ext-artic~
,c-ext-artic~
,ext-artic-attr~
,c-ext-artic-attr~
,ext-classif~
,c-ext-classif~
,ext-file~
,ext-file-line~
,ext-file-par~
,ext-system~
,c-ext-system~
,ext-system-attr~
,factur-connect~
,fbr-doc~
,c-fbr-doc~
,fbr-gds-grp~
,c-fbr-gds-grp~
,fbr-gds-grp-attr~
,c-fbr-gds-grp-attr~
,fbr-gds-obj~
,c-fbr-gds-obj~
,fbr-history~
,fbr-pln~
,c-fbr-pln~
,fbr-prn~
,c-fbr-prn~
,fbr-prn-gds~
,c-fbr-prn-gds~
,fbr-prn-grp~
,c-fbr-prn-grp~
,fbr-recipe~
,fbr-recipe-gds~
,fin-bank~
,c-fin-bank~
,fin-code-an-uchet~
,fin-code-cel-nazn~
,fin-code-cor-acc~
,fin-connect~
,fin-doc~
,c-fin-doc~
,fin-ob~
,c-fin-ob~
,fin-ob-before~
,fin-schet~
,c-fin-schet~
,fin-statement~
,c-fin-statement~
,firm~
,c-firm~
,gds-grp~
,c-gds-grp~
,gds-grp-attr~
,c-gds-grp-attr~
,gds-grp-obj~
,c-gds-grp-obj~
,gds-host-attr~
,c-gds-host-attr~
,gds-obj~
,gds-obj-attr~
,c-gds-obj-attr~
,gds-obj-prop~
,c-gds-obj-prop~
,gds-obj-prop-attr~
,assortment-matrix~
,assortment-matrix-attr~
,c-assortment-matrix~
,assortment-matrix-goods~
,c-assortment-matrix-goods~
,gds-prt~
,c-gds-prt~
,gds-season~
,c-gds-season~
,gds-add-charges~
,c-gds-add-charges~
,gds-grp-obj-attr~
,c-gds-obj-ref~
,global-state~
,goods~
,c-goods~
,goods-attr~
,c-goods-attr~
,group-period-validity~
,c-group-period-validity~
,grp-obj-price~
,c-grp-obj-price~
,hist-nws-option~
,c-hist-nws-option~
,icnt-doc~
,inkas~
,c-inkas~
,layout~
,c-layout~
,layout-elem~
,layout-elem-rule~
,c-layout-elem-rule~
,lvl-name~
,menu-user~
,menu-user-call~
,marking~
,marking-lines~
,nozzle~
,c-nozzle~
,nozzle-attr~
,c-nozzle-attr~
,nws-doc-hist~
,nws-outline~
,obj-date~
,ord-cons~
,ord-doc~
,c-ord-doc~
,ord-doc-rcv~
,ord-chain~
,parts~
,parts-attr~
,pay-type~
,c-pay-type~
,pck-rcvd~
,pck-sent~
,person~
,c-person~
,pl-gds~
,c-pl-gds~
,pl-gds-attr~
,c-pl-gds-attr~
,pl-gds-pump~
,c-pl-gds-pump~
,pl-level~
,pl-level-imp~
,c-pl-level~
,pl-level-mm~
,pl-level-mm-imp~
,pl-pump~
,c-pl-pump~
,pl-pump-nozzle~
,c-pl-pump-nozzle~
,place~
,c-place~
,place-attr~
,c-place-attr~
,place-imp~
,place-imp-attr~
,place-io~
,c-place-io~
,point-io~
,c-point-io~
,point-place-rel~
,c-point-place-rel~
,point-point-rel~
,c-point-point-rel~
,price-all~
,price-doc~
,c-price-doc~
,price-doc-forming~
,c-price-doc-forming~
,price-list-type~
,c-price-list-type~
,prod-bc~
,c-prod-bc~
,prod-bc-db~
,profile-by-profile~
,c-profile-by-profile~
,prop-head~
,c-prop-head~
,prop-map~
,prop-ref~
,c-prop-ref~
,prop-ref-call~
,prop-ruleset~
,prop-script~
,prt-obj~
,pscript-ruleset~
,pump~
,c-pump~
,pump-attr~
,c-pump-attr~
,pump-nozzle~
,c-pump-nozzle~
,qnty-group~
,rang-abc-def~
,rang-xyz-def~
,recipe~
,c-recipe~
,recipe-develop~
,c-recipe-develop~
,recipe-gds~
,c-recipe-gds~
,regions~
,c-regions~
,norm-loss~
,c-norm-loss~
,rp-by-call~
,c-rp-by-call~
,rp-rule-param~
,rpt-option~
,rule~
,rule-by-call~
,c-rule-by-call~
,rule-by-profile~
,rule-by-set~
,rule-call-param~
,c-rule-call-param~
,rule-profile~
,rule-process~
,ruledict~
,c-ruledict~
,ruledict-param~
,ruleset~
,rvs-doc~
,c-rvs-doc~
,s-coeff~
,c-s-coeff~
,scales~
,c-scales~
,scales-attr~
,c-scales-attr~
,scales-gds~
,c-scales-gds~
,scales-grp~
,c-scales-grp~
,schedule~
,schedule-attr~
,schet-fact-doc~
,c-schet-fact-doc~
,season~
,c-season~
,sert~
,c-sert~
,sert-join~
,shift-obj~
,c-shift-obj~
,shift-period~
,shop~
,c-shop~
,some-lk~
,sr-izmerenia~
,c-sr-izmerenia~
,sr-izmerenia-attr~
,c-sr-izmerenia-attr~
,staff~
,c-staff~
,stop-list~
,store~
,c-store~
,sum-group~
,sum-grp~
,c-sum-grp~
,sum-grp-obj~
,c-sum-grp-obj~
,sysconf~
,c-sysconf~
,tare~
,c-tare~
,tax~
,c-tax~
,tax-rate~
,c-tax-rate~
,tax-rate-gds~
,tax-rate-gds-grp~
,c-tax-rate-gds-grp~
,tax-rate-value~
,tax-units~
,c-tax-units~
,thbj-attr~
,c-thbj-attr~
,trn-doc~
,c-trn-doc~
,trn-reason~
,turnover-buyer-main~
,turnover-group~
,units~
,c-units~
,upgrade~
,user-account~
,c-user-account~
,user-context-history~
,user-host~
,user-login~
,c-user-login~
,user-login-action-item~
,user-login-action-role~
,user-login-attr~
,user-menu-group~
,user-obj~
,user-window-attr~
,var-deliv-gr-per-val~
,c-var-deliv-gr-per-val~
,variant-delivery~
,c-variant-delivery~
,varianty-delivery-gds-obj~
,c-varianty-delivery-gds-obj~
,wealth~
,c-wealth~
,who-lk~
,wth-doc~
,c-wth-doc~
,wth-doc-attr
,wth-gds~
,c-wth-gds~
,wth-ser~
,c-wth-ser~
,wth-par~
,c-wth-par~
,wth-place~
,c-wth-place~
,xyz-analysis~
,c-user-log~
,egais-clients~
,c-egais-clients~
,egais-gds~
,c-egais-gds~
,c-vsd~
,c-gds-mercury
,vsd~
,vsd-attr~
,c-gds-mercury~
,gds-mercury~
,gds-mercury-attr~
,units-attr~
,c-promo-schedule~
,c-promo-schedule-week~
,c-PromoAction~
,c-PromoAttr~
,c-PromoCriterion~
,c-PromoGift~
,c-PromoGoods~
,c-PromoObject~
,promo-schedule~
,promo-schedule-week~
,PromoAction~
,PromoAttr~
,PromoCriterion~
,PromoGift~
,PromoGoods~
,PromoObject~
,tech-prol-pwd~
,c-tech-prol-pwd~
,c-CashBook~
,c-CashBookAttr~
,c-CashBookRule~
,c-CashBookRuleAttr~
,c-OperServ~
,c-operServAttr~
,CashBook~
,CashBookAttr~
,CashBookRule~
,CashBookRuleAttr~
,OperServ~
,OperServAttr~
,c-counter~
,counter~
,c-cashbook-head~
,c-goods-attr-any~
,c-promo-head~
,code~
,c-code~
,devisPc~
,devisPc-attr~
,utd~
,c-utd-head~
,c-utd~
,c-utd-head~
,c-utd-lines~
,c-utd-marking-lines~
,c-utd-err~
,c-utd-attr~
,c-utd-lines-attr~
,c-utd-marking-lines-attr~
,c-utd-err-attr~
,marking-attr
,Xattr~
,xGroupObj~
,xstatus~
,c-contract-specif-attr~
,tran-fuel~
,chk-slip-head~
,chk-slip-string~
,c-marking
,order-doc~
,order-line~
,order-doc-attr~
,order-line-attr~
,c-order-head~
,c-order-doc~
,c-order-line~
,c-order-doc-attr~
,c-order-line-attr~
,reportShift~
,shift-param~
,susp-chk~
':U .
define variable oth-list1 as character no-undo .
define variable oth-list2 as character no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ren-route-dump :
  define input parameter p-action          as character no-undo .
  define input parameter p-old-gds-key-rec as character no-undo .
  define input parameter p-tbl-name        as character no-undo .
  define input parameter p-old-artic       as character no-undo .
  define input parameter p-old-prod-type   as character no-undo .
  define input parameter p-old-prod-code   as integer   no-undo .
  define input parameter p-new-artic       as character no-undo .
  define input parameter p-new-prod-type   as character no-undo .
  define input parameter p-new-prod-code   as integer   no-undo .
  define input parameter p-old-gds-code    as integer   no-undo .
  define input parameter p-new-gds-code    as integer   no-undo .
  do
  on error  undo, return error substitute( "&1 (ren-route-dump). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (ren-route-dump). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (ren-route-dump). endkey", vss-workfile )
  :
    define buffer buf_route-dump      for ub.route-dump .
    define buffer buf_route-dump-link for ub.route-dump-link .
    define variable v-is-change as logical no-undo .
    define variable tth           as handle    no-undo .
    define variable tt-name       as character no-undo .
    define variable v-ok          as logical   no-undo .
    define variable bh_tt         as handle    no-undo .
    define variable bh_route-dump as handle    no-undo .
    define variable fh_artic      as handle    no-undo .
    define variable fh_prod-type  as handle    no-undo .
    define variable fh_prod-code  as handle    no-undo .
    define variable fh_gds-code   as handle    no-undo .
    create temp-table tth.
    assign
      tt-name = "tt_" + p-tbl-name
    .
    assign
      v-ok = tth:create-like( "ub.":U + p-tbl-name ) no-error
    .
    if v-ok <> true then do:
      undo, return error substitute( "&1 (ren-route-dump). Ошибка при создании временной таблицы &2 (1)", vss-workfile, tt-name ) .
    end.
    assign
      v-ok = tth:temp-table-prepare( tt-name ) no-error
    .
    if v-ok <> true then do:
      undo, return error substitute( "&1 (ren-route-dump). Ошибка при создании временной таблицы &2 (2)", vss-workfile, tt-name ) .
    end.
    assign
      bh_tt = tth:default-buffer-handle
    .
    assign
      v-ok = bh_tt:buffer-create no-error
    .
    if v-ok <> true then do:
      undo, return error substitute( "&1 (ren-route-dump). Ошибка при создании буфера временной таблицы.", vss-workfile, tt-name ).
    end.
    for each buf_route-dump-link exclusive-lock
      where buf_route-dump-link.uniq-key-rec = p-old-gds-key-rec
        and buf_route-dump-link.dump-name    = p-tbl-name
    on error undo, return error
    :
      for each buf_route-dump exclusive-lock
        where buf_route-dump.dump-ord = buf_route-dump-link.dump-ord
          and buf_route-dump.rec-ord  = buf_route-dump-link.rec-ord
      on error  undo, return error
      :
        assign
          bh_route-dump = buffer buf_route-dump:handle
        .
        assign
          v-ok = bh_tt:raw-transfer ( false, bh_route-dump:buffer-field("value-rec":U) ) no-error
        .
        if v-ok <> true then do:
          undo, return error substitute( "&1 (ren-route-dump). RAW-TRANSFER -> не прошел для таблицы &2. Rowid записи &3", vss-workfile, tt-name, bh_route-dump:rowid ).
        end.
        assign
          v-is-change = false
        .
        case p-action :
          when "ren-art":U then do:
            assign
              fh_artic     = bh_tt:buffer-field("artic":U)
              fh_prod-type = bh_tt:buffer-field("prod-type":U)
              fh_prod-code = bh_tt:buffer-field("prod-code":U)
            .
            if fh_artic:buffer-value  = p-old-artic
              and fh_prod-type:buffer-value = p-old-prod-type
              and fh_prod-code:buffer-value = p-old-prod-code
            then do:
              assign
                fh_artic:buffer-value     = p-new-artic
                fh_prod-type:buffer-value = p-new-prod-type
                fh_prod-code:buffer-value = p-new-prod-code
                v-is-change               = true
              .
            end.
          end.
          when "ren-gds-code":U then do:
            assign
              fh_gds-code = bh_tt:buffer-field("gds-code":U)
            .
            if fh_gds-code:buffer-value = p-old-gds-code then do:
              assign
                fh_gds-code:buffer-value = p-new-gds-code
                v-is-change              = true
              .
            end.
          end.
        end case.
        if v-is-change = true then do:
          assign
            v-ok = bh_tt:raw-transfer ( true, bh_route-dump:buffer-field("value-rec":U) ) no-error
          .
          if v-ok <> true then do:
            undo, return error substitute( "&1 (ren-route-dump). RAW-TRANSFER <- не прошел для таблицы &2. Rowid записи &3", vss-workfile, tt-name, bh_route-dump:rowid ).
          end.
        end.
      end.
    end.
    assign
      v-ok = bh_tt:buffer-delete no-error
    .
    if v-ok <> true then do:
      undo, return error substitute( "&1 (ren-route-dump). Ошибка при удалении буфера временной таблицы.", vss-workfile, tt-name ).
    end.
    assign
      v-ok = tth:clear() no-error
    .
    if v-ok <> true then do:
      undo, return error substitute( "&1 (ren-route-dump). Ошибка при очистке временной таблицы &2", vss-workfile, tt-name ) .
    end.
    delete object tth no-error .
    if error-status:error then do:
      undo, return error substitute( "&1 (ren-route-dump). Ошибка при удалении временной таблицы для &2", vss-workfile, tt-name ).
    end.
  end.
  return.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ren-gds-code :
  define input parameter p-tbl-name        as character no-undo .
  define input parameter p-old-gds-key-rec as character no-undo .
  define input parameter p-old-gds-code    as integer   no-undo .
  define input parameter p-new-gds-code    as integer   no-undo .
  define input parameter p-search-bufs     as character no-undo .
  define input parameter p-search-prefix   as character no-undo .
  define input parameter p-search-suffix   as character no-undo .
  do
  on error  undo, return error substitute( "&1 (ren-gds-code). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (ren-gds-code). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (ren-gds-code). endkey", vss-workfile )
  :
    define variable qh_tbl-name as handle no-undo .
    define variable bh_tbl-name as handle no-undo .
    define variable fh_gds-code as handle no-undo .
    define variable v-query     as character no-undo .
    define variable v-tbl-name  as character no-undo .
    assign
      v-tbl-name = substitute( "ub.&1":U, p-tbl-name )
      v-query    = substitute( "for &1 each &2 where &2.gds-code = &3 &4", p-search-prefix, v-tbl-name, p-old-gds-code, p-search-suffix )
    .
    create buffer bh_tbl-name for table v-tbl-name  .
    bh_tbl-name:disable-load-triggers ( false ).
    create query qh_tbl-name .
    if trim( p-search-bufs ) = "":U
      or p-search-bufs = ?
    then do:
      qh_tbl-name:set-buffers( bh_tbl-name ).
    end.
    else do:
      qh_tbl-name:set-buffers( p-search-bufs, bh_tbl-name ).
    end.
    qh_tbl-name:query-prepare( v-query ).
    qh_tbl-name:query-open() .
    qh_tbl-name:get-first( exclusive-lock ).
    do while qh_tbl-name:query-off-end <> true
    on error  undo, return error substitute( "&1 (ren-gds-code2). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1 (ren-gds-code2). stop", vss-workfile )
    on quit   undo, return error substitute( "&1 (ren-gds-code2). quit", vss-workfile )
    on endkey undo, return error substitute( "&1 (ren-gds-code2). endkey", vss-workfile )
    :
      assign
        fh_gds-code = bh_tbl-name:buffer-field( "gds-code":U )
        fh_gds-code:buffer-value = p-new-gds-code .
      .
      bh_tbl-name:buffer-release() no-error .
      assign
        fh_gds-code = ?
      .
      qh_tbl-name:get-next( exclusive-lock ).
    END.
    qh_tbl-name:query-close() .
    delete object qh_tbl-name.
    delete object bh_tbl-name.
    if g#news = true
      and lookup( p-tbl-name, ( news-list + ",":U + attach-list ) ) <> 0
    then do:
      run ren-route-dump in this-procedure
        ( input "ren-gds-code":U
         ,input p-old-gds-key-rec
         ,input p-tbl-name
         ,input ?
         ,input ?
         ,input ?
         ,input ?
         ,input ?
         ,input ?
         ,input p-old-gds-code
         ,input p-new-gds-code
        ) no-error .
      if error-status :error then do:
        undo, return error substitute( "&1 (ren-gds-code). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
      end.
    end.
  end.
  return .
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure valid-ren-gdsc-tbl-list :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-std-list        as character no-undo .
    define variable v-ignore-list     as character no-undo .
    define variable v-special-list    as character no-undo .
    assign
      v-std-list     = "abc-analysis-gds-obj,abc-analysis-gds-obj-attr,abc-analysis-goods,abc-analysis-goods-attr,abcxyz-analysis-goods,abcxyz-analysis-goods-attr,action-post-role,action-role-item-gds,add-line,c-add-line,aht-gds,aht-gds-attr,aht-ot-line,aht-ot-line-attr,aht-stk-line,aht-stk-line-attr,alc-type-gds,c-alc-type-gds,alc-type-gds-attr,arh-wth-cli,arh-wth-cli-attr,arh-wth-cli-doc,arh-wth-cli-doc-attr,arh-wth-tot,arh-wth-w-p,assortment-matrix-goods,assortment-matrix-goods-attr,c-assortment-matrix-goods,bar-code,bar-code-attr,bar-code-obj-attr,c-bar-code,c-bar-code-attr,c-bar-code-obj-attr,cd-doc-line,c-cd-doc-line,cd-event-log,cd-plu,c-cd-plu,chk-gds-pay,contract-specif,c-contract-specif,contract-specif-attr,dis-gds-rule,c-dis-gds-rule,dis-gds-rule-attr,doc-fbr-gds,c-doc-fbr-gds,doc-fbr-gds-attr,doc-line-attr,c-doc-line-attr,doc-line-sum,c-doc-line-sum,doc-pl,doc-pl-attr,c-doc-pl,doc-pl-pump,doc-pl-pump-attr,c-doc-pl-pump,doc-prts,c-doc-prts,ext-artic,c-ext-artic,ext-artic-attr,c-ext-artic-attr,ext-artic-db,ext-artic-db-attr,ext-artic-host,ext-artic-host-attr,ext-artic-obj,ext-artic-obj-attr,factur-connect-line,fbr-history,fbr-gds-obj,c-fbr-gds-obj,fbr-gds-obj-attr,c-fbr-gds-obj-attr,fbr-pln-line,c-fbr-pln-line,c-fbr-prn,fbr-prn-gds,c-fbr-prn-gds,fbr-prn-gds-attr,fbr-recipe,fbr-recipe-gds,fin-gds-part,fin-gds-part-attr,c-fin-gds-part,c-gds-hist,gds-add-charges,gds-add-charges-attr,c-gds-add-charges,c-gds-add-charges-attr,gds-host-attr,c-gds-host-attr,gds-obj,c-gds-obj,c-gds-obj-ref,gds-obj-attr,c-gds-obj-attr,gds-obj-flag,gds-obj-flag-attr,gds-obj-prop,gds-obj-prop-attr,c-gds-obj-prop,gds-season,gds-season-attr,c-gds-season,c-goods,goods-attr,c-goods-attr,hold-sale,hold-goods,hold-purch,hold-purch-supp-gds,hold-sale-attr,hold-goods-attr,hold-purch-attr,hold-purch-supp-gds-attr,icnt-line,ord-cons-line-attr,ord-dtl,c-ord-dtl,ord-line,c-ord-line,c-ord-line-attr,ord-line-attr,ord-line-rcv,ord-rcv-line-attr,parts-attr,parts-add,c-parts-add,parts-add-attr,c-parts-attr,parts-obj-attr,c-parts-obj-attr,parts-root,parts-root-attr,c-parts-root,pl-gds,c-pl-gds,c-pl-gds-obj,pl-gds-attr,c-pl-gds-attr,c-plc-hist,c-pmp-hist,pl-gds-pump,c-pl-gds-pump,pl-gds-pump-attr,c-pl-gds-pump-attr,price-all,rcs-retail1product,recipe,c-recipe,c-recipe-gds,recipe-gds,recipe-develop,c-recipe-develop,c-recipe-hist,rvs-line,rvs-line-attr,c-rvs-line,rvs-pump,rvs-line-pump,rvs-line-pump-attr,c-rvs-line-pump,s-coeff,c-s-coeff,s-coeff-attr,schet-fact-line,c-schet-fact-line,tax-rate-gds,tax-rate-gds-attr,turnover-buyer-gds,turnover-buyer-gds-attr,user-login-action-item,user-login-action-role,varianty-delivery-gds-obj,c-varianty-delivery-gds-obj,wth-dtl,c-wth-dtl,wth-gds,c-wth-gds,wth-gds-attr,c-wth-gds-attr,wth-dtl,c-wth-dtl,wth-parts,c-wth-parts,xyz-analysis-gds-obj,xyz-analysis-gds-obj-attr,xyz-analysis-goods,xyz-analysis-goods-attr,egais-gds,c-egais-gds,vsd,c-vsd,gds-mercury,c-gds-mercury,PromoGift,PromoGoods,c-PromoGift,c-PromoGoods,OperServ,c-OperServ,c-goods-attr-any,utd-lines,c-utd-marking-lines,c-utd-lines,marking-lines,utd-marking-lines,marking,c-contract-specif-attr,c-marking,order-line,c-order-line,shift-param":U
      v-ignore-list  = "shift-period":U
      v-special-list = "goods":U
    .
def var vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-inform      as character no-undo .
    define variable bh_tbl-name   as handle    no-undo .
    define variable v-tbl-not-idx as character no-undo .
    define variable v-idx-avail   as logical   no-undo .
    define variable new-tbl-list  as character no-undo .
    define variable old-tbl-list  as character no-undo .
    define variable old-tbl-avail as logical   no-undo .
    define variable v-double-tbl  as character no-undo .
    define variable v-tbl-name    as character no-undo .
    define variable v-msg         as character no-undo .
    assign
      v-msg         = "":U
      v-tbl-not-idx = "":U
      new-tbl-list  = "":U
    .
    for each ub._Field no-lock
      where ub._Field._Field-Name = 'gds-code':U
    ,first ub._File of ub._Field
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      if  lookup( ub._File._File-Name, v-std-list     ) = 0
      and lookup( ub._File._File-Name, v-ignore-list  ) = 0
      and lookup( ub._File._File-Name, v-special-list ) = 0
      then do:
        assign
          new-tbl-list = new-tbl-list + chr(10) + ub._File._File-Name
        .
      end.
      if lookup( ub._File._File-Name, v-std-list ) <> 0
        or lookup( ub._File._File-Name, new-tbl-list, chr(10) ) <> 0
      then do:
        create buffer bh_tbl-name for table substitute( "ub.&1":U, ub._File._File-Name ) .
        assign
          v-idx-avail = false
          v-inform    = bh_tbl-name:index-information(1)
          v-ind       = 2
        .
        block_chk-idx:
        do while v-inform <> ?
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          if v-inform <> ?
              and lookup( entry( 5, v-inform, ",":U ), 'gds-code':U ) > 0
          then do:
            assign
              v-idx-avail = true
            .
            leave block_chk-idx.
          end.
          assign
            v-inform = bh_tbl-name:index-information( v-ind )
            v-ind    = v-ind + 1
          .
        end.
        if v-idx-avail = false then do:
          if lookup( ub._File._File-Name, new-tbl-list, chr(10) ) <> 0 then do:
            assign
              new-tbl-list = new-tbl-list + " (индекса нет)"
            .
          end.
          else do:
            assign
              v-tbl-not-idx = v-tbl-not-idx + chr(10) + ub._File._File-Name
            .
          end.
        end.
        delete object bh_tbl-name.
      end.
    end.
    assign
      old-tbl-list  = "":U
      v-double-tbl  = "":U
      v-num-entries = num-entries( v-std-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name    = entry( v-ind, v-std-list )
        old-tbl-avail = false
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if not available ub._File then do:
        assign
          old-tbl-avail = true
        .
      end.
      else do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'gds-code':U
          no-error .
        if not available ub._Field then do:
          assign
            old-tbl-avail = true
          .
        end.
      end.
      if old-tbl-avail = true then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > v-ind
           or lookup( v-tbl-name, v-ignore-list ) > 0
           or lookup( v-tbl-name, v-special-list ) > 0
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    assign
      v-num-entries = num-entries( v-ignore-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name = entry( v-ind, v-ignore-list )
        old-tbl-avail = false
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if not available ub._File then do:
        assign
          old-tbl-avail = true
        .
      end.
      else do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'gds-code':U
          no-error .
        if not available ub._Field then do:
          assign
            old-tbl-avail = true
          .
        end.
      end.
      if old-tbl-avail = true then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > 0
           or lookup( v-tbl-name, v-ignore-list ) > v-ind
           or lookup( v-tbl-name, v-special-list ) > 0
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    assign
      v-num-entries = num-entries( v-special-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name = entry( v-ind, v-special-list )
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if available ub._File then do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'gds-code':U
          no-error .
      end.
      if not available ub._File
        or ( available ub._File
             and not available ub._Field
           )
      then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > 0
           or lookup( v-tbl-name, v-ignore-list ) > 0
           or lookup( v-tbl-name, v-special-list ) > v-ind
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    if v-tbl-not-idx <> "" then do:
      assign
        v-msg = v-msg + substitute( "Таблицы не имеют индекса с полями &3 на первом месте и нет спецобработки: &2&1&1", chr(10), v-tbl-not-idx, 'gds-code':U )
      .
    end.
    if new-tbl-list <> "":U then do:
      assign
        v-msg = v-msg + substitute( "Нет обработки таблиц: &2&1&1", chr(10), new-tbl-list )
      .
    end.
    if v-double-tbl <> "":U then do:
      assign
        v-msg = v-msg + substitute( "В списках есть задублированные таблицы: &2&1&1", chr(10), v-double-tbl )
      .
    end.
    if old-tbl-list <> "":U then do:
      assign
        v-msg = v-msg + substitute( "В списках есть несуществующие таблицы или таблицы в которых отсутствуют переименовываемые поля: &2&1&1", chr(10), old-tbl-list )
      .
    end.
    if v-msg <> "":U then do:
      return error substitute( "Утилита переименования &3 не корректна.&1&1&2", chr(10), v-msg, 'gds-code':U ) .
    end.
  end.
end procedure.
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on quit   undo, return error substitute( "&1. quit", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define buffer buf_rename_goods for ub.goods .
  define buffer b-goods for ub.goods .
  define buffer buf_lock_batchprocess for ub.batchprocess .
  define variable old-gds-key-rec like ub.route.uniq-key-rec  no-undo.
  define variable v-ind         as integer   no-undo .
  define variable v-num-entries as integer   no-undo .
  define variable v-tbl-name    as character no-undo .
  run gbl/lockrngd.p
    (input 'grgc':U
    ,input 'enable':U
    ,buffer buf_lock_batchprocess
    ) no-error .
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при блокировании функции переименования кода товара&2&3&2&4"
                                  ,vss-workfile
                                  ,chr(10)
                                  ,error-status :get-message(1)
                                  ,return-value
                                  ) .
  end.
  update_block:
  do transaction
  on error  undo update_block, return error substitute( "&1 (update_block). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo update_block, return error substitute( "&1 (update_block). stop", vss-workfile )
  on quit   undo update_block, return error substitute( "&1 (update_block). quit", vss-workfile )
  on endkey undo update_block, return error substitute( "&1 (update_block). endkey", vss-workfile )
  :
    find first buf_rename_goods exclusive-lock
      where buf_rename_goods.gds-code = old-gds-code
      no-error .
    if not available buf_rename_goods then do:
      if g#news
      then do:
        return.
      end.
      else do:
        return error "Товар не доступен".
      end.
    end.
    if buf_rename_goods.gds-code <> old-gds-code then do:
      return error substitute( "Товарa с gds-code &1 НЕСУЩЕСТВУЕТ! Переименование не возможно.", old-gds-code ) .
    end.
    if new-gds-code = old-gds-code then do:
      if g#news then do:
        return.
      end.
      else do:
        return error "Новый код товара должен отличаться от старого" .
      end.
    end.
    if can-find(first b-goods no-lock where b-goods.gds-code  = new-gds-code) then do:
      return error substitute( "Уже существует товар с кодом &1", new-gds-code ) .
    end.
    RUN gen-key-rec
      (input 'goods':U
      ,input (buffer buf_rename_goods:handle)
      ,output old-gds-key-rec
      ).
    run waitfram-show in this-procedure
      (input 'Переименование кода товара ' + string( buf_rename_goods.gds-code )
      ).
    run invalidate-md5-signature in this-procedure .
    assign
      v-num-entries = num-entries( "abc-analysis-gds-obj,abc-analysis-gds-obj-attr,abc-analysis-goods,abc-analysis-goods-attr,abcxyz-analysis-goods,abcxyz-analysis-goods-attr,action-post-role,action-role-item-gds,add-line,c-add-line,aht-gds,aht-gds-attr,aht-ot-line,aht-ot-line-attr,aht-stk-line,aht-stk-line-attr,alc-type-gds,c-alc-type-gds,alc-type-gds-attr,arh-wth-cli,arh-wth-cli-attr,arh-wth-cli-doc,arh-wth-cli-doc-attr,arh-wth-tot,arh-wth-w-p,assortment-matrix-goods,assortment-matrix-goods-attr,c-assortment-matrix-goods,bar-code,bar-code-attr,bar-code-obj-attr,c-bar-code,c-bar-code-attr,c-bar-code-obj-attr,cd-doc-line,c-cd-doc-line,cd-event-log,cd-plu,c-cd-plu,chk-gds-pay,contract-specif,c-contract-specif,contract-specif-attr,dis-gds-rule,c-dis-gds-rule,dis-gds-rule-attr,doc-fbr-gds,c-doc-fbr-gds,doc-fbr-gds-attr,doc-line-attr,c-doc-line-attr,doc-line-sum,c-doc-line-sum,doc-pl,doc-pl-attr,c-doc-pl,doc-pl-pump,doc-pl-pump-attr,c-doc-pl-pump,doc-prts,c-doc-prts,ext-artic,c-ext-artic,ext-artic-attr,c-ext-artic-attr,ext-artic-db,ext-artic-db-attr,ext-artic-host,ext-artic-host-attr,ext-artic-obj,ext-artic-obj-attr,factur-connect-line,fbr-history,fbr-gds-obj,c-fbr-gds-obj,fbr-gds-obj-attr,c-fbr-gds-obj-attr,fbr-pln-line,c-fbr-pln-line,c-fbr-prn,fbr-prn-gds,c-fbr-prn-gds,fbr-prn-gds-attr,fbr-recipe,fbr-recipe-gds,fin-gds-part,fin-gds-part-attr,c-fin-gds-part,c-gds-hist,gds-add-charges,gds-add-charges-attr,c-gds-add-charges,c-gds-add-charges-attr,gds-host-attr,c-gds-host-attr,gds-obj,c-gds-obj,c-gds-obj-ref,gds-obj-attr,c-gds-obj-attr,gds-obj-flag,gds-obj-flag-attr,gds-obj-prop,gds-obj-prop-attr,c-gds-obj-prop,gds-season,gds-season-attr,c-gds-season,c-goods,goods-attr,c-goods-attr,hold-sale,hold-goods,hold-purch,hold-purch-supp-gds,hold-sale-attr,hold-goods-attr,hold-purch-attr,hold-purch-supp-gds-attr,icnt-line,ord-cons-line-attr,ord-dtl,c-ord-dtl,ord-line,c-ord-line,c-ord-line-attr,ord-line-attr,ord-line-rcv,ord-rcv-line-attr,parts-attr,parts-add,c-parts-add,parts-add-attr,c-parts-attr,parts-obj-attr,c-parts-obj-attr,parts-root,parts-root-attr,c-parts-root,pl-gds,c-pl-gds,c-pl-gds-obj,pl-gds-attr,c-pl-gds-attr,c-plc-hist,c-pmp-hist,pl-gds-pump,c-pl-gds-pump,pl-gds-pump-attr,c-pl-gds-pump-attr,price-all,rcs-retail1product,recipe,c-recipe,c-recipe-gds,recipe-gds,recipe-develop,c-recipe-develop,c-recipe-hist,rvs-line,rvs-line-attr,c-rvs-line,rvs-pump,rvs-line-pump,rvs-line-pump-attr,c-rvs-line-pump,s-coeff,c-s-coeff,s-coeff-attr,schet-fact-line,c-schet-fact-line,tax-rate-gds,tax-rate-gds-attr,turnover-buyer-gds,turnover-buyer-gds-attr,user-login-action-item,user-login-action-role,varianty-delivery-gds-obj,c-varianty-delivery-gds-obj,wth-dtl,c-wth-dtl,wth-gds,c-wth-gds,wth-gds-attr,c-wth-gds-attr,wth-dtl,c-wth-dtl,wth-parts,c-wth-parts,xyz-analysis-gds-obj,xyz-analysis-gds-obj-attr,xyz-analysis-goods,xyz-analysis-goods-attr,egais-gds,c-egais-gds,vsd,c-vsd,gds-mercury,c-gds-mercury,PromoGift,PromoGoods,c-PromoGift,c-PromoGoods,OperServ,c-OperServ,c-goods-attr-any,utd-lines,c-utd-marking-lines,c-utd-lines,marking-lines,utd-marking-lines,marking,c-contract-specif-attr,c-marking,order-line,c-order-line,shift-param":U )
    .
    do v-ind = 1 to v-num-entries
    on error  undo update_block, return error substitute( "&1 (TABLE-RGDS_LIST). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    on stop   undo update_block, return error substitute( "&1 (TABLE-RGDS_LIST). stop", vss-workfile )
    on quit   undo update_block, return error substitute( "&1 (TABLE-RGDS_LIST). quit", vss-workfile )
    on endkey undo update_block, return error substitute( "&1 (TABLE-RGDS_LIST). endkey", vss-workfile )
    :
      assign
        v-tbl-name = entry( v-ind, "abc-analysis-gds-obj,abc-analysis-gds-obj-attr,abc-analysis-goods,abc-analysis-goods-attr,abcxyz-analysis-goods,abcxyz-analysis-goods-attr,action-post-role,action-role-item-gds,add-line,c-add-line,aht-gds,aht-gds-attr,aht-ot-line,aht-ot-line-attr,aht-stk-line,aht-stk-line-attr,alc-type-gds,c-alc-type-gds,alc-type-gds-attr,arh-wth-cli,arh-wth-cli-attr,arh-wth-cli-doc,arh-wth-cli-doc-attr,arh-wth-tot,arh-wth-w-p,assortment-matrix-goods,assortment-matrix-goods-attr,c-assortment-matrix-goods,bar-code,bar-code-attr,bar-code-obj-attr,c-bar-code,c-bar-code-attr,c-bar-code-obj-attr,cd-doc-line,c-cd-doc-line,cd-event-log,cd-plu,c-cd-plu,chk-gds-pay,contract-specif,c-contract-specif,contract-specif-attr,dis-gds-rule,c-dis-gds-rule,dis-gds-rule-attr,doc-fbr-gds,c-doc-fbr-gds,doc-fbr-gds-attr,doc-line-attr,c-doc-line-attr,doc-line-sum,c-doc-line-sum,doc-pl,doc-pl-attr,c-doc-pl,doc-pl-pump,doc-pl-pump-attr,c-doc-pl-pump,doc-prts,c-doc-prts,ext-artic,c-ext-artic,ext-artic-attr,c-ext-artic-attr,ext-artic-db,ext-artic-db-attr,ext-artic-host,ext-artic-host-attr,ext-artic-obj,ext-artic-obj-attr,factur-connect-line,fbr-history,fbr-gds-obj,c-fbr-gds-obj,fbr-gds-obj-attr,c-fbr-gds-obj-attr,fbr-pln-line,c-fbr-pln-line,c-fbr-prn,fbr-prn-gds,c-fbr-prn-gds,fbr-prn-gds-attr,fbr-recipe,fbr-recipe-gds,fin-gds-part,fin-gds-part-attr,c-fin-gds-part,c-gds-hist,gds-add-charges,gds-add-charges-attr,c-gds-add-charges,c-gds-add-charges-attr,gds-host-attr,c-gds-host-attr,gds-obj,c-gds-obj,c-gds-obj-ref,gds-obj-attr,c-gds-obj-attr,gds-obj-flag,gds-obj-flag-attr,gds-obj-prop,gds-obj-prop-attr,c-gds-obj-prop,gds-season,gds-season-attr,c-gds-season,c-goods,goods-attr,c-goods-attr,hold-sale,hold-goods,hold-purch,hold-purch-supp-gds,hold-sale-attr,hold-goods-attr,hold-purch-attr,hold-purch-supp-gds-attr,icnt-line,ord-cons-line-attr,ord-dtl,c-ord-dtl,ord-line,c-ord-line,c-ord-line-attr,ord-line-attr,ord-line-rcv,ord-rcv-line-attr,parts-attr,parts-add,c-parts-add,parts-add-attr,c-parts-attr,parts-obj-attr,c-parts-obj-attr,parts-root,parts-root-attr,c-parts-root,pl-gds,c-pl-gds,c-pl-gds-obj,pl-gds-attr,c-pl-gds-attr,c-plc-hist,c-pmp-hist,pl-gds-pump,c-pl-gds-pump,pl-gds-pump-attr,c-pl-gds-pump-attr,price-all,rcs-retail1product,recipe,c-recipe,c-recipe-gds,recipe-gds,recipe-develop,c-recipe-develop,c-recipe-hist,rvs-line,rvs-line-attr,c-rvs-line,rvs-pump,rvs-line-pump,rvs-line-pump-attr,c-rvs-line-pump,s-coeff,c-s-coeff,s-coeff-attr,schet-fact-line,c-schet-fact-line,tax-rate-gds,tax-rate-gds-attr,turnover-buyer-gds,turnover-buyer-gds-attr,user-login-action-item,user-login-action-role,varianty-delivery-gds-obj,c-varianty-delivery-gds-obj,wth-dtl,c-wth-dtl,wth-gds,c-wth-gds,wth-gds-attr,c-wth-gds-attr,wth-dtl,c-wth-dtl,wth-parts,c-wth-parts,xyz-analysis-gds-obj,xyz-analysis-gds-obj-attr,xyz-analysis-goods,xyz-analysis-goods-attr,egais-gds,c-egais-gds,vsd,c-vsd,gds-mercury,c-gds-mercury,PromoGift,PromoGoods,c-PromoGift,c-PromoGoods,OperServ,c-OperServ,c-goods-attr-any,utd-lines,c-utd-marking-lines,c-utd-lines,marking-lines,utd-marking-lines,marking,c-contract-specif-attr,c-marking,order-line,c-order-line,shift-param":U )
      .
      run waitfram-show in this-procedure
        ( input substitute( "Переименование кода товара &1. Обработка таблицы &2", old-gds-code, v-tbl-name )
        ).
      run ren-gds-code in this-procedure
        ( input v-tbl-name
         ,input old-gds-key-rec
         ,input old-gds-code
         ,input new-gds-code
         ,input "":U
         ,input "":U
         ,input "":U
        ) no-error.
      if error-status :error then do:
        undo, return error substitute( "&1. Ошибка при переименовании кода товара в таблице &2&3&4&3&5"
                                      ,vss-workfile
                                      ,v-tbl-name
                                      ,chr(10)
                                      ,error-status :get-message(1)
                                      ,return-value
                                    ) .
      end.
    end.
    run waitfram-show in this-procedure
      (input substitute( "Переименование кода товара &1. Обработка таблицы &2", old-gds-code, 'goods':U )
      ).
    run ren-gds-code in this-procedure
      ( input 'goods':U
       ,input old-gds-key-rec
       ,input old-gds-code
       ,input new-gds-code
       ,input "":U
       ,input "":U
       ,input "":U
      ) no-error.
    if error-status :error then do:
      undo, return error substitute( "&1. Ошибка при переименовании кода товара в таблице &2&3&4&3&5"
                                    ,vss-workfile
                                    ,'goods':U
                                    ,chr(10)
                                    ,error-status :get-message(1)
                                    ,return-value
                                  ) .
    end.
    run waitfram-show in this-procedure
      (input substitute( "Переименование кода товара &1. Создание записи истории", old-gds-code )
      ).
    run goodsh_write-goods-proc in this-procedure
      ( buffer buf_rename_goods
       ,input integer('9':U)
       ,input 'ren-gdsc':U
       ,input string( old-gds-code )
      ) .
  end.
  run waitfram-hide in this-procedure .
  return .
end.
procedure invalidate-md5-signature :
  define buffer buf_archive-history for ub.archive-history .
  do
  on error undo, return error return-value
  :
    define variable v-create-chip-num as integer   no-undo .
    for each buf_archive-history exclusive-lock
      where buf_archive-history.file-valid = true
    break
    by buf_archive-history.obj-type
    by buf_archive-history.obj-code
    by buf_archive-history.archive-type
    on error undo, return error return-value
    :
      if first-of(buf_archive-history.archive-type)
      then do:
        run utl/arhiscr.p
          (input  buf_archive-history.obj-type
          ,input  buf_archive-history.obj-code
          ,input  buf_archive-history.archive-type
          ,input  'ren-gds-code':U
          ,input  ""
          ,input  ""
          ,input  0
          ,input  ""
          ,input  ""
          ,input  ?
          ,output v-create-chip-num
          ) .
      end.
      assign
        buf_archive-history.file-valid            = false
        buf_archive-history.file-invalid-chip-num = v-create-chip-num
      .
    end.
  end.
end procedure.
