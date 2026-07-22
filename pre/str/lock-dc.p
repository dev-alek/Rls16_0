block-level on error undo, throw.
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-doc-code like ub.trn-doc.doc-code no-undo .
define input parameter p-d-card like ub.dis-card.d-card no-undo .
define input parameter p-step             as integer no-undo .
define input parameter p-is-news          as logical no-undo .
define input parameter log-file-name      as character no-undo .
define output parameter p-num-dc          as integer no-undo .
define variable vss-revision    as character no-undo initial "$Revision: 5c3607367a23, 584, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SShalanin $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Apr 11 17:28:29 2016 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: lock-dc.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/lock-dc.p $":U .
define variable vss-description as character no-undo initial "Блокировка товаров по документу":U .
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
      p-vss-parameters = substitute('&1|&2',p-doc-code,p-is-news)
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
define variable v-count   as integer   no-undo initial 0 .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-lock-chr as character no-undo .
define variable v-first-main-card as character no-undo .
define variable v-d-card as character no-undo .
define buffer buf_trn-doc  for ub.trn-doc .
define buffer buf_dis-card for ub.dis-card  .
define buffer buf2_dis-card for ub.dis-card  .
define buffer buf3_dis-card for ub.dis-card  .
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_fin-doc for ub.fin-doc.
define buffer buf_payment for ub.payment.
main-block :
do transaction
on error undo main-block, return error return-value
:
  if valid-handle(p-log-handle) then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Блокировка ДК..." )).
  end.
  CASE p-doc-type:
    when 'inkas':U then do:
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = p-doc-code
        no-error .
      if not available buf_trn-doc then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не найден документ" skip
          "Документ" p-doc-code skip
          view-as alert-box error .
        undo main-block, return error .
      end.
      for each buf_chk-doc no-lock where
              buf_chk-doc.obj-type = buf_trn-doc.obj-type
          and buf_chk-doc.obj-code = buf_trn-doc.obj-code
          and buf_chk-doc.d-card > '':U
      on error undo main-block, return error
      :
        if lookup(string(buf_chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then NEXT .
        find first buf_dis-card no-lock
          where buf_dis-card.d-card = buf_chk-doc.d-card
          no-error .
        if not available buf_Dis-card then do:
          undo main-block, return error substitute ("&1 &2 &3&4Не найдена ДК&4Документ &5&4Чек &6"
                                                    ,vss-workfile
                                                    ,vss-revision
                                                    ,vss-description
                                                    ,chr(10)
                                                    ,buf_trn-doc.doc-code
                                                    ,buf_chk-doc.doc-code).
        end.
        assign
        v-count  = v-count + 1
        .
        if v-count mod 10 = 0 then do:
          if log-file-name <> '':U
          and valid-handle (p-log-handle) then do:
            run show-counter in p-log-handle .
            run write-counter in p-log-handle (substitute("Обработано: &1. Подготовка данных - карта &2"
                                              , v-count
                                              , buf_dis-card.d-card
                                              )) no-error.
          end.
        end.
        find current buf_dis-card exclusive-lock .
        assign
        v-first-main-card = buf_dis-card.first-main-card.
        release buf_dis-card .
        for each buf2_dis-card where
                buf2_dis-card.first-main-card =  v-first-main-card
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
          find buf_dis-card exclusive-lock where buf_dis-card.d-card = buf2_dis-card.d-card.
          release buf_dis-card .
        end.
      end.
    end.
    when 'trn-doc':U then do:
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = p-doc-code
        no-error .
      if not available buf_trn-doc then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не найден документ" skip
          "Документ" p-doc-code skip
          view-as alert-box error .
        undo main-block, return error .
      end.
      for each buf2_dis-card no-lock where
              buf2_dis-card.d-card = buf_trn-doc.d-card
      on error undo main-block, return error :
        find first buf_dis-card no-lock where buf_Dis-card.d-card = buf2_dis-card.d-card no-error.
        if not available buf_Dis-card then do:
          undo main-block, return error substitute ("&1 &2 &3&4Не найдена ДК из шапки документа&4Документ &5&4"
                                                    ,vss-workfile
                                                    ,vss-revision
                                                    ,vss-description
                                                    ,chr(10)
                                                    ,buf_trn-doc.doc-code
                                                    ).
        end.
        v-first-main-card = buf_dis-card.first-main-card.
        for each buf3_dis-card where
                buf3_dis-card.first-main-card =  v-first-main-card
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
          find buf_dis-card exclusive-lock where buf_dis-card.d-card = buf3_dis-card.d-card.
          release buf_dis-card .
        end.
      end.
    end.
    when 'dis-card-type':U then do:
      run gen-row-keyr in this-procedure
        ( input p-doc-code
         ,input ?
         ,input "ub"
         ,input ?
         ,input NO-LOCK
         ,output v-tbl-row
         ,output v-tbl-name
        ) no-error.
      find first buf_Dis-card-type no-lock where
                rowid(buf_dis-card-type) = v-tbl-row no-error.
      if not available buf_dis-card-type then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не найден ТИП ДК" p-doc-code skip
          view-as alert-box error .
        undo main-block, return error .
      end.
      _dis-card:
      for each buf2_dis-card no-lock where
              buf2_dis-card.type              = buf_dis-card-type.type
          and buf2_dis-card.emitent-host-code = buf_dis-card-type.emitent-host-code
          and buf2_dis-card.d-card            > p-d-card
      on error undo main-block, return error
      :
        v-first-main-card = buf2_dis-card.first-main-card.
        find first buf_dis-card no-lock
          where buf_dis-card.d-card = buf2_dis-card.d-card
          no-error .
        if not available buf_Dis-card then do:
          undo main-block, return error substitute ("&1 &2 &3&4Не найдена ДК &5&4Тип &5"
                                                    ,vss-workfile
                                                    ,vss-revision
                                                    ,vss-description
                                                    ,chr(10)
                                                    ,buf2_Dis-card.d-card
                                                    ,p-doc-code
                                                    ).
        end.
        if v-lock-chr <> '*':U then do:
          run is-to-lock-d-card in p-parent-handle ( input buf_dis-card.d-card, output v-lock-chr ) no-error.
          if v-lock-chr = "*"  then do:
          end.
          else if v-lock-chr = 'no' then do:
            v-lock-chr = '':U.
            next _dis-card.
          end.
        end.
        assign
        v-count  = v-count + 1
        .
        if v-count mod 10 = 0 then do:
          if log-file-name <> '':U
          and valid-handle (p-log-handle) then do:
            run show-counter in p-log-handle .
            run write-counter in p-log-handle (substitute("Обработано: &1. Подготовка данных - карта &2"
                                              , v-count
                                              , buf_dis-card.d-card
                                              )) no-error.
          end.
        end.
        for each buf3_dis-card no-lock where
                buf3_dis-card.first-main-card = v-first-main-card
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
          find buf_dis-card exclusive-lock where buf_dis-card.d-card = buf3_dis-card.d-card.
          release buf_dis-card .
        end.
        if v-count = 100 then do:
          p-num-dc = v-count.
          return.
        end.
      end.
      p-num-dc = v-count.
    end.
    when 'dis-card':U then do:
      find first buf_Dis-card no-lock where
               buf_dis-card.d-card = p-doc-code no-error.
      if not available buf_dis-card then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не найдена ДК" p-doc-code skip
          view-as alert-box error .
        undo main-block, return error .
      end.
      v-first-main-card = buf_dis-card.first-main-card.
      _dis-card:
      for each buf2_dis-card no-lock where
            buf2_dis-card.first-main-card      = v-first-main-card
      on error undo main-block, return error
      :
        find first buf_dis-card exclusive-lock where buf_dis-card.d-card = buf2_dis-card.d-card.
        release buf_dis-card .
      end.
    end.
    when 'payment':U then do:
      find first buf_payment no-lock
        where buf_payment.pmnt-code = p-doc-code
        no-error .
      if not available buf_payment then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не найден платеж по ДК" skip
          "Документ" p-doc-code skip
          view-as alert-box error .
        undo main-block, return error .
      end.
      for each buf2_dis-card no-lock where
              buf2_dis-card.d-card = buf_payment.d-card
      on error undo main-block, return error :
        find first buf_dis-card no-lock where buf_Dis-card.d-card = buf2_dis-card.d-card no-error.
        if not available buf_Dis-card then do:
          undo main-block, return error substitute ("&1 &2 &3&4Не найдена ДК из шапки платежа&4Документ &5&4"
                                                    ,vss-workfile
                                                    ,vss-revision
                                                    ,vss-description
                                                    ,chr(10)
                                                    ,buf_payment.pmnt-code
                                                    ).
        end.
        v-first-main-card = buf_dis-card.first-main-card.
        for each buf3_dis-card where
                buf3_dis-card.first-main-card =  v-first-main-card
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
          find buf_dis-card exclusive-lock where buf_dis-card.d-card = buf3_dis-card.d-card.
          release buf_dis-card .
        end.
      end.
    end.
    when 'fin-doc':U then do:
      find first buf_fin-doc no-lock
        where buf_fin-doc.fin-doc-code = integer(p-doc-code)
        no-error .
      if not available buf_fin-doc then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не найден платеж"  p-doc-code skip
          view-as alert-box error .
        undo main-block, return error .
      end.
      for each buf_payment no-lock where
              buf_payment.source-type = 'платеж':U
          and buf_payment.source-ref = string(buf_fin-doc.fin-doc-code)
          and buf_payment.d-card > '':U
      on error undo main-block, return error
      :
        find first buf_dis-card no-lock
          where buf_dis-card.d-card = buf_payment.d-card
          no-error .
        if not available buf_Dis-card then do:
          undo main-block, return error substitute ("&1 &2 &3&4Не найдена ДК&4Платеж &5&4Платеж на ДК &6"
                                                    ,vss-workfile
                                                    ,vss-revision
                                                    ,vss-description
                                                    ,chr(10)
                                                    ,buf_fin-doc.fin-doc-code
                                                    ,buf_payment.pmnt-code).
        end.
        assign
        v-count  = v-count + 1
        .
        if v-count mod 10 = 0 then do:
          if log-file-name <> '':U
          and valid-handle (p-log-handle) then do:
            run show-counter in p-log-handle .
            run write-counter in p-log-handle (substitute("Обработано: &1. Подготовка данных - карта &2"
                                              , v-count
                                              , buf_dis-card.d-card
                                              )) no-error.
          end.
        end.
        find current buf_dis-card exclusive-lock .
        assign
        v-first-main-card = buf_dis-card.first-main-card
        v-d-card = buf_dis-card.d-card
        .
        release buf_dis-card .
        for each buf2_dis-card where
                buf2_dis-card.first-main-card =  v-first-main-card
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
          if buf2_dis-card.d-card <> v-d-card then do:
            v-count = v-count + 1.
          end.
          find buf_dis-card exclusive-lock where buf_dis-card.d-card = buf2_dis-card.d-card.
          release buf_dis-card .
        end.
      end.
      p-num-dc = v-count.
    end.
  END CASE.
end.
